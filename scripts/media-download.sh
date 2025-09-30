#!/usr/bin/env bash
set -euo pipefail

# scripts/media-download.sh
# Descarga responsable de vídeos usando yt-dlp + ffmpeg (opcional).
# REQUISITO: instalar 'yt-dlp' y 'ffmpeg' (brew install yt-dlp ffmpeg)

usage(){
  cat <<EOF
Uso: $0 URL [--output OUTPUT] [--allow-download]

Este script muestra el comando seguro para descargar un vídeo con yt-dlp.
Por motivos legales solo ejecutará la descarga si pasas --allow-download y
si confirmas explícitamente que tienes derecho a descargar el contenido.

Opciones:
  --output OUTPUT     Ruta de salida (por defecto: "%(title)s.%(ext)s")
  --allow-download    Ejecuta la descarga (si no se pasa, el script solo imprime el comando)

Advertencia legal: descarga únicamente contenidos que poseas, que estén
bajo licencias que lo permitan o para los que tengas permiso explícito.
El autor de este proyecto no se responsabiliza del uso indebido.
EOF
}

if [ $# -lt 1 ]; then
  usage
  exit 1
fi

URL="$1"
shift || true
OUTPUT="%(title)s.%(ext)s"
ALLOW="false"

while [ $# -gt 0 ]; do
  case "$1" in
    --output) OUTPUT="$2"; shift 2;;
    --allow-download) ALLOW="true"; shift;;
    -h|--help) usage; exit 0;;
    *) echo "Parámetro desconocido: $1"; usage; exit 2;;
  esac
done

if ! command -v yt-dlp >/dev/null 2>&1; then
  echo "ERROR: yt-dlp no está instalado. Instala con: brew install yt-dlp" >&2
  exit 3
fi

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "WARNING: ffmpeg no está instalado. Para conversiones instala: brew install ffmpeg" >&2
fi

CMD=("yt-dlp" "-f" "bestaudio[ext=m4a]+bestaudio[ext=m4a]/bestaudio/best" "-o" "$OUTPUT" "$URL")

echo "Comando sugerido:"
printf ' %q' "${CMD[@]}"
printf '\n\n'

if [ "$ALLOW" != "true" ]; then
  echo "No se ejecutará la descarga. Pasa --allow-download y confirma los derechos sobre el contenido para ejecutar." 
  exit 0
fi

# Confirmación explícita antes de ejecutar
read -p "Confirmas que tienes los derechos para descargar este contenido? (type YES): " CONF
if [ "$CONF" != "YES" ]; then
  echo "Confirmación negativa. Abortando."; exit 5
fi

# Ejecutar la descarga
echo "Ejecutando descarga..."
"${CMD[@]}"

echo "Descarga finalizada. Revisa la salida y usa ffmpeg si quieres convertir/optimizar."