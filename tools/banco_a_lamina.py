#!/usr/bin/env python3
"""Conversor de bancos permitidos (O-20261111-4) al formato LaminaEscena.

Fuentes permitidas (solo estas):
  1. microsoft/fluentui-emoji (estilo Flat, MIT) -> SVG a JSON vectorial
  2. iconify/icon-sets (solo sets MIT, Apache-2.0, CC0 o game-icons CC BY 3.0) -> SVG a JSON vectorial
  3. dnizfor/vocabulary-flashcard-dataset (MIT) -> imagen raster WebP en assets/brand/laminas/
  4. global-asp/pb-imagebank (CC BY 4.0, solo escenas de apoyo) -> imagen raster JPG en assets/brand/laminas/

Convierte SVG al JSON de lib/core/brand/lamina_vector.dart:
  - H/V (y h/v, S/s, Q/q, T/t, A/a) -> L/Q/C absolutas
  - rect / ellipse / circle -> rrect / elipse (o ruta si rotado)
  - polygon -> poli; polyline / line -> ruta
  - transform (translate/scale/rotate/skew/matrix) cocido en coordenadas absolutas
  - fill-rule="evenodd" -> "fr": "evenodd"
  - paleta armonizada con tools/draw_contos.py y contorno opcional

Uso:
  python3 tools/banco_a_lamina.py --test
  python3 tools/banco_a_lamina.py <svg_entrada> <clave_salida> [--contorno #334155] [--sw 2]
"""
from __future__ import annotations

import argparse
import json
import math
import re
import shutil
import sys
import xml.etree.ElementTree as ET
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from check_laminas import CLAVES_POR_TIPO, HEX, _coordenadas, pares_con_duplicados  # noqa: E402
from draw_contos import (  # noqa: E402
    AMARELO,
    AREA,
    AUGA,
    AZUL_ESCURO,
    BRANCO,
    CEO,
    CEO_GRIS,
    CEO_NOITE,
    CHAN_MADEIRA,
    CREMA,
    FACE,
    HERBA,
    LARANXA,
    LOUSA,
    MADEIRA,
    MAR,
    NEGRO,
    OLLO,
    PELO,
    PERFIL,
    ROSA,
    TERRACOTA,
    VERDE_ESCURO,
    VERMELLO,
    VERMELLO_ESCURO,
)

# Paleta ampliada coherente con tools/draw_contos.py y tools/draw_banco_laminas.py.
PALETA_LUA: tuple[str, ...] = (
    PELO,
    PERFIL,
    CREMA,
    ROSA,
    OLLO,
    NEGRO,
    CEO,
    CEO_GRIS,
    CEO_NOITE,
    HERBA,
    VERDE_ESCURO,
    AREA,
    MAR,
    AUGA,
    CHAN_MADEIRA,
    MADEIRA,
    VERMELLO,
    VERMELLO_ESCURO,
    LARANXA,
    TERRACOTA,
    AMARELO,
    BRANCO,
    LOUSA,
    FACE,
    AZUL_ESCURO,
    "#94a3b8",  # GRIS (draw_banco_laminas.py)
    "#475569",  # GRIS_ESCURO (draw_banco_laminas.py)
    "#7c3aed",  # MORADO (draw_banco_laminas.py)
    "#ec4899",  # ROSA_FORTE (draw_banco_laminas.py)
    "#f59e0b",  # ámbar luminoso
    "#fde047",  # amarillo sol claro
    "#e2e8f0",  # gris muy claro / sombra suave
    "#d8b4fe",  # lila claro
    "#fda4af",  # rosa claro
)

NAMED_COLORS: dict[str, str] = {
    "black": "#181a20",
    "white": "#ffffff",
    "red": "#e62828",
    "green": "#1b7a2b",
    "blue": "#2f6fd0",
    "yellow": "#ffdc00",
    "orange": "#ff851b",
    "pink": "#f472b6",
    "purple": "#7c3aed",
    "brown": "#8b5a2b",
    "gray": "#94a3b8",
    "grey": "#94a3b8",
    "cyan": "#00c4be",
    "silver": "#c5ccd6",
    "navy": "#143a7a",
    "transparent": "none",
}


def _hex_to_rgb(h: str) -> tuple[int, int, int]:
    h = h.lstrip("#")
    return int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)


_PALETA_RGB = [(h, _hex_to_rgb(h)) for h in PALETA_LUA]


