#!/usr/bin/env python3
"""Genera las 20 microcápsulas del 1.º ciclo: 10 meses x 2 tramos (0-2 y 2-3).

La fuente es el documento curricular del primer ciclo, que para cada mes
describe DOS dinámicas distintas —una para lactantes de 0 a 2 años y otra para
el aula de 2 a 3—. Esa es la progresión escalonada del ciclo: no es la misma
sesión repetida, es una por tramo.

Regla de honestidad de este fichero: **solo se escribe lo que el documento
dice**. Las canciones, los materiales y los comandos en inglés son los que el
documento nombra, literalmente. Donde el documento no especifica algo, el campo
va vacío; no se rellena a ojo. Por eso no hay micro-rutina de hogar ni criterios
de evaluación por mes: el documento del primer ciclo no los da, y ponerlos
sería inventarse el currículo.

Estructura de las cuatro fases, con las duraciones del documento
(«8 a 10 minutos» en total):

  1. Apertura y Saludo        1-2 min ->  90 s
  2. Enfoque y Fingerplay       2 min -> 120 s
  3. Núcleo TPR Temático      3-4 min -> 210 s
  4. Calma y Despedida        1-2 min ->  90 s
"""

import json
import os

SALIDA = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
    "assets", "content", "asambleas_primeiro_ciclo",
)

TRAMOS = {
    "0_2": {"clave": "0_2", "slug": "0_2_anos"},
    "2_3": {"clave": "2_3", "slug": "2_3_anos"},
}

MESES = {
    9: ("setembro", "Setembro", "Septiembre", "September"),
    10: ("outubro", "Outubro", "Octubre", "October"),
    11: ("novembro", "Novembro", "Noviembre", "November"),
    12: ("decembro", "Decembro", "Diciembre", "December"),
    1: ("xaneiro", "Xaneiro", "Enero", "January"),
    2: ("febreiro", "Febreiro", "Febrero", "February"),
    3: ("marzo", "Marzo", "Marzo", "March"),
    4: ("abril", "Abril", "Abril", "April"),
    5: ("maio", "Maio", "Mayo", "May"),
    6: ("xuno", "Xuño", "Junio", "June"),
}


def t(gl, es, en):
    return {"gl": gl, "es": es, "en": en}


