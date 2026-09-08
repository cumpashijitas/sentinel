#!/usr/bin/env bash
# Build de Flutter Web para Vercel — Vercel no trae el SDK de Flutter
# instalado, así que este script lo clona en cada build (no hay caché
# persistente del SDK entre builds en el plan gratuito). Existe como
# archivo separado, no como el propio "Build Command" de Vercel, porque
# ese campo tiene un límite de 256 caracteres — corto de sobra para un
# comando de una línea, pero no para armar el .env + clonar Flutter +
# compilar en un solo string.
set -e

# front/.env está en .gitignore (nunca llega al repo) — se arma acá desde
# las variables de entorno cargadas en el proyecto de Vercel.
echo "API_BASE_URL=$API_BASE_URL" > .env
echo "WEB_BASE_URL=$WEB_BASE_URL" >> .env
echo "ENVIRONMENT=prod" >> .env

git clone https://github.com/flutter/flutter.git -b stable --depth 1 _flutter_sdk
export PATH="$PATH:$(pwd)/_flutter_sdk/bin"

flutter config --enable-web --no-analytics
flutter pub get
flutter build web --release
