#!/usr/bin/env python3
"""M3 (corrección 26/11/2026): xerador do reto semanal de irmáns.

Produce assets/content/nivel/reto_irmans.json cunha peza por semana (1..40) e
por cada parella de cursos veciños:
  - curso_0_2 + curso_2_3
  - curso_2_3 + curso_3_4
  - curso_3_4 + curso_4_5
  - curso_4_5 + curso_5_6

Cada peza xunta palabras dos dous cursos nesa semana, nomea os dous STEAM en
gl e es, inclúe frase en inglés con voz `child` + `slow`, e propón que o maior
lle diga as palabras ao pequeno mentres a persoa adulta marca aos dous.
Para cursos non veciños úsase a peza do curso do pequeno co seguinte.

Uso: python3 tools/gen_reto_irmans.py [--check]
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SAIDA = RAIZ / "assets/content/nivel/reto_irmans.json"
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
PARELLAS = [
    ("curso_0_2", "curso_2_3"),
    ("curso_2_3", "curso_3_4"),
    ("curso_3_4", "curso_4_5"),
    ("curso_4_5", "curso_5_6"),
]
NOMES_CURSO = {
    "curso_0_2": ("0-2 anos", "0-2 años"),
    "curso_2_3": ("2-3 anos", "2-3 años"),
    "curso_3_4": ("3-4 anos", "3-4 años"),
    "curso_4_5": ("4-5 anos", "4-5 años"),
    "curso_5_6": ("5-6 anos", "5-6 años"),
}


def _peza_semana_02(proxecto: dict, s_idx: int) -> tuple[dict, dict]:
    sem = proxecto["semanas"][s_idx]
    st = proxecto.get("steam") or {"id": f"STEAM-0_2-{proxecto['mesCalendario']:02d}", "titulo": proxecto["proxecto"]}
    by_en = {w["en"]: w for w in proxecto["palabras"]}
    pref = (sem.get("novas") or sem.get("palabras") or [])
    p = by_en[pref[0]]
    return {
        "en": p["en"],
        "gl": p["gl"],
        "es": p["es"],
        "lamina": p.get("lamina"),
    }, {
        "id": st.get("id", ""),
        "titulo": st.get("titulo") or proxecto["proxecto"],
    }


def _peza_semana_lec(unidade: dict, s_idx: int) -> tuple[dict, dict]:
    lec = unidade["leccions"][s_idx]
    st = unidade.get("steam") or {"id": "", "titulo": unidade["titulo"]}
    cands = (lec.get("novas") or lec.get("repasa") or lec.get("xaSabe") or [])
    p = cands[0] if cands else (lec.get("fraseGramatica") or {"en": "Look!", "gl": "Mira!", "es": "¡Mira!"})
    return {
        "en": p["en"],
        "gl": p.get("gl", ""),
        "es": p.get("es", ""),
        "lamina": p.get("lamina"),
    }, {
        "id": st.get("id", ""),
        "titulo": st.get("titulo") or unidade["titulo"],
    }


def _clean_en(t: str) -> str:
    return t.strip().rstrip(".!?")


def construir() -> dict:
    lec = json.loads((RAIZ / "assets/content/leccions/leccions.json").read_text(encoding="utf-8"))["cursos"]
    ac = {
        p["mesCalendario"]: p
        for p in json.loads((RAIZ / "assets/content/acopros/proxectos_0_2.json").read_text(encoding="utf-8"))["proxectos"]
    }

    pares_out: dict[str, list[dict]] = {}
    for c_min, c_max in PARELLAS:
        clave = f"{c_min}__{c_max}"
        items: list[dict] = []
        for m_idx, mes in enumerate(MESES):
            for s_idx in range(4):
                sem_curso = m_idx * 4 + s_idx + 1
                if c_min == "curso_0_2":
                    p_min, st_min = _peza_semana_02(ac[mes], s_idx)
                else:
                    p_min, st_min = _peza_semana_lec(lec[c_min]["unidades"][m_idx], s_idx)
                p_max, st_max = _peza_semana_lec(lec[c_max]["unidades"][m_idx], s_idx)

                st_min_gl = st_min["titulo"]["gl"]
                st_min_es = st_min["titulo"]["es"]
                st_max_gl = st_max["titulo"]["gl"]
                st_max_es = st_max["titulo"]["es"]

                w1 = _clean_en(p_min["en"])
                w2 = _clean_en(p_max["en"])
                if w1.lower() == w2.lower():
                    frase_en = f"Together now: {w1}!"
                else:
                    frase_en = f"{w1}, and {w2}!"

                n_min_gl, n_min_es = NOMES_CURSO[c_min]
                n_max_gl, n_max_es = NOMES_CURSO[c_max]

                items.append({
                    "id": f"reto_irmans.{c_min}.{c_max}.s{sem_curso:02d}",
                    "cursoMenor": c_min,
                    "cursoMaior": c_max,
                    "mesCalendario": mes,
                    "semanaDoMes": s_idx + 1,
                    "semanaCurso": sem_curso,
                    "steamMenor": st_min,
                    "steamMaior": st_max,
                    "palabraMenor": p_min,
                    "palabraMaior": p_max,
                    "titulo": {
                        "gl": f"Reto de irmáns · Semana {s_idx + 1} ({n_min_gl} e {n_max_gl})",
                        "es": f"Reto de hermanos · Semana {s_idx + 1} ({n_min_es} y {n_max_es})",
                    },
                    "instrucion": {
                        "gl": (
                            f"Quen vai en {n_max_gl} («{st_max_gl}») dille «{p_max['en']}» e «{p_min['en']}» "
                            f"a quen vai en {n_min_gl} («{st_min_gl}»), facendo o xesto xuntos. A persoa adulta marca aos dous."
                        ),
                        "es": (
                            f"Quien va en {n_max_es} («{st_max_es}») dice «{p_max['en']}» y «{p_min['en']}» "
                            f"a quien va en {n_min_es} («{st_min_es}»), haciendo el gesto juntos. La persona adulta marca a los dos."
                        ),
                    },
                    "fraseEn": frase_en,
                    "fraseSignificado": {
                        "gl": f"{p_min['gl'].rstrip('.!?')} e {p_max['gl'].rstrip('.!?')}.",
                        "es": f"{p_min['es'].rstrip('.!?')} y {p_max['es'].rstrip('.!?')}.",
                    },
                })
        pares_out[clave] = items

    return {
        "_doc": "Xerado por tools/gen_reto_irmans.py (M3 · P11.7). Non se edita a man.",
        "pares": pares_out,
    }


def revisar(d: dict) -> list[str]:
    fallos = []
    for c_min, c_max in PARELLAS:
        clave = f"{c_min}__{c_max}"
        items = d.get("pares", {}).get(clave) or []
        if len(items) != 40:
            fallos.append(f"{clave}: {len(items)} semanas (esperadas 40)")
            continue
        sems_vistas = set()
        for it in items:
            sc = it.get("semanaCurso")
            sems_vistas.add(sc)
            st1_gl = it["steamMenor"]["titulo"]["gl"]
            st1_es = it["steamMenor"]["titulo"]["es"]
            st2_gl = it["steamMaior"]["titulo"]["gl"]
            st2_es = it["steamMaior"]["titulo"]["es"]
            ins = it.get("instrucion") or {}
            if st1_gl not in ins.get("gl", "") or st2_gl not in ins.get("gl", ""):
                fallos.append(f"{it['id']} gl: non nomea ambos STEAM")
            if st1_es not in ins.get("es", "") or st2_es not in ins.get("es", ""):
                fallos.append(f"{it['id']} es: no nombra ambos STEAM")
            if not it.get("fraseEn") or not it.get("fraseSignificado", {}).get("gl") or not it.get("fraseSignificado", {}).get("es"):
                fallos.append(f"{it['id']}: falta fraseEn ou significado")
        if sems_vistas != set(range(1, 41)):
            fallos.append(f"{clave}: faltan semanas {set(range(1, 41)) - sems_vistas}")
    return fallos


def main() -> int:
    d = construir()
    fallos = revisar(d)
    texto = json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    if "--check" in sys.argv:
        if not SAIDA.exists() or SAIDA.read_text(encoding="utf-8") != texto:
            fallos.append(f"{SAIDA.relative_to(RAIZ)} non está ao día: python3 tools/gen_reto_irmans.py")
    else:
        SAIDA.parent.mkdir(parents=True, exist_ok=True)
        SAIDA.write_text(texto, encoding="utf-8")
    if fallos:
        print("FALLO (M3 Reto de irmáns):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: reto_irmans.json al día (4 parejas vecinas × 40 semanas = 160 piezas con ambos STEAM y voz).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
