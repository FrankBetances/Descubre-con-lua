#!/usr/bin/env python3
"""Las láminas vectoriales dicen lo que dibujan, o no pasan.

Por qué existe. El formato usaba `w` para dos cosas distintas: el ANCHO de un
rectángulo y el GROSOR del contorno. En un `rrect` eso deja la misma clave dos
veces dentro del mismo objeto, y JSON se queda con la última sin avisar a
nadie. Resultado: la barra de la toalla no se pintaba, el fichero se leía
perfectamente bien y no había forma de saber por qué. Diecisiete formas
estaban afectadas.

Un dibujo que no se pinta es la misma familia de fallo que un asset que no
viaja: silencioso, y solo se ve mirando la pantalla. Aquí se ve antes.

Lo que se comprueba:

  1. Ninguna clave repetida dentro de una forma.
  2. El tipo existe y trae las claves que ese tipo necesita.
  3. Los colores son hexadecimales de 6 u 8 dígitos.
  4. Ninguna forma es INVISIBLE: o tiene relleno, o tiene contorno con grosor.
     Una forma sin ninguno de los dos ocupa sitio en el fichero y no pinta nada.
  5. Nada se sale del lienzo por más de un margen de cortesía.
"""

from __future__ import annotations

import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
LAMINAS = ROOT / "assets" / "brand" / "laminas"

CLAVES_POR_TIPO = {
    "elipse": {"cx", "cy", "rx", "ry"},
    "rrect": {"x", "y", "w", "h"},
    "poli": {"p"},
    "ruta": {"d"},
}

HEX = re.compile(r"^#(?:[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$")
NUMERO = re.compile(r"-?\d*\.?\d+")


def pares_con_duplicados(pares):
    """Conserva los duplicados que `json.load` tiraría."""
    cuenta = Counter(k for k, _ in pares)
    d = dict(pares)
    repetidas = [k for k, n in cuenta.items() if n > 1]
    if repetidas:
        d["__repetidas__"] = repetidas
    return d


def main() -> int:
    fallos: list[str] = []
    revisadas = 0
    formas_totales = 0

    for ruta in sorted(LAMINAS.glob("*.json")):
        nombre = ruta.name
        try:
            datos = json.loads(
                ruta.read_text(encoding="utf-8"),
                object_pairs_hook=pares_con_duplicados,
            )
        except json.JSONDecodeError as e:
            fallos.append(f"{nombre}: no es JSON válido: {e}")
            continue

        revisadas += 1
        lienzo = datos.get("vb")
        if not isinstance(lienzo, (int, float)) or lienzo <= 0:
            fallos.append(f"{nombre}: falta `vb` (el lado del lienzo)")
            lienzo = 100

        formas = datos.get("formas")
        if not isinstance(formas, list) or not formas:
            fallos.append(f"{nombre}: no tiene formas")
            continue

        for i, forma in enumerate(formas):
            formas_totales += 1
            donde = f"{nombre} forma {i}"
            if not isinstance(forma, dict):
                fallos.append(f"{donde}: no es un objeto")
                continue

            repetidas = forma.get("__repetidas__")
            if repetidas:
                fallos.append(
                    f"{donde}: clave repetida {repetidas}. JSON se queda con la "
                    f"última y la otra desaparece sin decirlo."
                )

            tipo = forma.get("t")
            if tipo not in CLAVES_POR_TIPO:
                fallos.append(f"{donde}: tipo desconocido {tipo!r}")
                continue

            faltan = CLAVES_POR_TIPO[tipo] - set(forma)
            if faltan:
                fallos.append(f"{donde} [{tipo}]: le faltan {sorted(faltan)}")

            for clave in ("f", "s"):
                color = forma.get(clave)
                if color is not None and not HEX.match(str(color)):
                    fallos.append(
                        f"{donde}: `{clave}` no es un color hex de 6 u 8 "
                        f"dígitos: {color!r}"
                    )

            tiene_relleno = forma.get("f") is not None
            grosor = forma.get("sw") or 0
            tiene_trazo = forma.get("s") is not None and grosor > 0
            if not tiene_relleno and not tiene_trazo:
                fallos.append(
                    f"{donde} [{tipo}]: no se pinta. Sin `f` y sin `s`+`sw` la "
                    f"forma existe en el fichero y no aparece en pantalla."
                )

            if "w" in forma and tipo != "rrect":
                fallos.append(
                    f"{donde} [{tipo}]: usa `w`. El grosor del contorno es "
                    f"`sw`; `w` es solo el ancho de un `rrect`."
                )

            # Que el dibujo esté dentro del lienzo. Un margen de 6 unidades
            # perdona el grosor del contorno, que se pinta centrado.
            coords: list[float] = []
            for clave in ("cx", "cy", "x", "y"):
                if isinstance(forma.get(clave), (int, float)):
                    coords.append(float(forma[clave]))
            if tipo == "ruta":
                coords += [float(n) for n in NUMERO.findall(str(forma["d"]))]
            if tipo == "poli":
                for par in forma.get("p") or []:
                    coords += [float(v) for v in par]
            fuera = [c for c in coords if c < -6 or c > lienzo + 6]
            if fuera:
                fallos.append(
                    f"{donde} [{tipo}]: se sale del lienzo en {sorted(set(fuera))[:4]}"
                )

    if fallos:
        print("FAIL: las láminas tienen problemas:", file=sys.stderr)
        for linea in fallos:
            print(f"  {linea}", file=sys.stderr)
        return 1

    print(f"OK: {revisadas} láminas, {formas_totales} formas, todas se pintan.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
