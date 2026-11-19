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

# Solo las piezas explícitamente revisadas contra palabra (en/es) y gesto pueden
# llevar `revisado: True`. Nunca se marca `revisado` de forma automática.
REVISADAS_TPR: dict[str, str] = {
    **{k: "P2.81: Fluent Flat directa revisada en hoja de contactos" for k in CURATED_FLUENT_DIRECTOS},
    **{k: "P2.81: Iconify Noto directa revisada en hoja de contactos" for k in CURATED_ICONIFY_DIRECTOS},
}


# ── Helpers vectoriales Lúa reutilizables ─────────────────────────────────
def bebe(cx: float, cy: float, manta: str = "#bae6fd", borde: str = AGUA_OSCURO, mirando: int = 1) -> list[dict]:
    """Bebé tierno estilizado en estilo plano Lúa."""
    return [
        E(cx, cy + 8, 12, 8, manta, borde, 2.0),
        E(cx - 10 * mirando, cy + 1, 7.5, 7.5, PEL, PELB, 2.0),
        L(f"M{cx - 10 * mirando - 2} {cy - 5} Q{cx - 10 * mirando} {cy - 9} {cx - 10 * mirando + 2} {cy - 6}", BARRO, 1.8),
        E(cx - 10 * mirando - 2.2, cy + 0.5, 1.0, 1.3, TINTA),
        E(cx - 10 * mirando + 2.2, cy + 0.5, 1.0, 1.3, TINTA),
        L(f"M{cx - 10 * mirando - 2} {cy + 3.8} Q{cx - 10 * mirando} {cy + 5.6} {cx - 10 * mirando + 2} {cy + 3.8}", "#9a3412", 1.3),
    ]


def nino_acostado(x: float, y: float, col: tuple[str, str] = (ROJO, ROJO_OSCURO)) -> list[dict]:
    """Niño tumbado plano horizontal (sin diagonales deformadas)."""
    return [
        R(x, y + 4, 24, 9, 4, AZUL, AZUL_OSCURO, 2.0),
        E(x - 2, y + 8, 4.5, 3.0, "#1f2937"),
        R(x + 22, y + 2, 22, 12, 5, col[0], col[1], 2.0),
        E(x + 51, y + 6, 8, 8, PEL, PELB, 2.0),
        F(f"M{x + 44} {y + 3} C{x + 45} {y - 4} {x + 58} {y - 4} {x + 59} {y + 4} Z", BARRO),
        E(x + 53, y + 6, 1.1, 1.3, TINTA),
        L(f"M{x + 50} {y + 10} Q{x + 53} {y + 12} {x + 56} {y + 10}", "#9a3412", 1.4),
        R(x + 30, y + 12, 12, 5, 2.5, PEL, PELB, 1.6),
    ]


def nino_gateando(x: float, y: float, mira: int = 1, col: tuple[str, str] = (VERDE, VERDE_OSCURO)) -> list[dict]:
    """Niño gateando horizontalmente sobre manos y rodillas."""
    hx = x + 48 if mira > 0 else x + 12
    bx0 = x + 12 if mira > 0 else x + 22
    leg_x = x + 14 if mira > 0 else x + 44
    arm_x = x + 40 if mira > 0 else x + 20
    return [
        R(leg_x, y + 12, 6, 14, 3, AZUL, AZUL_OSCURO, 1.8),
        R(arm_x, y + 12, 5, 14, 2.5, PEL, PELB, 1.8),
        R(bx0, y + 4, 28, 12, 6, col[0], col[1], 2.0),
        E(hx, y + 4, 8, 8, PEL, PELB, 2.0),
        F(f"M{hx - 7} {y + 2} C{hx - 6} {y - 6} {hx + 7} {y - 6} {hx + 8} {y + 2} Z", BARRO),
        E(hx + 3 * mira, y + 4, 1.1, 1.4, TINTA),
        L(f"M{hx + 1 * mira} {y + 8} Q{hx + 3 * mira} {y + 10} {hx + 5 * mira} {y + 8}", "#9a3412", 1.4),
    ]


def arco_giro(cx: float, cy: float, r: float = 20, col: str = AZUL_OSCURO) -> list[dict]:
    """Dos arcos con puntas de flecha indicando rotación."""
    return [
        L(f"M{cx - r:.1f} {cy - 4:.1f} Q{cx:.1f} {cy - r:.1f} {cx + r:.1f} {cy - 4:.1f}", col, 2.4),
        P([(cx + r - 3, cy - 8), (cx + r + 3, cy - 3), (cx + r - 4, cy + 1)], col),
        L(f"M{cx + r:.1f} {cy + 4:.1f} Q{cx:.1f} {cy + r:.1f} {cx - r:.1f} {cy + 4:.1f}", col, 2.4),
        P([(cx - r + 3, cy + 8), (cx - r - 3, cy + 3), (cx - r + 4, cy - 1)], col),
    ]


def ondas_sonido(x: float, y: float, col: str = AZUL_OSCURO, dir_x: int = 1) -> list[dict]:
    return [
        L(f"M{x:.1f} {y - 5:.1f} Q{x + 5 * dir_x:.1f} {y:.1f} {x:.1f} {y + 5:.1f}", col, 2.2),
        L(f"M{x + 5 * dir_x:.1f} {y - 9:.1f} Q{x + 12 * dir_x:.1f} {y:.1f} {x + 5 * dir_x:.1f} {y + 9:.1f}", col, 2.2),
    ]


def lineas_viento(x: float, y: float, w: float = 26, col: str = "#0284c7") -> list[dict]:
    return [
        L(f"M{x:.1f} {y - 6:.1f} Q{x + w * 0.5:.1f} {y - 10:.1f} {x + w:.1f} {y - 6:.1f}", col, 2.2),
        L(f"M{x + 2:.1f} {y:.1f} Q{x + w * 0.55:.1f} {y + 4:.1f} {x + w + 4:.1f} {y:.1f}", col, 2.2),
        L(f"M{x:.1f} {y + 6:.1f} Q{x + w * 0.45:.1f} {y + 2:.1f} {x + w - 2:.1f} {y + 6:.1f}", col, 2.0),
    ]


def ondas_calor(x: float, y: float, col: str = ROJO) -> list[dict]:
    o = []
    for dx in (0, 10, 20):
        px = x + dx
        o.append(L(f"M{px:.1f} {y + 14:.1f} Q{px - 4:.1f} {y + 7:.1f} {px:.1f} {y:.1f} Q{px + 4:.1f} {y - 6:.1f} {px:.1f} {y - 12:.1f}", col, 2.2))
    return o


def mesa_prop(x: float, y: float, w: float = 52, h: float = 24) -> list[dict]:
    return [
        R(x + 4, y + 6, 4.5, h - 6, 1, MADERA_OSCURA),
        R(x + w - 8.5, y + 6, 4.5, h - 6, 1, MADERA_OSCURA),
        R(x, y, w, 7, 2.5, MADERA, MADERA_OSCURA, 1.8),
    ]


def caja_prop(x: float, y: float, s: float = 30, col: str = "#eab308", borde: str = MADERA_OSCURA) -> list[dict]:
    return [
        R(x, y, s, s * 0.85, 3, col, borde, 2.0),
        R(x - 2, y - 4, s + 4, 7, 2, "#fde047", borde, 1.8),
        L(f"M{x + s * 0.5:.1f} {y - 4:.1f} L{x + s * 0.5:.1f} {y + s * 0.85:.1f}", ROJO, 2.5),
    ]


def pelota_prop(cx: float, cy: float, r: float = 13, col: str = ROJO, borde: str = ROJO_OSCURO) -> list[dict]:
    return [
        E(cx, cy, r, r, col, borde, 2.2),
        E(cx - r * 0.32, cy - r * 0.32, r * 0.25, r * 0.18, BLANCO),
    ]


def tambor_prop(x: float, y: float, s: float = 32) -> list[dict]:
    return [
        R(x, y + 5, s, s * 0.65, 4, ROJO, ROJO_OSCURO, 2.0),
        E(x + s / 2, y + 6, s / 2, s * 0.18, "#fef3c7", MADERA_OSCURA, 2.0),
        L(f"M{x + 5:.1f} {y + 10:.1f} L{x + s * 0.5:.1f} {y + s * 0.65:.1f} L{x + s - 5:.1f} {y + 10:.1f}", AMARILLO, 2.0),
        L(f"M{x - 4:.1f} {y - 4:.1f} L{x + s * 0.4:.1f} {y + 5:.1f}", MADERA_OSCURA, 2.5),
        E(x + s * 0.4, y + 5, 2.8, 2.8, BLANCO, MADERA_OSCURA, 1.2),
    ]


def libro_prop(x: float, y: float, s: float = 34, col: str = AZUL) -> list[dict]:
    return [
        R(x, y + 2, s * 0.5, s * 0.72, 2, col, AZUL_OSCURO, 1.8),
        R(x + s * 0.5, y + 2, s * 0.5, s * 0.72, 2, col, AZUL_OSCURO, 1.8),
        R(x + 2, y + 4, s * 0.46, s * 0.62, 1, BLANCO, GRIS, 1.2),
        R(x + s * 0.52, y + 4, s * 0.46, s * 0.62, 1, BLANCO, GRIS, 1.2),
    ]


def vaso_prop(x: float, y: float, s: float = 28, lleno: float = 0.6) -> list[dict]:
    w, h = s * 0.8, s
    o = [
        F(f"M{x:.1f} {y:.1f} L{x + w:.1f} {y:.1f} L{x + w - 3:.1f} {y + h:.1f} L{x + 3:.1f} {y + h:.1f} Z", "#e0f2fe", AZUL_OSCURO, 2.0)
    ]
    if lleno > 0:
        nh = (h - 5) * lleno
        ny = y + h - nh - 2
        o.append(F(f"M{x + 3:.1f} {ny:.1f} L{x + w - 3:.1f} {ny:.1f} L{x + w - 4:.1f} {y + h - 2:.1f} L{x + 4:.1f} {y + h - 2:.1f} Z", AGUA, AGUA_OSCURO, 1.2))
    return o


def plato_prop(cx: float, cy: float, r: float = 16) -> list[dict]:
    return [E(cx, cy, r, r * 0.65, BLANCO, GRIS_OSCURO, 2.2), E(cx, cy, r * 0.62, r * 0.38, "#f8fafc", GRIS, 1.5)]


def cuchara_prop(x: float, y: float, s: float = 28) -> list[dict]:
    return [
        L(f"M{x + s * 0.4:.1f} {y + s * 0.85:.1f} L{x + s * 0.58:.1f} {y + s * 0.32:.1f}", GRIS_OSCURO, 3.0),
        E(x + s * 0.62, y + s * 0.22, s * 0.16, s * 0.22, GRIS, GRIS_OSCURO, 1.8),
    ]


def olla_prop(x: float, y: float, s: float = 34) -> list[dict]:
    return [
        R(x, y + s * 0.25, s, s * 0.6, 5, GRIS_OSCURO, NEGRO, 2.0),
        R(x - 4, y + s * 0.35, 5, 4, 2, GRIS_OSCURO),
        R(x + s - 1, y + s * 0.35, 5, 4, 2, GRIS_OSCURO),
        R(x - 1, y + s * 0.18, s + 2, 5, 2, GRIS, NEGRO, 1.8),
        R(x + s * 0.4, y + s * 0.08, s * 0.2, 4, 2, NEGRO),
    ]


def columpio_prop(x: float, y: float, s: float = 40) -> list[dict]:
    return [
        L(f"M{x + 4:.1f} {y:.1f} L{x + 12:.1f} {y + s * 0.72:.1f}", GRIS_OSCURO, 2.0),
        L(f"M{x + s - 4:.1f} {y:.1f} L{x + s - 12:.1f} {y + s * 0.72:.1f}", GRIS_OSCURO, 2.0),
        R(x + 8, y + s * 0.72, s - 16, 6, 2.5, ROJO, ROJO_OSCURO, 1.8),
    ]


def tunel_prop(x: float, y: float, s: float = 44) -> list[dict]:
    return [
        E(x + s * 0.5, y + s * 0.55, s * 0.45, s * 0.35, ROJO, ROJO_OSCURO, 2.0),
        E(x + s * 0.22, y + s * 0.55, s * 0.18, s * 0.28, NEGRO, ROJO_OSCURO, 2.0),
    ]


def puente_prop(x: float, y: float, s: float = 48) -> list[dict]:
    return [
        R(x, y + s * 0.45, s, s * 0.28, 2, AGUA, AGUA_OSCURO, 1.5),
        F(f"M{x + 4:.1f} {y + s * 0.45:.1f} Q{x + s * 0.5:.1f} {y:.1f} {x + s - 4:.1f} {y + s * 0.45:.1f} L{x + s - 4:.1f} {y + s * 0.55:.1f} Q{x + s * 0.5:.1f} {y + s * 0.2:.1f} {x + 4:.1f} {y + s * 0.55:.1f} Z", MADERA, MADERA_OSCURA, 2.0),
    ]


