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
    "paso1Porque": ("Ti es o modelo da túa criatura. Non fai falta pronunciar perfecto: abonda con dicilas con gusto e sempre igual.",
                    "Tú eres el modelo de tu criatura. No hace falta pronunciar perfecto: basta con decirlas con gusto y siempre igual."),
    "paso2": ("Dias sempre no mesmo momento", "Dilas siempre en el mismo momento"),
    "paso2Porque": ("Se o inglés chega sempre no mesmo momento, a criatura sabe que vai pasar e espérao. Unha lingua apréndese oíndoa moitas veces.",
                    "Si el inglés llega siempre en el mismo momento, la criatura sabe que va a pasar y lo espera. Una lengua se aprende oyéndola muchas veces."),
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
    "rutaTexto": ("O que se traballa en cada idade, do máis sinxelo ao máis complexo. A túa criatura está no resaltado.",
                  "Lo que se trabaja en cada edad, de lo más sencillo a lo más complejo. Tu criatura está en el resaltado."),
    "espera": ("Que se espera", "Qué se espera"),
    "seResponde": ("Que dicir despois, segundo responda", "Qué decir después, según responda"),
    "silencio": ("Se non di nada", "Si no dice nada"),
    "linguaCasa": ("Se contesta na lingua da casa", "Si contesta en la lengua de casa"),
    "unhaPalabra": ("Se di unha palabra", "Si dice una palabra"),
    "gozar": ("Para gozar máis esta semana", "Para disfrutar más esta semana"),
    "sinais": ("Sinais de que vai ben", "Señales de que va bien"),
    "sinaisTexto": ("Non hai que apuntar nada nin compararse: cada criatura leva o seu ritmo.",
                    "No hay que apuntar nada ni compararse: cada criatura lleva su ritmo."),
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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    plan, cal, sig, xogos, steam = H.cargar()
    b = banco()
    idx = indice_de_significados(plan, b, sig)
    # La gramática del curso (tools/gen_gramatica.py): un punto por unidad.
    gram = json.loads((C / "gramatica" / "gramatica.json").read_text())
    puntos = {p["n"]: p for p in gram["puntos"]}
    # La categoría de una palabra del plan, si el banco la tiene.
    cat_en = {}
    for x in b.values():
        if x["que"] in ("noun", "verb", "adjective"):
            cat_en.setdefault(norm(x["en"]), x["que"])
    steam_tit = {e["id"]: e["titulo"] for e in
                 json.loads((C / "steam" / "steam_do_mes.json").read_text())["experimentos"]}
    contos = []
    for f in sorted((C / "biblioteca").glob("his_*.json")):
        contos += json.loads(f.read_text())
    saida = {"_doc": "Generado por tools/gen_leccions.py desde el plan curricular y "
                     "las unidades del mes; no se edita a mano.",
             "guia": {k: {"gl": g, "es": e} for k, (g, e) in GUIA.items()},
             "ruta": [{"curso": c, "titulo": {"gl": t[0], "es": t[1]},
                       "texto": {"gl": x[0], "es": x[1]}} for c, t, x in RUTA],
             "cursos": {}}
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
            tr = repartir(its, len(sems)) if its else [[] for _ in sems]
            trozos_plan[uid] = dict(zip(sems, tr))
        ensinado, unidades, calendario, anterior = set(), [], {}, []
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
            leccions, da_unidade = [], []
            for k in range(4):
                semana = k + 1
                novas, vistos = [], set()
                for p in trozos_mes[k] + [peza_de(it, t if t != "palabra" else
                                                  cat_en.get(norm(it["en"]), "palabra"), sig)
                                          for t, it in trozos_plan[uid].get((mes, semana), [])]:
                    nk = norm(p["en"])
                    if nk in ensinado or nk in vistos:
                        continue
                    vistos.add(nk)
                    novas.append(p)
                repaso = not novas
                repasa = [] if novas else (da_unidade or anterior)[-4:]
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
                conto = do_plan[kp % len(do_plan)] if do_plan else None
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
                dias = [
                    ("Escoita ti as palabras novas e dias co seu xesto.",
                     "Escucha tú las palabras nuevas y dilas con su gesto.", None),
                    (f"Fai o reto: {momento['gl'].lower()}.",
                     f"Haz el reto: {momento['es'].lower()}.", (r.get("frase") or {}).get("en")),
                    dia3,
                    ((f"Xogade a «{xogo_tit['gl']}».", f"Jugad a «{xogo_tit['es']}».", None)
                     if xogo_tit else ("Xogade co obxecto da semana, dicindo as palabras.",
                                       "Jugad con el objeto de la semana, diciendo las palabras.", None)),
                    ((f"Lede o conto «{conto['titulo']['gl']}».",
                      f"Leed el cuento «{conto['titulo']['es']}».", None)
                     if conto else ("Contade o que fixestes na semana, coas palabras en inglés.",
                                    "Contad lo que hicisteis en la semana, con las palabras en inglés.", None)),
                ]
                novas = [con_significado(p, idx) for p in novas]
                repasa = [con_significado(p, idx) for p in repasa]
                if r.get("frase"):
                    r["frase"] = con_significado(r["frase"], idx)
                fg = gram["ruta"][curso][str(mes)]["frases"][k]
                lid = f"{curso}.{n_mes:02d}.{semana}"
                leccions.append({
                    "id": lid,
                    "numero": semana,
                    "de": 4,
                    "tipo": "repaso" if repaso else "leccion",
                    "espera": {"gl": NIVEIS[k][0], "es": NIVEIS[k][1]},
                    # La frase de gramática de la semana.
                    "fraseGramatica": fg,
                    "xaSabe": [con_significado(dict(p), idx) for p in (da_unidade or anterior)[-8:]],
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
                })
                calendario.setdefault(str(mes), []).append(lid)
                for p in novas:
                    ensinado.add(norm(p["en"]))
                da_unidade += novas
            foco = FOCO.get(uid)
            pg = puntos[gram["ruta"][curso][str(mes)]["punto"]]
            unidades.append({
                "id": um["id"],
                "titulo": um["centroInteres"],
                "plan": {"id": uid, "titulo": pu["titulo"]},
                **({"foco": {"gl": foco[0], "es": foco[1]}} if foco else {}),
                "gramatica": {"n": pg["n"], "nivel": pg["nivel"], "titulo": pg["titulo"],
                              "paraFamilias": pg["paraFamilias"]},
                "obxectivos": [{"gl": o["gl"], "es": o["es"]} for o in pu.get("objetivos") or []],
                "leccions": leccions,
            })
            anterior = da_unidade or anterior
        saida["cursos"][curso] = {"unidades": unidades, "calendario": calendario}
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
