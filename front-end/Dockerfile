# Multi-stage build para front-end otimizado
FROM nginx:alpine as production

# Metadados da imagem
LABEL maintainer="Greg Lixandrão <contato@greglixandrao.com>"
LABEL description="Frontend da aplicação Busca CEP"
LABEL version="1.0.0"

# Instalar dependências necessárias
RUN apk add --no-cache \
    curl \
    && rm -rf /var/cache/apk/*

# Criar usuário não-root
RUN addgroup -g 1001 -S appgroup && \
    adduser -S appuser -u 1001 -G appgroup

# Remover configuração padrão do Nginx
RUN rm /etc/nginx/conf.d/default.conf

# Copiar configuração customizada do Nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY default.conf /etc/nginx/conf.d/default.conf

# Copiar arquivos do front-end
COPY . /usr/share/nginx/html/

# Ajustar permissões
RUN chown -R appuser:appgroup /usr/share/nginx/html/ && \
    chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid

# Criar diretórios necessários com permissões corretas
RUN mkdir -p /var/cache/nginx/client_temp \
    /var/cache/nginx/proxy_temp \
    /var/cache/nginx/fastcgi_temp \
    /var/cache/nginx/uwsgi_temp \
    /var/cache/nginx/scgi_temp && \
    chown -R appuser:appgroup /var/cache/nginx

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/ || exit 1

# Expor porta
EXPOSE 3000

# Trocar para usuário não-root
USER appuser

# Comando de inicialização
CMD ["nginx", "-g", "daemon off;"]
