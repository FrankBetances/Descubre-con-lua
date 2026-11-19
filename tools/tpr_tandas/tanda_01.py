#!/usr/bin/env python3
"""Tanda 1 TPR (P2.82): Cuidados del bebé, descanso, silencio, esconderse/cucú,
sentarse/tumbarse/agacharse, escuchar, oler y asentir/sorpresa.

Cada pieza ha sido revisada individualmente contra `en`, `es` y `tprAction`.
Las piezas abstractas o conversacionales sin base visual clara quedan fuera
en `SIN_BASE` para no inventar contenido (R∞.3).
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
    arco_giro,
    bebe,
    bebe_sentado,
    bellota_prop,
    caja_prop,
    copos_nieve,
    cortina_prop,
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
    mantel_cuadros,
    mesa_prop,
    cara_dormida,
    cara_silencio,
    nino,
    nino_busto,
    notas_col,
    nino_acostado,
    nino_gateando,
    notas,
    nube_pensar,
    ondas_calor,
    ondas_sonido,
    pano,
    papelera_prop,
    pelota_prop,
    plato_prop,
    pompas,
    semilla_prop,
    sol,
    toalla_prop,
)

# ── Directas Fluent Emoji Flat (MIT) revisadas palabra + gesto ────────────
DIRECTOS_FL: dict[str, tuple[str, str, str]] = {
    "baby": ("Baby", "U", "Bebé en primer plano; corresponde al sustantivo y cuidado del bebé."),
    "ears": ("Ear", "U", "Oreja en primer plano para señalar las orejas y escuchar."),
    "island": ("Desert island", "U", "Isla rodeada de mar."),
    "pigeon": ("Dove", "R", "Paloma en vuelo suave."),
    "planet earth": ("Globe showing americas", "U", "Globo del planeta Tierra."),
    "sledge": ("Sled", "U", "Trineo para deslizarse sentado en la nieve."),
}

# ── Directas Iconify (MIT / Apache-2.0) revisadas palabra + gesto ─────────
# k -> (set, name, U/R, color, autor, porque)
DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {
    "acorn": ("tabler", "acorn", "U", BARRO, "", "Bellota clara con su capuchón."),
    "armchair": ("tabler", "armchair", "U", NARANJA_OSCURO, "", "Sillón para sentarse."),
    "bench": ("mdi", "bench-back", "U", MADERA_OSCURA, "", "Banco de madera con respaldo para sentarse."),
    "curtain": ("mdi", "curtains", "U", MORADO, "", "Cortina para esconderse detrás."),
    "pillow": ("tabler", "pillow", "U", AZUL_OSCURO, "", "Almohada blanda para apoyar la cabeza."),
}

# ── Composiciones (C) y propias (D) revisadas palabra + gesto ─────────────
# k -> (cd, builder_fn, porque, lic_override)
def _escenas() -> dict[str, tuple[str, list[dict], str, str | None]]:
    m: dict[str, tuple[str, list[dict], str, str | None]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, lic: str | None = None) -> None:
        m[k] = (cd, formas, porque, lic)

    # ── Cuidados y juego del bebé (baby_care / baby_floor) ────────────────
    put("baby photo", "C",
        fondo_sala() + [R(46, 14, 68, 72, 6, MADERA, MADERA_OSCURA, 2.5), R(52, 20, 56, 60, 3, "#e0f2fe", AZUL_OSCURO, 1.5)] + fl("Baby", 58, 28, 44),
        "Marco de madera con la foto de un bebé dentro.")
    put("changing mat", "D",
        fondo_sala() + [R(22, 54, 116, 26, 8, "#bae6fd", AGUA_OSCURO, 2.2), R(22, 54, 18, 26, 6, "#93c5fd", AZUL_OSCURO, 1.8)] + bebe(78, 52, BLANCO, GRIS_OSCURO) + pano(114, 58, 18, 12, "#fef3c7", "#d97706"),
        "Cambiador acolchado con el bebé tumbado y un pañal limpio al lado.")
    put("cradle", "D",
        fondo_sala() + [R(42, 22, 76, 54, 10, MADERA, MADERA_OSCURA, 2.4), R(48, 42, 64, 30, 6, "#fef3c7", MADERA_OSCURA, 1.8), L("M54 76 L50 86", MADERA_OSCURA, 3.2), L("M106 76 L110 86", MADERA_OSCURA, 3.2)] + bebe(78, 50, "#bae6fd", AGUA_OSCURO),
        "Cuna de madera con dosel y el bebé descansando dentro.")
    put("gums", "D",
        fondo_sala() + [E(62, 50, 28, 24, ROSA, ROSA_OSCURO, 2.4), E(62, 54, 18, 12, "#fbcfe8", ROSA_OSCURO, 1.8), E(62, 44, 14, 5, "#fda4af"), E(112, 50, 14, 14, None, AGUA_OSCURO, 5.0), E(112, 50, 9, 9, None, BLANCO, 1.5)],
        "Boca abierta mostrando las encías rosadas junto a un mordedor infantil.")
    put("high chair", "D",
        fondo_sala() + [L("M56 58 L46 88", MADERA_OSCURA, 3.2), L("M104 58 L114 88", MADERA_OSCURA, 3.2), R(56, 24, 48, 34, 6, AMARILLO, MADERA_OSCURA, 2.2), R(46, 48, 68, 8, 3, BLANCO, GRIS_OSCURO, 2.0)] + bebe_sentado(80, 34, (ROJO, ROJO_OSCURO)),
        "Trona alta infantil con bandeja y bebé sentado en ella.")
    put("newborn baby", "D",
        fondo_sala() + [R(36, 42, 88, 38, 14, "#fef3c7", NARANJA_OSCURO, 2.0)] + bebe(80, 50, "#fbcfe8", ROSA_OSCURO),
        "Bebé recién nacido envuelto en su mantita.")
    put("rock and sing", "D",
        fondo_sala() + nino((52, 32), (52, 45), (52, 66), [[(74, 48)], [(66, 54)]], [[(46, 88)], [(58, 88)]], camisa=(ROSA, ROSA_OSCURO)) + bebe(80, 48) + notas([(108, 30), (126, 20)]) + [L("M30 22 Q48 12 66 22", AZUL_OSCURO, 2.0)],
        "Adulto/niño meciendo al bebé en brazos mientras canta notas musicales.")
    put("rock gently", "D",
        fondo_sala() + [L("M40 76 Q80 90 120 76", MADERA_OSCURA, 2.6), R(46, 50, 68, 24, 8, "#e0f2fe", AZUL_OSCURO, 2.0)] + bebe(78, 52) + [L("M24 62 Q18 70 24 78", VERDE_OSCURO, 2.0), L("M136 62 Q142 70 136 78", VERDE_OSCURO, 2.0)],
        "Bebé meciéndose suavemente de lado a lado.")
    put("rock to and fro", "D",
        fondo_sala() + nino((58, 34), (58, 46), (58, 66), [[(80, 50)], [(72, 56)]], [[(52, 88)], [(64, 88)]]) + bebe(84, 48) + frecha((46, 22), (24, 22), AZUL_OSCURO, 2.5) + frecha((76, 22), (98, 22), AZUL_OSCURO, 2.5),
        "Mecer al bebé adelante y atrás indicado con doble flecha.")
    put("shampoo", "C",
        fondo_sala() + fl("Lotion bottle", 24, 26, 46) + nino((100, 38), (100, 50), (100, 68), [[(90, 26)], [(112, 26)]], [[(94, 88)], [(106, 88)]]) + pompas([(92, 20, 5), (102, 16, 6), (112, 22, 5)]),
        "Bote de champú y niño masajeándose la cabeza llena de espuma y burbujas.")
    put("whirl", "D",
        fondo_sala() + nino((72, 34), (72, 46), (72, 66), [[(92, 48)], [(84, 54)]], [[(66, 88)], [(78, 88)]]) + bebe(96, 46) + arco_giro(80, 50, 32, MORADO),
        "Dar vueltas despacio sosteniendo al bebé con arco circular de giro.")
    put("kick legs", "D",
        fondo_sala() + [R(22, 68, 116, 12, 5, "#fde68a", NARANJA_OSCURO, 1.8), R(48, 52, 32, 16, 6, AZUL, AZUL_OSCURO, 2.0), E(40, 56, 9, 9, PEL, PELB, 2.0), E(37, 55, 1.1, 1.3, TINTA), L("M78 56 L98 42", PELB, 4.5), L("M78 56 L98 42", PEL, 2.5), L("M80 64 L104 60", PELB, 4.5), L("M80 64 L104 60", PEL, 2.5), L("M108 38 Q122 50 108 66", VERDE_OSCURO, 2.4)],
        "Bebé tumbado boca arriba pataleando las piernas en bicicleta.")
    put("lift head", "D",
        fondo_sala() + [R(20, 70, 120, 10, 4, "#fde68a", NARANJA_OSCURO, 1.8), R(42, 56, 36, 13, 6, VERDE, VERDE_OSCURO, 2.0), L("M72 62 L80 69 L88 69", PELB, 4.2), L("M72 62 L80 69 L88 69", PEL, 2.2), E(82, 50, 9, 9, PEL, PELB, 2.0), E(85, 49, 1.1, 1.3, TINTA), L("M80 54 Q84 56 88 54", "#9a3412", 1.3)] + frecha((112, 64), (112, 30), ROJO, 3.0),
        "Bebé boca abajo apoyado en antebrazos levantando la cabeza con flecha hacia arriba.")
    put("playmat", "D",
        fondo_sala() + [E(80, 74, 56, 16, "#bae6fd", AZUL_OSCURO, 2.2), L("M34 70 Q80 12 126 70", ROJO, 3.5), L("M58 34 L58 48", GRIS_OSCURO, 1.6), E(58, 50, 5, 5, AMARILLO, NARANJA_OSCURO, 1.5), L("M102 34 L102 48", GRIS_OSCURO, 1.6), E(102, 50, 5, 5, VERDE, VERDE_OSCURO, 1.5)] + bebe(80, 62, "#fbcfe8", ROSA_OSCURO),
        "Alfombra de juegos acolchada con arco de colgantes y bebé encima.")
    put("reflection", "D",
        fondo_sala() + [R(75, 76, 10, 16, 3, MADERA, MADERA_OSCURA, 2.0), E(80, 44, 28, 34, "#94a3b8", GRIS_OSCURO, 2.6), E(80, 44, 23, 29, "#e0f2fe", AGUA_OSCURO, 1.6)] + bebe_sentado(80, 46, (AZUL, AZUL_OSCURO)),
        "Espejo ovalado mostrando el reflejo del bebé dentro.")
    put("tummy time", "D",
        fondo_sala() + [R(18, 70, 124, 12, 5, HERBA, HERBAB, 2.0), R(36, 58, 38, 12, 6, ROJO, ROJO_OSCURO, 2.0), E(82, 54, 9, 9, PEL, PELB, 2.0), E(85, 53, 1.1, 1.3, TINTA)] + pelota_prop(118, 60, 10, AMARILLO, NARANJA_OSCURO),
        "Bebé tumbado boca abajo sobre la alfombra mirando una pelota delante.")

    # ── Agacharse / esfera / semilla / suelo (crouch) ─────────────────────
    put("an oak grows from an acorn", "C",
        fondo_prado() + bellota_prop(18, 52, 26) + frecha((48, 62), (78, 44), VERDE_OSCURO, 2.8) + fl("Deciduous tree", 84, 14, 62),
        "Bellota pequeña junto a flecha de crecimiento hacia un roble grande.")
    put("ball pit", "D",
        fondo_sala() + [R(22, 46, 116, 40, 6, AZUL, AZUL_OSCURO, 2.5), R(26, 42, 108, 8, 3, "#93c5fd", AZUL_OSCURO, 1.6)]
        + [E(40, 64, 8, 8, ROJO, TINTA, 1.2), E(56, 66, 8, 8, AMARILLO, TINTA, 1.2), E(72, 62, 8, 8, VERDE, TINTA, 1.2), E(88, 66, 8, 8, ROSA, TINTA, 1.2), E(104, 64, 8, 8, NARANJA, TINTA, 1.2), E(120, 66, 8, 8, MORADO, TINTA, 1.2), E(48, 76, 8, 8, VERDE, TINTA, 1.2), E(64, 78, 8, 8, ROJO, TINTA, 1.2), E(96, 78, 8, 8, AMARILLO, TINTA, 1.2), E(112, 76, 8, 8, AZUL, TINTA, 1.2)]
        + [E(80, 34, 9, 9, PEL, PELB, 2.0), E(77, 33, 1.1, 1.3, TINTA), E(83, 33, 1.1, 1.3, TINTA)],
        "Piscina infantil llena de bolas de colores con niño dentro.")
    put("ball run", "D",
        fondo_sala() + [R(28, 22, 8, 64, 2, MADERA, MADERA_OSCURA, 1.8), R(124, 22, 8, 64, 2, MADERA, MADERA_OSCURA, 1.8), L("M36 30 L124 44", ROJO, 4.0), L("M124 52 L36 66", AZUL, 4.0), L("M36 74 L124 84", VERDE, 4.0)] + pelota_prop(86, 32, 7, AMARILLO, NARANJA_OSCURO) + frecha((66, 24), (96, 28), ROJO_OSCURO, 2.2),
        "Circuito en zigzag con rampa y bola bajando por él.")
    put("beach clean-up", "C",
        [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 62, 160, 38, 0, "#fde68a"), L("M0 62 L160 62", "#d97706", 2.0)]
        + fl("Beach with umbrella", 10, 20, 44)
        + nino((72, 42), (72, 54), (72, 70), [[(92, 62)], [(58, 58)]], [[(66, 88)], [(80, 88)]])
        + papelera_prop(112, 54, 30) + [R(94, 72, 10, 6, 1, BLANCO, GRIS_OSCURO, 1.4)],
        "Niño agachado recogiendo desperdicios en la playa hacia la papelera.")
    put("brrr, it's cold", "C",
        fondo_cielo("#e0f2fe") + fl("Cold face", 52, 22, 56) + copos_nieve([(24, 24), (132, 26), (26, 74), (134, 72)]),
        "Cara tiritando de frío rodeada de copos de nieve.")
    put("calm-down corner", "D",
        fondo_sala() + [L("M30 16 L30 76", GRIS_OSCURO, 2.0), R(30, 60, 54, 18, 6, "#bae6fd", AZUL_OSCURO, 2.0), E(44, 54, 14, 10, "#fde68a", NARANJA_OSCURO, 1.8)] + nino((96, 38), (96, 50), (96, 68), [[(86, 62)], [(106, 62)]], [[(88, 76), (82, 86)], [(104, 76), (110, 86)]]),
        "Rincón de la calma con cojines suaves y niño respirando tranquilo.")
    put("cosy corner", "C",
        fondo_sala() + [L("M24 14 L24 76", GRIS_OSCURO, 2.0)] + ico("tabler", "pillow", 32, 46, 34, MORADO) + ico("tabler", "pillow", 60, 50, 30, ROSA) + manta_prop(88, 52, 42, "#fde68a"),
        "Rincón acogedor con cojines suaves y manta doblada.", "MIT")
    put("cuddle", "D",
        fondo_sala() + [R(36, 66, 88, 16, 6, "#bae6fd", AZUL_OSCURO, 2.0)] + nino((80, 42), (80, 54), (80, 70), [[(74, 58)], [(86, 58)]], [[(72, 74)], [(88, 74)]], camisa=(ROSA, ROSA_OSCURO)) + [E(80, 56, 12, 9, "#fbcfe8", ROSA_OSCURO, 1.8)],
        "Niño acurrucado abrazando sus rodillas y un cojín tibio.")
    put("den", "D",
        fondo_prado() + [F("M22 76 Q80 14 138 76 Z", TIERRA, BARRO, 2.4), F("M54 76 Q80 34 106 76 Z", "#1e293b", BARRO, 2.0)] + fl("Fox", 64, 46, 32) + fl("Maple leaf", 26, 56, 22),
        "Madriguera en un montículo de tierra y hojas con animal agachado dentro.")
    put("earthworm", "C",
        fondo_prado() + [R(18, 66, 124, 20, 4, TIERRA, BARRO, 2.0)] + fl("Worm", 50, 22, 60),
        "Lombriz rosada sobre la tierra del prado.")
    put("eco-friendly", "C",
        fondo_prado() + fl("Globe showing americas", 48, 16, 60) + fl("Leaf fluttering in wind", 26, 44, 30) + fl("Seedling", 104, 44, 30),
        "Planeta Tierra rodeado de brotes y hojas verdes.")
    put("ecological", "C",
        fondo_prado() + fl("Globe showing americas", 30, 18, 56) + fl("Deciduous tree", 86, 20, 54),
        "Globo terrestre junto a árbol frondoso en prado verde.")
    put("from seed to flower", "C",
        fondo_prado() + semilla_prop(16, 50, 26) + frecha((44, 58), (62, 58), VERDE_OSCURO, 2.4) + fl("Seedling", 64, 36, 30) + frecha((96, 58), (112, 58), VERDE_OSCURO, 2.4) + fl("Blossom", 112, 32, 34),
        "Secuencia de semilla a brote y flor abierta.")
    put("hide in the seagrass", "C",
        fondo_mar() + [F("M26 90 Q32 54 24 26", VERDE_OSCURO, VERDE_OSCURO, 4.0), F("M44 90 Q54 48 42 22", VERDE, VERDE, 4.0), F("M118 90 Q112 52 124 24", VERDE_OSCURO, VERDE_OSCURO, 4.0)] + fl("Tropical fish", 64, 42, 38),
        "Pradera submarina de algas altas con pez escondido entre ellas.")
    put("holly", "D",
        fondo_cielo("#f1f5f9") + [P([(80, 50), (42, 26), (34, 46), (52, 62)], VERDE, VERDE_OSCURO, 2.2), P([(80, 50), (118, 26), (126, 46), (108, 62)], VERDE, VERDE_OSCURO, 2.2), P([(80, 50), (66, 84), (94, 84)], VERDE_OSCURO, NEGRO, 2.0), E(76, 46, 7, 7, ROJO, ROJO_OSCURO, 1.8), E(88, 48, 7, 7, ROJO, ROJO_OSCURO, 1.8), E(80, 57, 7, 7, ROJO, ROJO_OSCURO, 1.8)],
        "Rama de acebo con hojas verdes dentadas y tres bolitas rojas.")
    put("let's build a snowman", "C",
        fondo_cielo("#e0f2fe") + [R(0, 74, 160, 26, 0, BLANCO, GRIS, 2.0)] + fl("Snowman", 68, 22, 58) + nino((34, 38), (34, 50), (34, 66), [[(54, 46)], [(22, 56)]], [[(28, 86)], [(40, 86)]]) + [E(58, 52, 10, 10, BLANCO, AZUL_OSCURO, 1.8)],
        "Niño construyendo un muñeco de nieve con bolas de nieve.")
    put("little seed, sleep", "C",
        fondo_prado() + [R(18, 74, 124, 14, 4, TIERRA, BARRO, 1.8), E(56, 63, 14, 10, VERDE, VERDE_OSCURO, 2.0), E(68, 56, 8, 8, PEL, PELB, 2.0), F("M60 54 C62 47 74 47 76 55 Z", BARRO), L("M67 57 Q70 59 72 57", TINTA, 1.3)] + semilla_prop(110, 54, 24) + fl("Crescent moon", 20, 12, 24),
        "Niño encogido en ovillo en el suelo como una semillita dormida bajo la luna.")
    put("perch", "C",
        fondo_prado() + [L("M24 62 L136 54", MADERA_OSCURA, 5.0)] + fl("Bird", 56, 18, 46),
        "Pájaro posado sobre una rama horizontal.")
    put("pick up litter", "C",
        fondo_prado() + nino((48, 42), (48, 54), (48, 70), [[(72, 64)], [(34, 58)]], [[(42, 88)], [(56, 88)]]) + papelera_prop(108, 54, 30) + [R(80, 72, 12, 7, 1, BLANCO, GRIS_OSCURO, 1.5)] + frecha((84, 68), (112, 52), VERDE_OSCURO, 2.6),
        "Niño agachado recogiendo papeles del suelo hacia el cubo verde.")
    put("pick up trash", "C",
        fondo_sala() + nino((48, 42), (48, 54), (48, 70), [[(72, 64)], [(34, 58)]], [[(42, 88)], [(56, 88)]]) + fl("Wastebasket", 106, 48, 36) + [E(84, 74, 6, 4, "#cbd5e1", GRIS_OSCURO, 1.5)] + frecha((84, 66), (112, 48), AZUL_OSCURO, 2.6),
        "Niño recogiendo residuos del suelo hacia la papelera.")
    put("planet care", "C",
        fondo_cielo() + fl("Globe showing americas", 52, 8, 52) + fl("Open hands", 52, 46, 52),
        "Manos abiertas cuidando y sosteniendo el planeta Tierra.")
    put("play dough", "D",
        fondo_mesa() + [E(46, 62, 16, 14, ROJO, ROJO_OSCURO, 2.0), E(84, 64, 15, 13, AZUL, AZUL_OSCURO, 2.0), E(116, 66, 14, 10, VERDE, VERDE_OSCURO, 2.0), R(42, 32, 66, 12, 6, MADERA, MADERA_OSCURA, 2.0), R(28, 35, 14, 6, 3, MADERA_OSCURA), R(108, 35, 14, 6, 3, MADERA_OSCURA)],
        "Bolas de plastilina de colores sobre la mesa junto a un rodillo.")
    put("pumpkin coach", "C",
        fondo_cielo() + fl("Jack-o-lantern", 50, 20, 58) + [E(58, 76, 11, 11, MADERA_OSCURA, TINTA, 2.0), E(102, 76, 11, 11, MADERA_OSCURA, TINTA, 2.0), E(58, 76, 4, 4, AMARILLO), E(102, 76, 4, 4, AMARILLO)],
        "Calabaza grande convertida en carroza con ruedas.")
    put("quiet corner", "C",
        fondo_sala() + [R(22, 58, 56, 20, 6, "#ddd6fe", MORADO, 2.0)] + ico("tabler", "pillow", 30, 36, 32, MORADO) + cara_silencio(112, 46, 20),
        "Rincón tranquilo con cojines y gesto de silencio.", "MIT")
    put("round like a ball", "D",
        fondo_prado() + pelota_prop(80, 48, 22, ROJO, ROJO_OSCURO) + arco_giro(80, 48, 30, AZUL_OSCURO),
        "Pelota redonda rodeada de arco circular mostrando la forma redonda.")
    put("snow globe", "D",
        fondo_cielo("#e0f2fe") + [E(80, 44, 30, 30, "#dbeafe", AZUL_OSCURO, 2.4), R(56, 68, 48, 16, 4, MADERA, MADERA_OSCURA, 2.2)] + fl("Snowman", 64, 24, 32) + copos_nieve([(64, 30), (96, 32), (88, 52)]),
        "Bola de nieve transparente sobre base con muñeco de nieve y copos dentro.")
    put("stuck", "D",
        fondo_prado() + [E(80, 74, 46, 12, TIERRA, BARRO, 2.2)] + fl("Automobile", 48, 28, 56) + [L("M30 40 L38 34", ROJO, 2.4), L("M28 48 L36 48", ROJO, 2.4), L("M122 40 L130 34", ROJO, 2.4)],
        "Coche pequeño atascado en un charco de barro sin poder avanzar.")
    put("under the tree", "C",
        fondo_prado() + fl("Deciduous tree", 42, 6, 76) + nino((78, 52), (78, 62), (78, 76), [[(68, 68)], [(88, 68)]], [[(70, 86)], [(86, 86)]]) + frecha((126, 30), (126, 70), ROJO, 3.0),
        "Niño agachado debajo de la copa de un árbol grande.")
    put("watch out, crocodile", "C",
        fondo_mar() + fl("Crocodile", 18, 34, 62) + nino((114, 34), (114, 46), (114, 66), [[(98, 28)], [(130, 28)]], [[(106, 86)], [(122, 86)]]) + [L("M114 10 L114 18", ROJO, 2.8), E(114, 22, 2, 2, ROJO)],
        "Cocodrilo frente a niño sorprendido que encoge las piernas.")
    put("woodlouse", "D",
        fondo_prado() + [E(62, 56, 26, 14, GRIS_OSCURO, NEGRO, 2.2), L("M50 44 L50 68", NEGRO, 1.5), L("M62 42 L62 70", NEGRO, 1.5), L("M74 44 L74 68", NEGRO, 1.5), L("M86 52 L94 46", NEGRO, 1.5), L("M86 60 L94 64", NEGRO, 1.5), E(118, 58, 13, 13, GRIS_OSCURO, NEGRO, 2.0), L("M110 52 Q118 48 126 52", GRIS, 1.5)],
        "Cochinilla segmentada junto a su forma enrollada hecha bola.")

    # ── Tumbarse / flotar / plano (lie) ───────────────────────────────────
    put("belly slide", "D",
        fondo_cielo("#e0f2fe") + [P([(16, 84), (16, 30), (144, 84)], BLANCO, AZUL_OSCURO, 2.2), R(42, 46, 32, 12, 5, ROJO, ROJO_OSCURO, 2.0), E(78, 52, 8, 8, PEL, PELB, 2.0)] + frecha((88, 42), (124, 64), VERDE_OSCURO, 3.0),
        "Niño tumbado de barriga deslizándose por la cuesta nevada.")
    put("blueprint", "D",
        fondo_mesa() + [R(28, 18, 104, 64, 4, "#1d4ed8", AZUL_OSCURO, 2.2), R(46, 34, 44, 34, 1, None, BLANCO, 2.0), P([(46, 34), (68, 22), (90, 34)], None, BLANCO, 2.0), R(62, 48, 12, 20, 1, None, BLANCO, 1.5), R(102, 26, 18, 48, 1, None, "#93c5fd", 1.2)],
        "Plano azul de diseño técnico con dibujo lineal de una casa.")
    put("flat", "D",
        fondo_mesa() + [R(22, 62, 116, 10, 4, MADERA, MADERA_OSCURA, 2.2), L("M22 46 L138 46", AZUL_OSCURO, 2.8), P([(132, 42), (140, 46), (132, 50)], AZUL_OSCURO), P([(28, 42), (20, 46), (28, 50)], AZUL_OSCURO)],
        "Tabla completamente plana y horizontal con línea recta indicando plano.")
    put("float", "D",
        fondo_mar() + nino_acostado(50, 48, (AMARILLO, NARANJA_OSCURO)),
        "Niño tumbado boca arriba flotando tranquilo sobre el agua.")
    put("float like an otter", "C",
        fondo_mar() + fl("Otter", 44, 24, 66) + [L("M24 74 Q50 68 78 74 Q108 80 136 74", BLANCO, 2.2)],
        "Nutria flotando tranquila boca arriba sobre el agua.")
    put("float on your back", "D",
        fondo_mar() + nino_acostado(52, 46, (VERDE, VERDE_OSCURO), ojos_cerrados=True) + [L("M56 38 L46 28", PELB, 3.2), L("M56 38 L46 28", PEL, 1.8)],
        "Niño flotando boca arriba con los ojos cerrados y brazos abiertos en el mar.")
    put("lie still", "D",
        fondo_sala() + [R(20, 70, 120, 10, 4, HERBA, HERBAB, 2.0)] + nino_acostado(48, 54, (AZUL, AZUL_OSCURO)),
        "Niño tumbado totalmente quieto sobre una esterilla.")
    put("nap time", "D",
        fondo_sala() + [R(20, 68, 120, 12, 4, "#93c5fd", AZUL_OSCURO, 2.0)] + nino_acostado(46, 52, (MORADO, "#5b21b6"), ojos_cerrados=True) + fl("Twelve oclock", 112, 14, 30),
        "Niño echando la siesta tumbado en su esterilla junto al reloj.")
    put("pedal", "D",
        fondo_prado() + nino_acostado(42, 56, (NARANJA, NARANJA_OSCURO)) + [L("M46 58 L36 38 L48 34", AZUL_OSCURO, 3.0), L("M46 62 L58 44 L44 38", AZUL_OSCURO, 3.0)] + arco_giro(46, 36, 16, ROJO),
        "Niño tumbado boca arriba pedaleando las piernas en el aire.")
    put("relaxed summer", "C",
        fondo_prado() + fl("Sun", 16, 10, 32) + manta_prop(32, 58, 92, "#fde68a", h=28) + nino_acostado(54, 48, (ROSA, ROSA_OSCURO), ojos_cerrados=True),
        "Niño descansando tumbado sobre la manta al sol de verano.")
    put("resting", "D",
        fondo_sala() + [R(24, 68, 112, 14, 6, "#ddd6fe", MORADO, 2.0)] + nino_acostado(48, 52, (VERDE, VERDE_OSCURO), ojos_cerrados=True),
        "Niño en reposo tumbado cómodamente sobre un colchón.")
    put("sunbathe", "C",
        [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 62, 160, 38, 0, "#fde68a")] + fl("Sun", 116, 10, 32) + toalla_prop(36, 56, 80, h=28) + nino_acostado(48, 46, (ROJO, ROJO_OSCURO), ojos_cerrados=True),
        "Niño tomando el sol tumbado en la toalla sobre la arena.")

    # ── Escuchar (listen) ─────────────────────────────────────────────────
    put("bird song", "C",
        fondo_prado() + [L("M20 66 L104 54", MADERA_OSCURA, 4.5)] + fl("Bird", 32, 22, 46) + notas([(88, 30), (110, 22), (126, 34)]),
        "Pájaro cantando notas musicales desde la rama.")
    put("crackly shell", "C",
        fondo_mesa() + fl("Egg", 44, 24, 52) + [L("M66 36 L74 44 L64 54 L76 62", BARRO, 2.6)] + ondas_sonido(102, 48, NARANJA_OSCURO, 1),
        "Cáscara agrietándose con líneas de crujido y sonido.")
    put("listen close", "D",
        fondo_sala() + nino((58, 32), (58, 45), (58, 66), [[(44, 32)], [(72, 56)]], [[(52, 88)], [(64, 88)]]) + ondas_sonido(30, 30, AZUL_OSCURO, -1) + fl("Ear", 96, 28, 38),
        "Niño acercando la mano a la oreja para escuchar de cerca.")
    put("listen to the birds", "C",
        fondo_prado() + nino((46, 32), (46, 45), (46, 66), [[(34, 32)], [(58, 56)]], [[(40, 88)], [(52, 88)]]) + ondas_sonido(22, 30, AZUL_OSCURO, -1) + fl("Bird", 94, 20, 44) + notas([(84, 26), (134, 20)]),
        "Niño con la mano en la oreja escuchando cantar a los pájaros.")
    put("listen to the crunch", "C",
        fondo_prado() + fl("Maple leaf", 50, 44, 48) + [R(64, 22, 16, 24, 4, MAR_PROF, TINTA, 1.8), R(62, 42, 26, 10, 4, NARANJA, NARANJA_OSCURO, 1.8)] + ondas_sonido(104, 54, BARRO, 1),
        "Zapato pisando hoja seca con ondas sonoras del crujido.")
    put("listen to the woodpecker", "C",
        fondo_prado() + [R(36, 10, 26, 80, 3, MADERA, MADERA_OSCURA, 2.2)] + fl("Bird", 60, 22, 42, flip_x=True) + ondas_sonido(108, 34, ROJO_OSCURO, 1),
        "Pájaro picoteando el tronco del árbol con ondas de sonido.")
    put("listen with a hand to the ear", "D",
        fondo_sala() + nino((78, 32), (78, 45), (78, 66), [[(64, 32)], [(92, 56)]], [[(72, 88)], [(84, 88)]]) + ondas_sonido(46, 30, AZUL_OSCURO, -1) + ondas_sonido(104, 32, AZUL_OSCURO, 1),
        "Niño escuchando atento con la mano llevada a la oreja.")
    put("listening tube", "D",
        fondo_sala() + nino((38, 34), (38, 46), (38, 66), [[(56, 44)], [(26, 56)]], [[(32, 88)], [(44, 88)]]) + nino((116, 34), (116, 46), (116, 66), [[(98, 44)], [(128, 56)]], [[(110, 88)], [(122, 88)]], camisa=(AZUL, AZUL_OSCURO)) + [L("M48 32 L106 48", MADERA, 6.0), L("M48 32 L106 48", MADERA_OSCURA, 1.5)] + ondas_sonido(126, 44, ROJO, 1),
        "Dos niños usando un tubo de cartón para escuchar el latido del pecho.")
    put("put on your sun hat", "C",
        fondo_prado() + fl("Sun", 14, 10, 28) + fl("Womans hat", 61, 8, 38) + frecha((80, 42), (80, 56), VERDE_OSCURO, 2.6) + nino_busto(80, 70),
        "Sombrero de sol bajando hacia la cabeza del niño.")
    put("rattle", "D",
        fondo_sala() + [L("M58 76 L88 46", AZUL, 6.0), E(96, 38, 18, 18, AMARILLO, NARANJA_OSCURO, 2.4), L("M82 32 L110 44", ROJO, 3.0), E(56, 78, 7, 7, ROJO, ROJO_OSCURO, 2.0)] + ondas_sonido(118, 34, MORADO, 1),
        "Sonajero infantil agitado con ondas sonoras.")
    put("referee's whistle", "C",
        fondo_prado() + ico("mdi", "whistle", 38, 22, 54, GRIS_OSCURO) + ondas_sonido(102, 36, ROJO, 1) + [R(120, 42, 18, 26, 2, AMARILLO, NARANJA_OSCURO, 1.8)],
        "Silbato de árbitro sonando junto a tarjeta de aviso.", "Apache-2.0")
    put("rub gently", "D",
        fondo_prado() + [R(40, 18, 36, 68, 4, MADERA, MADERA_OSCURA, 2.2), L("M50 28 L50 76", BARRO, 1.8), L("M64 24 L64 78", BARRO, 1.8)] + fl("Open hands", 78, 30, 42) + ondas_sonido(122, 46, VERDE_OSCURO, 1),
        "Mano frotando suavemente la corteza de un tronco mientras suena.")
    put("shh, listen", "C",
        fondo_sala() + cara_silencio(48, 48, 20) + fl("Ear", 88, 24, 46) + ondas_sonido(136, 46, AZUL_OSCURO, 1),
        "Dedo en los labios pidiendo silencio seguido de oreja atenta escuchando.")
    put("stop, look and listen", "C",
        fondo_sala() + [E(34, 48, 20, 20, ROJO, ROJO_OSCURO, 2.2), R(24, 44, 20, 8, 2, BLANCO)] + fl("Eyes", 62, 26, 40) + fl("Ear", 108, 26, 38),
        "Señal de parar, ojos mirando y oreja escuchando.")
    put("thumping", "D",
        fondo_sala() + [L("M72 22 L72 64", AZUL_OSCURO, 8.0), R(64, 60, 34, 14, 6, ROJO, ROJO_OSCURO, 2.0)] + frecha((46, 32), (46, 62), ROJO, 3.0) + [L("M52 78 L42 84", NARANJA_OSCURO, 2.4), L("M104 78 L114 84", NARANJA_OSCURO, 2.4), L("M80 80 L80 88", NARANJA_OSCURO, 2.4)],
        "Pie golpeando fuerte en el suelo con ondas de retumbo.")
    put("touch your head", "D",
        fondo_sala() + nino((80, 36), (80, 48), (80, 68), [[(68, 26), (72, 24)], [(92, 26), (88, 24)]], [[(74, 88)], [(86, 88)]]) + [E(80, 32, 13, 13, None, ROJO, 2.2)],
        "Niño tocándose la cabeza con las dos manos.")
    put("wash your hands", "C",
        fondo_sala() + [R(22, 68, 116, 12, 4, "#e2e8f0", GRIS_OSCURO, 2.0), L("M80 18 L80 30", GRIS_OSCURO, 4.0)] + gotas([(76, 34), (84, 38)]) + fl("Soap", 28, 34, 38) + fl("Open hands", 68, 42, 44) + pompas([(116, 44, 6), (126, 36, 5)]),
        "Manos lavándose bajo gotas de agua con jabón y pompas.")

    # ── Esconderse / cucú / filas (peek) ──────────────────────────────────
    put("behind my hands", "D",
        fondo_sala() + nino((80, 36), (80, 50), (80, 70), [[(74, 36)], [(86, 36)]], [[(74, 88)], [(86, 88)]]) + [R(66, 28, 12, 18, 4, PEL, PELB, 1.8), R(82, 28, 12, 18, 4, PEL, PELB, 1.8)],
        "Niño escondiendo la cara detrás de sus dos manos.")
    put("behind the clouds", "C",
        fondo_cielo() + fl("Sun behind cloud", 46, 18, 68),
        "Sol escondido asomándose detrás de las nubes.")
    put("behind the tree", "C",
        fondo_prado() + fl("Deciduous tree", 46, 12, 68) + nino((100, 42), (100, 54), (100, 72), [[(86, 46)], [(114, 58)]], [[(94, 88)], [(106, 88)]]),
        "Niño asomándose escondido detrás del tronco de un árbol.")
    put("boo", "C",
        fondo_sala() + fl("Face with peeking eye", 50, 18, 60) + [L("M28 32 L38 40", AMARILLO_OSCURO, 2.6), L("M24 48 L36 48", AMARILLO_OSCURO, 2.6), L("M132 32 L122 40", AMARILLO_OSCURO, 2.6), L("M136 48 L124 48", AMARILLO_OSCURO, 2.6)],
        "Cara descubriendo el ojo de golpe para decir ¡bu!")
    put("chase after", "D",
        fondo_sala() + nino_gateando(28, 52, mira=1) + pelota_prop(120, 68, 12, ROJO, ROJO_OSCURO) + frecha((94, 44), (122, 44), VERDE_OSCURO, 2.8),
        "Niño gateando rápido detrás de una pelota que rueda.")
    put("comfortable", "C",
        fondo_sala() + [R(28, 62, 104, 18, 6, "#bae6fd", AZUL_OSCURO, 2.0)] + ico("tabler", "pillow", 34, 34, 38, MORADO) + nino((96, 38), (96, 50), (96, 68), [[(82, 54)], [(110, 54)]], [[(90, 78)], [(102, 78)]]),
        "Cojín suave apoyando cómodamente la espalda del niño.", "MIT")
    put("guess who's behind the mask", "C",
        fondo_sala() + nino((80, 38), (80, 50), (80, 70), [[(66, 38)], [(94, 58)]], [[(74, 88)], [(86, 88)]]) + ico("mdi", "domino-mask", 62, 24, 36, MORADO),
        "Niño cubriéndose los ojos con un antifaz para adivinar quién es.", "Apache-2.0")
    put("hidden", "D",
        fondo_prado() + nino_busto(80, 44) + [E(80, 64, 34, 20, HERBA, HERBAB, 2.2), E(58, 68, 22, 16, VERDE, VERDE_OSCURO, 1.8), E(102, 68, 22, 16, VERDE, VERDE_OSCURO, 1.8)],
        "Niño escondido detrás de un arbusto verde.")
    put("hide behind", "C",
        fondo_prado() + fl("Evergreen tree", 38, 14, 62) + nino((102, 42), (102, 54), (102, 72), [[(88, 52)], [(116, 58)]], [[(96, 88)], [(108, 88)]]),
        "Niño escondiéndose detrás de un pino.")
    put("hide quietly", "D",
        fondo_sala() + cortina_prop(28, 14, 56) + cara_silencio(114, 46, 20),
        "Niño escondiéndose detrás de la cortina con dedo en los labios.")
    put("hide thumbs", "D",
        fondo_sala() + [R(34, 34, 36, 34, 12, PEL, PELB, 2.2), R(90, 34, 36, 34, 12, PEL, PELB, 2.2), L("M42 46 L62 46", PELB, 1.8), L("M42 56 L62 56", PELB, 1.8), L("M98 46 L118 46", PELB, 1.8), L("M98 56 L118 56", PELB, 1.8), E(52, 50, 7, 7, None, ROJO, 2.0), E(108, 50, 7, 7, None, ROJO, 2.0)],
        "Dos puños cerrados escondiendo dentro los dedos pulgares.")
    put("hiding spot", "C",
        fondo_sala() + fl("Chair", 42, 22, 62) + nino((104, 42), (104, 54), (104, 72), [[(90, 54)], [(116, 58)]], [[(98, 88)], [(110, 88)]]),
        "Silla usada como escondrijo con niño agachado detrás.")
    put("line", "D",
        fondo_sala() + nino((34, 36), (34, 48), (34, 66), [[(22, 56)], [(46, 56)]], [[(28, 88)], [(40, 88)]]) + nino((80, 36), (80, 48), (80, 66), [[(68, 56)], [(92, 56)]], [[(74, 88)], [(86, 88)]], camisa=(AZUL, AZUL_OSCURO)) + nino((126, 36), (126, 48), (126, 66), [[(114, 56)], [(138, 56)]], [[(120, 88)], [(132, 88)]], camisa=(VERDE, VERDE_OSCURO)),
        "Tres niños en línea recta uno detrás de otro.")
    put("line up", "D",
        fondo_sala() + nino((36, 36), (36, 48), (36, 66), [[(24, 56)], [(48, 56)]], [[(30, 88)], [(42, 88)]]) + nino((80, 36), (80, 48), (80, 66), [[(68, 56)], [(92, 56)]], [[(74, 88)], [(86, 88)]], camisa=(MORADO, "#5b21b6")) + nino((124, 36), (124, 48), (124, 66), [[(112, 56)], [(136, 56)]], [[(118, 88)], [(130, 88)]], camisa=(AMARILLO, NARANJA_OSCURO)) + frecha((26, 16), (134, 16), ROJO, 2.8),
        "Niños poniéndose en fila con flecha de alineación.")
    put("muslin cloth", "D",
        fondo_sala() + pano(42, 22, 76, 52, BLANCO, AGUA_OSCURO) + [L("M50 36 L110 36", "#bae6fd", 1.8), L("M50 50 L110 50", "#bae6fd", 1.8), L("M50 62 L110 62", "#bae6fd", 1.8)],
        "Muselina suave y ligera doblada para jugar al cucú.")
    put("peekaboo", "D",
        fondo_sala() + nino((80, 38), (80, 50), (80, 70), [[(62, 34)], [(98, 34)]], [[(74, 88)], [(86, 88)]]) + [R(58, 28, 10, 16, 4, PEL, PELB, 1.8), R(92, 28, 10, 16, 4, PEL, PELB, 1.8)],
        "Niño apartando las manos de la cara al descubrirse en ¡cucú, tras!")
    put("peekaboo, i see you", "C",
        fondo_sala() + fl("Face with peeking eye", 28, 22, 52) + fl("Eyes", 88, 28, 46),
        "Cara asomándose tras los dedos y ojos mirando: ¡ya te veo!")
    put("peep out", "D",
        fondo_sala() + nino((80, 36), (80, 48), (80, 68), [[(66, 56)], [(94, 56)]], [[(74, 88)], [(86, 88)]]) + pano(54, 40, 52, 26, "#fca5a5", ROJO_OSCURO),
        "Niño asomando los ojos por encima de un pañuelo.")
    put("pop up", "C",
        fondo_sala() + nino_busto(72, 38, brazos_arriba=True) + fl("Couch and lamp", 36, 40, 72) + frecha((124, 60), (124, 22), VERDE_OSCURO, 3.0),
        "Niño apareciendo de golpe detrás del sofá con flecha hacia arriba.")
    put("shopkeeper", "C",
        fondo_sala() + [R(22, 16, 116, 16, 4, ROJO, ROJO_OSCURO, 2.0), R(22, 54, 116, 28, 4, MADERA, MADERA_OSCURA, 2.2)] + nino((62, 34), (62, 46), (62, 54), [[(48, 50)], [(76, 50)]], [[(58, 56)], [(66, 56)]]) + fl("Basket", 94, 28, 34),
        "Tendero detrás del mostrador atendiendo con cesta de fruta.")
    put("under the blanket", "D",
        fondo_sala() + manta_prop(30, 38, 100, "#fde68a", h=46) + [E(80, 34, 11, 11, PEL, PELB, 2.0), E(77, 33, 1.1, 1.3, TINTA), E(83, 33, 1.1, 1.3, TINTA), L("M77 37 Q80 39 83 37", "#9a3412", 1.3)],
        "Niño escondido debajo de una manta asomando la cabeza.")
    put("wait in line", "C",
        fondo_sala() + nino((34, 38), (34, 50), (34, 68), [[(24, 58)], [(44, 58)]], [[(28, 88)], [(40, 88)]]) + nino((74, 38), (74, 50), (74, 68), [[(64, 58)], [(84, 58)]], [[(68, 88)], [(80, 88)]], camisa=(AZUL, AZUL_OSCURO)) + fl("Hourglass not done", 108, 28, 36),
        "Niños esperando en fila tranquilamente junto al reloj de arena.")
    put("when the music stops, hide", "D",
        fondo_sala() + notas([(24, 38), (44, 28)]) + [L("M18 22 L56 46", ROJO, 3.0)] + nino_busto(122, 48) + cortina_prop(74, 18, 56),
        "Música parada (notas tachadas) y niño escondiéndose detrás de la cortina.")

    # ── Silencio / bajito / quietud (shh) ─────────────────────────────────
    put("carol", "C",
        fondo_noite() + fl("Christmas tree", 34, 16, 62) + notas_col([(104, 36), (124, 26)], "#fde047"),
        "Árbol de Navidad y notas musicales brillantes de un villancico.")
    put("chuckle", "D",
        fondo_sala() + nino((80, 34), (80, 46), (80, 68), [[(74, 38)], [(94, 58)]], [[(74, 88)], [(86, 88)]]) + ondas_sonido(98, 34, ROSA_OSCURO, 1),
        "Niño tapándose un poco la boca riéndose bajito.")
    put("echoing", "C",
        fondo_prado() + fl("Mountain", 22, 16, 58) + ondas_sonido(84, 42, AZUL_OSCURO, 1) + ondas_sonido(108, 42, AGUA_OSCURO, 1),
        "Montaña devolviendo ondas sonoras sucesivas de eco.")
    put("growl", "C",
        fondo_prado() + fl("Bear", 34, 20, 56) + [L("M96 34 L108 30 L104 42 L118 38 L112 50", ROJO_OSCURO, 2.6)],
        "Oso gruñendo suavemente con ondas cortas.")
    put("hush", "D",
        fondo_noite() + cara_silencio(72, 48, 22) + [L("M108 42 Q122 36 136 42", "#bae6fd", 2.4), L("M108 54 Q122 48 136 54", "#bae6fd", 2.0)],
        "Dedo en los labios pidiendo silencio y calma suave.")
    put("hush, little baby", "D",
        fondo_noite() + bebe(50, 50) + cara_silencio(106, 46, 18) + notas_col([(26, 28), (44, 22)], "#fde047"),
        "Bebé acunado tranquilo con dedo en los labios y nana suave.")
    put("listen", "D",
        fondo_sala() + nino((78, 32), (78, 45), (78, 66), [[(64, 32)], [(92, 56)]], [[(72, 88)], [(84, 88)]]) + ondas_sonido(46, 30, AZUL_OSCURO, -1),
        "Niño escuchando en silencio con la mano junto a la oreja.")
    put("mew", "C",
        fondo_sala() + fl("Cat", 38, 22, 56) + notas([(104, 34), (122, 26)]),
        "Gato maullando suavemente con notas.")
    put("owl hoot", "C",
        fondo_noite() + fl("Owl", 36, 20, 56) + ondas_sonido(102, 34, "#fde047", 1),
        "Búho ululando en la noche con ondas suaves.")
    put("shh, a heron", "D",
        fondo_prado() + [L("M48 64 L48 84", NARANJA_OSCURO, 2.2), L("M54 64 L54 84", NARANJA_OSCURO, 2.2), E(50, 54, 12, 9, BLANCO, GRIS_OSCURO, 2.0), L("M58 50 Q66 36 62 28", BLANCO, 4.0), E(64, 26, 5, 4, BLANCO, GRIS_OSCURO, 1.8), P([(68, 26), (80, 27), (68, 29)], NARANJA)] + cara_silencio(114, 46, 19),
        "Garza blanca estilizada junto al dedo en los labios pidiendo silencio.")
    put("short", "D",
        fondo_sala() + nino((52, 24), (52, 38), (52, 62), [[(38, 50)], [(66, 50)]], [[(46, 88)], [(58, 88)]]) + nino((108, 52), (108, 62), (108, 76), [[(98, 68)], [(118, 68)]], [[(102, 88)], [(114, 88)]], camisa=(VERDE, VERDE_OSCURO)) + [L("M90 42 L126 42", ROJO, 2.2)] + frecha((130, 28), (130, 56), ROJO, 2.4),
        "Comparación entre figura alta y figura agachada bajita.")
    put("silent room", "C",
        fondo_sala() + cara_silencio(52, 48, 20) + fl("Muted speaker", 88, 24, 48),
        "Sala en silencio representada por dedo en los labios y altavoz silenciado.")
    put("tiptoe past", "C",
        fondo_sala() + fl("Teddy bear", 26, 42, 40) + nino((96, 32), (96, 44), (96, 64), [[(84, 46)], [(108, 46)]], [[(90, 84)], [(102, 80)]]) + [L("M88 88 L92 84", PELB, 2.0), L("M100 84 L104 80", PELB, 2.0)],
        "Niño caminando de puntillas en silencio junto a un peluche dormido.")
    put("wait", "C",
        fondo_sala() + nino((50, 34), (50, 46), (50, 66), [[(42, 56)], [(58, 56)]], [[(44, 88)], [(56, 88)]]) + fl("Hourglass not done", 92, 24, 44),
        "Niño esperando tranquilo con las manos juntas junto al reloj de arena.")
    put("watch the sky", "C",
        fondo_cielo() + nino((56, 36), (56, 48), (56, 68), [[(44, 58)], [(68, 58)]], [[(50, 88)], [(62, 88)]]) + fl("Sun behind cloud", 96, 12, 42) + frecha((64, 30), (92, 22), AZUL_OSCURO, 2.2),
        "Niño mirando hacia arriba al cielo con sol y nubes.")
    put("watch the waves", "C",
        fondo_mar() + nino((48, 32), (48, 44), (48, 62), [[(36, 54)], [(60, 54)]], [[(42, 80)], [(54, 80)]]) + fl("Water wave", 92, 34, 46),
        "Niño sentado mirando tranquilamente las olas del mar.")
    put("when the drum stops, freeze", "C",
        fondo_sala() + fl("Drum", 28, 28, 44) + [L("M24 24 L74 74", ROJO, 3.0)] + nino((108, 34), (108, 46), (108, 66), [[(92, 36)], [(124, 36)]], [[(102, 88)], [(114, 88)]]),
        "Tambor detenido con señal roja y niño quieto como estatua.")
    put("worry doll", "D",
        fondo_sala() + [E(80, 28, 11, 11, PEL, BARRO, 2.0), E(76, 27, 1.2, 1.2, TINTA), E(84, 27, 1.2, 1.2, TINTA), L("M76 32 Q80 35 84 32", ROJO_OSCURO, 1.4), R(68, 40, 24, 14, 3, ROJO, TINTA, 1.8), R(68, 54, 24, 14, 3, AZUL, TINTA, 1.8), R(68, 68, 24, 14, 3, AMARILLO, TINTA, 1.8), L("M68 44 L54 48", VERDE, 4.0), L("M92 44 L106 48", VERDE, 4.0)],
        "Muñeca quitapenas tradicional vestida con franjas de colores vivos.")

    # ── Sentarse (sit) ────────────────────────────────────────────────────
    put("audience", "D",
        fondo_sala() + [R(22, 14, 116, 24, 4, ROJO, ROJO_OSCURO, 2.0), R(30, 18, 100, 16, 2, "#fef3c7")] + nino((46, 52), (46, 62), (46, 76), [[(38, 70)], [(54, 70)]], [[(42, 88)], [(50, 88)]]) + nino((80, 52), (80, 62), (80, 76), [[(72, 70)], [(88, 70)]], [[(76, 88)], [(84, 88)]], camisa=(AZUL, AZUL_OSCURO)) + nino((114, 52), (114, 62), (114, 76), [[(106, 70)], [(122, 70)]], [[(110, 88)], [(118, 88)]], camisa=(VERDE, VERDE_OSCURO)),
        "Niños sentados como público mirando el escenario.")
    put("bath", "C",
        fondo_sala() + fl("Bathtub", 42, 22, 72) + pompas([(44, 22, 6), (86, 16, 8), (116, 24, 5)]),
        "Bañera llena con pompas de baño.")
    put("buddy bench", "C",
        fondo_prado() + ico("mdi", "bench-back", 34, 34, 92, MADERA_OSCURA) + nino_busto(62, 42) + nino_busto(98, 42, camisa=(AZUL, AZUL_OSCURO)),
        "Dos amigos sentados juntos en el banco de la amistad.", "Apache-2.0")
    put("by the sea", "C",
        fondo_mar() + nino((48, 38), (48, 48), (48, 62), [[(38, 56)], [(58, 56)]], [[(44, 72)], [(54, 72)]]) + fl("Beach with umbrella", 92, 26, 48),
        "Niño sentado a la orilla del mar mirando las olas.")
    put("campfire", "C",
        fondo_noite() + [L("M52 76 L108 62", MADERA_OSCURA, 5.5), L("M52 62 L108 76", MADERA, 5.5)] + fl("Fire", 54, 18, 52),
        "Hoguera de campamento sobre troncos cruzados en la noche.")
    put("circle time", "D",
        fondo_sala() + [E(80, 62, 58, 24, "#fde68a", NARANJA_OSCURO, 2.2)] + nino((42, 40), (42, 50), (42, 62), [[(34, 58)], [(50, 58)]], [[(38, 72)], [(46, 72)]]) + nino((80, 32), (80, 42), (80, 54), [[(72, 50)], [(88, 50)]], [[(76, 64)], [(84, 64)]], camisa=(AZUL, AZUL_OSCURO)) + nino((118, 40), (118, 50), (118, 62), [[(110, 58)], [(126, 58)]], [[(114, 72)], [(122, 72)]], camisa=(VERDE, VERDE_OSCURO)),
        "Niños sentados en círculo sobre la alfombra en asamblea.")
    put("cool shade", "C",
        fondo_prado() + fl("Sun", 18, 10, 26) + [E(86, 78, 34, 8, "#4d7c0f")] + fl("Deciduous tree", 40, 12, 62) + nino((96, 44), (96, 54), (96, 66), [[(86, 62)], [(106, 62)]], [[(92, 76)], [(100, 76)]]),
        "Árbol dando sombra fresca con niño sentado debajo.")
    put("cushion circle", "D",
        fondo_sala() + [E(80, 36, 15, 10, ROJO, ROJO_OSCURO, 2.0), E(44, 54, 15, 10, AZUL, AZUL_OSCURO, 2.0), E(116, 54, 15, 10, VERDE, VERDE_OSCURO, 2.0), E(60, 74, 15, 10, AMARILLO, NARANJA_OSCURO, 2.0), E(100, 74, 15, 10, MORADO, "#5b21b6", 2.0)],
        "Cojines de colores colocados en círculo para sentarse.")
    put("desk", "D",
        fondo_sala() + mesa_prop(46, 46, 68, 36) + libro_prop(64, 24, 30, AZUL) + [R(68, 60, 24, 22, 3, AMARILLO, NARANJA_OSCURO, 1.8)],
        "Pupitre escolar con libro abierto encima y silla debajo.")
    put("family table", "C",
        fondo_sala() + nino_busto(48, 30) + bebe_sentado(112, 34, (ROSA, ROSA_OSCURO)) + mesa_prop(34, 54, 92, 30) + plato_prop(58, 48, 12) + plato_prop(102, 48, 12),
        "Mesa familiar puesta con platos, adulto y bebé sentados.")
    put("in the sand", "C",
        [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 56, 160, 44, 0, "#fde68a"), L("M0 56 L160 56", "#d97706", 2.0)] + nino((52, 36), (52, 48), (52, 64), [[(74, 62)], [(40, 58)]], [[(46, 76)], [(64, 76)]]) + [L("M90 74 C96 66 106 72 98 78 C90 82 84 70 96 64", BARRO, 2.2)],
        "Niño sentado en la arena dibujando espirales con el dedo.")
    put("lunch time", "C",
        fondo_mesa() + plato_prop(56, 60, 22) + cuchara_prop(84, 42, 26) + fl("Red apple", 36, 36, 24) + fl("Twelve oclock", 104, 16, 38),
        "Plato, cuchara y fruta junto al reloj indicando la hora de comer.")
    put("nearby", "D",
        fondo_prado() + nino((58, 36), (58, 48), (58, 66), [[(48, 56)], [(68, 56)]], [[(52, 86)], [(64, 86)]]) + nino((96, 36), (96, 48), (96, 66), [[(86, 56)], [(106, 56)]], [[(90, 86)], [(102, 86)]], camisa=(AZUL, AZUL_OSCURO)) + [L("M66 20 L88 20", VERDE_OSCURO, 2.4)],
        "Dos niños sentados muy cerca el uno del otro.")
    put("on the blanket", "D",
        fondo_prado() + manta_prop(30, 58, 100, "#fde68a", h=28) + nino((80, 36), (80, 48), (80, 62), [[(68, 56)], [(92, 56)]], [[(72, 74)], [(88, 74)]]),
        "Niño sentado encima de una manta extendida.")
    put("on the bus", "C",
        fondo_cielo() + fl("Bus", 20, 20, 86) + nino_busto(124, 52),
        "Autobús escolar y niño sentado para subir o mirando junto a él.")
    put("on the grass", "C",
        fondo_prado() + nino((80, 36), (80, 48), (80, 64), [[(68, 56)], [(92, 56)]], [[(72, 78)], [(88, 78)]]) + fl("Blossom", 28, 58, 24) + fl("Herb", 112, 56, 26),
        "Niño sentado directamente sobre la hierba verde con flores.")
    put("on the sofa", "C",
        fondo_sala() + fl("Couch and lamp", 32, 26, 78) + nino((116, 40), (116, 52), (116, 68), [[(104, 58)], [(128, 58)]], [[(110, 82)], [(122, 82)]]),
        "Sofá acogedor con niño sentado cómodamente.")
    put("park bench", "C",
        fondo_prado() + ico("mdi", "bench-back", 24, 34, 72, MADERA_OSCURA) + fl("Deciduous tree", 96, 16, 54),
        "Banco de madera del parque bajo un árbol verde.", "Apache-2.0")
    put("peace table", "C",
        fondo_sala() + mesa_prop(46, 54, 68, 28) + nino((36, 30), (36, 42), (36, 60), [[(52, 48)], [(26, 54)]], [[(32, 78)], [(42, 78)]]) + nino((124, 30), (124, 42), (124, 60), [[(108, 48)], [(134, 54)]], [[(118, 78)], [(128, 78)]], camisa=(AZUL, AZUL_OSCURO)) + fl("Dove", 66, 20, 28),
        "Dos niños sentados frente a frente en la mesa de la paz con una paloma.")
    put("picnic", "C",
        fondo_prado() + mantel_cuadros(36, 62, 88, 24) + fl("Basket", 36, 28, 40) + fl("Sandwich", 82, 34, 34) + fl("Red apple", 112, 42, 24),
        "Mantel de pícnic a cuadros sobre el prado con cesta, sándwich y manzana.")
    put("posture", "D",
        fondo_sala() + [R(50, 62, 34, 6, 2, MADERA, MADERA_OSCURA, 1.6), R(50, 32, 6, 36, 2, MADERA, MADERA_OSCURA, 1.6), R(54, 68, 5, 18, 1, MADERA_OSCURA), R(76, 68, 5, 18, 1, MADERA_OSCURA)] + nino((66, 32), (66, 44), (66, 60), [[(80, 52)], [(58, 52)]], [[(80, 64), (82, 84)], [(76, 64), (78, 84)]]) + [L("M106 24 L106 76", VERDE_OSCURO, 2.8), P([(102, 26), (106, 18), (110, 26)], VERDE_OSCURO)],
        "Niño sentado bien recto en una silla con guía vertical de buena postura.")
    put("read in the shade", "C",
        fondo_prado() + [E(88, 78, 34, 8, "#4d7c0f")] + fl("Deciduous tree", 20, 12, 58) + nino((96, 44), (96, 56), (96, 68), [[(82, 60)], [(110, 60)]], [[(90, 78)], [(102, 78)]]) + libro_prop(80, 56, 28, ROJO),
        "Niño sentado leyendo un libro abierto bajo la sombra del árbol.")
    put("rest at the top", "C",
        fondo_cielo() + fl("Mountain", 34, 24, 88) + nino_busto(80, 24),
        "Niño sentado descansando en la cima de la montaña.")
    put("riverbank", "C",
        fondo_prado() + [F("M84 96 C92 70 116 62 146 56 L160 56 L160 100 L80 100 Z", AGUA, AGUA_OSCURO, 2.0)] + nino((48, 38), (48, 50), (48, 66), [[(38, 58)], [(58, 58)]], [[(44, 78)], [(54, 78)]]),
        "Niño sentado tranquilamente en la orilla verde del río.")
    put("rug by the fire", "C",
        fondo_sala() + fl("Fire", 26, 24, 48) + [E(104, 72, 42, 14, ROJO, ROJO_OSCURO, 2.0), E(104, 72, 26, 8, AMARILLO)] + nino((104, 42), (104, 52), (104, 66), [[(94, 58)], [(114, 58)]], [[(98, 72)], [(110, 72)]]),
        "Alfombra cálida junto al fuego con niño sentado encima.")
    put("sit around", "D",
        fondo_prado() + manta_prop(46, 52, 68, "#fde68a", h=32) + nino((34, 40), (34, 50), (34, 64), [[(26, 58)], [(42, 58)]], [[(30, 74)], [(38, 74)]]) + nino((126, 40), (126, 50), (126, 64), [[(118, 58)], [(134, 58)]], [[(122, 74)], [(130, 74)]], camisa=(AZUL, AZUL_OSCURO)),
        "Niños sentados alrededor de la manta extendida.")
    put("sit up", "D",
        fondo_sala() + [R(24, 70, 112, 10, 4, "#bae6fd", AGUA_OSCURO, 1.8)] + bebe_sentado(74, 48, (VERDE, VERDE_OSCURO)) + frecha((106, 68), (106, 32), ROJO, 3.0),
        "Bebé incorporándose hasta quedar sentado con flecha hacia arriba.")
    put("stay in", "C",
        fondo_prado() + fl("House", 44, 16, 72) + nino_busto(80, 58),
        "Niño quedándose dentro de casa tranquilo.")
    put("upright", "D",
        fondo_sala() + [R(26, 72, 108, 10, 4, "#fde68a", NARANJA_OSCURO, 1.8)] + bebe_sentado(74, 46, (AZUL, AZUL_OSCURO)) + [L("M108 26 L108 70", VERDE_OSCURO, 2.8), P([(104, 30), (108, 22), (112, 30)], VERDE_OSCURO)],
        "Bebé sentado bien derecho con guía vertical recta.")
    put("wake up early", "C",
        fondo_cielo() + fl("Sunrise", 20, 14, 46) + fl("Bed", 68, 42, 56) + nino_busto(96, 38, brazos_arriba=True),
        "Sol saliendo al amanecer y niño incorporándose desperezándose en la cama.")
    put("wash your hands before lunch", "C",
        fondo_mesa() + fl("Soap", 20, 26, 32) + fl("Open hands", 18, 52, 36) + frecha((58, 50), (80, 50), VERDE_OSCURO, 2.8) + plato_prop(112, 56, 22) + fl("Red apple", 102, 42, 20),
        "Secuencia de lavarse las manos con jabón antes de pasar al plato de comida.")
    put("window seat", "C",
        fondo_sala() + fl("Window", 54, 10, 52) + [R(36, 62, 88, 18, 4, "#bae6fd", AZUL_OSCURO, 2.0)] + nino_busto(80, 40),
        "Ventana luminosa con banco acolchado abajo y niño sentado en él.")

    # ── Dormir / noche / calma (sleep) ────────────────────────────────────
    put("close your eyes and listen", "D",
        fondo_noite() + cara_dormida(76, 44, 16) + ondas_sonido(48, 40, "#bae6fd", -1) + notas_col([(108, 38), (124, 28)], "#fde047"),
        "Niño con ojos cerrados escuchando notas musicales.")
    put("close your eyes and taste", "D",
        fondo_mesa() + [E(66, 40, 14, 14, PEL, PELB, 2.0), L("M58 38 Q62 41 65 38", TINTA, 1.5), L("M68 38 Q72 41 75 38", TINTA, 1.5), L("M62 46 Q66 49 70 46", "#9a3412", 1.3)] + fl("Strawberry", 96, 36, 36) + frecha((94, 52), (76, 48), ROJO, 2.2),
        "Niño con ojos cerrados probando el sabor de una fresa.")
    put("dream", "C",
        fondo_noite() + nino_acostado(24, 58, (AZUL, AZUL_OSCURO), ojos_cerrados=True) + nube_pensar(108, 30, 30, 20) + fl("Star", 92, 16, 18) + fl("Crescent moon", 112, 18, 18),
        "Niño dormido soñando con nube de estrellas y luna.")
    put("drift off", "C",
        fondo_noite() + ico("tabler", "armchair", 24, 34, 60, "#c4b5fd") + nino_busto(54, 44, ojos="cerrados") + cara_dormida(114, 46, 20, somnolienta=True),
        "Niño quedándose dormido en el sillón con cara somnolienta.", "MIT")
    put("feather bed", "C",
        fondo_noite() + fl("Bed", 38, 32, 68) + fl("Feather", 90, 14, 42),
        "Cama mullida junto a pluma suave cayendo encima.")
    put("good night, moon", "C",
        fondo_noite() + fl("Crescent moon", 24, 14, 40) + fl("Star", 68, 16, 18) + nino((104, 38), (104, 50), (104, 68), [[(86, 24)], [(116, 58)]], [[(98, 86)], [(110, 86)]]),
        "Luna creciente brillante en la noche con niño despidiéndose.")
    put("imagine the old ships", "C",
        fondo_cielo("#dbeafe") + nino((36, 46), (36, 58), (36, 74), [[(26, 62)], [(46, 62)]], [[(30, 88)], [(42, 88)]]) + nube_pensar(104, 32, 34, 22) + fl("Sailboat", 86, 16, 36),
        "Niño imaginando en su nube de pensamiento un barco antiguo de vela.")
    put("lay down", "D",
        fondo_noite() + [R(24, 66, 112, 14, 5, "#bae6fd", AZUL_OSCURO, 2.0)] + bebe(76, 56, "#fbcfe8", ROSA_OSCURO) + frecha((80, 22), (80, 44), AZUL_OSCURO, 2.8),
        "Bebé acostado suavemente boca arriba sobre el colchón.")
    put("lights out, eyes closed", "C",
        fondo_noite() + fl("Light bulb", 28, 20, 44) + [L("M26 18 L74 66", ROJO, 3.0)] + cara_dormida(112, 48, 22),
        "Bombilla apagada con señal roja y cara con ojos cerrados durmiendo.")
    put("lullaby", "C",
        fondo_noite() + bebe(52, 54) + fl("Crescent moon", 24, 12, 32) + notas_col([(92, 42), (114, 30), (128, 44)], "#fde047"),
        "Bebé dormido bajo la luna entre notas suaves de nana.")
    put("make a wish on a star", "C",
        fondo_noite() + fl("Shooting star", 78, 12, 54) + nino((46, 42), (46, 54), (46, 72), [[(36, 60)], [(56, 60)]], [[(40, 88)], [(52, 88)]]),
        "Niño mirando una estrella fugaz en el cielo nocturno.")
    put("nap", "C",
        fondo_sala() + ico("tabler", "pillow", 26, 42, 50, AZUL_OSCURO) + cara_dormida(108, 48, 22),
        "Almohada blanda y cara dormida echando la siesta.", "MIT")
    put("rest time", "C",
        fondo_sala() + [R(22, 64, 96, 16, 6, "#bae6fd", AZUL_OSCURO, 2.0)] + manta_prop(38, 54, 58, "#fde68a") + fl("Hourglass not done", 116, 22, 32),
        "Colchoneta y manta de descanso junto al reloj de arena.")
    put("sleep like the moon", "C",
        fondo_noite() + fl("Crescent moon", 32, 18, 50) + nino_acostado(68, 54, (AZUL, AZUL_OSCURO), ojos_cerrados=True),
        "Luna creciente acompañando al niño que duerme sereno.")
    put("sleeping animal", "C",
        fondo_noite() + fl("Fox", 32, 24, 54) + cara_dormida(114, 48, 20),
        "Zorro descansando tranquilo junto al gesto de ojos cerrados.")
    put("sleepyhead", "C",
        fondo_noite() + fl("Person in bed", 46, 18, 68),
        "Persona acurrucada en la cama bien arropada.")
    put("sound asleep", "C",
        fondo_noite() + fl("Bed", 24, 34, 68) + cara_dormida(112, 52, 20) + fl("Crescent moon", 116, 12, 24),
        "Cama con persona profundamente dormida bajo la luna.")
    put("the deeper you go, the darker it gets", "D",
        [R(0, 0, 160, 34, 0, "#38bdf8"), R(0, 34, 160, 33, 0, "#0369a1"), R(0, 67, 160, 33, 0, "#0f172a")] + frecha((30, 14), (30, 86), "#fde047", 3.2) + fl("Tropical fish", 72, 12, 26) + fl("Fish", 96, 66, 30),
        "Gradiente marino desde luz clara arriba hasta fondo oscuro abajo con flecha descendente.")

    # ── Oler (smell) ──────────────────────────────────────────────────────
    put("bakery", "C",
        fondo_mesa() + fl("Bread", 30, 26, 48) + fl("Croissant", 84, 28, 48) + ondas_calor(68, 20, NARANJA_OSCURO),
        "Pan y cruasán recién horneados echando aroma tibio.")
    put("earthy", "C",
        fondo_prado() + [F("M30 82 Q80 34 130 82 Z", TIERRA, BARRO, 2.2)] + fl("Seedling", 64, 22, 34) + ondas_calor(98, 32, VERDE_OSCURO),
        "Montículo de tierra húmeda con brote verde y aroma natural.")
    put("fragrant", "C",
        fondo_prado() + fl("Blossom", 34, 24, 48) + nino((100, 34), (100, 46), (100, 66), [[(86, 48)], [(114, 58)]], [[(94, 88)], [(106, 88)]]) + ondas_calor(76, 30, ROSA_OSCURO),
        "Flor perfumada desprendiendo aroma hacia niño que la huele.")
    put("fresh from the farm", "C",
        fondo_prado() + ico("mdi", "barn", 24, 22, 54, ROJO_OSCURO) + fl("Red apple", 86, 36, 32) + fl("Carrot", 116, 36, 32),
        "Granero rojo de granja con manzana y zanahoria frescas.", "Apache-2.0")
    put("freshly picked", "C",
        fondo_prado() + [L("M24 26 L98 34", MADERA_OSCURA, 4.0)] + fl("Red apple", 46, 26, 44) + fl("Leaf fluttering in wind", 94, 24, 34) + frecha((70, 74), (70, 88), VERDE_OSCURO, 2.4),
        "Manzana recién cogida de la rama con hoja verde.")
    put("it smells good", "C",
        fondo_prado() + nino((52, 34), (52, 46), (52, 66), [[(68, 44)], [(38, 56)]], [[(46, 88)], [(58, 88)]]) + fl("Blossom", 92, 30, 40) + ondas_calor(76, 32, VERDE_OSCURO),
        "Niño oliendo encantado el buen olor que llega de una flor.")
    put("mmm, orange", "C",
        fondo_mesa() + fl("Tangerine", 32, 24, 52) + ondas_calor(88, 36, NARANJA_OSCURO) + nino((114, 34), (114, 46), (114, 66), [[(100, 48)], [(128, 58)]], [[(108, 88)], [(120, 88)]]),
        "Naranja fresca con aroma cítrico hacia niño contento.")
    put("nutty", "C",
        fondo_mesa() + fl("Chestnut", 48, 26, 52) + ondas_calor(106, 34, BARRO),
        "Fruto seco de cáscara marrón soltando aroma tostado.")
    put("salty shell", "C",
        fondo_mar() + fl("Spiral shell", 36, 28, 50) + ondas_calor(66, 20, AGUA_OSCURO) + fl("Salt", 98, 28, 42),
        "Concha marina soltando olor salado junto a salero.")
    put("smell", "C",
        fondo_prado() + nino((46, 34), (46, 46), (46, 66), [[(66, 42)], [(32, 58)]], [[(40, 88)], [(52, 88)]]) + ondas_calor(74, 38, MORADO) + fl("Rose", 94, 24, 46),
        "Niño acercándose a oler una rosa con líneas de aroma.")
    put("sniff out", "C",
        fondo_prado() + fl("Dog", 30, 26, 54) + [L("M86 58 L108 58", TIERRA, 2.4)] + fl("Bone", 108, 42, 34),
        "Perro olfateando el rastro hasta descubrir un hueso.")
    put("sun-dried", "C",
        fondo_cielo() + fl("Sun", 16, 10, 32) + [L("M24 44 L140 44", MADERA_OSCURA, 2.2)] + fl("T-shirt", 48, 44, 40) + toalla_prop(96, 44, 34) + lineas_viento(104, 24, 28, AZUL_OSCURO),
        "Ropa y toalla colgadas secándose al sol y al viento.")
    put("sweet-smelling", "C",
        fondo_prado() + fl("Hibiscus", 46, 22, 54) + ondas_calor(104, 34, ROSA_OSCURO),
        "Flor de hibisco desprendiendo aroma dulce.")
    put("sweet-smelling baby", "C",
        fondo_sala() + bebe(54, 48, "#fbcfe8", ROSA_OSCURO) + fl("Blossom", 96, 26, 38) + ondas_calor(72, 28, ROSA_OSCURO),
        "Bebé limpio con aroma dulce de flor.")

    # ── Asentir / sorpresa / otros gestos claros (nod_head / surprised_face) ──
    put("jack-in-the-box", "D",
        fondo_sala() + [R(54, 52, 52, 34, 4, ROJO, ROJO_OSCURO, 2.2), R(50, 48, 60, 8, 2, AMARILLO, NARANJA_OSCURO, 1.8), L("M80 48 L72 42 L88 36 L72 30 L80 24", GRIS_OSCURO, 2.6), E(80, 18, 10, 10, PEL, PELB, 2.0), E(77, 17, 1.2, 1.2, TINTA), E(83, 17, 1.2, 1.2, TINTA), E(80, 20, 2.5, 2.0, ROJO), P([(68, 12), (80, 2), (92, 12)], AZUL, AZUL_OSCURO, 1.8)],
        "Caja sorpresa abierta con muelle y muñeco saltando de golpe.")
    put("look, a butterfly", "C",
        fondo_prado() + nino((46, 36), (46, 48), (46, 68), [[(68, 30)], [(32, 58)]], [[(40, 88)], [(52, 88)]]) + frecha((70, 28), (94, 22), ROJO, 2.4) + fl("Butterfly", 94, 12, 44),
        "Niño señalando con sorpresa una mariposa volando arriba.")
    put("salty", "C",
        fondo_mesa() + fl("Salt", 20, 26, 38) + [E(58, 66, 2.2, 2.2, BLANCO, GRIS_OSCURO, 1.0), E(66, 70, 2.2, 2.2, BLANCO, GRIS_OSCURO, 1.0)] + fl("Astonished face", 66, 22, 42) + [R(116, 36, 20, 34, 3, "#e0f2fe", AGUA_OSCURO, 2.0), R(118, 48, 16, 20, 2, AGUA)],
        "Salero, gesto de sorpresa al probar algo salado y vaso de agua.")
    put("music", "C",
        fondo_sala() + fl("Musical notes", 36, 22, 50) + fl("Headphone", 84, 22, 50),
        "Notas musicales junto a auriculares.")
    put("nod", "D",
        fondo_sala() + nino((80, 34), (80, 48), (80, 68), [[(66, 58)], [(94, 58)]], [[(74, 88)], [(86, 88)]]) + [L("M52 20 Q44 32 52 44", AZUL_OSCURO, 2.4), P([(48, 22), (56, 22), (52, 16)], AZUL_OSCURO), P([(48, 42), (56, 42), (52, 48)], AZUL_OSCURO)],
        "Niño asintiendo arriba y abajo con flecha vertical doble junto a la cabeza.")
    put("tasty", "C",
        fondo_mesa() + fl("Face savoring food", 36, 22, 52) + fl("Strawberry", 94, 28, 42),
        "Cara saboreando comida rica junto a una fresa.")
    put("wasteful habit", "C",
        fondo_sala() + [L("M34 22 L34 34", GRIS_OSCURO, 4.5)] + gotas([(34, 40), (34, 56), (34, 72)]) + papelera_prop(92, 44, 34) + [L("M82 22 L126 66", ROJO, 3.0), L("M126 22 L82 66", ROJO, 3.0)],
        "Agua desperdiciándose y basura con aspa roja de mal hábito.")

    put("finger on lips", "D",
        fondo_sala() + cara_silencio(80, 46, 24),
        "Niño con el dedo índice vertical tocando los labios en gesto de silencio.")
    put("sleepy-eyed", "D",
        fondo_noite() + cara_dormida(80, 48, 24, somnolienta=True),
        "Rostro con ojitos pesados de sueño.")
    return m


ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = _escenas()

# ── Piezas auditadas SIN base visual clara (se dejan SIN lámina para Frank) ──
SIN_BASE: dict[str, str] = {
    "childhood": "Concepto abstracto («Infancia», gesto encogerse pequeño); no se distingue de niño sin texto.",
    "lose": "Concepto abstracto («Perder», encoger hombros); ambiguo sin texto.",
    "off-stage": "Concepto teatral abstracto («Fuera de escena»).",
    "ready, steady, go": "Consigna oral («¡Preparados, listos, ya!»); no tiene objeto o escena única.",
    "silly story": "Concepto abstracto («Historia disparatada»).",
    "what colour is it": "Pregunta abierta («¿De qué color es?»); sin objeto específico.",
    "what will happen if it gets warm": "Pregunta hipotética abstracta.",
    "where are you going": "Pregunta conversacional abierta.",
    "why do we wash our hands": "Pregunta causal abstracta.",
    "younger": "Adjetivo comparativo abstracto («Más joven») sin pareja fija.",
    "plan": "Homónimo ambiguo («Plano / plan»); además «blueprint» ya cubre el plano dibujado.",
    "listen, what's that": "Pregunta abierta de misterio sonoro sin objeto.",
    "reaction": "Sustantivo abstracto («Reacción»).",
    "ready, go": "Consigna de arranque oral sin referente visual único.",
    "respectful": "Adjetivo moral abstracto («Respetuoso»).",
    "tune in": "Expresión idiomática abstracta («Prestar atención»).",
    "we listen because we care": "Frase moral abstracta.",
    "what's inside": "Pregunta abierta sobre contenido oculto.",
    "here i am": "Exclamación conversacional («¡Aquí estoy!»).",
    "here's grandad": "Exclamación conversacional sobre foto sin imagen real del abuelo.",
    "out of sight": "Frase espacial abstracta («Fuera de la vista»).",
    "where did he go": "Pregunta conversacional abierta.",
    "gaze": "Matiz sutil («Mirar fijamente»); indistinguible de mirar sin texto.",
    "hushed": "Adjetivo sinónimo de «hush» / «silent room» sin escena propia distinta.",
    "upright posture": "Duplicado exacto de «posture» / «upright».",
    "imagine": "Verbo mental abstracto («Imaginar»).",
    "imagine long ago": "Verbo mental abstracto temporal («Imaginar hace mucho»).",
    "listen with your eyes closed": "Duplicado literal de «close your eyes and listen».",
    "peaceful mind": "Concepto mental abstracto («Mente tranquila»).",
    "restful": "Adjetivo abstracto («Relajante»).",
    "where did i go": "Pregunta conversacional abierta («¿Dónde estoy?»).",
    "aromatic": "Sinónimo abstracto de «fragrant» / «sweet-smelling».",
    "fresh and clean": "Adjetivo abstracto difícil de distinguir sin texto frente a «wash your hands».",
    "fresh-smelling": "Sinónimo de olor a limpio sin objeto único.",
    "bitter": "Sabor amargo difícil de distinguir visualmente sin texto de agrio o disgusto.",
    "agree": "Verbo abstracto («Estar de acuerdo»).",
    "agreed": "Adjetivo/participio abstracto («Acordado»).",
    "decide": "Verbo mental abstracto («Decidir»).",
    "disagree kindly": "Matiz social abstracto («Discrepar con amabilidad»).",
    "disagreement": "Sustantivo abstracto («Desacuerdo»).",
    "mild": "Adjetivo abstracto («Suave» aplicado al gesto/clima).",
    "remember": "Verbo mental abstracto («Recordar»).",
    "understanding": "Adjetivo/sustantivo abstracto («Comprensivo»).",
}
