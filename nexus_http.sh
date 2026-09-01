#!/usr/bin/env bash
set -e

METHOD="${1:-GET}"
URL="$2"
DATA="$3"

if [ -z "$URL" ]; then
  echo "Uso: ./nexus_http.sh <METHOD> <URL> [JSON_DATA]"
  exit 1
fi

if [ -n "$DATA" ]; then
  curl -s -X "$METHOD" "$URL" \
    -H "Content-Type: application/json" \
    -d "$DATA" \
    --max-time 20 | head -n 100
else
  curl -s -X "$METHOD" "$URL" \
    --max-time 20 | head -n 100
fi
