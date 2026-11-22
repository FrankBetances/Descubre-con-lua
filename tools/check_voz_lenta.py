#!/usr/bin/env python3
"""Gate P9.1: toda frase inglesa que oye el niño tiene voz `child` (1.05) y `slow` (1.6).

Comprueba (O-20261120-1, fuente Valeria `generate-voice-assets.py` y `stepLines`):
  1. `tools/voice_corpus.py` define `LENGTH_SCALE` con `tutor: 1.0`, `child: 1.05`,
     `slow: 1.6` y `estilo_ingles(text, para_neno=True)` coincide con
     `estiloIngles` de `lib/core/audio/voice_id.dart`.
  2. Toda frase inglesa dirigida al niño en `assets/content/escoita/plan_mensual.json`
     (par, progresión y su frase, modelo del adulto y momentos de pensamiento) y en
     `assets/content/acopros/proxectos_0_2.json` (`mira_e_nota`) tiene su entrada
     `child` y su versión completa `slow` en `voice-corpus.json`; las palabras
     sueltas tienen `slow`.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

from voice_corpus import (  # noqa: E402
    CONTENT_DIR,
    CORPUS_JSON,
    LENGTH_SCALE,
    estilo_ingles,
    normalize,
    voice_id,
)

VOICE_ID_DART = RAIZ / "lib" / "core" / "audio" / "voice_id.dart"


def _frases_neno() -> list[tuple[str, str]]:
    out: list[tuple[str, str]] = []
    plan_path = CONTENT_DIR / "escoita" / "plan_mensual.json"
    if plan_path.exists():
        data = json.loads(plan_path.read_text(encoding="utf-8"))
        pezas = data if isinstance(data, list) else (data.get("piezas") or data.get("pezas") or [])
        for p in pezas:
            sitio = f"{p.get('curso', '?')} mes {p.get('mes', '?')}"
            par = p.get("par") or {}
            if not par.get("pendiente"):
                for k in ("a", "b"):
                    w = (par.get(k) or {}).get("en")
                    if w:
                        out.append((f"{sitio} par.{k}", str(w)))
            for f in (p.get("progresion") or {}).get("fases") or []:
                if f.get("en"):
                    out.append((f"{sitio} fase.{f.get('tipo', '?')}", str(f["en"])))
                if f.get("frase"):
                    out.append((f"{sitio} fase.{f.get('tipo', '?')}.frase", str(f["frase"])))
            for idx, frase in enumerate((p.get("modelo") or {}).get("adulto") or []):
                if frase:
                    out.append((f"{sitio} modelo[{idx}]", str(frase)))
            pens = p.get("pensamiento")
            if isinstance(pens, dict):
                for mom in ("predice", "proba", "compara", "explica"):
                    m = pens.get(mom)
                    if not isinstance(m, dict):
                        continue
                    if m.get("pregunta_en"):
                        out.append((f"{sitio} pensamiento.{mom}.pregunta_en", str(m["pregunta_en"])))
                    if m.get("modelo_en"):
                        out.append((f"{sitio} pensamiento.{mom}.modelo_en", str(m["modelo_en"])))

    acopros_path = CONTENT_DIR / "acopros" / "proxectos_0_2.json"
    if acopros_path.exists():
        data = json.loads(acopros_path.read_text(encoding="utf-8"))
        for p in data.get("proxectos") or []:
            mira = p.get("mira_e_nota")
            if isinstance(mira, dict) and mira.get("frase_en"):
                out.append((f"acopros mes {p.get('mesCalendario', '?')} mira_e_nota", str(mira["frase_en"])))

    ar_path = CONTENT_DIR / "escoita" / "ar_estimulacion.json"
    if ar_path.exists():
        ar = json.loads(ar_path.read_text(encoding="utf-8"))
        for act in ar.get("actividades_faciais") or []:
            if act.get("frase_en"):
                out.append((f"ar.face.{act.get('id', '?')}", str(act["frase_en"])))
        for esc in ar.get("escenas") or []:
            for fr in esc.get("frases_en") or []:
                out.append((f"ar.{esc.get('id', '?')}.frase", str(fr)))
            for ev in (esc.get("scene_spec") or {}).get("events") or []:
                if ev.get("englishPhrase"):
                    out.append((f"ar.{esc.get('id', '?')}.ev", str(ev["englishPhrase"])))
    return out


def main() -> int:
    fallos: list[str] = []

    esperado = {"tutor": 1.0, "child": 1.05, "slow": 1.6}
    for k, v in esperado.items():
        if LENGTH_SCALE.get(k) != v:
            fallos.append(f"LENGTH_SCALE[{k!r}]={LENGTH_SCALE.get(k)!r}, se esperaba {v!r}")

    if estilo_ingles("The boat floats.", para_neno=True) != "child":
        fallos.append("estilo_ingles con frase y para_neno=True no devuelve 'child'")
    if estilo_ingles("boat", para_neno=True) != "slow":
        fallos.append("estilo_ingles con palabra suelta no devuelve 'slow'")
    if estilo_ingles("The boat floats.", para_neno=False) != "tutor":
        fallos.append("estilo_ingles con frase adulta no devuelve 'tutor'")

    if not VOICE_ID_DART.exists():
        fallos.append("falta lib/core/audio/voice_id.dart")
    else:
        dart = VOICE_ID_DART.read_text(encoding="utf-8")
        if "child," not in dart or "VoiceStyle.child" not in dart:
            fallos.append("voice_id.dart no define VoiceStyle.child ni lo devuelve en estiloIngles")

    if not CORPUS_JSON.exists():
        fallos.append("falta voice-corpus.json")
    else:
        corpus = json.loads(CORPUS_JSON.read_text(encoding="utf-8")).get("corpus") or []
        ids = {e["id"] for e in corpus}
        frases = _frases_neno()
        for sitio, raw in frases:
            texto = normalize(raw)
            if not texto:
                continue
            slow_id = voice_id("slow", texto, "en")
            if slow_id not in ids:
                fallos.append(f"{sitio}: falta versión 'slow' ({slow_id}) para «{texto}»")
            if " " in texto:
                child_id = voice_id("child", texto, "en")
                if child_id not in ids:
                    fallos.append(f"{sitio}: falta versión 'child' ({child_id}) para «{texto}»")

    if fallos:
        print("FALLA (check_voz_lenta):\n  " + "\n  ".join(fallos), file=sys.stderr)
        return 1

    frases = _frases_neno()
    n_frases = sum(1 for _, t in frases if " " in normalize(t))
    print(f"OK: {len(frases)} locuciones inglesas para el niño ({n_frases} frases con child 1.05 + slow 1.6).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