def valla_prop(x: float, y: float, s: float = 44) -> list[dict]:
    o = [R(x, y + s * 0.22, s, 5, 1, MADERA, MADERA_OSCURA, 1.5), R(x, y + s * 0.52, s, 5, 1, MADERA, MADERA_OSCURA, 1.5)]
    for dx in (4, s * 0.36, s * 0.68):
        o.append(R(x + dx, y + 4, 8, s * 0.72, 2, TIERRA_CLARA, BARRO, 1.6))
    return o


def rampa_prop(x: float, y: float, s: float = 48) -> list[dict]:
    return [
        P([(x, y + s * 0.72), (x + s, y + s * 0.72), (x + s, y + s * 0.2)], TIERRA_CLARA, BARRO, 2.2),
    ]


def silbato_prop(x: float, y: float, s: float = 32) -> list[dict]:
    return [
        R(x + s * 0.45, y + s * 0.22, s * 0.5, s * 0.26, 2, GRIS, GRIS_OSCURO, 2.0),
        E(x + s * 0.34, y + s * 0.45, s * 0.28, s * 0.28, GRIS, GRIS_OSCURO, 2.0),
        E(x + s * 0.34, y + s * 0.45, s * 0.1, s * 0.1, NEGRO),
    ]


def peonza_prop(x: float, y: float, s: float = 34) -> list[dict]:
    cx = x + s * 0.5
    return [
        R(cx - 2.5, y + 4, 5, 8, 2, MADERA, MADERA_OSCURA, 1.5),
        P([(x + 4, y + 12), (x + s - 4, y + 12), (cx, y + s * 0.85)], ROJO, ROJO_OSCURO, 2.0),
        L(f"M{x + 8:.1f} {y + 18:.1f} L{x + s - 8:.1f} {y + 18:.1f}", AMARILLO, 2.5),
        L(f"M{cx:.1f} {y + s * 0.85:.1f} L{cx:.1f} {y + s * 0.94:.1f}", GRIS_OSCURO, 2.2),
    ]


def papelera_prop(x: float, y: float, s: float = 32) -> list[dict]:
    return [
        F(f"M{x + 4:.1f} {y + 8:.1f} L{x + s - 4:.1f} {y + 8:.1f} L{x + s - 7:.1f} {y + s * 0.9:.1f} L{x + 7:.1f} {y + s * 0.9:.1f} Z", VERDE, VERDE_OSCURO, 2.0),
        R(x + 2, y + 4, s - 4, 5, 2, VERDE_OSCURO),
    ]


def cubo_3d_prop(x: float, y: float, s: float = 30, col: str = AZUL) -> list[dict]:
    return [
        R(x + 4, y + 8, s * 0.65, s * 0.65, 2, col, AZUL_OSCURO, 1.8),
        P([(x + 4, y + 8), (x + 12, y + 2), (x + 12 + s * 0.65, y + 2), (x + 4 + s * 0.65, y + 8)], "#93c5fd", AZUL_OSCURO, 1.8),
        P([(x + 4 + s * 0.65, y + 8), (x + 12 + s * 0.65, y + 2), (x + 12 + s * 0.65, y + 2 + s * 0.65), (x + 4 + s * 0.65, y + 8 + s * 0.65)], "#1d4ed8", AZUL_OSCURO, 1.8),
    ]


def cilindro_prop(x: float, y: float, s: float = 30, col: str = ROJO) -> list[dict]:
    return [
        R(x + 6, y + 8, s * 0.6, s * 0.68, 2, col, ROJO_OSCURO, 1.8),
        E(x + 6 + s * 0.3, y + 8, s * 0.3, 4.5, "#fca5a5", ROJO_OSCURO, 1.8),
        E(x + 6 + s * 0.3, y + 8 + s * 0.68, s * 0.3, 4.5, col, ROJO_OSCURO, 1.8),
    ]


def cono_prop(x: float, y: float, s: float = 30, col: str = NARANJA) -> list[dict]:
    cx = x + s * 0.5
    return [
        P([(cx, y + 2), (x + 4, y + s * 0.82), (x + s - 4, y + s * 0.82)], col, NARANJA_OSCURO, 2.0),
        E(cx, y + s * 0.82, s * 0.38, 4, col, NARANJA_OSCURO, 1.8),
    ]


def campana_custom(x: float, y: float, s: float = 30) -> list[dict]:
    return fl("Bell", x, y, s)


def piedra_prop(x: float, y: float, s: float = 28) -> list[dict]:
    return [
        E(x + s * 0.5, y + s * 0.55, s * 0.42, s * 0.28, GRIS, GRIS_OSCURO, 2.0),
        E(x + s * 0.35, y + s * 0.46, s * 0.14, s * 0.08, "#e2e8f0"),
    ]


def concha_prop(x: float, y: float, s: float = 30) -> list[dict]:
    return fl("Spiral shell", x, y, s)


def hoja_prop(x: float, y: float, s: float = 30) -> list[dict]:
    return fl("Leaf fluttering in wind", x, y, s)


def arbol_prop(x: float, y: float, s: float = 38) -> list[dict]:
    return fl("Deciduous tree", x, y, s)


def bellota_prop(x: float, y: float, s: float = 28) -> list[dict]:
    cx = x + s * 0.5
    return [
        E(cx, y + s * 0.6, s * 0.26, s * 0.32, TIERRA_CLARA, BARRO, 1.8),
        E(cx, y + s * 0.32, s * 0.32, s * 0.16, BARRO, NEGRO, 1.6),
        L(f"M{cx:.1f} {y + s * 0.18:.1f} L{cx + 2:.1f} {y + s * 0.06:.1f}", BARRO, 2.4),
    ]


def semilla_prop(x: float, y: float, s: float = 24) -> list[dict]:
    cx = x + s * 0.5
    return [
        E(cx, y + s * 0.55, s * 0.18, s * 0.26, TIERRA, BARRO, 1.8),
        L(f"M{cx:.1f} {y + s * 0.3:.1f} Q{cx + 5:.1f} {y + s * 0.12:.1f} {cx + 8:.1f} {y + s * 0.18:.1f}", VERDE_OSCURO, 2.0),
    ]


def manta_prop(x: float, y: float, s: float = 36, col: str = "#fde68a") -> list[dict]:
    return [
        R(x + 2, y + 6, s - 4, s * 0.65, 4, col, NARANJA_OSCURO, 2.0),
        L(f"M{x + 6:.1f} {y + 13:.1f} L{x + s - 6:.1f} {y + 13:.1f}", NARANJA_OSCURO, 1.4),
        L(f"M{x + 6:.1f} {y + s * 0.55:.1f} L{x + s - 6:.1f} {y + s * 0.55:.1f}", NARANJA_OSCURO, 1.4),
    ]


def cortina_prop(x: float, y: float, s: float = 42) -> list[dict]:
    return [
        L(f"M{x:.1f} {y + 3:.1f} L{x + s:.1f} {y + 3:.1f}", MADERA_OSCURA, 2.8),
        R(x + 2, y + 5, s * 0.42, s * 0.8, 3, MORADO, "#5b21b6", 1.8),
        R(x + s * 0.56, y + 5, s * 0.42, s * 0.8, 3, MORADO, "#5b21b6", 1.8),
    ]


def charco_prop(x: float, y: float, s: float = 42) -> list[dict]:
    return [
        E(x + s * 0.5, y + s * 0.65, s * 0.45, s * 0.18, AGUA, AGUA_OSCURO, 2.0),
        E(x + s * 0.4, y + s * 0.62, s * 0.18, s * 0.06, "#bae6fd"),
    ]


def cuerda_prop(x: float, y: float, s: float = 38) -> list[dict]:
    return [
        L(f"M{x + 4:.1f} {y + s * 0.7:.1f} Q{x + s * 0.3:.1f} {y + 6:.1f} {x + s * 0.5:.1f} {y + s * 0.5:.1f} Q{x + s * 0.7:.1f} {y + s * 0.85:.1f} {x + s - 4:.1f} {y + s * 0.35:.1f}", TIERRA_CLARA, 3.2),
    ]


def palo_prop(x: float, y: float, s: float = 34) -> list[dict]:
    return [
        L(f"M{x + 4:.1f} {y + s * 0.8:.1f} L{x + s - 4:.1f} {y + s * 0.2:.1f}", BARRO, 4.5),
        L(f"M{x + 4:.1f} {y + s * 0.8:.1f} L{x + s - 4:.1f} {y + s * 0.2:.1f}", MADERA, 2.5),
    ]


def cepillo_pelo_prop(x: float, y: float, s: float = 32) -> list[dict]:
    return [
        R(x + s * 0.42, y + s * 0.45, 5, s * 0.45, 2, MADERA, MADERA_OSCURA, 1.5),
        E(x + s * 0.5, y + s * 0.32, s * 0.24, s * 0.26, ROSA, ROSA_OSCURO, 1.8),
        E(x + s * 0.5, y + s * 0.32, s * 0.14, s * 0.16, "#fbcfe8"),
    ]


def toalla_prop(x: float, y: float, s: float = 34) -> list[dict]:
    return pano(x + 2, y + 6, s - 4, s * 0.65, "#bae6fd", AGUA_OSCURO)


def reloj_arena_prop(x: float, y: float, s: float = 30) -> list[dict]:
    return fl("Hourglass done", x, y, s)


# ── Tabla de motivos concretos (orden: específicos/compuestos -> generales) ─
# Cada entrada: (lista_keywords_regex, builder_fn(x, y, s, color))
# Builders pueden usar `fl`, `ico` o vectores Lúa.
def _fl_motif(fl_name: str):
    return lambda x, y, s, col=None: fl(fl_name, x, y, s)


def _ico_motif(iset: str, iname: str, default_col: str = TINTA):
    return lambda x, y, s, col=None: ico(iset, iname, x, y, s, current_color=col or default_col)


def _shape_motif(kind: str):
    def fn(x: float, y: float, s: float, col: str | None = None) -> list[dict]:
        c = col or AZUL
        cx, cy, r = x + s * 0.5, y + s * 0.5, s * 0.42
        if kind == "circle":
            return [E(cx, cy, r, r, c, TINTA, 2.2)]
        if kind == "square":
            return [R(x + s * 0.12, y + s * 0.12, s * 0.76, s * 0.76, 3, c, TINTA, 2.2)]
        if kind == "triangle":
            return [P([(cx, y + s * 0.1), (x + s * 0.1, y + s * 0.88), (x + s * 0.9, y + s * 0.88)], c, TINTA, 2.2)]
        if kind == "diamond":
            return [P([(cx, y + s * 0.08), (x + s * 0.88, cy), (cx, y + s * 0.92), (x + s * 0.12, cy)], c, TINTA, 2.2)]
        if kind == "cube":
            return cubo_3d_prop(x, y, s, c)
        if kind == "cylinder":
            return cilindro_prop(x, y, s, c)
        if kind == "cone":
            return cono_prop(x, y, s, c)
        if kind == "ball":
            return pelota_prop(cx, cy, r, c, TINTA)
        if kind == "box":
            return caja_prop(x + 2, y + 6, s * 0.88, c)
        if kind == "spiral":
            return [
                L(f"M{cx:.1f} {cy:.1f} C{cx + 5:.1f} {cy - 5:.1f} {cx + 7:.1f} {cy + 4:.1f} {cx:.1f} {cy + 7:.1f} "
                  f"C{cx - 9:.1f} {cy + 9:.1f} {cx - 11:.1f} {cy - 8:.1f} {cx:.1f} {cy - 12:.1f} "
                  f"C{cx + 14:.1f} {cy - 14:.1f} {cx + 15:.1f} {cy + 12:.1f} {cx - 2:.1f} {cy + 14:.1f}", c, 2.6)
            ]
        return [E(cx, cy, r, r, c, TINTA, 2.2)]
    return fn


