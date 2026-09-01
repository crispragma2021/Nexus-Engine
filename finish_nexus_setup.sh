#!/usr/bin/env bash
set -e

cd "$HOME/GDevelop_Engine"

echo "=== 1. FUSIONANDO UPSTREAM/MASTER ==="
git merge upstream/master --allow-unrelated-histories -m "feat: importar código fuente completo de GDevelop 5" || true

echo "=== 2. INYECTANDO ASSETS Y BRANDING ==="
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

echo "=== 3. CONFIGURANDO WORKFLOW ==="
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

echo "=== 4. SUBIENDO TODO A GITHUB ==="
git branch -M main
git add .
git commit -m "feat: complete gdevelop base with nexus branding and build workflow" || true
git push origin main --force

echo "✓ Código fusionado y subido a GitHub."
