#!/usr/bin/env python3
"""P11.6 (D4 + ACOPROS): 0-2 anos cun núcleo de 60 pezas en cinco familias.

Substitúe as 199 palabras de assets/content/acopros/proxectos_0_2.json por
60 pezas nucleares en cinco familias:
  - sustantivos (24): corpo, comida, familia/mundo próximo, animais/natureza
  - adxectivos (10): pares de contraste (big/small, hot/cold, wet/dry, soft/hard, loud/quiet)
  - onomatopeias (8): sempre unidas ao seu obxecto («Baa, lamb!», «Woof, dog!», …)
  - rutinas (10): rutinas e sucesos («Bath time», «All done», «Bye-bye», «Night night», …)
  - series (8): series básicas («One, two, three», «Big, small, big», «Up, down, up», …)

Cada peza:
  - 1 a 3 elementos como moito, sen verbo «to be».
  - 2 a 3 pezas novas por semana activa (6 por mes; 54 de 60 volven en meses posteriores).
  - Nomea o STEAM do mes e a parte do experimento que traballa (`parteSteam`).
  - Cada semana ten as súas 3 capas (`nucleo`, `mais`, `apoio`) co STEAM do mes e as
    6 liñas das rutinas do fogar M2 (`bano`, `comida`, `coche`, `vestirse`, `durmir`, `parque`)
    sen repetir entre semanas.

Frecuencia baseada en fala dirixida a crianzas temperás: MacArthur-Bates CDI /
Wordbank (Frank et al., Stanford University, datos normativos baixo licenza
CC BY 4.0, sen restrición NC nin ND).

Uso: python3 tools/gen_acopros_0_2.py [--check]
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
SAIDA = RAIZ / "assets/content/acopros/proxectos_0_2.json"
MAPA = RAIZ / "assets/content/laminas/palabras_laminas.json"
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]
TO_BE = re.compile(r"\b(is|are|am|was|were|be|it's|i'm|you're|we're|they're)\b", re.I)

FAMILIAS = ("sustantivos", "adxectivos", "onomatopeias", "rutinas", "series")
RUTINAS_FOGAR = (
    ("bano", "No baño", "En el baño"),
    ("comida", "Na comida", "En la comida"),
    ("coche", "No coche", "En el coche"),
    ("vestirse", "Ao vestirse", "Al vestirse"),
    ("durmir", "Antes de durmir", "Antes de dormir"),
    ("parque", "No parque", "En el parque"),
)

# Núcleo de 60 pezas (6 novas por mes en semanas 1-3: 2 + 2 + 2).
# (mes, familia, en, gl, es, xesto_gl, xesto_es, parte_gl, parte_es)
NUCLEO_60 = [
    # Mes 9 · Mollado e seco / Mojado y seco
    (9, "sustantivos", "Water", "Auga", "Agua", "Toca a auga da tina coa palma aberta.", "Toca el agua del barreño con la palma abierta.", "a auga do experimento «Mollado e seco»", "el agua del experimento «Mojado y seco»"),
    (9, "sustantivos", "Bath", "Baño", "Baño", "Fai ondas suaves coa man dentro da tina.", "Haz ondas suaves con la mano dentro del barreño.", "o baño onde probas «Mollado e seco»", "el baño donde pruebas «Mojado y seco»"),
    (9, "adxectivos", "Wet", "Mollado", "Mojado", "Aperta a esponxa enchoupada para ver caer as gotas.", "Aprieta la esponja empapada para ver caer las gotas.", "a esponxa enchoupada en «Mollado e seco»", "la esponja empapada en «Mojado y seco»"),
    (9, "adxectivos", "Dry", "Seco", "Seco", "Pasa a man pola toalla seca antes de mollar.", "Pasa la mano por la toalla seca antes de mojar.", "a toalla enxuta en «Mollado e seco»", "la toalla seca en «Mojado y seco»"),
    (9, "onomatopeias", "Splash, water!", "Chaf, auga!", "¡Chof, agua!", "Deixa caer dúas pingas na auga mentres ris.", "Deja caer dos gotas en el agua mientras ríes.", "o salpico ao tocar a cubeta de «Mollado e seco»", "el salpicón al tocar el barreño de «Mojado y seco»"),
    (9, "series", "Wet, dry, wet", "Mollado, seco, mollado", "Mojado, seco, mojado", "Alterna tocar esponxa mollada, toalla seca e esponxa.", "Alterna tocar esponja mojada, toalla seca y esponja.", "a secuencia de contrastes de «Mollado e seco»", "la secuencia de contrastes de «Mojado y seco»"),

    # Mes 10 · A música da auga / La música del agua
    (10, "sustantivos", "Spoon", "Culler", "Cuchara", "Suxeita a culler de madeira diante dos ollos.", "Sujeta la cuchara de madera delante de los ojos.", "a baqueta para soar vasos en «A música da auga»", "la baqueta para sonar vasos en «La música del agua»"),
    (10, "sustantivos", "Hand", "Man", "Mano", "Ensina a palma aberta antes de petar.", "Enseña la palma abierta antes de golpear.", "a man que abanea a botella en «A música da auga»", "la mano que agita la botella en «La música del agua»"),
    (10, "adxectivos", "Loud", "Forte", "Fuerte", "Abre os brazos cando a botella chea soa forte.", "Abre los brazos cuando la botella llena suena fuerte.", "o son forte ao abanear en «A música da auga»", "el sonido fuerte al agitar en «La música del agua»"),
    (10, "adxectivos", "Quiet", "Quedo", "Suave", "Pon o dedo nos beizos cando o vaso case non soa.", "Pon el dedo en los labios cuando el vaso suena suave.", "a calma entre gotas de «A música da auga»", "la calma entre gotas de «La música del agua»"),
    (10, "onomatopeias", "Tap, spoon!", "Tin, culler!", "¡Tin, cuchara!", "Dá un toque suave no bordo do vaso coa culler.", "Da un toque suave en el borde del vaso con la cuchara.", "o toque acústico do cristal en «A música da auga»", "el toque acústico del cristal en «La música del agua»"),
    (10, "rutinas", "Bath time", "Hora do baño", "Hora del baño", "Sinala a bañeira antes de xogar cos vasos.", "Señala la bañera antes de jugar con los vasos.", "o momento cotián onde escoitar «A música da auga»", "el momento cotidiano donde escuchar «La música del agua»"),

    # Mes 11 · A folla baila, a pedra cae / La hoja baila, la piedra cae
    (11, "sustantivos", "Leaf", "Folla", "Hoja", "Sostén a folla seca pola punta e déixaa planear.", "Sostén la hoja seca por la punta y déjala planear.", "a folla lixeira que planea en «A folla baila, a pedra cae»", "la hoja ligera que planea en «La hoja baila, la piedra cae»"),
    (11, "sustantivos", "Stone", "Pedra", "Piedra", "Pon a pedra pesada na palma e deixa que caia recto.", "Pon la piedra pesada en la palma y deja que caiga recto.", "a pedra pesada de «A folla baila, a pedra cae»", "la piedra pesada de «La hoja baila, la piedra cae»"),
    (11, "adxectivos", "Big", "Grande", "Grande", "Sinala a pedra máis grande coas dúas mans.", "Señala la piedra más grande con las dos manos.", "o tamaño que cae rápido en «A folla baila, a pedra cae»", "el tamaño que cae rápido en «La hoja baila, la piedra cae»"),
    (11, "adxectivos", "Small", "Pequeno", "Pequeño", "Fai unha pinza cos dedos para coller a folla pequena.", "Haz pinza con los dedos para coger la hoja pequeña.", "a folliña que baila no aire en «A folla baila, a pedra cae»", "la hojita que baila en el aire en «La hoja baila, la piedra cae»"),
    (11, "series", "Big, small, big", "Grande, pequeno, grande", "Grande, pequeño, grande", "Alinea pedra grande, folla pequena e pedra grande.", "Alinea piedra grande, hoja pequeña y piedra grande.", "a serie de tamaños de «A folla baila, a pedra cae»", "la serie de tamaños de «La hoja baila, la piedra cae»"),
    (11, "series", "Up, down, up", "Arriba, abaixo, arriba", "Arriba, abajo, arriba", "Leva a man arriba, solta abaixo e volve subir.", "Lleva la mano arriba, suelta abajo y vuelve a subir.", "a traxectoria da caída en «A folla baila, a pedra cae»", "la trayectoria de la caída en «La hoja baila, la piedra cae»"),

    # Mes 12 · Follas ao trasluz / Hojas a contraluz
    (12, "sustantivos", "Eye", "Ollo", "Ojo", "Sinala o teu ollo antes de mirar pola folla á luz.", "Señala tu ojo antes de mirar la hoja a la luz.", "a observación visual de «Follas ao trasluz»", "la observación visual de «Hojas a contraluz»"),
    (12, "sustantivos", "Bird", "Paxaro", "Pájaro", "Fai voar a sombra dun paxaro coas mans diante da luz.", "Haz volar la sombra de un pájaro ante la luz.", "a silueta proxectada en «Follas ao trasluz»", "la silueta proyectada en «Hojas a contraluz»"),
    (12, "onomatopeias", "Tick-tock, clock!", "Tic-tac, reloxo!", "¡Tic-tac, reloj!", "Move o dedo coma o péndulo mentres miras a luz.", "Mueve el dedo como péndulo mientras miras la luz.", "o ritmo tranquilo mirando os nervios en «Follas ao trasluz»", "el ritmo tranquilo mirando los nervios en «Hojas a contraluz»"),
    (12, "rutinas", "Night night", "Boas noites", "Buenas noches", "Apaga a lanterna suavemente ao acabar a proxección.", "Apaga la linterna suavemente al terminar la proyección.", "o peche escuro tras alumear «Follas ao trasluz»", "el cierre oscuro tras iluminar «Hojas a contraluz»"),
    (12, "rutinas", "Good morning", "Bos días", "Buenos días", "Abre a cortina para poñer a folla na fiestra.", "Abre la cortina para poner la hoja en la ventana.", "a luz da mañá para «Follas ao trasluz»", "la luz de la mañana para «Hojas a contraluz»"),
    (12, "rutinas", "Peek-a-boo", "Cucú-tras", "Cucú-tras", "Tapa e destapa a folla coa man diante da lanterna.", "Tapa y destapa la hoja con la mano ante la linterna.", "o xogo de luz e sombra en «Follas ao trasluz»", "el juego de luz y sombra en «Hojas a contraluz»"),

    # Mes 1 · Cada cousa na súa cesta / Cada cosa en su cesta
    (1, "sustantivos", "Box", "Caixa", "Caja", "Toca os catro lados da caixa de clasificar.", "Toca los cuatro lados de la caja de clasificar.", "o recipiente de clasificación en «Cada cousa na súa cesta»", "el recipiente de clasificación en «Cada cosa en su cesta»"),
    (1, "sustantivos", "Apple", "Mazá", "Manzana", "Colle a mazá e métea na cesta das froitas.", "Coge la manzana y métela en la cesta de las frutas.", "o primeiro obxecto que clasifica en «Cada cousa na súa cesta»", "el primer objeto que clasifica en «Cada cosa en su cesta»"),
    (1, "sustantivos", "Bread", "Pan", "Pan", "Pon o pan na cesta diferente á da froita.", "Pon el pan en la cesta distinta a la de la fruta.", "a segunda categoría de «Cada cousa na súa cesta»", "la segunda categoría de «Cada cosa en su cesta»"),
    (1, "series", "In, out, in", "Dentro, fóra, dentro", "Dentro, fuera, dentro", "Mete a peza na cesta, sácaa e vólvea meter.", "Mete la pieza en la cesta, sácala y vuelve a meterla.", "o xogo de agrupar en «Cada cousa na súa cesta»", "el juego de agrupar en «Cada cosa en su cesta»"),
    (1, "rutinas", "Clean up", "A recoller", "A recoger", "Sinala a caixa para gardar xuntos ao rematar.", "Señala la caja para guardar juntos al terminar.", "a acción final de ordenar en «Cada cousa na súa cesta»", "la acción final de ordenar en «Cada cosa en su cesta»"),
    (1, "rutinas", "All done", "Xa está", "Ya está", "Ensina as dúas palmas abertas sobre a cesta baleira.", "Enseña ambas palmas abiertas sobre la cesta vacía.", "o peche tras gardar todo en «Cada cousa na súa cesta»", "el cierre tras guardar todo en «Cada cosa en su cesta»"),

    # Mes 2 · Morno e frío / Templado y frío
    (2, "sustantivos", "Milk", "Leite", "Leche", "Suxeita o vaso de leite morno coas dúas mans.", "Sujeta el vaso de leche templada con ambas manos.", "a sensación morna na palma en «Morno e frío»", "la sensación templada en la palma en «Templado y frío»"),
    (2, "sustantivos", "Banana", "Plátano", "Plátano", "Toca o plátano fresco fronte ao pan morno.", "Toca el plátano fresco frente al pan templado.", "a froita fría da neveira en «Morno e frío»", "la fruta fría de la nevera en «Templado y frío»"),
    (2, "adxectivos", "Hot", "Quente", "Caliente", "Sopra amodo coa man preto do pan morno.", "Sopla despacio con la mano cerca del pan templado.", "o contraste cálido do experimento «Morno e frío»", "el contraste cálido del experimento «Templado y frío»"),
    (2, "adxectivos", "Cold", "Frío", "Frío", "Estremécete cun sorriso ao tocar a mazá da neveira.", "Estremécete con una sonrisa al tocar la manzana fría.", "o polo frío da proba de «Morno e frío»", "el polo frío de la prueba de «Templado y frío»"),
    (2, "series", "Cold, warm, cold", "Frío, morno, frío", "Frío, templado, frío", "Toca froita fría, pan morno e froita fría por quenda.", "Toca fruta fría, pan templado y fruta fría por turno.", "a serie térmica de «Morno e frío»", "la serie térmica de «Templado y frío»"),
    (2, "rutinas", "More, please", "Máis, por favor", "Más, por favor", "Xunta as puntas dos dedos pedindo tocar outra peza.", "Junta las puntas de los dedos pidiendo tocar otra pieza.", "pedir repetir o contraste táctil de «Morno e frío»", "pedir repetir el contraste táctil de «Templado y frío»"),

    # Mes 3 · Burbullas que voan / Burbujas que vuelan
    (3, "sustantivos", "Mama", "Mamá", "Mamá", "Sinala a mamá mentres sopra unha burbulla.", "Señala a mamá mientras sopla una burbuja.", "quen sopra o aro en «Burbullas que voan»", "quien sopla el aro en «Burbujas que vuelan»"),
    (3, "sustantivos", "Papa", "Papá", "Papá", "Sinala a papá collendo a burbulla na palma.", "Señala a papá recogiendo la burbuja en la palma.", "quen acompaña o xogo aéreo en «Burbullas que voan»", "quien acompaña el juego aéreo en «Burbujas que vuelan»"),
    (3, "sustantivos", "Baby", "Bebé", "Bebé", "Sinala o neno ou nena mirando subir a pompa.", "Señala al niño o niña mirando subir la pompa.", "quen segue coa vista en «Burbullas que voan»", "quien sigue con la vista en «Burbujas que vuelan»"),
    (3, "onomatopeias", "Pop, bubble!", "Pum, burbulla!", "¡Pop, burbuja!", "Toca suavemente co índice cando estoupa a burbulla.", "Toca suave con el índice cuando explota la burbuja.", "o estalo no aire en «Burbullas que voan»", "el estallido en el aire en «Burbujas que vuelan»"),
    (3, "rutinas", "Bye-bye", "Adeus", "Adiós", "Move a man despedindo a burbulla que sobe alto.", "Mueve la mano despidiendo la burbuja que sube alto.", "seguir a burbulla ata desaparecer en «Burbullas que voan»", "seguir la burbuja hasta desaparecer en «Burbujas que vuelan»"),
    (3, "series", "Open and close", "Abrir e pechar", "Abrir y cerrar", "Abre e pecha a man imitando a película de xabón.", "Abre y cierra la mano imitando la película de jabón.", "abrir o aro e gardar o bote en «Burbullas que voan»", "abrir el aro y cerrar el bote en «Burbujas que vuelan»"),

    # Mes 4 · Fregar fai son / Frotar hace sonido
    (4, "sustantivos", "Ear", "Orella", "Oreja", "Pon a man detrás da orella preto do pano ao fregar.", "Pon la mano detrás de la oreja cerca del paño al frotar.", "o oído atento á fricción en «Fregar fai son»", "el oído atento a la fricción en «Frotar hace sonido»"),
    (4, "sustantivos", "Nose", "Nariz", "Nariz", "Toca o nariz con suavidade usando a toalla limpa.", "Toca la nariz suavemente usando la toalla limpia.", "a suavidade na pel de «Fregar fai son»", "la suavidad en la piel de «Frotar hace sonido»"),
    (4, "adxectivos", "Soft", "Suave", "Suave", "Acaricia a meixela co pano seco antes de fregalo.", "Acaricia la mejilla con el paño seco antes de frotarlo.", "a textura branda que case non soa en «Fregar fai son»", "la textura blanda que apenas suena en «Frotar hace sonido»"),
    (4, "adxectivos", "Hard", "Duro", "Duro", "Peta devagar sobre o cartón ríxido coas unllas.", "Golpea despacio sobre el cartón rígido con los dedos.", "a superficie ríxida que resoa en «Fregar fai son»", "la superficie rígida que resuena en «Frotar hace sonido»"),
    (4, "rutinas", "Wash hands", "Lavar as mans", "Lavar las manos", "Frega palma contra palma escoitando a escuma.", "Frota palma contra palma escuchando la espuma.", "a fricción cotiá con xabón en «Fregar fai son»", "la fricción cotidiana con jabón en «Frotar hace sonido»"),
    (4, "rutinas", "Hold me", "Cóllome no colo", "Abrázame", "Dá unha aperta suave ao comparar texturas.", "Da un abrazo suave al comparar texturas.", "o contacto calmado tras explorar en «Fregar fai son»", "el contacto calmado tras explorar en «Frotar hace sonido»"),

    # Mes 5 · Sombras de animais / Sombras de animales
    (5, "sustantivos", "Dog", "Can", "Perro", "Proxeita a figura do can diante da lanterna.", "Proyecta la figura del perro delante de la linterna.", "o boneco protagonista de «Sombras de animais»", "el muñeco protagonista de «Sombras de animales»"),
    (5, "sustantivos", "Cat", "Gato", "Gato", "Fai as orellas do gato na parede iluminada.", "Haz las orejas del gato en la pared iluminada.", "a segunda silueta de «Sombras de animais»", "la segunda silueta de «Sombras de animales»"),
    (5, "sustantivos", "Duck", "Pato", "Pato", "Abre e pecha os dedos coma un peteiro fronte á luz.", "Abre y cierra los dedos como un pico frente a la luz.", "a sombra da man en «Sombras de animais»", "la sombra de la mano en «Sombras de animales»"),
    (5, "onomatopeias", "Woof, dog!", "Guau, can!", "¡Guau, perro!", "Fai mover a sombra do can mentres ladra suave.", "Mueve la sombra del perro mientras ladra suave.", "o son ligado á silueta do can en «Sombras de animais»", "el sonido ligado a la silueta del perro en «Sombras de animales»"),
    (5, "onomatopeias", "Meow, cat!", "Miau, gato!", "¡Miau, gato!", "Estira os bigotes coas mans vendo a sombra do gato.", "Estira los bigotes viendo la sombra del gato.", "a voz da silueta felina en «Sombras de animais»", "la voz de la silueta felina en «Sombras de animales»"),
    (5, "onomatopeias", "Quack, duck!", "Cuac, pato!", "¡Cuac, pato!", "Move o peteiro na parede ao son da lanterna.", "Mueve el pico en la pared al compás de la linterna.", "a sombra animada do pato en «Sombras de animais»", "la sombra animada del pato en «Sombras de animales»"),

    # Mes 6 · Rodar ou non rodar / Rodar o no rodar
    (6, "sustantivos", "Ball", "Pelota", "Pelota", "Empurra a pelota polo chan para que xire.", "Empuja la pelota por el suelo para que gire.", "o obxecto redondo que xira en «Rodar ou non rodar»", "el objeto redondo que gira en «Rodar o no rodar»"),
    (6, "sustantivos", "Belly", "Barriga", "Barriga", "Toca a túa barriga rodando devagar polo coxín.", "Toca tu barriga rodando despacio por el cojín.", "o xiro corporal imitando «Rodar ou non rodar»", "el giro corporal imitando «Rodar o no rodar»"),
    (6, "sustantivos", "Foot", "Pé", "Pie", "Para a pelota que roda tocándoa co pé.", "Para la pelota que rueda tocándola con el pie.", "o freo suave no chan en «Rodar ou non rodar»", "el freno suave en el suelo en «Rodar o no rodar»"),
    (6, "onomatopeias", "Baa, lamb!", "Bee, año!", "¡Bee, ovejita!", "Pousa o año na rampa e comproba que non roda.", "Posa la ovejita en la rampa y comprueba que no rueda.", "o peluche que queda quieto en «Rodar ou non rodar»", "el peluche que queda quieto en «Rodar o no rodar»"),
    (6, "series", "One, two, three", "Un, dous, tres", "Uno, dos, tres", "Marca tres dedos antes de soltar a pelota.", "Marca tres dedos antes de soltar la pelota.", "a conta previa ao lanzamento en «Rodar ou non rodar»", "la cuenta previa al lanzamiento en «Rodar o no rodar»"),
    (6, "series", "Stop and go", "Para e vai", "Para y ve", "Frea a pelota coa palma e logo empurra de novo.", "Frena la pelota con la palma y luego empuja otra vez.", "o control de movemento de «Rodar ou non rodar»", "el control de movimiento de «Rodar o no rodar»"),
]

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
    {"gl": "Descubrimos: primeiras palabras e a canción", "es": "Descubrimos: primeras palabras y la canción"},
    {"gl": "Xogamos coas palabras do núcleo e coa canción", "es": "Jugamos con las palabras del núcleo y con la canción"},
    {"gl": "A rima tradicional e as novas pezas", "es": "La rima tradicional y las nuevas piezas"},
    {"gl": "Consolidamos todo o proxecto sen novas", "es": "Consolidamos todo el proyecto sin palabras nuevas"},
]

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
        "Frota amodo tea contra tea e logo cartón estriado para que escoite e toque cada textura.",
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
    return 0 < elementos(en) <= 3 and not TO_BE.search(en)


def _peza_capa(p: dict) -> dict:
    return {k: p[k] for k in ("en", "gl", "es", "lamina", "xesto") if k in p}


def _capas_semana(st_gl: str, st_es: str, s_num: int, nova_items: list[dict], todas_sem: list[dict]) -> dict:
    """O-20261126-5 (punto 5): cada capa trae SUS piezas, con lámina, voz y
    significado. Núcleo: las nuevas de la semana. «Máis»: las otras palabras
    del proyecto de esa semana, para quien ya mira y busca las nuevas.
    «Apoio»: una sola pieza, la primera nueva, con su objeto."""
    nucleo = nova_items or todas_sem[:2]
    mais = [p for p in todas_sem if p not in nucleo][:3] or todas_sem[:2]
    apoio = nucleo[:1]
    def lista(xs, gl=True):
        nomes = [f"«{x['en']}»" for x in xs]
        y = " e " if gl else " y "
        return nomes[0] if len(nomes) == 1 else ", ".join(nomes[:-1]) + y + nomes[-1]
    return {
        "nucleo": {
            "gl": f"«{st_gl}», semana {s_num}: nomea {lista(nucleo)} mentres o toca coas mans.",
            "es": f"«{st_es}», semana {s_num}: nombra {lista(nucleo, False)} mientras lo toca con las manos.",
            "en": ", ".join(x["en"] for x in nucleo),
            "pezas": [_peza_capa(x) for x in nucleo],
        },
        "mais": {
            "gl": f"«{st_gl}», semana {s_num}, se xa mira e busca as novas: engade {lista(mais)}, unha a unha e co seu xesto.",
            "es": f"«{st_es}», semana {s_num}, si ya mira y busca las nuevas: añade {lista(mais, False)}, una a una y con su gesto.",
            "en": ", ".join(x["en"] for x in mais),
            "pezas": [_peza_capa(x) for x in mais],
        },
        "apoio": {
            "gl": f"«{st_gl}», semana {s_num}, con calma: só {lista(apoio)}, co obxecto na man, e agarda a que o mire.",
            "es": f"«{st_es}», semana {s_num}, con calma: solo {lista(apoio, False)}, con el objeto en la mano, y espera a que lo mire.",
            "en": apoio[0]["en"],
            "pezas": [_peza_capa(x) for x in apoio],
        },
    }


def _rutinas_semana(st_gl: str, st_es: str, mes: int, s_num: int, peza: dict) -> dict:
    en = peza["en"]
    g_gl = peza["xesto"]["gl"].rstrip(".")
    g_es = peza["xesto"]["es"].rstrip(".")
    out = {}
    verbos_gl = {
        "bano": f"coa auga na semana {s_num}",
        "comida": f"na cadeira da mesa na semana {s_num}",
        "coche": f"suxeitando unha peza segura no asento (sem. {s_num})",
        "vestirse": f"mentres pomos a roupa na semana {s_num}",
        "durmir": f"baixando o ton no conto da semana {s_num}",
        "parque": f"mirando o aire libre na semana {s_num}",
    }
    verbos_es = {
        "bano": f"con el agua en la semana {s_num}",
        "comida": f"en la trona de la comida en la semana {s_num}",
        "coche": f"sujetando una pieza segura en la silla (sem. {s_num})",
        "vestirse": f"mientras ponemos la ropa en la semana {s_num}",
        "durmir": f"bajando el tono antes de dormir (sem. {s_num})",
        "parque": f"al aire libre en el parque (sem. {s_num})",
    }
    for rk, lab_gl, lab_es in RUTINAS_FOGAR:
        out[rk] = {
            "gl": f"{lab_gl} ({st_gl}): di «{en}» {verbos_gl[rk]}, {g_gl.lower()}.",
            "es": f"{lab_es} ({st_es}): di «{en}» {verbos_es[rk]}, {g_es.lower()}.",
            "en": en,
            "xesto": peza["xesto"],
        }
    return out


def construir(laminas_pal: dict | None = None) -> dict:
    lec = json.loads((RAIZ / "assets/content/leccions/leccions.json").read_text(encoding="utf-8"))
    steam_data = json.loads((RAIZ / "assets/content/steam/steam_do_mes.json").read_text(encoding="utf-8"))["experimentos"]
    steam_obs = {e["id"]: e.get("observar") or {"gl": "", "es": ""} for e in steam_data}
    steam_tit = {e["mes"]: e["titulo"] for e in steam_data if e["curso"] == "curso_0_2"}
    unidades = lec["cursos"]["curso_0_2"]["unidades"]
    cancions = json.loads((RAIZ / "assets/content/cancions/cancions_con_pulso.json").read_text(encoding="utf-8"))["cancions"]
    if laminas_pal is None:
        laminas_pal = json.loads(MAPA.read_text(encoding="utf-8"))["pezas"] if MAPA.exists() else {}

    por_mes: dict[int, list[dict]] = {m: [] for m in MESES}
    for m, fam, en, gl, es, xgl, xes, pgl, pes in NUCLEO_60:
        en_l = limpo(en)
        k = en_l.lower().strip("!?. ")
        st = steam_tit[m]
        por_mes[m].append({
            "en": en_l,
            "gl": gl,
            "es": es,
            "familia": fam,
            "novaNoMes": True,
            "parteSteam": {"gl": pgl, "es": pes},
            "steam": st,
            "xesto": {"gl": xgl, "es": xes},
            **({"lamina": laminas_pal[k]["clave"]} if k in laminas_pal else {}),
        })

    proxectos = []
    vistas_antes: list[dict] = []
    for i, mes in enumerate(MESES):
        u = unidades[i]
        novas_mes = por_mes[mes]
        st_tit = (u.get("steam") or {}).get("titulo") or steam_tit[mes]
        st_gl, st_es = st_tit["gl"], st_tit["es"]

        # Retornos de meses anteriores (ata 12 pezas anteriores para consolidar o núcleo de 60).
        retornos: list[dict] = []
        if vistas_antes:
            offsets = [-1, -2, -3, -4, -6, -8, -10, -12, -15, -18, -22, -26]
            vistos_ret: set[str] = set()
            for off in offsets:
                cand = vistas_antes[(len(vistas_antes) + off) % len(vistas_antes)]
                if cand["en"] in vistos_ret:
                    continue
                vistos_ret.add(cand["en"])
                retornos.append({
                    **cand,
                    "novaNoMes": False,
                    "parteSteam": {
                        "gl": f"{cand['gl']} recuperada no xogo de «{st_gl}»",
                        "es": f"{cand['es']} recuperada en el juego de «{st_es}»",
                    },
                    "steam": st_tit,
                })
                if len(retornos) >= 12:
                    break

        palabras = novas_mes + [r for r in retornos if r["en"] not in {n["en"] for n in novas_mes}]
        semanas = []
        for s_idx in range(4):
            s_num = s_idx + 1
            if s_idx < 3:
                w_novas = novas_mes[s_idx * 2:(s_idx + 1) * 2]
                w_rets = retornos[s_idx * 3:s_idx * 3 + 2]
                if not w_rets:
                    # Mes 9: apoia con outra parella xa vista no mes para que cada semana teña xogo rico.
                    w_rets = [p for p in novas_mes if p not in w_novas][:2]
                w_pal = w_novas + w_rets
            else:
                w_novas = []
                w_pal = novas_mes[:3] + retornos[:2]
            peza_rut = w_novas[0] if w_novas else w_pal[0]
            semanas.append({
                "semana": s_num,
                "fase": FASES[s_idx],
                "novas": [p["en"] for p in w_novas],
                "palabras": [p["en"] for p in w_pal],
                "capas": _capas_semana(st_gl, st_es, s_num, w_novas, w_pal),
                "rutinas": _rutinas_semana(st_gl, st_es, mes, s_num, peza_rut),
            })

        frases = [w for w in palabras if 2 <= elementos(w["en"]) <= 3]
        como_falar = [w["en"] for w in (frases + [p for p in palabras if p not in frases])][:4]
        cn = cancions[i]
        ck = cn["titulo"]["es"].lower().strip("!?. ")
        r_en, r_gl, r_es = RIMAS[mes]
        rk = r_en.lower().strip("!?. ")
        m_en, m_gl, m_es, g_gl, g_es = MIRA_E_NOTA[mes]
        st_id = (u.get("steam") or {}).get("id", "")
        proxectos.append({
            "mesCalendario": mes,
            "proxecto": u["titulo"],
            "steam": u.get("steam"),
            "cancion": {
                "id": cn["id"],
                "gl": cn["titulo"]["gl"],
                "es": cn["titulo"]["es"],
                **({"lamina": laminas_pal[ck]["clave"]} if ck in laminas_pal else {}),
            },
            "rima": {
                "en": r_en,
                "gl": r_gl,
                "es": r_es,
                **({"lamina": laminas_pal[rk]["clave"]} if rk in laminas_pal else {}),
            },
            "palabras": palabras,
            "semanas": semanas,
            "comoFalar": como_falar,
            "xaSabe": [p["en"] for p in vistas_antes[-8:]],
            "guia": {
                "gl": f"Canta «{cn['titulo']['gl']}» co xesto. Traballa o núcleo de «{st_gl}» a un ritmo tranquilo.",
                "es": f"Canta «{cn['titulo']['es']}» con el gesto. Trabaja el núcleo de «{st_es}» a un ritmo tranquilo.",
            },
            "mira_e_nota": {
                "titulo": {"gl": "Mira e nota", "es": "Mira y nota"},
                "frase_en": m_en,
                "significado": {"gl": m_gl, "es": m_es},
                "guia": {"gl": g_gl, "es": g_es},
                "observar": steam_obs.get(st_id, {"gl": "", "es": ""}),
            },
        })
        vistas_antes.extend(novas_mes)

    return {
        "_doc": "Xerado por tools/gen_acopros_0_2.py (P11.6 · D4). Non se edita a man.",
        "fonte": "MacArthur-Bates CDI / Wordbank (Frank et al., Stanford University, CC BY 4.0) + ACOPROS (consideraciones-2026-11-09.md)",
        "proxectos": proxectos,
    }


def revisar(d: dict) -> list[str]:
    fallos = []
    if len(d["proxectos"]) != 10:
        fallos.append("non hai 10 proxectos")
    todas_en: dict[str, int] = {}
    fams: set[str] = set()
    rut_seen: set[tuple[str, str]] = set()
    for p in d["proxectos"]:
        m = p["mesCalendario"]
        st_gl = (p.get("steam") or {}).get("titulo", {}).get("gl", "")
        st_es = (p.get("steam") or {}).get("titulo", {}).get("es", "")
        if not 6 <= len(p["palabras"]) <= 20:
            fallos.append(f"mes {m}: {len(p['palabras'])} pezas fóra de 6..20")
        for w in p["palabras"]:
            if not valida(w["en"]):
                fallos.append(f"mes {m}: «{w['en']}» supera 3 palabras ou ten to be")
            if not (w["gl"] and w["es"]):
                fallos.append(f"mes {m}: «{w['en']}» sen gl/es")
            fam = w.get("familia")
            if fam not in FAMILIAS:
                fallos.append(f"mes {m}: «{w['en']}» sen familia válida ({fam})")
            else:
                fams.add(fam)
            ps = w.get("parteSteam") or {}
            if not (ps.get("gl") and ps.get("es")):
                fallos.append(f"mes {m}: «{w['en']}» sen parteSteam")
            elif st_gl not in ps["gl"] or st_es not in ps["es"]:
                fallos.append(f"mes {m}: parteSteam de «{w['en']}» non nomea «{st_es}»")
            todas_en[w["en"].lower()] = todas_en.get(w["en"].lower(), 0) + 1
        presentadas = {w["en"] for w in p["palabras"]}
        for f in p["comoFalar"]:
            if not valida(f) or f not in presentadas:
                fallos.append(f"mes {m}: comoFalar «{f}» non válido ou non presentado")
        for x in p["xaSabe"]:
            if not valida(x):
                fallos.append(f"mes {m}: xaSabe «{x}» supera 3 palabras")
        if not (p["cancion"].get("gl") and p["cancion"].get("es")):
            fallos.append(f"mes {m}: sen canción")
        if not (p["rima"]["en"] and p["rima"]["gl"] and p["rima"]["es"]):
            fallos.append(f"mes {m}: sen rima")
        mira = p.get("mira_e_nota") or {}
        if not mira.get("frase_en") or not valida(mira["frase_en"]):
            fallos.append(f"mes {m}: mira_e_nota.frase_en non válida")
        if "?" in str(mira) or "¿" in str(mira):
            fallos.append(f"mes {m}: mira_e_nota con preguntas abertas")
        for s_idx, sem in enumerate(p["semanas"]):
            if s_idx < 3 and not (2 <= len(sem.get("novas") or []) <= 3):
                fallos.append(f"mes {m} sem {sem['semana']}: {len(sem.get('novas') or [])} novas (esperado 2-3)")
            capas = sem.get("capas") or {}
            for cn in ("nucleo", "mais", "apoio"):
                c = capas.get(cn) or {}
                if not (c.get("gl") and c.get("es") and c.get("en")):
                    fallos.append(f"mes {m} sem {sem['semana']} capa {cn}: incompleta")
                elif st_gl not in c["gl"] or st_es not in c["es"]:
                    fallos.append(f"mes {m} sem {sem['semana']} capa {cn}: sen STEAM")
            ruts = sem.get("rutinas") or {}
            for rk, _, _ in RUTINAS_FOGAR:
                rv = ruts.get(rk) or {}
                if not (rv.get("gl") and rv.get("es") and rv.get("en")):
                    fallos.append(f"mes {m} sem {sem['semana']} rutina {rk}: incompleta")
                elif st_gl not in rv["gl"] or st_es not in rv["es"]:
                    fallos.append(f"mes {m} sem {sem['semana']} rutina {rk}: sen STEAM")
                else:
                    if (rk, rv["es"]) in rut_seen:
                        fallos.append(f"mes {m} sem {sem['semana']} rutina {rk}: repetida entre semanas")
                    rut_seen.add((rk, rv["es"]))
        if "canción" not in p["semanas"][0]["fase"]["es"]:
            fallos.append(f"mes {m}: a semana 1 non nomea a canción")
    if not 55 <= len(todas_en) <= 65:
        fallos.append(f"{len(todas_en)} pezas distintas (esperado ~60)")
    if fams != set(FAMILIAS):
        fallos.append(f"faltan familias: {set(FAMILIAS) - fams}")
    reps = sum(1 for v in todas_en.values() if v > 1)
    if reps < len(todas_en) // 2:
        fallos.append(f"só {reps} de {len(todas_en)} volven noutro mes")
    return fallos


def main() -> int:
    if "--check" not in sys.argv:
        sys.path.insert(0, str(RAIZ / "tools"))
        from laminas_0_2_nucleo import xerar_laminas_nucleo_0_2  # noqa: E402
        mp = json.loads(MAPA.read_text(encoding="utf-8"))
        xerar_laminas_nucleo_0_2(mp["pezas"])
        mp["pezas"] = dict(sorted(mp["pezas"].items()))
        MAPA.write_text(json.dumps(mp, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
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
        sp = RAIZ / "assets/content/significados/significados.json"
        sig = json.loads(sp.read_text(encoding="utf-8"))
        for p in d["proxectos"]:
            r = p["rima"]
            sig["significados"].setdefault(r["en"], {"gl": r["gl"], "es": r["es"]})
        sp.write_text(json.dumps(sig, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
    if fallos:
        print("FALLO (ACOPROS 0-2 D4):\n  " + "\n  ".join(fallos))
        return 1
    print("OK: 10 proxectos de 0-2 con núcleo de 60 pezas en 5 familias, 2-3 novas/semana, <=3 palabras, 3 capas STEAM e 6 rutinas M2.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
