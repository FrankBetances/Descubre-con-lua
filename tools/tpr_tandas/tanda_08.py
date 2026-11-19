#!/usr/bin/env python3
"""Tanda 8 TPR (P2.89): cierre completo de señalar (`point`) y mirar (`look`), más primer bloque de mover (`move`).

Cubre 200 piezas revisadas + 127 auditadas sin base (`SIN_BASE`):
- Cierre completo de `point` (`chart`..`yellow`: 94+80).
- Cierre completo de `look` (`belly button`..`watch the rain`: 62+37).
- Primer bloque de `move` (`back and forth`..`many-legged`: 44+10).

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
    arco_giro,
    bebe,
    cara_dormida,
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
    nino,
    nino_busto,
    nino_corriendo,
    notas_col,
    ondas_calor,
    ondas_sonido,
    pelota_prop,
    plato_prop,
    pompas,
    sol,
)

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "shoe": ("Flat shoe", "U", "Zapato plano listo para señalar."),
    "picture": ("Framed picture", "U", "Cuadro enmarcado con paisaje para mirar a través."),
    "rainy": ("Umbrella with rain drops", "R", "Paraguas bajo gotas de lluvia en día lluvioso."),
    "leafy green": ("Leafy green", "U", "Hojas verdes frescas y frondosas."),
}

DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _nino_pie(cx: float, cy: float, camisa: tuple[str, str] = (ROJO, ROJO_OSCURO), mira: int = 1) -> list[dict]:
    return nino(
        (cx, cy), (cx, cy + 12), (cx, cy + 28),
        [[(cx - 12, cy + 22)], [(cx + 12, cy + 22)]],
        [[(cx - 6, cy + 46)], [(cx + 6, cy + 46)]],
        camisa=camisa, mira=mira,
    )


def _mano_indice(cx: float, cy: float, dx: float = -1, dy: float = 0, manga: tuple[str, str] = (AZUL, AZUL_OSCURO)) -> list[dict]:
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


def _estrella(cx: float, cy: float, r: float, col: str = AMARILLO, borde: str = AMARILLO_OSCURO, sw: float = 1.6) -> list[dict]:
    pts = []
    for i in range(10):
        ang = -math.pi / 2 + i * math.pi / 5
        rad = r if i % 2 == 0 else r * 0.44
        pts.append((round(cx + rad * math.cos(ang), 1), round(cy + rad * math.sin(ang), 1)))
    return [P(pts, col, borde, sw)]


def _lupa(cx: float, cy: float, r: float = 13) -> list[dict]:
    hx, hy = cx + r * 0.72, cy + r * 0.72
    return [
        L(f"M{hx:.1f} {hy:.1f} L{hx + 15:.1f} {hy + 15:.1f}", MADERA_OSCURA, 5.2),
        L(f"M{hx:.1f} {hy:.1f} L{hx + 15:.1f} {hy + 15:.1f}", MADERA, 2.8),
        E(cx, cy, r, r, "#e0f2fe", GRIS_OSCURO, 2.6),
        L(f"M{cx - r * 0.5:.1f} {cy - r * 0.4:.1f} Q{cx - r * 0.15:.1f} {cy - r * 0.65:.1f} {cx + r * 0.2:.1f} {cy - r * 0.5:.1f}", BLANCO, 1.8),
    ]


def _sol(cx: float, cy: float, r: float = 12) -> list[dict]:
    return [E(cx, cy, r, r, "#fde047", AMARILLO_OSCURO, 2.0)]


def _frecha(x1: float, y1: float, x2: float, y2: float, cor: str = "#ffffff", sw: float = 2.4) -> list[dict]:
    return frecha((x1, y1), (x2, y2), cor, sw)


def _ojo(cx: float, cy: float, sc: float = 1.0) -> list[dict]:
    return [
        F(f"M{cx - 12 * sc:.1f} {cy:.1f} Q{cx:.1f} {cy - 9 * sc:.1f} {cx + 12 * sc:.1f} {cy:.1f} "
          f"Q{cx:.1f} {cy + 9 * sc:.1f} {cx - 12 * sc:.1f} {cy:.1f} Z", BLANCO, TINTA, 1.8),
        E(cx, cy, 4.2 * sc, 4.2 * sc, AZUL_OSCURO),
        E(cx, cy, 2.0 * sc, 2.0 * sc, NEGRO),
        E(cx - 1.2 * sc, cy - 1.2 * sc, 0.9 * sc, 0.9 * sc, BLANCO),
    ]


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── point (cierre: 93 escenas + 1 directa = 94) ─────────────────────────
    put("chart", "D",
        fondo_sala() + [
            R(36, 16, 84, 62, 4, BLANCO, GRIS_OSCURO, 2.2),
            R(46, 52, 12, 20, 1, AZUL, AZUL_OSCURO, 1.4),
            R(64, 38, 12, 34, 1, VERDE, VERDE_OSCURO, 1.4),
            R(82, 26, 12, 46, 1, ROJO, ROJO_OSCURO, 1.4),
            R(100, 44, 12, 28, 1, AMARILLO, AMARILLO_OSCURO, 1.4),
        ] + _mano_indice(126, 40, -1, 0, (ROJO, ROJO_OSCURO)),
        "Tabla gráfica con barras de colores señalada con el índice.")
    put("corner piece", "D",
        fondo_mesa() + [
            R(44, 30, 48, 42, 4, AZUL, AZUL_OSCURO, 2.2),
            E(92, 51, 9, 9, AZUL, AZUL_OSCURO, 2.0),
            E(68, 72, 9, 9, AZUL, AZUL_OSCURO, 2.0),
            E(44, 30, 8, 8, AMARILLO, ROJO_OSCURO, 2.0),
        ] + _mano_indice(24, 24, 1, 1, (ROJO, ROJO_OSCURO)),
        "Pieza de puzle con dos bordes rectos y su esquina resaltada señalada.")
    put("darker", "D",
        fondo_prado() + [
            F("M44 64 C32 42 52 24 66 44 C58 60 50 66 44 64 Z", "#86efac", VERDE_OSCURO, 2.0),
            F("M98 64 C86 42 106 24 120 44 C112 60 104 66 98 64 Z", "#14532d", NEGRO, 2.0),
        ] + _mano_indice(128, 72, -1, -1, (AZUL, AZUL_OSCURO)),
        "Dos hojas verdes comparadas señalando claramente la más oscura.")
    put("darkest shade", "D",
        fondo_sala() + [
            R(28, 30, 26, 38, 4, "#bae6fd", AZUL_OSCURO, 1.8),
            R(62, 30, 26, 38, 4, "#0284c7", AZUL_OSCURO, 1.8),
            R(96, 30, 28, 38, 4, "#172554", NEGRO, 2.4),
        ] + _mano_indice(112, 78, 0, -1, (ROJO, ROJO_OSCURO)),
        "Tres muestras de azul gradual señalando la tonalidad más oscura.")
    put("direction", "D",
        fondo_prado() + [
            R(74, 34, 8, 44, 2, MADERA, MADERA_OSCURA, 2.0),
            P([(48, 28), (112, 28), (124, 36), (112, 44), (48, 44)], AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M62 36 L108 36", ROJO_OSCURO, 3.0),
            P([(102, 31), (114, 36), (102, 41)], ROJO_OSCURO),
        ] + _nino_pie(34, 34, (AZUL, AZUL_OSCURO), 1),
        "Poste indicador de camino con flecha apuntando hacia delante junto al niño.")
    put("disco", "D",
        fondo_noite() + [
            L("M78 0 L78 18", GRIS, 2.0),
            E(78, 28, 12, 12, PLATA, GRIS_OSCURO, 2.0),
            L("M66 28 L90 28 M78 16 L78 40 M70 20 L86 36 M86 20 L70 36", BLANCO, 1.2),
            L("M78 40 L34 86 M78 40 L122 86", "#f472b6", 1.8),
            L("M78 40 L56 86 M78 40 L100 86", "#fde047", 1.8),
        ] + nino((78, 48), (78, 58), (78, 72), [[(60, 44)], [(96, 76)]], [[(70, 88)], [(86, 88)]], camisa=(MORADO, "#5b21b6")),
        "Pista oscura iluminada por bola de espejos con niño bailando señalando arriba y abajo.")
    put("distant", "D",
        fondo_prado() + [
            P([(84, 58), (116, 26), (146, 58)], GRIS, GRIS_OSCURO, 2.0),
            P([(106, 36), (116, 26), (126, 36), (116, 39)], BLANCO),
            L("M58 46 L104 34", AMARILLO_OSCURO, 1.8),
        ] + _mano_indice(34, 56, 1, -0.5, (ROJO, ROJO_OSCURO)),
        "Mano señalando a una cima lejana en el horizonte tras la pradera.")
    put("far", "D",
        fondo_prado() + [
            P([(48, 86), (62, 86), (116, 54), (112, 54)], TIERRA_CLARA),
            R(112, 42, 14, 12, 1, ROJO, ROJO_OSCURO, 1.6),
            P([(110, 42), (119, 34), (128, 42)], MADERA_OSCURA),
        ] + nino((34, 38), (34, 50), (34, 65), [[(22, 60)], [(56, 48)]], [[(28, 82)], [(40, 82)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
        "Niño con el brazo estirado señalando muy lejos al final de un camino largo.")
    put("faraway", "D",
        fondo_mar() + [
            F("M102 56 Q116 44 134 56 Z", AMARILLO, MADERA_OSCURA, 1.8),
            P([(114, 46), (118, 32), (124, 32), (126, 46)], GRIS, GRIS_OSCURO, 1.4),
            R(112, 28, 16, 6, 1, BLANCO, GRIS_OSCURO, 1.4),
            L("M48 56 L100 44", BLANCO, 1.5),
        ] + _mano_indice(28, 62, 1, -0.4, (AZUL, AZUL_OSCURO)),
        "Isla muy lejana en el horizonte del mar señalada con brazo extendido.")
    put("feelings chart", "D",
        fondo_sala() + [
            R(34, 16, 88, 62, 4, "#fef9c3", MADERA_OSCURA, 2.2),
            E(56, 36, 12, 12, "#fde047", AMARILLO_OSCURO, 1.8),
            L("M51 39 Q56 44 61 39", TINTA, 1.5),
            E(52, 34, 1.2, 1.4, TINTA), E(60, 34, 1.2, 1.4, TINTA),
            E(100, 36, 12, 12, "#bae6fd", AZUL_OSCURO, 1.8),
            L("M95 41 Q100 37 105 41", TINTA, 1.5),
            E(96, 34, 1.2, 1.4, TINTA), E(104, 34, 1.2, 1.4, TINTA),
            E(56, 62, 12, 12, "#fca5a5", ROJO_OSCURO, 1.8),
            L("M52 57 L56 59 M60 57 L56 59", TINTA, 1.4),
            L("M52 66 L60 66", TINTA, 1.5),
            E(100, 62, 12, 12, "#bbf7d0", VERDE_OSCURO, 1.8),
            E(96, 59, 1.2, 1.4, TINTA), E(104, 59, 1.2, 1.4, TINTA),
            E(100, 65, 2.2, 2.6, TINTA),
        ] + _mano_indice(126, 40, -1, 0, (ROJO, ROJO_OSCURO)),
        "Panel mural con cuatro caras de emociones señalando una de ellas.")
    put("fewest", "D",
        fondo_mesa() + [
            E(34, 58, 7, 7, ROJO, ROJO_OSCURO, 1.6),
            E(72, 58, 7, 7, ROJO, ROJO_OSCURO, 1.6), E(86, 58, 7, 7, ROJO, ROJO_OSCURO, 1.6),
            E(79, 46, 7, 7, ROJO, ROJO_OSCURO, 1.6),
            E(110, 58, 6, 6, ROJO, ROJO_OSCURO, 1.4), E(122, 58, 6, 6, ROJO, ROJO_OSCURO, 1.4),
            E(134, 58, 6, 6, ROJO, ROJO_OSCURO, 1.4), E(116, 47, 6, 6, ROJO, ROJO_OSCURO, 1.4),
            E(128, 47, 6, 6, ROJO, ROJO_OSCURO, 1.4), E(122, 36, 6, 6, ROJO, ROJO_OSCURO, 1.4),
        ] + _mano_indice(34, 28, 0, 1, (VERDE, VERDE_OSCURO)),
        "Tres montones de bolas con dedo señalando el grupo que tiene menos (solo una).")
    put("find the way", "D",
        fondo_sala() + [
            R(36, 18, 84, 58, 4, "#fef3c7", MADERA_OSCURA, 2.2),
            L("M48 64 Q68 38 86 52 Q100 62 108 32", AZUL_OSCURO, 2.6),
            E(48, 64, 4, 4, VERDE, VERDE_OSCURO, 1.6),
            P([(102, 26), (114, 26), (114, 34), (102, 34)], ROJO, ROJO_OSCURO, 1.4),
        ] + _mano_indice(118, 62, -1, -1, (ROJO, ROJO_OSCURO)),
        "Mapa con ruta curva dibujada de inicio a casita señalando cómo llegar.")
    put("fish market", "D",
        fondo_sala() + [
            P([(30, 30), (126, 30), (118, 16), (38, 16)], AZUL, AZUL_OSCURO, 2.0),
            R(36, 46, 84, 32, 3, MADERA, MADERA_OSCURA, 2.2),
            R(44, 38, 30, 12, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            R(82, 38, 30, 12, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            E(58, 42, 7, 3.5, AZUL_OSCURO), P([(50, 42), (46, 39), (46, 45)], AZUL_OSCURO),
            E(96, 42, 7, 3.5, AZUL_OSCURO), P([(88, 42), (84, 39), (84, 45)], AZUL_OSCURO),
        ] + _mano_indice(126, 62, -1, -1, (ROJO, ROJO_OSCURO)),
        "Mostrador de lonja con toldo y cajas azules con pescado fresco señalado.")
    put("foamy mouth", "D",
        fondo_sala() + [
            E(74, 48, 25, 25, PEL, PELB, 2.2),
            E(64, 41, 2.2, 2.6, TINTA), E(84, 41, 2.2, 2.6, TINTA),
            L("M66 56 Q74 62 82 56", ROSA_OSCURO, 2.0),
            E(64, 57, 5.5, 4.5, BLANCO, GRIS_OSCURO, 1.4),
            E(74, 54, 6.0, 4.5, BLANCO, GRIS_OSCURO, 1.4),
            E(84, 57, 5.5, 4.5, BLANCO, GRIS_OSCURO, 1.4),
            E(69, 62, 5.0, 4.0, BLANCO, GRIS_OSCURO, 1.4),
            E(79, 62, 5.0, 4.0, BLANCO, GRIS_OSCURO, 1.4),
            E(74, 58, 8.0, 4.5, BLANCO),
        ] + _mano_indice(112, 60, -1, 0, (AZUL, AZUL_OSCURO)),
        "Cara con espuma blanca de pasta o jabón alrededor de la boca señalada.")
    put("fresh green", "D",
        fondo_prado() + [
            R(42, 64, 72, 16, 4, TIERRA, BARRO, 1.8),
            L("M66 64 L66 42 M90 64 L90 38", VERDE_OSCURO, 2.8),
            F("M66 44 Q52 34 54 48 Q60 52 66 44 Z", "#4ade80", VERDE_OSCURO, 1.8),
            F("M66 44 Q80 34 78 48 Q72 52 66 44 Z", "#4ade80", VERDE_OSCURO, 1.8),
            F("M90 38 Q76 28 78 42 Q84 46 90 38 Z", "#4ade80", VERDE_OSCURO, 1.8),
            F("M90 38 Q104 28 102 42 Q96 46 90 38 Z", "#4ade80", VERDE_OSCURO, 1.8),
        ] + _mano_indice(122, 48, -1, -0.4, (AZUL, AZUL_OSCURO)),
        "Brotes nuevos de color verde fresco brillante saliendo de la tierra señalados.")
    put("front teeth", "D",
        fondo_sala() + [
            E(72, 48, 30, 21, "#be123c", NEGRO, 2.2),
            E(72, 48, 22, 13, "#881337"),
            R(60, 35, 11, 10, 2, BLANCO, GRIS_OSCURO, 1.6),
            R(73, 35, 11, 10, 2, BLANCO, GRIS_OSCURO, 1.6),
            R(60, 52, 11, 9, 2, BLANCO, GRIS_OSCURO, 1.6),
            R(73, 52, 11, 9, 2, BLANCO, GRIS_OSCURO, 1.6),
        ] + _mano_indice(116, 44, -1, 0, (AZUL, AZUL_OSCURO)),
        "Boca abierta destacando los dientes centrales de delante señalados con el índice.")
    put("full of pips", "D",
        fondo_mesa() + [
            F("M44 58 C44 26 112 26 112 58 Z", VERDE, VERDE_OSCURO, 2.2),
            F("M48 56 C48 31 108 31 108 56 Z", ROJO, ROJO_OSCURO, 1.6),
            E(64, 48, 2.2, 3.2, NEGRO), E(74, 42, 2.2, 3.2, NEGRO),
            E(84, 48, 2.2, 3.2, NEGRO), E(94, 43, 2.2, 3.2, NEGRO),
            E(70, 52, 2.2, 3.2, NEGRO), E(80, 52, 2.2, 3.2, NEGRO),
            E(90, 52, 2.2, 3.2, NEGRO),
        ] + _mano_indice(124, 34, -1, 0.5, (AZUL, AZUL_OSCURO)),
        "Tajada roja de sandía llena de pepitas negras señaladas con el dedo.")
    put("garden hose", "D",
        fondo_prado() + [
            E(46, 62, 18, 14, VERDE, VERDE_OSCURO, 3.4),
            E(46, 62, 11, 8, HERBA, VERDE_OSCURO, 2.0),
            L("M64 62 Q82 54 92 48", VERDE_OSCURO, 4.5),
            R(90, 44, 10, 7, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
            L("M100 47 L122 38 M100 49 L124 49 M100 51 L120 60", AGUA, 2.2),
            L("M124 68 L124 58", VERDE_OSCURO, 2.4),
            E(124, 56, 6, 5, ROSA, ROSA_OSCURO, 1.5),
        ],
        "Manguera verde enrollada apuntando y regando con chorros de agua las flores.")
    put("goal", "D",
        fondo_prado() + [
            R(106, 26, 5, 50, 2, MADERA, MADERA_OSCURA, 1.8),
            P([(111, 26), (138, 32), (111, 40)], ROJO, ROJO_OSCURO, 1.8),
            L("M48 72 L106 72", BLANCO, 3.0),
        ] + _nino_pie(34, 34, (AZUL, AZUL_OSCURO), 1),
        "Bandera de meta lejana al final de la pista señalada por el niño.")
    put("golden", "D",
        fondo_sala() + [
            P([(48, 66), (56, 44), (100, 44), (108, 66)], "#facc15", AMARILLO_OSCURO, 2.4),
            E(78, 32, 12, 12, "#fde047", AMARILLO_OSCURO, 2.2),
            L("M64 48 L92 48 M70 26 L75 26", BLANCO, 2.0),
        ] + _mano_indice(122, 40, -1, 0, (ROJO, ROJO_OSCURO)),
        "Lingote y medalla dorados relucientes señalados para mostrar el color dorado.")
    put("grey", "D",
        fondo_mesa() + [
            E(46, 56, 15, 11, "#94a3b8", "#475569", 2.0),
            R(72, 42, 24, 24, 4, "#cbd5e1", "#475569", 2.0),
            E(112, 56, 12, 12, "#64748b", "#334155", 2.0),
        ] + _mano_indice(84, 22, 0, 1, (AZUL, AZUL_OSCURO)),
        "Objetos de color gris (piedra, cubo y esfera) señalados sobre la mesa.")
    put("harbour", "D",
        fondo_mar() + [
            R(16, 44, 52, 16, 2, "#cbd5e1", GRIS_OSCURO, 2.0),
            R(26, 60, 8, 18, 1, MADERA_OSCURA),
            R(50, 60, 8, 18, 1, MADERA_OSCURA),
            F("M82 62 L124 62 L116 74 L90 74 Z", ROJO, ROJO_OSCURO, 2.0),
            P([(102, 34), (102, 58), (120, 58)], BLANCO, GRIS_OSCURO, 1.8),
        ] + _mano_indice(132, 32, -1, 0.4, (AZUL, AZUL_OSCURO)),
        "Muelle del puerto con veleros atracados en el agua señalado.")
    put("hearing", "D",
        fondo_sala() + [
            F("M66 28 C84 26 90 44 82 60 C76 70 62 72 60 60", PEL, PELB, 3.0),
            F("M68 38 C78 38 78 54 68 56", PELB, None, 2.2),
        ] + ondas_sonido(42, 46, AZUL_OSCURO, 1) + _mano_indice(112, 50, -1, 0, (ROJO, ROJO_OSCURO)),
        "Oreja recibiendo ondas de sonido señalada para representar el sentido del oído.")
    put("heater", "D",
        fondo_sala() + [
            R(40, 34, 64, 40, 4, "#f1f5f9", GRIS_OSCURO, 2.2),
            L("M52 38 L52 70 M64 38 L64 70 M76 38 L76 70 M88 38 L88 70 M98 38 L98 70", GRIS_OSCURO, 2.8),
        ] + ondas_calor(58, 22, ROJO) + _mano_indice(124, 54, -1, 0, (AZUL, AZUL_OSCURO)),
        "Radiador blanco emitiendo ondas rojas de calor señalado con la mano.")
    put("hiding place", "D",
        fondo_prado() + [
            E(68, 56, 28, 22, VERDE, VERDE_OSCURO, 2.2),
            E(54, 60, 18, 16, "#22c55e", VERDE_OSCURO, 1.8),
            E(82, 60, 18, 16, "#22c55e", VERDE_OSCURO, 1.8),
            E(72, 44, 3, 9, BLANCO, GRIS_OSCURO, 1.5),
            E(80, 44, 3, 9, BLANCO, GRIS_OSCURO, 1.5),
            E(76, 51, 7, 6, BLANCO, GRIS_OSCURO, 1.5),
        ] + _mano_indice(118, 42, -1, 0.3, (ROJO, ROJO_OSCURO)),
        "Escondite entre arbustos donde asoma un conejito señalado con el dedo.")
    put("high up", "D",
        fondo_cielo() + [
            R(110, 62, 7, 22, 1, MADERA_OSCURA),
            E(114, 54, 14, 12, VERDE, VERDE_OSCURO, 1.8),
            P([(62, 14), (74, 24), (62, 34), (50, 24)], ROJO, ROJO_OSCURO, 2.0),
            L("M62 34 Q68 46 60 56", AMARILLO_OSCURO, 1.6),
        ] + _mano_indice(34, 62, 1, -1, (AZUL, AZUL_OSCURO)),
        "Cometa volando muy alto en el cielo muy por encima del árbol señalada hacia arriba.")
    put("in the tree", "D",
        fondo_prado() + [
            R(72, 52, 12, 30, 2, MADERA, MADERA_OSCURA, 2.0),
            E(78, 36, 30, 24, VERDE, VERDE_OSCURO, 2.2),
            E(78, 34, 9, 4, BARRO, MADERA_OSCURA, 1.6),
            E(78, 30, 5, 5, AZUL, AZUL_OSCURO, 1.5),
        ] + _mano_indice(122, 50, -1, -0.5, (ROJO, ROJO_OSCURO)),
        "Nido y pajarito posados en lo alto de la copa del árbol señalados.")
    put("landmark", "D",
        fondo_prado() + [
            P([(66, 74), (72, 22), (84, 22), (90, 74)], BLANCO, GRIS_OSCURO, 2.2),
            R(69, 34, 18, 8, 1, ROJO, ROJO_OSCURO, 1.4),
            R(68, 52, 20, 8, 1, ROJO, ROJO_OSCURO, 1.4),
            R(70, 14, 16, 9, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
        ] + _mano_indice(122, 44, -1, -0.3, (AZUL, AZUL_OSCURO)),
        "Torre faro alta y reconocible en el paisaje señalada como punto de referencia.")
    put("leader", "D",
        fondo_prado() + _nino_pie(114, 34, (ROJO, ROJO_OSCURO), 1) + [
            L("M126 20 L126 48", MADERA_OSCURA, 2.2),
            P([(126, 20), (144, 26), (126, 32)], AMARILLO, AMARILLO_OSCURO, 1.6),
        ] + _nino_pie(76, 36, (AZUL, AZUL_OSCURO), 1) + _nino_pie(42, 36, (VERDE, VERDE_OSCURO), 1),
        "Niño con bandera al frente guiando la fila mientras los demás lo siguen.")
    put("leaves on my shoes", "D",
        fondo_prado() + [
            R(40, 56, 30, 14, 6, AZUL, AZUL_OSCURO, 2.0),
            R(84, 56, 30, 14, 6, AZUL, AZUL_OSCURO, 2.0),
            F("M48 56 Q56 42 66 50 Q58 60 48 56 Z", NARANJA, NARANJA_OSCURO, 1.8),
            F("M94 56 Q102 42 112 50 Q104 60 94 56 Z", AMARILLO, AMARILLO_OSCURO, 1.8),
        ] + _mano_indice(78, 28, 0, 1, (ROJO, ROJO_OSCURO)),
        "Hojas de otoño pegadas encima de los zapatos señaladas con la mano.")
    put("left side", "D",
        fondo_sala() + [
            R(36, 22, 42, 52, 4, AZUL, AZUL_OSCURO, 2.4),
            R(78, 22, 42, 52, 4, "#e2e8f0", GRIS_OSCURO, 1.8),
            L("M78 18 L78 78", NEGRO, 2.2),
        ] + _mano_indice(20, 48, 1, 0, (ROJO, ROJO_OSCURO)),
        "Panel partido por la mitad con el lado izquierdo resaltado en azul y señalado.")
    put("leftover", "D",
        fondo_mesa() + plato_prop(74, 54, 24) + [
            P([(68, 52), (82, 46), (86, 58)], "#fde68a", NARANJA_OSCURO, 1.8),
            E(60, 56, 2.2, 2.2, NARANJA_OSCURO),
            E(88, 52, 2.0, 2.0, NARANJA_OSCURO),
        ] + _mano_indice(116, 40, -1, 0.4, (AZUL, AZUL_OSCURO)),
        "Plato después de comer con un pequeño trozo sobrante señalado.")
    put("lighter", "D",
        fondo_prado() + [
            F("M44 64 C32 42 52 24 66 44 C58 60 50 66 44 64 Z", "#14532d", NEGRO, 2.0),
            F("M98 64 C86 42 106 24 120 44 C112 60 104 66 98 64 Z", "#bef264", VERDE_OSCURO, 2.0),
        ] + _mano_indice(128, 72, -1, -1, (ROJO, ROJO_OSCURO)),
        "Dos hojas comparadas señalando la de tono verde más claro.")
    put("look at the ducks", "D",
        fondo_mar() + [
            E(88, 58, 12, 7, BLANCO, GRIS_OSCURO, 1.8),
            E(96, 50, 6, 6, VERDE, VERDE_OSCURO, 1.8),
            P([(102, 49), (108, 51), (102, 53)], NARANJA),
            E(122, 60, 10, 6, BLANCO, GRIS_OSCURO, 1.8),
            E(128, 53, 5, 5, VERDE, VERDE_OSCURO, 1.8),
        ] + _nino_pie(36, 32, (ROJO, ROJO_OSCURO), 1),
        "Niño junto al estanque señalando hacia los patos nadando.")
    put("look at the lights", "D",
        fondo_noite() + [
            L("M18 22 Q78 36 138 22", GRIS, 1.8),
            E(34, 27, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.5),
            E(62, 31, 5, 5, ROJO, ROJO_OSCURO, 1.5),
            E(94, 31, 5, 5, AGUA, AZUL_OSCURO, 1.5),
            E(122, 27, 5, 5, "#4ade80", VERDE_OSCURO, 1.5),
        ] + bebe(72, 62) + _frecha(76, 52, 86, 36, AMARILLO, 2.2),
        "Bebé mirando hacia arriba y señalando las luces encendidas de colores.")
    put("look behind you", "D",
        fondo_prado() + _nino_pie(74, 34, (AZUL, AZUL_OSCURO), -1) + [
            E(118, 58, 10, 12, BARRO, MADERA_OSCURA, 1.8),
            E(114, 46, 5, 5, BARRO, MADERA_OSCURA, 1.5),
            E(124, 46, 5, 5, BARRO, MADERA_OSCURA, 1.5),
        ] + _frecha(88, 42, 108, 42, ROJO_OSCURO, 2.2),
        "Niño girando la cabeza para mirar detrás donde señala una flecha.")
    put("look how high it flies", "D",
        fondo_cielo() + [
            F("M88 22 Q98 16 108 22 Q98 25 88 22 Z", BLANCO, GRIS_OSCURO, 1.8),
            P([(94, 21), (86, 12), (99, 20)], BLANCO, GRIS_OSCURO, 1.4),
            L("M56 54 L84 26", ROJO, 2.0),
            P([(78, 26), (86, 24), (84, 32)], ROJO),
        ] + _nino_pie(38, 34, (ROJO, ROJO_OSCURO), 1),
        "Niño mirando al cielo y señalando un pájaro volando muy alto.")
    put("look, a rainbow", "D",
        fondo_cielo() + [
            F("M36 58 C36 22 124 22 124 58", ROJO, ROJO, 4.0),
            F("M41 58 C41 27 119 27 119 58", NARANJA, NARANJA, 3.8),
            F("M46 58 C46 32 114 32 114 58", AMARILLO, AMARILLO, 3.8),
            F("M51 58 C51 37 109 37 109 58", VERDE, VERDE, 3.8),
            F("M56 58 C56 42 104 42 104 58", AZUL, AZUL, 3.8),
        ] + _nino_pie(26, 36, (AZUL, AZUL_OSCURO), 1),
        "Niño señalando emocionado un arcoíris completo en el cielo.")
    put("look, a sand pie", "D",
        fondo_prado() + [
            R(0, 58, 156, 30, 0, "#fde68a"),
            P([(58, 66), (66, 46), (92, 46), (100, 66)], "#f59e0b", MADERA_OSCURA, 2.2),
            E(79, 44, 6, 4, ROJO, ROJO_OSCURO, 1.6),
        ] + _mano_indice(122, 46, -1, 0.3, (AZUL, AZUL_OSCURO)),
        "Flan de arena moldeado en la playa señalado con entusiasmo.")
    put("look, dolphins", "D",
        fondo_mar() + [
            F("M68 58 Q82 32 102 48 Q92 52 84 60 Z", AZUL, AZUL_OSCURO, 2.2),
            F("M102 58 Q116 36 132 50 Q122 54 114 60 Z", "#38bdf8", AZUL_OSCURO, 2.0),
        ] + _mano_indice(34, 48, 1, -0.3, (ROJO, ROJO_OSCURO)),
        "Mano desde la costa señalando dos delfines saltando sobre las olas.")
    put("month", "D",
        fondo_sala() + [
            R(34, 16, 84, 62, 4, BLANCO, GRIS_OSCURO, 2.2),
            R(34, 16, 84, 14, 4, ROJO, ROJO_OSCURO, 2.0),
            L("M38 42 L114 42 M38 54 L114 54 M38 66 L114 66", GRIS, 1.3),
            L("M58 30 L58 76 M78 30 L78 76 M98 30 L98 76", GRIS, 1.3),
            R(58, 42, 20, 12, 1, "#fde047", AMARILLO_OSCURO, 1.6),
        ] + _mano_indice(128, 48, -1, 0, (AZUL, AZUL_OSCURO)),
        "Hoja mensual completa de calendario señalada en la pared.")
    put("most", "D",
        fondo_mesa() + [
            E(32, 58, 6, 6, AZUL, AZUL_OSCURO, 1.5),
            E(68, 58, 6, 6, AZUL, AZUL_OSCURO, 1.5), E(80, 58, 6, 6, AZUL, AZUL_OSCURO, 1.5),
            E(106, 58, 6, 6, AZUL, AZUL_OSCURO, 1.5), E(118, 58, 6, 6, AZUL, AZUL_OSCURO, 1.5),
            E(130, 58, 6, 6, AZUL, AZUL_OSCURO, 1.5), E(112, 47, 6, 6, AZUL, AZUL_OSCURO, 1.5),
            E(124, 47, 6, 6, AZUL, AZUL_OSCURO, 1.5), E(118, 36, 6, 6, AZUL, AZUL_OSCURO, 1.5),
        ] + _mano_indice(118, 20, 0, 1, (ROJO, ROJO_OSCURO)),
        "Tres grupos de piezas con el dedo señalando claramente el grupo con más.")
    put("multicoloured", "D",
        fondo_cielo() + [
            L("M78 36 L78 78", MADERA_OSCURA, 2.4),
            P([(78, 36), (52, 24), (70, 16)], ROJO, NEGRO, 1.5),
            P([(78, 36), (70, 16), (92, 18)], AMARILLO, NEGRO, 1.5),
            P([(78, 36), (92, 18), (104, 34)], VERDE, NEGRO, 1.5),
            P([(78, 36), (104, 34), (94, 52)], AZUL, NEGRO, 1.5),
            P([(78, 36), (94, 52), (66, 52)], MORADO, NEGRO, 1.5),
            P([(78, 36), (66, 52), (52, 24)], NARANJA, NEGRO, 1.5),
        ] + _mano_indice(124, 42, -1, 0, (AZUL, AZUL_OSCURO)),
        "Molinillo multicolor de seis aspas brillantes señalado.")
    put("mummy and me", "D",
        fondo_sala() + _nino_pie(58, 22, (MORADO, "#5b21b6"), 1) + _nino_pie(94, 42, (ROJO, ROJO_OSCURO), -1),
        "Mamá y su peque de la mano señalados juntos.")
    put("name tag", "D",
        fondo_sala() + [
            R(36, 22, 84, 54, 6, BLANCO, AZUL_OSCURO, 2.4),
            R(36, 22, 84, 16, 4, AZUL, AZUL_OSCURO, 2.0),
            L("M50 50 L106 50 M58 62 L98 62", GRIS_OSCURO, 3.0),
        ] + _mano_indice(126, 56, -1, 0, (ROJO, ROJO_OSCURO)),
        "Etiqueta de identificación sin texto con franjas limpias señalada.")
    put("nanny", "D",
        fondo_prado() + _nino_pie(56, 22, (VERDE, VERDE_OSCURO), 1) + [
            R(84, 50, 26, 16, 4, AZUL, AZUL_OSCURO, 2.0),
            L("M84 52 L74 42", GRIS_OSCURO, 2.2),
            E(90, 68, 5, 5, NEGRO), E(106, 68, 5, 5, NEGRO),
        ] + _mano_indice(34, 38, 1, 0, (ROJO, ROJO_OSCURO)),
        "Cuidadora llevando el carrito infantil señalada amablemente.")
    put("nearby shop", "D",
        fondo_prado() + [
            R(62, 30, 68, 44, 3, "#fef3c7", MADERA_OSCURA, 2.2),
            P([(58, 30), (134, 30), (128, 20), (64, 20)], ROJO, ROJO_OSCURO, 2.0),
            R(74, 48, 18, 26, 2, MADERA, MADERA_OSCURA, 1.6),
            R(98, 42, 22, 18, 2, "#bae6fd", AZUL_OSCURO, 1.6),
        ] + _nino_pie(36, 34, (AZUL, AZUL_OSCURO), 1),
        "Niño justo al lado de la tienda cercana señalándola de cerca.")
    put("next in line", "D",
        fondo_sala() + _nino_pie(112, 34, (GRIS, GRIS_OSCURO), 1)
        + _nino_pie(78, 34, (ROJO, ROJO_OSCURO), 1)
        + _nino_pie(44, 34, (AZUL, AZUL_OSCURO), 1)
        + _frecha(78, 14, 78, 28, ROJO_OSCURO, 2.4),
        "Fila de niños caminando con flecha señalando al siguiente en turno.")
    put("next stop", "D",
        fondo_prado() + [
            R(22, 42, 48, 28, 5, AMARILLO, AMARILLO_OSCURO, 2.2),
            R(28, 47, 14, 10, 2, "#bae6fd", AZUL_OSCURO, 1.4),
            R(46, 47, 16, 10, 2, "#bae6fd", AZUL_OSCURO, 1.4),
            E(34, 70, 5.5, 5.5, NEGRO), E(58, 70, 5.5, 5.5, NEGRO),
            L("M116 32 L116 74", GRIS_OSCURO, 2.8),
            E(116, 30, 10, 10, AZUL, AZUL_OSCURO, 2.0),
            E(116, 30, 5, 5, BLANCO),
        ] + _frecha(76, 52, 106, 42, ROJO_OSCURO, 2.4),
        "Autobús avanzando mientras se señala el poste de la siguiente parada.")
    put("opposite", "D",
        fondo_prado() + [
            R(24, 42, 32, 32, 3, ROJO, ROJO_OSCURO, 2.0),
            P([(20, 42), (40, 26), (60, 42)], MADERA_OSCURA),
            R(100, 42, 32, 32, 3, AZUL, AZUL_OSCURO, 2.0),
            P([(96, 42), (116, 26), (136, 42)], MADERA_OSCURA),
            R(66, 62, 24, 18, 0, GRIS),
        ] + _frecha(62, 46, 94, 46, ROJO_OSCURO, 2.4) + _frecha(94, 54, 62, 54, AZUL_OSCURO, 2.4),
        "Dos casas frente a frente al otro lado de la calle con flechas opuestas.")
    put("orange", "D",
        fondo_mesa() + [
            E(44, 54, 13, 12, NARANJA, NARANJA_OSCURO, 2.0),
            P([(72, 42), (82, 66), (62, 66)], NARANJA, NARANJA_OSCURO, 2.0),
            R(100, 44, 24, 22, 4, NARANJA, NARANJA_OSCURO, 2.0),
        ] + _mano_indice(74, 22, 0, 1, (AZUL, AZUL_OSCURO)),
        "Tres objetos de color naranja brillante señalados sobre la mesa.")
    put("picnic spot", "D",
        fondo_prado() + [
            R(36, 56, 84, 22, 3, BLANCO, ROJO_OSCURO, 2.0),
            R(40, 58, 18, 8, 0, "#fca5a5"), R(76, 58, 18, 8, 0, "#fca5a5"),
            R(58, 66, 18, 8, 0, "#fca5a5"), R(94, 66, 18, 8, 0, "#fca5a5"),
            R(64, 42, 28, 16, 3, MADERA, MADERA_OSCURA, 2.0),
            F("M68 42 C68 30 88 30 88 42", MADERA_OSCURA, None, 2.4),
        ] + _mano_indice(126, 36, -1, 0.5, (VERDE, VERDE_OSCURO)),
        "Mantel de cuadros rojos extendido con cesta en el prado señalando el sitio de merienda.")
    put("pink", "D",
        fondo_mesa() + [
            E(44, 54, 12, 12, ROSA, ROSA_OSCURO, 2.0),
            E(78, 54, 13, 13, "#f472b6", ROSA_OSCURO, 2.0),
            R(104, 44, 22, 22, 4, "#fbcfe8", ROSA_OSCURO, 2.0),
        ] + _mano_indice(78, 24, 0, 1, (AZUL, AZUL_OSCURO)),
        "Colección de piezas rosa señaladas para aprender el color rosa.")
    put("place", "D",
        fondo_sala() + [
            R(30, 56, 96, 20, 4, MADERA, MADERA_OSCURA, 2.2),
            R(38, 42, 20, 14, 2, "#dbeafe", AZUL_OSCURO, 1.8),
            R(68, 42, 20, 14, 2, "#fef9c3", AMARILLO_OSCURO, 1.8),
            R(98, 42, 20, 14, 2, "#dcfce7", VERDE_OSCURO, 1.8),
        ] + _mano_indice(78, 22, 0, 1, (ROJO, ROJO_OSCURO)),
        "Estantería con tres sitios delimitados donde va cada cosa señalados.")
    put("plastic goes in the yellow bin", "D",
        fondo_sala() + [
            R(64, 34, 44, 46, 4, AMARILLO, AMARILLO_OSCURO, 2.4),
            R(60, 28, 52, 8, 2, DORADO, AMARILLO_OSCURO, 2.0),
            R(36, 22, 14, 24, 4, "#bae6fd", AZUL_OSCURO, 2.0),
            R(40, 17, 6, 5, 1, AZUL_OSCURO),
        ] + _frecha(50, 26, 72, 24, ROJO_OSCURO, 2.4),
        "Botella de plástico entrando al contenedor amarillo señalado.")
    put("point", "D",
        fondo_mesa() + pelota_prop(46, 54, 14, ROJO, ROJO_OSCURO)
        + _mano_indice(96, 54, -1, 0, (AZUL, AZUL_OSCURO)),
        "Dedo índice extendido señalando directamente una pelota cercana.")
    put("point at", "D",
        fondo_prado() + [
            L("M84 44 L132 44", MADERA_OSCURA, 3.2),
            E(104, 36, 9, 6, AZUL, AZUL_OSCURO, 1.8),
            E(112, 32, 5, 5, AZUL, AZUL_OSCURO, 1.8),
            P([(117, 31), (123, 33), (117, 35)], NARANJA),
        ] + _nino_pie(38, 34, (ROJO, ROJO_OSCURO), 1),
        "Niño señalando directamente a un pájaro azul en la rama.")
    put("point to", "D",
        fondo_sala() + bebe(64, 52) + _mano_indice(102, 46, -1, 0.2, (ROJO, ROJO_OSCURO)),
        "Mano señalando suavemente la nariz del bebé sonriente.")
    put("point to the sky", "D",
        fondo_cielo() + _sol(114, 24, 12) + _nino_pie(58, 36, (AZUL, AZUL_OSCURO), 1)
        + _frecha(74, 34, 96, 16, ROJO_OSCURO, 2.4),
        "Niño en el campo mirando arriba y señalando hacia el cielo.")
    put("purple", "D",
        fondo_mesa() + [
            E(46, 54, 12, 12, MORADO, "#5b21b6", 2.0),
            R(68, 42, 22, 24, 4, "#a855f7", "#5b21b6", 2.0),
            E(112, 54, 12, 12, "#c084fc", "#5b21b6", 2.0),
        ] + _mano_indice(78, 22, 0, 1, (ROJO, ROJO_OSCURO)),
        "Tres piezas moradas señaladas para identificar el color morado.")
    put("rainbow bubble", "D",
        fondo_cielo() + [
            E(72, 44, 24, 24, "#e0f2fe", AGUA_OSCURO, 2.2),
            F("M54 36 Q72 22 90 36", ROJO, ROJO, 2.6),
            F("M52 44 Q72 30 92 44", AMARILLO, AMARILLO, 2.6),
            F("M54 52 Q72 38 90 52", VERDE, VERDE, 2.6),
        ] + _mano_indice(118, 56, -1, -0.4, (AZUL, AZUL_OSCURO)),
        "Gran pompa de jabón con franjas de arcoíris señalada en el aire.")
    put("right side", "D",
        fondo_sala() + [
            R(36, 22, 42, 52, 4, "#e2e8f0", GRIS_OSCURO, 1.8),
            R(78, 22, 42, 52, 4, VERDE, VERDE_OSCURO, 2.4),
            L("M78 18 L78 78", NEGRO, 2.2),
        ] + _mano_indice(136, 48, -1, 0, (ROJO, ROJO_OSCURO)),
        "Panel partido con la mitad derecha resaltada en verde y señalada.")
    put("roasted", "D",
        fondo_mesa() + [
            E(74, 58, 30, 11, NEGRO, GRIS_OSCURO, 2.2),
            E(64, 52, 8, 7, BARRO, "#451a03", 1.8),
            E(82, 52, 8, 7, BARRO, "#451a03", 1.8),
            E(73, 47, 8, 7, BARRO, "#451a03", 1.8),
        ] + ondas_calor(64, 26, ROJO) + _mano_indice(122, 46, -1, 0.2, (AZUL, AZUL_OSCURO)),
        "Castañas asadas humeando en la sartén señaladas con la mano.")
    put("robin", "D",
        fondo_prado() + [
            L("M30 64 L118 64", MADERA_OSCURA, 3.4),
            E(66, 46, 15, 11, BARRO, MADERA_OSCURA, 2.0),
            E(74, 48, 8, 7, ROJO, ROJO_OSCURO, 1.4),
            E(78, 34, 8, 8, BARRO, MADERA_OSCURA, 2.0),
            E(80, 33, 1.4, 1.4, NEGRO),
            P([(86, 33), (94, 35), (86, 37)], NARANJA),
        ] + _mano_indice(116, 48, -1, 0, (AZUL, AZUL_OSCURO)),
        "Petirrojo con el pecho rojo vivo posado en una rama y señalado.")
    put("sense of smell", "D",
        fondo_sala() + [
            E(68, 46, 22, 24, PEL, PELB, 2.2),
            F("M64 42 L64 52 Q68 56 72 52", PELB, None, 2.2),
            L("M66 58 Q72 62 78 58", "#9a3412", 1.6),
            E(60, 40, 1.8, 2.2, TINTA), E(76, 40, 1.8, 2.2, TINTA),
            L("M44 50 Q52 46 58 50 M44 56 Q52 52 58 56", VERDE_OSCURO, 2.0),
        ] + _mano_indice(108, 48, -1, 0, (ROJO, ROJO_OSCURO)),
        "Nariz percibiendo olores señalada para representar el sentido del olfato.")
    put("sense of taste", "D",
        fondo_sala() + [
            E(72, 48, 24, 16, ROSA_OSCURO, NEGRO, 2.2),
            F("M62 50 C62 68 82 68 82 50 Z", ROSA, ROSA_OSCURO, 1.8),
            L("M72 50 L72 60", ROSA_OSCURO, 1.5),
            E(72, 42, 7, 5, ROJO, ROJO_OSCURO, 1.6),
        ] + _mano_indice(114, 54, -1, 0, (AZUL, AZUL_OSCURO)),
        "Boca con lengua saboreando una fresa señalada para el sentido del gusto.")
    put("sequence strip", "D",
        fondo_sala() + [
            R(22, 26, 32, 34, 3, BLANCO, GRIS_OSCURO, 2.0),
            E(38, 46, 6, 4, TIERRA, BARRO, 1.5),
            R(62, 26, 32, 34, 3, BLANCO, GRIS_OSCURO, 2.0),
            L("M78 54 L78 38", VERDE_OSCURO, 2.2), E(74, 40, 4, 3, VERDE), E(82, 40, 4, 3, VERDE),
            R(102, 26, 32, 34, 3, BLANCO, GRIS_OSCURO, 2.0),
            L("M118 54 L118 38", VERDE_OSCURO, 2.2), E(118, 34, 6, 6, ROJO, ROJO_OSCURO, 1.5),
        ] + _frecha(38, 70, 118, 70, ROJO_OSCURO, 2.4),
        "Tira de tres viñetas de crecimiento (semilla, brote y flor) en secuencia de izquierda a derecha.")
    put("shapes in the room", "D",
        fondo_sala() + [
            P([(38, 48), (54, 24), (70, 48)], ROJO, ROJO_OSCURO, 2.0),
            R(78, 24, 26, 26, 3, AZUL, AZUL_OSCURO, 2.0),
            E(122, 37, 13, 13, AMARILLO, AMARILLO_OSCURO, 2.0),
        ] + _mano_indice(78, 70, 0, -1, (VERDE, VERDE_OSCURO)),
        "Triángulo, cuadrado y círculo colgados en la sala señalados.")
    put("sight", "D",
        fondo_sala() + _ojo(68, 46, 1.6) + [
            L("M90 46 L112 38 M90 46 L112 54", AZUL_OSCURO, 1.8),
        ] + _mano_indice(34, 58, 1, -0.5, (ROJO, ROJO_OSCURO)),
        "Ojo abierto con rayos visuales señalado para representar el sentido de la vista.")
    put("silver", "D",
        fondo_mesa() + [
            E(48, 54, 13, 13, "#e2e8f0", "#475569", 2.2),
            E(82, 50, 11, 16, "#cbd5e1", "#475569", 2.2),
            L("M82 66 L82 76", "#475569", 3.4),
            L("M44 48 L52 48 M78 44 L86 44", BLANCO, 2.2),
        ] + _mano_indice(122, 46, -1, 0, (AZUL, AZUL_OSCURO)),
        "Objetos de metal plateado brillante señalados sobre la mesa.")
    put("sister", "D",
        fondo_sala() + _nino_pie(58, 28, (ROSA, ROSA_OSCURO), 1) + [
            E(52, 20, 4, 3, AMARILLO, AMARILLO_OSCURO, 1.3),
        ] + _mano_indice(108, 44, -1, 0, (AZUL, AZUL_OSCURO)),
        "Niña hermana mayor con lazo señalada con cariño.")
    put("sky", "D",
        fondo_cielo() + [
            E(46, 26, 16, 10, BLANCO, NUBE_B, 1.6),
            E(104, 24, 18, 11, BLANCO, NUBE_B, 1.6),
        ] + _nino_pie(74, 38, (AZUL, AZUL_OSCURO), 1) + _frecha(74, 30, 74, 10, ROJO_OSCURO, 2.4),
        "Niño mirando hacia lo alto señalando el cielo azul con nubes.")
    put("sky blue", "D",
        fondo_cielo() + [
            R(52, 28, 48, 40, 6, "#38bdf8", AZUL_OSCURO, 2.4),
            E(76, 48, 12, 12, "#7dd3fc"),
        ] + _mano_indice(118, 48, -1, 0, (ROJO, ROJO_OSCURO)),
        "Muestra brillante de azul cielo señalada bajo el cielo despejado.")
    put("snowy outside", "D",
        fondo_sala() + [
            R(38, 14, 78, 56, 4, "#0f172a", MADERA_OSCURA, 3.0),
            R(44, 20, 66, 44, 2, "#bae6fd"),
            E(60, 34, 3, 3, BLANCO), E(84, 30, 3, 3, BLANCO),
            E(72, 46, 3, 3, BLANCO), E(96, 44, 3, 3, BLANCO),
            R(44, 54, 66, 10, 0, BLANCO),
            L("M77 16 L77 68 M40 42 L114 42", MADERA_OSCURA, 2.4),
        ] + _mano_indice(126, 48, -1, 0, (ROJO, ROJO_OSCURO)),
        "Ventana desde dentro señalando la nieve cayendo fuera.")
    put("snowy white", "D",
        fondo_cielo() + [
            E(56, 54, 18, 18, BLANCO, GRIS_OSCURO, 2.2),
            E(96, 58, 12, 12, BLANCO, GRIS_OSCURO, 2.0),
            E(96, 44, 8, 8, BLANCO, GRIS_OSCURO, 2.0),
        ] + _mano_indice(122, 34, -1, 0.4, (AZUL, AZUL_OSCURO)),
        "Bola y muñeco blanco como la nieve señalados para mostrar el blanco puro.")
    put("splash zone", "D",
        fondo_prado() + [
            E(78, 69, 40, 10, AGUA, AZUL_OSCURO, 2.2),
            L("M60 62 L46 44 M78 58 L78 38 M96 62 L110 44", AGUA_OSCURO, 2.4),
            R(60, 42, 11, 20, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(60, 56, 16, 7, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(82, 42, 11, 20, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(82, 56, 16, 7, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
        ] + _mano_indice(30, 48, 1, 0.3, (ROJO, ROJO_OSCURO)),
        "Zona marcada de charcos y botas salpicando señalada.")
    put("spot a bird", "D",
        fondo_cielo() + [
            R(42, 44, 18, 8, 2, NEGRO, GRIS_OSCURO, 1.8),
            E(58, 46, 5, 5, "#bae6fd", NEGRO, 1.6),
            L("M66 44 L96 32", ROJO_OSCURO, 1.8),
            E(112, 28, 9, 6, VERDE, VERDE_OSCURO, 1.8),
            P([(102, 26), (94, 22), (96, 30)], VERDE),
            P([(121, 27), (127, 29), (121, 31)], NARANJA),
        ],
        "Prismáticos apuntando para avistar un pájaro en vuelo.")
    put("steaming", "D",
        fondo_mesa() + [
            R(50, 46, 48, 24, 5, ROJO, ROJO_OSCURO, 2.2),
            R(46, 44, 56, 6, 2, GRIS, GRIS_OSCURO, 1.8),
            L("M62 40 Q56 30 62 20 M74 40 Q80 30 74 20 M86 40 Q80 30 86 20", BLANCO, 2.4),
        ] + _mano_indice(122, 32, -1, 0, (AZUL, AZUL_OSCURO)),
        "Olla caliente echando vapor visible señalado hacia arriba.")
    put("tank", "D",
        fondo_sala() + [
            R(44, 22, 60, 52, 4, "#e0f2fe", GRIS_OSCURO, 2.4),
            R(46, 40, 56, 32, 2, AGUA, AZUL_OSCURO, 1.4),
            L("M48 40 L100 40", AZUL_OSCURO, 2.0),
        ] + _mano_indice(126, 48, -1, 0, (ROJO, ROJO_OSCURO)),
        "Tanque transparente lleno de agua azul señalado.")
    put("target", "D",
        fondo_prado() + [
            E(78, 46, 28, 28, BLANCO, ROJO_OSCURO, 2.2),
            E(78, 46, 19, 19, ROJO, ROJO_OSCURO, 1.8),
            E(78, 46, 10, 10, BLANCO, ROJO_OSCURO, 1.6),
            E(78, 46, 4.5, 4.5, ROJO_OSCURO),
            L("M44 26 L76 45", MADERA_OSCURA, 2.6),
            P([(72, 46), (80, 47), (76, 40)], NEGRO),
        ],
        "Diana concéntrica roja y blanca con flecha apuntando al centro.")
    put("the left side is the same as the right side", "D",
        fondo_cielo() + [
            E(54, 42, 20, 18, NARANJA, NARANJA_OSCURO, 2.0),
            E(54, 58, 14, 12, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(102, 42, 20, 18, NARANJA, NARANJA_OSCURO, 2.0),
            E(102, 58, 14, 12, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(75, 24, 6, 46, 3, NEGRO),
            L("M78 16 L78 78", ROJO_OSCURO, 1.8),
        ],
        "Mariposa simétrica mostrando el lado izquierdo idéntico al lado derecho.")
    put("this flower has more petals than that one", "D",
        fondo_prado() + [
            L("M44 48 L44 74 M104 48 L104 74", VERDE_OSCURO, 2.8),
            E(44, 34, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.6),
            E(44, 22, 5, 6, BLANCO, GRIS_OSCURO, 1.4), E(56, 34, 6, 5, BLANCO, GRIS_OSCURO, 1.4),
            E(44, 46, 5, 6, BLANCO, GRIS_OSCURO, 1.4), E(32, 34, 6, 5, BLANCO, GRIS_OSCURO, 1.4),
            *[E(104 + 13 * math.cos(i * math.pi / 4), 34 + 13 * math.sin(i * math.pi / 4), 5.5, 5.5, ROSA, ROSA_OSCURO, 1.4) for i in range(8)],
            E(104, 34, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.6),
        ] + _mano_indice(132, 62, -1, -1, (AZUL, AZUL_OSCURO)),
        "Flor de ocho pétalos comparada con otra de cuatro señalando la que tiene más.")
    put("this one is longer", "D",
        fondo_mesa() + [
            R(28, 36, 38, 10, 2, AZUL, AZUL_OSCURO, 1.8),
            R(28, 56, 86, 10, 2, ROJO, ROJO_OSCURO, 2.0),
            P([(114, 56), (124, 61), (114, 66)], PEL, MADERA_OSCURA, 1.4),
        ] + _mano_indice(126, 34, -0.5, 1, (VERDE, VERDE_OSCURO)),
        "Lápiz rojo mucho más largo comparado con uno corto y señalado.")
    put("timeline", "D",
        fondo_sala() + [
            L("M24 52 L132 52", GRIS_OSCURO, 3.0),
            P([(126, 46), (138, 52), (126, 58)], GRIS_OSCURO),
            E(38, 52, 6, 6, "#bae6fd", AZUL_OSCURO, 2.0),
            E(78, 52, 6, 6, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(114, 52, 6, 6, VERDE, VERDE_OSCURO, 2.0),
            E(38, 32, 6, 6, PEL, PELB, 1.6),
            E(78, 30, 8, 8, PEL, PELB, 1.6),
            E(114, 28, 10, 10, PEL, PELB, 1.6),
        ],
        "Línea del tiempo de izquierda a derecha mostrando etapas sin texto ni cifras.")
    put("top and bottom", "D",
        fondo_sala() + [
            E(78, 48, 28, 20, ROSA_OSCURO, NEGRO, 2.2),
            R(58, 34, 40, 8, 2, BLANCO, GRIS_OSCURO, 1.6),
            R(58, 54, 40, 8, 2, BLANCO, GRIS_OSCURO, 1.6),
        ] + _frecha(42, 46, 42, 32, AZUL_OSCURO, 2.4) + _frecha(114, 48, 114, 64, ROJO_OSCURO, 2.4),
        "Boca abierta con flechas señalando la fila superior e inferior de dientes.")
    put("treetop", "D",
        fondo_prado() + [
            R(72, 48, 12, 32, 2, MADERA, MADERA_OSCURA, 2.0),
            E(78, 36, 26, 20, VERDE, VERDE_OSCURO, 2.0),
            E(78, 24, 18, 13, "#4ade80", VERDE_OSCURO, 2.2),
        ] + _mano_indice(118, 28, -1, 0, (ROJO, ROJO_OSCURO)),
        "Árbol frondoso señalando claramente la punta alta de su copa.")
    put("uncle", "D",
        fondo_sala() + [
            R(52, 16, 52, 58, 4, MADERA, MADERA_OSCURA, 2.6),
            R(58, 22, 40, 46, 2, "#dcfce7", VERDE_OSCURO, 1.4),
            R(68, 52, 20, 16, 4, VERDE, VERDE_OSCURO, 1.6),
            E(78, 39, 10, 10, PEL, PELB, 1.8),
            F("M68 37 C68 27 88 27 88 37 Z", BARRO),
            E(74, 38, 1.2, 1.4, TINTA), E(82, 38, 1.2, 1.4, TINTA),
            L("M74 43 L82 43", BARRO, 2.0),
        ] + _mano_indice(122, 46, -1, 0, (AZUL, AZUL_OSCURO)),
        "Cuadro enmarcado de un tío sonriente con bigote señalado.")
    put("up in the air", "D",
        fondo_cielo() + pompas([(58, 28, 8), (82, 22, 10), (104, 34, 7)])
        + _mano_indice(46, 64, 1, -1, (ROJO, ROJO_OSCURO)),
        "Burbujas flotando arriba en el aire señaladas desde abajo.")
    put("washbasin", "D",
        fondo_sala() + [
            R(58, 12, 40, 26, 3, "#e0f2fe", GRIS_OSCURO, 2.0),
            F("M44 46 L112 46 L102 64 L54 64 Z", BLANCO, GRIS_OSCURO, 2.2),
            R(74, 64, 8, 16, 1, "#cbd5e1", GRIS_OSCURO, 1.8),
            L("M78 46 L78 39 Q78 35 72 35", GRIS_OSCURO, 3.0),
        ] + _mano_indice(128, 54, -1, 0, (AZUL, AZUL_OSCURO)),
        "Lavabo blanco con grifo y espejo en la pared señalado.")
    put("we smell with our nose and taste with our tongue", "D",
        fondo_sala() + [
            E(54, 46, 15, 15, PEL, PELB, 2.0),
            E(49, 41, 1.5, 1.8, TINTA), E(59, 41, 1.5, 1.8, TINTA),
            L("M54 44 L54 49", PELB, 2.0),
            L("M28 54 L28 70", VERDE_OSCURO, 2.2),
            E(24, 48, 4.5, 4.5, ROSA, ROSA_OSCURO, 1.2), E(32, 48, 4.5, 4.5, ROSA, ROSA_OSCURO, 1.2),
            E(28, 44, 4.5, 4.5, ROSA, ROSA_OSCURO, 1.2), E(28, 52, 4.5, 4.5, ROSA, ROSA_OSCURO, 1.2),
            E(28, 48, 3.5, 3.5, AMARILLO),
            E(104, 46, 15, 15, PEL, PELB, 2.0),
            E(99, 41, 1.5, 1.8, TINTA), E(109, 41, 1.5, 1.8, TINTA),
            F("M100 52 C100 60 108 60 108 52 Z", ROSA, ROSA_OSCURO, 1.5),
            P([(124, 48), (132, 48), (128, 58)], ROJO, ROJO_OSCURO, 1.5),
            P([(124, 48), (128, 44), (132, 48)], VERDE, VERDE_OSCURO, 1.2),
        ],
        "Escena doble: oler una flor con la nariz y saborear una fresa con la lengua.")
    put("weather", "D",
        fondo_cielo() + [
            _sol(42, 32, 11)[0],
            E(84, 34, 14, 9, NUBE, NUBE_B, 1.8),
            E(96, 36, 11, 8, NUBE, NUBE_B, 1.8),
        ] + gotas([(82, 48), (94, 50)]) + lineas_viento(106, 40, 24) + _mano_indice(52, 66, 0.5, -1, (ROJO, ROJO_OSCURO)),
        "Cielo mostrando el tiempo atmosférico (sol, lluvia y viento) señalado.")
    put("weather station", "D",
        fondo_prado() + [
            L("M78 24 L78 76", MADERA_OSCURA, 3.4),
            L("M60 32 L96 32", GRIS_OSCURO, 2.4),
            E(60, 32, 5, 5, ROJO, ROJO_OSCURO, 1.6),
            E(96, 32, 5, 5, AZUL, AZUL_OSCURO, 1.6),
            R(66, 48, 12, 18, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            P([(74, 18), (86, 22), (74, 26)], AMARILLO, AMARILLO_OSCURO, 1.6),
        ] + _mano_indice(122, 46, -1, 0, (VERDE, VERDE_OSCURO)),
        "Estación meteorológica escolar con veleta, cazoletas y pluviómetro señalada.")
    put("yellow", "D",
        fondo_mesa() + [
            E(46, 54, 12, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(70, 44, 20, 22, 4, "#fde047", AMARILLO_OSCURO, 2.0),
            E(112, 54, 12, 12, "#facc15", AMARILLO_OSCURO, 2.0),
        ] + _mano_indice(80, 22, 0, 1, (AZUL, AZUL_OSCURO)),
        "Objetos de color amarillo vivo señalados sobre la mesa.")

    # ── look (cierre: 60 escenas + 2 directas = 62) ─────────────────────────
    put("belly button", "D",
        fondo_sala() + [
            R(56, 24, 44, 22, 4, AZUL, AZUL_OSCURO, 2.0),
            R(56, 44, 44, 24, 4, PEL, PELB, 2.0),
            E(78, 56, 2.5, 2.5, PELB, MADERA_OSCURA, 1.4),
        ] + _mano_indice(118, 56, -1, 0, (ROJO, ROJO_OSCURO)),
        "Camiseta subida dejando visible el ombligo en la barriga señalado.")
    put("blindfold", "D",
        fondo_sala() + [
            E(78, 48, 22, 22, PEL, PELB, 2.2),
            F("M56 44 C56 20 100 20 100 44 Z", BARRO),
            R(55, 38, 46, 14, 4, MORADO, "#5b21b6", 2.0),
            L("M66 60 Q78 65 90 60", "#9a3412", 1.6),
        ],
        "Rostro infantil con una venda de tela morada cubriendo los ojos.")
    put("busy street", "D",
        fondo_cielo() + [
            R(0, 56, 156, 32, 0, GRIS, GRIS_OSCURO, 1.4),
            L("M14 70 L34 70 M54 70 L74 70 M94 70 L114 70 M134 70 L150 70", BLANCO, 2.2),
            R(24, 44, 28, 16, 4, ROJO, ROJO_OSCURO, 1.8),
            E(30, 60, 4, 4, NEGRO), E(46, 60, 4, 4, NEGRO),
            R(98, 44, 28, 16, 4, AZUL, AZUL_OSCURO, 1.8),
            E(104, 60, 4, 4, NEGRO), E(120, 60, 4, 4, NEGRO),
        ] + _nino_pie(74, 26, (VERDE, VERDE_OSCURO), 1),
        "Calle con tráfico de coches y peatones mirando a ambos lados.")
    put("calm jar", "D",
        fondo_mesa() + [
            R(56, 24, 44, 52, 6, "#e0f2fe", AZUL_OSCURO, 2.2),
            R(62, 16, 32, 8, 2, MORADO, "#5b21b6", 2.0),
            F("M60 64 Q78 58 96 64 L96 74 L60 74 Z", AGUA),
            E(68, 42, 2.5, 2.5, AMARILLO), E(84, 50, 2.5, 2.5, ROSA),
            E(76, 60, 2.5, 2.5, AMARILLO), E(88, 66, 2.5, 2.5, MORADO),
        ],
        "Frasco transparente de la calma con agua azul y brillos reposando al fondo.")
    put("choose fruit", "D",
        fondo_mesa() + [
            F("M44 54 C44 74 112 74 112 54 Z", MADERA, MADERA_OSCURA, 2.2),
            E(60, 50, 9, 9, ROJO, ROJO_OSCURO, 1.6),
            F("M72 48 Q80 34 90 48", AMARILLO, AMARILLO_OSCURO, 2.4),
            E(96, 50, 8, 8, NARANJA, NARANJA_OSCURO, 1.6),
        ] + _mano_indice(60, 24, 0, 1, (VERDE, VERDE_OSCURO)),
        "Frutero variado mientras la mano elige la manzana roja.")
    put("colour hunt", "D",
        fondo_prado() + [
            E(44, 58, 12, 8, VERDE, VERDE_OSCURO, 1.8),
            F("M92 58 Q106 42 118 56 Q106 66 92 58 Z", "#4ade80", VERDE_OSCURO, 1.8),
        ] + _lupa(98, 48, 16),
        "Lupa buscando objetos de color verde por el prado.")
    put("crystal-clear", "D",
        fondo_mar() + [
            R(36, 24, 84, 52, 6, "#e0f2fe", AGUA_OSCURO, 2.2),
            E(56, 62, 7, 5, GRIS, GRIS_OSCURO, 1.6),
            E(78, 64, 8, 5, TIERRA_CLARA, BARRO, 1.6),
            E(100, 62, 6, 4, AMARILLO, AMARILLO_OSCURO, 1.6),
            L("M48 34 L62 34 M88 38 L104 38", BLANCO, 2.0),
        ],
        "Agua cristalina y transparente que deja ver con nitidez las piedras del fondo.")
    put("dark", "D",
        [R(0, 0, 156, 88, 0, "#0f172a")] + [
            E(78, 44, 18, 18, "#1e293b", "#334155", 1.8),
            E(72, 42, 3, 3, "#fde047"),
            E(84, 42, 3, 3, "#fde047"),
        ],
        "Oscuridad profunda nocturna donde apenas asoman unos ojos en la sombra.")
    put("dazzling", "D",
        fondo_cielo() + [
            _sol(118, 22, 14)[0],
            L("M102 26 L62 40 M104 34 L66 52 M110 40 L78 58", "#fde047", 2.6),
        ] + nino_busto(48, 50, (ROJO, ROJO_OSCURO), ojos="cerrados") + [
            L("M34 58 L42 42 L60 40", PELB, 5.0),
            L("M34 58 L42 42 L60 40", PEL, 2.8),
        ],
        "Luz deslumbrante del sol frente al niño que se tapa los ojos con la mano.")
    put("dirty", "D",
        fondo_sala() + [
            E(56, 48, 13, 14, PEL, PELB, 2.0),
            E(100, 48, 13, 14, PEL, PELB, 2.0),
            E(54, 48, 7, 7, BARRO), E(62, 42, 4, 4, TIERRA),
            E(98, 50, 8, 6, BARRO), E(104, 42, 4, 4, TIERRA),
        ],
        "Dos manos con manchas oscuras de barro mostrando suciedad.")
    put("dolphin watching", "D",
        fondo_mar() + [
            F("M88 56 Q102 32 122 48 Q112 52 104 58 Z", AZUL, AZUL_OSCURO, 2.2),
            R(32, 42, 20, 9, 2, NEGRO, GRIS_OSCURO, 1.8),
            E(50, 46, 5, 5, "#bae6fd", NEGRO, 1.6),
        ],
        "Prismáticos observando un delfín saltar sobre el mar.")
    put("drop a stone", "D",
        fondo_mar() + [
            E(78, 44, 7, 6, GRIS, GRIS_OSCURO, 1.8),
            E(78, 66, 16, 5, None, BLANCO, 1.8),
        ] + _frecha(78, 28, 78, 54, ROJO_OSCURO, 2.2),
        "Piedra cayendo verticalmente hacia el agua creando ondas al caer.")
    put("experiment", "D",
        fondo_mesa() + [
            R(50, 26, 16, 40, 6, "#bae6fd", GRIS_OSCURO, 2.0),
            R(52, 44, 12, 20, 3, VERDE),
            R(86, 26, 16, 40, 6, "#fde68a", GRIS_OSCURO, 2.0),
            R(88, 44, 12, 20, 3, ROSA),
            E(58, 20, 3, 3, AGUA), E(94, 18, 3, 3, ROSA),
        ] + _lupa(114, 48, 12),
        "Probetas con líquidos de colores burbujeantes examinadas con lupa.")
    put("explore new places", "D",
        fondo_prado() + [
            P([(28, 32), (56, 24), (84, 32), (84, 66), (56, 58), (28, 66)], "#fef3c7", MADERA_OSCURA, 2.0),
            L("M38 56 Q56 38 74 48", ROJO_OSCURO, 2.0),
            P([(98, 56), (118, 28), (138, 56)], TIERRA_CLARA, BARRO, 1.8),
        ],
        "Mapa desplegado frente a senderos y montañas por explorar.")
    put("eye to eye", "D",
        fondo_sala() + _nino_pie(48, 36, (AZUL, AZUL_OSCURO), 1)
        + bebe(108, 42) + [L("M60 40 L94 40", ROJO_OSCURO, 2.0)],
        "Adulto a la misma altura mirando frente a frente a los ojos del bebé.")
    put("float or sink", "D",
        fondo_mar() + [
            R(34, 20, 88, 56, 4, "#e0f2fe", AGUA_OSCURO, 2.2),
            R(36, 42, 84, 32, 2, AGUA),
            R(48, 34, 22, 9, 3, MADERA, MADERA_OSCURA, 1.8),
            E(100, 66, 9, 7, GRIS, GRIS_OSCURO, 1.8),
        ],
        "Cubeta de agua con corcho flotando arriba y piedra hundida en el fondo.")
    put("look", "D",
        fondo_sala() + nino_busto(78, 44, (AZUL, AZUL_OSCURO), r=11, mira=0) + [
            E(72, 44, 5.2, 5.2, None, PELB, 3.0),
            E(84, 44, 5.2, 5.2, None, PELB, 3.0),
            E(72, 44, 5.2, 5.2, None, PEL, 1.4),
            E(84, 44, 5.2, 5.2, None, PEL, 1.4),
            L("M66 48 L62 60 M90 48 L94 60", PELB, 4.4),
            L("M66 48 L62 60 M90 48 L94 60", PEL, 2.4),
        ],
        "Niño formando gafas con sus manos sobre los ojos mirando atento.")
    put("look back", "D",
        fondo_prado() + _nino_pie(92, 34, (ROJO, ROJO_OSCURO), -1) + [
            P([(28, 48), (44, 32), (60, 48)], ROJO, ROJO_OSCURO, 1.6),
            L("M82 38 L58 38", AZUL_OSCURO, 2.2),
            P([(62, 34), (52, 38), (62, 42)], AZUL_OSCURO),
        ],
        "Niño volviendo la cabeza para mirar hacia atrás al camino recorrido.")
    put("look for patterns", "D",
        fondo_mesa() + [
            E(34, 48, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            R(50, 39, 18, 18, 2, AZUL, AZUL_OSCURO, 1.8),
            E(84, 48, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            R(100, 39, 18, 18, 2, AZUL, AZUL_OSCURO, 1.8),
        ] + _lupa(84, 48, 15),
        "Lupa inspeccionando una serie repetida de círculo rojo y cuadrado azul.")
    put("look into the distance", "D",
        fondo_prado() + [
            P([(94, 58), (118, 30), (144, 58)], GRIS, GRIS_OSCURO, 1.8),
        ] + _nino_pie(44, 36, (VERDE, VERDE_OSCURO), 1) + [
            R(44, 32, 12, 4, 1, PEL, PELB, 1.4),
        ],
        "Niño con la mano sobre la frente mirando lejos hacia las montañas.")
    put("look left, look right", "D",
        fondo_sala() + [
            R(0, 66, 156, 22, 0, GRIS),
            R(44, 68, 16, 16, 1, BLANCO), R(70, 68, 16, 16, 1, BLANCO), R(96, 68, 16, 16, 1, BLANCO),
        ] + _nino_pie(78, 26, (AMARILLO, AMARILLO_OSCURO), 1)
        + _frecha(62, 30, 34, 30, ROJO_OSCURO, 2.4) + _frecha(94, 30, 122, 30, ROJO_OSCURO, 2.4),
        "Niño antes del paso de cebra mirando a izquierda y derecha.")
    put("look out of the window", "D",
        fondo_sala() + [
            R(36, 16, 84, 54, 4, "#bae6fd", MADERA_OSCURA, 2.8),
            F("M38 56 Q62 42 86 52 Q102 46 118 54 L118 68 L38 68 Z", HERBA),
            E(96, 28, 7, 7, "#fde047", AMARILLO_OSCURO, 1.5),
            E(60, 44, 8, 8, PEL, PELB, 1.8),
            L("M78 18 L78 68", MADERA_OSCURA, 2.2),
        ],
        "Ventana encuadrando al niño mirando fuera hacia el paisaje exterior.")
    put("look through", "D",
        fondo_sala() + [
            R(48, 34, 64, 24, 8, MADERA, MADERA_OSCURA, 2.2),
            E(112, 46, 8, 12, "#0f172a", MADERA_OSCURA, 2.0),
            E(112, 46, 5, 8, "#bae6fd"),
        ] + _ojo(30, 46, 1.2),
        "Ojo asomado mirando a través de un tubo hueco.")
    put("look under the log", "D",
        fondo_prado() + [
            R(38, 44, 72, 18, 6, BARRO, MADERA_OSCURA, 2.2),
            E(64, 68, 5, 4, ROJO, NEGRO, 1.4),
            E(88, 68, 6, 4, MORADO, NEGRO, 1.4),
        ] + _frecha(44, 56, 44, 32, AZUL_OSCURO, 2.4),
        "Tronco ligeramente levantado para mirar los bichitos que viven debajo.")
    put("look up", "D",
        fondo_cielo() + _sol(108, 22, 11) + _nino_pie(58, 38, (AZUL, AZUL_OSCURO), 1)
        + _frecha(62, 34, 86, 14, ROJO_OSCURO, 2.4),
        "Niño levantando la cabeza para mirar arriba hacia el cielo.")
    put("lost", "D",
        fondo_prado() + [
            P([(68, 86), (88, 86), (84, 70), (122, 60), (114, 56), (78, 66), (42, 56), (34, 60), (72, 70)], TIERRA_CLARA),
            L("M44 40 L44 64", MADERA_OSCURA, 2.6),
            P([(30, 42), (44, 42), (44, 50), (30, 50), (24, 46)], AMARILLO, AMARILLO_OSCURO, 1.4),
            P([(44, 42), (58, 42), (64, 46), (58, 50), (44, 50)], ROJO, ROJO_OSCURO, 1.4),
        ] + _nino_pie(84, 30, (MORADO, "#5b21b6"), 1),
        "Niño detenido en un cruce de caminos buscando la dirección correcta.")
    put("masked", "D",
        fondo_sala() + [
            E(78, 48, 22, 22, PEL, PELB, 2.2),
            F("M54 44 C54 20 102 20 102 44 Z", BARRO),
            R(56, 38, 44, 14, 6, ROJO, ROJO_OSCURO, 2.0),
            E(69, 45, 5, 4, BLANCO), E(87, 45, 5, 4, BLANCO),
            E(69, 45, 2, 2, NEGRO), E(87, 45, 2, 2, NEGRO),
            L("M70 60 Q78 65 86 60", "#9a3412", 1.6),
        ],
        "Persona con antifaz de colores cubriendo los ojos en juego de disfraz.")
    put("mirror check", "D",
        fondo_sala() + [
            E(78, 44, 24, 32, "#e0f2fe", MADERA_OSCURA, 3.0),
            E(78, 42, 10, 10, PEL, PELB, 1.8),
            R(68, 52, 20, 16, 4, AZUL, AZUL_OSCURO, 1.6),
            L("M64 26 L70 20 M86 24 L92 18", BLANCO, 1.8),
        ],
        "Espejo ovalado donde se refleja el rostro para mirarse.")
    put("murky", "D",
        fondo_mesa() + [
            R(36, 24, 84, 52, 6, "#a8a29e", "#57534e", 2.2),
            R(38, 32, 80, 42, 4, "#78716c"),
            E(80, 52, 12, 6, "#57534e"),
            P([(92, 52), (100, 47), (100, 57)], "#57534e"),
            L("M46 42 Q64 36 82 42 M68 62 Q86 56 106 62", "#57534e", 2.2),
            E(58, 50, 7, 4, "#a16207"), E(94, 42, 6, 3, "#a16207"),
        ],
        "Agua turbia cargada de sedimentos donde apenas se distingue el pez al fondo.")
    put("nails", "D",
        fondo_sala() + [
            R(54, 48, 48, 30, 10, PEL, PELB, 2.0),
            R(54, 28, 9, 24, 4, PEL, PELB, 1.8),
            R(66, 22, 9, 30, 4, PEL, PELB, 1.8),
            R(79, 20, 9, 32, 4, PEL, PELB, 1.8),
            R(92, 24, 9, 28, 4, PEL, PELB, 1.8),
            R(55.5, 29.5, 6, 5, 2, "#fbcfe8", ROSA_OSCURO, 1.2),
            R(67.5, 23.5, 6, 5, 2, "#fbcfe8", ROSA_OSCURO, 1.2),
            R(80.5, 21.5, 6, 5, 2, "#fbcfe8", ROSA_OSCURO, 1.2),
            R(93.5, 25.5, 6, 5, 2, "#fbcfe8", ROSA_OSCURO, 1.2),
        ],
        "Mano abierta mostrando las uñas de los dedos limpias y resaltadas.")
    put("observation", "D",
        fondo_prado() + [
            F("M44 58 Q66 38 88 54 Q66 68 44 58 Z", VERDE, VERDE_OSCURO, 1.8),
            E(66, 52, 6, 5, ROJO, NEGRO, 1.6),
            E(64, 51, 1.2, 1.2, NEGRO), E(68, 53, 1.2, 1.2, NEGRO),
        ] + _lupa(66, 50, 18),
        "Lupa observando con detalle una mariquita roja sobre la hoja.")
    put("observe", "D",
        fondo_prado() + [
            E(112, 42, 7, 10, ROSA, ROSA_OSCURO, 1.6),
            E(122, 42, 7, 10, ROSA, ROSA_OSCURO, 1.6),
            L("M117 34 L117 50", NEGRO, 2.0),
        ] + _nino_pie(50, 34, (VERDE, VERDE_OSCURO), 1),
        "Niño quieto observando con atención una mariposa sin tocarla.")
    put("peer", "D",
        fondo_prado() + [
            E(42, 48, 22, 26, VERDE, VERDE_OSCURO, 2.0),
            E(114, 48, 22, 26, VERDE, VERDE_OSCURO, 2.0),
            E(78, 44, 15, 15, PEL, PELB, 2.0),
            E(73, 43, 2, 2.4, TINTA), E(83, 43, 2, 2.4, TINTA),
            L("M74 50 Q78 53 82 50", "#9a3412", 1.5),
        ],
        "Niño asomándose curioso entre las hojas verdes del arbusto.")
    put("photo wall", "D",
        fondo_sala() + [
            R(28, 16, 100, 62, 4, "#fde68a", MADERA_OSCURA, 2.4),
            R(36, 24, 24, 20, 2, BLANCO, ROJO_OSCURO, 1.8),
            E(48, 32, 5, 5, "#fde047"),
            R(66, 24, 24, 20, 2, BLANCO, AZUL_OSCURO, 1.8),
            E(78, 34, 6, 4, VERDE),
            R(96, 24, 24, 20, 2, BLANCO, VERDE_OSCURO, 1.8),
            E(108, 32, 5, 5, ROSA),
            R(50, 50, 24, 20, 2, BLANCO, AMARILLO_OSCURO, 1.8),
            R(82, 50, 24, 20, 2, BLANCO, MORADO, 1.8),
        ],
        "Mural en el aula lleno de fotografías enmarcadas para buscar.")
    put("pop out from behind", "D",
        fondo_prado() + [
            E(66, 56, 26, 20, VERDE, VERDE_OSCURO, 2.2),
            E(96, 38, 12, 12, NARANJA, NARANJA_OSCURO, 2.0),
            P([(87, 30), (92, 18), (96, 28)], NARANJA, NARANJA_OSCURO, 1.6),
            P([(96, 28), (102, 18), (105, 30)], NARANJA, NARANJA_OSCURO, 1.6),
            E(93, 38, 1.6, 2.0, NEGRO), E(101, 38, 1.6, 2.0, NEGRO),
        ] + _frecha(76, 44, 92, 36, ROJO_OSCURO, 2.2),
        "Zorrito apareciendo de repente por detrás de un arbusto verde.")
    put("pop-up toy", "D",
        fondo_mesa() + [
            R(56, 46, 44, 30, 4, ROJO, ROJO_OSCURO, 2.2),
            R(66, 54, 24, 14, 3, AMARILLO, AMARILLO_OSCURO, 1.6),
            L("M78 46 L72 38 L84 32 L74 26", GRIS_OSCURO, 2.4),
            E(78, 22, 11, 11, VERDE, VERDE_OSCURO, 2.0),
            E(74, 21, 1.6, 1.8, NEGRO), E(82, 21, 1.6, 1.8, NEGRO),
            L("M74 26 Q78 29 82 26", ROJO_OSCURO, 1.5),
        ],
        "Caja sorpresa con muñeco de muelle saltando al pulsar el botón.")
    put("prism", "D",
        fondo_sala() + [
            P([(56, 68), (78, 26), (100, 68)], "#e0f2fe", AZUL_OSCURO, 2.4),
            L("M24 44 L66 44", "#fde047", 2.8),
            L("M89 44 L132 34", ROJO, 2.4),
            L("M89 48 L132 48", VERDE, 2.4),
            L("M89 52 L132 62", AZUL, 2.4),
        ],
        "Prisma triangular de cristal dividiendo la luz blanca en haz multicolor.")
    put("rock pool", "D",
        fondo_prado() + [
            E(78, 56, 44, 18, GRIS, GRIS_OSCURO, 2.4),
            E(78, 56, 32, 12, AGUA, AZUL_OSCURO, 1.8),
            E(88, 56, 6, 4, ROJO, ROJO_OSCURO, 1.4),
        ] + _estrella(66, 56, 6, NARANJA, NARANJA_OSCURO, 1.4),
        "Charca natural entre rocas costeras con estrella de mar y cangrejo dentro.")
    put("sail across the ocean", "D",
        fondo_mar() + [
            F("M54 58 L102 58 L94 70 L62 70 Z", MADERA, MADERA_OSCURA, 2.2),
            L("M78 22 L78 58", MADERA_OSCURA, 2.6),
            P([(78, 24), (78, 54), (102, 54)], BLANCO, GRIS_OSCURO, 2.0),
        ] + _frecha(106, 42, 134, 42, ROJO_OSCURO, 2.2),
        "Velero navegando a través del océano abierto hacia adelante.")
    put("savour", "D",
        fondo_mesa() + nino_busto(78, 48, (AMARILLO, AMARILLO_OSCURO), ojos="cerrados") + [
            E(104, 52, 7, 7, ROJO, ROJO_OSCURO, 1.6),
            L("M96 42 Q100 34 106 38", ROSA_OSCURO, 1.8),
        ],
        "Niño con ojos cerrados disfrutando y saboreando despacio su bocado.")
    put("search", "D",
        fondo_prado() + [
            F("M44 66 Q56 46 72 56 Q62 72 44 66 Z", NARANJA, NARANJA_OSCURO, 2.0),
            F("M74 66 Q90 48 104 60 Q92 72 74 66 Z", AMARILLO, AMARILLO_OSCURO, 2.0),
        ] + _lupa(76, 48, 16),
        "Lupa levantando y buscando bajo las hojas caídas.")
    put("search for treasure", "D",
        fondo_mar() + [
            R(84, 46, 36, 24, 3, MADERA, MADERA_OSCURA, 2.2),
            R(84, 46, 36, 8, 2, DORADO, MADERA_OSCURA, 1.8),
            L("M24 38 L58 32", NARANJA_OSCURO, 5.0),
            L("M24 38 L58 32", AMARILLO, 3.0),
        ],
        "Catalejo mirando hacia el cofre del tesoro dorado en la playa.")
    put("see-through", "D",
        fondo_sala() + [
            E(96, 52, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            R(50, 26, 44, 48, 5, "#e0f2fe", AGUA_OSCURO, 2.4),
            L("M58 34 L70 34 M62 42 L68 42", BLANCO, 2.0),
        ],
        "Lámina de vidrio transparente delante de una pelota roja perfectamente visible.")
    put("seed bag", "D",
        fondo_mesa() + [
            R(56, 28, 44, 48, 4, TIERRA_CLARA, MADERA_OSCURA, 2.2),
            E(78, 48, 8, 8, VERDE, VERDE_OSCURO, 1.6),
            E(52, 72, 3.5, 2.5, BARRO),
            E(62, 74, 3.5, 2.5, BARRO),
            E(44, 74, 3.5, 2.5, BARRO),
        ],
        "Bolsita de papel con semillas oscuras asomando junto a la base.")
    put("seek", "D",
        fondo_prado() + [
            R(64, 18, 28, 62, 4, MADERA, MADERA_OSCURA, 2.2),
            E(78, 18, 30, 16, VERDE, VERDE_OSCURO, 2.0),
        ] + _nino_pie(46, 38, (AZUL, AZUL_OSCURO), 1) + _nino_pie(110, 42, (ROJO, ROJO_OSCURO), -1),
        "Niño buscando alrededor detrás de un tronco grueso al escondite.")
    put("shade your eyes", "D",
        fondo_cielo() + _sol(116, 22, 13) + nino_busto(64, 52, (VERDE, VERDE_OSCURO)) + [
            L("M74 62 L84 48 L74 44 L66 44", PELB, 5.0),
            L("M74 62 L84 48 L74 44 L66 44", PEL, 2.8),
        ],
        "Niño llevando la mano horizontal sobre las cejas para taparse del sol.")
    put("shop window", "D",
        fondo_sala() + [
            R(30, 20, 96, 56, 4, "#e0f2fe", MADERA_OSCURA, 2.8),
            E(56, 54, 10, 10, ROJO, ROJO_OSCURO, 1.8),
            R(76, 46, 20, 18, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(112, 44, 7, 16, VERDE, VERDE_OSCURO, 1.8),
        ] + _nino_pie(22, 44, (AZUL, AZUL_OSCURO), 1),
        "Escaparate acristalado de tienda con juguetes expuestos mientras el niño mira.")
    put("shy", "D",
        fondo_sala() + [
            E(78, 48, 20, 20, PEL, PELB, 2.2),
            F("M58 44 C58 22 98 22 98 44 Z", BARRO),
            E(67, 46, 2, 2.4, TINTA), E(89, 46, 2, 2.4, TINTA),
            E(63, 54, 4, 2.5, "#fda4af"), E(93, 54, 4, 2.5, "#fda4af"),
            R(58, 50, 14, 22, 5, PEL, PELB, 1.8),
            R(84, 50, 14, 22, 5, PEL, PELB, 1.8),
        ],
        "Niño tímido tapando parte de la cara con las manos con mejillas sonrojadas.")
    put("smile", "D",
        fondo_sala() + [
            E(78, 48, 22, 22, PEL, PELB, 2.2),
            F("M56 42 C56 20 100 20 100 42 Z", BARRO),
            E(70, 44, 2.2, 2.6, TINTA), E(86, 44, 2.2, 2.6, TINTA),
            E(64, 51, 3.5, 2.2, "#fda4af"), E(92, 51, 3.5, 2.2, "#fda4af"),
            L("M66 53 Q78 66 90 53", "#9a3412", 2.4),
        ],
        "Rostro infantil con sonrisa amplia y alegre.")
    put("snore", "D",
        fondo_noite() + [
            R(34, 48, 88, 26, 5, AZUL, AZUL_OSCURO, 2.2),
            R(38, 40, 24, 12, 4, BLANCO, GRIS_OSCURO, 1.8),
            R(62, 48, 56, 18, 4, "#bae6fd", AZUL_OSCURO, 1.8),
        ] + cara_dormida(50, 38, 12, False) + [
            E(50, 43, 3, 2.5, "#9a3412"),
            L("M64 28 Q70 22 76 28 Q82 34 88 28", BLANCO, 2.0),
        ],
        "Niño dormido con boca entreabierta y ondas suaves de ronquido nocturno.")
    put("sour", "D",
        fondo_mesa() + [
            E(78, 48, 24, 18, "#fde047", AMARILLO_OSCURO, 2.2),
            L("M64 42 L72 46 L64 50 M92 42 L84 46 L92 50", TINTA, 2.0),
            L("M70 56 Q74 53 78 56 Q82 59 86 56", "#9a3412", 1.8),
        ],
        "Limón amarillo con gesto fruncido de sabor muy ácido.")
    put("starry night", "D",
        fondo_noite() + [
            F("M116 16 C100 18 100 42 116 44 C107 38 107 22 116 16 Z", "#fde047", AMARILLO_OSCURO, 1.4),
        ] + _estrella(38, 24, 6) + _estrella(66, 18, 5) + _estrella(90, 30, 7) + _estrella(52, 40, 4) + _estrella(124, 42, 5) + [
            F("M0 72 Q50 58 96 68 Q126 62 156 70 L156 88 L0 88 Z", "#1e293b"),
        ],
        "Cielo azul oscuro nocturno colmado de estrellas doradas y luna sobre las colinas.")
    put("switch on", "D",
        fondo_sala() + [
            R(36, 30, 34, 40, 4, BLANCO, GRIS_OSCURO, 2.2),
            R(47, 40, 12, 20, 2, VERDE, VERDE_OSCURO, 1.8),
            E(106, 40, 16, 16, "#fde047", AMARILLO_OSCURO, 2.2),
            R(100, 54, 12, 8, 2, GRIS, GRIS_OSCURO, 1.8),
            L("M84 40 L76 40 M128 40 L136 40 M106 16 L106 22 M90 24 L95 29 M122 24 L117 29", AMARILLO_OSCURO, 2.2),
        ],
        "Interruptor activado en verde junto a bombilla amarilla recién encendida.")
    put("tall buildings", "D",
        fondo_cielo() + [
            R(26, 26, 28, 56, 2, AZUL, AZUL_OSCURO, 2.0),
            R(62, 12, 32, 70, 2, ROJO, ROJO_OSCURO, 2.0),
            R(102, 20, 28, 62, 2, VERDE, VERDE_OSCURO, 2.0),
            R(34, 34, 12, 8, 1, "#fde047"), R(34, 50, 12, 8, 1, "#fde047"),
            R(70, 22, 16, 8, 1, "#fde047"), R(70, 38, 16, 8, 1, "#fde047"), R(70, 54, 16, 8, 1, "#fde047"),
            R(110, 30, 12, 8, 1, "#fde047"), R(110, 46, 12, 8, 1, "#fde047"),
        ],
        "Edificios altos de varias plantas recortados hacia arriba en la ciudad.")
    put("tube", "D",
        fondo_mesa() + [
            P([(40, 34), (114, 34), (114, 62), (40, 62)], TIERRA_CLARA, MADERA_OSCURA, 2.2),
            E(40, 48, 8, 14, TIERRA_CLARA, MADERA_OSCURA, 2.2),
            E(40, 48, 4.5, 9, "#1e293b"),
            E(114, 48, 8, 14, "#475569", MADERA_OSCURA, 2.2),
            E(114, 48, 4.5, 9, "#bae6fd"),
        ],
        "Tubo cilíndrico hueco de cartón abierto por los dos extremos.")
    put("under the stone", "D",
        fondo_prado() + [
            E(78, 46, 32, 14, GRIS, GRIS_OSCURO, 2.2),
            E(72, 68, 5, 4, NEGRO),
            E(88, 68, 6, 4, BARRO),
        ] + _frecha(44, 56, 44, 32, AZUL_OSCURO, 2.4),
        "Piedra plana levantada por un borde revelando los bichitos debajo.")
    put("viewpoint", "D",
        fondo_cielo() + [
            F("M0 70 Q54 44 106 60 Q130 50 156 64 L156 88 L0 88 Z", HERBA, VERDE_OSCURO, 1.8),
            R(26, 62, 104, 5, 2, MADERA, MADERA_OSCURA, 1.8),
            L("M36 62 L36 82 M78 62 L78 82 M120 62 L120 82", MADERA_OSCURA, 3.2),
            L("M94 58 L94 42", GRIS_OSCURO, 3.0),
            R(86, 38, 18, 6, 2, NEGRO, GRIS_OSCURO, 1.6),
        ],
        "Mirador con barandilla y visor panorámico dominando el valle.")
    put("wait for", "D",
        fondo_sala() + [
            E(108, 30, 14, 14, BLANCO, GRIS_OSCURO, 2.2),
            L("M108 30 L108 21 M108 30 L115 30", ROJO_OSCURO, 2.0),
            R(36, 60, 44, 16, 3, MADERA, MADERA_OSCURA, 2.0),
        ] + nino_busto(58, 44, (AZUL, AZUL_OSCURO)),
        "Niño sentado esperando tranquilo mientras mira la hora en el reloj.")
    put("watch quietly", "D",
        fondo_prado() + [
            F("M120 62 C136 58 140 34 126 30 C118 28 118 40 124 44 C128 48 124 56 116 58 Z", NARANJA_OSCURO, MADERA_OSCURA, 1.8),
            E(110, 56, 9, 8, BARRO, MADERA_OSCURA, 1.8),
            E(102, 46, 6.5, 6.5, BARRO, MADERA_OSCURA, 1.8),
            P([(99, 41), (101, 34), (105, 40)], BARRO, MADERA_OSCURA, 1.4),
            E(100, 45, 1.3, 1.3, NEGRO),
        ] + nino_busto(48, 48, (VERDE, VERDE_OSCURO)) + [
            L("M38 60 L48 48 L48 41", PELB, 4.4),
            L("M38 60 L48 48 L48 41", PEL, 2.4),
        ],
        "Niño en silencio con dedo sobre los labios observando a la ardilla.")
    put("watch the rain", "D",
        fondo_sala() + [
            R(36, 16, 84, 54, 4, "#64748b", MADERA_OSCURA, 2.8),
        ] + gotas([(52, 28), (74, 34), (96, 26), (64, 50), (90, 52)]) + [
            L("M78 18 L78 68 M38 43 L118 43", MADERA_OSCURA, 2.2),
        ] + bebe(124, 64),
        "Bebé contemplando a través de la ventana cómo caen las gotas de lluvia.")

    # ── move (primer bloque: 43 escenas + 1 directa = 44) ───────────────────
    put("back and forth", "D",
        fondo_sala() + [
            F("M48 48 L108 48 L98 68 L58 68 Z", MADERA, MADERA_OSCURA, 2.2),
            F("M44 68 Q78 78 112 68", MADERA_OSCURA, None, 3.0),
        ] + bebe(78, 42) + _frecha(44, 30, 112, 30, AZUL_OSCURO, 2.2) + _frecha(112, 24, 44, 24, ROJO_OSCURO, 2.2),
        "Cuna balancín meciendo suavemente al bebé adelante y atrás.")
    put("barefoot", "D",
        fondo_prado() + [
            E(58, 54, 9, 14, PEL, PELB, 2.0),
            E(52, 36, 2.5, 3, PEL, PELB, 1.3), E(58, 35, 2.5, 3, PEL, PELB, 1.3),
            E(64, 37, 2.5, 3, PEL, PELB, 1.3), E(69, 40, 2.2, 2.5, PEL, PELB, 1.3),
            E(98, 54, 9, 14, PEL, PELB, 2.0),
            E(92, 37, 2.5, 3, PEL, PELB, 1.3), E(98, 35, 2.5, 3, PEL, PELB, 1.3),
            E(104, 36, 2.5, 3, PEL, PELB, 1.3), E(87, 40, 2.2, 2.5, PEL, PELB, 1.3),
        ],
        "Pies descalzos sobre la hierba verde moviendo libremente los dedos.")
    put("big toe", "D",
        fondo_sala() + [
            E(76, 56, 18, 22, PEL, PELB, 2.2),
            E(60, 28, 7, 9, ROJO, ROJO_OSCURO, 2.2),
            E(72, 28, 3.5, 5, PEL, PELB, 1.5),
            E(81, 30, 3.5, 5, PEL, PELB, 1.5),
            E(90, 33, 3.2, 4.5, PEL, PELB, 1.5),
            L("M48 24 Q44 30 48 36 M70 16 Q60 12 52 16", AZUL_OSCURO, 2.0),
        ],
        "Pie resaltando en rojo el dedo gordo mientras se mueve de lado.")
    put("blustery", "D",
        fondo_cielo() + lineas_viento(22, 32, 36) + lineas_viento(34, 52, 40) + [
            L("M108 78 L118 46", MADERA_OSCURA, 3.4),
            E(120, 38, 18, 13, VERDE, VERDE_OSCURO, 2.0),
            P([(88, 66), (104, 62), (96, 70)], AMARILLO),
        ],
        "Viento fuerte doblando la copa del árbol con ráfagas inclinadas.")
    put("board game", "D",
        fondo_mesa() + [
            R(36, 26, 84, 48, 4, "#fef9c3", MADERA_OSCURA, 2.2),
            R(44, 34, 16, 14, 2, AZUL, AZUL_OSCURO, 1.4),
            R(64, 34, 16, 14, 2, ROJO, ROJO_OSCURO, 1.4),
            R(84, 34, 16, 14, 2, VERDE, VERDE_OSCURO, 1.4),
            R(104, 34, 10, 14, 2, AMARILLO, AMARILLO_OSCURO, 1.4),
            P([(72, 54), (66, 68), (78, 68)], ROJO, ROJO_OSCURO, 1.8),
            E(72, 52, 4, 4, ROJO, ROJO_OSCURO, 1.6),
            R(100, 56, 14, 14, 3, BLANCO, GRIS_OSCURO, 1.8),
            E(104, 60, 1.6, 1.6, NEGRO), E(110, 66, 1.6, 1.6, NEGRO),
        ],
        "Tablero de juego con casillas de colores, peón rojo y dado de puntos.")
    put("boats on the water", "D",
        fondo_mar() + [
            F("M28 58 L64 58 L58 68 L34 68 Z", ROJO, ROJO_OSCURO, 1.8),
            P([(46, 36), (46, 56), (60, 56)], BLANCO, GRIS_OSCURO, 1.6),
            F("M92 54 L128 54 L122 64 L98 64 Z", AMARILLO, AMARILLO_OSCURO, 1.8),
            P([(110, 32), (110, 52), (124, 52)], BLANCO, GRIS_OSCURO, 1.6),
        ],
        "Dos barquitos de vela balanceándose sobre las olas del agua.")
    put("branch", "D",
        fondo_cielo() + [
            L("M24 54 Q70 48 118 42 M74 49 L96 30", MADERA_OSCURA, 5.2),
            L("M24 54 Q70 48 118 42", MADERA, 2.8),
            E(98, 28, 8, 5, VERDE, VERDE_OSCURO, 1.6),
            E(122, 40, 8, 5, "#4ade80", VERDE_OSCURO, 1.6),
            E(66, 38, 7, 5, VERDE, VERDE_OSCURO, 1.6),
        ],
        "Rama de árbol extendida con brotes de hojas verdes al viento.")
    put("breezy", "D",
        fondo_cielo() + [
            P([(84, 22), (98, 34), (84, 46), (70, 34)], AZUL, AZUL_OSCURO, 2.0),
            L("M84 46 Q92 56 80 64 Q70 72 86 78", ROJO, 2.0),
        ] + lineas_viento(26, 36, 28),
        "Brisa suave haciendo ondear ligeramente una cometa celeste en el cielo.")
    put("brush, brush, brush", "D",
        fondo_mesa() + [
            R(44, 34, 62, 16, 6, MADERA, MADERA_OSCURA, 2.2),
            L("M48 50 L48 64 M56 50 L56 64 M64 50 L64 64 M72 50 L72 64 M80 50 L80 64 M88 50 L88 64 M96 50 L96 64", "#fde68a", 3.2),
            L("M28 58 L38 58 M112 58 L122 58", AZUL_OSCURO, 2.2),
        ],
        "Cepillo de madera barriendo de un lado a otro con trazos de movimiento.")
    put("busy port", "D",
        fondo_mar() + [
            F("M34 56 L92 56 L84 68 L42 68 Z", ROJO, ROJO_OSCURO, 2.0),
            R(46, 44, 16, 12, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
            R(66, 44, 16, 12, 2, AZUL, AZUL_OSCURO, 1.6),
            L("M118 76 L118 22 L92 32 M100 28 L100 42", GRIS_OSCURO, 3.0),
            R(94, 42, 12, 10, 2, VERDE, VERDE_OSCURO, 1.6),
        ],
        "Puerto activo con grúa cargando contenedores sobre un barco mercante.")
    put("cast a spell", "D",
        fondo_noite() + [
            L("M34 64 L78 36", MADERA_OSCURA, 4.2),
            L("M72 40 L78 36", BLANCO, 4.2),
            L("M84 36 Q96 24 106 38 Q116 48 122 32", "#c084fc", 2.4),
        ] + _estrella(86, 26, 7, "#fde047", AMARILLO_OSCURO) + _estrella(118, 28, 5, "#f472b6", ROSA_OSCURO),
        "Varita mágica trazando un arco encantado luminoso en el aire.")
    put("centipede", "D",
        fondo_prado() + [
            *[E(38 + i * 13, 52 + (i % 2) * 3, 7.5, 6.5, NARANJA, NARANJA_OSCURO, 1.8) for i in range(6)],
            E(38, 50, 2, 2, NEGRO),
            *[L(f"M{38 + i * 13} 58 L{34 + i * 13} 67 M{42 + i * 13} 58 L{45 + i * 13} 67", NEGRO, 1.8) for i in range(6)],
        ],
        "Ciempiés naranja largo con muchos pares de patitas caminando.")
    put("chomp", "D",
        fondo_prado() + [
            E(72, 48, 24, 17, BLANCO, NEGRO, 2.2),
            E(96, 42, 13, 12, BLANCO, NEGRO, 2.0),
            E(66, 46, 6, 5, NEGRO), E(80, 52, 5, 4, NEGRO),
            L("M56 62 L56 76 M84 62 L84 76", NEGRO, 3.2),
            L("M108 58 L104 68 M112 58 L112 68 M116 58 L120 68", VERDE_OSCURO, 2.2),
        ],
        "Vaca moteada masticando con apetito un manojo de hierba fresca.")
    put("choppy", "D",
        fondo_mar() + [
            F("M16 54 L34 40 L52 54 L70 40 L88 54 L106 40 L124 54 L142 40 L142 74 L16 74 Z", "#0284c7", AZUL_OSCURO, 2.0),
            F("M62 48 L88 44 L84 54 L66 56 Z", AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Mar picado lleno de olas puntiagudas agitando una barquita.")
    put("clock", "D",
        fondo_sala() + [
            E(78, 44, 28, 28, BLANCO, ROJO_OSCURO, 3.0),
            E(78, 44, 3, 3, NEGRO),
            L("M78 44 L78 24 M78 44 L94 44", NEGRO, 2.8),
            L("M78 18 L78 21 M78 67 L78 70 M52 44 L55 44 M101 44 L104 44", GRIS_OSCURO, 2.0),
        ] + _frecha(92, 22, 108, 34, AZUL_OSCURO, 2.2),
        "Reloj redondo de pared sin números mostrando las agujas girando.")
    put("cluck", "D",
        fondo_prado() + [
            E(78, 52, 18, 15, TIERRA_CLARA, MADERA_OSCURA, 2.2),
            E(92, 38, 9, 9, TIERRA_CLARA, MADERA_OSCURA, 2.0),
            P([(88, 29), (92, 24), (96, 29)], ROJO, ROJO_OSCURO, 1.4),
            P([(101, 37), (107, 39), (101, 41)], NARANJA),
            E(76, 52, 9, 6, MADERA, MADERA_OSCURA, 1.8),
        ] + ondas_sonido(112, 38, ROJO_OSCURO, 1),
        "Gallina aleteando y cacareando en la granja.")
    put("colourful reef", "D",
        fondo_mar() + [
            L("M44 74 L44 46 M44 58 L32 48 M44 54 L54 44", ROSA, 4.4),
            L("M78 74 L78 40 M78 56 L66 44 M78 52 L90 42", NARANJA, 4.4),
            E(112, 60, 14, 12, MORADO, "#5b21b6", 2.0),
            E(60, 34, 6, 4, AMARILLO, AMARILLO_OSCURO, 1.5),
            E(104, 32, 6, 4, AGUA, AZUL_OSCURO, 1.5),
        ],
        "Arrecife marino multicolor con corales rosados, naranjas, morados y peces.")
    put("conductor", "D",
        fondo_sala() + nino_busto(64, 48, (NEGRO, GRIS_OSCURO)) + [
            L("M82 54 L108 32", MADERA_OSCURA, 2.4),
        ] + notas_col([(114, 24), (128, 34)], ROJO_OSCURO),
        "Director de orquesta moviendo la batuta en el aire entre notas musicales.")
    put("counter", "D",
        fondo_mesa() + [
            R(28, 44, 100, 28, 3, "#fef9c3", MADERA_OSCURA, 2.0),
            L("M61 44 L61 72 M95 44 L95 72", MADERA_OSCURA, 1.6),
            E(45, 58, 9, 6, ROJO, ROJO_OSCURO, 2.0),
        ] + _frecha(45, 36, 110, 36, AZUL_OSCURO, 2.4),
        "Ficha redonda roja saltando dos casillas sobre el tablero.")
    put("delicate seagrass", "D",
        fondo_mar() + [
            F("M44 78 Q38 56 46 38 Q50 56 48 78 Z", "#4ade80", VERDE_OSCURO, 1.6),
            F("M68 78 Q74 52 66 32 Q62 52 72 78 Z", VERDE, VERDE_OSCURO, 1.6),
            F("M92 78 Q86 56 96 36 Q100 56 96 78 Z", "#4ade80", VERDE_OSCURO, 1.6),
            F("M116 78 Q122 54 114 34 Q110 54 120 78 Z", VERDE, VERDE_OSCURO, 1.6),
        ],
        "Algas largas y finas de pradera marina ondulando suavemente bajo el agua.")
    put("dig tunnels", "D",
        fondo_prado() + [
            F("M24 68 C40 34 116 34 132 68 Z", TIERRA, BARRO, 2.2),
            F("M54 68 C54 48 102 48 102 68 Z", "#1e293b", BARRO, 2.0),
            L("M34 30 L50 48", GRIS_OSCURO, 2.8),
            P([(48, 46), (56, 52), (46, 56)], GRIS, GRIS_OSCURO, 1.6),
        ],
        "Montículo de arena con pala cavando un túnel oscuro por debajo.")
    put("direct traffic", "D",
        fondo_sala() + [
            R(98, 46, 36, 22, 4, ROJO, ROJO_OSCURO, 2.0),
            E(106, 68, 5, 5, NEGRO), E(126, 68, 5, 5, NEGRO),
        ] + _nino_pie(48, 34, (AMARILLO, AMARILLO_OSCURO), 1) + [
            E(68, 42, 6, 6, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Niño con chaleco amarillo levantando la mano para dar paso o parar el coche.")
    put("dripping", "D",
        fondo_sala() + [
            R(44, 24, 34, 10, 3, GRIS, GRIS_OSCURO, 2.0),
            R(70, 30, 8, 8, 1, GRIS, GRIS_OSCURO, 1.8),
        ] + gotas([(74, 48), (74, 62)]) + [
            E(74, 76, 16, 4, AGUA, AZUL_OSCURO, 1.6),
        ],
        "Grifo goteando agua gota a gota hacia el charco inferior.")
    put("drizzly", "D",
        fondo_cielo() + [
            E(66, 30, 18, 11, GRIS, GRIS_OSCURO, 2.0),
            E(88, 32, 16, 10, GRIS, GRIS_OSCURO, 2.0),
            E(76, 26, 16, 11, GRIS, GRIS_OSCURO, 2.0),
        ] + [E(54 + i * 11, 52 + (i % 3) * 8, 1.8, 2.8, AGUA) for i in range(6)],
        "Nube gris soltando llovizna fina y menuda.")
    put("fast", "D",
        fondo_prado() + nino_corriendo(86, 30, 1, (ROJO, ROJO_OSCURO)) + [
            L("M24 38 L52 38 M18 48 L48 48 M26 58 L54 58", AZUL_OSCURO, 2.4),
        ],
        "Niño corriendo muy rápido con largas estelas de velocidad detrás.")
    put("feathery tail", "D",
        fondo_prado() + [
            E(56, 54, 14, 12, AZUL, AZUL_OSCURO, 2.0),
            E(46, 44, 7, 7, AZUL, AZUL_OSCURO, 1.8),
            P([(70, 52), (112, 30), (118, 42)], VERDE, VERDE_OSCURO, 1.8),
            P([(70, 54), (120, 46), (118, 58)], "#4ade80", VERDE_OSCURO, 1.8),
            P([(70, 56), (114, 64), (104, 74)], AZUL, AZUL_OSCURO, 1.8),
            E(108, 38, 3.5, 3.5, AMARILLO, AZUL_OSCURO, 1.2),
            E(112, 52, 3.5, 3.5, AMARILLO, AZUL_OSCURO, 1.2),
        ],
        "Pavo real desplegando su vistosa cola de plumas de colores.")
    put("flap", "D",
        fondo_cielo() + [
            E(78, 48, 14, 11, AZUL, AZUL_OSCURO, 2.2),
            E(78, 35, 8, 8, AZUL, AZUL_OSCURO, 2.0),
            P([(74, 28), (78, 24), (82, 28)], NARANJA),
            P([(64, 46), (40, 32), (48, 52)], "#38bdf8", AZUL_OSCURO, 1.8),
            P([(92, 46), (116, 32), (108, 52)], "#38bdf8", AZUL_OSCURO, 1.8),
            L("M44 26 Q38 34 40 42 M112 26 Q118 34 116 42", ROJO_OSCURO, 2.0),
        ],
        "Pajarito batiendo rápido sus dos alas abiertas en el aire.")
    put("flipper", "D",
        fondo_mar() + [
            F("M44 50 Q78 30 112 52 Q86 64 56 58 Z", "#38bdf8", AZUL_OSCURO, 2.2),
            F("M72 56 L84 72 L90 58 Z", ROJO, ROJO_OSCURO, 2.0),
            E(56, 48, 2, 2, NEGRO),
        ] + _mano_indice(108, 72, -1, -0.4, (AZUL, AZUL_OSCURO)),
        "Delfín con su aleta pectoral destacada en rojo y señalada.")
    put("flow", "D",
        fondo_prado() + [
            F("M20 44 Q58 30 88 46 Q114 60 140 44 L140 58 Q112 72 86 58 Q56 44 20 58 Z", AGUA, AZUL_OSCURO, 2.0),
        ] + _frecha(34, 48, 70, 44, BLANCO, 2.2) + _frecha(86, 52, 122, 50, BLANCO, 2.2),
        "Corriente continua de agua fluyendo suavemente por el cauce.")
    put("follow the light", "D",
        fondo_noite() + [
            R(24, 46, 22, 10, 3, ROJO, ROJO_OSCURO, 1.8),
            P([(46, 46), (54, 42), (54, 60), (46, 56)], AMARILLO, AMARILLO_OSCURO, 1.6),
            P([(54, 42), (126, 26), (126, 70), (54, 60)], "#fef08a"),
        ] + _frecha(78, 50, 114, 50, NARANJA_OSCURO, 2.4),
        "Haz de luz de linterna iluminando el camino oscuro a seguir.")
    put("follow with eyes", "D",
        fondo_sala() + _ojo(38, 48, 1.3) + [
            L("M56 44 Q82 32 104 38", AZUL_OSCURO, 2.0),
        ] + pompas([(114, 36, 11)]),
        "Ojo mirando y siguiendo la trayectoria de una pompa flotante.")
    put("frilly", "D",
        fondo_sala() + [
            P([(60, 26), (96, 26), (112, 66), (44, 66)], ROSA, ROSA_OSCURO, 2.2),
            F("M44 66 Q52 76 60 66 Q68 76 76 66 Q84 76 92 66 Q100 76 112 66", "#fbcfe8", ROSA_OSCURO, 2.2),
            R(60, 24, 36, 8, 2, ROSA_OSCURO),
        ],
        "Falda rosa con amplio borde de volantes ondulados en el bajo.")
    put("glinting", "D",
        fondo_cielo() + [
            P([(78, 28), (100, 48), (78, 68), (56, 48)], "#bae6fd", AZUL_OSCURO, 2.4),
            L("M78 16 L78 24 M78 72 L78 80 M42 48 L50 48 M106 48 L114 48 M54 28 L60 34 M102 28 L96 34", "#fde047", 2.4),
        ],
        "Cristal facetado lanzando destellos vivos al darle la luz del sol.")
    put("graceful flight", "D",
        fondo_cielo() + [
            E(78, 44, 14, 8, BLANCO, GRIS_OSCURO, 2.0),
            L("M88 42 Q100 32 108 38", BLANCO, 3.6),
            F("M64 42 Q76 20 92 34", BLANCO, GRIS_OSCURO, 2.0),
            L("M24 58 Q74 36 124 28", AZUL_OSCURO, 1.8),
        ],
        "Ave blanca planeando en un vuelo elegante y suave por el cielo.")
    put("graze", "D",
        fondo_prado() + [
            E(76, 46, 20, 15, BLANCO, GRIS_OSCURO, 2.2),
            E(56, 56, 9, 8, "#334155", NEGRO, 1.8),
            L("M68 60 L68 74 M88 60 L88 74", NEGRO, 2.8),
            L("M44 74 L42 64 M48 74 L48 64 M52 74 L54 64", VERDE_OSCURO, 2.0),
        ],
        "Oveja con la cabeza agachada pastando tranquilamente en el prado.")
    put("hips", "D",
        fondo_sala() + _nino_pie(78, 28, (ROJO, ROJO_OSCURO), 1) + [
            E(78, 54, 12, 5, None, AMARILLO_OSCURO, 2.2),
        ] + _frecha(52, 54, 36, 54, AZUL_OSCURO, 2.2) + _frecha(104, 54, 120, 54, AZUL_OSCURO, 2.2),
        "Niño resaltando la cintura y caderas moviéndolas de un lado a otro.")
    put("it's raining", "D",
        fondo_cielo() + [
            E(64, 26, 20, 12, GRIS, GRIS_OSCURO, 2.0),
            E(88, 28, 18, 11, GRIS, GRIS_OSCURO, 2.0),
            E(76, 22, 18, 11, GRIS, GRIS_OSCURO, 2.0),
        ] + gotas([(56, 46), (72, 52), (88, 44), (102, 54)]) + [
            E(78, 76, 30, 5, AGUA, AZUL_OSCURO, 1.8),
        ],
        "Nube oscura dejando caer lluvia abundante sobre un charco en el suelo.")
    put("kick leaves", "D",
        fondo_prado() + _nino_pie(64, 32, (NARANJA, NARANJA_OSCURO), 1) + [
            F("M88 62 Q98 52 108 58 Q98 68 88 62 Z", ROJO, ROJO_OSCURO, 1.6),
            F("M98 46 Q108 36 118 42 Q108 52 98 46 Z", AMARILLO, AMARILLO_OSCURO, 1.6),
            F("M84 42 Q94 32 104 38 Q94 48 84 42 Z", NARANJA, NARANJA_OSCURO, 1.6),
        ] + _frecha(74, 72, 102, 58, AZUL_OSCURO, 2.2),
        "Niño pateando hojas secas de otoño que salen volando por el aire.")
    put("leaf litter", "D",
        fondo_prado() + [
            F("M26 70 Q38 56 54 64 Q42 76 26 70 Z", BARRO, MADERA_OSCURA, 1.6),
            F("M48 68 Q62 54 78 62 Q64 76 48 68 Z", NARANJA, NARANJA_OSCURO, 1.6),
            F("M72 70 Q86 56 102 64 Q88 76 72 70 Z", AMARILLO, AMARILLO_OSCURO, 1.6),
            F("M96 68 Q110 54 126 62 Q112 76 96 68 Z", ROJO, ROJO_OSCURO, 1.6),
            F("M58 60 Q72 48 88 56 Q74 68 58 60 Z", TIERRA_CLARA, BARRO, 1.6),
        ],
        "Alfombra espesa de hojas secas caídas cubriendo el suelo del bosque.")
    put("leafy", "D",
        fondo_prado() + [
            R(72, 54, 12, 28, 2, MADERA, MADERA_OSCURA, 2.0),
            E(78, 38, 26, 22, VERDE, VERDE_OSCURO, 2.2),
            E(58, 42, 16, 14, "#4ade80", VERDE_OSCURO, 1.8),
            E(98, 42, 16, 14, "#4ade80", VERDE_OSCURO, 1.8),
            E(78, 24, 18, 13, "#22c55e", VERDE_OSCURO, 1.8),
        ],
        "Árbol muy frondoso con la copa cargada de capas de hojas verdes.")
    put("leafy jungle", "D",
        fondo_prado() + [
            L("M34 80 L34 26", VERDE_OSCURO, 3.2),
            F("M34 28 Q16 20 14 34 Q24 38 34 28 Z", "#4ade80", VERDE_OSCURO, 1.6),
            F("M34 28 Q52 20 54 34 Q44 38 34 28 Z", "#4ade80", VERDE_OSCURO, 1.6),
            L("M118 80 L118 24", VERDE_OSCURO, 3.2),
            F("M118 26 Q100 18 98 32 Q108 36 118 26 Z", VERDE, VERDE_OSCURO, 1.6),
            F("M118 26 Q136 18 138 32 Q128 36 118 26 Z", VERDE, VERDE_OSCURO, 1.6),
            L("M56 0 Q72 26 66 52 M96 0 Q82 28 90 54", VERDE_OSCURO, 2.4),
        ],
        "Selva espesa con palmeras tropicales, grandes hojas verdes y lianas.")
    put("light show", "D",
        fondo_noite() + [
            P([(28, 84), (60, 18), (44, 84)], ROJO),
            P([(78, 84), (78, 14), (94, 84)], AZUL),
            P([(128, 84), (98, 18), (112, 84)], AMARILLO),
            R(20, 78, 116, 10, 2, GRIS_OSCURO, NEGRO, 1.8),
        ],
        "Escenario oscuro atravesado por focos de luz roja, azul y amarilla.")
    put("many-legged", "D",
        fondo_prado() + [
            *[E(38 + i * 16, 48, 10, 9, VERDE, VERDE_OSCURO, 1.8) for i in range(5)],
            E(34, 46, 2, 2, NEGRO),
            *[L(f"M{36 + i * 16} 57 L{34 + i * 16} 68 M{42 + i * 16} 57 L{44 + i * 16} 68", NEGRO, 1.8) for i in range(5)],
        ],
        "Oruga verde con hileras de muchas patitas caminando por debajo.")

    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    # point (80)
    "cue": "Concepto teatral temporal («Entrada / señal para hablar»); indistinguible de señalar a un amigo sin texto.",
    "different opinions": "Concepto cognitivo/social abstracto («Opiniones distintas»).",
    "does it float or sink": "Pregunta conversacional comparativa («¿Flota o se hunde?»); sin interrogación parece solo el experimento.",
    "familiar": "Rasgo social/cognitivo abstracto («Conocido»).",
    "famous": "Estatus social abstracto («Famoso»).",
    "favourite day": "Preferencia personal temporal («Día favorito»); señalar una casilla en calendario no distingue favorito sin texto.",
    "great-grandparents": "Relación genealógica temporal («Bisabuelos»); sin etiqueta de generación no se distingue de abuelos.",
    "guess": "Verbo cognitivo abstracto («Adivinar»); igual que «pensar» o «predecir» sin texto.",
    "here a moo, there a moo": "Estribillo cantado («Aquí un mu, allí un mu»); depende de la canción infantil hablada.",
    "here it is": "Exclamación conversacional deíctica («¡Aquí está!»).",
    "here's the shop": "Expresión situacional («Aquí está la tienda»); idéntica a «tienda» sin texto.",
    "history": "Concepto disciplinar temporal abstracto («Historia»).",
    "how are you feeling today": "Pregunta conversacional sobre emociones («¿Cómo te sientes hoy?»).",
    "how do you feel": "Pregunta conversacional sobre emociones («¿Cómo te sientes?»).",
    "how much is it": "Pregunta comercial conversacional («¿Cuánto cuesta?»); requiere signos/cifras.",
    "kind words make people smile": "Oración moral sobre palabras habladas («Las palabras amables hacen sonreír»).",
    "last week": "Referencia temporal pasada («La semana pasada»); imposible sin texto ni fechas.",
    "long, long ago": "Fórmula narrativa temporal («Hace mucho, mucho tiempo»).",
    "look at me": "Exhortación conversacional («¡Mírame!»); sin texto es indistinguible de señalar o mirar.",
    "mission": "Concepto abstracto de objetivo escolar o juego («Misión»).",
    "most of us chose the park": "Oración compleja de votación pasada («La mayoría elegimos el parque»).",
    "my favourite day was the beach": "Oración personal de preferencia pasada («Mi día favorito fue la playa»).",
    "my grandma is older than my mum": "Oración comparativa de parentesco y edad («Mi abuela es mayor que mi madre»).",
    "name a feeling": "Consigna lingüística («Nombrar un sentimiento»).",
    "next month": "Concepto temporal futuro («El mes que viene»); indistinguible de «mes» sin etiqueta.",
    "next year": "Concepto temporal futuro («El año que viene»).",
    "notice": "Verbo perceptivo/cognitivo abstracto («Darse cuenta»).",
    "oldest": "Superlativo temporal abstracto («El más viejo»).",
    "on time": "Concepto temporal de puntualidad («A tiempo»); un reloj solo no expresa puntualidad sin texto.",
    "over or under": "Pregunta espacial alternativa («¿Por encima o por debajo?»).",
    "plan ahead": "Verbo cognitivo de planificación («Planificar»).",
    "predict what's next": "Verbo cognitivo predictivo («Adivinar lo siguiente»).",
    "price": "Concepto económico numérico («Precio»); prohibido escribir cifras o símbolos monetarios en la etiqueta.",
    "react": "Verbo abstracto («Reaccionar»); ya rechazado junto con «reaction».",
    "remember the past": "Verbo mental temporal («Recordar el pasado»).",
    "remember when": "Verbo mental conversacional («Recordar cuando»).",
    "remote": "Rechazado explícitamente en P2.81 («remote, den, verse…»); «far/distant» ya cubren la distancia visual.",
    "roasting time": "Duración temporal abstracta («Tiempo de asado»).",
    "role": "Concepto teatral abstracto («Papel»).",
    "say your line": "Consigna verbal de actuación («Decir tu frase»).",
    "seasonal": "Adjetivo clasificatorio temporal abstracto («De temporada»).",
    "special": "Adjetivo valorativo abstracto («Especial»).",
    "spot": "Verbo perceptivo abstracto y homónimo visual («Descubrir / punto»).",
    "spot the mistake": "Consigna cognitiva de revisión («Encontrar el error»).",
    "stage directions": "Indicaciones escénicas textuales («Indicaciones de escena»).",
    "stars are further away than the moon": "Oración comparativa astronómica larga («Las estrellas están más lejos que la Luna»).",
    "symbol": "Concepto semiótico abstracto («Símbolo»).",
    "there it is": "Exclamación conversacional deíctica («¡Ahí está!»).",
    "this tree is older than our grandparents": "Oración comparativa de edad histórica («Este árbol es más viejo que nuestros abuelos»).",
    "timetable": "Horario numérico («Horario»); prohibido dibujar cifras de horas o texto.",
    "timetable board": "Tablero de horario escolar con letras y horas («Horario de la clase»).",
    "today": "Adverbio temporal deíctico («Hoy»); sin calendario con texto resulta ambiguo.",
    "tomorrow": "Adverbio temporal deíctico («Mañana»).",
    "turn order": "Regla organizativa abstracta («Orden de turnos»).",
    "what animal are you": "Pregunta conversacional («¿Qué animal eres?»).",
    "what bird is that": "Pregunta conversacional («¿Qué pájaro es ese?»).",
    "what colour is broccoli": "Pregunta conversacional («¿De qué color es el brócoli?»).",
    "what comes next": "Pregunta secuencial («¿Qué viene después?»).",
    "what day is it today": "Pregunta temporal de calendario («¿Qué día es hoy?»).",
    "what do you want to be": "Pregunta vocacional conversacional («¿Qué quieres ser?»).",
    "what grows on the ropes": "Pregunta de observación («¿Qué crece en las cuerdas?»).",
    "what happened next": "Pregunta narrativa secuencial («¿Qué pasó después?»).",
    "when the timer rings, we swap": "Regla condicional con alarma sonora («Cuando suene el temporizador, cambiamos»).",
    "where are we on the map": "Pregunta espacial sobre el mapa («¿Dónde estamos en el mapa?»).",
    "where does rain come from": "Pregunta científica conversacional («¿De dónde viene la lluvia?»).",
    "where will you go this summer": "Pregunta futura sobre vacaciones («¿Adónde irás este verano?»).",
    "which bus goes to the beach": "Pregunta conversacional sobre rutas («¿Qué autobús va a la playa?»).",
    "which light is the brightest": "Pregunta comparativa («¿Cuál es la luz más brillante?»).",
    "which piece goes here": "Pregunta de puzle («¿Qué pieza va aquí?»).",
    "which sense do we use": "Pregunta clasificatoria sobre los sentidos («¿Qué sentido usamos?»).",
    "which side goes down": "Pregunta sobre balanza («¿Qué lado baja?»).",
    "who am i": "Pregunta de adivinanza conversacional («¿Quién soy yo?»).",
    "who are you today": "Pregunta conversacional de juego («¿Quién eres hoy?»).",
    "who's in the mirror": "Pregunta frente al espejo («¿Quién está en el espejo?»).",
    "who's this": "Pregunta deíctica («¿Quién es este?»).",
    "yesterday": "Adverbio temporal pasado («Ayer»).",
    "yesterday was monday, today is tuesday": "Oración sobre nombres escritos de días de la semana («Ayer fue lunes, hoy es martes»).",
    "you and me": "Pronombres deícticos conversacionales («Tú y yo»).",
    "you first, then me": "Regla conversacional de turno («Tú primero, luego yo»).",
    "you think this, but i think that": "Contraste mental abstracto («Tú piensas esto, pero yo pienso aquello»).",
    # look (37)
    "admire": "Verbo actitudinal sutil («Admirar»); difícil de diferenciar de sorprenderse o mirar sin texto.",
    "beautiful": "Adjetivo estético valorativo abstracto («Bonito, bonita»).",
    "can you find something red": "Pregunta conversacional de búsqueda («¿Encuentras algo rojo?»).",
    "curious": "Rasgo cognitivo abstracto («Curioso, curiosa»); indistinguible de «observar» con lupa.",
    "curious mind": "Concepto cognitivo abstracto («Mente curiosa»).",
    "dreamy": "Estado anímico abstracto («Soñador»).",
    "find something red": "Consigna verbal de aula («Busca algo rojo»).",
    "focused": "Estado interno de atención («Concentrado»).",
    "give a compliment": "Acto de habla social («Decir un cumplido»); «compliment» ya está sin base.",
    "guess the taste": "Juego perceptivo interno («Adivinar el sabor»); «guess» es abstracto.",
    "hopeful": "Estado emocional abstracto («Esperanzado»).",
    "look at one spot": "Consigna verbal de atención («Mira un punto»).",
    "look back on": "Verbo mental de recuerdo («Recordar»).",
    "look forward": "Expresión idiomática emocional («Tener ganas»).",
    "look through the tube": "Consigna conversacional redundante con «look through» («¡Mira por el tubo!»).",
    "nostalgic": "Sentimiento temporal abstracto («Nostálgico»).",
    "notice feelings": "Verbo afectivo abstracto («Fijarse en los sentimientos»).",
    "point of view": "Concepto perspectivo abstracto («Punto de vista»).",
    "pretty": "Adjetivo estético valorativo («Lindo, linda»).",
    "ready": "Rechazado explícitamente en P2.81 («little/ready/play/give me five…»); estado abstracto sin objeto único.",
    "see both sides": "Expresión idiomática cognitiva («Ver las dos partes»).",
    "sense": "Rechazado explícitamente en P2.81 («sense…»); categoría general de los cinco sentidos.",
    "share memories": "Verbo conversacional abstracto («Compartir recuerdos»).",
    "sharp-eyed": "Adjetivo figurado abstracto («De vista aguda»).",
    "sing in tune": "Cualidad acústica invisible del canto («Cantar afinado»).",
    "what can you see from here": "Pregunta conversacional abierta («¿Qué ves desde aquí?»).",
    "what lives in the seagrass": "Pregunta biológica abierta («¿Qué vive en la pradera marina?»).",
    "what lives on the seabed": "Pregunta biológica abierta («¿Qué vive en el fondo del mar?»).",
    "what's in the basket": "Pregunta conversacional («¿Qué hay en la cesta?»).",
    "where does it go": "Pregunta de clasificación («¿Dónde va?»).",
    "where is the squirrel": "Pregunta conversacional de búsqueda («¿Dónde está la ardilla?»).",
    "where's teddy": "Pregunta conversacional («¿Dónde está el osito?»).",
    "where's the birdie": "Pregunta conversacional («¿Dónde está el pajarito?»).",
    "where's the monkey": "Pregunta conversacional («¿Dónde está el mono?»).",
    "where's your nose": "Pregunta conversacional («¿Dónde está tu nariz?»).",
    "who lives here": "Pregunta conversacional («¿Quién vive aquí?»).",
    "who's there": "Pregunta conversacional («¿Quién anda ahí?»).",
    # move (10 primeros)
    "abracadabra": "Palabra mágica hablada («¡Abracadabra!»); depende del texto oral.",
    "busy": "Adjetivo abstracto de ocupación («Ocupado, ocupada»).",
    "busy fingers": "Expresión descriptiva sin objeto distinto («Dedos inquietos»).",
    "clean and clear": "Par de adjetivos genérico redundante («Limpio y claro»).",
    "direct": "Verbo abstracto sin contexto concreto («Dirigir»).",
    "glittering": "Adjetivo dependiente de destellos genéricos («Resplandeciente»).",
    "hello, i'm sock": "Saludo dialogado de títere con nombre («¡Hola, soy Calcetín!»).",
    "homemade": "Adjetivo de procedencia abstracto («Casero»); indistinguible de cocinar sin texto.",
    "imaginary": "Adjetivo abstracto («Imaginario»).",
    "magic": "Concepto fantasioso abstracto («Mágico, mágica»); coherente con «magical» sin base.",
}
