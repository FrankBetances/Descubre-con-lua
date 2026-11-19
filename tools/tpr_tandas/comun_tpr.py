#!/usr/bin/env python3
"""Helpers vectoriales reutilizables para escenas TPR en estilo plano Lúa."""
from __future__ import annotations

import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from banco_comun import (  # noqa: E402
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    MADERA,
    MADERA_OSCURA,
    MAR_PROF,
    MORADO,
    NUBE,
    NUBE_B,
    PEL,
    PELB,
    ROJO,
    ROJO_OSCURO,
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
    copos_nieve,
    fl,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    ico,
    nino,
    notas,
    pano,
    pompas,
    sol,
    tubo,
)

ROSA = "#ec4899"
ROSA_OSCURO = "#9d174d"
NARANJA = "#f97316"
NARANJA_OSCURO = "#c2410c"
NEGRO = "#1e293b"
DORADO = "#eab308"
PLATA = "#94a3b8"


def bebe(cx: float, cy: float, manta: str = "#bae6fd", borde: str = AGUA_OSCURO, mirando: int = 1) -> list[dict]:
    """Bebé tierno estilizado en estilo plano Lúa."""
    return [
        E(cx, cy + 8, 12, 8, manta, borde, 2.0),
        E(cx - 10 * mirando, cy + 1, 7.5, 7.5, PEL, PELB, 2.0),
        L(f"M{cx - 10 * mirando - 2} {cy - 5} Q{cx - 10 * mirando} {cy - 9} {cx - 10 * mirando + 2} {cy - 6}", BARRO, 1.8),
        E(cx - 10 * mirando - 2.2, cy + 0.5, 1.0, 1.3, TINTA),
        E(cx - 10 * mirando + 2.2, cy + 0.5, 1.0, 1.3, TINTA),
        L(f"M{cx - 10 * mirando - 2} {cy + 3.8} Q{cx - 10 * mirando} {cy + 5.6} {cx - 10 * mirando + 2} {cy + 3.8}", "#9a3412", 1.3),
    ]


def bebe_sentado(cx: float, cy: float, camisa: tuple[str, str] = (AZUL, AZUL_OSCURO)) -> list[dict]:
    return [
        R(cx - 9, cy + 6, 18, 14, 7, camisa[0], camisa[1], 1.8),
        L(f"M{cx - 8} {cy + 11} L{cx - 16} {cy + 6}", PELB, 5.0),
        L(f"M{cx - 8} {cy + 11} L{cx - 16} {cy + 6}", PEL, 2.8),
        L(f"M{cx + 8} {cy + 11} L{cx + 16} {cy + 6}", PELB, 5.0),
        L(f"M{cx + 8} {cy + 11} L{cx + 16} {cy + 6}", PEL, 2.8),
        E(cx, cy - 1, 8.5, 8.5, PEL, PELB, 2.0),
        L(f"M{cx - 2} {cy - 9} Q{cx + 2} {cy - 12} {cx + 4} {cy - 8}", BARRO, 1.8),
        E(cx - 2.8, cy - 1.5, 1.0, 1.3, TINTA),
        E(cx + 2.8, cy - 1.5, 1.0, 1.3, TINTA),
        L(f"M{cx - 2.5} {cy + 2.5} Q{cx} {cy + 4.5} {cx + 2.5} {cy + 2.5}", "#9a3412", 1.3),
    ]


def nino_acostado(x: float, y: float, col: tuple[str, str] = (ROJO, ROJO_OSCURO), ojos_cerrados: bool = False) -> list[dict]:
    """Niño tumbado plano horizontal."""
    o = [
        R(x, y + 4, 24, 9, 4, AZUL, AZUL_OSCURO, 2.0),
        E(x - 2, y + 8, 4.5, 3.0, "#1f2937"),
        R(x + 22, y + 2, 22, 12, 5, col[0], col[1], 2.0),
        E(x + 51, y + 6, 8, 8, PEL, PELB, 2.0),
        F(f"M{x + 44} {y + 3} C{x + 45} {y - 4} {x + 58} {y - 4} {x + 59} {y + 4} Z", BARRO),
    ]
    if ojos_cerrados:
        o.append(L(f"M{x + 51} {y + 6} Q{x + 53} {y + 7.5} {x + 55} {y + 6}", TINTA, 1.4))
    else:
        o.append(E(x + 53, y + 6, 1.1, 1.3, TINTA))
    o.append(L(f"M{x + 50} {y + 10} Q{x + 53} {y + 12} {x + 56} {y + 10}", "#9a3412", 1.4))
    o.append(R(x + 30, y + 12, 12, 5, 2.5, PEL, PELB, 1.6))
    return o


