#!/usr/bin/env python3
"""Propuesta para Frank (28/10/2026): el STEAM del mes como eje y las 48
unidades. Para cada edad y cada mes, el experimento STEAM, la unidad de
gramática que toca y las cuatro frases de la semana escritas DESDE ese
experimento con la estructura de la unidad; dónde se abre y se cierra cada
unidad; y la ruta de la persona adulta, 21-48, con un ejemplo del STEAM de
su criatura. Las frases las escribe Claude Code y son propuesta: aún no
están en la app.

    python3 tools/mapa_steam_48.py   # escribe docs/mapa-steam-48.html
"""
from __future__ import annotations

import html
import json
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
C = RAIZ / "assets" / "content"
SAIDA = RAIZ / "docs" / "mapa-steam-48.html"
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
NOME = {9: "Septiembre", 10: "Octubre", 11: "Noviembre", 12: "Diciembre", 1: "Enero",
        2: "Febrero", 3: "Marzo", 4: "Abril", 5: "Mayo", 6: "Junio"}
EDADES = {"curso_0_2": "0-2 años", "curso_2_3": "2-3 años", "curso_3_4": "3-4 años",
          "curso_4_5": "4-5 años", "curso_5_6": "5-6 años"}

# Las cuatro frases de cada mes: descubrir, practicar, combinar, consolidar.
# Cada una dice el STEAM de ese mes con la estructura de su unidad.
FRASES = {
    "curso_0_2": {
        9: ["The sponge is wet.", "The towel is dry.", "I am wet!", "Is it dry?"],
        10: ["It is water.", "The bottle is loud.", "You are happy!", "Is it cold?"],
        11: ["A leaf.", "A big stone.", "The leaf is down.", "The stones."],
        12: ["A leaf in the light.", "The shadow.", "A big shadow.", "The torch."],
        1: ["An apple.", "The bread.", "Apples in the basket.", "The box."],
        2: ["This apple is cold.", "This bread is warm.", "My bread!", "Your apple."],
        3: ["This bubble.", "That bubble flies.", "My bubble!", "Your bubble pops."],
        4: ["You rub the towel.", "I rub my hands.", "It sounds soft.", "We rub fast."],
        5: ["The shadow runs.", "The dog sleeps.", "I see a dog.", "The light goes off."],
        6: ["The ball rolls.", "The box stops.", "You push the ball.", "It rolls down."],
    },
    "curso_2_3": {
        9: ["The boat always floats.", "The stone never floats.", "We often splash.", "Sometimes it sinks."],
        10: ["We always blow.", "The boat usually goes far.", "Sometimes we blow softly.", "We never stop!"],
        11: ["Two big stones.", "Some leaves.", "One small leaf.", "Many stones."],
        12: ["A nut.", "Some leaves.", "Many sounds.", "One big sound."],
        1: ["Some bread.", "A piece of bread.", "Some water.", "Two pieces."],
        2: ["There is a star.", "The star is in the apple.", "There are seeds.", "The seeds are inside."],
        3: ["There is soap.", "The soap is on the sink.", "There is water on your hands.", "The towel is next to you."],
        4: ["What is heavy?", "Where is the towel?", "Who lifts it?", "What happens?"],
        5: ["Who runs?", "What is fast?", "Where is the cat?", "Who sleeps?"],
        6: ["What is in the box?", "Where are the stars?", "How many stars?", "Who turns off the light?"],
    },
    "curso_3_4": {
        9: ["We build in the morning.", "At snack time it falls.", "On Friday it is tall.", "At night we tidy up."],
        10: ["On Monday: red, blue.", "In the afternoon: blue, red.", "At lunch, spoons in a row.", "On Friday you make one."],
        11: ["Push the train!", "It can go fast.", "Can it go slowly?", "Put it higher!"],
        12: ["Talk in the cup!", "Can you hear me?", "I can hear you.", "Pull the string!"],
        1: ["Look at your shadow!", "It can be long.", "Can you make it short?", "Draw the shadow!"],
        2: ["The ice is melting.", "I am stirring.", "It is getting cold.", "We are drinking."],
        3: ["You are putting the plates.", "I am counting spoons.", "We are eating.", "Who is waiting?"],
        4: ["The glass was empty.", "It was full!", "You were careful.", "Was it full?"],
        5: ["That sound was high.", "This one was low.", "We were musicians.", "Was it high or low?"],
        6: ["My face was upside down.", "It was funny.", "You were in the spoon!", "Were you surprised?"],
    },
    "curso_4_5": {
        9: ["The cloth drank the water.", "The bag didn't absorb it.", "We bandaged the teddy.", "Which one worked?"],
        10: ["We listened to the heart.", "My heart beat fast.", "We ran, then we listened.", "Did you hear the tum-tum?"],
        11: ["We were counting legs.", "The cat was standing on four legs.", "You were making two groups.", "What were you looking for?"],
        12: ["We were looking at a hair.", "It was getting bigger!", "You were drawing.", "What were you examining?"],
        1: ["We were carrying the teddy.", "It was falling!", "We were walking slowly.", "Who was holding it?"],
        2: ["The mud is on me!", "Look at yourself!", "Give it to me.", "We wash ourselves."],
        3: ["I made it myself.", "Blow it!", "The wind moves it.", "Hold it for me."],
        4: ["The thunder is louder than the rain.", "This tube is longer.", "The loudest storm!", "Quieter, quieter…"],
        5: ["My shadow is longer than yours.", "In the morning it is the longest.", "Your shadow is shorter.", "Who has the biggest shadow?"],
        6: ["Today is warmer than yesterday.", "It is the rainiest day!", "These boots are better.", "Is it colder today?"],
    },
    "curso_5_6": {
        9: ["It will be orange.", "We are going to mix blue and yellow.", "Will it be green?", "We'll make a rainbow."],
        10: ["Everything will be red.", "We are going to use the torch.", "What will happen with blue?", "It will turn purple."],
        11: ["You should fold it in half.", "You must open it slowly.", "You shouldn't use too much paint.", "Both sides have to be the same."],
        12: ["You have to spin it fast.", "You should paint three colours.", "You mustn't drop it.", "What should we try?"],
        1: ["You must close your eyes.", "You should listen carefully.", "You have to guess.", "You shouldn't peek!"],
        2: ["The plane flew across the hall.", "It went over the sofa.", "Throw it through the door!", "It landed under the table."],
        3: ["Go along the corridor.", "Walk past the kitchen.", "Go into your room.", "Climb onto the chair."],
        4: ["It is heavy because it has books.", "We need a coat, but not boots.", "First the clothes, then the books.", "We take water and a snack."],
        5: ["One flash means yes, and two mean no.", "I flashed, but you didn't see.", "Turn it off because it's late.", "First a question, then the answer."],
        6: ["The long straw is low, and the short one is high.", "It goes faster because we blow harder.", "First slow, then fast.", "Choo-choo, and then stop!"],
    },
}

