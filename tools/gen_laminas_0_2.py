#!/usr/bin/env python3
"""Generador de las 285 láminas de 0-2 años (P2.3, O-20261111-4).

Cubre:
  - todas las lecciones de `curso_0_2` en `leccions.json` (169 claves únicas)
  - todo `acopros/proxectos_0_2.json` (palabras, canciones y rimas; 116 extra)
Total: 285 claves únicas, 0 piezas sin lámina en 0-2 años.
"""
from __future__ import annotations

import json
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(RAIZ / "tools"))

import banco_comun as bc  # noqa: E402
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
    E,
    F,
    GRIS,
    GRIS_OSCURO,
    HERBA,
    HERBAB,
    L,
    LECCIONS_PATH,
    MADERA,
    MADERA_OSCURA,
    MAPA_PATH,
    MAR_PROF,
    MORADO,
    NUBE,
    NUBE_B,
    P,
    PEL,
    PELB,
    R,
    ROJO,
    ROJO_OSCURO,
    TIERRA,
    TIERRA_CLARA,
    TINTA,
    VERDE,
    VERDE_OSCURO,
    copos_nieve,
    escribir_cd,
    escribir_fluent_directo,
    escribir_reutilizada,
    fl,
    fondo_cielo,
    fondo_mar,
    fondo_mesa,
    fondo_noite,
    fondo_prado,
    fondo_sala,
    frecha,
    gotas,
    molinillo,
    nino,
    notas,
    pano,
    pompas,
    slug_de,
    sol,
    tubo,
)

SCRIPT_REF = "tools/gen_laminas_0_2.py"

# ── Banco directo Fluent Emoji Flat (MIT) ────────────────────────────────
FLUENT_DIRECTOS: dict[str, tuple[str, str, str, str]] = {
    "apple": ("apple", "Red apple", "U", "Manzana roja brillante con hoja verde."),
    "balloon": ("balloon", "Balloon", "U", "Globo rojo flotando."),
    "bean": ("bean", "Beans", "R", "Judías marrones en primer plano."),
    "biscuit": ("biscuit", "Cookie", "R", "Galleta redonda con pepitas."),
    "blossom": ("blossom", "Blossom", "U", "Flor de árbol abierta con pétalos blancos."),
    "blueberry": ("blueberry", "Blueberries", "U", "Arándanos azules frescos."),
    "box": ("box", "Package", "R", "Caja de cartón cerrada."),
    "bread": ("bread", "Bread", "U", "Rebanada de pan tierno."),
    "bubble wand": ("bubble_wand", "Magic wand", "R", "Varita mágica para hacer burbujas."),
    "cat!": ("cat", "Cat", "U", "Gato de cuerpo entero."),
    "chick": ("chick", "Baby chick", "U", "Pollito amarillo."),
    "cold!": ("cold", "Cold face", "R", "Cara tiritando de frío."),
    "custard": ("custard", "Custard", "U", "Flan o natillas cremosas en plato."),
    "dog": ("dog", "Dog", "U", "Perro de cuerpo entero."),
    "raindrop": ("raindrop", "Droplet", "U", "Gota de lluvia azul."),
    "fairy lights": ("fairy_lights", "Sparkles", "R", "Lucecitas doradas que brillan."),
    "fireplace": ("fireplace", "Fire", "R", "Llama cálida de la chimenea."),
    "fish!": ("fish", "Fish", "U", "Pez azul nadando."),
    "footprint": ("footprint", "Footprints", "R", "Huellas de pies descalzos."),
    "goat": ("goat", "Goat", "U", "Cabra de perfil."),
    "honey": ("honey", "Honey pot", "U", "Tarro de miel dorada."),
    "jellyfish": ("jellyfish", "Jellyfish", "U", "Medusa marina rosada."),
    "kiss goodbye": ("kiss_goodbye", "Kiss mark", "R", "Beso suave de despedida."),
    "lamb": ("lamb", "Ewe", "R", "Oveja/corderito de lana blanca."),
    "leaf": ("leaf", "Maple leaf", "R", "Hoja de otoño."),
    "little fish": ("little_fish", "Tropical fish", "R", "Pececito de colores."),
    "mittens": ("mittens", "Gloves", "R", "Manoplas cálidas de invierno."),
    "orange slice": ("orange_slice", "Tangerine", "R", "Naranja fresca en gajos."),
    "party blower": ("party_blower", "Party popper", "R", "Accesorio festivo de soplar."),
    "paw": ("paw", "Paw prints", "R", "Huella de pata."),
    "plant pot": ("plant_pot", "Potted plant", "U", "Maceta con planta verde."),
    "present": ("present", "Wrapped gift", "U", "Regalo envuelto con lazo."),
    "puppy": ("puppy", "Dog face", "R", "Cachorro tierno."),
    "kitten": ("kitten", "Cat face", "R", "Gatito tierno."),
    "rocking horse": ("rocking_horse", "Carousel horse", "R", "Caballito de madera para mecerse."),
    "sleep!": ("sleep", "Sleeping face", "R", "Cara dormida tranquila."),
    "soap": ("soap", "Soap", "U", "Pastilla de jabón con espuma."),
    "sponge": ("sponge", "Sponge", "U", "Esponja amarilla porosa."),
    "stocking": ("stocking", "Socks", "R", "Calcetín cálido de invierno."),
    "sunbeam": ("sunbeam", "Sun", "R", "Sol luminoso con rayos."),
    "sunshade": ("sunshade", "Beach with umbrella", "R", "Parasol abierto dando sombra."),
    "torch": ("torch", "Flashlight", "U", "Linterna de mano encendida."),
    "tulip": ("tulip", "Tulip", "U", "Tulipán rojo con tallo y hojas."),
    "whiskers": ("whiskers", "Cat face", "R", "Bigotes largos en el hocico del gato."),
    "wool": ("wool", "Yarn", "R", "Ovillo de lana suave."),
    "yellow duck": ("yellow_duck", "Duck", "R", "Pato amarillo de agua."),
    "yoghurt": ("yoghurt", "Bowl with spoon", "R", "Cuenco de yogur con cucharita."),
    "many bubbles!": ("many_bubbles", "Bubbles", "R", "Muchas burbujas de jabón flotando."),
    "there are bubbles": ("there_are_bubbles", "Bubbles", "R", "Burbujas en el aire."),
    "my torch": ("my_torch", "Flashlight", "R", "Mi linterna encendida."),
    "what is it? a dog": ("what_dog", "Dog", "R", "Un perro amigable."),
    "baby oil": ("baby_oil", "Lotion bottle", "R", "Bote de aceite suave para bebé."),
    "confetti": ("confetti", "Confetti ball", "R", "Bola de confeti de colores."),
    "streamer": ("streamer", "Ribbon", "R", "Cinta serpentina ondulada."),
    "rainbow ribbon": ("rainbow_ribbon", "Rainbow", "R", "Arcoíris de cintas de colores."),
    "chestnut husk": ("chestnut_husk", "Chestnut", "R", "Castaña con su cubierta."),
}

# ── Reutilizadas propias Lúa (assets/brand/laminas/*.json) ──────────────
PROPIAS_REUTILIZADAS: dict[str, tuple[str, str]] = {
    "ball": ("vocab_45", "Pelota que bota del set propio."),
    "boat": ("barco", "Barco de la ría del set propio."),
    "tummy": ("barriga", "Barriga descubierta de frente, dibujo propio."),
    "head": ("cabeza", "Cabeza de niño o niña con orejas y pelo, dibujo propio."),
    "water": ("auga", "Vaso de agua del set propio."),
    "towel": ("toalla", "Toalla colgada del set propio."),
    "wellies": ("botas", "Par de botas de agua amarillas del set propio."),
    "jingle bell": ("cascabel", "Cascabel dorado con cinta del set propio."),
    "cot": ("vocab_60", "Cuna segura del set propio."),
    "nappy": ("vocab_61", "Pañal limpio del set propio."),
    "warm milk": ("vocab_62", "Biberón morno del set propio."),
    "beam": ("vocab_66", "Sonrisa grande y alegre del set propio."),
    "memory box": ("vocab_56", "Caja de tesoros y recuerdos del set propio."),
    "window pane": ("vocab_51", "Ventana con cristal y sol del set propio."),
    "sunny beach": ("vigo_nat_99", "Playa soleada del set propio."),
    "las olas de nuestra ría": ("vigo_nat_97", "Mar y olas de la ría."),
    "stone": ("vigo_nat_118", "Piedra redonda del set propio."),
    "toes": ("pes", "Pies descalzos con sus dedos visibles."),
    "earth": ("terra", "Maceta con tierra oscura para tocar."),
    "warm!": ("quente", "Taza humeante: algo calentito."),
    "green shoot": ("semente", "Semilla con brote verde saliendo de la tierra."),
    "big hug": ("aperta", "Dos niños o niñas dándose un abrazo grande."),
    "a leaf": ("folla", "Hoja otoñal del set propio."),
    "shell": ("cuncha", "Concha marina del set propio."),
    "there is a towel": ("toalla", "Una toalla colgada."),
    "it is water": ("auga", "Vaso con agua clara."),
    "some water": ("auga", "Un poco de agua en el vaso."),
    "some soap": ("xabon", "Pastilla de jabón con espuma."),
    "drizzle": ("choiva", "Llovizna suave cayendo de la nube."),
    "splash!": ("charco", "Charco de agua con salpicaduras."),
}


