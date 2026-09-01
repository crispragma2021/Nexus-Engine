#!/usr/bin/env bash
set -e
SRC="$1"
DEST="$2"
mkdir -p "$DEST"
cp -r "$SRC"/* "$DEST/"
echo "Subsistema extraído en $DEST"
