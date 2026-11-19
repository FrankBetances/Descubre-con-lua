#!/usr/bin/env python3
"""Hook PostToolUse (R-VERDAD-ACCIONES, F-20261119-3): cada herramienta que
se ejecuta queda apuntada en .claude/estado/registro.log con la hora y qué
tocó. stop_freno.py se lo enseña a Claude Code cuando Frank pregunta qué ha
hecho, para contestar con el registro y no de memoria."""
import json
import os
import sys
import time
from pathlib import Path

try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
inp = d.get("tool_input", {}) or {}
que = inp.get("command") or inp.get("file_path") or inp.get("url") or json.dumps(inp, ensure_ascii=False)
reg = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")) / ".claude/estado/registro.log"
reg.parent.mkdir(parents=True, exist_ok=True)
with reg.open("a", encoding="utf-8") as f:
    f.write(f"{time.strftime('%H:%M:%S')} {d.get('tool_name', '?')}: {str(que).replace(chr(10), ' ')[:200]}\n")