def normalizar_color(
    val: str | None,
    *,
    current_color: str = LOUSA,
    opacity: float = 1.0,
    paleta: str = "lua",
) -> str | None:
    if not val:
        return None
    v = val.strip().lower()
    if v in ("none", "transparent"):
        return None
    if v == "currentcolor":
        base = current_color
    elif v in NAMED_COLORS:
        base = NAMED_COLORS[v]
    elif v.startswith("#"):
        h = v[1:]
        if len(h) == 3:
            base = "#" + "".join(c * 2 for c in h)
        elif len(h) == 4:
            r, g, b, a = h[0] * 2, h[1] * 2, h[2] * 2, h[3] * 2
            opacity *= int(a, 16) / 255.0
            base = f"#{r}{g}{b}"
        elif len(h) == 6:
            base = f"#{h}"
        elif len(h) == 8:
            opacity *= int(h[6:8], 16) / 255.0
            base = f"#{h[:6]}"
        else:
            return None
    elif v.startswith("rgb(") and v.endswith(")"):
        parts = [int(float(x.strip())) for x in v[4:-1].split(",")[:3]]
        base = "#{:02x}{:02x}{:02x}".format(*(max(0, min(255, c)) for c in parts))
    elif v.startswith("rgba(") and v.endswith(")"):
        raw = [x.strip() for x in v[5:-1].split(",")]
        parts = [int(float(x)) for x in raw[:3]]
        opacity *= float(raw[3])
        base = "#{:02x}{:02x}{:02x}".format(*(max(0, min(255, c)) for c in parts))
    else:
        return None

    if opacity <= 0.01:
        return None

    if paleta == "lua":
        r, g, b = _hex_to_rgb(base)
        # Ponderación perceptual simple (luminancia / croma) para no colapsar
        # tonos oscuros o pieles hacia el mismo color.
        best_h = base
        best_d = 1e18
        for ph, (pr, pg, pb) in _PALETA_RGB:
            d = 2.0 * (r - pr) ** 2 + 4.0 * (g - pg) ** 2 + 3.0 * (b - pb) ** 2
            if d < best_d:
                best_d = d
                best_h = ph
        base = best_h

    if opacity < 0.995:
        alpha = max(1, min(255, round(opacity * 255)))
        return f"{base}{alpha:02x}"
    return base


# ── Álgebra afín 2D (matrices [a, b, c, d, e, f]: x'=ax+cy+e, y'=bx+dy+f) ────

def _mul(m1: tuple[float, ...], m2: tuple[float, ...]) -> tuple[float, ...]:
    a1, b1, c1, d1, e1, f1 = m1
    a2, b2, c2, d2, e2, f2 = m2
    return (
        a1 * a2 + c1 * b2,
        b1 * a2 + d1 * b2,
        a1 * c2 + c1 * d2,
        b1 * c2 + d1 * d2,
        a1 * e2 + c1 * f2 + e1,
        b1 * e2 + d1 * f2 + f1,
    )


def _apply(m: tuple[float, ...], x: float, y: float) -> tuple[float, float]:
    a, b, c, d, e, f = m
    return a * x + c * y + e, b * x + d * y + f


def _parse_transform(spec: str | None) -> tuple[float, ...]:
    m = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)
    if not spec:
        return m
    for fn, args_s in re.findall(r"([a-zA-Z]+)\s*\(([^)]*)\)", spec):
        nums = [float(x) for x in re.findall(r"[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?", args_s)]
        fn_l = fn.lower()
        t: tuple[float, ...] | None = None
        if fn_l == "translate" and nums:
            tx = nums[0]
            ty = nums[1] if len(nums) > 1 else 0.0
            t = (1.0, 0.0, 0.0, 1.0, tx, ty)
        elif fn_l == "scale" and nums:
            sx = nums[0]
            sy = nums[1] if len(nums) > 1 else sx
            t = (sx, 0.0, 0.0, sy, 0.0, 0.0)
        elif fn_l == "rotate" and nums:
            ang = math.radians(nums[0])
            cs, sn = math.cos(ang), math.sin(ang)
            r = (cs, sn, -sn, cs, 0.0, 0.0)
            if len(nums) >= 3:
                cx, cy = nums[1], nums[2]
                t = _mul(_mul((1.0, 0.0, 0.0, 1.0, cx, cy), r), (1.0, 0.0, 0.0, 1.0, -cx, -cy))
            else:
                t = r
        elif fn_l == "skewx" and nums:
            t = (1.0, 0.0, math.tan(math.radians(nums[0])), 1.0, 0.0, 0.0)
        elif fn_l == "skewy" and nums:
            t = (1.0, math.tan(math.radians(nums[0])), 0.0, 1.0, 0.0, 0.0)
        elif fn_l == "matrix" and len(nums) >= 6:
            t = tuple(nums[:6])
        if t is not None:
            m = _mul(m, t)
    return m


# ── Conversión de arcos elípticos SVG a Beziers cúbicas ─────────────────────────

