#!/usr/bin/env bash

LOG_FILE="nexus_daemon.log"
SCRATCHPAD="scratchpad.json"

echo "=== ESTADO DEL AGENTE (MODO LIGERO) ==="

# 1. Rama Git sin recorrer todo el árbol
if [ -d ".git" ]; then
  BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "Desconocida")
  echo "• Rama Git activa: $BRANCH"
fi

# 2. Skills activas
SKILLS_COUNT=$(find .nexus/skills/bin -type f 2>/dev/null | wc -l)
echo "• Skills disponibles: $SKILLS_COUNT"

# 3. Scratchpad resumido
if [ -f "$SCRATCHPAD" ]; then
  echo ""
  echo "--- Memoria de Sesión ---"
  jq -r '"• Meta: \(.active_goal)\n• Detalle: \(.task_details)"' "$SCRATCHPAD" 2>/dev/null || echo "Scratchpad no parseable."
fi

# 4. Últimas líneas del log sin saturar buffer
if [ -f "$LOG_FILE" ]; then
  echo ""
  echo "--- Última Actividad ---"
  tail -n 6 "$LOG_FILE"
fi
