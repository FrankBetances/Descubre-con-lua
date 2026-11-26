#!/usr/bin/env python3
"""F-20261126-3: antes de decirle a Frank qué pegarle a Antigravity, se mira por dónde va.

Lista las ramas antigravity/* del remoto con sus commits fuera de main y el
último paso «P<n>.<m>» de cada una. Si un bloque de pasos ya tiene commits o
Frank dice que ya se lo pasó, un cambio al prompt se da como CORRECCIÓN para
pegar sobre el trabajo en curso, nunca como prompt nuevo. Solo lee; no cambia
nada. Sin red, lo dice y sale con 0.
"""
import re
import subprocess
import sys


def git(*a: str) -> str | None:
    r = subprocess.run(["git", *a], capture_output=True, text=True)
    return r.stdout if r.returncode == 0 else None


def main() -> int:
    if git("fetch", "-q", "origin", "refs/heads/antigravity/*:refs/remotes/origin/antigravity/*") is None:
        print("SIN RED: no se puede mirar el remoto; pregúntale a Frank si Antigravity ya empezó.")
        return 0
    ramas = (git("branch", "-r", "--list", "origin/antigravity/*") or "").split()
    for r in ramas:
        log = (git("log", "--format=%s", r, "^origin/main") or "").splitlines()
        pasos = [m.group(0) for s in log if (m := re.match(r"P\d+\.\d+", s))]
        print(f"{r}: {len(log)} commits fuera de main; último paso {pasos[0] if pasos else 'ninguno'}")
    if not ramas:
        print("Ninguna rama antigravity/* en el remoto.")
    print("Recuerda: si Frank ya le pasó el prompt, el cambio va como corrección, no como prompt nuevo.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
