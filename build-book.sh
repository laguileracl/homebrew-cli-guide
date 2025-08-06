#!/bin/bash

# =============================================================================
# CLI Tools Guide - Build Script
# Genera el libro en múltiples formatos con características avanzadas
# =============================================================================

set -euo pipefail

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuración
BOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${BOOK_DIR}/_book"
ASSETS_DIR="${BOOK_DIR}/assets"
VERSION="2.0.0"

# Funciones de utilidad
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_dependencies() {
    log_info "Verificando dependencias..."
    
    local deps=("quarto" "pandoc" "node" "npm")
    local missing=()
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            missing+=("$dep")
        fi
    done
    
    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Dependencias faltantes: ${missing[*]}"
        log_info "Instala las dependencias faltantes:"
        for dep in "${missing[@]}"; do
            case $dep in
                "quarto")
                    echo "  - Quarto: https://quarto.org/docs/get-started/"
                    ;;
                "pandoc")
                    echo "  - Pandoc: brew install pandoc"
                    ;;
                "node"|"npm")
                    echo "  - Node.js: brew install node"
                    ;;
            esac
        done
        exit 1
    fi
    
    log_success "Todas las dependencias están disponibles"
}

setup_assets() {
    log_info "Configurando assets..."
    
    # Crear directorio de assets si no existe
    mkdir -p "$ASSETS_DIR"
    
    # Generar imagen de portada (placeholder)
    if [ ! -f "$ASSETS_DIR/cover.png" ]; then
        log_info "Generando portada placeholder..."
        # Aquí podrías usar ImageMagick o similar para generar una portada
        cat > "$ASSETS_DIR/cover.png.placeholder" << 'EOF'
# Placeholder para cover.png
# En producción, aquí iría una imagen real de portada
# Dimensiones recomendadas: 800x1200px
EOF
    fi
    
    log_success "Assets configurados"
}

