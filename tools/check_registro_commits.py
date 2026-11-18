#!/usr/bin/env python3
"""O-20261118-4: cada commit del plan queda registrado para auditarlo paso a paso.

Lee el «Registro de commits» de docs/PLAN_ANTIGRAVITY.md.

Siempre (también en CI, que clona sin historia):
  - cada fila tiene paso (P<n>.<m>) que exista en la tabla de pasos, commit
    (SHA de 7-40 hex o «este» solo en la última fila), fecha AAAA-MM-DD,
    qué cambia en la app, gates y evidencia no vacíos;
  - ningún SHA se repite.

Con historia (en local, antes de cada push):
  - cada commit de <Base>..HEAD que no sea merge empieza por «P<n>.<m>:» y
    ese paso tiene fila en el registro;
  - cada SHA del registro existe y está en <Base>..HEAD.
Sin la base en el clon (CI), esta parte se salta y se dice.
"""
import re
import subprocess
import sys
from pathlib import Path

PLAN = Path("docs/PLAN_ANTIGRAVITY.md")
PASO = re.compile(r"^P\d+\.\d+$")


def git(*a: str) -> str | None:
    r = subprocess.run(["git", *a], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def main() -> int:
    if not PLAN.exists():
        print(f"FALTA {PLAN}")
        return 1
    texto = PLAN.read_text(encoding="utf-8")
    fallos: list[str] = []

    pasos = set(re.findall(r"^\| (P\d+\.\d+) \|", texto.split("## Registro de commits")[0], re.M))
    if not pasos:
        fallos.append("la tabla de pasos no tiene ningún P<n>.<m>")

    m = re.search(r"^Base: `?([0-9a-f]{7,40})`?", texto, re.M)
    base = m.group(1) if m else None
    if not base:
        fallos.append("falta la línea «Base: <sha>» del registro")

    registro = texto.split("## Registro de commits", 1)
    filas: list[list[str]] = []
    if len(registro) < 2:
        fallos.append("falta la sección «## Registro de commits»")
    else:
        for linea in registro[1].splitlines():
            if not re.match(r"^\| P\d+\.\d+ \|", linea):
                continue
            filas.append([c.strip() for c in linea.strip().strip("|").split("|")])

    vistos: set[str] = set()
    for i, f in enumerate(filas):
        if len(f) < 7:
            fallos.append(f"fila {i + 1}: faltan columnas")
            continue
        paso, sha, fecha, que, gates, evid, _rev = f[:7]
        sha = sha.strip("`")
        if not PASO.match(paso) or paso not in pasos:
            fallos.append(f"fila {i + 1}: paso «{paso}» no está en la tabla de pasos")
        if sha == "este":
            if i != len(filas) - 1:
                fallos.append(f"fila {i + 1}: «este» solo vale en la última fila; pon el SHA")
        elif not re.fullmatch(r"[0-9a-f]{7,40}", sha):
            fallos.append(f"fila {i + 1}: commit «{sha}» no es un SHA")
        elif sha in vistos:
            fallos.append(f"fila {i + 1}: SHA {sha} repetido")
        vistos.add(sha)
        if not re.fullmatch(r"\d{4}-\d{2}-\d{2}", fecha):
            fallos.append(f"fila {i + 1}: fecha «{fecha}» no es AAAA-MM-DD")
        for nombre, v in (("qué cambia", que), ("gates", gates), ("evidencia", evid)):
            if not v or v == "—":
                fallos.append(f"fila {i + 1} ({paso}): «{nombre}» vacío")

    es_ancestro = (
        base is not None
        and subprocess.run(["git", "merge-base", "--is-ancestor", base, "HEAD"],
                           capture_output=True).returncode == 0
    )
    if es_ancestro:
        rango = git("log", "--no-merges", "--format=%H %s", f"{base}..HEAD") or ""
        en_rango = set()
        pasos_registro = {f[0] for f in filas if f}
        for linea in rango.splitlines():
            h, _, asunto = linea.partition(" ")
            en_rango.add(h)
            mp = re.match(r"^(P\d+\.\d+):", asunto)
            if not mp:
                fallos.append(f"commit {h[:8]} «{asunto}» no empieza por «P<n>.<m>:»")
            elif mp.group(1) not in pasos_registro:
                fallos.append(f"commit {h[:8]}: el paso {mp.group(1)} no tiene fila en el registro")
        for s in vistos - {"este"}:
            if not any(h.startswith(s) for h in en_rango):
                fallos.append(f"el SHA {s} del registro no está en {base[:8]}..HEAD")
        modo = f"con historia ({len(en_rango)} commits desde {base[:8]})"
    else:
        modo = "sin historia: la base no está en este clon o no es antecesora de HEAD; solo se comprueba la tabla"

    if fallos:
        print("\n".join(f"FALLA: {x}" for x in fallos))
        return 1
    print(f"OK: {len(filas)} commits registrados, {modo}.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
