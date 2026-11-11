#!/usr/bin/env python3
"""O-20261111-2: una lámina por cada palabra o frase que se enseña.

Cada lámina dibuja ESA palabra y su gesto (no la escena del reto), en el
formato vectorial del set (assets/brand/laminas/, lienzo 160×100), sin texto
ni emoji. Las que ya existían en el set solo se reutilizan si coinciden de
verdad, y se dice por qué.

Escribe:
- assets/brand/laminas/pal_<slug>.json: las láminas nuevas;
- assets/content/laminas/palabras_laminas.json: palabra → lámina, si es nueva
  o reutilizada, y por qué coincide. De ahí leen tools/gen_leccions.py y
  tools/gen_acopros_0_2.py el campo "lamina" de cada pieza;
- el campo "lamina" en assets/content/tpr/**/*.json;
- docs/laminas-ejercicios.md: una fila por pieza.

Uso: python3 tools/gen_laminas_palabras.py [--check]"""
from __future__ import annotations

import json
import math
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LAMINAS = RAIZ / "assets/brand/laminas"
MAPA = RAIZ / "assets/content/laminas/palabras_laminas.json"
CONTROL = RAIZ / "docs/laminas-ejercicios.md"
CONTIDO = RAIZ / "assets/content"

PEL = "#f5c9a0"   # piel
PELB = "#b9794a"  # borde de la piel
TINTA = "#334155"
HERBA, HERBAB = "#86c96a", "#3f8f3a"


def clave_de(en: str) -> str:
    return en.lower().strip(" .!?")


# ── Piezas de dibujo ─────────────────────────────────────────────────────
def E(cx, cy, rx, ry, f=None, s=None, sw=0):
    d = {"t": "elipse", "cx": cx, "cy": cy, "rx": rx, "ry": ry}
    if f: d["f"] = f
    if s: d["s"], d["sw"] = s, sw or 3
    return d


def R(x, y, w, h, r=0, f=None, s=None, sw=0):
    d = {"t": "rrect", "x": x, "y": y, "w": w, "h": h, "r": r}
    if f: d["f"] = f
    if s: d["s"], d["sw"] = s, sw or 3
    return d


def P(pts, f=None, s=None, sw=0):
    d = {"t": "poli", "p": [list(p) for p in pts]}
    if f: d["f"] = f
    if s: d["s"], d["sw"] = s, sw or 3
    return d


def L(d, s, sw, f=None):
    o = {"t": "ruta", "d": d, "s": s, "sw": sw}
    if f: o["f"] = f
    return o


def F(d, f, s=None, sw=0):
    o = {"t": "ruta", "d": d, "f": f}
    if s: o["s"], o["sw"] = s, sw or 3
    return o


def tubo(pts, cor, borde, sw):
    """Un miembro: trazo grueso de punta redonda, con su contorno."""
    d = "M" + " L".join(f"{x:g} {y:g}" for x, y in pts)
    return [L(d, borde, sw + 3), L(d, cor, sw)]


def nino(cab, ombro, cadeira, brazos, pernas, camisa=("#ef4444", "#991b1b"),
         pelo="#5a3a1a", r=9, mira=1, ollos="abertos", pantalon=("#2563eb", "#1e3a8a")):
    """Un niño: piernas, tronco, brazos y cabeza. `brazos` y `pernas` son
    líneas quebradas que salen del hombro y de la cadera; `mira` es 1 si
    mira a la derecha y -1 a la izquierda."""
    o = []
    for p in pernas:
        o += tubo([cadeira, *p], *pantalon, 6)
        px, py = p[-1]
        o.append(E(px + 2 * mira, py, 5, 3, "#1f2937"))
    if len(brazos) > 1:
        o += tubo([ombro, *brazos[1]], PEL, PELB, 4)
    o += tubo([ombro, cadeira], *camisa, 13)
    o += tubo([ombro, *brazos[0]], PEL, PELB, 4)
    cx, cy = cab
    o.append(E(cx, cy, r, r, PEL, PELB, 2.5))
    o.append(F(f"M{cx - r} {cy - 1} C{cx - r} {cy - r - 6} {cx + r} {cy - r - 6} {cx + r} {cy - 1} "
               f"C{cx + r * .3} {cy - r * .75} {cx - r * .3} {cy - r * .75} {cx - r} {cy - 1} Z", pelo))
    if ollos == "abertos":
        o.append(E(cx + 3 * mira - 3, cy + 1, 1.3, 1.6, "#1f2937"))
        o.append(E(cx + 3 * mira + 3, cy + 1, 1.3, 1.6, "#1f2937"))
        o.append(L(f"M{cx + 3 * mira - 3} {cy + 5} Q{cx + 3 * mira} {cy + 7.5} {cx + 3 * mira + 3} {cy + 5}", "#9a3412", 1.5))
    else:
        o.append(L(f"M{cx + 3 * mira - 4} {cy + 2} Q{cx + 3 * mira - 2} {cy + 4} {cx + 3 * mira} {cy + 2}", "#1f2937", 1.5))
    return o


