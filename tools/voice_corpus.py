#!/usr/bin/env python3
"""Shared definition of the offline voice corpus.

Every locution the app can play is derived from the content JSON, never listed
by hand. The identifier of a recording is a hash of the text itself, so editing
a sentence necessarily changes the identifier: the old recording stops being
referenced, the new one does not exist yet, and check_voice_coverage.py says so.
That is what makes it impossible to ship a screen that shows one sentence and
plays another.

The hash is the same FNV-1a used by the earlier pipeline in the house, so an id computed
here, in Dart (lib/core/audio/voice_id.dart) or in JavaScript is identical.
"""
from __future__ import annotations

import json
import re
from pathlib import Path
from typing import Iterator, NamedTuple

ROOT = Path(__file__).resolve().parent.parent
CONTENT_DIR = ROOT / "assets" / "content"
VOICE_DIR = ROOT / "assets" / "voice"
CORPUS_JSON = ROOT / "voice-corpus.json"

# Las dos lenguas en las que se LEE la app. Toda la prosa bilingüe va en estas.
LANGS = ("gl", "es")

# El inglés no es lengua de interfaz: no hay ni una pantalla en inglés. Entra en
# el corpus como CONTENIDO que se escucha —el léxico, las órdenes TPR y las
# frases de assets/content/calendario/— para que la persona adulta pueda oír la
# pronunciación antes de decirla. Por eso se recoge aparte y no con _localized.
VOICE_LANGS = ("gl", "es", "en")
ALL_LANGS = VOICE_LANGS

# Reading pace passed to the synthesiser. There is no `child` style because a
# child never uses this app, and no `clinical` style because nothing here has a
# health purpose.
LENGTH_SCALE = {"tutor": 1.0, "slow": 1.6}

_WHITESPACE = re.compile(r"\s+")

# Pulse markers and syllable splits belong to what the teacher READS, not to
# what the voice SAYS: "* On-das * que veñen" is chanted as "Ondas que veñen".
# The identifier still hashes the displayed text, so changing a marker changes
# the recording — the displayed and the spoken text can never drift apart.
_PULSE_MARKER = re.compile(r"[*]")
_SYLLABLE_SPLIT = re.compile(r"(?<=[^\W\d_])-(?=[^\W\d_])")


def speech_text(text: str) -> str:
    """The text as the voice should say it, without the teacher's notation."""
    without_markers = _PULSE_MARKER.sub(" ", text)
    joined = _SYLLABLE_SPLIT.sub("", without_markers)
    return normalize(joined)


class Locution(NamedTuple):
    id: str
    lang: str
    style: str
    text: str
    speech: str
    source: str

    @property
    def filename(self) -> str:
        return f"{self.id}.m4a"

    @property
    def asset_path(self) -> str:
        return f"assets/voice/{self.filename}"


def normalize(text: str) -> str:
    """Collapses the whitespace that does not change how a sentence is read."""
    return _WHITESPACE.sub(" ", text).strip()


def fnv1a32(value: str) -> str:
    """FNV-1a, 32 bits, over UTF-16 code units (matches the Dart and JS ports)."""
    code_units = value.encode("utf-16-le")
    hash_ = 0x811C9DC5
    for i in range(0, len(code_units), 2):
        unit = code_units[i] | (code_units[i + 1] << 8)
        hash_ ^= unit
        hash_ = (hash_ * 0x01000193) & 0xFFFFFFFF
    return f"{hash_:08x}"


def utf16_length(value: str) -> int:
    """Length in UTF-16 code units, which is what Dart and JS call `.length`."""
    return len(value.encode("utf-16-le")) // 2


def voice_id(style: str, text: str, lang: str) -> str:
    normalized = normalize(text)
    return f"{lang}_{style}_{fnv1a32(normalized)}_{utf16_length(normalized)}"


def _localized(node: object) -> dict[str, str]:
    if isinstance(node, dict):
        return {lang: str(node.get(lang, "")) for lang in LANGS}
    return {lang: "" for lang in LANGS}


def _one(text: str, lang: str, style: str, source: str,
         seen: dict[str, Locution]) -> None:
    """Una locución suelta en una lengua concreta. La usa el inglés."""
    value = normalize(text)
    if not value:
        return
    entry = Locution(
        id=voice_id(style, value, lang),
        lang=lang,
        style=style,
        text=value,
        speech=speech_text(value),
        source=source,
    )
    seen.setdefault(entry.id, entry)


