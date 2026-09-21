#!/usr/bin/env python3
"""Los dibujos de las láminas del banco que no tenían uno.

De las 205 láminas del banco, 89 son cosas que este repositorio YA tenía
dibujadas —la manzana, el barco, la gata, las treinta escenas del cuento— y
`tools/draw_flashcards.py` se limita a apuntar a ellas. Las demás no existían en
ninguna parte: llegaron con el campo del dibujo vacío, porque en el proyecto de
origen eran un emoji, y aquí los emoji no entran (regla 5 del CLAUDE.md).

Este fichero las dibuja. Mismo formato de datos que el resto —lo lee
`lib/core/brand/lamina_vector.dart`—, misma paleta y el mismo trazo grueso con
contorno oscuro, importados de `draw_contos.py` para que no haya dos casas de
color. Un set propio es un set coherente: si el perro de la tarjeta «D» y el
perro de «Can leal» fuesen dos perros distintos, serían dos palabras.

    python3 tools/draw_banco_laminas.py      # escribe los ficheiros

Normalmente no se llama a mano: lo llama `tools/draw_flashcards.py`, que es
quien sabe qué lámina le toca a cada entrada del banco. Lo comprueba
`tools/check_laminas.py`, que es quien dice si una forma no pinta nada o se sale
del lienzo.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from draw_contos import (  # noqa: E402
    AMARELO,
    AREA,
    AUGA,
    AZUL_ESCURO,
    BRANCO,
    CEO,
    CEO_NOITE,
    CHAN_MADEIRA,
    CREMA,
    FACE,
    HERBA,
    LARANXA,
    LOUSA,
    MADEIRA,
    MAR,
    NEGRO,
    OLLO,
    PELO,
    PERFIL,
    ROSA,
    TERRACOTA,
    VERDE_ESCURO,
    VERMELLO,
    VERMELLO_ESCURO,
    elipse,
    objeto,
    poner,
    rrect,
    ruta,
    sol,
    nube,
    arbore,
    folla,
)

ROOT = Path(__file__).resolve().parent.parent
DESTINO = ROOT / "assets" / "brand" / "laminas"

BRILLO_FORTE = "#ffffff88"
GRIS = "#94a3b8"
GRIS_ESCURO = "#475569"
MORADO = "#7c3aed"
ROSA_FORTE = "#ec4899"

# El contorno de todo el set: mismo grosor, mismas terminaciones redondas.
SW = 4


def brillo(cx, cy, rx=7, ry=10):
    """El mismo brillo arriba a la izquierda que llevan todas las láminas: es
    de donde viene la luz en este set, y no cambia de una a otra."""
    return elipse(cx, cy, rx, ry, f=BRILLO_FORTE)


def _cara(boca, ollos="abertos", cor=FACE, cejas=None):
    """Una cara de las de la clase: un solo tono de piel, sin rasgos que
    identifiquen a nadie. Lo que cambia entre láminas es la EXPRESIÓN."""
    f = [
        elipse(50, 52, 34, 34, f=cor, s=TERRACOTA, sw=SW),
        brillo(36, 36, 8, 10),
    ]
    if ollos == "abertos":
        f += [elipse(38, 46, 5, 6, f=BRANCO, s=NEGRO, sw=2),
              elipse(62, 46, 5, 6, f=BRANCO, s=NEGRO, sw=2),
              elipse(38, 47, 2.5, 2.5, f=NEGRO),
              elipse(62, 47, 2.5, 2.5, f=NEGRO)]
    elif ollos == "grandes":
        f += [elipse(38, 45, 8, 9, f=BRANCO, s=NEGRO, sw=2),
              elipse(62, 45, 8, 9, f=BRANCO, s=NEGRO, sw=2),
              elipse(38, 46, 4, 4, f=NEGRO),
              elipse(62, 46, 4, 4, f=NEGRO)]
    elif ollos == "pechados":
        f += [ruta("M32 46 Q38 41 44 46", s=NEGRO, sw=3),
              ruta("M56 46 Q62 41 68 46", s=NEGRO, sw=3)]
    elif ollos == "cansos":
        f += [ruta("M32 47 Q38 52 44 47", s=NEGRO, sw=3),
              ruta("M56 47 Q62 52 68 47", s=NEGRO, sw=3)]

    if cejas == "arriba":
        f += [ruta("M31 35 Q38 30 45 34", s=PERFIL, sw=3),
              ruta("M55 34 Q62 30 69 35", s=PERFIL, sw=3)]
    elif cejas == "xuntas":
        f += [ruta("M31 36 Q38 40 45 37", s=PERFIL, sw=3),
              ruta("M55 37 Q62 40 69 36", s=PERFIL, sw=3)]

    if boca == "sorriso":
        f.append(ruta("M36 63 Q50 76 64 63", s=NEGRO, sw=3))
    elif boca == "risa":
        f += [ruta("M34 60 Q50 80 66 60 Z", f=VERMELLO_ESCURO, s=NEGRO, sw=3),
              ruta("M40 62 Q50 60 60 62", s=BRANCO, sw=4)]
    elif boca == "o":
        f.append(elipse(50, 66, 7, 9, f=VERMELLO_ESCURO, s=NEGRO, sw=3))
    elif boca == "triste":
        f.append(ruta("M36 70 Q50 58 64 70", s=NEGRO, sw=3))
    elif boca == "recta":
        f.append(ruta("M39 66 L61 66", s=NEGRO, sw=3))
    elif boca == "bico":
        f += [elipse(50, 66, 6, 7, f=ROSA_FORTE, s=VERMELLO_ESCURO, sw=2)]
    elif boca == "canta":
        f += [elipse(50, 66, 8, 11, f=VERMELLO_ESCURO, s=NEGRO, sw=3),
              ruta("M44 62 Q50 66 56 62", s=ROSA, sw=3)]
    return f


# ==========================================================================
# 1. VOCABULARIO · las cosas de la casa y de la clase
# ==========================================================================

def casa():
    return [
        rrect(20, 44, 60, 42, 4, f=CREMA, s=MADEIRA, sw=SW),
        ruta("M12 46 L50 16 L88 46 Z", f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        rrect(42, 60, 18, 26, 2, f=MADEIRA, s=PERFIL, sw=3),
        elipse(56, 73, 2, 2, f=AMARELO),
        rrect(26, 52, 14, 14, 2, f=CEO, s=MADEIRA, sw=3),
        rrect(64, 52, 14, 14, 2, f=CEO, s=MADEIRA, sw=3),
        brillo(30, 56, 4, 5),
    ]


def mesa():
    return [
        rrect(12, 38, 76, 12, 4, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(20, 50, 10, 36, 3, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(70, 50, 10, 36, 3, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        brillo(24, 42, 6, 3),
    ]


def cadeira():
    return [
        rrect(28, 18, 44, 34, 6, f=LARANXA, s=TERRACOTA, sw=SW),
        rrect(24, 52, 52, 10, 4, f=LARANXA, s=TERRACOTA, sw=SW),
        rrect(28, 62, 8, 24, 3, f=TERRACOTA, s=MADEIRA, sw=3),
        rrect(64, 62, 8, 24, 3, f=TERRACOTA, s=MADEIRA, sw=3),
        brillo(38, 28, 6, 8),
    ]


def prato():
    return [
        elipse(50, 54, 40, 30, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        elipse(50, 54, 26, 19, f=CREMA, s=GRIS, sw=3),
        brillo(34, 42, 8, 5),
    ]


def culler():
    return [
        elipse(50, 30, 17, 21, f=GRIS, s=GRIS_ESCURO, sw=SW),
        rrect(44, 48, 12, 40, 6, f=GRIS, s=GRIS_ESCURO, sw=SW),
        brillo(44, 24, 5, 7),
    ]


def cama():
    return [
        rrect(10, 46, 80, 24, 5, f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        rrect(10, 34, 26, 18, 6, f=BRANCO, s=GRIS_ESCURO, sw=3),
        rrect(6, 28, 10, 54, 4, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(84, 40, 10, 42, 4, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        ruta("M40 56 Q56 50 78 56", s=VERMELLO_ESCURO, sw=3),
        brillo(18, 40, 6, 4),
    ]


def alfombra():
    return [
        elipse(50, 56, 42, 28, f=MAR, s=AZUL_ESCURO, sw=SW),
        elipse(50, 56, 30, 19, f=AUGA, s=AZUL_ESCURO, sw=3),
        elipse(50, 56, 16, 10, f=BRANCO, s=AZUL_ESCURO, sw=3),
        brillo(32, 44, 8, 4),
    ]


def libro():
    return [
        ruta("M50 30 C36 20 20 22 12 28 L12 76 C20 70 36 68 50 78 Z",
             f=BRANCO, s=MADEIRA, sw=SW),
        ruta("M50 30 C64 20 80 22 88 28 L88 76 C80 70 64 68 50 78 Z",
             f=CREMA, s=MADEIRA, sw=SW),
        ruta("M50 30 L50 78", s=MADEIRA, sw=3),
        ruta("M20 38 L40 42", s=GRIS, sw=2),
        ruta("M20 48 L40 52", s=GRIS, sw=2),
        ruta("M60 42 L80 38", s=GRIS, sw=2),
        ruta("M60 52 L80 48", s=GRIS, sw=2),
    ]


def cepillo():
    # El mango en diagonal y las cerdas arriba, como se ve un cepillo en la
    # mano. En horizontal y con las cerdas de canto no se leía: parecía una
    # llave rara.
    return [
        rrect(44, 40, 14, 48, 7, f=AUGA, s=AZUL_ESCURO, sw=SW),
        rrect(38, 22, 26, 22, 6, f=AUGA, s=AZUL_ESCURO, sw=SW),
        rrect(38, 10, 26, 14, 4, f=BRANCO, s=GRIS_ESCURO, sw=3),
        ruta("M43 24 L43 10", s=GRIS, sw=2),
        ruta("M50 24 L50 10", s=GRIS, sw=2),
        ruta("M57 24 L57 10", s=GRIS, sw=2),
        brillo(48, 52, 3, 9),
    ]


def tesoiras():
    return [
        ruta("M30 24 L62 62", s=GRIS_ESCURO, sw=7),
        ruta("M70 24 L38 62", s=GRIS, sw=7),
        elipse(32, 74, 12, 12, s=VERMELLO, sw=6),
        elipse(68, 74, 12, 12, s=VERMELLO, sw=6),
        elipse(50, 56, 4, 4, f=GRIS_ESCURO),
    ]


def lapis():
    return [
        rrect(38, 22, 24, 50, 2, f=AMARELO, s=TERRACOTA, sw=SW),
        ruta("M38 72 L50 90 L62 72 Z", f=CREMA, s=TERRACOTA, sw=SW),
        ruta("M44 81 L50 90 L56 81 Z", f=NEGRO),
        rrect(38, 14, 24, 10, 2, f=ROSA_FORTE, s=VERMELLO_ESCURO, sw=3),
        ruta("M50 24 L50 72", s=TERRACOTA, sw=2),
    ]


def papel():
    return [
        ruta("M22 12 L64 12 L78 28 L78 88 L22 88 Z",
             f=BRANCO, s=GRIS_ESCURO, sw=SW),
        ruta("M64 12 L64 28 L78 28", s=GRIS_ESCURO, sw=3),
        ruta("M32 42 L68 42", s=GRIS, sw=3),
        ruta("M32 54 L68 54", s=GRIS, sw=3),
        ruta("M32 66 L56 66", s=GRIS, sw=3),
    ]


def pelota():
    return [
        elipse(50, 54, 34, 34, f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        ruta("M16 54 L84 54", s=VERMELLO_ESCURO, sw=3),
        ruta("M50 20 C34 38 34 70 50 88", s=VERMELLO_ESCURO, sw=3),
        ruta("M50 20 C66 38 66 70 50 88", s=VERMELLO_ESCURO, sw=3),
        brillo(36, 38, 8, 9),
    ]


def boneca():
    return [
        elipse(50, 30, 20, 20, f=FACE, s=TERRACOTA, sw=SW),
        ruta("M30 26 Q50 6 70 26 Q50 18 30 26 Z", f=MADEIRA, s=PERFIL, sw=3),
        elipse(43, 30, 3, 3.5, f=NEGRO),
        elipse(57, 30, 3, 3.5, f=NEGRO),
        ruta("M44 38 Q50 44 56 38", s=VERMELLO_ESCURO, sw=3),
        ruta("M50 50 L26 86 L74 86 Z", f=MORADO, s=AZUL_ESCURO, sw=SW),
        ruta("M32 58 L18 72", s=FACE, sw=8),
        ruta("M68 58 L82 72", s=FACE, sw=8),
    ]


def tren():
    return [
        rrect(12, 46, 44, 28, 5, f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        rrect(56, 34, 30, 40, 5, f=MAR, s=AZUL_ESCURO, sw=SW),
        rrect(62, 42, 18, 14, 3, f=CEO, s=AZUL_ESCURO, sw=3),
        rrect(22, 26, 14, 22, 3, f=GRIS_ESCURO, s=NEGRO, sw=3),
        elipse(26, 80, 10, 10, f=NEGRO, s=GRIS_ESCURO, sw=3),
        elipse(52, 80, 10, 10, f=NEGRO, s=GRIS_ESCURO, sw=3),
        elipse(76, 80, 10, 10, f=NEGRO, s=GRIS_ESCURO, sw=3),
        brillo(20, 52, 5, 4),
    ]


def coche():
    return [
        rrect(10, 52, 80, 22, 8, f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        ruta("M26 52 L36 32 L68 32 L80 52 Z", f=VERMELLO,
             s=VERMELLO_ESCURO, sw=SW),
        rrect(38, 36, 12, 14, 2, f=CEO, s=AZUL_ESCURO, sw=3),
        rrect(54, 36, 14, 14, 2, f=CEO, s=AZUL_ESCURO, sw=3),
        elipse(28, 76, 11, 11, f=NEGRO, s=GRIS_ESCURO, sw=3),
        elipse(72, 76, 11, 11, f=NEGRO, s=GRIS_ESCURO, sw=3),
        elipse(28, 76, 4, 4, f=GRIS),
        elipse(72, 76, 4, 4, f=GRIS),
        brillo(20, 58, 5, 3),
    ]


def campa():
    return [
        ruta("M50 16 C70 16 78 42 78 70 L22 70 C22 42 30 16 50 16 Z",
             f=AMARELO, s=TERRACOTA, sw=SW),
        rrect(16, 68, 68, 10, 5, f=LARANXA, s=TERRACOTA, sw=SW),
        elipse(50, 84, 8, 8, f=TERRACOTA, s=MADEIRA, sw=3),
        rrect(46, 8, 8, 10, 4, f=TERRACOTA, s=MADEIRA, sw=3),
        brillo(36, 34, 6, 10),
    ]


def reloxo():
    return [
        elipse(50, 52, 36, 36, f=BRANCO, s=MADEIRA, sw=SW),
        elipse(50, 52, 29, 29, f=CREMA, s=CHAN_MADEIRA, sw=2),
        ruta("M50 52 L50 32", s=NEGRO, sw=5),
        ruta("M50 52 L66 60", s=NEGRO, sw=4),
        elipse(50, 52, 4, 4, f=VERMELLO),
        elipse(50, 28, 2.5, 2.5, f=MADEIRA),
        elipse(74, 52, 2.5, 2.5, f=MADEIRA),
        elipse(50, 76, 2.5, 2.5, f=MADEIRA),
        elipse(26, 52, 2.5, 2.5, f=MADEIRA),
        brillo(36, 36, 6, 8),
    ]


def fiestra():
    return [
        rrect(14, 14, 72, 72, 5, f=CEO, s=MADEIRA, sw=SW),
        rrect(14, 14, 72, 72, 5, s=CHAN_MADEIRA, sw=8),
        ruta("M50 14 L50 86", s=CHAN_MADEIRA, sw=7),
        ruta("M14 50 L86 50", s=CHAN_MADEIRA, sw=7),
    ] + poner(sol(0, 0, 9), dx=68, dy=32) + [
        elipse(30, 66, 12, 7, f=HERBA, s=VERDE_ESCURO, sw=2),
        brillo(26, 28, 6, 8),
    ]


def porta():
    return [
        rrect(22, 10, 56, 80, 6, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(30, 20, 40, 26, 4, s=MADEIRA, sw=3),
        rrect(30, 54, 40, 26, 4, s=MADEIRA, sw=3),
        elipse(68, 52, 5, 5, f=AMARELO, s=TERRACOTA, sw=2),
        brillo(30, 24, 4, 7),
    ]


def chave():
    return [
        elipse(30, 40, 18, 18, f=AMARELO, s=TERRACOTA, sw=SW),
        elipse(30, 40, 7, 7, f=CREMA, s=TERRACOTA, sw=3),
        rrect(44, 34, 44, 12, 4, f=AMARELO, s=TERRACOTA, sw=SW),
        rrect(70, 46, 8, 14, 3, f=AMARELO, s=TERRACOTA, sw=3),
        rrect(82, 46, 8, 10, 3, f=AMARELO, s=TERRACOTA, sw=3),
        brillo(24, 32, 5, 6),
    ]


def espello():
    return [
        elipse(50, 48, 32, 40, f=CEO, s=CHAN_MADEIRA, sw=8),
        ruta("M34 30 L58 70", s=BRANCO, sw=6),
        ruta("M44 26 L54 44", s=BRANCO, sw=4),
        rrect(44, 84, 12, 8, 3, f=CHAN_MADEIRA, s=MADEIRA, sw=3),
    ]


def lampada():
    return [
        ruta("M28 44 L38 18 L62 18 L72 44 Z", f=AMARELO,
             s=TERRACOTA, sw=SW),
        rrect(46, 44, 8, 30, 3, f=GRIS, s=GRIS_ESCURO, sw=3),
        rrect(32, 74, 36, 10, 5, f=GRIS_ESCURO, s=NEGRO, sw=3),
        ruta("M34 52 L22 62", s=AMARELO, sw=4),
        ruta("M66 52 L78 62", s=AMARELO, sw=4),
        brillo(40, 26, 5, 7),
    ]


def caixa():
    return [
        rrect(18, 44, 64, 42, 4, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(14, 34, 72, 14, 4, f=TERRACOTA, s=MADEIRA, sw=SW),
        rrect(44, 34, 12, 52, 2, f=AMARELO, s=TERRACOTA, sw=3),
        elipse(50, 26, 9, 7, f=AMARELO, s=TERRACOTA, sw=3),
        brillo(24, 52, 5, 8),
    ]


def boton():
    return [
        elipse(50, 52, 34, 34, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        elipse(50, 52, 24, 24, s=MADEIRA, sw=3),
        elipse(42, 44, 5, 5, f=MADEIRA),
        elipse(58, 44, 5, 5, f=MADEIRA),
        elipse(42, 60, 5, 5, f=MADEIRA),
        elipse(58, 60, 5, 5, f=MADEIRA),
        brillo(34, 36, 7, 8),
    ]


def lazo():
    return [
        ruta("M50 50 C30 28 10 34 14 52 C18 70 38 66 50 50 Z",
             f=ROSA_FORTE, s=VERMELLO_ESCURO, sw=SW),
        ruta("M50 50 C70 28 90 34 86 52 C82 70 62 66 50 50 Z",
             f=ROSA_FORTE, s=VERMELLO_ESCURO, sw=SW),
        elipse(50, 50, 10, 10, f=VERMELLO, s=VERMELLO_ESCURO, sw=3),
        ruta("M44 58 L34 86", s=ROSA_FORTE, sw=7),
        ruta("M56 58 L66 86", s=ROSA_FORTE, sw=7),
    ]


def berce():
    return [
        ruta("M14 38 L86 38 L76 74 L24 74 Z", f=CHAN_MADEIRA,
             s=MADEIRA, sw=SW),
        ruta("M20 52 L80 52", s=MADEIRA, sw=3),
        ruta("M14 74 C34 90 66 90 86 74", f=MADEIRA, s=PERFIL, sw=3),
        rrect(30, 40, 40, 12, 5, f=BRANCO, s=GRIS_ESCURO, sw=3),
        ruta("M26 38 L26 20", s=MADEIRA, sw=5),
        ruta("M74 38 L74 20", s=MADEIRA, sw=5),
        ruta("M26 20 Q50 12 74 20", s=MADEIRA, sw=5),
    ]


def cueiro():
    # Doblado en triángulo y con el imperdible, que es como se reconoce un
    # pañal de tela en un dibujo. Abierto y con dos pegatinas redondas salía
    # un escudo con ojos: la forma mandaba más que el color.
    return [
        ruta("M12 26 L88 26 L50 88 Z", f=BRANCO, s=GRIS_ESCURO, sw=SW),
        ruta("M12 26 L88 26 L82 36 L18 36 Z", f=AUGA, s=AZUL_ESCURO, sw=3),
        ruta("M34 50 Q50 58 66 50", s=AUGA, sw=3),
        ruta("M42 62 Q50 68 58 62", s=AUGA, sw=3),
        elipse(50, 30, 5, 5, f=GRIS, s=GRIS_ESCURO, sw=2),
        ruta("M50 30 L50 44", s=GRIS_ESCURO, sw=3),
        brillo(30, 32, 5, 3),
    ]


def biberon():
    return [
        rrect(30, 34, 40, 52, 8, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        rrect(34, 54, 32, 28, 6, f=CREMA, s=GRIS, sw=2),
        rrect(36, 24, 28, 12, 4, f=AUGA, s=AZUL_ESCURO, sw=3),
        ruta("M44 24 C44 10 56 10 56 24 Z", f=ROSA, s=VERMELLO_ESCURO, sw=3),
        ruta("M36 62 L46 62", s=GRIS, sw=2),
        ruta("M36 70 L46 70", s=GRIS, sw=2),
        brillo(38, 44, 4, 8),
    ]


def bico():
    # El corazón dice «cariño» mejor que una mancha roja al lado de la cara.
    return _cara("bico", ollos="pechados") + [
        ruta("M80 20 C86 12 94 18 88 26 L80 36 L72 26 C66 18 74 12 80 20 Z",
             f=VERMELLO, s=VERMELLO_ESCURO, sw=3),
    ]


def sorriso():
    return _cara("risa", ollos="abertos") + [
        elipse(26, 60, 7, 5, f=ROSA),
        elipse(74, 60, 7, 5, f=ROSA),
    ]



# ==========================================================================
# 2. ANIMAIS · retrato de cabeza para los de cuatro patas, cuerpo entero para
#    los que se reconocen por la silueta. Es el criterio de `gato` y `peixe`,
#    que ya estaban dibujados: no se cambia a mitad del set.
# ==========================================================================

def _orella_triangulo(x, y, ancho, alto, cor, borde, dentro=None):
    f = [ruta(f"M{x} {y} L{x + ancho / 2} {y - alto} L{x + ancho} {y} Z",
              f=cor, s=borde, sw=SW)]
    if dentro:
        f.append(ruta(f"M{x + ancho * 0.25} {y - 3} "
                      f"L{x + ancho / 2} {y - alto * 0.6} "
                      f"L{x + ancho * 0.75} {y - 3} Z", f=dentro))
    return f


def _fuciño(cx, cy, rx, ry, cor, borde, nariz=NEGRO):
    return [
        elipse(cx, cy, rx, ry, f=cor, s=borde, sw=3),
        elipse(cx, cy - ry * 0.35, rx * 0.35, ry * 0.3, f=nariz),
        ruta(f"M{cx} {cy} L{cx} {cy + ry * 0.45}", s=borde, sw=2),
    ]


def can():
    # Orejas CAÍDAS y hocico largo. Con orejas cortas y redondas salía un oso:
    # a este tamaño la silueta de la oreja es lo que separa un perro de un oso.
    cor, borde = "#c98c48", "#7a4a12"
    return [
        ruta("M24 34 C10 40 8 66 20 74 C30 80 34 56 32 42 Z",
             f=borde, s=PERFIL, sw=3),
        ruta("M76 34 C90 40 92 66 80 74 C70 80 66 56 68 42 Z",
             f=borde, s=PERFIL, sw=3),
        elipse(50, 48, 28, 26, f=cor, s=borde, sw=SW),
        brillo(38, 34, 6, 8),
        elipse(41, 44, 4.5, 5, f=NEGRO),
        elipse(59, 44, 4.5, 5, f=NEGRO),
        elipse(50, 72, 19, 15, f=CREMA, s=borde, sw=3),
        elipse(50, 64, 7, 5.5, f=NEGRO),
        ruta("M50 68 L50 76", s=borde, sw=2),
        ruta("M50 76 Q42 82 38 76", s=borde, sw=2),
        ruta("M50 76 Q58 82 62 76", s=borde, sw=2),
    ]


def vaca():
    return [
        elipse(24, 40, 10, 7, f=CREMA, s=PERFIL, sw=3),
        elipse(76, 40, 10, 7, f=CREMA, s=PERFIL, sw=3),
        ruta("M30 30 C26 20 34 16 38 24", s=CREMA, sw=6),
        ruta("M70 30 C74 20 66 16 62 24", s=CREMA, sw=6),
        elipse(50, 52, 32, 30, f=BRANCO, s=PERFIL, sw=SW),
        ruta("M28 40 C20 48 24 60 34 56 C40 52 36 40 28 40 Z", f=NEGRO),
        ruta("M70 34 C80 34 82 46 74 48 C68 48 64 36 70 34 Z", f=NEGRO),
        elipse(40, 48, 4.5, 5, f=NEGRO),
        elipse(60, 48, 4.5, 5, f=NEGRO),
        elipse(50, 70, 17, 12, f=ROSA, s=PERFIL, sw=3),
        elipse(44, 68, 3.5, 4, f=PERFIL),
        elipse(56, 68, 3.5, 4, f=PERFIL),
        brillo(36, 36, 6, 8),
    ]


def ovella():
    return [
        elipse(28, 42, 13, 12, f=BRANCO, s=GRIS, sw=3),
        elipse(72, 42, 13, 12, f=BRANCO, s=GRIS, sw=3),
        elipse(38, 28, 14, 13, f=BRANCO, s=GRIS, sw=3),
        elipse(62, 28, 14, 13, f=BRANCO, s=GRIS, sw=3),
        elipse(50, 24, 15, 14, f=BRANCO, s=GRIS, sw=3),
        elipse(50, 56, 26, 26, f=CREMA, s=PERFIL, sw=SW),
        elipse(24, 56, 9, 7, f=CREMA, s=PERFIL, sw=3),
        elipse(76, 56, 9, 7, f=CREMA, s=PERFIL, sw=3),
        elipse(42, 52, 4, 4.5, f=NEGRO),
        elipse(58, 52, 4, 4.5, f=NEGRO),
        elipse(50, 66, 6, 4, f=PERFIL),
        brillo(40, 20, 6, 5),
    ]


def cabalo():
    # De perfil y con la crin marcada. De frente y en tono oscuro salía un
    # jabalí: el perfil es lo que dice «caballo» sin más ayuda.
    cor, borde, crin = "#b45309", "#5a3a12", "#3f2508"
    return [
        ruta("M34 34 L30 14 L46 28 Z", f=cor, s=borde, sw=3),
        ruta("M56 30 L62 12 L68 32 Z", f=cor, s=borde, sw=3),
        ruta("M56 22 C74 30 78 54 70 74 C66 84 58 88 52 84 "
             "C58 66 56 44 46 34 Z", f=crin, s=borde, sw=3),
        ruta("M44 26 C58 24 64 40 62 56 C60 72 50 86 36 88 "
             "C24 90 18 78 22 66 C26 54 30 30 44 26 Z",
             f=cor, s=borde, sw=SW),
        elipse(44, 48, 5, 5.5, f=NEGRO),
        elipse(30, 80, 13, 10, f=CREMA, s=borde, sw=3),
        elipse(26, 78, 3, 3.5, f=borde),
        elipse(35, 80, 3, 3.5, f=borde),
        brillo(38, 38, 5, 7),
    ]


def porco():
    return [
        elipse(24, 36, 11, 12, f=ROSA, s=VERMELLO_ESCURO, sw=3),
        elipse(76, 36, 11, 12, f=ROSA, s=VERMELLO_ESCURO, sw=3),
        elipse(50, 56, 32, 28, f=ROSA, s=VERMELLO_ESCURO, sw=SW),
        elipse(40, 48, 4.5, 5, f=NEGRO),
        elipse(60, 48, 4.5, 5, f=NEGRO),
        elipse(50, 68, 16, 12, f=ROSA_FORTE, s=VERMELLO_ESCURO, sw=3),
        elipse(45, 68, 3.5, 4.5, f=VERMELLO_ESCURO),
        elipse(55, 68, 3.5, 4.5, f=VERMELLO_ESCURO),
        brillo(36, 40, 7, 8),
    ]


def coello():
    return [
        elipse(34, 26, 9, 22, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        elipse(66, 26, 9, 22, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        elipse(34, 26, 4, 15, f=ROSA),
        elipse(66, 26, 4, 15, f=ROSA),
        elipse(50, 62, 28, 25, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        elipse(41, 58, 4.5, 5, f=NEGRO),
        elipse(59, 58, 4.5, 5, f=NEGRO),
        elipse(50, 70, 6, 4, f=ROSA_FORTE, s=GRIS_ESCURO, sw=2),
        ruta("M50 74 L50 78", s=GRIS_ESCURO, sw=2),
        ruta("M44 80 Q50 76 56 80", s=GRIS_ESCURO, sw=2),
        brillo(38, 50, 6, 7),
    ]


def rato():
    return [
        elipse(26, 38, 16, 16, f=GRIS, s=GRIS_ESCURO, sw=SW),
        elipse(74, 38, 16, 16, f=GRIS, s=GRIS_ESCURO, sw=SW),
        elipse(26, 38, 9, 9, f=ROSA),
        elipse(74, 38, 9, 9, f=ROSA),
        elipse(50, 60, 26, 24, f=GRIS, s=GRIS_ESCURO, sw=SW),
        elipse(42, 56, 4, 4.5, f=NEGRO),
        elipse(58, 56, 4, 4.5, f=NEGRO),
        elipse(50, 70, 5, 4, f=ROSA_FORTE, s=GRIS_ESCURO, sw=2),
        ruta("M44 72 L30 70", s=GRIS_ESCURO, sw=2),
        ruta("M56 72 L70 70", s=GRIS_ESCURO, sw=2),
        brillo(40, 48, 5, 6),
    ]


def leon():
    xuba = "#c2410c"
    cor = "#f59e0b"
    return [
        elipse(50, 52, 40, 38, f=xuba, s=TERRACOTA, sw=SW),
        elipse(50, 54, 28, 26, f=cor, s=TERRACOTA, sw=SW),
        elipse(41, 48, 4.5, 5, f=NEGRO),
        elipse(59, 48, 4.5, 5, f=NEGRO),
        elipse(50, 62, 10, 7, f=CREMA, s=TERRACOTA, sw=2),
        elipse(50, 60, 4, 3, f=NEGRO),
        ruta("M50 64 Q44 70 38 66", s=TERRACOTA, sw=2),
        ruta("M50 64 Q56 70 62 66", s=TERRACOTA, sw=2),
        brillo(34, 34, 6, 7),
    ]


def raposo():
    cor, borde = "#ea580c", "#7c2d12"
    return [
        ruta("M22 44 L26 16 L44 32 Z", f=cor, s=borde, sw=SW),
        ruta("M78 44 L74 16 L56 32 Z", f=cor, s=borde, sw=SW),
        ruta("M50 30 C70 32 82 46 80 56 L50 86 L20 56 C18 46 30 32 50 30 Z",
             f=cor, s=borde, sw=SW),
        ruta("M36 62 L50 86 L64 62 C58 70 42 70 36 62 Z", f=CREMA),
        elipse(38, 50, 4.5, 5, f=NEGRO),
        elipse(62, 50, 4.5, 5, f=NEGRO),
        elipse(50, 76, 5, 4, f=NEGRO),
        brillo(36, 40, 6, 6),
    ]


def golfino():
    return [
        ruta("M14 58 C26 34 58 26 82 38 C90 42 90 52 84 56 "
             "C70 66 38 74 14 58 Z", f=MAR, s=AZUL_ESCURO, sw=SW),
        ruta("M44 32 L52 14 L62 34 Z", f=MAR, s=AZUL_ESCURO, sw=SW),
        ruta("M14 58 L6 44 L10 62 L4 74 Z", f=MAR, s=AZUL_ESCURO, sw=SW),
        ruta("M40 62 C48 78 62 78 66 66 Z", f=MAR, s=AZUL_ESCURO, sw=3),
        ruta("M30 56 C46 68 68 62 82 52", f=CEO),
        elipse(74, 44, 4, 4.5, f=NEGRO),
        ruta("M80 52 Q84 54 88 52", s=AZUL_ESCURO, sw=2),
        brillo(40, 40, 8, 5),
    ]


def balea():
    # La cola HORIZONTAL y ancha es lo que dice «balea»: con cola vertical, por
    # muy gorda que sea, el ojo lee pez. También la boca larga y la barriga
    # clara. Es la tercera versión de esta lámina.
    return [
        ruta("M6 58 C14 36 44 26 68 32 C88 37 96 52 92 62 "
             "C87 74 62 84 38 82 C20 80 6 70 6 58 Z",
             f=AZUL_ESCURO, s=NEGRO, sw=SW),
        ruta("M14 56 C6 44 6 28 14 24 C24 30 26 44 26 52 Z",
             f=AZUL_ESCURO, s=NEGRO, sw=3),
        ruta("M14 60 C6 72 8 88 16 92 C26 86 26 70 26 62 Z",
             f=AZUL_ESCURO, s=NEGRO, sw=3),
        ruta("M24 74 C46 86 74 80 90 64 C72 82 44 84 24 74 Z", f=CREMA),
        ruta("M92 62 C82 70 70 72 62 68", s=NEGRO, sw=3),
        ruta("M54 62 C64 78 80 74 82 62 Z", f=AZUL_ESCURO, s=NEGRO, sw=2),
        ruta("M74 28 C72 18 80 14 80 22", s=CEO, sw=5),
        ruta("M80 22 C86 10 94 14 90 24", s=CEO, sw=5),
        elipse(80, 46, 4.5, 5, f=BRANCO),
        elipse(80, 46, 2.5, 3, f=NEGRO),
        brillo(40, 40, 8, 5),
    ]


def foca():
    # Erguida sobre as aletas dianteiras, co fociño arriba: é a postura coa que
    # se recoñece unha foca. Tombada e horizontal saía un peixe enfurruñado.
    cor, borde = "#64748b", "#334155"
    return [
        ruta("M40 30 C58 30 66 46 66 62 C66 78 58 88 44 88 "
             "L18 88 C10 88 8 80 16 76 C28 70 30 52 30 42 "
             "C30 34 34 30 40 30 Z", f=cor, s=borde, sw=SW),
        ruta("M66 62 C78 58 88 66 86 76 C84 84 72 84 66 78 Z",
             f=cor, s=borde, sw=3),
        ruta("M30 66 C20 62 12 68 14 76 C16 82 26 82 32 76 Z",
             f=cor, s=borde, sw=3),
        elipse(40, 44, 5, 5.5, f=NEGRO),
        elipse(56, 46, 5, 5.5, f=NEGRO),
        elipse(48, 56, 8, 6, f=NEGRO),
        ruta("M42 62 L28 62", s=borde, sw=2),
        ruta("M54 62 L68 62", s=borde, sw=2),
        ruta("M40 30 C40 22 48 20 50 26", s=borde, sw=3),
        brillo(36, 38, 5, 6),
    ]


def cangrexo():
    cor, borde = "#dc2626", "#7f1d1d"
    return [
        elipse(50, 58, 30, 22, f=cor, s=borde, sw=SW),
        ruta("M20 48 C6 40 6 24 18 22 C28 20 30 34 22 38 Z",
             f=cor, s=borde, sw=SW),
        ruta("M80 48 C94 40 94 24 82 22 C72 20 70 34 78 38 Z",
             f=cor, s=borde, sw=SW),
        ruta("M26 72 L14 84", s=borde, sw=5),
        ruta("M38 78 L32 90", s=borde, sw=5),
        ruta("M62 78 L68 90", s=borde, sw=5),
        ruta("M74 72 L86 84", s=borde, sw=5),
        elipse(40, 50, 6, 7, f=BRANCO, s=borde, sw=2),
        elipse(60, 50, 6, 7, f=BRANCO, s=borde, sw=2),
        elipse(40, 51, 3, 3, f=NEGRO),
        elipse(60, 51, 3, 3, f=NEGRO),
        brillo(36, 56, 6, 4),
    ]


def estrela_mar():
    cor, borde = "#f59e0b", "#b45309"
    return [
        ruta("M50 10 L63 42 L96 44 L70 64 L79 94 L50 76 "
             "L21 94 L30 64 L4 44 L37 42 Z", f=cor, s=borde, sw=SW),
        elipse(42, 48, 4, 4, f=borde),
        elipse(58, 48, 4, 4, f=borde),
        elipse(50, 62, 4, 4, f=borde),
        brillo(38, 36, 6, 6),
    ]


def ourizo_mar():
    cor, borde = "#6d28d9", "#3b0764"
    f = [elipse(50, 54, 24, 24, f=cor, s=borde, sw=SW)]
    import math as _m
    for i in range(12):
        a = _m.radians(i * 30)
        x0, y0 = 50 + _m.cos(a) * 22, 54 + _m.sin(a) * 22
        x1, y1 = 50 + _m.cos(a) * 40, 54 + _m.sin(a) * 40
        f.append(ruta(f"M{round(x0, 1)} {round(y0, 1)} "
                      f"L{round(x1, 1)} {round(y1, 1)}", s=borde, sw=5))
    f += [brillo(42, 46, 6, 6)]
    return f


def polvo():
    cor, borde = "#e11d48", "#881337"
    f = [
        ruta("M50 14 C72 14 82 30 82 48 L18 48 C18 30 28 14 50 14 Z",
             f=cor, s=borde, sw=SW),
        brillo(36, 28, 7, 8),
        elipse(40, 36, 6, 7, f=BRANCO, s=borde, sw=2),
        elipse(60, 36, 6, 7, f=BRANCO, s=borde, sw=2),
        elipse(40, 37, 3, 3, f=NEGRO),
        elipse(60, 37, 3, 3, f=NEGRO),
        ruta("M42 46 Q50 52 58 46", s=borde, sw=3),
    ]
    for i, x in enumerate([20, 32, 44, 56, 68, 80]):
        curva = 14 if i % 2 == 0 else -14
        f.append(ruta(f"M{x} 48 C{x + curva} 62 {x - curva} 74 {x} 86",
                      s=cor, sw=7))
    return f


def caracol():
    # La concha en espiral ATRÁS y el cuerpo saliendo hacia delante, que es la
    # silueta con la que se reconoce. La primera versión los tenía cruzados.
    cor, borde = "#a16207", "#5a3a12"
    return [
        ruta("M20 80 C14 80 10 74 14 70 C20 64 34 62 46 62 "
             "L76 62 C86 62 90 72 84 78 C80 82 70 80 60 80 Z",
             f=CREMA, s=borde, sw=SW),
        ruta("M22 70 L16 50", s=CREMA, sw=6),
        ruta("M34 66 L38 48", s=CREMA, sw=6),
        elipse(16, 47, 4, 4.5, f=NEGRO),
        elipse(38, 45, 4, 4.5, f=NEGRO),
        ruta("M66 22 C86 22 94 40 86 54 C78 68 56 66 52 52 "
             "C48 38 60 30 68 36 C76 42 72 54 62 52 "
             "C56 51 54 44 58 40", f=cor, s=borde, sw=SW),
        brillo(70, 32, 5, 4),
    ]


def bolboreta():
    return [
        ruta("M50 50 C30 20 8 26 12 46 C16 66 38 66 50 50 Z",
             f=MORADO, s=AZUL_ESCURO, sw=SW),
        ruta("M50 50 C70 20 92 26 88 46 C84 66 62 66 50 50 Z",
             f=MORADO, s=AZUL_ESCURO, sw=SW),
        ruta("M50 50 C34 62 22 78 34 88 C46 94 52 72 50 50 Z",
             f=ROSA_FORTE, s=AZUL_ESCURO, sw=SW),
        ruta("M50 50 C66 62 78 78 66 88 C54 94 48 72 50 50 Z",
             f=ROSA_FORTE, s=AZUL_ESCURO, sw=SW),
        rrect(46, 30, 8, 52, 4, f=PERFIL, s=NEGRO, sw=2),
        ruta("M48 30 C42 18 34 16 32 20", s=NEGRO, sw=3),
        ruta("M52 30 C58 18 66 16 68 20", s=NEGRO, sw=3),
        elipse(26, 40, 5, 5, f=AMARELO),
        elipse(74, 40, 5, 5, f=AMARELO),
    ]


def abella():
    return [
        ruta("M44 40 C24 24 10 34 18 48 C26 60 42 54 44 40 Z",
             f=BRANCO, s=GRIS_ESCURO, sw=3),
        ruta("M56 40 C76 24 90 34 82 48 C74 60 58 54 56 40 Z",
             f=BRANCO, s=GRIS_ESCURO, sw=3),
        elipse(50, 62, 26, 24, f=AMARELO, s=TERRACOTA, sw=SW),
        ruta("M32 52 C40 48 60 48 68 52", s=NEGRO, sw=7),
        ruta("M30 66 C40 70 60 70 70 66", s=NEGRO, sw=7),
        ruta("M38 80 C44 84 56 84 62 80", s=NEGRO, sw=6),
        elipse(42, 44, 4, 4.5, f=NEGRO),
        elipse(58, 44, 4, 4.5, f=NEGRO),
        ruta("M44 34 C40 24 34 22 32 24", s=NEGRO, sw=3),
        ruta("M56 34 C60 24 66 22 68 24", s=NEGRO, sw=3),
        brillo(40, 54, 5, 6),
    ]


def formiga():
    cor, borde = "#7c2d12", "#431407"
    return [
        elipse(24, 56, 12, 11, f=cor, s=borde, sw=SW),
        elipse(48, 58, 14, 13, f=cor, s=borde, sw=SW),
        elipse(76, 60, 17, 16, f=cor, s=borde, sw=SW),
        ruta("M20 48 C16 36 10 32 8 34", s=borde, sw=3),
        ruta("M28 46 C28 34 34 30 36 32", s=borde, sw=3),
        ruta("M40 68 L34 86", s=borde, sw=4),
        ruta("M52 70 L54 88", s=borde, sw=4),
        ruta("M68 72 L74 88", s=borde, sw=4),
        elipse(20, 52, 3.5, 4, f=BRANCO),
        elipse(20, 52, 2, 2, f=NEGRO),
        brillo(70, 52, 5, 5),
    ]


def pita():
    # Cuerpo redondo, cresta clara arriba, pico y barbilla a un lado. La
    # primera versión mezclaba cabeza, cuerpo y ala y no se leía ninguna.
    return [
        elipse(50, 62, 32, 28, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        elipse(50, 34, 20, 19, f=BRANCO, s=GRIS_ESCURO, sw=SW),
        ruta("M40 20 C40 10 48 10 48 18 C50 8 58 10 58 20 "
             "C58 14 64 16 62 22 Z", f=VERMELLO, s=VERMELLO_ESCURO, sw=3),
        ruta("M30 34 L14 40 L30 44 Z", f=LARANXA, s=TERRACOTA, sw=2),
        ruta("M36 46 C32 56 44 56 42 46 Z", f=VERMELLO,
             s=VERMELLO_ESCURO, sw=2),
        elipse(42, 32, 4, 4.5, f=NEGRO),
        ruta("M56 58 C76 54 82 74 60 78 Z", f=CREMA, s=GRIS_ESCURO, sw=3),
        ruta("M40 88 L36 94", s=LARANXA, sw=5),
        ruta("M60 88 L64 94", s=LARANXA, sw=5),
        brillo(38, 52, 6, 7),
    ]


def parrulo():
    return [
        elipse(50, 66, 30, 22, f=AMARELO, s=TERRACOTA, sw=SW),
        elipse(36, 36, 20, 19, f=AMARELO, s=TERRACOTA, sw=SW),
        ruta("M18 38 L4 42 L18 48 Z", f=LARANXA, s=TERRACOTA, sw=2),
        elipse(32, 32, 4, 4.5, f=NEGRO),
        ruta("M62 58 C78 54 84 70 66 76 Z", f=CREMA, s=TERRACOTA, sw=3),
        ruta("M40 86 L34 92", s=LARANXA, sw=4),
        ruta("M58 86 L64 92", s=LARANXA, sw=4),
        brillo(30, 28, 5, 6),
    ]


def tartaruga():
    verde, borde = "#15803d", "#14532d"
    return [
        ruta("M12 70 C12 44 30 30 50 30 C70 30 88 44 88 70 Z",
             f=verde, s=borde, sw=SW),
        ruta("M12 70 L88 70", s=borde, sw=3),
        ruta("M50 30 L50 70", s=borde, sw=3),
        ruta("M28 44 C40 52 60 52 72 44", s=borde, sw=3),
        elipse(88, 56, 12, 11, f=HERBA, s=borde, sw=3),
        elipse(92, 52, 3, 3.5, f=NEGRO),
        ruta("M22 70 L18 82", s=HERBA, sw=8),
        ruta("M44 70 L42 84", s=HERBA, sw=8),
        ruta("M68 70 L70 84", s=HERBA, sw=8),
        brillo(32, 44, 7, 5),
    ]


# ==========================================================================
# 3. ALFABETO · lo que no es ya un animal ni una cosa del vocabulario
# ==========================================================================

def elefante():
    # De frente: dos orejas grandes, la trompa recta en medio y los colmillos.
    # De perfil y con la trompa en curva era una mancha gris sin lectura.
    cor, borde = "#94a3b8", "#334155"
    return [
        elipse(20, 48, 18, 24, f=cor, s=borde, sw=SW),
        elipse(80, 48, 18, 24, f=cor, s=borde, sw=SW),
        elipse(50, 48, 28, 28, f=cor, s=borde, sw=SW),
        rrect(42, 62, 16, 32, 8, f=cor, s=borde, sw=SW),
        ruta("M46 76 L54 76", s=borde, sw=2),
        ruta("M46 84 L54 84", s=borde, sw=2),
        elipse(40, 44, 5, 5.5, f=NEGRO),
        elipse(60, 44, 5, 5.5, f=NEGRO),
        ruta("M34 68 C30 78 26 82 24 84", s=CREMA, sw=5),
        ruta("M66 68 C70 78 74 82 76 84", s=CREMA, sw=5),
        brillo(38, 34, 6, 7),
    ]


def guitarra():
    cor, borde = "#b45309", "#5a3a12"
    return [
        elipse(50, 66, 26, 24, f=cor, s=borde, sw=SW),
        elipse(50, 42, 20, 18, f=cor, s=borde, sw=SW),
        elipse(50, 62, 10, 10, f=PERFIL, s=borde, sw=3),
        rrect(45, 8, 10, 26, 3, f=borde, s=NEGRO, sw=2),
        rrect(42, 4, 16, 8, 3, f=NEGRO),
        ruta("M46 34 L46 88", s=CREMA, sw=2),
        ruta("M50 34 L50 88", s=CREMA, sw=2),
        ruta("M54 34 L54 88", s=CREMA, sw=2),
        brillo(36, 56, 5, 8),
    ]


def illas():
    return [
        rrect(0, 56, 100, 44, 0, f=MAR),
        ruta("M4 62 C20 40 36 40 48 62 Z", f=VERDE_ESCURO, s=PERFIL, sw=3),
        ruta("M40 64 C56 36 76 38 90 64 Z", f=HERBA, s=VERDE_ESCURO, sw=3),
        ruta("M74 66 C84 52 94 56 98 66 Z", f=VERDE_ESCURO, s=PERFIL, sw=3),
        rrect(0, 0, 100, 56, 0, f=CEO),
    ] + poner(sol(0, 0, 10), dx=76, dy=22) + [
        ruta("M8 76 Q20 70 32 76", s=CEO, sw=3),
        ruta("M44 84 Q56 78 68 84", s=CEO, sw=3),
        ruta("M20 90 Q32 84 44 90", s=CEO, sw=3),
    ]


def papaventos():
    return [
        ruta("M50 8 L82 40 L50 72 L18 40 Z", f=VERMELLO,
             s=VERMELLO_ESCURO, sw=SW),
        ruta("M50 8 L50 72", s=VERMELLO_ESCURO, sw=3),
        ruta("M18 40 L82 40", s=VERMELLO_ESCURO, sw=3),
        ruta("M50 8 L82 40 L50 40 Z", f=AMARELO),
        ruta("M50 40 L18 40 L50 72 Z", f=MAR),
        ruta("M50 72 C58 80 42 86 50 94", s=MADEIRA, sw=3),
        elipse(50, 80, 5, 4, f=ROSA_FORTE),
        elipse(50, 92, 5, 4, f=AMARELO),
    ]


def lua_noite():
    return [
        rrect(0, 0, 100, 100, 0, f=CEO_NOITE),
        ruta("M62 12 C36 12 20 34 24 58 C28 80 50 92 70 86 "
             "C50 78 40 58 44 42 C48 26 56 16 62 12 Z",
             f=AMARELO, s=TERRACOTA, sw=SW),
        elipse(78, 28, 3, 3, f=BRANCO),
        elipse(86, 50, 2.5, 2.5, f=BRANCO),
        elipse(70, 68, 2.5, 2.5, f=BRANCO),
        elipse(18, 20, 2.5, 2.5, f=BRANCO),
        brillo(40, 34, 5, 8),
    ]


def nino():
    return [
        ruta("M14 56 C14 78 34 88 50 88 C66 88 86 78 86 56 Z",
             f=MADEIRA, s=PERFIL, sw=SW),
        ruta("M14 56 C30 48 70 48 86 56", s=CHAN_MADEIRA, sw=5),
        ruta("M20 64 C36 58 64 58 80 64", s=CHAN_MADEIRA, sw=4),
        elipse(38, 54, 11, 9, f=CEO, s=AZUL_ESCURO, sw=3),
        elipse(58, 52, 11, 9, f=CREMA, s=TERRACOTA, sw=3),
        elipse(48, 46, 11, 9, f=ROSA, s=VERMELLO_ESCURO, sw=3),
        brillo(26, 60, 5, 4),
    ]


def cabaza():
    cor, borde = "#f97316", "#9a3412"
    return [
        elipse(50, 58, 36, 30, f=cor, s=borde, sw=SW),
        elipse(32, 58, 14, 29, f=cor, s=borde, sw=3),
        elipse(68, 58, 14, 29, f=cor, s=borde, sw=3),
        rrect(46, 20, 8, 12, 3, f=VERDE_ESCURO, s=PERFIL, sw=3),
        ruta("M54 24 C66 18 74 24 70 30", s=HERBA, sw=4),
        brillo(34, 44, 6, 8),
    ]


def silencio():
    # La mano ENTERA, entrando por abajo y por fuera de la cara, con el índice
    # en vertical sobre los labios. Un dedo solo, del color de la piel y en
    # medio de la cara, se leía como una lengua fuera: hacía falta la mano para
    # que el gesto fuese un gesto.
    return _cara("recta", ollos="abertos") + [
        rrect(56, 76, 26, 22, 9, f=FACE, s=TERRACOTA, sw=3),
        rrect(44, 54, 12, 34, 6, f=FACE, s=TERRACOTA, sw=3),
        ruta("M50 60 L50 84", s=TERRACOTA, sw=2),
        ruta("M20 26 C20 18 28 18 28 26 L28 34", s=MAR, sw=4),
        elipse(24, 38, 4, 4, f=MAR),
        ruta("M74 18 C74 10 82 10 82 18 L82 26", s=MAR, sw=4),
        elipse(78, 30, 4, 4, f=MAR),
    ]


def violin():
    cor, borde = "#7c2d12", "#431407"
    return [
        ruta("M50 30 C64 30 70 40 66 50 C62 58 62 66 68 74 "
             "C74 84 66 92 50 92 C34 92 26 84 32 74 "
             "C38 66 38 58 34 50 C30 40 36 30 50 30 Z",
             f=cor, s=borde, sw=SW),
        rrect(46, 6, 8, 26, 3, f=borde, s=NEGRO, sw=2),
        ruta("M42 4 C36 4 36 12 44 10", s=NEGRO, sw=4),
        ruta("M48 32 L48 88", s=CREMA, sw=2),
        ruta("M52 32 L52 88", s=CREMA, sw=2),
        ruta("M36 58 C38 52 40 64 38 68", s=NEGRO, sw=2),
        ruta("M64 58 C62 52 60 64 62 68", s=NEGRO, sw=2),
        brillo(38, 42, 5, 7),
    ]


def xilofono():
    cores = [VERMELLO, LARANXA, AMARELO, HERBA, MAR, MORADO]
    f = [ruta("M10 78 L20 26 L90 26 L80 78 Z", f=CHAN_MADEIRA,
              s=MADEIRA, sw=SW)]
    for i, c in enumerate(cores):
        y = 30 + i * 8
        x0 = 18 - i * 0.8
        f.append(rrect(x0 + 4, y, 70 - i * 2, 6, 3, f=c, s=MADEIRA, sw=2))
    f += [
        ruta("M62 84 L84 62", s=MADEIRA, sw=4),
        elipse(86, 60, 6, 6, f=VERMELLO, s=VERMELLO_ESCURO, sw=2),
    ]
    return f


def cebra():
    return [
        ruta("M30 36 L26 18 L42 28 Z", f=BRANCO, s=NEGRO, sw=3),
        ruta("M70 36 L74 18 L58 28 Z", f=BRANCO, s=NEGRO, sw=3),
        ruta("M50 26 C68 28 78 46 76 62 C74 78 62 88 50 88 "
             "C38 88 26 78 24 62 C22 46 32 28 50 26 Z",
             f=BRANCO, s=NEGRO, sw=SW),
        ruta("M34 38 C42 42 44 34 40 30", s=NEGRO, sw=5),
        ruta("M66 38 C58 42 56 34 60 30", s=NEGRO, sw=5),
        ruta("M28 56 L40 54", s=NEGRO, sw=5),
        ruta("M72 56 L60 54", s=NEGRO, sw=5),
        ruta("M32 70 L44 66", s=NEGRO, sw=4),
        ruta("M68 70 L56 66", s=NEGRO, sw=4),
        elipse(40, 50, 4.5, 5, f=NEGRO),
        elipse(60, 50, 4.5, 5, f=NEGRO),
        elipse(50, 78, 12, 9, f=PERFIL, s=NEGRO, sw=2),
        elipse(45, 76, 3, 3.5, f=NEGRO),
        elipse(55, 76, 3, 3.5, f=NEGRO),
        brillo(38, 40, 5, 6),
    ]



# ==========================================================================
# 4. VIGO E NATUREZA · miniescenas cuadradas. El mar siempre azul marino, la
#    arena siempre crema y el cielo siempre el mismo: si Samil y el Berbés
#    tuviesen dos mares distintos serían dos sitios sin relación.
# ==========================================================================

def _ceo_e_mar(y_horizonte=52):
    return [
        rrect(0, 0, 100, y_horizonte, 0, f=CEO),
        rrect(0, y_horizonte, 100, 100 - y_horizonte, 0, f=MAR),
    ]


def _ondas(ys, color=CEO):
    return [ruta(f"M{8 + (i % 2) * 16} {y} Q{24 + (i % 2) * 16} {y - 5} "
                 f"{40 + (i % 2) * 16} {y}", s=color, sw=3)
            for i, y in enumerate(ys)] + \
           [ruta(f"M{50 + (i % 2) * 14} {y} Q{66 + (i % 2) * 14} {y - 5} "
                 f"{82 + (i % 2) * 14} {y}", s=color, sw=3)
            for i, y in enumerate(ys)]


def mar_ria():
    return _ceo_e_mar(46) + poner(sol(0, 0, 9), dx=78, dy=20) + \
        _ondas([58, 70, 82]) + [
            ruta("M0 46 C20 38 40 44 58 40 C74 37 88 42 100 40 L100 46 Z",
                 f=VERDE_ESCURO),
        ]


def praia_samil():
    return _ceo_e_mar(40) + [
        ruta("M0 68 C24 60 76 60 100 68 L100 100 L0 100 Z", f=AREA),
    ] + _ondas([50, 60]) + poner(sol(0, 0, 9), dx=20, dy=18) + [
        ruta("M64 84 L64 62", s=MADEIRA, sw=4),
        ruta("M46 66 C52 52 76 52 82 66 Z", f=VERMELLO,
             s=VERMELLO_ESCURO, sw=3),
        elipse(28, 88, 9, 5, f=CREMA, s=TERRACOTA, sw=2),
    ]


def monte_castro():
    return [
        rrect(0, 0, 100, 62, 0, f=CEO),
        ruta("M0 70 C18 44 36 34 50 34 C64 34 84 46 100 70 L100 100 L0 100 Z",
             f=HERBA, s=VERDE_ESCURO, sw=3),
        rrect(38, 16, 26, 20, 2, f=GRIS, s=GRIS_ESCURO, sw=3),
        rrect(38, 12, 6, 6, 1, f=GRIS, s=GRIS_ESCURO, sw=2),
        rrect(50, 12, 6, 6, 1, f=GRIS, s=GRIS_ESCURO, sw=2),
        rrect(60, 12, 6, 6, 1, f=GRIS, s=GRIS_ESCURO, sw=2),
        rrect(47, 24, 8, 12, 2, f=PERFIL),
    ] + poner(arbore(0, 0, 0.5, VERDE_ESCURO), dx=18, dy=88) + \
        poner(arbore(0, 0, 0.45, HERBA), dx=82, dy=92)


def parque_castrelos():
    return [
        rrect(0, 0, 100, 60, 0, f=CEO),
        rrect(0, 60, 100, 40, 0, f=HERBA),
    ] + poner(sol(0, 0, 9), dx=80, dy=18) + \
        poner(arbore(0, 0, 0.72, VERDE_ESCURO, HERBA), dx=30, dy=78) + [
            ruta("M0 78 C30 72 70 72 100 78", s=AREA, sw=7),
            rrect(62, 62, 30, 6, 2, f=CHAN_MADEIRA, s=MADEIRA, sw=2),
            rrect(64, 68, 4, 10, 1, f=MADEIRA),
            rrect(86, 68, 4, 10, 1, f=MADEIRA),
            elipse(50, 92, 8, 4, f=VERDE_ESCURO),
        ]


def monte_guia():
    return _ceo_e_mar(58) + [
        ruta("M0 66 C16 42 32 30 46 30 C60 30 76 44 88 66 Z",
             f=HERBA, s=VERDE_ESCURO, sw=3),
        rrect(38, 16, 18, 16, 2, f=BRANCO, s=GRIS_ESCURO, sw=3),
        ruta("M34 16 L47 6 L60 16 Z", f=VERMELLO, s=VERMELLO_ESCURO, sw=2),
        ruta("M47 6 L47 0", s=GRIS_ESCURO, sw=2),
    ] + _ondas([76, 88])


def berbes():
    return _ceo_e_mar(56) + [
        rrect(4, 34, 18, 24, 2, f=CREMA, s=MADEIRA, sw=3),
        rrect(24, 28, 18, 30, 2, f=BRANCO, s=MADEIRA, sw=3),
        rrect(44, 36, 16, 22, 2, f=CREMA, s=MADEIRA, sw=3),
        rrect(9, 40, 6, 6, 1, f=CEO),
        rrect(29, 34, 6, 6, 1, f=CEO),
        rrect(49, 42, 6, 6, 1, f=CEO),
    ] + poner([f for f in __import__("json").loads(
        (DESTINO / "barco.json").read_text(encoding="utf-8"))["formas"]],
        e=0.4, dx=62, dy=54) + _ondas([74, 86])


def nube_soa():
    return [
        rrect(0, 0, 100, 100, 0, f=CEO),
    ] + poner(nube(0, 0, 1.5), dx=50, dy=46) + [
        elipse(22, 76, 12, 6, f=BRANCO),
        elipse(78, 82, 10, 5, f=BRANCO),
    ]


def arco_da_vella():
    cores = [VERMELLO, LARANXA, AMARELO, HERBA, MAR, MORADO]
    f = [rrect(0, 0, 100, 100, 0, f=CEO)]
    for i, c in enumerate(cores):
        r = 46 - i * 6
        f.append(ruta(f"M{50 - r} 84 A1 1 0 0 1 {50 + r} 84".replace("A1 1 0 0 1 ",
                 f"C{50 - r} {84 - r * 1.3} {50 + r} {84 - r * 1.3} "),
                 s=c, sw=6))
    f += poner(nube(0, 0, 0.7), dx=24, dy=82)
    f += poner(nube(0, 0, 0.7), dx=76, dy=82)
    return f


def outono():
    return [
        rrect(0, 0, 100, 66, 0, f="#fde68a"),
        rrect(0, 66, 100, 34, 0, f="#d97706"),
    ] + poner(arbore(0, 0, 0.85, LARANXA, TERRACOTA), dx=34, dy=76) + \
        poner(folla(0, 0, 1.1, LARANXA), dx=70, dy=34) + \
        poner(folla(0, 0, 0.9, TERRACOTA), dx=82, dy=54) + \
        poner(folla(0, 0, 0.8, AMARELO, TERRACOTA), dx=66, dy=72)


def inverno():
    f = [
        rrect(0, 0, 100, 68, 0, f="#dbeafe"),
        ruta("M0 68 C20 60 36 66 52 62 C68 58 86 64 100 60 L100 100 L0 100 Z",
             f=BRANCO, s=CEO, sw=3),
        ruta("M26 74 L26 34", s=MADEIRA, sw=9),
        ruta("M26 52 L10 36", s=MADEIRA, sw=5),
        ruta("M26 44 L42 28", s=MADEIRA, sw=5),
        ruta("M26 60 L14 52", s=MADEIRA, sw=4),
    ]
    import math as _m
    for k in range(6):
        a = _m.radians(k * 60)
        x1, y1 = 72 + _m.cos(a) * 20, 38 + _m.sin(a) * 20
        f.append(ruta(f"M72 38 L{round(x1, 1)} {round(y1, 1)}", s=BRANCO, sw=6))
        f.append(ruta(f"M72 38 L{round(x1, 1)} {round(y1, 1)}", s=MAR, sw=2))
    f += [elipse(72, 38, 6, 6, f=BRANCO, s=MAR, sw=2),
          elipse(20, 86, 4, 4, f=BRANCO, s=CEO, sw=2),
          elipse(56, 90, 4, 4, f=BRANCO, s=CEO, sw=2),
          elipse(86, 84, 4, 4, f=BRANCO, s=CEO, sw=2)]
    return f


def primavera():
    return [
        rrect(0, 0, 100, 64, 0, f=CEO),
        rrect(0, 64, 100, 36, 0, f=HERBA),
    ] + poner(sol(0, 0, 10), dx=76, dy=20) + poner(
        __import__("json").loads(
            (DESTINO / "flor.json").read_text(encoding="utf-8"))["formas"],
        e=0.62, dx=19, dy=33) + [
        ruta("M62 88 L62 70", s=VERDE_ESCURO, sw=4),
        elipse(62, 66, 7, 7, f=ROSA_FORTE, s=VERMELLO_ESCURO, sw=2),
        ruta("M84 88 L84 74", s=VERDE_ESCURO, sw=4),
        elipse(84, 70, 6, 6, f=AMARELO, s=TERRACOTA, sw=2),
    ]


def veran():
    return _ceo_e_mar(56) + [
        ruta("M0 72 C24 64 76 64 100 72 L100 100 L0 100 Z", f=AREA),
    ] + poner(sol(0, 0, 13), dx=74, dy=22) + _ondas([60]) + [
        ruta("M26 88 L26 68", s=MADEIRA, sw=4),
        ruta("M10 70 C16 58 36 58 42 70 Z", f=AMARELO,
             s=TERRACOTA, sw=3),
        elipse(66, 88, 10, 5, f=CREMA, s=TERRACOTA, sw=2),
    ]


def pedra_rio():
    return [
        rrect(0, 0, 100, 60, 0, f=AUGA),
        rrect(0, 60, 100, 40, 0, f=AREA),
    ] + _ondas([20, 34, 48], color=BRANCO) + [
        elipse(50, 66, 30, 20, f=GRIS, s=GRIS_ESCURO, sw=SW),
        elipse(24, 84, 12, 8, f=GRIS_ESCURO, s=PERFIL, sw=2),
        elipse(80, 86, 10, 7, f=GRIS_ESCURO, s=PERFIL, sw=2),
        brillo(38, 58, 8, 5),
    ]


# ==========================================================================
# 5. EMOCIÓNS E CORPO · la misma cara, distinta expresión. Cambia lo que se
#    siente, no quién lo siente.
# ==========================================================================

def _zzz(x, y):
    return [
        ruta(f"M{x} {y} L{x + 10} {y} L{x} {y + 10} L{x + 10} {y + 10}",
             s=MAR, sw=3),
        ruta(f"M{x + 12} {y - 12} L{x + 20} {y - 12} L{x + 12} {y - 5} "
             f"L{x + 20} {y - 5}", s=MAR, sw=3),
    ]


def alegria():
    return _cara("risa", ollos="pechados", cejas="arriba") + [
        elipse(24, 62, 7, 5, f=ROSA),
        elipse(76, 62, 7, 5, f=ROSA),
        ruta("M14 24 L20 30", s=AMARELO, sw=4),
        ruta("M86 24 L80 30", s=AMARELO, sw=4),
        ruta("M50 10 L50 16", s=AMARELO, sw=4),
    ]


def calma():
    return _cara("sorriso", ollos="pechados") + [
        ruta("M12 30 C22 22 34 22 42 28", s=AUGA, sw=3),
        ruta("M58 28 C66 22 78 22 88 30", s=AUGA, sw=3),
    ]


def sorpresa():
    return _cara("o", ollos="grandes", cejas="arriba") + [
        ruta("M12 26 L18 32", s=AMARELO, sw=4),
        ruta("M88 26 L82 32", s=AMARELO, sw=4),
    ]


def sono():
    return _cara("sorriso", ollos="cansos") + _zzz(70, 16)


def fame():
    return _cara("o", ollos="abertos") + poner(
        __import__("json").loads(
            (DESTINO / "mazan.json").read_text(encoding="utf-8"))["formas"],
        e=0.36, dx=64, dy=64)


def sede():
    return _cara("o", ollos="abertos") + poner(
        __import__("json").loads(
            (DESTINO / "auga.json").read_text(encoding="utf-8"))["formas"],
        e=0.38, dx=64, dy=60)


def tristeza():
    return _cara("triste", ollos="abertos") + [
        ruta("M38 54 C34 62 34 70 40 70 C46 70 44 62 38 54 Z",
             f=AUGA, s=MAR, sw=2),
        ruta("M82 74 C92 66 96 78 86 84", s=FACE, sw=9),
        ruta("M82 74 C92 66 96 78 86 84", s=TERRACOTA, sw=2),
    ]


def enfado_acougado():
    return _cara("recta", ollos="abertos", cejas="xuntas") + [
        ruta("M14 78 C24 70 24 88 34 80", s=AUGA, sw=4),
        ruta("M66 80 C76 88 76 70 86 78", s=AUGA, sw=4),
    ]


def orellas():
    return [
        elipse(50, 54, 28, 30, f=FACE, s=TERRACOTA, sw=SW),
        elipse(20, 52, 14, 18, f=FACE, s=TERRACOTA, sw=SW),
        elipse(80, 52, 14, 18, f=FACE, s=TERRACOTA, sw=SW),
        ruta("M20 44 C26 50 26 58 20 62", s=TERRACOTA, sw=3),
        ruta("M80 44 C74 50 74 58 80 62", s=TERRACOTA, sw=3),
        elipse(42, 48, 4, 4.5, f=NEGRO),
        elipse(58, 48, 4, 4.5, f=NEGRO),
        ruta("M42 66 Q50 72 58 66", s=NEGRO, sw=3),
        ruta("M6 38 C0 46 0 58 6 66", s=MAR, sw=3),
        ruta("M94 38 C100 46 100 58 94 66", s=MAR, sw=3),
        brillo(38, 38, 6, 8),
    ]


def boca_canta():
    return _cara("canta", ollos="pechados") + [
        elipse(84, 30, 6, 5, f=MAR),
        ruta("M90 30 L90 14", s=MAR, sw=3),
        elipse(16, 22, 5, 4, f=MAR),
        ruta("M21 22 L21 8", s=MAR, sw=3),
    ]


def costas():
    return [
        elipse(50, 24, 14, 14, f=FACE, s=TERRACOTA, sw=SW),
        ruta("M30 44 C30 36 70 36 70 44 L76 78 C60 86 40 86 24 78 Z",
             f=MORADO, s=AZUL_ESCURO, sw=SW),
        ruta("M50 44 L50 82", s=AZUL_ESCURO, sw=3),
        ruta("M38 52 L38 78", s=AZUL_ESCURO, sw=2),
        ruta("M62 52 L62 78", s=AZUL_ESCURO, sw=2),
        ruta("M22 60 C14 68 14 80 20 86", s=FACE, sw=8),
        ruta("M78 60 C86 68 86 80 80 86", s=FACE, sw=8),
        brillo(42, 18, 5, 5),
    ]


def dedos():
    return [
        rrect(30, 54, 42, 38, 12, f=FACE, s=TERRACOTA, sw=SW),
        rrect(32, 22, 10, 36, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(44, 14, 10, 44, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(56, 18, 10, 40, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(68, 28, 9, 30, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(14, 58, 18, 10, 5, f=FACE, s=TERRACOTA, sw=3),
        brillo(38, 70, 5, 6),
    ]


def pluma():
    return [
        ruta("M76 14 C46 26 26 52 20 86", s=CREMA, sw=3),
        ruta("M76 14 C52 18 34 34 28 60 C40 62 64 44 76 14 Z",
             f=BRANCO, s=GRIS, sw=3),
        ruta("M76 14 C60 34 42 52 24 74 C40 82 68 60 76 14 Z",
             f=CEO, s=GRIS, sw=3),
        ruta("M20 86 L14 94", s=GRIS_ESCURO, sw=3),
    ]


def son_forte():
    return [
        rrect(18, 40, 18, 22, 3, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        ruta("M36 40 L58 22 L58 80 L36 62 Z", f=CHAN_MADEIRA,
             s=MADEIRA, sw=SW),
        ruta("M66 34 C76 44 76 58 66 68", s=VERMELLO, sw=5),
        ruta("M78 24 C94 42 94 60 78 78", s=VERMELLO, sw=5),
        brillo(24, 46, 4, 5),
    ]




# ==========================================================================
# 6. ESCOLA E RUTINAS · lo que se hace, dibujado por su objeto. Una rutina no
#    tiene silueta; el plato de la merienda y la caja de recoger, sí.
# ==========================================================================

def _lamina_gardada(clave):
    return json.loads(
        (DESTINO / f"{clave}.json").read_text(encoding="utf-8"))["formas"]


def pegar(formas, cx, cy, alto):
    """Coloca un grupo de formas CENTRADO en (cx, cy) con el alto que se pida.

    `poner()` solo desplaza: pasarle el centro como desplazamiento deja la
    figura medio fuera del lienzo. Lo cazó check_laminas.py en la casa de
    «Ponte á casa», que salía por la derecha.
    """
    e = alto / 100.0
    return poner(formas, e=e, dx=cx - 50 * e, dy=cy - 50 * e)


def merenda():
    return prato() + pegar(_lamina_gardada("mazan"), 44, 48, 30) + \
        pegar(_lamina_gardada("auga"), 72, 40, 34)


def sesta():
    return cama() + _zzz(58, 26)


def pezas_madeira():
    return [
        rrect(12, 60, 26, 26, 3, f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        rrect(42, 60, 26, 26, 3, f=AMARELO, s=TERRACOTA, sw=SW),
        rrect(72, 60, 18, 26, 3, f=HERBA, s=VERDE_ESCURO, sw=SW),
        rrect(26, 32, 26, 26, 3, f=MAR, s=AZUL_ESCURO, sw=SW),
        ruta("M56 58 L69 32 L82 58 Z", f=LARANXA, s=TERRACOTA, sw=SW),
        brillo(18, 66, 4, 5),
    ]


def recollida():
    return [
        rrect(16, 46, 68, 40, 5, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(12, 38, 76, 12, 4, f=TERRACOTA, s=MADEIRA, sw=SW),
        elipse(36, 30, 11, 11, f=VERMELLO, s=VERMELLO_ESCURO, sw=3),
        rrect(52, 20, 18, 18, 3, f=MAR, s=AZUL_ESCURO, sw=3),
        ruta("M40 12 L36 22", s=LOUSA, sw=3),
        ruta("M76 16 L80 26", s=LOUSA, sw=3),
        brillo(22, 54, 4, 6),
    ]


def lectura_colectiva():
    return alfombra() + pegar(libro(), 50, 50, 56) + [
        elipse(18, 34, 6, 6, f=FACE, s=TERRACOTA, sw=2),
        elipse(82, 34, 6, 6, f=FACE, s=TERRACOTA, sw=2),
        elipse(50, 14, 6, 6, f=FACE, s=TERRACOTA, sw=2),
    ]


def gateo():
    # La criatura gateando de perfil sobre la colchoneta: cabeza, tronco y las
    # cuatro apoyadas. Con un trazo morado sobre una barra azul no se leía
    # nada; el gateo se reconoce por la postura, no por el sitio.
    return [
        rrect(6, 70, 88, 20, 8, f=AUGA, s=AZUL_ESCURO, sw=SW),
        ruta("M34 52 C46 44 62 44 72 54", s=MORADO, sw=16),
        elipse(24, 46, 14, 14, f=FACE, s=TERRACOTA, sw=3),
        elipse(20, 44, 3.5, 4, f=NEGRO),
        ruta("M20 52 Q25 56 30 52", s=TERRACOTA, sw=2),
        ruta("M36 60 L32 72", s=FACE, sw=8),
        ruta("M54 62 L52 72", s=FACE, sw=8),
        ruta("M70 60 L76 72", s=FACE, sw=8),
        ruta("M84 40 L92 34", s=LOUSA, sw=3),
        ruta("M86 50 L96 48", s=LOUSA, sw=3),
        brillo(16, 40, 4, 5),
    ]


def despedida():
    return [
        rrect(36, 46, 30, 46, 12, f=FACE, s=TERRACOTA, sw=SW),
        rrect(30, 20, 11, 34, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(44, 14, 11, 40, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(58, 20, 11, 34, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(70, 32, 10, 24, 5, f=FACE, s=TERRACOTA, sw=3),
        ruta("M14 30 C8 38 8 50 14 58", s=MAR, sw=4),
        ruta("M6 24 C-2 38 -2 52 6 66", s=MAR, sw=4),
        brillo(44, 60, 5, 6),
    ]


def entrada_familia():
    # La persona adulta y la criatura DE LA MANO delante de la puerta. Dos
    # barras de color al lado de una puerta no son una familia entrando.
    return [
        rrect(6, 8, 38, 84, 5, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(13, 18, 24, 22, 3, s=MADEIRA, sw=3),
        elipse(37, 52, 4, 4, f=AMARELO, s=TERRACOTA, sw=2),
        elipse(62, 26, 12, 12, f=FACE, s=TERRACOTA, sw=3),
        ruta("M62 38 L62 68", s=MORADO, sw=16),
        ruta("M62 48 L78 58", s=FACE, sw=7),
        ruta("M58 68 L54 90", s=AZUL_ESCURO, sw=7),
        ruta("M66 68 L70 90", s=AZUL_ESCURO, sw=7),
        elipse(88, 54, 9, 9, f=FACE, s=TERRACOTA, sw=3),
        ruta("M88 63 L88 78", s=HERBA, sw=12),
        ruta("M88 66 L78 58", s=FACE, sw=6),
        ruta("M85 78 L83 90", s=AZUL_ESCURO, sw=5),
        ruta("M91 78 L93 90", s=AZUL_ESCURO, sw=5),
    ]


def sentar_alfombra():
    return alfombra() + [
        elipse(50, 30, 12, 12, f=FACE, s=TERRACOTA, sw=3),
        ruta("M38 48 C44 42 56 42 62 48 L64 58 L36 58 Z",
             f=MORADO, s=AZUL_ESCURO, sw=3),
        rrect(46, 24, 8, 22, 4, f=FACE, s=TERRACOTA, sw=2),
        ruta("M22 16 C22 8 30 8 30 16 L30 22", s=MAR, sw=3),
        elipse(26, 26, 3, 3, f=MAR),
    ]


def quendas():
    return [
        ruta("M8 20 L48 20 C54 20 54 26 54 30 L54 46 "
             "C54 52 48 52 44 52 L24 52 L14 62 L16 52 "
             "C10 52 8 48 8 44 Z", f=AUGA, s=AZUL_ESCURO, sw=SW),
        ruta("M92 44 L56 44 C50 44 50 50 50 54 L50 70 "
             "C50 76 56 76 60 76 L78 76 L88 86 L86 76 "
             "C92 76 92 72 92 68 Z", f=AMARELO, s=TERRACOTA, sw=SW),
        ruta("M26 30 L26 44", s=BRANCO, sw=5),
        ruta("M64 56 C64 52 74 52 74 58 L64 68 L76 68", s=TERRACOTA, sw=4),
    ]


def compartir():
    return [
        elipse(50, 50, 18, 18, f=VERMELLO, s=VERMELLO_ESCURO, sw=SW),
        rrect(6, 54, 26, 20, 8, f=FACE, s=TERRACOTA, sw=3),
        rrect(10, 40, 9, 20, 4, f=FACE, s=TERRACOTA, sw=3),
        rrect(21, 38, 9, 22, 4, f=FACE, s=TERRACOTA, sw=3),
        rrect(68, 54, 26, 20, 8, f=FACE, s=TERRACOTA, sw=3),
        rrect(70, 38, 9, 22, 4, f=FACE, s=TERRACOTA, sw=3),
        rrect(81, 40, 9, 20, 4, f=FACE, s=TERRACOTA, sw=3),
        ruta("M50 24 C50 16 58 16 58 24", s=HERBA, sw=3),
    ]


def pintura_dedos():
    return [
        rrect(30, 50, 40, 40, 12, f=FACE, s=TERRACOTA, sw=SW),
        rrect(32, 22, 10, 32, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(44, 16, 10, 38, 5, f=FACE, s=TERRACOTA, sw=3),
        rrect(56, 20, 10, 34, 5, f=FACE, s=TERRACOTA, sw=3),
        elipse(37, 20, 6, 6, f=VERMELLO),
        elipse(49, 14, 6, 6, f=MAR),
        elipse(61, 18, 6, 6, f=AMARELO),
        elipse(14, 76, 8, 6, f=HERBA),
        elipse(86, 70, 7, 5, f=MORADO),
        brillo(38, 64, 5, 6),
    ]


def patio_verde():
    return [
        rrect(0, 0, 100, 58, 0, f=CEO),
        rrect(0, 58, 100, 42, 0, f=HERBA),
        ruta("M50 100 C46 84 54 74 50 58", s=AREA, sw=14),
    ] + poner(sol(0, 0, 9), dx=80, dy=18) + \
        poner(arbore(0, 0, 0.6, VERDE_ESCURO), dx=20, dy=74) + [
            elipse(78, 76, 7, 5, f=VERDE_ESCURO),
            elipse(30, 92, 9, 5, f=VERDE_ESCURO),
        ]


def danza_corro():
    import math as _m
    f = [elipse(50, 56, 34, 30, s=AUGA, sw=4)]
    for k in range(5):
        a = _m.radians(-90 + k * 72)
        x, y = 50 + _m.cos(a) * 34, 56 + _m.sin(a) * 30
        f += [elipse(round(x, 1), round(y, 1), 11, 11, f=FACE,
                     s=TERRACOTA, sw=3)]
    f += [ruta("M50 12 C58 4 68 10 62 18", s=MAR, sw=3),
          ruta("M18 30 L12 24", s=MAR, sw=3)]
    return f


def respiracion():
    return [
        elipse(50, 54, 36, 36, s=AUGA, sw=3),
        elipse(50, 54, 26, 26, s=AUGA, sw=3),
        elipse(50, 54, 16, 16, f=AUGA, s=AZUL_ESCURO, sw=3),
        ruta("M50 12 C60 16 60 22 52 24", s=MAR, sw=3),
        ruta("M50 96 C40 92 40 86 48 84", s=MAR, sw=3),
        brillo(44, 46, 4, 5),
    ]


def saida_feliz():
    return [
        rrect(6, 14, 40, 76, 5, f=CHAN_MADEIRA, s=MADEIRA, sw=SW),
        rrect(14, 24, 24, 22, 3, s=MADEIRA, sw=3),
        elipse(38, 56, 4, 4, f=AMARELO, s=TERRACOTA, sw=2),
    ] + poner(sol(0, 0, 9), dx=76, dy=24) + [
        elipse(70, 56, 11, 11, f=FACE, s=TERRACOTA, sw=3),
        ruta("M70 68 L70 88", s=VERMELLO, sw=12),
        ruta("M60 72 L52 64", s=FACE, sw=6),
        ruta("M80 72 L90 66", s=FACE, sw=6),
        ruta("M66 52 Q70 56 74 52", s=TERRACOTA, sw=2),
    ]


def ponte_a_casa():
    return pegar(libro(), 26, 54, 46) + \
        pegar(casa(), 76, 54, 46) + [
            ruta("M44 46 L60 46", s=AUGA, sw=5),
            ruta("M54 40 L60 46 L54 52", s=AUGA, sw=5),
        ]


# ==========================================================================
# 7. CONTOS ILUSTRADOS · las cuatro escenas que faltaban. Apaisadas, como las
#    otras treinta: una escena no cabe en un cuadrado sin encogerse hasta no
#    distinguirse.
# ==========================================================================

APAISADAS = {"cuento_ilus_197", "cuento_ilus_201",
             "cuento_ilus_203", "cuento_ilus_204"}


def arco_sobre_a_ria():
    cores = [VERMELLO, LARANXA, AMARELO, HERBA, MAR, MORADO]
    f = [rrect(0, 0, 160, 62, 0, f=CEO), rrect(0, 62, 160, 38, 0, f=MAR)]
    for k, c in enumerate(cores):
        r = 56 - k * 6
        f.append(ruta(f"M{80 - r} 62 C{80 - r} {62 - r * 1.1} "
                      f"{80 + r} {62 - r * 1.1} {80 + r} 62", s=c, sw=6))
    f += [ruta("M6 72 Q22 66 38 72", s=CEO, sw=3),
          ruta("M60 80 Q76 74 92 80", s=CEO, sw=3),
          ruta("M110 70 Q126 64 142 70", s=CEO, sw=3),
          ruta("M30 90 Q46 84 62 90", s=CEO, sw=3)]
    f += pegar(_lamina_gardada("barco"), 124, 78, 30)
    return f


def abella_e_amigos():
    f = [rrect(0, 0, 160, 66, 0, f=CEO), rrect(0, 66, 160, 34, 0, f=HERBA)]
    f += poner(sol(0, 0, 10), dx=138, dy=20)
    for x, cor in ((24, ROSA_FORTE), (56, AMARELO), (132, VERMELLO)):
        f += [ruta(f"M{x} 92 L{x} 70", s=VERDE_ESCURO, sw=4),
              elipse(x, 64, 9, 9, f=cor, s=TERRACOTA, sw=3),
              elipse(x, 64, 4, 4, f=AMARELO)]
    f += pegar(abella(), 88, 34, 34)
    f += pegar(abella(), 116, 52, 22)
    f += pegar(abella(), 62, 22, 22)
    f += [ruta("M74 40 C82 30 92 44 100 34", s=LOUSA, sw=2),
          ruta("M100 48 C108 40 112 54 118 48", s=LOUSA, sw=2)]
    return f


def ponte_de_rande():
    f = [rrect(0, 0, 160, 58, 0, f=CEO), rrect(0, 58, 160, 42, 0, f=MAR)]
    f += [
        ruta("M0 46 L160 46", s=LOUSA, sw=7),
        ruta("M40 46 L40 12", s=LOUSA, sw=6),
        ruta("M120 46 L120 12", s=LOUSA, sw=6),
        ruta("M40 16 C60 30 60 32 80 40", s=GRIS, sw=3),
        ruta("M40 16 C30 26 24 34 8 42", s=GRIS, sw=3),
        ruta("M120 16 C100 30 100 32 80 40", s=GRIS, sw=3),
        ruta("M120 16 C130 26 136 34 152 42", s=GRIS, sw=3),
        ruta("M0 42 L160 42", s=CHAN_MADEIRA, sw=4),
    ]
    f += pegar(_lamina_gardada("barco"), 104, 78, 28)
    f += [ruta("M10 70 Q26 64 42 70", s=CEO, sw=3),
          ruta("M60 84 Q76 78 92 84", s=CEO, sw=3),
          ruta("M124 88 Q140 82 156 88", s=CEO, sw=3)]
    return f


def ras_de_san_xoan():
    f = [rrect(0, 0, 160, 64, 0, f=CEO_NOITE), rrect(0, 64, 160, 36, 0, f=AUGA)]
    f += [elipse(132, 20, 12, 12, f=AMARELO, s=TERRACOTA, sw=2),
          elipse(126, 18, 5, 5, f=CEO_NOITE)]
    for x, y in ((20, 16), (52, 28), (86, 14), (110, 34), (148, 44)):
        f.append(elipse(x, y, 2.5, 2.5, f=BRANCO))
    for x, alto in ((34, 34), (76, 40), (120, 30)):
        f += pegar(_lamina_gardada("ra"), x, 80, alto)
    f += [ruta("M16 92 Q30 86 44 92", s=BRANCO, sw=3),
          ruta("M96 94 Q110 88 124 94", s=BRANCO, sw=3),
          ruta("M60 50 C64 44 70 50 66 56", s=AMARELO, sw=3),
          ruta("M100 44 C104 38 110 44 106 50", s=AMARELO, sw=3)]
    return f


# ==========================================================================
# El índice: clave del banco -> función que la dibuja
# ==========================================================================

DIBUXOS = {
    # --- vocabulario ---
    "vocab_27": casa,
    "vocab_28": mesa,
    "vocab_29": cadeira,
    "vocab_30": prato,
    "vocab_31": culler,
    "vocab_33": cama,
    "vocab_34": alfombra,
    "vocab_35": libro,
    "vocab_41": cepillo,
    "vocab_42": tesoiras,
    "vocab_43": lapis,
    "vocab_44": papel,
    "vocab_45": pelota,
    "vocab_46": boneca,
    "vocab_47": tren,
    "vocab_48": coche,
    "vocab_49": campa,
    "vocab_50": reloxo,
    "vocab_51": fiestra,
    "vocab_52": porta,
    "vocab_53": chave,
    "vocab_54": espello,
    "vocab_55": lampada,
    "vocab_56": caixa,
    "vocab_57": boton,
    "vocab_58": lazo,
    "vocab_60": berce,
    "vocab_61": cueiro,
    "vocab_62": biberon,
    "vocab_63": bico,
    "vocab_66": sorriso,
    # --- animais ---
    "animais_67": can,
    "animais_73": golfino,
    "animais_74": polvo,
    "animais_75": caracol,
    "animais_76": bolboreta,
    "animais_77": abella,
    "animais_78": formiga,
    "animais_79": vaca,
    "animais_80": ovella,
    "animais_81": cabalo,
    "animais_82": porco,
    "animais_83": pita,
    "animais_84": parrulo,
    "animais_85": coello,
    "animais_86": rato,
    "animais_87": tartaruga,
    "animais_89": leon,
    "animais_90": raposo,
    "animais_91": balea,
    "animais_92": foca,
    "animais_93": cangrexo,
    "animais_94": estrela_mar,
    "animais_95": ourizo_mar,
    # --- alfabeto ---
    "flashcard_d_dog": can,
    "flashcard_e_elephant": elefante,
    "flashcard_g_guitar": guitarra,
    "flashcard_i_island": illas,
    "flashcard_k_kite": papaventos,
    "flashcard_m_moon": lua_noite,
    "flashcard_n_nest": nino,
    "flashcard_o_octopus": polvo,
    "flashcard_p_pumpkin": cabaza,
    "flashcard_q_quiet": silencio,
    "flashcard_v_violin": violin,
    "flashcard_x_xylophone": xilofono,
    "flashcard_z_zebra": cebra,
    # --- vigo e natureza ---
    "vigo_nat_97": mar_ria,
    "vigo_nat_98": illas,
    "vigo_nat_99": praia_samil,
    "vigo_nat_100": monte_castro,
    "vigo_nat_101": parque_castrelos,
    "vigo_nat_102": monte_guia,
    "vigo_nat_103": berbes,
    "vigo_nat_105": nube_soa,
    "vigo_nat_108": arco_da_vella,
    "vigo_nat_109": outono,
    "vigo_nat_110": inverno,
    "vigo_nat_111": primavera,
    "vigo_nat_112": veran,
    "vigo_nat_118": pedra_rio,
    # --- emocións e corpo ---
    "emocions_corp_147": alegria,
    "emocions_corp_148": calma,
    "emocions_corp_149": sorpresa,
    "emocions_corp_150": sono,
    "emocions_corp_151": fame,
    "emocions_corp_152": sede,
    "emocions_corp_154": tristeza,
    "emocions_corp_155": enfado_acougado,
    "emocions_corp_158": orellas,
    "emocions_corp_160": boca_canta,
    "emocions_corp_164": costas,
    "emocions_corp_165": dedos,
    "emocions_corp_167": pluma,
    "emocions_corp_168": son_forte,
    # --- escola e rutinas ---
    "escola_rut_125": merenda,
    "escola_rut_126": sesta,
    "escola_rut_127": pezas_madeira,
    "escola_rut_128": recollida,
    "escola_rut_129": lectura_colectiva,
    "escola_rut_131": gateo,
    "escola_rut_132": despedida,
    "escola_rut_133": entrada_familia,
    "escola_rut_135": sentar_alfombra,
    "escola_rut_136": quendas,
    "escola_rut_137": compartir,
    "escola_rut_138": pintura_dedos,
    "escola_rut_140": patio_verde,
    "escola_rut_141": danza_corro,
    "escola_rut_142": respiracion,
    "escola_rut_145": saida_feliz,
    "escola_rut_146": ponte_a_casa,
    # --- contos ilustrados (apaisados) ---
    "cuento_ilus_197": arco_sobre_a_ria,
    "cuento_ilus_201": abella_e_amigos,
    "cuento_ilus_203": ponte_de_rande,
    "cuento_ilus_204": ras_de_san_xoan,
}


def lamina(clave, nota=""):
    """El fichero de una lámina, ya listo para escribir."""
    apaisada = clave in APAISADAS
    return {
        "vb": 160 if apaisada else 100,
        "vh": 100,
        "nota": nota,
        "generado": "tools/draw_banco_laminas.py",
        "formas": DIBUXOS[clave](),
    }


def escribir(notas=None):
    notas = notas or {}
    for clave in DIBUXOS:
        doc = lamina(clave, notas.get(clave, ""))
        (DESTINO / f"{clave}.json").write_text(
            json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    return len(DIBUXOS)


if __name__ == "__main__":
    print(f"OK: {escribir()} láminas dibujadas.")