def _bebe(cx: float, cy: float, camisa: tuple[str, str] = (AZUL, AZUL_OSCURO)) -> list[dict]:
    """Bebé sentado en estilo plano Lúa (cabeza grande, cuerpo corto, brazos abiertos)."""
    return [
        R(cx - 10, cy + 8, 20, 16, 8, camisa[0], camisa[1], 2),
        L(f"M{cx - 9} {cy + 13} L{cx - 19} {cy + 7}", PELB, 5.5),
        L(f"M{cx - 9} {cy + 13} L{cx - 19} {cy + 7}", PEL, 3.2),
        L(f"M{cx + 9} {cy + 13} L{cx + 19} {cy + 7}", PELB, 5.5),
        L(f"M{cx + 9} {cy + 13} L{cx + 19} {cy + 7}", PEL, 3.2),
        E(cx, cy, 9.5, 9.5, PEL, PELB, 2.2),
        L(f"M{cx - 2} {cy - 9} Q{cx + 2} {cy - 13} {cx + 5} {cy - 8}", "#5a3a1a", 2),
        E(cx - 3, cy - 1, 1.2, 1.5, TINTA),
        E(cx + 3, cy - 1, 1.2, 1.5, TINTA),
        L(f"M{cx - 3} {cy + 3} Q{cx} {cy + 5.5} {cx + 3} {cy + 3}", "#9a3412", 1.4),
    ]


