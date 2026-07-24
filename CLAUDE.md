# Homebrew Guide — libro Quarto de herramientas CLI

Guía práctica de herramientas CLI instalables con Homebrew, publicada como libro
Quarto. **Es el único repo público del ecosistema** (GitHub Pages, releases y CI):
todo lo que entre acá es visible para cualquiera.

Repo: `github.com/laguileracl/homebrew-cli-guide` · Sitio: `laguileracl.github.io/homebrew-cli-guide`

## Estructura

| Ruta | Contenido |
|---|---|
| `*.qmd` | Capítulos del libro (Quarto). |
| `_quarto.yml` | Configuración del libro: capítulos, formato, tema. |
| `build-book.sh` | Compila el libro a `_book/`. |
| `brew_maintenance.sh` | **Wrapper**: delega en `tools/homebrew-maintenance/`. |
| `api-server/` | Servidor de apoyo para la versión interactiva. |
| `.github/workflows/` | CI, verificación de herramientas y publicación en Pages. |

## El wrapper no implementa nada

`brew_maintenance.sh` existe solo para agregar `--with-readme` (regenerar el README
de la guía después del upgrade). Todo lo demás lo reenvía a
`tools/homebrew-maintenance/brew_full_upgrade.sh`, que es el script canónico.

```bash
./brew_maintenance.sh                 # mantenimiento completo
./brew_maintenance.sh --with-readme   # además regenera el README de la guía
```

Si hay que cambiar el comportamiento del upgrade, se cambia en `homebrew-maintenance`,
**no acá**.

## Reglas

- **Repo público:** nada de rutas locales, nombres de clientes, RUTs ni datos del
  resto del ecosistema. Es la excepción a la privacidad por defecto.
- El libro se compila con `build-book.sh`; `_book/` es salida generada.
- Nada de `Co-Authored-By` en commits (regla del ecosistema).
