#!/usr/bin/env python3
"""Genera assets/content/escoita/ar_estimulacion.json (P10.4 · RA de Valeria adaptada al inglés).

Enlaza cada mes de 2-3 a 5-6 años (40 piezas) con su experimento STEAM y su
pieza de escucha (`plan_mensual.json`):
  - materia    -> S0 / S5
  - acustica   -> S2 / S4
  - cinematica -> S1 / S3
  - optica     -> S6
  - logica     -> S8–S11 y L02–L05
Además define las 6 actividades faciales (cámara frontal, L01/L07, ar1–ar6)
con frases cortas en inglés («Open your mouth!», «Smile!», «Big eyes!»…)
sin reconocimiento de voz y sin pedir nunca al niño que repita.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
PLAN = ROOT / "assets" / "content" / "escoita" / "plan_mensual.json"
STEAM = ROOT / "assets" / "content" / "steam" / "steam_do_mes.json"
SIG = ROOT / "assets" / "content" / "significados" / "significados.json"
OUT = ROOT / "assets" / "content" / "escoita" / "ar_estimulacion.json"

SCENES_BY_FENOMENO: dict[str, list[str]] = {
    "materia": ["S0", "S5"],
    "acustica": ["S2", "S4"],
    "cinematica": ["S1", "S3"],
    "optica": ["S6"],
    "logica": ["S8", "S9", "S10", "S11", "L02", "L03", "L04", "L05"],
}

# Plantilla de cada escena portada de Valeria/src/steam/arScenes.ts y arActivities.ts.
SCENE_TEMPLATES: dict[str, dict] = {
    "S0": {
        "nombre_gl": "Mesa de formas e encaixe",
        "nombre_es": "Mesa de formas y encaje",
        "guia_gl": "Coloca dous ou tres obxectos seguros na mesa. Lúa amosa sobre a mesa onde vai cada peza: sinala ou encaixa sen présa.",
        "guia_es": "Coloca dos o tres objetos seguros en la mesa. Lúa muestra sobre la mesa dónde va cada pieza: señala o encaja sin prisa.",
        "frase_en": "Fit it in and match the shape!",
        "sig": {"gl": "Encaixa e emparella a forma!", "es": "¡Encaja y empareja la forma!"},
        "laminas": ["pal_fit", "pal_shape"],
        "events": [
            {"id": "S0.CABEZA_ENCAJADA", "label_gl": "Cabeza", "label_es": "Cabeza", "prompt_gl": "Toca ou encaixa a peza principal na mesa.", "prompt_es": "Toca o encaja la pieza principal en la mesa.", "englishPhrase": "Fit it in!"},
            {"id": "S0.PLACA_LEIDA", "label_gl": "Forma", "label_es": "Forma", "prompt_gl": "Sinala a silueta igual no taboleiro.", "prompt_es": "Señala la silueta igual en el tablero.", "englishPhrase": "Match the shape!"},
        ],
        "shapes": [
            {"kind": "tile", "style": "piece", "pts": [[-0.08, -0.06]], "w": 0.16, "d": 0.12, "y": 0.0, "text": ""},
            {"kind": "circle", "style": "light", "pts": [[0.0, 0.0]], "r": 0.055, "y": 0.02, "text": "FIT!", "after": "S0.CABEZA_ENCAJADA"},
            {"kind": "rings", "style": "light", "pts": [[0.0, 0.0]], "r": 0.07, "y": 0.02, "text": "SHAPE!", "after": "S0.PLACA_LEIDA"},
        ],
    },
    "S1": {
        "nombre_gl": "Camiño da mesa",
        "nombre_es": "Camino en la mesa",
        "guia_gl": "Sobre a mesa vese o percorrido. Move o obxecto coas mans pola liña marcada mentres escoitades as ordes en inglés.",
        "guia_es": "Sobre la mesa se ve el recorrido. Mueve el objeto con las manos por la línea marcada mientras escucháis las órdenes en inglés.",
        "frase_en": "Connect the path and turn!",
        "sig": {"gl": "Conecta o camiño e xira!", "es": "¡Conecta el camino y gira!"},
        "laminas": ["pal_turn", "pal_path"],
        "events": [
            {"id": "S1.LUA_EN_INICIO", "label_gl": "Inicio", "label_es": "Inicio", "prompt_gl": "Pon o boneco ou peza no punto de saída.", "prompt_es": "Pon el muñeco o pieza en el punto de salida.", "englishPhrase": "Connect the path!"},
            {"id": "S1.LUA_GIRA", "label_gl": "Xiro", "label_es": "Giro", "prompt_gl": "Facede o xiro xunto á esquina marcada.", "prompt_es": "Haced el giro junto a la esquina marcada.", "englishPhrase": "Turn here!"},
        ],
        "shapes": [
            {"kind": "flow", "style": "light", "pts": [[-0.14, 0.06], [0.0, 0.06], [0.0, -0.06], [0.14, -0.06]], "y": 0.01, "text": ""},
            {"kind": "circle", "style": "light", "pts": [[-0.14, 0.06]], "r": 0.035, "y": 0.02, "text": "START", "after": "S1.LUA_EN_INICIO"},
            {"kind": "arrow", "style": "warn", "pts": [[0.0, 0.06], [0.0, -0.06]], "y": 0.03, "text": "TURN!", "after": "S1.LUA_GIRA"},
        ],
    },
    "S2": {
        "nombre_gl": "Ondas de son na mesa",
        "nombre_es": "Ondas de sonido en la mesa",
        "guia_gl": "Golpea amodo ou forte na mesa mentres as ondas medran sobre o centro. Sinalade ondas grandes e pequenas.",
        "guia_es": "Golpea suave o fuerte en la mesa mientras las ondas crecen sobre el centro. Señalad ondas grandes y pequeñas.",
        "frase_en": "Big sound, small sound!",
        "sig": {"gl": "Son grande, son pequeno!", "es": "¡Sonido grande, sonido pequeño!"},
        "laminas": ["pal_loud", "pal_soft"],
        "events": [
            {"id": "S2.GOLPE_FUERTE", "label_gl": "Forte", "label_es": "Fuerte", "prompt_gl": "Un golpe fondo coa palma aberta.", "prompt_es": "Un golpe hondo con la palma abierta.", "englishPhrase": "Big and low!"},
            {"id": "S2.GOLPE_DEBIL", "label_gl": "Suave", "label_es": "Suave", "prompt_gl": "Toque suave cos dedos na mesa.", "prompt_es": "Toque suave con los dedos en la mesa.", "englishPhrase": "Small and high!"},
        ],
        "shapes": [
            {"kind": "circle", "style": "piece", "pts": [[0.0, 0.0]], "r": 0.06, "y": 0.01, "text": ""},
            {"kind": "rings", "style": "warn", "pts": [[0.0, 0.0]], "r": 0.08, "y": 0.03, "text": "BIG!", "last": ["S2.GOLPE_FUERTE"]},
            {"kind": "rings", "style": "light", "pts": [[0.0, 0.0]], "r": 0.04, "y": 0.03, "text": "SMALL!", "last": ["S2.GOLPE_DEBIL"]},
        ],
    },
    "S3": {
        "nombre_gl": "Rampla e velocidade",
        "nombre_es": "Rampa y velocidad",
        "guia_gl": "Poñede un cartón inclinado ou un libro na mesa e soltade unha peza grande para ver como roda ata a meta.",
        "guia_es": "Poned un cartón inclinado o un libro en la mesa y soltad una pieza grande para ver cómo rueda hasta la meta.",
        "frase_en": "Roll down, fast and slow!",
        "sig": {"gl": "Roda cara abaixo, rápido e amodo!", "es": "¡Rueda hacia abajo, rápido y despacio!"},
        "laminas": ["pal_roll", "pal_fast"],
        "events": [
            {"id": "S3.ESFERA_ARRIBA", "label_gl": "Arriba", "label_es": "Arriba", "prompt_gl": "Suxeitade o obxecto no alto da costa.", "prompt_es": "Sujetad el objeto en lo alto de la cuesta.", "englishPhrase": "High tower!"},
            {"id": "S3.LLEGADA_RAPIDA", "label_gl": "Rápido", "label_es": "Rápido", "prompt_gl": "Soltádeo e mirade como chega abaixo.", "prompt_es": "Soltadlo y mirad cómo llega abajo.", "englishPhrase": "Roll down fast!"},
        ],
        "shapes": [
            {"kind": "flow", "style": "light", "pts": [[-0.14, -0.05], [0.14, 0.05]], "y": 0.04, "text": "ROLL!"},
            {"kind": "circle", "style": "warn", "pts": [[-0.14, -0.05]], "r": 0.03, "y": 0.06, "text": "UP", "after": "S3.ESFERA_ARRIBA"},
            {"kind": "rings", "style": "light", "pts": [[0.14, 0.05]], "r": 0.05, "y": 0.02, "text": "FAST!", "after": "S3.LLEGADA_RAPIDA"},
        ],
    },
    "S4": {
        "nombre_gl": "Sopro e movemento",
        "nombre_es": "Soplo y movimiento",
        "guia_gl": "Soprade amodo ou con forza cara a unha folla ou barquiño de papel na mesa mentres seguides as frechas de aire.",
        "guia_es": "Soplad despacio o con fuerza hacia una hoja o barquito de papel en la mesa mientras seguís las flechas de aire.",
        "frase_en": "Blow gently and spin!",
        "sig": {"gl": "Sopra suave e faino xirar!", "es": "¡Sopla suave y hazlo girar!"},
        "laminas": ["pal_blow", "pal_spin"],
        "events": [
            {"id": "S4.PRAXIA_REDONDEO", "label_gl": "Sopro", "label_es": "Soplo", "prompt_gl": "Sopro longo e suave sobre a mesa.", "prompt_es": "Soplo largo y suave sobre la mesa.", "englishPhrase": "Blow gently!"},
            {"id": "S4.MOLINETE_GIRA", "label_gl": "Xira", "label_es": "Gira", "prompt_gl": "Vemos moverse ou xirar o obxecto.", "prompt_es": "Vemos moverse o girar el objeto.", "englishPhrase": "Spin the wheel!"},
        ],
        "shapes": [
            {"kind": "flow", "style": "light", "pts": [[-0.15, 0.0], [0.08, 0.0]], "y": 0.04, "text": "AIR"},
            {"kind": "rings", "style": "light", "pts": [[0.1, 0.0]], "r": 0.06, "y": 0.04, "text": "SPIN!", "after": "S4.MOLINETE_GIRA"},
        ],
    },
    "S5": {
        "nombre_gl": "Ponte e equilibrio",
        "nombre_es": "Puente y equilibrio",
        "guia_gl": "Comparade un obxecto pesado e un lixeiro sobre a ponte debuxada na mesa: cal inclina o lado?",
        "guia_es": "Comparad un objeto pesado y uno ligero sobre el puente dibujado en la mesa: ¿cuál inclina el lado?",
        "frase_en": "Heavy, light, level the bridge!",
        "sig": {"gl": "Pesado, lixeiro, nivela a ponte!", "es": "¡Pesado, ligero, nivela el puente!"},
        "laminas": ["pal_heavy", "pal_light"],
        "events": [
            {"id": "S5.INCLINA_IZQ", "label_gl": "Pesado", "label_es": "Pesado", "prompt_gl": "Pon o obxecto pesado nun extremo.", "prompt_es": "Pon el objeto pesado en un extremo.", "englishPhrase": "Heavy side down!"},
            {"id": "S5.PUENTE_ESTABLE", "label_gl": "Equilibrio", "label_es": "Equilibrio", "prompt_gl": "Equilibrade os dous lados da ponte.", "prompt_es": "Equilibrad los dos lados del puente.", "englishPhrase": "Level the bridge!"},
        ],
        "shapes": [
            {"kind": "tile", "style": "piece", "pts": [[-0.14, -0.04]], "w": 0.28, "d": 0.08, "y": 0.02, "text": ""},
            {"kind": "arrow", "style": "warn", "pts": [[-0.1, -0.02], [-0.1, 0.06]], "y": 0.05, "text": "HEAVY", "last": ["S5.INCLINA_IZQ"]},
            {"kind": "rings", "style": "light", "pts": [[0.0, 0.0]], "r": 0.06, "y": 0.04, "text": "EVEN!", "after": "S5.PUENTE_ESTABLE"},
        ],
    },
    "S6": {
        "nombre_gl": "Luz, sol e sombra",
        "nombre_es": "Luz, sol y sombra",
        "guia_gl": "Coa mesa iluminada ou cunha lanterna, observade onde cae a sombra e como xira ao mover a luz.",
        "guia_es": "Con la mesa iluminada o con una linterna, observad dónde cae la sombra y cómo gira al mover la luz.",
        "frase_en": "Turn the sun and look!",
        "sig": {"gl": "Xira o sol e mira!", "es": "¡Gira el sol y mira!"},
        "laminas": ["pal_sun", "pal_shadow"],
        "events": [
            {"id": "S6.RIEGO", "label_gl": "Luz", "label_es": "Luz", "prompt_gl": "Aluma o obxecto desde un lado.", "prompt_es": "Ilumina el objeto desde un lado.", "englishPhrase": "Light here!"},
            {"id": "S6.SOMBRA_ALINEADA", "label_gl": "Sombra", "label_es": "Sombra", "prompt_gl": "Sinala co dedo onde se alonga a sombra.", "prompt_es": "Señala con el dedo dónde se alarga la sombra.", "englishPhrase": "Turn the sun!"},
        ],
        "shapes": [
            {"kind": "circle", "style": "warn", "pts": [[-0.12, -0.06]], "r": 0.04, "y": 0.06, "text": "SUN"},
            {"kind": "flow", "style": "light", "pts": [[-0.12, -0.06], [0.06, 0.04]], "y": 0.04, "text": ""},
            {"kind": "tile", "style": "light", "pts": [[0.04, 0.02]], "w": 0.10, "d": 0.05, "y": 0.01, "text": "SHADOW", "after": "S6.SOMBRA_ALINEADA"},
        ],
    },
}

# Mundos lóxicos S8–S11 e L02–L05
LOGIC_TEMPLATES: dict[str, dict] = {
    "S8": {"nombre_gl": "Paso e quenda", "nombre_es": "Paso y turno", "guia_gl": "Practicamos esperar a quenda na mesa coa barreira marcada.", "guia_es": "Practicamos esperar el turno en la mesa con la barrera marcada.", "frase_en": "Stop, wait, and cross safely!", "sig": {"gl": "Para, agarda e cruza seguro!", "es": "¡Para, espera y cruza seguro!"}, "laminas": ["pal_stop", "pal_wait"]},
    "S9": {"nombre_gl": "Ruta á diana", "nombre_es": "Ruta a la diana", "guia_gl": "Seguide o camiño lóxico ata a diana tocando cada paso.", "guia_es": "Seguid el camino lógico hasta la diana tocando cada paso.", "frase_en": "Aim and follow the line!", "sig": {"gl": "Apunta e segue a liña!", "es": "¡Apunta y sigue la línea!"}, "laminas": ["pal_follow", "pal_line"]},
    "S10": {"nombre_gl": "Coidamos a Lúa", "nombre_es": "Cuidamos a Lúa", "guia_gl": "Ordeamos os pasos de coidado en serie de tres: chegar, descansar e celebrar.", "guia_es": "Ordenamos los pasos de cuidado en serie de tres: llegar, descansar y celebrar.", "frase_en": "One, two, three steps!", "sig": {"gl": "Un, dous, tres pasos!", "es": "¡Uno, dos, tres pasos!"}, "laminas": ["pal_one", "pal_two"]},
    "S11": {"nombre_gl": "Estación e orde", "nombre_es": "Estación y orden", "guia_gl": "Emparellade cada peza co seu sitio antes de dar a saída ao tren.", "guia_es": "Emparejad cada pieza con su sitio antes de dar salida al tren.", "frase_en": "Match each spot first!", "sig": {"gl": "Emparella cada sitio primeiro!", "es": "¡Empareja cada sitio primero!"}, "laminas": ["pal_match", "pal_spot"]},
    "L02": {"nombre_gl": "Lúa xira á cousa pedida", "nombre_es": "Lúa gira a lo pedido", "guia_gl": "Coloca dous obxectos a cada lado e axuda ao neno ou á nena a sinalar cal mira Lúa.", "guia_es": "Coloca dos objetos a cada lado y ayuda al niño o a la niña a señalar cuál mira Lúa.", "frase_en": "Point where Lúa looks!", "sig": {"gl": "Sinala onde mira Lúa!", "es": "¡Señala dónde mira Lúa!"}, "laminas": ["pal_point", "pal_look"]},
    "L03": {"nombre_gl": "A merenda de Lúa", "nombre_es": "La merienda de Lúa", "guia_gl": "Dádelle a cada peza o seu turno en orde mentres Lúa agarda na mesa.", "guia_es": "Dadle a cada pieza su turno en orden mientras Lúa espera en la mesa.", "frase_en": "Wait, then share the snack!", "sig": {"gl": "Agarda e despois comparte a merenda!", "es": "¡Espera y después comparte la merienda!"}, "laminas": ["pal_wait", "pal_share"]},
    "L04": {"nombre_gl": "Lúa descansa en calma", "nombre_es": "Lúa descansa en calma", "guia_gl": "Secuencia tranquila: cando baixa o movemento, Lúa esperta feliz.", "guia_es": "Secuencia tranquila: cuando baja el movimiento, Lúa despierta feliz.", "frase_en": "Calm and awake now!", "sig": {"gl": "En calma e esperto agora!", "es": "¡En calma y despierto ahora!"}, "laminas": ["pal_calm", "pal_wake"]},
    "L05": {"nombre_gl": "Aloumiño lento", "nombre_es": "Caricia lenta", "guia_gl": "Cando a man vai amodo pola mesa, acéndese o recuncho de calma.", "guia_es": "Cuando la mano va despacio por la mesa, se enciende el rincón de calma.", "frase_en": "Move your hand slowly!", "sig": {"gl": "Move a man amodo!", "es": "¡Mueve la mano despacio!"}, "laminas": ["pal_slow", "pal_hand"]},
}

for code, meta in LOGIC_TEMPLATES.items():
    SCENE_TEMPLATES[code] = {
        **meta,
        "events": [
            {"id": f"{code}.PASO_1", "label_gl": "Paso 1", "label_es": "Paso 1", "prompt_gl": meta["guia_gl"], "prompt_es": meta["guia_es"], "englishPhrase": meta["frase_en"]},
            {"id": f"{code}.FIN", "label_gl": "Logro", "label_es": "Logro", "prompt_gl": "Todo no seu sitio sobre a mesa.", "prompt_es": "Todo en su sitio sobre la mesa.", "englishPhrase": meta["frase_en"]},
        ],
        "shapes": [
            {"kind": "tile", "style": "piece", "pts": [[-0.10, -0.06]], "w": 0.20, "d": 0.12, "y": 0.0, "text": ""},
            {"kind": "rings", "style": "light", "pts": [[0.0, 0.0]], "r": 0.06, "y": 0.02, "text": "OK!", "after": f"{code}.FIN"},
        ],
    }

# Actividades faciales de cámara frontal (L01/L07, ar1–ar6) sen petición de fala
FACE_ACTIVITIES = [
    {
        "id": "L01.ar1",
        "code": "ar1",
        "modelAsset": "models/coche.glb",
        "animation": "celebrate",
        "gestureMode": "jaw_open",
        "titulo_gl": "Espello de Lúa · Boca aberta",
        "titulo_es": "Espejo de Lúa · Boca abierta",
        "guia_gl": "Ponte diante da cámara co neno ou coa nena. Cando abrades a boca grande en silencio, o coche avanza pola pantalla.",
        "guia_es": "Ponte delante de la cámara con el niño o con la niña. Cuando abráis la boca grande en silencio, el coche avanza por la pantalla.",
        "frase_en": "Open your mouth!",
        "sig": {"gl": "Abre a boca!", "es": "¡Abre la boca!"},
        "lamina": "pal_mouth",
    },
    {
        "id": "L07.ar6",
        "code": "ar6",
        "modelAsset": "models/lua.glb",
        "animation": "celebrate",
        "gestureMode": "smile",
        "titulo_gl": "Espello de Lúa · Sorriso grande",
        "titulo_es": "Espejo de Lúa · Sonrisa grande",
        "guia_gl": "Mirade á gata Lúa no espello: cun sorriso amplo sen dicir nada, Lúa dá un salto de alegría.",
        "guia_es": "Mirad a la gata Lúa en el espejo: con una sonrisa amplia sin decir nada, Lúa da un salto de alegría.",
        "frase_en": "Smile!",
        "sig": {"gl": "Sorrí!", "es": "¡Sonríe!"},
        "lamina": "pal_smile",
    },
    {
        "id": "L01.ar3",
        "code": "ar3",
        "modelAsset": "models/manzana.glb",
        "animation": "spin360",
        "gestureMode": "big_eyes",
        "titulo_gl": "Espello de Lúa · Ollos grandes",
        "titulo_es": "Espejo de Lúa · Ojos grandes",
        "guia_gl": "Xogade a abrir moito os ollos diante do espello para que xire a mazá.",
        "guia_es": "Jugad a abrir mucho los ojos delante del espejo para que gire la manzana.",
        "frase_en": "Big eyes!",
        "sig": {"gl": "Ollos grandes!", "es": "¡Ojos grandes!"},
        "lamina": "pal_eyes",
    },
    {
        "id": "L01.ar4",
        "code": "ar4",
        "modelAsset": "models/lua.glb",
        "animation": "celebrate",
        "gestureMode": "pucker",
        "titulo_gl": "Espello de Lúa · Bico de sopro",
        "titulo_es": "Espejo de Lúa · Beso de soplo",
        "guia_gl": "Xuntade os beizos coma un bico silencioso diante do espello ata encher o anel.",
        "guia_es": "Juntad los labios como un beso silencioso delante del espejo hasta llenar el anillo.",
        "frase_en": "Pucker your lips!",
        "sig": {"gl": "Xunta os beizos!", "es": "¡Junta los labios!"},
        "lamina": "pal_lips",
    },
    {
        "id": "L07.ar5",
        "code": "ar5",
        "modelAsset": "models/pez.glb",
        "animation": "spin360",
        "gestureMode": "cheek_puff",
        "titulo_gl": "Espello de Lúa · Meixelas de peixe",
        "titulo_es": "Espejo de Lúa · Mejillas de pez",
        "guia_gl": "Inflade as meixelas con aire e soltádeo amodo para lanzar o peixiño.",
        "guia_es": "Inflad las mejillas con aire y soltadlo despacio para lanzar el pececito.",
        "frase_en": "Puff your cheeks!",
        "sig": {"gl": "Infla as meixelas!", "es": "¡Infla las mejillas!"},
        "lamina": "pal_fish",
    },
    {
        "id": "L07.ar2",
        "code": "ar2",
        "modelAsset": "models/perro.glb",
        "animation": "celebrate",
        "gestureMode": "turn_head",
        "titulo_gl": "Espello de Lúa · Xirar a cabeza",
        "titulo_es": "Espejo de Lúa · Girar la cabeza",
        "guia_gl": "Despois de escoitar o son, xirade a cabeza amodo cara a un lado para atopar o canciño.",
        "guia_es": "Después de escuchar el sonido, girad la cabeza despacio hacia un lado para encontrar al perrito.",
        "frase_en": "Turn your head!",
        "sig": {"gl": "Xira a cabeza!", "es": "¡Gira la cabeza!"},
        "lamina": "pal_dog",
    },
]


def main() -> int:
    plan = json.loads(PLAN.read_text(encoding="utf-8"))["piezas"]
    steam = {e["id"]: e for e in json.loads(STEAM.read_text(encoding="utf-8"))["experimentos"]}
    sig_doc = json.loads(SIG.read_text(encoding="utf-8"))
    sig_map = sig_doc["significados"]

    counts: dict[str, int] = {}
    escenas: list[dict] = []

    for idx, p in enumerate(plan):
        curso = p["curso"]
        mes = p["mes"]
        st_id = p["steam"]["id"]
        exp = steam.get(st_id, {})
        fenomeno = exp.get("fenomeno", "materia")
        pool = SCENES_BY_FENOMENO.get(fenomeno, ["S0"])
        k = counts.get(fenomeno, 0)
        counts[fenomeno] = k + 1
        valeria_id = pool[k % len(pool)]
        tpl = SCENE_TEMPLATES[valeria_id]
        face = FACE_ACTIVITIES[idx % len(FACE_ACTIVITIES)]

        par_a = p["par"]["a"]
        par_b = p["par"]["b"]
        prog_frases = [f.get("frase", "") for f in p["progresion"]["fases"] if f.get("frase")]
        frase_mes = (p.get("modelo") or {}).get("adulto") or []

        # Frases en inglés para el neno/nena (voz child + slow)
        palabras_en = [par_a["en"], par_b["en"]]
        frases_en = [tpl["frase_en"], face["frase_en"]]
        if prog_frases:
            frases_en.append(prog_frases[0])

        # Registrar significados gl/es para doble toque
        for en_t, tr in [
            (tpl["frase_en"], tpl["sig"]),
            (face["frase_en"], face["sig"]),
        ]:
            sig_map.setdefault(en_t, tr)
        for ev in tpl["events"]:
            ep = ev["englishPhrase"]
            if ep not in sig_map:
                sig_map[ep] = {"gl": ev["prompt_gl"], "es": ev["prompt_es"]}

        escenas.append({
            "id": f"ra_{curso}_m{mes:02d}",
            "curso": curso,
            "mes": mes,
            "fenomeno": fenomeno,
            "steam_id": st_id,
            "steam_titulo": p["steam"]["titulo"],
            "valeria_scene_id": valeria_id,
            "titulo": {"gl": tpl["nombre_gl"], "es": tpl["nombre_es"]},
            "guia_adulto": {"gl": tpl["guia_gl"], "es": tpl["guia_es"]},
            "par": {
                "a": par_a["en"],
                "b": par_b["en"],
                "fonema": p["par"].get("fonema", ""),
            },
            "frase_cena_en": tpl["frase_en"],
            "frase_cena_sig": tpl["sig"],
            "palabras_en": palabras_en,
            "frases_en": frases_en,
            "frase_modelo_mes": frase_mes[0] if frase_mes else tpl["frase_en"],
            "face_id": face["id"],
            "fallback": {
                "instrucion": {
                    "gl": "Este aparello non ten cámara nin soporte ARCore. Podedes xogar igual coas láminas sobre a mesa e a voz de Lúa.",
                    "es": "Este dispositivo no tiene cámara ni soporte ARCore. Podéis jugar igual con las láminas sobre la mesa y la voz de Lúa.",
                },
                "laminas_suporte": [par_a.get("lamina", ""), par_b.get("lamina", "")],
            },
            "scene_spec": {
                "title": {"gl": f"Lúa RA · {tpl['nombre_gl']}", "es": f"Lúa RA · {tpl['nombre_es']}"},
                "placeHint": {"gl": "Toca a mesa debuxada para colocar a escena.", "es": "Toca la mesa dibujada para colocar la escena."},
                "searchHint": {"gl": "Move o móbil amodo mirando cara á mesa.", "es": "Mueve el móvil despacio mirando hacia la mesa."},
                "closeLabel": {"gl": "Pechar", "es": "Cerrar"},
                "replaceLabel": {"gl": "Recolocar", "es": "Recolocar"},
                "luaPrefix": "Lúa: ",
                "events": tpl["events"],
                "shapes": tpl["shapes"],
            },
        })

    doc = {
        "version": 1,
        "_doc": "P10.4: 40 escenas de Realidade Aumentada por mes e idade (2-3 a 5-6) e 6 actividades faciais (cámara frontal, L01/L07), adaptadas ao inglés desde Valeria.",
        "actividades_faciais": FACE_ACTIVITIES,
        "escenas": escenas,
    }
    OUT.write_text(json.dumps(doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    sig_doc["significados"] = dict(sorted(sig_map.items(), key=lambda kv: kv[0]))
    SIG.write_text(json.dumps(sig_doc, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"OK: escritas {len(escenas)} escenas AR e {len(FACE_ACTIVITIES)} actividades faciais en {OUT.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
