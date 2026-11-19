#!/usr/bin/env python3
"""O-20261119-8: el banco de escucha copiado de Valeria, entero y limpio.

Falla si:
  - falta valeria_gl.json, valeria_es.json o valeria_en.json;
  - el número de pares, progresiones, cápsulas, escenarios o categorías no es
    el de Valeria (commit e2a2a5e8: es 15 pares, gl 13, en 9; 9 progresiones,
    8 cápsulas, 5 escenarios y 5 categorías en cada lengua);
  - una progresión no tiene sus cuatro fases en orden (concepto, parte,
    acción, cualidad);
  - aparece «logopedia», «terapia», «trastorno», «clínico» o «diagnóstico»:
    es un juego educativo (opción A de O-20261118-3);
  - una clave de lámina no existe en assets/brand/laminas;
  - hay más palabras sin lámina que el tope de tools/tope_escoita_sen_lamina.txt,
    que solo puede bajar.
"""
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
DIR = RAIZ / "assets/content/escoita"
LAMINAS = RAIZ / "assets/brand/laminas"
TOPE = RAIZ / "tools/tope_escoita_sen_lamina.txt"
PARES = {"es": 15, "gl": 13, "en": 9}
GRUPOS = {"progresions": 9, "capsulas": 8, "escenarios": 5, "categorias": 5}
FASES = ["concepto", "parte", "accion", "cualidad"]
PROHIBIDAS = re.compile(r"logopedi|terapi|therap|trastorn|disorder|cl[ií]nic|diagn[oó]s", re.I)


def pezas(d):
    for p in d["pares"]:
        yield p["a"]
        yield p["b"]
    for k, c in (("progresions", "fases"), ("capsulas", "voltas"),
                 ("escenarios", "items"), ("categorias", "items")):
        for g in d[k]:
            yield from g[c]


def main() -> int:
    fallos, sen = [], 0
    for lang, npar in PARES.items():
        f = DIR / f"valeria_{lang}.json"
        if not f.exists():
            fallos.append(f"falta {f.relative_to(RAIZ)}")
            continue
        texto = f.read_text(encoding="utf-8")
        d = json.loads(texto)
        if len(d["pares"]) != npar:
            fallos.append(f"{lang}: {len(d['pares'])} pares, Valeria tiene {npar}")
        for k, n in GRUPOS.items():
            if len(d[k]) != n:
                fallos.append(f"{lang}: {len(d[k])} {k}, Valeria tiene {n}")
        for g in d["progresions"]:
            if [x["tipo"] for x in g["fases"]] != FASES:
                fallos.append(f"{lang}: {g['id']} no va concepto → parte → acción → cualidad")
        for m in PROHIBIDAS.finditer(texto):
            fallos.append(f"{lang}: palabra prohibida «{m.group(0)}»")
        for p in pezas(d):
            if p["lamina"] is None:
                sen += 1
            elif not (LAMINAS / f"{p['lamina']}.json").exists():
                fallos.append(f"{lang}: la lámina {p['lamina']} de «{p['palabra']}» no existe")
    tope = int(TOPE.read_text(encoding="utf-8").split()[0])
    if sen > tope:
        fallos.append(f"{sen} palabras sin lámina; el tope es {tope}")
    if fallos:
        print("\n".join(f"FALLA: {x}" for x in fallos))
        return 1
    aviso = f" (baja el tope a {sen})" if sen < tope else ""
    print(f"OK: banco de escucha de Valeria entero en gl, es y en; {sen} palabras sin lámina, tope {tope}{aviso}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
