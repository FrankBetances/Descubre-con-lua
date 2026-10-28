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

# La columna de las cinco edades: curso → mes → (punto, cuatro frases).
# Cada frase usa las palabras de la unidad de ese mes.
RUTA = {
    "curso_0_2": {
        9: (10, [("Clap!", "Aplaude!", "¡Aplaude!"), ("Splash!", "Chapuza!", "¡Chapotea!"),
                 ("Come up!", "Arriba!", "¡Arriba!"), ("Wave hello!", "Di ola coa man!", "¡Di hola con la mano!")]),
        10: (10, [("Touch your head!", "Toca a cabeza!", "¡Tócate la cabeza!"), ("Wiggle your toes!", "Move os dedos dos pés!", "¡Mueve los dedos de los pies!"),
                  ("Stop!", "Para!", "¡Para!"), ("Touch your tummy!", "Toca a barriguiña!", "¡Tócate la barriguita!")]),
        11: (2, [("A leaf.", "Unha folla.", "Una hoja."), ("The leaf is falling.", "A folla está caendo.", "La hoja se está cayendo."),
                 ("Leaves!", "Follas!", "¡Hojas!"), ("A stone.", "Unha pedra.", "Una piedra.")]),
        12: (3, [("This bell.", "Esta campá.", "Esta campana."), ("That bell is big.", "Esa campá é grande.", "Esa campana es grande."),
                 ("This hug is warm.", "Esta aperta é quentiña.", "Este abrazo es calentito."), ("That bell is small.", "Esa campá é pequena.", "Esa campana es pequeña.")]),
        1: (3, [("My hat.", "O meu gorro.", "Mi gorro."), ("Your hat.", "O teu gorro.", "Tu gorro."),
                ("My mittens.", "As miñas luvas.", "Mis manoplas."), ("Your apple.", "A túa mazá.", "Tu manzana.")]),
        2: (2, [("A frog.", "Unha ra.", "Una rana."), ("Two cats.", "Dous gatos.", "Dos gatos."),
                ("The bird says tweet.", "O paxaro di chío.", "El pájaro dice pío."), ("Frogs jump!", "As ras saltan!", "¡Las ranas saltan!")]),
        3: (7, [("The soap is in the water.", "O xabón está na auga.", "El jabón está en el agua."), ("The towel is on the chair.", "A toalla está na cadeira.", "La toalla está en la silla."),
                ("The circle is on the floor.", "O círculo está no chan.", "El círculo está en el suelo."), ("The ball is in the box.", "A pelota está na caixa.", "La pelota está en la caja.")]),
        4: (7, [("There is a drop!", "Hai unha pinga!", "¡Hay una gota!"), ("There is the sun!", "Aí está o sol!", "¡Ahí está el sol!"),
                ("There are drops on the window.", "Hai pingas na ventá.", "Hay gotas en la ventana."), ("There is rain!", "Hai chuvia!", "¡Hay lluvia!")]),
        5: (3, [("This is my soap.", "Este é o meu xabón.", "Este es mi jabón."), ("This is your towel.", "Esta é a túa toalla.", "Esta es tu toalla."),
                ("My clean hands!", "As miñas mans limpas!", "¡Mis manos limpias!"), ("Your dog.", "O teu can.", "Tu perro.")]),
        6: (7, [("The fish is in the sea.", "O peixe está no mar.", "El pez está en el mar."), ("The ball is in the box.", "A pelota está na caixa.", "La pelota está en la caja."),
                ("There is a wave!", "Hai unha onda!", "¡Hay una ola!"), ("The boat is on the water.", "O barco está na auga.", "El barco está en el agua.")]),
    },
    "curso_2_3": {
        9: (1, [("I am Lúa.", "Eu son Lúa.", "Yo soy Lúa."), ("You are my friend.", "Ti es o meu amigo.", "Tú eres mi amigo."),
                ("It is water.", "É auga.", "Es agua."), ("I am wet!", "Estou mollado!", "¡Estoy mojado!")]),
        10: (10, [("Touch your knees!", "Toca os xeonllos!", "¡Tócate las rodillas!"), ("Shake your hands!", "Axita as mans!", "¡Sacude las manos!"),
                  ("Freeze!", "Estátua!", "¡Estatua!"), ("Dance and freeze!", "Baila e queda quieto!", "¡Baila y quédate quieto!")]),
        11: (2, [("A leaf, two leaves.", "Unha folla, dúas follas.", "Una hoja, dos hojas."), ("The leaves are crunchy.", "As follas fan cruc.", "Las hojas crujen."),
                 ("Three stones.", "Tres pedras.", "Tres piedras."), ("The wind is blowing.", "Sopra o vento.", "Sopla el viento.")]),
        12: (1, [("It is loud!", "Soa forte!", "¡Suena fuerte!"), ("It isn't loud. It is quiet.", "Non soa forte. Soa baixiño.", "No suena fuerte. Suena bajito."),
                 ("Is it big?", "É grande?", "¿Es grande?"), ("The baby is sleeping. Shh!", "O bebé está durmindo. Shh!", "El bebé está durmiendo. ¡Shh!")]),
        1: (3, [("My coat.", "O meu abrigo.", "Mi abrigo."), ("Your boots.", "As túas botas.", "Tus botas."),
                ("This is my apple.", "Esta é a miña mazá.", "Esta es mi manzana."), ("Mum's coat.", "O abrigo de mamá.", "El abrigo de mamá.")]),
        2: (10, [("I can fly like a bird!", "Podo voar coma un paxaro!", "¡Puedo volar como un pájaro!"), ("Can you stomp like a bear?", "Podes pisar forte coma un oso?", "¿Puedes pisar fuerte como un oso?"),
                 ("I can't fly!", "Non podo voar!", "¡No puedo volar!"), ("Flap your wings!", "Bate as ás!", "¡Bate las alas!")]),
        3: (3, [("This circle is red.", "Este círculo é vermello.", "Este círculo es rojo."), ("That card is red.", "Esa tarxeta é vermella.", "Esa tarjeta es roja."),
                ("These tomatoes are red.", "Estes tomates son vermellos.", "Estos tomates son rojos."), ("My towel.", "A miña toalla.", "Mi toalla.")]),
        4: (8, [("Where is the sun?", "Onde está o sol?", "¿Dónde está el sol?"), ("What is it? A seed!", "Que é? Unha semente!", "¿Qué es? ¡Una semilla!"),
                ("Where are the flowers?", "Onde están as flores?", "¿Dónde están las flores?"), ("What is soft?", "Que é suave?", "¿Qué es suave?")]),
        5: (6, [("Some soap.", "Un pouco de xabón.", "Un poco de jabón."), ("More water!", "Máis auga!", "¡Más agua!"),
                ("A lot of bubbles!", "Moitas burbullas!", "¡Muchas burbujas!"), ("Some water on your face.", "Un pouco de auga na cara.", "Un poco de agua en la cara.")]),
        6: (7, [("The fish is under the sea.", "O peixe está debaixo do mar.", "El pez está debajo del mar."), ("The ball is in the box.", "A pelota está na caixa.", "La pelota está en la caja."),
                ("The box is next to the ball.", "A caixa está ao lado da pelota.", "La caja está al lado de la pelota."), ("There are big waves!", "Hai ondas grandes!", "¡Hay olas grandes!")]),
    },
    "curso_3_4": {
        9: (4, [("We sit in a circle.", "Sentamos en círculo.", "Nos sentamos en círculo."), ("We clap our hands.", "Aplaudimos.", "Aplaudimos."),
                ("I say hello.", "Eu digo ola.", "Yo digo hola."), ("The train goes round.", "O tren dá voltas.", "El tren da vueltas.")]),
        10: (7, [("The leaf is on the floor.", "A folla está no chan.", "La hoja está en el suelo."), ("Put the leaf under the cloth.", "Pon a folla debaixo da tela.", "Pon la hoja debajo de la tela."),
                 ("The leaf is in my hand.", "A folla está na miña man.", "La hoja está en mi mano."), ("Your turn!", "Tócache a ti!", "¡Te toca!")]),
        11: (10, [("I can jump!", "Podo saltar!", "¡Puedo saltar!"), ("Can you help me, please?", "Podes axudarme, por favor?", "¿Me puedes ayudar, por favor?"),
                  ("Roll the pumpkin!", "Fai rodar a cabaza!", "¡Haz rodar la calabaza!"), ("I can't jump so high.", "Non podo saltar tan alto.", "No puedo saltar tan alto.")]),
        12: (5, [("We always put on our boots.", "Sempre poñemos as botas.", "Siempre nos ponemos las botas."), ("It sometimes snows.", "Ás veces neva.", "A veces nieva."),
                 ("We never stomp on a friend.", "Nunca pisamos a un amigo.", "Nunca pisamos a un amigo."), ("We usually walk on tiptoe.", "Normalmente camiñamos de puntillas.", "Normalmente andamos de puntillas.")]),
        1: (11, [("It is raining.", "Está chovendo.", "Está lloviendo."), ("We are jumping over the puddle.", "Estamos saltando o charco.", "Estamos saltando el charco."),
                 ("I am opening my umbrella.", "Estou abrindo o paraugas.", "Estoy abriendo el paraguas."), ("The rain is falling fast.", "A chuvia está caendo rápido.", "La lluvia está cayendo rápido.")]),
        2: (6, [("Some juice, please.", "Un pouco de zume, por favor.", "Un poco de zumo, por favor."), ("More bread!", "Máis pan!", "¡Más pan!"),
                ("A full plate.", "Un prato cheo.", "Un plato lleno."), ("A lot of noise!", "Moito ruído!", "¡Mucho ruido!")]),
        3: (4, [("The seed grows.", "A semente medra.", "La semilla crece."), ("The sunflower grows tall.", "O xirasol medra alto.", "El girasol crece alto."),
                ("We dig the soil.", "Cavamos a terra.", "Cavamos la tierra."), ("Does the seed need water?", "A semente precisa auga?", "¿La semilla necesita agua?")]),
        4: (8, [("Who is it? A horse!", "Quen é? Un cabalo!", "¿Quién es? ¡Un caballo!"), ("What does the cow say?", "Que di a vaca?", "¿Qué dice la vaca?"),
                ("How does the horse walk?", "Como anda o cabalo?", "¿Cómo anda el caballo?"), ("Where is the sheep?", "Onde está a ovella?", "¿Dónde está la oveja?")]),
        5: (9, [("We clap in the morning.", "Aplaudimos pola mañá.", "Aplaudimos por la mañana."), ("We sing on Monday.", "Cantamos o luns.", "Cantamos el lunes."),
                ("We sleep at night.", "Durmimos pola noite.", "Dormimos por la noche."), ("Clap high, clap low!", "Aplaude arriba, aplaude abaixo!", "¡Aplaude arriba, aplaude abajo!")]),
        6: (19, [("Row the boat through the waves.", "Rema o barco entre as ondas.", "Rema el barco entre las olas."), ("Get into the boat.", "Entra no barco.", "Sube al barco."),
                 ("Swim to the shell.", "Nada ata a cuncha.", "Nada hasta la concha."), ("Get out of the water.", "Sae da auga.", "Sal del agua.")]),
    },
    "curso_4_5": {
        9: (11, [("The bear is sleeping.", "O oso está durmindo.", "El oso está durmiendo."), ("Bears sleep in winter.", "Os osos dormen no inverno.", "Los osos duermen en invierno."),
                 ("I am carrying my backpack.", "Levo a mochila.", "Llevo la mochila."), ("The bell is ringing!", "Está soando a campá!", "¡Está sonando la campana!")]),
        10: (12, [("The squirrel was in the tree.", "O esquío estaba na árbore.", "La ardilla estaba en el árbol."), ("There was a boar in the forest.", "Había un xabaril no bosque.", "Había un jabalí en el bosque."),
                  ("The chestnuts were on the ground.", "As castañas estaban no chan.", "Las castañas estaban en el suelo."), ("Was it hiding?", "Estaba escondido?", "¿Estaba escondido?")]),
        11: (13, [("The chestnut rolled downhill.", "A castaña rodou costa abaixo.", "La castaña rodó cuesta abajo."), ("The hedgehog curled into a ball.", "O ourizo fíxose unha bóla.", "El erizo se hizo una bola."),
                  ("We danced together.", "Bailamos xuntos.", "Bailamos juntos."), ("Did it hurt? Yes, it did.", "Doeulle? Si.", "¿Le dolió? Sí.")]),
        12: (13, [("It was cold last night.", "Onte pola noite facía frío.", "Anoche hacía frío."), ("The sun went down.", "Púxose o sol.", "Se puso el sol."),
                  ("We played the drum.", "Tocamos o tambor.", "Tocamos el tambor."), ("The pond froze.", "Xeou a charca.", "Se heló la charca.")]),
        1: (20, [("We run because the storm is here.", "Corremos porque chegou a tormenta.", "Corremos porque ha llegado la tormenta."), ("It is cloudy, so we take the umbrella.", "Está nubrado, así que levamos o paraugas.", "Está nublado, así que llevamos el paraguas."),
                 ("We hide under the umbrella because it is raining.", "Escondémonos baixo o paraugas porque chove.", "Nos escondemos bajo el paraguas porque llueve."), ("I am wet, but I am happy.", "Estou mollado, pero estou contento.", "Estoy mojado, pero estoy contento.")]),
        2: (15, [("The wolf can see you!", "O lobo pódete ver!", "¡El lobo te puede ver!"), ("Look at me: I am a horse.", "Mírame: son un cabalo.", "Mírame: soy un caballo."),
                 ("Follow him!", "Ségueo!", "¡Síguelo!"), ("The fox is watching us.", "O raposo está mirándonos.", "El zorro nos está mirando.")]),
        3: (16, [("The honey is sweeter than the apple.", "O mel é máis doce ca a mazá.", "La miel es más dulce que la manzana."), ("This flower is bigger.", "Esta flor é máis grande.", "Esta flor es más grande."),
                 ("The bee is as small as my finger.", "A abella é tan pequena coma o meu dedo.", "La abeja es tan pequeña como mi dedo."), ("The red flower is the biggest.", "A flor vermella é a máis grande.", "La flor roja es la más grande.")]),
        4: (14, [("The wolf was sleeping when the sheep came.", "O lobo estaba durmindo cando chegou a ovella.", "El lobo estaba durmiendo cuando llegó la oveja."), ("We were walking calmly.", "Estabamos camiñando con calma.", "Estábamos andando con calma."),
                 ("It was raining when we went out.", "Estaba chovendo cando saímos.", "Estaba lloviendo cuando salimos."), ("While the wolf was sleeping, we walked on tiptoe.", "Mentres o lobo durmía, camiñamos de puntillas.", "Mientras el lobo dormía, andamos de puntillas.")]),
        5: (20, [("We pull and pull, but it doesn't move.", "Tiramos e tiramos, pero non se move.", "Tiramos y tiramos, pero no se mueve."), ("We help, so it comes out.", "Axudamos, así que sae.", "Ayudamos, así que sale."),
                 ("It is heavy because it is enormous.", "Pesa porque é enorme.", "Pesa porque es enorme."), ("Pull and help!", "Tira e axuda!", "¡Tira y ayuda!")]),
        6: (17, [("We are going to swim in the sea.", "Imos nadar no mar.", "Vamos a nadar en el mar."), ("Look at the clouds: it is going to rain.", "Mira as nubes: vai chover.", "Mira las nubes: va a llover."),
                 ("I will help you.", "Eu axúdote.", "Yo te ayudo."), ("The sea will be calm.", "O mar estará en calma.", "El mar estará en calma.")]),
    },
    "curso_5_6": {
        9: (15, [("I hang my coat myself.", "Colgo o abrigo eu só.", "Cuelgo el abrigo yo solo."), ("Help her, please.", "Axúdaa, por favor.", "Ayúdala, por favor."),
                 ("I can do it myself.", "Podo facelo eu só.", "Puedo hacerlo yo solo."), ("Give me the green card.", "Dáme a tarxeta verde.", "Dame la tarjeta verde.")]),
        10: (16, [("This leaf is rougher than that one.", "Esta folla é máis áspera ca esa.", "Esta hoja es más áspera que esa."), ("The smoothest leaf goes in the hoop.", "A folla máis lisa vai no aro.", "La hoja más lisa va en el aro."),
                  ("My leaf is as brown as yours.", "A miña folla é tan marrón coma a túa.", "Mi hoja es tan marrón como la tuya."), ("This hoop is the biggest.", "Este aro é o máis grande.", "Este aro es el más grande.")]),
        11: (20, [("It is round, so it is a chestnut.", "É redonda, así que é unha castaña.", "Es redonda, así que es una castaña."), ("It is cold, but it isn't wet.", "Está fría, pero non está mollada.", "Está fría, pero no está mojada."),
                  ("Although I can't see it, I can feel it.", "Aínda que non a vexo, podo tocala.", "Aunque no la veo, la puedo tocar."), ("We share because it is fair.", "Compartimos porque é xusto.", "Compartimos porque es justo.")]),
        12: (19, [("Walk across the room.", "Cruza a sala.", "Cruza la sala."), ("Turn left and walk towards the light.", "Xira á esquerda e camiña cara á luz.", "Gira a la izquierda y camina hacia la luz."),
                  ("Walk along the line, hand in hand.", "Camiña pola liña, da man.", "Camina por la línea, de la mano."), ("Go out of the circle slowly.", "Sae do círculo amodo.", "Sal del círculo despacio.")]),
        1: (18, [("You must walk slowly.", "Tes que camiñar amodo.", "Tienes que andar despacio."), ("You have to balance the plate.", "Tes que manter o prato en equilibrio.", "Tienes que mantener el plato en equilibrio."),
                 ("You don't have to run.", "Non fai falta correr.", "No hace falta correr."), ("You shouldn't spill the water.", "Non deberías derramar a auga.", "No deberías derramar el agua.")]),
        2: (17, [("I am going to be a statue.", "Vou ser unha estatua.", "Voy a ser una estatua."), ("I will copy your movements.", "Vou copiar os teus movementos.", "Copiaré tus movimientos."),
                 ("We are going to put on our costumes.", "Imos poñer os disfraces.", "Vamos a ponernos los disfraces."), ("I will put my arms up.", "Vou poñer os brazos arriba.", "Pondré los brazos arriba.")]),
        3: (14, [("I was filling the pot when the seed fell.", "Estaba enchendo o testo cando caeu a semente.", "Estaba llenando la maceta cuando se cayó la semilla."), ("We were watering the plants.", "Estabamos regando as plantas.", "Estábamos regando las plantas."),
                 ("While she was digging, I was singing.", "Mentres ela cavaba, eu cantaba.", "Mientras ella cavaba, yo cantaba."), ("The seed was growing in the soil.", "A semente estaba medrando na terra.", "La semilla estaba creciendo en la tierra.")]),
        4: (18, [("You should hide behind the tree.", "Deberías esconderte detrás da árbore.", "Deberías esconderte detrás del árbol."), ("You must fasten your seatbelt.", "Tes que pór o cinto.", "Tienes que ponerte el cinturón."),
                 ("We have to crawl like a snake.", "Temos que arrastrarnos coma unha serpe.", "Tenemos que arrastrarnos como una serpiente."), ("You shouldn't touch the pointy stick.", "Non deberías tocar o pau con punta.", "No deberías tocar el palo con punta.")]),
        5: (16, [("Clap faster!", "Aplaude máis rápido!", "¡Aplaude más rápido!"), ("Now tap slower than before.", "Agora toca máis amodo ca antes.", "Ahora toca más despacio que antes."),
                 ("My pattern is longer than yours.", "O meu patrón é máis longo co teu.", "Mi patrón es más largo que el tuyo."), ("This is the fastest rhythm.", "Este é o ritmo máis rápido.", "Este es el ritmo más rápido.")]),
        6: (17, [("We are going to find shells.", "Imos atopar cunchas.", "Vamos a encontrar conchas."), ("I will walk five steps.", "Vou dar cinco pasos.", "Daré cinco pasos."),
                 ("The tide is going to come in.", "Vai subir a marea.", "Va a subir la marea."), ("I will put the white shell in the basket.", "Vou pór a cuncha branca na cesta.", "Pondré la concha blanca en la cesta.")]),
    },
}

