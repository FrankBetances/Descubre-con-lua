#!/usr/bin/env python3
"""Genera las 50 láminas nuevas de P7.7 (Escoita 100 % STEAM + cierre de Valeria):
  - 46 nuevas palabras de assets/content/escoita/plan_mensual.json (P7.6):
    bandage, bit, blade, boy, bubble, bug, bulb, bush, cloth, colorful, dish,
    dust, filter, flashlight, flute, four, frame, fun, grid, jar, large, lash,
    lens, lid, nip, outline, phone, pie, piece, pile, pole, press, rail,
    rainstick, ready, sale, sheet, six, snip, stone, stretcher, tip, tone, top,
    wear, windy.
  - 4 palabras del banco inglés de Valeria que seguían con lamina=null:
    jacket, shoulder, sock, tummy.

Todas con clave pal_<palabra_con_guiones_bajos>, sin texto ni números, sin
sobrescribir láminas ya existentes. Fuentes permitidas: Fluent Emoji Flat (MIT)
y dibujo vectorial propio estilo Lúa.
"""
from __future__ import annotations

import json
import math
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from PIL import Image, ImageDraw, ImageFont  # noqa: E402
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
    LAMINAS_DIR,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
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
    escribir_cd,
    escribir_fluent_directo,
    fl,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    molinillo,
    notas,
    pompas,
    sol,
)
from tpr_tandas.comun_tpr import (  # noqa: E402
    DORADO,
    NARANJA,
    NARANJA_OSCURO,
    NEGRO,
    PLATA,
    ROSA,
    ROSA_OSCURO,
    nino_busto,
    ondas_sonido,
    plato_prop,
    toalla_prop,
)

SCRIPT_REF = "tools/gen_laminas_escoita_2.py"

# 1) Directas de Fluent Emoji Flat (MIT)
FLUENT_DIRECTOS: list[tuple[str, str, str, str, str]] = [
    ("bandage", "bandage", "Adhesive bandage", "venda adhesiva", "Tirita adhesiva plana limpia para vendar."),
    ("boy", "boy", "Boy", "neno", "Niño sonriente en primer plano."),
    ("bubble", "bubble", "Bubbles", "burbullas", "Burbujas de jabón iridiscentes flotando."),
    ("bug", "bug", "Bug", "bicho", "Oruga verde simpática de perfil."),
    ("bulb", "bulb", "Light bulb", "lámpada", "Bombilla amarilla encendida."),
    ("flashlight", "flashlight", "Flashlight", "lanterna", "Linterna clásica encendida."),
    ("flute", "flute", "Flute", "frauta", "Flauta horizontal dorada."),
    ("frame", "frame", "Framed picture", "marco", "Marco dorado rodeando un paisaje."),
    ("jar", "jar", "Jar", "bote", "Bote de cristal transparente con tapa."),
    ("phone", "phone", "Telephone", "teléfono", "Teléfono clásico rojo."),
    ("pie", "pie", "Pie", "torta", "Tarta redonda horneada."),
    ("piece", "piece", "Puzzle piece", "peza", "Pieza verde de puzle encajable."),
    ("sock", "sock", "Socks", "calcetín", "Par de calcetines de rayas."),
    ("stone", "stone", "Rock", "pedra", "Piedra gris redondeada y pesada."),
    ("windy", "windy", "Wind face", "ventoso", "Escena de viento fuerte soplando espirales de aire y hojas."),
]

