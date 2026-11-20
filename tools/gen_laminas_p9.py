#!/usr/bin/env python3
"""P9.5 · Genera las láminas nuevas necesarias para palabras de P9.2 sin lámina.

No sobrescribe ninguna lámina existente en git.
Fuentes permitidas: Fluent Emoji Flat (MIT) y dibujo vectorial propio estilo Lúa,
sin texto ni dígitos. Genera también la hoja de contactos en
docs/capturas/hoja_contactos_p9.png.
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
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BLANCO,
    GRIS,
    GRIS_OSCURO,
    LAMINAS_DIR,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
    ROJO,
    ROJO_OSCURO,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    E,
    F,
    L,
    P,
    R,
    escribir_cd,
    escribir_fluent_directo,
    fl,
    fondo_cielo,
    fondo_mesa,
    fondo_prado,
    fondo_sala,
    frecha,
)
from tpr_tandas.comun_tpr import (  # noqa: E402
    DORADO,
    NARANJA_OSCURO,
    ondas_sonido,
)

SCRIPT_REF = "tools/gen_laminas_p9.py"

FLUENT_DIRECTOS: list[tuple[str, str, str, str, str]] = [
    ("agree", "agree", "Check mark button", "acordo", "Marca de confirmación para acordar una hipótesis."),
    ("animal", "animal", "Rabbit", "animal", "Animal pequeño para comparar desplazamientos e trazos."),
    ("appear", "appear", "Sparkles", "aparecer", "Destellos luminosos cuando surge una nueva señal."),
    ("basket", "basket", "Basket", "cesta", "Cesta para guardar, sacar y explorar objetos en 0-2."),
    ("color", "color", "Artist palette", "cor", "Paleta con varios colores para mezclar e comparar."),
    ("day", "day", "Sun", "día", "Sol brillante representando la luz del día."),
    ("earth", "earth", "Globe showing europe-africa", "terra", "Planeta Tierra para experimentos de luz e sombra."),
    ("launch", "launch", "Rocket", "lanzar", "Impulso ascendente al lanzar una pieza o avión."),
    ("note", "note", "Musical note", "nota", "Nota musical de una serie sonora."),
    ("paint", "paint", "Paintbrush", "pintar", "Pincel con pintura para combinar pigmentos."),
    ("quick", "quick", "High voltage", "rápido", "Símbolo de rapidez para probar cambios de ritmo."),
    ("sound", "sound", "Speaker high volume", "son", "Altavoz con ondas indicando intensidad sonora."),
    ("spoon", "spoon", "Spoon", "culler", "Cuchara metálica para observar reflejos e resonancia."),
    ("suitcase", "suitcase", "Luggage", "maleta", "Maleta preparada con objetos ordenados dentro."),
    ("train", "train", "Locomotive", "tren", "Locomotora para probar movimiento e secuencia."),
    ("understand", "understand", "Light bulb", "comprender", "Bombilla iluminada tras comprobar cómo funciona."),
    ("upside", "upside", "Counterclockwise arrows button", "ao revés", "Flechas curvas que invierten la orientación."),
    ("view", "view", "Eyes", "vista", "Ojos observando desde el punto de vista del experimento."),
    ("wall", "wall", "Brick", "parede", "Superficie sólida de ladrillo para rebotar ou proxectar."),
]

ESCENAS_CD: dict[str, tuple[str, str, list[dict], str]] = {
    "code": (
        "code",
        "D",
        fondo_sala()
        + [
            R(26, 20, 108, 60, 10, BLANCO, TINTA, 2.4),
            E(48, 38, 9, 9, AZUL, TINTA, 2),
            R(66, 33, 28, 10, 4, AMARILLO, TINTA, 2),
            E(108, 38, 9, 9, ROJO, TINTA, 2),
            R(40, 56, 26, 10, 4, VERDE, TINTA, 2),
            E(80, 61, 9, 9, NARANJA_OSCURO, TINTA, 2),
            R(98, 56, 22, 10, 4, AZUL, TINTA, 2),
        ],
        "Tarjeta con secuencia de círculos y barras de colores como código visual sin texto.",
    ),
    "come": (
        "come",
        "C",
        fondo_prado()
        + fl("Footprints", 22, 34, 42)
        + frecha((70, 56), (112, 56), NARANJA_OSCURO, 3)
        + [E(126, 56, 14, 14, AMARILLO, TINTA, 2.2)],
        "Huellas avanzando en la dirección de la flecha hacia el punto de encuentro.",
    ),
    "distance": (
        "distance",
        "C",
        fondo_prado()
        + fl("Straight ruler", 44, 24, 72)
        + [
            E(28, 68, 8, 8, ROJO, TINTA, 2),
            E(132, 68, 8, 8, VERDE, TINTA, 2),
            L("M38 68 L122 68", NARANJA_OSCURO, 3),
        ],
        "Regla recta entre dos marcadores destacando la distancia recorrida.",
    ),
    "follow": (
        "follow",
        "C",
        fondo_sala()
        + [
            E(42, 50, 15, 15, AZUL, TINTA, 2.2),
            E(104, 50, 15, 15, VERDE, TINTA, 2.2),
        ]
        + frecha((62, 50), (85, 50), NARANJA_OSCURO, 2.8)
        + fl("Footprints", 118, 28, 30),
        "Pieza verde siguiendo a la pieza azul en fila.",
    ),
    "front": (
        "front",
        "D",
        fondo_mesa()
        + [
            R(66, 22, 48, 48, 8, AZUL, TINTA, 2.2),
            E(56, 62, 16, 16, ROJO, TINTA, 2.2),
        ]
        + frecha((24, 62), (37, 62), NARANJA_OSCURO, 2.8),
        "Pelota roja colocada claramente delante del bloque grande.",
    ),
    "glass": (
        "glass",
        "D",
        fondo_mesa()
        + [
            P([[54, 18], [106, 18], [98, 76], [62, 76]], AGUA, AZUL_OSCURO, 2.6),
            E(80, 18, 26, 6, "#e0f2fe", AZUL_OSCURO, 2.4),
            L("M66 28 L72 68", BLANCO, 3),
            L("M90 32 L88 64", BLANCO, 2),
        ],
        "Vaso de cristal transparente sobre la mesa con brillos verticales.",
    ),
    "hear": (
        "hear",
        "C",
        fondo_sala()
        + fl("Ear", 32, 16, 64)
        + ondas_sonido(100, 48, AZUL_OSCURO),
        "Oreja recibiendo ondas concéntricas de sonido.",
    ),
    "height": (
        "height",
        "C",
        fondo_mesa()
        + [
            R(50, 56, 36, 16, 4, VERDE, TINTA, 2),
            R(50, 40, 36, 16, 4, AMARILLO, TINTA, 2),
            R(50, 24, 36, 16, 4, ROJO, TINTA, 2),
        ]
        + fl("Up-down arrow", 98, 22, 46),
        "Torre de tres bloques junto a flecha vertical mostrando la altura.",
    ),
    "inside": (
        "inside",
        "C",
        fondo_mesa()
        + fl("Basket", 36, 26, 84)
        + [E(80, 42, 14, 14, ROJO, TINTA, 2.2)],
        "Pelota roja metida dentro de la cesta abierta.",
    ),
    "miss": (
        "miss",
        "D",
        fondo_mesa()
        + [
            E(34, 48, 12, 12, AZUL, TINTA, 2.2),
            E(64, 48, 12, 12, VERDE, TINTA, 2.2),
            E(94, 48, 12, 12, AMARILLO, TINTA, 2.2),
            E(126, 48, 12, 12, "#fff8ec", GRIS_OSCURO, 2.4),
        ],
        "Tres círculos colocados y un cuarto hueco vacío que falta.",
    ),
    "move": (
        "move",
        "C",
        fondo_prado()
        + fl("Running shoe", 30, 26, 64)
        + frecha((98, 54), (138, 54), NARANJA_OSCURO, 3),
        "Zapatilla en movimiento con flecha hacia delante.",
    ),
    "pace": (
        "pace",
        "C",
        fondo_prado()
        + fl("Footprints", 24, 30, 48)
        + fl("Hourglass not done", 88, 20, 52),
        "Huellas junto a reloj de arena representando el ritmo y el paso.",
    ),
    "paper": (
        "paper",
        "D",
        fondo_mesa()
        + [
            P([[48, 14], [98, 14], [114, 30], [114, 78], [48, 78]], BLANCO, TINTA, 2.4),
            P([[98, 14], [98, 30], [114, 30]], GRIS, TINTA, 2.2),
        ],
        "Hoja de papel blanca con esquina doblada, limpia y sin texto.",
    ),
    "plane": (
        "plane",
        "D",
        fondo_cielo()
        + [
            P([[32, 54], [128, 26], [88, 78]], BLANCO, TINTA, 2.4),
            P([[32, 54], [128, 26], [70, 58]], GRIS, TINTA, 2),
            L("M16 66 Q44 74 62 62", AZUL_OSCURO, 2.4),
        ],
        "Avión de papel doblado planeando por el cielo con estela suave.",
    ),
    "sharp": (
        "sharp",
        "D",
        fondo_mesa()
        + [
            P([[40, 72], [80, 18], [120, 72]], DORADO, TINTA, 2.4),
            L("M80 18 L80 72", BLANCO, 2.6),
            E(80, 18, 6, 6, ROJO, TINTA, 1.8),
        ],
        "Punta doblada muy definida con arista marcada.",
    ),
    "side": (
        "side",
        "D",
        fondo_mesa()
        + [
            R(50, 26, 48, 48, 8, AZUL, TINTA, 2.2),
            E(118, 50, 13, 13, VERDE, TINTA, 2.2),
        ]
        + frecha((138, 32), (122, 42), NARANJA_OSCURO, 2.6),
        "Pieza verde situada en el lateral del cubo azul.",
    ),
    "stand": (
        "stand",
        "C",
        fondo_mesa()
        + [
            R(52, 22, 20, 50, 5, AZUL, TINTA, 2.2),
            R(88, 22, 20, 50, 5, VERDE, TINTA, 2.2),
        ]
        + fl("Check mark button", 118, 22, 28),
        "Dos bloques erguidos firmemente de pie sobre la mesa.",
    ),
    "stay": (
        "stay",
        "C",
        fondo_mesa()
        + [
            E(80, 72, 28, 8, VERDE, VERDE_OSCURO, 2),
            R(60, 34, 40, 38, 8, AMARILLO, TINTA, 2.2),
        ]
        + fl("Check mark button", 112, 26, 28),
        "Bloque estable asentado en su sitio sin moverse.",
    ),
    "thick": (
        "thick",
        "D",
        fondo_mesa()
        + [
            R(26, 26, 108, 10, 4, GRIS, TINTA, 2),
            R(26, 46, 108, 24, 6, MADERA, MADERA_OSCURA, 2.6),
        ]
        + frecha((140, 32), (140, 58), NARANJA_OSCURO, 2.8),
        "Dos barras paralelas comparando una fina arriba y otra gruesa abajo.",
    ),
    "three": (
        "three",
        "D",
        fondo_mesa()
        + [
            E(80, 28, 14, 14, ROJO, TINTA, 2.2),
            E(52, 56, 14, 14, AZUL, TINTA, 2.2),
            E(108, 56, 14, 14, VERDE, TINTA, 2.2),
        ],
        "Tres fichas iguales formando un grupo de tres sin dígitos.",
    ),
    "two": (
        "two",
        "D",
        fondo_mesa()
        + [
            E(56, 48, 16, 16, AZUL, TINTA, 2.2),
            E(104, 48, 16, 16, AMARILLO, TINTA, 2.2),
        ],
        "Dos fichas grandes juntas formando una pareja sin dígitos.",
    ),
    "watch": (
        "watch",
        "C",
        fondo_sala()
        + fl("Magnifying glass tilted left", 46, 18, 66)
        + [E(68, 56, 12, 12, VERDE, TINTA, 2)],
        "Lupa observando de cerca un elemento del experimento.",
    ),
}


def generar_hoja(claves: list[str], out_png: Path) -> None:
    import hoja_contactos as hc  # noqa: E402

    cols = 6
    rows = (len(claves) + cols - 1) // cols
    tile_w, tile_h = 220, 170
    sheet = Image.new("RGB", (cols * tile_w, rows * tile_h), "#f8fafc")
    dr = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for idx, clave in enumerate(sorted(claves)):
        c = idx % cols
        r = idx // cols
        x0, y0 = c * tile_w, r * tile_h
        thumb = hc.render_clave(clave, 200, 125)
        sheet.paste(thumb, (x0 + 10, y0 + 8))
        dr.rectangle([x0 + 2, y0 + 2, x0 + tile_w - 3, y0 + tile_h - 3], outline="#cbd5e1", width=1)
        dr.text((x0 + 8, y0 + 138), clave[:28], fill="#0f172a", font=font)
    out_png.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_png)
    print(f"OK: {out_png} ({len(claves)} láminas)")


def main() -> int:
    tracked = set(
        subprocess.check_output(
            ["git", "ls-files", "assets/brand/laminas/"], cwd=RAIZ, text=True
        ).splitlines()
    )
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]

    creadas: list[str] = []
    for word, slug, fl_name, ur, porque in FLUENT_DIRECTOS:
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_fluent_directo(pezas, key, slug, fl_name, ur, porque)
        creadas.append(f"pal_{slug}")

    for word, (slug, cd, formas, porque) in ESCENAS_CD.items():
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_cd(pezas, key, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=word)
        creadas.append(f"pal_{slug}")

    MAPA_PATH.write_text(
        json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    generar_hoja(creadas, RAIZ / "docs/capturas/hoja_contactos_p9.png")
    print(f"OK: generadas {len(creadas)} láminas nuevas de P9.5")
    return 0


if __name__ == "__main__":
    sys.exit(main())
