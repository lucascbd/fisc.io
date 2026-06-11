FROM node:22-alpine AS build
WORKDIR /build
COPY src/ src/
COPY build.sh tailwind.config.js tailwind.input.css index.html ./
RUN MINIFY=1 sh build.sh

FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx.conf /etc/nginx/conf.d/fiscio.conf
COPY manifest.json firebase-messaging-sw.js \
     icon-32.png icon-192.png icon-512.png \
     /usr/share/nginx/html/
COPY --from=build /build/dist/ /usr/share/nginx/html/
EXPOSE 80
