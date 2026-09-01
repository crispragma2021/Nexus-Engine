#!/usr/bin/env bash
echo "=== TELEMETRÍA DEL SISTEMA ==="
echo "--- Memoria RAM ---"
free -h 2>/dev/null || cat /proc/meminfo | grep -E "MemTotal|MemFree|MemAvailable"

echo ""
echo "--- Almacenamiento ---"
df -h . | awk 'NR==1 || NR==2'

echo ""
echo "--- Batería (Termux) ---"
if command -v termux-battery-status >/dev/null 2>&1; then
  termux-battery-status | jq -r '"Nivel: \(.percentage)% | Estado: \(.status) | Temperatura: \(.temperature)°C"'
else
  echo "termux-api no disponible (datos de batería omitidos)."
fi
