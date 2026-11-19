#!/usr/bin/env python3
"""Tanda 10 TPR (P2.91): segundo bloque de `present_object` (`crayon pot`..`jumper`).

Cubre exactamente 200 piezas revisadas + 68 auditadas sin base (`SIN_BASE`):
- Directas Fluent Emoji Flat (7): `diamond`, `electric`, `fan`, `finish line`, `flex`, `hatch`, `home`.
- Escenas propias estilo Lúa D (193): `crayon pot` .. `jumper`.

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
    caja_prop,
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
    nino,
    nino_busto,
    nino_corriendo,
    notas_col,
    pelota_prop,
    plato_prop,
    pompas,
)

DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "diamond": ("Large blue diamond", "U", "Rombo azul brillante."),
    "electric": ("Electric plug", "R", "Enchufe eléctrico gris con dos clavijas."),
    "fan": ("Folding hand fan", "R", "Abanico plegable de tela roja."),
    "finish line": ("Chequered flag", "R", "Bandera a cuadros blancos y negros de meta."),
    "flex": ("Flexed biceps", "R", "Brazo flexionado marcando fuerza muscular."),
    "hatch": ("Hatching chick", "R", "Pollito amarillo saliendo del cascarón roto."),
    "home": ("House", "U", "Casa con tejado y jardín."),
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


def _mano(cx: float, cy: float, ang: float = 0.0) -> list[dict]:
    dx = math.sin(ang) * 4
    return [
        L(f"M{cx - 6:.1f} {cy + 2:.1f} L{cx - 14:.1f} {cy - 4:.1f}", PELB, 4.2),
        L(f"M{cx - 6:.1f} {cy + 2:.1f} L{cx - 14:.1f} {cy - 4:.1f}", PEL, 2.4),
        E(cx, cy, 8, 9, PEL, PELB, 1.8),
        L(f"M{cx - 6:.1f} {cy - 4:.1f} L{cx - 9 + dx:.1f} {cy - 14:.1f}", PELB, 3.8),
        L(f"M{cx - 6:.1f} {cy - 4:.1f} L{cx - 9 + dx:.1f} {cy - 14:.1f}", PEL, 2.2),
        L(f"M{cx - 2:.1f} {cy - 7:.1f} L{cx - 2 + dx:.1f} {cy - 18:.1f}", PELB, 3.8),
        L(f"M{cx - 2:.1f} {cy - 7:.1f} L{cx - 2 + dx:.1f} {cy - 18:.1f}", PEL, 2.2),
        L(f"M{cx + 3:.1f} {cy - 7:.1f} L{cx + 4 + dx:.1f} {cy - 17:.1f}", PELB, 3.8),
        L(f"M{cx + 3:.1f} {cy - 7:.1f} L{cx + 4 + dx:.1f} {cy - 17:.1f}", PEL, 2.2),
        L(f"M{cx + 7:.1f} {cy - 3:.1f} L{cx + 11 + dx:.1f} {cy - 12:.1f}", PELB, 3.8),
        L(f"M{cx + 7:.1f} {cy - 3:.1f} L{cx + 11 + dx:.1f} {cy - 12:.1f}", PEL, 2.2),
    ]


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = {
    "crayon pot": (
        "D",
        fondo_mesa()
        + [
            P([(62, 24), (72, 24), (78, 56), (68, 56)], ROJO, ROJO_OSCURO, 1.6),
            P([(76, 18), (86, 18), (86, 56), (76, 56)], AMARILLO, AMARILLO_OSCURO, 1.6),
            P([(90, 22), (100, 22), (92, 56), (82, 56)], AZUL, AZUL_OSCURO, 1.6),
            P([(56, 46), (104, 46), (98, 86), (62, 86)], VERDE, VERDE_OSCURO, 2.2),
            E(80, 46, 24, 5, VERDE_OSCURO, VERDE_OSCURO, 1.4),
            P([(116, 18), (124, 24), (106, 44), (98, 38)], NARANJA, NARANJA_OSCURO, 1.6),
            *frecha((104, 26), (92, 42), TINTA),
        ],
        "Bote verde con ceras de colores dentro y otra cera entrando en él.",
        None,
    ),
    "creep": (
        "D",
        fondo_prado()
        + [
            *nino((100, 48), (82, 54), (62, 58), [[(98, 66), (108, 72)], [(80, 68), (88, 74)]], [[(56, 68), (44, 76)], [(64, 70), (54, 78)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            L("M24 62 L40 62 M28 70 L44 70", TINTA, 1.8),
            *frecha((116, 58), (138, 58), VERDE_OSCURO),
        ],
        "Niño avanzando agachado muy despacio hacia delante.",
        None,
    ),
    "crinkly": (
        "D",
        fondo_mesa()
        + [
            F("M44 58 Q56 32 82 28 Q112 32 118 56 Q104 76 76 74 Q54 74 44 58 Z", NARANJA, NARANJA_OSCURO, 2.2),
            L("M44 58 L30 66", MADERA_OSCURA, 2.5),
            L("M56 54 L70 42 L82 56 L96 40 L108 54", MADERA_OSCURA, 2.0),
            L("M60 66 L76 58 L92 66", MADERA_OSCURA, 1.8),
        ],
        "Hoja seca naranja arrugada con pliegues marcados.",
        None,
    ),
    "crowded bus": (
        "D",
        fondo_cielo()
        + [
            F("M0 80 L160 80 L160 100 L0 100 Z", "#94a3b8"),
            R(22, 26, 116, 50, 10, AMARILLO, AMARILLO_OSCURO, 2.4),
            R(30, 34, 24, 20, 3, "#e0f2fe", AZUL_OSCURO, 1.6),
            R(60, 34, 24, 20, 3, "#e0f2fe", AZUL_OSCURO, 1.6),
            R(90, 34, 24, 20, 3, "#e0f2fe", AZUL_OSCURO, 1.6),
            R(120, 34, 14, 20, 3, "#e0f2fe", AZUL_OSCURO, 1.6),
            E(37, 45, 5, 5, PEL, PELB, 1.3),
            E(48, 45, 5, 5, PEL, PELB, 1.3),
            E(67, 45, 5, 5, PEL, PELB, 1.3),
            E(78, 45, 5, 5, PEL, PELB, 1.3),
            E(97, 45, 5, 5, PEL, PELB, 1.3),
            E(108, 45, 5, 5, PEL, PELB, 1.3),
            E(127, 45, 5, 5, PEL, PELB, 1.3),
            E(46, 78, 10, 10, NEGRO, GRIS_OSCURO, 2.0),
            E(114, 78, 10, 10, NEGRO, GRIS_OSCURO, 2.0),
        ],
        "Autobús amarillo lleno con muchas cabezas apretadas en cada ventanilla.",
        None,
    ),
    "crumpled": (
        "D",
        fondo_mesa()
        + [
            P([(52, 46), (66, 26), (92, 24), (112, 42), (104, 68), (78, 76), (54, 66)], "#f8fafc", GRIS_OSCURO, 2.2),
            L("M66 32 L82 48 L64 62 M86 30 L96 52 L106 44 M78 68 L94 60", GRIS_OSCURO, 1.8),
        ],
        "Bola de papel o pañuelo muy arrugado con pliegues.",
        None,
    ),
    "cube": (
        "D",
        fondo_sala()
        + [
            P([(80, 22), (110, 36), (80, 50), (50, 36)], "#93c5fd", AZUL_OSCURO, 2.0),
            P([(50, 36), (80, 50), (80, 82), (50, 68)], AZUL, AZUL_OSCURO, 2.0),
            P([(80, 50), (110, 36), (110, 68), (80, 82)], "#1d4ed8", AZUL_OSCURO, 2.0),
        ],
        "Cubo tridimensional azul de caras cuadradas iguales.",
        None,
    ),
    "cube on the cylinder": (
        "D",
        fondo_mesa()
        + [
            R(62, 50, 36, 32, 4, MADERA, MADERA_OSCURA, 2.0),
            E(80, 50, 18, 6, "#fde68a", MADERA_OSCURA, 1.8),
            E(80, 82, 18, 6, MADERA, MADERA_OSCURA, 1.8),
            P([(80, 16), (98, 25), (80, 34), (62, 25)], "#fca5a5", ROJO_OSCURO, 1.8),
            P([(62, 25), (80, 34), (80, 50), (62, 42)], ROJO, ROJO_OSCURO, 1.8),
            P([(80, 34), (98, 25), (98, 42), (80, 50)], ROJO_OSCURO, ROJO_OSCURO, 1.8),
        ],
        "Cubo rojo apoyado encima de un cilindro de madera.",
        None,
    ),
    "cuddly": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(72, 32, (ROSA, ROSA_OSCURO), 1),
            E(92, 54, 12, 14, MADERA, MADERA_OSCURA, 2.0),
            E(92, 40, 10, 9, MADERA, MADERA_OSCURA, 2.0),
            E(85, 32, 3.5, 3.5, MADERA, MADERA_OSCURA, 1.6),
            E(99, 32, 3.5, 3.5, MADERA, MADERA_OSCURA, 1.6),
            E(92, 42, 3, 2, "#fef3c7"),
            E(92, 41, 1.4, 1.2, TINTA),
            L("M76 48 L88 54", PELB, 5.2),
            L("M76 48 L88 54", PEL, 3.2),
        ],
        "Niño achuchando un osito de peluche contra su pecho.",
        None,
    ),
    "curl up": (
        "D",
        fondo_sala()
        + [
            R(26, 66, 108, 16, 8, ROSA, ROSA_OSCURO, 2.0),
            E(82, 58, 26, 16, NARANJA, NARANJA_OSCURO, 2.2),
            E(68, 52, 11, 10, NARANJA, NARANJA_OSCURO, 2.0),
            P([(60, 45), (64, 36), (69, 44)], NARANJA, NARANJA_OSCURO, 1.6),
            P([(71, 44), (76, 36), (79, 46)], NARANJA, NARANJA_OSCURO, 1.6),
            L("M64 52 Q67 54 70 52 M96 68 Q110 66 106 54", TINTA, 2.0),
        ],
        "Gato hecho un ovillo enroscado sobre una manta rosa.",
        None,
    ),
    "curtain call": (
        "D",
        fondo_sala()
        + [
            F("M12 10 L44 10 Q38 48 26 84 L12 84 Z", ROJO, ROJO_OSCURO, 2.0),
            F("M148 10 L116 10 Q122 48 134 84 L148 84 Z", ROJO, ROJO_OSCURO, 2.0),
            R(26, 82, 108, 10, 2, MADERA, MADERA_OSCURA, 1.8),
            *nino((94, 42), (78, 48), (64, 58), [[(86, 56), (98, 66)], [(72, 58), (62, 68)]], [[(60, 68), (58, 82)], [(70, 68), (74, 82)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            L("M48 48 Q42 58 48 68", AMARILLO_OSCURO, 2.0),
        ],
        "Niño haciendo una reverencia en el escenario entre telones rojos.",
        None,
    ),
    "dam": (
        "D",
        fondo_prado()
        + [
            F("M0 36 L68 36 L68 78 L0 78 Z", AGUA, AGUA_OSCURO, 1.8),
            R(62, 26, 26, 56, 3, GRIS, GRIS_OSCURO, 2.2),
            L("M62 42 L88 42 M62 58 L88 58 M74 26 L74 42 M70 58 L70 82", GRIS_OSCURO, 1.6),
            F("M88 64 Q124 62 160 66 L160 80 L88 80 Z", AGUA, AGUA_OSCURO, 1.8),
            *frecha((26, 48), (56, 48), AZUL_OSCURO),
        ],
        "Presa de piedra reteniendo el agua alta del río.",
        None,
    ),
    "damp sand": (
        "D",
        fondo_cielo()
        + [
            F("M0 72 Q80 64 160 72 L160 100 L0 100 Z", "#d97706", "#92400e", 1.8),
            P([(48, 76), (112, 76), (96, 38), (64, 38)], "#b45309", "#78350f", 2.2),
            *gotas([(44, 24), (80, 18), (116, 24)]),
        ],
        "Montículo compacto de arena húmeda oscura con gotitas de agua.",
        None,
    ),
    "dance floor": (
        "D",
        fondo_sala()
        + [
            P([(20, 86), (140, 86), (120, 62), (40, 62)], "#fde047", AMARILLO_OSCURO, 2.0),
            P([(46, 86), (78, 86), (76, 62), (56, 62)], "#c084fc", MORADO, 1.4),
            P([(82, 86), (114, 86), (104, 62), (84, 62)], "#38bdf8", AZUL_OSCURO, 1.4),
            *nino((80, 26), (80, 38), (80, 54), [[(64, 28), (54, 20)], [(96, 30), (106, 22)]], [[(72, 64), (66, 76)], [(88, 64), (94, 76)]], camisa=(ROSA, ROSA_OSCURO), mira=1),
            *notas_col([(32, 28)], MORADO),
            *notas_col([(124, 28)], AZUL_OSCURO),
        ],
        "Pista de baile de colores iluminada con niño bailando y notas musicales.",
        None,
    ),
    "decorate": (
        "D",
        fondo_sala()
        + [
            F("M20 26 Q80 56 140 26 L140 34 Q80 64 20 34 Z", VERDE, VERDE_OSCURO, 2.0),
            E(46, 52, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            E(80, 60, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(114, 52, 8, 8, AZUL, AZUL_OSCURO, 1.8),
            *_mano(114, 72, 0.2),
        ],
        "Guirnalda verde decorada con bolas de colores colgadas a mano.",
        None,
    ),
    "decoration": (
        "D",
        fondo_sala()
        + [
            L("M80 10 L80 28", DORADO, 2.2),
            R(73, 28, 14, 7, 2, DORADO, AMARILLO_OSCURO, 1.6),
            E(80, 56, 22, 22, ROJO, ROJO_OSCURO, 2.2),
            F("M60 52 Q80 64 100 52 L98 62 Q80 74 62 62 Z", AMARILLO, AMARILLO_OSCURO, 1.6),
            _estrella(80, 44, 6, 2.5, BLANCO, AMARILLO_OSCURO),
        ],
        "Adorno brillante colgante con lazo dorado y estrella.",
        None,
    ),
    "deep breath": (
        "D",
        fondo_sala()
        + [
            *nino_busto(80, 38, (AZUL, AZUL_OSCURO)),
            E(80, 74, 22, 12, "#93c5fd", AZUL_OSCURO, 2.0),
            L("M34 46 Q46 36 58 46 M102 46 Q114 36 126 46", AGUA_OSCURO, 2.4),
            *frecha((34, 64), (56, 58), AZUL_OSCURO),
            *frecha((126, 64), (104, 58), AZUL_OSCURO),
        ],
        "Niño tomando aire profundo expandiendo el pecho con ondas de respiración.",
        None,
    ),
    "deeper and deeper": (
        "D",
        fondo_cielo()
        + [
            P([(0, 44), (44, 44), (44, 60), (62, 60), (62, 76), (98, 76), (98, 60), (116, 60), (116, 44), (160, 44), (160, 100), (0, 100)], TIERRA, BARRO, 2.0),
            L("M94 14 L80 62", MADERA_OSCURA, 3.0),
            P([(74, 62), (86, 62), (80, 74)], GRIS, GRIS_OSCURO, 1.8),
            *frecha((80, 26), (80, 54), ROJO_OSCURO),
        ],
        "Agujero excavado en escalones cada vez más hondo con pala bajando.",
        None,
    ),
    "defend": (
        "D",
        fondo_prado()
        + [
            *_nino_pie(68, 30, (VERDE, VERDE_OSCURO), 1),
            P([(92, 34), (124, 34), (124, 56), (108, 72), (92, 56)], AZUL, AZUL_OSCURO, 2.2),
            E(108, 50, 7, 7, AMARILLO, AMARILLO_OSCURO, 1.6),
        ],
        "Niño sosteniendo un escudo azul al frente para defender.",
        None,
    ),
    "dewy": (
        "D",
        fondo_cielo()
        + [
            F("M0 72 Q80 64 160 72 L160 100 L0 100 Z", HERBA, HERBAB, 1.8),
            F("M44 76 Q38 42 54 24 Q58 50 56 76 Z", VERDE, VERDE_OSCURO, 2.0),
            F("M78 76 Q82 36 96 22 Q94 52 88 76 Z", VERDE, VERDE_OSCURO, 2.0),
            F("M104 76 Q116 48 128 32 Q122 58 114 76 Z", VERDE, VERDE_OSCURO, 2.0),
            E(51, 34, 4.5, 4.5, "#bae6fd", AGUA_OSCURO, 1.6),
            E(88, 38, 5, 5, "#bae6fd", AGUA_OSCURO, 1.6),
            E(116, 48, 4, 4, "#bae6fd", AGUA_OSCURO, 1.6),
        ],
        "Hojas de hierba verde cubiertas de brillantes gotitas de rocío.",
        None,
    ),
    "different": (
        "D",
        fondo_sala()
        + [
            E(34, 50, 12, 12, AZUL, AZUL_OSCURO, 2.0),
            E(66, 50, 12, 12, AZUL, AZUL_OSCURO, 2.0),
            E(98, 50, 12, 12, AZUL, AZUL_OSCURO, 2.0),
            _estrella(130, 50, 16, 7, NARANJA, NARANJA_OSCURO),
        ],
        "Tres círculos azules iguales y una estrella naranja diferente.",
        None,
    ),
    "dig a hole": (
        "D",
        fondo_cielo()
        + [
            F("M0 58 Q48 54 54 58 L58 84 L102 84 L106 58 Q134 54 160 58 L160 100 L0 100 Z", TIERRA, BARRO, 2.0),
            E(80, 62, 24, 7, "#451a03"),
            P([(106, 58), (138, 58), (124, 42)], TIERRA_CLARA, BARRO, 1.8),
            L("M84 14 L76 54", MADERA_OSCURA, 3.0),
            P([(68, 54), (84, 54), (76, 68)], GRIS, GRIS_OSCURO, 1.8),
        ],
        "Pala cavando un hoyo hondo en la tierra con montón al lado.",
        None,
    ),
    "dim": (
        "D",
        fondo_noite()
        + [
            R(20, 74, 120, 16, 3, MADERA, MADERA_OSCURA, 1.8),
            P([(64, 34), (96, 34), (104, 52), (56, 52)], "#fef08a", AMARILLO_OSCURO, 2.0),
            R(76, 52, 8, 22, 2, MADERA, MADERA_OSCURA, 1.8),
            R(66, 70, 28, 6, 3, MADERA_OSCURA, TINTA, 1.6),
            E(80, 44, 18, 12, "#fef9c3"),
        ],
        "Lámpara de noche dando una luz tenue y suave en habitación oscura.",
        None,
    ),
    "diploma": (
        "D",
        fondo_mesa()
        + [
            R(28, 36, 104, 32, 8, "#fef3c7", AMARILLO_OSCURO, 2.2),
            E(34, 52, 6, 16, "#fde68a", AMARILLO_OSCURO, 1.6),
            L("M48 46 L74 46 M48 56 L74 56", BARRO, 2.0),
            R(84, 34, 10, 36, 2, ROJO, ROJO_OSCURO, 1.8),
            P([(84, 68), (88, 86), (92, 74), (96, 86), (94, 68)], ROJO, ROJO_OSCURO, 1.6),
            E(89, 52, 9, 9, DORADO, AMARILLO_OSCURO, 1.8),
        ],
        "Diploma enrollado con lazo rojo y sello dorado.",
        None,
    ),
    "dive": (
        "D",
        fondo_mar()
        + [
            L("M0 64 Q40 58 80 64 Q120 70 160 64", BLANCO, 2.0),
            *nino((100, 46), (80, 34), (60, 26), [[(108, 52), (120, 62)], [(100, 56), (112, 66)]], [[(52, 20), (40, 14)], [(58, 16), (48, 10)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *frecha((104, 36), (128, 60), AZUL_OSCURO),
        ],
        "Niño lanzándose con brazos juntos en punta hacia el agua.",
        None,
    ),
    "dive deep": (
        "D",
        fondo_mar()
        + [
            L("M0 16 Q40 11 80 16 Q120 21 160 16", BLANCO, 2.0),
            *nino((74, 76), (74, 60), (74, 44), [[(82, 82), (82, 92)], [(66, 82), (66, 92)]], [[(68, 34), (64, 24)], [(80, 34), (84, 24)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            *pompas([(58, 56, 4), (54, 42, 5), (60, 28, 3.5)]),
            *frecha((118, 28), (118, 82), BLANCO),
        ],
        "Buceador descendiendo hacia el fondo marino profundo con burbujas.",
        None,
    ),
    "dive for fish": (
        "D",
        fondo_mar()
        + [
            P([(52, 22), (82, 34), (68, 48), (44, 32)], BLANCO, GRIS_OSCURO, 2.0),
            P([(82, 34), (96, 44), (78, 42)], NARANJA, NARANJA_OSCURO, 1.6),
            P([(92, 72), (114, 62), (126, 72), (114, 82)], PLATA, AZUL_OSCURO, 2.0),
            P([(126, 72), (138, 64), (138, 80)], PLATA, AZUL_OSCURO, 1.8),
            *frecha((78, 46), (98, 64), AZUL_OSCURO),
        ],
        "Ave marina bajando en picado a por un pez bajo el agua.",
        None,
    ),
    "dodge": (
        "D",
        fondo_prado()
        + [
            *nino((100, 32), (96, 44), (92, 60), [[(84, 50)], [(110, 52)]], [[(86, 78)], [(104, 78)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
            E(42, 42, 12, 12, NARANJA, NARANJA_OSCURO, 2.0),
            L("M20 42 L34 42 M22 34 L36 34", ROJO_OSCURO, 2.2),
            *frecha((76, 40), (112, 32), AZUL_OSCURO),
        ],
        "Niño inclinándose a un lado para esquivar una pelota que pasa.",
        None,
    ),
    "doll": (
        "D",
        fondo_sala()
        + [
            E(80, 32, 14, 14, PEL, PELB, 2.0),
            E(63, 36, 6, 8, BARRO, MADERA_OSCURA, 1.8),
            E(97, 36, 6, 8, BARRO, MADERA_OSCURA, 1.8),
            F("M66 26 Q80 14 94 26 Q84 22 66 26 Z", BARRO),
            E(75, 31, 1.5, 1.8, TINTA),
            E(85, 31, 1.5, 1.8, TINTA),
            L("M75 37 Q80 42 85 37", ROJO_OSCURO, 1.6),
            P([(68, 46), (92, 46), (104, 76), (56, 76)], ROSA, ROSA_OSCURO, 2.0),
            L("M68 50 L54 62 M92 50 L106 62 M72 76 L72 88 M88 76 L88 88", PELB, 4.0),
            L("M68 50 L54 62 M92 50 L106 62 M72 76 L72 88 M88 76 L88 88", PEL, 2.4),
        ],
        "Muñeca sonriente de trapo con trenzas y vestido rosa.",
        None,
    ),
    "donate": (
        "D",
        fondo_mesa()
        + [
            R(54, 48, 52, 34, 4, MADERA, MADERA_OSCURA, 2.2),
            E(80, 68, 6, 6, ROJO, ROJO_OSCURO, 1.5),
            R(66, 22, 28, 18, 4, AZUL, AZUL_OSCURO, 1.8),
            *frecha((80, 42), (80, 56), VERDE_OSCURO),
        ],
        "Prenda doblada entrando dentro de la caja de donaciones.",
        None,
    ),
    "donation box": (
        "D",
        fondo_sala()
        + [
            R(46, 46, 68, 40, 4, TIERRA_CLARA, MADERA_OSCURA, 2.2),
            F("M74 62 C70 58 64 62 64 67 C64 73 80 80 80 80 C80 80 96 73 96 67 C96 62 90 58 86 62 L80 68 Z", ROJO, ROJO_OSCURO, 1.6),
            R(56, 30, 22, 16, 4, VERDE, VERDE_OSCURO, 1.6),
            E(94, 34, 10, 12, NARANJA, NARANJA_OSCURO, 1.6),
        ],
        "Caja abierta marcada con un corazón llena de ropa y peluches para donar.",
        None,
    ),
    "dough": (
        "D",
        fondo_mesa()
        + [
            R(26, 56, 108, 24, 5, MADERA, MADERA_OSCURA, 2.0),
            F("M44 64 C44 40 116 40 116 64 C112 72 48 72 44 64 Z", "#fde68a", AMARILLO_OSCURO, 2.2),
            R(54, 24, 52, 12, 5, TIERRA_CLARA, MADERA_OSCURA, 2.0),
            R(40, 27, 14, 6, 3, MADERA, MADERA_OSCURA, 1.6),
            R(106, 27, 14, 6, 3, MADERA, MADERA_OSCURA, 1.6),
        ],
        "Masa suave dorada sobre tabla con rodillo de madera.",
        None,
    ),
    "down the ramp": (
        "D",
        fondo_sala()
        + [
            P([(24, 34), (136, 78), (24, 78)], MADERA, MADERA_OSCURA, 2.2),
            E(56, 36, 11, 11, ROJO, ROJO_OSCURO, 2.0),
            *frecha((72, 42), (118, 62), AZUL_OSCURO),
        ],
        "Pelota roja rodando hacia abajo por una rampa inclinada.",
        None,
    ),
    "down to the ground": (
        "D",
        fondo_prado()
        + [
            F("M64 20 Q80 12 94 20 Q84 32 64 20 Z", NARANJA, NARANJA_OSCURO, 1.8),
            L("M78 24 Q64 42 86 58 Q96 68 78 78", BARRO, 2.0),
            *frecha((96, 34), (96, 74), VERDE_OSCURO),
        ],
        "Hoja cayendo suavemente hasta posarse en la hierba del suelo.",
        None,
    ),
    "dress": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(80, 28, (AZUL, AZUL_OSCURO), 1),
            P([(62, 42), (98, 42), (108, 56), (96, 62), (94, 72), (66, 72), (64, 62), (52, 56)], AZUL, AZUL_OSCURO, 2.0),
            E(80, 43, 8, 3.5, PEL, AZUL_OSCURO, 1.4),
            *frecha((80, 8), (80, 20), VERDE_OSCURO),
        ],
        "Niño metiendo la cabeza por la camiseta para vestirse.",
        None,
    ),
    "dress up": (
        "D",
        fondo_sala()
        + [
            P([(62, 42), (44, 80), (116, 80), (98, 42)], ROJO, ROJO_OSCURO, 2.0),
            *_nino_pie(80, 32, (AZUL, AZUL_OSCURO), 1),
            P([(68, 22), (72, 12), (80, 18), (88, 12), (92, 22)], DORADO, AMARILLO_OSCURO, 1.8),
        ],
        "Niño disfrazado con capa roja y corona dorada.",
        None,
    ),
    "drift": (
        "D",
        fondo_cielo()
        + [
            *lineas_viento(28, 34, 60),
            F("M84 34 Q102 22 114 34 Q102 48 84 34 Z", NARANJA, NARANJA_OSCURO, 1.8),
            L("M48 64 Q80 48 112 62", AGUA_OSCURO, 2.0),
            P([(112, 62), (104, 58), (106, 66)], AGUA_OSCURO),
        ],
        "Hoja planeando suavemente en el aire llevada por la brisa.",
        None,
    ),
    "drift along": (
        "D",
        fondo_mar()
        + [
            P([(52, 48), (108, 48), (98, 66), (62, 66)], MADERA, MADERA_OSCURA, 2.2),
            L("M80 48 L80 22", MADERA_OSCURA, 2.4),
            P([(80, 22), (104, 38), (80, 44)], BLANCO, GRIS_OSCURO, 1.8),
            L("M24 72 Q52 66 80 72 Q108 78 136 72", BLANCO, 2.0),
            *frecha((26, 40), (50, 40), BLANCO),
        ],
        "Barquito dejándose llevar despacio por la corriente del agua.",
        None,
    ),
    "dripping wet": (
        "D",
        fondo_sala()
        + [
            P([(48, 26), (112, 26), (104, 50), (56, 50)], AZUL, AZUL_OSCURO, 2.2),
            L("M66 36 L94 40 M72 44 L88 32", AZUL_OSCURO, 2.0),
            *gotas([(60, 62), (76, 58), (90, 66), (102, 58)]),
            E(80, 82, 34, 7, AGUA, AGUA_OSCURO, 1.8),
        ],
        "Paño azul empapado escurriendo muchas gotas sobre un charco.",
        None,
    ),
    "drop a light feather": (
        "D",
        fondo_cielo()
        + [
            *_mano(56, 26, -0.3),
            F("M84 48 Q106 34 114 48 Q98 62 84 48 Z", BLANCO, AZUL_OSCURO, 1.8),
            L("M78 52 L106 46", AZUL_OSCURO, 1.6),
            *frecha((96, 56), (96, 82), AGUA_OSCURO),
        ],
        "Mano soltando una pluma blanca ligera que cae despacio.",
        None,
    ),
    "drop by drop": (
        "D",
        fondo_mesa()
        + [
            P([(74, 10), (86, 10), (84, 32), (76, 32)], AZUL, AZUL_OSCURO, 2.0),
            L("M80 32 L80 38", TINTA, 2.0),
            *gotas([(80, 48), (80, 62)]),
            E(80, 82, 26, 7, AGUA, AGUA_OSCURO, 1.8),
        ],
        "Cuentagotas dejando caer gotas de agua una a una.",
        None,
    ),
    "dry": (
        "D",
        fondo_cielo()
        + [
            *_sol(128, 24, 11),
            F("M0 64 L160 64 L160 100 L0 100 Z", "#fde68a", "#b45309", 1.8),
            L("M24 64 L38 78 L28 94 M74 64 L66 80 L84 94 M118 64 L108 82 L124 94", "#92400e", 2.0),
            F("M54 50 Q74 36 92 48 Q78 62 54 50 Z", "#a16207", "#78350f", 1.8),
        ],
        "Suelo seco agrietado y hoja marrón seca bajo el sol.",
        None,
    ),
    "dry off": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(80, 34, (AZUL, AZUL_OSCURO), 1),
            R(54, 46, 52, 24, 6, BLANCO, AGUA_OSCURO, 2.0),
            L("M48 40 Q42 52 48 64 M112 40 Q118 52 112 64", AGUA_OSCURO, 2.0),
        ],
        "Niño secándose con una toalla suave después del baño.",
        None,
    ),
    "dry sand": (
        "D",
        fondo_cielo()
        + [
            *_mano(66, 26, 0.2),
            P([(30, 84), (130, 84), (92, 56), (68, 56)], "#fde68a", "#d97706", 2.0),
            E(72, 42, 2.5, 2.5, "#f59e0b"),
            E(80, 48, 2.5, 2.5, "#f59e0b"),
            E(76, 54, 2.5, 2.5, "#f59e0b"),
        ],
        "Mano dejando caer granitos de arena seca sobre un montículo dorado.",
        None,
    ),
    "early-rising": (
        "D",
        fondo_cielo("#bae6fd")
        + [
            *_sol(32, 34, 12),
            *nino((94, 34), (94, 46), (94, 64), [[(82, 46), (66, 26)], [(106, 46), (122, 26)]], [[(86, 84)], [(102, 84)]], camisa=(AMARILLO, AMARILLO_OSCURO), mira=-1),
        ],
        "Niño estirando los brazos desperezándose con el sol de la mañana.",
        None,
    ),
    "earmuffs": (
        "D",
        fondo_cielo()
        + [
            *nino_busto(80, 48, (AZUL, AZUL_OSCURO)),
            L("M56 46 Q80 10 104 46", ROJO_OSCURO, 4.0),
            E(54, 48, 8, 11, ROJO, ROJO_OSCURO, 2.0),
            E(106, 48, 8, 11, ROJO, ROJO_OSCURO, 2.0),
        ],
        "Niño con orejeras rojas abrigadas cubriendo ambas orejas.",
        None,
    ),
    "echo": (
        "D",
        fondo_cielo()
        + [
            *nino_busto(40, 56, (VERDE, VERDE_OSCURO)),
            P([(106, 84), (146, 84), (130, 22)], GRIS, GRIS_OSCURO, 2.2),
            L("M62 48 Q72 56 62 64 M72 44 Q84 56 72 68", AZUL_OSCURO, 2.0),
            L("M102 44 Q92 56 102 68 M92 48 Q84 56 92 64", ROJO_OSCURO, 2.0),
        ],
        "Niño gritando frente a una montaña con ondas de sonido que rebotan.",
        None,
    ),
    "egg cup": (
        "D",
        fondo_mesa()
        + [
            E(80, 38, 16, 20, "#fefce8", GRIS_OSCURO, 2.0),
            P([(62, 44), (98, 44), (88, 70), (72, 70)], AZUL, AZUL_OSCURO, 2.2),
            R(66, 70, 28, 10, 3, AZUL, AZUL_OSCURO, 2.0),
        ],
        "Huevera azul sosteniendo un huevo blanco.",
        None,
    ),
    "egg-shaped": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 24, 30, "#fef3c7", "#d97706", 2.4),
            E(80, 50, 14, 20, "#fde68a", "#f59e0b", 1.8),
            L("M80 16 L80 20 M80 80 L80 84 M50 50 L56 50 M104 50 L110 50", "#b45309", 2.0),
        ],
        "Contorno ovalado con la forma característica de un huevo.",
        None,
    ),
    "empty out": (
        "D",
        fondo_mesa()
        + [
            P([(42, 26), (76, 16), (82, 40), (52, 48)], AZUL, AZUL_OSCURO, 2.2),
            R(66, 74, 68, 10, 3, PLATA, GRIS_OSCURO, 1.8),
            *gotas([(86, 50), (96, 62)]),
            *frecha((82, 34), (104, 58), AZUL_OSCURO),
        ],
        "Vaso inclinado vaciando las últimas gotas sobre una bandeja.",
        None,
    ),
    "energy saver": (
        "D",
        fondo_sala()
        + [
            R(44, 24, 34, 48, 5, "#f8fafc", GRIS_OSCURO, 2.0),
            R(55, 42, 12, 14, 2, GRIS, GRIS_OSCURO, 1.6),
            *_mano(64, 70, 0.2),
            E(114, 44, 14, 14, "#cbd5e1", GRIS_OSCURO, 2.0),
            R(108, 56, 12, 8, 2, GRIS, GRIS_OSCURO, 1.6),
            E(114, 24, 7, 7, VERDE, VERDE_OSCURO, 1.5),
        ],
        "Mano apagando el interruptor junto a bombilla apagada de ahorro.",
        None,
    ),
    "equal": (
        "D",
        fondo_sala()
        + [
            P([(74, 68), (86, 68), (80, 50)], MADERA, MADERA_OSCURA, 2.0),
            L("M34 50 L126 50", MADERA_OSCURA, 4.0),
            R(36, 30, 18, 18, 3, AZUL, AZUL_OSCURO, 1.8),
            R(106, 30, 18, 18, 3, AZUL, AZUL_OSCURO, 1.8),
            L("M64 26 L96 26 M64 34 L96 34", VERDE_OSCURO, 2.6),
        ],
        "Balancín completamente horizontal con dos bloques iguales.",
        None,
    ),
    "evaporation": (
        "D",
        fondo_cielo()
        + [
            *_sol(34, 26, 11),
            E(80, 78, 42, 8, AGUA, AGUA_OSCURO, 2.0),
            L("M62 66 Q56 54 64 42 Q70 30 62 20", AGUA_OSCURO, 2.2),
            L("M80 66 Q74 54 82 42 Q88 30 80 20", AGUA_OSCURO, 2.2),
            L("M98 66 Q92 54 100 42 Q106 30 98 20", AGUA_OSCURO, 2.2),
            *frecha((118, 66), (118, 24), AZUL_OSCURO),
        ],
        "Charco calentado por el sol con vapor azul subiendo en ondas.",
        None,
    ),
    "exercise book": (
        "D",
        fondo_mesa()
        + [
            R(36, 22, 88, 58, 5, AZUL, AZUL_OSCURO, 2.2),
            R(42, 26, 36, 50, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(82, 26, 36, 50, 2, BLANCO, GRIS_OSCURO, 1.4),
            L("M48 36 L72 36 M48 46 L72 46 M48 56 L72 56 M88 36 L112 36 M88 46 L112 46", "#cbd5e1", 1.8),
            P([(116, 18), (124, 22), (104, 62), (96, 58)], AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Cuaderno abierto con páginas pautadas y lápiz amarillo encima.",
        None,
    ),
    "eyelashes": (
        "D",
        fondo_sala()
        + [
            F("M34 52 Q80 26 126 52 Q80 76 34 52 Z", BLANCO, TINTA, 2.2),
            E(80, 52, 13, 13, AZUL, AZUL_OSCURO, 1.8),
            E(80, 52, 6, 6, TINTA),
            L("M46 42 L38 28 M62 34 L58 18 M80 30 L80 14 M98 34 L102 18 M114 42 L122 28", TINTA, 2.6),
        ],
        "Ojo grande de cerca destacando sus largas pestañas oscuras.",
        None,
    ),
    "face": (
        "D",
        fondo_sala()
        + [
            E(80, 48, 26, 28, PEL, PELB, 2.4),
            F("M54 40 C56 18 104 18 106 40 C94 30 66 30 54 40 Z", BARRO),
            E(70, 44, 2.5, 3, TINTA),
            E(90, 44, 2.5, 3, TINTA),
            L("M72 58 Q80 66 88 58", "#9a3412", 2.0),
            *_mano(44, 58, -0.2),
            *_mano(116, 58, 0.2),
        ],
        "Cara frontal rodeada suavemente por las manos en las mejillas.",
        None,
    ),
    "face cloth": (
        "D",
        fondo_sala()
        + [
            R(44, 30, 72, 44, 6, "#bae6fd", AZUL_OSCURO, 2.2),
            L("M44 64 L116 64", AZUL_OSCURO, 1.6),
            E(60, 46, 3.5, 3.5, BLANCO),
            E(74, 52, 3.5, 3.5, BLANCO),
            E(92, 44, 3.5, 3.5, BLANCO),
            *gotas([(122, 36), (130, 52)]),
        ],
        "Paño suave azul doblado con gotitas de agua limpia.",
        None,
    ),
    "fan yourself": (
        "D",
        fondo_sala()
        + [
            *nino_busto(70, 48, (ROSA, ROSA_OSCURO)),
            E(82, 50, 3, 2, "#fca5a5"),
            P([(102, 62), (128, 34), (134, 54)], AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M90 36 Q96 48 90 60 M98 32 Q104 48 98 64", AGUA_OSCURO, 1.8),
        ],
        "Niño abanicándose la cara acalorada con un abanico.",
        None,
    ),
    "fasten": (
        "D",
        fondo_sala()
        + [
            R(32, 22, 46, 60, 4, AZUL, AZUL_OSCURO, 2.0),
            R(82, 22, 46, 60, 4, AZUL, AZUL_OSCURO, 2.0),
            E(66, 52, 10, 10, MADERA, MADERA_OSCURA, 2.2),
            E(63, 50, 1.5, 1.5, TINTA),
            E(69, 54, 1.5, 1.5, TINTA),
            R(90, 48, 18, 7, 3, BLANCO, AZUL_OSCURO, 1.8),
            *frecha((72, 32), (96, 44), VERDE_OSCURO),
        ],
        "Botón de madera acercándose al ojal para abrochar la chaqueta.",
        None,
    ),
    "feather mask": (
        "D",
        fondo_sala()
        + [
            F("M34 52 C34 36 126 36 126 52 C126 68 96 68 80 56 C64 68 34 68 34 52 Z", MORADO, TINTA, 2.2),
            E(58, 50, 9, 6, BLANCO, TINTA, 1.6),
            E(102, 50, 9, 6, BLANCO, TINTA, 1.6),
            F("M80 38 Q94 12 114 22 Q100 38 80 38 Z", VERDE, VERDE_OSCURO, 1.8),
            F("M80 38 Q66 12 46 22 Q60 38 80 38 Z", ROSA, ROSA_OSCURO, 1.8),
        ],
        "Máscara de fiesta morada adornada con plumas verdes y rosas.",
        None,
    ),
    "feathered hat": (
        "D",
        fondo_sala()
        + [
            E(80, 62, 44, 10, VERDE, VERDE_OSCURO, 2.2),
            F("M50 62 C52 28 108 28 110 62 Z", VERDE, VERDE_OSCURO, 2.2),
            L("M50 56 L110 56", AMARILLO, 4.0),
            F("M94 52 Q116 20 132 24 Q120 46 94 52 Z", NARANJA, NARANJA_OSCURO, 1.8),
        ],
        "Sombrero verde de ala ancha con una pluma naranja curva.",
        None,
    ),
    "feathery": (
        "D",
        fondo_cielo()
        + [
            F("M34 64 Q52 24 72 28 Q62 56 34 64 Z", "#bae6fd", AZUL_OSCURO, 1.8),
            F("M64 68 Q84 22 104 28 Q92 58 64 68 Z", "#fbcfe8", ROSA_OSCURO, 1.8),
            F("M92 64 Q112 30 130 34 Q116 60 92 64 Z", "#fef08a", AMARILLO_OSCURO, 1.8),
        ],
        "Tres plumas suaves de colores flotando ligeras.",
        None,
    ),
    "feed": (
        "D",
        fondo_sala()
        + [
            *bebe(48, 56),
            E(70, 56, 6, 3.5, PLATA, GRIS_OSCURO, 1.8),
            L("M76 56 L102 58", GRIS_OSCURO, 2.8),
            E(70, 55, 4, 2.5, AMARILLO, AMARILLO_OSCURO, 1.2),
            *_mano(114, 62, -0.2),
        ],
        "Mano acercando suavemente la cuchara con comida al bebé.",
        None,
    ),
    "feed the ducks": (
        "D",
        fondo_prado()
        + [
            E(86, 72, 46, 14, AGUA, AGUA_OSCURO, 1.8),
            E(72, 66, 12, 8, BLANCO, GRIS_OSCURO, 1.8),
            E(62, 56, 6, 6, BLANCO, GRIS_OSCURO, 1.8),
            P([(56, 56), (50, 58), (56, 60)], NARANJA, NARANJA_OSCURO, 1.4),
            E(102, 68, 12, 8, BLANCO, GRIS_OSCURO, 1.8),
            E(92, 58, 6, 6, BLANCO, GRIS_OSCURO, 1.8),
            P([(86, 58), (80, 60), (86, 62)], NARANJA, NARANJA_OSCURO, 1.4),
            *_mano(34, 34, 0.3),
            E(50, 44, 2, 2, AMARILLO_OSCURO),
            E(58, 48, 2, 2, AMARILLO_OSCURO),
        ],
        "Mano echando migas a dos patitos blancos en el estanque.",
        None,
    ),
    "feed yourself": (
        "D",
        fondo_mesa()
        + [
            *bebe_sentado(80, 42, (VERDE, VERDE_OSCURO)),
            F("M58 64 C58 84 102 84 102 64 Z", AZUL, AZUL_OSCURO, 2.0),
            *cuchara_prop(84, 52, 24),
        ],
        "Bebé sentado comiendo solo con su cuchara del cuenco.",
        None,
    ),
    "feet on the floor": (
        "D",
        fondo_sala()
        + [
            L("M20 76 L140 76", MADERA_OSCURA, 2.6),
            R(44, 56, 28, 18, 7, ROJO, ROJO_OSCURO, 2.0),
            R(88, 56, 28, 18, 7, ROJO, ROJO_OSCURO, 2.0),
            L("M56 30 L56 56 M100 30 L100 56", PELB, 6.0),
            L("M56 30 L56 56 M100 30 L100 56", PEL, 3.6),
        ],
        "Dos pies calzados con zapatillas apoyados firmes en el suelo.",
        None,
    ),
    "fill a crate": (
        "D",
        fondo_mesa()
        + [
            R(40, 44, 80, 40, 4, MADERA, MADERA_OSCURA, 2.2),
            L("M40 58 L120 58 M40 72 L120 72", MADERA_OSCURA, 1.8),
            E(58, 42, 10, 10, ROJO, ROJO_OSCURO, 1.8),
            E(80, 40, 10, 10, NARANJA, NARANJA_OSCURO, 1.8),
            E(102, 42, 10, 10, ROJO, ROJO_OSCURO, 1.8),
            *frecha((80, 14), (80, 30), VERDE_OSCURO),
        ],
        "Caja de madera de listones llenándose con manzanas y naranjas.",
        None,
    ),
    "fill a space": (
        "D",
        fondo_mesa()
        + [
            R(36, 46, 88, 36, 4, MADERA, MADERA_OSCURA, 2.2),
            R(66, 52, 28, 24, 3, "#451a03"),
            R(66, 16, 28, 24, 3, AZUL, AZUL_OSCURO, 2.0),
            *frecha((80, 42), (80, 56), VERDE_OSCURO),
        ],
        "Bloque azul bajando a encajar para llenar el hueco de la base.",
        None,
    ),
    "fill the bucket": (
        "D",
        fondo_cielo()
        + [
            F("M0 74 L160 74 L160 100 L0 100 Z", "#fde68a", "#d97706", 1.8),
            P([(54, 46), (106, 46), (98, 82), (62, 82)], ROJO, ROJO_OSCURO, 2.2),
            P([(62, 46), (80, 32), (98, 46)], "#f59e0b", "#b45309", 1.8),
            L("M112 22 L124 38", AZUL_OSCURO, 2.8),
            P([(100, 34), (114, 44), (104, 52)], AZUL, AZUL_OSCURO, 1.8),
            *frecha((96, 40), (84, 44), "#b45309"),
        ],
        "Pala de playa llenando de arena un cubo rojo.",
        None,
    ),
    "fin": (
        "D",
        fondo_mar()
        + [
            F("M64 62 Q76 18 102 22 Q92 44 96 62 Z", AZUL, AZUL_OSCURO, 2.2),
            L("M24 62 Q52 56 80 62 Q108 68 136 62", BLANCO, 2.2),
        ],
        "Aleta dorsal azul asomando sobre las olas del mar.",
        None,
    ),
    "finger on your nose": (
        "D",
        fondo_sala()
        + [
            E(80, 42, 24, 26, PEL, PELB, 2.4),
            F("M56 34 C58 12 102 12 104 34 C92 24 68 24 56 34 Z", BARRO),
            E(70, 38, 2.2, 2.6, TINTA),
            E(90, 38, 2.2, 2.6, TINTA),
            L("M74 56 Q80 61 86 56", "#9a3412", 1.8),
            E(80, 46, 3.5, 3, "#fca5a5", PELB, 1.3),
            E(94, 72, 7, 7, PEL, PELB, 1.8),
            L("M90 66 L82 48", PELB, 4.4),
            L("M90 66 L82 48", PEL, 2.6),
            E(81, 47, 2.8, 2.8, PEL, PELB, 1.2),
        ],
        "Dedo índice tocando suavemente la punta de la nariz.",
        None,
    ),
    "first": (
        "D",
        fondo_sala()
        + [
            R(28, 72, 32, 18, 3, GRIS, GRIS_OSCURO, 1.8),
            R(64, 58, 32, 32, 3, DORADO, AMARILLO_OSCURO, 2.2),
            R(100, 76, 32, 14, 3, TIERRA_CLARA, MADERA_OSCURA, 1.8),
            _estrella(80, 74, 8, 3.6, BLANCO, AMARILLO_OSCURO),
            *_nino_pie(80, 16, (ROJO, ROJO_OSCURO), 1),
        ],
        "Podio con el puesto más alto dorado y estrella brillante.",
        None,
    ),
    "fish supper": (
        "D",
        fondo_noite()
        + [
            R(20, 60, 120, 30, 4, MADERA, MADERA_OSCURA, 2.0),
            *plato_prop(80, 70, 32),
            F("M56 68 Q78 54 102 68 Q78 82 56 68 Z", PLATA, AZUL_OSCURO, 2.0),
            P([(102, 68), (112, 60), (112, 76)], PLATA, AZUL_OSCURO, 1.8),
            E(66, 66, 1.6, 1.6, TINTA),
            F("M26 16 C18 18 18 32 28 34 C22 28 22 20 26 16 Z", AMARILLO, AMARILLO_OSCURO, 1.5),
        ],
        "Cena nocturna de pescado servido entero en un plato bajo la luna.",
        None,
    ),
    "fishing hole": (
        "D",
        fondo_cielo()
        + [
            F("M0 44 L160 44 L160 100 L0 100 Z", "#e0f2fe", AGUA_OSCURO, 1.8),
            E(80, 68, 30, 12, MAR_PROF, AZUL_OSCURO, 2.2),
            L("M34 20 L80 34", MADERA_OSCURA, 3.0),
            L("M80 34 L80 68", TINTA, 1.6),
            E(80, 62, 3.5, 4.5, ROJO, ROJO_OSCURO, 1.3),
        ],
        "Agujero circular en el hielo con caña de pescar bajando al agua.",
        None,
    ),
    "fit": (
        "D",
        fondo_mesa()
        + [
            P([(34, 48), (126, 48), (126, 82), (34, 82)], VERDE, VERDE_OSCURO, 2.2),
            P([(62, 48), (98, 48), (88, 68), (72, 68)], "#064e3b"),
            P([(62, 18), (98, 18), (88, 38), (72, 38)], AMARILLO, AMARILLO_OSCURO, 2.0),
            *frecha((80, 40), (80, 52), TINTA),
        ],
        "Pieza encajando exactamente en su hueco correspondiente.",
        None,
    ),
    "flap arms": (
        "D",
        fondo_cielo()
        + [
            *nino((80, 32), (80, 44), (80, 60), [[(68, 46), (40, 32)], [(92, 46), (120, 32)]], [[(74, 82)], [(86, 82)]], camisa=(NARANJA, NARANJA_OSCURO), mira=1),
            L("M38 22 Q48 16 58 22 M38 42 Q48 48 58 42", AZUL_OSCURO, 2.0),
            L("M102 22 Q112 16 122 22 M102 42 Q112 48 122 42", AZUL_OSCURO, 2.0),
        ],
        "Niño batiendo ambos brazos extendidos arriba y abajo como alas.",
        None,
    ),
    "flexible body": (
        "D",
        fondo_sala()
        + [
            R(24, 78, 112, 10, 4, MORADO, TINTA, 1.8),
            L("M58 76 L62 44", AZUL_OSCURO, 8.0),
            L("M58 76 L62 44", AZUL, 5.0),
            L("M62 44 Q86 38 100 54", ROJO_OSCURO, 11.0),
            L("M62 44 Q86 38 100 54", ROJO, 8.0),
            L("M96 56 L66 74", PELB, 5.0),
            L("M96 56 L66 74", PEL, 3.0),
            E(104, 58, 8, 8, PEL, PELB, 1.8),
            L("M52 28 Q80 18 106 32", VERDE_OSCURO, 2.0),
        ],
        "Niño flexionando el cuerpo con flexibilidad hacia las puntas de los pies.",
        None,
    ),
    "float away": (
        "D",
        fondo_cielo()
        + [
            E(56, 36, 13, 15, ROJO, ROJO_OSCURO, 2.0),
            L("M56 51 Q50 66 56 76", TINTA, 1.6),
            *pompas([(104, 28, 7), (118, 42, 5.5), (96, 52, 4.5)]),
            *frecha((40, 68), (82, 22), AZUL_OSCURO),
        ],
        "Globo y pompas de jabón alejándose flotando por el cielo.",
        None,
    ),
    "float down": (
        "D",
        fondo_cielo()
        + [
            F("M64 24 Q80 12 96 24 Q82 32 64 24 Z", BLANCO, GRIS_OSCURO, 1.8),
            L("M66 24 L80 42 L94 24", TINTA, 1.4),
            E(80, 44, 3, 3, MADERA, MADERA_OSCURA, 1.3),
            L("M80 48 Q98 58 76 68 Q62 76 80 84", AGUA_OSCURO, 1.8),
            *frecha((108, 34), (108, 78), AZUL_OSCURO),
        ],
        "Semilla paracaídas bajando flotando suavemente hacia el suelo.",
        None,
    ),
    "float in space": (
        "D",
        fondo_noite()
        + [
            E(124, 28, 12, 12, AMARILLO, NARANJA_OSCURO, 1.8),
            L("M106 32 Q124 20 142 26", ROJO, 2.4),
            *nino((62, 42), (66, 54), (70, 66), [[(50, 50)], [(82, 46)]], [[(60, 80)], [(80, 76)]], camisa=(BLANCO, GRIS_OSCURO), mira=1),
            E(62, 42, 12, 12, "#e0f2fe", AZUL_OSCURO, 1.6),
            _estrella(30, 26, 5, 2),
            _estrella(94, 72, 4, 1.8),
        ],
        "Pequeño astronauta flotando en el espacio entre estrellas y planeta.",
        None,
    ),
    "floppy": (
        "D",
        fondo_sala()
        + [
            E(80, 60, 14, 18, TIERRA_CLARA, MADERA_OSCURA, 2.0),
            E(80, 38, 12, 11, TIERRA_CLARA, MADERA_OSCURA, 2.0),
            F("M70 32 Q54 36 52 56 Q62 56 68 40 Z", TIERRA_CLARA, MADERA_OSCURA, 1.8),
            F("M90 32 Q106 36 108 56 Q98 56 92 40 Z", TIERRA_CLARA, MADERA_OSCURA, 1.8),
            L("M66 64 L54 78 M94 64 L106 78", MADERA_OSCURA, 4.0),
        ],
        "Conejo de trapo muy blando con las orejas largas y caídas.",
        None,
    ),
    "flower in my hand": (
        "D",
        fondo_sala()
        + [
            *_mano(80, 64, 0.0),
            L("M80 48 L80 28", VERDE_OSCURO, 2.4),
            E(80, 22, 6, 6, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(72, 22, 4, 4, ROSA, ROSA_OSCURO, 1.3),
            E(88, 22, 4, 4, ROSA, ROSA_OSCURO, 1.3),
            E(80, 14, 4, 4, ROSA, ROSA_OSCURO, 1.3),
            E(80, 30, 4, 4, ROSA, ROSA_OSCURO, 1.3),
        ],
        "Flor rosa de pétalos redondos posada suavemente sobre la mano.",
        None,
    ),
    "flowerpot": (
        "D",
        fondo_mesa()
        + [
            P([(56, 48), (104, 48), (94, 84), (66, 84)], "#ea580c", "#9a3412", 2.2),
            R(52, 42, 56, 9, 3, "#f97316", "#9a3412", 2.0),
            L("M80 42 L80 22", VERDE_OSCURO, 2.6),
            F("M80 30 Q62 20 66 36 Q74 36 80 30 Z", VERDE, VERDE_OSCURO, 1.8),
            F("M80 26 Q98 16 94 32 Q86 32 80 26 Z", VERDE, VERDE_OSCURO, 1.8),
        ],
        "Maceta de barro naranja con tierra y brote verde saliendo.",
        None,
    ),
    "fly with wings": (
        "D",
        fondo_cielo()
        + [
            E(80, 48, 20, 11, AZUL, AZUL_OSCURO, 2.0),
            E(60, 44, 7, 7, AZUL, AZUL_OSCURO, 1.8),
            P([(54, 44), (46, 46), (54, 48)], NARANJA, NARANJA_OSCURO, 1.4),
            F("M74 42 Q84 12 106 24 Q96 42 74 42 Z", "#93c5fd", AZUL_OSCURO, 1.8),
            F("M74 52 Q84 74 106 64 Q96 50 74 52 Z", "#93c5fd", AZUL_OSCURO, 1.8),
            L("M110 48 L134 48 M114 56 L130 56", BLANCO, 2.0),
        ],
        "Pájaro azul volando con sus dos alas abiertas por el cielo.",
        None,
    ),
    "fold": (
        "D",
        fondo_mesa()
        + [
            R(44, 24, 72, 52, 4, BLANCO, GRIS_OSCURO, 2.2),
            L("M80 24 L80 76", AZUL_OSCURO, 2.0),
            P([(80, 24), (116, 24), (116, 76), (80, 76)], "#e0f2fe", AZUL_OSCURO, 1.8),
            *frecha((104, 50), (58, 50), ROJO_OSCURO),
        ],
        "Hoja doblándose por la línea central con flecha de pliegue.",
        None,
    ),
    "fold paper": (
        "D",
        fondo_mesa()
        + [
            P([(38, 30), (80, 30), (80, 74), (38, 74)], BLANCO, GRIS_OSCURO, 2.0),
            P([(80, 30), (110, 20), (110, 64), (80, 74)], "#e2e8f0", GRIS_OSCURO, 2.0),
            *_mano(46, 62, -0.2),
            *_mano(108, 54, 0.2),
        ],
        "Dos manos doblando una hoja blanca por la mitad.",
        None,
    ),
    "fold up": (
        "D",
        fondo_mesa()
        + [
            P([(40, 66), (120, 66), (80, 26)], ROJO, ROJO_OSCURO, 2.2),
            E(68, 54, 3, 3, BLANCO),
            E(88, 54, 3, 3, BLANCO),
            E(78, 42, 3, 3, BLANCO),
            *frecha((80, 72), (80, 48), AZUL_OSCURO),
        ],
        "Pañuelo rojo con lunares doblándose hacia arriba en triángulo.",
        None,
    ),
    "food plate": (
        "D",
        fondo_mesa()
        + [
            *plato_prop(80, 50, 32),
            L("M80 22 L80 78 M52 50 L108 50", GRIS_OSCURO, 1.6),
            E(66, 36, 8, 8, VERDE, VERDE_OSCURO, 1.6),
            E(94, 36, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            R(56, 56, 16, 12, 3, "#fde68a", AMARILLO_OSCURO, 1.6),
            E(94, 62, 8, 6, NARANJA, NARANJA_OSCURO, 1.6),
        ],
        "Plato saludable dividido con verduras, fruta y pan.",
        None,
    ),
    "forest": (
        "D",
        fondo_cielo()
        + [
            F("M0 72 L160 72 L160 100 L0 100 Z", HERBA, HERBAB, 1.8),
            R(28, 54, 8, 22, 2, MADERA, MADERA_OSCURA, 1.6),
            E(32, 42, 16, 18, VERDE, VERDE_OSCURO, 2.0),
            R(76, 48, 8, 28, 2, MADERA, MADERA_OSCURA, 1.6),
            P([(54, 58), (106, 58), (80, 20)], VERDE, VERDE_OSCURO, 2.0),
            R(124, 52, 8, 24, 2, MADERA, MADERA_OSCURA, 1.6),
            E(128, 40, 16, 18, HERBAB, VERDE_OSCURO, 2.0),
        ],
        "Bosque frondoso con varios árboles verdes juntos.",
        None,
    ),
    "fortress": (
        "D",
        fondo_prado()
        + [
            R(30, 34, 24, 46, 2, GRIS, GRIS_OSCURO, 2.0),
            R(106, 34, 24, 46, 2, GRIS, GRIS_OSCURO, 2.0),
            R(54, 44, 52, 36, 2, PLATA, GRIS_OSCURO, 2.0),
            R(30, 26, 8, 8, 1, GRIS, GRIS_OSCURO, 1.6),
            R(46, 26, 8, 8, 1, GRIS, GRIS_OSCURO, 1.6),
            R(106, 26, 8, 8, 1, GRIS, GRIS_OSCURO, 1.6),
            R(122, 26, 8, 8, 1, GRIS, GRIS_OSCURO, 1.6),
            F("M70 80 L70 58 Q80 48 90 58 L90 80 Z", MADERA, MADERA_OSCURA, 1.8),
        ],
        "Fortaleza de piedra con murallas almenadas y portón de madera.",
        None,
    ),
    "freeze water": (
        "D",
        fondo_cielo()
        + [
            F("M44 36 C32 54 36 68 44 68 C52 68 56 54 44 36 Z", AGUA, AGUA_OSCURO, 2.0),
            *frecha((58, 52), (82, 52), AZUL_OSCURO),
            R(90, 32, 34, 34, 5, "#bae6fd", AGUA_OSCURO, 2.2),
            L("M98 40 L116 58 M116 40 L98 58", BLANCO, 2.0),
        ],
        "Gota líquida congelándose en un cubito de hielo brillante.",
        None,
    ),
    "friends forever": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(58, 30, (AZUL, AZUL_OSCURO), 1),
            *_nino_pie(102, 30, (ROSA, ROSA_OSCURO), -1),
            L("M72 52 L88 52", PELB, 5.0),
            L("M72 52 L88 52", PEL, 3.0),
            E(80, 24, 6, 6, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Dos amigos juntos dándose las manos en señal de amistad.",
        None,
    ),
    "from hand to hand": (
        "D",
        fondo_sala()
        + [
            *_mano(44, 62, -0.2),
            *_mano(116, 62, 0.2),
            *pelota_prop(80, 36, 10, ROJO, ROJO_OSCURO),
            *frecha((52, 44), (108, 44), AZUL_OSCURO),
        ],
        "Pelota pasando de una mano a la otra en arco.",
        None,
    ),
    "from small to big": (
        "D",
        fondo_prado()
        + [
            E(40, 68, 7, 7, AZUL, AZUL_OSCURO, 1.8),
            E(76, 60, 14, 14, AZUL, AZUL_OSCURO, 2.0),
            E(122, 50, 22, 22, AZUL, AZUL_OSCURO, 2.2),
            *frecha((34, 24), (126, 24), VERDE_OSCURO),
        ],
        "Tres círculos ordenados de menor a mayor de izquierda a derecha.",
        None,
    ),
    "frosty": (
        "D",
        fondo_cielo("#94a3b8")
        + [
            R(36, 20, 88, 60, 4, "#e0f2fe", MADERA_OSCURA, 2.4),
            F("M37 21 L68 21 L37 44 Z", "#bae6fd"),
            F("M123 79 L92 79 L123 56 Z", "#bae6fd"),
            L("M80 20 L80 80 M36 50 L124 50", MADERA_OSCURA, 2.2),
            L("M48 30 L64 40 M56 25 L56 45 M48 40 L64 30", "#0284c7", 2.2),
            L("M94 58 L112 70 M103 54 L103 74 M94 70 L112 58", "#0284c7", 2.2),
        ],
        "Ventana helada cubierta de cristales azules de escarcha.",
        None,
    ),
    "fruit bowl": (
        "D",
        fondo_mesa()
        + [
            E(66, 46, 11, 11, ROJO, ROJO_OSCURO, 1.8),
            E(92, 46, 11, 11, NARANJA, NARANJA_OSCURO, 1.8),
            F("M62 32 Q80 22 98 34 Q82 40 62 32 Z", AMARILLO, AMARILLO_OSCURO, 1.8),
            F("M44 50 C44 82 116 82 116 50 Z", MADERA, MADERA_OSCURA, 2.2),
        ],
        "Frutero de madera rebosante de manzana, naranja y plátano.",
        None,
    ),
    "fruit peel": (
        "D",
        fondo_mesa()
        + [
            E(80, 48, 18, 22, "#fef3c7", AMARILLO_OSCURO, 2.0),
            F("M64 46 Q46 58 50 76 Q64 72 68 56 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            F("M96 46 Q114 58 110 76 Q96 72 92 56 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M74 26 L86 26", VERDE_OSCURO, 3.0),
        ],
        "Plátano con sus tiras amarillas de piel pelándose hacia fuera.",
        None,
    ),
    "fruit salad": (
        "D",
        fondo_mesa()
        + [
            F("M44 50 C44 82 116 82 116 50 Z", "#e0f2fe", AZUL_OSCURO, 2.2),
            R(56, 44, 10, 10, 2, ROJO, ROJO_OSCURO, 1.4),
            E(78, 48, 7, 7, VERDE, VERDE_OSCURO, 1.4),
            R(92, 44, 10, 10, 2, AMARILLO, AMARILLO_OSCURO, 1.4),
            E(68, 54, 5, 5, MORADO, TINTA, 1.3),
            *cuchara_prop(92, 28, 28),
        ],
        "Cuenco transparente con trozos de macedonia de frutas y cuchara.",
        None,
    ),
    "full to the top": (
        "D",
        fondo_mesa()
        + [
            P([(56, 26), (104, 26), (96, 80), (64, 80)], "#e0f2fe", AZUL_OSCURO, 2.2),
            P([(57, 28), (103, 28), (95, 78), (65, 78)], AGUA, AGUA_OSCURO, 1.8),
            E(80, 28, 23, 5, "#bae6fd", AZUL_OSCURO, 1.8),
        ],
        "Vaso transparente lleno de agua hasta el borde superior.",
        None,
    ),
    "gap": (
        "D",
        fondo_sala()
        + [
            R(26, 36, 32, 44, 4, MADERA, MADERA_OSCURA, 2.2),
            R(102, 36, 32, 44, 4, MADERA, MADERA_OSCURA, 2.2),
            *frecha((58, 58), (102, 58), VERDE_OSCURO),
            *frecha((80, 26), (80, 74), ROJO_OSCURO),
        ],
        "Hueco abierto claramente entre dos bloques con flechas pasando.",
        None,
    ),
    "garden plot": (
        "D",
        fondo_cielo()
        + [
            F("M0 70 L160 70 L160 100 L0 100 Z", HERBA, HERBAB, 1.6),
            R(28, 48, 104, 34, 4, TIERRA, BARRO, 2.2),
            L("M44 48 L44 82 M80 48 L80 82 M116 48 L116 82", BARRO, 1.8),
            L("M44 48 L44 36 M80 48 L80 34 M116 48 L116 36", VERDE_OSCURO, 2.4),
            E(44, 34, 5, 4, VERDE, VERDE_OSCURO, 1.3),
            E(80, 32, 5, 4, VERDE, VERDE_OSCURO, 1.3),
            E(116, 34, 5, 4, VERDE, VERDE_OSCURO, 1.3),
        ],
        "Parcela rectangular de tierra cultivada con brotes en hilera.",
        None,
    ),
    "garden trowel": (
        "D",
        fondo_mesa()
        + [
            L("M36 74 L68 50", MADERA, 7.0),
            L("M36 74 L68 50", MADERA_OSCURA, 2.2),
            P([(64, 46), (110, 20), (122, 36), (76, 56)], PLATA, GRIS_OSCURO, 2.2),
            F("M82 38 Q100 22 114 32 Q96 48 82 38 Z", TIERRA, BARRO, 1.6),
        ],
        "Pala pequeña de jardinería recogiendo tierra marrón.",
        None,
    ),
    "gather": (
        "D",
        fondo_prado()
        + [
            E(72, 66, 8, 6, NARANJA, NARANJA_OSCURO, 1.6),
            E(88, 66, 8, 6, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(80, 56, 8, 6, ROJO, ROJO_OSCURO, 1.6),
            *_mano(42, 60, -0.2),
            *_mano(118, 60, 0.2),
            *frecha((48, 38), (72, 48), VERDE_OSCURO),
            *frecha((112, 38), (88, 48), VERDE_OSCURO),
        ],
        "Dos manos juntando hojas caídas hacia un montón central.",
        None,
    ),
    "gather acorns": (
        "D",
        fondo_prado()
        + [
            P([(84, 52), (126, 52), (118, 78), (92, 78)], MADERA, MADERA_OSCURA, 2.2),
            *bellota_prop(46, 68),
            *bellota_prop(64, 72),
            *bellota_prop(102, 54),
            *frecha((54, 50), (96, 48), MADERA_OSCURA),
        ],
        "Bellotas recogidas del suelo y guardadas en una cesta.",
        None,
    ),
    "gently down the stream": (
        "D",
        fondo_mar()
        + [
            L("M10 38 Q80 28 150 38 M10 78 Q80 88 150 78", BLANCO, 2.0),
            P([(48, 48), (112, 48), (100, 66), (60, 66)], MADERA, MADERA_OSCURA, 2.2),
            L("M74 52 L60 74 M86 52 L100 74", MADERA_OSCURA, 2.8),
            *frecha((24, 56), (44, 56), BLANCO),
        ],
        "Barquita con remos navegando suavemente río abajo.",
        None,
    ),
    "get off": (
        "D",
        fondo_sala()
        + [
            R(20, 44, 42, 42, 3, MADERA, MADERA_OSCURA, 2.0),
            R(44, 64, 28, 22, 3, TIERRA_CLARA, MADERA_OSCURA, 2.0),
            *_nino_pie(100, 34, (VERDE, VERDE_OSCURO), 1),
            *frecha((54, 24), (84, 42), ROJO_OSCURO),
        ],
        "Niño bajando del escalón al suelo siguiendo la flecha.",
        None,
    ),
    "get ready for bed": (
        "D",
        fondo_noite()
        + [
            R(26, 56, 108, 26, 4, MADERA, MADERA_OSCURA, 2.0),
            R(32, 48, 26, 12, 4, BLANCO, GRIS_OSCURO, 1.8),
            R(56, 50, 74, 24, 4, AZUL, AZUL_OSCURO, 2.0),
            *_nino_pie(42, 34, (MORADO, TINTA), 1),
            F("M124 14 C108 14 104 34 124 38 C112 32 112 18 124 14 Z", AMARILLO, AMARILLO_OSCURO, 1.6),
        ],
        "Niño en pijama preparándose junto a su cama bajo la luna.",
        None,
    ),
    "giggle": (
        "D",
        fondo_sala()
        + [
            *bebe_sentado(80, 48, (ROSA, ROSA_OSCURO)),
            L("M66 44 Q72 40 76 44 M84 44 Q88 40 94 44", TINTA, 1.8),
            E(70, 52, 3, 2, "#fca5a5"),
            E(90, 52, 3, 2, "#fca5a5"),
            L("M50 38 Q44 46 50 54 M110 38 Q116 46 110 54", ROSA_OSCURO, 2.0),
        ],
        "Bebé riéndose feliz con ondas suaves de risita a los lados.",
        None,
    ),
    "give": (
        "D",
        fondo_sala()
        + [
            *_mano(44, 62, -0.2),
            *_mano(116, 62, 0.2),
            R(68, 32, 24, 22, 4, ROJO, ROJO_OSCURO, 2.0),
            L("M80 32 L80 54 M68 43 L92 43", AMARILLO, 2.8),
            *frecha((54, 42), (66, 42), VERDE_OSCURO),
        ],
        "Mano entregando un pequeño regalo a la otra mano.",
        None,
    ),
    "give a card": (
        "D",
        fondo_mesa()
        + [
            R(54, 26, 52, 40, 4, "#fefce8", AZUL_OSCURO, 2.2),
            E(80, 46, 8, 8, ROSA, ROSA_OSCURO, 1.6),
            E(80, 46, 3, 3, AMARILLO),
            *_mano(42, 62, -0.2),
            *frecha((96, 46), (124, 46), VERDE_OSCURO),
        ],
        "Mano ofreciendo una postal decorada con una flor.",
        None,
    ),
    "give me five": (
        "D",
        fondo_sala()
        + [
            *_mano(66, 52, 0.25),
            *_mano(94, 52, -0.25),
            L("M80 18 L80 28 M62 24 L68 32 M98 24 L92 32", AMARILLO_OSCURO, 2.4),
        ],
        "Dos palmas abiertas chocando los cinco con destellos.",
        None,
    ),
    "glass slipper": (
        "D",
        fondo_sala()
        + [
            F("M36 68 Q40 44 54 46 Q68 58 88 58 Q106 54 118 62 Q118 72 86 72 L46 72 Z", "#bae6fd", AZUL_OSCURO, 2.2),
            R(36, 68, 12, 12, 2, "#7dd3fc", AZUL_OSCURO, 1.8),
            L("M60 66 Q84 68 108 64", BLANCO, 2.2),
            _estrella(106, 36, 7, 2.8, BLANCO, AZUL_OSCURO),
        ],
        "Zapatito brillante de cristal azul celeste con destello.",
        None,
    ),
    "glassy": (
        "D",
        fondo_cielo()
        + [
            P([(0, 62), (160, 62), (160, 100), (0, 100)], "#7dd3fc", AZUL_OSCURO, 1.8),
            P([(30, 62), (76, 62), (53, 28)], VERDE, VERDE_OSCURO, 1.8),
            P([(30, 62), (76, 62), (53, 86)], "#6ee7b7", VERDE_OSCURO, 1.2),
            L("M88 72 L134 72 M96 80 L124 80", BLANCO, 2.2),
        ],
        "Superficie de lago tan lisa como un cristal reflejando el paisaje.",
        None,
    ),
    "glide": (
        "D",
        fondo_cielo()
        + [
            P([(44, 42), (116, 34), (72, 56)], BLANCO, AZUL_OSCURO, 2.2),
            P([(72, 56), (116, 34), (66, 48)], "#bae6fd", AZUL_OSCURO, 1.8),
            L("M18 46 L42 46 M24 54 L54 54", BLANCO, 2.0),
        ],
        "Avión de papel planeando suavemente en línea recta.",
        None,
    ),
    "gloomy": (
        "D",
        fondo_cielo("#64748b")
        + [
            F("M36 42 Q32 24 54 22 Q68 12 88 22 Q112 20 118 38 Q126 52 108 54 L46 54 Q30 54 36 42 Z", "#334155", TINTA, 2.0),
            L("M48 60 L42 78 M68 60 L62 78 M88 60 L82 78 M108 60 L102 78", "#94a3b8", 2.0),
        ],
        "Cielo gris oscuro cubierto de nubes grises y lluvia.",
        None,
    ),
    "glossy black": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 32, 24, "#0f172a", TINTA, 2.4),
            L("M60 36 Q74 30 88 34 M56 44 L64 42", BLANCO, 3.0),
            _estrella(106, 36, 7, 2.8, BLANCO, AMARILLO_OSCURO),
        ],
        "Canto rodado negro muy brillante con reflejo blanco luminoso.",
        None,
    ),
    "glowing moon": (
        "D",
        fondo_noite()
        + [
            E(80, 48, 30, 30, "#fde047"),
            E(80, 48, 22, 22, "#fef08a", AMARILLO_OSCURO, 2.0),
            _estrella(30, 26, 5, 2),
            _estrella(126, 68, 5, 2),
        ],
        "Luna llena amarilla brillando intensamente en el cielo nocturno.",
        None,
    ),
    "glue": (
        "D",
        fondo_mesa()
        + [
            R(62, 34, 36, 46, 6, BLANCO, AZUL_OSCURO, 2.2),
            R(70, 22, 20, 12, 2, NARANJA, NARANJA_OSCURO, 1.8),
            P([(76, 12), (84, 12), (82, 22), (78, 22)], NARANJA, NARANJA_OSCURO, 1.6),
            R(68, 48, 24, 18, 3, AZUL, AZUL_OSCURO, 1.4),
            E(114, 74, 12, 5, BLANCO, GRIS_OSCURO, 1.6),
        ],
        "Bote de pegamento escolar con tapón naranja y gota blanca.",
        None,
    ),
    "goodbye card": (
        "D",
        fondo_mesa()
        + [
            R(36, 26, 56, 44, 4, "#fefce8", ROJO_OSCURO, 2.0),
            *_mano(64, 52, 0.25),
            L("M44 36 Q48 30 54 34", ROJO_OSCURO, 2.0),
            R(98, 44, 36, 26, 3, "#e0f2fe", AZUL_OSCURO, 2.0),
            P([(98, 44), (116, 58), (134, 44)], BLANCO, AZUL_OSCURO, 1.6),
        ],
        "Tarjeta de despedida con una mano saludando y un sobre al lado.",
        None,
    ),
    "grab": (
        "D",
        fondo_sala()
        + [
            *pelota_prop(80, 42, 16, ROJO, ROJO_OSCURO),
            R(66, 62, 28, 22, 8, PEL, PELB, 2.0),
            R(58, 42, 9, 24, 4, PEL, PELB, 1.8),
            R(70, 32, 8, 20, 4, PEL, PELB, 1.8),
            R(80, 30, 8, 22, 4, PEL, PELB, 1.8),
            R(90, 34, 8, 20, 4, PEL, PELB, 1.8),
        ],
        "Mano con dedos cerrados agarrando con fuerza una pelota roja.",
        None,
    ),
    "graduated": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(80, 38, (AZUL, AZUL_OSCURO), 1),
            P([(60, 26), (80, 18), (100, 26), (80, 34)], NEGRO, TINTA, 1.8),
            L("M96 28 L96 42", DORADO, 2.2),
            R(100, 34, 12, 22, 4, "#fef3c7", AMARILLO_OSCURO, 1.6),
        ],
        "Niño sonriente con birrete negro sosteniendo su diploma.",
        None,
    ),
    "grandma": (
        "D",
        fondo_sala()
        + [
            E(80, 20, 11, 9, "#e2e8f0", GRIS_OSCURO, 2.0),
            E(80, 42, 22, 24, PEL, PELB, 2.2),
            F("M58 36 C60 18 100 18 102 36 Q90 28 58 36 Z", "#e2e8f0", GRIS_OSCURO, 1.6),
            E(71, 42, 6, 5, BLANCO, TINTA, 1.8),
            E(89, 42, 6, 5, BLANCO, TINTA, 1.8),
            L("M77 42 L83 42", TINTA, 1.8),
            L("M73 54 Q80 60 87 54", "#9a3412", 1.8),
            R(56, 64, 48, 24, 8, MORADO, TINTA, 2.0),
        ],
        "Retrato cariñoso de la abuela con moño blanco y gafas.",
        None,
    ),
    "group": (
        "D",
        fondo_sala()
        + [
            E(46, 50, 24, 24, "#e0f2fe", AZUL_OSCURO, 2.0),
            E(38, 44, 6, 6, ROJO, ROJO_OSCURO, 1.4),
            E(54, 44, 6, 6, ROJO, ROJO_OSCURO, 1.4),
            E(46, 58, 6, 6, ROJO, ROJO_OSCURO, 1.4),
            E(114, 50, 24, 24, "#fef3c7", AMARILLO_OSCURO, 2.0),
            E(106, 44, 6, 6, VERDE, VERDE_OSCURO, 1.4),
            E(122, 44, 6, 6, VERDE, VERDE_OSCURO, 1.4),
            E(114, 58, 6, 6, VERDE, VERDE_OSCURO, 1.4),
        ],
        "Piezas de colores agrupadas en dos conjuntos separados.",
        None,
    ),
    "grow": (
        "D",
        fondo_prado()
        + [
            L("M44 76 L44 62", VERDE_OSCURO, 2.4),
            E(40, 60, 4, 3, VERDE, VERDE_OSCURO, 1.3),
            E(48, 60, 4, 3, VERDE, VERDE_OSCURO, 1.3),
            *frecha((58, 62), (82, 44), VERDE_OSCURO),
            L("M106 76 L106 28", VERDE_OSCURO, 3.2),
            F("M106 50 Q86 38 92 56 Z", VERDE, VERDE_OSCURO, 1.8),
            F("M106 38 Q126 26 120 44 Z", VERDE, VERDE_OSCURO, 1.8),
            E(106, 22, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Planta pequeña creciendo hasta convertirse en flor alta.",
        None,
    ),
    "grow up": (
        "D",
        fondo_sala()
        + [
            *bebe_sentado(40, 64, (AMARILLO, AMARILLO_OSCURO)),
            *_nino_pie(76, 42, (VERDE, VERDE_OSCURO), 1),
            *_nino_pie(118, 22, (AZUL, AZUL_OSCURO), 1),
            *frecha((40, 42), (104, 22), ROJO_OSCURO),
        ],
        "Secuencia de crecimiento desde bebé hasta niño mayor.",
        None,
    ),
    "grown-up": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(58, 42, (AMARILLO, AMARILLO_OSCURO), 1),
            *nino((104, 22), (104, 36), (104, 56), [[(90, 48)], [(118, 48)]], [[(96, 86)], [(112, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        ],
        "Persona adulta alta de pie junto a un niño pequeño.",
        None,
    ),
    "growth chart": (
        "D",
        fondo_sala()
        + [
            R(36, 16, 18, 72, 3, "#fef3c7", MADERA_OSCURA, 2.0),
            L("M46 24 L54 24 M42 36 L54 36 M46 48 L54 48 M42 60 L54 60 M46 72 L54 72", MADERA_OSCURA, 1.8),
            *_nino_pie(86, 34, (VERDE, VERDE_OSCURO), -1),
            L("M54 32 L78 32", ROJO, 2.2),
        ],
        "Regla vertical de pared midiendo la altura de un niño.",
        None,
    ),
    "hair": (
        "D",
        fondo_sala()
        + [
            E(80, 52, 24, 24, PEL, PELB, 2.2),
            F("M52 50 C52 16 108 16 108 50 Q96 34 80 38 Q64 34 52 50 Z", BARRO, MADERA_OSCURA, 2.0),
            F("M54 26 Q80 12 106 26", MADERA_OSCURA, MADERA_OSCURA, 2.0),
            E(71, 52, 2.2, 2.5, TINTA),
            E(89, 52, 2.2, 2.5, TINTA),
            L("M74 62 Q80 68 86 62", "#9a3412", 1.6),
        ],
        "Cabeza con abundante pelo castaño ondulado.",
        None,
    ),
    "hairbrush": (
        "D",
        fondo_mesa()
        + [
            R(74, 54, 12, 34, 5, MADERA, MADERA_OSCURA, 2.0),
            E(80, 36, 18, 24, MADERA, MADERA_OSCURA, 2.2),
            E(80, 36, 12, 18, GRIS_OSCURO),
            E(75, 28, 1.5, 1.5, BLANCO),
            E(85, 28, 1.5, 1.5, BLANCO),
            E(75, 36, 1.5, 1.5, BLANCO),
            E(85, 36, 1.5, 1.5, BLANCO),
            E(75, 44, 1.5, 1.5, BLANCO),
            E(85, 44, 1.5, 1.5, BLANCO),
        ],
        "Cepillo ovalado de madera con púas para peinar el pelo.",
        None,
    ),
    "half": (
        "D",
        fondo_mesa()
        + [
            F("M72 24 C46 24 46 76 72 76 Z", ROJO, ROJO_OSCURO, 2.2),
            F("M88 24 C114 24 114 76 88 76 Z", "#fef3c7", ROJO_OSCURO, 2.2),
            E(95, 48, 2.5, 4.0, BARRO),
            L("M80 18 L80 82", TINTA, 2.0),
        ],
        "Manzana partida exactamente por la mitad en dos mitades iguales.",
        None,
    ),
    "hand on paper": (
        "D",
        fondo_mesa()
        + [
            R(38, 20, 84, 62, 4, BLANCO, GRIS_OSCURO, 2.2),
            *_mano(80, 56, 0.0),
        ],
        "Mano abierta posada sobre una hoja blanca de papel.",
        None,
    ),
    "hand over": (
        "D",
        fondo_sala()
        + [
            *_mano(44, 62, -0.2),
            *_mano(116, 62, 0.2),
            R(70, 36, 20, 20, 4, AZUL, AZUL_OSCURO, 2.0),
            *frecha((52, 46), (108, 46), VERDE_OSCURO),
        ],
        "Bloque azul entregado directamente de una mano a la otra.",
        None,
    ),
    "handle": (
        "D",
        fondo_sala()
        + [
            R(40, 22, 80, 58, 5, MADERA, MADERA_OSCURA, 2.2),
            L("M66 36 L66 64", PLATA, 5.0),
            E(66, 36, 4, 4, GRIS_OSCURO),
            E(66, 64, 4, 4, GRIS_OSCURO),
            *_mano(84, 52, -0.3),
        ],
        "Mano agarrándose al asidero metálico de la puerta.",
        None,
    ),
    "handprint": (
        "D",
        fondo_mesa()
        + [
            R(40, 18, 80, 66, 4, BLANCO, GRIS_OSCURO, 2.2),
            E(80, 58, 12, 13, ROJO, ROJO_OSCURO, 1.5),
            L("M72 60 L60 52 M72 48 L67 34 M78 45 L78 28 M85 46 L88 30 M90 52 L98 40", ROJO, 4.2),
        ],
        "Huella de mano estampada con pintura roja sobre un folio.",
        None,
    ),
    "hands in pockets": (
        "D",
        fondo_sala()
        + [
            R(56, 24, 48, 30, 6, VERDE, VERDE_OSCURO, 2.0),
            R(58, 54, 44, 34, 4, AZUL, AZUL_OSCURO, 2.0),
            L("M80 62 L80 88", AZUL_OSCURO, 2.0),
            P([(62, 58), (74, 58), (72, 70), (64, 70)], "#93c5fd", AZUL_OSCURO, 1.6),
            P([(86, 58), (98, 58), (96, 70), (88, 70)], "#93c5fd", AZUL_OSCURO, 1.6),
            L("M56 36 L68 62 M104 36 L92 62", PELB, 5.0),
            L("M56 36 L68 62 M104 36 L92 62", PEL, 3.0),
        ],
        "Niño con ambas manos metidas en los bolsillos del pantalón.",
        None,
    ),
    "hands in the dough": (
        "D",
        fondo_mesa()
        + [
            F("M38 66 C38 42 122 42 122 66 C118 76 42 76 38 66 Z", "#fde68a", AMARILLO_OSCURO, 2.2),
            *_mano(62, 48, 0.2),
            *_mano(98, 48, -0.2),
        ],
        "Dos manos hundidas amasando una masa dorada de pan.",
        None,
    ),
    "hands on your tummy": (
        "D",
        fondo_sala()
        + [
            *nino((80, 26), (80, 38), (80, 56), [[(68, 44), (74, 54)], [(92, 44), (86, 54)]], [[(74, 80)], [(86, 80)]], camisa=(NARANJA, NARANJA_OSCURO), mira=1),
            E(80, 54, 8, 6, PEL, PELB, 1.4),
        ],
        "Niño de pie con ambas manos apoyadas sobre su barriga.",
        None,
    ),
    "hands up and cheer": (
        "D",
        fondo_sala()
        + [
            *nino((54, 34), (54, 46), (54, 64), [[(42, 42), (38, 22)], [(66, 42), (70, 22)]], [[(48, 84)], [(60, 84)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *nino((106, 34), (106, 46), (106, 64), [[(94, 42), (90, 22)], [(118, 42), (122, 22)]], [[(100, 84)], [(112, 84)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
            _estrella(80, 22, 7, 3),
            E(34, 18, 3, 3, ROSA),
            E(126, 18, 3, 3, VERDE),
        ],
        "Dos niños con las manos en alto animando y celebrando.",
        None,
    ),
    "handspan": (
        "D",
        fondo_mesa()
        + [
            R(28, 62, 104, 16, 3, MADERA, MADERA_OSCURA, 2.0),
            L("M44 46 L116 46", ROJO_OSCURO, 2.2),
            P([(44, 46), (52, 42), (52, 50)], ROJO_OSCURO),
            P([(116, 46), (108, 42), (108, 50)], ROJO_OSCURO),
            *_mano(80, 52, 0.0),
        ],
        "Mano abierta extendida midiendo un palmo sobre la madera.",
        None,
    ),
    "hang ornaments": (
        "D",
        fondo_sala()
        + [
            P([(40, 74), (120, 74), (80, 20)], VERDE, VERDE_OSCURO, 2.2),
            R(74, 74, 12, 12, 2, MADERA, MADERA_OSCURA, 1.8),
            _estrella(80, 18, 7, 3),
            E(68, 50, 6, 6, ROJO, ROJO_OSCURO, 1.5),
            E(92, 56, 6, 6, AZUL, AZUL_OSCURO, 1.5),
            *_mano(108, 42, -0.3),
        ],
        "Mano colgando bolas de colores para adornar el árbol.",
        None,
    ),
    "hang up": (
        "D",
        fondo_sala()
        + [
            E(80, 16, 4, 4, GRIS_OSCURO),
            L("M80 20 L52 34 L108 34 L80 20", MADERA_OSCURA, 2.4),
            P([(52, 34), (108, 34), (114, 78), (46, 78)], AZUL, AZUL_OSCURO, 2.2),
            L("M80 34 L80 78", AZUL_OSCURO, 2.0),
        ],
        "Abrigo azul colgado ordenadamente en una percha de madera.",
        None,
    ),
    "harbour wall": (
        "D",
        fondo_mar()
        + [
            F("M0 40 L26 40 L26 86 L0 86 Z", TIERRA_CLARA, BARRO, 1.8),
            P([(20, 48), (118, 54), (118, 68), (20, 72)], GRIS, GRIS_OSCURO, 2.2),
            L("M46 50 L46 70 M76 52 L76 69 M100 54 L100 68", GRIS_OSCURO, 1.8),
            R(56, 44, 6, 8, 2, NEGRO, TINTA, 1.4),
            R(84, 46, 6, 8, 2, NEGRO, TINTA, 1.4),
            R(106, 34, 10, 22, 2, ROJO, ROJO_OSCURO, 1.8),
            E(111, 32, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.4),
        ],
        "Espigón largo de piedra saliendo desde la costa con bolardos y baliza.",
        None,
    ),
    "hard": (
        "D",
        fondo_mesa()
        + [
            P([(52, 74), (44, 52), (66, 30), (98, 32), (116, 54), (104, 74)], GRIS, GRIS_OSCURO, 2.4),
            L("M66 44 L82 44 M74 56 L92 54", BLANCO, 2.0),
            L("M34 30 L48 36 M126 30 L112 36", ROJO_OSCURO, 2.2),
        ],
        "Roca gris sólida y dura que no cede al golpe.",
        None,
    ),
    "harvest": (
        "D",
        fondo_prado()
        + [
            P([(44, 52), (116, 52), (106, 82), (54, 82)], MADERA, MADERA_OSCURA, 2.2),
            L("M58 52 Q80 20 102 52", MADERA_OSCURA, 3.0),
            E(66, 48, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            E(88, 48, 11, 9, NARANJA, NARANJA_OSCURO, 1.8),
            L("M102 44 L112 28", AMARILLO_OSCURO, 2.4),
        ],
        "Cesta llena de la cosecha de manzanas, calabaza y espigas.",
        None,
    ),
    "hat on, please": (
        "D",
        fondo_sala()
        + [
            *bebe_sentado(80, 56, (AZUL, AZUL_OSCURO)),
            E(80, 42, 20, 6, AMARILLO, AMARILLO_OSCURO, 1.8),
            F("M66 42 C68 24 92 24 94 42 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            *frecha((80, 12), (80, 24), VERDE_OSCURO),
        ],
        "Sombrero amarillo bajando con cariño sobre la cabeza del bebé.",
        None,
    ),
    "heaped": (
        "D",
        fondo_mesa()
        + [
            P([(44, 62), (116, 62), (106, 82), (54, 82)], AZUL, AZUL_OSCURO, 2.2),
            F("M48 62 C54 24 106 24 112 62 Z", "#fde68a", AMARILLO_OSCURO, 2.0),
            E(72, 46, 3, 3, "#d97706"),
            E(88, 48, 3, 3, "#d97706"),
            E(80, 38, 3, 3, "#d97706"),
        ],
        "Cuenco colmado con un montón muy alto por encima del borde.",
        None,
    ),
    "heartbeat": (
        "D",
        fondo_sala()
        + [
            F("M80 76 C50 60 36 42 36 30 C36 18 52 14 66 22 C74 26 78 32 80 36 C82 32 86 26 94 22 C108 14 124 18 124 30 C124 42 110 60 80 76 Z", ROJO, ROJO_OSCURO, 2.2),
            L("M46 46 L66 46 L72 32 L80 58 L88 38 L94 46 L114 46", BLANCO, 2.6),
        ],
        "Corazón rojo con línea de latido rítmico marcando el pulso.",
        None,
    ),
    "heavier": (
        "D",
        fondo_sala()
        + [
            P([(72, 82), (88, 82), (80, 44)], GRIS, GRIS_OSCURO, 2.0),
            L("M34 54 L126 34", GRIS_OSCURO, 3.0),
            E(42, 44, 14, 11, "#475569", TINTA, 2.0),
            F("M112 24 Q124 14 134 22 Q122 30 112 24 Z", BLANCO, AZUL_OSCURO, 1.6),
            *frecha((24, 34), (24, 62), ROJO_OSCURO),
        ],
        "Balanza muy inclinada hacia el lado de la piedra más pesada.",
        None,
    ),
    "heavier than water": (
        "D",
        fondo_mar()
        + [
            R(36, 22, 88, 60, 4, "#e0f2fe", AZUL_OSCURO, 2.2),
            F("M37 44 L123 44 L123 81 L37 81 Z", AGUA, AGUA_OSCURO, 1.4),
            P([(64, 78), (60, 62), (78, 56), (96, 64), (92, 78)], "#475569", TINTA, 2.0),
            *frecha((80, 28), (80, 52), ROJO_OSCURO),
        ],
        "Piedra pesada hundida hasta el fondo del recipiente con agua.",
        None,
    ),
    "heaviest": (
        "D",
        fondo_prado()
        + [
            E(34, 70, 8, 6, GRIS, GRIS_OSCURO, 1.8),
            E(66, 64, 14, 11, GRIS, GRIS_OSCURO, 2.0),
            P([(94, 78), (90, 48), (114, 34), (138, 48), (134, 78)], "#475569", TINTA, 2.4),
            *frecha((114, 16), (114, 32), ROJO_OSCURO),
        ],
        "Tres piedras comparadas señalando el peñasco más pesado.",
        None,
    ),
    "heavy": (
        "D",
        fondo_prado()
        + [
            *nino((80, 24), (80, 36), (76, 54), [[(64, 46), (62, 62)], [(96, 46), (98, 62)]], [[(68, 76)], [(88, 76)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            P([(58, 82), (56, 64), (80, 58), (104, 64), (102, 82)], "#475569", TINTA, 2.2),
            E(96, 28, 2.5, 3.5, AGUA, AGUA_OSCURO, 1.2),
        ],
        "Niño intentando levantar una piedra grande y muy pesada.",
        None,
    ),
    "heavy blanket": (
        "D",
        fondo_noite()
        + [
            R(28, 58, 104, 24, 4, MADERA, MADERA_OSCURA, 2.0),
            E(42, 48, 9, 9, PEL, PELB, 1.8),
            R(50, 46, 78, 30, 8, AZUL, AZUL_OSCURO, 2.4),
            L("M66 46 L66 76 M84 46 L84 76 M102 46 L102 76 M50 60 L128 60", "#1e3a8a", 2.0),
        ],
        "Manta acolchada gruesa y pesada cubriendo al niño dormido.",
        None,
    ),
    "heel": (
        "D",
        fondo_sala()
        + [
            P([(56, 22), (76, 22), (76, 58), (112, 66), (112, 76), (56, 76)], PEL, PELB, 2.2),
            E(58, 68, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            *frecha((34, 68), (50, 68), ROJO_OSCURO),
        ],
        "Pie descalzo señalando con un círculo el talón posterior.",
        None,
    ),
    "hello, sailor": (
        "D",
        fondo_mar()
        + [
            *nino_busto(80, 56, (BLANCO, AZUL_OSCURO)),
            P([(62, 66), (80, 74), (98, 66), (92, 62), (80, 68), (68, 62)], AZUL, AZUL_OSCURO, 1.6),
            R(62, 34, 36, 9, 4, BLANCO, AZUL_OSCURO, 1.8),
            L("M64 38 L96 38", AZUL_OSCURO, 2.2),
            L("M96 62 L110 48 L100 40", PELB, 4.8),
            L("M96 62 L110 48 L100 40", PEL, 2.8),
        ],
        "Niño con gorro marinero blanco haciendo el saludo militar.",
        None,
    ),
    "help a friend": (
        "D",
        fondo_prado()
        + [
            *_nino_pie(56, 30, (VERDE, VERDE_OSCURO), 1),
            *nino((104, 50), (104, 60), (100, 74), [[(90, 62), (72, 54)], [(116, 68)]], [[(84, 80)], [(114, 80)]], camisa=(ROJO, ROJO_OSCURO), mira=-1),
            L("M68 52 L88 54", PEL, 3.4),
        ],
        "Niño dando la mano a un amigo sentado para ayudarle a levantarse.",
        None,
    ),
    "helper": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(80, 30, (AZUL, AZUL_OSCURO), 1),
            _estrella(94, 48, 9, 4, DORADO, AMARILLO_OSCURO),
            P([(89, 54), (91, 64), (94, 58), (97, 64), (99, 54)], ROJO, ROJO_OSCURO, 1.3),
        ],
        "Niño ayudante luciendo una medalla de estrella dorada.",
        None,
    ),
    "hen": (
        "D",
        fondo_prado()
        + [
            E(80, 58, 22, 16, BARRO, MADERA_OSCURA, 2.2),
            E(62, 42, 10, 10, BARRO, MADERA_OSCURA, 2.0),
            P([(52, 42), (46, 44), (52, 46)], AMARILLO, AMARILLO_OSCURO, 1.5),
            F("M56 32 Q62 24 68 32", ROJO, ROJO_OSCURO, 2.0),
            E(60, 41, 1.5, 1.5, TINTA),
            F("M74 54 Q88 50 92 62 Q78 66 74 54 Z", MADERA, MADERA_OSCURA, 1.6),
            L("M74 74 L74 84 M86 74 L86 84", NARANJA_OSCURO, 2.2),
        ],
        "Gallina marrón de cuerpo entero con cresta roja en el prado.",
        None,
    ),
    "here comes the aeroplane": (
        "D",
        fondo_mesa()
        + [
            *bebe_sentado(46, 52, (AMARILLO, AMARILLO_OSCURO)),
            E(92, 42, 7, 4, PLATA, GRIS_OSCURO, 1.8),
            L("M99 42 L124 44", GRIS_OSCURO, 2.8),
            P([(102, 36), (112, 24), (116, 42)], AZUL, AZUL_OSCURO, 1.6),
            P([(104, 46), (112, 58), (116, 46)], AZUL, AZUL_OSCURO, 1.6),
            L("M82 42 Q72 34 62 42", AZUL_OSCURO, 2.0),
            P([(62, 42), (68, 38), (68, 46)], AZUL_OSCURO),
        ],
        "Cuchara con alas volando como un avión hacia el bebé.",
        None,
    ),
    "here's your change": (
        "D",
        fondo_mesa()
        + [
            *_mano(44, 34, 0.2),
            *_mano(108, 66, -0.2),
            E(72, 48, 9, 9, DORADO, AMARILLO_OSCURO, 1.8),
            E(86, 56, 8, 8, DORADO, AMARILLO_OSCURO, 1.8),
            *frecha((58, 36), (92, 54), VERDE_OSCURO),
        ],
        "Mano entregando monedas doradas de cambio en otra palma.",
        None,
    ),
    "hero": (
        "D",
        fondo_cielo()
        + [
            P([(62, 44), (36, 76), (124, 76), (98, 44)], ROJO, ROJO_OSCURO, 2.0),
            *nino((80, 28), (80, 40), (80, 56), [[(68, 46), (64, 56), (72, 58)], [(92, 46), (96, 56), (88, 58)]], [[(72, 80)], [(88, 80)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            _estrella(80, 48, 5, 2, AMARILLO, AMARILLO_OSCURO),
        ],
        "Niño con capa roja y manos en la cadera como protagonista.",
        None,
    ),
    "hidden away": (
        "D",
        fondo_sala()
        + [
            E(66, 46, 5, 5, MADERA, MADERA_OSCURA, 1.6),
            E(84, 46, 5, 5, MADERA, MADERA_OSCURA, 1.6),
            F("M34 78 Q56 42 80 46 Q104 42 126 78 Z", MORADO, TINTA, 2.2),
            L("M48 64 L112 64 M56 72 L104 72", ROSA, 2.0),
        ],
        "Peluche escondido bajo una manta morada asomando apenas las orejas.",
        None,
    ),
    "hold on": (
        "D",
        fondo_prado()
        + [
            L("M24 44 L136 44", MADERA_OSCURA, 6.0),
            L("M44 44 L44 82 M116 44 L116 82", MADERA, 4.0),
            *_nino_pie(80, 28, (AZUL, AZUL_OSCURO), 1),
            E(66, 44, 4.5, 4.5, PEL, PELB, 1.6),
            E(94, 44, 4.5, 4.5, PEL, PELB, 1.6),
        ],
        "Niño agarrado firmemente con ambas manos a la barra de madera.",
        None,
    ),
    "hold up": (
        "D",
        fondo_sala()
        + [
            *_nino_pie(74, 34, (VERDE, VERDE_OSCURO), 1),
            L("M86 44 L96 22", PELB, 5.0),
            L("M86 44 L96 22", PEL, 3.0),
            E(96, 18, 7, 7, MADERA_OSCURA, TINTA, 1.8),
            *frecha((116, 44), (116, 18), VERDE_OSCURO),
        ],
        "Mano levantando una castaña en alto para mostrarla bien.",
        None,
    ),
    "hold your breath": (
        "D",
        fondo_sala()
        + [
            E(80, 48, 25, 25, PEL, PELB, 2.2),
            F("M56 36 C58 16 102 16 104 36 C92 28 68 28 56 36 Z", BARRO),
            E(70, 42, 2.2, 2.6, TINTA),
            E(90, 42, 2.2, 2.6, TINTA),
            E(64, 54, 8, 7, "#fca5a5", PELB, 1.8),
            E(96, 54, 8, 7, "#fca5a5", PELB, 1.8),
            L("M74 56 L86 56", TINTA, 2.4),
        ],
        "Cara con los mofletes muy hinchados aguantando el aire dentro.",
        None,
    ),
    "hold your hat": (
        "D",
        fondo_cielo()
        + [
            *lineas_viento(16, 32, 44),
            *nino_busto(86, 58, (NARANJA, NARANJA_OSCURO)),
            E(86, 34, 24, 6, AZUL, AZUL_OSCURO, 1.8),
            F("M70 34 C72 16 100 16 102 34 Z", AZUL, AZUL_OSCURO, 2.0),
            L("M66 56 L62 36 M106 56 L110 36", PELB, 4.6),
            L("M66 56 L62 36 M106 56 L110 36", PEL, 2.8),
            E(62, 35, 3.5, 3.5, PEL, PELB, 1.3),
            E(110, 35, 3.5, 3.5, PEL, PELB, 1.3),
        ],
        "Niño sujetando con las dos manos el ala de su sombrero contra el viento.",
        None,
    ),
    "hollow trunk": (
        "D",
        fondo_prado()
        + [
            P([(52, 84), (56, 16), (104, 16), (108, 84)], MADERA, MADERA_OSCURA, 2.4),
            E(80, 52, 13, 18, "#29180b", TINTA, 2.0),
            L("M62 24 L62 42 M98 26 L98 76", MADERA_OSCURA, 1.8),
        ],
        "Tronco grueso de árbol con un hueco oscuro ovalado en el centro.",
        None,
    ),
    "honeycomb": (
        "D",
        fondo_sala()
        + [
            P([(58, 36), (68, 28), (80, 36), (80, 50), (68, 58), (58, 50)], DORADO, AMARILLO_OSCURO, 2.0),
            P([(80, 36), (92, 28), (102, 36), (102, 50), (92, 58), (80, 50)], AMARILLO, AMARILLO_OSCURO, 2.0),
            P([(69, 54), (80, 46), (91, 54), (91, 68), (80, 76), (69, 68)], DORADO, AMARILLO_OSCURO, 2.0),
            E(118, 28, 5, 4, AMARILLO, TINTA, 1.5),
            E(116, 23, 3, 2, "#e0f2fe"),
        ],
        "Celdas hexagonales doradas de panal con una abejita al lado.",
        None,
    ),
    "honk": (
        "D",
        fondo_sala()
        + [
            E(68, 52, 24, 24, NEGRO, TINTA, 2.4),
            E(68, 52, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            L("M48 52 L60 52 M76 52 L88 52 M68 60 L68 74", GRIS_OSCURO, 2.4),
            L("M100 36 Q110 52 100 68 M112 30 Q124 52 112 74", ROJO_OSCURO, 2.4),
        ],
        "Botón rojo del claxon en un volante emitiendo ondas de bocina.",
        None,
    ),
    "hooded towel": (
        "D",
        fondo_sala()
        + [
            P([(48, 44), (112, 44), (104, 84), (56, 84)], "#bae6fd", AGUA_OSCURO, 2.2),
            P([(56, 44), (80, 18), (104, 44)], "#7dd3fc", AGUA_OSCURO, 2.0),
            E(66, 24, 4, 4, "#bae6fd", AGUA_OSCURO, 1.6),
            E(94, 24, 4, 4, "#bae6fd", AGUA_OSCURO, 1.6),
            E(80, 38, 10, 9, PEL, PELB, 1.8),
        ],
        "Bebé envuelto en toalla azul celeste con capucha de orejitas.",
        None,
    ),
    "hoop tunnel": (
        "D",
        fondo_prado()
        + [
            E(52, 58, 12, 22, None, ROJO, 4.0),
            E(80, 54, 12, 22, None, AMARILLO_OSCURO, 4.0),
            E(108, 50, 12, 22, None, AZUL, 4.0),
            *frecha((24, 58), (134, 50), VERDE_OSCURO),
        ],
        "Tres aros de colores alineados en fila formando un túnel para pasar.",
        None,
    ),
    "hot and sticky": (
        "D",
        fondo_cielo()
        + [
            *_sol(124, 26, 12),
            *nino_busto(66, 56, (NARANJA, NARANJA_OSCURO)),
            E(82, 44, 3, 4.5, AGUA, AGUA_OSCURO, 1.3),
            L("M30 40 L44 36 M30 52 L44 48", ROJO_OSCURO, 2.0),
        ],
        "Niño acalorado sudando bajo un sol intenso de verano.",
        None,
    ),
    "hot water bottle": (
        "D",
        fondo_sala()
        + [
            R(56, 30, 48, 56, 12, ROJO, ROJO_OSCURO, 2.2),
            P([(68, 18), (92, 18), (86, 30), (74, 30)], ROJO, ROJO_OSCURO, 2.0),
            R(72, 14, 16, 6, 2, BLANCO, GRIS_OSCURO, 1.6),
            L("M66 44 L94 44 M66 56 L94 56 M66 68 L94 68", ROJO_OSCURO, 1.8),
        ],
        "Bolsa roja de goma acanalada para agua caliente.",
        None,
    ),
    "hot, hot, hot": (
        "D",
        fondo_mesa()
        + [
            R(54, 44, 44, 34, 6, ROJO, ROJO_OSCURO, 2.2),
            E(98, 60, 7, 9, None, ROJO_OSCURO, 3.0),
            L("M64 36 Q58 26 66 18 M76 36 Q70 26 78 18 M88 36 Q82 26 90 18", NARANJA_OSCURO, 2.2),
            *_mano(124, 38, -0.3),
        ],
        "Taza muy caliente echando vapor con mano abanicándose.",
        None,
    ),
    "howl": (
        "D",
        fondo_noite()
        + [
            F("M124 14 C108 14 104 34 124 38 C112 32 112 18 124 14 Z", AMARILLO, AMARILLO_OSCURO, 1.6),
            P([(44, 80), (74, 80), (66, 52), (48, 56)], GRIS, GRIS_OSCURO, 2.2),
            P([(58, 54), (72, 34), (82, 42), (68, 58)], GRIS, GRIS_OSCURO, 2.0),
            P([(56, 44), (58, 32), (64, 40)], GRIS, GRIS_OSCURO, 1.6),
            L("M86 30 Q98 34 94 44 M94 22 Q110 30 104 46", BLANCO, 2.0),
        ],
        "Lobo sentado mirando arriba a la luna aullando.",
        None,
    ),
    "huge": (
        "D",
        fondo_prado()
        + [
            E(68, 54, 34, 24, GRIS, GRIS_OSCURO, 2.4),
            E(96, 44, 14, 14, GRIS, GRIS_OSCURO, 2.2),
            L("M108 46 Q118 54 112 66", GRIS_OSCURO, 4.5),
            L("M50 74 L50 86 M84 74 L84 86", GRIS_OSCURO, 5.0),
            E(132, 78, 6, 4, TIERRA_CLARA, MADERA_OSCURA, 1.5),
        ],
        "Elefante enorme comparándose junto a un ratón diminuto.",
        None,
    ),
    "hum": (
        "D",
        fondo_sala()
        + [
            *nino_busto(66, 48, (VERDE, VERDE_OSCURO), r=11.0),
            L("M62 52 Q66 54 70 52", TINTA, 2.2),
            *notas_col([(106, 32), (124, 44)], AZUL_OSCURO),
            *notas_col([(114, 58)], MORADO),
        ],
        "Niño con labios cerrados tarareando notas musicales.",
        None,
    ),
    "i help at home by setting the table": (
        "D",
        fondo_mesa()
        + [
            R(24, 52, 112, 30, 4, MADERA, MADERA_OSCURA, 2.0),
            *plato_prop(54, 62, 14),
            *plato_prop(106, 62, 14),
            *cuchara_prop(70, 52, 24),
            *nino_busto(80, 34, (ROSA, ROSA_OSCURO)),
        ],
        "Niño poniendo platos y cucharas sobre la mesa de casa.",
        None,
    ),
    "iceberg": (
        "D",
        fondo_mar()
        + [
            L("M0 54 Q80 48 160 54", BLANCO, 2.2),
            P([(42, 54), (66, 20), (88, 32), (104, 18), (122, 54)], BLANCO, AZUL_OSCURO, 2.2),
            P([(46, 54), (118, 54), (96, 88), (64, 84)], "#7dd3fc", AZUL_OSCURO, 2.0),
        ],
        "Gran iceberg blanco flotando con su base azul sumergida.",
        None,
    ),
    "icicle": (
        "D",
        fondo_cielo("#cbd5e1")
        + [
            R(16, 18, 128, 12, 2, MADERA, MADERA_OSCURA, 2.0),
            P([(34, 30), (50, 30), (42, 68)], "#bae6fd", AZUL_OSCURO, 2.0),
            P([(68, 30), (92, 30), (80, 82)], "#e0f2fe", AZUL_OSCURO, 2.0),
            P([(108, 30), (126, 30), (117, 64)], "#bae6fd", AZUL_OSCURO, 2.0),
        ],
        "Carámbanos puntiagudos de hielo colgando del alero.",
        None,
    ),
    "igloo": (
        "D",
        fondo_cielo()
        + [
            F("M0 74 L160 74 L160 100 L0 100 Z", BLANCO, AZUL_OSCURO, 1.8),
            F("M34 74 C34 26 126 26 126 74 Z", "#f8fafc", AZUL_OSCURO, 2.2),
            L("M42 54 L118 54 M56 38 L104 38 M80 28 L80 54", "#94a3b8", 1.6),
            F("M64 74 L64 56 Q80 44 96 56 L96 74 Z", "#1e3a8a", TINTA, 2.0),
        ],
        "Iglú blanco construido con bloques de nieve sobre suelo helado.",
        None,
    ),
    "in and out": (
        "D",
        fondo_mesa()
        + [
            R(52, 48, 56, 36, 4, MADERA, MADERA_OSCURA, 2.2),
            *pelota_prop(80, 26, 10, ROJO, ROJO_OSCURO),
            *frecha((58, 22), (70, 44), VERDE_OSCURO),
            *frecha((90, 44), (104, 22), AZUL_OSCURO),
        ],
        "Pelota entrando y saliendo de una caja abierta con doble flecha.",
        None,
    ),
    "in order": (
        "D",
        fondo_mesa()
        + [
            R(34, 62, 16, 16, 3, ROJO, ROJO_OSCURO, 1.8),
            R(66, 50, 26, 28, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(104, 34, 34, 44, 3, AZUL, AZUL_OSCURO, 2.0),
            *frecha((32, 24), (128, 24), VERDE_OSCURO),
        ],
        "Tres cubos ordenados en fila creciente de tamaño.",
        None,
    ),
    "in the barn": (
        "D",
        fondo_prado()
        + [
            P([(30, 80), (130, 80), (130, 44), (80, 20), (30, 44)], ROJO, ROJO_OSCURO, 2.2),
            R(60, 48, 40, 32, 2, "#451a03", TINTA, 2.0),
            R(68, 62, 24, 16, 2, "#fde68a", AMARILLO_OSCURO, 1.6),
            L("M30 44 L80 20 L130 44", BLANCO, 3.0),
        ],
        "Establo rojo de granja con las puertas abiertas y heno dentro.",
        None,
    ),
    "in the basket": (
        "D",
        fondo_prado()
        + [
            P([(44, 48), (116, 48), (104, 80), (56, 80)], MADERA, MADERA_OSCURA, 2.2),
            L("M56 48 Q80 18 104 48", MADERA_OSCURA, 3.0),
            *bellota_prop(68, 46),
            *bellota_prop(88, 46),
            *frecha((80, 16), (80, 36), VERDE_OSCURO),
        ],
        "Bellotas entrando dentro de una cesta de mimbre.",
        None,
    ),
    "in the nest": (
        "D",
        fondo_prado()
        + [
            F("M36 52 C36 82 124 82 124 52 Q80 62 36 52 Z", BARRO, MADERA_OSCURA, 2.4),
            E(64, 48, 8, 10, "#bae6fd", AZUL_OSCURO, 1.8),
            E(80, 44, 8, 10, "#bae6fd", AZUL_OSCURO, 1.8),
            E(96, 48, 8, 10, "#bae6fd", AZUL_OSCURO, 1.8),
        ],
        "Tres huevos azules reposando dentro de un nido de ramitas.",
        None,
    ),
    "in the pot": (
        "D",
        fondo_mesa()
        + [
            P([(48, 44), (112, 44), (106, 78), (54, 78)], GRIS, GRIS_OSCURO, 2.2),
            L("M38 50 L48 50 M112 50 L122 50", GRIS_OSCURO, 3.0),
            E(68, 36, 7, 7, ROJO, ROJO_OSCURO, 1.6),
            E(90, 34, 7, 7, VERDE, VERDE_OSCURO, 1.6),
            *frecha((80, 14), (80, 34), VERDE_OSCURO),
        ],
        "Ingredientes cayendo dentro de una olla de cocina.",
        None,
    ),
    "inside the hoop": (
        "D",
        fondo_prado()
        + [
            E(80, 74, 34, 11, None, ROJO, 4.4),
            *_nino_pie(80, 26, (AZUL, AZUL_OSCURO), 1),
        ],
        "Niño de pie justo dentro de un aro rojo posado en el suelo.",
        None,
    ),
    "islands in the sea": (
        "D",
        fondo_mar()
        + [
            F("M18 68 Q34 52 50 68 Z", HERBA, VERDE_OSCURO, 1.8),
            F("M62 56 Q80 38 98 56 Z", HERBA, VERDE_OSCURO, 1.8),
            F("M110 72 Q126 54 142 72 Z", HERBA, VERDE_OSCURO, 1.8),
            L("M78 46 L78 28", MADERA_OSCURA, 2.0),
            E(78, 28, 7, 4, VERDE, VERDE_OSCURO, 1.4),
        ],
        "Varias islas verdes pequeñas repartidas por el mar azul.",
        None,
    ),
    "it's pouring": (
        "D",
        fondo_cielo("#94a3b8")
        + [
            F("M34 34 Q30 16 54 16 Q68 8 88 16 Q114 14 120 32 Q126 44 108 46 L46 46 Q28 46 34 34 Z", GRIS, GRIS_OSCURO, 2.2),
            L("M44 50 L32 76 M62 50 L50 76 M80 50 L68 76 M98 50 L86 76 M116 50 L104 76", AZUL_OSCURO, 2.4),
            E(80, 84, 38, 6, AGUA, AGUA_OSCURO, 1.6),
        ],
        "Nube oscura descargando lluvia torrencial sobre un charco.",
        None,
    ),
    "jingle": (
        "D",
        fondo_sala()
        + [
            E(80, 22, 6, 4, None, AMARILLO_OSCURO, 2.4),
            E(80, 52, 22, 22, DORADO, AMARILLO_OSCURO, 2.4),
            L("M68 48 L92 60 M80 42 L80 66", TINTA, 2.6),
            E(80, 54, 4.5, 4.5, TINTA),
            E(72, 38, 4, 3, "#fef9c3"),
            L("M44 40 Q36 52 44 64 M116 40 Q124 52 116 64", ROJO_OSCURO, 2.4),
        ],
        "Cascabel dorado tintineando con hendidura en cruz y ondas de sonido.",
        None,
    ),
    "joint": (
        "D",
        fondo_sala()
        + [
            L("M42 28 L56 64 L106 54", PELB, 11.0),
            L("M42 28 L56 64 L106 54", PEL, 7.0),
            E(56, 64, 11, 11, None, ROJO, 2.4),
            L("M72 42 Q82 48 80 60", AZUL_OSCURO, 2.0),
        ],
        "Brazo doblado rodeando con un círculo la articulación del codo.",
        None,
    ),
    "juicy": (
        "D",
        fondo_mesa()
        + [
            E(74, 46, 22, 22, NARANJA, NARANJA_OSCURO, 2.2),
            E(92, 50, 14, 16, "#fde047", NARANJA_OSCURO, 2.0),
            L("M86 50 L100 50 M92 40 L92 60", NARANJA_OSCURO, 1.4),
            *gotas([(88, 70), (98, 76), (76, 76)]),
        ],
        "Naranja partida goteando abundante zumo fresco.",
        None,
    ),
    "jump rope": (
        "D",
        fondo_prado()
        + [
            *nino((80, 26), (80, 38), (80, 54), [[(66, 48), (54, 54)], [(94, 48), (106, 54)]], [[(74, 70)], [(86, 70)]], camisa=(ROSA, ROSA_OSCURO), mira=1),
            L("M54 54 Q80 96 106 54", AZUL_OSCURO, 2.6),
            R(49, 48, 6, 10, 2, MADERA, MADERA_OSCURA, 1.5),
            R(105, 48, 6, 10, 2, MADERA, MADERA_OSCURA, 1.5),
        ],
        "Niño saltando en el aire con una comba azul pasando por debajo.",
        None,
    ),
    "jumper": (
        "D",
        fondo_sala()
        + [
            P([(58, 28), (102, 28), (124, 52), (112, 62), (100, 50), (100, 82), (60, 82), (60, 50), (48, 62), (36, 52)], AZUL, AZUL_OSCURO, 2.2),
            L("M60 44 L100 44", AMARILLO, 5.0),
            L("M60 54 L100 54", ROJO, 4.0),
            R(68, 24, 24, 7, 3, AZUL_OSCURO, TINTA, 1.6),
        ],
        "Jersey de punto azul con franjas de colores y cuello redondo.",
        None,
    ),
}

SIN_BASE: dict[str, str] = {
    "crayons in the pot": "Duplicada de `crayon pot` con el mismo gesto (`Meter las ceras en el bote`).",
    "cut! once more, please": "Frase verbal de rodaje cinematográfico; exige texto para distinguirla.",
    "determined": "Rasgo abstracto de carácter (`decidido`); apretar los puños se confunde con enfado.",
    "diligent": "Rasgo abstracto (`trabajador`); secarse la frente parece calor o cansancio.",
    "dive, catch, fly": "Secuencia verbal de tres acciones encadenadas sin escena única clara.",
    "do you remember our first day": "Pregunta conversacional sobre recuerdos sin apoyo visual autónomo.",
    "don't touch, just look": "Consigna verbal negativa (`no toques, solo mira`) sin objeto propio.",
    "empathy": "Valor emocional abstracto (`empatía`); poner la mano en el hombro es ambiguo.",
    "equal weight": "Duplicada conceptual de `equal` (`Mismo peso / Poner las manos iguales`).",
    "even": "Duplicada del gesto de manos a la misma altura (`equal`).",
    "even out": "Duplicada del gesto de igualar los brazos (`equal`).",
    "excited": "Emoción abstracta (`emocionado`); dar saltitos se confunde con saltar o alegría.",
    "fair solution": "Concepto moral/social abstracto (`solución justa`) sin objeto propio.",
    "fairest": "Superlativo abstracto (`el más justo`) sin apoyo visual claro.",
    "fierce": "Adjetivo expresivo abstracto (`feroz`); solapado con león o enfado.",
    "first day": "Referencia temporal abstracta (`primer día`) sin calendario ni texto.",
    "first pyjamas, then teeth, then a story": "Frase secuencial de tres rutinas nocturnas; requiere orden verbal.",
    "first the solo, then the choir": "Secuencia musical temporal (`primero el solo, luego el coro`) sin base visual única.",
    "first we pick, then we sort, then we share": "Frase secuencial de tres verbos; exige leer la progresión.",
    "first we sing, then we get our certificates, and finally we celebrate": "Oración larga de tres fases; requiere texto para seguir el orden.",
    "first-ever": "Superlativo temporal abstracto (`el primero de todos`).",
    "found": "Participio abstracto (`encontrado`) sin objeto específico.",
    "found one": "Exclamación conversacional (`¡Encontré una!`).",
    "fragile": "Propiedad abstracta (`frágil`); coger con cuidado se confunde con sostener.",
    "free": "Estado abstracto (`libre`) sin imagen unívoca sin texto.",
    "fresh": "Adjetivo sensorial abstracto (`fresco`); respirar profundo ya está cubierto.",
    "fruit in a bowl": "Duplicada directa de `fruit bowl` (`Meter fruta en el cuenco`).",
    "frustrated": "Emoción abstracta (`frustrado`); apretar los puños resulta ambiguo.",
    "get dressed": "Duplicada exacta de `dress` (`Vestirse / ponerse ropa`).",
    "give a thumbs up": "Duplicada exacta de `thumbs up` (ya cubierto con Fluent en P2.81).",
    "give away": "Duplicada del gesto de ofrecer/entregar un objeto (`give` / `hand over`).",
    "good deed": "Concepto moral abstracto (`buena acción`) con gesto genérico de pulgar.",
    "good job": "Elogio verbal (`¡Muy bien!`) sin contenido visual propio.",
    "good sport": "Concepto abstracto (`buen deportista`) duplicando el apretón de manos.",
    "graceful": "Adjetivo estético abstracto (`elegante`) sin objeto visual concreto.",
    "great": "Elogio abstracto (`estupendo`) con gesto de dos pulgares.",
    "groovy": "Adjetivo coloquial abstracto (`marchoso`) sin referente visual propio.",
    "grow, grow, grow": "Exclamación repetida duplicada de `grow` y `grow up`.",
    "grown bigger": "Comparativo verbal duplicado de `grow up`.",
    "grown so much": "Exclamación conversacional duplicada de `grow up`.",
    "hand it over": "Frase verbal duplicada de `hand over` y `give`.",
    "handwritten": "Exige mostrar texto escrito a mano; prohibido texto en las láminas.",
    "harmonious": "Adjetivo musical abstracto (`armonioso`) sin imagen unívoca.",
    "harmony": "Concepto abstracto (`armonía`) con gesto genérico de manos.",
    "harvest time": "Exclamación temporal duplicada de `harvest`.",
    "heavy side": "Duplicada comparativa de `heavier` (`Bajar un brazo`).",
    "help others": "Duplicada general de `help a friend` (`Dar la mano a alguien`).",
    "helping hand": "Modismo abstracto duplicado de `help a friend`.",
    "ho, ho, ho": "Onomatopeya verbal navideña sin base autónoma sin texto.",
    "hold it": "Consigna verbal genérica (`Sujetar`) solapada con `hold on`.",
    "hold up one finger for first": "Regla lingüística explícita (`para «primero»`) dependiente del texto.",
    "how does the story begin": "Pregunta narrativa hablada (`¿Cómo empieza la historia?`).",
    "humid": "Adjetivo atmosférico abstracto solapado con `hot and sticky` y `misty`.",
    "i think it will sink": "Oración de hipótesis mental en primera persona sin escena autónoma.",
    "i want to be a baker": "Oración de deseo en primera persona sin base visual unívoca del verbo.",
    "i'm taller now than in september": "Oración comparativa temporal con referencia al mes de septiembre.",
    "identify": "Verbo cognitivo abstracto (`identificar`) sin objeto concreto.",
    "if i take one away, there are four": "Condicional aritmética hablada que requiere números/texto.",
    "if it doesn't work, we try again": "Regla condicional abstracta (`si no funciona, volvemos a probar`).",
    "if you fold it, both halves match": "Regla condicional geométrica dependiente de enunciado verbal.",
    "if you roll a six, go again": "Regla verbal de juego de mesa que exige el número seis y texto.",
    "in the past, people travelled by boat": "Oración histórica en pasado sin marcador visual autónomo del pasado.",
    "it fell down because it was too high": "Explicación causal verbal larga.",
    "it floats because it's light": "Explicación causal verbal sobre flotación.",
    "it goes here": "Frase deíctica verbal (`Va aquí`).",
    "it melts because it's warm": "Explicación causal verbal sobre derretimiento.",
    "it's a deal": "Expresión idiomática hablada (`¡Trato hecho!`), solapada con `agreement`.",
    "it's a draw": "Frase verbal de resultado (`¡Empate!`) sin objeto único.",
}
