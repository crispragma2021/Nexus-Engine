#!/usr/bin/env bash
set -e

QUERY="$*"
if [ -z "$QUERY" ]; then
  echo "Uso: ./nexus_query.sh <tu pregunta>"
  exit 1
fi

./cf_vector_rag.sh search "$QUERY"
