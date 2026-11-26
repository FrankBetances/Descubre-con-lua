#!/usr/bin/env python3
"""Auditoría de niveles por edad, repaso y progresión semana a semana.

O-20261126-1 (Frank, 26/11/2026). Lee el contenido generado, no lo cambia:
- assets/content/leccions/leccions.json (2-3 … 5-6 y la lección de 0-2),
- assets/content/acopros/proxectos_0_2.json (las palabras que ve 0-2 en casa),
- assets/content/gramatica/gramatica.json (los 48 puntos y su nivel MCER).

Sin argumentos imprime el informe y sale con 0. Con `--gate` sale con 1 si
se incumple alguno de los umbrales del plan (docs/AUDITORIA_NIVELES_Y_REPASO.md,
sección 4). Con `--gate` NO está en tools/gates.sh: hoy el contenido los
incumple todos y conectarlo tumbaría CI (R000). Se conecta en la fase que
corrige cada umbral.
"""
from __future__ import annotations

import json
import statistics as st
import sys
from collections import Counter
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
C = RAIZ / "assets" / "content"

# Umbrales propuestos en el plan (sección 4). Los decide Frank.
TECHO_MCER = {"curso_0_2": None, "curso_2_3": "A1", "curso_3_4": "A1",
              "curso_4_5": "A2", "curso_5_6": "A2"}
MAX_FRASE = {"curso_0_2": 3, "curso_2_3": 4, "curso_3_4": 5,
             "curso_4_5": 6, "curso_5_6": 7}
MAX_SALTO = 2          # palabras de más en la frase de una semana a la siguiente
MIN_VUELTAS = 4        # veces que vuelve cada palabra nueva en el curso
ORDE_MCER = ["A1", "A2", "B1", "B2", "C1"]


def semanas(curso: dict) -> list[tuple[dict, dict]]:
    return [(u, l) for u in curso["unidades"] for l in u["leccions"]]


def auditar_leccions(fallos: list[str]) -> None:
    d = json.loads((C / "leccions" / "leccions.json").read_text())
    pendientes_siguiente: set[str] = set()
    for cid, cv in d["cursos"].items():
        ws = semanas(cv)
        intro: dict[str, int] = {}
        vueltas: Counter[str] = Counter()
        desfases: list[int] = []
        previas = 0
        frases: list[int] = []
        tipos: Counter[str] = Counter()
        repaso_semanas = sum(1 for _, l in ws if l.get("tipo") == "repaso")
        for i, (_, l) in enumerate(ws):
            for p in l.get("novas") or []:
                if p.get("en"):
                    intro.setdefault(p["en"].lower(), i)
                    tipos[p.get("tipo", "?")] += 1
            for p in (l.get("xaSabe") or []) + (l.get("repasa") or []):
                w = (p.get("en") or "").lower()
                if not w:
                    continue
                vueltas[w] += 1
                if w in intro:
                    desfases.append(i - intro[w])
                else:
                    previas += 1
            fg = (l.get("fraseGramatica") or {}).get("en")
            if fg:
                frases.append(len(fg.split()))
        saltos = [b - a for a, b in zip(frases, frases[1:])]
        grandes = [s for s in saltos if s > MAX_SALTO]
        niveles = [(u.get("gramatica") or {}).get("nivel") for u in cv["unidades"]]
        puntos = [(u.get("gramatica") or {}).get("n") for u in cv["unidades"]]
        con_margen = {w for w, j in intro.items() if (len(ws) - 1 - j) >= 16}
        pocas = [w for w in con_margen if vueltas[w] < MIN_VUELTAS]
        lejos = sum(1 for x in desfases if x > 4)
        sem1_xa = {
            (p.get("en") or "").lower()
            for p in (ws[0][1].get("xaSabe") or [])
            if p.get("en")
        }
        faltan_tardias = sorted(pendientes_siguiente - sem1_xa)

        print(f"\n== {cid} · {len(ws)} semanas")
        print(f"  palabras nuevas distintas: {len(intro)} · tipos: {dict(tipos)}")
        print(f"  semanas de repaso: {repaso_semanas} de {len(ws)}")
        print(
            f"  vuelven menos de {MIN_VUELTAS} veces (>=16 sem. por delante): "
            f"{len(pocas)} de {len(con_margen)}"
        )
        if desfases:
            print(f"  vuelven tras >4 semanas: {lejos} de {len(desfases)} "
                  f"(máximo {max(desfases)} semanas)")
        print(f"  la semana 1 da por sabidas {previas} palabras de otro curso")
        print(f"  frase de la unidad, palabras por semana: {frases}")
        print(f"  saltos de más de {MAX_SALTO} palabras entre semanas: {len(grandes)}")
        print(f"  gramática por mes (punto de 48, MCER): {list(zip(puntos, niveles))}")

        techo = TECHO_MCER[cid]
        if techo:
            pasa = [n for n in niveles if n and ORDE_MCER.index(n) > ORDE_MCER.index(techo)]
            if pasa:
                fallos.append(f"{cid}: {len(pasa)} meses por encima de {techo}")
        if frases and max(frases) > MAX_FRASE[cid]:
            fallos.append(f"{cid}: frase de {max(frases)} palabras (techo {MAX_FRASE[cid]})")
        if grandes:
            fallos.append(f"{cid}: {len(grandes)} saltos de dificultad entre semanas")
        if pocas:
            fallos.append(f"{cid}: {len(pocas)} palabras vuelven menos de {MIN_VUELTAS} veces")
        if faltan_tardias:
            fallos.append(
                f"{cid}: faltan {len(faltan_tardias)} palabras tardías del curso anterior en semana 1 xaSabe"
            )
        if desfases and lejos == 0:
            fallos.append(f"{cid}: ninguna palabra vuelve pasado un mes")
        if repaso_semanas == 0:
            fallos.append(f"{cid}: ninguna semana de repaso")
        pendientes_siguiente = {w for w, j in intro.items() if (len(ws) - 1 - j) < 16}


def auditar_0_2(fallos: list[str]) -> None:
    p = json.loads((C / "acopros" / "proxectos_0_2.json").read_text())["proxectos"]
    todas: Counter[str] = Counter()
    print("\n== curso_0_2 · palabras de casa (proxectos_0_2.json)")
    for pr in p:
        ws = [w["en"] for w in pr["palabras"]]
        todas.update(w.lower() for w in ws)
        largas = [w for w in ws if len(w.split()) > 1 and not w.endswith("!")]
        print(f"  mes {pr['mesCalendario']:>2}: {len(ws)} palabras, "
              f"{len(largas)} de dos o más palabras")
    repetidas = sum(1 for v in todas.values() if v > 1)
    print(f"  distintas en el curso: {len(todas)} · vuelven otro mes: {repetidas}")
    if repetidas < len(todas) // 2:
        fallos.append(f"curso_0_2: solo {repetidas} de {len(todas)} palabras vuelven otro mes")


def main() -> int:
    fallos: list[str] = []
    auditar_leccions(fallos)
    auditar_0_2(fallos)
    print(f"\nUmbrales del plan incumplidos: {len(fallos)}")
    for f in fallos:
        print(f"  - {f}")
    if "--gate" in sys.argv[1:] and fallos:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
