#!/usr/bin/env bash
# F-20261126-10: nada se mergea en main sin que estén verdes, aquí y enteros,
# los gates y todos los generadores con --check. El 26/11/2026 Claude Code
# mergeó #71 y #72 sin esperar al final de los gates locales ni al CI, y main
# quedó en rojo con la guía de casa y las lecciones sin regenerar.
# Uso: bash tools/antes_de_mergear.sh && (solo entonces) merge.
set -uo pipefail
cd "$(dirname "$0")/.."
fallos=0
for g in tools/gen_*.py; do
  if grep -q -- '--check' "$g"; then
    if ! python3 "$g" --check >/dev/null 2>&1; then
      echo "ROJO: $g --check (regenera con: python3 $g)"; fallos=$((fallos+1))
    fi
  fi
done
[[ $fallos -eq 0 ]] || { echo "$fallos generador(es) sin regenerar: NO se mergea."; exit 1; }
bash tools/gates.sh --fast || { echo "Gates en rojo: NO se mergea."; exit 1; }
echo "OK: se puede abrir el PR; se mergea solo con el CI de la rama en verde."
