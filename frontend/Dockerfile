FROM node:22-alpine AS build
WORKDIR /build
COPY src/ src/
COPY build.sh .
RUN sh build.sh

FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/fiscio.conf
COPY index.html manifest.json firebase-messaging-sw.js \
     icon-32.png icon-192.png icon-512.png \
     /usr/share/nginx/html/
COPY --from=build /build/dist/app.js  /usr/share/nginx/html/app.js
COPY --from=build /build/dist/app.css /usr/share/nginx/html/app.css
EXPOSE 80
