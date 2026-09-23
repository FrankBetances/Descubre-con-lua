#!/usr/bin/env python3
"""El inglés del curso: cinco palabras nuevas al día, leídas del contenido.

    python3 tools/planificador_5_palabras.py           # el curso en números
    python3 tools/planificador_5_palabras.py 10 1      # la semana 1 de octubre, día a día
    python3 tools/planificador_5_palabras.py --check   # gate: el curso cumple el modelo

Antes este script multiplicaba 5 × 4 × 4 × 10 y enseñaba «800» con veinte
palabras de muestra escritas en él: daba el número bueno aunque el curso no lo
tuviera. Ahora cuenta lo que hay en `assets/content/tpr/`, que es lo que viaja
en la app, y con --check falla si no es el modelo.

El modelo (documento «Modelo de Adquisición Natural y Proyección Anual»):
de lunes a jueves, cinco palabras nuevas al día en bloques A, B, C y D, con
repaso acumulativo; el viernes, ninguna nueva y reto con las veinte. Veinte por
semana, cuatro semanas por mes, diez meses: 800. Reparto 35/25/20/12/8 %.
"""
import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
TPR = RAIZ / "assets" / "content" / "tpr"
MODELO = TPR / "modelo.json"

PALABRAS_POR_DIA = 5
DIAS_CON_NOVAS = 4
BLOQUES = ["A", "B", "C", "D"]
SEMANAS_POR_MES = 4
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]

# El reparto del documento del modelo. Es una decisión del programa, no una
# norma del CDI ni de la LDS: el orden de las categorías se inspira en el
# vocabulario temprano que describen, los porcentajes no salen de ellos.
REPARTO = {"noun": 35, "verb": 25, "adjective": 20, "phrase": 12, "complex": 8}

# La lista del linter del documento de arquitectura (`content_linter.py`).
PROHIBIDAS = {
    "sick", "disease", "syndrome", "trauma", "disorder", "infection",
    "fever", "pain", "hospital", "doctor", "medicine", "pill",
    "scared", "fear", "danger", "stranger", "bad", "ugly", "kill",
    "dead", "die", "punish", "sad", "depressed", "anxiety", "clinic",
}

NOMES_DIAS = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes"]


def plan_da_semana(palabras: list) -> list:
    """Los cinco días de una semana de veinte: el mismo algoritmo que la app."""
    if len(palabras) != PALABRAS_POR_DIA * DIAS_CON_NOVAS:
        raise ValueError(f"Una semana son 20 palabras; llegaron {len(palabras)}.")
    dias = []
    for i, bloque in enumerate(BLOQUES):
        dias.append({
            "dia": i + 1,
            "bloque": bloque,
            "nuevas": palabras[i * PALABRAS_POR_DIA:(i + 1) * PALABRAS_POR_DIA],
            "repaso": palabras[:i * PALABRAS_POR_DIA],
        })
    dias.append({"dia": 5, "bloque": "", "nuevas": [], "repaso": list(palabras)})
    return dias


def leer_curso():
    modelo = json.loads(MODELO.read_text(encoding="utf-8"))
    meses = []
    for ruta in modelo.get("meses", []):
        meses.append(json.loads((RAIZ / ruta).read_text(encoding="utf-8")))
    return modelo, meses


def _clave(en: str) -> str:
    return " ".join(re.sub(r"[^a-z0-9]+", " ", en.lower()).split())


def _texto(valor) -> bool:
    return isinstance(valor, str) and valor.strip() != ""


def _bilingue(valor) -> bool:
    return isinstance(valor, dict) and _texto(valor.get("gl")) and _texto(valor.get("es"))


