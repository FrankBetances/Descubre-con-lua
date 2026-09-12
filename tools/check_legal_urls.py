#!/usr/bin/env python3
"""Comprueba que las páginas legales declaradas en Play Console se sirven.

  python3 tools/check_legal_urls.py --offline   # solo los ficheros (va en gates.sh)
  python3 tools/check_legal_urls.py             # además pide las URLs por red

Existe por lo que le pasó a Valeria+ el 19/8/2026: Google rechazó la ficha con
«URL provided ... does not link to a valid privacy policy page, HTTP server is
returning 404» teniendo el fichero intacto en el repositorio y el último
despliegue de Pages en verde. No se rompió el contenido: se apagó el sitio, y
volver a encenderlo no es automático.

Ese fallo es MUDO. No hay run rojo, no hay push, no hay nada que mirar; aparece
semanas después por boca de Google, con la publicación parada. Un despliegue
correcto no demuestra que el sitio esté vivo. Lo único que lo demuestra es pedir
la URL.
"""
from __future__ import annotations

import sys
import urllib.error
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DOCS = ROOT / "docs"

# El esquema de URL de un sitio de proyecto en GitHub Pages: el usuario en
# minúsculas, el nombre del repositorio tal cual. Valeria+ sirve sus páginas
# legales en https://frankbetances.github.io/Valeria/, y esta es la misma cuenta.
BASE = "https://frankbetances.github.io/Descubre-con-lua/"

CONTACT_EMAIL = "frank.alberto.betances.reinoso@gmail.com"

# Lo que Play Console tiene (o tendrá) declarado. Si cambia aquí, hay que
# cambiarlo también allí: Google contrasta lo declarado con lo que se sirve.
PAGES = [
    {
        "file": "privacy.html",
        "label": "Política de privacidad",
        "mark": "Política de Privacidad",
    },
    {
        "file": "index.html",
        "label": "Página del proyecto",
        "mark": "Descubre con Lúa",
    },
]

TIMEOUT = 20


def check_files() -> list[str]:
    """La mitad local: caza un fichero renombrado o borrado antes de desplegar."""
    failures: list[str] = []
    for page in PAGES:
        path = DOCS / page["file"]
        url = BASE + page["file"]
        if not path.exists():
            failures.append(f"docs/{page['file']} no existe, y {url} es la {page['label']}.")
            continue
        html = path.read_text(encoding="utf-8", errors="replace")
        if page["mark"] not in html:
            failures.append(
                f"docs/{page['file']} ya no contiene «{page['mark']}»: "
                "Google valida que la página sea lo que dice ser."
            )
        if CONTACT_EMAIL not in html:
            failures.append(f"docs/{page['file']} no lleva el correo de contacto del proyecto.")
        print(f"  OK  docs/{page['file']}")
    return failures


def check_network() -> list[str]:
    """La mitad de red: es la única que detecta el sitio apagado."""
    failures: list[str] = []
    for page in PAGES:
        url = BASE + page["file"]
        try:
            request = urllib.request.Request(url, headers={"User-Agent": "descubre-con-lua-gate"})
            with urllib.request.urlopen(request, timeout=TIMEOUT) as response:
                status = response.status
                body = response.read().decode("utf-8", errors="replace")
        except urllib.error.HTTPError as error:
            failures.append(f"{url} devuelve HTTP {error.code} ({page['label']}).")
            continue
        except Exception as error:  # red caída, DNS, TLS
            failures.append(f"{url} no se pudo pedir: {error}")
            continue

        if status != 200:
            failures.append(f"{url} devuelve HTTP {status} ({page['label']}).")
        elif page["mark"] not in body:
            failures.append(
                f"{url} responde 200 pero no contiene «{page['mark']}»: "
                "puede ser la 404 de GitHub Pages, que se sirve con 200 en algunos casos."
            )
        else:
            print(f"  OK  {url}")
    return failures


def main() -> int:
    offline = "--offline" in sys.argv

    print("Ficheros legales en docs/:")
    failures = check_files()

    if not offline:
        print(f"\nPidiendo las URLs publicadas ({BASE}):")
        failures += check_network()
    else:
        print("\n(--offline: no se piden las URLs por red)")

    if failures:
        print("\nFAIL: las páginas legales no están como Play Console espera:", file=sys.stderr)
        for line in failures:
            print(f"  {line}", file=sys.stderr)
        return 1

    scope = "los ficheros" if offline else "los ficheros y las URLs publicadas"
    print(f"\nOK: {scope} coinciden con lo declarado.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
