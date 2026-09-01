#!/usr/bin/env bash
set -e

ACTION="$1"
SKILL_NAME="$2"
CONTENT="$3"

mkdir -p .nexus/skills

case "$ACTION" in
  list)
    echo "=== SKILLS DISPONIBLES ==="
    ls -1 .nexus/skills/*.md 2>/dev/null || echo "No hay skills creadas aún."
    ;;
  read)
    if [ -f ".nexus/skills/${SKILL_NAME}.md" ]; then
      cat ".nexus/skills/${SKILL_NAME}.md"
    else
      echo "Error: Skill '${SKILL_NAME}' no encontrada."
      exit 1
    fi
    ;;
  create)
    echo "$CONTENT" > ".nexus/skills/${SKILL_NAME}.md"
    echo "Skill '${SKILL_NAME}' generada e indexada correctamente en .nexus/skills/."
    ;;
  *)
    echo "Uso: ./nexus_skill.sh {list|read <nombre>|create <nombre> <contenido>}"
    exit 1
    ;;
esac