# Tuple of (regex_pattern, motif_id, src_tag, builder)
MOTIF_SPECS: list[tuple[str, str, str, object]] = [
    # Bebés / juguetes / objetos de crianza específicos
    (r"\b(pram|stroller|cochecito)s?\b", "pram", "mdi", _ico_motif("mdi", "baby-carriage", AZUL_OSCURO)),
    (r"\b(high chair|trona)s?\b", "high_chair", "mdi", _ico_motif("mdi", "chair-school", NARANJA_OSCURO)),
    (r"\b(rocking chair|mecedora)s?\b", "rocking_chair", "tabler", _ico_motif("tabler", "rocking-chair", BARRO)),
    (r"\b(armchair|sill[oó]n(?:es)?)\b", "armchair", "tabler", _ico_motif("tabler", "armchair", NARANJA_OSCURO)),
    (r"\b(rocking horse|caballito)s?\b", "rocking_horse", "fl", _fl_motif("Carousel horse")),
    (r"\b(teddy|peluche|soft toy|stuffed|bear cub)s?\b", "teddy", "fl", _fl_motif("Teddy bear")),
    (r"\b(rattle|sonajero|maraca|shaker)s?\b", "rattle", "mdi", _ico_motif("mdi", "baby-bottle-outline", MORADO)),
    (r"\b(dummy|pacifier|chupete)s?\b", "pacifier", "fl", _fl_motif("Baby bottle")),
    (r"\b(baby bottle|bib|biber[oó]n(?:es)?)s?\b", "bottle", "fl", _fl_motif("Baby bottle")),
    (r"\b(nappy|diaper|pañal(?:es)?|cambiador|changing mat)s?\b", "cloth", "lua", lambda x, y, s, col=None: pano(x + 2, y + 6, s - 4, s * 0.65)),
    (r"\b(spinning top|peonza|trompo)s?\b", "spinning_top", "lua", lambda x, y, s, col=None: peonza_prop(x, y, s)),
    (r"\b(pop-?up toy|juguete|toys?)s?\b", "toy", "fl", _fl_motif("Teddy bear")),
    (r"\b(puzzle|puzle|jigsaw)s?\b", "puzzle", "fl", _fl_motif("Puzzle piece")),
    (r"\b(nesting doll|matrioska|muñeca)s?\b", "nesting_dolls", "fl", _fl_motif("Nesting dolls")),
    (r"\b(doll|puppet|títere|marioneta)s?\b", "doll", "fl", _fl_motif("Nesting dolls")),
    (r"\b(kite|cometa)s?\b", "kite", "fl", _fl_motif("Kite")),
    (r"\b(pinwheel|molinillo)s?\b", "pinwheel", "mdi", _ico_motif("mdi", "pinwheel", ROJO)),
    (r"\b(swing|columpio)s?\b", "swing", "lua", lambda x, y, s, col=None: columpio_prop(x, y, s)),
    (r"\b(slide|tobog[aá]n(?:es)?)s?\b", "slide", "fl", _fl_motif("Playground slide")),
    (r"\b(seesaw|balanc[ií]n|scale|balanza|weigh|peso)s?\b", "scale", "fl", _fl_motif("Balance scale")),
    (r"\b(ramp|rampa|slope|cuesta|hill)s?\b", "ramp", "lua", lambda x, y, s, col=None: rampa_prop(x, y, s)),
    (r"\b(tunnel|t[uú]nel(?:es)?)s?\b", "tunnel", "lua", lambda x, y, s, col=None: tunel_prop(x, y, s)),
    (r"\b(hoop|aro)s?\b", "hoop", "lua", lambda x, y, s, col=None: [E(x + s/2, y + s/2, s*0.38, s*0.38, None, col or ROJO, 4.5)]),
    (r"\b(jump rope|skipping rope|comba)\b", "jump_rope", "tabler", _ico_motif("tabler", "jump-rope", ROJO_OSCURO)),

    # Animales (extensos, con plurales)
    (r"\b(butterfly|butterflies|mariposa)s?\b", "butterfly", "fl", _fl_motif("Butterfly")),
    (r"\b(caterpillar|oruga)s?\b", "caterpillar", "fl", _fl_motif("Bug")),
    (r"\b(ladybird|ladybug|mariquita)s?\b", "ladybug", "fl", _fl_motif("Lady beetle")),
    (r"\b(bee|bees|abeja|buzz)s?\b", "bee", "fl", _fl_motif("Honeybee")),
    (r"\b(ant|ants|hormiga)s?\b", "ant", "fl", _fl_motif("Ant")),
    (r"\b(spider|web|araña|telaraña)s?\b", "spider", "fl", _fl_motif("Spider")),
    (r"\b(snail|caracol(?:es)?)s?\b", "snail", "fl", _fl_motif("Snail")),
    (r"\b(worm|lombriz|lombrices|gusano|wriggl\w*)s?\b", "worm", "fl", _fl_motif("Worm")),
    (r"\b(beetle|bug|insect|escarabajo|bicho)s?\b", "beetle", "fl", _fl_motif("Beetle")),
    (r"\b(frog|toad|rana|sapo|croak|tadpole|renacuajo)s?\b", "frog", "fl", _fl_motif("Frog")),
    (r"\b(turtle|tortoise|tortuga)s?\b", "turtle", "fl", _fl_motif("Turtle")),
    (r"\b(snake|serpent|serpiente|slither|hiss)s?\b", "snake", "fl", _fl_motif("Snake")),
    (r"\b(crocodile|alligator|cocodrilo)s?\b", "crocodile", "fl", _fl_motif("Crocodile")),
    (r"\b(lizard|gecko|lagart\w*)s?\b", "lizard", "fl", _fl_motif("Lizard")),
    (r"\b(dinosaur|dino|dinosaurio)s?\b", "dino", "fl", _fl_motif("Sauropod")),
    (r"\b(dragon|drag[oó]n(?:es)?)s?\b", "dragon", "fl", _fl_motif("Dragon")),
    (r"\b(whale|ballena)s?\b", "whale", "fl", _fl_motif("Whale")),
    (r"\b(dolphin|delf[ií]n(?:es)?)s?\b", "dolphin", "fl", _fl_motif("Dolphin")),
    (r"\b(shark|tibur[oó]n(?:es)?)s?\b", "shark", "fl", _fl_motif("Shark")),
    (r"\b(octopus|pulpo)s?\b", "octopus", "fl", _fl_motif("Octopus")),
    (r"\b(jellyfish|medusa)s?\b", "jellyfish", "fl", _fl_motif("Jellyfish")),
    (r"\b(crab|cangrejo)s?\b", "crab", "fl", _fl_motif("Crab")),
    (r"\b(seal|sea lion|foca)s?\b", "seal", "fl", _fl_motif("Seal")),
    (r"\b(otter|nutria)s?\b", "otter", "fl", _fl_motif("Otter")),
    (r"\b(fish|goldfish|pez|peces|seahorse|minnow)s?\b", "fish", "fl", _fl_motif("Tropical fish")),
    (r"\b(penguin|ping[uü]ino)s?\b", "penguin", "fl", _fl_motif("Penguin")),
    (r"\b(flamingo|flamenco)s?\b", "flamingo", "fl", _fl_motif("Flamingo")),
    (r"\b(swan|cisne)s?\b", "swan", "fl", _fl_motif("Swan")),
    (r"\b(eagle|[aá]guila|hawk|falcon)s?\b", "eagle", "fl", _fl_motif("Eagle")),
    (r"\b(owl|b[uú]ho|lechuza|hoot)s?\b", "owl", "fl", _fl_motif("Owl")),
    (r"\b(parrot|loro)s?\b", "parrot", "fl", _fl_motif("Parrot")),
    (r"\b(rooster|gallo|cock-a-doodle)s?\b", "rooster", "fl", _fl_motif("Rooster")),
    (r"\b(hen|chicken|gallina|pollo|cluck)s?\b", "chicken", "fl", _fl_motif("Chicken")),
    (r"\b(chick|pollito|duckling|gosling)s?\b", "chick", "fl", _fl_motif("Baby chick")),
    (r"\b(duck|pato|quack|cuac)s?\b", "duck", "fl", _fl_motif("Duck")),
    (r"\b(blackbird|mirlo|crow|raven)s?\b", "blackbird", "fl", _fl_motif("Blackbird")),
    (r"\b(robin|sparrow|pigeon|dove|seagull|gulls?|bird|p[aá]jaro|ave|paloma|gaviota|chirp|tweet)s?\b", "bird", "fl", _fl_motif("Bird")),
    (r"\b(feather\w*|pluma)s?\b", "feather", "fl", _fl_motif("Feather")),
    (r"\b(wing|ala)s?\b", "wing", "fl", _fl_motif("Wing")),
    (r"\b(nest|nido)s?\b", "nest", "fl", _fl_motif("Nest with eggs")),
    (r"\b(dog|puppy|puppies|perro|cachorro|woof|bark)s?\b", "dog", "fl", _fl_motif("Dog")),
    (r"\b(cat|kitten|kitty|gato|gatito|meow|miau|purr)s?\b", "cat", "fl", _fl_motif("Cat")),
    (r"\b(rabbit|bunny|bunnies|hare|conejo|liebre)s?\b", "rabbit", "fl", _fl_motif("Rabbit")),
    (r"\b(hamster|h[aá]mster|guinea pig)s?\b", "hamster", "fl", _fl_motif("Hamster")),
    (r"\b(mouse|mice|rat[oó]n(?:es)?)s?\b", "mouse", "fl", _fl_motif("Mouse")),
    (r"\b(hedgehog|erizo)s?\b", "hedgehog", "fl", _fl_motif("Hedgehog")),
    (r"\b(squirrel|ardilla)s?\b", "squirrel", "fl", _fl_motif("Chipmunk")),
    (r"\b(fox|foxes|zorro)s?\b", "fox", "fl", _fl_motif("Fox")),
    (r"\b(wolf|wolves|lobo|howl|aullar)s?\b", "wolf", "fl", _fl_motif("Wolf")),
    (r"\b(bear|oso|cub)s?\b", "bear", "fl", _fl_motif("Bear")),
    (r"\b(lion|le[oó]n(?:es)?|roar|rugir|mane|melena)s?\b", "lion", "fl", _fl_motif("Lion")),
    (r"\b(tiger|tigre)s?\b", "tiger", "fl", _fl_motif("Tiger")),
    (r"\b(elephant|elefante)s?\b", "elephant", "fl", _fl_motif("Elephant")),
    (r"\b(giraffe|jirafa)s?\b", "giraffe", "fl", _fl_motif("Giraffe")),
    (r"\b(zebra|cebra)s?\b", "zebra", "fl", _fl_motif("Zebra")),
    (r"\b(monkey|ape|chimpanzee|mono)s?\b", "monkey", "fl", _fl_motif("Monkey")),
    (r"\b(gorilla|gorila)s?\b", "gorilla", "fl", _fl_motif("Gorilla")),
    (r"\b(kangaroo|canguro)s?\b", "kangaroo", "fl", _fl_motif("Kangaroo")),
    (r"\b(cow|calf|calves|cattle|vaca|moo)s?\b", "cow", "fl", _fl_motif("Cow")),
    (r"\b(pig|piglet|cerdo|cerdito|oink)s?\b", "pig", "fl", _fl_motif("Pig")),
    (r"\b(sheep|lamb|oveja|cordero|baa)s?\b", "sheep", "fl", _fl_motif("Ewe")),
    (r"\b(goat|cabra)s?\b", "goat", "fl", _fl_motif("Goat")),
    (r"\b(horse|pony|ponies|foal|caballo|potro|neigh|gallop)s?\b", "horse", "fl", _fl_motif("Horse")),
    (r"\b(donkey|burro)s?\b", "donkey", "fl", _fl_motif("Donkey")),
    (r"\b(deer|stag|fawn|reindeer|ciervo|reno)s?\b", "deer", "fl", _fl_motif("Deer")),
    (r"\b(paw|huella|footprint)s?\b", "paw", "fl", _fl_motif("Paw prints")),
    (r"\b(tail|cola|rabo)s?\b", "feather", "fl", _fl_motif("Feather")),

    # Frutas, verduras y comida
    (r"\b(apple|manzana)s?\b", "apple", "fl", _fl_motif("Red apple")),
    (r"\b(pear|pera)s?\b", "pear", "fl", _fl_motif("Pear")),
    (r"\b(banana|pl[aá]tano)s?\b", "banana", "fl", _fl_motif("Banana")),
    (r"\b(tangerine|mandarin\w*|citrus|mandarina)s?\b", "orange_fruit", "fl", _fl_motif("Tangerine")),
    (r"\b(strawberry|strawberries|fresa)s?\b", "strawberry", "fl", _fl_motif("Strawberry")),
    (r"\b(cherry|cherries|cereza)s?\b", "cherry", "fl", _fl_motif("Cherries")),
    (r"\b(grape|uvas|raisin|pasa)s?\b", "grapes", "fl", _fl_motif("Grapes")),
    (r"\b(watermelon|sand[ií]a)s?\b", "watermelon", "fl", _fl_motif("Watermelon")),
    (r"\b(melon|mel[oó]n(?:es)?)s?\b", "melon", "fl", _fl_motif("Melon")),
    (r"\b(peach|peaches|melocot[oó]n(?:es)?)s?\b", "peach", "fl", _fl_motif("Peach")),
    (r"\b(pineapple|piña)s?\b", "pineapple", "fl", _fl_motif("Pineapple")),
    (r"\b(lemon|lim[oó]n(?:es)?|lime)s?\b", "lemon", "fl", _fl_motif("Lemon")),
    (r"\b(mango)e?s?\b", "mango", "fl", _fl_motif("Mango")),
    (r"\b(kiwi)s?\b", "kiwi", "fl", _fl_motif("Kiwi fruit")),
    (r"\b(blueberry|blueberries|berry|berries|ar[aá]ndano|mora|frambuesa)s?\b", "berries", "fl", _fl_motif("Blueberries")),
    (r"\b(carrot|zanahoria)s?\b", "carrot", "fl", _fl_motif("Carrot")),
    (r"\b(tomato|tomatoes|tomate)s?\b", "tomato", "fl", _fl_motif("Tomato")),
    (r"\b(potato|potatoes|patata|sweet potato|boniato)s?\b", "potato", "fl", _fl_motif("Potato")),
    (r"\b(cucumber|pepino)s?\b", "cucumber", "fl", _fl_motif("Cucumber")),
    (r"\b(broccoli|br[oó]coli)\b", "broccoli", "fl", _fl_motif("Broccoli")),
    (r"\b(corn|ma[ií]z)\b", "corn", "fl", _fl_motif("Ear of corn")),
    (r"\b(pumpkin|calabaza)s?\b", "pumpkin", "fl", _fl_motif("Jack-o-lantern")),
    (r"\b(mushroom|seta|hongo)s?\b", "mushroom", "fl", _fl_motif("Mushroom")),
    (r"\b(pea|peas|bean|alubia|guisante)s?\b", "beans", "fl", _fl_motif("Beans")),
    (r"\b(olive|aceituna)s?\b", "olive", "fl", _fl_motif("Olive")),
    (r"\b(bread|toast|pan|tostada|loaf|loaves|crumb|miga)s?\b", "bread", "fl", _fl_motif("Bread")),
    (r"\b(cheese|queso)s?\b", "cheese", "fl", _fl_motif("Cheese wedge")),
    (r"\b(egg|huevo)s?\b", "egg", "fl", _fl_motif("Egg")),
    (r"\b(sandwich|sandwiches|s[aá]ndwich|bocadillo)s?\b", "sandwich", "fl", _fl_motif("Sandwich")),
    (r"\b(cake|tarta|pastel(?:es)?|cupcake)s?\b", "cake", "fl", _fl_motif("Birthday cake")),
    (r"\b(cookie|biscuit|galleta)s?\b", "cookie", "fl", _fl_motif("Cookie")),
    (r"\b(chocolate)\b", "chocolate", "fl", _fl_motif("Chocolate bar")),
    (r"\b(ice cream|helado)s?\b", "ice_cream", "fl", _fl_motif("Ice cream")),
    (r"\b(juice|zumo|straw|pajita|smoothie|drink|bebida)s?\b", "juice", "fl", _fl_motif("Cup with straw")),
    (r"\b(milk|leche)\b", "milk", "fl", _fl_motif("Glass of milk")),
    (r"\b(honey|miel)\b", "honey", "fl", _fl_motif("Honey pot")),
    (r"\b(soup|porridge|stew|sopa|pot|olla|cocina)s?\b", "pot", "lua", lambda x, y, s, col=None: olla_prop(x, y, s)),
    (r"\b(rice|arroz|cereal)s?\b", "rice", "fl", _fl_motif("Bowl with spoon")),
    (r"\b(acorn|bellota)s?\b", "acorn", "lua", lambda x, y, s, col=None: bellota_prop(x, y, s)),
    (r"\b(chestnut|nut|castaña|nuez|nueces)s?\b", "chestnut", "fl", _fl_motif("Chestnut")),
    (r"\b(fruit|fruta|food|comida|snack|merienda|lunch|desayuno|dinner|cena)s?\b", "fruit", "fl", _fl_motif("Red apple")),

    # Naturaleza, cielo, tiempo, paisajes y materiales
    (r"\b(rainbow|arco[ií]ris)\b", "rainbow", "fl", _fl_motif("Rainbow")),
    (r"\b(sunrise|dawn|amanecer|morning|mañana)\b", "sunrise", "fl", _fl_motif("Sunrise")),
    (r"\b(sunset|atardecer|dusk|evening)\b", "sunset", "fl", _fl_motif("Sunset")),
    (r"\b(sun|sunshine|sunlight|sunny|sol|verano|summer)s?\b", "sun", "fl", _fl_motif("Sun")),
    (r"\b(moon|luna|night|noche|nocturn\w*)s?\b", "moon", "fl", _fl_motif("Crescent moon")),
    (r"\b(shooting star|estrella fugaz)\b", "shooting_star", "fl", _fl_motif("Shooting star")),
    (r"\b(star|starlight|estrella|twinkle)s?\b", "star", "fl", _fl_motif("Star")),
    (r"\b(comet|cometa espacial)\b", "comet", "fl", _fl_motif("Comet")),
    (r"\b(planet|earth|world|globe|planeta|tierra)s?\b", "globe", "fl", _fl_motif("Globe showing americas")),
    (r"\b(thunder|lightning|storm|rayo|tormenta|trueno)s?\b", "storm", "fl", _fl_motif("Cloud with lightning and rain")),
    (r"\b(rain|raindrop|rainy|pouring|drizzle|lluvia|llover|gotas?)s?\b", "rain", "fl", _fl_motif("Cloud with rain")),
    (r"\b(snow|snowflake|snowy|winter|nieve|copo|invierno)s?\b", "snowflake", "fl", _fl_motif("Snowflake")),
    (r"\b(snowman|muñeco de nieve)\b", "snowman", "fl", _fl_motif("Snowman")),
    (r"\b(ice|icy|frost|hielo|escarcha)\b", "ice", "fl", _fl_motif("Ice")),
    (r"\b(cloud|cloudy|nube|fog|niebla|mist|sky|cielo|dream|sueño|soñ\w*)s?\b", "cloud", "fl", _fl_motif("Cloud")),
    (r"\b(wind|windy|breeze|viento|brisa|gust)s?\b", "wind", "lua", lambda x, y, s, col=None: lineas_viento(x + 2, y + s * 0.5, s - 4)),
    (r"\b(pine|evergreen|pino|christmas tree)s?\b", "pine", "fl", _fl_motif("Evergreen tree")),
    (r"\b(palm|palmera)s?\b", "palm", "fl", _fl_motif("Palm tree")),
    (r"\b(tree|oak|trunk|branch|wood|wooden|park|forest|árbol|roble|tronco|rama|parque|bosque|madera)s?\b", "tree", "fl", lambda x, y, s, col=None: arbol_prop(x, y, s)),
    (r"\b(leaf|leaves|autumn|hoja|otoño)s?\b", "leaf", "fl", lambda x, y, s, col=None: hoja_prop(x, y, s)),
    (r"\b(sunflower|girasol(?:es)?)s?\b", "sunflower", "fl", _fl_motif("Sunflower")),
    (r"\b(tulip|tulip[aá]n(?:es)?)s?\b", "tulip", "fl", _fl_motif("Tulip")),
    (r"\b(flower|blossom|petal|bloom|daisy|spring|flor(?:es)?|p[eé]talo|garden|jard[ií]n|primavera)s?\b", "flower", "fl", _fl_motif("Blossom")),
    (r"\b(seed|semilla|sprout|brote|seedling|grow|crecer|plant\w*|sow|sembrar)s?\b", "seed", "lua", lambda x, y, s, col=None: semilla_prop(x, y, s)),
    (r"\b(grass|meadow|lawn|hierba|prado|bush|arbusto|ground|suelo|field|campo)s?\b", "grass", "fl", _fl_motif("Herb")),
    (r"\b(mushroom|toadstool|seta)s?\b", "mushroom", "fl", _fl_motif("Mushroom")),
    (r"\b(mountain|peak|hilltop|montaña|cumbre|volcano|volc[aá]n)s?\b", "mountain", "fl", _fl_motif("Mountain")),
    (r"\b(island|isla)s?\b", "island", "fl", _fl_motif("Desert island")),
    (r"\b(beach|beaches|sand|shore|playa|arena|dune)s?\b", "beach", "fl", _fl_motif("Beach with umbrella")),
    (r"\b(shell|seashell|concha)s?\b", "shell", "fl", lambda x, y, s, col=None: concha_prop(x, y, s)),
    (r"\b(wave|ocean|sea|seabed|seagrass|ola|mar|oc[eé]ano|fondo marino)s?\b", "wave", "fl", _fl_motif("Water wave")),
    (r"\b(puddle|pond|charco|estanque)s?\b", "puddle", "lua", lambda x, y, s, col=None: charco_prop(x, y, s)),
    (r"\b(river|stream|creek|waterfall|r[ií]o|arroyo|cascada)s?\b", "river", "fl", _fl_motif("Water wave")),
    (r"\b(water|droplet|splash|agua|gota)s?\b", "water", "fl", _fl_motif("Droplet")),
    (r"\b(rock|stone|pebble|boulder|piedra|roca|guijarro)s?\b", "stone", "lua", lambda x, y, s, col=None: piedra_prop(x, y, s)),
    (r"\b(fire|flame|bonfire|fuego|llama|campfire)s?\b", "fire", "fl", _fl_motif("Fire")),
    (r"\b(smoke|steam|humo|vapor|heat|calor)\b", "smoke", "lua", lambda x, y, s, col=None: ondas_calor(x + 4, y + s * 0.5, ROJO)),

    # Transporte y edificios / lugares
    (r"\b(fire engine|camión de bomberos)\b", "fire_engine", "fl", _fl_motif("Fire engine")),
    (r"\b(ambulance|ambulancia)s?\b", "ambulance", "fl", _fl_motif("Ambulance")),
    (r"\b(bus|buses|autob[uú]s(?:es)?)\b", "bus", "fl", _fl_motif("Bus")),
    (r"\b(train|locomotive|tren(?:es)?)s?\b", "train", "fl", _fl_motif("Locomotive")),
    (r"\b(tram|tranv[ií]a)s?\b", "tram", "fl", _fl_motif("Tram")),
    (r"\b(tractor)s?\b", "tractor", "fl", _fl_motif("Tractor")),
    (r"\b(truck|lorry|cami[oó]n(?:es)?)s?\b", "truck", "fl", _fl_motif("Delivery truck")),
    (r"\b(taxi)s?\b", "taxi", "fl", _fl_motif("Taxi")),
    (r"\b(car|automobile|coche)s?\b", "car", "fl", _fl_motif("Automobile")),
    (r"\b(bicycle|bike|bici|ciclista)s?\b", "bike", "fl", _fl_motif("Bicycle")),
    (r"\b(scooter|patinete)s?\b", "scooter", "fl", _fl_motif("Kick scooter")),
    (r"\b(motorbike|motorcycle|moto)s?\b", "motorbike", "fl", _fl_motif("Motorcycle")),
    (r"\b(rocket|cohete|spacecraft|blast off|despeg\w*)s?\b", "rocket", "fl", _fl_motif("Rocket")),
    (r"\b(plane|airplane|aeroplane|avi[oó]n(?:es)?)s?\b", "plane", "fl", _fl_motif("Airplane")),
    (r"\b(helicopter|helic[oó]ptero)s?\b", "helicopter", "fl", _fl_motif("Helicopter")),
    (r"\b(ship|ferry|ferri|barco grande)s?\b", "ferry", "fl", _fl_motif("Ferry")),
    (r"\b(boat|sailboat|canoe|row|barco|barca|velero|remar)s?\b", "boat", "fl", _fl_motif("Sailboat")),
    (r"\b(wheel|tire|tyre|rueda)s?\b", "wheel", "fl", _fl_motif("Wheel")),
    (r"\b(anchor|ancla)s?\b", "anchor", "fl", _fl_motif("Anchor")),
    (r"\b(castle|fort|castillo)s?\b", "castle", "fl", _fl_motif("Castle")),
    (r"\b(lighthouse|faro)s?\b", "lighthouse", "noto", _ico_motif("noto", "lighthouse")),
    (r"\b(barn|establo|granja|farm)s?\b", "barn", "mdi", _ico_motif("mdi", "barn", ROJO_OSCURO)),
    (r"\b(tent|tienda de campaña|refugio|shelter)s?\b", "tent", "fl", _fl_motif("Tent")),
    (r"\b(house|home|casa|cottage|roof|tejado)s?\b", "house", "fl", _fl_motif("House")),
    (r"\b(school|colegio|aula|classroom)s?\b", "school", "fl", _fl_motif("School")),
    (r"\b(bridge|puente)s?\b", "bridge", "lua", lambda x, y, s, col=None: puente_prop(x, y, s)),
    (r"\b(fence|gate|valla|verja)s?\b", "fence", "lua", lambda x, y, s, col=None: valla_prop(x, y, s)),
    (r"\b(ladder|stairs|steps|escalera|peldaño)s?\b", "ladder", "fl", _fl_motif("Ladder")),

    # Casa, aula, música, ropa, cuerpo y herramientas
    (r"\b(bed|cama|cradle|cuna|cot)s?\b", "bed", "fl", _fl_motif("Bed")),
    (r"\b(sofa|couch|sof[aá])s?\b", "sofa", "fl", _fl_motif("Couch and lamp")),
    (r"\b(chair|bench|silla|banco)s?\b", "chair", "fl", _fl_motif("Chair")),
    (r"\b(table|desk|plank|mesa|pupitre|tabla)s?\b", "table", "lua", lambda x, y, s, col=None: mesa_prop(x, y + s * 0.25, s, s * 0.65)),
    (r"\b(door|puerta)s?\b", "door", "fl", _fl_motif("Door")),
    (r"\b(window|ventana)s?\b", "window", "fl", _fl_motif("Window")),
    (r"\b(curtain|cortina)s?\b", "curtain", "lua", lambda x, y, s, col=None: cortina_prop(x, y, s)),
    (r"\b(blanket|sheet|manta|s[aá]bana)s?\b", "blanket", "lua", lambda x, y, s, col=None: manta_prop(x, y, s)),
    (r"\b(pillow|cushion|almohada|coj[ií]n(?:es)?)s?\b", "pillow", "tabler", _ico_motif("tabler", "pillow", MORADO)),
    (r"\b(towel|cloth|scarf|toalla|pañuelo|muselina)s?\b", "towel", "lua", lambda x, y, s, col=None: toalla_prop(x, y, s)),
    (r"\b(clock|watch|timer|reloj|despertador|horario|time)s?\b", "clock", "fl", _fl_motif("Alarm clock")),
    (r"\b(hourglass|sand timer|reloj de arena)\b", "hourglass", "fl", lambda x, y, s, col=None: reloj_arena_prop(x, y, s)),
    (r"\b(mirror|espejo|reflection|reflejo)s?\b", "mirror", "fl", _fl_motif("Mirror")),
    (r"\b(lamp|lantern|light bulb|flashlight|torch|linterna|farol|bombilla|l[aá]mpara|luz|luces|light)s?\b", "lamp", "fl", _fl_motif("Light bulb")),
    (r"\b(candle|vela)s?\b", "candle", "fl", _fl_motif("Candle")),
    (r"\b(key|llave)s?\b", "key", "fl", _fl_motif("Key")),
    (r"\b(lock|candado|cerradura)s?\b", "lock", "fl", _fl_motif("Locked")),
    (r"\b(book|album|notebook|libro|cuaderno|[aá]lbum|story|cuento|page|p[aá]gina)s?\b", "book", "lua", lambda x, y, s, col=None: libro_prop(x, y, s, col or AZUL)),
    (r"\b(pencil|crayon|pen|l[aá]piz|l[aá]pices|cera|boli|draw|dibuj\w*|write|escrib\w*)s?\b", "pencil", "fl", _fl_motif("Pencil")),
    (r"\b(paintbrush|paint|brush|pincel|pintura|colour|color(?:es)?)s?\b", "paint", "fl", _fl_motif("Artist palette")),
    (r"\b(scissors|tijeras|cut|cortar)\b", "scissors", "fl", _fl_motif("Scissors")),
    (r"\b(paper|envelope|letter|card|papel|carta|sobre|tarjeta)s?\b", "paper", "fl", _fl_motif("Page facing up")),
    (r"\b(bin|trash|basura|papelera)s?\b", "bin", "lua", lambda x, y, s, col=None: papelera_prop(x, y, s)),
    (r"\b(basket|cesta|canasta)s?\b", "basket", "fl", _fl_motif("Basket")),
    (r"\b(bucket|cubo)s?\b", "bucket", "fl", _fl_motif("Bucket")),
    (r"\b(spade|shovel|pala)s?\b", "shovel", "tabler", _ico_motif("tabler", "shovel", TIERRA)),
    (r"\b(bag|backpack|school bag|bolsa|mochila|luggage|suitcase)s?\b", "bag", "fl", _fl_motif("Backpack")),
    (r"\b(gift|present|regalo)s?\b", "gift", "fl", _fl_motif("Wrapped gift")),
    (r"\b(box|boxes|parcel|package|caja|paquete)s?\b", "box", "lua", lambda x, y, s, col=None: caja_prop(x + 2, y + 6, s * 0.85, col or TIERRA_CLARA)),
    (r"\b(glass|glasses of|cup|mug|vaso|taza)s?\b", "cup", "lua", lambda x, y, s, col=None: vaso_prop(x + 4, y + 2, s * 0.85, 0.7)),
    (r"\b(plate|tray|plato|bandeja)s?\b", "plate", "lua", lambda x, y, s, col=None: plato_prop(x + s * 0.5, y + s * 0.55, s * 0.42)),
    (r"\b(spoon|cuchara)s?\b", "spoon", "lua", lambda x, y, s, col=None: cuchara_prop(x, y, s)),
    (r"\b(toothbrush|cepillo de dientes)\b", "toothbrush", "fl", _fl_motif("Toothbrush")),
    (r"\b(tooth|teeth|diente)s?\b", "tooth", "fl", _fl_motif("Tooth")),
    (r"\b(hairbrush|comb|cepillo|peine)s?\b", "hairbrush", "lua", lambda x, y, s, col=None: cepillo_pelo_prop(x, y, s)),
    (r"\b(soap|jab[oó]n)\b", "soap", "fl", _fl_motif("Soap")),
    (r"\b(sponge|esponja)s?\b", "sponge", "fl", _fl_motif("Sponge")),
    (r"\b(umbrella|parasol|paraguas|sombrilla)s?\b", "umbrella", "fl", _fl_motif("Umbrella")),
    (r"\b(glasses|sunglasses|gafas)\b", "glasses", "fl", _fl_motif("Glasses")),
    (r"\b(hat|cap|helmet|bonnet|sombrero|gorro|gorra|casco)s?\b", "hat", "fl", _fl_motif("Womans hat")),
    (r"\b(crown|king|queen|princess|prince|rey|reina|princesa)s?\b", "crown", "fl", _fl_motif("Crown")),
    (r"\b(medal|badge|medalla|insignia|ayudante|helper)s?\b", "medal", "fl", _fl_motif("1st place medal")),
    (r"\b(coat|jacket|abrigo|chaqueta)s?\b", "coat", "fl", _fl_motif("Coat")),
    (r"\b(shirt|t-shirt|sweater|jersey|camiseta)s?\b", "shirt", "fl", _fl_motif("T-shirt")),
    (r"\b(dress|dresses|vestido)s?\b", "dress", "fl", _fl_motif("Dress")),
    (r"\b(socks|sock|calcet[ií]n|calcetines|tights|leotardos)\b", "socks", "fl", _fl_motif("Socks")),
    (r"\b(shoe|boot|slipper|zapato|bota|zapatilla)s?\b", "shoe", "fl", _fl_motif("Running shoe")),
    (r"\b(gloves|mitten|guante|manopla)s?\b", "gloves", "fl", _fl_motif("Gloves")),
    (r"\b(button|zipper|bot[oó]n(?:es)?|cremallera)s?\b", "button", "lua", lambda x, y, s, col=None: [E(x+s/2, y+s/2, s*0.36, s*0.36, col or ROJO, ROJO_OSCURO, 2.0), E(x+s*0.42, y+s*0.42, 2.2, 2.2, BLANCO), E(x+s*0.58, y+s*0.42, 2.2, 2.2, BLANCO), E(x+s*0.42, y+s*0.58, 2.2, 2.2, BLANCO), E(x+s*0.58, y+s*0.58, 2.2, 2.2, BLANCO)]),
    (r"\b(ribbon|bow|cinta|lazo)s?\b", "ribbon", "fl", _fl_motif("Ribbon")),
    (r"\b(drum|tambor|tambourine|pandereta)s?\b", "drum", "fl", _fl_motif("Drum")),
    (r"\b(guitar|guitarra)s?\b", "guitar", "fl", _fl_motif("Guitar")),
    (r"\b(violin|viol[ií]n)s?\b", "violin", "fl", _fl_motif("Violin")),
    (r"\b(trumpet|trompeta|horn)s?\b", "trumpet", "fl", _fl_motif("Trumpet")),
    (r"\b(bell|campana|jingle)s?\b", "bell", "fl", _fl_motif("Bell")),
    (r"\b(whistle|silbato)s?\b", "whistle", "lua", lambda x, y, s, col=None: silbato_prop(x, y, s)),
    (r"\b(microphone|micr[oó]fono)s?\b", "microphone", "fl", _fl_motif("Microphone")),
    (r"\b(music|song|sing|lullaby|carol|rhyme|melody|rhythm|nota|canci[oó]n|m[uú]sica)s?\b", "music", "lua", lambda x, y, s, col=None: list(notas([(x + s*0.3, y + s*0.65), (x + s*0.65, y + s*0.45)]))),
    (r"\b(telescope|telescopio)s?\b", "telescope", "fl", _fl_motif("Telescope")),
    (r"\b(magnifying|lupa)s?\b", "magnifier", "fl", _fl_motif("Magnifying glass tilted left")),
    (r"\b(compass|br[uú]jula)s?\b", "compass", "fl", _fl_motif("Compass")),
    (r"\b(magnet|im[aá]n(?:es)?)s?\b", "magnet", "fl", _fl_motif("Magnet")),
    (r"\b(thermometer|term[oó]metro|temperature|temperatura)s?\b", "thermometer", "fl", _fl_motif("Thermometer")),
    (r"\b(map|mapa)s?\b", "map", "fl", _fl_motif("World map")),
    (r"\b(camera|photo|foto|c[aá]mara)s?\b", "camera", "fl", _fl_motif("Camera")),
    (r"\b(coin|money|moneda|dinero|expensive|caro)s?\b", "coin", "fl", _fl_motif("Coin")),
    (r"\b(rope|string|thread|cord|shoelace|net|cuerda|hilo|cord[oó]n|red)s?\b", "rope", "lua", lambda x, y, s, col=None: cuerda_prop(x, y, s)),
    (r"\b(stick|branch|wand|varita|palo|ramita)s?\b", "stick", "lua", lambda x, y, s, col=None: palo_prop(x, y, s)),
    (r"\b(windmill|molino)s?\b", "windmill", "tabler", _ico_motif("tabler", "windmill", AZUL_OSCURO)),
    (r"\b(balloon|globo)s?\b", "balloon", "fl", _fl_motif("Balloon")),
    (r"\b(bubbles|bubble|pompa|burbuja)s?\b", "bubbles", "fl", _fl_motif("Bubbles")),
    (r"\b(robot)s?\b", "robot", "fl", _fl_motif("Robot")),

    # Formas geométricas, símbolos y conceptos visuales
    (r"\b(cube|cubo geom[eé]trico|block|bloque)s?\b", "cube", "lua", _shape_motif("cube")),
    (r"\b(cylinder|cilindro)s?\b", "cylinder", "lua", _shape_motif("cylinder")),
    (r"\b(cone|cono)s?\b", "cone", "lua", _shape_motif("cone")),
    (r"\b(triangle|tri[aá]ngulo|triangular)s?\b", "triangle", "lua", _shape_motif("triangle")),
    (r"\b(square|cuadrado)s?\b", "square", "lua", _shape_motif("square")),
    (r"\b(diamond|rhombus|rombo)s?\b", "diamond", "lua", _shape_motif("diamond")),
    (r"\b(circle|round|c[ií]rculo|redondo)s?\b", "circle", "lua", _shape_motif("circle")),
    (r"\b(spiral|espiral|swirl)s?\b", "spiral", "lua", _shape_motif("spiral")),
    (r"\b(ball|sphere|pelota|bal[oó]n|canica|marble)s?\b", "ball", "lua", _shape_motif("ball")),
    (r"\b(heart|coraz[oó]n|love|cariño|amistad|friendship)s?\b", "heart", "fl", _fl_motif("Red heart")),
    (r"\b(sparkles|sparkle|glitter|magic|spell|shine|bright|brillo|purpurina|magia|hechizo)\b", "sparkles", "fl", _fl_motif("Sparkles")),
]

