#!/usr/bin/env python3
"""Every asset the app asks for at runtime must exist AND be packaged.

Why this gate exists. The Calendario Escola·Fogar shipped for weeks as an
infinite spinner and no gate saw it. `assets/content/calendario/` was simply
missing from the `assets:` list in pubspec.yaml, so `meses.json` never entered
the APK, `rootBundle.loadString` threw, and the screen waited forever for a
future that had already failed. Fifty-seven green runs went past it, because
every test injects the content or a file-reading loader: nothing ever asked the
real bundle for anything.

Declaring an asset is three separate acts, and two of them are silent when they
go wrong:

  1. the file exists on disk        -> a missing file is silent at build time
  2. pubspec packages it            -> a missing directory is silent too
  3. the code asks for it           -> only this one is visible

So this gate reads what the code and the content ASK for, and checks 1 and 2.

Flutter's directory entries are NOT recursive: listing `assets/content/` does
not package `assets/content/calendario/meses.json`. The immediate parent
directory of a file has to be listed, or the file itself. That rule is the one
this gate enforces, because it is the rule that was broken.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent

# Where an asset path can be written down. Build-time tools are deliberately
# out: tools/build_launcher_icons.py reads a grid from the working tree, and
# that file has no reason to travel inside the APK.
DART_DIR = ROOT / "lib"
CONTENT_DIR = ROOT / "assets" / "content"

# A path built at runtime out of a variable. The gate cannot resolve these, and
# guessing would be worse than saying so: they are listed in the report and
# their directory is still required to be packaged.
INTERPOLATED = re.compile(r"[$]")

ASSET_LITERAL = re.compile(r"""['"](assets/[^'"\s]+)['"]""")

# Las grabaciones son de check_voice_coverage.py, que sabe algo que este gate no
# sabe: se sintetizan en CI a partir del texto y se comprometen después, así que
# entre el commit que cambia una frase y el que trae su .m4a hay un hueco
# legítimo. Aquí se exige que el DIRECTORIO viaje —que es lo que se rompió en el
# calendario—; que cada fichero exista lo dice el otro gate, y con mejor
# diagnóstico: nombra la locución que falta, no solo la ruta.
VOICE_PREFIX = "assets/voice/"


def pubspec_asset_entries(pubspec: Path) -> list[str]:
    """The `assets:` entries under `flutter:`, verbatim.

    Hand-parsed on purpose: the gate must run with the standard library only,
    and the block is a flat list of strings. Anything cleverer would be a new
    dependency for the one file that must never fail to run.
    """
    entries: list[str] = []
    in_flutter = False
    in_assets = False
    for raw in pubspec.read_text(encoding="utf-8").splitlines():
        line = raw.split("#", 1)[0].rstrip()
        if not line.strip():
            continue
        indent = len(line) - len(line.lstrip())
        stripped = line.strip()

        if indent == 0:
            in_flutter = stripped == "flutter:"
            in_assets = False
            continue
        if not in_flutter:
            continue
        if stripped == "assets:":
            in_assets = True
            assets_indent = indent
            continue
        if in_assets:
            if stripped.startswith("- ") and indent > assets_indent:
                entries.append(stripped[2:].strip().strip("'\""))
            elif not stripped.startswith("- "):
                in_assets = False
    return entries


def packaged_by(path: str, entries: list[str]) -> bool:
    """True if `path` would end up inside the bundle.

    Two ways in, and only two: the file is listed outright, or the directory
    that DIRECTLY contains it is listed. Flutter does not recurse into
    subdirectories, which is exactly the trap this gate is here to spring.
    """
    if path in entries:
        return True
    parent = path.rsplit("/", 1)[0] + "/"
    return parent in entries


def literals_in_dart() -> dict[str, set[str]]:
    found: dict[str, set[str]] = {}
    for dart in sorted(DART_DIR.rglob("*.dart")):
        text = dart.read_text(encoding="utf-8")
        # Comments carry example paths ("assets/images/cuento/...") that are
        # prose, not requests. Strip them before looking for literals.
        text = re.sub(r"//[^\n]*", "", text)
        for match in ASSET_LITERAL.findall(text):
            found.setdefault(match, set()).add(str(dart.relative_to(ROOT)))
    return found


def literals_in_content() -> dict[str, set[str]]:
    found: dict[str, set[str]] = {}

    def walk(node, origin: str) -> None:
        if isinstance(node, dict):
            for value in node.values():
                walk(value, origin)
        elif isinstance(node, list):
            for value in node:
                walk(value, origin)
        elif isinstance(node, str) and node.startswith("assets/"):
            found.setdefault(node, set()).add(origin)

    for jsonfile in sorted(CONTENT_DIR.rglob("*.json")):
        walk(
            json.loads(jsonfile.read_text(encoding="utf-8")),
            str(jsonfile.relative_to(ROOT)),
        )
    return found


def main() -> int:
    pubspec = ROOT / "pubspec.yaml"
    entries = pubspec_asset_entries(pubspec)
    if not entries:
        print("pubspec.yaml: no assets: block found under flutter:")
        return 1

    asked: dict[str, set[str]] = {}
    for source in (literals_in_dart(), literals_in_content()):
        for path, origins in source.items():
            asked.setdefault(path, set()).update(origins)

    missing_file: list[tuple[str, set[str]]] = []
    not_packaged: list[tuple[str, set[str]]] = []
    dynamic: list[tuple[str, set[str]]] = []
    aplazadas: list[str] = []

    for path, origins in sorted(asked.items()):
        if INTERPOLATED.search(path):
            # Only the directory can be checked for these.
            directory = path.rsplit("/", 1)[0] + "/"
            dynamic.append((path, origins))
            if directory not in entries:
                not_packaged.append((directory, origins))
            continue
        if path.endswith("/"):
            if not (ROOT / path).is_dir():
                missing_file.append((path, origins))
            elif path not in entries:
                not_packaged.append((path, origins))
            continue
        if path.startswith(VOICE_PREFIX):
            aplazadas.append(path)
            if VOICE_PREFIX not in entries:
                not_packaged.append((VOICE_PREFIX, origins))
            continue
        if not (ROOT / path).is_file():
            missing_file.append((path, origins))
            continue
        if not packaged_by(path, entries):
            not_packaged.append((path, origins))

    if missing_file:
        print("These assets are asked for but DO NOT EXIST on disk:")
        for path, origins in missing_file:
            print(f"  {path}")
            for origin in sorted(origins):
                print(f"      asked by {origin}")
        print()

    if not_packaged:
        print("These assets exist but WOULD NOT TRAVEL in the APK.")
        print("pubspec.yaml must list the file, or the directory that directly")
        print("contains it (Flutter does not recurse into subdirectories):")
        merged: dict[str, set[str]] = {}
        for path, origins in not_packaged:
            merged.setdefault(path, set()).update(origins)
        for path, origins in sorted(merged.items()):
            print(f"  {path}")
            for origin in sorted(origins):
                print(f"      asked by {origin}")
        print()

    if missing_file or not_packaged:
        print("A missing asset is silent at build time and shows up as a screen")
        print("that never finishes loading. That is why this is a gate.")
        return 1

    checked = len(asked) - len(dynamic) - len(aplazadas)
    print(f"OK: {checked} asset paths exist and are packaged.")
    if aplazadas:
        print(f"    {len(aplazadas)} recordings under {VOICE_PREFIX} are")
        print("    check_voice_coverage.py's, which names the missing locution.")
    if dynamic:
        print(f"    {len(dynamic)} are built at runtime; their directory is packaged:")
        for path, _ in dynamic:
            print(f"      {path}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
