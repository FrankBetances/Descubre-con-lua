#!/usr/bin/env python3
"""Generador de las 180 láminas nuevas de 5-6 años (P2.6, O-20261111-4).

Cubre todas las piezas restantes de `curso_5_6` en `leccions.json`
hasta dejar `curso_5_6` a 0 piezas sin lámina.
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

SCRIPT_REF = "tools/gen_laminas_5_6.py"

# ── Banco directo Fluent Emoji Flat (MIT) ────────────────────────────────
FLUENT_DIRECTOS = {
    "basket": ("pal_basket", "Basket", "U", "Cesta tejida vacía."),
    "candle": ("pal_candle", "Candle", "U", "Vela encendida con llama amarilla."),
    "paint": ("pal_paint", "Artist palette", "R", "Paleta de artista con varios colores."),
    "paper": ("pal_paper", "Page facing up", "R", "Hoja de papel blanca limpia."),
    "plane": ("pal_plane", "Airplane", "R", "Avión volando en ángulo."),
    "scissors": ("pal_scissors", "Scissors", "U", "Tijeras rojas abiertas."),
    "snake": ("pal_snake", "Snake", "U", "Serpiente verde ondulada."),
    "suitcase": ("pal_suitcase", "Luggage", "R", "Maleta de viaje con asa y ruedas."),
    "ticket": ("pal_ticket", "Ticket", "U", "Billete o entrada de colores."),
    "vote": ("pal_vote", "Ballot box with ballot", "R", "Urna con papeleta entrando."),
}

PROPIAS_REUTILIZADAS = {}


def _avion_papel(x: float, y: float, s: float = 1.0, col: str = BLANCO) -> list[dict]:
    """Avión de papel limpio sin dependencias externas."""
    return [
        F(
            f"M{x:.1f} {y:.1f} L{x + 34*s:.1f} {y - 8*s:.1f} L{x + 10*s:.1f} {y + 10*s:.1f} Z",
            col,
            AZUL_OSCURO,
            1.8,
        ),
        F(
            f"M{x + 10*s:.1f} {y + 10*s:.1f} L{x + 34*s:.1f} {y - 8*s:.1f} L{x + 20*s:.1f} {y + 16*s:.1f} Z",
            "#bae6fd",
            AZUL_OSCURO,
            1.8,
        ),
    ]


def _vaso(x: float, y: float, w: float, h: float, nivel: float = 0.0) -> list[dict]:
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


def _escenas_5_6() -> dict[str, tuple[str, str, list[dict], str]]:
    out: dict[str, tuple[str, str, list[dict], str]] = {}

    def put(en: str, cd: str, formas: list[dict], porque: str, slug: str | None = None) -> None:
        key = en.lower().strip(" .!?")
        out[key] = (slug or slug_de(key), cd, formas, porque)

    # ── Colores, formas, matemáticas, arte y conceptos ─────────────────────
    put("blue", "D", fondo_mesa() + [E(80, 48, 30, 30, AZUL, AZUL_OSCURO, 3)],
        "Mancha/círculo azul intenso.")
    put("brown", "D", fondo_mesa() + [E(80, 48, 30, 30, TIERRA, BARRO, 3)],
        "Mancha/círculo marrón sólido.")
    put("green", "D", fondo_mesa() + [E(80, 48, 30, 30, VERDE, VERDE_OSCURO, 3)],
        "Mancha/círculo verde intenso.")
    put("white", "D", fondo_mesa() + [E(80, 48, 30, 30, BLANCO, GRIS_OSCURO, 3)],
        "Mancha/círculo blanco con contorno nítido.")
    put("bright", "C", fondo_cielo() + fl("Sun", 48, 16, 56) + [
        L("M34 22 L20 12", AMARILLO_OSCURO, 3),
        L("M126 22 L140 12", AMARILLO_OSCURO, 3),
        L("M30 48 L14 48", AMARILLO_OSCURO, 3),
        L("M130 48 L146 48", AMARILLO_OSCURO, 3),
    ], "Luz muy viva y brillante con destellos.")
    put("circle", "D", fondo_mesa() + [E(80, 48, 30, 30, None, AZUL_OSCURO, 4.5)],
        "Círculo geométrico perfecto y bien trazado.")
    put("hoop", "D", fondo_sala() + [
        E(80, 50, 34, 34, None, ROJO, 6),
        E(80, 50, 34, 34, None, ROJO_OSCURO, 1.5),
    ], "Aro grande de psicomotricidad de color rojo.")
    put("left", "C", fondo_sala() + fl("Handbag", 96, 36, 36) + frecha((92, 48), (28, 48), AZUL_OSCURO, 5),
        "Flecha gruesa señalando claramente hacia la izquierda.")
    put("middle", "D", fondo_mesa() + [
        R(24, 36, 26, 26, 3, GRIS, GRIS_OSCURO, 2),
        R(64, 30, 32, 32, 4, AMARILLO, AMARILLO_OSCURO, 3),
        R(110, 36, 26, 26, 3, GRIS, GRIS_OSCURO, 2),
    ] + frecha((80, 10), (80, 28), ROJO_OSCURO, 3.5), "Pieza central señalada en mitad de otras dos.")
    put("mosaic", "D", fondo_mesa() + [
        R(44, 18, 22, 22, 2, ROJO, TINTA, 1.5),
        R(68, 18, 22, 22, 2, AMARILLO, TINTA, 1.5),
        R(92, 18, 22, 22, 2, AZUL, TINTA, 1.5),
        R(44, 42, 22, 22, 2, AZUL, TINTA, 1.5),
        R(68, 42, 22, 22, 2, VERDE, TINTA, 1.5),
        R(92, 42, 22, 22, 2, ROJO, TINTA, 1.5),
        R(44, 66, 22, 22, 2, VERDE, TINTA, 1.5),
        R(68, 66, 22, 22, 2, ROJO, TINTA, 1.5),
        R(92, 66, 22, 22, 2, AMARILLO, TINTA, 1.5),
    ], "Mosaico de teselas cuadradas de colores variados.")
    put("pattern", "D", fondo_mesa() + [
        E(30, 48, 12, 12, ROJO, ROJO_OSCURO, 2),
        R(50, 36, 22, 22, 2, AZUL, AZUL_OSCURO, 2),
        E(90, 48, 12, 12, ROJO, ROJO_OSCURO, 2),
        R(110, 36, 22, 22, 2, AZUL, AZUL_OSCURO, 2),
    ], "Serie repetida: círculo rojo, cuadrado azul, círculo rojo, cuadrado azul.")
    put("pointy", "D", fondo_mesa() + [
        F("M44 76 L80 16 L116 76 Z", AMARILLO, AMARILLO_OSCURO, 2.5),
    ] + frecha((118, 22), (88, 18), ROJO_OSCURO, 3.5), "Punta triangular afilada señalada arriba.")
    put("rough", "C", fondo_mar() + fl("Water wave", 22, 22, 56) + fl("Water wave", 74, 18, 60) + [
        L("M24 20 L48 12", ROJO_OSCURO, 3),
        L("M116 14 L138 24", ROJO_OSCURO, 3),
    ], "Olas altas y movidas representando textura o mar bravo.")
    put("round", "D", fondo_mesa() + [E(80, 48, 28, 28, AMARILLO, AMARILLO_OSCURO, 3)],
        "Forma completamente redonda sin esquinas.")
    put("shape", "D", fondo_mesa() + [
        E(34, 48, 14, 14, ROJO, ROJO_OSCURO, 2),
        R(64, 34, 28, 28, 2, AZUL, AZUL_OSCURO, 2),
        F("M106 62 L124 30 L142 62 Z", VERDE, VERDE_OSCURO, 2),
    ], "Círculo, cuadrado y triángulo mostrando formas geométricas.")
    put("slow", "C", fondo_prado() + fl("Turtle", 38, 28, 56) + frecha((102, 50), (126, 50), GRIS_OSCURO, 2.5),
        "Tortuga avanzando con flecha corta y tranquila.")
    put("slower", "C", fondo_prado() + fl("Turtle", 44, 30, 48) + [
        L("M104 42 L104 60", AZUL_OSCURO, 3),
        L("M114 42 L114 60", AZUL_OSCURO, 3),
    ], "Tortuga frenando aún más despacio.")
    put("faster", "C", fondo_prado() + fl("Wind face", 24, 26, 46) + frecha((78, 36), (138, 36), ROJO_OSCURO, 4.5) + frecha((78, 56), (138, 56), ROJO_OSCURO, 4.5),
        "Doble flecha roja impulsando velocidad aún mayor.")
    put("smooth", "D", fondo_mesa() + [
        E(80, 50, 38, 22, "#bae6fd", AGUA_OSCURO, 2.5),
        L("M54 42 Q80 34 106 42", BLANCO, 3),
    ], "Superficie pulida, suave y perfectamente lisa.")
    put("sticky", "D", fondo_mesa() + [
        R(48, 34, 64, 28, 6, AMARILLO, AMARILLO_OSCURO, 2),
        L("M66 62 Q70 78 62 82", AMARILLO_OSCURO, 3),
        L("M92 62 Q88 76 96 80", AMARILLO_OSCURO, 3),
    ], "Sustancia espesa pegajosa con hilos colgando.")
    put("symmetry", "D", fondo_sala() + [
        L("M80 12 L80 86", ROJO_OSCURO, 2.5),
        F("M74 30 C42 14 30 46 56 54 C38 66 54 84 74 66 Z", MORADO, TINTA, 2),
        F("M86 30 C118 14 130 46 104 54 C122 66 106 84 86 66 Z", MORADO, TINTA, 2),
    ], "Alas simétricas idénticas a ambos lados de un eje central.")
    put("tile", "D", fondo_mesa() + [
        R(50, 18, 60, 60, 3, "#e0f2fe", AZUL_OSCURO, 2.5),
        L("M80 18 L80 78", AZUL_OSCURO, 1.8),
        L("M50 48 L110 48", AZUL_OSCURO, 1.8),
        E(80, 48, 12, 12, AMARILLO, AMARILLO_OSCURO, 1.8),
    ], "Azulejo cuadrado esmaltado con dibujo geométrico.")

    # ── Sustantivos y escenas de unidad (5-6 años) ─────────────────────────
    put("balance beam", "D", fondo_sala() + [
        R(20, 48, 120, 12, 3, MADERA, MADERA_OSCURA, 2.2),
        R(32, 60, 12, 22, 2, GRIS_OSCURO, TINTA, 1.8),
        R(116, 60, 12, 22, 2, GRIS_OSCURO, TINTA, 1.8),
    ], "Barra horizontal de equilibrio apoyada sobre dos soportes.")
    put("beginning", "C", fondo_prado() + fl("Seedling", 36, 36, 44) + frecha((86, 52), (132, 52), VERDE_OSCURO, 4),
        "Punto de partida e inicio de un camino o actividad.")
    put("blowhole", "C", fondo_mar() + fl("Spouting whale", 42, 20, 68) + frecha((76, 8), (76, 26), AZUL_OSCURO, 3),
        "Ballena soltando agua por el espiráculo en la parte superior.")
    put("card", "C", fondo_mesa() + [
        R(36, 22, 88, 56, 4, BLANCO, AZUL_OSCURO, 2.5),
        R(98, 28, 18, 18, 2, ROJO, ROJO_OSCURO, 1.8),
        L("M46 42 L84 42", GRIS_OSCURO, 2),
        L("M46 56 L76 56", GRIS_OSCURO, 2),
    ], "Postal o tarjeta escrita con sello en la esquina.")
    put("careful", "C", fondo_sala() + nino((52, 28), (52, 40), (52, 60), [[(68, 44)], [(36, 52)]], [[(46, 86)], [(58, 86)]], mira=1)
        + _vaso(76, 30, 26, 32, 0.85) + [E(122, 28, 12, 12, AMARILLO, AMARILLO_OSCURO, 2), L("M122 20 L122 28", TINTA, 2.5), E(122, 34, 2, 2, TINTA)],
        "Niño llevando un vaso lleno con mucho cuidado.")
    put("command", "C", fondo_sala() + nino((46, 28), (46, 40), (46, 60), [[(74, 34)], [(32, 52)]], [[(40, 86)], [(52, 86)]], mira=1)
        + fl("Stop sign", 94, 24, 46), "Niño dando una indicación clara con gesto de mano.")
    put("compromise", "C", fondo_sala() + fl("Balance scale", 46, 18, 66) + fl("Handshake", 56, 54, 44),
        "Balanza equilibrada y acuerdo justo entre dos personas.")
    put("countdown to midnight", "C", fondo_noite() + fl("Timer clock", 34, 18, 54) + fl("Crescent moon", 102, 14, 36) + [
        L("M34 78 L126 78", AMARILLO, 2.5),
    ], "Reloj marcando la cuenta atrás hasta medianoche.")
    put("creative", "C", fondo_mesa() + fl("Artist palette", 24, 24, 52) + fl("Paintbrush", 82, 18, 44) + fl("Sparkles", 98, 48, 34),
        "Paleta de colores, pincel y chispas de imaginación.")
    put("dangerous", "D", fondo_cielo() + [
        F("M80 14 L126 80 L34 80 Z", AMARILLO, ROJO_OSCURO, 3.5),
        L("M80 34 L80 56", TINTA, 5),
        E(80, 68, 3.5, 3.5, TINTA),
    ], "Triángulo amarillo de peligro con borde rojo.")
    put("deal", "C", fondo_sala() + fl("Handshake", 46, 22, 66) + [E(34, 34, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.8), E(124, 34, 8, 8, VERDE, VERDE_OSCURO, 1.8)],
        "Apretón de manos cerrando un buen trato.", "deal_handshake")
    put("destination", "C", fondo_prado() + fl("Compass", 24, 28, 46) + frecha((74, 50), (104, 50), ROJO_OSCURO, 3.5) + [
        L("M116 20 L116 76", TINTA, 3),
        F("M116 20 L144 30 L116 40 Z", ROJO, ROJO_OSCURO, 1.8),
    ], "Brújula apuntando a la bandera de destino al final del viaje.")
    put("director", "C", fondo_sala() + nino((52, 26), (52, 38), (52, 58), [[(76, 36)], [(38, 48)]], [[(46, 84)], [(58, 84)]], mira=1)
        + fl("Drum", 92, 38, 44) + notas([(100, 18)]), "Director guiando el ritmo del grupo.")
    put("dolphin pod", "C", fondo_mar() + fl("Dolphin", 22, 26, 44) + fl("Dolphin", 60, 14, 44) + fl("Dolphin", 98, 28, 44),
        "Grupo de tres delfines saltando juntos en el mar.")
    put("dramatic", "C", fondo_sala() + fl("Performing arts", 46, 18, 66),
        "Máscaras de teatro expresando escenas dramáticas.")
    put("fairy tale", "C", fondo_noite() + fl("Open book", 36, 28, 56) + fl("Sparkles", 92, 14, 42),
        "Libro abierto de cuentos mágicos con estrellas brillantes.")
    put("fishing village", "C", fondo_mar() + fl("House", 22, 16, 42) + fl("House", 64, 18, 40) + fl("Sailboat", 104, 38, 42),
        "Casitas junto al puerto y velero de aldea marinera.")
    put("journey", "C", fondo_prado() + fl("World map", 24, 22, 54) + fl("Airplane", 88, 16, 46) + [L("M48 64 Q80 48 118 64", ROJO_OSCURO, 2.5)],
        "Mapa del mundo y avión trazando la ruta de un viaje.")
    put("memory lane", "C", fondo_prado() + [
        F("M34 86 Q60 44 76 18 L84 18 Q100 44 126 86 Z", TIERRA_CLARA, BARRO, 2),
    ] + fl("Camera", 24, 16, 36) + fl("Backpack", 104, 16, 36), "Camino lleno de fotos y recuerdos del curso.")
    put("mystery bag", "D", fondo_sala() + [
        F("M54 34 L106 34 L114 82 L46 82 Z", MORADO, TINTA, 2.5),
        F("M62 34 L66 18 L94 18 L98 34 Z", MORADO, TINTA, 2),
        L("M72 50 Q80 40 88 48 Q90 56 80 60", BLANCO, 3.5),
        E(80, 69, 3, 3, BLANCO),
    ], "Bolsa cerrada opaca con interrogación misteriosa.")
    put("passport", "D", fondo_mesa() + [
        R(50, 16, 60, 68, 4, MAR_PROF, TINTA, 2.5),
        E(80, 44, 16, 16, None, AMARILLO, 2),
        L("M64 44 L96 44", AMARILLO, 1.5),
        L("M80 28 L80 60", AMARILLO, 1.5),
        L("M64 68 L96 68", AMARILLO, 2),
    ], "Libreta azul de pasaporte con globo dorado.")
    put("pot", "C", fondo_mesa() + fl("Pot of food", 46, 18, 66),
        "Olla o cazuela honda sobre la mesa.")
    put("primary school", "C", fondo_prado() + fl("School", 44, 14, 70) + fl("Backpack", 112, 48, 32),
        "Edificio grande de colegio de Primaria.")
    put("quiet time", "C", fondo_noite() + fl("Open book", 34, 30, 48) + fl("Crescent moon", 98, 16, 38),
        "Rato tranquilo de calma, lectura y descanso.")
    put("responsible", "C", fondo_mesa() + fl("Basket", 30, 32, 48) + fl("Red apple", 86, 26, 36) + frecha((84, 34), (56, 34), VERDE_OSCURO, 3.5),
        "Recogiendo y cuidando las cosas con responsabilidad.")
    put("rhythmic", "C", fondo_sala() + fl("Drum", 36, 28, 52) + notas([(98, 22), (118, 34), (104, 52)]),
        "Tambor acompañado de compases rítmicos regulares.")
    put("self-care", "C", fondo_sala() + fl("Toothbrush", 28, 24, 42) + fl("Soap", 70, 34, 38) + fl("Red heart", 108, 18, 34),
        "Cuidarse lavando dientes y manos con cariño.")
    put("statue", "C", fondo_sala() + nino((78, 24), (78, 36), (78, 56), [[(56, 32)], [(100, 32)]], [[(72, 84)], [(84, 84)]], camisa=(GRIS, GRIS_OSCURO))
        + [R(56, 84, 44, 10, 2, GRIS, GRIS_OSCURO, 2)], "Figura completamente inmóvil sobre un pedestal.")
    put("steps", "D", fondo_sala() + [
        R(28, 68, 104, 14, 2, MADERA, MADERA_OSCURA, 2),
        R(48, 54, 84, 14, 2, MADERA, MADERA_OSCURA, 2),
        R(68, 40, 64, 14, 2, MADERA, MADERA_OSCURA, 2),
        R(88, 26, 44, 14, 2, MADERA, MADERA_OSCURA, 2),
    ], "Escalones ascendentes en perspectiva lateral.")
    put("summer holidays", "C", fondo_mar() + fl("Beach with umbrella", 32, 16, 56) + fl("Sun", 104, 10, 38),
        "Playa, sombrilla y sol radiante de vacaciones de verano.")
    put("suncream bottle", "C", fondo_mar() + fl("Lotion bottle", 44, 18, 56) + fl("Sun", 104, 14, 34),
        "Bote de crema solar protectora bajo el sol.")
    put("travel map", "C", fondo_mesa() + fl("World map", 34, 16, 68) + fl("Compass", 102, 42, 38) + [L("M46 46 Q68 30 92 52", ROJO_OSCURO, 2.5)],
        "Mapa extendido de viaje con ruta marcada y brújula.")
    put("wolf costume", "C", fondo_sala() + fl("Wolf", 38, 18, 64) + fl("Coat", 100, 36, 40),
        "Disfraz de lobo preparado para representar el cuento.")

    # ── Verbos, expresiones y consignas TPR (5-6 años) ─────────────────────
    put("arms up", "C", fondo_prado() + nino((78, 26), (78, 38), (78, 58), [[(66, 12)], [(90, 12)]], [[(72, 86)], [(84, 86)]])
        + frecha((44, 62), (44, 16), VERDE_OSCURO, 3.5) + frecha((112, 62), (112, 16), VERDE_OSCURO, 3.5),
        "Niño levantando bien alto los dos brazos.")
    put("arrive", "C", fondo_prado() + fl("Train", 26, 26, 52) + frecha((82, 50), (104, 50), VERDE_OSCURO, 3) + [
        L("M118 22 L118 76", TINTA, 3),
        F("M118 22 L144 32 L118 42 Z", VERDE, VERDE_OSCURO, 2),
    ], "Llegando por fin a la meta o estación.")
    put("balance", "C", fondo_sala() + [R(24, 72, 112, 10, 2, MADERA, MADERA_OSCURA, 2)]
        + nino((78, 22), (78, 34), (78, 52), [[(48, 34)], [(108, 34)]], [[(74, 72)], [(86, 62)]]),
        "Niño manteniendo el equilibrio sobre una línea o viga.")
    put("balance a plate", "C", fondo_sala() + nino((78, 26), (78, 38), (78, 58), [[(58, 34)], [(98, 48)]], [[(72, 86)], [(84, 86)]])
        + [E(58, 28, 18, 5, BLANCO, AZUL_OSCURO, 2)], "Niño equilibrando un plato plano sobre la palma de la mano.")
    put("blend", "C", fondo_mesa() + [
        E(62, 46, 22, 22, AMARILLO, AMARILLO_OSCURO, 2),
        E(98, 46, 22, 22, AZUL, AZUL_OSCURO, 2),
        E(80, 46, 12, 18, VERDE, VERDE_OSCURO, 1.5),
    ], "Dos colores superponiéndose y mezclándose en verde.")
    put("can we trade", "C", fondo_mesa() + fl("Red apple", 26, 30, 38) + frecha((66, 24), (94, 24), VERDE_OSCURO, 3)
        + frecha((94, 62), (66, 62), AZUL_OSCURO, 3) + fl("Banana", 98, 30, 38),
        "Flechas cruzadas proponiendo intercambiar un objeto por otro.")
    put("climb a ladder", "C", fondo_prado() + fl("Ladder", 48, 12, 64) + frecha((116, 72), (116, 18), VERDE_OSCURO, 4),
        "Escalera vertical con flecha indicando subir peldaño a peldaño.")
    put("copy my movements", "C", fondo_sala() + nino((46, 26), (46, 38), (46, 58), [[(28, 24)], [(64, 48)]], [[(40, 84)], [(52, 84)]])
        + frecha((70, 38), (94, 38), AZUL_OSCURO, 3)
        + nino((114, 26), (114, 38), (114, 58), [[(96, 24)], [(132, 48)]], [[(108, 84)], [(120, 84)]], camisa=(VERDE, VERDE_OSCURO)),
        "Dos niños haciendo exactamente el mismo movimiento en espejo.")
    put("count", "D", fondo_mesa() + [
        E(34, 48, 10, 10, ROJO, ROJO_OSCURO, 2),
        E(64, 48, 10, 10, AZUL, AZUL_OSCURO, 2),
        E(94, 48, 10, 10, VERDE, VERDE_OSCURO, 2),
        E(124, 48, 10, 10, AMARILLO, AMARILLO_OSCURO, 2),
        L("M34 30 L34 20", TINTA, 2.5),
        L("M60 22 L68 22 L60 30 L68 30", TINTA, 2),
    ], "Fichas alineadas contándose una por una.")
    put("count in twos", "D", fondo_mesa() + [
        R(20, 32, 34, 32, 4, "#dbeafe", AZUL_OSCURO, 2),
        E(31, 48, 6, 6, AZUL, AZUL_OSCURO, 1.5), E(44, 48, 6, 6, AZUL, AZUL_OSCURO, 1.5),
        R(63, 32, 34, 32, 4, "#dcfce7", VERDE_OSCURO, 2),
        E(74, 48, 6, 6, VERDE, VERDE_OSCURO, 1.5), E(87, 48, 6, 6, VERDE, VERDE_OSCURO, 1.5),
        R(106, 32, 34, 32, 4, "#fef9c3", AMARILLO_OSCURO, 2),
        E(117, 48, 6, 6, AMARILLO, AMARILLO_OSCURO, 1.5), E(130, 48, 6, 6, AMARILLO, AMARILLO_OSCURO, 1.5),
    ], "Parejas agrupadas de dos en dos para contar.")
    put("count the days", "C", fondo_mesa() + fl("Tear-off calendar", 36, 18, 56) + [
        E(104, 34, 7, 7, ROJO, ROJO_OSCURO, 1.5),
        E(124, 34, 7, 7, AZUL, AZUL_OSCURO, 1.5),
        E(104, 56, 7, 7, VERDE, VERDE_OSCURO, 1.5),
    ], "Calendario y marcas contando cuántos días quedan.")
    put("count three leaves and jump over the ring", "C", fondo_prado()
        + fl("Maple leaf", 18, 22, 24) + fl("Maple leaf", 42, 22, 24) + fl("Maple leaf", 66, 22, 24)
        + [E(116, 70, 22, 10, None, ROJO, 4)]
        + nino((116, 18), (116, 30), (116, 48), [[(98, 26)], [(134, 26)]], [[(108, 60)], [(124, 60)]]),
        "Tres hojas contadas antes de saltar por encima del aro.", "count_3_leaves_jump_ring")
    put("crawl", "C", fondo_prado() + [
        R(66, 52, 42, 16, 8, AZUL, AZUL_OSCURO, 2),
        E(56, 48, 12, 12, PEL, PELB, 2),
        F("M44 46 C44 34 68 34 68 46 C62 41 50 41 44 46 Z", BARRO, TINTA, 1.5),
        L("M72 64 L68 82", PELB, 5),
        L("M82 64 L80 82", PELB, 5),
        L("M102 64 L112 78 L100 82", AZUL_OSCURO, 5),
        L("M94 64 L104 78 L92 82", AZUL_OSCURO, 5),
    ] + frecha((40, 26), (118, 26), VERDE_OSCURO, 3.5), "Niño gateando a cuatro patas por el suelo.")
    put("cut", "C", fondo_mesa() + fl("Scissors", 26, 20, 48) + fl("Page facing up", 86, 20, 52) + [
        L("M82 46 L136 46", ROJO_OSCURO, 2.5),
    ], "Tijeras cortando una hoja de papel por la línea.")
    put("draw", "C", fondo_mesa() + fl("Paintbrush", 30, 18, 46) + [
        R(74, 20, 56, 56, 4, BLANCO, GRIS_OSCURO, 2.2),
        L("M86 58 Q102 32 118 54", AZUL_OSCURO, 3),
    ], "Pincel dibujando trazos de colores en un papel blanco.")
    put("exchange gifts", "C", fondo_sala() + nino((38, 28), (38, 40), (38, 60), [[(56, 44)], [(24, 52)]], [[(32, 86)], [(44, 86)]], mira=1)
        + fl("Wrapped gift", 64, 32, 32)
        + nino((122, 28), (122, 40), (122, 60), [[(104, 44)], [(136, 52)]], [[(116, 86)], [(128, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos amigos intercambiando paquetes de regalo.")
    put("explore", "C", fondo_prado() + fl("Magnifying glass tilted left", 30, 20, 56) + fl("Compass", 92, 34, 44),
        "Lupa y brújula explorando objetos y caminos nuevos.")
    put("fasten your seatbelts", "C", fondo_sala() + fl("Seat", 36, 18, 56) + [
        L("M48 52 L92 52", ROJO_OSCURO, 4),
        R(66, 46, 12, 12, 2, GRIS, GRIS_OSCURO, 2),
    ] + frecha((104, 50), (80, 50), VERDE_OSCURO, 3.5), "Cinturón de seguridad abrochado firmemente al asiento.")
    put("feel without looking", "C", fondo_sala() + [
        E(46, 46, 17, 17, PEL, PELB, 2),
        F("M29 44 C29 30 63 30 63 44 C56 38 36 38 29 44 Z", BARRO, TINTA, 1.5),
        R(28, 38, 36, 10, 2, MORADO, TINTA, 1.8),
        L("M40 55 Q46 59 52 55", TINTA, 1.8),
    ] + fl("Open hands", 80, 32, 46), "Ojos tapados tocando y reconociendo con las manos.")
    put("feel your heartbeat", "C", fondo_sala() + nino((56, 26), (56, 38), (56, 58), [[(48, 44)], [(64, 44)]], [[(50, 84)], [(62, 84)]])
        + fl("Beating heart", 92, 24, 46), "Mano sobre el pecho sintiendo el latido del corazón.")
    put("fill", "C", fondo_mesa() + [
        F("M24 22 L56 18 L48 44 L22 40 Z", AZUL, AZUL_OSCURO, 2),
        L("M52 28 Q74 34 76 54", AGUA, 3.5),
    ] + _vaso(64, 44, 38, 34, 0.85), "Jarra echando líquido hasta llenar el recipiente.")
    put("fill the pot, plant the seed and water it", "C", fondo_prado() + fl("Potted plant", 26, 24, 50) + fl("Seedling", 74, 34, 34)
        + gotas([(112, 24), (124, 38), (114, 52)]), "Maceta con tierra, semilla plantada y gotas de riego.", "fill_pot_plant_seed")
    put("find", "C", fondo_prado() + fl("Magnifying glass tilted left", 34, 22, 54) + fl("Spiral shell", 88, 36, 40),
        "Lupa encontrando exactamente el objeto escondido.")
    put("hand in hand", "C", fondo_prado() + nino((50, 26), (50, 38), (50, 58), [[(36, 48)], [(80, 48)]], [[(44, 84)], [(56, 84)]])
        + nino((110, 26), (110, 38), (110, 58), [[(80, 48)], [(124, 48)]], [[(104, 84)], [(116, 84)]], camisa=(VERDE, VERDE_OSCURO)),
        "Dos niños caminando cogidos de la mano.")
    put("hang", "C", fondo_sala() + [
        L("M30 22 L130 22", MADERA_OSCURA, 4),
        E(80, 22, 5, 5, TINTA),
    ] + fl("Coat", 52, 26, 56), "Prenda colgada en su gancho en lo alto.")
    put("harvest fruit", "C", fondo_prado() + fl("Red apple", 28, 22, 38) + frecha((70, 40), (92, 48), VERDE_OSCURO, 3) + fl("Basket", 94, 30, 48),
        "Fruta recién cogida metiéndose dentro de la cesta.")
    put("have a safe trip", "C", fondo_cielo() + fl("Airplane", 32, 18, 56) + fl("Waving hand", 96, 34, 44),
        "Avión despegando y mano despidiendo deseando buen viaje.")
    put("here you go. thank you! your turn", "C", fondo_sala() + nino((42, 28), (42, 40), (42, 60), [[(64, 44)], [(28, 52)]], [[(36, 86)], [(48, 86)]], mira=1)
        + fl("Package", 68, 36, 28) + frecha((66, 22), (96, 22), VERDE_OSCURO, 3)
        + nino((118, 28), (118, 40), (118, 60), [[(98, 44)], [(132, 52)]], [[(112, 86)], [(124, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Intercambio amable pasando el objeto y el turno.", "here_you_go_thank_you_turn")
    put("here you go: give the light to the next pair", "C", fondo_noite() + nino((40, 28), (40, 40), (40, 60), [[(62, 44)], [(26, 52)]], [[(34, 86)], [(46, 86)]], mira=1)
        + fl("Flashlight", 64, 34, 30) + frecha((64, 22), (96, 22), AMARILLO, 3)
        + nino((120, 28), (120, 40), (120, 60), [[(100, 44)], [(134, 52)]], [[(114, 86)], [(126, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Pasando la linterna encendida a la siguiente pareja.", "give_light_next_pair")
    put("here you go: pass the soil to your friend", "C", fondo_prado() + nino((40, 28), (40, 40), (40, 60), [[(62, 44)], [(26, 52)]], [[(34, 86)], [(46, 86)]], mira=1)
        + [F("M64 56 Q80 42 96 56 Z", BARRO, TINTA, 2)] + frecha((64, 24), (96, 24), VERDE_OSCURO, 3)
        + nino((120, 28), (120, 40), (120, 60), [[(100, 44)], [(134, 52)]], [[(114, 86)], [(126, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Pasando el recipiente con tierra al compañero.", "pass_soil_friend")
    put("i am blending yellow and blue because i want to make green", "C", fondo_mesa() + [
        E(34, 48, 16, 16, AMARILLO, AMARILLO_OSCURO, 2),
        L("M56 48 L66 48", TINTA, 3), L("M61 43 L61 53", TINTA, 3),
        E(84, 48, 16, 16, AZUL, AZUL_OSCURO, 2),
    ] + frecha((102, 48), (118, 48), TINTA, 3) + [E(136, 48, 16, 16, VERDE, VERDE_OSCURO, 2)],
        "Amarillo más azul producen color verde nuevo.", "blending_yellow_blue_green")
    put("i am not finished yet", "C", fondo_mesa() + [
        R(28, 32, 48, 36, 3, BLANCO, GRIS_OSCURO, 2),
        R(36, 40, 18, 20, 2, AZUL, AZUL_OSCURO, 1.5),
    ] + fl("Hourglass not done", 96, 20, 50), "Trabajo a medio completar junto a reloj de arena en marcha.")
    put("i feel proud of our work", "C", fondo_sala() + nino((48, 28), (48, 40), (48, 60), [[(34, 48)], [(62, 48)]], [[(42, 86)], [(54, 86)]])
        + [R(82, 26, 48, 44, 3, BLANCO, AMARILLO_OSCURO, 2.5)] + fl("Star", 94, 34, 24),
        "Niño satisfecho mostrando un trabajo terminado con estrella.")
    put("if it climbs the chestnut tree, crawl to the green mat", "C", fondo_prado() + fl("Chestnut", 20, 18, 38)
        + frecha((60, 34), (82, 34), VERDE_OSCURO, 3) + [
            R(84, 68, 56, 14, 3, VERDE, VERDE_OSCURO, 2),
            R(100, 44, 30, 12, 6, AZUL, AZUL_OSCURO, 1.8),
            E(94, 42, 9, 9, PEL, PELB, 1.8),
            F("M85 40 C85 31 103 31 103 40 Z", BARRO, TINTA, 1.3),
            L("M104 54 L102 68", PELB, 4),
            L("M126 54 L132 68", AZUL_OSCURO, 4),
        ], "Si toca castaño, gatear hasta la colchoneta verde.", "climbs_chestnut_green_mat")
    put("if it's hot, we play with water", "C", fondo_cielo() + fl("Sun", 20, 14, 40) + [E(92, 64, 34, 14, AGUA, AGUA_OSCURO, 2)] + gotas([(80, 32), (104, 26), (116, 42)]),
        "Sol caluroso y juego refrescante con agua.", "hot_play_with_water")
    put("if the seed is big, put it in the brown pot", "C", fondo_prado() + [
        E(34, 54, 16, 12, TIERRA_CLARA, BARRO, 2),
    ] + frecha((54, 46), (80, 46), BARRO, 3.5) + [
        F("M88 38 L126 38 L120 76 L94 76 Z", BARRO, TINTA, 2),
    ], "Semilla grande yendo hacia la maceta marrón.", "big_seed_brown_pot")
    put("if the shell is smooth, put it in the blue basket", "C", fondo_prado() + fl("Spiral shell", 24, 30, 38)
        + frecha((64, 46), (86, 46), AZUL_OSCURO, 3.5) + [
            R(90, 38, 46, 32, 4, AZUL, AZUL_OSCURO, 2.5),
            L("M96 38 L130 38", BLANCO, 2),
        ], "Concha lisa entrando en la cesta azul.", "smooth_shell_blue_basket")
    put("if the water is cold, walk to the blue mat", "C", fondo_cielo() + fl("Ice", 22, 22, 38) + frecha((62, 42), (84, 42), AZUL_OSCURO, 3)
        + [R(88, 66, 48, 16, 3, AZUL, AZUL_OSCURO, 2)] + nino((112, 24), (112, 34), (112, 48), [[(100, 42)], [(124, 42)]], [[(106, 66)], [(118, 66)]]),
        "Agua fría señalando caminar hacia la colchoneta azul.", "cold_water_blue_mat")
    put("investigate", "C", fondo_mesa() + fl("Magnifying glass tilted left", 34, 18, 56) + fl("Chestnut", 88, 36, 38),
        "Lupa observando de cerca para investigar detalles.")
    put("it is fair to share", "C", fondo_mesa() + fl("Red apple", 64, 18, 32)
        + nino((38, 34), (38, 46), (38, 64), [[(54, 48)], [(24, 54)]], [[(32, 86)], [(44, 86)]], mira=1)
        + nino((122, 34), (122, 46), (122, 64), [[(106, 48)], [(136, 54)]], [[(116, 86)], [(128, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Reparto justo de la fruta entre dos compañeros.")
    put("it's your turn to direct", "C", fondo_sala() + nino((56, 26), (56, 38), (56, 58), [[(78, 36)], [(42, 48)]], [[(50, 84)], [(62, 84)]], mira=1)
        + frecha((116, 36), (86, 36), VERDE_OSCURO, 3.5) + fl("Drum", 92, 52, 38),
        "Flecha señalando al niño al que le toca dirigir.")
    put("look at the card and copy the shape", "C", fondo_mesa() + [
        R(24, 24, 42, 48, 3, BLANCO, AZUL_OSCURO, 2),
        F("M34 60 L45 34 L56 60 Z", VERDE, VERDE_OSCURO, 2),
    ] + frecha((70, 48), (92, 48), AZUL_OSCURO, 3) + [F("M98 62 L114 32 L130 62 Z", VERDE, VERDE_OSCURO, 2.2)],
        "Tarjeta modelo con triángulo y figura copiada igual.", "look_card_copy_shape")
    put("look, a shell", "C", fondo_mar() + fl("Eye", 24, 22, 42) + frecha((70, 44), (92, 44), AZUL_OSCURO, 3) + fl("Spiral shell", 94, 24, 46),
        "Mirando con asombro una concha encontrada.")
    put("make your pattern: clap, jump, tap", "C", fondo_sala() + fl("Clapping hands", 18, 28, 34)
        + nino((78, 18), (78, 28), (78, 44), [[(64, 24)], [(92, 24)]], [[(72, 64)], [(84, 64)]])
        + fl("Drum", 106, 32, 36), "Serie de tres acciones: palma, salto, toque.", "pattern_clap_jump_tap")
    put("mateo, find a round cold chestnut", "C", fondo_prado() + fl("Magnifying glass tilted left", 22, 24, 42)
        + fl("Chestnut", 68, 30, 40) + copos_nieve([(118, 24), (126, 48)]),
        "Lupa buscando una castaña fría y redonda.", "mateo_round_cold_chestnut")
    put("may i see your ticket", "C", fondo_sala() + fl("Ticket", 30, 24, 48) + fl("Eye", 92, 24, 40),
        "Mostrando el billete de viaje para revisarlo.")
    put("noa, walk five steps and take the white shell", "C", fondo_mar() + fl("Footprints", 24, 24, 44)
        + frecha((70, 46), (94, 46), AZUL_OSCURO, 3) + fl("Spiral shell", 96, 26, 44),
        "Caminar cinco pasos hasta coger la concha blanca.", "noa_5_steps_shell")
    put("noa, walk slowly and give the smooth leaf to your friend", "C", fondo_prado() + fl("Turtle", 20, 42, 32)
        + fl("Maple leaf", 58, 26, 34) + frecha((94, 42), (112, 42), VERDE_OSCURO, 3) + nino((124, 28), (124, 40), (124, 58), [[(110, 46)], [(136, 48)]], [[(118, 84)], [(130, 84)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Caminar despacio y entregar la hoja lisa a un amigo.", "noa_slowly_leaf_friend")
    put("now the group copies your pattern", "C", fondo_sala() + nino((34, 26), (34, 38), (34, 58), [[(22, 22)], [(46, 22)]], [[(28, 84)], [(40, 84)]])
        + frecha((54, 42), (76, 42), MORADO, 3)
        + nino((94, 28), (94, 40), (94, 58), [[(82, 24)], [(106, 24)]], [[(88, 84)], [(100, 84)]], camisa=(VERDE, VERDE_OSCURO))
        + nino((128, 28), (128, 40), (128, 58), [[(116, 24)], [(140, 24)]], [[(122, 84)], [(134, 84)]], camisa=(AMARILLO, AMARILLO_OSCURO)),
        "Todo el grupo repitiendo el patrón marcado.", "group_copies_pattern")
    put("pass the rhythm stick around the circle", "C", fondo_sala() + [
        E(80, 50, 32, 28, None, AGUA_OSCURO, 2.5),
        L("M66 20 L94 26", TIERRA, 5),
        L("M112 36 Q124 54 106 72", ROJO_OSCURO, 2.5),
        F("M106 72 L114 68 L112 76 Z", ROJO_OSCURO),
    ], "Palo de madera circulando alrededor de todo el corro.", "pass_rhythm_stick_circle")
    put("put the rough one here and the smooth one there", "C", fondo_mesa() + fl("Rock", 22, 34, 38) + frecha((64, 50), (88, 50), VERDE_OSCURO, 3)
        + [E(116, 52, 22, 16, "#bae6fd", AGUA_OSCURO, 2)],
        "Piedra áspera en un lado y superficie lisa en el otro.", "rough_here_smooth_there")
    put("put your arms up and your left foot forward", "C", fondo_prado() + nino((76, 24), (76, 36), (76, 56), [[(64, 10)], [(88, 10)]], [[(54, 82)], [(84, 84)]])
        + frecha((52, 72), (24, 72), AZUL_OSCURO, 3),
        "Niño con brazos arriba y pie izquierdo adelantado.", "arms_up_left_foot")
    put("ready, steady, go: pass the tray to your friend", "C", fondo_sala() + nino((38, 28), (38, 40), (38, 60), [[(56, 46)], [(24, 52)]], [[(32, 86)], [(44, 86)]], mira=1)
        + [R(60, 48, 36, 6, 2, AMARILLO_OSCURO, TINTA, 1.8)] + frecha((64, 24), (96, 24), VERDE_OSCURO, 3)
        + nino((122, 28), (122, 40), (122, 60), [[(102, 46)], [(136, 52)]], [[(116, 86)], [(128, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Pasando la bandeja al amigo con ritmo.", "ready_steady_pass_tray")
    put("recharge", "C", fondo_sala() + fl("Battery", 38, 20, 56) + [
        F("M108 22 L96 46 L106 46 L98 70 L118 42 L106 42 Z", AMARILLO, AMARILLO_OSCURO, 1.8),
    ], "Pila recargándose con símbolo de energía.")
    put("sit on the green mat and freeze", "C", fondo_sala() + [R(44, 68, 72, 16, 4, VERDE, VERDE_OSCURO, 2)]
        + nino((78, 32), (78, 42), (78, 58), [[(66, 50)], [(90, 50)]], [[(70, 68)], [(86, 68)]])
        + fl("Stop sign", 112, 18, 34), "Niño sentado quieto como estatua en la colchoneta verde.", "sit_green_mat_freeze")
    put("slither", "C", fondo_prado() + fl("Snake", 30, 26, 56) + frecha((94, 54), (134, 54), VERDE_OSCURO, 3.5),
        "Serpiente reptando pegada al suelo.")
    put("stargaze", "C", fondo_noite() + fl("Telescope", 28, 32, 52) + fl("Star", 92, 14, 28) + fl("Star", 118, 28, 24),
        "Telescopio apuntando al cielo estrellado nocturno.")
    put("step across", "C", fondo_prado() + [E(80, 74, 24, 8, AGUA, AGUA_OSCURO, 2)]
        + nino((78, 20), (78, 32), (78, 50), [[(64, 42)], [(92, 42)]], [[(56, 70)], [(102, 70)]])
        + [L("M48 64 Q80 42 112 64", VERDE_OSCURO, 2.5)], "Niño dando una zancada amplia por encima de un obstáculo.")
    put("step slowly and don't spill the water into the river", "C", fondo_mar() + nino((42, 26), (42, 38), (42, 58), [[(56, 46)], [(28, 50)]], [[(36, 84)], [(48, 84)]], mira=1)
        + _vaso(64, 34, 22, 26, 0.85) + fl("Turtle", 104, 52, 34),
        "Paso lento llevando agua sin derramar una gota.", "step_slowly_no_spill")
    put("take a rough leaf and put it in the brown ring", "C", fondo_prado() + fl("Fallen leaf", 26, 30, 38)
        + frecha((66, 46), (88, 46), BARRO, 3) + [E(114, 52, 22, 14, None, BARRO, 5)],
        "Hoja entrando en el aro marrón del suelo.", "rough_leaf_brown_ring")
    put("take the smock, turn around and give it to noa", "C", fondo_sala() + fl("Coat", 26, 22, 46)
        + frecha((76, 44), (98, 44), VERDE_OSCURO, 3)
        + nino((118, 26), (118, 38), (118, 58), [[(102, 46)], [(132, 48)]], [[(112, 84)], [(124, 84)]], camisa=(MORADO, TINTA), mira=-1),
        "Babi/bata pasando tras darse la vuelta a su compañera.", "take_smock_give_noa")
    put("tap-tap", "C", fondo_sala() + fl("Drum", 42, 24, 54) + [
        L("M30 22 L46 38", TIERRA, 4),
        L("M114 22 L98 38", TIERRA, 4),
    ], "Dos golpecitos suaves con baquetas sobre superficie.")
    put("the brush is between the cup and the paper", "C", fondo_mesa() + fl("Teacup without handle", 18, 34, 36)
        + fl("Paintbrush", 62, 26, 38) + fl("Page facing up", 106, 26, 40),
        "Pincel colocado justo en medio de la taza y la hoja.", "brush_between_cup_paper")
    put("turn left", "C", fondo_sala() + nino((102, 28), (102, 40), (102, 60), [[(88, 48)], [(116, 48)]], [[(96, 86)], [(108, 86)]], mira=-1)
        + [L("M74 28 Q44 28 40 54", AZUL_OSCURO, 4), F("M40 54 L32 42 L48 44 Z", AZUL_OSCURO)],
        "Flecha curva girando hacia la izquierda.")
    put("turn left and step over the rope", "C", fondo_prado() + [
        L("M74 22 Q44 22 40 42", AZUL_OSCURO, 3.5), F("M40 42 L34 32 L46 34 Z", AZUL_OSCURO),
        L("M40 76 L136 76", TIERRA_CLARA, 4),
    ] + nino((96, 24), (96, 36), (96, 54), [[(82, 44)], [(110, 44)]], [[(82, 82)], [(112, 70)]], mira=-1),
        "Giro a la izquierda pasando por encima de la cuerda.", "turn_left_step_rope")
    put("under the stones! slither like a snake", "C", fondo_prado() + [
        R(38, 22, 84, 18, 6, GRIS, GRIS_OSCURO, 2.2),
    ] + fl("Snake", 52, 46, 54), "Serpiente deslizándose por debajo de la piedra.", "under_stones_slither")
    put("unwind", "C", fondo_noite() + fl("Crescent moon", 32, 16, 44) + fl("Sparkles", 92, 34, 40),
        "Relajarse y desconectar suavemente al final del día.")
    put("walk slowly and hold your friend's hand", "C", fondo_prado() + fl("Turtle", 16, 58, 28)
        + nino((66, 26), (66, 38), (66, 58), [[(52, 48)], [(88, 48)]], [[(60, 84)], [(72, 84)]])
        + nino((114, 26), (114, 38), (114, 58), [[(88, 48)], [(128, 48)]], [[(108, 84)], [(120, 84)]], camisa=(VERDE, VERDE_OSCURO)),
        "Dos amigos caminando despacio cogidos de la mano.", "walk_slowly_hold_hand")
    put("walk to the hook and hang up your coat", "C", fondo_sala() + nino((42, 28), (42, 40), (42, 60), [[(56, 48)], [(28, 52)]], [[(36, 86)], [(48, 86)]], mira=1)
        + [L("M90 22 L138 22", MADERA_OSCURA, 3), E(114, 22, 4, 4, TINTA)] + fl("Coat", 92, 26, 46),
        "Acercarse al perchero y colgar el abrigo.", "walk_hook_hang_coat")
    put("water the plants", "C", fondo_prado() + fl("Potted plant", 36, 32, 48) + fl("Potted plant", 86, 34, 46)
        + gotas([(56, 18), (68, 28), (104, 18), (116, 28)]), "Gotas de agua regando las macetas con plantas.")
    put("we have to hurry because the train is leaving in front of us", "C", fondo_prado() + fl("Train", 24, 26, 54)
        + frecha((82, 36), (116, 36), ROJO_OSCURO, 3.5) + nino((124, 30), (124, 42), (124, 62), [[(110, 48)], [(138, 46)]], [[(112, 84)], [(134, 84)]], mira=-1),
        "Niño corriendo deprisa al ver partir el tren delante.", "hurry_train_leaving")
    put("welcome aboard", "C", fondo_cielo() + fl("Airplane", 34, 22, 56) + fl("Waving hand", 98, 28, 44),
        "Bienvenida sonriente al subir a bordo del viaje.")
    put("where does the fox hide? point with your elbows", "C", fondo_prado() + fl("Fox", 28, 30, 48)
        + nino((106, 26), (106, 38), (106, 58), [[(86, 44), (94, 52)], [(126, 44), (118, 52)]], [[(100, 84)], [(112, 84)]]),
        "Zorro escondido y niño señalando con los codos.", "fox_hide_point_elbows")
    put("your turn: give the command to your friend", "C", fondo_sala() + nino((44, 26), (44, 38), (44, 58), [[(66, 34)], [(30, 48)]], [[(38, 84)], [(50, 84)]], mira=1)
        + frecha((68, 22), (98, 22), VERDE_OSCURO, 3)
        + nino((116, 26), (116, 38), (116, 58), [[(102, 48)], [(130, 48)]], [[(110, 84)], [(122, 84)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Turno para dar una indicación clara al compañero.", "your_turn_give_command")
    put("your turn: now you are the sculptor", "C", fondo_sala() + nino((46, 26), (46, 38), (46, 58), [[(74, 40)], [(32, 48)]], [[(40, 84)], [(52, 84)]], mira=1)
        + nino((108, 26), (108, 38), (108, 58), [[(90, 22)], [(126, 36)]], [[(102, 84)], [(114, 84)]], camisa=(GRIS, GRIS_OSCURO)),
        "Niño escultor dando postura de estatua a su amigo.", "your_turn_sculptor")

    # ── Frases de gramática (unidades 01-10, 40 frases) ───────────────────
    put("she explained that the colours mix", "C", fondo_mesa() + [
        E(34, 48, 16, 16, ROJO, ROJO_OSCURO, 2),
        E(56, 48, 16, 16, AMARILLO, AMARILLO_OSCURO, 2),
    ] + frecha((76, 48), (102, 48), TINTA, 3) + [E(122, 48, 18, 18, "#f97316", "#9a3412", 2)],
        "Rojo y amarillo mezclándose claramente en naranja.", "she_explained_colours_mix")
    put("you promised to spin it fast", "C", fondo_mesa() + [
        E(80, 48, 22, 22, MORADO, TINTA, 2.5),
        L("M46 28 Q80 8 114 28", ROJO_OSCURO, 3.5),
        F("M114 28 L104 20 L106 32 Z", ROJO_OSCURO),
    ], "Disco girando muy rápido sobre su centro.")
    put("i suggested painting three colours", "C", fondo_mesa() + fl("Paintbrush", 24, 24, 42) + [
        R(72, 26, 18, 46, 2, ROJO, ROJO_OSCURO, 2),
        R(96, 26, 18, 46, 2, AMARILLO, AMARILLO_OSCURO, 2),
        R(120, 26, 18, 46, 2, AZUL, AZUL_OSCURO, 2),
    ], "Pincel señalando tres franjas de pintura distintas.", "suggested_painting_3_colours")
    put("he admitted the circle was hard to spin", "C", fondo_sala() + [
        E(68, 48, 24, 24, AZUL, AZUL_OSCURO, 2.5),
        L("M52 20 Q68 12 84 20", GRIS_OSCURO, 2.5),
        R(106, 26, 28, 44, 4, GRIS, GRIS_OSCURO, 2),
    ], "Círculo pesado que cuesta hacer girar.")
    put("this time tomorrow, we will be using the torch", "C", fondo_noite() + fl("Spiral calendar", 24, 18, 46)
        + fl("Flashlight", 82, 22, 52), "Calendario de mañana junto a linterna iluminando.", "tomorrow_using_torch")
    put("by friday, the room will have turned red", "C", fondo_sala() + [
        R(22, 16, 116, 62, 4, "#fecaca", ROJO_OSCURO, 2.5),
    ] + fl("Tear-off calendar", 54, 22, 48), "Habitación teñida de rojo con calendario semanal.", "friday_room_turned_red")
    put("by bedtime, we will have seen every colour", "C", fondo_noite() + fl("Bed", 26, 36, 48) + fl("Rainbow", 82, 18, 54),
        "Cama de dormir junto a arcoíris completo de colores.", "bedtime_seen_every_colour")
    put("will you have tried blue by then", "C", fondo_mesa() + fl("Artist palette", 28, 22, 48) + [
        E(104, 44, 20, 20, AZUL, AZUL_OSCURO, 2.5),
        L("M128 24 Q134 16 140 22 Q142 28 134 32", TINTA, 2.5),
        E(134, 39, 2.5, 2.5, TINTA),
    ], "Paleta de pintura con bote azul y pregunta.", "tried_blue_by_then")
    put("i can blow harder, and so can you", "C", fondo_cielo() + nino((36, 30), (36, 42), (36, 60), [[(24, 48)], [(50, 48)]], [[(30, 86)], [(42, 86)]], mira=1)
        + [L("M58 34 L100 34", AZUL_OSCURO, 3.5)]
        + nino((124, 30), (124, 42), (124, 60), [[(110, 48)], [(138, 48)]], [[(118, 86)], [(130, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos niños soplando con igual fuerza.", "blow_harder_so_can_you")
    put("faster? yes, faster", "C", fondo_prado() + fl("Train", 24, 26, 48) + frecha((78, 40), (138, 40), ROJO_OSCURO, 4.5) + frecha((78, 56), (138, 56), ROJO_OSCURO, 3.5),
        "Tren acelerando cada vez más rápido.")
    put("however, the gift paper was the loudest", "C", fondo_sala() + fl("Wrapped gift", 32, 22, 52) + [
        L("M96 34 L124 22", ROJO_OSCURO, 4),
        L("M98 48 L132 48", ROJO_OSCURO, 4),
        L("M96 62 L124 74", ROJO_OSCURO, 4),
    ], "Papel de regalo haciendo muchísimo ruido al arrugarse.", "gift_paper_loudest")
    put("the newspaper is loud, whereas the tissue is soft", "C", fondo_mesa() + fl("Newspaper", 22, 22, 46)
        + [L("M72 34 L82 26", ROJO_OSCURO, 3), L("M72 52 L82 60", ROJO_OSCURO, 3)]
        + [R(94, 32, 42, 34, 4, BLANCO, AGUA_OSCURO, 2)], "Periódico ruidoso frente a pañuelo suave y silencioso.", "newspaper_loud_tissue_soft")
    put("the long straw sounds low, and the short one high", "C", fondo_mesa() + [
        R(28, 18, 12, 62, 3, AZUL, AZUL_OSCURO, 2),
        R(116, 46, 12, 34, 3, ROJO, ROJO_OSCURO, 2),
    ] + notas([(52, 64), (100, 22)]), "Pajita larga con nota grave abajo y corta con nota aguda arriba.", "long_straw_low_short_high")
    put("the paint had been drying all morning", "C", fondo_cielo() + fl("Sun", 18, 12, 34) + [
        R(52, 30, 56, 44, 3, BLANCO, GRIS_OSCURO, 2),
        E(80, 52, 18, 12, ROJO, ROJO_OSCURO, 1.8),
        L("M66 22 Q72 14 78 22", AGUA_OSCURO, 2),
        L("M86 22 Q92 14 98 22", AGUA_OSCURO, 2),
    ], "Cuadro recién pintado secándose toda la mañana al aire.", "paint_drying_all_morning")
    put("we had been painting before we folded it", "C", fondo_mesa() + fl("Artist palette", 20, 24, 44) + frecha((68, 46), (92, 46), AZUL_OSCURO, 3) + _avion_papel(98, 46, 1.1),
        "Primero pintar la hoja y luego doblarla en avión.", "painting_before_folded")
    put("had you been folding the paper long", "C", fondo_mesa() + fl("Page facing up", 26, 22, 46) + fl("Stopwatch", 82, 22, 44) + [
        L("M132 24 Q138 16 144 22 Q146 28 138 32", TINTA, 2.5),
        E(138, 39, 2.5, 2.5, TINTA),
    ], "Hoja doblándose y cronómetro preguntando cuánto tiempo.", "folding_paper_long")
    put("you had been looking for the same side", "C", fondo_mesa() + [
        R(32, 30, 32, 32, 3, AZUL, AZUL_OSCURO, 2),
        R(74, 30, 32, 32, 3, AZUL, AZUL_OSCURO, 2),
    ] + fl("Magnifying glass tilted left", 104, 32, 40), "Dos cuadrados idénticos encontrados con lupa.", "looking_same_side")
    put("blue, which is cold, makes green", "C", fondo_cielo() + [
        E(34, 48, 16, 16, AZUL, AZUL_OSCURO, 2),
    ] + copos_nieve([(34, 20)]) + frecha((56, 48), (94, 48), TINTA, 3) + [E(116, 48, 18, 18, VERDE, VERDE_OSCURO, 2)],
        "Color azul frío convirtiéndose en verde.", "blue_cold_makes_green")
    put("red, which is warm, mixes with yellow", "C", fondo_mesa() + [
        E(32, 48, 15, 15, ROJO, ROJO_OSCURO, 2),
        L("M52 48 L62 48", TINTA, 2.5), L("M57 43 L57 53", TINTA, 2.5),
        E(80, 48, 15, 15, AMARILLO, AMARILLO_OSCURO, 2),
    ] + frecha((98, 48), (114, 48), TINTA, 3) + [E(132, 48, 16, 16, "#f97316", "#9a3412", 2)],
        "Rojo cálido y amarillo dando naranja.", "red_warm_yellow")
    put("the rainbow, which we painted, is big", "C", fondo_cielo() + fl("Rainbow", 34, 10, 74) + fl("Paintbrush", 106, 42, 36),
        "Arcoíris grande recién pintado con pincel.", "rainbow_painted_big")
    put("orange, which we made, is new", "C", fondo_mesa() + [
        E(74, 46, 26, 26, "#f97316", "#9a3412", 2.5),
    ] + fl("Sparkles", 104, 16, 36), "Círculo naranja brillante recién creado.")
    put("if i were you, i would flash twice", "C", fondo_noite() + fl("Flashlight", 28, 22, 50) + [
        F("M88 30 L118 20 L118 40 Z", AMARILLO),
        F("M88 54 L118 44 L118 64 Z", AMARILLO),
    ], "Linterna haciendo dos destellos seguidos en la oscuridad.", "if_i_were_you_flash_twice")
    put("suppose you saw a light: what would you say", "C", fondo_noite() + fl("Light bulb", 36, 16, 52) + [
        L("M106 24 Q112 16 118 22 Q120 28 112 32", BLANCO, 3),
        E(112, 39, 3, 3, BLANCO),
    ], "Luz brillante inesperada en la oscuridad con interrogación.", "suppose_saw_light")
    put("it's time we turned the torch off", "C", fondo_noite() + fl("Flashlight", 46, 20, 54) + [
        L("M44 20 L102 74", ROJO_OSCURO, 4.5),
    ], "Linterna tachada indicando hora de apagarla.", "time_turned_torch_off")
    put("as if the light were a secret", "C", fondo_noite() + fl("Flashlight", 28, 30, 44) + [
        R(78, 26, 44, 46, 4, TIERRA, BARRO, 2.2),
        E(100, 48, 8, 8, AMARILLO),
    ], "Luz guardada en secreto dentro de una caja.")
    put("although we closed our eyes, we guessed", "C", fondo_sala() + [
        E(52, 46, 20, 20, PEL, PELB, 2),
        F("M32 44 C32 26 72 26 72 44 C64 36 40 36 32 44 Z", BARRO, TINTA, 1.5),
        L("M40 44 Q44 47 48 44", TINTA, 2.2), L("M56 44 Q60 47 64 44", TINTA, 2.2),
        L("M46 56 Q52 60 58 56", TINTA, 1.8),
    ] + fl("Red apple", 96, 28, 40), "Adivinando qué objeto es con los ojos cerrados.", "closed_eyes_guessed")
    put("despite the noise, we listened", "C", fondo_sala() + fl("Drum", 26, 30, 44) + fl("Ear", 86, 20, 52),
        "Oreja atenta escuchando a pesar del ruido de fondo.", "despite_noise_listened")
    put("the train starts slow, then fast, then stops", "C", fondo_prado() + fl("Train", 20, 26, 46)
        + frecha((70, 48), (94, 48), VERDE_OSCURO, 3) + frecha((70, 34), (104, 34), ROJO_OSCURO, 4) + fl("Stop sign", 106, 24, 40),
        "Tren cambiando de despacio a rápido y parando.", "train_slow_fast_stops")
    put("having folded the plane, we threw it", "C", fondo_cielo() + _avion_papel(36, 36, 1.3) + frecha((90, 44), (138, 32), AZUL_OSCURO, 4),
        "Avión de papel doblado volando lanzado al aire.", "folded_plane_threw_it")
    put("thrown gently, it flew far", "C", fondo_cielo() + _avion_papel(26, 42, 1.1) + [L("M66 44 Q96 22 134 30", AGUA_OSCURO, 3)],
        "Avión planeando lejos con suavidad por el cielo.")
    put("changed a little, the plane flew further", "C", fondo_cielo() + _avion_papel(22, 40, 1.1) + frecha((66, 44), (138, 44), VERDE_OSCURO, 4),
        "Avión ajustado volando aún más lejos.", "changed_plane_flew_further")
    put("counting the steps, we measured it", "C", fondo_sala() + fl("Footprints", 30, 24, 48) + [
        L("M24 78 L136 78", ROJO_OSCURO, 3),
        L("M24 72 L24 84", ROJO_OSCURO, 3),
        L("M80 72 L80 84", ROJO_OSCURO, 3),
        L("M136 72 L136 84", ROJO_OSCURO, 3),
    ], "Huellas midiendo la distancia en pasos.", "counting_steps_measured")
    put("only on the map can you find it", "C", fondo_mesa() + fl("World map", 34, 16, 68) + fl("Star", 64, 38, 28),
        "Estrella del tesoro marcada únicamente en el mapa.", "only_on_the_map")
    put("never have we hidden the treasure so well", "C", fondo_prado() + fl("Package", 46, 24, 54) + [E(74, 48, 12, 12, AMARILLO, AMARILLO_OSCURO, 2)],
        "Caja del tesoro dorada muy bien escondida.", "never_hidden_treasure")
    put("not once did you lose the map", "C", fondo_mesa() + fl("World map", 36, 18, 62) + fl("Thumbs up", 102, 28, 40),
        "Mapa bien cuidado sin haberse perdido ni una vez.", "not_once_lose_map")
    put("rarely is a treasure so close", "C", fondo_prado() + fl("Star", 36, 24, 44) + frecha((84, 46), (108, 46), VERDE_OSCURO, 3.5) + fl("Compass", 110, 32, 34),
        "Brújula muy cerquita del tesoro dorado.", "rarely_treasure_close")
    put("what we need is water", "C", fondo_mesa() + _vaso(56, 20, 48, 56, 0.78) + gotas([(32, 32), (124, 32)]),
        "Vaso de agua limpia que se necesita.")
    put("what matters is the coat", "C", fondo_cielo() + fl("Coat", 46, 16, 66) + copos_nieve([(26, 24), (130, 28)]),
        "Abrigo cálido como pieza más importante contra el frío.")
    put("it was you who packed it", "C", fondo_sala() + nino((46, 28), (46, 40), (46, 60), [[(66, 44)], [(32, 52)]], [[(40, 86)], [(52, 86)]], mira=1)
        + fl("Luggage", 84, 24, 54), "Niño preparando y cerrando su propia maleta.")
    put("it's the books that make it heavy", "C", fondo_mesa() + fl("Backpack", 30, 26, 48)
        + fl("Blue book", 86, 16, 36) + fl("Green book", 92, 38, 36) + frecha((132, 22), (132, 72), ROJO_OSCURO, 4),
        "Mochila pesando mucho por los libros dentro.", "books_make_it_heavy")

    return out


def main() -> int:
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas: dict[str, dict] = mapa["pezas"]

    escenas = {k.strip(" .!?"): v for k, v in _escenas_5_6().items()}

    counts = {"U": 0, "R": 0, "C": 0, "D": 0}
    ya_cubiertas = 0

    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    c56 = lec["cursos"]["curso_5_6"]
    claves_56: dict[str, str] = {}
    for u in c56["unidades"]:
        for l in u["leccions"]:
            for campo in ("xaSabe", "novas", "repasa"):
                for p in l.get(campo) or []:
                    en = p.get("en", "")
                    k = en.lower().strip(" .!?")
                    if k and k not in claves_56:
                        claves_56[k] = en
            f = l.get("fraseGramatica")
            if f:
                en = f.get("en", "")
                k = en.lower().strip(" .!?")
                if k and k not in claves_56:
                    claves_56[k] = en

    faltan: list[str] = []
    for k, en in sorted(claves_56.items()):
        if k in pezas and k not in FLUENT_DIRECTOS and k not in PROPIAS_REUTILIZADAS and k not in escenas:
            ya_cubiertas += 1
            continue
        if k in FLUENT_DIRECTOS:
            slug, nombre, cat, porque = FLUENT_DIRECTOS[k]
            escribir_fluent_directo(pezas, k, slug, nombre, cat, porque)
            counts[cat] += 1
        elif k in PROPIAS_REUTILIZADAS:
            slug, cat, porque = PROPIAS_REUTILIZADAS[k]
            escribir_reutilizada(pezas, k, slug, cat, porque)
            counts[cat] += 1
        elif k in escenas:
            slug, cd, formas, porque = escenas[k]
            escribir_cd(pezas, k, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=en)
            counts[cd] += 1
        else:
            faltan.append(k)

    if faltan:
        print(f"ERROR: faltan {len(faltan)} claves de 5-6: {faltan[:20]}")
        return 1

    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK gen_laminas_5_6: nuevas={counts} (sum={sum(counts.values())}), ya_cubiertas={ya_cubiertas}, total_curso={len(claves_56)}")
    print("Agora: python3 tools/gen_laminas_palabras.py && python3 tools/gen_leccions.py && python3 tools/gen_laminas_palabras.py --control")
    return 0


if __name__ == "__main__":
    sys.exit(main())