def frecha(a, b, cor="#ffffff", sw=4):
    (x1, y1), (x2, y2) = a, b
    t = math.atan2(y2 - y1, x2 - x1)
    p = lambda ang, n: (round(x2 + n * math.cos(t + ang), 1), round(y2 + n * math.sin(t + ang), 1))
    return [L(f"M{x1} {y1} L{x2} {y2}", cor, sw), P([p(0, 7), p(2.4, 7), p(-2.4, 7)], cor)]


def sol(cx=138, cy=18):
    return [E(cx, cy, 9, 9, "#fde047", "#ca8a04", 2.5)]


# ── Los dibujos ──────────────────────────────────────────────────────────
def ourizo():
    o = []
    for g in range(195, 356, 16):  # las púas, en abanico sobre el lomo
        a, b, m = math.radians(g - 7), math.radians(g + 7), math.radians(g)
        o.append(P([(88 + 40 * math.cos(a), 72 + 30 * math.sin(a)), (88 + 40 * math.cos(b), 72 + 30 * math.sin(b)),
                    (88 + 54 * math.cos(m), 72 + 43 * math.sin(m))], "#5a3a1a", "#3b2410", 2))
    o.append(F("M46 80 C44 30 132 30 132 80 Z", "#5a3a1a"))  # el pelaje bajo las púas
    o.append(F("M48 80 C44 40 132 36 130 80 Z", "#8b5a2b", "#4a2c11", 3))
    o.append(F("M26 74 C34 56 58 54 64 80 L34 80 Z", "#f3d9b1", "#4a2c11", 3))
    o += [E(25, 73, 3.5, 3.5, "#1f2937"), E(44, 66, 2.2, 2.6, "#1f2937")]
    o += [E(60, 82, 6, 3.5, "#f3d9b1", "#4a2c11", 2.5), E(112, 82, 6, 3.5, "#f3d9b1", "#4a2c11", 2.5)]
    o.append(L("M10 86 L150 86", HERBAB, 3))
    return o


def esperame():
    o = [L("M6 90 L154 90", HERBAB, 3)]
    # la que va delante se gira a mirar; el de atrás corre con la mano tendida
    o += nino((120, 34), (120, 47), (120, 66), [[(110, 58)], [(130, 58)]], [[(114, 86)], [(127, 86)]],
              camisa=("#22c55e", "#15803d"), pelo="#1f2937", mira=-1)
    o += nino((42, 36), (45, 49), (42, 66), [[(60, 46), (70, 40)], [(34, 60)]], [[(52, 76), (58, 86)], [(32, 78), (24, 84)]],
              mira=1)
    o.append(E(72, 38, 3.5, 4.5, PEL, PELB, 2))  # la mano abierta: «espera»
    o += [L("M82 52 L90 52", "#94a3b8", 3), L("M96 52 L104 52", "#94a3b8", 3)]
    return o


def cima():
    o = sol()
    o.append(F("M0 100 Q80 22 160 100 Z", HERBA, HERBAB, 3))
    o += nino((80, 22), (80, 34), (80, 48), [[(70, 26), (66, 12)], [(90, 26), (94, 12)]], [[(76, 61)], [(85, 61)]])
    o += [E(30, 22, 12, 6, "#ffffff", "#cbd5e1", 2), E(40, 26, 10, 5, "#ffffff", "#cbd5e1", 2)]
    return o


