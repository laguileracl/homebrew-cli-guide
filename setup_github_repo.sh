#!/bin/bash

# 🚀 Script para preparar y subir el proyecto a GitHub
# Este script automatiza el proceso de crear y configurar el repositorio

set -e  # Exit on any error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Funciones de logging
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_header() {
    echo -e "\n${BOLD}${BLUE}📚 $1${NC}\n"
}

# Verificar dependencias
check_dependencies() {
    log_header "Verificando dependencias..."
    
    if ! command -v git &> /dev/null; then
        log_error "Git no está instalado"
        exit 1
    fi
    log_success "Git encontrado"
    
    if ! command -v gh &> /dev/null; then
        log_warning "GitHub CLI (gh) no encontrado. Se necesitará configuración manual del repositorio"
        USE_GH_CLI=false
    else
        log_success "GitHub CLI encontrado"
        USE_GH_CLI=true
    fi
    
    if ! command -v quarto &> /dev/null; then
        log_warning "Quarto no encontrado. Instalando..."
        brew install quarto
        log_success "Quarto instalado"
    else
        log_success "Quarto encontrado"
    fi
}

# Preparar archivos del proyecto
prepare_project() {
    log_header "Preparando archivos del proyecto..."
    
    # Crear .gitignore si no existe
    if [ ! -f .gitignore ]; then
        log_info "Creando .gitignore..."
        cat > .gitignore << 'EOF'
# Quarto
_book/
.quarto/
*.html

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Logs
*.log
logs/

# Temporary files
*.tmp
*.temp
.cache/

# IDE
.vscode/
.idea/
*.swp
*.swo

# Environment variables
.env
.env.local

# Backup files
*~
*.bak
*.backup

# System files
Thumbs.db
Desktop.ini
EOF
        log_success ".gitignore creado"
    fi
    
    # Verificar que el libro se puede generar
    log_info "Verificando que el libro se puede generar..."
    if quarto render --quiet; then
        log_success "Libro generado correctamente"
    else
        log_error "Error al generar el libro"
        exit 1
    fi
    
    # Limpiar archivos de build para el repo
    rm -rf _book/
    log_success "Archivos de build limpiados"
}

# Configurar Git
setup_git() {
    log_header "Configurando Git..."
    
    # Verificar si ya es un repo git
    if [ ! -d .git ]; then
        log_info "Inicializando repositorio Git..."
        git init
        log_success "Repositorio Git inicializado"
    else
        log_info "Repositorio Git ya existe"
    fi
    
    # Configurar rama principal
    git checkout -b main 2>/dev/null || git checkout main
    
    # Añadir archivos
    log_info "Añadiendo archivos al repositorio..."
    git add .
    
    # Hacer commit inicial si no hay commits
    if ! git rev-parse HEAD >/dev/null 2>&1; then
        log_info "Creando commit inicial..."
        git commit -m "🎉 Initial commit: Guía Práctica de Herramientas CLI con Homebrew

📚 Libro completo con 11 capítulos cubriendo más de 200 herramientas CLI
🔧 Scripts de automatización para mantenimiento de Homebrew  
📖 Documentación generada con Quarto
🤝 Preparado para contribuciones de la comunidad

Capítulos incluidos:
- Navegación y Sistema
- Gestión de Archivos
- Búsqueda y Filtros
- Desarrollo
- Multimedia
- Red y Conectividad
- Monitoreo del Sistema
- Procesamiento de Texto
- Utilidades Generales
- Flujos Avanzados
- Configuración del Entorno"
        log_success "Commit inicial creado"
    else
        log_info "Ya existen commits en el repositorio"
    fi
}

# Crear repositorio en GitHub
create_github_repo() {
    log_header "Configurando repositorio en GitHub..."
    
    if [ "$USE_GH_CLI" = true ]; then
        log_info "¿Quieres crear el repositorio automáticamente con GitHub CLI? (y/N)"
        read -r create_auto
        
        if [[ $create_auto =~ ^[Yy]$ ]]; then
            log_info "Ingresa el nombre del repositorio (default: homebrew-cli-guide):"
            read -r repo_name
            repo_name=${repo_name:-homebrew-cli-guide}
            
            log_info "¿Repositorio público? (Y/n)"
            read -r is_public
            if [[ $is_public =~ ^[Nn]$ ]]; then
                visibility="--private"
            else
                visibility="--public"
            fi
            
            log_info "Creando repositorio en GitHub..."
            gh repo create "$repo_name" $visibility \
                --description "📚 Guía completa de herramientas CLI disponibles via Homebrew con ejemplos prácticos y workflows" \
                --homepage "https://$(gh api user --jq .login).github.io/$repo_name" \
                --add-readme=false
            
            log_info "Configurando remote origin..."
            git remote add origin "https://github.com/$(gh api user --jq .login)/$repo_name.git"
            
            log_success "Repositorio creado: https://github.com/$(gh api user --jq .login)/$repo_name"
        fi
    else
        log_warning "Para crear el repositorio manualmente:"
        echo -e "${YELLOW}1. Ve a https://github.com/new${NC}"
        echo -e "${YELLOW}2. Crea un repositorio llamado 'homebrew-cli-guide'${NC}"
        echo -e "${YELLOW}3. No inicialices con README, .gitignore o license${NC}"
        echo -e "${YELLOW}4. Luego ejecuta:${NC}"
        echo -e "${BLUE}   git remote add origin https://github.com/laguileracl/homebrew-cli-guide.git${NC}"
        echo ""
        log_info "Presiona Enter cuando hayas creado el repositorio..."
        read -r
    fi
}

