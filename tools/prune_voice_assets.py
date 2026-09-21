#!/usr/bin/env python3
"""Borra las grabaciones que ya no corresponden a ninguna locución.

    python3 tools/prune_voice_assets.py           # borra
    python3 tools/prune_voice_assets.py --check   # solo avisa (es el gate)

**Por qué existe.** El identificador de una grabación sale del texto exacto, y
el corpus de voz se genera del contenido. Cuando el contenido ENCOGE —se quita
una palabra, se acorta una lista, se reescribe una frase— la locución
desaparece del corpus pero **el fichero .m4a se queda**, y se queda dentro del
APK: peso muerto que nadie reproduce nunca.

Pasó al recortar el vocabulario inglés de 7.998 palabras a las 3.995 de uso
habitual: quedaron 1.275 grabaciones huérfanas, 9 MB.

`check_voice_coverage.py` mira lo contrario —que no falte ninguna— y por eso no
lo veía: un fichero de más no es una locución de menos.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CORPUS = ROOT / "voice-corpus.json"
VOZ = ROOT / "assets" / "voice"


def orfas() -> list[Path]:
    if not CORPUS.exists() or not VOZ.exists():
        return []
    ids = {e["id"] for e in json.loads(CORPUS.read_text(encoding="utf-8"))["corpus"]}
    return sorted(p for p in VOZ.glob("*.m4a") if p.stem not in ids)


def main() -> int:
    sobran = orfas()
    total = len(list(VOZ.glob("*.m4a"))) if VOZ.exists() else 0

    if not sobran:
        print(f"OK: {total} gravacións e ningunha sobra.")
        return 0

    mb = sum(p.stat().st_size for p in sobran) / 1024 / 1024

    if "--check" in sys.argv:
        print(f"Sobran {len(sobran)} gravacións ({mb:.1f} MB) que non son de "
              f"ningunha locución. As cinco primeiras:")
        for p in sobran[:5]:
            print("  ·", p.name)
        print("Córrelle: python3 tools/prune_voice_assets.py")
        return 1

    for p in sobran:
        p.unlink()
    print(f"OK: borradas {len(sobran)} gravacións orfas ({mb:.1f} MB). "
          f"Quedan {total - len(sobran)}.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
