#!/usr/bin/env python3
"""Tanda 5 TPR (P2.86): acciones con agua (cierre), comer y beber, dar/ofrecer
en grupo, soplar, parar/equilibrio/comparar, sacudir/temblar, alegrarse/sonreír,
sostener/llevar y primeras piezas de crear/dibujar.

Cubre 200 piezas revisadas + 32 auditadas sin base (`SIN_BASE`):
- Cierre completo de `water_action` (22+3), `eat_drink` (18+1), `give_offer` (7+0),
  `blow` (33+3), `stop_freeze` (16+14), `shake_move` (27+2), `happy_smile` (35+6)
  y `hold_carry` (39+3).
- Primeras 3 piezas concretas de `make_draw` (`bug hotel`, `butterfly print`, `card making`).

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las abstractas o sin base visual clara quedan fuera en `SIN_BASE`.
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
    bebe_sentado,
    caja_prop,
    charco_prop,
    copos_nieve,
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
    ico,
    libro_prop,
    lineas_viento,
    manta_prop,
    mesa_prop,
    nino,
    nino_busto,
    nino_caminando,
    nino_corriendo,
    notas_col,
    ondas_calor,
    ondas_sonido,
    pelota_prop,
    plato_prop,
    pompas,
    sol,
)
from banco_comun import molinillo, notas  # noqa: E402

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "bike": ("Bicycle", "R", "Bicicleta infantil con manillar y dos ruedas."),
    "cheerful face": ("Beaming face with smiling eyes", "R", "Cara radiante con sonrisa abierta y ojos alegres."),
    "glass jar": ("Jar", "R", "Tarro transparente de cristal con tapa."),
    "juice box": ("Beverage box", "R", "Brik de zumo de fruta con pajita."),
    "lantern": ("Red paper lantern", "R", "Farol rojo de papel iluminado para llevar."),
    "maraca": ("Maracas", "U", "Par de maracas coloridas para agitar al ritmo."),
    "milk": ("Glass of milk", "U", "Vaso lleno de leche blanca fresca."),
    "shopping bag": ("Shopping bags", "R", "Bolsas de la compra con asas para llevar."),
}

# ── Directas Iconify ───────────────────────────────────────────────────────
DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _regadera(x: float, y: float, col: str = AZUL, borde: str = AZUL_OSCURO) -> list[dict]:
    return [
        R(x, y + 6, 26, 20, 4, col, borde, 2.0),
        L(f"M{x - 2} {y + 16} Q{x - 10} {y + 8} {x + 2} {y + 6}", borde, 2.4),
        L(f"M{x + 25} {y + 18} L{x + 38} {y + 8}", borde, 3.2),
        E(x + 40, y + 8, 3.5, 4.5, col, borde, 1.8),
    ]


def _grifo(x: float, y: float) -> list[dict]:
    return [
        R(x, y, 22, 8, 2, GRIS, GRIS_OSCURO, 1.8),
        R(x + 6, y - 6, 10, 6, 2, GRIS_OSCURO),
        R(x + 17, y + 4, 7, 10, 2, GRIS, GRIS_OSCURO, 1.8),
    ]


def _vaso_agua(cx: float, cy: float, w: float = 20, h: float = 26) -> list[dict]:
    x0 = cx - w / 2
    return [
        F(f"M{x0} {cy} L{x0 + w} {cy} L{x0 + w - 2.5} {cy + h} L{x0 + 2.5} {cy + h} Z", "#e0f2fe", AGUA_OSCURO, 2.0),
        F(f"M{x0 + 1.5} {cy + 7} L{x0 + w - 1.5} {cy + 7} L{x0 + w - 2.5} {cy + h - 1.5} L{x0 + 2.5} {cy + h - 1.5} Z", AGUA),
    ]


def _palmera(cx: float, base_y: float) -> list[dict]:
    return [
        L(f"M{cx} {base_y} Q{cx - 4} {base_y - 22} {cx + 2} {base_y - 42}", BARRO, 4.5),
        E(cx - 10, base_y - 40, 12, 4, VERDE, VERDE_OSCURO, 1.4),
        E(cx + 12, base_y - 40, 12, 4, VERDE, VERDE_OSCURO, 1.4),
        E(cx + 2, base_y - 46, 9, 4, VERDE, VERDE_OSCURO, 1.4),
    ]


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── Cierre de acciones con agua (`water_action`, 22 escenas) ────────────
    put("spread", "C",
        fondo_mesa() + fl("Bread", 34, 26, 52) + [
            F("M48 44 Q60 38 72 46 Q74 56 60 56 Q48 54 48 44 Z", "#fde047", AMARILLO_OSCURO, 1.6),
            L("M74 44 L116 26", GRIS_OSCURO, 3.8),
            L("M106 30 L122 23", MADERA_OSCURA, 5.0),
        ] + frecha((54, 66), (76, 66), NARANJA_OSCURO, 2.2),
        "Rebanada de pan untándose suavemente con mantequilla.")
    put("sprinkle", "C",
        fondo_prado() + fl("Potted plant", 54, 34, 48) + gotas([(66, 22), (78, 16), (90, 22), (74, 30), (86, 30)]),
        "Gotitas ligeras cayendo sobre la planta en su maceta para regarla.")
    put("strain", "D",
        fondo_mesa() + [
            R(42, 34, 54, 12, 4, ROJO, ROJO_OSCURO, 2.0),
            L("M96 40 L124 40", GRIS_OSCURO, 3.2),
            L("M50 46 L88 46", NEGRO, 1.8),
            L("M56 38 L82 38", GRIS_OSCURO, 1.4),
            R(46, 68, 46, 12, 4, AZUL, AZUL_OSCURO, 1.8),
        ] + gotas([(56, 52), (69, 58), (82, 52)]),
        "Colador filtrando el agua en gotitas hacia el cuenco inferior.")
    put("sun and water", "C",
        fondo_cielo() + fl("Sun", 24, 18, 44) + [R(82, 54, 62, 32, 8, AGUA, AGUA_OSCURO, 2.0)] + fl("Droplet", 96, 16, 36),
        "Sol brillante arriba y agua azul clara con su gota al lado.")
    put("swim like a fish", "C",
        fondo_mar() + fl("Tropical fish", 20, 56, 36) + [
            L("M116 70 L138 66", PELB, 4.6),
            L("M116 70 L138 66", PEL, 2.6),
            E(92, 74, 15, 7.5, ROJO, ROJO_OSCURO, 1.8),
            E(111, 71, 7.5, 7.5, PEL, PELB, 1.8),
            E(114, 70, 1.3, 1.5, TINTA),
        ] + pompas([(122, 58, 3), (128, 50, 4)]),
        "Pez tropical y niño o niña nadando juntos con las manos delante bajo el agua.")
    put("swim underwater", "D",
        [
            R(0, 0, 160, 100, 0, "#bae6fd"),
            R(0, 24, 160, 76, 0, AGUA),
            L("M0 24 Q20 18 40 24 Q60 30 80 24 Q100 18 120 24 Q140 30 160 24", AGUA_OSCURO, 2.4),
            E(68, 60, 16, 7, VERDE, VERDE_OSCURO, 2.0),
            E(90, 58, 8, 8, PEL, PELB, 2.0),
            R(88, 54, 9, 5, 2, "#38bdf8", AZUL_OSCURO, 1.4),
            L("M96 58 L114 54", PELB, 3.0),
        ] + pompas([(100, 44, 3.5), (104, 34, 4.5), (96, 48, 2.5)]),
        "Niño o niña con gafas buceando por debajo de la línea de las olas con burbujas.")
    put("swish", "D",
        fondo_sala() + [
            E(64, 46, 20, 20, PEL, PELB, 2.2),
            F("M44 42 C44 24 84 24 84 42 C72 32 56 32 44 42 Z", BARRO),
            E(56, 42, 1.8, 2.2, TINTA),
            E(72, 42, 1.8, 2.2, TINTA),
            E(52, 54, 7, 5, "#bae6fd", AGUA_OSCURO, 1.5),
            E(76, 54, 7, 5, "#bae6fd", AGUA_OSCURO, 1.5),
            L("M58 55 L70 55", "#9a3412", 1.8),
        ] + _vaso_agua(116, 46, 22, 28) + [L("M48 64 Q64 70 80 64", AGUA_OSCURO, 2.0)],
        "Carrillos hinchados enjuagando el agua de un lado a otro junto al vaso.")
    put("tap water", "C",
        fondo_sala() + _grifo(62, 16) + [L("M82 30 L82 64", AGUA, 5.5)] + fl("Open hands", 58, 50, 44) + gotas([(70, 46), (94, 46)]),
        "Grifo abierto con chorro de agua cayendo sobre las manos abiertas.")
    put("test", "C",
        fondo_mesa() + [
            R(36, 48, 88, 28, 6, AGUA, AGUA_OSCURO, 2.2),
            R(36, 48, 88, 6, 2, "#bae6fd"),
        ] + fl("Duck", 54, 24, 32) + [E(100, 68, 7, 5, GRIS_OSCURO, NEGRO, 1.8)] + gotas([(80, 32)]),
        "Barreño con agua probando qué objeto flota arriba y cuál se hunde al fondo.")
    put("the mother swims next to her calf", "C",
        fondo_mar() + fl("Whale", 24, 26, 60) + fl("Whale", 94, 48, 36),
        "Ballena grande nadando en el mar justo al lado de su cría pequeña.")
    put("toy watering can", "D",
        fondo_prado() + _regadera(42, 24, ROJO, ROJO_OSCURO) + gotas([(90, 44), (96, 54), (104, 48)]) + [
            L("M110 74 L110 56", VERDE_OSCURO, 2.6),
            E(110, 52, 7, 7, AMARILLO, AMARILLO_OSCURO, 1.8),
            E(110, 52, 3, 3, NARANJA),
        ],
        "Regadera roja de juguete inclinando el pico y regando una flor.")
    put("under the sea", "C",
        [
            R(0, 0, 160, 100, 0, "#0284c7"),
            R(0, 76, 160, 24, 0, "#fde68a"),
            L("M0 14 Q20 8 40 14 Q60 20 80 14 Q100 8 120 14 Q140 20 160 14", "#bae6fd", 2.4),
        ] + fl("Tropical fish", 28, 28, 38) + fl("Coral", 94, 42, 42) + pompas([(72, 30, 4), (78, 20, 3), (84, 38, 3)]),
        "Fondo marino bajo las olas con pez tropical, coral y burbujas.")
    put("under the umbrella", "C",
        fondo_prado() + gotas([(24, 20), (42, 14), (120, 16), (136, 24)]) + fl("Umbrella", 44, 12, 72) + nino_busto(68, 56, camisa=(ROJO, ROJO_OSCURO), r=7) + nino_busto(92, 56, camisa=(AZUL, AZUL_OSCURO), r=7),
        "Dos niños o niñas resguardadas bajo un gran paraguas mientras llueve fuera.")
    put("wash vegetables", "C",
        fondo_mesa() + _grifo(64, 12) + [L("M84 26 L84 44", AGUA, 4.5)] + fl("Carrot", 44, 40, 36) + fl("Tomato", 84, 44, 34) + gotas([(66, 36), (98, 36)]),
        "Zanahoria y tomate frescos lavándose bajo el agua del grifo.")
    put("wash, then dry", "C",
        fondo_sala() + _grifo(22, 16) + [L("M42 30 L42 50", AGUA, 4.0)] + fl("Open hands", 22, 44, 34) + frecha((62, 46), (90, 46), AZUL_OSCURO, 2.6) + [
            L("M96 24 L138 24", MADERA_OSCURA, 3.2),
            F("M102 24 L132 24 L134 66 Q124 62 117 66 Q110 62 100 66 Z", "#7dd3fc", AZUL_OSCURO, 2.0),
            L("M102 56 L132 56", BLANCO, 2.0),
        ],
        "Primero lavar las manos bajo el chorro y flecha hacia la toalla para secarlas.")
    put("water bottle", "C",
        fondo_sala() + nino_busto(56, 38, camisa=(VERDE, VERDE_OSCURO), r=9.5) + [
            R(84, 28, 22, 42, 6, AGUA, AGUA_OSCURO, 2.2),
            R(90, 20, 10, 8, 2, AZUL_OSCURO),
            R(86, 40, 18, 16, 2, "#bae6fd"),
        ],
        "Botella reutilizable de agua junto a un niño o una niña dispuesta a dar un sorbo.")
    put("water it", "C",
        fondo_prado() + _regadera(32, 22, VERDE, VERDE_OSCURO) + gotas([(82, 42), (90, 50)]) + fl("Potted plant", 88, 36, 44),
        "Regadera vertiendo agua sobre la planta de la maceta.")
    put("water on my toes", "D",
        fondo_mar() + charco_prop(80, 74, 48, 12) + [
            R(54, 26, 13, 30, 5, AZUL, AZUL_OSCURO, 1.8),
            E(60, 62, 11, 7, PEL, PELB, 2.0),
            E(51, 55, 2.3, 2.6, PEL, PELB, 1.2), E(56, 54, 2.4, 2.8, PEL, PELB, 1.2), E(61, 54, 2.4, 2.8, PEL, PELB, 1.2), E(66, 55, 2.2, 2.5, PEL, PELB, 1.2),
            R(93, 26, 13, 30, 5, AZUL, AZUL_OSCURO, 1.8),
            E(100, 62, 11, 7, PEL, PELB, 2.0),
            E(94, 55, 2.2, 2.5, PEL, PELB, 1.2), E(99, 54, 2.4, 2.8, PEL, PELB, 1.2), E(104, 54, 2.4, 2.8, PEL, PELB, 1.2), E(109, 55, 2.3, 2.6, PEL, PELB, 1.2),
        ] + gotas([(40, 54), (120, 54)]),
        "Pies descalzos chapoteando con los deditos en el agua.")
    put("water table", "C",
        fondo_sala() + [
            R(36, 54, 8, 26, 2, MADERA_OSCURA),
            R(116, 54, 8, 26, 2, MADERA_OSCURA),
            R(26, 38, 108, 22, 5, AZUL, AZUL_OSCURO, 2.2),
            R(32, 42, 96, 12, 3, AGUA),
        ] + fl("Duck", 44, 22, 24) + [
            P([(94, 48), (112, 48), (106, 40), (98, 40)], ROJO, ROJO_OSCURO, 1.5),
        ] + fl("Open hands", 64, 14, 30),
        "Mesa de juegos llena de agua con barquito, patito y manos jugando.")
    put("water wheel", "D",
        fondo_prado() + [
            _grifo(44, 12)[0],
            L("M66 20 L66 42", AGUA, 4.5),
            E(80, 52, 20, 20, BLANCO, MADERA_OSCURA, 2.4),
            E(80, 52, 5, 5, MADERA_OSCURA),
            L("M80 28 L80 76", MADERA_OSCURA, 3.0),
            L("M56 52 L104 52", MADERA_OSCURA, 3.0),
            L("M63 35 L97 69", MADERA_OSCURA, 2.6),
            L("M97 35 L63 69", MADERA_OSCURA, 2.6),
        ] + gotas([(96, 62), (104, 70)]),
        "Rueda de palas girando al caer el chorro de agua encima.")
    put("waterproof", "D",
        fondo_cielo("#bae6fd") + [
            F("M54 32 L106 32 L116 78 L44 78 Z", AMARILLO, AMARILLO_OSCURO, 2.2),
            E(80, 24, 14, 11, AMARILLO, AMARILLO_OSCURO, 2.0),
            L("M80 32 L80 78", AMARILLO_OSCURO, 2.0),
        ] + gotas([(34, 26), (124, 26), (30, 56), (130, 56), (48, 82), (112, 82)]),
        "Chubasquero amarillo impermeable haciendo resbalar las gotas de lluvia.")
    put("when i look after my plant, it grows", "C",
        fondo_prado() + fl("Seedling", 26, 44, 34) + gotas([(40, 28), (48, 22)]) + frecha((64, 52), (92, 52), VERDE_OSCURO, 2.8) + fl("Sunflower", 96, 20, 48),
        "Brote pequeño regado creciendo con una flecha hasta ser un girasol alto.")

    # ── Comer y beber (`eat_drink`, 17 escenas + `milk` directa = 18) ─────────
    put("burp", "C",
        fondo_sala() + nino_busto(64, 42, camisa=(VERDE, VERDE_OSCURO), r=10) + bebe(90, 42, "#fde68a", AMARILLO_OSCURO, mirando=-1) + [L("M92 26 L98 22", ROJO, 2.0), L("M96 32 L104 30", ROJO, 2.0)] + fl("Baby bottle", 24, 40, 34),
        "Palmaditas suaves en la espalda del bebé tras tomar su biberón.")
    put("chew", "C",
        fondo_mesa() + nino_busto(58, 42, camisa=(NARANJA, NARANJA_OSCURO), r=11) + [
            E(66, 47, 4.5, 4.0, "#fed7aa", "#c2410c", 1.2),
            L("M72 48 Q78 52 72 56", ROJO, 1.8),
        ] + fl("Red apple", 96, 36, 38),
        "Niño o niña con el carrillo lleno masticando despacio un bocado de manzana.")
    put("chocolate", "D",
        fondo_mesa() + nino_busto(48, 44, camisa=(AZUL, AZUL_OSCURO), r=10.5) + [
            R(84, 44, 36, 28, 6, ROJO, ROJO_OSCURO, 2.2),
            E(120, 58, 7, 8, BLANCO, ROJO_OSCURO, 2.6),
            E(102, 44, 17, 4.5, "#451a03", BARRO, 1.5),
        ] + ondas_calor(92, 24, GRIS_OSCURO),
        "Taza caliente de chocolate humeante bebida con cuidado.")
    put("chocolatey", "C",
        fondo_mesa() + nino_busto(58, 44, camisa=(ROJO, ROJO_OSCURO), r=11) + [
            E(58, 49, 6, 2.2, "#451a03"),
            E(62, 53, 3.2, 2.5, "#ec4899"),
        ] + fl("Cookie", 96, 34, 40),
        "Cara feliz con bigote de chocolate relamiéndose junto a una galleta.")
    put("crunchy", "C",
        fondo_mesa() + nino_busto(54, 42, camisa=(VERDE, VERDE_OSCURO), r=11) + fl("Carrot", 86, 30, 42) + [
            L("M76 42 L84 36", NARANJA, 2.0),
            L("M78 50 L88 52", NARANJA, 2.0),
            E(82, 60, 2.2, 2.2, NARANJA),
            E(90, 62, 1.8, 1.8, NARANJA),
        ],
        "Mordisco alegre a una zanahoria crujiente con destellos y miguitas.")
    put("fresh water", "C",
        fondo_prado() + [
            L("M16 74 Q50 64 90 74 Q124 82 150 72", AGUA_OSCURO, 4.0),
        ] + _vaso_agua(80, 32, 28, 36) + fl("Droplet", 42, 28, 28),
        "Vaso de agua dulce cristalina recién recogida.")
    put("hydrated", "C",
        fondo_prado() + nino_busto(58, 44, camisa=(AZUL, AZUL_OSCURO), r=10.5) + _vaso_agua(98, 40, 22, 30) + fl("Sparkles", 112, 18, 26),
        "Niño o niña sonriente y fresca hidratándose con un vaso de agua limpia.")
    put("ice lolly", "D",
        fondo_cielo() + [
            R(74, 58, 12, 28, 4, MADERA, MADERA_OSCURA, 1.8),
            R(62, 16, 36, 46, 14, ROSA, ROSA_OSCURO, 2.2),
            R(68, 24, 6, 28, 3, "#fbcfe8"),
            L("M80 24 L80 54", ROSA_OSCURO, 2.0),
        ] + gotas([(54, 46), (106, 34)]),
        "Polo helado de fruta en palo de madera muy fresquito.")
    put("lick", "C",
        fondo_sala() + nino_busto(56, 42, camisa=(ROSA, ROSA_OSCURO), r=11) + [E(62, 50, 3.5, 4.5, "#ec4899", "#9d174d", 1.2)] + fl("Lollipop", 84, 24, 46),
        "Lengua fuera lamiendo una piruleta grande de colores.")
    put("lick a lolly", "D",
        fondo_cielo() + nino_busto(52, 44, camisa=(AZUL, AZUL_OSCURO), r=11) + [
            E(60, 52, 3.5, 4.5, "#ec4899", "#9d174d", 1.2),
            P([(84, 44), (112, 44), (98, 78)], TIERRA_CLARA, BARRO, 2.0),
            E(98, 36, 15, 13, ROSA, ROSA_OSCURO, 2.0),
            E(92, 26, 11, 10, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Niño o niña sacando la lengua para lamer un cucurucho de helado.")
    put("refreshing", "C",
        fondo_cielo("#e0f2fe") + _vaso_agua(76, 32, 30, 40) + [R(70, 36, 10, 10, 2, "#bae6fd", AGUA_OSCURO, 1.5)] + fl("Ice", 32, 36, 34) + lineas_viento(104, 42, 26, AGUA_OSCURO),
        "Agua helada con cubito de hielo y brisa refrescante.")
    put("slurp up", "C",
        fondo_mesa() + nino_busto(50, 44, camisa=(AMARILLO, AMARILLO_OSCURO), r=10.5) + fl("Cup with straw", 84, 24, 48) + frecha((108, 62), (108, 28), ROJO, 2.6),
        "Sorbiendo zumo hacia arriba por la pajita del vaso.")
    put("smack lips", "C",
        fondo_mesa() + [
            E(64, 44, 20, 20, PEL, PELB, 2.2),
            F("M44 40 C44 22 84 22 84 40 C72 30 56 30 44 40 Z", BARRO),
            E(56, 40, 2.0, 2.5, TINTA),
            E(72, 40, 2.0, 2.5, TINTA),
            L("M56 50 Q64 56 72 50", "#9a3412", 2.0),
            E(70, 52, 4.5, 3.2, "#ec4899", "#9d174d", 1.2),
        ] + fl("Strawberry", 100, 34, 36),
        "Cara feliz relamiéndose los labios con la lengua ante una fresa dulce.")
    put("thirsty", "C",
        fondo_cielo("#fef3c7") + fl("Sun", 16, 12, 34) + nino_busto(58, 46, camisa=(ROJO, ROJO_OSCURO), r=10.5) + [E(46, 42, 2.4, 3.5, AGUA)] + _vaso_agua(104, 42, 24, 32) + frecha((74, 54), (90, 54), AGUA_OSCURO, 2.4),
        "Niño o niña con calor y sed tendiendo la mano hacia un vaso de agua fresca.")
    put("water break", "C",
        fondo_prado() + nino_corriendo(48, 22, camisa=(VERDE, VERDE_OSCURO)) + [
            R(100, 32, 20, 38, 5, AGUA, AGUA_OSCURO, 2.0),
            R(105, 25, 10, 7, 2, AZUL_OSCURO),
        ] + gotas([(90, 38)]),
        "Pausa tras correr para hidratarse bebiendo agua de la botella.")
    put("water cup", "D",
        fondo_mesa() + nino_busto(54, 44, camisa=(AZUL, AZUL_OSCURO), r=10.5) + _vaso_agua(98, 40, 26, 32),
        "Vaso propio lleno de agua limpia junto al niño o a la niña para beber.")
    put("yummy", "C",
        fondo_mesa() + nino_busto(56, 44, camisa=(ROSA, ROSA_OSCURO), r=10.5) + [E(62, 51, 3.2, 3.2, "#ec4899")] + fl("Cupcake", 94, 32, 42),
        "Cara relamiéndose de gusto frente a un pastelito riquísimo.")

    # ── Dar, ofrecer y agrupar (`give_offer`, 7 escenas) ────────────────────
    put("crowded", "D",
        fondo_sala() + [
            R(28, 26, 104, 52, 8, AMARILLO, AMARILLO_OSCURO, 2.2),
        ] + nino_busto(48, 46, camisa=(ROJO, ROJO_OSCURO), r=7)
          + nino_busto(64, 46, camisa=(AZUL, AZUL_OSCURO), r=7)
          + nino_busto(80, 46, camisa=(VERDE, VERDE_OSCURO), r=7)
          + nino_busto(96, 46, camisa=(MORADO, AZUL_OSCURO), r=7)
          + nino_busto(112, 46, camisa=(NARANJA, NARANJA_OSCURO), r=7),
        "Muchos niños apretados hombro con hombro en un espacio lleno.")
    put("fish swim together in a shoal", "C",
        fondo_mar() + fl("Tropical fish", 16, 66, 22) + fl("Tropical fish", 42, 56, 22) + fl("Tropical fish", 42, 76, 22) + fl("Tropical fish", 70, 66, 22) + fl("Tropical fish", 98, 56, 22) + fl("Tropical fish", 98, 76, 22) + frecha((126, 68), (148, 68), BLANCO, 2.2),
        "Banco de seis peces nadando juntos en la misma dirección.")
    put("friendly", "D",
        fondo_prado() + nino_busto(50, 42, camisa=(AZUL, AZUL_OSCURO), r=9.5) + nino_busto(110, 42, camisa=(VERDE, VERDE_OSCURO), r=9.5, mira=-1) + [
            L("M66 56 L94 56", PELB, 5.2),
            L("M66 56 L94 56", PEL, 3.0),
            E(80, 56, 5, 4, PEL, PELB, 1.6),
        ],
        "Dos niños o niñas sonrientes dándose la mano con gesto amigable.")
    put("huddle together", "D",
        fondo_cielo("#dbeafe") + [R(0, 74, 160, 26, 0, BLANCO, GRIS, 2.0)] + copos_nieve([(28, 22), (132, 22), (80, 14)])
          + nino_busto(62, 46, camisa=(ROJO, ROJO_OSCURO), r=8)
          + nino_busto(80, 44, camisa=(AZUL, AZUL_OSCURO), r=8)
          + nino_busto(98, 46, camisa=(VERDE, VERDE_OSCURO), r=8),
        "Tres niños muy juntos acurrucándose para darse calor en el frío.")
    put("kind", "C",
        fondo_prado() + nino_busto(48, 42, camisa=(ROSA, ROSA_OSCURO), r=9.5) + nino_busto(112, 42, camisa=(AZUL, AZUL_OSCURO), r=9.5, mira=-1) + fl("Red apple", 68, 36, 24) + frecha((68, 64), (92, 64), ROJO, 2.4),
        "Niño o niña amable ofreciendo una manzana con una sonrisa a su amiga.")
    put("shoal", "D",
        fondo_mar() + [
            E(44, 68, 10, 5, "#93c5fd", AZUL_OSCURO, 1.6), P([(34, 68), (27, 63), (27, 73)], "#93c5fd", AZUL_OSCURO, 1.4),
            E(68, 60, 10, 5, "#93c5fd", AZUL_OSCURO, 1.6), P([(58, 60), (51, 55), (51, 65)], "#93c5fd", AZUL_OSCURO, 1.4),
            E(68, 76, 10, 5, "#93c5fd", AZUL_OSCURO, 1.6), P([(58, 76), (51, 71), (51, 81)], "#93c5fd", AZUL_OSCURO, 1.4),
            E(94, 68, 10, 5, "#93c5fd", AZUL_OSCURO, 1.6), P([(84, 68), (77, 63), (77, 73)], "#93c5fd", AZUL_OSCURO, 1.4),
            E(118, 62, 10, 5, "#93c5fd", AZUL_OSCURO, 1.6), P([(108, 62), (101, 57), (101, 67)], "#93c5fd", AZUL_OSCURO, 1.4),
        ],
        "Cardumen compacto de peces plateados nadando en grupo.")
    put("swim in a pod", "C",
        fondo_mar() + fl("Dolphin", 22, 40, 44) + fl("Dolphin", 64, 34, 42) + fl("Dolphin", 104, 46, 34),
        "Manada de delfines nadando juntos en grupo sobre las olas.")

    # ── Soplar (`blow`, 33 escenas) ────────────────────────────────────────
    put("blow bubbles", "C",
        fondo_prado() + [
            L("M38 66 L54 44", MORADO, 3.0),
            E(58, 38, 7, 7, "#f0abfc", MORADO, 2.2),
        ] + pompas([(76, 34, 6), (92, 26, 8), (110, 38, 7), (124, 22, 5), (100, 52, 5)]),
        "Varita mágica haciendo pompas de jabón que salen flotando.")
    put("blow harder", "C",
        fondo_mar() + fl("Wind face", 20, 22, 44) + lineas_viento(64, 38, 34, AZUL_OSCURO) + lineas_viento(64, 52, 34, AZUL_OSCURO) + fl("Sailboat", 98, 34, 44),
        "Viento soplando con mucha fuerza para impulsar el velero.")
    put("blow on it", "C",
        fondo_mesa() + nino_busto(46, 44, camisa=(ROJO, ROJO_OSCURO), r=10.5) + lineas_viento(62, 46, 18, AGUA_OSCURO) + [
            L("M98 58 L130 58", GRIS_OSCURO, 3.2),
            E(92, 58, 10, 5, "#fbbf24", NARANJA_OSCURO, 1.8),
        ] + ondas_calor(82, 34, ROJO),
        "Soplar suave sobre la cuchara con comida caliente antes de probarla.")
    put("blow the boat", "C",
        fondo_mar() + nino_busto(40, 44, camisa=(VERDE, VERDE_OSCURO), r=9.5) + lineas_viento(56, 44, 24, AZUL_OSCURO) + fl("Sailboat", 86, 36, 46),
        "Niño soplando directo hacia la vela del barquito sobre el agua.")
    put("blow to cool", "C",
        fondo_mesa() + fl("Steaming bowl", 74, 32, 48) + lineas_viento(34, 42, 32, AGUA_OSCURO) + ondas_calor(84, 18, ROJO),
        "Corriente suave de aire enfriando un plato de comida humeante.")
    put("breeze", "C",
        fondo_prado() + fl("Leaf fluttering in wind", 80, 30, 44) + lineas_viento(30, 44, 40, AGUA_OSCURO),
        "Brisa suave haciendo ondear las hojitas en el aire.")
    put("brr, freezing hands", "C",
        fondo_cielo("#dbeafe") + copos_nieve([(28, 22), (132, 22)]) + fl("Open hands", 56, 36, 48) + [
            E(68, 46, 6, 4, "#93c5fd"),
            E(92, 46, 6, 4, "#93c5fd"),
        ] + lineas_viento(64, 20, 30, AGUA_OSCURO),
        "Manos heladas entre copos recibiendo soplido tibio para calentarlas.")
    put("cake", "D",
        fondo_mesa() + [
            R(44, 44, 72, 30, 6, "#fbcfe8", ROSA_OSCURO, 2.2),
            R(44, 44, 72, 10, 4, BLANCO, ROSA_OSCURO, 1.6),
            R(62, 28, 5, 16, 1, AZUL, AZUL_OSCURO, 1.4),
            R(78, 28, 5, 16, 1, AMARILLO, AMARILLO_OSCURO, 1.4),
            R(94, 28, 5, 16, 1, VERDE, VERDE_OSCURO, 1.4),
            E(64.5, 23, 2.5, 4, NARANJA),
            E(80.5, 23, 2.5, 4, NARANJA),
            E(96.5, 23, 2.5, 4, NARANJA),
        ] + lineas_viento(22, 26, 26, AGUA_OSCURO),
        "Tarta redonda con tres velas encendidas soplándose.")
    put("careful, it's hot", "C",
        fondo_mesa() + [
            R(44, 44, 48, 30, 6, ROJO, ROJO_OSCURO, 2.2),
            R(42, 40, 52, 6, 2, GRIS, GRIS_OSCURO, 1.6),
        ] + ondas_calor(58, 22, ROJO) + lineas_viento(14, 36, 22, AGUA_OSCURO) + fl("Waving hand", 102, 38, 36),
        "Olla muy caliente con ondas de calor y mano apartándose mientras se sopla.")
    put("chalky", "D",
        fondo_sala() + [
            R(26, 28, 64, 46, 4, "#065f46", MADERA_OSCURA, 2.4),
            R(36, 56, 28, 9, 2, BLANCO, GRIS_OSCURO, 1.6),
            R(44, 44, 28, 9, 2, "#fef3c7", GRIS_OSCURO, 1.6),
            E(102, 44, 10, 8, BLANCO, GRIS_OSCURO, 1.5),
            E(116, 38, 7, 6, BLANCO, GRIS_OSCURO, 1.4),
        ] + lineas_viento(74, 34, 24, AGUA_OSCURO),
        "Barritas de tiza sobre pizarra soltando polvo blanco al soplar.")
    put("cool", "C",
        fondo_cielo("#e0f2fe") + fl("Open hands", 56, 38, 46) + lineas_viento(38, 28, 42, AGUA_OSCURO) + copos_nieve([(112, 34)]),
        "Soplo suave y fresquito pasando sobre las palmas abiertas.")
    put("dandelion", "D",
        fondo_prado() + [
            L("M64 80 L64 42", VERDE_OSCURO, 3.2),
            E(64, 36, 17, 17, "#f8fafc", "#64748b", 2.0),
            L("M64 19 L64 53", "#94a3b8", 1.4),
            L("M47 36 L81 36", "#94a3b8", 1.4),
            L("M52 24 L76 48", "#94a3b8", 1.4),
            L("M52 48 L76 24", "#94a3b8", 1.4),
            E(64, 36, 5, 5, AMARILLO_OSCURO),
            L("M94 30 L104 26", "#475569", 1.8),
            L("M110 38 L120 34", "#475569", 1.8),
            L("M104 18 L114 14", "#475569", 1.8),
            E(104, 26, 2.5, 2.5, "#94a3b8"), E(120, 34, 2.5, 2.5, "#94a3b8"), E(114, 14, 2.5, 2.5, "#94a3b8"),
        ],
        "Diente de león blanco soltando sus semillas al viento.")
    put("dolphins breathe air through a blowhole", "C",
        fondo_mar() + fl("Dolphin", 54, 34, 52) + gotas([(74, 16), (86, 14), (80, 24)]),
        "Delfín asomando sobre el mar soplando aire y gotas por su espiráculo.")
    put("floaty", "C",
        fondo_cielo() + fl("Feather", 44, 30, 40) + fl("Leaf fluttering in wind", 86, 24, 38) + lineas_viento(26, 58, 42, AGUA_OSCURO),
        "Pluma y hojita flotando ligeritas llevadas por la corriente de aire.")
    put("foamy", "D",
        fondo_sala() + [
            R(42, 46, 76, 32, 8, AZUL, AZUL_OSCURO, 2.2),
            E(56, 42, 14, 10, BLANCO, GRIS, 1.6),
            E(76, 38, 16, 12, BLANCO, GRIS, 1.6),
            E(98, 42, 14, 10, BLANCO, GRIS, 1.6),
        ] + pompas([(54, 22, 5), (80, 18, 6), (104, 24, 4)]) + lineas_viento(20, 30, 24, AGUA_OSCURO),
        "Barreño rebosante de espuma blanca y burbujas ligeras al soplar.")
    put("gust", "C",
        fondo_prado() + fl("Wind face", 20, 22, 46) + lineas_viento(68, 36, 46, AZUL_OSCURO) + fl("Leaf fluttering in wind", 104, 22, 36),
        "Ráfaga fuerte de viento empujando hojas en el aire.")
    put("happy birthday", "C",
        fondo_sala() + fl("Birthday cake", 66, 32, 52) + nino_busto(40, 44, camisa=(MORADO, AZUL_OSCURO), r=9.5) + lineas_viento(52, 44, 16, ROJO) + [E(34, 20, 3, 3, ROJO), E(122, 22, 3, 3, AMARILLO), E(130, 36, 3, 3, VERDE)],
        "Niño soplando las velas de la tarta entre confeti de cumpleaños.")
    put("he huffed and he puffed", "C",
        fondo_prado() + fl("Wolf", 20, 30, 48) + lineas_viento(68, 42, 28, AZUL_OSCURO) + [
            P([(100, 44), (118, 28), (136, 44)], AMARILLO, AMARILLO_OSCURO, 2.0),
            R(102, 44, 32, 28, 3, "#fde68a", MADERA_OSCURA, 2.0),
        ],
        "El lobo soplando con fuerza hacia la casita de paja.")
    put("hot chocolate", "D",
        fondo_mesa() + [
            R(54, 42, 46, 32, 6, TIERRA, BARRO, 2.2),
            E(100, 58, 8, 9, BLANCO, BARRO, 2.8),
            E(77, 42, 22, 5, "#451a03"),
            R(66, 37, 8, 6, 2, BLANCO, GRIS, 1.3),
            R(80, 37, 8, 6, 2, BLANCO, GRIS, 1.3),
        ] + ondas_calor(67, 20, GRIS_OSCURO) + lineas_viento(24, 32, 26, AGUA_OSCURO),
        "Taza de chocolate caliente humeante con nubes mientras se sopla.")
    put("huff and puff", "C",
        fondo_cielo() + fl("Wind face", 34, 22, 50) + lineas_viento(86, 36, 44, AZUL_OSCURO) + lineas_viento(86, 52, 40, AGUA_OSCURO),
        "Carrillos llenos de aire soplando una y otra vez con fuerza.")
    put("it's hot", "C",
        fondo_cielo("#fef3c7") + fl("Sun", 104, 12, 40) + nino_busto(64, 42, camisa=(ROJO, ROJO_OSCURO), r=11) + [E(46, 40, 2.5, 4.0, AGUA)] + fl("Waving hand", 92, 42, 34),
        "Sol intenso dando mucho calor mientras la mano abanica la cara.")
    put("make a wish", "C",
        fondo_cielo("#bae6fd") + nino_busto(40, 44, camisa=(MORADO, AZUL_OSCURO), r=10) + [
            L("M74 76 L74 44", VERDE_OSCURO, 2.6),
            E(74, 38, 12, 12, BLANCO, "#475569", 1.8),
            L("M64 38 L84 38", "#94a3b8", 1.2),
            L("M74 28 L74 48", "#94a3b8", 1.2),
            E(94, 30, 2.2, 2.2, "#475569"),
            E(104, 24, 2.2, 2.2, "#475569"),
        ] + fl("Glowing star", 108, 20, 34),
        "Pedir un deseo soplando el diente de león bajo una estrella brillante.")
    put("minty", "C",
        fondo_cielo("#ecfdf5") + fl("Herb", 54, 26, 48) + lineas_viento(32, 46, 28, AGUA_OSCURO) + fl("Sparkles", 98, 24, 30),
        "Hojitas verdes de menta con aire fresco y aroma limpio.")
    put("old", "D",
        fondo_sala() + nino_busto(40, 44, camisa=(VERDE, VERDE_OSCURO), r=10) + lineas_viento(56, 42, 20, AGUA_OSCURO) + [
            P([(84, 68), (112, 68), (116, 42), (88, 42)], BARRO, "#451a03", 2.0),
            P([(88, 66), (114, 66), (118, 44), (92, 44)], "#fef3c7", MADERA_OSCURA, 1.5),
            L("M96 52 L110 52", GRIS_OSCURO, 1.4),
            L("M95 58 L109 58", GRIS_OSCURO, 1.4),
            E(96, 32, 6, 4, GRIS, GRIS_OSCURO, 1.2),
            E(108, 28, 7, 4, GRIS, GRIS_OSCURO, 1.2),
        ],
        "Soplando la nube de polvo de un libro muy viejo para limpiarlo.")
    put("paper boat race", "D",
        fondo_mar() + [
            P([(38, 60), (72, 60), (66, 68), (44, 68)], BLANCO, AZUL_OSCURO, 1.8),
            P([(48, 60), (55, 42), (62, 60)], "#e0f2fe", AZUL_OSCURO, 1.6),
            P([(86, 66), (120, 66), (114, 74), (92, 74)], "#fef3c7", ROJO_OSCURO, 1.8),
            P([(96, 66), (103, 48), (110, 66)], "#fee2e2", ROJO_OSCURO, 1.6),
        ] + lineas_viento(14, 48, 22, AGUA_OSCURO) + lineas_viento(64, 54, 20, AGUA_OSCURO),
        "Dos barquitos de papel plegado compitiendo impulsados por el soplido.")
    put("pinwheel", "D",
        fondo_prado() + molinillo(80, 42, 20) + lineas_viento(28, 38, 28, AGUA_OSCURO),
        "Molinillo de cuatro colores girando cuando se le sopla.")
    put("smoothie", "C",
        fondo_mesa() + fl("Cup with straw", 64, 24, 52) + fl("Strawberry", 34, 48, 30) + pompas([(82, 24, 3), (94, 18, 4)]),
        "Vaso de batido fresco con fresa y pajita haciendo burbujas al soplar.")
    put("soup", "C",
        fondo_mesa() + fl("Steaming bowl", 62, 28, 48) + fl("Spoon", 104, 28, 38) + lineas_viento(30, 38, 28, AGUA_OSCURO),
        "Cuenco de caldo caliente con cuchara enfriándose con un soplido.")
    put("steamy", "D",
        fondo_mesa() + [
            R(56, 46, 48, 30, 6, AZUL, AZUL_OSCURO, 2.2),
            E(104, 60, 7, 8, BLANCO, AZUL_OSCURO, 2.4),
        ] + ondas_calor(66, 24, NUBE_B) + lineas_viento(24, 32, 26, AGUA_OSCURO),
        "Taza sacando mucho vapor visible mientras se sopla encima.")
    put("toot", "C",
        fondo_sala() + fl("Trumpet", 40, 26, 52) + notas([(98, 36), (112, 28), (122, 42)]),
        "Trompeta dorada sonando con notas musicales al soplar.")
    put("warm up hands", "C",
        fondo_cielo("#dbeafe") + fl("Open hands", 54, 38, 52) + [
            L("M64 32 Q80 24 96 32", NARANJA, 2.4),
            L("M60 22 Q80 14 100 22", ROJO, 2.4),
        ],
        "Manos juntitas recibiendo aliento cálido para entrar en calor.")
    put("warm with breath", "C",
        fondo_cielo("#dbeafe") + nino_busto(44, 44, camisa=(ROJO, ROJO_OSCURO), r=10) + fl("Open hands", 86, 34, 46) + [
            L("M62 44 Q72 40 82 44", NARANJA, 2.4),
            L("M62 52 Q72 56 82 52", ROJO, 2.4),
        ],
        "Niño soplando vaho tibio directamente sobre las manos frías.")
    put("whistle", "D",
        fondo_prado() + [
            E(56, 46, 18, 18, PEL, PELB, 2.2),
            F("M38 42 C38 24 74 24 74 42 C62 32 50 32 38 42 Z", BARRO),
            E(64, 42, 2.0, 2.4, TINTA),
            E(70, 52, 2.6, 2.6, "#9a3412"),
        ] + notas([(90, 44), (104, 34), (118, 46)]),
        "Labios en círculo silbando una melodía alegre de notas musicales.")

    # ── Parar, equilibrio y comparar (`stop_freeze`, 16 escenas) ──────────────
    put("balanced", "D",
        fondo_prado() + nino((80, 22), (80, 34), (80, 52), [[(56, 36)], [(104, 36)]], [[(80, 74)], [(94, 58), (86, 66)]], camisa=(VERDE, VERDE_OSCURO)),
        "Niño equilibrado sobre un solo pie con los brazos en cruz.")
    put("brake", "D",
        fondo_prado() + [
            E(58, 66, 10, 10, BLANCO, NEGRO, 2.6),
            E(102, 66, 10, 10, BLANCO, NEGRO, 2.6),
            L("M58 66 L76 46 L102 66", ROJO, 3.0),
            L("M96 34 L102 66", GRIS_OSCURO, 2.8),
            L("M24 76 L46 76", ROJO, 2.4),
            L("M28 70 L42 70", NARANJA, 2.0),
        ] + nino_busto(70, 26, camisa=(AZUL, AZUL_OSCURO), r=8),
        "Frenando la bicicleta con el cuerpo echado atrás y marcas de frenada.")
    put("escalator", "D",
        fondo_sala() + [
            P([(30, 76), (110, 24), (126, 24), (126, 76)], GRIS, GRIS_OSCURO, 2.2),
            L("M30 62 L110 10", AZUL_OSCURO, 3.6),
            R(48, 56, 14, 6, 1, GRIS_OSCURO),
            R(66, 44, 14, 6, 1, GRIS_OSCURO),
            R(84, 32, 14, 6, 1, GRIS_OSCURO),
        ] + nino_busto(72, 22, camisa=(ROJO, ROJO_OSCURO), r=7),
        "Escalera mecánica en diagonal con niño quieto subiendo en su peldaño.")
    put("long", "D",
        fondo_prado() + [
            L("M20 56 Q44 44 68 56 Q92 68 116 56 Q130 48 140 54", VERDE, 7.0),
            E(140, 54, 5, 4, VERDE_OSCURO),
            E(142, 52, 1.4, 1.4, BLANCO),
        ] + frecha((22, 34), (138, 34), AZUL_OSCURO, 2.2) + frecha((138, 34), (22, 34), AZUL_OSCURO, 2.2),
        "Serpiente verde muy larga extendida de lado a lado con flecha de longitud.")
    put("longer", "D",
        fondo_mesa() + [
            R(30, 30, 42, 12, 3, AMARILLO, AMARILLO_OSCURO, 1.8),
            P([(72, 30), (80, 36), (72, 42)], "#fed7aa", BARRO, 1.6),
            R(30, 52, 92, 12, 3, AZUL, AZUL_OSCURO, 1.8),
            P([(122, 52), (130, 58), (122, 64)], "#fed7aa", BARRO, 1.6),
        ],
        "Comparación de dos lápices: el azul inferior es claramente más largo.")
    put("longest night", "C",
        fondo_noite() + fl("Crescent moon", 30, 16, 36) + [
            E(90, 22, 2.2, 2.2, BLANCO), E(112, 16, 2.0, 2.0, BLANCO), E(130, 28, 2.5, 2.5, BLANCO), E(76, 38, 2.0, 2.0, BLANCO),
        ] + nino_busto(80, 52, camisa=(AZUL, AZUL_OSCURO), r=8.5, brazos_arriba=False),
        "Noche invernal larga y oscura llena de estrellas y luna creciente.")
    put("pause", "D",
        fondo_sala() + [
            E(80, 50, 26, 26, AMARILLO, AMARILLO_OSCURO, 2.4),
            R(68, 37, 8, 26, 2, AZUL_OSCURO),
            R(84, 37, 8, 26, 2, AZUL_OSCURO),
        ],
        "Símbolo claro de pausa con dos barras verticales paralelas.")
    put("split in half", "D",
        fondo_mesa() + [
            L("M74 28 L70 20", BARRO, 2.6),
            F("M74 28 C50 28 46 66 74 68 Z", ROJO, ROJO_OSCURO, 2.0),
            F("M86 28 C110 28 114 66 86 68 Z", ROJO, ROJO_OSCURO, 2.0),
            R(68, 32, 6, 32, 2, "#fef3c7"),
            R(86, 32, 6, 32, 2, "#fef3c7"),
            E(71, 48, 1.5, 2.2, BARRO),
            E(89, 48, 1.5, 2.2, BARRO),
        ] + frecha((66, 16), (48, 16), AZUL_OSCURO, 2.0) + frecha((94, 16), (112, 16), AZUL_OSCURO, 2.0),
        "Manzana roja partida limpiamente en dos mitades iguales separadas.")
    put("still", "D",
        fondo_prado() + nino((58, 22), (58, 34), (58, 52), [[(48, 42)], [(68, 42)]], [[(53, 74)], [(63, 74)]], camisa=(AZUL, AZUL_OSCURO)) + [
            F("M92 74 Q94 54 110 56 Q126 58 128 74 Z", GRIS, GRIS_OSCURO, 2.2),
        ],
        "Niño completamente quieto de pie junto a una piedra firme.")
    put("stone statue", "D",
        fondo_prado() + [
            R(58, 62, 44, 16, 3, GRIS_OSCURO, NEGRO, 2.0),
            E(80, 24, 9, 9, GRIS, GRIS_OSCURO, 2.0),
            R(71, 34, 18, 22, 4, GRIS, GRIS_OSCURO, 2.0),
            L("M71 40 L54 34", GRIS_OSCURO, 3.6),
            L("M89 40 L106 34", GRIS_OSCURO, 3.6),
        ],
        "Estatua gris de piedra inmóvil sobre su pedestal.")
    put("take a break", "D",
        fondo_prado() + [
            R(44, 52, 72, 8, 2, MADERA, MADERA_OSCURA, 2.0),
            R(52, 60, 6, 16, 1, MADERA_OSCURA),
            R(102, 60, 6, 16, 1, MADERA_OSCURA),
        ] + nino_busto(80, 32, camisa=(VERDE, VERDE_OSCURO), r=9, ojos="cerrados"),
        "Niño o niña sentada en un banco descansando tranquila en una pausa.")
    put("taller", "D",
        fondo_sala() + [
            R(46, 56, 22, 20, 2, ROJO, ROJO_OSCURO, 1.8),
            R(90, 56, 22, 20, 2, AZUL, AZUL_OSCURO, 1.8),
            R(90, 36, 22, 20, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            R(90, 16, 22, 20, 2, VERDE, VERDE_OSCURO, 1.8),
        ],
        "Dos torres de bloques: la segunda torre es claramente más alta.")
    put("this one is darker than that one", "D",
        fondo_cielo("#f8fafc") + [
            E(52, 50, 16, 24, "#86efac", VERDE, 2.2),
            L("M52 28 L52 76", VERDE, 2.0),
            E(108, 50, 16, 24, VERDE_OSCURO, "#064e3b", 2.2),
            L("M108 28 L108 76", "#064e3b", 2.0),
        ],
        "Dos hojas lado a lado: una verde clara y otra mucho más oscura.")
    put("very dizzy", "D",
        fondo_sala() + nino((80, 32), (80, 44), (80, 60), [[(60, 46)], [(100, 46)]], [[(68, 78)], [(92, 78)]], camisa=(MORADO, AZUL_OSCURO)) + [
            L("M60 18 Q80 10 100 18", ROJO, 2.2),
            L("M64 12 Q80 20 96 12", AZUL_OSCURO, 2.2),
            E(58, 22, 2.5, 2.5, AMARILLO_OSCURO),
            E(102, 22, 2.5, 2.5, AMARILLO_OSCURO),
        ],
        "Niño tambaleándose mareado con espirales dando vueltas sobre la cabeza.")
    put("wait for green", "D",
        fondo_prado() + nino_busto(48, 48, camisa=(ROJO, ROJO_OSCURO), r=8.5) + [
            R(84, 14, 28, 60, 6, NEGRO, GRIS_OSCURO, 2.2),
            R(95, 74, 6, 8, 1, GRIS_OSCURO),
            E(98, 26, 6.5, 6.5, GRIS_OSCURO),
            E(98, 44, 6.5, 6.5, GRIS_OSCURO),
            E(98, 62, 7.5, 7.5, VERDE, "#86efac", 2.0),
            L("M112 62 L124 62", VERDE, 2.4),
            L("M110 54 L120 48", VERDE, 2.2),
            L("M110 70 L120 76", VERDE, 2.2),
        ],
        "Semáforo iluminado en verde abajo mientras el niño espera.")
    put("weigh", "C",
        fondo_mesa() + [
            L("M80 72 L80 28", GRIS_OSCURO, 3.2),
            L("M44 36 L116 24", GRIS_OSCURO, 3.0),
            R(36, 46, 22, 6, 2, DORADO, AMARILLO_OSCURO, 1.8),
            R(104, 34, 22, 6, 2, DORADO, AMARILLO_OSCURO, 1.8),
        ] + fl("Red apple", 36, 24, 22) + fl("Feather", 104, 14, 22),
        "Balanza comparando el peso de una manzana y una pluma ligera.")

    # ── Sacudir y temblar (`shake_move`, 26 escenas + `maraca` directa = 27) ─
    put("dripping clothes", "D",
        fondo_prado() + [
            L("M20 22 L140 22", NEGRO, 2.0),
            F("M54 24 L106 24 L112 40 L98 44 L94 34 L94 64 L66 64 L66 34 L62 44 L48 40 Z", AZUL, AZUL_OSCURO, 2.0),
        ] + gotas([(66, 70), (80, 74), (94, 70)]),
        "Camiseta mojada tendida en la cuerda goteando agua hacia abajo.")
    put("egg shaker", "D",
        fondo_sala() + [
            E(80, 48, 16, 22, AMARILLO, NARANJA_OSCURO, 2.2),
            L("M64 48 L96 48", ROJO, 3.0),
            L("M66 56 L94 56", VERDE, 2.6),
        ] + ondas_sonido(54, 46, MORADO, -1) + ondas_sonido(106, 46, MORADO, 1),
        "Huevo sonoro colorido vibrando con ondas de ritmo al agitarlo.")
    put("freezing", "C",
        fondo_cielo("#dbeafe") + copos_nieve([(30, 22), (130, 22), (80, 14)]) + nino_busto(80, 44, camisa=(AZUL, AZUL_OSCURO), r=11) + [
            L("M52 38 L46 44 L52 50", AZUL_OSCURO, 2.2),
            L("M108 38 L114 44 L108 50", AZUL_OSCURO, 2.2),
        ],
        "Niño o niña tiritando helada entre copos de nieve y líneas de temblor.")
    put("glitter", "C",
        fondo_sala() + fl("Jar", 52, 24, 52) + fl("Sparkles", 64, 40, 28) + [E(46, 28, 2.5, 2.5, DORADO), E(112, 34, 2.5, 2.5, ROSA), E(108, 60, 2, 2, AZUL)],
        "Bote transparente lleno de purpurina brillante centelleando.")
    put("grab and shake", "D",
        fondo_sala() + [
            L("M80 68 L80 42", MADERA_OSCURA, 3.4),
            E(80, 32, 13, 13, ROJO, ROJO_OSCURO, 2.0),
            E(72, 62, 10, 7, PEL, PELB, 1.8),
        ] + ondas_sonido(56, 32, NARANJA, -1) + ondas_sonido(104, 32, NARANJA, 1),
        "Mano sujetando un sonajero y agitándolo de lado a lado.")
    put("hold ice", "C",
        fondo_cielo("#e0f2fe") + fl("Open hands", 52, 42, 52) + fl("Ice", 62, 20, 36) + copos_nieve([(42, 24), (118, 24)]),
        "Manos sosteniendo un cubito de hielo helado con copos alrededor.")
    put("i'm a lion", "C",
        fondo_prado() + fl("Lion", 30, 24, 48) + nino((106, 24), (106, 36), (106, 52), [[(90, 30)], [(122, 30)]], [[(100, 74)], [(112, 74)]], camisa=(NARANJA, NARANJA_OSCURO)),
        "Niño imitando al león con zarpas arriba junto a un león.")
    put("icy", "D",
        fondo_cielo("#7dd3fc") + [
            P([(26, 18), (42, 18), (34, 46)], BLANCO, AZUL_OSCURO, 2.0),
            P([(52, 18), (74, 18), (63, 58)], BLANCO, AZUL_OSCURO, 2.0),
            P([(86, 18), (104, 18), (95, 50)], BLANCO, AZUL_OSCURO, 2.0),
            P([(116, 18), (132, 18), (124, 40)], BLANCO, AZUL_OSCURO, 2.0),
            E(80, 78, 54, 10, "#e0f2fe", AZUL_OSCURO, 2.2),
        ],
        "Carámbanos afilados de hielo helado colgando sobre placa helada.")
    put("jingle-jangle", "C",
        fondo_cielo("#e0f2fe") + [E(76, 26, 9, 9, BLANCO, GRIS_OSCURO, 2.4)] + fl("Key", 46, 30, 40) + fl("Key", 74, 32, 40) + ondas_sonido(42, 50, NARANJA_OSCURO, -1) + ondas_sonido(118, 50, NARANJA_OSCURO, 1),
        "Manojo de llaves tintineando con notas de sonido metálico al agitarse.")
    put("mane", "D",
        fondo_prado() + [
            E(80, 48, 28, 26, TIERRA_CLARA, BARRO, 2.4),
            E(60, 32, 9, 9, NARANJA_OSCURO), E(100, 32, 9, 9, NARANJA_OSCURO),
            E(54, 50, 9, 9, NARANJA_OSCURO), E(106, 50, 9, 9, NARANJA_OSCURO),
            E(80, 24, 11, 8, NARANJA_OSCURO),
            E(80, 48, 17, 16, "#fde68a", BARRO, 2.0),
            E(74, 45, 2, 2.5, TINTA), E(86, 45, 2, 2.5, TINTA),
            P([(77, 51), (83, 51), (80, 55)], BARRO),
        ] + lineas_viento(22, 42, 20, NARANJA),
        "Melena espesa y dorada de león agitándose con el movimiento.")
    put("nearly dry", "C",
        fondo_sala() + [
            R(42, 64, 76, 16, 6, BLANCO, GRIS_OSCURO, 2.2),
        ] + fl("Open hands", 58, 22, 44) + gotas([(80, 56)]),
        "Manos casi secas sobre el lavabo con una sola gotita final.")
    put("rattle toy", "D",
        fondo_sala() + [
            E(80, 62, 11, 11, BLANCO, AZUL_OSCURO, 4.0),
            L("M80 51 L80 42", AZUL_OSCURO, 3.6),
            E(80, 30, 14, 14, ROSA, ROSA_OSCURO, 2.0),
            E(75, 28, 3, 3, AMARILLO), E(85, 28, 3, 3, VERDE), E(80, 34, 3, 3, AZUL),
        ] + ondas_sonido(56, 30, AZUL_OSCURO, -1) + ondas_sonido(104, 30, AZUL_OSCURO, 1),
        "Sonajero de bebé de aro y bolas sonoras agitándose.")
    put("rattly", "D",
        fondo_mesa() + [
            R(66, 26, 28, 46, 7, "#e0f2fe", AZUL_OSCURO, 2.0),
            R(73, 19, 14, 7, 2, ROJO, ROJO_OSCURO, 1.8),
            E(74, 58, 2.2, 1.5, BLANCO), E(82, 62, 2.2, 1.5, BLANCO), E(86, 54, 2.2, 1.5, BLANCO), E(76, 66, 2.2, 1.5, BLANCO),
        ] + ondas_sonido(54, 46, ROJO, -1) + ondas_sonido(106, 46, ROJO, 1),
        "Botella transparente con arroz dentro sonando fuerte al agitarse.")
    put("refreshing splash", "C",
        fondo_mar() + fl("Open hands", 58, 38, 44) + gotas([(46, 28), (58, 20), (102, 20), (114, 28), (70, 54), (90, 54)]),
        "Salpicón refrescante de gotas claras saltando al sacudir las manos.")
    put("sandy", "C",
        fondo_cielo("#fef3c7") + [
            R(0, 74, 160, 26, 0, "#fde68a", BARRO, 2.0),
        ] + fl("Open hands", 56, 24, 48) + [
            E(60, 62, 2.4, 2.4, TIERRA), E(70, 68, 2.4, 2.4, BARRO), E(82, 65, 2.4, 2.4, TIERRA), E(92, 68, 2.4, 2.4, BARRO), E(100, 62, 2.4, 2.4, TIERRA),
        ],
        "Manos sacudiéndose granitos de arena dorada sobre la playa.")
    put("shake it all out", "D",
        fondo_prado() + nino((80, 20), (80, 32), (80, 50), [[(56, 32), (62, 42)], [(104, 32), (98, 42)]], [[(64, 72)], [(96, 72)]], camisa=(NARANJA, NARANJA_OSCURO)) + [
            L("M48 30 L42 38 L48 44", ROJO, 2.0),
            L("M112 30 L118 38 L112 44", ROJO, 2.0),
            L("M56 64 L50 72", AZUL_OSCURO, 2.0),
            L("M104 64 L110 72", AZUL_OSCURO, 2.0),
        ],
        "Niño sacudiendo enérgicamente brazos y piernas para soltar todo el cuerpo.")
    put("shake off", "C",
        fondo_sala() + fl("Open hands", 56, 22, 48) + gotas([(54, 62), (72, 68), (88, 68), (106, 62)]) + frecha((42, 32), (42, 56), AGUA_OSCURO, 2.2),
        "Manos sacudiendo hacia abajo las gotas de agua restantes.")
    put("shake out", "D",
        fondo_prado() + [
            F("M44 28 Q80 38 116 28 L112 64 Q80 72 48 64 Z", ROJO, ROJO_OSCURO, 2.0),
            E(42, 28, 5, 4, PEL, PELB, 1.6),
            E(118, 28, 5, 4, PEL, PELB, 1.6),
            E(66, 74, 4, 3, GRIS), E(94, 74, 4, 3, GRIS),
        ] + ondas_sonido(34, 44, ROJO_OSCURO, -1) + ondas_sonido(126, 44, ROJO_OSCURO, 1),
        "Sacudiendo una manta o alfombra al aire libre para quitar el polvo.")
    put("shake the bottle", "D",
        fondo_sala() + nino_busto(50, 44, camisa=(VERDE, VERDE_OSCURO), r=9.5) + [
            R(86, 26, 22, 38, 6, "#e0f2fe", AZUL_OSCURO, 2.0),
            R(92, 19, 10, 7, 2, AZUL_OSCURO),
            E(92, 54, 2, 1.6, TIERRA_CLARA), E(100, 56, 2, 1.6, TIERRA_CLARA), E(96, 48, 2, 1.6, TIERRA_CLARA),
        ] + frecha((116, 34), (116, 18), NARANJA, 2.0) + frecha((116, 48), (116, 64), NARANJA, 2.0),
        "Niño o niña agitando arriba y abajo una botella cerrada con granos dentro.")
    put("shake the glitter", "C",
        fondo_cielo("#e0f2fe") + fl("Jar", 54, 26, 48) + fl("Sparkles", 64, 38, 28) + ondas_sonido(44, 48, ROSA, -1) + ondas_sonido(116, 48, ROSA, 1),
        "Tarro de purpurina agitándose con ondas de movimiento y destellos.")
    put("shake the tree", "C",
        fondo_prado() + fl("Deciduous tree", 50, 14, 58) + fl("Red apple", 36, 56, 18) + fl("Red apple", 106, 58, 18) + ondas_sonido(42, 36, VERDE_OSCURO, -1) + ondas_sonido(118, 36, VERDE_OSCURO, 1),
        "Árbol frondoso sacudiéndose mientras caen manzanas rojas al suelo.")
    put("shaky", "C",
        fondo_prado() + fl("Open hands", 52, 36, 48) + [
            L("M44 40 L38 46 L44 52 L38 58", AZUL_OSCURO, 2.0),
            L("M108 40 L114 46 L108 52 L114 58", AZUL_OSCURO, 2.0),
        ] + fl("Leaf fluttering in wind", 112, 18, 28),
        "Manos temblorosas vibrando como hojas agitadas por el aire.")
    put("shiver", "C",
        fondo_cielo("#dbeafe") + copos_nieve([(26, 20), (134, 20)]) + nino((80, 22), (80, 34), (80, 52), [[(88, 42)], [(72, 44)]], [[(75, 74)], [(85, 74)]], camisa=(AZUL, AZUL_OSCURO)) + [
            L("M56 36 L50 42 L56 48", AZUL_OSCURO, 2.0),
            L("M104 36 L110 42 L104 48", AZUL_OSCURO, 2.0),
        ],
        "Niño encogido abrazándose el cuerpo mientras tiembla de frío.")
    put("take off", "D",
        fondo_sala() + nino((80, 32), (80, 44), (80, 60), [[(60, 26)], [(100, 26)]], [[(74, 80)], [(86, 80)]], camisa=(PEL, PELB)) + [
            F("M64 14 L96 14 L108 26 L100 34 L94 28 L94 34 L66 34 L66 28 L60 34 L52 26 Z", ROJO, ROJO_OSCURO, 2.0),
        ] + frecha((44, 38), (44, 16), AZUL_OSCURO, 2.2),
        "Niño o niña tirando hacia arriba para quitarse la camiseta.")
    put("watch the glitter settle", "D",
        fondo_mesa() + [
            R(64, 22, 32, 52, 7, "#e0f2fe", AZUL_OSCURO, 2.0),
            R(70, 15, 20, 7, 2, MORADO, AZUL_OSCURO, 1.8),
            E(72, 66, 3, 2, DORADO), E(80, 68, 3, 2, ROSA), E(88, 66, 3, 2, DORADO),
            E(76, 46, 2, 2, DORADO), E(84, 52, 2, 2, ROSA),
        ] + frecha((112, 30), (112, 62), MORADO, 2.4),
        "Tarro de la calma quieto viendo bajar la purpurina hacia el fondo.")
    put("wobbly legs", "D",
        fondo_sala() + [
            R(66, 18, 28, 24, 6, VERDE, VERDE_OSCURO, 2.0),
            L("M72 42 Q66 54 74 64 Q78 70 70 78", AZUL_OSCURO, 4.5),
            L("M88 42 Q94 54 86 64 Q82 70 90 78", AZUL_OSCURO, 4.5),
            L("M56 54 L50 60 L56 66", ROJO, 2.0),
            L("M104 54 L110 60 L104 66", ROJO, 2.0),
        ],
        "Piernas arqueadas temblando como flan de lado a lado.")

    # ── Alegría y sonrisas (`happy_smile`, 34 escenas + `cheerful face` directa = 35)
    put("big smile", "D",
        fondo_cielo("#fef9c3") + [
            E(80, 50, 28, 28, PEL, PELB, 2.4),
            F("M52 44 C54 16 106 16 108 44 C94 28 66 28 52 44 Z", BARRO),
            E(69, 44, 2.6, 3.2, TINTA),
            E(91, 44, 2.6, 3.2, TINTA),
            F("M64 56 Q80 74 96 56 Z", BLANCO, "#9a3412", 2.0),
        ],
        "Sonrisa enorme enseñando todos los dientes blancos con alegría.")
    put("brr, the arctic", "C",
        fondo_cielo("#dbeafe") + [
            P([(16, 76), (52, 42), (88, 76)], BLANCO, AGUA_OSCURO, 2.0),
            R(0, 72, 160, 28, 0, "#bae6fd", AGUA_OSCURO, 2.0),
        ] + fl("Polar bear", 92, 34, 46) + copos_nieve([(28, 22), (132, 22)]),
        "Oso polar en un glaciar nevado del Ártico entre copos de nieve.")
    put("bubbly baby", "C",
        fondo_sala() + bebe_sentado(80, 48, (ROSA, ROSA_OSCURO)) + pompas([(36, 32, 6), (48, 20, 4), (112, 24, 6), (124, 38, 4), (102, 44, 5)]),
        "Bebé risueño y feliz rodeado de pompas flotantes.")
    put("chirpy", "C",
        fondo_prado() + fl("Bird", 46, 30, 46) + notas_col([(102, 34), (116, 26), (126, 40)], AMARILLO_OSCURO),
        "Pajarito cantarín y alegre piando notas musicales.")
    put("clean", "C",
        fondo_sala() + fl("Open hands", 54, 34, 50) + fl("Sparkles", 30, 22, 28) + fl("Sparkles", 104, 22, 28),
        "Manos limpias y relucientes tras lavarse bien.")
    put("clean hands, happy baby", "C",
        fondo_sala() + bebe_sentado(56, 48, (AZUL, AZUL_OSCURO)) + fl("Open hands", 94, 36, 40) + fl("Sparkles", 106, 18, 24),
        "Bebé contento enseñando unas manos limpias y brillantes.")
    put("festive", "C",
        fondo_sala() + [
            P([(20, 14), (32, 14), (26, 26)], ROJO),
            P([(44, 14), (56, 14), (50, 26)], AMARILLO),
            P([(68, 14), (80, 14), (74, 26)], VERDE),
            P([(92, 14), (104, 14), (98, 26)], AZUL),
            P([(116, 14), (128, 14), (122, 26)], ROSA),
        ] + nino((80, 26), (80, 38), (80, 54), [[(60, 26)], [(100, 26)]], [[(68, 76)], [(92, 76)]], camisa=(ROJO, ROJO_OSCURO)) + fl("Balloon", 26, 38, 32),
        "Ambiente festivo con banderines, globo y niño bailando alegre.")
    put("friendly wolf", "C",
        fondo_prado() + fl("Wolf", 42, 28, 48) + fl("Waving hand", 96, 32, 34),
        "Lobo amigable saludando simpático en el prado.")
    put("funny", "D",
        fondo_cielo("#fef9c3") + [
            E(80, 50, 24, 24, PEL, PELB, 2.2),
            E(70, 44, 4, 4, TINTA),
            E(90, 44, 4, 4, TINTA),
            E(80, 52, 6, 6, ROJO, ROJO_OSCURO, 1.5),
            L("M66 60 Q80 72 94 60", "#9a3412", 2.2),
            E(58, 30, 8, 8, AMARILLO, NARANJA_OSCURO, 1.6),
            E(102, 30, 8, 8, AZUL, AZUL_OSCURO, 1.6),
        ],
        "Cara muy divertida de payaso haciendo reír.")
    put("giggly", "C",
        fondo_sala() + fl("Grinning face with smiling eyes", 36, 26, 46) + bebe_sentado(106, 48, (VERDE, VERDE_OSCURO)),
        "Risa contagiosa compartida jugando con el bebé.")
    put("grumpy", "D",
        fondo_cielo("#e2e8f0") + nino((80, 28), (80, 40), (80, 58), [[(88, 48)], [(72, 50)]], [[(74, 80)], [(86, 80)]], camisa=(MORADO, AZUL_OSCURO)) + [
            L("M72 25 L78 28", TINTA, 1.8),
            L("M88 25 L82 28", TINTA, 1.8),
            L("M76 34 Q80 31 84 34", "#9a3412", 1.5),
            E(34, 26, 10, 7, GRIS_OSCURO), E(44, 21, 12, 8, GRIS_OSCURO), E(54, 26, 10, 7, GRIS_OSCURO),
        ],
        "Niño con el ceño fruncido y brazos cruzados de mal humor.")
    put("honey is sweeter than lemon", "C",
        fondo_mesa() + fl("Honey pot", 26, 26, 44) + fl("Beaming face with smiling eyes", 56, 54, 24) + fl("Lemon", 92, 26, 42) + [
            E(114, 64, 10, 10, "#fde047", AMARILLO_OSCURO, 1.6),
            L("M108 61 L112 63 L108 65", TINTA, 1.4),
            L("M120 61 L116 63 L120 65", TINTA, 1.4),
            L("M110 69 Q114 67 118 69", TINTA, 1.4),
        ],
        "Tarro de miel dulce que hace sonreír frente al limón ácido.")
    put("i'm a tiger", "C",
        fondo_prado() + fl("Tiger", 28, 24, 48) + nino((106, 24), (106, 36), (106, 52), [[(90, 34)], [(122, 34)]], [[(100, 74)], [(112, 74)]], camisa=(NARANJA, NARANJA_OSCURO)),
        "Tigre rayado y niño o niña imitando sus zarpas con alegría.")
    put("jolly", "C",
        fondo_sala() + nino((80, 24), (80, 36), (80, 52), [[(60, 24)], [(100, 24)]], [[(68, 72)], [(92, 72)]], camisa=(AMARILLO, AMARILLO_OSCURO)) + notas([(34, 34), (48, 22), (114, 24), (128, 36)]),
        "Niño muy alegre saltando y riendo al ritmo de la música.")
    put("knock over", "D",
        fondo_mesa() + [
            R(50, 54, 18, 18, 2, AZUL, AZUL_OSCURO, 1.8),
            P([(74, 62), (92, 54), (98, 70), (80, 78)], ROJO, ROJO_OSCURO, 1.8),
            P([(98, 42), (116, 48), (110, 64), (92, 58)], VERDE, VERDE_OSCURO, 1.8),
        ] + frecha((46, 32), (82, 46), NARANJA, 2.6),
        "Torre de bloques derribándose y cayendo por la mesa.")
    put("last", "D",
        fondo_prado() + nino_caminando(44, 22, 1, (VERDE, VERDE_OSCURO)) + nino_caminando(76, 22, 1, (AZUL, AZUL_OSCURO)) + nino_caminando(108, 22, 1, (ROJO, ROJO_OSCURO)) + frecha((44, 6), (44, 18), ROJO, 2.4),
        "Fila de tres niños caminando hacia la derecha señalando al último atrás.")
    put("laugh", "D",
        fondo_cielo("#fef9c3") + nino((80, 24), (80, 36), (80, 52), [[(62, 34)], [(98, 34)]], [[(72, 74)], [(88, 74)]], camisa=(ROJO, ROJO_OSCURO)) + [
            L("M52 28 L44 22", NARANJA, 2.2),
            L("M50 38 L40 38", NARANJA, 2.2),
            L("M108 28 L116 22", NARANJA, 2.2),
            L("M110 38 L120 38", NARANJA, 2.2),
        ],
        "Niño o niña riendo a carcajadas con destellos de alegría alrededor.")
    put("laugh together", "D",
        fondo_prado() + nino_busto(58, 40, camisa=(ROJO, ROJO_OSCURO), r=9.5, brazos_arriba=True) + nino_busto(102, 40, camisa=(AZUL, AZUL_OSCURO), r=9.5, mira=-1, brazos_arriba=True) + [
            L("M74 22 L80 14 L86 22", AMARILLO_OSCURO, 2.2),
        ],
        "Dos amigos riendo juntos muy felices.")
    put("lights on", "C",
        fondo_cielo("#fef3c7") + fl("Light bulb", 56, 22, 48) + [
            L("M44 24 L32 16", AMARILLO_OSCURO, 2.4),
            L("M116 24 L128 16", AMARILLO_OSCURO, 2.4),
            L("M40 46 L26 46", AMARILLO_OSCURO, 2.4),
            L("M120 46 L134 46", AMARILLO_OSCURO, 2.4),
        ],
        "Bombilla recién encendida irradiando rayos de luz brillante.")
    put("nervous but ready", "C",
        fondo_sala() + nino((72, 22), (72, 34), (72, 52), [[(56, 40)], [(92, 28)]], [[(66, 74)], [(78, 74)]], camisa=(VERDE, VERDE_OSCURO)) + gotas([(56, 18)]) + fl("Thumbs up", 104, 34, 30),
        "Gotita de nervios respirando hondo y animándose con pulgar arriba.")
    put("playful summer", "C",
        fondo_mar() + fl("Sun", 18, 10, 34) + nino((66, 18), (66, 30), (66, 46), [[(48, 22)], [(84, 22)]], [[(58, 66)], [(74, 66)]], camisa=(AMARILLO, AMARILLO_OSCURO)) + pelota_prop(114, 52, 13, ROJO, ROJO_OSCURO),
        "Niño saltando alegre en la playa soleada jugando con pelota.")
    put("pose", "C",
        fondo_sala() + nino((56, 22), (56, 34), (56, 52), [[(40, 28)], [(72, 42)]], [[(50, 74)], [(62, 74)]], camisa=(ROSA, ROSA_OSCURO)) + fl("Camera", 96, 34, 42),
        "Niña posando sonriente delante de la cámara de fotos.")
    put("rested and happy", "C",
        fondo_sala() + fl("Sun", 118, 12, 30) + [
            R(28, 52, 104, 24, 5, AZUL, AZUL_OSCURO, 2.0),
            R(34, 46, 28, 10, 4, BLANCO, GRIS_OSCURO, 1.6),
        ] + nino_busto(80, 34, camisa=(AMARILLO, AMARILLO_OSCURO), r=9.5, brazos_arriba=True),
        "Niño o niña estirando los brazos contenta y descansada al despertar.")
    put("say cheese", "C",
        fondo_sala() + fl("Camera", 24, 28, 44) + [
            R(76, 22, 62, 54, 6, BLANCO, AMARILLO_OSCURO, 2.2),
        ] + nino_busto(107, 44, camisa=(ROJO, ROJO_OSCURO), r=11),
        "Cámara enfocando una gran sonrisa encuadrada para la foto.")
    put("show me your teeth", "D",
        fondo_cielo("#fef9c3") + [
            E(80, 50, 30, 22, ROJO, ROJO_OSCURO, 2.4),
            R(58, 42, 44, 16, 4, BLANCO, GRIS_OSCURO, 1.6),
            L("M58 50 L102 50", GRIS_OSCURO, 1.6),
            L("M69 42 L69 58", GRIS, 1.3),
            L("M80 42 L80 58", GRIS, 1.3),
            L("M91 42 L91 58", GRIS, 1.3),
        ],
        "Sonrisa grande mostrando las dos hileras limpias de dientes blancos.")
    put("smile at me", "D",
        fondo_cielo("#fef9c3") + [
            E(80, 50, 26, 26, PEL, PELB, 2.4),
            F("M54 44 C56 18 104 18 106 44 C92 28 68 28 54 44 Z", BARRO),
            E(70, 44, 2.4, 3.0, TINTA),
            E(90, 44, 2.4, 3.0, TINTA),
            E(63, 52, 4, 2.5, "#fca5a5"),
            E(97, 52, 4, 2.5, "#fca5a5"),
            L("M66 56 Q80 68 94 56", "#9a3412", 2.4),
        ],
        "Rostro cercano mirando de frente con una sonrisa cálida.")
    put("sparkly teeth", "C",
        fondo_cielo("#e0f2fe") + fl("Tooth", 56, 26, 46) + fl("Sparkles", 30, 22, 26) + fl("Sparkles", 104, 22, 26),
        "Diente blanco impecable rodeado de destellos brillantes.")
    put("spring", "C",
        fondo_prado() + fl("Sun", 18, 10, 34) + fl("Tulip", 44, 42, 34) + fl("Butterfly", 84, 24, 32) + fl("Deciduous tree", 106, 24, 46),
        "Prado primaveral con tulipán, mariposa, árbol verde y sol cálido.")
    put("summertime", "C",
        fondo_mar() + fl("Sun", 24, 12, 38) + fl("Sunglasses", 64, 28, 42) + fl("Ice cream", 110, 32, 38),
        "Ambiente veraniego con sol brillante, gafas de sol y helado.")
    put("sweet", "C",
        fondo_mesa() + fl("Candy", 32, 30, 42) + fl("Cupcake", 86, 28, 44),
        "Caramelo y pastelito dulce para saborear con una sonrisa.")
    put("take off your mask", "D",
        fondo_sala() + nino_busto(60, 44, camisa=(MORADO, AZUL_OSCURO), r=11) + [
            E(102, 34, 10, 8, ROJO, ROJO_OSCURO, 1.8),
            E(118, 34, 10, 8, ROJO, ROJO_OSCURO, 1.8),
            R(100, 31, 20, 6, 2, ROJO),
            E(102, 34, 4, 2.8, BLANCO, ROJO_OSCURO, 1.2),
            E(118, 34, 4, 2.8, BLANCO, ROJO_OSCURO, 1.2),
        ] + frecha((84, 52), (102, 42), VERDE_OSCURO, 2.2),
        "Niño quitándose el antifaz de carnaval mostrando su cara sonriente.")
    put("taste sweet", "C",
        fondo_mesa() + nino_busto(54, 44, camisa=(AMARILLO, AMARILLO_OSCURO), r=10.5) + fl("Spoon", 84, 38, 32) + fl("Honey pot", 104, 32, 36),
        "Niño o niña probando una cucharadita de miel dulce y sonriendo.")
    put("we share because we care", "C",
        fondo_prado() + nino_busto(46, 44, camisa=(ROJO, ROJO_OSCURO), r=9.5) + nino_busto(114, 44, camisa=(AZUL, AZUL_OSCURO), r=9.5, mira=-1) + fl("Red apple", 66, 38, 22) + fl("Red apple", 88, 38, 22),
        "Dos amigos repartiéndose por igual sus manzanas con cariño.")
    put("win or lose, we have fun", "C",
        fondo_prado() + nino_busto(48, 42, camisa=(VERDE, VERDE_OSCURO), r=9.5) + nino_busto(112, 42, camisa=(NARANJA, NARANJA_OSCURO), r=9.5, mira=-1) + [
            L("M64 56 L96 56", PELB, 4.6),
            L("M64 56 L96 56", PEL, 2.8),
        ] + pelota_prop(80, 74, 9, ROJO, ROJO_OSCURO) + fl("Trophy", 68, 14, 24),
        "Dos jugadores dándose la mano contentos después del partido.")

    # ── Sostener y llevar (`hold_carry`, 33 escenas + 6 directas = 39) ─────────
    put("bottle", "D",
        fondo_mesa() + [
            R(68, 26, 24, 46, 7, "#bae6fd", AZUL_OSCURO, 2.2),
            R(74, 16, 12, 10, 2, AZUL, AZUL_OSCURO, 1.8),
            L("M40 54 L66 50", PELB, 6.0), L("M40 54 L66 50", PEL, 3.6),
            L("M120 54 L94 50", PELB, 6.0), L("M120 54 L94 50", PEL, 3.6),
        ],
        "Dos manos sujetando firmemente una botella transparente.")
    put("bucket of water", "C",
        fondo_prado() + fl("Bucket", 56, 26, 48) + [E(80, 42, 14, 5, AGUA, AGUA_OSCURO, 1.5)] + gotas([(66, 24), (94, 24)]),
        "Cubo lleno hasta arriba con agua fresca para transportar con cuidado.")
    put("carry", "C",
        fondo_prado() + nino((64, 22), (64, 34), (64, 52), [[(48, 42)], [(86, 40)]], [[(58, 74)], [(70, 74)]], camisa=(ROJO, ROJO_OSCURO)) + fl("Basket", 82, 34, 38),
        "Niño llevando una cesta colgada en el brazo doblado.")
    put("carry carefully", "D",
        fondo_sala() + nino_caminando(58, 24, 1, (VERDE, VERDE_OSCURO), paso=6) + [
            R(74, 42, 38, 6, 2, MADERA, MADERA_OSCURA, 1.8),
        ] + _vaso_agua(94, 22, 14, 20),
        "Niño caminando despacito llevando una bandeja con un vaso sin derramar.")
    put("clean up, clean up", "C",
        fondo_sala() + caja_prop(92, 46, 38, AZUL, AZUL_OSCURO) + fl("Teddy bear", 98, 22, 28) + notas([(34, 28), (50, 20), (66, 30)]) + frecha((50, 52), (86, 52), VERDE_OSCURO, 2.4),
        "Notas alegres de canción mientras se recogen juguetes en la caja.")
    put("collect", "C",
        fondo_cielo("#e0f2fe") + [R(0, 68, 160, 32, 0, "#fde68a", BARRO, 2.0)] + fl("Open hands", 54, 16, 48) + fl("Spiral shell", 44, 56, 28) + fl("Spiral shell", 86, 56, 28),
        "Manos recogiendo conchas marinas bonitas de la orilla de arena.")
    put("cooperate", "D",
        fondo_sala() + nino_caminando(44, 24, 1, (AZUL, AZUL_OSCURO)) + nino_caminando(116, 24, -1, (ROJO, ROJO_OSCURO)) + caja_prop(64, 40, 32, TIERRA_CLARA, BARRO),
        "Dos niños sujetando cada uno un lado para llevar juntos la caja.")
    put("crate", "C",
        fondo_mesa() + [
            R(44, 42, 72, 34, 4, MADERA, MADERA_OSCURA, 2.2),
            L("M44 54 L116 54", MADERA_OSCURA, 2.0),
            L("M44 65 L116 65", MADERA_OSCURA, 2.0),
        ] + fl("Red apple", 50, 22, 24) + fl("Tangerine", 70, 22, 24) + fl("Red apple", 90, 22, 24),
        "Caja de madera de listones cargada de manzanas y naranjas.")
    put("drink water", "D",
        fondo_sala() + nino_busto(64, 42, camisa=(AZUL, AZUL_OSCURO), r=11) + [
            R(74, 42, 16, 22, 4, "#e0f2fe", AGUA_OSCURO, 1.8),
            R(75, 48, 14, 15, 2, AGUA),
        ] + frecha((102, 56), (92, 42), AGUA_OSCURO, 2.0),
        "Niño o niña acercando el vaso de agua a la boca para beber.")
    put("eat your greens", "C",
        fondo_mesa() + plato_prop(80, 56, 28) + fl("Broccoli", 62, 36, 26) + fl("Leafy green", 84, 38, 24) + fl("Fork and knife", 26, 38, 28),
        "Plato lleno de brócoli y verdura verde con tenedor listo.")
    put("first the blocks, then the cars", "D",
        fondo_sala() + [
            R(24, 46, 44, 30, 4, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(32, 32, 12, 12, 2, ROJO, ROJO_OSCURO, 1.5),
            R(46, 32, 12, 12, 2, AZUL, AZUL_OSCURO, 1.5),
            R(94, 46, 44, 30, 4, VERDE, VERDE_OSCURO, 2.0),
            R(102, 34, 24, 10, 4, ROJO, ROJO_OSCURO, 1.6),
            E(107, 45, 3, 3, NEGRO), E(121, 45, 3, 3, NEGRO),
        ] + frecha((70, 58), (90, 58), AZUL_OSCURO, 2.6),
        "Primero recoger los bloques a su caja y después los coches.")
    put("flamingo pose", "C",
        fondo_prado() + fl("Flamingo", 32, 20, 50) + nino((106, 22), (106, 34), (106, 52), [[(90, 38)], [(122, 38)]], [[(106, 74)], [(118, 56), (110, 64)]], camisa=(ROSA, ROSA_OSCURO)),
        "Flamenco rosa en una pata imitado por un niño o una niña en equilibrio.")
    put("go on holiday", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Sun", 118, 10, 30) + nino_caminando(58, 24, 1, (AMARILLO, AMARILLO_OSCURO)) + fl("Luggage", 84, 32, 42),
        "Niño saliendo feliz de vacaciones llevando su maleta.")
    put("hair tie", "D",
        fondo_sala() + [
            E(80, 48, 16, 16, PEL, PELB, 2.0),
            F("M64 42 C66 24 94 24 96 42 Z", BARRO),
            F("M96 36 C116 32 126 52 108 62 C110 48 102 44 96 44 Z", BARRO),
            R(93, 36, 7, 10, 3, ROSA, ROSA_OSCURO, 1.8),
        ],
        "Coleta recogida atrás con una goma elástica rosa para el pelo.")
    put("hard-working", "D",
        fondo_prado() + nino_caminando(68, 24, 1, (AZUL, AZUL_OSCURO)) + caja_prop(84, 38, 22, MADERA, MADERA_OSCURA) + caja_prop(84, 16, 22, AMARILLO, AMARILLO_OSCURO) + frecha((116, 52), (138, 52), VERDE_OSCURO, 2.4),
        "Niño trabajador llevando cajas apiladas de un sitio a otro.")
    put("hat brim", "D",
        fondo_prado() + [
            E(76, 54, 36, 9, "#fde68a", AMARILLO_OSCURO, 2.2),
            F("M56 52 C58 28 94 28 96 52 Z", "#fde68a", AMARILLO_OSCURO, 2.2),
            L("M56 48 L96 48", ROJO, 3.0),
            L("M132 62 L110 54", PELB, 6.0), L("M132 62 L110 54", PEL, 3.6),
            E(110, 54, 6, 4.5, PEL, PELB, 1.6),
        ] + lineas_viento(16, 34, 24, AGUA_OSCURO),
        "Mano sujetando el ala ancha del sombrero de paja frente al viento.")
    put("helpful", "D",
        fondo_sala() + nino_busto(48, 42, camisa=(VERDE, VERDE_OSCURO), r=9.5) + nino_busto(112, 42, camisa=(ROSA, ROSA_OSCURO), r=9.5, mira=-1) + caja_prop(64, 52, 32, AZUL, AZUL_OSCURO) + pelota_prop(80, 42, 8, ROJO, ROJO_OSCURO),
        "Dos amigos serviciales ayudándose a guardar los juguetes en la caja.")
    put("heron", "D",
        fondo_mar() + [
            R(0, 68, 160, 32, 0, AGUA),
            L("M78 52 L78 76", NARANJA_OSCURO, 2.6),
            L("M82 52 L88 62 L80 62", NARANJA_OSCURO, 2.4),
            E(78, 44, 16, 10, GRIS, GRIS_OSCURO, 2.0),
            L("M90 38 Q94 28 92 20", BLANCO, 4.5),
            E(92, 20, 5, 4, BLANCO, GRIS_OSCURO, 1.8),
            P([(96, 19), (110, 21), (96, 23)], NARANJA),
            L("M34 74 L34 44", VERDE_OSCURO, 2.4),
            L("M40 74 L40 50", VERDE, 2.2),
        ],
        "Garza blanca y gris de patas largas quieta sobre una sola pata.")
    put("hold", "C",
        fondo_prado() + fl("Open hands", 52, 42, 52) + pelota_prop(78, 36, 14, ROJO, ROJO_OSCURO),
        "Dos manos abiertas sujetando firme una pelota roja sin dejarla caer.")
    put("hold steady", "D",
        fondo_mesa() + [
            R(66, 56, 28, 16, 2, AZUL, AZUL_OSCURO, 1.8),
            R(68, 40, 24, 16, 2, ROJO, ROJO_OSCURO, 1.8),
            R(70, 24, 20, 16, 2, AMARILLO, AMARILLO_OSCURO, 1.8),
            L("M34 52 L64 46", PELB, 6.0), L("M34 52 L64 46", PEL, 3.6),
            L("M126 52 L96 46", PELB, 6.0), L("M126 52 L96 46", PEL, 3.6),
        ],
        "Dos manos sujetando firme una torre alta de bloques para que no caiga.")
    put("ice cube", "C",
        fondo_cielo("#e0f2fe") + fl("Open hands", 52, 44, 50) + [
            R(64, 20, 30, 28, 4, "#bae6fd", AGUA_OSCURO, 2.2),
            L("M69 25 L82 25", BLANCO, 2.0),
        ],
        "Cubito cuadrado de hielo frío sostenido sobre las manos.")
    put("in the shade", "C",
        fondo_prado() + fl("Sun", 122, 10, 30) + fl("Deciduous tree", 34, 12, 62) + [
            E(66, 76, 42, 10, "#15803d"),
        ] + manta_prop(46, 58, 38, "#fde68a", 20) + bebe(66, 58, "#bae6fd", AZUL_OSCURO),
        "Bebé resguardado sobre su mantita en la sombra fresca del árbol.")
    put("lantern light", "C",
        fondo_noite() + [E(80, 48, 36, 36, "#fef08a")] + fl("Red paper lantern", 56, 22, 48),
        "Luz cálida amarilla irradiando alrededor del farol en la noche.")
    put("laundry basket", "D",
        fondo_sala() + [
            F("M44 46 L116 46 L106 76 L54 76 Z", MADERA, MADERA_OSCURA, 2.2),
            L("M49 58 L111 58", MADERA_OSCURA, 1.6),
            L("M52 68 L108 68", MADERA_OSCURA, 1.6),
            E(62, 40, 14, 9, ROJO, ROJO_OSCURO, 1.8),
            E(84, 38, 15, 10, AZUL, AZUL_OSCURO, 1.8),
            E(100, 42, 11, 8, AMARILLO, AMARILLO_OSCURO, 1.8),
        ],
        "Cesto trenzado lleno de ropa limpia doblada encima.")
    put("look through the binoculars", "C",
        fondo_prado() + nino_busto(78, 46, camisa=(VERDE, VERDE_OSCURO), r=11) + ico("tabler", "binoculars", 64, 28, 28, NEGRO),
        "Niño o niña mirando a lo lejos con unos prismáticos delante de los ojos.")
    put("palette", "D",
        fondo_sala() + [
            E(80, 50, 34, 24, MADERA, MADERA_OSCURA, 2.2),
            E(62, 56, 6, 4, "#fef3c7", MADERA_OSCURA, 1.6),
            E(68, 38, 5, 5, ROJO),
            E(82, 34, 5, 5, AMARILLO),
            E(96, 40, 5, 5, AZUL),
            E(96, 56, 5, 5, VERDE),
            L("M98 72 L126 30", BARRO, 3.2),
        ],
        "Paleta de madera con manchas de colores y pincel.")
    put("snack", "C",
        fondo_mesa() + plato_prop(80, 56, 28) + fl("Red apple", 58, 30, 28) + fl("Cookie", 82, 34, 26),
        "Merienda sana con manzana y galleta servidas en el plato.")
    put("stand like a heron", "C",
        fondo_mar() + nino((54, 20), (54, 32), (54, 50), [[(40, 38)], [(68, 38)]], [[(54, 72)], [(66, 56), (58, 64)]], camisa=(AZUL, AZUL_OSCURO)) + [
            L("M106 54 L106 74", NARANJA_OSCURO, 2.4),
            E(106, 46, 12, 8, BLANCO, GRIS_OSCURO, 1.8),
            L("M114 40 L116 26", BLANCO, 3.8),
            E(116, 26, 4, 3.5, BLANCO, GRIS_OSCURO, 1.6),
            P([(120, 25), (130, 26), (120, 28)], NARANJA),
        ],
        "Niño o niña sosteniéndose en un pie imitando a la garza del agua.")
    put("taste", "C",
        fondo_mesa() + nino_busto(56, 44, camisa=(ROSA, ROSA_OSCURO), r=10.5, ojos="cerrados") + [
            L("M72 48 L92 56", GRIS_OSCURO, 2.8),
            E(70, 48, 5, 3.5, GRIS, GRIS_OSCURO, 1.6),
        ] + fl("Bowl with spoon", 94, 34, 40),
        "Saboreando despacio una cucharadita con los ojos cerrados de gusto.")
    put("tidy up", "C",
        fondo_sala() + caja_prop(78, 46, 38, VERDE, VERDE_OSCURO) + fl("Teddy bear", 86, 22, 26) + pelota_prop(40, 64, 9, ROJO, ROJO_OSCURO) + frecha((46, 52), (72, 42), AZUL_OSCURO, 2.4),
        "Juguetes sueltos recogidos y guardados dentro de su caja.")
    put("tidy your room", "D",
        fondo_sala() + [
            R(22, 46, 48, 28, 4, AZUL, AZUL_OSCURO, 2.0),
            R(24, 38, 18, 10, 3, BLANCO, GRIS_OSCURO, 1.6),
            E(80, 74, 24, 8, "#fca5a5", ROJO_OSCURO, 1.8),
            R(102, 48, 34, 26, 3, VERDE, VERDE_OSCURO, 2.0),
            R(108, 36, 10, 12, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
            R(120, 38, 10, 10, 2, ROJO, ROJO_OSCURO, 1.6),
        ],
        "Habitación ordenada con cama hecha, alfombra y juguetes guardados.")
    put("tray", "D",
        fondo_mesa() + [
            R(36, 56, 88, 12, 4, MADERA, MADERA_OSCURA, 2.2),
            R(28, 52, 10, 8, 2, MADERA_OSCURA),
            R(122, 52, 10, 8, 2, MADERA_OSCURA),
        ] + _vaso_agua(64, 28, 20, 28) + [E(102, 48, 12, 7, "#fbbf24", BARRO, 1.8)],
        "Bandeja de servir con asas llevando un vaso y un bollo.")
    put("weigh up", "D",
        fondo_prado() + nino_busto(80, 36, camisa=(MORADO, AZUL_OSCURO), r=9.5) + [
            L("M68 46 L42 54", PELB, 4.4), L("M68 46 L42 54", PEL, 2.6),
            L("M92 46 L118 46", PELB, 4.4), L("M92 46 L118 46", PEL, 2.6),
            E(42, 44, 9, 9, ROJO, ROJO_OSCURO, 1.8),
            E(118, 38, 6, 4, BLANCO, GRIS_OSCURO, 1.6),
        ],
        "Niño sopesando una manzana pesada y una pluma ligera con las manos.")
    put("wooden plank", "D",
        fondo_prado() + nino_caminando(44, 24, 1, (VERDE, VERDE_OSCURO)) + nino_caminando(116, 24, -1, (AMARILLO, AMARILLO_OSCURO)) + [
            R(34, 42, 92, 11, 2, MADERA, MADERA_OSCURA, 2.0),
            L("M44 47 L116 47", BARRO, 1.4),
        ],
        "Dos niños llevando juntos una tabla larga de madera entre los dos.")

    # ── Primeras 3 de crear/dibujar (`make_draw`) ──────────────────────────
    put("bug hotel", "C",
        fondo_prado() + [
            P([(48, 36), (80, 14), (112, 36)], MADERA_OSCURA, BARRO, 2.0),
            R(52, 36, 56, 40, 3, MADERA, MADERA_OSCURA, 2.2),
            R(56, 40, 22, 16, 2, "#fde68a", BARRO, 1.5),
            E(62, 48, 3.5, 3.5, BARRO), E(72, 48, 3.5, 3.5, BARRO),
            R(82, 40, 22, 16, 2, TIERRA_CLARA, BARRO, 1.5),
            R(56, 58, 48, 14, 2, HERBAB, VERDE_OSCURO, 1.5),
        ] + fl("Lady beetle", 86, 40, 20),
        "Casita de madera rellena de ramitas y tubos para refugio de insectos.")
    put("butterfly print", "D",
        fondo_mesa() + [
            R(36, 22, 88, 56, 4, BLANCO, GRIS_OSCURO, 2.0),
            L("M80 22 L80 78", GRIS, 1.5),
            E(64, 42, 14, 11, MORADO, AZUL_OSCURO, 1.8),
            E(96, 42, 14, 11, MORADO, AZUL_OSCURO, 1.8),
            E(66, 58, 11, 9, ROSA, ROSA_OSCURO, 1.8),
            E(94, 58, 11, 9, ROSA, ROSA_OSCURO, 1.8),
            R(78, 32, 4, 34, 2, NEGRO),
        ],
        "Papel doblado abierto mostrando una mariposa simétrica estampada con pintura.")
    put("card making", "C",
        fondo_mesa() + [
            P([(38, 72), (38, 28), (74, 20), (74, 64)], BLANCO, AZUL_OSCURO, 2.0),
            P([(74, 20), (110, 28), (110, 72), (74, 64)], "#fef3c7", AZUL_OSCURO, 2.0),
            E(92, 46, 9, 9, ROJO, ROJO_OSCURO, 1.6),
            E(92, 46, 3.5, 3.5, AMARILLO),
        ] + fl("Paintbrush", 104, 34, 36),
        "Postal doblada decorada con una flor junto al pincel de pintar.")

    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    # water_action (3)
    "thank-you note": "Tarjetita social («Nota de agradecimiento»); sin texto es indistinguible de cualquier postal o carta.",
    "wasteful": "Adjetivo moral abstracto («Que desperdicia»); no se distingue claramente de un grifo abierto o salpicar.",
    "where are your toes": "Pregunta lúdica verbal («¿Dónde están tus deditos?»); depende del juego hablado de buscarlos.",
    # eat_drink (1)
    "flavour": "Sustantivo sensorial abstracto («Sabor»); cualidad invisible sin referente visual único.",
    # blow (3)
    "fresh breath": "Sensación invisible («Aliento fresco»); no tiene imagen propia diferenciable de «minty» o «breeze».",
    "ready, set, blow": "Señal verbal de inicio («¡Preparados, listos, sopla!»); orden de turno sin objeto distinto.",
    "which boat is faster": "Pregunta comparativa («¿Qué barco es más rápido?»); requiere lectura comparativa.",
    # stop_freeze (14)
    "clap, stamp, clap, stamp, what comes next": "Pregunta de secuencia rítmica («Palma, pie, palma, pie, ¿qué viene ahora?»).",
    "difference": "Concepto lógico abstracto («Diferencia»).",
    "does that tickle": "Pregunta conversacional táctil («¿Hace cosquillas?»).",
    "don't move a muscle": "Orden verbal enfática («¡No te muevas nada!»); redundante con «stone statue» y «still».",
    "freeze immediately": "Orden verbal de parada («Congelarse al momento»); redundante sin texto.",
    "freeze on command": "Regla verbal de juego («Pararse a la orden»).",
    "is it the same on both sides": "Pregunta lógica comparativa («¿Es igual en los dos lados?»).",
    "ready, steady, stop": "Señal verbal de juego («¡Preparados, listos, para!»).",
    "stop right there": "Orden verbal de alto («¡Para ahí!»); redundante sin texto.",
    "stop spinning": "Orden verbal de parada («¡Deja de girar!»).",
    "sudden": "Adjetivo temporal abstracto («Repentino»).",
    "when i say freeze, don't move": "Regla condicional con palabra citada («Cuando diga freeze, no te muevas»).",
    "when the conductor stops, we stop": "Regla condicional grupal («Cuando el director para, nosotros paramos»).",
    "which is the biggest": "Pregunta comparativa («¿Cuál es el más grande?»).",
    # shake_move (2)
    "is ice hot or cold": "Pregunta de temperatura («¿El hielo es caliente o frío?»).",
    "shake the tree gently": "Variante adverbial («¡Sacude el árbol despacio!»); redundante con «shake the tree» sin texto.",
    # happy_smile (6)
    "grrr, grrr": "Onomatopeya vocal pura («¡Grrr, grrr!»); sonido sin referente propio fuera de león/tigre.",
    "is it sweet or sour": "Pregunta sensorial («¿Es dulce o ácido?»).",
    "kind words": "Expresión invisible del habla («Palabras amables»); prohibido dibujar texto o diálogo escrito.",
    "kindest": "Superlativo moral abstracto («El más amable»).",
    "satisfied": "Estado interior sutil («Satisfecho»); indistinguible de «happy» o «smile».",
    "smile of thanks": "Matiz social abstracto («Sonrisa de agradecimiento»); indistinguible de otras sonrisas sin texto.",
    # hold_carry (3)
    "hold it, please": "Petición verbal cortés («¡Sujétalo, por favor!»); redundante con «hold» y «hold steady».",
    "useful helper": "Epíteto valorativo («Ayudante útil»); redundante con «helpful» y «cooperate».",
    "word": "Unidad lingüística abstracta («Palabra»); no se representa sin texto ni letras.",
}
