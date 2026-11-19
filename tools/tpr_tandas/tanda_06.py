#!/usr/bin/env python3
"""Tanda 6 TPR (P2.87): crear/dibujar (cierre), enseñar/mostrar, hablar/cantar,
contar/dedos y primer bloque de tocar/cuerpo.

Cubre 200 piezas revisadas + 69 auditadas sin base (`SIN_BASE`):
- Cierre completo de `make_draw` (38+1), `show_gesture` (37+12),
  `mouth_sing` (34+19) y `count_fingers` (61+34).
- Primer bloque de `body_touch` (`all by myself`..`grassy`: 30+3).

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas, numéricas dependientes de dígitos o sin base visual clara quedan
en `SIN_BASE`.
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
    bebe_sentado,
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
    lineas_viento,
    nino,
    nino_busto,
    nino_caminando,
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
    "lightning": ("Cloud with lightning", "U", "Nube oscura descargando un rayo amarillo de relámpago."),
    "moon": ("Full moon", "U", "Luna llena amarilla y redonda brillando en la noche."),
    "question mark": ("Red question mark", "U", "Signo de interrogación rojo en estilo plano."),
    "smiley face": ("Grinning face", "U", "Cara amarilla con gran sonrisa alegre."),
    "muscles": ("Flexed biceps", "U", "Brazo flexionado enseñando los músculos con fuerza."),
    "rice": ("Cooked rice", "U", "Cuenco blanco lleno de granos de arroz cocido."),
}

DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _mano_abierta(cx: float, cy: float, esc: float = 1.0, manga: tuple[str, str] = (AZUL, AZUL_OSCURO)) -> list[dict]:
    """Mano plana estilizada con antebrazo/puño, palma, pulgar y cuatro dedos."""
    s = esc
    o = [
        R(cx - 7 * s, cy + 12 * s, 14 * s, 12 * s, 3 * s, manga[0], manga[1], 1.8),
        R(cx - 8 * s, cy - 3 * s, 16 * s, 16 * s, 6 * s, PEL, PELB, 1.8),
        L(f"M{cx - 7 * s:.1f} {cy + 4 * s:.1f} L{cx - 14 * s:.1f} {cy - 2 * s:.1f}", PELB, 5.2 * s),
        L(f"M{cx - 7 * s:.1f} {cy + 4 * s:.1f} L{cx - 14 * s:.1f} {cy - 2 * s:.1f}", PEL, 3.0 * s),
    ]
    for dx, dy_top in [(-5.5, -14), (-1.8, -17), (2.0, -16), (5.6, -12)]:
        o += [
            L(f"M{cx + dx * s:.1f} {cy - 1 * s:.1f} L{cx + dx * s:.1f} {cy + dy_top * s:.1f}", PELB, 4.6 * s),
            L(f"M{cx + dx * s:.1f} {cy - 1 * s:.1f} L{cx + dx * s:.1f} {cy + dy_top * s:.1f}", PEL, 2.6 * s),
        ]
    return o


def _mano_indice(x: float, y: float, dir_x: int = 1, dir_y: int = -1, manga: tuple[str, str] = (ROJO, ROJO_OSCURO)) -> list[dict]:
    """Mano con antebrazo y dedo índice extendido señalando/tocando un punto."""
    tx = x + 16 * dir_x
    ty = y + 14 * dir_y
    return [
        R(x - 10 * dir_x - 6, y + 6, 14, 11, 3, manga[0], manga[1], 1.8),
        E(x, y + 4, 8, 7, PEL, PELB, 1.8),
        L(f"M{x + 3 * dir_x:.1f} {y + 1:.1f} L{tx:.1f} {ty:.1f}", PELB, 5.2),
        L(f"M{x + 3 * dir_x:.1f} {y + 1:.1f} L{tx:.1f} {ty:.1f}", PEL, 3.0),
    ]


def _hoja(cx: float, cy: float, rx: float, ry: float, col: str, borde: str, ang: float = 0.0) -> list[dict]:
    """Hoja simétrica sencilla con nervio central."""
    dx = ang
    return [
        F(
            f"M{cx - rx:.1f} {cy + dx:.1f} "
            f"Q{cx:.1f} {cy - ry * 1.4:.1f} {cx + rx:.1f} {cy - dx:.1f} "
            f"Q{cx:.1f} {cy + ry * 1.4:.1f} {cx - rx:.1f} {cy + dx:.1f} Z",
            col, borde, 2.0,
        ),
        L(f"M{cx - rx * 1.15:.1f} {cy + dx * 1.1:.1f} L{cx + rx * 0.75:.1f} {cy - dx * 0.7:.1f}", borde, 1.8),
        L(f"M{cx - rx * 0.2:.1f} {cy:.1f} L{cx + rx * 0.15:.1f} {cy - ry * 0.55:.1f}", borde, 1.3),
        L(f"M{cx - rx * 0.1:.1f} {cy:.1f} L{cx + rx * 0.25:.1f} {cy + ry * 0.52:.1f}", borde, 1.3),
    ]


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], pq: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, pq, lic)

    # ── 1. Cierre de `make_draw` (34 escenas) ──────────────────────────────
    put("chalk", "D",
        fondo_sala() + [
            R(20, 62, 120, 26, 4, "#334155", NEGRO, 2.0),
            L("M34 75 Q52 67 70 75 Q88 83 106 75", BLANCO, 2.6),
            P([(98, 60), (118, 42), (124, 48), (104, 66)], BLANCO, GRIS_OSCURO, 1.8),
            R(112, 40, 14, 10, 2, "#fde047", AMARILLO_OSCURO, 1.5),
            R(124, 34, 14, 14, 4, PEL, PELB, 1.8),
        ],
        "Mano sujetando una tiza blanca que traza líneas sobre la pizarra oscura del suelo.")
    put("circular", "D",
        fondo_mesa() + [
            E(74, 48, 28, 28, "#dbeafe", AZUL_OSCURO, 3.2),
            E(74, 48, 20, 20, BLANCO, AZUL, 1.6),
        ] + _mano_indice(116, 62, -1, -1, (VERDE, VERDE_OSCURO)),
        "Círculo grande y perfecto trazado con el dedo sobre la mesa.")
    put("create a picture", "C",
        fondo_sala() + [
            L("M56 84 L74 20 M92 84 L74 20", MADERA_OSCURA, 3.2),
            R(44, 22, 60, 44, 3, BLANCO, MADERA_OSCURA, 2.6),
            R(48, 26, 52, 36, 1, "#bae6fd"),
            F("M48 62 L66 42 L82 54 L94 40 L100 62 Z", HERBA),
            E(88, 34, 5, 5, AMARILLO),
        ] + fl("Paintbrush", 104, 38, 38),
        "Lienzo enmarcado sobre caballete con paisaje pintado y pincel.")
    put("curved", "D",
        fondo_cielo() + [
            L("M28 66 C48 22 72 22 86 52 C100 82 122 80 134 36", MORADO, 4.5),
            E(28, 66, 4.5, 4.5, ROJO, ROJO_OSCURO, 1.5),
            E(134, 36, 4.5, 4.5, ROJO, ROJO_OSCURO, 1.5),
        ] + _mano_indice(126, 56, 1, -1, (AMARILLO, AMARILLO_OSCURO)),
        "Trazo curvo amplio en forma de ola dibujado suavemente.")
    put("cut a cross", "D",
        fondo_mesa() + [
            R(46, 20, 68, 60, 4, BLANCO, GRIS_OSCURO, 2.0),
            L("M60 32 L100 68", ROJO, 5.0),
            L("M100 32 L60 68", ROJO, 5.0),
        ] + _mano_indice(118, 68, -1, -1),
        "Mano dibujando una cruz en aspa clara sobre una lámina blanca.")
    put("draw a shape", "C",
        fondo_sala() + [
            R(28, 60, 104, 26, 4, "#475569", NEGRO, 2.0),
            P([(62, 80), (80, 63), (98, 80)], AMARILLO, AMARILLO_OSCURO, 2.4),
            E(44, 73, 7, 7, "#38bdf8", AZUL_OSCURO, 2.0),
        ] + fl("Crayon", 96, 36, 36),
        "Cera de color dibujando un triángulo y un círculo en el suelo.")
    put("draw circles", "D",
        fondo_sala() + [
            E(64, 24, 10, 10, BARRO, "#451a03", 1.8),
            E(54, 25, 2.5, 3, PEL, PELB, 1.2),
            E(74, 25, 2.5, 3, PEL, PELB, 1.2),
            R(46, 35, 36, 40, 8, AZUL, AZUL_OSCURO, 2.0),
            E(64, 54, 11, 11, None, AMARILLO, 2.0),
            E(64, 54, 5.5, 5.5, None, "#fde047", 1.8),
        ] + _mano_indice(98, 58, -1, -1, (ROJO, ROJO_OSCURO)),
        "Niño de espaldas mientras un dedo traza círculos concéntricos en su espalda.")
    put("draw with chalk", "D",
        fondo_sala() + [
            R(22, 54, 116, 34, 4, "#334155", NEGRO, 2.2),
            E(52, 70, 9, 9, "#fde047", AMARILLO_OSCURO, 1.8),
            E(96, 70, 8, 8, ROSA, ROSA_OSCURO, 1.8),
            R(30, 36, 22, 7, 3, "#f9a8d4", ROSA_OSCURO, 1.5),
            R(58, 36, 22, 7, 3, "#93c5fd", AZUL_OSCURO, 1.5),
            R(86, 36, 22, 7, 3, "#fde047", AMARILLO_OSCURO, 1.5),
        ],
        "Tizas de colores dibujando un sol y una flor sobre la acera oscura.")
    put("dream journal", "C",
        fondo_noite() + [
            R(36, 48, 54, 38, 3, MORADO, AZUL_OSCURO, 2.0),
            R(42, 52, 44, 30, 2, BLANCO, GRIS, 1.4),
            E(52, 26, 12, 10, "#e2e8f0", GRIS_OSCURO, 1.6),
            E(74, 26, 12, 10, "#e2e8f0", GRIS_OSCURO, 1.6),
            E(63, 21, 15, 11, "#e2e8f0", GRIS_OSCURO, 1.6),
            E(63, 24, 18, 9, "#e2e8f0"),
            F("M62 17 C54 19 54 29 62 31 C58 27 58 21 62 17 Z", AMARILLO_OSCURO),
            F("M72 20 L74 23 L77 24 L74 25 L72 28 L70 25 L67 24 L70 23 Z", AMARILLO_OSCURO),
        ] + fl("Pencil", 96, 44, 38),
        "Cuaderno de sueños abierto con nube de luna creciente y lápiz para dibujar.")
    put("dune", "D",
        fondo_cielo() + [
            F("M0 78 Q42 36 86 58 Q120 74 160 52 L160 100 L0 100 Z", "#fde047", TIERRA_CLARA, 2.0),
            F("M44 74 Q92 34 148 72 L160 72 L160 100 L0 100 Z", "#fbbf24", TIERRA, 2.0),
            L("M58 58 Q88 48 116 62", TIERRA, 1.6),
        ],
        "Dunas curvas de arena dorada moldeadas por el viento junto al cielo.")
    put("estuary", "D",
        fondo_cielo() + [
            F("M0 50 L160 50 L160 100 L0 100 Z", HERBA),
            F("M46 50 Q62 72 30 100 L130 100 Q98 72 114 50 Z", AGUA, AGUA_OSCURO, 2.0),
            L("M66 64 L94 64 M56 80 L104 80", BLANCO, 1.6),
        ],
        "Ría azul que se ensancha entre colinas verdes hasta llegar al mar.")
    put("family tree", "D",
        fondo_prado() + [
            R(74, 44, 12, 36, 3, MADERA, MADERA_OSCURA, 2.0),
            E(80, 34, 36, 24, HERBA, VERDE_OSCURO, 2.2),
            E(62, 28, 8, 9, "#fef3c7", BARRO, 1.8),
            E(98, 28, 8, 9, "#fef3c7", BARRO, 1.8),
            E(80, 42, 8, 9, "#fef3c7", BARRO, 1.8),
            E(62, 27, 4, 4, PEL), E(98, 27, 4, 4, PEL), E(80, 41, 4, 4, PEL),
        ],
        "Árbol frondoso con marcos ovalados de la familia colgados en sus ramas.")
    put("farm", "C",
        fondo_prado() + [
            P([(30, 44), (56, 22), (82, 44)], ROJO_OSCURO, NEGRO, 2.0),
            R(34, 44, 44, 32, 2, ROJO, ROJO_OSCURO, 2.0),
            R(48, 56, 16, 20, 2, BLANCO, NEGRO, 1.6),
            L("M48 56 L64 76 M64 56 L48 76", ROJO_OSCURO, 1.5),
            L("M84 68 L138 68 M84 76 L138 76 M96 60 L96 80 M116 60 L116 80 M134 60 L134 80", MADERA_OSCURA, 2.4),
        ] + fl("Cow", 94, 34, 42),
        "Granja con establo rojo, valla de madera y vaca pastando en el prado.")
    put("geometric", "D",
        fondo_mesa() + [
            P([(30, 68), (50, 30), (70, 68)], ROJO, ROJO_OSCURO, 2.2),
            R(76, 34, 32, 32, 2, AZUL, AZUL_OSCURO, 2.2),
            E(128, 50, 16, 16, AMARILLO, AMARILLO_OSCURO, 2.2),
        ],
        "Triángulo rojo, cuadrado azul y círculo amarillo en estilo geométrico limpio.")
    put("illustrate", "C",
        fondo_mesa() + libro_prop(38, 30, 56, AZUL) + [
            E(52, 48, 6, 8, ROSA, ROSA_OSCURO, 1.4),
            E(80, 48, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.4),
        ] + fl("Artist palette", 96, 36, 40),
        "Libro abierto ilustrado con dibujos junto a una paleta de colores.")
    put("look, a spiral", "C",
        fondo_prado() + nino_busto(48, 38, (VERDE, VERDE_OSCURO)) + [
            L("M60 48 L82 44", PELB, 4.6), L("M60 48 L82 44", PEL, 2.6),
        ] + fl("Spiral shell", 88, 32, 44),
        "Niño señalando sorprendido la espiral de una concha de caracol.")
    put("necklace", "D",
        fondo_mesa() + [
            E(80, 50, 30, 24, None, GRIS_OSCURO, 2.0),
        ] + [
            E(cx, cy, 5.5, 5.5, col, NEGRO, 1.5)
            for cx, cy, col in [
                (80, 26, ROJO), (98, 31, AMARILLO), (108, 44, VERDE), (105, 62, AZUL),
                (90, 72, MORADO), (70, 72, ROSA), (55, 62, NARANJA), (52, 44, AZUL), (62, 31, VERDE),
            ]
        ],
        "Collar circular de cuentas de colores brillantes ensartadas.")
    put("oak leaf", "D",
        fondo_prado() + [
            F(
                "M46 72 L60 60 Q52 46 66 42 Q60 28 76 28 Q80 14 92 22 "
                "Q106 16 106 32 Q122 32 112 46 Q120 60 102 62 Q94 74 80 66 "
                "Q68 74 62 62 Z",
                VERDE, VERDE_OSCURO, 2.2,
            ),
            L("M46 72 L96 28", VERDE_OSCURO, 2.2),
            L("M68 52 L66 38 M80 42 L78 28 M82 42 L98 44", VERDE_OSCURO, 1.5),
        ],
        "Hoja de roble verde con su borde característico de lóbulos ondulados.")
    put("oval", "D",
        fondo_mesa() + [
            E(80, 50, 42, 24, "#ddd6fe", MORADO, 3.2),
            E(80, 50, 32, 16, BLANCO, MORADO, 1.4),
        ],
        "Figura ovalada morada limpia y alargada sobre la mesa.")
    put("paint stripes", "C",
        fondo_sala() + [
            E(66, 50, 26, 26, PEL, PELB, 2.4),
            F("M40 46 C42 18 90 18 92 46 C80 32 52 32 40 46 Z", BARRO),
            E(56, 46, 2.6, 3.2, TINTA),
            E(76, 46, 2.6, 3.2, TINTA),
            L("M58 60 Q66 66 74 60", "#9a3412", 2.0),
            R(44, 52, 10, 3, 1, ROJO), R(44, 57, 10, 3, 1, AMARILLO),
            R(78, 52, 10, 3, 1, AZUL), R(78, 57, 10, 3, 1, VERDE),
        ] + fl("Paintbrush", 96, 34, 38),
        "Cara sonriente con rayas de colores pintadas en las mejillas y pincel.")
    put("rainbow-striped", "D",
        fondo_cielo() + [
            R(42, 24, 76, 54, 6, BLANCO, GRIS_OSCURO, 2.2),
            R(44, 26, 72, 8, 1, ROJO),
            R(44, 34, 72, 8, 1, NARANJA),
            R(44, 42, 72, 8, 1, AMARILLO),
            R(44, 50, 72, 8, 1, VERDE),
            R(44, 58, 72, 8, 1, AZUL),
            R(44, 66, 72, 8, 1, MORADO),
        ],
        "Bandera o tela blanca decorada con seis franjas paralelas arcoíris.")
    put("round and round the garden", "D",
        fondo_prado() + _mano_abierta(68, 54, 1.25, (VERDE, VERDE_OSCURO)) + [
            L("M68 54 C74 50 76 58 68 60 C60 62 58 50 68 46 C78 42 82 58 70 66", ROJO, 2.2),
            E(116, 42, 8, 8, ROSA, ROSA_OSCURO, 1.5),
            E(116, 42, 3, 3, AMARILLO),
            L("M116 50 L116 74", VERDE_OSCURO, 2.2),
        ],
        "Espiral trazada sobre la palma de la mano junto a una flor de jardín.")
    put("spiral", "D",
        fondo_mesa() + [
            L(
                "M80 50 C84 46 88 52 82 56 C74 60 68 50 74 42 "
                "C82 32 98 38 96 54 C94 70 70 74 60 58 C50 40 66 20 88 22 C108 24 114 48 106 68",
                AGUA_OSCURO, 3.6,
            ),
            E(80, 50, 3.2, 3.2, NARANJA),
        ],
        "Espiral nítida trazada desde el centro hacia fuera en azul intenso.")
    put("square", "D",
        fondo_mesa() + [
            R(52, 22, 56, 56, 2, "#bfdbfe", AZUL_OSCURO, 3.5),
            E(52, 22, 3.5, 3.5, ROJO), E(108, 22, 3.5, 3.5, ROJO),
            E(52, 78, 3.5, 3.5, ROJO), E(108, 78, 3.5, 3.5, ROJO),
        ],
        "Cuadrado azul de cuatro lados iguales con sus cuatro vértices marcados.")
    put("storyboard", "D",
        fondo_mesa() + [
            R(20, 26, 120, 50, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(26, 32, 32, 38, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            E(42, 45, 7, 7, AMARILLO),
            R(64, 32, 32, 38, 2, "#e2e8f0", GRIS_OSCURO, 1.6),
            E(80, 44, 9, 6, BLANCO, GRIS_OSCURO, 1.4),
            R(102, 32, 32, 38, 2, "#bae6fd", AZUL_OSCURO, 1.6),
            L("M106 58 Q118 38 130 58", ROJO, 2.6),
            L("M108 58 Q118 43 128 58", AMARILLO, 2.2),
        ],
        "Hoja de guion gráfico dividida en tres viñetas visuales consecutivas sin texto.")
    put("striped", "D",
        fondo_sala() + [
            R(44, 24, 72, 54, 6, BLANCO, AZUL_OSCURO, 2.2),
            R(46, 29, 68, 8, 1, AZUL),
            R(46, 45, 68, 8, 1, AZUL),
            R(46, 61, 68, 8, 1, AZUL),
        ],
        "Tela blanca decorada con rayas azules horizontales bien definidas.")
    put("stripes", "D",
        fondo_mesa() + [
            R(34, 22, 92, 56, 4, BLANCO, GRIS_OSCURO, 2.2),
            R(40, 24, 14, 52, 1, ROJO),
            R(62, 24, 14, 52, 1, AMARILLO),
            R(84, 24, 14, 52, 1, AZUL),
            R(106, 24, 14, 52, 1, VERDE),
        ],
        "Lámina de rayas verticales de colores brillantes paralelas entre sí.")
    put("town square", "D",
        fondo_prado() + [
            R(28, 52, 104, 34, 4, "#e2e8f0", GRIS_OSCURO, 2.0),
            P([(30, 38), (44, 24), (58, 38)], ROJO, ROJO_OSCURO, 1.6),
            R(32, 38, 24, 18, 1, "#fef3c7", BARRO, 1.6),
            P([(102, 38), (116, 24), (130, 38)], NARANJA, BARRO, 1.6),
            R(104, 38, 24, 18, 1, "#fde68a", BARRO, 1.6),
            E(80, 68, 14, 8, AGUA, AZUL_OSCURO, 1.8),
            L("M80 66 Q72 52 66 60 M80 66 Q88 52 94 60", BLANCO, 2.0),
        ],
        "Plaza amplia empedrada con casas alrededor y una fuente central.")
    put("tree rings", "D",
        fondo_prado() + [
            E(80, 52, 36, 28, BARRO, "#451a03", 2.4),
            E(80, 50, 32, 24, "#fde68a", MADERA_OSCURA, 1.8),
            E(80, 50, 24, 18, None, MADERA, 1.6),
            E(80, 50, 16, 12, None, MADERA_OSCURA, 1.6),
            E(80, 50, 8, 6, None, BARRO, 1.5),
            E(80, 50, 2.5, 2.5, BARRO),
        ],
        "Corte transversal de tronco mostrando los anillos concéntricos de crecimiento.")
    put("wavy", "D",
        fondo_cielo() + [
            L("M24 34 Q42 18 60 34 Q78 50 96 34 Q116 18 136 34", AZUL, 4.2),
            L("M24 52 Q42 36 60 52 Q78 68 96 52 Q116 36 136 52", AGUA_OSCURO, 4.2),
            L("M24 70 Q42 54 60 70 Q78 86 96 70 Q116 54 136 70", MORADO, 4.2),
        ],
        "Tres líneas curvas onduladas paralelas cruzando el lienzo.")
    put("wavy-edged", "D",
        fondo_prado() + [
            F(
                "M42 54 Q46 34 58 38 Q66 22 80 28 Q94 22 102 38 "
                "Q116 34 120 52 Q112 68 98 62 Q86 74 74 64 Q60 72 50 60 Z",
                VERDE, VERDE_OSCURO, 2.4,
            ),
            L("M34 56 L108 46", VERDE_OSCURO, 2.2),
            E(66, 26, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.4),
            E(94, 26, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.4),
        ],
        "Hoja de borde ondulado con sus ondas destacadas en amarillo.")
    put("we cut a cross so it doesn't pop", "C",
        fondo_mesa() + [
            E(64, 54, 24, 20, "#7c2d12", "#451a03", 2.2),
            L("M52 46 L76 62 M76 46 L52 62", "#fef3c7", 3.4),
        ] + fl("Chestnut", 94, 34, 42),
        "Castaña marcada con un corte en cruz para asarla sin que explote.")
    put("when the sun shines through the rain, we see a rainbow", "D",
        fondo_cielo() + sol(34, 26) + [
            E(56, 30, 14, 9, NUBE, NUBE_B, 1.8),
        ] + gotas([(48, 46), (56, 54), (64, 48)]) + [
            L("M68 78 Q104 20 142 78", ROJO, 4.0),
            L("M73 78 Q104 28 137 78", AMARILLO, 3.6),
            L("M78 78 Q104 36 132 78", AGUA_OSCURO, 3.4),
        ],
        "Sol brillando a través de la lluvia formando un gran arcoíris en el cielo.")
    put("zigzag", "D",
        fondo_mesa() + [
            L("M24 68 L48 30 L72 68 L96 30 L120 68 L138 36", NARANJA, 5.2),
            E(24, 68, 4, 4, ROJO), E(138, 36, 4, 4, ROJO),
        ],
        "Trazo continuo en zigzag con ángulos marcados de punta a punta.")

    # ── 2. Cierre de `show_gesture` (36 escenas) ───────────────────────────
    put("blue and yellow", "D",
        fondo_mesa() + [
            R(36, 34, 34, 34, 6, AZUL, AZUL_OSCURO, 2.4),
            E(108, 51, 18, 18, AMARILLO, AMARILLO_OSCURO, 2.4),
        ],
        "Un bloque azul y una esfera amarilla mostrados uno junto al otro.")
    put("brush head", "D",
        fondo_sala() + [
            L("M20 74 L92 48", AZUL_OSCURO, 8.0),
            R(86, 34, 40, 14, 5, AZUL, AZUL_OSCURO, 2.2),
            R(90, 20, 32, 15, 3, BLANCO, GRIS_OSCURO, 1.8),
            L("M98 20 L98 34 M106 20 L106 34 M114 20 L114 34", AGUA_OSCURO, 1.6),
            E(106, 32, 24, 20, None, ROJO, 2.0),
        ],
        "Detalle ampliado de la cabeza y cerdas de un cepillo de dientes.")
    put("carrots and cucumbers", "C",
        fondo_mesa() + fl("Carrot", 28, 22, 48) + fl("Cucumber", 86, 24, 48),
        "Zanahoria naranja y pepino verde mostrados juntos sobre la mesa.")
    put("clean beach", "D",
        fondo_mar() + sol(136, 20) + [
            F("M0 64 Q80 56 160 66 L160 100 L0 100 Z", "#fde68a", TIERRA_CLARA, 1.8),
            E(56, 78, 8, 6, "#f9a8d4", ROSA_OSCURO, 1.6),
            L("M50 78 L62 78 M56 72 L56 82", ROSA_OSCURO, 1.2),
            F("M108 32 L112 24 L116 32 L124 36 L116 40 L112 48 L108 40 L100 36 Z", BLANCO),
        ],
        "Playa de arena dorada reluciente y limpia junto al mar azul.")
    put("clean face", "D",
        fondo_sala() + [
            E(58, 50, 24, 24, PEL, PELB, 2.4),
            F("M34 46 C36 20 80 20 82 46 C70 32 46 32 34 46 Z", BARRO),
            E(50, 48, 2.4, 3.0, TINTA), E(66, 48, 2.4, 3.0, TINTA),
            L("M50 60 Q58 67 66 60", "#9a3412", 2.0),
            E(114, 50, 20, 26, "#e0f2fe", GRIS_OSCURO, 2.8),
            L("M106 38 L122 54 M104 48 L116 60", BLANCO, 2.0),
        ],
        "Cara limpia y sonriente reflejada junto a un espejo reluciente.")
    put("dressed up", "C",
        fondo_sala() + [
            P([(62, 48), (42, 86), (94, 86), (86, 48)], MORADO, AZUL_OSCURO, 2.0),
        ] + nino_busto(76, 42, (ROJO, ROJO_OSCURO)) + fl("Crown", 62, 10, 28),
        "Niño disfrazado con capa morada y corona dorada.")
    put("emotion card", "D",
        fondo_mesa() + [
            R(26, 24, 48, 56, 6, BLANCO, GRIS_OSCURO, 2.2),
            E(50, 52, 16, 16, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(45, 49, 2, 2.5, TINTA), E(55, 49, 2, 2.5, TINTA),
            L("M44 57 Q50 63 56 57", TINTA, 2.0),
            R(86, 24, 48, 56, 6, BLANCO, GRIS_OSCURO, 2.2),
            E(110, 52, 16, 16, "#93c5fd", AZUL_OSCURO, 1.8),
            E(105, 49, 2, 2.5, TINTA), E(115, 49, 2, 2.5, TINTA),
            L("M104 60 Q110 55 116 60", TINTA, 2.0),
        ],
        "Dos tarjetas ilustradas con cara alegre y cara triste sin texto.")
    put("germ-free", "C",
        fondo_sala() + _mano_abierta(56, 54, 1.0, (AGUA, AZUL_OSCURO)) + [
            E(110, 48, 16, 16, VERDE, VERDE_OSCURO, 2.2),
            L("M102 48 L108 54 L119 42", BLANCO, 3.2),
        ] + pompas([(68, 28, 5), (82, 34, 4), (44, 30, 4)]) + fl("Soap", 82, 56, 30),
        "Mano limpia con burbujas de jabón y sello verde sin gérmenes.")
    put("glowing", "D",
        fondo_noite() + [
            E(80, 44, 32, 32, "#fef08a"),
            R(62, 68, 36, 12, 4, MADERA, MADERA_OSCURA, 2.0),
            P([(56, 52), (104, 52), (94, 24), (66, 24)], "#fde047", NARANJA_OSCURO, 2.2),
            L("M46 38 L34 32 M114 38 L126 32 M80 18 L80 8", AMARILLO, 2.6),
        ],
        "Lámpara encendida irradiando una luz cálida y luminosa.")
    put("golden brown", "D",
        fondo_cielo() + sol(30, 22) + _hoja(86, 54, 34, 20, "#d97706", "#78350f", -4.0) + [
            E(92, 46, 8, 5, "#fde047"),
        ],
        "Hoja otoñal de color marrón dorado brillando a la luz del sol.")
    put("group of five", "D",
        fondo_mesa() + _mano_abierta(48, 54, 1.15, (VERDE, VERDE_OSCURO)) + [
            E(104, 34, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            E(126, 34, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            E(94, 56, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            E(115, 56, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            E(136, 56, 8, 8, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Mano abierta con cinco dedos enseñando un grupo de cinco manzanas.")
    put("handmade", "D",
        fondo_mesa() + [
            R(40, 24, 80, 56, 4, "#fef3c7", BARRO, 2.0),
            F("M80 62 C64 52 62 36 74 36 C78 36 80 40 80 42 C80 40 82 36 86 36 C98 36 96 52 80 62 Z", ROJO, ROJO_OSCURO, 1.8),
        ] + _mano_indice(34, 62, 1, -1, (AZUL, AZUL_OSCURO)) + _mano_indice(126, 62, -1, -1, (ROSA, ROSA_OSCURO)),
        "Dos manos pegando y creando una manualidad de papel sobre la mesa.")
    put("hands and feet", "C",
        fondo_sala() + _mano_abierta(44, 52, 0.95) + _mano_abierta(74, 52, 0.95) + fl("Foot", 104, 30, 44),
        "Manos abiertas mostradas junto a los pies descalzos.")
    put("healthy snack", "C",
        fondo_mesa() + plato_prop(80, 62, 40) + fl("Red apple", 44, 24, 38) + fl("Carrot", 84, 26, 38),
        "Plato de merienda saludable con manzana fresca y zanahoria.")
    put("hold up high", "D",
        fondo_prado() + [
            L("M70 46 L58 18", PELB, 5.0), L("M70 46 L58 18", PEL, 2.8),
            L("M90 46 L102 18", PELB, 5.0), L("M90 46 L102 18", PEL, 2.8),
        ] + nino_busto(80, 44, (AMARILLO, AMARILLO_OSCURO)) + [
            E(80, 16, 12, 10, DORADO, NARANJA_OSCURO, 2.0),
            E(80, 16, 4, 4, "#fef08a"),
        ],
        "Niño levantando en lo alto un tesoro brillante para enseñarlo a todos.")
    put("matching", "D",
        fondo_mesa() + [
            R(36, 26, 30, 38, 12, AZUL, AZUL_OSCURO, 2.2),
            R(28, 38, 12, 18, 6, AZUL, AZUL_OSCURO, 2.0),
            R(34, 62, 34, 9, 3, "#bfdbfe", AZUL_OSCURO, 1.8),
            E(51, 42, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.3),
            R(94, 26, 30, 38, 12, AZUL, AZUL_OSCURO, 2.2),
            R(120, 38, 12, 18, 6, AZUL, AZUL_OSCURO, 2.0),
            R(92, 62, 34, 9, 3, "#bfdbfe", AZUL_OSCURO, 1.8),
            E(109, 42, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.3),
        ],
        "Dos manoplas azules exactamente iguales haciendo juego una con otra.")
    put("muscular", "D",
        fondo_sala() + [
            L("M69 54 L46 52 L44 34", PELB, 9.0), L("M69 54 L46 52 L44 34", PEL, 6.0),
            E(56, 48, 6.5, 5.5, PEL, PELB, 1.6),
            L("M91 54 L114 52 L116 34", PELB, 9.0), L("M91 54 L114 52 L116 34", PEL, 6.0),
            E(104, 48, 6.5, 5.5, PEL, PELB, 1.6),
        ] + nino_busto(80, 42, (VERDE, VERDE_OSCURO)),
        "Niño flexionando ambos brazos a la vez enseñando postura musculosa.")
    put("nappy time", "D",
        fondo_sala() + [
            R(28, 62, 104, 20, 6, "#bae6fd", AGUA_OSCURO, 2.0),
            F("M50 32 L110 32 L110 44 Q98 48 94 64 Q80 72 66 64 Q62 48 50 44 Z", BLANCO, GRIS_OSCURO, 2.2),
            R(46, 35, 14, 7, 2, AZUL, AZUL_OSCURO, 1.5),
            R(100, 35, 14, 7, 2, AZUL, AZUL_OSCURO, 1.5),
            L("M56 39 L104 39", "#93c5fd", 2.0),
        ],
        "Pañal blanco anatómico con pestañas azules sobre el cambiador.")
    put("neatly folded", "D",
        fondo_mesa() + [
            R(46, 52, 68, 16, 4, AZUL, AZUL_OSCURO, 2.0),
            R(48, 38, 64, 15, 4, "#fef08a", AMARILLO_OSCURO, 2.0),
            R(50, 24, 60, 15, 4, BLANCO, GRIS_OSCURO, 2.0),
        ],
        "Pila de pañuelos y ropa bien doblada con bordes rectos y ordenados.")
    put("one fish, two fish", "D",
        fondo_mar() + [
            E(40, 52, 14, 9, NARANJA, NARANJA_OSCURO, 1.8),
            P([(26, 52), (16, 44), (16, 60)], NARANJA, NARANJA_OSCURO, 1.8),
            E(48, 50, 2, 2, TINTA),
            L("M74 22 L74 80", BLANCO, 2.0),
            E(104, 40, 12, 8, AZUL, AZUL_OSCURO, 1.8),
            P([(92, 40), (84, 34), (84, 46)], AZUL, AZUL_OSCURO, 1.8),
            E(124, 64, 12, 8, AZUL, AZUL_OSCURO, 1.8),
            P([(112, 64), (104, 58), (104, 70)], AZUL, AZUL_OSCURO, 1.8),
        ],
        "Un pez naranja a la izquierda y dos peces azules nadando a la derecha.")
    put("one leaf, two leaves", "D",
        fondo_prado() + _hoja(42, 48, 18, 11, VERDE, VERDE_OSCURO) + [
            L("M76 20 L76 80", BLANCO, 2.0),
        ] + _hoja(104, 36, 16, 10, VERDE, VERDE_OSCURO) + _hoja(126, 58, 16, 10, HERBA, VERDE_OSCURO),
        "Una hoja verde a un lado y dos hojas verdes al otro lado.")
    put("plum", "D",
        fondo_mesa() + [
            E(80, 52, 22, 25, MORADO, "#4c1d95", 2.4),
            E(72, 44, 6, 10, "#c4b5fd"),
            L("M80 28 Q82 16 90 14", BARRO, 2.6),
            F("M82 22 Q96 14 102 24 Q92 30 82 22 Z", VERDE, VERDE_OSCURO, 1.8),
        ],
        "Ciruela morada madura con tallo y hojita verde sobre la mesa.")
    put("raisin", "D",
        fondo_mesa() + _mano_abierta(68, 56, 1.15, (VERDE, VERDE_OSCURO)) + [
            E(62, 48, 5, 4, "#4c1d95", NEGRO, 1.4),
            E(74, 52, 5, 4, "#4c1d95", NEGRO, 1.4),
            E(67, 58, 4.5, 3.8, "#581c87", NEGRO, 1.4),
        ],
        "Puñado pequeño de pasas oscuras y arrugadas en la palma de la mano.")
    put("red, orange and brown", "D",
        fondo_prado() + _hoja(36, 48, 18, 11, ROJO, ROJO_OSCURO)
        + _hoja(80, 48, 18, 11, NARANJA, NARANJA_OSCURO)
        + _hoja(124, 48, 18, 11, BARRO, NEGRO),
        "Tres hojas de otoño juntas: roja, naranja y marrón.")
    put("reddish", "D",
        fondo_cielo() + _hoja(80, 50, 32, 20, "#dc2626", ROJO_OSCURO, -4.0) + [
            E(68, 46, 10, 6, "#fca5a5"),
        ],
        "Hoja otoñal de intenso tono rojizo mostrada al aire.")
    put("russet", "D",
        fondo_cielo() + [
            F(
                "M44 68 L58 58 Q54 44 66 42 Q64 26 78 28 Q86 16 96 26 "
                "Q110 24 108 38 Q122 42 110 56 Q98 68 82 62 Q66 70 58 60 Z",
                "#b45309", "#7c2d12", 2.2,
            ),
            L("M44 68 L94 30", "#7c2d12", 2.0),
        ],
        "Hoja de roble de color cobrizo rojizo intenso de otoño.")
    put("sense of touch", "D",
        fondo_mesa() + _mano_abierta(46, 54, 1.0, (ROJO, ROJO_OSCURO)) + _mano_abierta(114, 54, 1.0, (AZUL, AZUL_OSCURO)) + [
            E(46, 30, 12, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(114, 30, 11, 13, BARRO, NEGRO, 1.8),
            L("M106 28 L122 28 M106 34 L122 34", "#fef3c7", 1.4),
        ],
        "Dos manos abiertas palpando algodón suave y piña rugosa para sentir el tacto.")
    put("show", "D",
        fondo_sala() + nino_busto(48, 42, (VERDE, VERDE_OSCURO)) + [
            R(66, 28, 40, 32, 3, BLANCO, AZUL_OSCURO, 2.0),
            E(86, 44, 8, 8, ROSA, ROSA_OSCURO, 1.4),
            E(86, 44, 3, 3, AMARILLO),
        ] + nino_busto(124, 48, (AZUL, AZUL_OSCURO), mira=-1),
        "Niño levantando y enseñando un dibujo de una flor a otro compañero.")
    put("silvery", "D",
        fondo_cielo() + [
            P([(38, 28), (118, 22), (124, 72), (44, 78)], "#cbd5e1", "#475569", 2.4),
            P([(48, 32), (82, 30), (62, 72), (48, 72)], "#f1f5f9"),
            F("M96 34 L100 24 L104 34 L114 38 L104 42 L100 52 L96 42 L86 38 Z", BLANCO),
        ],
        "Lámina brillante de papel plateado con reflejos metálicos claros.")
    put("sparkly", "D",
        fondo_noite() + [
            R(40, 22, 80, 56, 6, MORADO, BLANCO, 2.0),
        ] + [
            F(f"M{cx - 5} {cy} L{cx} {cy - 7} L{cx + 5} {cy} L{cx} {cy + 7} Z", col)
            for cx, cy, col in [(58, 38, AMARILLO), (88, 34, BLANCO), (104, 58, "#fde047"), (66, 62, "#7dd3fc")]
        ],
        "Tarjeta morada repleta de destellos y purpurina brillante.")
    put("spotless", "D",
        fondo_sala() + plato_prop(80, 54, 32) + [
            L("M58 46 L68 38 M64 52 L74 44", BLANCO, 2.4),
            F("M106 32 L110 22 L114 32 L124 36 L114 40 L110 50 L106 40 L96 36 Z", AMARILLO),
            F("M48 34 L51 28 L54 34 L60 37 L54 40 L51 46 L48 40 L42 37 Z", AMARILLO),
        ],
        "Plato blanco completamente limpio e impecable echando destellos.")
    put("teeth", "D",
        fondo_sala() + [
            E(80, 50, 34, 24, "#fda4af", ROJO_OSCURO, 2.4),
            E(80, 50, 26, 15, "#991b1b"),
            F("M56 46 Q80 42 104 46 L102 51 Q80 51 58 51 Z", BLANCO, GRIS_OSCURO, 1.4),
            F("M58 53 Q80 53 102 53 L100 59 Q80 62 60 59 Z", BLANCO, GRIS_OSCURO, 1.4),
            L("M66 45 L66 59 M75 44 L75 60 M85 44 L85 60 M94 45 L94 59", GRIS_OSCURO, 1.2),
        ],
        "Gran sonrisa abierta enseñando los dientes blancos alineados.")
    put("this card is for my grandma", "C",
        fondo_sala() + nino_busto(40, 48, (AZUL, AZUL_OSCURO)) + [
            R(60, 42, 26, 20, 2, BLANCO, ROJO_OSCURO, 1.8),
            E(73, 52, 4.5, 4.5, ROSA),
            R(100, 56, 30, 26, 7, MORADO, AZUL_OSCURO, 2.0),
        ] + fl("Old woman", 96, 20, 40),
        "Niño entregando con cariño una postal con flor a su abuela sonriente.")
    put("toy", "C",
        fondo_sala() + fl("Teddy bear", 36, 24, 44) + fl("Puzzle piece", 90, 28, 40),
        "Osito de peluche y pieza de puzle mostrados como juguetes.")
    put("vegetables", "C",
        fondo_mesa() + fl("Basket", 54, 40, 52) + fl("Carrot", 46, 18, 34) + fl("Broccoli", 74, 16, 34) + fl("Tomato", 96, 26, 30),
        "Cesta llena de verduras frescas: zanahoria, brócoli y tomate.")

    # ── 3. Cierre de `mouth_sing` (34 escenas) ─────────────────────────────
    put("baby spoon", "D",
        fondo_mesa() + [
            L("M34 72 L96 42", "#38bdf8", 7.0),
            E(108, 36, 18, 12, "#7dd3fc", AGUA_OSCURO, 2.2),
            E(108, 35, 11, 7, "#e0f2fe"),
        ],
        "Cucharita infantil de punta redondeada y suave sobre la mesa.")
    put("bread and cheese", "C",
        fondo_mesa() + plato_prop(80, 68, 44) + fl("Bread", 42, 24, 42) + fl("Cheese wedge", 84, 28, 40),
        "Rebanada de pan y cuña de queso servidas juntas en el plato.")
    put("bubble trail", "D",
        fondo_mar() + [
            E(42, 66, 16, 10, NARANJA, NARANJA_OSCURO, 2.0),
            P([(26, 66), (16, 56), (16, 76)], NARANJA, NARANJA_OSCURO, 2.0),
            E(50, 64, 2.2, 2.2, TINTA),
        ] + pompas([(64, 54, 3.5), (74, 44, 4.5), (86, 34, 5.5), (98, 22, 6.5)]),
        "Pez soltando un rastro ascendente de burbujas en el agua.")
    put("carol singers", "D",
        fondo_noite() + [
            R(118, 28, 6, 56, 2, NEGRO),
            E(121, 24, 10, 10, "#fef08a", AMARILLO_OSCURO, 2.0),
        ] + nino_busto(36, 44, (ROJO, ROJO_OSCURO)) + nino_busto(64, 46, (VERDE, VERDE_OSCURO)) + nino_busto(92, 44, (AZUL, AZUL_OSCURO))
        + notas_col([(48, 26), (78, 22)]),
        "Tres niños abrigados cantando villancicos juntos bajo la farola nocturna.")
    put("choir", "D",
        fondo_sala() + nino_busto(36, 46, (AZUL, AZUL_OSCURO)) + nino_busto(64, 46, (AZUL, AZUL_OSCURO))
        + nino_busto(92, 46, (AZUL, AZUL_OSCURO)) + nino_busto(120, 46, (AZUL, AZUL_OSCURO))
        + notas_col([(50, 26), (78, 20), (108, 26)]),
        "Cuatro niños en fila cantando al unísono en coro con notas musicales.")
    put("class song", "D",
        fondo_sala() + nino_busto(40, 46, (ROJO, ROJO_OSCURO), brazos_arriba=True)
        + nino_busto(80, 44, (VERDE, VERDE_OSCURO), brazos_arriba=True)
        + nino_busto(120, 46, (AMARILLO, AMARILLO_OSCURO), brazos_arriba=True)
        + notas_col([(60, 24), (102, 22)]),
        "Grupo de clase cantando con alegría y los brazos arriba.")
    put("croak", "C",
        fondo_mar() + [
            E(80, 74, 34, 10, HERBA, VERDE_OSCURO, 2.0),
        ] + fl("Frog", 54, 24, 48) + ondas_sonido(104, 40, VERDE_OSCURO, 1),
        "Rana sobre nenúfar croando con ondas de sonido.")
    put("crunch a carrot", "C",
        fondo_sala() + nino_busto(56, 44, (NARANJA, NARANJA_OSCURO)) + fl("Carrot", 80, 32, 40) + [
            E(78, 56, 2.5, 2.5, NARANJA_OSCURO), E(84, 62, 2, 2, NARANJA),
        ],
        "Niño mordiendo una zanahoria crujiente en trocitos.")
    put("daddy", "C",
        fondo_prado() + [
            R(44, 52, 24, 30, 5, VERDE, VERDE_OSCURO, 2.0),
            L("M68 58 L84 62", PELB, 5.0), L("M68 58 L84 62", PEL, 2.8),
        ] + fl("Man", 38, 18, 38) + nino_caminando(98, 32, -1, (AZUL, AZUL_OSCURO)),
        "Papá de cuerpo entero llevando de la mano a su hijo por el prado.")
    put("dialogue", "D",
        fondo_sala() + nino_busto(44, 46, (ROJO, ROJO_OSCURO), mira=1)
        + nino_busto(116, 46, (AZUL, AZUL_OSCURO), mira=-1) + [
            E(60, 24, 18, 11, BLANCO, ROJO_OSCURO, 1.8),
            E(60, 24, 2, 2, ROJO_OSCURO), E(54, 24, 2, 2, ROJO_OSCURO), E(66, 24, 2, 2, ROJO_OSCURO),
            E(100, 24, 18, 11, BLANCO, AZUL_OSCURO, 1.8),
            E(100, 24, 2, 2, AZUL_OSCURO), E(94, 24, 2, 2, AZUL_OSCURO), E(106, 24, 2, 2, AZUL_OSCURO),
        ],
        "Dos niños conversando por turnos con globos de diálogo vacíos sin texto.")
    put("give a speech", "C",
        fondo_sala() + nino_busto(80, 36, (AZUL, AZUL_OSCURO)) + [
            R(60, 56, 40, 28, 3, MADERA, MADERA_OSCURA, 2.0),
        ] + fl("Microphone", 88, 28, 30) + ondas_sonido(108, 38, AZUL_OSCURO, 1),
        "Niño hablando en público ante el micrófono sobre el atril.")
    put("glove puppet", "D",
        fondo_sala() + [
            R(68, 60, 22, 26, 4, PEL, PELB, 2.0),
            E(79, 44, 24, 18, VERDE, VERDE_OSCURO, 2.2),
            E(67, 28, 7, 7, VERDE, VERDE_OSCURO, 1.8),
            E(91, 28, 7, 7, VERDE, VERDE_OSCURO, 1.8),
            E(67, 28, 4, 4, BLANCO), E(67, 28, 2, 2, TINTA),
            E(91, 28, 4, 4, BLANCO), E(91, 28, 2, 2, TINTA),
            E(79, 49, 13, 6, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Títere de guante de rana verde redondeado colocado en la mano.")
    put("hoot, hoot", "C",
        fondo_noite() + [
            L("M30 74 L126 68", MADERA_OSCURA, 5.0),
        ] + fl("Owl", 54, 20, 48) + ondas_sonido(106, 36, AMARILLO, 1),
        "Búho posado en una rama nocturna haciendo su ulular.")
    put("hum along", "D",
        fondo_sala() + [
            E(72, 48, 22, 22, PEL, PELB, 2.2),
            F("M50 42 C52 18 92 18 94 42 C82 30 62 30 50 42 Z", BARRO),
            E(65, 46, 2.2, 2.6, TINTA), E(79, 46, 2.2, 2.6, TINTA),
            L("M66 57 Q72 60 78 57", "#9a3412", 2.0),
        ] + notas_col([(108, 38), (122, 28)], AZUL_OSCURO),
        "Rostro sonriente con los labios cerrados tarareando notas musicales.")
    put("lights off", "D",
        fondo_noite() + [
            L("M74 0 L74 16", GRIS, 2.4),
            R(68, 16, 12, 8, 2, GRIS, BLANCO, 1.4),
            E(74, 38, 16, 18, "#475569", GRIS, 2.2),
            L("M68 38 Q74 32 80 38", GRIS, 1.6),
            R(112, 46, 22, 30, 4, BLANCO, GRIS_OSCURO, 2.0),
            R(118, 58, 10, 12, 2, GRIS, GRIS_OSCURO, 1.6),
        ],
        "Bombilla apagada colgando a oscuras con el interruptor pulsado abajo.")
    put("napkin", "D",
        fondo_mesa() + plato_prop(72, 56, 28) + [
            P([(102, 74), (110, 34), (132, 40), (124, 74)], BLANCO, GRIS_OSCURO, 2.0),
            L("M110 42 L124 46 M108 54 L122 58", AZUL, 1.6),
        ],
        "Servilleta de tela limpia y doblada junto al plato en la mesa.")
    put("nursery rhyme", "C",
        fondo_sala() + fl("Open book", 34, 24, 52) + fl("Musical notes", 90, 22, 38),
        "Libro abierto de canciones infantiles acompañado de notas musicales.")
    put("oink, oink", "C",
        fondo_prado() + fl("Pig", 50, 24, 50) + ondas_sonido(104, 44, ROSA_OSCURO, 1),
        "Cerdito gruñendo con ondas de sonido sonoras.")
    put("old macdonald had a farm", "C",
        fondo_prado() + [
            P([(20, 44), (42, 24), (64, 44)], ROJO_OSCURO, NEGRO, 2.0),
            R(24, 44, 36, 28, 2, ROJO, ROJO_OSCURO, 2.0),
        ] + fl("Cow", 62, 34, 36) + fl("Duck", 100, 42, 32) + notas_col([(120, 24), (134, 32)], ROJO_OSCURO),
        "Granja con vaca, pato y notas musicales cantando la canción de la granja.")
    put("one more bite", "D",
        fondo_mesa() + [
            R(44, 58, 42, 18, 8, AZUL, AZUL_OSCURO, 2.0),
            L("M34 38 L78 52", GRIS_OSCURO, 3.0),
            E(82, 52, 9, 6, GRIS, GRIS_OSCURO, 1.6),
            E(82, 50, 6, 4, "#fbbf24"),
        ] + _mano_indice(122, 54, -1, -1, (VERDE, VERDE_OSCURO)),
        "Cuchara con un último bocado de comida junto al gesto de un dedo.")
    put("puppet", "D",
        fondo_sala() + [
            L("M66 10 L66 36 M94 10 L94 36", GRIS_OSCURO, 1.5),
            L("M58 10 L102 10", MADERA_OSCURA, 3.2),
            E(80, 32, 13, 13, PEL, PELB, 2.0),
            R(68, 45, 24, 24, 6, ROJO, ROJO_OSCURO, 2.0),
            L("M68 50 L54 44 M92 50 L106 44", ROJO, 4.0),
            L("M74 69 L72 84 M86 69 L88 84", AZUL_OSCURO, 4.0),
        ],
        "Marioneta simpática articulada suspendida de una cruceta con hilos.")
    put("robotic", "C",
        fondo_sala() + fl("Robot", 48, 22, 54) + ondas_sonido(108, 44, AZUL_OSCURO, 1),
        "Robot hablando con voz mecánica indicada por ondas rectangulares.")
    put("rumbly bus", "C",
        fondo_prado() + fl("Bus", 44, 24, 56) + [
            L("M34 34 L28 42 M34 52 L26 60", NARANJA_OSCURO, 2.2),
            L("M110 38 L118 46 M110 54 L120 62", NARANJA_OSCURO, 2.2),
        ],
        "Autobús amarillo vibrando y retumbando con líneas de movimiento.")
    put("silent", "D",
        fondo_sala() + [
            E(80, 46, 22, 22, PEL, PELB, 2.4),
            F("M58 40 C60 16 100 16 102 40 C90 28 70 28 58 40 Z", BARRO),
            E(72, 43, 2.4, 3.0, TINTA), E(88, 43, 2.4, 3.0, TINTA),
            E(80, 54, 3.2, 2.8, "#9a3412"),
            R(76.5, 48, 7, 22, 3.5, PEL, PELB, 2.0),
            E(82, 72, 9, 6, PEL, PELB, 1.8),
        ],
        "Rostro en calma con el dedo índice en los labios pidiendo silencio.")
    put("solo", "C",
        fondo_noite() + [
            P([(80, 8), (52, 86), (108, 86)], "#fef08a"),
        ] + nino_busto(76, 44, (ROJO, ROJO_OSCURO)) + fl("Studio microphone", 92, 32, 34) + notas_col([(50, 32), (114, 34)]),
        "Un solo niño iluminado por un foco cantando ante el micrófono.")
    put("spicy", "C",
        fondo_mesa() + fl("Hot pepper", 24, 24, 46) + ondas_calor(54, 28, ROJO) + nino_busto(110, 44, (NARANJA, NARANJA_OSCURO)) + [
            E(110, 50, 4, 3, ROJO, ROJO_OSCURO, 1.2),
        ] + _mano_abierta(136, 56, 0.75, (AZUL, AZUL_OSCURO)),
        "Guindilla picante roja echando calor junto a niño abanicándose la boca.")
    put("switch off", "D",
        fondo_sala() + [
            R(56, 22, 48, 56, 6, BLANCO, GRIS_OSCURO, 2.4),
            R(72, 34, 16, 32, 3, "#cbd5e1", GRIS_OSCURO, 2.0),
            R(74, 50, 12, 14, 2, "#475569", NEGRO, 1.6),
        ] + _mano_indice(118, 68, -1, -1, (AZUL, AZUL_OSCURO)),
        "Dedo apretando la parte inferior de un interruptor para apagar la luz.")
    put("taste a bit", "D",
        fondo_mesa() + nino_busto(54, 44, (VERDE, VERDE_OSCURO)) + [
            L("M66 56 L84 48", PELB, 4.8), L("M66 56 L84 48", PEL, 2.6),
            E(85, 47, 5, 5, ROJO, ROJO_OSCURO, 1.5),
        ] + plato_prop(118, 64, 24) + [
            E(112, 62, 5, 5, ROJO, ROJO_OSCURO, 1.3),
            E(124, 62, 5, 5, ROJO, ROJO_OSCURO, 1.3),
        ],
        "Niño acercando un trocito de fresa del plato a la boca para probar.")
    put("tasting spoon", "D",
        fondo_mesa() + [
            R(36, 48, 52, 32, 6, AZUL, AZUL_OSCURO, 2.2),
            R(30, 54, 8, 8, 2, AZUL_OSCURO), R(86, 54, 8, 8, 2, AZUL_OSCURO),
            L("M66 50 L114 26", MADERA_OSCURA, 4.2),
            E(64, 50, 9, 6, MADERA, MADERA_OSCURA, 1.8),
        ] + ondas_calor(50, 28, NARANJA_OSCURO),
        "Cuchara de madera de probar sobre una olla caliente echando vapor.")
    put("tidy-up song", "D",
        fondo_sala() + [
            R(78, 52, 46, 30, 4, MADERA, MADERA_OSCURA, 2.2),
            R(90, 44, 12, 12, 2, ROJO, ROJO_OSCURO, 1.6),
            R(104, 46, 12, 10, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
        ] + nino_busto(48, 44, (VERDE, VERDE_OSCURO)) + notas_col([(56, 24), (108, 22)], AZUL_OSCURO),
        "Niño guardando bloques en la caja de juguetes mientras canta la canción.")
    put("timer song", "C",
        fondo_sala() + fl("Hourglass done", 38, 22, 46) + fl("Toothbrush", 82, 26, 42) + notas_col([(120, 24), (132, 34)], AZUL_OSCURO),
        "Reloj de arena junto al cepillo de dientes y notas para la canción de dos minutos.")
    put("whisper game", "D",
        fondo_sala() + nino_busto(54, 46, (MORADO, AZUL_OSCURO), mira=1)
        + nino_busto(102, 46, (AMARILLO, AMARILLO_OSCURO), mira=1) + [
            E(72, 48, 6, 4, PEL, PELB, 1.6),
            L("M74 44 Q82 40 88 44", AZUL_OSCURO, 1.6),
        ],
        "Niño ahuecando la mano para susurrar un secreto al oído de un amigo.")
    put("woof, woof", "C",
        fondo_prado() + fl("Dog", 48, 24, 52) + ondas_sonido(104, 44, BARRO, 1),
        "Perro simpático ladrando con ondas sonoras visibles.")

    # ── 4. Cierre de `count_fingers` (60 escenas) ──────────────────────────
    put("beak", "D",
        fondo_prado() + [
            E(62, 52, 22, 18, AZUL, AZUL_OSCURO, 2.2),
            E(68, 46, 3.2, 3.6, BLANCO), E(69, 46, 1.6, 2.0, TINTA),
            P([(82, 44), (112, 50), (82, 58)], NARANJA, NARANJA_OSCURO, 2.2),
            E(96, 51, 20, 14, None, ROJO, 1.8),
        ],
        "Pájaro de perfil destacando claramente su pico naranja afilado.")
    put("bird bath", "C",
        fondo_prado() + [
            R(72, 52, 16, 34, 3, GRIS, GRIS_OSCURO, 2.0),
            E(80, 50, 34, 10, "#cbd5e1", GRIS_OSCURO, 2.2),
            E(80, 49, 26, 6, AGUA, AGUA_OSCURO, 1.4),
        ] + fl("Bird", 60, 16, 36) + gotas([(84, 34), (96, 38)]),
        "Bebedero de piedra lleno de agua en el jardín con un pájaro refrescándose.")
    put("clover", "D",
        fondo_prado() + [
            L("M80 54 L80 82", VERDE_OSCURO, 3.0),
            E(80, 34, 13, 13, VERDE, VERDE_OSCURO, 2.0),
            E(64, 50, 13, 13, VERDE, VERDE_OSCURO, 2.0),
            E(96, 50, 13, 13, VERDE, VERDE_OSCURO, 2.0),
            E(80, 48, 5, 5, HERBA),
        ],
        "Trébol verde fresco de tres hojas redondeadas sobre la hierba.")
    put("count coins", "C",
        fondo_mesa() + _mano_indice(36, 60, 1, -1, (VERDE, VERDE_OSCURO))
        + fl("Coin", 58, 30, 26) + fl("Coin", 86, 30, 26) + fl("Coin", 114, 30, 26),
        "Dedo contando tres monedas doradas alineadas sobre la mesa.")
    put("count petals", "D",
        fondo_prado() + [
            L("M74 52 L74 84", VERDE_OSCURO, 2.8),
            E(74, 24, 9, 12, BLANCO, GRIS_OSCURO, 1.8),
            E(94, 38, 12, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(88, 60, 10, 10, BLANCO, GRIS_OSCURO, 1.8),
            E(60, 60, 10, 10, BLANCO, GRIS_OSCURO, 1.8),
            E(54, 38, 12, 9, BLANCO, GRIS_OSCURO, 1.8),
            E(74, 44, 10, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
        ] + _mano_indice(116, 54, -1, -1, (ROSA, ROSA_OSCURO)),
        "Dedo señalando los pétalos blancos de una margarita para contarlos.")
    put("count rings", "D",
        fondo_prado() + [
            R(44, 50, 68, 34, 4, BARRO, "#451a03", 2.0),
            E(78, 50, 34, 16, "#fde68a", MADERA_OSCURA, 2.0),
            E(78, 50, 24, 11, None, MADERA, 1.6),
            E(78, 50, 14, 6, None, BARRO, 1.6),
        ] + _mano_indice(118, 62, -1, -1, (AZUL, AZUL_OSCURO)),
        "Dedo señalando y contando los anillos de crecimiento de un tocón.")
    put("count votes", "D",
        fondo_sala() + nino_busto(36, 48, (ROJO, ROJO_OSCURO), brazos_arriba=True)
        + nino_busto(70, 48, (AZUL, AZUL_OSCURO), brazos_arriba=True)
        + nino_busto(104, 48, (VERDE, VERDE_OSCURO), brazos_arriba=True)
        + _mano_indice(132, 58, -1, -1, (MORADO, AZUL_OSCURO)),
        "Tres niños levantando las manos mientras otro cuenta los votos.")
    put("creep up", "D",
        fondo_sala() + [
            R(36, 52, 76, 16, 8, PEL, PELB, 2.0),
            R(32, 50, 14, 20, 4, AZUL, AZUL_OSCURO, 2.0),
            E(66, 48, 5, 4, ROJO, NEGRO, 1.5),
            E(66, 47, 1.5, 1.5, NEGRO),
        ] + frecha((54, 42), (96, 42), VERDE_OSCURO, 2.6),
        "Mariquita pequeña subiendo despacio a lo largo de un brazo.")
    put("crumbly", "D",
        fondo_mesa() + [
            R(60, 30, 36, 22, 6, TIERRA_CLARA, BARRO, 2.0),
            E(70, 62, 4, 3, BARRO), E(82, 66, 3.5, 3.5, TIERRA),
            E(62, 72, 3, 2.5, TIERRA_CLARA), E(92, 74, 4, 3, BARRO),
        ] + _mano_indice(44, 44, 1, 0, (VERDE, VERDE_OSCURO)),
        "Terrón seco de tierra desmenuzándose en miguitas sobre la mesa.")
    put("cut out", "C",
        fondo_mesa() + [
            R(34, 22, 68, 56, 3, BLANCO, GRIS_OSCURO, 2.0),
            P([(68, 30), (86, 66), (50, 66)], "#fde047", AZUL_OSCURO, 2.0),
        ] + fl("Scissors", 96, 36, 42),
        "Tijeras recortando una figura triangular amarilla de una hoja de papel.")
    put("delicate", "D",
        fondo_prado() + [
            E(80, 44, 16, 16, "#e0f2fe", AGUA_OSCURO, 1.8),
            E(74, 38, 4, 3, BLANCO),
        ] + _mano_indice(46, 54, 1, -1, (ROSA, ROSA_OSCURO)) + _mano_indice(114, 54, -1, -1, (ROSA, ROSA_OSCURO)),
        "Dos manos sujetando con suma suavidad una frágil pompa transparente.")
    put("dozen", "D",
        fondo_mesa() + [
            R(28, 30, 104, 42, 5, "#d6d3d1", GRIS_OSCURO, 2.2),
        ] + [
            E(40 + c * 16, 42 + r * 18, 6.2, 7.2, "#fef3c7", TIERRA_CLARA, 1.6)
            for r in range(2) for c in range(6)
        ],
        "Huevera completa con exactamente doce huevos colocados en dos filas de seis.")
    put("fall as rain", "D",
        fondo_cielo() + [
            E(64, 28, 22, 13, NUBE, NUBE_B, 2.0),
            E(96, 28, 20, 12, NUBE, NUBE_B, 2.0),
            E(80, 22, 24, 15, NUBE, NUBE_B, 2.0),
        ] + gotas([(54, 50), (72, 56), (90, 50), (108, 56), (64, 72), (82, 76), (100, 72)]),
        "Nube de lluvia soltando gotas de agua que caen hacia el suelo.")
    put("fishing net", "D",
        fondo_mar() + [
            L("M30 78 L72 48", MADERA_OSCURA, 4.0),
            E(94, 42, 26, 12, None, ROJO_OSCURO, 2.6),
            F("M68 42 L78 72 Q94 78 110 72 L120 42 Z", "#e2e8f0", GRIS_OSCURO, 1.8),
            L("M74 52 L114 52 M78 62 L110 62 M84 44 L86 74 M104 44 L102 74", GRIS_OSCURO, 1.4),
        ],
        "Salabre o red de pesca con mango de madera y malla entrecruzada.")
    put("four-sided", "D",
        fondo_mesa() + [
            P([(48, 30), (112, 24), (122, 70), (38, 76)], "#dcfce7", VERDE_OSCURO, 3.2),
            E(48, 30, 4, 4, ROJO), E(112, 24, 4, 4, ROJO),
            E(122, 70, 4, 4, ROJO), E(38, 76, 4, 4, ROJO),
        ],
        "Polígono cuadrilátero verde con sus cuatro lados y cuatro esquinas marcadas.")
    put("friendship", "D",
        fondo_prado() + nino_caminando(58, 26, 1, (ROJO, ROJO_OSCURO))
        + nino_caminando(102, 26, -1, (AZUL, AZUL_OSCURO)) + [
            L("M66 46 L94 46", PELB, 5.2), L("M66 46 L94 46", PEL, 3.0),
        ],
        "Dos amigos caminando juntos cogidos de la mano con alegría.")
    put("hexagon", "D",
        fondo_mesa() + [
            P([(80, 20), (108, 34), (108, 66), (80, 80), (52, 66), (52, 34)], "#fef08a", NARANJA_OSCURO, 3.2),
            E(80, 20, 3.5, 3.5, ROJO), E(108, 34, 3.5, 3.5, ROJO), E(108, 66, 3.5, 3.5, ROJO),
            E(80, 80, 3.5, 3.5, ROJO), E(52, 66, 3.5, 3.5, ROJO), E(52, 34, 3.5, 3.5, ROJO),
        ],
        "Hexágono regular dorado con sus seis lados y seis vértices bien visibles.")
    put("horns", "D",
        fondo_prado() + [
            L("M64 42 Q40 24 44 12", "#fef3c7", 6.5),
            L("M64 42 Q40 24 44 12", BARRO, 2.2),
            L("M96 42 Q120 24 116 12", "#fef3c7", 6.5),
            L("M96 42 Q120 24 116 12", BARRO, 2.2),
            E(80, 56, 20, 18, BARRO, "#451a03", 2.2),
            E(72, 52, 2.5, 3, BLANCO), E(88, 52, 2.5, 3, BLANCO),
            E(80, 64, 12, 7, "#fca5a5", ROJO_OSCURO, 1.6),
        ],
        "Cabeza de vaca con dos grandes cuernos curvos bien visibles.")
    put("hot", "D",
        fondo_mesa() + [
            R(44, 52, 48, 24, 6, ROJO, ROJO_OSCURO, 2.2),
            R(38, 48, 60, 6, 3, ROJO_OSCURO),
        ] + ondas_calor(56, 32, ROJO) + _mano_abierta(122, 54, 0.9, (AMARILLO, AMARILLO_OSCURO)),
        "Cuenco caliente soltando ondas rojas de calor junto a la mano.")
    put("ladybird spots", "D",
        fondo_prado() + [
            E(80, 52, 26, 24, ROJO, NEGRO, 2.4),
            E(80, 28, 12, 9, NEGRO),
            L("M80 34 L80 76", NEGRO, 2.4),
            E(68, 44, 4.5, 4.5, NEGRO), E(64, 58, 4, 4, NEGRO), E(72, 66, 3.5, 3.5, NEGRO),
            E(92, 44, 4.5, 4.5, NEGRO), E(96, 58, 4, 4, NEGRO), E(88, 66, 3.5, 3.5, NEGRO),
        ],
        "Mariquita roja vista desde arriba mostrando bien sus puntos negros.")
    put("long-legged", "D",
        fondo_prado() + [
            L("M74 42 L70 86 M86 42 L94 86", NARANJA_OSCURO, 3.2),
            E(80, 34, 18, 11, ROSA, ROSA_OSCURO, 2.0),
            L("M94 30 Q106 16 112 18", ROSA, 4.2),
            E(114, 18, 5, 5, ROSA, ROSA_OSCURO, 1.6),
            P([(118, 18), (124, 21), (118, 22)], NEGRO),
        ],
        "Flamenco de patas muy largas y delgadas de pie en la orilla.")
    put("measure a leaf", "C",
        fondo_mesa() + _hoja(80, 38, 36, 14, VERDE, VERDE_OSCURO) + fl("Straight ruler", 44, 42, 46),
        "Hoja verde colocada junto a una regla para medir su longitud.")
    put("meow", "C",
        fondo_sala() + fl("Cat", 48, 24, 52) + ondas_sonido(104, 42, MORADO, 1),
        "Gato maullando suavemente con ondas de sonido.")
    put("microplastic", "C",
        fondo_mar() + fl("Magnifying glass tilted left", 54, 22, 56) + [
            E(72, 40, 12, 12, "#e0f2fe"),
            E(68, 37, 2.5, 2, ROJO), E(76, 35, 2, 2, AMARILLO),
            E(70, 44, 2.8, 1.8, MORADO), E(78, 43, 2, 2, VERDE),
        ],
        "Lupa observando diminutos trocitos de microplástico de colores en el agua.")
    put("moo", "C",
        fondo_prado() + fl("Cow", 48, 24, 52) + ondas_sonido(106, 44, BARRO, 1),
        "Vaca mugiendo en el prado con ondas sonoras visibles.")
    put("mussels grow on ropes under the raft", "D",
        fondo_mar() + [
            R(26, 26, 108, 10, 2, MADERA, MADERA_OSCURA, 2.2),
            L("M24 38 L136 38", AGUA_OSCURO, 2.6),
        ] + [
            L(f"M{rx} 36 L{rx} 82", BARRO, 2.4) for rx in (44, 68, 92, 116)
        ] + [
            E(rx + dx, ry, 5, 3.5, "#1e293b", AZUL_OSCURO, 1.2)
            for rx in (44, 68, 92, 116)
            for ry, dx in [(46, -3), (54, 3), (62, -3), (70, 3), (78, -2)]
        ],
        "Batea gallega flotando en el mar con cuerdas llenas de mejillones bajo el agua.")
    put("one, two, toes", "D",
        fondo_sala() + [
            F("M54 50 Q52 34 62 34 Q74 34 86 42 Q90 56 84 74 Q70 84 60 72 Z", PEL, PELB, 2.2),
            E(58, 32, 4.5, 5.5, PEL, PELB, 1.6),
            E(66, 31, 3.8, 4.5, PEL, PELB, 1.6),
            E(74, 33, 3.5, 4.0, PEL, PELB, 1.6),
            E(81, 37, 3.2, 3.8, PEL, PELB, 1.6),
            E(87, 42, 2.8, 3.2, PEL, PELB, 1.6),
        ] + _mano_indice(112, 46, -1, -1, (ROSA, ROSA_OSCURO)),
        "Dedo tocando y contando suavemente los deditos de un pie descalzo.")
    put("pair", "D",
        fondo_sala() + [
            R(34, 54, 36, 18, 7, ROJO, ROJO_OSCURO, 2.2),
            R(34, 40, 22, 18, 5, ROJO, ROJO_OSCURO, 2.0),
            R(32, 70, 40, 5, 2, BLANCO, GRIS_OSCURO, 1.5),
            R(90, 54, 36, 18, 7, ROJO, ROJO_OSCURO, 2.2),
            R(90, 40, 22, 18, 5, ROJO, ROJO_OSCURO, 2.0),
            R(88, 70, 40, 5, 2, BLANCO, GRIS_OSCURO, 1.5),
        ],
        "Pareja de dos zapatos rojos iguales colocados uno junto al otro.")
    put("peas", "D",
        fondo_mesa() + [
            F("M30 56 Q80 28 130 52 Q80 78 30 56 Z", VERDE_OSCURO, NEGRO, 2.2),
            E(52, 52, 7, 7, "#86efac", VERDE_OSCURO, 1.6),
            E(70, 50, 7.5, 7.5, "#86efac", VERDE_OSCURO, 1.6),
            E(88, 50, 7.5, 7.5, "#86efac", VERDE_OSCURO, 1.6),
            E(106, 52, 7, 7, "#86efac", VERDE_OSCURO, 1.6),
        ],
        "Vaina verde abierta mostrando cuatro guisantes redondos en fila.")
    put("peck", "D",
        fondo_prado() + [
            E(66, 46, 18, 14, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(84, 54, 10, 9, AMARILLO, AMARILLO_OSCURO, 2.0),
            P([(92, 54), (104, 62), (90, 62)], NARANJA, NARANJA_OSCURO, 1.8),
            E(87, 52, 2, 2, TINTA),
            L("M62 60 L60 72 M72 60 L74 72", NARANJA_OSCURO, 2.4),
            E(108, 66, 3, 2, TIERRA_CLARA), E(116, 68, 3, 2, TIERRA_CLARA),
        ],
        "Pollito amarillo inclinando el pico para picotear granos en el suelo.")
    put("peek", "D",
        fondo_sala() + [
            R(38, 26, 84, 52, 6, AZUL, AZUL_OSCURO, 2.2),
            E(80, 52, 22, 16, PEL, PELB, 2.0),
            E(73, 52, 4, 4.5, BLANCO), E(73, 52, 2.2, 2.5, TINTA),
            E(87, 52, 4, 4.5, BLANCO), E(87, 52, 2.2, 2.5, TINTA),
        ],
        "Ojos curiosos asomándose a espiar por un agujero circular.")
    put("peek out", "D",
        fondo_prado() + [
            E(52, 46, 5, 6, BARRO, "#451a03", 1.5),
            E(64, 58, 17, 15, TIERRA_CLARA, BARRO, 2.0),
            E(56, 56, 2.2, 2.6, TINTA), E(66, 56, 2.2, 2.6, TINTA),
            E(52, 62, 3, 2.2, NEGRO),
            E(104, 56, 28, 22, HERBA, VERDE_OSCURO, 2.2),
            E(86, 62, 20, 16, VERDE, VERDE_OSCURO, 2.0),
        ],
        "Animalito curioso con orejas asomando detrás de un arbusto verde.")
    put("peel", "C",
        fondo_mesa() + fl("Chestnut", 52, 26, 46) + _mano_indice(116, 56, -1, -1, (ROJO, ROJO_OSCURO)) + [
            F("M48 64 Q64 78 86 68 Q74 58 60 62 Z", BARRO, "#451a03", 1.8),
        ],
        "Puntas de los dedos pelando la cáscara marrón de una castaña.")
    put("petal count", "D",
        fondo_prado() + [
            L("M80 56 L80 86", VERDE_OSCURO, 2.8),
            E(80, 26, 9, 12, ROSA, ROSA_OSCURO, 1.8),
            E(100, 40, 12, 9, ROSA, ROSA_OSCURO, 1.8),
            E(92, 62, 10, 10, ROSA, ROSA_OSCURO, 1.8),
            E(68, 62, 10, 10, ROSA, ROSA_OSCURO, 1.8),
            E(60, 40, 12, 9, ROSA, ROSA_OSCURO, 1.8),
            E(80, 46, 10, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
        ] + _mano_indice(34, 46, 1, -1, (AZUL, AZUL_OSCURO)),
        "Flor rosa de cinco pétalos señalados uno a uno para contarlos.")
    put("pinch", "D",
        fondo_mesa() + [
            R(50, 62, 60, 18, 8, AZUL, AZUL_OSCURO, 2.0),
            R(36, 22, 16, 12, 3, VERDE, VERDE_OSCURO, 1.8),
            E(58, 28, 10, 7, PEL, PELB, 1.8),
            L("M64 26 Q76 28 80 42 M62 34 Q72 42 78 44", PELB, 4.8),
            L("M64 26 Q76 28 80 42 M62 34 Q72 42 78 44", PEL, 2.8),
            E(79, 50, 2.2, 2.2, BLANCO), E(76, 56, 2, 2, BLANCO), E(82, 55, 2, 2, BLANCO),
        ],
        "Pulgar e índice pellizcando suavemente una pizca de sal sobre un cuenco.")
    put("primary colours", "D",
        fondo_mesa() + [
            E(42, 50, 16, 16, ROJO, ROJO_OSCURO, 2.2),
            E(80, 50, 16, 16, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(118, 50, 16, 16, AZUL, AZUL_OSCURO, 2.2),
        ],
        "Tres círculos con los colores primarios: rojo, amarillo y azul.")
    put("pulse", "D",
        fondo_sala() + [
            R(32, 48, 96, 20, 8, PEL, PELB, 2.2),
            L("M44 58 L64 58 L70 46 L76 68 L82 58 L112 58", ROJO, 2.4),
        ] + _mano_indice(90, 26, -1, 1, (VERDE, VERDE_OSCURO)),
        "Dos dedos sobre la muñeca notando el latido de la línea del pulso.")
    put("race", "D",
        fondo_prado() + [
            L("M118 28 L118 82", BLANCO, 3.4),
            R(116, 24, 4, 16, 1, ROJO),
        ] + nino_corriendo(44, 24, 1, (ROJO, ROJO_OSCURO)) + nino_corriendo(84, 28, 1, (AZUL, AZUL_OSCURO)),
        "Dos niños echando una carrera hacia la línea de meta blanca.")
    put("rectangle", "D",
        fondo_mesa() + [
            R(30, 30, 100, 40, 2, "#bbf7d0", VERDE_OSCURO, 3.4),
            E(30, 30, 3.5, 3.5, ROJO), E(130, 30, 3.5, 3.5, ROJO),
            E(30, 70, 3.5, 3.5, ROJO), E(130, 70, 3.5, 3.5, ROJO),
        ],
        "Rectángulo verde alargado con sus cuatro esquinas rectas bien marcadas.")
    put("roll the dice", "C",
        fondo_mesa() + fl("Game die", 78, 30, 40) + [
            L("M40 30 Q60 16 74 30", AZUL_OSCURO, 2.2),
        ] + _mano_abierta(42, 56, 0.9, (ROJO, ROJO_OSCURO)),
        "Mano lanzando un dado blanco sobre la mesa con arco de movimiento.")
    put("root", "D",
        fondo_cielo() + [
            R(0, 56, 160, 44, 0, TIERRA),
            L("M0 56 L160 56", HERBA, 5.0),
            L("M80 26 L80 56", VERDE_OSCURO, 3.0),
            E(72, 34, 7, 4, HERBA, VERDE_OSCURO, 1.5),
            E(88, 30, 7, 4, HERBA, VERDE_OSCURO, 1.5),
            L("M80 56 Q76 72 80 86 M80 64 Q64 70 58 84 M80 70 Q96 76 102 86", "#fef3c7", 2.6),
        ],
        "Planta verde con una raíz principal ramificada creciendo bajo tierra.")
    put("roots", "D",
        fondo_cielo() + [
            R(0, 54, 160, 46, 0, TIERRA),
            L("M0 54 L160 54", HERBA, 5.0),
            R(70, 18, 20, 36, 3, MADERA, MADERA_OSCURA, 2.2),
            E(80, 18, 24, 14, HERBA, VERDE_OSCURO, 2.0),
            L("M74 54 Q60 66 42 74 Q36 80 34 88 M78 54 Q70 70 58 84 M82 54 Q90 70 102 84 M86 54 Q100 66 118 74 Q124 80 126 88", "#fef3c7", 2.6),
        ],
        "Tronco de árbol extendiendo raíces orgánicas curvas bajo el suelo.")
    put("roots under the ground", "D",
        fondo_cielo() + [
            R(0, 50, 160, 50, 0, "#78350f"),
            L("M0 50 L160 50", HERBA, 6.0),
            L("M48 24 L48 50 M112 24 L112 50", VERDE_OSCURO, 2.8),
            E(48, 22, 8, 8, ROJO, ROJO_OSCURO, 1.6),
            E(112, 22, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.6),
            L("M48 50 Q42 66 36 78 M48 50 Q54 68 58 82 M112 50 Q104 66 98 80 M112 50 Q118 66 124 78", "#fde68a", 2.4),
        ],
        "Dos flores sobre el césped con sus raíces onduladas bajo la tierra oscura.")
    put("show small fingers", "D",
        fondo_sala() + _mano_abierta(56, 54, 0.9, (ROSA, ROSA_OSCURO)) + _mano_abierta(104, 54, 0.9, (ROSA, ROSA_OSCURO)),
        "Dos manitas pequeñas abiertas enseñando los diez deditos separados.")
    put("six-sided", "D",
        fondo_mesa() + [
            P([(80, 20), (108, 34), (108, 66), (80, 80), (52, 66), (52, 34)], "#bae6fd", AZUL_OSCURO, 3.2),
            L("M80 20 L108 34 M108 66 L80 80 M52 66 L52 34", ROJO, 3.6),
            L("M108 34 L108 66 M80 80 L52 66 M52 34 L80 20", AZUL, 3.6),
        ],
        "Figura de seis lados coloreados alternando segmentos para contarlos.")
    put("spice", "D",
        fondo_mesa() + [
            R(44, 56, 72, 22, 10, BLANCO, GRIS_OSCURO, 2.0),
            R(48, 52, 64, 8, 3, NARANJA, NARANJA_OSCURO, 1.6),
            E(74, 34, 2.5, 2.5, TIERRA), E(82, 40, 2.5, 2.5, ROJO_OSCURO), E(88, 32, 2.5, 2.5, TIERRA),
        ] + _mano_indice(98, 22, -1, 1, (VERDE, VERDE_OSCURO)),
        "Dedos espolvoreando especia molida aromática sobre un cuenco de comida.")
    put("stag beetle", "D",
        fondo_prado() + [
            E(80, 62, 14, 18, "#451a03", NEGRO, 2.2),
            E(80, 42, 10, 7, "#7c2d12", NEGRO, 2.0),
            L("M74 36 Q62 20 72 14 M86 36 Q98 20 88 14", "#9a3412", 3.2),
            L("M68 54 L54 48 M68 62 L52 62 M68 70 L56 76", NEGRO, 2.0),
            L("M92 54 L106 48 M92 62 L108 62 M92 70 L104 76", NEGRO, 2.0),
        ],
        "Escarabajo ciervo volante marrón oscuro con sus dos grandes cuernos.")
    put("stand on one leg", "D",
        fondo_prado() + nino(
            (80, 24), (80, 36), (80, 56),
            [[(60, 46)], [(100, 46)]],
            [[(80, 82)], [(96, 62), (88, 70)]],
            camisa=(AZUL, AZUL_OSCURO),
        ),
        "Niño manteniendo el equilibrio sobre una sola pierna con brazos abiertos.")
    put("steam", "D",
        fondo_sala() + [
            R(50, 54, 60, 28, 6, GRIS, GRIS_OSCURO, 2.2),
            R(44, 58, 8, 8, 2, GRIS_OSCURO), R(108, 58, 8, 8, 2, GRIS_OSCURO),
            E(66, 36, 9, 8, BLANCO, GRIS_OSCURO, 1.5),
            E(84, 28, 11, 9, BLANCO, GRIS_OSCURO, 1.5),
            E(76, 18, 9, 7, BLANCO, GRIS_OSCURO, 1.5),
        ],
        "Olla caliente soltando nubes blancas de vapor ascendente.")
    put("straw", "D",
        fondo_prado() + [
            L("M64 20 L52 78 M70 18 L64 80 M76 18 L74 80 M84 18 L86 80 M90 18 L96 80 M96 20 L108 78", TIERRA_CLARA, 4.0),
            L("M64 20 L52 78 M70 18 L64 80 M76 18 L74 80 M84 18 L86 80 M90 18 L96 80 M96 20 L108 78", "#fde047", 2.2),
            R(58, 48, 44, 7, 2, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Haz de tallos dorados de paja seca atados por el centro con una cinta.")
    put("strum", "C",
        fondo_sala() + fl("Guitar", 38, 16, 60) + _mano_abierta(94, 58, 0.85, (MORADO, AZUL_OSCURO)) + notas_col([(114, 34), (126, 24)], AZUL_OSCURO),
        "Mano rasgueando las cuerdas de una guitarra acompañada de notas musicales.")
    put("teeny", "D",
        fondo_mesa() + [
            E(50, 54, 22, 22, ROJO, ROJO_OSCURO, 2.2),
            L("M50 32 L54 24", BARRO, 2.4),
            E(112, 68, 3.5, 3.0, "#1e293b"),
            E(112, 68, 14, 14, None, VERDE_OSCURO, 1.6),
        ],
        "Insecto diminuto destacado con lupa al lado de una manzana grande.")
    put("ten little fingers", "D",
        fondo_sala() + _mano_abierta(52, 52, 1.1, (AMARILLO, AMARILLO_OSCURO)) + _mano_abierta(108, 52, 1.1, (AMARILLO, AMARILLO_OSCURO)),
        "Dos manos abiertas completas mostrando claramente sus diez dedos.")
    put("three little pigs", "C",
        fondo_prado() + fl("Pig", 22, 34, 38) + fl("Pig", 62, 34, 38) + fl("Pig", 102, 34, 38),
        "Tres cerditos rosados alineados uno junto al otro en el prado.")
    put("ticklish", "D",
        fondo_sala() + nino_busto(72, 44, (VERDE, VERDE_OSCURO), brazos_arriba=True) + [
            L("M116 28 Q104 40 94 52", AMARILLO_OSCURO, 2.4),
            E(112, 32, 9, 5, "#fde047", AMARILLO_OSCURO, 1.5),
            L("M48 34 L42 30 M46 42 L38 42", ROJO, 1.8),
        ],
        "Niño riendo encogido mientras una pluma suave le hace cosquillas.")
    put("tie", "D",
        fondo_sala() + [
            R(44, 50, 72, 26, 10, AZUL, AZUL_OSCURO, 2.2),
            R(42, 74, 76, 6, 2, BLANCO, GRIS_OSCURO, 1.6),
            E(68, 42, 10, 6, BLANCO, ROJO_OSCURO, 2.0),
            E(92, 42, 10, 6, BLANCO, ROJO_OSCURO, 2.0),
            E(80, 44, 4, 4, ROJO),
        ],
        "Zapatilla azul con los cordones recién atados en un lazo limpio.")
    put("tiny", "D",
        fondo_mesa() + [
            R(24, 42, 16, 14, 3, AZUL, AZUL_OSCURO, 1.8),
            E(46, 49, 10, 8, PEL, PELB, 1.8),
            L("M52 44 Q64 38 68 44 M52 54 Q64 58 68 50", PELB, 4.8),
            L("M52 44 Q64 38 68 44 M52 54 Q64 58 68 50", PEL, 2.8),
            E(74, 47, 2.8, 2.8, TIERRA_CLARA, BARRO, 1.4),
            E(74, 47, 13, 13, None, VERDE_OSCURO, 1.6),
        ],
        "Mano sujetando una semilla diminuta entre pulgar e índice.")
    put("tiny bits", "D",
        fondo_mesa() + [
            R(28, 28, 104, 48, 4, MADERA, MADERA_OSCURA, 2.0),
            E(52, 52, 14, 14, "#fde047", TIERRA_CLARA, 2.0),
            E(84, 44, 3.5, 3, "#fde047", TIERRA_CLARA, 1.2),
            E(98, 56, 3, 2.5, "#fde047", TIERRA_CLARA, 1.2),
            E(112, 46, 3.5, 3, "#fde047", TIERRA_CLARA, 1.2),
            E(92, 64, 2.8, 2.5, "#fde047", TIERRA_CLARA, 1.2),
            E(108, 62, 3, 2.5, "#fde047", TIERRA_CLARA, 1.2),
        ],
        "Galleta partida en trocitos y miguitas pequeñas sobre tabla de madera.")
    put("two apples, please", "C",
        fondo_mesa() + _mano_abierta(46, 56, 0.95, (AZUL, AZUL_OSCURO)) + fl("Red apple", 76, 30, 34) + fl("Red apple", 112, 30, 34),
        "Mano abierta extendida pidiendo con educación dos manzanas rojas.")
    put("up the arm", "D",
        fondo_sala() + [
            L("M36 72 L76 58 L112 28", PELB, 13.0),
            L("M36 72 L76 58 L112 28", PEL, 9.0),
            R(100, 18, 22, 18, 4, VERDE, VERDE_OSCURO, 2.0),
        ] + frecha((44, 58), (94, 34), ROJO, 2.6),
        "Flecha roja subiendo desde la mano a lo largo del brazo hacia el hombro.")

    # ── 5. Primer bloque de `body_touch` (30 escenas: `back`..`grassy`) ────
    put("back", "D",
        fondo_sala() + [
            R(74, 64, 6, 18, 2, AZUL_OSCURO), R(82, 64, 6, 18, 2, AZUL_OSCURO),
            R(68, 36, 24, 30, 7, VERDE, VERDE_OSCURO, 2.2),
            E(80, 24, 9, 9, BARRO, "#451a03", 2.0),
            L("M68 42 L58 52 L74 52", PEL, 3.0),
            L("M92 42 L102 52 L86 52", PEL, 3.0),
            E(80, 50, 9, 10, "#bbf7d0", VERDE_OSCURO, 1.4),
        ],
        "Niño visto de espaldas llevando ambas manos hacia su espalda.")
    put("beep", "C",
        fondo_prado() + fl("Bus", 36, 22, 48) + [
            E(108, 54, 16, 16, NEGRO, GRIS_OSCURO, 2.4),
            E(108, 54, 7, 7, ROJO, ROJO_OSCURO, 1.6),
        ] + ondas_sonido(84, 38, ROJO, 1),
        "Claxon rojo pulsado junto al autobús emitiendo pitido sonoro.")
    put("between your fingers too", "D",
        fondo_sala() + _mano_abierta(68, 54, 1.05, (AZUL, AZUL_OSCURO))
        + _mano_abierta(92, 54, 1.05, (ROJO, ROJO_OSCURO))
        + pompas([(72, 34, 3.8), (80, 38, 4.2), (88, 34, 3.8), (76, 46, 3.5), (84, 46, 3.5)]),
        "Dos manos entrelazadas con espuma limpiando entre los dedos.")
    put("body", "D",
        fondo_sala() + nino(
            (80, 20), (80, 32), (80, 54),
            [[(62, 44)], [(98, 44)]],
            [[(72, 82)], [(88, 82)]],
            camisa=(AZUL, AZUL_OSCURO),
        ),
        "Cuerpo humano completo de pie mostrando cabeza, tronco, brazos y piernas.")
    put("bones", "C",
        fondo_sala() + [
            R(28, 44, 104, 24, 10, PEL, PELB, 2.2),
            R(44, 46, 72, 20, 4, "#334155", NEGRO, 1.8),
        ] + fl("Bone", 56, 34, 46),
        "Antebrazo mostrando el hueso blanco en su interior como radiografía.")
    put("bonfire", "C",
        fondo_noite() + [
            L("M48 76 L92 64 M48 64 L92 76", MADERA_OSCURA, 5.5),
        ] + fl("Fire", 48, 22, 46) + _mano_abierta(118, 54, 0.9, (ROJO, ROJO_OSCURO)),
        "Hoguera cálida de troncos ardiendo con las manos acercándose al calor.")
    put("bony", "D",
        fondo_sala() + [
            R(62, 18, 16, 50, 5, PEL, PELB, 2.0),
            E(72, 72, 20, 9, PEL, PELB, 2.0),
            E(69, 62, 5, 5, "#fde68a", PELB, 1.6),
        ] + _mano_indice(104, 58, -1, 0, (AZUL, AZUL_OSCURO)),
        "Tobillo perfilado señalando con el dedo el hueso sobresaliente.")
    put("bumpy", "D",
        fondo_prado() + [
            F("M26 70 Q38 50 50 66 Q64 46 78 66 Q92 48 106 66 Q120 50 134 70 L134 82 L26 82 Z", MADERA, MADERA_OSCURA, 2.2),
        ] + _mano_abierta(80, 42, 0.95, (VERDE, VERDE_OSCURO)),
        "Mano palpando una superficie claramente rugosa de bultos y ondas.")
    put("burst", "D",
        fondo_cielo() + [
            E(68, 44, 16, 16, None, AGUA_OSCURO, 2.0),
            L("M52 34 L44 26 M84 34 L92 26 M52 54 L44 62 M84 54 L92 62", AGUA_OSCURO, 2.2),
        ] + gotas([(56, 26), (82, 24), (60, 62)]) + _mano_indice(108, 54, -1, -1, (ROJO, ROJO_OSCURO)),
        "Dedo tocando una pompa de jabón en el momento en que revienta.")
    put("cheeks", "D",
        fondo_sala() + [
            E(80, 48, 24, 24, PEL, PELB, 2.4),
            F("M56 42 C58 18 102 18 104 42 C92 30 68 30 56 42 Z", BARRO),
            E(72, 44, 2.4, 3.0, TINTA), E(88, 44, 2.4, 3.0, TINTA),
            E(66, 54, 6, 5, "#fda4af", ROSA_OSCURO, 1.4),
            E(94, 54, 6, 5, "#fda4af", ROSA_OSCURO, 1.4),
            L("M74 60 Q80 65 86 60", "#9a3412", 1.8),
        ] + _mano_indice(40, 62, 1, -1, (AZUL, AZUL_OSCURO)) + _mano_indice(120, 62, -1, -1, (AZUL, AZUL_OSCURO)),
        "Dos dedos tocando las mejillas sonrosadas e infladas de una cara.")
    put("chilly", "D",
        fondo_cielo() + [
            R(64, 44, 32, 34, 8, AZUL, AZUL_OSCURO, 2.0),
            R(70, 42, 20, 6, 3, ROJO, ROJO_OSCURO, 1.5),
            E(80, 30, 10, 10, PEL, PELB, 2.0),
            F("M70 28 C72 16 88 16 90 28 Z", BARRO),
            E(76, 30, 1.4, 1.8, TINTA), E(84, 30, 1.4, 1.8, TINTA),
            L("M64 48 L90 58", PELB, 5.2), L("M64 48 L90 58", PEL, 3.0),
            L("M96 48 L70 58", PELB, 5.2), L("M96 48 L70 58", PEL, 3.0),
        ] + lineas_viento(22, 42, 28, AGUA_OSCURO),
        "Niño abrigado frotándose los brazos ante la brisa fresca.")
    put("chin", "D",
        fondo_sala() + [
            E(80, 46, 24, 24, PEL, PELB, 2.4),
            F("M56 40 C58 16 102 16 104 40 C92 28 68 28 56 40 Z", BARRO),
            E(72, 42, 2.4, 3.0, TINTA), E(88, 42, 2.4, 3.0, TINTA),
            L("M74 52 Q80 57 86 52", "#9a3412", 1.8),
            E(80, 66, 6, 4, "#fed7aa", ROJO, 1.6),
        ] + _mano_indice(112, 74, -1, -1, (VERDE, VERDE_OSCURO)),
        "Dedo índice tocando directamente la barbilla bajo la boca.")
    put("chunky", "D",
        fondo_sala() + [
            L("M68 22 L80 14 L92 22", MADERA_OSCURA, 2.6),
            P([(52, 30), (32, 62), (46, 68), (56, 44)], ROJO, ROJO_OSCURO, 2.0),
            P([(108, 30), (128, 62), (114, 68), (104, 44)], ROJO, ROJO_OSCURO, 2.0),
            R(52, 28, 56, 50, 8, ROJO, ROJO_OSCURO, 2.2),
            E(80, 28, 12, 5, "#fca5a5", ROJO_OSCURO, 2.0),
            L("M66 40 Q62 50 66 60 Q70 70 66 74 M80 40 Q76 50 80 60 Q84 70 80 74 M94 40 Q90 50 94 60 Q98 70 94 74", "#fecaca", 2.2),
        ],
        "Jersey grueso de punto con trenzas de lana colgado en una percha.")
    put("cold and fresh", "C",
        fondo_mesa() + [
            R(30, 22, 56, 58, 4, "#e0f2fe", AZUL_OSCURO, 2.2),
            R(34, 52, 48, 4, 1, GRIS_OSCURO),
        ] + fl("Green apple", 44, 24, 34) + gotas([(84, 30), (96, 40), (104, 26)]),
        "Manzana verde fría y fresca recién sacada del frigorífico con gotitas.")
    put("colour by colour", "D",
        fondo_mesa() + [
            R(26, 44, 20, 20, 3, ROJO, ROJO_OSCURO, 1.8),
            R(54, 44, 20, 20, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(82, 44, 20, 20, 3, AZUL, AZUL_OSCURO, 1.8),
            R(110, 44, 20, 20, 3, VERDE, VERDE_OSCURO, 1.8),
        ] + _mano_indice(48, 76, -1, -1, (MORADO, AZUL_OSCURO)),
        "Cuatro bloques de colores distintos señalados uno tras otro por turnos.")
    put("damp", "D",
        fondo_sala() + [
            R(44, 26, 72, 48, 8, "#93c5fd", AZUL_OSCURO, 2.2),
            L("M44 46 L116 46", AZUL_OSCURO, 1.6),
        ] + gotas([(60, 40), (76, 54), (94, 40), (102, 60)]),
        "Tela o toalla azul húmeda cubierta de pequeñas gotas de humedad.")
    put("dewdrop", "D",
        fondo_prado() + [
            F("M34 80 Q50 32 82 22 Q68 58 64 80 Z", VERDE, VERDE_OSCURO, 2.2),
            F("M92 80 Q106 42 132 32 Q118 62 114 80 Z", HERBA, VERDE_OSCURO, 2.0),
            F("M84 26 Q94 40 84 48 Q74 40 84 26 Z", "#bae6fd", AGUA_OSCURO, 2.2),
            E(81, 38, 2.2, 3.2, BLANCO),
        ],
        "Gota cristalina de rocío colgando de la punta de una brizna de hierba.")
    put("dimple", "D",
        fondo_sala() + [
            E(80, 48, 24, 24, PEL, PELB, 2.4),
            F("M56 42 C58 18 102 18 104 42 C92 30 68 30 56 42 Z", BARRO),
            E(72, 44, 2.4, 3.0, TINTA), E(88, 44, 2.4, 3.0, TINTA),
            L("M72 56 Q80 62 88 56", "#9a3412", 1.8),
            L("M66 53 Q62 56 66 59 M94 53 Q98 56 94 59", "#9a3412", 2.0),
        ] + _mano_indice(116, 66, -1, -1, (ROSA, ROSA_OSCURO)),
        "Rostro sonriente señalando el hoyuelo marcado junto a la sonrisa.")
    put("discover", "C",
        fondo_sala() + bebe_sentado(46, 46, (AMARILLO, AMARILLO_OSCURO)) + fl("Basket", 76, 36, 48) + [
            E(96, 44, 6, 7, BARRO), E(108, 46, 5, 5, ROJO),
        ],
        "Bebé curioso descubriendo objetos naturales dentro de una cesta.")
    put("dot", "D",
        fondo_mesa() + [
            E(72, 46, 12, 12, AZUL, AZUL_OSCURO, 2.2),
        ] + _mano_indice(106, 64, -1, -1, (ROJO, ROJO_OSCURO)),
        "Dedo índice señalando un punto azul redondo bien definido.")
    put("ears and nose", "C",
        fondo_sala() + fl("Ear", 32, 24, 48) + fl("Nose", 84, 24, 48),
        "Oreja y nariz mostradas claramente una al lado de la otra.")
    put("elbow", "D",
        fondo_sala() + [
            L("M48 28 L48 56 L92 56", PELB, 14.0),
            L("M48 28 L48 56 L92 56", PEL, 10.0),
            E(48, 56, 10, 10, "#fed7aa", ROJO, 2.0),
        ] + _mano_indice(82, 74, -1, -1, (AZUL, AZUL_OSCURO)),
        "Brazo doblado en ángulo recto señalando claramente el codo.")
    put("feel", "D",
        fondo_mesa() + [
            R(28, 56, 104, 24, 4, MADERA, MADERA_OSCURA, 2.2),
            L("M34 64 L126 64 M38 72 L122 72", MADERA_OSCURA, 1.5),
        ] + _mano_abierta(80, 44, 1.0, (AZUL, AZUL_OSCURO)),
        "Palma de la mano abierta palpando la textura de la madera.")
    put("filling", "D",
        fondo_mesa() + [
            R(30, 56, 44, 20, 8, ROJO, ROJO_OSCURO, 2.0),
            E(52, 54, 20, 6, "#fde68a", TIERRA_CLARA, 1.5),
        ] + nino_busto(108, 42, (VERDE, VERDE_OSCURO)) + [
            E(108, 66, 10, 8, VERDE_OSCURO, NEGRO, 1.4),
        ],
        "Cuenco sustancioso de comida junto a niño tocando su barriga llena.")
    put("fingertip", "D",
        fondo_sala() + [
            L("M24 62 L68 48", PELB, 14.0), L("M24 62 L68 48", PEL, 10.0),
            E(74, 46, 5, 4, "#fecdd3", ROJO, 1.5),
            L("M132 58 L98 50", PELB, 9.0), L("M132 58 L98 50", PEL, 6.0),
            E(88, 48, 10, 10, None, ROJO, 1.8),
        ],
        "Yema de un dedo grande tocando con dulzura la punta del dedo pequeño.")
    put("front and back", "D",
        fondo_sala() + _mano_abierta(48, 54, 1.0, (AZUL, AZUL_OSCURO)) + [
            E(48, 54, 5, 5, "#fed7aa", PELB, 1.2),
            L("M80 20 L80 82", GRIS_OSCURO, 1.8),
        ] + _mano_abierta(112, 54, 1.0, (VERDE, VERDE_OSCURO)) + [
            R(106, 36, 4, 5, 1, BLANCO, GRIS_OSCURO, 1.0),
            R(110, 34, 4, 5, 1, BLANCO, GRIS_OSCURO, 1.0),
            R(114, 35, 4, 5, 1, BLANCO, GRIS_OSCURO, 1.0),
        ],
        "Dos manos enseñando la palma por delante y el dorso con uñas por detrás.")
    put("full up", "D",
        fondo_mesa() + plato_prop(46, 66, 22) + cuchara_prop(56, 48, 22)
        + nino_busto(106, 42, (AMARILLO, AMARILLO_OSCURO)) + [
            L("M94 52 L106 60 M118 52 L106 60", PEL, 3.0),
        ],
        "Plato limpio tras terminar de comer y niño satisfecho frotando la barriga.")
    put("germs", "D",
        fondo_sala() + _mano_abierta(52, 54, 1.05, (AZUL, AZUL_OSCURO)) + [
            E(50, 48, 4, 4, VERDE, VERDE_OSCURO, 1.3),
            E(58, 54, 3.5, 3.5, MORADO, NEGRO, 1.3),
            E(108, 46, 14, 14, "#dcfce7", VERDE_OSCURO, 2.0),
            E(108, 46, 7, 7, VERDE_OSCURO),
            L("M108 28 L108 64 M90 46 L126 46", VERDE_OSCURO, 2.0),
        ],
        "Gérmenes vistos bajo lupa sobre una mano para lavarlos bien.")
    put("glittery", "D",
        fondo_noite() + [
            R(36, 22, 88, 56, 5, ROSA, ROSA_OSCURO, 2.2),
        ] + [
            E(cx, cy, 2.8, 2.8, col)
            for cx, cy, col in [
                (52, 34, AMARILLO), (68, 46, BLANCO), (84, 32, "#7dd3fc"),
                (104, 42, AMARILLO), (58, 60, BLANCO), (78, 64, "#fde047"),
                (96, 58, BLANCO), (112, 66, "#7dd3fc"),
            ]
        ],
        "Cartulina rosa brillante cubierta de destellos de purpurina.")
    put("grassy", "D",
        fondo_prado() + [
            P([(30, 82), (38, 44), (46, 82)], HERBA, VERDE_OSCURO, 1.6),
            P([(50, 82), (60, 38), (70, 82)], VERDE, VERDE_OSCURO, 1.6),
            P([(74, 82), (82, 42), (90, 82)], HERBA, VERDE_OSCURO, 1.6),
            P([(94, 82), (104, 38), (114, 82)], VERDE, VERDE_OSCURO, 1.6),
            P([(116, 82), (124, 46), (132, 82)], HERBA, VERDE_OSCURO, 1.6),
        ] + _mano_abierta(80, 56, 0.9, (AMARILLO, AMARILLO_OSCURO)),
        "Palma apoyada sobre tupidas briznas verdes de terreno herboso.")
    put("gritty", "D",
        fondo_mesa() + [
            F("M34 78 Q80 42 126 78 Z", "#fde68a", TIERRA_CLARA, 2.0),
        ] + [
            E(cx, cy, 1.8, 1.8, BARRO)
            for cx, cy in [(62, 68), (74, 62), (86, 66), (96, 70), (70, 72), (80, 56), (90, 62), (54, 72)]
        ] + _mano_indice(112, 46, -1, 1, (ROJO, ROJO_OSCURO)),
        "Granos gruesos y arenosos de arena notándose ásperos entre los dedos.")
    put("hand gel", "D",
        fondo_sala() + [
            R(44, 38, 30, 42, 6, "#bae6fd", AGUA_OSCURO, 2.2),
            R(53, 28, 12, 10, 2, BLANCO, GRIS_OSCURO, 1.8),
            L("M59 28 L59 20 L74 20", GRIS_OSCURO, 2.8),
            E(76, 32, 4.5, 5.5, "#38bdf8", AGUA_OSCURO, 1.5),
        ] + _mano_abierta(108, 56, 1.0, (VERDE, VERDE_OSCURO)) + [
            E(108, 54, 5, 4, "#38bdf8", AGUA_OSCURO, 1.3),
        ],
        "Bote dosificador de gel hidroalcohólico echando una gota sobre la palma.")

    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    # make_draw (1)
    "letters and numbers": "Prohibido dibujar letras o números en las láminas («Letras y números»: dibujar una A y un 1).",
    # show_gesture (13)
    "cheap": "Concepto económico abstracto («Barato»); sin etiquetas de precio con números no se distingue de una moneda.",
    "every piece counts": "Idea moral abstracta («Cada trozo cuenta»); carece de imagen única inequívoca sin texto.",
    "expensive": "Concepto económico abstracto («Caro»); indistinguible de «monedas» o «ahorrar» sin cifras.",
    "hobby": "Categoría general abstracta («Afición»); abarca deportes, lectura o pintura sin referente único.",
    "independent": "Rasgo de autonomía personal abstracto («Autónomo»); indistinguible de cualquier acción cotidiana sin texto.",
    "keepsake": "Valor afectivo invisible («Recuerdo»); cualquier objeto pequeño parece solo ese objeto sin historia escrita.",
    "new": "Cualidad temporal abstracta («Nuevo, nueva»); enseñar una caja o lazo parece «regalo», no «nuevo».",
    "one more sleep": "Expresión temporal idiomática («¡Solo una noche más!»); imposible distinguirla de «dormir» sin texto.",
    "what a colour": "Exclamación conversacional («¡Qué color!»); sin objeto concreto ni signo escrito.",
    "what does the cow say": "Pregunta lúdica verbal («¿Qué dice la vaca?»); sin texto no se distingue de «cow» o «moo».",
    "what is it": "Pregunta abierta genérica («¿Qué es?»); depende de un objeto desconocido y el diálogo hablado.",
    "what shape is this": "Pregunta abierta de formas («¿Qué forma es?»); indistinguible de mostrar una figura.",
    "which one is blue": "Pregunta verbal de elección («¿Cuál es el azul?»); requiere frase hablada para distinguirla.",
    # mouth_sing (20)
    "actor's line": "Concepto teatral lingüístico («Frase del papel»); requiere guion escrito.",
    "calm and clear": "Cualidad invisible del habla («Tranquilo y claro»); depende de la voz escuchada.",
    "calm voice": "Cualidad acústica invisible («Voz tranquila»).",
    "change voices": "Consigna vocal dinámica («Cambiar de voz»); cambio invisible en imagen fija.",
    "chorus": "Parte estructural de una canción («Estribillo»); indistinguible de «choir» o «class song» sin texto.",
    "clear voice": "Cualidad invisible de la dicción («Voz clara»).",
    "compliment": "Acto de habla social («Cumplido»); indistinguible de «sonreír» o «hablar» sin palabras.",
    "deep voice": "Cualidad acústica invisible («Voz grave»).",
    "first he whispers, then he shouts": "Secuencia narrativa acústica («Primero susurra, luego grita»); requiere dos volúmenes de audio.",
    "loudest": "Superlativo acústico comparativo («El más fuerte»); requiere escala sonora de comparación.",
    "rumbly": "Cualidad sonora abstracta («Retumbante»); sonido grave sin objeto único.",
    "soft voice": "Cualidad acústica invisible («Voz suave»).",
    "speech": "Concepto lingüístico abstracto («Discurso»); sin texto se confunde con «talk» o «give a speech».",
    "squeaky voice": "Cualidad acústica invisible («Voz aguda»).",
    "talk it through": "Verbo conversacional abstracto («Hablarlo»); indistinguible de «dialogue» sin texto.",
    "try it": "Petición verbal genérica («Probar»); sin objeto fijo es idéntica a «taste a bit».",
    "voice": "Fenómeno acústico invisible («Voz»); carece de imagen única no textual.",
    "where's the smile": "Pregunta lúdica verbal («¿Dónde está la sonrisa?»).",
    "whispery": "Cualidad acústica invisible («Susurrante»).",
    "yum yum": "Exclamación onomatopéyica pura («¡Ñam ñam!»); indistinguible de «delicious» sin texto.",
    # count_fingers (34)
    "age": "Concepto abstracto («Edad»); sin dígitos ni texto no se distingue de mostrar los dedos o cumpleaños.",
    "count down": "Acción numérica descendente («Contar hacia atrás»); requiere números sin texto prohibido.",
    "count to twenty": "Consigna numérica verbal («Contar hasta veinte»); prohibido dibujar cifras y no se distingue de lavar manos.",
    "countdown": "Secuencia numérica descendente («Cuenta atrás»); requiere dígitos «5, 4, 3...».",
    "even number": "Concepto matemático abstracto («Número par»); requiere dígitos.",
    "every little thing helps": "Refrán moral abstracto («Cada poquito ayuda»).",
    "first, then, finally": "Conectores lógicos temporales («Primero, luego, por último»); secuencia puramente verbal.",
    "five minutes each": "Regla temporal de turnos («Cinco minutos cada uno»).",
    "five years": "Duración temporal abstracta («Cinco años»); requiere dígito «5» para no confundirse.",
    "five, four, three, two, one": "Serie numérica hablada («¡Cinco, cuatro, tres, dos, uno!»).",
    "gram": "Unidad de masa abstracta («Gramo»); invisible sin símbolo numérico «g».",
    "hours of sleep": "Medida temporal abstracta («Horas de sueño»); indistinguible de «sleep» o reloj sin cifras.",
    "how long can you stand on one leg": "Pregunta de duración («¿Cuánto aguantas a la pata coja?»); indistinguible de «stand on one leg».",
    "how many chestnuts": "Pregunta numérica («¿Cuántas castañas?»); sin interrogación parece solo «castañas».",
    "how many crates did we fill": "Pregunta numérica («¿Cuántas cajas llenamos?»).",
    "how many days until the party": "Pregunta temporal de calendario («¿Cuántos días faltan para la fiesta?»).",
    "how many legs has it got": "Pregunta numérica («¿Cuántas patas tiene?»).",
    "how many petals does it have": "Pregunta numérica («¿Cuántos pétalos tiene?»).",
    "how old are you": "Pregunta personal («¿Cuántos años tienes?»).",
    "how old is this tree": "Pregunta numérica sobre el árbol («¿Cuántos años tiene este árbol?»).",
    "i'm five and a half": "Frase de edad exacta («¡Tengo cinco años y medio!»); requiere números.",
    "keep score": "Concepto lúdico numérico («Llevar los puntos»); un marcador exige números.",
    "less than three": "Comparación matemática abstracta («Menos de tres»).",
    "majority": "Concepto cuantitativo abstracto («Mayoría»).",
    "more than five": "Comparación matemática abstracta («Más de cinco»).",
    "odd": "Concepto matemático abstracto («Impar»); requiere dígitos.",
    "plan b": "Expresión estratégica abstracta («Plan B»); prohibido dibujar la letra «B».",
    "result": "Concepto lógico/matemático abstracto («Resultado»).",
    "retell": "Verbo narrativo abstracto («Volver a contar una historia»).",
    "solution": "Concepto lógico abstracto («Solución»); sin texto se confunde con «idea».",
    "tell in order": "Consigna verbal de orden («Contar en orden»).",
    "three plus two makes five": "Operación aritmética verbal («Tres más dos son cinco»); requiere cifras y signos.",
    "total": "Concepto matemático abstracto («Total»).",
    "week": "Concepto temporal abstracto («Semana»); sin nombres de días se confunde con calendario.",
    # body_touch (3 primeros auditados)
    "all by myself": "Expresión de autonomía personal («Yo solo»); indistinguible de orgullo sin texto.",
    "clever": "Rasgo cognitivo abstracto («Listo, lista»); indistinguible de pensar o idea.",
    "do you remember": "Pregunta conversacional de memoria («¿Te acuerdas?»).",
}
