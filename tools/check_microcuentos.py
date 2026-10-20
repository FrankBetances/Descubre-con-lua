#!/usr/bin/env python3
"""El microcuento de cada unidad: lo que dice Lúa sale del núcleo, y nadie pide repetir.

    python3 tools/check_microcuentos.py              # lo que hay, y qué falta
    python3 tools/check_microcuentos.py --estricto   # además, exige los 40 dibujados

Módulo M5.1 del plan docente (`docs/PLAN_MEJORA_INTEGRAL.md`). El microcuento
vive dentro de su unidad del mes, en el campo `microcuento`
(`assets/content/unidades_mes/<curso>/unidade.NN.json`), desde 2-3 años: diez
por curso en 2-3, 3-4, 4-5 y 5-6. En 0-2 va a `null`. Lo que es cada parte
está en `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartados 5 y 7.

Comprueba, por microcuento:

- que el id es `microcuento.<curso>.NN`, y que título, trama y ayudas van en
  gallego Y en castellano;
- que tiene **3 láminas en 2-3 y 3-4 años, 4 en 4-5 y 5-6**, cada una con su
  encargo para quien la dibuja;
- que la **frase de Lúa** de cada lámina es un id del registro de frases de
  tipo `lua`, distinta en cada lámina, y que **solo usa palabras del núcleo**
  de su unidad (desde 4-5, también las descriptivas y la estructura), más un
  puñado cerrado de palabras de función (`FUNCION`). La onomatopeya va aparte;
- que la **tríada** son tres preguntas en inglés (señalar, imitar, acercar),
  cada una con su ayuda, y que la de acercar habla de la criatura (*you*,
  *your*);
- que el **guion de recast** cubre las cinco respuestas (silencio, señala,
  lengua de casa, una palabra, forma torcida), y que ante una palabra suelta
  devuelve una frase más larga;
- que la **pregunta de casa** es una por lámina y del tipo que toca por edad
  (apartado 8.2); en 5-6, una distinta en cada lámina;
- que ningún texto pide repetir ni traducir: ni *say* ni *repeat* en inglés, ni
  «repite» ni «¿cómo se dice?» en gallego o castellano;
- que la espera es de 3 a 5 segundos;
- que la lámina, si está puesta, existe en `assets/brand/laminas/`.

Sin `--estricto` faltar un microcuento o una lámina por dibujar no es fallo:
los textos se escriben curso a curso (M5.2-M5.5) y las láminas después (M5.6).
Con `--estricto` (M5.8) se exigen los 40 con todas sus láminas.
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
LAMINAS = ROOT / "assets" / "brand" / "laminas"

CURSOS = ["curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]
N_LAMINAS = {"curso_2_3": 3, "curso_3_4": 3, "curso_4_5": 4, "curso_5_6": 4}

# La pregunta de casa por edad (arquitectura, apartado 8.2).
CASA = {
    "curso_2_3": {"peer"},
    "curso_3_4": {"peer", "completar", "queOnde"},
    "curso_4_5": {"recordar", "abrir"},
    "curso_5_6": {"completar", "recordar", "abrir", "queOnde", "achegar"},
}

# Desde 4-5 la frase de Lúa puede usar también descriptivas y estructura.
CON_ESTRUCTURA = {"curso_4_5", "curso_5_6"}

# Lo único que la frase de Lúa puede decir fuera del núcleo: artículos,
# pronombres, el verbo ser y conectores. Ni preposiciones (in, on, under son
# la estructura de 4-5) ni verbos ni nombres.
FUNCION = {
    "a", "an", "the", "is", "are", "am", "it", "its", "it's", "i", "i'm",
    "you", "you're", "we", "me", "my", "your", "our", "and", "so", "too",
    "oh", "yes", "no", "now", "here", "there", "this", "that", "lúa", "lua",
}

PIDE_REPETIR_EN = re.compile(r"\b(say|repeat|can you say)\b", re.I)
PIDE_REPETIR = re.compile(
    r"rep[ií]te|rep[ií]teo|rep[ií]telo|c[oó]mo se di(ce)?\b|traduc", re.I)

PALABRA = re.compile(r"[a-záéíóúñ']+", re.I)


def palabras(texto: str) -> list[str]:
    return [p.lower().strip("'") for p in PALABRA.findall(texto)]


def raices(palabra: str) -> set[str]:
    """La palabra y lo que queda al quitarle el plural o el verbo conjugado."""
    p = palabra.lower()
    saida = {p}
    if p.endswith("'s"):
        saida.add(p[:-2])
    for sufixo in ("ing", "ed", "es", "s"):
        if p.endswith(sufixo) and len(p) > len(sufixo) + 2:
            base = p[: -len(sufixo)]
            saida |= {base, base + "e"}
            if len(base) > 2 and base[-1] == base[-2]:
                saida.add(base[:-1])
    return saida


def bilingue(valor, donde: str, fallos: list[str]) -> None:
    if not isinstance(valor, dict):
        fallos.append(f"{donde}: falta el texto en gl y es")
        return
    for lingua in ("gl", "es"):
        texto = str(valor.get(lingua, "")).strip()
        if not texto:
            fallos.append(f"{donde}: falta el texto en {lingua}")
        elif PIDE_REPETIR.search(texto):
            fallos.append(f"{donde} ({lingua}): pide repetir o traducir: "
                          f"«{texto}»")


def ingles(texto, donde: str, fallos: list[str]) -> str:
    texto = str(texto or "").strip()
    if not texto:
        fallos.append(f"{donde}: falta el inglés")
    elif PIDE_REPETIR_EN.search(texto):
        fallos.append(f"{donde}: pide repetir: «{texto}»")
    return texto


def ingles_do_rexistro() -> tuple[dict[str, dict], dict[str, str]]:
    """Las frases del registro por id, y el inglés de cada id del banco."""
    frases = {}
    if FRASES.exists():
        for f in json.loads(FRASES.read_text(encoding="utf-8"))["frases"]:
            frases[f["id"]] = f
    banco = {}
    for fichero in (CONTENIDO / "tpr").glob("curso_*/tpr.*.json"):
        for semana in json.loads(fichero.read_text(encoding="utf-8"))["semanas"]:
            for palabra in semana["palabras"]:
                banco[palabra["id"]] = palabra["en"]
    return frases, banco


def permitidas(curso: str, u: dict, frases: dict, banco: dict) -> set[str]:
    refs = [e.get("ref", "") for e in u.get("nucleo") or []]
    if curso in CON_ESTRUCTURA:
        refs += [e.get("ref", "") for e in u.get("descriptivas") or []]
        if isinstance(u.get("estructura"), dict):
            refs.append(u["estructura"].get("ref", ""))
    saida: set[str] = set()
    for ref in refs:
        en = frases[ref]["en"] if ref in frases else banco.get(ref, "")
        for p in palabras(en):
            saida |= raices(p)
    return saida


def revisar(curso: str, orden: int, u: dict, frases: dict, banco: dict,
            fallos: list[str], pendentes: list[str]) -> None:
    donde = f"{curso}/unidade.{orden:02d}"
    mc = u.get("microcuento")
    if not isinstance(mc, dict):
        fallos.append(f"{donde}: el microcuento no es un objeto")
        return
    if mc.get("id") != f"microcuento.{curso}.{orden:02d}":
        fallos.append(f"{donde}: el id debe ser microcuento.{curso}.{orden:02d}")
    bilingue(mc.get("titulo"), f"{donde} · título", fallos)
    espera = mc.get("esperaSegundos")
    if not isinstance(espera, int) or not 3 <= espera <= 5:
        fallos.append(f"{donde}: esperaSegundos debe ir de 3 a 5")

    laminas = mc.get("laminas") or []
    if len(laminas) != N_LAMINAS[curso]:
        fallos.append(f"{donde}: {len(laminas)} láminas; en este curso van "
                      f"{N_LAMINAS[curso]}")

    lexico = permitidas(curso, u, frases, banco)
    vistas_lua: set[str] = set()
    tipos_casa: list[str] = []
    for i, lamina in enumerate(laminas, start=1):
        aqui = f"{donde} · lámina {i}"
        if not str(lamina.get("encargo", "")).strip():
            fallos.append(f"{aqui}: falta el encargo para quien la dibuja")
        clave = lamina.get("lamina")
        if clave:
            if not (LAMINAS / f"{clave}.json").exists():
                fallos.append(f"{aqui}: la lámina «{clave}» no existe en "
                              "assets/brand/laminas/")
        else:
            pendentes.append(aqui)
        bilingue(lamina.get("trama"), f"{aqui} · trama", fallos)

        lua = lamina.get("lua") or {}
        ref = lua.get("ref", "")
        frase = frases.get(ref)
        if frase is None:
            fallos.append(f"{aqui}: la frase de Lúa «{ref}» no está en el "
                          "registro de frases")
        else:
            if frase.get("tipo") != "lua":
                fallos.append(f"{aqui}: «{ref}» no es una frase de Lúa")
            if ref in vistas_lua:
                fallos.append(f"{aqui}: Lúa repite la frase de otra lámina")
            vistas_lua.add(ref)
            fora = [p for p in palabras(frase["en"])
                    if p not in FUNCION and not (raices(p) & lexico)]
            if fora:
                fallos.append(f"{aqui}: Lúa dice «{frase['en']}», y "
                              f"{', '.join(fora)} no es del núcleo")
            ingles(frase["en"], f"{aqui} · frase de Lúa", fallos)
        if not str(lua.get("onomatopeia", "")).strip():
            fallos.append(f"{aqui}: la frase de Lúa no trae onomatopeya")

        triada = lamina.get("triada") or {}
        for parte in ("sinalar", "imitar", "achegar"):
            p = triada.get(parte) or {}
            en = ingles(p.get("en"), f"{aqui} · tríada · {parte}", fallos)
            bilingue(p.get("axuda"), f"{aqui} · tríada · {parte} · ayuda",
                     fallos)
            if parte == "achegar" and en and not re.search(
                    r"\b(you|your)\b", en, re.I):
                fallos.append(f"{aqui}: «{en}» no acerca la escena a la "
                              "criatura (ni you ni your)")

        recast = lamina.get("recast") or {}
        for parte in ("silencio", "sinala"):
            r = recast.get(parte) or {}
            ingles(r.get("en"), f"{aqui} · recast · {parte}", fallos)
            bilingue(r.get("axuda"), f"{aqui} · recast · {parte} · ayuda",
                     fallos)
        casa_l1 = recast.get("linguaCasa") or {}
        bilingue(casa_l1.get("di"), f"{aqui} · recast · lengua de casa · dice",
                 fallos)
        bilingue(casa_l1.get("acolle"),
                 f"{aqui} · recast · lengua de casa · acoge", fallos)
        ingles(casa_l1.get("en"), f"{aqui} · recast · lengua de casa", fallos)
        for parte in ("unhaPalabra", "formaTorcida"):
            r = recast.get(parte) or {}
            di = ingles(r.get("di"), f"{aqui} · recast · {parte} · dice",
                        fallos)
            en = ingles(r.get("en"), f"{aqui} · recast · {parte}", fallos)
            if di and en and di.lower().strip(" !.?") == en.lower().strip(" !.?"):
                fallos.append(f"{aqui} · recast · {parte}: devuelve lo mismo "
                              "que dijo")
            if parte == "unhaPalabra" and di and en and \
                    len(palabras(en)) <= len(palabras(di)):
                fallos.append(f"{aqui} · recast · una palabra: «{en}» no es "
                              f"más larga que «{di}»")

        casa = lamina.get("casa") or {}
        tipo = casa.get("tipo")
        if tipo not in CASA[curso]:
            fallos.append(f"{aqui}: pregunta de casa de tipo «{tipo}»; en este "
                          f"curso van {', '.join(sorted(CASA[curso]))}")
        tipos_casa.append(tipo)
        ingles(casa.get("en"), f"{aqui} · pregunta de casa", fallos)
        bilingue(casa.get("axuda"), f"{aqui} · pregunta de casa · ayuda",
                 fallos)

    if curso == "curso_5_6" and len(set(tipos_casa)) != len(tipos_casa):
        fallos.append(f"{donde}: en 5-6 cada lámina lleva un tipo de pregunta "
                      "de casa distinto")


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--estricto", action="store_true",
                        help="exige los 40, con todas sus láminas dibujadas")
    args = parser.parse_args()

    frases, banco = ingles_do_rexistro()
    fallos: list[str] = []
    faltan: list[str] = []
    pendentes: list[str] = []
    vistos = 0

    for fichero in sorted((UNIDADES / "curso_0_2").glob("unidade.*.json")):
        u = json.loads(fichero.read_text(encoding="utf-8"))
        if u.get("microcuento") is not None:
            fallos.append(f"curso_0_2/{fichero.name}: en 0-2 no hay "
                          "microcuento (desde 2 años)")

    for curso in CURSOS:
        for orden in range(1, 11):
            fichero = UNIDADES / curso / f"unidade.{orden:02d}.json"
            if not fichero.exists():
                faltan.append(f"{curso} · {orden:02d} (sin unidad)")
                continue
            u = json.loads(fichero.read_text(encoding="utf-8"))
            if u.get("microcuento") is None:
                faltan.append(f"{curso} · {orden:02d}")
                continue
            revisar(curso, orden, u, frases, banco, fallos, pendentes)
            vistos += 1

    if args.estricto:
        fallos.extend(f"falta el microcuento de {m}" for m in faltan)
        fallos.extend(f"{p}: sin lámina dibujada" for p in pendentes)

    if fallos:
        print("Los microcuentos no cuadran:\n")
        for linea in fallos:
            print(f"  {linea}")
        print(f"\n{len(fallos)} fallos.")
        return 1

    print(f"OK: {vistos} de 40 microcuentos, todos cuadran.")
    if not args.estricto:
        if faltan:
            print(f"    Faltan {len(faltan)} (se escriben en M5.2-M5.5).")
        if pendentes:
            print(f"    {len(pendentes)} láminas por dibujar (M5.6).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
