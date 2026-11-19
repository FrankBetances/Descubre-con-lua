#!/usr/bin/env python3
"""Hook PreToolUse (R-STOP, F-20261119-1): si Frank dijo STOP, ninguna
herramienta se ejecuta. La marca la pone y la quita stop_freno.py."""
import os
import sys
from pathlib import Path

if (Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")) / ".claude/estado/parado").exists():
    print("R-STOP: Frank ha dicho STOP. Ninguna herramienta hasta que diga «sigue». Contesta solo con texto.", file=sys.stderr)
    sys.exit(2)
_pide = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")) / ".cl" "aude" / "estado" / "pide_texto"
if _pide.exists() and _pide.read_text(encoding="utf-8").strip():
    print("R-ENTREGA: Frank ha pedido un texto. Dáselo primero, entero, sin herramientas. Se desbloquea con su siguiente mensaje.", file=sys.stderr)
    sys.exit(2)
