"""Motor de las láminas en pixel art de los cuentos HIS (F9).

Una lámina es un fondo (uno por escenario del documento: ESC-01…08) más
elementos (sprites de `sprites.py`), Lúa —siempre desde su rejilla oficial,
`luaSitArt`, sin redibujar: las posturas se hacen moviendo, girando o
volteando el sprite (regla 5b)— y efectos (gotas, viento, zzz, notas…).
El lienzo mide 192×120 y se guarda a ese tamaño; la app lo escala sin
suavizar.
"""
from __future__ import annotations

import json
import math
import random
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
W, H = 192, 120
BAYER = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
CONTORNO = (26, 20, 36, 255)


def hx(h: str):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def aclarar(c, k):
    return tuple(max(0, min(255, int(v + k))) for v in c[:3]) + (255,)


class Lenzo:
    def __init__(self):
        self.im = Image.new("RGBA", (W, H))
        self.px = self.im.load()

    def put(self, x, y, c):
        if 0 <= x < W and 0 <= y < H:
            self.px[x, y] = c

    def rect(self, x0, y0, x1, y1, c):
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                self.px[x, y] = c

    def degradado(self, y0, y1, cores, x0=0, x1=W):
        """Degradado vertical por bandas con tramado de Bayer."""
        n = len(cores) - 1
        for y in range(max(0, y0), min(H, y1)):
            t = (y - y0) / max(1, (y1 - y0)) * n
            i = int(t)
            f = t - i
            for x in range(max(0, x0), min(W, x1)):
                j = min(n, i + (1 if f * 16 > BAYER[y % 4][x % 4] else 0))
                self.px[x, y] = cores[j]

    def elipse(self, cx, cy, rx, ry, c, borde=None):
        for y in range(int(cy - ry), int(cy + ry) + 1):
            for x in range(int(cx - rx), int(cx + rx) + 1):
                e = ((x - cx) / max(rx, .5)) ** 2 + ((y - cy) / max(ry, .5)) ** 2
                if e <= 1:
                    self.put(x, y, borde if (borde and e > .78) else c)

    def textura(self, x0, y0, x1, y1, cor, prob, seed):
        random.seed(seed)
        for y in range(max(0, y0), min(H, y1)):
            for x in range(max(0, x0), min(W, x1)):
                if random.random() < prob:
                    self.px[x, y] = cor

    def pegar(self, im, x, y):
        self.im.alpha_composite(im, (int(x), int(y)))
        self.px = self.im.load()

    def gardar(self, ruta):
        Path(ruta).parent.mkdir(parents=True, exist_ok=True)
        self.im.convert("RGB").save(ruta, optimize=True)


# --- Sprites -----------------------------------------------------------------

def de_reixa(filas, pal, escala=1, contorno=True):
    """Imagen RGBA desde una rejilla de caracteres. Se amplía primero y el
    contorno oscuro va después, de 1 px a tamaño final: así un sprite grande
    no lleva un borde negro grueso."""
    h = len(filas)
    w = max(len(f) for f in filas)
    base = Image.new("RGBA", (w, h))
    bp = base.load()
    for y, f in enumerate(filas):
        for x, ch in enumerate(f):
            if ch in pal:
                c = pal[ch]
                bp[x, y] = c if isinstance(c, tuple) else hx(c)
    if escala != 1:
        base = base.resize((w * escala, h * escala), Image.NEAREST)
    if not contorno:
        return base
    pad = 1
    im = Image.new("RGBA", (base.width + 2 * pad, base.height + 2 * pad))
    im.alpha_composite(base, (pad, pad))
    px = im.load()
    on = {(x, y) for y in range(im.height) for x in range(im.width) if px[x, y][3] > 0}
    for (x, y) in on:
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            q = (x + dx, y + dy)
            if q not in on and 0 <= q[0] < im.width and 0 <= q[1] < im.height:
                px[q] = CONTORNO
    return im


_LUA = None


def lua(pose="sentada", escala=2, espello=False):
    """Lúa desde `luaSitArt` (lua_art.json). Posturas sin redibujar."""
    global _LUA
    if _LUA is None:
        art = json.loads((ROOT / "assets/content/lua_art.json").read_text())
        pal = {k: v for k, v in art["luaPalette"].items() if v != "transparent"}
        _LUA = (art["luaSitArt"], pal)
    im = de_reixa(_LUA[0], _LUA[1], escala)
    if espello:
        im = im.transpose(Image.FLIP_LEFT_RIGHT)
    if pose in ("deitada", "durme"):
        im = im.rotate(90, expand=True)
    elif pose == "inclinada":
        im = im.rotate(-12, expand=True, resample=Image.NEAREST)
    return im


# --- Efectos -----------------------------------------------------------------

def sombra(l: Lenzo, cx, cy, rx):
    for x in range(int(cx - rx), int(cx + rx) + 1):
        for y in (cy, cy + 1):
            if 0 <= x < W and 0 <= y < H and ((x - cx) / rx) ** 2 < .95:
                c = l.px[x, y]
                l.px[x, y] = tuple(int(v * .72) for v in c[:3]) + (255,)


def gota(l, x, y, c=hx("#7cc8f0")):
    for dy, w in ((0, 0), (1, 1), (2, 1), (3, 0)):
        for dx in range(-w, w + 1):
            l.put(x + dx, y + dy, c)
    l.put(x, y + 1, hx("#ffffff"))


