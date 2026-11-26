#!/usr/bin/env python3
"""F-20261126-13: un criterio marcado [x] en docs/ORDENES.md no puede llevar
una evidencia que confiese que no está hecho. El 26/11/2026 Claude Code
intentó cerrar criterios con «no lo he verificado», «en curso» y «sin esperar
al final del CI» escritos en la propia evidencia."""
import re
import sys
from pathlib import Path

ORDENES = Path(__file__).resolve().parent.parent / "docs" / "ORDENES.md"
# Confesiones, no palabras sueltas: «curso_0_2» o «falla si falta» no lo son.
DELATAN = [re.compile(p) for p in (
    r"no (lo|la|los|las) he (verificado|comprobado|mirado|visto)",
    r"\bno he (verificado|comprobado|mirado)",
    r"sin esperar al? (final|ci|verde)",
    r"\b(ci|run)\b[^;.]{0,40}\ben curso\b",
    r"\bpor verificar\b",
    r"\baún no\b",
)]


def main() -> int:
    fallos = []
    for n, linea in enumerate(ORDENES.read_text(encoding="utf-8").splitlines(), 1):
        if not linea.startswith("- [x]") or "· evidencia:" not in linea:
            continue
        ev = linea.split("· evidencia:", 1)[1].lower()
        for d in DELATAN:
            m = d.search(ev)
            if m:
                fallos.append(f"línea {n}: marcado hecho con «{m.group(0)}» en la evidencia")
                break
    if fallos:
        print("FALLO (criterio cerrado sin estar hecho):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: ningún criterio cerrado confiesa en su evidencia que no está hecho.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
