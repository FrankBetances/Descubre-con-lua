#!/usr/bin/env python3
"""Fails when a locution the app can play has no recording in the package.

This is the gate that replaces the previous "referential integrity validator",
which only checked that an audio path looked like a path and ended in .mp3. It
passed while every single recording referenced by the content was absent from
the repository and the app played nothing at all.
"""
from __future__ import annotations

import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from voice_corpus import PACK_DIR, VOICE_DIR, collect_locutions, iter_missing  # noqa: E402


def main() -> int:
    locutions = collect_locutions()
    if not locutions:
        print("FAIL: the content declares no locutions at all", file=sys.stderr)
        return 1

    missing = list(iter_missing(locutions))

    esperadas = {(entry.directory, entry.filename) for entry in locutions}
    orphans = sorted(
        f"{carpeta.name}/{path.name}"
        for carpeta in (VOICE_DIR, PACK_DIR) if carpeta.exists()
        for path in carpeta.glob("*.m4a")
        if (carpeta, path.name) not in esperadas
    )

    for name in orphans:
        print(f"  note: {name} is no longer referenced by any text")

    if missing:
        print(
            f"FAIL: {len(missing)} of {len(locutions)} locutions have no recording.",
            file=sys.stderr,
        )
        for entry in missing:
            print(f"  {entry.lang} {entry.style} {entry.source}: {entry.text[:60]}", file=sys.stderr)
        print(
            "\nSynthesise them with tools/generate_voice_assets.py "
            "(or the voice-assets workflow) and commit the result.",
            file=sys.stderr,
        )
        return 1

    print(f"OK: {len(locutions)} locutions, every recording present in assets/voice/ and assets/voice_pack/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
