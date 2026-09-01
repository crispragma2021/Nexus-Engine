#!/usr/bin/env bash
set -e

echo "=== INICIANDO AUDITORÍA PREFLIGHT NEXUS ==="

# 1. Verificar Rust & Cargo
if command -v cargo >/dev/null 2>&1; then
  echo "[OK] Rust Cargo: $(cargo --version)"
else
  echo "[ERR] Cargo no encontrado en PATH."
  exit 1
fi

# 2. Verificar Git & SSH con GitHub
echo -n "Comprobando conexión SSH con GitHub... "
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
  echo "[OK] Autenticado."
else
  echo "[WARN] Revisa tu conexión SSH o llaves en ~/.ssh/."
fi

# 3. Verificar estado del árbol Git
UNCOMMITTED=$(git status --porcelain | wc -l)
echo "[INFO] Archivos modificados sin commit: $UNCOMMITTED"

# 4. Verificar Manifiesto de Herramientas
if [ -f "tools_manifest.json" ] && jq . tools_manifest.json >/dev/null 2>&1; then
  TOTAL_TOOLS=$(jq '.tools | length' tools_manifest.json)
  echo "[OK] tools_manifest.json válido ($TOTAL_TOOLS herramientas registradas)."
else
  echo "[ERR] tools_manifest.json roto o inexistente."
  exit 1
fi

# 5. Directorio de Skills
mkdir -p .nexus/skills/bin
echo "[OK] Directorio de skills listo ($(ls -1 .nexus/skills/*.md 2>/dev/null | wc -l) skills)."

echo "=== SISTEMA 100% OPERATIVO ==="
