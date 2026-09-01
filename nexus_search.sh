#!/usr/bin/env bash
set -e

QUERY="$1"
if [ -z "$QUERY" ]; then
  echo "Uso: ./nexus_search.sh <terminos de busqueda>"
  exit 1
fi

ENCODED_QUERY=$(printf '%s' "$QUERY" | jq -s -R -r @uri)

# Busca en DuckDuckGo HTML y extrae texto plano de los resultados
curl -s -L "https://html.duckduckgo.com/html/?q=${ENCODED_QUERY}" \
  -H "User-Agent: Mozilla/5.0 (Android; Mobile; rv:109.0) Gecko/109.0 Firefox/110.0" \
  --max-time 15 | lynx -dump -stdin 2>/dev/null | grep -E -A 2 "(http|https)://" | head -n 40
