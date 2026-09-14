#!/usr/bin/env python3
"""Dibuja las treinta láminas del cuento: diez unidades por tres páginas.

Por qué un generador y no treinta ficheros a mano. Las láminas del vocabulario
son OBJETOS: una manzana, un barco, una concha. Cada una se dibuja una vez y se
acabó. Las del cuento son ESCENAS, y en las treinta aparece la misma gata. Escrita
a mano, Lúa saldría treinta veces distinta —otro hocico, otro marrón, otras
orejas—, que es justo lo que la regla 5 del CLAUDE.md prohíbe: un set propio es
un set coherente. Aquí la gata se describe UNA vez y se coloca, se escala y se
gira; lo que cambia entre escenas es la pose, no el personaje.

Lo que sale de aquí sigue siendo el mismo formato de datos plano que lee
`lib/core/brand/lamina_vector.dart`: coordenadas absolutas, sin grupos ni
transformaciones. La transformación ocurre AQUÍ, al escribir, no en el aparato.
Quien quiera corregir una escena puede editar el JSON a mano sin este script; si
lo vuelve a ejecutar, se pierde. Por eso cada fichero lleva `generado`.

    python3 tools/draw_contos.py

Las comprueba `tools/check_laminas.py`, que es quien dice si una forma no se
pinta o se sale del lienzo.
"""

from __future__ import annotations

import json
import math
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DESTINO = ROOT / "assets" / "brand" / "laminas"

# Apaisado. Una escena no cabe en un cuadrado sin encogerse hasta no
# distinguirse, y a los dieciocho meses lo que no se distingue no se nombra.
ANCHO, ALTO = 160, 100

# La paleta es la de las láminas del vocabulario, sin colores nuevos: el cuento
# y las palabras tienen que parecer el mismo libro.
PELO = "#8b5a2b"
PERFIL = "#4a2c11"
CREMA = "#fcedc7"
ROSA = "#f472b6"
OLLO = "#1b7a2b"
NEGRO = "#181a20"
BRILLO = "#ffffff55"

CEO = "#a5f3fc"
CEO_GRIS = "#c5ccd6"
CEO_NOITE = "#143a7a"
HERBA = "#2ecc40"
VERDE_ESCURO = "#1b7a2b"
AREA = "#fcedc7"
MAR = "#2f6fd0"
AUGA = "#00c4be"
PARED = "#fcedc7"
CHAN_MADEIRA = "#c89666"
MADEIRA = "#5a3a12"
VERMELLO = "#e62828"
VERMELLO_ESCURO = "#911212"
LARANXA = "#ff851b"
TERRACOTA = "#c2410c"
AMARELO = "#ffdc00"
BRANCO = "#ffffff"
LOUSA = "#334155"
# La piel de las criaturas de la clase: un solo tono, sin escala de pieles. Una
# figura que representa a cualquiera, no a alguien.
FACE = "#fca070"
AZUL_ESCURO = "#1e3a8a"


# ---------------------------------------------------------------- primitivas

def elipse(cx, cy, rx, ry, f=None, s=None, sw=None):
    d = {"t": "elipse", "cx": cx, "cy": cy, "rx": rx, "ry": ry}
    return _pintar(d, f, s, sw)


def rrect(x, y, w, h, r=0, f=None, s=None, sw=None):
    d = {"t": "rrect", "x": x, "y": y, "w": w, "h": h, "r": r}
    return _pintar(d, f, s, sw)


def poli(puntos, f=None, s=None, sw=None):
    d = {"t": "poli", "p": [list(p) for p in puntos]}
    return _pintar(d, f, s, sw)


def ruta(d_, f=None, s=None, sw=None):
    d = {"t": "ruta", "d": d_}
    return _pintar(d, f, s, sw)


def _pintar(d, f, s, sw):
    if f is not None:
        d["f"] = f
    if s is not None:
        d["s"] = s
        d["sw"] = sw if sw is not None else 3
    return d


# ------------------------------------------------------- transformar y pegar

_TOKEN = re.compile(r"[MLQCZmlqcz]|-?\d*\.?\d+")


def _n(v):
    v = round(float(v), 2)
    return int(v) if v == int(v) else v


def _punto(x, y, e, dx, dy, espello):
    if espello:
        x = -x
    return _n(x * e + dx), _n(y * e + dy)


def _ruta_transformada(d, e, dx, dy, espello):
    fuera, buf = [], []

    def volcar():
        while len(buf) >= 2:
            x, y = float(buf.pop(0)), float(buf.pop(0))
            X, Y = _punto(x, y, e, dx, dy, espello)
            fuera.append(str(X))
            fuera.append(str(Y))

    for pieza in _TOKEN.findall(d):
        if pieza.isalpha():
            volcar()
            fuera.append(pieza.upper())
        else:
            buf.append(pieza)
    volcar()
    return " ".join(fuera)


def poner(formas, e=1.0, dx=0.0, dy=0.0, espello=False):
    """Coloca un grupo de formas: escala, desplaza y, si se pide, lo refleja.

    El reflejo es lo que permite que Lúa mire a la derecha en una página y a la
    izquierda en la siguiente sin dibujarla dos veces.
    """
    salida = []
    for f in formas:
        g = dict(f)
        t = g["t"]
        if t == "elipse":
            g["cx"], g["cy"] = _punto(f["cx"], f["cy"], e, dx, dy, espello)
            g["rx"], g["ry"] = _n(f["rx"] * e), _n(f["ry"] * e)
        elif t == "rrect":
            x0 = -(f["x"] + f["w"]) if espello else f["x"]
            g["x"], g["y"] = _punto(x0, f["y"], e, dx, dy, False)
            g["w"], g["h"] = _n(f["w"] * e), _n(f["h"] * e)
            g["r"] = _n(f.get("r", 0) * e)
        elif t == "poli":
            g["p"] = [list(_punto(px, py, e, dx, dy, espello)) for px, py in f["p"]]
        elif t == "ruta":
            g["d"] = _ruta_transformada(f["d"], e, dx, dy, espello)
        if "sw" in f:
            g["sw"] = _n(max(f["sw"] * e, 0.6))
        salida.append(g)
    return salida


# ------------------------------------------------------------------ la gata

