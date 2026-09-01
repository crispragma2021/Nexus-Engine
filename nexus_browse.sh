#!/usr/bin/env bash
set -e

URL="$1"
if [ -z "$URL" ]; then
  echo "Uso: ./nexus_browse.sh <URL>"
  exit 1
fi

# Extrae la página en Markdown semántico limpio usando Jina Reader API
curl -s -L "https://r.jina.ai/${URL}" \
  -H "Accept: text/event-stream" \
  -H "X-No-Cache: true" \
  --max-time 15 | head -n 350
