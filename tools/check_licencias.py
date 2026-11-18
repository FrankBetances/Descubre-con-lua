#!/usr/bin/env python3
"""La app tiene ánimo de lucro (CLAUDE.md, Frank 18/11/2026): nada de terceros
con licencia no comercial (NC) ni sin derivadas (ND).

Revisa las licencias empaquetadas (assets/third_party/**), la pantalla de
créditos y pubspec.yaml. Falla si aparece una licencia NC/ND o ARASAAC.
"""
import re
import sys
from pathlib import Path

PROHIBIDO = re.compile(
    r"non-?commercial|no comercial|by-nc|cc[ -]by[ -]nc|nc-sa|nc-nd|by-nd|"
    r"noderivatives|sin obra derivada|arasaac",
    re.IGNORECASE,
)
SITIOS = [Path("pubspec.yaml"), Path("lib/features/creditos")]
SITIOS += [p for p in Path("assets/third_party").rglob("*") if p.is_file()] if Path("assets/third_party").is_dir() else []


def ficheros():
    for s in SITIOS:
        if s.is_dir():
            yield from (p for p in s.rglob("*") if p.is_file())
        elif s.is_file():
            yield s


fallos = []
for f in ficheros():
    try:
        txt = f.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    for n, linea in enumerate(txt.splitlines(), 1):
        if PROHIBIDO.search(linea):
            fallos.append(f"{f}:{n}: {linea.strip()[:120]}")
if fallos:
    print("FALLO: licencia no comercial o sin derivadas en una app con ánimo de lucro:")
    print("\n".join("  " + x for x in fallos))
    sys.exit(1)
print("OK: ninguna licencia NC/ND en lo empaquetado, los créditos ni pubspec.")
