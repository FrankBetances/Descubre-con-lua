#!/usr/bin/env python3
"""Generador del banco TPR (O-20261111-4, P2.81+).

Solo emite y marca `revisado: True` para piezas TPR explícitamente revisadas
contra su palabra (en/es) y su gesto (`REVISADAS_TPR`). Nunca marca `revisado`
de forma automática ni genera rellenos genéricos sin objeto.
"""
from __future__ import annotations

import hashlib
import json
import math
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

import banco_a_lamina as bal  # noqa: E402
from banco_comun import (  # noqa: E402
    ACOPROS_PATH,
    AGUA,
    AGUA_OSCURO,
    AMARILLO,
    AMARILLO_OSCURO,
    AZUL,
    AZUL_OSCURO,
    BARRO,
    BLANCO,
    FLUENT_SVGS,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    LAMINAS_DIR,
    LECCIONS_PATH,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
    MAR_PROF,
    MORADO,
    NUBE,
    NUBE_B,
    PEL,
    PELB,
    ROJO,
    ROJO_OSCURO,
    SHA_FLUENT,
    SHA_ICONIFY,
    SHA_PROPIA,
    TIERRA,
    TIERRA_CLARA,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    E,
    F,
    L,
    P,
    R,
    _round_forma,
    copos_nieve,
    escribir_fluent_directo,
    escribir_iconify_directo,
    fl,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    ico,
    nino,
    notas,
    pano,
    pompas,
    slug_de,
    sol,
    tubo,
)

SCRIPT_REF = "tools/gen_laminas_tpr.py"
TPR_DIR = RAIZ / "assets/content/tpr"

ROSA = "#ec4899"
ROSA_OSCURO = "#9d174d"
NARANJA = "#f97316"
NARANJA_OSCURO = "#c2410c"
NEGRO = "#1e293b"
DORADO = "#eab308"
PLATA = "#94a3b8"


