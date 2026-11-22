#!/usr/bin/env python3
"""Tanda 4 TPR (P2.85): abrazos/ternura (cierre), empujar/tirar, lanzar/coger,
brazos arriba, levantar la mano, brazos abiertos, saludar, equilibrio/agacharse/girar
y primer bloque de acciones con agua.

Cubre 200 piezas revisadas + 55 auditadas sin base (`SIN_BASE`):
- Cierre completo de `hug_heart` (29), `push_pull` (16), `throw_catch` (15),
  `arms_up` (7+12), `raise_hand` (7+8), `arms_wide` (42+16), `wave` (32+19),
  `balance` (3), `crouch` (1) y `spin` (1).
- Primeras 47 concretas de `water_action` (`blow bubbles in water` .. `splashing` + `shower`).

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
    abrazo_dos,
    arco_giro,
    bebe,
    bebe_sentado,
    caja_prop,
    charco_prop,
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
    lineas_viento,
    manta_prop,
    mesa_prop,
    nino,
    nino_abrazando,
    nino_busto,
    nino_caminando,
    nino_corriendo,
    ondas_sonido,
    pano,
    pelota_prop,
    pompas,
    sol,
    toalla_prop,
)

# ── Directas Fluent Emoji Flat (MIT) ───────────────────────────────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "dice": ("Game die", "U", "Dado cúbico de juego con puntos."),
    "gift": ("Wrapped gift", "U", "Caja de regalo envuelta con lazo rojo."),
    "hand wave": ("Waving hand", "U", "Mano abierta moviéndose de lado a lado para saludar."),
    "raise a hand": ("Raised hand", "U", "Mano abierta levantada esperando el turno."),
    "shower": ("Shower", "U", "Alcachofa de ducha soltando chorros de agua."),
}

# ── Directas Iconify ───────────────────────────────────────────────────────
DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}


def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── Cierre de abrazos, ternura y caricias (hug_heart) ──────────────────
    put("bye-bye", "C",
        fondo_sala() + fl("Waving hand", 28, 20, 48) + fl("Kiss mark", 92, 24, 42),
        "Mano diciendo adiós y beso lanzado al aire con cariño.")
    put("coo coo", "C",
        fondo_prado() + fl("Dove", 28, 22, 48, flip_x=True) + ondas_sonido(86, 44, AZUL_OSCURO, 1) + ondas_sonido(96, 44, AZUL_OSCURO, 1),
        "Paloma blanca arrullando con ondas suaves de sonido.")
    put("family", "D",
        fondo_sala() + [R(47, 14, 22, 18, 6, MADERA_OSCURA)] + nino((58, 22), (58, 34), (58, 56), [[(74, 44)], [(44, 48)]], [[(52, 84)], [(64, 84)]], camisa=(ROSA, ROSA_OSCURO), r=9.0) + nino((102, 22), (102, 34), (102, 56), [[(86, 44)], [(116, 48)]], [[(96, 84)], [(108, 84)]], camisa=(AZUL, AZUL_OSCURO), r=9.0) + nino((80, 38), (80, 48), (80, 66), [[(66, 52)], [(94, 52)]], [[(75, 86)], [(85, 86)]], camisa=(VERDE, VERDE_OSCURO), r=7.5),
        "Familia reunida en un gran abrazo común entre padres y niño.")
    put("heart", "C",
        fondo_sala() + fl("Beating heart", 28, 22, 46) + nino((102, 34), (102, 46), (102, 66), [[(98, 50)], [(116, 56)]], [[(96, 88)], [(108, 88)]]),
        "Corazón latiendo y niño sintiendo el pulso con la mano sobre el pecho.")
    put("kiss", "C",
        fondo_sala() + nino((62, 34), (62, 46), (62, 66), [[(70, 38)], [(48, 56)]], [[(56, 88)], [(68, 88)]], mira=1) + frecha((80, 34), (98, 30), ROSA_OSCURO, 2.2) + fl("Kiss mark", 102, 18, 32),
        "Niño llevándose los dedos a los labios y lanzando un beso suave al aire.")
    put("look after animals", "C",
        fondo_prado() + fl("Dog", 22, 26, 46) + [E(68, 74, 12, 5, ROJO, ROJO_OSCURO, 1.8), E(68, 72, 7, 3, BARRO)] + nino((106, 36), (106, 48), (106, 66), [[(82, 48)], [(118, 56)]], [[(100, 88)], [(112, 88)]], mira=-1),
        "Niño cuidando al perrito acariciándole el lomo junto a su plato de comida.")
    put("mummy", "D",
        fondo_sala() + [R(53, 14, 22, 18, 6, MADERA_OSCURA)] + nino((64, 22), (64, 34), (64, 56), [[(50, 46)], [(84, 52)]], [[(58, 84)], [(70, 84)]], camisa=(ROSA, ROSA_OSCURO), r=9.0) + nino((98, 38), (98, 48), (98, 66), [[(94, 52)], [(112, 58)]], [[(93, 86)], [(103, 86)]], r=7.5),
        "Mamá adulta de la mano junto a su niño que se lleva la mano al pecho.")
    put("pet care", "C",
        fondo_sala() + fl("Cat", 22, 26, 46) + [E(68, 74, 12, 5, AZUL, AZUL_OSCURO, 1.8), E(68, 72, 7, 3, AGUA)] + nino((106, 36), (106, 48), (106, 66), [[(82, 48)], [(118, 56)]], [[(100, 88)], [(112, 88)]], mira=-1),
        "Cuidado de la mascota dando agua y caricias suaves al gatito.")
    put("see you after summer", "C",
        fondo_mar() + fl("Sun", 22, 14, 34) + fl("Waving hand", 64, 24, 40) + fl("Kiss mark", 110, 24, 34),
        "Sol brillante de verano con despedida agitando la mano y mandando un beso.")
    put("snug in the towel", "C",
        fondo_sala() + toalla_prop(46, 36, 68, h=38) + bebe_sentado(80, 32),
        "Bebé bien envuelto y arropado en una toalla azul suave.")
    put("snuggle", "D",
        fondo_sala() + nino_busto(64, 36) + bebe(96, 46),
        "Bebé acurrucado tiernamente contra el pecho.")
    put("snuggly", "C",
        fondo_sala() + bebe(66, 48) + nino((108, 38), (108, 50), (108, 68), [[(86, 54)], [(118, 60)]], [[(102, 88)], [(114, 88)]], mira=-1),
        "Bebé mimoso acurrucado mejilla con mejilla.")
    put("snuggly jumper", "C",
        fondo_sala() + fl("T-shirt", 32, 22, 46) + nino_abrazando(104, 34, camisa=(VERDE, VERDE_OSCURO)),
        "Jersey suave de abrigo abrazado para estar calentito.")
    put("soft and dry", "C",
        fondo_sala() + [R(26, 46, 46, 12, 5, "#bae6fd", AGUA_OSCURO, 2.0), R(28, 34, 42, 12, 5, "#e0f2fe", AGUA_OSCURO, 1.8), L("M32 52 L66 52", AZUL_OSCURO, 1.4)] + fl("Sun", 34, 8, 26) + nino_abrazando(106, 34),
        "Toalla doblada seca y suave secando con cuidado la piel.")
    put("soft like a cat", "C",
        fondo_sala() + fl("Cat", 28, 26, 46) + nino((104, 34), (104, 46), (104, 66), [[(98, 38)], [(118, 56)]], [[(98, 88)], [(110, 88)]]),
        "Gatito de pelo suave y niño acariciando su propia mejilla.")
    put("soothing", "D",
        fondo_sala() + abrazo_dos(76, 34) + arco_giro(112, 50, 14, MORADO),
        "Caricia suave y circular en la espalda que calma y relaja.")
    put("squeeze tight", "D",
        fondo_sala() + abrazo_dos(80, 34) + frecha((36, 50), (58, 50), ROJO, 2.4) + frecha((124, 50), (102, 50), ROJO, 2.4),
        "Abrazo apretado con fuerza simbolizado por flechas hacia el centro.")
    put("stroke", "D",
        fondo_sala() + bebe(54, 48) + nino((106, 34), (106, 46), (106, 66), [[(74, 44)], [(118, 56)]], [[(100, 88)], [(112, 88)]]),
        "Caricia delicada en el pelo del bebé con la mano abierta.")
    put("sweet dreams", "C",
        fondo_noite() + fl("Crescent moon", 24, 14, 36) + nino_busto(82, 36, ojos="cerrados") + fl("Kiss mark", 110, 24, 28),
        "Ojos cerrados bajo la luna mandando un beso suave de buenas noches.")
    put("the vet helps animals because she loves them", "C",
        fondo_sala() + fl("Stethoscope", 22, 18, 42) + fl("Dog", 66, 30, 42) + nino_abrazando(124, 34),
        "Veterinaria cuidando con estetoscopio y cariño a los animales.")
    put("tiger cub", "C",
        fondo_prado() + fl("Tiger", 30, 24, 48) + nino_abrazando(104, 34, camisa=(NARANJA, NARANJA_OSCURO)),
        "Cachorro de tigre acurrucado y niño abrazándose suave como él.")
    put("toasty warm", "C",
        fondo_sala() + fl("Fire", 24, 24, 42) + nino_busto(84, 36) + bebe(116, 46),
        "Calorcito agradable abrazando al bebé bien apretado.")
    put("tree trunk", "C",
        fondo_prado() + fl("Evergreen tree", 36, 14, 58) + nino_busto(94, 42) + bebe(120, 52),
        "Tronco de árbol grande abrazado con el bebé al lado.")
    put("vet", "C",
        fondo_sala() + fl("Stethoscope", 26, 22, 46) + fl("Cat", 84, 24, 48),
        "Estetoscopio veterinario y gatito cuidado con mimo.")
    put("warm clothes", "C",
        fondo_sala() + fl("Coat", 28, 22, 46) + fl("Scarf", 88, 24, 44) + nino_abrazando(126, 34),
        "Abrigo y bufanda cálida abrazados en días fríos.")
    put("well-cared-for", "C",
        fondo_prado() + fl("Potted plant", 32, 22, 48) + nino((104, 34), (104, 46), (104, 66), [[(82, 44)], [(118, 56)]], [[(98, 88)], [(110, 88)]]),
        "Planta cuidada con mimo acariciada suavemente por un niño.")
    put("woolly", "C",
        fondo_sala() + fl("Yarn", 28, 24, 48) + nino((106, 34), (106, 46), (106, 66), [[(78, 44)], [(118, 56)]], [[(100, 88)], [(112, 88)]], mira=-1),
        "Ovillo de lana esponjosa y blanda acariciada suavemente con la mano.")
    put("woolly lamb", "C",
        fondo_prado() + fl("Ewe", 28, 24, 48) + nino((104, 34), (104, 46), (104, 66), [[(82, 46)], [(116, 56)]], [[(98, 88)], [(110, 88)]]),
        "Corderito de lana blanca acariciado suavemente.")
    put("wrap in a towel", "C",
        fondo_sala() + toalla_prop(40, 34, 64, h=38) + bebe_sentado(72, 32) + nino((116, 34), (116, 46), (116, 66), [[(98, 48)], [(128, 56)]], [[(110, 88)], [(122, 88)]]),
        "Envolver suavemente al bebé en su toalla y darle un abrazo.")

    # ── Empujar / tirar (push_pull — completo, 16) ─────────────────────────
    put("nudge", "D",
        fondo_mesa() + pelota_prop(96, 52, 14, VERDE, VERDE_OSCURO) + frecha((44, 52), (76, 52), ROJO, 2.6),
        "Empujoncito suave con el dedo para hacer rodar la pelota.")
    put("plough", "C",
        fondo_prado() + [R(0, 74, 160, 26, 0, BARRO)] + fl("Tractor", 26, 28, 46) + nino_caminando(104, 32, -1) + frecha((84, 22), (46, 22), ROJO, 2.4),
        "Tractor abriendo surco y niño caminando empujando el arado despacio.")
    put("pram", "D",
        fondo_prado() + [R(74, 38, 42, 24, 8, AZUL, AZUL_OSCURO, 2.0), E(84, 68, 7, 7, NEGRO), E(108, 68, 7, 7, NEGRO), L("M74 42 L60 32", GRIS_OSCURO, 2.8)] + nino_caminando(44, 34, 1) + frecha((90, 22), (124, 22), VERDE_OSCURO, 2.4),
        "Niño empujando despacio un cochecito de paseo con ruedas.")
    put("pull on boots", "C",
        fondo_sala() + fl("Hiking boot", 56, 38, 46) + frecha((66, 36), (66, 14), ROJO, 2.4) + frecha((94, 36), (94, 14), ROJO, 2.4),
        "Bota fuerte tirada de las orejetas hacia arriba para calzarse.")
    put("pull up the rope", "D",
        fondo_prado() + [L("M60 16 L60 88", BARRO, 4.0)] + nino((92, 34), (92, 46), (92, 66), [[(60, 44)], [(60, 56)]], [[(86, 88)], [(98, 88)]], mira=-1) + frecha((42, 64), (42, 24), ROJO, 2.8),
        "Niño agarrando una cuerda vertical y tirando fuerte hacia arriba.")
    put("pull, pull, pull", "D",
        fondo_prado() + [L("M24 54 L136 54", BARRO, 3.8)] + nino((96, 34), (104, 46), (112, 66), [[(74, 54)], [(86, 54)]], [[(98, 88)], [(120, 88)]], mira=1) + frecha((76, 26), (124, 26), ROJO, 2.8),
        "Niño inclinado hacia atrás tirando con fuerza de la cuerda horizontal.")
    put("rope", "D",
        fondo_sala() + [L("M24 52 L136 52", BARRO, 4.4)] + [E(58, 52, 6, 5, PEL, PELB, 1.8), E(102, 52, 6, 5, PEL, PELB, 1.8)] + frecha((42, 38), (24, 38), AZUL_OSCURO, 2.2) + frecha((118, 38), (136, 38), AZUL_OSCURO, 2.2),
        "Dos manos sujetando una cuerda gruesa tirando en tensión.")
    put("set sail", "C",
        fondo_mar() + fl("Sailboat", 54, 18, 54) + lineas_viento(22, 34, 20, AZUL_OSCURO) + frecha((112, 42), (138, 42), ROJO, 2.4),
        "Velero soltando amarras impulsado por el viento sobre el mar.")
    put("shut the drawer", "D",
        fondo_sala() + [R(48, 28, 64, 48, 3, MADERA, MADERA_OSCURA, 2.2), R(56, 38, 48, 22, 2, TIERRA_CLARA, MADERA_OSCURA, 2.0), E(80, 49, 4, 4, MADERA_OSCURA)] + frecha((126, 49), (98, 49), ROJO, 2.8),
        "Cajón abierto empujándose hacia dentro para cerrarlo.")
    put("stretch time", "D",
        fondo_sala() + [R(36, 78, 88, 10, 4, MORADO, "#5b21b6", 1.8)] + nino((80, 26), (80, 38), (80, 58), [[(62, 16)], [(98, 16)]], [[(74, 80)], [(86, 80)]]) + frecha((50, 40), (50, 18), AZUL_OSCURO, 2.0) + frecha((110, 40), (110, 18), AZUL_OSCURO, 2.0),
        "Niño sobre la esterilla estirando despacio los brazos hacia arriba en calma.")
    put("strong legs", "D",
        fondo_sala() + [R(22, 36, 12, 52, 2, GRIS, GRIS_OSCURO, 2.0)] + nino((96, 40), (96, 52), (92, 68), [[(82, 60)], [(110, 62)]], [[(36, 68)], [(86, 86)]], mira=-1) + frecha((68, 56), (38, 56), ROJO, 2.6),
        "Niño empujando con mucha fuerza con el pie la pared resistente.")
    put("swing seat", "D",
        fondo_prado() + [L("M56 12 L56 64", BARRO, 2.4), L("M104 12 L104 64", BARRO, 2.4), R(50, 64, 60, 9, 3, MADERA, MADERA_OSCURA, 2.0)] + frecha((30, 58), (48, 52), VERDE_OSCURO, 2.4),
        "Asiento de columpio suspendido por dos cuerdas al empujarlo suave.")
    put("tights", "D",
        fondo_sala() + [R(58, 22, 44, 16, 4, MORADO, "#5b21b6", 2.0), R(58, 36, 18, 42, 4, MORADO, "#5b21b6", 2.0), R(84, 36, 18, 42, 4, MORADO, "#5b21b6", 2.0)] + frecha((42, 54), (42, 24), ROJO, 2.4) + frecha((118, 54), (118, 24), ROJO, 2.4),
        "Leotardos morados largos estirándose hacia arriba al ponérselos.")
    put("train set", "C",
        fondo_sala() + [L("M22 76 L138 76", GRIS_OSCURO, 3.0)] + fl("Locomotive", 34, 22, 52) + frecha((94, 48), (126, 48), ROJO, 2.6),
        "Locomotora de juguete empujada hacia delante por la vía.")
    put("wheelbarrow", "C",
        fondo_prado() + [L("M78 64 L74 78", MADERA_OSCURA, 2.6), L("M106 60 L112 72", MADERA_OSCURA, 2.6), P([(72, 42), (118, 42), (108, 66), (78, 66)], VERDE, VERDE_OSCURO, 2.0), E(112, 72, 8, 8, NEGRO), L("M72 46 L56 44", MADERA_OSCURA, 2.8)] + fl("Fallen leaf", 84, 24, 24) + nino_caminando(40, 34, 1),
        "Carretilla llena de hojas empujada hacia delante por el jardín.")
    put("will it roll", "D",
        fondo_mesa() + [P([(32, 34), (128, 72), (32, 72)], TIERRA_CLARA, MADERA_OSCURA, 2.0)] + pelota_prop(48, 28, 11, ROJO, ROJO_OSCURO) + frecha((66, 26), (112, 44), AZUL_OSCURO, 2.6),
        "Pelota en lo alto de una rampa recibiendo un empujón para ver si rueda.")

    # ── Lanzar / atrapar (throw_catch — completo, 15) ──────────────────────
    put("cast a net", "D",
        fondo_mar() + [L("M20 76 L140 76", AGUA_OSCURO, 2.2), P([(22, 66), (72, 66), (62, 78), (30, 78)], MADERA, MADERA_OSCURA, 2.0)] + nino((46, 30), (46, 42), (46, 58), [[(64, 34)], [(34, 46)]], [[(40, 66)], [(52, 66)]]) + [L("M74 34 L126 62", BARRO, 1.8), L("M74 34 L106 72", BARRO, 1.8), L("M92 44 L116 56", BARRO, 1.5), L("M84 54 L120 66", BARRO, 1.5)],
        "Pescador en barca lanzando una red trenzada hacia el mar.")
    put("catch me", "D",
        fondo_prado() + nino_corriendo(44, 34, 1) + nino((114, 34), (114, 46), (114, 66), [[(92, 42)], [(128, 50)]], [[(108, 88)], [(120, 88)]], camisa=(AZUL, AZUL_OSCURO), mira=-1) + frecha((68, 24), (96, 24), VERDE_OSCURO, 2.2),
        "Un niño corriendo delante y otro extendiendo los brazos para atraparlo.")
    put("crumbs", "C",
        fondo_mesa() + fl("Bread", 24, 24, 44) + [E(80, 64, 3.2, 2.5, TIERRA_CLARA, BARRO, 1.2), E(92, 68, 2.8, 2.2, TIERRA_CLARA, BARRO, 1.2), E(102, 62, 3.5, 2.6, TIERRA_CLARA, BARRO, 1.2)] + nino((124, 34), (124, 46), (124, 66), [[(102, 58)], [(134, 58)]], [[(118, 88)], [(130, 88)]], mira=-1),
        "Pan con miguitas sueltas sobre la mesa recogidas con los dedos.")
    put("fish for a living", "C",
        fondo_mar() + fl("Fishing pole", 26, 18, 50) + fl("Tropical fish", 92, 36, 42) + frecha((80, 26), (96, 36), ROJO, 2.2),
        "Caña de pescar lanzada hacia los peces brillantes en el mar.")
    put("fisherman", "C",
        fondo_mar() + [P([(20, 64), (74, 64), (66, 76), (28, 76)], MADERA, MADERA_OSCURA, 2.0)] + nino((46, 30), (46, 42), (46, 58), [[(64, 36)], [(34, 48)]], [[(42, 64)], [(52, 64)]]) + fl("Tropical fish", 102, 52, 36),
        "Pescador en su barca lanzando la red hacia el pez.")
    put("graduation", "C",
        fondo_sala() + nino_busto(62, 50, brazos_arriba=True) + fl("Graduation cap", 86, 6, 34) + frecha((76, 38), (92, 20), ROJO, 2.2),
        "Niño levantando alegre los brazos al lanzar el birrete de graduación.")
    put("scale", "C",
        fondo_sala() + fl("Balance scale", 24, 20, 48) + nino((106, 34), (106, 46), (106, 66), [[(82, 46)], [(130, 46)]], [[(100, 88)], [(112, 88)]]),
        "Balanza de dos platillos y niño abriendo los brazos igual en equilibrio.")
    put("throw", "D",
        fondo_cielo() + [R(0, 74, 160, 26, 0, BLANCO, "#bae6fd", 1.6)] + nino((46, 32), (46, 44), (46, 64), [[(64, 36)], [(32, 50)]], [[(40, 84)], [(52, 84)]]) + [E(112, 34, 7, 7, BLANCO, AGUA_OSCURO, 1.8), L("M72 34 Q92 18 106 30", ROJO, 2.0)],
        "Niño lanzando suavemente una bola de nieve blanca por el aire.")
    put("throw and catch", "D",
        fondo_prado() + nino((40, 34), (40, 46), (40, 66), [[(58, 38)], [(28, 54)]], [[(34, 88)], [(46, 88)]], mira=1) + nino((120, 34), (120, 46), (120, 66), [[(102, 40)], [(132, 54)]], [[(114, 88)], [(126, 88)]], camisa=(AZUL, AZUL_OSCURO), mira=-1) + pelota_prop(80, 26, 9, ROJO, ROJO_OSCURO) + [L("M58 34 Q80 12 102 36", VERDE_OSCURO, 2.0)],
        "Dos niños lanzándose y cogiendo una pelota roja por el aire.")
    put("throw caps in the air", "C",
        fondo_sala() + nino_busto(52, 48, brazos_arriba=True) + nino_busto(108, 48, camisa=(AZUL, AZUL_OSCURO), brazos_arriba=True) + fl("Graduation cap", 36, 8, 30) + fl("Graduation cap", 92, 8, 30),
        "Niños celebrando el final de curso lanzando los birretes hacia arriba.")
    put("throw it higher than the tree", "C",
        fondo_prado() + fl("Deciduous tree", 24, 24, 52) + nino((108, 34), (108, 46), (108, 66), [[(92, 36)], [(120, 54)]], [[(102, 88)], [(114, 88)]], mira=-1) + pelota_prop(50, 14, 7, ROJO, ROJO_OSCURO) + [L("M90 32 Q72 8 58 14", ROJO, 2.0)],
        "Pelota lanzada con fuerza mucho más arriba de la copa del árbol.")
    put("toss", "D",
        fondo_sala() + nino((62, 36), (62, 48), (62, 68), [[(78, 36)], [(48, 56)]], [[(56, 88)], [(68, 88)]]) + [F("M92 22 Q104 12 118 22 Q112 34 102 30 Q94 34 92 22 Z", VERDE, VERDE_OSCURO, 2.0)] + frecha((84, 38), (96, 24), ROJO, 2.2),
        "Niño lanzando un pañuelo ligero suave hacia arriba.")
    put("up and away", "C",
        fondo_prado() + fl("Fallen leaf", 96, 12, 32) + nino((52, 34), (52, 46), (52, 66), [[(68, 34)], [(40, 54)]], [[(46, 88)], [(58, 88)]]) + [L("M72 34 Q82 18 94 22", NARANJA_OSCURO, 2.2)],
        "Hoja seca lanzada hacia arriba volando lejos en el cielo.")
    put("up it goes", "D",
        fondo_sala() + nino((80, 42), (80, 54), (80, 72), [[(64, 36)], [(96, 36)]], [[(74, 88)], [(86, 88)]]) + [F("M64 18 Q80 6 96 18 Q90 28 80 24 Q70 28 64 18 Z", AGUA, AGUA_OSCURO, 2.0)] + frecha((54, 42), (54, 18), ROJO, 2.2),
        "Pañuelo azul lanzado bien alto justo por encima de la cabeza.")

    # ── Brazos arriba (arms_up — 7 concretas, resto SIN_BASE) ─────────────
    put("arms up high", "C",
        fondo_sala() + fl("T-shirt", 26, 22, 46) + nino((104, 34), (104, 46), (104, 66), [[(92, 16)], [(116, 16)]], [[(98, 88)], [(110, 88)]]) + frecha((128, 38), (128, 16), ROJO, 2.2),
        "Camiseta preparada y niño levantando los dos brazos arriba para vestirla.")
    put("growing", "C",
        fondo_prado() + fl("Seedling", 26, 36, 42) + frecha((70, 62), (70, 22), VERDE_OSCURO, 2.6) + nino((106, 32), (106, 44), (106, 64), [[(94, 14)], [(118, 14)]], [[(100, 88)], [(112, 88)]]),
        "Brote verde creciendo junto al niño que se estira alto hacia arriba.")
    put("plant", "C",
        fondo_prado() + fl("Potted plant", 26, 24, 48) + nino((104, 32), (104, 44), (104, 64), [[(90, 16)], [(118, 16)]], [[(98, 88)], [(110, 88)]], camisa=(VERDE, VERDE_OSCURO)),
        "Planta en maceta abriéndose arriba mientras el niño la imita de pie.")
    put("reach up", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Sun", 66, 4, 28) + nino((80, 48), (80, 58), (80, 74), [[(68, 34)], [(92, 34)]], [[(76, 88)], [(84, 88)]]),
        "Sol brillante arriba y niño estirando mucho los brazos hacia él.")
    put("so big", "D",
        fondo_sala() + bebe_sentado(44, 52) + nino((104, 30), (104, 42), (104, 64), [[(92, 12)], [(116, 12)]], [[(98, 88)], [(110, 88)]]) + frecha((128, 72), (128, 16), ROJO, 2.6),
        "Niño levantando los brazos bien alto mostrando lo muy grande que es.")
    put("win", "C",
        fondo_sala() + fl("1st place medal", 26, 22, 46) + nino((104, 34), (104, 46), (104, 66), [[(90, 18)], [(118, 18)]], [[(98, 88)], [(110, 88)]]),
        "Medalla de oro y niño alzando los dos brazos en señal de triunfo.")
    put("winner", "C",
        fondo_sala() + fl("Trophy", 24, 24, 46) + [R(82, 64, 44, 22, 2, AMARILLO, AMARILLO_OSCURO, 2.0)] + nino((104, 24), (104, 34), (104, 50), [[(90, 12)], [(118, 12)]], [[(98, 64)], [(110, 64)]]),
        "Trofeo de premio y ganador en el podio con los brazos levantados.")

    # ── Levantar una mano (raise_hand — 6 concretas, resto SIN_BASE) ───────
    put("hail a taxi", "C",
        fondo_prado() + [R(0, 68, 160, 32, 0, GRIS, GRIS_OSCURO, 1.5)] + fl("Taxi", 22, 30, 50) + nino((112, 32), (112, 44), (112, 64), [[(96, 16)], [(124, 54)]], [[(106, 84)], [(118, 84)]]),
        "Taxi amarillo en la calle y niño levantando la mano desde la acera.")
    put("hidden under", "C",
        fondo_sala() + mesa_prop(26, 46, 70, 38) + pelota_prop(60, 72, 9, ROJO, ROJO_OSCURO) + nino((118, 38), (118, 50), (118, 68), [[(92, 64)], [(128, 30)]], [[(112, 88)], [(124, 88)]], mira=-1),
        "Pelota escondida debajo de la mesa y niño asomándose con la mano levantada.")
    put("higher than the houses", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("House", 20, 42, 36) + fl("House", 104, 42, 36) + nino((80, 32), (80, 44), (80, 64), [[(68, 14)], [(94, 54)]], [[(74, 86)], [(86, 86)]]) + frecha((80, 28), (80, 10), ROJO, 2.2),
        "Casas pequeñas a los lados y brazo levantado mucho más alto que los tejados.")
    put("referee", "C",
        fondo_prado() + ico("mdi", "whistle", 28, 22, 44, NEGRO) + nino((104, 34), (104, 46), (104, 66), [[(88, 18)], [(116, 56)]], [[(98, 88)], [(110, 88)]], camisa=(GRIS_OSCURO, NEGRO)),
        "Silbato de árbitro y mano levantada marcando la señal.", "Apache-2.0")
    put("right-hand", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 66), [[(66, 56)], [(96, 18)]], [[(74, 88)], [(86, 88)]]) + frecha((104, 24), (128, 24), ROJO, 2.6),
        "Niño levantando bien clara la mano del lado derecho indicado con flecha.")
    put("traffic light", "C",
        fondo_sala() + fl("Vertical traffic light", 30, 16, 54) + nino((104, 34), (104, 46), (104, 66), [[(90, 18)], [(118, 56)]], [[(98, 88)], [(110, 88)]]),
        "Semáforo de luces y mano en alto imitando la señal de parar.")

    # ── Brazos abiertos en cruz (arms_wide — 42 concretas) ─────────────────
    put("arms", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 66), [[(50, 46)], [(110, 46)]], [[(74, 88)], [(86, 88)]]) + frecha((54, 34), (36, 34), ROJO, 2.2) + frecha((106, 34), (124, 34), ROJO, 2.2),
        "Niño abriendo los dos brazos rectos en cruz señalados hacia fuera.")
    put("arms out like a plane", "C",
        fondo_cielo() + fl("Airplane", 24, 18, 46) + nino((106, 36), (106, 48), (106, 66), [[(78, 42)], [(134, 54)]], [[(100, 86)], [(112, 86)]]),
        "Avión volando y niño inclinando sus brazos abiertos como alas.")
    put("bloom", "C",
        fondo_prado() + fl("Blossom", 26, 24, 46) + nino((104, 34), (104, 46), (104, 66), [[(80, 32)], [(128, 32)]], [[(98, 88)], [(110, 88)]]),
        "Flor abierta y niño desplegando los brazos hacia arriba como pétalos.")
    put("blooming", "C",
        fondo_prado() + fl("Hibiscus", 24, 22, 42) + fl("Sunflower", 96, 20, 44) + nino((80, 42), (80, 52), (80, 70), [[(56, 46)], [(104, 46)]], [[(74, 88)], [(86, 88)]]),
        "Flores abiertas coloridas y niño abriendo grande los brazos en el prado.")
    put("canopy", "C",
        fondo_prado() + fl("Deciduous tree", 24, 16, 56) + nino((104, 36), (104, 48), (104, 66), [[(84, 26), (94, 18)], [(124, 26), (114, 18)]], [[(98, 88)], [(110, 88)]]),
        "Árbol frondoso y niño curvando los brazos por encima imitando su copa.")
    put("classroom", "D",
        fondo_sala() + [R(34, 14, 92, 34, 2, VERDE_OSCURO, MADERA_OSCURA, 2.6)] + nino((80, 40), (80, 52), (80, 70), [[(54, 50)], [(106, 50)]], [[(74, 88)], [(86, 88)]]),
        "Pizarra verde del aula y niño abriendo los brazos dentro de la clase.")
    put("come here for a hug", "D",
        fondo_sala() + nino((50, 34), (50, 46), (50, 66), [[(30, 44)], [(70, 44)]], [[(44, 88)], [(56, 88)]]) + nino_caminando(114, 34, -1, camisa=(AZUL, AZUL_OSCURO)) + frecha((94, 26), (70, 26), ROJO, 2.2),
        "Niño esperando con los brazos abiertos a su amigo que se acerca.")
    put("cormorant", "D",
        fondo_mar() + [R(18, 66, 36, 18, 4, GRIS, GRIS_OSCURO, 2.0), E(36, 46, 7, 9, NEGRO), E(36, 33, 5, 5, NEGRO), P([(36, 32), (48, 33), (36, 36)], AMARILLO_OSCURO), P([(30, 44), (10, 34), (28, 52)], NEGRO), P([(42, 44), (62, 34), (44, 52)], NEGRO)] + sol(126, 18),
        "Cormorán oscuro posado en roca extendiendo sus alas para secarlas al sol.")
    put("dry wings", "C",
        fondo_prado() + fl("Sun", 64, 6, 32) + fl("Bird", 24, 34, 40) + nino((106, 36), (106, 48), (106, 66), [[(80, 44)], [(132, 44)]], [[(100, 88)], [(112, 88)]]),
        "Pájaro al sol y niño abriendo los brazos amplios para secar sus alas.")
    put("enormous", "D",
        fondo_sala() + [E(34, 54, 8, 8, AZUL, AZUL_OSCURO, 1.8), E(112, 48, 32, 32, ROJO, ROJO_OSCURO, 2.2)] + frecha((50, 50), (74, 50), VERDE_OSCURO, 2.4),
        "Comparación visual de un círculo pequeño frente a una esfera enorme.")
    put("float on top", "D",
        fondo_mar() + [R(50, 54, 52, 12, 5, ROJO, ROJO_OSCURO, 2.0), E(110, 58, 7.5, 7.5, PEL, PELB, 2.0), L("M64 56 L50 38", PELB, 3.8), L("M64 56 L50 38", PEL, 2.2), L("M78 56 L92 38", PELB, 3.8), L("M78 56 L92 38", PEL, 2.2)],
        "Niño flotando boca arriba en la superficie del agua con los brazos abiertos.")
    put("good morning, sun", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Sunrise", 22, 16, 48) + nino((104, 34), (104, 46), (104, 66), [[(80, 40)], [(128, 40)]], [[(98, 88)], [(110, 88)]]),
        "Amanecer luminoso y niño abriendo los brazos sonriente dando los buenos días al sol.")
    put("grow bigger", "D",
        fondo_prado() + [E(28, 72, 5, 5, VERDE, VERDE_OSCURO, 1.8), E(56, 64, 9, 9, VERDE, VERDE_OSCURO, 1.8)] + nino((108, 32), (108, 44), (108, 64), [[(82, 42)], [(134, 42)]], [[(102, 88)], [(114, 88)]]) + frecha((36, 44), (82, 24), ROJO, 2.4),
        "Tamaño que va creciendo paso a paso hasta abrir los brazos muy grandes.")
    put("happy", "C",
        fondo_prado() + fl("Sun", 104, 14, 36) + nino((74, 34), (74, 46), (74, 66), [[(50, 40)], [(98, 40)]], [[(68, 88)], [(80, 88)]], camisa=(AMARILLO, AMARILLO_OSCURO)),
        "Niño feliz con gran sonrisa abriendo alegremente los brazos bajo el sol.")
    put("have a nice summer", "C",
        fondo_mar() + fl("Beach with umbrella", 24, 22, 48) + fl("Sun", 112, 14, 32) + nino((86, 36), (86, 48), (86, 66), [[(64, 44)], [(108, 44)]], [[(80, 88)], [(92, 88)]]),
        "Playa de verano con sombrilla y sol mientras el niño abre los brazos contento.")
    put("hover", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Eagle", 26, 12, 46) + nino((106, 36), (106, 48), (106, 66), [[(80, 44)], [(132, 44)]], [[(100, 88)], [(112, 88)]]),
        "Águila cerniéndose quieta en lo alto con las alas abiertas igual que el niño.")
    put("meadow", "C",
        fondo_prado() + fl("Blossom", 22, 54, 26) + fl("Butterfly", 112, 16, 32) + nino((78, 34), (78, 46), (78, 66), [[(54, 44)], [(102, 44)]], [[(72, 88)], [(84, 88)]]),
        "Prado verde lleno de flores y mariposa con niño abriendo los brazos.")
    put("merry christmas", "C",
        fondo_sala() + fl("Christmas tree", 24, 14, 56) + nino((104, 34), (104, 46), (104, 66), [[(80, 44)], [(128, 44)]], [[(98, 88)], [(110, 88)]]),
        "Árbol de Navidad iluminado y niño con los brazos abiertos deseando alegría.")
    put("mother bird", "C",
        fondo_prado() + fl("Bird", 26, 18, 42) + [E(92, 66, 26, 10, BARRO, MADERA_OSCURA, 2.0)] + fl("Hatching chick", 78, 36, 30) + nino((124, 34), (124, 46), (124, 66), [[(98, 44)], [(144, 44)]], [[(118, 88)], [(130, 88)]]),
        "Mamá pájaro protegiendo su nido con los brazos extendidos como alas.")
    put("nature", "C",
        fondo_prado() + fl("Mountain", 20, 18, 44) + fl("Deciduous tree", 102, 18, 46) + nino((74, 34), (74, 46), (74, 66), [[(52, 44)], [(96, 44)]], [[(68, 88)], [(80, 88)]]),
        "Montaña, árbol y niño respirando el aire libre con los brazos abiertos.")
    put("ocean", "C",
        fondo_mar() + fl("Water wave", 24, 24, 48) + fl("Whale", 86, 24, 50),
        "Gran océano azul abierto mostrado por las olas extensas y la ballena.")
    put("on the farm", "C",
        fondo_prado() + [R(64, 24, 34, 34, 2, ROJO, ROJO_OSCURO, 2.0), P([(60, 26), (81, 12), (102, 26)], ROJO_OSCURO)] + fl("Cow", 22, 34, 42) + fl("Pig", 104, 36, 40),
        "Granja roja con vaca y cerdito al aire libre.")
    put("once upon a time", "C",
        fondo_sala() + fl("Open book", 28, 26, 48) + fl("Castle", 92, 18, 48),
        "Libro abierto de cuentos donde empieza la historia del castillo.")
    put("park", "C",
        fondo_prado() + fl("Playground slide", 24, 22, 46) + fl("Deciduous tree", 96, 18, 48),
        "Parque infantil amplio con tobogán y árbol verde.")
    put("proud peacock", "C",
        fondo_prado() + fl("Peacock", 26, 18, 52) + nino((104, 34), (104, 46), (104, 66), [[(80, 42)], [(128, 42)]], [[(98, 88)], [(110, 88)]]),
        "Pavo real desplegando su cola en abanico igual que los brazos abiertos.")
    put("sail", "C",
        fondo_mar() + fl("Sailboat", 28, 18, 50) + nino((106, 36), (106, 48), (106, 66), [[(84, 44)], [(128, 44)]], [[(100, 88)], [(112, 88)]]),
        "Velero navegando con la vela desplegada y brazos abiertos al viento.")
    put("scarecrow", "D",
        fondo_prado() + [R(77, 40, 6, 46, 1, MADERA_OSCURA), L("M46 46 L114 46", MADERA_OSCURA, 3.6), R(68, 40, 24, 26, 3, NARANJA, NARANJA_OSCURO, 1.8), E(80, 28, 8, 8, "#fde68a", BARRO, 1.8), P([(68, 22), (80, 12), (92, 22)], BARRO)],
        "Espantapájaros con sombrero de paja y brazos rígidos abiertos en cruz.")
    put("seagull", "C",
        fondo_mar() + [R(12, 72, 58, 28, 0, TIERRA_CLARA, BARRO, 1.4), F("M62 24 Q74 12 86 24 Q98 12 110 24 Q98 18 86 26 Q74 18 62 24 Z", BLANCO, NEGRO, 2.4)] + fl("Water wave", 96, 36, 44) + nino((40, 36), (40, 48), (40, 66), [[(18, 42)], [(62, 42)]], [[(34, 86)], [(46, 86)]]),
        "Gaviota blanca planeando sobre las olas del mar con alas abiertas.")
    put("shine", "C",
        fondo_cielo() + fl("Sun", 52, 16, 56) + [L("M42 26 L28 14", AMARILLO_OSCURO, 2.4), L("M118 26 L132 14", AMARILLO_OSCURO, 2.4), L("M42 64 L28 76", AMARILLO_OSCURO, 2.4), L("M118 64 L132 76", AMARILLO_OSCURO, 2.4)],
        "Sol radiante abriendo sus rayos dorados brillantes en todas direcciones.")
    put("shine like the sun", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Sun", 24, 14, 46) + nino((104, 34), (104, 46), (104, 66), [[(80, 36)], [(128, 36)]], [[(98, 88)], [(110, 88)]], camisa=(AMARILLO, AMARILLO_OSCURO)),
        "Sol brillante y niño abriendo de golpe los brazos como rayos de luz.")
    put("show big arms", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 66), [[(44, 46)], [(116, 46)]], [[(74, 88)], [(86, 88)]]) + frecha((46, 30), (22, 30), ROJO, 2.4) + frecha((114, 30), (138, 30), ROJO, 2.4),
        "Niño mostrando los brazos extendidos todo lo ancho posible.")
    put("so many bubbles", "C",
        fondo_cielo() + fl("Bubbles", 20, 14, 42) + pompas([(68, 20, 6), (82, 14, 5), (96, 18, 4), (72, 34, 4)]) + nino((114, 40), (114, 50), (114, 68), [[(92, 44)], [(136, 44)]], [[(108, 88)], [(120, 88)]]),
        "Montón de burbujas flotando por todo el aire y niño abriendo los brazos asombrado.")
    put("space", "C",
        fondo_noite() + fl("Ringed planet", 22, 16, 46) + fl("Rocket", 92, 18, 48) + [E(80, 16, 2, 2, BLANCO), E(72, 68, 2, 2, BLANCO), E(138, 66, 2, 2, BLANCO)],
        "Espacio exterior con planeta con anillos y cohete flotando entre estrellas.")
    put("sun-soaked", "C",
        fondo_mar() + fl("Sun", 24, 14, 44) + [L("M56 36 L78 44", AMARILLO_OSCURO, 2.2), L("M56 50 L76 54", AMARILLO_OSCURO, 2.2)] + nino((104, 34), (104, 46), (104, 66), [[(82, 40)], [(126, 40)]], [[(98, 88)], [(110, 88)]]),
        "Rayos cálidos bañando al niño con brazos abiertos al sol.")
    put("sunny", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Sun", 104, 12, 38) + nino((52, 34), (52, 46), (52, 66), [[(32, 42)], [(72, 42)]], [[(46, 88)], [(58, 88)]]),
        "Día despejado y muy soleado con brazos abiertos hacia la luz.")
    put("symmetrical", "D",
        fondo_sala() + [L("M80 12 L80 90", ROJO, 2.0)] + [P([(30, 50), (46, 36), (46, 64)], AZUL, AZUL_OSCURO, 2.0), P([(130, 50), (114, 36), (114, 64)], AZUL, AZUL_OSCURO, 2.0)] + nino((80, 34), (80, 46), (80, 66), [[(54, 46)], [(106, 46)]], [[(74, 88)], [(86, 88)]]),
        "Eje central de simetría con figuras idénticas a izquierda y derecha.")
    put("tree", "C",
        fondo_prado() + fl("Deciduous tree", 24, 14, 56) + nino((104, 34), (104, 46), (104, 66), [[(82, 34)], [(126, 34)]], [[(98, 88)], [(110, 88)]], camisa=(VERDE, VERDE_OSCURO)),
        "Árbol frondoso y niño erguido con brazos abiertos como sus ramas.")
    put("welcome", "C",
        fondo_sala() + fl("Door", 24, 18, 52) + nino((104, 34), (104, 46), (104, 66), [[(80, 44)], [(128, 44)]], [[(98, 88)], [(110, 88)]]),
        "Puerta abierta recibiendo con los brazos extendidos en bienvenida.")
    put("white sail", "D",
        fondo_mar() + [P([(46, 70), (114, 70), (102, 84), (58, 84)], AZUL, AZUL_OSCURO, 2.0), L("M80 18 L80 70", MADERA_OSCURA, 2.8), P([(80, 20), (80, 64), (114, 64)], BLANCO, GRIS_OSCURO, 2.0), P([(78, 28), (78, 64), (56, 64)], BLANCO, GRIS_OSCURO, 1.8)],
        "Vela triangular blanca bien desplegada sobre el barco en el agua.")
    put("wider", "D",
        fondo_sala() + [R(26, 34, 24, 28, 3, AZUL, AZUL_OSCURO, 2.0), R(86, 34, 52, 28, 3, VERDE, VERDE_OSCURO, 2.0)] + frecha((54, 48), (80, 48), ROJO, 2.4) + frecha((94, 24), (134, 24), ROJO, 2.2),
        "Comparación visual de un rectángulo estrecho frente a otro más ancho.")
    put("wings", "C",
        fondo_cielo() + fl("Wing", 24, 22, 44) + fl("Wing", 92, 22, 44, flip_x=True),
        "Par de alas blancas grandes desplegadas a ambos lados.")
    put("look at all the lights", "C",
        fondo_noite() + [L("M16 32 Q80 48 144 32", GRIS, 2.0), E(32, 37, 6, 6, ROJO), E(56, 40, 6, 6, AMARILLO), E(80, 42, 6, 6, VERDE), E(104, 40, 6, 6, AGUA), E(128, 37, 6, 6, ROSA)] + nino((80, 56), (80, 66), (80, 82), [[(60, 58)], [(100, 58)]], [[(76, 94)], [(84, 94)]], r=7.0),
        "Guirnalda de bombillas de colores encendidas en la noche admirada con brazos abiertos.")

    # ── Saludar / mover la mano (wave — 31 escenas + 1 directa) ───────────
    put("ahoy, pirates", "C",
        fondo_mar() + fl("Pirate flag", 24, 18, 46) + nino((104, 34), (104, 46), (104, 66), [[(98, 28)], [(118, 56)]], [[(98, 88)], [(110, 88)]]),
        "Bandera pirata y niño haciendo saludo marinero en la frente.")
    put("air", "C",
        fondo_cielo() + fl("Wind face", 28, 20, 44) + lineas_viento(80, 38, 44, AZUL_OSCURO),
        "Corriente invisible de aire mostrada por ráfagas limpias en el cielo.")
    put("bye for now", "C",
        fondo_sala() + fl("Door", 24, 16, 56) + nino((104, 34), (104, 46), (104, 66), [[(86, 30)], [(118, 56)]], [[(98, 88)], [(110, 88)]]) + [L("M78 24 Q82 18 88 22", ROJO, 1.8)],
        "Niño saliendo por la puerta mientras agita la mano diciendo hasta luego.")
    put("bye-bye, boat", "C",
        fondo_mar() + fl("Sailboat", 24, 18, 50) + nino((106, 34), (106, 46), (106, 66), [[(88, 28)], [(120, 56)]], [[(100, 88)], [(112, 88)]]) + [L("M80 22 Q86 16 92 22", ROJO, 1.8)],
        "Barco navegando y niño en la orilla diciendo adiós con la mano.")
    put("bye-bye, friends", "D",
        fondo_prado() + nino((42, 34), (42, 46), (42, 66), [[(28, 56)], [(56, 28)]], [[(36, 88)], [(48, 88)]]) + nino_caminando(96, 34, 1, camisa=(AZUL, AZUL_OSCURO)) + nino_caminando(124, 34, 1, camisa=(VERDE, VERDE_OSCURO)) + frecha((70, 26), (92, 26), ROJO, 2.0),
        "Niño despidiéndose agitando la mano mientras sus amigos se alejan.")
    put("carnival float", "C",
        fondo_prado() + nino_busto(78, 28, brazos_arriba=True) + [R(26, 52, 108, 24, 4, MORADO, "#5b21b6", 2.0), E(46, 78, 9, 9, NEGRO), E(112, 78, 9, 9, NEGRO)] + fl("Balloon", 28, 12, 34) + fl("Confetti ball", 104, 14, 32),
        "Carroza colorida de fiesta con globos y niño saludando encima de ella.")
    put("creamy", "D",
        fondo_mesa() + [E(76, 60, 32, 15, BLANCO, GRIS_OSCURO, 2.0), E(76, 54, 28, 10, "#fef3c7", BARRO, 1.8), L("M76 50 L96 22", MADERA_OSCURA, 3.0)] + arco_giro(76, 32, 14, AZUL_OSCURO),
        "Crema suave blanca en cuenco removida despacio en círculos con cuchara.")
    put("depart", "C",
        fondo_prado() + fl("Bus", 22, 28, 48) + frecha((26, 20), (62, 20), ROJO, 2.4) + nino((108, 34), (108, 46), (108, 66), [[(90, 28)], [(122, 56)]], [[(102, 88)], [(114, 88)]]),
        "Autobús saliendo en marcha mientras se dice adiós desde la acera.")
    put("downstream", "D",
        fondo_mar() + [L("M16 26 Q80 48 144 74", "#7dd3fc", 16.0), L("M16 26 Q80 48 144 74", AGUA_OSCURO, 2.2)] + frecha((36, 16), (114, 48), ROJO, 2.8),
        "Corriente azul de río bajando cuesta abajo con dirección clara hacia abajo.")
    put("floating", "C",
        fondo_cielo() + fl("Balloon", 30, 18, 44) + fl("Feather", 92, 22, 42) + [L("M88 68 Q112 62 134 68", AZUL_OSCURO, 1.8)],
        "Globo y pluma ligera flotando suavemente suspendidos en el aire.")
    put("floating boat", "C",
        fondo_mar() + fl("Sailboat", 52, 18, 56) + [L("M24 72 Q52 66 80 72 Q108 78 136 72", AZUL_OSCURO, 2.4)],
        "Barquito de vela flotando meciéndose sobre ondas tranquilas de agua.")
    put("from light to dark", "D",
        fondo_sala() + [R(22, 30, 26, 40, 3, "#fef9c3", BARRO, 1.8), R(52, 30, 26, 40, 3, "#fde047", BARRO, 1.8), R(82, 30, 26, 40, 3, "#64748b", NEGRO, 1.8), R(112, 30, 26, 40, 3, "#1e293b", NEGRO, 1.8)] + frecha((26, 20), (134, 20), ROJO, 2.4),
        "Gradación visual continua desde el tono más claro luminoso al más oscuro.")
    put("good night", "C",
        fondo_noite() + fl("Crescent moon", 24, 14, 36) + nino_busto(84, 34, ojos="cerrados") + [R(50, 62, 68, 22, 6, MORADO, "#5b21b6", 1.8)],
        "Luna nocturna y niño arropado con ojos cerrados diciendo buenas noches.")
    put("grandpa", "C",
        fondo_sala() + ico("healthicons", "cane", 26, 26, 44, MADERA_OSCURA) + nino((86, 28), (86, 40), (86, 62), [[(70, 24)], [(100, 52)]], [[(80, 86)], [(92, 86)]], camisa=(GRIS, GRIS_OSCURO), pelo="#cbd5e1", r=9.0) + [E(82, 27, 2.6, 2.6, None, NEGRO, 1.2), E(90, 27, 2.6, 2.6, None, NEGRO, 1.2), L("M85 27 L87 27", NEGRO, 1.2)],
        "Abuelo canoso con gafas y bastón levantando la mano en saludo cariñoso.", "MIT")
    put("grate", "C",
        fondo_mesa() + fl("Cheese wedge", 34, 16, 40) + [R(76, 28, 30, 42, 3, GRIS, GRIS_OSCURO, 2.0), E(85, 42, 2, 2, NEGRO), E(97, 42, 2, 2, NEGRO), E(91, 52, 2, 2, NEGRO), E(85, 76, 3, 2, AMARILLO_OSCURO), E(96, 78, 3, 2, AMARILLO_OSCURO)] + frecha((118, 26), (118, 56), ROJO, 2.2),
        "Queso moviéndose arriba y abajo sobre rallador metálico soltando virutas.")
    put("hello, flower", "C",
        fondo_prado() + fl("Blossom", 28, 24, 46) + nino((104, 34), (104, 46), (104, 66), [[(86, 28)], [(118, 56)]], [[(98, 88)], [(110, 88)]]) + [L("M78 22 Q84 16 90 22", ROJO, 1.8)],
        "Niño agitado saludando con una sonrisa a la flor del prado.")
    put("hello, sun", "C",
        fondo_cielo() + [R(0, 74, 160, 26, 0, HERBA)] + fl("Sun", 24, 10, 42) + nino((102, 34), (102, 46), (102, 66), [[(84, 24)], [(116, 56)]], [[(96, 88)], [(108, 88)]]),
        "Sol alto y niño saludándolo hacia arriba con la mano contenta.")
    put("neighbour", "C",
        fondo_prado() + fl("House", 16, 22, 40) + fl("House", 104, 22, 40) + nino((62, 38), (62, 50), (62, 68), [[(74, 34)], [(52, 56)]], [[(58, 86)], [(66, 86)]], r=7.5) + nino((96, 38), (96, 50), (96, 68), [[(84, 34)], [(106, 56)]], [[(92, 86)], [(100, 86)]], camisa=(AZUL, AZUL_OSCURO), r=7.5),
        "Dos vecinos en casas contiguas saludándose alegres de ventana a puerta.")
    put("say goodbye", "C",
        fondo_sala() + fl("Door", 102, 18, 52) + nino((52, 34), (52, 46), (52, 66), [[(38, 56)], [(68, 26)]], [[(46, 88)], [(58, 88)]]) + [L("M66 18 Q74 14 78 22", ROJO, 1.8)],
        "Niño junto a la puerta agitando la mano para despedirse.")
    put("say hello", "D",
        fondo_sala() + nino((52, 34), (52, 46), (52, 66), [[(68, 28)], [(38, 56)]], [[(46, 88)], [(58, 88)]], mira=1) + nino((108, 34), (108, 46), (108, 66), [[(92, 28)], [(122, 56)]], [[(102, 88)], [(114, 88)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Dos amigos frente a frente levantando la mano para decir hola.")
    put("stream", "D",
        fondo_prado() + [L("M24 20 Q56 42 40 60 Q28 76 76 88", AGUA, 12.0), L("M24 20 Q56 42 40 60 Q28 76 76 88", AGUA_OSCURO, 2.0)] + nino((112, 36), (112, 48), (112, 66), [[(92, 44)], [(126, 56)]], [[(106, 86)], [(118, 86)]]),
        "Arroyo serpenteante de agua clara siguiendo su cauce suave.")
    put("tail-wagging", "C",
        fondo_prado() + fl("Dog", 36, 26, 50) + [L("M94 42 Q108 36 110 48", ROJO, 2.2), L("M100 34 Q116 28 118 44", ROJO, 2.0)],
        "Perro contento moviendo el rabo de un lado a otro con ondas.")
    put("thank you, firefighter", "C",
        fondo_sala() + fl("Fire engine", 22, 26, 52) + nino((106, 34), (106, 46), (106, 66), [[(88, 28)], [(120, 56)]], [[(100, 88)], [(112, 88)]]),
        "Camión de bomberos rojo y niño saludando agradecido con la mano.")
    put("thank you, lúa", "C",
        fondo_sala() + fl("Wolf", 26, 24, 48) + nino((104, 34), (104, 46), (104, 66), [[(86, 28)], [(118, 56)]], [[(98, 88)], [(110, 88)]]),
        "Lobito Lúa y niño agitando la mano alegremente dándole las gracias.")
    put("the river runs into the sea", "D",
        fondo_mar() + [R(0, 50, 82, 50, 0, HERBA), L("M14 50 Q48 56 82 64", AGUA, 14.0), L("M14 50 Q48 56 82 64", AGUA_OSCURO, 2.0)] + frecha((30, 34), (102, 54), ROJO, 2.6),
        "Río azul serpenteante desembocando amplio en las aguas del mar.")
    put("tidal", "C",
        fondo_mar() + fl("Water wave", 48, 20, 54) + frecha((26, 66), (52, 66), ROJO, 2.4) + frecha((134, 66), (108, 66), ROJO, 2.4),
        "Oleaje azul yendo y viniendo en el vaivén de las mareas.")
    put("upstream", "C",
        fondo_mar() + [L("M16 74 Q80 54 144 28", "#7dd3fc", 16.0), L("M16 74 Q80 54 144 28", AGUA_OSCURO, 2.2)] + fl("Tropical fish", 88, 36, 36) + frecha((118, 24), (48, 42), ROJO, 2.6),
        "Corriente que baja mientras el pez sube río arriba a contracorriente.")
    put("wave", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 66), [[(58, 24)], [(94, 56)]], [[(74, 88)], [(86, 88)]]) + [L("M48 20 Q56 12 64 18", ROJO, 2.0), L("M64 26 Q72 20 74 28", ROJO, 2.0)],
        "Niño levantando y agitando su mano de un lado a otro para saludar.")
    put("wave and smile", "C",
        fondo_sala() + nino((58, 34), (58, 46), (58, 66), [[(46, 56)], [(70, 56)]], [[(52, 88)], [(64, 88)]], camisa=(AMARILLO, AMARILLO_OSCURO)) + fl("Waving hand", 92, 24, 44),
        "Niño sonriendo ampliamente junto a una mano abierta saludando.")
    put("wave your graduation cap", "C",
        fondo_sala() + nino((62, 36), (62, 48), (62, 68), [[(86, 28)], [(48, 56)]], [[(56, 88)], [(68, 88)]]) + fl("Graduation cap", 82, 10, 36) + [L("M116 14 Q124 22 118 32", ROJO, 2.0)],
        "Niño sosteniendo en alto y agitando alegre el birrete en el aire.")
    put("winding", "D",
        fondo_prado() + [L("M24 72 Q46 28 74 54 Q102 80 132 30", TIERRA_CLARA, 10.0), L("M24 72 Q46 28 74 54 Q102 80 132 30", BARRO, 2.0)] + [L("M24 58 Q46 18 74 42 Q102 68 128 20", ROJO, 2.2), P([(120, 20), (132, 16), (128, 28)], ROJO)],
        "Camino sinuoso en curvas en zigzag marcado por el campo.")

    # ── Equilibrio, cuclillas y giro (balance, crouch, spin — completos) ───
    put("foot", "D",
        fondo_sala() + nino((80, 32), (80, 44), (80, 62), [[(64, 52)], [(96, 58)]], [[(76, 86)], [(92, 68)]]) + frecha((116, 70), (98, 70), ROJO, 2.4),
        "Niño en equilibrio sobre una pierna sujetándose el pie trasero con la mano.")
    put("in the bath", "C",
        fondo_sala() + fl("Bathtub", 48, 20, 58) + pompas([(58, 24, 5), (76, 18, 6), (92, 24, 4)]) + frecha((26, 36), (48, 48), AZUL_OSCURO, 2.4),
        "Bañera blanca llena de espuma donde se entra levantando un pie.")
    put("tree pose", "D",
        fondo_prado() + nino((80, 32), (80, 44), (80, 62), [[(74, 16)], [(86, 16)]], [[(80, 86)], [(92, 68), (82, 72)]], camisa=(VERDE, VERDE_OSCURO)),
        "Postura de equilibrio sobre un pie con el otro doblado contra la rodilla.")
    put("squat", "D",
        fondo_prado() + nino((80, 46), (80, 58), (80, 74), [[(66, 62)], [(94, 62)]], [[(68, 74), (72, 88)], [(92, 74), (88, 88)]]) + frecha((112, 34), (112, 64), AZUL_OSCURO, 2.6),
        "Niño agachado en cuclillas doblando profundamente ambas rodillas.")
    put("inside out", "C",
        fondo_sala() + fl("T-shirt", 24, 24, 44) + arco_giro(80, 48, 13, ROJO) + fl("T-shirt", 96, 24, 44, flip_x=True) + [R(115, 28, 6, 4, 1, BLANCO, GRIS_OSCURO, 1.2), L("M111 36 L111 64", BLANCO, 1.5), L("M125 36 L125 64", BLANCO, 1.5)],
        "Camiseta girada mostrando etiqueta y costuras del revés.")

    # ── Acciones con agua (water_action — primeras 46 escenas + 1 directa) ─
    put("blow bubbles in water", "D",
        fondo_mesa() + [R(42, 48, 76, 28, 8, AGUA, AGUA_OSCURO, 2.2), L("M78 48 L96 18", ROJO, 3.2)] + pompas([(68, 38, 6), (82, 34, 7), (74, 24, 5)]),
        "Pajita metida en el recipiente de agua soltando pompas de aire.")
    put("bubbly water", "C",
        fondo_mesa() + fl("Cup with straw", 42, 18, 52) + pompas([(82, 46, 5), (94, 34, 6), (104, 48, 4), (88, 22, 4)]),
        "Vaso de agua fresca lleno de burbujitas subiendo hasta arriba.")
    put("can you swim", "D",
        fondo_mar() + [R(50, 56, 46, 11, 5, AZUL, AZUL_OSCURO, 2.0), E(104, 60, 7.5, 7.5, PEL, PELB, 2.0), L("M82 54 L96 42", PELB, 3.6), L("M82 54 L96 42", PEL, 2.0), L("M56 54 L40 42", PELB, 3.6), L("M56 54 L40 42", PEL, 2.0)] + [L("M24 72 Q52 66 80 72 Q108 78 136 72", AGUA_OSCURO, 2.2)],
        "Niño nadando en el mar dando brazadas hacia delante.")
    put("close", "C",
        fondo_cielo() + fl("Closed umbrella", 52, 16, 56) + frecha((30, 46), (52, 46), ROJO, 2.4) + frecha((130, 46), (108, 46), ROJO, 2.4),
        "Paraguas plegado cerrándose con flechas hacia dentro.")
    put("cool down", "C",
        fondo_prado() + fl("Droplet", 28, 22, 36) + fl("Sun", 104, 14, 34) + nino((74, 34), (74, 46), (74, 66), [[(68, 30)], [(88, 56)]], [[(68, 88)], [(80, 88)]]),
        "Gota de agua fresca aplicada en la nuca y frente para quitar el calor.")
    put("cork", "D",
        fondo_mesa() + [R(38, 34, 84, 44, 4, "#e0f2fe", AGUA_OSCURO, 2.0), R(40, 48, 80, 28, 2, AGUA), R(68, 38, 24, 14, 3, TIERRA_CLARA, MADERA_OSCURA, 2.0)],
        "Tapón de corcho ligero flotando arriba en la superficie del agua.")
    put("current", "D",
        fondo_mar() + [L("M20 44 Q52 36 80 44 Q108 52 140 44", AGUA_OSCURO, 2.6), L("M20 62 Q52 54 80 62 Q108 70 140 62", AGUA_OSCURO, 2.6)] + frecha((34, 24), (126, 24), ROJO, 2.6),
        "Corriente continua de agua fluyendo con fuerza en una sola dirección.")
    put("deep", "D",
        fondo_mar() + [R(0, 46, 160, 54, 0, MAR_PROF)] + frecha((80, 18), (80, 88), AMARILLO, 3.2),
        "Fondo marino muy hondo con flecha vertical descendiendo hasta lo profundo.")
    put("deliver", "C",
        fondo_sala() + fl("Package", 26, 26, 44) + nino((102, 34), (102, 46), (102, 66), [[(78, 46)], [(116, 56)]], [[(96, 88)], [(108, 88)]]) + frecha((72, 24), (106, 24), VERDE_OSCURO, 2.4),
        "Paquete entregado hacia delante sosteniendo la caja con las dos manos.")
    put("dip", "D",
        fondo_mesa() + [R(36, 52, 88, 28, 6, AGUA, AGUA_OSCURO, 2.2), E(77, 22, 11, 6, PEL, PELB, 1.8), L("M73 25 L73 56", PELB, 4.0), L("M73 25 L73 56", PEL, 2.2), L("M81 25 L81 56", PELB, 4.0), L("M81 25 L81 56", PEL, 2.2)] + frecha((104, 24), (104, 48), ROJO, 2.2),
        "Dedos bajando para mojarse brevemente dentro del agua del recipiente.")
    put("diver", "C",
        fondo_mar() + [R(0, 26, 160, 74, 0, MAR_PROF)] + fl("Goggles", 48, 24, 40) + pompas([(96, 36, 5), (104, 22, 6), (90, 14, 4)]),
        "Gafas de buceo sumergidas bajo el mar soltando burbujas hacia arriba.")
    put("doll clothes", "C",
        fondo_sala() + fl("T-shirt", 24, 24, 38) + [R(64, 50, 56, 24, 5, AGUA, AGUA_OSCURO, 2.2)] + fl("Soap", 104, 22, 36),
        "Camiseta pequeña lavada con jabón dentro de un barreño de agua.")
    put("drain", "D",
        fondo_prado() + [R(48, 58, 64, 24, 3, GRIS, GRIS_OSCURO, 2.2), L("M56 64 L56 76", NEGRO, 2.4), L("M68 64 L68 76", NEGRO, 2.4), L("M80 64 L80 76", NEGRO, 2.4), L("M92 64 L92 76", NEGRO, 2.4), L("M104 64 L104 76", NEGRO, 2.4)] + gotas([(66, 30), (80, 36), (94, 30)]) + frecha((80, 14), (80, 52), AGUA_OSCURO, 2.6),
        "Rejilla metálica de alcantarilla por donde escurre hacia abajo el agua.")
    put("drink", "C",
        fondo_mesa() + fl("Cup with straw", 42, 26, 42) + nino((100, 34), (100, 46), (100, 66), [[(74, 42)], [(114, 56)]], [[(94, 88)], [(106, 88)]]),
        "Vaso acercado a los labios para beber un sorbo refrescante de agua.")
    put("drippy", "C",
        fondo_mesa() + fl("Sponge", 54, 14, 50) + gotas([(64, 66), (80, 72), (96, 66)]),
        "Esponja amarilla empapada dejando caer gotitas azules hacia abajo.")
    put("fill up", "D",
        fondo_mesa() + [R(46, 36, 42, 42, 4, "#e0f2fe", AGUA_OSCURO, 2.2), R(48, 52, 38, 24, 2, AGUA)] + [L("M106 16 L84 44", AGUA, 4.0)] + frecha((67, 74), (67, 40), ROJO, 2.2),
        "Vaso transparente llenándose con chorro de agua hasta arriba.")
    put("from cup to cup", "D",
        fondo_mesa() + [R(32, 32, 26, 30, 3, AZUL, AZUL_OSCURO, 2.0), R(102, 48, 26, 30, 3, AGUA, AGUA_OSCURO, 2.0), L("M56 36 Q88 22 115 48", AGUA, 3.6)] + frecha((64, 18), (98, 18), ROJO, 2.2),
        "Agua trasvasada pasando en chorro desde un vaso al otro.")
    put("gargle", "D",
        fondo_sala() + nino((80, 36), (80, 48), (80, 68), [[(68, 52)], [(92, 52)]], [[(74, 88)], [(86, 88)]]) + pompas([(78, 20, 4), (86, 16, 5), (72, 14, 3)]) + ondas_sonido(100, 34, AGUA_OSCURO, 1),
        "Cabeza un poco inclinada hacia atrás haciendo burbujitas y gárgaras.")
    put("gutter", "D",
        fondo_cielo() + [P([(20, 44), (62, 18), (94, 44)], ROJO_OSCURO), R(22, 44, 70, 34, 0, "#fef3c7", MADERA_OSCURA, 1.8), L("M92 44 L106 44 L106 84", GRIS_OSCURO, 4.0)] + gotas([(106, 56), (106, 70)]) + frecha((120, 42), (120, 80), AGUA_OSCURO, 2.4),
        "Canalón del tejado conduciendo el agua de lluvia hacia abajo.")
    put("if we pick up plastic, fish are safer", "C",
        fondo_mar() + fl("Tropical fish", 22, 34, 44) + [R(78, 44, 14, 24, 4, "#bae6fd", AZUL_OSCURO, 2.0), R(82, 38, 6, 6, 1, ROJO, ROJO_OSCURO, 1.6)] + nino((122, 34), (122, 46), (122, 66), [[(90, 48)], [(134, 56)]], [[(116, 86)], [(128, 86)]], mira=-1),
        "Recogiendo botella de plástico del mar para que naden seguros los peces.")
    put("juice in a cup", "C",
        fondo_mesa() + fl("Beverage box", 26, 20, 44) + [R(84, 36, 34, 40, 3, "#fef3c7", NARANJA_OSCURO, 2.0), R(86, 50, 30, 24, 1, NARANJA)] + frecha((68, 30), (92, 34), NARANJA_OSCURO, 2.2),
        "Zumo naranja servido en un vaso listo para beber.")
    put("kick water", "D",
        fondo_mar() + [R(22, 58, 116, 26, 4, AGUA, AGUA_OSCURO, 2.0)] + nino((80, 24), (80, 36), (80, 52), [[(66, 44)], [(94, 44)]], [[(70, 74)], [(92, 66)]]) + gotas([(56, 54), (104, 54)]),
        "Niño pataleando alegremente dentro del agua salpicando gotitas.")
    put("leaky", "D",
        fondo_mesa() + [R(58, 22, 44, 42, 4, AZUL, AZUL_OSCURO, 2.2), E(80, 62, 3, 3, NEGRO)] + gotas([(80, 70), (80, 82)]),
        "Recipiente con agujero en el fondo por donde gotea el agua abajo.")
    put("lukewarm", "D",
        fondo_mesa() + [R(36, 48, 88, 30, 6, AGUA, AGUA_OSCURO, 2.2)] + [E(56, 20, 7, 7, AZUL, AZUL_OSCURO, 1.6), L("M58 22 L72 38 L78 54", PELB, 4.4), L("M58 22 L72 38 L78 54", PEL, 2.4)] + [L("M96 42 Q92 36 96 30", NARANJA, 1.8), L("M106 42 Q102 36 106 30", NARANJA, 1.8)],
        "Agua templada probada con cuidado metiendo la punta del codo.")
    put("marine life", "C",
        fondo_mar() + fl("Tropical fish", 20, 24, 38) + fl("Octopus", 62, 30, 40) + fl("Crab", 104, 38, 36),
        "Niños y niñas vivas del mar nadando juntas bajo el agua.")
    put("melted water", "C",
        fondo_mesa() + fl("Ice", 24, 24, 42) + frecha((70, 44), (88, 44), AZUL_OSCURO, 2.4) + charco_prop(118, 62, 24, 8),
        "Cubito de hielo derritiéndose hasta convertirse en charco de agua líquida.")
    put("oops, it spilled", "D",
        fondo_mesa() + [R(36, 42, 30, 20, 3, ROJO, ROJO_OSCURO, 2.0), E(66, 52, 4, 10, ROJO_OSCURO)] + [E(96, 64, 32, 9, AGUA, AGUA_OSCURO, 2.0)] + gotas([(72, 56)]),
        "Vaso volcado de lado dejando todo un charco de agua derramada.")
    put("paddle", "D",
        fondo_mar() + [R(22, 62, 116, 22, 6, AGUA, AGUA_OSCURO, 2.0)] + nino((80, 22), (80, 34), (80, 52), [[(66, 42)], [(94, 42)]], [[(72, 74)], [(88, 66)]]) + gotas([(60, 56), (100, 56)]),
        "Niño moviendo los pies sentado chapoteando en el agua poco profunda.")
    put("pipette", "C",
        fondo_mesa() + ico("mdi", "eyedropper", 54, 14, 46, AZUL_OSCURO) + gotas([(80, 64), (80, 76)]),
        "Pipeta cuentagotas dejando caer gotitas medidas una a una.", "Apache-2.0")
    put("plant a tree", "C",
        fondo_prado() + fl("Seedling", 34, 34, 40) + ico("mdi", "watering-can", 86, 18, 44, VERDE_OSCURO) + gotas([(78, 52), (74, 62)]),
        "Brote joven recién plantado en la tierra regándose con agua.", "Apache-2.0")
    put("postman", "C",
        fondo_prado() + fl("Envelope", 24, 26, 44) + nino((102, 34), (102, 46), (102, 66), [[(78, 44)], [(116, 56)]], [[(96, 88)], [(108, 88)]], camisa=(AZUL, AZUL_OSCURO)) + frecha((72, 24), (104, 24), ROJO, 2.2),
        "Cartero con uniforme azul repartiendo cartas de mano en mano.")
    put("pour it out", "D",
        fondo_mesa() + [L("M38 28 Q26 36 38 46", AZUL_OSCURO, 2.8), R(38, 22, 26, 32, 4, AZUL, AZUL_OSCURO, 2.0), L("M64 36 Q86 38 92 64", AGUA, 4.0), R(78, 62, 40, 18, 4, GRIS, GRIS_OSCURO, 2.0), E(98, 63, 18, 4, "#cbd5e1", GRIS_OSCURO, 1.6)],
        "Jarra inclinada vertiendo despacio el agua hacia el recipiente.")
    put("put up the umbrella", "C",
        fondo_cielo() + fl("Umbrella", 50, 14, 58) + frecha((30, 56), (30, 26), ROJO, 2.4) + frecha((130, 56), (130, 26), ROJO, 2.4),
        "Paraguas abriéndose hacia arriba de golpe para cubrirse.")
    put("rainwater", "C",
        fondo_cielo() + gotas([(48, 18), (74, 24), (96, 16), (62, 36), (86, 34)]) + [R(50, 48, 52, 34, 4, "#e0f2fe", AGUA_OSCURO, 2.2), R(52, 62, 48, 18, 2, AGUA)],
        "Gotas de lluvia cayendo directamente dentro del vaso abierto.")
    put("rinse", "D",
        fondo_sala() + [R(36, 16, 28, 10, 2, GRIS, GRIS_OSCURO, 2.0), R(53, 24, 7, 5, 1, GRIS, GRIS_OSCURO, 1.8), L("M56 29 L56 48", AGUA, 4.0)] + [E(50, 56, 10, 5, PEL, PELB, 1.8), E(64, 56, 10, 5, PEL, PELB, 1.8)] + gotas([(48, 68), (66, 68)]),
        "Manos abiertas pasándose bajo el chorro de agua del grifo.")
    put("rinse cup", "C",
        fondo_sala() + fl("Toothbrush", 24, 24, 42) + [R(82, 36, 36, 40, 4, "#e0f2fe", AGUA_OSCURO, 2.2), R(84, 52, 32, 22, 2, AGUA)],
        "Cepillo de dientes junto al vaso de agua limpia para enjuagar.")
    put("rinse off", "C",
        fondo_sala() + fl("Shower", 24, 14, 48) + gotas([(62, 40), (70, 52), (56, 56)]) + nino((106, 36), (106, 48), (106, 68), [[(92, 54)], [(120, 54)]], [[(100, 88)], [(112, 88)]]),
        "Chorro suave de ducha aclarando el agua por los hombros y espalda.")
    put("rinse off sand", "C",
        fondo_mar() + fl("Spiral shell", 48, 22, 48) + gotas([(64, 16), (80, 14), (96, 16)]) + [E(62, 74, 2, 2, TIERRA_CLARA), E(76, 76, 2, 2, TIERRA_CLARA), E(92, 74, 2, 2, TIERRA_CLARA)],
        "Concha de mar aclarada con chorritos quitando los granitos de arena.")
    put("rinse well", "D",
        fondo_sala() + [R(36, 14, 34, 10, 2, GRIS, GRIS_OSCURO, 2.0), R(59, 22, 7, 5, 1, GRIS, GRIS_OSCURO, 1.8), L("M62 27 L62 48", AGUA, 5.0)] + fl("Open hands", 44, 42, 40) + gotas([(38, 66), (88, 66)]),
        "Manos frotándose bien bajo chorro abundante de agua limpia.")
    put("rubber duck", "D",
        fondo_sala() + [R(30, 54, 100, 26, 6, AGUA, AGUA_OSCURO, 2.2)] + [E(80, 46, 14, 10, AMARILLO, AMARILLO_OSCURO, 2.0), E(88, 34, 8, 8, AMARILLO, AMARILLO_OSCURO, 2.0), P([(94, 33), (104, 35), (94, 38)], NARANJA), E(90, 32, 1.4, 1.4, NEGRO)],
        "Patito amarillo de goma flotando encima del agua del baño.")
    put("scrub", "C",
        fondo_sala() + fl("Soap", 28, 24, 42) + fl("Open hands", 82, 24, 48) + pompas([(72, 20, 5), (126, 22, 4), (78, 64, 5)]),
        "Manos enjabonadas restregando con fuerza haciendo espuma blanca.")
    put("shallow", "D",
        fondo_mar() + [R(0, 68, 160, 32, 0, "#fde68a", BARRO, 1.4), R(0, 62, 160, 10, 0, AGUA, AGUA_OSCURO, 1.6)] + nino((80, 20), (80, 32), (80, 50), [[(66, 38)], [(94, 38)]], [[(74, 68)], [(86, 68)]]),
        "Capa finita de agua poco profunda llegando solo a la punta de los pies.")
    put("sieve", "D",
        fondo_mesa() + [L("M114 46 L142 46", GRIS_OSCURO, 3.4), R(46, 40, 68, 14, 4, ROJO, ROJO_OSCURO, 2.0), L("M54 54 L106 54", GRIS_OSCURO, 2.2), L("M58 46 L102 46", NEGRO, 1.6)] + [E(68, 36, 4, 3, BARRO), E(90, 36, 4, 3, BARRO)] + gotas([(66, 64), (80, 72), (94, 64)]),
        "Colador con rejilla reteniendo piedrecitas mientras caen las gotas de agua.")
    put("sparkly water", "C",
        fondo_mar() + fl("Sun", 24, 12, 38) + [L("M24 62 Q60 54 96 62 Q122 68 144 62", "#bae6fd", 2.6)] + [E(62, 54, 4, 4, "#fde047"), E(94, 56, 3, 3, BLANCO), E(118, 52, 4, 4, "#fde047")],
        "Reflejos luminosos del sol brillando sobre la superficie del agua.")
    put("splashing", "D",
        fondo_mar() + [R(26, 56, 108, 26, 6, AGUA, AGUA_OSCURO, 2.0)] + [E(64, 50, 8, 5, PEL, PELB, 1.8), E(96, 50, 8, 5, PEL, PELB, 1.8)] + gotas([(46, 36), (56, 26), (104, 26), (114, 36)]),
        "Manos golpeando la superficie haciendo saltar gotas por todas partes.")
    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ─
SIN_BASE: dict[str, str] = {
    # arms_up (12 abstractas / exclamaciones puras)
    "accomplished": "Adjetivo evaluativo abstracto («Logrado»); indiscernible de celebrar o ganar sin texto.",
    "achievement": "Sustantivo abstracto («Logro»); indistinguible sin texto de triunfo o premio.",
    "brilliant": "Exclamación valorativa verbal («¡Genial!»); solo brazos arriba y voz sin referente visual propio.",
    "cheer": "Acción grupal genérica («Animar»); igual que «celebrate» o «cheering crowd» sin texto.",
    "hip, hip, hooray": "Vítores verbales rítmicos («¡Hip, hip, hurra!»); indiscernible sin texto.",
    "hooray for us": "Exclamación de grupo («¡Hurra por nosotros!»); sin imagen única diferenciable.",
    "i can do it": "Frase de autoestima abstracta («¡Puedo yo!»); depende por entero del texto.",
    "i'm ready for primary": "Expresión declarativa escolar («¡Estoy listo para Primaria!»); igual que brazos arriba genérico sin texto.",
    "joyful": "Adjetivo emocional abstracto («Gozoso»); redundante con «happy» y «glad».",
    "shout for joy": "Exclamación sonora sin objeto («Gritar de alegría»); brazos arriba idénticos a los demás.",
    "shout hooray": "Exclamación verbal («Gritar hurra»); indistinguible sin texto.",
    "we did it": "Exclamación colectiva genérica («¡Lo conseguimos!»); sin marca visual distinta de «win» o «celebrate».",
    # raise_hand (8 sociales/turnos verbales)
    "answer": "Acto verbal escolar («Responder»); levantar la mano sin texto no distingue preguntar, responder ni votar.",
    "ask for help": "Petición verbal («Pedir ayuda»); gesto idéntico a levantar la mano sin contexto único.",
    "democratic": "Adjetivo cívico abstracto («Democrático»); no se representa un concepto político sin texto.",
    "if you want to talk, raise your hand": "Norma condicional de aula («Si quieres hablar, levanta la mano»); indistinguible de «raise a hand».",
    "signal": "Sustantivo genérico abstracto («Señal»); demasiado ambiguo frente a gestos concretos.",
    "volunteer": "Rol social abstracto («Voluntario»); gesto idéntico a levantar la mano.",
    "who agrees": "Pregunta asamblearia («¿Quién está de acuerdo?»); votación verbal dependiente del habla.",
    "who wants to be captain": "Pregunta conversacional de juego («¿Quién quiere ser capitán?»).",
    # arms_wide (16 abstractas / comparativas / escénicas puras)
    "all the family": "Cuantificador colectivo («Toda la familia»); redundante con «family» sin añadir gesto distinto.",
    "bigger school": "Comparativo abstracto de edificio («Colegio más grande»); indistinguible de «school» sin etiqueta.",
    "biggest": "Superlativo abstracto sin referente único («El más grande»).",
    "everybody, sing the chorus": "Consigna verbal grupal («¡Todos, cantad el estribillo!»).",
    "everyone can play": "Norma inclusiva abstracta («Todos pueden jugar»).",
    "forgive": "Acto moral y afectivo interior («Perdonar»); indiscernible visualmente de un saludo o abrazo sin texto.",
    "generous": "Virtud moral abstracta («Generoso»).",
    "how big is baby": "Pregunta de juego verbal («¿Cuánto crece el bebé?»); depende de la rima hablada.",
    "let's sing": "Exhortación grupal («¡Vamos a cantar!»); igual a notas/canto genérico sin texto.",
    "plentiful": "Adjetivo cuantitativo abstracto («Abundante»).",
    "scene": "Término metaliterario abstracto («Escena»); abrir los brazos como un marco es ambiguo sin texto.",
    "setting": "Término narrativo abstracto («Lugar de la historia»).",
    "theatrical": "Adjetivo estilístico abstracto («Teatral»).",
    "welcome back": "Fórmula social temporal («De vuelta»); indiferenciable de «welcome» sin texto.",
    "welcoming": "Adjetivo social abstracto («Acogedor»); redundante con «welcome».",
    "wonderful": "Adjetivo valorativo genérico («Maravilloso»).",
    # wave (19 temporales, literarias o sociales sin referente visual único)
    "ancient": "Adjetivo temporal abstracto («Antiquísimo»); mover la mano como el tiempo no tiene imagen clara.",
    "estimate": "Proceso mental matemático («Estimar»); dudar con la mano es abstracto.",
    "family audience": "Rol colectivo redundante («Familias en el público»); igual que «cheering crowd» o «proud parents».",
    "farewell party": "Evento redundante con «celebration»/«bye» sin rasgo propio.",
    "farewell song": "Evento sonoro/verbal («Canción de despedida»); idéntico a cantar o saludar.",
    "happy holidays": "Fórmula social estacional («¡Felices fiestas!»); sin imagen única diferenciable.",
    "last day": "Concepto temporal abstracto («Último día»).",
    "life story": "Concepto narrativo/biográfico abstracto («Historia de vida»).",
    "melody": "Concepto musical puramente auditivo («Melodía»); indistinguible de otras ondas o notas.",
    "mood": "Concepto psicológico abstracto («Estado de ánimo»).",
    "poetic": "Adjetivo estético abstracto («Poético»).",
    "quiet car": "Cualidad sonora/regla silenciosa («Coche silencioso»); indistinguible de «car» o «quiet» sin texto.",
    "see you in primary": "Despedida verbal escolar («¡Nos vemos en Primaria!»).",
    "see you in september": "Despedida temporal con nombre de mes («Nos vemos en septiembre»); prohibido texto/meses.",
    "see you next year": "Despedida temporal («¡Nos vemos el año que viene!»).",
    "see you soon": "Fórmula conversacional temporal («¡Hasta pronto!»).",
    "sluggish": "Adjetivo abstracto de ritmo («Lentísimo»); gesto vago de mano sin referente propio.",
    "social": "Adjetivo relacional abstracto («Sociable»).",
    "wave to families": "Acción redundante con «hand wave» y «proud parents» sin marca propia.",
}
