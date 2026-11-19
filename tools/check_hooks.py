#!/usr/bin/env python3
"""F-20261119-5: los frenos de Frank se prueban con frases reales.

Copia los hooks a un directorio temporal (no toca el estado de verdad) y
comprueba:
  - «STOP», «para ya», «no hagas nada» paran; las herramientas quedan bloqueadas;
  - «sigue», «arregla», «a» tras un STOP… una orden de hacer desbloquea, aunque
    el mensaje lleve también «para» o «espera» como palabras normales;
  - «para el trabajo de hoy usa esto» NO para (es la preposición);
  - borrar un fichero del proyecto sin permiso se bloquea; con «borra X», no;
  - borrar en /tmp se deja;
  - «qué has hecho» enseña el registro de herramientas;
  - escribir en los hooks se bloquea; leerlos, no.
Si un hook está mal escrito, este gate tumba CI.
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
HOOKS = RAIZ / ".claude" / "hooks"


def main() -> int:
    tmp = Path(tempfile.mkdtemp())
    (tmp / ".claude").mkdir()
    shutil.copytree(HOOKS, tmp / ".claude" / "hooks")
    env = dict(os.environ, CLAUDE_PROJECT_DIR=str(tmp))
    parado = tmp / ".claude" / "estado" / "parado"
    fallos = []

    def hook(nome, datos):
        return subprocess.run([sys.executable, str(tmp / ".claude" / "hooks" / nome)],
                              input=json.dumps(datos), capture_output=True, text=True, env=env)

    def mensaje(t):
        return hook("stop_freno.py", {"prompt": t}).stdout

    def bloquea(datos):
        return any(hook(h, datos).returncode == 2
                   for h in ("freno_herramientas.py", "blindaje.py", "sin_borrar.py"))

    leer = {"tool_name": "Read", "tool_input": {"file_path": str(tmp / "x")}}
    casos_para = ["STOP", "Stop por cierto", "para ya", "no hagas nada"]
    casos_sigue = ["sigue", "Sigue y corrige el freno, para que no pase",
                   "Arregla esto ya", "Restaura todo y mergea", "continúa, espera a CI"]
    for t in casos_para:
        mensaje(t)
        if not parado.exists() or not bloquea(leer):
            fallos.append(f"«{t}» debería parar y bloquear")
        mensaje("sigue")
    for t in casos_sigue:
        mensaje("STOP")
        mensaje(t)
        if parado.exists() or bloquea(leer):
            fallos.append(f"«{t}» debería desbloquear")
    mensaje("sigue")
    mensaje("para el trabajo de hoy usa esto y espera mi revisión")
    if parado.exists():
        fallos.append("«para el trabajo de hoy…» no es una orden de parar")
        mensaje("sigue")

    mensaje("sigue")
    rm = {"tool_name": "Bash", "tool_input": {"command": "rm lib/main.dart"}}
    if not bloquea(rm):
        fallos.append("rm de un fichero del proyecto sin permiso no se bloquea")
    mensaje("borra lib/main.dart")
    if bloquea(rm):
        fallos.append("rm pedido por Frank («borra lib/main.dart») se bloquea")
    mensaje("sigue")
    if bloquea({"tool_name": "Bash", "tool_input": {"command": "rm -rf /tmp/prueba"}}):
        fallos.append("rm en /tmp se bloquea")

    # R-ENTREGA (F-20261119-6): si Frank pide un texto, nada de herramientas
    # hasta su siguiente mensaje.
    for t in ["Dame el prompt ya", "dame el puto prompt joder", "pásame el texto para Antigravity"]:
        mensaje(t)
        if not bloquea(leer):
            fallos.append(f"«{t}» debería bloquear herramientas hasta dar el texto")
        mensaje("vale, sigue")
        if bloquea(leer):
            fallos.append(f"tras «{t}», el mensaje siguiente debería desbloquear")

    hook("registro_acciones.py", {"tool_name": "Bash", "tool_input": {"command": "ls"}})
    if "ls" not in mensaje("qué has hecho"):
        fallos.append("«qué has hecho» no enseña el registro")

    if not bloquea({"tool_name": "Edit", "tool_input": {
            "file_path": str(tmp / ".claude" / "hooks" / "stop_freno.py")}}):
        fallos.append("editar un hook no se bloquea")
    if bloquea({"tool_name": "Bash", "tool_input": {"command": "cat .claude/settings.json"}}):
        fallos.append("leer la configuración se bloquea")

    shutil.rmtree(tmp, ignore_errors=True)
    if fallos:
        print("\n".join(f"FALLA: {f}" for f in fallos))
        return 1
    print(f"OK: frenos probados con {len(casos_para) + len(casos_sigue) + 7} casos reales.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
