#!/usr/bin/env python3
"""Gate P11.8 + M2 + M3: verifica que cada semana das cinco idades ten:
  1. As súas 3 capas (`nucleo`, `mais`, `apoio`) co nome do STEAM do mes.
  2. As 6 rutinas do fogar M2 (`bano`, `comida`, `coche`, `vestirse`, `durmir`, `parque`)
     en cada capa e semana, co STEAM do mes e sen repetir entre semanas.
  3. O reto semanal de irmáns M3 en `assets/content/nivel/reto_irmans.json` para
     cada semana (1..40) e cada parella de cursos veciños (`0-2__2-3` .. `4-5__5-6`).

Uso: python3 tools/check_capas_semana.py
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
C = RAIZ / "assets" / "content"
CAPAS = ("nucleo", "mais", "apoio")
RUTINAS = ("bano", "comida", "coche", "vestirse", "durmir", "parque")
PARELLAS = (
    "curso_0_2__curso_2_3",
    "curso_2_3__curso_3_4",
    "curso_3_4__curso_4_5",
    "curso_4_5__curso_5_6",
)


def revisar() -> list[str]:
    fallos: list[str] = []

    # 1. leccions.json: 5 cursos × 40 semanas = 200 semanas.
    lec = json.loads((C / "leccions" / "leccions.json").read_text(encoding="utf-8"))["cursos"]
    if len(lec) != 5:
        fallos.append(f"esperados 5 cursos en leccions.json, atopados {len(lec)}")
    for curso, cv in lec.items():
        vistos_rut: dict[tuple[str, str], set[str]] = {}
        total_sem = 0
        for u in cv.get("unidades") or []:
            st = (u.get("steam") or {}).get("titulo") or {}
            st_gl = st.get("gl", "")
            st_es = st.get("es", "")
            for l in u.get("leccions") or []:
                total_sem += 1
                lid = l.get("id", "?")
                capas = l.get("capas") or {}
                for c_key in CAPAS:
                    c_obj = capas.get(c_key) or {}
                    gl = c_obj.get("gl", "")
                    es = c_obj.get("es", "")
                    en = c_obj.get("en", "")
                    if not (gl and es and en):
                        fallos.append(f"{lid} capa {c_key}: falta gl/es/en")
                    elif (st_gl and st_gl not in gl) or (st_es and st_es not in es):
                        fallos.append(f"{lid} capa {c_key}: non nomea o STEAM «{st_es}»")
                    ruts = c_obj.get("rutinas") or {}
                    for r_key in RUTINAS:
                        r_obj = ruts.get(r_key) or {}
                        r_gl = r_obj.get("gl", "")
                        r_es = r_obj.get("es", "")
                        r_en = r_obj.get("en", "")
                        if not (r_gl and r_es and r_en):
                            fallos.append(f"{lid} capa {c_key} rutina {r_key}: incompleta")
                        elif (st_gl and st_gl not in r_gl) or (st_es and st_es not in r_es):
                            fallos.append(f"{lid} capa {c_key} rutina {r_key}: non nomea o STEAM")
                        else:
                            bucket = vistos_rut.setdefault((c_key, r_key), set())
                            if r_es in bucket:
                                fallos.append(f"{lid} capa {c_key} rutina {r_key}: texto repetido entre semanas")
                            bucket.add(r_es)
        if total_sem != 40:
            fallos.append(f"{curso}: esperadas 40 semanas, atopadas {total_sem}")

    # 2. proxectos_0_2.json: 10 proxectos × 4 semanas = 40 semanas.
    ac = json.loads((C / "acopros" / "proxectos_0_2.json").read_text(encoding="utf-8"))["proxectos"]
    if len(ac) != 10:
        fallos.append(f"proxectos_0_2.json: esperados 10 meses, atopados {len(ac)}")
    rut_02_vistos: dict[str, set[str]] = {}
    for pr in ac:
        mes = pr.get("mesCalendario")
        st = (pr.get("steam") or {}).get("titulo") or {}
        st_gl, st_es = st.get("gl", ""), st.get("es", "")
        for sem in pr.get("semanas") or []:
            snum = sem.get("semana")
            capas = sem.get("capas") or {}
            for c_key in CAPAS:
                c_obj = capas.get(c_key) or {}
                if not (c_obj.get("gl") and c_obj.get("es") and c_obj.get("en")):
                    fallos.append(f"0-2 mes {mes} sem {snum} capa {c_key}: incompleta")
                elif (st_gl and st_gl not in c_obj["gl"]) or (st_es and st_es not in c_obj["es"]):
                    fallos.append(f"0-2 mes {mes} sem {snum} capa {c_key}: sen STEAM")
            ruts = sem.get("rutinas") or {}
            for r_key in RUTINAS:
                r_obj = ruts.get(r_key) or {}
                r_gl, r_es, r_en = r_obj.get("gl", ""), r_obj.get("es", ""), r_obj.get("en", "")
                if not (r_gl and r_es and r_en):
                    fallos.append(f"0-2 mes {mes} sem {snum} rutina {r_key}: incompleta")
                elif (st_gl and st_gl not in r_gl) or (st_es and st_es not in r_es):
                    fallos.append(f"0-2 mes {mes} sem {snum} rutina {r_key}: sen STEAM")
                else:
                    b02 = rut_02_vistos.setdefault(r_key, set())
                    if r_es in b02:
                        fallos.append(f"0-2 mes {mes} sem {snum} rutina {r_key}: repetida entre semanas")
                    b02.add(r_es)

    # 3. M3: reto_irmans.json (4 parellas × 40 semanas = 160 pezas).
    irmans_path = C / "nivel" / "reto_irmans.json"
    if not irmans_path.is_file():
        fallos.append("falta assets/content/nivel/reto_irmans.json (M3)")
    else:
        rm = json.loads(irmans_path.read_text(encoding="utf-8")).get("pares") or {}
        for par in PARELLAS:
            items = rm.get(par) or []
            sems = {it.get("semanaCurso") for it in items}
            if len(items) != 40 or sems != set(range(1, 41)):
                fallos.append(f"reto_irmans {par}: faltan semanas ({len(items)}/40)")

    return fallos


def main() -> int:
    fallos = revisar()
    if fallos:
        print("FALLO (check_capas_semana):\n  " + "\n  ".join(fallos[:30]))
        return 1
    print(
        "OK: 200 semanas de 5 idades coas 3 capas STEAM, 6 rutinas M2 sen repetir "
        "e 160 retos semanais de irmáns M3 completos."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
