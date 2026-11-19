#!/usr/bin/env python3
"""Hook PreToolUse (F-20261119-1…3): Claude Code no puede tocar sus propios
frenos. Bloquea escribir o editar en .claude/ (hooks, settings, estado) con
Write, Edit o Bash. Leer sí. Solo Frank cambia los frenos."""
import json
import re
import sys

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
tool, inp = d.get("tool_name", ""), d.get("tool_input", {}) or {}
if tool in ("Write", "Edit", "NotebookEdit") and "/.claude/" in inp.get("file_path", "") + "/":
    if re.search(r"/\.claude/(hooks|settings|estado)", inp.get("file_path", "")):
        print("Blindaje: .claude/ (hooks, settings, estado) solo lo cambia Frank.", file=sys.stderr)
        sys.exit(2)
if tool == "Bash":
    c = inp.get("command", "")
    if re.search(r"\.claude/(hooks|settings|estado)", c) and not re.match(r"^\s*(cat|ls|grep|head|tail|sed -n|wc|git (diff|log|status|show)|python3 -c \"import json)", c):
        if re.search(r"(>|\btee\b|\bsed -i\b|\bmv\b|\bcp\b|\brm\b|\bchmod\b|\bwrite_text\b|open\([^)]*['\"][wa])", c):
            print("Blindaje: .claude/ (hooks, settings, estado) solo lo cambia Frank.", file=sys.stderr)
            sys.exit(2)
