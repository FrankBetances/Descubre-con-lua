#!/usr/bin/env python3
"""El registro de frases: todo el inglés de la app que no es palabra del banco.

    python3 tools/xera_rexistro_frases.py           # escribe el registro y el inventario
    python3 tools/xera_rexistro_frases.py --check   # falla si algo no está al día

Módulo M3.2 del plan docente. El registro léxico de la arquitectura
(`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartado 6) tiene dos partes: el banco
TPR, que está cerrado (800 palabras por curso y los cuentos semanales que las
llevan), y este registro, para todo lo demás. Las unidades del mes citan una u
otra parte por id; no copian el inglés.

De dónde sale cada frase:

- `registro/frases_propias.json`: lo que no está en ningún otro sitio. Son las
  fórmulas de turno que el banco no trae y las estructuras de 4-6 años, y se
  escriben ahí a mano;
- las órdenes de las asambleas de los dos ciclos, con su gesto;
- las frases de las dinámicas de aula, de los juegos de casa, de STEAM y de la
  guía de atención por edad.

Una orden o una frase entra aunque su texto sea también palabra del banco:
*Up* en la asamblea de 0-2 es «eleva las manos del bebé», y *Up* en el banco
de 3-4 es la palabra con el gesto de 3-4. Lo que se lleva de su fuente es el
gesto. El mismo texto con el mismo estilo comparte grabación, así que no
cuesta audio nuevo. Lo que no entra todavía por otra razón (las palabras del calendario de 50 meses, que
solo lee ya el Planificador, hasta M7.3; la frase TPR de los cuentos, M5; las láminas, M7.2; la
asamblea vieja, M4.3) queda en el inventario con su destino:
`referencias/inventario_frases_ingles.md`.

Hasta M7.2 las fuentes siguen siendo la verdad y el registro se deriva de
ellas: si una orden cambia en su asamblea, cambia aquí al regenerar. El id de
cada frase sale del id de su fuente, así que es estable.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENIDO = ROOT / "assets" / "content"
PROPIAS = CONTENIDO / "registro" / "frases_propias.json"
SAIDA = CONTENIDO / "registro" / "frases.json"
INVENTARIO = ROOT / "referencias" / "inventario_frases_ingles.md"


def norm(texto: str) -> str:
    return re.sub(r"[^a-z' ]", "", texto.lower()).strip()


def banco() -> dict[str, str]:
    """Inglés normalizado del banco → su id."""
    ids: dict[str, str] = {}
    for fichero in sorted((CONTENIDO / "tpr").glob("curso_*/tpr.*.json")):
        for semana in json.loads(fichero.read_text(encoding="utf-8"))["semanas"]:
            for palabra in semana["palabras"]:
                ids.setdefault(norm(palabra["en"]), palabra["id"])
    return ids


def ler(ruta: Path):
    return json.loads(ruta.read_text(encoding="utf-8"))


def candidatas() -> list[dict]:
    """Cada frase de cada fuente que entra en el registro, en orden estable."""
    saida: list[dict] = []

    for ciclo in ("primeiro", "segundo"):
        for fichero in sorted(
                (CONTENIDO / f"asambleas_{ciclo}_ciclo").glob("*.json")):
            asamblea = ler(fichero)
            for fase in asamblea.get("fases", []):
                for orde in fase.get("comandosL3") or []:
                    saida.append({
                        "id": f"frase.{orde['id']}",
                        "tipo": "orde",
                        "en": orde["textoIngles"],
                        "accion": orde.get("accionFisica") or {},
                        "fonte": f"asambleas_{ciclo}_ciclo/{fichero.name}",
                    })

    for dinamica in ler(CONTENIDO / "dinamicas_aula.json"):
        tpr = dinamica.get("tprIngles") or {}
        saida.append({
            "id": f"frase.dinamica.{dinamica['clave']}",
            "tipo": "dinamica",
            "en": tpr.get("comando", ""),
            "accion": tpr.get("accion") or {},
            "fonte": "dinamicas_aula.json",
        })

    for xogo in ler(CONTENIDO / "xogos_fogar.json")["xogos"]:
        saida.append({
            "id": f"frase.xogo.{xogo['id']}",
            "tipo": "xogo",
            "en": xogo.get("fraseEn", ""),
            "accion": xogo.get("accionKinestesica") or {},
            "fonte": "xogos_fogar.json",
        })

    for unidade in ler(CONTENIDO / "steam" / "unidades_steam.json"):
        for i, orde in enumerate(unidade.get("ordenesIngles") or []):
            saida.append({
                "id": f"frase.steam.{unidade['id']}.{i + 1:02d}",
                "tipo": "steam",
                "en": orde.get("en", ""),
                "accion": orde.get("accion") or {},
                "fonte": "steam/unidades_steam.json",
            })

    for tramo in ler(CONTENIDO / "calendario" / "atencion.json")["tramos"]:
        saida.append({
            "id": f"frase.atencion.{tramo['id']}",
            "tipo": "atencion",
            "en": tramo.get("fraseIngles", ""),
            "accion": tramo.get("queFacer") or {},
            "fonte": "calendario/atencion.json",
        })

    return saida


def pendentes() -> list[tuple[str, int, str]]:
    """Lo que hoy tiene inglés propio y aún no entra en el registro."""
    calendario = ler(CONTENIDO / "calendario" / "curriculo_50_meses.json")
    contos = ler(CONTENIDO / "cuentos" / "banco100_cuentos.json")
    historias = ler(CONTENIDO / "cuentos" / "historias_progresivas.json")
    laminas = ler(CONTENIDO / "laminas" / "banco200_laminas.json")
    vellas = sorted((CONTENIDO / "unidades").glob("juega.*.json"))
    return [
        ("calendario/curriculo_50_meses.json (léxico, órdenes y frase del mes)",
         sum(len(m["ingles"]["lexico"]) + len(m["ingles"]["tpr"]) + 1
             for m in calendario),
         "Desde M3.9 el calendario lee la unidad; lo lee aún el Planificador, "
         "hasta M7.3"),
        ("cuentos: frase TPR de los cuentos y de las historias",
         len(contos) + len(historias),
         "M5: el cuento de la semana conserva su frase; el microcuento cita el registro"),
        ("laminas/banco200_laminas.json (palabra y acción)", 2 * len(laminas),
         "M7.2: las láminas pasan a citar el registro"),
        ("unidades/juega.* (asamblea de seis pasos)", len(vellas),
         "Se retira en M4.3"),
    ]


def construir() -> tuple[dict, list[str], str]:
    fallos: list[str] = []
    do_banco = banco()
    propias = ler(PROPIAS)["frases"]
    frases: list[dict] = []
    vistos: set[str] = set()
    no_banco = 0
    por_fonte: dict[str, list[int]] = {}

    for frase in propias:
        if norm(frase["en"]) in do_banco:
            fallos.append(f"frases_propias: «{frase['en']}» ya es "
                          f"{do_banco[norm(frase['en'])]} del banco: cítalo")
        frases.append(frase)

    for frase in candidatas():
        conta = por_fonte.setdefault(frase["fonte"].split("/")[0], [0, 0])
        conta[0] += 1
        if not frase["en"].strip():
            fallos.append(f"{frase['id']}: sin inglés")
            continue
        if norm(frase["en"]) in do_banco:
            conta[1] += 1
            no_banco += 1
        frases.append(frase)

    for frase in frases:
        if frase["id"] in vistos:
            fallos.append(f"{frase['id']}: id repetido")
        vistos.add(frase["id"])
        accion = frase.get("accion") or {}
        for lingua in ("gl", "es"):
            if not str(accion.get(lingua, "")).strip():
                fallos.append(f"{frase['id']}: sin acción en {lingua}")
        if frase.get("tipo") == "estructura":
            nota = frase.get("nota") or {}
            for lingua in ("gl", "es"):
                if not str(nota.get(lingua, "")).strip():
                    fallos.append(f"{frase['id']}: estructura sin nota en {lingua}")

    rexistro = {
        "_doc": "Generado por tools/xera_rexistro_frases.py; no se edita a mano. "
                "Las frases propias se escriben en registro/frases_propias.json.",
        "frases": frases,
    }

    filas = "\n".join(
        f"| `{fonte}` | {total} | {enBanco} | {total} |"
        for fonte, (total, enBanco) in sorted(por_fonte.items()))
    resto = "\n".join(f"| {nome} | {n} | {destino} |"
                      for nome, n, destino in pendentes())
    inventario = f"""# Inventario de las frases inglesas de la app

