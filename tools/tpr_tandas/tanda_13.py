#!/usr/bin/env python3
"""Tanda 13 TPR (P2.95, cierre): últimos 59 ítems (`weight`..`zippy`).

Cubre exactamente 25 piezas revisadas (`ESCENAS` D estilo Lúa) + 34 auditadas sin base (`SIN_BASE`):
- 0 directas nuevas (`DIRECTOS_FL = {}`, `DIRECTOS_ICO = {}`)
- 25 escenas propias estilo Lúa D
- 34 auditadas sin base (`SIN_BASE`)

Con esta tanda quedan auditadas las 4.000 piezas del banco TPR.
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
    MORADO,
    NARANJA,
    NARANJA_OSCURO,
    NEGRO,
    PEL,
    PELB,
    PLATA,
    ROJO,
    ROJO_OSCURO,
    ROSA,
    ROSA_OSCURO,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    E,
    F,
    L,
    P,
    R,
    bebe,
    fondo_cielo,
    fondo_mesa,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    mesa_prop,
    nino,
    toalla_prop,
)

DIRECTOS_FL: dict[str, tuple[str, str, str]] = {}
DIRECTOS_ICO: dict[str, tuple[str, str, str, str, str, str]] = {}

MORADO_OSCURO = "#5b21b6"

ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = {
    "weight": (
        "D",
        fondo_mesa()
        + [
            P([(62, 72), (68, 46), (92, 46), (98, 72)], GRIS_OSCURO, TINTA, 2.2),
            L("M72 46 Q80 32 88 46", TINTA, 3.0),
            *frecha((116, 36), (116, 66), ROJO_OSCURO),
        ],
        "Pesa maciza de hierro sobre la mesa con flecha descendente de peso.",
        None,
    ),
    "wet sponge": (
        "D",
        fondo_sala()
        + [
            E(80, 78, 34, 8, AGUA, AGUA_OSCURO, 1.8),
            R(50, 34, 60, 26, 7, AMARILLO, AMARILLO_OSCURO, 2.2),
            E(64, 43, 2.5, 2.5, AMARILLO_OSCURO),
            E(82, 48, 3, 2.5, AMARILLO_OSCURO),
            E(96, 42, 2.5, 2.5, AMARILLO_OSCURO),
            *gotas([(64, 62), (80, 64), (96, 62)]),
        ],
        "Esponja amarilla porosa goteando agua sobre un charco azul.",
        None,
    ),
    "wet wipe": (
        "D",
        fondo_sala()
        + [
            R(44, 52, 72, 24, 6, "#bae6fd", AZUL_OSCURO, 2.2),
            E(80, 56, 16, 6, BLANCO, AZUL_OSCURO, 1.6),
            F("M70 54 Q62 32 76 26 Q94 24 88 54 Z", BLANCO, AGUA_OSCURO, 1.8),
            *gotas([(104, 34), (56, 38)]),
        ],
        "Paquete azul de toallitas húmedas con una toallita blanca saliendo y gotitas.",
        None,
    ),
    "whole": (
        "D",
        fondo_mesa()
        + [
            E(80, 50, 22, 22, NARANJA, NARANJA_OSCURO, 2.2),
            F("M80 28 Q84 20 90 22 Q86 28 80 28 Z", VERDE, VERDE_OSCURO, 1.5),
            *frecha((34, 50), (54, 50), AZUL_OSCURO),
            *frecha((126, 50), (106, 50), AZUL_OSCURO),
        ],
        "Naranja entera cerrada con dos flechas convergiendo hacia el centro.",
        None,
    ),
    "wiggle hips": (
        "D",
        fondo_sala()
        + [
            *nino((80, 26), (80, 38), (80, 56), [[(66, 54)], [(94, 54)]], [[(74, 76)], [(86, 76)]], camisa=(ROSA, ROSA_OSCURO), mira=1),
            L("M56 50 Q50 56 56 62", VERDE_OSCURO, 2.2),
            L("M104 50 Q110 56 104 62", VERDE_OSCURO, 2.2),
        ],
        "Niño con manos en la cintura moviendo las caderas de un lado a otro.",
        None,
    ),
    "wiggle your tail": (
        "D",
        fondo_prado()
        + [
            E(74, 62, 20, 12, BARRO, NEGRO, 2.0),
            E(94, 48, 11, 10, BARRO, NEGRO, 2.0),
            P([(86, 40), (92, 30), (96, 40)], BARRO, NEGRO, 1.8),
            E(98, 47, 1.8, 1.8, TINTA),
            L("M60 72 L60 80 M86 72 L86 80", NEGRO, 3.2),
            L("M54 58 Q40 48 44 38", BARRO, 4.0),
            L("M36 42 Q34 34 40 30", VERDE_OSCURO, 2.0),
            L("M50 38 Q56 32 54 44", VERDE_OSCURO, 2.0),
        ],
        "Perrito marrón moviendo alegremente la cola de un lado a otro.",
        None,
    ),
    "wings up, wings down": (
        "D",
        fondo_cielo()
        + [
            E(80, 56, 13, 10, AZUL, AZUL_OSCURO, 2.0),
            P([(68, 52), (44, 34), (62, 56)], "#93c5fd", AZUL_OSCURO, 1.8),
            P([(92, 52), (116, 34), (98, 56)], "#93c5fd", AZUL_OSCURO, 1.8),
            P([(93, 55), (101, 57), (93, 60)], AMARILLO, AMARILLO_OSCURO, 1.4),
            *frecha((34, 60), (34, 30), VERDE_OSCURO),
            *frecha((126, 30), (126, 60), ROJO_OSCURO),
        ],
        "Pájaro batiendo las alas con flechas vertical hacia arriba y hacia abajo.",
        None,
    ),
    "wingspan": (
        "D",
        fondo_cielo()
        + [
            E(80, 48, 10, 7, BARRO, NEGRO, 1.8),
            P([(70, 48), (22, 36), (34, 54), (70, 52)], MADERA, NEGRO, 1.8),
            P([(90, 48), (138, 36), (126, 54), (90, 52)], MADERA, NEGRO, 1.8),
            L("M24 72 L136 72", ROJO_OSCURO, 2.4),
            P([(20, 72), (28, 67), (28, 77)], ROJO_OSCURO),
            P([(140, 72), (132, 67), (132, 77)], ROJO_OSCURO),
        ],
        "Ave con las alas abiertas de extremo a extremo y flecha doble midiendo su envergadura.",
        None,
    ),
    "wipe hands": (
        "D",
        fondo_sala()
        + [
            E(58, 52, 16, 10, PEL, PELB, 2.0),
            E(102, 52, 16, 10, PEL, PELB, 2.0),
            *toalla_prop(64, 30, 32, 32),
        ],
        "Dos manos sujetando una servilleta para secarse y limpiarse.",
        None,
    ),
    "wipe the table": (
        "D",
        fondo_sala()
        + [
            *mesa_prop(26, 52, 108, 30),
            R(62, 42, 34, 12, 3, "#fef3c7", AMARILLO_OSCURO, 2.0),
            L("M44 48 L58 48", AZUL_OSCURO, 2.2),
            *frecha((98, 48), (120, 48), AZUL_OSCURO),
        ],
        "Paño amarillo deslizándose sobre la superficie de la mesa para limpiarla.",
        None,
    ),
    "wobble": (
        "D",
        fondo_mesa()
        + [
            E(80, 70, 32, 8, BLANCO, GRIS_OSCURO, 1.8),
            F("M58 68 Q62 34 80 34 Q98 34 102 68 Z", ROSA, ROSA_OSCURO, 2.2),
            L("M46 42 Q40 52 46 62", MORADO, 2.0),
            L("M114 42 Q120 52 114 62", MORADO, 2.0),
        ],
        "Gelatina rosa sobre plato tambaleándose con ondas laterales.",
        None,
    ),
    "wooden block": (
        "D",
        fondo_mesa()
        + [
            R(48, 46, 34, 26, 3, MADERA, MADERA_OSCURA, 2.2),
            R(84, 46, 28, 26, 3, "#fde68a", MADERA_OSCURA, 2.2),
            R(62, 22, 36, 24, 3, MADERA, MADERA_OSCURA, 2.2),
            L("M54 56 L76 56 M68 34 L90 34", MADERA_OSCURA, 1.4),
        ],
        "Bloques de madera natural con veta apilados sobre la mesa.",
        None,
    ),
    "wrap": (
        "D",
        fondo_mesa()
        + [
            R(56, 38, 48, 34, 3, AMARILLO, AMARILLO_OSCURO, 2.2),
            P([(40, 34), (56, 38), (56, 72), (38, 66)], ROSA, ROSA_OSCURO, 1.8),
            P([(120, 34), (104, 38), (104, 72), (122, 66)], ROSA, ROSA_OSCURO, 1.8),
            *frecha((34, 48), (54, 48), ROJO_OSCURO),
            *frecha((126, 48), (106, 48), ROJO_OSCURO),
        ],
        "Caja amarilla siendo envuelta con papel rosa desde ambos lados.",
        None,
    ),
    "wrap up": (
        "D",
        fondo_sala()
        + [
            R(48, 46, 64, 32, 12, "#93c5fd", AZUL_OSCURO, 2.2),
            L("M52 58 L108 58", AZUL_OSCURO, 1.6),
            *bebe(80, 48, "#fef3c7", "#d97706"),
        ],
        "Bebé abrigado y arropado dentro de una manta azul cálida.",
        None,
    ),
    "wreath": (
        "D",
        fondo_sala()
        + [
            E(80, 48, 28, 28, VERDE, VERDE_OSCURO, 2.4),
            E(80, 48, 14, 14, "#fef3c7", VERDE_OSCURO, 2.0),
            E(60, 34, 5, 5, ROJO, ROJO_OSCURO, 1.2),
            E(100, 36, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.2),
            E(62, 62, 5, 5, ROSA, ROSA_OSCURO, 1.2),
            E(98, 60, 5, 5, ROJO, ROJO_OSCURO, 1.2),
            P([(80, 74), (70, 86), (80, 82), (90, 86)], ROJO, ROJO_OSCURO, 1.4),
        ],
        "Corona circular de hojas verdes decorada con flores y lazo rojo.",
        None,
    ),
    "wriggle": (
        "D",
        fondo_prado()
        + [
            L("M34 62 Q48 44 64 60 Q80 76 96 58 Q112 40 124 56", VERDE, 9.0),
            L("M34 62 Q48 44 64 60 Q80 76 96 58 Q112 40 124 56", VERDE_OSCURO, 2.0),
            E(126, 55, 6, 6, VERDE, VERDE_OSCURO, 1.8),
            E(128, 53, 1.5, 1.5, TINTA),
            L("M58 42 Q64 34 70 42", NARANJA_OSCURO, 1.8),
            L("M90 72 Q96 80 102 72", NARANJA_OSCURO, 1.8),
        ],
        "Oruga verde retorciéndose en curvas sinuosas sobre la hierba.",
        None,
    ),
    "wring out": (
        "D",
        fondo_sala()
        + [
            P([(42, 40), (70, 48), (90, 42), (118, 50), (114, 58), (88, 50), (68, 56), (40, 48)], "#93c5fd", AZUL_OSCURO, 2.0),
            L("M66 36 Q80 28 94 36", ROJO_OSCURO, 2.0),
            P([(92, 32), (97, 37), (90, 39)], ROJO_OSCURO),
            *gotas([(74, 62), (86, 68)]),
            E(80, 82, 26, 6, AGUA, AGUA_OSCURO, 1.6),
        ],
        "Paño mojado retorcido escurriendo gotas de agua hacia el suelo.",
        None,
    ),
    "wrinkly": (
        "D",
        fondo_mesa()
        + [
            P([(42, 30), (66, 24), (82, 32), (104, 24), (118, 36), (112, 68), (88, 74), (66, 66), (44, 72)], BLANCO, GRIS_OSCURO, 2.2),
            L("M54 36 L68 52 L56 64 M82 32 L78 50 L92 64 M100 32 L96 48 L110 56", GRIS_OSCURO, 1.6),
        ],
        "Hoja de papel muy arrugada con pliegues marcados en zigzag.",
        None,
    ),
    "write": (
        "D",
        fondo_mesa()
        + [
            R(38, 32, 76, 46, 4, BLANCO, GRIS_OSCURO, 2.0),
            L("M48 64 Q58 56 68 64 Q78 72 88 64 Q98 58 104 62", AZUL_OSCURO, 2.2),
            P([(102, 60), (124, 26), (132, 32), (108, 62)], AMARILLO, AMARILLO_OSCURO, 1.8),
            P([(102, 60), (105, 55), (109, 59)], TINTA),
        ],
        "Lápiz amarillo escribiendo un trazo ondulado sobre una hoja blanca.",
        None,
    ),
    "write a card": (
        "D",
        fondo_mesa()
        + [
            R(36, 26, 74, 48, 4, "#fef3c7", ROSA_OSCURO, 2.0),
            L("M73 26 L73 74", ROSA_OSCURO, 1.6),
            E(54, 48, 7, 7, ROSA, ROSA_OSCURO, 1.5),
            L("M82 42 L100 42 M82 52 L98 52", GRIS_OSCURO, 1.8),
            P([(98, 60), (122, 30), (128, 35), (104, 64)], AZUL, AZUL_OSCURO, 1.8),
        ],
        "Tarjeta abierta decorada con lápiz azul escribiendo dentro.",
        None,
    ),
    "yawn wide": (
        "D",
        fondo_sala()
        + [
            E(80, 50, 26, 26, PEL, PELB, 2.2),
            E(68, 40, 2.5, 2.5, TINTA),
            E(92, 40, 2.5, 2.5, TINTA),
            L("M64 34 L72 34 M88 34 L96 34", NEGRO, 1.8),
            E(80, 60, 10, 12, ROJO_OSCURO, TINTA, 2.0),
            E(80, 67, 6, 4, ROSA),
        ],
        "Cara con los ojos cerrados y la boca muy abierta bostezando.",
        None,
    ),
    "yoga mat": (
        "D",
        fondo_sala()
        + [
            P([(34, 72), (56, 48), (124, 48), (104, 72)], MORADO, MORADO_OSCURO, 2.2),
            E(116, 60, 9, 12, "#c4b5fd", MORADO_OSCURO, 2.2),
            E(116, 60, 4, 6, MORADO_OSCURO),
        ],
        "Esterilla morada extendida en el suelo con un extremo enrollado.",
        None,
    ),
    "zip": (
        "D",
        fondo_sala()
        + [
            R(44, 18, 72, 66, 6, AZUL, AZUL_OSCURO, 2.2),
            L("M80 18 L80 54", PLATA, 3.2),
            L("M80 54 L68 84 M80 54 L92 84", PLATA, 2.6),
            R(74, 46, 12, 12, 2, DORADO, TINTA, 1.8),
            *frecha((104, 66), (104, 30), VERDE_OSCURO),
        ],
        "Cremallera cerrándose de abajo hacia arriba con flecha verde ascendente.",
        None,
    ),
    "zip your coat": (
        "D",
        fondo_sala()
        + [
            P([(50, 24), (110, 24), (124, 54), (110, 58), (104, 42), (104, 80), (56, 80), (56, 42), (50, 58), (36, 54)], ROJO, ROJO_OSCURO, 2.2),
            L("M80 28 L80 78", PLATA, 2.8),
            R(76, 42, 8, 10, 2, DORADO, TINTA, 1.6),
            *frecha((94, 64), (94, 34), VERDE_OSCURO),
        ],
        "Abrigo rojo cerrando su cremallera central hacia arriba con flecha verde.",
        None,
    ),
    "zipper pull": (
        "D",
        fondo_sala()
        + [
            R(50, 18, 60, 66, 6, VERDE, VERDE_OSCURO, 2.2),
            L("M80 18 L80 84", PLATA, 3.5),
            R(72, 34, 16, 14, 3, DORADO, TINTA, 2.0),
            R(75, 48, 10, 20, 4, DORADO, TINTA, 2.0),
            E(80, 62, 2.5, 2.5, TINTA),
            *frecha((102, 62), (102, 30), ROJO_OSCURO),
        ],
        "Primer plano del tirador metálico dorado de una cremallera subiendo.",
        None,
    ),
}

SIN_BASE: dict[str, str] = {
    "weightless": "Sensación física abstracta (`ingrávido`) difícil de mostrar sin escena espacial explícita.",
    "well done, explorer": "Fórmula verbal de ánimo (`¡muy bien, explorador!`) duplicada de `thumbs up`.",
    "well-rehearsed": "Adjetivo participial abstracto (`bien ensayado`) dependiente del contexto.",
    "well-rested": "Estado interno tras descansar (`descansado`) duplicado de despertar/dormir.",
    "what do you do to feel calm": "Pregunta conversacional completa (`¿qué haces para estar tranquilo?`).",
    "what's in the bag": "Pregunta verbal de adivinanza (`¿qué hay en la bolsa?`).",
    "whee": "Interjección exclamativa hablada (`¡uiii!`) sin referente único propio.",
    "when i feel angry, i breathe slowly": "Oración emocional compleja de autorregulación dependiente de texto.",
    "when i was two, i couldn't write my name, but now i can": "Oración temporal autobiográfica compleja imposible sin texto.",
    "when the bell rings, we line up": "Regla escolar en dos tiempos duplicada de `line up at the bell`.",
    "where does the river go": "Pregunta geográfica verbal (`¿adónde va el río?`).",
    "where's your hand": "Pregunta lúdica de escondite verbal (`¿dónde está tu mano?`).",
    "which one is heavier": "Pregunta comparativa verbal (`¿cuál pesa más?`).",
    "whisper to me": "Petición verbal duplicada de `whisper`.",
    "whistle sound": "Sensación auditiva (`silbido de delfín`) imposible de distinguir visualmente.",
    "wiggle": "Duplicada directa de `wiggle hips`.",
    "wild": "Adjetivo abstracto (`salvaje`) ambiguo frente a un animal concreto.",
    "will it float": "Pregunta predictiva verbal (`¿flotará?`).",
    "wipe": "Verbo genérico duplicado de `wipe hands` / `wipe the table`.",
    "wipe clean": "Duplicada directa de `wipe the table`.",
    "with grandma": "Sintagma relacional (`con la abuela`) ambiguo sin historia verbal.",
    "with music": "Condición temporal (`mientras suena la música`) dependiente de audio.",
    "wobble and hold": "Consigna motriz compuesta duplicada de `wobble`.",
    "wobbly": "Adjetivo duplicado de `wobble`.",
    "woof": "Onomatopeya sonora (`ladrar`) imposible sin sonido ni bocadillo de texto.",
    "wriggly": "Adjetivo duplicado de `wriggle`.",
    "write a thank-you note": "Variante textual duplicada de `write a card`.",
    "write down": "Verbo genérico duplicado de `write`.",
    "write your name": "Consigna alfabética (`escribir tu nombre`) dependiente de texto.",
    "you can do it": "Exclamación motivacional (`¡tú puedes!`) duplicada de `thumbs up`.",
    "you're a great friend": "Cumplido verbal afectivo (`eres un gran amigo`).",
    "your hand in mine": "Expresión afectiva relacional (`tu mano en la mía`).",
    "yuck or yum": "Pregunta dicotómica conversacional (`¿puaj o ñam?`).",
    "zippy": "Adjetivo coloquial de velocidad (`rapidísimo`) ambiguo frente a correr.",
}