# ── Banco directo curado y revisado (P2.81, verificado en hoja de contactos) ─
# k -> (fl_name, U/R, porque)
CURATED_FLUENT_DIRECTOS: dict[str, tuple[str, str, str]] = {
    "alarm clock": ("Alarm clock", "U", "Despertador rojo con dos campanas arriba."),
    "ambulance": ("Ambulance", "U", "Ambulancia blanca con luz azul y cruz roja."),
    "anchor": ("Anchor", "U", "Ancla metálica de barco."),
    "ant": ("Ant", "U", "Hormiga de perfil con seis patas."),
    "astronaut": ("Astronaut", "U", "Astronauta con casco espacial."),
    "balance scale": ("Balance scale", "U", "Balanza clásica de dos platillos."),
    "balloon": ("Balloon", "U", "Globo rojo flotando con su hilo."),
    "beach": ("Beach with umbrella", "R", "Playa de arena con sombrilla junto al mar."),
    "beans": ("Beans", "U", "Alubias marrones agrupadas."),
    "bed": ("Bed", "U", "Cama infantil con almohada y manta."),
    "beetle": ("Beetle", "U", "Escarabajo de perfil con patas."),
    "bird": ("Bird", "U", "Pájaro azul de perfil."),
    "birthday": ("Birthday cake", "R", "Tarta de cumpleaños con velas encendidas."),
    "blackbird": ("Blackbird", "U", "Mirlo negro con pico naranja."),
    "broccoli": ("Broccoli", "U", "Ramillete de brócoli verde."),
    "bubbles": ("Bubbles", "U", "Burbujas de jabón flotando."),
    "bucket": ("Bucket", "U", "Cubo azul con asa."),
    "bus": ("Bus", "U", "Autobús escolar amarillo con ruedas."),
    "bus stop": ("Bus stop", "U", "Poste de parada de autobús."),
    "butterfly": ("Butterfly", "U", "Mariposa azul de alas simétricas."),
    "calendar": ("Calendar", "U", "Calendario de hojas mensuales."),
    "castle": ("Castle", "U", "Castillo con torres y bandera."),
    "chair": ("Chair", "U", "Silla de madera de cuatro patas."),
    "cheese": ("Cheese wedge", "R", "Cuña de queso amarillo con agujeros."),
    "coin": ("Coin", "U", "Moneda dorada brillante."),
    "comet": ("Comet", "U", "Cometa celeste con estela luminosa."),
    "compass": ("Compass", "U", "Brújula con aguja señalando el norte."),
    "coral": ("Coral", "U", "Rama de coral marino rojo."),
    "crayon": ("Crayon", "U", "Cera de color rojo con funda."),
    "crocodile": ("Crocodile", "U", "Cocodrilo verde de perfil."),
    "crown": ("Crown", "U", "Corona dorada con joyas de colores."),
    "cucumber": ("Cucumber", "U", "Pepino verde fresco."),
    "deer": ("Deer", "U", "Ciervo de perfil con astas."),
    "dolphin": ("Dolphin", "U", "Delfín azul saltando."),
    "donkey": ("Donkey", "U", "Burro gris de perfil."),
    "door": ("Door", "U", "Puerta de madera con pomo."),
    "dragon": ("Dragon", "U", "Dragón verde con alas."),
    "droplet": ("Droplet", "U", "Gotita de agua azul."),
    "duck": ("Duck", "U", "Pato verde y marrón de perfil."),
    "egg": ("Egg", "U", "Huevo blanco ovalado."),
    "elephant": ("Elephant", "U", "Elefante gris con trompa."),
    "eyes": ("Eyes", "U", "Dos ojos abiertos mirando."),
    "farmer": ("Farmer", "U", "Granjero con sombrero de paja."),
    "feather": ("Feather", "U", "Pluma azul ligera."),
    "ferry": ("Ferry", "U", "Ferry navegando sobre el agua."),
    "fire": ("Fire", "U", "Llama de fuego cálida."),
    "fire engine": ("Fire engine", "U", "Camión de bomberos rojo."),
    "foggy": ("Foggy", "U", "Paisaje cubierto de niebla suave."),
    "fountain": ("Fountain", "U", "Fuente echando chorros de agua."),
    "giraffe": ("Giraffe", "U", "Jirafa alta de cuello largo."),
    "globe": ("Globe showing americas", "R", "Globo terráqueo azul y verde."),
    "gloves": ("Gloves", "U", "Par de guantes cálidos."),
    "goggles": ("Goggles", "U", "Gafas protectoras de bucear."),
    "gorilla": ("Gorilla", "U", "Gorila de perfil."),
    "graduation cap": ("Graduation cap", "U", "Birrete azul con borla."),
    "grapes": ("Grapes", "U", "Racimo de uvas moradas."),
    "guitar": ("Guitar", "U", "Guitarra acústica de madera."),
    "hamster": ("Hamster", "U", "Hámster tierno con mofletes."),
    "ice": ("Ice", "U", "Cubito de hielo azul brillante."),
    "ice cream": ("Ice cream", "U", "Helado en cucurucho."),
    "kangaroo": ("Kangaroo", "U", "Canguro saltando con bolsa."),
    "key": ("Key", "U", "Llave dorada antigua."),
    "kite": ("Kite", "U", "Cometa de papel volando con cola."),
    "kiwi": ("Kiwi fruit", "R", "Kiwi partido mostrando su interior verde."),
    "lab coat": ("Lab coat", "U", "Bata blanca de laboratorio."),
    "ladder": ("Ladder", "U", "Escalera de mano con peldaños."),
    "lemon": ("Lemon", "U", "Limón amarillo brillante."),
    "light bulb": ("Light bulb", "U", "Bombilla amarilla encendida."),
    "lion": ("Lion", "U", "León con melena dorada."),
    "lotion": ("Lotion bottle", "R", "Bote de crema hidratante con dosificador."),
    "lungs": ("Lungs", "U", "Pulmones rosados ilustrados."),
    "magnifying glass": ("Magnifying glass tilted left", "R", "Lupa con lente transparente."),
    "mango": ("Mango", "U", "Mango maduro amarillo y rojo."),
    "melon": ("Melon", "U", "Melón verde redondo."),
    "microphone": ("Microphone", "U", "Micrófono de mano."),
    "mirror": ("Mirror", "U", "Espejo de mano ovalado."),
    "monkey": ("Monkey", "U", "Mono marrón con cola larga."),
    "mountain": ("Mountain", "U", "Montaña alta con cumbre nevada."),
    "mouse": ("Mouse", "U", "Ratón blanco de orejas redondas."),
    "mouth": ("Mouth", "U", "Boca roja entreabierta."),
    "mushroom": ("Mushroom", "U", "Seta roja con lunares blancos."),
    "nesting dolls": ("Nesting dolls", "U", "Muñecas rusas encajables."),
    "nose": ("Nose", "U", "Nariz de perfil en tono piel."),
    "notebook": ("Notebook", "U", "Cuaderno escolar con espiral."),
    "octopus": ("Octopus", "U", "Pulpo rosado con tentáculos."),
    "olive": ("Olive", "U", "Aceituna verde brillante."),
    "otter": ("Otter", "U", "Nutria marrón tumbada."),
    "owl": ("Owl", "U", "Búho marrón de ojos grandes."),
    "palm tree": ("Palm tree", "U", "Palmera tropical con hojas verdes."),
    "parrot": ("Parrot", "U", "Loro de plumaje colorido."),
    "party": ("Party popper", "R", "Cañón de fiesta con confeti."),
    "paw prints": ("Paw prints", "U", "Dos huellas de pata de animal."),
    "peach": ("Peach", "U", "Melocotón rosado y naranja con hoja."),
    "pear": ("Pear", "U", "Pera verde madura."),
    "pencil": ("Pencil", "U", "Lápiz amarillo con goma rosa."),
    "penguin": ("Penguin", "U", "Pingüino blanco y negro."),
    "pig": ("Pig", "U", "Cerdito rosa de perfil."),
    "pineapple": ("Pineapple", "U", "Piña tropical con corona verde."),
    "playground": ("Playground slide", "R", "Tobogán infantil del patio."),
    "postbox": ("Postbox", "U", "Buzón rojo de correo."),
    "potato": ("Potato", "U", "Patata marrón ovalada."),
    "princess": ("Princess", "U", "Figura con corona de princesa."),
    "puzzle piece": ("Puzzle piece", "U", "Pieza de puzle encajable."),
    "rabbit": ("Rabbit", "U", "Conejo blanco de orejas largas."),
    "rainbow": ("Rainbow", "U", "Arcoíris de siete colores."),
    "ribbon": ("Ribbon", "U", "Lazo rojo de cinta."),
    "robot": ("Robot", "U", "Robot metálico simpático."),
    "rocket": ("Rocket", "U", "Cohete espacial despegando."),
    "rooster": ("Rooster", "U", "Gallo con cresta roja."),
    "sandwich": ("Sandwich", "U", "Sándwich de pan con lechuga y tomate."),
    "scarf": ("Scarf", "U", "Bufanda cálida roja."),
    "scientist": ("Scientist", "U", "Científica con gafas y bata."),
    "shooting star": ("Shooting star", "U", "Estrella fugaz con estela dorada."),
    "snail": ("Snail", "U", "Caracol con su concha en espiral."),
    "snowflake": ("Snowflake", "U", "Copo de nieve azul simétrico."),
    "snowman": ("Snowman", "U", "Muñeco de nieve con bufanda y sombrero."),
    "socks": ("Socks", "U", "Par de calcetines de rayas."),
    "spider": ("Spider", "U", "Araña negra con ocho patas."),
    "sponge": ("Sponge", "U", "Esponja amarilla porosa."),
    "star": ("Star", "U", "Estrella amarilla de cinco puntas."),
    "strawberry": ("Strawberry", "U", "Fresa roja con hojitas verdes."),
    "sunflower": ("Sunflower", "U", "Girasol amarillo de pétalos radiantes."),
    "sunglasses": ("Sunglasses", "U", "Gafas oscuras de sol."),
    "sunrise": ("Sunrise", "U", "Sol saliendo sobre las montañas."),
    "sweet potato": ("Roasted sweet potato", "R", "Boniato asado partido."),
    "taxi": ("Taxi", "U", "Taxi amarillo con ruedas."),
    "teacher": ("Teacher", "U", "Docente junto a la pizarra."),
    "teddy": ("Teddy bear", "R", "Osito de peluche suave."),
    "telescope": ("Telescope", "U", "Telescopio apoyado en trípode."),
    "thermometer": ("Thermometer", "U", "Termómetro rojo y blanco."),
    "thumbs up": ("Thumbs up", "U", "Mano haciendo el gesto del pulgar arriba."),
    "timer": ("Timer clock", "R", "Temporizador redondo con manecilla."),
    "tomato": ("Tomato", "U", "Tomate rojo brillante."),
    "tongue": ("Tongue", "U", "Lengua rosada sacada."),
    "tooth": ("Tooth", "U", "Diente blanco limpio."),
    "toothbrush": ("Toothbrush", "U", "Cepillo de dientes con pasta."),
    "tractor": ("Tractor", "U", "Tractor verde agrícola con ruedas grandes."),
    "tram": ("Tram", "U", "Tranvía urbano sobre raíles."),
    "turtle": ("Turtle", "U", "Tortuga verde con caparazón."),
    "water pistol": ("Water pistol", "U", "Pistola de agua de colores."),
    "watermelon": ("Watermelon", "U", "Tajada roja de sandía con pepitas."),
    "whale": ("Whale", "U", "Ballena azul soltando chorro de agua."),
    "wheel": ("Wheel", "U", "Rueda redonda con radios."),
    "wind chime": ("Wind chime", "U", "Campanillas de viento colgantes."),
    "window": ("Window", "U", "Ventana abierta mirando al cielo azul."),
    "wing": ("Wing", "U", "Ala blanca emplumada."),
    "worm": ("Worm", "U", "Lombriz rosada ondulada."),
    "zebra": ("Zebra", "U", "Cebra con rayas blancas y negras."),
    "caterpillar": ("Bug", "R", "Oruga verde segmentada avanzando."),
    "pine tree": ("Evergreen tree", "R", "Pino verde perenne."),
    "bowl": ("Bowl with spoon", "R", "Cuenco azul con cuchara."),
    "cherry": ("Cherries", "R", "Dos cerezas rojas con rabito verde."),
    "scooter": ("Kick scooter", "R", "Patinete de dos ruedas con manillar."),
    "motorbike": ("Motorcycle", "R", "Moto roja de dos ruedas."),
    "ballot box": ("Ballot box with ballot", "R", "Urna con papeleta entrando."),
    "ballet": ("Ballet shoes", "R", "Zapatillas rosas de ballet."),
}

