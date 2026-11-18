#!/usr/bin/env python3
"""Utilidades compartidas para generar las láminas de todas las edades (O-20261111-4).

Proporciona:
  - Carga de SVG de Fluent Emoji Flat (MIT) y sets permitidos de Iconify.
  - Escalado/espejado de formas vectoriales en lienzo 160x100.
  - Fondos y figuras articuladas en estilo plano Lúa (nino, bebe, frecha, etc.).
  - Registro uniforme en assets/content/laminas/palabras_laminas.json.
"""
from __future__ import annotations

import json
import math
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

import banco_a_lamina as bal  # noqa: E402
from gen_laminas_palabras import (  # noqa: E402
    E,
    F,
    HERBA,
    HERBAB,
    L,
    P,
    PEL,
    PELB,
    R,
    TINTA,
    frecha,
    nino,
    sol,
    tubo,
)

LAMINAS_DIR = RAIZ / "assets/brand/laminas"
MAPA_PATH = RAIZ / "assets/content/laminas/palabras_laminas.json"
LECCIONS_PATH = RAIZ / "assets/content/leccions/leccions.json"
ACOPROS_PATH = RAIZ / "assets/content/acopros/proxectos_0_2.json"

FLUENT_ROOT = Path("/tmp/banco_src/fluentui-emoji/assets")
ICONIFY_ROOT = Path("/tmp/banco_src/iconify/json")

SHA_FLUENT = "1ffb34c752ecf5d402f04cfb4b392c77f57c54bc"
SHA_ICONIFY = "81ad501f19cc13e548e4cb6a9c63a3873c87262a"
SHA_PROPIA = "6be3d38b"

ICONIFY_LICENCIA = {
    "fluent": "MIT",
    "tabler": "MIT",
    "healthicons": "MIT",
    "material-symbols": "Apache-2.0",
    "mdi": "Apache-2.0",
    "noto": "Apache-2.0",
    "game-icons": "CC-BY-3.0",
}

# Colores auxiliares
AGUA = "#38bdf8"
AGUA_OSCURO = "#0284c7"
MAR_PROF = "#1e3a8a"
TIERRA = "#b45309"
TIERRA_CLARA = "#d97706"
BARRO = "#78350f"
MADERA = "#c27c3e"
MADERA_OSCURA = "#7c471b"
AMARILLO = "#facc15"
AMARILLO_OSCURO = "#ca8a04"
ROJO = "#ef4444"
ROJO_OSCURO = "#991b1b"
VERDE = "#22c55e"
VERDE_OSCURO = "#15803d"
AZUL = "#3b82f6"
AZUL_OSCURO = "#1e3a8a"
MORADO = "#8b5cf6"
NUBE = "#f1f5f9"
NUBE_B = "#94a3b8"
GRIS = "#cbd5e1"
GRIS_OSCURO = "#475569"
BLANCO = "#ffffff"


def _cargar_fluent_index() -> dict[str, Path]:
    idx: dict[str, Path] = {}
    if not FLUENT_ROOT.is_dir():
        return idx
    for p in FLUENT_ROOT.glob("*/Flat/*.svg"):
        idx[p.parent.parent.name] = p
    for p in FLUENT_ROOT.glob("*/Default/Flat/*.svg"):
        idx.setdefault(p.parent.parent.parent.name, p)
    return idx


FLUENT_SVGS = _cargar_fluent_index()
_FLUENT_CACHE: dict[str, list[dict]] = {}
_ICONIFY_SETS: dict[str, dict] = {}
_ICONIFY_CACHE: dict[tuple[str, str, str], list[dict]] = {}


def _fluent_formas(nombre: str) -> list[dict]:
    if nombre not in _FLUENT_CACHE:
        p = FLUENT_SVGS.get(nombre)
        if not p:
            raise KeyError(f"Fluent Flat no encontrado: {nombre!r}")
        lam = bal.svg_a_lamina(p.read_text(encoding="utf-8"), paleta="exacta")
        _FLUENT_CACHE[nombre] = lam["formas"]
    return _FLUENT_CACHE[nombre]


def _iconify_json(icon_set: str) -> dict:
    if icon_set not in _ICONIFY_SETS:
        jp = ICONIFY_ROOT / f"{icon_set}.json"
        if not jp.is_file():
            jp = ICONIFY_ROOT.parent / f"{icon_set}.json"
        _ICONIFY_SETS[icon_set] = json.loads(jp.read_text(encoding="utf-8"))
    return _ICONIFY_SETS[icon_set]


