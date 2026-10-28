#!/usr/bin/env python3
"""Regla R∞ (Frank, 28/10/2026): una orden marcada como cumplida en
docs/ORDENES.md tiene todos sus criterios marcados y, en cada uno, una
evidencia que existe en el repositorio (un fichero) y, si cita un test
entre comillas, ese test por su nombre."""
from __future__ import annotations

import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
ORDENES = RAIZ / "docs" / "ORDENES.md"


def main() -> int:
    if not ORDENES.exists():
        print("FALLO: falta docs/ORDENES.md (regla R∞)")
        return 1
    fallos, orden, estado, n, bloque = [], None, None, 0, False
    for linea in ORDENES.read_text(encoding="utf-8").splitlines():
        # El ejemplo de formato, entre ```, no es una orden.
        if linea.startswith("```"):
            bloque = not bloque
            continue
        if bloque:
            continue
        if linea.startswith("## O-"):
            orden, estado = linea[3:].split(" · ")[0], None
            n += 1
            continue
        if orden and linea.startswith("Estado:"):
            estado = linea.split(":", 1)[1].strip()
            if estado not in ("abierta", "cumplida"):
                fallos.append(f"{orden}: estado «{estado}»")
            continue
        m = re.match(r"- \[([ x])\] (.+?) · evidencia:(.*)$", linea)
        if not (orden and m):
            continue
        hecho, criterio, ev = m.group(1) == "x", m.group(2), m.group(3).strip()
        if estado == "cumplida" and not hecho:
            fallos.append(f"{orden}: cumplida con un criterio sin marcar: {criterio}")
        if hecho:
            if not ev:
                fallos.append(f"{orden}: «{criterio}» marcado sin evidencia")
                continue
            fichero = ev.split(" ")[0].rstrip(",")
            ruta = RAIZ / fichero
            if not ruta.exists():
                fallos.append(f"{orden}: la evidencia {fichero} no existe")
                continue
            for nome in re.findall(r"«([^»]+?)(?:…)?»", ev):
                if ruta.is_file() and nome.rstrip(".") not in ruta.read_text(encoding="utf-8"):
                    fallos.append(f"{orden}: {fichero} no tiene el test «{nome}»")
    if fallos:
        print("FALLO (regla R∞):\n  " + "\n  ".join(fallos))
        return 1
    print(f"OK: {n} órdenes en docs/ORDENES.md; las cumplidas, con evidencia en cada criterio.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