# La persona adulta: 28 unidades en los 10 meses, en el mismo orden en todas
# las edades; tres al mes (dos en noviembre y febrero).
ADULTO_MES = {9: [21, 22, 23], 10: [24, 25, 26], 11: [27, 28], 12: [29, 30, 31],
              1: [32, 33, 34], 2: [35, 36], 3: [37, 38, 39], 4: [40, 41, 42],
              5: [43, 44, 45], 6: [46, 47, 48]}

# Un ejemplo de la primera unidad de adulto del mes, dicho sobre el STEAM de
# la criatura de cada edad.
EXEMPLO_ADULTO = {
    9: ["We have dried the sponge three times.", "The stone has sunk again.", "Our tower has fallen twice.",
        "The cloth has absorbed all the water.", "We have made a new colour."],
    10: ["The bottle had stopped before we shook it again.", "The boat had reached the end before I blew.",
         "We had finished the row before lunch.", "Your heart had slowed down by the time we lay on the sofa.",
         "We had switched on the torch before the room went red."],
    11: ["If the leaf were heavier, it would fall faster.", "If we had more stones, we would make a bigger pile.",
         "If the tray were higher, the train would go faster.", "If the cat had two legs, it would go in the other group.",
         "If we used more paint, the butterfly would smudge."],
    12: ["The leaf that you held made a big shadow.", "The sound that the nut made was louder.",
         "The cup that has a tight string works best.", "The hair that we saw looked like a rope.",
         "The colour that appears is a mix of both."],
    1: ["Let's put the apples away.", "Let's throw out the hard bread.",
        "The sun is going down, so the shadow gets longer.", "Pick the teddy up gently.",
        "Close your eyes and figure out which paper it is."],
    2: ["If the apple hadn't been in the fridge, it wouldn't be cold now.",
        "If we hadn't cut it across, we wouldn't see the star now.",
        "If we had used warm juice, the ice would be gone by now.",
        "If it hadn't rained yesterday, there wouldn't be mud today.",
        "If we had folded it differently, it would fly further now."],
    3: ["The bubble must have touched the towel.", "You must have skipped the soap on purpose.",
        "We should have counted the spoons first.", "The wind must have changed direction.",
        "We should have marked the treasure more clearly."],
    4: ["By bedtime, we will have rubbed the towel a hundred times.",
        "By Friday, we will have lifted every towel in the house.",
        "By dinner, you will have poured all the water.",
        "This time tomorrow, we will be making thunder again.",
        "By the trip, we will have packed the bag twice."],
    5: ["Although the light is off, the dog shadow is still in our heads.", "Whereas the dog runs, the cat sleeps.",
        "Despite being plastic, the cups sound different.",
        "Our shadows are long in the morning; however, at noon they shrink.",
        "Even though it was dark, we understood every message."],
    6: ["It was the box that stopped the ball.", "What you love is the stars on the ceiling.",
        "It is the back of the spoon that turns your face.", "What decides the clothes is the sky.",
        "It's the short straw that sounds highest."],
}