# Compilar regexes una sola vez
_MOTIF_COMPILED = [(re.compile(pat, re.IGNORECASE), mid, src, fn) for pat, mid, src, fn in MOTIF_SPECS]


def _extract_colors(text: str) -> list[tuple[str, str]]:
    t = text.lower()
    checks = [
        (r"\b(red|rojo|roja|scarlet|crimson)\b", ROJO, "rojo"),
        (r"\b(blue|azul|navy|sky blue)\b", AZUL, "azul"),
        (r"\b(green|verde)\b", VERDE, "verde"),
        (r"\b(yellow|amarillo|amarilla)\b", AMARILLO, "amarillo"),
        (r"\b(orange|naranja)\b", NARANJA, "naranja"),
        (r"\b(pink|rosa|rosado|rosada)\b", ROSA, "rosa"),
        (r"\b(purple|violet|morado|morada|violeta)\b", MORADO, "morado"),
        (r"\b(brown|marr[oó]n|castaño)\b", TIERRA, "marrón"),
        (r"\b(black|negro|negra)\b", NEGRO, "negro"),
        (r"\b(white|blanco|blanca)\b", BLANCO, "blanco"),
        (r"\b(grey|gray|gris)\b", GRIS_OSCURO, "gris"),
        (r"\b(gold|golden|dorado|dorada)\b", DORADO, "dorado"),
        (r"\b(silver|plateado|plateada)\b", PLATA, "plateado"),
    ]
    found: list[tuple[str, str]] = []
    for pat, col, lbl in checks:
        if re.search(pat, t):
            found.append((col, lbl))
    return found