# Cada entrada: el mes, su centro de interés, y las dos dinámicas del documento.
CURSO = [
    {
        "mes": 9,
        "titulo": t(
            "Setembro: acollida, caricias suaves e novas amizades",
            "Septiembre: acogida, caricias suaves y nuevas amistades",
            "September: Welcome, Gentle Touches and New Friends",
        ),
        "centro": t(
            "A acollida e o vínculo afectivo co grupo",
            "La acogida y el vínculo afectivo con el grupo",
            "Welcome and building a safe bond with the group",
        ),
        "0_2": {
            "material": t("Monicreque brando de feltro", "Muñeco blando de fieltro", "Soft felt doll"),
            "cancion": "Up and Down, Clap Clap Clap",
            "apertura": t(
                "Reúne aos bebés sobre colchonetas brandas e achega o monicreque a cada un.",
                "Reúne a los bebés sobre colchonetas mullidas y acerca el muñeco a cada uno.",
                "Gather the babies on soft mats and bring the doll close to each one.",
            ),
            "fingerplay": t(
                "Sostén as mans do bebé e entoa a canción mirándoo aos ollos.",
                "Sostén las manos del bebé y entona la canción mirándolo a los ojos.",
                "Hold the baby's hands and sing while keeping eye contact.",
            ),
            "calma": t(
                "Caricias no torso e susurro prosódico ata que baixe o ritmo.",
                "Caricias en el torso y susurro prosódico hasta que baje el ritmo.",
                "Stroke the chest and whisper softly until the pace slows down.",
            ),
            "comandos": [
                ("Up", t("Eleva as mans do bebé cara arriba.", "Eleva las manos del bebé hacia arriba.", "Lift the baby's hands upwards.")),
                ("Down", t("Baixa as mans e apóiaas nos seus muslos.", "Baja las manos y apóyalas en sus muslos.", "Lower the hands and rest them on the thighs.")),
                ("Clap", t("Guía dúas palmadas lentas.", "Guía dos palmadas lentas.", "Guide two slow claps.")),
            ],
        },
        "2_3": {
            "material": t("Cinta elástica ancha forrada de veludo", "Cinta elástica ancha forrada de terciopelo", "Wide velvet-covered elastic band"),
            "cancion": "Hello Hello, Hello to You!",
            "apertura": t(
                "Sentados en roda, todos suxeitan a cinta elástica coas dúas mans.",
                "Sentados en rueda, todos sujetan la cinta elástica con las dos manos.",
                "Sitting in a ring, everyone holds the elastic band with both hands.",
            ),
            "fingerplay": t(
                "Canta a canción marcando o pulso coa cinta, sen pedir que repitan.",
                "Canta la canción marcando el pulso con la cinta, sin pedir que repitan.",
                "Sing the song marking the beat with the band, never asking them to repeat.",
            ),
            "calma": t(
                "Sentar con coidado sobre a alfombra e soltar a cinta amodo.",
                "Sentarse con cuidado sobre la alfombra y soltar la cinta despacio.",
                "Sit down carefully on the rug and release the band slowly.",
            ),
            "comandos": [
                ("Everybody stand up!", t("Tracción suave da cinta para erguerse á vez.", "Tracción suave de la cinta para levantarse a la vez.", "Gentle pull on the band so everyone stands up together.")),
                ("Hello!", t("Traslado do peso dun pé ao outro.", "Traslado del peso de un pie al otro.", "Shift the body weight from one foot to the other.")),
                ("Everybody sit down!", t("Sentarse con coidado sobre a alfombra.", "Sentarse con cuidado sobre la alfombra.", "Sit down carefully on the rug.")),
            ],
        },
    },
    {
        "mes": 10,
        "titulo": t(
            "Outubro: o meu corpiño en movemento",
            "Octubre: mi cuerpecito en movimiento",
            "October: My Little Body in Motion",
        ),
        "centro": t(
            "A conciencia do propio corpo e a propiocepción",
            "La conciencia del propio cuerpo y la propiocepción",
            "Body awareness and proprioception",
        ),
        "0_2": {
            "material": t("Plumas de avestruz de cores claras", "Plumas de avestruz de colores claros", "Light-coloured ostrich feathers"),
            "cancion": "One Little Finger",
            "apertura": t(
                "Deita aos bebés de costas ou sostenos no regazo.",
                "Recuesta a los bebés de espaldas o sostenlos en el regazo.",
                "Lay the babies on their backs or hold them in your lap.",
            ),
            "fingerplay": t(
                "Rozar as partes do corpo coa pluma ao son da canción.",
                "Rozar las partes del cuerpo con la pluma al son de la canción.",
                "Brush body parts with the feather along with the song.",
            ),
            "calma": t(
                "Retira a pluma e deixa a man aberta e quieta sobre a barriga.",
                "Retira la pluma y deja la mano abierta y quieta sobre la tripa.",
                "Put the feather away and rest an open, still hand on the tummy.",
            ),
            "comandos": [
                ("Head", t("Roza suavemente a coroniña.", "Roza suavemente la coronilla.", "Gently brush the top of the head.")),
                ("Tummy", t("Acaricia a barriga con movementos circulares.", "Acaricia la tripita con movimientos circulares.", "Stroke the tummy in circles.")),
                ("Toes", t("Lixeiro cóxegas nos dedos dos pés.", "Leve cosquilleo en los dedos de los pies.", "A light tickle on the toes.")),
            ],
        },
        "2_3": {
            "material": t("Sen material: só o corpo", "Sin material: solo el cuerpo", "No materials: the body alone"),
            "cancion": "Head, Shoulders, Knees and Toes",
            "apertura": t(
                "En pé, en círculo aberto, coas mans libres.",
                "De pie, en círculo abierto, con las manos libres.",
                "Standing in an open circle with free hands.",
            ),
            "fingerplay": t(
                "Secuencia da canción tocando xeonllos, ombreiros e pés.",
                "Secuencia de la canción tocando rodillas, hombros y pies.",
                "Follow the song touching knees, shoulders and feet.",
            ),
            "calma": t(
                "Tras o freeze, mans abertas sobre os xeonllos e respiración lenta.",
                "Tras el freeze, manos abiertas sobre las rodillas y respiración lenta.",
                "After the freeze, open hands on the knees and slow breathing.",
            ),
            "comandos": [
                ("Head, shoulders, knees and toes", t("Tocar cada parte seguindo un compás que acelera.", "Tocar cada parte siguiendo un compás que acelera.", "Touch each part following a beat that speeds up.")),
                ("Shake your hands!", t("Sacudir os brazos con forza.", "Sacudir los brazos con fuerza.", "Shake the arms vigorously.")),
                ("FREEZE!", t("Deter ao instante calquera oscilación.", "Detener al instante cualquier oscilación.", "Stop any movement instantly.")),
            ],
        },
    },
    {
        "mes": 11,
        "titulo": t(
            "Novembro: follas de outono e os bosques de Galicia (o Magosto)",
            "Noviembre: hojas de otoño y los bosques de Galicia (el Magosto)",
            "November: Autumn Leaves and the Woods of Galicia",
        ),
        "centro": t(
            "O outono galego e as texturas do bosque",
            "El otoño gallego y las texturas del bosque",
            "Galician autumn and the textures of the woods",
        ),
        "0_2": {
            "material": t("Cesta de vimbio con follas de carballo e castiñeiro lavadas", "Cesta de mimbre con hojas de roble y castaño lavadas", "Wicker basket with washed oak and chestnut leaves"),
            "cancion": "",
            "apertura": t(
                "Achega a cesta e deixa que miren e toquen as follas.",
                "Acerca la cesta y deja que miren y toquen las hojas.",
                "Bring the basket close and let them look at and touch the leaves.",
            ),
            "fingerplay": t(
                "Ergue un puñado de follas á altura dos seus ollos.",
                "Eleva un puñado de hojas a la altura de sus ojos.",
                "Raise a handful of leaves to their eye level.",
            ),
            "calma": t(
                "Deixa unha folla na man do bebé e baixa a voz.",
                "Deja una hoja en la mano del bebé y baja la voz.",
                "Leave one leaf in the baby's hand and lower your voice.",
            ),
            "comandos": [
                ("Falling, falling, falling down!", t("Deixar caer as follas en choiva lixeira diante deles.", "Dejar caer las hojas en lluvia ligera delante de ellos.", "Let the leaves fall like light rain in front of them.")),
                ("Crunch, crunch!", t("Apertar unha folla seca xunto ao oído do neno.", "Apretar una hoja seca junto al oído del niño.", "Squeeze a dry leaf next to the child's ear.")),
            ],
        },
        "2_3": {
            "material": t("Dúas follas de cartolina en tons ocres e marróns por neno", "Dos hojas de cartulina en tonos ocres y marrones por niño", "Two ochre and brown card leaves per child"),
            "cancion": "",
            "apertura": t(
                "Reparte dúas follas de cartolina a cada neno.",
                "Reparte dos hojas de cartulina a cada niño.",
                "Hand out two card leaves to each child.",
            ),
            "fingerplay": t(
                "Camiñar de puntillas ao ritmo dunha marcha.",
                "Caminar de puntillas al ritmo de una marcha.",
                "Walk on tiptoe to a marching rhythm.",
            ),
            "calma": t(
                "Ao cesar a música, deixarse caer amodo na alfombra coma follas.",
                "Al cesar la música, dejarse caer despacio en la alfombra como hojas.",
                "When the music stops, drop slowly to the rug like falling leaves.",
            ),
            "comandos": [
                ("The wind blows! Whoosh!", t("Bater os brazos camiñando de puntillas.", "Batir los brazos caminando de puntillas.", "Flap the arms while walking on tiptoe.")),
                ("Crunch your leaves!", t("Agacharse rápido e fregar as follas contra o chan.", "Agacharse rápido y frotar las hojas contra el suelo.", "Crouch quickly and rub the leaves against the floor.")),
            ],
        },
    },
    {
        "mes": 12,
        "titulo": t(
            "Decembro: abrazos quentes, campaíñas e aire de inverno",
            "Diciembre: abrazos cálidos, campanillas y aire de invierno",
            "December: Warm Hugs, Little Bells and Winter Air",
        ),
        "centro": t(
            "O contraste entre o frío de fóra e a calor do colo",
            "El contraste entre el frío de fuera y el calor del regazo",
            "The contrast between the cold outside and the warmth of the lap",
        ),
        "0_2": {
            "material": t("Muñequeiras de feltro con axóuxeres inoxidables", "Muñequeras de fieltro con cascabeles inoxidables", "Felt cuffs with stainless bells"),
            "cancion": "Ring the Bells",
            "apertura": t(
                "Axusta as muñequeiras cos axóuxeres nos nocellos dos bebés.",
                "Ajusta las muñequeras con cascabeles en los tobillos de los bebés.",
                "Fit the bell cuffs around the babies' ankles.",
            ),
            "fingerplay": t(
                "Flexiona as pernas do bebé de xeito alterno ao compás.",
                "Flexiona las piernas del bebé de manera alterna al compás.",
                "Bend the baby's legs alternately to the beat.",
            ),
            "calma": t(
                "Envolve os ombreiros nunha toalla morna e susurra.",
                "Envuelve los hombros en una toalla cálida y susurra.",
                "Wrap the shoulders in a warm towel and whisper.",
            ),
            "comandos": [
                ("Ring the bells", t("Patexo alterno que fai soar os axóuxeres.", "Pataleo alterno que hace sonar los cascabeles.", "Alternate kicking that rings the bells.")),
                ("Warm... soft and warm", t("Envolver os ombreiros na toalla morna.", "Envolver los hombros en la toalla cálida.", "Wrap the shoulders in the warm towel.")),
            ],
        },
        "2_3": {
            "material": t("Campaíñas de madeira con badalo protexido", "Campanillas de madera con badajo protegido", "Wooden bells with a protected clapper"),
            "cancion": "",
            "apertura": t(
                "Reparte unha campaíña a cada neno, en círculo.",
                "Reparte una campanilla a cada niño, en círculo.",
                "Hand one bell to each child, in a circle.",
            ),
            "fingerplay": t(
                "Modula o volume: forte e rápido, logo suave.",
                "Modula el volumen: fuerte y rápido, luego suave.",
                "Modulate the volume: loud and fast, then soft.",
            ),
            "calma": t(
                "Campaíña detrás das costas, deitados e cos ollos pechados.",
                "Campanilla detrás de la espalda, tumbados y con los ojos cerrados.",
                "Bell behind the back, lying down with eyes closed.",
            ),
            "comandos": [
                ("Loud bells! Shake fast!", t("Correr no sitio facendo soar a campaíña.", "Correr en el sitio haciendo sonar la campanilla.", "Run on the spot ringing the bell.")),
                ("Quiet bells... sleep", t("Agochar a campaíña e deitarse en silencio.", "Esconder la campanilla y tumbarse en silencio.", "Hide the bell and lie down in silence.")),
                ("Wake up!", t("Incorporarse dun salto.", "Incorporarse de un salto.", "Spring back up.")),
            ],
        },
    },
    {
        "mes": 1,
        "titulo": t(
            "Xaneiro: roupa de inverno, botas grandes e luvas brandas",
            "Enero: ropa de invierno, botas grandes y manoplas suaves",
            "January: Winter Clothes, Big Boots and Soft Mittens",
        ),
        "centro": t(
            "As rutinas de abrigo e a autonomía ao vestirse",
            "Las rutinas de abrigo y la autonomía al vestirse",
            "Wrapping-up routines and independence when dressing",
        ),
        "0_2": {
            "material": t("Gorros e luvas de la, e o espello da asemblea", "Gorros y manoplas de lana, y el espejo de la asamblea", "Wool hats and mittens, and the circle-time mirror"),
            "cancion": "",
            "apertura": t(
                "Sitúate co bebé diante do espello da parede.",
                "Sitúate con el bebé delante del espejo de la pared.",
                "Sit with the baby in front of the wall mirror.",
            ),
            "fingerplay": t(
                "Pon e quita o gorro mirando o reflexo, sen présa.",
                "Pon y quita el gorro mirando el reflejo, sin prisa.",
                "Put the hat on and off while watching the reflection, unhurried.",
            ),
            "calma": t(
                "Fregar as luvas sobre as palmas do bebé, amodo.",
                "Frotar las manoplas sobre las palmas del bebé, despacio.",
                "Rub the mittens over the baby's palms, slowly.",
            ),
            "comandos": [
                ("Put on your hat!", t("Colocar o gorro na cabeza mirando o espello.", "Colocar el gorro en la cabeza mirando el espejo.", "Place the hat on the head while looking in the mirror.")),
                ("Take off!", t("Retirar a prenda suavemente.", "Retirar la prenda suavemente.", "Take the garment off gently.")),
            ],
        },
        "2_3": {
            "material": t("Sen material: mimo da roupa", "Sin material: mimo de la ropa", "No materials: miming the clothes"),
            "cancion": "Put on Your Shoes",
            "apertura": t(
                "En pé, con sitio arredor para mover as pernas.",
                "De pie, con sitio alrededor para mover las piernas.",
                "Standing, with room around to move the legs.",
            ),
            "fingerplay": t(
                "Simular poñer uns pantalóns pesados, unha perna e logo a outra.",
                "Simular ponerse unos pantalones pesados, una pierna y luego la otra.",
                "Mime pulling on heavy trousers, one leg then the other.",
            ),
            "calma": t(
                "Sentarse e atar as botas imaxinarias en silencio.",
                "Sentarse y atar las botas imaginarias en silencio.",
                "Sit down and tie the imaginary boots in silence.",
            ),
            "comandos": [
                ("Put on your coat!", t("Deslizar os brazos por mangas imaxinarias e facer «Zzzip!».", "Deslizar los brazos por mangas imaginarias y hacer «Zzzip!».", "Slide the arms into imaginary sleeves and go «Zzzip!».")),
                ("Stomp your boots in the puddles!", t("Tres pisotóns contundentes contra o chan.", "Tres pisotones contundentes contra el suelo.", "Three firm stomps on the floor.")),
            ],
        },
    },
    {
        "mes": 2,
        "titulo": t(
            "Febreiro: o reino animal e o Entroido",
            "Febrero: el reino animal y el Entroido",
            "February: The Animal Kingdom and Entroido",
        ),
        "centro": t(
            "A motricidade zoomorfa e as onomatopeas",
            "La motricidad zoomorfa y las onomatopeyas",
            "Animal-like movement and onomatopoeia",
        ),
        "0_2": {
            "material": t("Títeres de man de tea branda: ra, paxaro e gato", "Títeres de mano de tela suave: rana, pájaro y gato", "Soft hand puppets: frog, bird and cat"),
            "cancion": "",
            "apertura": t(
                "Presenta os tres títeres un a un, á altura dos seus ollos.",
                "Presenta los tres títeres uno a uno, a la altura de sus ojos.",
                "Introduce the three puppets one by one at their eye level.",
            ),
            "fingerplay": t(
                "A ra achégase con botes rítmicos sobre a colchoneta.",
                "La rana se acerca con botes rítmicos sobre la colchoneta.",
                "The frog hops rhythmically closer across the mat.",
            ),
            "calma": t(
                "O gato deitase e a voz baixa ata o susurro.",
                "El gato se tumba y la voz baja hasta el susurro.",
                "The cat lies down and the voice drops to a whisper.",
            ),
            "comandos": [
                ("Jump, jump, green frog! Ribbit!", t("Apoiar as patiñas do títere nos xeonllos do neno para que flexione as pernas.", "Apoyar las patitas del títere en las rodillas del niño para que flexione las piernas.", "Rest the puppet's feet on the child's knees so the legs bend in response.")),
            ],
        },
        "2_3": {
            "material": t("Tarxetas de gran formato coas siluetas dos animais", "Tarjetas de gran formato con las siluetas de los animales", "Large cards with animal silhouettes"),
            "cancion": "",
            "apertura": t(
                "Amosa a primeira tarxeta sen dicir nada e agarda.",
                "Muestra la primera tarjeta sin decir nada y espera.",
                "Show the first card without speaking and wait.",
            ),
            "fingerplay": t(
                "Circuito de emulación corporal polo aula.",
                "Circuito de emulación corporal por el aula.",
                "A body-imitation circuit around the room.",
            ),
            "calma": t(
                "Conxelar a postura do animal preferido, sen emitir son.",
                "Congelar la postura del animal preferido, sin emitir sonido.",
                "Freeze in the favourite animal's posture, without a sound.",
            ),
            "comandos": [
                ("Fly like a bird!", t("Desprazarse de puntillas cos brazos estendidos.", "Desplazarse de puntillas con los brazos extendidos.", "Move on tiptoe with the arms stretched out.")),
                ("Big heavy bear! Stomp!", t("Cuadrupedia pesada con mans e pés no chan.", "Cuadrupedia pesada con manos y pies en el suelo.", "Heavy four-legged walk with hands and feet on the floor.")),
                ("Carnival Freeze!", t("Conxelar a postura do animal predilecto en silencio.", "Congelar la postura del animal predilecto en silencio.", "Freeze in the favourite animal's pose, in silence.")),
            ],
        },
    },
    {
        "mes": 3,
        "titulo": t(
            "Marzo: cores, formas e comida sensorial",
            "Marzo: colores, formas y comida sensorial",
            "March: Colors, Shapes and Sensory Food",
        ),
        "centro": t(
            "A categorización sensorial e a discriminación de cor",
            "La categorización sensorial y la discriminación de color",
            "Sensory sorting and colour discrimination",
        ),
        "0_2": {
            "material": t("Botellas sensoriais seladas con auga tinguida e aros de silicona", "Botellas sensoriales selladas con agua teñida y aros de silicona", "Sealed sensory bottles with tinted water and silicone rings"),
            "cancion": "",
            "apertura": t(
                "Senta co bebé e amosa a botella á contraluz.",
                "Siéntate con el bebé y muestra la botella a contraluz.",
                "Sit with the baby and hold the bottle up to the light.",
            ),
            "fingerplay": t(
                "Fai rodar a botella polas súas pernas.",
                "Haz rodar la botella por sus piernas.",
                "Roll the bottle along their legs.",
            ),
            "calma": t(
                "Deixa a botella quieta e mira como baixan as brillantiñas.",
                "Deja la botella quieta y mirad cómo bajan las purpurinas.",
                "Set the bottle still and watch the glitter settle.",
            ),
            "comandos": [
                ("Roll, roll, yellow circle!", t("Guiar a presión coas dúas mans para que sacuda o recipiente.", "Guiar la prensión con las dos manos para que sacuda el recipiente.", "Guide a two-handed grip so they shake the bottle.")),
            ],
        },
        "2_3": {
            "material": t("Siluetas circulares de goma eva vermellas e amarelas", "Siluetas circulares de goma eva rojas y amarillas", "Red and yellow foam circles"),
            "cancion": "",
            "apertura": t(
                "Espalla as siluetas pola zona da asemblea.",
                "Esparce las siluetas por la zona de la asamblea.",
                "Scatter the shapes around the circle-time area.",
            ),
            "fingerplay": t(
                "Canta a adaptación rítmica de busca de cores.",
                "Canta la adaptación rítmica de búsqueda de colores.",
                "Sing the rhythmic colour-hunting chant.",
            ),
            "calma": t(
                "Recoller as siluetas por cor e sentarse enriba dunha.",
                "Recoger las siluetas por color y sentarse encima de una.",
                "Collect the shapes by colour and sit on one.",
            ),
            "comandos": [
                ("Find a red circle! Touch it with your foot!", t("Localizar a peza no chan e pousar a punta do zapato enriba.", "Localizar la pieza en el suelo y posar la punta del zapato encima.", "Spot the shape on the floor and place the toe of the shoe on it.")),
            ],
        },
    },
    {
        "mes": 4,
        "titulo": t(
            "Abril: esperta a primavera — flores, choiva e bechiños",
            "Abril: despierta la primavera — flores, lluvia y bichitos",
            "April: Spring Awakening — Flowers, Rain and Little Bugs",
        ),
        "centro": t(
            "O orballo e o espertar biolóxico da primavera",
            "El orballo y el despertar biológico de la primavera",
            "The soft Atlantic drizzle and the waking of spring",
        ),
        "0_2": {
            "material": t("Atomizador con auga morna e tea de tul translúcido amarelo", "Atomizador con agua tibia y tela de tul translúcido amarillo", "Spray bottle with warm water and translucent yellow tulle"),
            "cancion": "",
            "apertura": t(
                "Achega o atomizador e deixa que oian o son antes de sentilo.",
                "Acerca el atomizador y deja que oigan el sonido antes de sentirlo.",
                "Bring the spray close and let them hear it before they feel it.",
            ),
            "fingerplay": t(
                "Néboa imperceptible sobre o dorso das mans, con cadencia suave.",
                "Niebla imperceptible sobre el dorso de las manos, con cadencia suave.",
                "A barely-there mist over the backs of the hands, in a gentle cadence.",
            ),
            "calma": t(
                "Pousa o tul sobre as pernas e deixa que o toquen.",
                "Posa el tul sobre las piernas y deja que lo toquen.",
                "Lay the tulle over their legs and let them touch it.",
            ),
            "comandos": [
                ("Rain, rain, little drops, tap, tap, tap", t("Pulverizar auga morna sobre o dorso das mans.", "Pulverizar agua tibia sobre el dorso de las manos.", "Spray warm water over the backs of the hands.")),
                ("Sun comes up!", t("Ondear o tul amarelo sobre os seus rostros.", "Ondear el tul amarillo sobre sus rostros.", "Wave the yellow tulle above their faces.")),
            ],
        },
        "2_3": {
            "material": t("Sen material: o corpo no chan", "Sin material: el cuerpo en el suelo", "No materials: the body on the floor"),
            "cancion": "",
            "apertura": t(
                "Ovillados no chan en posición fetal encollida.",
                "Ovillados en el suelo en posición fetal encogida.",
                "Curled up on the floor in a tucked position.",
            ),
            "fingerplay": t(
                "Golpes rítmicos dos dedos imitando as pingas de choiva.",
                "Golpes rítmicos de los dedos imitando las gotas de lluvia.",
                "Rhythmic finger taps imitating raindrops.",
            ),
            "calma": t(
                "Baixar os brazos amodo e volver a sentarse.",
                "Bajar los brazos despacio y volver a sentarse.",
                "Lower the arms slowly and sit back down.",
            ),
            "comandos": [
                ("We are tiny seeds under the ground", t("Manterse encollidos e quietos no chan.", "Mantenerse encogidos y quietos en el suelo.", "Stay curled up and still on the floor.")),
                ("Bloom! Big bright flowers!", t("Erguerse milímetro a milímetro ata as puntas dos pés cos brazos en abano.", "Erguirse milímetro a milímetro hasta las puntas de los pies con los brazos en abanico.", "Rise millimetre by millimetre onto tiptoe with the arms fanned open.")),
            ],
        },
    },
    {
        "mes": 5,
        "titulo": t(
            "Maio: auga, salpicaduras e rutinas de aseo",
            "Mayo: agua, salpicaduras y rutinas de aseo",
            "May: Water, Splashing and Bathroom Routines",
        ),
        "centro": t(
            "Os hábitos de hixiene e o pracer de lavarse",
            "Los hábitos de higiene y el placer de lavarse",
            "Hygiene habits and the pleasure of washing",
        ),
        "0_2": {
            "material": t("Toalliñas de felpa humedecidas en hidrolato de lavanda apto para bebés", "Toallitas de felpa humedecidas en hidrolato de lavanda apto para bebés", "Towelling cloths dampened with baby-safe lavender water"),
            "cancion": "This Is the Way We Wash Our Hands",
            "apertura": t(
                "Amosa a toalliña e deixa que a cheiren antes de tocala.",
                "Muestra la toallita y deja que la huelan antes de tocarla.",
                "Show the cloth and let them smell it before touching.",
            ),
            "fingerplay": t(
                "Desliza a toalliña polas palmas e frótaas ritmicamente.",
                "Desliza la toallita por las palmas y frótalas rítmicamente.",
                "Slide the cloth over the palms and rub them rhythmically.",
            ),
            "calma": t(
                "Acariña as meixelas reforzando a sensación de frescor.",
                "Acaricia las mejillas reforzando la sensación de frescor.",
                "Stroke the cheeks, reinforcing the fresh, calm feeling.",
            ),
            "comandos": [
                ("Wash, wash, clean hands!", t("Sostén as mans do bebé e frótaas unha contra a outra.", "Sostén las manos del bebé y frótalas una contra la otra.", "Hold the baby's hands and rub them together.")),
            ],
        },
        "2_3": {
            "material": t("Unha toalla pequena de microfibra seca por neno", "Una toalla pequeña de microfibra seca por niño", "One small dry microfibre towel per child"),
            "cancion": "",
            "apertura": t(
                "Reparte unha toalla a cada neno, sentados en círculo.",
                "Reparte una toalla a cada niño, sentados en círculo.",
                "Hand a towel to each child, seated in a circle.",
            ),
            "fingerplay": t(
                "Secuencia de aseo simbólico sen auga, en orde.",
                "Secuencia de aseo simbólico sin agua, en orden.",
                "A symbolic washing sequence without water, in order.",
            ),
            "calma": t(
                "Dobrar a toalla sobre os xeonllos e quedar quietos.",
                "Doblar la toalla sobre las rodillas y quedarse quietos.",
                "Fold the towel over the knees and stay still.",
            ),
            "comandos": [
                ("Wash your face!", t("Fregar con suavidade meixelas e fronte coa toalla.", "Frotar con suavidad mejillas y frente con la toalla.", "Gently rub cheeks and forehead with the towel.")),
                ("Wash your belly!", t("Describir círculos sobre a camiseta á altura do embigo.", "Describir círculos sobre la camiseta a la altura del ombligo.", "Draw circles on the shirt at tummy height.")),
                ("Dry your toes!", t("Inclinar o tronco adiante para secar os zapatos sen dobrar os xeonllos.", "Inclinar el tronco adelante para secar los zapatos sin doblar las rodillas.", "Bend forward to dry the shoes without bending the knees.")),
            ],
        },
    },
    {
        "mes": 6,
        "titulo": t(
            "Xuño: días de sol, o océano e despedidas alegres",
            "Junio: días de sol, el océano y despedidas alegres",
            "June: Sunny Days, The Ocean and Happy Farewells",
        ),
        "centro": t(
            "O Atlántico, as rías de Vigo e a despedida do curso",
            "El Atlántico, las rías de Vigo y la despedida del curso",
            "The Atlantic, the Vigo rías and the end-of-year farewell",
        ),
        "0_2": {
            "material": t("Tea extensa de lycra azul brillante", "Tela extensa de lycra azul brillante", "A large bright blue lycra sheet"),
            "cancion": "Waves go up, waves go down, blue sea",
            "apertura": t(
                "Os bebés deitados comodamente sobre unha colchoneta central.",
                "Los bebés tumbados cómodamente sobre una colchoneta central.",
                "The babies lying comfortably on a central mat.",
            ),
            "fingerplay": t(
                "Ondear a tea horizontalmente a poucos centímetros dos seus corpos.",
                "Ondear la tela horizontalmente a pocos centímetros de sus cuerpos.",
                "Wave the sheet horizontally a few centimetres above their bodies.",
            ),
            "calma": t(
                "Baixar a tea ata pousala e deixala quieta enriba deles.",
                "Bajar la tela hasta posarla y dejarla quieta encima de ellos.",
                "Lower the sheet until it rests still over them.",
            ),
            "comandos": [
                ("Waves go up, waves go down, blue sea", t("Ondear a tea creando fluxo de aire e ondada visual.", "Ondear la tela creando flujo de aire y oleaje visual.", "Wave the sheet to create airflow and a visual swell.")),
            ],
        },
        "2_3": {
            "material": t("Paracaídas azul de asemblea", "Paracaídas azul de asamblea", "Blue circle-time parachute"),
            "cancion": "Bye-Bye, Goodbye",
            "apertura": t(
                "Todos suxeitan o contorno do paracaídas coas dúas mans.",
                "Todos sujetan el contorno del paracaídas con las dos manos.",
                "Everyone holds the rim of the parachute with both hands.",
            ),
            "fingerplay": t(
                "Modular a intensidade da ondada segundo a orde.",
                "Modular la intensidad del oleaje según la orden.",
                "Modulate the swell according to the command.",
            ),
            "calma": t(
                "Sentados en círculo, cantar a despedida co axitar de mans.",
                "Sentados en círculo, cantar la despedida con el agitar de manos.",
                "Seated in a circle, sing the farewell with a coordinated hand wave.",
            ),
            "comandos": [
                ("Gentle waves", t("Pequenos tremores de pulso.", "Pequeños temblores de muñeca.", "Small wrist tremors.")),
                ("Giant waves!", t("Bater os brazos enteiros desde os ombreiros.", "Batir los brazos enteros desde los hombros.", "Beat the whole arms from the shoulders.")),
                ("Little fish swimming under the sea!", t("Dous nenos designados gatean rápido por debaixo da tea.", "Dos niños designados gatean rápido por debajo de la tela.", "Two chosen children crawl quickly under the sheet.")),
            ],
        },
    },
]

