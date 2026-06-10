#!/bin/sh
set -e
mkdir -p dist
# Concatenate JS in order
cat src/js/01-core.js \
    src/js/02-home.js \
    src/js/03-expenses.js \
    src/js/04-admin.js \
    src/js/05-targets.js \
    src/js/06-charts.js \
    src/js/07-sidebar.js \
    src/js/08-agent-firebase.js \
    src/js/09-swipe.js \
    src/js/10-fab-audit.js \
    src/js/11-pwa-banner.js \
    > dist/app.js
# Copy CSS
cp src/css/app.css dist/app.css
echo "Build complete: dist/app.js and dist/app.css"
