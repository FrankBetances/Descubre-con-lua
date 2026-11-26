#!/usr/bin/env python3
"""F-20261126-2: ninguna orden ya mergeada sigue diciendo que falta el merge.

Una orden de docs/ORDENES.md cuya línea «Reparto:» nombra un bloque de pasos
(«P10.0–P10.9») no puede tener abierto un criterio «mergeado en main» si la
historia de HEAD ya tiene el commit del ÚLTIMO paso del bloque («P10.9: …»):
ese commit solo llega a main con la entrega mergeada. Pasó el 26/11/2026: la
evidencia del merge #66 se quedó en una rama sin mergear, ORDENES.md siguió
diciendo que faltaba y Claude Code se lo repitió a Frank como pendiente.

No mira títulos de merge: un PR de Claude Code que solo guarda el prompt de un
bloque («P11, …») no es la entrega del bloque.
"""
import re
import subprocess
import sys
from pathlib import Path

ORDENES = Path("docs/ORDENES.md")


def asuntos() -> set[str] | None:
    # Lo que está en main, no lo que lleva la rama en la que se trabaja: una
    # entrega que aún vive en una rama no está mergeada (26/11/2026, la rama
    # de integración llevaba P11.11 y la guarda la daba por mergeada).
    ref = "HEAD"
    for candidato in ("origin/main", "main"):
        if subprocess.run(["git", "rev-parse", "--verify", "-q", candidato],
                          capture_output=True).returncode == 0:
            ref = candidato
            break
    r = subprocess.run(["git", "log", "--no-merges", "--format=%s", ref],
                       capture_output=True, text=True)
    if r.returncode != 0 or not r.stdout.strip():
        return None
    return {m.group(1) for s in r.stdout.splitlines()
            if (m := re.match(r"(P\d+\.\d+):", s))}


def main() -> int:
    hechos = asuntos()
    if hechos is None:
        print("SALTADO: sin historia en este clon.")
        return 0
    fallos = []
    for bloque in re.split(r"^## (?=O-\d{8}-\d+)", ORDENES.read_text(encoding="utf-8"),
                           flags=re.M)[1:]:
        nome = bloque.split(" ", 1)[0]
        reparto = re.search(r"^Reparto:(.*)$", bloque, re.M)
        if not reparto:
            continue
        abertos = [l for l in bloque.splitlines()
                   if l.startswith("- [ ]") and "mergeado en main" in l]
        if not abertos:
            continue
        ultimo: dict[str, int] = {}
        for b, n in re.findall(r"\b(P\d+)\.(\d+)", reparto.group(1)):
            ultimo[b] = max(ultimo.get(b, -1), int(n))
        for b, n in sorted(ultimo.items()):
            if f"{b}.{n}" in hechos:
                fallos.append(f"{nome}: {b}.{n} ya está en la historia y el "
                              f"criterio de merge sigue abierto")
    if fallos:
        print("FALLO (órdenes atrasadas):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: ninguna orden con su bloque entregado tiene abierto el merge.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