def _membro(x0, y0, ang, longo, grosor=8):
    """Un brazo o una pata: trazo oscuro debajo, pelo encima.

    `ang` en grados desde la vertical hacia abajo; positivo hacia la derecha.
    Devuelve las formas y la punta, para colgar de ahí una mano o un pie.
    """
    r = math.radians(ang)
    x1, y1 = x0 + math.sin(r) * longo, y0 + math.cos(r) * longo
    d = f"M{_n(x0)} {_n(y0)} L{_n(x1)} {_n(y1)}"
    return [ruta(d, s=PERFIL, sw=grosor + 4), ruta(d, s=PELO, sw=grosor)], (x1, y1)


def _man(x, y, r=6):
    return [elipse(_n(x), _n(y), r, r, f=CREMA, s=PERFIL, sw=3)]


def _cabeza(ollos="abertos", boca="sorriso", inclinada=0):
    """La cabeza, siempre la misma: orejas, hocico, bigotes y ojos verdes."""
    f = []
    # Orejas, por detrás de la cabeza para que no se vea el corte.
    f += [
        poli([(-25, -50), (-30, -72), (-8, -58)], f=PELO, s=PERFIL, sw=3),
        poli([(25, -50), (30, -72), (8, -58)], f=PELO, s=PERFIL, sw=3),
        poli([(-23, -53), (-26, -66), (-13, -58)], f=ROSA),
        poli([(23, -53), (26, -66), (13, -58)], f=ROSA),
        elipse(0, -38, 26, 23, f=PELO, s=PERFIL, sw=3),
        # Hocico claro: es lo que separa una gata de un oso a esta escala.
        elipse(0, -25, 16, 11, f=CREMA),
    ]
    if ollos == "pechados":
        f += [
            ruta("M-17 -41 Q-11 -35 -5 -41", s=PERFIL, sw=3),
            ruta("M5 -41 Q11 -35 17 -41", s=PERFIL, sw=3),
        ]
    elif ollos == "contentos":
        f += [
            ruta("M-17 -38 Q-11 -45 -5 -38", s=PERFIL, sw=3),
            ruta("M5 -38 Q11 -45 17 -38", s=PERFIL, sw=3),
        ]
    else:
        for sx in (-11, 11):
            f += [
                elipse(sx, -40, 7, 8, f=BRANCO, s=PERFIL, sw=2),
                elipse(sx, -39, 4.5, 6, f=OLLO),
                elipse(sx, -39, 2.2, 4, f=NEGRO),
                elipse(sx - 2, -42, 1.8, 1.8, f=BRANCO),
            ]
    f += [poli([(-5, -29), (5, -29), (0, -23)], f=ROSA, s=VERMELLO_ESCURO, sw=2)]
    if boca == "aberta":
        f += [
            elipse(0, -18, 7, 6, f=VERMELLO_ESCURO),
            elipse(0, -16, 4, 3, f=ROSA),
        ]
    else:
        f += [ruta("M0 -23 C0 -18 -6 -16 -10 -19 M0 -23 C0 -18 6 -16 10 -19",
                   s=PERFIL, sw=3)]
    f += [ruta("M-14 -26 L-32 -30 M-14 -21 L-33 -19 "
               "M14 -26 L32 -30 M14 -21 L33 -19", s=PERFIL, sw=2.5)]
    f += [elipse(-13, -50, 8, 5, f=BRILLO)]
    if inclinada:
        # Inclinar de verdad pediría rotación; basta con desplazar la cabeza,
        # que a este tamaño se lee igual y no deforma el contorno.
        f = poner(f, dx=inclinada, dy=abs(inclinada) * 0.15)
    return f


def _cola(estilo="curva"):
    trazos = {
        "curva": "M18 20 C44 24 52 2 40 -6",
        "alta": "M18 18 C40 16 44 -14 34 -26",
        "baixa": "M18 26 C40 34 48 26 46 14",
    }
    d = trazos.get(estilo, trazos["curva"])
    return [ruta(d, s=PERFIL, sw=13), ruta(d, s=PELO, sw=8)]


def lua(pose="sentada", ollos="abertos", boca="sorriso", cola="curva",
        brazo_e=18, brazo_d=-18, longo_brazo=32, cabeza=0, mans=True,
        disfraz=None):
    """Lúa entera, en coordenadas locales: alto ~140, ancho ~90, centro en (0,0).

    Las poses son las que pide el cuento, no un catálogo: sentada en la
    asamblea, de pie, en salto y enroscada para dormir.

    Los brazos salen del BORDE del tronco y son largos. La primera versión los
    colgaba del centro y medían menos que el radio del cuerpo: en las treinta
    escenas quedaban dentro de la gata, y «abre os brazos coma ás», «estira os
    brazos arriba» y «achega a man» se dibujaban exactamente igual. Un brazo que
    no asoma no cuenta nada.
    """
    if pose == "durmida":
        f = _cola("baixa")
        f += [
            elipse(0, 8, 40, 26, f=PELO, s=PERFIL, sw=3),
            elipse(4, 16, 26, 14, f=CREMA),
        ]
        f += poner(_cabeza(ollos="pechados", boca="sorriso"), e=0.72, dx=-24, dy=34)
        return f

    f = _cola(cola)
    # Tronco: la panza clara repite el hocico, que es lo que hace que se lea
    # como el mismo bicho de cerca y de lejos.
    f += [
        elipse(0, 10, 20, 29, f=PELO, s=PERFIL, sw=3),
        elipse(0, 16, 11, 19, f=CREMA),
    ]
    # El signo: POSITIVO es hacia fuera, hacia el lado del hombro del que
    # cuelga. Escrito como ángulo absoluto, los dos brazos apuntaban hacia el
    # centro y quedaban cruzados sobre la panza en las treinta escenas.
    for ang, lado in ((-brazo_e, -1), (-brazo_d, 1)):
        trazos, punta = _membro(19 * lado, -2, ang, longo_brazo)
        f += trazos
        if mans:
            f += _man(*punta)
    if pose == "sentada":
        f += [
            elipse(-13, 40, 12, 8, f=CREMA, s=PERFIL, sw=3),
            elipse(13, 40, 12, 8, f=CREMA, s=PERFIL, sw=3),
        ]
    elif pose == "de_pe":
        for lado in (-1, 1):
            trazos, punta = _membro(10 * lado, 28, 4 * lado, 20, grosor=9)
            f += trazos
            f += [elipse(_n(punta[0] + 3 * lado), _n(punta[1] + 1), 9, 6,
                         f=CREMA, s=PERFIL, sw=3)]
    elif pose == "salto":
        for lado, ang in ((-1, -52), (1, 52)):
            trazos, punta = _membro(10 * lado, 26, ang, 24, grosor=9)
            f += trazos
            f += [elipse(_n(punta[0]), _n(punta[1]), 9, 6, f=CREMA, s=PERFIL, sw=3)]
    if disfraz == "alas":
        # Después de los brazos, y más anchas que ellos: puestas antes, el brazo
        # se pintaba encima y de la página del vuelo no quedaba ni un ala.
        for lado in (-1, 1):
            f += [ruta(f"M{16 * lado} -10 C{62 * lado} -40 {88 * lado} 6 "
                       f"{26 * lado} 26 Z", f="#a5f3fc", s=LOUSA, sw=3.5),
                  # Las plumas: tres trazos, que es lo que separa un ala de una
                  # mancha azul con forma de gota.
                  ruta(f"M{26 * lado} 8 C{46 * lado} -4 {62 * lado} -6 "
                       f"{70 * lado} 0", s=LOUSA, sw=2.5),
                  ruta(f"M{24 * lado} 16 C{44 * lado} 6 {60 * lado} 6 "
                       f"{70 * lado} 10", s=LOUSA, sw=2.5)]
    if disfraz == "ra":
        # Las patas verdes se pintan ENCIMA de las de la gata: es un disfraz.
        for lado in (-1, 1):
            f += [ruta(f"M{10 * lado} 26 L{24 * lado} 46", s="#84cc16", sw=11),
                  elipse(_n(27 * lado), 48, 12, 6, f="#84cc16", s=VERDE_ESCURO,
                         sw=2.5)]
    f += poner(_cabeza(ollos=ollos, boca=boca, inclinada=cabeza), dy=-5)
    return f


