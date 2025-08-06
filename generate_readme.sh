#!/bin/bash

# ============================================
# Generador de README.md para Homebrew
# ============================================
# 
# Este script genera un README.md completo con:
# - Lista de todas las fórmulas y casks instalados
# - Descripción de cada programa
# - Ejemplos de uso básicos
#

set -e

# Archivo de salida
README_FILE="README.md"

# Función para obtener descripción de un paquete
get_formula_description() {
    local formula="$1"
    brew info "$formula" 2>/dev/null | head -n 1 | sed 's/^[^:]*: //' || echo "Herramienta de línea de comandos"
}

get_cask_description() {
    local cask="$1"
    brew info --cask "$cask" 2>/dev/null | head -n 1 | sed 's/^[^:]*: //' || echo "Aplicación de escritorio"
}

# Crear el archivo README
cat > "$README_FILE" << 'EOF'
# 🍺 Mi Configuración de Homebrew

Este repositorio contiene la configuración y documentación de todos los paquetes instalados con Homebrew.

## 📋 Índice

- [Mantenimiento Automático](#-mantenimiento-automático)
- [Estadísticas](#-estadísticas)  
- [Fórmulas Instaladas](#-fórmulas-instaladas)
- [Aplicaciones (Casks)](#-aplicaciones-casks)
- [Comandos Útiles](#-comandos-útiles)

## 🖥️ Guía de Herramientas CLI

Para una guía detallada con ejemplos prácticos de todas las herramientas de línea de comandos, consulta: **[CLI_TOOLS.md](CLI_TOOLS.md)**

Esta guía incluye ejemplos específicos y casos de uso para cada herramienta que puedes usar desde el terminal.

## 🔧 Mantenimiento Automático

Para mantener tu sistema actualizado, ejecuta:

```bash
# Mantenimiento básico
./brew_maintenance.sh

# Mantenimiento + actualizar este README
./brew_maintenance.sh --with-readme
```

El script realiza:
1. `brew update` - Actualiza las fórmulas
2. `brew upgrade` - Actualiza los paquetes instalados  
3. `brew cleanup` - Limpia archivos antiguos

## 📊 Estadísticas

EOF

# Agregar estadísticas actuales
echo "- **Fórmulas instaladas:** $(brew list --formula | wc -l | tr -d ' ')" >> "$README_FILE"
echo "- **Aplicaciones instaladas:** $(brew list --cask | wc -l | tr -d ' ')" >> "$README_FILE"
echo "- **Última actualización:** $(date)" >> "$README_FILE"
echo "" >> "$README_FILE"

# Agregar sección de fórmulas
cat >> "$README_FILE" << 'EOF'
## 📦 Fórmulas Instaladas

Las fórmulas son herramientas de línea de comandos y bibliotecas.

| Programa | Descripción | Ejemplos de Uso |
|----------|-------------|-----------------|
EOF

# Obtener y procesar fórmulas
echo "Procesando fórmulas..."
brew list --formula | sort | while read formula; do
    description=$(get_formula_description "$formula" | cut -c1-80)
    
    # Ejemplos específicos para programas comunes
    examples=""
    case "$formula" in
        "git")
            examples="\`git status\`, \`git add .\`, \`git commit -m \"mensaje\"\`"
            ;;
        "node")
            examples="\`node --version\`, \`npm install\`, \`node app.js\`"
            ;;
        "python"*|"pyenv")
            examples="\`python --version\`, \`pip install package\`, \`python script.py\`"
            ;;
        "wget")
            examples="\`wget https://ejemplo.com/archivo.zip\`"
            ;;
        "curl")
            examples="\`curl -O https://ejemplo.com/api\`, \`curl -X POST\`"
            ;;
        "jq")
            examples="\`echo '{\"name\":\"Juan\"}' | jq .name\`"
            ;;
        "tree")
            examples="\`tree\`, \`tree -L 2\`, \`tree -I node_modules\`"
            ;;
        "htop")
            examples="\`htop\` (monitor de procesos interactivo)"
            ;;
        "ffmpeg")
            examples="\`ffmpeg -i video.mp4 output.avi\`"
            ;;
        "imagemagick")
            examples="\`convert image.jpg -resize 50% small.jpg\`"
            ;;
        "bat")
            examples="\`bat archivo.txt\` (cat con sintaxis highlight)"
            ;;
        "eza")
            examples="\`eza -la\`, \`eza --tree\` (ls mejorado)"
            ;;
        "ripgrep")
            examples="\`rg \"texto\" .\`, \`rg -i \"buscar\"\`"
            ;;
        "fzf")
            examples="\`find . | fzf\`, \`history | fzf\`"
            ;;
        "gh")
            examples="\`gh repo create\`, \`gh pr list\`, \`gh issue create\`"
            ;;
        "mas")
            examples="\`mas list\`, \`mas install 497799835\`"
            ;;
        "thefuck")
            examples="Escribe un comando mal, luego \`fuck\` para corregirlo"
            ;;
        "cowsay")
            examples="\`cowsay \"Hola mundo\"\`, \`fortune | cowsay\`"
            ;;
        "neofetch")
            examples="\`neofetch\` (muestra info del sistema con estilo)"
            ;;
        "starship")
            examples="Prompt personalizable - configurar en \`~/.config/starship.toml\`"
            ;;
        "tldr")
            examples="\`tldr git\`, \`tldr curl\` (ejemplos prácticos de comandos)"
            ;;
        "ranger")
            examples="\`ranger\` (navegador de archivos en terminal)"
            ;;
        "pandoc")
            examples="\`pandoc -f markdown -t html doc.md -o doc.html\`"
            ;;
        "zoxide")
            examples="\`z directorio\`, \`zi\` (navegación inteligente)"
            ;;
        "direnv")
            examples="Crear \`.envrc\` en proyecto, luego \`direnv allow\`"
            ;;
        "httpie")
            examples="\`http GET httpbin.org/json\`, \`http POST api.com/data\`"
            ;;
        "aria2")
            examples="\`aria2c https://ejemplo.com/archivo.zip\`"
            ;;
        "yt-dlp")
            examples="\`yt-dlp 'https://youtube.com/watch?v=VIDEO_ID'\`"
            ;;
        "csvkit")
            examples="\`csvstat data.csv\`, \`csvcut -c 1,3 data.csv\`"
            ;;
        "glow")
            examples="\`glow README.md\`, \`glow -p .\`"
            ;;
        *)
            examples="\`$formula --help\`, \`man $formula\`"
            ;;
    esac
    
    echo "| \`$formula\` | $description | $examples |" >> "$README_FILE"
