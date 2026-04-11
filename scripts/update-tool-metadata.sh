#!/usr/bin/env bash
# update-tool-metadata.sh - Actualiza version y fecha de herramientas usando Homebrew
# Requisitos: brew, jq

set -euo pipefail

FILE="${TOOLS_INDEX_PATH:-tools-index.json}"

today() { date -I; }

usage() {
  cat <<'EOF'
Uso: update-tool-metadata.sh [--file tools-index.json]
Actualiza .metadata.version y .metadata.lastUpdated con datos de Homebrew.

Ejemplos:
  ./scripts/update-tool-metadata.sh
  TOOLS_INDEX_PATH=data/tools.json ./scripts/update-tool-metadata.sh
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      FILE="$2"; shift 2;;
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

tmp_file() { mktemp "${TMPDIR:-/tmp}/tools.XXXXXX"; }

update_tool() {
  local name="$1"
  local version
  version=$(brew info --json=v2 "$name" 2>/dev/null | jq -r '(.formulae[0].versions.stable // .casks[0].version // empty)' || true)
  if [[ -z "$version" || "$version" == "null" ]]; then
    echo "[SKIP] No se pudo obtener versión para $name" >&2
    return
  fi
  local tmp
  tmp=$(tmp_file)
  jq --arg name "$name" --arg version "$version" --arg date "$(today)" '
    (.tools[] | select(.name == $name) | .metadata.version) = $version | 
    (.tools[] | select(.name == $name) | .metadata.lastUpdated) = $date
  ' "$FILE" > "$tmp"
  mv "$tmp" "$FILE"
  echo "[UPDATED] $name -> $version"
}

while IFS= read -r name; do
  [[ -z "$name" ]] && continue
  update_tool "$name"
done < <(jq -r '.tools[].name' "$FILE")

echo "Actualización completada: $FILE"
