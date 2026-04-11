#!/usr/bin/env bash
# verify-homebrew-tools.sh - Verifica que las herramientas del índice existan en Homebrew
# Requisitos: brew, jq

set -euo pipefail

FILE="${TOOLS_INDEX_PATH:-tools-index.json}"
STRICT=false

usage() {
  cat <<'EOF'
Uso: verify-homebrew-tools.sh [--file tools-index.json] [--strict]
  --file    Ruta al índice (default: tools-index.json)
  --strict  Falla si alguna herramienta no está disponible

Ejemplos:
  ./scripts/verify-homebrew-tools.sh
  TOOLS_INDEX_PATH=data/tools.json ./scripts/verify-homebrew-tools.sh --strict
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      FILE="$2"; shift 2;;
    --strict)
      STRICT=true; shift;;
    -h|--help)
      usage; exit 0;;
    *)
      echo "Opción no reconocida: $1" >&2
      usage; exit 1;;
  esac
done

command -v jq >/dev/null 2>&1 || { echo "jq es requerido" >&2; exit 1; }
command -v brew >/dev/null 2>&1 || { echo "Homebrew es requerido" >&2; exit 1; }

if [[ ! -f "$FILE" ]]; then
  echo "No se encontró el archivo: $FILE" >&2
  exit 1
fi

missing=()
validated=0

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  if brew info --json=v2 "$name" >/dev/null 2>&1; then
    printf "[OK] %s\n" "$name"
    ((validated++))
  else
    printf "[MISSING] %s\n" "$name"
    missing+=("$name")
  fi
done < <(jq -r '.tools[].name' "$FILE")

echo "---"
echo "Herramientas validadas: $validated"
echo "Faltantes: ${#missing[@]}"

if [[ ${#missing[@]} -gt 0 ]]; then
  printf 'Lista faltante: %s\n' "${missing[*]}"
  $STRICT && exit 1
fi

exit 0
