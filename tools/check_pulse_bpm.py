#!/usr/bin/env python3
"""Fails when the tempo a unit displays is not the tempo its pulse track plays.

The content declared 80 BPM while the only pulse recording in the repository
measures 72.3 BPM, so the teacher read one number off the badge and clapped to
another. Nothing caught it: the file name said 72, the documentation said 72,
and the JSON said 80.

The tempo is measured from the audio itself rather than parsed out of the file
name, because a file name is not evidence.
"""
from __future__ import annotations

import json
import sys
import wave
from pathlib import Path

try:
    import numpy as np
except ImportError:  # pragma: no cover
    print("ERROR: numpy is required: pip install numpy", file=sys.stderr)
    raise SystemExit(1)

ROOT = Path(__file__).resolve().parent.parent
UNITS = ROOT / "assets" / "content" / "unidades"
PULSE = ROOT / "assets" / "audio" / "mar_pulso_72bpm.wav"

# A steady pulse for 0-3 is set by ear, not to the decimal: one beat per minute
# of slack absorbs the encoder without hiding a real mismatch.
TOLERANCE_BPM = 1.5


def measure_bpm(path: Path) -> float | None:
    with wave.open(str(path), "rb") as reader:
        if reader.getsampwidth() != 2:
            return None
        rate = reader.getframerate()
        frames = reader.readframes(reader.getnframes())

    samples = np.frombuffer(frames, dtype="<i2").astype(np.float32) / 32768.0
    if reader.getnchannels() > 1:
        samples = samples.reshape(-1, reader.getnchannels()).mean(axis=1)

    step = int(rate * 0.01)
    envelope = np.array([
        np.max(np.abs(samples[i:i + step]))
        for i in range(0, len(samples) - step, step)
    ])
    if envelope.size == 0:
        return None

    threshold = envelope.max() * 0.35
    onsets: list[float] = []
    above = False
    for index, value in enumerate(envelope):
        if value > threshold and not above:
            onsets.append(index * 0.01)
            above = True
        elif value < threshold * 0.6:
            above = False

    if len(onsets) < 3:
        return None
    return 60.0 / float(np.median(np.diff(onsets)))


def main() -> int:
    if not PULSE.exists():
        print(f"FAIL: the pulse track is missing: {PULSE.relative_to(ROOT)}", file=sys.stderr)
        return 1

    measured = measure_bpm(PULSE)
    if measured is None:
        print(f"FAIL: could not measure a pulse in {PULSE.name}", file=sys.stderr)
        return 1

    failures: list[str] = []
    for path in sorted(UNITS.glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        cancion = data.get("cancionPulso") or data.get("cancion") or {}
        declared = cancion.get("bpm")
        if declared is None:
            continue
        if abs(float(declared) - measured) > TOLERANCE_BPM:
            failures.append(
                f"{path.name}: displays {declared} BPM, "
                f"the pulse track plays {measured:.1f} BPM"
            )

    if failures:
        print("FAIL: declared tempo does not match the pulse track:", file=sys.stderr)
        for line in failures:
            print(f"  {line}", file=sys.stderr)
        return 1

    print(f"OK: declared tempo matches the pulse track ({measured:.1f} BPM measured)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