validate_content() {
    log_info "Validando contenido..."
    
    # Verificar que todos los archivos QMD existen
    local qmd_files=(
        "index.qmd"
        "interactive-playground.qmd"
        "navegacion.qmd"
        "archivos.qmd"
        "busqueda.qmd"
        "desarrollo.qmd"
        "multimedia.qmd"
        "red.qmd"
        "monitoreo.qmd"
        "texto.qmd"
        "utilidades.qmd"
        "combinaciones.qmd"
        "configuracion.qmd"
        "ecosystem-integration.qmd"
    )
    
    local missing_files=()
    for file in "${qmd_files[@]}"; do
        if [ ! -f "$BOOK_DIR/$file" ]; then
            missing_files+=("$file")
        fi
    done
    
    if [ ${#missing_files[@]} -ne 0 ]; then
        log_error "Archivos QMD faltantes: ${missing_files[*]}"
        exit 1
    fi
    
    # Verificar sintaxis de _quarto.yml
    if ! quarto check --quiet; then
        log_error "Error en la configuración de Quarto"
        exit 1
    fi
    
    log_success "Contenido validado correctamente"
}

build_html() {
    log_info "Construyendo versión HTML..."
    
    # Construir con Quarto
    if quarto render --to html; then
        log_success "Versión HTML construida exitosamente"
        
        # Copiar archivos adicionales
        cp "$BOOK_DIR/tools-explorer.html" "$OUTPUT_DIR/" 2>/dev/null || true
        cp "$BOOK_DIR/tools-index.json" "$OUTPUT_DIR/" 2>/dev/null || true
        cp "$BOOK_DIR/interactive-features.js" "$OUTPUT_DIR/" 2>/dev/null || true
        cp "$BOOK_DIR/custom-interactive.css" "$OUTPUT_DIR/" 2>/dev/null || true
        
        log_info "Archivos interactivos copiados"
    else
        log_error "Error construyendo versión HTML"
        return 1
    fi
}

build_pdf() {
    log_info "Construyendo versión PDF..."
    
    # Verificar que tenemos LaTeX
    if ! command -v pdflatex &> /dev/null; then
        log_warning "pdflatex no encontrado. Instalando BasicTeX..."
        if command -v brew &> /dev/null; then
            brew install --cask basictex
        else
            log_error "No se puede instalar LaTeX automáticamente"
            return 1
        fi
    fi
    
    if quarto render --to pdf; then
        log_success "Versión PDF construida exitosamente"
        
        # Mover PDF al directorio de salida con nombre descriptivo
        if [ -f "$OUTPUT_DIR/homebrew-cli-guide.pdf" ]; then
            cp "$OUTPUT_DIR/homebrew-cli-guide.pdf" "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.pdf"
        fi
    else
        log_warning "Error construyendo versión PDF (LaTeX puede requerir configuración adicional)"
        return 0  # No fallar por PDF
    fi
}

build_epub() {
    log_info "Construyendo versión EPUB..."
    
    if quarto render --to epub; then
        log_success "Versión EPUB construida exitosamente"
        
        # Mover EPUB al directorio de salida con nombre descriptivo
        if [ -f "$OUTPUT_DIR/homebrew-cli-guide.epub" ]; then
            cp "$OUTPUT_DIR/homebrew-cli-guide.epub" "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.epub"
        fi
    else
        log_warning "Error construyendo versión EPUB"
        return 0  # No fallar por EPUB
    fi
}

build_docx() {
    log_info "Construyendo versión DOCX..."
    
    if quarto render --to docx; then
        log_success "Versión DOCX construida exitosamente"
        
        # Mover DOCX al directorio de salida con nombre descriptivo
        if [ -f "$OUTPUT_DIR/homebrew-cli-guide.docx" ]; then
            cp "$OUTPUT_DIR/homebrew-cli-guide.docx" "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.docx"
        fi
    else
        log_warning "Error construyendo versión DOCX"
        return 0  # No fallar por DOCX
    fi
}

generate_manifest() {
    log_info "Generando manifiesto de build..."
    
    cat > "$OUTPUT_DIR/build-manifest.json" << EOF
{
  "version": "$VERSION",
  "build_date": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
  "build_system": "$(uname -s) $(uname -r)",
  "quarto_version": "$(quarto --version)",
  "pandoc_version": "$(pandoc --version | head -1)",
  "formats": {
    "html": {
      "available": $([ -f "$OUTPUT_DIR/index.html" ] && echo "true" || echo "false"),
      "interactive": true,
      "size_mb": "$(du -m "$OUTPUT_DIR" 2>/dev/null | cut -f1 || echo "0")"
    },
    "pdf": {
      "available": $([ -f "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.pdf" ] && echo "true" || echo "false"),
      "printable": true
    },
    "epub": {
      "available": $([ -f "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.epub" ] && echo "true" || echo "false"),
      "ebook_reader": true
    },
    "docx": {
      "available": $([ -f "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.docx" ] && echo "true" || echo "false"),
      "editable": true
    }
  },
  "features": {
    "interactive_code": true,
    "search": true,
    "dark_mode": true,
    "responsive": true,
    "offline_cli": true,
    "api_integration": true
  }
}
EOF
    
    log_success "Manifiesto generado: $OUTPUT_DIR/build-manifest.json"
}

optimize_output() {
    log_info "Optimizando salida..."
    
    # Comprimir archivos CSS y JS si existen
    if command -v terser &> /dev/null && [ -f "$OUTPUT_DIR/interactive-features.js" ]; then
        terser "$OUTPUT_DIR/interactive-features.js" -o "$OUTPUT_DIR/interactive-features.min.js"
        log_info "JavaScript minificado"
    fi
    
    # Generar archivos de checksums
    if command -v shasum &> /dev/null; then
        cd "$OUTPUT_DIR"
        find . -name "*.pdf" -o -name "*.epub" -o -name "*.docx" -o -name "*.html" | \
            xargs shasum -a 256 > checksums.sha256
        log_info "Checksums generados"
    fi
    
    log_success "Optimización completada"
}

create_distribution() {
    log_info "Creando paquete de distribución..."
    
    local dist_dir="$BOOK_DIR/dist"
    local archive_name="CLI-Tools-Guide-v${VERSION}-$(date +%Y%m%d)"
    
    mkdir -p "$dist_dir"
    
    # Crear archivo ZIP con todos los formatos
    if command -v zip &> /dev/null; then
        cd "$OUTPUT_DIR"
        zip -r "$dist_dir/${archive_name}.zip" . \
            -x "*.git*" "*node_modules*" "*.tmp*"
        log_success "Archivo ZIP creado: $dist_dir/${archive_name}.zip"
    fi
    
    # Crear tarball
    if command -v tar &> /dev/null; then
        cd "$OUTPUT_DIR"
        tar -czf "$dist_dir/${archive_name}.tar.gz" \
            --exclude=".git*" --exclude="node_modules*" --exclude="*.tmp*" .
        log_success "Tarball creado: $dist_dir/${archive_name}.tar.gz"
    fi
}

show_summary() {
    log_info "Resumen del build:"
    echo
    echo "📁 Directorio de salida: $OUTPUT_DIR"
    echo "📊 Formatos generados:"
    
    [ -f "$OUTPUT_DIR/index.html" ] && echo "   ✅ HTML (interactivo)"
    [ -f "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.pdf" ] && echo "   ✅ PDF"
    [ -f "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.epub" ] && echo "   ✅ EPUB"
    [ -f "$OUTPUT_DIR/CLI-Tools-Guide-v${VERSION}.docx" ] && echo "   ✅ DOCX"
    
    echo
    echo "🌐 Para servir localmente:"
    echo "   cd $OUTPUT_DIR && python3 -m http.server 8080"
    echo
    echo "🚀 Para desplegar:"
    echo "   rsync -av $OUTPUT_DIR/ tu-servidor:/var/www/html/"
    echo
    
    if [ -d "$BOOK_DIR/dist" ]; then
        echo "📦 Paquetes de distribución disponibles en: $BOOK_DIR/dist/"
    fi
}

# Función principal
main() {
    log_info "🚀 Iniciando build de CLI Tools Guide v$VERSION"
    echo
    
    # Verificar dependencias
    check_dependencies
    
    # Configurar assets
    setup_assets
    
    # Validar contenido
    validate_content
    
    # Limpiar directorio de salida
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
    
    # Construir formatos
    build_html
    build_pdf
    build_epub  
    build_docx
    
    # Post-procesamiento
    generate_manifest
    optimize_output
    create_distribution
    
    # Mostrar resumen
    echo
    log_success "🎉 Build completado exitosamente!"
    show_summary
}

# Manejo de argumentos
case "${1:-all}" in
    "html")
        check_dependencies
        setup_assets
        validate_content
        build_html
        ;;
    "pdf")
        check_dependencies
        setup_assets
        validate_content
        build_pdf
        ;;
    "epub")
        check_dependencies
        setup_assets
        validate_content
        build_epub
        ;;
    "docx")
        check_dependencies
        setup_assets
        validate_content
        build_docx
        ;;
    "clean")
        log_info "Limpiando archivos de build..."
        rm -rf "$OUTPUT_DIR" "$BOOK_DIR/dist"
        log_success "Limpieza completada"
        ;;
    "serve")
        cd "$OUTPUT_DIR" 2>/dev/null || cd "$BOOK_DIR"
        log_info "Sirviendo en http://localhost:8080"
        python3 -m http.server 8080
        ;;
    "all"|*)
        main
        ;;
esac