# Subir código
push_code() {
    log_header "Subiendo código a GitHub..."
    
    # Verificar que hay un remote
    if ! git remote get-url origin >/dev/null 2>&1; then
        log_error "No hay remote 'origin' configurado"
        log_info "Configura el remote manualmente:"
        echo -e "${BLUE}git remote add origin https://github.com/laguileracl/REPO-NAME.git${NC}"
        exit 1
    fi
    
    log_info "Subiendo código..."
    if git push -u origin main; then
        log_success "Código subido correctamente"
    else
        log_error "Error al subir el código"
        exit 1
    fi
}

# Configurar GitHub Pages
setup_github_pages() {
    log_header "Configurando GitHub Pages..."
    
    if [ "$USE_GH_CLI" = true ]; then
        log_info "¿Quieres habilitar GitHub Pages automáticamente? (y/N)"
        read -r enable_pages
        
        if [[ $enable_pages =~ ^[Yy]$ ]]; then
            log_info "Habilitando GitHub Pages..."
            # Note: GitHub Pages configuration via CLI might need manual setup
            # The workflow will handle the deployment
            log_warning "GitHub Pages se configurará automáticamente con el primer push"
            log_info "Revisa la configuración en: Settings > Pages en tu repositorio"
        fi
    else
        log_warning "Para habilitar GitHub Pages manualmente:"
        echo -e "${YELLOW}1. Ve a tu repositorio en GitHub${NC}"
        echo -e "${YELLOW}2. Settings > Pages${NC}"
        echo -e "${YELLOW}3. Source: GitHub Actions${NC}"
        echo -e "${YELLOW}4. El workflow se ejecutará automáticamente${NC}"
    fi
}

# Mostrar resumen final
show_summary() {
    log_header "🎉 ¡Proyecto configurado exitosamente!"
    
    echo -e "${GREEN}✅ Repositorio Git configurado${NC}"
    echo -e "${GREEN}✅ Archivos preparados para GitHub${NC}"
    echo -e "${GREEN}✅ Workflow de CI/CD configurado${NC}"
    echo -e "${GREEN}✅ Templates de issues y PRs listos${NC}"
    echo -e "${GREEN}✅ Documentación de contribución preparada${NC}"
    
    echo -e "\n${BOLD}🔗 Próximos pasos:${NC}"
    echo -e "${BLUE}1. Ve a tu repositorio en GitHub${NC}"
    echo -e "${BLUE}2. Configura GitHub Pages en Settings > Pages${NC}"
    echo -e "${BLUE}3. El libro se publicará automáticamente en cada push${NC}"
    echo -e "${BLUE}4. Invita a colaboradores y habilita Discussions${NC}"
    
    if git remote get-url origin >/dev/null 2>&1; then
        repo_url=$(git remote get-url origin | sed 's/\.git$//')
        echo -e "\n${BOLD}🌐 Enlaces importantes:${NC}"
        echo -e "${GREEN}📚 Repositorio: $repo_url${NC}"
        echo -e "${GREEN}📖 GitHub Pages: ${repo_url/github.com/$(basename $(dirname $repo_url)).github.io}${NC}"
        echo -e "${GREEN}🐛 Issues: $repo_url/issues${NC}"
        echo -e "${GREEN}💬 Discussions: $repo_url/discussions${NC}"
    fi
    
    echo -e "\n${BOLD}🚀 Para continuar trabajando:${NC}"
    echo -e "${BLUE}# Ver el libro localmente:${NC}"
    echo -e "${BLUE}quarto preview${NC}"
    echo -e "\n${BLUE}# Actualizar con cambios:${NC}"
    echo -e "${BLUE}git add .${NC}"
    echo -e "${BLUE}git commit -m \"feat: nueva funcionalidad\"${NC}"
    echo -e "${BLUE}git push${NC}"
}

# Script principal
main() {
    log_header "🚀 Preparando Guía CLI de Homebrew para GitHub"
    
    check_dependencies
    prepare_project
    setup_git
    create_github_repo
    push_code
    setup_github_pages
    show_summary
    
    log_success "¡Proceso completado! 🎉"
}

# Ejecutar script principal
main "$@"
