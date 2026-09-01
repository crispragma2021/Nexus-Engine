#!/usr/bin/env bash
TITLE="${1:-Nexus Agent}"
MESSAGE="${2:-Tarea en segundo plano completada.}"

# Si termux-api está instalado, envía notificación visual al móvil
if command -v termux-notification >/dev/null 2>&1; then
  termux-notification --title "$TITLE" --content "$MESSAGE" --priority high
fi

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [NOTIFY] $TITLE: $MESSAGE" >> nexus_daemon.log
