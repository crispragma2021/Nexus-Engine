#!/usr/bin/env bash
set -e

TASK_NAME="${1:-task_$(date +%s)}"
SANDBOX_BRANCH="sandbox/${TASK_NAME}"
LOG_FILE="nexus_daemon.log"

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SANDBOX] Creando entorno aislado: $SANDBOX_BRANCH" >> "$LOG_FILE"

# 1. Crear rama sandbox limpia desde el HEAD actual
git checkout -b "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1

# Función de rollback automático ante fallos
cleanup_on_error() {
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SANDBOX ERROR] Revirtiendo cambios..." >> "$LOG_FILE"
  git checkout - >> "$LOG_FILE" 2>&1 || git checkout main >> "$LOG_FILE" 2>&1
  git branch -D "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SANDBOX ERROR] Estado restaurado al último commit limpio." >> "$LOG_FILE"
  exit 1
}

trap cleanup_on_error ERR

# 2. Validación estricta antes de aceptar el trabajo
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SANDBOX] Validando código con cargo check..." >> "$LOG_FILE"
cargo check --quiet >> "$LOG_FILE" 2>&1

# 3. Si pasa la validación, fusiona a main de forma limpia
echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SANDBOX SUCCESS] Validación superada. Sincronizando con main..." >> "$LOG_FILE"
git checkout - >> "$LOG_FILE" 2>&1 || git checkout main >> "$LOG_FILE" 2>&1
git merge --ff-only "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1
git branch -d "$SANDBOX_BRANCH" >> "$LOG_FILE" 2>&1

echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] [SANDBOX] Tarea completada e integrada con éxito." >> "$LOG_FILE"
