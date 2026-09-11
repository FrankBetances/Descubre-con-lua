#!/usr/bin/env python3
"""Writes voice-corpus.json and syncs the audio paths inside the content JSON.

  python3 tools/export_voice_corpus.py          # write corpus + sync content
  python3 tools/export_voice_corpus.py --check  # fail if anything is stale

The content JSON keeps declaring its own `audioAsset` paths so a reader can see
what a unit plays, but those paths are no longer written by hand: they are the
hash of the text they belong to. Running this after any content edit is what
keeps text and audio in the same commit.
"""
from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from voice_corpus import (  # noqa: E402
    CONTENT_DIR,
    CORPUS_JSON,
    LANGS,
    collect_locutions,
    normalize,
    voice_id,
)


def sync_content(check_only: bool) -> list[str]:
    """Rewrites every `audioAsset` block to the id derived from its own text."""
    stale: list[str] = []

    for path in sorted((CONTENT_DIR / "unidades").glob("*.json")):
        raw = path.read_text(encoding="utf-8")
        data = json.loads(raw)
        changed = False

        def derive(text_node: object, style: str) -> dict[str, str] | None:
            if not isinstance(text_node, dict):
                return None
            out: dict[str, str] = {}
            for lang in LANGS:
                value = normalize(str(text_node.get(lang, "")))
                if not value:
                    return None
                out[lang] = f"assets/voice/{voice_id(style, value, lang)}.m4a"
            return out

        cancion = data.get("cancionPulso") or data.get("cancion")
        if isinstance(cancion, dict):
            derived = derive(
                cancion.get("letraConPulsos") or cancion.get("letra_con_pulsos"),
                "tutor",
            )
            if derived and cancion.get("audioAsset") != derived:
                stale.append(f"{path.name}: cancionPulso.audioAsset")
                cancion["audioAsset"] = derived
                changed = True

        for item in data.get("vocabulario") or []:
            if not isinstance(item, dict):
                continue
            derived = derive(item.get("palabra"), "slow")
            if derived and item.get("audioAsset") != derived:
                stale.append(f"{path.name}: vocabulario/{item.get('id', '?')}.audioAsset")
                item["audioAsset"] = derived
                changed = True

        if changed and not check_only:
            path.write_text(
                json.dumps(data, ensure_ascii=False, indent=2) + "\n",
                encoding="utf-8",
            )

    return stale


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--check",
        action="store_true",
        help="do not write anything; exit 1 if the corpus or the content is stale",
    )
    args = parser.parse_args()

    locutions = collect_locutions()
    stale = sync_content(check_only=args.check)

    by_style: dict[str, int] = {}
    by_lang: dict[str, int] = {}
    for entry in locutions:
        by_style[entry.style] = by_style.get(entry.style, 0) + 1
        by_lang[entry.lang] = by_lang.get(entry.lang, 0) + 1

    payload = {
        "generatedAt": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "entries": len(locutions),
        "byStyle": by_style,
        "byLang": by_lang,
        "corpus": [entry._asdict() for entry in locutions],
    }

    if args.check:
        current = json.loads(CORPUS_JSON.read_text(encoding="utf-8")) if CORPUS_JSON.exists() else {}
        if current.get("corpus") != payload["corpus"]:
            stale.append("voice-corpus.json is out of date")
        if stale:
            print("FAIL: run tools/export_voice_corpus.py, the voice corpus is stale:", file=sys.stderr)
            for item in stale:
                print(f"  {item}", file=sys.stderr)
            return 1
        print(f"OK: voice corpus in sync ({len(locutions)} locutions)")
        return 0

    # generatedAt alone must not churn the file on every run.
    if CORPUS_JSON.exists():
        previous = json.loads(CORPUS_JSON.read_text(encoding="utf-8"))
        if previous.get("corpus") == payload["corpus"]:
            payload["generatedAt"] = previous.get("generatedAt", payload["generatedAt"])

    CORPUS_JSON.write_text(
        json.dumps(payload, ensure_ascii=False, indent=1) + "\n",
        encoding="utf-8",
    )
    print(f"OK -> {CORPUS_JSON.name}: {len(locutions)} locutions {by_lang}")
    for item in stale:
        print(f"  synced {item}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
