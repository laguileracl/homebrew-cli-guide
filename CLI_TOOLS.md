# 🖥️ Herramientas de Terminal - Guía Práctica

Esta guía se enfoca exclusivamente en las herramientas de línea de comandos instaladas con Homebrew que puedes usar directamente desde el terminal.

## 📋 Índice

- [Navegación y Exploración](#-navegación-y-exploración)
- [Gestión de Archivos](#-gestión-de-archivos)
- [Búsqueda y Filtrado](#-búsqueda-y-filtrado)
- [Desarrollo y Git](#-desarrollo-y-git)
- [Multimedia](#-multimedia)
- [Red y Descargas](#-red-y-descargas)
- [Monitoreo del Sistema](#-monitoreo-del-sistema)
- [Texto y Documentos](#-texto-y-documentos)
- [Utilidades Diversas](#-utilidades-diversas)

---

## 🧭 Navegación y Exploración

### `eza` - Listado de archivos mejorado
Reemplazo moderno de `ls` con colores y mejor formato.

```bash
# Listado básico con iconos y colores
eza

# Listado detallado como 'ls -la'
eza -la

# Vista en árbol
eza --tree

# Limitar profundidad del árbol
eza --tree --level=2

# Mostrar solo directorios
eza -D

# Ordenar por tamaño
eza -la --sort=size

# Mostrar información de git
eza -la --git
```

### `tree` - Estructura de directorios
Muestra la estructura de carpetas en formato árbol.

```bash
# Árbol básico del directorio actual
tree

# Limitar a 2 niveles de profundidad
tree -L 2

# Ignorar node_modules y .git
tree -I 'node_modules|.git'

# Mostrar archivos ocultos
tree -a

# Solo directorios
tree -d

# Generar HTML
tree -H . -o tree.html
```

### `ranger` - Navegador de archivos en terminal
Navegador visual de archivos con vista previa.

```bash
# Abrir ranger
ranger

# Comandos dentro de ranger:
# h, j, k, l - navegación (como vim)
# Enter - abrir archivo/directorio
# q - salir
# S - abrir shell en directorio actual
# r - abrir con aplicación
# zh - mostrar archivos ocultos
```

### `zoxide` - Navegación inteligente
Comando `cd` inteligente que recuerda directorios frecuentes.

```bash
# Después de navegar varias veces a ~/Projects/myapp
# Solo necesitas:
z myapp

# Navegación interactiva
zi

# Agregar directorio manualmente
zoxide add /ruta/al/directorio

# Ver estadísticas
zoxide query --stats
```

---

## 📁 Gestión de Archivos

### `rename` / `renameutils` - Renombrado masivo
Herramientas para renombrar múltiples archivos.

```bash
# Renombrar archivos con patrón
rename 's/\.jpeg$/\.jpg/' *.jpeg

# Cambiar espacios por guiones bajos
rename 's/ /_/g' *.txt

# Cambiar a minúsculas
rename 'y/A-Z/a-z/' *.TXT

# Con mmv (más visual)
mmv '*.jpeg' '*.jpg'
```

### `rsync` (via coreutils) - Sincronización de archivos
Copia y sincronización avanzada de archivos.

```bash
# Copia básica con progreso
rsync -avh --progress source/ destination/

# Sincronizar eliminando archivos extra
rsync -avh --delete source/ destination/

# Copia por SSH
rsync -avh file.txt user@server:/path/

# Excluir archivos
rsync -avh --exclude='*.log' source/ dest/
```

---

## 🔍 Búsqueda y Filtrado

### `ripgrep` (rg) - Búsqueda ultrarrápida
Herramienta de búsqueda más rápida que grep.

```bash
# Buscar texto en archivos
rg "función"

# Buscar ignorando mayúsculas
rg -i "error"

# Buscar solo en archivos .js
rg -t js "console.log"

# Buscar excluyendo directorios
rg "texto" --ignore-dir node_modules

# Mostrar líneas antes/después del match
rg -A 3 -B 2 "error"

# Buscar y reemplazar (vista previa)
rg "old_text" --replace "new_text"

# Contar matches
rg -c "import"
```

### `fzf` - Buscador difuso interactivo
Filtro interactivo para cualquier lista.

```bash
# Buscar archivos
find . -type f | fzf

# Buscar en historial de comandos
history | fzf

# Buscar procesos y matar
ps aux | fzf | awk '{print $2}' | xargs kill

# Buscar y editar archivo
vim $(find . -name "*.py" | fzf)

# Buscar en git commits
git log --oneline | fzf

# Variables de entorno útiles:
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_DEFAULT_OPTS='--height 40% --reverse'
```

### `jq` - Procesador JSON
Manipula y consulta archivos JSON desde terminal.

```bash
# Pretty print JSON
curl -s api.github.com/users/octocat | jq .

# Extraer campo específico
echo '{"name":"Juan","age":30}' | jq .name

# Filtrar arrays
curl -s api.github.com/users/octocat/repos | jq '.[].name'

# Filtros complejos
jq '.users[] | select(.age > 25) | .name' users.json

# Modificar JSON
jq '.name = "Nuevo Nombre"' data.json

# Convertir a CSV
jq -r '.[] | [.name, .age] | @csv' data.json
```

---

## 💻 Desarrollo y Git

### `git` - Control de versiones
Sistema de control de versiones distribuido.

```bash
# Configuración inicial
git config --global user.name "Tu Nombre"
git config --global user.email "tu@email.com"

# Comandos básicos
git status
git add .
git commit -m "Mensaje del commit"
git push origin main

# Branches
git branch nueva-feature
git checkout nueva-feature
git checkout -b otra-feature

# Ver historial
git log --oneline --graph
git log --author="Tu Nombre"

# Revertir cambios
git checkout -- archivo.txt
git reset HEAD~1
git revert abc123

# Stash (guardar cambios temporalmente)
git stash
git stash pop
git stash list
```

### `gh` - GitHub CLI
Herramienta oficial de GitHub para terminal.

```bash
# Autenticación
gh auth login

# Repositorios
gh repo create mi-proyecto
gh repo clone usuario/repo
gh repo list

# Pull Requests
gh pr create --title "Nueva feature" --body "Descripción"
gh pr list
gh pr view 123
gh pr merge 123

# Issues
gh issue create --title "Bug encontrado"
gh issue list
gh issue close 456

# Releases
gh release create v1.0.0 --notes "Primera versión"
```

### `node` - JavaScript runtime
Ejecutar JavaScript fuera del navegador.

```bash
# Verificar versión
node --version

# Ejecutar archivo
node app.js

# REPL interactivo
node

# Ejecutar código directo
node -e "console.log('Hola mundo')"

# Con npm
npm init
npm install express
npm run dev
npm test
```

---

## 🎵 Multimedia

### `ffmpeg` - Procesamiento de video/audio
Herramienta todopoderosa para multimedia.

```bash
# Convertir video
ffmpeg -i input.mov output.mp4

# Cambiar resolución
ffmpeg -i input.mp4 -vf scale=1280:720 output.mp4

# Extraer audio
ffmpeg -i video.mp4 -vn audio.mp3

# Cortar video (desde segundo 30, duración 60s)
ffmpeg -i input.mp4 -ss 30 -t 60 output.mp4

# Comprimir video
ffmpeg -i input.mp4 -crf 28 compressed.mp4

# Unir videos
ffmpeg -f concat -i lista.txt -c copy output.mp4
# donde lista.txt contiene:
# file 'video1.mp4'
# file 'video2.mp4'

# GIF desde video
ffmpeg -i input.mp4 -vf "fps=10,scale=320:-1" output.gif
```

### `yt-dlp` - Descargar videos de YouTube
Descargador de videos de múltiples sitios.

```bash
# Descargar video
yt-dlp "https://youtube.com/watch?v=VIDEO_ID"

# Solo audio en MP3
yt-dlp -x --audio-format mp3 "URL"

# Calidad específica
yt-dlp -f "best[height<=720]" "URL"

# Lista de reproducción
yt-dlp "https://youtube.com/playlist?list=PLAYLIST_ID"

# Ver formatos disponibles
yt-dlp -F "URL"

# Con subtítulos
yt-dlp --write-subs --sub-lang es "URL"
```

### `imagemagick` - Manipulación de imágenes
Suite completa para editar imágenes desde terminal.

```bash
# Redimensionar imagen
convert image.jpg -resize 50% small.jpg
convert image.jpg -resize 800x600 resized.jpg

# Convertir formato
convert image.png image.jpg

# Rotar imagen
convert image.jpg -rotate 90 rotated.jpg

# Agregar texto
convert image.jpg -pointsize 30 -annotate +50+100 "Texto" output.jpg

# Crear thumbnail
convert image.jpg -thumbnail 150x150 thumb.jpg

# Procesar múltiples imágenes
mogrify -resize 50% *.jpg

# Crear GIF animado
convert -delay 100 *.jpg animation.gif
```

---

## 🌐 Red y Descargas

### `curl` - Transferencia de datos
Herramienta para transferir datos hacia/desde servidores.

```bash
# GET básico
curl https://api.github.com/users/octocat

# Guardar en archivo
curl -o archivo.html https://example.com

# Seguir redirects
curl -L https://git.io/shortened-url

# POST con datos JSON
curl -X POST -H "Content-Type: application/json" \
     -d '{"name":"Juan"}' https://api.example.com/users

# Subir archivo
curl -X POST -F "file=@documento.pdf" https://upload.example.com

# Headers personalizados
curl -H "Authorization: Bearer token" https://api.example.com

# Ver headers de respuesta
curl -I https://google.com

# Medir tiempo de respuesta
curl -w "@curl-format.txt" -o /dev/null -s https://example.com
```

### `wget` - Descargador de archivos
Descargador no interactivo para web.

```bash
# Descargar archivo
wget https://example.com/archivo.zip

# Descargar sitio completo
wget -r -p -k https://example.com

# Continuar descarga interrumpida
wget -c https://example.com/archivo-grande.zip

# Descargar en background
wget -b https://example.com/archivo.zip

# Limitar velocidad
wget --limit-rate=200k https://example.com/archivo.zip

# User agent personalizado
wget --user-agent="Mi Bot 1.0" https://example.com
```

### `aria2` - Descargador avanzado
Descargador multihilo y multi-protocolo.

```bash
# Descarga básica
aria2c https://example.com/archivo.zip

# Múltiples conexiones
aria2c -x 8 https://example.com/archivo.zip

# Torrents
aria2c archivo.torrent

# Múltiples URLs
aria2c -i urls.txt

# Continuar descargas
aria2c -c https://example.com/archivo.zip
```

### `httpie` - Cliente HTTP amigable
Alternativa más amigable a curl.

```bash
# GET simple
http GET httpbin.org/json

# POST con JSON
http POST httpbin.org/post name=Juan age:=30

# Headers personalizados
http GET example.com Authorization:"Bearer token"

# Subir archivo
http --form POST httpbin.org/post file@documento.pdf

# Query parameters
http GET httpbin.org/get search=="python tutorial"

# Seguir redirects
http --follow GET httpbin.org/redirect/3
```

---

## 📊 Monitoreo del Sistema

### `htop` - Monitor de procesos interactivo
Versión mejorada de `top` con interfaz visual.

```bash
# Ejecutar htop
htop

# Comandos dentro de htop:
# F1 - Ayuda
# F2 - Setup/configuración
# F3 - Buscar proceso
# F4 - Filtrar
# F5 - Vista de árbol
# F6 - Ordenar por columna
# F9 - Matar proceso
# F10 - Salir
# Space - Marcar proceso
# U - Mostrar solo procesos de un usuario
```

### `neofetch` - Información del sistema
Muestra información del sistema con estilo.

```bash
# Mostrar info básica
neofetch

# Solo distro y kernel
neofetch --disable packages shell resolution de wm theme icons cursor

# Personalizar logo
neofetch --ascii_distro arch

# Guardar en archivo
neofetch > system-info.txt
```

---

## 📝 Texto y Documentos

### `bat` - Visualizador de texto con sintaxis
Reemplazo de `cat` con resaltado de sintaxis.

```bash
# Ver archivo con sintaxis highlight
bat archivo.py

# Ver múltiples archivos
bat *.js

# Mostrar números de línea
bat -n archivo.txt

# Ver solo líneas específicas
bat -r 10:20 archivo.txt

# Tema diferente
bat --theme="Monokai Extended" archivo.py

# Como pager (como less)
bat --paging=always archivo-largo.txt
```

### `pandoc` - Conversor universal de documentos
Convierte entre múltiples formatos de documentos.

```bash
# Markdown a HTML
pandoc -f markdown -t html documento.md -o documento.html

# Markdown a PDF (requiere LaTeX)
pandoc documento.md -o documento.pdf

# HTML a Markdown
pandoc -f html -t markdown pagina.html -o pagina.md

# Con CSS personalizado
pandoc -c styles.css documento.md -o documento.html

# Múltiples archivos
pandoc cap1.md cap2.md cap3.md -o libro.pdf

# Con tabla de contenidos
pandoc --toc documento.md -o documento.html
```

### `glow` - Renderizador de Markdown
Visualiza archivos Markdown con estilo en terminal.

```bash
# Ver archivo Markdown
glow README.md

# Buscar y ver archivos .md en directorio
glow .

# Modo pager
glow -p README.md

# Diferente estilo
glow -s dark README.md

# Ancho específico
glow -w 100 README.md
```

---

## 🛠️ Utilidades Diversas

### `tldr` - Ejemplos prácticos de comandos
Páginas de manual simplificadas con ejemplos.

```bash
# Ver ejemplos de un comando
tldr git
tldr curl
tldr ffmpeg

# Actualizar base de datos
tldr --update

# Buscar comando
tldr --search "compress"

# Diferente plataforma
tldr -p linux tar
```

### `thefuck` - Corrector de comandos
Corrige automáticamente comandos mal escritos.

```bash
# Después de un comando mal escrito:
$ gut push
git: 'gut' is not a git command

$ fuck
git push [enter/↑/↓/ctrl+c]
```

### `cowsay` - Vacas que hablan
Genera arte ASCII divertido con mensajes.

```bash
# Mensaje básico
cowsay "Hola mundo"

# Diferente animal
cowsay -f dragon "Soy un dragón"

# Listar animales disponibles
cowsay -l

# Combinar con fortune (si está instalado)
fortune | cowsay

# Diferentes expresiones
cowsay -b "Ojos de Borg"
cowsay -d "Muerto"
cowsay -g "Codicioso"
cowsay -s "Stoned"
cowsay -t "Cansado"
cowsay -w "Cableado"
cowsay -y "Joven"
```

### `direnv` - Variables de entorno por directorio
Carga automáticamente variables de entorno al entrar a directorios.

```bash
# Crear archivo .envrc en tu proyecto
echo 'export DATABASE_URL="postgres://localhost/mydb"' > .envrc

# Permitir el archivo
direnv allow

# Al entrar al directorio, las variables se cargan automáticamente
# Al salir, se descargan

# Ver variables cargadas
direnv status

# Recargar configuración
direnv reload
```

### `starship` - Prompt personalizable
Prompt de terminal minimalista y rápido.

```bash
# El prompt se activa automáticamente después de la instalación
# Configurar en ~/.config/starship.toml

# Ejemplo de configuración básica:
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[git_branch]
symbol = "🌱 "

[nodejs]
symbol = "⬢ "

# Presets disponibles
starship preset nerd-font-symbols > ~/.config/starship.toml
```

---

## 🔗 Combinaciones Útiles

### Pipelines Poderosos

```bash
# Buscar archivos grandes
find . -type f -exec du -h {} + | sort -rh | head -10

# Procesos que más CPU usan
ps aux | sort -nrk 3,3 | head -5

# Buscar texto en archivos y abrir en editor
rg -l "TODO" | fzf | xargs code

# Backup rápido con fecha
tar -czf "backup-$(date +%Y%m%d).tar.gz" directorio/

# Monitorear logs en tiempo real
tail -f /var/log/app.log | rg "ERROR"

# Convertir todas las imágenes PNG a JPG
find . -name "*.png" -exec sh -c 'convert "$1" "${1%.png}.jpg"' _ {} \;
```

---

💡 **Tip**: Muchas de estas herramientas se pueden combinar con pipes (`|`) para crear flujos de trabajo potentes. Experimenta combinando diferentes comandos para automatizar tareas complejas.

🔧 **Configuración**: La mayoría de estas herramientas permiten configuración personalizada. Busca archivos de configuración en `~/.config/` o archivos dotfiles como `~/.zshrc`.

📚 **Aprende más**: Usa `man comando` o `comando --help` para documentación completa, y `tldr comando` para ejemplos rápidos.
