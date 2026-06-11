#!/bin/sh
# Build do frontend: concatena os módulos JS e copia o CSS.
# Com MINIFY=1 (usado no Docker), minifica via esbuild e gera nomes com hash
# para cache imutável, reescrevendo as referências no index.html de dist/.
set -e
mkdir -p dist

cat src/js/01-core.js \
    src/js/02-home.js \
    src/js/03-expenses.js \
    src/js/04-admin.js \
    src/js/05-targets.js \
    src/js/06-charts.js \
    src/js/07-sidebar.js \
    src/js/08-agent-firebase.js \
    src/js/09-pluggy.js \
    src/js/10-swipe.js \
    src/js/11-fab-audit.js \
    src/js/12-pwa-banner.js \
    > dist/app.js

cp src/css/app.css dist/app.css

if [ "$MINIFY" = "1" ]; then
    npx -y esbuild@0.24.2 dist/app.js  --minify --target=es2020 --outfile=dist/app.min.js
    npx -y esbuild@0.24.2 dist/app.css --minify --outfile=dist/app.min.css
    npx -y tailwindcss@3.4.17 -c tailwind.config.js -i tailwind.input.css -o dist/tailwind.css --minify

    JS_HASH=$(md5sum dist/app.min.js   | cut -c1-8)
    CSS_HASH=$(md5sum dist/app.min.css | cut -c1-8)
    TW_HASH=$(md5sum dist/tailwind.css | cut -c1-8)

    mv dist/app.min.js    "dist/app.${JS_HASH}.js"
    mv dist/app.min.css   "dist/app.${CSS_HASH}.css"
    mv dist/tailwind.css  "dist/tailwind.${TW_HASH}.css"
    rm dist/app.js dist/app.css

    sed -e "s|/app.js|/app.${JS_HASH}.js|" \
        -e "s|/app.css|/app.${CSS_HASH}.css|" \
        -e "s|/tailwind.css|/tailwind.${TW_HASH}.css|" \
        index.html > dist/index.html

    echo "Build minificado: app.${JS_HASH}.js, app.${CSS_HASH}.css, tailwind.${TW_HASH}.css"
else
    echo "Build dev: dist/app.js e dist/app.css (sem minificação)"
fi