def bola():
    o = [E(82, 88, 62, 7, "#e2e8f0")]
    o += tubo([(58, 84), (102, 84)], "#2563eb", "#1e3a8a", 7)       # las espinillas, en el suelo
    o.append(E(54, 84, 6, 3.5, "#1f2937"))
    o += tubo([(64, 72), (100, 78)], "#2563eb", "#1e3a8a", 8)       # los muslos, recogidos
    o.append(F("M58 76 C52 42 98 36 110 60 L102 78 Z", "#ef4444", "#991b1b", 3))  # el lomo, redondo
    o.append(E(114, 68, 12, 12, PEL, PELB, 2.5))                    # la cabeza, metida
    o.append(F("M102 64 C102 50 124 50 127 66 C120 58 110 57 102 64 Z", "#5a3a1a"))
    o.append(L("M114 72 Q117 74.5 120 72", "#1f2937", 1.5))         # ojos cerrados
    o += tubo([(98, 58), (106, 80), (86, 86)], PEL, PELB, 4)        # el brazo abraza las piernas
    return o


def costa_abaixo():
    o = sol(22, 16)
    o.append(P([(0, 30), (160, 84), (160, 100), (0, 100)], HERBA, HERBAB, 3))
    o += nino((86, 14), (84, 26), (80, 42), [[(94, 34)], [(72, 36)]], [[(90, 50), (92, 59)], [(72, 48), (70, 53)]])
    o += frecha((98, 76), (134, 88))
    return o


def empinado():
    o = [P([(34, 100), (116, 8), (160, 8), (160, 100)], HERBA, HERBAB, 3)]
    o += [L("M70 70 L76 62", HERBAB, 2.5), L("M92 44 L98 36", HERBAB, 2.5), L("M124 40 L132 34", HERBAB, 2.5),
          L("M110 76 L118 70", HERBAB, 2.5)]
    # abajo, pequeño, mira hacia arriba y señala la cuesta
    o.append(L("M2 96 L40 96", HERBAB, 3))
    o += nino((16, 62), (16, 72), (16, 82), [[(24, 64), (30, 56)], [(10, 80)]], [[(12, 93)], [(21, 93)]], r=7)
    return o


def laranxa_vivo():
    o = [L("M8 92 L120 92", "#94a3b8", 3)]
    o += nino((56, 36), (56, 49), (56, 68), [[(74, 44), (86, 34)], [(46, 60)]], [[(50, 90)], [(63, 90)]],
              camisa=("#3b82f6", "#1e3a8a"), pantalon=("#64748b", "#334155"))
    # una pelota naranja vivo, con su costura y su brillo (sin rayos: no es un sol)
    o += [E(100, 26, 15, 15, "#ff7a00", "#c2410c", 3), L("M87 30 C96 20 106 34 114 22", "#ffd8a8", 3),
          E(94, 19, 4, 2.5, "#ffe8cc")]
    return o


def venda():
    o = [P([(92, 62), (146, 76), (146, 90), (92, 76)], "#fdf6e3", "#a8a29e", 3)]
    for x in range(100, 142, 8):
        y = 62 + (x - 92) * 14 / 54
        o.append(L(f"M{x} {y + 2:.1f} L{x} {y + 12:.1f}", "#d6d3d1", 1.5))
    o.append(R(48, 30, 46, 46, 5, "#fdf6e3", "#a8a29e", 3))
    for y in (40, 50, 60, 70):
        o.append(L(f"M58 {y} L92 {y}", "#d6d3d1", 1.5))
    o += [E(48, 53, 13, 23, "#ffffff", "#a8a29e", 3), E(48, 53, 8, 15, None, "#d6d3d1", 2), E(48, 53, 3, 6, "#e7e5e4")]
    o += [R(128, 76, 12, 5, 2, "#94a3b8", "#475569", 1.5)]
    return o


def paxaro_duas_patas():
    o = [L("M20 88 L140 88", HERBAB, 3)]
    o += tubo([(70, 60), (70, 86)], "#f97316", "#9a3412", 4) + tubo([(92, 60), (92, 86)], "#f97316", "#9a3412", 4)
    for x in (70, 92):
        o.append(L(f"M{x - 7} 88 L{x} 84 L{x + 7} 88", "#9a3412", 3))
    o.append(P([(58, 40), (36, 28), (42, 50)], "#2563eb", "#1e3a8a", 3))
    o.append(E(80, 44, 28, 21, "#3b82f6", "#1e3a8a", 3))
    o.append(E(108, 28, 13, 13, "#3b82f6", "#1e3a8a", 3))
    o.append(P([(119, 24), (132, 29), (119, 34)], "#fbbf24", "#b45309", 2.5))
    o += [E(111, 25, 2.2, 2.6, "#1f2937"), E(74, 46, 15, 9, "#2563eb", "#1e3a8a", 2.5)]
    return o