def nino_gateando(x: float, y: float, mira: int = 1, col: tuple[str, str] = (VERDE, VERDE_OSCURO)) -> list[dict]:
    hx = x + 48 if mira > 0 else x + 12
    bx0 = x + 12 if mira > 0 else x + 22
    leg_x = x + 14 if mira > 0 else x + 44
    arm_x = x + 40 if mira > 0 else x + 20
    return [
        R(leg_x, y + 12, 6, 14, 3, AZUL, AZUL_OSCURO, 1.8),
        R(arm_x, y + 12, 5, 14, 2.5, PEL, PELB, 1.8),
        R(bx0, y + 4, 28, 12, 6, col[0], col[1], 2.0),
        E(hx, y + 4, 8, 8, PEL, PELB, 2.0),
        F(f"M{hx - 7} {y + 2} C{hx - 6} {y - 6} {hx + 7} {y - 6} {hx + 8} {y + 2} Z", BARRO),
        E(hx + 3 * mira, y + 4, 1.1, 1.4, TINTA),
        L(f"M{hx + 1 * mira} {y + 8} Q{hx + 3 * mira} {y + 10} {hx + 5 * mira} {y + 8}", "#9a3412", 1.4),
    ]


def arco_giro(cx: float, cy: float, r: float = 20, col: str = AZUL_OSCURO) -> list[dict]:
    return [
        L(f"M{cx - r:.1f} {cy - 4:.1f} Q{cx:.1f} {cy - r:.1f} {cx + r:.1f} {cy - 4:.1f}", col, 2.4),
        P([(cx + r - 3, cy - 8), (cx + r + 3, cy - 3), (cx + r - 4, cy + 1)], col),
        L(f"M{cx + r:.1f} {cy + 4:.1f} Q{cx:.1f} {cy + r:.1f} {cx - r:.1f} {cy + 4:.1f}", col, 2.4),
        P([(cx - r + 3, cy + 8), (cx - r - 3, cy + 3), (cx - r + 4, cy - 1)], col),
    ]


def ondas_sonido(x: float, y: float, col: str = AZUL_OSCURO, dir_x: int = 1) -> list[dict]:
    return [
        L(f"M{x:.1f} {y - 5:.1f} Q{x + 5 * dir_x:.1f} {y:.1f} {x:.1f} {y + 5:.1f}", col, 2.2),
        L(f"M{x + 5 * dir_x:.1f} {y - 9:.1f} Q{x + 12 * dir_x:.1f} {y:.1f} {x + 5 * dir_x:.1f} {y + 9:.1f}", col, 2.2),
    ]


def lineas_viento(x: float, y: float, w: float = 26, col: str = "#0284c7") -> list[dict]:
    return [
        L(f"M{x:.1f} {y - 6:.1f} Q{x + w * 0.5:.1f} {y - 10:.1f} {x + w:.1f} {y - 6:.1f}", col, 2.2),
        L(f"M{x + 2:.1f} {y:.1f} Q{x + w * 0.55:.1f} {y + 4:.1f} {x + w + 4:.1f} {y:.1f}", col, 2.2),
        L(f"M{x:.1f} {y + 6:.1f} Q{x + w * 0.45:.1f} {y + 2:.1f} {x + w - 2:.1f} {y + 6:.1f}", col, 2.0),
    ]


def ondas_calor(x: float, y: float, col: str = ROJO) -> list[dict]:
    o = []
    for dx in (0, 10, 20):
        px = x + dx
        o.append(L(f"M{px:.1f} {y + 14:.1f} Q{px - 4:.1f} {y + 7:.1f} {px:.1f} {y:.1f} Q{px + 4:.1f} {y - 6:.1f} {px:.1f} {y - 12:.1f}", col, 2.2))
    return o


def mesa_prop(x: float, y: float, w: float = 52, h: float = 24) -> list[dict]:
    return [
        R(x + 4, y + 6, 4.5, h - 6, 1, MADERA_OSCURA),
        R(x + w - 8.5, y + 6, 4.5, h - 6, 1, MADERA_OSCURA),
        R(x, y, w, 7, 2.5, MADERA, MADERA_OSCURA, 1.8),
    ]