def _arc_to_beziers(
    x1: float, y1: float, rx: float, ry: float, phi_deg: float,
    fa: int, fs: int, x2: float, y2: float,
) -> list[tuple[float, float, float, float, float, float]]:
    if x1 == x2 and y1 == y2:
        return []
    rx, ry = abs(rx), abs(ry)
    if rx < 1e-9 or ry < 1e-9:
        return [(x1, y1, x2, y2, x2, y2)]

    phi = math.radians(phi_deg % 360.0)
    c_phi, s_phi = math.cos(phi), math.sin(phi)
    dx2, dy2 = (x1 - x2) * 0.5, (y1 - y2) * 0.5
    x1p = c_phi * dx2 + s_phi * dy2
    y1p = -s_phi * dx2 + c_phi * dy2

    lam = (x1p ** 2) / (rx ** 2) + (y1p ** 2) / (ry ** 2)
    if lam > 1.0:
        s_lam = math.sqrt(lam)
        rx *= s_lam
        ry *= s_lam

    rx2, ry2 = rx ** 2, ry ** 2
    x1p2, y1p2 = x1p ** 2, y1p ** 2
    denom = rx2 * y1p2 + ry2 * x1p2
    num = max(0.0, rx2 * ry2 - denom)
    coef = math.sqrt(num / denom) if denom > 1e-12 else 0.0
    if fa == fs:
        coef = -coef
    cxp = coef * (rx * y1p) / ry
    cyp = coef * -(ry * x1p) / rx

    cx = c_phi * cxp - s_phi * cyp + (x1 + x2) * 0.5
    cy = s_phi * cxp + c_phi * cyp + (y1 + y2) * 0.5

    def vec_angle(ux: float, uy: float, vx: float, vy: float) -> float:
        dot = ux * vx + uy * vy
        mag = math.hypot(ux, uy) * math.hypot(vx, vy)
        ang = math.acos(max(-1.0, min(1.0, dot / mag))) if mag > 1e-12 else 0.0
        return -ang if (ux * vy - uy * vx) < 0 else ang

    theta1 = vec_angle(1.0, 0.0, (x1p - cxp) / rx, (y1p - cyp) / ry)
    dtheta = vec_angle((x1p - cxp) / rx, (y1p - cyp) / ry, (-x1p - cxp) / rx, (-y1p - cyp) / ry)
    if fs == 0 and dtheta > 0:
        dtheta -= 2 * math.pi
    elif fs == 1 and dtheta < 0:
        dtheta += 2 * math.pi

    segs = max(1, int(math.ceil(abs(dtheta) / (math.pi * 0.5))))
    delta = dtheta / segs
    t_const = (4.0 / 3.0) * math.tan(delta * 0.25)
    out = []
    for k in range(segs):
        t1 = theta1 + k * delta
        t2 = t1 + delta
        st1, ct1 = math.sin(t1), math.cos(t1)
        st2, ct2 = math.sin(t2), math.cos(t2)
        p1x, p1y = ct1 - t_const * st1, st1 + t_const * ct1
        p2x, p2y = ct2 + t_const * st2, st2 - t_const * ct2
        p3x, p3y = ct2, st2

        def back(px: float, py: float) -> tuple[float, float]:
            ex, ey = rx * px, ry * py
            return c_phi * ex - s_phi * ey + cx, s_phi * ex + c_phi * ey + cy

        c1x, c1y = back(p1x, p1y)
        c2x, c2y = back(p2x, p2y)
        ex, ey = back(p3x, p3y)
        out.append((c1x, c1y, c2x, c2y, ex, ey))
    return out


# ── Parser de rutas SVG -> lista de tokens absolutos M/L/Q/C/Z ──────────────

_NUM_RE = re.compile(r"[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?")


def _tokenize_path(d: str) -> list[str]:
    """Tokeniza `d` respetando los flags de arco `A`/`a` sin espacios (p.ej. `010`)."""
    tokens: list[str] = []
    i, n = 0, len(d)
    cmd = ""
    arc_param_idx = 0
    while i < n:
        ch = d[i]
        if ch in " \t\r\n,":
            i += 1
            continue
        if ch.isalpha():
            tokens.append(ch)
            cmd = ch
            arc_param_idx = 0
            i += 1
            continue
        if cmd in ("A", "a") and (arc_param_idx % 7) in (3, 4) and ch in ("0", "1"):
            tokens.append(ch)
            arc_param_idx += 1
            i += 1
            continue
        m = _NUM_RE.match(d, i)
        if not m:
            i += 1
            continue
        tokens.append(m.group(0))
        if cmd in ("A", "a"):
            arc_param_idx += 1
        i = m.end()
    return tokens


