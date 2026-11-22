#!/usr/bin/env python3
"""Tanda 7 TPR (P2.88): cierre completo de tocar/cuerpo y abrir/cerrar, más primer bloque de señalar.

Cubre 200 piezas revisadas + 67 auditadas sin base (`SIN_BASE`):
- Cierre completo de `body_touch` (`hard hat`..`yummy chestnut`: 71+26).
- Cierre completo de `open_close` (`action`..`wide-eyed`: 107+37).
- Primer bloque de `point` (`above`..`colourful`: 22+4).

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas, conversacionales o sin base visual clara quedan en `SIN_BASE`.
"""
from __future__ import annotations

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
    caja_prop,
    cuchara_prop,
    fl,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    libro_prop,
    nino,
    nino_busto,
    nino_corriendo,
    notas_col,
    ondas_calor,
    ondas_sonido,
    pano,
    pelota_prop,
    plato_prop,
    pompas,
    sol,
)
from banco_comun import notas  # noqa: E402

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "clapperboard": ("Clapper board", "U", "Claqueta de cine abierta y lista para cerrarse de golpe."),
    "fist": ("Raised fist", "U", "Mano cerrada con firmeza formando un puño."),
    "hippo": ("Hippopotamus", "U", "Hipopótamo abriendo grande su hocico."),
    "piano": ("Musical keyboard", "U", "Teclado de piano en blanco y negro listo para tocar con los dedos."),
    "sun and rain together": ("Sun behind rain cloud", "U", "Sol brillante y nube de lluvia cayendo a la vez."),
    "surprised": ("Face with open mouth", "U", "Cara con los ojos y la boca muy abiertos de sorpresa."),
}

DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}



def _nino_pie(cx: float, cy: float, camisa: tuple[str, str] = (ROJO, ROJO_OSCURO), mira: int = 1) -> list[dict]:
    return nino(
        (cx, cy), (cx, cy + 12), (cx, cy + 28),
        [[(cx - 12, cy + 22)], [(cx + 12, cy + 22)]],
        [[(cx - 6, cy + 46)], [(cx + 6, cy + 46)]],
        camisa=camisa, mira=mira,
    )


def _sol(cx: float, cy: float, r: float = 13) -> list[dict]:
    return [E(cx, cy, r, r, "#fde047", AMARILLO_OSCURO, 2.2)]


def _frecha(x1: float, y1: float, x2: float, y2: float, cor: str = "#ffffff", sw: float = 2.4) -> list[dict]:
    return frecha((x1, y1), (x2, y2), cor, sw)


def _gotas(x: float, y: float, n: int, _col: str = AGUA) -> list[dict]:
    return gotas([(x + i * 10, y + (i % 2) * 8) for i in range(n)])


def _notas_col(x: float, y: float, col: str = "#fde047") -> list[dict]:
    return notas_col([(x, y), (x + 14, y - 6)], col)


def _pompas(x: float, y: float) -> list[dict]:
    return pompas([(x - 10, y + 6, 5), (x + 2, y, 7), (x + 14, y - 8, 9)])


def _mano_indice(cx: float, cy: float, dx: float = -1, dy: float = 0, manga: tuple[str, str] = (AZUL, AZUL_OSCURO)) -> list[dict]:
    """Mano con el dedo índice señalando/tocando hacia `(dx, dy)`."""
    ix, iy = cx + dx * 18, cy + dy * 14
    sx, sy = cx - dx * 14, cy - dy * 8
    return [
        L(f"M{sx:.1f} {sy:.1f} L{cx:.1f} {cy:.1f}", manga[1], 10.0),
        L(f"M{sx:.1f} {sy:.1f} L{cx:.1f} {cy:.1f}", manga[0], 7.0),
        E(cx, cy, 8.5, 7.5, PEL, PELB, 2.0),
        L(f"M{cx:.1f} {cy:.1f} L{ix:.1f} {iy:.1f}", PELB, 6.2),
        L(f"M{cx:.1f} {cy:.1f} L{ix:.1f} {iy:.1f}", PEL, 3.6),
        E(ix, iy, 2.4, 2.4, PEL, PELB, 1.3),
    ]


def _mano_abierta(cx: float, cy: float, esc: float = 1.0, manga: tuple[str, str] = (ROJO, ROJO_OSCURO)) -> list[dict]:
    s = esc
    return [
        R(cx - 5 * s, cy + 8 * s, 10 * s, 14 * s, 3, manga[0], manga[1], 1.8),
        E(cx, cy, 10 * s, 9 * s, PEL, PELB, 1.8),
        L(f"M{cx - 8 * s:.1f} {cy - 4 * s:.1f} L{cx - 11 * s:.1f} {cy - 14 * s:.1f}", PELB, 4.2 * s),
        L(f"M{cx - 8 * s:.1f} {cy - 4 * s:.1f} L{cx - 11 * s:.1f} {cy - 14 * s:.1f}", PEL, 2.4 * s),
        L(f"M{cx - 3 * s:.1f} {cy - 7 * s:.1f} L{cx - 4 * s:.1f} {cy - 19 * s:.1f}", PELB, 4.2 * s),
        L(f"M{cx - 3 * s:.1f} {cy - 7 * s:.1f} L{cx - 4 * s:.1f} {cy - 19 * s:.1f}", PEL, 2.4 * s),
        L(f"M{cx + 2 * s:.1f} {cy - 7 * s:.1f} L{cx + 2 * s:.1f} {cy - 20 * s:.1f}", PELB, 4.2 * s),
        L(f"M{cx + 2 * s:.1f} {cy - 7 * s:.1f} L{cx + 2 * s:.1f} {cy - 20 * s:.1f}", PEL, 2.4 * s),
        L(f"M{cx + 7 * s:.1f} {cy - 5 * s:.1f} L{cx + 9 * s:.1f} {cy - 16 * s:.1f}", PELB, 4.2 * s),
        L(f"M{cx + 7 * s:.1f} {cy - 5 * s:.1f} L{cx + 9 * s:.1f} {cy - 16 * s:.1f}", PEL, 2.4 * s),
        L(f"M{cx + 9 * s:.1f} {cy + 2 * s:.1f} L{cx + 16 * s:.1f} {cy - 4 * s:.1f}", PELB, 4.2 * s),
        L(f"M{cx + 9 * s:.1f} {cy + 2 * s:.1f} L{cx + 16 * s:.1f} {cy - 4 * s:.1f}", PEL, 2.4 * s),
    ]


def _estrella(cx: float, cy: float, r: float, col: str = AMARILLO, borde: str = AMARILLO_OSCURO, sw: float = 1.6) -> list[dict]:
    import math
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rad = r if i % 2 == 0 else r * 0.44
        pts.append((round(cx + rad * math.cos(ang), 1), round(cy + rad * math.sin(ang), 1)))
    return [P(pts, col, borde, sw)]