def caja_prop(x: float, y: float, s: float = 30, col: str = "#eab308", borde: str = MADERA_OSCURA) -> list[dict]:
    return [
        R(x, y, s, s * 0.85, 3, col, borde, 2.0),
        R(x - 2, y - 4, s + 4, 7, 2, "#fde047", borde, 1.8),
        L(f"M{x + s * 0.5:.1f} {y - 4:.1f} L{x + s * 0.5:.1f} {y + s * 0.85:.1f}", ROJO, 2.5),
    ]


def pelota_prop(cx: float, cy: float, r: float = 13, col: str = ROJO, borde: str = ROJO_OSCURO) -> list[dict]:
    return [
        E(cx, cy, r, r, col, borde, 2.2),
        E(cx - r * 0.32, cy - r * 0.32, r * 0.25, r * 0.18, BLANCO),
    ]


def libro_prop(x: float, y: float, s: float = 34, col: str = AZUL) -> list[dict]:
    return [
        R(x, y + 2, s * 0.5, s * 0.72, 2, col, AZUL_OSCURO, 1.8),
        R(x + s * 0.5, y + 2, s * 0.5, s * 0.72, 2, col, AZUL_OSCURO, 1.8),
        R(x + 2, y + 4, s * 0.46, s * 0.62, 1, BLANCO, GRIS, 1.2),
        R(x + s * 0.52, y + 4, s * 0.46, s * 0.62, 1, BLANCO, GRIS, 1.2),
    ]


def plato_prop(cx: float, cy: float, r: float = 16) -> list[dict]:
    return [E(cx, cy, r, r * 0.65, BLANCO, GRIS_OSCURO, 2.2), E(cx, cy, r * 0.62, r * 0.38, "#f8fafc", GRIS, 1.5)]


def cuchara_prop(x: float, y: float, s: float = 28) -> list[dict]:
    return [
        L(f"M{x + s * 0.4:.1f} {y + s * 0.85:.1f} L{x + s * 0.58:.1f} {y + s * 0.32:.1f}", GRIS_OSCURO, 3.0),
        E(x + s * 0.62, y + s * 0.22, s * 0.16, s * 0.22, GRIS, GRIS_OSCURO, 1.8),
    ]


def papelera_prop(x: float, y: float, s: float = 32) -> list[dict]:
    return [
        F(f"M{x + 4:.1f} {y + 8:.1f} L{x + s - 4:.1f} {y + 8:.1f} L{x + s - 7:.1f} {y + s * 0.9:.1f} L{x + 7:.1f} {y + s * 0.9:.1f} Z", VERDE, VERDE_OSCURO, 2.0),
        R(x + 2, y + 4, s - 4, 5, 2, VERDE_OSCURO),
    ]


def bellota_prop(x: float, y: float, s: float = 28) -> list[dict]:
    cx = x + s * 0.5
    return [
        E(cx, y + s * 0.6, s * 0.26, s * 0.32, TIERRA_CLARA, BARRO, 1.8),
        E(cx, y + s * 0.32, s * 0.32, s * 0.16, BARRO, NEGRO, 1.6),
        L(f"M{cx:.1f} {y + s * 0.18:.1f} L{cx + 2:.1f} {y + s * 0.06:.1f}", BARRO, 2.4),
    ]


def semilla_prop(x: float, y: float, s: float = 24) -> list[dict]:
    cx = x + s * 0.5
    return [
        E(cx, y + s * 0.55, s * 0.18, s * 0.26, TIERRA, BARRO, 1.8),
        L(f"M{cx:.1f} {y + s * 0.3:.1f} Q{cx + 5:.1f} {y + s * 0.12:.1f} {cx + 8:.1f} {y + s * 0.18:.1f}", VERDE_OSCURO, 2.0),
    ]


def manta_prop(x: float, y: float, s: float = 36, col: str = "#fde68a", h: float | None = None) -> list[dict]:
    alto = h if h is not None else s * 0.65
    return [
        R(x + 2, y + 6, s - 4, alto, 4, col, NARANJA_OSCURO, 2.0),
        L(f"M{x + 6:.1f} {y + 13:.1f} L{x + s - 6:.1f} {y + 13:.1f}", NARANJA_OSCURO, 1.4),
        L(f"M{x + 6:.1f} {y + 6 + alto * 0.72:.1f} L{x + s - 6:.1f} {y + 6 + alto * 0.72:.1f}", NARANJA_OSCURO, 1.4),
    ]


