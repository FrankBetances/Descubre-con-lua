#!/usr/bin/env python3
"""Escribe las lecciones semanales de los cinco cursos (P11, Frank 27/10/2026).

    python3 tools/gen_leccions.py           # escribe
    python3 tools/gen_leccions.py --check   # falla si no está al día

Una sola fuente: el plan curricular de Frank (`assets/content/curriculo/`).
Cada curso es una fila de unidades del plan, y cada unidad, una fila de
lecciones de una semana, como dice el documento: 6 en 18-36 meses y 8 en 3-6
años. Lo que la unidad enseña (vocabulario, órdenes, fórmulas, estructuras) se
reparte entre sus lecciones, sin dejar nada fuera; las semanas que sobran en el
calendario de la unidad son de repaso, que es la recuperación espaciada del
propio documento.

Cada lección dice, en este orden: lo que ya debería saber (lo de las
lecciones anteriores), las palabras nuevas, cómo decirlas en casa (el reto),
el cuento de la unidad (de los 100 dialogados), el juego y qué mirar. Las
plantillas del reto son las de `tools/gen_hogar.py`.

Lo que NO entra en el camino de lecciones, por decisión de Frank: el banco de
4.000 palabras, las asambleas antiguas y las palabras del día. Siguen en la
app como consulta.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
import gen_hogar as H  # noqa: E402

C = H.C
SAIDA = C / "leccions" / "leccions.json"
MESES_ORDE = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]

# Lo que trabaja cada unidad del plan en gramática, tal cual lo dice el
# documento de Frank («Morfosintaxis y Estructuras Diana»,
# referencias/base/curriculo-vocabulario-infantil-2-6.txt, líneas 172, 192,
# 211, 229, 248 y 266). El castellano es el del documento; el gallego es
# traducción. Las unidades de 18-36 meses no traen ese apartado.
FOCO = {
    "T3.U3.1": ("Frases con preposicións de lugar («The car is on the block», «Put it under the bridge») e frases de quen fai, que fai e que pasa («I push and it falls»).",
                "Frases con preposiciones de lugar («The car is on the block», «Put it under the bridge») y frases de quién hace, qué hace y qué pasa («I push and it falls»)."),
    "T3.U3.2": ("Palabras para cantidades («More juice in my cup», «A full plate on the table»).",
                "Palabras para cantidades («More juice in my cup», «A full plate on the table»)."),
    "T3.U4.1": ("Frases de causa e efecto («Why…? Because the cat is sick») e de orde no tempo («First…, then…»).",
                "Frases de causa y efecto («Why…? Because the cat is sick») y de orden en el tiempo («First…, then…»)."),
    "T3.U4.2": ("Frases de condición e de tempo («When it rains, we need boots»; «Put your feet into the boots»).",
                "Frases de condición y de tiempo («When it rains, we need boots»; «Put your feet into the boots»)."),
    "T3.U5.1": ("Dicir para que se fai algo e por que («I am blending yellow and blue because I want to make green»); onde está («between the cup and the paper»).",
                "Decir para qué se hace algo y por qué («I am blending yellow and blue because I want to make green»); dónde está («between the cup and the paper»)."),
    "T3.U5.2": ("Frases que unen tempo e causa («We have to hurry because the train is leaving»).",
                "Frases que unen tiempo y causa («We have to hurry because the train is leaving»)."),
}

# Qué es cada pieza, dicho para una familia.
QUE = {
    "noun": ("Nome: unha cousa", "Nombre: una cosa"),
    "verb": ("Verbo: unha acción", "Verbo: una acción"),
    "adjective": ("Adxectivo: como é", "Adjetivo: cómo es"),
    "phrase": ("Frase para relacionarse", "Frase para relacionarse"),
    "complex": ("Expresión", "Expresión"),
    "palabra": ("Palabra nova", "Palabra nueva"),
    "orde": ("Orde: unha acción", "Orden: una acción"),
    "formula": ("Frase para relacionarse", "Frase para relacionarse"),
    "estructura": ("Estrutura de frase", "Estructura de frase"),
}

# La ruta de los cinco cursos (referencias/base/curriculo-vocabulario-infantil-2-6.txt:
# objetivos del Tramo 2, líneas 9-13, y evolución del Tramo 3, líneas 155-158).
# El documento trata 0-2 y 2-3 como un tramo, 18-36 meses: aquí 0-2 se queda
# en escuchar y hacer, y 2-3 añade las dos palabras juntas del objetivo 4.
RUTA = [
    ("curso_0_2", ("0-2 anos · Escoitar e facer", "0-2 años · Escuchar y hacer"),
     ("Nomes de cousas reais (water, boat) e verbos de acción que fai co corpo (jump, splash, stop). Entende e fai; aínda non ten que dicir.",
      "Nombres de cosas reales (water, boat) y verbos de acción que hace con el cuerpo (jump, splash, stop). Entiende y hace; todavía no tiene que decir.")),
    ("curso_2_3", ("2-3 anos · Dúas palabras xuntas", "2-3 años · Dos palabras juntas"),
     ("Os mesmos nomes e verbos, e as primeiras combinacións de dúas palabras: un adxectivo ou «more» co nome («big ball», «more water»).",
      "Los mismos nombres y verbos, y las primeras combinaciones de dos palabras: un adjetivo o «more» con el nombre («big ball», «more water»).")),
    ("curso_3_4", ("3-4 anos · Quendas e lugares", "3-4 años · Turnos y lugares"),
     ("Frases para xogar con outros («my turn», «your turn») e preposicións de lugar (in, on, under) en frases curtas.",
      "Frases para jugar con otros («my turn», «your turn») y preposiciones de lugar (in, on, under) en frases cortas.")),
    ("curso_4_5", ("4-5 anos · Por que e porque", "4-5 años · Por qué y porque"),
     ("Preguntar e explicar causas («why?», «because…»), ordenar no tempo («first…, then…») e máis posicións (behind, in front of, into, out of).",
      "Preguntar y explicar causas («why?», «because…»), ordenar en el tiempo («first…, then…») y más posiciones (behind, in front of, into, out of).")),
    ("curso_5_6", ("5-6 anos · Argumentar e xogar cos sons", "5-6 años · Argumentar y jugar con los sonidos"),
     ("Dicir por que e para que («because I want to…»), frases que unen tempo e causa, posicións máis finas (between, next to) e rimas para xogar cos sons.",
      "Decir por qué y para qué («because I want to…»), frases que unen tiempo y causa, posiciones más finas (between, next to) y rimas para jugar con los sonidos.")),
]

# Los cuatro niveles de logro del documento (líneas 352-355), uno por semana
# de la unidad: de entender con ayuda a usarlo solo.
NIVEIS = [
    ("Esta semana abonda con que o entenda co teu xesto.", "Esta semana basta con que lo entienda con tu gesto."),
    ("Esta semana, que o faga sen que lle fagas o xesto.", "Esta semana, que lo haga sin que le hagas el gesto."),
    ("Esta semana, que o diga contigo, nunha rutina ou nunha canción.", "Esta semana, que lo diga contigo, en una rutina o en una canción."),
    ("Esta semana, que o use só, xogando, sen que llo pidas.", "Esta semana, que lo use solo, jugando, sin que se lo pidas."),
]

DIAS = [("Luns", "Lunes"), ("Martes", "Martes"), ("Mércores", "Miércoles"),
        ("Xoves", "Jueves"), ("Venres", "Viernes")]

GUIA = {
    "comoFunciona": ("Cada semana, unhas poucas palabras novas en inglés, nun momento do día que xa tedes. Non é unha clase: son uns minutos de xogo.",
                     "Cada semana, unas pocas palabras nuevas en inglés, en un momento del día que ya tenéis. No es una clase: son unos minutos de juego."),
    "deOnde": ("Xa as coñece", "Ya las conoce"),
    "deOndeTexto": ("Das semanas anteriores. Se algunha non a recorda, dila ti tamén esta semana.",
                    "De las semanas anteriores. Si alguna no la recuerda, dila tú también esta semana."),
    "comezo": ("É a primeira semana: comezades de cero.", "Es la primera semana: empezáis de cero."),
    "aOnde": ("Ao final desta unidade", "Al final de esta unidad"),
    "pasos": ("Esta semana, en tres pasos", "Esta semana, en tres pasos"),
    "paso1": ("Escoita ti as palabras", "Escucha tú las palabras"),
    "paso1Repaso": ("Escoita ti as que volven", "Escucha tú las que vuelven"),
    "paso1Texto": ("Toca cada unha para oíla en inglés; con dous toques, oes o que quere dicir.",
                   "Toca cada una para oírla en inglés; con dos toques, oyes lo que quiere decir."),
    "paso1Porque": ("Ti es o modelo do teu neno ou da túa nena. Non fai falta pronunciar perfecto: abonda con dicilas con gusto e sempre igual.",
                    "Tú eres el modelo de tu niño o niña. No hace falta pronunciar perfecto: basta con decirlas con gusto y siempre igual."),
    "paso2": ("Dias sempre no mesmo momento", "Dilas siempre en el mismo momento"),
    "paso2Porque": ("Se o inglés chega sempre no mesmo momento, o neno ou a nena sabe que vai pasar e espérao. Unha lingua apréndese oíndoa moitas veces.",
                    "Si el inglés llega siempre en el mismo momento, el niño o la niña sabe que va a pasar y lo espera. Una lengua se aprende oyéndola muchas veces."),
    "paso3": ("Agarda e celebra", "Espera y celebra"),
    "paso3Espera": ("Despois de dicilo, conta {n} segundos en silencio, mirándoa.",
                    "Después de decirlo, cuenta {n} segundos en silencio, mirándola."),
    "paso3Porque": ("Responder leva tempo. Se se celebra o que fai, sen esixirlle nada, segue sendo un xogo e quere volver.",
                    "Responder lleva tiempo. Si se celebra lo que hace, sin exigirle nada, sigue siendo un juego y quiere volver."),
    "porque": ("Por que?", "¿Por qué?"),
    "foco": ("Que se traballa", "Qué se trabaja"),
    "doPlan": ("No plan curricular", "En el plan curricular"),
    "estaSemana": ("Esta semana", "Esta semana"),
    "dias": ("Cada día, unha cousa", "Cada día, una cosa"),
    "hoxe": ("HOXE", "HOY"),
    "ruta": ("A ruta dos cinco cursos", "La ruta de los cinco cursos"),
    "rutaTexto": ("O que se traballa en cada idade, do máis sinxelo ao máis complexo. O teu neno ou a túa nena está no resaltado.",
                  "Lo que se trabaja en cada edad, de lo más sencillo a lo más complejo. Tu niño o niña está en el resaltado."),
    "espera": ("Que se espera", "Qué se espera"),
    "seResponde": ("Que dicir despois, segundo responda", "Qué decir después, según responda"),
    "silencio": ("Se non di nada", "Si no dice nada"),
    "linguaCasa": ("Se contesta na lingua da casa", "Si contesta en la lengua de casa"),
    "unhaPalabra": ("Se di unha palabra", "Si dice una palabra"),
    "gozar": ("Para gozar máis esta semana", "Para disfrutar más esta semana"),
    "sinais": ("Sinais de que vai ben", "Señales de que va bien"),
    "sinaisTexto": ("Non hai que apuntar nada nin compararse: cada neno ou nena leva o seu ritmo.",
                    "No hay que apuntar nada ni compararse: cada niño o niña lleva su ritmo."),
    "seguinte": ("A semana que vén", "La semana que viene"),
    "seguinteUnidade": ("Despois vén a unidade", "Después viene la unidad"),
}


def items_da_unidade(u):
    """Lo que enseña la unidad, en el orden en que se presenta: las palabras
    primero y, entre ellas, las órdenes o fórmulas y las estructuras."""
    def con_en(xs):
        # Una orden del plan sin inglés (hay una en T2.U4) no se inventa.
        return [x for x in xs or [] if isinstance(x, dict) and x.get("en")]
    voc = [("palabra", x) for x in con_en(u.get("vocabulario"))]
    seg = [("orde", x) for x in con_en(u.get("accionsTPR"))] + \
          [("formula", x) for x in con_en(u.get("formulas"))]
    est = [("estructura", x) for x in con_en(u.get("estructuras"))]
    saida, i, j = [], 0, 0
    # Dos palabras por cada orden o fórmula, y las estructuras al final.
    while i < len(voc) or j < len(seg):
        saida += voc[i:i + 2]
        i += 2
        if j < len(seg):
            saida.append(seg[j])
            j += 1
    # La misma palabra como vocabulario y como orden («Splash» y «Splash!»)
    # se enseña una vez: se queda la que trae gesto.
    vistos, unicos = {}, []
    for t, x in saida + est:
        k = x["en"].strip("!.?¡¿ ").lower()
        if k in vistos:
            if isinstance(x.get("xesto"), dict) and not isinstance(unicos[vistos[k]][1].get("xesto"), dict):
                unicos[vistos[k]] = (t, x)
            continue
        vistos[k] = len(unicos)
        unicos.append((t, x))
    return unicos


def repartir(items, n):
    """`n` trozos seguidos, lo más iguales posible, sin perder ninguno."""
    base, resto = divmod(len(items), n)
    saida, k = [], 0
    for i in range(n):
        t = base + (1 if i < resto else 0)
        saida.append(items[k:k + t])
        k += t
    return saida


def peza(tipo, item, sig):
    s = H.significado(item, sig)
    p = {"tipo": tipo, "en": item["en"]}
    if s:
        p["gl"], p["es"] = s["gl"], s["es"]
    x = item.get("xesto")
    if isinstance(x, dict):
        p["xesto"] = {"gl": x["gl"], "es": x["es"]}
    return p


def mans_de(peza):
    if "xesto" in peza:
        return peza["xesto"]
    if peza.get("gl") and peza["tipo"] == "palabra":
        return {"gl": f"Sinala ou colle o que nomeas: {peza['gl'].rstrip('.!?')}.",
                "es": f"Señala o coge lo que nombras: {peza['es'].rstrip('.!?')}."}
    if peza["tipo"] == "formula":
        return {"gl": "Acompáñaa dun xesto claro: dar, recibir ou sinalar a quen lle toca.",
                "es": "Acompáñala de un gesto claro: dar, recibir o señalar a quien le toca."}
    return {"gl": "Ten na man aquilo do que falas e ensínallo mentres o dis.",
            "es": "Ten en la mano aquello de lo que hablas y enséñaselo mientras lo dices."}


def reto(curso, uid, fase, frase, prev, sig, mans):
    b = H.banda(curso)
    facer = H.QUE_FACER_0_2 if b == 0 else H.QUE_FACER
    (mgl, mes), (egl, ees) = H.MOMENTO[uid]
    en = frase["en"]
    s = H.significado(frase, sig)
    gl, es = facer[fase]
    return {
        "momento": {"gl": mgl, "es": mes},
        "escena": {"gl": egl, "es": ees},
        "minutos": H.MINUTOS[curso],
        "fase": fase,
        "nomeFase": dict(H.FASES)[fase],
        "frase": {"en": en, **(s or {})},
        "queFacer": {"gl": gl.format(en=en, prev=prev, oco=H.oco(en)),
                     "es": es.format(en=en, prev=prev, oco=H.oco(en))},
        "mans": mans,
        "esperaSegundos": H.ESPERA[curso],
        "nonPedir": {"gl": H.NON_PEDIR[b][0], "es": H.NON_PEDIR[b][1]},
        "recast": {k: {"gl": v[0].format(en=en), "es": v[1].format(en=en)}
                   for k, v in H.RECAST.items()},
    }


def banco():
    """id → pieza, del banco de los cinco cursos y del registro de frases."""
    b = {}
    for f in sorted((C / "tpr").glob("curso_*/tpr.*.json")):
        for sem in json.loads(f.read_text())["semanas"]:
            for p in sem["palabras"]:
                b[p["id"]] = {"en": p["en"], "gl": p.get("gl"), "es": p.get("es"),
                              "que": p.get("category") or "palabra",
                              "xesto": p.get("tprAction")}
    for fr in json.loads((C / "registro" / "frases.json").read_text())["frases"]:
        b[fr["id"]] = {"en": fr["en"], "que": "orde" if fr.get("tipo") == "orde"
                       else ("estructura" if fr.get("tipo") == "estructura" else "formula"),
                       "xesto": fr.get("accion")}
    return b


def banco_por_semana():
    """curso → (n.º de mes, semana) → palabras del banco del curso, en su
    orden: lo que la edad trae para esa semana, con significado y gesto."""
    saida = {}
    for f in sorted((C / "tpr").glob("curso_*/tpr.*.json")):
        j = json.loads(f.read_text())
        n_mes = int(f.name.split(".")[1])
        for sem in j["semanas"]:
            saida.setdefault(f.parent.name, {})[(n_mes, sem["semana"])] = [
                {"en": p["en"], "gl": p.get("gl"), "es": p.get("es"),
                 "que": p.get("category") or "palabra", "xesto": p.get("tprAction")}
                for p in sem["palabras"]]
    return saida


# O-20261028-7 (opción A de Frank): cada semana trae al menos estas palabras
# nuevas. Si el plan curricular no da tantas, se completan con las del banco
# de esa edad para ese mes y esa semana, nunca con «repaso».
# Los temas de 2-3 años, escritos por Claude Code (O-20261028-7): la unidad del
# mes comparte el centro de interés de la asamblea del primer ciclo con 0-2,
# y la lección no puede repetir el tema de otra edad.
TEMA_PROPIO = {"curso_2_3": {
    1: ("Ola, amigos: o círculo e o primeiro saúdo", "Hola, amigos: el círculo y el primer saludo"),
    2: ("Cabeza, xeonllos e pés: o corpo que baila e para", "Cabeza, rodillas y pies: el cuerpo que baila y se para"),
    3: ("O vento do outono e as follas do parque", "El viento de otoño y las hojas del parque"),
    4: ("Forte e baixiño: campás, choiva e o quentiño da casa", "Fuerte y bajito: campanas, lluvia y el calorcito de casa"),
    5: ("Abrigo, botas e cremalleira: vestirse para os charcos", "Abrigo, botas y cremallera: vestirse para los charcos"),
    6: ("O desfile do Entroido: voar, pisar e quedar quietos", "El desfile de Carnaval: volar, pisar y quedarse quietos"),
    7: ("Formas e cores na merenda: círculos, tomates e bólas", "Formas y colores en la merienda: círculos, tomates y bolas"),
    8: ("As sementes espertan: flores, sol e paxariños", "Las semillas despiertan: flores, sol y pajaritos"),
    9: ("Lávome eu só: xabón, auga e secar os dedos", "Me lavo solo: jabón, agua y secar los dedos"),
    10: ("As ondas da praia: peixes, barcos e ata logo", "Las olas de la playa: peces, barcos y hasta luego"),
}}

MINIMO_NOVAS = 3

# Cómo se habla cada semana, del modelo (assets/content/modelo/o_modelo.json):
# una técnica por fase. En 0-2 años, antes de que haya palabras que expandir,
# el habla paralela.
TECNICA = {"curso_0_2": ["parentese", "habla_paralela", "espera", "recast"]}
def cat_da_unidade(titulo_es):
    """La clase de palabra que trabaja la unidad de gramática, si trabaja una."""
    t = titulo_es.lower()
    if any(k in t for k in ("sustantiv", "contable")):
        return "noun"
    if "adjetiv" in t:
        return "adjective"
    if any(k in t for k in ("verbo", "presente", "pasado", "futuro", "imperativo", "obliga", "can ")):
        return "verb"
    return None


TECNICA_RESTO = ["parentese", "espera", "expansion", "recast"]

# Los cuentos dialogados son de una cohorte; cada edad lee los suyos. 0-2
# años no tiene cohorte propia: lee el microcuento de su mes.
COHORTE = {"curso_2_3": "2_3", "curso_3_4": "4_6", "curso_4_5": "4_6", "curso_5_6": "4_6"}


def norm(en):
    return en.strip("!.?¡¿ ").lower()


# El único inglés de las lecciones sin significado en ninguna fuente; lo
# escribe Claude Code y queda señalado aquí.
SIGNIFICADO_EXTRA = {"roll! / ball": ("Rodar / Pelota", "Rodar / Pelota")}


def indice_de_significados(plan, b, sig):
    """Lo que quiere decir cada inglés, de todas las fuentes, para que el
    doble toque diga algo en cada botón de la lección."""
    idx = dict(SIGNIFICADO_EXTRA)

    def add(en, gl, es):
        if en and gl and es:
            idx.setdefault(norm(en), (gl, es))
    for u in plan.values():
        for k in ("vocabulario", "accionsTPR", "formulas", "estructuras", "rimas", "frasesAdulta"):
            for x in u.get(k) or []:
                if isinstance(x, dict):
                    add(x.get("en"), x.get("gl"), x.get("es"))
    for x in b.values():
        add(x["en"], x.get("gl"), x.get("es"))
    for en, v in sig.items():
        if isinstance(v, dict):
            add(en, v.get("gl"), v.get("es"))
    return idx


def con_significado(p, idx):
    """`p` con gl/es si le faltan; nunca inventa: si no hay, lo deja."""
    if p.get("gl") and p.get("es"):
        return p
    s = idx.get(norm(p["en"]))
    return {**p, "gl": s[0], "es": s[1]} if s else p


def peza_de(item, que, sig):
    s = H.significado(item, sig) if not (item.get("gl") and item.get("es")) else \
        {"gl": item["gl"], "es": item["es"]}
    p = {"tipo": que, "en": item["en"],
         "que": {"gl": QUE.get(que, QUE["palabra"])[0], "es": QUE.get(que, QUE["palabra"])[1]}}
    if s:
        p["gl"], p["es"] = s["gl"], s["es"]
    x = item.get("xesto")
    if isinstance(x, dict) and x.get("gl"):
        p["xesto"] = {"gl": x["gl"], "es": x["es"]}
    return p


# Edades en las que cada palabra nueva ya sale en el cuento de su semana
# (O-20261101-1). Se entregan de una en una (R∞.6): primero 4-5 años.
CONTO_COMPLETO = {"curso_0_2", "curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"}
# El texto de cada cuento de la semana, por lección, para revisar.
CONTO_TEXTO = {}


def sen_puntos(t):
    return re.sub(r"[!.?¡¿,]", "", t).strip().lower()


def revisar(saida):
    """Lo que tumba el gate: un tema con el título de otro, una palabra nueva
    en dos edades o una semana sin nada nuevo."""
    fallos, titulos, donde = [], {}, {}
    for curso, c in saida["cursos"].items():
        for u in c["unidades"]:
            t = u["titulo"]["gl"]
            if t in titulos:
                fallos.append(f"«{t}»: tema de {titulos[t]} y de {curso}")
            titulos[t] = curso
            cu = cat_da_unidade(u["gramatica"]["titulo"]["es"])
            for l in u["leccions"]:
                is_repaso = l.get("tipo") == "repaso"
                if not is_repaso:
                    if cu and not any(p.get("tipo") == cu for p in l["novas"]):
                        fallos.append(f"{l['id']}: ninguna palabra nueva es de la clase de su unidad ({cu})")
                    if len(l["novas"]) < MINIMO_NOVAS:
                        fallos.append(f"{l['id']}: {len(l['novas'])} palabras nuevas")
                else:
                    if len(l["novas"]) > 1:
                        fallos.append(f"{l['id']}: semana de repaso con {len(l['novas'])} palabras nuevas (máx 1)")
                    if not l["repasa"]:
                        fallos.append(f"{l['id']}: semana de repaso sin palabras en repasa")
                if curso in CONTO_COMPLETO:
                    for p in l["novas"]:
                        if sen_puntos(p["en"]) not in CONTO_TEXTO.get(l["id"], ""):
                            fallos.append(f"{l['id']}: «{p['en']}» no sale en el cuento de su semana")
                dias = " ".join(d["texto"]["gl"] for d in l["dias"])
                for p in l["novas"]:
                    if f"«{p['en']}»" not in dias:
                        fallos.append(f"{l['id']}: «{p['en']}» no sale en ninguna actividad")
                    k = norm(p["en"])
                    if donde.get(k, curso) != curso:
                        fallos.append(f"«{p['en']}»: nueva en {donde[k]} y en {curso}")
                    donde.setdefault(k, curso)
    return fallos


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    plan, cal, sig, xogos, steam = H.cargar()
    b = banco()
    modelo = {x["clave"]: x for x in
              json.loads((C / "modelo" / "o_modelo.json").read_text())["seccions"]}
    bsem = banco_por_semana()
    idx = indice_de_significados(plan, b, sig)
    # La gramática del curso (tools/gen_gramatica.py): un punto por unidad.
    gram = json.loads((C / "gramatica" / "gramatica.json").read_text())
    puntos = {p["n"]: p for p in gram["puntos"]}
    # La categoría de una palabra del plan, si el banco la tiene.
    cat_en = {}
    for x in b.values():
        if x["que"] in ("noun", "verb", "adjective"):
            cat_en.setdefault(norm(x["en"]), x["que"])
    steam_exp = json.loads((C / "steam" / "steam_do_mes.json").read_text())["experimentos"]
    steam_tit = {e["id"]: e["titulo"] for e in steam_exp}
    # El eje de cada mes: su experimento STEAM, por edad.
    steam_mes = {(e["curso"], e["mes"]): e for e in steam_exp}
    # Las frases de gramática de cada semana, con su significado.
    for r_ in gram["ruta"].values():
        for m_ in r_.values():
            for f_ in m_["frases"]:
                if f_.get("gl") and f_.get("es"):
                    idx.setdefault(norm(f_["en"]), (f_["gl"], f_["es"]))
    for e in steam_exp:
        for o in e.get("ordes") or []:
            idx.setdefault(norm(o["en"]), (o["gl"], o["es"]))
    # El cuento de cada semana: uno por edad, mes y semana, con las palabras
    # del banco de esa semana dentro.
    conto_sem = {(h["cursoId"], int(h["mesNumero"]), int(h["semanaSugerida"])): h
                 for h in json.loads((C / "cuentos" / "historias_progresivas.json").read_text())
                 if h.get("semanaSugerida")}
    contos = []
    for f in sorted((C / "biblioteca").glob("his_*.json")):
        contos += json.loads(f.read_text())
    saida = {"_doc": "Generado por tools/gen_leccions.py desde el plan curricular y "
                     "las unidades del mes; no se edita a mano.",
             "guia": {k: {"gl": g, "es": e} for k, (g, e) in GUIA.items()},
             "ruta": [{"curso": c, "titulo": {"gl": t[0], "es": t[1]},
                       "texto": {"gl": x[0], "es": x[1]}} for c, t, x in RUTA],
             "cursos": {}}
    # Lo enseñado en las edades anteriores: ninguna palabra se enseña en dos
    # edades, y ningún cuento se lee en dos (O-20261028-7).
    ensinado_antes, contos_lidos, ultimas_do_curso = set(), set(), []
    for curso in H.CURSOS:
        # Las semanas de cada unidad del plan en el curso, para repartir su
        # contenido entre ellas sin repetir.
        semanas_plan = {}
        for mes in MESES_ORDE:
            for s_ in range(1, 5):
                semanas_plan.setdefault(cal[curso][str(mes)], []).append((mes, s_))
        trozos_plan = {}
        for uid, sems in semanas_plan.items():
            its = items_da_unidade(plan[uid])
            # Preferir semanas 1-3 (y las que ya citan la palabra en su cuento)
            # para dejar como mucho 1 palabra nueva en la semana 4 de cada mes.
            sems_ord = sorted(sems, key=lambda ms: (ms[1] == 4, MESES_ORDE.index(ms[0]), ms[1]))
            asig = {ms: [] for ms in sems}
            if its:
                w4_usadas = set()
                textos_uid = {
                    ms: sen_puntos(json.dumps(
                        (conto_sem.get((curso, MESES_ORDE.index(ms[0]) + 1, ms[1])) or {}).get("paginas", []),
                        ensure_ascii=False,
                    ))
                    for ms in sems
                }
                for idx_it, it in enumerate(its):
                    sp = sen_puntos(it[1]["en"])
                    cands_w = [ms for ms in sems_ord if sp in textos_uid[ms] and (ms[1] < 4 or ms not in w4_usadas)]
                    if not cands_w:
                        cands_w = [ms for ms in sems_ord if sp in textos_uid[ms]]
                    if not cands_w:
                        cands_w = [ms for ms in sems_ord if ms[1] < 4]
                    destino = min(cands_w, key=lambda ms: (ms[1] == 4 and ms in w4_usadas, ms[1] == 4, len(asig[ms])))
                    if destino[1] == 4:
                        w4_usadas.add(destino)
                    asig[destino].append(it)
            trozos_plan[uid] = asig
        ensinado, unidades, calendario = set(ensinado_antes), [], {}
        anterior = []
        leccions_curso, intro_sem, pezas_curso = [], {}, {}
        k_plan, ultimo_reto = {}, None
        for n_mes, mes in enumerate(MESES_ORDE, start=1):
            um = json.loads((C / "unidades_mes" / curso / f"unidade.{n_mes:02d}.json").read_text())
            assert um["mesCalendario"] == mes, (curso, mes)
            uid = cal[curso][str(mes)]
            pu = plan[uid]
            refs = [x["ref"] for x in um.get("nucleo") or []] + \
                   [x if isinstance(x, str) else x.get("ref") for x in um.get("descriptivas") or []] + \
                   [x["ref"] for x in um.get("ordenes") or []] + \
                   [x if isinstance(x, str) else x.get("ref") for x in um.get("formulas") or []] + \
                   ([um["estructura"] if isinstance(um["estructura"], str) else um["estructura"].get("ref")]
                    if um.get("estructura") else [])
            do_mes = [peza_de(b[r], b[r]["que"], sig) for r in refs if r in b]
            trozos_mes = repartir(do_mes, 4)
            hogar = um.get("hogar") or {}
            retos = hogar.get("retosCasa") or []
            do_plan = sorted((c for c in contos if c["unidade"] == uid), key=lambda c: c["id"])
            rimas = pu.get("rimas") or []
            frases = pu.get("frasesAdulta") or []
            xc = hogar.get("juegoCasa") or {}
            xogo_tit = (xogos[xc["xogo"]]["titulo"] if xc.get("xogo") in xogos
                        else steam_tit.get(xc.get("steam")))
            textos_mes = [
                sen_puntos(json.dumps((conto_sem.get((curso, n_mes, w + 1)) or {}).get("paginas", []), ensure_ascii=False))
                for w in range(4)
            ]
            cands_mes = [[] for _ in range(4)]
            vistos_mes = set()
            for k in range(4):
                sem_k = k + 1
                for p in trozos_mes[k] + [peza_de(it, t if t != "palabra" else
                                                  cat_en.get(norm(it["en"]), "palabra"), sig)
                                          for t, it in trozos_plan[uid].get((mes, sem_k), [])]:
                    nk = norm(p["en"])
                    if nk in ensinado or nk in vistos_mes:
                        continue
                    vistos_mes.add(nk)
                    sp = sen_puntos(p["en"])
                    if sp in textos_mes[k]:
                        cands_mes[k].append(p)
                    else:
                        destino = next((w for w in range(3) if sp in textos_mes[w]), k)
                        cands_mes[destino].append(p)
            if len(cands_mes[3]) > 1:
                quedan_w4 = []
                extras_w4 = []
                for p in cands_mes[3]:
                    sp = sen_puntos(p["en"])
                    destino = next((w for w in range(3) if sp in textos_mes[w]), None)
                    if destino is not None:
                        cands_mes[destino].append(p)
                    else:
                        extras_w4.append(p)
                if extras_w4:
                    quedan_w4.append(extras_w4[0])
                    for p in extras_w4[1:]:
                        cands_mes[2].append(p)
                cands_mes[3] = quedan_w4[:1]
            leccions, da_unidade, micro_usado = [], [], False
            for k in range(4):
                semana = k + 1
                novas = list(cands_mes[k])
                vistos = {norm(p["en"]) for p in novas}
                # Si el plan no da bastante, el banco de la edad para esa
                # semana, en su orden: es lo que esa edad trabaja ese mes.
                cs = conto_sem.get((curso, n_mes, semana))
                do_conto = {norm(w) for pg in (cs or {}).get("paginas", []) for w in pg.get("palabras", [])}
                da_semana = bsem.get(curso, {}).get((n_mes, semana), [])
                # Primero, las de la clase que trabaja la unidad de gramática;
                # luego, las que salen en el cuento de la semana.
                cu = cat_da_unidade(puntos[gram["ruta"][curso][str(mes)]["punto"]]["titulo"]["es"])
                if semana < 4:
                    for it in sorted(da_semana, key=lambda x: (x["que"] != cu, norm(x["en"]) not in do_conto)):
                        if len(novas) >= MINIMO_NOVAS and (not cu or any(p.get("tipo") == cu for p in novas)):
                            break
                        nk = norm(it["en"])
                        if nk in ensinado or nk in vistos or not (it.get("gl") and it.get("es")):
                            continue
                        vistos.add(nk)
                        novas.append(peza_de(it, it["que"], sig))
                repaso = (semana == 4) or (not novas)
                repasa = (da_unidade or anterior)[-4:] if repaso else []
                # El reto practica una palabra de ESTA semana, no otra de la
                # unidad del plan: si no, el tema del mes y el reto no casan.
                cand = [p for p in (novas or repasa) if p["en"] != ultimo_reto]
                alvo = (cand or novas or repasa or [None])[0]
                if alvo:
                    r = reto(curso, uid, H.FASES[k][0],
                             {"en": alvo["en"], **({"gl": alvo["gl"], "es": alvo["es"]}
                                                   if "gl" in alvo else {})},
                             (da_unidade or anterior or [alvo])[-1]["en"], sig, mans_de(alvo))
                    r["id"] = f"reto.{curso}.{mes:02d}.{semana}"
                else:
                    r = dict(retos[k]) if k < len(retos) else {}
                ultimo_reto = (r.get("frase") or {}).get("en")
                kp = k_plan.get(uid, 0)
                k_plan[uid] = kp + 1
                # El primer cuento de la unidad y de la cohorte de la edad que
                # nadie haya leído aún; 0-2 años, su microcuento del mes.
                coh = COHORTE.get(curso)
                libres = [c for c in do_plan if c.get("cohorte") == coh and c["id"] not in contos_lidos]
                conto = libres[0] if libres else None
                if conto:
                    contos_lidos.add(conto["id"])
                # El microcuento del mes, una sola vez en el mes.
                micro = (um.get("microcuento") or {}).get("titulo") \
                    if not conto and not micro_usado else None
                micro_usado = micro_usado or bool(micro)
                usar = ", ".join(f"«{p['en']}»" for p in novas[:3])
                # Todas: ninguna palabra nueva se queda fuera de una actividad.
                todas = ", ".join(f"«{p['en']}»" for p in novas)
                # Solo las que salen de verdad en el cuento de la semana.
                no_conto = [p["en"] for p in novas if norm(p["en"]) in do_conto][:3] or \
                    [w for pg in (cs or {}).get("paginas", []) for w in pg.get("palabras", [])][:3]
                usar_conto = ", ".join(f"«{w}»" for w in no_conto)
                cancion = (um.get("cancion") or {}).get("titulo")
                if cancion:
                    dia3 = (f"Cantade xuntos «{cancion}», con xestos.",
                            f"Cantad juntos «{cancion}», con gestos.", None)
                elif rimas:
                    ri = rimas[kp % len(rimas)]
                    dia3 = (f"Dicide xuntos a rima, con ritmo: «{ri['en']}».",
                            f"Decid juntos la rima, con ritmo: «{ri['en']}».", ri["en"])
                elif frases:
                    fr = frases[kp % len(frases)]
                    dia3 = (f"Mentres xogades, di ti esta frase: «{fr['en']}».",
                            f"Mientras jugáis, di tú esta frase: «{fr['en']}».", fr["en"])
                else:
                    dia3 = ("Repasade as palabras da semana, cantando.",
                            "Repasad las palabras de la semana, cantando.", None)
                momento = hogar.get("momento") or {"gl": "", "es": ""}
                st = steam_mes.get((curso, mes))
                fg = gram["ruta"][curso][str(mes)]["frases"][k]
                pasos = (st or {}).get("casa") or []
                ordes = (st or {}).get("ordes") or []
                paso = pasos[k] if k < len(pasos) else None
                orde = ordes[k % len(ordes)] if ordes else None
                dias = [
                    (f"Escoita ti as palabras novas, {todas}, e dias co seu xesto.",
                     f"Escucha tú las palabras nuevas, {todas}, y dilas con su gesto.", None),
                    (f"Fai o reto: {momento['gl'].lower()}, con «{(r.get('frase') or {}).get('en')}».",
                     f"Haz el reto: {momento['es'].lower()}, con «{(r.get('frase') or {}).get('en')}».",
                     (r.get("frase") or {}).get("en")),
                    ((f"STEAM «{st['titulo']['gl']}»: mentres o facedes, di ti a frase da unidade "
                      f"{gram['ruta'][curso][str(mes)]['punto']}: «{fg['en']}».",
                      f"STEAM «{st['titulo']['es']}»: mientras lo hacéis, di tú la frase de la unidad "
                      f"{gram['ruta'][curso][str(mes)]['punto']}: «{fg['en']}».", fg["en"])
                     if st else dia3),
                    ((f"STEAM «{st['titulo']['gl']}», paso {k % len(pasos) + 1}: {paso['gl']}",
                      f"STEAM «{st['titulo']['es']}», paso {k % len(pasos) + 1}: {paso['es']}",
                      orde["en"] if orde else None)
                     if st and paso else
                     (f"STEAM «{st['titulo']['gl']}»: facédeo outra vez, xuntos, e mirade isto: "
                      f"{st['observar']['gl']}",
                      f"STEAM «{st['titulo']['es']}»: hacedlo otra vez, juntos, y mirad esto: "
                      f"{st['observar']['es']}", orde["en"] if orde else None)
                     if st and st.get("observar") else
                     (f"Xogade a «{xogo_tit['gl']}».", f"Jugad a «{xogo_tit['es']}».", None)
                     if xogo_tit else ("Xogade co obxecto da semana, dicindo as palabras.",
                                       "Jugad con el objeto de la semana, diciendo las palabras.", None)),
                    ((f"Lede o conto da semana, «{cs['titulo']['gl']}»: nel saen {usar_conto}.",
                      f"Leed el cuento de la semana, «{cs['titulo']['es']}»: en él salen {usar_conto}.", None)
                     if cs else
                     (f"Lede o conto «{conto['titulo']['gl']}».",
                      f"Leed el cuento «{conto['titulo']['es']}».", None)
                     if conto else
                     (f"Mirade o microcuento «{micro['gl']}» e sinalade o que nomeades.",
                      f"Mirad el microcuento «{micro['es']}» y señalad lo que nombráis.", None)
                     if micro else (f"Contade o que fixestes na semana, dicindo {usar}.",
                                    f"Contad lo que hicisteis en la semana, diciendo {usar}.", None)),
                ]
                novas = [con_significado(p, idx) for p in novas]
                repasa = [con_significado(p, idx) for p in repasa]
                if r.get("frase"):
                    r["frase"] = con_significado(r["frase"], idx)
                lid = f"{curso}.{n_mes:02d}.{semana}"
                CONTO_TEXTO[lid] = sen_puntos(json.dumps((cs or {}).get("paginas", []), ensure_ascii=False))
                idx_sem = len(leccions_curso)
                for p in novas:
                    nk = norm(p["en"])
                    intro_sem.setdefault(nk, idx_sem)
                    pezas_curso[nk] = dict(p)
                lec_obj = {
                    "id": lid,
                    "numero": semana,
                    "de": 4,
                    "tipo": "repaso" if repaso else "leccion",
                    "espera": {"gl": NIVEIS[k][0], "es": NIVEIS[k][1]},
                    # La frase de gramática de la semana.
                    "fraseGramatica": fg,
                    # Cómo hablar esta semana: la técnica del modelo y sus dos
                    # primeros pasos.
                    "comoFalar": (lambda t: {"clave": t["clave"], "titulo": t["titulo"],
                                             "como": t["como"][:2]})(
                        modelo[TECNICA.get(curso, TECNICA_RESTO)[k]]),
                    "xaSabe": [],
                    "novas": novas,
                    "repasa": [dict(p) for p in repasa],
                    "reto": {**r, "momento": momento,
                             "escena": hogar.get("escena") or {"gl": "", "es": ""},
                             "minutos": hogar.get("minutos") or 5},
                    "conto": conto["id"] if conto else None,
                    "xogo": xc,
                    "queMirar": hogar.get("queObservarCasa") or [],
                    "dias": [{"dia": {"gl": g, "es": e}, "texto": {"gl": tg, "es": te},
                              **(con_significado({"en": en}, idx) if en else {})}
                             for (g, e), (tg, te, en) in zip(DIAS, dias)],
                }
                leccions.append(lec_obj)
                leccions_curso.append(lec_obj)
                calendario.setdefault(str(mes), []).append(lid)
                for p in novas:
                    ensinado.add(norm(p["en"]))
                da_unidade += novas
            foco = FOCO.get(uid)
            pg = puntos[gram["ruta"][curso][str(mes)]["punto"]]
            unidades.append({
                "id": um["id"],
                "titulo": ({"gl": TEMA_PROPIO[curso][n_mes][0], "es": TEMA_PROPIO[curso][n_mes][1]}
                           if n_mes in TEMA_PROPIO.get(curso, {}) else um["centroInteres"]),
                "plan": {"id": uid, "titulo": pu["titulo"]},
                **({"steam": {"id": steam_mes[(curso, mes)]["id"],
                              "titulo": steam_mes[(curso, mes)]["titulo"]}}
                   if (curso, mes) in steam_mes else {}),
                **({"foco": {"gl": foco[0], "es": foco[1]}} if foco else {}),
                "gramatica": {"n": pg["n"], "nivel": pg["nivel"], "titulo": pg["titulo"],
                              "paraFamilias": pg["paraFamilias"]},
                # De dónde viene y a dónde va: la unidad de gramática de antes
                # y la de después, en el orden de Frank.
                **({"gramaticaAntes": {"n": pg["n"] - 1, "nivel": puntos[pg["n"] - 1]["nivel"],
                                       "titulo": puntos[pg["n"] - 1]["titulo"]}}
                   if pg["n"] > 1 else {}),
                **({"gramaticaDespois": {"n": pg["n"] + 1, "nivel": puntos[pg["n"] + 1]["nivel"],
                                         "titulo": puntos[pg["n"] + 1]["titulo"]}}
                   if pg["n"] < 48 else {}),
                "obxectivos": [{"gl": o["gl"], "es": o["es"]} for o in pu.get("objetivos") or []],
                "leccions": leccions,
            })
            anterior = da_unidade or anterior
        # Repaso espaciado en el aula (+1, +2, +4, +8, +16 semanas; e +3 nas
        # últimas semanas para que a semana 35 complete as 4 voltas antes de xuño).
        for idx_sem, lec_obj in enumerate(leccions_curso):
            due_rep = [nk for nk, j in intro_sem.items()
                       if idx_sem - j in (1, 2)]
            due_xa = [nk for nk, j in intro_sem.items()
                      if idx_sem - j in (4, 8, 16)
                      or (j >= len(leccions_curso) - 5 and idx_sem - j == 3)]
            if idx_sem == len(leccions_curso) - 1:
                extra_end = [nk for nk, j in intro_sem.items()
                             if idx_sem - j in (5, 6, 7)]
                due_xa = due_xa + [nk for nk in extra_end if nk not in due_rep and nk not in due_xa]
            if lec_obj["tipo"] == "repaso":
                lec_obj["repasa"] = [dict(pezas_curso[nk]) for nk in due_rep]
                lec_obj["xaSabe"] = [dict(pezas_curso[nk]) for nk in due_xa]
                rep_str = ", ".join(f"«{p['en']}»" for p in lec_obj["repasa"][:4])
                if lec_obj["novas"]:
                    nova_str = f"«{lec_obj['novas'][0]['en']}»"
                    lec_obj["dias"][0]["texto"] = {
                        "gl": f"Escoita ti a palabra nova, {nova_str}, e repasa {rep_str} co seu xesto.",
                        "es": f"Escucha tú la palabra nueva, {nova_str}, y repasa {rep_str} con su gesto.",
                    }
                else:
                    lec_obj["dias"][0]["texto"] = {
                        "gl": f"Escoita ti as palabras que volven, {rep_str}, e dias co seu xesto.",
                        "es": f"Escucha tú las palabras que vuelven, {rep_str}, y dilas con su gesto.",
                    }
            else:
                due_all = [nk for nk, j in intro_sem.items()
                           if idx_sem - j in (1, 2, 4, 8, 16)
                           or (j >= len(leccions_curso) - 5 and idx_sem - j == 3)]
                lec_obj["xaSabe"] = [dict(pezas_curso[nk]) for nk in due_all]
                lec_obj["repasa"] = []

        # O-20261126-5 (punto 6): lo que llega del plan curricular con
        # palabras ajenas a la edad, por las de tools/vocab_idade.py.
        import vocab_idade as VI  # noqa: E402
        _mapa_vi = json.loads((C / "laminas" / "palabras_laminas.json").read_text(encoding="utf-8"))["pezas"]
        for u_obj in unidades:
            VI.sustituir_leccions(curso, u_obj["leccions"], _mapa_vi)
        ruts_m2 = (
            ("bano", "No baño", "En el baño", "mentres botas a auga", "mientras echas el agua"),
            ("comida", "Na comida", "En la comida", "ao sentar á mesa", "al sentar a la mesa"),
            ("coche", "No coche", "En el coche", "mirando pola fiestra na cadeira", "mirando por la ventana en la silla"),
            ("vestirse", "Ao vestirse", "Al vestirse", "mentres pomos a roupa", "mientras ponemos la ropa"),
            ("durmir", "Antes de durmir", "Antes de dormir", "con voz suave antes do conto", "con voz suave antes del cuento"),
            ("parque", "No parque", "En el parque", "ao aire libre co seu xesto", "al aire libre con su gesto"),
        )
        _todas_l = [l for u_ in unidades for l in u_["leccions"]]
        proxima_frase = {a_["id"]: (b_.get("fraseGramatica") or {}) for a_, b_ in zip(_todas_l, _todas_l[1:])}
        sem_index = 0
        for u_obj in unidades:
            st_tit = (u_obj.get("steam") or {}).get("titulo") or {"gl": u_obj["titulo"]["gl"], "es": u_obj["titulo"]["es"]}
            st_gl, st_es = st_tit["gl"], st_tit["es"]
            for l_obj in u_obj["leccions"]:
                sem_index += 1
                foco = (l_obj.get("novas") or l_obj.get("repasa") or [{}])[0]
                foco_en = foco.get("en") or (l_obj.get("fraseGramatica") or {}).get("en") or "Look!"
                foco_xesto = foco.get("xesto") or {
                    "gl": f"Sinala e repite «{foco_en}» con calma.",
                    "es": f"Señala y repite «{foco_en}» con calma.",
                }
                fg_en = (l_obj.get("fraseGramatica") or {}).get("en") or foco_en
                nov_en = ", ".join(p["en"] for p in (l_obj.get("novas") or [])[:3]) or foco_en
                rep_en = ", ".join(p["en"] for p in (l_obj.get("repasa") or l_obj.get("xaSabe") or [])[:2]) or foco_en

                def _ruts_capa(capa_tag_gl: str, capa_tag_es: str, palabra_en: str) -> dict:
                    return {
                        rk: {
                            "gl": f"{lgl} (sem. {sem_index} · «{st_gl}» · {capa_tag_gl}): \"{palabra_en}\", {acc_gl}.",
                            "es": f"{les} (sem. {sem_index} · «{st_es}» · {capa_tag_es}): \"{palabra_en}\", {acc_es}.",
                            "en": palabra_en,
                            "xesto": foco_xesto,
                        }
                        for rk, lgl, les, acc_gl, acc_es in ruts_m2
                    }

                # O-20261126-5 (punto 5): cada capa trae SUS piezas reales.
                # «Máis»: tres palabras más de la misma semana del banco de la
                # edad (salen en el cuento de esa semana y tienen lámina y voz)
                # y la frase de la semana siguiente, un peldaño más. «Apoio»:
                # la pieza nueva más corta, junto a una que ya conoce.
                def _pz(x):
                    q = {k: x[k] for k in ("en", "gl", "es", "xesto") if x.get(k)}
                    m = _mapa_vi.get(x["en"].lower().strip(" .!?"))
                    if m:
                        q["lamina"] = m["clave"]
                    return q
                n_u, w_l = (int(v) for v in l_obj["id"].split(".")[1:3])
                xa = {norm(x["en"]) for k in ("novas", "xaSabe", "repasa") for x in l_obj.get(k) or []}
                texto_c = CONTO_TEXTO.get(l_obj["id"], "")
                banco_w = [x for x in bsem.get(curso, {}).get((n_u, w_l), [])
                           if norm(x["en"]) not in xa and x.get("gl") and x.get("es")
                           and _mapa_vi.get(x["en"].lower().strip(" .!?"))]
                banco_w.sort(key=lambda x: sen_puntos(x["en"]) not in texto_c)
                mais_pz = [_pz(x) for x in banco_w[:3]]
                seg = proxima_frase.get(l_obj["id"]) or (l_obj.get("fraseGramatica") or {})
                fr_mais = seg.get("en") or fg_en
                novas_l = l_obj.get("novas") or l_obj.get("repasa") or []
                curta = min(novas_l, key=lambda x: len(x["en"].split())) if novas_l else {"en": foco_en}
                coñecida = next(iter(l_obj.get("xaSabe") or []), None)
                apoio_pz = [_pz(curta)] + ([_pz(coñecida)] if coñecida else [])
                def _lista(xs, y):
                    n_ = [f"«{x['en']}»" for x in xs]
                    return n_[0] if len(n_) == 1 else ", ".join(n_[:-1]) + y + n_[-1]
                l_obj["capas"] = {
                    "nucleo": {
                        "gl": f"Semana {sem_index} · «{st_gl}»: practica o núcleo ({nov_en}) coa frase «{fg_en}».",
                        "es": f"Semana {sem_index} · «{st_es}»: practica el núcleo ({nov_en}) con la frase «{fg_en}».",
                        "en": fg_en,
                        "pezas": [_pz(x) for x in novas_l],
                        "rutinas": _ruts_capa("núcleo", "núcleo", foco_en),
                    },
                    "mais": {
                        "gl": (f"«{st_gl}», semana {sem_index}, para quen xa as di: engade {_lista(mais_pz, ' e ')}, que saen no conto, "
                               f"e proba a frase do paso seguinte, «{fr_mais}»." if mais_pz else
                               f"«{st_gl}», semana {sem_index}, para quen xa as di: proba a frase do paso seguinte, «{fr_mais}»."),
                        "es": (f"«{st_es}», semana {sem_index}, para quien ya las dice: añade {_lista(mais_pz, ' y ')}, que salen en el cuento, "
                               f"y prueba la frase del paso siguiente, «{fr_mais}»." if mais_pz else
                               f"«{st_es}», semana {sem_index}, para quien ya las dice: prueba la frase del paso siguiente, «{fr_mais}»."),
                        "en": fr_mais,
                        "pezas": mais_pz,
                        "rutinas": _ruts_capa("máis", "más", (mais_pz or [{"en": fr_mais}])[0]["en"]),
                    },
                    "apoio": {
                        "gl": (f"«{st_gl}», semana {sem_index}, con calma: só «{curta['en']}», co seu xesto"
                               + (f", xunto a «{coñecida['en']}», que xa coñece." if coñecida else ".")),
                        "es": (f"«{st_es}», semana {sem_index}, con calma: solo «{curta['en']}», con su gesto"
                               + (f", junto a «{coñecida['en']}», que ya conoce." if coñecida else ".")),
                        "en": curta["en"],
                        "pezas": apoio_pz,
                        "rutinas": _ruts_capa("apoio", "apoyo", curta["en"]),
                    },
                }

        saida["cursos"][curso] = {"unidades": unidades, "calendario": calendario}
        ensinado_antes |= ensinado
        ultimas_do_curso = []
    # O-20261111-2: cada pieza enseñada, con su lámina (tools/gen_laminas_palabras.py).
    mapa_laminas = json.loads((Path(__file__).resolve().parent.parent / "assets/content/laminas/palabras_laminas.json").read_text(encoding="utf-8"))["pezas"] \
        if (Path(__file__).resolve().parent.parent / "assets/content/laminas/palabras_laminas.json").exists() else {}
    for c in saida["cursos"].values():
        for u in c["unidades"]:
            for l in u["leccions"]:
                pezas = [p for k in ("xaSabe", "novas", "repasa") for p in l.get(k) or []]
                if l.get("fraseGramatica"):
                    l["fraseGramatica"] = dict(l["fraseGramatica"])
                    pezas.append(l["fraseGramatica"])
                for p in pezas:
                    m = mapa_laminas.get(p["en"].lower().strip(" .!?"))
                    if m:
                        p["lamina"] = m["clave"]
    fallos = revisar(saida)
    if fallos:
        print("FALLO (O-20261028-7):\n  " + "\n  ".join(fallos[:20]))
        return 1
    texto = json.dumps(saida, ensure_ascii=False, indent=1) + "\n"
    if a.check:
        if not SAIDA.exists() or SAIDA.read_text() != texto:
            print("FALLO: leccions.json no está al día (python3 tools/gen_leccions.py)")
            return 1
        print("OK: lecciones al día.")
        return 0
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    SAIDA.write_text(texto)
    n = sum(len(u["leccions"]) for c in saida["cursos"].values() for u in c["unidades"])
    print(f"OK: {n} semanas en 5 cursos.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