# 2) Compuestas / propias (C = Fluent + formas Lúa; D = vectorial puro Lúa), todas 160x100 sin texto
ESCENAS_CD: dict[str, tuple[str, str, list[dict], str]] = {
    "bit": (
        "bit", "D",
        fondo_mesa()
        + [
            R(26, 36, 56, 32, 6, TIERRA_CLARA, TIERRA, 2.2),
            R(30, 40, 48, 24, 4, "#fef3c7"),
            # Miga pequeña separada a la derecha con halo de destaque
            E(118, 52, 22, 22, "#f8fafc", GRIS_OSCURO, 1.5),
            P([(111, 47), (124, 45), (126, 57), (112, 58)], TIERRA_CLARA, TIERRA, 2.0),
        ]
        + frecha((86, 52), (102, 52), NARANJA_OSCURO, 2.4),
        "Galleta entera a la izquierda y un trocito diminuto separado dentro de un círculo.",
    ),
    "blade": (
        "blade", "D",
        fondo_cielo()
        + [
            L("M74 52 L74 92", MADERA_OSCURA, 3.5),
            # 3 aspas suaves
            P([(74, 52), (52, 34), (44, 54)], "#cbd5e1", GRIS_OSCURO, 1.5),
            P([(74, 52), (96, 70), (104, 50)], "#cbd5e1", GRIS_OSCURO, 1.5),
            P([(74, 52), (56, 74), (76, 82)], "#cbd5e1", GRIS_OSCURO, 1.5),
            # Aspa superior destacada en rojo vivo con aro dorado
            P([(74, 52), (92, 26), (72, 18)], ROJO, ROJO_OSCURO, 2.4),
            E(74, 52, 4, 4, BLANCO, TINTA, 1.8),
            E(82, 32, 18, 18, None, DORADO, 2.2),
        ],
        "Molinillo con tres aspas suaves y una aspa roja destacada con aro dorado.",
    ),
    "bush": (
        "bush", "D",
        fondo_prado()
        + [
            E(58, 58, 22, 18, VERDE, VERDE_OSCURO, 2.2),
            E(98, 58, 22, 18, VERDE, VERDE_OSCURO, 2.2),
            E(78, 46, 26, 22, "#4ade80", VERDE_OSCURO, 2.2),
            E(78, 66, 36, 12, VERDE),
            L("M44 74 L114 74", VERDE_OSCURO, 2.4),
            E(66, 48, 3, 3, ROJO),
            E(92, 54, 3, 3, ROJO),
            E(78, 60, 3, 3, ROJO),
        ],
        "Arbusto verde frondoso con bayas rojas sobre el prado.",
    ),
    "cloth": (
        "cloth", "D",
        fondo_mesa()
        + [
            R(36, 24, 88, 54, 6, AZUL, AZUL_OSCURO, 2.4),
            P([(40, 26), (120, 26), (112, 42), (48, 42)], "#93c5fd", AZUL_OSCURO, 1.8),
        ]
        + [L(f"M42 {y} L118 {y}", "#60a5fa", 1.2) for y in range(48, 74, 8)]
        + [L(f"M{x} 42 L{x} 74", "#60a5fa", 1.2) for x in range(52, 115, 14)],
        "Tela cuadrada azul doblada con textura de tejido.",
    ),
    "colorful": (
        "colorful", "C",
        fondo_cielo()
        + fl("Rainbow", 44, 14, 72)
        + fl("Sparkles", 22, 24, 24)
        + fl("Sparkles", 114, 24, 24)
        + [
            E(34, 76, 7, 7, ROJO, TINTA, 1.5),
            E(56, 76, 7, 7, AMARILLO, TINTA, 1.5),
            E(78, 76, 7, 7, VERDE, TINTA, 1.5),
            E(100, 76, 7, 7, AZUL, TINTA, 1.5),
            E(122, 76, 7, 7, MORADO, TINTA, 1.5),
        ],
        "Arcoíris y cinco círculos de colores brillantes sin texto.",
    ),
    "dish": (
        "dish", "D",
        fondo_mesa()
        + [
            E(80, 60, 48, 22, BLANCO, AZUL_OSCURO, 2.4),
            E(80, 58, 38, 16, "#e0f2fe", AZUL, 1.8),
            E(80, 58, 26, 10, BLANCO, "#bae6fd", 1.2),
        ],
        "Plato hondo ancho de cerámica blanca y azul visto desde arriba.",
    ),
    "dust": (
        "dust", "C",
        fondo_prado()
        + [
            R(26, 60, 34, 10, 3, AMARILLO, NARANJA_OSCURO, 1.8),
            R(34, 68, 34, 10, 3, ROSA, ROSA_OSCURO, 1.8),
            E(92, 54, 12, 10, "#fef08a", AMARILLO_OSCURO, 1.2),
            E(108, 46, 14, 12, "#fbcfe8", ROSA_OSCURO, 1.2),
            E(118, 60, 11, 9, "#bae6fd", AZUL, 1.2),
            E(84, 42, 4, 4, AMARILLO),
            E(98, 34, 3, 3, ROSA),
            E(126, 44, 3.5, 3.5, AZUL),
        ]
        + frecha((64, 58), (82, 50), GRIS_OSCURO, 2.0),
        "Tizas de colores soltando nubes y partículas de polvo colorido.",
    ),
    "filter": (
        "filter", "C",
        fondo_noite()
        + fl("Flashlight", 14, 34, 34)
        + [
            P([(48, 42), (78, 24), (78, 76), (48, 56)], "#fef9c3"),
            R(76, 16, 12, 68, 3, ROJO, ROJO_OSCURO, 2.0),
            P([(88, 24), (144, 12), (144, 88), (88, 76)], "#fca5a5"),
        ],
        "Linterna proyectando haz blanco que se vuelve rojo al pasar por un filtro transparente.",
    ),
    "four": (
        "four", "D",
        fondo_mesa()
        + [
            R(44, 18, 28, 26, 4, ROJO, ROJO_OSCURO, 2.0),
            R(88, 18, 28, 26, 4, AZUL, AZUL_OSCURO, 2.0),
            R(44, 54, 28, 26, 4, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(88, 54, 28, 26, 4, VERDE, VERDE_OSCURO, 2.0),
        ],
        "Exactamente cuatro bloques de madera de colores en 2x2 sin dígitos.",
    ),
    "fun": (
        "fun", "C",
        fondo_cielo()
        + fl("Party popper", 24, 32, 44)
        + fl("Balloon", 68, 14, 44)
        + fl("Sparkles", 104, 26, 36)
        + [
            E(58, 26, 4, 4, ROJO),
            E(104, 68, 4, 4, AZUL),
            E(72, 74, 4, 4, AMARILLO),
        ],
        "Lanzador de confeti, globo y chispas celebrando el juego.",
    ),
    "grid": (
        "grid", "D",
        fondo_mesa()
        + [R(30, 14, 100, 72, 4, "#fffbeb", MADERA_OSCURA, 2.2)]
        + [L(f"M{x} 14 L{x} 86", GRIS_OSCURO, 1.6) for x in (55, 80, 105)]
        + [L(f"M30 {y} L130 {y}", GRIS_OSCURO, 1.6) for y in (38, 62)]
        + [
            E(92.5, 50, 7, 7, ROJO, ROJO_OSCURO, 1.8),
        ],
        "Mapa en cuadrícula de 4x3 casillas con una marca roja en una celda.",
    ),
    "jacket": (
        "jacket", "D",
        fondo_sala()
        + [
            P([(48, 26), (34, 62), (46, 66), (56, 40)], AZUL, AZUL_OSCURO, 2.0),
            P([(112, 26), (126, 62), (114, 66), (104, 40)], AZUL, AZUL_OSCURO, 2.0),
            R(52, 22, 56, 58, 6, AZUL, AZUL_OSCURO, 2.2),
            P([(62, 16), (80, 26), (98, 16), (94, 28), (80, 32), (66, 28)], AMARILLO, AMARILLO_OSCURO, 1.8),
            L("M80 28 L80 80", AMARILLO, 2.6),
            R(58, 56, 14, 12, 2, "#60a5fa", AZUL_OSCURO, 1.4),
            R(88, 56, 14, 12, 2, "#60a5fa", AZUL_OSCURO, 1.4),
        ],
        "Chaqueta azul con cuello amarillo, cremallera central y dos bolsillos.",
    ),
    "large": (
        "large", "C",
        fondo_cielo()
        + fl("Leaf fluttering in wind", 18, 42, 24)
        + frecha((46, 52), (66, 52), NARANJA_OSCURO, 2.4)
        + [
            E(106, 48, 34, 34, BLANCO, TINTA, 2.4),
            L("M130 72 L146 88", MADERA_OSCURA, 4.5),
        ]
        + fl("Leaf fluttering in wind", 78, 20, 56),
        "Hoja pequeña a la izquierda ampliada en grande dentro de una lupa a la derecha.",
    ),
    "lash": (
        "lash", "D",
        fondo_sala()
        + [
            E(80, 54, 46, 22, BLANCO, TINTA, 2.4),
            E(80, 54, 14, 14, AZUL, AZUL_OSCURO, 2.0),
            E(80, 54, 6, 6, NEGRO),
            E(84, 50, 2.5, 2.5, BLANCO),
            L("M52 38 L46 22", TINTA, 2.8),
            L("M66 33 L62 16", TINTA, 2.8),
            L("M80 31 L80 14", TINTA, 2.8),
            L("M94 33 L98 16", TINTA, 2.8),
            L("M108 38 L114 22", TINTA, 2.8),
            E(80, 22, 34, 12, None, NARANJA_OSCURO, 1.8),
        ],
        "Ojo en primer plano con las pestañas superiores largas resaltadas.",
    ),
    "lens": (
        "lens", "C",
        fondo_sala()
        + fl("Magnifying glass tilted left", 46, 16, 68)
        + [
            E(68, 38, 12, 12, "#e0f2fe"),
        ],
        "Lupa de plástico enfocada con brillo azul en el cristal.",
    ),
    "lid": (
        "lid", "D",
        fondo_mesa()
        + [
            R(56, 38, 48, 46, 6, "#e0f2fe", AGUA_OSCURO, 2.2),
            R(62, 34, 36, 8, 2, GRIS, GRIS_OSCURO, 1.8),
            # Tapa levantada encima
            R(56, 12, 48, 10, 4, ROJO, ROJO_OSCURO, 2.2),
            R(72, 7, 16, 6, 2, AMARILLO, AMARILLO_OSCURO, 1.6),
        ]
        + frecha((116, 26), (116, 12), NARANJA_OSCURO, 2.2),
        "Bote de cristal abierto con la tapa roja levantada encima.",
    ),
    "nip": (
        "nip", "C",
        fondo_mesa()
        + [R(22, 44, 72, 40, 3, "#fef3c7", MADERA_OSCURA, 2.0)]
        + fl("Pinching hand", 68, 18, 54),
        "Mano en pinza dando un pellizco suave a la esquina de una hoja.",
    ),
    "outline": (
        "outline", "D",
        fondo_mesa()
        + [
            # Torre sólida a la izquierda
            R(28, 38, 26, 42, 2, AZUL, AZUL_OSCURO, 2.0),
            R(34, 22, 14, 16, 2, AZUL, AZUL_OSCURO, 2.0),
            # Papel a la derecha con contorno punteado/limpio sin relleno
            R(84, 14, 54, 72, 4, BLANCO, GRIS_OSCURO, 1.8),
            R(98, 38, 26, 42, 2, None, ROJO_OSCURO, 2.4),
            R(104, 22, 14, 16, 2, None, ROJO_OSCURO, 2.4),
        ]
        + frecha((62, 50), (78, 50), NARANJA_OSCURO, 2.2),
        "Bloque sólido a la izquierda y solo su contorno dibujado en rojo a la derecha.",
    ),
    "pile": (
        "pile", "D",
        fondo_sala()
        + [
            R(38, 62, 24, 18, 2, ROJO, ROJO_OSCURO, 2.0),
            R(66, 62, 24, 18, 2, AZUL, AZUL_OSCURO, 2.0),
            R(94, 62, 24, 18, 2, VERDE, VERDE_OSCURO, 2.0),
            R(50, 44, 24, 18, 2, AMARILLO, AMARILLO_OSCURO, 2.0),
            R(82, 44, 24, 18, 2, MORADO, TINTA, 2.0),
            R(66, 26, 24, 18, 2, NARANJA, NARANJA_OSCURO, 2.0),
        ],
        "Montón apilado en pirámide de seis bloques de colores.",
    ),
    "pole": (
        "pole", "D",
        fondo_prado()
        + [
            P([(24, 66), (132, 28), (136, 38), (28, 76)], MADERA, MADERA_OSCURA, 2.4),
            L("M40 65 L120 37", TIERRA, 1.5),
        ],
        "Palo largo de madera apoyado en diagonal sobre la hierba.",
    ),
    "press": (
        "press", "C",
        fondo_mesa()
        + [
            # Pan suave hundiéndose arriba bajo la mano
            E(80, 68, 42, 14, TIERRA_CLARA, TIERRA, 2.2),
            E(80, 64, 34, 8, "#fef3c7"),
        ]
        + frecha((40, 26), (40, 54), ROJO_OSCURO, 2.6)
        + fl("Raised back of hand", 56, 16, 46),
        "Mano apretando hacia abajo un bollo blando con flecha de presión.",
    ),
    "rail": (
        "rail", "D",
        fondo_sala()
        + [
            R(40, 44, 8, 40, 2, MADERA, MADERA_OSCURA, 2.0),
            R(112, 44, 8, 40, 2, MADERA, MADERA_OSCURA, 2.0),
            R(22, 34, 116, 12, 4, MADERA_OSCURA, TINTA, 2.2),
            L("M28 40 L132 40", MADERA, 2.5),
        ],
        "Barandilla horizontal de madera sobre dos postes en la sala.",
    ),
    "rainstick": (
        "rainstick", "C",
        fondo_sala()
        + [
            P([(30, 68), (118, 20), (128, 36), (40, 84)], MADERA, MADERA_OSCURA, 2.2),
            E(58, 64, 3, 3, BLANCO),
            E(72, 56, 3, 3, BLANCO),
            E(86, 48, 3, 3, BLANCO),
            E(100, 40, 3, 3, BLANCO),
        ]
        + gotas([(46, 28), (112, 62)]),
        "Tubo palo de lluvia con granos blancos dentro y gotas alrededor.",
    ),
    "ready": (
        "ready", "C",
        fondo_mesa()
        + plato_prop(72, 56, 26)
        + fl("Spoon", 104, 36, 36)
        + [
            E(128, 24, 14, 14, VERDE, VERDE_OSCURO, 2.0),
            L("M122 24 L126 29 L135 19", BLANCO, 2.8),
        ],
        "Mesa lista con plato, cuchara y marca verde de verificación.",
    ),
    "sale": (
        "sale", "C",
        fondo_sala()
        + fl("Shopping bags", 34, 24, 52)
        + fl("Label", 86, 26, 46)
        + [
            E(124, 68, 10, 10, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(112, 74, 9, 9, DORADO, MADERA_OSCURA, 1.8),
        ],
        "Bolsas, etiqueta lisa sin texto y monedas de tienda.",
    ),
    "sheet": (
        "sheet", "D",
        fondo_mesa()
        + [
            R(44, 14, 72, 74, 2, BLANCO, GRIS_OSCURO, 2.2),
            P([(98, 14), (116, 32), (98, 32)], GRIS, GRIS_OSCURO, 1.8),
            L("M56 36 L94 36", "#cbd5e1", 2.0),
            L("M56 50 L104 50", "#cbd5e1", 2.0),
            L("M56 64 L104 64", "#cbd5e1", 2.0),
        ],
        "Hoja de papel blanca con esquina doblada sobre la mesa.",
    ),
    "shoulder": (
        "shoulder", "D",
        fondo_sala()
        + [
            E(80, 26, 16, 16, PEL, PELB, 2.0),
            E(80, 18, 16, 8, "#5a3a1a"),
            R(50, 44, 60, 44, 14, ROJO, ROJO_OSCURO, 2.2),
            E(54, 52, 12, 11, None, DORADO, 2.8),
        ]
        + frecha((22, 34), (42, 46), NARANJA_OSCURO, 2.6),
        "Niño en primer plano con un aro dorado y flecha señalando su hombro.",
    ),
    "six": (
        "six", "D",
        fondo_mesa()
        + [
            E(44, 34, 12, 12, ROJO, ROJO_OSCURO, 2.0),
            E(80, 34, 12, 12, AMARILLO, AMARILLO_OSCURO, 2.0),
            E(116, 34, 12, 12, VERDE, VERDE_OSCURO, 2.0),
            E(44, 66, 12, 12, AZUL, AZUL_OSCURO, 2.0),
            E(80, 66, 12, 12, MORADO, TINTA, 2.0),
            E(116, 66, 12, 12, NARANJA, NARANJA_OSCURO, 2.0),
        ],
        "Seis fichas circulares de colores en dos filas de tres sin números.",
    ),
    "snip": (
        "snip", "C",
        fondo_mesa()
        + [
            R(26, 24, 82, 54, 3, BLANCO, GRIS_OSCURO, 2.0),
            L("M34 50 L48 50", ROJO, 2.2),
            L("M54 50 L68 50", ROJO, 2.2),
            L("M74 50 L88 50", ROJO, 2.2),
        ]
        + fl("Scissors", 78, 22, 56),
        "Tijeras recortando una hoja de papel por una línea discontinua.",
    ),
    "stretcher": (
        "stretcher", "C",
        fondo_prado()
        + [
            L("M24 64 L136 64", MADERA_OSCURA, 4.0),
            R(36, 54, 88, 14, 4, AZUL, AZUL_OSCURO, 2.2),
            E(24, 64, 5, 5, MADERA, MADERA_OSCURA, 1.6),
            E(136, 64, 5, 5, MADERA, MADERA_OSCURA, 1.6),
        ]
        + fl("Teddy bear", 58, 18, 42),
        "Camilla de tela azul con mangos de madera llevando un osito paciente.",
    ),
    "tip": (
        "tip", "D",
        fondo_sala()
        + [
            P([(30, 18), (92, 18), (76, 62), (18, 62)], AGUA, AGUA_OSCURO, 2.2),
            # Punta inferior derecha destacada entrando en un barreño de agua
            R(44, 68, 76, 22, 4, "#e0f2fe", AZUL_OSCURO, 2.0),
            E(76, 62, 16, 12, None, ROJO_OSCURO, 2.4),
        ]
        + frecha((116, 36), (88, 56), NARANJA_OSCURO, 2.2),
        "Punta de una tela destacada con un aro rojo y una flecha.",
    ),
    "tone": (
        "tone", "C",
        fondo_sala()
        + fl("Bell", 34, 28, 44)
        + ondas_sonido(84, 50, NARANJA_OSCURO)
        + notas([(116, 40), (128, 56)]),
        "Campana emitiendo ondas sonoras suaves y notas musicales.",
    ),
    "top": (
        "top", "D",
        fondo_mesa()
        + [
            P([(48, 46), (112, 46), (80, 74)], ROJO, ROJO_OSCURO, 2.2),
            P([(56, 46), (104, 46), (80, 56)], AMARILLO, AMARILLO_OSCURO, 1.8),
            L("M80 18 L80 46", MADERA_OSCURA, 4.0),
            E(80, 76, 3, 3, GRIS_OSCURO),
            # Arcos de giro
            L("M42 36 Q80 26 118 36", AZUL, 2.2),
            L("M52 28 Q80 20 108 28", AZUL_OSCURO, 2.0),
        ],
        "Peonza de cartón rojo y amarillo con eje de lápiz girando.",
    ),
    "tummy": (
        "tummy", "D",
        fondo_sala()
        + [
            E(80, 26, 15, 15, PEL, PELB, 2.0),
            R(60, 42, 40, 42, 12, VERDE, VERDE_OSCURO, 2.2),
            # Barriguita resaltada
            E(80, 62, 14, 12, "#bbf7d0", DORADO, 2.4),
            # Brazos hacia la barriga
            L("M60 48 L70 62", PELB, 4.0),
            L("M100 48 L90 62", PELB, 4.0),
        ]
        + frecha((28, 62), (58, 62), NARANJA_OSCURO, 2.4),
        "Muñeco con camiseta verde y un círculo destacando su barriga.",
    ),
    "wear": (
        "wear", "C",
        fondo_prado()
        + [
            E(52, 34, 14, 14, PEL, PELB, 2.0),
            E(52, 26, 14, 7, "#5a3a1a"),
            R(32, 50, 40, 34, 10, AMARILLO, AMARILLO_OSCURO, 2.2),
        ]
        + fl("Running shirt", 94, 24, 50)
        + frecha((94, 52), (72, 58), NARANJA_OSCURO, 2.6),
        "Niño poniéndose una prenda amarilla con flecha clara.",
    ),
}


def generar_hoja_contactos(claves: list[str], out_png: Path) -> None:
    import hoja_contactos as hc  # noqa: E402

    cols = 10
    tile_w, tile_h = 220, 170
    rows = (len(claves) + cols - 1) // cols
    sheet = Image.new("RGB", (cols * tile_w, rows * tile_h), "#f8fafc")
    dr = ImageDraw.Draw(sheet)
    font = ImageFont.load_default()
    for idx, clave in enumerate(sorted(claves)):
        c = idx % cols
        r = idx // cols
        x0, y0 = c * tile_w, r * tile_h
        thumb = hc.render_clave(clave, 200, 125)
        sheet.paste(thumb, (x0 + 10, y0 + 8))
        dr.rectangle([x0 + 2, y0 + 2, x0 + tile_w - 3, y0 + tile_h - 3], outline="#cbd5e1", width=1)
        dr.text((x0 + 8, y0 + 138), clave[:28], fill="#0f172a", font=font)
    out_png.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(out_png)
    print(f"OK: {out_png.relative_to(RAIZ)} ({len(claves)} láminas)")


def main() -> int:
    import subprocess
    tracked = set(
        subprocess.check_output(["git", "ls-files", "assets/brand/laminas/"], cwd=RAIZ, text=True).splitlines()
    )
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]

    creadas: list[str] = []
    for word, slug, fl_name, ur, porque in FLUENT_DIRECTOS:
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente en git: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_fluent_directo(pezas, key, slug, fl_name, ur, porque)
        creadas.append(f"pal_{slug}")

    for word, (slug, cd, formas, porque) in ESCENAS_CD.items():
        destino = LAMINAS_DIR / f"pal_{slug}.json"
        if destino.relative_to(RAIZ).as_posix() in tracked:
            raise RuntimeError(f"Prohibido sobrescribir lámina existente en git: {destino}")
        key = f"escoita:{word}" if word in pezas and pezas[word].get("clave") != f"pal_{slug}" else word
        escribir_cd(pezas, key, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=word)
        creadas.append(f"pal_{slug}")

    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    generar_hoja_contactos(creadas, RAIZ / "docs/capturas/hoja_contactos_escoita_2.png")
    print(f"OK: generadas {len(creadas)} láminas nuevas en {LAMINAS_DIR.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