def _extract_color(text: str) -> tuple[str | None, str | None]:
    cols = _extract_colors(text)
    return cols[0] if cols else (None, None)


def _extract_count(text: str) -> int | None:
    t = text.lower()
    words = [
        (r"\b(ten|diez)\b", 10),
        (r"\b(nine|nueve)\b", 9),
        (r"\b(eight|ocho)\b", 8),
        (r"\b(seven|siete)\b", 7),
        (r"\b(six|seis)\b", 6),
        (r"\b(five|cinco)\b", 5),
        (r"\b(four|cuatro)\b", 4),
        (r"\b(three|tres)\b", 3),
        (r"\b(two|dos|pair|par|both|ambos|double)\b", 2),
        (r"\b(one|uno|una|single|once)\b", 1),
    ]
    for pat, n in words:
        if re.search(pat, t):
            return n
    return None


def _extract_motifs(en: str, es: str, tpr: str) -> list[tuple[str, str, object]]:
    found: list[tuple[str, str, object]] = []
    seen_ids: set[str] = set()
    # 1. Buscar primero en en + es (significado exacto)
    txt_primary = f"{en} {es}"
    for rx, mid, src, fn in _MOTIF_COMPILED:
        if rx.search(txt_primary) and mid not in seen_ids:
            seen_ids.add(mid)
            found.append((mid, src, fn))
            if len(found) >= 2:
                return found
    # 2. Complementar con objetos concretos citados en tprAction
    if len(found) < 2 and tpr:
        for rx, mid, src, fn in _MOTIF_COMPILED:
            if rx.search(tpr) and mid not in seen_ids:
                seen_ids.add(mid)
                found.append((mid, src, fn))
                if len(found) >= 2:
                    return found
    return found


