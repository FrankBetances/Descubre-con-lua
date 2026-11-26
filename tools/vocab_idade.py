#!/usr/bin/env python3
"""O-20261126-5 (punto 6): vocabulario de 2-3 a 5-6 ajustado a la edad.

Frank, 26/11/2026: «hagas ahora lo más pesado, el cinco y el seis». El seis es
sustituir las palabras y órdenes que no son de la edad (palabras raras o
abstractas, y órdenes más largas que el tope de su edad) por otras que un niño
de esa edad oye y puede usar, del mismo tema y con lámina.

SUBST es la tabla, escrita por Claude Code. Cada sustitución se aplica en
todas las fuentes de su curso, para que la lección, el banco TPR de la semana y
el cuento sigan diciendo lo mismo:

- assets/content/tpr/<curso>/*.json, assets/content/unidades_mes/<curso>/*.json,
  los experimentos de assets/content/steam/steam_do_mes.json de ese curso,
  los cuentos de assets/content/cuentos/historias_progresivas.json de ese curso
  y tools/paxinas_extra_<edad>.py (de donde salen esos cuentos);
- en el texto: el inglés entre “…” o «…», y el significado gallego y castellano
  de la palabra vieja en la misma frase, por el de la nueva;
- tools/gen_leccions.py la aplica además a las lecciones (lo que llega del plan
  curricular), con `sustituir_leccions`.

Las órdenes acortadas reutilizan la lámina de la orden larga (es la misma
acción); las palabras nuevas usan la lámina que ya tienen en el banco.

Uso: python3 tools/vocab_idade.py [--aplicar | --check]
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
C = RAIZ / "assets" / "content"
MAPA = C / "laminas" / "palabras_laminas.json"

# Tope de palabras de una pieza nueva (orden o frase) por edad.
MAX_PALABRAS = {"curso_2_3": 5, "curso_3_4": 6, "curso_4_5": 7, "curso_5_6": 8}

# vella → (nova, galego, castellano). Todas las propuestas de Claude Code.
PROPOSTAS: dict[str, dict[str, tuple[str, str, str]]] = {
    "curso_2_3": {
        "Roll up": ("Tidy up", "Recoller", "Recoger"),
        "Kneecap": ("Knee", "Xeonllo", "Rodilla"),
        "Merry-go-round": ("Swing", "Randeeira", "Columpio"),
        "Race track": ("Park", "Parque", "Parque"),
        "Finish line": ("Slide", "Tobogán", "Tobogán"),
        "Stroll": ("March", "Marchar", "Marchar"),
        "Blow away": ("Spin", "Xirar", "Girar"),
        "Tread": ("Stamp", "Pisar forte", "Pisar fuerte"),
        "Jump in": ("Hop", "Brincar", "Brincar"),
        "Pour down": ("Pitter-patter", "Plic, plic", "Plic, plic"),
        "Pull on": ("Wear", "Levar posto", "Llevar puesto"),
        "Pavement": ("Street", "Rúa", "Calle"),
        "Walrus": ("Whale", "Balea", "Ballena"),
        "Oval": ("Square", "Cadrado", "Cuadrado"),
        "Cube": ("Triangle", "Triángulo", "Triángulo"),
        "Sphere": ("Star", "Estrela", "Estrella"),
        "Meadow": ("Grass", "Herba", "Hierba"),
        "Blackbird": ("Robin", "Paporrubio", "Petirrojo"),
        "Library": ("Book", "Libro", "Libro"),
        "Soap pump": ("Bubbles", "Burbullas", "Burbujas"),
        "Brush head": ("Comb", "Peite", "Peine"),
        "Water table": ("Bucket", "Balde", "Cubo"),
        "Sieve": ("Jug", "Xerra", "Jarra"),
        "Calm sea": ("Sunny", "Soleado", "Soleado"),
        "Sea glass": ("Starfish", "Estrela de mar", "Estrella de mar"),
        "Driftwood": ("Stick", "Pau", "Palo"),
        "Stomp your boots in the puddles!": ("Stomp in the puddles!", "Pisa forte nas pozas!", "¡Pisa fuerte en los charcos!"),
        "Find a red circle! Touch it with your foot!": ("Touch the red circle!", "Toca o círculo vermello!", "¡Toca el círculo rojo!"),
        "We are tiny seeds under the ground": ("Tiny seeds, sleep!", "Sementiñas, a durmir!", "¡Semillitas, a dormir!"),
        "Little fish swimming under the sea!": ("Swim like a little fish!", "Nada coma un peixiño!", "¡Nada como un pececito!"),
    },
    "curso_3_4": {
        "steady": ("Still", "Quieto", "Quieto"),
        "rebuild": ("Build", "Construír", "Construir"),
        "Walk to the circle and sit down": ("Walk to the circle!", "Camiña ao círculo!", "¡Camina al círculo!"),
        "Spin around and fall down like a leaf": ("Spin and fall like a leaf", "Xira e cae coma unha folla", "Gira y cae como una hoja"),
        "Pick up two acorns and put them in the basket": ("Two acorns in the basket", "Dúas landras na cesta", "Dos bellotas en la cesta"),
        "The chestnut pops in the fire: jump!": ("Pop! Jump like a chestnut!", "Pop! Salta coma unha castaña!", "¡Pop! ¡Salta como una castaña!"),
        "Warm your hands and rub them fast": ("Rub your hands fast", "Frega as mans axiña", "Frota las manos rápido"),
        "Tiptoe quietly to blow out the light": ("Tiptoe and blow!", "De puntillas, e sopra!", "¡De puntillas, y sopla!"),
        "Tap your knees like rain falling fast": ("Tap your knees like rain", "Bate nos xeonllos coma a chuvia", "Golpea las rodillas como la lluvia"),
        "Put on your animal mask and roar": ("Mask on and roar!", "Ponte a máscara e brúa!", "¡Ponte la máscara y ruge!"),
        "Curl up small like a tiny seed": ("Curl up like a seed", "Encóllete coma unha semente", "Acurrúcate como una semilla"),
        "Gallop like a horse in the meadow": ("Gallop like a horse", "Galopa coma un cabalo", "Galopa como un caballo"),
        "Cross your hands and clap with your friend": ("Clap with your friend", "Aplaude co teu amigo", "Aplaude con tu amigo"),
        "Row your boat through the big waves": ("Row your boat!", "Rema na túa barca!", "¡Rema en tu barca!"),
        "Swim like a fast fish in the ría": ("Swim fast like a fish", "Nada rápido coma un peixe", "Nada rápido como un pez"),
        "Dive deep and find a white shell": ("Dive and find a shell", "Mergúllate e atopa unha cuncha", "Sumérgete y encuentra una concha"),
    },
    "curso_4_5": {
        "Motionless": ("Tired", "Canso", "Cansado"),
        "Sly": ("Furry", "Peludo", "Peludo"),
        "Nimble-footed": ("Quick", "Rápido", "Rápido"),
        "Alert": ("Awake", "Esperto", "Despierto"),
        "Hilltop": ("Hill", "Outeiro", "Colina"),
        "Downhill": ("Bumpy", "Con baches", "Con baches"),
        "Steep": ("Grassy", "Con herba", "Con hierba"),
        "examine": ("Listen", "Escoitar", "Escuchar"),
        "Frozen solid": ("Icy", "Xeado", "Helado"),
        "Brightest": ("Shiny", "Brillante", "Brillante"),
        "temperature": ("Gloves", "Luvas", "Guantes"),
        "Showery": ("Rainy", "Chuvioso", "Lluvioso"),
        "Underpass": ("Tunnel", "Túnel", "Túnel"),
        "Stage": ("Puppet", "Monicreque", "Títere"),
        "Sneak": ("Peek", "Asomar a cabeza", "Asomarse"),
        "Mysterious": ("Dark", "Escuro", "Oscuro"),
        "Knight": ("King", "Rei", "Rey"),
        "Seabird": ("Seagull", "Gaivota", "Gaviota"),
        "Gull chick": ("Nest", "Niño", "Nido"),
        "splashy": ("Slippery", "Esvaradío", "Resbaladizo"),
        "Fair": ("Kind", "Amable", "Amable"),
        "Sturdy": ("Solid", "Sólido", "Sólido"),
        "protect": ("Share", "Compartir", "Compartir"),
        "Evaporate": ("Melt", "Derreter", "Derretir"),
        "Mussel raft": ("Mussel", "Mexillón", "Mejillón"),
        "Rope line": ("Rope", "Corda", "Cuerda"),
        "Rushing": ("Fast", "Rápido", "Rápido"),
        "Deep blue": ("Salty", "Salgado", "Salado"),
        "Photo book": ("Photo", "Foto", "Foto"),
        "Walk like a sleepy bear with your heavy bag": ("Walk like a sleepy bear", "Camiña coma un oso con sono", "Camina como un oso con sueño"),
        "The bell rings: run to the circle and freeze!": ("Bell! Run and freeze!", "Campá! Corre e queda quieto!", "¡Campana! ¡Corre y quédate quieto!"),
        "Open your bag, take out your smock and smile": ("Open your bag and smile", "Abre a mochila e sorrí", "Abre la mochila y sonríe"),
        "Hop like a squirrel and collect the chestnuts": ("Hop like a squirrel", "Brinca coma un esquío", "Brinca como una ardilla"),
        "Climb the oak tree and hide your nuts": ("Climb and hide your nuts", "Rube e agocha as noces", "Trepa y esconde las nueces"),
        "The hedgehog wakes up: FREEZE and curl up small!": ("Hedgehog! Freeze and curl up!", "Ourizo! Quieto e enróscate!", "¡Erizo! ¡Quieto y enróscate!"),
        "Cold winter night: curl up and do not move": ("Cold night: curl up!", "Noite fría: enróscate!", "Noche fría: ¡enróscate!"),
        "Why are you putting the bandage? Because the cat is sick.": ("Why a bandage? The cat is sick.", "Por que unha venda? O gato está malo.", "¿Por qué una venda? El gato está malito."),
        "First we check the heart, then we wrap the bandage.": ("First the heart, then the bandage.", "Primeiro o corazón, despois a venda.", "Primero el corazón, luego la venda."),
        "I put on my boots because it is raining.": ("Boots on, because it rains.", "Botas postas, porque chove.", "Botas puestas, porque llueve."),
        "The storm is here: run and hide under the umbrella!": ("Storm! Hide under the umbrella!", "Treboada! Agóchate baixo o paraugas!", "¡Tormenta! ¡Escóndete bajo el paraguas!"),
        "The sun comes back: shake the water off": ("Sun! Shake the water off!", "Sol! Sacode a auga!", "¡Sol! ¡Sacude el agua!"),
        "Sneak quietly like a fox in the woods": ("Quiet like a fox!", "Caladiño coma un raposo!", "¡Calladito como un zorro!"),
        "Sleep in the flower until the sun wakes up": ("Sleep in the flower", "Durme na flor", "Duerme en la flor"),
        "Walk calmly like a sheep in the field": ("Walk calmly like a sheep", "Camiña tranquilo coma unha ovella", "Camina tranquilo como una oveja"),
        "Storm! Shake the sea with all your strength": ("Storm! Shake the sea!", "Treboada! Axita o mar!", "¡Tormenta! ¡Agita el mar!"),
        "The sea sleeps: put the cloth down and lie still": ("The sea sleeps: lie still", "O mar dorme: deitado e quieto", "El mar duerme: tumbado y quieto"),
    },
    "curso_5_6": {
        "Vote": ("Pick", "Escoller", "Elegir"),
        "Command": ("Turn", "Quenda", "Turno"),
        "Responsible": ("Tidy", "Ordenado", "Ordenado"),
        "creative": ("Colourful", "Colorido", "Colorido"),
        "Investigate": ("Search", "Buscar", "Buscar"),
        "blend": ("Mix", "Mesturar", "Mezclar"),
        "Stargaze": ("Look up", "Mirar arriba", "Mirar arriba"),
        "Balance beam": ("Bench", "Banco", "Banco"),
        "Fishing village": ("Harbour", "Porto", "Puerto"),
        "Dramatic": ("Happy", "Contento", "Contento"),
        "Director": ("Crown", "Coroa", "Corona"),
        "Symmetry": ("Same", "Igual", "Igual"),
        "journey": ("Holiday", "Vacacións", "Vacaciones"),
        "destination": ("Beach", "Praia", "Playa"),
        "passport": ("Hold on", "Agárrate", "Agárrate"),
        "Rhythmic": ("Noisy", "Ruidoso", "Ruidoso"),
        "explore": ("Discover", "Descubrir", "Descubrir"),
        "Memory lane": ("Picture", "Imaxe", "Imagen"),
        "Primary school": ("Big school", "A escola dos maiores", "El cole de mayores"),
        "Walk to the hook and hang up your coat": ("Hang up your coat on the hook", "Colga o abrigo no colgador", "Cuelga el abrigo en el perchero"),
        "Take the smock, turn around and give it to Noa": ("Take the smock and give it to Noa", "Colle o mandil e dállo a Noa", "Coge el babi y dáselo a Noa"),
        "Take a rough leaf and put it in the brown ring": ("Put a rough leaf in the ring", "Pon unha folla áspera no aro", "Pon una hoja áspera en el aro"),
        "Noa, walk slowly and give the smooth leaf to your friend": ("Give the smooth leaf to your friend", "Dálle a folla lisa ao teu amigo", "Dale la hoja lisa a tu amigo"),
        "Put the rough one here and the smooth one there": ("Rough one here, smooth one there", "A áspera aquí, a lisa alí", "La áspera aquí, la lisa allí"),
        "Here you go: give the light to the next pair": ("Here you go: pass the light", "Toma: pasa a luz", "Toma: pasa la luz"),
        "I am blending yellow and blue because I want to make green.": ("Yellow and blue make green!", "Amarelo e azul fan verde!", "¡Amarillo y azul hacen verde!"),
        "The brush is between the cup and the paper.": ("The brush is between the cup and paper.", "O pincel está entre o vaso e o papel.", "El pincel está entre el vaso y el papel."),
        "Step slowly and don't spill the water into the river": ("Step slowly, don't spill the water", "Pisa amodo, non verques a auga", "Pisa despacio, no derrames el agua"),
        "Ready, steady, go: pass the tray to your friend": ("Ready, steady, go: pass the tray!", "Preparados, listos, xa: pasa a bandexa!", "Preparados, listos, ya: ¡pasa la bandeja!"),
        "If the water is cold, walk to the blue mat": ("Cold water? Walk to the blue mat", "Auga fría? Camiña á alfombra azul", "¿Agua fría? Camina a la alfombra azul"),
        "Put your arms up and your left foot forward": ("Arms up, left foot forward", "Brazos arriba, pé esquerdo diante", "Brazos arriba, pie izquierdo delante"),
        "Fill the pot, plant the seed and water it": ("Fill the pot and plant the seed", "Enche o testo e planta a semente", "Llena la maceta y planta la semilla"),
        "Here you go: pass the soil to your friend": ("Here you go: pass the soil", "Toma: pasa a terra", "Toma: pasa la tierra"),
        "If the seed is big, put it in the brown pot": ("Big seed? Brown pot!", "Semente grande? Testo marrón!", "¿Semilla grande? ¡Maceta marrón!"),
        "Where does the fox hide? Point with your elbows": ("Where does the fox hide? Point!", "Onde se agocha o raposo? Sinala!", "¿Dónde se esconde el zorro? ¡Señala!"),
        "If it climbs the chestnut tree, crawl to the green mat": ("It climbs? Crawl to the green mat!", "Rube? Gatea á alfombra verde!", "¿Trepa? ¡Gatea a la alfombra verde!"),
        "We have to hurry because the train is leaving in front of us.": ("Hurry, the train is leaving!", "Présa, que o tren marcha!", "¡Deprisa, que el tren se va!"),
        "Noa, walk five steps and take the white shell": ("Walk five steps, take the shell", "Dá cinco pasos, colle a cuncha", "Da cinco pasos, coge la concha"),
        "If the shell is smooth, put it in the blue basket": ("Smooth shell? Blue basket!", "Cuncha lisa? Cesta azul!", "¿Concha lisa? ¡Cesta azul!"),
    },
}

# Las que NO se aplican: la palabra nueva ya está en el banco de 4.000 palabras
# de otra edad, y el modelo de Frank («5 cursos de 800 palabras, 4.000 sin
# repetir», tools/planificador_5_palabras.py) no deja que una palabra sea nueva
# dos veces. Decide Frank (O-20261126-5): o se deja volver una palabra sencilla
# de una edad anterior, o se queda la de ahora.
PENDENTES_FRANK = {
    ('curso_2_3', 'Roll up'),
    ('curso_2_3', 'Kneecap'),
    ('curso_2_3', 'Merry-go-round'),
    ('curso_2_3', 'Race track'),
    ('curso_2_3', 'Finish line'),
    ('curso_2_3', 'Stroll'),
    ('curso_2_3', 'Blow away'),
    ('curso_2_3', 'Tread'),
    ('curso_2_3', 'Jump in'),
    ('curso_2_3', 'Pour down'),
    ('curso_2_3', 'Pavement'),
    ('curso_2_3', 'Walrus'),
    ('curso_2_3', 'Oval'),
    ('curso_2_3', 'Cube'),
    ('curso_2_3', 'Sphere'),
    ('curso_2_3', 'Meadow'),
    ('curso_2_3', 'Blackbird'),
    ('curso_2_3', 'Library'),
    ('curso_2_3', 'Soap pump'),
    ('curso_2_3', 'Brush head'),
    ('curso_2_3', 'Water table'),
    ('curso_2_3', 'Sieve'),
    ('curso_2_3', 'Calm sea'),
    ('curso_2_3', 'Sea glass'),
    ('curso_2_3', 'Driftwood'),
    ('curso_3_4', 'steady'),
    ('curso_3_4', 'rebuild'),
    ('curso_4_5', 'Motionless'),
    ('curso_4_5', 'Sly'),
    ('curso_4_5', 'Alert'),
    ('curso_4_5', 'Downhill'),
    ('curso_4_5', 'Steep'),
    ('curso_4_5', 'examine'),
    ('curso_4_5', 'Frozen solid'),
    ('curso_4_5', 'Brightest'),
    ('curso_4_5', 'temperature'),
    ('curso_4_5', 'Showery'),
    ('curso_4_5', 'Underpass'),
    ('curso_4_5', 'Stage'),
    ('curso_4_5', 'Sneak'),
    ('curso_4_5', 'Mysterious'),
    ('curso_4_5', 'Knight'),
    ('curso_4_5', 'Seabird'),
    ('curso_4_5', 'Gull chick'),
    ('curso_4_5', 'splashy'),
    ('curso_4_5', 'Fair'),
    ('curso_4_5', 'Sturdy'),
    ('curso_4_5', 'protect'),
    ('curso_4_5', 'Evaporate'),
    ('curso_4_5', 'Mussel raft'),
    ('curso_4_5', 'Rope line'),
    ('curso_4_5', 'Rushing'),
    ('curso_4_5', 'Deep blue'),
    ('curso_4_5', 'Photo book'),
    ('curso_5_6', 'Vote'),
    ('curso_5_6', 'Responsible'),
    ('curso_5_6', 'creative'),
    ('curso_5_6', 'Investigate'),
    ('curso_5_6', 'blend'),
    ('curso_5_6', 'Stargaze'),
    ('curso_5_6', 'Balance beam'),
    ('curso_5_6', 'Fishing village'),
    ('curso_5_6', 'Dramatic'),
    ('curso_5_6', 'Director'),
    ('curso_5_6', 'Symmetry'),
    ('curso_5_6', 'journey'),
    ('curso_5_6', 'destination'),
    ('curso_5_6', 'passport'),
    ('curso_5_6', 'Rhythmic'),
    ('curso_5_6', 'explore'),
    ('curso_5_6', 'Memory lane'),
    ('curso_5_6', 'Primary school'),
}

# Frank, 26/11/2026: «Todo está aprobado y se debe hacer». Se aplican todas;
# la palabra que ya era nueva en otra edad vuelve aquí como repaso («volve»).
SUBST = PROPOSTAS
ORDE_CURSOS = ["curso_0_2", "curso_2_3", "curso_3_4", "curso_4_5", "curso_5_6"]

# Palabras o expresiones que el gate considera ajenas a la edad (las viejas).
ALLEAS = {c: set(t) for c, t in SUBST.items()}


def norm(en: str) -> str:
    return en.strip("!.?¡¿ ").lower()


def es_orde(vella: str) -> bool:
    return len(re.findall(r"[A-Za-z']+", vella)) > 2


def _texto(s: str, curso: str, sig_vello: dict) -> str:
    for vella, (nova, gl, es) in SUBST[curso].items():
        for a, b in (("“", "”"), ("«", "»")):
            tok = f"{a}{vella}{b}"
            if tok in s:
                s = s.replace(tok, f"{a}{nova}{b}")
                # El significado viejo, en la misma frase, por el nuevo.
                s = _gloss(s, vella, curso, sig_vello)
    return s


def _gloss(s: str, vella: str, curso: str, sig_vello: dict) -> str:
    nova, gl, es = SUBST[curso][vella]
    if es_orde(vella):
        return s
    for viejo, nuevo in zip(sig_vello.get(vella, ("", "")), (gl, es)):
        if not viejo:
            continue
        pat = re.compile(rf"\b{re.escape(viejo)}\b", re.I)
        s = pat.sub(lambda m: nuevo.lower() if m.group(0)[0].islower() else nuevo, s)
    return s


def significados_vellos() -> dict[str, tuple[str, str]]:
    """El significado de cada palabra vieja, tal como estaba en las lecciones."""
    d = json.loads((C / "leccions" / "leccions.json").read_text(encoding="utf-8"))
    sig = {}
    todas = {v for t in SUBST.values() for v in t}
    for c in d["cursos"].values():
        for u in c["unidades"]:
            for l in u["leccions"]:
                for k in ("novas", "xaSabe", "repasa"):
                    for p in l.get(k) or []:
                        if p["en"] in todas and p.get("gl"):
                            sig.setdefault(p["en"], (p["gl"], p.get("es", "")))
    return sig


def _peza(o: dict, curso: str, mapa: dict) -> dict:
    vella = o.get("en")
    if vella not in SUBST[curso]:
        return o
    nova, gl, es = SUBST[curso][vella]
    o = dict(o)
    o["en"] = nova
    for k, v in (("gl", gl), ("es", es)):
        if k in o:
            o[k] = v
    m = mapa.get(norm(nova))
    if "lamina" in o and m:
        o["lamina"] = m["clave"]
    if not es_orde(vella):
        # El gesto de la palabra vieja no vale para la nueva.
        for k in ("tprAction", "xesto"):
            if isinstance(o.get(k), dict):
                o[k] = {"gl": f"Sinala ou colle o que nomeas: {gl.lower()}.",
                        "es": f"Señala o coge lo que nombras: {es.lower()}."}
    return o


def _camiñar(x, curso: str, mapa: dict, sig: dict):
    if isinstance(x, dict):
        x = _peza(x, curso, mapa)
        return {k: _camiñar(v, curso, mapa, sig) for k, v in x.items()}
    if isinstance(x, list):
        return [_camiñar(v, curso, mapa, sig) for v in x]
    if isinstance(x, str):
        if x in SUBST[curso]:
            return SUBST[curso][x][0]
        return _texto(x, curso, sig)
    return x


def _vocab_clave(h: dict, curso: str, sig: dict) -> dict:
    """vocabularioClave(Es) son los significados de las palabras: los viejos, por los nuevos."""
    for k, i in (("vocabularioClave", 0), ("vocabularioClaveEs", 1)):
        if isinstance(h.get(k), list):
            out = []
            for v in h[k]:
                for vella, (nova, gl, es) in SUBST[curso].items():
                    if sig.get(vella, ("", ""))[i] == v:
                        v = (gl, es)[i]
                        break
                out.append(v)
            h[k] = out
    return h


def vocab_clave_dos_contos() -> None:
    """vocabularioClave(Es) de cada página, desde el banco TPR de su curso:
    el significado de cada palabra declarada, en su orden."""
    f = C / "cuentos" / "historias_progresivas.json"
    j = json.loads(f.read_text(encoding="utf-8"))
    for curso, t in SUBST.items():
        novas = {v[0] for v in t.values()}
        por_nova = {v[0]: (v[1], v[2]) for v in t.values()}
        sig = {}
        for tf in (C / "tpr" / curso).glob("tpr.*.json"):
            for s in json.loads(tf.read_text(encoding="utf-8")).get("semanas", []):
                for w in s["palabras"]:
                    sig[w["en"]] = (w.get("gl"), w.get("es"))
        for h in j:
            if h.get("cursoId") != curso:
                continue
            for pg in h.get("paginas", []):
                pal = pg.get("palabras") or []
                vk, ve = pg.get("vocabularioClave"), pg.get("vocabularioClaveEs")
                if not isinstance(vk, list) or not isinstance(ve, list) or len(vk) != len(pal):
                    continue
                for i, w in enumerate(pal):
                    if w in por_nova:
                        vk[i], ve[i] = por_nova[w]
                    elif w in novas and w in sig:
                        vk[i], ve[i] = sig[w]
    f.write_text(json.dumps(j, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def lamina_orde(mapa: dict) -> dict:
    """Entradas nuevas del mapa: cada orden corta, con la lámina de la larga."""
    novas = {}
    for curso, t in SUBST.items():
        for vella, (nova, _, _) in t.items():
            if norm(nova) in mapa:
                continue
            m = mapa.get(norm(vella))
            if m:
                novas[norm(nova)] = {
                    "clave": m["clave"], "orixe": "reutilizada",
                    "porque": f"Versión curta de «{vella}» para a idade (O-20261126-5): a mesma acción.",
                    "fuente": "propia", "asset": f"assets/brand/laminas/{m['clave']}.json",
                    "sha": "1973cc64", "licencia": "Propia", "revisado": True,
                }
    return novas


def marcar_volve() -> None:
    """En el banco TPR, la palabra que ya era nueva en una edad anterior lleva
    «volve»: la edad de la que vuelve. tools/planificador_5_palabras.py la
    cuenta como repaso, no como nueva otra vez."""
    vistas: dict[str, str] = {}
    for curso in ORDE_CURSOS:
        for f in sorted((C / "tpr" / curso).glob("tpr.*.json")):
            t_ = f.read_text(encoding="utf-8")
            j = json.loads(t_)
            for s in j.get("semanas", []):
                for w in s["palabras"]:
                    k = norm(w["en"])
                    if k in vistas and vistas[k] != curso:
                        w["volve"] = vistas[k]
                    else:
                        w.pop("volve", None)
                        vistas.setdefault(k, curso)
            novo = json.dumps(j, ensure_ascii=False, indent=2) + "\n"
            if novo != t_:
                f.write_text(novo, encoding="utf-8")


def ficheiros(curso: str):
    yield from sorted((C / "tpr" / curso).glob("*.json"))
    yield from sorted((C / "unidades_mes" / curso).glob("*.json"))


def aplicar(escribir: bool) -> list[str]:
    sig = significados_vellos() if escribir else {}
    mapa_j = json.loads(MAPA.read_text(encoding="utf-8"))
    mapa = mapa_j["pezas"]
    restos = []
    if escribir:
        mapa.update(lamina_orde(mapa))
        mapa_j["pezas"] = dict(sorted(mapa.items()))
        MAPA.write_text(json.dumps(mapa_j, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    for curso in SUBST:
        for f in ficheiros(curso):
            t = f.read_text(encoding="utf-8")
            j = json.loads(t)
            if escribir:
                novo = json.dumps(_camiñar(j, curso, mapa, sig), ensure_ascii=False, indent=2) + "\n"
                if novo != t and json.loads(novo) != j:
                    f.write_text(novo, encoding="utf-8")
            else:
                restos += [f"{f.relative_to(RAIZ)}: «{v}»" for v in SUBST[curso]
                           if f'"{v}"' in t or f"“{v}”" in t]
        # Cuentos y experimentos de este curso.
        for f, clave in ((C / "cuentos" / "historias_progresivas.json", "cursoId"),
                         (C / "steam" / "steam_do_mes.json", "curso")):
            j = json.loads(f.read_text(encoding="utf-8"))
            lista = j if isinstance(j, list) else j.get("experimentos", [])
            for i, h in enumerate(lista):
                if h.get(clave) != curso:
                    continue
                if escribir:
                    lista[i] = _vocab_clave(_camiñar(h, curso, mapa, sig), curso, sig)
                else:
                    s = json.dumps(h, ensure_ascii=False)
                    restos += [f"{f.name} {h.get('id')}: «{v}»" for v in SUBST[curso]
                               if f'"{v}"' in s or f"“{v}”" in s]
            if escribir:
                f.write_text(json.dumps(j, ensure_ascii=False, indent=2) + "\n",
                             encoding="utf-8")
        # El plan curricular y sus cuentos no van por curso: las palabras viejas
        # son de una sola edad, así que se cambian donde estén.
        for f in [C / "curriculo" / "tramo_3_6.json", *sorted((C / "biblioteca").glob("his_*.json"))]:
            t_ = f.read_text(encoding="utf-8")
            if escribir:
                j = _camiñar(json.loads(t_), curso, mapa, sig)
                ind = 2 if t_.startswith("{\n  ") or t_.startswith("[\n  ") else 1
                novo = json.dumps(j, ensure_ascii=False, indent=ind) + "\n"
                if json.loads(novo) != json.loads(t_):
                    f.write_text(novo, encoding="utf-8")
            else:
                restos += [f"{f.name}: «{v}»" for v in SUBST[curso] if f'"{v}"' in t_ or f"“{v}”" in t_]
        # La fuente de los cuentos.
        px = RAIZ / "tools" / f"paxinas_extra_{curso[6:]}.py"
        if px.exists():
            s = px.read_text(encoding="utf-8")
            if escribir:
                s2 = _texto(s, curso, sig)
                if s2 != s:
                    px.write_text(s2, encoding="utf-8")
            else:
                restos += [f"{px.name}: «{v}»" for v in SUBST[curso] if f"“{v}”" in s]
    return restos


def sustituir_leccions(curso: str, leccions: list[dict], mapa: dict) -> None:
    """Para tools/gen_leccions.py: cada pieza vieja de las lecciones del curso, por la nueva."""
    if curso not in SUBST:
        return
    for i, l in enumerate(leccions):
        leccions[i] = _camiñar(l, curso, mapa, {})


def main() -> int:
    if "--aplicar" in sys.argv:
        aplicar(True)
        vocab_clave_dos_contos()
        marcar_volve()
        print("Aplicado. Agora: python3 tools/gen_leccions.py e o resto da cadea.")
        return 0
    restos = aplicar(False)
    if restos:
        print("FALLO (vocabulario por idade): quedan palabras alleas á idade:\n  " + "\n  ".join(restos[:30]))
        return 1
    print(f"OK: {sum(len(t) for t in SUBST.values())} sustitucións aplicadas en 2-3 a 5-6.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