# ------------------------------------------------------------- decorados

def ceo(color=CEO):
    return [rrect(0, 0, ANCHO, ALTO, 0, f=color)]


def chan(y, color=HERBA, borde=None):
    d = f"M0 {y} C40 {y - 4} 120 {y + 4} {ANCHO} {y - 2} L{ANCHO} {ALTO} L0 {ALTO} Z"
    formas = [ruta(d, f=color)]
    if borde:
        formas.append(ruta(f"M0 {y} C40 {y - 4} 120 {y + 4} {ANCHO} {y - 2}",
                           s=borde, sw=3))
    return formas


def interior(alto_parede=62):
    """Un aula: pared clara, suelo de madera y su junta."""
    return [
        rrect(0, 0, ANCHO, ALTO, 0, f=PARED),
        rrect(0, alto_parede, ANCHO, ALTO - alto_parede, 0, f=CHAN_MADEIRA),
        ruta(f"M0 {alto_parede} L{ANCHO} {alto_parede}", s=MADEIRA, sw=3),
    ]


def alfombra(cx, cy, rx=52, ry=13, color=MAR):
    return [
        elipse(cx, cy, rx, ry, f=color, s=AZUL_ESCURO, sw=3),
        elipse(cx, cy, rx - 9, ry - 4, s=BRANCO, sw=2),
    ]


def sol(cx, cy, r=13, color=AMARELO):
    f = [elipse(cx, cy, r, r, f=color, s=TERRACOTA, sw=3)]
    for i in range(8):
        a = math.radians(i * 45)
        x0, y0 = cx + math.cos(a) * (r + 4), cy + math.sin(a) * (r + 4)
        x1, y1 = cx + math.cos(a) * (r + 11), cy + math.sin(a) * (r + 11)
        f.append(ruta(f"M{_n(x0)} {_n(y0)} L{_n(x1)} {_n(y1)}", s=TERRACOTA, sw=3))
    return f


def nube(cx, cy, e=1.0, color=BRANCO):
    return poner([
        elipse(-14, 0, 14, 10, f=color),
        elipse(2, -5, 17, 13, f=color),
        elipse(16, 1, 13, 9, f=color),
        rrect(-14, -2, 30, 12, 6, f=color),
    ], e=e, dx=cx, dy=cy)


def arbore(cx, base, e=1.0, follas=VERDE_ESCURO, follas2=None):
    """`base` es donde el tronco TOCA el suelo, no el centro del árbol.

    Se escribió al revés la primera vez y el tronco bajaba siete unidades por
    debajo del borde: en pantalla se corta, y quien lo mira no sabe si el árbol
    está mal dibujado o el recorte está mal puesto. Lo cazó check_laminas.py.
    """
    f = [
        rrect(-6, -46, 12, 46, 3, f=MADEIRA),
        elipse(-14, -56, 18, 15, f=follas),
        elipse(14, -56, 17, 14, f=follas2 or follas),
        elipse(0, -70, 21, 17, f=follas),
    ]
    return poner(f, e=e, dx=cx, dy=base)


def pingas(xs, y0, longo=9, color=MAR, sw=3):
    return [ruta(f"M{x} {y0 + (i % 3) * 5} L{x - 2} {y0 + (i % 3) * 5 + longo}",
                 s=color, sw=sw) for i, x in enumerate(xs)]


def folla(cx, cy, e=1.0, color=LARANXA, borde=TERRACOTA):
    return poner([
        ruta("M0 -10 C10 -6 10 6 0 10 C-10 6 -10 -6 0 -10 Z", f=color, s=borde, sw=2),
        ruta("M0 -9 L0 9", s=borde, sw=2),
    ], e=e, dx=cx, dy=cy)


def frecha_movemento(d, color=LOUSA, sw=3):
    """El rastro que dice que algo se mueve. En una lámina fija es la única
    manera de contar 'salta', 'rola' o 'cae' sin escribirlo."""
    return [ruta(d, s=color, sw=sw)]


# --------------------------------------------- reutilizar las del vocabulario

_CACHE: dict[str, list] = {}


def objeto(clave, cx, cy, alto=40, espello=False):
    """Trae una lámina del vocabulario y la coloca dentro de la escena.

    Esto no es ahorro de trabajo: es lo que hace que la manzana del cuento y la
    manzana de la tarjeta de vocabulario sean LA MISMA manzana. A los dos años
    el reconocimiento se apoya en eso; dos dibujos distintos de la misma palabra
    son dos palabras.
    """
    if clave not in _CACHE:
        ruta_ = DESTINO / f"{clave}.json"
        _CACHE[clave] = json.loads(ruta_.read_text(encoding="utf-8"))["formas"]
    e = alto / 100.0
    return poner(_CACHE[clave], e=e, dx=cx - 50 * e, dy=cy - 50 * e,
                 espello=espello)


