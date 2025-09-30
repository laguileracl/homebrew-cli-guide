# Contribuir a la Guía CLI de Homebrew

¡Gracias por tu interés en contribuir! Esta guía vive gracias a las contribuciones de la comunidad.

## 🚀 Formas de Contribuir

### 📝 Documentación
- **Nuevas herramientas**: Añadir herramientas CLI que falten
- **Mejores ejemplos**: Mejorar o añadir ejemplos prácticos
- **Casos de uso**: Documentar workflows específicos de tu industria
- **Traducciones**: Ayudar con versiones en otros idiomas

### 🔧 Código y Scripts
- **Automatización**: Scripts para tareas comunes
- **Configuraciones**: Setups optimizados para herramientas
- **Tests**: Validar que los ejemplos funcionen
- **Tooling**: Herramientas para mantener el proyecto

### 🐛 Calidad
- **Bugs**: Reportar errores en ejemplos
- **Mejoras**: Sugerir optimizaciones
- **Revisiones**: Revisar PRs de otros contribuidores
- **Testing**: Probar en diferentes sistemas

## 📋 Proceso de Contribución

### 1. Setup Local

```bash
# Fork el repositorio en GitHub
# Luego clona tu fork

git clone https://github.com/laguileracl/homebrew-cli-guide.git
cd homebrew-cli-guide

# Instala Quarto si no lo tienes
brew install quarto

# Inicia el servidor de desarrollo
quarto preview
```

### 2. Crear una Rama

```bash
# Crea una rama descriptiva
git checkout -b feature/nueva-herramienta-xyz
# o
git checkout -b fix/corregir-ejemplo-grep
# o
git checkout -b docs/workflow-data-science
```

### 3. Hacer Cambios

#### Para nuevas herramientas:
1. Añade la herramienta en el capítulo apropiado (`.qmd`)
2. Incluye descripción, instalación, ejemplos básicos y avanzados
3. Añade referencias cruzadas si es relevante

#### Para mejorar ejemplos:
1. Asegúrate que el ejemplo funcione en sistemas reales
2. Incluye contexto sobre cuándo usar el comando
3. Añade variaciones para diferentes casos de uso

#### Estructura de una entrada de herramienta:

```markdown
## nombre-herramienta - Descripción breve {#sec-nombre-herramienta}

Descripción más detallada de qué hace y por qué es útil.

### Instalación

```bash
brew install nombre-herramienta
```

### Uso básico

```bash
# Ejemplo básico
nombre-herramienta --help

# Ejemplo común
nombre-herramienta input.txt
```

### Casos avanzados

```bash
# Workflow específico
nombre-herramienta --advanced-flag | other-tool
```

### Configuración

Archivo `~/.config/herramienta/config`:

```ini
# Configuración optimizada
option1=value1
option2=value2
```

### Tips y trucos

- **Tip 1**: Descripción del tip
- **Tip 2**: Otro consejo útil

---
```

### 4. Probar Cambios

```bash
# Genera el libro para verificar que compila
quarto render

# Revisa en el navegador
quarto preview
```

### 5. Commit y Push

```bash
# Commits descriptivos
git add .
git commit -m "feat: añadir herramienta xyz con ejemplos de data science"

# Push a tu fork
git push origin feature/nueva-herramienta-xyz
```

### 6. Crear Pull Request

1. Ve a GitHub y crea un PR desde tu rama
2. Usa el template de PR (se llena automáticamente)
3. Describe qué cambiaste y por qué
4. Añade screenshots si es visual
5. Menciona issues relacionados

## 📝 Estándares de Contribución

### Estilo de Documentación

#### ✅ Buenas prácticas:
- **Ejemplos funcionales**: Todos los comandos deben funcionar
- **Contexto claro**: Explica cuándo y por qué usar cada comando
- **Progresión lógica**: De básico a avanzado
- **Referencias**: Enlaces a documentación oficial
- **Casos reales**: Ejemplos de problemas reales, no académicos

#### ❌ Evitar:
- Ejemplos que no funcionan
- Documentación incompleta
- Comandos peligrosos sin advertencias
- Duplicación innecesaria
- Jerga excesiva sin explicación

### Formato de Código

```bash
# ✅ Bueno: Comentarios claros
# Buscar archivos modificados en las últimas 24 horas
find . -type f -mtime -1

# ✅ Bueno: Explicar flags no obvios
# -type f: solo archivos (no directorios)
# -mtime -1: modificados en último día
find . -type f -mtime -1

# ❌ Malo: Sin contexto
find . -type f -mtime -1
```

### Nombres de Branches

- `feature/nombre-herramienta` - Nueva herramienta
- `fix/corregir-problema` - Corrección de bug
- `docs/mejorar-seccion` - Mejora de documentación
- `refactor/reorganizar-capitulo` - Reorganización

### Mensajes de Commit

Usa [Conventional Commits](https://www.conventionalcommits.org/):

```bash
feat: añadir herramienta ripgrep con ejemplos avanzados
fix: corregir ejemplo de jq que no funcionaba
docs: mejorar explicación de configuración de tmux
refactor: reorganizar capítulo de herramientas de red
```

## 🏷️ Labels de Issues

- `good first issue` - Perfecto para nuevos contribuidores
- `help wanted` - Necesitamos ayuda comunitaria
- `documentation` - Mejoras de documentación
- `bug` - Algo no funciona
- `enhancement` - Nueva funcionalidad
- `question` - Pregunta de la comunidad

## 🎯 Areas que Necesitan Ayuda

### 🔥 Prioridad Alta
- [ ] Tests automatizados para ejemplos
- [ ] Más workflows de data science
- [ ] Herramientas de seguridad/pentesting
- [ ] Configuraciones para shells menos comunes

### 📈 Prioridad Media
- [ ] Traducción al inglés
- [ ] Videos tutoriales
- [ ] Integración con IDEs
- [ ] Benchmarks de rendimiento

### 💡 Ideas Futuras
- [ ] Plugin para VS Code
- [ ] CLI para buscar en la guía
- [ ] Versión mobile-friendly
- [ ] Comunidad en Discord

## 🆘 ¿Necesitas Ayuda?

- 💬 **Discussions**: Para preguntas generales
- 🐛 **Issues**: Para reportar problemas
- 📧 **Email**: Usa el sistema de Issues para contactar a los mantenedores: https://github.com/laguileracl/homebrew-cli-guide/issues
- 🐦 **Twitter**: [@homebrew_guide](https://twitter.com/homebrew_guide)

## 🙏 Reconocimientos

Todos los contribuidores aparecen en:
- [Contributors](https://github.com/laguileracl/homebrew-cli-guide/graphs/contributors)
- [Página de reconocimientos](https://laguileracl.github.io/homebrew-cli-guide/contributors.html)
- [Archivo AUTHORS](AUTHORS.md)

¡Tu contribución, sin importar el tamaño, es valiosa y será reconocida! 🎉
