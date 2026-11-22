#!/usr/bin/env python3
"""P10.1 (O-20261122-1): en Galicia se dice neno/nena (y niño/niña en es),
no «criatura», «criaturas», «crianza», «crianzas» ni «criança».

Falla si esas palabras aparecen en:
  - texto visible de assets/content/ (valores JSON, .txt, .md);
  - cadenas de texto de lib/**/*.dart (excluidos comentarios, directivas y
    expresiones de interpolación ${...});
  - docs/*.html y README.md.

Excepciones explícitas y justificadas (solo identificadores internos de código
o claves de almacenamiento que no pueden renombrarse sin romper datos guardados):
  - paraCriaturas: clave JSON de assets/content/gramatica/gramatica.json.
  - criancas.json: nombre del fichero local de almacenamiento en casa.
  - folla_crianza, crianza_resultados, crianza_, crianza_engadir,
    crianza_editar, crianza_borrar, crianza_borrar_si, resultados_crianza,
    rexistro_crianza: claves Key(...) internas de Flutter en lib/features/criancas/.
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent

PALABRAS_GALICIA = re.compile(
    r"\b(?:criaturas?|crianzas?|crianças?)\b",
    re.IGNORECASE,
)

# Claves JSON internas que no son texto visible.
CLAVES_JSON_EXENTAS: frozenset[str] = frozenset({
    "paraCriaturas",
})

# Cadenas literales de Dart que son exclusivamente identificadores internos
# (nombres de fichero local o claves Key(...) de widget), nunca texto visible.
CADENAS_DART_EXENTAS: frozenset[str] = frozenset({
    "criancas.json",
    "folla_crianza",
    "crianza_resultados",
    "crianza_",
    "crianza_engadir",
    "crianza_editar",
    "crianza_borrar",
    "crianza_borrar_si",
    "resultados_crianza",
    "rexistro_crianza",
})

# Comentarios de línea/bloque y directivas de import/export/part en Dart.
_DART_STRIP_COMMENTS = re.compile(
    r"//[^\n]*|/\*[\s\S]*?\*/",
)
# Literales de cadena Dart: r'''...''', r"""...""", '''...''', """...""", r'...', r"...", '...', "..."
_DART_STRING = re.compile(
    r"r?'''[\s\S]*?'''|r?\"\"\"[\s\S]*?\"\"\"|r?'(?:\\.|[^'\\])*'|r?\"(?:\\.|[^\"\\])*\"",
)
_DART_INTERP = re.compile(r"\$\{[^}]*\}|\$[A-Za-z_][A-Za-z0-9_]*")


def _check_json_obj(obj: object, rel: str, path: str, out: list[str]) -> None:
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k not in CLAVES_JSON_EXENTAS and PALABRAS_GALICIA.search(k):
                out.append(f"  {rel} ({path}.<key:{k}>): {k}")
            _check_json_obj(v, rel, f"{path}.{k}" if path else k, out)
    elif isinstance(obj, list):
        for i, item in enumerate(obj):
            _check_json_obj(item, rel, f"{path}[{i}]", out)
    elif isinstance(obj, str):
        m = PALABRAS_GALICIA.search(obj)
        if m:
            out.append(f"  {rel} ({path}): «{m.group(0)}» en «{obj[:90]}»")


def check_assets_content(fallos: list[str]) -> int:
    count = 0
    base = RAIZ / "assets" / "content"
    for p in sorted(base.rglob("*")):
        if not p.is_file():
            continue
        rel = p.relative_to(RAIZ).as_posix()
        if p.suffix == ".json":
            count += 1
            data = json.loads(p.read_text(encoding="utf-8"))
            _check_json_obj(data, rel, "", fallos)
        elif p.suffix in {".txt", ".md"}:
            count += 1
            for i, linea in enumerate(p.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
                m = PALABRAS_GALICIA.search(linea)
                if m:
                    fallos.append(f"  {rel}:{i}: «{m.group(0)}»")
    return count


def check_lib_strings(fallos: list[str]) -> int:
    count = 0
    for p in sorted((RAIZ / "lib").rglob("*.dart")):
        count += 1
        rel = p.relative_to(RAIZ).as_posix()
        raw = p.read_text(encoding="utf-8")
        # Quitar líneas import/export/part antes de extraer cadenas
        lines = [
            ln if not re.match(r"^\s*(?:import|export|part)\b", ln) else ""
            for ln in raw.splitlines()
        ]
        sin_imports = "\n".join(lines)
        # Reemplazar comentarios conservando saltos de línea para mantener nº de línea
        sin_comentarios = _DART_STRIP_COMMENTS.sub(
            lambda m: "\n" * m.group(0).count("\n"),
            sin_imports,
        )
        for m in _DART_STRING.finditer(sin_comentarios):
            lit = m.group(0)
            # Desenvolver comillas
            body = lit
            if body.startswith("r"):
                body = body[1:]
            if body.startswith("'''") or body.startswith('"""'):
                inner = body[3:-3]
            else:
                inner = body[1:-1]
            if inner in CADENAS_DART_EXENTAS:
                continue
            # Quitar interpolaciones ${...} / $ident (son nombres de variables Dart, no texto visible)
            if not lit.startswith("r"):
                inner_vis = _DART_INTERP.sub(" ", inner)
            else:
                inner_vis = inner
            hit = PALABRAS_GALICIA.search(inner_vis)
            if hit:
                linea_n = sin_comentarios[:m.start()].count("\n") + 1
                fallos.append(f"  {rel}:{linea_n}: «{hit.group(0)}» en {inner[:80]!r}")
    return count


# Rutas de capturas de pantalla ya existentes en docs/capturas/ (no texto visible).
_HTML_CAPTURA_SRC = re.compile(r'src="capturas/[^"]+"')


def check_docs_and_readme(fallos: list[str]) -> int:
    count = 0
    targets = sorted((RAIZ / "docs").glob("*.html")) + [RAIZ / "README.md"]
    for p in targets:
        if not p.is_file():
            continue
        count += 1
        rel = p.relative_to(RAIZ).as_posix()
        for i, linea in enumerate(p.read_text(encoding="utf-8", errors="ignore").splitlines(), 1):
            vis = _HTML_CAPTURA_SRC.sub("", linea) if p.suffix == ".html" else linea
            m = PALABRAS_GALICIA.search(vis)
            if m:
                fallos.append(f"  {rel}:{i}: «{m.group(0)}» -> {linea.strip()[:90]}")
    return count


def main() -> int:
    fallos: list[str] = []
    n_assets = check_assets_content(fallos)
    n_lib = check_lib_strings(fallos)
    n_docs = check_docs_and_readme(fallos)
    if fallos:
        print(
            f"FALLA ({len(fallos)} coincidencias): léxico no gallego (criatura/crianza):\n"
            + "\n".join(fallos[:100])
            + (f"\n  ... ({len(fallos) - 100} más)" if len(fallos) > 100 else "")
        )
        return 1
    print(
        f"OK: {n_assets} ficheros de assets/content, {n_lib} de lib/ y {n_docs} de docs/*.html/README.md "
        f"sin «criatura/crianza»."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
