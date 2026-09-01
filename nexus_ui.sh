#!/usr/bin/env bash

# Códigos ANSI nativos para Termux
DIM="\033[2;37m"     # Letras gris apagadas / tenue
BRIGHT="\033[1;37m"  # Blanco brillante
GREEN="\033[1;32m"   # Verde éxito
RED="\033[1;31m"     # Rojo error
CYAN="\033[1;36m"    # Cyan info
RESET="\033[0m"      # Reset de estilo

run_with_ui() {
  local MSG="$1"
  shift
  local CMD="$*"

  # Imprime estado tenue/gris en la misma línea
  echo -ne "${DIM}⚙ ${MSG}...${RESET}\r"

  # Ejecuta comando redirigiendo el ruido a nexus_daemon.log
  if eval "$CMD" >> nexus_daemon.log 2>&1; then
    echo -e "${GREEN}✓ ${MSG} completado.${RESET}"
  else
    echo -e "${RED}✗ Error en: ${MSG}.${RESET} ${DIM}(Revisa nexus_daemon.log)${RESET}"
    return 1
  fi
}

show_result() {
  local TITLE="$1"
  local CONTENT="$2"
  echo ""
  echo -e "${CYAN}=== ${TITLE} ===${RESET}"
  echo -e "${BRIGHT}${CONTENT}${RESET}"
}