done

# Agregar sección de casks
cat >> "$README_FILE" << 'EOF'

## 💻 Aplicaciones (Casks)

Las aplicaciones son programas con interfaz gráfica.

| Aplicación | Descripción | Tipo |
|------------|-------------|------|
EOF

# Procesar casks
echo "Procesando casks..."
brew list --cask | sort | while read cask; do
    description=$(get_cask_description "$cask" | cut -c1-80)
    
    # Categorizar aplicaciones
    category=""
    case "$cask" in
        *"browser"*|"brave-browser"|"google-chrome")
            category="Navegador Web"
            ;;
        "visual-studio-code"|"rstudio")
            category="Editor/IDE"
            ;;
        "discord"|"slack"|"telegram"|"whatsapp")
            category="Comunicación"
            ;;
        "obs"|"vlc")
            category="Multimedia"
            ;;
        "1password"*|"karabiner-elements"|"keyboard-maestro")
            category="Utilidades"
            ;;
        "postman"|"ngrok")
            category="Desarrollo"
            ;;
        "dropbox"|"google-drive")
            category="Almacenamiento"
            ;;
        "cleanmymac"|"alfred"|"the-unarchiver")
            category="Productividad"
            ;;
        "iterm2")
            category="Terminal"
            ;;
        "expressvpn")
            category="Seguridad/VPN"
            ;;
        "r"|"r-app")
            category="Análisis de Datos"
            ;;
        "tradingview")
            category="Finanzas"
            ;;
        "obsidian")
            category="Notas/PKM"
            ;;
        *)
            category="Aplicación"
            ;;
    esac
    
    echo "| \`$cask\` | $description | $category |" >> "$README_FILE"
done

# Agregar sección de comandos útiles
cat >> "$README_FILE" << 'EOF'

## 🚀 Comandos Útiles

### Gestión Básica
```bash
# Buscar programas
brew search nombre

# Instalar fórmula
brew install nombre

# Instalar aplicación
brew install --cask nombre

# Actualizar todo
brew update && brew upgrade

# Desinstalar
brew uninstall nombre
brew uninstall --cask nombre

# Ver información
brew info nombre
brew info --cask nombre
```

### Mantenimiento
```bash
# Limpiar archivos antiguos
brew cleanup

# Ver qué se limpiaría (sin ejecutar)
brew cleanup --dry-run

# Verificar estado del sistema
brew doctor

# Ver servicios en ejecución
brew services list

# Iniciar/detener servicio
brew services start/stop nombre
```

### Información del Sistema
```bash
# Lista de instalados
brew list
brew list --cask

# Programas desactualizados
brew outdated
brew outdated --cask

# Dependencias de un programa
brew deps nombre
brew deps --tree nombre

# Programas que dependen de algo
brew uses nombre
```

### Backup y Restauración
```bash
# Generar lista de programas instalados
brew bundle dump

# Instalar desde Brewfile
brew bundle install

# Exportar lista simple
brew list > my_brews.txt
brew list --cask > my_casks.txt
```

---

📝 **Nota:** Este README se regenera automáticamente con el script `generate_readme.sh` o ejecutando `./brew_maintenance.sh --with-readme`.

🔄 **Última actualización:** Ejecuta `./generate_readme.sh` para actualizar la fecha.
EOF

echo "✅ README.md generado exitosamente"
echo "📄 Archivo creado: $README_FILE"
echo "📊 Fórmulas documentadas: $(brew list --formula | wc -l | tr -d ' ')"
echo "💻 Casks documentados: $(brew list --cask | wc -l | tr -d ' ')"
