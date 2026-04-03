FROM nginx:alpine

# Remover config padrão
RUN rm /etc/nginx/conf.d/default.conf

# Copiar config customizado
COPY nginx.conf /etc/nginx/conf.d/fiscio.conf

# Copiar arquivos estáticos (ícones de app ficam em icons/system, servidos pelo backend via proxy)
COPY index.html manifest.json firebase-messaging-sw.js \
     /usr/share/nginx/html/

EXPOSE 80