# El curso empieza en septiembre: el mes del curso → el mes del calendario.
MESES = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]


def construir():
    puntos = []
    for n, (niv, tgl, tes, dgl, des, fgl, fes) in PUNTOS.items():
        p = {"n": n, "nivel": niv, "titulo": {"gl": tgl, "es": tes},
             "descricion": {"gl": dgl, "es": des},
             "paraCriaturas": n <= 20}
        if fgl:
            p["paraFamilias"] = {"gl": fgl, "es": fes}
        if n in EXEMPLO_ADULTO:
            en, gl, es = EXEMPLO_ADULTO[n]
            p["exemplo"] = {"en": en, "gl": gl, "es": es}
        puntos.append(p)
    ruta = {}
    for curso, meses in RUTA.items():
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
    for n in range(1, 21):
        if n not in usados:
            fallos.append(f"el punto {n} no está en ninguna edad")
    for c, ms in d["ruta"].items():
        if len(ms) != 10:
            fallos.append(f"{c}: {len(ms)} meses")
        for m, x in ms.items():
            if x["punto"] > 20:
                fallos.append(f"{c} {m}: punto {x['punto']} no es A1-A2")
            if len(x["frases"]) != 4:
                fallos.append(f"{c} {m}: {len(x['frases'])} frases")
    # La columna no retrocede: el punto más alto de cada edad es al menos el
    # de la anterior. (La media no sirve: el imperativo es el punto 10 y es lo
    # primero que se trabaja en 0-2.)
    techos = [max(x["punto"] for x in d["ruta"][c].values()) for c in RUTA]
    if techos != sorted(techos):
        fallos.append(f"la columna baja de una edad a la siguiente: {techos}")
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
        print("OK: gramática al día; 48 puntos, los 20 de A1-A2 en las cinco edades.")
        return 0
    SAIDA.parent.mkdir(parents=True, exist_ok=True)
    SAIDA.write_text(texto)
    print("OK: 48 puntos; 50 unidades con su punto y cuatro frases.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
