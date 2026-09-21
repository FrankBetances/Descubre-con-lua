#!/usr/bin/env python3
"""Escribe el vocabulario inglés de la app: las 4.000 de uso habitual.

Cuántas y por qué esas. Frank: «solo deja las 4.000 palabras que usan de forma
habitual». La lista de origen trae 7.998 ordenadas por frecuencia en bandas de
mil, así que «las que se usan de forma habitual» son las CUATRO PRIMERAS
BANDAS: 1k, 2k, 3k y 4k. Las 3.998 de la 5k a la 8k no entran ni en el fichero
ni en la app ni en el corpus de voz. Y doce palabras más quedan fuera por otra
razón, la de FORA: son insultos o anatomía sexual y Frank pidió quitarlas.

Por qué existe. El corpus llegó del proyecto de origen con tres campos
inventados: `pos` decía «NOUN» en 6.206 de las 8.000 —«able», «across» y
«accept» entre ellas—, `zipf_score` resultó ser una función del ORDEN
ALFABÉTICO dentro de la banda, y el nivel CEFR era la banda renombrada. Se
quitaron, porque un dato inventado presentado como dato es peor que ningún
dato. Pero sin categoría gramatical no hay sustantivos, verbos ni adverbios que
distinguir, y sin frase no hay nada que escuchar ni que imitar.

De dónde sale ahora cada campo, y esto es lo que importa:

  · `pos`          WordNet 3.0 (Princeton), pero NO por el orden en que
                   WordNet devuelve los sentidos —ese orden pone los nombres
                   primero y por eso 5.826 palabras salían «NOUN»—, sino por
                   la cuenta real del corpus etiquetado SemCor: gana la
                   categoría con la que esa palabra más se usa. Quedan 4.188
                   nombres, 2.269 verbos, 1.319 adjetivos, 151 adverbios y 71
                   de clase cerrada. Las 89 de `FUNCIONAIS` van a mano: 73 que
                   WordNet no recoge —«and», «of», «should»— y 16 que sí
                   recoge, pero como otra cosa («he» es el helio, «who» la
                   OMS, «at» el astato).
  · `zipf`         wordfreq, que mide frecuencia real sobre corpus reales. Es
                   el dato que el fichero fingía tener. 7.993 de 7.998; las
                   cinco que faltan son tan raras que wordfreq da cero, y
                   entonces no se les pone número.
  · `frase`        Una oración ENTERA para cada palabra, las 7.998. Primero,
                   un ejemplo real de WordNet que use la palabra (3.457), y
                   solo si cumple cuatro condiciones: que sea de la misma
                   categoría gramatical que se enseña, que sea una oración con
                   verbo en forma personal —no un sintagma como «a card
                   shark»—, que quepa en 80 caracteres y que no traiga nada de
                   VETO. Si no lo hay, la frase se construye con la definición
                   de WordNet (4.452), que también es contenido real y además
                   dice qué significa. Las 89 funcionales traen la suya
                   escrita a mano.
  · `definicion`   La glosa del sentido MÁS USADO de esa categoría, recortada
                   por el primer punto y coma y sin cortar palabras.
  · `onomatopeya`  Lista explícita de ONOMATOPEIAS. WordNet no marca esto y no
                   se puede deducir: se escribe y se ve.

Nada de esto se inventa aquí. Si una palabra no tiene dato, no se le pone uno.

    python3 tools/build_corpus_ingles.py           # escribe
    python3 tools/build_corpus_ingles.py --check   # solo comprueba que está al día

Para ESCRIBIR hace falta `wordfreq` y `nltk` con tres paquetes: `wordnet`,
`averaged_perceptron_tagger_eng` y `punkt_tab`. Para `--check` no hace falta
nada: el gate mira el fichero entregado, no lo reconstruye, porque exigirle a
CI una descarga a los servidores de nltk en cada corrida es un gate que se
rompe solo. Ninguna de las dos cosas corre en la compilación de la app: esto
produce un fichero de contenido que SÍ viaja en el repositorio.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BANDAS = ROOT / "assets" / "content" / "corpus" / "bnc_coca_8000.json"
DESTINO = (ROOT / "assets" / "content" / "corpus"
           / "ingles_4000_uso_habitual.json")

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

POS_WORDNET = {"n": "NOUN", "v": "VERB", "a": "ADJ", "s": "ADJ", "r": "ADV"}

# Las onomatopeyas. WordNet no las marca y no hay regla que las deduzca: son
# las palabras que imitan un sonido, y en una app de linguaxe temperá son la
# puerta de entrada —antes de nombrar la lluvia, se dice «drip, drip».
ONOMATOPEIAS = {
    "bang", "beep", "boom", "buzz", "chirp", "clap", "click", "crack",
    "crash", "creak", "crunch", "drip", "flap", "giggle", "growl", "gurgle",
    "hiss", "hum", "knock", "moo", "munch", "pop", "purr", "rattle", "ring",
    "roar", "rumble", "rustle", "scream", "shout", "sizzle", "slam", "smack",
    "snap", "sniff", "splash", "squeak", "squeal", "swish", "tap", "thud",
    "thump", "tick", "tinkle", "whack", "whisper", "whistle", "yawn", "yell",
    "zoom",
}

# Las 73 de clase cerrada, que WordNet no recoge. POS y frase escritas a mano:
# son pocas, son las más frecuentes del inglés y merecen una frase de verdad.
FUNCIONAIS: dict[str, tuple[str, str]] = {
    # Las que WordNet SÍ tiene, pero como otra cosa. Se vieron abriendo la app:
    # «a» salía de sustantivo con «a typical household circuit carries 15 to 50
    # amps» —el amperio—, «he» era el helio, «it» la informática, «who» la
    # Organización Mundial de la Salud y «at» el astato. La palabra más
    # frecuente del inglés no puede entrar en la app definida como una unidad
    # eléctrica, así que estas se escriben a mano como las otras.
    "a": ("DET", "She is reading a story to the class."),
    "an": ("DET", "He is eating an apple."),
    "i": ("PRON", "I can see you."),
    "he": ("PRON", "He is putting on his coat."),
    "it": ("PRON", "It is raining again."),
    "at": ("ADP", "We meet at the door every morning."),
    "or": ("CCONJ", "Do you want the red one or the blue one?"),
    "who": ("PRON", "Who is sitting next to you?"),
    "why": ("ADV", "Why are you laughing?"),
    "can": ("AUX", "You can do it by yourself."),
    "may": ("AUX", "May I sit here with you?"),
    "might": ("AUX", "It might rain this afternoon."),
    "must": ("AUX", "We must wash our hands first."),
    "will": ("AUX", "I will read it again tomorrow."),
    "have": ("VERB", "We have a story every morning."),
    "in": ("ADP", "The blocks are in the box."),
    "three": ("NUM", "She is holding three crayons."),
    "against": ("ADP", "The ladder is leaning against the wall."),
    "although": ("SCONJ", "Although it was raining, we went outside."),
    "among": ("ADP", "She was sitting among her friends."),
    "amid": ("ADP", "The child stayed calm amid all the noise."),
    "amidst": ("ADP", "We found a quiet corner amidst the crowd."),
    "and": ("CCONJ", "We read a story and then we sang a song."),
    "because": ("SCONJ", "We stayed inside because it was cold."),
    "beside": ("ADP", "Come and sit beside me on the rug."),
    "could": ("AUX", "She could hear the rain on the window."),
    "during": ("ADP", "We keep the lights low during the nap."),
    "else": ("ADV", "Is there anything else you want to say?"),
    "for": ("ADP", "This picture is for your family."),
    "from": ("ADP", "The letter came from the school."),
    "how": ("ADV", "Show me how you open your hands."),
    "if": ("SCONJ", "If you are ready, we can start."),
    "into": ("ADP", "Put the blocks into the box."),
    "of": ("ADP", "This is the first day of the week."),
    "ought": ("AUX", "We ought to wait a few more seconds."),
    "shall": ("AUX", "Shall we read the story again?"),
    "she": ("PRON", "She is looking at the picture."),
    "should": ("AUX", "You should hold the cup with both hands."),
    "since": ("SCONJ", "He has been happy since he started school."),
    "than": ("SCONJ", "This box is bigger than that one."),
    "that": ("PRON", "That is the book we read yesterday."),
    "the": ("DET", "The child is playing with the ball."),
    "they": ("PRON", "They are singing together."),
    "this": ("PRON", "This is my favourite song."),
    "to": ("ADP", "We are going to the garden."),
    "toward": ("ADP", "He walked slowly toward the door."),
    "unless": ("SCONJ", "We go outside unless it is raining."),
    "until": ("SCONJ", "Wait until everyone is sitting down."),
    "upon": ("ADP", "The cat jumped upon the table."),
    "we": ("PRON", "We are ready to begin."),
    "what": ("PRON", "What can you see in this picture?"),
    "when": ("SCONJ", "Clap your hands when you hear the drum."),
    "where": ("ADV", "Where did you put your shoes?"),
    "whether": ("SCONJ", "Ask whether she wants to join us."),
    "which": ("PRON", "Which colour do you like best?"),
    "with": ("ADP", "Paint with your fingers, not with a brush."),
    "without": ("ADP", "She walked without making a sound."),
    "would": ("AUX", "Would you like to hear it again?"),
    "you": ("PRON", "You can try it one more time."),
    "nor": ("CCONJ", "He did not cry, nor did he complain."),
    "per": ("ADP", "We read one story per day."),
    "whereas": ("SCONJ", "He likes water play, whereas she likes sand."),
    "etc": ("X", "Bring your coat, your hat, your boots, etc."),
    "versus": ("ADP", "This is play versus work, and play always wins."),
    "via": ("ADP", "We came home via the park."),
    "aye": ("INTJ", "Aye, that is the right answer."),
    "et": ("X", "The book was written by Smith et al."),
    "albeit": ("SCONJ", "He finished the puzzle, albeit very slowly."),
    "whereby": ("ADV", "This is the routine whereby we start the day."),
    "firefight": ("NOUN", "The news described a firefight far away."),
    "ibid": ("X", "The same page is cited again as ibid."),
    "lo": ("INTJ", "Lo, the sun came out again."),
    "mega": ("ADJ", "The children built a mega tower of blocks."),
    "metaphysic": ("NOUN", "The book explains a simple metaphysic of time."),
    "pre": ("ADJ", "This is the pre reading stage of the course."),
    "multi": ("ADJ", "We use multi coloured blocks in the classroom."),
    "que": ("X", "The Spanish word que means that."),
    "unto": ("ADP", "He gave the gift unto his friend."),
    "afore": ("ADV", "As said afore, the routine comes first."),
    "bon": ("ADJ", "They wished us bon voyage at the door."),
    "circa": ("ADP", "The school was built circa nineteen ninety."),
    "coli": ("NOUN", "The lab studied a sample of E. coli."),
    "com": ("X", "The address ends in dot com."),
    "hotline": ("NOUN", "The family called the hotline for advice."),
    "multiparty": ("ADJ", "It was a multiparty meeting at the school."),
    "nah": ("INTJ", "Nah, I do not want any more."),
    "nope": ("INTJ", "Nope, that is not the right piece."),
    "ole": ("INTJ", "Ole, you did it all by yourself!"),
    "showbiz": ("NOUN", "The song came from the world of showbiz."),
    "trans": ("ADJ", "They took a trans Atlantic flight."),
}

VOGAIS = "aeiou"

# Largo máximo de la frase de ejemplo tomada de WordNet. La frase existe para
# OÍRSE en una escuela infantil y para imitarse: pasado este largo deja de ser
# un modelo repetible y se convierte en un párrafo. Cuando un ejemplo se pasa,
# no se recorta —recortar una frase la deja incompleta— sino que se descarta y
# se construye la frase con la definición.
MAX_EXEMPLO = 80

# Definición recortada para que la frase construida quepa en el mismo largo.
MAX_DEFINICION = 68

# Lo que NO se lleva a una asamblea de cero a seis años. WordNet es un
# diccionario general y sus ejemplos vienen de corpus de prensa adulta: hay
# cárcel, armas, alcohol y violencia. La palabra del corpus se queda —es una
# lista de frecuencia del inglés, no se toca—, pero SU FRASE, que es la que se
# graba y suena, se construye entonces con la definición, que es neutra.
#
# Filtra el EJEMPLO, nunca la palabra. Si una palabra de esta lista es la
# entrada misma, su frase saldrá de la definición del diccionario.
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

# Palabras de la lista de origen cuya frase NO puede salir de un ejemplo.
#
# La lista BNC/COCA es una lista de frecuencia del inglés y trae lo que trae,
# insultos incluidos. La palabra no se quita —quitarla sería alterar la lista
# de frecuencia sin que nadie lo pidiera— pero su frase sale SIEMPRE de la
# definición del diccionario, que nombra la cosa sin escenificarla. El ejemplo
# de WordNet para «damn», por poner uno, es una blasfemia entera.
SENSIBLES: set[str] = set()  # las doce que había aquí están ahora en FORA

_PALABRAS = None  # tokenizador perezoso: solo se importa nltk si hace falta


def _tokens(texto: str) -> list[str]:
    import re
    return re.findall(r"[A-Za-z']+", texto.lower())


def _vetada(exemplo: str) -> bool:
    return any(t in VETO for t in _tokens(exemplo))


def _e_oracion(exemplo: str) -> bool:
    """¿Es esto una ORACIÓN, o un trozo de sintagma?

    WordNet llama «ejemplos» a cosas como «a card shark», «the ravages of
    time» o «rustle cattle»: sintagmas sin verbo conjugado. Frank pidió frases
    ENTERAS, así que se comprueba que haya un verbo en forma personal —o un
    imperativo— con el etiquetador de nltk, no a ojo.

    Devuelve False también para lo que es demasiado corto para ser una frase.
    """
    from nltk import pos_tag, word_tokenize

    palabras = word_tokenize(exemplo)
    if len(palabras) < 3:
        return False
    etiquetas = [t for _, t in pos_tag(palabras)]
    # VBP/VBZ/VBD son formas personales; MD es un modal. VB solo cuenta si no
    # va detrás de «to», porque entonces es un infinitivo y puede no haber
    # oración («to exemplify something»).
    for i, (palabra, etiqueta) in enumerate(pos_tag(palabras)):
        if etiqueta in ("VBP", "VBZ", "VBD", "MD"):
            return True
        if etiqueta == "VB" and (i == 0 or palabras[i - 1].lower() != "to"):
            return True
    return "VBN" in etiquetas and any(
        p.lower() in ("is", "are", "was", "were", "be", "been")
        for p in palabras
    )


# Palabras que no pueden quedar al final de una frase: si el recorte las deja
# colgando, la oración se corta en seco —«a structure in a hollow organ with a
# flap to insure.»— y deja de ser una frase entera.
COLGANTES = {
    "a", "an", "the", "of", "to", "with", "for", "in", "on", "at", "by", "as",
    "from", "into", "like", "about", "and", "or", "that", "which", "who",
    "is", "are", "was", "were", "be", "been", "its", "his", "her", "their",
    "this", "these", "those", "such", "very", "more", "most", "not", "no",
    "any", "some", "one", "two", "other", "another", "than", "then", "so",
    "usually", "especially", "often", "esp", "e.g", "i.e",
}


def _sen_colgar(texto: str) -> str:
    """Quita del final lo que deje la frase a medias."""
    partes = texto.split()
    while len(partes) > 1 and partes[-1].strip(",.").lower() in COLGANTES:
        partes.pop()
    limpo = " ".join(partes).rstrip(" ,;:")
    # «seldom» se define «not often»: las dos palabras están en COLGANTES y el
    # recorte dejaba la definición vacía. Si limpiar lo borra todo, no se
    # limpia: una definición corta entera vale más que nada.
    return limpo or texto.strip()


def _recorta(definicion: str, maximo: int = MAX_DEFINICION) -> str:
    """La glosa, sin las variantes que WordNet cuelga tras un punto y coma.

    Una definición entera puede medir doscientos caracteres y la frase existe
    para OÍRSE: pasado cierto largo deja de ser un modelo y es un párrafo. Si
    hay que cortar, se corta por una coma —que es un límite de la oración— y
    nunca dejando una preposición o un artículo al final.
    """
    texto = definicion.split(";")[0].strip()
    texto = texto.replace("(", "").replace(")", "").strip()
    # Solo se limpia el final cuando SE CORTA: una glosa entera no cuelga, y
    # «not often» —la definición de «seldom»— se quedaría en «not».
    if len(texto) <= maximo:
        return texto
    cabeza = texto[:maximo]
    porPalabra = cabeza.rsplit(" ", 1)[0]  # nunca se corta una palabra por la mitad
    porComa = cabeza.rsplit(",", 1)[0] if "," in cabeza else ""
    corte = porComa if len(porComa) >= maximo * 0.5 else porPalabra
    return _sen_colgar(corte)


def _e_instancia(synset) -> bool:
    """¿Es esto un nombre propio disfrazado de palabra?

    WordNet mete personas y lugares como «instancias»: «born» devuelve a Max
    Born, el físico. Una lista de frecuencia del inglés no habla de él, y la
    frase «A born is British nuclear physicist born in Germany» es un disparate
    en una pantalla de vocabulario.
    """
    try:
        return bool(synset.instance_hypernyms())
    except Exception:
        return False


def _synsets_utiles(synsets: list) -> list:
    """Los sentidos que sirven: primero los que no son nombres propios."""
    comuns = [s for s in synsets if not _e_instancia(s)]
    return comuns or synsets


def _pos_dominante(palabra: str, synsets: list) -> str:
    """La categoría gramatical con la que esa palabra SE USA más.

    `wn.synsets()` devuelve los sentidos ordenados por categoría —primero los
    nombres, luego los verbos, luego adjetivos y adverbios—, no por frecuencia.
    Coger `synsets[0]` etiquetaba como NOUN todo lo que tuviera un sentido
    nominal, aunque fuera marginal: 5.826 de las 8.000 salían «NOUN», que es
    justo el defecto por el que se tiró el `pos` inventado que traía el
    fichero de origen.

    Aquí se cuenta: WordNet trae, por lema, cuántas veces aparece ese sentido
    en el corpus etiquetado SemCor. Se suman esas cuentas por categoría y gana
    la mayor. Si ninguna tiene cuenta —palabras raras—, gana la categoría con
    más sentidos, y en empate manda el orden de WordNet.
    """
    contas: dict[str, int] = {}
    sentidos: dict[str, int] = {}
    orde: list[str] = []
    obxectivo = palabra.replace(" ", "_").lower()
    for s in synsets:
        pos = POS_WORDNET.get(s.pos(), "")
        if not pos:
            continue
        if pos not in orde:
            orde.append(pos)
        sentidos[pos] = sentidos.get(pos, 0) + 1
        for lema in s.lemmas():
            if lema.name().lower() == obxectivo:
                contas[pos] = contas.get(pos, 0) + lema.count()
    if not orde:
        return ""
    if any(contas.values()):
        return max(orde, key=lambda p: (contas.get(p, 0), sentidos.get(p, 0),
                                        -orde.index(p)))
    return max(orde, key=lambda p: (sentidos.get(p, 0), -orde.index(p)))


def _conta(synset, palabra: str) -> int:
    """Cuántas veces aparece ese sentido en SemCor, para ese lema."""
    obxectivo = palabra.replace(" ", "_").lower()
    return sum(l.count() for l in synset.lemmas()
               if l.name().lower() == obxectivo)


def _definicion_curta(palabra: str, synsets: list, pos: str) -> str:
    """La definición del sentido MÁS USADO de esa categoría, si cabe.

    Tres pasos, y este orden importa:

    1. los sentidos de la categoría que se va a enseñar —si la palabra se
       etiqueta VERB, la definición no puede salir de un sentido nominal, que
       es lo que producía «To run is to a regular trip»—;
    2. ordenados por la cuenta real de SemCor, el sentido más usado primero;
    3. el primero que quepa entero. Si ninguno cabe, el más usado, recortado.
    """
    mesma = [s for s in synsets if POS_WORDNET.get(s.pos(), "") == pos]
    candidatas = mesma or synsets
    candidatas = sorted(candidatas, key=lambda s: -_conta(s, palabra))

    # Primero los sentidos cuya definición no lleva nada de VETO. WordNet
    # ordena «naughty» con «suggestive of sexual impropriety» por delante de
    # «badly behaved», que es el sentido que se usa con una criatura de cuatro
    # años. La palabra se queda; el sentido que se enseña, no es ese.
    limpas = [s for s in candidatas if not _vetada(s.definition())]
    for grupo in (limpas, candidatas):
        for s in grupo:
            d = _recorta(s.definition())
            if d and len(d) <= MAX_DEFINICION:
                return d
    return _recorta(candidatas[0].definition()) if candidatas else ""


def _frase_desde_definicion(palabra: str, pos: str, definicion: str) -> str:
    """Una frase ENTERA construida con la definición real de WordNet.

    No es un ejemplo de uso —eso es lo primero que se intenta— pero es una
    oración completa, gramatical, que contiene la palabra y que además dice qué
    significa. Y no inventa nada: la definición es de WordNet.
    """
    d = definicion.strip()
    if not d:
        return ""
    if pos == "NOUN":
        art = "An" if palabra[:1].lower() in VOGAIS else "A"
        return f"{art} {palabra} is {d}."
    if pos == "VERB":
        if d.startswith("to "):
            d = d[3:]
        return f"To {palabra} is to {d}."
    if pos == "ADJ":
        return f"Something {palabra} is {d}."
    if pos == "ADV":
        return f"{palabra.capitalize()} means {d}."
    return f"{palabra.capitalize()} means {d}."


def _exemplo_bo(palabra: str, synsets, pos: str) -> str:
    """El primer ejemplo de WordNet que sirva de verdad.

    Cuatro condiciones, y las cuatro son por algo:

    1. que USE la palabra, o no es su frase;
    2. que salga de un sentido de la MISMA categoría gramatical, porque si no
       la pantalla enseña «overlook · NOUN» y la frase dice «the apartment
       overlooks the Hudson», que es el verbo;
    3. que sea una oración entera (`_e_oracion`), que es lo que Frank pidió;
    4. que no lleve nada de la lista VETO, porque esto se graba y suena en una
       escuela infantil.
    """
    for s in synsets:
        if POS_WORDNET.get(s.pos(), "") != pos:
            continue
        for ex in s.examples():
            ex = ex.strip()
            if len(ex) > MAX_EXEMPLO:
                continue
            if palabra.lower() not in ex.lower():
                continue
            if _vetada(ex):
                continue
            if not _e_oracion(ex):
                continue
            return ex
    return ""


def construir() -> tuple[list[dict], dict[str, int]]:
    from nltk.corpus import wordnet as wn
    from wordfreq import zipf_frequency

    bandas = json.loads(BANDAS.read_text(encoding="utf-8"))
    saida = []
    orixe = {"exemplo": 0, "definicion": 0, "man": 0}

    for i, entrada in enumerate(bandas, start=1):
        palabra = str(entrada.get("word", "")).strip()
        if not palabra:
            continue
        banda = str(entrada.get("band", "1k")).strip()
        if banda not in BANDAS_QUE_ENTRAN:
            continue
        if palabra.lower() in FORA:
            continue

        pos = ""
        definicion = ""
        frase = ""

        if palabra in FUNCIONAIS:
            pos, frase = FUNCIONAIS[palabra]
            orixe["man"] += 1
        else:
            synsets = _synsets_utiles(wn.synsets(palabra.replace(" ", "_")))
            if synsets:
                pos = _pos_dominante(palabra, synsets)
                definicion = _definicion_curta(palabra, synsets, pos)
                frase = ("" if palabra.lower() in SENSIBLES
                         else _exemplo_bo(palabra, synsets, pos))
                if frase:
                    orixe["exemplo"] += 1
                else:
                    frase = _frase_desde_definicion(palabra, pos, definicion)
                    if frase:
                        orixe["definicion"] += 1

        if frase:
            frase = frase[0].upper() + frase[1:]
            if frase[-1] not in ".!?":
                frase += "."

        zipf = zipf_frequency(palabra, "en")

        item = {
            "id_global": i,
            "lemma": palabra,
            "banda_frecuencia": banda,
            "nivel_cefr": NIVEL_POR_BANDA.get(banda, "C1+"),
        }
        if pos:
            item["pos"] = pos
        if zipf > 0:
            item["zipf"] = round(zipf, 2)
        if definicion:
            item["definicion"] = definicion
        if frase:
            item["frase"] = frase
        if palabra.lower() in ONOMATOPEIAS:
            item["onomatopeya"] = True
        saida.append(item)

    return saida, orixe


# --------------------------------------------------------------- comprobación
POS_VALIDAS = {
    "NOUN", "VERB", "ADJ", "ADV", "ADP", "AUX", "PRON", "DET", "NUM",
    "CCONJ", "SCONJ", "INTJ", "X",
}


def comprobar() -> int:
    """El gate. NO reconstruye: mira el fichero que viaja en el repositorio.

    Reconstruir exigiría WordNet y wordfreq en cada corrida de CI —y una
    descarga a los servidores de nltk—, así que el gate comprueba lo que de
    verdad importa del fichero entregado: que las 8.000 estén, que ninguna se
    quede sin categoría gramatical ni sin frase, que la frase contenga la
    palabra y termine en punto, y que el nivel salga de la banda.
    """
    if not DESTINO.exists():
        print(f"Falta {DESTINO.relative_to(ROOT)}.")
        return 1

    datos = json.loads(DESTINO.read_text(encoding="utf-8"))
    bandas = json.loads(BANDAS.read_text(encoding="utf-8"))
    fallos = []

    esperadas = sum(1 for e in bandas
                    if str(e.get("band", "")).strip() in BANDAS_QUE_ENTRAN
                    and str(e.get("word", "")).strip().lower() not in FORA)
    if len(datos) != esperadas:
        fallos.append(
            f"o vocabulario ten {len(datos)} palabras e deberían ser {esperadas}")

    for d in datos:
        if str(d.get("banda_frecuencia", "")) not in BANDAS_QUE_ENTRAN:
            fallos.append(f"«{d.get('lemma')}» está fóra das bandas 1k-4k")
        if str(d.get("lemma", "")).lower() in FORA:
            fallos.append(f"«{d.get('lemma')}» é unha das que Frank mandou quitar")

    for d in datos:
        lemma = d.get("lemma", "")
        if not lemma:
            fallos.append(f"#{d.get('id_global')} sen lemma")
            continue
        if d.get("pos") not in POS_VALIDAS:
            fallos.append(f"«{lemma}» sen categoría gramatical válida")
        frase = d.get("frase", "")
        if not frase:
            fallos.append(f"«{lemma}» sen frase")
            continue
        if lemma.lower() not in frase.lower():
            fallos.append(f"a frase de «{lemma}» non contén a palabra: {frase}")
        if frase[-1] not in ".!?":
            fallos.append(f"a frase de «{lemma}» non remata en punto: {frase}")
        esperado = NIVEL_POR_BANDA.get(d.get("banda_frecuencia", ""), "C1+")
        if d.get("nivel_cefr") != esperado:
            fallos.append(f"«{lemma}» ten un nivel que non sae da súa banda")

    if fallos:
        print(f"O corpus de 8.000 ten {len(fallos)} problemas. Os dez primeiros:")
        for f in fallos[:10]:
            print("  ·", f)
        print("Corre: python3 tools/build_corpus_ingles.py")
        return 1

    onoma = sum(1 for d in datos if d.get("onomatopeya"))
    con_zipf = sum(1 for d in datos if d.get("zipf"))
    print(
        f"OK: {len(datos)} palabras, todas con categoría gramatical e frase "
        f"enteira · {con_zipf} con frecuencia real · {onoma} onomatopeias."
    )
    return 0


def main() -> int:
    if "--check" in sys.argv:
        return comprobar()

    datos, orixe = construir()
    texto = json.dumps(datos, ensure_ascii=False, separators=(",", ":")) + "\n"
    DESTINO.write_text(texto, encoding="utf-8")

    con_pos = sum(1 for d in datos if d.get("pos"))
    con_frase = sum(1 for d in datos if d.get("frase"))
    con_zipf = sum(1 for d in datos if d.get("zipf"))
    onoma = sum(1 for d in datos if d.get("onomatopeya"))
    print(
        f"OK: {len(datos)} palabras · {con_pos} con categoría gramatical · "
        f"{con_frase} con frase enteira · {con_zipf} con frecuencia real · "
        f"{onoma} onomatopeias."
    )
    print(
        f"   A frase vén: {orixe['exemplo']} dun exemplo real de WordNet · "
        f"{orixe['definicion']} construída coa definición de WordNet · "
        f"{orixe['man']} escritas a man (as de clase pechada)."
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
