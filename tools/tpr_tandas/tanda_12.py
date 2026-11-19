#!/usr/bin/env python3
"""Tanda 12 TPR (P2.94): bloques `scrunch`..`weather chart`.

Cubre exactamente 200 piezas revisadas + 107 auditadas sin base (`SIN_BASE`):
- Directas Fluent Emoji Flat (3): `tired`, `triangle`, `upside-down`.
- Escenas propias estilo Lúa D (197): `scrunch` .. `weather chart`.

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
    caja_prop,
    charco_prop,
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
    nino_caminando,
    nino_corriendo,
    nino_saltando,
    notas_col,
    nube_pensar,
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
    "tired": ("Tired face", "U", "Cara cansada cerrando los ojos con gesto de fatiga."),
    "triangle": ("Red triangle", "U", "Triángulo rojo geométrico de tres lados."),
    "upside-down": ("Upside-down face", "U", "Cara girada completamente del revés."),
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


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = {
    "scrunch": (
        "D",
        fondo_mesa()
        + [
            F("M64 40 L78 32 L92 38 L96 52 L84 64 L68 60 L60 48 Z", BLANCO, GRIS_OSCURO, 2.0),
            L("M68 44 L84 52 M78 38 L74 56", GRIS_OSCURO, 1.4),
            E(48, 50, 11, 8, PEL, PELB, 2.0),
            E(112, 50, 11, 8, PEL, PELB, 2.0),
            *frecha((30, 50), (44, 50), AZUL_OSCURO),
            *frecha((130, 50), (116, 50), AZUL_OSCURO),
        ],
        "Dos manos estrujando una hoja de papel hecha bola.",
        None,
    ),
    "seabed": (
        "D",
        fondo_mar()
        + [
            F("M10 74 Q80 66 150 74 L150 94 L10 94 Z", "#fde68a", BARRO, 1.8),
            E(46, 76, 8, 5, GRIS, GRIS_OSCURO, 1.6),
            _estrella(106, 76, 9, 4, NARANJA, NARANJA_OSCURO),
            *pompas([(62, 52, 4), (72, 38, 4), (94, 46, 4)]),
        ],
        "Fondo arenoso del mar con piedra, estrella de mar y burbujas.",
        None,
    ),
    "seagrass": (
        "D",
        fondo_mar()
        + [
            L("M44 84 Q38 64 46 48 Q52 34 44 22", VERDE, 4.6),
            L("M66 84 Q72 60 64 42 Q58 28 68 18", HERBA, 4.6),
            L("M94 84 Q88 62 96 44 Q102 30 92 20", VERDE, 4.6),
            L("M116 84 Q122 64 114 48 Q108 34 118 22", HERBA, 4.6),
        ],
        "Pradera submarina de altas cintas verdes de hierba marina.",
        None,
    ),
    "seat belt on": (
        "D",
        fondo_sala()
        + [
            R(50, 26, 60, 58, 8, AZUL, AZUL_OSCURO, 2.2),
            *nino_busto(80, 42, (ROJO, ROJO_OSCURO)),
            L("M56 38 L104 74", TINTA, 6.0),
            R(74, 52, 12, 10, 2, PLATA, GRIS_OSCURO, 1.6),
        ],
        "Niño sentado con el cinturón de seguridad cruzado por el pecho.",
        None,
    ),
    "seed in the soil": (
        "D",
        fondo_prado()
        + [
            R(24, 62, 112, 26, 3, BARRO, NEGRO, 2.0),
            *semilla_prop(68, 22, 24),
            *frecha((80, 44), (80, 62), VERDE_OSCURO),
            E(80, 72, 6, 4, TIERRA_CLARA, BARRO, 1.5),
        ],
        "Semilla cayendo dentro de un agujero en la tierra marrón.",
        None,
    ),
    "send a postcard": (
        "D",
        fondo_cielo()
        + [
            R(92, 26, 38, 54, 6, ROJO, ROJO_OSCURO, 2.2),
            R(100, 38, 22, 5, 2, TINTA),
            R(26, 40, 36, 24, 2, BLANCO, AZUL_OSCURO, 1.8),
            R(50, 44, 8, 8, 1, NARANJA),
            *frecha((64, 50), (96, 42), VERDE_OSCURO),
        ],
        "Postal entrando por la ranura del buzón rojo de correos.",
        None,
    ),
    "sensory ball": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 22, 22, MORADO, "#5b21b6", 2.2),
            E(64, 34, 4, 4, MORADO, "#5b21b6", 1.4),
            E(80, 26, 4, 4, MORADO, "#5b21b6", 1.4),
            E(96, 34, 4, 4, MORADO, "#5b21b6", 1.4),
            E(104, 50, 4, 4, MORADO, "#5b21b6", 1.4),
            E(96, 66, 4, 4, MORADO, "#5b21b6", 1.4),
            E(80, 74, 4, 4, MORADO, "#5b21b6", 1.4),
            E(64, 66, 4, 4, MORADO, "#5b21b6", 1.4),
            E(56, 50, 4, 4, MORADO, "#5b21b6", 1.4),
        ],
        "Pelota sensorial morada cubierta de bultitos blandos.",
        None,
    ),
    "separate waste": (
        "D",
        fondo_sala()
        + [
            F("M34 44 L68 44 L64 80 L38 80 Z", AZUL, AZUL_OSCURO, 2.0),
            F("M92 44 L126 44 L122 80 L96 80 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
            R(44, 24, 14, 10, 1, BLANCO, GRIS_OSCURO, 1.4),
            *frecha((51, 36), (51, 44), AZUL_OSCURO),
            R(104, 18, 10, 18, 3, "#bae6fd", AGUA_OSCURO, 1.5),
            *frecha((109, 36), (109, 44), AMARILLO_OSCURO),
        ],
        "Papel al contenedor azul y botella de plástico al contenedor amarillo.",
        None,
    ),
    "sequence": (
        "D",
        fondo_mesa()
        + [
            R(22, 32, 28, 36, 3, BLANCO, AZUL_OSCURO, 1.8),
            E(36, 54, 5, 6, BARRO),
            R(66, 32, 28, 36, 3, BLANCO, AZUL_OSCURO, 1.8),
            L("M80 62 L80 46", VERDE_OSCURO, 2.4),
            E(75, 48, 5, 3, VERDE),
            R(110, 32, 28, 36, 3, BLANCO, AZUL_OSCURO, 1.8),
            L("M124 62 L124 44", VERDE_OSCURO, 2.4),
            E(124, 40, 7, 7, ROJO, ROJO_OSCURO, 1.4),
            *frecha((50, 50), (64, 50), TINTA),
            *frecha((94, 50), (108, 50), TINTA),
        ],
        "Tres tarjetas en secuencia: semilla, brote verde y flor roja.",
        None,
    ),
    "serve": (
        "D",
        fondo_mesa()
        + [
            *plato_prop(54, 58, 16),
            *plato_prop(106, 58, 16),
            R(68, 24, 24, 14, 4, NARANJA, NARANJA_OSCURO, 1.8),
            *cuchara_prop(74, 28, 28),
            *frecha((72, 42), (56, 52), VERDE_OSCURO),
            *frecha((88, 42), (104, 52), VERDE_OSCURO),
        ],
        "Olla y cuchara sirviendo comida en dos platos de la mesa.",
        None,
    ),
    "set a timer": (
        "D",
        fondo_sala()
        + [
            E(80, 52, 24, 24, BLANCO, ROJO_OSCURO, 2.4),
            R(74, 22, 12, 6, 2, GRIS, GRIS_OSCURO, 1.8),
            L("M80 52 L80 34 M80 52 L94 52", ROJO_OSCURO, 2.6),
            L("M98 30 Q108 38 106 50", AZUL_OSCURO, 2.0),
            P([(102, 48), (108, 53), (110, 46)], AZUL_OSCURO),
        ],
        "Temporizador redondo rojo con flecha girando para ajustar el tiempo.",
        None,
    ),
    "set of weights": (
        "D",
        fondo_mesa()
        + [
            F("M30 68 L48 68 L45 48 L33 48 Z", GRIS_OSCURO, TINTA, 1.8),
            R(35, 43, 8, 5, 2, GRIS_OSCURO),
            F("M64 68 L90 68 L85 40 L69 40 Z", GRIS_OSCURO, TINTA, 2.0),
            R(72, 34, 10, 6, 2, GRIS_OSCURO),
            F("M106 68 L138 68 L132 32 L112 32 Z", GRIS_OSCURO, TINTA, 2.2),
            R(116, 25, 12, 7, 2, GRIS_OSCURO),
        ],
        "Juego de tres pesas de hierro ordenadas de menor a mayor.",
        None,
    ),
    "shade": (
        "D",
        fondo_prado()
        + [
            *_sol(132, 20, 9),
            R(52, 46, 12, 34, 2, BARRO, NEGRO, 1.8),
            E(58, 32, 24, 18, VERDE, VERDE_OSCURO, 2.0),
            E(72, 78, 32, 8, "#64748b"),
            *nino((80, 46), (80, 56), (80, 68), [[(70, 60)], [(90, 60)]], [[(76, 78)], [(84, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
        ],
        "Niño resguardado a la sombra fresca debajo de un árbol frondoso.",
        None,
    ),
    "shade card": (
        "D",
        fondo_mesa()
        + [
            R(24, 30, 112, 44, 4, BLANCO, TINTA, 2.0),
            R(32, 36, 22, 32, 2, "#dbeafe", AZUL_OSCURO, 1.4),
            R(58, 36, 22, 32, 2, "#93c5fd", AZUL_OSCURO, 1.4),
            R(84, 36, 22, 32, 2, "#3b82f6", AZUL_OSCURO, 1.4),
            R(110, 36, 22, 32, 2, "#1e3a8a", TINTA, 1.4),
        ],
        "Carta de tonos progresivos desde el azul más claro al más oscuro.",
        None,
    ),
    "shadow": (
        "D",
        fondo_prado()
        + [
            *_sol(32, 22, 9),
            *nino((64, 30), (64, 42), (64, 58), [[(52, 50)], [(76, 50)]], [[(58, 76)], [(70, 76)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            E(104, 78, 34, 6, "#475569"),
            E(126, 74, 8, 5, "#475569"),
        ],
        "Niño de pie al sol proyectando su sombra oscura sobre la hierba.",
        None,
    ),
    "shake hands": (
        "D",
        fondo_sala()
        + [
            *nino((54, 30), (54, 42), (54, 58), [[(42, 50)], [(76, 52)]], [[(48, 78)], [(60, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *nino((106, 30), (106, 42), (106, 58), [[(84, 52)], [(118, 50)]], [[(100, 78)], [(112, 78)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
            E(80, 52, 7, 5, PEL, PELB, 1.6),
            L("M74 42 L86 42 M74 62 L86 62", AZUL_OSCURO, 1.6),
        ],
        "Dos niños estrechándose la mano con cordialidad.",
        None,
    ),
    "shape sorter": (
        "D",
        fondo_sala()
        + [
            R(44, 36, 72, 46, 5, AMARILLO, MADERA_OSCURA, 2.2),
            E(62, 58, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            P([(82, 48), (73, 66), (91, 66)], AZUL, AZUL_OSCURO, 1.8),
            R(96, 50, 14, 14, 1, VERDE, VERDE_OSCURO, 1.8),
            E(62, 22, 7, 7, ROJO, ROJO_OSCURO, 1.6),
            *frecha((62, 30), (62, 44), ROJO_OSCURO),
        ],
        "Caja amarilla encajable con huecos de círculo, triángulo y cuadrado.",
        None,
    ),
    "share": (
        "D",
        fondo_mesa()
        + [
            *nino_busto(48, 36, (AZUL, AZUL_OSCURO)),
            *nino_busto(112, 36, (ROSA, ROSA_OSCURO), mira=-1),
            E(72, 58, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            E(88, 58, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            L("M80 46 L80 68", TINTA, 1.8),
        ],
        "Dos niños compartiendo por la mitad la fruta sobre la mesa.",
        None,
    ),
    "shared blanket": (
        "D",
        fondo_sala()
        + [
            E(64, 38, 9, 9, PEL, PELB, 2.0),
            E(96, 38, 9, 9, PEL, PELB, 2.0),
            R(44, 48, 72, 34, 6, MORADO, "#5b21b6", 2.2),
            L("M48 56 L112 56 M48 72 L112 72", "#c4b5fd", 1.8),
        ],
        "Dos niños tapados juntos bajo la misma manta morada.",
        None,
    ),
    "shelf": (
        "D",
        fondo_sala()
        + [
            R(28, 52, 104, 10, 2, MADERA, MADERA_OSCURA, 2.2),
            P([(42, 62), (42, 72), (52, 62)], MADERA_OSCURA),
            P([(118, 62), (118, 72), (108, 62)], MADERA_OSCURA),
            R(46, 26, 12, 26, 2, ROJO, ROJO_OSCURO, 1.6),
            R(60, 30, 12, 22, 2, AZUL, AZUL_OSCURO, 1.6),
            E(100, 42, 10, 10, VERDE, VERDE_OSCURO, 1.6),
        ],
        "Estante de madera fijado a la pared con libros y pelota encima.",
        None,
    ),
    "shell pieces": (
        "D",
        fondo_prado()
        + [
            P([(38, 62), (56, 46), (62, 68)], "#fef3c7", BARRO, 1.8),
            P([(74, 50), (92, 42), (88, 66), (70, 62)], "#fde68a", BARRO, 1.8),
            P([(102, 54), (122, 58), (112, 72)], "#fef3c7", BARRO, 1.8),
        ],
        "Trozos rotos de cáscara y concha esparcidos.",
        None,
    ),
    "shells in the bag": (
        "D",
        fondo_prado()
        + [
            R(50, 42, 60, 40, 6, TIERRA_CLARA, BARRO, 2.2),
            L("M62 42 C62 24 98 24 98 42", BARRO, 3.0),
            P([(68, 22), (60, 34), (76, 34)], "#fef3c7", BARRO, 1.6),
            P([(92, 22), (84, 34), (100, 34)], "#fde68a", BARRO, 1.6),
            *frecha((80, 18), (80, 40), AZUL_OSCURO),
        ],
        "Conchas marinas entrando dentro de una bolsa de playa.",
        None,
    ),
    "shelter": (
        "D",
        fondo_cielo()
        + [
            *gotas([(28, 20), (132, 22), (46, 16), (114, 16)]),
            P([(42, 42), (80, 22), (118, 42)], ROJO, ROJO_OSCURO, 2.2),
            R(48, 42, 64, 38, 2, MADERA, MADERA_OSCURA, 2.0),
            *nino_busto(80, 56, (VERDE, VERDE_OSCURO)),
        ],
        "Niño resguardado bajo un refugio de madera mientras llueve fuera.",
        None,
    ),
    "shiny paper": (
        "D",
        fondo_mesa()
        + [
            P([(44, 24), (110, 24), (118, 72), (52, 72)], "#fde047", AMARILLO_OSCURO, 2.2),
            _estrella(64, 38, 7, 3, BLANCO, AMARILLO_OSCURO),
            _estrella(102, 54, 7, 3, BLANCO, AMARILLO_OSCURO),
            L("M60 32 L78 62 M76 32 L94 62", BLANCO, 2.2),
        ],
        "Lámina de papel metalizado brillante con reflejos de luz.",
        None,
    ),
    "shorter": (
        "D",
        fondo_mesa()
        + [
            R(30, 34, 100, 12, 3, AZUL, AZUL_OSCURO, 2.0),
            R(30, 58, 46, 12, 3, VERDE, VERDE_OSCURO, 2.0),
            *frecha((96, 64), (78, 64), ROJO_OSCURO),
        ],
        "Dos regletas donde la flecha señala la pieza más corta.",
        None,
    ),
    "shoulder blade": (
        "D",
        fondo_sala()
        + [
            R(56, 36, 48, 46, 10, PEL, PELB, 2.2),
            E(80, 24, 12, 12, BARRO, NEGRO, 2.0),
            P([(62, 44), (76, 48), (68, 64)], NARANJA, ROJO_OSCURO, 1.8),
            P([(98, 44), (84, 48), (92, 64)], NARANJA, ROJO_OSCURO, 1.8),
            *frecha((40, 52), (62, 52), ROJO_OSCURO),
        ],
        "Vista trasera señalando los dos omóplatos en la espalda.",
        None,
    ),
    "shrink": (
        "D",
        fondo_sala()
        + [
            R(26, 26, 40, 40, 5, MORADO, "#5b21b6", 2.2),
            *frecha((70, 46), (96, 46), ROJO_OSCURO),
            R(106, 42, 18, 18, 3, MORADO, "#5b21b6", 2.0),
        ],
        "Bloque morado grande encogiéndose hasta hacerse pequeño.",
        None,
    ),
    "sieve toy": (
        "D",
        fondo_prado()
        + [
            E(80, 44, 28, 10, AMARILLO, AMARILLO_OSCURO, 2.2),
            L("M60 44 L100 44 M66 40 L94 40 M70 48 L90 48", GRIS_OSCURO, 1.4),
            R(108, 41, 20, 6, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(72, 62, 2, 2, "#f59e0b"),
            E(80, 66, 2, 2, "#f59e0b"),
            E(88, 60, 2, 2, "#f59e0b"),
            E(76, 72, 2, 2, "#f59e0b"),
            E(84, 74, 2, 2, "#f59e0b"),
        ],
        "Tamiz amarillo de juguete dejando caer arena fina.",
        None,
    ),
    "silk scarf": (
        "D",
        fondo_cielo()
        + [
            F("M34 36 Q60 18 84 42 Q108 66 130 36 L124 58 Q100 84 76 60 Q52 38 30 58 Z", ROSA, ROSA_OSCURO, 2.0),
            *lineas_viento(24, 24, 24, AZUL_OSCURO),
        ],
        "Pañuelo de seda rosa muy fino ondeando en el aire.",
        None,
    ),
    "silly face": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 26, PEL, PELB, 2.4),
            F("M54 44 C56 18 104 18 106 44 C90 32 70 32 54 44 Z", BARRO),
            E(70, 44, 3.5, 4.5, BLANCO, TINTA, 1.5),
            E(71, 44, 1.5, 2.0, TINTA),
            L("M86 44 Q92 40 96 44", TINTA, 2.2),
            L("M66 58 Q80 68 94 58", "#9a3412", 2.0),
            E(80, 66, 6, 8, ROSA, ROSA_OSCURO, 1.6),
        ],
        "Cara haciendo una mueca divertida guiñando un ojo y sacando la lengua.",
        None,
    ),
    "silly monster": (
        "D",
        fondo_sala()
        + [
            E(80, 52, 24, 26, VERDE, VERDE_OSCURO, 2.2),
            L("M66 28 L60 16 M94 28 L100 16", MORADO, 3.2),
            E(60, 16, 4, 4, MORADO),
            E(100, 16, 4, 4, MORADO),
            E(80, 42, 7, 7, BLANCO, TINTA, 1.8),
            E(80, 42, 3, 3, TINTA),
            L("M66 60 Q80 72 94 60", TINTA, 2.2),
            P([(72, 63), (75, 68), (78, 64)], BLANCO, TINTA, 1.2),
            P([(84, 64), (87, 68), (90, 63)], BLANCO, TINTA, 1.2),
        ],
        "Monstruito verde simpático de un ojo con antenas y gran sonrisa.",
        None,
    ),
    "sink down": (
        "D",
        fondo_mar()
        + [
            E(80, 68, 14, 10, GRIS_OSCURO, TINTA, 2.0),
            *frecha((80, 24), (80, 52), ROJO_OSCURO),
            *pompas([(66, 44, 4), (94, 40, 4)]),
        ],
        "Piedra hundiéndose hasta el fondo del mar con flecha descendente.",
        None,
    ),
    "sink plug": (
        "D",
        fondo_sala()
        + [
            E(80, 68, 28, 12, BLANCO, GRIS_OSCURO, 2.2),
            E(80, 68, 9, 4, GRIS, GRIS_OSCURO, 1.8),
            E(80, 38, 11, 6, NEGRO, TINTA, 2.0),
            R(77, 30, 6, 8, 2, PLATA, GRIS_OSCURO, 1.6),
            L("M80 30 Q94 22 106 38 L106 54", PLATA, 2.2),
            *frecha((80, 46), (80, 62), AZUL_OSCURO),
        ],
        "Tapón negro con cadenita sobre el desagüe del lavabo.",
        None,
    ),
    "sip": (
        "D",
        fondo_mesa()
        + [
            *nino_busto(72, 40, (AZUL, AZUL_OSCURO)),
            R(86, 46, 16, 22, 3, "#e0f2fe", AZUL_OSCURO, 1.8),
            R(88, 54, 12, 12, 1, NARANJA),
            L("M92 54 L82 46", ROJO, 2.4),
        ],
        "Niño dando un sorbo pequeño con pajita de un vaso.",
        None,
    ),
    "sippy cup": (
        "D",
        fondo_mesa()
        + [
            R(62, 38, 36, 40, 7, "#bae6fd", AZUL_OSCURO, 2.2),
            P([(60, 38), (100, 38), (94, 24), (82, 24), (80, 14), (74, 24), (66, 24)], VERDE, VERDE_OSCURO, 2.0),
            L("M62 46 C46 46 46 68 62 68", VERDE_OSCURO, 3.2),
            L("M98 46 C114 46 114 68 98 68", VERDE_OSCURO, 3.2),
        ],
        "Vaso infantil de aprendizaje con dos asas laterales y boquilla.",
        None,
    ),
    "skeleton": (
        "D",
        fondo_noite()
        + [
            E(80, 24, 10, 9, BLANCO, GRIS_OSCURO, 2.0),
            E(76, 23, 2, 2.5, TINTA),
            E(84, 23, 2, 2.5, TINTA),
            L("M80 33 L80 58", BLANCO, 3.2),
            L("M68 40 L92 40 M70 46 L90 46 M72 52 L88 52", BLANCO, 2.6),
            L("M68 38 L54 52 M92 38 L106 52", BLANCO, 3.0),
            L("M74 58 L70 80 M86 58 L90 80", BLANCO, 3.0),
        ],
        "Esqueleto blanco sonriente sobre fondo oscuro nocturno.",
        None,
    ),
    "sleeve": (
        "D",
        fondo_sala()
        + [
            P([(52, 28), (108, 28), (124, 52), (110, 62), (98, 48), (98, 78), (62, 78), (62, 48), (50, 62), (36, 52)], AZUL, AZUL_OSCURO, 2.2),
            *frecha((28, 62), (48, 48), ROJO_OSCURO),
            L("M48 48 L36 52 L50 62", AMARILLO, 2.4),
        ],
        "Jersey azul señalando la manga larga para meter el brazo.",
        None,
    ),
    "slice": (
        "D",
        fondo_mesa()
        + [
            E(68, 58, 18, 12, NARANJA, NARANJA_OSCURO, 2.0),
            E(96, 60, 8, 10, AMARILLO, NARANJA_OSCURO, 1.8),
            E(112, 62, 8, 10, AMARILLO, NARANJA_OSCURO, 1.8),
            R(84, 22, 6, 30, 2, PLATA, GRIS_OSCURO, 1.8),
            R(84, 14, 6, 10, 2, BARRO, NEGRO, 1.6),
            *frecha((98, 24), (98, 42), ROJO_OSCURO),
        ],
        "Cuchillo cortando en rodajas una fruta sobre la mesa.",
        None,
    ),
    "slide": (
        "D",
        fondo_prado()
        + [
            L("M34 32 L120 74", AZUL_OSCURO, 5.0),
            L("M34 32 L34 78", MADERA_OSCURA, 3.2),
            *nino((64, 30), (70, 42), (76, 54), [[(56, 40)], [(86, 40)]], [[(86, 60)], [(94, 58)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *frecha((84, 28), (112, 44), VERDE_OSCURO),
        ],
        "Niño deslizándose cuesta abajo por un tobogán.",
        None,
    ),
    "slide like a penguin": (
        "D",
        fondo_cielo()
        + [
            R(12, 66, 136, 22, 0, "#e0f2fe", AZUL_OSCURO, 1.6),
            E(78, 58, 22, 10, "#1e293b", TINTA, 2.0),
            E(78, 62, 16, 6, BLANCO),
            E(100, 52, 9, 9, "#1e293b", TINTA, 2.0),
            P([(109, 52), (117, 54), (109, 56)], NARANJA),
            *frecha((34, 42), (62, 42), AZUL_OSCURO),
        ],
        "Pingüino deslizándose sobre la barriga por el hielo.",
        None,
    ),
    "slide on ice": (
        "D",
        fondo_cielo()
        + [
            E(80, 74, 54, 12, "#bae6fd", AGUA_OSCURO, 2.0),
            *nino((78, 24), (78, 36), (78, 52), [[(62, 42)], [(94, 42)]], [[(68, 70)], [(90, 68)]], camisa=(MORADO, "#5b21b6"), mira=1),
            *frecha((96, 58), (124, 58), AZUL_OSCURO),
        ],
        "Niño deslizándose con los pies sobre una pista de hielo azul.",
        None,
    ),
    "slippery fish": (
        "D",
        fondo_mar()
        + [
            E(80, 46, 18, 10, NARANJA, NARANJA_OSCURO, 2.0),
            P([(98, 46), (110, 38), (110, 54)], NARANJA, NARANJA_OSCURO, 1.8),
            E(72, 44, 1.8, 1.8, TINTA),
            E(60, 58, 12, 7, PEL, PELB, 1.8),
            E(100, 58, 12, 7, PEL, PELB, 1.8),
            *gotas([(68, 28), (90, 26)]),
            *frecha((80, 32), (80, 18), AZUL_OSCURO),
        ],
        "Pez naranja resbalándose entre las manos con gotitas de agua.",
        None,
    ),
    "slippery soap": (
        "D",
        fondo_sala()
        + [
            R(58, 42, 44, 24, 10, ROSA, ROSA_OSCURO, 2.2),
            *pompas([(46, 30, 4), (62, 24, 4), (104, 28, 4), (114, 46, 4)]),
            L("M48 72 Q80 82 114 68", AZUL_OSCURO, 2.2),
            P([(110, 66), (118, 67), (113, 73)], AZUL_OSCURO),
        ],
        "Pastilla de jabón rosa resbalando rodeada de pompas.",
        None,
    ),
    "slot in": (
        "D",
        fondo_mesa()
        + [
            R(44, 50, 72, 28, 4, MADERA, MADERA_OSCURA, 2.2),
            R(66, 50, 28, 14, 2, TIERRA, MADERA_OSCURA, 1.8),
            R(68, 20, 24, 16, 2, VERDE, VERDE_OSCURO, 2.0),
            *frecha((80, 38), (80, 50), VERDE_OSCURO),
        ],
        "Pieza verde encajando exactamente en el hueco de la base de madera.",
        None,
    ),
    "slow like a snail": (
        "D",
        fondo_prado()
        + [
            F("M44 68 L106 68 Q112 68 112 62 Q104 58 96 62 L52 62 Z", PEL, BARRO, 2.0),
            E(72, 54, 16, 16, NARANJA_OSCURO, BARRO, 2.2),
            E(72, 54, 9, 9, AMARILLO, BARRO, 1.6),
            L("M106 58 L110 48 M112 58 L116 48", BARRO, 1.8),
            L("M24 66 L38 66", VERDE_OSCURO, 1.8),
        ],
        "Caracol avanzando lentamente sobre la hierba verde.",
        None,
    ),
    "slurp": (
        "D",
        fondo_mesa()
        + [
            *nino_busto(76, 36, (VERDE, VERDE_OSCURO)),
            F("M56 58 L96 58 Q92 78 76 78 Q60 78 56 58 Z", BLANCO, AZUL_OSCURO, 2.0),
            L("M72 48 Q74 54 78 58 M76 48 Q80 54 84 58", AMARILLO_OSCURO, 2.2),
        ],
        "Niño sorbiendo fideos largos directamente de un cuenco.",
        None,
    ),
    "smaller": (
        "D",
        fondo_sala()
        + [
            *pelota_prop(50, 52, 22, ROJO, ROJO_OSCURO),
            *pelota_prop(112, 62, 11, VERDE, VERDE_OSCURO),
            *frecha((112, 28), (112, 48), VERDE_OSCURO),
        ],
        "Dos pelotas comparadas señalando la pelota más pequeña.",
        None,
    ),
    "smell the flower": (
        "D",
        fondo_prado()
        + [
            *nino_busto(56, 38, (ROSA, ROSA_OSCURO)),
            L("M104 78 L104 48", VERDE_OSCURO, 3.0),
            E(104, 40, 10, 10, AMARILLO, NARANJA_OSCURO, 1.8),
            E(94, 40, 5, 5, ROSA),
            E(114, 40, 5, 5, ROSA),
            E(104, 30, 5, 5, ROSA),
            L("M88 36 Q78 32 70 38", MORADO, 1.8),
        ],
        "Niño acercándose a oler el aroma de una flor en el prado.",
        None,
    ),
    "smoky": (
        "D",
        fondo_noite()
        + [
            P([(62, 78), (74, 54), (86, 78)], NARANJA, ROJO_OSCURO, 2.0),
            L("M56 80 L104 74 M56 74 L104 80", MADERA_OSCURA, 4.0),
            E(78, 42, 10, 7, GRIS, GRIS_OSCURO, 1.6),
            E(88, 30, 13, 9, GRIS, GRIS_OSCURO, 1.6),
            E(74, 18, 15, 10, "#cbd5e1", GRIS_OSCURO, 1.6),
        ],
        "Hoguera desprendiendo espirales de humo gris hacia arriba.",
        None,
    ),
    "smooth sand": (
        "D",
        fondo_mar()
        + [
            F("M22 64 Q80 54 138 64 L138 86 L22 86 Z", "#fde68a", BARRO, 2.0),
            L("M34 68 L126 68 M42 74 L118 74", AMARILLO_OSCURO, 1.8),
            E(80, 46, 16, 8, PEL, PELB, 2.0),
            *frecha((48, 46), (62, 46), BARRO),
            *frecha((112, 46), (98, 46), BARRO),
        ],
        "Mano alisando la arena de la playa dejándola suave y plana.",
        None,
    ),
    "snail shell": (
        "D",
        fondo_prado()
        + [
            E(80, 52, 24, 22, NARANJA_OSCURO, BARRO, 2.4),
            E(80, 52, 16, 15, "#fdba74", BARRO, 2.0),
            E(80, 52, 8, 7, AMARILLO, BARRO, 1.8),
            E(80, 52, 2.5, 2.5, BARRO),
        ],
        "Concha enrollada en espiral de caracol sobre la hierba.",
        None,
    ),
    "sniff the fruit": (
        "D",
        fondo_mesa()
        + [
            *nino_busto(58, 38, (AMARILLO, AMARILLO_OSCURO)),
            E(104, 54, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            L("M104 42 L106 34", BARRO, 2.0),
            E(110, 36, 4, 2.5, VERDE, VERDE_OSCURO, 1.2),
            L("M90 42 Q80 34 72 40 M92 48 Q82 40 74 46", VERDE_OSCURO, 1.8),
        ],
        "Niño acercándose a oler una manzana fresca sobre la mesa.",
        None,
    ),
    "snorkel": (
        "D",
        fondo_mar()
        + [
            R(48, 42, 44, 20, 7, "#bae6fd", AZUL_OSCURO, 2.2),
            E(60, 52, 8, 7, BLANCO, AZUL_OSCURO, 1.4),
            E(80, 52, 8, 7, BLANCO, AZUL_OSCURO, 1.4),
            L("M96 64 L108 64 L108 20 L118 20", NARANJA, 5.0),
            L("M96 64 L108 64 L108 20 L118 20", NARANJA_OSCURO, 1.6),
            *pompas([(118, 12, 4), (124, 22, 4)]),
        ],
        "Gafas de buceo azules con tubo respirador naranja bajo el agua.",
        None,
    ),
    "soap bar": (
        "D",
        fondo_sala()
        + [
            R(50, 36, 60, 32, 12, ROSA, ROSA_OSCURO, 2.2),
            R(58, 42, 44, 18, 8, "#fbcfe8", ROSA_OSCURO, 1.4),
            *pompas([(40, 26, 4), (118, 28, 4), (112, 68, 4)]),
        ],
        "Pastilla de jabón rosa con relieve ovalado y burbujas.",
        None,
    ),
    "soap pump": (
        "D",
        fondo_sala()
        + [
            R(60, 38, 40, 44, 8, "#bae6fd", AZUL_OSCURO, 2.2),
            R(72, 28, 16, 10, 2, PLATA, GRIS_OSCURO, 1.8),
            L("M80 28 L80 18 L96 18", PLATA, 4.0),
            *gotas([(96, 30)]),
            *frecha((80, 8), (80, 18), AZUL_OSCURO),
        ],
        "Dosificador de jabón líquido apretado arriba echando una gota.",
        None,
    ),
    "soap up": (
        "D",
        fondo_sala()
        + [
            E(68, 54, 15, 10, PEL, PELB, 2.0),
            E(92, 54, 15, 10, PEL, PELB, 2.0),
            E(80, 46, 16, 12, BLANCO, AGUA_OSCURO, 1.6),
            *pompas([(56, 34, 4), (72, 26, 4), (92, 28, 4), (104, 38, 4)]),
        ],
        "Dos manos frotándose llenas de espuma blanca y pompas de jabón.",
        None,
    ),
    "soaring": (
        "D",
        fondo_cielo()
        + [
            E(42, 24, 16, 8, NUBE, NUBE_B, 1.4),
            E(118, 26, 18, 9, NUBE, NUBE_B, 1.4),
            E(80, 46, 12, 6, BARRO, NEGRO, 1.8),
            F("M34 42 Q60 28 80 44 Q100 28 126 42 Q100 48 80 48 Q60 48 34 42 Z", BARRO, NEGRO, 1.8),
            *lineas_viento(44, 62, 36, AZUL_OSCURO),
        ],
        "Ave planeando serenamente alto entre nubes con las alas abiertas.",
        None,
    ),
    "socks on the line": (
        "D",
        fondo_cielo()
        + [
            L("M20 34 L140 34", TINTA, 2.2),
            R(46, 36, 14, 30, 3, ROJO, ROJO_OSCURO, 1.8),
            R(46, 60, 22, 10, 4, ROJO, ROJO_OSCURO, 1.8),
            R(50, 30, 6, 8, 1, MADERA_OSCURA),
            R(94, 36, 14, 30, 3, AZUL, AZUL_OSCURO, 1.8),
            R(94, 60, 22, 10, 4, AZUL, AZUL_OSCURO, 1.8),
            R(98, 30, 6, 8, 1, MADERA_OSCURA),
        ],
        "Par de calcetines de colores colgados con pinzas en la cuerda.",
        None,
    ),
    "sofa": (
        "D",
        fondo_sala()
        + [
            R(34, 34, 92, 30, 8, MORADO, "#5b21b6", 2.2),
            R(26, 48, 14, 28, 5, MORADO, "#5b21b6", 2.0),
            R(120, 48, 14, 28, 5, MORADO, "#5b21b6", 2.0),
            R(40, 56, 80, 18, 4, "#a78bfa", "#5b21b6", 2.0),
            L("M36 76 L36 84 M124 76 L124 84", MADERA_OSCURA, 3.0),
        ],
        "Sofá morado mullido con reposabrazos en el salón.",
        None,
    ),
    "soft toy": (
        "D",
        fondo_sala()
        + [
            E(66, 26, 7, 7, TIERRA_CLARA, BARRO, 1.8),
            E(94, 26, 7, 7, TIERRA_CLARA, BARRO, 1.8),
            E(80, 38, 16, 14, TIERRA_CLARA, BARRO, 2.0),
            E(80, 41, 4, 3, BARRO),
            E(74, 35, 1.5, 1.5, TINTA),
            E(86, 35, 1.5, 1.5, TINTA),
            E(80, 64, 18, 18, TIERRA_CLARA, BARRO, 2.0),
            E(80, 64, 10, 11, "#fde68a"),
            E(62, 58, 7, 5, TIERRA_CLARA, BARRO, 1.8),
            E(98, 58, 7, 5, TIERRA_CLARA, BARRO, 1.8),
        ],
        "Osito de peluche suave de felpa marrón claro.",
        None,
    ),
    "soggy": (
        "D",
        fondo_sala()
        + [
            R(50, 32, 60, 26, 6, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(50, 44, 60, 14, 4, AZUL, AZUL_OSCURO, 1.6),
            *gotas([(58, 66), (74, 72), (90, 68), (104, 74)]),
        ],
        "Esponja completamente empapada soltando gotas gruesas de agua.",
        None,
    ),
    "solar panel": (
        "D",
        fondo_cielo()
        + [
            *_sol(32, 22, 10),
            *frecha((46, 28), (66, 40), AMARILLO_OSCURO),
            P([(52, 66), (118, 66), (130, 38), (64, 38)], AZUL_OSCURO, TINTA, 2.2),
            L("M74 38 L62 66 M94 38 L82 66 M112 38 L100 66 M58 52 L124 52", "#93c5fd", 1.6),
            L("M88 66 L88 84", GRIS_OSCURO, 4.0),
        ],
        "Placa solar azul cuadriculada captando los rayos del sol.",
        None,
    ),
    "solve": (
        "D",
        fondo_mesa()
        + [
            R(36, 34, 34, 34, 4, AZUL, AZUL_OSCURO, 2.0),
            E(70, 51, 7, 7, AZUL, AZUL_OSCURO, 1.6),
            R(90, 34, 34, 34, 4, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(90, 51, 7, 7, BLANCO, AMARILLO_OSCURO, 1.6),
            *frecha((72, 22), (88, 22), VERDE_OSCURO),
        ],
        "Dos piezas de puzle acercándose para encajar y resolver el reto.",
        None,
    ),
    "songbird": (
        "D",
        fondo_cielo()
        + [
            L("M24 72 L136 62", BARRO, 4.0),
            E(70, 52, 16, 12, AZUL, AZUL_OSCURO, 2.0),
            E(84, 42, 9, 9, AZUL, AZUL_OSCURO, 2.0),
            E(87, 40, 1.5, 1.5, TINTA),
            P([(93, 41), (101, 44), (92, 46)], NARANJA, BARRO, 1.4),
            *notas_col([(108, 30), (122, 22)], ROJO_OSCURO),
        ],
        "Pájaro cantor azul posado en una rama entonando notas musicales.",
        None,
    ),
    "sort": (
        "D",
        fondo_mesa()
        + [
            R(24, 46, 48, 28, 4, "#fecaca", ROJO_OSCURO, 2.0),
            E(38, 40, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            E(56, 40, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            R(88, 46, 48, 28, 4, "#bfdbfe", AZUL_OSCURO, 2.0),
            E(102, 40, 8, 8, AZUL, AZUL_OSCURO, 1.6),
            E(120, 40, 8, 8, AZUL, AZUL_OSCURO, 1.6),
        ],
        "Dos cestas clasificando piezas rojas a un lado y azules al otro.",
        None,
    ),
    "sow": (
        "D",
        fondo_prado()
        + [
            R(24, 62, 112, 24, 2, BARRO, NEGRO, 2.0),
            L("M28 68 L132 68 M28 76 L132 76", TIERRA_CLARA, 1.8),
            E(68, 26, 14, 9, PEL, PELB, 2.0),
            *semilla_prop(46, 36, 18),
            *semilla_prop(68, 42, 18),
            *semilla_prop(90, 38, 18),
        ],
        "Mano esparciendo semillas sobre los surcos de la tierra.",
        None,
    ),
    "spade": (
        "D",
        fondo_prado()
        + [
            R(76, 14, 8, 42, 2, MADERA, MADERA_OSCURA, 1.8),
            R(68, 10, 24, 7, 3, ROJO, ROJO_OSCURO, 1.8),
            P([(62, 54), (98, 54), (92, 82), (80, 88), (68, 82)], GRIS, GRIS_OSCURO, 2.2),
        ],
        "Pala de jardín con mango rojo y hoja metálica puntiaguda.",
        None,
    ),
    "speaking turn": (
        "D",
        fondo_sala()
        + [
            *nino_busto(48, 38, (VERDE, VERDE_OSCURO)),
            *nino_busto(112, 38, (AZUL, AZUL_OSCURO), mira=-1),
            E(80, 34, 6, 7, GRIS_OSCURO, TINTA, 1.8),
            R(77, 41, 6, 16, 2, TINTA),
            *frecha((64, 26), (96, 26), NARANJA_OSCURO),
        ],
        "Dos niños turnándose para hablar con un micrófono.",
        None,
    ),
    "spine": (
        "D",
        fondo_sala()
        + [
            R(56, 34, 48, 48, 10, PEL, PELB, 2.2),
            E(80, 22, 11, 11, BARRO, NEGRO, 2.0),
            R(76, 38, 8, 6, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(76, 46, 8, 6, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(76, 54, 8, 6, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(76, 62, 8, 6, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(76, 70, 8, 6, 2, BLANCO, GRIS_OSCURO, 1.4),
        ],
        "Espalda mostrando las vértebras de la columna en el centro.",
        None,
    ),
    "spit in the sink": (
        "D",
        fondo_sala()
        + [
            F("M44 56 L116 56 L106 78 L54 78 Z", BLANCO, AZUL_OSCURO, 2.2),
            R(74, 78, 12, 14, 2, GRIS, GRIS_OSCURO, 1.8),
            *nino_busto(58, 22, (AZUL, AZUL_OSCURO)),
            *gotas([(74, 46), (82, 52)]),
        ],
        "Niño inclinándose sobre el lavabo blanco tras cepillarse los dientes.",
        None,
    ),
    "sponge ball": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 24, 24, AMARILLO, NARANJA_OSCURO, 2.2),
            E(70, 42, 3.5, 3, NARANJA_OSCURO),
            E(88, 38, 3, 2.5, NARANJA_OSCURO),
            E(76, 58, 3.5, 3, NARANJA_OSCURO),
            E(92, 56, 3, 2.5, NARANJA_OSCURO),
            E(66, 54, 2.5, 2.5, NARANJA_OSCURO),
        ],
        "Pelota blanda amarilla de esponja porosa.",
        None,
    ),
    "spotlight": (
        "D",
        fondo_noite()
        + [
            P([(80, 24), (36, 86), (124, 86)], "#fef08a", AMARILLO_OSCURO, 1.4),
            R(68, 12, 24, 16, 4, GRIS_OSCURO, TINTA, 2.0),
            E(80, 28, 10, 4, AMARILLO),
        ],
        "Foco proyectando un haz triangular de luz brillante en la oscuridad.",
        None,
    ),
    "springy legs": (
        "D",
        fondo_prado()
        + [
            *nino_saltando(80, 14, True, False, (VERDE, VERDE_OSCURO)),
            L("M68 62 L76 68 L68 74 L76 80", GRIS_OSCURO, 2.4),
            L("M84 62 L92 68 L84 74 L92 80", GRIS_OSCURO, 2.4),
            *frecha((42, 66), (42, 34), VERDE_OSCURO),
        ],
        "Niño botando hacia arriba con resortes elásticos bajo los pies.",
        None,
    ),
    "sprout": (
        "D",
        fondo_prado()
        + [
            R(44, 62, 72, 22, 3, BARRO, NEGRO, 2.0),
            L("M80 62 L80 38", VERDE_OSCURO, 3.2),
            F("M80 42 Q60 28 56 42 Q68 50 80 42 Z", HERBA, VERDE_OSCURO, 1.8),
            F("M80 40 Q100 26 104 40 Q92 48 80 40 Z", VERDE, VERDE_OSCURO, 1.8),
        ],
        "Pequeño brote verde de dos hojitas saliendo de la tierra.",
        None,
    ),
    "squash": (
        "D",
        fondo_sala()
        + [
            E(80, 68, 28, 7, MORADO, "#5b21b6", 2.0),
            R(66, 22, 28, 18, 4, BARRO, NEGRO, 2.0),
            *frecha((80, 42), (80, 58), ROJO_OSCURO),
        ],
        "Zapato aplastando hasta dejar plana una pieza blanda.",
        None,
    ),
    "squawk like a seagull": (
        "D",
        fondo_mar()
        + [
            E(68, 50, 18, 11, BLANCO, GRIS_OSCURO, 2.0),
            E(84, 38, 9, 9, BLANCO, GRIS_OSCURO, 2.0),
            E(86, 36, 1.5, 1.5, TINTA),
            P([(93, 35), (105, 34), (94, 39)], AMARILLO, NARANJA_OSCURO, 1.4),
            P([(93, 40), (104, 45), (92, 43)], AMARILLO, NARANJA_OSCURO, 1.4),
            *ondas_sonido(112, 40, AZUL_OSCURO, 1),
        ],
        "Gaviota blanca con el pico abierto graznando fuerte junto al mar.",
        None,
    ),
    "squeeze": (
        "D",
        fondo_mesa()
        + [
            E(80, 44, 16, 16, NARANJA, NARANJA_OSCURO, 2.2),
            E(58, 44, 10, 12, PEL, PELB, 2.0),
            E(102, 44, 10, 12, PEL, PELB, 2.0),
            *gotas([(74, 66), (80, 74), (86, 66)]),
        ],
        "Manos apretando una naranja soltando gotas de zumo.",
        None,
    ),
    "squishy": (
        "D",
        fondo_sala()
        + [
            E(80, 52, 26, 14, ROSA, ROSA_OSCURO, 2.2),
            E(80, 32, 16, 7, PEL, PELB, 1.8),
            *frecha((80, 16), (80, 28), ROSA_OSCURO),
            *frecha((40, 52), (52, 52), ROSA_OSCURO),
            *frecha((120, 52), (108, 52), ROSA_OSCURO),
        ],
        "Bola blanda deformándose suavemente al apretarla con la mano.",
        None,
    ),
    "stack": (
        "D",
        fondo_mesa()
        + [
            R(56, 62, 48, 16, 3, ROJO, ROJO_OSCURO, 2.0),
            R(60, 44, 40, 16, 3, AZUL, AZUL_OSCURO, 2.0),
            R(64, 26, 32, 16, 3, VERDE, VERDE_OSCURO, 2.0),
            *frecha((40, 62), (40, 28), AZUL_OSCURO),
        ],
        "Cubos o vasos apilados ordenadamente uno encima de otro.",
        None,
    ),
    "stairs": (
        "D",
        fondo_sala()
        + [
            R(36, 68, 28, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(60, 54, 28, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(84, 40, 28, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(108, 26, 28, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            *frecha((42, 56), (98, 22), VERDE_OSCURO),
        ],
        "Escaleras de cuatro peldaños subiendo en diagonal.",
        None,
    ),
    "stamp feet": (
        "D",
        fondo_sala()
        + [
            *nino((80, 24), (80, 36), (80, 52), [[(66, 44)], [(94, 44)]], [[(68, 68), (66, 78)], [(92, 62), (96, 72)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *frecha((96, 54), (96, 74), ROJO_OSCURO),
            L("M56 78 L46 74 M104 78 L114 74", NARANJA_OSCURO, 2.0),
        ],
        "Niño pataleando con fuerza contra el suelo.",
        None,
    ),
    "stand like a tree": (
        "D",
        fondo_prado()
        + [
            *nino((80, 26), (80, 38), (80, 54), [[(66, 30), (74, 18)], [(94, 30), (86, 18)]], [[(78, 76)], [(92, 60), (80, 62)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
        ],
        "Niño en equilibrio sobre una pierna con los brazos alzados como copa de árbol.",
        None,
    ),
    "stand tall": (
        "D",
        fondo_sala()
        + [
            *nino((80, 22), (80, 34), (80, 50), [[(68, 44)], [(92, 44)]], [[(76, 76)], [(84, 76)]], camisa=(AZUL, AZUL_OSCURO), mira=1),
            *frecha((46, 74), (46, 20), VERDE_OSCURO),
            L("M40 20 L116 20", VERDE_OSCURO, 1.4),
        ],
        "Niño de pie muy recto y erguido junto a flecha vertical.",
        None,
    ),
    "stand up": (
        "D",
        fondo_sala()
        + [
            R(44, 62, 24, 16, 2, MADERA, MADERA_OSCURA, 1.8),
            L("M44 46 L44 62", MADERA_OSCURA, 3.0),
            *nino((88, 28), (88, 40), (88, 56), [[(74, 48)], [(102, 48)]], [[(82, 78)], [(94, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *frecha((58, 58), (74, 30), VERDE_OSCURO),
        ],
        "Niño levantándose de la silla para ponerse de pie.",
        None,
    ),
    "stem": (
        "D",
        fondo_prado()
        + [
            L("M80 82 L80 26", VERDE_OSCURO, 5.0),
            E(80, 20, 11, 9, ROSA, ROSA_OSCURO, 1.8),
            F("M80 56 Q62 46 58 58 Q68 64 80 56 Z", HERBA, VERDE_OSCURO, 1.6),
            *frecha((50, 54), (74, 54), ROJO_OSCURO),
        ],
        "Tallo verde largo de una flor señalado con una flecha.",
        None,
    ),
    "step back": (
        "D",
        fondo_prado()
        + [
            *nino_caminando(92, 28, 1, (AZUL, AZUL_OSCURO), 9),
            *frecha((68, 50), (36, 50), ROJO_OSCURO),
        ],
        "Niño dando un paso hacia atrás siguiendo la flecha roja.",
        None,
    ),
    "step stool": (
        "D",
        fondo_sala()
        + [
            R(46, 50, 68, 12, 3, AZUL, AZUL_OSCURO, 2.0),
            R(42, 62, 76, 18, 3, AZUL, AZUL_OSCURO, 2.2),
            R(56, 54, 48, 4, 2, "#93c5fd"),
            *frecha((80, 26), (80, 44), VERDE_OSCURO),
        ],
        "Taburete escalón azul de dos peldaños.",
        None,
    ),
    "stick": (
        "D",
        fondo_sala()
        + [
            R(42, 22, 76, 60, 4, "#fef3c7", BARRO, 1.8),
            R(58, 34, 44, 34, 3, AZUL, AZUL_OSCURO, 2.0),
            E(80, 51, 10, 8, PEL, PELB, 1.8),
            *frecha((114, 51), (104, 51), VERDE_OSCURO),
        ],
        "Mano pegando una lámina sobre el mural con palmaditas.",
        None,
    ),
    "stick in photos": (
        "D",
        fondo_mesa()
        + [
            *libro_prop(40, 28, 80, VERDE),
            R(48, 36, 26, 28, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            E(61, 46, 6, 6, AMARILLO),
            R(86, 36, 26, 28, 2, "#fecaca", ROJO_OSCURO, 1.6),
            *frecha((126, 24), (104, 42), VERDE_OSCURO),
        ],
        "Álbum abierto pegando una fotografía en la página derecha.",
        None,
    ),
    "stick out your tongue": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 26, PEL, PELB, 2.4),
            F("M54 44 C56 18 104 18 106 44 C90 32 70 32 54 44 Z", BARRO),
            E(70, 44, 2.5, 3, TINTA),
            E(90, 44, 2.5, 3, TINTA),
            L("M68 58 Q80 64 92 58", "#9a3412", 2.0),
            E(80, 66, 6.5, 9, ROSA, ROSA_OSCURO, 1.8),
            L("M80 60 L80 68", ROSA_OSCURO, 1.4),
        ],
        "Cara sonriente sacando mucho la lengua rosa.",
        None,
    ),
    "sticker": (
        "D",
        fondo_mesa()
        + [
            R(50, 24, 60, 56, 5, BLANCO, GRIS_OSCURO, 2.0),
            _estrella(80, 52, 18, 8, AMARILLO, NARANJA_OSCURO),
            P([(98, 62), (110, 62), (110, 74)], "#e2e8f0", GRIS_OSCURO, 1.4),
        ],
        "Pegatina dorada de estrella despegándose de la esquina.",
        None,
    ),
    "sticker chart": (
        "D",
        fondo_sala()
        + [
            R(34, 20, 92, 62, 4, BLANCO, AZUL_OSCURO, 2.2),
            L("M34 40 L126 40 M34 60 L126 60 M64 20 L64 82 M94 20 L94 82", GRIS, 1.6),
            _estrella(49, 30, 6, 3, AMARILLO, NARANJA_OSCURO),
            _estrella(79, 30, 6, 3, AMARILLO, NARANJA_OSCURO),
            _estrella(109, 30, 6, 3, AMARILLO, NARANJA_OSCURO),
            _estrella(49, 50, 6, 3, ROJO, ROJO_OSCURO),
            _estrella(79, 50, 6, 3, ROJO, ROJO_OSCURO),
        ],
        "Tabla cuadriculada de recompensas con pegatinas de estrellas.",
        None,
    ),
    "stiff": (
        "D",
        fondo_sala()
        + [
            R(66, 18, 28, 20, 3, GRIS, GRIS_OSCURO, 2.0),
            E(74, 26, 2.2, 2.2, AZUL_OSCURO),
            E(86, 26, 2.2, 2.2, AZUL_OSCURO),
            R(60, 40, 40, 26, 3, PLATA, GRIS_OSCURO, 2.0),
            R(46, 42, 12, 22, 2, GRIS, GRIS_OSCURO, 1.8),
            R(102, 42, 12, 22, 2, GRIS, GRIS_OSCURO, 1.8),
            R(66, 66, 10, 18, 2, GRIS, GRIS_OSCURO, 1.8),
            R(84, 66, 10, 18, 2, GRIS, GRIS_OSCURO, 1.8),
        ],
        "Robot tieso y rígido con brazos y piernas completamente rectos.",
        None,
    ),
    "stone wall": (
        "D",
        fondo_prado()
        + [
            R(24, 42, 112, 38, 2, "#94a3b8", TINTA, 2.0),
            R(28, 46, 32, 14, 4, GRIS, GRIS_OSCURO, 1.6),
            R(64, 46, 34, 14, 4, "#cbd5e1", GRIS_OSCURO, 1.6),
            R(102, 46, 30, 14, 4, GRIS, GRIS_OSCURO, 1.6),
            R(28, 63, 46, 14, 4, "#cbd5e1", GRIS_OSCURO, 1.6),
            R(78, 63, 54, 14, 4, GRIS, GRIS_OSCURO, 1.6),
        ],
        "Muro sólido construido con piedras grises encajadas.",
        None,
    ),
    "store": (
        "D",
        fondo_sala()
        + [
            R(36, 26, 88, 56, 3, MADERA, MADERA_OSCURA, 2.2),
            L("M36 54 L124 54", MADERA_OSCURA, 2.4),
            R(44, 34, 24, 18, 2, AMARILLO, BARRO, 1.8),
            R(74, 34, 24, 18, 2, AZUL, AZUL_OSCURO, 1.8),
            R(44, 60, 24, 18, 2, VERDE, VERDE_OSCURO, 1.8),
            *frecha((106, 68), (74, 68), ROJO_OSCURO),
        ],
        "Estantería de almacenaje guardando cajas ordenadas por pisos.",
        None,
    ),
    "straight": (
        "D",
        fondo_mesa()
        + [
            L("M24 50 L136 50", AZUL_OSCURO, 6.0),
            *frecha((34, 34), (126, 34), VERDE_OSCURO),
            E(24, 50, 5, 5, ROJO, ROJO_OSCURO, 1.6),
            E(136, 50, 5, 5, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Línea completamente recta de extremo a extremo.",
        None,
    ),
    "straw hat": (
        "D",
        fondo_cielo()
        + [
            F("M48 56 Q52 24 80 24 Q108 24 112 56 Z", "#fde047", BARRO, 2.2),
            R(48, 48, 64, 8, 2, ROJO, ROJO_OSCURO, 1.6),
            E(80, 58, 52, 9, "#fef08a", BARRO, 2.2),
        ],
        "Sombrero de paja dorado de ala ancha con cinta roja.",
        None,
    ),
    "straw house": (
        "D",
        fondo_prado()
        + [
            R(50, 48, 60, 32, 3, "#fde68a", BARRO, 2.0),
            P([(42, 48), (80, 18), (118, 48)], "#facc15", BARRO, 2.2),
            L("M58 46 L74 28 M80 46 L80 22 M102 46 L86 28", NARANJA_OSCURO, 1.8),
            R(72, 60, 16, 20, 2, BARRO, NEGRO, 1.6),
        ],
        "Casita amarilla con tejado cónico de haces de paja.",
        None,
    ),
    "street lamp": (
        "D",
        fondo_noite()
        + [
            R(76, 34, 8, 50, 2, GRIS_OSCURO, TINTA, 2.0),
            R(64, 22, 32, 12, 4, AMARILLO, AMARILLO_OSCURO, 2.0),
            P([(70, 34), (50, 86), (110, 86), (90, 34)], "#fef08a"),
        ],
        "Farol alto iluminando la calle durante la noche.",
        None,
    ),
    "stretch out your arms": (
        "D",
        fondo_prado()
        + [
            *nino((80, 26), (80, 38), (80, 54), [[(66, 40), (42, 40)], [(94, 40), (118, 40)]], [[(74, 74)], [(86, 74)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *frecha((54, 28), (30, 28), AZUL_OSCURO),
            *frecha((106, 28), (130, 28), AZUL_OSCURO),
        ],
        "Niño estirando ambos brazos completamente en cruz hacia los lados.",
        None,
    ),
    "stretchy": (
        "D",
        fondo_sala()
        + [
            R(28, 44, 104, 12, 5, ROSA, ROSA_OSCURO, 2.0),
            *frecha((54, 30), (24, 30), ROSA_OSCURO),
            *frecha((106, 30), (136, 30), ROSA_OSCURO),
        ],
        "Banda elástica rosa estirándose mucho hacia ambos extremos.",
        None,
    ),
    "suck": (
        "D",
        fondo_mesa()
        + [
            *nino_busto(72, 40, (NARANJA, NARANJA_OSCURO)),
            F("M82 48 Q98 42 104 54 Q94 60 82 54 Z", AMARILLO, NARANJA_OSCURO, 1.8),
        ],
        "Niño chupando un gajo dulce de naranja.",
        None,
    ),
    "sun hat": (
        "D",
        fondo_cielo()
        + [
            *_sol(130, 22, 9),
            F("M50 56 Q54 28 80 28 Q106 28 110 56 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            R(50, 48, 60, 7, 2, AZUL, AZUL_OSCURO, 1.6),
            E(80, 58, 52, 9, "#fef08a", AMARILLO_OSCURO, 2.2),
        ],
        "Sombrero ancho amarillo de verano con cinta azul bajo el sol.",
        None,
    ),
    "sunshine": (
        "D",
        fondo_prado()
        + [
            *_sol(80, 32, 16),
            L("M60 48 L42 74 M72 52 L66 78 M88 52 L94 78 M100 48 L118 74", "#fde047", 2.6),
        ],
        "Sol luminoso enviando largos rayos dorados sobre el prado.",
        None,
    ),
    "surface": (
        "D",
        fondo_mar()
        + [
            R(0, 0, 160, 46, 0, "#e0f2fe"),
            L("M0 46 Q40 40 80 46 Q120 52 160 46", AZUL_OSCURO, 2.4),
            *nino_busto(80, 42, (NARANJA, NARANJA_OSCURO)),
            *frecha((50, 76), (50, 42), AZUL_OSCURO),
        ],
        "Nadador subiendo hasta asomar la cabeza sobre la superficie del agua.",
        None,
    ),
    "swallow": (
        "D",
        fondo_cielo()
        + [
            F("M64 48 Q80 42 96 48 L118 38 L104 52 L118 62 L94 54 Q80 60 64 48 Z", "#1e293b", TINTA, 1.8),
            E(76, 52, 8, 5, BLANCO),
            P([(76, 44), (58, 22), (86, 42)], "#1e293b", TINTA, 1.6),
            P([(80, 52), (54, 70), (88, 52)], "#1e293b", TINTA, 1.6),
            E(60, 46, 6, 5, "#1e293b", TINTA, 1.6),
            P([(54, 46), (48, 48), (54, 50)], NARANJA),
        ],
        "Golondrina negra y blanca volando con su cola ahorquillada.",
        None,
    ),
    "swap": (
        "D",
        fondo_sala()
        + [
            E(42, 54, 14, 14, ROJO, ROJO_OSCURO, 2.0),
            R(102, 40, 28, 28, 4, AZUL, AZUL_OSCURO, 2.0),
            *frecha((60, 40), (100, 40), VERDE_OSCURO),
            *frecha((100, 68), (60, 68), NARANJA_OSCURO),
        ],
        "Pelota roja y cubo azul intercambiándose de posición.",
        None,
    ),
    "sweep": (
        "D",
        fondo_sala()
        + [
            L("M96 14 L76 62", MADERA_OSCURA, 3.6),
            P([(58, 60), (92, 60), (98, 82), (52, 82)], AMARILLO, BARRO, 2.0),
            L("M64 68 L60 80 M76 68 L74 80 M86 68 L88 80", BARRO, 1.6),
            *frecha((48, 74), (24, 74), VERDE_OSCURO),
        ],
        "Escoba amarilla barriendo el suelo de derecha a izquierda.",
        None,
    ),
    "swim in a group": (
        "D",
        fondo_mar()
        + [
            E(44, 40, 9, 5, NARANJA, NARANJA_OSCURO, 1.6),
            P([(34, 40), (28, 36), (28, 44)], NARANJA),
            E(76, 36, 9, 5, AMARILLO, NARANJA_OSCURO, 1.6),
            P([(66, 36), (60, 32), (60, 40)], AMARILLO),
            E(66, 60, 9, 5, ROJO, ROJO_OSCURO, 1.6),
            P([(56, 60), (50, 56), (50, 64)], ROJO),
            E(104, 52, 9, 5, VERDE, VERDE_OSCURO, 1.6),
            P([(94, 52), (88, 48), (88, 56)], VERDE),
            *frecha((114, 44), (138, 44), AZUL_OSCURO),
        ],
        "Banco de pececitos de colores nadando juntos en la misma dirección.",
        None,
    ),
    "switch off lights": (
        "D",
        fondo_noite()
        + [
            R(28, 32, 34, 44, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(38, 44, 14, 20, 2, GRIS, GRIS_OSCURO, 1.6),
            *frecha((18, 54), (36, 54), ROJO_OSCURO),
            E(108, 44, 16, 16, GRIS, GRIS_OSCURO, 2.0),
            R(100, 58, 16, 12, 3, GRIS_OSCURO, TINTA, 1.8),
        ],
        "Interruptor pulsado dejando la bombilla apagada.",
        None,
    ),
    "swoop": (
        "D",
        fondo_cielo()
        + [
            E(58, 36, 14, 7, BARRO, NEGRO, 2.0),
            P([(44, 34), (34, 20), (66, 32)], BARRO, NEGRO, 1.8),
            P([(72, 36), (80, 38), (72, 41)], AMARILLO),
            L("M68 46 Q96 54 116 74", ROJO_OSCURO, 2.4),
            P([(112, 74), (120, 77), (118, 69)], ROJO_OSCURO),
        ],
        "Águila bajando rápido en picado hacia abajo.",
        None,
    ),
    "tails and wings": (
        "D",
        fondo_cielo()
        + [
            E(80, 54, 16, 12, AZUL, AZUL_OSCURO, 2.0),
            P([(66, 48), (34, 30), (66, 58)], HERBA, VERDE_OSCURO, 1.8),
            P([(94, 48), (126, 30), (94, 58)], HERBA, VERDE_OSCURO, 1.8),
            P([(74, 64), (68, 84), (80, 74), (92, 84), (86, 64)], AMARILLO, AMARILLO_OSCURO, 1.8),
            E(80, 38, 8, 8, AZUL, AZUL_OSCURO, 1.8),
        ],
        "Pájaro mostrando claramente las dos alas extendidas y su cola.",
        None,
    ),
    "take a mask": (
        "D",
        fondo_sala()
        + [
            *nino_busto(54, 40, (MORADO, "#5b21b6")),
            F("M92 34 Q112 24 132 34 L126 52 Q112 46 98 52 Z", ROJO, ROJO_OSCURO, 2.0),
            E(104, 41, 4, 3, BLANCO),
            E(120, 41, 4, 3, BLANCO),
            *frecha((90, 42), (68, 42), VERDE_OSCURO),
        ],
        "Niño cogiendo una máscara de carnaval para ponérsela.",
        None,
    ),
    "take away": (
        "D",
        fondo_mesa()
        + [
            E(36, 54, 11, 11, ROJO, ROJO_OSCURO, 1.8),
            E(66, 54, 11, 11, ROJO, ROJO_OSCURO, 1.8),
            E(96, 54, 11, 11, ROJO, ROJO_OSCURO, 1.8),
            E(128, 34, 11, 11, ROJO, ROJO_OSCURO, 1.8),
            *frecha((108, 48), (122, 38), AZUL_OSCURO),
        ],
        "Cuatro manzanas retirando una de ellas hacia fuera.",
        None,
    ),
    "take cover": (
        "D",
        fondo_cielo()
        + [
            *gotas([(30, 18), (64, 16), (96, 16), (130, 18)]),
            *nino((80, 50), (80, 62), (80, 74), [[(66, 46), (72, 34)], [(94, 46), (88, 34)]], [[(72, 84)], [(88, 84)]], camisa=(NARANJA, NARANJA_OSCURO), mira=1),
            L("M58 34 Q80 22 102 34", AZUL_OSCURO, 3.0),
        ],
        "Niño agachado protegiéndose la cabeza con ambos brazos bajo la lluvia.",
        None,
    ),
    "take down": (
        "D",
        fondo_cielo()
        + [
            L("M20 26 L140 26", TINTA, 2.2),
            P([(42, 30), (68, 30), (74, 44), (66, 48), (64, 40), (64, 58), (46, 58), (46, 40), (44, 48), (36, 44)], AZUL, AZUL_OSCURO, 1.8),
            P([(94, 44), (120, 44), (126, 58), (118, 62), (116, 54), (116, 72), (98, 72), (98, 54), (96, 62), (88, 58)], ROJO, ROJO_OSCURO, 1.8),
            *frecha((107, 28), (107, 42), VERDE_OSCURO),
        ],
        "Descolgando ropa limpia de la cuerda de tender.",
        None,
    ),
    "talking stick": (
        "D",
        fondo_sala()
        + [
            *nino_busto(44, 40, (VERDE, VERDE_OSCURO)),
            *nino_busto(116, 40, (ROJO, ROJO_OSCURO), mira=-1),
            L("M66 64 L94 34", MADERA_OSCURA, 5.0),
            L("M88 40 L102 48 M84 44 L96 54", AMARILLO, 2.6),
            *ondas_sonido(58, 34, AZUL_OSCURO, 1),
        ],
        "Palo decorado con cintas de colores para pedir el turno de palabra.",
        None,
    ),
    "tall and green": (
        "D",
        fondo_prado()
        + [
            R(74, 46, 12, 36, 2, BARRO, NEGRO, 1.8),
            E(80, 32, 22, 22, VERDE, VERDE_OSCURO, 2.2),
            *frecha((42, 78), (42, 16), VERDE_OSCURO),
        ],
        "Árbol muy alto y verde con flecha vertical marcando su altura.",
        None,
    ),
    "tall tower": (
        "D",
        fondo_sala()
        + [
            R(64, 68, 32, 14, 2, ROJO, ROJO_OSCURO, 1.8),
            R(64, 54, 32, 14, 2, AZUL, AZUL_OSCURO, 1.8),
            R(64, 40, 32, 14, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(64, 26, 32, 14, 2, VERDE, VERDE_OSCURO, 1.8),
            R(64, 12, 32, 14, 2, MORADO, "#5b21b6", 1.8),
            *frecha((44, 78), (44, 14), AZUL_OSCURO),
        ],
        "Torre altísima de cinco bloques de colores apilados.",
        None,
    ),
    "tally": (
        "D",
        fondo_sala()
        + [
            R(28, 22, 104, 56, 4, "#1e293b", MADERA_OSCURA, 2.4),
            L("M46 36 L46 64 M56 36 L56 64 M66 36 L66 64 M76 36 L76 64", BLANCO, 3.0),
            L("M40 60 L82 40", AMARILLO, 3.0),
            L("M100 36 L100 64 M110 36 L110 64", BLANCO, 3.0),
        ],
        "Pizarra oscura con grupo de cinco palitos de recuento cruzados.",
        None,
    ),
    "tangram": (
        "D",
        fondo_mesa()
        + [
            R(50, 22, 60, 60, 2, BLANCO, TINTA, 2.0),
            P([(50, 22), (110, 22), (80, 52)], ROJO, TINTA, 1.6),
            P([(50, 22), (80, 52), (50, 82)], AZUL, TINTA, 1.6),
            P([(110, 22), (110, 52), (95, 37)], VERDE, TINTA, 1.6),
            P([(80, 52), (95, 37), (110, 52), (95, 67)], AMARILLO, TINTA, 1.6),
            P([(50, 82), (80, 52), (95, 67), (65, 82)], NARANJA, TINTA, 1.6),
            P([(65, 82), (110, 82), (110, 52)], MORADO, TINTA, 1.6),
        ],
        "Rompecabezas tangram cuadrado formado por siete piezas geométricas de colores.",
        None,
    ),
    "tap the rhythm": (
        "D",
        fondo_mesa()
        + [
            E(80, 56, 32, 14, ROJO, ROJO_OSCURO, 2.2),
            E(80, 50, 32, 12, "#fef3c7", BARRO, 2.0),
            E(80, 32, 10, 7, PEL, PELB, 1.8),
            *frecha((80, 14), (80, 26), AZUL_OSCURO),
            *notas_col([(116, 36), (130, 26)], AZUL_OSCURO),
        ],
        "Mano dando golpecitos sobre el tambor siguiendo el ritmo musical.",
        None,
    ),
    "tape measure": (
        "D",
        fondo_mesa()
        + [
            E(54, 48, 22, 22, AMARILLO, AMARILLO_OSCURO, 2.4),
            E(54, 48, 8, 8, BLANCO, AMARILLO_OSCURO, 1.6),
            R(66, 56, 68, 12, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M76 56 L76 62 M88 56 L88 64 M100 56 L100 62 M112 56 L112 64 M124 56 L124 62", TINTA, 1.8),
        ],
        "Cinta métrica amarilla desenrollada con marcas de medida.",
        None,
    ),
    "taste test": (
        "D",
        fondo_mesa()
        + [
            *nino_busto(50, 38, (ROSA, ROSA_OSCURO)),
            *cuchara_prop(68, 34, 24),
            E(96, 54, 10, 10, ROJO, ROJO_OSCURO, 1.8),
            E(122, 54, 10, 10, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Niño haciendo una cata con cuchara entre distintas frutas.",
        None,
    ),
    "tea set": (
        "D",
        fondo_mesa()
        + [
            E(60, 50, 18, 16, AZUL, AZUL_OSCURO, 2.2),
            L("M44 46 Q32 46 36 58 Q44 62 48 56", AZUL_OSCURO, 3.0),
            L("M74 44 L86 34", AZUL_OSCURO, 3.6),
            R(52, 30, 16, 6, 3, AZUL, AZUL_OSCURO, 1.6),
            R(98, 48, 18, 16, 4, BLANCO, AZUL_OSCURO, 1.8),
            E(107, 66, 14, 4, BLANCO, AZUL_OSCURO, 1.6),
        ],
        "Juego de té infantil con tetera azul y taza con platillo.",
        None,
    ),
    "team": (
        "D",
        fondo_prado()
        + [
            *nino_busto(48, 36, (AZUL, AZUL_OSCURO)),
            *nino_busto(80, 36, (AZUL, AZUL_OSCURO)),
            *nino_busto(112, 36, (AZUL, AZUL_OSCURO)),
            L("M48 64 Q80 78 112 64", AZUL_OSCURO, 3.2),
        ],
        "Equipo de tres niños con la misma camiseta unidos juntos.",
        None,
    ),
    "team circle": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 32, 32, "#dbeafe", AZUL_OSCURO, 2.0),
            E(80, 22, 7, 7, PEL, PELB, 1.8),
            E(108, 50, 7, 7, PEL, PELB, 1.8),
            E(80, 78, 7, 7, PEL, PELB, 1.8),
            E(52, 50, 7, 7, PEL, PELB, 1.8),
            E(80, 50, 8, 8, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Equipo de cuatro jugadores reunidos en corrillo en círculo.",
        None,
    ),
    "teethe": (
        "D",
        fondo_sala()
        + [
            *bebe_sentado(74, 44, (AZUL, AZUL_OSCURO)),
            E(96, 52, 10, 10, "#93c5fd", AZUL_OSCURO, 4.0),
            E(96, 52, 5, 5, "#f8fafc"),
        ],
        "Bebé mordisqueando un aro mordedor azul suave.",
        None,
    ),
    "the sun is up": (
        "D",
        fondo_prado()
        + [
            *_sol(80, 34, 16),
            *frecha((40, 60), (40, 26), AMARILLO_OSCURO),
            P([(10, 72), (56, 52), (98, 72)], HERBA, VERDE_OSCURO, 1.8),
            P([(68, 72), (114, 48), (154, 72)], HERBA, VERDE_OSCURO, 1.8),
        ],
        "Sol ya alto brillando sobre las colinas verdes.",
        None,
    ),
    "thermos": (
        "D",
        fondo_mesa()
        + [
            R(64, 24, 32, 54, 5, PLATA, GRIS_OSCURO, 2.2),
            R(66, 14, 28, 12, 3, ROJO, ROJO_OSCURO, 2.0),
            R(64, 40, 32, 16, 1, ROJO, ROJO_OSCURO, 1.6),
            *ondas_calor(106, 36, ROJO),
        ],
        "Termo metálico con tapón rojo manteniendo la bebida caliente.",
        None,
    ),
    "think hard": (
        "D",
        fondo_sala()
        + [
            *nino_busto(58, 44, (MORADO, "#5b21b6")),
            *nube_pensar(108, 30, 24, 16),
            E(108, 29, 7, 7, AMARILLO, AMARILLO_OSCURO, 1.6),
        ],
        "Niño pensativo con gran nube de ideas encendiéndose arriba.",
        None,
    ),
    "thread beads": (
        "D",
        fondo_mesa()
        + [
            L("M24 52 Q80 68 136 44", BARRO, 2.4),
            E(48, 56, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            E(72, 58, 9, 9, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(96, 56, 9, 9, VERDE, VERDE_OSCURO, 1.8),
            E(122, 34, 9, 9, AZUL, AZUL_OSCURO, 1.8),
            *frecha((122, 18), (122, 42), AZUL_OSCURO),
        ],
        "Cuentas de colores ensartándose en un cordón.",
        None,
    ),
    "throw away": (
        "D",
        fondo_sala()
        + [
            *papelera_prop(84, 44, 36),
            E(44, 30, 9, 8, BLANCO, GRIS_OSCURO, 1.6),
            *frecha((54, 30), (92, 42), ROJO_OSCURO),
        ],
        "Mano tirando un papel arrugado dentro de la papelera.",
        None,
    ),
    "thumb": (
        "D",
        fondo_sala()
        + [
            R(62, 46, 36, 34, 10, PEL, PELB, 2.2),
            R(72, 20, 14, 28, 7, PEL, PELB, 2.2),
            *frecha((42, 40), (68, 32), ROJO_OSCURO),
        ],
        "Mano levantando claramente el dedo pulgar hacia arriba.",
        None,
    ),
    "tickle toes": (
        "D",
        fondo_sala()
        + [
            E(58, 56, 14, 22, PEL, PELB, 2.2),
            E(48, 32, 3, 4, PEL, PELB, 1.4),
            E(55, 30, 3, 4, PEL, PELB, 1.4),
            E(62, 31, 3, 4, PEL, PELB, 1.4),
            E(69, 34, 3, 4, PEL, PELB, 1.4),
            F("M84 36 Q106 16 122 28 Q112 44 84 42 Z", AMARILLO, NARANJA_OSCURO, 1.8),
            L("M72 36 L86 38", AMARILLO_OSCURO, 2.0),
        ],
        "Pluma suave haciendo cosquillas en los dedos del pie.",
        None,
    ),
    "tickle tummy": (
        "D",
        fondo_sala()
        + [
            *bebe_sentado(74, 44, (VERDE, VERDE_OSCURO)),
            E(104, 52, 11, 7, PEL, PELB, 1.8),
            *frecha((100, 40), (84, 52), NARANJA_OSCURO),
            L("M62 46 L54 42 M86 46 L94 42", AMARILLO_OSCURO, 1.8),
        ],
        "Mano haciendo cosquillas suaves en la barriguita del bebé.",
        None,
    ),
    "tidy": (
        "D",
        fondo_sala()
        + [
            *caja_prop(38, 48, 32, AZUL, AZUL_OSCURO),
            R(86, 46, 12, 30, 2, ROJO, ROJO_OSCURO, 1.8),
            R(100, 46, 12, 30, 2, VERDE, VERDE_OSCURO, 1.8),
            R(114, 46, 12, 30, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Rincón ordenado con juguetes dentro de la caja y libros bien alineados.",
        None,
    ),
    "tight": (
        "D",
        fondo_mesa()
        + [
            *caja_prop(62, 38, 36, NARANJA, BARRO),
            L("M60 52 L100 52 M80 36 L80 68", ROJO_OSCURO, 3.6),
            *frecha((34, 52), (56, 52), ROJO_OSCURO),
            *frecha((126, 52), (104, 52), ROJO_OSCURO),
        ],
        "Caja fuertemente apretada y atada por cintas rojas.",
        None,
    ),
    "time it": (
        "D",
        fondo_sala()
        + [
            E(80, 54, 24, 24, BLANCO, TINTA, 2.4),
            R(74, 22, 12, 8, 2, ROJO, ROJO_OSCURO, 1.8),
            L("M80 54 L80 36 M80 54 L94 44", ROJO_OSCURO, 2.4),
            *frecha((80, 10), (80, 20), ROJO_OSCURO),
        ],
        "Cronómetro deportivo pulsando el botón superior para medir el tiempo.",
        None,
    ),
    "tiny shoe": (
        "D",
        fondo_sala()
        + [
            R(68, 52, 22, 14, 6, ROJO, ROJO_OSCURO, 2.0),
            R(66, 62, 26, 5, 2, BLANCO, GRIS_OSCURO, 1.4),
            *frecha((42, 58), (62, 58), AZUL_OSCURO),
            *frecha((118, 58), (98, 58), AZUL_OSCURO),
        ],
        "Zapatito diminuto señalado entre flechas pequeñas.",
        None,
    ),
    "tiny village": (
        "D",
        fondo_prado()
        + [
            R(34, 52, 22, 18, 2, BLANCO, BARRO, 1.6),
            P([(31, 52), (45, 40), (59, 52)], ROJO, ROJO_OSCURO, 1.6),
            R(68, 48, 24, 22, 2, "#fef3c7", BARRO, 1.6),
            P([(65, 48), (80, 36), (95, 48)], AZUL, AZUL_OSCURO, 1.6),
            R(104, 52, 22, 18, 2, BLANCO, BARRO, 1.6),
            P([(101, 52), (115, 40), (129, 52)], VERDE, VERDE_OSCURO, 1.6),
        ],
        "Pequeña aldea de tres casitas juntas sobre la pradera.",
        None,
    ),
    "tip over": (
        "D",
        fondo_mesa()
        + [
            P([(56, 68), (88, 36), (104, 54), (72, 78)], AZUL, AZUL_OSCURO, 2.2),
            *gotas([(104, 64), (114, 70)]),
            L("M48 34 Q72 18 92 32", ROJO_OSCURO, 2.2),
            P([(88, 28), (95, 34), (86, 35)], ROJO_OSCURO),
        ],
        "Vaso azul volcándose de lado sobre la mesa.",
        None,
    ),
    "tip the scale": (
        "D",
        fondo_mesa()
        + [
            P([(74, 76), (86, 76), (80, 44)], GRIS_OSCURO, TINTA, 2.0),
            L("M36 36 L124 62", MADERA_OSCURA, 3.6),
            E(36, 48, 12, 5, PLATA, GRIS_OSCURO, 1.6),
            E(124, 70, 12, 5, PLATA, GRIS_OSCURO, 1.6),
            R(116, 54, 16, 14, 2, ROJO, ROJO_OSCURO, 1.8),
            *frecha((124, 32), (124, 48), ROJO_OSCURO),
        ],
        "Balanza inclinándose con fuerza hacia el platillo más pesado.",
        None,
    ),
    "tissue": (
        "D",
        fondo_sala()
        + [
            F("M44 54 Q64 26 88 46 Q104 34 116 56 Q96 74 74 62 Q58 70 44 54 Z", BLANCO, GRIS_OSCURO, 2.0),
            *lineas_viento(24, 44, 20, AGUA_OSCURO),
        ],
        "Pañuelo de papel blanco suave y ligero.",
        None,
    ),
    "tissue box": (
        "D",
        fondo_mesa()
        + [
            R(44, 44, 72, 34, 4, AZUL, AZUL_OSCURO, 2.2),
            E(80, 44, 18, 5, "#1e3a8a"),
            F("M68 44 Q74 18 82 28 Q90 16 94 44 Z", BLANCO, GRIS_OSCURO, 1.8),
        ],
        "Caja azul con un pañuelo blanco saliendo por la abertura superior.",
        None,
    ),
    "toadstool": (
        "D",
        fondo_prado()
        + [
            R(72, 52, 16, 28, 4, "#fef3c7", BARRO, 2.0),
            F("M44 54 Q46 20 80 20 Q114 20 116 54 Z", ROJO, ROJO_OSCURO, 2.2),
            E(66, 36, 5, 4, BLANCO),
            E(88, 30, 4.5, 4, BLANCO),
            E(96, 44, 4, 3.5, BLANCO),
        ],
        "Seta roja de cuento con sombrero de lunares blancos.",
        None,
    ),
    "together": (
        "D",
        fondo_prado()
        + [
            *nino((62, 28), (62, 40), (62, 56), [[(48, 48)], [(80, 50)]], [[(56, 76)], [(68, 76)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            *nino((98, 28), (98, 40), (98, 56), [[(80, 50)], [(112, 48)]], [[(92, 76)], [(104, 76)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
            E(80, 20, 6, 5, ROSA, ROSA_OSCURO, 1.4),
        ],
        "Dos niños juntos cogiéndose de la mano con alegría.",
        None,
    ),
    "toot the horn": (
        "D",
        fondo_mar()
        + [
            F("M34 54 L106 54 L96 72 L44 72 Z", ROJO, ROJO_OSCURO, 2.0),
            R(56, 36, 28, 18, 2, BLANCO, AZUL_OSCURO, 1.8),
            R(66, 24, 10, 12, 1, AMARILLO, BARRO, 1.6),
            *ondas_sonido(96, 28, ROJO_OSCURO, 1),
            *notas_col([(114, 24)], AZUL_OSCURO),
        ],
        "Barquito haciendo sonar su bocina con ondas de sonido.",
        None,
    ),
    "toothpaste": (
        "D",
        fondo_sala()
        + [
            P([(30, 38), (82, 32), (82, 54), (30, 48)], AZUL, AZUL_OSCURO, 2.0),
            R(82, 39, 8, 8, 2, BLANCO, GRIS_OSCURO, 1.6),
            L("M90 43 Q106 38 118 46", "#38bdf8", 5.0),
            R(98, 56, 40, 7, 3, VERDE, VERDE_OSCURO, 1.8),
            R(100, 48, 20, 8, 1, BLANCO, GRIS_OSCURO, 1.4),
        ],
        "Tubo de pasta de dientes azul apretándose sobre el cepillo.",
        None,
    ),
    "topple": (
        "D",
        fondo_sala()
        + [
            R(64, 68, 32, 12, 2, ROJO, ROJO_OSCURO, 1.8),
            R(66, 56, 28, 12, 2, AZUL, AZUL_OSCURO, 1.8),
            P([(74, 54), (98, 42), (104, 52), (80, 62)], AMARILLO, AMARILLO_OSCURO, 1.8),
            P([(96, 36), (118, 22), (124, 32), (102, 46)], VERDE, VERDE_OSCURO, 1.8),
            L("M106 16 Q128 24 132 46", ROJO_OSCURO, 2.2),
            P([(128, 44), (134, 49), (136, 41)], ROJO_OSCURO),
        ],
        "Torre de bloques inclinándose y viniéndose abajo.",
        None,
    ),
    "touch your toes": (
        "D",
        fondo_prado()
        + [
            *nino((94, 40), (80, 38), (74, 52), [[(86, 54), (94, 72)], [(72, 54), (82, 72)]], [[(68, 76)], [(84, 76)]], camisa=(AMARILLO, AMARILLO_OSCURO), mira=1),
            *frecha((104, 46), (96, 70), ROJO_OSCURO),
        ],
        "Niño flexionándose hacia delante para tocarse la punta de los pies.",
        None,
    ),
    "tower": (
        "D",
        fondo_prado()
        + [
            R(56, 28, 48, 54, 2, GRIS, GRIS_OSCURO, 2.2),
            R(50, 20, 14, 10, 1, GRIS, GRIS_OSCURO, 1.8),
            R(73, 20, 14, 10, 1, GRIS, GRIS_OSCURO, 1.8),
            R(96, 20, 14, 10, 1, GRIS, GRIS_OSCURO, 1.8),
            R(74, 40, 12, 16, 4, TINTA),
            F("M72 82 L72 64 Q80 58 88 64 L88 82 Z", MADERA_OSCURA),
        ],
        "Torre alta de piedra con almenas y portón de madera.",
        None,
    ),
    "town hall": (
        "D",
        fondo_cielo()
        + [
            R(38, 44, 84, 38, 2, "#fef3c7", BARRO, 2.0),
            P([(34, 44), (80, 24), (126, 44)], ROJO, ROJO_OSCURO, 2.0),
            R(68, 18, 24, 26, 2, "#fef3c7", BARRO, 1.8),
            E(80, 31, 7, 7, BLANCO, TINTA, 1.6),
            L("M80 31 L80 26 M80 31 L84 31", TINTA, 1.4),
            R(72, 60, 16, 22, 2, MADERA_OSCURA),
            L("M80 6 L80 18", TINTA, 1.8),
            P([(80, 6), (92, 10), (80, 14)], AZUL),
        ],
        "Edificio del ayuntamiento con torre del reloj y bandera.",
        None,
    ),
    "toy box": (
        "D",
        fondo_sala()
        + [
            R(42, 42, 76, 40, 4, MADERA, MADERA_OSCURA, 2.2),
            P([(38, 42), (46, 26), (114, 26), (122, 42)], MADERA_OSCURA, TINTA, 2.0),
            *pelota_prop(62, 34, 10, ROJO, ROJO_OSCURO),
            E(96, 34, 10, 9, TIERRA_CLARA, BARRO, 1.8),
        ],
        "Baúl de madera abierto lleno de juguetes.",
        None,
    ),
    "trace a spiral": (
        "D",
        fondo_mesa()
        + [
            L("M80 50 Q86 44 86 52 Q86 60 76 58 Q64 56 66 44 Q68 30 84 30 Q102 30 102 52 Q102 74 78 74", AZUL_OSCURO, 2.8),
            *frecha((52, 44), (66, 44), ROJO_OSCURO),
            E(46, 46, 8, 5, PEL, PELB, 1.6),
        ],
        "Dedo trazando y repasando el recorrido de una espiral.",
        None,
    ),
    "trail": (
        "D",
        fondo_prado()
        + [
            F("M30 82 Q60 66 78 52 Q96 38 118 22 L134 22 Q108 42 94 56 Q80 70 58 82 Z", TIERRA_CLARA, BARRO, 1.8),
            E(62, 68, 3, 2, BARRO),
            E(82, 54, 3, 2, BARRO),
            E(104, 38, 3, 2, BARRO),
        ],
        "Sendero natural marcado con pisadas entre la hierba.",
        None,
    ),
    "travel": (
        "D",
        fondo_cielo()
        + [
            E(80, 56, 22, 22, AGUA, AZUL_OSCURO, 2.0),
            E(74, 52, 7, 9, VERDE),
            E(88, 60, 6, 7, VERDE),
            P([(52, 24), (104, 24), (96, 32), (60, 32)], BLANCO, AZUL_OSCURO, 2.0),
            P([(72, 24), (82, 12), (90, 24)], AZUL, AZUL_OSCURO, 1.6),
            *frecha((108, 28), (132, 28), NARANJA_OSCURO),
        ],
        "Avión viajando sobre el planeta azul.",
        None,
    ),
    "tree planting": (
        "D",
        fondo_prado()
        + [
            R(76, 54, 8, 22, 1, BARRO, NEGRO, 1.6),
            E(80, 44, 15, 14, VERDE, VERDE_OSCURO, 2.0),
            *nino((44, 32), (44, 44), (44, 60), [[(34, 52)], [(60, 52)]], [[(40, 78)], [(48, 78)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            R(106, 52, 18, 16, 3, AZUL, AZUL_OSCURO, 1.8),
            L("M106 56 L94 48", AZUL_OSCURO, 2.6),
            *gotas([(90, 54)]),
        ],
        "Niño plantando y regando un árbol joven en el prado.",
        None,
    ),
    "trickle": (
        "D",
        fondo_sala()
        + [
            R(36, 18, 88, 64, 4, "#e0f2fe", AZUL_OSCURO, 2.0),
            L("M76 24 Q72 40 78 52 Q82 64 76 76", AGUA, 2.8),
            *gotas([(76, 78)]),
        ],
        "Hilo fino de agua escurriendo lentamente por el cristal.",
        None,
    ),
    "tricycle": (
        "D",
        fondo_prado()
        + [
            E(46, 68, 9, 9, BLANCO, NEGRO, 2.4),
            E(60, 72, 9, 9, BLANCO, NEGRO, 2.4),
            E(110, 64, 13, 13, BLANCO, NEGRO, 2.4),
            L("M52 68 L84 52 L110 64 M98 38 L108 38 M102 48 L102 38", ROJO, 3.2),
            R(72, 46, 16, 6, 2, AMARILLO, BARRO, 1.6),
        ],
        "Triciclo infantil rojo de tres ruedas y sillín amarillo.",
        None,
    ),
    "tuck in": (
        "D",
        fondo_sala()
        + [
            R(30, 50, 100, 30, 5, MADERA, MADERA_OSCURA, 2.2),
            *bebe(56, 44, "#93c5fd", AZUL_OSCURO, 1),
            *manta_prop(54, 46, 70, "#fde68a", 28),
            *frecha((88, 30), (88, 46), AZUL_OSCURO),
        ],
        "Bebé arropado cómodamente en la cama remetiéndole la manta.",
        None,
    ),
    "tunnel": (
        "D",
        fondo_prado()
        + [
            F("M34 78 L34 42 Q80 14 126 42 L126 78 Z", ROJO, ROJO_OSCURO, 2.2),
            F("M54 78 L54 48 Q80 28 106 48 L106 78 Z", "#1e293b", TINTA, 1.8),
            *frecha((20, 62), (66, 62), AMARILLO),
        ],
        "Túnel arqueado de juegos con flecha atravesándolo.",
        None,
    ),
    "turn": (
        "D",
        fondo_sala()
        + [
            *nino((80, 28), (80, 40), (80, 56), [[(64, 46)], [(96, 46)]], [[(74, 76)], [(86, 76)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
            L("M54 64 Q80 86 106 64", AZUL_OSCURO, 2.4),
            P([(102, 62), (110, 62), (107, 69)], AZUL_OSCURO),
            L("M106 38 Q80 18 54 38", AZUL_OSCURO, 2.4),
            P([(58, 40), (50, 40), (53, 33)], AZUL_OSCURO),
        ],
        "Niño dando una vuelta completa sobre sí mismo.",
        None,
    ),
    "turn over a stone": (
        "D",
        fondo_prado()
        + [
            E(68, 56, 22, 13, GRIS, GRIS_OSCURO, 2.2),
            L("M48 44 Q64 26 88 38", AZUL_OSCURO, 2.4),
            P([(84, 34), (92, 40), (83, 42)], AZUL_OSCURO),
            E(96, 70, 6, 5, ROJO, ROJO_OSCURO, 1.5),
            E(96, 70, 1.5, 1.5, TINTA),
        ],
        "Dando la vuelta con cuidado a una piedra para mirar debajo.",
        None,
    ),
    "turn the page": (
        "D",
        fondo_mesa()
        + [
            *libro_prop(38, 30, 84, AZUL),
            F("M80 34 Q102 24 114 34 L114 68 Q96 58 80 68 Z", "#fef3c7", AMARILLO_OSCURO, 1.8),
            L("M104 20 Q82 12 64 22", ROJO_OSCURO, 2.2),
            P([(68, 18), (60, 24), (69, 25)], ROJO_OSCURO),
        ],
        "Libro abierto pasando suavemente la página hacia la izquierda.",
        None,
    ),
    "turn the page of the calendar": (
        "D",
        fondo_sala()
        + [
            R(48, 22, 64, 58, 4, BLANCO, GRIS_OSCURO, 2.2),
            R(48, 22, 64, 14, 3, ROJO, ROJO_OSCURO, 2.0),
            L("M56 46 L104 46 M56 58 L104 58 M56 70 L104 70", GRIS, 1.6),
            P([(92, 64), (112, 64), (112, 80)], "#e2e8f0", AZUL_OSCURO, 1.6),
            L("M116 54 Q114 38 98 34", AZUL_OSCURO, 2.2),
            P([(102, 30), (94, 34), (100, 39)], AZUL_OSCURO),
        ],
        "Calendario de pared levantando y pasando la hoja mensual.",
        None,
    ),
    "twigs": (
        "D",
        fondo_prado()
        + [
            L("M34 62 L120 48 M48 54 L66 42 M92 52 L112 38", BARRO, 3.8),
            L("M40 74 L126 66 M68 70 L84 58", MADERA_OSCURA, 3.6),
        ],
        "Manojo de ramitas secas recogidas en el suelo.",
        None,
    ),
    "uncover": (
        "D",
        fondo_mesa()
        + [
            *pelota_prop(80, 64, 13, ROJO, ROJO_OSCURO),
            F("M44 36 Q80 20 116 36 L110 50 Q80 38 50 50 Z", MORADO, "#5b21b6", 2.0),
            *frecha((80, 30), (80, 14), VERDE_OSCURO),
        ],
        "Levantando un pañuelo morado para destapar la pelota escondida.",
        None,
    ),
    "under the quilt": (
        "D",
        fondo_sala()
        + [
            R(30, 50, 100, 30, 5, MADERA, MADERA_OSCURA, 2.2),
            R(44, 42, 74, 30, 7, ROSA, ROSA_OSCURO, 2.2),
            R(56, 48, 18, 18, 2, AMARILLO),
            R(84, 48, 18, 18, 2, "#93c5fd"),
            E(48, 38, 8, 8, PEL, PELB, 2.0),
            *frecha((24, 58), (42, 58), AZUL_OSCURO),
        ],
        "Niño asomando acogedoramente por debajo de un edredón de retales.",
        None,
    ),
    "under the table": (
        "D",
        fondo_sala()
        + [
            *mesa_prop(36, 36, 88, 44),
            *pelota_prop(80, 68, 11, ROJO, ROJO_OSCURO),
            *frecha((22, 68), (58, 68), AZUL_OSCURO),
        ],
        "Pelota roja colocada claramente debajo de la mesa.",
        None,
    ),
    "under the tap": (
        "D",
        fondo_sala()
        + [
            R(36, 16, 48, 10, 4, PLATA, GRIS_OSCURO, 2.0),
            R(74, 22, 12, 14, 3, PLATA, GRIS_OSCURO, 2.0),
            L("M80 36 L80 58", AGUA, 6.0),
            R(62, 56, 36, 26, 4, AMARILLO, AMARILLO_OSCURO, 2.0),
        ],
        "Vaso amarillo puesto justo debajo del chorro del grifo.",
        None,
    ),
    "underwater": (
        "D",
        fondo_mar()
        + [
            R(0, 0, 160, 26, 0, "#e0f2fe"),
            L("M0 26 Q40 20 80 26 Q120 32 160 26", AZUL_OSCURO, 2.4),
            E(60, 56, 12, 7, NARANJA, NARANJA_OSCURO, 1.8),
            P([(48, 56), (40, 50), (40, 62)], NARANJA),
            E(104, 62, 10, 6, AMARILLO, NARANJA_OSCURO, 1.8),
            P([(114, 62), (122, 56), (122, 68)], AMARILLO),
            *pompas([(82, 46, 4), (86, 36, 4)]),
        ],
        "Escena submarina con peces y burbujas bajo la línea del agua.",
        None,
    ),
    "underwater camera": (
        "D",
        fondo_mar()
        + [
            R(48, 36, 64, 40, 7, AMARILLO, NARANJA_OSCURO, 2.2),
            R(58, 28, 20, 8, 2, NARANJA, NARANJA_OSCURO, 1.8),
            E(80, 56, 13, 13, "#1e293b", TINTA, 2.0),
            E(80, 56, 7, 7, AGUA, AZUL_OSCURO, 1.4),
            *pompas([(36, 36, 4), (124, 32, 4)]),
        ],
        "Cámara impermeable amarilla sacando fotos bajo el mar.",
        None,
    ),
    "uniformed": (
        "D",
        fondo_sala()
        + [
            *nino_busto(80, 28, (AZUL, AZUL_OSCURO)),
            P([(76, 38), (84, 38), (82, 56), (78, 56)], ROJO, ROJO_OSCURO, 1.2),
            R(68, 58, 24, 22, 2, GRIS_OSCURO, TINTA, 1.8),
        ],
        "Escolar vestido impecablemente con su uniforme azul y corbata.",
        None,
    ),
    "unpack": (
        "D",
        fondo_mesa()
        + [
            R(50, 44, 60, 34, 4, MADERA, MADERA_OSCURA, 2.2),
            *libro_prop(58, 16, 32, ROJO),
            *frecha((80, 46), (80, 20), VERDE_OSCURO),
        ],
        "Sacando libros y objetos fuera de la caja abierta.",
        None,
    ),
    "unsteady": (
        "D",
        fondo_prado()
        + [
            R(36, 72, 88, 7, 2, MADERA, MADERA_OSCURA, 2.0),
            *nino((84, 22), (78, 34), (74, 50), [[(56, 34)], [(102, 46)]], [[(68, 70)], [(84, 70)]], camisa=(NARANJA, NARANJA_OSCURO), mira=1),
            L("M46 28 Q40 36 46 44 M112 28 Q118 36 112 44", ROJO_OSCURO, 2.0),
        ],
        "Niño tambaleándose inestable sobre un tablón estrecho.",
        None,
    ),
    "unwrap": (
        "D",
        fondo_mesa()
        + [
            R(56, 44, 48, 34, 4, AMARILLO, ROJO_OSCURO, 2.2),
            P([(56, 44), (42, 28), (68, 36)], ROSA, ROSA_OSCURO, 1.8),
            P([(104, 44), (118, 28), (92, 36)], ROSA, ROSA_OSCURO, 1.8),
            *frecha((54, 24), (38, 16), ROSA_OSCURO),
            *frecha((106, 24), (122, 16), ROSA_OSCURO),
        ],
        "Desenvolviendo el papel de colores de un regalo.",
        None,
    ),
    "up and down": (
        "D",
        fondo_sala()
        + [
            *pelota_prop(80, 50, 14, AZUL, AZUL_OSCURO),
            *frecha((48, 68), (48, 26), VERDE_OSCURO),
            *frecha((112, 26), (112, 68), ROJO_OSCURO),
        ],
        "Flechas alternas indicando movimiento arriba y abajo.",
        None,
    ),
    "up as steam, down as rain": (
        "D",
        fondo_cielo()
        + [
            R(10, 74, 140, 20, 0, AGUA, AZUL_OSCURO, 1.6),
            E(104, 24, 24, 12, GRIS, GRIS_OSCURO, 1.8),
            *frecha((46, 68), (46, 28), ROJO_OSCURO),
            *gotas([(96, 46), (112, 50), (104, 62)]),
            *frecha((126, 36), (126, 66), AZUL_OSCURO),
        ],
        "Vapor subiendo al cielo y cayendo de la nube en gotas de lluvia.",
        None,
    ),
    "up the hill and down": (
        "D",
        fondo_cielo()
        + [
            F("M10 86 Q80 18 150 86 Z", HERBA, VERDE_OSCURO, 2.2),
            *frecha((34, 62), (70, 32), VERDE_OSCURO),
            *frecha((90, 32), (126, 62), ROJO_OSCURO),
        ],
        "Colina verde con flecha subiendo por una ladera y bajando por la otra.",
        None,
    ),
    "up the palm tree": (
        "D",
        fondo_cielo()
        + [
            L("M80 86 Q76 54 84 32", BARRO, 8.0),
            L("M84 32 Q58 20 46 34 M84 32 Q64 16 56 20 M84 32 Q110 20 122 34 M84 32 Q104 16 112 20", VERDE_OSCURO, 4.4),
            *frecha((58, 76), (58, 36), VERDE_OSCURO),
        ],
        "Palmera tropical alta con flecha subiendo por el tronco.",
        None,
    ),
    "up with the crane": (
        "D",
        fondo_cielo()
        + [
            R(36, 22, 12, 62, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(30, 20, 88, 10, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M106 30 L106 54", TINTA, 2.2),
            R(94, 54, 24, 18, 2, NARANJA, BARRO, 1.8),
            *frecha((78, 72), (78, 42), ROJO_OSCURO),
        ],
        "Grúa amarilla elevando una carga pesada hacia arriba.",
        None,
    ),
    "upstairs and downstairs": (
        "D",
        fondo_sala()
        + [
            R(30, 68, 26, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(54, 54, 26, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(78, 40, 26, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(102, 26, 26, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            *frecha((34, 56), (92, 20), VERDE_OSCURO),
            *frecha((116, 48), (64, 80), ROJO_OSCURO),
        ],
        "Escaleras con flechas subiendo hacia arriba y bajando hacia abajo.",
        None,
    ),
    "vine": (
        "D",
        fondo_prado()
        + [
            L("M80 10 Q96 30 74 50 Q56 68 84 82", VERDE_OSCURO, 4.4),
            E(68, 26, 6, 4, HERBA, VERDE_OSCURO, 1.4),
            E(88, 40, 6, 4, HERBA, VERDE_OSCURO, 1.4),
            E(62, 62, 6, 4, HERBA, VERDE_OSCURO, 1.4),
            E(88, 74, 6, 4, HERBA, VERDE_OSCURO, 1.4),
        ],
        "Liana verde colgante con hojas enrollándose desde lo alto.",
        None,
    ),
    "vinegar": (
        "D",
        fondo_mesa()
        + [
            R(64, 34, 32, 46, 6, "#fde68a", BARRO, 2.2),
            R(74, 18, 12, 16, 2, "#fde68a", BARRO, 1.8),
            R(74, 14, 12, 5, 2, BARRO, NEGRO, 1.4),
            R(66, 48, 28, 16, 2, VERDE, VERDE_OSCURO, 1.4),
        ],
        "Botella de cristal con vinagre dorado sobre la mesa.",
        None,
    ),
    "waddle along": (
        "D",
        fondo_prado()
        + [
            E(72, 52, 20, 14, AMARILLO, NARANJA_OSCURO, 2.0),
            E(92, 36, 10, 10, AMARILLO, NARANJA_OSCURO, 2.0),
            P([(102, 36), (112, 38), (102, 41)], NARANJA, NARANJA_OSCURO, 1.4),
            E(95, 34, 1.5, 1.5, TINTA),
            L("M66 66 L64 78 M80 66 L84 78", NARANJA_OSCURO, 3.0),
            L("M40 42 Q34 52 40 62 M116 42 Q122 52 116 62", AZUL_OSCURO, 2.0),
        ],
        "Patito caminando bamboleándose de un lado a otro.",
        None,
    ),
    "wade": (
        "D",
        fondo_mar()
        + [
            *nino((80, 24), (80, 36), (80, 50), [[(66, 42)], [(94, 42)]], [[(72, 70)], [(88, 70)]], camisa=(ROJO, ROJO_OSCURO), mira=1),
            L("M16 62 Q48 56 80 62 Q112 68 144 62", AGUA, 4.0),
            L("M60 66 L52 60 M100 66 L108 60", BLANCO, 1.8),
        ],
        "Niño caminando dentro del agua hasta las rodillas salpicando.",
        None,
    ),
    "wake": (
        "D",
        fondo_cielo()
        + [
            *_sol(130, 22, 10),
            R(28, 60, 104, 22, 4, MADERA, MADERA_OSCURA, 2.0),
            *nino_busto(76, 36, (AZUL, AZUL_OSCURO), brazos_arriba=True),
            *manta_prop(46, 56, 68, "#93c5fd", 22),
        ],
        "Niño despertándose por la mañana desperezando los brazos.",
        None,
    ),
    "warm sand": (
        "D",
        fondo_cielo()
        + [
            *_sol(128, 22, 10),
            F("M12 66 Q80 56 148 66 L148 90 L12 90 Z", "#fde68a", BARRO, 2.0),
            *ondas_calor(58, 46, NARANJA_OSCURO),
            *ondas_calor(88, 48, ROJO),
        ],
        "Arena dorada irradiando ondas cálidas bajo el sol.",
        None,
    ),
    "wash hair": (
        "D",
        fondo_sala()
        + [
            *nino_busto(80, 44, (AZUL, AZUL_OSCURO)),
            E(72, 32, 7, 6, BLANCO, AGUA_OSCURO, 1.6),
            E(88, 32, 7, 6, BLANCO, AGUA_OSCURO, 1.6),
            E(80, 28, 8, 6, BLANCO, AGUA_OSCURO, 1.6),
            *gotas([(60, 24), (100, 24)]),
        ],
        "Niño lavándose el pelo con espuma blanca y agua.",
        None,
    ),
    "washing line": (
        "D",
        fondo_cielo()
        + [
            L("M24 22 L24 84 M136 22 L136 84", MADERA_OSCURA, 3.6),
            L("M24 30 L136 30", TINTA, 2.2),
            R(44, 32, 22, 28, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(74, 32, 20, 26, 3, AZUL, AZUL_OSCURO, 1.8),
            R(102, 32, 18, 24, 3, ROSA, ROSA_OSCURO, 1.8),
        ],
        "Tendedero al aire libre entre dos postes con ropa tendida.",
        None,
    ),
    "watch it grow": (
        "D",
        fondo_prado()
        + [
            R(38, 64, 22, 16, 2, TIERRA, BARRO, 1.8),
            L("M49 64 L49 52", VERDE_OSCURO, 2.6),
            E(49, 50, 4, 3, VERDE),
            *frecha((64, 56), (92, 46), VERDE_OSCURO),
            R(100, 62, 26, 18, 2, TIERRA, BARRO, 1.8),
            L("M113 62 L113 28", VERDE_OSCURO, 3.4),
            E(113, 24, 9, 9, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Planta en maceta creciendo poco a poco hasta florecer.",
        None,
    ),
    "water cycle": (
        "D",
        fondo_cielo()
        + [
            R(14, 72, 132, 18, 0, AGUA, AZUL_OSCURO, 1.8),
            E(80, 24, 24, 12, NUBE, NUBE_B, 1.8),
            *frecha((42, 66), (56, 34), ROJO_OSCURO),
            *gotas([(80, 46), (80, 60)]),
            *frecha((104, 34), (118, 66), AZUL_OSCURO),
        ],
        "Ciclo circular del agua entre el mar, las nubes y la lluvia.",
        None,
    ),
    "water pipe": (
        "D",
        fondo_sala()
        + [
            L("M24 38 L78 38 L78 68 L134 68", GRIS_OSCURO, 14.0),
            L("M24 38 L78 38 L78 68 L134 68", AGUA, 8.0),
            *frecha((34, 24), (68, 24), AZUL_OSCURO),
        ],
        "Tubería con codo transportando agua en su interior.",
        None,
    ),
    "waterfall": (
        "D",
        fondo_prado()
        + [
            R(24, 22, 54, 56, 3, GRIS_OSCURO, TINTA, 2.0),
            L("M74 28 L98 72 M84 28 L108 72 M92 28 L114 72", AGUA, 6.0),
            E(96, 78, 38, 10, AZUL, AZUL_OSCURO, 1.8),
            *pompas([(82, 66, 4), (112, 68, 4)]),
        ],
        "Cascada caudalosa de agua cayendo desde lo alto de la roca.",
        None,
    ),
    "waterlogged": (
        "D",
        fondo_mar()
        + [
            R(46, 56, 68, 18, 5, BARRO, NEGRO, 2.2),
            L("M0 44 Q40 38 80 44 Q120 50 160 44", AZUL_OSCURO, 2.2),
            *frecha((80, 26), (80, 50), ROJO_OSCURO),
            *pompas([(62, 48, 4), (98, 48, 4)]),
        ],
        "Tronco completamente empapado y hundido bajo el agua.",
        None,
    ),
    "weather chart": (
        "D",
        fondo_sala()
        + [
            R(28, 22, 104, 58, 4, BLANCO, AZUL_OSCURO, 2.2),
            L("M62 22 L62 80 M98 22 L98 80", GRIS, 1.8),
            *_sol(45, 48, 7),
            E(80, 48, 11, 7, GRIS, GRIS_OSCURO, 1.6),
            E(115, 44, 10, 6, GRIS, GRIS_OSCURO, 1.6),
            *gotas([(112, 58), (120, 60)]),
        ],
        "Tablero meteorológico con columnas de sol, nube y lluvia.",
        None,
    ),
}

SIN_BASE: dict[str, str] = {
    "script": "Objeto textual teatral (`guion`) imposible de mostrar sin texto ni páginas legibles.",
    "seafaring": "Adjetivo abstracto (`marinero`) que exige saludo o rol no unívoco.",
    "seagrass is a home for little fish": "Frase ecológica compuesta (`la pradera es la casa de los pececitos`) dependiente del texto.",
    "season": "Concepto cíclico abstracto (`estación`) imposible en una sola imagen sin texto.",
    "seat belts on, please": "Fórmula verbal de cortesía duplicada de `seat belt on`.",
    "seaworthy": "Adjetivo evaluativo abstracto (`listo para el mar`) sin rasgo visual propio.",
    "send me a postcard": "Petición verbal duplicada de `send a postcard`.",
    "settle": "Estado interno de calma (`calmarse`) sin objeto visual unívoco.",
    "shake hands kindly": "Matiz adverbial duplicado de `shake hands`.",
    "shake on it": "Modismo de acuerdo (`estrecharse la mano`) duplicado de `shake hands`.",
    "share blocks": "Consigna específica duplicada conceptualmente de `share`.",
    "share equally": "Concepto matemático/reparto (`repartir por igual`) duplicado de `share`.",
    "share out": "Verbo fásico genérico (`repartir`) duplicado de `share`.",
    "share the fruit": "Variante verbal duplicada de `share`.",
    "share toys": "Variante verbal duplicada de `share`.",
    "sharing": "Adjetivo participial duplicado de `share`.",
    "shortest day": "Concepto astronómico/temporal (`el día más corto`) imposible sin texto ni diagrama.",
    "show me the heavy side": "Petición verbal comparativa (`enséñame el lado pesado`).",
    "sign": "Acción dependiente de escritura alfabética (`firmar`) prohibida en láminas.",
    "signature": "Sustantivo alfabético (`firma`) prohibido sin texto.",
    "silky": "Adjetivo táctil (`sedoso`) indistinguible visualmente de `silk scarf`.",
    "sing softer": "Modulación auditiva comparativa (`cantar más suave`) imposible sin referencia sonora.",
    "sit with me": "Invitación conversacional (`siéntate conmigo`) ambigua respecto a sentarse.",
    "sleek": "Adjetivo abstracto (`liso y rápido`) sin referente único infantil.",
    "slow down your breathing": "Instrucción gradual (`respirar más despacio`) duplicada de `breathe`.",
    "slowly, slowly": "Adverbio de modo (`despacito`) dependiente de cualquier acción previa.",
    "smell it": "Orden genérica duplicada de `smell the flower`.",
    "sniff a flower": "Duplicada directa de `smell the flower`.",
    "snug": "Sensación térmica/afectiva (`arropadito`) duplicada de `under the quilt`.",
    "soft and sweet": "Doble adjetivo sensorial (`blando y dulce`) imposible de representar sin texto.",
    "soft-furred": "Cualidad táctil (`de pelo suave`) no distinguible de un animal normal.",
    "softer, please": "Petición verbal de volumen (`más suave, por favor`).",
    "solstice": "Fenómeno astronómico estacional (`solsticio`) abstracto para 0-7 sin texto.",
    "sort by number": "Regla numérica (`ordenar por número`) prohibida sin dígitos.",
    "sorted": "Participio duplicado de `sort`.",
    "sourer": "Grado comparativo (`más ácido`) sin escala visual frente a `sour`.",
    "spit out": "Duplicada directa de `spit in the sink`.",
    "sporty": "Adjetivo abstracto (`deportista`) ambiguo frente a un deporte concreto.",
    "squawk": "Onomatopeya duplicada de `squawk like a seagull`.",
    "squeezy": "Adjetivo táctil duplicado de `squeeze` / `squishy`.",
    "stack up": "Duplicada directa de `stack`.",
    "stackable": "Adjetivo potencial (`apilable`) duplicado de `stack`.",
    "staircase": "Duplicada directa de `stairs`.",
    "stand tall and proud": "Frase postural duplicada de `stand tall`.",
    "street sign": "Placa urbana dependiente de texto legible de calle.",
    "stretch as high as you can": "Variante verbal duplicada de `stretch out your arms` / `stand tall`.",
    "strong": "Adjetivo abstracto (`fuerte`) ambiguo frente a `flex` o levantamiento.",
    "strongest house": "Superlativo narrativo de cuento (`la casa más fuerte`) dependiente de texto.",
    "summery": "Adjetivo estacional (`veraniego`) ambiguo frente a `sunny` / `sunshine`.",
    "supportive": "Rasgo socioemocional abstracto (`que apoya`).",
    "swap roles": "Regla teatral abstracta (`cambiar los papeles`) duplicada de `swap`.",
    "swap toys": "Variante verbal duplicada de `swap`.",
    "switch": "Verbo genérico polisémico (`cambiar de golpe`) sin referente único.",
    "take a turn": "Regla de turno grupal duplicada de `speaking turn`.",
    "take one away": "Operación verbal (`quitar uno`) duplicada de `take away`.",
    "take only photos": "Lema ecológico (`llévate solo fotos`) imposible sin texto.",
    "take photos": "Acción duplicada conceptualmente de cámara / `photo`.",
    "take turns directing": "Consigna de juego de rol (`dirigir por turnos`).",
    "take turns talking": "Duplicada directa de `speaking turn`.",
    "tangy": "Sensación gustativa (`ácido`) sin objeto propio distinto de limón.",
    "tap, tap, tap": "Onomatopeya rítmica repetida duplicada de `tap the rhythm`.",
    "tapping game": "Nombre de dinámica auditiva grupal (`juego de golpecitos`).",
    "team leader": "Rol organizativo abstracto (`jefe de equipo`) ambiguo.",
    "team, huddle up": "Consigna grupal duplicada de `team circle`.",
    "teamwork": "Concepto social abstracto (`trabajo en equipo`) duplicado de `team` / `together`.",
    "test an idea": "Verbo cognitivo abstracto (`probar una idea`).",
    "thank you for helping me": "Fórmula verbal de agradecimiento (`gracias por ayudarme`).",
    "the bag is heavier with potatoes": "Oración comparativa compleja dependiente de texto.",
    "the brick house is stronger than the straw house": "Oración comparativa de cuento dependiente de texto.",
    "the chestnut is heavier than the leaf": "Oración comparativa compleja de peso dependiente de texto.",
    "the gull flies higher than the cormorant": "Oración comparativa espacial de dos aves dependiente de texto.",
    "the stone sinks, but the cork floats": "Oración contrastiva compleja dependiente de texto.",
    "this is for you": "Frase deíctica verbal (`esto es para ti`) duplicada de entrega.",
    "this little piggy": "Retahíla tradicional infantil dependiente de la letra.",
    "thumbs up for a clean beach": "Lema verbal duplicado de `thumbs up` + playa.",
    "thumbs up for a clean sea": "Lema verbal duplicado de `thumbs up` + mar.",
    "ticklish feet": "Variante duplicada de `tickle toes`.",
    "tickly": "Adjetivo sensorial (`que hace cosquillas`) sin referente autónomo.",
    "tied": "Resultado deportivo abstracto (`empatados`) ambiguo sin marcador.",
    "time for a drink": "Frase horaria verbal (`hora de beber`) duplicada de beber.",
    "toasty": "Sensación térmica interna (`calentito`) ambigua frente a fuego o sol.",
    "together we are stronger": "Lema abstracto (`juntos somos más fuertes`).",
    "toot, toot": "Onomatopeya sonora duplicada de `toot the horn`.",
    "trace": "Acción fina ambigua sin contorno definido; duplicada de `trace a spiral`.",
    "trace around": "Acción duplicada de `trace`.",
    "tradition": "Concepto cultural abstracto (`tradición`) sin icono único.",
    "traditional": "Adjetivo cultural abstracto (`tradicional`).",
    "transfer": "Concepto de transporte abstracto (`hacer transbordo`).",
    "tricky": "Adjetivo evaluativo abstracto (`complicado`) ambiguo.",
    "trustworthy": "Valor moral abstracto (`de confianza`) imposible de ilustrar literal.",
    "try again": "Consigna motivacional temporal (`intentarlo de nuevo`).",
    "try your best": "Expresión motivacional abstracta (`hacerlo lo mejor posible`).",
    "tuneful": "Cualidad sonora (`melodioso`) sin signo visual autónomo.",
    "turn off lights": "Duplicada directa de `switch off lights`.",
    "turn off the light when you leave": "Oración compleja de hábito duplicada de `switch off lights`.",
    "turn out": "Acción de cocina específica (`desmoldar`) poco clara sin secuencia.",
    "unanimous": "Concepto de votación abstracto (`por unanimidad`) sin contexto textual.",
    "up the hill and down again": "Duplicada directa de `up the hill and down`.",
    "up you come": "Exclamación verbal afectiva (`¡arriba!`) sin gesto unívoco.",
    "useful": "Adjetivo abstracto de utilidad (`útil`) sin referente único.",
    "vegetables make us strong": "Oración nutricional compleja dependiente del mensaje verbal.",
    "waddling": "Adjetivo duplicado de `waddle along`.",
    "water first, then soap": "Secuencia instruccional en dos tiempos dependiente del texto.",
    "we can both be right": "Enunciado dialogado abstracto (`podemos tener razón los dos`).",
    "we did it together": "Exclamación de logro grupal duplicada de `together`.",
    "we have grown so much in five years": "Oración temporal autobiográfica (`en cinco años`) imposible sin texto.",
    "we solved it together": "Exclamación de logro grupal duplicada de `solve` / `together`.",
}
