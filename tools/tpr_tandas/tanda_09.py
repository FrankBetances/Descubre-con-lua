#!/usr/bin/env python3
"""Tanda 9 TPR (P2.90): cierre completo de mover (`move`) y primer bloque de `present_object`.

Cubre 200 piezas revisadas + 57 auditadas sin base (`SIN_BASE`):
- Cierre completo de `move` (`match both sides`..`zoom`: 54 cubiertas + 14 `SIN_BASE`).
- Primer bloque de `present_object` (`a slice for each`..`crane`: 146 cubiertas + 43 `SIN_BASE`).

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas, conversacionales o sin base visual clara quedan en `SIN_BASE`.
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
    semilla_prop,
)

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "swim": ("Person swimming", "U", "Persona nadando en el agua con los brazos."),
    "act": ("Performing arts", "U", "Máscaras teatrales para actuar un personaje."),
    "agreement": ("Handshake", "U", "Dos manos dándose la mano en señal de acuerdo."),
    "busy city": ("Cityscape", "U", "Ciudad con edificios iluminados y actividad."),
    "cable car": ("Mountain cableway", "U", "Cabina de teleférico subiendo por la montaña."),
    "car": ("Automobile", "R", "Coche rojo de perfil sobre el camino."),
    "clapping": ("Clapping hands", "U", "Manos dando palmas con ondas."),
    "construction site": ("Construction", "R", "Señal de obras con valla amarilla y negra."),
    "corn": ("Ear of corn", "R", "Mazorca de maíz dorada con hojas."),
}

DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _sol(cx: float, cy: float, r: float = 11) -> list[dict]:
    o = [E(cx, cy, r, r, AMARILLO, AMARILLO_OSCURO, 1.8)]
    for i in range(8):
        ang = math.radians(i * 45)
        x1 = cx + (r + 3) * math.cos(ang)
        y1 = cy + (r + 3) * math.sin(ang)
        x2 = cx + (r + 7) * math.cos(ang)
        y2 = cy + (r + 7) * math.sin(ang)
        o.append(L(f"M{x1:.1f} {y1:.1f} L{x2:.1f} {y2:.1f}", AMARILLO_OSCURO, 2.0))
    return o


def _estrella(cx: float, cy: float, r_ext: float, r_int: float, col: str = AMARILLO, borde: str = AMARILLO_OSCURO) -> dict:
    pts = []
    for i in range(10):
        ang = math.radians(-90 + i * 36)
        r = r_ext if i % 2 == 0 else r_int
        pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return P(pts, col, borde, 1.5)


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
    """Palma estilizada con pulgar y dedos abiertos para gestos claros."""
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


# ── Escenas propias Lúa (D) y compuestas (C) ───────────────────────────────
ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = {
    # ══════ CIERRE DE MOVER (`move`) ══════
    "match both sides": (
        "D",
        fondo_sala()
        + [
            L("M80 12 L80 86", GRIS_OSCURO, 2.0),
            R(28, 34, 24, 24, 5, AZUL, AZUL_OSCURO, 2.0),
            R(108, 34, 24, 24, 5, AZUL, AZUL_OSCURO, 2.0),
            E(40, 46, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            E(120, 46, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            *frecha((56, 46), (74, 46), VERDE_OSCURO),
            *frecha((104, 46), (86, 46), VERDE_OSCURO),
        ],
        "Eje de simetría con piezas idénticas igualadas a ambos lados.",
        None,
    ),
    "messy": (
        "D",
        fondo_sala()
        + [
            R(24, 56, 36, 22, 3, MADERA, MADERA_OSCURA, 1.8),
            P([(30, 38), (58, 30), (62, 46), (34, 54)], ROJO, ROJO_OSCURO, 1.8),
            P([(74, 62), (96, 52), (104, 68), (82, 78)], AZUL, AZUL_OSCURO, 1.8),
            E(118, 72, 10, 8, AMARILLO, AMARILLO_OSCURO, 1.8),
            L("M66 28 L86 22 M96 38 L120 34 M42 74 L62 82", VERDE_OSCURO, 3.0),
            F("M122 50 C130 44 138 56 128 60 C120 62 116 54 122 50 Z", BLANCO, GRIS_OSCURO, 1.6),
        ],
        "Juguetes, papeles y ceras esparcidos y torcidos en desorden.",
        None,
    ),
    "metronome": (
        "D",
        fondo_mesa()
        + [
            P([(54, 80), (106, 80), (88, 16), (72, 16)], MADERA, MADERA_OSCURA, 2.2),
            P([(62, 74), (98, 74), (86, 28), (74, 28)], "#fef3c7", MADERA_OSCURA, 1.4),
            L("M80 74 L106 24", TINTA, 3.2),
            R(92, 34, 12, 9, 2, DORADO, AMARILLO_OSCURO, 1.6),
            L("M56 26 Q80 14 104 26", AZUL_OSCURO, 2.0),
            P([(54, 24), (58, 30), (50, 29)], AZUL_OSCURO),
            P([(106, 24), (102, 30), (110, 29)], AZUL_OSCURO),
        ],
        "Metrónomo de madera con varilla oscilando rítmicamente de lado a lado.",
        None,
    ),
    "misty": (
        "D",
        fondo_cielo("#cbd5e1")
        + [
            F("M0 64 Q42 40 86 58 Q126 38 160 56 L160 100 L0 100 Z", VERDE, VERDE_OSCURO, 1.8),
            R(14, 34, 132, 12, 6, "#f8fafc", "#94a3b8", 1.5),
            R(28, 52, 114, 13, 6, "#f1f5f9", "#94a3b8", 1.5),
            R(10, 70, 124, 12, 6, "#e2e8f0", "#94a3b8", 1.5),
        ],
        "Bandas densas de bruma flotando sobre las colinas verdes.",
        None,
    ),
    "mix": (
        "D",
        fondo_mesa()
        + [
            F("M44 52 C44 82 116 82 116 52 Z", AZUL, AZUL_OSCURO, 2.2),
            E(80, 52, 36, 9, "#fde68a", AMARILLO_OSCURO, 2.0),
            L("M86 52 L110 20", MADERA_OSCURA, 4.5),
            L("M86 52 L110 20", MADERA, 2.5),
            L("M62 34 Q80 22 98 34", ROJO, 2.2),
            P([(98, 34), (91, 30), (93, 38)], ROJO),
        ],
        "Cuenco con masa y cuchara removiendo en círculo para mezclar.",
        None,
    ),
    "mix colours": (
        "D",
        fondo_mesa()
        + [
            E(62, 50, 24, 18, AZUL, AZUL_OSCURO, 1.8),
            E(96, 50, 24, 18, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(79, 52, 14, 15, VERDE, VERDE_OSCURO, 1.8),
            L("M79 52 L114 22", MADERA_OSCURA, 3.6),
            E(79, 52, 4, 4, VERDE_OSCURO),
            L("M68 28 Q80 20 92 28", ROJO, 2.0),
        ],
        "Pintura azul y amarilla mezclándose en el centro en verde brillante.",
        None,
    ),
    "moonlight": (
        "D",
        fondo_noite()
        + [
            P([(106, 40), (36, 86), (92, 86), (120, 44)], "#475569"),
            F("M122 14 C102 14 96 42 122 46 C108 40 108 20 122 14 Z", "#fef08a", AMARILLO_OSCURO, 1.8),
            L("M96 46 L52 74 M106 50 L72 76 M114 52 L92 76", "#fde047", 1.8),
            F("M0 78 Q50 68 100 76 Q135 82 160 74 L160 100 L0 100 Z", "#334155"),
            _estrella(36, 22, 5, 2),
            _estrella(66, 18, 4, 1.6),
        ],
        "Media luna nocturna bañando las colinas con un haz de luz pálida.",
        None,
    ),
    "move like a robot": (
        "D",
        fondo_sala()
        + nino((80, 24), (80, 36), (80, 56), [[(62, 40), (62, 24)], [(98, 40), (98, 54)]], [[(72, 78)], [(88, 78)]], camisa=(VERDE, VERDE_OSCURO))
        + [
            R(24, 44, 20, 20, 3, GRIS, GRIS_OSCURO, 1.8),
            R(28, 30, 12, 12, 2, PLATA, GRIS_OSCURO, 1.8),
            E(32, 36, 1.8, 1.8, ROJO),
            E(36, 36, 1.8, 1.8, ROJO),
            L("M34 30 L34 22", GRIS_OSCURO, 2.0),
            E(34, 21, 2.5, 2.5, AMARILLO, AMARILLO_OSCURO, 1.4),
        ],
        "Niño moviendo brazos rígidos en ángulo recto como un robot de juguete.",
        None,
    ),
    "musical": (
        "D",
        fondo_sala()
        + nino((72, 28), (72, 40), (72, 58), [[(56, 30)], [(90, 28)]], [[(64, 78)], [(84, 74)]], camisa=(MORADO, "#5b21b6"))
        + notas_col([(34, 34), (114, 28), (126, 46)], ROJO)
        + [E(124, 74, 12, 7, NARANJA, NARANJA_OSCURO, 1.8), R(112, 66, 24, 10, 2, AMARILLO, NARANJA_OSCURO, 1.8)],
        "Niño bailando con notas musicales coloridas y tambor.",
        None,
    ),
    "neck": (
        "D",
        fondo_cielo("#f1f5f9")
        + [
            R(44, 68, 72, 32, 12, AZUL, AZUL_OSCURO, 2.0),
            R(70, 48, 20, 24, 4, PEL, PELB, 2.2),
            E(80, 32, 20, 19, PEL, PELB, 2.2),
            F("M60 30 C62 10 98 10 100 30 C92 18 68 18 60 30 Z", BARRO),
            E(73, 33, 2, 2.5, TINTA),
            E(87, 33, 2, 2.5, TINTA),
            L("M74 42 Q80 46 86 42", "#9a3412", 1.8),
            *frecha((54, 58), (68, 58), ROJO),
            *frecha((106, 58), (92, 58), ROJO),
        ],
        "Primer plano de cabeza y hombros destacando el cuello al moverlo.",
        None,
    ),
    "oar": (
        "D",
        fondo_mar()
        + [
            L("M44 16 L102 68", MADERA_OSCURA, 5.2),
            L("M44 16 L102 68", MADERA, 3.0),
            P([(94, 60), (118, 74), (110, 84), (86, 68)], TIERRA_CLARA, MADERA_OSCURA, 2.0),
            L("M82 68 Q104 60 128 68", BLANCO, 2.0),
            *frecha((40, 44), (66, 56), AZUL_OSCURO),
        ],
        "Remo de madera hundiéndose en el agua con salpicaduras al remar.",
        None,
    ),
    "parrot feather": (
        "D",
        fondo_cielo("#ecfeff")
        + [
            F("M40 76 C48 42 84 18 118 22 C110 54 78 72 40 76 Z", ROJO, ROJO_OSCURO, 1.8),
            F("M54 66 C64 46 90 28 114 26 C100 46 80 60 54 66 Z", AMARILLO),
            F("M72 54 C84 42 100 32 114 26 C102 42 90 50 72 54 Z", AZUL),
            L("M30 84 Q76 50 122 20", MADERA_OSCURA, 2.0),
            L("M46 30 Q62 18 80 22", AGUA_OSCURO, 1.8),
        ],
        "Pluma tricolor brillante de loro flotando suavemente en el aire.",
        None,
    ),
    "pointer": (
        "D",
        fondo_mesa()
        + [
            E(80, 50, 34, 34, BLANCO, GRIS_OSCURO, 2.4),
            E(80, 50, 28, 28, "#f8fafc", GRIS, 1.4),
            *[
                E(80 + 23 * math.cos(math.radians(a)), 50 + 23 * math.sin(math.radians(a)), 1.8, 1.8, TINTA)
                for a in range(0, 360, 45)
            ],
            L("M80 50 L102 32", ROJO, 4.0),
            P([(105, 29), (96, 31), (102, 38)], ROJO_OSCURO),
            E(80, 50, 4, 4, TINTA),
            L("M96 20 Q112 30 112 46", AZUL_OSCURO, 2.0),
        ],
        "Esfera con aguja roja destacada girando como puntero.",
        None,
    ),
    "pull the strings": (
        "D",
        fondo_sala()
        + [
            R(44, 16, 72, 7, 3, MADERA, MADERA_OSCURA, 1.8),
            L("M56 23 L56 54 M80 23 L80 46 M104 23 L104 54", GRIS_OSCURO, 1.6),
            E(80, 46, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            E(56, 56, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(104, 56, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.6),
            R(72, 54, 16, 18, 4, AZUL, AZUL_OSCURO, 1.8),
            *frecha((42, 36), (42, 20), ROJO),
            *frecha((118, 36), (118, 20), ROJO),
        ],
        "Cruz de madera arriba tirando de los hilos verticales de un títere.",
        None,
    ),
    "puppeteer": (
        "D",
        fondo_sala()
        + [
            R(28, 16, 20, 14, 4, MORADO, "#5b21b6", 1.8),
            E(38, 12, 7, 7, PEL, PELB, 1.6),
            L("M48 22 L92 22", MADERA_OSCURA, 3.0),
            L("M74 22 L74 54 M92 22 L92 60", GRIS_OSCURO, 1.5),
            E(83, 52, 8, 8, PEL, PELB, 1.8),
            R(75, 60, 16, 18, 4, NARANJA, NARANJA_OSCURO, 1.8),
            L("M75 62 L66 56 M91 62 L100 56", PELB, 2.4),
        ],
        "Titiritero manejando desde arriba con cruceta e hilos a una marioneta.",
        None,
    ),
    "put out a fire": (
        "D",
        fondo_prado()
        + [
            F("M104 74 C98 54 114 40 116 26 C126 38 136 56 128 74 Z", NARANJA, ROJO_OSCURO, 1.8),
            F("M110 74 C108 58 118 50 118 42 C124 50 126 60 122 74 Z", AMARILLO),
            L("M22 68 Q46 58 60 54", ROJO, 5.0),
            R(56, 48, 14, 9, 2, PLATA, GRIS_OSCURO, 1.6),
            L("M72 50 Q90 42 104 46", AGUA, 3.2),
            L("M72 54 Q88 52 102 58", AGUA_OSCURO, 2.4),
            *gotas([(92, 36), (98, 48), (104, 60)]),
        ],
        "Manguera proyectando agua a presión sobre llamas de fuego para apagarlas.",
        None,
    ),
    "rainbow-coloured": (
        "D",
        fondo_cielo()
        + [
            L("M24 72 Q52 24 88 52 Q116 74 138 24", ROJO, 6.0),
            L("M24 76 Q52 28 88 56 Q116 78 138 28", NARANJA, 5.0),
            L("M24 80 Q52 32 88 60 Q116 82 138 32", AMARILLO, 5.0),
            L("M24 84 Q52 36 88 64 Q116 86 138 36", VERDE, 5.0),
            L("M24 88 Q52 40 88 68 Q116 90 138 40", AZUL, 5.0),
            L("M24 92 Q52 44 88 72 Q116 94 138 44", MORADO, 4.5),
        ],
        "Cinta ondulante con franjas de los seis colores del arcoíris.",
        None,
    ),
    "rustle": (
        "D",
        fondo_prado()
        + [
            E(56, 68, 13, 8, NARANJA, BARRO, 1.8),
            E(82, 72, 14, 9, TIERRA_CLARA, BARRO, 1.8),
            E(104, 66, 12, 8, ROJO, ROJO_OSCURO, 1.8),
            L("M44 46 Q52 38 60 46 M96 44 Q104 36 112 44", AMARILLO_OSCURO, 2.0),
            L("M50 38 Q62 28 74 38 M90 36 Q102 26 114 36", NARANJA_OSCURO, 1.8),
        ],
        "Hojas secas crujiendo con ondas sonoras al moverlas.",
        None,
    ),
    "sift": (
        "D",
        fondo_mesa()
        + [
            R(48, 28, 64, 18, 4, PLATA, GRIS_OSCURO, 2.0),
            L("M112 36 L136 36", GRIS_OSCURO, 4.0),
            L("M52 46 L108 46", GRIS_OSCURO, 2.2),
            *[E(56 + i * 8, 55 + (i % 2) * 6, 1.8, 1.8, "#fef08a", AMARILLO_OSCURO, 1.0) for i in range(7)],
            *[E(60 + i * 8, 64 + (i % 2) * 5, 1.8, 1.8, "#fef08a", AMARILLO_OSCURO, 1.0) for i in range(6)],
            F("M44 68 C44 88 116 88 116 68 Z", ROJO, ROJO_OSCURO, 2.0),
        ],
        "Colador tamizando lluvia fina de harina sobre un cuenco rojo.",
        None,
    ),
    "slippery": (
        "D",
        fondo_sala()
        + [
            E(80, 78, 42, 9, AGUA, AGUA_OSCURO, 2.0),
            *nino((80, 26), (76, 38), (74, 56), [[(56, 30)], [(102, 34)]], [[(60, 74)], [(98, 72)]], camisa=(AMARILLO, AMARILLO_OSCURO)),
            L("M44 74 L58 74 M102 74 L118 74", AZUL_OSCURO, 2.2),
        ],
        "Niño resbalando sobre un charco brillante manteniendo el equilibrio.",
        None,
    ),
    "soapy": (
        "D",
        fondo_cielo("#e0f2fe")
        + [
            E(64, 54, 18, 14, PEL, PELB, 2.0),
            E(96, 54, 18, 14, PEL, PELB, 2.0),
            E(72, 46, 10, 9, BLANCO, AGUA_OSCURO, 1.6),
            E(86, 44, 11, 10, BLANCO, AGUA_OSCURO, 1.6),
            E(79, 56, 12, 9, BLANCO, AGUA_OSCURO, 1.6),
            *pompas([(52, 28, 6), (80, 22, 8), (108, 28, 5), (120, 44, 4)]),
        ],
        "Manos cubiertas de espuma jabonosa blanca y pompas flotando.",
        None,
    ),
    "song": (
        "D",
        fondo_sala()
        + nino((80, 30), (80, 42), (80, 60), [[(58, 36)], [(102, 34)]], [[(74, 80)], [(86, 80)]], camisa=(ROSA, ROSA_OSCURO))
        + notas_col([(38, 28), (52, 20), (108, 22), (122, 32)], AZUL_OSCURO),
        "Niño moviendo las manos dirigiendo una canción rodeado de notas.",
        None,
    ),
    "sprinkle spice": (
        "D",
        fondo_mesa()
        + [
            R(66, 16, 28, 24, 5, MADERA, MADERA_OSCURA, 2.0),
            R(64, 36, 32, 6, 2, PLATA, GRIS_OSCURO, 1.6),
            *[E(64 + i * 6, 48 + (i % 3) * 5, 1.8, 1.8, NARANJA_OSCURO) for i in range(6)],
            *[E(66 + i * 6, 62 + (i % 2) * 4, 1.8, 1.8, ROJO_OSCURO) for i in range(5)],
            *plato_prop(80, 74, 24),
        ],
        "Bote especiero espolvoreando granitos dorados sobre un plato.",
        None,
    ),
    "stamp": (
        "D",
        fondo_sala()
        + nino((78, 22), (78, 34), (78, 54), [[(64, 46)], [(92, 46)]], [[(72, 76)], [(92, 66), (92, 78)]], camisa=(ROJO, ROJO_OSCURO))
        + [
            L("M82 80 L68 84 M102 80 L116 84 M92 82 L92 89", ROJO_OSCURO, 2.2),
            *frecha((104, 56), (104, 72), AZUL_OSCURO),
        ],
        "Niño pisoteando fuerte con el pie contra el suelo con líneas de impacto.",
        None,
    ),
    "stir, then taste": (
        "D",
        fondo_mesa()
        + [
            F("M22 52 C22 76 68 76 68 52 Z", AZUL, AZUL_OSCURO, 2.0),
            L("M46 52 L58 26", MADERA_OSCURA, 3.2),
            L("M34 38 Q46 30 56 38", ROJO, 2.0),
            *frecha((72, 54), (92, 54), VERDE_OSCURO),
            *nino_busto(120, 38, camisa=(ROJO, ROJO_OSCURO), mira=-1),
            *cuchara_prop(98, 42, 22),
        ],
        "Secuencia de remover en el cuenco y luego probar con la cuchara.",
        None,
    ),
    "storm": (
        "D",
        fondo_cielo("#94a3b8")
        + [
            E(64, 28, 20, 14, GRIS_OSCURO, NEGRO, 1.8),
            E(92, 30, 22, 15, GRIS_OSCURO, NEGRO, 1.8),
            E(78, 22, 22, 16, "#64748b", NEGRO, 1.8),
            P([(78, 36), (68, 56), (78, 56), (70, 76), (92, 50), (80, 50)], AMARILLO, AMARILLO_OSCURO, 1.6),
            L("M44 46 L36 68 M104 46 L96 68 M118 46 L110 68", AZUL_OSCURO, 2.2),
        ],
        "Nube oscura de tormenta con rayo amarillo y lluvia intensa.",
        None,
    ),
    "strings": (
        "D",
        fondo_sala()
        + [
            R(28, 18, 104, 8, 3, MADERA, MADERA_OSCURA, 2.0),
            L("M44 26 Q38 50 46 78", ROJO, 2.4),
            L("M68 26 Q74 52 66 78", AZUL, 2.4),
            L("M92 26 Q86 50 94 78", VERDE, 2.4),
            L("M116 26 Q122 52 114 78", MORADO, 2.4),
        ],
        "Hilos largos de colores colgando y ondulando suavemente.",
        None,
    ),
    "swaying": (
        "D",
        fondo_prado()
        + [
            L("M50 74 Q42 50 38 30", VERDE_OSCURO, 3.6),
            L("M80 74 Q70 46 66 24", VERDE, 3.8),
            L("M110 74 Q100 50 96 32", VERDE_OSCURO, 3.6),
            L("M58 22 Q80 14 102 22", AZUL_OSCURO, 2.2),
            P([(56, 20), (62, 26), (54, 26)], AZUL_OSCURO),
            P([(104, 20), (98, 26), (106, 26)], AZUL_OSCURO),
        ],
        "Tallos altos balanceándose de un lado a otro con flechas de vaivén.",
        None,
    ),
    "swim along": (
        "D",
        fondo_mar()
        + [
            E(50, 56, 10, 7, PEL, PELB, 1.8),
            R(58, 54, 24, 10, 4, NARANJA, NARANJA_OSCURO, 1.8),
            L("M58 58 L42 66", PELB, 3.0),
            E(110, 72, 11, 6, AMARILLO, AMARILLO_OSCURO, 1.6),
            P([(120, 72), (128, 66), (128, 78)], AMARILLO, AMARILLO_OSCURO, 1.6),
            E(105, 71, 1.4, 1.4, TINTA),
            L("M24 62 Q40 56 54 62 M86 64 Q100 58 114 64", BLANCO, 1.8),
        ],
        "Niño nadando junto a un pececito en el agua.",
        None,
    ),
    "swirl": (
        "D",
        fondo_cielo("#e0f2fe")
        + [
            L(
                "M80 50 C88 42 98 52 90 62 C78 74 58 64 60 46 C64 22 98 18 112 40 C124 62 104 86 76 86 C48 86 34 62 40 36",
                AZUL_OSCURO,
                3.4,
            ),
            P([(38, 34), (46, 36), (40, 42)], ROJO),
        ],
        "Espiral amplia con flecha girando en remolino.",
        None,
    ),
    "swishing": (
        "D",
        fondo_prado()
        + [
            F("M44 58 C54 32 92 28 116 48 C102 64 74 68 44 58 Z", NARANJA, NARANJA_OSCURO, 2.0),
            F("M96 40 C104 38 112 42 116 48 C108 54 100 54 94 50 Z", BLANCO),
            L("M60 22 Q86 14 114 24", AZUL_OSCURO, 2.2),
            P([(58, 20), (64, 26), (56, 26)], AZUL_OSCURO),
            P([(116, 22), (110, 28), (118, 28)], AZUL_OSCURO),
        ],
        "Cola esponjosa ondulando de lado a lado con arco de movimiento.",
        None,
    ),
    "tail": (
        "D",
        fondo_prado()
        + [
            R(26, 40, 46, 30, 12, TIERRA_CLARA, BARRO, 2.0),
            F("M70 50 C96 36 122 36 128 24 C132 42 112 64 70 60 Z", TIERRA_CLARA, BARRO, 2.2),
            L("M112 18 Q128 22 134 38", ROJO, 2.2),
        ],
        "Parte trasera de animal destacando la cola larga que se mueve.",
        None,
    ),
    "tail fin": (
        "D",
        fondo_mar()
        + [
            F("M56 76 C64 56 72 48 80 42 C64 34 46 22 44 16 C64 20 76 30 82 36 C88 30 100 20 120 16 C118 22 100 34 84 42 C92 48 100 56 108 76 Z", AZUL, AZUL_OSCURO, 2.2),
            L("M34 74 Q80 68 126 74", BLANCO, 2.2),
            *gotas([(46, 52), (114, 52)]),
        ],
        "Aleta caudal en forma de V saliendo sobre la superficie del mar.",
        None,
    ),
    "the tram is faster than the bus": (
        "D",
        fondo_cielo()
        + [
            R(0, 68, 160, 32, 0, GRIS, GRIS_OSCURO, 1.5),
            R(16, 42, 42, 26, 5, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(26, 70, 5, 5, NEGRO),
            E(48, 70, 5, 5, NEGRO),
            R(86, 36, 56, 28, 5, VERDE, VERDE_OSCURO, 2.0),
            L("M114 36 L114 20 M104 20 L124 20", GRIS_OSCURO, 2.2),
            L("M72 46 L82 46 M68 54 L82 54", ROJO, 2.5),
        ],
        "Tranvía verde adelantando con estelas de velocidad al autobús amarillo.",
        None,
    ),
    "tick, tock": (
        "D",
        fondo_sala()
        + [
            R(60, 14, 40, 34, 6, MADERA, MADERA_OSCURA, 2.2),
            E(80, 31, 12, 12, BLANCO, GRIS_OSCURO, 1.6),
            L("M80 31 L80 23 M80 31 L86 31", TINTA, 2.0),
            L("M80 48 L96 76", AMARILLO_OSCURO, 2.8),
            E(96, 78, 6, 6, DORADO, AMARILLO_OSCURO, 1.8),
            L("M60 76 Q80 86 100 76", AZUL_OSCURO, 2.0),
        ],
        "Reloj de péndulo oscilando en arco rítmico de un lado a otro.",
        None,
    ),
    "trickling": (
        "D",
        fondo_prado()
        + [
            F("M30 74 C32 42 54 32 76 34 C96 36 108 54 110 74 Z", GRIS, GRIS_OSCURO, 2.0),
            L("M76 34 Q82 46 78 56 Q74 66 80 74", AGUA, 3.0),
            *gotas([(80, 62), (82, 74)]),
            E(80, 82, 20, 5, AGUA, AGUA_OSCURO, 1.6),
        ],
        "Hilo fino de agua goteando suavemente por la roca hacia el charco.",
        None,
    ),
    "tropical": (
        "D",
        fondo_cielo("#cffafe")
        + [
            R(0, 74, 160, 26, 0, "#fde68a"),
            L("M48 76 Q44 48 56 28", MADERA_OSCURA, 4.5),
            F("M56 28 Q34 20 24 34 Q42 32 56 28 Z", VERDE, VERDE_OSCURO, 1.6),
            F("M56 28 Q78 20 88 34 Q70 32 56 28 Z", VERDE, VERDE_OSCURO, 1.6),
            F("M56 28 Q54 10 38 14 Q48 22 56 28 Z", HERBA, VERDE_OSCURO, 1.6),
            E(110, 56, 11, 11, ROSA, ROSA_OSCURO, 1.8),
            E(110, 56, 4, 4, AMARILLO),
            *_sol(128, 22, 9),
        ],
        "Palmera tropical con hojas amplias, flor de hibisco y sol cálido.",
        None,
    ),
    "twinkly": (
        "D",
        fondo_noite()
        + [
            _estrella(38, 28, 9, 3.5),
            _estrella(80, 24, 12, 4.5, "#fef08a", DORADO),
            _estrella(122, 34, 8, 3.0),
            _estrella(56, 56, 7, 2.8, BLANCO, GRIS),
            _estrella(106, 58, 10, 3.8),
        ],
        "Cielo nocturno lleno de estrellas titilantes de varios tamaños.",
        None,
    ),
    "wag": (
        "D",
        fondo_prado()
        + [
            R(44, 44, 46, 26, 10, MADERA, MADERA_OSCURA, 2.0),
            E(42, 38, 11, 10, MADERA, MADERA_OSCURA, 2.0),
            E(34, 40, 4, 7, BARRO),
            L("M90 50 Q112 36 118 24", MADERA_OSCURA, 4.5),
            L("M106 20 Q122 24 126 40", ROJO, 2.2),
            P([(104, 18), (110, 23), (102, 24)], ROJO),
        ],
        "Perrito contento moviendo la cola de lado a lado con arco de meneo.",
        None,
    ),
    "warm up your body": (
        "D",
        fondo_sala()
        + [
            R(42, 76, 76, 7, 3, AZUL, AZUL_OSCURO, 1.8),
            *nino((80, 22), (80, 34), (80, 52), [[(60, 18)], [(100, 18)]], [[(68, 74)], [(92, 74)]], camisa=(NARANJA, NARANJA_OSCURO)),
            L("M50 22 Q56 12 64 14 M110 22 Q104 12 96 14", ROJO, 2.0),
        ],
        "Niño sobre esterilla estirando brazos arriba para calentar el cuerpo.",
        None,
    ),
    "water always flows downhill": (
        "D",
        fondo_cielo()
        + [
            P([(0, 24), (72, 24), (160, 78), (160, 100), (0, 100)], HERBA, VERDE_OSCURO, 2.0),
            F("M34 24 Q64 40 90 58 Q116 74 160 80 L160 94 Q110 88 82 68 Q56 48 22 24 Z", AGUA, AGUA_OSCURO, 1.8),
            *frecha((50, 28), (104, 58), AZUL_OSCURO),
        ],
        "Agua fluyendo cuesta abajo por la ladera verde con flecha descendente.",
        None,
    ),
    "wave fingers": (
        "D",
        fondo_cielo("#f0f9ff")
        + _mano(80, 56, 0.2)
        + [
            L("M56 26 Q80 18 104 26", AZUL_OSCURO, 2.2),
            P([(54, 24), (60, 30), (52, 30)], AZUL_OSCURO),
            P([(106, 24), (100, 30), (108, 30)], AZUL_OSCURO),
        ],
        "Mano abierta moviendo los dedos suavemente de lado a lado.",
        None,
    ),
    "whoosh": (
        "D",
        fondo_cielo("#e0f2fe")
        + [
            L("M16 56 Q58 24 102 42 Q128 52 144 30", AGUA_OSCURO, 3.6),
            L("M22 68 Q62 42 108 58 Q128 64 140 50", AZUL, 2.6),
            P([(146, 28), (136, 30), (142, 38)], AZUL_OSCURO),
            E(66, 28, 7, 4, VERDE, VERDE_OSCURO, 1.4),
            E(112, 62, 6, 3.5, NARANJA, NARANJA_OSCURO, 1.4),
        ],
        "Ráfaga rápida de viento barriendo hojas en curva ascendente.",
        None,
    ),
    "wiggle your fingers": (
        "D",
        fondo_sala()
        + _mano(54, 56, -0.3)
        + _mano(106, 56, 0.3)
        + [
            L("M38 30 Q44 24 50 30 M58 26 Q64 20 70 26", ROJO, 2.0),
            L("M90 26 Q96 20 102 26 M110 30 Q116 24 122 30", ROJO, 2.0),
        ],
        "Dos manos moviendo rápidamente las puntas de los dedos.",
        None,
    ),
    "wild wind": (
        "D",
        fondo_prado()
        + [
            L("M106 74 Q94 54 88 36", MADERA_OSCURA, 5.0),
            E(82, 30, 24, 15, VERDE, VERDE_OSCURO, 2.0),
            *lineas_viento(18, 28, 38, AZUL_OSCURO),
            *lineas_viento(14, 50, 44, MAR_PROF),
            E(122, 38, 6, 3.5, NARANJA, BARRO, 1.4),
            E(136, 54, 5, 3, TIERRA_CLARA, BARRO, 1.4),
        ],
        "Viento fuerte en ráfagas doblando un árbol y arrastrando hojas.",
        None,
    ),
    "wind": (
        "D",
        fondo_cielo()
        + [
            *lineas_viento(22, 36, 46, AGUA_OSCURO),
            *lineas_viento(28, 56, 52, AZUL),
            E(104, 34, 8, 5, BLANCO, GRIS_OSCURO, 1.4),
            L("M96 38 C108 38 114 26 106 24 C98 22 98 30 104 32", AGUA_OSCURO, 2.4),
            L("M106 60 C118 60 124 70 116 74 C108 76 108 68 114 66", AZUL_OSCURO, 2.4),
        ],
        "Brisa de aire dibujada en rizos de viento surcando el cielo.",
        None,
    ),
    "wipers": (
        "D",
        fondo_cielo("#cbd5e1")
        + [
            P([(24, 72), (38, 24), (122, 24), (136, 72)], "#e0f2fe", GRIS_OSCURO, 2.6),
            L("M56 72 L40 34", NEGRO, 3.4),
            L("M104 72 L88 34", NEGRO, 3.4),
            L("M36 30 Q54 24 72 32 M84 30 Q102 24 120 32", AGUA_OSCURO, 2.0),
        ],
        "Parabrisas con dos limpiaparabrisas barriendo en arco las gotas.",
        None,
    ),
    "wizard": (
        "D",
        fondo_noite()
        + [
            E(72, 64, 34, 10, AZUL_OSCURO, MORADO, 2.0),
            P([(48, 64), (72, 16), (96, 64)], AZUL, MORADO, 2.0),
            _estrella(72, 42, 7, 2.8),
            L("M100 66 L128 38", MADERA, 3.2),
            _estrella(130, 34, 8, 3.2, "#fef08a", AMARILLO_OSCURO),
        ],
        "Sombrero azul estrellado de mago junto a varita mágica brillante.",
        None,
    ),
    "wobbly bubble": (
        "D",
        fondo_cielo("#e0f2fe")
        + [
            E(80, 50, 26, 19, "#bae6fd", AGUA_OSCURO, 2.2),
            E(70, 42, 6, 4, BLANCO),
            L("M44 40 Q40 50 44 60 M116 40 Q120 50 116 60", ROJO, 2.0),
        ],
        "Pompa grande ovalada deformándose y temblando en el aire.",
        None,
    ),
    "wobbly jelly": (
        "D",
        fondo_mesa()
        + [
            *plato_prop(80, 72, 34),
            F("M54 68 Q58 32 80 32 Q102 32 106 68 Z", ROSA, ROSA_OSCURO, 2.0),
            E(72, 46, 4, 7, "#fbcfe8"),
            L("M44 40 Q40 50 44 60 M116 40 Q120 50 116 60", ROJO_OSCURO, 2.2),
        ],
        "Gelatina rosa temblando sobre un plato blanco con ondas de vibración.",
        None,
    ),
    "wobbly tower": (
        "D",
        fondo_sala()
        + [
            R(66, 68, 28, 13, 2, AZUL, AZUL_OSCURO, 1.8),
            P([(64, 68), (92, 66), (90, 53), (62, 55)], VERDE, VERDE_OSCURO, 1.8),
            P([(68, 53), (96, 55), (98, 42), (70, 40)], AMARILLO, AMARILLO_OSCURO, 1.8),
            P([(62, 40), (90, 36), (88, 23), (60, 27)], ROJO, ROJO_OSCURO, 1.8),
            L("M52 28 Q48 38 52 48 M106 28 Q110 38 106 48", NARANJA_OSCURO, 2.0),
        ],
        "Torre alta de bloques inclinada tambaleándose a punto de caer.",
        None,
    ),
    "wriggle toes": (
        "D",
        fondo_cielo("#fef3c7")
        + [
            R(0, 68, 160, 32, 0, "#fde68a", "#d97706", 2.0),
            E(56, 60, 11, 16, PEL, PELB, 2.0),
            E(104, 60, 11, 16, PEL, PELB, 2.0),
            *[E(48 + i * 4.5, 42, 2.2, 3.2, PEL, PELB, 1.3) for i in range(5)],
            *[E(95 + i * 4.5, 42, 2.2, 3.2, PEL, PELB, 1.3) for i in range(5)],
            L("M46 34 Q56 28 66 34 M94 34 Q104 28 114 34", ROJO, 2.0),
        ],
        "Dos pies descalzos en la arena moviendo los deditos con ondas.",
        None,
    ),
    "zoom": (
        "D",
        fondo_cielo()
        + [
            R(0, 70, 160, 30, 0, GRIS, GRIS_OSCURO, 1.5),
            R(72, 48, 56, 18, 6, ROJO, ROJO_OSCURO, 2.0),
            F("M84 48 L92 34 L114 34 L122 48 Z", "#bae6fd", ROJO_OSCURO, 1.8),
            E(86, 68, 7, 7, NEGRO),
            E(116, 68, 7, 7, NEGRO),
            L("M24 52 L64 52 M16 60 L60 60 M32 44 L66 44", NARANJA_OSCURO, 3.0),
        ],
        "Coche de carreras avanzando a gran velocidad con estelas largas.",
        None,
    ),

    # ══════ PRIMER BLOQUE DE `present_object` ══════
    "a slice for each": (
        "D",
        fondo_mesa()
        + plato_prop(50, 64, 24)
        + plato_prop(110, 64, 24)
        + [
            P([(38, 62), (62, 62), (50, 44)], NARANJA, NARANJA_OSCURO, 1.8),
            P([(98, 62), (122, 62), (110, 44)], NARANJA, NARANJA_OSCURO, 1.8),
            *frecha((66, 30), (48, 42), VERDE_OSCURO),
            *frecha((94, 30), (112, 42), VERDE_OSCURO),
        ],
        "Dos platos iguales, cada uno con una rodaja repartida.",
        None,
    ),
    "a spoon for you": (
        "D",
        fondo_sala()
        + bebe_sentado(56, 52, (VERDE, VERDE_OSCURO))
        + cuchara_prop(92, 42, 32)
        + frecha((104, 34), (78, 46), ROJO),
        "Bebé sentado recibiendo la cuchara que le ofrecen.",
        None,
    ),
    "acorn cap": (
        "D",
        fondo_prado()
        + [
            E(80, 62, 16, 18, TIERRA_CLARA, BARRO, 2.0),
            F("M56 42 C58 22 102 22 104 42 Z", BARRO, NEGRO, 2.2),
            L("M80 24 L80 14", BARRO, 3.2),
            *frecha((116, 26), (96, 36), ROJO),
        ],
        "Bellota con su sombrerete marrón oscuro destacado arriba.",
        None,
    ),
    "across the sea": (
        "D",
        fondo_mar()
        + [
            P([(58, 58), (102, 58), (94, 70), (66, 70)], MADERA, MADERA_OSCURA, 2.0),
            L("M80 58 L80 30", MADERA_OSCURA, 2.5),
            P([(80, 32), (98, 46), (80, 52)], BLANCO, GRIS_OSCURO, 1.6),
            L("M24 38 Q80 18 136 38", ROJO, 2.4),
            P([(138, 38), (128, 32), (130, 42)], ROJO),
        ],
        "Barquito cruzando el mar de un extremo al otro con flecha larga.",
        None,
    ),
    "add one more": (
        "D",
        fondo_mesa()
        + [
            R(62, 60, 36, 16, 3, AZUL, AZUL_OSCURO, 1.8),
            R(62, 44, 36, 16, 3, VERDE, VERDE_OSCURO, 1.8),
            R(62, 18, 36, 16, 3, ROJO, ROJO_OSCURO, 1.8),
            *frecha((114, 24), (102, 40), ROJO),
        ],
        "Dos bloques apilados recibiendo un bloque rojo adicional encima.",
        None,
    ),
    "add up": (
        "D",
        fondo_mesa()
        + [
            E(42, 48, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            E(56, 56, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            E(104, 48, 8, 8, VERDE, VERDE_OSCURO, 1.8),
            E(118, 56, 8, 8, VERDE, VERDE_OSCURO, 1.8),
            *frecha((58, 36), (76, 36), AZUL_OSCURO),
            *frecha((102, 36), (84, 36), AZUL_OSCURO),
        ],
        "Dos grupos de manzanas juntándose en el centro para sumar.",
        None,
    ),
    "all aboard": (
        "D",
        fondo_prado()
        + [
            R(36, 44, 88, 28, 5, AZUL, AZUL_OSCURO, 2.0),
            R(44, 50, 18, 12, 2, "#bae6fd", AZUL_OSCURO, 1.4),
            R(70, 50, 18, 12, 2, "#bae6fd", AZUL_OSCURO, 1.4),
            R(96, 50, 18, 12, 2, "#bae6fd", AZUL_OSCURO, 1.4),
            E(50, 74, 6, 6, NEGRO),
            E(80, 74, 6, 6, NEGRO),
            E(110, 74, 6, 6, NEGRO),
            *frecha((18, 62), (34, 56), ROJO),
        ],
        "Tren azul en el andén con flecha subiendo a bordo.",
        None,
    ),
    "all aboard the boat": (
        "D",
        fondo_mar()
        + [
            P([(38, 54), (122, 54), (110, 72), (50, 72)], MADERA, MADERA_OSCURA, 2.2),
            *nino_busto(64, 34, camisa=(ROJO, ROJO_OSCURO)),
            *nino_busto(94, 34, camisa=(AMARILLO, AMARILLO_OSCURO)),
            *frecha((20, 48), (44, 52), VERDE_OSCURO),
        ],
        "Barco en el agua con niños subiendo a cubierta.",
        None,
    ),
    "almost at the top": (
        "D",
        fondo_cielo()
        + [
            P([(20, 88), (80, 18), (140, 88)], TIERRA, BARRO, 2.2),
            P([(62, 39), (80, 18), (98, 39)], BLANCO, GRIS_OSCURO, 1.6),
            L("M80 18 L80 6", TINTA, 2.0),
            P([(80, 6), (92, 11), (80, 16)], ROJO),
            *nino((62, 34), (66, 44), (70, 58), [[(74, 30)], [(54, 48)]], [[(64, 70)], [(76, 72)]], camisa=(ROJO, ROJO_OSCURO)),
        ],
        "Niño cerca de la cima de la montaña estirando la mano hacia la cumbre.",
        None,
    ),
    "alternating": (
        "D",
        fondo_sala()
        + nino((80, 26), (80, 38), (80, 56), [[(60, 22)], [(100, 54)]], [[(72, 76)], [(88, 76)]], camisa=(VERDE, VERDE_OSCURO))
        + frecha((50, 40), (50, 20), ROJO)
        + frecha((110, 36), (110, 56), AZUL_OSCURO),
        "Niño alternando un brazo arriba y el otro abajo.",
        None,
    ),
    "animal ears": (
        "D",
        fondo_sala()
        + [
            E(80, 58, 16, 16, PEL, PELB, 2.2),
            F("M64 56 C64 38 96 38 96 56 C88 46 72 46 64 56 Z", BARRO),
            E(74, 56, 1.8, 2.2, TINTA),
            E(86, 56, 1.8, 2.2, TINTA),
            L("M74 65 Q80 70 86 65", "#9a3412", 1.8),
            E(68, 30, 5.5, 16, PEL, PELB, 1.8),
            E(92, 30, 5.5, 16, PEL, PELB, 1.8),
            E(68, 30, 2.5, 10, ROSA),
            E(92, 30, 2.5, 10, ROSA),
        ],
        "Niño con largas orejas de conejo colocadas sobre la cabeza.",
        None,
    ),
    "apples and pears": (
        "D",
        fondo_mesa()
        + [
            E(56, 56, 16, 15, ROJO, ROJO_OSCURO, 2.0),
            L("M56 41 L58 33", BARRO, 2.4),
            F("M58 34 Q68 30 66 40 Q58 40 58 34 Z", VERDE, VERDE_OSCURO, 1.4),
            F("M104 34 C96 34 94 46 92 54 C90 66 96 72 104 72 C112 72 118 66 116 54 C114 46 112 34 104 34 Z", HERBA, VERDE_OSCURO, 2.0),
            L("M104 34 L106 26", BARRO, 2.4),
        ],
        "Manzana roja y pera verde juntas sobre la mesa.",
        None,
    ),
    "arch your back": (
        "D",
        fondo_sala()
        + [
            F("M44 64 C50 34 96 34 106 64 L100 76 L92 76 L92 60 Q75 50 58 60 L58 76 L50 76 Z", NEGRO),
            E(42, 54, 9, 8, NEGRO),
            P([(35, 48), (39, 38), (43, 46)], NEGRO),
            P([(43, 46), (47, 38), (50, 48)], NEGRO),
            L("M58 30 Q76 18 94 30", ROJO, 2.2),
            P([(76, 18), (72, 24), (80, 24)], ROJO),
        ],
        "Gato arqueando bien alto el lomo con flecha curva encima.",
        None,
    ),
    "arctic fox": (
        "D",
        fondo_cielo("#e0f2fe")
        + [
            R(0, 72, 160, 28, 0, BLANCO, GRIS, 1.8),
            E(76, 62, 24, 13, BLANCO, GRIS_OSCURO, 2.0),
            E(54, 54, 11, 10, BLANCO, GRIS_OSCURO, 2.0),
            P([(46, 46), (49, 34), (56, 44)], BLANCO, GRIS_OSCURO, 1.8),
            P([(55, 44), (60, 34), (63, 46)], BLANCO, GRIS_OSCURO, 1.8),
            E(48, 54, 1.5, 1.5, TINTA),
            F("M98 62 C118 58 122 72 96 72 Z", BLANCO, GRIS_OSCURO, 1.8),
        ],
        "Zorro ártico blanco acurrucado sobre la nieve.",
        None,
    ),
    "arrange tiles": (
        "D",
        fondo_sala()
        + [
            R(28, 42, 22, 22, 2, ROJO, ROJO_OSCURO, 1.8),
            R(54, 42, 22, 22, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(80, 42, 22, 22, 2, AZUL, AZUL_OSCURO, 1.8),
            R(110, 24, 22, 22, 2, VERDE, VERDE_OSCURO, 1.8),
            *frecha((121, 48), (117, 62), VERDE_OSCURO),
        ],
        "Azulejos de colores colocados en fila ordenadamente.",
        None,
    ),
    "ask for": (
        "D",
        fondo_sala()
        + nino((52, 30), (52, 42), (52, 60), [[(40, 48)], [(76, 44)]], [[(46, 78)], [(58, 78)]], camisa=(AZUL, AZUL_OSCURO), mira=1)
        + pelota_prop(108, 44, 11, ROJO, ROJO_OSCURO)
        + frecha((78, 42), (96, 42), VERDE_OSCURO),
        "Niño extendiendo la palma hacia delante para pedir la pelota.",
        None,
    ),
    "autumn": (
        "D",
        fondo_cielo("#fef3c7")
        + [
            R(0, 76, 160, 24, 0, TIERRA_CLARA, BARRO, 1.8),
            R(28, 34, 12, 44, 3, BARRO),
            E(34, 28, 22, 18, NARANJA, NARANJA_OSCURO, 1.8),
            E(72, 34, 7, 4, NARANJA, BARRO, 1.4),
            E(96, 48, 8, 4.5, ROJO, ROJO_OSCURO, 1.4),
            E(118, 30, 7, 4, AMARILLO, AMARILLO_OSCURO, 1.4),
            E(88, 68, 8, 4, NARANJA, BARRO, 1.4),
        ],
        "Árbol otoñal con hojas naranjas, rojas y doradas cayendo al suelo.",
        None,
    ),
    "back in the box": (
        "D",
        fondo_sala()
        + caja_prop(62, 50, 36, "#fde68a", MADERA_OSCURA)
        + pelota_prop(80, 24, 10, ROJO, ROJO_OSCURO)
        + frecha((80, 34), (80, 50), AZUL_OSCURO),
        "Pelota bajando con flecha para guardarse dentro de la caja.",
        None,
    ),
    "back to front": (
        "D",
        fondo_sala()
        + [
            E(80, 44, 16, 16, PEL, PELB, 2.2),
            E(74, 46, 1.8, 2.2, TINTA),
            E(86, 46, 1.8, 2.2, TINTA),
            L("M74 53 Q80 57 86 53", "#9a3412", 1.8),
            F("M62 38 C64 20 96 20 98 38 Z", ROJO, ROJO_OSCURO, 2.0),
            R(94, 33, 20, 5, 2, ROJO_OSCURO),
            L("M58 18 Q80 8 102 18", AZUL_OSCURO, 2.2),
        ],
        "Niño con la gorra puesta al revés, con la visera hacia atrás.",
        None,
    ),
    "badge": (
        "D",
        fondo_sala()
        + [
            R(50, 34, 60, 58, 10, AZUL, AZUL_OSCURO, 2.0),
            E(80, 56, 16, 16, DORADO, AMARILLO_OSCURO, 2.0),
            _estrella(80, 56, 10, 4.2, BLANCO, AMARILLO_OSCURO),
            P([(70, 68), (64, 86), (76, 80)], ROJO, ROJO_OSCURO, 1.4),
            P([(90, 68), (96, 86), (84, 80)], ROJO, ROJO_OSCURO, 1.4),
        ],
        "Insignia dorada con estrella y cintas prendida en el pecho.",
        None,
    ),
    "bagpipes": (
        "D",
        fondo_prado()
        + [
            E(76, 56, 22, 16, VERDE, VERDE_OSCURO, 2.2),
            L("M60 50 L92 50 M60 62 L92 62 M70 42 L70 70 M82 42 L82 70", ROJO, 2.0),
            L("M66 44 L44 20 M76 42 L68 14 M86 44 L94 18", MADERA_OSCURA, 4.2),
            L("M56 54 L36 62", MADERA_OSCURA, 3.0),
        ],
        "Gaita con saco a cuadros y tres punteros sonoros.",
        None,
    ),
    "balance arms": (
        "D",
        fondo_sala()
        + nino((80, 26), (80, 38), (80, 56), [[(42, 40)], [(118, 40)]], [[(74, 78)], [(86, 78)]], camisa=(ROJO, ROJO_OSCURO))
        + [L("M36 46 L124 46", AZUL_OSCURO, 1.8)],
        "Niño manteniendo ambos brazos extendidos perfectamente horizontales.",
        None,
    ),
    "balance on top": (
        "D",
        fondo_mesa()
        + [
            R(62, 50, 36, 26, 3, AZUL, AZUL_OSCURO, 2.0),
            P([(66, 50), (80, 20), (94, 50)], AMARILLO, AMARILLO_OSCURO, 2.0),
            *frecha((108, 22), (92, 34), VERDE_OSCURO),
        ],
        "Pirámide amarilla equilibrada con precisión encima de un cubo azul.",
        None,
    ),
    "balanced scale": (
        "D",
        fondo_mesa()
        + [
            L("M80 76 L80 30", GRIS_OSCURO, 4.0),
            R(64, 72, 32, 6, 2, GRIS_OSCURO),
            L("M40 34 L120 34", AMARILLO_OSCURO, 3.5),
            L("M44 34 L34 54 M44 34 L54 54 M116 34 L106 54 M116 34 L126 54", GRIS_OSCURO, 1.5),
            R(32, 54, 24, 5, 2, DORADO, AMARILLO_OSCURO, 1.5),
            R(104, 54, 24, 5, 2, DORADO, AMARILLO_OSCURO, 1.5),
            E(44, 48, 6, 6, ROJO, ROJO_OSCURO, 1.5),
            E(116, 48, 6, 6, ROJO, ROJO_OSCURO, 1.5),
        ],
        "Balanza completamente horizontal con pesos idénticos en ambos platillos.",
        None,
    ),
    "barn": (
        "D",
        fondo_prado()
        + [
            P([(38, 76), (38, 42), (80, 18), (122, 42), (122, 76)], ROJO, ROJO_OSCURO, 2.2),
            P([(34, 44), (80, 14), (126, 44)], MADERA_OSCURA, NEGRO, 2.2),
            R(64, 50, 32, 26, 2, BLANCO, MADERA_OSCURA, 2.0),
            L("M64 50 L96 76 M96 50 L64 76", MADERA_OSCURA, 2.0),
        ],
        "Establo rojo de tejado picudo con puerta blanca cruzada en aspa.",
        None,
    ),
    "base": (
        "D",
        fondo_mesa()
        + [
            R(36, 56, 88, 18, 4, VERDE, VERDE_OSCURO, 2.4),
            R(52, 40, 56, 16, 3, AZUL, AZUL_OSCURO, 1.8),
            R(68, 24, 24, 16, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            *frecha((22, 64), (34, 64), ROJO),
        ],
        "Bloque ancho en la parte inferior destacando la base de la torre.",
        None,
    ),
    "bath foam": (
        "D",
        fondo_sala()
        + [
            R(32, 50, 96, 28, 12, BLANCO, AZUL_OSCURO, 2.2),
            E(50, 44, 14, 10, BLANCO, GRIS, 1.6),
            E(72, 40, 16, 12, BLANCO, GRIS, 1.6),
            E(96, 42, 15, 11, BLANCO, GRIS, 1.6),
            E(114, 46, 12, 9, BLANCO, GRIS, 1.6),
            *pompas([(58, 22, 6), (86, 18, 7), (112, 24, 5)]),
        ],
        "Bañera llena de espuma esponjosa blanca y pompas arriba.",
        None,
    ),
    "be gentle with bugs": (
        "D",
        fondo_prado()
        + [
            F("M44 64 C54 44 102 42 116 58 C98 74 64 74 44 64 Z", VERDE, VERDE_OSCURO, 2.0),
            E(80, 52, 8, 7, ROJO, NEGRO, 1.8),
            E(74, 52, 3, 3, NEGRO),
            E(80, 50, 1.4, 1.4, NEGRO),
            E(84, 54, 1.4, 1.4, NEGRO),
            E(58, 34, 9, 6, PEL, PELB, 1.8),
            *frecha((58, 22), (66, 32), VERDE_OSCURO),
        ],
        "Mano posándose suavemente junto a una mariquita sobre una hoja.",
        None,
    ),
    "beach bag": (
        "D",
        fondo_cielo("#fef3c7")
        + [
            R(0, 74, 160, 26, 0, "#fde68a"),
            L("M62 40 Q80 18 98 40", NARANJA_OSCURO, 3.6),
            P([(48, 38), (112, 38), (104, 78), (56, 78)], AZUL, AZUL_OSCURO, 2.0),
            L("M52 52 L108 52 M54 64 L106 64", BLANCO, 3.4),
            R(86, 26, 16, 14, 3, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Bolsa de playa a rayas azules y blancas con toalla asomando.",
        None,
    ),
    "beach spade": (
        "D",
        fondo_cielo("#fef3c7")
        + [
            F("M20 84 Q78 58 140 84 L160 100 L0 100 Z", "#fde68a", "#d97706", 2.0),
            R(76, 18, 8, 34, 3, ROJO, ROJO_OSCURO, 1.8),
            R(70, 14, 20, 7, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            P([(66, 50), (94, 50), (90, 76), (80, 82), (70, 76)], AZUL, AZUL_OSCURO, 2.0),
        ],
        "Pala infantil azul y roja clavada en la arena de la playa.",
        None,
    ),
    "bead": (
        "D",
        fondo_mesa()
        + [
            L("M24 58 Q76 48 136 56", BARRO, 2.4),
            E(44, 54, 10, 10, ROJO, ROJO_OSCURO, 2.0),
            E(70, 52, 10, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(96, 52, 10, 10, AZUL, AZUL_OSCURO, 2.0),
            E(122, 34, 10, 10, VERDE, VERDE_OSCURO, 2.0),
            *frecha((122, 44), (122, 54), VERDE_OSCURO),
        ],
        "Cuentas de madera de colores ensartadas en un cordón.",
        None,
    ),
    "beanbag": (
        "D",
        fondo_sala()
        + [
            F("M40 72 C36 46 58 34 80 34 C102 34 124 46 120 72 C104 82 56 82 40 72 Z", MORADO, "#5b21b6", 2.2),
            F("M54 54 Q80 64 106 54", "#ddd6fe", "#5b21b6", 1.8),
        ],
        "Puf morado mullido con asiento hundido para recostarse.",
        None,
    ),
    "bedtime routine": (
        "D",
        fondo_noite()
        + [
            R(16, 46, 34, 7, 3, AZUL, AZUL_OSCURO, 1.6),
            R(16, 40, 12, 6, 2, BLANCO, GRIS_OSCURO, 1.4),
            *frecha((52, 48), (62, 48), "#fde047"),
            *libro_prop(64, 34, 30, VERDE),
            *frecha((96, 48), (106, 48), "#fde047"),
            F("M126 24 C114 28 114 44 126 48 C118 44 118 30 126 24 Z", "#fef08a", AMARILLO_OSCURO, 1.6),
            R(110, 56, 34, 14, 3, ROJO, ROJO_OSCURO, 1.6),
            R(112, 50, 10, 7, 2, BLANCO, GRIS_OSCURO, 1.2),
        ],
        "Tres pasos de noche en orden: cepillo de dientes, cuento y cama.",
        None,
    ),
    "beep beep, nose": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 24, PEL, PELB, 2.2),
            E(70, 44, 2.2, 2.6, TINTA),
            E(90, 44, 2.2, 2.6, TINTA),
            E(80, 52, 4.5, 4.5, ROJO, ROJO_OSCURO, 1.6),
            L("M72 62 Q80 68 88 62", "#9a3412", 1.8),
            L("M108 52 L90 52", PELB, 4.5),
            L("M108 52 L90 52", PEL, 2.5),
            L("M66 50 Q62 54 66 58 M94 50 Q98 54 94 58", ROJO, 1.6),
        ],
        "Cara sonriente con dedo apretando suavemente la nariz divertida.",
        None,
    ),
    "beep, beep": (
        "D",
        fondo_cielo("#f1f5f9")
        + [
            E(80, 52, 28, 28, NEGRO),
            E(80, 52, 21, 21, "#e2e8f0"),
            L("M56 52 L104 52 M80 52 L80 78", NEGRO, 5.0),
            E(80, 52, 11, 11, ROJO, ROJO_OSCURO, 1.8),
            L("M42 42 Q34 52 42 62 M118 42 Q126 52 118 62", AMARILLO_OSCURO, 2.4),
        ],
        "Volante de coche con bocina roja central y ondas de sonido.",
        None,
    ),
    "beep, beep, bus": (
        "D",
        fondo_cielo()
        + [
            R(0, 72, 160, 28, 0, GRIS, GRIS_OSCURO, 1.5),
            R(36, 34, 84, 38, 6, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(44, 42, 18, 14, 2, "#bae6fd", AMARILLO_OSCURO, 1.4),
            R(68, 42, 18, 14, 2, "#bae6fd", AMARILLO_OSCURO, 1.4),
            R(92, 42, 18, 14, 2, "#bae6fd", AMARILLO_OSCURO, 1.4),
            E(54, 72, 7, 7, NEGRO),
            E(102, 72, 7, 7, NEGRO),
            L("M126 42 Q134 50 126 58 M134 38 Q144 50 134 62", ROJO, 2.4),
        ],
        "Autobús escolar amarillo tocando la bocina con ondas delante.",
        None,
    ),
    "bees build hexagons because they fit together": (
        "D",
        fondo_cielo("#fef9c3")
        + [
            P([(62, 34), (72, 28), (82, 34), (82, 46), (72, 52), (62, 46)], AMARILLO, AMARILLO_OSCURO, 2.0),
            P([(82, 34), (92, 28), (102, 34), (102, 46), (92, 52), (82, 46)], DORADO, AMARILLO_OSCURO, 2.0),
            P([(72, 52), (82, 46), (92, 52), (92, 64), (82, 70), (72, 64)], AMARILLO, AMARILLO_OSCURO, 2.0),
            E(42, 38, 7, 5, AMARILLO, NEGRO, 1.6),
            E(38, 32, 4, 5, BLANCO, GRIS_OSCURO, 1.2),
        ],
        "Abeja junto a tres hexágonos de panal que encajan sin huecos.",
        None,
    ),
    "bell button": (
        "D",
        fondo_sala()
        + [
            R(75, 14, 10, 74, 3, GRIS_OSCURO, NEGRO, 1.8),
            R(68, 36, 24, 32, 6, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(80, 52, 7, 7, ROJO, ROJO_OSCURO, 1.8),
            L("M112 52 L88 52", PELB, 4.5),
            L("M112 52 L88 52", PEL, 2.5),
            L("M58 46 Q52 52 58 58", ROJO, 2.0),
        ],
        "Botón rojo de parada en barra amarilla con dedo pulsándolo.",
        None,
    ),
    "belly": (
        "D",
        fondo_sala()
        + nino((80, 24), (80, 38), (80, 58), [[(64, 46), (72, 54)], [(96, 46), (88, 54)]], [[(74, 80)], [(86, 80)]], camisa=(VERDE, VERDE_OSCURO))
        + [
            E(80, 53, 8, 7, PEL, PELB, 1.6),
            E(80, 54, 1.5, 1.5, TINTA),
            L("M68 48 Q80 40 92 48", ROJO, 1.8),
        ],
        "Niño destacando la barriga redondeada al rodearla.",
        None,
    ),
    "bend": (
        "D",
        fondo_sala()
        + nino((78, 30), (74, 42), (72, 58), [[(90, 48)], [(60, 48)]], [[(86, 68), (74, 78)], [(68, 68), (58, 78)]], camisa=(AZUL, AZUL_OSCURO), mira=1)
        + frecha((104, 34), (104, 58), ROJO),
        "Niño flexionando ambas rodillas bajando hacia el suelo.",
        None,
    ),
    "bendy": (
        "D",
        fondo_cielo("#ecfeff")
        + [
            L("M34 68 C40 20 120 20 126 68", VERDE_OSCURO, 8.0),
            L("M34 68 C40 20 120 20 126 68", VERDE, 4.6),
            *frecha((52, 54), (66, 38), ROJO),
            *frecha((108, 54), (94, 38), ROJO),
        ],
        "Barra verde muy flexible doblada en forma de arco U.",
        None,
    ),
    "berry": (
        "D",
        fondo_prado()
        + [
            L("M44 30 Q80 24 116 32", BARRO, 3.0),
            F("M70 28 Q80 14 90 28 Q80 36 70 28 Z", VERDE, VERDE_OSCURO, 1.5),
            L("M58 29 L56 44 M80 28 L80 46 M102 30 L104 44", VERDE_OSCURO, 2.0),
            E(56, 52, 9, 10, ROJO, ROJO_OSCURO, 1.8),
            E(80, 56, 9, 10, MORADO, "#4c1d95", 1.8),
            E(104, 52, 9, 10, ROJO, ROJO_OSCURO, 1.8),
            E(53, 49, 2, 2, BLANCO),
            E(77, 53, 2, 2, BLANCO),
            E(101, 49, 2, 2, BLANCO),
        ],
        "Ramita con bayas rojas y moradas brillantes colgando.",
        None,
    ),
    "beside": (
        "D",
        fondo_prado()
        + _nino_pie(60, 26, (ROJO, ROJO_OSCURO), 1)
        + _nino_pie(98, 26, (AZUL, AZUL_OSCURO), -1)
        + frecha((70, 18), (88, 18), VERDE_OSCURO),
        "Dos amigos de pie colocados juntos lado a lado.",
        None,
    ),
    "between": (
        "D",
        fondo_prado()
        + _nino_pie(40, 28, (AZUL, AZUL_OSCURO), 1)
        + _nino_pie(80, 24, (AMARILLO, AMARILLO_OSCURO), 1)
        + _nino_pie(120, 28, (AZUL, AZUL_OSCURO), -1)
        + frecha((80, 12), (80, 22), ROJO),
        "Tres niños en fila con el del medio señalado entre los dos.",
        None,
    ),
    "big waves": (
        "D",
        fondo_cielo()
        + [
            F("M0 72 Q26 42 52 62 Q82 22 114 48 Q138 30 160 54 L160 100 L0 100 Z", AZUL, AZUL_OSCURO, 2.4),
            F("M68 42 Q84 20 102 32 Q92 38 78 44 Z", BLANCO),
            *frecha((24, 52), (24, 24), AZUL_OSCURO),
        ],
        "Olas altas del mar crestadas de espuma blanca subiendo alto.",
        None,
    ),
    "bigger now": (
        "D",
        fondo_prado()
        + [
            R(40, 60, 10, 16, 2, VERDE, VERDE_OSCURO, 1.8),
            E(45, 56, 6, 5, VERDE, VERDE_OSCURO, 1.6),
            R(98, 30, 14, 46, 3, VERDE, VERDE_OSCURO, 2.0),
            E(105, 24, 10, 9, VERDE, VERDE_OSCURO, 1.8),
            *frecha((64, 56), (86, 36), ROJO),
        ],
        "Comparación de un brote pequeño creciendo a una planta mucho mayor.",
        None,
    ),
    "bike ride": (
        "D",
        fondo_prado()
        + [
            E(52, 66, 13, 13, BLANCO, NEGRO, 3.0),
            E(108, 66, 13, 13, BLANCO, NEGRO, 3.0),
            L("M52 66 L74 44 L102 44 L108 66 M74 44 L80 66 L52 66", ROJO, 3.0),
            L("M98 38 L106 38", NEGRO, 2.6),
            L("M70 40 L78 40", NEGRO, 3.0),
            *nino_busto(76, 22, camisa=(AZUL, AZUL_OSCURO), mira=1),
        ],
        "Niño paseando en bicicleta roja por el camino verde.",
        None,
    ),
    "bin": (
        "D",
        fondo_sala()
        + [
            P([(56, 38), (104, 38), (96, 78), (64, 78)], VERDE, VERDE_OSCURO, 2.2),
            R(52, 32, 56, 7, 2, VERDE_OSCURO),
            F("M74 16 C82 14 88 22 80 26 C74 26 70 20 74 16 Z", BLANCO, GRIS_OSCURO, 1.4),
            *frecha((80, 26), (80, 36), ROJO),
        ],
        "Papelera verde con bola de papel entrando arriba.",
        None,
    ),
    "binoculars": (
        "D",
        fondo_cielo()
        + [
            R(44, 34, 24, 40, 8, AZUL, AZUL_OSCURO, 2.2),
            R(92, 34, 24, 40, 8, AZUL, AZUL_OSCURO, 2.2),
            R(66, 44, 28, 10, 3, GRIS_OSCURO, NEGRO, 1.8),
            E(56, 34, 11, 5, "#bae6fd", AZUL_OSCURO, 1.8),
            E(104, 34, 11, 5, "#bae6fd", AZUL_OSCURO, 1.8),
        ],
        "Prismáticos azules con lentes brillantes para mirar lejos.",
        None,
    ),
    "bird feeder": (
        "D",
        fondo_prado()
        + [
            L("M80 10 L80 24", BARRO, 2.2),
            P([(54, 38), (80, 22), (106, 38)], ROJO, ROJO_OSCURO, 2.0),
            R(62, 38, 36, 26, 2, "#fef3c7", MADERA_OSCURA, 1.8),
            R(54, 64, 52, 6, 2, MADERA, MADERA_OSCURA, 1.8),
            *[E(66 + i * 6, 59, 1.6, 1.6, TIERRA) for i in range(5)],
            E(114, 54, 7, 5, AZUL, AZUL_OSCURO, 1.5),
            E(110, 50, 4, 4, AZUL, AZUL_OSCURO, 1.5),
        ],
        "Comedero colgante de madera con semillas y un pajarito comiendo.",
        None,
    ),
    "birdhouse": (
        "D",
        fondo_cielo()
        + [
            L("M80 72 L80 96", MADERA_OSCURA, 4.0),
            P([(52, 42), (80, 20), (108, 42), (108, 74), (52, 74)], MADERA, MADERA_OSCURA, 2.2),
            P([(46, 44), (80, 16), (114, 44)], VERDE, VERDE_OSCURO, 2.2),
            E(80, 50, 9, 9, BARRO, NEGRO, 1.6),
            R(74, 62, 12, 4, 2, MADERA_OSCURA),
        ],
        "Casita de madera con tejado verde y agujero redondo para pájaros.",
        None,
    ),
    "birdseed": (
        "D",
        fondo_mesa()
        + [
            F("M44 58 C54 44 106 44 116 58 C110 74 50 74 44 58 Z", "#fde68a", MADERA_OSCURA, 2.0),
            *[E(62 + (i % 6) * 7, 54 + (i // 6) * 5, 2.2, 1.4, TIERRA_CLARA, BARRO, 1.0) for i in range(12)],
        ],
        "Montoncito de granos dorados de alpiste en un cuenco abierto.",
        None,
    ),
    "blade of grass": (
        "D",
        fondo_cielo("#ecfccb")
        + [
            F("M74 88 C74 56 76 34 86 14 C86 38 86 60 88 88 Z", VERDE, VERDE_OSCURO, 2.2),
            E(82, 44, 3, 4, "#bae6fd", AGUA_OSCURO, 1.2),
        ],
        "Una única brizna alta y esbelta de hierba verde con gotita.",
        None,
    ),
    "blanket": (
        "D",
        fondo_sala()
        + manta_prop(46, 30, 68, ROJO, 48)
        + [
            L("M50 50 L110 50 M50 64 L110 64 M70 38 L70 82 M90 38 L90 82", "#fca5a5", 1.8),
        ],
        "Manta cálida a cuadros doblada suavemente para taparse.",
        None,
    ),
    "block the water": (
        "D",
        fondo_cielo()
        + [
            R(0, 56, 76, 34, 0, AGUA, AGUA_OSCURO, 2.0),
            R(76, 34, 16, 56, 3, MADERA, MADERA_OSCURA, 2.2),
            R(92, 74, 68, 16, 0, HERBA, VERDE_OSCURO, 1.8),
            *frecha((42, 66), (72, 66), AZUL_OSCURO),
        ],
        "Barrera de madera conteniendo el agua azul para frenar su paso.",
        None,
    ),
    "blocks": (
        "D",
        fondo_sala()
        + [
            R(44, 54, 24, 22, 3, ROJO, ROJO_OSCURO, 2.0),
            R(72, 54, 24, 22, 3, AZUL, AZUL_OSCURO, 2.0),
            R(100, 54, 24, 22, 3, VERDE, VERDE_OSCURO, 2.0),
            R(58, 32, 24, 22, 3, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(86, 32, 24, 22, 3, MORADO, "#5b21b6", 2.0),
        ],
        "Bloques de madera de colores vivos apilados en pirámide.",
        None,
    ),
    "blow your nose": (
        "D",
        fondo_sala()
        + [
            E(80, 46, 18, 18, PEL, PELB, 2.2),
            E(72, 42, 1.8, 2.2, TINTA),
            E(88, 42, 1.8, 2.2, TINTA),
            P([(68, 52), (92, 52), (88, 72), (72, 72)], BLANCO, GRIS_OSCURO, 1.8),
            L("M62 56 L50 62 M98 56 L110 62", AGUA_OSCURO, 1.8),
        ],
        "Niño sujetando un pañuelo blanco limpio sobre la nariz para sonarse.",
        None,
    ),
    "blue and yellow make green": (
        "D",
        fondo_mesa()
        + [
            E(56, 52, 24, 20, AZUL, AZUL_OSCURO, 2.0),
            E(104, 52, 24, 20, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(80, 52, 14, 18, VERDE, VERDE_OSCURO, 2.0),
        ],
        "Mancha azul y mancha amarilla superpuestas formando verde en el centro.",
        None,
    ),
    "bob": (
        "D",
        fondo_sala()
        + bebe_sentado(80, 44, (AMARILLO, AMARILLO_OSCURO))
        + [
            *frecha((42, 54), (42, 34), VERDE_OSCURO),
            *frecha((118, 34), (118, 54), VERDE_OSCURO),
        ],
        "Bebé subiendo y bajando suavemente con flechas verticales.",
        None,
    ),
    "bob on the water": (
        "D",
        fondo_mar()
        + [
            E(80, 54, 12, 10, ROJO, ROJO_OSCURO, 2.0),
            R(74, 48, 12, 12, 3, BLANCO, ROJO_OSCURO, 1.5),
            *frecha((104, 42), (104, 58), AZUL_OSCURO),
            *frecha((56, 58), (56, 42), AZUL_OSCURO),
        ],
        "Corcho rojo y blanco flotando subiendo y bajando sobre las olas.",
        None,
    ),
    "boil": (
        "D",
        fondo_mesa()
        + [
            R(48, 44, 64, 30, 5, PLATA, GRIS_OSCURO, 2.2),
            R(42, 48, 8, 6, 2, NEGRO),
            R(110, 48, 8, 6, 2, NEGRO),
            *pompas([(66, 36, 4), (80, 32, 5), (94, 36, 4), (74, 22, 3.5), (88, 22, 3)]),
            L("M60 76 L72 72 L84 76 L96 72", ROJO, 2.6),
        ],
        "Olla al fuego hirviendo con burbujas subiendo por arriba.",
        None,
    ),
    "bonfire smoke": (
        "D",
        fondo_noite()
        + [
            R(54, 70, 52, 8, 3, MADERA_OSCURA),
            F("M64 70 C62 54 78 44 80 34 C88 46 98 56 94 70 Z", NARANJA, ROJO_OSCURO, 1.8),
            L("M80 32 Q72 22 82 14 Q90 8 78 2", GRIS, 3.6),
            L("M88 30 Q98 20 88 10", PLATA, 2.4),
        ],
        "Hoguera nocturna encendida con espiral gris de humo ascendiendo.",
        None,
    ),
    "bonnet": (
        "D",
        fondo_sala()
        + [
            F("M54 56 C54 24 106 24 106 56 Z", "#fbcfe8", ROSA_OSCURO, 2.2),
            F("M48 56 C48 48 64 48 64 56 L96 56 C96 48 112 48 112 56 Z", BLANCO, ROSA_OSCURO, 1.8),
            L("M58 56 Q52 72 60 80 M102 56 Q108 72 100 80", ROSA, 2.4),
        ],
        "Gorrito infantil de bebé con visera festoneada y cintas colgantes.",
        None,
    ),
    "bounce": (
        "D",
        fondo_sala()
        + [
            *pelota_prop(102, 34, 12, NARANJA, NARANJA_OSCURO),
            L("M36 42 Q58 76 74 74 Q88 72 98 48", AZUL_OSCURO, 2.2),
            E(74, 74, 8, 3, GRIS_OSCURO),
        ],
        "Pelota naranja botando en el suelo en trayectoria de V.",
        None,
    ),
    "bounce up and down": (
        "D",
        fondo_sala()
        + [
            E(80, 74, 34, 7, AZUL, AZUL_OSCURO, 2.0),
            *nino_busto(80, 28, camisa=(ROJO, ROJO_OSCURO), brazos_arriba=True),
            *frecha((40, 56), (40, 32), VERDE_OSCURO),
            *frecha((120, 32), (120, 56), VERDE_OSCURO),
        ],
        "Niño rebotando arriba y abajo sobre colchoneta elástica.",
        None,
    ),
    "bracken": (
        "D",
        fondo_prado()
        + [
            L("M80 78 Q80 46 80 18", VERDE_OSCURO, 2.8),
            *[F(f"M80 {68 - i * 10} Q{62 - i * 2} {62 - i * 10} {54 + i * 2} {68 - i * 10} Q{66} {72 - i * 10} 80 {68 - i * 10} Z", VERDE, VERDE_OSCURO, 1.3) for i in range(5)],
            *[F(f"M80 {68 - i * 10} Q{98 + i * 2} {62 - i * 10} {106 - i * 2} {68 - i * 10} Q{94} {72 - i * 10} 80 {68 - i * 10} Z", VERDE, VERDE_OSCURO, 1.3) for i in range(5)],
        ],
        "Fronda amplia de helecho verde simétrico en el prado.",
        None,
    ),
    "brave knight": (
        "D",
        fondo_prado()
        + [
            E(80, 44, 18, 20, PLATA, GRIS_OSCURO, 2.2),
            R(66, 40, 28, 8, 2, NEGRO),
            F("M80 24 Q92 10 108 18 Q92 22 80 24 Z", ROJO, ROJO_OSCURO, 1.6),
            P([(106, 44), (132, 44), (128, 72), (119, 80), (110, 72)], AZUL, AZUL_OSCURO, 2.0),
            _estrella(119, 58, 6, 2.5),
        ],
        "Yelmo plateado con pluma roja y escudo de caballero.",
        None,
    ),
    "breathe": (
        "D",
        fondo_cielo("#e0f2fe")
        + nino_busto(80, 42, camisa=(AZUL, AZUL_OSCURO), ojos="cerrados")
        + [
            L("M48 44 Q62 40 72 44 M90 44 Q100 40 112 44", AGUA_OSCURO, 2.2),
            L("M66 56 Q80 64 94 56", VERDE_OSCURO, 2.0),
        ],
        "Niño respirando serenamente con flujo suave de aire entrando y saliendo.",
        None,
    ),
    "breathe in, breathe out": (
        "D",
        fondo_sala()
        + nino_busto(80, 44, camisa=(VERDE, VERDE_OSCURO))
        + [
            *frecha((42, 44), (66, 44), AZUL_OSCURO),
            *frecha((94, 44), (118, 44), ROJO),
        ],
        "Niño cogiendo aire por un lado y echando aire por el otro.",
        None,
    ),
    "breathing buddy": (
        "D",
        fondo_sala()
        + [
            R(26, 62, 108, 18, 6, AZUL, AZUL_OSCURO, 2.0),
            E(42, 54, 10, 10, PEL, PELB, 2.0),
            R(52, 54, 52, 16, 6, VERDE, VERDE_OSCURO, 2.0),
            E(78, 44, 9, 8, TIERRA_CLARA, BARRO, 1.8),
            E(78, 34, 6, 6, TIERRA_CLARA, BARRO, 1.6),
            *frecha((98, 46), (98, 30), ROJO),
        ],
        "Niño tumbado con un osito peluche subiendo sobre su barriga al respirar.",
        None,
    ),
    "breezy evening": (
        "D",
        fondo_cielo("#fed7aa")
        + [
            E(116, 46, 14, 14, NARANJA, ROJO_OSCURO, 1.8),
            R(0, 72, 160, 28, 0, HERBA, VERDE_OSCURO, 1.8),
            *lineas_viento(26, 36, 48, AZUL_OSCURO),
            E(88, 28, 6, 3.5, VERDE, VERDE_OSCURO, 1.4),
        ],
        "Atardecer anaranjado con brisa fresca meciendo las hojas.",
        None,
    ),
    "brick house": (
        "D",
        fondo_prado()
        + [
            R(44, 40, 72, 36, 2, ROJO, ROJO_OSCURO, 2.2),
            P([(38, 42), (80, 16), (122, 42)], MADERA_OSCURA, NEGRO, 2.2),
            L("M44 52 L116 52 M44 64 L116 64 M68 40 L68 52 M92 52 L92 64", "#fca5a5", 1.4),
            R(70, 54, 18, 22, 2, MADERA, MADERA_OSCURA, 1.8),
        ],
        "Casita sólida hecha de ladrillos rojos con puerta de madera.",
        None,
    ),
    "bridge": (
        "D",
        fondo_mar()
        + [
            F("M20 68 L20 44 L140 44 L140 68 L112 68 C106 48 54 48 48 68 Z", TIERRA_CLARA, BARRO, 2.2),
            L("M24 38 L136 38", MADERA_OSCURA, 2.6),
            L("M34 44 L34 38 M60 44 L60 38 M100 44 L100 38 M126 44 L126 38", MADERA_OSCURA, 2.2),
        ],
        "Puente de piedra en arco tendido sobre el río azul.",
        None,
    ),
    "bring": (
        "D",
        fondo_sala()
        + [
            E(116, 74, 24, 9, NARANJA, NARANJA_OSCURO, 2.0),
            *nino((48, 26), (48, 38), (48, 56), [[(64, 46)], [(38, 48)]], [[(42, 76)], [(54, 76)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            *pelota_prop(68, 46, 8, ROJO, ROJO_OSCURO),
            *frecha((78, 36), (104, 52), VERDE_OSCURO),
        ],
        "Niño llevando un balón hacia la alfombra con flecha indicativa.",
        None,
    ),
    "browse": (
        "D",
        fondo_mesa()
        + libro_prop(46, 36, 68, AZUL)
        + [
            F("M80 38 Q98 22 108 38 L108 66 Q94 56 80 66 Z", BLANCO, GRIS_OSCURO, 1.6),
            *frecha((104, 22), (76, 22), ROJO),
        ],
        "Libro ilustrado abierto pasando lentamente una página hacia la izquierda.",
        None,
    ),
    "brush your teeth": (
        "D",
        fondo_sala()
        + [
            R(50, 34, 60, 30, 12, BLANCO, GRIS_OSCURO, 2.2),
            L("M50 49 L110 49 M65 34 L65 64 M80 34 L80 64 M95 34 L95 64", GRIS, 1.6),
            R(34, 42, 46, 7, 3, AZUL, AZUL_OSCURO, 1.8),
            R(66, 35, 14, 7, 2, BLANCO, AGUA_OSCURO, 1.5),
            *pompas([(56, 26, 4), (74, 24, 5), (90, 26, 4)]),
        ],
        "Cepillo azul con espuma limpiando una fila de dientes blancos.",
        None,
    ),
    "buckle up": (
        "D",
        fondo_sala()
        + [
            L("M24 78 L66 54", NEGRO, 8.0),
            L("M136 24 L94 48", NEGRO, 8.0),
            R(64, 40, 18, 22, 3, GRIS, GRIS_OSCURO, 2.0),
            R(84, 42, 16, 18, 2, ROJO, ROJO_OSCURO, 2.0),
            *frecha((68, 28), (84, 38), VERDE_OSCURO),
        ],
        "Cinturón de seguridad abrochándose con hebilla roja y metálica.",
        None,
    ),
    "build": (
        "D",
        fondo_sala()
        + [
            R(36, 54, 24, 20, 2, ROJO, ROJO_OSCURO, 2.0),
            R(60, 54, 24, 20, 2, AZUL, AZUL_OSCURO, 2.0),
            R(48, 34, 24, 20, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(98, 32, 24, 20, 2, VERDE, VERDE_OSCURO, 2.0),
            *frecha((110, 54), (92, 54), VERDE_OSCURO),
        ],
        "Bloques apilándose unos sobre otros para construir una estructura.",
        None,
    ),
    "build high": (
        "D",
        fondo_sala()
        + [
            R(64, 62, 32, 14, 2, AZUL, AZUL_OSCURO, 1.8),
            R(64, 48, 32, 14, 2, VERDE, VERDE_OSCURO, 1.8),
            R(64, 34, 32, 14, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(64, 20, 32, 14, 2, ROJO, ROJO_OSCURO, 1.8),
            *frecha((114, 70), (114, 18), ROJO),
        ],
        "Torre muy alta de bloques con gran flecha vertical hacia arriba.",
        None,
    ),
    "builder": (
        "D",
        fondo_prado()
        + [
            *nino_busto(74, 42, camisa=(NARANJA, NARANJA_OSCURO)),
            F("M62 38 C64 24 84 24 86 38 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            R(56, 36, 36, 5, 2, AMARILLO_OSCURO),
            R(100, 58, 22, 14, 2, ROJO, ROJO_OSCURO, 1.8),
            R(106, 44, 22, 14, 2, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Albañil con casco amarillo colocando ladrillos rojos.",
        None,
    ),
    "bumpy ride": (
        "D",
        fondo_cielo()
        + [
            L("M0 78 Q20 66 40 78 Q60 66 80 78 Q100 66 120 78 Q140 66 160 78", BARRO, 4.5),
            P([(56, 58), (98, 52), (96, 36), (60, 42)], ROJO, ROJO_OSCURO, 2.0),
            E(64, 62, 6, 6, NEGRO),
            E(92, 58, 6, 6, NEGRO),
            L("M66 30 Q78 20 90 28", AZUL_OSCURO, 2.0),
        ],
        "Cochecito dando saltos sobre un camino ondulado lleno de baches.",
        None,
    ),
    "buoy": (
        "D",
        fondo_mar()
        + [
            R(62, 54, 36, 12, 4, ROJO, ROJO_OSCURO, 2.0),
            P([(70, 54), (90, 54), (86, 26), (74, 26)], BLANCO, ROJO_OSCURO, 1.8),
            R(73, 36, 14, 8, 1, ROJO),
            E(80, 22, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Boya marítima roja y blanca flotando sobre las olas del mar.",
        None,
    ),
    "buoyant": (
        "D",
        fondo_mar()
        + [
            R(0, 52, 160, 48, 0, AGUA, AGUA_OSCURO, 2.0),
            *pelota_prop(80, 46, 15, AMARILLO, AMARILLO_OSCURO),
            *frecha((110, 56), (110, 32), VERDE_OSCURO),
        ],
        "Pelota ligera flotando muy arriba sobre la superficie del agua.",
        None,
    ),
    "bury": (
        "D",
        fondo_cielo("#fef3c7")
        + [
            R(0, 68, 160, 32, 0, "#fde68a", "#d97706", 2.0),
            F("M44 74 C52 46 108 46 116 74 Z", "#f59e0b", "#b45309", 2.0),
            R(64, 28, 10, 28, 3, AZUL, AZUL_OSCURO, 1.8),
            R(86, 28, 10, 28, 3, AZUL, AZUL_OSCURO, 1.8),
            *frecha((36, 48), (60, 58), ROJO),
        ],
        "Piernas con los pies enterrados bajo un montículo de arena dorada.",
        None,
    ),
    "busy harbour": (
        "D",
        fondo_mar()
        + [
            R(12, 48, 36, 20, 2, MADERA, MADERA_OSCURA, 2.0),
            L("M22 48 L22 18 L52 18 M48 18 L48 32", AMARILLO_OSCURO, 3.0),
            R(41, 32, 14, 10, 2, NARANJA, NARANJA_OSCURO, 1.6),
            P([(62, 56), (98, 56), (92, 68), (68, 68)], ROJO, ROJO_OSCURO, 1.8),
            L("M80 56 L80 38", MADERA_OSCURA, 2.0),
            P([(80, 40), (92, 48), (80, 52)], BLANCO, GRIS_OSCURO, 1.4),
            R(110, 46, 36, 18, 3, AZUL, AZUL_OSCURO, 1.8),
            P([(116, 46), (138, 46), (132, 36), (122, 36)], BLANCO, AZUL_OSCURO, 1.6),
            R(124, 30, 6, 7, 1, GRIS_OSCURO),
        ],
        "Puerto activo con grúa en el muelle y barcos entrando y saliendo.",
        None,
    ),
    "buttercup": (
        "D",
        fondo_prado()
        + [
            L("M80 78 L80 44", VERDE_OSCURO, 3.0),
            *[E(80 + 13 * math.cos(math.radians(i * 72 - 18)), 38 + 13 * math.sin(math.radians(i * 72 - 18)), 8, 8, AMARILLO, AMARILLO_OSCURO, 1.6) for i in range(5)],
            E(80, 38, 6, 6, DORADO, NARANJA_OSCURO, 1.5),
        ],
        "Flor amarilla brillante botón de oro de cinco pétalos sobre su tallo.",
        None,
    ),
    "button": (
        "D",
        fondo_sala()
        + [
            R(36, 22, 88, 62, 6, AZUL, AZUL_OSCURO, 2.2),
            L("M80 22 L80 84", AZUL_OSCURO, 2.2),
            E(80, 42, 9, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(77, 40, 1.4, 1.4, TINTA),
            E(83, 40, 1.4, 1.4, TINTA),
            E(77, 44, 1.4, 1.4, TINTA),
            E(83, 44, 1.4, 1.4, TINTA),
            E(80, 66, 9, 9, BLANCO, GRIS_OSCURO, 1.8),
            R(86, 63, 12, 6, 3, ROJO),
        ],
        "Camisa azul con botones blancos de cuatro agujeros y ojal.",
        None,
    ),
    "button nose": (
        "D",
        fondo_sala()
        + [
            E(56, 30, 9, 9, TIERRA_CLARA, BARRO, 2.0),
            E(104, 30, 9, 9, TIERRA_CLARA, BARRO, 2.0),
            E(80, 50, 26, 24, TIERRA_CLARA, BARRO, 2.2),
            E(80, 56, 12, 9, "#fef3c7", BARRO, 1.4),
            E(70, 42, 2.4, 2.6, TINTA),
            E(90, 42, 2.4, 2.6, TINTA),
            E(80, 53, 5.5, 5.5, NEGRO),
            E(78.2, 51.5, 1.0, 1.0, BLANCO),
            E(81.8, 51.5, 1.0, 1.0, BLANCO),
            E(78.2, 54.5, 1.0, 1.0, BLANCO),
            E(81.8, 54.5, 1.0, 1.0, BLANCO),
            L("M74 60 Q80 65 86 60", BARRO, 1.6),
        ],
        "Cara alegre destacando una naricita redonda como un botón.",
        None,
    ),
    "buy bread": (
        "D",
        fondo_mesa()
        + [
            E(98, 56, 26, 14, TIERRA_CLARA, BARRO, 2.2),
            L("M86 50 L92 60 M98 48 L104 58 M110 50 L116 60", BARRO, 1.8),
            E(42, 48, 10, 10, DORADO, AMARILLO_OSCURO, 2.0),
            *frecha((54, 48), (72, 52), VERDE_OSCURO),
        ],
        "Moneda dorada ofrecida a cambio de una hogaza de pan recién hecho.",
        None,
    ),
    "buzz": (
        "D",
        fondo_prado()
        + [
            E(94, 44, 13, 9, AMARILLO, NEGRO, 2.0),
            L("M90 36 L90 52 M98 36 L98 52", NEGRO, 3.0),
            E(90, 32, 6, 8, BLANCO, GRIS_OSCURO, 1.4),
            E(98, 32, 6, 8, BLANCO, GRIS_OSCURO, 1.4),
            L("M24 62 Q44 34 62 56 Q72 68 80 48", NEGRO, 1.8),
        ],
        "Abeja volando en bucle dejando estela zumbante tras de sí.",
        None,
    ),
    "calm down": (
        "D",
        fondo_cielo("#dbeafe")
        + [
            E(80, 52, 34, 34, "#eff6ff", AZUL, 1.6),
            *nino_busto(80, 42, camisa=(VERDE, VERDE_OSCURO), ojos="cerrados"),
            *frecha((40, 36), (40, 62), AZUL_OSCURO),
            *frecha((120, 36), (120, 62), AZUL_OSCURO),
        ],
        "Niño sereno rodeado de halo suave bajando los hombros para calmarse.",
        None,
    ),
    "campsite": (
        "D",
        fondo_prado()
        + [
            P([(34, 74), (66, 28), (98, 74)], NARANJA, NARANJA_OSCURO, 2.2),
            P([(56, 74), (66, 48), (76, 74)], NEGRO),
            P([(114, 74), (126, 30), (138, 74)], VERDE_OSCURO),
            F("M106 74 C104 64 112 58 114 50 C120 58 124 64 120 74 Z", ROJO),
        ],
        "Tienda de campaña naranja acampada junto a pinos y fogata.",
        None,
    ),
    "cannon": (
        "D",
        fondo_prado()
        + [
            P([(50, 52), (108, 34), (112, 46), (56, 66)], GRIS_OSCURO, NEGRO, 2.2),
            E(56, 66, 13, 13, MADERA, MADERA_OSCURA, 2.4),
            E(56, 66, 4, 4, NEGRO),
            E(122, 34, 6, 6, "#fde047", NARANJA_OSCURO, 1.6),
        ],
        "Cañón oscuro de rueda de madera apuntando hacia lo alto.",
        None,
    ),
    "captain": (
        "D",
        fondo_mar()
        + [
            E(80, 56, 22, 22, MADERA, MADERA_OSCURA, 2.6),
            E(80, 56, 14, 14, "#e0f2fe", MADERA_OSCURA, 2.0),
            L("M52 56 L108 56 M80 28 L80 84 M60 36 L100 76 M100 36 L60 76", MADERA_OSCURA, 2.8),
            R(58, 18, 44, 12, 4, BLANCO, AZUL_OSCURO, 2.0),
            R(62, 28, 36, 5, 2, AZUL_OSCURO),
        ],
        "Gorra blanca de capitán sobre un timón de madera de barco.",
        None,
    ),
    "careful with nature": (
        "D",
        fondo_prado()
        + [
            F("M64 70 L96 70 L90 58 L70 58 Z", TIERRA, BARRO, 1.8),
            L("M80 62 L80 42", VERDE_OSCURO, 2.6),
            F("M80 44 Q64 36 66 48 Q74 52 80 44 Z", VERDE, VERDE_OSCURO, 1.5),
            F("M80 44 Q96 36 94 48 Q86 52 80 44 Z", VERDE, VERDE_OSCURO, 1.5),
            E(54, 62, 11, 7, PEL, PELB, 1.8),
            E(106, 62, 11, 7, PEL, PELB, 1.8),
        ],
        "Dos manos ahuecadas cuidando con delicadeza un brote verde.",
        None,
    ),
    "careful with the egg": (
        "D",
        fondo_mesa()
        + [
            E(80, 48, 16, 20, "#fef3c7", MADERA_OSCURA, 2.2),
            E(56, 58, 12, 8, PEL, PELB, 2.0),
            E(104, 58, 12, 8, PEL, PELB, 2.0),
            *frecha((52, 34), (62, 44), VERDE_OSCURO),
            *frecha((108, 34), (98, 44), VERDE_OSCURO),
        ],
        "Manos sosteniendo un huevo entero con mucho cuidado.",
        None,
    ),
    "carrot stick": (
        "D",
        fondo_mesa()
        + plato_prop(80, 62, 32)
        + [
            P([(58, 56), (92, 46), (94, 52), (60, 62)], NARANJA, NARANJA_OSCURO, 1.6),
            P([(62, 64), (98, 54), (100, 60), (64, 70)], NARANJA, NARANJA_OSCURO, 1.6),
            P([(68, 70), (102, 62), (104, 67), (70, 75)], NARANJA, NARANJA_OSCURO, 1.6),
        ],
        "Palitos frescos de zanahoria naranja servidos sobre plato blanco.",
        None,
    ),
    "catch the frisbee": (
        "D",
        fondo_prado()
        + [
            *nino((54, 28), (54, 40), (54, 58), [[(68, 36)], [(76, 44)]], [[(48, 78)], [(60, 78)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            E(112, 34, 15, 5, ROJO, ROJO_OSCURO, 2.0),
            *frecha((104, 42), (82, 38), AZUL_OSCURO),
        ],
        "Niño estirando ambas manos para atrapar un disco rojo que vuela.",
        None,
    ),
    "celebrate as a team": (
        "D",
        fondo_sala()
        + nino_busto(48, 44, camisa=(ROJO, ROJO_OSCURO), brazos_arriba=True)
        + nino_busto(80, 38, camisa=(AMARILLO, AMARILLO_OSCURO), brazos_arriba=True)
        + nino_busto(112, 44, camisa=(AZUL, AZUL_OSCURO), brazos_arriba=True)
        + [_estrella(64, 18, 6, 2.5), _estrella(96, 18, 6, 2.5, ROJO, ROJO_OSCURO)],
        "Tres niños chocando y alzando manos en equipo celebrando juntos.",
        None,
    ),
    "certificate": (
        "D",
        fondo_mesa()
        + [
            R(40, 24, 80, 52, 4, "#fef9c3", MADERA_OSCURA, 2.2),
            L("M52 38 L108 38 M52 48 L96 48", GRIS_OSCURO, 2.4),
            E(100, 62, 8, 8, ROJO, ROJO_OSCURO, 1.8),
            P([(96, 68), (92, 82), (100, 76)], ROJO),
            P([(104, 68), (108, 82), (100, 76)], ROJO),
        ],
        "Diploma o certificado oficial con sello rojo y cintas colgantes.",
        None,
    ),
    "change over time": (
        "D",
        fondo_prado()
        + [
            *semilla_prop(26, 52, 22),
            *frecha((52, 60), (64, 60), AZUL_OSCURO),
            L("M78 72 L78 52", VERDE_OSCURO, 2.6),
            E(72, 54, 6, 4, VERDE, VERDE_OSCURO, 1.4),
            E(84, 54, 6, 4, VERDE, VERDE_OSCURO, 1.4),
            *frecha((94, 60), (106, 60), AZUL_OSCURO),
            L("M122 72 L122 36", VERDE_OSCURO, 3.0),
            E(122, 32, 11, 11, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(122, 32, 5, 5, BARRO),
        ],
        "Tres etapas mostrando el crecimiento de semilla a brote y flor.",
        None,
    ),
    "channel": (
        "D",
        fondo_prado()
        + [
            R(0, 64, 160, 36, 0, "#fde68a", "#d97706", 1.8),
            P([(52, 34), (108, 34), (124, 96), (36, 96)], AGUA, AGUA_OSCURO, 2.2),
            L("M68 46 L62 84 M92 46 L98 84", BLANCO, 1.8),
        ],
        "Canal estrecho de agua azul excavado entre dos orillas de arena.",
        None,
    ),
    "chapel": (
        "D",
        fondo_prado()
        + [
            R(48, 42, 64, 34, 2, "#f8fafc", GRIS_OSCURO, 2.2),
            P([(42, 42), (80, 18), (118, 42)], TIERRA_CLARA, BARRO, 2.2),
            R(72, 10, 16, 12, 2, "#f8fafc", GRIS_OSCURO, 1.8),
            E(80, 16, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.4),
            F("M72 76 L72 58 Q80 50 88 58 L88 76 Z", MADERA, MADERA_OSCURA, 1.8),
        ],
        "Pequeña capilla blanca de pueblo con campanario arriba y puerta en arco.",
        None,
    ),
    "cheek to cheek": (
        "D",
        fondo_sala()
        + [
            E(68, 48, 16, 16, PEL, PELB, 2.0),
            E(94, 48, 16, 16, PEL, PELB, 2.0),
            E(64, 46, 1.8, 2.2, TINTA),
            E(98, 46, 1.8, 2.2, TINTA),
            L("M62 55 Q68 59 74 55", "#9a3412", 1.6),
            L("M88 55 Q94 59 100 55", "#9a3412", 1.6),
            E(79, 51, 4, 3, "#fca5a5"),
        ],
        "Dos caras sonrientes pegando suavemente mejilla con mejilla.",
        None,
    ),
    "chestnut tree": (
        "D",
        fondo_prado()
        + [
            R(72, 46, 16, 30, 3, BARRO),
            E(80, 32, 30, 22, VERDE, VERDE_OSCURO, 2.2),
            E(66, 34, 5, 5, TIERRA_CLARA, BARRO, 1.5),
            E(92, 30, 5, 5, TIERRA_CLARA, BARRO, 1.5),
            E(82, 42, 5, 5, TIERRA_CLARA, BARRO, 1.5),
        ],
        "Árbol castaño de copa frondosa con castañas marrones en las ramas.",
        None,
    ),
    "chew on": (
        "D",
        fondo_sala()
        + bebe_sentado(72, 50, (ROSA, ROSA_OSCURO))
        + [
            E(96, 52, 10, 10, AZUL, AZUL_OSCURO, 3.0),
            E(96, 52, 5, 5, "#fef3c7"),
            *frecha((116, 44), (104, 50), VERDE_OSCURO),
        ],
        "Bebé mordisqueando un anillo mordedor azul seguro y limpio.",
        None,
    ),
    "chirp": (
        "D",
        fondo_prado()
        + [
            E(72, 56, 15, 13, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(82, 42, 10, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
            P([(91, 40), (102, 38), (92, 44)], NARANJA_OSCURO),
            P([(91, 44), (102, 48), (91, 46)], NARANJA_OSCURO),
            E(85, 40, 1.6, 1.6, TINTA),
            L("M106 38 Q112 43 106 48 M112 34 Q120 43 112 52", ROJO, 2.0),
        ],
        "Pollito amarillo con pico abierto piando con ondas de sonido.",
        None,
    ),
    "chop": (
        "D",
        fondo_mesa()
        + [
            R(36, 58, 88, 16, 4, MADERA, MADERA_OSCURA, 2.0),
            R(46, 52, 18, 9, 3, NARANJA, NARANJA_OSCURO, 1.6),
            R(70, 52, 16, 9, 3, NARANJA, NARANJA_OSCURO, 1.6),
            R(92, 52, 14, 9, 3, NARANJA, NARANJA_OSCURO, 1.6),
            R(74, 22, 10, 26, 2, PLATA, GRIS_OSCURO, 1.8),
            R(75, 12, 8, 12, 2, BARRO),
            *frecha((96, 20), (96, 42), ROJO),
        ],
        "Tabla de cortar con zanahoria partida en rodajas y cuchillo bajando.",
        None,
    ),
    "chore": (
        "D",
        fondo_sala()
        + [
            L("M80 14 L80 56", MADERA_OSCURA, 3.6),
            P([(62, 56), (98, 56), (104, 78), (56, 78)], AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M66 64 L64 78 M76 64 L76 78 M86 64 L88 78", BARRO, 1.6),
            *frecha((40, 70), (62, 70), AZUL_OSCURO),
        ],
        "Escoba barriendo el suelo en las tareas de casa.",
        None,
    ),
    "chubby cheeks": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 22, PEL, PELB, 2.2),
            E(60, 54, 10, 9, "#fca5a5", "#f87171", 1.6),
            E(100, 54, 10, 9, "#fca5a5", "#f87171", 1.6),
            E(70, 42, 2.2, 2.6, TINTA),
            E(90, 42, 2.2, 2.6, TINTA),
            L("M74 58 Q80 62 86 58", "#9a3412", 1.8),
        ],
        "Cara risueña con mofletes grandes, redondos y rosados inflados.",
        None,
    ),
    "clap a pattern": (
        "D",
        fondo_sala()
        + _mano(32, 56, 0.35)
        + _mano(44, 56, -0.35)
        + _mano(76, 56, 0.35)
        + _mano(88, 56, -0.35)
        + [
            L("M34 32 L38 38 M44 32 L40 38 M78 32 L82 38 M88 32 L84 38", ROJO, 2.0),
            E(124, 58, 12, 8, ROJO, ROJO_OSCURO, 1.8),
            R(114, 44, 12, 16, 4, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Patrón rítmico visual: dos palmas seguidas de un pisotón de zapato.",
        None,
    ),
    "clap twice": (
        "D",
        fondo_sala()
        + _mano(44, 58, 0.35)
        + _mano(58, 58, -0.35)
        + _mano(100, 58, 0.35)
        + _mano(114, 58, -0.35)
        + [
            L("M44 34 L50 40 M58 34 L52 40", ROJO, 2.2),
            L("M100 34 L106 40 M114 34 L108 40", ROJO, 2.2),
        ],
        "Dos pares iguales de manos aplaudiendo dos veces.",
        None,
    ),
    "class photo": (
        "D",
        fondo_sala()
        + [
            R(28, 18, 104, 64, 4, BLANCO, GRIS_OSCURO, 2.4),
            R(36, 26, 88, 48, 2, "#bae6fd"),
            *nino_busto(52, 44, camisa=(ROJO, ROJO_OSCURO)),
            *nino_busto(80, 44, camisa=(VERDE, VERDE_OSCURO)),
            *nino_busto(108, 44, camisa=(AZUL, AZUL_OSCURO)),
        ],
        "Fotografía escolar enmarcada con tres compañeros posando sonrientes.",
        None,
    ),
    "clean and shiny": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 28, "#e0f2fe", GRIS_OSCURO, 2.4),
            L("M68 42 L88 62 M76 36 L94 54", BLANCO, 2.6),
            _estrella(60, 28, 6, 2, AMARILLO, AMARILLO_OSCURO),
            _estrella(104, 34, 5, 1.8, AMARILLO, AMARILLO_OSCURO),
            R(94, 54, 22, 14, 3, VERDE, VERDE_OSCURO, 1.6),
        ],
        "Espejo brillante destellando limpio junto a un paño verde.",
        None,
    ),
    "cliff nest": (
        "D",
        fondo_cielo()
        + [
            P([(0, 22), (64, 22), (82, 56), (96, 84), (0, 84)], GRIS, GRIS_OSCURO, 2.2),
            E(88, 52, 18, 8, MADERA, BARRO, 2.0),
            E(84, 46, 4, 5, "#fef3c7", GRIS_OSCURO, 1.3),
            E(92, 46, 4, 5, "#fef3c7", GRIS_OSCURO, 1.3),
            R(0, 84, 160, 16, 0, AGUA, AGUA_OSCURO, 1.8),
        ],
        "Nido de ramas con huevos posado en repisa alta de un acantilado.",
        None,
    ),
    "climb aboard": (
        "D",
        fondo_mar()
        + [
            P([(74, 46), (138, 46), (126, 70), (82, 70)], MADERA, MADERA_OSCURA, 2.2),
            L("M36 74 L80 46", TIERRA_CLARA, 4.5),
            *nino((54, 24), (58, 36), (62, 52), [[(74, 40)], [(46, 46)]], [[(56, 66)], [(72, 56)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
        ],
        "Niño subiendo por la pasarela de madera para embarcar en el barco.",
        None,
    ),
    "climb over": (
        "D",
        fondo_prado()
        + [
            R(62, 56, 36, 18, 6, BARRO, NEGRO, 2.0),
            *nino((80, 18), (80, 30), (80, 44), [[(64, 38)], [(96, 38)]], [[(68, 56), (60, 68)], [(92, 56), (100, 68)]], camisa=(VERDE, VERDE_OSCURO)),
            L("M52 24 Q80 6 108 24", ROJO, 2.2),
            P([(110, 24), (102, 20), (104, 28)], ROJO),
        ],
        "Niño pasando por encima de un tronco con flecha en arco.",
        None,
    ),
    "close to me": (
        "D",
        fondo_sala()
        + nino_busto(72, 38, camisa=(AZUL, AZUL_OSCURO))
        + bebe_sentado(90, 50, (ROSA, ROSA_OSCURO))
        + [
            L("M66 54 Q80 62 96 58", PELB, 4.2),
            L("M66 54 Q80 62 96 58", PEL, 2.2),
            *frecha((120, 48), (104, 48), ROJO),
        ],
        "Niño abrazando muy cerquita del pecho al bebé.",
        None,
    ),
    "collect leaves": (
        "D",
        fondo_prado()
        + [
            R(62, 42, 36, 34, 4, TIERRA_CLARA, BARRO, 2.0),
            E(68, 26, 7, 4, NARANJA, BARRO, 1.4),
            E(82, 20, 7, 4, ROJO, ROJO_OSCURO, 1.4),
            E(92, 28, 7, 4, AMARILLO, AMARILLO_OSCURO, 1.4),
            *frecha((80, 30), (80, 44), VERDE_OSCURO),
        ],
        "Hojas de otoño entrando dentro de una bolsa de papel marrón.",
        None,
    ),
    "collect rain": (
        "D",
        fondo_prado()
        + [
            P([(62, 44), (98, 44), (92, 76), (68, 76)], "#e0f2fe", AZUL_OSCURO, 2.2),
            R(68, 60, 24, 16, 2, AGUA),
            *gotas([(72, 20), (84, 26), (78, 36)]),
        ],
        "Vaso colocado fuera recogiendo gotas de lluvia del cielo.",
        None,
    ),
    "comb": (
        "D",
        fondo_sala()
        + [
            R(36, 36, 88, 12, 5, AZUL, AZUL_OSCURO, 2.0),
            *[R(42 + i * 8, 48, 3.5, 22, 1.5, AZUL, AZUL_OSCURO, 1.4) for i in range(10)],
        ],
        "Peine azul de dientes uniformes para peinar el pelo.",
        None,
    ),
    "come here, puppy": (
        "D",
        fondo_prado()
        + [
            *nino_busto(48, 42, camisa=(VERDE, VERDE_OSCURO), mira=1),
            R(98, 56, 26, 14, 5, TIERRA_CLARA, BARRO, 1.8),
            E(94, 50, 8, 8, TIERRA_CLARA, BARRO, 1.8),
            E(91, 50, 3, 5, BARRO),
            *frecha((90, 38), (68, 42), ROJO),
        ],
        "Perrito trotando alegremente hacia quien lo llama con la mano.",
        None,
    ),
    "community": (
        "D",
        fondo_prado()
        + [
            *nino_busto(46, 44, camisa=(ROJO, ROJO_OSCURO)),
            *nino_busto(80, 40, camisa=(AMARILLO, AMARILLO_OSCURO)),
            *nino_busto(114, 44, camisa=(AZUL, AZUL_OSCURO)),
            L("M58 58 L70 54 M90 54 L102 58", PELB, 3.6),
            L("M58 58 L70 54 M90 54 L102 58", PEL, 2.0),
        ],
        "Grupo de tres compañeros unidos de la mano formando comunidad.",
        None,
    ),
    "compare": (
        "D",
        fondo_mesa()
        + [
            F("M44 66 C40 44 58 26 68 38 C72 52 58 66 44 66 Z", VERDE, VERDE_OSCURO, 2.0),
            F("M96 64 C94 52 104 42 110 48 C112 56 104 64 96 64 Z", HERBA, VERDE_OSCURO, 1.8),
            *frecha((72, 48), (88, 48), ROJO),
            *frecha((88, 48), (72, 48), ROJO),
        ],
        "Dos hojas de diferente tamaño colocadas lado a lado para comparar.",
        None,
    ),
    "compost": (
        "D",
        fondo_prado()
        + [
            R(50, 44, 60, 34, 4, MADERA, MADERA_OSCURA, 2.2),
            E(68, 42, 7, 6, ROJO, ROJO_OSCURO, 1.6),
            F("M84 42 Q96 32 104 42 Q94 48 84 42 Z", VERDE, VERDE_OSCURO, 1.5),
            *frecha((80, 20), (80, 34), BARRO),
        ],
        "Cajón de compostaje de madera recibiendo restos de fruta y hojas.",
        None,
    ),
    "condense": (
        "D",
        fondo_cielo("#e0f2fe")
        + [
            E(66, 34, 18, 12, GRIS, GRIS_OSCURO, 1.8),
            E(94, 34, 18, 12, GRIS, GRIS_OSCURO, 1.8),
            E(80, 26, 20, 14, "#cbd5e1", GRIS_OSCURO, 1.8),
            *frecha((44, 34), (58, 34), AZUL_OSCURO),
            *frecha((116, 34), (102, 34), AZUL_OSCURO),
            *gotas([(70, 54), (84, 58), (92, 50)]),
        ],
        "Vapor juntándose arriba para condensarse en nube gris con gotitas.",
        None,
    ),
    "cone": (
        "D",
        fondo_prado()
        + [
            P([(56, 76), (72, 22), (88, 22), (104, 76)], NARANJA, NARANJA_OSCURO, 2.2),
            P([(62, 58), (98, 58), (95, 48), (65, 48)], BLANCO),
            P([(68, 38), (92, 38), (90, 30), (70, 30)], BLANCO),
            R(50, 72, 60, 6, 2, NARANJA_OSCURO),
        ],
        "Cono naranja y blanco de psicomotricidad sobre el suelo.",
        None,
    ),
    "conga line": (
        "D",
        fondo_sala()
        + nino((48, 28), (48, 40), (48, 56), [[(64, 40)], [(38, 46)]], [[(42, 76)], [(56, 74)]], camisa=(ROJO, ROJO_OSCURO), mira=1)
        + nino((80, 28), (80, 40), (80, 56), [[(96, 40)], [(70, 46)]], [[(74, 76)], [(88, 74)]], camisa=(AMARILLO, AMARILLO_OSCURO), mira=1)
        + nino((112, 28), (112, 40), (112, 56), [[(126, 42)], [(102, 46)]], [[(106, 76)], [(120, 74)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
        "Tres niños bailando en fila de conga con manos sobre los hombros.",
        None,
    ),
    "connect": (
        "D",
        fondo_mesa()
        + [
            R(40, 40, 32, 24, 4, AZUL, AZUL_OSCURO, 2.0),
            E(72, 52, 6, 6, AZUL, AZUL_OSCURO, 1.8),
            R(86, 40, 34, 24, 4, ROJO, ROJO_OSCURO, 2.0),
            *frecha((72, 26), (88, 26), VERDE_OSCURO),
        ],
        "Dos piezas de colores acercándose para encajar y conectarse.",
        None,
    ),
    "connect the dots": (
        "D",
        fondo_mesa()
        + [
            L("M80 22 L92 48 L60 36 L100 36", AZUL_OSCURO, 2.2),
            L("M100 36 L68 62 L80 22", GRIS_OSCURO, 1.6),
            E(80, 22, 4, 4, ROJO),
            E(92, 48, 4, 4, ROJO),
            E(60, 36, 4, 4, ROJO),
            E(100, 36, 4, 4, ROJO),
            E(68, 62, 4, 4, ROJO),
        ],
        "Puntos rojos unidos en orden formando una figura con trazos.",
        None,
    ),
    "constellation": (
        "D",
        fondo_noite()
        + [
            L("M34 52 L54 46 L72 50 L86 44 L88 60 L114 62 L120 44 L86 44", "#93c5fd", 1.8),
            _estrella(34, 52, 5, 2),
            _estrella(54, 46, 5, 2),
            _estrella(72, 50, 5, 2),
            _estrella(86, 44, 5, 2),
            _estrella(88, 60, 5, 2),
            _estrella(114, 62, 5, 2),
            _estrella(120, 44, 5, 2),
        ],
        "Constelación de siete estrellas unidas por finas líneas en el cielo nocturno.",
        None,
    ),
    "cook": (
        "D",
        fondo_mesa()
        + [
            R(48, 44, 64, 30, 5, ROJO, ROJO_OSCURO, 2.2),
            L("M96 44 L118 20", MADERA_OSCURA, 4.0),
            E(64, 42, 6, 5, NARANJA, NARANJA_OSCURO, 1.4),
            E(78, 40, 6, 5, VERDE, VERDE_OSCURO, 1.4),
            L("M66 32 Q62 22 68 14 M86 32 Q82 22 88 14", GRIS, 2.0),
        ],
        "Olla roja cocinando verduras con cuchara de madera y vapor.",
        None,
    ),
    "cool to touch": (
        "D",
        fondo_prado()
        + [
            E(80, 62, 28, 15, GRIS, GRIS_OSCURO, 2.2),
            E(76, 44, 10, 6, PEL, PELB, 1.8),
            L("M44 40 Q52 34 60 40 M100 40 Q108 34 116 40", AGUA_OSCURO, 2.0),
            L("M66 30 L74 30 M70 26 L70 34", AZUL_OSCURO, 1.8),
        ],
        "Mano posada sobre una piedra fresca con brisa y frío suave.",
        None,
    ),
    "cotton wool": (
        "D",
        fondo_mesa()
        + [
            F("M44 60 C44 76 116 76 116 60 Z", AZUL, AZUL_OSCURO, 2.0),
            E(62, 50, 12, 10, BLANCO, GRIS_OSCURO, 1.6),
            E(80, 44, 13, 11, BLANCO, GRIS_OSCURO, 1.6),
            E(98, 50, 12, 10, BLANCO, GRIS_OSCURO, 1.6),
        ],
        "Bolitas suaves y esponjosas de algodón blanco en un cuenco azul.",
        None,
    ),
    "cover up": (
        "D",
        fondo_sala()
        + [
            R(54, 24, 14, 28, 4, AZUL, AZUL_OSCURO, 1.8),
            R(92, 24, 14, 28, 4, AZUL, AZUL_OSCURO, 1.8),
            R(36, 44, 88, 34, 6, MORADO, "#5b21b6", 2.2),
            L("M40 56 L120 56 M40 68 L120 68", "#ddd6fe", 2.0),
            *frecha((80, 22), (80, 42), ROJO),
        ],
        "Manta morada cubriendo los pies de la persona tumbada.",
        None,
    ),
    "cover with soil": (
        "D",
        fondo_prado()
        + [
            F("M42 74 C52 48 108 48 118 74 Z", BARRO, NEGRO, 2.0),
            E(80, 64, 5, 7, TIERRA_CLARA, AMARILLO_OSCURO, 1.4),
            E(54, 42, 10, 6, PEL, PELB, 1.6),
            E(106, 42, 10, 6, PEL, PELB, 1.6),
            *frecha((64, 38), (74, 50), TIERRA_CLARA),
            *frecha((96, 38), (86, 50), TIERRA_CLARA),
        ],
        "Dos manos echando tierra oscura sobre una semilla en el huerto.",
        None,
    ),
    "crackly": (
        "D",
        fondo_mesa()
        + [
            P([(48, 38), (72, 26), (98, 32), (112, 54), (92, 72), (56, 68)], "#fde68a", MADERA_OSCURA, 2.0),
            L("M62 42 L84 56 L96 42 M66 60 L84 56", MADERA_OSCURA, 1.8),
            L("M40 28 L48 34 M118 28 L110 34 M120 62 L110 58", ROJO, 2.0),
        ],
        "Papel o lámina arrugada con pliegues marcados y líneas crujientes.",
        None,
    ),
    "crane": (
        "D",
        fondo_cielo()
        + [
            R(0, 76, 160, 24, 0, HERBA, VERDE_OSCURO, 1.6),
            R(44, 24, 12, 52, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(36, 20, 88, 10, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M110 30 L110 50", NEGRO, 2.2),
            R(100, 50, 20, 14, 2, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Grúa amarilla alta levantando una carga roja colgante.",
        None,
    ),
}

# ── Piezas auditadas sin base visual clara (R∞.3) ───────────────────────────
SIN_BASE: dict[str, str] = {
    # De `move` (14)
    "nimble": "Adjetivo abstracto de agilidad sin objeto único ni gesto distinguible.",
    "pastel": "Homónimo con tarta; el matiz cromático suave no se distingue de colores sin texto.",
    "play": "Verbo genérico sin objeto único; prohíben rellenos genéricos en O-20261111-4.",
    "poem": "Género literario basado en texto; indistinguible de libro o cuento sin palabras.",
    "slow down": "Gradación temporal relativa sin objeto propio distinguible de parar o caminar.",
    "small and quick": "Pareja de adjetivos abstractos sin referente visual único.",
    "soft and slow": "Pareja de adjetivos sensoriales/temporales sin objeto propio.",
    "speedy": "Adjetivo de rapidez sin objeto único (reduntante con rápido/correr/coche).",
    "swirly": "Adjetivo derivado idéntico visualmente al verbo `swirl` ya cubierto.",
    "tell a dream": "Acción narrativa verbal de contar un sueño sin imagen objetiva inequívoca.",
    "tell a story": "Acción verbal de narrar indistinguible de leer libro sin texto.",
    "thick": "Consistencia espesa de alimento difícil de distinguir de crema/cuenco sin contexto.",
    "warm-up exercise": "Duplicado directo de `warm up your body` en el mismo grupo `move`.",
    "wiggly": "Adjetivo abstracto de inquietud corporal sin referente único.",
    # De `present_object` bloque 1 (43)
    "act it out": "Verbo abstracto de dramatización narrativa sin objeto único.",
    "alive": "Concepto abstracto de estar vivo sin pictograma único no ambiguo.",
    "babble": "Sonido vocal puro de bebé sin objeto visual representable sin texto.",
    "bee rhymes with tree": "Regla fonética de rima en inglés que depende por entero de las palabras habladas.",
    "best moment": "Valoración subjetiva abstracta sin referente visual concreto.",
    "blow a raspberry": "Juego vocal/táctil con la boca sin representación visual clara e infantilmente nítida.",
    "bottom": "Parte corporal privada mejor evitada como lámina ilustrada infantil.",
    "bouncy": "Adjetivo redundante con `bounce` y `bounce up and down` ya cubiertos.",
    "brackish": "Sabor químico de agua salobre indistinguible visualmente del agua normal.",
    "brave": "Rasgo abstracto de carácter sin gesto inequívoco sin texto.",
    "breathe calmly": "Variante redundante idéntica visualmente a `breathe`.",
    "breathe in slowly": "Variante redundante idéntica visualmente a `breathe in, breathe out`.",
    "breathe slowly": "Variante redundante idéntica visualmente a `breathe`.",
    "building blocks": "Duplicado exacto de `blocks` en la misma tanda.",
    "bunch of grapes": "Duplicado de `grapes` ya cubierto en el banco curado.",
    "buzz, buzz": "Onomatopeya sonora duplicada de `buzz` ya cubierto.",
    "calmer": "Comparativo abstracto redundante con `calm down`.",
    "can i have more peas": "Frase conversacional de petición sin escena única distinguible de guisantes.",
    "can i have one": "Pregunta conversacional genérica sin objeto propio.",
    "can i keep it": "Pregunta conversacional posesiva sin referente único.",
    "can i try some": "Pregunta conversacional de probar sin referente único.",
    "can you help me build": "Pregunta conversacional cooperativa sin objeto distinto de `build`.",
    "can you see the plough": "Pregunta conversacional redundante con constelación/carro.",
    "can you write your name": "Pregunta ligada a escritura y texto propio del niño.",
    "caring": "Valor afectivo abstracto sin símbolo único no ambiguo.",
    "challenge": "Sustantivo abstracto de reto sin objeto concreto universal.",
    "character": "Concepto narrativo abstracto de personaje sin referente único.",
    "choose": "Verbo mental de elección sin gesto único distinguible de señalar.",
    "choose together": "Variante abstracta de decisión colectiva sin referente visual claro.",
    "chubby": "Adjetivo corporal subjetivo sin referente claro no ambiguo.",
    "class charter": "Norma escrita de clase que depende de texto firmado.",
    "clear table": "Indistinguible visualmente de `table` sin contexto verbal.",
    "coax": "Verbo afectivo de voz dulce sin imagen objetiva distinguible.",
    "come": "Verbo direccional abstracto sin objeto concreto único.",
    "comfy": "Sensación subjetiva de comodidad sin escena única distinta de descanso.",
    "comical": "Adjetivo abstracto de gracia sin referente único no estereotipado.",
    "communicate": "Verbo comunicativo abstracto sin símbolo claro no textual.",
    "compare results": "Duplicado abstracto de `compare` ligado a resultados.",
    "confident": "Estado psicológico interno sin gesto único inequívoco.",
    "considerate": "Rasgo moral abstracto de espera atenta sin objeto propio.",
    "content": "Estado emocional interno indistinguible de sonrisa genérica.",
    "continue": "Verbo abstracto de continuidad sin objeto visual propio.",
    "coo": "Sonido vocal puro de bebé sin objeto visual representable.",
}