def _castana(cx: float, cy: float, r: float = 12) -> list[dict]:
    return [
        F(
            f"M{cx - r:.1f} {cy + r * 0.3:.1f} Q{cx - r:.1f} {cy - r * 0.6:.1f} {cx:.1f} {cy - r * 0.95:.1f} "
            f"Q{cx + r:.1f} {cy - r * 0.6:.1f} {cx + r:.1f} {cy + r * 0.3:.1f} "
            f"Q{cx:.1f} {cy + r * 0.95:.1f} {cx - r:.1f} {cy + r * 0.3:.1f} Z",
            BARRO, "#451a03", 2.0,
        ),
        E(cx, cy + r * 0.42, r * 0.62, r * 0.32, TIERRA_CLARA),
        L(f"M{cx - r * 0.25:.1f} {cy - r * 0.35:.1f} Q{cx - r * 0.4:.1f} {cy - r * 0.05:.1f} {cx - r * 0.25:.1f} {cy + r * 0.15:.1f}", "#fcd34d", 1.5),
    ]


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── body_touch (cierre: 71 cubiertas) ───────────────────────────────────
    put("hard hat", "D",
        fondo_sala() + [
            E(72, 68, 17, 17, PEL, PELB, 2.0),
            E(66, 68, 1.8, 2.2, TINTA),
            E(78, 68, 1.8, 2.2, TINTA),
            L("M66 76 Q72 80 78 76", "#9a3412", 1.6),
            F("M50 61 C50 38 94 38 94 61 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            R(68, 39, 8, 18, 2, AMARILLO_OSCURO),
            R(45, 59, 54, 7, 3, DORADO, AMARILLO_OSCURO, 2.0),
        ] + _mano_indice(108, 42, -1, 0, (AZUL, AZUL_OSCURO)),
        "Casco amarillo de obra puesto en la cabeza con una mano tocándolo.")
    put("hat and mittens", "D",
        fondo_cielo() + [
            F("M30 68 C30 40 72 40 72 68 Z", ROJO, ROJO_OSCURO, 2.2),
            R(27, 65, 48, 10, 4, BLANCO, ROJO_OSCURO, 2.0),
            E(51, 37, 7.5, 7.5, BLANCO, ROJO_OSCURO, 1.8),
            R(90, 50, 18, 24, 9, AZUL, AZUL_OSCURO, 2.0),
            E(87, 62, 5.5, 4.5, AZUL, AZUL_OSCURO, 1.8),
            R(90, 72, 18, 6, 2, BLANCO, AZUL_OSCURO, 1.6),
            R(116, 50, 18, 24, 9, AZUL, AZUL_OSCURO, 2.0),
            E(113, 62, 5.5, 4.5, AZUL, AZUL_OSCURO, 1.8),
            R(116, 72, 18, 6, 2, BLANCO, AZUL_OSCURO, 1.6),
        ],
        "Gorro de invierno con pompón y un par de manoplas calentitas.")
    put("hat pompom", "D",
        fondo_cielo() + [
            F("M44 76 C44 44 102 44 102 76 Z", MORADO, "#5b21b6", 2.2),
            R(40, 73, 66, 12, 4, "#e9d5ff", "#5b21b6", 2.0),
            E(73, 35, 13, 13, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(68, 32, 3.5, 3.5, "#fef9c3"),
            E(78, 36, 3, 3, "#fef9c3"),
        ] + _mano_indice(106, 35, -1, 0, (VERDE, VERDE_OSCURO)),
        "Gorro de punto destacando su gran pompón mullido arriba mientras el dedo lo toca.")
    put("horn", "D",
        fondo_cielo() + [
            E(46, 56, 15, 13, ROJO, ROJO_OSCURO, 2.2),
            F("M60 51 L96 42 L106 32 L106 72 L96 62 L60 60 Z", DORADO, AMARILLO_OSCURO, 2.2),
            E(106, 52, 4, 20, AMARILLO, AMARILLO_OSCURO, 1.8),
        ] + ondas_sonido(116, 52, AZUL_OSCURO, 1) + _mano_indice(34, 72, 1, -1, (AZUL, AZUL_OSCURO)),
        "Bocina con pera roja y trompeta dorada tocada con la mano emitiendo sonido.")
    put("i like mango", "D",
        fondo_sala() + nino_busto(54, 48, (VERDE, VERDE_OSCURO)) + [
            L("M48 76 Q54 81 60 76", BLANCO, 2.2),
            E(54, 78, 9, 4.5, PEL, PELB, 1.5),
            F("M96 44 C112 36 126 52 114 70 C100 84 86 68 96 44 Z", NARANJA, NARANJA_OSCURO, 2.2),
            E(104, 54, 6, 10, "#fde047"),
            L("M100 42 Q105 34 112 37", VERDE_OSCURO, 2.4),
        ],
        "Mango dorado brillante junto a niño feliz tocándose la barriga con agrado.")
    put("knee", "D",
        fondo_sala() + [
            R(36, 36, 18, 42, 7, AZUL, AZUL_OSCURO, 2.0),
            R(42, 68, 44, 15, 7, PEL, PELB, 2.0),
            E(48, 74, 12, 11, PEL, PELB, 2.0),
            E(48, 74, 16, 15, None, ROJO, 2.0),
            R(82, 74, 16, 10, 4, ROJO, ROJO_OSCURO, 1.8),
        ] + _mano_indice(72, 50, -1, 1, (VERDE, VERDE_OSCURO)),
        "Pierna doblada señalando y tocando la rodilla con círculo destacado.")
    put("kneecap", "D",
        fondo_sala() + [
            R(38, 22, 22, 34, 6, PEL, PELB, 2.0),
            F("M44 54 L64 46 L78 82 L58 86 Z", PEL, PELB, 2.0),
            E(60, 50, 12, 12, "#fde68a", ROJO_OSCURO, 2.2),
            E(60, 50, 5, 5, AMARILLO, NARANJA_OSCURO, 1.4),
        ] + _mano_indice(96, 50, -1, 0, (AZUL, AZUL_OSCURO)),
        "Detalle de la articulación de la rodilla doblada con el hueso redondo de la rótula marcado al frente.")
    put("knobbly", "D",
        fondo_prado() + [
            R(34, 42, 82, 28, 12, BARRO, "#451a03", 2.2),
            E(56, 48, 8, 6, TIERRA, "#451a03", 1.8),
            E(56, 48, 3.5, 2.5, TIERRA_CLARA),
            E(88, 56, 9, 7, TIERRA, "#451a03", 1.8),
            E(88, 56, 4, 3, TIERRA_CLARA),
            E(72, 42, 6, 4, BARRO, "#451a03", 1.8),
        ] + _mano_indice(108, 34, -1, 1, (NARANJA, NARANJA_OSCURO)),
        "Tronco de madera con bultos y nudos marcados tocados con el dedo.")
    put("leaf rubbing", "D",
        fondo_mesa() + [
            R(42, 24, 72, 54, 4, BLANCO, GRIS_OSCURO, 2.0),
            F("M64 62 Q58 40 78 34 Q96 42 88 64 Z", "#bbf7d0", VERDE_OSCURO, 1.6),
            L("M76 35 L76 68", VERDE_OSCURO, 1.6),
            L("M76 46 L66 42 M76 54 L86 48 M76 58 L66 56", VERDE_OSCURO, 1.4),
            F("M92 38 L114 18 L120 24 L98 44 Z", ROJO, ROJO_OSCURO, 1.8),
            P([(92, 38), (86, 46), (98, 44)], ROJO_OSCURO),
        ],
        "Hoja debajo de un papel calco sobre la mesa mientras una cera la frota mostrando sus nervios.")
    put("mmm, chestnuts", "D",
        fondo_sala() + nino_busto(48, 48, (NARANJA, NARANJA_OSCURO)) + [
            L("M42 74 Q48 79 54 74", PELB, 1.8),
            E(104, 70, 26, 12, BLANCO, GRIS_OSCURO, 2.0),
        ] + _castana(94, 64, 9) + _castana(108, 62, 9) + _castana(102, 70, 9),
        "Plato lleno de castañas asadas junto a niño feliz tocándose la barriga.")
    put("nail brush", "D",
        fondo_sala() + [
            E(96, 62, 20, 14, PEL, PELB, 2.0),
            R(76, 56, 14, 7, 3, PEL, PELB, 1.6),
            R(78, 50, 14, 7, 3, PEL, PELB, 1.6),
            R(80, 64, 14, 7, 3, PEL, PELB, 1.6),
            R(44, 34, 44, 10, 4, MADERA, MADERA_OSCURA, 2.0),
        ] + [L(f"M{x} 44 L{x} 53", BLANCO, 2.5) for x in range(48, 86, 5)] + [
            L(f"M{x} 44 L{x} 53", GRIS_OSCURO, 1.0) for x in range(48, 86, 5)
        ],
        "Cepillo de madera con cerdas frotando limpiamente las uñas de la mano.")
    put("near", "D",
        fondo_sala() + [
            R(44, 44, 16, 28, 7, AZUL, AZUL_OSCURO, 2.0),
            E(52, 35, 9, 9, PEL, PELB, 2.0),
            E(54, 35, 1.2, 1.4, TINTA),
            R(94, 44, 16, 28, 7, ROJO, ROJO_OSCURO, 2.0),
            E(102, 35, 9, 9, PEL, PELB, 2.0),
            E(100, 35, 1.2, 1.4, TINTA),
            L("M66 56 L73 56 M88 56 L81 56", VERDE_OSCURO, 2.4),
            P([(74, 56), (70, 52), (70, 60)], VERDE_OSCURO),
            P([(80, 56), (84, 52), (84, 60)], VERDE_OSCURO),
        ],
        "Dos figuras muy juntas acercándose casi hasta tocarse.")
    put("nose to nose", "D",
        fondo_sala() + [
            E(52, 52, 17, 17, PEL, PELB, 2.2),
            P([(68, 49), (77, 52), (68, 55)], PEL, PELB, 1.8),
            F("M35 48 C36 30 66 30 66 44 Z", BARRO),
            E(57, 47, 1.6, 1.8, TINTA),
            L("M58 59 Q63 61 66 58", "#9a3412", 1.5),
            E(108, 52, 17, 17, PEL, PELB, 2.2),
            P([(92, 49), (83, 52), (92, 55)], PEL, PELB, 1.8),
            F("M94 44 C94 30 124 30 125 48 Z", AMARILLO_OSCURO),
            E(103, 47, 1.6, 1.8, TINTA),
            L("M94 58 Q97 61 102 59", "#9a3412", 1.5),
            E(80, 52, 4, 4, None, ROJO, 1.8),
        ],
        "Dos caras de perfil acercando sus narices hasta tocarse punta con punta.")
    put("pinecone scales", "D",
        fondo_prado() + [
            E(68, 54, 21, 27, BARRO, "#451a03", 2.2),
            P([(54, 40), (68, 30), (82, 40)], TIERRA, "#451a03", 1.6),
            P([(49, 53), (68, 42), (87, 53)], TIERRA, "#451a03", 1.6),
            P([(52, 66), (68, 54), (84, 66)], TIERRA, "#451a03", 1.6),
            P([(56, 76), (68, 66), (80, 76)], AMARILLO_OSCURO, "#451a03", 2.0),
        ] + _mano_indice(108, 68, -1, 0, (VERDE, VERDE_OSCURO)),
        "Piña marrón destacando una de sus escamas leñosas tocada con el dedo.")
    put("poke", "D",
        fondo_mesa() + [
            F("M44 74 C44 46 96 46 96 74 Z", "#fde68a", NARANJA_OSCURO, 2.2),
            E(84, 58, 7, 5, NARANJA_OSCURO),
        ] + _mano_indice(112, 48, -1, 1, (ROJO, ROJO_OSCURO)),
        "Dedo índice apretando y marcando un hoyito sobre una bola de masa blanda.")
    put("pop, pop, pop", "D",
        fondo_cielo() + [
            E(42, 44, 12, 12, "#e0f2fe", AGUA_OSCURO, 2.0),
            E(38, 40, 3, 2, BLANCO),
            E(72, 34, 13, 13, "#e0f2fe", AGUA_OSCURO, 2.0),
            E(68, 30, 3.5, 2.5, BLANCO),
            L("M96 46 L90 40 M108 46 L114 40 M96 58 L90 64 M108 58 L114 64 M102 42 L102 34", AGUA_OSCURO, 2.2),
        ] + _mano_indice(122, 62, -1, -1, (AZUL, AZUL_OSCURO)),
        "Tres pompas de jabón en el aire mientras el dedo explota una de ellas.")
    put("purr", "D",
        fondo_sala() + [
            E(68, 60, 18, 16, NARANJA, NARANJA_OSCURO, 2.2),
            P([(54, 48), (57, 34), (66, 45)], NARANJA, NARANJA_OSCURO, 2.0),
            P([(82, 48), (79, 34), (70, 45)], NARANJA, NARANJA_OSCURO, 2.0),
            L("M58 58 Q61 55 64 58 M72 58 Q75 55 78 58", TINTA, 1.8),
            E(68, 63, 2.8, 2.0, ROSA_OSCURO),
            L("M63 67 Q68 70 73 67", TINTA, 1.4),
            R(86, 52, 22, 12, 5, PEL, PELB, 2.0),
        ] + ondas_sonido(42, 58, NARANJA_OSCURO, -1),
        "Gato contento con los ojos entrecerrados frotando su mejilla contra una mano y ronroneando.")
    put("red and yellow", "D",
        fondo_mesa() + [
            E(52, 58, 16, 16, ROJO, ROJO_OSCURO, 2.2),
            E(106, 58, 16, 16, AMARILLO, AMARILLO_OSCURO, 2.2),
        ] + _mano_indice(52, 32, 0, 1, (ROJO, ROJO_OSCURO)) + _mano_indice(106, 32, 0, 1, (AZUL, AZUL_OSCURO)),
        "Objeto rojo vivo y objeto amarillo brillante tocados uno tras otro.")
    put("red, red, red", "D",
        fondo_mesa() + [
            E(42, 62, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            R(68, 50, 22, 22, 4, ROJO, ROJO_OSCURO, 2.0),
            F("M104 72 L116 44 L128 72 Z", ROJO, ROJO_OSCURO, 2.0),
        ] + _mano_indice(80, 28, 0, 1, (VERDE, VERDE_OSCURO)),
        "Tres figuras rojas distintas tocadas sucesivamente sobre la mesa.")
    put("rocky", "D",
        fondo_prado() + [
            P([(34, 78), (44, 50), (64, 44), (82, 52), (96, 78)], GRIS, GRIS_OSCURO, 2.2),
            P([(80, 78), (92, 58), (112, 54), (124, 78)], "#94a3b8", GRIS_OSCURO, 2.0),
            L("M50 62 L62 56 L74 64", GRIS_OSCURO, 1.6),
        ] + _mano_indice(112, 36, -1, 1, (NARANJA, NARANJA_OSCURO)),
        "Rocas duras e irregulares tocadas con la mano para notar su superficie.")
    put("rosy", "D",
        fondo_cielo() + [
            E(78, 52, 24, 24, PEL, PELB, 2.2),
            F("M54 46 C56 26 100 26 102 46 Z", BARRO),
            E(69, 47, 2.0, 2.4, TINTA),
            E(87, 47, 2.0, 2.4, TINTA),
            E(63, 56, 6.5, 4.5, ROSA, ROSA_OSCURO, 1.2),
            E(93, 56, 6.5, 4.5, ROSA, ROSA_OSCURO, 1.2),
            L("M71 62 Q78 68 85 62", "#9a3412", 1.8),
        ] + _mano_indice(42, 64, 1, -1, (ROSA, ROSA_OSCURO)) + _mano_indice(114, 64, -1, -1, (ROSA, ROSA_OSCURO)),
        "Cara sonriente con las mejillas muy sonrosadas tocadas suavemente.")
    put("rub a leaf", "D",
        fondo_mesa() + [
            F("M44 64 Q54 34 86 38 Q110 56 84 74 Q54 78 44 64 Z", HERBA, VERDE_OSCURO, 2.2),
            L("M48 64 L88 52", VERDE_OSCURO, 1.8),
        ] + _mano_abierta(94, 48, 0.7, (AZUL, AZUL_OSCURO)),
        "Mano frotando suavemente una hoja verde sobre la mesa.")
    put("rub hands", "D",
        fondo_sala() + [
            E(66, 56, 13, 18, PEL, PELB, 2.0),
            E(88, 54, 13, 18, PEL, PELB, 2.0),
            R(44, 68, 22, 10, 4, AZUL, AZUL_OSCURO, 1.8),
            R(90, 68, 22, 10, 4, AZUL, AZUL_OSCURO, 1.8),
            L("M77 32 L77 24 M67 35 L63 28 M87 35 L91 28", NARANJA_OSCURO, 2.2),
            L("M50 48 Q45 56 50 64 M104 48 Q109 56 104 64", NARANJA, 1.8),
        ],
        "Dos manos juntándose y frotándose entre sí para entrar en calor.")
    put("rub palms", "D",
        fondo_sala() + [
            R(50, 68, 16, 12, 4, VERDE, VERDE_OSCURO, 1.8),
            R(90, 68, 16, 12, 4, VERDE, VERDE_OSCURO, 1.8),
            F("M52 68 L52 46 Q52 40 57 40 L57 28 Q61 28 61 40 L63 25 Q67 25 67 40 L69 29 Q73 29 73 46 L70 68 Z", PEL, PELB, 2.0),
            F("M104 68 L104 46 Q104 40 99 40 L99 28 Q95 28 95 40 L93 25 Q89 25 89 40 L87 29 Q83 29 83 46 L86 68 Z", PEL, PELB, 2.0),
            L("M40 38 L40 58 M116 58 L116 38", ROJO_OSCURO, 2.4),
            P([(40, 34), (36, 40), (44, 40)], ROJO_OSCURO),
            P([(116, 62), (112, 56), (120, 56)], ROJO_OSCURO),
        ],
        "Dos palmas abiertas enfrentadas frotándose verticalmente palma con palma.")
    put("rub your hands", "D",
        fondo_cielo() + nino_busto(78, 48, (ROJO, ROJO_OSCURO)) + [
            E(72, 67, 7.0, 6.0, PEL, PELB, 1.8),
            E(84, 67, 7.0, 6.0, PEL, PELB, 1.8),
        ] + ondas_calor(36, 62, NARANJA_OSCURO) + ondas_calor(100, 62, NARANJA_OSCURO),
        "Niño frotándose rápido las manos delante del pecho para calentarse.")
    put("rubbery", "D",
        fondo_prado() + [
            R(56, 30, 26, 40, 5, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(56, 62, 46, 16, 7, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(54, 74, 48, 5, 2, NEGRO),
            L("M60 36 L78 36", NARANJA_OSCURO, 2.0),
        ] + _mano_indice(112, 54, -1, 0, (AZUL, AZUL_OSCURO)),
        "Bota de goma impermeable amarilla presionada con el dedo mostrando su material elástico.")
    put("rusty", "D",
        fondo_sala() + [
            E(52, 56, 13, 8, None, GRIS_OSCURO, 4.0),
            E(72, 56, 13, 8, None, "#b45309", 4.0),
            E(92, 56, 13, 8, None, "#9a3412", 4.0),
            E(68, 52, 4, 3, NARANJA_OSCURO),
            E(86, 58, 5, 3, NARANJA_OSCURO),
        ] + _mano_indice(114, 38, -1, 1, (VERDE, VERDE_OSCURO)),
        "Cadena metálica vieja con manchas rojizas de óxido tocada con el dedo.")
    put("salty lips", "D",
        fondo_cielo() + [
            R(0, 72, 156, 20, 0, AGUA),
            L("M14 75 Q36 71 58 75 M94 77 Q118 73 142 77", "#bae6fd", 1.8),
            F("M44 46 Q62 30 78 40 Q94 30 112 46 Q78 52 44 46 Z", ROSA, ROSA_OSCURO, 2.2),
            F("M44 46 Q78 68 112 46 Q78 52 44 46 Z", ROSA, ROSA_OSCURO, 2.2),
            E(66, 44, 2.4, 2.4, BLANCO, GRIS_OSCURO, 0.9),
            E(86, 45, 2.4, 2.4, BLANCO, GRIS_OSCURO, 0.9),
            E(78, 54, 2.2, 2.2, BLANCO, GRIS_OSCURO, 0.9),
        ] + _mano_indice(122, 60, -1, -1, (AZUL, AZUL_OSCURO)),
        "Labios junto al mar con cristalitos blancos de sal tocados suavemente con un dedo.")
    put("scrub nails", "D",
        fondo_sala() + [
            E(56, 58, 18, 12, PEL, PELB, 2.0),
            R(74, 46, 18, 20, 6, PEL, PELB, 2.0),
            R(74, 48, 5, 5, 2, BLANCO, GRIS_OSCURO, 1.0),
            R(74, 55, 5, 5, 2, BLANCO, GRIS_OSCURO, 1.0),
            E(64, 44, 6, 6, BLANCO, AGUA_OSCURO, 1.4),
            E(72, 38, 5, 5, BLANCO, AGUA_OSCURO, 1.4),
            E(84, 38, 4.5, 4.5, BLANCO, AGUA_OSCURO, 1.4),
        ],
        "Puntas de los dedos frotando y limpiando las uñas con espuma jabonosa contra la palma.")
    put("scrumptious", "D",
        fondo_sala() + nino_busto(48, 48, (ROJO, ROJO_OSCURO)) + [
            E(106, 68, 22, 10, BLANCO, GRIS_OSCURO, 2.0),
            P([(92, 66), (118, 66), (118, 46)], "#fde68a", NARANJA_OSCURO, 2.0),
            R(92, 60, 26, 6, 2, BARRO),
            E(112, 44, 4, 4, ROJO, ROJO_OSCURO, 1.4),
        ],
        "Niño tocándose la barriga encantado ante un trozo delicioso de tarta.")
    put("sensory", "D",
        fondo_mesa() + [
            R(36, 30, 86, 48, 6, MADERA, MADERA_OSCURA, 2.2),
            R(44, 37, 32, 15, 3, "#e0f2fe", AGUA_OSCURO, 1.6),
            R(82, 37, 32, 15, 3, "#fef08a", AMARILLO_OSCURO, 1.6),
            R(44, 57, 32, 15, 3, "#bbf7d0", VERDE_OSCURO, 1.6),
            R(82, 57, 32, 15, 3, "#fbcfe8", ROSA_OSCURO, 1.6),
            L("M48 44 L72 44 M86 41 L90 48 L96 41 L102 48 L108 41", GRIS_OSCURO, 1.5),
            E(54, 64, 3, 3, VERDE_OSCURO),
            E(64, 64, 3, 3, VERDE_OSCURO),
        ] + _mano_indice(118, 70, -1, -1, (ROJO, ROJO_OSCURO)),
        "Tablero sensorial con cuatro texturas distintas exploradas con el tacto.")
    put("shoulders", "D",
        fondo_sala() + nino_busto(78, 48, (AZUL, AZUL_OSCURO)) + [
            L("M65 66 L57 60 L67 55", PELB, 5.2),
            L("M65 66 L57 60 L67 55", PEL, 3.0),
            L("M91 66 L99 60 L89 55", PELB, 5.2),
            L("M91 66 L99 60 L89 55", PEL, 3.0),
            E(67, 55, 5.5, 5.5, None, ROJO, 2.0),
            E(89, 55, 5.5, 5.5, None, ROJO, 2.0),
        ],
        "Niño señalando y tocando ambos hombros resaltados con aros.")
    put("slimy", "D",
        fondo_prado() + [
            F("M36 74 Q54 58 78 64 Q102 58 116 74 Q78 82 36 74 Z", "#84cc16", VERDE_OSCURO, 2.2),
            L("M68 38 L66 66 M78 36 L76 64 M88 38 L86 64", "#84cc16", 2.8),
            E(76, 52, 2.8, 4.0, "#a3e635", VERDE_OSCURO, 1.2),
            E(86, 54, 2.5, 3.5, "#a3e635", VERDE_OSCURO, 1.2),
            E(78, 30, 12, 7, PEL, PELB, 2.0),
            R(90, 26, 22, 9, 4, AZUL, AZUL_OSCURO, 1.8),
            L("M68 32 L64 40 M75 34 L73 42 M82 34 L81 42 M88 32 L89 39", PELB, 4.0),
            L("M68 32 L64 40 M75 34 L73 42 M82 34 L81 42 M88 32 L89 39", PEL, 2.2),
        ],
        "Sustancia verde viscosa y pegajosa con hilos colgando al retirar la mano.")
    put("smallest", "D",
        fondo_mesa() + [
            E(44, 56, 17, 17, AZUL, AZUL_OSCURO, 2.0),
            E(78, 62, 11, 11, VERDE, VERDE_OSCURO, 2.0),
            E(106, 68, 5.5, 5.5, ROJO, ROJO_OSCURO, 2.0),
        ] + _frecha(106, 40, 106, 58, ROJO_OSCURO, 2.4),
        "Tres bolas ordenadas de grande a minúscula con una flecha marcando la más pequeña.")
    put("soft or rough", "D",
        fondo_mesa() + [
            E(44, 56, 11, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(58, 56, 11, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(51, 50, 11, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(51, 55, 13, 8, BLANCO),
            P([(92, 68), (96, 48), (104, 56), (112, 44), (122, 68)], BARRO, "#451a03", 2.0),
            L("M78 24 L78 76", GRIS_OSCURO, 1.6),
        ] + _mano_indice(52, 74, 0, -1, (AZUL, AZUL_OSCURO)) + _mano_indice(108, 74, 0, -1, (ROJO, ROJO_OSCURO)),
        "Comparación táctil entre algodón muy suave a la izquierda y roca áspera a la derecha.")
    put("sole", "D",
        fondo_sala() + [
            F("M64 74 C56 68 58 46 66 36 C74 28 88 32 88 46 C88 60 80 78 64 74 Z", PEL, PELB, 2.2),
            E(63, 28, 3.2, 4.2, PEL, PELB, 1.6),
            E(70, 26, 2.8, 3.8, PEL, PELB, 1.5),
            E(77, 27, 2.6, 3.5, PEL, PELB, 1.5),
            E(83, 29, 2.4, 3.2, PEL, PELB, 1.5),
            E(88, 33, 2.2, 2.8, PEL, PELB, 1.4),
            E(73, 55, 8, 12, None, ROJO, 2.0),
        ] + _mano_indice(106, 56, -1, 0, (AZUL, AZUL_OSCURO)),
        "Planta del pie descalzo destacada en el centro mientras el dedo la toca.")
    put("speckled", "D",
        fondo_sala() + [
            E(74, 54, 18, 24, "#fef3c7", BARRO, 2.2),
            E(68, 42, 2.5, 2.5, BARRO),
            E(80, 46, 3.0, 2.5, BARRO),
            E(65, 58, 2.8, 3.2, BARRO),
            E(77, 62, 2.2, 2.2, BARRO),
            E(72, 51, 3.2, 2.6, TIERRA),
            E(82, 68, 2.4, 2.4, TIERRA),
        ] + _mano_indice(112, 54, -1, 0, (VERDE, VERDE_OSCURO)),
        "Huevo claro cubierto de motas y pintitas marrones tocadas con el dedo.")
    put("spiky", "D",
        fondo_prado() + [
            E(66, 62, 18, 14, BARRO, "#451a03", 2.0),
            L("M52 54 L42 42 M60 48 L56 34 M70 48 L72 34 M80 52 L90 42 M83 62 L94 60", "#451a03", 2.4),
            E(54, 64, 1.8, 1.8, TINTA),
        ] + _mano_indice(112, 48, -1, 1, (ROJO, ROJO_OSCURO)),
        "Erizo con púas afiladas mientras un dedo se acerca despacio con cuidado.")
    put("spiky pineapple", "D",
        fondo_mesa() + [
            P([(62, 42), (50, 20), (66, 34), (74, 14), (80, 34), (96, 20), (84, 42)], VERDE, VERDE_OSCURO, 2.0),
            E(73, 60, 18, 21, AMARILLO, NARANJA_OSCURO, 2.2),
            L("M60 50 L86 70 M60 70 L86 50", NARANJA_OSCURO, 1.4),
        ] + _mano_indice(108, 24, -1, 0, (ROJO, ROJO_OSCURO)),
        "Piña tropical destacando las hojas pinchudas de su corona tocadas con cuidado.")
    put("spiny", "D",
        fondo_mar() + [
            L("M74 56 L42 36 M74 56 L74 22 M74 56 L106 36 M74 56 L36 62 M74 56 L112 62 M74 56 L50 80 M74 56 L98 80", NEGRO, 2.6),
            E(74, 56, 15, 13, MORADO, NEGRO, 2.2),
        ] + _mano_indice(118, 42, -1, 1, (AZUL, AZUL_OSCURO)),
        "Cuerpo redondo lleno de largas púas radiales y dedo cauteloso acercándose.")
    put("spotted", "D",
        fondo_mesa() + [
            P([(42, 40), (112, 40), (77, 76)], "#bae6fd", AZUL_OSCURO, 2.2),
            E(64, 50, 4.5, 4.5, ROJO),
            E(88, 50, 4.5, 4.5, ROJO),
            E(76, 61, 4.5, 4.5, AMARILLO_OSCURO),
            E(76, 46, 3.5, 3.5, VERDE),
        ] + _mano_indice(114, 58, -1, -1, (ROJO, ROJO_OSCURO)),
        "Pañuelo triangular de lunares grandes de colores tocado con el dedo.")
    put("spotty", "D",
        fondo_sala() + [
            F("M54 34 L42 48 L52 54 L56 46 L56 76 L98 76 L98 46 L102 54 L112 48 L100 34 Z", VERDE, VERDE_OSCURO, 2.0),
            E(68, 48, 4, 4, AMARILLO),
            E(84, 50, 4, 4, ROJO),
            E(72, 64, 4, 4, AZUL),
            E(88, 66, 4, 4, BLANCO),
        ] + _mano_indice(112, 68, -1, 0, (NARANJA, NARANJA_OSCURO)),
        "Camiseta llena de lunares variados tocados con el dedo.")
    put("squeaky clean", "D",
        fondo_sala() + _mano_abierta(60, 56, 0.9, (AZUL, AZUL_OSCURO)) + _mano_abierta(96, 56, 0.9, (AZUL, AZUL_OSCURO))
        + _estrella(40, 30, 6, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(116, 30, 7, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(78, 24, 5, "#bae6fd", AGUA_OSCURO, 1.2),
        "Manos lavadas relucientes y resplandecientes con destellos de limpieza total.")
    put("stripy", "D",
        fondo_mesa() + [
            R(42, 40, 72, 34, 4, BLANCO, AZUL_OSCURO, 2.0),
            R(43, 47, 70, 6, 0, ROJO),
            R(43, 60, 70, 6, 0, VERDE),
            L("M36 44 L42 44 M36 56 L42 56 M36 68 L42 68 M114 44 L120 44 M114 56 L120 56 M114 68 L120 68", GRIS_OSCURO, 1.6),
        ] + _mano_indice(112, 74, -1, -1, (AZUL, AZUL_OSCURO)),
        "Bufanda o pañuelo con franjas de rayas horizontales tocada con la mano.")
    put("sugary", "D",
        fondo_mesa() + [
            E(74, 58, 22, 18, "#fde68a", NARANJA_OSCURO, 2.2),
            E(74, 58, 7, 5, "#fef3c7", NARANJA_OSCURO, 1.6),
            E(62, 50, 2.2, 2.2, BLANCO, GRIS_OSCURO, 0.8),
            E(84, 50, 2.2, 2.2, BLANCO, GRIS_OSCURO, 0.8),
            E(66, 66, 2.2, 2.2, BLANCO, GRIS_OSCURO, 0.8),
            E(86, 64, 2.2, 2.2, BLANCO, GRIS_OSCURO, 0.8),
        ] + _mano_indice(112, 52, -1, 0, (ROSA, ROSA_OSCURO)),
        "Rosquilla dulce cubierta de cristalitos blancos de azúcar.")
    put("sun-kissed", "D",
        fondo_cielo() + _sol(34, 24, 12) + nino_busto(84, 48, (AMARILLO, AMARILLO_OSCURO)) + [
            L("M48 32 L64 42 M42 38 L58 50", AMARILLO_OSCURO, 2.0),
            E(76, 56, 4.5, 3, ROSA),
            E(92, 56, 4.5, 3, ROSA),
        ],
        "Sol iluminando directamente las mejillas cálidas y sonrosadas del niño.")
    put("tag", "D",
        fondo_prado() + nino_corriendo(50, 34, 1, (AZUL, AZUL_OSCURO)) + nino_corriendo(96, 34, 1, (ROJO, ROJO_OSCURO)) + [
            L("M66 56 L88 52", PEL, 3.6),
            E(90, 52, 6, 6, None, AMARILLO_OSCURO, 2.0),
        ],
        "Un niño corriendo alcanza y toca el hombro de su amigo para pillarlo.")
    put("tag game", "D",
        fondo_prado() + nino_corriendo(36, 34, 1, (VERDE, VERDE_OSCURO)) + nino_corriendo(78, 34, 1, (AMARILLO, AMARILLO_OSCURO)) + nino_corriendo(118, 34, 1, (MORADO, "#5b21b6")) + [
            L("M58 40 Q78 30 98 40", GRIS_OSCURO, 1.8),
        ],
        "Varios niños corriendo por el parque jugando al juego de pillar.")
    put("tambourine", "D",
        fondo_sala() + [
            E(72, 54, 21, 21, "#fde68a", MADERA_OSCURA, 3.0),
            E(72, 35, 3.5, 2.2, GRIS, GRIS_OSCURO, 1.2),
            E(91, 54, 2.2, 3.5, GRIS, GRIS_OSCURO, 1.2),
            E(72, 73, 3.5, 2.2, GRIS, GRIS_OSCURO, 1.2),
            E(53, 54, 2.2, 3.5, GRIS, GRIS_OSCURO, 1.2),
        ] + _mano_indice(108, 62, -1, -1, (ROJO, ROJO_OSCURO)) + _notas_col(36, 36),
        "Pandereta redonda con sonajas metálicas tocada con la mano al ritmo musical.")
    put("tap lightly", "D",
        fondo_sala() + [
            R(44, 34, 18, 42, 7, VERDE, VERDE_OSCURO, 2.0),
            R(50, 66, 42, 14, 6, PEL, PELB, 2.0),
            E(56, 72, 9, 9, PEL, PELB, 1.8),
            L("M66 54 Q70 50 74 54 M68 48 Q72 44 76 48", AZUL_OSCURO, 1.5),
        ] + _mano_indice(92, 46, -1, 1, (AZUL, AZUL_OSCURO)),
        "Dedo dando toquecitos muy suaves sobre la rodilla.")
    put("the grass tickles", "D",
        fondo_prado() + _nino_pie(64, 34, (VERDE, VERDE_OSCURO)) + [
            L("M48 82 L44 64 M54 82 L56 60 M60 82 L58 62 M68 82 L70 62 M74 82 L72 60 M80 82 L84 64", HERBAB, 2.6),
            L("M50 70 Q54 66 58 70 M70 70 Q74 66 78 70", AMARILLO_OSCURO, 1.8),
        ],
        "Niño riendo sobre el prado mientras las briznas altas de hierba le hacen cosquillas.")
    put("tickly grass", "D",
        fondo_prado() + [
            F("M44 48 C42 30 62 30 64 48 L66 68 L44 68 Z", PEL, PELB, 2.0),
            E(46, 28, 2.8, 3.5, PEL, PELB, 1.4),
            E(52, 26, 2.6, 3.2, PEL, PELB, 1.4),
            E(58, 28, 2.4, 3.0, PEL, PELB, 1.4),
            L("M62 78 L64 46 M70 78 L72 40 M78 78 L84 44 M86 78 L94 50 M96 78 L104 46", VERDE_OSCURO, 2.4),
            L("M64 46 L68 38 M72 40 L78 34 M84 44 L90 36", HERBAB, 1.8),
        ],
        "Hierba alta y fina rozando la planta del pie descalzo haciendo cosquillas.")
    put("tinkly", "D",
        fondo_sala() + [
            F("M60 66 L66 36 C68 28 84 28 86 36 L92 66 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            E(76, 68, 4.5, 4.5, DORADO, AMARILLO_OSCURO, 1.8),
            L("M76 28 L76 18", BARRO, 3.0),
        ] + _notas_col(42, 44) + ondas_sonido(98, 48, AMARILLO_OSCURO, 1),
        "Campanita dorada emitiendo un tintineo suave y notas ligeras.")
    put("top to toe", "D",
        fondo_sala() + _nino_pie(64, 34, (ROJO, ROJO_OSCURO)) + _frecha(102, 24, 102, 78, AZUL_OSCURO, 2.6) + [
            E(64, 24, 6, 4, None, ROJO, 1.6),
            E(64, 78, 8, 4, None, ROJO, 1.6),
        ],
        "Niño entero con flecha vertical recorriendo de la coronilla de la cabeza a los pies.")
    put("touch", "D",
        fondo_mesa() + [
            R(44, 44, 38, 28, 5, MADERA, MADERA_OSCURA, 2.2),
            E(82, 56, 5, 5, None, AZUL_OSCURO, 1.6),
        ] + _mano_indice(106, 56, -1, 0, (VERDE, VERDE_OSCURO)),
        "Dedo índice tocando suavemente la superficie lisa de un bloque cercano.")
    put("twiggy", "D",
        fondo_prado() + [
            F("M40 58 C40 78 112 78 112 58 Z", BARRO, "#451a03", 2.2),
            L("M42 60 L108 64 M46 66 L104 60 M52 56 L96 68 M60 72 L94 56", TIERRA_CLARA, 2.0),
            L("M36 56 L48 62 M116 56 L104 62", "#451a03", 2.2),
        ] + _mano_indice(108, 36, -1, 1, (NARANJA, NARANJA_OSCURO)),
        "Nido tejido con ramitas secas entrelazadas tocado con la mano.")
    put("warm as toast", "D",
        fondo_sala() + [
            F("M30 52 C28 38 64 38 62 52 L60 74 L32 74 Z", NARANJA_OSCURO, "#7c2d12", 2.0),
            F("M34 52 C33 42 59 42 58 52 L56 70 L36 70 Z", "#fde68a"),
        ] + ondas_calor(36, 30, ROJO) + [
            E(104, 62, 18, 12, "#fef08a", NARANJA_OSCURO, 2.2),
            L("M94 54 Q104 64 114 54", NARANJA_OSCURO, 1.6),
            E(92, 50, 10, 10, PEL, PELB, 2.0),
            L("M90 41 Q92 36 96 40", BARRO, 1.8),
            E(89, 49, 1.3, 1.5, TINTA),
            E(95, 49, 1.3, 1.5, TINTA),
            L("M89 54 Q92 56 95 54", "#9a3412", 1.4),
        ],
        "Tostada dorada calentita junto a un bebé arropado bien abrigado.")
    put("warm chestnut", "D",
        fondo_mesa() + _castana(68, 60, 15) + ondas_calor(58, 32, ROJO) + _mano_indice(108, 54, -1, 0, (ROJO, ROJO_OSCURO)),
        "Castaña recién asada con ondas de calor subiendo antes de tocarla.")
    put("warm feet", "D",
        fondo_sala() + bebe(68, 50, "#e0f2fe", AGUA_OSCURO, 1) + [
            E(92, 62, 5, 4, PEL, PELB, 1.6),
            E(96, 56, 5, 4, PEL, PELB, 1.6),
            E(104, 62, 9, 8, PEL, PELB, 1.8),
        ] + ondas_calor(84, 38, NARANJA_OSCURO),
        "Manos arropando y frotando los pies descalzos del bebé para darles calor.")
    put("warm hands", "D",
        fondo_sala() + _mano_abierta(56, 58, 0.92, (NARANJA, NARANJA_OSCURO)) + _mano_abierta(100, 58, 0.92, (NARANJA, NARANJA_OSCURO)) + ondas_calor(68, 28, ROJO),
        "Dos manos abiertas irradiando calor suave.")
    put("warm hands, warm heart", "D",
        fondo_sala() + nino_busto(78, 48, (ROJO, ROJO_OSCURO)) + [
            E(72, 66, 6.5, 5.5, PEL, PELB, 1.6),
            E(84, 66, 6.5, 5.5, PEL, PELB, 1.6),
            F("M78 62 Q73 56 78 52 Q83 56 78 62 Z", "#fecaca"),
        ] + ondas_calor(38, 60, NARANJA_OSCURO) + ondas_calor(98, 60, NARANJA_OSCURO),
        "Niño posando ambas manos calientes con ternura sobre el pecho.")
    put("warm up", "D",
        fondo_prado() + nino_corriendo(76, 34, 1, (NARANJA, NARANJA_OSCURO)) + [
            L("M44 40 L54 46 M44 58 L54 54 M108 40 L98 46 M108 58 L98 54", ROJO, 2.2),
        ],
        "Niño moviéndose con energía y balanceando brazos para entrar en calor.")
    put("warmer", "D",
        fondo_sala() + [
            R(68, 20, 16, 48, 8, BLANCO, GRIS_OSCURO, 2.0),
            E(76, 68, 13, 13, ROJO, GRIS_OSCURO, 2.0),
            R(73, 28, 6, 40, 3, ROJO),
        ] + _frecha(98, 64, 98, 26, ROJO_OSCURO, 2.6) + ondas_calor(38, 44, NARANJA),
        "Termómetro con la barra roja subiendo y flecha hacia arriba indicando más calor.")
    put("wash thoroughly", "D",
        fondo_sala() + [
            R(36, 56, 20, 12, 4, AZUL, AZUL_OSCURO, 1.8),
            R(100, 56, 20, 12, 4, AZUL, AZUL_OSCURO, 1.8),
            E(68, 58, 14, 10, PEL, PELB, 2.0),
            E(88, 58, 14, 10, PEL, PELB, 2.0),
            L("M72 48 L72 64 M78 46 L78 66 M84 48 L84 64", PELB, 2.2),
            E(66, 38, 6, 6, BLANCO, AGUA_OSCURO, 1.5),
            E(78, 34, 7.5, 7.5, BLANCO, AGUA_OSCURO, 1.5),
            E(92, 40, 5.5, 5.5, BLANCO, AGUA_OSCURO, 1.5),
        ],
        "Manos entrelazadas lavando a fondo entre todos los dedos con abundante espuma.")
    put("wash, wash the socks", "D",
        fondo_sala() + [
            F("M36 54 L116 54 L108 78 L44 78 Z", "#bae6fd", AGUA_OSCURO, 2.2),
            L("M42 54 Q56 49 72 54 Q92 59 110 54", AGUA_OSCURO, 1.8),
            F("M64 30 L78 30 L78 48 Q78 52 90 52 C95 52 95 62 88 62 L68 62 Q62 62 62 54 Z", ROJO, ROJO_OSCURO, 2.0),
            R(65, 35, 12, 4, 0, AMARILLO),
            R(65, 42, 12, 3, 0, BLANCO),
            E(52, 48, 5, 5, BLANCO, AGUA_OSCURO, 1.4),
            E(98, 46, 6, 6, BLANCO, AGUA_OSCURO, 1.4),
        ],
        "Calcetín rayado frotándose en un barreño lleno de agua y burbujas de jabón.")
    put("wash, wash, wash", "D",
        fondo_sala() + [
            L("M42 22 L68 22 L68 30", GRIS_OSCURO, 5.0),
            L("M68 30 L68 42", AGUA, 4.0),
            E(66, 56, 12, 9, PEL, PELB, 1.8),
            E(80, 58, 12, 9, PEL, PELB, 1.8),
            E(58, 44, 6, 6, BLANCO, AGUA_OSCURO, 1.4),
            E(76, 42, 7, 7, BLANCO, AGUA_OSCURO, 1.4),
            E(90, 48, 5, 5, BLANCO, AGUA_OSCURO, 1.4),
        ],
        "Manos bajo el grifo enjabonándose con espuma y agua corriente.")
    put("wobbly tooth", "D",
        fondo_sala() + [
            E(78, 54, 28, 17, "#991b1b", TINTA, 2.2),
            R(58, 42, 8, 9, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(67, 42, 8, 9, 2, BLANCO, GRIS_OSCURO, 1.4),
            F("M77 41 L85 43 L83 52 L75 50 Z", "#fef08a", NARANJA_OSCURO, 1.8),
            R(87, 42, 8, 9, 2, BLANCO, GRIS_OSCURO, 1.4),
            L("M72 34 L77 30 M88 34 L83 30", NARANJA_OSCURO, 1.8),
        ],
        "Boca abierta destacando un diente flojo torcido con líneas de movimiento.")
    put("woolly hat", "D",
        fondo_cielo() + [
            F("M44 68 C44 36 106 36 106 68 Z", ROJO, ROJO_OSCURO, 2.2),
            R(40, 64, 70, 14, 5, BLANCO, ROJO_OSCURO, 2.2),
            L("M52 65 L52 77 M64 65 L64 77 M76 65 L76 77 M88 65 L88 77 M98 65 L98 77", ROJO_OSCURO, 1.6),
            E(75, 33, 8, 8, BLANCO, ROJO_OSCURO, 1.8),
        ] + _mano_indice(116, 52, -1, 0, (AZUL, AZUL_OSCURO)),
        "Gorro grueso de lana tejida tocado con la mano para sentir el punto.")
    put("you're it", "D",
        fondo_prado() + _nino_pie(54, 34, (VERDE, VERDE_OSCURO)) + [
            L("M70 54 L94 52", PEL, 3.6),
            E(96, 52, 5.5, 5.5, None, ROJO, 2.0),
            L("M96 42 L96 34 M102 45 L108 39", ROJO_OSCURO, 2.0),
        ] + _nino_pie(106, 34, (AMARILLO, AMARILLO_OSCURO)),
        "Niño tocando el hombro de un compañero para avisarle de que ahora le toca pillar.")
    put("yummy chestnut", "D",
        fondo_sala() + nino_busto(48, 48, (AMARILLO, AMARILLO_OSCURO)) + _castana(106, 56, 17) + [
            L("M100 44 L106 50 L112 44", "#fde68a", 2.0),
        ] + ondas_calor(100, 28, NARANJA_OSCURO),
        "Niño saboreando una rica castaña recién asada y humeante.")

    # ── open_close (cierre: 107 cubiertas: 5 Fluent directas arriba + 102 escenas aquí) ──
    put("action", "D",
        fondo_sala() + _nino_pie(48, 34, (AZUL, AZUL_OSCURO)) + [
            L("M62 50 L82 40 M62 58 L82 60", PEL, 3.8),
            R(86, 46, 36, 22, 3, NEGRO, TINTA, 2.0),
            P([(86, 46), (118, 30), (121, 36), (88, 50)], NEGRO, TINTA, 1.8),
            L("M93 43 L97 48 M103 38 L107 43 M113 33 L117 38", BLANCO, 2.4),
            L("M92 56 L116 56", BLANCO, 1.8),
            P([(100, 24), (105, 32), (110, 24)], ROJO_OSCURO),
        ],
        "Niño dando una palmada con los brazos frente a una claqueta de cine abierta que se cierra.")
    put("anemone", "D",
        fondo_mar() + [
            F("M44 76 Q50 58 78 58 Q106 58 112 76 Z", BARRO, "#451a03", 2.0),
            L("M58 62 Q40 50 38 36 Q42 30 46 34", ROSA, 4.2),
            L("M64 60 Q54 40 52 26 Q56 22 60 26", "#f472b6", 4.2),
            L("M72 58 Q68 38 68 22", ROSA, 4.2),
            L("M78 58 Q78 36 80 20", "#f472b6", 4.2),
            L("M84 58 Q90 38 94 24", ROSA, 4.2),
            L("M90 60 Q100 42 106 30", "#f472b6", 4.2),
            L("M96 62 Q114 50 118 38", ROSA, 4.2),
            E(78, 56, 18, 7, ROSA_OSCURO, "#831843", 1.8),
        ] + [
            E(cx, cy, 3.2, 3.2, "#fbcfe8", ROSA_OSCURO, 1.2)
            for cx, cy in [(38, 36), (52, 26), (68, 22), (80, 20), (94, 24), (106, 30), (118, 38)]
        ],
        "Anémona marina sobre roca abriendo y meciendo sus tentáculos como pétalos en el fondo del mar.")
    put("awake", "D",
        fondo_sala() + [
            R(24, 16, 26, 26, 3, "#e0f2fe", MADERA_OSCURA, 2.0),
            E(37, 26, 6, 6, AMARILLO),
            R(48, 58, 66, 22, 6, "#bae6fd", AZUL_OSCURO, 2.0),
            E(80, 44, 14, 14, PEL, PELB, 2.0),
            E(74, 42, 3.5, 4.0, BLANCO, TINTA, 1.4),
            E(86, 42, 3.5, 4.0, BLANCO, TINTA, 1.4),
            E(74, 42, 1.6, 1.8, TINTA),
            E(86, 42, 1.6, 1.8, TINTA),
            L("M74 51 Q80 55 86 51", "#9a3412", 1.5),
        ],
        "Niño bien despierto en la cama por la mañana con los ojos muy abiertos.")
    put("bark", "D",
        fondo_prado() + [
            R(44, 52, 34, 20, 8, BARRO, "#451a03", 2.0),
            R(48, 70, 6, 12, 2, BARRO, "#451a03", 1.6),
            R(68, 70, 6, 12, 2, BARRO, "#451a03", 1.6),
            E(84, 44, 13, 12, BARRO, "#451a03", 2.0),
            P([(84, 44), (104, 40), (96, 48)], BARRO, "#451a03", 1.8),
            P([(86, 48), (102, 54), (94, 54)], "#7c2d12", "#451a03", 1.8),
            E(86, 40, 1.8, 1.8, TINTA),
            E(74, 42, 5, 9, "#451a03"),
        ] + ondas_sonido(108, 46, ROJO_OSCURO, 1),
        "Perro abriendo el hocico y ladrando con ondas de sonido hacia delante.")
    put("bedtime story", "D",
        fondo_noite() + [
            R(42, 48, 72, 30, 5, "#bae6fd", AZUL_OSCURO, 2.0),
        ] + libro_prop(58, 30, 42, MORADO) + _estrella(116, 24, 7, AMARILLO, AMARILLO_OSCURO, 1.4),
        "Cuento ilustrado abierto bajo la noche estrellada a la hora de dormir.")
    put("big mouth, hippo", "D",
        fondo_prado() + [
            E(74, 48, 28, 22, "#a78bfa", "#5b21b6", 2.2),
            E(60, 34, 6, 6, BLANCO, "#5b21b6", 1.8),
            E(60, 34, 2.5, 2.5, TINTA),
            F("M64 48 L108 42 L106 68 L64 62 Z", "#fda4af", "#9d174d", 2.2),
            R(94, 43, 6, 7, 2, BLANCO, GRIS_OSCURO, 1.2),
            R(94, 60, 6, 7, 2, BLANCO, GRIS_OSCURO, 1.2),
        ],
        "Hipopótamo abriendo enorme su gran boca enseñando los dientes.")
    put("bigger", "D",
        fondo_mesa() + [
            E(46, 62, 10, 10, AZUL, AZUL_OSCURO, 2.0),
        ] + _frecha(62, 56, 78, 56, VERDE_OSCURO, 2.6) + [
            E(104, 54, 22, 22, AZUL, AZUL_OSCURO, 2.2),
        ],
        "Círculo pequeño pasando por flecha a otro círculo notablemente más grande.")
    put("bigger and bigger", "D",
        fondo_cielo() + [
            E(26, 65, 5, 5, NARANJA, NARANJA_OSCURO, 1.8),
            E(47, 61, 8, 8, NARANJA, NARANJA_OSCURO, 1.8),
            E(77, 54, 13, 13, NARANJA, NARANJA_OSCURO, 2.0),
            E(118, 45, 19, 19, NARANJA, NARANJA_OSCURO, 2.2),
        ] + _frecha(26, 22, 118, 22, ROJO_OSCURO, 2.2),
        "Serie progresiva de cuatro globos creciendo cada vez más.")
    put("bigger than an ant, smaller than a mouse", "D",
        fondo_prado() + [
            E(34, 68, 3, 2.5, NEGRO),
            E(40, 68, 3.5, 2.5, NEGRO),
            E(72, 58, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            E(114, 52, 17, 13, GRIS, GRIS_OSCURO, 2.0),
            E(104, 42, 6, 6, ROSA, GRIS_OSCURO, 1.6),
            L("M130 56 Q142 52 140 42", GRIS_OSCURO, 2.0),
            L("M52 54 L46 58 L52 62 M94 54 L100 58 L94 62", TINTA, 2.0),
        ],
        "Escala visual mostrando algo mayor que una hormiga y menor que un ratón.")
    put("blanket and a book", "D",
        fondo_sala() + [
            R(36, 48, 38, 26, 5, ROJO, ROJO_OSCURO, 2.0),
            L("M38 56 L72 56 M38 65 L72 65", AMARILLO, 1.8),
        ] + libro_prop(84, 42, 40, VERDE),
        "Manta abrigada doblada junto a un cuento abierto.")
    put("blink", "D",
        fondo_sala() + [
            E(56, 50, 14, 11, BLANCO, TINTA, 2.2),
            E(56, 50, 5.5, 6.5, AZUL_OSCURO),
            E(54, 48, 1.8, 1.8, BLANCO),
            L("M86 50 Q100 58 114 50", TINTA, 2.8),
            L("M92 54 L90 59 M100 55 L100 60 M108 54 L110 59", TINTA, 1.6),
            L("M88 38 Q100 32 112 38", AZUL_OSCURO, 1.6),
        ],
        "Dos ojos: uno abierto y el otro cerrándose rápido al parpadear.")
    put("blub, blub, blub", "D",
        fondo_mar() + [
            E(72, 58, 18, 11, NARANJA, NARANJA_OSCURO, 2.2),
            P([(90, 58), (104, 48), (104, 68)], NARANJA, NARANJA_OSCURO, 2.0),
            E(62, 56, 2.2, 2.2, TINTA),
            E(54, 60, 3, 2, ROJO_OSCURO),
            E(46, 48, 4, 4, "#e0f2fe", AGUA_OSCURO, 1.5),
            E(42, 36, 5.5, 5.5, "#e0f2fe", AGUA_OSCURO, 1.5),
            E(48, 24, 7, 7, "#e0f2fe", AGUA_OSCURO, 1.5),
        ],
        "Pez naranja abriendo la boca bajo el agua y soltando tres burbujas hacia arriba.")
    put("box lid", "D",
        fondo_mesa() + [
            R(48, 48, 56, 30, 3, TIERRA_CLARA, BARRO, 2.2),
            R(44, 30, 64, 10, 3, "#fde68a", BARRO, 2.2),
        ] + _frecha(76, 18, 76, 28, ROJO_OSCURO, 2.2),
        "Caja de cartón con su tapa superior bajando para cerrarla.")
    put("bubbly", "D",
        fondo_sala() + [
            R(50, 44, 52, 36, 5, "#bae6fd", AGUA_OSCURO, 2.2),
        ] + [
            E(cx, cy, r, r, BLANCO, AGUA_OSCURO, 1.6)
            for cx, cy, r in [(62, 42, 6), (76, 38, 7), (90, 42, 5.5), (68, 28, 5), (84, 24, 6.5), (56, 28, 4.5), (96, 30, 4)]
        ],
        "Recipiente burbujeante rebosando pompas y burbujas en el aire.")
    put("catch", "D",
        fondo_prado() + pelota_prop(78, 46, 12, ROJO, ROJO_OSCURO) + [
            L("M44 68 L62 52", PEL, 4.5),
            L("M112 68 L94 52", PEL, 4.5),
            E(63, 50, 6.5, 6.5, PEL, PELB, 1.8),
            E(93, 50, 6.5, 6.5, PEL, PELB, 1.8),
        ],
        "Ambas manos abiertas cerrándose en el aire para atrapar una pelota.")
    put("catch drops", "D",
        fondo_cielo() + [
            E(64, 24, 16, 11, NUBE, NUBE_B, 1.8),
            E(82, 24, 16, 11, NUBE, NUBE_B, 1.8),
            E(73, 19, 14, 10, NUBE),
        ] + _gotas(60, 44, 3, AGUA) + [
            R(58, 66, 38, 9, 4, PEL, PELB, 2.0),
            L("M58 68 L44 62 M96 68 L108 72", PEL, 4.0),
        ],
        "Mano abierta hacia arriba recogiendo gotas finas de lluvia.")
    put("catch the snowflake", "D",
        fondo_noite() + [
            L("M78 16 L78 38 M67 27 L89 27 M70 19 L86 35 M86 19 L70 35", BLANCO, 2.4),
            R(61, 45, 34, 28, 12, ROJO, ROJO_OSCURO, 2.0),
            E(56, 56, 7, 5, ROJO, ROJO_OSCURO, 1.8),
            R(61, 68, 34, 8, 2, BLANCO, ROJO_OSCURO, 1.6),
        ],
        "Manopla estirada esperando atrapar suavemente un copo de nieve que cae.")
    put("cheerful", "D",
        fondo_cielo() + _sol(26, 22, 11) + nino_busto(78, 48, (AMARILLO, AMARILLO_OSCURO), brazos_arriba=True) + [
            E(71, 51, 3.2, 2.0, ROSA),
            E(85, 51, 3.2, 2.0, ROSA),
        ],
        "Niño radiante y alegre levantando los brazos con una sonrisa bajo el sol.")
    put("city lights", "D",
        fondo_noite() + [
            R(28, 42, 22, 44, 2, "#334155", NEGRO, 1.8),
            R(54, 28, 28, 58, 2, "#1e293b", NEGRO, 1.8),
            R(86, 38, 24, 48, 2, "#334155", NEGRO, 1.8),
            R(114, 48, 20, 38, 2, "#1e293b", NEGRO, 1.8),
        ] + [
            R(x, y, 5, 6, 1, AMARILLO)
            for x, y in [(33, 50), (41, 50), (33, 62), (60, 36), (72, 36), (60, 48), (72, 60), (92, 46), (100, 58), (118, 56)]
        ],
        "Edificios de la ciudad de noche con muchas ventanas iluminadas brillando.")
    put("clear", "D",
        [R(0, 0, 156, 92, 0, "#38bdf8")] + _sol(78, 42, 17) + [
            E(24, 30, 14, 9, BLANCO, NUBE_B, 1.4),
            E(132, 30, 14, 9, BLANCO, NUBE_B, 1.4),
        ] + _frecha(44, 30, 26, 30, BLANCO, 2.2) + _frecha(112, 30, 130, 30, BLANCO, 2.2),
        "Cielo completamente despejado apartando las nubes hacia los lados.")
    put("close the book", "D",
        fondo_mesa() + [
            R(44, 34, 34, 40, 2, AZUL, AZUL_OSCURO, 2.0),
            R(48, 36, 26, 36, 1, BLANCO, GRIS_OSCURO, 1.4),
            P([(78, 34), (106, 26), (106, 66), (78, 74)], AZUL, AZUL_OSCURO, 2.0),
        ] + _frecha(102, 22, 62, 22, ROJO_OSCURO, 2.4),
        "Libro abierto doblándose su cubierta hacia la izquierda para cerrarse.")
    put("clothes peg", "D",
        fondo_cielo() + [
            L("M22 34 L134 34", GRIS_OSCURO, 2.0),
            P([(68, 22), (82, 22), (86, 68), (77, 68), (75, 42), (73, 68), (64, 68)], NARANJA, NARANJA_OSCURO, 2.0),
            R(66, 38, 18, 4, 1, GRIS_OSCURO),
        ],
        "Pinza naranja abierta y sujeta sobre la cuerda de tender.")
    put("cockle", "D",
        fondo_mar() + [
            F("M44 68 C40 40 62 28 78 28 C94 28 116 40 112 68 Q78 80 44 68 Z", "#fed7aa", BARRO, 2.2),
            L("M78 28 L78 72 M78 28 L60 70 M78 28 L96 70 M78 28 L48 64 M78 28 L108 64", BARRO, 1.6),
        ],
        "Concha redondeada y estriada de berberecho en la orilla marina.")
    put("confetti cannon", "D",
        fondo_cielo() + [
            P([(34, 72), (62, 48), (74, 60), (46, 82)], ROJO, ROJO_OSCURO, 2.2),
            L("M48 64 L58 72", AMARILLO, 4.0),
        ] + [
            E(cx, cy, 3.2, 3.2, col)
            for cx, cy, col in [(82, 38, AMARILLO), (96, 28, AZUL), (112, 38, VERDE), (104, 54, ROJO), (88, 24, MORADO), (120, 26, NARANJA)]
        ] + [
            L("M76 46 L94 34 M80 54 L106 50 M70 40 L82 22", AZUL_OSCURO, 2.0),
        ],
        "Tubo de fiesta lanzando confeti de colores al abrirse de golpe.")
    put("crack, crack", "D",
        fondo_mesa() + [
            E(76, 52, 22, 26, "#fef3c7", BARRO, 2.2),
            L("M76 26 L70 38 L80 46 L72 56 L82 66 L76 78", "#451a03", 2.8),
            L("M50 42 L42 36 M102 42 L110 36", NARANJA_OSCURO, 2.0),
        ],
        "Cáscara agrietándose en zigzag con chasquidos al abrirse.")
    put("day and night", "D",
        [
            R(0, 0, 78, 92, 0, "#bae6fd"),
            R(0, 68, 78, 24, 0, HERBA),
        ] + _sol(38, 32, 15) + [
            R(78, 0, 78, 92, 0, "#1e1b4b"),
            R(78, 68, 78, 24, 0, "#14532d"),
            F("M124 22 C110 24 110 42 124 44 C116 39 116 27 124 22 Z", AMARILLO),
        ] + _estrella(98, 24, 5, AMARILLO, AMARILLO_OSCURO, 1.0) + _estrella(138, 38, 4, AMARILLO, AMARILLO_OSCURO, 1.0) + [
            L("M78 0 L78 92", BLANCO, 2.0),
        ],
        "Escena partida con sol brillante de día a la izquierda y luna con estrellas de noche a la derecha.")
    put("drain away", "D",
        fondo_sala() + [
            E(78, 66, 30, 11, GRIS, GRIS_OSCURO, 2.2),
            E(78, 66, 15, 5.5, NEGRO),
            L("M60 54 Q78 46 96 54 Q94 64 78 66", AGUA, 3.6),
            L("M66 64 Q78 72 90 64", AGUA, 2.6),
            P([(74, 65), (80, 62), (80, 68)], AGUA_OSCURO),
        ] + _frecha(78, 24, 78, 52, AGUA_OSCURO, 2.4),
        "Agua arremolinándose hacia abajo para escurrirse por el desagüe.")
    put("drawer", "D",
        fondo_sala() + [
            R(44, 24, 68, 56, 4, MADERA, MADERA_OSCURA, 2.2),
            R(50, 30, 56, 18, 2, MADERA_OSCURA),
            F("M44 38 L108 38 L118 52 L54 52 Z", "#fde68a", MADERA_OSCURA, 2.0),
            R(54, 52, 64, 14, 2, TIERRA_CLARA, MADERA_OSCURA, 2.0),
            E(86, 59, 4, 4, GRIS_OSCURO),
            R(50, 54, 56, 18, 2, TIERRA_CLARA, MADERA_OSCURA, 1.8),
            E(78, 63, 3.5, 3.5, GRIS_OSCURO),
        ],
        "Mueble de madera con el cajón superior tirado hacia fuera y abierto.")
    put("drawing folder", "D",
        fondo_mesa() + [
            R(44, 28, 68, 48, 4, AZUL, AZUL_OSCURO, 2.2),
            R(50, 22, 56, 36, 2, BLANCO, GRIS_OSCURO, 1.8),
            E(66, 36, 7, 7, AMARILLO),
            P([(62, 54), (78, 36), (94, 54)], VERDE),
            F("M44 40 L112 40 L106 76 L38 76 Z", "#60a5fa", AZUL_OSCURO, 2.2),
        ],
        "Carpeta azul abierta asomando una lámina de dibujo guardada dentro.")
    put("eggshell", "D",
        fondo_mesa() + [
            F("M40 52 C42 74 72 74 74 52 L66 58 L58 50 L50 58 Z", "#fef3c7", BARRO, 2.2),
            F("M84 52 C86 74 116 74 118 52 L110 58 L102 50 L94 58 Z", "#fef3c7", BARRO, 2.2),
        ],
        "Dos mitades vacías de cáscara de huevo abiertas sobre la mesa.")
    put("fingers", "D",
        fondo_sala() + _mano_abierta(52, 56, 1.0, (VERDE, VERDE_OSCURO)) + _mano_abierta(104, 56, 1.0, (VERDE, VERDE_OSCURO)),
        "Ambas manos abiertas mostrando claramente todos los dedos separados.")
    put("flash", "D",
        fondo_noite() + [
            P([(78, 12), (86, 34), (112, 24), (94, 44), (120, 52), (92, 58), (104, 80), (78, 64), (52, 80), (64, 58), (36, 52), (62, 44), (44, 24), (70, 34)], AMARILLO, AMARILLO_OSCURO, 2.0),
            E(78, 48, 10, 10, BLANCO),
        ],
        "Estallido luminoso de flash brillando de golpe sobre fondo oscuro.")
    put("flicker", "D",
        fondo_noite() + [
            R(70, 50, 16, 32, 3, BLANCO, GRIS_OSCURO, 1.8),
            L("M78 50 L78 44", NEGRO, 2.0),
            F("M78 20 Q88 34 78 44 Q68 34 78 20 Z", NARANJA, NARANJA_OSCURO, 1.6),
            E(78, 36, 4, 6, AMARILLO),
            L("M60 28 Q56 34 60 40 M96 28 Q100 34 96 40", "#fde047", 1.8),
        ],
        "Llama de vela parpadeando con leves oscilaciones de luz.")
    put("fly away, bird", "D",
        fondo_cielo() + [
            L("M48 72 L66 64 M104 72 L86 64", PEL, 4.0),
            E(76, 38, 13, 9, AZUL, AZUL_OSCURO, 2.0),
            F("M70 34 Q80 14 96 24 Q84 36 74 36 Z", "#60a5fa", AZUL_OSCURO, 1.8),
            P([(63, 38), (56, 36), (63, 41)], NARANJA),
            E(68, 36, 1.5, 1.5, TINTA),
        ] + _frecha(92, 42, 114, 22, AZUL_OSCURO, 2.2),
        "Manos abriéndose hacia arriba mientras un pájaro azul echa a volar al cielo.")
    put("freezer", "D",
        fondo_sala() + [
            R(44, 20, 50, 58, 4, "#e0f2fe", AGUA_OSCURO, 2.2),
            F("M94 20 L120 14 L120 72 L94 78 Z", "#bae6fd", AGUA_OSCURO, 2.0),
            R(52, 28, 34, 14, 2, BLANCO, AGUA_OSCURO, 1.5),
            R(52, 48, 34, 14, 2, BLANCO, AGUA_OSCURO, 1.5),
            L("M69 28 L69 42 M62 35 L76 35", "#38bdf8", 1.8),
            R(58, 52, 8, 8, 1, "#38bdf8"),
            R(70, 52, 8, 8, 1, "#7dd3fc"),
        ],
        "Puerta del congelador abierta mostrando hielo y frío helado en su interior.")
    put("gate", "D",
        fondo_prado() + [
            R(28, 36, 10, 44, 2, MADERA_OSCURA),
            R(118, 36, 10, 44, 2, MADERA_OSCURA),
            P([(38, 42), (76, 50), (76, 76), (38, 70)], MADERA, MADERA_OSCURA, 2.0),
            P([(118, 42), (86, 50), (86, 76), (118, 70)], MADERA, MADERA_OSCURA, 2.0),
            L("M56 46 L56 73 M102 46 L102 73", MADERA_OSCURA, 2.0),
        ],
        "Verja de madera del parque abriéndose por la mitad hacia el camino verde.")
    put("giant shoe", "D",
        fondo_prado() + [
            R(36, 26, 44, 48, 8, ROJO, ROJO_OSCURO, 2.2),
            R(36, 52, 74, 24, 10, ROJO, ROJO_OSCURO, 2.2),
            R(34, 70, 78, 8, 3, BLANCO, GRIS_OSCURO, 1.8),
            L("M66 36 L82 40 M66 44 L82 48", BLANCO, 2.4),
            R(118, 66, 18, 11, 4, AZUL, AZUL_OSCURO, 1.6),
        ],
        "Zapato gigante comparado al lado de un zapatito pequeño en el suelo.")
    put("greener", "D",
        fondo_mesa() + [
            F("M34 64 Q36 36 62 36 Q66 64 34 64 Z", "#bef264", HERBAB, 2.0),
        ] + _frecha(68, 50, 86, 50, VERDE_OSCURO, 2.4) + [
            F("M92 66 Q94 32 124 32 Q128 66 92 66 Z", VERDE_OSCURO, "#064e3b", 2.2),
            L("M94 64 L120 36", "#86efac", 1.8),
        ],
        "Hoja pálida pasando por flecha a otra hoja de un verde mucho más vivo e intenso.")
    put("i'm hungry", "D",
        fondo_sala() + nino_busto(54, 48, (AZUL, AZUL_OSCURO)) + [
            E(104, 34, 26, 18, BLANCO, GRIS_OSCURO, 1.8),
            E(82, 46, 4, 4, BLANCO, GRIS_OSCURO, 1.5),
            E(96, 36, 7.5, 7.5, ROJO, ROJO_OSCURO, 1.4),
            L("M96 29 L98 25", VERDE_OSCURO, 1.8),
            F("M106 38 Q112 28 120 38 Q113 42 106 38 Z", "#f59e0b", NARANJA_OSCURO, 1.4),
        ],
        "Niño tocándose la barriga pensando en comida en un globo sobre la cabeza.")
    put("idea", "D",
        fondo_sala() + nino_busto(78, 48, (VERDE, VERDE_OSCURO)) + [
            E(78, 28, 11, 11, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(74, 38, 8, 5, 1, GRIS, GRIS_OSCURO, 1.4),
            L("M78 11 L78 15 M60 20 L64 23 M96 20 L92 23 M58 32 L63 32 M98 32 L93 32", AMARILLO_OSCURO, 2.0),
        ],
        "Bombilla encendida brillante sobre la cabeza del niño cuando tiene una idea.")
    put("if it's sunny, we go to the beach; if it rains, we read", "D",
        [
            R(0, 0, 78, 92, 0, "#bae6fd"),
            R(0, 66, 78, 26, 0, "#fde68a"),
        ] + _sol(26, 24, 12) + [
            P([(30, 56), (54, 40), (68, 56)], ROJO, ROJO_OSCURO, 1.8),
            L("M49 56 L49 72", MADERA_OSCURA, 2.0),
            R(78, 0, 78, 92, 0, "#cbd5e1"),
            E(112, 22, 16, 10, GRIS, GRIS_OSCURO, 1.8),
        ] + _gotas(100, 38, 2, AGUA_OSCURO) + libro_prop(94, 48, 36, AZUL) + [
            L("M78 0 L78 92", BLANCO, 2.2),
        ],
        "Viñeta partida: playa con sol a la izquierda y nube de lluvia con libro abierto a la derecha.")
    put("it's a star", "D",
        fondo_cielo() + _estrella(78, 48, 34, AMARILLO, AMARILLO_OSCURO, 2.2) + [
            E(78, 42, 7.5, 7.5, PEL, PELB, 1.8),
            R(72, 50, 12, 16, 4, ROJO, ROJO_OSCURO, 1.6),
            L("M72 52 L54 44 M84 52 L102 44 M74 66 L64 78 M82 66 L92 78", PEL, 3.2),
        ],
        "Niño abriendo brazos y piernas en forma de gran estrella dorada.")
    put("lamp", "D",
        fondo_sala() + [
            P([(52, 50), (62, 26), (94, 26), (104, 50)], AMARILLO, AMARILLO_OSCURO, 2.2),
            P([(52, 50), (104, 50), (120, 78), (36, 78)], "#fef9c3"),
            R(75, 50, 6, 24, 2, MADERA_OSCURA),
            R(64, 72, 28, 7, 3, MADERA, MADERA_OSCURA, 1.8),
        ],
        "Lámpara de mesa encendida abriendo un haz cálido de luz amarilla.")
    put("let sand run", "D",
        fondo_prado() + [
            R(44, 24, 40, 12, 5, PEL, PELB, 2.0),
            L("M50 36 L44 48 M60 36 L58 50 M72 36 L74 48", "#eab308", 2.0),
            F("M34 78 Q64 48 96 78 Z", "#fde68a", NARANJA_OSCURO, 2.0),
            E(56, 56, 2, 2, NARANJA_OSCURO),
            E(68, 52, 2, 2, NARANJA_OSCURO),
            E(64, 62, 2, 2, NARANJA_OSCURO),
        ],
        "Mano abierta dejando escurrirse un chorro fino de granos de arena dorada.")
    put("light up", "D",
        fondo_noite() + [
            R(30, 42, 34, 16, 4, AZUL, AZUL_OSCURO, 2.0),
            P([(64, 42), (76, 36), (76, 64), (64, 58)], AMARILLO_OSCURO, NEGRO, 1.8),
            P([(76, 36), (130, 18), (130, 82), (76, 64)], "#fef08a"),
        ],
        "Linterna encendiéndose de golpe para iluminar la oscuridad.")
    put("lights in the dark", "D",
        fondo_noite() + [
            L("M20 26 Q78 46 136 26", GRIS_OSCURO, 1.8),
        ] + [
            E(cx, cy, 6.5, 6.5, AMARILLO, AMARILLO_OSCURO, 1.4)
            for cx, cy in [(36, 32), (62, 39), (92, 39), (118, 32)]
        ] + [
            E(cx, cy, 3, 3, BLANCO)
            for cx, cy in [(36, 32), (62, 39), (92, 39), (118, 32)]
        ],
        "Guirnalda de bombillas luminosas encendidas en una sala muy oscura.")
    put("lunchbox", "D",
        fondo_mesa() + [
            R(44, 46, 68, 32, 5, ROJO, ROJO_OSCURO, 2.2),
            P([(44, 46), (52, 22), (104, 22), (112, 46)], "#fca5a5", ROJO_OSCURO, 2.0),
            R(52, 52, 24, 20, 3, "#fde68a", NARANJA_OSCURO, 1.6),
            E(92, 62, 10, 10, VERDE, VERDE_OSCURO, 1.6),
        ],
        "Fiambrera roja abierta dejando ver el bocadillo y la fruta en su interior.")
    put("morning", "D",
        fondo_prado() + [
            R(0, 0, 156, 62, 0, "#fed7aa"),
            E(78, 62, 22, 22, AMARILLO, NARANJA_OSCURO, 2.2),
            L("M78 30 L78 20 M54 40 L46 32 M102 40 L110 32 M44 56 L34 54 M112 56 L122 54", NARANJA_OSCURO, 2.2),
            R(0, 62, 156, 30, 0, HERBA),
        ] + _nino_pie(114, 34, (AZUL, AZUL_OSCURO)),
        "Amanecer luminoso de mañana con el sol saliendo y niño desperezándose.")
    put("open", "D",
        fondo_sala() + [
            R(48, 26, 46, 54, 3, "#e0f2fe", MADERA_OSCURA, 2.2),
            P([(48, 26), (76, 34), (76, 74), (48, 80)], MADERA, MADERA_OSCURA, 2.2),
            E(70, 54, 2.5, 2.5, DORADO),
        ] + _frecha(84, 52, 114, 52, VERDE_OSCURO, 2.8),
        "Puerta abierta hacia fuera con flecha clara indicando abrir.")
    put("open and shut", "D",
        fondo_sala() + _mano_abierta(48, 56, 0.95, (VERDE, VERDE_OSCURO)) + [
            R(98, 44, 22, 22, 8, PEL, PELB, 2.0),
            R(102, 66, 14, 14, 4, VERDE, VERDE_OSCURO, 1.8),
            L("M99 54 L119 54", PELB, 1.8),
        ] + _frecha(72, 46, 90, 46, AZUL_OSCURO, 2.0) + _frecha(90, 60, 72, 60, AZUL_OSCURO, 2.0),
        "Mano abierta a un lado y puño cerrado al otro alternándose con flechas.")
    put("open like a flower", "D",
        fondo_prado() + [
            L("M78 52 L78 80", VERDE_OSCURO, 3.0),
            E(62, 46, 12, 8, ROSA, ROSA_OSCURO, 1.8),
            E(94, 46, 12, 8, ROSA, ROSA_OSCURO, 1.8),
            E(78, 34, 8, 12, ROSA, ROSA_OSCURO, 1.8),
            E(68, 38, 9, 9, ROSA, ROSA_OSCURO, 1.8),
            E(88, 38, 9, 9, ROSA, ROSA_OSCURO, 1.8),
            E(78, 46, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.8),
        ] + _frecha(48, 42, 34, 28, ROSA_OSCURO, 2.0) + _frecha(108, 42, 122, 28, ROSA_OSCURO, 2.0),
        "Flor abriendo sus pétalos hacia arriba y hacia fuera como una flor que florece.")
    put("open up the fold", "D",
        fondo_mesa() + [
            P([(42, 30), (76, 30), (76, 72), (42, 72)], "#e0f2fe", AZUL_OSCURO, 2.0),
            P([(76, 30), (112, 22), (112, 64), (76, 72)], BLANCO, AZUL_OSCURO, 2.0),
            L("M76 30 L76 72", AZUL_OSCURO, 1.8),
        ] + _frecha(90, 46, 118, 46, VERDE_OSCURO, 2.4),
        "Hoja de papel doblada desplegándose abierta por el pliegue central.")
    put("open wide", "D",
        fondo_sala() + [
            E(60, 50, 22, 22, PEL, PELB, 2.2),
            E(52, 44, 2.2, 2.5, TINTA),
            E(68, 44, 2.2, 2.5, TINTA),
            E(60, 60, 9, 10, "#991b1b", TINTA, 2.0),
            L("M55 64 Q60 68 65 64", ROSA, 2.2),
        ] + cuchara_prop(92, 42, 36),
        "Cara abriendo bien grande la boca frente a una cuchara.")
    put("open your beak", "D",
        fondo_prado() + [
            R(44, 62, 62, 18, 8, BARRO, "#451a03", 2.0),
            E(75, 50, 14, 13, AMARILLO, NARANJA_OSCURO, 2.0),
            E(70, 46, 1.8, 1.8, TINTA),
            P([(85, 44), (104, 34), (92, 50)], NARANJA, NARANJA_OSCURO, 1.8),
            P([(85, 52), (104, 62), (92, 50)], NARANJA, NARANJA_OSCURO, 1.8),
        ],
        "Polluelo en el nido abriendo muy grande su pico naranja.")
    put("open your mouth wide", "D",
        fondo_prado() + [
            E(78, 50, 27, 25, NARANJA_OSCURO, "#7c2d12", 2.0),
            E(58, 30, 8, 8, NARANJA_OSCURO, "#7c2d12", 1.8),
            E(98, 30, 8, 8, NARANJA_OSCURO, "#7c2d12", 1.8),
            E(53, 50, 8, 8, NARANJA_OSCURO),
            E(103, 50, 8, 8, NARANJA_OSCURO),
            E(78, 25, 9, 7, NARANJA_OSCURO),
            E(78, 51, 17, 16, "#fde047", NARANJA_OSCURO, 1.8),
            E(71, 44, 2.0, 2.2, TINTA),
            E(85, 44, 2.0, 2.2, TINTA),
            L("M56 50 L66 51 M56 55 L66 54 M100 50 L90 51 M100 55 L90 54", "#7c2d12", 1.4),
            E(78, 58, 9, 9, "#991b1b", TINTA, 2.0),
            P([(72, 52), (74, 57), (76, 52)], BLANCO),
            P([(80, 52), (82, 57), (84, 52)], BLANCO),
        ],
        "León con melena abriendo mucho la boca mostrando un gran bostezo o rugido.")
    put("pencil case", "D",
        fondo_mesa() + [
            R(36, 48, 82, 28, 8, AZUL, AZUL_OSCURO, 2.2),
            L("M38 48 L116 48", GRIS_OSCURO, 2.4),
            R(48, 28, 8, 20, 2, ROJO, ROJO_OSCURO, 1.6),
            R(62, 24, 8, 24, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
            R(76, 30, 8, 18, 2, VERDE, VERDE_OSCURO, 1.6),
            R(92, 34, 14, 14, 3, ROSA, ROSA_OSCURO, 1.6),
        ],
        "Estuche escolar abierto con lápices de colores y goma asomando fuera.")
    put("picnic basket", "D",
        fondo_prado() + [
            R(42, 46, 68, 32, 6, MADERA, MADERA_OSCURA, 2.2),
            L("M44 56 L108 56 M44 66 L108 66 M60 46 L60 78 M76 46 L76 78 M92 46 L92 78", MADERA_OSCURA, 1.5),
            P([(42, 46), (52, 26), (104, 26), (110, 46)], TIERRA_CLARA, MADERA_OSCURA, 2.0),
            L("M60 46 Q76 14 92 46", MADERA_OSCURA, 2.6),
            E(66, 40, 8, 8, ROJO, ROJO_OSCURO, 1.4),
            R(80, 34, 14, 10, 2, "#fde68a", NARANJA_OSCURO, 1.4),
        ],
        "Cesta de mimbre de picnic abierta con manzana y bocadillo listos para merendar.")
    put("puff of steam", "D",
        fondo_sala() + [
            E(70, 66, 20, 14, AGUA, AZUL_OSCURO, 2.2),
            L("M86 58 L98 46", AZUL_OSCURO, 4.0),
            E(104, 36, 9, 7, BLANCO, GRIS_OSCURO, 1.6),
            E(112, 26, 12, 9, BLANCO, GRIS_OSCURO, 1.6),
            E(102, 22, 10, 8, BLANCO, GRIS_OSCURO, 1.6),
        ],
        "Tetera echando hacia arriba una bocanada redonda de vapor blanco.")
    put("pull faces", "D",
        fondo_sala() + [
            E(78, 52, 24, 24, PEL, PELB, 2.2),
            F("M54 44 C56 24 100 24 102 44 Z", BARRO),
            E(67, 46, 5.5, 6.5, BLANCO, TINTA, 1.8),
            E(89, 46, 5.5, 6.5, BLANCO, TINTA, 1.8),
            E(69, 46, 2, 2, TINTA),
            E(87, 46, 2, 2, TINTA),
            E(78, 62, 10, 6, "#991b1b", TINTA, 1.8),
            R(73, 62, 10, 10, 5, ROSA, ROSA_OSCURO, 1.6),
        ],
        "Niño poniendo cara graciosa con ojos muy abiertos y sacando la lengua.")
    put("puppet show", "D",
        fondo_sala() + [
            R(28, 16, 100, 66, 4, "#fef9c3", MADERA_OSCURA, 2.4),
            F("M28 16 L54 16 Q48 48 34 82 L28 82 Z", ROJO, ROJO_OSCURO, 2.0),
            F("M128 16 L102 16 Q108 48 122 82 L128 82 Z", ROJO, ROJO_OSCURO, 2.0),
            R(44, 62, 68, 20, 2, MADERA, MADERA_OSCURA, 2.0),
            E(64, 42, 9, 9, VERDE, VERDE_OSCURO, 1.8),
            R(57, 50, 14, 14, 3, VERDE, VERDE_OSCURO, 1.8),
            E(92, 42, 9, 9, MORADO, "#5b21b6", 1.8),
            R(85, 50, 14, 14, 3, MORADO, "#5b21b6", 1.8),
        ],
        "Teatrillo de guiñol con cortinas rojas abiertas y dos títeres actuando.")
    put("rain, then sun", "D",
        [
            R(0, 0, 74, 92, 0, "#cbd5e1"),
            E(38, 26, 16, 10, GRIS, GRIS_OSCURO, 1.8),
        ] + _gotas(26, 42, 3, AGUA_OSCURO) + [
            R(74, 0, 82, 92, 0, "#bae6fd"),
        ] + _sol(118, 34, 16) + _frecha(62, 48, 90, 48, AMARILLO_OSCURO, 2.8),
        "Secuencia de lluvia cayendo a la izquierda seguida con flecha por un sol radiante.")
    put("read", "D",
        fondo_sala() + _nino_pie(48, 34, (AZUL, AZUL_OSCURO)) + libro_prop(78, 38, 44, ROJO) + [
            L("M83 46 L94 46 M83 52 L94 52 M105 46 L116 46", GRIS_OSCURO, 1.6),
        ],
        "Niño leyendo un libro abierto con líneas impresas.")
    put("refract", "D",
        fondo_noite() + [
            L("M20 52 L64 46", BLANCO, 3.8),
            P([(62, 68), (80, 24), (98, 68)], "#bae6fd", BLANCO, 2.2),
            L("M88 42 L134 26", ROJO, 2.8),
            L("M90 48 L134 44", AMARILLO, 2.8),
            L("M92 54 L134 62", VERDE, 2.8),
            L("M94 60 L134 78", AZUL, 2.8),
        ],
        "Prisma triangular abriendo y separando un haz de luz blanca en varios colores.")
    put("river mouth", "D",
        [
            R(0, 0, 156, 92, 0, HERBA),
            F("M30 0 L44 0 Q50 38 72 48 L156 26 L156 92 L0 92 L0 64 Q44 58 30 0 Z", AGUA, AGUA_OSCURO, 2.0),
            L("M86 58 Q108 54 130 58", BLANCO, 1.8),
        ],
        "Río azul que se ensancha abriéndose al desembocar en el mar.")
    put("save water", "D",
        fondo_sala() + [
            L("M44 26 L76 26 L76 38", GRIS_OSCURO, 6.0),
            R(50, 16, 20, 6, 2, AZUL, AZUL_OSCURO, 1.8),
            F("M76 48 Q82 58 76 62 Q70 58 76 48 Z", AGUA, AGUA_OSCURO, 1.8),
        ] + _mano_abierta(102, 46, 0.75, (VERDE, VERDE_OSCURO)) + [
            L("M80 20 L62 20", VERDE_OSCURO, 2.2),
            P([(58, 20), (64, 16), (64, 24)], VERDE_OSCURO),
        ],
        "Mano cerrando el grifo del agua para ahorrar y evitar desperdiciar gotas.")
    put("scale pan", "D",
        fondo_mesa() + [
            R(74, 22, 6, 52, 2, GRIS_OSCURO),
            R(56, 72, 42, 7, 3, GRIS_OSCURO),
            L("M42 28 L112 28", GRIS_OSCURO, 3.0),
            L("M46 28 L34 54 M46 28 L58 54", GRIS, 1.8),
            F("M32 54 L60 54 Q46 66 32 54 Z", DORADO, AMARILLO_OSCURO, 2.2),
            E(46, 58, 18, 9, None, ROJO, 2.0),
            L("M108 28 L98 54 M108 28 L118 54", GRIS, 1.8),
            F("M96 54 L120 54 Q108 64 96 54 Z", GRIS, GRIS_OSCURO, 1.8),
        ],
        "Balanza de platos destacando uno de sus platillos abiertos con un aro.")
    put("scallop", "D",
        fondo_mar() + [
            F("M44 62 Q40 28 78 24 Q116 28 112 62 L90 70 L94 76 L62 76 L66 70 Z", "#fef3c7", NARANJA_OSCURO, 2.2),
            L("M78 72 L52 38 M78 72 L65 30 M78 72 L78 26 M78 72 L91 30 M78 72 L104 38", NARANJA_OSCURO, 1.8),
        ],
        "Concha de vieira con sus características estrías en abanico y orejas en la base.")
    put("sea urchin", "D",
        fondo_mar() + [
            L("M78 52 L38 28 M78 52 L78 14 M78 52 L118 28 M78 52 L30 52 M78 52 L126 52 M78 52 L44 76 M78 52 L112 76 M78 52 L56 18 M78 52 L100 18", NEGRO, 2.4),
            E(78, 52, 16, 15, "#581c87", NEGRO, 2.2),
            E(73, 47, 3, 3, "#a855f7"),
            E(84, 54, 3, 3, "#a855f7"),
        ],
        "Erizo de mar oscuro cubierto de púas radiales sobre el fondo marino.")
    put("shiny", "D",
        fondo_cielo() + [
            E(78, 50, 22, 22, "#fde047", AMARILLO_OSCURO, 2.4),
            E(78, 50, 14, 14, "#fef9c3"),
            L("M66 40 L74 34", BLANCO, 3.0),
        ] + _estrella(46, 26, 8, BLANCO, AMARILLO_OSCURO, 1.4) + _estrella(110, 28, 7, BLANCO, AMARILLO_OSCURO, 1.4) + _estrella(106, 72, 6, BLANCO, AMARILLO_OSCURO, 1.4),
        "Disco dorado pulido y muy reluciente rodeado de destellos de brillo.")
    put("shop", "D",
        fondo_prado() + [
            R(38, 32, 80, 48, 3, "#fef3c7", MADERA_OSCURA, 2.2),
            P([(34, 32), (122, 32), (116, 20), (40, 20)], ROJO, ROJO_OSCURO, 2.0),
            R(50, 22, 12, 9, 0, BLANCO),
            R(74, 22, 12, 9, 0, BLANCO),
            R(98, 22, 12, 9, 0, BLANCO),
            R(48, 44, 32, 22, 2, "#bae6fd", AZUL_OSCURO, 1.8),
            R(88, 44, 22, 36, 2, MADERA, MADERA_OSCURA, 2.0),
        ],
        "Fachada de tienda con toldo rayado, escaparate y puerta abierta.")
    put("sing", "D",
        fondo_sala() + nino_busto(64, 48, (ROJO, ROJO_OSCURO)) + [
            E(66.5, 53.5, 3.8, 4.0, "#991b1b"),
        ] + _notas_col(94, 34),
        "Niño abriendo la boca suavemente mientras canta notas musicales.")
    put("sing louder", "D",
        fondo_sala() + nino_busto(54, 48, (AZUL, AZUL_OSCURO), brazos_arriba=True) + [
            E(56.5, 53.5, 5.2, 5.4, "#991b1b", TINTA, 1.4),
        ] + ondas_sonido(74, 48, ROJO_OSCURO, 1) + _notas_col(106, 30, MORADO) + _notas_col(118, 48, NARANJA_OSCURO),
        "Niño con la boca muy abierta cantando con gran volumen y notas grandes.")
    put("snap", "D",
        fondo_prado() + [
            P([(38, 42), (96, 26), (96, 46)], VERDE, VERDE_OSCURO, 2.2),
            P([(38, 60), (96, 76), (96, 56)], VERDE, VERDE_OSCURO, 2.2),
            E(52, 34, 4, 4, BLANCO, TINTA, 1.4),
            E(52, 34, 1.6, 1.6, TINTA),
            L("M106 36 L116 32 M106 50 L118 50 M106 64 L116 68", ROJO_OSCURO, 2.2),
        ] + _frecha(102, 22, 102, 42, ROJO_OSCURO, 2.2) + _frecha(102, 80, 102, 60, ROJO_OSCURO, 2.2),
        "Mandíbulas cerrándose de golpe con chasquido en el extremo.")
    put("sock puppet", "D",
        fondo_sala() + [
            R(62, 50, 26, 36, 4, VERDE, VERDE_OSCURO, 2.0),
            F("M62 50 C62 28 96 28 102 44 L76 46 L102 52 C98 62 62 62 62 50 Z", "#86efac", VERDE_OSCURO, 2.2),
            P([(76, 46), (102, 44), (102, 52)], ROJO_OSCURO),
            E(72, 32, 4.5, 4.5, BLANCO, TINTA, 1.5),
            E(72, 32, 1.8, 1.8, TINTA),
            E(84, 32, 4.5, 4.5, BLANCO, TINTA, 1.5),
            E(84, 32, 1.8, 1.8, TINTA),
            R(64, 66, 22, 5, 0, AMARILLO),
        ],
        "Mano metida dentro de un títere de calcetín con ojos de botón abriendo la boca.")
    put("sparkle", "D",
        fondo_noite() + _estrella(78, 46, 22, "#fef08a", AMARILLO_OSCURO, 2.0)
        + _estrella(42, 28, 9, "#bae6fd", AGUA_OSCURO, 1.4)
        + _estrella(114, 28, 10, "#bae6fd", AGUA_OSCURO, 1.4)
        + _estrella(48, 70, 7, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(112, 68, 8, AMARILLO, AMARILLO_OSCURO, 1.2),
        "Chispas luminosas destellando en la oscuridad al abrir y cerrar los dedos.")
    put("sparkling sea", "D",
        fondo_mar() + _sol(124, 18, 12) + [
            L("M30 56 Q46 50 62 56 M82 64 Q100 58 118 64 M46 74 Q64 68 82 74", "#7dd3fc", 2.0),
        ] + _estrella(52, 56, 6, BLANCO, AMARILLO_OSCURO, 1.2) + _estrella(94, 58, 7, BLANCO, AMARILLO_OSCURO, 1.2) + _estrella(72, 70, 5.5, BLANCO, AMARILLO_OSCURO, 1.2),
        "Mar azul brillante lleno de destellos del sol reflejados en las olas.")
    put("splash down", "D",
        fondo_cielo() + [
            R(0, 62, 156, 30, 0, AGUA),
            E(78, 62, 12, 10, ROJO, ROJO_OSCURO, 2.0),
            F("M44 62 L58 38 L70 52 L78 30 L86 52 L98 38 L112 62 Z", "#bae6fd", AGUA_OSCURO, 2.0),
        ] + _frecha(78, 14, 78, 42, AZUL_OSCURO, 2.4),
        "Pelota cayendo al agua y levantando una gran corona de salpicaduras.")
    put("split open", "D",
        fondo_mesa() + [
            F("M34 52 C34 74 68 74 68 52 Z", VERDE_OSCURO, "#064e3b", 2.0),
            F("M38 52 C38 69 64 69 64 52 Z", ROJO),
            F("M88 52 C88 74 122 74 122 52 Z", VERDE_OSCURO, "#064e3b", 2.0),
            F("M92 52 C92 69 118 69 118 52 Z", ROJO),
            E(50, 58, 1.8, 2.2, NEGRO),
            E(104, 58, 1.8, 2.2, NEGRO),
        ] + _frecha(72, 34, 54, 34, ROJO_OSCURO, 2.0) + _frecha(84, 34, 102, 34, ROJO_OSCURO, 2.0),
        "Fruto partido completamente en dos mitades abiertas mostrando el interior.")
    put("spout", "D",
        fondo_mar() + [
            F("M44 74 C44 50 108 50 112 74 Z", AZUL, AZUL_OSCURO, 2.2),
            E(60, 64, 2.2, 2.2, TINTA),
            L("M74 52 Q64 26 48 24 M78 52 Q88 26 104 24", "#bae6fd", 3.4),
            E(46, 24, 4, 4, BLANCO, AGUA_OSCURO, 1.2),
            E(106, 24, 4, 4, BLANCO, AGUA_OSCURO, 1.2),
        ],
        "Ballena echando un alto chorro de agua en arco hacia arriba desde el espiráculo.")
    put("sprouting", "D",
        fondo_prado() + [
            R(0, 62, 156, 30, 0, TIERRA),
            E(78, 66, 10, 7, BARRO, "#451a03", 2.0),
            L("M78 60 Q78 40 78 34", VERDE_OSCURO, 3.2),
            E(66, 36, 10, 6, HERBA, VERDE_OSCURO, 1.8),
            E(90, 32, 10, 6, HERBA, VERDE_OSCURO, 1.8),
        ],
        "Semilla en la tierra brotando con un tallo verde y sus primeras hojitas abriéndose.")
    put("squeeze and let go", "D",
        fondo_sala() + [
            E(48, 56, 13, 18, AMARILLO, AMARILLO_OSCURO, 2.2),
            L("M30 56 L38 56 M66 56 L58 56", ROJO_OSCURO, 2.2),
        ] + _frecha(72, 56, 86, 56, AZUL_OSCURO, 2.2) + [
            E(112, 56, 19, 19, AMARILLO, AMARILLO_OSCURO, 2.2),
            L("M94 36 L98 42 M130 36 L126 42", VERDE_OSCURO, 2.0),
        ],
        "Bola blanda apretada y encogida que vuelve a abrirse al soltarla.")
    put("star shape", "D",
        fondo_noite() + _estrella(78, 46, 32, AMARILLO, AMARILLO_OSCURO, 2.4),
        "Figura geométrica bien definida en forma de estrella de cinco puntas.")
    put("starlight", "D",
        fondo_noite() + [
            L("M78 36 L44 80 M78 36 L60 82 M78 36 L78 84 M78 36 L96 82 M78 36 L112 80", "#fef08a", 3.0),
        ] + _estrella(78, 28, 13, AMARILLO, AMARILLO_OSCURO, 1.8)
        + _estrella(42, 24, 5, AMARILLO, AMARILLO_OSCURO, 1.0)
        + _estrella(114, 24, 5, AMARILLO, AMARILLO_OSCURO, 1.0),
        "Estrella brillante enviando rayos de luz estelar hacia abajo en la noche.")
    put("starry", "D",
        fondo_noite() + _estrella(38, 28, 8, AMARILLO, AMARILLO_OSCURO, 1.4)
        + _estrella(78, 22, 10, AMARILLO, AMARILLO_OSCURO, 1.4)
        + _estrella(118, 30, 7.5, AMARILLO, AMARILLO_OSCURO, 1.4)
        + _estrella(54, 54, 6.5, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(102, 56, 8.5, AMARILLO, AMARILLO_OSCURO, 1.4)
        + _estrella(30, 66, 5.5, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(130, 62, 6, AMARILLO, AMARILLO_OSCURO, 1.2),
        "Cielo nocturno completamente estrellado y lleno de estrellas.")
    put("sticky fingers", "D",
        fondo_sala() + _mano_abierta(78, 56, 1.1, (NARANJA, NARANJA_OSCURO)) + [
            E(68, 38, 3.5, 5, "#eab308", NARANJA_OSCURO, 1.2),
            E(84, 36, 3.5, 6, "#eab308", NARANJA_OSCURO, 1.2),
            L("M69 36 Q74 44 77 36 M80 35 Q85 45 90 38", "#f59e0b", 2.2),
        ],
        "Mano abierta con hilos pegajosos dorados entre los dedos abiertos.")
    put("summer reading", "D",
        fondo_prado() + _sol(128, 22, 13) + [
            E(44, 34, 24, 18, VERDE, VERDE_OSCURO, 2.0),
            R(40, 48, 8, 32, 2, MADERA_OSCURA),
        ] + _nino_pie(64, 34, (AMARILLO, AMARILLO_OSCURO)) + libro_prop(92, 46, 34, AZUL),
        "Niño leyendo un libro abierto bajo la sombra de un árbol en un día soleado de verano.")
    put("sunlight", "D",
        fondo_prado() + _sol(34, 24, 15) + [
            L("M52 28 L128 54 M48 36 L112 72 M40 42 L84 78", "#fde047", 4.2),
            L("M52 28 L128 54 M48 36 L112 72 M40 42 L84 78", AMARILLO_OSCURO, 1.6),
        ],
        "Rayos luminosos de luz solar abriéndose sobre la pradera verde.")
    put("sunny day", "D",
        fondo_cielo() + [
            R(0, 62, 156, 30, 0, HERBA),
        ] + _sol(78, 34, 20) + [
            E(34, 24, 12, 7, BLANCO, NUBE_B, 1.2),
            E(124, 26, 11, 6, BLANCO, NUBE_B, 1.2),
        ],
        "Día luminoso de sol radiante sobre cielo azul y colinas verdes.")
    put("talkative", "D",
        fondo_sala() + nino_busto(54, 48, (MORADO, "#5b21b6")) + [
            E(54, 54, 5, 5, "#991b1b"),
            E(104, 34, 22, 14, BLANCO, AZUL_OSCURO, 1.8),
            L("M92 34 L116 34", AZUL_OSCURO, 2.0),
            E(112, 58, 18, 12, BLANCO, VERDE_OSCURO, 1.8),
            L("M102 58 L122 58", VERDE_OSCURO, 2.0),
        ],
        "Personaje muy hablador charlando sin parar con varios globos de diálogo.")
    put("tap", "D",
        fondo_sala() + [
            R(42, 66, 72, 14, 3, "#e2e8f0", GRIS_OSCURO, 2.0),
            R(56, 44, 10, 22, 3, GRIS, GRIS_OSCURO, 2.0),
            L("M66 44 Q86 38 92 50", GRIS_OSCURO, 6.0),
            R(50, 36, 22, 6, 2, AZUL, AZUL_OSCURO, 1.8),
            F("M92 54 Q98 63 92 67 Q86 63 92 54 Z", AGUA, AGUA_OSCURO, 1.6),
        ],
        "Grifo metálico de lavabo con llave azul y una gota de agua.")
    put("through the grass", "D",
        fondo_prado() + [
            L("M30 82 L24 34 M42 82 L34 28 M56 82 L44 38 M100 82 L112 38 M114 82 L122 28 M126 82 L132 34", VERDE_OSCURO, 4.0),
            L("M68 58 L46 52 M88 58 L110 52", PEL, 4.0),
        ] + _frecha(68, 58, 46, 52, HERBAB, 2.0) + _frecha(88, 58, 110, 52, HERBAB, 2.0),
        "Manos apartando y abriéndose paso entre briznas altas de hierba.")
    put("treasure basket", "D",
        fondo_mesa() + [
            F("M40 50 L116 50 L108 78 L48 78 Z", MADERA, MADERA_OSCURA, 2.2),
            L("M44 60 L112 60 M46 69 L110 69", MADERA_OSCURA, 1.6),
            E(60, 46, 9, 10, BARRO, "#451a03", 1.8),
            E(78, 44, 9, 9, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(96, 46, 9, 8, None, ROJO_OSCURO, 3.6),
        ],
        "Cesta baja de los tesoros llena de objetos naturales para sacar y explorar.")
    put("twinkle", "D",
        fondo_noite() + _estrella(78, 46, 18, AMARILLO, AMARILLO_OSCURO, 2.0) + [
            L("M52 28 L46 22 M104 28 L110 22 M52 64 L46 70 M104 64 L110 70", "#fef08a", 2.2),
        ],
        "Estrella luminosa titilando con destellos intermitentes en el cielo nocturno.")
    put("twinkling", "D",
        fondo_noite() + [
            R(0, 60, 156, 32, 0, MAR_PROF),
            L("M16 66 Q38 62 60 66 M90 66 Q114 62 138 66", "#38bdf8", 1.6),
        ] + _estrella(46, 26, 7, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(86, 22, 9, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(118, 32, 7, AMARILLO, AMARILLO_OSCURO, 1.2)
        + _estrella(46, 74, 4.5, "#fef08a", AMARILLO_OSCURO, 0.9)
        + _estrella(86, 72, 5.5, "#fef08a", AMARILLO_OSCURO, 0.9)
        + _estrella(118, 76, 4.5, "#fef08a", AMARILLO_OSCURO, 0.9),
        "Luces estelares titilantes reflejándose como chispas sobre el agua tranquila.")
    put("unfold", "D",
        fondo_mesa() + [
            R(44, 28, 34, 44, 2, "#fce7f3", ROSA_OSCURO, 2.0),
            R(78, 28, 34, 44, 2, ROSA, ROSA_OSCURO, 2.0),
            P([(98, 28), (112, 28), (112, 42)], "#fbcfe8", ROSA_OSCURO, 1.6),
            L("M78 28 L78 72", ROSA_OSCURO, 1.8),
        ] + _frecha(56, 50, 32, 50, ROJO_OSCURO, 2.2) + _frecha(100, 50, 124, 50, ROJO_OSCURO, 2.2),
        "Paño o papel doblado por el centro desplegándose abierto hacia ambos lados.")
    put("walnut", "D",
        fondo_mesa() + [
            E(56, 56, 15, 19, BARRO, "#451a03", 2.2),
            L("M56 37 L56 75 M45 48 Q56 54 67 48 M45 64 Q56 58 67 64", "#451a03", 1.5),
            E(102, 56, 15, 19, "#fde68a", BARRO, 2.2),
            E(98, 52, 5, 9, NARANJA_OSCURO),
            E(106, 52, 5, 9, NARANJA_OSCURO),
        ],
        "Nuez entera con cáscara dura junto a otra mitad abierta mostrando el fruto.")
    put("water tap", "D",
        fondo_prado() + [
            R(28, 34, 14, 46, 3, GRIS, GRIS_OSCURO, 2.0),
            L("M42 44 L76 44 L76 54", GRIS_OSCURO, 5.5),
            R(50, 32, 22, 6, 2, VERDE, VERDE_OSCURO, 1.8),
            L("M76 54 L76 76", AGUA, 4.0),
        ] + _mano_indice(102, 34, -1, 0, (AZUL, AZUL_OSCURO)),
        "Grifo de jardín con caño vertiendo agua mientras una mano se acerca a cerrarlo.")
    put("webbed", "D",
        fondo_mar() + [
            F("M74 28 L82 28 L80 48 L104 66 Q90 74 78 68 Q66 74 52 66 L76 48 Z", NARANJA, NARANJA_OSCURO, 2.2),
            L("M78 48 L78 68 M77 48 L60 66 M79 48 L96 66", NARANJA_OSCURO, 2.2),
        ],
        "Pata palmeada de pato abierta mostrando las membranas entre los tres dedos.")
    put("webbed feet", "D",
        fondo_prado() + [
            R(0, 62, 156, 30, 0, AGUA),
            F("M54 34 L60 34 L59 50 L72 64 Q57 68 42 64 L55 50 Z", NARANJA, NARANJA_OSCURO, 2.0),
            F("M98 34 L104 34 L103 50 L116 64 Q101 68 86 64 L99 50 Z", NARANJA, NARANJA_OSCURO, 2.0),
        ],
        "Par de patas palmeadas abiertas junto a la orilla del estanque.")
    put("wide", "D",
        fondo_prado() + _nino_pie(78, 34, (VERDE, VERDE_OSCURO)) + [
            L("M68 52 L44 48 M88 52 L112 48 M73 68 L60 80 M83 68 L96 80", PEL, 3.2),
        ] + _frecha(56, 26, 28, 26, ROJO_OSCURO, 2.4) + _frecha(100, 26, 128, 26, ROJO_OSCURO, 2.4),
        "Niño abriendo mucho brazos y piernas con flechas hacia lo ancho.")
    put("wide awake", "D",
        fondo_noite() + [
            R(40, 58, 76, 24, 6, "#bae6fd", AZUL_OSCURO, 2.0),
            R(50, 48, 56, 14, 5, BLANCO, GRIS_OSCURO, 1.8),
            E(78, 48, 17, 17, PEL, PELB, 2.2),
            F("M61 42 C63 26 93 26 95 42 Z", BARRO),
            E(71, 47, 4.5, 5.2, BLANCO, TINTA, 1.6),
            E(85, 47, 4.5, 5.2, BLANCO, TINTA, 1.6),
            E(71, 47, 1.8, 2.0, TINTA),
            E(85, 47, 1.8, 2.0, TINTA),
            L("M74 56 Q78 58 82 56", "#9a3412", 1.5),
        ] + _estrella(28, 26, 6, AMARILLO, AMARILLO_OSCURO, 1.2) + _estrella(128, 26, 6, AMARILLO, AMARILLO_OSCURO, 1.2),
        "Niño en la cama de noche con los ojos muy abiertos completamente despierto.")
    put("wide-eyed", "D",
        fondo_sala() + [
            E(78, 52, 24, 24, PEL, PELB, 2.2),
            F("M54 44 C56 24 100 24 102 44 Z", BARRO),
            E(68, 48, 7.5, 8.5, BLANCO, TINTA, 2.0),
            E(88, 48, 7.5, 8.5, BLANCO, TINTA, 2.0),
            E(68, 48, 2.8, 3.0, TINTA),
            E(88, 48, 2.8, 3.0, TINTA),
            E(78, 64, 4.5, 4.5, "#9a3412"),
        ],
        "Cara asombrada con los ojos redondos abiertos de par en par.")

    # ── point (primeras 22 cubiertas: `above`..`colourful`) ──────────────────
    put("above", "D",
        fondo_sala() + [
            R(36, 56, 84, 8, 2, MADERA, MADERA_OSCURA, 2.0),
            R(44, 64, 6, 16, 1, MADERA_OSCURA),
            R(106, 64, 6, 16, 1, MADERA_OSCURA),
        ] + pelota_prop(78, 30, 13, ROJO, ROJO_OSCURO) + _frecha(118, 52, 118, 24, AZUL_OSCURO, 2.4),
        "Pelota flotando por encima del estante con flecha señalando hacia arriba.")
    put("aunt", "D",
        fondo_sala() + [
            R(50, 20, 52, 56, 4, MADERA, MADERA_OSCURA, 2.4),
            R(56, 26, 40, 44, 2, "#fef9c3", MADERA_OSCURA, 1.4),
            E(76, 42, 11, 11, PEL, PELB, 1.8),
            F("M64 42 C64 26 88 26 88 42 Z", BARRO),
            R(65, 52, 22, 16, 5, MORADO, "#5b21b6", 1.8),
            E(72, 41, 1.4, 1.6, TINTA),
            E(80, 41, 1.4, 1.6, TINTA),
            L("M72 47 Q76 50 80 47", "#9a3412", 1.4),
        ] + _mano_indice(118, 56, -1, -1, (ROJO, ROJO_OSCURO)),
        "Retrato enmarcado de una tía sonriente señalado con el dedo índice.")
    put("autumn-coloured", "D",
        fondo_prado() + [
            E(42, 52, 12, 7, NARANJA, NARANJA_OSCURO, 1.8),
            E(74, 44, 13, 8, ROJO, ROJO_OSCURO, 1.8),
            E(104, 52, 12, 7, AMARILLO_OSCURO, BARRO, 1.8),
        ] + _castana(84, 66, 10) + _mano_indice(122, 72, -1, -1, (NARANJA, NARANJA_OSCURO)),
        "Hojas naranjas, rojas y doradas junto a una castaña en colores cálidos de otoño.")
    put("back teeth", "D",
        fondo_sala() + [
            E(76, 52, 32, 20, "#991b1b", TINTA, 2.2),
            R(54, 40, 9, 10, 2, "#fde047", NARANJA_OSCURO, 1.8),
            R(65, 40, 8, 9, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(75, 40, 8, 9, 2, BLANCO, GRIS_OSCURO, 1.4),
            R(85, 40, 9, 10, 2, "#fde047", NARANJA_OSCURO, 1.8),
            R(54, 56, 9, 10, 2, "#fde047", NARANJA_OSCURO, 1.8),
            R(85, 56, 9, 10, 2, "#fde047", NARANJA_OSCURO, 1.8),
        ] + _mano_indice(120, 44, -1, 0, (AZUL, AZUL_OSCURO)),
        "Boca abierta señalando las muelas anchas situadas al fondo.")
    put("before and after", "D",
        [
            R(0, 0, 76, 92, 0, "#fef2f2"),
            R(24, 30, 18, 32, 4, "#a16207", "#451a03", 2.0),
            R(24, 52, 32, 14, 5, "#a16207", "#451a03", 2.0),
            E(32, 44, 4, 3, BARRO),
            E(44, 58, 5, 3, BARRO),
            R(76, 0, 80, 92, 0, "#f0fdf4"),
            R(102, 30, 18, 32, 4, BLANCO, AGUA_OSCURO, 2.0),
            R(102, 52, 32, 14, 5, BLANCO, AGUA_OSCURO, 2.0),
        ] + _estrella(126, 26, 5, AMARILLO, AMARILLO_OSCURO, 1.2) + _frecha(62, 50, 92, 50, AZUL_OSCURO, 2.8),
        "Comparación visual de una bota manchada de barro antes pasando con flecha a limpia después.")
    put("below", "D",
        fondo_sala() + [
            R(36, 34, 84, 8, 2, MADERA, MADERA_OSCURA, 2.0),
            R(44, 42, 6, 34, 1, MADERA_OSCURA),
            R(106, 42, 6, 34, 1, MADERA_OSCURA),
        ] + pelota_prop(78, 64, 12, AZUL, AZUL_OSCURO) + _frecha(118, 38, 118, 68, ROJO_OSCURO, 2.4),
        "Pelota colocada por debajo de la mesa con flecha señalando hacia abajo.")
    put("big school", "D",
        fondo_prado() + [
            R(42, 26, 72, 52, 3, "#fca5a5", ROJO_OSCURO, 2.2),
            P([(38, 26), (78, 10), (118, 26)], ROJO_OSCURO),
            R(68, 56, 20, 22, 2, MADERA, MADERA_OSCURA, 2.0),
            E(78, 28, 7, 7, BLANCO, TINTA, 1.5),
            L("M78 28 L78 24 M78 28 L82 28", TINTA, 1.4),
            R(50, 42, 12, 12, 1, "#bae6fd", AZUL_OSCURO, 1.5),
            R(94, 42, 12, 12, 1, "#bae6fd", AZUL_OSCURO, 1.5),
        ] + _mano_indice(28, 64, 1, -1, (AZUL, AZUL_OSCURO)),
        "Edificio grande de la escuela de primaria con reloj señalado a lo lejos.")
    put("black", "D",
        fondo_mesa() + [
            R(42, 34, 34, 40, 5, NEGRO, TINTA, 2.2),
            E(96, 54, 14, 14, NEGRO),
            P([(84, 44), (88, 30), (94, 42)], NEGRO),
            P([(108, 44), (104, 30), (98, 42)], NEGRO),
            E(91, 52, 2.2, 2.2, AMARILLO),
            E(101, 52, 2.2, 2.2, AMARILLO),
        ] + _mano_indice(120, 68, -1, -1, (VERDE, VERDE_OSCURO)),
        "Muestra de color negro puro y silueta de gato negro señalados con el dedo.")
    put("both sides", "D",
        fondo_sala() + [
            R(64, 34, 28, 36, 4, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(34, 52, 8, 8, AZUL, AZUL_OSCURO, 1.8),
            E(122, 52, 8, 8, ROJO, ROJO_OSCURO, 1.8),
        ] + _frecha(60, 52, 46, 52, AZUL_OSCURO, 2.4) + _frecha(96, 52, 110, 52, ROJO_OSCURO, 2.4),
        "Dos flechas simétricas señalando tanto el lado izquierdo como el derecho.")
    put("bright red", "D",
        fondo_mesa() + [
            E(72, 52, 22, 22, "#ef4444", "#991b1b", 2.2),
            E(66, 44, 6, 4, BLANCO),
            E(82, 60, 4, 3, "#fecaca"),
        ] + _mano_indice(112, 54, -1, 0, (AZUL, AZUL_OSCURO)),
        "Círculo rojo muy vivo y brillante destacado y señalado con el dedo.")
    put("brightest star", "D",
        fondo_noite() + _estrella(34, 32, 6, "#fde047", AMARILLO_OSCURO, 1.0)
        + _estrella(122, 34, 6, "#fde047", AMARILLO_OSCURO, 1.0)
        + _estrella(46, 66, 5, "#fde047", AMARILLO_OSCURO, 1.0)
        + _estrella(78, 42, 20, AMARILLO, AMARILLO_OSCURO, 2.2)
        + [L("M78 14 L78 8 M54 24 L48 18 M102 24 L108 18", BLANCO, 2.0)]
        + _mano_indice(116, 68, -1, -1, (MORADO, "#5b21b6")),
        "Estrella mucho más grande y brillante entre otras pequeñas en el cielo nocturno.")
    put("brother", "D",
        fondo_prado() + _nino_pie(56, 34, (AZUL, AZUL_OSCURO)) + [
            R(90, 48, 16, 20, 5, VERDE, VERDE_OSCURO, 1.8),
            E(98, 40, 8, 8, PEL, PELB, 1.8),
        ] + _mano_indice(34, 48, 1, 0, (ROJO, ROJO_OSCURO)),
        "Hermano mayor señalado junto a su hermano menor en el prado.")
    put("bubble machine", "D",
        fondo_prado() + [
            R(36, 42, 42, 34, 6, AZUL, AZUL_OSCURO, 2.2),
            E(72, 56, 9, 9, "#e0f2fe", AZUL_OSCURO, 2.0),
            R(50, 34, 14, 8, 3, AZUL_OSCURO),
        ] + _pompas(108, 40) + _mano_indice(116, 68, -1, -1, (NARANJA, NARANJA_OSCURO)),
        "Máquina azul soplando un chorro continuo de pompas de jabón.")
    put("bubbles everywhere", "D",
        fondo_cielo() + [
            E(cx, cy, r, r, "#e0f2fe", AGUA_OSCURO, 1.6)
            for cx, cy, r in [(26, 22, 7), (54, 18, 9), (86, 24, 6), (118, 20, 10), (36, 48, 10), (72, 46, 8), (104, 52, 7), (132, 44, 8), (28, 74, 7), (64, 72, 9), (98, 74, 8), (128, 72, 6)]
        ] + _mano_indice(78, 58, 1, -1, (ROJO, ROJO_OSCURO)),
        "Espacio entero inundado de burbujas flotando por todas partes.")
    put("ceiling", "D",
        fondo_sala() + [
            R(0, 0, 156, 18, 0, "#e2e8f0", GRIS_OSCURO, 2.0),
            L("M78 18 L78 34", NEGRO, 2.0),
            P([(68, 42), (74, 32), (82, 32), (88, 42)], AMARILLO, AMARILLO_OSCURO, 1.8),
        ] + _mano_indice(52, 62, 1, -1, (AZUL, AZUL_OSCURO)) + _frecha(116, 66, 116, 22, ROJO_OSCURO, 2.4),
        "Habitación señalando directamente arriba hacia el techo y la lámpara colgante.")
    put("centre", "D",
        fondo_sala() + [
            E(78, 48, 28, 28, "#e0f2fe", AZUL_OSCURO, 2.2),
            E(78, 48, 16, 16, BLANCO, AZUL_OSCURO, 1.8),
            E(78, 48, 6.5, 6.5, ROJO, ROJO_OSCURO, 1.8),
        ] + _mano_indice(118, 62, -1, -1, (VERDE, VERDE_OSCURO)),
        "Diana circular señalando exactamente el punto rojo del centro.")
    put("chestnut stall", "D",
        fondo_prado() + [
            R(44, 46, 68, 32, 3, MADERA, MADERA_OSCURA, 2.2),
            P([(38, 28), (118, 28), (110, 16), (46, 16)], NARANJA, NARANJA_OSCURO, 2.0),
            L("M48 28 L48 46 M108 28 L108 46", MADERA_OSCURA, 2.8),
            E(68, 44, 14, 6, NEGRO),
        ] + _castana(68, 40, 6) + [
            L("M66 28 Q62 22 66 16 M74 28 Q78 22 74 16", GRIS, 2.0),
        ] + _mano_indice(120, 62, -1, -1, (ROJO, ROJO_OSCURO)),
        "Puesto ambulante de castañas asadas humeando señalado en la calle.")
    put("classmate", "D",
        fondo_sala() + _nino_pie(52, 34, (AZUL, AZUL_OSCURO)) + _nino_pie(102, 34, (VERDE, VERDE_OSCURO)) + [
            R(40, 68, 24, 14, 2, MADERA, MADERA_OSCURA, 1.8),
            R(90, 68, 24, 14, 2, MADERA, MADERA_OSCURA, 1.8),
        ] + _frecha(68, 40, 88, 40, ROJO_OSCURO, 2.2),
        "Dos compañeros de clase juntos en sus pupitres señalándose amistosamente.")
    put("classroom job", "D",
        fondo_sala() + [
            R(42, 20, 72, 56, 4, "#fef9c3", MADERA_OSCURA, 2.2),
            R(48, 26, 28, 20, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            R(80, 26, 28, 20, 2, "#bbf7d0", VERDE_OSCURO, 1.6),
            L("M62 29 L62 43 M57 40 L67 40", BARRO, 2.2),
            E(94, 36, 5, 5, AGUA, AZUL_OSCURO, 1.5),
            R(48, 52, 60, 18, 2, BLANCO, GRIS_OSCURO, 1.5),
        ] + _mano_indice(118, 44, -1, -1, (ROJO, ROJO_OSCURO)),
        "Panel de encargos de la clase con tareas ilustradas señalado por una mano.")
    put("clue", "D",
        fondo_prado() + [
            E(52, 68, 4, 6, BARRO),
            E(68, 56, 4, 6, BARRO),
            E(84, 44, 5, 7, ROJO_OSCURO),
            E(84, 44, 16, 16, "#e0f2fe", GRIS_OSCURO, 2.6),
            E(84, 44, 5, 7, ROJO_OSCURO),
            L("M95 55 L114 74", MADERA_OSCURA, 5.0),
        ],
        "Lupa enfocando una huella en el suelo siguiendo una pista.")
    put("colour", "D",
        fondo_mesa() + [
            E(42, 54, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            E(76, 54, 12, 12, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(110, 54, 12, 12, AZUL, AZUL_OSCURO, 2.0),
        ] + _mano_indice(76, 26, 0, 1, (VERDE, VERDE_OSCURO)),
        "Tres manchas de colores distintos señaladas para nombrar el color.")
    put("colourful", "D",
        fondo_cielo() + [
            E(42, 34, 11, 13, ROJO, ROJO_OSCURO, 1.8),
            E(66, 28, 11, 13, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(90, 32, 11, 13, VERDE, VERDE_OSCURO, 1.8),
            E(114, 28, 11, 13, MORADO, "#5b21b6", 1.8),
            E(78, 48, 11, 13, AZUL, AZUL_OSCURO, 1.8),
            L("M42 47 L78 78 M66 41 L78 78 M90 45 L78 78 M114 41 L78 78 M78 61 L78 78", GRIS_OSCURO, 1.3),
        ],
        "Ramillete de globos muy colorido con muchos tonos brillantes juntos.")

    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    # body_touch (26)
    "historic": "Cualidad histórica temporal abstracta («Histórico»); tocar una piedra vieja parece solo «roca» sin texto.",
    "how would you feel if": "Pregunta hipotética emocional («¿Cómo te sentirías si...?»); depende del diálogo hablado.",
    "hypothesis": "Concepto científico abstracto («Hipótesis»); indistinguible de «pensar» o «idea» sin texto.",
    "i think so because": "Conector argumentativo causal («Pienso eso porque»); estructura puramente verbal.",
    "if i touch you, you're it": "Regla condicional verbal de juego («Si te toco, pillas tú»); indistinguible de «pillar» sin texto.",
    "intelligent": "Rasgo cognitivo abstracto («Inteligente»); indistinguible de «listo» o «cerebro».",
    "is it warm": "Pregunta conversacional térmica («¿Está calentito?»); indistinguible de «caliente» sin signos ni texto.",
    "it's you": "Exclamación deíctica conversacional («¡Eres tú!»); depende del intercambio hablado.",
    "let's find out": "Exhortación conversacional («¡Vamos a descubrirlo!»); carece de imagen única sin texto.",
    "memory": "Concepto mental abstracto («Recuerdo»); sin historia ni texto es indistinguible de «pensar».",
    "my turn, your turn": "Regla alternante de turnos («Mi turno, tu turno»); depende del diálogo y orden verbal.",
    "natural": "Adjetivo clasificatorio abstracto («Natural»); tocar una hoja parece solo «hoja».",
    "not too hot": "Grado térmico negativo («No muy caliente»); una negación de grado resulta ambigua sin texto.",
    "one by one": "Secuencia adverbial («Uno a uno»); requiere orden temporal o numeración escrita.",
    "predict": "Verbo cognitivo abstracto («Predecir»); indistinguible de «pensar» o «adivinar».",
    "prediction": "Sustantivo cognitivo abstracto («Predicción»).",
    "quick-thinking": "Rasgo cognitivo abstracto («Espabilado»).",
    "routine": "Concepto organizativo temporal («Rutina»); indistinguible de reloj o tarea concreta sin texto.",
    "simon says touch your nose": "Consigna verbal condicional («Simón dice: tócate la nariz»); sin texto es igual a «tocar la nariz».",
    "the warmer it gets, the faster it cooks": "Ley proporcional verbal («Cuanto más caliente, más rápido se hace»).",
    "thoughtful": "Rasgo personal abstracto («Atento»).",
    "thoughtful idea": "Frase abstracta («Idea pensada»); indistinguible de «idea».",
    "what did you dream about": "Pregunta conversacional («¿Qué soñaste?»).",
    "what do you think will happen": "Pregunta predictiva («¿Qué crees que pasará?»).",
    "what if the wolf was kind": "Pregunta narrativa hipotética («¿Y si el lobo fuera bueno?»).",
    "wholesome": "Cualidad nutricional abstracta («Sano y bueno»).",
    # open_close (37)
    "all clean now": "Expresión de estado finalizado («Ya todo limpio»); indistinguible de «manos limpias» sin texto.",
    "all done": "Expresión temporal de cierre («¡Ya está!»).",
    "all gone": "Expresión de ausencia o fin («¡Se acabó!»); indistinguible de «gone» o «vacío».",
    "and then": "Conector narrativo suspensivo («Y entonces...»).",
    "breathtaking": "Adjetivo emocional superlativo («Impresionante»); indistinguible de «sorpresa».",
    "can i play": "Pregunta social conversacional («¿Puedo jugar?»).",
    "countless": "Cuantificador infinito abstracto («Incontable»).",
    "do you want to play with us": "Pregunta de invitación social («¿Quieres jugar con nosotros?»).",
    "ending": "Concepto narrativo estructural («Final»); cerrar un libro se confunde con «cerrar el libro».",
    "enjoy your meal": "Fórmula social de cortesía («¡Buen provecho!»).",
    "exciting": "Adjetivo emocional abstracto («Emocionante»).",
    "express": "Verbo comunicativo abstracto («Expresar»).",
    "figure out": "Verbo cognitivo abstracto («Averiguar»).",
    "gone": "Adjetivo abstracto de desaparición («Desaparecido»).",
    "how can we help the planet": "Pregunta reflexiva larga («¿Cómo podemos ayudar al planeta?»).",
    "include someone": "Acción social abstracta («Incluir a alguien»).",
    "inclusive": "Adjetivo social abstracto («Que incluye a todos»).",
    "independent learner": "Concepto pedagógico abstracto («Aprendiz autónomo»).",
    "invent": "Verbo creativo abstracto («Inventar»); indistinguible de «idea» sin texto.",
    "look what i found": "Exclamación conversacional genérica («¡Mira lo que encontré!»).",
    "magical": "Adjetivo fantasioso abstracto («Mágico»); evitar destellos genéricos.",
    "memorable": "Adjetivo temporal abstracto («Memorable»).",
    "next year i will learn to read books by myself": "Oración futura larga («El año que viene aprenderé a leer libros yo solo»).",
    "next year i will read more books": "Oración futura larga («El año que viene leeré más libros»).",
    "open hands to agree": "Fórmula social abstracta («Abrir las manos para acordar»).",
    "open, shut them": "Consigna cantada («Ábrelas, ciérralas»); idéntica en imagen a «abrir y cerrar».",
    "open-minded": "Rasgo actitudinal abstracto («De mente abierta»).",
    "size": "Concepto dimensional abstracto («Tamaño»); requiere etiqueta escrita de medida.",
    "suggest": "Verbo comunicativo abstracto («Sugerir»).",
    "surprise ending": "Concepto literario abstracto («Final sorprendente»).",
    "surprising": "Adjetivo abstracto («Sorprendente»); redundante con «surprised».",
    "that's ok": "Fórmula consoladora verbal («No pasa nada»).",
    "the end": "Fórmula textual de cierre («Fin»).",
    "the town was small, but now it is big": "Oración histórica comparativa («La villa era pequeña, pero ahora es grande»).",
    "vivid": "Adjetivo sensorial abstracto («Vivo»).",
    "was the town always big": "Pregunta histórica verbal («¿La villa siempre fue grande?»).",
    "what can we do": "Pregunta abierta de acción («¿Qué podemos hacer?»).",
    # point (4 primeros)
    "and then what happened": "Pregunta narrativa secuencial («¿Y qué pasó después?»).",
    "autumn park": "Parque en otoño («Parque de otoño»); sin rótulo de texto no se distingue de un parque genérico.",
    "cat and hat rhyme": "Concepto fonológico verbal en inglés («¡Cat y hat riman!»).",
    "clever idea": "Frase cognitiva abstracta («Idea inteligente»); indistinguible de «idea» sin texto.",
}
