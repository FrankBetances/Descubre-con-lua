#!/usr/bin/env python3
"""O-20261119-8: trae de Valeria los bancos de escucha y palabras.

Fuente: FrankBetances/Valeria (commit en FUENTE_COMMIT):
  src/valeriaMinimalPairs.ts, …Gl.ts, …En.ts       → pares
  src/valeriaSemanticExpansion.ts, …Gl.ts, …En.ts  → escenarios, categorías,
                                                     progresiones y cápsulas

Escribe assets/content/escoita/valeria_<gl|es|en>.json. Se adapta así:
  - sin emoji: cada palabra lleva la clave de su lámina (o null si falta);
  - sin reconocedor de voz: se quita «Di: …» / «Say: …» de las frases y las
    listas de pronunciaciones esperadas; el niño escucha y señala;
  - sin las etiquetas técnicas del error: se quitan el nombre del error y las
    etiquetas de grupo (Rotacismo, Fronting…), que la app no enseña.

Uso: python3 tools/importar_valeria_escoita.py /ruta/a/valeria
Necesita node (solo para leer los .ts). El resultado se commitea; la app no
depende de este script ni de node.
"""
from __future__ import annotations

import glob
import json
import re
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SAIDA = RAIZ / "assets/content/escoita"
GLOSAS = json.loads((RAIZ / "tools/valeria_escoita/glosas.json").read_text(encoding="utf-8"))
ARRAYS = RAIZ / "tools/valeria_escoita/arrays.js"
LAMINAS = {Path(f).stem for f in glob.glob(str(RAIZ / "assets/brand/laminas/*.json"))}

FICHEROS = {
    "es": ("valeriaMinimalPairs.ts", "MINIMAL_PAIRS", "valeriaSemanticExpansion.ts", ""),
    "gl": ("valeriaMinimalPairsGl.ts", "MINIMAL_PAIRS_GL", "valeriaSemanticExpansionGl.ts", "_GL"),
    "en": ("valeriaMinimalPairsEn.ts", "MINIMAL_PAIRS_EN", "valeriaSemanticExpansionEn.ts", "_EN"),
}
SEM = ("DAILY_SCENARIOS", "LEXICAL_CATEGORIES", "PROGRESSION_SEQUENCES", "CONTRAST_CAPSULES")


def ler(valeria: Path, fichero: str, *nomes: str) -> dict:
    out = subprocess.run(["node", str(ARRAYS), str(valeria / "src" / fichero), *nomes],
                         capture_output=True, text=True, check=True).stdout
    return json.loads(out)


def lamina(palabra: str, lang: str) -> str | None:
    glosa = palabra if lang == "en" else (GLOSAS["gl"].get(palabra) or GLOSAS["es"].get(palabra))
    if not glosa:
        return None
    s = re.sub(r"[^a-z]+", "_", glosa.lower()).strip("_")
    for c in (f"pal_{s}", s, f"pal_pal_{s}", f"flashcard_{s[:1]}_{s}"):
        if c in LAMINAS:
            return c
    return None


def frase(t: str) -> str:
    """Quita la consigna de decir la palabra: la app la dice y el niño señala."""
    return re.sub(r"\s*(Di|Say)\s*:\s*[^.!?]*[.!?]\s*$", "", t or "").strip()


def peza(palabra: str, lang: str, **extra) -> dict:
    return {"palabra": palabra, "lamina": lamina(palabra, lang), **extra}


def _pezas(doc: dict):
    for p in doc["pares"]:
        yield p["a"]
        yield p["b"]
    for k, campo in (("progresions", "fases"), ("capsulas", "voltas"),
                     ("escenarios", "items"), ("categorias", "items")):
        for x in doc[k]:
            yield from x[campo]


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__)
        return 2
    valeria = Path(sys.argv[1])
    commit = subprocess.run(["git", "-C", str(valeria), "rev-parse", "--short=8", "HEAD"],
                            capture_output=True, text=True).stdout.strip()
    SAIDA.mkdir(parents=True, exist_ok=True)
    for lang, (fp, np_, fs, suf) in FICHEROS.items():
        pares = ler(valeria, fp, np_)[np_]
        sem = ler(valeria, fs, *(n + suf for n in SEM))
        esc, cat, prog, cap = (sem[n + suf] for n in SEM)
        doc = {
            "_doc": "Copiado de Valeria y adaptado (O-20261119-8): sin emoji, sin reconocedor de voz, sin las etiquetas técnicas del error. Lo genera tools/importar_valeria_escoita.py; no se edita a mano.",
            "fuente": {"repo": "FrankBetances/Valeria", "commit": commit,
                       "ficheros": [f"src/{fp}", f"src/{fs}"]},
            "lingua": lang,
            "pares": [{
                "id": p["id"],
                "a": peza(p["target"], lang),
                "b": peza(p["foil"], lang),
                "fonema": p["phoneme"],
                "pista": p["onFoil"]["cue"],
                "misionAcerto": p["onTarget"]["mission"],
                "misionFallo": p["onFoil"]["mission"],
                **({"soDistincion": True} if p.get("region") == "distincion" else {}),
            } for p in pares],
            "progresions": [{
                "id": s["id"], "tema": s["theme"],
                "fases": [peza(f["label"], lang, tipo=f["kind"], frase=frase(f["tts_string"]),
                               accion=f["parent_tpr_action"]) for f in s["phases"]],
            } for s in prog],
            "capsulas": [{
                "id": c["id"], "tipo": c["kind"], "montaxe": c["physical_setup"],
                "voltas": [peza(r["label"], lang, frase=frase(r["tts_trigger"]),
                                accion=r["parent_action"]) for r in c["rounds"]],
            } for c in cap],
            "escenarios": [{
                "id": e["id"], "titulo": e["title"], "subtitulo": e.get("subtitle", ""),
                "items": [peza(i["label"], lang, frase=frase(i.get("tts_string", "")),
                               accion=i.get("parent_tpr_action", "")) for i in e["items"]],
            } for e in esc],
            "categorias": [{
                "id": c["id"], "titulo": c["title"], "subtitulo": c.get("subtitle", ""),
                "items": [peza(i["label"], lang, frase=frase(i.get("tts_string", "")),
                               accion=i.get("parent_tpr_action", "")) for i in c["items"]],
            } for c in cat],
        }
        (SAIDA / f"valeria_{lang}.json").write_text(
            json.dumps(doc, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        sen = sorted({x["palabra"] for x in _pezas(doc) if not x["lamina"]})
        print(f"{lang}: {len(doc['pares'])} pares, {len(doc['progresions'])} progresións, "
              f"{len(doc['capsulas'])} cápsulas, {len(doc['escenarios'])} escenarios, "
              f"{len(doc['categorias'])} categorías; sen lámina: {len(sen)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
