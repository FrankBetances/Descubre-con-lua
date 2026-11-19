#!/usr/bin/env python3
"""Tanda 11 TPR (P2.93): bloques `jumping`..`scratch`.

Cubre exactamente 200 piezas revisadas + 86 auditadas sin base (`SIN_BASE`):
- Directas Fluent Emoji Flat (6): `ladybird`, `lorry`, `photo`, `recycle`, `rowing boat`, `ruler`.
- Escenas propias estilo Lúa D (194): `jumping` .. `scratch`.

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas, conversacionales, duplicadas o dependientes de texto quedan en `SIN_BASE`.
"""
from __future__ import annotations

import math
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from tpr_tandas.comun_tpr import (  # noqa: E402
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    DORADO,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    MADERA,
    MADERA_OSCURA,
    MAR_PROF,
    MORADO,
    NARANJA,
    NARANJA_OSCURO,
    NEGRO,
    NUBE,
    NUBE_B,
    PEL,
    PELB,
    PLATA,
    ROJO,
    ROJO_OSCURO,
    ROSA,
    ROSA_OSCURO,
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
    bebe,
    bebe_sentado,
    bellota_prop,
    cuchara_prop,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    libro_prop,
    lineas_viento,
    manta_prop,
    mesa_prop,
    nino,
    nino_busto,
    nino_corriendo,
    notas_col,
    ondas_calor,
    ondas_sonido,
    papelera_prop,
    pelota_prop,
    plato_prop,
    pompas,
    semilla_prop,
    toalla_prop,
)

DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "ladybird": ("Lady beetle", "U", "Mariquita roja con puntos negros."),
    "lorry": ("Articulated lorry", "U", "Camión grande articulado de carga."),
    "photo": ("Camera with flash", "R", "Cámara de fotos disparando el flash."),
    "recycle": ("Recycling symbol", "U", "Símbolo verde de tres flechas en círculo de reciclar."),
    "rowing boat": ("Person rowing boat", "U", "Persona remando en barca de remos."),
    "ruler": ("Straight ruler", "U", "Regla escolar recta amarilla con marcas de medida."),
}

DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _sol(cx: float, cy: float, r: float = 10) -> list[dict]:
    o = [E(cx, cy, r, r, AMARILLO, AMARILLO_OSCURO, 1.8)]
    for i in range(8):
        ang = math.radians(i * 45)
        x1 = cx + (r + 3) * math.cos(ang)
        y1 = cy + (r + 3) * math.sin(ang)
        x2 = cx + (r + 7) * math.cos(ang)
        y2 = cy + (r + 7) * math.sin(ang)
        o.append(L(f"M{x1:.1f} {y1:.1f} L{x2:.1f} {y2:.1f}", AMARILLO_OSCURO, 1.9))
    return o


def _estrella(cx: float, cy: float, r_ext: float, r_int: float, col: str = AMARILLO, borde: str = AMARILLO_OSCURO) -> dict:
    pts = []
    for i in range(10):
        ang = math.radians(-90 + i * 36)
        r = r_ext if i % 2 == 0 else r_int
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return P(pts, col, borde, 1.4)


def _nino_pie(cx: float, cy: float, camisa: tuple[str, str] = (ROJO, ROJO_OSCURO), mira: int = 1) -> list[dict]:
    return nino(
        (cx, cy),
        (cx, cy + 12),
        (cx, cy + 28),
        [[(cx - 12, cy + 22)], [(cx + 12, cy + 22)]],
        [[(cx - 6, cy + 48)], [(cx + 6, cy + 48)]],
        camisa=camisa,
        mira=mira,
    )