# ------------------------------------------------------------- una criatura

def crianza(x, chan_y, alto=54, pel="#4a2c11", roupa="#5a208a",
            brazo_e=25, brazo_d=-45, espello=False):
    """Una criatura de la clase. Sin rasgos que la identifiquen con nadie: es
    una figura, no un retrato. La app no guarda ni enseña datos de ninguna."""
    e = alto / 100.0
    f = [
        # Piernas y zapatos
        ruta("M-12 40 L-12 76", s=LOUSA, sw=11),
        ruta("M12 40 L12 76", s=LOUSA, sw=11),
        elipse(-14, 80, 11, 7, f=PERFIL),
        elipse(14, 80, 11, 7, f=PERFIL),
        # Cuerpo
        ruta("M-20 4 L20 4 L25 46 L-25 46 Z", f=roupa, s=PERFIL, sw=3),
    ]
    for ang, lado in ((brazo_e, -1), (brazo_d, 1)):
        r = math.radians(ang)
        x0, y0 = 19 * lado, 10
        x1, y1 = x0 + math.sin(r) * 30, y0 + math.cos(r) * 30
        d = f"M{_n(x0)} {_n(y0)} L{_n(x1)} {_n(y1)}"
        f += [ruta(d, s=PERFIL, sw=11), ruta(d, s=roupa, sw=7),
              elipse(_n(x1), _n(y1), 7, 7, f=FACE, s=PERFIL, sw=2.5)]
    f += [
        elipse(0, -22, 24, 24, f=FACE, s=PERFIL, sw=3),
        ruta("M-24 -28 C-20 -52 20 -52 24 -28 C18 -40 -18 -40 -24 -28 Z", f=pel),
        elipse(-9, -22, 3.2, 4, f=NEGRO),
        elipse(9, -22, 3.2, 4, f=NEGRO),
        ruta("M-7 -12 C-3 -7 3 -7 7 -12", s=PERFIL, sw=3),
        elipse(-15, -14, 5, 3.5, f="#f472b6aa"),
        elipse(15, -14, 5, 3.5, f="#f472b6aa"),
    ]
    return poner(f, e=e, dx=x, dy=chan_y - 87 * e, espello=espello)


# ---------------------------------------------------------------- colocar a Lúa

# Dónde queda la planta del pie en coordenadas locales, por pose. Sin esto, Lúa
# flota o se hunde en el suelo según la pose, que es el defecto que delata un
# decorado montado a ojo.
_CHAN_LOCAL = {"sentada": 48, "de_pe": 55, "salto": 52, "durmida": 34}


def lua_en(x, chan_y, alto=70, espello=False, pose="sentada", **kw):
    formas = lua(pose=pose, **kw)
    # La gata local mide 132 de alto, de la punta de la oreja a la planta.
    e = alto / 132.0
    return poner(formas, e=e, dx=x, dy=chan_y - _CHAN_LOCAL[pose] * e,
                 espello=espello)


# =============================================================== as escenas
#
# Una por página. El orden manda: primero el fondo, luego lo que está lejos,
# luego Lúa, y al final lo que la tapa. Cada escena dice lo que cuenta SU
# página, no el resumen del cuento: si la página dice que salta, salta.


def benvida_1():
    f = interior(58)
    f += [
        # Percheiro de la entrada
        rrect(20, 26, 120, 7, 3, f=MADEIRA),
        rrect(34, 33, 6, 9, 3, f=MADEIRA),
        rrect(90, 33, 6, 9, 3, f=MADEIRA),
        rrect(126, 33, 6, 9, 3, f=MADEIRA),
        # La foto de casa, en su marco
        rrect(112, 44, 26, 22, 3, f=BRANCO, s=MADEIRA, sw=3),
        ruta("M116 62 L124 50 L131 62 Z", f=VERDE_ESCURO),
        elipse(131, 51, 4, 4, f=AMARELO),
    ]
    f += objeto("mochila", 93, 56, alto=38)
    f += objeto("zapato", 26, 84, alto=34)
    f += lua_en(58, 88, alto=66, pose="de_pe", brazo_e=-10, brazo_d=-58,
                ollos="contentos")
    return f, ("Lúa colga a mochila no percheiro da entrada. Debaixo, o zapato "
               "de recambio; na parede, a foto da casa.")


def benvida_2():
    f = interior(56)
    f += alfombra(80, 84, rx=66, ry=15)
    f += crianza(112, 88, alto=56, brazo_e=-78, brazo_d=20, espello=True)
    f += lua_en(44, 86, alto=62, pose="sentada", brazo_e=8, brazo_d=-82,
                ollos="contentos")
    f += [
        # El destello del encuentro, POR DEBAJO de las manos: encima era un aro
        # amarillo tapando exactamente el gesto que cuenta la página.
        elipse(80, 70, 6, 6, f="#ffdc00"),
        elipse(90, 62, 4, 4, f="#ffdc00"),
        elipse(72, 60, 3.5, 3.5, f="#ffdc00"),
    ]
    return f, ("Na alfombra, Lúa achega a man moi a modo e a amiga nova "
               "tócalle os dedos.")


def benvida_3():
    f = interior(56)
    f += [
        # La puerta del aula, por donde se marcha
        rrect(112, 18, 40, 44, 4, f=MADEIRA),
        rrect(117, 23, 30, 34, 3, f=CHAN_MADEIRA),
        elipse(146, 44, 3, 3, f=AMARELO),
    ]
    f += crianza(108, 88, alto=52, brazo_e=18, brazo_d=-120, espello=True)
    f += lua_en(48, 88, alto=64, pose="de_pe", brazo_e=18, brazo_d=-125,
                ollos="contentos")
    f += objeto("mochila", 20, 60, alto=34)
    f += frecha_movemento("M34 22 C40 16 48 16 54 22 M60 22 C66 16 74 16 80 22",
                          color=ROSA, sw=3)
    return f, "Lúa e a amiga din adeus coa man ao rematar a mañá."


def mar_1():
    f = ceo(CEO)
    f += sol(132, 22, 13)
    f += nube(36, 20, e=0.9)
    f += [
        ruta(f"M0 52 L{ANCHO} 52 L{ANCHO} 74 L0 74 Z", f=MAR),
        ruta("M6 60 C16 56 26 64 36 60 M108 62 C118 58 128 66 138 62",
             s=BRILLO, sw=3),
    ]
    f += chan(74, AREA)
    f += lua_en(56, 92, alto=70, pose="sentada", brazo_e=42, brazo_d=-42,
                ollos="contentos")
    f += objeto("barco", 110, 72, alto=42)
    return f, ("Lúa senta na area de Samil co seu barquiño de madeira e mira a "
               "ría de Vigo baixo o sol.")


