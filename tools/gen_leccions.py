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
SEMANAS_DO_PLAN = {"T2": 6, "T3": 8}


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


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    plan, cal, sig, xogos, steam = H.cargar()
    contos = []
    for f in sorted((C / "biblioteca").glob("his_*.json")):
        contos += json.loads(f.read_text())
    saida = {"_doc": "Generado por tools/gen_leccions.py desde el plan curricular; "
                     "no se edita a mano.", "cursos": {}}
    for curso in H.CURSOS:
        # Las semanas del curso, en orden, con su unidad del plan.
        slots = [(mes, s, cal[curso][str(mes)]) for mes in H.MESES for s in range(1, 5)]
        orden_unidades = []
        for _, _, uid in slots:
            if uid not in orden_unidades:
                orden_unidades.append(uid)
        unidades, calendario, da_anterior = [], {}, []
        for uid in orden_unidades:
            u = plan[uid]
            semanas = [(m, s) for m, s, x in slots if x == uid]
            items = items_da_unidade(u)
            # Nunca una lección sin nada nuevo: si la unidad enseña menos cosas
            # que semanas tiene, las que sobran son de repaso.
            n = min(SEMANAS_DO_PLAN[uid.split(".")[0]], len(semanas), len(items))
            trozos = repartir(items, n)
            fra = u.get("frasesAdulta") or []
            do_unidade = sorted((c for c in contos if c["unidade"] == uid),
                                key=lambda c: c["id"])
            mes0 = next(m for m, _, x in slots if x == uid)
            xogo = next((x for x in H.XOGO_DA_UNIDADE[uid]
                         if x in xogos and H.xoga(xogos[x], curso)), None)
            leccions, xa_sabe = [], []
            for k, (mes, s) in enumerate(semanas):
                repaso = k >= n
                novas = [] if repaso else [peza(t, it, sig) for t, it in trozos[k]]
                if repaso:
                    # Recuperación espaciada: vuelve la unidad entera si es
                    # corta; si no, seis de cada vez, rotando, hasta pasar por
                    # todo.
                    todos = [x for t in trozos for x in t]
                    if len(todos) <= 8:
                        novas_rep = todos
                    else:
                        i0 = ((k - n) * 6) % len(todos)
                        novas_rep = (todos + todos)[i0:i0 + 6]
                    repasa = [peza(t, it, sig) for t, it in novas_rep]
                else:
                    repasa = []
                fase = H.FASES[min(3, (k * 4) // max(1, n))][0] if not repaso else "consolidar"
                lexico = [p["en"].strip("!.?¡¿ ").lower() for p in (novas or repasa)]
                con_palabra = [f for f in fra
                               if any(w and w in f["en"].lower() for w in lexico)]
                if fase in ("descubrir", "practicar") and novas:
                    frase = trozos[k][0][1]
                elif con_palabra:
                    # Una frase del plan que lleve una palabra de esta semana.
                    frase = con_palabra[k % len(con_palabra)]
                else:
                    frase = (trozos[k][0] if not repaso else novas_rep[0])[1]
                prev = (xa_sabe[-1]["en"] if xa_sabe else frase["en"])
                conto = do_unidade[k % len(do_unidade)]["id"] if do_unidade else None
                b = H.banda(curso)
                alvo = (novas or repasa)[0]["en"]
                leccions.append({
                    "id": f"{curso}.{uid}.{k + 1}",
                    "numero": k + 1,
                    "de": len(semanas),
                    "tipo": "repaso" if repaso else "leccion",
                    # Lo de las semanas anteriores de la unidad; en la primera,
                    # lo de la unidad anterior.
                    "xaSabe": list(xa_sabe) if (xa_sabe or k) else list(da_anterior),
                    "novas": novas,
                    "repasa": repasa,
                    "reto": reto(curso, uid, fase, frase, prev, sig,
                                 mans_de((novas or repasa)[0])),
                    "conto": conto,
                    "xogo": {"xogo": xogo} if xogo else {"steam": steam[(curso, mes0)]},
                    "queMirar": [{"gl": g.format(en=alvo), "es": e.format(en=alvo)}
                                 for g, e in H.OBSERVAR[b]],
                })
                calendario.setdefault(str(mes), []).append(leccions[-1]["id"])
                xa_sabe += [{"en": p["en"], **({"gl": p["gl"], "es": p["es"]} if "gl" in p else {})}
                            for p in novas]
            unidades.append({"id": uid, "titulo": u["titulo"], "leccions": leccions})
            da_anterior = xa_sabe
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