# palabra → (slug, dibujo, por qué coincide). Reutilizadas: (clave existente, None, por qué).
DEBUXOS = {
    "hedgehog": ("ourizo", ourizo, "Un erizo de perfil, con sus púas, el hocico y las patas."),
    "wait for me": ("esperame", esperame, "Un niño corre detrás con la mano tendida y la de delante se gira a mirarlo."),
    "hilltop": ("cima", cima, "Un niño en lo más alto del monte, con los brazos estirados hacia arriba: el gesto."),
    "curl into a ball": ("bola", bola, "Un niño enroscado en el suelo, hecho una bola, abrazándose las piernas: el gesto."),
    "downhill": ("costa_abaixo", costa_abaixo, "Un niño camina cuesta abajo y una flecha marca la bajada."),
    "steep": ("empinado", empinado, "Una cuesta muy empinada y, abajo, un niño pequeño que la señala hacia arriba."),
    "bright orange": ("laranxa_vivo", laranxa_vivo, "Un niño enseña en alto una pelota de color naranja vivo: el gesto."),
    "bandage": ("venda", venda, "Un rollo de venda con la tira a medio desenrollar y su cierre."),
    "i said the bird had two": ("paxaro_duas_patas", paxaro_duas_patas, "Un pájaro de pie sobre sus dos patas, bien visibles."),
}


def pezas_ensinadas():
    """(onde, en, gl, es, xesto_es) de cada pieza que se enseña."""
    lec = json.loads((CONTIDO / "leccions/leccions.json").read_text(encoding="utf-8"))
    for c in lec["cursos"].values():
        for u in c["unidades"]:
            for l in u["leccions"]:
                for k in ("xaSabe", "novas", "repasa"):
                    for p in l.get(k) or []:
                        yield f"{l['id']} {k}", p["en"], p.get("gl", ""), p.get("es", ""), (p.get("xesto") or {}).get("es", "")
                f = l.get("fraseGramatica")
                if f:
                    yield f"{l['id']} frase", f["en"], f.get("gl", ""), f.get("es", ""), ""
    for fich in sorted((CONTIDO / "tpr").rglob("*.json")):
        for s in json.loads(fich.read_text(encoding="utf-8")).get("semanas") or []:
            for w in s.get("palabras") or []:
                yield f"tpr {w.get('id', '')}", w["en"], w.get("gl", ""), w.get("es", ""), (w.get("tprAction") or {}).get("es", "")
    for p in json.loads((CONTIDO / "acopros/proxectos_0_2.json").read_text(encoding="utf-8"))["proxectos"]:
        for w in p["palabras"]:
            yield f"0-2 mes {p['mesCalendario']}", w["en"], w.get("gl", ""), w.get("es", ""), (w.get("xesto") or {}).get("es", "")


def construir():
    laminas, mapa = {}, {}
    for k, (slug, debuxo, porque) in sorted(DEBUXOS.items()):
        if debuxo is None:
            mapa[k] = {"clave": slug, "orixe": "reutilizada", "porque": porque}
            continue
        clave = f"pal_{slug}"
        formas = []
        for f in debuxo():
            for c in ("cx", "cy", "rx", "ry", "x", "y", "w", "h"):
                if c in f:
                    f[c] = round(f[c], 2)
            if "p" in f:
                f["p"] = [[round(a, 1), round(b, 1)] for a, b in f["p"]]
            formas.append(f)
        laminas[clave] = {"vb": 160, "vh": 100, "nota": f"«{k}»: {porque} Sen texto.", "formas": formas}
        mapa[k] = {"clave": clave, "orixe": "nova", "porque": porque}
    return laminas, {"_doc": "Xerado por tools/gen_laminas_palabras.py (O-20261111-2). Non se edita a man.",
                     "pezas": mapa}


