#!/usr/bin/env python3
"""Fails when a song's pulse markers do not describe one steady pulse.

The `*` in `letraConPulsos` are the beats: they drive the visual metronome, so
they are not decoration. The Spanish lyrics shipped with 4, 5, 4 and 3 markers
per line while the Galician had 4, 4, 4, 4 — the same song would have been
clapped differently in each language, and two of its four bars did not exist in
the other one.

The two languages do not measure the same, which is exactly why this is checked
per language AND across languages.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
UNITS = ROOT / "assets" / "content" / "unidades"
LANGS = ("gl", "es")


def marker_counts(lyrics: str) -> list[int]:
    return [line.count("*") for line in lyrics.split("\n") if line.strip()]


def main() -> int:
    failures: list[str] = []
    checked = 0

    for path in sorted(UNITS.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        cancion = data.get("cancionPulso") or data.get("cancion") or {}
        lyrics = cancion.get("letraConPulsos") or cancion.get("letra_con_pulsos")
        if not isinstance(lyrics, dict):
            continue

        per_lang: dict[str, list[int]] = {}
        for lang in LANGS:
            text = str(lyrics.get(lang, ""))
            if not text.strip():
                failures.append(f"{path.name}: letraConPulsos.{lang} is empty")
                continue
            counts = marker_counts(text)
            per_lang[lang] = counts

            if 0 in counts:
                failures.append(
                    f"{path.name} [{lang}]: a line carries no pulse marker at all: {counts}"
                )
            elif len(set(counts)) != 1:
                failures.append(
                    f"{path.name} [{lang}]: the beats per line are not constant: {counts}. "
                    "A pulse song has one steady bar."
                )

        if len(per_lang) == len(LANGS):
            checked += 1
            if len(per_lang["gl"]) != len(per_lang["es"]):
                failures.append(
                    f"{path.name}: {len(per_lang['gl'])} lines in gl but "
                    f"{len(per_lang['es'])} in es"
                )
            elif set(per_lang["gl"]) != set(per_lang["es"]):
                failures.append(
                    f"{path.name}: gl claps {per_lang['gl']} and es claps {per_lang['es']}. "
                    "The same song must keep the same pulse in both languages."
                )

    if failures:
        print("FAIL: the pulse markers do not describe one steady pulse:", file=sys.stderr)
        for line in failures:
            print(f"  {line}", file=sys.stderr)
        return 1

    print(f"OK: {checked} song(s), one steady pulse per bar in both languages")
    return 0


if __name__ == "__main__":
    sys.exit(main())
