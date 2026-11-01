#!/usr/bin/env python3
"""Añade a los cuentos de la semana la página «Y además» de
tools/paxinas_extra_*.py, con las palabras nuevas de la semana que el cuento
no traía (O-20261101-1). Idempotente: no la añade dos veces."""
import importlib
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
F = RAIZ / "assets" / "content" / "cuentos" / "historias_progresivas.json"
sys.path.insert(0, str(RAIZ / "tools"))


def frases(t):
    # Frases, sin cortar dentro de las comillas.
    out, cur, dentro = [], "", False
    for i, ch in enumerate(t):
        cur += ch
        if ch == "“":
            dentro = True
        elif ch == "”":
            dentro = False
        if not dentro and ch in ".!?" and (i + 1 == len(t) or t[i + 1] == " "):
            out.append(cur.strip())
            cur = ""
    if cur.strip():
        out.append(cur.strip())
    return out


def anacos(gl, es, maximo=4):
    """La página partida en trozos de como mucho `maximo` palabras entre
    comillas, por frases, igual en gl y en es."""
    fg, fe = frases(gl), frases(es)
    if len(fg) != len(fe):
        return [(gl, es)]
    out, g, e = [], [], []
    for a, b in zip(fg, fe):
        n = len(re.findall(r"“", a))
        if g and len(re.findall(r"“", " ".join(g))) + n > maximo:
            out.append((" ".join(g), " ".join(e)))
            g, e = [], []
        g.append(a)
        e.append(b)
    out.append((" ".join(g), " ".join(e)))
    return out


def main(edades):
    lec = json.loads((RAIZ / "assets/content/leccions/leccions.json").read_text())["cursos"]
    sig = {}
    for c in lec.values():
        for u in c["unidades"]:
            for l in u["leccions"]:
                for p in l["novas"]:
                    sig.setdefault(p["en"].strip().lower().rstrip(".!?,"), (p.get("gl"), p.get("es")))
    raw = F.read_text(encoding="utf-8")
    contos = json.loads(raw)
    por_id = {c["id"]: c for c in contos}
    for ed in edades:
        for cid, (gl, es) in importlib.import_module(f"paxinas_extra_{ed}").PAXINAS.items():
            c = por_id[cid]
            if any(p.get("extra") for p in c["paginas"]):
                continue
            ult = c["paginas"][-1]
            for tg, te in anacos(gl, es):
                palabras = re.findall(r"“([^”]+)”", tg)
                claves = [w.strip().lower().rstrip(".!?,") for w in palabras]
                c["paginas"].append({"numero": c["paginas"][-1]["numero"] + 1,
                                     "tituloPagina": {"gl": "E ademais", "es": "Y además"},
                                     "lamina": ult["lamina"], "extra": True,
                                     "texto": {"gl": tg, "es": te}, "palabras": palabras,
                                     "vocabularioClave": [sig.get(k, (None, None))[0] for k in claves],
                                     "vocabularioClaveEs": [sig.get(k, (None, None))[1] for k in claves]})
    F.write_text(json.dumps(contos, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main(sys.argv[1:] or ["4_5"])
