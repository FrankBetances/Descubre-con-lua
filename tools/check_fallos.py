#!/usr/bin/env python3
"""Orden de automejora (Frank, O-20261109-2): cada fallo de docs/FALLOS.md
lleva qué pasó, la causa raíz y una guarda que existe en el repositorio."""
from __future__ import annotations

import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
FALLOS = RAIZ / "docs" / "FALLOS.md"


def main() -> int:
    if not FALLOS.exists():
        print("FALLO: falta docs/FALLOS.md (orden de automejora)")
        return 1
    texto = FALLOS.read_text(encoding="utf-8").split("```")[-1]
    entradas = re.split(r"^## (?=F-\d{8}-\d+)", texto, flags=re.M)[1:]
    fallos = []
    for e in entradas:
        nome = e.split(" · ")[0].strip()
        for campo in ("- Qué pasó:", "- Causa raíz:", "- Guarda:"):
            if campo not in e:
                fallos.append(f"{nome}: falta «{campo[2:]}»")
        m = re.search(r"- Guarda:\s*(.+)", e)
        if m:
            rutas = re.findall(r"[\w./-]+\.(?:py|sh|dart|json|yml|md)", m.group(1))
            if not rutas:
                fallos.append(f"{nome}: la guarda no nombra ningún fichero")
            for r in rutas:
                if not (RAIZ / r).exists():
                    fallos.append(f"{nome}: la guarda {r} no existe")
    if not entradas:
        fallos.append("docs/FALLOS.md no tiene ninguna entrada")
    if fallos:
        print("FALLO (automejora):\n  " + "\n  ".join(fallos))
        return 1
    print(f"OK: {len(entradas)} fallos registrados, cada uno con su guarda.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
