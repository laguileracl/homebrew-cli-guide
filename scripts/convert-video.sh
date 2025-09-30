#!/usr/bin/env bash
set -euo pipefail

# scripts/convert-video.sh
# Convierte un archivo de vídeo a MP4 (H.264 + AAC) optimizado para web.
# Uso: ./scripts/convert-video.sh input.ext output.mp4

if [ "$#" -lt 2 ]; then
  echo "Uso: $0 input_video output_video.mp4" >&2
  exit 1
fi

INPUT="$1"
OUTPUT="$2"

if ! command -v ffmpeg >/dev/null 2>&1; then
  echo "ERROR: ffmpeg no está instalado. Instala con: brew install ffmpeg" >&2
  exit 2
fi

# Conversión recomendada: H.264 para vídeo y AAC para audio
ffmpeg -i "$INPUT" -c:v libx264 -preset slow -crf 23 -c:a aac -b:a 128k -movflags +faststart "$OUTPUT"

echo "Conversión completada: $OUTPUT"