def cortina_prop(x: float, y: float, s: float = 42) -> list[dict]:
    return [
        L(f"M{x:.1f} {y + 3:.1f} L{x + s:.1f} {y + 3:.1f}", MADERA_OSCURA, 2.8),
        R(x + 2, y + 5, s * 0.42, s * 0.8, 3, MORADO, "#5b21b6", 1.8),
        R(x + s * 0.56, y + 5, s * 0.42, s * 0.8, 3, MORADO, "#5b21b6", 1.8),
    ]


def toalla_prop(x: float, y: float, s: float = 34, h: float | None = None) -> list[dict]:
    alto = h if h is not None else s * 0.65
    return pano(x + 2, y + 6, s - 4, alto, "#bae6fd", AGUA_OSCURO)


def nube_pensar(cx: float, cy: float, rx: float = 28, ry: float = 18) -> list[dict]:
    return [
        E(cx - 10, cy + 4, rx * 0.55, ry * 0.65, BLANCO, GRIS_OSCURO, 1.8),
        E(cx + 10, cy + 4, rx * 0.55, ry * 0.65, BLANCO, GRIS_OSCURO, 1.8),
        E(cx, cy - 2, rx * 0.72, ry * 0.78, BLANCO, GRIS_OSCURO, 1.8),
        E(cx - 8, cy + 5, rx * 0.5, ry * 0.55, BLANCO),
        E(cx + 8, cy + 5, rx * 0.5, ry * 0.55, BLANCO),
        E(cx, cy - 1, rx * 0.65, ry * 0.68, BLANCO),
        E(cx - 18, cy + ry + 6, 3.5, 3.5, BLANCO, GRIS_OSCURO, 1.5),
        E(cx - 24, cy + ry + 13, 2.2, 2.2, BLANCO, GRIS_OSCURO, 1.4),
    ]


def mantel_cuadros(x: float, y: float, w: float = 72, h: float = 26) -> list[dict]:
    o = [R(x, y, w, h, 3, BLANCO, ROJO_OSCURO, 2.0)]
    cw = w / 4
    ch = h / 2
    for r in range(2):
        for c in range(4):
            if (r + c) % 2 == 0:
                o.append(R(x + c * cw + 1, y + r * ch + 1, cw - 2, ch - 2, 0, "#fca5a5"))
    return o


def notas_col(pts: list[tuple[float, float]], col: str = "#fde047") -> list[dict]:
    o = []
    for nx, ny in pts:
        o += [E(nx, ny, 3.2, 2.4, col), L(f"M{nx + 2.6} {ny} L{nx + 2.6} {ny - 9} L{nx + 7.5} {ny - 7}", col, 2.2)]
    return o


def nino_busto(
    cx: float,
    cy: float,
    camisa: tuple[str, str] = (ROJO, ROJO_OSCURO),
    pelo: str = "#5a3a1a",
    r: float = 8.5,
    mira: int = 1,
    ojos: str = "abertos",
    brazos_arriba: bool = False,
) -> list[dict]:
    """Torso superior + brazos + cabeza de niño sin piernas (para sentarse en objetos o detrás)."""
    o: list[dict] = []
    if brazos_arriba:
        o += [
            L(f"M{cx - 8} {cy + 11} L{cx - 16} {cy - 1}", PELB, 4.8),
            L(f"M{cx - 8} {cy + 11} L{cx - 16} {cy - 1}", PEL, 2.6),
            L(f"M{cx + 8} {cy + 11} L{cx + 16} {cy - 1}", PELB, 4.8),
            L(f"M{cx + 8} {cy + 11} L{cx + 16} {cy - 1}", PEL, 2.6),
        ]
    else:
        o += [
            L(f"M{cx - 8} {cy + 10} L{cx - 14} {cy + 20}", PELB, 4.8),
            L(f"M{cx - 8} {cy + 10} L{cx - 14} {cy + 20}", PEL, 2.6),
            L(f"M{cx + 8} {cy + 10} L{cx + 14} {cy + 20}", PELB, 4.8),
            L(f"M{cx + 8} {cy + 10} L{cx + 14} {cy + 20}", PEL, 2.6),
        ]
    o.append(R(cx - 8.5, cy + 6, 17, 16, 6, camisa[0], camisa[1], 2.0))
    o.append(E(cx, cy, r, r, PEL, PELB, 2.2))
    o.append(F(
        f"M{cx - r} {cy - 1} C{cx - r} {cy - r - 5} {cx + r} {cy - r - 5} {cx + r} {cy - 1} "
        f"C{cx + r * 0.3} {cy - r * 0.72} {cx - r * 0.3} {cy - r * 0.72} {cx - r} {cy - 1} Z",
        pelo,
    ))
    if ojos == "abertos":
        o.append(E(cx + 2.5 * mira - 2.6, cy + 1, 1.2, 1.5, TINTA))
        o.append(E(cx + 2.5 * mira + 2.6, cy + 1, 1.2, 1.5, TINTA))
        o.append(L(f"M{cx + 2.5 * mira - 2.5} {cy + 4.5} Q{cx + 2.5 * mira} {cy + 6.8} {cx + 2.5 * mira + 2.5} {cy + 4.5}", "#9a3412", 1.4))
    else:
        o.append(L(f"M{cx - 4.2} {cy + 1} Q{cx - 2.2} {cy + 3.2} {cx - 0.5} {cy + 1}", TINTA, 1.4))
        o.append(L(f"M{cx + 0.5} {cy + 1} Q{cx + 2.2} {cy + 3.2} {cx + 4.2} {cy + 1}", TINTA, 1.4))
        o.append(L(f"M{cx - 2.2} {cy + 5} Q{cx} {cy + 6.5} {cx + 2.2} {cy + 5}", "#9a3412", 1.3))
    return o


