#!/usr/bin/env python3
"""Fails when a shipped recording peaks too close to full scale.

voice-assets-manifest.*.json declares `peakDbfs: -3.0`, but that number was
written by the generator about the audio BEFORE encoding. Nothing measured the
files that actually ship, and one of them (the Spanish recitation) reached
-0.0 dBFS: three decibels above the target, with no headroom left and a real
risk of clipping on a phone speaker in a classroom.

So this reads the artefacts, the same way the permission gate reads the APK
instead of the manifest.

Y por eso, si no hay ffmpeg, esto FALLA en vez de saltarse. La primera versión
devolvía 0 cuando faltaba la herramienta, y en CI nunca se instaló: el gate
llevaba desde que se escribió diciendo PASS sin haber medido una grabación.
Salirse en verde por no poder comprobar es exactamente el fallo que este
repositorio lleva pagando en otras formas.
"""
from __future__ import annotations

import re
import shutil
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
VOICE_DIR = ROOT / "assets" / "voice"

# The pipeline masters to -3 dBFS. A lossy encoder legitimately overshoots a
# little on decode, so the gate allows headroom for that and only fails on a
# file that has effectively none left.
CEILING_DBFS = -1.0

_PEAK = re.compile(r"max_volume:\s*(-?\d+(?:\.\d+)?)\s*dB")


def peak_dbfs(path: Path) -> float | None:
    result = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", str(path), "-af", "volumedetect",
         "-f", "null", "/dev/null"],
        capture_output=True,
        text=True,
    )
    match = _PEAK.search(result.stderr)
    return float(match.group(1)) if match else None


def main() -> int:
    recordings = sorted(VOICE_DIR.glob("*.m4a")) if VOICE_DIR.exists() else []

    if shutil.which("ffmpeg") is None:
        # Sin ffmpeg no se puede medir nada. Antes esto devolvía 0 y el gate
        # salía PASS: en CI no había ffmpeg instalado, así que este gate llevaba
        # desde que existe informando de verde SIN HABER ABIERTO UN SOLO
        # FICHERO. Un gate que dice verde sin comprobar es peor que no tenerlo,
        # porque ocupa el sitio del que sí comprobaría.
        #
        # Ausencia de herramienta no es ausencia de problema. Si hay grabaciones
        # que medir y no hay con qué, esto es un fallo, no un salto.
        if recordings:
            print(
                f"FAIL: hay {len(recordings)} grabaciones que medir y ffmpeg no "
                f"está instalado.\n"
                f"      Instálalo (apt-get install ffmpeg / brew install ffmpeg) "
                f"o el gate no puede\n"
                f"      decir nada sobre los picos de audio que van en el APK.",
                file=sys.stderr,
            )
            return 1
        print("OK: no hay grabaciones que medir, así que no hace falta ffmpeg")
        return 0

    if not recordings:
        print("OK: no recordings to measure yet")
        return 0

    failures: list[str] = []
    for path in recordings:
        peak = peak_dbfs(path)
        if peak is None:
            failures.append(f"{path.name}: could not be measured")
            continue
        flag = "  <-- too hot" if peak > CEILING_DBFS else ""
        print(f"  {path.name:<36} {peak:>6.1f} dBFS{flag}")
        if peak > CEILING_DBFS:
            failures.append(f"{path.name}: peaks at {peak:.1f} dBFS")

    if failures:
        print(
            f"\nFAIL: {len(failures)} recording(s) peak above {CEILING_DBFS} dBFS:",
            file=sys.stderr,
        )
        for line in failures:
            print(f"  {line}", file=sys.stderr)
        print(
            "\nRe-synthesise them with --force: the generator now verifies the "
            "encoded peak and attenuates until it fits.",
            file=sys.stderr,
        )
        return 1

    print(f"\nOK: {len(recordings)} recording(s), none above {CEILING_DBFS} dBFS")
    return 0


if __name__ == "__main__":
    sys.exit(main())
