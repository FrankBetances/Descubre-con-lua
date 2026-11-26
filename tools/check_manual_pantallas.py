#!/usr/bin/env python3
"""F-20261126-9: el manual enseña cada pantalla de la app, en gallego y castellano.

docs/manual-casos-de-uso.html tiene que llevar, en pareja gl/es, la captura de
cada pantalla de OBLIGADAS. Cada captura que cita existe y tiene su pareja en
la otra lengua. Pasó el 26/11/2026: P11 llegó a main con siete pantallas nuevas
y el manual no enseñaba ninguna.

Una pantalla nueva entra aquí en el mismo cambio que la crea, con su captura
en test/capturas_test.dart.
"""
import re
import sys
from pathlib import Path

DOCS = Path(__file__).resolve().parent.parent / "docs"
MANUAL = DOCS / "manual-casos-de-uso.html"
OBLIGADAS = [
    "bienvenida", "rexistro-crianza", "p11-proba-entrada", "p11-hoxe-nenos",
    "leccion-duolingo-paso", "leccion-duolingo-fin", "hoxe-aviso-dia-futuro",
    "p11-marcar", "p11-lua-pregunta", "p11-volven-hoxe", "p11-capa",
    "p11-reto-irmans", "proxecto-0-2", "calendario-leccions-casa",
    "explorar-familias", "guia-ingles", "casa-ponte-ao-dia", "folla-crianza",
    "resultados-crianza", "premios-lua", "p11-tarxeta-escola", "hoxe-docentes",
    "calendario-leccions-aula", "aula-unidades", "aula-2ciclo-asemblea",
    "steam-hub", "conto-palabras", "microcuento-aula", "recursos-docentes",
    "cancion-pulso", "estimulacion", "ar-lua",
]


def main() -> int:
    t = MANUAL.read_text(encoding="utf-8")
    citadas = re.findall(r'src="capturas/([a-z0-9-]+)-(gl|es)\.png"', t)
    por_nome = {}
    for nome, l in citadas:
        por_nome.setdefault(nome, set()).add(l)
    fallos = []
    for nome, ls in por_nome.items():
        if ls != {"gl", "es"}:
            fallos.append(f"«{nome}»: solo en {', '.join(sorted(ls))}")
        for l in ls:
            if not (DOCS / "capturas" / f"{nome}-{l}.png").exists():
                fallos.append(f"«{nome}-{l}.png» no existe")
    for nome in OBLIGADAS:
        if nome not in por_nome:
            fallos.append(f"la pantalla «{nome}» no sale en el manual")
    if fallos:
        print("FALLO (manual):\n  " + "\n  ".join(fallos))
        return 1
    print(f"OK: el manual enseña {len(por_nome)} pantallas, todas en gallego y castellano.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
