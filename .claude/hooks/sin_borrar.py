#!/usr/bin/env python3
"""Hook PreToolUse (R-BORRAR, F-20261119-2): nada se borra sin que Frank lo
pida con palabras.

Bloquea, salvo que el objetivo esté en .claude/estado/permiso_borrar (lo
escribe stop_freno.py solo con lo que Frank pide borrar en su mensaje):
  - Bash: rm, rmdir, unlink, git rm, git clean, git reset --hard,
    git checkout -- / git restore de ficheros, find -delete, truncate,
    os.remove / rmtree / .unlink() dentro de un script;
  - Write sobre un fichero que existe con menos de la mitad de su contenido;
  - Edit que borra más de 400 caracteres sin poner casi nada en su lugar.
Lo de /tmp y del directorio de trabajo temporal de la sesión sí se puede
borrar: no es del proyecto."""
import json
import os
import re
import sys
from pathlib import Path

RAIZ = Path(os.environ.get("CLAUDE_PROJECT_DIR", "."))
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
tool, inp = d.get("tool_name", ""), d.get("tool_input", {}) or {}
permiso = [l.strip() for l in (RAIZ / ".claude/estado/permiso_borrar").read_text(encoding="utf-8").splitlines()
           if l.strip()] if (RAIZ / ".claude/estado/permiso_borrar").exists() else []


def permitido(texto: str) -> bool:
    return any(p and p in texto for p in permiso)


def bloquea(que: str):
    print(f"R-BORRAR: {que}. Frank no lo ha pedido en su mensaje. Propónselo y espera su «borra …».", file=sys.stderr)
    sys.exit(2)


if tool == "Bash":
    c = inp.get("command", "")
    # /tmp, el directorio temporal de la sesión y las marcas de estado de los
    # hooks no son del proyecto: si todo lo que el comando borra está ahí, pasa.
    fuera = r"/tmp/\S*|\$S\S*|\S*scratchpad\S*|\S*estado/(?:parado|permiso_borrar)"
    sin_tmp = re.sub(fuera, "", c)
    objetivos = re.findall(r"(?:^|[\s;&|(])rm\s+((?:-\S+\s+)*)([^;&|\n]+)", c)
    if objetivos and all(all(re.fullmatch(fuera, x) for x in o[1].split()) for o in objetivos):
        sys.exit(0)
    patrones = [r"(^|[\s;&|(])rm\s", r"\brmdir\b", r"\bunlink\b", r"\bgit\s+rm\b", r"\bgit\s+clean\b",
                r"\breset\s+--hard\b", r"\bgit\s+checkout\s+--\s", r"\bgit\s+restore\b", r"-delete\b",
                r"\btruncate\b", r"os\.remove\(", r"rmtree\(", r"\.unlink\("]
    for pat in patrones:
        if re.search(pat, sin_tmp) and not permitido(c):
            bloquea(f"el comando borra o descarta ficheros ({pat})")
elif tool == "Write":
    p = Path(inp.get("file_path", ""))
    if p.exists() and p.is_file() and not str(p).startswith("/tmp"):
        viejo = p.stat().st_size
        if viejo > 400 and len(inp.get("content", "").encode()) < viejo / 2 and not permitido(str(p)):
            bloquea(f"Write deja {p} con menos de la mitad de su contenido")
elif tool == "Edit":
    viejo, nuevo = inp.get("old_string", ""), inp.get("new_string", "")
    if len(viejo) > 400 and len(nuevo) < len(viejo) / 4 and not permitido(inp.get("file_path", "")):
        bloquea(f"Edit borra {len(viejo) - len(nuevo)} caracteres de {inp.get('file_path')}")
