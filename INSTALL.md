# 🛠️ Instrucciones de Uso

## Instalación

1. Clona o descarga este repositorio:
```bash
git clone <tu-repo> homebrew-config
cd homebrew-config
```

2. Haz los scripts ejecutables (si no lo están ya):
```bash
chmod +x brew_maintenance.sh
chmod +x generate_readme.sh
```

## Uso

### 🔄 Mantenimiento Regular

Para actualizar todo tu sistema Homebrew:
```bash
./brew_maintenance.sh
```

Para actualizar el sistema Y regenerar el README:
```bash
./brew_maintenance.sh --with-readme
```

### 📚 Actualizar Documentación

Si instalas nuevos programas y quieres actualizar solo el README:
```bash
./generate_readme.sh
```

### ⏰ Automatización

Para ejecutar el mantenimiento automáticamente, puedes crear un cron job:
```bash
# Editar crontab
crontab -e

# Agregar línea para ejecutar cada domingo a las 10:00 AM
0 10 * * 0 /ruta/completa/al/script/brew_maintenance.sh

# O crear un alias en tu shell (.zshrc, .bashrc)
alias brewup='/ruta/completa/al/script/brew_maintenance.sh'
```

## Estructura de Archivos

```
homebrew-config/
├── brew_maintenance.sh    # Script principal de mantenimiento
├── generate_readme.sh     # Generador de documentación
├── README.md             # Documentación completa (auto-generada)
└── INSTALL.md            # Este archivo
```

## Funcionalidades

### Script de Mantenimiento (`brew_maintenance.sh`)
- ✅ Actualiza las fórmulas de Homebrew (`brew update`)
- ✅ Actualiza todos los paquetes instalados (`brew upgrade`)
- ✅ Limpia archivos antiguos y cache (`brew cleanup`)
- ✅ Muestra estadísticas del sistema
- ✅ Verifica el estado del sistema (`brew doctor`)
- ✅ Opción para regenerar README automáticamente

### Generador de README (`generate_readme.sh`)
- ✅ Lista completa de fórmulas y casks instalados
- ✅ Descripción automática de cada programa
- ✅ Ejemplos de uso específicos para programas comunes
- ✅ Categorización de aplicaciones
- ✅ Estadísticas actualizadas
- ✅ Comandos útiles de Homebrew

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

¡Disfruta de tu sistema Homebrew bien mantenido y documentado! 🎉
