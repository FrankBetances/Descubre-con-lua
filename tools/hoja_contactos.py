#!/usr/bin/env python3
"""Generador de hojas de contactos visuales para auditoría por edad (O-20261111-4).

Renderiza todas las láminas de un curso (vectores JSON con LaminaEscena y
rasters WebP/JPG/PNG) en rejillas PNG etiquetadas con clave, clasificación y texto.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path
import numpy as np
from PIL import Image, ImageChops, ImageDraw, ImageFont

RAIZ = Path(__file__).resolve().parent.parent
LAMINAS_DIR = RAIZ / "assets/brand/laminas"
MAPA_PATH = RAIZ / "assets/content/laminas/palabras_laminas.json"
LECCIONS_PATH = RAIZ / "assets/content/leccions/leccions.json"


def _parse_rgba(c: str | None) -> tuple[int, int, int, int] | None:
    if not c:
        return None
    h = c.lstrip("#")
    r, g, b = int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16)
    a = int(h[6:8], 16) if len(h) == 8 else 255
    return (r, g, b, a)


def _cubic(p0, p1, p2, p3, n=12):
    pts = []
    for i in range(1, n + 1):
        t = i / n
        mt = 1.0 - t
        pts.append((
            mt**3 * p0[0] + 3 * mt**2 * t * p1[0] + 3 * mt * t**2 * p2[0] + t**3 * p3[0],
            mt**3 * p0[1] + 3 * mt**2 * t * p1[1] + 3 * mt * t**2 * p2[1] + t**3 * p3[1],
        ))
    return pts


def _quad(p0, p1, p2, n=10):
    pts = []
    for i in range(1, n + 1):
        t = i / n
        mt = 1.0 - t
        pts.append((
            mt**2 * p0[0] + 2 * mt * t * p1[0] + t**2 * p2[0],
            mt**2 * p0[1] + 2 * mt * t * p1[1] + t**2 * p2[1],
        ))
    return pts


def _path_to_polys(d: str):
    tokens = re.findall(r"[MLQCZmlqcz]|-?\d*\.?\d+", d)
    polys = []
    cur = []
    pos = (0.0, 0.0)
    start = (0.0, 0.0)
    i = 0
    cmd = None
    while i < len(tokens):
        t = tokens[i]
        if re.match(r"^[A-Za-z]$", t):
            cmd = t.upper()
            i += 1
            if cmd == "Z":
                if cur:
                    polys.append((cur, True))
                    cur = []
                pos = start
                cmd = None
            continue
        if cmd is None:
            i += 1
            continue
        if cmd == "M":
            if cur:
                polys.append((cur, False))
            pos = (float(tokens[i]), float(tokens[i + 1]))
            i += 2
            start = pos
            cur = [pos]
            cmd = "L"
        elif cmd == "L":
            pos = (float(tokens[i]), float(tokens[i + 1]))
            i += 2
            cur.append(pos)
        elif cmd == "Q":
            p1 = (float(tokens[i]), float(tokens[i + 1]))
            p2 = (float(tokens[i + 2]), float(tokens[i + 3]))
            i += 4
            cur.extend(_quad(pos, p1, p2))
            pos = p2
        elif cmd == "C":
            p1 = (float(tokens[i]), float(tokens[i + 1]))
            p2 = (float(tokens[i + 2]), float(tokens[i + 3]))
            p3 = (float(tokens[i + 4]), float(tokens[i + 5]))
            i += 6
            cur.extend(_cubic(pos, p1, p2, p3))
            pos = p3
    if cur:
        polys.append((cur, False))
    return polys


def render_clave(clave: str, target_w: int = 200, target_h: int = 125) -> Image.Image:
    for ext in ("webp", "jpg", "jpeg", "png"):
        rp = LAMINAS_DIR / f"{clave}.{ext}"
        if rp.is_file():
            im = Image.open(rp).convert("RGBA")
            im.thumbnail((target_w, target_h), Image.Resampling.LANCZOS)
            bg = Image.new("RGB", (target_w, target_h), (255, 255, 255))
            bg.paste(im, ((target_w - im.width) // 2, (target_h - im.height) // 2), im)
            return bg

    jp = LAMINAS_DIR / f"{clave}.json"
    lam = json.loads(jp.read_text(encoding="utf-8"))
    vb = float(lam.get("vb", 100))
    vh = float(lam.get("vh", vb))
    scale = min(target_w / vb, target_h / vh)
    rw, rh = max(1, round(vb * scale)), max(1, round(vh * scale))
    canvas = Image.new("RGBA", (rw, rh), (255, 255, 255, 255))
    sx = sy = scale

    for f in lam.get("formas") or []:
        layer = Image.new("RGBA", (rw, rh), (0, 0, 0, 0))
        d = ImageDraw.Draw(layer)
        fill = _parse_rgba(f.get("f"))
        stroke = _parse_rgba(f.get("s"))
        sw = max(1, round(float(f.get("sw") or 0) * scale)) if stroke and (f.get("sw") or 0) > 0 else 0
        tp = f["t"]
        if tp == "elipse":
            cx, cy, rx, ry = f["cx"] * sx, f["cy"] * sy, f["rx"] * sx, f["ry"] * sy
            box = [cx - rx, cy - ry, cx + rx, cy + ry]
            if fill:
                d.ellipse(box, fill=fill)
            if sw:
                d.ellipse(box, outline=stroke, width=sw)
        elif tp == "rrect":
            box = [f["x"] * sx, f["y"] * sy, (f["x"] + f["w"]) * sx, (f["y"] + f["h"]) * sy]
            r = float(f.get("r") or 0) * scale
            if fill:
                d.rounded_rectangle(box, radius=r, fill=fill)
            if sw:
                d.rounded_rectangle(box, radius=r, outline=stroke, width=sw)
        elif tp == "poli":
            pts = [(p[0] * sx, p[1] * sy) for p in f["p"]]
            if len(pts) >= 2:
                if fill:
                    d.polygon(pts, fill=fill)
                if sw:
                    d.line(pts + [pts[0]], fill=stroke, width=sw, joint="curve")
        elif tp == "ruta":
            polys = _path_to_polys(f["d"])
            if fill and len(polys) > 1 and f.get("fr") == "evenodd":
                acc = Image.new("L", (rw, rh), 0)
                for pts, _ in polys:
                    if len(pts) >= 3:
                        tmp = Image.new("L", (rw, rh), 0)
                        ImageDraw.Draw(tmp).polygon([(x * sx, y * sy) for x, y in pts], fill=255)
                        acc = ImageChops.difference(acc, tmp)
                layer.paste(Image.new("RGBA", (rw, rh), fill), (0, 0), acc)
            elif fill and len(polys) > 1:
                acc = np.zeros((rh, rw), dtype=np.int16)
                for pts, _ in polys:
                    if len(pts) >= 3:
                        spts = [(x * sx, y * sy) for x, y in pts]
                        area = sum(
                            x0 * y1 - x1 * y0
                            for (x0, y0), (x1, y1) in zip(spts, spts[1:] + [spts[0]])
                        )
                        if abs(area) < 1e-6:
                            continue
                        sign = 1 if area > 0 else -1
                        tmp = Image.new("L", (rw, rh), 0)
                        ImageDraw.Draw(tmp).polygon(spts, fill=255)
                        acc += sign * (np.asarray(tmp) > 0)
                mask = Image.fromarray(((acc != 0).astype(np.uint8)) * 255, mode="L")
                layer.paste(Image.new("RGBA", (rw, rh), fill), (0, 0), mask)
            elif fill:
                for pts, _ in polys:
                    if len(pts) >= 3:
                        d.polygon([(x * sx, y * sy) for x, y in pts], fill=fill)
            if sw:
                for pts, cl in polys:
                    spts = [(x * sx, y * sy) for x, y in pts]
                    if cl and len(spts) >= 2:
                        spts = spts + [spts[0]]
                    if len(spts) >= 2:
                        d.line(spts, fill=stroke, width=sw, joint="curve")
        canvas = Image.alpha_composite(canvas, layer)

    out = Image.new("RGB", (target_w, target_h), (255, 255, 255))
    out.paste(canvas.convert("RGB"), ((target_w - rw) // 2, (target_h - rh) // 2))
    return out


def _recoger_items(modo: str) -> list[tuple[str, str, str]]:
    items: list[tuple[str, str, str]] = []
    seen: set[str] = set()
    if modo == "acopros_0_2":
        ac = json.loads((RAIZ / "assets/content/acopros/proxectos_0_2.json").read_text(encoding="utf-8"))
        for p in ac["proxectos"]:
            m = f"m{p['mesCalendario']:02d}"
            for w in p["palabras"]:
                k = w["en"].lower().strip(" .!?")
                if k not in seen:
                    seen.add(k)
                    items.append((m, w["en"], w.get("lamina", "")))
            ck = p["cancion"]["es"].lower().strip(" .!?")
            if ck not in seen:
                seen.add(ck)
                items.append((f"{m}c", p["cancion"]["es"], p["cancion"].get("lamina", "")))
            rk = p["rima"]["en"].lower().strip(" .!?")
            if rk not in seen:
                seen.add(rk)
                items.append((f"{m}r", p["rima"]["en"], p["rima"].get("lamina", "")))
        return items
    if modo == "tpr" or modo.startswith("tpr_"):
        tpr_dir = RAIZ / "assets/content/tpr"
        sub = modo.replace("tpr_", "curso_") if modo.startswith("tpr_") else ""
        files = sorted((tpr_dir / sub).glob("*.json")) if sub else sorted(tpr_dir.rglob("*.json"))
        for fich in files:
            d = json.loads(fich.read_text(encoding="utf-8"))
            for s in d.get("semanas") or []:
                for w in s.get("palabras") or []:
                    if not w.get("lamina"):
                        continue
                    k = w["en"].lower().strip(" .!?")
                    if k not in seen:
                        seen.add(k)
                        items.append((w.get("id", "tpr")[-4:], w["en"], w.get("lamina", "")))
        return items

    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    for u in lec["cursos"][modo]["unidades"]:
        for l in u["leccions"]:
            for b in ("xaSabe", "novas", "repasa"):
                for p in l.get(b) or []:
                    k = p["en"].lower().strip(" .!?")
                    if k not in seen:
                        seen.add(k)
                        items.append((l["id"], p["en"], p.get("lamina", "")))
            f = l.get("fraseGramatica")
            if f:
                k = f["en"].lower().strip(" .!?")
                if k not in seen:
                    seen.add(k)
                    items.append((l["id"], f["en"], f.get("lamina", "")))
    return items


def main() -> int:
    modo = sys.argv[1] if len(sys.argv) > 1 else "curso_4_5"
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))["pezas"]
    items = _recoger_items(modo)

    cols = 10
    per_page = 100
    tile_w, tile_h = 220, 170
    font = ImageFont.load_default()
    for pg_idx in range(0, len(items), per_page):
        chunk = items[pg_idx:pg_idx + per_page]
        rows = (len(chunk) + cols - 1) // cols
        sheet = Image.new("RGB", (cols * tile_w, rows * tile_h), "#f8fafc")
        dr = ImageDraw.Draw(sheet)
        for idx, (lid, en, clave) in enumerate(chunk):
            c = idx % cols
            r = idx // cols
            x0, y0 = c * tile_w, r * tile_h
            thumb = render_clave(clave, 200, 125) if clave else Image.new("RGB", (200, 125), "#fee2e2")
            sheet.paste(thumb, (x0 + 10, y0 + 8))
            dr.rectangle([x0 + 2, y0 + 2, x0 + tile_w - 3, y0 + tile_h - 3], outline="#cbd5e1", width=1)
            m = mapa.get(en.lower().strip(" .!?"), {})
            lbl1 = f"{lid[-4:]} [{m.get('fuente','?')[:6]}] {en[:24]}"
            lbl2 = f"{clave[:28]}"
            dr.text((x0 + 8, y0 + 136), lbl1, fill="#0f172a", font=font)
            dr.text((x0 + 8, y0 + 150), lbl2, fill="#475569", font=font)
        pno = pg_idx // per_page + 1
        out_p = RAIZ / f"docs/capturas/hoja_contactos_{modo}_p{pno}.png"
        out_p.parent.mkdir(parents=True, exist_ok=True)
        sheet.save(out_p)
        print(f"OK {out_p.relative_to(RAIZ)} ({len(chunk)} láminas)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
