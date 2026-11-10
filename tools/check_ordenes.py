#!/usr/bin/env python3
"""Regla R∞ (Frank, 28/10/2026): una orden marcada como cumplida en
docs/ORDENES.md tiene todos sus criterios marcados y, en cada uno, una
evidencia que existe en el repositorio (un fichero) y, si cita un test
entre comillas, ese test por su nombre.

Y desde el 9/11/2026 (O-20261109-2, tras copiar de lo que había en vez de
Valeria): cada orden desde O-20261109-2 lleva una línea «Fuente:» escrita
antes de empezar, que dice de dónde sale lo que se hace —un fichero de este
repositorio, «FrankBetances/<repo>:<ruta>» de otro, o «ninguna: contenido
nuevo»—. Sin ella, falla aunque la orden siga abierta."""
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
    fuentes: dict[str, str | None] = {}
    for linea in ORDENES.read_text(encoding="utf-8").splitlines():
        # El ejemplo de formato, entre ```, no es una orden.
        if linea.startswith("```"):
            bloque = not bloque
            continue
        if bloque:
            continue
        if linea.startswith("## O-"):
            orden, estado = linea[3:].split(" · ")[0], None
            fuentes[orden] = None
            n += 1
            continue
        if orden and linea.startswith("Fuente:"):
            fuentes[orden] = linea.split(":", 1)[1].strip()
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
    # O-20261110-1: los criterios de ACOPROS (O-20261109-4) solo se marcan con
    # la evidencia de su gate o de su test, no con cualquier fichero.
    texto = ORDENES.read_text(encoding="utf-8")
    if "## O-20261109-4" in texto:
        bloque = texto.split("## O-20261109-4", 1)[1].split("\n## ", 1)[0]
        for linea in bloque.splitlines():
            m = re.match(r"- \[x\] (.+?) · evidencia:(.*)$", linea)
            if m and "Mergeado" not in m.group(1) and not any(
                    e in m.group(2) for e in ("tools/gen_acopros_0_2.py", "test/features/acopros_0_2_test.dart")):
                fallos.append(f"O-20261109-4: «{m.group(1)[:60]}» marcado sin el gate ni el test de ACOPROS")
    for o, f in fuentes.items():
        if o < "O-20261109-2":
            continue
        if not f:
            fallos.append(f"{o}: sin línea «Fuente:» (de dónde sale lo que se hace)")
        elif not (f.startswith("ninguna") or re.match(r"FrankBetances/[\w.-]+:\S+", f)
                  or (RAIZ / f.split(" ")[0].rstrip(",;")).exists()):
            fallos.append(f"{o}: la fuente «{f}» no es un fichero, un «FrankBetances/<repo>:<ruta>» ni «ninguna: …»")
    if fallos:
        print("FALLO (regla R∞):\n  " + "\n  ".join(fallos))
        return 1
    print(f"OK: {n} órdenes en docs/ORDENES.md; las cumplidas, con evidencia en cada criterio.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
