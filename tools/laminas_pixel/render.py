#!/usr/bin/env python3
"""Pinta las láminas de los cuentos HIS desde sus fichas (F9).

Uso:  python3 tools/laminas_pixel/render.py [--solo HIS-002] [--folla saida.png]

Cada línea de `escenas/*.txt` es una lámina:

    HIS-002.1 | cociña cor=crema | mesa@40,84x2 prato@92,78 LUA:sentada@20,30 | alegria@60,40

- fondo y sus opciones (clave=valor; true/false para sí/no);
- elementos en orden de pintado: nombre@x,y, «xN» escala, «<» en espejo;
  LUA:postura@x,y es Lúa (sentada, salto, deitada, durme, puntillas,
  inclinada), siempre desde su rejilla oficial;
- efectos: nombre@x,y (gotas, vento, zzz, notas, corazons, vapor…).

Escribe `assets/brand/contos/hisNNN_K.png` y pone `imaxe` en la lámina del
JSON de la biblioteca.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import fondos  # noqa: E402
import motor  # noqa: E402
import sprites  # noqa: E402

AQUI = Path(__file__).resolve().parent
ROOT = AQUI.parents[1]
SAIDA = ROOT / "assets" / "brand" / "contos"
TOKEN = re.compile(r"^(?P<nome>[^@]+)@(?P<x>-?\d+),(?P<y>-?\d+)(?:x(?P<e>\d+))?(?P<esp><)?$")


def valor(v: str):
    if v in ("true", "false"):
        return v == "true"
    if re.fullmatch(r"-?\d+", v):
        return int(v)
    if v == "none":
        return None
    return v


def debuxar(liña: str):
    partes = [p.strip() for p in liña.split("|")]
    lid = partes[0]
    fondo_def = partes[1].split()
    op = dict(kv.split("=", 1) for kv in fondo_def[1:])
    l = fondos.pintar(fondo_def[0], **{k: valor(v) for k, v in op.items()})
    for tok in (partes[2].split() if len(partes) > 2 else []):
        m = TOKEN.match(tok)
        if not m:
            raise ValueError(f"{lid}: no entiendo «{tok}»")
        nome, x, y = m["nome"], int(m["x"]), int(m["y"])
        esc = int(m["e"] or 1)
        esp = bool(m["esp"])
        if nome.startswith("LUA"):
            pose = nome.split(":", 1)[1] if ":" in nome else "sentada"
            im = motor.lua(pose, escala=esc if m["e"] else 2, espello=esp)
            yy = y - (8 if pose in ("salto", "puntillas") else 0)
            if pose not in ("deitada", "durme"):
                motor.sombra(l, x + im.width // 2, y + im.height - 1, im.width // 2 - 4)
            l.pegar(im, x, yy)
            if pose == "salto":
                motor.EFECTOS["salto"](l, x + im.width // 2, y + im.height + 2)
            if pose == "durme":
                motor.zzz(l, x + im.width - 6, y - 4)
        else:
            if nome not in sprites.S:
                raise ValueError(f"{lid}: no hay sprite «{nome}»")
            l.pegar(sprites.img(nome, esc, esp), x, y)
    for tok in (partes[3].split() if len(partes) > 3 else []):
        m = TOKEN.match(tok)
        if not m:
            raise ValueError(f"{lid}: efecto «{tok}»")
        if m["nome"] in motor.EFECTOS:
            motor.EFECTOS[m["nome"]](l, int(m["x"]), int(m["y"]))
        else:  # un sprite pequeño usado como adorno (estrela…)
            l.pegar(sprites.img(m["nome"], int(m["e"] or 1)), int(m["x"]), int(m["y"]))
    return lid, l


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--solo")
    ap.add_argument("--folla", help="hoja de contacto con lo pintado")
    a = ap.parse_args()
    liñas = []
    for f in sorted((AQUI / "escenas").glob("*.txt")):
        for ln in f.read_text(encoding="utf-8").splitlines():
            if ln.strip() and not ln.lstrip().startswith("#"):
                if not a.solo or ln.startswith(a.solo):
                    liñas.append(ln)
    feitas = {}
    imaxes = []
    for ln in liñas:
        lid, l = debuxar(ln)
        cid, n = lid.split(".")
        ruta = SAIDA / f"his{cid[4:]}_{n}.png"
        l.gardar(ruta)
        feitas[(cid, int(n))] = f"assets/brand/contos/{ruta.name}"
        imaxes.append(l.im)
    # JSON: imaxe en cada lámina pintada
    for jf in sorted((ROOT / "assets/content/biblioteca").glob("his_*.json")):
        d = json.loads(jf.read_text(encoding="utf-8"))
        cambio = False
        for c in d:
            for i, lam in enumerate(c["laminas"]):
                if (c["id"], i + 1) in feitas and lam.get("imaxe") != feitas[(c["id"], i + 1)]:
                    lam["imaxe"] = feitas[(c["id"], i + 1)]
                    cambio = True
        if cambio:
            jf.write_text(json.dumps(d, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    if a.folla and imaxes:
        from PIL import Image
        cols = 4
        filas = (len(imaxes) + cols - 1) // cols
        o = Image.new("RGB", (cols * (motor.W * 2 + 6), filas * (motor.H * 2 + 6)), "white")
        for k, im in enumerate(imaxes):
            o.paste(im.convert("RGB").resize((motor.W * 2, motor.H * 2), Image.NEAREST),
                    ((k % cols) * (motor.W * 2 + 6), (k // cols) * (motor.H * 2 + 6)))
        o.save(a.folla)
    print(f"OK: {len(feitas)} láminas")


if __name__ == "__main__":
    main()