def texto_control(mapa) -> str:
    filas, sen, vistas = [], 0, set()
    for onde, en, gl, es, xesto in pezas_ensinadas():
        k = clave_de(en)
        if k in vistas:
            continue
        vistas.add(k)
        m = mapa["pezas"].get(k)
        if not m:
            sen += 1
            continue
        filas.append(f"| {en} | {gl} | {es} | {xesto or '—'} | `{m['clave']}` | {m['orixe']} | {m['porque']} |")
    out = ["# Láminas de los ejercicios (O-20261111-2)", "",
           "Generado por `tools/gen_laminas_palabras.py`. Una fila por palabra o frase que se enseña "
           "(lección paso a paso, palabras del día, TPR y proyecto de 0-2) y que ya tiene su lámina.", "",
           f"Con lámina: {len(filas)}. **Sin lámina todavía: {sen}** (las cuenta y las nombra "
           "`python3 tools/check_laminas_leccion.py`).", "",
           "| Palabra (en) | gl | es | Gesto | Lámina | Nueva o reutilizada | Por qué coincide |",
           "| --- | --- | --- | --- | --- | --- | --- |", *sorted(filas, key=str.lower)]
    return "\n".join(out) + "\n"


def tpr_con_laminas(mapa):
    """Cada fichero del banco, con el campo "lamina" en las palabras que la tienen."""
    for fich in sorted((CONTIDO / "tpr").rglob("*.json")):
        orix = fich.read_text(encoding="utf-8")
        d = json.loads(orix)
        cambio = False
        for s in d.get("semanas") or []:
            for w in s.get("palabras") or []:
                m = mapa["pezas"].get(clave_de(w["en"]))
                if m and w.get("lamina") != m["clave"]:
                    w["lamina"], cambio = m["clave"], True
                elif not m and "lamina" in w:
                    del w["lamina"]
                    cambio = True
        if cambio:
            # se conserva el formato del fichero: mismo sangrado que tenía
            sangria = len(re.search(r"\n( +)\"", orix).group(1)) if re.search(r"\n( +)\"", orix) else 2
            yield fich, json.dumps(d, ensure_ascii=False, indent=sangria) + ("\n" if orix.endswith("\n") else "")


def main() -> int:
    laminas, mapa = construir()
    fallos = []
    textos = {c: json.dumps(v, ensure_ascii=False, indent=1) + "\n" for c, v in laminas.items()}
    js = json.dumps(mapa, ensure_ascii=False, indent=1) + "\n"
    for m in mapa["pezas"].values():
        if m["orixe"] == "reutilizada" and not (LAMINAS / f"{m['clave']}.json").is_file():
            fallos.append(f"a lámina reutilizada {m['clave']} non existe")
        if m["clave"].startswith("escena_"):
            fallos.append(f"{m['clave']} é unha lámina de escena de reto")
    if "--check" in sys.argv:
        for c, t in textos.items():
            p = LAMINAS / f"{c}.json"
            if not p.exists() or p.read_text(encoding="utf-8") != t:
                fallos.append(f"{p.relative_to(RAIZ)} non está ao día")
        if not MAPA.exists() or MAPA.read_text(encoding="utf-8") != js:
            fallos.append(f"{MAPA.relative_to(RAIZ)} non está ao día")
        for fich, _ in tpr_con_laminas(mapa):
            fallos.append(f"{fich.relative_to(RAIZ)} sen as súas láminas ao día")
        md = texto_control(mapa)
        if not CONTROL.exists() or CONTROL.read_text(encoding="utf-8") != md:
            fallos.append(f"{CONTROL.relative_to(RAIZ)} non está ao día")
    else:
        for c, t in textos.items():
            (LAMINAS / f"{c}.json").write_text(t, encoding="utf-8")
        MAPA.write_text(js, encoding="utf-8")
        for fich, t in tpr_con_laminas(mapa):
            fich.write_text(t, encoding="utf-8")
    if fallos:
        print("FALLO (láminas das palabras):\n  " + "\n  ".join(fallos[:30]))
        return 1
    if "--check" not in sys.argv:
        print("Agora: python3 tools/gen_leccions.py && python3 tools/gen_acopros_0_2.py && "
              "python3 tools/gen_laminas_palabras.py --control")
    if "--control" in sys.argv:
        CONTROL.write_text(texto_control(mapa), encoding="utf-8")
    novas = sum(1 for m in mapa["pezas"].values() if m["orixe"] == "nova")
    print(f"OK: {len(mapa['pezas'])} palabras con lámina ({novas} novas, {len(mapa['pezas']) - novas} reutilizadas).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
