#!/bin/bash

# ============================================
# Script de Mantenimiento de Homebrew
# ============================================
# 
# Este script realiza las siguientes tareas:
# 1. Actualiza las fórmulas de Homebrew (brew update)
# 2. Actualiza los paquetes instalados (brew upgrade)
# 3. Limpia archivos antiguos y cache (brew cleanup)
# 4. Opcional: Regenera el README.md con la lista actualizada
#
# Uso: ./brew_maintenance.sh [--with-readme]
#

set -e  # Salir si cualquier comando falla

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar mensajes con color
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar que Homebrew esté instalado
if ! command -v brew &> /dev/null; then
    print_error "Homebrew no está instalado. Por favor instálalo primero."
    exit 1
fi

print_status "Iniciando mantenimiento de Homebrew..."

# 1. Actualizar las fórmulas de Homebrew
print_status "Actualizando fórmulas de Homebrew..."
if brew update; then
    print_success "Fórmulas actualizadas correctamente"
else
    print_error "Error al actualizar las fórmulas"
    exit 1
fi

# 2. Actualizar paquetes instalados
print_status "Actualizando paquetes instalados..."
if brew upgrade; then
    print_success "Paquetes actualizados correctamente"
else
    print_warning "Algunos paquetes podrían no haberse actualizado correctamente"
fi

# 3. Limpiar archivos antiguos y cache
print_status "Limpiando archivos antiguos y cache..."
if brew cleanup; then
    print_success "Limpieza completada"
else
    print_warning "La limpieza pudo haber tenido algunos problemas"
fi

# 4. Mostrar estadísticas finales
print_status "Generando reporte de estado..."
echo
echo "=========================="
echo "   REPORTE DE ESTADO"
echo "=========================="
echo "Fórmulas instaladas: $(brew list --formula | wc -l | tr -d ' ')"
echo "Casks instalados: $(brew list --cask | wc -l | tr -d ' ')"
echo "Espacio liberado en la última limpieza:"
brew cleanup --dry-run | tail -1 || echo "No hay archivos para limpiar"

# 5. Verificar el estado del sistema
print_status "Verificando estado del sistema..."
if brew doctor > /dev/null 2>&1; then
    print_success "Sistema Homebrew en buen estado"
else
    print_warning "Ejecuta 'brew doctor' para ver recomendaciones"
fi

# 6. Regenerar README si se solicita
if [[ "$1" == "--with-readme" ]]; then
    print_status "Regenerando README.md..."
    if [[ -f "generate_readme.sh" ]]; then
        ./generate_readme.sh
        print_success "README.md regenerado"
    else
        print_warning "Script generate_readme.sh no encontrado"
    fi
fi

print_success "¡Mantenimiento de Homebrew completado!"
echo
echo "Para ejecutar este script en el futuro:"
echo "  ./brew_maintenance.sh                  # Solo mantenimiento"
echo "  ./brew_maintenance.sh --with-readme    # Mantenimiento + actualizar README"