def mar_2():
    f = ceo(CEO)
    f += nube(120, 18, e=0.8)
    f += [ruta(f"M0 56 L{ANCHO} 56 L{ANCHO} 72 L0 72 Z", f=MAR)]
    f += chan(72, AREA)
    f += objeto("gaivota", 112, 28, alto=44, espello=True)
    f += frecha_movemento("M24 18 C48 10 74 14 92 24", color="#68707e", sw=3)
    f += lua_en(44, 92, alto=68, pose="de_pe", brazo_e=8, brazo_d=-118,
                ollos="abertos", boca="aberta", cabeza=2)
    f += objeto("cuncha", 118, 84, alto=26)
    f += objeto("cuncha", 142, 90, alto=20)
    return f, ("Unha gaivota branca cruza o ceo e Lúa mírana. Na beira hai "
               "cunchas grandes.")


def mar_3():
    f = ceo(CEO)
    f += sol(22, 20, 11)
    f += [ruta(f"M0 54 L{ANCHO} 54 L{ANCHO} 70 L0 70 Z", f=MAR)]
    f += chan(70, AREA)
    f += lua_en(64, 92, alto=74, pose="sentada", brazo_e=6, brazo_d=-146,
                ollos="pechados")
    f += objeto("cuncha", 88, 36, alto=30)
    f += frecha_movemento("M104 30 C114 24 118 30 116 38", color=AUGA, sw=3)
    f += objeto("mexillon", 132, 88, alto=24)
    return f, ("Lúa achega a cuncha á orella e sorrí: dentro está o son das "
               "ondas.")


def follas_1():
    f = ceo(CEO)
    f += nube(30, 16, e=0.7)
    f += [
        # El monte do Castro, que es una cuesta y por eso se sube
        ruta(f"M0 88 C40 54 110 44 {ANCHO} 62 L{ANCHO} {ALTO} L0 {ALTO} Z",
             f=HERBA),
        ruta(f"M0 88 C40 54 110 44 {ANCHO} 62", s=VERDE_ESCURO, sw=3),
    ]
    f += arbore(34, 76, e=0.62, follas=TERRACOTA, follas2=LARANXA)
    f += arbore(124, 62, e=0.5, follas=LARANXA, follas2=TERRACOTA)
    f += folla(72, 34, e=0.9)
    f += folla(96, 24, e=0.7, color=TERRACOTA)
    f += lua_en(82, 76, alto=54, pose="de_pe", brazo_e=32, brazo_d=-24,
                ollos="contentos")
    return f, ("Lúa sobe ao monte do Castro. As árbores están cheas de follas "
               "marróns e laranxas.")


def follas_2():
    f = ceo(CEO_GRIS)
    f += chan(80, HERBA, borde=VERDE_ESCURO)
    f += arbore(24, 84, e=0.72, follas=TERRACOTA, follas2=LARANXA)
    # El viento: tres rachas largas. Es lo único que cuenta esta página.
    f += frecha_movemento("M52 22 C78 12 108 20 136 14", color=BRANCO, sw=4)
    f += frecha_movemento("M60 38 C88 30 116 38 146 32", color=BRANCO, sw=4)
    f += frecha_movemento("M70 54 C94 48 118 54 140 50", color=BRANCO, sw=3)
    f += folla(66, 30, e=0.8)
    f += folla(102, 44, e=0.9, color=TERRACOTA)
    f += folla(128, 62, e=0.7)
    f += folla(88, 66, e=0.6, color=TERRACOTA)
    f += lua_en(112, 92, alto=52, pose="de_pe", brazo_e=48, brazo_d=-48,
                ollos="abertos", boca="aberta")
    return f, ("Sopra o vento forte e as follas caen a modo, dando voltas ata "
               "chegar ao chan.")


def follas_3():
    f = ceo(CEO)
    f += chan(70, HERBA, borde=VERDE_ESCURO)
    # La alfombra de hojas secas que se pisa
    for x, e_, c in ((14, 0.8, TERRACOTA), (40, 0.7, LARANXA), (62, 0.9, TERRACOTA),
                     (136, 0.8, LARANXA), (150, 0.6, TERRACOTA)):
        f += folla(x, 88, e=e_, color=c)
    f += lua_en(66, 88, alto=62, pose="de_pe", brazo_e=26, brazo_d=-26,
                ollos="contentos")
    f += objeto("cesta", 124, 72, alto=44)
    f += folla(120, 54, e=0.6)
    f += folla(134, 52, e=0.5, color=TERRACOTA)
    return f, ("Lúa pisa as follas secas cos catro pés e despois enche a cesta.")


def _fiestra(x, y, w, h, ceo_cor=CEO_GRIS):
    """Una ventana de verdad: marco grueso, cruz y lo que se ve fuera."""
    return [
        rrect(x, y, w, h, 4, f=ceo_cor, s=MADEIRA, sw=5),
        ruta(f"M{x + w / 2} {y} L{x + w / 2} {y + h}", s=MADEIRA, sw=4),
        ruta(f"M{x} {y + h / 2} L{x + w} {y + h / 2}", s=MADEIRA, sw=4),
    ]


def choiva_1():
    f = interior(78)
    f += _fiestra(52, 12, 92, 58)
    f += pingas([62, 74, 86, 98, 110, 122, 134], 18, longo=10)
    f += pingas([68, 80, 92, 104, 116, 128], 40, longo=9)
    f += lua_en(28, 94, alto=64, pose="de_pe", brazo_e=14, brazo_d=-30,
                ollos="abertos", cabeza=3)
    return f, ("Chove en Vigo. Lúa mira pola fiestra e decide saír igual.")


def choiva_2():
    f = interior(72)
    f += lua_en(56, 92, alto=72, pose="de_pe", brazo_e=20, brazo_d=-30,
                ollos="contentos")
    f += objeto("gorro", 56, 18, alto=34)
    f += objeto("abrigo", 118, 44, alto=48)
    f += objeto("botas", 126, 84, alto=34)
    f += frecha_movemento("M92 24 L106 34 M92 44 L106 54 M92 64 L106 74",
                          color=LOUSA, sw=3)
    return f, ("Primeiro o gorro, despois o abrigo coa cremalleira, e ao final "
               "as botas.")


