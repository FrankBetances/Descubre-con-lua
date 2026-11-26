#!/usr/bin/env python3
"""F-20261126-4: un plan de mejoras de Claude Code trae mejoras propias.

docs/AUDITORIA_NIVELES_Y_REPASO.md tiene que llevar la sección «Mejoras
propuestas por Claude Code» con al menos tres propuestas (**M1 …**, **M2 …**…),
cada una con su «Por qué» y su «Coste», y una recomendación de cuál va primero.
Arreglar solo lo que Frank señaló no es plantear mejoras.
"""
import re
import sys
from pathlib import Path

PLAN = Path("docs/AUDITORIA_NIVELES_Y_REPASO.md")


def main() -> int:
    if not PLAN.exists():
        print(f"FALTA {PLAN}")
        return 1
    t = PLAN.read_text(encoding="utf-8")
    m = re.search(r"^## \d+\. Mejoras propuestas por Claude Code.*?(?=^## |\Z)", t, re.M | re.S)
    if not m:
        print("FALLO: el plan no tiene la sección «Mejoras propuestas por Claude Code»")
        return 1
    sec = m.group(0)
    props = re.split(r"(?=^\*\*M\d+ · )", sec, flags=re.M)[1:]
    fallos = []
    if len(props) < 3:
        fallos.append(f"solo {len(props)} propuestas propias (mínimo 3)")
    for p in props:
        nome = p.split("**")[1]
        for campo in ("Por qué", "Coste"):
            if campo not in p:
                fallos.append(f"{nome}: sin «{campo}»")
    if "Recomiendo" not in sec:
        fallos.append("sin recomendación de cuál va primero")
    if fallos:
        print("FALLO (mejoras propias):\n  " + "\n  ".join(fallos))
        return 1
    print(f"OK: {len(props)} mejoras propias, cada una con su porqué y su coste.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
