#!/usr/bin/env python3
"""Mes a mes, qué palabras del banco encajan con la asamblea de ese mes.

    python3 tools/xera_banco_asamblea.py

Módulo M3.3 del plan docente. Con D9 el banco no se mueve, y con D4 el centro
de interés de cada mes es el de su asamblea. Al escribir la unidad de un mes
(M3.4-M3.8) hay que saber qué palabras del banco pueden entrar en su núcleo.
Esta tabla lo dice, mes a mes y para los 50 meses:

- las órdenes de la asamblea, con su id del registro de frases o del banco;
- los temas de las cuatro semanas del banco de ese mes;
- las candidatas **del mismo mes**: palabras del banco que comparten una
  palabra de contenido con las órdenes de la asamblea;
- las candidatas **de otros meses del mismo curso**, que también se pueden
  citar: el id es estable aunque la palabra se enseñe nueva otro mes;
- un veredicto: «encaja» (5 o más candidatas del mismo mes), «parcial» (de 1 a
  4) o «no encaja» (ninguna: el núcleo sale de las órdenes y de otros meses).

Es una coincidencia de palabras, no de significado: «coat» casa con «Put on
your coat!», pero «manoplas» no casa con nada si no se dice en inglés. Por eso
la tabla propone y quien escribe la unidad decide.

Escribe `referencias/banco_frente_asamblea.md`.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENIDO = ROOT / "assets" / "content"
SAIDA = ROOT / "referencias" / "banco_frente_asamblea.md"

CURSOS = ["curso_0_2", "curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]
MESES = ["setembro", "outubro", "novembro", "decembro", "xaneiro",
         "febreiro", "marzo", "abril", "maio", "xuno"]
NOME_MES = ["Septiembre", "Octubre", "Noviembre", "Diciembre", "Enero",
            "Febrero", "Marzo", "Abril", "Mayo", "Junio"]
ASAMBLEA = {
    "curso_0_2": ("primeiro", "0_2_anos"),
    "curso_2_3": ("primeiro", "2_3_anos"),
    "curso_3_4": ("segundo", "4_infantil"),
    "curso_4_5": ("segundo", "5_infantil"),
    "curso_5_6": ("segundo", "6_infantil"),
}

# Palabras que no dicen de qué va una orden.
VACIAS = set(
    "the a an and your my to in on of with up down it is are you we let's lets "
    "go do me this that his her our their at for be can like all now here "
    "there one two three get make put take give look come".split())


def palabras(texto: str) -> set[str]:
    return {w for w in re.findall(r"[a-z']+", texto.lower())
            if w not in VACIAS and len(w) > 2}


def ler(ruta: Path):
    return json.loads(ruta.read_text(encoding="utf-8"))


def main() -> int:
    frases = ler(CONTENIDO / "registro" / "frases.json")["frases"]
    id_da_frase = {f["en"]: f["id"] for f in frases}

    linhas = [
        "# El banco frente a la asamblea, mes a mes",
        "",
        "Generado por `tools/xera_banco_asamblea.py`; no se edita a mano. "
        "Módulo M3.3 del plan docente. Coincidencia de palabras entre las "
        "órdenes de la asamblea y el banco del curso: propone, no decide.",
        "",
    ]
    resumo = []

    for curso in CURSOS:
        banco_curso = []
        for orden in range(1, 11):
            fichero = next((CONTENIDO / "tpr" / curso).glob(f"tpr.{orden:02d}.*.json"))
            datos = ler(fichero)
            for semana in datos["semanas"]:
                for p in semana["palabras"]:
                    banco_curso.append((orden, semana["semana"], p["id"], p["en"]))
        id_do_banco = {en.lower(): pid for _, _, pid, en in banco_curso}

        linhas += [f"## {curso.replace('curso_', '').replace('_', '-')} años", ""]
        for orden in range(1, 11):
            ciclo, sufixo = ASAMBLEA[curso]
            asamblea = ler(CONTENIDO / f"asambleas_{ciclo}_ciclo" /
                           f"asamblea.{ciclo}_ciclo.{MESES[orden - 1]}.{sufixo}.json")
            ordes = [o["textoIngles"] for f in asamblea["fases"]
                     for o in (f.get("comandosL3") or [])]
            chave = set().union(*(palabras(o) for o in ordes)) if ordes else set()
            temas = ler(next((CONTENIDO / "tpr" / curso).glob(
                f"tpr.{orden:02d}.*.json")))["semanas"]

            mesmo, outros = [], []
            for o, s, pid, en in banco_curso:
                if palabras(en) & chave:
                    (mesmo if o == orden else outros).append((o, s, pid, en))
            veredicto = ("encaja" if len(mesmo) >= 5
                         else "parcial" if mesmo else "no encaja")
            resumo.append((curso, orden, veredicto, len(mesmo), len(outros)))

            linhas += [
                f"### {NOME_MES[orden - 1]} · {veredicto}",
                "",
                f"- **Centro de interés (asamblea):** "
                f"{asamblea['centroInteres']['es']}",
                "- **Órdenes de la asamblea:** " + (
                    "; ".join(
                        f"*{o}* (`{id_da_frase.get(o) or id_do_banco.get(o.lower(), '¿?')}`)"
                        for o in ordes) or "ninguna"),
                "- **Temas del banco del mes:** "
                + "; ".join(s["tema"]["es"] for s in temas),
                "- **Candidatas del mismo mes:** " + (
                    ", ".join(f"*{en}* (`{pid}`)" for _, _, pid, en in mesmo)
                    or "ninguna"),
                "- **Candidatas de otros meses:** " + (
                    ", ".join(f"*{en}* (`{pid}`, {NOME_MES[o - 1].lower()})"
                              for o, _, pid, en in outros[:12])
                    + (f" y {len(outros) - 12} más" if len(outros) > 12 else "")
                    or "ninguna"),
                "",
            ]

    cabeza = ["## Resumen", "",
              "| Curso | Mes | Veredicto | Del mismo mes | De otros meses |",
              "| --- | --- | --- | --- | --- |"]
    cabeza += [f"| {c.replace('curso_', '').replace('_', '-')} | "
               f"{NOME_MES[o - 1]} | {v} | {m} | {x} |"
               for c, o, v, m, x in resumo]
    contas = {v: sum(1 for r in resumo if r[2] == v)
              for v in ("encaja", "parcial", "no encaja")}
    cabeza += ["", f"Encajan {contas['encaja']}, parcial {contas['parcial']}, "
               f"no encajan {contas['no encaja']}, de 50.", ""]

    SAIDA.write_text("\n".join(linhas[:4] + cabeza + linhas[4:]) + "\n",
                     encoding="utf-8")
    print(f"Escrito {SAIDA.relative_to(ROOT)}: " + ", ".join(
        f"{k} {v}" for k, v in contas.items()))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
