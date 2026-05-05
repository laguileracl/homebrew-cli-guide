#!/usr/bin/env bash
# ============================================
# Wrapper de mantenimiento de Homebrew
# ============================================
#
# Este script delega el mantenimiento al script canónico del ecosistema:
#   tools/homebrew-maintenance/brew_full_upgrade.sh
#
# Mantiene la opción --with-readme para regenerar el README de esta guía
# después del upgrade.
#
# Uso:
#   ./brew_maintenance.sh                       # Mantenimiento completo
#   ./brew_maintenance.sh --with-readme         # Mantenimiento + regenerar README
#   ./brew_maintenance.sh --verbose             # Salida detallada de brew
#   ./brew_maintenance.sh --log                 # Guardar log en ~/.cache/brew_full_upgrade/
#   ./brew_maintenance.sh --unpin-all           # Desanclar y reintentar upgrade
#
# Las opciones --verbose, --log y --unpin-all se reenvían al script canónico.
# Ver tools/homebrew-maintenance/brew_full_upgrade.md para detalles.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CANONICAL_SCRIPT="${SCRIPT_DIR}/../homebrew-maintenance/brew_full_upgrade.sh"

if [[ ! -x "$CANONICAL_SCRIPT" ]]; then
  echo "ERROR: No se encontró el script canónico en:" >&2
  echo "  $CANONICAL_SCRIPT" >&2
  echo "Verifica que el repositorio tools/homebrew-maintenance/ esté disponible." >&2
  exit 1
fi

WITH_README=false
PASSTHROUGH_ARGS=()

for arg in "$@"; do
  case "$arg" in
    --with-readme)
      WITH_README=true
      ;;
    *)
      PASSTHROUGH_ARGS+=("$arg")
      ;;
  esac
done

"$CANONICAL_SCRIPT" "${PASSTHROUGH_ARGS[@]}"

if $WITH_README; then
  printf '\n==> Regenerando README.md...\n'
  if [[ -x "${SCRIPT_DIR}/generate_readme.sh" ]]; then
    (cd "$SCRIPT_DIR" && ./generate_readme.sh)
    echo "README.md regenerado."
  else
    echo "WARNING: generate_readme.sh no encontrado o no ejecutable." >&2
  fi
fi
