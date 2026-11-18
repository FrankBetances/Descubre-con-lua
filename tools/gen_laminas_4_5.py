#!/usr/bin/env python3
"""Generador de las 181 láminas faltantes de 4-5 años (P2.2, O-20261111-4).

Cada pieza de `curso_4_5` en `assets/content/leccions/leccions.json` queda
revisada contra su palabra en inglés, su significado gl/es y su gesto (`xesto`),
clasificada en:
  - U: banco directo (Fluent Emoji Flat MIT / dnizfor MIT limpio)
  - R: banco o propia elegida por gesto/concepto (Fluent Flat / propia Lúa)
  - C: composición de objetos del banco + pose Fluent o figura articulada Lúa
  - D: dibujo vectorial propio en estilo Lúa

Salida:
  - assets/brand/laminas/pal_<slug>.json (vectores nuevos/compuestos/banco)
  - assets/brand/laminas/pal_<slug>.webp (solo rasters verificados dnizfor)
  - assets/content/laminas/palabras_laminas.json (esquema completo O-20261111-4)
  - docs/revision_4_5_lecciones.csv (clasificación U/R/C/D y estado revisado)
"""
from __future__ import annotations

import csv
import json
import math
import re
import shutil
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

import banco_a_lamina as bal  # noqa: E402
from gen_laminas_palabras import (  # noqa: E402
    DEBUXOS as DEBUXOS_P21,
    E,
    F,
    HERBA,
    HERBAB,
    L,
    P,
    PEL,
    PELB,
    R,
    TINTA,
    frecha,
    nino,
    sol,
    tubo,
)

LAMINAS_DIR = RAIZ / "assets/brand/laminas"
MAPA_PATH = RAIZ / "assets/content/laminas/palabras_laminas.json"
LECCIONS_PATH = RAIZ / "assets/content/leccions/leccions.json"
CSV_4_5_PATH = RAIZ / "docs/revision_4_5_lecciones.csv"

FLUENT_ROOT = Path("/tmp/banco_src/fluentui-emoji/assets")
DNIZFOR_ROOT = Path("/tmp/banco_src/dnizfor")

SHA_FLUENT = "1ffb34c752ecf5d402f04cfb4b392c77f57c54bc"
SHA_DNIZFOR = "eae41b7c6cd85da0ca4171ce79eb115971b533de"
SHA_PROPIA = "6be3d38b"

# Colores auxiliares
AGUA = "#38bdf8"
AGUA_OSCURO = "#0284c7"
MAR_PROF = "#1e3a8a"
TIERRA = "#b45309"
TIERRA_CLARA = "#d97706"
BARRO = "#78350f"
MADERA = "#c27c3e"
MADERA_OSCURA = "#7c471b"
AMARILLO = "#facc15"
AMARILLO_OSCURO = "#ca8a04"
ROJO = "#ef4444"
ROJO_OSCURO = "#991b1b"
VERDE = "#22c55e"
VERDE_OSCURO = "#15803d"
AZUL = "#3b82f6"
AZUL_OSCURO = "#1e3a8a"
MORADO = "#8b5cf6"
NUBE = "#f1f5f9"
NUBE_B = "#94a3b8"
GRIS = "#cbd5e1"
GRIS_OSCURO = "#475569"
BLANCO = "#ffffff"


def _cargar_fluent_index() -> dict[str, Path]:
    idx: dict[str, Path] = {}
    for p in FLUENT_ROOT.glob("*/Flat/*.svg"):
        idx[p.parent.parent.name] = p
    for p in FLUENT_ROOT.glob("*/Default/Flat/*.svg"):
        idx.setdefault(p.parent.parent.parent.name, p)
    return idx


def _cargar_dnizfor_index() -> dict[str, Path]:
    data = json.loads((DNIZFOR_ROOT / "data/data.json").read_text(encoding="utf-8"))
    return {x["word"].strip().lower(): DNIZFOR_ROOT / x["image"] for x in data}


FLUENT_SVGS = _cargar_fluent_index()
DNIZFOR_IMGS = _cargar_dnizfor_index()
_FLUENT_CACHE: dict[str, list[dict]] = {}


def _fluent_formas(nombre: str) -> list[dict]:
    if nombre not in _FLUENT_CACHE:
        p = FLUENT_SVGS.get(nombre)
        if not p:
            raise KeyError(f"Fluent Flat no encontrado: {nombre!r}")
        lam = bal.svg_a_lamina(p.read_text(encoding="utf-8"), paleta="exacta")
        _FLUENT_CACHE[nombre] = lam["formas"]
    return _FLUENT_CACHE[nombre]


def _num_str(v: float) -> str:
    r = round(v, 2)
    return str(int(r)) if r == int(r) else f"{r:.2f}".rstrip("0").rstrip(".")


def _transformar_d(d: str, dx: float, dy: float, sc: float, flip_x: bool = False) -> str:
    tokens = re.findall(r"[MLQCZ]|-?\d*\.?\d+", d)
    out: list[str] = []
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t in ("M", "L", "Q", "C", "Z"):
            out.append(t)
            i += 1
            continue
        x = float(tokens[i])
        y = float(tokens[i + 1])
        if flip_x:
            x = 100.0 - x
        out.append(_num_str(dx + x * sc))
        out.append(_num_str(dy + y * sc))
        i += 2
    return " ".join(out)


def fl(nombre: str, dx: float, dy: float, size: float, flip_x: bool = False) -> list[dict]:
    """Inserta un emoji Fluent Flat (origen 100x100) dentro de [dx, dy, size, size]."""
    sc = size / 100.0
    formas: list[dict] = []
    for orig in _fluent_formas(nombre):
        f = dict(orig)
        tp = f["t"]
        if tp == "elipse":
            cx = (100.0 - f["cx"]) if flip_x else f["cx"]
            f["cx"] = round(dx + cx * sc, 2)
            f["cy"] = round(dy + f["cy"] * sc, 2)
            f["rx"] = round(f["rx"] * sc, 2)
            f["ry"] = round(f["ry"] * sc, 2)
        elif tp == "rrect":
            rx0 = (100.0 - (f["x"] + f["w"])) if flip_x else f["x"]
            f["x"] = round(dx + rx0 * sc, 2)
            f["y"] = round(dy + f["y"] * sc, 2)
            f["w"] = round(f["w"] * sc, 2)
            f["h"] = round(f["h"] * sc, 2)
            if "r" in f:
                f["r"] = round(f["r"] * sc, 2)
        elif tp == "poli":
            pts = []
            for px, py in f["p"]:
                nx = (100.0 - px) if flip_x else px
                pts.append([round(dx + nx * sc, 2), round(dy + py * sc, 2)])
            f["p"] = pts
        elif tp == "ruta":
            f["d"] = _transformar_d(f["d"], dx, dy, sc, flip_x=flip_x)
        if "sw" in f and f["sw"]:
            f["sw"] = round(max(0.6, f["sw"] * sc), 2)
        formas.append(f)
    return formas


def fondo_prado() -> list[dict]:
    return [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 74, 160, 26, 0, HERBA), L("M0 74 L160 74", HERBAB, 2.5)]


def fondo_mar() -> list[dict]:
    return [
        R(0, 0, 160, 100, 0, "#e0f2fe"),
        R(0, 60, 160, 40, 0, AGUA),
        L("M0 62 Q20 55 40 62 Q60 69 80 62 Q100 55 120 62 Q140 69 160 62", AGUA_OSCURO, 2.5),
    ]


def fondo_mesa() -> list[dict]:
    return [R(0, 0, 160, 100, 0, "#dbeafe"), R(0, 72, 160, 28, 0, MADERA), L("M0 72 L160 72", MADERA_OSCURA, 2.5)]


def _nino_ovillo(cx: float, cy: float) -> list[dict]:
    """Niño acurrucado hecho una bolita (bulto de brazos, espalda y cabeza con pelo)."""
    return [
        F(f"M{cx - 22} {cy + 14} C{cx - 26} {cy - 8} {cx + 6} {cy - 10} {cx + 12} {cy + 4} L{cx + 6} {cy + 14} Z", ROJO, ROJO_OSCURO, 2),
        E(cx + 14, cy + 7, 8, 8, PEL, PELB, 2),
        F(f"M{cx + 7} {cy + 5} C{cx + 7} {cy - 4} {cx + 22} {cy - 4} {cx + 23} {cy + 6} C{cx + 19} {cy + 1} {cx + 12} {cy + 1} {cx + 7} {cy + 5} Z", "#5a3a1a"),
        L(f"M{cx + 15} {cy + 9} Q{cx + 17} {cy + 11} {cx + 19} {cy + 9}", TINTA, 1.3),
        L(f"M{cx + 2} {cy + 4} L{cx + 8} {cy + 15} L{cx - 4} {cy + 16}", PELB, 3.5),
    ]


def molinillo(cx: float, cy: float, r: float = 18) -> list[dict]:
    o = [L(f"M{cx} {cy} L{cx} {cy + r + 16}", MADERA_OSCURA, 3)]
    cols = [(ROJO, ROJO_OSCURO), (AMARILLO, AMARILLO_OSCURO), (AZUL, AZUL_OSCURO), (VERDE, VERDE_OSCURO)]
    for idx, (c, s) in enumerate(cols):
        ang = math.radians(idx * 90 + 25)
        x1 = cx + r * math.cos(ang)
        y1 = cy + r * math.sin(ang)
        x2 = cx + r * 0.72 * math.cos(ang + 0.75)
        y2 = cy + r * 0.72 * math.sin(ang + 0.75)
        o.append(P([(cx, cy), (x1, y1), (x2, y2)], c, s, 1.8))
    o.append(E(cx, cy, 3, 3, BLANCO, TINTA, 1.5))
    return o


def pano(x: float, y: float, w: float = 34, h: float = 22, color: str = "#fef3c7", borde: str = "#d97706") -> list[dict]:
    return [
        R(x, y, w, h, 4, color, borde, 2.2),
        L(f"M{x + 5} {y + 6} L{x + w - 5} {y + 6}", "#cbd5e1", 1.5),
        L(f"M{x + 5} {y + h - 6} L{x + w - 5} {y + h - 6}", "#cbd5e1", 1.5),
    ]


def gotas(pts: list[tuple[float, float]]) -> list[dict]:
    o = []
    for gx, gy in pts:
        o.append(F(f"M{gx} {gy} C{gx - 3.5} {gy + 5} {gx - 3} {gy + 9} {gx} {gy + 9} "
                   f"C{gx + 3} {gy + 9} {gx + 3.5} {gy + 5} {gx} {gy} Z", AGUA, AGUA_OSCURO, 1.2))
    return o


def _copos_nieve(pts: list[tuple[float, float]], color: str = "#0284c7") -> list[dict]:
    o = []
    for x, y in pts:
        o += [
            L(f"M{x - 5} {y} L{x + 5} {y}", color, 2.0),
            L(f"M{x} {y - 5} L{x} {y + 5}", color, 2.0),
            L(f"M{x - 3.5} {y - 3.5} L{x + 3.5} {y + 3.5}", color, 1.6),
            L(f"M{x - 3.5} {y + 3.5} L{x + 3.5} {y - 3.5}", color, 1.6),
        ]
    return o


def _notas(pts: list[tuple[float, float]]) -> list[dict]:
    o = []
    for nx, ny in pts:
        o += [E(nx, ny, 3, 2.2, MORADO), L(f"M{nx + 2.5} {ny} L{nx + 2.5} {ny - 9} L{nx + 7} {ny - 7}", MORADO, 2)]
    return o


