#!/usr/bin/env bash
# fetch-github-stats.sh - Actualiza estrellas, forks y watchers desde GitHub
# Requisitos: gh, jq

set -euo pipefail

FILE="${TOOLS_INDEX_PATH:-tools-index.json}"

today() { date -I; }

usage() {
  cat <<'EOF'
Uso: fetch-github-stats.sh [--file tools-index.json]
Requiere GH_TOKEN configurado (gh auth login) y usa gh api repos/{owner}/{repo}.
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
command -v gh >/dev/null 2>&1 || { echo "GitHub CLI es requerido" >&2; exit 1; }

if [[ ! -f "$FILE" ]]; then
  echo "No se encontró el archivo: $FILE" >&2
  exit 1
fi

tmp_file() { mktemp "${TMPDIR:-/tmp}/tools.XXXXXX"; }

extract_repo() {
  local url="$1"
  echo "$url" | sed -E 's#https?://github.com/([^/]+/[^/]+).*#\1#'
}

update_stats() {
  local name="$1" homepage="$2"
  local repo
  repo=$(extract_repo "$homepage")
  if [[ -z "$repo" || "$repo" == "$homepage" ]]; then
    echo "[SKIP] $name no parece apuntar a GitHub" >&2
    return
  fi
  local data
  if ! data=$(gh api "repos/$repo" --jq '{stars: .stargazers_count, forks: .forks_count, watchers: .subscribers_count}'); then
    echo "[SKIP] No se pudo obtener stats para $name ($repo)" >&2
    return
  fi
  local stars forks watchers
  stars=$(echo "$data" | jq -r '.stars')
  forks=$(echo "$data" | jq -r '.forks')
  watchers=$(echo "$data" | jq -r '.watchers')
  local tmp
  tmp=$(tmp_file)
  jq --arg name "$name" \
     --argjson stars "$stars" \
     --argjson forks "$forks" \
     --argjson watchers "$watchers" \
     --arg date "$(today)" '
    (.tools[] | select(.name == $name) | .metadata.githubStars) = $stars | 
    (.tools[] | select(.name == $name) | .metadata.githubForks) = $forks | 
    (.tools[] | select(.name == $name) | .metadata.githubWatchers) = $watchers | 
    (.tools[] | select(.name == $name) | .metadata.lastUpdated) = $date
  ' "$FILE" > "$tmp"
  mv "$tmp" "$FILE"
  echo "[UPDATED] $name -> stars:$stars forks:$forks watchers:$watchers"
}

jq -c '.tools[] | {name: .name, homepage: .metadata.homepage}' "$FILE" | while read -r entry; do
  name=$(echo "$entry" | jq -r '.name')
  homepage=$(echo "$entry" | jq -r '.homepage')
  [[ -z "$homepage" || "$homepage" == "null" ]] && { echo "[SKIP] $name sin homepage" >&2; continue; }
  update_stats "$name" "$homepage"
done

echo "Actualización de métricas GitHub completada: $FILE"
