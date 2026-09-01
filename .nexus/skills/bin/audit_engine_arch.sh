#!/usr/bin/env bash
set -e
TARGET_DIR="${1:-.}"
echo "=== AUDITORÍA ESTRUCTURAL ==="
find "$TARGET_DIR" -maxdepth 3 -type d ! -path "*/.git*"
echo "=== MÓDULOS DE RENDER Y FÍSICA ==="
find "$TARGET_DIR" -type f \( -name "*render*" -o -name "*physics*" -o -name "*3d*" \) ! -path "*/.git*" | head -n 40