CURATED_ICONIFY_DIRECTOS: dict[str, tuple[str, str, str, str, str]] = {
    "lighthouse": ("noto", "lighthouse", "U", "#1e293b", "Faro rayado con luz en lo alto."),
    "fairy": ("noto", "fairy", "U", "#1e293b", "Hada con alas y varita."),
    "superhero": ("noto", "superhero", "U", "#1e293b", "Figura de superhéroe con capa."),
}

from banco_comun import escribir_cd  # noqa: E402
from tpr_tandas import tanda_01, tanda_02, tanda_03, tanda_04, tanda_05, tanda_06  # noqa: E402

TANDAS: list[tuple[str, object]] = [
    ("P2.82", tanda_01),
    ("P2.83", tanda_02),
    ("P2.84", tanda_03),
    ("P2.85", tanda_04),
    ("P2.86", tanda_05),
    ("P2.87", tanda_06),
]

TANDA_FLUENT_DIRECTOS: dict[str, tuple[str, str, str]] = {}
TANDA_ICONIFY_DIRECTOS: dict[str, tuple[str, str, str, str, str, str]] = {}
TANDA_ESCENAS: dict[str, tuple[str, list[dict], str, str | None]] = {}
SIN_BASE_AUDIT: dict[str, tuple[str, str]] = {}

