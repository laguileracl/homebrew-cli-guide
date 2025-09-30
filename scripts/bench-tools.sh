#!/usr/bin/env bash
set -euo pipefail

# scripts/bench-tools.sh
# Usa hyperfine para comparar comandos similares y generar un pequeño reporte.
# Ejemplo: ./scripts/bench-tools.sh "curl -s https://example.com" "httpx -silent https://example.com"

if [ "$#" -lt 2 ]; then
  echo "Uso: $0 <comando1> <comando2> [<comando3> ...]" >&2
  exit 1
fi

if ! command -v hyperfine >/dev/null 2>&1; then
  echo "Instala hyperfine: brew install hyperfine" >&2
  exit 2
fi

CMD_ARGS=("$@")

# Ejecutar hyperfine con los comandos pasados
hyperfine "${CMD_ARGS[@]}" --export-json bench-results.json

echo "Benchmark finalizado — resultados en bench-results.json"