def burbulla(l, cx, cy, r):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            d = math.hypot(x - cx, y - cy)
            if r - .9 <= d <= r + .3:
                l.put(x, y, hx("#d8f4ff"))
    if r >= 2:
        l.put(cx - r // 2, cy - r // 2, hx("#ffffff"))


def liñas_vento(l, y, x0, x1, c=hx("#ffffff")):
    for x in range(x0, x1):
        yy = y + int(1.5 * math.sin(x / 6))
        if (x // 3) % 4 != 3:
            l.put(x, yy, c)


def liñas_movemento(l, x, y, lonx=10, n=3, dirx=-1):
    for i in range(n):
        for k in range(lonx - i * 2):
            l.put(x + dirx * k, y + i * 4, hx("#ffffff"))


def zzz(l, x, y):
    Z = ["####", "..#.", ".#..", "####"]
    for k, (ox, oy, s) in enumerate(((0, 0, 1), (6, -6, 1), (13, -13, 2))):
        for j, f in enumerate(Z):
            for i, ch in enumerate(f):
                if ch == "#":
                    for sy in range(s):
                        for sx in range(s):
                            l.put(x + ox + i * s + sx, y + oy + j * s + sy, hx("#f4f0ff"))


def nota(l, x, y, c=hx("#2a2440")):
    for dy in range(6):
        l.put(x + 2, y + dy, c)
    l.put(x + 3, y, c)
    l.put(x + 4, y + 1, c)
    for dx, dy in ((0, 5), (1, 5), (0, 6), (1, 6), (2, 6)):
        l.put(x + dx, y + dy, c)


def corazon(l, x, y, c=hx("#ff6f91")):
    for dy, f in enumerate([".#.#.", "#####", "#####", ".###.", "..#.."]):
        for dx, ch in enumerate(f):
            if ch == "#":
                l.put(x + dx, y + dy, c)


def pregunta(l, x, y, c=hx("#2a2440")):
    for dy, f in enumerate([".##.", "#..#", "..#.", ".#..", "....", ".#.."]):
        for dx, ch in enumerate(f):
            if ch == "#":
                l.put(x + dx, y + dy, c)


def vapor(l, x, y, alto=14):
    for k in range(alto):
        l.put(x + int(2 * math.sin(k / 2.5)), y - k, hx("#ffffff") if k % 3 else hx("#e8eef4"))


def brillo(l, x, y):
    for d in (-2, -1, 1, 2):
        l.put(x + d, y, hx("#fff6b0"))
        l.put(x, y + d, hx("#fff6b0"))
    l.put(x, y, hx("#ffffff"))


def alegria(l, cx, cy, r=18):
    for a in range(0, 360, 45):
        ra = math.radians(a)
        for k in range(3):
            l.put(int(cx + (r + k) * math.cos(ra)), int(cy + (r + k) * math.sin(ra)), hx("#ffe36b"))


EFECTOS = {
    "gotas": lambda l, x, y: [gota(l, x + dx, y + dy) for dx, dy in ((0, 0), (10, 6), (-8, 10), (16, -6), (-14, -4))],
    "choiva": lambda l, x, y: [gota(l, (i * 23 + j * 9) % W, (j * 17 + i * 7) % 90) for i in range(9) for j in range(4)],
    "burbullas": lambda l, x, y: [burbulla(l, x + dx, y + dy, r) for dx, dy, r in ((0, 0, 3), (6, -10, 2), (-4, -18, 4))],
    "vento": lambda l, x, y: [liñas_vento(l, yy, 8, W - 8) for yy in (18, 30, 44)],
    "movemento": lambda l, x, y: liñas_movemento(l, x, y),
    "zzz": lambda l, x, y: zzz(l, x, y),
    "notas": lambda l, x, y: [nota(l, x + dx, y + dy) for dx, dy in ((0, 0), (12, -8), (24, 2))],
    "corazons": lambda l, x, y: [corazon(l, x + dx, y + dy) for dx, dy in ((0, 0), (10, -8), (20, 2))],
    "pregunta": lambda l, x, y: [pregunta(l, x + dx, y + dy) for dx, dy in ((0, 0), (10, -6), (20, 0))],
    "vapor": lambda l, x, y: [vapor(l, x + dx, y) for dx in (0, 6, 12)],
    "brillo": lambda l, x, y: brillo(l, x, y),
    "alegria": lambda l, x, y: alegria(l, x, y),
    "golpe": lambda l, x, y: [l.rect(x + dx, y, x + dx + 1, y + 4, hx("#2a2440")) for dx in (0, 4, 8)],
    "salto": lambda l, x, y: [l.put(x + dx, y + int(abs(dx) / 3), hx("#ffffff")) for dx in range(-10, 11, 2)],
    "relampo": lambda l, x, y: [l.rect(x + dx, y + dy, x + dx + 3, y + dy + 2, hx("#ffe36b"))
                                 for dx, dy in ((0, 0), (-2, 2), (-4, 4), (-1, 6), (-3, 8), (-6, 10))],
    "luz": lambda l, x, y: [l.put(x + int(k * math.cos(a)), y + int(k * math.sin(a)), hx("#fff3b0"))
                             for a in (0.3, 0.8, 1.3, 1.8, 2.3) for k in range(4, 22, 2)],
}