def cara_silencio(cx: float, cy: float, r: float = 20) -> list[dict]:
    """Rostro plano nítido con dedo índice vertical sobre los labios (gesto shh, sin texto)."""
    return [
        E(cx, cy, r, r, PEL, PELB, 2.4),
        F(f"M{cx - r} {cy - r * 0.15} C{cx - r * 0.9} {cy - r * 1.15} {cx + r * 0.9} {cy - r * 1.15} {cx + r} {cy - r * 0.15} "
          f"C{cx + r * 0.35} {cy - r * 0.75} {cx - r * 0.35} {cy - r * 0.75} {cx - r} {cy - r * 0.15} Z", BARRO),
        E(cx - r * 0.34, cy - r * 0.12, r * 0.11, r * 0.14, TINTA),
        E(cx + r * 0.34, cy - r * 0.12, r * 0.11, r * 0.14, TINTA),
        E(cx, cy + r * 0.32, r * 0.14, r * 0.12, "#9a3412"),
        E(cx + r * 0.08, cy + r * 0.95, r * 0.34, r * 0.24, PEL, PELB, 1.8),
        R(cx - r * 0.11, cy + r * 0.08, r * 0.22, r * 0.85, r * 0.1, PEL, PELB, 2.0),
    ]


def cara_dormida(cx: float, cy: float, r: float = 20, somnolienta: bool = False) -> list[dict]:
    """Rostro sereno con ojos cerrados durmiendo o somnoliento (sin letras Zzz)."""
    o = [
        E(cx, cy, r, r, PEL, PELB, 2.4),
        F(f"M{cx - r} {cy - r * 0.15} C{cx - r * 0.9} {cy - r * 1.15} {cx + r * 0.9} {cy - r * 1.15} {cx + r} {cy - r * 0.15} "
          f"C{cx + r * 0.35} {cy - r * 0.75} {cx - r * 0.35} {cy - r * 0.75} {cx - r} {cy - r * 0.15} Z", BARRO),
    ]
    if somnolienta:
        o += [
            L(f"M{cx - r * 0.52} {cy - r * 0.15} L{cx - r * 0.12} {cy - r * 0.15}", TINTA, 2.2),
            L(f"M{cx + r * 0.12} {cy - r * 0.15} L{cx + r * 0.52} {cy - r * 0.15}", TINTA, 2.2),
            L(f"M{cx - r * 0.48} {cy - r * 0.14} Q{cx - r * 0.32} {cy + r * 0.06} {cx - r * 0.16} {cy - r * 0.14}", TINTA, 1.8),
            L(f"M{cx + r * 0.16} {cy - r * 0.14} Q{cx + r * 0.32} {cy + r * 0.06} {cx + r * 0.48} {cy - r * 0.14}", TINTA, 1.8),
            E(cx, cy + r * 0.36, r * 0.15, r * 0.1, "#9a3412"),
        ]
    else:
        o += [
            L(f"M{cx - r * 0.5} {cy - r * 0.05} Q{cx - r * 0.32} {cy + r * 0.16} {cx - r * 0.14} {cy - r * 0.05}", TINTA, 2.0),
            L(f"M{cx + r * 0.14} {cy - r * 0.05} Q{cx + r * 0.32} {cy + r * 0.16} {cx + r * 0.5} {cy - r * 0.05}", TINTA, 2.0),
            L(f"M{cx - r * 0.22} {cy + r * 0.38} Q{cx} {cy + r * 0.5} {cx + r * 0.22} {cy + r * 0.38}", "#9a3412", 1.8),
        ]
    return o