def _detect_body_part(txt: str) -> tuple[str, tuple[float, float]] | None:
    """Si la pieza nombra una parte del cuerpo, devuelve (nombre, coords en nino centro)."""
    t = txt.lower()
    parts = [
        (r"\b(eyelash\w*|pestaña\w*|eye|ojos|ojo)\b", "ojos", (57, 29)),
        (r"\b(ear|ears|oreja\w*)\b", "oreja", (49, 29)),
        (r"\b(nose|nariz|nostril\w*)\b", "nariz", (60, 31)),
        (r"\b(mouth|lips|tooth|teeth|tongue|boca|labios|diente\w*|lengua)\b", "boca", (58, 35)),
        (r"\b(cheek|dimple|mejilla|hoyuelo)s?\b", "mejilla", (55, 33)),
        (r"\b(chin|barbilla|ment[oó]n)\b", "barbilla", (56, 38)),
        (r"\b(hair|pelo|forehead|frente|head|cabeza)\b", "cabeza", (56, 22)),
        (r"\b(neck|throat|cuello|garganta)\b", "cuello", (56, 40)),
        (r"\b(shoulder|hombro|om[oó]plato)s?\b", "hombro", (48, 44)),
        (r"\b(chest|heart|pecho|latido)\b", "pecho", (56, 51)),
        (r"\b(belly|tummy|stomach|barriga|tripa)\b", "barriga", (56, 59)),
        (r"\b(back|spine|espalda|lomo)\b", "espalda", (46, 54)),
        (r"\b(elbow|codo)s?\b", "codo", (68, 52)),
        (r"\b(wrist|muñeca)\b", "muñeca", (74, 57)),
        (r"\b(fingertip|finger|thumb|pinky|meñique|pulgar|dedo)s?\b", "dedos", (78, 59)),
        (r"\b(hand|palm|mano|palma)s?\b", "mano", (77, 58)),
        (r"\b(arm|brazo)s?\b", "brazo", (70, 50)),
        (r"\b(hip|bottom|culito|cadera)s?\b", "cadera", (56, 65)),
        (r"\b(knee|rodilla)s?\b", "rodilla", (50, 77)),
        (r"\b(ankle|tobillo)s?\b", "tobillo", (49, 85)),
        (r"\b(heel|tal[oó]n(?:es)?)\b", "talón", (46, 89)),
        (r"\b(big toe|toe|dedo del pie|foot|feet|pie|pies)s?\b", "pie", (54, 89)),
        (r"\b(leg|pierna)s?\b", "pierna", (63, 76)),
    ]
    for pat, label, pt in parts:
        if re.search(pat, t):
            return label, pt
    return None


def _classify_gesture(tpr: str, cat: str, en: str, es: str) -> str:
    t = tpr.lower()
    full = f"{en} {es} {tpr}".lower()

    if any(w in t for w in ("acunar", "mecer al bebé", "masajear", "en el cambiador", "en la trona", "en brazos")):
        return "baby_care"
    if "bebé" in t and any(w in t for w in ("boca abajo", "piernas", "tumb", "alfombra", "espejo", "cosquillas")):
        return "baby_floor"
    if any(w in t for w in ("dormir", "nana", "cerrar los ojos", "acostar", "cabeza en las manos", "almohada")):
        return "sleep"
    if any(w in t for w in ("en los labios", "silencio", "bajito", "cuchichear", "susurrar")):
        return "shh"
    if any(w in t for w in ("a la oreja", "escuchar", "oír", "ululato")):
        return "listen"
    if any(w in t for w in ("esconder", "detrás de", "tapar la cara", "descubrir", "cucú", "escondite")):
        return "peek"
    if any(w in t for w in ("gatear", "arrastrar", "reptar", "suelo como", "deslizar por el suelo")):
        return "crawl"
    if any(w in t for w in ("saltar", "brincar", "rebotar", "salto", "hop", "jump", "leap")):
        return "jump"
    if any(w in t for w in ("correr", "rápido en el sitio", "perseguir")):
        return "run"
    if any(w in t for w in ("puntillas", "caminar", "marchar", "pasear", "pasos", "pisar", "sendero", "pasitos")):
        return "walk"
    if any(w in t for w in ("dar vueltas", "girar", "rodar", "rotar")):
        return "spin"
    if any(w in t for w in ("balancear", "mecerse", "de un lado a otro", "onda", "tambalear", "subir y bajar", "vaivén")):
        return "sway"
    if any(w in t for w in ("agachar", "encoger", "bajito", "bola", "rincón")):
        return "crouch"
    if any(w in t for w in ("sentarse", "sentar")):
        return "sit"
    if any(w in t for w in ("tumbar", "estirado en el suelo", "plano")):
        return "lie"
    if any(w in t for w in ("soplar", "viento", "burbuja", "respirar hondo", "abanic")):
        return "blow"
    if any(w in t for w in ("oler", "olfatear", "aroma")):
        return "smell"
    if any(w in t for w in ("boca", "sorbo", "comer", "morder", "probar", "saborear", "lamer", "cantar", "abrir mucho la boca", "rugir")):
        return "mouth_sing" if any(w in t for w in ("cantar", "rugir", "gritar", "decir", "silbar")) else "eat_drink"
    if any(w in t for w in ("palmas", "aplaudir", "golpear", "tambor", "ritmo")):
        return "clap_tap"
    if any(w in t for w in ("saludar", "adiós", "reverencia", "saludo", "bienvenid")):
        return "wave"
    if any(w in full for w in ("abrazar", "consolar", "mano en el pecho", "manos en el pecho", "corazón con las manos", "acariciar", "acurrucar", "mimoso", "tierno")):
        return "hug_heart"
    if any(w in full for w in ("amigo", "de mano en mano", "darse la mano", "compartir", "intercambiar", "entre todos", "todos juntos", "dos personas", "entre dos")):
        return "share_two"
    if any(w in t for w in ("levantar los brazos", "estirar los brazos", "manos arriba", "brazos arriba", "estirarse alto", "trepar", "desperezarse")):
        return "arms_up"
    if any(w in t for w in ("levantar la mano", "subir la mano", "alzar la mano", "levantar un")):
        return "raise_hand"
    if any(w in t for w in ("abrir los brazos", "brazos amplios", "extender los brazos")):
        return "arms_wide"
    if any(w in t for w in ("empujar", "tirar", "arrastrar", "levantar con fuerza", "pesado")):
        return "push_pull"
    if any(w in t for w in ("lanzar", "atrapar", "dejar caer", "soltar", "coger al vuelo", "tirar al aire")):
        return "throw_catch"
    if any(w in t for w in ("lavar", "frotar", "enjabonar", "escurrir", "regar", "verter", "nadar", "salpicar")):
        return "water_action"
    if any(w in t for w in ("contar", "dedos", "enseñar un dedo", "levantar el pulgar", "enseñar dos")):
        return "count_fingers"
    if any(w in t for w in ("lupa", "mirar", "asomarse", "observar", "buscar")):
        return "look"
    if any(w in t for w in ("escribir", "dibujar", "recortar", "cortar", "pintar", "apilar", "encajar", "construir")):
        return "make_draw"
    if any(w in t for w in ("parar", "quieto", "estatua", "congel", "esperar")):
        return "stop_freeze"
    if any(w in t for w in ("equilibrio", "pesar", "mismo peso", "manos iguales", "misma altura", "comparar")):
        return "balance"
    if any(w in t for w in ("mover la cabeza", "asentir", "negar")):
        return "nod_head"
    if any(w in t for w in ("encoger los hombros", "sin saber")):
        return "shrug"
    if any(w in t for w in ("triste", "llorar", "lágrima")):
        return "sad_face"
    if any(w in t for w in ("sorpresa", "admiración", "asombro", "¡oh!")):
        return "surprised_face"
    if any(w in full for w in ("sonreír", "reír", "risita", "content", "alegre", "feliz", "festivo")):
        return "happy_smile"
    if any(w in t for w in ("coger", "sujetar", "sostener", "llevar", "traer", "meter", "sacar")):
        return "hold_carry"
    if any(w in t for w in ("dar ", "ofrecer", "extender la mano")):
        return "give_offer"
    if any(w in t for w in ("abrir ", "cerrar ", "abrochar", "doblar", "envolver")):
        return "open_close"
    if any(w in t for w in ("mover las manos", "agitar", "sacudir")):
        return "shake_move"
    if _detect_body_part(full) and any(w in t for w in ("tocar", "señalar", "pasar la mano", "mover el", "mover la", "rascar", "frotar", "apretar", "cosquillas")):
        return "body_touch"
    if _detect_body_part(f"{en} {es}"):
        return "body_touch"
    if any(w in t for w in ("señalar", "mostrar", "enseñar")):
        return "point"
    if cat == "noun" and not any(w in t for w in ("saltar", "correr", "bailar")):
        return "present_object"
    return "show_gesture"


def _escoger_fondo(full: str, en: str) -> list[dict]:
    t = full.lower()
    if any(w in t for w in ("noite", "night", "noche", "luna", "moon", "estrella", "star", "sleep", "dormir", "lullaby", "owl", "búho")):
        return fondo_noite()
    if any(w in t for w in ("sea", "ocean", "mar", "oceano", "whale", "dolphin", "fish", "octopus", "crab", "swim", "nadar", "boat", "barco", "water", "agua", "wave", "ola")):
        return fondo_mar()
    if any(w in t for w in ("grass", "meadow", "forest", "tree", "garden", "flower", "leaf", "park", "prado", "bosque", "árbol", "flor", "hoja", "jardín", "patio", "farm", "granja")):
        return fondo_prado()
    if any(w in t for w in ("sky", "cloud", "rain", "sun", "wind", "rainbow", "fly", "bird", "plane", "rocket", "sol", "nube", "lluvia", "viento", "pájaro", "cielo")):
        return fondo_cielo()
    if any(w in t for w in ("table", "kitchen", "cup", "bowl", "plate", "spoon", "eat", "cook", "mesa", "cocina", "plato", "taza")):
        return fondo_mesa()
    return fondo_sala()