# ── Banco directo U/R de Fluent Emoji Flat ───────────────────────────────
FLUENT_DIRECTOS: dict[str, tuple[str, str, str, str]] = {
    # clave_en: (slug, nombre_fluent, clasificacion_U_R, porque)
    "crab": ("crab", "Crab", "U", "Cangrejo rojo con pinzas abiertas, en estilo Fluent Flat."),
    "goodbye": ("goodbye", "Waving hand", "R", "Mano abierta saludando al despedirse: coincide con el gesto de adiós."),
    "backpack": ("backpack", "Backpack", "U", "Mochila escolar de frente con asas y bolsillo, coincidencia directa."),
    "bell": ("bell", "Bell", "U", "Campana dorada, coincidencia directa con el timbre o campana."),
    "bear": ("bear", "Bear", "U", "Oso pardo de frente, coincidencia directa."),
    "school": ("school", "School", "U", "Edificio de escuela con reloj y bandera, coincidencia directa."),
    "sleepy": ("sleepy", "Sleepy face", "R", "Cara con ojos cerrados y gota de sueño, coincide con cabeza caída."),
    "hurt": ("hurt", "Face with head-bandage", "R", "Cara con venda en la cabeza mostrando daño o dolor."),
    "boar": ("boar", "Boar", "U", "Jabalí de perfil con colmillos, coincidencia directa."),
    "leg": ("leg", "Leg", "U", "Pierna flexionada completa con pie, coincidencia directa."),
    "stopwatch": ("stopwatch", "Stopwatch", "U", "Cronómetro con botón superior y aguja roja, coincidencia directa."),
    "crimson leaf": ("crimson_leaf", "Maple leaf", "R", "Hoja de color rojo carmesí intenso, coincidencia visual."),
    "drum": ("drum", "Drum", "U", "Tambor con sus dos baquetas, coincidencia directa."),
    "night": ("night", "Night with stars", "R", "Cielo nocturno oscuro con luna y estrellas: noche."),
    "sun": ("sun", "Sun", "U", "Sol luminoso con rayos alrededor, coincidencia directa."),
    "cloud": ("cloud", "Cloud", "U", "Nube blanca esponjosa, coincidencia directa."),
    "map": ("map", "World map", "R", "Mapa desplegado del mundo, coincidencia directa con mapa."),
    "showery": ("showery", "Cloud with rain", "R", "Nube de chubascos dejando caer gotas de lluvia."),
    "cloudy": ("cloudy", "Sun behind large cloud", "R", "Nube grande tapando al sol: tiempo nublado."),
    "firefighter": ("firefighter", "Firefighter", "U", "Persona bombera con casco y uniforme, coincidencia directa."),
    "police officer": ("police_officer", "Police officer", "U", "Persona policía con gorra y uniforme, coincidencia directa."),
    "wolf": ("wolf", "Wolf", "U", "Lobo gris de frente con orejas en punta, coincidencia directa."),
    "fox": ("fox", "Fox", "U", "Zorro naranja de frente con orejas en punta y hocico blanco."),
    "coat": ("coat", "Coat", "U", "Abrigo cálido con solapas y botones, coincidencia directa."),
    "bee": ("bee", "Honeybee", "U", "Abeja con rayas y alas, coincidencia directa."),
    "flower": ("flower", "Blossom", "R", "Flor abierta con pétalos claros y centro dorado."),
    "hat": ("hat", "Womans hat", "R", "Sombrero de ala ancha con cinta, coincidencia directa."),
    "stormy": ("stormy", "Cloud with lightning and rain", "R", "Nube oscura de tormenta con rayo y lluvia."),
    "secret": ("secret", "Shushing face", "R", "Cara llevándose el dedo a los labios: secreto, igual que el gesto."),
    "frisbee": ("frisbee", "Flying disc", "R", "Disco volador (frisbee) inclinado en vuelo."),
    "alert": ("alert", "Eyes", "R", "Ojos bien abiertos mirando atento: coincide con el gesto de abrir mucho los ojos."),
    "thank you so much": ("thank_you_so_much", "Folded hands", "R", "Dos manos juntas en señal de gratitud: coincide con el gesto."),
}


# ── Banco directo dnizfor MIT (inspeccionadas una a una sin marcas/personajes)
DNIZFOR_DIRECTOS: dict[str, tuple[str, str, str, str]] = {
    # clave_en: (slug, dnizfor_word, clasificacion, porque)
    "summer": ("summer", "summer", "U", "Escena de verano en la playa con sol brillante y niños bañándose."),
    "winter": ("winter", "winter", "U", "Paisaje de invierno con nieve, muñeco de nieve y niños abrigados."),
    "examine": ("examine", "examine", "U", "Niño examinando de cerca una mariquita con una lupa."),
    "stage": ("stage", "stage", "U", "Escenario de teatro con telón abierto y foco central."),
    "cliff": ("cliff", "cliff", "U", "Acantilado rocoso alto junto al mar."),
    "muddy": ("muddy", "mud", "R", "Charco grande de barro salpicando: embarrado."),
    "windy": ("windy", "wind", "R", "Viento fuerte agitando árbol, cometa, molinillo y velero."),
}


# ── Reutilizadas propias Lúa R ───────────────────────────────────────────
PROPIAS_REUTILIZADAS: dict[str, tuple[str, str]] = {
    "red": ("vermello", "Mancha clara de pintura roja del set propio: coincide con rojo."),
    "seabird": ("gaivota", "Gaviota de perfil del set propio sobre fondo marino: ave marina."),
}


