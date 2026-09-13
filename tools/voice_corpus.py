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
ALL_LANGS = ("gl", "es", "en")
VOICE_LANGS = ALL_LANGS

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


def _localized(node: object, langs: tuple[str, ...] = LANGS) -> dict[str, str]:
    if isinstance(node, dict):
        return {lang: str(node.get(lang, "")) for lang in langs}
    return {lang: "" for lang in langs}


def _add(text: dict[str, str], style: str, source: str, seen: dict[str, Locution], langs: tuple[str, ...] = LANGS) -> None:
    for lang in langs:
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


def collect_locutions(content_dir: Path = CONTENT_DIR, langs: tuple[str, ...] = LANGS) -> list[Locution]:
    """Every locution the app can play, read from the content JSON.

    Nothing is invented here: if a screen starts playing something new, it gets
    added to this function first and the coverage gate reports the missing
    recording until it is synthesised.

    The corpus used to cover only the pulse chant and the vocabulary words —
    twelve recordings — so almost every card in the app had no speaker button.
    It now covers every piece of PROSE the adult reads on a card, in both
    languages, which is what a neural Galician voice is actually for: a teacher
    who did not grow up speaking Galician can hear the model pronunciation
    before saying it to the class.

    What is deliberately left out: titles, subtitles, headings and lists of
    materials. They are labels, not sentences, and a synthesised voice reading
    "Grande / Pequeno, Moito / Pouco" out of context is noise. Vocabulary words
    are the exception, and they get the slow pace because they exist to be
    imitated.
    """
    seen: dict[str, Locution] = {}
    _orig_localized = globals()["_localized"]
    _orig_add = globals()["_add"]

    def _localized(node: object) -> dict[str, str]:
        return _orig_localized(node, langs=langs)

    def _add(text: dict[str, str], style: str, source: str, _s: dict[str, Locution] = seen) -> None:
        _orig_add(text, style, source, seen, langs=langs)

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
        if cancion.get("consignaDocente"):
            _add(
                _localized(cancion["consignaDocente"]),
                "tutor",
                f"{unit_id}/cancionPulso/consigna",
                seen,
            )

        cuento = data.get("cuento") or {}
        for i, pagina in enumerate(cuento.get("paginas") or []):
            if not isinstance(pagina, dict):
                continue
            if pagina.get("texto"):
                _add(_localized(pagina["texto"]), "tutor",
                     f"{unit_id}/cuento/{i}/texto", seen)
            if pagina.get("preguntaComprension"):
                _add(_localized(pagina["preguntaComprension"]), "tutor",
                     f"{unit_id}/cuento/{i}/pregunta", seen)

        for pregunta in data.get("preguntas") or []:
            if not isinstance(pregunta, dict):
                continue
            pid = pregunta.get("id", "?")
            for campo in ("enunciado", "respuestaSugerida", "consejoDocente"):
                if pregunta.get(campo):
                    _add(_localized(pregunta[campo]), "tutor",
                         f"{unit_id}/preguntas/{pid}/{campo}", seen)

        for item in data.get("vocabulario") or []:
            if not isinstance(item, dict):
                continue
            item_id = item.get("id", "?")
            # La palabra va despacio: existe para que la imiten.
            if item.get("palabra"):
                _add(_localized(item["palabra"]), "slow",
                     f"{unit_id}/vocabulario/{item_id}", seen)
            # `definicionBreve` NO entra en el corpus: hoy no hay ninguna
            # pantalla que pinte el vocabulario, así que esas grabaciones
            # viajarían en el APK sin que nada pudiera reproducirlas. Entra el
            # día que exista la tarjeta, no antes.

        exploracion = data.get("exploracion") or {}
        for campo in ("objetivoSensorial", "avisoSeguridad"):
            if exploracion.get(campo):
                _add(_localized(exploracion[campo]), "tutor",
                     f"{unit_id}/exploracion/{campo}", seen)
        for i, paso in enumerate(exploracion.get("pasos") or []):
            _add(_localized(paso), "tutor", f"{unit_id}/exploracion/paso/{i}",
                 seen)

        matematicas = data.get("matematicas") or {}
        if matematicas.get("descripcion"):
            _add(_localized(matematicas["descripcion"]), "tutor",
                 f"{unit_id}/matematicas/descripcion", seen)
        for i, accion in enumerate(matematicas.get("accionesSugeridas") or []):
            _add(_localized(accion), "tutor",
                 f"{unit_id}/matematicas/accion/{i}", seen)

        puente = data.get("puenteCasa") or {}
        for campo in ("mensajeFamilias", "recomendacionConversacion"):
            if puente.get(campo):
                _add(_localized(puente[campo]), "tutor",
                     f"{unit_id}/puenteCasa/{campo}", seen)
        for i, act in enumerate(puente.get("actividadesSugeridas") or []):
            _add(_localized(act), "tutor", f"{unit_id}/puenteCasa/act/{i}", seen)

    # Academy. Las cápsulas las lee una familia en casa, muchas veces con las
    # manos ocupadas; que se puedan escuchar no es un adorno.
    for path in sorted((content_dir / "capsulas").glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        cap_id = data.get("id", path.stem)

        for campo in ("ideaClave", "porQueImporta", "queHacerEnCasa",
                      "ejemploCotidiano"):
            if data.get(campo):
                _add(_localized(data[campo]), "tutor", f"{cap_id}/{campo}", seen)

        for afirmacion in data.get("afirmaciones") or []:
            if not isinstance(afirmacion, dict):
                continue
            aid = afirmacion.get("id", "?")
            for campo in ("enunciado", "explicacion"):
                if afirmacion.get(campo):
                    _add(_localized(afirmacion[campo]), "tutor",
                         f"{cap_id}/afirmaciones/{aid}/{campo}", seen)

    return sorted(seen.values(), key=lambda e: (e.lang, e.style, e.id))


def iter_missing(locutions: list[Locution], voice_dir: Path = VOICE_DIR) -> Iterator[Locution]:
    for entry in locutions:
        if not (voice_dir / entry.filename).exists():
            yield entry
