#!/usr/bin/env python3
"""Gate de O-20261111-1: cada escena del contenido tiene su imagen.

Tumba CI si una escena (`escena.gl` en cualquier JSON de assets/content) no
tiene lámina, si la ruta de la lámina no existe o no está al día, o si las
carpetas no están declaradas en pubspec.yaml. Lo hace el propio generador en
modo --check, para que la regla y el dibujo no puedan discrepar."""
import subprocess
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.exit(subprocess.call([sys.executable, str(RAIZ / "tools/gen_escenas_retos.py"), "--check"]))
