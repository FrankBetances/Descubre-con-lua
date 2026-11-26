#!/usr/bin/env python3
"""F-20261126-2: ninguna orden ya mergeada sigue diciendo que falta el merge.

Una orden de docs/ORDENES.md cuya línea «Reparto:» nombra pasos (P10.0–P10.9)
no puede tener abierto un criterio «mergeado en main» si la historia ya tiene
un merge cuyo mensaje nombra ese bloque («Merge pull request #66: P10, …»).
Pasó el 26/11/2026: la evidencia del merge #66 se quedó en una rama sin
mergear, ORDENES.md siguió diciendo que faltaba y Claude Code se lo repitió a
Frank como pendiente.

Mira los merges que haya en la historia; si no hay ninguno (clon de un solo
commit), lo dice y sale con 0.
"""
import re
import subprocess
import sys
from pathlib import Path

ORDENES = Path("docs/ORDENES.md")


def merges() -> str | None:
    r = subprocess.run(["git", "log", "--merges", "--format=%s%n%b", "HEAD"],
                       capture_output=True, text=True)
    if r.returncode != 0:
        return None
    # Con la historia que haya: en un clon superficial se ven los merges
    # recientes, que son los que pueden estar atrasados en ORDENES.md.
    return r.stdout if r.stdout.strip() else None


def main() -> int:
    historia = merges()
    if historia is None:
        print("SALTADO: no hay merges en la historia de este clon.")
        return 0
    fallos = []
    for bloque in re.split(r"^## (?=O-\d{8}-\d+)", ORDENES.read_text(encoding="utf-8"),
                           flags=re.M)[1:]:
        nome = bloque.split(" ", 1)[0]
        reparto = re.search(r"^Reparto:(.*)$", bloque, re.M)
        if not reparto:
            continue
        pasos = set(re.findall(r"\b(P\d+)\.\d+", reparto.group(1)))
        abertos = [l for l in bloque.splitlines()
                   if l.startswith("- [ ]") and "mergeado en main" in l]
        for p in sorted(pasos):
            if abertos and re.search(rf"Merge pull request #\d+: {p}\b", historia):
                fallos.append(f"{nome}: el bloque {p} ya está mergeado y el "
                              f"criterio de merge sigue abierto")
    if fallos:
        print("FALLO (órdenes atrasadas):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: ninguna orden mergeada tiene abierto su criterio de merge.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
