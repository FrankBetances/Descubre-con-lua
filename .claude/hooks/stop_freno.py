#!/usr/bin/env python3
"""Hook UserPromptSubmit (Frank, 19/11/2026, R-STOP, R-BORRAR y R-VERDAD).

Nació de tres fallos de Claude Code el 19/11/2026 (F-20261119-1…3): siguió
ejecutando después de que Frank dijera STOP, borró sin permiso y dijo que no
había hecho nada cuando sí.

En cada mensaje de Frank:
  - «stop», «para», «espera», «no hagas nada»… → crea .claude/estado/parado.
    Mientras exista, freno_herramientas.py bloquea TODAS las herramientas.
  - «sigue», «continúa», «adelante», «hazlo», o una orden de hacer
    («restaura», «crea», «mergea», «push»…) sin palabra de parar → la quita.
  - «borra X» / «elimina X» / «quita X» → apunta X en
    .claude/estado/permiso_borrar; sin_borrar.py solo deja borrar lo apuntado.
    Cada mensaje nuevo empieza con la lista vacía.
  - Apunta el mensaje en .claude/estado/registro.log; si Frank pregunta qué
    se ha hecho, o habla de mentir, inyecta lo registrado desde su mensaje
    anterior para contestar con el registro y no de memoria.
"""
import json
import os
import re
import sys
import time
from pathlib import Path

EST = Path(os.environ.get("CLAUDE_PROJECT_DIR", ".")) / ".claude" / "estado"
EST.mkdir(parents=True, exist_ok=True)
PARADO = EST / "parado"
PIDE_TEXTO = EST / "pide_texto"
PERMISO = EST / "permiso_borrar"
REG = EST / "registro.log"

try:
    texto = str(json.load(sys.stdin).get("prompt", ""))
except Exception:
    texto = ""
t = texto.lower()

STOP = re.compile(r"\b(stop|para ya|para todo|p[aá]rate|alto ahí|detente|no hagas nada|no toques nada|quieto)\b")
SIGUE = re.compile(r"^\s*a\s*$|\b(sigue|segue|contin[uú]a|adelante|hazlo|dale|vale,? sigue|restaura|crea|mergea|merge|push|haz|termina|arregla|corrige|ejecuta|lanza)\b")
BORRA = re.compile(r"\b(?:borra|elimina|quita|suprime)\s+([^\n.;,]+)")
QUE_HICISTE = re.compile(r"qu[eé] (has hecho|est[aá]s haciendo|hiciste|has tocado)|mentir|mentiste|mentiroso|sin (mi )?(permiso|consentimiento)|qu[eé] hiciste")

avisos = []
# R-ENTREGA (F-20261119-6): si Frank pide un texto para pegar, la respuesta
# empieza por ese texto, entero y solo, sin herramientas antes. La marca (no
# vacía) bloquea las herramientas hasta su siguiente mensaje, que la vacía.
PIDE = re.compile(r"\b(dame|d[aá]me|p[aá]same|quiero|escr[ií]beme|el)\b[^.?!\n]{0,25}\b(prompt|texto|mensaje)\b")
if PIDE.search(t):
    PIDE_TEXTO.write_text(texto[:300], encoding="utf-8")
    avisos.append("R-ENTREGA: Frank pide un texto. Tu respuesta EMPIEZA por ese texto, completo y solo, sin ninguna herramienta antes. Las herramientas están bloqueadas en esta respuesta.")
else:
    PIDE_TEXTO.write_text("", encoding="utf-8")
# Si Frank ordena seguir, se sigue (Frank, 19/11/2026: «si yo ordeno que se
# siga se siga»): una orden de hacer gana a cualquier palabra de parar.
if STOP.search(t) and not SIGUE.search(t):
    PARADO.write_text(time.strftime("%Y-%m-%d %H:%M:%S") + "\n" + texto[:300], encoding="utf-8")
    avisos.append("R-STOP: Frank ha dicho STOP. Están bloqueadas TODAS las herramientas hasta que diga «sigue», «continúa» o «adelante». Contesta solo con texto.")
elif SIGUE.search(t) and PARADO.exists():
    PARADO.unlink()

PERMISO.write_text("\n".join(m.strip() for m in BORRA.findall(t)) + "\n", encoding="utf-8")

previo = REG.read_text(encoding="utf-8").split("=== MENSAJE DE FRANK") if REG.exists() else [""]
desde = previo[-1] if len(previo) > 1 else ""
with REG.open("a", encoding="utf-8") as f:
    f.write(f"=== MENSAJE DE FRANK {time.strftime('%Y-%m-%d %H:%M:%S')}: {texto[:160]!r}\n")
if QUE_HICISTE.search(t):
    acciones = [l for l in desde.splitlines()[1:] if l.strip()]
    avisos.append("R-VERDAD-ACCIONES: contesta SOLO con este registro de herramientas desde el mensaje anterior de Frank, sin añadir ni quitar nada:\n"
                  + ("\n".join(acciones[-60:]) or "(ninguna herramienta ejecutada)"))

avisos.append("R-STEAM: el eje de toda la app es el pensamiento STEAM aplicado a la estimulación del lenguaje; todo contenido nombra el STEAM del mes. R-BORRAR: nada se borra, quita o sustituye sin que Frank lo pida con palabras.")
print("\n".join(avisos))
