#!/usr/bin/env python3
"""O-20261109-3: copia de Valeria el catálogo de premios de Lúa —12 niveles,
18 insignias, 5 coleccionables y los textos de la gata— en gl y es.
Uso: python3 tools/port_premios_valeria.py <ruta-a-valeria>
Escribe assets/content/premios/premios_lua.json."""
import json
import re
import sys
from pathlib import Path

V = Path(sys.argv[1])
gam = (V / "src/valeriaGamification.ts").read_text(encoding="utf-8")
tip = (V / "src/types/valeriaLua.ts").read_text(encoding="utf-8")


def bloque(txt, clave):
    i = txt.index(clave)
    j = txt.index("}[id]", i)
    return dict(re.findall(r"(\w+): '((?:[^'\\]|\\.)*)'", txt[i:j]))


def textos(lang):
    t = (V / f"src/i18n/strings.{lang}.ts").read_text(encoding="utf-8")
    aw = t[t.index("  awards: {"):]
    niv = t[t.index("levelNameByIndex"):]
    niv = re.findall(r"'([^']+)'", niv[:niv.index("]")])
    un = lambda k: re.search(rf"{k}: '((?:[^'\\]|\\.)*)'", t).group(1)
    return {
        "niveis": niv,
        "insignia": bloque(aw, "badgeName:"),
        "insigniaDi": bloque(aw, "badgeDesc:"),
        "obxecto": bloque(aw, "itemName:"),
        "obxectoCondicion": bloque(aw, "itemUnlockCondition:"),
        "humor": {k: un(k) for k in ("luaPurring", "luaEating", "luaCraving", "luaPatShort", "luaFeedFish")},
        "titulo": re.search(r"title: '([^']+)'", aw).group(1),
        "subtitulo": re.search(r"subtitle: '([^']+)'", aw).group(1),
        "maxNivel": re.search(r"maxLevel: '([^']+)'", aw).group(1),
        "escaleira": re.search(r"levelTrack: '([^']+)'", aw).group(1),
        "armario": re.search(r"wardrobeTitle: '([^']+)'", aw).group(1),
        "posto": re.search(r"itemEquipped: '([^']+)'", aw).group(1),
        "poñer": re.search(r"itemEquipAction: '([^']+)'", aw).group(1),
    }


gl, es = textos("gl"), textos("es")
insignias = [
    {"id": i, "glyph": g, "tier": t,
     "nome": {"gl": gl["insignia"][i], "es": es["insignia"][i]},
     "di": {"gl": gl["insigniaDi"].get(i, ""), "es": es["insigniaDi"].get(i, "")}}
    for i, g, t in re.findall(r"\{ id: '(\w+)', glyph: '(\w+)', tier: '(\w+)' \}", gam)
]
obxectos = []
for m in re.finditer(r"\{\s*id: '(\w+)',[^}]*?slot: '(\w+)',[^}]*?(required\w+): (\d+),", tip, re.S):
    i, slot, req, n = m.groups()
    obxectos.append({"id": i, "slot": slot, "require": {"requiredSessions": "sesions",
                     "requiredStreak": "racha", "requiredLevel": "nivel"}[req], "n": int(n),
                     "nome": {"gl": gl["obxecto"][i], "es": es["obxecto"][i]},
                     "condicion": {"gl": gl["obxectoCondicion"][i], "es": es["obxectoCondicion"][i]}})
out = {
    "fuente": "FrankBetances/Valeria:src/valeriaGamification.ts, src/types/valeriaLua.ts y src/i18n/strings.{gl,es}.ts",
    "xpPorNivel": int(re.search(r"XP_PER_LEVEL = (\d+)", gam).group(1)),
    "niveis": [{"gl": a, "es": b} for a, b in zip(gl["niveis"], es["niveis"])],
    "insignias": insignias,
    "obxectos": obxectos,
    "textos": {k: {"gl": gl[k], "es": es[k]} for k in ("titulo", "subtitulo", "maxNivel", "escaleira", "armario", "posto", "poñer")},
    "humor": {k: {"gl": gl["humor"][k], "es": es["humor"][k]} for k in gl["humor"]},
}
Path("assets/content/premios/premios_lua.json").write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
print(f"escrito: {len(out['niveis'])} niveis, {len(insignias)} insignias, {len(obxectos)} obxectos")