# Solo las piezas explícitamente revisadas contra palabra (en/es) y gesto pueden
# llevar `revisado: True`. Nunca se marca `revisado` de forma automática.
REVISADAS_TPR: dict[str, str] = {
    **{k: "P2.81: Fluent Flat directa revisada en hoja de contactos" for k in CURATED_FLUENT_DIRECTOS},
    **{k: "P2.81: Iconify Noto directa revisada en hoja de contactos" for k in CURATED_ICONIFY_DIRECTOS},
}

for _paso, _mod in TANDAS:
    for _k, _v in getattr(_mod, "DIRECTOS_FL", {}).items():
        if _k in CURATED_FLUENT_DIRECTOS or _k in TANDA_FLUENT_DIRECTOS:
            raise RuntimeError(f"Clave Fluent duplicada en {_paso}: {_k!r}")
        TANDA_FLUENT_DIRECTOS[_k] = _v
        REVISADAS_TPR[_k] = f"{_paso}: Fluent Flat directa revisada palabra+gesto"
    for _k, _v in getattr(_mod, "DIRECTOS_ICO", {}).items():
        if _k in CURATED_ICONIFY_DIRECTOS or _k in TANDA_ICONIFY_DIRECTOS:
            raise RuntimeError(f"Clave Iconify duplicada en {_paso}: {_k!r}")
        TANDA_ICONIFY_DIRECTOS[_k] = _v
        REVISADAS_TPR[_k] = f"{_paso}: Iconify directa revisada palabra+gesto"
    for _k, _v in getattr(_mod, "ESCENAS", {}).items():
        if _k in TANDA_ESCENAS or _k in REVISADAS_TPR:
            raise RuntimeError(f"Clave escena duplicada en {_paso}: {_k!r}")
        TANDA_ESCENAS[_k] = _v
        REVISADAS_TPR[_k] = f"{_paso}: Escena compuesta/propia revisada palabra+gesto"
    for _k, _motivo in getattr(_mod, "SIN_BASE", {}).items():
        if _k in REVISADAS_TPR:
            raise RuntimeError(f"Clave en SIN_BASE también revisada en {_paso}: {_k!r}")
        SIN_BASE_AUDIT[_k] = (_paso, _motivo)