def choiva_3():
    f = ceo(CEO_GRIS)
    f += chan(72, "#68707e")
    f += pingas([10, 26, 42, 58, 120, 138, 152], 10, longo=11)
    f += [
        # El charco, grande, que es lo que se pisa
        elipse(92, 84, 46, 13, f=MAR, s=AZUL_ESCURO, sw=3),
        elipse(92, 82, 30, 7, f=AUGA),
    ]
    # Despegada del charco: con las patas dentro del agua la pose de salto se
    # leía como una gata sentada en un charco.
    f += [elipse(92, 86, 26, 6, f="#1e3a8a55")]
    f += lua_en(90, 72, alto=62, pose="salto", brazo_e=66, brazo_d=-66,
                ollos="contentos", boca="aberta", cola="alta")
    f += frecha_movemento("M40 66 C52 34 118 30 136 58", color=BRANCO, sw=3)
    # El agua que salta hasta los bigotes
    f += frecha_movemento("M52 76 C46 62 42 56 38 48", color=AUGA, sw=4)
    f += frecha_movemento("M132 76 C138 62 142 56 146 48", color=AUGA, sw=4)
    f += [elipse(36, 44, 5, 5, f=AUGA), elipse(148, 44, 5, 5, f=AUGA),
          elipse(120, 56, 4, 4, f=AUGA), elipse(64, 58, 4, 4, f=AUGA)]
    f += objeto("paraugas", 24, 62, alto=46)
    return f, ("Lúa pisa o charco con forza e a auga sáltalle ata os bigotes.")


def inverno_1():
    f = [rrect(0, 0, ANCHO, ALTO, 0, f="#1e3a8a")]
    f += _fiestra(46, 10, 100, 62, ceo_cor=CEO_NOITE)
    # Las luces de la calle: la guirnalda que Vigo enciende en diciembre
    f += [ruta("M52 26 C76 40 116 40 140 26", s="#c5ccd6", sw=2.5)]
    for i, x in enumerate((58, 72, 86, 100, 114, 128)):
        y = (34, 38, 40, 40, 38, 34)[i]
        f += [elipse(x, y, 4.5, 4.5, f=(AMARELO, VERMELLO, "#fff677")[i % 3]),
              elipse(x, y, 8, 8, f="#ffdc0033")]
    f += [rrect(0, 78, ANCHO, ALTO - 78, 0, f=MADEIRA)]
    f += lua_en(30, 94, alto=62, pose="de_pe", brazo_e=10, brazo_d=-24,
                ollos="abertos", cabeza=4)
    f += [elipse(50, 54, 7, 5, f="#a5f3fc88")]  # el vaho del nariz no cristal
    return f, ("Fóra fai frío e as rúas de Vigo están cheas de luces. Lúa pega "
               "o nariz ao cristal.")


def inverno_2():
    f = interior(66)
    f += alfombra(80, 88, rx=62, ry=12, color=VERMELLO_ESCURO)
    f += lua_en(64, 90, alto=68, pose="de_pe", brazo_e=16, brazo_d=-72,
                ollos="contentos", boca="aberta")
    f += objeto("cascabel", 118, 34, alto=36)
    # Las rachas del cascabel: rápido, y por eso se dibujan tres.
    f += frecha_movemento("M104 20 C112 16 122 16 130 20", color=AMARELO, sw=3)
    f += frecha_movemento("M136 28 C142 34 142 44 136 50", color=AMARELO, sw=3)
    f += frecha_movemento("M100 30 C94 36 94 46 100 52", color=AMARELO, sw=3)
    return f, ("Lúa move a pulseira de cascabeis moi rápido: ring, ring, ring!")


def inverno_3():
    f = [rrect(0, 0, ANCHO, ALTO, 0, f="#5a208a")]
    f += [rrect(0, 62, ANCHO, ALTO - 62, 0, f=MADEIRA)]
    f += objeto("luz", 24, 30, alto=42)
    f += lua_en(86, 86, alto=58, pose="durmida", ollos="pechados")
    f += [
        # La manta entra DESPUÉS de la gata, que es lo que hace que tape; pero
        # arranca a la derecha de la cabeza. La primera versión la cubría entera
        # y la página del sueño se quedaba sin nadie durmiendo.
        ruta("M78 90 C84 62 142 60 150 90 Z", f=VERMELLO, s=VERMELLO_ESCURO,
             sw=3),
        ruta("M80 82 C90 72 138 70 146 82", s="#ff6b6b", sw=3),
    ]
    f += frecha_movemento("M112 46 C120 40 116 34 122 28", color=BRANCO, sw=3)
    return f, ("Debaixo da manta suave, Lúa está quente e pecha os ollos.")


def animais_1():
    f = interior(64)
    f += alfombra(80, 88, rx=64, ry=12, color=MAR)
    f += objeto("ra", 128, 74, alto=40)
    f += lua_en(58, 80, alto=64, pose="salto", brazo_e=62, brazo_d=-62,
                ollos="contentos", boca="aberta", cola="alta", disfraz="ra")
    # El arco del salto: sin él, una gata con las patas abiertas está quieta.
    f += frecha_movemento("M20 84 C32 46 84 46 96 78", color="#84cc16", sw=3)
    return f, ("É Entroido: Lúa ponse unhas patas verdes e salta polo chan como "
               "unha ra.")


def animais_2():
    f = interior(64)
    f += alfombra(80, 90, rx=62, ry=11)
    f += objeto("paxaro", 28, 26, alto=36)
    f += lua_en(80, 84, alto=60, pose="de_pe", brazo_e=96, brazo_d=-96,
                longo_brazo=26, ollos="contentos", cola="alta", mans=False,
                disfraz="alas")
    f += frecha_movemento("M44 20 C74 8 112 12 140 26", color="#68707e", sw=3)
    return f, ("Lúa abre os brazos coma ás e voa de puntillas arredor da "
               "alfombra.")


def animais_3():
    f = interior(64)
    f += alfombra(80, 90, rx=62, ry=11, color=TERRACOTA)
    f += objeto("oso", 126, 62, alto=56)
    f += lua_en(52, 88, alto=66, pose="de_pe", brazo_e=44, brazo_d=-44,
                ollos="abertos", boca="aberta")
    # Las pisadas pesadas, que es lo que suena: pum, pum.
    for x in (16, 34):
        f += [elipse(x, 93, 9, 6.5, f="#5a3a12"),
              elipse(x - 5, 85, 3, 3, f="#5a3a12"),
              elipse(x + 4, 84, 3, 3, f="#5a3a12")]
    return f, ("Lúa pisa pesado coma un oso: pum, pum. Despois volve ser gata.")


