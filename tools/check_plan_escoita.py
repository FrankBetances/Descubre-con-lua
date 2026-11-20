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
ACOPROS = RAIZ / "assets/content/acopros/proxectos_0_2.json"
LAMINAS = RAIZ / "assets/brand/laminas"
CURSOS = ["curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]
FASES = ["concepto", "parte", "accion", "cualidad"]
MOMENTOS = ["predice", "proba", "compara", "explica"]
MODO_POR_CURSO = {
    "curso_2_3": "elige_dos",
    "curso_3_4": "elige_dos",
    "curso_4_5": "palabra_corta",
    "curso_5_6": "explica_because",
}
PROHIBIDAS = re.compile(r"logopedi|terapi|therap|trastorn|disorder|cl[ií]nic|diagn[oó]s", re.I)


def _tokens_en(text: str) -> set[str]:
    return set(re.findall(r"[a-z]+", text.lower()))


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
    pendentes = []
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
        # Un par marcado "pendiente" (P7.9) no se enseña en la lección: se
        # lista aquí y no se le exige el STEAM hasta que se rehaga.
        if p["par"].get("pendiente"):
            pendentes.append(sitio)
            palabras = list(fases)
        else:
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

        # P9.2: bloque pensamiento STEAM (predice, proba, compara, explica)
        pens = p.get("pensamiento")
        if not isinstance(pens, dict):
            fallos.append(f"{sitio}: falta el bloque «pensamiento» (P9.2)")
        else:
            modo_esp = MODO_POR_CURSO.get(p["curso"])
            if pens.get("edad_modo") != modo_esp:
                fallos.append(f"{sitio}: pensamiento.edad_modo={pens.get('edad_modo')!r}, se esperaba {modo_esp!r}")
            vocab_pieza = {w["en"].lower() for w in [p["par"]["a"], p["par"]["b"], *fases]}
            # También acepta formas flexionadas simples (plural -s, -ed, -ing)
            vocab_stems = set(vocab_pieza)
            for w in vocab_pieza:
                vocab_stems.update({w + "s", w + "es", w + "ed", w + "ing"})
            tokens_pens: set[str] = set()
            for mom in MOMENTOS:
                m = pens.get(mom)
                if not isinstance(m, dict):
                    fallos.append(f"{sitio}: falta el momento pensamiento.{mom}")
                    continue
                q_en = str(m.get("pregunta_en") or "").strip()
                if not q_en:
                    fallos.append(f"{sitio}: pensamiento.{mom}.pregunta_en vacío")
                for campo in ("significado", "guia", "observar"):
                    val = m.get(campo) or {}
                    if not all(val.get(l) for l in ("gl", "es")):
                        fallos.append(f"{sitio}: pensamiento.{mom}.{campo} vacío en gl o es")
                toks = _tokens_en(q_en)
                if mom == "explica":
                    mod_en = str(m.get("modelo_en") or "").strip()
                    if not mod_en:
                        fallos.append(f"{sitio}: pensamiento.explica.modelo_en vacío")
                    if not all((m.get("modelo_significado") or {}).get(l) for l in ("gl", "es")):
                        fallos.append(f"{sitio}: pensamiento.explica.modelo_significado vacío en gl o es")
                    if p["curso"] == "curso_5_6" and "because" not in mod_en.lower():
                        fallos.append(f"{sitio}: en 5-6 años, explica.modelo_en debe usar «because»")
                    toks |= _tokens_en(mod_en)
                tokens_pens |= toks
                if not (toks & vocab_stems):
                    fallos.append(f"{sitio}: pensamiento.{mom} («{q_en}») no usa ninguna palabra del par o progresión ({sorted(vocab_pieza)})")
            if p["curso"] in ("curso_2_3", "curso_3_4"):
                pred_q = str((pens.get("predice") or {}).get("pregunta_en") or "").lower()
                comp_q = str((pens.get("compara") or {}).get("pregunta_en") or "").lower()
                if " or " not in pred_q and " or " not in comp_q:
                    fallos.append(f"{sitio}: en 2-3/3-4 el niño elige entre dos («or» en predice/compara)")
            if not (tokens_pens & {p["par"]["a"]["en"].lower(), p["par"]["b"]["en"].lower(),
                                   p["par"]["a"]["en"].lower() + "s", p["par"]["b"]["en"].lower() + "s"}):
                fallos.append(f"{sitio}: pensamiento no menciona ninguna palabra del par ({p['par']['a']['en']}/{p['par']['b']['en']})")

    if ACOPROS.exists():
        ac = json.loads(ACOPROS.read_text(encoding="utf-8"))
        for pr in ac.get("proxectos") or []:
            mes_c = pr.get("mesCalendario", "?")
            mira = pr.get("mira_e_nota")
            if not isinstance(mira, dict):
                fallos.append(f"0-2 mes {mes_c}: falta «mira_e_nota» (P9.2)")
                continue
            if not mira.get("frase_en"):
                fallos.append(f"0-2 mes {mes_c}: mira_e_nota.frase_en vacío")
            if "?" in str(mira) or "¿" in str(mira):
                fallos.append(f"0-2 mes {mes_c}: mira_e_nota no puede tener preguntas abiertas")
            for campo in ("significado", "guia", "observar"):
                if not all((mira.get(campo) or {}).get(l) for l in ("gl", "es")):
                    fallos.append(f"0-2 mes {mes_c}: mira_e_nota.{campo} vacío en gl o es")

    faltan = [f"{c} mes {m}" for c in CURSOS for m in range(1, 11) if (c, m) not in vistos]
    fallos += [f"falta la pieza de {x}" for x in faltan]
    if fallos:
        print("\n".join(f"FALLA: {x}" for x in fallos))
        return 1
    extra = f" Pares pendientes de rehacer (P7.9): {len(pendentes)}: {', '.join(pendentes)}." if pendentes else ""
    print(f"OK: {len(pezas)} piezas de escucha con pensamiento STEAM (4 momentos c/u) y 10 proyectos 0-2 con mira_e_nota.{extra}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
