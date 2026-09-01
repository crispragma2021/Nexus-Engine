#!/usr/bin/env bash
# Captura y trunca salidas excesivas para proteger el contexto del LLM
MAX_LINES=50
LOG_FILE="nexus_daemon.log"

CMD="$*"
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [EXEC_SAFE] $CMD" >> "$LOG_FILE"

TMP_OUT=$(mktemp)
eval "$CMD" > "$TMP_OUT" 2>&1
EXIT_CODE=$?

TOTAL_LINES=$(wc -l < "$TMP_OUT")

if [ "$TOTAL_LINES" -gt "$MAX_LINES" ]; then
  echo "--- [SALIDA TRUNCADA: Mostrando 25 primeras y 25 últimas de $TOTAL_LINES líneas] ---"
  head -n 25 "$TMP_OUT"
  echo "... [Líneas intermedias omitidas para ahorrar contexto] ..."
  tail -n 25 "$TMP_OUT"
else
  cat "$TMP_OUT"
fi

rm -f "$TMP_OUT"
exit $EXIT_CODE