ALL_FLUENT_DIRECTOS: dict[str, tuple[str, str, str]] = {
    **CURATED_FLUENT_DIRECTOS,
    **TANDA_FLUENT_DIRECTOS,
}
ALL_ICONIFY_DIRECTOS: dict[str, tuple[str, str, str, str, str, str]] = {
    **{k: (s, n, ur, col, "", pq) for k, (s, n, ur, col, pq) in CURATED_ICONIFY_DIRECTOS.items()},
    **TANDA_ICONIFY_DIRECTOS,
}


def _non_tpr_keys() -> set[str]:
    keys: set[str] = set()
    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    for c in lec["cursos"].values():
        for u in c["unidades"]:
            for l in u["leccions"]:
                for b in ("xaSabe", "novas", "repasa"):
                    for p in l.get(b) or []:
                        keys.add(p["en"].lower().strip(" .!?"))
                f = l.get("fraseGramatica")
                if f:
                    keys.add(f["en"].lower().strip(" .!?"))
    ac = json.loads(ACOPROS_PATH.read_text(encoding="utf-8"))
    for p in ac["proxectos"]:
        for w in p["palabras"]:
            keys.add(w["en"].lower().strip(" .!?"))
        keys.add(p["cancion"]["es"].lower().strip(" .!?"))
        keys.add(p["rima"]["en"].lower().strip(" .!?"))
    from gen_laminas_palabras import DEBUXOS
    for k in DEBUXOS:
        keys.add(k)
    return keys


