#!/usr/bin/env python3
"""Cuántas locuciones siguen sin grabación.

    python3 tools/voice_missing.py            # todas las lenguas
    python3 tools/voice_missing.py --lang en  # solo el inglés

Escribe un número y nada más, para que un script de CI pueda leerlo. Existe
porque el paso del inglés sintetiza POR TANDAS y necesita saber, entre tanda y
tanda, si ya ha terminado.
"""
from __future__ import annotations

import argparse
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from voice_corpus import (  # noqa: E402
    VOICE_LANGS,
    collect_locutions,
    iter_missing,
)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lang", choices=sorted(VOICE_LANGS))
    args = parser.parse_args()

    faltan = list(iter_missing(collect_locutions()))
    if args.lang:
        faltan = [e for e in faltan if e.lang == args.lang]
    print(len(faltan))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
