#!/usr/bin/env python3
"""O-20261118-3: la app es un juego educativo. Falla si «logopedia», «terapia»,
«terapéutico», «trastorno» o «diagnóstico» aparecen en assets/, lib/ o en las
páginas públicas de docs/ (las que sirve GitHub Pages).

Excepciones, y solo estas: la lista de palabras vetadas del propio validador de
contenido y la cláusula legal que dice que la app NO trata ningún trastorno.
"""
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
VETADAS = re.compile(
    r"\b(?:logopedia|terapias?|terap[eé]utic[oa]s?|trastornos?|diagn[oó]sticos?)\b", re.IGNORECASE)
EXCEPCIONES = {
    "lib/data/validators/content_validator.dart": lambda linea: "r'" in linea,
    "docs/terms.html": lambda linea: "Exclusión de finalidad sanitaria" in linea,
}
TEXTO = {".json", ".dart", ".txt", ".html", ".md", ".arb", ".yaml"}


def ficheros():
    for base in ("assets", "lib"):
        for p in (RAIZ / base).rglob("*"):
            if p.is_file() and p.suffix in TEXTO:
                yield p
    yield from (RAIZ / "docs").glob("*.html")


def main() -> int:
    fallos = []
    n = 0
    for p in ficheros():
        n += 1
        rel = p.relative_to(RAIZ).as_posix()
        permitida = EXCEPCIONES.get(rel, lambda _l: False)
        for i, linea in enumerate(p.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            if VETADAS.search(linea) and not permitida(linea):
                fallos.append(f"  {rel}:{i}: {VETADAS.search(linea).group(0)}")
    if fallos:
        print("FALLA: palabra clínica en un juego educativo:\n" + "\n".join(fallos))
        return 1
    print(f"OK: {n} ficheros de assets/, lib/ y docs/*.html, sin vocabulario clínico.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