def corpo_1():
    f = interior(70)
    f += alfombra(80, 92, rx=60, ry=10)
    f += lua_en(74, 92, alto=74, pose="de_pe", brazo_e=24, brazo_d=-24,
                ollos="abertos", cabeza=-4)
    # Las flechas de un lado al otro: la cabeza se mueve, no está torcida.
    f += frecha_movemento("M28 26 C36 16 44 14 52 16 M28 26 L34 20 M28 26 L36 30",
                          color=MAR, sw=3)
    f += frecha_movemento("M132 26 C124 16 116 14 108 16 M132 26 L126 20 "
                          "M132 26 L124 30", color=MAR, sw=3)
    for cx, clave in ((22, "ollos"), (138, "nariz")):
        f += [rrect(cx - 20, 48, 40, 40, 6, f=BRANCO, s=MAR, sw=3)]
        f += objeto(clave, cx, 68, alto=32)
    return f, ("Lúa move a cabeza dun lado ao outro, despois os ollos e "
               "despois o nariz.")


def corpo_2():
    f = interior(70)
    f += alfombra(80, 92, rx=60, ry=10)
    f += lua_en(72, 92, alto=76, pose="de_pe", brazo_e=-52, brazo_d=52,
                longo_brazo=23, ollos="contentos", boca="aberta")
    f += [elipse(72, 74, 15, 12, f="#ffdc0033", s=AMARELO, sw=3)]
    f += objeto("barriga", 22, 40, alto=34)
    f += objeto("pes", 136, 76, alto=34)
    f += frecha_movemento("M120 60 C126 54 132 54 136 58", color=ROSA, sw=3)
    return f, ("Lúa baixa as mans á barriga e faise cóxegas; despois chega aos "
               "pés e move os dedos.")


def corpo_3():
    f = interior(70)
    f += [
        # Una peana: una estatua se queda quieta ENCIMA de algo.
        rrect(44, 86, 72, 12, 3, f="#c5ccd6", s=LOUSA, sw=3),
    ]
    f += lua_en(80, 86, alto=70, pose="de_pe", brazo_e=88, brazo_d=-88,
                longo_brazo=28, ollos="abertos", boca="aberta", cola="alta")
    # El movimiento que SE PARA: el arco viene y choca contra una barra. Dos
    # rayas quietas no decían nada; un tope sí, porque se ve de dónde venía.
    f += frecha_movemento("M10 34 C20 24 30 24 38 32", color=LARANXA, sw=3)
    f += frecha_movemento("M150 34 C140 24 130 24 122 32", color=LARANXA, sw=3)
    f += [ruta("M42 22 L42 44", s=VERMELLO, sw=5),
          ruta("M118 22 L118 44", s=VERMELLO, sw=5)]
    return f, ("Alguén di a palabra máxica e Lúa queda quieta coma unha "
               "estatua.")


def auga_1():
    f = ceo(CEO)
    f += chan(72, AREA)
    f += [
        # El arenero del parque, de donde vienen las patas así
        ruta(f"M0 72 C30 66 60 78 96 72", s="#c89666", sw=3),
    ]
    f += arbore(136, 76, e=0.6)
    f += lua_en(58, 92, alto=70, pose="de_pe", brazo_e=34, brazo_d=-34,
                ollos="abertos", boca="sorriso")
    # Las manchas de tierra: van al final, encima de las patas.
    for x, y, r in ((38, 88, 7), (50, 93, 5.5), (70, 89, 7), (80, 94, 5),
                    (58, 82, 4.5), (44, 80, 4)):
        f += [elipse(x, y, r, r * 0.8, f="#5a3a12")]
    return f, ("Lúa volve do parque coas patas cheas de terra e area.")


def auga_2():
    f = interior(74)
    f += [
        # El lavabo, con su encimera
        rrect(78, 52, 76, 10, 3, f="#c5ccd6", s=LOUSA, sw=3),
        ruta("M84 62 C86 82 142 82 146 62 Z", f=BRANCO, s=LOUSA, sw=3),
    ]
    f += objeto("billa", 112, 34, alto=38)
    f += [ruta("M112 44 C112 56 110 62 110 70", s=AUGA, sw=6)]
    f += objeto("xabon", 62, 40, alto=32)
    f += objeto("espuma", 44, 74, alto=36)
    f += lua_en(32, 94, alto=64, pose="de_pe", brazo_e=-46, brazo_d=58,
                longo_brazo=24, ollos="contentos", boca="aberta")
    return f, ("Abre a billa, sae auga morna e Lúa frega co xabón ata que "
               "aparece a espuma.")


def auga_3():
    f = interior(74)
    f += [ruta("M84 58 C86 80 142 80 146 58 Z", f=BRANCO, s=LOUSA, sw=3)]
    f += objeto("toalla", 26, 40, alto=44)
    f += lua_en(62, 94, alto=66, pose="de_pe", brazo_e=-44, brazo_d=54,
                longo_brazo=24, ollos="contentos", boca="aberta")
    # El splash: gotas que salen, no una mancha.
    for x, y, r in ((96, 30, 5), (110, 22, 4), (124, 30, 5), (136, 42, 4),
                    (88, 44, 3.5), (146, 56, 3)):
        f += [elipse(x, y, r, r, f=AUGA)]
    f += frecha_movemento("M96 46 C104 34 118 30 130 38", color=AUGA, sw=3)
    f += [elipse(52, 62, 7, 5, f=BRILLO), elipse(80, 60, 6, 4, f=BRILLO)]
    return f, ("Splash! A auga lévao todo e as patas quedan limpas e "
               "brillantes.")


def primavera_1():
    f = interior(80)
    f += _fiestra(50, 10, 96, 62, ceo_cor=CEO_GRIS)
    f += pingas([60, 72, 84, 96, 108, 120, 132], 16, longo=7, sw=2.5)
    f += pingas([66, 78, 90, 102, 114, 126], 38, longo=7, sw=2.5)
    f += [
        # LA pinga, la que se sigue con el dedo. Más gorda que la lluvia de
        # detrás, porque esta página va de una sola gota.
        ruta("M98 22 C98 34 98 46 98 58", s=MAR, sw=4),
        elipse(98, 60, 5, 6, f=MAR),
    ]
    f += lua_en(30, 94, alto=62, pose="de_pe", brazo_e=10, brazo_d=-74,
                ollos="abertos", cabeza=3)
    return f, ("Chove moi miúdo. Lúa pousa un dedo no cristal e segue unha "
               "pinga que baixa: tap, tap, tap.")


