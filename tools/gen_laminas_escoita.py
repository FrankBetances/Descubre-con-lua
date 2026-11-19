#!/usr/bin/env python3
"""Genera las 76 láminas nuevas de Escoita (P7.3, O-20261119-8 y O-20261111-4):
  - Las 47 de los bancos de Valeria en gallego y castellano:
    ball, bathtub, boat, bone, boot, breakfast, bun, crust, eight, eye, fly,
    get dressed, hand, hill, house, hunt, in, jewel, law, lock, nail, off, on,
    out, pajamas, put in, rat, red, saw, seat, ship, shoes, shovel, sit down,
    soy, string, take out, tea, tin can, toast, towel, track, truck, wagon,
    warm, water, zero.
  - Las 29 adicionales usadas en assets/content/escoita/plan_mensual.json:
    bat, boom, busy, cap, ear, finger, five, glow, gold, hive, lane, mill,
    pea, pin, pup, rack, ray, right, spines, spot, stripe, switch, tape, tick,
    toe, town, van, zipper, zoo.

Todas con clave pal_<palabra_con_guiones_bajos>, sin texto, fuentes permitidas
(Fluent Emoji Flat MIT y dibujo vectorial propio estilo Lúa).
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

import banco_a_lamina as bal  # noqa: E402
from banco_comun import (  # noqa: E402
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    FLUENT_SVGS,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    LAMINAS_DIR,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
    MORADO,
    NUBE,
    NUBE_B,
    PEL,
    PELB,
    ROJO,
    ROJO_OSCURO,
    SHA_FLUENT,
    SHA_PROPIA,
    TIERRA,
    TIERRA_CLARA,
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
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    nino,
    sol,
)
from tpr_tandas.comun_tpr import (  # noqa: E402
    DORADO,
    NARANJA,
    NARANJA_OSCURO,
    NEGRO,
    PLATA,
    ROSA,
    ROSA_OSCURO,
    caja_prop,
    mesa_prop,
    nino_busto,
    ondas_calor,
    ondas_sonido,
    pelota_prop,
    plato_prop,
    toalla_prop,
)

SCRIPT_REF = "tools/gen_laminas_escoita.py"

# 1) Directas de Fluent Emoji Flat (MIT)
FLUENT_DIRECTOS: list[tuple[str, str, str, str, str]] = [
    ("ball", "ball", "Soccer ball", "U", "Balón blanco y negro redondo de fútbol."),
    ("bat", "bat", "Bat", "U", "Murciélago morado con alas abiertas."),
    ("bathtub", "bathtub", "Bathtub", "U", "Bañera blanca con grifo y patas."),
    ("boat", "boat", "Sailboat", "R", "Barco de vela blanca sobre el agua."),
    ("bone", "bone", "Bone", "U", "Hueso blanco clásico."),
    ("boot", "boot", "Hiking boot", "R", "Bota marrón resistente de montaña."),
    ("cap", "cap", "Billed cap", "U", "Gorra azul con visera."),
    ("ear", "ear", "Ear", "U", "Oreja humana de perfil."),
    ("eye", "eye", "Eye", "U", "Ojo abierto mirando al frente."),
    ("hand", "hand", "Raised hand", "U", "Mano abierta con los cinco dedos."),
    ("house", "house", "House", "U", "Casa con tejado rojo y puerta."),
    ("jewel", "jewel", "Gem stone", "U", "Gema azul brillante tallada."),
    ("law", "law", "Balance scale", "R", "Balanza dorada de dos platillos representando la ley y justicia."),
    ("lock", "lock", "Locked", "U", "Candado dorado cerrado."),
    ("pea", "pea", "Pea pod", "U", "Vaina verde abierta con guisantes redondos."),
    ("pin", "pin", "Pushpin", "R", "Alfiler / chincheta roja con punta metálica."),
    ("rat", "rat", "Rat", "U", "Rata gris de perfil con cola larga."),
    ("saw", "saw", "Carpentry saw", "U", "Sierra de carpintero con mango de madera."),
    ("seat", "seat", "Chair", "R", "Silla de madera para sentarse."),
    ("ship", "ship", "Passenger ship", "U", "Barco grande de pasajeros navegando."),
    ("string", "string", "Thread", "U", "Carrete con hilo/cuerda enrollada."),
    ("tea", "tea", "Teacup without handle", "U", "Taza verde de té caliente humeante."),
    ("tin can", "tin_can", "Canned food", "U", "Lata cilíndrica metálica de conserva."),
    ("track", "track", "Railway track", "U", "Vía de tren con raíles y traviesas."),
    ("truck", "truck", "Delivery truck", "U", "Camión de reparto con caja y ruedas."),
    ("van", "van", "Minibus", "R", "Furgoneta amarilla con ventanas y ruedas."),
]


def _estrella(cx: float, cy: float, r_ext: float, r_int: float, col: str = AMARILLO, borde: str = AMARILLO_OSCURO) -> list[dict]:
    pts = []
    for i in range(10):
        ang = math.radians(-90 + i * 36)
        r = r_ext if i % 2 == 0 else r_int
        pts.append((round(cx + r * math.cos(ang), 2), round(cy + r * math.sin(ang), 2)))
    return [P(pts, col, borde, 1.8)]


def _caja_abierta(x: float, y: float, w: float = 56, h: float = 40) -> list[dict]:
    """Caja abierta vista de frente con solapas abiertas."""
    return [
        R(x, y, w, h, 3, "#eab308", MADERA_OSCURA, 2.2),
        P([(x, y), (x - 10, y - 10), (x + w * 0.45, y - 10), (x + w * 0.48, y)], "#fde047", MADERA_OSCURA, 1.8),
        P([(x + w, y), (x + w + 10, y - 10), (x + w * 0.55, y - 10), (x + w * 0.52, y)], "#fde047", MADERA_OSCURA, 1.8),
        R(x + 4, y + 3, w - 8, 8, 1, "#78350f"),
    ]


def _lampara(encendida: bool) -> list[dict]:
    pantalla_f = AMARILLO if encendida else GRIS
    pantalla_s = AMARILLO_OSCURO if encendida else GRIS_OSCURO
    base = [
        R(66, 76, 28, 8, 3, MADERA, MADERA_OSCURA, 2.0),
        R(77, 50, 6, 28, 2, MADERA_OSCURA, TINTA, 1.5),
        P([(56, 52), (66, 24), (94, 24), (104, 52)], pantalla_f, pantalla_s, 2.2),
    ]
    if encendida:
        rays = []
        for ang in (-35, 0, 35, 145, 180, 215):
            rad = math.radians(ang)
            x1 = 80 + 30 * math.cos(rad)
            y1 = 38 + 20 * math.sin(rad)
            x2 = 80 + 44 * math.cos(rad)
            y2 = 38 + 30 * math.sin(rad)
            rays.append(L(f"M{x1:.1f} {y1:.1f} L{x2:.1f} {y2:.1f}", AMARILLO_OSCURO, 2.6))
        return fondo_sala() + [E(80, 42, 34, 26, "#fef08a")] + rays + base
    return [R(0, 0, 160, 100, 0, "#334155"), R(0, 76, 160, 24, 0, "#475569")] + base


# 2) Composiciones (C) y Dibujos propios (D)
ESCENAS_CD: dict[str, tuple[str, str, list[dict], str]] = {
    "boom": (
        "boom", "D",
        fondo_cielo("#fef3c7")
        + [
            P([
                (80, 10), (92, 30), (118, 16), (106, 38), (134, 42),
                (110, 56), (128, 78), (98, 68), (90, 90), (78, 70),
                (54, 86), (62, 62), (32, 62), (54, 46), (34, 24), (66, 32),
            ], ROJO, ROJO_OSCURO, 2.4),
            P([
                (80, 24), (88, 38), (104, 30), (96, 44), (114, 48),
                (96, 56), (108, 68), (88, 62), (82, 76), (74, 62),
                (60, 70), (66, 54), (48, 52), (64, 42), (54, 30), (72, 38),
            ], AMARILLO, NARANJA_OSCURO, 2.0),
        ],
        "Estallido concéntrico en rojo, naranja y amarillo sin texto.",
    ),
    "breakfast": (
        "breakfast", "C",
        fondo_mesa()
        + plato_prop(92, 66, 26)
        + fl("Bread", 68, 36, 44)
        + fl("Glass of milk", 26, 24, 46),
        "Mesa de desayuno con vaso de leche y rebanada de pan en el plato.",
    ),
    "bun": (
        "bun", "D",
        fondo_mesa()
        + plato_prop(80, 66, 34)
        + [
            E(80, 58, 25, 9, TIERRA_CLARA, BARRO, 2.0),
            F("M55 58 C55 32 105 32 105 58 Z", "#f59e0b", BARRO, 2.2),
            E(70, 44, 2.2, 1.4, "#fef3c7"),
            E(80, 40, 2.2, 1.4, "#fef3c7"),
            E(90, 45, 2.2, 1.4, "#fef3c7"),
            E(76, 50, 2.2, 1.4, "#fef3c7"),
            E(86, 51, 2.2, 1.4, "#fef3c7"),
        ],
        "Bollo de pan redondo dorado con semillas sobre un plato.",
    ),
    "busy": (
        "busy", "C",
        fondo_prado()
        + [
            L("M34 62 Q48 26 78 44 Q108 62 126 30", AMARILLO_OSCURO, 2.0),
            E(34, 68, 7, 7, ROSA, ROSA_OSCURO, 1.6),
            E(34, 68, 2.5, 2.5, AMARILLO),
            E(126, 68, 7, 7, MORADO, TINTA, 1.6),
            E(126, 68, 2.5, 2.5, AMARILLO),
        ]
        + fl("Honeybee", 60, 20, 40),
        "Abeja atareada volando en zigzag entre flores.",
    ),
    "crust": (
        "crust", "D",
        fondo_mesa()
        + [
            R(46, 22, 68, 58, 12, BARRO, "#451a03", 3.0),
            R(54, 30, 52, 42, 8, "#fef3c7", "#d97706", 1.5),
            *frecha((22, 46), (48, 46), ROJO_OSCURO),
        ],
        "Rebanada de pan con la corteza marrón gruesa señalada por una flecha.",
    ),
    "eight": (
        "eight", "D",
        fondo_cielo("#f0f9ff")
        + [R(22, 16, 116, 68, 10, BLANCO, AZUL_OSCURO, 2.2)]
        + [item for cx in (42, 67, 93, 118) for cy in (36, 64) for item in _estrella(cx, cy, 9.5, 4.2)],
        "Ocho estrellas doradas alineadas en dos filas de cuatro, sin números.",
    ),
    "finger": (
        "finger", "C",
        fondo_sala()
        + fl("Backhand index pointing up", 48, 16, 64)
        + [E(76, 28, 11, 11, None, ROJO, 2.4)],
        "Mano con el dedo índice extendido y señalado con un círculo.",
    ),
    "five": (
        "five", "D",
        fondo_cielo("#f0f9ff")
        + [R(24, 16, 112, 68, 10, BLANCO, AZUL_OSCURO, 2.2)]
        + [item for cx, cy in [(46, 34), (114, 34), (80, 50), (46, 66), (114, 66)] for item in _estrella(cx, cy, 9.5, 4.2)],
        "Cinco estrellas doradas dispuestas como un cinco de dado, sin números.",
    ),
    "fly": (
        "fly", "C",
        fondo_cielo()
        + [
            E(34, 24, 14, 8, BLANCO, NUBE_B, 1.4),
            E(124, 28, 16, 9, BLANCO, NUBE_B, 1.4),
            L("M34 68 Q62 56 80 44", AZUL_OSCURO, 2.4),
        ]
        + fl("Bird", 64, 22, 46, flip_x=True),
        "Pájaro azul volando alto entre nubes con trazo de vuelo.",
    ),
    "get dressed": (
        "get_dressed", "C",
        fondo_sala()
        + nino((46, 20), (46, 32), (46, 52), [[(32, 46)], [(60, 46)]], [[(40, 74)], [(52, 74)]], camisa=(AZUL, AZUL_OSCURO))
        + fl("T-shirt", 82, 22, 36)
        + fl("Jeans", 86, 56, 34),
        "Niño vistiéndose junto a camiseta y pantalón.",
    ),
    "glow": (
        "glow", "C",
        fondo_noite()
        + [E(80, 46, 34, 34, "#fef08a"), E(80, 46, 24, 24, "#fde047")]
        + fl("Light bulb", 52, 18, 56),
        "Bombilla brillando con halo luminoso cálido en la noche.",
    ),
    "gold": (
        "gold", "C",
        fondo_mesa()
        + [
            P([(42, 66), (52, 44), (108, 44), (118, 66)], DORADO, "#854d0e", 2.4),
            P([(52, 44), (60, 34), (100, 34), (108, 44)], AMARILLO, "#854d0e", 2.0),
        ]
        + fl("Coin", 36, 52, 28)
        + fl("Sparkles", 98, 16, 30),
        "Lingote y moneda de oro brillante con destellos.",
    ),
    "hill": (
        "hill", "D",
        fondo_cielo()
        + [
            F("M0 86 Q45 30 85 28 Q125 28 160 86 L160 100 L0 100 Z", HERBA, HERBAB, 2.4),
            L("M58 92 Q78 62 85 32", "#fde68a", 6.0),
        ]
        + sol(26, 20),
        "Colina verde alta bajo cielo azul con sendero hasta la cima.",
    ),
    "hive": (
        "hive", "D",
        fondo_prado()
        + [
            L("M20 18 L120 18", MADERA_OSCURA, 5.0),
            E(80, 36, 18, 10, AMARILLO, BARRO, 2.0),
            E(80, 46, 23, 11, AMARILLO, BARRO, 2.0),
            E(80, 56, 20, 10, AMARILLO, BARRO, 2.0),
            E(80, 65, 13, 8, AMARILLO, BARRO, 2.0),
            E(80, 52, 6, 7, TINTA),
        ]
        + fl("Honeybee", 104, 28, 22),
        "Colmena dorada colgando de una rama con una abeja.",
    ),
    "hunt": (
        "hunt", "C",
        fondo_prado()
        + fl("Footprints", 46, 56, 36)
        + fl("Magnifying glass tilted left", 76, 26, 48),
        "Lupa buscando huellas escondidas en la hierba.",
    ),
    "in": (
        "in", "D",
        fondo_sala()
        + _caja_abierta(52, 40, 56, 38)
        + pelota_prop(80, 56, 14)
        + _caja_abierta(52, 46, 56, 32)[0:1]  # pared frontal ocultando mitad inferior de la pelota
        + frecha((80, 12), (80, 34), VERDE_OSCURO),
        "Pelota roja claramente dentro de una caja abierta.",
    ),
    "lane": (
        "lane", "D",
        fondo_prado()
        + [
            P([(52, 100), (72, 34), (88, 34), (108, 100)], GRIS_OSCURO, TINTA, 2.0),
            L("M80 42 L80 50", BLANCO, 2.5),
            L("M80 58 L80 70", BLANCO, 2.8),
            L("M80 78 L80 94", BLANCO, 3.2),
        ],
        "Carril / pista recta con línea discontinua blanca.",
    ),
    "mill": (
        "mill", "D",
        fondo_prado()
        + [
            P([(62, 82), (68, 36), (92, 36), (98, 82)], "#fef3c7", MADERA_OSCURA, 2.2),
            P([(64, 36), (80, 20), (96, 36)], ROJO, ROJO_OSCURO, 2.2),
            R(74, 62, 12, 20, 2, MADERA, MADERA_OSCURA, 1.8),
            L("M52 24 L108 64", MADERA_OSCURA, 3.2),
            L("M108 24 L52 64", MADERA_OSCURA, 3.2),
            E(80, 44, 4, 4, BLANCO, TINTA, 1.5),
        ],
        "Molino con torre y cuatro aspas cruzadas.",
    ),
    "nail": (
        "nail", "D",
        fondo_sala()
        + [
            R(58, 30, 44, 70, 22, PEL, PELB, 2.4),
            R(66, 34, 28, 28, 12, "#fce7f3", ROSA_OSCURO, 2.0),
            E(80, 42, 10, 4, BLANCO),
            *frecha((26, 46), (62, 46), AZUL_OSCURO),
        ],
        "Punta del dedo señalando claramente la uña rosada.",
    ),
    "off": (
        "off", "D",
        _lampara(encendida=False),
        "Lámpara de mesa apagada sobre fondo oscuro.",
    ),
    "on": (
        "on", "D",
        _lampara(encendida=True),
        "Lámpara de mesa encendida irradiando luz amarilla.",
    ),
    "out": (
        "out", "D",
        fondo_sala()
        + _caja_abierta(28, 42, 48, 34)
        + pelota_prop(118, 66, 14)
        + frecha((78, 56), (104, 56), AZUL_OSCURO),
        "Pelota roja fuera de la caja sobre el suelo con flecha saliendo.",
    ),
    "pajamas": (
        "pajamas", "D",
        fondo_noite()
        + [
            P([(48, 20), (62, 16), (98, 16), (112, 20), (118, 38), (104, 42), (100, 32), (100, 54), (60, 54), (60, 32), (56, 42), (42, 38)], "#93c5fd", AZUL_OSCURO, 2.0),
            P([(62, 56), (98, 56), (104, 88), (84, 88), (80, 68), (76, 88), (56, 88)], "#93c5fd", AZUL_OSCURO, 2.0),
        ]
        + _estrella(74, 34, 4.5, 2.0)
        + _estrella(86, 42, 4.5, 2.0)
        + _estrella(70, 72, 4.0, 1.8),
        "Pijama azul celeste de dos piezas con estrellitas amarillas.",
    ),
    "pup": (
        "pup", "C",
        fondo_prado()
        + fl("Dog", 52, 26, 56),
        "Cachorrito alegre en el prado.",
    ),
    "put in": (
        "put_in", "D",
        fondo_sala()
        + _caja_abierta(52, 52, 56, 32)
        + pelota_prop(80, 18, 12)
        + frecha((80, 32), (80, 50), VERDE_OSCURO),
        "Pelota entrando hacia el interior de la caja abierta.",
    ),
    "rack": (
        "rack", "D",
        fondo_sala()
        + [
            L("M66 86 L94 86", MADERA_OSCURA, 4.0),
            R(77, 22, 6, 64, 2, MADERA, MADERA_OSCURA, 2.0),
            L("M77 32 L58 24", MADERA_OSCURA, 3.2),
            L("M83 32 L102 24", MADERA_OSCURA, 3.2),
            L("M77 44 L62 38", MADERA_OSCURA, 3.0),
            L("M83 44 L98 38", MADERA_OSCURA, 3.0),
            E(58, 24, 3.5, 3.5, AMARILLO, MADERA_OSCURA, 1.5),
            E(102, 24, 3.5, 3.5, AMARILLO, MADERA_OSCURA, 1.5),
        ],
        "Perchero de madera de pie con ganchos arriba.",
    ),
    "ray": (
        "ray", "C",
        fondo_cielo()
        + fl("Sun", 14, 10, 44)
        + [
            L("M58 40 L132 76", AMARILLO, 5.0),
            L("M52 50 L110 86", AMARILLO_OSCURO, 3.5),
            L("M64 30 L144 50", AMARILLO_OSCURO, 3.5),
        ],
        "Sol brillante proyectando un rayo de luz largo.",
    ),
    "red": (
        "red", "D",
        [
            R(0, 0, 160, 100, 0, "#fff1f2"),
            E(80, 50, 32, 32, ROJO, ROJO_OSCURO, 3.0),
            E(68, 38, 8, 5, "#fca5a5"),
        ],
        "Círculo grande de color rojo intenso.",
    ),
    "right": (
        "right", "C",
        fondo_sala()
        + frecha((26, 50), (88, 50), AZUL_OSCURO)
        + fl("Backhand index pointing right", 82, 20, 58),
        "Mano y flecha señalando claramente hacia la derecha.",
    ),
    "shoes": (
        "shoes", "C",
        fondo_sala()
        + fl("Running shoe", 26, 26, 50)
        + fl("Running shoe", 82, 26, 50),
        "Par de dos zapatillas colocadas juntas.",
    ),
    "shovel": (
        "shovel", "D",
        fondo_prado()
        + [
            R(70, 14, 20, 7, 3, MADERA, MADERA_OSCURA, 2.0),
            R(77, 21, 6, 36, 2, MADERA, MADERA_OSCURA, 1.8),
            P([(62, 54), (98, 54), (94, 78), (80, 88), (66, 78)], PLATA, GRIS_OSCURO, 2.2),
        ],
        "Pala de jardín con mango de madera y hoja metálica.",
    ),
    "sit down": (
        "sit_down", "D",
        fondo_sala()
        + [
            R(94, 40, 6, 44, 2, MADERA, MADERA_OSCURA, 1.8),
            R(66, 62, 34, 6, 2, MADERA, MADERA_OSCURA, 1.8),
            R(66, 68, 5, 16, 1, MADERA_OSCURA),
            R(94, 68, 5, 16, 1, MADERA_OSCURA),
        ]
        + nino_busto(78, 38, camisa=(VERDE, VERDE_OSCURO), mira=-1)
        + frecha((36, 30), (36, 64), AZUL_OSCURO),
        "Niño sentándose en una silla con flecha descendente.",
    ),
    "soy": (
        "soy", "D",
        fondo_mesa()
        + [
            F("M34 56 Q62 24 126 38 Q112 72 34 56 Z", VERDE, VERDE_OSCURO, 2.2),
            E(58, 49, 8.5, 7.5, "#fde68a", AMARILLO_OSCURO, 1.8),
            E(80, 47, 8.5, 7.5, "#fde68a", AMARILLO_OSCURO, 1.8),
            E(102, 48, 8.5, 7.5, "#fde68a", AMARILLO_OSCURO, 1.8),
        ],
        "Vaina verde abierta con tres habas de soja doradas.",
    ),
    "spines": (
        "spines", "C",
        fondo_prado()
        + fl("Hedgehog", 46, 26, 62)
        + [
            L("M72 40 L62 24", BARRO, 2.6),
            L("M86 36 L86 20", BARRO, 2.6),
            L("M100 40 L110 24", BARRO, 2.6),
            E(86, 44, 20, 12, None, ROJO, 2.2),
        ],
        "Erizo con sus púas destacadas en el lomo.",
    ),
    "spot": (
        "spot", "D",
        fondo_mesa()
        + [
            R(36, 18, 88, 62, 6, BLANCO, GRIS_OSCURO, 2.0),
            E(80, 49, 18, 15, ROJO, ROJO_OSCURO, 2.0),
            E(96, 38, 5, 4, ROJO),
            E(63, 60, 4, 3, ROJO),
        ],
        "Hoja blanca con una mancha roja de pintura en el centro.",
    ),
    "stripe": (
        "stripe", "D",
        fondo_sala()
        + [
            R(40, 22, 80, 56, 8, AMARILLO, TINTA, 2.2),
            R(42, 34, 76, 10, 0, TINTA),
            R(42, 56, 76, 10, 0, TINTA),
            *frecha((16, 39), (38, 39), ROJO_OSCURO),
        ],
        "Patrón amarillo con rayas negras y flecha señalando una raya.",
    ),
    "switch": (
        "switch", "D",
        fondo_sala()
        + [
            R(54, 16, 52, 68, 8, BLANCO, GRIS_OSCURO, 2.4),
            R(68, 32, 24, 36, 4, "#e2e8f0", GRIS_OSCURO, 1.8),
            P([(70, 50), (90, 50), (88, 34), (72, 34)], AMARILLO, AMARILLO_OSCURO, 1.8),
            *frecha((124, 60), (124, 34), VERDE_OSCURO),
        ],
        "Interruptor de pared con palanca señalada.",
    ),
    "take out": (
        "take_out", "D",
        fondo_sala()
        + _caja_abierta(52, 52, 56, 32)
        + pelota_prop(80, 18, 12)
        + frecha((80, 50), (80, 32), ROJO_OSCURO),
        "Pelota saliendo hacia fuera desde el interior de la caja abierta.",
    ),
    "tape": (
        "tape", "D",
        fondo_mesa()
        + [
            E(72, 50, 24, 24, "#fef08a", AMARILLO_OSCURO, 2.4),
            E(72, 50, 11, 11, MADERA, MADERA_OSCURA, 2.0),
            L("M72 26 L126 26 L126 38 L92 38", AMARILLO_OSCURO, 2.0),
            P([(72, 26), (126, 26), (126, 38), (92, 38)], "#fef08a", AMARILLO_OSCURO, 1.8),
        ],
        "Rollo de cinta adhesiva amarilla con tira desplegada.",
    ),
    "tick": (
        "tick", "C",
        fondo_sala()
        + fl("Alarm clock", 50, 20, 60)
        + ondas_sonido(44, 48, AZUL_OSCURO, -1)
        + ondas_sonido(116, 48, AZUL_OSCURO, 1),
        "Reloj despertador emitiendo ondas rítmicas de tic-tac.",
    ),
    "toast": (
        "toast", "D",
        fondo_mesa()
        + plato_prop(80, 68, 34)
        + [
            F("M54 64 L54 36 C50 24 64 20 80 20 C96 20 110 24 106 36 L106 64 Z", BARRO, "#451a03", 2.2),
            F("M59 60 L59 38 C56 29 67 26 80 26 C93 26 104 29 101 38 L101 60 Z", TIERRA_CLARA, BARRO, 1.5),
            R(70, 38, 20, 14, 3, "#fef08a", AMARILLO_OSCURO, 1.6),
        ],
        "Rebanada de pan tostado dorado con mantequilla encima.",
    ),
    "toe": (
        "toe", "C",
        fondo_sala()
        + fl("Foot", 48, 18, 64)
        + [E(58, 67, 10, 10, None, ROJO, 2.4)],
        "Pie descalzo con los dedos del pie rodeados por un círculo rojo.",
    ),
    "towel": (
        "towel", "D",
        fondo_sala()
        + [L("M34 28 L126 28", MADERA_OSCURA, 4.0)]
        + toalla_prop(50, 28, 60, 48),
        "Toalla azul doblada colgando de una barra.",
    ),
    "town": (
        "town", "C",
        fondo_prado()
        + fl("House", 18, 36, 40)
        + fl("House with garden", 60, 32, 44)
        + fl("Houses", 104, 36, 40),
        "Pueblo pequeño con varias casas juntas en fila.",
    ),
    "wagon": (
        "wagon", "D",
        fondo_prado()
        + [
            L("M48 56 L22 36", TINTA, 3.0),
            E(20, 34, 4, 4, AMARILLO, TINTA, 1.8),
            R(48, 38, 68, 26, 4, ROJO, ROJO_OSCURO, 2.2),
            E(62, 68, 10, 10, NEGRO, BLANCO, 2.0),
            E(102, 68, 10, 10, NEGRO, BLANCO, 2.0),
            E(62, 68, 3, 3, PLATA),
            E(102, 68, 3, 3, PLATA),
        ],
        "Vagoneta roja de juguete con asa y cuatro ruedas.",
    ),
    "warm": (
        "warm", "C",
        fondo_sala()
        + fl("Teacup without handle", 52, 34, 56)
        + ondas_calor(68, 28, NARANJA_OSCURO),
        "Taza caliente desprendiendo ondas cálidas de vapor.",
    ),
    "water": (
        "water", "C",
        fondo_mar()
        + fl("Droplet", 42, 20, 36)
        + fl("Droplet", 84, 24, 34),
        "Agua azul con olas y gotas claras.",
    ),
    "zero": (
        "zero", "D",
        fondo_mesa()
        + plato_prop(80, 56, 36),
        "Plato completamente vacío representando cero elementos, sin números.",
    ),
    "zipper": (
        "zipper", "D",
        fondo_sala()
        + [
            R(66, 12, 28, 76, 4, AZUL, AZUL_OSCURO, 2.2),
            L("M80 14 L80 86", GRIS_OSCURO, 2.0),
        ]
        + [R(74, y, 5, 4, 1, PLATA, GRIS_OSCURO, 0.8) for y in range(18, 82, 8)]
        + [R(81, y + 4, 5, 4, 1, PLATA, GRIS_OSCURO, 0.8) for y in range(18, 78, 8)]
        + [
            R(73, 40, 14, 12, 3, AMARILLO, MADERA_OSCURA, 1.8),
            R(76, 52, 8, 14, 3, AMARILLO, MADERA_OSCURA, 1.6),
        ],
        "Cremallera metálica con tirador amarillo subiendo.",
    ),
    "zoo": (
        "zoo", "C",
        fondo_prado()
        + fl("Lion", 22, 24, 40)
        + fl("Elephant", 62, 22, 42)
        + fl("Zebra", 102, 24, 40)
        + [
            L("M16 64 L144 64", MADERA_OSCURA, 3.5),
            L("M16 74 L144 74", MADERA_OSCURA, 3.5),
            R(28, 56, 6, 28, 1, MADERA, MADERA_OSCURA, 1.5),
            R(77, 56, 6, 28, 1, MADERA, MADERA_OSCURA, 1.5),
            R(126, 56, 6, 28, 1, MADERA, MADERA_OSCURA, 1.5),
        ],
        "Zoológico con león, elefante y cebra tras una valla de madera.",
    ),
}


def main() -> int:
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]

    creadas: list[str] = []
    for word, slug, fl_name, ur, porque in FLUENT_DIRECTOS:
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_fluent_directo(pezas, key, slug, fl_name, ur, porque)
        creadas.append(f"pal_{slug}")

    for word, (slug, cd, formas, porque) in ESCENAS_CD.items():
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_cd(pezas, key, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=word)
        creadas.append(f"pal_{slug}")

    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK: generadas {len(creadas)} láminas nuevas en {LAMINAS_DIR.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
