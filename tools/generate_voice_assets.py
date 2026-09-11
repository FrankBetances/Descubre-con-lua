#!/usr/bin/env python3
"""Synthesises the offline voice assets.

  python3 tools/generate_voice_assets.py --lang gl
  python3 tools/generate_voice_assets.py --lang es

Voices, same decision as Valeria+:
  · gl -> «Celtia» do Proxecto Nós (VITS de grafemas, motor coqui-tts). The
    checkpoint files are discovered through the Hugging Face API so this
    pipeline does not depend on the repository's internal file names. The model
    is gated: accept its conditions with a Hugging Face account, create a read
    token and expose it as HF_TOKEN, or the download returns 401.
  · es -> «Sharvard» (rhasspy/piper-voices), the open female VITS that pairs
    with Celtia in Spanish.

Mastering: peak at -3 dBFS, mono, AAC at 40 kbit/s. Style is baked into the
VITS length_scale rather than applied afterwards with atempo, so the pauses are
not stretched.

The models run HERE and never in the app: the APK carries the resulting .m4a
files and no inference code, which is what keeps the release free of network
permissions and of any machine-learning runtime.

Incremental: only locutions without a recording are synthesised, so re-running
this does not rewrite what already exists and does not churn the repository.

This is a port of scripts/generate-voice-assets.py in the Valeria repository,
reduced to the two languages this project ships. Build-time tooling only: no
Valeria screen, module or app code is reused here.
"""
from __future__ import annotations

import argparse
import audioop
import json
import re
import subprocess
import sys
import urllib.request
import wave
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

import os  # noqa: E402

from voice_corpus import (  # noqa: E402
    CORPUS_JSON,
    LENGTH_SCALE,
    VOICE_DIR,
    ROOT,
)

HF_TOKEN = os.environ.get("HF_TOKEN", "").strip()

VOICES_DIR = ROOT / "tools" / ".voices"  # downloaded models (gitignored)

PEAK_DBFS = -3.0
AAC_BITRATE = "40k"

# A lossy encoder does not preserve the peak it was handed: the Spanish
# recitation was mastered to -3 dBFS and came out of the encoder at -0.0, with
# no headroom left. The target alone is therefore not enough — the ENCODED file
# is measured and attenuated until it fits under this ceiling.
CEILING_DBFS = -1.0
MAX_ENCODE_ATTEMPTS = 4

_PEAK_RE = re.compile(r"max_volume:\s*(-?\d+(?:\.\d+)?)\s*dB")


def die(msg: str) -> None:
    print(f"ERROR: {msg}", file=sys.stderr)
    sys.exit(1)


def piper_urls(name: str) -> list[str]:
    locale, speaker, quality = name.split("-", 2)
    base = (
        f"https://huggingface.co/rhasspy/piper-voices/resolve/main/"
        f"{locale.split('_')[0]}/{locale}/{speaker}/{quality}/{name}"
    )
    return [f"{base}.onnx", f"{base}.onnx.json"]


VOICES = {
    "gl": {
        "engine": "coqui",
        "name": "celtia",
        "label": "Celtia · Proxecto Nós (proxectonos)",
        "hf_repos": [
            "proxectonos/Nos_TTS-celtia-vits-graphemes",
            "proxectonos/nos_tts-celtia-vits-graphemes",
        ],
    },
    "es": {
        "engine": "piper",
        "name": "es_ES-sharvard-medium",
        "label": "Sharvard (femenina) · rhasspy/piper-voices",
        "urls": piper_urls("es_ES-sharvard-medium"),
    },
}


def curl(url: str, dest: Path) -> None:
    if dest.exists() and dest.stat().st_size > 0:
        return
    print(f"↓ {url}")
    auth = ["-H", f"Authorization: Bearer {HF_TOKEN}"] if HF_TOKEN and "huggingface.co" in url else []
    try:
        subprocess.run(["curl", "-fsSL", *auth, "-o", str(dest), url], check=True)
    except subprocess.CalledProcessError:
        die(
            f"Download failed: {url}\n"
            "If this is a gated Hugging Face model (Celtia, from proxectonos):\n"
            "  1) sign in to Hugging Face and ACCEPT the conditions on the model page,\n"
            "  2) create a read token (Settings -> Access Tokens),\n"
            "  3) expose it as the HF_TOKEN secret of this repository."
        )


def hf_discover(repos: list[str]) -> tuple[str, list[str]]:
    """Returns (repo, files) for the first reachable Hugging Face repository."""
    for candidate in repos:
        try:
            request = urllib.request.Request(f"https://huggingface.co/api/models/{candidate}")
            if HF_TOKEN:
                request.add_header("Authorization", f"Bearer {HF_TOKEN}")
            with urllib.request.urlopen(request, timeout=30) as response:
                payload = json.loads(response.read().decode("utf-8"))
            files = [s["rfilename"] for s in payload.get("siblings", [])]
            if files:
                return candidate, files
        except Exception as exc:  # noqa: BLE001 - any failure means "try the next one"
            print(f"  {candidate}: {exc}")
    die(f"No reachable Hugging Face repository among {repos}. With a gated model, set HF_TOKEN.")
    raise AssertionError("unreachable")