def _mano(cx: float, cy: float) -> list[dict]:
    return [
        L(f"M{cx - 6:.1f} {cy + 2:.1f} L{cx - 14:.1f} {cy - 4:.1f}", PELB, 4.2),
        L(f"M{cx - 6:.1f} {cy + 2:.1f} L{cx - 14:.1f} {cy - 4:.1f}", PEL, 2.4),
        E(cx, cy, 8, 9, PEL, PELB, 1.8),
        L(f"M{cx - 6:.1f} {cy - 4:.1f} L{cx - 9:.1f} {cy - 14:.1f}", PELB, 3.8),
        L(f"M{cx - 6:.1f} {cy - 4:.1f} L{cx - 9:.1f} {cy - 14:.1f}", PEL, 2.2),
        L(f"M{cx - 2:.1f} {cy - 7:.1f} L{cx - 2:.1f} {cy - 18:.1f}", PELB, 3.8),
        L(f"M{cx - 2:.1f} {cy - 7:.1f} L{cx - 2:.1f} {cy - 18:.1f}", PEL, 2.2),
        L(f"M{cx + 3:.1f} {cy - 7:.1f} L{cx + 4:.1f} {cy - 17:.1f}", PELB, 3.8),
        L(f"M{cx + 3:.1f} {cy - 7:.1f} L{cx + 4:.1f} {cy - 17:.1f}", PEL, 2.2),
        L(f"M{cx + 7:.1f} {cy - 3:.1f} L{cx + 11:.1f} {cy - 12:.1f}", PELB, 3.8),
        L(f"M{cx + 7:.1f} {cy - 3:.1f} L{cx + 11:.1f} {cy - 12:.1f}", PEL, 2.2),
    ]


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = {
    "jumping": (
        "D",
        fondo_prado()
        + [
            *nino((80, 18), (80, 30), (80, 44), [[(64, 24), (54, 16)], [(96, 24), (106, 16)]], [[(72, 58), (68, 66)], [(88, 58), (92, 66)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            E(80, 82, 16, 4, "#94a3b8"),
            L("M66 66 L66 78 M94 66 L94 78", AZUL_OSCURO, 1.8),
            *frecha((42, 68), (42, 34), VERDE_OSCURO),
        ],
        "Niño dando saltitos en el aire sobre el prado con flecha ascendente.",
        None,
    ),
    "keep": (
        "D",
        fondo_sala()
        + [
            R(50, 52, 60, 34, 4, MADERA, MADERA_OSCURA, 2.2),
            F("M48 52 L112 52 L106 42 L54 42 Z", "#fde68a", MADERA_OSCURA, 1.8),
            E(80, 34, 9, 9, TIERRA_CLARA, BARRO, 1.8),
            E(72, 26, 3.5, 3.5, TIERRA_CLARA, BARRO, 1.4),
            E(88, 26, 3.5, 3.5, TIERRA_CLARA, BARRO, 1.4),
            *frecha((80, 20), (80, 46), AZUL_OSCURO),
        ],
        "Osito de juguete guardándose dentro de una caja de madera.",
        None,
    ),
    "keep warm together": (
        "D",
        fondo_sala()
        + [
            E(66, 36, 9, 9, PEL, PELB, 2.0),
            E(94, 36, 9, 9, PEL, PELB, 2.0),
            F("M58 32 C60 22 72 22 74 32 Z", BARRO),
            F("M86 32 C88 22 100 22 102 32 Z", NARANJA_OSCURO),
            E(64, 36, 1.2, 1.3, TINTA),
            E(69, 36, 1.2, 1.3, TINTA),
            E(91, 36, 1.2, 1.3, TINTA),
            E(96, 36, 1.2, 1.3, TINTA),
            *manta_prop(46, 44, 68, col=ROJO, h=38),
            L("M52 56 L108 56 M52 70 L108 70", AMARILLO, 2.2),
            E(80, 22, 5, 5, ROJO),
        ],
        "Dos niños juntos abrigados bajo una misma manta roja cálida.",
        None,
    ),
    "keep your distance": (
        "D",
        fondo_prado()
        + [
            *_nino_pie(36, 32, (AZUL, AZUL_OSCURO), 1),
            *_nino_pie(124, 32, (VERDE, VERDE_OSCURO), -1),
            *frecha((78, 52), (54, 52), ROJO_OSCURO),
            *frecha((82, 52), (106, 52), ROJO_OSCURO),
            L("M80 34 L80 78", ROJO, 2.0),
        ],
        "Dos niños separados con flechas bidireccionales marcando distancia.",
        None,
    ),
    "kelp": (
        "D",
        fondo_mar()
        + [
            F("M34 92 Q24 66 38 44 Q48 24 34 12 Q22 24 30 44 Q18 68 28 92 Z", VERDE, VERDE_OSCURO, 1.8),
            F("M74 92 Q86 64 72 40 Q62 20 76 10 Q90 22 80 42 Q94 66 82 92 Z", "#16a34a", VERDE_OSCURO, 1.8),
            F("M114 92 Q104 68 118 46 Q128 28 116 14 Q104 28 112 46 Q100 68 108 92 Z", VERDE, VERDE_OSCURO, 1.8),
            *pompas([(56, 30, 3), (98, 22, 4)]),
        ],
        "Algas laminarias verdes largas ondulando desde el fondo marino.",
        None,
    ),
    "kick": (
        "D",
        fondo_prado()
        + [
            *nino((54, 28), (54, 40), (54, 56), [[(42, 48)], [(66, 48)]], [[(48, 78)], [(76, 66)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *pelota_prop(108, 66, 11, BLANCO, TINTA),
            *frecha((84, 66), (96, 66), ROJO_OSCURO),
        ],
        "Niño dando una patada a una pelota en el prado.",
        None,
    ),
    "kindness jar": (
        "D",
        fondo_mesa()
        + [
            R(56, 30, 48, 54, 8, "#e0f2fe", AZUL_OSCURO, 2.2),
            R(62, 22, 36, 9, 3, DORADO, MADERA_OSCURA, 1.8),
            F("M66 64 C66 58 74 58 74 64 C74 58 82 58 82 64 C82 70 74 75 74 75 C74 75 66 70 66 64 Z", ROJO),
            F("M80 54 C80 49 87 49 87 54 C87 49 94 49 94 54 C94 59 87 64 87 64 C87 64 80 59 80 54 Z", ROSA),
            F("M64 46 C64 41 71 41 71 46 C71 41 78 41 78 46 C78 51 71 56 71 56 C71 56 64 51 64 46 Z", NARANJA),
            E(80, 12, 4, 4, ROJO),
        ],
        "Tarro de cristal lleno de corazones de colores simbolizando la bondad.",
        None,
    ),
    "kitchen": (
        "D",
        fondo_sala()
        + [
            R(26, 46, 108, 40, 3, "#fef3c7", MADERA_OSCURA, 2.2),
            R(24, 42, 112, 7, 2, GRIS, GRIS_OSCURO, 1.8),
            R(84, 52, 38, 30, 3, BLANCO, GRIS_OSCURO, 1.8),
            R(90, 58, 26, 18, 2, "#bae6fd", AZUL_OSCURO, 1.4),
            R(92, 28, 22, 14, 3, ROJO, ROJO_OSCURO, 1.8),
            L("M96 24 Q94 18 98 14 M106 24 Q104 18 108 14", GRIS_OSCURO, 1.6),
            R(36, 16, 36, 22, 2, MADERA, MADERA_OSCURA, 1.8),
        ],
        "Cocina equipada con encimera, horno y olla echando vapor.",
        None,
    ),
    "knees up, knees down": (
        "D",
        fondo_sala()
        + [
            *nino((64, 24), (64, 36), (64, 52), [[(50, 44)], [(78, 44)]], [[(58, 76)], [(78, 56), (78, 72)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            *frecha((104, 62), (104, 40), VERDE_OSCURO),
            *frecha((118, 40), (118, 62), ROJO_OSCURO),
        ],
        "Niño subiendo una rodilla con flechas de arriba y abajo.",
        None,
    ),
    "knock": (
        "D",
        fondo_sala()
        + [
            R(52, 16, 56, 72, 4, MADERA, MADERA_OSCURA, 2.4),
            E(96, 52, 4, 4, DORADO, MADERA_OSCURA, 1.5),
            E(48, 46, 10, 8, PEL, PELB, 2.0),
            L("M30 48 L42 46", PELB, 5.0),
            L("M30 48 L42 46", PEL, 3.0),
            *ondas_sonido(62, 46, ROJO_OSCURO, 1),
        ],
        "Puño llamando a una puerta de madera con ondas de golpe.",
        None,
    ),
    "knock down": (
        "D",
        fondo_mesa()
        + [
            R(44, 60, 18, 18, 2, AZUL, AZUL_OSCURO, 1.8),
            R(66, 62, 18, 16, 2, VERDE, VERDE_OSCURO, 1.8),
            P([(84, 50), (100, 42), (108, 56), (92, 64)], ROJO, ROJO_OSCURO, 1.8),
            P([(98, 66), (114, 58), (122, 72), (106, 80)], AMARILLO, AMARILLO_OSCURO, 1.8),
            *frecha((68, 36), (94, 44), ROJO_OSCURO),
        ],
        "Torre de bloques de colores cayendo derribada hacia un lado.",
        None,
    ),
    "lamp post": (
        "D",
        fondo_noite()
        + [
            R(76, 36, 8, 52, 2, GRIS_OSCURO, TINTA, 1.8),
            R(68, 84, 24, 6, 2, GRIS_OSCURO, TINTA, 1.8),
            P([(62, 22), (98, 22), (90, 38), (70, 38)], AMARILLO, AMARILLO_OSCURO, 2.0),
            P([(70, 38), (90, 38), (118, 84), (42, 84)], "#fef08a"),
            R(60, 18, 40, 5, 2, GRIS_OSCURO, TINTA, 1.6),
        ],
        "Farola urbana encendida proyectando un haz de luz amarillo de noche.",
        None,
    ),
    "land softly": (
        "D",
        fondo_prado()
        + [
            *nino((80, 32), (80, 44), (80, 58), [[(64, 50), (56, 44)], [(96, 50), (104, 44)]], [[(68, 66), (68, 76)], [(92, 66), (92, 76)]], camisa=(ROSA, ROSA_OSCURO), mira=1),
            *frecha((50, 22), (50, 48), VERDE_OSCURO),
            L("M58 80 Q80 86 102 80", HERBAB, 2.2),
        ],
        "Niño aterrizando suavemente con las rodillas dobladas sobre la hierba.",
        None,
    ),
    "leaf-covered": (
        "D",
        fondo_prado()
        + [
            R(24, 72, 112, 16, 4, TIERRA_CLARA, BARRO, 1.8),
            E(42, 74, 12, 6, NARANJA, NARANJA_OSCURO, 1.6),
            E(64, 70, 13, 6, ROJO, ROJO_OSCURO, 1.6),
            E(88, 74, 12, 6, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(110, 70, 13, 6, NARANJA, BARRO, 1.6),
            E(56, 62, 11, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            E(96, 62, 11, 5, ROJO, ROJO_OSCURO, 1.5),
            *_nino_pie(80, 22, (VERDE, VERDE_OSCURO), 1),
        ],
        "Suelo completamente cubierto de hojas otoñales bajo los pies de un niño.",
        None,
    ),
    "lean on": (
        "D",
        fondo_sala()
        + [
            R(90, 44, 34, 42, 8, AZUL, AZUL_OSCURO, 2.0),
            *_nino_pie(68, 34, (AMARILLO, AMARILLO_OSCURO), 1),
            L("M74 52 L92 54", PELB, 5.0),
            L("M74 52 L92 54", PEL, 2.8),
        ],
        "Niño apoyándose suavemente sobre un cojín o sillón azul.",
        None,
    ),
    "leap": (
        "D",
        fondo_prado()
        + [
            *nino((80, 20), (76, 32), (72, 46), [[(60, 38), (52, 30)], [(92, 38), (102, 30)]], [[(58, 58), (44, 64)], [(88, 52), (106, 54)]], camisa=(NARANJA, NARANJA_OSCURO), mira=1),
            L("M30 78 Q80 28 130 78", AZUL_OSCURO, 2.0),
            P([(126, 74), (134, 80), (124, 82)], AZUL_OSCURO),
        ],
        "Niño dando un salto largo en arco hacia delante.",
        None,
    ),
    "legs": (
        "D",
        fondo_sala()
        + [
            R(56, 20, 48, 22, 6, AZUL, AZUL_OSCURO, 2.0),
            R(60, 42, 16, 36, 6, PEL, PELB, 2.0),
            R(84, 42, 16, 36, 6, PEL, PELB, 2.0),
            E(66, 80, 9, 5, ROJO, ROJO_OSCURO, 1.8),
            E(94, 80, 9, 5, ROJO, ROJO_OSCURO, 1.8),
            *frecha((34, 58), (56, 58), ROJO_OSCURO),
            *frecha((126, 58), (104, 58), ROJO_OSCURO),
        ],
        "Par de piernas con pantalones cortos y zapatillas señaladas con flechas.",
        None,
    ),
    "lentils": (
        "D",
        fondo_mesa()
        + [
            F("M44 54 L116 54 Q110 82 80 82 Q50 82 44 54 Z", BLANCO, GRIS_OSCURO, 2.2),
            E(80, 54, 36, 7, TIERRA_CLARA, BARRO, 1.8),
            E(62, 52, 4, 3, BARRO),
            E(72, 50, 4, 3, TIERRA),
            E(82, 53, 4, 3, BARRO),
            E(92, 51, 4, 3, TIERRA),
            E(76, 56, 4, 3, VERDE_OSCURO),
            E(88, 55, 4, 3, BARRO),
            E(68, 55, 4, 3, TIERRA),
        ],
        "Cuenco blanco lleno de pequeñas lentejas pardas.",
        None,
    ),
    "let's vote": (
        "D",
        fondo_sala()
        + [
            R(52, 42, 56, 44, 4, AZUL, AZUL_OSCURO, 2.2),
            R(62, 42, 36, 5, 2, NEGRO),
            R(68, 18, 24, 24, 2, BLANCO, GRIS_OSCURO, 1.8),
            L("M74 28 L79 34 L88 22", VERDE_OSCURO, 2.4),
            *frecha((104, 22), (96, 38), ROJO_OSCURO),
        ],
        "Papeleta marcada entrando por la ranura de una urna azul de votación.",
        None,
    ),
    "level": (
        "D",
        fondo_mesa()
        + [
            R(26, 42, 108, 24, 5, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(62, 46, 36, 16, 4, "#dcfce7", VERDE_OSCURO, 1.8),
            L("M72 46 L72 62 M88 46 L88 62", TINTA, 1.5),
            E(80, 54, 5, 5, VERDE, VERDE_OSCURO, 1.4),
        ],
        "Nivel de burbuja amarillo perfectamente horizontal con la burbuja en el centro.",
        None,
    ),
    "library": (
        "D",
        fondo_sala()
        + [
            R(30, 14, 100, 74, 4, MADERA, MADERA_OSCURA, 2.4),
            L("M34 42 L126 42 M34 66 L126 66", MADERA_OSCURA, 3.0),
            R(40, 20, 10, 20, 1, ROJO, ROJO_OSCURO, 1.3),
            R(52, 18, 11, 22, 1, AZUL, AZUL_OSCURO, 1.3),
            R(65, 22, 10, 18, 1, VERDE, VERDE_OSCURO, 1.3),
            R(78, 19, 12, 21, 1, AMARILLO, AMARILLO_OSCURO, 1.3),
            R(94, 20, 10, 20, 1, MORADO, TINTA, 1.3),
            R(42, 46, 12, 18, 1, NARANJA, NARANJA_OSCURO, 1.3),
            R(56, 44, 10, 20, 1, AZUL, AZUL_OSCURO, 1.3),
            R(70, 46, 12, 18, 1, ROSA, ROSA_OSCURO, 1.3),
            R(86, 44, 10, 20, 1, VERDE, VERDE_OSCURO, 1.3),
        ],
        "Estantería de biblioteca llena de libros de muchos colores.",
        None,
    ),
    "life jacket": (
        "D",
        fondo_mar()
        + [
            F("M54 22 L70 22 L74 36 L86 36 L90 22 L106 22 L114 78 L84 78 L80 62 L76 78 L46 78 Z", NARANJA, NARANJA_OSCURO, 2.2),
            R(54, 48, 52, 7, 2, NEGRO),
            R(74, 46, 12, 11, 2, PLATA, TINTA, 1.4),
            R(52, 64, 56, 7, 2, NEGRO),
            R(74, 62, 12, 11, 2, PLATA, TINTA, 1.4),
        ],
        "Chaleco salvavidas naranja con dos cintas negras y hebillas.",
        None,
    ),
    "lift a log": (
        "D",
        fondo_prado()
        + [
            *nino((80, 20), (80, 32), (80, 46), [[(64, 42), (56, 52)], [(96, 42), (104, 52)]], [[(72, 68)], [(88, 68)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            R(44, 50, 72, 14, 6, MADERA, MADERA_OSCURA, 2.2),
            E(46, 57, 4, 7, TIERRA_CLARA, MADERA_OSCURA, 1.6),
            *frecha((32, 62), (32, 40), VERDE_OSCURO),
        ],
        "Niño levantando un tronco de madera grueso con las dos manos.",
        None,
    ),
    "lights, camera, action": (
        "D",
        fondo_sala()
        + [
            R(44, 44, 72, 42, 4, NEGRO, TINTA, 2.2),
            P([(44, 44), (116, 44), (114, 34), (42, 34)], BLANCO, TINTA, 1.8),
            P([(46, 32), (116, 18), (114, 28), (44, 42)], NEGRO, TINTA, 1.8),
            L("M58 34 L66 44 M82 34 L90 44 M102 34 L110 44", NEGRO, 4.0),
            L("M60 28 L68 37 M84 23 L92 32 M104 19 L112 28", BLANCO, 4.0),
        ],
        "Claqueta de cine abierta lista para empezar a rodar.",
        None,
    ),
    "lightweight": (
        "D",
        fondo_sala()
        + [
            L("M80 28 L80 82", GRIS_OSCURO, 3.0),
            L("M44 52 L116 36", MADERA_OSCURA, 2.8),
            R(62, 80, 36, 6, 2, GRIS_OSCURO, TINTA, 1.6),
            E(46, 64, 14, 12, GRIS, TINTA, 2.0),
            F("M106 28 Q116 14 128 20 Q118 34 106 28 Z", BLANCO, AZUL_OSCURO, 1.8),
            *frecha((116, 44), (116, 28), AZUL_OSCURO),
        ],
        "Balanza inclinada donde una pluma blanca sube ligera frente a una piedra.",
        None,
    ),
    "line them up": (
        "D",
        fondo_mesa()
        + [
            R(28, 52, 20, 20, 3, ROJO, ROJO_OSCURO, 2.0),
            R(56, 52, 20, 20, 3, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(84, 52, 20, 20, 3, VERDE, VERDE_OSCURO, 2.0),
            R(112, 52, 20, 20, 3, AZUL, AZUL_OSCURO, 2.0),
            *frecha((34, 40), (126, 40), TINTA),
        ],
        "Cuatro bloques de colores colocados perfectamente en fila recta.",
        None,
    ),
    "line up by size": (
        "D",
        fondo_mesa()
        + [
            R(26, 66, 14, 14, 3, AZUL, AZUL_OSCURO, 1.8),
            R(50, 56, 20, 24, 3, VERDE, VERDE_OSCURO, 1.8),
            R(80, 44, 26, 36, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(114, 30, 30, 50, 3, ROJO, ROJO_OSCURO, 1.8),
            *frecha((28, 22), (138, 22), TINTA),
        ],
        "Cuatro bloques ordenados en fila creciente de pequeño a grande.",
        None,
    ),
    "little": (
        "D",
        fondo_sala()
        + [
            E(56, 54, 16, 14, PEL, PELB, 2.0),
            L("M66 44 L86 38", PELB, 5.2),
            L("M66 44 L86 38", PEL, 3.0),
            L("M68 62 L86 58", PELB, 5.2),
            L("M68 62 L86 58", PEL, 3.0),
            E(96, 48, 4.5, 4.5, ROJO, ROJO_OSCURO, 1.6),
            *frecha((96, 34), (96, 42), TINTA),
            *frecha((96, 62), (96, 54), TINTA),
        ],
        "Dedos pulgar e índice haciendo el gesto de tamaño muy pequeño sobre una bolita.",
        None,
    ),
    "little finger": (
        "D",
        fondo_sala()
        + [
            E(76, 62, 16, 18, PEL, PELB, 2.0),
            L("M62 52 L58 26", PELB, 5.2),
            L("M62 52 L58 26", PEL, 3.0),
            L("M70 46 L70 20", PELB, 5.2),
            L("M70 46 L70 20", PEL, 3.0),
            L("M80 46 L82 22", PELB, 5.2),
            L("M80 46 L82 22", PEL, 3.0),
            L("M90 54 L100 38", ROJO_OSCURO, 6.0),
            L("M90 54 L100 38", PEL, 3.2),
            E(100, 38, 4, 4, ROJO),
            *frecha((122, 34), (106, 38), ROJO_OSCURO),
        ],
        "Mano abierta señalando con una flecha el dedo meñique.",
        None,
    ),
    "load": (
        "D",
        fondo_prado()
        + [
            F("M44 52 L110 52 L100 72 L52 72 Z", VERDE, VERDE_OSCURO, 2.0),
            E(104, 76, 8, 8, NEGRO, GRIS_OSCURO, 2.0),
            L("M44 54 L26 48", MADERA_OSCURA, 3.0),
            R(58, 36, 22, 18, 2, MADERA, MADERA_OSCURA, 1.8),
            R(80, 20, 22, 18, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            *frecha((90, 14), (90, 46), ROJO_OSCURO),
        ],
        "Carretilla verde cargándose con cajas de madera desde arriba.",
        None,
    ),
    "look at old photos": (
        "D",
        fondo_mesa()
        + [
            *libro_prop(46, 30, 68, MADERA_OSCURA),
            R(52, 36, 26, 22, 2, "#f1f5f9", GRIS_OSCURO, 1.4),
            E(65, 45, 5, 5, GRIS_OSCURO),
            R(84, 36, 26, 22, 2, "#f1f5f9", GRIS_OSCURO, 1.4),
            P([(86, 56), (95, 42), (106, 56)], GRIS_OSCURO),
            L("M56 66 L74 66 M88 66 L106 66", GRIS, 1.8),
        ],
        "Álbum abierto con fotografías antiguas en blanco y negro.",
        None,
    ),
    "look closely": (
        "D",
        fondo_sala()
        + [
            E(56, 56, 12, 7, VERDE, VERDE_OSCURO, 1.8),
            E(72, 42, 18, 18, "#e0f2fe", AZUL_OSCURO, 2.6),
            L("M85 55 L106 76", MADERA_OSCURA, 4.2),
            E(70, 42, 8, 4.5, VERDE, VERDE_OSCURO, 1.6),
            E(34, 42, 9, 6, BLANCO, TINTA, 1.8),
            E(34, 42, 3, 3, AZUL_OSCURO),
        ],
        "Ojo mirando muy de cerca una hoja a través de una lupa grande.",
        None,
    ),
    "look through binoculars": (
        "D",
        fondo_prado()
        + [
            *nino_busto(80, 44, (AZUL, AZUL_OSCURO)),
            R(62, 34, 16, 12, 4, NEGRO, TINTA, 2.0),
            R(82, 34, 16, 12, 4, NEGRO, TINTA, 2.0),
            E(70, 40, 4.5, 4.5, "#bae6fd"),
            E(90, 40, 4.5, 4.5, "#bae6fd"),
            R(76, 38, 8, 4, 1, GRIS_OSCURO),
        ],
        "Niño mirando a lo lejos a través de unos prismáticos negros.",
        None,
    ),
    "loose": (
        "D",
        fondo_mesa()
        + [
            R(68, 22, 24, 56, 4, MADERA, MADERA_OSCURA, 2.0),
            L("M52 44 Q80 62 108 44", ROJO, 3.2),
            L("M52 44 Q80 28 108 44", ROJO, 2.6),
            *frecha((54, 62), (42, 62), AZUL_OSCURO),
            *frecha((106, 62), (118, 62), AZUL_OSCURO),
        ],
        "Cinta roja muy floja y suelta alrededor de un poste de madera.",
        None,
    ),
    "lunch mat": (
        "D",
        fondo_mesa()
        + [
            R(34, 34, 92, 48, 4, "#fef08a", NARANJA_OSCURO, 2.2),
            L("M38 42 L122 42 M38 74 L122 74", ROJO, 1.8),
            *plato_prop(80, 58, 16),
            R(106, 44, 10, 16, 2, "#bae6fd", AZUL_OSCURO, 1.6),
        ],
        "Mantel individual amarillo sobre la mesa con un plato y un vaso encima.",
        None,
    ),
    "lunge": (
        "D",
        fondo_prado()
        + [
            *nino((78, 26), (78, 38), (78, 52), [[(64, 44)], [(92, 44)]], [[(58, 64), (44, 78)], [(96, 58), (96, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *frecha((106, 70), (126, 70), ROJO_OSCURO),
        ],
        "Niño haciendo una zancada profunda con una pierna flexionada adelante.",
        None,
    ),
    "make a card": (
        "D",
        fondo_mesa()
        + [
            P([(44, 30), (80, 22), (80, 74), (44, 82)], "#fef3c7", NARANJA_OSCURO, 2.0),
            P([(80, 22), (116, 30), (116, 82), (80, 74)], BLANCO, NARANJA_OSCURO, 2.0),
            F("M92 48 C92 42 98 42 98 48 C98 42 104 42 104 48 C104 54 98 59 98 59 C98 59 92 54 92 48 Z", ROJO),
            L("M110 18 L124 32", AMARILLO_OSCURO, 3.5),
            P([(106, 18), (110, 14), (114, 18)], TINTA),
        ],
        "Postal de cartulina doblada con un corazón dibujado y lápiz.",
        None,
    ),
    "make a circle": (
        "D",
        fondo_prado()
        + [
            L("M52 34 L108 34 L108 72 L52 72 Z", HERBA, 1.0),
            E(80, 52, 28, 22, HERBA, VERDE_OSCURO, 2.2),
            E(80, 26, 8, 8, PEL, PELB, 1.8),
            E(80, 78, 8, 8, PEL, PELB, 1.8),
            E(48, 52, 8, 8, PEL, PELB, 1.8),
            E(112, 52, 8, 8, PEL, PELB, 1.8),
            E(80, 26, 4, 4, ROJO),
            E(80, 78, 4, 4, AZUL),
            E(48, 52, 4, 4, AMARILLO),
            E(112, 52, 4, 4, MORADO),
        ],
        "Cuatro niños cogidos de la mano formando un círculo completo en el prado.",
        None,
    ),
    "marble": (
        "D",
        fondo_mesa()
        + [
            E(80, 52, 22, 22, AZUL, AZUL_OSCURO, 2.4),
            L("M66 44 Q80 60 94 42 M68 62 Q82 48 94 64", "#bae6fd", 4.0),
            E(72, 40, 5, 3, BLANCO),
        ],
        "Canica de cristal azul brillante con vetas interiores claras.",
        None,
    ),
    "mark the date": (
        "D",
        fondo_sala()
        + [
            R(44, 20, 72, 66, 5, BLANCO, GRIS_OSCURO, 2.2),
            R(44, 20, 72, 16, 4, ROJO, ROJO_OSCURO, 2.0),
            E(60, 52, 4, 4, GRIS),
            E(80, 52, 4, 4, GRIS),
            E(100, 52, 4, 4, GRIS),
            E(60, 70, 4, 4, GRIS),
            E(80, 70, 6, 6, ROJO, ROJO_OSCURO, 1.6),
            E(80, 70, 12, 10, "#fecaca", ROJO_OSCURO, 2.2),
            E(100, 70, 4, 4, GRIS),
        ],
        "Hoja de calendario con un día concreto rodeado por un círculo rojo.",
        None,
    ),
    "market": (
        "D",
        fondo_cielo()
        + [
            R(36, 52, 88, 34, 3, MADERA, MADERA_OSCURA, 2.2),
            L("M42 32 L42 52 M118 32 L118 52", MADERA_OSCURA, 3.0),
            P([(30, 34), (130, 34), (120, 18), (40, 18)], ROJO, ROJO_OSCURO, 2.0),
            R(50, 18, 18, 16, 0, BLANCO),
            R(86, 18, 18, 16, 0, BLANCO),
            E(56, 46, 5, 5, ROJO, ROJO_OSCURO, 1.4),
            E(68, 46, 5, 5, ROJO, ROJO_OSCURO, 1.4),
            E(88, 46, 5, 5, NARANJA, NARANJA_OSCURO, 1.4),
            E(100, 46, 5, 5, NARANJA, NARANJA_OSCURO, 1.4),
        ],
        "Puesto de mercado al aire libre con toldo rojo y blanco y cajas de fruta.",
        None,
    ),
    "mash": (
        "D",
        fondo_mesa()
        + [
            F("M44 54 L116 54 Q110 82 80 82 Q50 82 44 54 Z", BLANCO, GRIS_OSCURO, 2.2),
            E(80, 56, 28, 7, AMARILLO, AMARILLO_OSCURO, 1.8),
            L("M88 22 L80 54", GRIS_OSCURO, 3.0),
            L("M74 50 L86 52 M76 54 L80 58", GRIS_OSCURO, 2.0),
            *frecha((60, 28), (60, 48), NARANJA_OSCURO),
        ],
        "Tenedor aplastando alimento blando amarillo dentro de un cuenco.",
        None,
    ),
    "mask maker": (
        "D",
        fondo_mesa()
        + [
            P([(48, 34), (112, 34), (104, 62), (80, 56), (56, 62)], MORADO, TINTA, 2.0),
            E(66, 46, 7, 5, BLANCO, TINTA, 1.6),
            E(94, 46, 7, 5, BLANCO, TINTA, 1.6),
            L("M110 72 L126 52", MADERA_OSCURA, 3.0),
            E(128, 48, 4, 5, ROJO, ROJO_OSCURO, 1.4),
        ],
        "Máscara de colores decorada sobre mesa junto a un pincel de pintura.",
        None,
    ),
    "massage feet": (
        "D",
        fondo_sala()
        + [
            E(82, 54, 18, 28, PEL, PELB, 2.2),
            E(66, 30, 3, 3.5, PEL, PELB, 1.3),
            E(73, 27, 3, 3.5, PEL, PELB, 1.3),
            E(81, 27, 3, 3.5, PEL, PELB, 1.3),
            E(89, 29, 3, 3.5, PEL, PELB, 1.3),
            E(96, 33, 2.8, 3.2, PEL, PELB, 1.3),
            L("M56 54 Q66 64 58 74", PELB, 5.0),
            L("M56 54 Q66 64 58 74", PEL, 3.0),
            L("M74 52 Q82 46 90 52 Q82 58 74 52", ROSA_OSCURO, 1.8),
        ],
        "Mano masajeando suavemente la planta de un pie descalzo en círculos.",
        None,
    ),
    "mast": (
        "D",
        fondo_mar()
        + [
            F("M44 74 L116 74 L106 86 L54 86 Z", MADERA, MADERA_OSCURA, 2.0),
            R(77, 14, 6, 60, 2, MADERA_OSCURA, TINTA, 1.8),
            P([(83, 18), (108, 24), (83, 30)], ROJO, ROJO_OSCURO, 1.6),
            *frecha((64, 66), (64, 22), TINTA),
        ],
        "Mástil vertical alto de madera en una barca con banderín rojo en lo alto.",
        None,
    ),
    "mat": (
        "D",
        fondo_sala()
        + [
            P([(30, 58), (118, 58), (132, 80), (22, 80)], MORADO, "#5b21b6", 2.2),
            E(118, 66, 10, 14, "#c4b5fd", "#5b21b6", 2.0),
            E(118, 66, 4, 6, "#5b21b6"),
        ],
        "Esterilla morada extendida en el suelo con un extremo enrollado.",
        None,
    ),
    "match": (
        "D",
        fondo_mesa()
        + [
            R(30, 28, 36, 46, 5, "#fde68a", AMARILLO_OSCURO, 2.0),
            _estrella(48, 51, 11, 5, ROJO, ROJO_OSCURO),
            R(94, 28, 36, 46, 5, "#fde68a", AMARILLO_OSCURO, 2.0),
            _estrella(112, 51, 11, 5, ROJO, ROJO_OSCURO),
            L("M66 51 L94 51", VERDE_OSCURO, 2.8),
        ],
        "Dos tarjetas con exactamente la misma estrella roja unidas por una línea.",
        None,
    ),
    "match colours": (
        "D",
        fondo_mesa()
        + [
            E(42, 34, 11, 11, ROJO, ROJO_OSCURO, 2.0),
            E(118, 34, 11, 11, ROJO, ROJO_OSCURO, 2.0),
            L("M55 34 L105 34", ROJO_OSCURO, 2.2),
            E(42, 68, 11, 11, AZUL, AZUL_OSCURO, 2.0),
            E(118, 68, 11, 11, AZUL, AZUL_OSCURO, 2.0),
            L("M55 68 L105 68", AZUL_OSCURO, 2.2),
        ],
        "Parejas de círculos rojos y azules unidos con su color correspondiente.",
        None,
    ),
    "measure": (
        "D",
        fondo_mesa()
        + [
            R(36, 36, 88, 22, 3, MADERA, MADERA_OSCURA, 2.0),
            R(30, 62, 100, 14, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M40 62 L40 68 M50 62 L50 66 M60 62 L60 68 M70 62 L70 66 M80 62 L80 68 M90 62 L90 66 M100 62 L100 66 M110 62 L110 68 M120 62 L120 66", TINTA, 1.5),
        ],
        "Regla graduada midiendo la longitud exacta de una tabla de madera.",
        None,
    ),
    "measure height": (
        "D",
        fondo_sala()
        + [
            R(106, 14, 14, 72, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M106 24 L114 24 M106 36 L112 36 M106 48 L114 48 M106 60 L112 60 M106 72 L114 72", TINTA, 1.6),
            *_nino_pie(74, 34, (VERDE, VERDE_OSCURO), 1),
            L("M74 26 L108 26", ROJO_OSCURO, 2.0),
        ],
        "Niño junto a un medidor de pared con marcas de altura hasta su cabeza.",
        None,
    ),
    "measure with hands": (
        "D",
        fondo_mesa()
        + [
            R(28, 52, 104, 24, 3, AZUL, AZUL_OSCURO, 2.0),
            *_mano(52, 38),
            *_mano(104, 38),
            L("M52 46 L104 46", TINTA, 1.6),
        ],
        "Dos manos extendidas a palmos midiendo el ancho de un objeto azul.",
        None,
    ),
    "measuring cup": (
        "D",
        fondo_mesa()
        + [
            F("M54 24 L106 24 L98 82 L62 82 Z", "#e0f2fe", AZUL_OSCURO, 2.2),
            F("M60 54 L100 54 L96 80 L64 80 Z", AGUA),
            L("M104 34 Q118 34 118 50 Q118 66 100 66", AZUL_OSCURO, 3.0),
            L("M66 36 L76 36 M66 48 L76 48 M66 60 L76 60 M66 72 L76 72", TINTA, 1.8),
        ],
        "Jarra medidora transparente con escala lateral llena hasta la mitad.",
        None,
    ),
    "melt": (
        "D",
        fondo_prado()
        + [
            *_sol(128, 22, 9),
            E(80, 76, 36, 10, "#bae6fd", AGUA_OSCURO, 2.0),
            R(64, 44, 32, 30, 5, "#e0f2fe", AGUA_OSCURO, 2.2),
            F("M66 66 Q80 62 94 66 Q100 76 80 78 Q60 76 66 66 Z", "#bae6fd"),
            *gotas([(60, 62), (100, 62)]),
        ],
        "Cubito de hielo derritiéndose en un charco de agua bajo el sol.",
        None,
    ),
    "mend": (
        "D",
        fondo_mesa()
        + [
            R(44, 28, 72, 50, 6, AZUL, AZUL_OSCURO, 2.2),
            R(68, 42, 24, 20, 3, NARANJA, NARANJA_OSCURO, 1.8),
            L("M66 46 L72 46 M66 56 L72 56 M88 46 L94 46 M88 56 L94 56 M74 40 L74 44 M86 40 L86 44", BLANCO, 1.6),
            L("M96 36 L116 20", GRIS_OSCURO, 2.2),
        ],
        "Prenda azul reparada con un parche naranja cosido y aguja.",
        None,
    ),
    "milestone": (
        "D",
        fondo_prado()
        + [
            F("M20 88 Q74 72 140 88 L140 100 L20 100 Z", TIERRA_CLARA, BARRO, 1.6),
            F("M62 78 L62 42 Q80 24 98 42 L98 78 Z", BLANCO, GRIS_OSCURO, 2.4),
            R(62, 66, 36, 12, 0, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Hito de piedra blanco con base roja señalando un punto del camino.",
        None,
    ),
    "mirror a friend": (
        "D",
        fondo_sala()
        + [
            *nino((48, 28), (48, 40), (48, 56), [[(34, 48)], [(62, 40), (68, 30)]], [[(42, 78)], [(54, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *nino((112, 28), (112, 40), (112, 56), [[(98, 40), (92, 30)], [(126, 48)]], [[(106, 78)], [(118, 78)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
            L("M80 18 L80 82", GRIS_OSCURO, 2.0),
        ],
        "Dos niños frente a frente copiando exactamente el gesto como en un espejo.",
        None,
    ),
    "mirror line": (
        "D",
        fondo_sala()
        + [
            E(56, 44, 18, 12, MORADO, TINTA, 1.8),
            E(60, 62, 13, 10, NARANJA, NARANJA_OSCURO, 1.8),
            E(104, 44, 18, 12, MORADO, TINTA, 1.8),
            E(100, 62, 13, 10, NARANJA, NARANJA_OSCURO, 1.8),
            R(77, 36, 6, 40, 3, NEGRO),
            L("M80 14 L80 24 M80 30 L80 40 M80 46 L80 56 M80 62 L80 72 M80 78 L80 88", ROJO_OSCURO, 2.2),
        ],
        "Mariposa simétrica dividida por una línea vertical discontinua en el centro.",
        None,
    ),
    "mood meter": (
        "D",
        fondo_sala()
        + [
            R(50, 18, 30, 32, 3, ROJO, TINTA, 1.6),
            R(80, 18, 30, 32, 3, AMARILLO, TINTA, 1.6),
            R(50, 50, 30, 32, 3, AZUL, TINTA, 1.6),
            R(80, 50, 30, 32, 3, VERDE, TINTA, 1.6),
            E(95, 34, 6, 6, BLANCO, TINTA, 2.0),
        ],
        "Panel de cuatro cuadrantes de colores de emociones con marcador circular.",
        None,
    ),
    "mould": (
        "D",
        fondo_prado()
        + [
            F("M34 46 L70 46 L64 78 L40 78 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            F("M92 52 L124 52 L118 78 L98 78 Z", "#fde68a", BARRO, 2.0),
            *frecha((72, 36), (104, 36), BARRO),
        ],
        "Molde amarillo de playa junto a su figura hecha de arena.",
        None,
    ),
    "move forward": (
        "D",
        fondo_prado()
        + [
            *nino_corriendo(56, 30, 1, (VERDE, VERDE_OSCURO)),
            *frecha((90, 54), (132, 54), VERDE_OSCURO),
        ],
        "Niño caminando hacia delante siguiendo una gran flecha verde.",
        None,
    ),
    "muddy pig": (
        "D",
        fondo_prado()
        + [
            E(80, 74, 36, 10, BARRO, NEGRO, 1.8),
            E(80, 52, 22, 16, ROSA, ROSA_OSCURO, 2.2),
            E(60, 44, 12, 11, ROSA, ROSA_OSCURO, 2.2),
            E(52, 45, 5, 4, "#fbcfe8", ROSA_OSCURO, 1.6),
            E(58, 40, 1.5, 1.5, TINTA),
            E(76, 54, 5, 3.5, BARRO),
            E(90, 48, 4.5, 3, BARRO),
            L("M66 66 L66 74 M92 66 L92 74", ROSA_OSCURO, 4.0),
        ],
        "Cerdito rosa con manchas marrones chapoteando en un charco de barro.",
        None,
    ),
    "mug": (
        "D",
        fondo_mesa()
        + [
            R(56, 36, 42, 46, 6, ROJO, ROJO_OSCURO, 2.2),
            L("M98 44 Q116 44 116 58 Q116 72 98 72", ROJO_OSCURO, 4.0),
            L("M68 28 Q64 20 70 14 M82 28 Q78 20 84 14", GRIS_OSCURO, 2.0),
        ],
        "Taza roja grande con asa echando un suave vapor caliente.",
        None,
    ),
    "mushy peach": (
        "D",
        fondo_mesa()
        + [
            E(80, 56, 26, 20, NARANJA, NARANJA_OSCURO, 2.2),
            E(80, 58, 12, 9, AMARILLO, NARANJA_OSCURO, 1.4),
            L("M78 36 L88 26", VERDE_OSCURO, 2.5),
            *gotas([(60, 74), (100, 72)]),
        ],
        "Melocotón maduro aplastado y blando soltando gotas dulces.",
        None,
    ),
    "music box": (
        "D",
        fondo_mesa()
        + [
            R(50, 44, 60, 38, 4, MADERA, MADERA_OSCURA, 2.2),
            P([(50, 44), (110, 44), (104, 24), (56, 24)], TIERRA_CLARA, MADERA_OSCURA, 2.0),
            L("M110 62 L122 62 L122 54 M122 62 L122 70", AMARILLO_OSCURO, 2.5),
            *notas_col([(74, 28), (92, 22)], MORADO),
        ],
        "Caja de música de madera abierta con manivela lateral y notas musicales.",
        None,
    ),
    "narrow street": (
        "D",
        fondo_cielo()
        + [
            R(14, 18, 46, 68, 2, TIERRA_CLARA, BARRO, 2.0),
            R(100, 18, 46, 68, 2, ROJO, ROJO_OSCURO, 2.0),
            P([(60, 86), (100, 86), (92, 46), (68, 46)], GRIS, GRIS_OSCURO, 1.8),
            R(26, 30, 18, 18, 2, "#fef08a", TINTA, 1.4),
            R(116, 30, 18, 18, 2, "#fef08a", TINTA, 1.4),
            *frecha((52, 66), (66, 66), AZUL_OSCURO),
            *frecha((108, 66), (94, 66), AZUL_OSCURO),
        ],
        "Callejuela estrecha encajada entre dos casas muy juntas.",
        None,
    ),
    "neat": (
        "D",
        fondo_sala()
        + [
            R(26, 72, 108, 10, 2, MADERA, MADERA_OSCURA, 1.8),
            R(40, 56, 20, 16, 5, AZUL, AZUL_OSCURO, 1.8),
            R(64, 56, 20, 16, 5, AZUL, AZUL_OSCURO, 1.8),
            R(92, 56, 20, 16, 5, ROJO, ROJO_OSCURO, 1.8),
            R(116, 56, 20, 16, 5, ROJO, ROJO_OSCURO, 1.8),
            L("M34 42 L130 42", VERDE_OSCURO, 2.0),
        ],
        "Zapatos perfectamente ordenados por parejas en fila sobre una balda.",
        None,
    ),
    "neigh": (
        "D",
        fondo_prado()
        + [
            P([(52, 84), (60, 42), (82, 26), (96, 40), (88, 56), (72, 58), (68, 84)], TIERRA, BARRO, 2.2),
            P([(72, 28), (76, 16), (82, 26)], TIERRA, BARRO, 1.6),
            E(80, 36, 2, 2, TINTA),
            L("M90 48 L96 48", BARRO, 2.2),
            *ondas_sonido(104, 40, ROJO_OSCURO, 1),
        ],
        "Cabeza de caballo relinchando con ondas sonoras saliendo de la boca.",
        None,
    ),
    "nibble": (
        "D",
        fondo_mesa()
        + [
            E(58, 62, 16, 12, GRIS, GRIS_OSCURO, 2.0),
            E(72, 56, 9, 8, GRIS, GRIS_OSCURO, 2.0),
            E(68, 46, 5, 5, ROSA, GRIS_OSCURO, 1.6),
            E(74, 54, 1.4, 1.4, TINTA),
            P([(92, 68), (120, 68), (110, 44)], AMARILLO, AMARILLO_OSCURO, 2.0),
            E(102, 60, 3, 3, AMARILLO_OSCURO),
            E(110, 63, 2.5, 2.5, AMARILLO_OSCURO),
        ],
        "Ratoncito mordisqueando suavemente una cuña de queso amarillo.",
        None,
    ),
    "night light": (
        "D",
        fondo_noite()
        + [
            R(36, 68, 88, 18, 3, MADERA, MADERA_OSCURA, 2.0),
            E(80, 46, 24, 22, "#fef08a"),
            R(70, 56, 20, 12, 3, BLANCO, GRIS_OSCURO, 1.6),
            E(80, 44, 12, 14, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(80, 44, 5, 6, BLANCO),
        ],
        "Pequeña luz quitamiedos encendida suavemente en la mesilla de noche.",
        None,
    ),
    "noisy engine": (
        "D",
        fondo_sala()
        + [
            R(44, 38, 66, 38, 6, GRIS, GRIS_OSCURO, 2.2),
            R(54, 28, 34, 12, 3, GRIS_OSCURO, TINTA, 1.8),
            E(92, 56, 10, 10, AMARILLO, TINTA, 1.8),
            L("M34 44 L30 56 L36 68 M118 44 L122 56 L116 68", ROJO_OSCURO, 2.2),
            *ondas_sonido(120, 48, ROJO_OSCURO, 1),
            *ondas_sonido(38, 48, ROJO_OSCURO, -1),
        ],
        "Motor metálico vibrando con fuertes ondas de ruido alrededor.",
        None,
    ),
    "noisy farm": (
        "D",
        fondo_prado()
        + [
            P([(48, 42), (80, 20), (112, 42), (112, 80), (48, 80)], ROJO, ROJO_OSCURO, 2.2),
            R(70, 56, 20, 24, 2, BLANCO, ROJO_OSCURO, 1.8),
            *ondas_sonido(34, 46, AMARILLO_OSCURO, -1),
            *ondas_sonido(124, 46, AMARILLO_OSCURO, 1),
            *notas_col([(80, 12)], ROJO_OSCURO),
        ],
        "Granero rojo de granja rodeado de ondas sonoras de animales.",
        None,
    ),
    "nutritious": (
        "D",
        fondo_mesa()
        + [
            *plato_prop(80, 56, 30),
            E(66, 52, 9, 9, VERDE, VERDE_OSCURO, 1.8),
            E(72, 46, 7, 7, VERDE, VERDE_OSCURO, 1.8),
            P([(84, 58), (104, 46), (100, 62)], NARANJA, NARANJA_OSCURO, 1.8),
            E(82, 64, 7, 7, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Plato con verduras y fruta fresca variadas: brócoli, zanahoria y manzana.",
        None,
    ),
    "oak tree": (
        "D",
        fondo_prado()
        + [
            R(70, 46, 20, 40, 3, TIERRA, BARRO, 2.2),
            E(80, 34, 34, 22, VERDE, VERDE_OSCURO, 2.2),
            E(60, 40, 18, 14, VERDE, VERDE_OSCURO, 1.8),
            E(100, 40, 18, 14, VERDE, VERDE_OSCURO, 1.8),
            *bellota_prop(26, 60, 22),
            *bellota_prop(112, 60, 22),
        ],
        "Roble frondoso de copa ancha verde con bellotas a los lados.",
        None,
    ),
    "obstacle course": (
        "D",
        fondo_prado()
        + [
            P([(28, 78), (38, 48), (48, 78)], NARANJA, NARANJA_OSCURO, 1.8),
            E(80, 68, 16, 7, AMARILLO, AMARILLO_OSCURO, 2.4),
            L("M112 78 L112 52 L134 52 L134 78", AZUL_OSCURO, 2.8),
            L("M28 40 Q54 24 80 42 Q106 24 128 42", ROJO_OSCURO, 2.0),
        ],
        "Circuito de obstáculos con cono naranja, aro amarillo y valla para saltar.",
        None,
    ),
    "olive tree": (
        "D",
        fondo_prado()
        + [
            F("M72 86 Q68 64 76 46 L86 46 Q90 66 86 86 Z", MADERA, MADERA_OSCURA, 2.2),
            E(80, 34, 34, 18, "#65a30d", VERDE_OSCURO, 2.2),
            E(66, 36, 4, 5, "#365314"),
            E(82, 28, 4, 5, "#365314"),
            E(96, 38, 4, 5, "#365314"),
            E(74, 40, 4, 5, "#1e293b"),
        ],
        "Olivo de tronco retorcido y hojas verdes cargado de aceitunas.",
        None,
    ),
    "on and off": (
        "D",
        fondo_sala()
        + [
            E(50, 44, 16, 18, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(44, 60, 12, 10, 2, GRIS_OSCURO),
            L("M50 20 L50 14 M30 30 L24 26 M70 30 L76 26", AMARILLO_OSCURO, 2.2),
            E(110, 44, 16, 18, GRIS, GRIS_OSCURO, 2.2),
            R(104, 60, 12, 10, 2, GRIS_OSCURO),
        ],
        "Bombilla amarilla encendida a la izquierda y bombilla apagada a la derecha.",
        None,
    ),
    "on the tree": (
        "D",
        fondo_prado()
        + [
            R(74, 62, 12, 24, 2, TIERRA, BARRO, 2.0),
            P([(80, 14), (42, 66), (118, 66)], VERDE, VERDE_OSCURO, 2.2),
            E(74, 34, 5, 5, ROJO, ROJO_OSCURO, 1.4),
            E(88, 46, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.4),
            E(66, 54, 5, 5, AZUL, AZUL_OSCURO, 1.4),
            E(92, 58, 5, 5, ROSA, ROSA_OSCURO, 1.4),
        ],
        "Árbol verde decorado con bolas de colores colgadas en sus ramas.",
        None,
    ),
    "one peg, two pegs": (
        "D",
        fondo_sala()
        + [
            L("M20 36 L140 36", TINTA, 2.2),
            R(44, 28, 10, 32, 2, ROJO, ROJO_OSCURO, 1.8),
            R(92, 28, 10, 32, 2, AZUL, AZUL_OSCURO, 1.8),
            R(108, 28, 10, 32, 2, AZUL, AZUL_OSCURO, 1.8),
            E(49, 72, 4, 4, ROJO_OSCURO),
            E(97, 72, 4, 4, AZUL_OSCURO),
            E(113, 72, 4, 4, AZUL_OSCURO),
        ],
        "Cuerda tendida con una pinza roja a un lado y dos pinzas azules al otro.",
        None,
    ),
    "orchard": (
        "D",
        fondo_prado()
        + [
            R(36, 54, 10, 28, 2, TIERRA, BARRO, 1.8),
            E(41, 42, 20, 16, VERDE, VERDE_OSCURO, 1.8),
            E(34, 40, 3.5, 3.5, ROJO),
            E(46, 44, 3.5, 3.5, ROJO),
            R(75, 52, 10, 30, 2, TIERRA, BARRO, 1.8),
            E(80, 40, 20, 16, VERDE, VERDE_OSCURO, 1.8),
            E(74, 38, 3.5, 3.5, NARANJA),
            E(86, 42, 3.5, 3.5, NARANJA),
            R(114, 54, 10, 28, 2, TIERRA, BARRO, 1.8),
            E(119, 42, 20, 16, VERDE, VERDE_OSCURO, 1.8),
            E(113, 40, 3.5, 3.5, AMARILLO),
            E(124, 44, 3.5, 3.5, AMARILLO),
        ],
        "Huerto de tres árboles frutales cargados de manzanas, naranjas y peras.",
        None,
    ),
    "order": (
        "D",
        fondo_mesa()
        + [
            R(34, 58, 16, 18, 2, AZUL, AZUL_OSCURO, 1.8),
            R(62, 44, 24, 32, 2, VERDE, VERDE_OSCURO, 1.8),
            R(98, 28, 32, 48, 2, ROJO, ROJO_OSCURO, 1.8),
            *frecha((34, 22), (126, 22), TINTA),
        ],
        "Tres piezas ordenadas de menor a mayor en estricta secuencia.",
        None,
    ),
    "ornament": (
        "D",
        fondo_sala()
        + [
            L("M80 10 L80 24", DORADO, 2.0),
            R(72, 22, 16, 8, 2, DORADO, MADERA_OSCURA, 1.8),
            E(80, 56, 26, 26, ROJO, ROJO_OSCURO, 2.4),
            L("M56 54 Q80 66 104 54 M58 44 Q80 56 102 44", AMARILLO, 2.8),
        ],
        "Adorno brillante rojo con franjas doradas y cinta para colgar.",
        None,
    ),
    "out of the basket": (
        "D",
        fondo_sala()
        + [
            F("M48 48 L112 48 L104 82 L56 82 Z", MADERA, MADERA_OSCURA, 2.2),
            L("M54 58 L106 58 M56 70 L104 70", MADERA_OSCURA, 1.6),
            *pelota_prop(80, 22, 11, ROJO, ROJO_OSCURO),
            *frecha((80, 50), (80, 34), VERDE_OSCURO),
        ],
        "Pelota roja saliendo hacia fuera de una cesta de mimbre.",
        None,
    ),
    "out of the egg": (
        "D",
        fondo_prado()
        + [
            F("M56 60 L66 66 L74 58 L84 66 L94 58 L104 64 Q102 84 80 84 Q58 84 56 60 Z", "#fef3c7", MADERA_OSCURA, 2.2),
            E(80, 44, 16, 16, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(75, 42, 1.6, 1.6, TINTA),
            E(85, 42, 1.6, 1.6, TINTA),
            P([(77, 46), (83, 46), (80, 51)], NARANJA, NARANJA_OSCURO, 1.4),
            *frecha((42, 62), (42, 34), VERDE_OSCURO),
        ],
        "Pollito amarillo saliendo hacia arriba del cascarón partido.",
        None,
    ),
    "over the log": (
        "D",
        fondo_prado()
        + [
            R(62, 66, 36, 16, 6, MADERA, MADERA_OSCURA, 2.2),
            *nino((48, 22), (50, 34), (54, 48), [[(38, 42)], [(66, 40)]], [[(42, 74)], [(78, 52), (96, 68)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            L("M44 58 Q80 34 114 62", AZUL_OSCURO, 2.0),
            P([(110, 58), (118, 64), (108, 66)], AZUL_OSCURO),
        ],
        "Niño pasando la pierna por encima de un tronco caído en el prado.",
        None,
    ),
    "over the stone": (
        "D",
        fondo_prado()
        + [
            E(80, 74, 20, 12, GRIS, GRIS_OSCURO, 2.2),
            *nino((46, 22), (48, 34), (52, 48), [[(36, 42)], [(64, 40)]], [[(40, 76)], [(76, 52), (100, 68)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            L("M42 54 Q80 28 118 58", AZUL_OSCURO, 2.0),
            P([(114, 54), (122, 60), (112, 62)], AZUL_OSCURO),
        ],
        "Niño dando una zancada larga por encima de una piedra grande.",
        None,
    ),
    "over the waves": (
        "D",
        fondo_mar()
        + [
            L("M16 68 Q34 54 52 68 Q70 82 88 68 Q106 54 124 68 Q138 78 148 68", AGUA_OSCURO, 3.0),
            F("M62 42 L98 42 L90 54 L70 54 Z", ROJO, ROJO_OSCURO, 1.8),
            P([(80, 20), (80, 40), (96, 40)], BLANCO, TINTA, 1.5),
            L("M44 38 Q80 14 116 38", AMARILLO_OSCURO, 2.2),
            P([(112, 34), (120, 40), (110, 42)], AMARILLO_OSCURO),
        ],
        "Barquito pasando por encima de grandes olas azules siguiendo un arco.",
        None,
    ),
    "overflowing": (
        "D",
        fondo_mesa()
        + [
            F("M54 32 L106 32 L98 84 L62 84 Z", "#e0f2fe", AZUL_OSCURO, 2.2),
            F("M54 34 L106 34 L98 82 L62 82 Z", AGUA),
            L("M54 34 Q42 46 46 70 M106 34 Q118 46 114 70", AGUA_OSCURO, 3.0),
            *gotas([(44, 78), (116, 78)]),
        ],
        "Vaso completamente lleno con el agua desbordándose por ambos bordes.",
        None,
    ),
    "overpass": (
        "D",
        fondo_cielo()
        + [
            R(10, 74, 140, 18, 0, GRIS_OSCURO),
            L("M20 83 L140 83", BLANCO, 2.0),
            F("M18 52 Q80 28 142 52 L142 60 Q80 38 18 60 Z", MADERA, MADERA_OSCURA, 2.0),
            R(28, 56, 8, 22, 1, MADERA_OSCURA),
            R(124, 56, 8, 22, 1, MADERA_OSCURA),
        ],
        "Puente peatonal en arco pasando por encima de la carretera.",
        None,
    ),
    "pack": (
        "D",
        fondo_sala()
        + [
            R(44, 44, 72, 42, 6, AZUL, AZUL_OSCURO, 2.2),
            R(68, 36, 24, 10, 3, GRIS_OSCURO),
            R(56, 22, 22, 16, 3, ROJO, ROJO_OSCURO, 1.8),
            R(84, 24, 20, 14, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            *frecha((80, 14), (80, 44), VERDE_OSCURO),
        ],
        "Maleta azul abierta preparándose con ropa doblada entrando dentro.",
        None,
    ),
    "pack the bag": (
        "D",
        fondo_mesa()
        + [
            R(48, 42, 64, 44, 6, NARANJA, NARANJA_OSCURO, 2.2),
            L("M66 42 Q80 28 94 42", NARANJA_OSCURO, 3.0),
            R(62, 18, 14, 20, 2, AZUL, AZUL_OSCURO, 1.6),
            R(82, 22, 16, 16, 2, VERDE, VERDE_OSCURO, 1.6),
            *frecha((120, 22), (104, 44), ROJO_OSCURO),
        ],
        "Bolsa naranja abierta llenándose con botella y libreta.",
        None,
    ),
    "pack your pencil case": (
        "D",
        fondo_mesa()
        + [
            R(36, 48, 88, 32, 8, MORADO, TINTA, 2.2),
            L("M44 56 L116 56", AMARILLO, 2.0),
            P([(62, 20), (68, 20), (68, 46), (62, 46)], AMARILLO, AMARILLO_OSCURO, 1.5),
            P([(82, 18), (88, 18), (88, 46), (82, 46)], ROJO, ROJO_OSCURO, 1.5),
            *frecha((106, 22), (100, 46), VERDE_OSCURO),
        ],
        "Estuche escolar morado abierto con lápices de colores entrando dentro.",
        None,
    ),
    "paddle boat": (
        "D",
        fondo_mar()
        + [
            F("M36 58 L124 58 L114 76 L46 76 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            E(80, 68, 14, 14, ROJO, ROJO_OSCURO, 2.0),
            L("M66 68 L94 68 M80 54 L80 82", BLANCO, 2.4),
            R(58, 40, 44, 18, 5, "#bae6fd", AZUL_OSCURO, 1.8),
        ],
        "Hidropedal amarillo en el mar con su rueda de palas roja en el costado.",
        None,
    ),
    "paddle in": (
        "D",
        fondo_mar()
        + [
            R(0, 56, 160, 44, 0, AGUA),
            L("M10 56 Q40 48 70 56 Q100 64 130 56 Q145 52 160 56", AGUA_OSCURO, 2.4),
            R(56, 24, 14, 42, 6, PEL, PELB, 1.8),
            R(90, 24, 14, 42, 6, PEL, PELB, 1.8),
            E(63, 66, 9, 5, PEL, PELB, 1.8),
            E(97, 66, 9, 5, PEL, PELB, 1.8),
            *gotas([(44, 52), (116, 52)]),
        ],
        "Pies descalzos chapoteando dentro del agua fresca en la orilla.",
        None,
    ),
    "pair of socks": (
        "D",
        fondo_sala()
        + [
            F("M44 26 L62 26 L62 60 L74 68 L68 78 L44 68 Z", ROJO, ROJO_OSCURO, 2.0),
            F("M92 26 L110 26 L110 60 L122 68 L116 78 L92 68 Z", ROJO, ROJO_OSCURO, 2.0),
            L("M44 38 L62 38 M92 38 L110 38", AMARILLO, 3.0),
        ],
        "Par de calcetines rojos idénticos con franja amarilla colocados juntos.",
        None,
    ),
    "paper bag": (
        "D",
        fondo_mesa()
        + [
            R(52, 34, 56, 50, 4, TIERRA_CLARA, BARRO, 2.2),
            L("M68 34 Q80 18 92 34", BARRO, 2.6),
            E(68, 30, 8, 6, NARANJA, NARANJA_OSCURO, 1.4),
            E(90, 28, 7, 5, AMARILLO, AMARILLO_OSCURO, 1.4),
        ],
        "Bolsa de papel marrón con asas y hojas de colores asomando.",
        None,
    ),
    "paper boat": (
        "D",
        fondo_mar()
        + [
            P([(34, 58), (126, 58), (108, 76), (52, 76)], BLANCO, AZUL_OSCURO, 2.2),
            P([(56, 58), (80, 24), (104, 58)], "#f8fafc", AZUL_OSCURO, 2.0),
            L("M80 24 L80 58", GRIS_OSCURO, 1.5),
        ],
        "Barquito blanco de papiroflexia flotando sobre el agua azul.",
        None,
    ),
    "paper cone": (
        "D",
        fondo_mesa()
        + [
            P([(54, 28), (106, 28), (80, 84)], "#fef3c7", MADERA_OSCURA, 2.2),
            E(80, 28, 26, 7, "#fde68a", MADERA_OSCURA, 2.0),
            L("M68 34 L80 84", MADERA_OSCURA, 1.5),
        ],
        "Cucurucho enrollado en forma de cono con papel claro.",
        None,
    ),
    "paper in the bin": (
        "D",
        fondo_sala()
        + [
            *papelera_prop(60, 48, 40),
            P([(70, 22), (82, 16), (92, 24), (84, 34), (72, 32)], BLANCO, GRIS_OSCURO, 1.8),
            *frecha((80, 36), (80, 52), VERDE_OSCURO),
        ],
        "Bola de papel arrugado entrando en una papelera verde.",
        None,
    ),
    "paper snowflake": (
        "D",
        fondo_mesa()
        + [
            E(80, 52, 28, 28, BLANCO, AZUL_OSCURO, 2.0),
            L("M80 26 L80 78 M54 52 L106 52 M62 34 L98 70 M98 34 L62 70", AZUL, 2.2),
            E(80, 52, 6, 6, "#bae6fd", AZUL_OSCURO, 1.5),
        ],
        "Copo de nieve blanco simétrico recortado en papel sobre la mesa.",
        None,
    ),
    "paper towel": (
        "D",
        fondo_mesa()
        + [
            R(44, 24, 32, 54, 5, BLANCO, GRIS_OSCURO, 2.0),
            E(60, 24, 16, 6, "#f1f5f9", GRIS_OSCURO, 1.8),
            E(60, 24, 6, 2.5, MADERA_OSCURA),
            R(76, 40, 44, 38, 2, "#f8fafc", GRIS_OSCURO, 1.8),
            *gotas([(96, 54), (108, 62)]),
        ],
        "Rollo de papel absorbente blanco con una hoja secando gotas.",
        None,
    ),
    "parade": (
        "D",
        fondo_prado()
        + [
            *nino_corriendo(44, 32, 1, (ROJO, ROJO_OSCURO)),
            *nino_corriendo(86, 32, 1, (AZUL, AZUL_OSCURO)),
            *nino_corriendo(122, 32, 1, (AMARILLO, AMARILLO_OSCURO)),
            R(62, 52, 16, 12, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
            P([(102, 16), (120, 22), (102, 28)], ROJO, ROJO_OSCURO, 1.5),
            L("M102 16 L102 48", MADERA_OSCURA, 2.0),
        ],
        "Tres niños desfilando en fila alegremente con tambor y banderín.",
        None,
    ),
    "pass": (
        "D",
        fondo_sala()
        + [
            *nino((44, 30), (44, 42), (44, 58), [[(32, 50)], [(62, 48)]], [[(38, 78)], [(50, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *nino((116, 30), (116, 42), (116, 58), [[(98, 48)], [(128, 50)]], [[(110, 78)], [(122, 78)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
            E(80, 48, 12, 5, BLANCO, GRIS_OSCURO, 1.8),
            *frecha((64, 34), (96, 34), VERDE_OSCURO),
        ],
        "Dos niños pasándose un plato de mano a mano.",
        None,
    ),
    "pass the baton": (
        "D",
        fondo_prado()
        + [
            *nino_corriendo(46, 28, 1, (ROJO, ROJO_OSCURO)),
            *nino_corriendo(110, 28, 1, (AZUL, AZUL_OSCURO)),
            R(72, 44, 18, 6, 2, AMARILLO, ROJO_OSCURO, 1.8),
            *frecha((68, 30), (92, 30), VERDE_OSCURO),
        ],
        "Dos corredores entregándose el testigo amarillo en carrera de relevos.",
        None,
    ),
    "pass the plate": (
        "D",
        fondo_mesa()
        + [
            *plato_prop(56, 54, 15),
            *frecha((72, 46), (98, 46), AZUL_OSCURO),
            *plato_prop(112, 54, 15),
            E(80, 56, 5, 5, NARANJA, NARANJA_OSCURO, 1.4),
        ],
        "Plato deslizándose sobre la mesa de una persona a la siguiente.",
        None,
    ),
    "pat": (
        "D",
        fondo_prado()
        + [
            E(80, 62, 20, 13, TIERRA_CLARA, BARRO, 2.0),
            E(60, 52, 10, 9, TIERRA_CLARA, BARRO, 2.0),
            E(56, 48, 4, 6, BARRO),
            E(56, 50, 1.5, 1.5, TINTA),
            L("M62 72 L62 82 M94 72 L94 82", BARRO, 4.0),
            *_mano(86, 36),
            *frecha((86, 22), (86, 32), VERDE_OSCURO),
        ],
        "Mano dando palmaditas suaves sobre el lomo de un perrito.",
        None,
    ),
    "pat down": (
        "D",
        fondo_mesa()
        + [
            F("M44 74 Q80 46 116 74 Z", "#fde68a", BARRO, 2.2),
            *_mano(80, 38),
            *frecha((54, 28), (54, 48), AZUL_OSCURO),
            *frecha((106, 28), (106, 48), AZUL_OSCURO),
        ],
        "Mano abierta aplanando suavemente hacia abajo un montón de arena o masa.",
        None,
    ),
    "pat dry": (
        "D",
        fondo_sala()
        + [
            R(30, 56, 68, 16, 7, PEL, PELB, 2.0),
            *gotas([(52, 48), (68, 46)]),
            *toalla_prop(74, 24, 38, 28),
            *frecha((94, 20), (94, 34), AGUA_OSCURO),
        ],
        "Toalla suave secando a toquecitos las gotas de agua sobre el brazo.",
        None,
    ),
    "pat the ball": (
        "D",
        fondo_sala()
        + [
            *pelota_prop(80, 66, 18, AZUL, AZUL_OSCURO),
            *_mano(80, 34),
            *frecha((106, 28), (106, 48), AZUL_OSCURO),
        ],
        "Mano abierta dando palmaditas desde arriba a una pelota azul.",
        None,
    ),
    "pat the sand": (
        "D",
        fondo_prado()
        + [
            F("M20 68 Q80 44 140 68 L140 94 L20 94 Z", "#fde68a", BARRO, 2.0),
            *_mano(80, 38),
            *frecha((54, 26), (54, 46), BARRO),
        ],
        "Mano palmeando suavemente la arena dorada de la playa.",
        None,
    ),
    "pay": (
        "D",
        fondo_mesa()
        + [
            E(58, 48, 11, 11, DORADO, MADERA_OSCURA, 2.0),
            E(74, 56, 11, 11, DORADO, MADERA_OSCURA, 2.0),
            E(92, 46, 11, 11, AMARILLO, AMARILLO_OSCURO, 2.0),
            *frecha((106, 26), (106, 48), VERDE_OSCURO),
        ],
        "Monedas doradas entregándose sobre un mostrador para pagar.",
        None,
    ),
    "peaceful park": (
        "D",
        fondo_prado()
        + [
            R(36, 46, 10, 32, 2, TIERRA, BARRO, 1.8),
            E(41, 34, 20, 16, VERDE, VERDE_OSCURO, 1.8),
            R(76, 60, 44, 10, 2, MADERA, MADERA_OSCURA, 1.8),
            L("M82 70 L82 80 M114 70 L114 80", MADERA_OSCURA, 2.5),
            F("M116 32 Q122 24 128 32 Q122 36 116 32 Z", AZUL, AZUL_OSCURO, 1.4),
            *_sol(88, 20, 8),
        ],
        "Parque tranquilo con árbol frondoso, banco de madera y pájaro.",
        None,
    ),
    "pebble path": (
        "D",
        fondo_prado()
        + [
            E(42, 82, 12, 8, GRIS, GRIS_OSCURO, 1.8),
            E(66, 76, 11, 7, "#cbd5e1", GRIS_OSCURO, 1.8),
            E(88, 66, 10, 6.5, GRIS, GRIS_OSCURO, 1.8),
            E(72, 54, 9, 6, "#cbd5e1", GRIS_OSCURO, 1.8),
            E(94, 44, 8, 5, GRIS, GRIS_OSCURO, 1.8),
            E(112, 36, 7, 4.5, "#cbd5e1", GRIS_OSCURO, 1.8),
        ],
        "Camino sinuoso formado por piedras lisas y redondeadas sobre el prado.",
        None,
    ),
    "peck at seeds": (
        "D",
        fondo_prado()
        + [
            E(70, 56, 14, 11, MAR_PROF, TINTA, 1.8),
            E(84, 52, 9, 9, MAR_PROF, TINTA, 1.8),
            P([(92, 50), (102, 55), (92, 58)], NARANJA, NARANJA_OSCURO, 1.5),
            E(86, 50, 1.4, 1.4, BLANCO),
            L("M68 66 L68 78 M74 66 L74 78", NARANJA_OSCURO, 2.0),
            E(108, 76, 3, 2, TIERRA_CLARA),
            E(116, 74, 3, 2, AMARILLO_OSCURO),
            E(124, 77, 3, 2, TIERRA_CLARA),
        ],
        "Pajarito inclinado picoteando semillas en el suelo.",
        None,
    ),
    "peel a carrot": (
        "D",
        fondo_mesa()
        + [
            P([(44, 56), (110, 40), (114, 56), (48, 72)], NARANJA, NARANJA_OSCURO, 2.2),
            L("M110 46 Q124 38 128 46 M112 50 Q124 52 126 58", VERDE_OSCURO, 2.5),
            L("M64 42 L86 64", GRIS_OSCURO, 3.2),
            L("M58 68 Q68 82 82 78", NARANJA, 3.0),
        ],
        "Pelador retirando una tira de piel naranja de una zanahoria.",
        None,
    ),
    "peg": (
        "D",
        fondo_sala()
        + [
            R(36, 22, 88, 14, 3, MADERA, MADERA_OSCURA, 2.0),
            E(80, 29, 5, 5, TIERRA, BARRO, 1.8),
            R(62, 42, 36, 40, 8, AZUL, AZUL_OSCURO, 2.2),
            R(68, 56, 24, 16, 4, "#bae6fd", AZUL_OSCURO, 1.6),
            L("M74 42 Q80 30 86 42", AZUL_OSCURO, 2.4),
        ],
        "Percha de madera en la pared con una mochila azul colgada.",
        None,
    ),
    "peg bag": (
        "D",
        fondo_sala()
        + [
            L("M80 14 L80 28", TINTA, 2.4),
            F("M54 32 L106 32 L110 82 L50 82 Z", VERDE, VERDE_OSCURO, 2.2),
            R(62, 22, 8, 22, 2, MADERA, MADERA_OSCURA, 1.6),
            R(76, 20, 8, 22, 2, ROJO, ROJO_OSCURO, 1.6),
            R(90, 22, 8, 22, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
        ],
        "Bolsa colgante de tela verde llena de pinzas de madera y colores.",
        None,
    ),
    "periwinkle": (
        "D",
        fondo_mar()
        + [
            E(80, 62, 24, 18, GRIS_OSCURO, TINTA, 2.2),
            E(72, 60, 14, 12, "#475569", TINTA, 1.8),
            E(66, 58, 7, 6, "#64748b", TINTA, 1.6),
            R(28, 76, 104, 14, 4, TIERRA_CLARA, BARRO, 1.6),
        ],
        "Bígaro marino oscuro en espiral apoyado sobre una roca.",
        None,
    ),
    "photo album": (
        "D",
        fondo_mesa()
        + [
            *libro_prop(42, 26, 76, ROJO),
            R(48, 34, 28, 22, 2, "#e0f2fe", AZUL_OSCURO, 1.4),
            R(84, 34, 28, 22, 2, "#dcfce7", VERDE_OSCURO, 1.4),
            E(62, 42, 5, 5, AMARILLO),
            P([(88, 54), (98, 40), (108, 54)], VERDE_OSCURO),
            R(48, 60, 28, 12, 2, "#fef3c7", MADERA_OSCURA, 1.2),
            R(84, 60, 28, 12, 2, "#fee2e2", ROJO_OSCURO, 1.2),
        ],
        "Álbum abierto de tapa roja lleno de fotografías enmarcadas.",
        None,
    ),
    "pick": (
        "D",
        fondo_prado()
        + [
            L("M24 28 Q80 22 132 34", MADERA_OSCURA, 3.2),
            E(96, 36, 11, 11, ROJO, ROJO_OSCURO, 2.0),
            E(92, 22, 6, 4, VERDE, VERDE_OSCURO, 1.4),
            *_mano(96, 62),
            *frecha((72, 66), (72, 44), VERDE_OSCURO),
        ],
        "Mano estirándose hacia una rama para coger una manzana roja.",
        None,
    ),
    "pick a daisy": (
        "D",
        fondo_prado()
        + [
            L("M80 48 L80 82", VERDE_OSCURO, 2.8),
            E(80, 34, 6, 12, BLANCO, GRIS_OSCURO, 1.4),
            E(80, 34, 12, 6, BLANCO, GRIS_OSCURO, 1.4),
            E(80, 34, 6, 6, AMARILLO, AMARILLO_OSCURO, 1.6),
            *_mano(104, 62),
            *frecha((104, 46), (90, 42), VERDE_OSCURO),
        ],
        "Mano acercándose con cuidado para coger una margarita blanca del prado.",
        None,
    ),
    "pick up baby": (
        "D",
        fondo_sala()
        + [
            *bebe_sentado(80, 44, (AMARILLO, AMARILLO_OSCURO)),
            L("M48 64 L68 58 M112 64 L92 58", PELB, 5.2),
            L("M48 64 L68 58 M112 64 L92 58", PEL, 3.0),
            *frecha((36, 70), (36, 38), AZUL_OSCURO),
            *frecha((124, 70), (124, 38), AZUL_OSCURO),
        ],
        "Dos manos levantando suavemente a un bebé hacia arriba.",
        None,
    ),
    "picnic blanket": (
        "D",
        fondo_prado()
        + [
            P([(30, 52), (130, 52), (144, 84), (16, 84)], BLANCO, ROJO_OSCURO, 2.0),
            R(44, 54, 24, 28, 0, "#fecaca"),
            R(92, 54, 24, 28, 0, "#fecaca"),
            L("M24 68 L136 68", ROJO, 4.0),
            R(66, 40, 28, 18, 3, MADERA, MADERA_OSCURA, 1.8),
            L("M74 40 Q80 30 86 40", MADERA_OSCURA, 2.2),
        ],
        "Manta de pícnic a cuadros rojos y blancos extendida con cesta encima.",
        None,
    ),
    "picture book": (
        "D",
        fondo_mesa()
        + [
            *libro_prop(42, 26, 76, VERDE),
            E(62, 46, 9, 9, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(98, 44, 11, 10, VERDE, VERDE_OSCURO, 1.6),
            R(95, 52, 6, 12, 1, TIERRA, BARRO, 1.4),
        ],
        "Libro infantil abierto mostrando grandes dibujos coloridos sin texto.",
        None,
    ),
    "pinch softly": (
        "D",
        fondo_sala()
        + [
            E(80, 56, 20, 14, ROSA, ROSA_OSCURO, 2.0),
            L("M48 34 L72 48 M112 34 L88 48", PELB, 5.0),
            L("M48 34 L72 48 M112 34 L88 48", PEL, 2.8),
            *frecha((58, 22), (72, 40), ROSA_OSCURO),
            *frecha((102, 22), (88, 40), ROSA_OSCURO),
        ],
        "Dos dedos pellizcando con suavidad una bola blanda de plastilina rosa.",
        None,
    ),
    "pinky promise": (
        "D",
        fondo_sala()
        + [
            E(46, 56, 14, 14, PEL, PELB, 2.0),
            E(114, 56, 14, 14, PEL, PELB, 2.0),
            L("M58 50 Q76 34 86 48", PELB, 5.4),
            L("M58 50 Q76 34 86 48", PEL, 3.2),
            L("M102 50 Q84 34 74 48", PELB, 5.4),
            L("M102 50 Q84 34 74 48", PEL, 3.2),
            E(80, 26, 5, 5, ROJO),
        ],
        "Dos dedos meñiques entrelazados haciendo una promesa cariñosa.",
        None,
    ),
    "pirate": (
        "D",
        fondo_mar()
        + [
            E(80, 52, 18, 18, PEL, PELB, 2.2),
            F("M60 44 Q80 22 100 44 Z", ROJO, ROJO_OSCURO, 2.0),
            E(72, 50, 4.5, 4.5, NEGRO),
            L("M62 44 L98 54", NEGRO, 2.0),
            E(88, 50, 1.8, 1.8, TINTA),
            L("M74 62 Q80 67 88 62", TINTA, 1.8),
        ],
        "Pirata sonriente con pañuelo rojo en la cabeza y parche en un ojo.",
        None,
    ),
    "plant a seed": (
        "D",
        fondo_prado()
        + [
            R(26, 58, 108, 30, 4, TIERRA, BARRO, 2.0),
            *semilla_prop(68, 46, 24),
            *_mano(80, 26),
            *frecha((54, 24), (54, 52), VERDE_OSCURO),
        ],
        "Dedo hundiendo una semilla en un hoyito de tierra fértil.",
        None,
    ),
    "plastic": (
        "D",
        fondo_mesa()
        + [
            R(52, 34, 22, 48, 5, "#bae6fd", AGUA_OSCURO, 2.0),
            R(58, 22, 10, 12, 2, "#bae6fd", AGUA_OSCURO, 1.8),
            R(57, 17, 12, 6, 2, AZUL, AZUL_OSCURO, 1.6),
            F("M88 46 L114 46 L108 82 L94 82 Z", "#fde68a", NARANJA_OSCURO, 2.0),
        ],
        "Botella y vaso de plástico translúcidos sobre la mesa.",
        None,
    ),
    "playtime bell": (
        "D",
        fondo_cielo()
        + [
            F("M62 66 Q66 28 80 28 Q94 28 98 66 L106 72 L54 72 Z", DORADO, MADERA_OSCURA, 2.2),
            E(80, 74, 5, 5, MADERA_OSCURA),
            E(80, 24, 5, 5, MADERA_OSCURA),
            *ondas_sonido(46, 50, ROJO_OSCURO, -1),
            *ondas_sonido(114, 50, ROJO_OSCURO, 1),
        ],
        "Campana dorada del recreo sonando con ondas a ambos lados.",
        None,
    ),
    "pocket": (
        "D",
        fondo_sala()
        + [
            R(36, 20, 88, 66, 6, AZUL, AZUL_OSCURO, 2.2),
            P([(58, 44), (102, 44), (102, 70), (80, 78), (58, 70)], "#93c5fd", AZUL_OSCURO, 2.0),
            L("M62 48 L98 48", BLANCO, 1.4),
            R(72, 24, 16, 22, 5, PEL, PELB, 1.8),
            *frecha((46, 26), (56, 48), AMARILLO_OSCURO),
        ],
        "Bolsillo cosido en pantalón azul con la mano entrando dentro.",
        None,
    ),
    "polluted": (
        "D",
        fondo_sala()
        + [
            R(10, 58, 140, 34, 0, "#64748b"),
            E(46, 30, 14, 12, "#94a3b8", GRIS_OSCURO, 1.8),
            E(64, 24, 16, 13, "#64748b", TINTA, 1.8),
            E(82, 32, 14, 11, "#94a3b8", GRIS_OSCURO, 1.8),
            R(44, 68, 18, 10, 2, TIERRA, BARRO, 1.6),
            P([(92, 68), (112, 66), (108, 80), (90, 78)], AMARILLO, TINTA, 1.6),
        ],
        "Entorno contaminado con humo gris espeso y residuos flotando en el agua.",
        None,
    ),
    "pop out": (
        "D",
        fondo_sala()
        + [
            R(54, 48, 52, 34, 5, NARANJA, NARANJA_OSCURO, 2.2),
            R(66, 26, 28, 22, 6, PEL, PELB, 2.0),
            E(75, 34, 2, 2, TINTA),
            E(85, 34, 2, 2, TINTA),
            *frecha((40, 56), (40, 26), ROJO_OSCURO),
        ],
        "Cabeza asomándose hacia fuera desde dentro de una caja naranja.",
        None,
    ),
    "post a letter": (
        "D",
        fondo_cielo()
        + [
            R(56, 28, 52, 56, 8, ROJO, ROJO_OSCURO, 2.2),
            R(68, 46, 28, 6, 2, NEGRO),
            R(66, 34, 32, 18, 2, BLANCO, GRIS_OSCURO, 1.8),
            L("M66 34 L82 44 L98 34", GRIS_OSCURO, 1.4),
            *frecha((40, 40), (62, 48), VERDE_OSCURO),
        ],
        "Sobre blanco entrando por la ranura de un buzón rojo de correos.",
        None,
    ),
    "postcard": (
        "D",
        fondo_mesa()
        + [
            R(34, 28, 92, 52, 4, BLANCO, GRIS_OSCURO, 2.2),
            R(42, 34, 46, 38, 2, "#bae6fd", AZUL_OSCURO, 1.5),
            *_sol(52, 44, 5),
            F("M42 62 Q64 54 88 62 L88 72 L42 72 Z", AMARILLO),
            R(102, 34, 16, 16, 2, ROJO, ROJO_OSCURO, 1.4),
            L("M94 58 L118 58 M94 66 L118 66", GRIS_OSCURO, 1.6),
        ],
        "Postal de viaje con dibujo de sol y playa y sello rojo en la esquina.",
        None,
    ),
    "press hands": (
        "D",
        fondo_mesa()
        + [
            R(36, 54, 88, 26, 3, "#fef3c7", MADERA_OSCURA, 2.0),
            *_mano(62, 42),
            *_mano(98, 42),
            *frecha((42, 22), (42, 46), AZUL_OSCURO),
            *frecha((118, 22), (118, 46), AZUL_OSCURO),
        ],
        "Dos manos presionando con fuerza una lámina sobre la mesa.",
        None,
    ),
    "press the bell": (
        "D",
        fondo_sala()
        + [
            R(56, 30, 48, 44, 6, MADERA, MADERA_OSCURA, 2.0),
            E(80, 52, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            L("M108 32 L86 50", PELB, 5.2),
            L("M108 32 L86 50", PEL, 3.0),
            *ondas_sonido(42, 52, AMARILLO_OSCURO, -1),
        ],
        "Dedo pulsando el botón rojo de un timbre sonando.",
        None,
    ),
    "prickly": (
        "D",
        fondo_prado()
        + [
            E(80, 62, 24, 16, BARRO, NEGRO, 2.0),
            P([(58, 56), (62, 40), (70, 52), (78, 36), (86, 50), (94, 38), (100, 56)], BARRO, NEGRO, 1.8),
            E(96, 62, 1.6, 1.6, TINTA),
            E(104, 64, 2.5, 2, NEGRO),
            *_mano(44, 32),
            *frecha((56, 36), (40, 26), ROJO_OSCURO),
        ],
        "Erizo con púas afiladas y mano apartándose con cuidado.",
        None,
    ),
    "problem": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(64, 34, (AZUL, AZUL_OSCURO), 1),
            L("M70 48 L68 28", PELB, 4.6),
            L("M70 48 L68 28", PEL, 2.6),
            P([(96, 66), (112, 56), (118, 72)], ROJO, ROJO_OSCURO, 1.6),
            R(116, 48, 16, 14, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(106, 26, 6, 6, NARANJA),
        ],
        "Niño pensativo rascándose la cabeza frente a piezas descolocadas.",
        None,
    ),
    "protected": (
        "D",
        fondo_prado()
        + [
            L("M80 76 L80 56", VERDE_OSCURO, 2.6),
            E(74, 56, 7, 4, VERDE, VERDE_OSCURO, 1.4),
            E(86, 56, 7, 4, VERDE, VERDE_OSCURO, 1.4),
            L("M44 68 Q44 30 80 30 Q116 30 116 68", AZUL_OSCURO, 3.2),
            L("M50 68 Q50 36 80 36 Q110 36 110 68", PEL, 2.2),
        ],
        "Cúpula protectora arqueada sobre un brote verde frágil.",
        None,
    ),
    "pull a face": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 26, PEL, PELB, 2.2),
            F("M56 42 C58 20 102 20 104 42 Z", BARRO),
            E(70, 44, 3, 3, TINTA),
            L("M86 44 Q90 40 94 44", TINTA, 2.2),
            L("M68 58 Q80 68 92 58", "#9a3412", 2.0),
            E(80, 66, 5, 7, ROSA, ROSA_OSCURO, 1.6),
        ],
        "Cara infantil guiñando un ojo y sacando la lengua en mueca divertida.",
        None,
    ),
    "puppet theatre": (
        "D",
        fondo_sala()
        + [
            R(36, 18, 88, 68, 4, ROJO, ROJO_OSCURO, 2.2),
            R(48, 28, 64, 34, 2, MAR_PROF, TINTA, 1.8),
            P([(48, 28), (62, 28), (54, 62), (48, 62)], AMARILLO, AMARILLO_OSCURO, 1.4),
            P([(98, 28), (112, 28), (112, 62), (106, 62)], AMARILLO, AMARILLO_OSCURO, 1.4),
            E(80, 46, 9, 9, VERDE, VERDE_OSCURO, 1.8),
            E(77, 44, 1.5, 1.5, BLANCO),
            E(83, 44, 1.5, 1.5, BLANCO),
        ],
        "Teatrillo de marionetas rojo con cortinas amarillas y títere asomando.",
        None,
    ),
    "put arms in": (
        "D",
        fondo_sala()
        + [
            R(56, 36, 48, 44, 6, VERDE, VERDE_OSCURO, 2.0),
            P([(56, 36), (34, 54), (42, 64), (56, 52)], VERDE, VERDE_OSCURO, 1.8),
            P([(104, 36), (126, 54), (118, 64), (104, 52)], VERDE, VERDE_OSCURO, 1.8),
            E(80, 24, 10, 10, PEL, PELB, 1.8),
            E(32, 60, 5, 5, PEL, PELB, 1.6),
            *frecha((42, 34), (30, 50), AZUL_OSCURO),
        ],
        "Niño metiendo los brazos por las mangas de una chaqueta verde.",
        None,
    ),
    "puzzle": (
        "D",
        fondo_mesa()
        + [
            R(44, 32, 34, 34, 3, AZUL, AZUL_OSCURO, 2.0),
            E(78, 49, 7, 7, AZUL, AZUL_OSCURO, 1.8),
            R(84, 32, 34, 34, 3, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(84, 49, 7, 7, "#fef3c7"),
            *frecha((100, 22), (82, 22), VERDE_OSCURO),
        ],
        "Dos piezas de puzle azul y amarilla listas para encajar.",
        None,
    ),
    "pyjamas": (
        "D",
        fondo_noite()
        + [
            P([(58, 22), (102, 22), (118, 42), (108, 50), (98, 40), (98, 60), (62, 60), (62, 40), (52, 50), (42, 42)], "#bae6fd", AZUL_OSCURO, 2.0),
            R(62, 62, 16, 26, 2, "#bae6fd", AZUL_OSCURO, 2.0),
            R(82, 62, 16, 26, 2, "#bae6fd", AZUL_OSCURO, 2.0),
            _estrella(74, 36, 4.5, 2.2, AMARILLO, AMARILLO_OSCURO),
            _estrella(88, 48, 4.5, 2.2, AMARILLO, AMARILLO_OSCURO),
        ],
        "Pijama azul celeste de dos piezas decorado con estrellas amarillas.",
        None,
    ),
    "pyramid": (
        "D",
        fondo_cielo()
        + [
            R(10, 74, 140, 18, 0, "#fde68a"),
            P([(80, 18), (34, 78), (86, 78)], AMARILLO, MADERA_OSCURA, 2.2),
            P([(80, 18), (86, 78), (126, 74)], NARANJA, MADERA_OSCURA, 2.2),
        ],
        "Pirámide dorada de dos caras visibles sobre arena clara.",
        None,
    ),
    "queue up": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(42, 34, (ROJO, ROJO_OSCURO), 1),
            *_nino_pie(76, 34, (AZUL, AZUL_OSCURO), 1),
            *_nino_pie(110, 34, (VERDE, VERDE_OSCURO), 1),
            *frecha((34, 22), (120, 22), TINTA),
        ],
        "Tres niños haciendo cola ordenados uno detrás del otro.",
        None,
    ),
    "quince": (
        "D",
        fondo_mesa()
        + [
            E(80, 56, 22, 24, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(80, 36, 12, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M80 26 L80 16", BARRO, 2.6),
            E(92, 22, 10, 5, VERDE, VERDE_OSCURO, 1.6),
        ],
        "Membrillo amarillo maduro con una hoja verde en el tallo.",
        None,
    ),
    "radiator": (
        "D",
        fondo_sala()
        + [
            R(38, 38, 12, 44, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(54, 38, 12, 44, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(70, 38, 12, 44, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(86, 38, 12, 44, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(102, 38, 12, 44, 4, BLANCO, GRIS_OSCURO, 2.0),
            *ondas_calor(56, 24, ROJO),
        ],
        "Radiador blanco de láminas verticales irradiando ondas de calor.",
        None,
    ),
    "rain cloud": (
        "D",
        fondo_cielo()
        + [
            E(60, 40, 20, 14, GRIS, GRIS_OSCURO, 2.0),
            E(84, 32, 22, 16, "#cbd5e1", GRIS_OSCURO, 2.0),
            E(104, 42, 18, 12, GRIS, GRIS_OSCURO, 2.0),
            E(80, 42, 28, 10, GRIS),
            *gotas([(54, 62), (72, 68), (90, 62), (108, 70)]),
        ],
        "Nube gris cargada descargando gotas de lluvia azul.",
        None,
    ),
    "rain gauge": (
        "D",
        fondo_prado()
        + [
            R(62, 26, 36, 56, 4, "#e0f2fe", AZUL_OSCURO, 2.2),
            R(64, 54, 32, 26, 2, AGUA),
            L("M66 36 L76 36 M66 46 L76 46 M66 56 L76 56 M66 66 L76 66", TINTA, 1.8),
            *gotas([(74, 14), (88, 18)]),
        ],
        "Pluviómetro transparente con marcas de nivel recogiendo gotas de lluvia.",
        None,
    ),
    "rain hat": (
        "D",
        fondo_cielo()
        + [
            F("M44 58 Q46 28 80 28 Q114 28 116 58 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            F("M26 58 L134 58 Q126 70 80 70 Q34 70 26 58 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            *gotas([(44, 18), (116, 18)]),
        ],
        "Sombrero impermeable amarillo de ala ancha bajo la lluvia.",
        None,
    ),
    "rain jacket": (
        "D",
        fondo_cielo()
        + [
            F("M58 26 Q80 12 102 26 L124 48 L112 58 L100 46 L100 84 L60 84 L60 46 L48 58 L36 48 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            L("M80 34 L80 84", NARANJA_OSCURO, 2.0),
            *gotas([(34, 22), (126, 22)]),
        ],
        "Chubasquero amarillo con capucha bajo gotas de lluvia.",
        None,
    ),
    "ramp": (
        "D",
        fondo_sala()
        + [
            P([(30, 78), (130, 78), (30, 34)], MADERA, MADERA_OSCURA, 2.2),
            *pelota_prop(64, 38, 10, ROJO, ROJO_OSCURO),
            *frecha((78, 36), (118, 54), AZUL_OSCURO),
        ],
        "Rampa inclinada de madera con pelota rodando cuesta abajo.",
        None,
    ),
    "razor clam": (
        "D",
        fondo_mar()
        + [
            R(26, 50, 108, 16, 7, "#fef3c7", BARRO, 2.0),
            R(34, 54, 92, 4, 2, "#fde68a"),
            L("M46 50 L46 66 M66 50 L66 66 M86 50 L86 66 M106 50 L106 66", BARRO, 1.4),
        ],
        "Concha alargada de navaja marina rayada junto al agua.",
        None,
    ),
    "reach": (
        "D",
        fondo_sala()
        + [
            R(98, 28, 40, 6, 2, MADERA, MADERA_OSCURA, 1.8),
            E(116, 20, 7, 7, ROJO, ROJO_OSCURO, 1.8),
            *nino((62, 34), (62, 46), (62, 62), [[(48, 54)], [(78, 42), (104, 26)]], [[(56, 82)], [(68, 82)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            *frecha((78, 34), (102, 20), AZUL_OSCURO),
        ],
        "Niño estirando el brazo hacia arriba para alcanzar la manzana del estante.",
        None,
    ),
    "receive": (
        "D",
        fondo_sala()
        + [
            *nino((52, 30), (52, 42), (52, 58), [[(40, 50)], [(68, 46)]], [[(46, 78)], [(58, 78)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            *nino((112, 30), (112, 42), (112, 58), [[(92, 46), (82, 46)], [(124, 50)]], [[(106, 78)], [(118, 78)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
            R(72, 36, 16, 14, 2, AMARILLO, ROJO_OSCURO, 1.8),
            L("M80 36 L80 50 M72 43 L88 43", ROJO, 2.0),
            *frecha((92, 26), (68, 26), VERDE_OSCURO),
        ],
        "Niño recibiendo con los brazos extendidos un paquete que le entregan.",
        None,
    ),
    "red, blue, red, blue": (
        "D",
        fondo_mesa()
        + [
            R(22, 42, 24, 24, 4, ROJO, ROJO_OSCURO, 2.2),
            R(54, 42, 24, 24, 4, AZUL, AZUL_OSCURO, 2.2),
            R(86, 42, 24, 24, 4, ROJO, ROJO_OSCURO, 2.2),
            R(118, 42, 24, 24, 4, AZUL, AZUL_OSCURO, 2.2),
        ],
        "Cuatro bloques alineados alternando rojo, azul, rojo y azul.",
        None,
    ),
    "reef": (
        "D",
        fondo_mar()
        + [
            L("M44 82 L44 52 M44 64 L32 54 M44 60 L56 50", ROSA, 5.0),
            L("M80 82 L80 46 M80 60 L68 50 M80 58 L92 48", NARANJA, 5.5),
            L("M116 82 L116 54 M116 66 L106 58 M116 64 L126 56", MORADO, 4.8),
            E(60, 34, 8, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            P([(68, 34), (74, 30), (74, 38)], AMARILLO, AMARILLO_OSCURO, 1.4),
            E(104, 32, 7, 4.5, AZUL, AZUL_OSCURO, 1.5),
            P([(111, 32), (116, 28), (116, 36)], AZUL, AZUL_OSCURO, 1.4),
        ],
        "Arrecife submarino con corales de colores y pececitos.",
        None,
    ),
    "reindeer": (
        "D",
        fondo_prado()
        + [
            E(82, 56, 22, 14, BARRO, NEGRO, 2.2),
            E(56, 40, 12, 10, BARRO, NEGRO, 2.2),
            E(47, 42, 4, 4, ROJO, ROJO_OSCURO, 1.5),
            E(54, 37, 1.5, 1.5, TINTA),
            L("M58 30 L52 14 M55 22 L46 18 M55 20 L62 16", MADERA_OSCURA, 2.6),
            L("M64 30 L72 14 M68 22 L76 18 M67 18 L63 14", MADERA_OSCURA, 2.6),
            L("M68 68 L68 82 M76 68 L76 82 M92 68 L92 82 M100 68 L100 82", BARRO, 4.0),
        ],
        "Reno marrón de gran cornamenta y nariz roja.",
        None,
    ),
    "relax": (
        "D",
        fondo_cielo()
        + [
            *_sol(132, 22, 9),
            R(26, 66, 108, 12, 5, "#bae6fd", AZUL_OSCURO, 2.0),
            E(42, 60, 10, 5, BLANCO, GRIS_OSCURO, 1.6),
            E(48, 50, 9, 9, PEL, PELB, 2.0),
            L("M44 50 Q46 52 48 50 M50 50 Q52 52 54 50", TINTA, 1.5),
            R(58, 52, 34, 12, 5, VERDE, VERDE_OSCURO, 2.0),
            R(92, 56, 26, 8, 4, AZUL, AZUL_OSCURO, 1.8),
        ],
        "Niño recostado tranquilamente con los ojos cerrados relajándose.",
        None,
    ),
    "relay race": (
        "D",
        fondo_prado()
        + [
            R(16, 62, 128, 22, 0, "#fecaca", ROJO_OSCURO, 1.4),
            L("M16 73 L144 73", BLANCO, 1.6),
            *nino_corriendo(44, 24, 1, (AMARILLO, AMARILLO_OSCURO)),
            *nino_corriendo(104, 24, 1, (VERDE, VERDE_OSCURO)),
            R(66, 40, 16, 5, 2, ROJO, ROJO_OSCURO, 1.6),
            L("M134 26 L134 62", TINTA, 2.0),
            P([(134, 26), (146, 31), (134, 36)], ROJO, ROJO_OSCURO, 1.4),
        ],
        "Carrera de relevos en pista roja con testigo y banderín de meta.",
        None,
    ),
    "rest": (
        "D",
        fondo_sala()
        + [
            R(26, 62, 108, 20, 3, MADERA, MADERA_OSCURA, 2.0),
            R(56, 44, 48, 18, 6, MORADO, "#5b21b6", 2.0),
            E(80, 44, 11, 11, PEL, PELB, 2.2),
            L("M74 44 Q76 46 78 44 M82 44 Q84 46 86 44", TINTA, 1.5),
            R(44, 54, 26, 8, 4, PEL, PELB, 1.8),
            R(90, 54, 26, 8, 4, PEL, PELB, 1.8),
        ],
        "Niño descansando con la cabeza apoyada sobre los brazos encima de la mesa.",
        None,
    ),
    "reusable bag": (
        "D",
        fondo_sala()
        + [
            R(48, 34, 64, 50, 5, VERDE, VERDE_OSCURO, 2.2),
            L("M62 34 C62 14 98 14 98 34", VERDE_OSCURO, 3.6),
            E(80, 58, 12, 10, HERBA, VERDE_OSCURO, 1.6),
            L("M80 68 L80 48", VERDE_OSCURO, 1.8),
        ],
        "Bolsa reutilizable de tela verde con asas y dibujo de hoja.",
        None,
    ),
    "ribbon stick": (
        "D",
        fondo_cielo()
        + [
            L("M44 76 L68 32", MADERA_OSCURA, 3.4),
            L("M68 32 Q88 18 102 34 Q116 50 96 60 Q82 68 118 76", ROSA, 4.2),
            L("M68 32 Q88 18 102 34 Q116 50 96 60 Q82 68 118 76", ROSA_OSCURO, 1.4),
        ],
        "Varita de madera con larga cinta rosa ondulando en espiral.",
        None,
    ),
    "ride": (
        "D",
        fondo_prado()
        + [
            E(52, 68, 13, 13, BLANCO, NEGRO, 2.4),
            E(108, 68, 13, 13, BLANCO, NEGRO, 2.4),
            L("M52 68 L78 52 L100 52 L108 68 M78 52 L84 68 L52 68", ROJO_OSCURO, 2.6),
            L("M96 42 L104 42 M100 52 L100 42", TINTA, 2.2),
            *nino_busto(76, 28, (AZUL, AZUL_OSCURO)),
        ],
        "Niño montando en bicicleta roja por el prado.",
        None,
    ),
    "ridged": (
        "D",
        fondo_mar()
        + [
            P([(80, 22), (40, 74), (120, 74)], "#fef3c7", BARRO, 2.2),
            L("M80 26 L52 72 M80 26 L66 72 M80 26 L80 72 M80 26 L94 72 M80 26 L108 72", NARANJA_OSCURO, 2.2),
        ],
        "Concha marina con estrías radiales muy marcadas en abanico.",
        None,
    ),
    "ring": (
        "D",
        fondo_cielo()
        + [
            F("M54 66 Q58 26 80 24 Q102 26 106 66 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            R(50, 64, 60, 7, 3, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(80, 74, 5, 5, DORADO, AMARILLO_OSCURO, 1.8),
            *ondas_sonido(116, 44, ROJO_OSCURO, 1),
            *ondas_sonido(44, 44, ROJO_OSCURO, -1),
        ],
        "Campana dorada balanceándose y sonando con ondas laterales.",
        None,
    ),
    "ring bells": (
        "D",
        fondo_cielo()
        + [
            F("M34 62 Q38 30 54 28 Q70 30 74 62 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            R(30, 60, 48, 6, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(54, 69, 4, 4, DORADO, AMARILLO_OSCURO, 1.6),
            F("M86 62 Q90 30 106 28 Q122 30 126 62 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            R(82, 60, 48, 6, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(106, 69, 4, 4, DORADO, AMARILLO_OSCURO, 1.6),
            *ondas_sonido(132, 42, ROJO_OSCURO, 1),
            *ondas_sonido(28, 42, ROJO_OSCURO, -1),
        ],
        "Dos campanas doradas sonando al mismo tiempo.",
        None,
    ),
    "rinse your hands": (
        "D",
        fondo_sala()
        + [
            R(40, 14, 48, 10, 4, GRIS, GRIS_OSCURO, 2.0),
            R(78, 20, 12, 14, 3, GRIS, GRIS_OSCURO, 2.0),
            L("M84 34 L84 54", AGUA, 6.0),
            *gotas([(76, 44), (92, 48)]),
            E(68, 62, 13, 8, PEL, PELB, 2.0),
            E(92, 62, 13, 8, PEL, PELB, 2.0),
        ],
        "Dos manos enjuagándose bajo el chorro de agua de un grifo.",
        None,
    ),
    "ripe mango": (
        "D",
        fondo_mesa()
        + [
            E(80, 50, 26, 18, AMARILLO, NARANJA_OSCURO, 2.2),
            E(68, 46, 12, 11, NARANJA),
            E(90, 54, 10, 9, ROJO),
            F("M98 36 Q112 22 118 34 Q108 42 98 36 Z", VERDE, VERDE_OSCURO, 1.8),
        ],
        "Mango maduro dorado y rojizo con hoja verde fresca.",
        None,
    ),
    "rise and fall": (
        "D",
        fondo_mar()
        + [
            L("M20 58 Q40 42 60 58 Q80 74 100 58 Q120 42 140 58", AZUL_OSCURO, 3.2),
            *frecha((40, 40), (40, 20), VERDE_OSCURO),
            *frecha((80, 32), (80, 52), ROJO_OSCURO),
            *frecha((120, 40), (120, 20), VERDE_OSCURO),
        ],
        "Olas subiendo y bajando con flechas hacia arriba y hacia abajo.",
        None,
    ),
    "roar loudly": (
        "D",
        fondo_prado()
        + [
            E(62, 50, 22, 22, NARANJA_OSCURO, BARRO, 2.2),
            E(62, 50, 15, 15, AMARILLO, BARRO, 2.0),
            E(56, 46, 1.8, 1.8, TINTA),
            E(68, 46, 1.8, 1.8, TINTA),
            E(62, 57, 7, 5.5, ROJO_OSCURO, TINTA, 1.6),
            *ondas_sonido(96, 50, ROJO_OSCURO, 1),
            *ondas_sonido(110, 50, ROJO_OSCURO, 1),
        ],
        "León con gran melena rugiendo con la boca abierta y ondas sonoras.",
        None,
    ),
    "robin's nest": (
        "D",
        fondo_prado()
        + [
            E(80, 62, 30, 14, BARRO, MADERA_OSCURA, 2.2),
            E(80, 56, 22, 7, TIERRA, BARRO, 1.8),
            E(72, 55, 5, 6, AGUA, AZUL_OSCURO, 1.5),
            E(82, 55, 5, 6, AGUA, AZUL_OSCURO, 1.5),
            E(92, 55, 5, 6, AGUA, AZUL_OSCURO, 1.5),
            E(46, 40, 11, 9, BARRO, NEGRO, 1.8),
            E(49, 43, 6, 5, ROJO, ROJO_OSCURO, 1.2),
            E(39, 34, 7, 7, BARRO, NEGRO, 1.8),
            P([(32, 34), (26, 36), (32, 38)], NARANJA, BARRO, 1.2),
        ],
        "Nido de ramitas con huevos azules y petirrojo de pecho rojo al lado.",
        None,
    ),
    "rotate arms": (
        "D",
        fondo_prado()
        + [
            *nino((80, 26), (80, 38), (80, 54), [[(66, 42), (52, 42)], [(94, 42), (108, 42)]], [[(74, 74)], [(86, 74)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            L("M34 36 Q42 22 54 32", VERDE_OSCURO, 2.2),
            P([(52, 28), (57, 34), (49, 35)], VERDE_OSCURO),
            L("M106 32 Q118 22 126 36", VERDE_OSCURO, 2.2),
            P([(128, 32), (126, 39), (121, 34)], VERDE_OSCURO),
        ],
        "Niño con los brazos extendidos haciendo círculos en el aire.",
        None,
    ),
    "route": (
        "D",
        fondo_prado()
        + [
            L("M30 74 Q64 74 80 50 Q96 26 130 28", TIERRA_CLARA, 10.0),
            L("M30 74 Q64 74 80 50 Q96 26 130 28", BARRO, 2.0),
            L("M30 50 L30 74", TINTA, 2.0),
            P([(30, 50), (42, 54), (30, 58)], VERDE, VERDE_OSCURO, 1.4),
            L("M130 12 L130 34", TINTA, 2.0),
            P([(130, 12), (142, 16), (130, 20)], ROJO, ROJO_OSCURO, 1.4),
        ],
        "Ruta sinuosa marcada desde la bandera verde de salida hasta la meta roja.",
        None,
    ),
    "row of dolls": (
        "D",
        fondo_sala()
        + [
            E(42, 62, 8, 12, ROSA, ROSA_OSCURO, 1.8),
            E(42, 46, 6, 6, PEL, PELB, 1.8),
            E(78, 58, 10, 15, MORADO, "#5b21b6", 2.0),
            E(78, 38, 8, 8, PEL, PELB, 2.0),
            E(118, 54, 13, 19, ROJO, ROJO_OSCURO, 2.2),
            E(118, 29, 10, 10, PEL, PELB, 2.2),
        ],
        "Tres muñecas alineadas en fila ordenadas de pequeña a grande.",
        None,
    ),
    "row the boat": (
        "D",
        fondo_mar()
        + [
            F("M32 54 L128 54 L112 72 L48 72 Z", MADERA, MADERA_OSCURA, 2.2),
            *nino_busto(80, 32, (AMARILLO, AMARILLO_OSCURO)),
            L("M66 48 L44 74 M94 48 L116 74", MADERA_OSCURA, 3.0),
        ],
        "Niño sentado en una barca remando sobre el agua con los dos remos.",
        None,
    ),
    "rub in": (
        "D",
        fondo_sala()
        + [
            R(30, 24, 24, 42, 4, BLANCO, AZUL_OSCURO, 2.0),
            R(36, 18, 12, 8, 2, AZUL, AZUL_OSCURO, 1.8),
            E(98, 56, 22, 14, PEL, PELB, 2.2),
            E(96, 52, 8, 5, BLANCO, GRIS, 1.4),
            L("M86 44 Q98 36 108 44", AZUL_OSCURO, 2.0),
            P([(106, 41), (111, 45), (105, 47)], AZUL_OSCURO),
        ],
        "Tubo de crema junto a una mano extendiendo crema blanca en círculos.",
        None,
    ),
    "rubber gloves": (
        "D",
        fondo_sala()
        + [
            R(40, 44, 24, 34, 6, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(40, 28, 5, 20, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(47, 22, 5, 24, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(54, 24, 5, 22, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(94, 44, 24, 34, 6, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(94, 24, 5, 22, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(101, 22, 5, 24, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(108, 28, 5, 20, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Par de guantes amarillos de goma.",
        None,
    ),
    "rubbish": (
        "D",
        fondo_sala()
        + [
            *papelera_prop(64, 44, 38),
            E(68, 24, 6, 5, BLANCO, GRIS_OSCURO, 1.5),
            L("M84 18 Q94 24 88 32", AMARILLO_OSCURO, 3.0),
            *frecha((50, 26), (62, 40), ROJO_OSCURO),
        ],
        "Restos de papel y piel cayendo dentro de la papelera verde.",
        None,
    ),
    "rug": (
        "D",
        fondo_sala()
        + [
            R(30, 40, 100, 38, 4, ROJO, ROJO_OSCURO, 2.2),
            R(40, 46, 80, 26, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(80, 59, 12, 8, AZUL, AZUL_OSCURO, 1.8),
            L("M24 44 L30 44 M24 54 L30 54 M24 64 L30 64 M24 72 L30 72", BARRO, 1.8),
            L("M130 44 L136 44 M130 54 L136 54 M130 64 L136 64 M130 72 L136 72", BARRO, 1.8),
        ],
        "Alfombra rectangular roja y amarilla con flecos en el suelo.",
        None,
    ),
    "sailor": (
        "D",
        fondo_mar()
        + [
            *nino_busto(64, 34, (AZUL, AZUL_OSCURO)),
            R(52, 18, 24, 9, 3, BLANCO, AZUL_OSCURO, 1.8),
            E(110, 52, 16, 16, BLANCO, MADERA_OSCURA, 3.2),
            L("M110 32 L110 72 M90 52 L130 52", MADERA_OSCURA, 2.4),
        ],
        "Marinero con gorra blanca junto al timón de madera del barco.",
        None,
    ),
    "salt water": (
        "D",
        fondo_mar()
        + [
            F("M54 34 L106 34 L100 78 L60 78 Z", "#e0f2fe", AZUL_OSCURO, 2.2),
            F("M58 50 L102 50 L98 76 L62 76 Z", AGUA),
            R(66, 12, 18, 20, 3, BLANCO, GRIS_OSCURO, 1.8),
            R(68, 8, 14, 6, 2, PLATA, GRIS_OSCURO, 1.6),
            E(72, 40, 1.8, 1.8, BLANCO),
            E(80, 44, 1.8, 1.8, BLANCO),
            E(88, 38, 1.8, 1.8, BLANCO),
        ],
        "Vaso de agua azul con salero vertiendo granos de sal blanca.",
        None,
    ),
    "same": (
        "D",
        fondo_sala()
        + [
            R(26, 24, 44, 52, 5, BLANCO, AZUL_OSCURO, 2.2),
            _estrella(48, 50, 14, 6, AMARILLO, AMARILLO_OSCURO),
            R(90, 24, 44, 52, 5, BLANCO, AZUL_OSCURO, 2.2),
            _estrella(112, 50, 14, 6, AMARILLO, AMARILLO_OSCURO),
        ],
        "Dos tarjetas idénticas mostrando exactamente la misma estrella amarilla.",
        None,
    ),
    "sand in the bucket": (
        "D",
        fondo_prado()
        + [
            F("M54 44 L106 44 L98 80 L62 80 Z", AZUL, AZUL_OSCURO, 2.2),
            F("M56 44 Q80 30 104 44 Z", "#fde68a", BARRO, 1.8),
            L("M56 44 C56 26 104 26 104 44", AZUL_OSCURO, 2.6),
            E(74, 34, 2.0, 2.0, "#f59e0b"),
            E(86, 36, 2.0, 2.0, "#f59e0b"),
        ],
        "Cubo azul de playa lleno hasta arriba de arena dorada.",
        None,
    ),
    "sand on my feet": (
        "D",
        fondo_mar()
        + [
            E(58, 60, 12, 18, PEL, PELB, 2.0),
            E(102, 60, 12, 18, PEL, PELB, 2.0),
            E(56, 62, 6, 4, "#fde68a", BARRO, 1.2),
            E(100, 64, 6, 4, "#fde68a", BARRO, 1.2),
            E(62, 54, 2, 2, "#f59e0b"),
            E(106, 56, 2, 2, "#f59e0b"),
        ],
        "Dos pies descalzos cubiertos de arena amarilla en la playa.",
        None,
    ),
    "sand pie": (
        "D",
        fondo_prado()
        + [
            F("M54 78 L66 44 L94 44 L106 78 Z", "#fde68a", BARRO, 2.2),
            E(80, 44, 14, 5, "#fef3c7", BARRO, 1.8),
            E(80, 39, 4, 3, ROSA, ROSA_OSCURO, 1.2),
        ],
        "Flan dorado de arena recién desmoldado en la playa.",
        None,
    ),
    "sandcastle": (
        "D",
        fondo_mar()
        + [
            R(44, 46, 72, 32, 3, "#fde68a", BARRO, 2.2),
            R(38, 34, 20, 44, 2, "#fde68a", BARRO, 2.0),
            R(102, 34, 20, 44, 2, "#fde68a", BARRO, 2.0),
            R(66, 26, 28, 22, 2, "#fde68a", BARRO, 2.0),
            F("M72 78 L72 60 Q80 54 88 60 L88 78 Z", BARRO),
            L("M80 12 L80 26", TINTA, 2.0),
            P([(80, 12), (94, 16), (80, 20)], ROJO, ROJO_OSCURO, 1.4),
        ],
        "Castillo de arena con torres almenadas, puerta en arco y bandera roja.",
        None,
    ),
    "school bag": (
        "D",
        fondo_sala()
        + [
            R(50, 26, 60, 56, 10, ROJO, ROJO_OSCURO, 2.2),
            R(58, 52, 44, 22, 5, AZUL, AZUL_OSCURO, 1.8),
            L("M68 26 C68 14 92 14 92 26", ROJO_OSCURO, 3.2),
            L("M58 46 L102 46", AMARILLO_OSCURO, 2.2),
        ],
        "Mochila escolar roja y azul con bolsillo frontal y asa superior.",
        None,
    ),
    "scoop": (
        "D",
        fondo_mesa()
        + [
            F("M44 52 L116 52 Q112 80 80 80 Q48 80 44 52 Z", BLANCO, AZUL_OSCURO, 2.2),
            *cuchara_prop(72, 18, 38),
            E(88, 28, 8, 6, ROSA, ROSA_OSCURO, 1.5),
        ],
        "Cuchara cogiendo una porción de yogur o crema de un cuenco.",
        None,
    ),
    "scoop sand": (
        "D",
        fondo_prado()
        + [
            F("M26 78 Q80 48 134 78 Z", "#fde68a", BARRO, 2.0),
            R(56, 36, 26, 18, 5, ROJO, ROJO_OSCURO, 2.0),
            L("M82 44 L112 24", ROJO_OSCURO, 4.0),
            E(68, 42, 8, 5, "#fef3c7", BARRO, 1.4),
        ],
        "Pala roja recogiendo un puñado de arena dorada del suelo.",
        None,
    ),
    "scoreboard": (
        "D",
        fondo_sala()
        + [
            R(30, 22, 100, 56, 5, "#1e293b", TINTA, 2.2),
            L("M80 24 L80 76", BLANCO, 2.0),
            E(46, 40, 7, 7, ROJO),
            E(64, 40, 7, 7, ROJO),
            E(46, 58, 7, 7, ROJO),
            E(98, 40, 7, 7, AZUL),
            E(116, 40, 7, 7, AZUL),
        ],
        "Tablero marcador deportivo dividido en dos lados con fichas de puntuación.",
        None,
    ),
    "scrapbook": (
        "D",
        fondo_mesa()
        + [
            *libro_prop(42, 28, 76, MORADO),
            R(48, 36, 24, 28, 2, AMARILLO, NARANJA_OSCURO, 1.4),
            _estrella(100, 48, 9, 4, ROSA, ROSA_OSCURO),
            E(94, 62, 5, 5, VERDE, VERDE_OSCURO, 1.4),
        ],
        "Álbum abierto de recortes con pegatinas, fotos y estrella pegada.",
        None,
    ),
    "scratch": (
        "D",
        fondo_sala()
        + [
            *nino((80, 28), (80, 40), (80, 56), [[(66, 48)], [(96, 38), (88, 22)]], [[(74, 76)], [(86, 76)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            L("M94 20 L102 16 M96 26 L104 26", ROJO_OSCURO, 1.8),
        ],
        "Niño llevándose la mano a la cabeza para rascarse.",
        None,
    ),
}

SIN_BASE: dict[str, str] = {
    "keep in touch": "Concepto comunicativo abstracto (`seguir en contacto`); hacer teléfono con la mano es ambiguo con llamar.",
    "kilo": "Unidad métrica de masa (`kilo`) sin representación visual unívoca sin número ni texto.",
    "knock, knock": "Onomatopeya hablada (`¡Toc, toc!`) sin puerta fija distinta de `knock`.",
    "lazy": "Rasgo abstracto (`perezoso`); estirarse bostezando parece sueño o descanso.",
    "let's breathe together": "Consigna grupal (`respiremos juntos`) duplicada de `breathe`.",
    "let's build a bridge": "Consigna de invitación (`vamos a hacer un puente`); gesto genérico.",
    "let's clean the beach": "Consigna grupal duplicada visualmente de `clean up` / playa.",
    "let's dance": "Invitación verbal (`¡Vamos a bailar!`) duplicada de `dance`.",
    "let's dig": "Invitación verbal (`¡Vamos a cavar!`) duplicada de `dig`.",
    "let's find a fair solution": "Consigna moral abstracta (`busquemos una solución justa`).",
    "let's make music": "Invitación verbal (`vamos a hacer música`) sin instrumento único.",
    "lighter in weight": "Comparativo relativo (`más ligero`) difícil sin texto ni par fijo claro.",
    "lighter than water": "Comparación física verbal (`más ligero que el agua`).",
    "lightest": "Superlativo relativo (`el más ligero`) sin referencia textual.",
    "line up at the bell": "Regla escolar compuesta (`ponerse en fila al timbre`); exige doble secuencia.",
    "little pig, let me in": "Diálogo de cuento (`¡Cerdito, déjame entrar!`) dependiente del texto.",
    "lively": "Adjetivo abstracto (`animado`) solapado con bailar o saltar.",
    "look after": "Verbo abstracto (`cuidar de`); tapar algo con las manos es ambiguo.",
    "loving": "Adjetivo emocional abstracto (`cariñoso`) duplicado de abrazo.",
    "make a deal": "Modismo abstracto (`hacer un trato`) solapado con darse la mano.",
    "make a shape": "Consigna abierta (`hacer una forma`) sin forma concreta definida.",
    "make up": "Modismo emocional (`hacer las paces`) duplicado de apretón de manos.",
    "melty": "Adjetivo sensorial (`derretido`) duplicado de `melt`.",
    "merry": "Adjetivo abstracto (`festivo`) sin referente único fuera de texto.",
    "merry tune": "Concepto auditivo (`melodía alegre`) solapado con cantar.",
    "mighty": "Adjetivo abstracto (`poderoso`) solapado con `strong` / `flex`.",
    "mirrored": "Concepto espacial/lógico (`reflejado`) que exige simetría contextual.",
    "modern": "Adjetivo histórico/abstracto (`moderno`) sin icono universal infantil.",
    "much taller": "Comparativo de grado (`mucho más alto`) dependiente del texto.",
    "mushy": "Adjetivo táctil (`machacado`) ambiguo sin contexto.",
    "next stop, please": "Frase conversacional de transporte (`en la siguiente, por favor`).",
    "next to me": "Preposición relativa (`a mi lado`) sin marco visual autónomo claro.",
    "older": "Comparativo de edad (`mayor`) sin referencia clara sin texto.",
    "one for you, one for me": "Frase verbal de reparto (`uno para ti, uno para mí`).",
    "one step, two steps": "Consigna numérica secuencial que requiere leer números.",
    "open up": "Verbo fásico genérico (`abrir`) duplicado de `open`.",
    "organised": "Rasgo abstracto (`organizado`) difícil de separar de ordenar objetos.",
    "out of tune": "Concepto musical auditivo (`desafinado`) sin marca visual unívoca.",
    "out you come": "Exclamación conversacional (`fuera del agua`).",
    "overwhelmed": "Emoción compleja (`abrumado`) ambigua frente a dolor de cabeza.",
    "pass around": "Consigna grupal (`pasar de mano en mano`) duplicada de `pass`.",
    "pass it, please": "Petición verbal de cortesía (`pásamelo, por favor`).",
    "pass me a peg": "Petición verbal específica (`pásame una pinza`).",
    "pat softly": "Matiz adverbial (`dar palmaditas suaves`) indistinguible de acariciar.",
    "peaceful": "Estado emocional abstracto (`sereno`) sin objeto concreto.",
    "peaceful solution": "Concepto moral abstracto (`solución pacífica`) duplicado.",
    "piece by piece": "Locución adverbial (`trozo a trozo`) dependiente de secuencia verbal.",
    "play fair": "Valor deportivo abstracto (`jugar limpio`) duplicado de darse la mano.",
    "playful": "Rasgo abstracto (`juguetón`) solapado con saltar/jugar.",
    "popping sound": "Onomatopeya sonora (`estallido`) sin objeto visual definido.",
    "pretend": "Verbo cognitivo de juego simbólico (`hacer como que`).",
    "promise": "Concepto abstracto (`prometer`); enganchar meñiques es opaco sin texto.",
    "promise card": "Exige una tarjeta escrita de compromiso (prohibido texto).",
    "props": "Sustantivo teatral abstracto (`atrezo` / objetos imaginarios).",
    "purring": "Sensación sonora táctil (`que ronronea`) sin marca visual clara.",
    "put it back gently": "Consigna adverbial (`devolverlo con cuidado`).",
    "put yourself in their shoes": "Modismo empático (`ponerse en su lugar`) sin lectura literal válida.",
    "reach for": "Duplicada directa de `reach` (`Intentar coger / alcanzar`).",
    "read me a story": "Petición verbal (`léeme un cuento`) solapada con libro/leer.",
    "ready for more": "Expresión motivacional (`listo para más`) sin referente visual propio.",
    "ready for primary": "Frase escolar vinculada a etapa educativa (`Primaria`).",
    "ready to go": "Expresión coloquial (`¡Listos para salir!`) ambigua.",
    "record": "Verbo genérico (`anotar`) que sugiere escritura o texto.",
    "reflection game": "Nombre de dinámica grupal (`juego del espejo`).",
    "refreshed": "Adjetivo de bienestar interno (`descansado y fresco`).",
    "rehearse": "Verbo abstracto de repetición teatral (`ensayar`).",
    "relaxed": "Participio duplicado de `relax`.",
    "relaxing": "Adjetivo duplicado de `relax`.",
    "renewable": "Concepto ecológico abstracto (`renovable`) solapado con reciclar.",
    "repeat": "Acción temporal abstracta (`repetición`) sin icono infantil unívoco sin texto.",
    "repeating": "Adjetivo temporal abstracto (`que se repite`).",
    "reply": "Verbo comunicativo verbal (`responder`) sin objeto propio.",
    "reuse": "Duplicada conceptual de `reusable bag` / `recycle`.",
    "rhyme card": "Material lingüístico dependiente de palabras que riman.",
    "rhyming": "Concepto fonológico verbal (`que rima`) imposible sin texto.",
    "ripe": "Adjetivo duplicado de `ripe mango`.",
    "ripest": "Superlativo relativo (`el más maduro`) sin escala objetiva.",
    "rise and shine": "Expresión coloquial (`¡Arriba, que sale el sol!`) ambigua.",
    "row, row, row your boat": "Estribillo de canción infantil duplicado de `row the boat`.",
    "royal": "Adjetivo abstracto (`real`) solapado con corona.",
    "rule": "Concepto normativo abstracto (`norma`) sin objeto propio.",
    "rumble": "Onomatopeya sonora grave (`retumbar`) sin referente único.",
    "salty wind": "Sensación olfativa/gustativa (`viento salado`) sin signo visual claro.",
    "say please": "Fórmula verbal de cortesía (`decir por favor`) imposible sin texto.",
    "scientific": "Adjetivo abstracto (`científico`) ambiguo frente a gafas o lupa.",
    "scratchy": "Adjetivo táctil (`rasposo`) difícil de distinguir visualmente de corteza o árbol.",
}

