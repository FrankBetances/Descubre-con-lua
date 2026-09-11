#!/usr/bin/env python3
"""Shared definition of the offline voice corpus.

Every locution the app can play is derived from the content JSON, never listed
by hand. The identifier of a recording is a hash of the text itself, so editing
a sentence necessarily changes the identifier: the old recording stops being
referenced, the new one does not exist yet, and check_voice_coverage.py says so.
That is what makes it impossible to ship a screen that shows one sentence and
plays another.

The hash is the same FNV-1a used by the Valeria pipeline, so an id computed
here, in Dart (lib/core/audio/voice_id.dart) or in JavaScript is identical.
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Iterator, NamedTuple

ROOT = Path(__file__).resolve().parent.parent
CONTENT_DIR = ROOT / "assets" / "content"
VOICE_DIR = ROOT / "assets" / "voice"
CORPUS_JSON = ROOT / "voice-corpus.json"

LANGS = ("gl", "es")

# Reading pace passed to the synthesiser. There is no `child` style because a
# child never uses this app, and no `clinical` style because nothing here has a
# health purpose.
LENGTH_SCALE = {"tutor": 1.0, "slow": 1.6}

_WHITESPACE = re.compile(r"\s+")

# Pulse markers and syllable splits belong to what the teacher READS, not to
# what the voice SAYS: "* On-das * que veñen" is chanted as "Ondas que veñen".
# The identifier still hashes the displayed text, so changing a marker changes
# the recording — the displayed and the spoken text can never drift apart.
_PULSE_MARKER = re.compile(r"[*]")
_SYLLABLE_SPLIT = re.compile(r"(?<=[^\W\d_])-(?=[^\W\d_])")


def speech_text(text: str) -> str:
    """The text as the voice should say it, without the teacher's notation."""
    without_markers = _PULSE_MARKER.sub(" ", text)
    joined = _SYLLABLE_SPLIT.sub("", without_markers)
    return normalize(joined)


class Locution(NamedTuple):
    id: str
    lang: str
    style: str
    text: str
    speech: str
    source: str

    @property
    def filename(self) -> str:
        return f"{self.id}.m4a"

    @property
    def asset_path(self) -> str:
        return f"assets/voice/{self.filename}"


def normalize(text: str) -> str:
    """Collapses the whitespace that does not change how a sentence is read."""
    return _WHITESPACE.sub(" ", text).strip()


def fnv1a32(value: str) -> str:
    """FNV-1a, 32 bits, over UTF-16 code units (matches the Dart and JS ports)."""
    code_units = value.encode("utf-16-le")
    hash_ = 0x811C9DC5
    for i in range(0, len(code_units), 2):
        unit = code_units[i] | (code_units[i + 1] << 8)
        hash_ ^= unit
        hash_ = (hash_ * 0x01000193) & 0xFFFFFFFF
    return f"{hash_:08x}"


def utf16_length(value: str) -> int:
    """Length in UTF-16 code units, which is what Dart and JS call `.length`."""
    return len(value.encode("utf-16-le")) // 2


def voice_id(style: str, text: str, lang: str) -> str:
    normalized = normalize(text)
    return f"{lang}_{style}_{fnv1a32(normalized)}_{utf16_length(normalized)}"


def _localized(node: object) -> dict[str, str]:
    if isinstance(node, dict):
        return {lang: str(node.get(lang, "")) for lang in LANGS}
    return {lang: "" for lang in LANGS}


def _add(text: dict[str, str], style: str, source: str, seen: dict[str, Locution]) -> None:
    for lang in LANGS:
        value = normalize(text.get(lang, ""))
        if not value:
            continue
        entry = Locution(
            id=voice_id(style, value, lang),
            lang=lang,
            style=style,
            text=value,
            speech=speech_text(value),
            source=source,
        )
        seen.setdefault(entry.id, entry)


def collect_locutions(content_dir: Path = CONTENT_DIR) -> list[Locution]:
    """Every locution the app can play, read from the content JSON.

    Only what the content actually declares audio for is included: the pulse
    chant and the vocabulary words. Nothing is invented here — if a screen
    starts playing something new, it gets added here first and the coverage gate
    reports the missing recording until it is synthesised.
    """
    seen: dict[str, Locution] = {}

    for path in sorted((content_dir / "unidades").glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        unit_id = data.get("id", path.stem)

        cancion = data.get("cancionPulso") or data.get("cancion") or {}
        letra = cancion.get("letraConPulsos") or cancion.get("letra_con_pulsos")
        if letra:
            # A neural TTS voice speaks; it does not sing. The recording for the
            # pulse step is the lyrics chanted at a steady pace, which is how
            # pulse work is done with 0-3 anyway. The instrumental pulse track
            # stays available separately as the metronome.
            _add(_localized(letra), "tutor", f"{unit_id}/cancionPulso", seen)

        for item in data.get("vocabulario") or []:
            if not isinstance(item, dict):
                continue
            palabra = item.get("palabra")
            if palabra:
                item_id = item.get("id", "?")
                _add(_localized(palabra), "slow", f"{unit_id}/vocabulario/{item_id}", seen)

    return sorted(seen.values(), key=lambda e: (e.lang, e.style, e.id))


def iter_missing(locutions: list[Locution], voice_dir: Path = VOICE_DIR) -> Iterator[Locution]:
    for entry in locutions:
        if not (voice_dir / entry.filename).exists():
            yield entry