# ------------------------------------------------------------------ mastering
def normalize_peak(wav_in: Path, wav_out: Path) -> float:
    with wave.open(str(wav_in), "rb") as reader:
        params = reader.getparams()
        if params.sampwidth != 2:
            die(f"{wav_in}: expected 16-bit PCM")
        frames = reader.readframes(params.nframes)
    peak = audioop.max(frames, 2) or 1
    target = int(32767 * (10 ** (PEAK_DBFS / 20)))
    frames = audioop.mul(frames, 2, target / peak)
    with wave.open(str(wav_out), "wb") as writer:
        writer.setparams(params)
        writer.writeframes(frames)
    return params.nframes / params.framerate


def measure_peak_dbfs(path: Path) -> float | None:
    """Peak of the ENCODED file, as a player will decode it."""
    result = subprocess.run(
        ["ffmpeg", "-hide_banner", "-i", str(path), "-af", "volumedetect",
         "-f", "null", "/dev/null"],
        capture_output=True,
        text=True,
    )
    match = _PEAK_RE.search(result.stderr)
    return float(match.group(1)) if match else None


def encode_m4a(wav: Path, m4a: Path, atempo: float | None = None) -> None:
    """Encodes, then checks what came out and attenuates until it fits.

    Trusting the pre-encode target is what let a recording ship at -0.0 dBFS.
    """
    trim_db = 0.0
    for attempt in range(MAX_ENCODE_ATTEMPTS):
        filters = []
        if atempo and abs(atempo - 1.0) > 1e-3:
            filters.append(f"atempo={atempo:.4f}")
        if trim_db:
            filters.append(f"volume={trim_db:.2f}dB")

        subprocess.run(
            ["ffmpeg", "-y", "-loglevel", "error", "-i", str(wav),
             *(["-af", ",".join(filters)] if filters else []),
             "-c:a", "aac", "-b:a", AAC_BITRATE, "-movflags", "+faststart",
             str(m4a)],
            check=True,
        )

        peak = measure_peak_dbfs(m4a)
        if peak is None or peak <= CEILING_DBFS:
            return

        # Take off what it overshot, plus a little, and try again.
        trim_db -= (peak - PEAK_DBFS) + 0.5
        print(f"    encoded peak {peak:+.1f} dBFS, retrying at {trim_db:+.2f} dB "
              f"(attempt {attempt + 2}/{MAX_ENCODE_ATTEMPTS})")

    die(f"{m4a.name}: still above {CEILING_DBFS} dBFS after "
        f"{MAX_ENCODE_ATTEMPTS} attempts")


# ------------------------------------------------------------------- engines
def make_piper_synth(voice: dict):
    from piper import PiperVoice, SynthesisConfig  # pip install piper-tts

    VOICES_DIR.mkdir(parents=True, exist_ok=True)
    for url in voice["urls"]:
        curl(url, VOICES_DIR / url.rsplit("/", 1)[1])
    onnx = VOICES_DIR / f"{voice['name']}.onnx"

    config = json.loads(onnx.with_suffix(".onnx.json").read_text(encoding="utf-8"))
    speaker = None
    if int(config.get("num_speakers", 1)) > 1:
        id_map = config.get("speaker_id_map") or {}
        speaker = next(
            (int(v) for k, v in id_map.items()
             if k.lower().startswith(("f", "female", "muller", "mujer"))),
            0,
        )
    print(f"Voice: {voice['label']} · speaker={speaker if speaker is not None else 'single'}")
    loaded = PiperVoice.load(str(onnx))

    def synth(text: str, style: str, raw_wav: Path) -> float | None:
        config = SynthesisConfig(
            length_scale=LENGTH_SCALE.get(style, 1.0),
            speaker_id=speaker,
        )
        with wave.open(str(raw_wav), "wb") as writer:
            loaded.synthesize_wav(text, writer, syn_config=config)
        return None  # style already baked in: no atempo afterwards

    return synth


