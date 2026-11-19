#!/usr/bin/env python3
"""Gate de O-20261111-2: cada pieza que se enseña tiene SU lámina.

Recorre, sin listas de exclusión:
- assets/content/leccions/leccions.json: xaSabe, novas, repasa y la frase de
  gramática de cada lección (los pasos de la lección de Duolingo y las
  «palabras do día»);
- assets/content/tpr/**/*.json: las palabras del banco (el TPR del día);
- assets/content/acopros/proxectos_0_2.json: las palabras de cada proyecto
  de 0-2, y su canción y su rima (los otros dos pasos de esa lección).

Falla si una pieza no tiene "lamina", si assets/brand/laminas/<lamina>.json
no existe, o si la lámina es de escena de reto (escena_*): esas solo valen
para el paso del reto, nunca como imagen de una palabra.

Uso: python3 tools/check_laminas_leccion.py [--resumo]"""
from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
LAMINAS = RAIZ / "assets/brand/laminas"
CONTIDO = RAIZ / "assets/content"


def pezas():
    """(conxunto, onde, en, lamina) de cada pieza enseñada."""
    lec = json.loads((CONTIDO / "leccions/leccions.json").read_text(encoding="utf-8"))
    for curso, c in lec["cursos"].items():
        for u in c["unidades"]:
            for l in u["leccions"]:
                for k in ("xaSabe", "novas", "repasa"):
                    for p in l.get(k) or []:
                        yield "leccions", f"{l['id']} {k}", p.get("en", ""), p.get("lamina")
                f = l.get("fraseGramatica")
                if f:
                    yield "frases", f"{l['id']} fraseGramatica", f.get("en", ""), f.get("lamina")
    for fich in sorted((CONTIDO / "tpr").rglob("*.json")):
        d = json.loads(fich.read_text(encoding="utf-8"))
        for s in d.get("semanas") or []:
            for w in s.get("palabras") or []:
                yield "tpr", f"{fich.relative_to(CONTIDO)} {w.get('id', '')}", w.get("en", ""), w.get("lamina")
    ac = json.loads((CONTIDO / "acopros/proxectos_0_2.json").read_text(encoding="utf-8"))
    for p in ac["proxectos"]:
        for w in p["palabras"]:
            yield "0-2", f"proxecto mes {p['mesCalendario']}", w.get("en", ""), w.get("lamina")
        # los otros dos pasos de la lección de 0-2: la canción y la rima
        yield "0-2", f"proxecto mes {p['mesCalendario']} canción", p["cancion"].get("es", ""), p["cancion"].get("lamina")
        yield "0-2", f"proxecto mes {p['mesCalendario']} rima", p["rima"].get("en", ""), p["rima"].get("lamina")


TOPE_TPR = Path(__file__).with_name("tope_tpr_sen_lamina.txt")
SIN_BASE_TPR = Path(__file__).with_name("tpr_sin_base_aprobadas.txt")


def main() -> int:
    total, sen, fallos = Counter(), Counter(), []
    distintas_sen: set[str] = set()
    tpr_sen: list[str] = []
    for conxunto, onde, en, lamina in pezas():
        total[conxunto] += 1
        if not lamina:
            sen[conxunto] += 1
            if conxunto == "tpr":
                tpr_sen.append(en.lower().strip(" .!?"))
            distintas_sen.add(en.lower().strip(" .!?"))
            fallos.append(f"{onde}: «{en}» sen lámina")
        elif lamina.startswith("escena_"):
            sen[conxunto] += 1
            fallos.append(f"{onde}: «{en}» usa a lámina de escena de reto {lamina}")
        elif not any((LAMINAS / f"{lamina}.{ext}").is_file() for ext in ("json", "webp", "jpg", "jpeg", "png")):
            sen[conxunto] += 1
            fallos.append(f"{onde}: «{en}» → {lamina} non existe")
    for k in total:
        print(f"  {k}: {total[k]} pezas, {sen[k]} sen lámina válida")
    # O-20261119-1 (Frank, 19/11/2026): lecciones, frases y 0-2 tienen que
    # estar a 0; el banco TPR, mientras Antigravity lo cubre por tandas, no
    # puede subir de su tope (tools/tope_tpr_sen_lamina.txt), que solo baja.
    # El criterio del banco TPR de O-20261111-4 sigue abierto hasta llegar a 0.
    if "--tope-tpr" in sys.argv:
        tope = int(TOPE_TPR.read_text(encoding="utf-8").split()[0])
        resto = [f for f in fallos if not f.startswith("tpr/")]
        # O-20261119-3: las piezas TPR que Frank aprobó dejar sin imagen no cuentan.
        aprobadas = {l.strip() for l in SIN_BASE_TPR.read_text(encoding="utf-8").splitlines()
                     if l.strip() and not l.startswith("#")}
        sen["tpr"] -= sum(1 for en in tpr_sen if en in aprobadas)
        if resto or sen["tpr"] > tope:
            print(f"FALLO: {len(resto)} piezas de lección, frase o 0-2 sin lámina; "
                  f"TPR sin lámina {sen['tpr']} (tope {tope}).")
            for f in resto[:40]:
                print("  " + f)
            return 1
        print(f"OK: lecciones, frases y 0-2 a 0; TPR sin lámina {sen['tpr']} de tope {tope} "
              "(el tope solo baja; criterio TPR de O-20261111-4 abierto).")
        return 0
    if fallos:
        print(f"FALLO (láminas das pezas): {len(fallos)} de {sum(total.values())} pezas sen lámina válida "
              f"({len(distintas_sen)} palabras ou frases distintas).")
        if "--resumo" not in sys.argv:
            for f in fallos[:40]:
                print("  " + f)
            if len(fallos) > 40:
                print(f"  … e {len(fallos) - 40} máis")
        return 1
    print(f"OK: {sum(total.values())} pezas ensinadas, todas coa súa lámina.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