def _add(text: dict[str, str], style: str, source: str, seen: dict[str, Locution]) -> None:
    for lang in LANGS:
        _one(text.get(lang, ""), lang, style, source, seen)


def estilo_ingles(text: str) -> str:
    """Una palabra suelta se imita, una frase se lee.

    La MISMA regla está en `estiloIngles` de lib/core/audio/voice_id.dart. Si
    las dos dejaran de coincidir, la app pediría una grabación con otro
    identificador y el botón desaparecería sin que nadie supiera por qué.
    """
    return "tutor" if " " in normalize(text) else "slow"


def collect_locutions(content_dir: Path = CONTENT_DIR) -> list[Locution]:
    """Every locution the app can play, read from the content JSON.

    Nothing is invented here: if a screen starts playing something new, it gets
    added to this function first and the coverage gate reports the missing
    recording until it is synthesised.

    The corpus used to cover only the pulse chant and the vocabulary words —
    twelve recordings — so almost every card in the app had no speaker button.
    It now covers every piece of PROSE the adult reads on a card, in both
    languages, which is what a neural Galician voice is actually for: a teacher
    who did not grow up speaking Galician can hear the model pronunciation
    before saying it to the class.

    What is deliberately left out: titles, subtitles, headings and lists of
    materials. They are labels, not sentences, and a synthesised voice reading
    "Grande / Pequeno, Moito / Pouco" out of context is noise. Vocabulary words
    are the exception, and they get the slow pace because they exist to be
    imitated.
    """
    seen: dict[str, Locution] = {}

    for path in sorted((content_dir / "unidades").glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        unit_id = data.get("id", path.stem)

        # El inglés de la unidad, fase por fase: es lo que la barra de la
        # asamblea pinta con altavoz, así que tiene que estar grabado.
        ingles = data.get("ingles") or {}
        for fase, textos in (ingles.get("porFase") or {}).items():
            for texto in textos or []:
                _one(str(texto), "en", estilo_ingles(str(texto)),
                     f"{unit_id}/ingles/{fase}", seen)
        if ingles.get("frase"):
            _one(str(ingles["frase"]), "en", estilo_ingles(str(ingles["frase"])),
                 f"{unit_id}/ingles/frase", seen)

        cancion = data.get("cancionPulso") or data.get("cancion") or {}
        letra = cancion.get("letraConPulsos") or cancion.get("letra_con_pulsos")
        if letra:
            # A neural TTS voice speaks; it does not sing. The recording for the
            # pulse step is the lyrics chanted at a steady pace, which is how
            # pulse work is done with 0-3 anyway. The instrumental pulse track
            # stays available separately as the metronome.
            _add(_localized(letra), "tutor", f"{unit_id}/cancionPulso", seen)
        if cancion.get("consignaDocente"):
            _add(
                _localized(cancion["consignaDocente"]),
                "tutor",
                f"{unit_id}/cancionPulso/consigna",
                seen,
            )

        cuento = data.get("cuento") or {}
        for i, pagina in enumerate(cuento.get("paginas") or []):
            if not isinstance(pagina, dict):
                continue
            if pagina.get("texto"):
                _add(_localized(pagina["texto"]), "tutor",
                     f"{unit_id}/cuento/{i}/texto", seen)
            if pagina.get("preguntaComprension"):
                _add(_localized(pagina["preguntaComprension"]), "tutor",
                     f"{unit_id}/cuento/{i}/pregunta", seen)
            # El inglés de ESA página: lo que la persona adulta dice mientras la
            # lee. Va aquí y no en porFase porque la docente tiene delante la
            # página, no la fase.
            for texto in pagina.get("ingles") or []:
                _one(str(texto), "en", estilo_ingles(str(texto)),
                     f"{unit_id}/cuento/{i}/ingles", seen)

        for pregunta in data.get("preguntas") or []:
            if not isinstance(pregunta, dict):
                continue
            pid = pregunta.get("id", "?")
            for campo in ("enunciado", "respuestaSugerida", "consejoDocente"):
                if pregunta.get(campo):
                    _add(_localized(pregunta[campo]), "tutor",
                         f"{unit_id}/preguntas/{pid}/{campo}", seen)

        for item in data.get("vocabulario") or []:
            if not isinstance(item, dict):
                continue
            item_id = item.get("id", "?")
            # La palabra va despacio: existe para que la imiten.
            if item.get("palabra"):
                _add(_localized(item["palabra"]), "slow",
                     f"{unit_id}/vocabulario/{item_id}", seen)
            # La palabra inglesa, al lado de la galega y la castellana: la
            # tarjeta las enseña juntas y las tres se pueden oír.
            if item.get("ingles"):
                _one(str(item["ingles"]), "en", estilo_ingles(str(item["ingles"])),
                     f"{unit_id}/vocabulario/{item_id}/ingles", seen)
            # `definicionBreve` NO entra en el corpus: hoy no hay ninguna
            # pantalla que pinte el vocabulario, así que esas grabaciones
            # viajarían en el APK sin que nada pudiera reproducirlas. Entra el
            # día que exista la tarjeta, no antes.

        exploracion = data.get("exploracion") or {}
        for campo in ("objetivoSensorial", "avisoSeguridad"):
            if exploracion.get(campo):
                _add(_localized(exploracion[campo]), "tutor",
                     f"{unit_id}/exploracion/{campo}", seen)
        for i, paso in enumerate(exploracion.get("pasos") or []):
            _add(_localized(paso), "tutor", f"{unit_id}/exploracion/paso/{i}",
                 seen)

        matematicas = data.get("matematicas") or {}
        if matematicas.get("descripcion"):
            _add(_localized(matematicas["descripcion"]), "tutor",
                 f"{unit_id}/matematicas/descripcion", seen)
        for i, accion in enumerate(matematicas.get("accionesSugeridas") or []):
            _add(_localized(accion), "tutor",
                 f"{unit_id}/matematicas/accion/{i}", seen)

        puente = data.get("puenteCasa") or {}
        for campo in ("mensajeFamilias", "recomendacionConversacion"):
            if puente.get(campo):
                _add(_localized(puente[campo]), "tutor",
                     f"{unit_id}/puenteCasa/{campo}", seen)
        for i, act in enumerate(puente.get("actividadesSugeridas") or []):
            _add(_localized(act), "tutor", f"{unit_id}/puenteCasa/act/{i}", seen)

    # Academy. Las cápsulas las lee una familia en casa, muchas veces con las
    # manos ocupadas; que se puedan escuchar no es un adorno.
    for path in sorted((content_dir / "capsulas").glob("*.json")):
        data = json.loads(path.read_text(encoding="utf-8"))
        cap_id = data.get("id", path.stem)

        # `luaDice` es el cierre de la gata. Entra en el corpus como las
        # otras cuatro: es prosa que la familia lee, y si se pudiera leer
        # pero no escuchar sería la única tarjeta del lector sin altavoz.
        for campo in ("ideaClave", "porQueImporta", "queHacerEnCasa",
                      "ejemploCotidiano", "luaDice"):
            if data.get(campo):
                _add(_localized(data[campo]), "tutor", f"{cap_id}/{campo}", seen)

        for afirmacion in data.get("afirmaciones") or []:
            if not isinstance(afirmacion, dict):
                continue
            aid = afirmacion.get("id", "?")
            for campo in ("enunciado", "explicacion"):
                if afirmacion.get(campo):
                    _add(_localized(afirmacion[campo]), "tutor",
                         f"{cap_id}/afirmaciones/{aid}/{campo}", seen)

    # ── El inglés del Calendario Escola·Fogar ──────────────────────────────
    # Es la razón de ser de la voz inglesa: una maestra de una escuela infantil
    # de Vigo no tiene por qué pronunciar «Crunch leaves», y aquí lo oye antes
    # de llevarlo a la asamblea. Solo entra lo que una pantalla puede
    # reproducir: el léxico, las órdenes y la frase del mes se pintan como
    # pastillas con altavoz, y la frase de cada tramo, en la guía de la
    # familia. Nada que no se pueda pulsar viaja en el APK.
    meses_json = content_dir / "calendario" / "meses.json"
    if meses_json.exists():
        data = json.loads(meses_json.read_text(encoding="utf-8"))
        for mes in data.get("meses") or []:
            orden = mes.get("orden", "?")
            ingles = mes.get("ingles") or {}
            for palabra in ingles.get("lexico") or []:
                # Despacio: las palabras sueltas existen para imitarse.
                _one(str(palabra), "en", "slow",
                     f"calendario/mes/{orden}/ingles/lexico", seen)
            for comando in ingles.get("tpr") or []:
                _one(str(comando), "en", "tutor",
                     f"calendario/mes/{orden}/ingles/tpr", seen)
            if ingles.get("frase"):
                _one(str(ingles["frase"]), "en", "tutor",
                     f"calendario/mes/{orden}/ingles/frase", seen)

    atencion_json = content_dir / "calendario" / "atencion.json"
    if atencion_json.exists():
        data = json.loads(atencion_json.read_text(encoding="utf-8"))
        for tramo in data.get("tramos") or []:
            if tramo.get("fraseIngles"):
                _one(str(tramo["fraseIngles"]), "en", "tutor",
                     f"calendario/tramo/{tramo.get('id', '?')}/fraseIngles",
                     seen)

    # La asamblea matinal de segundo ciclo. Nació MUDA: la docente leía la
    # consigna y el inglés de las órdenes TPR sin poder oír cómo suena, que es
    # justo lo que la voz neuronal existe para resolver. Este directorio no lo
    # miraba nadie, así que el gate de cobertura daba OK sin cubrirlo.
    asambleas = content_dir / "asambleas_segundo_ciclo"
    if asambleas.exists():
        for path in sorted(asambleas.glob("*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            aid = data.get("id", path.stem)

            for fase in data.get("fases") or []:
                if not isinstance(fase, dict):
                    continue
                orden = fase.get("orden", "?")
                # Lo que la docente dice en voz alta, en las dos lenguas.
                if fase.get("consignaDocente"):
                    _add(_localized(fase["consignaDocente"]), "tutor",
                         f"{aid}/fase/{orden}/consigna", seen)
                # La señal en inglés que abre la fase.
                if fase.get("cueAcustica"):
                    texto = str(fase["cueAcustica"])
                    _one(texto, "en", estilo_ingles(texto),
                         f"{aid}/fase/{orden}/cue", seen)
                for comando in fase.get("comandosL3") or []:
                    if not isinstance(comando, dict):
                        continue
                    cid = comando.get("id", "?")
                    # La orden en inglés: esto es el corazón del TPR y es lo
                    # que nadie tiene por qué saber pronunciar de oído.
                    if comando.get("textoIngles"):
                        texto = str(comando["textoIngles"])
                        _one(texto, "en", estilo_ingles(texto),
                             f"{aid}/fase/{orden}/cmd/{cid}/ingles", seen)
                    for campo in ("accionFisica", "modeladoDocente"):
                        if comando.get(campo):
                            _add(_localized(comando[campo]), "tutor",
                                 f"{aid}/fase/{orden}/cmd/{cid}/{campo}", seen)

            # La micro-rutina de casa la lee la familia, muchas veces con las
            # manos ocupadas, igual que las cápsulas.
            micro = data.get("microRutinaHogar") or {}
            for campo in ("objetivoAutonomia", "escenaCotidiana"):
                if micro.get(campo):
                    _add(_localized(micro[campo]), "tutor",
                         f"{aid}/microRutina/{campo}", seen)
            for i, pauta in enumerate(micro.get("pautasRecast") or []):
                if not isinstance(pauta, dict):
                    continue
                for campo in ("modeladoIndirecto", "consejoEvitar"):
                    if pauta.get(campo):
                        _add(_localized(pauta[campo]), "tutor",
                             f"{aid}/microRutina/pauta/{i}/{campo}", seen)

    # La microcápsula matinal del PRIMER ciclo. Nació muda por el mismo motivo
    # exacto que la de segundo: el directorio es nuevo y esta función no lo
    # miraba, así que el gate de cobertura habría dado OK sobre veinte ficheros
    # sin una sola grabación. Es la segunda vez que pasa; por eso queda escrito.
    primeiro = content_dir / "asambleas_primeiro_ciclo"
    if primeiro.exists():
        for path in sorted(primeiro.glob("*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            aid = data.get("id", path.stem)

            for fase in data.get("fases") or []:
                if not isinstance(fase, dict):
                    continue
                orden = fase.get("orden", "?")
                if fase.get("consignaDocente"):
                    _add(_localized(fase["consignaDocente"]), "tutor",
                         f"{aid}/fase/{orden}/consigna", seen)
                # La canción del mes es el título de una canción inglesa, y es
                # justo lo que una educadora que no la conoce necesita oír.
                if fase.get("cueAcustica"):
                    texto = str(fase["cueAcustica"])
                    _one(texto, "en", estilo_ingles(texto),
                         f"{aid}/fase/{orden}/cue", seen)
                for comando in fase.get("comandosL3") or []:
                    if not isinstance(comando, dict):
                        continue
                    cid = comando.get("id", "?")
                    if comando.get("textoIngles"):
                        texto = str(comando["textoIngles"])
                        _one(texto, "en", estilo_ingles(texto),
                             f"{aid}/fase/{orden}/cmd/{cid}/ingles", seen)
                    for campo in ("accionFisica", "modeladoDocente"):
                        if comando.get(campo):
                            _add(_localized(comando[campo]), "tutor",
                                 f"{aid}/fase/{orden}/cmd/{cid}/{campo}", seen)

    # La formación previa: lo que docente y familia leen ANTES de usar la app.
    # Es prosa de adulto, igual que las cápsulas, y se lee muchas veces con las
    # manos ocupadas.
    formacion = content_dir / "formacion"
    if formacion.exists():
        for path in sorted(formacion.glob("*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            gid = data.get("id", path.stem)
            for i, paso in enumerate(data.get("pasos") or []):
                if not isinstance(paso, dict):
                    continue
                for campo in ("corpo", "clave"):
                    if paso.get(campo):
                        _add(_localized(paso[campo]), "tutor",
                             f"{gid}/paso/{i}/{campo}", seen)

    # La progresión diaria: el foco y la consigna de cada uno de los 20 días
    # de cada tramo. Es lo que la docente lee en la fase núcleo en vez de la
    # consigna del mes, así que necesita voz igual que ella.
    progresion = content_dir / "progresion"
    if progresion.exists():
        for path in sorted(progresion.glob("*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            pid = data.get("id", path.stem)
            for dia in data.get("dias") or []:
                if not isinstance(dia, dict):
                    continue
                ref = f"{pid}/s{dia.get('semana', '?')}/d{dia.get('dia', '?')}"
                for campo in ("foco", "consigna"):
                    if dia.get(campo):
                        _add(_localized(dia[campo]), "tutor",
                             f"{ref}/{campo}", seen)

    # El inglés de los módulos nuevos. Nacieron MUDOS —es la tercera vez que
    # pasa lo mismo: contenido nuevo en un directorio que esta función no
    # miraba— y el efecto se ve en la pantalla: «Comprensión Auditiva» sin una
    # sola grabación, el entrenador de vocabulario enseñando «water» sin poder
    # decirlo, y la tarjeta de la lámina con su acción TPR en inglés y nadie
    # que la pronuncie.
    ingles = content_dir / "english"
    if ingles.exists():
        corpus_json = ingles / "english_corpus.json"
        if corpus_json.exists():
            data = json.loads(corpus_json.read_text(encoding="utf-8"))
            for palabra in data.get("words") or []:
                if not isinstance(palabra, dict):
                    continue
                wid = palabra.get("id", "?")
                for campo in ("word", "naturalPhrase"):
                    if palabra.get(campo):
                        texto = str(palabra[campo])
                        _one(texto, "en", estilo_ingles(texto),
                             f"english/word/{wid}/{campo}", seen)
                tpr = palabra.get("tprAction")
                if isinstance(tpr, dict) and tpr.get("en"):
                    texto = str(tpr["en"])
                    _one(texto, "en", estilo_ingles(texto),
                         f"english/word/{wid}/tpr", seen)
                for colocacion in palabra.get("collocations") or []:
                    texto = str(colocacion)
                    _one(texto, "en", estilo_ingles(texto),
                         f"english/word/{wid}/colocacion", seen)
            for escena in data.get("scenarios") or []:
                if not isinstance(escena, dict):
                    continue
                sid = escena.get("id", "?")
                for i, turno in enumerate(escena.get("turns") or []):
                    if isinstance(turno, dict) and turno.get("en"):
                        texto = str(turno["en"])
                        _one(texto, "en", estilo_ingles(texto),
                             f"english/scenario/{sid}/turn/{i}", seen)

        colocaciones_json = ingles / "collocations_grammar.json"
        if colocaciones_json.exists():
            data = json.loads(colocaciones_json.read_text(encoding="utf-8"))
            for col in data.get("collocations") or []:
                if not isinstance(col, dict):
                    continue
                cid = col.get("id", "?")
                for campo in ("fullCollocation", "naturalContext"):
                    if col.get(campo):
                        texto = str(col[campo])
                        _one(texto, "en", estilo_ingles(texto),
                             f"english/colocacion/{cid}/{campo}", seen)
            for escena in data.get("scenarios") or []:
                if not isinstance(escena, dict):
                    continue
                sid = escena.get("id", "?")
                for i, turno in enumerate(escena.get("turns") or []):
                    if isinstance(turno, dict) and turno.get("en"):
                        texto = str(turno["en"])
                        _one(texto, "en", estilo_ingles(texto),
                             f"english/colocacion/{sid}/turn/{i}", seen)

        fonemas_json = ingles / "phonics_taxonomy.json"
        if fonemas_json.exists():
            data = json.loads(fonemas_json.read_text(encoding="utf-8"))
            for fonema in data.get("phonemes") or []:
                if not isinstance(fonema, dict):
                    continue
                ej = fonema.get("exampleWord")
                if isinstance(ej, dict) and ej.get("en"):
                    texto = str(ej["en"])
                    _one(texto, "en", estilo_ingles(texto),
                         f"english/fonema/{fonema.get('id', '?')}/exemplo", seen)
            for palabra in data.get("decodableWords") or []:
                if isinstance(palabra, dict) and palabra.get("word"):
                    texto = str(palabra["word"])
                    _one(texto, "en", estilo_ingles(texto),
                         f"english/decodable/{palabra.get('id', '?')}", seen)

    # La palabra inglesa de cada lámina y su acción TPR: es lo que la persona
    # adulta dice mientras enseña la tarjeta.
    laminas_json = content_dir / "laminas" / "banco200_laminas.json"
    if laminas_json.exists():
        for lam in json.loads(laminas_json.read_text(encoding="utf-8")):
            if not isinstance(lam, dict):
                continue
            lid = lam.get("id", "?")
            if lam.get("en"):
                texto = str(lam["en"])
                _one(texto, "en", estilo_ingles(texto),
                     f"lamina/{lid}/en", seen)
            tpr = lam.get("tprAccion")
            if isinstance(tpr, dict) and tpr.get("en"):
                texto = str(tpr["en"])
                _one(texto, "en", estilo_ingles(texto),
                     f"lamina/{lid}/tpr", seen)

    # El reto TPR oral de cada cuento del banco.
    cuentos = content_dir / "cuentos"
    if cuentos.exists():
        for path in sorted(cuentos.glob("*.json")):
            data = json.loads(path.read_text(encoding="utf-8"))
            if not isinstance(data, list):
                continue
            for cuento in data:
                if not isinstance(cuento, dict):
                    continue
                tpr = cuento.get("tprOral")
                if isinstance(tpr, dict) and tpr.get("fraseEn"):
                    texto = str(tpr["fraseEn"])
                    _one(texto, "en", estilo_ingles(texto),
                         f"conto/{cuento.get('id', '?')}/tpr", seen)

    # LAS 4.000 SUENAN ENTERAS: la palabra y su frase.
    #
    # Esto lo ordenó Frank: «deben sonar todas porque deben integrarse dentro
    # de la aplicación… necesitamos todas las palabras con frases completas».
    # Después acotó cuáles: «solo deja las 4.000 palabras que usan de forma
    # habitual». Así que suenan las 3.995 del fichero, que son las cuatro
    # primeras bandas de frecuencia menos las doce que mandó quitar.
    #
    # Dos grabaciones por palabra, y las dos hacen falta:
    #
    #   · la PALABRA sola, en estilo `slow`, que es el que existe para imitar
    #     —una palabra suelta dicha a ritmo de frase no se puede repetir—;
    #   · la FRASE entera, en estilo `tutor`, que es comprensión auditiva:
    #     oírla entera, entenderla y poder decirla.
    #
    # El identificador sale del texto EXACTO, así que «Bird» —como aparece en
    # la asamblea— y «bird» —como aparece en la lista— son dos grabaciones
    # distintas, y las dos se graban. No hay lista a mano de nada: lo que está
    # en el fichero del corpus, suena.
    corpus_cefr = content_dir / "corpus" / "ingles_4000_uso_habitual.json"
    if corpus_cefr.exists():
        for palabra in json.loads(corpus_cefr.read_text(encoding="utf-8")):
            if not isinstance(palabra, dict):
                continue
            ref = f"corpus/{palabra.get('id_global', '?')}"
            lema = normalize(str(palabra.get("lemma", "")))
            if lema:
                _one(lema, "en", "slow", f"{ref}/lemma", seen)
            frase = normalize(str(palabra.get("frase", "")))
            if frase:
                _one(frase, "en", "tutor", f"{ref}/frase", seen)

    return sorted(seen.values(), key=lambda e: (e.lang, e.style, e.id))


def iter_missing(locutions: list[Locution], voice_dir: Path = VOICE_DIR) -> Iterator[Locution]:
    for entry in locutions:
        if not (voice_dir / entry.filename).exists():
            yield entry
