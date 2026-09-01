#!/usr/bin/env bash
set -e

cd "$HOME"

echo "=== 1. LOCALIZANDO CARPETA OFICIAL ==="
OFFICIAL_DIR=""
if [ -d "$HOME/GDevelop-master/newIDE" ]; then
  OFFICIAL_DIR="$HOME/GDevelop-master"
elif [ -d "$HOME/GDevelop/newIDE" ]; then
  OFFICIAL_DIR="$HOME/GDevelop"
elif [ -d "$HOME/GDevelop_Engine/newIDE" ]; then
  OFFICIAL_DIR="$HOME/GDevelop_Engine"
fi

if [ -z "$OFFICIAL_DIR" ]; then
  echo "❌ Error: No se encontró la carpeta oficial con newIDE."
  exit 1
fi

echo "✓ Trabajando sobre: $OFFICIAL_DIR"
cd "$OFFICIAL_DIR"

echo "=== 2. CONFIGURANDO VÍNCULO A GITHUB ==="
git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/crispragma2021/Nexus-Engine.git
git config user.name "crispragma2021"
git config user.email "Crispragma2021@gmail.com"

echo "=== 3. INYECTANDO TU MARCA ==="
mkdir -p assets .github/workflows
if [ -f "/sdcard/DCIM/Creative/IMG_20260828_190920.jpg" ]; then
  cp "/sdcard/DCIM/Creative/IMG_20260828_190920.jpg" assets/nexus_logo.jpg
  cp assets/nexus_logo.jpg newIDE/app/resources/GDicon.png 2>/dev/null || true
  cp assets/nexus_logo.jpg newIDE/app/public/favicon.ico 2>/dev/null || true
fi

sed -i 's/<title>.*<\/title>/<title>NEXUS ENGINE - 2D\/3D GAME ENGINE<\/title>/g' newIDE/app/public/index.html 2>/dev/null || true
sed -i 's/"name": "gdevelop"/"name": "nexus-engine"/g' newIDE/app/package.json 2>/dev/null || true

find newIDE/app/src -type f \( -name "*Analytics*.js" -o -name "*Analytics*.ts" \) | while read -r file; do
  echo "export const sendMetric = () => {}; export default {};" > "$file"
done

echo "=== 4. CONFIGURANDO WORKFLOW ==="
cat << 'WORKFLOW' > .github/workflows/build-nexus.yml
name: Build and Deploy NEXUS ENGINE

on:
  push:
    branches: [ main, master ]
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build-nexus:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Repositorio Propio
        uses: actions/checkout@v4

      - name: Configurar Node.js 18
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Instalar Dependencias
        run: |
          npm --prefix newIDE/app install --legacy-peer-deps
          npm --prefix newIDE/app install react-refresh@^0.14.0 --legacy-peer-deps --save-dev
          mkdir -p newIDE/app/node_modules/GDJS-for-web-app-only/
          cp -r GDJS/Runtime newIDE/app/node_modules/GDJS-for-web-app-only/ || true

      - name: Compilar Web App
        run: |
          npm --prefix newIDE/app run build

      - name: Publicar en Rama dist
        uses: peaceiris/actions-gh-pages@v4
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./newIDE/app/build
          publish_branch: dist
WORKFLOW

echo "=== 5. SUBIENDO A GITHUB ==="
git branch -M main
git add .
git commit -m "feat: base oficial de gdevelop 5 adaptada a nexus engine" || true
git push origin main --force

echo "✓ Repositorio oficial sincronizado y subido a GitHub sin eliminar archivos locales."
