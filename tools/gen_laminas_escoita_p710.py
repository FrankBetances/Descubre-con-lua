#!/usr/bin/env python3
"""Genera las 2 láminas de los pares que Frank aprobó el 20/11/2026 (O-20261119-10):
  pan (la sartén vieja de «Pum grande, pum pequeño») y cheek (la mejilla de «La cara en la cuchara»).

No sobrescribe ninguna lámina existente. Fuentes: Fluent Emoji Flat (MIT) y dibujo vectorial propio.
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from banco_comun import (  # noqa: E402
    GRIS, GRIS_OSCURO, LAMINAS_DIR, MADERA, MADERA_OSCURA, MAPA_PATH, ROJO, TINTA,
    E, L, escribir_cd, fl, fondo_mesa, frecha,
)
from tpr_tandas.comun_tpr import NARANJA_OSCURO  # noqa: E402

SCRIPT_REF = "tools/gen_laminas_escoita_p710.py"

ESCENAS = {
    "pan": ("pan", "D",
            fondo_mesa()
            + [L("M96 50 L148 40", MADERA_OSCURA, 7.0),
               E(64, 52, 36, 22, GRIS_OSCURO, TINTA, 2.4),
               E(64, 50, 29, 16, GRIS)],
            "Sartén vieja de metal vista desde arriba, con su mango largo."),
    "cheek": ("cheek", "D",
              fl("Smiling face with smiling eyes", 46, 12, 76)
              + [E(66, 51, 9, 7, None, ROJO, 2.6)]
              + frecha((22, 80), (57, 56), NARANJA_OSCURO, 2.6),
              "Cara sonriente con una flecha que señala la mejilla."),
}


def main() -> int:
    tracked = set(subprocess.check_output(["git", "ls-files", "assets/brand/laminas/"], cwd=RAIZ, text=True).splitlines())
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]
    for word, (slug, cd, formas, porque) in ESCENAS.items():
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_cd(pezas, key, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=word)
    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print("OK: pal_pan, pal_cheek")
    return 0


if __name__ == "__main__":
    sys.exit(main())
