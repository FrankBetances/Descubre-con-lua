# Láminas en pixel art de los cuentos HIS (F9). Uso: python3 tools/draw_contos_pixel.py <carpeta>; luego se reducen a 192x120 en assets/brand/contos/.
import json, math, random, sys
from PIL import Image

W, H, ESC = 192, 120, 5
REPO = str(__import__('pathlib').Path(__file__).resolve().parent.parent)
art = json.load(open(f'{REPO}/assets/content/lua_art.json'))
PAL_LUA = {k: v for k, v in art['luaPalette'].items() if v != 'transparent'}

def hx(h):
    h = h.lstrip('#'); return tuple(int(h[i:i+2], 16) for i in (0, 2, 4)) + (255,)

# Paleta del mar: tonos cálidos y saturados, como Stardew.
MAR = [hx(c) for c in ('#123a5c', '#15507a', '#17698f', '#1a85a3', '#2aa3b3', '#4cc3c0', '#8fe0cf')]
AREA = [hx(c) for c in ('#7a5232', '#a8763f', '#d29d55', '#ecc27a', '#fbe2a6')]
ALGA = [hx(c) for c in ('#1d4a2a', '#2f7a3a', '#4fa64a', '#86cf5e')]
ROCHA = [hx(c) for c in ('#2a2633', '#423c4f', '#5d566b', '#7f7790')]
CONTORNO = hx('#1a1424')
BRANCO = hx('#ffffff')

def lenzo(seed):
    random.seed(seed)
    im = Image.new('RGBA', (W, H))
    px = im.load()
    for y in range(H):
        # degradado por bandas, con tramado de Bayer entre bandas
        t = y / H * (len(MAR) - 1)
        i = int(t); f = t - i
        bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
        for x in range(W):
            j = len(MAR) - 1 - min(len(MAR) - 1, i + (1 if f * 16 > bayer[y % 4][x % 4] else 0))
            px[x, y] = MAR[j]
    return im, px

def raios(px, seed):
    random.seed(seed)
    for r in range(4):
        x0 = 20 + r * 45 + random.randint(-6, 6)
        for y in range(0, 70):
            w = 3 + y // 14
            for dx in range(w):
                x = x0 + dx + y // 3
                if 0 <= x < W and (x + y) % 3:
                    c = px[x, y]
                    px[x, y] = tuple(min(255, v + 14) for v in c[:3]) + (255,)

def area(px, y0, seed):
    random.seed(seed)
    bayer = [[0, 8, 2, 10], [12, 4, 14, 6], [3, 11, 1, 9], [15, 7, 13, 5]]
    for x in range(W):
        top = y0 + int(2 * math.sin(x / 11) + 1.5 * math.sin(x / 5.3))
        for y in range(top, H):
            d = y - top
            if d == 0: c = AREA[4]
            elif d == 1: c = AREA[3]
            else:
                t = min(3.0, 1 + (d - 2) / 7)
                i = int(t); f = t - i
                k = 3 - min(3, i + (1 if f * 16 > bayer[y % 4][x % 4] else 0))
                c = AREA[max(1, k)] if d < 18 else AREA[max(0, k - 1)]
            # ondulas da area
            if d > 3 and (x + 3 * int(math.sin(y / 2.0) * 2) + y * 2) % 23 == 0: c = AREA[4]
            if d > 3 and (x + 3 * int(math.sin(y / 2.0) * 2) + y * 2) % 23 == 1: c = AREA[1]
            if random.random() < 0.05: c = AREA[max(0, AREA.index(c) - 1)]
            px[x, y] = c
        px[x, top - 1] = AREA[2]
    for _ in range(22):  # pedriñas con luz
        x, y = random.randint(2, W - 4), random.randint(y0 + 5, H - 2)
        px[x, y] = ROCHA[1]; px[x + 1, y] = ROCHA[2]; px[x, y - 1] = ROCHA[3]

def alga(px, x0, base, alto, fase):
    for y in range(alto):
        x = x0 + int(2.2 * math.sin(y / 4 + fase))
        for dx, c in ((-1, ALGA[0]), (0, ALGA[2]), (1, ALGA[1])):
            if 0 <= x + dx < W: px[x + dx, base - y] = c
        if y % 5 == 2 and x + 2 < W: px[x + 2, base - y] = ALGA[3]

