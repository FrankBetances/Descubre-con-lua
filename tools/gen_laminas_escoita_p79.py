#!/usr/bin/env python3
"""Genera las 7 láminas nuevas necesarias tras rehacer los pares STEAM en P7.9:
  heap, pip, pit, set, talk, taut, wood.

No sobrescribe ninguna lámina ya existente. Fuentes permitidas: Fluent Emoji Flat (MIT)
y dibujo vectorial propio estilo Lúa, sin texto ni dígitos.
"""
from __future__ import annotations

import json
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from PIL import Image, ImageDraw, ImageFont  # noqa: E402
from banco_comun import (  # noqa: E402
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    GRIS,
    GRIS_OSCURO,
    LAMINAS_DIR,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
    ROJO,
    ROJO_OSCURO,
    TIERRA,
    TIERRA_CLARA,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    E,
    L,
    P,
    R,
    escribir_cd,
    escribir_fluent_directo,
    fl,
    fondo_mesa,
    fondo_prado,
    fondo_sala,
    frecha,
)
from tpr_tandas.comun_tpr import (  # noqa: E402
    DORADO,
    NARANJA_OSCURO,
    ondas_sonido,
    plato_prop,
)

SCRIPT_REF = "tools/gen_laminas_escoita_p79.py"

FLUENT_DIRECTOS: list[tuple[str, str, str, str, str]] = [
    ("talk", "talk", "Speaking head", "falar", "Silueta hablando con ondas suaves de voz."),
    ("wood", "wood", "Wood", "madeira", "Bloque y troncos de madera natural."),
]

ESCENAS_CD: dict[str, tuple[str, str, list[dict], str]] = {
    "heap": (
        "heap", "C",
        fondo_prado()
        + fl("Rock", 42, 46, 32)
        + fl("Rock", 74, 44, 34)
        + fl("Rock", 58, 22, 34)
        + fl("Leaf fluttering in wind", 104, 48, 28)
        + fl("Leaf fluttering in wind", 118, 56, 26),
        "Montón apilado de piedras y hojas sobre la hierba.",
    ),
    "pip": (
        "pip", "C",
        fondo_mesa()
        + fl("Red apple", 26, 20, 48)
        + [
            # Corte central mostrando una pepita destacada con aro y flecha
            E(110, 50, 26, 26, "#fef3c7", ROJO_OSCURO, 2.4),
            E(110, 50, 7, 10, BARRO, TINTA, 1.8),
            E(110, 50, 14, 14, None, DORADO, 2.2),
        ]
        + frecha((76, 46), (94, 48), NARANJA_OSCURO, 2.4),
        "Manzana y sección ampliada destacando una pepita marrón en el centro.",
    ),
    "pit": (
        "pit", "D",
        fondo_mesa()
        + [
            # Mitad de melocotón/fruta abierta con hueso grande central destacado
            E(80, 50, 34, 32, TIERRA_CLARA, NARANJA_OSCURO, 2.4),
            E(80, 50, 27, 25, "#fde68a"),
            E(80, 50, 12, 16, BARRO, TINTA, 2.2),
            E(80, 50, 17, 20, None, DORADO, 2.2),
        ]
        + frecha((26, 50), (58, 50), NARANJA_OSCURO, 2.4),
        "Fruta abierta por la mitad con el hueso grande destacado en el centro.",
    ),
    "set": (
        "set", "C",
        fondo_mesa()
        + fl("Fork and knife with plate", 44, 16, 62)
        + fl("Cup with straw", 104, 24, 38),
        "Mesa puesta ordenadamente con plato, cubiertos y vaso.",
    ),
    "taut": (
        "taut", "D",
        fondo_sala()
        + [
            # Dos vasos unidos por un cordel completamente recto y tenso con flechas de tensión
            P([(20, 34), (42, 34), (38, 66), (24, 66)], BLANCO, AZUL_OSCURO, 2.2),
            P([(118, 34), (140, 34), (136, 66), (122, 66)], BLANCO, AZUL_OSCURO, 2.2),
            L("M41 50 L119 50", ROJO_OSCURO, 3.0),
        ]
        + frecha((66, 34), (46, 34), NARANJA_OSCURO, 2.2)
        + frecha((94, 34), (114, 34), NARANJA_OSCURO, 2.2)
        + ondas_sonido(74, 66, AZUL),
        "Dos vasos de papel unidos por un hilo recto y bien tenso.",
    ),
}


def generar_hoja(claves: list[str], out_png: Path) -> None:
    import hoja_contactos as hc  # noqa: E402

    cols = len(claves)
    tile_w, tile_h = 220, 170
    sheet = Image.new("RGB", (cols * tile_w, tile_h), "#f8fafc")
    dr = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for idx, clave in enumerate(sorted(claves)):
        x0, y0 = idx * tile_w, 0
        thumb = hc.render_clave(clave, 200, 125)
        sheet.paste(thumb, (x0 + 10, y0 + 8))
        dr.rectangle([x0 + 2, y0 + 2, x0 + tile_w - 3, y0 + tile_h - 3], outline="#cbd5e1", width=1)
        dr.text((x0 + 8, y0 + 138), clave[:28], fill="#0f172a", font=font)
    out_png.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_png)
    print(f"OK: {out_png} ({len(claves)} láminas)")


def main() -> int:
    tracked = set(
        subprocess.check_output(["git", "ls-files", "assets/brand/laminas/"], cwd=RAIZ, text=True).splitlines()
    )
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]

    creadas: list[str] = []
    for word, slug, fl_name, ur, porque in FLUENT_DIRECTOS:
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente en git: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_fluent_directo(pezas, key, slug, fl_name, ur, porque)
        creadas.append(f"pal_{slug}")

    for word, (slug, cd, formas, porque) in ESCENAS_CD.items():
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente en git: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_cd(pezas, key, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=word)
        creadas.append(f"pal_{slug}")

    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    generar_hoja(creadas, Path("/tmp/hoja_p79.png"))
    print(f"OK: generadas {len(creadas)} láminas nuevas de P7.9 en {LAMINAS_DIR.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
