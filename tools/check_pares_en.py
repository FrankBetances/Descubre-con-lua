#!/usr/bin/env python3
"""Gate fonético de pares mínimos en inglés (P7.1, O-20261119-8 y O-20261118-3).

Comprueba contra el subconjunto de CMUdict en tools/banco/cmudict_escoita.txt:
  1. tools/banco/cmudict_escoita.txt tiene la cabecera de licencia BSD de CMUdict
     y exactamente las entradas de las palabras usadas en plan_mensual.json.
  2. Cada pieza de assets/content/escoita/plan_mensual.json tiene dos palabras
     en inglés que existen en CMUdict con una única pronunciación (no ambiguas).
  3. El par difiere en EXACTAMENTE un fonema (sustitución, inserción o borrado).
  4. La etiqueta «fonema» («/x/ → /y/») coincide con el contraste real a → b.
  5. Ningún par usa un contraste prohibido (como en Valeria):
       - /r/ postvocálica (car, bird)
       - grupo consonántico final (test/tes)
       - sonoridad en posición final (bad/bat)
  6. Ningún par se repite en plan_mensual.json, ni aparecen palabras prohibidas
     en assets/content/escoita/.

Uso:
  python3 tools/check_pares_en.py
  python3 tools/check_pares_en.py --self-test
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
PLAN = RAIZ / "assets/content/escoita/plan_mensual.json"
CMU_PATH = RAIZ / "tools/banco/cmudict_escoita.txt"

VOWELS = {
    "AA", "AE", "AH", "AO", "AW", "AY",
    "EH", "ER", "EY", "IH", "IY", "OW", "OY", "UH", "UW",
}

VOICING = {
    "B": "P", "D": "T", "G": "K", "V": "F",
    "Z": "S", "ZH": "SH", "DH": "TH", "JH": "CH",
}

# IPA -> ARPAbet (CMUdict sin dígito de acento).
# Los tokens de 2 caracteres se comprueban antes que los de 1 carácter.
IPA_TO_ARPA = {
    # Consonantes dobles / africadas
    "tʃ": "CH", "dʒ": "JH",
    # Diptongos / vocales largas
    "eɪ": "EY", "oʊ": "OW", "aɪ": "AY", "aʊ": "AW", "ɔɪ": "OY",
    "iː": "IY", "uː": "UW", "ɑː": "AA", "ɔː": "AO",
    # Consonantes simples
    "p": "P", "b": "B", "t": "T", "d": "D", "k": "K", "g": "G", "ɡ": "G",
    "f": "F", "v": "V", "s": "S", "z": "Z", "h": "HH",
    "m": "M", "n": "N", "l": "L", "r": "R", "w": "W", "j": "Y",
    "θ": "TH", "ð": "DH", "ʃ": "SH", "ʒ": "ZH", "ŋ": "NG",
    # Vocales simples
    "i": "IY", "ɪ": "IH", "e": "EY", "ɛ": "EH", "æ": "AE",
    "ɑ": "AA", "ɔ": "AO", "o": "OW", "ʊ": "UH", "u": "UW",
    "ʌ": "AH", "ə": "AH", "ɚ": "ER", "ɝ": "ER",
}

PROHIBIDO_TEXTO = re.compile(
    r"\b(?:logopedia|terapia|terap[eé]utic[oa]s?|trastorno|cl[ií]nic[oa]s?|diagn[oó]stico)\b",
    re.IGNORECASE,
)


def bare(ph: str) -> str:
    return re.sub(r"\d$", "", ph)


def devoiced(a: str, b: str) -> bool:
    return VOICING.get(a) == b or VOICING.get(b) == a


def load_cmudict(path: Path) -> tuple[bool, dict[str, list[list[str]]]]:
    if not path.is_file():
        return False, {}
    lines = path.read_text(encoding="utf-8").splitlines()
    header = "\n".join(l for l in lines if l.startswith("#"))
    has_license = (
        "Carnegie Mellon University" in header
        and "Redistribution and use in source and binary forms" in header
    )
    words: dict[str, list[list[str]]] = {}
    for raw in lines:
        line = raw.strip()
        if not line or line.startswith("#") or line.startswith(";;;"):
            continue
        parts = line.split("#")[0].strip().split()
        if len(parts) < 2:
            continue
        word = re.sub(r"\(\d+\)$", "", parts[0].lower())
        words.setdefault(word, []).append([bare(ph) for ph in parts[1:]])
    return has_license, words


def to_arpa(label: str) -> tuple[list[str] | None, str | None]:
    s = label.strip().replace("/", "").replace(" ", "")
    if s in ("∅", ""):
        return [], None
    s_clean = s.replace("-", "").replace("ː", "")
    # Reintentar con 'ː' preservado primero para pares largos
    s_raw = s.replace("-", "")
    out: list[str] = []
    i = 0
    while i < len(s_raw):
        two = s_raw[i:i + 2]
        if two in IPA_TO_ARPA:
            out.append(IPA_TO_ARPA[two])
            i += 2
            continue
        one = s_raw[i]
        if one == "ː":
            i += 1
            continue
        if one in IPA_TO_ARPA:
            out.append(IPA_TO_ARPA[one])
            i += 1
            continue
        return None, f"símbolo IPA desconocido «{one}» en «{label}»"
    return out, None


def single_diff(a: list[str], b: list[str]) -> dict | None:
    if len(a) == len(b):
        diffs = [i for i, (pa, pb) in enumerate(zip(a, b)) if pa != pb]
        if len(diffs) != 1:
            return None
        at = diffs[0]
        return {"kind": "sub", "at": at, "from": [a[at]], "to": [b[at]]}
    if len(a) - len(b) == 1:
        for at in range(len(a)):
            if a[:at] + a[at + 1:] == b:
                return {"kind": "del", "at": at, "from": [a[at]], "to": []}
        return None
    if len(b) - len(a) == 1:
        for at in range(len(b)):
            if b[:at] + b[at + 1:] == a:
                return {"kind": "ins", "at": at, "from": [], "to": [b[at]]}
        return None
    return None


def tail_cluster(phs: list[str]) -> int:
    n = 0
    for ph in reversed(phs):
        if ph in VOWELS:
            break
        n += 1
    return n


def check_pair(
    a_word: str,
    b_word: str,
    fonema: str,
    cmu: dict[str, list[list[str]]],
) -> list[str]:
    errs: list[str] = []
    wa = a_word.strip().lower()
    wb = b_word.strip().lower()

    prons: dict[str, list[str]] = {}
    for role, w in (("a", wa), ("b", wb)):
        entry = cmu.get(w)
        if not entry:
            errs.append(f"«{w}» ({role}) no está en CMUdict ({CMU_PATH.name})")
        elif len(entry) > 1:
            al = " / ".join(" ".join(x) for x in entry)
            errs.append(f"«{w}» tiene {len(entry)} pronunciaciones en CMUdict ({al}): palabra ambigua")
        else:
            prons[role] = entry[0]
    if errs:
        return errs

    pa, pb = prons["a"], prons["b"]
    diff = single_diff(pa, pb)
    if not diff:
        errs.append(f"«{wa}» /{' '.join(pa)}/ y «{wb}» /{' '.join(pb)}/ no difieren en exactamente un fonema")
        return errs

    # Validar etiqueta `fonema`
    if "→" not in fonema:
        errs.append(f"etiqueta fonema «{fonema}» sin flecha «→»")
    else:
        lhs, rhs = [x.strip() for x in fonema.split("→", 1)]
        want_from, err_l = to_arpa(lhs)
        want_to, err_r = to_arpa(rhs)
        if err_l:
            errs.append(err_l)
        if err_r:
            errs.append(err_r)
        if want_from is not None and want_to is not None:
            if diff["kind"] == "sub":
                ok_label = (
                    diff["from"][0] in want_from
                    and diff["to"][0] in want_to
                    and len(want_from) == 1
                    and len(want_to) == 1
                )
            elif diff["kind"] == "del":
                at = diff["at"]
                if want_to == []:
                    ok_label = diff["from"] == want_from
                else:
                    # Grupo inicial/final (ej. /sn-/ -> /n-/)
                    ok_label = False
                    for start in range(max(0, at - len(want_from) + 1), at + 1):
                        end = start + len(want_from)
                        if end <= len(pa) and pa[start:end] == want_from:
                            rem = pa[start:at] + pa[at + 1:end]
                            if rem == want_to:
                                ok_label = True
                                break
            else:  # ins
                at = diff["at"]
                if want_from == []:
                    ok_label = diff["to"] == want_to
                else:
                    ok_label = False
                    for start in range(max(0, at - len(want_to) + 1), at + 1):
                        end = start + len(want_to)
                        if end <= len(pb) and pb[start:end] == want_to:
                            rem = pb[start:at] + pb[at + 1:end]
                            if rem == want_from:
                                ok_label = True
                                break
            if not ok_label:
                got_f = " ".join(diff["from"]) or "∅"
                got_t = " ".join(diff["to"]) or "∅"
                errs.append(f"etiqueta fonema «{fonema}» no coincide con el cambio real {got_f} → {got_t}")

    # Contrastes prohibidos (como en Valeria)
    changed = diff["from"] + diff["to"]
    idx = diff["at"]
    longest = pa if len(pa) >= len(pb) else pb

    # 1) /r/ postvocálica
    r_post = ("ER" in changed) or (
        "R" in changed and (
            (diff["kind"] != "ins" and idx > 0 and pa[idx - 1] in VOWELS)
            or (diff["kind"] != "del" and idx > 0 and pb[idx - 1] in VOWELS)
        )
    )
    if r_post:
        errs.append("contraste prohibido: /r/ después de vocal")

    # 2) grupo consonántico final
    tc_a = tail_cluster(pa)
    tc_b = tail_cluster(pb)
    if (tc_a >= 2 and idx >= len(pa) - tc_a) or (tc_b >= 2 and idx >= len(pb) - tc_b):
        errs.append("contraste prohibido: grupo consonántico final")

    # 3) sonoridad en posición final
    if diff["kind"] == "sub" and devoiced(diff["from"][0], diff["to"][0]) and idx == len(pa) - 1:
        errs.append("contraste prohibido: sonoridad en posición final")

    return errs


def run_self_test() -> int:
    sample_cmu = {
        "rake": [["R", "EY", "K"]],
        "wake": [["W", "EY", "K"]],
        "snail": [["S", "N", "EY", "L"]],
        "nail": [["N", "EY", "L"]],
        "seat": [["S", "IY", "T"]],
        "sea": [["S", "IY"]],
        "car": [["K", "AA", "R"]],
        "far": [["F", "AA", "R"]],
        "card": [["K", "AA", "R", "D"]],
        "bad": [["B", "AE", "D"]],
        "bat": [["B", "AE", "T"]],
        "test": [["T", "EH", "S", "T"]],
        "tes": [["T", "EH", "S"]],
        "dog": [["D", "AO", "G"]],
        "cat": [["K", "AE", "T"]],
        "bow": [["B", "AW"], ["B", "OW"]],
        "cow": [["K", "AW"]],
    }
    assert check_pair("rake", "wake", "/r/ → /w/", sample_cmu) == []
    assert check_pair("snail", "nail", "/sn-/ → /n-/", sample_cmu) == []
    assert check_pair("seat", "sea", "/-t/ → ∅", sample_cmu) == []
    assert check_pair("sea", "seat", "∅ → /-t/", sample_cmu) == []
    assert check_pair("nail", "snail", "/n-/ → /sn-/", sample_cmu) == []
    assert check_pair("dog", "cat", "/d/ → /k/", sample_cmu), "debe fallar: >1 fonema"
    assert check_pair("rake", "wake", "/l/ → /w/", sample_cmu), "debe fallar: etiqueta falsa"
    assert check_pair("rake", "wake", "/w/ → /r/", sample_cmu), "debe fallar: dirección invertida"
    assert check_pair("missing", "wake", "/m/ → /w/", sample_cmu), "debe fallar: falta en CMUdict"
    assert check_pair("bow", "cow", "/b/ → /k/", sample_cmu), "debe fallar: ambigua"
    assert check_pair("car", "card", "∅ → /-d/", sample_cmu), "debe fallar: grupo final"
    assert check_pair("test", "tes", "/-t/ → ∅", sample_cmu), "debe fallar: grupo final"
    assert check_pair("bad", "bat", "/d/ → /t/", sample_cmu), "debe fallar: sonoridad final"
    assert check_pair("car", "far", "/k/ → /f/", sample_cmu) == [], "contraste inicial ante /r/ es válido"
    # /r/ después de vocal: heart vs heat
    sample_cmu["heart"] = [["HH", "AA", "R", "T"]]
    sample_cmu["heat"] = [["HH", "IY", "T"]]
    sample_cmu["hot"] = [["HH", "AA", "T"]]
    assert check_pair("heart", "hot", "/r/ → ∅", sample_cmu), "debe fallar: /r/ después de vocal"
    print("OK: self-test de check_pares_en.py superado.")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--self-test", action="store_true", help="Ejecuta pruebas unitarias del validador.")
    args = parser.parse_args()
    if args.self_test:
        return run_self_test()

    fallos: list[str] = []

    has_license, cmu = load_cmudict(CMU_PATH)
    if not CMU_PATH.is_file():
        print(f"FALLO: falta {CMU_PATH.relative_to(RAIZ)}")
        return 1
    if not has_license:
        fallos.append(f"{CMU_PATH.relative_to(RAIZ)}: falta la cabecera de licencia BSD de CMUdict")

    if not PLAN.is_file():
        print(f"FALLO: falta {PLAN.relative_to(RAIZ)}")
        return 1

    raw_plan = PLAN.read_text(encoding="utf-8")
    for n, linea in enumerate(raw_plan.splitlines(), 1):
        m = PROHIBIDO_TEXTO.search(linea)
        if m:
            fallos.append(f"{PLAN.relative_to(RAIZ)}:{n}: palabra prohibida «{m.group(0)}»")

    data = json.loads(raw_plan)
    piezas = data.get("piezas") if isinstance(data, dict) else data
    if not isinstance(piezas, list):
        print(f"FALLO: {PLAN.relative_to(RAIZ)} debe contener una lista de piezas")
        return 1

    cursos_esperados = {"curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"}
    vistos_curso_mes: set[tuple[str, int]] = set()
    pares_vistos: set[frozenset[str]] = set()
    palabras_usadas: set[str] = set()

    for idx, pieza in enumerate(piezas):
        curso = pieza.get("curso")
        mes = pieza.get("mes")
        tag = f"{curso}.m{mes}" if curso and mes is not None else f"pieza[{idx}]"
        if curso not in cursos_esperados or not isinstance(mes, int) or not (1 <= mes <= 10):
            fallos.append(f"{tag}: curso o mes inválido ({curso!r}, {mes!r})")
        elif (curso, mes) in vistos_curso_mes:
            fallos.append(f"{tag}: curso+mes repetido")
        else:
            vistos_curso_mes.add((curso, mes))

        par = pieza.get("par") or {}
        a = (par.get("a") or {}).get("en", "")
        b = (par.get("b") or {}).get("en", "")
        fonema = par.get("fonema", "")
        if not a or not b:
            fallos.append(f"{tag}: falta par.a.en o par.b.en")
            continue

        wa, wb = a.strip().lower(), b.strip().lower()
        palabras_usadas.update([wa, wb])
        clave_par = frozenset((wa, wb))
        if clave_par in pares_vistos:
            fallos.append(f"{tag}: par repetido ({wa}/{wb})")
        pares_vistos.add(clave_par)

        for err in check_pair(wa, wb, fonema, cmu):
            fallos.append(f"{tag} ({wa}/{wb}): {err}")

    esperados = {(c, m) for c in cursos_esperados for m in range(1, 11)}
    faltan = sorted(esperados - vistos_curso_mes)
    if faltan:
        fallos.append(f"faltan {len(faltan)} piezas para completar las 40: {faltan[:6]}")

    sobran = sorted(set(cmu) - palabras_usadas)
    if sobran:
        fallos.append(f"{CMU_PATH.relative_to(RAIZ)} contiene palabras no usadas: {sobran[:10]}")

    if fallos:
        print("FALLO (check_pares_en):")
        for f in fallos:
            print(f"  {f}")
        return 1

    print(
        f"OK: {len(piezas)} pares mínimos en {PLAN.relative_to(RAIZ)} "
        f"({len(palabras_usadas)} palabras en CMUdict), 1 fonema distinto y sin contrastes prohibidos."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