Generado por `tools/xera_rexistro_frases.py`; no se edita a mano. Módulo M3.2
del plan docente.

## Lo que entra en el registro de frases

`assets/content/registro/frases.json`: {len(frases)} frases, de ellas
{len(propias)} propias (`registro/frases_propias.json`). Una orden entra
aunque su texto sea también palabra del banco: se lleva el gesto de su fuente,
y comparte la grabación.

| Fuente | Frases | Mismo texto en el banco | En el registro |
| --- | --- | --- | --- |
{filas}
| `registro/frases_propias.json` | {len(propias)} | 0 | {len(propias)} |

## Lo que todavía no entra, y dónde se resuelve

| Fuente | Inglés que lleva | Destino |
| --- | --- | --- |
{resto}

Fuera del registro, a propósito: el corpus de 4.000 palabras de uso habitual y
las colocaciones son consulta de la persona adulta, no currículo.
"""
    return rexistro, fallos, inventario


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--check", action="store_true")
    args = parser.parse_args()

    rexistro, fallos, inventario = construir()
    texto = json.dumps(rexistro, ensure_ascii=False, indent=2) + "\n"

    if args.check:
        if not SAIDA.exists() or SAIDA.read_text(encoding="utf-8") != texto:
            fallos.append("registro/frases.json no está al día: corre "
                          "tools/xera_rexistro_frases.py")
        if (not INVENTARIO.exists()
                or INVENTARIO.read_text(encoding="utf-8") != inventario):
            fallos.append("referencias/inventario_frases_ingles.md no está al "
                          "día: corre tools/xera_rexistro_frases.py")
    if fallos:
        print("El registro de frases no cuadra:\n")
        for linea in fallos:
            print(f"  - {linea}")
        return 1

    if not args.check:
        SAIDA.write_text(texto, encoding="utf-8")
        INVENTARIO.write_text(inventario, encoding="utf-8")
        print(f"Escrito: {len(rexistro['frases'])} frases en el registro.")
    else:
        print(f"OK: registro de frases al día ({len(rexistro['frases'])} frases).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