# ── Composiciones C y dibujos propios D ──────────────────────────────────
def _escenas_4_5() -> dict[str, tuple[str, str, list[dict], str]]:
    """clave_en -> (slug, clasificacion C/D, formas_160x100, porque)."""
    m: dict[str, tuple[str, str, list[dict], str]] = {}

    # U01 · Playa y vuelta al cole
    m["row your boat through the big waves"] = (
        "row_boat_waves", "C",
        fondo_mar()
        + fl("Water wave", 8, 52, 34)
        + fl("Water wave", 116, 52, 34)
        + fl("Person rowing boat", 46, 20, 68),
        "Persona remando en barca en medio de grandes olas (Fluent Flat combinado).",
    )
    m["swim like a fast fish in the ría"] = (
        "swim_fast_fish", "C",
        fondo_mar()
        + fl("Fish", 98, 60, 34, flip_x=True)
        + nino((52, 62), (38, 64), (20, 66), [[(68, 60)], [(56, 74)]], [[(8, 66)], [(10, 72)]], mira=1)
        + frecha((54, 42), (96, 42), "#ffffff", 3.5),
        "Niño nadando a brazadas junto a un pez rápido en la ría.",
    )
    m["dive deep and find a white shell"] = (
        "dive_white_shell", "C",
        [R(0, 0, 160, 100, 0, "#bae6fd"), R(0, 78, 160, 22, 0, "#fde68a")]
        + fl("Spiral shell", 96, 62, 30)
        + nino((56, 52), (48, 38), (38, 22), [[(74, 58)], [(64, 64)]], [[(24, 14)], [(28, 10)]], mira=1)
        + [E(64, 34, 2.5, 2.5, BLANCO, AGUA_OSCURO, 1.2), E(68, 24, 3, 3, BLANCO, AGUA_OSCURO, 1.2)],
        "Niño buceando hacia el fondo arenoso para encontrar una concha blanca.",
    )
    m["holiday"] = (
        "holiday", "C",
        fondo_prado()
        + fl("Sun", 14, 8, 26)
        + fl("Beach with umbrella", 92, 24, 52)
        + fl("Luggage", 16, 46, 30)
        + nino((66, 26), (66, 38), (66, 54), [[(50, 20)], [(82, 20)]], [[(58, 70)], [(74, 70)]]),
        "Niño saltando con los brazos arriba junto a sombrilla de playa y maleta: vacaciones.",
    )
    m["this is the cloth that drinks water"] = (
        "cloth_drinks_water", "C",
        fondo_mesa()
        + [E(80, 70, 38, 8, AGUA, AGUA_OSCURO, 2)]
        + pano(54, 44, 52, 28, "#fef08a", "#ca8a04")
        + gotas([(66, 64), (80, 62), (94, 64)])
        + frecha((80, 70), (80, 52), AGUA_OSCURO, 3),
        "Paño amarillo posado en un charco absorbiendo el agua hacia arriba.",
    )
    m["heavy bag"] = (
        "heavy_bag", "C",
        fondo_prado()
        + nino((64, 34), (66, 46), (72, 64), [[(82, 54)], [(78, 58)]], [[(64, 80), (62, 90)], [(78, 80), (82, 90)]], mira=1)
        + fl("Backpack", 82, 34, 46)
        + fl("Sweat droplets", 40, 20, 22),
        "Niño inclinado con esfuerzo cargando una mochila pesada con gotas de sudor.",
    )
    m["motionless"] = (
        "motionless", "D",
        fondo_prado()
        + nino((80, 26), (80, 38), (80, 58), [[(70, 58)], [(90, 58)]], [[(75, 86)], [(85, 86)]], ollos="abertos")
        + [L("M52 24 L52 86", GRIS_OSCURO, 2), L("M108 24 L108 86", GRIS_OSCURO, 2)],
        "Niño quieto completamente erguido y recto entre dos líneas fijas: inmóvil.",
    )
    m["the bag that we used stayed dry"] = (
        "bag_stayed_dry", "C",
        fondo_prado()
        + gotas([(20, 16), (34, 24), (126, 18), (142, 26)])
        + fl("Umbrella", 48, 6, 64)
        + fl("Backpack", 60, 46, 40),
        "Mochila protegida bajo paraguas mientras la lluvia cae a los lados: se quedó seca.",
    )
    m["walk like a sleepy bear with your heavy bag"] = (
        "walk_sleepy_bear_bag", "C",
        fondo_prado()
        + fl("Bear", 36, 30, 54)
        + fl("Backpack", 82, 36, 40)
        + fl("Sleepy face", 18, 12, 26),
        "Oso con gesto somnoliento caminando con mochila pesada a cuestas.",
    )
    m["the bell rings: run to the circle and freeze"] = (
        "bell_run_circle_freeze", "C",
        fondo_prado()
        + [E(96, 82, 44, 11, "#fde68a", "#d97706", 2.5)]
        + fl("Bell", 14, 10, 32)
        + nino((96, 30), (96, 42), (96, 60), [[(82, 46)], [(110, 46)]], [[(91, 80)], [(101, 80)]])
        + frecha((36, 60), (66, 60), AZUL_OSCURO, 3),
        "Campana sonando arriba y niño que corre hacia la alfombra circular y queda quieto.",
    )
    m["open your bag, take out your smock and smile"] = (
        "open_bag_smock_smile", "C",
        fondo_mesa()
        + fl("Backpack", 14, 34, 48)
        + fl("T-shirt", 64, 36, 44)
        + nino((128, 36), (128, 48), (128, 68), [[(116, 56)], [(140, 56)]], [[(122, 86)], [(134, 86)]]),
        "Mochila abierta de donde sale un babi azul y niño sonriendo contento.",
    )
    m["can i help you"] = (
        "can_i_help_you", "C",
        fondo_prado()
        + nino((48, 32), (48, 44), (48, 64), [[(68, 48)], [(36, 56)]], [[(42, 86)], [(54, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1)
        + nino((114, 34), (114, 46), (114, 66), [[(98, 52)], [(124, 54)]], [[(108, 86)], [(120, 86)]], mira=-1)
        + fl("Package", 80, 46, 26),
        "Niño tendiendo la mano para ayudar a otro que sostiene una caja.",
    )
    m["the teddy who hurt his leg is fine"] = (
        "teddy_hurt_leg_fine", "C",
        fondo_prado()
        + fl("Teddy bear", 48, 22, 62)
        + fl("Adhesive bandage", 78, 62, 24)
        + fl("Red heart", 112, 18, 24),
        "Peluche de oso con tirita curada en la pierna y corazón alegre: ya está bien.",
    )
    m["wait your turn, please"] = (
        "wait_your_turn", "D",
        fondo_prado()
        + [R(36, 58, 30, 12, 3, MADERA, MADERA_OSCURA, 2), L("M40 70 L40 88", MADERA_OSCURA, 3), L("M62 70 L62 88", MADERA_OSCURA, 3)]
        + nino((50, 28), (50, 40), (50, 56), [[(60, 54)], [(42, 54)]], [[(60, 62), (62, 84)], [(56, 62), (58, 84)]], mira=1)
        + nino((106, 30), (106, 42), (106, 62), [[(118, 46)], [(96, 52)]], [[(100, 86)], [(112, 86)]], camisa=(AZUL, AZUL_OSCURO)),
        "Niño sentado tranquilo con las manos en el regazo esperando su turno.",
    )
    m["put your feet into the boots"] = (
        "put_feet_into_boots", "C",
        fondo_mesa()
        + fl("Hiking boot", 26, 44, 46)
        + fl("Hiking boot", 88, 44, 46)
        + frecha((49, 14), (49, 42), AZUL_OSCURO, 3.5)
        + frecha((111, 14), (111, 42), AZUL_OSCURO, 3.5),
        "Dos botas preparadas debajo de sendas flechas hacia abajo: meter los pies en las botas.",
    )
    m["which is the cloth that works"] = (
        "which_cloth_works", "C",
        fondo_mesa()
        + pano(16, 44, 46, 26, "#fef08a", "#ca8a04")
        + gotas([(32, 24), (44, 24)])
        + [E(39, 58, 12, 5, AGUA, AGUA_OSCURO, 1.5)]
        + pano(96, 44, 46, 26, "#e2e8f0", GRIS_OSCURO)
        + gotas([(106, 74), (132, 74)]),
        "Dos paños lado a lado: uno absorbe las gotas y otro las deja resbalar.",
    )

    # U02 · Bosque de otoño: ardilla, jabalí, perro y corazón
    m["squirrel"] = (
        "squirrel", "D",
        fondo_prado()
        + [
            F("M92 78 C126 78 134 30 106 24 C86 20 84 44 98 54 C88 60 84 72 92 78 Z", "#c2410c", "#7c2d12", 2.5),
            E(72, 66, 16, 18, "#ea580c", "#7c2d12", 2.5),
            E(64, 40, 13, 12, "#ea580c", "#7c2d12", 2.5),
            P([(62, 30), (65, 18), (70, 30)], "#ea580c", "#7c2d12", 2),
            E(59, 38, 2, 2.3, "#1f2937"),
            E(56, 60, 6, 4, "#f97316", "#7c2d12", 2),
            E(52, 64, 5, 6, "#92400e", "#451a03", 2),
        ],
        "Ardilla pelirroja con gran cola curva sujetando una bellota entre las patas.",
    )
    m["climb"] = (
        "climb", "D",
        fondo_prado()
        + [R(82, 8, 20, 88, 2, MADERA, MADERA_OSCURA, 2.5), E(92, 10, 44, 16, VERDE, VERDE_OSCURO, 2.5)]
        + nino((62, 34), (66, 46), (68, 62), [[(84, 34)], [(84, 48)]], [[(80, 68)], [(76, 78)]], mira=1)
        + frecha((40, 68), (40, 26), VERDE_OSCURO, 3.5),
        "Niño trepando por el tronco de un árbol con flecha ascendente.",
    )
    m["i like listening to your heart"] = (
        "listening_to_heart", "C",
        fondo_prado()
        + nino((48, 32), (48, 44), (48, 64), [[(66, 48)], [(36, 56)]], [[(42, 86)], [(54, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=1)
        + nino((108, 32), (108, 44), (108, 64), [[(98, 56)], [(120, 56)]], [[(102, 86)], [(114, 86)]], mira=-1)
        + fl("Beating heart", 66, 36, 30),
        "Niño escuchando el pecho de su compañero mientras late un gran corazón.",
    )
    m["hide"] = (
        "hide", "D",
        fondo_prado()
        + nino((80, 26), (80, 38), (80, 58), [[(68, 52), (76, 56)], [(92, 52), (84, 56)]], [[(74, 86)], [(86, 86)]])
        + [E(94, 58, 8, 8, AMARILLO, AMARILLO_OSCURO, 2), L("M106 50 Q114 48 110 56", TINTA, 2)],
        "Niño escondiendo detrás de la espalda un objeto para que no se vea: esconder.",
    )
    m["sly"] = (
        "sly", "C",
        fondo_prado()
        + fl("Fox", 50, 20, 56)
        + [L("M58 46 L70 43", TINTA, 2.5), L("M90 43 L102 46", TINTA, 2.5)],
        "Zorro con mirada astuta guiñando ligeramente los ojos: gesto de pillo.",
    )
    m["nimble-footed"] = (
        "nimble_footed", "C",
        fondo_prado()
        + nino((76, 26), (74, 38), (72, 56), [[(90, 44)], [(56, 48)]], [[(94, 70), (108, 76)], [(52, 74), (38, 82)]], mira=1)
        + [L("M24 72 L42 72", AZUL_OSCURO, 2.5), L("M20 80 L36 80", AZUL_OSCURO, 2.5)],
        "Niño moviendo los pies muy deprisa con trazos de velocidad en los pies.",
    )
    m["where does it hurt"] = (
        "where_does_it_hurt", "C",
        fondo_prado()
        + nino((46, 32), (46, 44), (46, 64), [[(64, 50)], [(34, 56)]], [[(40, 86)], [(52, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1)
        + fl("Stethoscope", 76, 24, 36)
        + fl("Teddy bear", 104, 36, 44),
        "Niño con estetoscopio señalando al peluche para preguntar dónde le duele.",
    )
    m["we want to run"] = (
        "we_want_to_run", "C",
        fondo_prado()
        + nino((52, 32), (50, 44), (46, 62), [[(66, 46)], [(34, 48)]], [[(62, 76), (70, 86)], [(32, 78), (22, 84)]], mira=1)
        + nino((106, 32), (104, 44), (100, 62), [[(120, 46)], [(88, 48)]], [[(116, 76), (124, 86)], [(86, 78), (76, 84)]], camisa=(AZUL, AZUL_OSCURO), mira=1)
        + frecha((128, 52), (150, 52), VERDE_OSCURO, 3),
        "Dos niños corriendo hacia delante con flecha de impulso: queremos correr.",
    )
    m["hop like a squirrel and collect the chestnuts"] = (
        "hop_squirrel_chestnuts", "C",
        fondo_prado()
        + fl("Chestnut", 20, 64, 24)
        + fl("Chestnut", 118, 64, 24)
        + nino((76, 24), (76, 36), (76, 52), [[(68, 44)], [(84, 44)]], [[(68, 68)], [(86, 68)]])
        + [L("M52 72 Q68 54 84 72", AMARILLO_OSCURO, 2.5)],
        "Niño dando brincos cortos junto a dos castañas en el suelo.",
    )
    m["the wild boar is coming: freeze"] = (
        "wild_boar_freeze", "C",
        fondo_prado()
        + fl("Boar", 18, 36, 50, flip_x=True)
        + nino((114, 28), (114, 40), (114, 60), [[(102, 54)], [(126, 54)]], [[(108, 86)], [(120, 86)]], mira=-1),
        "Jabalí entrando por la izquierda y niño parado inmóvil como una estatua.",
    )
    m["climb the oak tree and hide your nuts"] = (
        "climb_oak_hide_nuts", "C",
        fondo_prado()
        + fl("Deciduous tree", 76, 10, 74)
        + fl("Chestnut", 104, 44, 20)
        + nino((52, 42), (56, 54), (58, 70), [[(74, 44)], [(74, 58)]], [[(72, 74)], [(70, 84)]], mira=1),
        "Niño trepando al roble junto a las castañas escondidas en la copa.",
    )
    m["doctor / vet"] = (
        "doctor_vet", "C",
        fondo_prado()
        + fl("Health worker", 26, 18, 56)
        + fl("Stethoscope", 82, 18, 32)
        + fl("Dog", 104, 42, 42),
        "Profesional sanitario con estetoscopio atendiendo a un perro: doctor o veterinario.",
    )
    m["running makes it beat fast"] = (
        "running_beats_fast", "C",
        fondo_prado()
        + nino((42, 32), (40, 44), (36, 62), [[(56, 46)], [(24, 50)]], [[(52, 76), (60, 86)], [(22, 78), (14, 84)]], mira=1)
        + fl("Beating heart", 88, 22, 52),
        "Niño corriendo acompañado de un corazón latiendo rápido.",
    )
    m["the dog is behind the tree"] = (
        "dog_behind_tree", "C",
        fondo_prado()
        + fl("Dog", 86, 42, 42)
        + fl("Deciduous tree", 40, 8, 76),
        "Árbol en primer plano y el perro asomando por detrás del tronco.",
    )
    m["gentle"] = (
        "gentle", "C",
        fondo_prado()
        + fl("Cat", 76, 38, 48)
        + nino((44, 34), (44, 46), (44, 66), [[(70, 52)], [(34, 58)]], [[(38, 86)], [(50, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1)
        + fl("Red heart", 60, 16, 22),
        "Niño acariciando suavemente a un gato con cuidado y cariño.",
    )
    m["let's stop to listen"] = (
        "stop_to_listen", "C",
        fondo_prado()
        + nino((64, 30), (64, 42), (64, 62), [[(76, 32)], [(52, 56)]], [[(58, 86)], [(70, 86)]])
        + fl("Ear", 96, 26, 38)
        + _notas([(134, 24), (144, 34)]),
        "Niño quieto llevándose la mano a la oreja para escuchar notas suaves.",
    )
    m["you said the cat had four legs"] = (
        "cat_four_legs", "C",
        fondo_prado()
        + fl("Cat", 50, 18, 62)
        + [L("M58 84 L58 92", ROJO, 2.5), L("M72 84 L72 92", ROJO, 2.5), L("M88 84 L88 92", ROJO, 2.5), L("M102 84 L102 92", ROJO, 2.5)],
        "Gato de cuerpo entero con sus cuatro patas señaladas debajo sobre la hierba.",
    )
    m["roll down the hill like a chestnut"] = (
        "roll_down_hill_chestnut", "C",
        [R(0, 0, 160, 100, 0, "#e0f2fe"), P([(0, 26), (160, 88), (160, 100), (0, 100)], HERBA, HERBAB, 2.5)]
        + fl("Chestnut", 52, 34, 32)
        + frecha((88, 52), (132, 74), "#ffffff", 3.5),
        "Castaña rodando cuesta abajo por la ladera verde con flecha descendente.",
    )
    m["the hedgehog wakes up: freeze and curl up small"] = (
        "hedgehog_curl_small", "C",
        fondo_prado()
        + fl("Hedgehog", 20, 40, 48)
        + _nino_ovillo(112, 70),
        "Erizo despierto junto a niño hecho una bolita pequeña en el suelo.",
    )
    m["pop out and dance around the fire"] = (
        "dance_around_fire", "C",
        fondo_prado()
        + fl("Fire", 62, 36, 36)
        + nino((34, 32), (34, 44), (34, 62), [[(20, 34)], [(48, 36)]], [[(28, 84)], [(40, 84)]], mira=1)
        + nino((126, 32), (126, 44), (126, 62), [[(112, 36)], [(140, 34)]], [[(120, 84)], [(132, 84)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos niños bailando alegres con los brazos en alto alrededor de una hoguera.",
    )
    m["she asked where the snake went"] = (
        "where_snake_went", "C",
        fondo_prado()
        + nino((42, 30), (42, 42), (42, 62), [[(60, 44)], [(30, 56)]], [[(36, 86)], [(48, 86)]], mira=1)
        + fl("Snake", 96, 44, 44),
        "Niño señalando hacia la hierba por donde se desliza la serpiente.",
    )
    m["first we wash, then we eat"] = (
        "first_wash_then_eat", "C",
        fondo_mesa()
        + fl("Soap", 16, 30, 38)
        + gotas([(24, 18), (44, 18)])
        + frecha((64, 50), (88, 50), VERDE_OSCURO, 4)
        + fl("Fork and knife with plate", 98, 24, 48),
        "Secuencia de dos pasos: primero jabón y agua para lavar, flecha hacia plato para comer.",
    )
    m["do not worry, be gentle"] = (
        "do_not_worry_gentle", "C",
        fondo_prado()
        + nino((46, 32), (46, 44), (46, 64), [[(86, 46)], [(34, 56)]], [[(40, 86)], [(52, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1)
        + nino((110, 32), (110, 44), (110, 64), [[(98, 56)], [(122, 56)]], [[(104, 86)], [(116, 86)]], mira=-1)
        + fl("Red heart", 68, 10, 22),
        "Niño calmando con mano suave en el hombro a su compañero: no te preocupes.",
    )
    m["you told me it didn't fit"] = (
        "didnt_fit", "C",
        fondo_mesa()
        + fl("Wastebasket", 62, 44, 42)
        + fl("Basketball", 54, 14, 48),
        "Pelota grande apoyada encima de un cesto pequeño sin poder caber dentro.",
    )

    # U03 · Invierno, lupa, temperatura
    m["look at the stone closely"] = (
        "look_stone_closely", "C",
        fondo_mesa()
        + fl("Rock", 74, 44, 42)
        + fl("Magnifying glass tilted right", 42, 22, 44),
        "Lupa acercándose mucho a una piedra gris sobre la mesa: mirar de cerca.",
    )
    m["colder"] = (
        "colder", "C",
        [R(0, 0, 160, 100, 0, "#dbeafe")]
        + fl("Cold face", 48, 20, 58)
        + _copos_nieve([(24, 24), (132, 26), (26, 74), (134, 72)]),
        "Cara tiritando rodeada de copos de nieve: más frío.",
    )
    m["frozen solid"] = (
        "frozen_solid", "C",
        [R(0, 0, 160, 100, 0, "#e0f2fe")]
        + fl("Ice", 52, 22, 56)
        + _copos_nieve([(26, 28), (130, 28), (30, 76), (130, 76)]),
        "Bloque compacto de hielo helado entre copos de nieve: congelado del todo.",
    )
    m["brightest"] = (
        "brightest", "C",
        [R(0, 0, 160, 100, 0, "#1e293b")]
        + fl("Sun", 44, 14, 72)
        + [L("M80 4 L80 12", AMARILLO, 3), L("M80 88 L80 96", AMARILLO, 3), L("M18 50 L36 50", AMARILLO, 3), L("M124 50 L142 50", AMARILLO, 3)],
        "Sol deslumbrante con rayos largos sobre fondo oscuro: el más brillante.",
    )
    m["pick up the lens"] = (
        "pick_up_lens", "C",
        fondo_mesa()
        + fl("Magnifying glass tilted right", 60, 28, 44)
        + frecha((80, 68), (80, 18), AZUL_OSCURO, 3.5),
        "Lupa elevándose sobre la mesa con flecha hacia arriba: coge la lupa.",
    )
    m["dance freely while the drum sings"] = (
        "dance_drum_sings", "C",
        fondo_prado()
        + fl("Drum", 18, 40, 44)
        + _notas([(56, 30), (66, 20)])
        + nino((110, 28), (110, 40), (110, 58), [[(92, 32)], [(128, 30)]], [[(102, 80)], [(122, 76)]], camisa=(MORADO, AZUL_OSCURO)),
        "Tambor con notas musicales y niño bailando libremente con brazos abiertos.",
    )
    m["cold winter night: curl up and do not move"] = (
        "cold_winter_night_curl", "C",
        [R(0, 0, 160, 100, 0, "#0f172a"), R(0, 76, 160, 24, 0, "#cbd5e1")]
        + fl("Crescent moon", 18, 10, 28)
        + _copos_nieve([(128, 22), (142, 42)], color="#bae6fd")
        + _nino_ovillo(82, 62),
        "Noche fría con luna y nieve, y niño acurrucado e inmóvil en el suelo.",
    )
    m["sunlight! stand up and stretch tall"] = (
        "sunlight_stretch_tall", "C",
        fondo_prado()
        + fl("Sun", 14, 8, 38)
        + nino((86, 26), (86, 38), (86, 58), [[(74, 12)], [(98, 12)]], [[(81, 86)], [(91, 86)]]),
        "Sol brillante iluminando al niño de pie estirando los brazos bien arriba.",
    )
    m["why are you putting the bandage? because the cat is sick"] = (
        "why_bandage_cat_sick", "C",
        fondo_mesa()
        + fl("Cat", 38, 28, 52)
        + fl("Adhesive bandage", 94, 40, 34)
        + fl("Thermometer", 18, 18, 30),
        "Gato malito con termómetro mientras se le acerca una venda.",
    )
    m["look for a hair"] = (
        "look_for_hair", "C",
        fondo_mesa()
        + [L("M56 64 Q76 48 96 66 Q110 76 122 58", "#1f2937", 2.5)]
        + fl("Magnifying glass tilted right", 52, 22, 48),
        "Lupa enfocando de cerca un pelo suelto ondulado sobre la superficie.",
    )
    m["i put on my boots because it is raining"] = (
        "boots_because_raining", "C",
        fondo_prado()
        + fl("Cloud with rain", 14, 6, 46)
        + nino((80, 24), (80, 36), (80, 56), [[(66, 52)], [(94, 52)]], [[(74, 74)], [(86, 74)]], mira=1)
        + fl("Hiking boot", 62, 66, 24)
        + fl("Hiking boot", 82, 66, 24),
        "Niño calzándose las botas de agua mientras cae la lluvia detrás.",
    )
    m["first we check the heart, then we wrap the bandage"] = (
        "first_heart_then_bandage", "C",
        fondo_mesa()
        + fl("Stethoscope", 14, 24, 38)
        + fl("Red heart", 36, 40, 22)
        + frecha((66, 50), (92, 50), AZUL_OSCURO, 4)
        + fl("Adhesive bandage", 100, 26, 42),
        "Secuencia: primero estetoscopio sobre el corazón, flecha hacia la venda.",
    )
    m["put the lens down gently"] = (
        "put_lens_down", "C",
        fondo_mesa()
        + fl("Magnifying glass tilted right", 58, 38, 42)
        + frecha((80, 10), (80, 36), VERDE_OSCURO, 3.5),
        "Flecha suave hacia abajo indicando dejar la lupa sobre la mesa.",
    )

    # U04 · Tormenta y nube
    m["shake"] = (
        "shake", "D",
        fondo_prado()
        + nino((80, 26), (80, 38), (80, 58), [[(60, 36)], [(100, 36)]], [[(72, 86)], [(88, 86)]])
        + [L("M48 34 Q42 44 48 54", AZUL_OSCURO, 2.5), L("M112 34 Q118 44 112 54", AZUL_OSCURO, 2.5)],
        "Niño agitando brazos y cuerpo con líneas de vibración a ambos lados.",
    )
    m["it's heavy, isn't it"] = (
        "its_heavy_isnt_it", "C",
        fondo_prado()
        + nino((62, 34), (62, 46), (64, 66), [[(78, 52)], [(52, 56)]], [[(54, 86)], [(72, 86)]], mira=1)
        + fl("Rock", 78, 36, 48)
        + fl("Sweat droplets", 40, 20, 20),
        "Niño esforzándose con gotas de sudor mientras levanta una gran piedra pesada.",
    )
    m["underpass"] = (
        "underpass", "D",
        fondo_prado()
        + [R(22, 22, 116, 62, 10, "#94a3b8", GRIS_OSCURO, 3), F("M42 84 C42 36 118 36 118 84 Z", "#e0f2fe", GRIS_OSCURO, 2.5), R(20, 74, 120, 26, 0, HERBA)]
        + nino((80, 56), (76, 66), (72, 76), [[(88, 70)], [(66, 72)]], [[(68, 86)], [(80, 86)]], r=7),
        "Paso inferior arqueado con niño pasando agachado por debajo.",
    )
    m["you can carry it, can't you"] = (
        "you_can_carry_it", "C",
        fondo_prado()
        + nino((60, 30), (60, 42), (60, 62), [[(78, 48)], [(76, 54)]], [[(54, 86)], [(68, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1)
        + fl("Package", 78, 34, 38)
        + frecha((120, 50), (144, 50), VERDE_OSCURO, 3),
        "Niño sonriente llevando con soltura una caja en los brazos mientras camina.",
    )
    m["walk together like one big cloud"] = (
        "walk_together_cloud", "C",
        fondo_prado()
        + fl("Cloud", 50, 4, 58)
        + nino((52, 42), (52, 52), (52, 68), [[(66, 58)], [(42, 60)]], [[(48, 86)], [(56, 86)]], camisa=(AZUL, AZUL_OSCURO), r=7)
        + nino((80, 42), (80, 52), (80, 68), [[(66, 58)], [(94, 58)]], [[(76, 86)], [(84, 86)]], r=7)
        + nino((108, 42), (108, 52), (108, 68), [[(94, 58)], [(118, 60)]], [[(104, 86)], [(112, 86)]], camisa=(VERDE, VERDE_OSCURO), r=7),
        "Tres niños caminando juntos cogidos bajo una gran nube blanca.",
    )
    m["the storm is here: run and hide under the umbrella"] = (
        "storm_hide_umbrella", "C",
        fondo_prado()
        + fl("Cloud with lightning and rain", 16, 4, 44)
        + fl("Umbrella", 54, 18, 64)
        + nino((76, 56), (76, 66), (76, 76), [[(68, 72)], [(84, 72)]], [[(70, 88)], [(82, 88)]], r=7)
        + nino((98, 56), (98, 66), (98, 76), [[(90, 72)], [(106, 72)]], [[(92, 88)], [(104, 88)]], camisa=(AZUL, AZUL_OSCURO), r=7),
        "Nube de tormenta con rayos y niños agachados resguardándose bajo un paraguas.",
    )
    m["the sun comes back: shake the water off"] = (
        "sun_back_shake_water", "C",
        fondo_prado()
        + fl("Sun", 14, 8, 36)
        + nino((80, 28), (80, 40), (80, 60), [[(60, 38)], [(100, 38)]], [[(74, 86)], [(86, 86)]])
        + gotas([(52, 44), (108, 44), (48, 62), (112, 62)]),
        "Sol brillante de vuelta mientras el niño sacude los brazos soltando gotas de agua.",
    )
    m["do you know who is holding it"] = (
        "who_is_holding_it", "C",
        fondo_prado()
        + nino((48, 32), (48, 44), (48, 64), [[(66, 50)], [(38, 56)]], [[(42, 86)], [(54, 86)]], mira=1)
        + nino((112, 32), (112, 44), (112, 64), [[(94, 50)], [(122, 56)]], [[(106, 86)], [(118, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + fl("Balloon", 66, 16, 30),
        "Dos niños sujetando juntos un globo mientras se miran preguntándose quién lo sostiene.",
    )

    # U05 · Oficios y bosque de noche
    m["baker"] = (
        "baker", "C",
        fondo_mesa()
        + fl("Cook", 36, 16, 62)
        + fl("Bread", 94, 38, 44),
        "Panadero con gorro blanco junto a hogaza de pan recién horneada.",
    )
    m["it didn't fall, did it"] = (
        "didnt_fall", "D",
        fondo_mesa()
        + [R(64, 54, 32, 18, 2, ROJO, ROJO_OSCURO, 2),
           R(68, 36, 24, 18, 2, AMARILLO, AMARILLO_OSCURO, 2),
           R(72, 20, 16, 16, 2, AZUL, AZUL_OSCURO, 2)]
        + nino((34, 36), (34, 48), (34, 64), [[(48, 44)], [(22, 52)]], [[(28, 72)], [(40, 72)]], mira=1),
        "Torre firme de bloques en pie sobre la mesa observada por un niño: no se cayó.",
    )
    m["if it had rained, we would have found mud"] = (
        "if_rained_mud", "C",
        fondo_prado()
        + fl("Cloud with rain", 52, 6, 48)
        + [E(80, 78, 44, 12, BARRO, "#451a03", 2.5), E(64, 72, 6, 3, BARRO), E(98, 70, 5, 3, BARRO)],
        "Nube de lluvia cayendo sobre un gran charco marrón de barro.",
    )
    m["sneak"] = (
        "sneak", "D",
        fondo_prado()
        + nino((88, 42), (76, 50), (66, 60), [[(98, 54)], [(64, 58)]], [[(78, 72), (82, 86)], [(56, 74), (50, 86)]], mira=1)
        + [L("M106 60 L124 60", GRIS_OSCURO, 2), L("M110 66 L122 66", GRIS_OSCURO, 2)],
        "Niño agachado caminando silenciosamente de puntillas: andar a hurtadillas.",
    )
    m["mysterious"] = (
        "mysterious", "C",
        [R(0, 0, 160, 100, 0, "#312e81"), R(0, 74, 160, 26, 0, "#1e1b4b")]
        + nino((62, 32), (62, 44), (62, 62), [[(82, 46)], [(46, 50)]], [[(56, 86)], [(68, 86)]], mira=1)
        + fl("Magnifying glass tilted right", 82, 26, 42),
        "Niño en ambiente nocturno mirando atento con lupa a los lados: misterioso.",
    )
    m["knight"] = (
        "knight", "C",
        fondo_prado()
        + nino((64, 30), (64, 42), (64, 62), [[(84, 50)], [(48, 52)]], [[(58, 86)], [(70, 86)]], camisa=(GRIS, GRIS_OSCURO), mira=1)
        + [P([(54, 24), (64, 12), (74, 24)], ROJO, ROJO_OSCURO, 2), R(54, 22, 20, 8, 3, GRIS, GRIS_OSCURO, 2)]
        + fl("Shield", 84, 34, 42),
        "Niño con casco con penacho sosteniendo un gran escudo de caballero.",
    )
    m["if we had used boots, we would have stayed clean"] = (
        "boots_stayed_clean", "C",
        fondo_prado()
        + [E(80, 82, 46, 10, BARRO, "#451a03", 2)]
        + fl("Hiking boot", 46, 44, 34)
        + fl("Hiking boot", 80, 44, 34)
        + [L("M34 40 L42 32", VERDE_OSCURO, 2.5), L("M122 40 L114 32", VERDE_OSCURO, 2.5)],
        "Botas altas sobre charco de barro manteniendo limpios los pies.",
    )
    m["gallop like a wild horse"] = (
        "gallop_wild_horse", "C",
        fondo_prado()
        + fl("Horse", 18, 28, 56, flip_x=True)
        + nino((106, 28), (104, 40), (100, 58), [[(122, 44)], [(90, 46)]], [[(120, 72), (126, 86)], [(84, 72), (74, 82)]], mira=1),
        "Caballo galopando junto a niño dando zancadas de galope con brazos recogidos.",
    )
    m["the wolf is watching: freeze"] = (
        "wolf_watching_freeze", "C",
        fondo_prado()
        + fl("Wolf", 18, 32, 48)
        + fl("Eyes", 64, 20, 26)
        + nino((114, 28), (114, 40), (114, 60), [[(102, 54)], [(126, 54)]], [[(108, 86)], [(120, 86)]], mira=-1),
        "Lobo observando atento a un niño congelado inmóvil sin moverse.",
    )
    m["sneak quietly like a fox in the woods"] = (
        "sneak_fox_woods", "C",
        fondo_prado()
        + fl("Evergreen tree", 12, 12, 54)
        + fl("Evergreen tree", 104, 14, 52)
        + fl("Fox", 46, 44, 44)
        + nino((88, 52), (82, 60), (76, 70), [[(98, 62)], [(72, 64)]], [[(86, 80)], [(68, 82)]], r=7, mira=1),
        "Zorro y niño caminando agachados con sigilo entre árboles del bosque.",
    )
    m["look outside"] = (
        "look_outside", "C",
        [R(0, 0, 160, 100, 0, "#fef3c7"), R(44, 14, 72, 58, 4, "#bae6fd", MADERA_OSCURA, 4), L("M80 14 L80 72", MADERA_OSCURA, 3), L("M44 43 L116 43", MADERA_OSCURA, 3)]
        + fl("Sun", 52, 18, 22)
        + fl("Deciduous tree", 84, 34, 30)
        + nino((26, 48), (28, 60), (28, 78), [[(44, 56)], [(16, 68)]], [[(22, 92)], [(34, 92)]], mira=1),
        "Niño mirando hacia fuera a través de una ventana abierta al sol y los árboles.",
    )
    m["if you had jumped, it would have splashed"] = (
        "jumped_splashed", "C",
        fondo_prado()
        + [E(80, 80, 44, 11, AGUA, AGUA_OSCURO, 2.5)]
        + nino((80, 20), (80, 32), (80, 48), [[(64, 24)], [(96, 24)]], [[(70, 62)], [(90, 62)]])
        + gotas([(42, 60), (118, 60), (50, 48), (110, 48)]),
        "Niño saltando sobre un charco azul haciendo saltar gotas de agua alrededor.",
    )

    # U06 · Puentes, río y lluvia
    m["whose turn is it"] = (
        "whose_turn", "C",
        fondo_prado()
        + nino((42, 32), (42, 44), (42, 64), [[(62, 46)], [(30, 54)]], [[(36, 86)], [(48, 86)]], mira=1)
        + nino((118, 32), (118, 44), (118, 64), [[(98, 46)], [(130, 54)]], [[(112, 86)], [(124, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + fl("Red circle", 70, 54, 20)
        + frecha((62, 32), (98, 32), AMARILLO_OSCURO, 3),
        "Dos niños mirándose alternando el turno con la pelota en medio.",
    )
    m["we walk across the bridge"] = (
        "walk_across_bridge", "D",
        [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 66, 160, 34, 0, AGUA),
         F("M12 72 Q80 34 148 72 L148 86 Q80 48 12 86 Z", MADERA, MADERA_OSCURA, 3)]
        + nino((74, 22), (74, 34), (74, 48), [[(86, 40)], [(62, 42)]], [[(80, 60)], [(68, 60)]], r=7, mira=1)
        + frecha((94, 34), (130, 42), VERDE_OSCURO, 3),
        "Puente arqueado sobre el agua con un niño cruzándolo caminando hacia el otro lado.",
    )
    m["what would have happened without water"] = (
        "without_water", "C",
        [R(0, 0, 160, 100, 0, "#fef3c7"), R(0, 74, 160, 26, 0, "#d97706")]
        + fl("Wilted flower", 56, 22, 52)
        + [L("M24 84 L48 78", "#78350f", 2), L("M112 80 L138 86", "#78350f", 2)],
        "Flor marchita inclinada sobre tierra seca sin agua.",
    )

    # U07 · Abejas, flores y molinillos de viento
    m["fly"] = (
        "fly_action", "D",
        fondo_prado()
        + nino((80, 24), (80, 36), (80, 54), [[(44, 34)], [(116, 34)]], [[(72, 74)], [(88, 74)]])
        + [L("M34 38 Q40 28 46 34", AZUL_OSCURO, 2), L("M114 34 Q120 28 126 38", AZUL_OSCURO, 2)],
        "Niño con los brazos extendidos en cruz como alas planeando: verbo volar.",
    )
    m["land"] = (
        "land_action", "D",
        fondo_prado()
        + nino((80, 34), (80, 46), (80, 62), [[(64, 62)], [(96, 62)]], [[(72, 74), (70, 86)], [(88, 74), (90, 86)]])
        + frecha((38, 22), (38, 68), VERDE_OSCURO, 3.5),
        "Niño bajando despacio los brazos y flexionando las rodillas al posarse en el suelo.",
    )
    m["if we had made it bigger, it would spin faster now"] = (
        "bigger_spin_faster", "C",
        fondo_prado()
        + molinillo(40, 44, 12)
        + frecha((60, 44), (82, 44), AZUL_OSCURO, 3)
        + molinillo(118, 38, 24)
        + [L("M90 22 Q118 8 146 22", AZUL_OSCURO, 2.5)],
        "Molinillo pequeño comparado con uno grande que gira más rápido con arco de giro.",
    )
    m["sweeter"] = (
        "sweeter", "C",
        [R(0, 0, 160, 100, 0, "#fff1f2")]
        + fl("Honey pot", 26, 26, 48)
        + fl("Strawberry", 84, 26, 48),
        "Tarro de miel y fresa madura juntos: más dulce.",
    )
    m["it is raining hard"] = (
        "raining_hard", "C",
        [R(0, 0, 160, 100, 0, "#cbd5e1"), R(0, 80, 160, 20, 0, AGUA)]
        + fl("Cloud with rain", 20, 6, 56)
        + fl("Cloud with rain", 84, 6, 56)
        + gotas([(32, 60), (50, 66), (76, 58), (96, 64), (120, 60)]),
        "Dos nubes descargando mucha lluvia intensa con grandes gotas sobre charco.",
    )
    m["if it weren't windy, it wouldn't have moved"] = (
        "if_not_windy_moved", "C",
        fondo_mar()
        + fl("Wind face", 14, 16, 42)
        + fl("Sailboat", 78, 22, 54)
        + frecha((58, 38), (82, 38), "#ffffff", 3),
        "Viento soplando la vela para mover el barco por el mar.",
    )
    m["fly like a busy bee"] = (
        "fly_busy_bee", "C",
        fondo_prado()
        + fl("Honeybee", 24, 18, 44)
        + nino((102, 30), (102, 42), (102, 60), [[(80, 44)], [(124, 44)]], [[(94, 82)], [(110, 82)]]),
        "Abeja volando rápida junto a niño batiendo los brazos cortos a los lados.",
    )
    m["find the red flower and land softly"] = (
        "red_flower_land_softly", "C",
        fondo_prado()
        + fl("Rose", 26, 36, 46)
        + nino((104, 38), (104, 50), (104, 66), [[(88, 60)], [(120, 60)]], [[(96, 78), (94, 88)], [(112, 78), (114, 88)]])
        + frecha((132, 22), (132, 58), ROJO_OSCURO, 3),
        "Flor roja sobre el prado con niño agachándose suavemente al aterrizar.",
    )
    m["sleep in the flower until the sun wakes up"] = (
        "sleep_flower_sun_wakes", "C",
        fondo_prado()
        + fl("Sun", 14, 8, 34)
        + fl("Blossom", 54, 24, 60)
        + nino((84, 54), (84, 66), (84, 76), [[(74, 72)], [(94, 72)]], [[(78, 86)], [(90, 86)]], r=7, ollos="pechados"),
        "Niño quieto con ojos cerrados posado junto a la flor mientras sale el sol.",
    )
    m["if you had blown, it would be turning"] = (
        "if_blown_turning", "C",
        fondo_prado()
        + fl("Wind face", 20, 26, 46)
        + frecha((68, 44), (92, 44), AZUL_OSCURO, 3)
        + molinillo(118, 42, 20),
        "Cara soplando aire directamente hacia un molinillo de colores que gira.",
    )
    m["market stall"] = (
        "market_stall", "C",
        fondo_prado()
        + [R(34, 46, 92, 38, 3, MADERA, MADERA_OSCURA, 2.5),
           P([(26, 26), (134, 26), (126, 12), (34, 12)], ROJO, ROJO_OSCURO, 2.5)]
        + fl("Red apple", 42, 30, 24)
        + fl("Banana", 68, 30, 24)
        + fl("Tangerine", 94, 30, 24),
        "Puesto del mercado con toldo rojo y manzanas, plátanos y naranjas expuestas.",
    )
    m["shopping list"] = (
        "shopping_list", "C",
        fondo_mesa()
        + fl("Spiral notepad", 22, 16, 56)
        + fl("Shopping cart", 82, 22, 56),
        "Libreta de lista de la compra junto a carrito de mercado.",
    )
    m["if we had put it outside, it would be spinning now"] = (
        "put_outside_spinning", "C",
        fondo_prado()
        + fl("Sun", 18, 10, 30)
        + fl("Cloud", 104, 10, 36)
        + molinillo(80, 44, 22)
        + [L("M56 32 Q80 14 104 32", AZUL_OSCURO, 2.5)],
        "Molinillo al aire libre en el jardín girando bajo el sol y el viento.",
    )

    # U08 · Costa, gaviotas, lobo y reciclaje
    m["come under my umbrella"] = (
        "come_under_umbrella", "C",
        fondo_prado()
        + fl("Umbrella with rain drops", 46, 6, 68)
        + nino((66, 52), (66, 62), (66, 76), [[(78, 66)], [(56, 68)]], [[(60, 88)], [(72, 88)]], r=7)
        + nino((94, 52), (94, 62), (94, 76), [[(82, 66)], [(104, 68)]], [[(88, 88)], [(100, 88)]], camisa=(AZUL, AZUL_OSCURO), r=7),
        "Dos niños acercándose juntos debajo del paraguas bajo la lluvia.",
    )
    m["i wish it would thunder"] = (
        "wish_thunder", "C",
        fondo_prado()
        + fl("Cloud with lightning", 54, 8, 56)
        + [L("M112 36 Q126 30 120 46", AMARILLO_OSCURO, 3), L("M42 36 Q30 30 36 46", AMARILLO_OSCURO, 3)],
        "Nube con rayo amarillo y ondas sonoras de trueno en el cielo.",
    )
    m["calm"] = (
        "calm", "D",
        fondo_prado()
        + nino((80, 32), (80, 44), (80, 62), [[(68, 60)], [(92, 60)]], [[(74, 84)], [(86, 84)]], camisa=(VERDE, VERDE_OSCURO), ollos="pechados")
        + [L("M54 44 Q48 52 54 60", AGUA_OSCURO, 2.5), L("M106 44 Q112 52 106 60", AGUA_OSCURO, 2.5)],
        "Niño con ojos cerrados, hombros caídos y respiración tranquila: calma.",
    )
    m["gull chick"] = (
        "gull_chick", "C",
        fondo_mar()
        + fl("Hatching chick", 52, 24, 56),
        "Pollito recién nacido junto a la costa marina: pollo de gaviota.",
    )
    m["i wish we had more rice"] = (
        "wish_more_rice", "C",
        fondo_mesa()
        + fl("Cooked rice", 26, 30, 42)
        + fl("Cooked rice", 80, 18, 58)
        + fl("Spoon", 18, 22, 24),
        "Cuenco pequeño comparado con un cuenco grande lleno de arroz blanco.",
    )
    m["walk calmly like a sheep in the field"] = (
        "walk_calmly_sheep", "C",
        fondo_prado()
        + fl("Ewe", 22, 34, 50, flip_x=True)
        + nino((102, 30), (102, 42), (102, 62), [[(90, 56)], [(114, 56)]], [[(96, 86)], [(108, 86)]], camisa=(VERDE, VERDE_OSCURO)),
        "Oveja tranquila en el prado junto a niño caminando despacio y en calma.",
    )
    m["the hungry wolf wakes up: freeze"] = (
        "hungry_wolf_wakes_freeze", "C",
        fondo_prado()
        + fl("Sun", 10, 6, 26)
        + fl("Wolf", 20, 32, 48)
        + fl("Bone", 66, 56, 26)
        + [L("M96 28 L96 86", AGUA_OSCURO, 2), L("M132 28 L132 86", AGUA_OSCURO, 2)]
        + nino((114, 30), (114, 42), (114, 62), [[(104, 56)], [(124, 56)]], [[(108, 86)], [(120, 86)]]),
        "Sol naciente, lobo hambriento despertando junto a un hueso y niño congelado inmóvil entre barras.",
    )
    m["the wolf sleeps again: tiptoe away"] = (
        "wolf_sleeps_tiptoe_away", "C",
        fondo_prado()
        + fl("Wolf", 20, 40, 48)
        + fl("Sleepy face", 28, 12, 24)
        + nino((106, 32), (104, 44), (102, 62), [[(116, 50)], [(92, 52)]], [[(110, 82)], [(96, 82)]], mira=1)
        + frecha((122, 52), (146, 52), VERDE_OSCURO, 3),
        "Lobo dormido a la izquierda y niño alejándose despacio de puntillas hacia la derecha.",
    )
    m["if only the storm were louder"] = (
        "storm_louder", "C",
        [R(0, 0, 160, 100, 0, "#334155")]
        + fl("Cloud with lightning and rain", 46, 12, 68)
        + [L("M24 38 Q14 50 24 62", AMARILLO, 3), L("M136 38 Q146 50 136 62", AMARILLO, 3)],
        "Gran nube con rayo y lluvia intensa entre ondas sonoras fuertes.",
    )
    m["are you ready"] = (
        "are_you_ready", "D",
        fondo_prado()
        + [L("M20 88 L140 88", "#ffffff", 4)]
        + nino((56, 30), (56, 42), (56, 62), [[(70, 46)], [(44, 52)]], [[(50, 84)], [(64, 84)]], mira=1)
        + nino((104, 30), (104, 42), (104, 62), [[(118, 46)], [(92, 52)]], [[(98, 84)], [(112, 84)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
        "Dos niños en postura atenta sobre la línea de salida preparados para empezar.",
    )
    m["litter"] = (
        "litter", "C",
        fondo_prado()
        + [R(36, 72, 18, 12, 3, GRIS, GRIS_OSCURO, 2), P([(74, 78), (88, 70), (96, 84)], "#fef3c7", "#d97706", 2),
           R(112, 70, 14, 16, 4, AGUA, AGUA_OSCURO, 2)]
        + nino((76, 30), (76, 42), (76, 58), [[(90, 64)], [(62, 58)]], [[(68, 84)], [(84, 84)]]),
        "Residuos en el suelo del parque con niño agachándose a recoger la basura.",
    )
    m["recycling bin"] = (
        "recycling_bin", "C",
        fondo_prado()
        + fl("Wastebasket", 50, 20, 60)
        + [E(80, 56, 17, 17, BLANCO, "#008463", 2)]
        + fl("Recycling symbol", 65, 41, 30),
        "Contenedor de reciclaje con distintivo blanco y símbolo verde reciclable.",
    )
    m["i wish i had made a longer tube"] = (
        "longer_tube", "D",
        fondo_mesa()
        + [R(22, 28, 36, 14, 4, MADERA, MADERA_OSCURA, 2.5),
           R(22, 54, 104, 14, 4, MADERA, MADERA_OSCURA, 2.5)]
        + frecha((66, 35), (124, 35), AZUL_OSCURO, 3),
        "Comparación de un tubo corto arriba frente a un tubo mucho más largo abajo.",
    )

    # U09 · El nabo enorme, cuerda, ayuda y sombras
    m["pull"] = (
        "pull", "D",
        fondo_prado()
        + [L("M14 58 L108 58", MADERA_OSCURA, 4.5), R(108, 48, 22, 22, 3, TIERRA_CLARA, TIERRA, 2.5)]
        + nino((62, 32), (56, 44), (54, 62), [[(82, 54)], [(74, 58)]], [[(44, 84)], [(66, 84)]], camisa=(ROJO, ROJO_OSCURO), mira=1)
        + frecha((54, 16), (22, 16), ROJO_OSCURO, 3.5),
        "Niño inclinado hacia atrás agarrando y tirando con fuerza de una cuerda hacia sí.",
    )
    m["help"] = (
        "help", "C",
        fondo_prado()
        + nino((46, 32), (46, 44), (46, 62), [[(68, 52)], [(36, 56)]], [[(40, 86)], [(52, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1)
        + nino((114, 32), (114, 44), (114, 62), [[(92, 52)], [(124, 56)]], [[(108, 86)], [(120, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + fl("Package", 64, 42, 32)
        + frecha((80, 40), (80, 16), VERDE_OSCURO, 3.5),
        "Dos niños levantando juntos una caja pesada: ayudar entre dos.",
    )
    m["whisper"] = (
        "whisper", "D",
        fondo_prado()
        + nino((58, 30), (56, 44), (56, 64), [[(74, 42)], [(44, 56)]], [[(50, 86)], [(62, 86)]], mira=1)
        + nino((96, 32), (98, 44), (98, 64), [[(86, 56)], [(110, 56)]], [[(92, 86)], [(104, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + [L("M69 32 L81 30", GRIS_OSCURO, 1.8), L("M69 35 L81 36", GRIS_OSCURO, 1.8)],
        "Niño acercándose muy cerca a la oreja de su compañero para hablar bajito: susurrar.",
    )
    m["splashy"] = (
        "splashy", "D",
        fondo_prado()
        + [E(80, 76, 46, 12, AGUA, AGUA_OSCURO, 2.5)]
        + gotas([(48, 48), (64, 34), (80, 28), (96, 34), (112, 48)]),
        "Charco con muchas gotas saltando hacia arriba: que salpica.",
    )
    m["the sun must have moved"] = (
        "sun_must_have_moved", "C",
        fondo_prado()
        + fl("Sun", 24, 24, 30)
        + [L("M56 34 Q80 14 104 22", AMARILLO_OSCURO, 2.5)]
        + fl("Sun", 104, 12, 34)
        + frecha((66, 26), (98, 20), AMARILLO_OSCURO, 2.5),
        "Arco celeste mostrando el desplazamiento del sol por el cielo.",
    )
    m["all together"] = (
        "all_together", "D",
        fondo_prado()
        + nino((42, 32), (42, 44), (42, 62), [[(28, 22)], [(56, 22)]], [[(36, 86)], [(48, 86)]])
        + nino((80, 32), (80, 44), (80, 62), [[(56, 22)], [(104, 22)]], [[(74, 86)], [(86, 86)]], camisa=(VERDE, VERDE_OSCURO))
        + nino((118, 32), (118, 44), (118, 62), [[(104, 22)], [(132, 22)]], [[(112, 86)], [(124, 86)]], camisa=(AZUL, AZUL_OSCURO)),
        "Tres niños cogidos de la mano levantando todos los brazos juntos.",
    )
    m["fair"] = (
        "fair", "C",
        fondo_mesa()
        + nino((36, 34), (36, 46), (36, 66), [[(52, 54)], [(26, 56)]], [[(30, 86)], [(42, 86)]], mira=1)
        + nino((124, 34), (124, 46), (124, 66), [[(108, 54)], [(134, 56)]], [[(118, 86)], [(130, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + fl("Red apple", 54, 46, 22)
        + fl("Red apple", 84, 46, 22),
        "Dos niños recibiendo exactamente una manzana igual cada uno: reparto justo.",
    )
    m["sturdy"] = (
        "sturdy", "D",
        fondo_mesa()
        + [R(86, 54, 36, 18, 2, ROJO, ROJO_OSCURO, 2.5), R(90, 36, 28, 18, 2, AMARILLO, AMARILLO_OSCURO, 2.5),
           R(94, 18, 20, 18, 2, AZUL, AZUL_OSCURO, 2.5)]
        + nino((44, 34), (44, 46), (44, 64), [[(82, 46)], [(34, 56)]], [[(38, 86)], [(50, 86)]], mira=1)
        + frecha((58, 36), (82, 36), VERDE_OSCURO, 3),
        "Niño empujando lateralmente una torre de bloques sólida que se mantiene firme: resistente.",
    )
    m["brave and kind"] = (
        "brave_and_kind", "C",
        fondo_prado()
        + fl("Shield", 26, 20, 52)
        + fl("Red heart", 82, 22, 50),
        "Escudo protector junto a corazón cálido: valiente y amable.",
    )
    m["your shadow might have grown"] = (
        "shadow_grown", "C",
        fondo_prado()
        + fl("Sun", 14, 14, 32)
        + [E(94, 80, 44, 7, "#334155")]
        + nino((58, 32), (58, 44), (58, 62), [[(48, 56)], [(68, 56)]], [[(53, 82)], [(63, 82)]]),
        "Sol bajo proyectando una sombra muy alargada del niño sobre la hierba.",
    )
    m["pull the rope together: one, two, three"] = (
        "pull_rope_together", "D",
        fondo_prado()
        + [L("M14 58 L146 58", MADERA_OSCURA, 4.5)]
        + nino((42, 30), (40, 42), (40, 60), [[(56, 54)], [(30, 54)]], [[(32, 84)], [(48, 84)]], mira=-1)
        + nino((78, 30), (76, 42), (76, 60), [[(92, 54)], [(66, 54)]], [[(68, 84)], [(84, 84)]], camisa=(VERDE, VERDE_OSCURO), mira=-1)
        + nino((114, 30), (112, 42), (112, 60), [[(128, 54)], [(102, 54)]], [[(104, 84)], [(120, 84)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + frecha((40, 14), (16, 14), ROJO_OSCURO, 3.5),
        "Tres niños alineados tirando juntos hacia la izquierda de una misma cuerda.",
    )
    m["call your friend: come and help us"] = (
        "call_friend_help", "D",
        fondo_prado()
        + [L("M14 60 L80 60", MADERA_OSCURA, 4)]
        + nino((50, 32), (50, 44), (50, 62), [[(74, 34)], [(36, 58)]], [[(44, 86)], [(56, 86)]], mira=1)
        + nino((120, 32), (118, 44), (116, 62), [[(102, 50)], [(130, 52)]], [[(108, 86)], [(124, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + frecha((104, 24), (76, 24), VERDE_OSCURO, 3),
        "Niño haciendo amplio gesto de llamada para que su amigo se acerque a ayudar.",
    )
    m["whisper the secret word to your friend"] = (
        "whisper_secret_friend", "C",
        fondo_prado()
        + nino((54, 32), (52, 44), (52, 62), [[(70, 42)], [(42, 56)]], [[(46, 86)], [(58, 86)]], mira=1)
        + nino((90, 32), (92, 44), (92, 62), [[(80, 56)], [(104, 56)]], [[(86, 86)], [(98, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        + fl("Shushing face", 118, 12, 26),
        "Niño susurrando al oído de su compañero con icono de silencio.",
    )
    m["when it rains, we need boots"] = (
        "when_rains_need_boots", "C",
        fondo_prado()
        + fl("Cloud with rain", 14, 18, 48)
        + frecha((66, 44), (90, 44), AZUL_OSCURO, 3.5)
        + fl("Hiking boot", 94, 24, 38)
        + fl("Hiking boot", 114, 42, 38),
        "Lluvia a la izquierda, flecha hacia el par de botas: cuando llueve necesitamos botas.",
    )
    m["evaporate"] = (
        "evaporate", "D",
        fondo_prado()
        + [E(80, 82, 44, 9, AGUA, AGUA_OSCURO, 2)]
        + [L("M56 70 Q50 56 58 42 Q64 30 56 18", AGUA_OSCURO, 2.5),
           L("M80 70 Q74 54 82 40 Q88 28 80 14", AGUA_OSCURO, 2.5),
           L("M104 70 Q98 56 106 42 Q112 30 104 18", AGUA_OSCURO, 2.5)]
        + frecha((30, 68), (30, 22), AGUA_OSCURO, 3),
        "Charco de agua con espirales de vapor subiendo hacia arriba: evaporarse.",
    )
    m["we should have looked at the shadow earlier"] = (
        "looked_shadow_earlier", "C",
        fondo_prado()
        + fl("Sun", 118, 12, 28)
        + [E(46, 82, 26, 6, "#64748b"), E(94, 82, 18, 5, "#94a3b8")]
        + nino((74, 32), (74, 44), (74, 62), [[(64, 56)], [(84, 56)]], [[(68, 82)], [(80, 82)]]),
        "Dos sombras comparadas junto al niño bajo el sol: sombra más corta antes y más larga después.",
    )
    m["paddle across"] = (
        "paddle_across", "C",
        fondo_mar()
        + fl("Person rowing boat", 46, 18, 60)
        + frecha((112, 50), (146, 50), "#ffffff", 3.5),
        "Persona remando en barca cruzando el agua hacia la otra orilla.",
    )
    m["meet the sea"] = (
        "meet_the_sea", "C",
        [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 62, 160, 38, 0, AGUA),
         P([(0, 62), (76, 62), (56, 100), (0, 100)], HERBA, HERBAB, 2)]
        + fl("Water wave", 92, 46, 46)
        + nino((42, 28), (42, 40), (42, 58), [[(64, 44)], [(30, 52)]], [[(36, 78)], [(48, 78)]], mira=1),
        "Niño llegando por la orilla del prado hasta encontrarse con las olas del mar.",
    )
    m["wade in"] = (
        "wade_in", "D",
        fondo_mar()
        + nino((78, 22), (78, 34), (78, 50), [[(64, 42)], [(92, 42)]], [[(90, 56), (92, 74)], [(68, 64), (66, 78)]], mira=1)
        + gotas([(60, 64), (98, 64)]),
        "Niño entrando en el agua poco profunda levantando las rodillas al caminar.",
    )
    m["the sun can't have gone"] = (
        "sun_cant_have_gone", "C",
        [R(0, 0, 160, 100, 0, "#bae6fd"), R(0, 74, 160, 26, 0, HERBA), L("M0 74 L160 74", HERBAB, 2.5)]
        + fl("Sun", 50, 8, 60)
        + [L("M44 26 L30 16", AMARILLO_OSCURO, 2.5), L("M116 26 L130 16", AMARILLO_OSCURO, 2.5)]
        + fl("Cloud", 18, 32, 40)
        + fl("Cloud", 102, 32, 40),
        "Sol radiante asomando en lo alto entre dos nubes apartadas: el sol no puede haberse ido.",
    )

    # U10 · Batea, mar y despedida
    m["mussel raft"] = (
        "mussel_raft", "D",
        fondo_mar()
        + [R(22, 48, 116, 10, 2, MADERA, MADERA_OSCURA, 2.5),
           L("M44 58 L44 92", GRIS_OSCURO, 3), L("M72 58 L72 92", GRIS_OSCURO, 3),
           L("M100 58 L100 92", GRIS_OSCURO, 3), L("M122 58 L122 92", GRIS_OSCURO, 3)]
        + [E(44, 74, 5, 8, MAR_PROF), E(72, 78, 5, 8, MAR_PROF), E(100, 74, 5, 8, MAR_PROF), E(122, 78, 5, 8, MAR_PROF)],
        "Batea flotante de madera sobre la ría con cuerdas sumergidas llenas de mejillones.",
    )
    m["rope line"] = (
        "rope_line", "D",
        fondo_mar()
        + [L("M80 12 L80 92", MADERA_OSCURA, 4.5)]
        + [E(74, 40, 7, 4, MAR_PROF), E(86, 48, 7, 4, MAR_PROF), E(74, 58, 7, 4, MAR_PROF),
           E(86, 68, 7, 4, MAR_PROF), E(74, 78, 7, 4, MAR_PROF)],
        "Cuerda vertical sumergida en el mar con racimos de mejillones sujetos.",
    )
    m["fishing boat"] = (
        "fishing_boat", "C",
        fondo_mar()
        + fl("Motor boat", 36, 28, 66)
        + fl("Fish", 104, 62, 28, flip_x=True),
        "Barco pesquero navegando en el agua acompañado de un pez.",
    )
    m["the weather was checked every morning"] = (
        "weather_checked_morning", "C",
        [R(0, 0, 160, 100, 0, "#fef3c7"), R(48, 12, 64, 56, 4, "#bae6fd", MADERA_OSCURA, 4)]
        + fl("Sun", 54, 16, 24)
        + fl("Cloud with rain", 82, 30, 26)
        + nino((26, 48), (26, 60), (26, 78), [[(42, 54)], [(16, 68)]], [[(20, 92)], [(32, 92)]], mira=1),
        "Niño mirando el tiempo atmosférico cada mañana por la ventana.",
    )
    m["rushing"] = (
        "rushing", "D",
        fondo_mar()
        + [L("M14 66 Q48 52 82 66 Q116 80 148 66", "#ffffff", 3),
           L("M14 78 Q48 64 82 78 Q116 92 148 78", MAR_PROF, 3)]
        + frecha((28, 36), (132, 36), AGUA_OSCURO, 4)
        + frecha((28, 48), (118, 48), AGUA_OSCURO, 3),
        "Corriente rápida con espumas y flechas veloces avanzando con fuerza.",
    )
    m["deep blue"] = (
        "deep_blue", "D",
        [R(0, 0, 160, 30, 0, "#7dd3fc"), R(0, 30, 160, 32, 0, "#0284c7"), R(0, 62, 160, 38, 0, "#1e3a8a")]
        + [E(48, 72, 3, 3, "#bfdbfe"), E(96, 82, 4, 4, "#bfdbfe")]
        + frecha((132, 14), (132, 86), "#ffffff", 3.5),
        "Capas descendentes hacia el azul profundo del fondo marino con flecha hacia abajo.",
    )
    m["photo book"] = (
        "photo_book", "C",
        fondo_mesa()
        + fl("Open book", 26, 22, 62)
        + fl("Framed picture", 88, 18, 52),
        "Libro abierto junto a fotografía enmarcada: libro de fotos.",
    )
    m["we had the boots put by the door"] = (
        "boots_by_door", "C",
        fondo_mesa()
        + fl("Door", 28, 8, 66)
        + fl("Hiking boot", 94, 42, 38),
        "Puerta de madera con las botas colocadas justo al lado.",
    )
    m["calm sea: move the cloth very slowly"] = (
        "calm_sea_cloth", "D",
        fondo_prado()
        + [F("M34 52 Q80 42 126 52 L126 68 Q80 58 34 68 Z", AGUA, AGUA_OSCURO, 2.5)]
        + nino((24, 30), (24, 42), (24, 62), [[(36, 52)], [(14, 54)]], [[(18, 86)], [(30, 86)]], mira=1)
        + nino((136, 30), (136, 42), (136, 62), [[(124, 52)], [(146, 54)]], [[(130, 86)], [(142, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Dos niños sujetando y ondulando suavemente una tela azul como mar en calma.",
    )
    m["storm! shake the sea with all your strength"] = (
        "storm_shake_sea", "D",
        fondo_prado()
        + [F("M32 46 Q56 26 80 52 Q104 72 128 42 L128 60 Q104 86 80 68 Q56 44 32 62 Z", AGUA_OSCURO, MAR_PROF, 2.5)]
        + nino((24, 28), (24, 40), (24, 60), [[(36, 46)], [(14, 34)]], [[(18, 86)], [(30, 86)]], mira=1)
        + nino((136, 28), (136, 40), (136, 60), [[(124, 44)], [(146, 32)]], [[(130, 86)], [(142, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Dos niños agitando con fuerza una tela azul formando grandes olas de tormenta.",
    )
    m["the sea sleeps: put the cloth down and lie still"] = (
        "sea_sleeps_lie_still", "D",
        fondo_prado()
        + [R(24, 74, 112, 12, 4, AGUA, AGUA_OSCURO, 2)]
        + nino((106, 62), (86, 64), (62, 66), [[(86, 72)], [(90, 56)]], [[(42, 68)], [(44, 74)]], ollos="pechados", mira=1),
        "Tela azul extendida quieta en el suelo y niño tumbado inmóvil y tranquilo.",
    )
    m["the hat is chosen by you"] = (
        "hat_chosen_by_you", "C",
        fondo_mesa()
        + fl("Womans hat", 22, 18, 44)
        + fl("Billed cap", 94, 20, 44)
        + nino((80, 48), (80, 60), (80, 76), [[(56, 42)], [(96, 66)]], [[(74, 90)], [(86, 90)]], r=7),
        "Dos sombreros arriba y niño señalando el sombrero que elige.",
    )
    m["thank you for everything"] = (
        "thank_you_everything", "C",
        [R(0, 0, 160, 100, 0, "#fff1f2")]
        + nino((58, 30), (58, 42), (58, 62), [[(68, 52)], [(46, 56)]], [[(52, 86)], [(64, 86)]])
        + fl("Red heart", 90, 24, 44),
        "Niño llevando la mano al pecho junto a un gran corazón rojo: gracias por todo.",
    )
    m["water balloon"] = (
        "water_balloon", "C",
        fondo_prado()
        + fl("Balloon", 52, 14, 56)
        + gotas([(48, 32), (112, 34), (80, 72)]),
        "Globo rodeado de gotas de agua: globo de agua.",
    )
    m["get your coat zipped"] = (
        "coat_zipped", "C",
        fondo_mesa()
        + fl("Coat", 42, 14, 68)
        + frecha((120, 72), (120, 24), VERDE_OSCURO, 4),
        "Abrigo cerrado con flecha hacia arriba indicando subir la cremallera.",
    )
    m["sand"] = (
        "sand", "C",
        [
            R(0, 0, 160, 100, 0, "#e0f2fe"),
            R(0, 54, 160, 22, 0, AGUA),
            L("M0 57 Q20 51 40 57 Q60 63 80 57 Q100 51 120 57 Q140 63 160 57", AGUA_OSCURO, 2),
            F("M0 68 Q75 56 160 66 L160 100 L0 100 Z", "#fde68a", "#d97706", 2.2),
            F("M42 84 Q78 38 114 84 Z", "#fcd34d", "#d97706", 2.2),
            E(68, 70, 1.5, 1.5, TIERRA),
            E(84, 64, 1.5, 1.5, TIERRA),
            E(92, 76, 1.5, 1.5, TIERRA),
            E(20, 82, 1.5, 1.5, TIERRA),
            E(136, 80, 1.5, 1.5, TIERRA),
        ]
        + fl("Sun", 12, 8, 22)
        + fl("Spiral shell", 18, 60, 26)
        + fl("Bucket", 104, 48, 34),
        "Montículo de arena dorada en la playa con concha y cubo junto al mar, sin personajes.",
    )
    m["temperature"] = (
        "temperature", "C",
        [
            R(0, 0, 80, 100, 0, "#fee2e2"),
            R(80, 0, 80, 100, 0, "#e0f2fe"),
            L("M80 0 L80 100", "#cbd5e1", 1.5),
        ]
        + fl("Sun", 14, 12, 26)
        + fl("Fire", 14, 52, 30)
        + fl("Snowflake", 120, 12, 26)
        + fl("Ice", 116, 52, 30)
        + fl("Thermometer", 48, 16, 64),
        "Termómetro central entre calor (sol y fuego) y frío (copo de nieve y hielo): temperatura.",
    )
    m["protect"] = (
        "protect", "C",
        fondo_prado()
        + gotas([(14, 18), (22, 42), (38, 12)])
        + fl("Shield", 26, 18, 56)
        + fl("Seedling", 88, 38, 36)
        + fl("Blossom", 116, 48, 26),
        "Escudo protegiendo un brote y una flor bajo la lluvia lateral, sin caras ni personajes.",
    )
    return m


def _slug_de(en: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "_", en.lower()).strip("_")
    return s[:48]


def _round_forma(f: dict) -> dict:
    for k in ("cx", "cy", "rx", "ry", "x", "y", "w", "h", "r", "sw"):
        if k in f and isinstance(f[k], float):
            f[k] = round(f[k], 2)
    if "p" in f:
        f["p"] = [[round(a, 2), round(b, 2)] for a, b in f["p"]]
    return f


def main() -> int:
    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]

    escenas_cd = _escenas_4_5()

    # Recoger todas las claves únicas de curso_4_5 (leccions.json)
    orden_keys: dict[str, dict] = {}
    for u in lec["cursos"]["curso_4_5"]["unidades"]:
        for l in u["leccions"]:
            for b in ("xaSabe", "novas", "repasa"):
                for p in l.get(b) or []:
                    k = p["en"].lower().strip(" .!?")
                    orden_keys.setdefault(k, {
                        "en": p["en"], "es": p.get("es", ""), "gl": p.get("gl", ""),
                        "xesto": (p.get("xesto") or {}).get("es", ""),
                    })
            f = l.get("fraseGramatica")
            if f:
                k = f["en"].lower().strip(" .!?")
                orden_keys.setdefault(k, {
                    "en": f["en"], "es": f.get("es", ""), "gl": f.get("gl", ""), "xesto": "",
                })

    print(f"Claves distintas en curso_4_5 lecciones: {len(orden_keys)}")

    clasif_por_clave: dict[str, str] = {}
    counts = {"U": 0, "R": 0, "C": 0, "D": 0}
    faltan = []

    for k, info in orden_keys.items():
        if k in DEBUXOS_P21:
            # Ya revisadas en P2.1 (propias D)
            clasif_por_clave[k] = "D"
            counts["D"] += 1
            continue

        if k in FLUENT_DIRECTOS:
            slug, fl_name, ur, porque = FLUENT_DIRECTOS[k]
            clave = f"pal_{slug}"
            svg_path = FLUENT_SVGS[fl_name]
            lam = bal.svg_a_lamina(svg_path.read_text(encoding="utf-8"), paleta="exacta")
            err = bal.validar_lamina_dict(lam, clave)
            if err:
                raise RuntimeError(f"Error en {clave}: {err}")
            (LAMINAS_DIR / f"{clave}.json").write_text(
                json.dumps(lam, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8"
            )
            pezas[k] = {
                "clave": clave,
                "orixe": "banco",
                "porque": porque,
                "fuente": "fluent-flat",
                "asset": f"fluentui-emoji:assets/{fl_name}/Flat",
                "sha": SHA_FLUENT,
                "licencia": "MIT",
                "revisado": True,
            }
            clasif_por_clave[k] = ur
            counts[ur] += 1
        elif k in DNIZFOR_DIRECTOS:
            slug, dn_word, ur, porque = DNIZFOR_DIRECTOS[k]
            clave = f"pal_{slug}"
            src = DNIZFOR_IMGS[dn_word]
            bal.copiar_raster_banco(src, clave, LAMINAS_DIR)
            pezas[k] = {
                "clave": clave,
                "orixe": "banco",
                "porque": porque,
                "fuente": "dnizfor",
                "asset": f"images/{src.name}",
                "sha": SHA_DNIZFOR,
                "licencia": "MIT",
                "revisado": True,
            }
            clasif_por_clave[k] = ur
            counts[ur] += 1
        elif k in PROPIAS_REUTILIZADAS:
            clave, porque = PROPIAS_REUTILIZADAS[k]
            pezas[k] = {
                "clave": clave,
                "orixe": "reutilizada",
                "porque": porque,
                "fuente": "propia",
                "asset": f"assets/brand/laminas/{clave}.json",
                "sha": SHA_PROPIA,
                "licencia": "Propia",
                "revisado": True,
            }
            clasif_por_clave[k] = "R"
            counts["R"] += 1
        elif k in escenas_cd:
            slug, cd, formas, porque = escenas_cd[k]
            clave = f"pal_{slug}"
            lam = {
                "vb": 160,
                "vh": 100,
                "nota": f"«{info['en']}»: {porque} Sen texto.",
                "formas": [_round_forma(dict(f)) for f in formas],
            }
            err = bal.validar_lamina_dict(lam, clave)
            if err:
                raise RuntimeError(f"Error en {clave}: {err}")
            (LAMINAS_DIR / f"{clave}.json").write_text(
                json.dumps(lam, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8"
            )
            pezas[k] = {
                "clave": clave,
                "orixe": "composta" if cd == "C" else "nova",
                "porque": porque,
                "fuente": "composta" if cd == "C" else "propia",
                "asset": f"tools/gen_laminas_4_5.py#{slug}",
                "sha": SHA_FLUENT if cd == "C" else SHA_PROPIA,
                "licencia": "MIT" if cd == "C" else "Propia",
                "revisado": True,
            }
            clasif_por_clave[k] = cd
            counts[cd] += 1
        else:
            faltan.append(k)

    if faltan:
        raise RuntimeError(f"Faltan {len(faltan)} claves en curso_4_5: {faltan[:10]}")

    mapa["pezas"] = dict(sorted(pezas.items()))
    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")

    # Actualizar docs/revision_4_5_lecciones.csv
    rows_out = []
    with CSV_4_5_PATH.open(encoding="utf-8", newline="") as fh:
        reader = csv.DictReader(fh)
        fields = reader.fieldnames
        for row in reader:
            k = row["clave"].lower().strip(" .!?")
            m_p = pezas.get(k)
            c = clasif_por_clave.get(k, "")
            if m_p:
                row["lamina_actual"] = m_p["clave"]
                row["clasificacion"] = c
                row["estado"] = "revisado"
            rows_out.append(row)
    with CSV_4_5_PATH.open("w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=fields)
        w.writeheader()
        w.writerows(rows_out)

    print("OK gen_laminas_4_5:", counts, "total:", sum(counts.values()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
