#!/usr/bin/env python3
"""Ningún emoji del sistema como iconografía.

Regla 5 del CLAUDE.md: «Nada de emoji del sistema como iconografía: cambian
entre fabricantes y nunca forman un set.» No es una manía estética. El mismo
carácter ⚠️ es un triángulo naranja en un Samsung, uno rojo plano en un Pixel y
otra cosa en un Xiaomi, así que un aviso de seguridad —que es de lo que va la
pantalla donde estaba— se dibujaba distinto en cada aula. Y al lado había YA un
icono del set propio diciendo lo mismo: dos avisos, dos dibujos.

Este gate nace de encontrar uno que llevaba meses ahí sin que nada lo mirara.
Un defecto arreglado sin gate vuelve, porque escribir un emoji es más rápido
que buscar el icono.

Dónde mira, y por qué solo ahí:

  lib/**.dart      lo que se PINTA en la pantalla
  assets/content/  el contenido, que también se pinta
  test/**.dart     lo que EXIGE que la pantalla diga

Fuera quedan `docs/` y los `.md`: ahí un emoji es prosa para quien lee el
manual, no iconografía dentro de la app.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Los bloques de donde sale la pictografía de los teclados. No se listan los
# emoji uno a uno: se listan los rangos, porque el siguiente que entre no va a
# ser ninguno de los que hoy se nos ocurran.
EMOJI = re.compile(
    "["
    "\U0001F000-\U0001FAFF"  # pictogramas, emoticonos, símbolos y transporte
    "☀-➿"          # símbolos misceláneos y dingbats
    "⬀-⯿"          # flechas y formas geométricas
    "️"                 # el selector que convierte un símbolo en emoji
    "‍"                 # el unificador que pega emoji entre sí
    "]"
)

OBJETIVOS = [
    (ROOT / "lib", "*.dart"),
    (ROOT / "assets" / "content", "*.json"),
    # Y los tests. No porque un test pinte nada, sino porque un test que EXIGE
    # el emoji obliga a reponerlo: al quitarlo de la pantalla, dos tests se
    # pusieron rojos buscando la cadena con el ⚠️ dentro. Ese es el camino por
    # el que vuelve.
    (ROOT / "test", "*.dart"),
]


def main() -> int:
    hallazgos: list[str] = []
    revisados = 0

    for carpeta, patron in OBJETIVOS:
        if not carpeta.is_dir():
            continue
        for fichero in sorted(carpeta.rglob(patron)):
            revisados += 1
            for n, linea in enumerate(
                fichero.read_text(encoding="utf-8").splitlines(), 1
            ):
                encontrados = EMOJI.findall(linea)
                if encontrados:
                    ruta = fichero.relative_to(ROOT)
                    hallazgos.append(
                        f"  {ruta}:{n}: {''.join(sorted(set(encontrados)))}  "
                        f"→ {linea.strip()[:70]}"
                    )

    if hallazgos:
        print("FAIL: hay emoji del sistema usados como iconografía:",
              file=sys.stderr)
        for linea in hallazgos:
            print(linea, file=sys.stderr)
        print(
            "\nEl mismo emoji se dibuja distinto en cada fabricante, así que no\n"
            "forma un set. El icono sale de Material o de las láminas propias.",
            file=sys.stderr,
        )
        return 1

    print(f"OK: {revisados} ficheros de pantalla y de contenido, sin emoji.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
