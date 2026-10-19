#!/usr/bin/env python3
"""Ningún texto de la app pide a la criatura que repita, traduzca o «diga cómo se dice».

    python3 tools/check_sin_repetir.py

Decisión D3 del plan docente (`docs/PLAN_MEJORA_INTEGRAL.md`, módulo M2.4): en
gallego, en castellano y en inglés, nada del contenido le pide a la criatura

- que repita una palabra o una frase («que repita», «repite conmigo»,
  «can you say», «say it again», «repeat after me», «and say: …»);
- que traduzca o diga cómo se dice algo («¿cómo se dice…?», «dilo en inglés»,
  «how do you say…», «translate it»);
- ni la corrige de frente («no se dice así», «that's wrong»).

El modelo es el recast: la persona adulta devuelve la frase bien dicha y sigue.

Lo que NO es un fallo, y por eso el gate no se queja:

- **Prohibirlo.** «No pidas que repitan», «Evita «¿cómo se dice?»», «Never ask
  them to repeat». Si en la misma frase, antes de lo encontrado, hay una
  negación o un «evitar», o si el campo es de los que dicen qué evitar
  (`consejoEvitar`, `queEvitar`, `erroComunAEvitar`…), es la regla escrita, no
  su incumplimiento.
- **Que repita la persona adulta.** «Repite el saludo», «repetir en casa la
  misma frase». El gate solo mira las formas que piden algo a otra persona
  («que repita», «repitan»…), no el imperativo dirigido a la adulta.
- **Una afirmación falsa de un test de Academy** (`esVerdadera: false`): está
  escrita para que la familia la descarte.
- **Las excepciones de abajo**, cada una con su motivo.

Mira `assets/content/**.json`, que es lo que se pinta y lo que se oye. No mira
`corpus/` ni `english/`: son diccionarios de consulta de la adulta, donde
«say» es una palabra del inglés, no una consigna.

Escribe una línea por fallo y sale con 1 si hay alguno.
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CONTENIDO = ROOT / "assets" / "content"

# Diccionarios de consulta: el inglés como objeto, no consignas.
FUERA = ("corpus/", "english/")

# Lo que pide algo a la criatura. Cada patrón lleva su nombre para que el fallo
# diga qué ha encontrado.
PATRONES = [
    ("pedir que repita", re.compile(
        r"\b(?:que|para que|a que)\s+(?:\w+\s+){0,4}?"
        r"(?:repita|repitan|repiten)\b", re.I)),
    ("repite conmigo", re.compile(r"\brepit?e\s+(?:conmigo|comigo)\b", re.I)),
    ("pedir que lo diga", re.compile(
        r"\b(?:píde(?:le|lles?)|pídelle|pídelles|pedirlle|pedirle|pide|dile|dille|dígale)\s+que\s+"
        r"(?:\w+\s+){0,3}?(?:diga|digan|repita|repitan|traduza|traduzca)\b",
        re.I)),
    ("cómo se dice", re.compile(r"\bc[oó]mo\s+se\s+di(?:ce)?\b", re.I)),
    ("dilo en inglés", re.compile(
        r"\b(?:dilo|dio|díselo|dillo|decilo)\s+en\s+inglés\b", re.I)),
    ("traducir", re.compile(r"\btrad[uú]c(?:elo|eo|ea|ilo|ilas|ir)\b", re.I)),
    ("corrección de frente", re.compile(
        r"\b(?:no\s+se\s+dice\s+así|non\s+se\s+di\s+así|está\s+mal\s+dich[oa]|"
        r"that'?s\s+wrong|that\s+is\s+wrong)\b", re.I)),
    ("can you say", re.compile(r"\bcan\s+you\s+say\b", re.I)),
    ("say it again", re.compile(r"\bsay\s+(?:it|that)\s+again\b", re.I)),
    ("repeat after me", re.compile(r"\brepeat\s+after\s+me\b", re.I)),
    ("ask to repeat", re.compile(
        r"\b(?:ask|make|get)\s+(?:him|her|them|the\s+child(?:ren)?|the\s+group)\s+"
        r"(?:to\s+)?(?:repeat|say)\b", re.I)),
    ("and say", re.compile(r"\b(?:and|then)\s+say\b(?!\s+(?:it|so))", re.I)),
    ("say: …", re.compile(r"\bsay\s*:", re.I)),
    # «"Say thank you to the baker!"»: una orden de decir algo, entre comillas o
    # al principio del texto. Las fórmulas del banco («Say hello», «Say please»)
    # se libran más abajo: son palabras del trayecto que la adulta modela y cuya
    # respuesta es un gesto.
    ("«Say …» como orden", re.compile(r"(?:^|[\"“«])\s*say\b(?!\s*:)", re.I)),
    ("let's say", re.compile(r"\blet'?s\s+(?:all\s+)?say\b", re.I)),
    ("how do you say", re.compile(r"\bhow\s+do\s+you\s+say\b", re.I)),
    ("say it in English", re.compile(r"\bsay\s+it\s+in\s+english\b", re.I)),
    ("translate", re.compile(r"\btranslate\s+(?:it|this|that)\b", re.I)),
]

# Antes de lo encontrado, en la misma frase: es una prohibición.
NEGACION = re.compile(
    r"\b(?:no|non|nunca|ni|nin|sin|sen|evita|evitar|evite|never|not|don'?t|"
    r"do\s+not|avoid|without|nada\s+de|nin\s+de)\b", re.I)

# Campos que dicen qué no hacer: todo su texto es la regla escrita.
CAMPOS_EVITAR = re.compile(r"(?:evitar|avoid|erroComun)", re.I)

# Fin de frase, para no mirar negaciones de la frase anterior. Lo que va entre
# comillas no corta la frase: en «Nunca preguntes «¿cómo se dice?»» el «¿» es de
# la cita, y la negación de delante sigue mandando.
FIN_DE_FRASE = re.compile(r"[.!?;\n]")
CITA = re.compile(r"«[^»]*»|“[^”]*”|\"[^\"]*\"")

# Excepciones: (fichero relativo a assets/content, texto exacto, motivo). Cada
# una dice por qué el texto cumple la regla aunque lleve las palabras.
EXCEPCIONES = [
    ("capsulas/academy.segundo_ciclo.setembro.01.json",
     "Esixir que a crianza fale en inglés ou preguntarlle «como se di isto?» "
     "convérteo nun exame, e o exame corta a conversa. Devolverlle a frase ben "
     "dita dentro do xogo (modelado indirecto ou recast) valida o que dixo e "
     "mantén viva a ganas de falar.",
     "Cita la pregunta para explicar por qué no se hace."),
    ("capsulas/academy.segundo_ciclo.setembro.01.json",
     "Exigir que el niño hable en inglés o preguntarle «¿cómo se dice esto?» lo "
     "convierte en un examen, y el examen corta la conversación. Devolverle la "
     "frase bien dicha dentro del juego (modelado indirecto o recast) valida lo "
     "que dijo y mantiene vivas las ganas de hablar.",
     "Cita la pregunta para explicar por qué no se hace."),
    ("capsulas/academy.segundo_ciclo.setembro.01.json",
     "O modelado indirecto (recast) axuda máis á aprendizaxe que pedir que "
     "repita a frase ben dita.",
     "Afirmación verdadera del test: compara el recast con pedir que repita."),
    ("capsulas/academy.segundo_ciclo.setembro.01.json",
     "El modelado indirecto (recast) ayuda más al aprendizaje que pedir que "
     "repita la frase bien dicha.",
     "Afirmación verdadera del test: compara el recast con pedir que repita."),
    ("formacion/formacion.familia.json",
     "Esa pregunta convierte un xogo nun exame. Xera ansiedade e o resultado "
     "adoita ser que a crianza cala ou rexeita a actividade. O mesmo pasa con "
     "«non se di así» ou «dillo a papá».",
     "Cita las frases para explicar por qué no se dicen."),
    ("formacion/formacion.familia.json",
     "Esa pregunta convierte un juego en un examen. Genera ansiedad y el "
     "resultado suele ser que la criatura calla o rechaza la actividad. Lo mismo "
     "pasa con «no se dice así» o «díselo a papá».",
     "Cita las frases para explicar por qué no se dicen."),
    ("nomes/nomes_portais.json",
     "Canto dura o xogo segundo a idade e como se di cada frase.",
     "Etiqueta de menú: la que aprende cómo se dice la frase es la adulta."),
    ("nomes/nomes_portais.json",
     "Cuánto dura el juego según la edad y cómo se dice cada frase.",
     "Etiqueta de menú: la que aprende cómo se dice la frase es la adulta."),
    ("asambleas_segundo_ciclo/asamblea.segundo_ciclo.abril.6_infantil.json",
     "The teacher describes an ecological shelter; children choose the motor "
     "response and say the matching chunk.",
     "Sale del documento curricular de Frank (6.º, fase transaccional): espera "
     "que la criatura use la fórmula, no que repita un modelo. Frank decidió "
     "el 19/10/2026 que estas órdenes se quedan (D3)."),
]

def textos(valor, ruta):
    """Recorre el JSON y da (ruta, texto) de cada cadena, con el nodo padre."""
    if isinstance(valor, dict):
        for clave, hijo in valor.items():
            yield from textos(hijo, ruta + [str(clave)])
    elif isinstance(valor, list):
        for i, hijo in enumerate(valor):
            yield from textos(hijo, ruta + [str(i)])
    elif isinstance(valor, str):
        yield ruta, valor


def es_afirmacion_falsa(datos, ruta) -> bool:
    """La cadena está dentro de una afirmación de test con esVerdadera: false."""
    nodo = datos
    for paso in ruta:
        if isinstance(nodo, dict) and nodo.get("esVerdadera") is False:
            return True
        nodo = nodo[int(paso)] if isinstance(nodo, list) else nodo.get(paso)
        if nodo is None:
            return False
    return False


def palabras_del_banco() -> set[str]:
    """Las expresiones inglesas del banco TPR, en minúsculas y sin signos."""
    banco: set[str] = set()
    for fichero in (CONTENIDO / "tpr").glob("curso_*/*.json"):
        for semana in json.loads(fichero.read_text(encoding="utf-8"))["semanas"]:
            for palabra in semana["palabras"]:
                banco.add(_limpia(palabra["en"]))
    return banco


def _limpia(texto: str) -> str:
    return re.sub(r"[^a-z' ]", "", texto.lower()).strip()


def es_palabra_del_banco(texto: str, hallazgo: re.Match, banco: set[str]) -> bool:
    """Lo encontrado es una expresión del banco: el texto entero, o lo que va
    entre las comillas donde está. «Say hello» o «Say please» son fórmulas del
    trayecto (D9: el banco no se toca); su respuesta es un gesto."""
    if _limpia(texto) in banco:
        return True
    for cita in CITA.finditer(texto):
        if cita.start() <= hallazgo.start() < cita.end():
            return _limpia(cita.group(0)) in banco
    return False


def prohibido_antes(texto: str, inicio: int) -> bool:
    """En la misma frase, antes del hallazgo, hay una negación o un «evitar»."""
    trozo = CITA.sub(lambda m: " " * len(m.group(0)), texto[:inicio])
    # Una cita abierta que llega hasta el hallazgo tampoco corta la frase.
    trozo = re.sub(r"[«“\"][^»”\"]*$", lambda m: " " * len(m.group(0)), trozo)
    cortes = list(FIN_DE_FRASE.finditer(trozo))
    if cortes:
        trozo = trozo[cortes[-1].end():]
    return bool(NEGACION.search(trozo))


def main() -> int:
    excepciones = {(f, t) for f, t, _ in EXCEPCIONES}
    banco = palabras_del_banco()
    usadas: set[tuple[str, str]] = set()
    fallos: list[str] = []
    revisados = 0

    for fichero in sorted(CONTENIDO.rglob("*.json")):
        relativo = fichero.relative_to(CONTENIDO).as_posix()
        if relativo.startswith(FUERA):
            continue
        datos = json.loads(fichero.read_text(encoding="utf-8"))
        revisados += 1
        for ruta, texto in textos(datos, []):
            if any(CAMPOS_EVITAR.search(paso) for paso in ruta):
                continue
            for nombre, patron in PATRONES:
                for hallazgo in patron.finditer(texto):
                    if prohibido_antes(texto, hallazgo.start()):
                        continue
                    if es_afirmacion_falsa(datos, ruta):
                        continue
                    if es_palabra_del_banco(texto, hallazgo, banco):
                        continue
                    if (relativo, texto) in excepciones:
                        usadas.add((relativo, texto))
                        continue
                    fallos.append(
                        f"{relativo}: {'.'.join(ruta)}: {nombre}: «{texto}»")

    sobrantes = excepciones - usadas
    for relativo, texto in sorted(sobrantes):
        fallos.append(
            f"{relativo}: excepción que ya no hace falta, quítala: «{texto}»")

    if fallos:
        print("Textos que piden a la criatura repetir, traducir o «cómo se dice», "
              "o que corrigen de frente:\n")
        for linea in fallos:
            print(f"  {linea}")
        print(f"\n{len(fallos)} fallos en {revisados} ficheros.")
        return 1

    print(f"OK: {revisados} ficheros de contenido; ninguno pide repetir, "
          "traducir ni «cómo se dice».")
    return 0


if __name__ == "__main__":
    sys.exit(main())
