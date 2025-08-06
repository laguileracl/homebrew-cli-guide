# Dockerfile para la API del CLI Guide
FROM node:18-alpine

# Metadata
LABEL maintainer="laguileracl@github.com"
LABEL description="Homebrew CLI Guide API Server"
LABEL version="1.0.0"

# Crear usuario no-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

# Directorio de trabajo
WORKDIR /app

# Instalar dependencias primero (para cache de Docker layers)
COPY api-server/package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Copiar código fuente
COPY api-server/ ./
COPY tools-index.json ./

# Cambiar ownership
RUN chown -R nextjs:nodejs /app
USER nextjs

# Exponer puerto
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) })"

# Variables de entorno
ENV NODE_ENV=production
ENV PORT=3000

# Comando por defecto
CMD ["npm", "start"]