def _path_a_absoluto(d: str, m: tuple[float, ...]) -> str:
    """Normaliza cualquier ruta SVG a `M`, `L`, `Q`, `C`, `Z` absolutas y transformadas."""
    toks = _tokenize_path(d)
    out: list[str] = []
    idx, total = 0, len(toks)
    cx, cy = 0.0, 0.0
    sx, sy = 0.0, 0.0
    last_ctrl_c: tuple[float, float] | None = None
    last_ctrl_q: tuple[float, float] | None = None
    cmd = ""

    def fmt(v: float) -> str:
        r = round(v, 2)
        if abs(r) < 1e-9:
            r = 0.0
        return str(int(r)) if r == int(r) else f"{r:.2f}".rstrip("0").rstrip(".")

    def emit(letter: str, *pts: tuple[float, float]) -> None:
        coords = []
        for px, py in pts:
            tx, ty = _apply(m, px, py)
            coords.append(f"{fmt(tx)} {fmt(ty)}")
        out.append(letter + " ".join(coords))

    def has_num(k: int = 1) -> bool:
        return idx + k <= total and not toks[idx].isalpha()

    def fnum() -> float:
        nonlocal idx
        v = float(toks[idx])
        idx += 1
        return v

    while idx < total:
        if toks[idx].isalpha():
            cmd = toks[idx]
            idx += 1
            if cmd in ("Z", "z"):
                out.append("Z")
                cx, cy = sx, sy
                last_ctrl_c = last_ctrl_q = None
                continue
        else:
            if not cmd:
                idx += 1
                continue
            if cmd == "M":
                cmd = "L"
            elif cmd == "m":
                cmd = "l"

        up = cmd.upper()
        rel = cmd.islower()

        if up == "M":
            if not has_num(2):
                break
            x, y = fnum(), fnum()
            if rel:
                x, y = cx + x, cy + y
            cx, cy = x, y
            sx, sy = x, y
            emit("M", (x, y))
            last_ctrl_c = last_ctrl_q = None
        elif up == "L":
            if not has_num(2):
                break
            x, y = fnum(), fnum()
            if rel:
                x, y = cx + x, cy + y
            cx, cy = x, y
            emit("L", (x, y))
            last_ctrl_c = last_ctrl_q = None
        elif up == "H":
            if not has_num(1):
                break
            x = fnum()
            if rel:
                x = cx + x
            cx = x
            emit("L", (cx, cy))
            last_ctrl_c = last_ctrl_q = None
        elif up == "V":
            if not has_num(1):
                break
            y = fnum()
            if rel:
                y = cy + y
            cy = y
            emit("L", (cx, cy))
            last_ctrl_c = last_ctrl_q = None
        elif up == "C":
            if not has_num(6):
                break
            x1, y1, x2, y2, x, y = fnum(), fnum(), fnum(), fnum(), fnum(), fnum()
            if rel:
                x1, y1 = cx + x1, cy + y1
                x2, y2 = cx + x2, cy + y2
                x, y = cx + x, cy + y
            emit("C", (x1, y1), (x2, y2), (x, y))
            last_ctrl_c = (x2, y2)
            last_ctrl_q = None
            cx, cy = x, y
        elif up == "S":
            if not has_num(4):
                break
            x2, y2, x, y = fnum(), fnum(), fnum(), fnum()
            if rel:
                x2, y2 = cx + x2, cy + y2
                x, y = cx + x, cy + y
            x1, y1 = (2 * cx - last_ctrl_c[0], 2 * cy - last_ctrl_c[1]) if last_ctrl_c else (cx, cy)
            emit("C", (x1, y1), (x2, y2), (x, y))
            last_ctrl_c = (x2, y2)
            last_ctrl_q = None
            cx, cy = x, y
        elif up == "Q":
            if not has_num(4):
                break
            x1, y1, x, y = fnum(), fnum(), fnum(), fnum()
            if rel:
                x1, y1 = cx + x1, cy + y1
                x, y = cx + x, cy + y
            emit("Q", (x1, y1), (x, y))
            last_ctrl_q = (x1, y1)
            last_ctrl_c = None
            cx, cy = x, y
        elif up == "T":
            if not has_num(2):
                break
            x, y = fnum(), fnum()
            if rel:
                x, y = cx + x, cy + y
            x1, y1 = (2 * cx - last_ctrl_q[0], 2 * cy - last_ctrl_q[1]) if last_ctrl_q else (cx, cy)
            emit("Q", (x1, y1), (x, y))
            last_ctrl_q = (x1, y1)
            last_ctrl_c = None
            cx, cy = x, y
        elif up == "A":
            if not has_num(7):
                break
            rx, ry, phi = fnum(), fnum(), fnum()
            fa, fs = int(fnum()), int(fnum())
            x, y = fnum(), fnum()
            if rel:
                x, y = cx + x, cy + y
            for c1x, c1y, c2x, c2y, ex, ey in _arc_to_beziers(cx, cy, rx, ry, phi, fa, fs, x, y):
                emit("C", (c1x, c1y), (c2x, c2y), (ex, ey))
            cx, cy = x, y
            last_ctrl_c = last_ctrl_q = None
        else:
            break

    return " ".join(out)