def comprobar() -> list:
    """Todo lo que no cumple el modelo, en frases. Vacío si todo está bien."""
    fallos = []
    try:
        modelo, meses = leer_curso()
    except (OSError, json.JSONDecodeError) as e:
        return [f"No se puede leer el curso: {e}"]

    if modelo.get("ritmoDiario") != PALABRAS_POR_DIA:
        fallos.append(f"modelo.json: ritmoDiario es {modelo.get('ritmoDiario')}, no {PALABRAS_POR_DIA}.")
    en_disco = {f"assets/content/tpr/{p.name}" for p in TPR.glob("tpr.*.json")}
    declarados = set(modelo.get("meses", []))
    for sobra in sorted(en_disco - declarados):
        fallos.append(f"{sobra} está en disco pero no en modelo.json: la app no lo lee.")
    for falta in sorted(declarados - en_disco):
        fallos.append(f"modelo.json declara {falta}, que no existe.")
    dias = modelo.get("dias", [])
    if [d.get("bloque") for d in dias] != BLOQUES + [""]:
        fallos.append("modelo.json: los días no son A, B, C, D y el reto del viernes.")
    for d in dias:
        for campo in ("dinamica", "dinamicaFogar"):
            if not _bilingue(d.get(campo)):
                fallos.append(f"modelo.json: al día {d.get('dia')} le falta {campo} en gl o es.")
    if [c.get("clave") for c in modelo.get("categorias", [])] != list(REPARTO):
        fallos.append(f"modelo.json: las categorías no son {list(REPARTO)}.")
    for c in modelo.get("categorias", []):
        if not (_bilingue(c.get("nome")) and _bilingue(c.get("descricion"))):
            fallos.append(f"modelo.json: a la categoría {c.get('clave')} le falta texto en gl o es.")
    if not _bilingue(modelo.get("fontes")):
        fallos.append("modelo.json: falta la nota de fuentes en gl o es.")

    if sorted(m.get("mesCalendario") for m in meses) != sorted(MESES):
        fallos.append(f"Los meses del curso no son {MESES}.")
    ids, vistas, cuenta, total = set(), {}, {}, 0
    for m in meses:
        mes = m.get("mesCalendario")
        orden_bueno = MESES.index(mes) + 1 if mes in MESES else None
        if m.get("orden") != orden_bueno:
            fallos.append(f"Mes {mes}: el orden {m.get('orden')} no es el del curso.")
        semanas = m.get("semanas", [])
        if [s.get("semana") for s in semanas] != list(range(1, SEMANAS_POR_MES + 1)):
            fallos.append(f"Mes {mes}: las semanas no son 1, 2, 3 y 4.")
        for s in semanas:
            donde = f"mes {mes}, semana {s.get('semana')}"
            if not _bilingue(s.get("tema")):
                fallos.append(f"{donde}: falta el tema en gl o es.")
            palabras = s.get("palabras", [])
            if len(palabras) != PALABRAS_POR_DIA * DIAS_CON_NOVAS:
                fallos.append(f"{donde}: {len(palabras)} palabras, no 20.")
            for p in palabras:
                total += 1
                en = p.get("en", "")
                if p.get("id") in ids:
                    fallos.append(f"{donde}: el id {p.get('id')} está repetido.")
                ids.add(p.get("id"))
                if not (_texto(en) and _texto(p.get("gl")) and _texto(p.get("es"))):
                    fallos.append(f"{donde}: «{en}» no tiene inglés, gallego y castellano.")
                if not _bilingue(p.get("tprAction")):
                    fallos.append(f"{donde}: «{en}» no tiene gesto en gl y es.")
                categoria = p.get("category")
                if categoria not in REPARTO:
                    fallos.append(f"{donde}: «{en}» tiene la categoría {categoria!r}.")
                cuenta[categoria] = cuenta.get(categoria, 0) + 1
                clave = _clave(en)
                if clave in vistas:
                    fallos.append(f"{donde}: «{en}» ya era nueva en {vistas[clave]}.")
                vistas[clave] = donde
                malas = set(re.findall(r"\b[a-z]+\b", en.lower())) & PROHIBIDAS
                if malas:
                    fallos.append(f"{donde}: «{en}» lleva {sorted(malas)}, que la lista excluye.")

    esperado = PALABRAS_POR_DIA * DIAS_CON_NOVAS * SEMANAS_POR_MES * len(MESES)
    if total != esperado:
        fallos.append(f"El curso tiene {total} palabras, no {esperado}.")
    for categoria, porcentaje in REPARTO.items():
        quiere = esperado * porcentaje // 100
        if cuenta.get(categoria, 0) != quiere:
            fallos.append(f"{categoria}: {cuenta.get(categoria, 0)} palabras, no {quiere} ({porcentaje} %).")
    return fallos


def resumen() -> None:
    modelo, meses = leer_curso()
    total = sum(len(s["palabras"]) for m in meses for s in m["semanas"])
    print(f"Curso: {len(meses)} meses, {total} palabras nuevas "
          f"({modelo['ritmoDiario']} al día de lunes a jueves).")
    cuenta = {}
    for m in meses:
        for s in m["semanas"]:
            for p in s["palabras"]:
                cuenta[p["category"]] = cuenta.get(p["category"], 0) + 1
    for c in modelo["categorias"]:
        n = cuenta.get(c["clave"], 0)
        print(f"  {c['nome']['es']}: {n} ({round(100 * n / total) if total else 0} %)")


def semana(mes: int, numero: int) -> int:
    _, meses = leer_curso()
    for m in meses:
        if m["mesCalendario"] != mes:
            continue
        for s in m["semanas"]:
            if s["semana"] != numero:
                continue
            print(f"Mes {mes}, semana {numero}: {s['tema']['es']}")
            for d in plan_da_semana(s["palabras"]):
                nuevas = ", ".join(p["en"] for p in d["nuevas"]) or "—"
                print(f"  {NOMES_DIAS[d['dia'] - 1]:<10} {d['bloque'] or 'reto':<4} "
                      f"nuevas: {nuevas} · repaso: {len(d['repaso'])}")
            return 0
    print(f"No hay semana {numero} en el mes {mes}.")
    return 1


def main(argv: list) -> int:
    if argv[:1] == ["--check"]:
        fallos = comprobar()
        for f in fallos:
            print(f"FALLO: {f}")
        if fallos:
            return 1
        print("El curso de inglés cumple el modelo: 800 palabras, 20 por semana, "
              "reparto 280/200/160/96/64.")
        return 0
    if len(argv) == 2:
        return semana(int(argv[0]), int(argv[1]))
    resumen()
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
