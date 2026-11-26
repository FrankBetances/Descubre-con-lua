#!/usr/bin/env python3
"""F-20261126-5: lo que Frank aprueba para Antigravity está guardado en el repositorio.

Si docs/ORDENES.md da por aprobadas mejoras «M<n>», docs/PROMPTS_ANTIGRAVITY.md
tiene que llevar una sección «vigente» que nombre cada una («M1 · …»). Pasó el
26/11/2026: Claude Code dio a Frank la corrección con M1-M5 en el chat y esperó
un «sigue» para guardarla, aunque Frank ya había pedido guardarlo todo.
"""
import re
import sys
from pathlib import Path

ORDENES = Path("docs/ORDENES.md")
PROMPTS = Path("docs/PROMPTS_ANTIGRAVITY.md")


def main() -> int:
    o = ORDENES.read_text(encoding="utf-8")
    aprobadas = set()
    for linea in o.splitlines():
        if linea.startswith("Decisión:") and "aprobad" in linea:
            for a, b in re.findall(r"\bM(\d+)(?:-M(\d+))?\b", linea):
                aprobadas.update(range(int(a), int(b or a) + 1))
    if not aprobadas:
        print("OK: ninguna mejora M<n> aprobada en ORDENES.md.")
        return 0
    p = PROMPTS.read_text(encoding="utf-8")
    vigentes = re.findall(r"^## [^\n]*vigente[^\n]*\n(.*?)(?=^## |\Z)", p, re.M | re.S)
    texto = "\n".join(vigentes)
    faltan = [f"M{n}" for n in sorted(aprobadas) if not re.search(rf"\bM{n} · ", texto)]
    if faltan:
        print("FALLO: aprobadas en ORDENES.md y sin guardar en un prompt vigente: " + ", ".join(faltan))
        return 1
    print(f"OK: las {len(aprobadas)} mejoras aprobadas están en un prompt vigente.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
