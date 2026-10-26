#!/usr/bin/env python3
"""Escribe el bloque `hogar` de las 50 unidades del mes (F5, apartado 8.3 de
`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`).

    python3 tools/gen_hogar.py           # escribe
    python3 tools/gen_hogar.py --check   # falla si alguna unidad no está al día

Cada mes trae cuatro retos de casa, uno por semana, en la progresión
descubrir, practicar, combinar y consolidar. La frase de cada reto sale del
plan curricular de Frank para ese curso y mes (`assets/content/curriculo/`),
que es también de donde sale el núcleo que enseña la app y donde ya tiene voz:
así la casa dice lo mismo que el aula y el botón siempre suena.

El momento del día es UNO por mes, el mismo las cuatro semanas (guía estable,
punto 3: una lengua, una rutina), y sale de la unidad del plan curricular del
mes, que es la que da el tema.

La lectura en casa es el microcuento de la unidad, que ya trae una pregunta por
lámina (`casa`); aquí solo se cita. El juego se cita de `xogos_fogar.json` si
casa con el tema y la edad, y si no, del apartado de casa del STEAM del mes.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
C = ROOT / "assets" / "content"
CURSOS = ["curso_0_2", "curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
IDADE = {"curso_0_2": 0, "curso_2_3": 2, "curso_3_4": 3, "curso_4_5": 4, "curso_5_6": 5}
ESPERA = {"curso_0_2": 3, "curso_2_3": 5, "curso_3_4": 5, "curso_4_5": 5, "curso_5_6": 5}

FASES = [
    ("descubrir", {"gl": "Descubrir", "es": "Descubrir"}),
    ("practicar", {"gl": "Practicar", "es": "Practicar"}),
    ("combinar", {"gl": "Combinar", "es": "Combinar"}),
    ("consolidar", {"gl": "Consolidar", "es": "Consolidar"}),
]

# Un momento de casa por unidad del plan curricular, con lo que hay a mano en
# él: el tema del mes es el de esa unidad (F11), así que el momento también.
MOMENTO = {
    "T2.U1": (("No baño, coa bañeira ou o lavabo", "En el baño, con la bañera o el lavabo"),
              ("Un vaso de plástico e unha esponxa", "Un vaso de plástico y una esponja")),
    "T2.U2": (("No paseo, ao recoller follas e pedras", "En el paseo, al recoger hojas y piedras"),
              ("Unha bolsa de tea para os tesouros", "Una bolsa de tela para los tesoros")),
    "T2.U3": (("Na merenda", "En la merienda"),
              ("A froita da merenda", "La fruta de la merienda")),
    "T2.U4": (("No baño, ao lavar as mans", "En el baño, al lavarse las manos"),
              ("O xabón e a toalla", "El jabón y la toalla")),
    "T2.U5": (("No xogo do chan, antes de durmir", "En el juego del suelo, antes de dormir"),
              ("Un peluche de animal e unha manta", "Un peluche de animal y una manta")),
    "T2.U6": (("Ao recoller os xoguetes", "Al recoger los juguetes"),
              ("Unha caixa de cartón e unha pelota", "Una caja de cartón y una pelota")),
    "T3.U3.1": (("No xogo de construír, despois da merenda", "En el juego de construir, después de la merienda"),
                ("Bloques, caixas ou envases baleiros para amorear", "Bloques, cajas o envases vacíos para apilar")),
    "T3.U3.2": (("Ao poñer a mesa", "Al poner la mesa"),
                ("Pratos, vasos e culleres de verdade", "Platos, vasos y cucharas de verdad")),
    "T3.U4.1": (("No xogo cos peluches, antes do baño", "En el juego con los peluches, antes del baño"),
                ("Un peluche e unha venda ou un pano", "Un peluche y una venda o un pañuelo")),
    "T3.U4.2": (("Ao vestirse para saír, mirando pola fiestra", "Al vestirse para salir, mirando por la ventana"),
                ("O chuvasqueiro e as botas", "El chubasquero y las botas")),
    "T3.U5.1": (("Na mesa, pintando xuntos", "En la mesa, pintando juntos"),
                ("Un papel grande e unha soa cor para compartir", "Un papel grande y un solo color para compartir")),
    "T3.U5.2": (("Ao preparar unha saída ou a mochila", "Al preparar una salida o la mochila"),
                ("Unha mochila e un billete feito por vós", "Una mochila y un billete hecho por vosotros")),
}
MINUTOS = {"curso_0_2": 3, "curso_2_3": 8, "curso_3_4": 8, "curso_4_5": 8, "curso_5_6": 10}

# El juego de casa de cada unidad del plan curricular, si alguno casa con su
# tema; si ninguno casa con la edad, el apartado de casa del STEAM del mes.
XOGO_DA_UNIDADE = {
    "T2.U1": ["xogo_02_barco_samil", "xogo_04_cuncha_escoita"],
    "T2.U2": ["xogo_09_caixa_sons_texturas", "xogo_01_caza_tesouro"],
    "T2.U3": ["xogo_09_caixa_sons_texturas"],
    "T2.U4": ["xogo_06_masaxe_72bpm", "xogo_05_espello_corpo"],
    "T2.U5": ["xogo_06_masaxe_72bpm", "xogo_03_xigante_formiga"],
    "T2.U6": ["xogo_10_eco_pes_mans"],
    "T3.U3.1": ["xogo_03_xigante_formiga"],
    "T3.U3.2": [],
    "T3.U4.1": ["xogo_05_espello_corpo"],
    "T3.U4.2": [],
    "T3.U5.1": [],
    "T3.U5.2": ["xogo_07_circuito_5palabras"],
}

QUE_FACER = {
    "descubrir": ("Dio ti mentres o fas, cara a cara e á súa altura: «{en}». Só ten que escoitar e mirar.",
                  "Dilo tú mientras lo haces, cara a cara y a su altura: «{en}». Solo tiene que escuchar y mirar."),
    "practicar": ("Di «{en}» e fai o xesto á vez. Agarda e, se o fai, facédeo xuntos outra vez.",
                  "Di «{en}» y haz el gesto a la vez. Espera y, si lo hace, hacedlo juntos otra vez."),
    "combinar": ("Xunta a frase desta semana coa da semana pasada nun xogo curto: «{en}» e, despois, «{prev}».",
                 "Junta la frase de esta semana con la de la semana pasada en un juego corto: «{en}» y, después, «{prev}»."),
    "consolidar": ("Di o comezo, «{oco}…», e deixa o oco. Se o completa co corpo ou cunha palabra, celébrao e di a frase enteira.",
                   "Di el comienzo, «{oco}…», y deja el hueco. Si lo completa con el cuerpo o con una palabra, celébralo y di la frase entera."),
}
# Antes de los 18 meses no se pregunta ni se deja hueco: persona delante,
# habla paralela, espera y rutina (apartado 7 de la arquitectura).
QUE_FACER_0_2 = {
    "descubrir": QUE_FACER["descubrir"],
    "practicar": ("Di «{en}» e fai o xesto sobre o seu corpo, amodo, mentres o miras aos ollos.",
                  "Di «{en}» y haz el gesto sobre su cuerpo, despacio, mientras le miras a los ojos."),
    "combinar": ("Dio noutro momento do día co mesmo xesto, e tamén a da semana pasada: «{en}», «{prev}».",
                 "Dilo en otro momento del día con el mismo gesto, y también la de la semana pasada: «{en}», «{prev}»."),
    "consolidar": ("Di «{en}» e agarda. Se se xira, sorrí ou move o corpo, xa respondeu: devólvello cun sorriso.",
                   "Di «{en}» y espera. Si se gira, sonríe o mueve el cuerpo, ya ha respondido: devuélveselo con una sonrisa."),
}
NON_PEDIR = {
    0: ("Non se lle pide nada: mirar e sentir xa é a resposta.",
        "No se le pide nada: mirar y sentir ya es la respuesta."),
    2: ("Non hai que dicilo: abonda con que o faga co corpo ou colla o obxecto.",
        "No hay que decirlo: basta con que lo haga con el cuerpo o coja el objeto."),
    3: ("Non hai que dicilo nin pasalo á lingua da casa: se o fai co corpo, xa respondeu.",
        "No hay que decirlo ni pasarlo a la lengua de casa: si lo hace con el cuerpo, ya ha respondido."),
    4: ("Non é unha proba: se responde na lingua da casa, tamén vale, e o xogo segue.",
        "No es una prueba: si responde en la lengua de casa, también vale, y el juego sigue."),
}
RECAST = {
    "silencio": ("Fai ti o xesto e volve dicir «{en}» amodo, sorrindo, e segue co xogo.",
                 "Haz tú el gesto y vuelve a decir «{en}» despacio, sonriendo, y sigue con el juego."),
    "linguaCasa": ("Acolle o que di na lingua da casa, asente e devólvello en inglés: «{en}».",
                   "Acoge lo que dice en la lengua de casa, asiente y devuélveselo en inglés: «{en}»."),
    "unhaPalabra": ("Celébrao e engade o que falta: «Yes! {en}».",
                    "Celébralo y añade lo que falta: «Yes! {en}»."),
}
OBSERVAR = {
    0: [("Vólvese ou mira cando oe a frase", "Se gira o mira cuando oye la frase"),
        ("Sorrí, balbucea ou move o corpo co xesto", "Sonríe, balbucea o mueve el cuerpo con el gesto")],
    2: [("Fai o xesto cando oe «{en}»", "Hace el gesto cuando oye «{en}»"),
        ("Colle ou sinala o obxecto", "Coge o señala el objeto"),
        ("Anticipa o momento: xa sabe que vén o inglés", "Anticipa el momento: ya sabe que llega el inglés")],
    3: [("Fai o xesto cando oe «{en}»", "Hace el gesto cuando oye «{en}»"),
        ("Usa unha palabra ou unha fórmula no xogo, na lingua que sexa", "Usa una palabra o una fórmula en el juego, en la lengua que sea"),
        ("Busca o momento do inglés ou o propón", "Busca el momento del inglés o lo propone")],
    4: [("Completa a frase co corpo ou cunha palabra", "Completa la frase con el cuerpo o con una palabra"),
        ("Usa a frase noutro xogo, sen que llo propoñas", "Usa la frase en otro juego, sin que se lo propongas"),
        ("Conta o que pasa mesturando linguas", "Cuenta lo que pasa mezclando lenguas")],
}


def banda(curso):
    a = IDADE[curso]
    return 0 if a == 0 else 2 if a == 2 else 3 if a == 3 else 4


def cargar():
    plan = {}
    for f in ("tramo_18_36.json", "tramo_3_6.json"):
        for u in json.loads((C / "curriculo" / f).read_text())["unidades"]:
            plan[u["id"]] = u
    cal = json.loads((C / "curriculo" / "calendario_curricular.json").read_text())["cursos"]
    sig = json.loads((C / "significados" / "significados.json").read_text())["significados"]
    xogos = {x["id"]: x for x in json.loads((C / "xogos_fogar.json").read_text())["xogos"]}
    steam = {(e["curso"], e["mes"]): e["id"]
             for e in json.loads((C / "steam" / "steam_do_mes.json").read_text())["experimentos"]}
    return plan, cal, sig, xogos, steam


def mes_dentro(cal, curso, mes):
    uid = cal[curso][str(mes)]
    meses = [m for m in MESES if cal[curso][str(m)] == uid]
    return uid, meses.index(mes)


def significado(item, sig):
    if item.get("gl") and item.get("es"):
        return {"gl": item["gl"], "es": item["es"]}
    for k in (item["en"], item["en"].rstrip("!.?"), item["en"].rstrip("!.?") + "!"):
        if k in sig:
            return sig[k]
    return None


def oco(en):
    """La frase sin su última palabra: lo que dice la adulta antes del hueco."""
    palabras = en.rstrip("!.?").split()
    return " ".join(palabras[:-1]) if len(palabras) > 1 else palabras[0][:1]


def xoga(xogo, curso):
    lo, hi = (int(x) for x in xogo["idade"].split()[0].split("-"))
    a = IDADE[curso]
    return lo <= max(a, 1) and a + 1 <= hi


def hogar(curso, mes, unidade, plan, cal, sig, xogos, steam, anterior):
    uid, n = mes_dentro(cal, curso, mes)
    u = plan[uid]
    voc = u.get("vocabulario") or []
    # 18-36: órdenes TPR con su gesto; 3-6: fórmulas de turno (apartado 3).
    seg = u.get("accionsTPR") or u.get("formulas") or []
    fra = u.get("frasesAdulta") or []
    escollidas = [
        ("palabra", voc[(2 * n) % len(voc)]),
        ("orde" if u.get("accionsTPR") else "formula", seg[n % len(seg)]),
        ("frase", fra[n % len(fra)]),
        ("frase", fra[(n + 1) % len(fra)]),
    ]
    (mgl, mes_), (egl, ees) = MOMENTO[uid]
    momento, escena = {"gl": mgl, "es": mes_}, {"gl": egl, "es": ees}
    b = banda(curso)
    facer = QUE_FACER_0_2 if b == 0 else QUE_FACER
    retos = []
    for w, ((fase, nome), (tipo, item)) in enumerate(zip(FASES, escollidas), start=1):
        en = item["en"]
        s = significado(item, sig)
        prev = escollidas[w - 2][1]["en"] if w > 1 else en
        xesto = item.get("xesto")
        if isinstance(xesto, dict):
            mans = {k: xesto[k] for k in ("gl", "es")}
        elif tipo == "palabra" and s:
            mans = {"gl": f"Sinala ou colle o que nomeas: {s['gl'].rstrip('.!?')}.",
                    "es": f"Señala o coge lo que nombras: {s['es'].rstrip('.!?')}."}
        elif tipo == "formula":
            mans = {"gl": "Acompáñaa dun xesto claro: dar, recibir ou sinalar a quen lle toca.",
                    "es": "Acompáñala de un gesto claro: dar, recibir o señalar a quien le toca."}
        else:
            mans = {"gl": "Ten na man aquilo do que falas e ensínallo mentres o dis.",
                    "es": "Ten en la mano aquello de lo que hablas y enséñaselo mientras lo dices."}
        gl, es = facer[fase]
        r = {
            "id": f"reto.{curso}.{mes:02d}.{w}",
            "semana": w,
            "fase": fase,
            "nomeFase": nome,
            "frase": {"en": en, **(s or {})},
            "queFacer": {"gl": gl.format(en=en, prev=prev, oco=oco(en)),
                         "es": es.format(en=en, prev=prev, oco=oco(en))},
            "mans": mans,
            "esperaSegundos": ESPERA[curso],
            "nonPedir": {"gl": NON_PEDIR[b][0], "es": NON_PEDIR[b][1]},
            "recast": {k: {"gl": v[0].format(en=en), "es": v[1].format(en=en)}
                       for k, v in RECAST.items()},
        }
        retos.append(r)
    xogo = next((x for x in XOGO_DA_UNIDADE[uid] if x in xogos and xoga(xogos[x], curso)), None)
    observar = [{"gl": g.format(en=escollidas[0][1]["en"]), "es": e.format(en=escollidas[0][1]["en"])}
                for g, e in OBSERVAR[b]]
    reactivar = None
    if anterior:
        ult = anterior["retosCasa"][0]["frase"]["en"]
        reactivar = {
            "en": ult,
            "texto": {"gl": f"Noutro momento do día, sen avisar, volve dicir «{ult}», a palabra do mes pasado, sinalándoa.",
                      "es": f"En otro momento del día, sin avisar, vuelve a decir «{ult}», la palabra del mes pasado, señalándola."},
        }
    return {
        "momento": momento,
        "minutos": MINUTOS[curso],
        "escena": escena,
        "retosCasa": retos,
        "lecturaCasa": ({"microcuento": unidade["microcuento"]["id"]}
                        if isinstance(unidade.get("microcuento"), dict) else None),
        "juegoCasa": ({"xogo": xogo} if xogo else {"steam": steam[(curso, mes)]}),
        "queObservarCasa": observar,
        "reactivarCasa": reactivar,
    }


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    plan, cal, sig, xogos, steam = cargar()
    vellas = 0
    for curso in CURSOS:
        anterior = None
        for orden, mes in enumerate(MESES, start=1):
            f = C / "unidades_mes" / curso / f"unidade.{orden:02d}.json"
            u = json.loads(f.read_text())
            h = hogar(curso, mes, u, plan, cal, sig, xogos, steam, anterior)
            anterior = h
            if u.get("hogar") != h:
                vellas += 1
                if not a.check:
                    u["hogar"] = h
                    f.write_text(json.dumps(u, ensure_ascii=False, indent=2) + "\n")
    # Las frases de las dos guías de casa también tienen que sonar: salen del
    # inglés del plan curricular, que es el que tiene voz.
    ingles = {i["en"] for u in plan.values()
              for campo in ("vocabulario", "accionsTPR", "formulas", "frasesAdulta")
              for i in u.get(campo) or [] if isinstance(i, dict) and i.get("en")}
    g = json.loads((C / "hogar" / "guia_hogar.json").read_text())
    e = json.loads((C / "hogar" / "hogar_por_edad.json").read_text())
    frases = ([x["en"] for p in g["puntos"] for x in p.get("exemplos") or []]
              + [t["exemplo"]["en"] for t in e["tramos"]])
    sen_voz = [f for f in frases if f not in ingles]
    if sen_voz:
        print(f"FALLO: frases de las guías de casa sin voz: {sen_voz}")
        return 1
    if a.check and vellas:
        print(f"FALLO: {vellas} unidades con el bloque hogar sin regenerar "
              "(python3 tools/gen_hogar.py)")
        return 1
    print(f"OK: 50 unidades con su guía de casa ({'al día' if a.check else f'{vellas} escritas'}).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
