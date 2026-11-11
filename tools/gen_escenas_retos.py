#!/usr/bin/env python3
"""O-20261111-1: una imagen por cada escena de los retos de casa.

Las 12 escenas (`reto.escena` en leccions.json y en unidades_mes) se dibujan
como láminas vectoriales del set propio (assets/brand/laminas/), sin texto ni
emoji. Cada escena es la SUMA de sus objetos: los que ya tenían lámina (oso,
xabon, toalla, manta, mochila, botas, abrigo, mazan, laranxa) se reutilizan
tal cual, recolocados y escalados; los que no la tenían se dibujan aquí, en el
mismo estilo (contorno redondo de 3-4, colores planos).

Escribe:
- assets/brand/laminas/escena_<id>.json (lienzo 160×100)
- assets/content/escenas/escenas.json (texto gl/es → lámina y etiqueta)
- docs/imagenes-escenas.md (control: escena, texto, lámina, objetos)

Uso: python3 tools/gen_escenas_retos.py [--check]"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LAMINAS = RAIZ / "assets/brand/laminas"
SAIDA = RAIZ / "assets/content/escenas/escenas.json"
CONTROL = RAIZ / "docs/imagenes-escenas.md"
CONTORNO = "#334155"

# ── Objetos nuevos, en un lienzo de 100 ──────────────────────────────────
NOVOS: dict[str, list[dict]] = {
    "vaso": [  # vaso de plástico transparente, azul claro
        {"t": "poli", "p": [[28, 22], [72, 22], [65, 88], [35, 88]], "f": "#cfe8ff", "s": "#2f6fd0", "sw": 4},
        {"t": "rrect", "x": 25, "y": 18, "w": 50, "h": 8, "r": 4, "f": "#e6f3ff", "s": "#2f6fd0", "sw": 4},
        {"t": "ruta", "d": "M36 32 L40 80", "s": "#ffffffcc", "sw": 4},
    ],
    "esponxa": [  # esponja amarilla con la capa verde de frotar
        {"t": "rrect", "x": 12, "y": 40, "w": 76, "h": 40, "r": 10, "f": "#ffd54a", "s": "#b7791f", "sw": 4},
        {"t": "rrect", "x": 12, "y": 30, "w": 76, "h": 14, "r": 6, "f": "#2ecc40", "s": "#1b7a2b", "sw": 4},
        {"t": "elipse", "cx": 30, "cy": 58, "rx": 4, "ry": 3, "f": "#d9a21b"},
        {"t": "elipse", "cx": 52, "cy": 66, "rx": 5, "ry": 3.5, "f": "#d9a21b"},
        {"t": "elipse", "cx": 70, "cy": 54, "rx": 3.5, "ry": 3, "f": "#d9a21b"},
    ],
    "bolsa_tea": [  # bolsa de tela con dos asas
        {"t": "ruta", "d": "M34 42 C34 14 66 14 66 42", "s": "#8b6b3e", "sw": 5},
        {"t": "rrect", "x": 20, "y": 40, "w": 60, "h": 50, "r": 8, "f": "#ecdcb8", "s": "#8b6b3e", "sw": 4},
        {"t": "ruta", "d": "M26 48 L74 48", "s": "#c9ad7c", "sw": 3},
    ],
    "caixa": [  # caja de cartón abierta
        {"t": "poli", "p": [[16, 44], [6, 30], [42, 30], [50, 44]], "f": "#e0ac6e", "s": "#7a4b1e", "sw": 4},
        {"t": "poli", "p": [[84, 44], [94, 30], [58, 30], [50, 44]], "f": "#e0ac6e", "s": "#7a4b1e", "sw": 4},
        {"t": "rrect", "x": 16, "y": 44, "w": 68, "h": 44, "r": 3, "f": "#d49a5a", "s": "#7a4b1e", "sw": 4},
        {"t": "ruta", "d": "M50 44 L50 88", "s": "#b07a3c", "sw": 3},
    ],
    "pelota": [  # pelota roja con su franja
        {"t": "elipse", "cx": 50, "cy": 55, "rx": 33, "ry": 33, "f": "#ef4444", "s": "#991b1b", "sw": 4},
        {"t": "ruta", "d": "M19 46 C38 36 62 74 82 62", "s": "#ffffff", "sw": 7},
    ],
    "bloque_vermello": [{"t": "rrect", "x": 20, "y": 20, "w": 60, "h": 60, "r": 6, "f": "#ef4444", "s": "#991b1b", "sw": 4}],
    "bloque_azul": [{"t": "rrect", "x": 20, "y": 20, "w": 60, "h": 60, "r": 6, "f": "#3b82f6", "s": "#1e3a8a", "sw": 4}],
    "envase": [  # envase vacío de yogur
        {"t": "poli", "p": [[26, 30], [74, 30], [66, 88], [34, 88]], "f": "#ffffff", "s": "#64748b", "sw": 4},
        {"t": "rrect", "x": 22, "y": 22, "w": 56, "h": 10, "r": 4, "f": "#a3e635", "s": "#4d7c0f", "sw": 4},
    ],
    "prato": [  # plato visto de lado
        {"t": "elipse", "cx": 50, "cy": 60, "rx": 42, "ry": 14, "f": "#ffffff", "s": "#64748b", "sw": 4},
        {"t": "elipse", "cx": 50, "cy": 58, "rx": 26, "ry": 7, "f": "#eef2f7", "s": "#94a3b8", "sw": 2},
    ],
    "vaso_verdade": [  # vaso de cristal
        {"t": "poli", "p": [[32, 26], [68, 26], [64, 86], [36, 86]], "f": "#e2f2fb", "s": "#475569", "sw": 4},
        {"t": "ruta", "d": "M40 36 L42 78", "s": "#ffffffcc", "sw": 4},
    ],
    "culler": [  # cuchara
        {"t": "ruta", "d": "M50 42 L50 92", "s": "#94a3b8", "sw": 7},
        {"t": "elipse", "cx": 50, "cy": 28, "rx": 11, "ry": 16, "f": "#cbd5e1", "s": "#64748b", "sw": 3},
    ],
    "pano": [  # pañuelo doblado, a rayas
        {"t": "poli", "p": [[10, 30], [90, 30], [50, 90]], "f": "#f472b6", "s": "#9d174d", "sw": 4},
        {"t": "ruta", "d": "M24 44 L76 44 M36 60 L64 60", "s": "#fbcfe8", "sw": 4},
    ],
    "papel": [  # papel grande, en blanco
        {"t": "rrect", "x": 8, "y": 14, "w": 84, "h": 72, "r": 3, "f": "#ffffff", "s": "#94a3b8", "sw": 3},
        {"t": "poli", "p": [[80, 86], [92, 86], [92, 74]], "f": "#e2e8f0", "s": "#94a3b8", "sw": 3},
    ],
    "cera": [  # una cera de un solo color (azul)
        {"t": "rrect", "x": 20, "y": 42, "w": 56, "h": 16, "r": 4, "f": "#2563eb", "s": "#1e3a8a", "sw": 4},
        {"t": "poli", "p": [[76, 42], [92, 50], [76, 58]], "f": "#1d4ed8", "s": "#1e3a8a", "sw": 4},
        {"t": "ruta", "d": "M30 42 L30 58 M64 42 L64 58", "s": "#93c5fd", "sw": 3},
    ],
    "peluche_corpo": [  # cuerpo de peluche sentado; la cabeza es la lámina oso
        {"t": "elipse", "cx": 24, "cy": 70, "rx": 10, "ry": 14, "f": "#8b5a2b", "s": "#4a2c11", "sw": 4},
        {"t": "elipse", "cx": 76, "cy": 70, "rx": 10, "ry": 14, "f": "#8b5a2b", "s": "#4a2c11", "sw": 4},
        {"t": "elipse", "cx": 50, "cy": 74, "rx": 26, "ry": 22, "f": "#8b5a2b", "s": "#4a2c11", "sw": 4},
        {"t": "elipse", "cx": 50, "cy": 78, "rx": 14, "ry": 13, "f": "#c89666"},
        {"t": "elipse", "cx": 32, "cy": 92, "rx": 12, "ry": 7, "f": "#8b5a2b", "s": "#4a2c11", "sw": 4},
        {"t": "elipse", "cx": 68, "cy": 92, "rx": 12, "ry": 7, "f": "#8b5a2b", "s": "#4a2c11", "sw": 4},
    ],
    "manta_dobrada": [  # manta doblada, a cuadros, sin cama
        {"t": "rrect", "x": 8, "y": 50, "w": 84, "h": 40, "r": 10, "f": "#9b51e0", "s": "#5a208a", "sw": 4},
        {"t": "rrect", "x": 14, "y": 30, "w": 72, "h": 30, "r": 10, "f": "#b57ce8", "s": "#5a208a", "sw": 4},
        {"t": "ruta", "d": "M38 30 L38 60 M62 30 L62 60 M14 45 L86 45", "s": "#f472b6", "sw": 3},
        {"t": "ruta", "d": "M30 50 L30 90 M50 50 L50 90 M70 50 L70 90 M8 70 L92 70", "s": "#f472b6", "sw": 3},
    ],
    "billete": [  # billete hecho a mano: papel con borde de picos y dibujos, sin letras
        {"t": "rrect", "x": 8, "y": 28, "w": 84, "h": 44, "r": 4, "f": "#fde68a", "s": "#b45309", "sw": 4},
        {"t": "ruta", "d": "M70 28 L70 72", "s": "#b45309", "sw": 3},
        {"t": "poli", "p": [[38, 36], [42, 46], [53, 46], [44, 53], [48, 64], [38, 57], [28, 64], [32, 53], [23, 46], [34, 46]],
         "f": "#f97316", "s": "#9a3412", "sw": 2},
        {"t": "elipse", "cx": 81, "cy": 50, "rx": 5, "ry": 5, "f": "#22c55e", "s": "#15803d", "sw": 2},
    ],
}

# ── Las 12 escenas: texto exacto del contenido y lo que lleva la imagen ──
# capa: (objeto, x, y, escala, recolor). Un objeto es una lámina existente
# (nombre de fichero) o uno de NOVOS. La escena mide 160×100.
ESCENAS = [
    ("vaso_esponxa", "Un vaso de plástico e unha esponxa", "Un vaso de plástico y una esponja",
     [("vaso", 8, 8, 0.84), ("esponxa", 82, 14, 0.8)], ["1 vaso de plástico", "1 esponja"]),
    ("bolsa_tesouros", "Unha bolsa de tea para os tesouros", "Una bolsa de tela para los tesoros",
     [("bolsa_tea", 30, 2, 0.96)], ["1 bolsa de tela con asas"]),
    ("froita_merenda", "A froita da merenda", "La fruta de la merienda",
     [("mazan", 10, 14, 0.76), ("laranxa", 82, 14, 0.76)], ["1 manzana", "1 naranja"]),
    ("xabon_toalla", "O xabón e a toalla", "El jabón y la toalla",
     [("xabon", 6, 14, 0.8), ("toalla", 72, 8, 0.8)], ["1 jabón", "1 toalla"]),
    ("peluche_manta", "Un peluche de animal e unha manta", "Un peluche de animal y una manta",
     [("peluche_corpo", 6, 6, 0.9), ("oso", 21, 0, 0.6), ("manta_dobrada", 84, 10, 0.72)], ["1 peluche de oso", "1 manta doblada"]),
    ("caixa_pelota", "Unha caixa de cartón e unha pelota", "Una caja de cartón y una pelota",
     [("caixa", 6, 6, 0.9), ("pelota", 92, 30, 0.62)], ["1 caja de cartón", "1 pelota"]),
    ("amorear", "Bloques, caixas ou envases baleiros para amorear", "Bloques, cajas o envases vacíos para apilar",
     [("bloque_vermello", 20, 52, 0.5), ("bloque_azul", 20, 18, 0.5), ("caixa", 66, 40, 0.6),
      ("envase", 118, 46, 0.5)], ["2 bloques apilados (rojo y azul)", "1 caja de cartón", "1 envase vacío"]),
    ("pratos_vasos_culleres", "Pratos, vasos e culleres de verdade", "Platos, vasos y cucharas de verdad",
     [("prato", 2, 34, 0.6), ("prato", 2, 50, 0.6), ("vaso_verdade", 58, 26, 0.5), ("vaso_verdade", 82, 26, 0.5),
      ("culler", 104, 24, 0.52), ("culler", 120, 24, 0.52)], ["2 platos", "2 vasos", "2 cucharas"]),
    ("peluche_pano", "Un peluche e unha venda ou un pano", "Un peluche y una venda o un pañuelo",
     [("peluche_corpo", 8, 6, 0.9), ("oso", 23, 0, 0.6), ("pano", 92, 22, 0.62)], ["1 peluche de oso", "1 pañuelo"]),
    ("chuvasqueiro_botas", "O chuvasqueiro e as botas", "El chubasquero y las botas",
     [("abrigo", 6, 4, 0.9, {"#2ecc40": "#facc15", "#1b7a2b": "#a16207", "#143a7a": "#a16207", "#84cc16": "#fde047"}),
      ("botas", 86, 26, 0.7)], ["1 chubasquero amarillo con capucha", "1 par de botas de agua"]),
    ("papel_cor", "Un papel grande e unha soa cor para compartir", "Un papel grande y un solo color para compartir",
     [("papel", 10, 2, 0.96), ("cera", 104, 30, 0.52)], ["1 papel grande en blanco", "1 cera de un solo color (azul)"]),
    ("mochila_billete", "Unha mochila e un billete feito por vós", "Una mochila y un billete hecho por vosotros",
     [("mochila", 4, 6, 0.86), ("billete", 86, 24, 0.66)], ["1 mochila", "1 billete hecho a mano, sin letras"]),
]

NUM = re.compile(r"-?\d+(?:\.\d+)?")


def objeto(nome: str) -> list[dict]:
    if nome in NOVOS:
        return NOVOS[nome]
    return json.loads((LAMINAS / f"{nome}.json").read_text(encoding="utf-8"))["formas"]


def r(v: float) -> float:
    return round(v, 2)


def mover(f: dict, x: float, y: float, e: float, cor: dict | None) -> dict:
    g = dict(f)
    t = f["t"]
    if t == "elipse":
        g.update(cx=r(x + f["cx"] * e), cy=r(y + f["cy"] * e), rx=r(f["rx"] * e), ry=r(f["ry"] * e))
    elif t == "rrect":
        g.update(x=r(x + f["x"] * e), y=r(y + f["y"] * e), w=r(f["w"] * e), h=r(f["h"] * e), r=r(f.get("r", 0) * e))
    elif t == "poli":
        g["p"] = [[r(x + a * e), r(y + b * e)] for a, b in f["p"]]
    elif t == "ruta":
        nums = [float(n) for n in NUM.findall(f["d"])]
        it = iter(range(len(nums)))
        out = [r((x if i % 2 == 0 else y) + nums[i] * e) for i in it]
        k = iter(out)
        g["d"] = NUM.sub(lambda _m: f"{next(k):g}", f["d"])
    if "sw" in f:
        g["sw"] = r(max(1.5, f["sw"] * e))
    if cor:
        for c in ("f", "s"):
            if g.get(c) in cor:
                g[c] = cor[g[c]]
    return g


def construir():
    laminas, mapa, control = {}, [], []
    for eid, gl, es, capas, obxectos in ESCENAS:
        formas = []
        for capa in capas:
            nome, x, y, e = capa[:4]
            cor = capa[4] if len(capa) > 4 else None
            formas += [mover(f, x, y, e, cor) for f in objeto(nome)]
        clave = f"escena_{eid}"
        laminas[clave] = {"vb": 160, "vh": 100,
                          "nota": f"Escena do reto: {gl} / {es}. Obxectos: {', '.join(obxectos)}. Sen texto.",
                          "formas": formas}
        mapa.append({"clave": clave, "escena": {"gl": gl, "es": es},
                     "etiqueta": {"gl": f"Imaxe: {gl}", "es": f"Imagen: {es}"}, "obxectos": obxectos,
                     "pezas": [c[0] for c in capas]})
        control.append((clave, gl, es, obxectos, [c[0] for c in capas]))
    return laminas, {"_doc": "Xerado por tools/gen_escenas_retos.py (O-20261111-1). Non se edita a man.",
                     "escenas": mapa}, control


def escenas_do_contido() -> dict[str, str]:
    vistas: dict[str, str] = {}
    for f in (RAIZ / "assets/content").rglob("*.json"):
        if "escenas" in f.parts:
            continue
        try:
            d = json.loads(f.read_text(encoding="utf-8"))
        except Exception:
            continue

        def walk(x):
            if isinstance(x, dict):
                e = x.get("escena")
                if isinstance(e, dict) and e.get("gl"):
                    vistas.setdefault(e["gl"], str(f.relative_to(RAIZ)))
                for v in x.values():
                    walk(v)
            elif isinstance(x, list):
                for v in x:
                    walk(v)
        walk(d)
    return vistas


def texto_control(control) -> str:
    out = ["# Imágenes de las escenas de los retos (O-20261111-1)", "",
           "Generado por `tools/gen_escenas_retos.py`. Cada escena del contenido tiene su lámina vectorial, "
           "hecha con las láminas del set propio que ya existían y con objetos nuevos en el mismo estilo. "
           "Sin texto dentro de la imagen y sin emoji. La comprobación dice qué objetos lleva la imagen, "
           "que son los que nombra el texto.", "",
           "| Lámina | Escena (gl) | Escena (es) | La imagen lleva | Piezas | Comprobación |",
           "| --- | --- | --- | --- | --- | --- |"]
    for clave, gl, es, obx, pezas in control:
        out.append(f"| `assets/brand/laminas/{clave}.json` | {gl} | {es} | {'; '.join(obx)} | "
                   f"{', '.join(pezas)} | coincide: los objetos del texto, ni más ni menos |")
    return "\n".join(out) + "\n"


def main() -> int:
    laminas, mapa, control = construir()
    fallos = []
    textos = {c: json.dumps(v, ensure_ascii=False, indent=1) + "\n" for c, v in laminas.items()}
    js = json.dumps(mapa, ensure_ascii=False, indent=1) + "\n"
    md = texto_control(control)
    contido = escenas_do_contido()
    con_imaxe = {e["escena"]["gl"] for e in mapa["escenas"]}
    for gl, f in sorted(contido.items()):
        if gl not in con_imaxe:
            fallos.append(f"a escena «{gl}» ({f}) non ten imaxe")
    pub = (RAIZ / "pubspec.yaml").read_text(encoding="utf-8")
    for d in ("assets/brand/laminas/", "assets/content/escenas/"):
        if f"- {d}" not in pub:
            fallos.append(f"{d} non está en pubspec.yaml")
    if "--check" in sys.argv:
        for c, t in textos.items():
            p = LAMINAS / f"{c}.json"
            if not p.exists() or p.read_text(encoding="utf-8") != t:
                fallos.append(f"{p.relative_to(RAIZ)} non existe ou non está ao día")
        for p, t in ((SAIDA, js), (CONTROL, md)):
            if not p.exists() or p.read_text(encoding="utf-8") != t:
                fallos.append(f"{p.relative_to(RAIZ)} non está ao día: python3 tools/gen_escenas_retos.py")
    else:
        for c, t in textos.items():
            (LAMINAS / f"{c}.json").write_text(t, encoding="utf-8")
        SAIDA.parent.mkdir(parents=True, exist_ok=True)
        SAIDA.write_text(js, encoding="utf-8")
        CONTROL.write_text(md, encoding="utf-8")
    if fallos:
        print("FALLO (imaxes das escenas):\n  " + "\n  ".join(fallos))
        return 1
    print(f"OK: {len(contido)} escenas no contido, todas coa súa imaxe ({len(laminas)} láminas).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