def primavera_2():
    f = interior(72)
    f += [
        # La maceta en corte: la semilla está DEBAJO, y esta página va justo de
        # lo que no se ve.
        ruta("M62 52 L118 52 L110 92 L70 92 Z", f=TERRACOTA, s="#911212", sw=3),
        ruta("M64 60 L116 60 L110 92 L70 92 Z", f="#5a3a12"),
        ruta("M64 60 L116 60", s="#4a2c11", sw=3),
    ]
    f += objeto("semente", 90, 76, alto=26)
    f += frecha_movemento("M90 70 C90 64 90 60 90 56", color="#84cc16", sw=3)
    f += lua_en(28, 94, alto=58, pose="sentada", brazo_e=30, brazo_d=-42,
                ollos="abertos", cabeza=3)
    f += [elipse(138, 42, 12, 12, f="#ffdc0033", s=AMARELO, sw=2.5)]
    return f, ("Na maceta hai unha semente durmida debaixo da terra: aínda non "
               "se ve, pero medra.")


def primavera_3():
    f = ceo(CEO)
    f += sol(134, 20, 14)
    f += chan(76, HERBA, borde=VERDE_ESCURO)
    f += objeto("flor", 116, 58, alto=56)
    f += lua_en(56, 94, alto=72, pose="de_pe", brazo_e=152, brazo_d=-152,
                longo_brazo=26, ollos="contentos", boca="aberta", cola="alta")
    f += frecha_movemento("M30 34 L24 26 M80 34 L86 26", color=AMARELO, sw=3)
    return f, ("Sae o sol, a planta abre os pétalos e Lúa estira os brazos ben "
               "arriba.")


def cores_1():
    f = ceo(CEO)
    f += sol(24, 18, 11)
    f += [
        # La plaza: losas, no hierba. Es la praza da Princesa.
        rrect(0, 74, ANCHO, ALTO - 74, 0, f="#c5ccd6"),
        ruta(f"M0 74 L{ANCHO} 74", s="#68707e", sw=3),
        ruta("M30 74 L30 100 M70 74 L70 100 M110 74 L110 100 "
             "M0 88 L160 88", s="#68707e", sw=2),
        # El banco
        rrect(96, 56, 54, 8, 3, f=MADEIRA),
        rrect(100, 64, 6, 14, 2, f=MADEIRA),
        rrect(140, 64, 6, 14, 2, f=MADEIRA),
    ]
    f += lua_en(52, 92, alto=72, pose="sentada", brazo_e=34, brazo_d=-56,
                ollos="contentos", boca="aberta")
    f += objeto("mazan", 84, 58, alto=30)
    return f, ("Lúa senta na praza da Princesa cun anaco de mazá vermella.")


def cores_2():
    f = ceo(CEO)
    f += [
        rrect(0, 72, ANCHO, ALTO - 72, 0, f="#c5ccd6"),
        ruta(f"M0 72 L{ANCHO} 72", s="#68707e", sw=3),
    ]
    f += lua_en(34, 92, alto=66, pose="de_pe", brazo_e=14, brazo_d=-66,
                ollos="contentos")
    f += objeto("laranxa", 122, 76, alto=38)
    # Rueda: el rastro y las estelas. Sin esto es una naranja parada.
    f += frecha_movemento("M64 82 C82 70 104 70 118 78", color=LARANXA, sw=3)
    f += frecha_movemento("M84 58 C90 54 98 54 104 58", color=LARANXA, sw=2.5)
    f += [elipse(70, 84, 3, 3, f=LARANXA), elipse(88, 80, 3, 3, f=LARANXA)]
    return f, ("Lúa dálle un toque á laranxa redonda e a laranxa rola, rola e "
               "rola.")


def cores_3():
    f = ceo(CEO)
    f += sol(132, 22, 14)
    f += chan(76, HERBA, borde=VERDE_ESCURO)
    f += objeto("aro", 34, 56, alto=46)
    f += objeto("amarelo", 100, 82, alto=30)
    f += lua_en(72, 94, alto=66, pose="de_pe", brazo_e=10, brazo_d=-148,
                ollos="abertos", boca="sorriso")
    return f, ("Lúa busca todo o que sexa amarelo: un aro, unha flor e o sol "
               "que quenta a praza.")


ESCENAS = {
    "conto_benvida_1": benvida_1, "conto_benvida_2": benvida_2,
    "conto_benvida_3": benvida_3,
    "conto_mar_1": mar_1, "conto_mar_2": mar_2, "conto_mar_3": mar_3,
    "conto_follas_1": follas_1, "conto_follas_2": follas_2,
    "conto_follas_3": follas_3,
    "conto_choiva_1": choiva_1, "conto_choiva_2": choiva_2,
    "conto_choiva_3": choiva_3,
    "conto_inverno_1": inverno_1, "conto_inverno_2": inverno_2,
    "conto_inverno_3": inverno_3,
    "conto_animais_1": animais_1, "conto_animais_2": animais_2,
    "conto_animais_3": animais_3,
    "conto_corpo_1": corpo_1, "conto_corpo_2": corpo_2, "conto_corpo_3": corpo_3,
    "conto_auga_1": auga_1, "conto_auga_2": auga_2, "conto_auga_3": auga_3,
    "conto_primavera_1": primavera_1, "conto_primavera_2": primavera_2,
    "conto_primavera_3": primavera_3,
    "conto_cores_1": cores_1, "conto_cores_2": cores_2, "conto_cores_3": cores_3,
}


def main() -> int:
    for clave, fabrica in sorted(ESCENAS.items()):
        formas, nota = fabrica()
        doc = {
            "vb": ANCHO,
            "vh": ALTO,
            "nota": nota,
            "generado": "tools/draw_contos.py",
            "formas": formas,
        }
        destino = DESTINO / f"{clave}.json"
        destino.write_text(
            json.dumps(doc, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
    print(f"OK: {len(ESCENAS)} láminas de conto escritas en "
          f"{DESTINO.relative_to(ROOT)}/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