def _compose_scene(item: dict) -> tuple[str, list[dict], str, str]:
    """Genera (cd, formas, porque, fuente_extra) agrupado por gesto + motivos."""
    en = item["en"]
    es = item["es"]
    cat = item["cat"]
    tpr = item["tpr"]
    k = item["k"]
    full = f"{en} {es} {tpr}"
    low = full.lower()

    colors = _extract_colors(f"{en} {es}")
    color_val, color_lbl = colors[0] if colors else (None, None)
    count_val = _extract_count(f"{en} {es}")
    motifs = _extract_motifs(en, es, tpr)
    gesture = _classify_gesture(tpr, cat, en, es)

    bg = _escoger_fondo(full, en)
    formas: list[dict] = list(bg)
    used_srcs: set[str] = set()

    def use_fl(name: str, x: float, y: float, s: float) -> list[dict]:
        used_srcs.add("fl")
        return fl(name, x, y, s)

    # Indicadores ambientales de modificadores
    if any(w in low for w in ("cold", "freezing", "frost", "frío", "helado", "nieve")) and not any(m[0] == "snowflake" for m in motifs):
        formas += copos_nieve([(20, 18), (140, 20)])
    if any(w in low for w in ("hot", "warm", "steam", "caliente", "cálido", "calor", "templado")):
        formas += ondas_calor(126, 26, ROJO)
    if any(w in low for w in ("wet", "rain", "splash", "drip", "mojado", "húmedo", "lluvia", "salpicar", "goteando")):
        formas += gotas([(24, 18), (38, 12), (134, 16)])
    if any(w in low for w in ("loud", "noisy", "ruido", "fuerte", "clang", "bang", "ring", "alarm")):
        formas += ondas_sonido(126, 24, ROJO_OSCURO, 1)
    if any(w in low for w in ("sparkl", "glitter", "shiny", "bright", "magic", "brilla", "purpurina", "luz")):
        formas += [
            L("M134 12 L134 24", AMARILLO, 2.2),
            L("M128 18 L140 18", AMARILLO, 2.2),
            E(24, 20, 2.5, 2.5, AMARILLO),
        ]

    # Relaciones espaciales
    is_left = bool(re.search(r"\b(left|izquierd)\b", f"{en} {es}".lower()))
    is_right = bool(re.search(r"\b(right|derech)\b", f"{en} {es}".lower()))
    is_under = bool(re.search(r"\b(under|below|beneath|debajo|bajo)\b", f"{en} {es}".lower()))
    is_above = bool(re.search(r"\b(above|over|on top|top|encima|arriba|sobre)\b", f"{en} {es}".lower()))
    is_inside = bool(re.search(r"\b(inside|into|dentro)\b", f"{en} {es}".lower()))
    is_between = bool(re.search(r"\b(between|entre)\b", f"{en} {es}".lower()))

    def draw_motif(idx: int, x: float, y: float, s: float, override_col: str | None = None) -> None:
        if idx < len(motifs):
            _, msrc, fn = motifs[idx]
            used_srcs.add(msrc)
            formas.extend(fn(x, y, s, override_col or color_val))
        elif len(colors) >= 2 and idx == 0:
            formas.extend(pelota_prop(x + s * 0.28, y + s * 0.5, s * 0.24, colors[0][0], TINTA))
            formas.extend(pelota_prop(x + s * 0.72, y + s * 0.5, s * 0.24, colors[1][0], TINTA))
        elif color_val:
            formas.extend(pelota_prop(x + s * 0.5, y + s * 0.5, s * 0.36, color_val, TINTA))

    has_m0 = len(motifs) >= 1
    has_m1 = len(motifs) >= 2

    # Helper de tamaño comparativo (big vs small)
    is_big = bool(re.search(r"\b(big|large|huge|giant|tall|wide|grand[ea]|enorme|gigante|largo)\b", f"{en} {es}".lower()))
    is_small = bool(re.search(r"\b(small|little|tiny|mini|short|pequeñ|diminut|corto|bajito)\b", f"{en} {es}".lower()))

    # ── Renderizar por grupo de gesto ────────────────────────────────────
    if gesture == "present_object":
        if count_val and count_val in (2, 3) and has_m0:
            if count_val == 2:
                draw_motif(0, 26, 20, 48)
                draw_motif(0, 86, 20, 48)
            else:
                draw_motif(0, 14, 24, 40)
                draw_motif(0, 60, 24, 40)
                draw_motif(0, 106, 24, 40)
        elif has_m0 and has_m1:
            draw_motif(0, 22, 20, 50)
            draw_motif(1, 88, 20, 50)
        elif is_big and is_small:
            if has_m0:
                draw_motif(0, 18, 12, 60)
                draw_motif(0, 100, 46, 28)
            else:
                formas += pelota_prop(48, 44, 24, color_val or AZUL, AZUL_OSCURO)
                formas += pelota_prop(114, 58, 10, color_val or ROJO, ROJO_OSCURO)
        elif has_m0:
            draw_motif(0, 50, 16, 60)
        elif len(colors) >= 2:
            formas += pelota_prop(54, 48, 20, colors[0][0], TINTA)
            formas += pelota_prop(106, 48, 20, colors[1][0], TINTA)
        elif color_val:
            formas += pelota_prop(80, 46, 24, color_val, TINTA)
        elif count_val and 1 <= count_val <= 6:
            for idx in range(count_val):
                cx = 36 + (idx % 3) * 44
                cy = 34 if idx < 3 else 62
                formas.append(E(cx, cy, 10, 10, AMARILLO, NARANJA_OSCURO, 2.0))
        else:
            formas += nino((46, 32), (46, 45), (46, 66), [[(68, 42)], [(28, 56)]], [[(40, 88)], [(52, 88)]])
            formas += frecha((68, 42), (94, 42), ROJO, 3.2)
            formas += use_fl("Sparkles", 98, 24, 42)
        if color_val and has_m0 and motifs[0][0] not in ("circle", "square", "triangle", "diamond", "cube", "cylinder", "cone", "ball", "box"):
            formas.append(E(24, 76, 10, 10, color_val, TINTA, 2.0))
        if is_left:
            formas += frecha((132, 50), (96, 50), ROJO, 4)
        elif is_right:
            formas += frecha((28, 50), (64, 50), ROJO, 4)

    elif gesture == "baby_care":
        formas += nino((42, 30), (42, 43), (42, 64), [[(56, 48), (68, 52)], [(34, 56)]], [[(36, 86)], [(48, 86)]], camisa=(ROSA, ROSA_OSCURO))
        formas += bebe(72, 50)
        if has_m0:
            draw_motif(0, 106, 28, 38)
        else:
            formas.append(E(80, 24, 5, 5, ROJO))
            formas += use_fl("Red heart", 110, 24, 28)

    elif gesture == "baby_floor":
        formas.append(R(24, 68, 92, 12, 5, "#fde68a", NARANJA_OSCURO, 2.0))
        formas += bebe(62, 54)
        if has_m0:
            draw_motif(0, 108, 26, 38)

    elif gesture == "body_touch":
        bp = _detect_body_part(full)
        formas += nino((56, 28), (56, 42), (56, 62), [[(74, 48)], [(38, 50)]], [[(48, 88)], [(64, 88)]])
        if bp:
            _, target_pt = bp
            formas += frecha((98, target_pt[1] - 4), (target_pt[0] + 6, target_pt[1]), ROJO, 3.5)
            formas.append(E(target_pt[0], target_pt[1], 5.5, 5.5, None, AMARILLO_OSCURO, 2.5))
        if has_m0:
            draw_motif(0, 108, 22, 38)

    elif gesture == "sleep":
        formas += [R(18, 66, 76, 16, 5, "#93c5fd", AZUL_OSCURO, 2.0), E(26, 62, 11, 6, BLANCO, GRIS_OSCURO, 1.8)]
        formas += nino_acostado(24, 50, (MORADO, "#5b21b6"))
        formas += use_fl("Crescent moon", 118, 12, 28)
        if has_m0:
            draw_motif(0, 106, 44, 34)

    elif gesture == "shh":
        formas += nino((48, 32), (48, 45), (48, 66), [[(56, 36)], [(36, 58)]], [[(42, 88)], [(54, 88)]])
        formas.append(L("M56 42 L56 32", PELB, 3.2))
        formas.append(L("M56 42 L56 32", PEL, 2.0))
        if has_m0:
            draw_motif(0, 96, 24, 44)
        else:
            formas += ondas_sonido(72, 34, GRIS_OSCURO, 1)
            formas.append(L("M72 24 L86 44", ROJO, 2.8))

    elif gesture == "listen":
        formas += nino((46, 32), (46, 45), (46, 66), [[(36, 32)], [(58, 56)]], [[(40, 88)], [(52, 88)]])
        formas += ondas_sonido(26, 30, AZUL_OSCURO, -1)
        if has_m0:
            draw_motif(0, 94, 24, 46)
        else:
            formas += notas([(96, 48), (118, 36)])

    elif gesture == "peek":
        formas += nino((48, 34), (48, 47), (48, 68), [[(44, 34)], [(56, 34)]], [[(42, 88)], [(54, 88)]])
        if has_m0:
            draw_motif(0, 96, 22, 46)
        else:
            formas += cortina_prop(96, 18, 44)

    elif gesture == "crawl":
        if is_under and has_m0:
            draw_motif(0, 44, 14, 56)
            formas += nino_gateando(46, 54, mira=1)
        else:
            formas += nino_gateando(24, 52, mira=1)
            if has_m0:
                draw_motif(0, 100, 26, 42)
            else:
                formas += frecha((92, 64), (132, 64), VERDE_OSCURO, 3.5)

    elif gesture == "jump":
        formas.append(E(48, 86, 16, 4, GRIS))
        formas += nino((48, 22), (48, 35), (48, 52), [[(32, 22)], [(64, 22)]], [[(38, 66), (34, 72)], [(58, 66), (62, 72)]])
        formas += frecha((20, 68), (20, 32), AZUL_OSCURO, 3.2)
        if has_m0:
            draw_motif(0, 96, 26, 46)

    elif gesture == "run":
        formas += nino((52, 32), (48, 45), (44, 62), [[(66, 42)], [(32, 54)]], [[(60, 74), (72, 86)], [(28, 74), (18, 84)]])
        formas += [L("M14 38 L28 38", GRIS_OSCURO, 2.2), L("M10 48 L26 48", GRIS_OSCURO, 2.2)]
        if has_m0:
            draw_motif(0, 98, 26, 44)
        else:
            formas += frecha((76, 54), (124, 54), ROJO, 4)

    elif gesture == "walk":
        formas += nino((44, 32), (44, 45), (44, 64), [[(56, 54)], [(32, 56)]], [[(54, 76), (58, 88)], [(34, 76), (30, 88)]])
        formas += [E(74, 88, 5, 2.5, TIERRA), E(90, 88, 5, 2.5, TIERRA)]
        if has_m0:
            draw_motif(0, 96, 22, 46)
        else:
            formas += frecha((68, 52), (118, 52), VERDE_OSCURO, 3.5)

    elif gesture == "spin":
        formas += nino((48, 34), (48, 47), (48, 66), [[(28, 44)], [(68, 44)]], [[(42, 88)], [(54, 88)]])
        formas += arco_giro(48, 50, 26, MORADO)
        if has_m0:
            draw_motif(0, 98, 26, 44)

    elif gesture == "sway":
        formas += nino((50, 32), (48, 46), (46, 66), [[(28, 36)], [(68, 42)]], [[(38, 88)], [(54, 88)]])
        formas.append(L("M22 22 Q48 10 74 22", AZUL_OSCURO, 2.4))
        formas.append(P([(20, 23), (26, 19), (26, 26)], AZUL_OSCURO))
        formas.append(P([(76, 23), (70, 19), (70, 26)], AZUL_OSCURO))
        if has_m0:
            draw_motif(0, 98, 26, 44)

    elif gesture == "crouch":
        formas += nino((48, 52), (48, 63), (48, 76), [[(36, 70)], [(60, 70)]], [[(38, 86)], [(58, 86)]])
        formas += frecha((20, 24), (20, 62), NARANJA_OSCURO, 3.2)
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "sit":
        formas += [
            R(28, 64, 34, 6, 2, MADERA, MADERA_OSCURA, 1.8),
            R(31, 70, 5, 18, 1, MADERA_OSCURA),
            R(54, 70, 5, 18, 1, MADERA_OSCURA),
        ]
        formas += nino((44, 34), (44, 47), (44, 64), [[(56, 56)], [(34, 56)]], [[(58, 68), (62, 86)], [(54, 68), (58, 86)]])
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "lie":
        formas.append(R(14, 72, 76, 8, 3, VERDE, VERDE_OSCURO, 1.8))
        formas += nino_acostado(20, 54)
        if has_m0:
            draw_motif(0, 102, 22, 42)

    elif gesture == "blow":
        formas += nino((42, 34), (42, 47), (42, 66), [[(52, 56)], [(32, 58)]], [[(36, 88)], [(48, 88)]])
        formas += lineas_viento(58, 36, 32, AZUL_OSCURO)
        if has_m0:
            draw_motif(0, 98, 22, 44)
        else:
            formas += pompas([(104, 34, 8), (122, 26, 11), (132, 44, 6)])

    elif gesture == "smell":
        formas += nino((48, 34), (46, 47), (46, 66), [[(64, 42)], [(34, 58)]], [[(40, 88)], [(52, 88)]])
        formas += ondas_calor(72, 42, VERDE_OSCURO)
        if has_m0:
            draw_motif(0, 96, 26, 46)
        else:
            formas += use_fl("Blossom", 96, 26, 46)

    elif gesture == "eat_drink":
        formas += nino((44, 32), (44, 45), (44, 66), [[(56, 38)], [(32, 58)]], [[(38, 88)], [(50, 88)]])
        if has_m0:
            draw_motif(0, 92, 24, 46)
        else:
            formas += plato_prop(108, 60, 22)
            formas += cuchara_prop(92, 28, 30)

    elif gesture == "mouth_sing":
        formas += nino((44, 32), (44, 45), (44, 66), [[(62, 44)], [(28, 48)]], [[(38, 88)], [(50, 88)]])
        formas.append(E(47, 37, 2.5, 2.5, ROJO_OSCURO))
        formas += notas([(68, 30), (84, 22)])
        if has_m0:
            draw_motif(0, 98, 30, 44)

    elif gesture == "clap_tap":
        formas += nino((48, 32), (48, 45), (48, 66), [[(62, 42)], [(58, 48)]], [[(42, 88)], [(54, 88)]])
        formas += [L("M66 36 L74 30", AMARILLO_OSCURO, 2.2), L("M68 44 L78 44", AMARILLO_OSCURO, 2.2)]
        if has_m0:
            draw_motif(0, 96, 26, 46)
        else:
            formas += notas([(96, 46), (118, 36)])

    elif gesture == "wave":
        formas += nino((48, 32), (48, 45), (48, 66), [[(66, 22)], [(32, 56)]], [[(42, 88)], [(54, 88)]])
        formas += ondas_sonido(72, 22, NARANJA_OSCURO, 1)
        if has_m0:
            draw_motif(0, 98, 28, 44)

    elif gesture == "raise_hand":
        formas += nino((48, 34), (48, 47), (48, 66), [[(62, 16)], [(34, 58)]], [[(42, 88)], [(54, 88)]])
        formas += frecha((74, 46), (74, 16), VERDE_OSCURO, 3.0)
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "nod_head":
        formas += nino((48, 34), (48, 47), (48, 66), [[(34, 58)], [(62, 58)]], [[(42, 88)], [(54, 88)]])
        formas += [
            L("M28 24 Q22 32 28 40", AZUL_OSCURO, 2.2),
            P([(25, 22), (31, 22), (28, 27)], AZUL_OSCURO),
            P([(25, 42), (31, 42), (28, 37)], AZUL_OSCURO),
        ]
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "shrug":
        formas += nino((48, 34), (48, 47), (48, 66), [[(32, 50), (24, 44)], [(64, 50), (72, 44)]], [[(42, 88)], [(54, 88)]])
        formas += [
            L("M30 40 L26 32", NARANJA_OSCURO, 2.0),
            L("M66 40 L70 32", NARANJA_OSCURO, 2.0),
        ]
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "sad_face":
        formas += nino((48, 32), (48, 45), (48, 66), [[(34, 58)], [(62, 58)]], [[(42, 88)], [(54, 88)]], boca="triste")
        formas += gotas([(55, 36), (38, 38)])
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "surprised_face":
        formas += nino((48, 32), (48, 45), (48, 66), [[(32, 34)], [(64, 34)]], [[(42, 88)], [(54, 88)]])
        formas.append(E(48, 37, 2.5, 3.0, ROJO_OSCURO))
        formas += [L("M48 10 L48 16", AMARILLO_OSCURO, 2.2), L("M36 14 L40 19", AMARILLO_OSCURO, 2.2), L("M60 14 L56 19", AMARILLO_OSCURO, 2.2)]
        if has_m0:
            draw_motif(0, 96, 24, 46)

    elif gesture == "happy_smile":
        formas += nino((48, 32), (48, 45), (48, 66), [[(30, 44)], [(66, 44)]], [[(42, 88)], [(54, 88)]])
        formas.append(E(41, 33, 2.4, 1.8, "#f472b6"))
        formas.append(E(55, 33, 2.4, 1.8, "#f472b6"))
        if has_m0:
            draw_motif(0, 96, 24, 46)
        else:
            formas += use_fl("Smiling face with smiling eyes", 98, 26, 42)

    elif gesture == "hold_carry":
        formas += nino((46, 32), (46, 45), (46, 66), [[(64, 50)], [(60, 56)]], [[(40, 88)], [(52, 88)]])
        if has_m0:
            draw_motif(0, 74, 32, 44)
        else:
            formas += caja_prop(74, 42, 34, color_val or AMARILLO)

    elif gesture == "give_offer":
        formas += nino((40, 32), (40, 45), (40, 66), [[(64, 46)], [(58, 54)]], [[(34, 88)], [(46, 88)]])
        formas += frecha((66, 26), (92, 26), VERDE_OSCURO, 3.0)
        if has_m0:
            draw_motif(0, 88, 32, 44)
        else:
            formas += use_fl("Wrapped gift", 90, 34, 40)

    elif gesture == "open_close":
        is_close = bool(re.search(r"\b(close|shut|cerrar)\b", full.lower()))
        if has_m0:
            draw_motif(0, 56, 22, 48)
        else:
            formas += caja_prop(62, 34, 36, color_val or AMARILLO)
        if is_close:
            formas += frecha((24, 50), (50, 50), ROJO, 3.2)
            formas += frecha((136, 50), (110, 50), ROJO, 3.2)
        else:
            formas += frecha((50, 50), (22, 50), VERDE_OSCURO, 3.2)
            formas += frecha((110, 50), (138, 50), VERDE_OSCURO, 3.2)

    elif gesture == "shake_move":
        formas += nino((48, 32), (48, 45), (48, 66), [[(28, 38)], [(68, 38)]], [[(42, 88)], [(54, 88)]])
        formas += ondas_sonido(22, 36, NARANJA_OSCURO, -1)
        formas += ondas_sonido(74, 36, NARANJA_OSCURO, 1)
        if has_m0:
            draw_motif(0, 96, 26, 44)

    elif gesture == "hug_heart":
        formas += nino((48, 32), (48, 45), (48, 66), [[(56, 52), (46, 52)], [(40, 52), (50, 52)]], [[(42, 88)], [(54, 88)]])
        if has_m0:
            draw_motif(0, 96, 24, 46)
        else:
            formas += use_fl("Red heart", 96, 24, 46)

    elif gesture == "share_two":
        formas += nino((34, 34), (34, 47), (34, 66), [[(56, 50)], [(20, 56)]], [[(28, 88)], [(40, 88)]], mira=1)
        formas += nino((124, 34), (124, 47), (124, 66), [[(102, 50)], [(138, 56)]], [[(118, 88)], [(130, 88)]], camisa=(AZUL, AZUL_OSCURO), mira=-1)
        if has_m0:
            draw_motif(0, 62, 26, 36)
        else:
            formas += frecha((58, 42), (98, 42), AMARILLO_OSCURO, 3)

    elif gesture == "arms_up":
        formas += nino((48, 34), (48, 47), (48, 66), [[(34, 24), (32, 12)], [(62, 24), (64, 12)]], [[(42, 88)], [(54, 88)]])
        formas += frecha((18, 66), (18, 22), VERDE_OSCURO, 3.2)
        if has_m0:
            draw_motif(0, 96, 22, 46)

    elif gesture == "arms_wide":
        formas += nino((52, 32), (52, 45), (52, 66), [[(22, 44)], [(82, 44)]], [[(46, 88)], [(58, 88)]])
        formas += frecha((52, 20), (22, 20), AZUL_OSCURO, 2.8)
        formas += frecha((52, 20), (82, 20), AZUL_OSCURO, 2.8)
        if has_m0:
            draw_motif(0, 102, 26, 42)

    elif gesture == "push_pull":
        formas += nino((38, 34), (42, 47), (38, 66), [[(66, 46)], [(64, 54)]], [[(48, 88)], [(26, 88)]])
        if has_m0:
            draw_motif(0, 84, 34, 48)
        else:
            formas += caja_prop(84, 44, 36)
        formas += frecha((66, 24), (124, 24), ROJO, 3.5)

    elif gesture == "throw_catch":
        formas += nino((38, 34), (38, 47), (38, 66), [[(58, 30)], [(24, 56)]], [[(32, 88)], [(44, 88)]])
        formas.append(L("M62 28 Q92 8 118 32", AZUL_OSCURO, 2.5))
        if has_m0:
            draw_motif(0, 102, 24, 40)
        else:
            formas += pelota_prop(120, 38, 12)

    elif gesture == "water_action":
        formas += nino((42, 32), (42, 45), (42, 66), [[(64, 46)], [(58, 54)]], [[(36, 88)], [(48, 88)]])
        formas += gotas([(78, 22), (94, 16), (112, 24)])
        if has_m0:
            draw_motif(0, 94, 34, 46)
        else:
            formas += pompas([(82, 48, 7), (104, 44, 10), (122, 56, 6)])

    elif gesture == "count_fingers":
        n_dots = count_val if count_val and count_val <= 6 else 3
        formas += nino((40, 32), (40, 45), (40, 66), [[(56, 26)], [(26, 56)]], [[(34, 88)], [(46, 88)]])
        if has_m0:
            for idx in range(min(3, n_dots)):
                draw_motif(0, 76 + idx * 26, 46, 24)
        for i in range(n_dots):
            formas.append(E(80 + (i % 3) * 20, 22 + (i // 3) * 18, 6, 6, AMARILLO, NARANJA_OSCURO, 2.0))

    elif gesture == "look":
        formas += nino((42, 32), (42, 45), (42, 66), [[(60, 34)], [(28, 56)]], [[(36, 88)], [(48, 88)]])
        if has_m0:
            draw_motif(0, 96, 22, 46)
        else:
            formas += use_fl("Magnifying glass tilted left", 86, 22, 46)

    elif gesture == "make_draw":
        formas += nino((40, 32), (40, 45), (40, 66), [[(62, 44)], [(56, 54)]], [[(34, 88)], [(46, 88)]])
        if has_m0:
            draw_motif(0, 94, 24, 46)
        else:
            formas += use_fl("Pencil", 94, 24, 42)

    elif gesture == "stop_freeze":
        formas += nino((44, 32), (44, 45), (44, 66), [[(62, 36)], [(28, 56)]], [[(38, 88)], [(50, 88)]])
        formas += [E(112, 46, 20, 20, ROJO, ROJO_OSCURO, 2.5), R(102, 42, 20, 8, 2, BLANCO)]
        if has_m0:
            draw_motif(0, 66, 20, 30)

    elif gesture == "balance":
        formas += nino((50, 30), (50, 43), (50, 62), [[(24, 42)], [(76, 42)]], [[(48, 86)], [(62, 72), (54, 72)]])
        if has_m0 and has_m1:
            draw_motif(0, 12, 16, 26)
            draw_motif(1, 74, 16, 26)
        elif has_m0:
            draw_motif(0, 106, 24, 40)

    elif gesture == "point":
        formas += nino((42, 32), (42, 45), (42, 66), [[(68, 42)], [(28, 56)]], [[(36, 88)], [(48, 88)]])
        formas += frecha((68, 42), (90, 42), ROJO, 3.2)
        if has_m0 and has_m1:
            draw_motif(0, 92, 14, 36)
            draw_motif(1, 114, 48, 36)
        elif has_m0:
            draw_motif(0, 94, 22, 48)
        elif len(colors) >= 2:
            formas += pelota_prop(102, 44, 14, colors[0][0], TINTA)
            formas += pelota_prop(132, 44, 14, colors[1][0], TINTA)
        elif color_val:
            formas += pelota_prop(116, 44, 20, color_val, TINTA)

    else:  # show_gesture (fallback contextualizado siempre con sujeto + gesto)
        formas += nino((44, 32), (44, 45), (44, 66), [[(64, 40)], [(28, 52)]], [[(38, 88)], [(50, 88)]])
        if has_m0 and has_m1:
            draw_motif(0, 82, 16, 36)
            draw_motif(1, 112, 48, 36)
        elif has_m0:
            draw_motif(0, 94, 22, 48)
        elif len(colors) >= 2:
            formas += pelota_prop(102, 44, 14, colors[0][0], TINTA)
            formas += pelota_prop(132, 44, 14, colors[1][0], TINTA)
        elif color_val:
            formas += pelota_prop(116, 44, 20, color_val, TINTA)
        else:
            formas += use_fl("Sparkles", 98, 24, 42)

    # Ajustes espaciales adicionales si hay relación explícita
    if is_inside and has_m0 and not has_m1 and cat in ("phrase", "complex"):
        formas += frecha((94, 14), (114, 34), VERDE_OSCURO, 3.0)
    if is_above and has_m0 and cat in ("phrase", "complex"):
        formas += frecha((116, 68), (116, 20), AZUL_OSCURO, 3.0)
    if is_between and has_m0:
        formas.append(E(116, 48, 6, 6, AMARILLO, NARANJA_OSCURO, 2.0))

    if "mdi" in used_srcs or "noto" in used_srcs:
        cd, lic, sha = "C", "Apache-2.0", SHA_ICONIFY
    elif "tabler" in used_srcs:
        cd, lic, sha = "C", "MIT", SHA_ICONIFY
    elif "fl" in used_srcs:
        cd, lic, sha = "C", "MIT", SHA_FLUENT
    else:
        cd, lic, sha = "D", "Propia", SHA_PROPIA

    mot_txt = ", ".join(m[0] for m in motifs) if motifs else (color_lbl or gesture)
    porque = f"Gesto «{tpr}» con motivo ({mot_txt}) para «{es}»."
    return cd, formas, porque, f"{lic}|{sha}"


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

        revisado_flag = k in REVISADAS_TPR
        if k in CURATED_FLUENT_DIRECTOS:
            fl_name, ur, porque = CURATED_FLUENT_DIRECTOS[k]
            if FLUENT_SVGS:
                escribir_fluent_directo(pezas, k, slug, fl_name, ur, porque)
                pezas[k]["revisado"] = revisado_flag
            else:
                if k not in pezas or not (LAMINAS_DIR / f"{pezas[k]['clave']}.json").is_file():
                    raise RuntimeError(f"Falta lámina en disco para revisada Fluent {k!r} sin /tmp/banco_src")
                pezas[k]["revisado"] = revisado_flag
            stats[ur] += 1
        elif k in CURATED_ICONIFY_DIRECTOS:
            iset, iname, ur, cur_col, porque = CURATED_ICONIFY_DIRECTOS[k]
            if (RAIZ / "tools/banco/iconify-icon-sets").is_dir() and Path("/tmp/banco_src/iconify/json").is_dir():
                escribir_iconify_directo(pezas, k, slug, iset, iname, ur, porque, current_color=cur_col)
                pezas[k]["revisado"] = revisado_flag
            else:
                if k not in pezas or not (LAMINAS_DIR / f"{pezas[k]['clave']}.json").is_file():
                    raise RuntimeError(f"Falta lámina en disco para revisada Iconify {k!r} sin /tmp/banco_src")
                pezas[k]["revisado"] = revisado_flag
            stats[ur] += 1
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
    cubiertas = sum(stats.values())
    print(f"OK gen_laminas_tpr: {cubiertas} pezas TPR revisadas -> {stats}; {omitidas} sen lámina; {borradas} ficheiros borrados.")


if __name__ == "__main__":
    generar()
