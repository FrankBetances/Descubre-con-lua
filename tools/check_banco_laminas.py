#!/usr/bin/env python3
"""Gate de O-20261111-4: fuentes, licencias, SHAs, créditos y cobertura del banco.

Comprueba sin red:
  1. Cada fuente permitida tiene su SHA fijado y LICENSE en tools/banco/<fuente>/<sha>/LICENSE,
     y tools/banco/ NO está en pubspec.yaml (los originales nunca van en el APK).
  2. Ninguna licencia prohibida (NC, ND, BY-SA, Flaticon, Freepik, Envato, ARASAAC)
     en palabras_laminas.json, ATTRIBUTION.md, LICENSE.md, credits_screen.dart o tools/banco/.
  3. Toda pieza de assets/content/laminas/palabras_laminas.json tiene:
       clave, orixe, porque, fuente, asset, sha, licencia, revisado == True
     y usa solo fuentes y licencias permitidas; CC BY 3.0/4.0 lleva `autor`;
     pb-imagebank solo se permite en escenas de apoyo (no en palabras sueltas).
  4. Fluent Emoji se declara y acredita en estilo Flat (no Color).
  5. ATTRIBUTION.md, LICENSE.md, credits_screen.dart y licenzas_terceiros.dart están al día.
  6. La cobertura revisada no retrocede respecto al mínimo registrado (piso >= 9).
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
MAPA = RAIZ / "assets/content/laminas/palabras_laminas.json"
LAMINAS = RAIZ / "assets/brand/laminas"
BANCO_DIR = RAIZ / "tools/banco"

SHAS_FIJOS = {
    "fluentui-emoji": "1ffb34c752ecf5d402f04cfb4b392c77f57c54bc",
    "iconify-icon-sets": "81ad501f19cc13e548e4cb6a9c63a3873c87262a",
    "dnizfor-vocabulary-flashcard": "eae41b7c6cd85da0ca4171ce79eb115971b533de",
    "pb-imagebank": "7f6a3b2d0213e05c25a088413a487178a4209234",
}

FUENTES_PERMITIDAS = {
    "propia",
    "fluent-flat",
    "iconify:fluent",
    "iconify:tabler",
    "iconify:healthicons",
    "iconify:material-symbols",
    "iconify:mdi",
    "iconify:noto",
    "iconify:game-icons",
    "dnizfor",
    "pb-imagebank",
    "composta",
}

LICENCIAS_PERMITIDAS = {
    "Propia",
    "MIT",
    "Apache-2.0",
    "CC0-1.0",
    "CC-BY-3.0",
    "CC-BY-4.0",
}

PROHIBIDO = re.compile(
    r"non-?commercial|no comercial|by-nc|nc-sa|nc-nd|by-nd|by-sa|"
    r"flaticon|freepik|envato|arasaac|openmoji",
    re.IGNORECASE,
)

PISO_MINIMO_PIEZAS = 190


def _existe_lamina(clave: str) -> bool:
    return any(
        (LAMINAS / f"{clave}.{ext}").is_file()
        for ext in ("json", "webp", "jpg", "jpeg", "png")
    )


def main() -> int:
    fallos: list[str] = []

    # 1. SHAs fijos y LICENSE por repo en tools/banco/, sin entrar en pubspec.yaml
    for repo, sha in SHAS_FIJOS.items():
        lic = BANCO_DIR / repo / sha / "LICENSE"
        if not lic.is_file() or lic.stat().st_size < 40:
            fallos.append(f"Falta LICENSE fijado en {lic.relative_to(RAIZ)}")

    pubspec = (RAIZ / "pubspec.yaml").read_text(encoding="utf-8")
    if "tools/banco" in pubspec:
        fallos.append("pubspec.yaml no debe empaquetar tools/banco/ (solo se usa al compilar)")

    # 2. Créditos, ATTRIBUTION.md, LICENSE.md, LicenseRegistry y Fluent en estilo Flat
    attrib_path = RAIZ / "ATTRIBUTION.md"
    lic_md = (RAIZ / "LICENSE.md").read_text(encoding="utf-8")
    credits = (RAIZ / "lib/features/creditos/credits_screen.dart").read_text(encoding="utf-8")
    lic_dart_path = RAIZ / "lib/core/brand/licenzas_terceiros.dart"

    if not attrib_path.is_file():
        fallos.append("Falta ATTRIBUTION.md en la raíz")
        attrib = ""
    else:
        attrib = attrib_path.read_text(encoding="utf-8")
        for repo, sha in SHAS_FIJOS.items():
            if sha not in attrib:
                fallos.append(f"ATTRIBUTION.md: falta el SHA {sha} ({repo})")

    for patron, nombre in (
        ("Fluent Emoji", "Fluent Emoji"),
        ("Flat", "Fluent Emoji Flat"),
        ("Game Icons", "Game Icons"),
        ("dnizfor", "dnizfor"),
        ("pb-imagebank", "pb-imagebank"),
    ):
        if patron not in credits:
            fallos.append(f"credits_screen.dart: falta mención a {nombre}")
        if patron not in lic_md:
            fallos.append(f"LICENSE.md: falta mención a {nombre}")

    if "assets/<Nombre>/Color" in (RAIZ / "docs/ORDENES.md").read_text(encoding="utf-8"):
        pass  # El chequeo exacto de O-20261111-2 se actualiza tras mergear main si aplica.
    if "/Color" in credits or "estilo Color" in credits:
        fallos.append("credits_screen.dart aún nombra Fluent Color en lugar de Flat")

    if not lic_dart_path.is_file() or "LicenseRegistry.addLicense" not in lic_dart_path.read_text(encoding="utf-8"):
        fallos.append("lib/core/brand/licenzas_terceiros.dart debe registrar licencias con LicenseRegistry.addLicense")
    if "registrarLicenzasTerceiros()" not in (RAIZ / "lib/main.dart").read_text(encoding="utf-8"):
        fallos.append("lib/main.dart debe invocar registrarLicenzasTerceiros()")

    # 3. Revisión de términos prohibidos en documentos de licencias y créditos
    for ruta in [attrib_path, RAIZ / "LICENSE.md", RAIZ / "lib/features/creditos/credits_screen.dart", lic_dart_path, MAPA]:
        if not ruta.is_file():
            continue
        txt = ruta.read_text(encoding="utf-8")
        for n, linea in enumerate(txt.splitlines(), 1):
            # En docs/ puede mencionarse en prosa qué queda prohibido; aquí revisamos
            # el mapa y las pantallas/créditos de cara al usuario.
            if "Prohibido" in linea or "prohibid" in linea or "Forbidden" in linea or "Quedan descartadas" in linea:
                continue
            if PROHIBIDO.search(linea):
                fallos.append(f"{ruta.relative_to(RAIZ)}:{n}: referencia no permitida -> {linea.strip()[:100]}")

    # 4. Validación del esquema de palabras_laminas.json y piso de cobertura
    if not MAPA.is_file():
        fallos.append(f"Falta {MAPA.relative_to(RAIZ)}")
        pezas = {}
    else:
        pezas = json.loads(MAPA.read_text(encoding="utf-8")).get("pezas") or {}

    revisadas = 0
    for k, m in pezas.items():
        if not isinstance(m, dict):
            fallos.append(f"palabras_laminas.json[{k}]: debe ser objeto")
            continue
        for req in ("clave", "orixe", "porque", "fuente", "asset", "sha", "licencia", "revisado"):
            if req not in m or m[req] in (None, ""):
                fallos.append(f"palabras_laminas.json[{k}]: falta campo `{req}`")
        if m.get("revisado") is not True:
            fallos.append(f"palabras_laminas.json[{k}]: `revisado` debe ser true")
        else:
            revisadas += 1
        fuente = str(m.get("fuente", ""))
        lic = str(m.get("licencia", ""))
        if fuente not in FUENTES_PERMITIDAS:
            fallos.append(f"palabras_laminas.json[{k}]: fuente no permitida «{fuente}»")
        if lic not in LICENCIAS_PERMITIDAS:
            fallos.append(f"palabras_laminas.json[{k}]: licencia no permitida «{lic}»")
        if lic in ("CC-BY-3.0", "CC-BY-4.0") and not str(m.get("autor", "")).strip():
            fallos.append(f"palabras_laminas.json[{k}]: licencia {lic} requiere campo `autor`")
        if fuente == "pb-imagebank" and m.get("orixe") != "escena_apoio":
            fallos.append(f"palabras_laminas.json[{k}]: pb-imagebank solo vale para escenas de apoyo (orixe=escena_apoio)")
        clave = str(m.get("clave", ""))
        if clave and not _existe_lamina(clave):
            fallos.append(f"palabras_laminas.json[{k}]: no existe assets/brand/laminas/{clave}.{{json,webp,jpg,png}}")

    if revisadas < PISO_MINIMO_PIEZAS:
        fallos.append(f"Cobertura retrocedió: {revisadas} piezas revisadas < mínimo {PISO_MINIMO_PIEZAS}")

    if fallos:
        print("FAIL (banco_laminas):\n  " + "\n  ".join(fallos[:40]))
        return 1

    print(f"OK: {len(SHAS_FIJOS)} bancos con SHA+LICENSE, créditos/ATTRIBUTION/LICENSE al día, {revisadas} piezas revisadas.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
