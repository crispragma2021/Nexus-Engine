#!/usr/bin/env bash
SCRATCH_FILE=".nexus/scratchpad.json"
mkdir -p .nexus

ACTION="$1"
shift || true

case "$ACTION" in
  init)
    cat << 'JSONEOF' > "$SCRATCH_FILE"
{
  "current_goal": "Ninguno",
  "active_task": "Inactivo",
  "subtasks_pending": [],
  "completed_subtasks": [],
  "last_updated": ""
}
JSONEOF
    echo "Scratchpad inicializado."
    ;;
  read)
    if [ -f "$SCRATCH_FILE" ]; then
      cat "$SCRATCH_FILE"
    else
      echo '{"error": "Scratchpad no inicializado"}'
    fi
    ;;
  update)
    GOAL="$1"
    TASK="$2"
    jq --arg g "$GOAL" --arg t "$TASK" --arg d "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
      '.current_goal = $g | .active_task = $t | .last_updated = $d' \
      "$SCRATCH_FILE" > "${SCRATCH_FILE}.tmp" && mv "${SCRATCH_FILE}.tmp" "$SCRATCH_FILE"
    echo "Scratchpad actualizado."
    ;;
  *)
    echo "Uso: ./nexus_scratchpad.sh {init|read|update <goal> <task>}"
    exit 1
    ;;
esac