def _is_axis_aligned(m: tuple[float, ...]) -> bool:
    _, b, c, _, _, _ = m
    return abs(b) < 1e-6 and abs(c) < 1e-6


def _n(v: float) -> int | float:
    r = round(v, 2)
    if abs(r) < 1e-9:
        r = 0.0
    return int(r) if r == int(r) else r


def _collect_gradients(root: ET.Element) -> dict[str, str]:
    grads: dict[str, str] = {}
    for el in root.iter():
        tag = el.tag.split("}")[-1]
        if tag in ("linearGradient", "radialGradient") and "id" in el.attrib:
            gid = el.attrib["id"]
            for child in el:
                if child.tag.split("}")[-1] == "stop":
                    sc = child.attrib.get("stop-color")
                    if not sc and "style" in child.attrib:
                        for part in child.attrib["style"].split(";"):
                            if part.strip().startswith("stop-color:"):
                                sc = part.split(":", 1)[1].strip()
                    if sc:
                        grads[gid] = sc
                        break
    return grads


def _resolve_paint(
    val: str | None,
    grads: dict[str, str],
    *,
    current_color: str,
    opacity: float,
    paleta: str,
) -> str | None:
    if not val:
        return None
    v = val.strip()
    if v.startswith("url(#") and v.endswith(")"):
        gid = v[5:-1]
        v = grads.get(gid, "#94a3b8")
    return normalizar_color(v, current_color=current_color, opacity=opacity, paleta=paleta)


def _parse_style_attr(el: ET.Element) -> dict[str, str]:
    out = dict(el.attrib)
    style = out.get("style", "")
    if style:
        for item in style.split(";"):
            if ":" in item:
                k, v = item.split(":", 1)
                out.setdefault(k.strip(), v.strip())
    return out


