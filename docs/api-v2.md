# API v2 (propuesta)

## Objetivo
API estructurada para consultar herramientas, métricas y workflows desde integraciones externas.

## Endpoints

- `GET /api/v2/tools` — Lista paginada con filtros (`category`, `difficulty`, `tag`, `limit`, `offset`, `sort`)
- `GET /api/v2/tools/:name` — Detalle de herramienta con relacionados
- `GET /api/v2/tools/:name/examples` — Ejemplos y recetas asociadas
- `GET /api/v2/tools/:name/changelog` — Cambios de versión y notas
- `GET /api/v2/compare?tools=rg,grep` — Comparación lado a lado
- `GET /api/v2/workflow/:name` — Workflows predefinidos
- `GET /api/v2/trending` — Herramientas en tendencia (estrellas, instalaciones)
- `GET /api/v2/search?q=term` — Búsqueda con ranking de relevancia
- `POST /api/v2/feedback` — Feedback y sugerencias de comunidad

## Esquema de herramienta

```json
{
  "name": "ripgrep",
  "displayName": "ripgrep (rg)",
  "category": "busqueda",
  "description": {
    "short": "Búsqueda de texto ultrarrápida",
    "long": "Recorre recursivamente directorios con regex y respeta .gitignore."
  },
  "installation": {
    "homebrew": "brew install ripgrep"
  },
  "metadata": {
    "version": "14.1.0",
    "lastUpdated": "2026-01-01",
    "githubStars": 48000,
    "githubForks": 2200,
    "githubWatchers": 900,
    "homepage": "https://github.com/BurntSushi/ripgrep",
    "license": "MIT",
    "maintainer": "Andrew Gallant"
  },
  "performance": {
    "benchmark": "10x grep en repos medianos",
    "memoryUsage": "low",
    "cpuIntensive": false
  },
  "examples": ["rg error src", "rg --files --hidden"],
  "alternatives": ["grep", "ag"],
  "relatedTools": ["fd", "fzf"],
  "tags": ["search", "regex", "rust"],
  "difficulty": "beginner",
  "useCases": ["code-search", "log-analysis"],
  "platforms": ["macos", "linux", "windows"],
  "verified": true,
  "lastVerified": "2026-01-01"
}
```

## Respuestas de ejemplo

### Lista paginada
```json
{
  "tools": [ { "name": "fd", "category": "busqueda", "metadata": { "version": "9.0.0" } } ],
  "pagination": { "total": 200, "limit": 50, "offset": 0, "hasMore": true }
}
```

### Comparación
```json
{
  "left": { "name": "ripgrep", "benchmark": "10x grep" },
  "right": { "name": "grep", "benchmark": "1x" },
  "summary": "ripgrep es más rápido y respeta .gitignore"
}
```

## Consideraciones
- Todas las respuestas deben ser cacheables (ETag) y versionadas.
- Paginación con `limit` y `offset`; máximo recomendado 100.
- Filtrado validando categorías conocidas para evitar abuso.
- Respuestas en JSON UTF-8; errores estructurados con `code`, `message`, `details`.
