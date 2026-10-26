#!/usr/bin/env python3
"""Las unidades del mes: una por curso y mes, y lo que citan existe.

    python3 tools/check_unidades.py              # lo que hay, y qué meses faltan
    python3 tools/check_unidades.py --estricto   # además, exige los 50

Módulo M3.1 del plan docente (`docs/PLAN_MEJORA_INTEGRAL.md`). La unidad es la
única fuente del mes (`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartado 3): las
pantallas leen la unidad y no guardan contenido propio. Vive en
`assets/content/unidades_mes/<curso>/unidade.NN.json`, con NN el mes del curso
(01 es septiembre). La carpeta se llama `unidades_mes/` porque `unidades/` era
la de la asamblea de seis pasos, que se retiró en M4.3.

Comprueba, por unidad:

- que el esquema está completo y que todo texto va en gallego Y en castellano;
- que el **centro de interés es el de su asamblea**, letra por letra (D4: manda
  la asamblea), que esa asamblea existe y que la canción es la suya;
- que todo lo que cita (núcleo, fórmulas, estructura, órdenes, contraste y
  reactivación) es un id del banco TPR o del registro de frases
  (`assets/content/registro/frases.json`, cuando exista). No se copia la
  palabra: se cita;
- que el núcleo tiene el tamaño de su edad (apartado 3 de la arquitectura);
- que las órdenes son las de su asamblea, todas y en su orden (M4.1);
- que cada orden usa solo lo que la unidad enseña;
- que la reactivación sale del núcleo de la unidad del mes anterior.

Escribe una línea por fallo y sale con 1 si hay alguno. Sin `--estricto`, los
meses que faltan se listan pero no son fallo: las unidades se escriben curso a
curso (M3.4-M3.8).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENIDO = ROOT / "assets" / "content"
UNIDADES = CONTENIDO / "unidades_mes"
FRASES = CONTENIDO / "registro" / "frases.json"

CURSOS = ["curso_0_2", "curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]
MESES = ["setembro", "outubro", "novembro", "decembro", "xaneiro",
         "febreiro", "marzo", "abril", "maio", "xuno"]
MES_CALENDARIO = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]

# La asamblea de cada curso: ciclo y sufijo del fichero.
ASAMBLEA = {
    "curso_0_2": ("primeiro", "0_2_anos"),
    "curso_2_3": ("primeiro", "2_3_anos"),
    "curso_3_4": ("segundo", "4_infantil"),
    "curso_4_5": ("segundo", "5_infantil"),
    "curso_5_6": ("segundo", "6_infantil"),
}

# Tamaño por edad (arquitectura, apartado 3): (mínimo, máximo) de cada bloque.
TAMANO = {
    "curso_0_2": {"nucleo": (3, 5), "descriptivas": (0, 0),
                  "formulas": (0, 0), "estructura": (0, 0)},
    "curso_2_3": {"nucleo": (5, 5), "descriptivas": (0, 0),
                  "formulas": (0, 0), "estructura": (0, 0)},
    "curso_3_4": {"nucleo": (5, 5), "descriptivas": (0, 0),
                  "formulas": (2, 2), "estructura": (0, 0)},
    "curso_4_5": {"nucleo": (5, 5), "descriptivas": (3, 3),
                  "formulas": (2, 2), "estructura": (1, 1)},
    "curso_5_6": {"nucleo": (5, 5), "descriptivas": (3, 3),
                  "formulas": (2, 2), "estructura": (1, 1)},
}

NOME = re.compile(r"^unidade\.(\d{2})\.json$")


def bilingue(valor, donde: str, fallos: list[str]) -> None:
    """Un texto de la unidad: gallego y castellano, los dos con algo dentro."""
    if not isinstance(valor, dict):
        fallos.append(f"{donde}: falta el texto en gl y es")
        return
    for lingua in ("gl", "es"):
        if not str(valor.get(lingua, "")).strip():
            fallos.append(f"{donde}: falta el texto en {lingua}")


def ids_do_banco() -> set[str]:
    ids: set[str] = set()
    for fichero in (CONTENIDO / "tpr").glob("curso_*/tpr.*.json"):
        for semana in json.loads(fichero.read_text(encoding="utf-8"))["semanas"]:
            for palabra in semana["palabras"]:
                ids.add(palabra["id"])
    return ids


def ids_das_frases() -> set[str]:
    if not FRASES.exists():
        return set()
    datos = json.loads(FRASES.read_text(encoding="utf-8"))
    return {f["id"] for f in datos.get("frases", [])}


def asamblea_de(curso: str, orden: int) -> tuple[str, dict | None]:
    ciclo, sufixo = ASAMBLEA[curso]
    nome = f"asamblea.{ciclo}_ciclo.{MESES[orden - 1]}.{sufixo}"
    fichero = CONTENIDO / f"asambleas_{ciclo}_ciclo" / f"{nome}.json"
    if not fichero.exists():
        return nome, None
    return nome, json.loads(fichero.read_text(encoding="utf-8"))


def refs(lista) -> list[str]:
    return [e.get("ref", "") for e in (lista or []) if isinstance(e, dict)]


def revisar(curso: str, orden: int, u: dict, existentes: set[str],
            anterior: dict | None, fallos: list[str]) -> None:
    donde = f"unidades_mes/{curso}/unidade.{orden:02d}.json"

    esperado = {
        "id": f"unidade.{curso}.{orden:02d}",
        "curso": curso,
        "orden": orden,
        "mesCalendario": MES_CALENDARIO[orden - 1],
    }
    for clave, valor in esperado.items():
        if u.get(clave) != valor:
            fallos.append(f"{donde}: «{clave}» debe ser {valor!r}, "
                          f"no {u.get(clave)!r}")

    nome, asamblea = asamblea_de(curso, orden)
    if u.get("asamblea") != nome:
        fallos.append(f"{donde}: «asamblea» debe ser {nome!r}")
    if asamblea is None:
        fallos.append(f"{donde}: no existe la asamblea {nome}")
    else:
        centro = asamblea.get("centroInteres") or {}
        for lingua in ("gl", "es"):
            if (u.get("centroInteres") or {}).get(lingua) != centro.get(lingua):
                fallos.append(
                    f"{donde}: el centro de interés en {lingua} no es el de la "
                    f"asamblea (D4): «{centro.get(lingua)}»")

    # Las órdenes son las de la asamblea, todas y en su orden (M4.1): el
    # reproductor las lee de la unidad, y la progresión del día las elige por
    # su posición. Si una sobrara, faltara o cambiara de sitio, el día daría
    # otra orden que la que dice su consigna.
    if asamblea is not None:
        da_asamblea_ordes = [
            f"frase.{o['id']}" for fase in asamblea.get("fases", [])
            for o in (fase.get("comandosL3") or [])]
        da_unidade = [o.get("ref") for o in (u.get("ordenes") or [])]
        if da_unidade != da_asamblea_ordes:
            fallos.append(f"{donde}: las órdenes no son las de su asamblea, "
                          f"en su orden: {da_asamblea_ordes}")

    # La canción es la de la asamblea, si la trae; si no, no hay canción.
    cancion = (u.get("cancion") or {}).get("titulo")
    da_asamblea = (asamblea or {}).get("cancionDoMes") or None
    if cancion != da_asamblea:
        fallos.append(f"{donde}: la canción debe ser la de la asamblea: "
                      f"{da_asamblea!r}, no {cancion!r}")

    ensina: set[str] = set()
    for bloque, (minimo, maximo) in TAMANO[curso].items():
        if bloque == "estructura":
            lista = [u["estructura"]] if u.get("estructura") else []
        else:
            lista = u.get(bloque) or []
        if not minimo <= len(lista) <= maximo:
            rango = str(minimo) if minimo == maximo else f"de {minimo} a {maximo}"
            fallos.append(f"{donde}: «{bloque}» lleva {len(lista)}; en "
                          f"{curso} van {rango}")
        for ref in refs(lista):
            if ref not in existentes:
                fallos.append(f"{donde}: {bloque}: «{ref}» no está en el banco "
                              "ni en el registro de frases")
            ensina.add(ref)
    for i, entrada in enumerate(u.get("nucleo") or []):
        if "objeto" in entrada:
            bilingue(entrada["objeto"], f"{donde}: nucleo.{i}.objeto", fallos)
    if u.get("estructura"):
        bilingue(u["estructura"].get("nota"), f"{donde}: estructura.nota",
                 fallos)

    ordes = u.get("ordenes") or []
    if not ordes:
        fallos.append(f"{donde}: no hay órdenes")
    for i, orde in enumerate(ordes):
        if orde.get("ref") not in existentes:
            fallos.append(f"{donde}: ordenes.{i}: «{orde.get('ref')}» no está "
                          "en el banco ni en el registro de frases")
        usa = orde.get("usa") or []
        if not usa:
            fallos.append(f"{donde}: ordenes.{i}: no dice qué usa del núcleo")
        for ref in usa:
            if ref not in ensina:
                fallos.append(f"{donde}: ordenes.{i}: usa «{ref}», que la "
                              "unidad no enseña")

    realia = u.get("realia") or []
    if not realia:
        fallos.append(f"{donde}: falta la realia")
    for i, objeto in enumerate(realia):
        bilingue(objeto, f"{donde}: realia.{i}", fallos)

    contraste = u.get("contraste")
    # F4: desde 2-3 cada mes trae su contraste de sonido. En 0-2 no, porque el
    # contraste empieza a los 18 meses y el curso arranca antes (M3.4).
    if not contraste and curso != "curso_0_2":
        fallos.append(f"{donde}: falta el contraste de sonido (F4)")
    if contraste and contraste.get("a") == contraste.get("b"):
        fallos.append(f"{donde}: el contraste compara una palabra consigo misma")
    if contraste:
        for lado in ("a", "b"):
            if contraste.get(lado) not in existentes:
                fallos.append(f"{donde}: contraste.{lado}: «{contraste.get(lado)}»"
                              " no está en el banco ni en el registro")
        bilingue(contraste.get("nota"), f"{donde}: contraste.nota", fallos)

    observar = u.get("queObservar") or []
    if not 2 <= len(observar) <= 4:
        fallos.append(f"{donde}: «queObservar» lleva {len(observar)}; van de 2 a 4")
    for i, linea in enumerate(observar):
        bilingue(linea, f"{donde}: queObservar.{i}", fallos)

    reactivar = u.get("reactivar") or []
    if orden == 1 and reactivar:
        fallos.append(f"{donde}: septiembre no tiene mes anterior que reactivar")
    for ref in reactivar:
        if ref not in existentes:
            fallos.append(f"{donde}: reactivar: «{ref}» no está en el banco ni "
                          "en el registro de frases")
    if anterior is not None:
        do_anterior = set(refs(anterior.get("nucleo")))
        for ref in reactivar:
            if ref not in do_anterior:
                fallos.append(f"{donde}: reactivar: «{ref}» no está en el "
                              "núcleo del mes anterior")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--estricto", action="store_true",
                        help="exige las 50 unidades")
    args = parser.parse_args()

    existentes = ids_do_banco() | ids_das_frases()
    fallos: list[str] = []
    faltan: list[str] = []
    vistas = 0

    for curso in CURSOS:
        carpeta = UNIDADES / curso
        anterior = None
        for orden in range(1, 11):
            fichero = carpeta / f"unidade.{orden:02d}.json"
            if not fichero.exists():
                faltan.append(f"{curso} · {MESES[orden - 1]}")
                anterior = None
                continue
            u = json.loads(fichero.read_text(encoding="utf-8"))
            revisar(curso, orden, u, existentes, anterior, fallos)
            anterior = u
            vistas += 1
        if carpeta.exists():
            for sobra in sorted(carpeta.iterdir()):
                if not NOME.match(sobra.name):
                    fallos.append(f"unidades_mes/{curso}/{sobra.name}: no es "
                                  "una unidad (unidade.NN.json)")

    if args.estricto and faltan:
        fallos.extend(f"falta la unidad de {m}" for m in faltan)

    if fallos:
        print("Las unidades del mes no cuadran:\n")
        for linea in fallos:
            print(f"  {linea}")
        print(f"\n{len(fallos)} fallos.")
        return 1

    print(f"OK: {vistas} de 50 unidades, todas cuadran.")
    if faltan and not args.estricto:
        print(f"    Faltan {len(faltan)} (se escriben en M3.4-M3.8).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
