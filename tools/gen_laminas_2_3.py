#!/usr/bin/env python3
"""Generador de las 160 láminas nuevas de 2-3 años (P2.4, O-20261111-4).

Cubre todas las piezas restantes de `curso_2_3` en `leccions.json`
(168 claves únicas en total: 8 ya cubiertas en pasos anteriores + 160 nuevas)
hasta dejar `curso_2_3` a 0 piezas sin lámina.
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

SCRIPT_REF = "tools/gen_laminas_2_3.py"

# ── Banco directo Fluent Emoji Flat (MIT) ────────────────────────────────
FLUENT_DIRECTOS: dict[str, tuple[str, str, str, str]] = {
    "a red tomato": ("red_tomato", "Tomato", "U", "Tomate rojo brillante con hojita verde."),
    "flip-flops": ("flip_flops", "Thong sandal", "R", "Chancla ligera de verano."),
    "polar bear": ("polar_bear", "Polar bear", "U", "Oso polar blanco de perfil."),
    "sailing boat": ("sailing_boat", "Sailboat", "R", "Velero navegando con vela blanca."),
    "seal": ("seal", "Seal", "U", "Foca simpática de perfil."),
    "tiger": ("tiger", "Tiger", "U", "Tigre rayado de cuerpo entero."),
}

# ── Reutilizadas propias Lúa (assets/brand/laminas/*.json) ──────────────
PROPIAS_REUTILIZADAS: dict[str, tuple[str, str]] = {
    "face mask": ("careta", "Careta colorida de disfraz del set propio."),
    "wellington boots": ("botas", "Botas de agua altas para la lluvia del set propio."),
}


def _escenas_2_3() -> dict[str, tuple[str, str, list[dict], str]]:
    m: dict[str, tuple[str, str, list[dict], str]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, slug: str | None = None) -> None:
        m[k] = (slug or slug_de(k), cd, formas, porque)

    # ── Palabras / acciones de curso_2_3 ──────────────────────────────────
    put("animal parade", "C", fondo_prado() + fl("Tiger", 16, 36, 38) + fl("Dog", 58, 36, 38) + fl("Cat", 98, 36, 38) + frecha((132, 24), (150, 24), VERDE_OSCURO, 3),
        "Animales caminando en fila desfilando uno detrás de otro.")
    put("animal tail", "D", fondo_prado() + [
        E(62, 54, 24, 16, "#fb923c", "#c2410c", 2.2),
        F("M84 54 Q112 40 120 20 Q128 32 108 58 Q96 66 84 54 Z", "#ea580c", "#9a3412", 2.2),
    ] + frecha((134, 16), (118, 28), ROJO_OSCURO, 3), "Cola larga de disfraz de animal señalada con flecha.")
    put("beach ball game", "C", fondo_mar() + nino((36, 26), (36, 38), (36, 56), [[(54, 42)], [(22, 46)]], [[(30, 74)], [(42, 74)]], mira=1) + [
        E(84, 30, 14, 14, BLANCO, TINTA, 2),
        F("M84 30 L84 16 C92 16 98 22 98 30 Z", ROJO, TINTA, 1.2),
        F("M84 30 L70 30 C70 22 76 16 84 16 Z", AZUL, TINTA, 1.2),
    ] + nino((124, 26), (124, 38), (124, 56), [[(106, 42)], [(138, 46)]], [[(118, 74)], [(130, 74)]], camisa=(VERDE, VERDE_OSCURO), mira=-1),
        "Dos niños pasándose la pelota de playa por el aire.")
    put("bend knees", "C", fondo_prado() + nino((80, 32), (80, 44), (80, 62), [[(64, 50)], [(96, 50)]], [[(68, 74), (74, 88)], [(92, 74), (86, 88)]]) + frecha((116, 44), (116, 68), AZUL_OSCURO, 3.5),
        "Niño flexionando ambas rodillas hacia abajo.")
    put("big heavy bear! stomp", "C", fondo_prado() + fl("Bear", 38, 18, 62) + frecha((114, 24), (114, 72), BARRO, 4.5) + [L("M34 80 L54 80", BARRO, 3), L("M76 80 L96 80", BARRO, 3)],
        "Oso grande pisando fuerte con fuerza sobre el suelo.", "big_heavy_bear_stomp")
    put("bloom! big bright flowers", "C", fondo_prado() + fl("Sunflower", 20, 18, 46) + fl("Hibiscus", 66, 20, 46) + fl("Tulip", 108, 22, 42),
        "Flores grandes y vistosas abriéndose al sol.")
    put("blow away", "C", fondo_prado() + fl("Wind face", 20, 22, 46) + fl("Maple leaf", 96, 26, 34) + frecha((72, 44), (138, 44), AZUL_OSCURO, 3.5),
        "Viento soplando con fuerza y llevándose una hoja volando.")
    put("blow seeds", "C", fondo_prado() + nino((38, 34), (38, 46), (38, 66), [[(56, 50)], [(24, 54)]], [[(32, 86)], [(44, 86)]], mira=1) + [
        L("M52 34 L82 40", AZUL_OSCURO, 2.5),
        E(94, 30, 4, 4, BLANCO, GRIS_OSCURO, 1.5),
        E(112, 22, 4, 4, BLANCO, GRIS_OSCURO, 1.5),
        E(126, 36, 4, 4, BLANCO, GRIS_OSCURO, 1.5),
    ], "Niño soplando semillas blancas ligeras por el aire.")
    put("brush up and down", "C", fondo_sala() + fl("Toothbrush", 36, 26, 56) + frecha((110, 62), (110, 22), VERDE_OSCURO, 3.5) + frecha((128, 22), (128, 62), AZUL_OSCURO, 3.5),
        "Cepillo moviéndose arriba y abajo para limpiar.")
    put("build a nest", "C", fondo_prado() + fl("Empty nest", 36, 34, 56) + fl("Bird", 94, 18, 42),
        "Pajarito construyendo su nido de ramitas.")
    put("calm sea", "D", fondo_mar() + fl("Sun", 18, 10, 28) + [L("M20 72 L60 72", BLANCO, 2), L("M84 80 L132 80", BLANCO, 2)],
        "Mar tranquilo con agua en calma bajo el sol.")
    put("carnival freeze", "C", fondo_sala() + fl("Party popper", 16, 18, 38) + nino((80, 28), (80, 40), (80, 60), [[(60, 28)], [(100, 28)]], [[(72, 86)], [(88, 86)]]) + fl("Stop sign", 114, 18, 34),
        "Fiesta de carnaval con niño quieto como estatua ante señal de parar.")
    put("coat on the peg", "C", fondo_sala() + [R(26, 18, 108, 14, 4, MADERA, MADERA_OSCURA, 2), E(80, 25, 4, 4, TINTA), L("M80 29 L80 38", TINTA, 3)] + fl("Coat", 52, 34, 56),
        "Abrigo colgado en su percha de madera.")
    put("colourful plate", "D", fondo_mesa() + [
        E(80, 48, 30, 30, BLANCO, GRIS_OSCURO, 2.5),
        E(68, 42, 8, 8, ROJO, ROJO_OSCURO, 1.5),
        E(92, 42, 8, 8, AMARILLO, AMARILLO_OSCURO, 1.5),
        E(80, 60, 8, 8, VERDE, VERDE_OSCURO, 1.5),
    ], "Plato lleno de alimentos coloridos rojo, amarillo y verde.")
    put("come out of the egg", "C", fondo_prado() + fl("Hatching chick", 46, 18, 66),
        "Pollito saliendo al romperse el cascarón del huevo.")
    put("crack open", "C", fondo_mesa() + fl("Egg", 36, 26, 46) + [L("M56 36 L64 46 L54 54 L62 62", TINTA, 2.5)] + frecha((104, 48), (134, 34), ROJO_OSCURO, 3) + frecha((104, 52), (134, 66), ROJO_OSCURO, 3),
        "Cáscara agrietándose para abrirse hacia los dos lados.")
    put("crispy", "C", fondo_mesa() + fl("Cookie", 42, 22, 54) + [E(104, 38, 3, 3, TIERRA), E(114, 52, 3.5, 3.5, TIERRA), E(102, 62, 2.5, 2.5, TIERRA)],
        "Galleta crujiente saltando miguitas secas al partirse.")
    put("cross the road", "D", fondo_prado() + [
        R(0, 56, 160, 44, 0, GRIS_OSCURO),
        R(46, 62, 16, 32, 2, BLANCO),
        R(72, 62, 16, 32, 2, BLANCO),
        R(98, 62, 16, 32, 2, BLANCO),
    ] + nino((40, 24), (40, 36), (40, 52), [[(28, 46)], [(52, 46)]], [[(34, 72)], [(46, 72)]]) + frecha((66, 42), (128, 42), VERDE_OSCURO, 3.5),
        "Niño cruzando por el paso de cebra hacia el otro lado.")
    put("crunch your leaves", "C", fondo_prado() + nino((52, 24), (52, 36), (52, 54), [[(40, 46)], [(64, 46)]], [[(46, 74)], [(58, 74)]]) + fl("Fallen leaf", 38, 64, 32) + fl("Ear", 104, 24, 38),
        "Niño pisando hojas secas con sonido crujiente junto al oído.")
    put("crunchy leaves", "C", fondo_prado() + fl("Fallen leaf", 24, 36, 42) + fl("Maple leaf", 66, 26, 44) + fl("Ear", 112, 24, 34),
        "Hojas secas y quebradizas haciendo ruido al crujir.")
    put("curl up on the sofa", "C", fondo_sala() + fl("Couch and lamp", 30, 14, 72) + fl("Cat", 98, 44, 38),
        "Gato acurrucado cómodamente sobre el sofá.")
    put("dance and freeze", "C", fondo_sala() + nino((40, 28), (40, 40), (40, 60), [[(24, 26)], [(56, 26)]], [[(32, 84)], [(48, 84)]]) + notas([(64, 22)]) + nino((116, 28), (116, 40), (116, 60), [[(102, 52)], [(130, 52)]], [[(112, 86)], [(120, 86)]], camisa=(AZUL, AZUL_OSCURO)),
        "Pasar de bailar con música a quedarse completamente quieto como estatua.")
    put("dash", "C", fondo_prado() + nino((54, 30), (50, 42), (44, 60), [[(68, 40)], [(32, 48)]], [[(64, 74), (74, 84)], [(28, 74), (18, 84)]], mira=1) + frecha((92, 46), (144, 46), ROJO, 4.5) + [L("M14 38 L28 38", AZUL_OSCURO, 2.5), L("M10 52 L24 52", AZUL_OSCURO, 2.5)],
        "Niño saliendo disparado corriendo muy rápido hacia delante.")
    put("driftwood", "C", [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 62, 160, 38, 0, "#fde68a"), R(0, 48, 160, 18, 0, AGUA)] + fl("Wood", 46, 42, 64),
        "Tronco de madera flotando y llegando a la arena de la playa.")
    put("dry your toes", "C", fondo_sala() + pano(26, 22, 48, 46, "#bae6fd", AGUA_OSCURO) + [
        E(104, 60, 14, 20, PEL, PELB, 2),
        E(90, 38, 4, 5, PEL, PELB, 1.5),
        E(99, 34, 3.8, 4.5, PEL, PELB, 1.5),
        E(108, 34, 3.5, 4.5, PEL, PELB, 1.5),
        E(116, 37, 3.2, 4, PEL, PELB, 1.5),
        E(122, 41, 3, 3.5, PEL, PELB, 1.5),
    ], "Toalla secando los dedos del pie después del baño.")
    put("everybody sit down", "C", fondo_sala() + nino((46, 38), (46, 50), (46, 68), [[(34, 58)], [(58, 58)]], [[(36, 72), (34, 86)], [(56, 72), (58, 86)]]) + nino((94, 38), (94, 50), (94, 68), [[(82, 58)], [(106, 58)]], [[(84, 72), (82, 86)], [(104, 72), (106, 86)]], camisa=(VERDE, VERDE_OSCURO)) + frecha((134, 26), (134, 72), AZUL_OSCURO, 3.5),
        "Todos los niños sentándose abajo en círculo.")
    put("everybody stand up", "C", fondo_sala() + nino((46, 26), (46, 38), (46, 58), [[(34, 48)], [(58, 48)]], [[(40, 86)], [(52, 86)]]) + nino((94, 26), (94, 38), (94, 58), [[(82, 48)], [(106, 48)]], [[(88, 86)], [(100, 86)]], camisa=(VERDE, VERDE_OSCURO)) + frecha((134, 72), (134, 24), VERDE_OSCURO, 3.5),
        "Todos los niños poniéndose de pie hacia arriba.")
    put("find a red circle! touch it with your foot", "C", fondo_sala() + [
        E(46, 66, 22, 10, ROJO, ROJO_OSCURO, 2.5),
    ] + nino((100, 24), (100, 36), (100, 56), [[(86, 46)], [(114, 46)]], [[(58, 66)], [(106, 84)]]),
        "Círculo rojo en el suelo y niño tocándolo con el pie.")
    put("find the shape", "C", fondo_mesa() + [
        E(34, 44, 14, 14, ROJO, ROJO_OSCURO, 2),
        R(64, 30, 26, 26, 2, AZUL, AZUL_OSCURO, 2),
        P([(102, 56), (118, 28), (134, 56)], VERDE, VERDE_OSCURO, 2),
    ] + fl("Magnifying glass tilted right", 76, 42, 42), "Lupa buscando entre círculo, cuadrado y triángulo.")
    put("flap wings", "C", fondo_prado() + fl("Bird", 48, 22, 56) + frecha((30, 54), (30, 22), VERDE_OSCURO, 3) + frecha((128, 22), (128, 54), VERDE_OSCURO, 3),
        "Pájaro batiendo sus alas arriba y abajo.")
    put("fluffy seeds", "D", fondo_prado() + [
        L("M80 80 L80 42", VERDE_OSCURO, 3),
        E(80, 42, 14, 14, BLANCO, GRIS_OSCURO, 1.5),
        E(68, 34, 9, 9, BLANCO, GRIS_OSCURO, 1.2),
        E(92, 34, 9, 9, BLANCO, GRIS_OSCURO, 1.2),
        E(112, 24, 5, 5, BLANCO, GRIS_OSCURO, 1.2),
        E(126, 18, 4, 4, BLANCO, GRIS_OSCURO, 1.2),
    ], "Semillas blancas algodonosas como diente de león flotando.")
    put("fly like a bird", "C", fondo_prado() + nino((52, 28), (52, 40), (52, 60), [[(20, 32)], [(84, 32)]], [[(46, 84)], [(58, 84)]]) + fl("Bird", 104, 16, 40),
        "Niño abriendo los brazos como alas imitando al pájaro volando.")
    put("freeze", "C", fondo_cielo("#e0f2fe") + nino((72, 26), (72, 38), (72, 58), [[(56, 36)], [(88, 36)]], [[(66, 84)], [(78, 84)]]) + copos_nieve([(28, 28), (132, 28)]) + fl("Stop sign", 114, 52, 32),
        "Niño completamente quieto en postura de estatua.")
    put("friends in a circle", "C", fondo_prado() + nino((42, 28), (42, 40), (42, 58), [[(56, 44)], [(28, 48)]], [[(36, 82)], [(48, 82)]]) + nino((80, 24), (80, 36), (80, 54), [[(64, 44)], [(96, 44)]], [[(74, 78)], [(86, 78)]], camisa=(VERDE, VERDE_OSCURO)) + nino((118, 28), (118, 40), (118, 58), [[(104, 44)], [(132, 48)]], [[(112, 82)], [(124, 82)]], camisa=(AMARILLO, AMARILLO_OSCURO)),
        "Amigos cogidos de la mano formando un corro alegre.")
    put("from loud to quiet", "D", fondo_sala() + [
        R(20, 22, 14, 48, 3, ROJO, ROJO_OSCURO, 2),
        R(42, 32, 12, 30, 3, AMARILLO, AMARILLO_OSCURO, 2),
        R(62, 42, 10, 14, 3, VERDE, VERDE_OSCURO, 2),
    ] + frecha((80, 46), (124, 46), AZUL_OSCURO, 3) + [E(136, 46, 5, 5, AZUL, AZUL_OSCURO, 1.5)],
        "Barras sonoras pasando de volumen muy fuerte a muy suave.")
    put("fruity", "C", fondo_mesa() + fl("Strawberry", 24, 26, 40) + fl("Red apple", 60, 22, 42) + fl("Banana", 98, 26, 40),
        "Conjunto variado de frutas frescas y dulces.")
    put("gentle waves", "C", fondo_mar() + fl("Water wave", 48, 36, 52) + [L("M20 74 Q40 68 60 74 Q80 80 100 74", BLANCO, 2)],
        "Olas pequeñas y suaves balanceándose despacio.")
    put("get on", "C", fondo_prado() + fl("Bus", 24, 22, 58) + nino((114, 34), (114, 46), (114, 66), [[(100, 52)], [(126, 54)]], [[(108, 86)], [(120, 86)]]) + frecha((104, 24), (72, 32), VERDE_OSCURO, 3.5),
        "Niño subiendo hacia el vehículo o columpio.")
    put("get warm", "C", fondo_sala() + fl("Fire", 24, 24, 48) + nino((106, 30), (106, 42), (106, 62), [[(86, 44)], [(120, 52)]], [[(100, 84)], [(112, 84)]], mira=-1),
        "Niño acercando las manos al fuego cálido para entrar en calor.")
    put("giant waves", "C", fondo_mar() + fl("Water wave", 18, 10, 74) + frecha((116, 68), (116, 18), MAR_PROF, 4.5),
        "Ola enorme levantándose muy alta en el mar.")
    put("halt", "C", fondo_prado() + fl("Stop sign", 26, 16, 54) + nino((110, 28), (110, 40), (110, 60), [[(96, 50)], [(124, 50)]], [[(106, 86)], [(114, 86)]]),
        "Señal roja de alto con niño detenido en seco.")
    put("hang out", "C", fondo_prado() + [
        L("M16 28 L144 28", TINTA, 2.5),
        R(32, 28, 34, 36, 3, "#bae6fd", AGUA_OSCURO, 2),
        R(88, 28, 38, 32, 3, "#fca5a5", ROJO_OSCURO, 2),
    ] + fl("Sun", 122, 6, 26), "Ropa y toallas tendidas en el tendedero al sol.")
    put("head, shoulders, knees and toes", "C", fondo_prado() + nino((72, 20), (72, 32), (72, 54), [[(56, 38)], [(88, 38)]], [[(66, 84)], [(78, 84)]])
        + frecha((34, 20), (58, 20), ROJO_OSCURO, 2.5)
        + frecha((34, 40), (56, 40), AZUL_OSCURO, 2.5)
        + frecha((34, 68), (62, 68), VERDE_OSCURO, 2.5)
        + frecha((34, 86), (62, 86), MORADO, 2.5),
        "Esquema corporal señalando cabeza, hombros, rodillas y pies.")
    put("healthy", "C", fondo_mesa() + fl("Broccoli", 24, 26, 42) + fl("Red apple", 64, 24, 42) + fl("Red heart", 104, 26, 38),
        "Verdura y fruta sana acompañadas de corazón saludable.")
    put("hello", "C", fondo_prado() + fl("Waving hand", 46, 16, 66),
        "Mano abierta saludando con un ¡hola!.")
    put("hello, friend", "C", fondo_prado() + nino((46, 28), (46, 40), (46, 60), [[(30, 32)], [(60, 50)]], [[(40, 84)], [(52, 84)]]) + nino((108, 28), (108, 40), (108, 60), [[(94, 50)], [(124, 32)]], [[(102, 84)], [(114, 84)]], camisa=(AZUL, AZUL_OSCURO)),
        "Dos amigos levantando la mano para saludarse.")
    put("hold hands", "C", fondo_prado() + nino((48, 28), (48, 40), (48, 60), [[(34, 52)], [(80, 50)]], [[(42, 84)], [(54, 84)]]) + nino((112, 28), (112, 40), (112, 60), [[(80, 50)], [(126, 52)]], [[(106, 84)], [(118, 84)]], camisa=(VERDE, VERDE_OSCURO)) + [E(80, 50, 4, 4, ROJO)],
        "Dos niños caminando juntos agarrados de la mano.")
    put("hold my hand", "C", fondo_sala() + fl("Handshake", 44, 16, 70),
        "Manos estrechándose juntas para dar la mano.")
    put("hollow", "D", fondo_mesa() + [
        E(80, 48, 30, 22, MADERA, MADERA_OSCURA, 3),
        E(80, 48, 18, 12, "#1e293b", TINTA, 2),
    ], "Tubo o cilindro hueco por dentro dejando ver el espacio vacío.")
    put("invite", "C", fondo_prado() + nino((48, 28), (48, 40), (48, 60), [[(34, 50)], [(72, 44)]], [[(42, 84)], [(54, 84)]], mira=1) + frecha((126, 44), (84, 44), VERDE_OSCURO, 3.5),
        "Niño abriendo la mano con gesto amable para invitar a acercarse.")
    put("jump in", "C", fondo_prado() + [E(84, 72, 42, 12, AGUA, AGUA_OSCURO, 2.5)] + nino((84, 18), (84, 30), (84, 46), [[(68, 26)], [(100, 26)]], [[(76, 56)], [(92, 56)]]) + frecha((30, 22), (56, 60), VERDE_OSCURO, 3.5),
        "Niño saltando desde fuera directo dentro del charco.")
    put("jungle", "C", fondo_prado() + fl("Palm tree", 18, 12, 58) + fl("Tiger", 86, 30, 54),
        "Selva tropical frondosa con palmera y tigre.")
    put("keep warm", "C", fondo_sala() + fl("Scarf", 24, 24, 48) + fl("Teacup without handle", 86, 26, 48),
        "Bufanda abrigada y bebida humeante para mantenerse calentito.")
    put("kick a leaf", "C", fondo_prado() + nino((46, 26), (46, 38), (46, 58), [[(34, 48)], [(58, 48)]], [[(40, 82)], [(68, 72)]], mira=1) + fl("Maple leaf", 78, 54, 34) + frecha((104, 46), (138, 30), ROJO_OSCURO, 3.5),
        "Niño lanzando con el pie una hoja seca por el aire.")
    put("lie on the grass", "C", fondo_prado() + [
        R(38, 64, 54, 14, 6, VERDE, VERDE_OSCURO, 2),
        E(104, 68, 10, 10, PEL, PELB, 2),
        L("M38 66 L26 62", AZUL_OSCURO, 4),
    ] + fl("Sun", 18, 10, 28), "Niño tumbado cómodamente mirando al cielo sobre la hierba.")
    put("lift up", "C", fondo_sala() + fl("Package", 52, 42, 44) + frecha((118, 74), (118, 20), VERDE_OSCURO, 4.5),
        "Objeto pesado levantado hacia lo alto.")
    put("little fish swimming under the sea", "C", fondo_mar() + fl("Fish", 22, 46, 38) + fl("Tropical fish", 72, 42, 38) + fl("Tropical fish", 112, 58, 32),
        "Varios pececitos nadando juntos bajo las olas del mar.", "little_fish_under_sea")
    put("loud bells! shake fast", "C", fondo_sala() + fl("Bell", 36, 18, 52) + fl("Bell", 86, 22, 44) + [L("M24 22 L16 38", ROJO, 3), L("M138 22 L146 38", ROJO, 3)],
        "Campanas agitándose muy rápido haciendo mucho ruido.", "loud_bells_shake_fast")
    put("munch", "C", fondo_mesa() + nino((106, 26), (106, 38), (106, 60), [[(76, 36)], [(120, 50)]], [[(100, 82)], [(112, 82)]], mira=-1) + fl("Red apple", 54, 20, 32),
        "Niño dando un bocado grande a una manzana roja.")
    put("pass the ball", "C", fondo_prado() + nino((30, 30), (30, 42), (30, 62), [[(48, 46)], [(18, 54)]], [[(24, 84)], [(36, 84)]], mira=1) + fl("Soccer ball", 64, 30, 32) + frecha((66, 20), (102, 20), VERDE_OSCURO, 3) + nino((130, 30), (130, 42), (130, 62), [[(112, 46)], [(142, 54)]], [[(124, 84)], [(136, 84)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Pasando la pelota de un niño a otro con las manos.")
    put("peg up", "C", fondo_prado() + [
        L("M20 26 L140 26", TINTA, 2.5),
        R(50, 26, 60, 46, 4, "#fde68a", "#d97706", 2),
        R(56, 14, 8, 18, 2, ROJO, ROJO_OSCURO, 1.8),
        R(96, 14, 8, 18, 2, AZUL, AZUL_OSCURO, 1.8),
    ], "Pinzas sujetando un dibujo o prenda en la cuerda.")
    put("pick up toys", "C", fondo_sala() + fl("Basket", 24, 40, 46) + fl("Teddy bear", 86, 14, 36) + frecha((104, 54), (62, 48), VERDE_OSCURO, 3.5),
        "Recogiendo juguetes del suelo para guardarlos en su cesta.")
    put("pointed", "D", fondo_mesa() + [
        P([(56, 76), (80, 18), (104, 76)], AMARILLO, AMARILLO_OSCURO, 2.5),
        P([(73, 34), (80, 18), (87, 34)], ROJO_OSCURO),
    ] + frecha((122, 18), (92, 20), ROJO_OSCURO, 3), "Forma triangular acabada en punta afilada arriba.")
    put("pour carefully", "C", fondo_mesa() + [
        P([(24, 24), (58, 24), (52, 56), (30, 56)], AZUL, AZUL_OSCURO, 2),
        P([(86, 52), (124, 52), (118, 84), (92, 84)], BLANCO, AZUL_OSCURO, 2.2),
        F("M56 32 Q80 34 98 56", AGUA, AGUA_OSCURO, 2.5),
    ], "Vertiendo un chorro fino de agua despacio dentro del vaso.")
    put("pour down", "C", fondo_cielo("#cbd5e1") + fl("Cloud with rain", 42, 6, 54) + gotas([(48, 62), (64, 72), (80, 60), (96, 72), (112, 62), (56, 84), (88, 84)]),
        "Lluvia intensa cayendo fuerte sin parar desde la nube.")
    put("pull on", "C", fondo_sala() + fl("Socks", 44, 22, 54) + frecha((116, 70), (116, 22), AZUL_OSCURO, 4),
        "Tirando de un calcetín o bota hacia arriba para ponérselo.")
    put("pump the soap", "C", fondo_sala() + fl("Soap", 46, 28, 52) + frecha((72, 6), (72, 26), ROJO_OSCURO, 3.5) + pompas([(114, 34, 7), (128, 48, 5)]),
        "Apretando hacia abajo para que salga espuma de jabón.")
    put("put away", "C", fondo_sala() + fl("Package", 30, 36, 52) + fl("Ballot box with ballot", 86, 16, 48) if False else fondo_sala() + fl("Package", 32, 34, 52) + fl("Teddy bear", 88, 12, 40) + frecha((100, 52), (64, 52), VERDE_OSCURO, 3.5),
        "Guardando las cosas ordenadas dentro de su caja.")
    put("put on your coat", "C", fondo_sala() + fl("Coat", 24, 18, 52) + nino((106, 30), (106, 42), (106, 62), [[(90, 48)], [(122, 48)]], [[(100, 86)], [(112, 86)]]) + frecha((76, 42), (96, 42), AZUL_OSCURO, 3),
        "Abrigo poniéndoselo encima para salir fuera.")
    put("quiet bells... sleep", "C", fondo_noite() + fl("Bell", 36, 28, 46) + fl("Sleeping face", 94, 22, 46),
        "Campanillas en silencio mientras todo duerme tranquilo.")
    put("red card", "D", fondo_mesa() + [
        R(50, 14, 60, 72, 6, ROJO, ROJO_OSCURO, 3),
    ], "Tarjeta grande completamente de color rojo.")
    put("roll up", "D", fondo_mesa() + [
        E(80, 48, 28, 16, "#fde68a", "#d97706", 2.5),
        E(80, 48, 18, 10, "#f59e0b", "#d97706", 2),
        E(80, 48, 8, 4, "#b45309"),
    ] + frecha((118, 66), (118, 28), AZUL_OSCURO, 3), "Manta o papel enrollado sobre sí mismo.")
    put("round and flat", "D", fondo_mesa() + [
        E(80, 56, 42, 12, "#fde68a", "#d97706", 2.5),
        E(80, 52, 40, 10, "#fcd34d", "#d97706", 1.8),
    ], "Disco completamente redondo y muy plano como una tortita.")
    put("sandpit", "D", fondo_prado() + [
        R(24, 42, 112, 40, 4, MADERA, MADERA_OSCURA, 2.5),
        R(32, 48, 96, 28, 3, "#fde68a", "#d97706", 1.8),
        P([(66, 64), (92, 64), (86, 44), (72, 44)], ROJO, ROJO_OSCURO, 2),
    ], "Arenero de madera lleno de arena con cubo de playa.")
    put("sea glass", "D", fondo_mar() + [
        R(36, 66, 24, 14, 7, "#67e8f9", AGUA_OSCURO, 2),
        R(72, 64, 26, 15, 7, "#6ee7b7", VERDE_OSCURO, 2),
        R(106, 68, 22, 12, 6, "#bae6fd", AZUL_OSCURO, 2),
    ], "Cristales pulidos y redondeados por el agua en la orilla.")
    put("shake dry", "C", fondo_prado() + fl("Dog", 46, 26, 56) + gotas([(30, 34), (116, 30), (124, 52)]) + [L("M36 22 L28 34", AZUL_OSCURO, 2.5), L("M108 20 L118 30", AZUL_OSCURO, 2.5)],
        "Perro sacudiéndose con fuerza para soltar las gotas de agua.")
    put("shake your hands", "C", fondo_sala() + fl("Open hands", 46, 22, 56) + [L("M30 34 L22 46", MORADO, 3), L("M130 34 L138 46", MORADO, 3)],
        "Agitando ambas manos alegremente en el aire.")
    put("shh, baby's sleeping", "C", fondo_noite() + fl("Baby", 26, 34, 44) + fl("Crescent moon", 16, 10, 24) + [
        E(112, 46, 17, 17, PEL, PELB, 2),
        F("M95 44 C95 30 129 30 129 44 C122 38 102 38 95 44 Z", BARRO, TINTA, 1.5),
        E(106, 44, 2, 2.2, TINTA),
        E(118, 44, 2, 2.2, TINTA),
        E(112, 52, 2.5, 2.5, TINTA),
        R(110, 50, 4.5, 16, 2, "#fcd34d", PELB, 1.5),
    ], "Bebé dormido por la noche y gesto de pedir silencio suave.")
    put("shuffle", "C", fondo_sala() + nino((58, 28), (58, 40), (58, 60), [[(44, 50)], [(72, 50)]], [[(48, 86)], [(68, 86)]]) + frecha((84, 82), (132, 82), VERDE_OSCURO, 3.5),
        "Niño deslizando los pies bajitos por el suelo al caminar.")
    put("sip slowly", "C", fondo_mesa() + fl("Cup with straw", 32, 22, 50) + nino((104, 34), (104, 46), (104, 66), [[(88, 52)], [(118, 54)]], [[(98, 86)], [(110, 86)]], mira=-1),
        "Tomando un sorbito pequeño y tranquilo de la taza.")
    put("soak", "C", fondo_mar() + fl("Sponge", 50, 48, 48) + frecha((116, 22), (116, 62), AZUL_OSCURO, 3.5),
        "Esponja sumergida empapándose bien dentro del agua.")
    put("soap, rub, rinse", "C", fondo_sala() + fl("Soap", 18, 26, 38) + fl("Open hands", 60, 26, 40) + fl("Shower", 104, 16, 42),
        "Secuencia de jabón, frotar las manos y aclarar bajo el agua.")
    put("solid", "D", fondo_mesa() + [
        P([(50, 38), (94, 38), (110, 24), (66, 24)], "#64748b", TINTA, 2),
        R(50, 38, 44, 40, 2, "#475569", TINTA, 2),
        P([(94, 38), (110, 24), (110, 64), (94, 78)], "#334155", TINTA, 2),
    ], "Bloque compacto completamente macizo por dentro.")
    put("speak softly", "C", fondo_sala() + nino((46, 34), (46, 46), (46, 66), [[(34, 56)], [(58, 56)]], [[(40, 86)], [(52, 86)]], mira=1) + [
        L("M74 36 Q82 36 82 42", AZUL_OSCURO, 2),
        L("M88 32 Q98 32 98 42", AGUA_OSCURO, 1.5),
    ], "Hablando con voz muy bajita y ondas pequeñas.")
    put("speed up", "C", fondo_prado() + nino((48, 30), (44, 42), (38, 60), [[(62, 38)], [(26, 48)]], [[(60, 72), (70, 82)], [(22, 74), (14, 84)]], mira=1) + frecha((84, 44), (124, 44), ROJO, 4) + frecha((104, 62), (148, 62), ROJO, 4),
        "Acelerando el paso con doble flecha de velocidad.")
    put("spin around", "C", fondo_prado() + nino((80, 26), (80, 38), (80, 58), [[(62, 46)], [(98, 46)]], [[(74, 84)], [(86, 84)]]) + [L("M44 58 Q80 80 116 58", MORADO, 3)] + frecha((110, 62), (122, 54), MORADO, 3),
        "Niño girando sobre sí mismo dando una vuelta completa.")
    put("spread out", "C", fondo_mesa() + pano(46, 26, 68, 44, "#fde68a", "#d97706") + frecha((36, 48), (14, 48), AZUL_OSCURO, 3) + frecha((124, 48), (146, 48), AZUL_OSCURO, 3),
        "Extender y estirar bien hacia todos los lados.")
    put("squirt", "C", fondo_mesa() + fl("Lotion bottle", 24, 24, 46) + [L("M68 38 Q92 34 114 48", AGUA_OSCURO, 3.5)] + gotas([(118, 52), (128, 62)]),
        "Chorro saliendo a presión de un bote al apretarlo.")
    put("step forward", "C", fondo_prado() + nino((58, 28), (58, 40), (58, 60), [[(44, 50)], [(72, 50)]], [[(48, 84)], [(78, 84)]], mira=1) + frecha((88, 72), (132, 72), VERDE_OSCURO, 3.5),
        "Niño dando un paso claro hacia delante.")
    put("stomp around", "C", fondo_prado() + nino((72, 26), (72, 38), (72, 56), [[(56, 42)], [(88, 42)]], [[(62, 84)], [(84, 72)]]) + frecha((114, 44), (114, 82), BARRO, 4),
        "Niño dando pisadas fuertes levantando la rodilla.")
    put("stomp your boots in the puddles", "C", fondo_prado() + fl("Hiking boot", 50, 24, 48) + [E(76, 76, 36, 9, AGUA, AGUA_OSCURO, 2)] + gotas([(38, 54), (118, 54)]),
        "Botas pisando con fuerza sobre un charco de agua salpicando.", "stomp_boots_puddles")
    put("stroll", "C", fondo_prado() + nino((56, 28), (56, 40), (56, 60), [[(42, 50)], [(70, 50)]], [[(48, 84)], [(64, 84)]], mira=1) + fl("Deciduous tree", 104, 14, 52),
        "Niño paseando tranquilamente por el parque.")
    put("summer hat", "C", [R(0, 0, 160, 100, 0, "#fef9c3"), R(0, 68, 160, 32, 0, "#fde68a")] + fl("Womans hat", 44, 16, 64) + fl("Sun", 14, 10, 28),
        "Sombrero amplio de ala ancha bajo el sol del verano.")
    put("sway hips", "C", fondo_prado() + nino((80, 26), (80, 38), (80, 58), [[(62, 54)], [(98, 54)]], [[(74, 84)], [(86, 84)]]) + frecha((54, 58), (30, 58), MORADO, 3) + frecha((106, 58), (130, 58), MORADO, 3),
        "Balanceando las caderas suavemente de un lado al otro.")
    put("take turns", "C", fondo_prado() + nino((36, 32), (36, 44), (36, 64), [[(50, 52)], [(24, 54)]], [[(30, 86)], [(42, 86)]]) + fl("Soccer ball", 66, 42, 28) + nino((124, 32), (124, 44), (124, 64), [[(110, 52)], [(136, 54)]], [[(118, 86)], [(130, 86)]], camisa=(AZUL, AZUL_OSCURO)) + frecha((66, 24), (96, 24), VERDE_OSCURO, 3) + frecha((96, 78), (66, 78), AZUL_OSCURO, 3),
        "Dos niños turnándose ordenadamente por turnos.")
    put("the wind blows! whoosh", "C", fondo_cielo("#e0f2fe") + fl("Wind face", 24, 18, 54) + [L("M82 36 Q112 24 140 38", AZUL_OSCURO, 3.5), L("M82 54 Q112 64 140 52", AGUA_OSCURO, 3.5)],
        "Viento soplando fuerte con grandes ráfagas.", "the_wind_blows_whoosh")
    put("the wind is blowing", "C", fondo_prado() + fl("Leaf fluttering in wind", 82, 22, 50) + [L("M20 34 Q48 26 74 34", AZUL_OSCURO, 3), L("M24 50 Q52 42 78 50", AGUA_OSCURO, 3)],
        "Ráfagas de aire moviendo las hojas por el campo.")
    put("tie up", "C", fondo_mar() + fl("Sailboat", 24, 22, 52) + [L("M74 62 Q94 74 114 60", BARRO, 3), R(110, 48, 14, 26, 2, MADERA, MADERA_OSCURA, 2)],
        "Amarrando el barco con cabo firme al poste del puerto.")
    put("tiptoe around", "C", fondo_sala() + fl("Footprints", 46, 22, 50) + frecha((112, 72), (112, 24), MORADO, 3.5),
        "Andando suavemente de puntillas sin hacer ruido.")
    put("touch your knees", "C", fondo_prado() + nino((80, 26), (80, 38), (80, 56), [[(70, 68)], [(90, 68)]], [[(74, 86)], [(86, 86)]]) + frecha((42, 68), (66, 68), ROJO_OSCURO, 3) + frecha((118, 68), (94, 68), ROJO_OSCURO, 3),
        "Niño tocándose las dos rodillas con sus manos.")
    put("tread", "C", fondo_prado() + fl("Hiking boot", 46, 24, 52) + frecha((118, 22), (118, 70), BARRO, 3.5),
        "Pie apoyándose firmemente al pisar el suelo.")
    put("wake up", "C", fondo_cielo("#fef9c3") + fl("Sun", 18, 12, 34) + nino((84, 30), (84, 42), (84, 62), [[(64, 24)], [(104, 24)]], [[(78, 86)], [(90, 86)]]),
        "Sol naciente y niño despertándose y estirando los brazos.")
    put("walrus", "D", fondo_mar() + [
        E(80, 54, 30, 20, "#9a3412", "#431407", 2.5),
        E(80, 36, 15, 13, "#9a3412", "#431407", 2.2),
        P([(71, 44), (74, 60), (77, 44)], BLANCO, TINTA, 1.5),
        P([(83, 44), (86, 60), (89, 44)], BLANCO, TINTA, 1.5),
        E(74, 33, 2, 2, TINTA),
        E(86, 33, 2, 2, TINTA),
    ], "Morsa marrón en el mar con dos largos colmillos blancos.")
    put("wash your belly", "C", fondo_sala() + nino((64, 26), (64, 38), (64, 58), [[(64, 54)], [(78, 54)]], [[(58, 86)], [(70, 86)]]) + fl("Soap", 104, 32, 32) + pompas([(96, 22, 5), (102, 66, 5)]),
        "Niño lavándose suavemente la barriguita con jabón y espuma.")
    put("wash your face", "C", fondo_sala() + fl("Open hands", 40, 34, 48) + [E(80, 30, 15, 15, PEL, PELB, 2)] + gotas([(52, 22), (108, 22)]) + fl("Soap", 108, 42, 32),
        "Lavándose suavemente la cara con agua fresca y jabón.")
    put("wave goodbye", "C", fondo_prado() + nino((64, 30), (64, 42), (64, 62), [[(50, 52)], [(86, 28)]], [[(58, 86)], [(70, 86)]]) + fl("Waving hand", 92, 16, 40),
        "Niño levantando la mano abierta para despedirse diciendo adiós.")
    put("wave to the boat", "C", fondo_mar() + fl("Sailboat", 22, 26, 48) + nino((116, 32), (116, 44), (116, 64), [[(98, 28)], [(130, 52)]], [[(110, 86)], [(122, 86)]]),
        "Niño saludando con la mano al barco que navega.")
    put("we are tiny seeds under the ground", "D", [
        R(0, 0, 160, 44, 0, "#e0f2fe"),
        R(0, 44, 160, 56, 0, BARRO),
        E(46, 70, 7, 5, "#fde68a", AMARILLO_OSCURO, 1.8),
        E(80, 74, 7, 5, "#fde68a", AMARILLO_OSCURO, 1.8),
        E(114, 70, 7, 5, "#fde68a", AMARILLO_OSCURO, 1.8),
        L("M80 68 L80 54", VERDE, 2.5),
    ], "Semillas pequeñitas dormidas debajo de la tierra marrón.", "tiny_seeds_ground")
    put("where's the sun", "C", fondo_cielo("#cbd5e1") + fl("Cloud", 44, 24, 56) + fl("Sun", 82, 16, 36),
        "Sol escondiéndose detrás de una gran nube blanca.", "wheres_the_sun")
    put("whistle a tune", "C", fondo_prado() + nino((58, 32), (58, 44), (58, 64), [[(44, 54)], [(72, 54)]], [[(52, 86)], [(64, 86)]]) + notas([(92, 26), (110, 18), (128, 30)]),
        "Niño silbando alegremente una melodía con notas en el aire.")
    put("zip it up", "D", fondo_sala() + [
        R(48, 16, 64, 68, 8, AZUL, AZUL_OSCURO, 2.5),
        L("M80 20 L80 82", GRIS, 4),
        R(74, 30, 12, 12, 2, AMARILLO, AMARILLO_OSCURO, 2),
    ] + frecha((126, 62), (126, 24), VERDE_OSCURO, 3.5), "Cremallera del abrigo cerrándose completamente hasta arriba.")
    put("zip up", "D", fondo_sala() + [
        R(44, 16, 72, 68, 8, ROJO, ROJO_OSCURO, 2.5),
        L("M80 44 L80 82", GRIS, 4),
        P([(66, 16), (80, 44), (94, 16)], "#fef3c7", "#d97706", 2),
        R(74, 40, 12, 12, 2, AMARILLO, AMARILLO_OSCURO, 2),
    ] + frecha((126, 58), (126, 22), VERDE_OSCURO, 3.5), "Subiendo la cremallera abierta de la chaqueta hacia arriba.")

    # ── Frases de gramática de curso_2_3 ──────────────────────────────────
    put("can the stone float", "C", fondo_mar() + fl("Rock", 48, 36, 46) + [L("M116 40 Q124 30 124 44 L118 52", TINTA, 3), E(118, 60, 2.5, 2.5, TINTA)],
        "Piedra en el agua preguntando si puede flotar.")
    put("cut it for me", "C", fondo_mesa() + fl("Red apple", 32, 24, 48) + fl("Kitchen knife", 84, 24, 48),
        "Manzana y cuchillo de cocina listos para cortarla.")
    put("did you hear it", "C", fondo_sala() + fl("Ear", 40, 22, 52) + [L("M96 32 Q112 48 96 64", AZUL_OSCURO, 3), L("M108 26 Q128 48 108 70", AGUA_OSCURO, 3)],
        "Oreja atenta escuchando ondas sonoras en el aire.")
    put("i found the star myself", "C", fondo_prado() + nino((46, 30), (46, 42), (46, 62), [[(68, 40)], [(34, 52)]], [[(40, 86)], [(52, 86)]], mira=1) + fl("Glowing star", 82, 20, 48),
        "Niño mostrando contento la estrella que encontró él mismo.")
    put("is it going far", "C", fondo_prado() + fl("Soccer ball", 24, 44, 34) + frecha((66, 60), (144, 60), AZUL_OSCURO, 4),
        "Pelota viajando muy lejos hasta el fondo.")
    put("it will be dry tomorrow", "C", fondo_cielo("#fef9c3") + fl("Sun", 20, 12, 42) + pano(66, 26, 60, 44, "#fde68a", "#d97706"),
        "Toalla tendida secándose al sol radiante de mañana.")
    put("look at it", "C", fondo_sala() + fl("Eyes", 32, 24, 52) + fl("Teddy bear", 92, 24, 46),
        "Ojos mirando atentamente justo hacia el objeto.")
    put("put the boat in the water", "C", fondo_mar() + fl("Sailboat", 52, 16, 48) + frecha((116, 16), (116, 58), VERDE_OSCURO, 3.5),
        "Colocando el barco desde arriba dentro del agua.")
    put("show me the star", "C", fondo_noite() + nino((42, 32), (42, 44), (42, 64), [[(64, 34)], [(28, 54)]], [[(36, 86)], [(48, 86)]], mira=1) + fl("Glowing star", 82, 16, 52),
        "Niño señalando y mostrando la estrella brillante.")
    put("the boat can float", "C", fondo_mar() + fl("Sailboat", 46, 24, 62),
        "Velero flotando suavemente en la superficie del mar.")
    put("the boat is moving", "C", fondo_mar() + fl("Sailboat", 30, 26, 52) + frecha((92, 56), (138, 56), AZUL_OSCURO, 3.5),
        "Barco avanzando con movimiento sobre las olas.")
    put("the bread was getting hard", "C", fondo_mesa() + fl("Baguette bread", 32, 26, 54) + fl("Rock", 90, 32, 42),
        "Barra de pan endureciéndose tanto como una piedra.")
    put("the cat has to sleep", "C", fondo_noite() + fl("Cat", 32, 30, 52) + fl("Sleeping face", 94, 18, 40),
        "Gato echado descansando para dormir por la noche.")
    put("the cleanest hands", "C", fondo_sala() + fl("Open hands", 40, 26, 58) + fl("Sparkles", 98, 12, 36),
        "Manos relucientes y completamente limpias con destellos.")
    put("the leaf made a small sound", "C", fondo_prado() + fl("Fallen leaf", 28, 28, 46) + fl("Ear", 88, 28, 42) + [L("M74 44 L82 44", AZUL_OSCURO, 2)],
        "Hoja suave produciendo un sonido pequeñito al moverse.", "leaf_small_sound")
    put("the leaf was small", "C", fondo_prado() + fl("Fallen leaf", 66, 46, 28),
        "Una hoja muy pequeñita en mitad del prado.")
    put("the light comes out of the holes", "C", fondo_noite() + [
        R(28, 26, 48, 48, 4, MADERA, MADERA_OSCURA, 2),
        E(52, 40, 5, 5, "#fef08a"),
        E(52, 60, 5, 5, "#fef08a"),
        L("M56 40 L132 22", "#fef08a", 3),
        L("M56 60 L132 76", "#fef08a", 3),
    ], "Rayos de luz amarilla saliendo por los agujeros de la caja.", "light_out_holes")
    put("the light goes into the box", "C", fondo_noite() + fl("Flashlight", 18, 28, 44) + [P([(54, 44), (92, 34), (92, 62)], "#fef08a")] + fl("Package", 86, 28, 52),
        "Luz de linterna entrando dentro de la caja abierta.")
    put("the nut dropped", "C", fondo_prado() + fl("Chestnut", 52, 18, 42) + frecha((112, 16), (112, 68), TIERRA, 3.5),
        "Fruto seco cayendo hacia abajo hasta el suelo.")
    put("the stars go up to the ceiling", "C", fondo_noite() + fl("Glowing star", 34, 10, 36) + fl("Glowing star", 84, 16, 32) + frecha((126, 72), (126, 20), AMARILLO, 3.5),
        "Estrellas luminosas subiendo hacia lo alto del techo.")
    put("the stone can't float", "C", fondo_mar() + fl("Rock", 52, 54, 44) + frecha((116, 26), (116, 74), ROJO_OSCURO, 3.5),
        "Piedra hundiéndose hasta el fondo porque no flota.")
    put("the stone was big", "C", fondo_prado() + fl("Rock", 42, 12, 76),
        "Una piedra enorme ocupando gran parte de la escena.")
    put("the stones were in two piles", "C", fondo_prado()
        + fl("Rock", 16, 44, 28) + fl("Rock", 42, 44, 28) + fl("Rock", 29, 26, 26)
        + fl("Rock", 88, 44, 28) + fl("Rock", 114, 44, 28) + fl("Rock", 101, 26, 26),
        "Piedras agrupadas en dos montones separados.", "stones_two_piles")
    put("the towel will be heavy", "C", fondo_sala() + pano(34, 24, 62, 46, "#93c5fd", AZUL_OSCURO) + gotas([(46, 56), (66, 62), (82, 54)]) + frecha((118, 24), (118, 72), AZUL_OSCURO, 4),
        "Toalla muy mojada tirando hacia abajo por el peso del agua.")
    put("they move across the room", "C", fondo_sala() + nino((34, 30), (34, 42), (34, 62), [[(48, 48)], [(20, 50)]], [[(28, 86)], [(40, 86)]], mira=1) + frecha((60, 48), (104, 48), VERDE_OSCURO, 3.5) + nino((124, 30), (124, 42), (124, 62), [[(138, 48)], [(110, 50)]], [[(118, 86)], [(130, 86)]], camisa=(VERDE, VERDE_OSCURO), mira=1),
        "Niños cruzando de lado a lado por toda la sala.")
    put("this is the best soap", "C", fondo_sala() + fl("Soap", 42, 24, 56) + fl("Sparkles", 98, 12, 34) + fl("Glowing star", 18, 16, 30),
        "Pastilla de jabón reluciente destacada como la mejor.")
    put("was the stone the biggest", "C", fondo_prado() + fl("Rock", 22, 48, 32) + fl("Rock", 68, 16, 66),
        "Comparación entre una piedra pequeña y la más grande.")
    put("water is faster than soap", "C", fondo_mesa() + fl("Droplet", 24, 24, 42) + frecha((70, 44), (102, 44), AZUL_OSCURO, 4) + fl("Soap", 104, 30, 40),
        "El agua avanza mucho más rápida que la pastilla de jabón.")
    put("we are blowing the boat", "C", fondo_mar() + nino((30, 32), (30, 44), (30, 62), [[(44, 52)], [(18, 54)]], [[(24, 78)], [(36, 78)]], mira=1) + frecha((46, 38), (78, 38), AZUL_OSCURO, 3) + fl("Sailboat", 84, 26, 52),
        "Niño soplando suavemente para mover el barquito en el agua.")
    put("we are going to lift it", "C", fondo_prado() + nino((52, 36), (52, 48), (52, 68), [[(68, 52)], [(36, 54)]], [[(46, 86)], [(58, 86)]], mira=1) + fl("Package", 76, 48, 36) + frecha((122, 70), (122, 22), VERDE_OSCURO, 3.5),
        "Preparado para levantar el paquete hacia arriba.")
    put("we listened", "C", fondo_sala() + fl("Ear", 46, 20, 56) + notas([(108, 28), (126, 20)]),
        "Escuchando con atención los sonidos del entorno.")
    put("we were squeezing the bread", "C", fondo_mesa() + fl("Bread", 50, 24, 56) + frecha((22, 48), (48, 48), ROJO_OSCURO, 3.5) + frecha((138, 48), (110, 48), ROJO_OSCURO, 3.5),
        "Apretando una rebanada de pan blando desde ambos lados.")
    put("what was happening to the bread", "C", fondo_mesa() + fl("Bread", 36, 26, 52) + gotas([(96, 26), (112, 44), (100, 60)]),
        "Observando cómo cambia la rebanada de pan al mojarse.")
    put("will it be light", "C", fondo_cielo("#e0f2fe") + fl("Feather", 46, 22, 56) + frecha((116, 62), (116, 20), VERDE_OSCURO, 3),
        "Pluma ligerísima flotando suavemente hacia arriba.")
    put("you are blowing softly", "C", fondo_sala() + nino((38, 34), (38, 46), (38, 66), [[(52, 52)], [(24, 54)]], [[(32, 86)], [(44, 86)]], mira=1) + [L("M56 38 Q78 34 98 38", AGUA_OSCURO, 2)] + fl("Feather", 98, 26, 38),
        "Soplando un aire suave capaz de mover una pluma ligera.")
    put("you have to run fast", "C", fondo_prado() + nino((52, 30), (48, 42), (42, 60), [[(64, 40)], [(28, 48)]], [[(60, 74), (70, 84)], [(26, 74), (18, 84)]], mira=1) + frecha((88, 46), (140, 46), ROJO, 4.5),
        "Corriendo rápido hacia delante siguiendo la flecha roja.")
    put("you must stop", "C", fondo_prado() + fl("Stop sign", 28, 16, 54) + nino((108, 28), (108, 40), (108, 60), [[(92, 30)], [(124, 30)]], [[(102, 86)], [(114, 86)]]),
        "Señal de stop indicando que hay que detenerse.")
    put("you should walk slowly", "C", fondo_prado() + nino((52, 28), (52, 40), (52, 60), [[(40, 50)], [(64, 50)]], [[(46, 84)], [(60, 84)]], mira=1) + fl("Turtle", 92, 40, 44),
        "Niño caminando despacio al ritmo tranquilo de la tortuga.")
    put("you were knocking on it", "C", fondo_sala() + fl("Door", 36, 14, 62) + fl("Oncoming fist", 94, 30, 42),
        "Puño llamando suave en la madera de la puerta.")
    put("your hands are cleaner now", "C", fondo_sala() + fl("Open hands", 42, 26, 54) + pompas([(28, 26, 5), (120, 48, 5)]) + fl("Sparkles", 98, 14, 34),
        "Manos mucho más limpias y relucientes tras lavarse.", "hands_cleaner_now")

    return m


def _recoger_claves_2_3() -> dict[str, str]:
    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    out: dict[str, str] = {}
    for u in lec["cursos"]["curso_2_3"]["unidades"]:
        for l in u["leccions"]:
            for b in ("xaSabe", "novas", "repasa"):
                for p in l.get(b) or []:
                    k = p["en"].lower().strip(" .!?")
                    out.setdefault(k, p["en"])
            f = l.get("fraseGramatica")
            if f:
                k = f["en"].lower().strip(" .!?")
                out.setdefault(k, f["en"])
    return out


def main() -> int:
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]
    claves = _recoger_claves_2_3()
    escenas = {k.strip(" .!?"): v for k, v in _escenas_2_3().items()}
    fd = {k.strip(" .!?"): v for k, v in FLUENT_DIRECTOS.items()}
    pr = {k.strip(" .!?"): v for k, v in PROPIAS_REUTILIZADAS.items()}

    counts = {"U": 0, "R": 0, "C": 0, "D": 0}
    reused_prev = 0
    faltan: list[str] = []

    for k, en in sorted(claves.items()):
        if k in fd:
            slug, fl_name, ur, porque = fd[k]
            escribir_fluent_directo(pezas, k, slug, fl_name, ur, porque)
            counts[ur] += 1
        elif k in pr:
            clave, porque = pr[k]
            escribir_reutilizada(pezas, k, clave, porque)
            counts["R"] += 1
        elif k in escenas:
            slug, cd, formas, porque = escenas[k]
            escribir_cd(pezas, k, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=en)
            counts[cd] += 1
        elif k in pezas:
            reused_prev += 1
        else:
            faltan.append(k)

    if faltan:
        raise RuntimeError(f"Faltan {len(faltan)} claves en 2-3: {faltan[:20]}")

    mapa["pezas"] = dict(sorted(pezas.items()))
    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print(f"OK gen_laminas_2_3: nuevas={counts} (sum={sum(counts.values())}), ya_cubiertas={reused_prev}, total_curso={len(claves)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
