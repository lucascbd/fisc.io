FROM nginx:alpine

# Remover config padrão
RUN rm /etc/nginx/conf.d/default.conf

# Copiar config customizado
COPY nginx.conf /etc/nginx/conf.d/fiscio.conf

# Copiar arquivos estáticos
COPY index.html manifest.json firebase-messaging-sw.js \
     icon-32.png icon-192.png icon-512.png \
     pix-48.png cartao-48.png vale-48.png \
     /usr/share/nginx/html/

EXPOSE 80
