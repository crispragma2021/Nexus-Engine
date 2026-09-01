#!/usr/bin/env bash
set -e

ACTION="$1"
SKILL_NAME="$2"
shift 2 || true

SKILL_DIR=".nexus/skills"
BIN_DIR=".nexus/skills/bin"
LOG_FILE="nexus_daemon.log"

mkdir -p "$SKILL_DIR" "$BIN_DIR"

case "$ACTION" in
  create)
    DOCS="$1"
    SCRIPT_CODE="$2"
    
    # 1. Guardar documentación de la skill
    echo "$DOCS" > "${SKILL_DIR}/${SKILL_NAME}.md"
    
    # 2. Guardar script ejecutable de la skill si existe
    if [ -n "$SCRIPT_CODE" ]; then
      cat << 'SKILLEOF' > "${BIN_DIR}/${SKILL_NAME}.sh"
#!/usr/bin/env bash
set -e
SKILLEOF
      echo "$SCRIPT_CODE" >> "${BIN_DIR}/${SKILL_NAME}.sh"
      chmod +x "${BIN_DIR}/${SKILL_NAME}.sh"
    fi
    
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SKILL ENGINE] Skill '${SKILL_NAME}' creada y lista para uso." >> "$LOG_FILE"
    echo "Skill '${SKILL_NAME}' registrada con éxito."
    ;;

  run)
    if [ ! -f "${BIN_DIR}/${SKILL_NAME}.sh" ]; then
      echo "Error: La skill '${SKILL_NAME}' no tiene ejecutable asociado."
      exit 1
    fi
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SKILL RUN] Ejecutando skill: ${SKILL_NAME}" >> "$LOG_FILE"
    "${BIN_DIR}/${SKILL_NAME}.sh" "$@" >> "$LOG_FILE" 2>&1
    echo "Skill '${SKILL_NAME}' ejecutada correctamente."
    ;;

  list)
    echo "=== SKILLS AUTOGENERADAS ==="
    ls -1 "$SKILL_DIR"/*.md 2>/dev/null | xargs -n 1 basename -s .md || echo "Sin skills aún."
    ;;

  inspect)
    if [ -f "${SKILL_DIR}/${SKILL_NAME}.md" ]; then
      cat "${SKILL_DIR}/${SKILL_NAME}.md"
    else
      echo "Error: Skill '${SKILL_NAME}' no encontrada."
      exit 1
    fi
    ;;

  *)
    echo "Uso: ./nexus_skill_engine.sh {create <nombre> <docs> <script> | run <nombre> [args] | inspect <nombre> | list}"
    exit 1
    ;;
esac
