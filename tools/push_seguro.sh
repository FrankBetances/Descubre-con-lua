#!/usr/bin/env bash
# R000 y F-20261109-6: nada se empuja si format, analyze o los gates de
# órdenes y fallos fallan. Uso: tools/push_seguro.sh "mensaje del commit" [rutas...]
set -euo pipefail
cd "$(dirname "$0")/.."
msg="$1"; shift
dart format --output=none --set-exit-if-changed lib test
out=$(flutter analyze lib test 2>&1) || { echo "$out" | tail -20; echo "NO SE EMPUJA: analyze falla"; exit 1; }
echo "$out" | grep -q "No issues found" || { echo "$out" | tail -20; echo "NO SE EMPUJA: analyze con avisos"; exit 1; }
python3 tools/check_ordenes.py
python3 tools/check_fallos.py
git checkout -q -- .dart_tool pubspec.lock 2>/dev/null || true
git add -A "${@:-.}"
git commit -q -m "$msg"
git push -q -u origin "$(git branch --show-current)"
git log --oneline -1
