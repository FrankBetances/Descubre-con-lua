#!/usr/bin/env python3
"""F-20261126-6: un criterio hecho no se queda abierto en docs/ORDENES.md.

Si la tabla de control de una entrega (docs/p*-control.md) da evidencia a un
criterio que en ORDENES.md sigue «- [ ]», o se marca con su evidencia o lleva
justo encima una línea «> Abierto (…): …» que diga qué le falta. Pasó el
26/11/2026: Claude Code contó como pendientes cuatro criterios que Antigravity
ya había hecho con sus tests en verde, y Frank recibió una cuenta falsa.
"""
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent


def main() -> int:
    lineas = (RAIZ / "docs/ORDENES.md").read_text(encoding="utf-8").splitlines()
    control = {}
    for f in sorted((RAIZ / "docs").glob("p*-control.md")):
        for l in f.read_text(encoding="utf-8").splitlines():
            c = [x.strip() for x in l.split("|")]
            if len(c) >= 5 and c[-2] and not c[-2].startswith("---"):
                control[c[2][:60]] = f.name
    fallos = []
    for i, l in enumerate(lineas):
        m = re.match(r"- \[ \] (.+?) · evidencia:", l)
        if not m:
            continue
        clave = m.group(1).replace("`", "")[:60]
        if clave in {k.replace("`", "") for k in control} and not lineas[i - 1].startswith("> Abierto"):
            fallos.append(f"«{m.group(1)[:70]}…»: tiene evidencia en la tabla de control y sigue abierto sin decir qué falta")
    if fallos:
        print("FALLO (criterios hechos sin pasar a ORDENES):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: ningún criterio con evidencia en las tablas de control sigue abierto sin motivo.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