def svg_a_lamina(
    svg_text: str,
    *,
    vb_destino: float = 100.0,
    vh_destino: float | None = None,
    pad: float = 4.0,
    paleta: str = "lua",
    contorno: str | None = None,
    contorno_sw: float = 0.0,
    current_color: str = LOUSA,
) -> dict:
    root = ET.fromstring(svg_text)
    if vh_destino is None:
        vh_destino = vb_destino

    raw_vb = root.attrib.get("viewBox")
    if raw_vb:
        parts = [float(x) for x in re.split(r"[\s,]+", raw_vb.strip()) if x]
        vx, vy, vw, vh = parts[0], parts[1], parts[2], parts[3]
    else:
        vx, vy = 0.0, 0.0
        vw = float(re.sub(r"[a-zA-Z]+$", "", root.attrib.get("width", "100")))
        vh = float(re.sub(r"[a-zA-Z]+$", "", root.attrib.get("height", "100")))

    escala = min((vb_destino - 2 * pad) / vw, (vh_destino - 2 * pad) / vh)
    ox = (vb_destino - vw * escala) * 0.5 - vx * escala
    oy = (vh_destino - vh * escala) * 0.5 - vy * escala
    base_m = (escala, 0.0, 0.0, escala, ox, oy)

    grads = _collect_gradients(root)
    formas: list[dict] = []

    default_state = {
        "fill": root.attrib.get("fill", "#000000"),
        "fill-rule": root.attrib.get("fill-rule", "nonzero"),
        "stroke": root.attrib.get("stroke", "none"),
        "stroke-width": root.attrib.get("stroke-width", "1"),
        "opacity": float(root.attrib.get("opacity", "1")),
        "fill-opacity": float(root.attrib.get("fill-opacity", "1")),
    }

    def walk(el: ET.Element, m: tuple[float, ...], st: dict) -> None:
        tag = el.tag.split("}")[-1]
        if tag in ("defs", "clipPath", "mask", "filter", "linearGradient", "radialGradient", "title", "desc"):
            return
        attrs = _parse_style_attr(el)
        cur_m = _mul(m, _parse_transform(attrs.get("transform")))
        cur_st = dict(st)
        for k in ("fill", "fill-rule", "stroke", "stroke-width"):
            if k in attrs and attrs[k]:
                cur_st[k] = attrs[k]
        if "opacity" in attrs:
            try:
                cur_st["opacity"] = st["opacity"] * float(attrs["opacity"])
            except ValueError:
                pass
        if "fill-opacity" in attrs:
            try:
                cur_st["fill-opacity"] = float(attrs["fill-opacity"])
            except ValueError:
                pass

        if tag == "g" or tag == "svg":
            for child in el:
                walk(child, cur_m, cur_st)
            return

        fill = _resolve_paint(
            cur_st["fill"], grads,
            current_color=current_color,
            opacity=cur_st["opacity"] * cur_st["fill-opacity"],
            paleta=paleta,
        )
        stroke = _resolve_paint(
            cur_st["stroke"], grads,
            current_color=current_color,
            opacity=cur_st["opacity"],
            paleta=paleta,
        )
        try:
            raw_sw = float(re.sub(r"[a-zA-Z]+$", "", str(cur_st["stroke-width"])))
        except ValueError:
            raw_sw = 1.0
        scale_avg = (math.hypot(cur_m[0], cur_m[1]) + math.hypot(cur_m[2], cur_m[3])) * 0.5
        sw = round(max(1.2, min(8.0, raw_sw * scale_avg)), 2) if stroke else 0.0

        if not fill and not (stroke and sw > 0):
            return

        def finish(forma: dict) -> None:
            if fill:
                forma["f"] = fill
                if cur_st["fill-rule"].strip().lower() == "evenodd":
                    forma["fr"] = "evenodd"
            if stroke and sw > 0:
                forma["s"] = stroke
                forma["sw"] = _n(sw)
            elif contorno and contorno_sw > 0 and fill and forma.get("t") != "ruta":
                forma["s"] = contorno
                forma["sw"] = _n(contorno_sw)
            elif contorno and contorno_sw > 0 and fill:
                forma["s"] = contorno
                forma["sw"] = _n(contorno_sw)
            formas.append(forma)

        if tag == "path":
            d = _path_a_absoluto(attrs.get("d", ""), cur_m)
            if d:
                finish({"t": "ruta", "d": d})
        elif tag == "rect":
            x = float(attrs.get("x", 0))
            y = float(attrs.get("y", 0))
            w = float(attrs.get("width", 0))
            h = float(attrs.get("height", 0))
            if w <= 0 or h <= 0:
                return
            rx = float(attrs.get("rx", attrs.get("ry", 0)))
            if _is_axis_aligned(cur_m):
                x0, y0 = _apply(cur_m, x, y)
                x1, y1 = _apply(cur_m, x + w, y + h)
                nx, ny = min(x0, x1), min(y0, y1)
                nw, nh = abs(x1 - x0), abs(y1 - y0)
                nr = min(rx * abs(cur_m[0]), nw * 0.5, nh * 0.5)
                forma = {"t": "rrect", "x": _n(nx), "y": _n(ny), "w": _n(nw), "h": _n(nh)}
                if nr > 0.05:
                    forma["r"] = _n(nr)
                finish(forma)
            else:
                pts = [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
                finish({"t": "poli", "p": [[_n(px), _n(py)] for px, py in (_apply(cur_m, *p) for p in pts)]})
        elif tag in ("circle", "ellipse"):
            cx = float(attrs.get("cx", 0))
            cy = float(attrs.get("cy", 0))
            if tag == "circle":
                rx = ry = float(attrs.get("r", 0))
            else:
                rx = float(attrs.get("rx", 0))
                ry = float(attrs.get("ry", 0))
            if rx <= 0 or ry <= 0:
                return
            if _is_axis_aligned(cur_m):
                tcx, tcy = _apply(cur_m, cx, cy)
                trx = abs(rx * cur_m[0])
                try_ = abs(ry * cur_m[3])
                finish({"t": "elipse", "cx": _n(tcx), "cy": _n(tcy), "rx": _n(trx), "ry": _n(try_)})
            else:
                k = 0.5522847498
                d = (
                    f"M {cx + rx} {cy} "
                    f"C {cx + rx} {cy + k * ry} {cx + k * rx} {cy + ry} {cx} {cy + ry} "
                    f"C {cx - k * rx} {cy + ry} {cx - rx} {cy + k * ry} {cx - rx} {cy} "
                    f"C {cx - rx} {cy - k * ry} {cx - k * rx} {cy - ry} {cx} {cy - ry} "
                    f"C {cx + k * rx} {cy - ry} {cx + rx} {cy - k * ry} {cx + rx} {cy} Z"
                )
                finish({"t": "ruta", "d": _path_a_absoluto(d, cur_m)})
        elif tag == "polygon":
            raw_pts = [float(v) for v in re.findall(r"[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?", attrs.get("points", ""))]
            pts = [(_apply(cur_m, raw_pts[j], raw_pts[j + 1])) for j in range(0, len(raw_pts) - 1, 2)]
            if len(pts) >= 2:
                finish({"t": "poli", "p": [[_n(px), _n(py)] for px, py in pts]})
        elif tag == "polyline":
            raw_pts = [float(v) for v in re.findall(r"[-+]?(?:\d*\.\d+|\d+)(?:[eE][-+]?\d+)?", attrs.get("points", ""))]
            if len(raw_pts) >= 4:
                segs = [f"M{raw_pts[0]} {raw_pts[1]}"] + [f"L{raw_pts[j]} {raw_pts[j + 1]}" for j in range(2, len(raw_pts) - 1, 2)]
                finish({"t": "ruta", "d": _path_a_absoluto(" ".join(segs), cur_m)})
        elif tag == "line":
            x1, y1 = float(attrs.get("x1", 0)), float(attrs.get("y1", 0))
            x2, y2 = float(attrs.get("x2", 0)), float(attrs.get("y2", 0))
            finish({"t": "ruta", "d": _path_a_absoluto(f"M{x1} {y1} L{x2} {y2}", cur_m)})

    walk(root, base_m, default_state)
    out = {"vb": _n(vb_destino), "formas": formas}
    if vh_destino != vb_destino:
        out["vh"] = _n(vh_destino)
    return out


def icono_iconify_a_svg(set_json_path: Path, icon_name: str) -> str:
    data = json.loads(set_json_path.read_text(encoding="utf-8"))
    ic = data["icons"][icon_name]
    w = ic.get("width") or data.get("width") or 24
    h = ic.get("height") or data.get("height") or 24
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {w} {h}">{ic["body"]}</svg>'


def copiar_raster_banco(src: Path, clave: str, destino_dir: Path | None = None) -> Path:
    dest_dir = destino_dir or (RAIZ / "assets/brand/laminas")
    ext = src.suffix.lower()
    if ext not in (".webp", ".jpg", ".jpeg", ".png"):
        raise ValueError(f"Formato raster no soportado: {src}")
    out = dest_dir / f"{clave}{ext}"
    shutil.copy2(src, out)
    return out


def validar_lamina_dict(datos: dict, nombre: str = "<mem>") -> list[str]:
    raw = json.dumps(datos, ensure_ascii=False)
    parsed = json.loads(raw, object_pairs_hook=pares_con_duplicados)
    fallos: list[str] = []
    ancho = parsed.get("vb", 100)
    alto = parsed.get("vh", ancho)
    formas = parsed.get("formas") or []
    if not formas:
        fallos.append(f"{nombre}: sin formas")
    for i, forma in enumerate(formas):
        tipo = forma.get("t")
        if tipo not in CLAVES_POR_TIPO:
            fallos.append(f"{nombre}[{i}]: tipo desconocido {tipo!r}")
            continue
        faltan = CLAVES_POR_TIPO[tipo] - set(forma)
        if faltan:
            fallos.append(f"{nombre}[{i}]: faltan {faltan}")
        for k in ("f", "s"):
            c = forma.get(k)
            if c is not None and not HEX.match(str(c)):
                fallos.append(f"{nombre}[{i}]: {k} color inválido {c!r}")
        if forma.get("f") is None and not (forma.get("s") and (forma.get("sw") or 0) > 0):
            fallos.append(f"{nombre}[{i}]: forma invisible")
        xs, ys = _coordenadas(forma, tipo)
        if any(v < -6 or v > ancho + 6 for v in xs) or any(v < -6 or v > alto + 6 for v in ys):
            fallos.append(f"{nombre}[{i}]: fuera del lienzo {ancho}x{alto}")
        if tipo == "ruta" and re.search(r"[HVhvSsTtAa]", str(forma.get("d", ""))):
            fallos.append(f"{nombre}[{i}]: ruta aún contiene H/V/S/T/A")
    return fallos


def _self_test() -> int:
    fluent_root = Path("/tmp/banco_src/fluentui-emoji/assets")
    iconify_root = Path("/tmp/banco_src/iconify")
    if not fluent_root.is_dir() or not iconify_root.is_dir():
        print("FALTA /tmp/banco_src/ (clona o descarga fluentui-emoji y iconify para --test)")
        return 1

    # 20 SVGs reales de Fluent Flat, incluyendo casos con rect, circle, ellipse, transform y evenodd.
    muestras_fluent = [
        "Red apple", "Bear", "Airplane", "Alarm clock", "Backpack",
        "Bicycle", "Open book", "Bread", "Paintbrush", "Billed cap",
        "Camera", "Camping", "Twelve oclock", "Cloud", "Compass",
        "Cookie", "Scissors", "Envelope", "Balloon", "Umbrella",
    ]
    all_svgs = {p.parent.parent.name: p for p in fluent_root.glob("*/Flat/*.svg")}
    for p in fluent_root.glob("*/Default/Flat/*.svg"):
        all_svgs.setdefault(p.parent.parent.parent.name, p)
    fallos: list[str] = []
    ok_fluent = 0
    evenodd_vistos = 0
    rrect_vistos = 0
    elipse_vistos = 0

    for nombre in muestras_fluent:
        p = all_svgs.get(nombre)
        if not p:
            fallos.append(f"Fluent Flat: no encontrado {nombre}")
            continue
        lam = svg_a_lamina(p.read_text(encoding="utf-8"))
        err = validar_lamina_dict(lam, f"fluent:{nombre}")
        if err:
            fallos.extend(err)
        else:
            ok_fluent += 1
            for f in lam["formas"]:
                if f.get("fr") == "evenodd":
                    evenodd_vistos += 1
                if f.get("t") == "rrect":
                    rrect_vistos += 1
                if f.get("t") == "elipse":
                    elipse_vistos += 1

    # Prueba adicional con transform + rect + ellipse + evenodd explícito
    sintetico = (
        '<svg viewBox="0 0 32 32" xmlns="http://www.w3.org/2000/svg">'
        '<g transform="translate(2, 2)">'
        '<rect x="2" y="2" width="12" height="8" rx="2" fill="#2f6fd0"/>'
        '<ellipse cx="20" cy="18" rx="6" ry="4" fill="#ffdc00"/>'
        '<path d="M4 16 H20 V26 H4 Z M8 19 H16 V23 H8 Z" fill="#e62828" fill-rule="evenodd"/>'
        '</g></svg>'
    )
    lam_syn = svg_a_lamina(sintetico, contorno="#334155", contorno_sw=2)
    fallos.extend(validar_lamina_dict(lam_syn, "sintetico_svg"))

    # 5 SVGs de Iconify (sets permitidos MIT / Apache-2.0 / CC0 / CC-BY-3.0)
    muestras_iconify = [
        ("tabler", "acorn"),
        ("game-icons", "seahorse"),
        ("material-symbols", "wash"),
        ("noto", "snail"),
        ("healthicons", "arm-outline"),
    ]
    ok_iconify = 0
    for set_name, icon_name in muestras_iconify:
        jp = iconify_root / f"{set_name}.json"
        d = json.loads(jp.read_text(encoding="utf-8"))
        if icon_name not in d["icons"]:
            icon_name = sorted(d["icons"].keys())[0]
        svg = icono_iconify_a_svg(jp, icon_name)
        lam = svg_a_lamina(svg)
        err = validar_lamina_dict(lam, f"iconify:{set_name}:{icon_name}")
        if err:
            fallos.extend(err)
        else:
            ok_iconify += 1

    if fallos:
        print("FALLO banco_a_lamina --test:\n  " + "\n  ".join(fallos))
        return 1
    print(
        f"OK: {ok_fluent} SVG Fluent Flat + {ok_iconify} SVG Iconify + caso sintético transform/evenodd "
        f"(formas: evenodd={evenodd_vistos}, rrect={rrect_vistos}, elipse={elipse_vistos})."
    )
    return 0


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("entrada", nargs="?")
    ap.add_argument("salida", nargs="?")
    ap.add_argument("--test", action="store_true")
    ap.add_argument("--paleta", choices=("lua", "exacta"), default="lua")
    ap.add_argument("--contorno", default=None)
    ap.add_argument("--sw", type=float, default=0.0)
    args = ap.parse_args()

    if args.test:
        return _self_test()
    if not args.entrada or not args.salida:
        ap.print_help()
        return 2

    src = Path(args.entrada)
    if src.suffix.lower() in (".webp", ".jpg", ".jpeg", ".png"):
        dest = copiar_raster_banco(src, args.salida)
        print(f"OK raster -> {dest.relative_to(RAIZ)}")
        return 0

    lam = svg_a_lamina(
        src.read_text(encoding="utf-8"),
        paleta=args.paleta,
        contorno=args.contorno,
        contorno_sw=args.sw,
    )
    err = validar_lamina_dict(lam, args.salida)
    if err:
        print("\n".join(err), file=sys.stderr)
        return 1
    dest = RAIZ / "assets/brand/laminas" / f"{args.salida}.json"
    dest.write_text(json.dumps(lam, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"OK vector -> {dest.relative_to(RAIZ)} ({len(lam['formas'])} formas)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