def nino_corriendo(
    cx: float,
    cy: float,
    mira: int = 1,
    camisa: tuple[str, str] = (ROJO, ROJO_OSCURO),
) -> list[dict]:
    """Niño corriendo con zancada amplia y brazos doblados."""
    return nino(
        (cx + 4 * mira, cy),
        (cx + 2 * mira, cy + 12),
        (cx - 2 * mira, cy + 30),
        [[(cx + 14 * mira, cy + 14), (cx + 20 * mira, cy + 8)], [(cx - 12 * mira, cy + 18), (cx - 18 * mira, cy + 12)]],
        [[(cx + 10 * mira, cy + 40), (cx + 18 * mira, cy + 50)], [(cx - 12 * mira, cy + 40), (cx - 22 * mira, cy + 46)]],
        camisa=camisa,
        mira=mira,
    )


def nino_saltando(
    cx: float,
    cy: float,
    brazos_arriba: bool = True,
    pata_coja: bool = False,
    camisa: tuple[str, str] = (ROJO, ROJO_OSCURO),
) -> list[dict]:
    """Niño en el aire saltando sobre el suelo."""
    brazos = [[(cx - 16, cy - 2)], [(cx + 16, cy - 2)]] if brazos_arriba else [[(cx - 14, cy + 20)], [(cx + 14, cy + 20)]]
    pernas = [[(cx - 5, cy + 46)], [(cx + 12, cy + 36), (cx + 4, cy + 42)]] if pata_coja else [[(cx - 8, cy + 42)], [(cx + 8, cy + 42)]]
    return nino((cx, cy), (cx, cy + 12), (cx, cy + 28), brazos, pernas, camisa=camisa)


def nino_inclinado(
    cx: float,
    cy: float,
    dx: float = 10,
    camisa: tuple[str, str] = (ROJO, ROJO_OSCURO),
) -> list[dict]:
    """Niño inclinando el tronco hacia un lado o hacia delante."""
    s = 1 if dx >= 0 else -1
    return nino(
        (cx + dx, cy),
        (cx + dx * 0.6, cy + 12),
        (cx, cy + 32),
        [[(cx + dx * 0.8 + 12, cy + 16)], [(cx + dx * 0.8 - 12, cy + 16)]],
        [[(cx - 6, cy + 54)], [(cx + 6, cy + 54)]],
        camisa=camisa,
        mira=s,
    )


def pina_prop(cx: float, cy: float, rx: float = 12, ry: float = 16) -> list[dict]:
    """Piña natural de pino marrón con escamas (distinta de la fruta pineapple)."""
    return [
        E(cx, cy, rx, ry, BARRO, "#451a03", 2.0),
        L(f"M{cx - rx * 0.7:.1f} {cy - ry * 0.35:.1f} Q{cx:.1f} {cy - ry * 0.1:.1f} {cx + rx * 0.7:.1f} {cy - ry * 0.35:.1f}", "#fef3c7", 1.4),
        L(f"M{cx - rx * 0.85:.1f} {cy + ry * 0.05:.1f} Q{cx:.1f} {cy + ry * 0.3:.1f} {cx + rx * 0.85:.1f} {cy + ry * 0.05:.1f}", "#fef3c7", 1.4),
        L(f"M{cx - rx * 0.65:.1f} {cy + ry * 0.45:.1f} Q{cx:.1f} {cy + ry * 0.68:.1f} {cx + rx * 0.65:.1f} {cy + ry * 0.45:.1f}", "#fef3c7", 1.4),
    ]


def charco_prop(cx: float, cy: float, rx: float = 28, ry: float = 8) -> list[dict]:
    return [
        E(cx, cy, rx, ry, AGUA, AGUA_OSCURO, 2.0),
        E(cx - rx * 0.25, cy - ry * 0.2, rx * 0.35, ry * 0.25, "#bae6fd"),
    ]


