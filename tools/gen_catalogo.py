#!/usr/bin/env python3
"""El catálogo de todo el material, por edad (Frank, 28/10/2026): cada tema
con su unidad de las 48, su STEAM, su microcuento y sus cuatro semanas
—palabras, frase, cuento y los cinco días—, y las unidades 21-48 para la
persona adulta. Sale de los mismos JSON que la app; no se edita a mano.

    python3 tools/gen_catalogo.py          # escribe docs/catalogo-por-idades.html
    node docs/build-catalogo.js            # y de ahí el PDF
"""
from __future__ import annotations

import glob
import html
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
C = RAIZ / "assets" / "content"
SAIDA = RAIZ / "docs" / "catalogo-por-idades.html"
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
NOME_MES = {9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre", 1: "Enero",
            2: "Febrero", 3: "Marzo", 4: "Abril", 5: "Mayo", 6: "Junio"}
EDADES = {"curso_0_2": "0-2 años", "curso_2_3": "2-3 años", "curso_3_4": "3-4 años",
          "curso_4_5": "4-5 años", "curso_5_6": "5-6 años"}


def e(x) -> str:
    return html.escape(x if isinstance(x, str) else (x or {}).get("es", "") if isinstance(x, dict) else str(x or ""))


def main() -> int:
    lec = json.loads((C / "leccions" / "leccions.json").read_text())["cursos"]
    gram = json.loads((C / "gramatica" / "gramatica.json").read_text())
    steam = {(x["curso"], x["mes"]): x for x in
             json.loads((C / "steam" / "steam_do_mes.json").read_text())["experimentos"]}
    contos = {(h["cursoId"], int(h["mesNumero"]), int(h["semanaSugerida"])): h
              for h in json.loads((C / "cuentos" / "historias_progresivas.json").read_text())
              if h.get("semanaSugerida")}
    banco = {c: sum(len(s["palabras"]) for f in glob.glob(str(C / "tpr" / c / "tpr.*.json"))
                    for s in json.loads(Path(f).read_text())["semanas"]) for c in EDADES}
    dialog = []
    for f in sorted((C / "biblioteca").glob("his_*.json")):
        dialog += json.loads(f.read_text())
    dialog_id = {d["id"]: d for d in dialog}
    cancions = json.loads((C / "cancions" / "cancions_con_pulso.json").read_text())["cancions"]

    modelo = json.loads((C / "modelo" / "o_modelo.json").read_text())
    tramos = json.loads((C / "hogar" / "hogar_por_edad.json").read_text())["tramos"]
    bid = {}
    for f in glob.glob(str(C / "tpr" / "curso_*" / "tpr.*.json")):
        for sem in json.loads(Path(f).read_text())["semanas"]:
            for w in sem["palabras"]:
                bid[w["id"]] = w

    nome = {"que": "Qué es", "porque": "Por qué", "como": "Cómo se hace", "erro": "Error frecuente",
            "fonte": "Fuente", "documento": "Documento de origen", "ferramenta": "Herramienta",
            "quePedir": "Qué pedir", "lectura": "Lectura", "momento": "Momento", "minutos": "Minutos",
            "idade": "Edad", "exemplo": "Ejemplo", "sinal": "Señal"}

    def campos(d, saltar=("clave", "titulo", "id")):
        # Cada campo de texto de una ficha, con su nombre.
        filas = []
        for k, v in d.items():
            if k in saltar:
                continue
            if isinstance(v, dict) and "es" in v:
                filas.append(f"<li><b>{nome.get(k, k)}:</b> {e(v)}</li>")
            elif isinstance(v, list) and v and isinstance(v[0], dict) and "es" in v[0]:
                filas.append(f"<li><b>{nome.get(k, k)}:</b> " + " · ".join(e(x) for x in v) + "</li>")
            elif isinstance(v, str) and k not in ("curso",):
                filas.append(f"<li><b>{nome.get(k, k)}:</b> {e(v)}</li>")
        return "<ul>" + "".join(filas) + "</ul>"

    def lua(x):
        # La frase de Lúa en una lámina: inglés y lo que quiere decir.
        if isinstance(x, dict) and x.get("en"):
            return f" <i>Lúa: «{e(x['en'])}» ({e(x)})</i>"
        return ""

    out = ['<!doctype html><html lang="es"><head><meta charset="utf-8">',
           "<title>Descubre con Lúa · Material por edades</title><style>",
           "@page{size:A4;margin:16mm 14mm}body{font-family:'Nunito',Arial,sans-serif;font-size:9.5pt;"
           "color:#1f2937;line-height:1.35}h1{font-size:20pt;margin:0 0 6px}h2{font-size:15pt;"
           "page-break-before:always;border-bottom:2px solid #b45309;padding-bottom:4px}"
           "h3{font-size:11.5pt;margin:14px 0 4px;color:#b45309;page-break-after:avoid}"
           "h4{font-size:10pt;margin:8px 0 2px;page-break-after:avoid}table{border-collapse:collapse;"
           "width:100%;margin:4px 0 8px}tr{page-break-inside:avoid}td,th{border:1px solid #d1d5db;"
           "padding:3px 5px;vertical-align:top;text-align:left}th{background:#fef3c7}"
           ".sem{border-left:3px solid #fcd34d;padding-left:8px;margin:6px 0}"
           ".k{color:#6b7280}ul{margin:2px 0 4px 16px;padding:0}</style></head><body>",
           "<h1>Descubre con Lúa · Material por edades</h1>",
           "<p>Todo el material que la app enseña en cada edad, tal como sale de sus ficheros de "
           "contenido: diez temas por edad, uno por mes, de cuatro semanas. Cada tema trabaja una "
           "unidad de gramática de las 48 (A1-A2 para las criaturas) y tiene su experimento STEAM, "
           "que es el eje del mes; cada semana, sus palabras nuevas, la frase de la unidad, su cuento "
           "y los cinco días. Al final, las unidades 21-48 (B1-C1), para la persona adulta.</p>"]

    out.append("<h2>El método: cómo se habla a la criatura</h2>")
    out.append(f"<p>{e(modelo.get('intro') or modelo.get('resumo') or '')}</p>")
    for sec in modelo.get("seccions") or []:
        out.append(f"<h3>{e(sec.get('titulo'))}</h3>" + campos(sec))
    # Inventario.
    out.append("<h3>Inventario</h3><table><tr><th>Edad</th><th>Temas</th><th>Semanas</th>"
               "<th>Palabras nuevas</th><th>Banco de la edad</th><th>Cuentos de la semana</th>"
               "<th>Cuentos dialogados</th><th>STEAM</th><th>Unidades de gramática</th></tr>")
    tot = [0] * 8
    for c, ed in EDADES.items():
        us = lec[c]["unidades"]
        ls = [l for u in us for l in u["leccions"]]
        fila = [len(us), len(ls), sum(len(l["novas"]) for l in ls), banco[c],
                sum((c, i + 1, l["numero"]) in contos for i, u in enumerate(us) for l in u["leccions"]),
                sum(1 for l in ls if l.get("conto")), sum("steam" in u for u in us),
                len({u["gramatica"]["n"] for u in us})]
        tot = [a + b for a, b in zip(tot, fila)]
        rango = f'{us[0]["gramatica"]["n"]}-{us[-1]["gramatica"]["n"]}'
        out.append(f"<tr><td>{ed}</td>" + "".join(f"<td>{v}</td>" for v in fila[:-1])
                   + f"<td>{fila[-1]} ({rango})</td></tr>")
    out.append("<tr><th>Total</th>" + "".join(f"<th>{v}</th>" for v in tot) + "</tr></table>")
    out.append('<p class="k">«Palabras nuevas»: las que la lección enseña, ninguna repetida entre '
               "edades. «Banco de la edad»: todas las palabras del programa diario de esa edad "
               "(cinco al día). «Cuentos dialogados»: semanas que, además del cuento de la semana, "
               "tienen uno dialogado de su cohorte; 0-2 años no tiene cohorte propia.</p>")

    for c, ed in EDADES.items():
        out.append(f"<h2>{ed}</h2>")
        for t in [t for t in tramos if t.get("curso") == c]:
            out.append(f"<h3>En casa, {e(t.get('idade'))}: herramienta y lo que se pide</h3>" + campos(t))
        for i, u in enumerate(lec[c]["unidades"]):
            mes = MESES[i]
            g = u["gramatica"]
            st = steam.get((c, mes))
            um = json.loads((C / "unidades_mes" / c / f"unidade.{i + 1:02d}.json").read_text())
            out.append(f"<h3>Tema {i + 1} de 10 · {NOME_MES[mes]} · {e(u['titulo'])}</h3>")
            out.append(f"<p><b>Unidad {g['n']} de 48 · {g['nivel']} · {e(g['titulo'])}</b>. "
                       f"{e(g.get('paraFamilias'))}</p>")
            if st:
                out.append(f"<p><b>STEAM del mes: {e(st['titulo'])}</b>. Material: "
                           + "; ".join(e(m) for m in st.get("material") or []) + ".</p><ul>"
                           + "".join(f"<li>En casa: {e(p)}</li>" for p in st.get("casa") or [])
                           + "".join(f"<li>En el aula: {e(p)}</li>" for p in st.get("aula") or [])
                           + "".join(f"<li>Se dice: «{e(o['en'])}» ({e(o)})</li>" for o in st.get("ordes") or [])
                           + f"</ul><p class='k'>Qué mirar: {e(st.get('observar'))} · "
                           f"Seguridad: {e(st.get('seguridade'))}</p>")
            ct = um.get("contraste")
            if ct:
                a, b = bid.get(ct.get("a"), {}), bid.get(ct.get("b"), {})
                out.append(f"<p><b>Fonética del mes:</b> «{e(a.get('en', ct.get('a')))}» frente a "
                           f"«{e(b.get('en', ct.get('b')))}». {e(ct.get('nota'))}</p>")
            extra = []
            if (um.get("microcuento") or {}).get("titulo"):
                extra.append(f"microcuento «{e(um['microcuento']['titulo'])}»")
            if (um.get("cancion") or {}).get("titulo"):
                extra.append(f"canción «{e(um['cancion']['titulo'])}»")
            if extra:
                out.append("<p>Además, este mes: " + ", ".join(extra) + ".</p>")
            mc = um.get("microcuento") or {}
            if mc.get("laminas"):
                out.append(f"<h4>Microcuento del mes: «{e(mc['titulo'])}»</h4><ol>"
                           + "".join(f"<li>{e(x.get('trama'))}{lua(x.get('lua'))}</li>"
                                     for x in mc["laminas"]) + "</ol>")
            fb = sorted(glob.glob(str(C / "tpr" / c / f"tpr.{i + 1:02d}.*.json")))
            if fb:
                for sem in json.loads(Path(fb[0]).read_text())["semanas"]:
                    out.append(f"<h4>Banco del mes · semana {sem['semana']}: {e(sem.get('tema'))} "
                               f"({len(sem['palabras'])} palabras, cinco al día)</h4><table>"
                               "<tr><th>Inglés</th><th>Castellano</th><th>Gallego</th><th>Gesto</th></tr>"
                               + "".join(f"<tr><td>{e(w['en'])}</td><td>{e(w.get('es'))}</td><td>{e(w.get('gl'))}</td>"
                                         f"<td>{e(w.get('tprAction'))}</td></tr>" for w in sem["palabras"])
                               + "</table>")
            for l in u["leccions"]:
                cs = contos.get((c, i + 1, l["numero"]))
                d = dialog_id.get(l.get("conto"))
                out.append(f'<div class="sem"><h4>Semana {l["numero"]} de 4</h4><table>'
                           "<tr><th>Inglés</th><th>Gallego</th><th>Castellano</th><th>Qué es</th></tr>"
                           + "".join(f"<tr><td>{e(p['en'])}</td><td>{e(p.get('gl'))}</td>"
                                     f"<td>{e(p.get('es'))}</td><td>{e(p.get('que'))}</td></tr>"
                                     for p in l["novas"]) + "</table>")
                r = l.get("reto") or {}
                out.append(f"<p><b>Fase de la semana:</b> {e(r.get('nomeFase') or r.get('fase'))} · "
                           f"<b>Qué se espera:</b> {e(l.get('espera'))}</p>")
                cf = l.get("comoFalar") or {}
                if cf:
                    out.append(f"<p><b>Cómo hablar esta semana: {e(cf.get('titulo'))}.</b> "
                               + " ".join(e(x) for x in cf.get("como") or []) + "</p>")
                if l.get("xaSabe"):
                    out.append("<p><b>Repaso, ya debería saber:</b> "
                               + ", ".join(f"{e(p['en'])} ({e(p.get('es'))})" for p in l["xaSabe"]) + "</p>")
                if r:
                    out.append(f"<p><b>Reto de casa:</b> «{e((r.get('frase') or {}).get('en'))}» · "
                               f"{e(r.get('momento'))}, {r.get('minutos')} min. {e(r.get('queFacer'))} "
                               f"Con las manos: {e(r.get('mans'))} Espera: {r.get('esperaSegundos')} s. "
                               f"No pedir: {e(r.get('nonPedir'))}</p>")
                    if r.get("recast"):
                        out.append("<p class='k'>Qué decir después: " + " · ".join(
                            f"{e(k)}: {e(v)}" for k, v in r["recast"].items()) + "</p>")
                fg = l.get("fraseGramatica") or {}
                out.append(f"<p><b>Frase de la unidad {g['n']}:</b> {e(fg.get('en'))} "
                           f"<span class='k'>({e(fg)})</span></p>")
                if cs:
                    out.append(f"<p><b>Cuento de la semana:</b> «{e(cs['titulo'])}». {e(cs.get('sinopse'))}</p><ol>"
                               + "".join(f"<li><b>{e(pg.get('tituloPagina'))}.</b> {e(pg.get('texto'))}"
                                         f" <span class='k'>[{', '.join(e(w) for w in pg.get('palabras') or [])}]</span></li>"
                                         for pg in cs.get("paginas") or []) + "</ol>")
                    if cs.get("preguntasGraduadas"):
                        out.append("<p class='k'>Preguntas: " + " · ".join(
                            f"{q.get('nivel')}: {e(q.get('enunciado'))}" for q in cs["preguntasGraduadas"]) + "</p>")
                if d:
                    out.append(f"<p><b>Cuento dialogado:</b> «{e(d['titulo'])}»</p><ol>"
                               + "".join(f"<li>{e(x.get('narracion'))}{lua(x.get('lua'))}</li>"
                                         for x in d.get("laminas") or []) + "</ol>")
                out.append("<ul>" + "".join(f"<li><b>{e(x['dia'])}:</b> {e(x['texto'])}</li>"
                                             for x in l["dias"]) + "</ul></div>")

    out.append("<h2>Las canciones con pulso</h2>")
    for cn in cancions:
        out.append(f"<h4>{e(cn['titulo'])} · {cn.get('bpm')} bpm</h4><p>"
                   + e(cn.get("letraConPulsos")).replace("*", "·").replace("\n", "<br>") + "</p>")
    usados = {l.get("conto") for c in lec.values() for u in c["unidades"] for l in u["leccions"]}
    resto = [d for d in dialog if d["id"] not in usados]
    out.append(f"<h2>Cuentos dialogados que no van en ninguna semana ({len(resto)})</h2>")
    for d in resto:
        out.append(f"<h4>«{e(d['titulo'])}» · {e(d.get('unidade'))} · cohorte {e(d.get('cohorte'))}</h4><ol>"
                   + "".join(f"<li>{e(x.get('narracion'))}{lua(x.get('lua'))}</li>" for x in d.get("laminas") or [])
                   + "</ol>")
    out.append("<h2>Unidades 21-48 · B1-C1, para la persona adulta</h2>")
    out.append('<p class="k">Estas unidades no tienen todavía semanas propias: aquí van su '
               "descripción y su ejemplo, tal como están en la app (Guía → Ver las 48 unidades).</p>")
    out.append("<table><tr><th>N.º</th><th>Nivel</th><th>Unidad</th><th>Qué es</th><th>Ejemplo</th></tr>")
    for p in gram["puntos"]:
        if int(p["n"]) > 20:
            ex = p.get("exemplo") or {}
            out.append(f"<tr><td>{p['n']}</td><td>{p['nivel']}</td><td>{e(p['titulo'])}</td>"
                       f"<td>{e(p.get('descricion'))}</td><td>{e(ex.get('en'))}<br>"
                       f"<span class='k'>{e(ex)}</span></td></tr>")
    out.append("</table></body></html>")
    SAIDA.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"OK: {SAIDA.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
