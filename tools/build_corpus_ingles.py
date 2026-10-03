#!/usr/bin/env python3
"""Escribe el vocabulario inglés de la app: las 4.000 de uso habitual.

Cuántas y por qué esas. Frank: «solo deja las 4.000 palabras que usan de forma
habitual». La lista de origen trae 7.998 ordenadas por frecuencia en bandas de
mil, así que «las que se usan de forma habitual» son las CUATRO PRIMERAS
BANDAS: 1k, 2k, 3k y 4k. Las 3.998 de la 5k a la 8k no entran ni en el fichero
ni en la app ni en el corpus de voz. Y doce palabras más quedan fuera por otra
razón, la de FORA: son insultos o anatomía sexual y Frank pidió quitarlas.

De dónde sale cada campo, y esto es lo que importa:

  · `pos`, `definicion` y `frase`  de `tools/datos/vocabulario_ingles.tsv`,
                   escritas A MANO para esta app, una por una, para las 3.995.
                   La definición, en el inglés con que se le explica una
                   palabra a quien aprende; la frase, una oración entera,
                   natural, que usa la palabra en su sentido más común y que
                   se puede oír e imitar en casa o en el aula.
  · `zipf`         wordfreq, que mide frecuencia real sobre corpus reales. Las
                   palabras para las que wordfreq da cero se quedan sin número.
  · `onomatopeya`  Lista explícita de ONOMATOPEIAS: se escribe y se ve.
  · `nivel_cefr`   Sale de la banda de frecuencia. Es ORIENTATIVO: no es una
                   clasificación del MCER y la pantalla lo dice.

Por qué a mano. Hasta octubre de 2026 la definición y la frase salían de
WordNet: un ejemplo suyo si pasaba cuatro filtros y, si no, una oración hecha
con la definición —«Above means at an earlier place.», «A flower is a plant
cultivated for its blooms or blossoms.»—. Frank encontró «flower» mal en la
app y pidió revisar las demás: la mitad de las frases eran definiciones
disfrazadas de oración, y muchas glosas, de un sentido que nadie usa con una
criatura. Ahora las escribe una persona y las comprueba el gate.

    python3 tools/build_corpus_ingles.py           # escribe el JSON
    python3 tools/build_corpus_ingles.py --check   # solo comprueba (el gate)

Para ESCRIBIR hace falta `wordfreq`. Para `--check` no hace falta nada: el
gate mira el fichero entregado y su fuente, no los reconstruye.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BANDAS = ROOT / "assets" / "content" / "corpus" / "bnc_coca_8000.json"
DESTINO = (ROOT / "assets" / "content" / "corpus"
           / "ingles_4000_uso_habitual.json")
# La fuente vive en tools/ y no en assets/: todo lo que hay en
# assets/content/corpus/ se empaqueta en el APK, y esto no lo lee la app.
FUENTE = ROOT / "tools" / "datos" / "vocabulario_ingles.tsv"

# Las que entran. La lista de origen ordena por frecuencia en bandas de mil:
# estas cuatro son las 4.000 que se usan de verdad.
BANDAS_QUE_ENTRAN = {"1k", "2k", "3k", "4k"}

# Las que NO entran, las pida quien las pida. Son palabras de una lista de
# frecuencia del inglés y por eso estaban; en una app de escuela infantil no
# pintan nada, y menos grabadas y sonando. Frank: «quita de la app las doce
# palabras que son insultos o anatomía sexual».
FORA = {
    "ass", "bastard", "breast", "damn", "goddam", "nigger", "penis", "queer",
    "rape", "sex", "vagina", "whore",
}

# El nivel es ORIENTATIVO y sale de la banda de frecuencia, en bloques de mil.
# No es una clasificación del MCER y la pantalla lo dice con esas palabras.
NIVEL_POR_BANDA = {
    "1k": "A1/A2",
    "2k": "A2/B1",
    "3k": "B1/B2",
    "4k": "B2",
    "5k": "B2",
    "6k": "C1",
    "7k": "C1",
    "8k": "C1+",
}

# Las onomatopeyas. Ningún diccionario las marca y no hay regla que las
# deduzca: son las palabras que imitan un sonido, y en una app de linguaxe
# temperá son la puerta de entrada —antes de nombrar la lluvia, se dice «drip,
# drip».
ONOMATOPEIAS = {
    "bang", "beep", "boom", "buzz", "chirp", "clap", "click", "crack",
    "crash", "creak", "crunch", "drip", "flap", "giggle", "growl", "gurgle",
    "hiss", "hum", "knock", "moo", "munch", "pop", "purr", "rattle", "ring",
    "roar", "rumble", "rustle", "scream", "shout", "sizzle", "slam", "smack",
    "snap", "sniff", "splash", "squeak", "squeal", "swish", "tap", "thud",
    "thump", "tick", "tinkle", "whack", "whisper", "whistle", "yawn", "yell",
    "zoom",
}

# Largo máximo de la frase y de la definición. La frase existe para OÍRSE en
# una escuela infantil y para imitarse: pasado este largo deja de ser un
# modelo repetible y se convierte en un párrafo.
MAX_FRASE = 80
MAX_DEFINICION = 80

# Lo que NO se lleva a una asamblea de cero a seis años, ni en la frase ni en
# la definición. La palabra del corpus se queda —es una lista de frecuencia del
# inglés— y puede ser ella misma una de estas: entonces es lo ÚNICO de la lista
# que puede aparecer en su frase y en su definición.
VETO = {
    "abortion", "alcohol", "alcoholic", "ammunition", "arrest", "arrested",
    "assault", "bastard", "beer", "bitch", "blood", "bloody", "bomb", "bombed",
    "bullet", "cancer", "cigarette", "cocaine", "condom", "corpse", "crime",
    "criminal", "dead", "death", "died", "drown", "drowned", "drug", "drugs",
    "drunk", "execution", "gun", "guns", "hang", "hanged", "heroin", "hell",
    "homicide", "jail", "killed", "killing", "kills", "murder", "murdered",
    "naked", "nazi", "penis", "pistol", "poison", "porn", "prison", "prostitute",
    "rape", "raped", "rifle", "sex", "sexual", "sexually", "shot", "slave",
    "slaughter", "smoking", "stab", "stabbed", "suicide", "terrorist", "tobacco",
    "torture", "vagina", "victim", "violence", "violent", "war", "weapon",
    "whiskey", "whore", "wine", "wound", "wounded",
    # Estas se añadieron después de LEER las frases que salían, una por una,
    # en la pantalla: «Please don't advertise the fact that he has AIDS», «He
    # was a child born of adultery», «He joined the Communist Party», «Muslim
    # women hide their faces», «the plot to kill the president». Ninguna es
    # para una escuela infantil de Vigo, y las cinco pasaban el filtro.
    "aids", "hiv", "adultery", "adulterous", "martyr", "martyrs", "dogma",
    "muslim", "muslims", "jew", "jews", "jewish", "communist", "kill",
    "thief", "terror", "terrorism", "gossip",
    # Y estas salieron de buscar «sex» en la pantalla ya montada: la palabra
    # que Frank mandó quitar ya no estaba, pero seguía saliendo en la
    # definición de otras. «Naughty» se enseñaba como «suggestive of sexual
    # impropriety» en vez de «badly behaved».
    "impropriety", "sexuality", "homosexuality", "intercourse", "erotic",
    "obscene", "lewd", "seduce", "seduction", "genital", "genitals",
}

POS_VALIDAS = {
    "NOUN", "VERB", "ADJ", "ADV", "ADP", "AUX", "PRON", "DET", "NUM",
    "CCONJ", "SCONJ", "INTJ", "X",
}


def _tokens(texto: str) -> list[str]:
    return re.findall(r"[A-Za-z']+", texto.lower())


def _vetadas(texto: str, lema: str) -> list[str]:
    """Las palabras de VETO que hay en el texto, menos la propia palabra."""
    return sorted({t for t in _tokens(texto) if t in VETO and t != lema.lower()})


def _definicion_disfrazada(frase: str, lema: str) -> bool:
    """¿Es la frase una definición con forma de oración?

    Es lo que se quitó: «A flower is a plant…», «To run is to…», «Something
    absurd is…», «Above means…». Eso no enseña a usar la palabra.
    """
    l = re.escape(lema)
    return bool(re.match(
        rf"^(an? {l} is |to {l} is to |something {l} is |{l} means )",
        frase, re.I))


def leer_fuente() -> dict[int, dict[str, str]]:
    """La fuente escrita a mano, por `id_global`."""
    filas: dict[int, dict[str, str]] = {}
    cabeceira: list[str] = []
    for linea in FUENTE.read_text(encoding="utf-8").splitlines():
        if not linea.strip() or linea.startswith("#"):
            continue
        campos = linea.split("\t")
        if not cabeceira:
            cabeceira = campos
            continue
        fila = dict(zip(cabeceira, campos))
        filas[int(fila["id_global"])] = fila
    return filas


def construir() -> list[dict]:
    from wordfreq import zipf_frequency

    bandas = json.loads(BANDAS.read_text(encoding="utf-8"))
    fuente = leer_fuente()
    saida = []

    for i, entrada in enumerate(bandas, start=1):
        palabra = str(entrada.get("word", "")).strip()
        if not palabra:
            continue
        banda = str(entrada.get("band", "1k")).strip()
        if banda not in BANDAS_QUE_ENTRAN:
            continue
        if palabra.lower() in FORA:
            continue

        fila = fuente.get(i)
        if fila is None or fila["lemma"] != palabra:
            raise SystemExit(
                f"A fonte non trae «{palabra}» (#{i}): escríbea en "
                f"{FUENTE.relative_to(ROOT)}.")

        item = {
            "id_global": i,
            "lemma": palabra,
            "banda_frecuencia": banda,
            "nivel_cefr": NIVEL_POR_BANDA.get(banda, "C1+"),
            "pos": fila["pos"],
        }
        zipf = zipf_frequency(palabra, "en")
        if zipf > 0:
            item["zipf"] = round(zipf, 2)
        item["definicion"] = fila["definicion"]
        item["frase"] = fila["frase"]
        if palabra.lower() in ONOMATOPEIAS:
            item["onomatopeya"] = True
        saida.append(item)

    return saida


# --------------------------------------------------------------- comprobación
def comprobar() -> int:
    """El gate. NO reconstruye: mira el fichero que viaja en el repositorio.

    Comprueba que estén todas las de las cuatro bandas, que el JSON diga lo
    mismo que la fuente escrita a mano —si alguien edita una frase en el JSON
    y no en la fuente, la próxima vez que se escriba se pierde—, y que cada
    definición y cada frase cumplan lo que se pide: la frase contiene la
    palabra, empieza en mayúscula y termina en punto, cabe en 80 caracteres, no
    es una definición disfrazada, no se repite y no trae nada de VETO.
    """
    for f in (DESTINO, FUENTE):
        if not f.exists():
            print(f"Falta {f.relative_to(ROOT)}.")
            return 1

    datos = json.loads(DESTINO.read_text(encoding="utf-8"))
    bandas = json.loads(BANDAS.read_text(encoding="utf-8"))
    fuente = leer_fuente()
    fallos = []

    esperadas = sum(1 for e in bandas
                    if str(e.get("band", "")).strip() in BANDAS_QUE_ENTRAN
                    and str(e.get("word", "")).strip().lower() not in FORA)
    if len(datos) != esperadas:
        fallos.append(
            f"o vocabulario ten {len(datos)} palabras e deberían ser {esperadas}")
    if len(fuente) != esperadas:
        fallos.append(
            f"a fonte escrita a man ten {len(fuente)} palabras e deberían ser "
            f"{esperadas}")

    frases: dict[str, str] = {}
    for d in datos:
        lemma = str(d.get("lemma", ""))
        if not lemma:
            fallos.append(f"#{d.get('id_global')} sen lemma")
            continue
        if str(d.get("banda_frecuencia", "")) not in BANDAS_QUE_ENTRAN:
            fallos.append(f"«{lemma}» está fóra das bandas 1k-4k")
        if lemma.lower() in FORA:
            fallos.append(f"«{lemma}» é unha das que Frank mandou quitar")
        esperado = NIVEL_POR_BANDA.get(d.get("banda_frecuencia", ""), "C1+")
        if d.get("nivel_cefr") != esperado:
            fallos.append(f"«{lemma}» ten un nivel que non sae da súa banda")

        fila = fuente.get(d.get("id_global"))
        if fila is None or fila.get("lemma") != lemma:
            fallos.append(f"«{lemma}» non está na fonte escrita a man")
            continue
        for campo in ("pos", "definicion", "frase"):
            if d.get(campo) != fila.get(campo):
                fallos.append(
                    f"«{lemma}»: o {campo} do JSON non é o da fonte "
                    f"(corre tools/build_corpus_ingles.py)")

        pos = d.get("pos")
        definicion = str(d.get("definicion", ""))
        frase = str(d.get("frase", ""))
        if pos not in POS_VALIDAS:
            fallos.append(f"«{lemma}» sen categoría gramatical válida")
        if not definicion or len(definicion) > MAX_DEFINICION:
            fallos.append(f"«{lemma}»: definición baleira ou de máis de "
                          f"{MAX_DEFINICION} caracteres")
        if not frase:
            fallos.append(f"«{lemma}» sen frase")
            continue
        if lemma.lower() not in frase.lower():
            fallos.append(f"a frase de «{lemma}» non contén a palabra: {frase}")
        if not frase[0].isupper() or frase[-1] not in ".!?":
            fallos.append(f"a frase de «{lemma}» non empeza en maiúscula ou "
                          f"non remata en punto: {frase}")
        if len(frase) > MAX_FRASE:
            fallos.append(f"a frase de «{lemma}» pasa de {MAX_FRASE} "
                          f"caracteres: {frase}")
        if _definicion_disfrazada(frase, lemma):
            fallos.append(f"a frase de «{lemma}» é unha definición: {frase}")
        vetadas = _vetadas(f"{definicion} {frase}", lemma)
        if vetadas:
            fallos.append(f"«{lemma}» leva {', '.join(vetadas)}: {frase}")
        clave = frase.lower()
        if clave in frases:
            fallos.append(f"«{lemma}» repite a frase de «{frases[clave]}»")
        frases[clave] = lemma

    if fallos:
        print(f"O vocabulario inglés ten {len(fallos)} problemas. Os dez primeiros:")
        for f in fallos[:10]:
            print("  ·", f)
        return 1

    onoma = sum(1 for d in datos if d.get("onomatopeya"))
    con_zipf = sum(1 for d in datos if d.get("zipf"))
    print(
        f"OK: {len(datos)} palabras, todas con categoría, definición e frase "
        f"escritas a man · {con_zipf} con frecuencia real · {onoma} "
        f"onomatopeias."
    )
    return 0


def main() -> int:
    if "--check" in sys.argv:
        return comprobar()

    datos = construir()
    texto = json.dumps(datos, ensure_ascii=False, separators=(",", ":")) + "\n"
    DESTINO.write_text(texto, encoding="utf-8")

    con_zipf = sum(1 for d in datos if d.get("zipf"))
    onoma = sum(1 for d in datos if d.get("onomatopeya"))
    print(
        f"OK: {len(datos)} palabras escritas desde "
        f"{FUENTE.relative_to(ROOT)} · {con_zipf} con frecuencia real · "
        f"{onoma} onomatopeias."
    )
    return comprobar()


if __name__ == "__main__":
    raise SystemExit(main())
