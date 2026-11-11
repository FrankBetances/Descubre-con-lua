#!/usr/bin/env python3
"""O-20261109-4 (ACOPROS, referencias/acopros/consideraciones-2026-11-09.md):
0-2 años trabaja por proyectos, uno por mes, con unas 20 palabras bien
escogidas, sin gramática, frases de dos elementos como mucho y una rima
tradicional, y empieza cada proyecto por el vocabulario y la canción.

No inventa contenido: SELECCIONA del material de 0-2 que ya existe.
- Proyecto: el tema y el STEAM de la unidad del mes (leccions.json).
- Canción: la canción con pulso del mes (cancions/cancions_con_pulso.json),
  una por mes en el orden del curso.
- Palabras: primero las de la lección del mes, luego las del banco TPR del
  mes (tpr/curso_0_2), con su significado y su gesto; solo de uno o dos
  elementos y sin el verbo «to be». Veinte por proyecto, cinco por semana.
- Rima: una tradicional inglesa de dominio público por mes (Decisión de
  Frank, 9/11/2026), la primera estrofa.

Uso: python3 tools/gen_acopros_0_2.py [--check]
Escribe assets/content/acopros/proxectos_0_2.json."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SAIDA = RAIZ / "assets/content/acopros/proxectos_0_2.json"
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
POR_PROXECTO = 20
# O-20261111-2: cada palabra, con su lámina (tools/gen_laminas_palabras.py).
_MAPA = RAIZ / "assets/content/laminas/palabras_laminas.json"
LAMINAS_PAL = json.loads(_MAPA.read_text(encoding="utf-8"))["pezas"] if _MAPA.exists() else {}
TO_BE = re.compile(r"\b(is|are|am|was|were|be|it's|i'm|you're|we're|they're)\b", re.I)

# Rimas tradicionales inglesas de dominio público, la primera estrofa. Una
# por mes, cerca del tema del proyecto. gl/es: lo que quiere decir, para la
# persona adulta.
RIMAS = {
    9: ("Pat-a-cake, pat-a-cake, baker's man! Bake me a cake as fast as you can.",
        "Bate, bate palmiñas, panadeiro! Faime unha torta axiña.",
        "¡Palmas, palmitas, panadero! Hazme una torta muy deprisa."),
    10: ("Head, shoulders, knees and toes, knees and toes.",
         "Cabeza, ombreiros, xeonllos e pés.",
         "Cabeza, hombros, rodillas y pies."),
    11: ("Round and round the garden, like a teddy bear.",
         "Dando voltas polo xardín, coma un osiño.",
         "Dando vueltas por el jardín, como un osito."),
    12: ("Twinkle, twinkle, little star, how I wonder what you are.",
         "Brilla, brilla, estreliña, que serás, pregunto eu.",
         "Brilla, brilla, estrellita, qué serás, me pregunto."),
    1: ("This is the way we put on our hat, put on our hat, put on our hat.",
        "Así é como pomos o gorro.",
        "Así es como nos ponemos el gorro."),
    2: ("Old MacDonald had a farm, E-I-E-I-O.",
        "O vello MacDonald tiña unha granxa.",
        "El viejo MacDonald tenía una granja."),
    3: ("Ring-a-ring o' roses, a pocket full of posies.",
        "Roda, roda de rosas, o peto cheo de flores.",
        "Corro de rosas, el bolsillo lleno de flores."),
    4: ("Rain, rain, go away, come again another day.",
        "Chuvia, chuvia, vaite xa, volve outro día.",
        "Lluvia, lluvia, vete ya, vuelve otro día."),
    5: ("This is the way we wash our hands, wash our hands, wash our hands.",
        "Así é como lavamos as mans.",
        "Así es como nos lavamos las manos."),
    6: ("Row, row, row your boat, gently down the stream.",
        "Rema, rema, rema o teu barco, suave río abaixo.",
        "Rema, rema, rema tu barco, suave río abajo."),
}

FASES = [
    ({"gl": "Descubrimos: as primeiras palabras e a canción",
      "es": "Descubrimos: las primeras palabras y la canción"}),
    ({"gl": "Xogamos coas palabras e coa canción",
      "es": "Jugamos con las palabras y con la canción"}),
    ({"gl": "A rima tradicional, coas palabras do tema",
      "es": "La rima tradicional, con las palabras del tema"}),
    ({"gl": "Repasamos todo o proxecto",
      "es": "Repasamos todo el proyecto"}),
]


def limpo(en: str) -> str:
    return re.sub(r"\s+", " ", en.strip())


def elementos(en: str) -> int:
    return len([t for t in re.split(r"[\s,/]+", re.sub(r"[!?.…]", "", en)) if t])


def valida(en: str) -> bool:
    return 0 < elementos(en) <= 2 and not TO_BE.search(en)


def construir() -> dict:
    lec = json.loads((RAIZ / "assets/content/leccions/leccions.json").read_text(encoding="utf-8"))
    unidades = lec["cursos"]["curso_0_2"]["unidades"]
    cancions = json.loads((RAIZ / "assets/content/cancions/cancions_con_pulso.json").read_text(encoding="utf-8"))["cancions"]
    proxectos = []
    anteriores: list[str] = []
    for i, mes in enumerate(MESES):
        u = unidades[i]
        tpr = json.loads(next((RAIZ / "assets/content/tpr/curso_0_2").glob(f"tpr.{i + 1:02d}.*.json")).read_text(encoding="utf-8"))
        palabras: list[dict] = []
        vistas: set[str] = set()

        def engade(en, gl, es, xesto_gl, xesto_es, orixe):
            en = limpo(en)
            k = en.lower().strip("!?. ")
            if not valida(en) or k in vistas or len(palabras) >= POR_PROXECTO:
                return
            vistas.add(k)
            palabras.append({"en": en, "gl": gl, "es": es,
                             "xesto": {"gl": xesto_gl, "es": xesto_es}, "orixe": orixe,
                             **({"lamina": LAMINAS_PAL[k]["clave"]} if k in LAMINAS_PAL else {})})

        for l in u["leccions"]:
            for p in l["novas"]:
                x = p.get("xesto") or {}
                engade(p["en"], p.get("gl", ""), p.get("es", ""), x.get("gl", ""), x.get("es", ""), "leccion")
        # Del banco del mes: primero los nombres (el vocabulario base), luego el resto.
        todas = [w for s in tpr["semanas"] for w in s["palabras"]]
        for w in sorted(todas, key=lambda w: 0 if w.get("category") == "noun" else 1):
            a = w.get("tprAction") or {}
            engade(w["en"], w.get("gl", ""), w.get("es", ""), a.get("gl", ""), a.get("es", ""), "tpr")

        semanas = []
        for s in range(4):
            sw = palabras[s * 5:(s + 1) * 5]
            semanas.append({"semana": s + 1, "fase": FASES[s], "palabras": [w["en"] for w in sw]})
        frases = [w for w in palabras if elementos(w["en"]) == 2]
        cn = cancions[i]
        canc = {"id": cn["id"], "gl": cn["titulo"]["gl"], "es": cn["titulo"]["es"]}
        en, gl, es = RIMAS[mes]
        proxectos.append({
            "mesCalendario": mes,
            "proxecto": u["titulo"],
            "steam": u.get("steam"),
            "cancion": canc,
            "rima": {"en": en, "gl": gl, "es": es},
            "palabras": palabras,
            "semanas": semanas,
            # Como falar: frases de dous elementos do propio proxecto, co seu
            # xesto; se non hai, a palabra soa (holofrase).
            "comoFalar": [w["en"] for w in (frases or palabras)][:4],
            # Xa debería saber: palabras soltas do proxecto anterior.
            "xaSabe": [p for p in anteriores if elementos(p) == 1][:8],
            "guia": {
                "gl": f"Canta «{canc['gl']}» co xesto. Repasa as palabras do proxecto, unha a unha, mentres xogades.",
                "es": f"Canta «{canc['es']}» con el gesto. Repasa las palabras del proyecto, una a una, mientras jugáis.",
            },
        })
        anteriores = [w["en"] for w in palabras]
    return {
        "_doc": "Xerado por tools/gen_acopros_0_2.py (O-20261109-4, ACOPROS). Non se edita a man.",
        "fonte": "referencias/acopros/consideraciones-2026-11-09.md",
        "proxectos": proxectos,
    }


def revisar(d: dict) -> list[str]:
    fallos = []
    if len(d["proxectos"]) != 10:
        fallos.append("non hai 10 proxectos")
    for p in d["proxectos"]:
        m = p["mesCalendario"]
        n = len(p["palabras"])
        if not 18 <= n <= 22:
            fallos.append(f"mes {m}: {n} palabras, non unhas 20")
        for w in p["palabras"]:
            if not valida(w["en"]):
                fallos.append(f"mes {m}: «{w['en']}» ten máis de dous elementos ou o verbo to be")
            if not (w["gl"] and w["es"]):
                fallos.append(f"mes {m}: «{w['en']}» sen significado gl/es")
        presentadas = {w["en"].lower().strip("!?. ") for w in p["palabras"]}
        tokens = {t.lower() for w in p["palabras"] for t in re.split(r"[\s,/]+", re.sub(r"[!?.…]", "", w["en"])) if t}
        for f in p["comoFalar"]:
            if elementos(f) > 2:
                fallos.append(f"mes {m}: cómo falar «{f}» con máis de dous elementos")
            if f.lower().strip("!?. ") not in presentadas and not all(
                    t.lower() in tokens for t in re.split(r"[\s,/]+", re.sub(r"[!?.…]", "", f)) if t):
                fallos.append(f"mes {m}: cómo falar «{f}» usa unha palabra non presentada")
        for x in p["xaSabe"]:
            if elementos(x) != 1:
                fallos.append(f"mes {m}: xa debería saber «{x}» non é unha palabra soa")
        if not (p["cancion"].get("gl") and p["cancion"].get("es")):
            fallos.append(f"mes {m}: sen canción")
        if not (p["rima"]["en"] and p["rima"]["gl"] and p["rima"]["es"]):
            fallos.append(f"mes {m}: sen rima")
        sem1 = p["semanas"][0]
        if not sem1["palabras"] or "canción" not in sem1["fase"]["es"]:
            fallos.append(f"mes {m}: a semana 1 non empeza polo vocabulario e a canción")
        if [w for s in p["semanas"] for w in s["palabras"]] != [w["en"] for w in p["palabras"]]:
            fallos.append(f"mes {m}: as catro semanas non reparten as palabras do proxecto")
    return fallos


def main() -> int:
    d = construir()
    fallos = revisar(d)
    texto = json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    if "--check" in sys.argv:
        sig = json.loads((RAIZ / "assets/content/significados/significados.json").read_text(encoding="utf-8"))["significados"]
        for p in d["proxectos"]:
            if p["rima"]["en"] not in sig:
                fallos.append(f"mes {p['mesCalendario']}: a rima sen significado en significados.json")
        if not SAIDA.exists() or SAIDA.read_text(encoding="utf-8") != texto:
            fallos.append(f"{SAIDA.relative_to(RAIZ)} non está ao día: python3 tools/gen_acopros_0_2.py")
    else:
        SAIDA.parent.mkdir(parents=True, exist_ok=True)
        SAIDA.write_text(texto, encoding="utf-8")
        # Las rimas, con su significado en el diccionario de la app (el
        # doble toque en una frase inglesa enseña lo que quiere decir).
        sp = RAIZ / "assets/content/significados/significados.json"
        sig = json.loads(sp.read_text(encoding="utf-8"))
        for p in d["proxectos"]:
            r = p["rima"]
            sig["significados"].setdefault(r["en"], {"gl": r["gl"], "es": r["es"]})
        sp.write_text(json.dumps(sig, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    if fallos:
        print("FALLO (ACOPROS 0-2):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: 10 proxectos de 0-2, ~20 palabras cada un, frases de dous elementos como moito, "
          "sen to be, coa súa canción e a súa rima.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