def _escenas_0_2() -> dict[str, tuple[str, str, list[dict], str]]:
    m: dict[str, tuple[str, str, list[dict], str]] = {}

    def put(k: str, cd: str, formas: list[dict], porque: str, slug: str | None = None) -> None:
        m[k] = (slug or slug_de(k), cd, formas, porque)

    # ── Acciones y gestos corporales / sensoriales ─────────────────────────
    put("a bubble", "D", fondo_prado() + [E(80, 46, 22, 22, "#bae6fd", AGUA_OSCURO, 2.5), E(71, 36, 5, 5, BLANCO)],
        "Una sola burbuja brillante flotando.")
    put("all wet!", "C", fondo_mar() + fl("Open hands", 48, 24, 52) + gotas([(46, 22), (80, 14), (112, 24)]),
        "Manos abiertas cubiertas de gotas de agua: todo mojado.")
    put("baa", "C", fondo_prado() + fl("Ewe", 44, 24, 58) + notas([(108, 28), (124, 20)]),
        "Oveja/cordero balando en el prado.")
    put("baby bath", "C", fondo_sala() + fl("Bathtub", 36, 22, 64) + _bebe(78, 36) + pompas([(48, 20, 5), (108, 18, 6)]),
        "Bebé chapoteando en la bañera con pompas.", "baby_bath")
    put("bath time!", "C", fondo_sala() + fl("Bathtub", 38, 22, 72) + pompas([(36, 24, 5), (118, 20, 6)]),
        "Bañera llena con pompas lista para la hora del baño.")
    put("bath towel", "C", fondo_sala() + pano(44, 20, 62, 54, "#bae6fd", AGUA_OSCURO) + _bebe(75, 44),
        "Toalla suave envolviendo al bebé tras el baño.")
    put("bath toy", "C", fondo_mar() + fl("Duck", 36, 28, 44) + fl("Sailboat", 86, 26, 46),
        "Patito y barquito flotando en el agua como juguetes de baño.")
    put("beach ball", "D", fondo_mar() + [
        E(80, 48, 26, 26, BLANCO, TINTA, 2.5),
        F("M80 48 L80 22 C94 22 106 34 106 48 Z", ROJO, TINTA, 1.5),
        F("M80 48 L54 48 C54 34 66 22 80 22 Z", AZUL, TINTA, 1.5),
        F("M80 48 L80 74 C94 74 106 62 106 48 Z", AMARILLO, TINTA, 1.5),
        E(80, 48, 5, 5, BLANCO, TINTA, 1.5),
    ], "Pelota grande de playa dividida en gajos de colores vivos.")
    put("beach towel", "C", [R(0, 0, 160, 100, 0, "#e0f2fe"), R(0, 62, 160, 38, 0, "#fde68a")] + pano(34, 46, 92, 34, "#fca5a5", ROJO_OSCURO) + fl("Sun", 14, 10, 24),
        "Toalla de colores extendida sobre la arena bajo el sol.")
    put("bib", "D", fondo_sala() + [
        F("M54 20 Q80 34 106 20 L114 42 Q114 78 80 84 Q46 78 46 42 Z", "#bae6fd", AZUL_OSCURO, 2.5),
        E(80, 22, 12, 8, "#fef3c7", "#d97706", 2),
        E(80, 54, 8, 8, AMARILLO, AMARILLO_OSCURO, 2),
    ], "Babero de tela con abertura para el cuello.")
    put("big!", "C", fondo_prado() + nino((80, 26), (80, 38), (80, 58), [[(42, 32), (34, 44)], [(118, 32), (126, 44)]], [[(72, 84)], [(88, 84)]]) + frecha((54, 16), (26, 16), AZUL_OSCURO, 3) + frecha((106, 16), (134, 16), AZUL_OSCURO, 3),
        "Niño abriendo mucho los brazos hacia fuera para mostrar grande.")
    put("big bubble", "C", fondo_prado() + [E(80, 44, 30, 30, "#bae6fd", AGUA_OSCURO, 2.5), E(68, 30, 7, 7, BLANCO)],
        "Una burbuja muy grande y brillante ocupando el centro.")
    put("bite!", "C", fondo_mesa() + fl("Red apple", 54, 22, 52) + [P([(92, 30), (106, 36), (92, 42)], BLANCO, TINTA, 2)],
        "Manzana con marca de mordisco.")
    put("blanket fort", "D", fondo_sala() + [
        P([(24, 78), (80, 22), (136, 78)], MORADO, "#5b21b6", 2.5),
        P([(58, 78), (80, 46), (102, 78)], "#1e293b"),
        R(32, 76, 96, 12, 4, "#fde68a", "#d97706", 2),
    ], "Cabaña triangular hecha con manta sobre el suelo.")
    put("blue cup", "D", fondo_mesa() + [
        P([(58, 28), (102, 28), (94, 76), (66, 76)], AZUL, AZUL_OSCURO, 2.5),
        E(80, 28, 22, 5, "#93c5fd", AZUL_OSCURO, 2),
    ], "Vaso de color azul sobre la mesa.")
    put("bounce on knee", "C", fondo_sala() + nino((52, 36), (52, 48), (52, 66), [[(74, 52)], [(40, 58)]], [[(82, 64), (82, 86)], [(64, 68), (64, 86)]], mira=1) + _bebe(82, 42) + frecha((98, 52), (98, 28), VERDE_OSCURO, 3),
        "Adulto haciendo botar suavemente al bebé en la rodilla.")
    put("breath", "D", fondo_sala() + [
        R(64, 16, 68, 66, 6, "#e0f2fe", AZUL_OSCURO, 2.5),
        E(34, 48, 12, 12, PEL, PELB, 2),
        L("M44 48 L54 44 L54 52 Z", PELB, 1),
        E(86, 48, 18, 14, BLANCO, GRIS_OSCURO, 1.5),
        L("M50 48 L68 48", AGUA_OSCURO, 2),
    ], "Vaho tibio del aliento empañando el cristal frío de la ventana.")
    put("brr, so cold!", "C", fondo_cielo("#e0f2fe") + fl("Cold face", 48, 20, 56) + copos_nieve([(24, 24), (132, 26), (128, 68)]),
        "Cara temblando de frío rodeada de copos de nieve.")
    put("bubble mixture", "C", fondo_mesa() + fl("Bottle with popping cork", 40, 24, 46) + pompas([(96, 30, 8), (114, 46, 6), (88, 54, 5)]),
        "Bote de agua con jabón rodeado de burbujas.")
    put("bud", "D", fondo_prado() + [
        L("M80 76 L80 42", VERDE_OSCURO, 4),
        F("M80 44 C64 38 66 18 80 14 C94 18 96 38 80 44 Z", "#f43f5e", ROJO_OSCURO, 2.2),
        F("M80 46 Q68 38 72 28 Q80 38 80 46 Z", VERDE, VERDE_OSCURO, 1.8),
    ], "Capullo de flor cerrado a punto de abrirse en el tallo.")
    put("bye-bye, nursery!", "C", fondo_prado() + fl("School", 22, 16, 56) + fl("Waving hand", 92, 28, 48),
        "Edificio de la escuela y mano saludando adiós.")
    put("cardboard box", "C", fondo_mesa() + fl("Package", 32, 24, 54) + fl("Teddy bear", 90, 32, 42) + frecha((104, 20), (66, 20), VERDE_OSCURO, 3),
        "Caja de cartón junto a un peluche para meter y sacar.")
    put("cardigan", "C", fondo_mesa() + fl("Coat", 46, 14, 68),
        "Rebeca abotonada de manga larga.")
    put("caress", "C", fondo_sala() + fl("Teddy bear", 30, 26, 54) + fl("Open hands", 86, 30, 44) + frecha((112, 20), (74, 20), MORADO, 3),
        "Mano abierta acariciando despacio.")
    put("change", "C", fondo_sala() + fl("Baby", 26, 22, 46) + [
        P([(90, 38), (132, 38), (124, 62), (98, 62)], BLANCO, GRIS_OSCURO, 2.2),
        R(84, 38, 10, 8, 2, "#93c5fd", AZUL_OSCURO, 1.5),
        R(128, 38, 10, 8, 2, "#93c5fd", AZUL_OSCURO, 1.5),
    ], "Bebé junto a un pañal limpio con cierres para cambiar.")
    put("clap", "C", fondo_prado() + fl("Clapping hands", 46, 18, 66),
        "Dos manos dando palmas: aplaudir.")
    put("clown nose", "D", fondo_sala() + [
        E(80, 48, 24, 24, PEL, PELB, 2.5),
        E(71, 41, 2.5, 2.5, TINTA),
        E(89, 41, 2.5, 2.5, TINTA),
        L("M69 57 Q80 65 91 57", "#9a3412", 2),
        E(80, 49, 8, 8, ROJO, ROJO_OSCURO, 2),
    ] + frecha((122, 49), (94, 49), ROJO_OSCURO, 3), "Cara sonriente con nariz roja redonda de payaso.")
    put("shush", "D", fondo_sala() + [
        E(80, 42, 24, 24, PEL, PELB, 2.5),
        E(71, 36, 2.2, 2.5, TINTA),
        E(89, 36, 2.2, 2.5, TINTA),
        E(80, 50, 4, 4, "#9a3412"),
        R(77, 46, 6, 24, 3, "#fcd34d", PELB, 2),
    ], "Dedo índice vertical sobre los labios pidiendo silencio suave.")
    put("daisy", "D", fondo_prado() + [
        L("M80 76 L80 46", VERDE_OSCURO, 4),
        E(80, 26, 9, 9, BLANCO, GRIS_OSCURO, 1.5),
        E(94, 34, 9, 9, BLANCO, GRIS_OSCURO, 1.5),
        E(88, 48, 9, 9, BLANCO, GRIS_OSCURO, 1.5),
        E(72, 48, 9, 9, BLANCO, GRIS_OSCURO, 1.5),
        E(66, 34, 9, 9, BLANCO, GRIS_OSCURO, 1.5),
        E(80, 38, 10, 10, AMARILLO, AMARILLO_OSCURO, 2),
    ], "Margarita blanca de pétalos abiertos con centro amarillo.")
    put("drop!", "C", fondo_cielo() + gotas([(80, 24)]) + [E(80, 68, 22, 6, None, AGUA_OSCURO, 2)],
        "Gota cayendo justo sobre la superficie del agua.")
    put("jelly", "D", fondo_mesa() + [
        E(80, 68, 34, 8, BLANCO, GRIS_OSCURO, 2),
        F("M54 64 Q56 32 80 30 Q104 32 106 64 Z", "#f43f5e", ROJO_OSCURO, 2.2),
        E(72, 42, 6, 4, "#fecdd3"),
    ], "Gelatina roja brillante y temblorosa en plato.")
    put("pebble", "D", fondo_prado() + [
        E(80, 64, 18, 11, GRIS, GRIS_OSCURO, 2.2),
        E(74, 60, 6, 3, NUBE),
    ], "Piedrecita lisa y pequeña de río sobre la hierba.")
    put("sun cream", "C", fondo_prado() + fl("Lotion bottle", 36, 22, 54) + fl("Sun", 92, 16, 42),
        "Bote de crema protectora solar junto al sol.")
    put("the towel is dry", "C", fondo_sala() + pano(44, 24, 58, 44, "#fde68a", "#d97706") + fl("Sun", 104, 12, 34),
        "Toalla completamente seca bajo un sol cálido.")
    put("this leaf", "C", fondo_prado() + fl("Maple leaf", 38, 22, 56) + frecha((116, 44), (92, 44), ROJO_OSCURO, 3.5),
        "Esta hoja señalada de cerca con flecha.")
    put("coat hook", "C", fondo_sala() + [R(24, 24, 112, 16, 4, MADERA, MADERA_OSCURA, 2.2), E(80, 32, 4, 4, TINTA), L("M80 36 L80 44", TINTA, 3)] + fl("Coat", 56, 42, 48),
        "Perchero de madera con un abrigo colgado.")
    put("collar", "C", fondo_mesa() + fl("Dog", 32, 22, 54) + [R(94, 44, 44, 14, 6, ROJO, ROJO_OSCURO, 2), E(116, 62, 5, 5, AMARILLO, AMARILLO_OSCURO, 1.8)],
        "Perro junto a su collar con chapita.")
    put("colour card", "D", fondo_mesa() + [
        R(24, 20, 34, 48, 5, ROJO, ROJO_OSCURO, 2.2),
        R(63, 20, 34, 48, 5, AMARILLO, AMARILLO_OSCURO, 2.2),
        R(102, 20, 34, 48, 5, AZUL, AZUL_OSCURO, 2.2),
    ], "Tarjetas de colores vivos rojo, amarillo y azul.")
    put("copy", "C", fondo_prado() + nino((46, 30), (46, 42), (46, 62), [[(30, 26)], [(62, 26)]], [[(40, 86)], [(52, 86)]]) + nino((114, 30), (114, 42), (114, 62), [[(98, 26)], [(130, 26)]], [[(108, 86)], [(120, 86)]], camisa=(VERDE, VERDE_OSCURO)),
        "Dos niños haciendo exactamente el mismo gesto con los brazos en alto: imitar.")
    put("cotton", "D", fondo_cielo("#f1f5f9") + [
        E(80, 52, 24, 18, BLANCO, GRIS_OSCURO, 2),
        E(62, 46, 14, 13, BLANCO, GRIS_OSCURO, 1.8),
        E(98, 46, 14, 13, BLANCO, GRIS_OSCURO, 1.8),
        E(80, 36, 16, 14, BLANCO, GRIS_OSCURO, 1.8),
    ], "Copo de algodón blanco muy esponjoso.")
    put("cradle song", "C", fondo_noite() + fl("Crescent moon", 20, 12, 34) + _bebe(80, 52) + notas([(114, 34), (132, 24)]),
        "Luna nocturna y notas musicales suaves acunando al bebé.")
    put("crunch, crunch!", "C", fondo_prado() + fl("Fallen leaf", 28, 26, 48) + fl("Ear", 90, 26, 44),
        "Hoja seca crujiendo junto a la oreja.")
    put("cushion", "D", fondo_sala() + [
        R(40, 26, 80, 50, 14, "#fca5a5", ROJO_OSCURO, 2.5),
        L("M52 38 Q80 48 108 38", ROJO_OSCURO, 1.8),
    ], "Cojín mullido y blando para apoyar la cabeza.")
    put("dog bowl", "C", fondo_mesa() + [F("M44 58 L54 78 L106 78 L116 58 Z", AZUL, AZUL_OSCURO, 2.2), E(80, 58, 36, 7, "#93c5fd", AZUL_OSCURO, 2)] + fl("Dog", 16, 14, 40),
        "Perro junto a su cuenco vacío en el suelo.")
    put("down", "C", fondo_prado() + nino((72, 26), (72, 38), (72, 58), [[(60, 62)], [(84, 62)]], [[(66, 86)], [(78, 86)]]) + frecha((116, 22), (116, 76), AZUL_OSCURO, 4.5),
        "Niño bajando las manos y flecha grande hacia abajo.")
    put("drip, drop!", "C", fondo_cielo() + fl("Cloud with rain", 42, 10, 52) + gotas([(62, 66), (86, 74), (104, 64)]),
        "Gotas cayendo una a una desde la nube.")
    put("dummy", "D", fondo_sala() + [
        E(80, 62, 16, 14, None, AZUL_OSCURO, 3.5),
        R(54, 42, 52, 18, 9, "#93c5fd", AZUL_OSCURO, 2.2),
        E(80, 42, 8, 12, "#fde68a", "#d97706", 2),
        E(80, 51, 9, 9, AZUL, AZUL_OSCURO, 2),
    ], "Chupete de bebé con anilla y tetina.")
    put("eat!", "C", fondo_mesa() + fl("Bowl with spoon", 50, 22, 60),
        "Cuenco con cuchara listo para comer.")
    put("eyebrows", "C", fondo_sala() + fl("Eyes", 42, 34, 66) + [L("M46 31 Q60 22 74 31", "#5a3a1a", 4.5), L("M86 31 Q100 22 114 31", "#5a3a1a", 4.5)] + frecha((30, 14), (48, 26), ROJO_OSCURO, 2.8) + frecha((130, 14), (112, 26), ROJO_OSCURO, 2.8),
        "Dos ojos con las cejas marcadas justo encima.")
    put("face paint", "C", fondo_sala() + fl("Artist palette", 24, 22, 54) + nino((106, 36), (106, 48), (106, 68), [[(92, 56)], [(120, 56)]], [[(100, 86)], [(112, 86)]]) + [E(112, 39, 2, 2, ROJO)],
        "Paleta de colores y punto pintado en la mejilla.")
    put("falling, falling, falling down!", "C", fondo_prado() + fl("Fallen leaf", 24, 14, 34) + fl("Maple leaf", 74, 28, 36) + fl("Fallen leaf", 108, 48, 34) + frecha((54, 20), (54, 68), TIERRA, 3),
        "Varias hojas cayendo suavemente hacia el suelo.")
    put("feel this!", "C", fondo_mesa() + fl("Open hands", 24, 28, 48) + fl("Teddy bear", 86, 24, 52),
        "Mano abierta tocando un peluche suave para sentir la textura.")
    put("finger puppet", "D", fondo_sala() + [
        tubo([(80, 88), (80, 56)], PEL, PELB, 14)[0],
        tubo([(80, 88), (80, 56)], PEL, PELB, 14)[1],
        R(64, 34, 32, 34, 10, VERDE, VERDE_OSCURO, 2.2),
        E(80, 26, 16, 14, VERDE, VERDE_OSCURO, 2.2),
        E(74, 22, 3, 3, BLANCO, TINTA, 1.5),
        E(86, 22, 3, 3, BLANCO, TINTA, 1.5),
    ], "Títere de dedo colocado en la punta del dedo.")
    put("fingers and thumbs", "C", fondo_sala() + fl("Hand with fingers splayed", 26, 18, 52) + fl("Thumbs up", 92, 22, 46),
        "Mano con dedos abiertos junto a pulgar en alto.")
    put("flutter", "C", fondo_prado() + fl("Butterfly", 36, 20, 56) + [L("M96 42 Q118 30 134 40", AZUL_OSCURO, 2.5), L("M96 54 Q118 66 134 56", AZUL_OSCURO, 2.5)],
        "Mariposa revoloteando con estela de alas.")
    put("forehead", "C", fondo_sala() + _bebe(80, 52) + frecha((80, 14), (80, 36), ROJO_OSCURO, 3.5),
        "Bebé y flecha señalando la frente arriba de los ojos.")
    put("frost", "C", fondo_cielo("#e0f2fe") + fl("Window", 32, 16, 62) + copos_nieve([(96, 28), (118, 42), (104, 58), (124, 22)]),
        "Escarcha helada y copos de hielo sobre la ventana.")
    put("funnel", "D", fondo_mesa() + [
        P([(44, 18), (116, 18), (88, 52), (88, 76), (72, 76), (72, 52)], AZUL, AZUL_OSCURO, 2.5),
        E(80, 18, 36, 6, "#93c5fd", AZUL_OSCURO, 2),
    ] + gotas([(80, 82)]), "Embudo azul dejando caer una gota por la boca estrecha.")
    put("garden", "C", fondo_prado() + fl("Deciduous tree", 18, 12, 60) + fl("Blossom", 86, 46, 30) + fl("Tulip", 118, 44, 30),
        "Jardín verde con árbol y flores abiertas.")
    put("go!", "C", fondo_prado() + nino((54, 30), (52, 42), (48, 60), [[(68, 44)], [(36, 48)]], [[(64, 74), (72, 86)], [(34, 76), (26, 84)]], mira=1) + frecha((88, 48), (138, 48), VERDE_OSCURO, 4.5),
        "Niño echando a andar hacia delante siguiendo una flecha verde.")
    put("grandad", "C", fondo_sala() + fl("Older person", 46, 18, 66),
        "Abuelo sonriente en primer plano.")
    put("grasp", "C", fondo_sala() + fl("Pinching hand", 34, 24, 50) + [E(92, 46, 12, 12, ROJO, ROJO_OSCURO, 2.5)],
        "Mano cerrándose para agarrar un objeto redondo.")
    put("greet", "C", fondo_prado() + fl("Waving hand", 28, 22, 48) + nino((104, 34), (104, 46), (104, 66), [[(86, 42)], [(118, 56)]], [[(98, 86)], [(110, 86)]]),
        "Niño sonriendo y saludando con la mano.")
    put("hammock", "D", fondo_prado() + [
        L("M20 26 L140 26", MADERA_OSCURA, 2),
        F("M20 34 Q80 86 140 34 Q80 62 20 34 Z", "#fca5a5", ROJO_OSCURO, 2.5),
    ] + _bebe(80, 44), "Bebé mecéndose tranquilo en una hamaca de tela.")
    put("hand towel", "C", fondo_sala() + pano(30, 26, 52, 46, "#bae6fd", AGUA_OSCURO) + fl("Open hands", 88, 28, 46),
        "Toalla colgada junto a dos manos secándose.")
    put("hat on, hat off", "C", fondo_sala() + fl("Womans hat", 20, 24, 46) + frecha((72, 48), (94, 48), AZUL_OSCURO, 3) + _bebe(122, 44),
        "Gorro y bebé con flecha indicando ponerse y quitarse el gorro.")
    put("head to toes", "C", fondo_prado() + nino((72, 20), (72, 32), (72, 54), [[(60, 46)], [(84, 46)]], [[(66, 84)], [(78, 84)]]) + frecha((114, 16), (114, 86), MORADO, 3.5),
        "Cuerpo entero desde la cabeza hasta los pies con flecha vertical.")
    put("hello, little one!", "C", fondo_sala() + _bebe(56, 46) + fl("Waving hand", 96, 22, 46),
        "Bebé mirando alegre a la mano que lo saluda.")
    put("hello, sea!", "C", fondo_mar() + fl("Water wave", 18, 42, 48) + fl("Waving hand", 92, 18, 48),
        "Mano saludando ante las olas del mar.")
    put("here comes a wave!", "C", fondo_mar() + fl("Water wave", 22, 24, 62) + frecha((94, 52), (138, 52), AZUL_OSCURO, 4),
        "Gran ola de mar avanzando con fuerza.")
    put("hood", "D", fondo_prado() + [
        F("M60 44 C60 16 100 16 100 44 L112 78 L48 78 Z", ROJO, ROJO_OSCURO, 2.5),
        E(80, 36, 13, 13, PEL, PELB, 2),
        E(76, 35, 1.5, 1.5, TINTA),
        E(84, 35, 1.5, 1.5, TINTA),
    ] + frecha((118, 22), (96, 26), AZUL_OSCURO, 3), "Chaqueta con capucha roja puesta cubriendo la cabeza.")
    put("hop along", "C", fondo_prado() + fl("Frog", 32, 36, 44) + [L("M74 44 Q96 14 118 44", VERDE_OSCURO, 3)] + frecha((114, 38), (122, 48), VERDE_OSCURO, 3),
        "Rana saltando por arcos sucesivos sobre la hierba.")
    put("hum a tune", "C", fondo_sala() + nino((62, 34), (62, 46), (62, 66), [[(48, 54)], [(76, 54)]], [[(56, 86)], [(68, 86)]]) + notas([(96, 28), (116, 20), (132, 32)]),
        "Niño tarareando una melodía con notas musicales en el aire.")
    put("in my arms", "C", fondo_sala() + nino((58, 34), (58, 46), (58, 66), [[(74, 48), (82, 54)], [(46, 56)]], [[(52, 86)], [(64, 86)]]) + _bebe(82, 46),
        "Persona sosteniendo suavemente al bebé en sus brazos.")
    put("jump, jump, green frog! ribbit!", "C", fondo_prado() + fl("Frog", 52, 26, 56) + frecha((30, 68), (30, 22), VERDE_OSCURO, 3.5) + frecha((130, 68), (130, 22), VERDE_OSCURO, 3.5),
        "Rana verde dando grandes saltos hacia arriba.")
    put("jug", "D", fondo_mesa() + [
        F("M56 26 L100 26 L106 72 L50 72 Z", "#93c5fd", AZUL_OSCURO, 2.5),
        L("M100 32 C120 32 120 62 104 62", AZUL_OSCURO, 4),
        L("M50 26 L44 20 L60 22", AZUL_OSCURO, 2.5),
        E(78, 48, 16, 6, AGUA, AGUA_OSCURO, 1.5),
    ], "Jarra azul transparente con asa y pico para verter agua.")
    put("kennel", "D", fondo_prado() + [
        R(42, 40, 76, 44, 4, MADERA, MADERA_OSCURA, 2.5),
        P([(32, 44), (80, 14), (128, 44)], ROJO, ROJO_OSCURO, 2.5),
        F("M66 84 L66 62 C66 48 94 48 94 62 L94 84 Z", "#1e293b"),
    ], "Caseta de madera con tejado rojo y puerta arqueada.")
    put("knuckles", "C", fondo_sala() + fl("Oncoming fist", 46, 20, 64),
        "Puño cerrado mostrando los nudillos al frente.")
    put("lap", "C", fondo_sala() + nino((58, 30), (58, 42), (58, 60), [[(74, 54)], [(46, 54)]], [[(86, 60), (88, 86)], [(76, 60), (78, 86)]], mira=1) + _bebe(76, 42),
        "Bebé sentado cómodamente en el regazo.")
    put("leaf pile", "C", fondo_prado() + fl("Fallen leaf", 26, 42, 44) + fl("Maple leaf", 56, 30, 48) + fl("Fallen leaf", 88, 44, 44),
        "Montón grande de hojas secas acumuladas en la hierba.")
    put("leaves are falling", "C", fondo_prado() + fl("Deciduous tree", 16, 12, 64) + fl("Maple leaf", 88, 22, 30) + fl("Fallen leaf", 112, 52, 30) + frecha((104, 16), (104, 72), TIERRA, 3),
        "Hojas desprendiéndose del árbol y cayendo al suelo.")
    put("let go", "C", fondo_prado() + fl("Open hands", 24, 18, 48) + fl("Red apple", 86, 48, 36) + frecha((104, 24), (104, 46), AZUL_OSCURO, 3),
        "Mano abierta dejando caer suavemente una manzana.")
    put("lift", "C", fondo_prado() + nino((62, 44), (62, 56), (62, 72), [[(44, 26)], [(80, 26)]], [[(56, 88)], [(68, 88)]]) + fl("Soccer ball", 44, 6, 32) + frecha((116, 72), (116, 22), VERDE_OSCURO, 4),
        "Brazos alzando hacia arriba por encima de la cabeza.")
    put("lips", "D", fondo_sala() + [
        F("M44 50 Q64 32 80 42 Q96 32 116 50 Q80 56 44 50 Z", "#f43f5e", ROJO_OSCURO, 2.5),
        F("M44 50 Q80 74 116 50 Q80 56 44 50 Z", ROJO, ROJO_OSCURO, 2.5),
    ], "Labios dibujados claramente en el centro.")
    put("make faces", "C", fondo_sala() + fl("Winking face with tongue", 26, 20, 48) + fl("Zany face", 86, 20, 48),
        "Caras divertidas haciendo muecas juguetonas.")
    put("mashed banana", "C", fondo_mesa() + fl("Banana", 22, 22, 46) + fl("Fork and knife", 72, 24, 42) + [E(122, 62, 22, 10, AMARILLO, AMARILLO_OSCURO, 2)],
        "Plátano chafado en el plato con tenedor.")
    put("massage", "C", fondo_sala() + _bebe(56, 48) + fl("Open hands", 92, 24, 46) + [L("M96 70 Q114 78 132 70", MORADO, 2.5)],
        "Manos realizando un masaje circular muy suave.")
    put("moss", "C", fondo_prado() + fl("Rock", 42, 34, 58) + [E(62, 36, 24, 10, VERDE, VERDE_OSCURO, 2), E(84, 42, 16, 8, HERBA, VERDE_OSCURO, 2)],
        "Capa verde esponjosa de musgo cubriendo una piedra.")
    put("nursery", "C", fondo_prado() + fl("School", 44, 14, 68),
        "Edificio colorido de la escuela infantil con puerta acogedora.")
    put("paddling pool", "D", fondo_prado() + [
        E(80, 62, 52, 22, AZUL, AZUL_OSCURO, 3),
        E(80, 56, 44, 16, AGUA, AGUA_OSCURO, 2),
    ] + fl("Duck", 64, 34, 30), "Piscina infantil azul llena de agua con patito.")
    put("palm", "C", fondo_sala() + fl("Raised hand", 46, 16, 66) + [E(80, 56, 10, 10, "#fecaca", ROJO_OSCURO, 1.5)],
        "Palma de la mano abierta señalando el centro.")
    put("parasol", "D", fondo_prado() + [
        L("M80 76 L80 28", MADERA_OSCURA, 3.5),
        F("M44 38 C52 14 108 14 116 38 Z", "#f43f5e", ROJO_OSCURO, 2.5),
        F("M68 38 C72 16 88 16 92 38 Z", AMARILLO, "#d97706", 1.8),
        E(80, 18, 3, 3, MADERA_OSCURA),
    ] + fl("Sun", 16, 10, 26), "Sombrilla abierta de jardín dando sombra sobre la hierba.")
    put("pat-a-cake", "C", fondo_sala() + fl("Clapping hands", 46, 18, 66),
        "Dos manos haciendo palmitas al ritmo.")
    put("petal", "C", fondo_prado() + fl("Blossom", 28, 26, 48) + [F("M92 50 C96 28 122 24 126 42 C122 58 98 62 92 50 Z", "#f472b6", "#be185d", 2)],
        "Flor junto a un pétalo suelto para tocar suavemente.")
    put("pick up!", "C", fondo_prado() + nino((58, 44), (62, 54), (66, 70), [[(86, 68)], [(80, 74)]], [[(58, 76), (52, 88)], [(74, 76), (78, 88)]], mira=1) + fl("Package", 96, 56, 28) + frecha((112, 52), (112, 22), VERDE_OSCURO, 3),
        "Niño agachado recogiendo del suelo hacia arriba.")
    put("pitter-patter", "C", fondo_mesa() + fl("Cloud with rain", 42, 8, 50) + gotas([(52, 62), (72, 66), (92, 60), (110, 66)]),
        "Lluvia ligera repiqueteando gotita a gotita.")
    put("pom-pom", "D", fondo_sala() + [
        E(80, 48, 22, 22, "#f43f5e", ROJO_OSCURO, 2),
        E(64, 38, 12, 12, "#fb7185", ROJO_OSCURO, 1.5),
        E(96, 38, 12, 12, "#fb7185", ROJO_OSCURO, 1.5),
        E(66, 60, 12, 12, "#fb7185", ROJO_OSCURO, 1.5),
        E(94, 60, 12, 12, "#fb7185", ROJO_OSCURO, 1.5),
    ], "Pompón mullido y alegre de lana roja.")
    put("put on your hat!", "C", fondo_sala() + nino((80, 40), (80, 52), (80, 70), [[(62, 34)], [(98, 34)]], [[(74, 88)], [(86, 88)]]) + fl("Womans hat", 56, 6, 48),
        "Niño poniéndose el gorro encima de la cabeza.")
    put("quilt", "D", fondo_noite() + [
        R(32, 30, 96, 52, 8, "#f87171", ROJO_OSCURO, 2.5),
        R(44, 40, 32, 16, 3, "#fde68a", "#d97706", 1.5),
        R(84, 40, 32, 16, 3, "#93c5fd", AZUL_OSCURO, 1.5),
        R(44, 60, 32, 16, 3, "#86efac", VERDE_OSCURO, 1.5),
        R(84, 60, 32, 16, 3, "#fde68a", "#d97706", 1.5),
    ], "Edredón suave de retales de colores para abrigarse.")
    put("rain cover", "C", fondo_prado() + fl("Cloud with rain", 20, 8, 42) + [F("M54 78 L54 44 C54 22 108 22 108 44 L108 78 Z", "#bae6fd", AGUA_OSCURO, 2.5)] + _bebe(80, 56),
        "Cubierta transparente protegiendo al bebé de la lluvia.")
    put("rain, rain, little drops, tap, tap, tap", "C", fondo_prado() + fl("Cloud with rain", 52, 4, 40) + fl("Open hands", 58, 52, 44) + gotas([(68, 42), (80, 40), (92, 42)]),
        "Gotitas de lluvia cayendo suavemente sobre las manos abiertas.")
    put("rake", "D", fondo_prado() + [
        L("M30 22 L96 68", MADERA_OSCURA, 4),
        L("M82 82 L116 54", ROJO_OSCURO, 4),
        L("M86 78 L94 88", ROJO_OSCURO, 2.5),
        L("M96 70 L104 80", ROJO_OSCURO, 2.5),
        L("M106 62 L114 72", ROJO_OSCURO, 2.5),
    ], "Rastrillo pequeño de jardín con púas.")
    put("red ball", "D", fondo_prado() + [
        E(80, 48, 28, 28, ROJO, ROJO_OSCURO, 3),
        E(70, 36, 7, 5, "#ffffff88"),
    ], "Pelota grande de color rojo brillante.")
    put("ring the bells", "C", fondo_sala() + fl("Bell", 36, 20, 52) + fl("Bell", 84, 24, 42) + notas([(24, 34), (132, 30)]),
        "Campanas sonando alegres con notas musicales.")
    put("ripples", "D", fondo_mar() + [
        E(80, 74, 46, 12, None, BLANCO, 2),
        E(80, 74, 28, 7, None, BLANCO, 2),
        E(80, 74, 12, 3, None, BLANCO, 2),
    ], "Ondas circulares abriéndose en la superficie del agua.")
    put("roasting pan", "C", fondo_mesa() + fl("Cooking", 46, 18, 66),
        "Sartén honda de cocina vista desde arriba.")
    put("roll it to me", "C", fondo_prado() + nino((34, 32), (34, 44), (34, 64), [[(50, 56)], [(22, 56)]], [[(28, 86)], [(40, 86)]], mira=1) + fl("Soccer ball", 66, 54, 28) + frecha((66, 46), (112, 46), VERDE_OSCURO, 3.5) + nino((128, 32), (128, 44), (128, 64), [[(112, 56)], [(140, 56)]], [[(122, 86)], [(134, 86)]], camisa=(AZUL, AZUL_OSCURO), mira=-1),
        "Niño rodando la pelota hacia su compañero que espera con las manos abiertas.")
    put("roll! / ball!", "C", fondo_prado() + fl("Soccer ball", 54, 34, 44) + frecha((104, 56), (138, 56), AZUL_OSCURO, 4),
        "Pelota rodando con fuerza hacia delante.")
    put("roll, roll, yellow circle!", "C", fondo_mesa() + [
        E(74, 48, 24, 24, AMARILLO, AMARILLO_OSCURO, 3),
        L("M64 36 Q74 26 84 36", BLANCO, 2),
    ] + frecha((104, 48), (136, 48), VERDE_OSCURO, 3.5),
        "Círculo amarillo brillante girando y rodando.")
    put("rub!", "C", fondo_sala() + fl("Open hands", 46, 20, 56) + frecha((30, 54), (30, 32), MORADO, 3) + frecha((126, 32), (126, 54), MORADO, 3),
        "Manos frotando hacia arriba y abajo suavemente.")
    put("run!", "C", fondo_prado() + nino((62, 30), (58, 42), (52, 60), [[(74, 40)], [(38, 48)]], [[(68, 74), (78, 84)], [(34, 74), (24, 84)]], mira=1) + frecha((94, 48), (138, 48), ROJO, 4),
        "Niño corriendo deprisa hacia delante.")
    put("salty air", "C", fondo_mar() + fl("Nose", 26, 26, 46) + [L("M74 42 Q104 34 134 42", AZUL_OSCURO, 3), L("M78 54 Q108 46 138 54", AGUA_OSCURO, 3)],
        "Brisa marina llegando hacia la nariz para respirar aire salado.")
    put("scarves", "D", fondo_sala() + [
        L("M24 64 Q48 24 74 44 Q98 62 122 24", ROJO, 7),
        L("M34 74 Q64 38 90 56 Q116 70 138 34", AZUL, 7),
        L("M44 46 Q74 16 100 34 Q122 50 142 18", AMARILLO, 7),
    ], "Pañuelos ligeros de colores ondulando al aire.")
    put("seahorse", "D", fondo_mar() + [
        F("M74 18 C94 16 96 38 82 48 C70 56 88 74 72 80 C62 82 64 70 72 68", "#fb923c", "#c2410c", 3),
        E(74, 28, 9, 8, "#fb923c", "#c2410c", 2),
        L("M62 28 L66 28", "#c2410c", 3),
        E(76, 26, 1.5, 1.5, TINTA),
    ], "Caballito de mar naranja de perfil en el agua.")
    put("seaside", "C", [
        R(0, 0, 160, 100, 0, "#e0f2fe"),
        R(0, 56, 160, 44, 0, "#fde68a"),
        P([(0, 46), (96, 46), (72, 76), (0, 82)], AGUA, AGUA_OSCURO, 2),
    ] + fl("Spiral shell", 98, 56, 26) + fl("Sun", 18, 10, 26),
        "Orilla del mar donde se unen el agua y la arena con concha.")
    put("seaweed", "D", fondo_mar() + [
        L("M48 92 Q36 70 52 48 Q64 32 48 16", VERDE_OSCURO, 5),
        L("M80 92 Q92 68 76 46 Q66 28 84 12", VERDE, 5),
        L("M110 92 Q98 70 112 50 Q124 34 108 18", VERDE_OSCURO, 5),
    ], "Algas verdes ondulando bajo el agua del mar.")
    put("seesaw", "D", fondo_prado() + [
        P([(70, 76), (80, 56), (90, 76)], TIERRA_CLARA, BARRO, 2),
        L("M24 68 L136 42", ROJO_OSCURO, 5),
        R(28, 48, 16, 16, 4, AMARILLO, AMARILLO_OSCURO, 2),
        R(116, 24, 16, 16, 4, AZUL, AZUL_OSCURO, 2),
    ], "Balancín inclinado subiendo de un lado y bajando del otro.")
    put("semilla pequeña", "C", fondo_prado() + [
        R(56, 62, 48, 20, 4, TIERRA, BARRO, 2),
        L("M80 62 L80 34", VERDE_OSCURO, 3.5),
        E(70, 40, 8, 5, VERDE, VERDE_OSCURO, 1.5),
        E(90, 36, 8, 5, VERDE, VERDE_OSCURO, 1.5),
    ] + notas([(28, 30), (126, 26), (138, 38)]), "Canción de la semilla pequeña con su brote verde.", "cancion_semilla")
    put("sensory bag", "D", fondo_mesa() + [
        R(44, 18, 72, 62, 10, "#bae6fd", AZUL_OSCURO, 2.5),
        E(64, 42, 7, 7, ROJO, ROJO_OSCURO, 1.5),
        E(92, 36, 6, 6, AMARILLO, AMARILLO_OSCURO, 1.5),
        E(78, 60, 8, 6, VERDE, VERDE_OSCURO, 1.5),
        E(98, 58, 4, 4, BLANCO),
    ], "Bolsa sensorial transparente con piezas brillantes dentro.")
    put("shake, shake, shake!", "C", fondo_sala() + fl("Maracas", 48, 22, 60) + [L("M34 30 L24 44", MORADO, 3), L("M126 30 L136 44", MORADO, 3)],
        "Maraca sonando con líneas de agitación.")
    put("shaker", "D", fondo_sala() + [
        E(80, 48, 22, 28, AMARILLO, AMARILLO_OSCURO, 2.5),
        E(72, 42, 3, 3, ROJO),
        E(88, 42, 3, 3, AZUL),
        E(80, 56, 3, 3, VERDE),
    ], "Huevo sonajero amarillo para agitar con la mano.")
    put("silly hat", "C", fondo_sala() + fl("Top hat", 50, 22, 58) + fl("Blossom", 84, 34, 28) + fl("Party popper", 18, 24, 34),
        "Sombrero de copa divertido decorado con flor.")
    put("slippers", "D", fondo_sala() + [
        E(52, 54, 16, 22, "#fca5a5", ROJO_OSCURO, 2.5),
        E(52, 46, 10, 12, "#fee2e2", ROJO_OSCURO, 1.8),
        E(108, 54, 16, 22, "#fca5a5", ROJO_OSCURO, 2.5),
        E(108, 46, 10, 12, "#fee2e2", ROJO_OSCURO, 1.8),
    ], "Par de zapatillas suaves de casa.")
    put("small!", "C", fondo_prado() + nino((80, 54), (80, 62), (80, 74), [[(68, 66)], [(92, 66)]], [[(74, 84)], [(86, 84)]], r=7) + frecha((120, 22), (96, 46), AZUL_OSCURO, 3) + frecha((40, 22), (64, 46), AZUL_OSCURO, 3),
        "Niño encogido en el suelo haciéndose pequeñito.")
    put("smoke", "C", fondo_prado() + fl("Wood", 46, 56, 44) + [
        L("M62 56 Q50 42 66 28 Q78 16 64 6", GRIS_OSCURO, 4.5),
        L("M80 54 Q94 40 78 24 Q68 14 82 6", GRIS, 4.5),
    ] + frecha((116, 62), (116, 18), GRIS_OSCURO, 3),
        "Humo gris subiendo desde la madera hacia arriba.")
    put("snowsuit", "C", fondo_cielo("#e0f2fe") + fl("Coat", 34, 16, 48) + fl("Jeans", 78, 24, 46) + copos_nieve([(24, 24), (134, 26)]),
        "Buzo completo abrigado para el frío y la nieve.")
    put("soap and water", "C", fondo_mesa() + fl("Soap", 26, 30, 48) + fl("Droplet", 88, 28, 46),
        "Pastilla de jabón y gota de agua juntas.")
    put("soft!", "C", fondo_sala() + fl("Feather", 46, 18, 64),
        "Pluma ligera y suave.")
    put("splish, splash!", "C", fondo_mar() + fl("Water wave", 22, 34, 48) + fl("Sweat droplets", 86, 20, 44) + gotas([(66, 24), (118, 50)]),
        "Salpicaduras alegres golpeando el agua.")
    put("stacking cups", "D", fondo_mesa() + [
        R(44, 58, 72, 16, 3, ROJO, ROJO_OSCURO, 2.2),
        R(54, 42, 52, 16, 3, AMARILLO, AMARILLO_OSCURO, 2.2),
        R(64, 26, 32, 16, 3, AZUL, AZUL_OSCURO, 2.2),
        R(72, 12, 16, 14, 3, VERDE, VERDE_OSCURO, 2.2),
    ], "Torre de vasos apilables de colores del grande al pequeño.")
    put("stop!", "C", fondo_prado() + fl("Stop sign", 26, 18, 52) + nino((106, 30), (106, 42), (106, 62), [[(90, 30)], [(122, 30)]], [[(100, 86)], [(112, 86)]]),
        "Señal de stop y niño quieto con las manos en alto.")
    put("stroke gently", "C", fondo_sala() + fl("Cat", 26, 24, 54) + fl("Open hands", 86, 26, 46) + frecha((94, 20), (62, 20), MORADO, 3),
        "Mano abierta acariciando suavemente al gatito en una dirección.")
    put("suena el cascabel", "C", fondo_sala() + fl("Bell", 46, 20, 56) + notas([(24, 30), (124, 24), (136, 36)]),
        "Canción del cascabel sonando con notas musicales.", "cancion_cascabel")
    put("sunny yellow", "C", fondo_cielo("#fef9c3") + fl("Sun", 46, 18, 66),
        "Sol amarillo grande brillando en cielo dorado.")
    put("swim, little fish", "C", fondo_mar() + fl("Tropical fish", 36, 34, 48) + frecha((92, 54), (138, 54), AZUL_OSCURO, 3.5),
        "Pececito nadando ágil por el agua.")
    put("take it off!", "C", fondo_sala() + fl("Womans hat", 48, 18, 54) + frecha((116, 56), (116, 18), ROJO, 3.5),
        "Gorro levantándose con flecha hacia arriba: quitárselo.")
    put("the cat says meow", "C", fondo_sala() + fl("Cat", 32, 24, 56) + notas([(100, 34), (118, 24)]),
        "Gato maullando alegremente.")
    put("the sun comes up!", "C", fondo_prado() + fl("Sunrise", 42, 16, 72) + frecha((128, 62), (128, 22), AMARILLO_OSCURO, 3.5),
        "Sol saliendo por el horizonte hacia arriba.")
    put("tide", "C", fondo_mar() + fl("Water wave", 34, 34, 56) + frecha((96, 42), (136, 42), AZUL_OSCURO, 3) + frecha((136, 72), (96, 72), MAR_PROF, 3),
        "Olas de la marea que vienen y van entre flechas.")
    put("tiny toes", "D", fondo_sala() + [
        E(74, 58, 16, 22, PEL, PELB, 2.2),
        E(56, 34, 5, 6, PEL, PELB, 1.8),
        E(67, 29, 4.5, 5.5, PEL, PELB, 1.8),
        E(78, 29, 4, 5, PEL, PELB, 1.8),
        E(87, 32, 3.8, 4.5, PEL, PELB, 1.8),
        E(95, 37, 3.4, 4, PEL, PELB, 1.8),
    ] + frecha((124, 24), (96, 32), ROJO_OSCURO, 3), "Pie descalzo con cinco deditos pequeños señalados arriba.")
    put("toenails", "D", fondo_sala() + [
        E(74, 58, 16, 22, PEL, PELB, 2.2),
        E(56, 34, 5, 6, PEL, PELB, 1.8), E(56, 31, 3, 2, "#fecdd3", ROJO_OSCURO, 1),
        E(67, 29, 4.5, 5.5, PEL, PELB, 1.8), E(67, 26, 2.8, 1.8, "#fecdd3", ROJO_OSCURO, 1),
        E(78, 29, 4, 5, PEL, PELB, 1.8), E(78, 26, 2.5, 1.6, "#fecdd3", ROJO_OSCURO, 1),
        E(87, 32, 3.8, 4.5, PEL, PELB, 1.8), E(87, 29.5, 2.3, 1.5, "#fecdd3", ROJO_OSCURO, 1),
        E(95, 37, 3.4, 4, PEL, PELB, 1.8), E(95, 34.5, 2, 1.4, "#fecdd3", ROJO_OSCURO, 1),
    ], "Dedos del pie mostrando claramente las uñas pequeñas.")
    put("toy tambourine", "D", fondo_sala() + [
        E(80, 48, 26, 26, "#fde68a", MADERA_OSCURA, 5),
        E(56, 36, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.5),
        E(104, 36, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.5),
        E(56, 60, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.5),
        E(104, 60, 4, 4, AMARILLO, AMARILLO_OSCURO, 1.5),
    ] + notas([(116, 26), (130, 18)]), "Pandereta de juguete con sonajas doradas y música.")
    put("tree bark", "C", fondo_prado() + fl("Wood", 34, 24, 56) + fl("Deciduous tree", 90, 16, 56),
        "Tronco de árbol y corteza de madera.")
    put("tweet", "C", fondo_prado() + fl("Baby chick", 46, 24, 54) + notas([(108, 28), (124, 20)]),
        "Pollito piando con notas musicales.")
    put("tweet, tweet!", "C", fondo_prado() + fl("Bird", 42, 22, 56) + notas([(104, 28), (122, 20), (134, 32)]),
        "Pajarito cantando pío pío.")
    put("twig", "D", fondo_prado() + [
        L("M34 74 L118 28", MADERA_OSCURA, 4.5),
        L("M68 55 L52 32", MADERA_OSCURA, 3),
        L("M90 43 L112 52", MADERA_OSCURA, 3),
    ] + fl("Leaf fluttering in wind", 104, 16, 28), "Ramita fina de árbol con brotes laterales.")
    put("up", "C", fondo_prado() + nino((66, 36), (66, 48), (66, 68), [[(48, 20)], [(84, 20)]], [[(60, 86)], [(72, 86)]]) + frecha((116, 78), (116, 20), VERDE_OSCURO, 4.5),
        "Niño levantando los brazos hacia arriba con flecha ascendente.")
    put("warm... soft and warm", "C", fondo_sala() + fl("Teacup without handle", 24, 28, 48) + pano(84, 26, 48, 44, "#fde68a", "#d97706"),
        "Toalla suave y bebida templada: calentito y suave.")
    put("wash!", "C", fondo_sala() + fl("Soap", 28, 24, 46) + fl("Open hands", 80, 26, 50) + pompas([(56, 18, 5), (108, 18, 6)]),
        "Manos lavándose con jabón y pompas.")
    put("wash, wash, clean hands!", "C", fondo_sala() + fl("Open hands", 46, 28, 54) + fl("Sparkles", 98, 12, 32) + pompas([(30, 32, 5), (124, 52, 5)]),
        "Manos limpias y relucientes tras lavarse con espuma.")
    put("washcloth", "C", fondo_sala() + pano(44, 24, 52, 46, "#bae6fd", AGUA_OSCURO) + pompas([(106, 26, 6), (118, 42, 5)]),
        "Manopla de baño azul con espuma.")
    put("water tray", "D", fondo_mesa() + [
        R(28, 36, 104, 40, 8, AZUL, AZUL_OSCURO, 2.5),
        R(34, 42, 92, 28, 6, AGUA, AGUA_OSCURO, 1.8),
    ] + fl("Duck", 66, 30, 30), "Bandeja grande llena de agua con patito flotando.")
    put("waves go up, waves go down, blue sea", "C", fondo_mar() + fl("Water wave", 36, 28, 54) + frecha((104, 56), (104, 22), AZUL_OSCURO, 3.5) + frecha((126, 22), (126, 56), MAR_PROF, 3.5),
        "Olas del mar azul subiendo y bajando entre flechas.")
    put("wet", "C", fondo_cielo("#e0f2fe") + gotas([(56, 24), (80, 16), (104, 26), (68, 54), (96, 52)]),
        "Gotas grandes de agua cubriendo la escena: mojado.")
    put("wrapping paper", "C", fondo_sala() + fl("Wrapped gift", 46, 16, 66),
        "Paquete envuelto con papel de colores y lazo.")
    put("wrist", "C", fondo_sala() + fl("Raised hand", 46, 12, 56) + [R(65, 62, 30, 8, 3, ROJO, ROJO_OSCURO, 2)] + frecha((122, 66), (98, 66), ROJO_OSCURO, 3),
        "Mano señalando la muñeca rodeada por pulsera.")
    put("xylophone", "D", fondo_sala() + [
        L("M30 46 L130 34", MADERA_OSCURA, 4),
        L("M30 62 L130 70", MADERA_OSCURA, 4),
        R(32, 36, 14, 34, 3, ROJO, ROJO_OSCURO, 2),
        R(50, 37, 14, 32, 3, "#fb923c", "#c2410c", 2),
        R(68, 38, 14, 30, 3, AMARILLO, AMARILLO_OSCURO, 2),
        R(86, 39, 14, 28, 3, VERDE, VERDE_OSCURO, 2),
        R(104, 40, 14, 26, 3, AZUL, AZUL_OSCURO, 2),
        L("M44 16 L60 36", MADERA_OSCURA, 2.5),
        E(60, 36, 4, 4, MAR_PROF),
    ], "Xilófono infantil de láminas de colores con baqueta.")

    # ── Frases de gramática de curso_0_2 ───────────────────────────────────
    put("a big stone", "C", fondo_prado() + fl("Rock", 40, 14, 78),
        "Una piedra muy grande ocupando el prado.")
    put("at bath time, the box stops", "C", fondo_sala() + fl("Bathtub", 20, 24, 52) + fl("Package", 80, 36, 40) + fl("Stop sign", 112, 14, 30),
        "Bañera y caja detenida junto a la señal de parar.")
    put("at night, the ball sleeps in the box", "C", fondo_noite() + fl("Crescent moon", 16, 10, 28) + fl("Package", 52, 34, 52) + fl("Soccer ball", 66, 22, 26) + fl("Sleeping face", 114, 16, 26),
        "De noche bajo la luna, la pelota duerme guardada en la caja.")
    put("i am wet!", "C", fondo_cielo("#e0f2fe") + nino((72, 34), (72, 46), (72, 66), [[(56, 54)], [(88, 54)]], [[(66, 86)], [(78, 86)]]) + gotas([(42, 22), (108, 22), (44, 62), (110, 62)]),
        "Niño empapado con gotas cayendo alrededor: ¡estoy mojado!")
    put("i like bread", "C", fondo_mesa() + fl("Bread", 36, 24, 54) + fl("Red heart", 96, 24, 42),
        "Pan tierno junto a un corazón rojo: me gusta el pan.")
    put("in the morning, the ball rolls", "C", fondo_prado() + fl("Sunrise", 16, 10, 36) + fl("Soccer ball", 54, 44, 40) + frecha((100, 64), (138, 64), AZUL_OSCURO, 3.5),
        "Por la mañana al salir el sol, la pelota rueda.")
    put("is it cold", "C", fondo_cielo("#e0f2fe") + fl("Ice", 36, 26, 52) + copos_nieve([(104, 28), (124, 50), (96, 62)]),
        "Cubito de hielo rodeado de copos fríos.")
    put("is it dry", "C", fondo_mesa() + pano(38, 26, 58, 44, "#fde68a", "#d97706") + fl("Sun", 104, 14, 34),
        "Toalla seca bajo el sol brillante.")
    put("on monday we push the ball", "C", fondo_prado() + nino((46, 32), (48, 44), (48, 64), [[(74, 48)], [(68, 54)]], [[(42, 86)], [(54, 86)]], mira=1) + fl("Soccer ball", 80, 44, 38) + frecha((122, 62), (144, 62), VERDE_OSCURO, 3),
        "Niño empujando la pelota hacia delante.")
    put("that shadow", "C", fondo_prado() + [E(94, 78, 28, 7, "#475569")] + nino((64, 28), (64, 40), (64, 60), [[(50, 50)], [(78, 50)]], [[(58, 82)], [(70, 82)]]) + fl("Sun", 16, 10, 28),
        "Niño proyectando esa sombra alargada en el suelo.")
    put("the apple goes in the basket", "C", fondo_mesa() + fl("Basket", 54, 42, 54) + fl("Red apple", 62, 10, 36) + frecha((116, 16), (116, 48), VERDE_OSCURO, 3.5),
        "Manzana entrando hacia abajo dentro de la cesta.")
    put("the apple is always cold", "C", fondo_mesa() + fl("Red apple", 38, 24, 54) + copos_nieve([(102, 26), (122, 46), (104, 66)]),
        "Manzana fresca rodeada de copos de frío.")
    put("the bottle is loud", "C", fondo_mesa() + fl("Baby bottle", 36, 20, 56) + [L("M98 30 L124 20", ROJO, 3.5), L("M100 44 L132 44", ROJO, 3.5), L("M98 58 L124 68", ROJO, 3.5)],
        "Botella haciendo mucho ruido con ondas sonoras intensas.")
    put("the bread is usually warm", "C", fondo_mesa() + fl("Bread", 46, 28, 58) + [L("M58 24 Q64 14 58 6", TIERRA_CLARA, 2.5), L("M76 24 Q82 14 76 6", TIERRA_CLARA, 2.5), L("M94 24 Q100 14 94 6", TIERRA_CLARA, 2.5)],
        "Pan templado desprendiendo vapor cálido.")
    put("the leaf falls", "C", fondo_prado() + fl("Fallen leaf", 54, 18, 46) + frecha((114, 20), (114, 72), TIERRA, 3.5),
        "Hoja cayendo hacia el suelo.")
    put("the soap is on your hands", "C", fondo_sala() + fl("Open hands", 44, 34, 64) + fl("Soap", 56, 12, 40),
        "Pastilla de jabón encima de las manos abiertas.")
    put("the sponge is wet", "C", fondo_mesa() + fl("Sponge", 42, 26, 58) + gotas([(56, 68), (82, 72), (104, 64)]),
        "Esponja empapada soltando gotas de agua.")
    put("the towel is next to you", "C", fondo_sala() + nino((52, 34), (52, 46), (52, 66), [[(40, 56)], [(64, 56)]], [[(46, 86)], [(58, 86)]]) + pano(88, 32, 40, 44, "#bae6fd", AGUA_OSCURO),
        "Niño de pie con la toalla justo al lado.")
    put("two big stones", "C", fondo_prado() + fl("Rock", 22, 28, 56) + fl("Rock", 84, 28, 56),
        "Dos piedras grandes una al lado de la otra.")
    put("we eat an apple", "C", fondo_mesa() + nino((48, 34), (48, 46), (48, 66), [[(68, 42)], [(36, 56)]], [[(42, 86)], [(54, 86)]]) + fl("Red apple", 86, 30, 46),
        "Niño acercándose a comer una manzana roja.")
    put("we never eat cold bread", "C", fondo_mesa() + fl("Bread", 32, 28, 50) + copos_nieve([(92, 32), (110, 46)]) + [L("M118 18 L142 42", ROJO, 4), L("M142 18 L118 42", ROJO, 4)],
        "Pan helado tachado con aspa roja: nunca frío.")
    put("we often touch them", "C", fondo_mesa() + fl("Open hands", 30, 26, 48) + fl("Rock", 86, 28, 48),
        "Manos tocando objetos sobre la mesa.")
    put("where is the light", "C", fondo_noite() + fl("Flashlight", 28, 28, 48) + [P([(72, 46), (144, 18), (144, 78)], "#fef08a")] + fl("Light bulb", 104, 30, 34),
        "Linterna proyectando luz hacia una bombilla.")
    put("where is the shadow", "C", fondo_prado() + fl("Sun", 16, 10, 28) + [E(94, 78, 30, 8, "#334155")] + nino((68, 28), (68, 40), (68, 60), [[(54, 52)], [(82, 52)]], [[(62, 82)], [(74, 82)]]),
        "Sol iluminando y sombra oscura en el suelo.")
    put("who runs", "C", fondo_prado() + nino((58, 30), (56, 42), (50, 60), [[(72, 42)], [(36, 48)]], [[(66, 74), (76, 84)], [(32, 74), (22, 84)]], mira=1) + frecha((92, 48), (138, 48), VERDE_OSCURO, 3.5),
        "Niño corriendo rápido con flecha.")
    put("you are happy!", "C", fondo_prado() + fl("Grinning face with big eyes", 46, 16, 66),
        "Cara muy sonriente y contenta.")
    put("you put the bread in the box", "C", fondo_mesa() + fl("Package", 48, 42, 56) + fl("Bread", 56, 10, 40) + frecha((114, 18), (114, 48), VERDE_OSCURO, 3.5),
        "Pan entrando dentro de la caja.")
    put("your shadow is big!", "C", fondo_prado() + [E(98, 76, 38, 10, "#334155")] + nino((56, 32), (56, 44), (56, 64), [[(42, 52)], [(70, 52)]], [[(50, 82)], [(62, 82)]]),
        "Sombra muy grande y alargada al lado del niño.")

    # ── Canciones (ACOPROS 0-2) ────────────────────────────────────────────
    put("¡buenos días, hola!", "C", fondo_prado() + fl("Sun", 18, 10, 34) + fl("Waving hand", 68, 22, 54) + notas([(124, 24), (138, 34)]),
        "Sol naciente, mano saludando y notas: buenos días, hola.", "cancion_buenos_dias")
    put("busca el color", "C", fondo_sala() + [E(34, 46, 16, 16, ROJO, ROJO_OSCURO, 2), E(72, 46, 16, 16, AMARILLO, AMARILLO_OSCURO, 2), E(110, 46, 16, 16, AZUL, AZUL_OSCURO, 2)] + fl("Magnifying glass tilted right", 88, 34, 44),
        "Lupa buscando entre círculos rojo, amarillo y azul.", "cancion_busca_color")
    put("cabeza, hombros, rodillas y pies", "C", fondo_prado() + nino((72, 22), (72, 34), (72, 56), [[(56, 46)], [(88, 46)]], [[(66, 84)], [(78, 84)]]) + notas([(24, 26), (124, 26), (138, 36)]),
        "Niño señalando cuerpo de cabeza a pies con notas musicales.", "cancion_cabeza_hombros")
    put("hojas que caen", "C", fondo_prado() + fl("Fallen leaf", 28, 18, 34) + fl("Maple leaf", 68, 32, 36) + fl("Fallen leaf", 104, 48, 34) + notas([(124, 20), (140, 28)]),
        "Hojas otoñales cayendo al son de notas musicales.", "cancion_hojas_caen")
    put("lava, lava las manos", "C", fondo_sala() + fl("Open hands", 40, 26, 52) + fl("Soap", 92, 24, 38) + pompas([(30, 24, 5), (132, 44, 6)]) + notas([(22, 54), (134, 20)]),
        "Manos lavándose con jabón y pompas con notas musicales.", "cancion_lava_manos")
    put("me pongo el gorro, me pongo las botas", "C", fondo_prado() + fl("Womans hat", 20, 20, 44) + fl("Hiking boot", 66, 26, 44) + notas([(118, 24), (134, 34)]),
        "Gorro, botas de agua y notas musicales.", "cancion_gorro_botas")
    put("salta la rana, vuela el pájaro", "C", fondo_prado() + fl("Frog", 24, 38, 44) + fl("Bird", 82, 16, 44) + notas([(126, 24), (140, 34)]),
        "Rana saltando abajo y pájaro volando arriba con música.", "cancion_rana_pajaro")

    # ── Rimas tradicionales (ACOPROS 0-2) ──────────────────────────────────
    put("pat-a-cake, pat-a-cake, baker's man! bake me a cake as fast as you can", "C",
        fondo_mesa() + fl("Clapping hands", 22, 24, 48) + fl("Shortcake", 82, 20, 52) + notas([(136, 24)]),
        "Palmitas y pastel horneado de la rima tradicional.", "rima_pat_a_cake")
    put("head, shoulders, knees and toes, knees and toes", "C",
        fondo_prado() + nino((76, 22), (76, 34), (76, 56), [[(60, 46)], [(92, 46)]], [[(70, 84)], [(82, 84)]]) + notas([(26, 24), (126, 26)]),
        "Niño tocando cabeza, hombros, rodillas y pies al cantar.", "rima_head_shoulders")
    put("round and round the garden, like a teddy bear", "C",
        fondo_prado() + fl("Teddy bear", 48, 20, 56) + fl("Blossom", 20, 46, 28) + [L("M34 28 C58 10 104 10 124 28", MORADO, 2.5)] + notas([(124, 22)]),
        "Osito de peluche en el jardín con arco circular.", "rima_round_garden")
    put("twinkle, twinkle, little star, how i wonder what you are", "C",
        fondo_noite() + fl("Glowing star", 48, 18, 56) + fl("Crescent moon", 18, 14, 30) + notas([(120, 24), (136, 34)]),
        "Estrella brillante en el cielo nocturno junto a la luna.", "rima_twinkle_star")
    put("this is the way we put on our hat, put on our hat, put on our hat", "C",
        fondo_sala() + fl("Womans hat", 32, 16, 48) + nino((102, 38), (102, 50), (102, 68), [[(86, 32)], [(118, 32)]], [[(96, 86)], [(108, 86)]]) + notas([(22, 24)]),
        "Niño colocándose el gorro cantando.", "rima_put_on_hat")
    put("old macdonald had a farm, e-i-e-i-o", "C",
        fondo_prado() + fl("Cow", 20, 28, 48) + fl("Pig", 72, 30, 44) + fl("Baby chick", 116, 36, 34),
        "Animales de la granja juntos en el prado.", "rima_old_macdonald")
    put("ring-a-ring o' roses, a pocket full of posies", "C",
        fondo_prado() + fl("Rose", 26, 26, 42) + fl("Blossom", 66, 22, 40) + fl("Tulip", 104, 24, 42),
        "Corro alegre de rosas y flores.", "rima_ring_roses")
    put("rain, rain, go away, come again another day", "C",
        fondo_prado() + fl("Cloud with rain", 24, 10, 50) + fl("Sun", 96, 12, 42) + gotas([(42, 66), (56, 72)]),
        "Nube con lluvia marchándose mientras asoma el sol.", "rima_rain_away")
    put("this is the way we wash our hands, wash our hands, wash our hands", "C",
        fondo_sala() + fl("Open hands", 40, 24, 52) + fl("Soap", 92, 24, 40) + pompas([(28, 22, 5), (134, 46, 5)]),
        "Manos lavándose con agua y jabón.", "rima_wash_hands")
    put("row, row, row your boat, gently down the stream", "C",
        fondo_mar() + fl("Person rowing boat", 46, 20, 68) + notas([(24, 22), (128, 22)]),
        "Remando suave en la barca río abajo con música.", "rima_row_boat")

    return m