def _iconify_formas(icon_set: str, icon_name: str, current_color: str = "#1e293b") -> list[dict]:
    key = (icon_set, icon_name, current_color)
    if key not in _ICONIFY_CACHE:
        data = _iconify_json(icon_set)
        ic = data["icons"][icon_name]
        w = ic.get("width") or data.get("width") or 24
        h = ic.get("height") or data.get("height") or 24
        svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">{ic["body"]}</svg>'
        paleta = "exacta" if icon_set in ("noto", "fluent-emoji-flat") else "suave"
        lam = bal.svg_a_lamina(svg, current_color=current_color, paleta=paleta)
        _ICONIFY_CACHE[key] = lam["formas"]
    return _ICONIFY_CACHE[key]


def _num_str(v: float) -> str:
    r = round(v, 2)
    return str(int(r)) if r == int(r) else f"{r:.2f}".rstrip("0").rstrip(".")


def _transformar_d(d: str, dx: float, dy: float, sc: float, flip_x: bool = False) -> str:
    tokens = re.findall(r"[MLQCZ]|-?\d*\.?\d+", d)
    out: list[str] = []
    i = 0
    while i < len(tokens):
        t = tokens[i]
        if t in ("M", "L", "Q", "C", "Z"):
            out.append(t)
            i += 1
            continue
        x = float(tokens[i])
        y = float(tokens[i + 1])
        if flip_x:
            x = 100.0 - x
        out.append(_num_str(dx + x * sc))
        out.append(_num_str(dy + y * sc))
        i += 2
    return " ".join(out)


def _escalar_formas(formas_100: list[dict], dx: float, dy: float, size: float, flip_x: bool = False) -> list[dict]:
    sc = size / 100.0
    formas: list[dict] = []
    for orig in formas_100:
        f = dict(orig)
        tp = f["t"]
        if tp == "elipse":
            cx = (100.0 - f["cx"]) if flip_x else f["cx"]
            f["cx"] = round(dx + cx * sc, 2)
            f["cy"] = round(dy + f["cy"] * sc, 2)
            f["rx"] = round(f["rx"] * sc, 2)
            f["ry"] = round(f["ry"] * sc, 2)
        elif tp == "rrect":
            rx0 = (100.0 - (f["x"] + f["w"])) if flip_x else f["x"]
            f["x"] = round(dx + rx0 * sc, 2)
            f["y"] = round(dy + f["y"] * sc, 2)
            f["w"] = round(f["w"] * sc, 2)
            f["h"] = round(f["h"] * sc, 2)
            if "r" in f:
                f["r"] = round(f["r"] * sc, 2)
        elif tp == "poli":
            pts = []
            for px, py in f["p"]:
                nx = (100.0 - px) if flip_x else px
                pts.append([round(dx + nx * sc, 2), round(dy + py * sc, 2)])
            f["p"] = pts
        elif tp == "ruta":
            f["d"] = _transformar_d(f["d"], dx, dy, sc, flip_x=flip_x)
        if "sw" in f and f["sw"]:
            f["sw"] = round(max(0.6, f["sw"] * sc), 2)
        formas.append(f)
    return formas


def fl(nombre: str, dx: float, dy: float, size: float, flip_x: bool = False) -> list[dict]:
    """Inserta un emoji Fluent Flat (origen 100x100) dentro de [dx, dy, size, size]."""
    return _escalar_formas(_fluent_formas(nombre), dx, dy, size, flip_x=flip_x)


def ico(
    icon_set: str,
    icon_name: str,
    dx: float,
    dy: float,
    size: float,
    current_color: str = "#1e293b",
    flip_x: bool = False,
) -> list[dict]:
    """Inserta un icono de Iconify (normalizado 100x100) dentro de [dx, dy, size, size]."""
    return _escalar_formas(_iconify_formas(icon_set, icon_name, current_color=current_color), dx, dy, size, flip_x=flip_x)


# ── Fondos y motivos comunes ──────────────────────────────────────────────
def fondo_prado() -> list[dict]:
    return [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 74, 160, 26, 0, HERBA), L("M0 74 L160 74", HERBAB, 2.5)]


def fondo_mar() -> list[dict]:
    return [
        R(0, 0, 160, 100, 0, "#e0f2fe"),
        R(0, 60, 160, 40, 0, AGUA),
        L("M0 62 Q20 55 40 62 Q60 69 80 62 Q100 55 120 62 Q140 69 160 62", AGUA_OSCURO, 2.5),
    ]


