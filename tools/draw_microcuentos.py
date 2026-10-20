#!/usr/bin/env python3
"""Dibuja las láminas de los microcuentos (M5.6).

    python3 tools/draw_microcuentos.py

El microcuento pide una lámina LIMPIA por escena: una acción, un contraste y
nada de fondo que compita (`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartado 5).
Cada lámina sale del `encargo` que su microcuento trae escrito en la unidad.

Lúa, la paleta y las primitivas son las de `tools/draw_contos.py`: la gata se
describe allí UNA vez y aquí solo se coloca, para que la del microcuento y la
del cuento de la semana sean la misma gata. Lo que sale es el mismo formato
plano que lee `lib/core/brand/lamina_vector.dart`, y lo comprueba
`tools/check_laminas.py`.

Antes de la primera tanda, Frank aprueba el estilo con tres láminas de muestra
(regla 5 del CLAUDE.md: activos propios). Las tres de muestra son las del
microcuento de 2-3 años de junio, «Lúa e o peixiño azul».
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from draw_contos import (  # noqa: E402
    ALTO, ANCHO, AZUL_ESCURO, BRANCO, CEO, CEO_GRIS, DESTINO, LOUSA, MAR,
    NEGRO, VERDE_ESCURO, elipse, frecha_movemento, lua, poner, ruta,
    _CHAN_LOCAL,
)

ROOT = Path(__file__).resolve().parent.parent

# El mar de dentro: más oscuro que el de la superficie para que el pez claro y
# Lúa destaquen. Es el azul escuro de la paleta, no un color nuevo.
FONDO_MAR = MAR
BURBULLA = "#a5f3fc"


def lua_flotando(x, y, alto=60, gafas=True, **kw):
    """Lúa nadando: de pie, sin suelo, con las gafas de bucear puestas."""
    formas = lua(pose="de_pe", **kw)
    if gafas:
        # Sobre los ojos (en local, centrados en ±11, -45 tras subir la cabeza).
        formas += [
            ruta("M-26 -46 C-26 -62 26 -62 26 -46", s=LOUSA, sw=3),
            elipse(-11, -45, 10, 9, f="#a5f3fc88", s=LOUSA, sw=3),
            elipse(11, -45, 10, 9, f="#a5f3fc88", s=LOUSA, sw=3),
            ruta("M-1 -45 L1 -45", s=LOUSA, sw=3),
        ]
    e = alto / 132.0
    return poner(formas, e=e, dx=x, dy=y - _CHAN_LOCAL["de_pe"] * e)


def peixe_azul(cx, cy, alto=40, espello=False, so_cola=False):
    """El pez del cuento: el mismo dibujo que la lámina `peixe` del
    vocabulario, pero AZUL CLARO, porque el cuento lo nombra así en las tres
    láminas (la errata del texto modelo era cambiarle el color)."""
    corpo = [
        ruta("M18 50 C18 34 38 24 56 24 C74 24 86 36 86 50 C86 64 74 76 56 76 "
             "C38 76 18 66 18 50 Z", f=CEO, s=AZUL_ESCURO, sw=4),
        ruta("M44 26 C48 14 58 12 64 18 C58 22 52 26 48 30 Z", f=BURBULLA,
             s=AZUL_ESCURO, sw=3),
        ruta("M40 68 C44 80 54 82 60 76 C54 72 48 70 44 66 Z", f=BURBULLA,
             s=AZUL_ESCURO, sw=3),
        ruta("M40 40 C46 46 46 54 40 60 M52 38 C58 44 58 56 52 62", s=AZUL_ESCURO,
             sw=3),
        elipse(72, 44, 7, 8, f=BRANCO, s=AZUL_ESCURO, sw=2),
        elipse(73, 44, 3.5, 4.5, f=NEGRO),
    ]
    cola = [ruta("M18 50 L4 32 C2 44 2 56 4 68 Z", f=BURBULLA, s=AZUL_ESCURO,
                 sw=4)]
    formas = cola if so_cola else cola + corpo
    e = alto / 100.0
    # Reflejado, x pasa a -x: el centro (50) queda en -50, y hay que sumarlo.
    dx = cx + 50 * e if espello else cx - 50 * e
    return poner(formas, e=e, dx=dx, dy=cy - 50 * e, espello=espello)


def pedra(cx, cy, rx, ry):
    return [elipse(cx, cy, rx, ry, f=CEO_GRIS, s=LOUSA, sw=3)]


def burbullas(puntos):
    return [elipse(x, y, r, r, f="#a5f3fc66", s=BRANCO, sw=1.6)
            for x, y, r in puntos]


def alga(x, base, alto=34):
    d = (f"M{x} {base} C{x - 8} {base - alto * 0.3} {x + 8} {base - alto * 0.6} "
         f"{x} {base - alto}")
    return [ruta(d, s=VERDE_ESCURO, sw=6), ruta(d, s="#2ecc40", sw=3)]


def mar_fondo():
    return [ruta(f"M0 0 L{ANCHO} 0 L{ANCHO} {ALTO} L0 {ALTO} Z", f=FONDO_MAR)]


# ======================================= microcuento.curso_2_3.10 · el pez


def peixe_1():
    f = mar_fondo()
    f += burbullas([(30, 22, 3), (36, 14, 2), (128, 30, 2.5)])
    # Solo la cola, asomando POR DETRÁS del hueco entre las dos piedras: «algo
    # se move». Se pinta antes que ellas. La cola local ocupa x 2-18, así que
    # el centro va 40 unidades a su derecha.
    f += peixe_azul(150, 71, alto=44, so_cola=True)
    f += pedra(116, 90, 18, 10)
    f += pedra(146, 88, 16, 12)
    f += lua_flotando(70, 84, alto=66, brazo_e=55, brazo_d=-55,
                      ollos="abertos")
    return f, ("Lúa baixa ao fondo do mar coas gafas de mergullo; entre dúas "
               "pedras asoma a cola dun peixe azul.")


def peixe_2():
    f = mar_fondo()
    f += alga(14, 100, 40)
    f += alga(150, 100, 34)
    f += lua_flotando(34, 86, alto=52, brazo_e=70, brazo_d=-70,
                      ollos="contentos")
    f += frecha_movemento("M66 66 L76 56 L86 66 L96 56", color=BRANCO, sw=3)
    f += peixe_azul(116, 56, alto=52)
    f += burbullas([(138, 34, 3), (142, 24, 4), (148, 12, 5)])
    return f, ("Un peixiño azul nada en zigzag e bota tres burbullas; Lúa "
               "achégase amodo cos brazos abertos.")


def peixe_3():
    f = mar_fondo()
    # Las olas grandes, arriba y abajo, en el azul escuro con espuma blanca.
    for y in (16, 88):
        f += [ruta(f"M0 {y} C20 {y - 12} 40 {y + 12} 60 {y} C80 {y - 12} 100 "
                   f"{y + 12} 120 {y} C140 {y - 12} 150 {y + 8} 160 {y}",
                   s=AZUL_ESCURO, sw=9),
              ruta(f"M0 {y - 4} C20 {y - 16} 40 {y + 8} 60 {y - 4} C80 {y - 16} "
                   f"100 {y + 8} 120 {y - 4} C140 {y - 16} 150 {y + 4} 160 {y - 4}",
                   s=BRANCO, sw=2.5)]
    f += lua_flotando(58, 80, alto=60, brazo_e=10, brazo_d=-150,
                      ollos="contentos")
    f += peixe_azul(108, 52, alto=40, espello=True)
    return f, ("Lúa e o peixiño fan ondas xigantes e dinse adeus: ela coa man, "
               "el coa cola.")


ESCENAS = {
    "microcuento_2_3_10_1": peixe_1,
    "microcuento_2_3_10_2": peixe_2,
    "microcuento_2_3_10_3": peixe_3,
}


def main() -> int:
    for clave, fabrica in sorted(ESCENAS.items()):
        formas, nota = fabrica()
        doc = {
            "vb": ANCHO,
            "vh": ALTO,
            "nota": nota,
            "generado": "tools/draw_microcuentos.py",
            "formas": formas,
        }
        (DESTINO / f"{clave}.json").write_text(
            json.dumps(doc, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8")
    print(f"OK: {len(ESCENAS)} láminas de microcuento escritas en "
          f"{DESTINO.relative_to(ROOT)}/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
