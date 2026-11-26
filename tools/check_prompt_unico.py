#!/usr/bin/env python3
"""F-20261126-7: para Antigravity hay UN solo prompt vigente, y está entero.

Frank, 26/11/2026: «me des todo completo, que no me des nada trozo y me digas
cómo hay que pegar». docs/PROMPTS_ANTIGRAVITY.md tiene que tener exactamente
una sección con «vigente» en su título; esa sección no puede ser una
corrección ni un añadido, y su bloque de texto lleva las reglas, el paso 0
(preparar la rama), el cierre y el formato del informe final. Claude Code da
a Frank ese bloque copiado tal cual, nunca una línea suelta para pegar aparte.
"""
import re
import sys
from pathlib import Path

PROMPTS = Path(__file__).resolve().parent.parent / "docs/PROMPTS_ANTIGRAVITY.md"
OBRIGATORIO = ("REGLAS", "PASO 0", "CIERRE", "De la orden falta")


def main() -> int:
    t = PROMPTS.read_text(encoding="utf-8")
    vigentes = re.findall(r"^## ([^\n]*vigente[^\n]*)\n(.*?)(?=^## |\Z)", t, re.M | re.S)
    fallos = []
    if len(vigentes) != 1:
        fallos.append(f"hay {len(vigentes)} secciones vigentes; tiene que haber una sola: "
                      + "; ".join(v[0] for v in vigentes))
    for titulo, cuerpo in vigentes:
        if re.search(r"correcci[oó]n|añadido|para pegar sobre", titulo, re.I):
            fallos.append(f"«{titulo}»: una corrección no puede ser el prompt vigente")
        bloque = re.search(r"```text\n(.*?)```", cuerpo, re.S)
        if not bloque:
            fallos.append(f"«{titulo}»: sin bloque de texto que copiar")
            continue
        for k in OBRIGATORIO:
            if k not in bloque.group(1):
                fallos.append(f"«{titulo}»: al prompt le falta «{k}»; no está entero")
    if fallos:
        print("FALLO (prompt único):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: un solo prompt vigente para Antigravity, entero.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