def fondo_mesa() -> list[dict]:
    return [R(0, 0, 160, 100, 0, "#dbeafe"), R(0, 72, 160, 28, 0, MADERA), L("M0 72 L160 72", MADERA_OSCURA, 2.5)]


def fondo_cielo(color: str = "#e0f2fe") -> list[dict]:
    return [R(0, 0, 160, 100, 0, color)]


def fondo_noite() -> list[dict]:
    return [R(0, 0, 160, 100, 0, "#1e293b"), R(0, 76, 160, 24, 0, "#334155")]


def fondo_sala() -> list[dict]:
    return [R(0, 0, 160, 100, 0, "#fef3c7"), R(0, 76, 160, 24, 0, "#fde68a"), L("M0 76 L160 76", "#d97706", 2)]


def gotas(pts: list[tuple[float, float]]) -> list[dict]:
    o = []
    for gx, gy in pts:
        o.append(F(
            f"M{gx} {gy} C{gx - 3.5} {gy + 5} {gx - 3} {gy + 9} {gx} {gy + 9} "
            f"C{gx + 3} {gy + 9} {gx + 3.5} {gy + 5} {gx} {gy} Z",
            AGUA,
            AGUA_OSCURO,
            1.2,
        ))
    return o


def pano(x: float, y: float, w: float = 34, h: float = 22, color: str = "#fef3c7", borde: str = "#d97706") -> list[dict]:
    return [
        R(x, y, w, h, 4, color, borde, 2.2),
        L(f"M{x + 5} {y + 6} L{x + w - 5} {y + 6}", "#cbd5e1", 1.5),
        L(f"M{x + 5} {y + h - 6} L{x + w - 5} {y + h - 6}", "#cbd5e1", 1.5),
    ]


def copos_nieve(pts: list[tuple[float, float]], color: str = "#0284c7") -> list[dict]:
    o = []
    for x, y in pts:
        o += [
            L(f"M{x - 5} {y} L{x + 5} {y}", color, 2.0),
            L(f"M{x} {y - 5} L{x} {y + 5}", color, 2.0),
            L(f"M{x - 3.5} {y - 3.5} L{x + 3.5} {y + 3.5}", color, 1.6),
            L(f"M{x - 3.5} {y + 3.5} L{x + 3.5} {y - 3.5}", color, 1.6),
        ]
    return o


def notas(pts: list[tuple[float, float]]) -> list[dict]:
    o = []
    for nx, ny in pts:
        o += [E(nx, ny, 3, 2.2, MORADO), L(f"M{nx + 2.5} {ny} L{nx + 2.5} {ny - 9} L{nx + 7} {ny - 7}", MORADO, 2)]
    return o


def molinillo(cx: float, cy: float, r: float = 18) -> list[dict]:
    o = [L(f"M{cx} {cy} L{cx} {cy + r + 16}", MADERA_OSCURA, 3)]
    cols = [(ROJO, ROJO_OSCURO), (AMARILLO, AMARILLO_OSCURO), (AZUL, AZUL_OSCURO), (VERDE, VERDE_OSCURO)]
    for idx, (c, s) in enumerate(cols):
        ang = math.radians(idx * 90 + 25)
        x1 = cx + r * math.cos(ang)
        y1 = cy + r * math.sin(ang)
        x2 = cx + r * 0.72 * math.cos(ang + 0.75)
        y2 = cy + r * 0.72 * math.sin(ang + 0.75)
        o.append(P([(cx, cy), (x1, y1), (x2, y2)], c, s, 1.8))
    o.append(E(cx, cy, 3, 3, BLANCO, TINTA, 1.5))
    return o


def pompas(pts: list[tuple[float, float, float]]) -> list[dict]:
    o = []
    for bx, by, br in pts:
        o.append(E(bx, by, br, br, "#bae6fd", AGUA_OSCURO, 1.5))
        if br >= 5:
            o.append(E(bx - br * 0.35, by - br * 0.35, br * 0.25, br * 0.25, BLANCO))
    return o


def _round_forma(f: dict) -> dict:
    for k in ("cx", "cy", "rx", "ry", "x", "y", "w", "h", "r", "sw"):
        if k in f and isinstance(f[k], float):
            f[k] = round(f[k], 2)
    if "p" in f:
        f["p"] = [[round(a, 2), round(b, 2)] for a, b in f["p"]]
    return f


