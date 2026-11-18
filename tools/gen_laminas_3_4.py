#!/usr/bin/env python3
"""Generador de las 164 láminas nuevas de 3-4 años (P2.5, O-20261111-4).

Cubre todas las piezas restantes de `curso_3_4` en `leccions.json`
hasta dejar `curso_3_4` a 0 piezas sin lámina.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
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
    E,
    F,
    GRIS,
    GRIS_OSCURO,
    L,
    LECCIONS_PATH,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
    MAR_PROF,
    MORADO,
    P,
    PEL,
    PELB,
    R,
    ROJO,
    ROJO_OSCURO,
    TIERRA,
    TIERRA_CLARA,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    copos_nieve,
    escribir_cd,
    escribir_fluent_directo,
    escribir_reutilizada,
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
    notas,
    pano,
    pompas,
    slug_de,
)

SCRIPT_REF = "tools/gen_laminas_3_4.py"

# ── Banco directo Fluent Emoji Flat (MIT) ────────────────────────────────
FLUENT_DIRECTOS = {
    "banana": ("pal_banana", "Banana", "U", "Plátano amarillo curvado."),
    "chestnut": ("pal_chestnut", "Chestnut", "U", "Castaña brillante de otoño."),
    "cow": ("pal_cow", "Cow", "U", "Vaca blanca y negra de perfil."),
    "frog": ("pal_frog", "Frog", "U", "Rana verde de frente."),
    "horse": ("pal_horse", "Horse", "U", "Caballo marrón de perfil."),
    "sheep": ("pal_sheep", "Ewe", "R", "Oveja blanca lanuda de perfil."),
    "shell": ("pal_shell", "Spiral shell", "R", "Concha marina en espiral."),
    "snow": ("pal_snow", "Snowflake", "R", "Copo de nieve blanco y azul."),
    "spoon": ("pal_spoon", "Spoon", "U", "Cuchara metálica limpia."),
    "train": ("pal_train", "Train", "U", "Tren de pasajeros de perfil."),
    "umbrella": ("pal_umbrella", "Umbrella", "U", "Paraguas abierto con gotas de lluvia."),
}

PROPIAS_REUTILIZADAS = {}


def _acorn(x: float, y: float, s: float = 1.0) -> list[dict]:
    """Bellota dibujada a mano (sin emoji propio en Fluent)."""
    return [
        E(x, y + 7 * s, 9 * s, 11 * s, "#b45309", BARRO, 1.8),
        F(
            f"M{x - 11*s:.1f} {y + 1*s:.1f} C{x - 11*s:.1f} {y - 8*s:.1f} {x + 11*s:.1f} {y - 8*s:.1f} {x + 11*s:.1f} {y + 1*s:.1f} Z",
            BARRO,
            TINTA,
            1.8,
        ),
        L(f"M{x:.1f} {y - 6*s:.1f} L{x + 2*s:.1f} {y - 11*s:.1f}", BARRO, 2.5),
    ]


def _pumpkin(x: float, y: float, r: float = 22) -> list[dict]:
    """Calabaza lisa sin cara (O-20261111-4)."""
    return [
        R(x - 3, y - r - 7, 6, 9, 2, VERDE_OSCURO, TINTA, 1.6),
        E(x - r * 0.45, y, r * 0.65, r, "#ea580c", "#9a3412", 2),
        E(x + r * 0.45, y, r * 0.65, r, "#ea580c", "#9a3412", 2),
        E(x, y, r * 0.65, r, "#f97316", "#9a3412", 2),
    ]


def _vaso(x: float, y: float, w: float, h: float, nivel: float = 0.0) -> list[dict]:
    """Vaso transparente con nivel opcional de líquido (0.0 a 1.0)."""
    formas = [
        F(
            f"M{x:.1f} {y:.1f} L{x + w:.1f} {y:.1f} L{x + w - 4:.1f} {y + h:.1f} L{x + 4:.1f} {y + h:.1f} Z",
            "#e0f2fe",
            AZUL_OSCURO,
            2,
        )
    ]
    if nivel > 0:
        nh = (h - 6) * nivel
        ny = y + h - nh - 2
        dx = 3.5 * (1 - nivel)
        formas.append(
            F(
                f"M{x + 3 + dx:.1f} {ny:.1f} L{x + w - 3 - dx:.1f} {ny:.1f} L{x + w - 5:.1f} {y + h - 2:.1f} L{x + 5:.1f} {y + h - 2:.1f} Z",
                AGUA,
                AGUA_OSCURO,
                1.5,
            )
        )
    return formas


def _escenas_3_4() -> dict[str, tuple[str, str, list[dict], str]]:
    out: dict[str, tuple[str, str, list[dict], str]] = {}

    def put(en: str, cd: str, formas: list[dict], porque: str, slug: str | None = None) -> None:
        key = en.lower().strip(" .!?")
        out[key] = (slug or slug_de(key), cd, formas, porque)

    # ── Sustantivos y objetos cotidianos ───────────────────────────────────
    put("block", "D", fondo_mesa() + [
        R(52, 24, 56, 52, 5, ROJO, ROJO_OSCURO, 2.5),
        R(62, 16, 16, 8, 2, ROJO, ROJO_OSCURO, 2),
        R(84, 16, 16, 8, 2, ROJO, ROJO_OSCURO, 2),
    ], "Bloque de construcción rojo de madera sobre mesa.")
    put("boots", "D", fondo_prado() + [
        R(44, 24, 24, 48, 5, AZUL, AZUL_OSCURO, 2),
        R(44, 62, 34, 14, 5, AZUL, AZUL_OSCURO, 2),
        R(90, 24, 24, 48, 5, AZUL, AZUL_OSCURO, 2),
        R(90, 62, 34, 14, 5, AZUL, AZUL_OSCURO, 2),
        R(44, 24, 24, 8, 2, BLANCO, GRIS_OSCURO, 1.5),
        R(90, 24, 24, 8, 2, BLANCO, GRIS_OSCURO, 1.5),
    ], "Par de botas azules de invierno con borde blanco.")
    put("brush", "C", fondo_mesa() + fl("Paintbrush", 46, 16, 66),
        "Pincel de pintura limpio en primer plano.")
    put("costume", "C", fondo_sala() + fl("Coat", 26, 20, 56) + [
        F("M100 32 L134 32 L140 72 L94 72 Z", MORADO, TINTA, 2),
        F("M108 32 L117 22 L126 32 Z", AMARILLO, AMARILLO_OSCURO, 1.8),
    ], "Capa y disfraz festivo colgados en la sala.")
    put("cup", "C", fondo_mesa() + fl("Teacup without handle", 46, 18, 66),
        "Taza limpia encima de la mesa.")
    put("fork", "D", fondo_mesa() + [
        R(75, 42, 10, 42, 4, GRIS, GRIS_OSCURO, 2),
        R(66, 30, 28, 16, 4, GRIS, GRIS_OSCURO, 2),
        L("M72 16 L72 34", GRIS_OSCURO, 3.5),
        L("M80 16 L80 34", GRIS_OSCURO, 3.5),
        L("M88 16 L88 34", GRIS_OSCURO, 3.5),
    ], "Tenedor metálico de tres púas en posición vertical.")
    put("friend", "C", fondo_prado() + nino((52, 26), (52, 38), (52, 58), [[(38, 46)], [(72, 48)]], [[(46, 84)], [(58, 84)]])
        + nino((106, 26), (106, 38), (106, 58), [[(86, 48)], [(120, 46)]], [[(100, 84)], [(112, 84)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos amigos sonriendo y dándose la mano en el prado.")
    put("grass", "C", fondo_prado() + fl("Herb", 26, 22, 54) + fl("Herb", 80, 22, 54),
        "Briznas verdes de hierba fresca creciendo.")
    put("juice", "C", fondo_mesa() + _vaso(56, 20, 46, 54, 0.72) + [
        F("M60 40 L98 40 L96 72 L62 72 Z", "#fb923c", "#c2410c", 1.5),
        L("M88 10 L82 40", ROJO, 3),
    ] + fl("Tangerine", 104, 42, 34), "Vaso lleno de zumo naranja con pajita y naranja.")
    put("knees", "C", fondo_sala() + nino((78, 22), (78, 34), (78, 54), [[(64, 46)], [(92, 46)]], [[(72, 84)], [(84, 84)]])
        + frecha((40, 68), (64, 68), ROJO_OSCURO, 3.5)
        + frecha((116, 68), (92, 68), ROJO_OSCURO, 3.5),
        "Flechas rojas señalando las dos rodillas del niño.")
    put("light", "C", fondo_noite() + fl("Light bulb", 48, 12, 62),
        "Bombilla encendida irradiando luz amarilla brillante.")
    put("mask", "D", fondo_sala() + [
        E(52, 30, 12, 12, TIERRA, BARRO, 2),
        E(108, 30, 12, 12, TIERRA, BARRO, 2),
        E(80, 48, 34, 24, TIERRA_CLARA, BARRO, 2.5),
        E(66, 44, 7, 5, BLANCO, TINTA, 2),
        E(94, 44, 7, 5, BLANCO, TINTA, 2),
        E(80, 56, 6, 4, TINTA),
    ], "Máscara de animal con orejas y agujeros para los ojos.")
    put("nest", "C", fondo_prado() + fl("Empty nest", 46, 22, 66),
        "Nido de ramitas tejido y redondo.")
    put("page", "D", fondo_mesa() + [
        R(44, 14, 72, 68, 4, BLANCO, GRIS_OSCURO, 2.5),
        L("M56 28 L104 28", AGUA_OSCURO, 2.5),
        L("M56 40 L104 40", GRIS_OSCURO, 2),
        L("M56 52 L96 52", GRIS_OSCURO, 2),
        L("M56 64 L88 64", GRIS_OSCURO, 2),
    ], "Página de papel con líneas escritas de un cuento.")
    put("plate", "D", fondo_mesa() + [
        E(80, 48, 44, 30, BLANCO, GRIS_OSCURO, 2.5),
        E(80, 48, 28, 18, "#f8fafc", GRIS, 2),
    ], "Plato redondo limpio visto desde arriba.")
    put("puddle", "D", fondo_prado() + [
        E(80, 62, 46, 16, AGUA, AGUA_OSCURO, 2.5),
        E(72, 59, 20, 6, "#bae6fd"),
    ] + gotas([(62, 26), (92, 20)]), "Charco grande de agua azul en el suelo con gotitas.")
    put("pumpkin", "D", fondo_prado() + _pumpkin(80, 50, 26),
        "Calabaza naranja redonda de otoño sin cara.")
    put("rain", "C", fondo_cielo() + fl("Cloud with rain", 42, 12, 68) + gotas([(56, 72), (80, 76), (104, 70)]),
        "Nube de lluvia soltando gotas abundantes de agua.")
    put("raincoat", "D", fondo_prado() + [
        F("M56 24 L104 24 L122 46 L112 54 L102 42 L102 80 L58 80 L58 42 L48 54 L38 46 Z", AMARILLO, AMARILLO_OSCURO, 2.5),
        F("M64 24 Q80 8 96 24 Z", AMARILLO, AMARILLO_OSCURO, 2),
        L("M80 24 L80 80", AMARILLO_OSCURO, 2),
    ] + gotas([(32, 24), (126, 28)]), "Chubasquero impermeable amarillo con capucha bajo la lluvia.")
    put("sea", "C", fondo_mar() + fl("Water wave", 28, 30, 54) + fl("Water wave", 78, 34, 52),
        "Olas azules extendiéndose por el mar.")
    put("seed", "D", fondo_prado() + [
        F("M56 54 Q80 44 104 54 L112 80 L48 80 Z", BARRO, TINTA, 2),
        E(80, 56, 8, 5, AMARILLO_OSCURO, TINTA, 2),
        E(80, 56, 3, 2, TIERRA_CLARA),
    ], "Semilla única posada sobre tierra fértil.")
    put("soil", "D", fondo_prado() + [
        F("M28 74 Q54 38 82 42 Q110 40 132 74 Z", BARRO, TINTA, 2.2),
        E(62, 60, 4, 3, TIERRA_CLARA),
        E(94, 58, 5, 3, TIERRA_CLARA),
        E(78, 66, 4, 2.5, TIERRA_CLARA),
    ], "Montículo oscuro de tierra de jardín.")
    put("story", "C", fondo_mesa() + fl("Open book", 34, 16, 62) + [
        R(98, 28, 38, 46, 4, AMARILLO, AMARILLO_OSCURO, 2),
        E(117, 50, 8, 8, ROJO, ROJO_OSCURO, 1.5),
    ], "Libro de cuentos abierto mostrando imágenes y páginas.")
    put("waves", "C", fondo_mar() + fl("Water wave", 22, 24, 52) + fl("Water wave", 74, 20, 56),
        "Varias olas azules levantándose en el mar.")

    # ── Adjetivos, conceptos sonoros y fórmulas corteses ───────────────────
    put("broken", "D", fondo_mesa() + [
        F("M34 32 L72 32 L64 46 L74 56 L66 72 L34 72 Z", ROJO, ROJO_OSCURO, 2),
        F("M88 32 L126 32 L126 72 L86 72 L94 56 L84 46 Z", ROJO, ROJO_OSCURO, 2),
        L("M78 24 L72 38 L82 48 L74 62 L80 78", AMARILLO_OSCURO, 2.5),
    ], "Pieza partida por la mitad mostrando rotura clara.")
    put("delicious", "C", fondo_mesa() + fl("Red apple", 26, 26, 44) + fl("Birthday cake", 72, 20, 48) + [
        L("M126 22 L134 14", AMARILLO_OSCURO, 2.5),
        L("M132 32 L144 30", AMARILLO_OSCURO, 2.5),
    ], "Comida apetitosa y sabrosa sobre la mesa.")
    put("empty", "D", fondo_mesa() + _vaso(56, 20, 48, 56, 0.0),
        "Vaso completamente transparente y vacío.")
    put("full", "D", fondo_mesa() + _vaso(56, 20, 48, 56, 0.90),
        "Vaso lleno casi hasta el borde de líquido azul.")
    put("high", "C", fondo_cielo() + [
        L("M30 70 Q55 30 80 70 Q105 30 130 70", ROJO_OSCURO, 3),
    ] + notas([(48, 22), (80, 16), (112, 22)]) + frecha((136, 72), (136, 18), MORADO, 3.5),
        "Notas musicales arriba y flecha hacia lo agudo/alto.")
    put("hungry", "C", fondo_mesa() + nino((52, 26), (52, 38), (52, 58), [[(38, 46)], [(64, 52)]], [[(46, 84)], [(58, 84)]])
        + [E(110, 34, 24, 18, BLANCO, GRIS_OSCURO, 2)] + fl("Red apple", 96, 20, 26),
        "Niño con mano en la barriga pensando en comida.")
    put("loud", "C", fondo_sala() + fl("Ear", 22, 24, 44) + [
        L("M76 34 Q90 46 76 58", ROJO_OSCURO, 4),
        L("M90 26 Q110 46 90 66", ROJO_OSCURO, 4),
        L("M106 18 Q132 46 106 74", ROJO_OSCURO, 4),
    ], "Ondas sonoras muy grandes representando un sonido fuerte.")
    put("low", "C", fondo_sala() + [
        L("M24 54 Q52 40 80 54 Q108 68 134 54", AZUL_OSCURO, 4.5),
    ] + notas([(52, 66), (92, 70)]) + frecha((136, 20), (136, 72), AZUL_OSCURO, 3.5),
        "Ondas lentas abajo y flecha hacia sonido grave/bajo.")
    put("quiet", "C", fondo_noite() + [
        E(80, 44, 18, 18, PEL, PELB, 2),
        F("M62 42 C62 28 98 28 98 42 C91 36 69 36 62 42 Z", BARRO, TINTA, 1.5),
        E(74, 42, 2, 2.2, TINTA),
        E(86, 42, 2, 2.2, TINTA),
        E(80, 50, 2.5, 2.5, TINTA),
        R(78, 48, 4.5, 18, 2, "#fcd34d", PELB, 1.5),
    ], "Dedo delante de la boca pidiendo estar en silencio y callado.")
    put("steady", "D", fondo_mesa() + [
        R(52, 46, 56, 30, 4, VERDE, VERDE_OSCURO, 2.5),
        R(60, 22, 40, 24, 4, AZUL, AZUL_OSCURO, 2.5),
        L("M40 76 L120 76", TINTA, 3),
    ], "Torre firme y bien asentada en equilibrio perfecto.")
    put("tall", "C", fondo_prado() + fl("Sunflower", 48, 8, 66) + frecha((126, 78), (126, 12), VERDE_OSCURO, 4),
        "Planta alta y flecha vertical midiendo gran altura.")

    put("good morning", "C", fondo_cielo() + fl("Sun", 24, 14, 44) + fl("Waving hand", 78, 22, 54),
        "Sol amaneciendo y mano saludando alegremente por la mañana.")
    put("help me, please", "C", fondo_prado() + nino((52, 28), (52, 40), (52, 60), [[(38, 48)], [(74, 44)]], [[(46, 86)], [(58, 86)]])
        + nino((106, 28), (106, 40), (106, 60), [[(78, 44)], [(120, 48)]], [[(100, 86)], [(112, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1)
        + fl("Package", 62, 62, 34),
        "Niño tendiendo la mano para ayudar a otro con una caja.")
    put("here you are", "C", fondo_sala() + nino((46, 28), (46, 40), (46, 60), [[(66, 46)], [(32, 52)]], [[(40, 86)], [(52, 86)]], mira=1)
        + fl("Red apple", 70, 32, 26)
        + frecha((68, 22), (100, 22), VERDE_OSCURO, 3)
        + nino((116, 28), (116, 40), (116, 60), [[(98, 48)], [(130, 52)]], [[(110, 86)], [(122, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Niño entregando una manzana en la mano de otro.")
    put("here you go", "C", fondo_sala() + nino((46, 28), (46, 40), (46, 60), [[(66, 46)], [(32, 52)]], [[(40, 86)], [(52, 86)]], mira=1)
        + fl("Blue book", 70, 30, 28)
        + frecha((68, 20), (100, 20), AZUL_OSCURO, 3)
        + nino((116, 28), (116, 40), (116, 60), [[(98, 48)], [(130, 52)]], [[(110, 86)], [(122, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Niño dando un libro a su compañero con gesto amable.")
    put("look at this", "C", fondo_sala() + nino((52, 28), (52, 40), (52, 60), [[(74, 40)], [(38, 52)]], [[(46, 86)], [(58, 86)]], mira=1)
        + fl("Eye", 92, 16, 30) + fl("Chestnut", 96, 46, 36),
        "Niño señalando con entusiasmo un objeto para mirarlo.")
    put("more, please", "C", fondo_mesa() + _vaso(36, 30, 36, 46, 0.3) + fl("Waving hand", 86, 26, 42) + frecha((118, 20), (68, 28), VERDE_OSCURO, 3.5),
        "Vaso medio vacío pidiendo un poco más de forma amable.")
    put("my turn", "C", fondo_sala() + nino((52, 28), (52, 40), (52, 60), [[(40, 48)], [(64, 48)]], [[(46, 86)], [(58, 86)]])
        + frecha((98, 36), (68, 36), AZUL_OSCURO, 4) + fl("Soccer ball", 104, 46, 32),
        "Flecha apuntando hacia el propio niño indicando su turno.")
    put("no, thank you", "C", fondo_mesa() + fl("Red apple", 32, 34, 40) + fl("Raised hand", 78, 22, 48) + [
        L("M82 22 L124 64", ROJO_OSCURO, 4),
    ], "Mano levantada declinando amablemente el ofrecimiento.")
    put("thank you", "C", fondo_sala() + fl("Clapping hands", 46, 24, 58) + fl("Red heart", 96, 12, 30),
        "Manos agradecidas acompañadas de corazón afectuoso.")
    put("what do you want", "C", fondo_mesa() + [
        E(46, 42, 20, 20, AMARILLO, AMARILLO_OSCURO, 2),
        L("M42 36 Q46 28 52 34 Q54 40 46 44", TINTA, 2.5),
        E(46, 51, 2.5, 2.5, TINTA),
    ] + fl("Red apple", 80, 20, 34) + fl("Banana", 108, 42, 34),
        "Signo de pregunta junto a dos opciones para elegir.")
    put("yes, please", "C", fondo_mesa() + fl("Thumbs up", 34, 24, 52) + fl("Red apple", 92, 28, 42),
        "Pulgar hacia arriba aceptando con gusto.")
    put("you are welcome", "C", fondo_sala() + fl("Waving hand", 34, 24, 52) + fl("Red heart", 92, 24, 42),
        "Mano amable y corazón respondiendo de nada.")
    put("your turn", "C", fondo_sala() + nino((106, 28), (106, 40), (106, 60), [[(94, 48)], [(118, 48)]], [[(100, 86)], [(112, 86)]], camisa=(VERDE, VERDE_OSCURO))
        + frecha((46, 36), (86, 36), VERDE_OSCURO, 4) + fl("Soccer ball", 26, 48, 32),
        "Flecha señalando al compañero indicando que es su turno.")

    # ── Verbos y acciones TPR ──────────────────────────────────────────────
    put("blow", "C", fondo_cielo() + nino((52, 28), (52, 40), (52, 60), [[(38, 48)], [(66, 48)]], [[(46, 86)], [(58, 86)]], mira=1)
        + [L("M74 30 L108 28", AZUL_OSCURO, 2.5), L("M76 38 Q94 44 114 38", AGUA_OSCURO, 2.5)],
        "Niño soplando chorro de aire hacia delante.")
    put("clap your hands", "C", fondo_sala() + fl("Clapping hands", 46, 18, 66) + [L("M34 26 L44 34", ROJO, 2.5), L("M126 26 L116 34", ROJO, 2.5)],
        "Dos manos chocando al aplaudir con ritmo.")
    put("dance", "C", fondo_sala() + nino((78, 24), (78, 36), (78, 56), [[(56, 22)], [(102, 26)]], [[(66, 84)], [(92, 74)]], camisa=(MORADO, TINTA))
        + notas([(36, 22), (120, 20)]),
        "Niño bailando alegremente con notas musicales.")
    put("dig", "C", fondo_prado() + nino((56, 28), (56, 40), (56, 60), [[(74, 52)], [(42, 48)]], [[(50, 86)], [(62, 86)]], mira=1) + [
        F("M84 72 Q108 54 132 72 Z", BARRO, TINTA, 2),
        L("M72 48 L102 68", GRIS_OSCURO, 3),
        F("M96 64 L112 74 L102 78 Z", GRIS, GRIS_OSCURO, 1.8),
    ], "Niño cavando la tierra con una pala pequeña.")
    put("drip", "C", fondo_sala() + [
        R(32, 18, 44, 14, 3, GRIS, GRIS_OSCURO, 2),
        R(64, 32, 14, 12, 2, GRIS, GRIS_OSCURO, 2),
    ] + gotas([(71, 52), (71, 66), (71, 78)]), "Grifo soltando gotas de agua una tras otra.")
    put("drive", "C", fondo_prado() + fl("Automobile", 28, 34, 62) + frecha((96, 56), (138, 56), VERDE_OSCURO, 4),
        "Coche avanzando por la carretera hacia delante.")
    put("fall", "C", fondo_prado() + [
        R(58, 38, 30, 30, 4, ROJO, ROJO_OSCURO, 2),
    ] + frecha((104, 24), (104, 72), ROJO_OSCURO, 4), "Objeto cayendo en vertical hacia el suelo.")
    put("fall down", "C", fondo_prado() + nino((66, 48), (74, 58), (88, 70), [[(54, 66)], [(84, 72)]], [[(96, 80)], [(106, 82)]])
        + frecha((40, 26), (52, 70), ROJO_OSCURO, 3.5),
        "Niño dejándose caer suavemente hacia el suelo.")
    put("gallop", "C", fondo_prado() + fl("Horse", 34, 22, 62) + frecha((98, 46), (138, 46), TIERRA, 4),
        "Caballo galopando rápido por el prado.")
    put("hop", "C", fondo_prado() + nino((74, 20), (74, 32), (74, 52), [[(56, 40)], [(92, 40)]], [[(70, 82)], [(92, 66)]])
        + [L("M58 84 Q74 68 90 84", VERDE_OSCURO, 2.5)],
        "Niño saltando en el aire a la pata coja.")
    put("jump", "C", fondo_prado() + nino((78, 16), (78, 28), (78, 46), [[(56, 20)], [(100, 20)]], [[(68, 70)], [(90, 70)]])
        + frecha((120, 74), (120, 22), VERDE_OSCURO, 4),
        "Niño dando un salto alto con ambos brazos arriba.")
    put("make", "C", fondo_mesa() + [
        R(46, 52, 34, 22, 3, AZUL, AZUL_OSCURO, 2),
        R(84, 52, 34, 22, 3, VERDE, VERDE_OSCURO, 2),
        R(64, 28, 34, 22, 3, ROJO, ROJO_OSCURO, 2),
    ] + frecha((80, 10), (80, 26), AMARILLO_OSCURO, 3.5),
        "Manos juntando y construyendo piezas de colores.")
    put("pop", "C", fondo_cielo() + fl("Chestnut", 52, 32, 42) + [
        L("M44 26 L32 16", ROJO, 3),
        L("M106 26 L118 16", ROJO, 3),
        L("M40 52 L24 52", AMARILLO_OSCURO, 3),
        L("M110 52 L126 52", AMARILLO_OSCURO, 3),
    ], "Estallido repentino con chispas saliendo hacia fuera.")
    put("pour", "C", fondo_mesa() + [
        F("M26 24 L62 18 L52 48 L24 44 Z", AZUL, AZUL_OSCURO, 2),
        L("M58 30 Q84 36 86 58", AGUA, 4),
    ] + _vaso(70, 50, 36, 30, 0.55), "Jarra azul inclinando agua dentro de un vaso.")
    put("push", "C", fondo_sala() + nino((46, 28), (46, 40), (46, 60), [[(70, 44)], [(68, 50)]], [[(36, 86)], [(56, 86)]], mira=1)
        + fl("Package", 76, 40, 44) + frecha((94, 26), (132, 26), ROJO_OSCURO, 3.5),
        "Niño empujando una caja pesada hacia delante.")
    put("put on", "C", fondo_sala() + nino((52, 28), (52, 40), (52, 60), [[(38, 48)], [(66, 48)]], [[(46, 86)], [(58, 86)]])
        + fl("Coat", 94, 24, 48) + frecha((92, 42), (66, 42), AZUL_OSCURO, 3.5),
        "Gesto de ponerse una prenda encima del cuerpo.")
    put("rebuild", "C", fondo_mesa() + [
        R(28, 60, 22, 16, 2, GRIS, GRIS_OSCURO, 1.8),
        R(48, 62, 22, 14, 2, ROJO, ROJO_OSCURO, 1.8),
    ] + frecha((66, 46), (92, 46), VERDE_OSCURO, 3.5) + [
        R(98, 54, 34, 22, 3, AZUL, AZUL_OSCURO, 2),
        R(102, 32, 26, 22, 3, ROJO, ROJO_OSCURO, 2),
    ], "Piezas caídas volviéndose a levantar en una torre nueva.")
    put("roar", "C", fondo_prado() + fl("Lion", 28, 22, 58) + [
        L("M94 34 L120 24", ROJO, 3.5),
        L("M96 46 L128 46", ROJO, 3.5),
        L("M94 58 L120 68", ROJO, 3.5),
    ], "León rugiendo fuerte con ondas hacia delante.")
    put("roll", "C", fondo_prado() + fl("Soccer ball", 46, 36, 44) + [
        L("M50 26 Q72 12 94 26", VERDE_OSCURO, 3),
        F("M94 26 L86 20 L88 30 Z", VERDE_OSCURO),
    ] + frecha((98, 58), (134, 58), VERDE_OSCURO, 3.5),
        "Pelota girando y rodando sobre el suelo.")
    put("row", "C", fondo_mar() + fl("Canoe", 38, 28, 66) + frecha((104, 56), (138, 56), MAR_PROF, 3.5),
        "Bote con remo avanzando por el agua.")
    put("see", "C", fondo_prado() + fl("Eye", 28, 28, 48) + frecha((82, 48), (108, 48), AZUL_OSCURO, 3) + fl("Sunflower", 110, 26, 36),
        "Ojo mirando directamente hacia una flor.")
    put("sit", "C", fondo_sala() + fl("Chair", 48, 30, 50) + nino((68, 34), (68, 44), (68, 60), [[(56, 52)], [(82, 52)]], [[(62, 66), (56, 80)], [(76, 66), (72, 80)]])
        + frecha((116, 26), (116, 68), AZUL_OSCURO, 3.5),
        "Niño sentándose en una silla.")
    put("sniff", "C", fondo_prado() + fl("Nose", 36, 24, 48) + fl("Hibiscus", 92, 34, 44) + [
        L("M88 36 Q78 30 74 36", MORADO, 2.5),
        L("M90 48 Q80 42 76 48", MORADO, 2.5),
    ], "Nariz oliendo el aroma de una flor.")
    put("stir", "C", fondo_mesa() + fl("Bowl with spoon", 46, 22, 62) + [
        L("M56 18 Q78 8 100 18", ROJO_OSCURO, 3),
        F("M100 18 L92 12 L94 22 Z", ROJO_OSCURO),
    ], "Cuchara dando vueltas en círculo dentro de un cuenco.")
    put("stomp", "C", fondo_prado() + fl("Hiking boot", 50, 20, 56) + frecha((116, 20), (116, 68), TIERRA, 4) + [
        L("M44 80 L36 70", TIERRA, 2.5),
        L("M104 80 L112 70", TIERRA, 2.5),
    ], "Bota pisando fuerte hacia abajo contra el suelo.")
    put("stretch", "C", fondo_prado() + nino((78, 22), (78, 34), (78, 54), [[(70, 10)], [(86, 10)]], [[(72, 86)], [(84, 86)]])
        + frecha((44, 70), (44, 16), VERDE_OSCURO, 3.5) + frecha((112, 70), (112, 16), VERDE_OSCURO, 3.5),
        "Niño estirándose hacia arriba todo lo posible.")
    put("tiptoe", "C", fondo_sala() + fl("Footprints", 46, 22, 56) + frecha((116, 74), (116, 24), MORADO, 3.5),
        "Pies caminando de puntillas de manera ligera.")
    put("turn around", "C", fondo_sala() + nino((78, 24), (78, 36), (78, 56), [[(62, 46)], [(94, 46)]], [[(72, 84)], [(84, 84)]]) + [
        L("M46 66 Q80 82 114 66", AZUL_OSCURO, 3.5),
        F("M114 66 L104 62 L106 72 Z", AZUL_OSCURO),
    ], "Flecha circular rodeando al niño para darse la vuelta.")
    put("turn off", "C", fondo_noite() + fl("Light bulb", 42, 18, 52) + [
        R(38, 16, 60, 56, 12, None, GRIS, 2),
        L("M42 22 L94 68", ROJO_OSCURO, 4.5),
    ], "Bombilla apagada y tachada indicando apagar la luz.")
    put("turn on", "C", fondo_cielo() + fl("Light bulb", 48, 16, 58) + [
        L("M38 24 L24 14", AMARILLO_OSCURO, 3),
        L("M116 24 L130 14", AMARILLO_OSCURO, 3),
        L("M34 46 L18 46", AMARILLO_OSCURO, 3),
        L("M120 46 L136 46", AMARILLO_OSCURO, 3),
    ], "Bombilla encendida con rayos brillantes de luz.")
    put("walk", "C", fondo_prado() + nino((66, 26), (66, 38), (66, 58), [[(80, 48)], [(52, 52)]], [[(56, 86)], [(78, 84)]], mira=1)
        + frecha((94, 58), (132, 58), VERDE_OSCURO, 3.5),
        "Niño caminando con paso natural hacia delante.")
    put("wish", "C", fondo_noite() + fl("Star", 46, 16, 56) + [
        L("M30 50 L44 38", AMARILLO, 2.5),
        L("M110 24 L124 14", AMARILLO, 2.5),
    ], "Estrella brillante en la noche al pedir un deseo.")
    put("yawn", "C", fondo_noite() + [
        E(80, 42, 22, 22, PEL, PELB, 2),
        F("M58 40 C58 20 102 20 102 40 C94 32 66 32 58 40 Z", BARRO, TINTA, 1.5),
        L("M69 38 Q73 41 77 38", TINTA, 2),
        L("M83 38 Q87 41 91 38", TINTA, 2),
        E(80, 52, 7, 9, ROJO_OSCURO, TINTA, 1.8),
    ] + fl("Crescent moon", 112, 12, 26), "Niño abriendo mucho la boca en un bostezo de sueño.")

    # ── Consignas compuestas del aula (3-4 años) ───────────────────────────
    put("a full plate on the table", "C", fondo_mesa() + fl("Fork and knife with plate", 38, 12, 72) + fl("Red apple", 64, 34, 24),
        "Plato lleno encima de la mesa con comida.")
    put("blow like the autumn wind", "C", fondo_prado() + fl("Wind face", 20, 22, 48) + fl("Maple leaf", 78, 22, 34) + fl("Fallen leaf", 108, 42, 32),
        "Viento soplando con fuerza hojas otoñales por el aire.")
    put("clap high, clap low", "C", fondo_sala() + fl("Clapping hands", 30, 12, 44) + frecha((84, 48), (84, 14), ROJO_OSCURO, 3)
        + fl("Clapping hands", 98, 46, 44) + frecha((146, 44), (146, 78), AZUL_OSCURO, 3),
        "Manos dando palmas arriba y abajo.")
    put("clap the rhythm on your chest", "C", fondo_sala() + nino((78, 24), (78, 36), (78, 56), [[(68, 46)], [(88, 46)]], [[(72, 84)], [(84, 84)]])
        + notas([(38, 26), (118, 26)]),
        "Niño marcando el ritmo con palmadas sobre su pecho.")
    put("cross your hands and clap with your friend", "C", fondo_sala() + nino((46, 26), (46, 38), (46, 58), [[(66, 44)], [(32, 50)]], [[(40, 84)], [(52, 84)]], mira=1)
        + fl("Clapping hands", 68, 32, 24)
        + nino((114, 26), (114, 38), (114, 58), [[(94, 44)], [(128, 50)]], [[(108, 84)], [(120, 84)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos amigos chocando y cruzando las manos al ritmo.")
    put("curl up small like a tiny seed", "C", fondo_prado() + [
        E(80, 62, 20, 14, TIERRA_CLARA, BARRO, 2.5),
    ] + fl("Seedling", 104, 44, 32) + frecha((42, 36), (62, 56), VERDE_OSCURO, 3),
        "Cuerpo hecho bolita pequeñita en el suelo como una semilla.")
    put("dig the soil with your hands", "C", fondo_prado() + [
        F("M28 74 Q80 42 132 74 Z", BARRO, TINTA, 2.2),
    ] + fl("Open hands", 54, 16, 52) + frecha((116, 24), (116, 54), TIERRA, 3.5),
        "Manos excavando y removiendo la tierra.")
    put("gallop like a horse in the meadow", "C", fondo_prado() + fl("Horse", 26, 26, 56) + fl("Herb", 100, 48, 36) + frecha((94, 24), (132, 24), VERDE_OSCURO, 3.5),
        "Caballo galopando por un prado verde con hierba.")
    put("graze like a gentle sheep", "C", fondo_prado() + fl("Ewe", 36, 26, 58) + fl("Herb", 102, 46, 38),
        "Oveja mansa pastando hierba fresca en el campo.")
    put("grow tall into a sunflower", "C", fondo_prado() + fl("Seedling", 24, 52, 32) + frecha((60, 62), (82, 36), VERDE_OSCURO, 3.5) + fl("Sunflower", 88, 12, 62),
        "Brote pequeño creciendo hasta abrirse como girasol alto.")
    put("jump over the big puddle", "C", fondo_prado() + [
        E(80, 72, 42, 12, AGUA, AGUA_OSCURO, 2),
    ] + nino((78, 18), (78, 30), (78, 48), [[(58, 32)], [(98, 32)]], [[(68, 62)], [(90, 62)]])
        + [L("M34 62 Q80 28 126 62", VERDE_OSCURO, 2.5)],
        "Niño saltando por encima de un charco grande.")
    put("open your umbrella", "C", fondo_cielo() + fl("Closed umbrella", 20, 26, 40) + frecha((64, 46), (86, 46), AZUL_OSCURO, 3) + fl("Umbrella", 88, 16, 56),
        "Paraguas cerrado abriéndose ante la lluvia.")
    put("pick up two acorns and put them in the basket", "C", fondo_prado() + _acorn(30, 56, 1.0) + _acorn(52, 56, 1.0)
        + frecha((58, 34), (88, 34), TIERRA, 3.5) + fl("Basket", 94, 34, 52),
        "Dos bellotas recogidas y colocadas dentro de la cesta.", "pick_up_two_acorns_basket")
    put("put on your animal mask and roar", "C", fondo_sala() + fl("Lion", 30, 22, 56) + [
        L("M94 34 L124 24", ROJO_OSCURO, 3.5),
        L("M96 46 L130 46", ROJO_OSCURO, 3.5),
        L("M94 58 L124 68", ROJO_OSCURO, 3.5),
    ], "Máscara de león colocada rugiendo fuerte.", "put_on_animal_mask_roar")
    put("put on your winter boots", "C", fondo_prado() + nino((46, 26), (46, 38), (46, 58), [[(32, 46)], [(60, 46)]], [[(40, 84)], [(52, 84)]])
        + fl("Hiking boot", 92, 34, 48) + frecha((90, 58), (64, 72), AZUL_OSCURO, 3.5),
        "Botas de invierno colocándose en los pies.")
    put("quiet: hands on your tummy", "C", fondo_sala() + nino((78, 22), (78, 34), (78, 54), [[(70, 54)], [(86, 54)]], [[(72, 84)], [(84, 84)]])
        + [L("M44 46 L60 46", MORADO, 2.5), L("M100 46 L116 46", MORADO, 2.5)],
        "Niño quieto con ambas manos apoyadas sobre su barriga.")
    put("roll the pumpkin on the floor", "C", fondo_prado() + _pumpkin(58, 54, 22) + frecha((88, 54), (132, 54), ROJO_OSCURO, 3.5),
        "Calabaza rodando por el suelo en línea recta.")
    put("shake your bells loudly", "C", fondo_sala() + fl("Bell", 34, 18, 50) + fl("Bell", 82, 18, 50)
        + [L("M24 26 L16 38", ROJO, 3), L("M138 26 L146 38", ROJO, 3)],
        "Campanas sonando fuerte al agitarlas.")
    put("spin around and fall down like a leaf", "C", fondo_prado() + fl("Maple leaf", 54, 24, 52) + [
        L("M34 40 Q46 18 70 18", ROJO_OSCURO, 2.5),
        F("M70 18 L62 14 L64 22 Z", ROJO_OSCURO),
    ] + frecha((116, 24), (116, 72), ROJO_OSCURO, 3.5),
        "Hoja otoñal girando y cayendo suave al suelo.", "spin_around_fall_like_leaf")
    put("stand up and clap your hands", "C", fondo_sala() + nino((52, 24), (52, 36), (52, 56), [[(38, 44)], [(66, 44)]], [[(46, 84)], [(58, 84)]])
        + frecha((24, 72), (24, 24), VERDE_OSCURO, 3.5) + fl("Clapping hands", 88, 22, 50),
        "Niño de pie dando palmas con alegría.")
    put("stomp in the snow", "C", fondo_cielo() + [
        R(16, 66, 128, 24, 4, BLANCO, GRIS_OSCURO, 2),
    ] + fl("Hiking boot", 50, 20, 48) + frecha((110, 22), (110, 62), AZUL_OSCURO, 3.5) + copos_nieve([(28, 20), (126, 22)]),
        "Bota pisando fuerte en la nieve blanca.")
    put("tap your knees like rain falling fast", "C", fondo_sala() + nino((56, 24), (56, 36), (56, 56), [[(46, 66)], [(66, 66)]], [[(50, 84)], [(62, 84)]])
        + gotas([(112, 20), (124, 34), (112, 48), (124, 62)]),
        "Manos dando golpecitos rápidos en las rodillas como lluvia.", "tap_knees_like_rain")
    put("the chestnut pops in the fire: jump", "C", fondo_prado() + fl("Fire", 32, 26, 52) + fl("Chestnut", 86, 18, 36) + frecha((104, 64), (104, 18), ROJO_OSCURO, 3.5),
        "Castaña saltando del fuego de otoño.", "chestnut_pops_fire_jump")
    put("tiptoe quietly to blow out the light", "C", fondo_noite() + nino((46, 28), (46, 40), (46, 60), [[(34, 48)], [(58, 48)]], [[(42, 84)], [(50, 84)]], mira=1)
        + fl("Candle", 104, 22, 44) + [L("M72 34 L94 32", BLANCO, 2.5)],
        "Niño de puntillas acercándose a apagar la luz de la vela.", "tiptoe_quietly_blow_light")
    put("touch your knees and freeze", "C", fondo_sala() + nino((56, 26), (56, 38), (56, 58), [[(48, 68)], [(64, 68)]], [[(50, 84)], [(62, 84)]])
        + fl("Stop sign", 102, 24, 42) + copos_nieve([(124, 16)]),
        "Niño tocando sus rodillas quieto como estatua.")
    put("walk heavily like a big cow", "C", fondo_prado() + fl("Cow", 36, 20, 66) + frecha((114, 30), (114, 72), BARRO, 4),
        "Vaca grande caminando pesado con paso firme.")
    put("walk to the circle and sit down", "C", fondo_sala() + nino((38, 28), (38, 40), (38, 60), [[(26, 48)], [(50, 48)]], [[(32, 86)], [(44, 86)]], mira=1)
        + frecha((60, 48), (88, 56), VERDE_OSCURO, 3) + [E(116, 70, 22, 10, AZUL, AZUL_OSCURO, 2.5)],
        "Niño caminando hacia el círculo azul para sentarse.")
    put("warm your hands and rub them fast", "C", fondo_sala() + fl("Open hands", 46, 22, 54) + [
        L("M30 34 L42 46", ROJO, 3),
        L("M118 34 L106 46", ROJO, 3),
        L("M66 14 L74 22", AMARILLO_OSCURO, 2.5),
        L("M92 14 L84 22", AMARILLO_OSCURO, 2.5),
    ], "Manos frotándose rápido para entrar en calor.", "warm_hands_rub_fast")

    # ── Frases de gramática (unidad 01-10, 40 frases exactas) ─────────────
    put("we build a tower and it stands", "C", fondo_mesa() + [
        R(56, 56, 48, 22, 3, AZUL, AZUL_OSCURO, 2),
        R(60, 34, 40, 22, 3, VERDE, VERDE_OSCURO, 2),
        R(64, 14, 32, 20, 3, ROJO, ROJO_OSCURO, 2),
    ], "Torre de tres bloques firmes en pie.")
    put("it is tall, but it falls", "C", fondo_mesa() + [
        R(44, 52, 24, 24, 3, AZUL, AZUL_OSCURO, 2),
        R(52, 28, 24, 24, 3, VERDE, VERDE_OSCURO, 2),
        R(74, 10, 22, 22, 3, ROJO, ROJO_OSCURO, 2),
    ] + frecha((106, 20), (124, 68), ROJO_OSCURO, 3.5), "Torre alta inclinándose hacia la caída.")
    put("it falls because it wobbles", "C", fondo_mesa() + [
        R(62, 54, 30, 22, 3, AZUL, AZUL_OSCURO, 2),
        R(68, 32, 28, 22, 3, ROJO, ROJO_OSCURO, 2),
        L("M44 36 Q52 28 48 44", MORADO, 2.5),
        L("M112 36 Q104 28 108 44", MORADO, 2.5),
    ], "Torre tambaleándose a ambos lados antes de caer.")
    put("first the big box, then the cup", "C", fondo_mesa() + fl("Package", 24, 24, 56) + frecha((84, 50), (104, 50), VERDE_OSCURO, 3)
        + fl("Teacup without handle", 106, 36, 36), "Primero la caja grande y luego la taza.")
    put("we have made a row", "C", fondo_mesa() + [
        R(22, 44, 24, 24, 3, ROJO, ROJO_OSCURO, 2),
        R(52, 44, 24, 24, 3, AZUL, AZUL_OSCURO, 2),
        R(82, 44, 24, 24, 3, VERDE, VERDE_OSCURO, 2),
        R(112, 44, 24, 24, 3, AMARILLO, AMARILLO_OSCURO, 2),
    ], "Cuatro piezas colocadas ordenadamente en fila.")
    put("you have chosen blue", "C", fondo_mesa() + [
        R(32, 36, 26, 26, 3, ROJO, ROJO_OSCURO, 2),
        R(68, 30, 32, 32, 4, AZUL, AZUL_OSCURO, 3),
        R(108, 36, 26, 26, 3, VERDE, VERDE_OSCURO, 2),
    ] + frecha((84, 12), (84, 28), AZUL_OSCURO, 3.5), "Bloque azul señalado y elegido entre varios.")
    put("have you finished the row", "C", fondo_mesa() + [
        R(20, 48, 22, 22, 3, ROJO, ROJO_OSCURO, 2),
        R(46, 48, 22, 22, 3, AZUL, AZUL_OSCURO, 2),
        R(72, 48, 22, 22, 3, VERDE, VERDE_OSCURO, 2),
        R(98, 48, 22, 22, 3, None, GRIS_OSCURO, 2),
        L("M130 34 Q136 26 142 32 Q144 38 136 42", TINTA, 2.5),
        E(136, 49, 2.5, 2.5, TINTA),
    ], "Fila casi terminada con último hueco y pregunta.")
    put("i have made a new one", "C", fondo_mesa() + [
        R(58, 48, 44, 26, 3, AZUL, AZUL_OSCURO, 2),
        R(66, 26, 28, 22, 3, AMARILLO, AMARILLO_OSCURO, 2),
        L("M44 26 L54 34", AMARILLO_OSCURO, 3),
        L("M116 26 L106 34", AMARILLO_OSCURO, 3),
    ], "Construcción nueva recién terminada con destellos.")
    put("the train has gone down", "C", fondo_prado() + fl("Train", 26, 18, 52) + frecha((88, 26), (128, 66), ROJO_OSCURO, 4),
        "Tren descendiendo por una pendiente hacia abajo.")
    put("yesterday the train went slowly", "C", fondo_prado() + fl("Train", 26, 28, 52) + fl("Turtle", 94, 42, 40) + frecha((84, 24), (112, 24), GRIS_OSCURO, 2.5),
        "Tren avanzando despacio al ritmo de una tortuga.")
    put("today it has gone fast", "C", fondo_prado() + fl("Train", 26, 26, 56) + frecha((86, 36), (136, 36), ROJO_OSCURO, 4.5) + frecha((86, 52), (136, 52), ROJO_OSCURO, 3.5),
        "Tren desplazándose muy rápido con doble flecha.")
    put("have you pushed it", "C", fondo_sala() + nino((38, 30), (38, 42), (38, 62), [[(60, 46)], [(24, 52)]], [[(32, 86)], [(44, 86)]], mira=1)
        + fl("Package", 66, 42, 38) + [
            L("M118 26 Q124 18 130 24 Q132 30 124 34", TINTA, 2.5),
            E(124, 41, 2.5, 2.5, TINTA),
        ], "Niño junto a caja y signo de pregunta sobre empujarla.")
    put("i push and it falls", "C", fondo_mesa() + nino((32, 28), (32, 40), (32, 60), [[(56, 44)], [(18, 50)]], [[(26, 86)], [(38, 86)]], mira=1)
        + [R(68, 38, 28, 34, 4, ROJO, ROJO_OSCURO, 2)] + frecha((106, 32), (124, 70), ROJO_OSCURO, 3.5),
        "Niño empujando un bloque que cae hacia delante.")
    put("we have been talking in the cups", "C", fondo_sala() + nino((34, 28), (34, 40), (34, 60), [[(48, 46)], [(20, 50)]], [[(28, 86)], [(40, 86)]], mira=1)
        + _vaso(52, 32, 18, 22, 0.0) + [L("M70 42 L90 42", ROJO_OSCURO, 2.5)] + _vaso(90, 32, 18, 22, 0.0)
        + nino((126, 28), (126, 40), (126, 60), [[(112, 46)], [(140, 50)]], [[(120, 86)], [(132, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos niños hablando a través de teléfono de vasos unidos por hilo.", "talking_in_the_cups")
    put("you have been listening", "C", fondo_sala() + fl("Ear", 48, 20, 56) + notas([(108, 28), (122, 44)]),
        "Oreja atenta recibiendo notas suaves.", "you_have_been_listening")
    put("i have been pulling the string", "C", fondo_sala() + nino((42, 28), (42, 40), (42, 60), [[(66, 44)], [(28, 50)]], [[(36, 86)], [(48, 86)]], mira=1)
        + [L("M66 44 L124 44", TIERRA, 2.5)] + frecha((94, 30), (66, 30), ROJO_OSCURO, 3.5),
        "Niño tirando hacia sí de un cordel tenso.", "pulling_the_string")
    put("have you been holding the cup", "C", fondo_mesa() + nino((52, 28), (52, 40), (52, 60), [[(74, 44)], [(38, 52)]], [[(46, 86)], [(58, 86)]], mira=1)
        + fl("Teacup without handle", 76, 32, 32) + [
            L("M118 24 Q124 16 130 22 Q132 28 124 32", TINTA, 2.5),
            E(124, 39, 2.5, 2.5, TINTA),
        ], "Niño sujetando un vaso con pregunta encima.", "holding_the_cup")
    put("the car is on the block", "C", fondo_mesa() + [
        R(50, 52, 60, 26, 4, AZUL, AZUL_OSCURO, 2.2),
    ] + fl("Automobile", 52, 14, 54), "Coche colocado justo encima del bloque azul.")
    put("put it under the bridge", "C", fondo_prado() + [
        R(28, 36, 104, 16, 4, TIERRA_CLARA, BARRO, 2.2),
        R(28, 36, 16, 46, 2, TIERRA_CLARA, BARRO, 2),
        R(116, 36, 16, 46, 2, TIERRA_CLARA, BARRO, 2),
    ] + fl("Automobile", 62, 54, 36) + frecha((80, 14), (80, 32), VERDE_OSCURO, 3),
        "Coche colocado por debajo de un puente.")
    put("the sun had gone down", "C", fondo_noite() + [
        L("M16 66 L144 66", TIERRA, 2.5),
        E(80, 64, 24, 22, AMARILLO, "#ea580c", 2),
    ] + frecha((120, 24), (120, 62), "#ea580c", 3.5), "Sol ocultándose por detrás del horizonte al atardecer.")
    put("the shadow had grown long", "C", fondo_prado() + fl("Sun", 16, 12, 32) + nino((52, 26), (52, 38), (52, 58), [[(40, 48)], [(64, 48)]], [[(46, 84)], [(58, 84)]])
        + [E(104, 82, 40, 8, GRIS_OSCURO)] + frecha((72, 74), (132, 74), GRIS_OSCURO, 3),
        "Sombra muy alargada proyectándose en el suelo detrás del niño.")
    put("we had drawn it before dinner", "C", fondo_mesa() + fl("Paintbrush", 28, 22, 42) + [
        R(66, 24, 42, 46, 3, BLANCO, GRIS_OSCURO, 2),
        E(87, 46, 10, 10, ROJO, ROJO_OSCURO, 1.5),
    ] + fl("Fork and knife with plate", 112, 30, 36), "Dibujo con pincel terminado antes del plato de cena.")
    put("had you seen the shadow before", "C", fondo_prado() + fl("Eye", 24, 22, 38) + [
        E(90, 74, 36, 10, GRIS_OSCURO),
        L("M126 24 Q132 16 138 22 Q140 28 132 32", TINTA, 2.5),
        E(132, 39, 2.5, 2.5, TINTA),
    ], "Ojo observando una sombra oscura con pregunta.", "seen_the_shadow_before")
    put("the ice might melt", "C", fondo_sala() + fl("Ice", 34, 22, 48) + [
        E(88, 70, 26, 8, AGUA, AGUA_OSCURO, 1.8),
    ] + gotas([(68, 66), (82, 62)]), "Cubito de hielo derritiéndose en un charquito de agua.")
    put("it must be cold", "C", fondo_cielo() + fl("Ice", 32, 20, 52) + copos_nieve([(104, 26), (118, 48), (96, 62)]),
        "Hielo rodeado de copos señalando frío intenso.")
    put("the spoon could help", "C", fondo_mesa() + fl("Spoon", 30, 18, 56) + fl("Bowl with spoon", 84, 26, 52),
        "Cuchara útil lista para ayudar a comer o remover.")
    put("it can't be warm", "C", fondo_cielo() + fl("Ice", 32, 22, 52) + fl("Fire", 92, 26, 44) + [
        L("M90 26 L134 68", ROJO_OSCURO, 4.5),
    ], "Hielo frío y fuego tachado indicando que no puede estar caliente.")
    put("there might be more spoons", "C", fondo_mesa() + fl("Spoon", 26, 22, 46) + fl("Spoon", 62, 22, 46) + fl("Spoon", 98, 22, 46),
        "Varias cucharas alineadas una junto a la otra.")
    put("this must be your spoon", "C", fondo_mesa() + fl("Spoon", 48, 20, 56) + frecha((116, 46), (90, 46), AZUL_OSCURO, 4),
        "Flecha señalando exactamente una cuchara concreta.")
    put("it could be empty", "C", fondo_mesa() + _vaso(50, 20, 44, 54, 0.0) + [
        L("M110 26 Q116 18 122 24 Q124 30 116 34", TINTA, 2.5),
        E(116, 41, 2.5, 2.5, TINTA),
    ], "Vaso transparente sin agua y signo de posibilidad.")
    put("it can't be full", "C", fondo_mesa() + _vaso(44, 20, 44, 54, 0.90) + [
        L("M38 22 L94 74", ROJO_OSCURO, 4.5),
        L("M94 22 L38 74", ROJO_OSCURO, 4.5),
    ], "Vaso lleno tachado indicando que no puede estar lleno.")
    put("if you pour, the glass fills", "C", fondo_mesa() + [
        F("M20 22 L52 18 L44 44 L18 40 Z", AZUL, AZUL_OSCURO, 2),
        L("M48 28 Q70 32 72 52", AGUA, 3.5),
    ] + _vaso(58, 44, 34, 34, 0.85) + frecha((104, 70), (104, 36), AZUL_OSCURO, 3.5),
        "Al verter agua de la jarra, sube el nivel dentro del vaso.", "pour_glass_fills")
    put("if it is full, i say stop", "C", fondo_mesa() + _vaso(32, 22, 42, 54, 0.92) + fl("Stop sign", 90, 22, 48),
        "Vaso completamente lleno junto a señal roja de parar.")
    put("if you pour slowly, it won't spill", "C", fondo_mesa() + [
        F("M20 24 L52 20 L44 44 L18 40 Z", AZUL, AZUL_OSCURO, 2),
        L("M48 30 Q72 34 72 56", AGUA, 2.5),
    ] + _vaso(58, 46, 36, 32, 0.6) + fl("Turtle", 104, 42, 34),
        "Vertiendo agua despacio sin que se derrame ni una gota.", "pour_slowly_no_spill")
    put("if we drink, it will be empty", "C", fondo_mesa() + fl("Cup with straw", 28, 22, 46)
        + frecha((78, 46), (100, 46), AZUL_OSCURO, 3) + _vaso(104, 22, 36, 52, 0.0),
        "Después de beber con la pajita queda el vaso vacío.", "drink_will_be_empty")
    put("if we added water, it would sound low", "C", fondo_sala() + _vaso(26, 22, 40, 52, 0.85)
        + notas([(82, 58), (104, 62)]) + frecha((128, 24), (128, 72), AZUL_OSCURO, 3.5),
        "Vaso con bastante agua produciendo sonido grave.", "added_water_sound_low")
    put("if it were empty, it would sound high", "C", fondo_sala() + _vaso(26, 22, 40, 52, 0.0)
        + notas([(82, 20), (104, 24)]) + frecha((128, 72), (128, 22), MORADO, 3.5),
        "Vaso vacío produciendo sonido agudo arriba.", "empty_sound_high")
    put("if i had a spoon, i would play", "C", fondo_sala() + fl("Spoon", 26, 20, 46) + _vaso(76, 26, 38, 48, 0.5)
        + notas([(120, 20), (134, 34)]),
        "Cuchara lista para golpear suavemente el vaso musical.", "spoon_would_play")
    put("what would happen if we hit the glass harder", "C", fondo_sala() + fl("Spoon", 26, 18, 42)
        + _vaso(64, 26, 38, 48, 0.5) + [
            L("M108 32 L124 22", ROJO_OSCURO, 3.5),
            L("M110 48 L130 48", ROJO_OSCURO, 3.5),
            L("M134 22 Q140 14 146 20 Q148 26 140 30", TINTA, 2.5),
            E(140, 37, 2.5, 2.5, TINTA),
        ], "Golpe fuerte de cuchara contra el vaso y pregunta.", "hit_glass_harder")
    put("the spoon is used for soup", "C", fondo_mesa() + fl("Spoon", 26, 20, 48) + fl("Pot of food", 80, 22, 56),
        "Cuchara junto a plato/olla caliente de sopa.", "spoon_used_for_soup")
    put("my face is turned upside down", "C", fondo_sala() + fl("Spoon", 24, 16, 56) + [
        E(112, 48, 20, 20, PEL, PELB, 2),
        E(105, 55, 2.5, 2.5, TINTA),
        E(119, 55, 2.5, 2.5, TINTA),
        L("M105 42 Q112 36 119 42", ROJO_OSCURO, 2.5),
    ], "Cara reflejada cabeza abajo junto a cuchara.", "face_upside_down")
    put("the spoons are put away", "C", fondo_sala() + [
        R(38, 28, 84, 46, 4, MADERA, MADERA_OSCURA, 2.5),
        L("M44 48 L116 48", MADERA_OSCURA, 2),
    ] + fl("Spoon", 52, 34, 30) + fl("Spoon", 84, 34, 30),
        "Cucharas recogidas y guardadas ordenadamente en el cajón.", "spoons_put_away")
    put("the faces in the spoon were made by us", "C", fondo_sala() + fl("Spoon", 34, 18, 56)
        + nino((100, 28), (100, 40), (100, 60), [[(86, 48)], [(114, 48)]], [[(94, 86)], [(106, 86)]])
        + [E(62, 34, 6, 6, AMARILLO, TINTA, 1.5)],
        "Niño reflejando su cara divertida en una cuchara.", "faces_in_the_spoon")
    put("more juice in my cup", "C", fondo_mesa() + _vaso(56, 22, 46, 54, 0.85) + [
        F("M60 32 L98 32 L96 74 L62 74 Z", "#fb923c", "#c2410c", 1.5),
    ] + frecha((120, 66), (120, 28), "#c2410c", 3.5), "Más zumo subiendo de nivel dentro del vaso.")

    return out


def main() -> int:
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas: dict[str, dict] = mapa["pezas"]

    escenas = {k.strip(" .!?"): v for k, v in _escenas_3_4().items()}

    counts = {"U": 0, "R": 0, "C": 0, "D": 0}
    ya_cubiertas = 0

    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    c34 = lec["cursos"]["curso_3_4"]
    claves_34: dict[str, str] = {}
    for u in c34["unidades"]:
        for l in u["leccions"]:
            for campo in ("xaSabe", "novas", "repasa"):
                for p in l.get(campo) or []:
                    en = p.get("en", "")
                    k = en.lower().strip(" .!?")
                    if k and k not in claves_34:
                        claves_34[k] = en
            f = l.get("fraseGramatica")
            if f:
                en = f.get("en", "")
                k = en.lower().strip(" .!?")
                if k and k not in claves_34:
                    claves_34[k] = en

    faltan: list[str] = []
    for k, en in sorted(claves_34.items()):
        if k in pezas:
            ya_cubiertas += 1
            continue
        if k in FLUENT_DIRECTOS:
            slug, nombre, cat, porque = FLUENT_DIRECTOS[k]
            escribir_fluent_directo(pezas, k, slug, nombre, cat, porque)
            counts[cat] += 1
        elif k in PROPIAS_REUTILIZADAS:
            slug, cat, porque = PROPIAS_REUTILIZADAS[k]
            escribir_reutilizada(pezas, k, slug, cat, porque, SCRIPT_REF)
            counts[cat] += 1
        elif k in escenas:
            slug, cd, formas, porque = escenas[k]
            escribir_cd(pezas, k, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=en)
            counts[cd] += 1
        else:
            faltan.append(k)

    if faltan:
        print(f"ERROR: faltan {len(faltan)} claves de 3-4: {faltan[:20]}")
        return 1

    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK gen_laminas_3_4: nuevas={counts} (sum={sum(counts.values())}), ya_cubiertas={ya_cubiertas}, total_curso={len(claves_34)}")
    print("Agora: python3 tools/gen_laminas_palabras.py && python3 tools/gen_leccions.py && python3 tools/gen_laminas_palabras.py --control")
    return 0


if __name__ == "__main__":
    sys.exit(main())
