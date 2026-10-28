#!/usr/bin/env python3
"""Escribe la gramática del curso (Frank, 28/10/2026).

    python3 tools/gen_gramatica.py           # escribe
    python3 tools/gen_gramatica.py --check   # falla si no está al día

Los 48 puntos de gramática, de A1 a C1, en el orden que dio Frank. Por su
decisión, los puntos 1-20 (A1 y A2) son la columna de las cinco edades: cada
unidad del mes trabaja uno, con cuatro frases de ejemplo hechas con las
palabras de ese mes, una por semana, que dice la persona adulta. Los puntos
21-48 (B1-C1) son para la persona adulta, para que sepa lo que modela.

La descripción de cada punto es la de Frank (castellano); el gallego, la
explicación sencilla para las familias y las frases de ejemplo las escribe
Claude Code.
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

C = Path(__file__).resolve().parent.parent / "assets" / "content"
SAIDA = C / "gramatica" / "gramatica.json"

# n: (nivel, título gl, título es, descripción gl, descripción es,
#     para la familia gl, para la familia es)
PUNTOS = {
    1: ("A1", "Pronomes suxeito e o verbo to be", "Pronombres sujeto y el verbo to be",
        "Formas afirmativa, negativa e interrogativa en presente simple.",
        "Formas afirmativa, negativa e interrogativa en presente simple.",
        "Dicir quen é e como está: «I am happy», «It is a cat», «Is it cold?».",
        "Decir quién es y cómo está: «I am happy», «It is a cat», «Is it cold?»."),
    2: ("A1", "Artigos e substantivos", "Artículos y sustantivos",
        "Artigos indeterminados (a/an) e determinado (the); substantivos en singular e plural (formación regular e irregular).",
        "Artículos indeterminados (a/an) y determinado (the); sustantivos en singular y plural (reglas de formación regular e irregular).",
        "Os nomes das cousas, un ou moitos: «a leaf», «the leaf», «leaves».",
        "Los nombres de las cosas, uno o muchos: «a leaf», «the leaf», «leaves»."),
    3: ("A1", "Demostrativos e posesivos", "Demostrativos y posesivos",
        "Pronomes e adxectivos demostrativos (this, that, these, those); adxectivos posesivos (my, your, his…) e xenitivo saxón ('s).",
        "Pronombres/adjetivos demostrativos (this, that, these, those); adjetivos posesivos (my, your, his...) y genitivo sajón ('s).",
        "Sinalar e dicir de quen é: «this hat», «my hat», «Mum's coat».",
        "Señalar y decir de quién es: «this hat», «my hat», «Mum's coat»."),
    4: ("A1", "Presente simple", "Presente simple",
        "Verbos de acción, terceira persoa do singular (-s/-es), auxiliares do / does para negar e preguntar.",
        "Verbos de acción, reglas de tercera persona singular (-s/-es), auxiliares do / does para negación y preguntas.",
        "O que facemos sempre: «We sit in a circle», «The cow eats grass».",
        "Lo que hacemos siempre: «We sit in a circle», «The cow eats grass»."),
    5: ("A1", "Adverbios e expresións de frecuencia", "Adverbios y expresiones de frecuencia",
        "Posición de always, usually, often, sometimes, never e expresións de tempo.",
        "Posición sintáctica de always, usually, often, sometimes, never y expresiones temporales.",
        "Cada canto se fai algo: «We always wear boots in the rain».",
        "Cada cuánto se hace algo: «We always wear boots in the rain»."),
    6: ("A1", "Contables e incontables", "Contables e incontables",
        "Cuantificadores básicos (some, any, much, many, a lot of).",
        "Cuantificadores básicos (some, any, much, many, a lot of).",
        "Cantidades: «some water», «more juice», «a lot of seeds».",
        "Cantidades: «some water», «more juice», «a lot of seeds»."),
    7: ("A1", "There is / there are e preposicións de lugar", "There is / there are y preposiciones de lugar",
        "Estrutura there is / there are; preposicións básicas (in, on, under, next to, behind, in front of).",
        "Estructura There is / There are; preposiciones básicas (in, on, under, next to, behind, in front of).",
        "Que hai e onde está: «There is a fish in the water», «The ball is under the table».",
        "Qué hay y dónde está: «There is a fish in the water», «The ball is under the table»."),
    8: ("A1", "Preguntas con wh-", "Preguntas con wh-",
        "Preguntas con what, where, when, who, why, which, how.",
        "Estructura de preguntas con what, where, when, who, why, which, how.",
        "Preguntar: «Where is the sun?», «What is it?», «Who is it?».",
        "Preguntar: «Where is the sun?», «What is it?», «Who is it?»."),
    9: ("A1", "Preposicións de tempo", "Preposiciones de tiempo",
        "Uso de at, in, on.",
        "Uso canónico de at, in, on.",
        "Cando pasa: «in the morning», «at night», «on Monday».",
        "Cuándo pasa: «in the morning», «at night», «on Monday»."),
    10: ("A1", "Can e o imperativo", "Can y el imperativo",
         "Can / can't (habilidade, posibilidade e permiso); oracións imperativas (ordes e instrucións).",
         "Verbo modal can / can't (habilidad, posibilidad y permiso informal); oraciones imperativas (órdenes e instrucciones).",
         "Ordes e o que se pode facer: «Jump!», «Clap your hands!», «I can fly!».",
         "Órdenes y lo que se puede hacer: «Jump!», «Clap your hands!», «I can fly!»."),
    11: ("A2", "Presente continuo", "Presente continuo",
         "To be + xerundio (-ing) para o que está pasando agora, fronte ao presente simple.",
         "Formación con to be + gerundio (-ing) para acciones en progreso y contraste con Presente Simple (action verbs vs. stative verbs).",
         "O que está pasando agora: «It is raining», «The bear is sleeping».",
         "Lo que está pasando ahora: «It is raining», «The bear is sleeping»."),
    12: ("A2", "Pasado de to be", "Pasado de to be",
         "Was / were e there was / there were.",
         "Formas was / were y estructura existencial en pasado (there was / there were).",
         "Como era antes: «It was cold», «There was a squirrel».",
         "Cómo era antes: «It was cold», «There was a squirrel»."),
    13: ("A2", "Pasado simple", "Pasado simple",
         "Verbos regulares (-ed) e os irregulares básicos; auxiliar did / didn't.",
         "Verbos regulares (terminación -ed y reglas fonéticas) y lista fundamental de verbos irregulares; auxiliar did / didn't.",
         "Contar o que pasou: «The chestnut rolled», «We went home».",
         "Contar lo que pasó: «The chestnut rolled», «We went home»."),
    14: ("A2", "Pasado continuo", "Pasado continuo",
         "Accións en curso no pasado, con when e while.",
         "Acciones en progreso en el pasado y combinación con Pasado Simple mediante conectores when y while.",
         "O que estaba pasando: «The wolf was sleeping when the sheep came».",
         "Lo que estaba pasando: «The wolf was sleeping when the sheep came»."),
    15: ("A2", "Pronomes obxecto e reflexivos", "Pronombres objeto y reflexivos",
         "Me, you, him, her… e myself, yourself…",
         "Pronombres personales de complemento directo/indirecto (me, you, him, her...) y reflexivos (myself, yourself...).",
         "A quen: «Look at me», «Help him», «I can do it myself».",
         "A quién: «Look at me», «Help him», «I can do it myself»."),
    16: ("A2", "Adxectivos: comparativos e superlativos", "Adjetivos: comparativos y superlativos",
         "Orde dos adxectivos; comparativo (-er / more than, as… as) e superlativo (-est / the most).",
         "Orden estándar de adjetivos; comparativo de superioridad (-er / more than), igualdad (as... as) y superlativo (-est / the most).",
         "Comparar: «bigger», «as big as», «the biggest».",
         "Comparar: «bigger», «as big as», «the biggest»."),
    17: ("A2", "O futuro", "El futuro",
         "Be going to (plans e o que se ve vir) fronte a will (decisións, predicións e promesas).",
         "Be going to (intenciones, planes previos y evidencia inmediata) frente a Will (decisiones espontáneas, predicciones y promesas).",
         "O que imos facer: «We are going to swim», «I will help you».",
         "Lo que vamos a hacer: «We are going to swim», «I will help you»."),
    18: ("A2", "Obriga e consello", "Obligación y consejo",
         "Must, have to, don't have to e should / shouldn't.",
         "Must, have to, don't have to (ausencia de obligación) y should / shouldn't.",
         "O que hai que facer: «You must walk slowly», «You should hide».",
         "Lo que hay que hacer: «You must walk slowly», «You should hide»."),
    19: ("A2", "Preposicións de movemento", "Preposiciones de movimiento",
         "To, into, out of, through, across, towards, along.",
         "To, into, out of, through, across, towards, along.",
         "Cara a onde: «into the boat», «across the river», «through the waves».",
         "Hacia dónde: «into the boat», «across the river», «through the waves»."),
    20: ("A2", "Conectores básicos", "Conectores básicos",
         "And, but, so, because, although.",
         "Coordinación y subordinación elemental (and, but, so, because, although).",
         "Unir dúas ideas: «We pull and pull, but it doesn't move», «because».",
         "Unir dos ideas: «We pull and pull, but it doesn't move», «because»."),
    21: ("B1", "Presente perfecto", "Presente perfecto", "Have/has + participio; experiencias con ever, never, already, yet, just.", "Formación con have/has + participio pasado; uso para experiencias vitales con marcadores ever, never, already, yet, just.", None, None),
    22: ("B1", "Presente perfecto e pasado simple", "Presente perfecto y pasado simple", "Duración e relevancia no presente fronte a tempo pechado; for e since.", "Duración y relevancia presente frente a tiempo cerrado; uso de for y since.", None, None),
    23: ("B1", "Presente perfecto continuo", "Presente perfecto continuo", "Accións prolongadas con efecto no presente fronte ao resultado do presente perfecto.", "Acciones prolongadas con efecto en el presente frente al resultado del Presente Perfecto Simple.", None, None),
    24: ("B1", "Pasado perfecto", "Pasado perfecto", "Had + participio; o que pasou antes doutra acción pasada.", "Formación con had + participio; anterioridad cronológica respecto a otra acción en pasado.", None, None),
    25: ("B1", "Modais de probabilidade e dedución", "Modales de probabilidad y deducción", "May, might, could (posibilidade); must, can't (certeza no presente).", "May, might, could (posibilidad); must, can't (certeza en presente).", None, None),
    26: ("B1", "Condicional cero e primeiro", "Condicional cero y primero", "Cero (if + presente, presente); primeiro (if + presente, will + infinitivo); unless.", "Cero (hechos universales: if + present, present); Primero (hipótesis reales y futuras: if + present, will + infinitive); cláusulas con unless.", None, None),
    27: ("B1", "Segundo condicional", "Segundo condicional", "Situacións hipotéticas do presente e do futuro (if + pasado simple, would + infinitivo).", "Situaciones hipotéticas o irreales del presente y futuro (if + past simple, would + infinitive).", None, None),
    28: ("B1", "Voz pasiva básica", "Voz pasiva básica", "Pasiva en presente e pasado simple (am/is/are + participio, was/were + participio).", "Transformación agente-paciente en Presente Simple y Pasado Simple (am/is/are + participio, was/were + participio).", None, None),
    29: ("B1", "Oracións de relativo especificativas", "Oraciones de relativo especificativas", "Who, which, that, whose, where e cando se omite o pronome.", "Pronombres relativos (who, which, that, whose, where) y regla de omisión del pronombre como objeto.", None, None),
    30: ("B1", "Xerundio ou infinitivo", "Gerundio o infinitivo", "Verbos con to-infinitivo (decide, want), con -ing (enjoy, avoid) e cos dous con distinto significado (stop, remember).", "Verbos seguidos de to-infinitive (ej. decide, want), verbos seguidos de -ing (ej. enjoy, avoid), y verbos con cambio de significado (ej. stop, remember).", None, None),
    31: ("B1", "Estilo indirecto básico", "Estilo indirecto básico", "Cambio de tempos (backshift) en afirmacións e preguntas.", "Correlación temporal básica (backshift) en afirmaciones y preguntas reportadas.", None, None),
    32: ("B1", "Phrasal verbs", "Phrasal verbs", "Transitivos, intransitivos, separables e inseparables.", "Clasificación sintáctica: transitivos, intransitivos, separables e inseparables.", None, None),
    33: ("B1", "Preguntas confirmatorias e indirectas", "Preguntas confirmatorias e indirectas", "Question tags e preguntas de cortesía (Could you tell me where…?).", "Question tags y estructuras de cortesía (Could you tell me where...?).", None, None),
    34: ("B2", "Terceiro condicional", "Tercer condicional", "Hipóteses do pasado (if + past perfect, would have + participio).", "Hipótesis del pasado y arrepentimientos (if + past perfect, would have + past participle).", None, None),
    35: ("B2", "Condicionais mixtos", "Condicionales mixtos", "Causa pasada con consecuencia presente, ou condición permanente con resultado pasado.", "Causa pasada con consecuencia en el presente, o condición permanente con resultado pasado.", None, None),
    36: ("B2", "Desexo e arrepentimento", "Deseo y arrepentimiento", "Wish e if only (+ pasado simple, + pasado perfecto, + would).", "Uso de Wish e If only (+ pasado simple para el presente; + pasado perfecto para el pasado; + would para quejas).", None, None),
    37: ("B2", "Modais en pasado", "Modales en pasado", "Must have, can't have, couldn't have, should have, might have + participio.", "Deducción y juicio retrospectivo (must have, can't have, couldn't have, should have, might have + participio).", None, None),
    38: ("B2", "Pasiva avanzada e causativos", "Pasiva avanzada y causativos", "Pasiva en tempos continuos e perfectos; pasiva impersoal (It is said that…); have/get something done.", "Pasiva en tiempos continuos y perfectos; pasiva impersonal (It is said that... / Subject is said to...); estructuras causativas (have/get something done).", None, None),
    39: ("B2", "Oracións de relativo explicativas", "Oraciones de relativo explicativas", "Comas, pronomes obrigatorios e sen that.", "Uso de comas, pronombres obligatorios y prohibición de that.", None, None),
    40: ("B2", "Futuros compostos", "Futuros compuestos", "Futuro continuo (will be doing) e futuro perfecto (will have done).", "Futuro Continuo (will be doing) para acciones en desarrollo futuro; Futuro Perfecto (will have done) para acciones completadas antes de un punto temporal.", None, None),
    41: ("B2", "Pasado perfecto continuo", "Pasado perfecto continuo", "Had been doing: o que viña pasando antes doutro momento pasado.", "Continuidad de una acción previa a otro punto de referencia en el pasado (had been doing).", None, None),
    42: ("B2", "Verbos de estilo indirecto", "Verbos de estilo indirecto", "Admit, deny, refuse, warn, insist on, apologize for.", "Patrones con verbos específicos de reporte (admit, deny, refuse, warn, insist on, apologize for).", None, None),
    43: ("B2", "Conectores avanzados", "Conectores avanzados", "Contraste, concesión e propósito (despite, in spite of, whereas, in order to, so that, nonetheless).", "Marcadores de contraste, concesión y propósito (despite, in spite of, whereas, in order to, so that, nonetheless).", None, None),
    44: ("C1", "Cláusulas de participio", "Cláusulas de participio", "Reducir subordinadas con -ing, -ed e having done.", "Reducción de subordinadas temporales, causales y relativas mediante participios de presente (-ing), pasado (-ed) y perfecto (having done).", None, None),
    45: ("C1", "Inversión enfática", "Inversión enfática", "Never had I seen, Seldom do we, Under no circumstances should you.", "Alteración del orden sujeto-verbo tras adverbios negativos o restrictivos (Never had I seen, Seldom do we, Under no circumstances should you).", None, None),
    46: ("C1", "Oracións fendidas", "Oraciones hendidas", "What I really need is… / It was yesterday when… / The reason why…", "Estructuras de focalización y énfasis (What I really need is... / It was yesterday when... / The reason why...).", None, None),
    47: ("C1", "Subxuntivo e fórmulas hipotéticas", "Subjuntivo y fórmulas hipotéticas", "Subxuntivo mandativo (demand that he be present) e were he to come, lest.", "Subjuntivo mandativo (demand that he be present) y giros hipotéticos arcaicos o formales (were he to come, lest).", None, None),
    48: ("C1", "Elipse, substitución e cohesión", "Elipsis, sustitución y cohesión", "So do I, neither will he, to do so e marcadores de rexistro formal.", "Omisión de elementos sintácticos redundantes (so do I, neither will he, to do so) y marcadores de registro formal/académico.", None, None),
}

# Un ejemplo de cada punto B1-C1, para la persona adulta.
EXEMPLO_ADULTO = {
    21: ("Have you ever seen a hedgehog?", "Viches algunha vez un ourizo?", "¿Has visto alguna vez un erizo?"),
    22: ("We have lived in Vigo since 2020.", "Vivimos en Vigo desde 2020.", "Vivimos en Vigo desde 2020."),
    23: ("She has been playing in the sand all morning.", "Leva toda a mañá xogando na area.", "Lleva toda la mañana jugando en la arena."),
    24: ("The bus had left when we arrived.", "O autobús xa saíra cando chegamos.", "El autobús ya se había ido cuando llegamos."),
    25: ("It might rain later.", "Pode que chova máis tarde.", "Puede que llueva más tarde."),
    26: ("If it rains, we will stay at home.", "Se chove, quedaremos na casa.", "Si llueve, nos quedaremos en casa."),
    27: ("If I had a boat, I would sail to the islands.", "Se tivese un barco, iría ás illas.", "Si tuviera un barco, iría a las islas."),
    28: ("The bread is made every morning.", "O pan faise todas as mañás.", "El pan se hace todas las mañanas."),
    29: ("This is the park where we play.", "Este é o parque onde xogamos.", "Este es el parque donde jugamos."),
    30: ("She enjoys painting.", "Gústalle pintar.", "Le gusta pintar."),
    31: ("He said he was tired.", "Dixo que estaba canso.", "Dijo que estaba cansado."),
    32: ("Put on your coat.", "Ponte o abrigo.", "Ponte el abrigo."),
    33: ("It's cold today, isn't it?", "Hoxe vai frío, non si?", "Hoy hace frío, ¿verdad?"),
    34: ("If we had left earlier, we would have caught the bus.", "Se saísemos antes, colleriamos o autobús.", "Si hubiéramos salido antes, habríamos cogido el autobús."),
    35: ("If I had slept more, I wouldn't be so tired now.", "Se durmise máis, agora non estaría tan canso.", "Si hubiera dormido más, ahora no estaría tan cansado."),
    36: ("I wish I lived near the sea.", "Oxalá vivise preto do mar.", "Ojalá viviera cerca del mar."),
    37: ("She must have forgotten her hat.", "Debeu de esquecer o gorro.", "Debió de olvidar el gorro."),
    38: ("We had the windows cleaned.", "Fixemos limpar as ventás.", "Hicimos limpiar las ventanas."),
    39: ("My sister, who lives in Lugo, is a teacher.", "A miña irmá, que vive en Lugo, é mestra.", "Mi hermana, que vive en Lugo, es maestra."),
    40: ("This time tomorrow, we will be flying to London.", "Mañá a esta hora estaremos voando a Londres.", "Mañana a esta hora estaremos volando a Londres."),
    41: ("They had been waiting for an hour when the bus came.", "Levaban unha hora esperando cando chegou o autobús.", "Llevaban una hora esperando cuando llegó el autobús."),
    42: ("He apologized for being late.", "Pediu perdón por chegar tarde.", "Pidió perdón por llegar tarde."),
    43: ("Despite the rain, we went to the beach.", "A pesar da chuvia, fomos á praia.", "A pesar de la lluvia, fuimos a la playa."),
    44: ("Having finished dinner, we went for a walk.", "Despois de cear, fomos dar un paseo.", "Después de cenar, fuimos a dar un paseo."),
    45: ("Never have I seen such a big wave.", "Nunca vin unha onda tan grande.", "Nunca he visto una ola tan grande."),
    46: ("What I really need is a cup of tea.", "O que de verdade necesito é unha cunca de té.", "Lo que de verdad necesito es una taza de té."),
    47: ("The school asks that every child bring a hat.", "A escola pide que cada neno traia un gorro.", "La escuela pide que cada niño traiga un gorro."),
    48: ("I love the sea, and so does my son.", "Encántame o mar, e ao meu fillo tamén.", "Me encanta el mar, y a mi hijo también."),
}

# La columna de las cinco edades (Frank, 28/10/2026: «progresión real»): las
# 20 unidades de A1-A2, en el orden de Frank, subiendo a lo largo de los 50
# meses sin volver atrás (unas 2,5 por unidad): 0-2 → 1-4, 2-3 → 5-8,
# 3-4 → 9-12, 4-5 → 13-16, 5-6 → 17-20. Cada mes, cuatro frases con las
# palabras de su unidad del mes, una por semana.
RUTA = {
    "curso_0_2": {
        9: (1, [("I am Lúa.", "Eu son Lúa.", "Yo soy Lúa."), ("You are my friend.", "Ti es o meu amigo.", "Tú eres mi amigo."),
                ("It is water.", "É auga.", "Es agua."), ("I am wet!", "Estou mollado!", "¡Estoy mojado!")]),
        10: (1, [("I am happy.", "Estou contento.", "Estoy contento."), ("Is it your tummy? Yes, it is.", "É a túa barriga? Si.", "¿Es tu barriga? Sí."),
                 ("It is your head.", "É a túa cabeza.", "Es tu cabeza."), ("You are big!", "Es grande!", "¡Eres grande!")]),
        11: (2, [("A leaf.", "Unha folla.", "Una hoja."), ("The leaves are falling.", "As follas caen.", "Las hojas caen."),
                 ("Two stones.", "Dúas pedras.", "Dos piedras."), ("A big leaf.", "Unha folla grande.", "Una hoja grande.")]),
        12: (2, [("A bell.", "Unha campá.", "Una campana."), ("The bells ring.", "As campás soan.", "Las campanas suenan."),
                 ("A big hug.", "Unha aperta grande.", "Un abrazo grande."), ("Two small bells.", "Dúas campás pequenas.", "Dos campanas pequeñas.")]),
        1: (2, [("A hat.", "Un gorro.", "Un gorro."), ("The mittens.", "As luvas.", "Las manoplas."),
                ("An apple.", "Unha mazá.", "Una manzana."), ("Two apples.", "Dúas mazás.", "Dos manzanas.")]),
        2: (3, [("This frog.", "Esta ra.", "Esta rana."), ("That cat.", "Ese gato.", "Ese gato."),
                ("This is my bird.", "Este é o meu paxaro.", "Este es mi pájaro."), ("Your frog jumps!", "A túa ra salta!", "¡Tu rana salta!")]),
        3: (3, [("This circle is yellow.", "Este círculo é amarelo.", "Este círculo es amarillo."), ("That is my soap.", "Ese é o meu xabón.", "Ese es mi jabón."),
                ("Your towel.", "A túa toalla.", "Tu toalla."), ("These are my hands.", "Estas son as miñas mans.", "Estas son mis manos.")]),
        4: (4, [("The rain falls.", "A chuvia cae.", "La lluvia cae."), ("The sun comes up.", "Sae o sol.", "Sale el sol."),
                ("We clap.", "Aplaudimos.", "Aplaudimos."), ("It drips.", "Pinga.", "Gotea.")]),
        5: (4, [("We wash our hands.", "Lavamos as mans.", "Nos lavamos las manos."), ("The dog runs.", "O can corre.", "El perro corre."),
                ("The cat sleeps.", "O gato dorme.", "El gato duerme."), ("I dry my toes.", "Seco os dedos dos pés.", "Me seco los dedos de los pies.")]),
        6: (4, [("The waves go up.", "As ondas soben.", "Las olas suben."), ("The fish swims.", "O peixe nada.", "El pez nada."),
                ("We roll the ball.", "Facemos rodar a pelota.", "Hacemos rodar la pelota."), ("The sea moves.", "O mar móvese.", "El mar se mueve.")]),
    },
    "curso_2_3": {
        9: (5, [("We always say hello.", "Sempre dicimos ola.", "Siempre decimos hola."), ("We sometimes splash.", "Ás veces chapuzamos.", "A veces chapoteamos."),
                ("We never push our friends.", "Nunca empurramos aos amigos.", "Nunca empujamos a los amigos."), ("We usually sit in a circle.", "Normalmente sentamos en círculo.", "Normalmente nos sentamos en círculo.")]),
        10: (5, [("We always touch our knees.", "Sempre tocamos os xeonllos.", "Siempre nos tocamos las rodillas."), ("We often dance.", "Bailamos a miúdo.", "Bailamos a menudo."),
                 ("We sometimes freeze.", "Ás veces quedamos quietos.", "A veces nos quedamos quietos."), ("We usually shake our hands.", "Normalmente axitamos as mans.", "Normalmente sacudimos las manos.")]),
        11: (6, [("Some leaves.", "Unhas follas.", "Unas hojas."), ("A lot of stones.", "Moitas pedras.", "Muchas piedras."),
                 ("More leaves, please!", "Máis follas, por favor!", "¡Más hojas, por favor!"), ("How many stones?", "Cantas pedras?", "¿Cuántas piedras?")]),
        12: (6, [("Some bells.", "Unhas campás.", "Unas campanas."), ("A lot of noise!", "Moito ruído!", "¡Mucho ruido!"),
                 ("More quiet, please.", "Máis silencio, por favor.", "Más silencio, por favor."), ("Many bells.", "Moitas campás.", "Muchas campanas.")]),
        1: (6, [("Some bread.", "Un pouco de pan.", "Un poco de pan."), ("Many apples.", "Moitas mazás.", "Muchas manzanas."),
                ("Some puddles.", "Unhas pozas.", "Unos charcos."), ("A lot of boots.", "Moitas botas.", "Muchas botas.")]),
        2: (7, [("There is a bird in the tree.", "Hai un paxaro na árbore.", "Hay un pájaro en el árbol."), ("There are two bears.", "Hai dous osos.", "Hay dos osos."),
                ("The bird is on the branch.", "O paxaro está na póla.", "El pájaro está en la rama."), ("The bear is behind the tree.", "O oso está detrás da árbore.", "El oso está detrás del árbol.")]),
        3: (7, [("There is a red circle on the floor.", "Hai un círculo vermello no chan.", "Hay un círculo rojo en el suelo."), ("The card is under the chair.", "A tarxeta está debaixo da cadeira.", "La tarjeta está debajo de la silla."),
                ("The tomato is in the box.", "O tomate está na caixa.", "El tomate está en la caja."), ("There are two circles.", "Hai dous círculos.", "Hay dos círculos.")]),
        4: (8, [("Where is the sun?", "Onde está o sol?", "¿Dónde está el sol?"), ("What is it? A seed!", "Que é? Unha semente!", "¿Qué es? ¡Una semilla!"),
                ("Who has the flower?", "Quen ten a flor?", "¿Quién tiene la flor?"), ("How big is the flower?", "Que grande é a flor?", "¿Qué tamaño tiene la flor?")]),
        5: (8, [("What do we wash? Our face!", "Que lavamos? A cara!", "¿Qué lavamos? ¡La cara!"), ("Where is the soap?", "Onde está o xabón?", "¿Dónde está el jabón?"),
                ("Who is wet?", "Quen está mollado?", "¿Quién está mojado?"), ("Which towel is yours?", "Cal é a túa toalla?", "¿Cuál es tu toalla?")]),
        6: (8, [("Where is the fish?", "Onde está o peixe?", "¿Dónde está el pez?"), ("What is in the box?", "Que hai na caixa?", "¿Qué hay en la caja?"),
                ("How big are the waves?", "Que grandes son as ondas?", "¿Qué tamaño tienen las olas?"), ("Who has the ball?", "Quen ten a pelota?", "¿Quién tiene la pelota?")]),
    },
    "curso_3_4": {
        9: (9, [("We sit in the circle in the morning.", "Pola mañá sentamos no círculo.", "Por la mañana nos sentamos en el círculo."), ("We clap at nine o'clock.", "Aplaudimos ás nove.", "Aplaudimos a las nueve."),
                ("On Monday we play trains.", "O luns xogamos aos trens.", "El lunes jugamos a los trenes."), ("In the afternoon we sing.", "Pola tarde cantamos.", "Por la tarde cantamos.")]),
        10: (9, [("In autumn the leaves fall.", "No outono caen as follas.", "En otoño caen las hojas."), ("On Friday we blow the leaves.", "O venres sopramos as follas.", "El viernes soplamos las hojas."),
                 ("At night the wind blows.", "Pola noite sopra o vento.", "Por la noche sopla el viento."), ("In October we spin like leaves.", "En outubro xiramos coma follas.", "En octubre giramos como hojas.")]),
        11: (10, [("Jump like a chestnut!", "Salta coma unha castaña!", "¡Salta como una castaña!"), ("Can you help me, please?", "Podes axudarme, por favor?", "¿Me puedes ayudar, por favor?"),
                  ("I can roll the pumpkin.", "Podo facer rodar a cabaza.", "Puedo hacer rodar la calabaza."), ("I can't jump so high.", "Non podo saltar tan alto.", "No puedo saltar tan alto.")]),
        12: (10, [("Put on your boots!", "Pon as botas!", "¡Ponte las botas!"), ("Can you stomp in the snow?", "Podes pisar forte na neve?", "¿Puedes pisar fuerte en la nieve?"),
                  ("Walk on tiptoe!", "Camiña de puntillas!", "¡Anda de puntillas!"), ("I can't find my boot.", "Non atopo a miña bota.", "No encuentro mi bota.")]),
        1: (10, [("Open your umbrella!", "Abre o paraugas!", "¡Abre el paraguas!"), ("Jump over the puddle!", "Salta a poza!", "¡Salta el charco!"),
                 ("Can you tap like the rain?", "Podes petar coma a chuvia?", "¿Puedes dar golpecitos como la lluvia?"), ("I can jump!", "Podo saltar!", "¡Puedo saltar!")]),
        2: (11, [("I am shaking my bells.", "Estou axitando as campás.", "Estoy sacudiendo las campanas."), ("The lion is roaring.", "O león está ruxindo.", "El león está rugiendo."),
                 ("We are playing quietly.", "Estamos xogando en silencio.", "Estamos jugando en silencio."), ("You are eating with a spoon.", "Estás comendo coa culler.", "Estás comiendo con la cuchara.")]),
        3: (11, [("The seed is growing.", "A semente está medrando.", "La semilla está creciendo."), ("We are digging the soil.", "Estamos cavando a terra.", "Estamos cavando la tierra."),
                 ("The sunflower is growing tall.", "O xirasol está medrando alto.", "El girasol está creciendo alto."), ("I am curling up like a seed.", "Estou encollido coma unha semente.", "Estoy encogido como una semilla.")]),
        4: (12, [("The horse was in the field.", "O cabalo estaba no campo.", "El caballo estaba en el campo."), ("The cows were hungry.", "As vacas tiñan fame.", "Las vacas tenían hambre."),
                 ("There was a sheep.", "Había unha ovella.", "Había una oveja."), ("Were you a horse? Yes, I was.", "Eras un cabalo? Si, era.", "¿Eras un caballo? Sí, lo era.")]),
        5: (12, [("It was fun!", "Foi divertido!", "¡Fue divertido!"), ("We were friends.", "Eramos amigos.", "Éramos amigos."),
                 ("There were many claps.", "Houbo moitas palmadas.", "Hubo muchas palmadas."), ("Was it high or low?", "Era alto ou baixo?", "¿Era alto o bajo?")]),
        6: (12, [("The waves were big.", "As ondas eran grandes.", "Las olas eran grandes."), ("There was a white shell.", "Había unha cuncha branca.", "Había una concha blanca."),
                 ("The boat was in the ría.", "O barco estaba na ría.", "El barco estaba en la ría."), ("We were in the boat.", "Estabamos no barco.", "Estábamos en el barco.")]),
    },
    "curso_4_5": {
        9: (13, [("The bell rang.", "Soou a campá.", "Sonó la campana."), ("I packed my backpack.", "Preparei a mochila.", "Preparé la mochila."),
                 ("The bear slept.", "O oso durmiu.", "El oso durmió."), ("Did you hear the bell?", "Escoitaches a campá?", "¿Oíste la campana?")]),
        10: (13, [("The squirrel climbed the tree.", "O esquío subiu á árbore.", "La ardilla subió al árbol."), ("The boar hid.", "O xabaril escondeuse.", "El jabalí se escondió."),
                  ("We found a chestnut.", "Atopamos unha castaña.", "Encontramos una castaña."), ("Did you see the squirrel?", "Viches o esquío?", "¿Viste la ardilla?")]),
        11: (14, [("The chestnut was rolling downhill.", "A castaña ía rodando costa abaixo.", "La castaña iba rodando cuesta abajo."), ("The hedgehog was sleeping when we came.", "O ourizo estaba durmindo cando chegamos.", "El erizo estaba durmiendo cuando llegamos."),
                  ("We were dancing.", "Estabamos bailando.", "Estábamos bailando."), ("While it was rolling, we waited.", "Mentres rodaba, agardamos.", "Mientras rodaba, esperamos.")]),
        12: (14, [("We were playing the drum when the sun came up.", "Estabamos tocando o tambor cando saíu o sol.", "Estábamos tocando el tambor cuando salió el sol."), ("It was snowing at night.", "Pola noite estaba nevando.", "Por la noche estaba nevando."),
                  ("The children were stretching.", "As criaturas estaban estirándose.", "Los niños se estaban estirando."), ("While it was cold, we were inside.", "Mentres facía frío, estabamos dentro.", "Mientras hacía frío, estábamos dentro.")]),
        1: (14, [("It was raining when we went out.", "Estaba chovendo cando saímos.", "Estaba lloviendo cuando salimos."), ("We were running when the storm came.", "Estabamos correndo cando chegou a tormenta.", "Estábamos corriendo cuando llegó la tormenta."),
                 ("The clouds were moving fast.", "As nubes movíanse rápido.", "Las nubes se movían rápido."), ("While it was raining, we hid.", "Mentres chovía, escondémonos.", "Mientras llovía, nos escondimos.")]),
        2: (15, [("The wolf can see you!", "O lobo pódete ver!", "¡El lobo te puede ver!"), ("Look at me!", "Mírame!", "¡Mírame!"),
                 ("Follow him!", "Ségueo!", "¡Síguelo!"), ("The fox is watching us.", "O raposo está mirándonos.", "El zorro nos está mirando.")]),
        3: (15, [("The bee is looking at me.", "A abella está mirándome.", "La abeja me está mirando."), ("Give it to her.", "Dállo a ela.", "Dáselo a ella."),
                 ("I can do it myself.", "Podo facelo eu só.", "Puedo hacerlo yo solo."), ("The flowers are for them.", "As flores son para eles.", "Las flores son para ellos.")]),
        4: (16, [("The wolf is bigger than the sheep.", "O lobo é máis grande ca a ovella.", "El lobo es más grande que la oveja."), ("The sheep is calmer than the wolf.", "A ovella está máis tranquila co lobo.", "La oveja está más tranquila que el lobo."),
                 ("This umbrella is the biggest.", "Este paraugas é o máis grande.", "Este paraguas es el más grande."), ("The wolf is as hungry as a bear.", "O lobo ten tanta fame coma un oso.", "El lobo tiene tanta hambre como un oso.")]),
        5: (16, [("The turnip is bigger than me!", "O nabo é máis grande ca min!", "¡El nabo es más grande que yo!"), ("We are stronger together.", "Xuntos somos máis fortes.", "Juntos somos más fuertes."),
                 ("This rope is the longest.", "Esta corda é a máis longa.", "Esta cuerda es la más larga."), ("He is as brave as a lion.", "É tan valente coma un león.", "Es tan valiente como un león.")]),
        6: (16, [("The sea is calmer today.", "Hoxe o mar está máis tranquilo.", "Hoy el mar está más tranquilo."), ("These waves are bigger than yesterday.", "Estas ondas son máis grandes ca onte.", "Estas olas son más grandes que ayer."),
                 ("The blue fish is the fastest.", "O peixe azul é o máis rápido.", "El pez azul es el más rápido."), ("The sea is as blue as the sky.", "O mar é tan azul coma o ceo.", "El mar es tan azul como el cielo.")]),
    },
    "curso_5_6": {
        9: (17, [("I am going to hang my coat.", "Vou colgar o abrigo.", "Voy a colgar el abrigo."), ("I will help you.", "Eu axúdote.", "Yo te ayudo."),
                 ("We are going to paint.", "Imos pintar.", "Vamos a pintar."), ("It is going to be a good day.", "Vai ser un bo día.", "Va a ser un buen día.")]),
        10: (17, [("We are going to count the leaves.", "Imos contar as follas.", "Vamos a contar las hojas."), ("I will jump into the hoop.", "Vou saltar dentro do aro.", "Saltaré dentro del aro."),
                  ("We are going to cut paper.", "Imos cortar papel.", "Vamos a cortar papel."), ("It will be fun.", "Vai ser divertido.", "Será divertido.")]),
        11: (18, [("You must feel without looking.", "Tes que tocar sen mirar.", "Tienes que tocar sin mirar."), ("We have to share.", "Temos que compartir.", "Tenemos que compartir."),
                  ("You should wait your turn.", "Deberías agardar a túa quenda.", "Deberías esperar tu turno."), ("You don't have to hurry.", "Non fai falta ter présa.", "No hace falta tener prisa.")]),
        12: (18, [("You must walk slowly.", "Tes que camiñar amodo.", "Tienes que andar despacio."), ("We have to hold hands.", "Temos que ir da man.", "Tenemos que ir de la mano."),
                  ("You shouldn't touch the candle.", "Non deberías tocar a vela.", "No deberías tocar la vela."), ("You should turn left.", "Deberías xirar á esquerda.", "Deberías girar a la izquierda.")]),
        1: (18, [("You have to balance the plate.", "Tes que manter o prato en equilibrio.", "Tienes que mantener el plato en equilibrio."), ("You must not spill the water.", "Non podes derramar a auga.", "No puedes derramar el agua."),
                 ("You don't have to run.", "Non fai falta correr.", "No hace falta correr."), ("You should step slowly.", "Deberías pisar amodo.", "Deberías pisar despacio.")]),
        2: (19, [("Walk across the room.", "Cruza a sala.", "Cruza la sala."), ("Jump into the circle.", "Salta dentro do círculo.", "Salta dentro del círculo."),
                 ("Go out of the box.", "Sae da caixa.", "Sal de la caja."), ("Move towards me.", "Móvete cara a min.", "Muévete hacia mí.")]),
        3: (19, [("Put the seed into the pot.", "Mete a semente no testo.", "Mete la semilla en la maceta."), ("The water goes through the soil.", "A auga pasa a través da terra.", "El agua pasa a través de la tierra."),
                 ("Walk along the garden.", "Camiña polo xardín.", "Camina por el jardín."), ("Take it out of the box.", "Sácao da caixa.", "Sácalo de la caja.")]),
        4: (20, [("We hide because the fox is coming.", "Escondémonos porque vén o raposo.", "Nos escondemos porque viene el zorro."), ("The snake crawls, but it doesn't bite.", "A serpe arrástrase, pero non morde.", "La serpiente se arrastra, pero no muerde."),
                 ("It is dark, so we use a lamp.", "Está escuro, así que usamos unha lámpada.", "Está oscuro, así que usamos una lámpara."), ("Although it is pointy, it is safe.", "Aínda que ten punta, é seguro.", "Aunque tiene punta, es seguro.")]),
        5: (20, [("Clap and tap!", "Aplaude e peta!", "¡Aplaude y golpea!"), ("It is fast, but I can do it.", "É rápido, pero podo facelo.", "Es rápido, pero puedo hacerlo."),
                 ("I like it because it is a pattern.", "Gústame porque é un patrón.", "Me gusta porque es un patrón."), ("Although it is difficult, we try.", "Aínda que é difícil, intentámolo.", "Aunque es difícil, lo intentamos.")]),
        6: (20, [("The shell is smooth, so it goes in the basket.", "A cuncha é lisa, así que vai na cesta.", "La concha es lisa, así que va en la cesta."), ("We look for shells and we count them.", "Buscamos cunchas e contámolas.", "Buscamos conchas y las contamos."),
                 ("I want this shell because it is white.", "Quero esta cuncha porque é branca.", "Quiero esta concha porque es blanca."), ("Although it is small, it is beautiful.", "Aínda que é pequena, é bonita.", "Aunque es pequeña, es bonita.")]),
    },
}

# El curso empieza en septiembre: el mes del curso → el mes del calendario.
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]


# O-20261028-9 (Frank): las 48 unidades son para las criaturas, una por mes.
from ruta_48 import PARA_FAMILIAS, RUTA as RUTA_48  # noqa: E402


def construir():
    puntos = []
    for n, (niv, tgl, tes, dgl, des, fgl, fes) in PUNTOS.items():
        p = {"n": n, "nivel": niv, "titulo": {"gl": tgl, "es": tes},
             "descricion": {"gl": dgl, "es": des},
             "paraCriaturas": True}
        if not fgl and n in PARA_FAMILIAS:
            fgl, fes = PARA_FAMILIAS[n]
        if fgl:
            p["paraFamilias"] = {"gl": fgl, "es": fes}
        if n in EXEMPLO_ADULTO:
            en, gl, es = EXEMPLO_ADULTO[n]
            p["exemplo"] = {"en": en, "gl": gl, "es": es}
        puntos.append(p)
    ruta = {}
    for curso, meses in RUTA_48.items():
        ruta[curso] = {}
        for mes in MESES:
            punto, frases = meses[mes]
            ruta[curso][str(mes)] = {
                "punto": punto,
                "frases": [{"en": en, "gl": gl, "es": es} for en, gl, es in frases],
            }
    return {"_doc": "Generado por tools/gen_gramatica.py; no se edita a mano.",
            "puntos": puntos, "ruta": ruta}


def revisar(d):
    fallos = []
    usados = {m["punto"] for c in d["ruta"].values() for m in c.values()}
    for n in range(1, 49):
        if n not in usados:
            fallos.append(f"el punto {n} no está en ninguna edad")
    for c, ms in d["ruta"].items():
        if len(ms) != 10:
            fallos.append(f"{c}: {len(ms)} meses")
        for m, x in ms.items():
            if len(x["frases"]) != 4:
                fallos.append(f"{c} {m}: {len(x['frases'])} frases")
    # Progresión real: a lo largo de los 50 meses, de 0-2 en septiembre a
    # 5-6 en junio, la unidad nunca vuelve atrás.
    seq = [d["ruta"][c][str(m)]["punto"] for c in RUTA_48 for m in MESES]
    atras = [(i, a, b) for i, (a, b) in enumerate(zip(seq, seq[1:])) if b < a]
    if atras:
        fallos.append(f"la columna vuelve atrás {len(atras)} veces: {atras[:5]}")
    return fallos


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    a = ap.parse_args()
    d = construir()
    fallos = revisar(d)
    if fallos:
        print("FALLO:\n  " + "\n  ".join(fallos))
        return 1
    texto = json.dumps(d, ensure_ascii=False, indent=1) + "\n"
    if a.check:
        if not SAIDA.exists() or SAIDA.read_text() != texto:
            print("FALLO: gramatica.json no está al día (python3 tools/gen_gramatica.py)")
            return 1
        print("OK: gramática al día; las 48 unidades, en orden, en las cinco edades.")
        return 0
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    SAIDA.write_text(texto)
    print("OK: 48 puntos; 50 unidades con su punto y cuatro frases.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