def slug_de(en: str) -> str:
    s = re.sub(r"[^a-z0-9]+", "_", en.lower()).strip("_")
    return s[:48]


def escribir_fluent_directo(
    pezas: dict,
    k: str,
    slug: str,
    fl_name: str,
    ur: str,
    porque: str,
) -> None:
    clave = f"pal_{slug}"
    svg_path = FLUENT_SVGS[fl_name]
    lam = bal.svg_a_lamina(svg_path.read_text(encoding="utf-8"), paleta="exacta")
    err = bal.validar_lamina_dict(lam, clave)
    if err:
        raise RuntimeError(f"Error en {clave}: {err}")
    (LAMINAS_DIR / f"{clave}.json").write_text(
        json.dumps(lam, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    pezas[k] = {
        "clave": clave,
        "orixe": "banco",
        "porque": porque,
        "fuente": "fluent-flat",
        "asset": f"fluentui-emoji:assets/{fl_name}/Flat",
        "sha": SHA_FLUENT,
        "licencia": "MIT",
        "revisado": True,
    }


def escribir_iconify_directo(
    pezas: dict,
    k: str,
    slug: str,
    icon_set: str,
    icon_name: str,
    ur: str,
    porque: str,
    current_color: str = "#1e293b",
    autor: str = "",
) -> None:
    clave = f"pal_{slug}"
    data = _iconify_json(icon_set)
    ic = data["icons"][icon_name]
    w = ic.get("width") or data.get("width") or 24
    h = ic.get("height") or data.get("height") or 24
    svg = f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">{ic["body"]}</svg>'
    paleta = "exacta" if icon_set == "noto" else "suave"
    lam = bal.svg_a_lamina(svg, current_color=current_color, paleta=paleta)
    err = bal.validar_lamina_dict(lam, clave)
    if err:
        raise RuntimeError(f"Error en {clave}: {err}")
    (LAMINAS_DIR / f"{clave}.json").write_text(
        json.dumps(lam, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    lic = ICONIFY_LICENCIA[icon_set]
    entry = {
        "clave": clave,
        "orixe": "banco",
        "porque": porque,
        "fuente": f"iconify:{icon_set}",
        "asset": f"{icon_set}:{icon_name}",
        "sha": SHA_ICONIFY,
        "licencia": lic,
        "revisado": True,
    }
    if lic in ("CC-BY-3.0", "CC-BY-4.0"):
        entry["autor"] = autor or "GameIcons contributors"
    pezas[k] = entry


def escribir_reutilizada(pezas: dict, k: str, clave: str, porque: str) -> None:
    if not any((LAMINAS_DIR / f"{clave}.{ext}").is_file() for ext in ("json", "webp", "jpg", "jpeg", "png")):
        raise FileNotFoundError(f"Lámina reutilizada inexistente: {clave}")
    pezas[k] = {
        "clave": clave,
        "orixe": "reutilizada",
        "porque": porque,
        "fuente": "propia",
        "asset": f"assets/brand/laminas/{clave}.json",
        "sha": SHA_PROPIA,
        "licencia": "Propia",
        "revisado": True,
    }


def escribir_cd(
    pezas: dict,
    k: str,
    slug: str,
    cd: str,
    formas: list[dict],
    porque: str,
    script_ref: str,
    etiqueta_en: str | None = None,
) -> None:
    clave = f"pal_{slug}"
    nota = f"«{etiqueta_en or k}»: {porque} Sen texto."
    lam = {
        "vb": 160,
        "vh": 100,
        "nota": nota,
        "formas": [_round_forma(dict(f)) for f in formas],
    }
    err = bal.validar_lamina_dict(lam, clave)
    if err:
        raise RuntimeError(f"Error en {clave}: {err}")
    (LAMINAS_DIR / f"{clave}.json").write_text(
        json.dumps(lam, ensure_ascii=False, separators=(",", ":")) + "\n",
        encoding="utf-8",
    )
    pezas[k] = {
        "clave": clave,
        "orixe": "composta" if cd == "C" else "nova",
        "porque": porque,
        "fuente": "composta" if cd == "C" else "propia",
        "asset": f"{script_ref}#{slug}",
        "sha": SHA_FLUENT if cd == "C" else SHA_PROPIA,
        "licencia": "MIT" if cd == "C" else "Propia",
        "revisado": True,
    }