def _recoger_claves_0_2() -> dict[str, str]:
    lec = json.loads(LECCIONS_PATH.read_text(encoding="utf-8"))
    ac = json.loads(ACOPROS_PATH.read_text(encoding="utf-8"))
    out: dict[str, str] = {}
    for u in lec["cursos"]["curso_0_2"]["unidades"]:
        for l in u["leccions"]:
            for b in ("xaSabe", "novas", "repasa"):
                for p in l.get(b) or []:
                    k = p["en"].lower().strip(" .!?")
                    out.setdefault(k, p["en"])
            f = l.get("fraseGramatica")
            if f:
                k = f["en"].lower().strip(" .!?")
                out.setdefault(k, f["en"])
    for p in ac["proxectos"]:
        for w in p["palabras"]:
            k = w["en"].lower().strip(" .!?")
            out.setdefault(k, w["en"])
        ck = p["cancion"]["es"].lower().strip(" .!?")
        out.setdefault(ck, p["cancion"]["es"])
        rk = p["rima"]["en"].lower().strip(" .!?")
        out.setdefault(rk, p["rima"]["en"])
    return out


def main() -> int:
    mapa = json.loads(MAPA_PATH.read_text(encoding="utf-8"))
    pezas = mapa["pezas"]
    claves = _recoger_claves_0_2()
    escenas = {k.strip(" .!?"): v for k, v in _escenas_0_2().items()}
    fd = {k.strip(" .!?"): v for k, v in FLUENT_DIRECTOS.items()}
    pr = {k.strip(" .!?"): v for k, v in PROPIAS_REUTILIZADAS.items()}

    counts = {"U": 0, "R": 0, "C": 0, "D": 0}
    faltan: list[str] = []

    for k, en in sorted(claves.items()):
        if k in fd:
            slug, fl_name, ur, porque = fd[k]
            escribir_fluent_directo(pezas, k, slug, fl_name, ur, porque)
            counts[ur] += 1
        elif k in pr:
            clave, porque = pr[k]
            escribir_reutilizada(pezas, k, clave, porque)
            counts["R"] += 1
        elif k in escenas:
            slug, cd, formas, porque = escenas[k]
            escribir_cd(pezas, k, slug, cd, formas, porque, SCRIPT_REF, etiqueta_en=en)
            counts[cd] += 1
        else:
            faltan.append(k)

    if faltan:
        raise RuntimeError(f"Faltan {len(faltan)} claves en 0-2: {faltan[:20]}")

    mapa["pezas"] = dict(sorted(pezas.items()))
    MAPA_PATH.write_text(json.dumps(mapa, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    print("OK gen_laminas_0_2:", counts, "total:", sum(counts.values()))
    return 0


if __name__ == "__main__":
    sys.exit(main())
