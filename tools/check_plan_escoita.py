#!/usr/bin/env python3
"""O-20261119-8: las 40 piezas de escucha del mes (Frank: «uno por mes»).

Comprueba assets/content/escoita/plan_mensual.json (lo prepara Antigravity,
P7.2). Mientras no exista, lo dice y no falla: el criterio sigue abierto en
docs/ORDENES.md. En cuanto existe, falla si:
  - no hay exactamente una pieza por curso (2-3, 3-4, 4-5, 5-6) y mes (1-10);
  - un par o una progresión se repite en cualquier otro mes o edad;
  - una progresión no va concepto → parte → acción → cualidad;
  - un texto gl o es está vacío, o el modelo no tiene tres frases;
  - una lámina no existe;
  - aparece vocabulario clínico (opción A de O-20261118-3);
  - la pieza no lleva el STEAM de su mes (steam.id distinto del de
    leccions.json), o una palabra (las dos del par y las cuatro fases) no
    dice qué parte de ESE experimento nombra, o se describe como contraste
    ajeno al experimento (F-20261119-9, R-STEAM: cada palabra nombra el STEAM).
La fonética de los pares la comprueba tools/check_pares_en.py (P7.1).
"""
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LECCIONS = RAIZ / "assets/content/leccions/leccions.json"
AJENO = re.compile(r"sin relaci|ajen|no pertenece|no va en|no transmite|contraste (de|con) (un|una|otro|otra|el|la|comida|animal|insecto|objeto)", re.I)
PLAN = RAIZ / "assets/content/escoita/plan_mensual.json"
LAMINAS = RAIZ / "assets/brand/laminas"
CURSOS = ["curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]
FASES = ["concepto", "parte", "accion", "cualidad"]
PROHIBIDAS = re.compile(r"logopedi|terapi|therap|trastorn|disorder|cl[ií]nic|diagn[oó]s", re.I)


def main() -> int:
    if not PLAN.exists():
        print("PENDIENTE: assets/content/escoita/plan_mensual.json aún no existe (P7.2, Antigravity).")
        return 0
    texto = PLAN.read_text(encoding="utf-8")
    d = json.loads(texto)
    pezas = d if isinstance(d, list) else (d.get("piezas") or d.get("pezas") or [])
    if not pezas:
        print("PENDIENTE: plan_mensual.json no tiene piezas todavía (P7.6, Antigravity).")
        return 0
    fallos = [f"vocabulario prohibido «{m.group(0)}»" for m in PROHIBIDAS.finditer(texto)]
    cursos = json.loads(LECCIONS.read_text(encoding="utf-8"))["cursos"]
    vistos, pares, progs = set(), {}, {}
    for p in pezas:
        k = (p["curso"], p["mes"])
        sitio = f"{p['curso']} mes {p['mes']}"
        if k in vistos:
            fallos.append(f"{sitio}: repetido")
        vistos.add(k)
        try:
            esperado = cursos[p["curso"]]["unidades"][p["mes"] - 1]["steam"]["id"]
        except (KeyError, IndexError, TypeError):
            esperado = None
        if not esperado or (p.get("steam") or {}).get("id") != esperado:
            fallos.append(f"{sitio}: steam.id no es el STEAM del mes ({esperado})")
        par = frozenset((p["par"]["a"]["en"].lower(), p["par"]["b"]["en"].lower()))
        if par in pares:
            fallos.append(f"{sitio}: el par {sorted(par)} ya está en {pares[par]}")
        pares[par] = sitio
        fases = p["progresion"]["fases"]
        if [f["tipo"] for f in fases] != FASES:
            fallos.append(f"{sitio}: la progresión no va {' → '.join(FASES)}")
        con = fases[0]["en"].lower() if fases else ""
        if con in progs:
            fallos.append(f"{sitio}: la progresión de «{con}» ya está en {progs[con]}")
        progs[con] = sitio
        if len(p["modelo"]["adulto"]) != 3:
            fallos.append(f"{sitio}: el modelo del adulto no tiene tres frases")
        palabras = [p["par"]["a"], p["par"]["b"], *fases]
        for w in palabras:
            st = w.get("steam") or {}
            if not all(st.get(l) for l in ("gl", "es")):
                fallos.append(f"{sitio}: «{w['en']}» no dice qué parte del STEAM nombra")
            elif AJENO.search(st.get("es", "")) or AJENO.search(st.get("gl", "")):
                fallos.append(f"{sitio}: «{w['en']}» se describe como ajena al experimento («{st['es'][:50]}»)")
            if not (w.get("gl") and w.get("es")):
                fallos.append(f"{sitio}: «{w['en']}» sin significado gl o es")
            if not w.get("lamina") or not (LAMINAS / f"{w['lamina']}.json").exists():
                fallos.append(f"{sitio}: «{w['en']}» sin lámina válida ({w.get('lamina')})")
        for campo in ("nota", "mision_acerto", "mision_fallo", "pista"):
            if not all(p["par"][campo].get(l) for l in ("gl", "es")):
                fallos.append(f"{sitio}: par.{campo} vacío en gl o es")
        for f in fases:
            if not all(f["accion"].get(l) for l in ("gl", "es")):
                fallos.append(f"{sitio}: la acción de «{f['en']}» vacía en gl o es")
    faltan = [f"{c} mes {m}" for c in CURSOS for m in range(1, 11) if (c, m) not in vistos]
    fallos += [f"falta la pieza de {x}" for x in faltan]
    if fallos:
        print("\n".join(f"FALLA: {x}" for x in fallos))
        return 1
    print(f"OK: {len(pezas)} piezas de escucha, una por mes y edad, sin repetir.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
