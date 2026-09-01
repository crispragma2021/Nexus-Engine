#!/usr/bin/env bash
set -e

FILE="$1"
OLD_STR="$2"
NEW_STR="$3"

if [ ! -f "$FILE" ]; then
  echo "Error: El archivo $FILE no existe."
  exit 1
fi

python3 -c "
import sys

file_path = sys.argv[1]
old_str = sys.argv[2]
new_str = sys.argv[3]

with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

if old_str not in content:
    print('Error: El texto a reemplazar no fue encontrado en el archivo.')
    sys.exit(1)

content = content.replace(old_str, new_str, 1)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)

print('Reemplazo quirúrgico aplicado exitosamente.')
" "$FILE" "$OLD_STR" "$NEW_STR"