FASES = ["Descubrir", "Practicar", "Combinar", "Consolidar"]


def e(x):
    return html.escape(x if isinstance(x, str) else (x or {}).get("es", ""))


def main() -> int:
    g = json.loads((C / "gramatica" / "gramatica.json").read_text())
    puntos = {int(p["n"]): p for p in g["puntos"]}
    steam = {(x["curso"], x["mes"]): x for x in
             json.loads((C / "steam" / "steam_do_mes.json").read_text())["experimentos"]}
    out = ['<!doctype html><html lang="es"><head><meta charset="utf-8">',
           "<title>STEAM y las 48 unidades</title><style>@page{size:A4 landscape;margin:12mm}"
           "body{font-family:Arial,sans-serif;font-size:9pt;color:#1f2937}h1{font-size:17pt}"
           "h2{font-size:13pt;page-break-before:always;border-bottom:2px solid #b45309}"
           "table{border-collapse:collapse;width:100%;margin:6px 0}td,th{border:1px solid #d1d5db;"
           "padding:3px 5px;vertical-align:top;text-align:left}th{background:#fef3c7}tr{page-break-inside:avoid}"
           ".abre{color:#047857;font-weight:bold}.cierra{color:#b91c1c;font-weight:bold}"
           ".k{color:#6b7280}</style></head><body>",
           "<h1>El STEAM como eje y las 48 unidades · propuesta</h1>",
           "<p>Cada mes de cada edad parte de su experimento STEAM. La unidad de gramática se dice "
           "<b>dentro</b> del experimento: las cuatro frases de la semana cuentan el STEAM con la "
           "estructura de la unidad, en cuatro fases. Cada unidad dura dos o tres meses; se marca dónde "
           "<span class='abre'>se abre</span> y dónde <span class='cierra'>se cierra</span>, y la semana "
           "que abre una unidad repasa la anterior. La persona adulta sigue las unidades 21-48, tres al "
           "mes, con ejemplos del STEAM de su criatura. Las frases son propuesta de Claude Code: aún no "
           "están en la app.</p>"]
    for ci, (c, ed) in enumerate(EDADES.items()):
        out.append(f"<h2>{ed}</h2><table><tr><th>Mes</th><th>STEAM (eje)</th><th>Unidad</th>"
                   + "".join(f"<th>Semana {k + 1} · {FASES[k]}</th>" for k in range(4))
                   + "<th>Persona adulta</th></tr>")
        ns = [g["ruta"][c][str(m)]["punto"] for m in MESES]
        for i, m in enumerate(MESES):
            n = ns[i]
            st = steam[(c, m)]
            abre = i == 0 or ns[i - 1] != n
            cierra = i == len(MESES) - 1 or ns[i + 1] != n
            marca = ("<br><span class='abre'>Abre la unidad"
                     + (f"; repasa la {ns[i - 1]}" if i and ns[i - 1] != n else "") + "</span>" if abre else "") + \
                    ("<br><span class='cierra'>Cierra la unidad en la semana 4"
                     + (f"; después, la {ns[i + 1]}" if i + 1 < len(ns) else "") + "</span>" if cierra else "")
            frases = FRASES[c][m]
            ad = ADULTO_MES[m]
            out.append(
                f"<tr><td>{NOME[m]}</td><td><b>{e(st['titulo'])}</b><br><span class='k'>{e(st['fenomeno'])}: "
                + " / ".join(e(p) for p in st["casa"]) + "<br>Se dice: "
                + " · ".join(e(o["en"]) for o in st["ordes"]) + "</span></td>"
                f"<td><b>{n}</b> · {puntos[n]['nivel']} · {e(puntos[n]['titulo'])}{marca}</td>"
                + "".join(f"<td>{e(f)}</td>" for f in frases)
                + f"<td>Unidades {', '.join(str(x) for x in ad)}: {e(puntos[ad[0]]['titulo'])}…<br>"
                f"<i>{e(EXEMPLO_ADULTO[m][ci])}</i></td></tr>")
        out.append("</table>")
    out.append("<h2>La persona adulta, mes a mes</h2><table><tr><th>Mes</th><th>Unidades</th></tr>")
    for m in MESES:
        out.append(f"<tr><td>{NOME[m]}</td><td>"
                   + "; ".join(f"{x} · {puntos[x]['nivel']} · {e(puntos[x]['titulo'])}" for x in ADULTO_MES[m])
                   + "</td></tr>")
    out.append("</table></body></html>")
    assert sum(len(v) for v in ADULTO_MES.values()) == 28
    assert all(len(FRASES[c][m]) == 4 for c in FRASES for m in MESES)
    SAIDA.write_text("\n".join(out) + "\n", encoding="utf-8")
    print(f"OK: {SAIDA.relative_to(RAIZ)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