def rocha(px, cx, cy, rx, ry):
    random.seed(cx * 7 + cy)
    for y in range(cy - ry, cy + 1):
        for x in range(cx - rx, cx + rx + 1):
            e = ((x - cx) / rx) ** 2 + ((y - cy) / ry) ** 2
            if e <= 1:
                lx, ly = (x - cx) / rx, (y - cy) / ry
                luz = -lx * 0.6 - ly * 0.8 + random.uniform(-0.15, 0.15)
                c = ROCHA[3] if luz > 0.75 else ROCHA[2] if luz > 0.25 else ROCHA[1] if luz > -0.3 else ROCHA[0]
                if e > 0.86: c = CONTORNO
                # musgo na parte de arriba
                if ly < -0.55 and e <= 0.86 and random.random() < 0.55:
                    c = ALGA[2] if luz > 0.4 else ALGA[1]
                px[x, y] = c
    for _ in range(rx // 3):  # gretas
        x, y = cx + random.randint(-rx // 2, rx // 2), cy - random.randint(2, ry // 2)
        for k in range(3):
            if px[x + k, y + k // 2][:3] != CONTORNO[:3]: px[x + k, y + k // 2] = ROCHA[0]

def burbulla(px, cx, cy, r):
    for y in range(cy - r, cy + r + 1):
        for x in range(cx - r, cx + r + 1):
            d = math.hypot(x - cx, y - cy)
            if 0 <= x < W and 0 <= y < H and r - 0.9 <= d <= r + 0.3:
                px[x, y] = hx('#bfe9f5')
    if r >= 2: px[cx - r // 2, cy - r // 2] = BRANCO
    if r >= 4: px[cx - r // 2 + 1, cy - r // 2] = BRANCO

# O peixiño azul: azul celeste, máis claro que o fondo, con contorno branco.
PEIXE = [
    "......oooo..............",
    ".....oLLLLo.............",
    "....oLLsssso.........oo.",
    "...oLsssssssoo......oLo.",
    "..oLssssssssbbo....oLso.",
    ".oLsswwKsssssbbo..oLsbo.",
    ".oLswwKKssxsxsbbooLssbo.",
    "oLssswKKsssxsxsbbsssbo..",
    "oLssssssssxsxsxsbbsbbo..",
    "oPssssssssssssssbbbbbo..",
    ".oPsssssssssssbbbbbbo...",
    ".oPPssssssbbbbbbddoLbo..",
    "..oPPsbbbbbbbbddoo.oLbo.",
    "...ooPbbbbdddoo.....oLo.",
    ".....oodddooo........oo.",
    "........ooo.............",
]
PAL_PEIXE = {'o': hx('#16324f'), 'L': hx('#d6f6ff'), 's': hx('#7fd3f0'), 'x': hx('#5cbde2'),
             'b': hx('#3f9fd0'), 'd': hx('#2a73a8'), 'w': BRANCO, 'K': hx('#141220'), 'P': hx('#ffb3b3')}

def sprite(px, filas, pal, x0, y0, espello=False, escala=1):
    for y, fila in enumerate(filas):
        for x, ch in enumerate(fila[::-1] if espello else fila):
            if ch in pal:
                for sy in range(escala):
                    for sx in range(escala):
                        X, Y = x0 + x * escala + sx, y0 + y * escala + sy
                        if 0 <= X < W and 0 <= Y < H:
                            c = pal[ch]
                            px[X, Y] = c if isinstance(c, tuple) else hx(c)

def lua(px, x0, y0, espello=False):
    sprite(px, art['luaSitArt'], PAL_LUA, x0, y0, espello)


def contorno(px, filas, x0, y0, cor):
    on = {(x, y) for y, f in enumerate(filas) for x, ch in enumerate(f) if ch in PAL_LUA}
    for (x, y) in list(on):
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if (x + dx, y + dy) not in on:
                X, Y = x0 + x + dx, y0 + y + dy
                if 0 <= X < W and 0 <= Y < H: px[X, Y] = cor

def sombra(px, cx, cy, rx):
    for x in range(cx - rx, cx + rx + 1):
        for y in (cy, cy + 1):
            if 0 <= x < W and ((x - cx) / rx) ** 2 < 0.95:
                c = px[x, y]; px[x, y] = tuple(int(v * 0.72) for v in c[:3]) + (255,)

def peixiños(px, seed):
    # banco de peixes lonxanos, en silueta
    random.seed(seed + 11)
    sil = hx('#2a8fa6')
    for _ in range(7):
        x, y = random.randint(10, W - 20), random.randint(14, 50)
        for dx, dy in ((0, 0), (1, 0), (2, 0), (1, -1), (1, 1), (-1, -1), (-1, 1)):
            if 0 <= x + dx < W: px[x + dx, y + dy] = sil

def superficie(px):
    # a luz da superficie: ondas brillantes nas tres primeiras filas
    for x in range(W):
        for y in range(0, 4):
            if (x + y * 5 + int(3 * math.sin(x / 6))) % 9 < 4 - y:
                c = px[x, y]; px[x, y] = tuple(min(255, v + 45) for v in c[:3]) + (255,)

CORAL = [hx(c) for c in ('#7a2340', '#c2405a', '#f06c6c', '#ffb08a')]
ESTRELA = [hx(c) for c in ('#9a4a10', '#e0802a', '#ffc15a')]

def lonxe(px, seed):
    # Capa de fondo: rochas e algas en silueta, máis escuras, para dar fondo.
    random.seed(seed + 7)
    sil = hx('#0d3256')
    for cx, ry, rx in ((30, 26, 30), (100, 18, 40), (170, 30, 34)):
        for y in range(100 - ry, 100):
            for x in range(cx - rx, cx + rx):
                if 0 <= x < W and ((x - cx) / rx) ** 2 + ((y - 100) / ry) ** 2 <= 1:
                    px[x, y] = sil

def coral(px, x0, base, alto):
    # Un abano de coral: ramas que se abren cara arriba.
    for rama in (-3, -1, 1, 3):
        x, y = x0, base
        for i in range(alto):
            y -= 1
            x += rama * 0.35
            c = CORAL[1] if i < alto - 2 else CORAL[3]
            X = int(x)
            if 0 <= X < W:
                px[X, y] = c
                if X + 1 < W: px[X + 1, y] = CORAL[2]
                if X - 1 >= 0: px[X - 1, y] = CORAL[0]

def estrela(px, cx, cy):
    for dx, dy in ((0, -2), (0, -1), (-2, 0), (-1, 0), (1, 0), (2, 0), (-1, 1), (1, 1), (-2, 2), (2, 2), (0, 0)):
        px[cx + dx, cy + dy] = ESTRELA[1]
    px[cx, cy] = ESTRELA[2]; px[cx - 1, cy + 1] = ESTRELA[0]; px[cx + 1, cy + 1] = ESTRELA[0]

def cunca(px, cx, cy):
    for dx in range(-2, 3): px[cx + dx, cy] = hx('#f6d2c0')
    for dx in range(-1, 2): px[cx + dx, cy - 1] = hx('#fbe7dc')
    px[cx, cy - 2] = hx('#ffffff')
    px[cx - 2, cy + 1] = hx('#b07a6a'); px[cx + 2, cy + 1] = hx('#b07a6a')

def causticas(px, y0, seed):
    random.seed(seed + 3)
    for _ in range(40):
        x, y = random.randint(0, W - 3), random.randint(y0, y0 + 6)
        for dx in range(random.randint(1, 3)):
            c = px[x + dx, y]
            px[x + dx, y] = tuple(min(255, v + 30) for v in c[:3]) + (255,)

def fondo(seed):
    im, px = lenzo(seed)
    superficie(px)
    lonxe(px, seed)
    peixiños(px, seed)
    raios(px, seed)
    rocha(px, 152, 104, 24, 18)
    rocha(px, 36, 106, 12, 8)
    area(px, 100, seed)
    causticas(px, 100, seed)
    for x0, alto, f in ((10, 40, 0.3), (17, 30, 1.4), (24, 22, 2.6), (178, 36, 2.1), (186, 26, 0.4), (128, 20, 0.9)):
        alga(px, x0, 103, alto, f)
    coral(px, 60, 104, 12)
    coral(px, 112, 105, 9)
    estrela(px, 90, 110)
    cunca(px, 138, 112)
    cunca(px, 46, 114)
    return im, px

def gardar(im, nome):
    im.resize((W * ESC, H * ESC), Image.NEAREST).save(nome)

S = sys.argv[1]
# Lámina 1: o mar fondo e azul; burbullas no centro; a cola do peixe asoma á dereita.
im, px = fondo(1)
for cx, cy, r in ((90, 40, 6), (104, 28, 4), (80, 58, 3), (112, 50, 5), (96, 16, 2)):
    burbulla(px, cx, cy, r)
cola = [''.join(c * 2 for c in f[14:]) for f in PEIXE for _ in (0, 1)]
sprite(px, cola, PAL_PEIXE, W - 12, 52)
gardar(im, f'{S}/his001_1.png')
# Lámina 2: o peixe no centro; tres burbullas en diagonal.
im, px = fondo(2)
sprite(px, PEIXE, PAL_PEIXE, 62, 36, escala=3)
for cx, cy, r in ((66, 32, 3), (58, 20, 4), (50, 7, 5)):
    burbulla(px, cx, cy, r)
gardar(im, f'{S}/his001_2.png')
# Lámina 3: Lúa e o peixe fronte a fronte, nariz con nariz.
im, px = fondo(3)
lua2 = [''.join(c * 2 for c in f) for f in art['luaSitArt'] for _ in (0, 1)]
sombra(px, 66, 103, 30)
contorno(px, lua2, 34, 28, CONTORNO)
sprite(px, lua2, PAL_LUA, 34, 28)
sprite(px, PEIXE, PAL_PEIXE, 104, 46, escala=2)
for cx, cy, r in ((106, 40, 2), (110, 30, 3), (104, 20, 2)):
    burbulla(px, cx, cy, r)
gardar(im, f'{S}/his001_3.png')
print('ok')
