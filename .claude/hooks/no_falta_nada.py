#!/usr/bin/env python3
"""Hook Stop (Frank, 9/11/2026, F-20261109-4).

Nació de que Claude Code escribió «De tu orden no falta nada» con 11
criterios de docs/ORDENES.md sin cumplir; Frank subió la app a Play Store
creyendo que estaba todo hecho.

Si el último mensaje de Claude Code dice que no falta nada, que está todo
hecho, listo o terminado, y en docs/ORDENES.md queda algún criterio sin
marcar, bloquea el final del turno y obliga a decir, con números, qué falta."""
import json
import re
import sys
from pathlib import Path

try:
    datos = json.load(sys.stdin)
except Exception:
    sys.exit(0)
if datos.get("stop_hook_active"):
    sys.exit(0)

ultimo = ""
try:
    for linea in Path(datos.get("transcript_path", "")).read_text(encoding="utf-8").splitlines():
        try:
            ev = json.loads(linea)
        except Exception:
            continue
        msg = ev.get("message") or {}
        if ev.get("type") == "assistant" and isinstance(msg.get("content"), list):
            txt = " ".join(c.get("text", "") for c in msg["content"] if c.get("type") == "text")
            if txt.strip():
                ultimo = txt
except Exception:
    sys.exit(0)

AFIRMA = re.compile(
    r"no falta nada|todo (está )?hecho|está (todo )?(hecho|listo|terminado)|"
    r"listo para (subir|publicar|la tienda|play)|ya (está|esta) todo|"
    r"orden cumplida|completad[ao] entera",
    re.IGNORECASE,
)
# Lo citado entre comillas («…») no es una afirmación propia: citar el
# «no falta nada» de antes para reconocer el fallo no debe bloquear.
propio = re.sub(r"«[^»]*»|“[^”]*”|\"[^\"]*\"", "", ultimo)
if not AFIRMA.search(propio):
    sys.exit(0)

raiz = Path(datos.get("cwd") or ".")
ordenes = raiz / "docs" / "ORDENES.md"
if not ordenes.exists():
    sys.exit(0)
abiertos, orden = [], None
for l in ordenes.read_text(encoding="utf-8").splitlines():
    if l.startswith("## O-") and "AAAAMMDD" not in l:
        orden = l[3:].split(" · ")[0]
    elif orden and l.startswith("- [ ] "):
        abiertos.append(f"{orden}: {l[6:].split(' · evidencia')[0][:120]}")
if not abiertos:
    sys.exit(0)
print(json.dumps({
    "decision": "block",
    "reason": (
        f"Has escrito que no falta nada / está hecho, pero docs/ORDENES.md tiene "
        f"{len(abiertos)} criterios sin cumplir. Reescribe el informe empezando "
        "por «De tus órdenes falta: N criterios» y nómbralos, y no digas que "
        "algo está listo para la tienda mientras falten:\n- " + "\n- ".join(abiertos)
    ),
}, ensure_ascii=False))