def _escribir_sin_base(tpr_items: dict[str, dict]) -> None:
    out_path = RAIZ / "docs/tpr_sin_base.md"
    lines = [
        "# Piezas TPR sin base visual clara (O-20261111-4, P2.82+)",
        "",
        "Generado automáticamente por `tools/gen_laminas_tpr.py`. Estas piezas fueron",
        "auditadas manualmente contra su palabra (`en`/`es`) y su gesto (`tprAction`) y",
        "se dejan **sin lámina** para no inventar contenido ni usar pictogramas abstractos",
        "o engañosos (R∞.3).",
        "",
        f"Total piezas auditadas sin base visual hasta ahora: **{len(SIN_BASE_AUDIT)}**.",
        "",
        "| Tanda | Pieza (`en`) | `es` | Categoría | Gesto TPR | Motivo sin lámina |",
        "| --- | --- | --- | --- | --- | --- |",
    ]
    for k in sorted(SIN_BASE_AUDIT):
        paso, motivo = SIN_BASE_AUDIT[k]
        it = tpr_items.get(k)
        if not it:
            raise RuntimeError(f"Pieza SIN_BASE {k!r} no existe en tpr_items")
        en = it["en"].replace("|", "/")
        es = it["es"].replace("|", "/")
        cat = it["cat"]
        tpr = it["tpr"].replace("|", "/")
        mot = motivo.replace("|", "/")
        lines.append(f"| {paso} | {en} | {es} | {cat} | {tpr} | {mot} |")
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def generar() -> None:
    data = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas: dict = data.get("pezas") or {}
    non_tpr = _non_tpr_keys()

    # Conservar claves ya cubiertas por lecciones/acopros/palabras y sus slugs
    used_claves: set[str] = set()
    for k, v in pezas.items():
        if k in non_tpr:
            used_claves.add(v["clave"])
    for p in LAMINAS_DIR.glob("escena_*"):
        used_claves.add(p.stem)

    # Recoger TODAS las piezas de TPR que no están en non_tpr
    tpr_items: dict[str, dict] = {}
    for fich in sorted(TPR_DIR.rglob("*.json")):
        d = json.loads(fich.read_text(encoding="utf-8"))
        for s in d.get("semanas") or []:
            for w in s.get("palabras") or []:
                k = w["en"].lower().strip(" .!?")
                if k in non_tpr:
                    continue
                if k not in tpr_items:
                    tpr_t = w["tprAction"]["es"] if isinstance(w.get("tprAction"), dict) else str(w.get("tprAction", ""))
                    tpr_items[k] = {
                        "k": k,
                        "en": w["en"],
                        "es": w.get("es", ""),
                        "gl": w.get("gl", ""),
                        "cat": w.get("category", ""),
                        "tpr": tpr_t,
                    }

    for k in REVISADAS_TPR:
        if k in non_tpr:
            raise RuntimeError(f"Pieza {k!r} de REVISADAS_TPR colisiona con non_tpr (P2.1-P2.7)")
        if k not in tpr_items:
            raise RuntimeError(f"Pieza {k!r} de REVISADAS_TPR no existe en banco TPR")

    # Eliminar de `pezas` toda pieza TPR-only no incluida explícitamente en REVISADAS_TPR
    for k in list(pezas.keys()):
        if k not in non_tpr and k not in REVISADAS_TPR:
            del pezas[k]

    stats = {"U": 0, "R": 0, "C": 0, "D": 0}
    omitidas = 0
    for k in sorted(tpr_items):
        if k not in REVISADAS_TPR:
            omitidas += 1
            continue
        item = tpr_items[k]
        base = slug_de(item["en"]) or "tpr_pieza"
        if f"pal_{base}" not in used_claves:
            slug = base
        else:
            h = hashlib.sha1(k.encode("utf-8")).hexdigest()[:5]
            slug = f"{base[:42]}_{h}"
        used_claves.add(f"pal_{slug}")

        if k in ALL_FLUENT_DIRECTOS:
            fl_name, ur, porque = ALL_FLUENT_DIRECTOS[k]
            if FLUENT_SVGS:
                escribir_fluent_directo(pezas, k, slug, fl_name, ur, porque)
                pezas[k]["revisado"] = True
            else:
                if k not in pezas or not (LAMINAS_DIR / f"{pezas[k]['clave']}.json").is_file():
                    raise RuntimeError(f"Falta lámina en disco para revisada Fluent {k!r} sin /tmp/banco_src")
                pezas[k]["revisado"] = True
            stats[ur] += 1
        elif k in ALL_ICONIFY_DIRECTOS:
            iset, iname, ur, cur_col, autor, porque = ALL_ICONIFY_DIRECTOS[k]
            if (RAIZ / "tools/banco/iconify-icon-sets").is_dir() and Path("/tmp/banco_src/iconify/json").is_dir():
                escribir_iconify_directo(pezas, k, slug, iset, iname, ur, porque, current_color=cur_col, autor=autor)
                pezas[k]["revisado"] = True
            else:
                if k not in pezas or not (LAMINAS_DIR / f"{pezas[k]['clave']}.json").is_file():
                    raise RuntimeError(f"Falta lámina en disco para revisada Iconify {k!r} sin /tmp/banco_src")
                pezas[k]["revisado"] = True
            stats[ur] += 1
        elif k in TANDA_ESCENAS:
            cd, formas, porque, lic_override = TANDA_ESCENAS[k]
            if cd not in ("C", "D"):
                raise RuntimeError(f"Clasificación inválida {cd!r} para escena {k!r}")
            escribir_cd(pezas, k, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=item["en"])
            if lic_override:
                pezas[k]["licencia"] = lic_override
                if lic_override in ("Apache-2.0", "CC-BY-3.0", "CC-BY-4.0", "CC0-1.0"):
                    pezas[k]["sha"] = SHA_ICONIFY
                elif lic_override == "MIT" and "tabler" in str(formas) and "fluent" not in str(formas):
                    pezas[k]["sha"] = SHA_ICONIFY
                if lic_override == "CC-BY-3.0":
                    pezas[k]["autor"] = "GameIcons contributors"
            pezas[k]["revisado"] = True
            stats[cd] += 1
        else:
            raise RuntimeError(f"Pieza {k!r} en REVISADAS_TPR sin generador registrado")

    # Borrar ficheros pal_*.json de piezas TPR eliminadas (sin tocar non_tpr ni escena_*)
    claves_activas = {v["clave"] for v in pezas.values()}
    borradas = 0
    for p in sorted(LAMINAS_DIR.glob("pal_*.json")):
        if p.stem not in claves_activas:
            p.unlink()
            borradas += 1

    data["pezas"] = dict(sorted(pezas.items()))
    MAPA_PATH.write_text(json.dumps(data, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    _escribir_sin_base(tpr_items)
    cubiertas = sum(stats.values())
    print(f"OK gen_laminas_tpr: {cubiertas} pezas TPR revisadas -> {stats}; {omitidas} sen lámina ({len(SIN_BASE_AUDIT)} auditadas sin base); {borradas} ficheiros borrados.")


if __name__ == "__main__":
    generar()
