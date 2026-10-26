"""Los fondos de las láminas: uno por escenario del documento de la biblioteca
(ESC-01 baño, 02 cocina, 03 cuarto, 04 parque, 05 naturaleza, 06 mar,
07 rincón de juego, 08 granja), con variantes de color y de hora que piden
las descripciones."""
from __future__ import annotations

import math
import random

from motor import H, W, Lenzo, aclarar, hx

CORES_PAREDE = {
    "crema": ("#f6ead2", "#efdcb8"), "amarelo": ("#fbeeb0", "#f3dd86"),
    "azul": ("#cfe8f6", "#b4d9ef"), "verde": ("#d3efe0", "#b8e3cc"),
    "malva": ("#e4d2ef", "#cfb6e2"), "azulnoite": ("#2c3e74", "#22305e"),
    "rosa": ("#f8dce4", "#efc4d1"), "laranxa": ("#fbd9a8", "#f3c07a"),
}


def parede(l, cor, chan_y, chan=("#d9b48a", "#c79d70")):
    a, b = (hx(c) for c in CORES_PAREDE[cor])
    l.degradado(0, chan_y, [aclarar(a, 8), a, b])
    # rodapé e chan de táboas
    l.rect(0, chan_y, W, chan_y + 2, aclarar(b, -40))
    c1, c2 = hx(chan[0]), hx(chan[1])
    for y in range(chan_y + 2, H):
        for x in range(W):
            tab = ((y - chan_y) // 6) % 2
            l.px[x, y] = c1 if (x + tab * 17) % 34 else c2
            if (y - chan_y) % 6 == 0:
                l.px[x, y] = aclarar(c2, -15)


def ventá(l, x, y, w=34, h=30, noite=False, lúa=False, gotas=False, vento=False):
    marco = hx("#f4f4f4")
    l.rect(x - 2, y - 2, x + w + 2, y + h + 2, marco)
    ceo = [hx("#101c3e"), hx("#1c2d5c")] if noite else [hx("#8fd0f2"), hx("#c6ebfb")]
    l.degradado(y, y + h, ceo, x, x + w)
    l.rect(x + w // 2, y, x + w // 2 + 1, y + h, marco)
    l.rect(x, y + h // 2, x + w, y + h // 2 + 1, marco)
    if noite:
        for i in range(6):
            l.put(x + 3 + (i * 11) % (w - 4), y + 3 + (i * 7) % (h - 6), hx("#fff8c8"))
    if lúa:
        l.elipse(x + w - 9, y + 8, 5, 5, hx("#ffe58a"))
        l.elipse(x + w - 7, y + 7, 4, 4, ceo[0])
    if gotas:
        from motor import gota
        for gx, gy in ((5, 4), (20, 12), (10, 20), (27, 5)):
            gota(l, x + gx, y + gy, hx("#bfe6fb"))
    if vento:
        from motor import liñas_vento
        for yy in (y + 6, y + 14, y + 22):
            liñas_vento(l, yy, x + 2, x + w - 2)


def baño(l, cor="azul", azulexo=True):
    parede(l, cor, 84, chan=("#e9eef2", "#d4dde4"))
    if azulexo:
        base = hx(CORES_PAREDE[cor][1])
        for y in range(40, 84, 8):
            for x in range(0, W, 8):
                l.rect(x, y, x + 8, y + 1, aclarar(base, -18))
                l.rect(x, y, x + 1, y + 8, aclarar(base, -18))


def cociña(l, cor="crema"):
    parede(l, cor, 86, chan=("#f1e6d2", "#dfcfb3"))
    # baldosas de cociña no chan
    for y in range(88, H, 8):
        for x in range(0, W, 8):
            if ((x // 8) + (y // 8)) % 2:
                l.rect(x, y, x + 8, y + 8, hx("#e7d9bf"))
    # estante
    l.rect(120, 22, 176, 25, hx("#b07a4a"))
    for i, c in enumerate(("#e46a5a", "#6ab7e4", "#f2c14e")):
        l.rect(126 + i * 16, 12, 134 + i * 16, 22, hx(c))


def cuarto(l, cor="azulnoite", noite=True, lúa=True, ventá_x=140, gotas=False, vento=False):
    parede(l, cor, 88, chan=("#7d6a9a", "#6b5886") if noite else ("#d9b48a", "#c79d70"))
    if ventá_x is not None:
        ventá(l, ventá_x, 14, noite=noite, lúa=lúa, gotas=gotas, vento=vento)


def ceo(l, tipo, ata):
    cores = {
        "azul": ["#6fb8ea", "#94cdf0", "#bfe3f7"],
        "gris": ["#9aa6b4", "#b5bfca", "#ccd4dc"],
        "laranxa": ["#f39a6b", "#f7b98a", "#fbd9a8"],
        "amencer": ["#f7b57a", "#f9cf96", "#fbe6bc"],
        "noite": ["#16224a", "#22336a", "#30457f"],
    }[tipo]
    l.degradado(0, ata, [hx(c) for c in cores])


def nubes(l, seed):
    random.seed(seed)
    for _ in range(3):
        x, y = random.randint(10, W - 40), random.randint(6, 26)
        for dx, r in ((0, 6), (8, 8), (17, 6)):
            l.elipse(x + dx, y, r, r * .6, hx("#ffffff"))


def herba(l, y0, cores=("#4f9e3c", "#62b649", "#7fca5a"), seed=1):
    a, b, c = (hx(x) for x in cores)
    l.degradado(y0, H, [c, b, a])
    random.seed(seed)
    for _ in range(140):
        x, y = random.randint(0, W - 1), random.randint(y0 + 2, H - 1)
        l.put(x, y, aclarar(c, 25))
        l.put(x, y - 1, aclarar(c, 10))


def árbore_fondo(l, x, base, cor_copa="#3f8a3a", tronco="#7a5232", alto=34):
    l.rect(x - 2, base - alto // 2, x + 3, base, hx(tronco))
    for dx, dy, r in ((-8, -alto // 2, 9), (8, -alto // 2, 9), (0, -alto // 2 - 9, 11)):
        l.elipse(x + dx, base + dy, r, r * .85, hx(cor_copa))
        l.elipse(x + dx - 2, base + dy - 2, r * .55, r * .45, aclarar(hx(cor_copa), 22))


def parque(l, ceo_tipo="azul", outono=False, camiño=False, seed=1):
    ceo(l, ceo_tipo, 72)
    if ceo_tipo in ("azul", "amencer"):
        nubes(l, seed)
    copa = "#d9822b" if outono else "#3f8a3a"
    for x in (18, 62, 150, 178):
        árbore_fondo(l, x, 76, copa if x % 2 else ("#e9a23b" if outono else "#4c9a40"))
    herba(l, 70, seed=seed)
    if camiño:
        for y in range(80, H):
            w = 10 + (y - 80)
            cx = 96 + int(6 * math.sin(y / 9))
            l.rect(cx - w // 2, y, cx + w // 2, y + 1, hx("#d6b37f"))
    if outono:
        random.seed(seed)
        for _ in range(26):
            x, y = random.randint(0, W - 2), random.randint(96, H - 2)
            c = hx(random.choice(["#e9a23b", "#d9822b", "#f2c14e"]))
            l.rect(x, y, x + 2, y + 1, c)


def natureza(l, ceo_tipo="azul", horta=True, seed=2):
    ceo(l, ceo_tipo, 60)
    nubes(l, seed)
    for x, alto in ((14, 40), (44, 30), (168, 42)):
        árbore_fondo(l, x, 66, "#2f7a35", alto=alto)
    herba(l, 62, seed=seed)
    if horta:
        l.degradado(84, H, [hx("#6b4a2e"), hx("#57391f")])
        random.seed(seed)
        for _ in range(90):
            x, y = random.randint(0, W - 1), random.randint(86, H - 1)
            l.put(x, y, hx("#7d5a3a"))


def mar(l, tipo="fondo", seed=3):
    if tipo == "praia":
        ceo(l, "azul", 50)
        nubes(l, seed)
        l.degradado(50, 78, [hx("#4cc3d0"), hx("#2aa3b3"), hx("#1a85a3")])
        for x in range(W):
            y = 76 + int(2 * math.sin(x / 7))
            l.rect(x, y, x + 1, y + 2, hx("#ffffff"))
        l.degradado(78, H, [hx("#fbe2a6"), hx("#ecc27a"), hx("#d29d55")])
        return
    l.degradado(0, 104, [hx(c) for c in ("#8fe0cf", "#4cc3c0", "#2aa3b3", "#1a85a3", "#17698f", "#15507a")])
    for x in range(W):
        for y in range(0, 4):
            if (x + y * 5 + int(3 * math.sin(x / 6))) % 9 < 4 - y:
                l.put(x, y, aclarar(l.px[x, y], 45))
    for cx, ry, rx in ((30, 26, 30), (100, 18, 40), (170, 30, 34)):
        l.elipse(cx, 104, rx, ry, hx("#0d3256"))
    l.degradado(100, H, [hx("#fbe2a6"), hx("#ecc27a"), hx("#d29d55")])
    random.seed(seed)
    for _ in range(20):
        x, y = random.randint(0, W - 2), random.randint(102, H - 1)
        l.put(x, y, hx("#a8763f"))
    for x0, alto, f in ((8, 34, .3), (16, 24, 1.4), (182, 30, 2.1)):
        for y in range(alto):
            x = x0 + int(2 * math.sin(y / 4 + f))
            l.put(x, 103 - y, hx("#4fa64a"))
            l.put(x + 1, 103 - y, hx("#2f7a3a"))


def xogo(l, cor="crema", alfombra="#7cc1e4", estante=True):
    parede(l, cor, 80)
    l.elipse(96, 104, 80, 14, hx(alfombra))
    l.elipse(96, 104, 66, 10, aclarar(hx(alfombra), 18))
    if estante:
        l.rect(8, 40, 48, 44, hx("#b07a4a"))
        for i, c in enumerate(("#e46a5a", "#f2c14e", "#6ab7e4", "#7fca5a")):
            l.rect(12 + i * 9, 30, 19 + i * 9, 40, hx(c))


def granxa(l, ceo_tipo="azul", interior=False, valla=True, establo=False, seed=4):
    if interior:
        parede(l, "crema", 78, chan=("#e9c46a", "#d9ae4f"))
        for x in range(0, W, 16):
            l.rect(x, 0, x + 2, 78, hx("#c9a874"))
        random.seed(seed)
        for _ in range(200):
            x, y = random.randint(0, W - 2), random.randint(80, H - 1)
            l.rect(x, y, x + 3, y + 1, hx("#f2d27a"))
        return
    ceo(l, ceo_tipo, 66)
    nubes(l, seed)
    for x, y, r in ((40, 66, 40), (150, 66, 50)):
        l.elipse(x, y, r, 14, hx("#7fbf5a"))
    herba(l, 62, seed=seed)
    if establo:
        l.rect(130, 22, 186, 66, hx("#b5442e"))
        for y in (22, 21, 20):
            pass
        for i in range(10):
            l.rect(128 + i * 3, 22 - i * 2, 188 - i * 3, 24 - i * 2, hx("#8c3423"))
        l.rect(148, 40, 168, 66, hx("#7a4a2a"))
        l.rect(157, 40, 159, 66, hx("#5a3418"))
    if valla:
        for x in range(0, W, 14):
            l.rect(x, 70, x + 3, 86, hx("#c79562"))
        l.rect(0, 74, W, 76, hx("#b07f4f"))
        l.rect(0, 80, W, 82, hx("#b07f4f"))


FONDOS = {
    "baño": baño, "cociña": cociña, "cuarto": cuarto, "parque": parque,
    "natureza": natureza, "mar": mar, "xogo": xogo, "granxa": granxa,
}


def pintar(nome: str, **op) -> Lenzo:
    l = Lenzo()
    FONDOS[nome](l, **op)
    return l
