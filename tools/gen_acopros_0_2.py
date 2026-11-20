#!/usr/bin/env python3
"""O-20261109-4 (ACOPROS, referencias/acopros/consideraciones-2026-11-09.md):
0-2 años trabaja por proyectos, uno por mes, con unas 20 palabras bien
escogidas, sin gramática, frases de dos elementos como mucho y una rima
tradicional, y empieza cada proyecto por el vocabulario y la canción.

No inventa contenido: SELECCIONA del material de 0-2 que ya existe.
- Proyecto: el tema y el STEAM de la unidad del mes (leccions.json).
- Canción: la canción con pulso del mes (cancions/cancions_con_pulso.json),
  una por mes en el orden del curso.
- Palabras: primero las de la lección del mes, luego las del banco TPR del
  mes (tpr/curso_0_2), con su significado y su gesto; solo de uno o dos
  elementos y sin el verbo «to be». Veinte por proyecto, cinco por semana.
- Rima: una tradicional inglesa de dominio público por mes (Decisión de
  Frank, 9/11/2026), la primera estrofa.

Uso: python3 tools/gen_acopros_0_2.py [--check]
Escribe assets/content/acopros/proxectos_0_2.json."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SAIDA = RAIZ / "assets/content/acopros/proxectos_0_2.json"
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
POR_PROXECTO = 20
# O-20261111-2: cada palabra, con su lámina (tools/gen_laminas_palabras.py).
_MAPA = RAIZ / "assets/content/laminas/palabras_laminas.json"
LAMINAS_PAL = json.loads(_MAPA.read_text(encoding="utf-8"))["pezas"] if _MAPA.exists() else {}
TO_BE = re.compile(r"\b(is|are|am|was|were|be|it's|i'm|you're|we're|they're)\b", re.I)

# Rimas tradicionales inglesas de dominio público, la primera estrofa. Una
# por mes, cerca del tema del proyecto. gl/es: lo que quiere decir, para la
# persona adulta.
RIMAS = {
    9: ("Pat-a-cake, pat-a-cake, baker's man! Bake me a cake as fast as you can.",
        "Bate, bate palmiñas, panadeiro! Faime unha torta axiña.",
        "¡Palmas, palmitas, panadero! Hazme una torta muy deprisa."),
    10: ("Head, shoulders, knees and toes, knees and toes.",
         "Cabeza, ombreiros, xeonllos e pés.",
         "Cabeza, hombros, rodillas y pies."),
    11: ("Round and round the garden, like a teddy bear.",
         "Dando voltas polo xardín, coma un osiño.",
         "Dando vueltas por el jardín, como un osito."),
    12: ("Twinkle, twinkle, little star, how I wonder what you are.",
         "Brilla, brilla, estreliña, que serás, pregunto eu.",
         "Brilla, brilla, estrellita, qué serás, me pregunto."),
    1: ("This is the way we put on our hat, put on our hat, put on our hat.",
        "Así é como pomos o gorro.",
        "Así es como nos ponemos el gorro."),
    2: ("Old MacDonald had a farm, E-I-E-I-O.",
        "O vello MacDonald tiña unha granxa.",
        "El viejo MacDonald tenía una granja."),
    3: ("Ring-a-ring o' roses, a pocket full of posies.",
        "Roda, roda de rosas, o peto cheo de flores.",
        "Corro de rosas, el bolsillo lleno de flores."),
    4: ("Rain, rain, go away, come again another day.",
        "Chuvia, chuvia, vaite xa, volve outro día.",
        "Lluvia, lluvia, vete ya, vuelve otro día."),
    5: ("This is the way we wash our hands, wash our hands, wash our hands.",
        "Así é como lavamos as mans.",
        "Así es como nos lavamos las manos."),
    6: ("Row, row, row your boat, gently down the stream.",
        "Rema, rema, rema o teu barco, suave río abaixo.",
        "Rema, rema, rema tu barco, suave río abajo."),
}

FASES = [
    ({"gl": "Descubrimos: as primeiras palabras e a canción",
      "es": "Descubrimos: las primeras palabras y la canción"}),
    ({"gl": "Xogamos coas palabras e coa canción",
      "es": "Jugamos con las palabras y con la canción"}),
    ({"gl": "A rima tradicional, coas palabras do tema",
      "es": "La rima tradicional, con las palabras del tema"}),
    ({"gl": "Repasamos todo o proxecto",
      "es": "Repasamos todo el proyecto"}),
]

# P9.2 (0-2): un momento «mira y nota» por proyecto, sin preguntas abiertas y
# con frases de dos elementos como máximo sin verbo «to be».
MIRA_E_NOTA = {
    9: ("Wet sponge!", "Esponxa mollada!", "¡Esponja mojada!",
        "Achega a esponxa mollada á man e logo a toalla seca, en silencio, para que note o contraste.",
        "Acerca la esponja mojada a la mano y luego la toalla seca, en silencio, para que note el contraste."),
    10: ("Listen, water!", "Escoita, auga!", "¡Escucha, agua!",
         "Bota auga amodo da xerra ao caldeiro e abanea a botella preto para que note cada son.",
         "Echa agua despacio de la jarra al cubo y agita la botella cerca para que note cada sonido."),
    11: ("Leaf, stone!", "Folla, pedra!", "¡Hoja, piedra!",
         "Solta á vez unha folla seca e unha pedra grande desde pouca altura para que siga o movemento cos ollos.",
         "Suelta a la vez una hoja seca y una piedra grande desde poca altura para que siga el movimiento con los ojos."),
    12: ("Bright leaf!", "Folla brillante!", "¡Hoja brillante!",
         "Ilumina coa lanterna unha folla grande contra a parede para que mire a luz e a sombra.",
         "Ilumina con la linterna una hoja grande contra la pared para que mire la luz y la sombra."),
    1: ("One basket!", "Unha cesta!", "¡Una cesta!",
        "Garda dúas pezas iguais na súa cesta mentres dis o nome con calma, deixando que mire onde vai cada unha.",
        "Guarda dos piezas iguales en su cesta mientras dices el nombre con calma, dejando que mire dónde va cada una."),
    2: ("Warm, cold!", "Morno, frío!", "¡Templado, frío!",
        "Pon na súa palma un segundo a mazá fría e logo o pan morno para que sinta os dous contrastes.",
        "Pon en su palma un segundo la manzana fría y luego el pan templado para que sienta los dos contrastes."),
    3: ("Float, bubble!", "Flota, burbulla!", "¡Flota, burbuja!",
        "Sopra dúas burbullas suaves á altura dos seus ollos para que as siga co corpo e coa man.",
        "Sopla dos burbujas suaves a la altura de sus ojos para que las siga con el cuerpo y con la mano."),
    4: ("Soft sound!", "Son suave!", "¡Sonido suave!",
        "Frota amodo tea contra tea e logo cartón estriado para que escuite e toque cada textura.",
        "Frota despacio tela contra tela y luego cartón estriado para que escuche y toque cada textura."),
    5: ("Look, shadow!", "Mira, sombra!", "¡Mira, sombra!",
        "Proxecta na parede a sombra do can ou do gato de xoguete xunto ao boneco real para que mire os dous.",
        "Proyecta en la pared la sombra del perro o del gato de juguete junto al muñeco real para que mire los dos."),
    6: ("Roll ball!", "Roda pelota!", "¡Rueda pelota!",
        "Fai rodar a pelota branda e pousa á beira a caixa para que note cal roda polo chan.",
        "Haz rodar la pelota blanda y posa al lado la caja para que note cuál rueda por el suelo."),
}


def limpo(en: str) -> str:
    return re.sub(r"\s+", " ", en.strip())


def elementos(en: str) -> int:
    return len([t for t in re.split(r"[\s,/]+", re.sub(r"[!?.…]", "", en)) if t])


def valida(en: str) -> bool:
    return 0 < elementos(en) <= 2 and not TO_BE.search(en)


def construir() -> dict:
    lec = json.loads((RAIZ / "assets/content/leccions/leccions.json").read_text(encoding="utf-8"))
    steam_data = json.loads((RAIZ / "assets/content/steam/steam_do_mes.json").read_text(encoding="utf-8"))["experimentos"]
    steam_obs = {e["id"]: e.get("observar") or {"gl": "", "es": ""} for e in steam_data}
    unidades = lec["cursos"]["curso_0_2"]["unidades"]
    cancions = json.loads((RAIZ / "assets/content/cancions/cancions_con_pulso.json").read_text(encoding="utf-8"))["cancions"]
    proxectos = []
    anteriores: list[str] = []
    for i, mes in enumerate(MESES):
        u = unidades[i]
        tpr = json.loads(next((RAIZ / "assets/content/tpr/curso_0_2").glob(f"tpr.{i + 1:02d}.*.json")).read_text(encoding="utf-8"))
        palabras: list[dict] = []
        vistas: set[str] = set()

        def engade(en, gl, es, xesto_gl, xesto_es, orixe):
            en = limpo(en)
            k = en.lower().strip("!?. ")
            if not valida(en) or k in vistas or len(palabras) >= POR_PROXECTO:
                return
            vistas.add(k)
            palabras.append({"en": en, "gl": gl, "es": es,
                             "xesto": {"gl": xesto_gl, "es": xesto_es}, "orixe": orixe,
                             **({"lamina": LAMINAS_PAL[k]["clave"]} if k in LAMINAS_PAL else {})})

        for l in u["leccions"]:
            for p in l["novas"]:
                x = p.get("xesto") or {}
                engade(p["en"], p.get("gl", ""), p.get("es", ""), x.get("gl", ""), x.get("es", ""), "leccion")
        # Del banco del mes: primero los nombres (el vocabulario base), luego el resto.
        todas = [w for s in tpr["semanas"] for w in s["palabras"]]
        for w in sorted(todas, key=lambda w: 0 if w.get("category") == "noun" else 1):
            a = w.get("tprAction") or {}
            engade(w["en"], w.get("gl", ""), w.get("es", ""), a.get("gl", ""), a.get("es", ""), "tpr")

        semanas = []
        for s in range(4):
            sw = palabras[s * 5:(s + 1) * 5]
            semanas.append({"semana": s + 1, "fase": FASES[s], "palabras": [w["en"] for w in sw]})
        frases = [w for w in palabras if elementos(w["en"]) == 2]
        cn = cancions[i]
        ck = cn["titulo"]["es"].lower().strip("!?. ")
        canc = {
            "id": cn["id"],
            "gl": cn["titulo"]["gl"],
            "es": cn["titulo"]["es"],
            **({"lamina": LAMINAS_PAL[ck]["clave"]} if ck in LAMINAS_PAL else {}),
        }
        en, gl, es = RIMAS[mes]
        rk = en.lower().strip("!?. ")
        m_en, m_gl, m_es, g_gl, g_es = MIRA_E_NOTA[mes]
        st_id = (u.get("steam") or {}).get("id", "")
        proxectos.append({
            "mesCalendario": mes,
            "proxecto": u["titulo"],
            "steam": u.get("steam"),
            "cancion": canc,
            "rima": {
                "en": en,
                "gl": gl,
                "es": es,
                **({"lamina": LAMINAS_PAL[rk]["clave"]} if rk in LAMINAS_PAL else {}),
            },
            "palabras": palabras,
            "semanas": semanas,
            # Como falar: frases de dous elementos do propio proxecto, co seu
            # xesto; se non hai, a palabra soa (holofrase).
            "comoFalar": [w["en"] for w in (frases or palabras)][:4],
            # Xa debería saber: palabras soltas do proxecto anterior.
            "xaSabe": [p for p in anteriores if elementos(p) == 1][:8],
            "guia": {
                "gl": f"Canta «{canc['gl']}» co xesto. Repasa as palabras do proxecto, unha a unha, mentres xogades.",
                "es": f"Canta «{canc['es']}» con el gesto. Repasa las palabras del proyecto, una a una, mientras jugáis.",
            },
            "mira_e_nota": {
                "titulo": {"gl": "Mira e nota", "es": "Mira y nota"},
                "frase_en": m_en,
                "significado": {"gl": m_gl, "es": m_es},
                "guia": {"gl": g_gl, "es": g_es},
                "observar": steam_obs.get(st_id, {"gl": "", "es": ""}),
            },
        })
        anteriores = [w["en"] for w in palabras]
    return {
        "_doc": "Xerado por tools/gen_acopros_0_2.py (O-20261109-4, ACOPROS). Non se edita a man.",
        "fonte": "referencias/acopros/consideraciones-2026-11-09.md",
        "proxectos": proxectos,
    }


def revisar(d: dict) -> list[str]:
    fallos = []
    if len(d["proxectos"]) != 10:
        fallos.append("non hai 10 proxectos")
    for p in d["proxectos"]:
        m = p["mesCalendario"]
        n = len(p["palabras"])
        if not 18 <= n <= 22:
            fallos.append(f"mes {m}: {n} palabras, non unhas 20")
        for w in p["palabras"]:
            if not valida(w["en"]):
                fallos.append(f"mes {m}: «{w['en']}» ten máis de dous elementos ou o verbo to be")
            if not (w["gl"] and w["es"]):
                fallos.append(f"mes {m}: «{w['en']}» sen significado gl/es")
        presentadas = {w["en"].lower().strip("!?. ") for w in p["palabras"]}
        tokens = {t.lower() for w in p["palabras"] for t in re.split(r"[\s,/]+", re.sub(r"[!?.…]", "", w["en"])) if t}
        for f in p["comoFalar"]:
            if elementos(f) > 2:
                fallos.append(f"mes {m}: cómo falar «{f}» con máis de dous elementos")
            if f.lower().strip("!?. ") not in presentadas and not all(
                    t.lower() in tokens for t in re.split(r"[\s,/]+", re.sub(r"[!?.…]", "", f)) if t):
                fallos.append(f"mes {m}: cómo falar «{f}» usa unha palabra non presentada")
        for x in p["xaSabe"]:
            if elementos(x) != 1:
                fallos.append(f"mes {m}: xa debería saber «{x}» non é unha palabra soa")
        if not (p["cancion"].get("gl") and p["cancion"].get("es")):
            fallos.append(f"mes {m}: sen canción")
        if not (p["rima"]["en"] and p["rima"]["gl"] and p["rima"]["es"]):
            fallos.append(f"mes {m}: sen rima")
        mira = p.get("mira_e_nota") or {}
        if not mira.get("frase_en") or not valida(mira["frase_en"]):
            fallos.append(f"mes {m}: mira_e_nota.frase_en non válida (máx 2 palabras sen to be)")
        if "?" in str(mira) or "¿" in str(mira):
            fallos.append(f"mes {m}: mira_e_nota en 0-2 non pode levar preguntas abertas")
        for campo in ("significado", "guia", "observar"):
            if not all((mira.get(campo) or {}).get(l) for l in ("gl", "es")):
                fallos.append(f"mes {m}: mira_e_nota.{campo} baleiro en gl ou es")
        sem1 = p["semanas"][0]
        if not sem1["palabras"] or "canción" not in sem1["fase"]["es"]:
            fallos.append(f"mes {m}: a semana 1 non empeza polo vocabulario e a canción")
        if [w for s in p["semanas"] for w in s["palabras"]] != [w["en"] for w in p["palabras"]]:
            fallos.append(f"mes {m}: as catro semanas non reparten as palabras do proxecto")
    return fallos


def main() -> int:
    d = construir()
    fallos = revisar(d)
    texto = json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    if "--check" in sys.argv:
        sig = json.loads((RAIZ / "assets/content/significados/significados.json").read_text(encoding="utf-8"))["significados"]
        for p in d["proxectos"]:
            if p["rima"]["en"] not in sig:
                fallos.append(f"mes {p['mesCalendario']}: a rima sen significado en significados.json")
        if not SAIDA.exists() or SAIDA.read_text(encoding="utf-8") != texto:
            fallos.append(f"{SAIDA.relative_to(RAIZ)} non está ao día: python3 tools/gen_acopros_0_2.py")
    else:
        SAIDA.parent.mkdir(parents=True, exist_ok=True)
        SAIDA.write_text(texto, encoding="utf-8")
        # Las rimas, con su significado en el diccionario de la app (el
        # doble toque en una frase inglesa enseña lo que quiere decir).
        sp = RAIZ / "assets/content/significados/significados.json"
        sig = json.loads(sp.read_text(encoding="utf-8"))
        for p in d["proxectos"]:
            r = p["rima"]
            sig["significados"].setdefault(r["en"], {"gl": r["gl"], "es": r["es"]})
        sp.write_text(json.dumps(sig, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    if fallos:
        print("FALLO (ACOPROS 0-2):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: 10 proxectos de 0-2, ~20 palabras cada un, frases de dous elementos como moito, "
          "sen to be, coa súa canción e a súa rima.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