def make_coqui_synth(voice: dict):
    """Celtia (gl) with controlled prosody.

    Synthesising a whole paragraph at once makes coqui's Synthesizer split it by
    sentence and concatenate with ~0.45 s of dead silence, which breaks the
    pulse. Each sentence is therefore synthesised alone, its edge silence is
    trimmed and the sentences are joined with one short, constant breath.
    """
    import re

    import numpy as np
    from TTS.api import TTS  # pip install coqui-tts (CPU torch)

    repo, siblings = hf_discover(voice["hf_repos"])
    model_file = next((f for f in siblings if f.endswith((".pth", ".pth.tar", ".ckpt"))), None)
    config_file = next((f for f in siblings if f.endswith("config.json")), None)
    if not model_file or not config_file:
        die(f"{repo}: no checkpoint/config among {siblings}")

    vdir = VOICES_DIR / voice["name"]
    vdir.mkdir(parents=True, exist_ok=True)
    model = vdir / Path(model_file).name
    config = vdir / Path(config_file).name
    curl(f"https://huggingface.co/{repo}/resolve/main/{model_file}", model)
    curl(f"https://huggingface.co/{repo}/resolve/main/{config_file}", config)
    print(f"Voice: {voice['label']} · {repo} ({Path(model_file).name})")

    tts = TTS(model_path=str(model), config_path=str(config), progress_bar=False)
    sample_rate = int(tts.synthesizer.output_sample_rate)
    vits = getattr(tts.synthesizer, "tts_model", None)
    native_scale = vits is not None and hasattr(vits, "length_scale")

    sentence_split = re.compile(r"(?<=[.!?…:])\s+")
    pause_sec, edge_keep, pad_sec = 0.16, 0.04, 0.05

    def trim_edges(wav):
        if wav.size == 0:
            return wav
        threshold = float(np.max(np.abs(wav))) * (10 ** (-40 / 20))
        index = np.where(np.abs(wav) > threshold)[0]
        if index.size == 0:
            return wav
        keep = int(sample_rate * edge_keep)
        return wav[max(0, int(index[0]) - keep):min(wav.size, int(index[-1]) + keep)]

    def synth(text: str, style: str, raw_wav: Path) -> float | None:
        scale = LENGTH_SCALE.get(style, 1.0)
        atempo = None
        if native_scale:
            vits.length_scale = scale
        elif scale != 1.0:
            atempo = 1.0 / scale

        pause = np.zeros(int(sample_rate * pause_sec * (atempo or 1.0)), dtype=np.float32)
        pad = np.zeros(int(sample_rate * pad_sec * (atempo or 1.0)), dtype=np.float32)

        sentences = [s.strip() for s in sentence_split.split(text.strip()) if s.strip()]
        chunks = [pad]
        for i, sentence in enumerate(sentences):
            wav = np.asarray(tts.tts(text=sentence, split_sentences=False), dtype=np.float32)
            chunks.append(trim_edges(wav))
            chunks.append(pause if i < len(sentences) - 1 else pad)

        pcm = (np.clip(np.concatenate(chunks), -1.0, 1.0) * 32767.0).astype("<i2")
        with wave.open(str(raw_wav), "wb") as writer:
            writer.setnchannels(1)
            writer.setsampwidth(2)
            writer.setframerate(sample_rate)
            writer.writeframes(pcm.tobytes())
        return atempo

    return synth


# ---------------------------------------------------------------------- main
def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lang", choices=sorted(VOICES), required=True)
    parser.add_argument("--force", action="store_true",
                        help="re-synthesise locutions that already have a recording")
    args = parser.parse_args()

    if not CORPUS_JSON.exists():
        die("voice-corpus.json is missing: run tools/export_voice_corpus.py first")

    corpus = json.loads(CORPUS_JSON.read_text(encoding="utf-8"))["corpus"]
    entries = [e for e in corpus if e["lang"] == args.lang]
    VOICE_DIR.mkdir(parents=True, exist_ok=True)

    pending = [e for e in entries
               if args.force or not (VOICE_DIR / f"{e['id']}.m4a").exists()]

    print(f"{args.lang}: {len(entries)} locutions, {len(pending)} to synthesise")
    if not pending:
        return 0

    voice = VOICES[args.lang]
    synth = make_piper_synth(voice) if voice["engine"] == "piper" else make_coqui_synth(voice)

    work = ROOT / "build" / "voice-tmp"
    work.mkdir(parents=True, exist_ok=True)

    files = []
    for index, entry in enumerate(pending, start=1):
        raw = work / "raw.wav"
        mastered = work / "mastered.wav"
        target = VOICE_DIR / f"{entry['id']}.m4a"

        # `speech` is the text without the teacher's pulse markers and syllable
        # splits; `text` is what the screen shows and what the id hashes.
        atempo = synth(entry.get("speech") or entry["text"], entry["style"], raw)
        seconds = normalize_peak(raw, mastered)
        encode_m4a(mastered, target, atempo)
        files.append({
            "id": entry["id"],
            "file": target.name,
            "seconds": round(seconds, 2),
            "bytes": target.stat().st_size,
        })
        print(f"  [{index}/{len(pending)}] {entry['id']} · {seconds:.2f}s")

    manifest = ROOT / f"voice-assets-manifest.{args.lang}.json"
    known = {f["id"]: f for f in
             (json.loads(manifest.read_text(encoding="utf-8")).get("files", [])
              if manifest.exists() else [])}
    known.update({f["id"]: f for f in files})
    ordered = [known[e["id"]] for e in entries if e["id"] in known]

    manifest.write_text(
        json.dumps(
            {
                "lang": args.lang,
                "voice": voice["label"],
                "peakDbfs": PEAK_DBFS,
                "entries": len(ordered),
                "totalBytes": sum(f["bytes"] for f in ordered),
                "totalSeconds": round(sum(f["seconds"] for f in ordered), 2),
                "files": ordered,
            },
            ensure_ascii=False,
            indent=1,
        ) + "\n",
        encoding="utf-8",
    )
    print(f"OK -> {manifest.name}: {len(ordered)} recordings")
    return 0


if __name__ == "__main__":
    sys.exit(main())