FASES = [
    ("apertura_saudo", 90, t("Apertura e Saúdo", "Apertura y Saludo", "Opening and Greeting"), "apertura"),
    ("movement_rhythm_focus", 120, t("Enfoque e Fingerplay", "Enfoque y Fingerplay", "Focus and Fingerplay"), "fingerplay"),
    ("core_tpr_challenge", 210, t("Núcleo TPR Temático", "Núcleo TPR Temático", "Thematic TPR Core"), None),
    ("calma_transicion", 90, t("Calma e Despedida", "Calma y Despedida", "Calm and Farewell"), "calma"),
]


def construir(entrada, tramo):
    mes = entrada["mes"]
    slug, gl_mes, es_mes, en_mes = MESES[mes]
    d = entrada[tramo]
    ident = f"asamblea.primeiro_ciclo.{slug}.{TRAMOS[tramo]['slug']}"

    fases = []
    for orden, (clave, dur, titulo, campo) in enumerate(FASES, start=1):
        fase = {
            "orden": orden,
            "tipo": clave,
            "titulo": titulo,
            "duracionSegundos": dur,
            "lamina": "gato",
            "consignaDocente": d[campo] if campo else t(
                "Tres ordes motrices co material do mes. Non pidas que repitan.",
                "Tres órdenes motrices con el material del mes. No pidas que repitan.",
                "Three motor commands with this month's material. Never ask them to repeat.",
            ),
            "comandosL3": [],
            "repertorioMateriales": [],
        }
        if d["cancion"] and orden in (1, 2):
            fase["cueAcustica"] = d["cancion"]
        if clave == "core_tpr_challenge":
            fase["comandosL3"] = [
                {
                    "id": f"cmd.{slug}.{TRAMOS[tramo]['clave']}.{i:02d}",
                    "textoIngles": en,
                    "accionFisica": accion,
                    "modeladoDocente": t(
                        "A educadora fai o xesto mentres di a orde, e agarda sen esixir resposta.",
                        "La educadora hace el gesto mientras dice la orden, y espera sin exigir respuesta.",
                        "The educator performs the gesture while saying the command, and waits without demanding a response.",
                    ),
                }
                for i, (en, accion) in enumerate(d["comandos"], start=1)
            ]
        fases.append(fase)

    return {
        "id": ident,
        "tramo": TRAMOS[tramo]["clave"],
        "mes": mes,
        "titulo": entrada["titulo"],
        "centroInteres": entrada["centro"],
        "duracionTotalMinutos": 9,
        "materialDoMes": d["material"],
        "cancionDoMes": d["cancion"],
        "fases": fases,
        "curriculo": {
            "normativa": "Decreto 150/2022",
            "etapa": "educacion_infantil",
            "ciclo": "primeiro_ciclo_0_3",
            "nivel": TRAMOS[tramo]["clave"],
            "areas": [
                "area_1_crecemento_harmonia",
                "area_3_comunicacion_representacion",
            ],
            "competenciasClave": ["CCL", "CP", "CPSAA"],
            "criteriosEvaluacion": [],
        },
        "revision": {
            "autor": "Claude Code",
            "revisorPedagogico": "",
            "fechaRevision": "",
            "version": "1.0.0",
            "aprobadoParaAula": False,
        },
    }


def main():
    os.makedirs(SALIDA, exist_ok=True)
    escritos = 0
    for entrada in CURSO:
        for tramo in ("0_2", "2_3"):
            doc = construir(entrada, tramo)
            ruta = os.path.join(SALIDA, doc["id"] + ".json")
            with open(ruta, "w", encoding="utf-8") as fh:
                json.dump(doc, fh, ensure_ascii=False, indent=1)
                fh.write("\n")
            escritos += 1
    print(f"{escritos} microcápsulas escritas en {SALIDA}")


if __name__ == "__main__":
    main()
