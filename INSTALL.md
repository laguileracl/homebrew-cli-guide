# Instrucciones de Uso

## Instalación

1. Clona o descarga este repositorio:
```bash
git clone https://github.com/laguileracl/homebrew-cli-guide.git homebrew-config
cd homebrew-config
```

2. Haz los scripts ejecutables (si no lo están ya):
```bash
chmod +x brew_maintenance.sh
chmod +x generate_readme.sh
```

> **Nota:** El mantenimiento real lo realiza el script canónico del ecosistema, ubicado en `tools/homebrew-maintenance/brew_full_upgrade.sh`. El script `brew_maintenance.sh` de esta guía es un wrapper que delega allí y agrega la opción de regenerar el README. Ver `tools/homebrew-maintenance/brew_full_upgrade.md` para todas las opciones soportadas.

## Uso

### Mantenimiento Regular

Para actualizar todo tu sistema Homebrew:
```bash
./brew_maintenance.sh
```

Para actualizar el sistema Y regenerar el README:
```bash
./brew_maintenance.sh --with-readme
```

Opciones avanzadas (se reenvían al script canónico):
```bash
./brew_maintenance.sh --verbose            # Salida detallada
./brew_maintenance.sh --log                # Guardar log en ~/.cache/brew_full_upgrade/
./brew_maintenance.sh --unpin-all          # Desanclar y reintentar upgrade
```

### Auditoría rápida del entorno

Para revisar qué herramientas tienes dentro y fuera de Homebrew:
```bash
../homebrew-maintenance/brew_audit.sh
```

### Actualizar Documentación

Si instalas nuevos programas y quieres actualizar solo el README:
```bash
./generate_readme.sh
```

### Automatización

Para ejecutar el mantenimiento automáticamente, puedes crear un cron job:
```bash
# Editar crontab
crontab -e

# Agregar línea para ejecutar cada domingo a las 10:00 AM
0 10 * * 0 /ruta/completa/al/script/brew_maintenance.sh --log

# O crear un alias en tu shell (.zshrc, .bashrc)
alias brewup='/ruta/completa/al/script/brew_maintenance.sh'
```

## Estructura de Archivos

```
homebrew-config/
├── brew_maintenance.sh    # Wrapper que delega en homebrew-maintenance/brew_full_upgrade.sh
├── generate_readme.sh     # Generador de documentación
├── README.md              # Documentación completa (auto-generada)
└── INSTALL.md             # Este archivo
```

Y en paralelo (otro repo del ecosistema):
```
tools/homebrew-maintenance/
├── brew_full_upgrade.sh   # Script canónico de mantenimiento
├── brew_full_upgrade.md   # Documentación detallada
└── brew_audit.sh          # Auditoría de herramientas dentro/fuera de brew
```

## Funcionalidades

### Wrapper de Mantenimiento (`brew_maintenance.sh`)
Reenvía todas las opciones al script canónico `brew_full_upgrade.sh`, que realiza:
- `brew update` y `brew upgrade` (fórmulas CLI)
- `brew upgrade --cask --greedy` (incluye casks con auto-updater)
- Retry inteligente de casks pendientes con clasificación de fallos:
  - `SUDO`: casks que requieren permisos de administrador
  - `CHECKSUM`: mismatch upstream que se resolverá automáticamente
  - `FALLO`: errores desconocidos
- Reinicio automático de servicios de Homebrew activos
- `brew cleanup -s` y `brew doctor`
- Eliminación de cachés con más de 30 días
- Snapshots antes/después con diff de versiones
- Resumen final con contadores y detalle de fallos
- Logging opcional con `--log`

Adicionalmente, con `--with-readme`, regenera el README de esta guía tras el upgrade.

### Generador de README (`generate_readme.sh`)
- Lista completa de fórmulas y casks instalados
- Descripción automática de cada programa
- Ejemplos de uso específicos para programas comunes
- Categorización de aplicaciones
- Estadísticas actualizadas
- Comandos útiles de Homebrew

## Personalización

### Modificar Ejemplos de Uso

Edita el archivo `generate_readme.sh` y busca la sección `case "$formula"` para agregar ejemplos específicos para tus programas favoritos.

### Cambiar Categorías de Aplicaciones

En la sección de casks, modifica la lógica de `case "$cask"` para personalizar las categorías.

### Agregar Más Información

Puedes modificar cualquiera de los scripts para incluir información adicional como:
- Enlaces a documentación oficial
- Configuraciones recomendadas
- Scripts de instalación de dependencias

## Troubleshooting

### Permisos
Si obtienes errores de permisos:
```bash
chmod +x *.sh
```

### Homebrew no encontrado
Si el script no encuentra Homebrew:
```bash
# Verificar instalación
which brew

# Instalar Homebrew si es necesario
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Problemas con el PATH
Asegúrate de que Homebrew esté en tu PATH:
```bash
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Wrapper no encuentra el script canónico
Si `brew_maintenance.sh` reporta que no encuentra `brew_full_upgrade.sh`, verifica que el directorio `tools/homebrew-maintenance/` esté presente al mismo nivel que `tools/homebrew-guide/`.

¡Disfruta de tu sistema Homebrew bien mantenido y documentado!
