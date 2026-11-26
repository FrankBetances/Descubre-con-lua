"""Escaleira dos 48 puntos por dominio e teito por idade (D1 · P11.5).

Os puntos 1-20 (A1-A2) forman a columna das idades sen pasar nunca do teito
de cada curso:
  - curso_0_2: sen gramática visible na casa (frases curtas de apoio <= 3 pal.)
  - curso_2_3: fórmulas fixas dos puntos 1-9 (A1, <= 4 pal.)
  - curso_3_4: puntos A1 (1-10) como fórmulas (<= 5 pal.)
  - curso_4_5: A1 e selección de A2 (1-19, <= 6 pal.)
  - curso_5_6: ata A2 (9-20, <= 7 pal.)
Os puntos 21-48 (B1-C1) quedan na guía da persoa adulta co seu exemplo.
Cada mes, catro frases co vocabulario do STEAM dese mes.
"""

# curso → mes → (punto_en_1_20, [(en, gl, es) × 4])
RUTA = {
    "curso_0_2": {
        9: (1, [
            ("Sponge is wet.", "A esponxa está mollada.", "La esponja está mojada."),
            ("Towel is dry.", "A toalla está seca.", "La toalla está seca."),
            ("Splash the water!", "Salpica a auga!", "¡Salpica el agua!"),
            ("I am wet!", "Estou mollado!", "¡Estoy mojado!"),
        ]),
        10: (1, [
            ("It is water.", "É auga.", "Es agua."),
            ("Bottle is loud.", "A botella soa forte.", "La botella suena fuerte."),
            ("Tap the glass!", "Peta no vaso!", "¡Golpea el vaso!"),
            ("You are happy!", "Estás contento!", "¡Estás contento!"),
        ]),
        11: (2, [
            ("A big leaf.", "Unha folla grande.", "Una hoja grande."),
            ("A stone drops.", "Cae unha pedra.", "Cae una piedra."),
            ("The leaf falls.", "A folla cae.", "La hoja cae."),
            ("Two big stones.", "Dúas pedras grandes.", "Dos piedras grandes."),
        ]),
        12: (3, [
            ("This big leaf.", "Esta folla grande.", "Esta hoja grande."),
            ("That dark shadow.", "Esa sombra escura.", "Esa sombra oscura."),
            ("My warm light.", "A miña luz.", "Mi luz cálida."),
            ("Your big shadow!", "A túa sombra grande!", "¡Tu sombra grande!"),
        ]),
        1: (4, [
            ("Put the apple.", "Pon a mazá.", "Pon la manzana."),
            ("Eat warm bread.", "Come pan quente.", "Come pan caliente."),
            ("Open the box!", "Abre a caixa!", "¡Abre la caja!"),
            ("I like bread.", "Gústame o pan.", "Me gusta el pan."),
        ]),
        2: (5, [
            ("Cold apple!", "Mazá fría!", "¡Manzana fría!"),
            ("Bread is warm.", "O pan está quente.", "El pan está caliente."),
            ("Touch cold apple.", "Toca a mazá fría.", "Toca la manzana fría."),
            ("Warm bread here!", "Pan quente aquí!", "¡Pan caliente aquí!"),
        ]),
        3: (6, [
            ("One big bubble!", "Unha burbulla grande!", "¡Una burbuja grande!"),
            ("Many soap bubbles!", "Moitas burbullas!", "¡Muchas burbujas!"),
            ("Blow soap bubble!", "Sopra a burbulla!", "¡Sopla la burbuja!"),
            ("Pop the bubble!", "Estoura a burbulla!", "¡Explota la burbuja!"),
        ]),
        4: (7, [
            ("Soap on hands.", "Xabón nas mans.", "Jabón en las manos."),
            ("Bubbles on towel.", "Burbullas na toalla.", "Burbuja en la toalla."),
            ("Soft dry towel.", "Toalla suave e seca.", "Toalla suave y seca."),
            ("Rub wet hands.", "Frega as mans molladas.", "Frota las manos mojadas."),
        ]),
        5: (8, [
            ("Where is light?", "Onde está a luz?", "¿Dónde está la luz?"),
            ("Look, dog shadow!", "Mira, sombra do can!", "¡Mira, sombra de perro!"),
            ("Who runs fast?", "Quen corre rápido?", "¿Quién corre rápido?"),
            ("Teddy can sleep.", "O osiño pode durmir.", "El osito puede dormir."),
        ]),
        6: (9, [
            ("Roll the ball!", "Roda a pelota!", "¡Rueda la pelota!"),
            ("Push the box!", "Empuxa a caixa!", "¡Empuja la caja!"),
            ("Stop the ball!", "Para a pelota!", "¡Para la pelota!"),
            ("Ball in box.", "Pelota na caixa.", "Pelota en la caja."),
        ]),
    },
    "curso_2_3": {
        9: (1, [
            ("The boat floats.", "O barco flota.", "El barco flota."),
            ("The stone is heavy.", "A pedra pesa.", "La piedra pesa."),
            ("Boat is wet!", "O barco está mollado!", "¡El barco está mojado!"),
            ("Is the stone wet?", "Está mollada a pedra?", "¿Está mojada la piedra?"),
        ]),
        10: (3, [
            ("This is my boat.", "Este é o meu barco.", "Este es mi barco."),
            ("Blow the boat!", "Sopra o barco!", "¡Sopla el barco!"),
            ("My boat moves far!", "O barco vai lonxe!", "¡Mi barco va lejos!"),
            ("Look at that boat!", "Mira ese barco!", "¡Mira ese barco!"),
        ]),
        11: (4, [
            ("Big stone, small leaf.", "Pedra grande, folla pequena.", "Piedra grande, hoja pequeña."),
            ("We walk together.", "Camiñamos xuntos.", "Caminamos juntos."),
            ("The leaf is small.", "A folla é pequena.", "La hoja es pequeña."),
            ("Make a big pile!", "Fai un montón grande!", "¡Haz un montón grande!"),
        ]),
        12: (4, [
            ("Drop the nut!", "Solta a noz!", "¡Suelta la nuez!"),
            ("Listen to the pan!", "Escoita a tixola!", "¡Escucha la sartén!"),
            ("Tap with a spoon.", "Peta cunha culler.", "Golpea con una cuchara."),
            ("Hear that soft sound!", "Oes ese son suave?", "¡Oye ese sonido suave!"),
        ]),
        1: (5, [
            ("Always squeeze soft bread.", "Aperta sempre pan brando.", "Aprieta siempre pan blando."),
            ("Yesterday bread was soft.", "Onte estaba brando.", "Ayer estaba blando."),
            ("Today it is hard.", "Hoxe está duro.", "Hoy está duro."),
            ("Knock on hard bread!", "Peta no pan duro!", "¡Golpea el pan duro!"),
        ]),
        2: (6, [
            ("Cut an apple!", "Corta unha mazá!", "¡Corta una manzana!"),
            ("Some seeds inside!", "Algunhas sementes dentro!", "¡Algunas semillas dentro!"),
            ("Look, a little star!", "Mira, unha estrela!", "¡Mira, una estrella!"),
            ("Many apple seeds here.", "Moitas sementes de mazá.", "Muchas semillas de manzana."),
        ]),
        3: (7, [
            ("Water on hands.", "Auga nas mans.", "Agua en las manos."),
            ("Soap is in water.", "O xabón está na auga.", "El jabón está en el agua."),
            ("Towel is right here.", "A toalla está aquí.", "La toalla está aquí."),
            ("Look! Clean hands now.", "Mira! Mans limpas agora.", "¡Mira! Manos limpias ahora."),
        ]),
        4: (8, [
            ("Where is wet towel?", "Onde está a toalla?", "¿Dónde está la toalla?"),
            ("Is it heavy now?", "Pesa moito agora?", "¿Pesa mucho ahora?"),
            ("Lift the dry towel!", "Levanta a toalla seca!", "¡Levanta la toalla seca!"),
            ("Light or heavy towel?", "Lixeira ou pesada?", "¿Ligera o pesada?"),
        ]),
        5: (8, [
            ("Who runs very fast?", "Quen corre moi rápido?", "¿Quién corre muy rápido?"),
            ("What does cat do?", "Que fai o gato?", "¿Qué hace el gato?"),
            ("Walk like a dog.", "Camiña coma un can.", "Camina como un perro."),
            ("Stop in the box!", "Para na caixa!", "¡Para en la caja!"),
        ]),
        6: (9, [
            ("At night, look up!", "Pola noite, mira arriba!", "¡Por la noche, mira arriba!"),
            ("Stars in dark room!", "Estrelas no cuarto escuro!", "¡Estrellas en la habitación!"),
            ("Shine light through holes!", "Pasa luz polos buratos!", "¡Pasa luz por los agujeros!"),
            ("See ceiling stars now!", "Mira as estrelas no teito!", "¡Mira las estrellas en el techo!"),
        ]),
    },
    "curso_3_4": {
        9: (3, [
            ("This box is tall.", "Esta caixa é alta.", "Esta caja es alta."),
            ("My cup on top!", "O meu vaso arriba!", "¡Mi vaso encima!"),
            ("Your tower stands strong!", "A túa torre aguanta!", "¡Tu torre aguanta!"),
            ("Oh no, it wobbles!", "Ai non, abanea!", "¡Ay no, se tambalea!"),
        ]),
        10: (4, [
            ("We make a long row.", "Facemos unha fila longa.", "Hacemos una fila larga."),
            ("Red block, then blue block.", "Bloque vermello, logo azul.", "Bloque rojo, luego azul."),
            ("Put the spoon next.", "Pon a culler despois.", "Pon la cuchara después."),
            ("I choose the blue sock.", "Escollo o calcetín azul.", "Elijo el calcetín azul."),
        ]),
        11: (4, [
            ("Push the fast train!", "Empuxa o tren rápido!", "¡Empuja el tren rápido!"),
            ("The orange goes down fast.", "A laranxa baixa rápido.", "La naranja baja rápido."),
            ("The tray goes down slowly.", "A bandexa baixa amodo.", "La bandeja baja despacio."),
            ("Does the car go fast?", "Vai rápido o coche?", "¿Va rápido el coche?"),
        ]),
        12: (4, [
            ("Pull the string tight!", "Tira ben do fío!", "¡Tira bien del hilo!"),
            ("Talk into your cup.", "Fala polo teu vaso.", "Habla por tu vaso."),
            ("I hear your voice!", "Escoito a túa voz!", "¡Oigo tu voz!"),
            ("Listen with the cup phone!", "Escoita co teléfono!", "¡Escucha con el teléfono!"),
        ]),
        1: (4, [
            ("Shine the torch low!", "Aluma coa lanterna abaixo!", "¡Alumbra con la linterna abajo!"),
            ("The tower shadow grows long.", "A sombra faise longa.", "La sombra se hace larga."),
            ("Now the sun sits high.", "Agora o sol está alto.", "Ahora el sol está alto."),
            ("Is the shadow short now?", "É curta agora a sombra?", "¿Es corta ahora la sombra?"),
        ]),
        2: (5, [
            ("Ice is always cold.", "O xeo sempre está frío.", "El hielo siempre está frío."),
            ("We sometimes stir cold juice.", "Ás veces remexemos o zume.", "A veces removemos el zumo."),
            ("Usually ice melts slowly.", "O xeo derrétese amodo.", "El hielo se derrite despacio."),
            ("Never touch hot glass!", "Nunca toques cristal quente!", "¡Nunca toques cristal caliente!"),
        ]),
        3: (7, [
            ("There is one big plate.", "Hai un prato grande.", "Hay un plato grande."),
            ("There are three small spoons.", "Hai tres culleres pequenas.", "Hay tres cucharas pequeñas."),
            ("The spoons sit on table.", "As culleres están na mesa.", "Las cucharas están en la mesa."),
            ("The plate is empty now.", "O prato está baleiro.", "El plato está vacío."),
        ]),
        4: (8, [
            ("Where is the water jug?", "Onde está a xerra?", "¿Dónde está la jarra?"),
            ("How full is the glass?", "Que cheo está o vaso?", "¿Qué lleno está el vaso?"),
            ("Pour slowly, do not spill!", "Bota amodo, non vertas!", "¡Echa despacio, no derrames!"),
            ("Who can drink water now?", "Quen bebe auga agora?", "¿Quién bebe agua ahora?"),
        ]),
        5: (9, [
            ("Tap the glass gently now!", "Peta no vaso con tino!", "¡Golpea el vaso suavemente!"),
            ("Full glass sounds very low.", "O vaso cheo soa grave.", "El vaso lleno suena grave."),
            ("Empty glass sounds very high.", "O vaso baleiro soa agudo.", "El vaso vacío suena agudo."),
            ("Play water music with spoons!", "Toca música con culleres!", "¡Toca música con cucharas!"),
        ]),
        6: (9, [
            ("Look in the soup spoon!", "Mira na culler da sopa!", "¡Mira en la cuchara!"),
            ("My face turns upside down!", "A cara vólvese do revés!", "¡Mi cara se gira al revés!"),
            ("Turn the spoon round slowly.", "Xira a culler amodo.", "Gira la cuchara despacio."),
            ("Wave at your tiny face!", "Saúda á túa cara!", "¡Saluda a tu cara pequeña!"),
        ]),
    },
    "curso_4_5": {
        9: (7, [
            ("There is water on cloth.", "Hai auga no pano.", "Hay agua en el paño."),
            ("The plaster stays under water.", "O apósito queda baixo a auga.", "La tirita queda bajo el agua."),
            ("The bag is dry inside.", "A bolsa está seca dentro.", "La bolsa está seca por dentro."),
            ("Teddy bandage is on leg.", "A venda está na perna.", "La venda está en la pierna."),
        ]),
        10: (8, [
            ("Where does your heart beat?", "Onde latexa o teu corazón?", "¿Dónde late tu corazón?"),
            ("Listen to my chest quietly.", "Escoita o meu peito quedo.", "Escucha mi pecho en silencio."),
            ("How fast do we run?", "Que rápido corremos?", "¿Qué rápido corremos?"),
            ("Sit on sofa, hear beat!", "Senta no sofá e escoita!", "¡Siéntate en el sofá y escucha!"),
        ]),
        11: (9, [
            ("Count the teddy legs carefully.", "Conta as patas do osiño.", "Cuenta las patas del osito."),
            ("In autumn, count cat legs!", "No outono conta patas de gato!", "¡En otoño cuenta patas de gato!"),
            ("Bird has two little legs.", "O paxaro ten dúas patas.", "El pájaro tiene dos patas."),
            ("Does snake fit in group?", "Cabe a serpe no grupo?", "¿Cabe la serpiente en el grupo?"),
        ]),
        12: (9, [
            ("Look through the magic lens!", "Mira pola lupa máxica!", "¡Mira por la lupa mágica!"),
            ("At school, examine a leaf.", "Na escola mira unha folla.", "En la escuela mira una hoja."),
            ("The stone looks much bigger.", "A pedra vese moito maior.", "La piedra se ve mucho más grande."),
            ("Now draw that tiny hair!", "Agora debuxa ese pelo pequeno!", "¡Ahora dibuja ese pelo pequeño!"),
        ]),
        1: (15, [
            ("Hold this teddy with me!", "Suxeita este osiño comigo!", "¡Sujeta este osito conmigo!"),
            ("Carry the towel with us.", "Leva a toalla connosco.", "Lleva la toalla con nosotros."),
            ("Look at me carry it!", "Mírame levalo!", "¡Mírame llevarlo!"),
            ("Don't let teddy fall slowly!", "Non deixes caer o osiño!", "¡No dejes caer el osito!"),
        ]),
        2: (15, [
            ("Look at the wet mud!", "Mira o barro mollado!", "¡Mira el barro mojado!"),
            ("Wear boots, keep them clean.", "Pon botas, mantenas limpas.", "Ponte botas, mantenlas limpias."),
            ("Wash muddy boots with me.", "Lava as botas de barro comigo.", "Lava las botas con barro conmigo."),
            ("Soil and rain make mud!", "Terra e chuvia fan barro!", "¡Tierra y lluvia hacen barro!"),
        ]),
        3: (15, [
            ("Watch the paper windmill spin!", "Mira xirar o muíño!", "¡Mira girar el molino!"),
            ("Hold windmill high with me.", "Suxeita o muíño comigo.", "Sujeta el molino conmigo."),
            ("Wind blows it for us.", "O vento sóprao para nós.", "El viento lo sopla para nosotros."),
            ("Take it outside with you!", "Lévao fóra contigo!", "¡Llévalo fuera contigo!"),
        ]),
        4: (15, [
            ("Listen to the rain tube!", "Escoita o tubo de chuvia!", "¡Escucha el tubo de lluvia!"),
            ("Hear loud rice with me.", "Oio o arroz forte comigo.", "Oye el arroz fuerte conmigo."),
            ("Shake the storm for us!", "Axita a tormenta para nós!", "¡Agita la tormenta para nosotros!"),
            ("Wait for thunder with them!", "Agarda o trono con eles!", "¡Espera el trueno con ellos!"),
        ]),
        5: (17, [
            ("We are going to check sun.", "Imos mirar o sol.", "Vamos a mirar el sol."),
            ("Our shadow will grow long.", "A nosa sombra medrará.", "Nuestra sombra crecerá."),
            ("In morning, shadow will stretch.", "Pola mañá a sombra estirarase.", "Por la mañana se estirará."),
            ("It is going to hide hat!", "Vai tapar o gorro!", "¡Va a tapar el gorro!"),
        ]),
        6: (19, [
            ("Look out into the sky!", "Mira cara ao ceo!", "¡Mira hacia el cielo!"),
            ("Put the hat onto head.", "Pon o gorro na cabeza.", "Ponte el gorro en la cabeza."),
            ("Walk out into sunny weather.", "Sae ao tempo de sol.", "Sal al tiempo soleado."),
            ("Zip coat up against rain!", "Pecha o abrigo para a chuvia!", "¡Cierra el abrigo para la lluvia!"),
        ]),
    },
    "curso_5_6": {
        9: (9, [
            ("In autumn we mix warm colours.", "No outono mesturamos cores cálidas.", "En otoño mezclamos colores cálidos."),
            ("Mix red and yellow paint now!", "Mestura pintura vermella e amarela!", "¡Mezcla pintura roja y amarilla!"),
            ("Look at orange and green paint.", "Mira a pintura laranxa e verde.", "Mira la pintura naranja y verde."),
            ("Today we paint a rainbow together.", "Hoxe pintamos un arco da vella.", "Hoy pintamos un arcoíris juntos."),
        ]),
        10: (10, [
            ("Can you shine the bright torch?", "Podes alumar coa lanterna brillante?", "¿Puedes alumbrar con la linterna brillante?"),
            ("Hold red paper over the light!", "Pon o papel vermello na luz!", "¡Pon el papel rojo sobre la luz!"),
            ("Can red and blue make purple?", "Poden vermello e azul facer morado?", "¿Pueden rojo y azul hacer morado?"),
            ("Look how the room turns purple!", "Mira como o cuarto vólvese morado!", "¡Mira cómo el cuarto se vuelve morado!"),
        ]),
        11: (11, [
            ("We are painting one paper side.", "Estamos pintando un lado do papel.", "Estamos pintando un lado del papel."),
            ("Now I am folding the butterfly.", "Agora estou dobrando a bolboreta.", "Ahora estoy doblando la mariposa."),
            ("We are opening the folded paper.", "Estamos abrindo o papel dobrado.", "Estamos abriendo el papel doblado."),
            ("Look! Both sides are the same!", "Mira! Os dous lados son iguais!", "¡Mira! ¡Los dos lados son iguales!"),
        ]),
        12: (13, [
            ("Yesterday we painted a colour circle.", "Onte pintamos un círculo de cores.", "Ayer pintamos un círculo de colores."),
            ("Did you spin the painted circle?", "Xiraches o círculo pintado?", "¿Giraste el círculo pintado?"),
            ("We spun the circle very fast!", "Xiramos o círculo moi rápido!", "¡Giramos el círculo muy rápido!"),
            ("All the colours mixed into white!", "Todas as cores mesturáronse en branco!", "¡Todos los colores se mezclaron en blanco!"),
        ]),
        1: (15, [
            ("Close your eyes, listen with me.", "Pecha os ollos, escoita comigo.", "Cierra los ojos, escucha conmigo."),
            ("Crumple the newspaper for us now.", "Engurra o xornal para nós agora.", "Arruga el periódico para nosotros ahora."),
            ("Can you guess tissue paper yourself?", "Adiviñas o pano de papel ti?", "¿Adivinas el pañuelo de papel tú solo?"),
            ("Hold it and listen with us!", "Suxéitao e escoita connosco!", "¡Sujétalo y escucha con nosotros!"),
        ]),
        2: (19, [
            ("Fold a paper plane with care.", "Dobra un avión de papel ben.", "Dobla un avión de papel con cuidado."),
            ("Throw the plane across the room!", "Lanza o avión polo cuarto!", "¡Lanza el avión por la habitación!"),
            ("Walk along and count your steps!", "Camiña e conta os teus pasos!", "¡Camina y cuenta tus pasos!"),
            ("Watch how far it can fly!", "Mira que lonxe pode voar!", "¡Mira qué lejos puede volar!"),
        ]),
        3: (19, [
            ("Hide the treasure under a chair!", "Esconde o tesouro baixo a cadeira!", "¡Esconde el tesoro bajo la silla!"),
            ("Walk down the corridor to kitchen.", "Vai polo corredor á cociña.", "Ve por el pasillo hacia la cocina."),
            ("Follow our map into the room.", "Segue o mapa dentro do cuarto.", "Sigue nuestro mapa dentro del cuarto."),
            ("Look around the chair and find it!", "Busca pola cadeira e atópao!", "¡Busca por la silla y encuéntralo!"),
        ]),
        4: (19, [
            ("Pack books and coat into suitcase!", "Mete libros e abrigo na maleta!", "¡Mete libros y abrigo en la maleta!"),
            ("Lift the heavy bag off floor.", "Levanta a bolsa pesada do chan.", "Levanta la bolsa pesada del suelo."),
            ("Take one bottle out of bag.", "Saca unha botella da bolsa.", "Saca una botella de la bolsa."),
            ("Move the lighter suitcase across floor!", "Move a maleta lixeira polo chan!", "¡Mueve la maleta ligera por el suelo!"),
        ]),
        5: (20, [
            ("Flash once for yes, twice no!", "Fai un destello para si!", "¡Haz un destello para sí!"),
            ("It is dark, so use torch!", "Está escuro, así que usa lanterna!", "¡Está oscuro, así que usa linterna!"),
            ("We watch and answer every question.", "Miramos e contestamos cada pregunta.", "Miramos y contestamos cada pregunta."),
            ("We understand the message because it glows.", "Entendemos a mensaxe porque brilla.", "Entendemos el mensaje porque brilla."),
        ]),
        6: (20, [
            ("Blow the straw and listen close!", "Sopra pola palla e escoita!", "¡Sopla la pajita y escucha cerca!"),
            ("Long straw is low, short high.", "Palla longa soa grave, curta agudo.", "Pajita larga grave, corta agudo."),
            ("Blow softly or blow fast train!", "Sopra suave ou tren rápido!", "¡Sopla suave o como tren rápido!"),
            ("Wait! Listen and count high notes!", "Agarda! Escoita e conta notas agudas!", "¡Espera! ¡Escucha y cuenta notas agudas!"),
        ]),
    },
}

# Lo que es cada unidad para una familia, de la 21 a la 48: una línea, con un
# ejemplo de criatura.
PARA_FAMILIAS = {
    21: ("Contar o que xa fixemos: «We have made a row».", "Contar lo que ya hemos hecho: «We have made a row»."),
    22: ("O que fixemos hoxe e o que fixemos onte: «Today it has gone fast», «Yesterday it went slowly».", "Lo que hemos hecho hoy y lo que hicimos ayer: «Today it has gone fast», «Yesterday it went slowly»."),
    23: ("O que levamos un tempo facendo: «We have been talking».", "Lo que llevamos un rato haciendo: «We have been talking»."),
    24: ("O que xa pasara antes: «The sun had gone down».", "Lo que ya había pasado antes: «The sun had gone down»."),
    25: ("O que pode ser ou ten que ser: «It might melt», «It must be cold».", "Lo que puede ser o tiene que ser: «It might melt», «It must be cold»."),
    26: ("Se pasa unha cousa, pasa outra: «If you pour, the glass fills».", "Si pasa una cosa, pasa otra: «If you pour, the glass fills»."),
    27: ("Imaxinar: «If it were empty, it would sound high».", "Imaginar: «If it were empty, it would sound high»."),
    28: ("O que se fai, sen dicir quen: «The spoons are put away».", "Lo que se hace, sin decir quién: «The spoons are put away»."),
    29: ("Dicir cal: «the cloth that drinks water».", "Decir cuál: «the cloth that drinks water»."),
    30: ("Gustar, querer e parar con outro verbo: «I like listening», «We want to run».", "Gustar, querer y parar con otro verbo: «I like listening», «We want to run»."),
    31: ("Contar o que dixo alguén: «You said the cat had four legs».", "Contar lo que dijo alguien: «You said the cat had four legs»."),
    32: ("Verbos con compañía: «pick up», «look for».", "Verbos con compañía: «pick up», «look for»."),
    33: ("Preguntar para confirmar: «It's heavy, isn't it?».", "Preguntar para confirmar: «It's heavy, isn't it?»."),
    34: ("O que pasaría se tivese pasado: «If it had rained, we would have found mud».", "Lo que habría pasado si hubiera pasado: «If it had rained, we would have found mud»."),
    35: ("Mesturar o de antes co de agora: «If we had made it bigger, it would spin faster now».", "Mezclar lo de antes con lo de ahora: «If we had made it bigger, it would spin faster now»."),
    36: ("Desexar: «I wish it would thunder!».", "Desear: «I wish it would thunder!»."),
    37: ("Adiviñar o que pasou: «The sun must have moved».", "Adivinar lo que pasó: «The sun must have moved»."),
    38: ("O que se fai ou se fai facer: «The weather was checked», «Get your coat zipped!».", "Lo que se hace o se hace hacer: «The weather was checked», «Get your coat zipped!»."),
    39: ("Engadir un dato entre comas: «Red, which is warm, …».", "Añadir un dato entre comas: «Red, which is warm, …»."),
    40: ("O que xa estará feito: «By bedtime, we will have seen every colour».", "Lo que ya estará hecho: «By bedtime, we will have seen every colour»."),
    41: ("O que levabamos un tempo facendo antes: «We had been painting».", "Lo que llevábamos un rato haciendo antes: «We had been painting»."),
    42: ("Contar con outros verbos: prometer, propoñer, explicar: «You promised to spin it».", "Contar con otros verbos: prometer, proponer, explicar: «You promised to spin it»."),
    43: ("Unir ideas: aínda que, mentres que, porén: «Although we closed our eyes, we guessed».", "Unir ideas: aunque, mientras que, sin embargo: «Although we closed our eyes, we guessed»."),
    44: ("Dicir dúas cousas nunha: «Having folded the plane, we threw it».", "Decir dos cosas en una: «Having folded the plane, we threw it»."),
    45: ("Darlle forza á frase: «Never have we hidden it so well!».", "Darle fuerza a la frase: «Never have we hidden it so well!»."),
    46: ("Sinalar o importante: «It's the books that make it heavy».", "Señalar lo importante: «It's the books that make it heavy»."),
    47: ("Imaxinar e aconsellar: «If I were you, I would flash twice».", "Imaginar y aconsejar: «If I were you, I would flash twice»."),
    48: ("Non repetir o que xa se dixo: «I can blow harder, and so can you».", "No repetir lo que ya se dijo: «I can blow harder, and so can you»."),
}

# Lo que cada STEAM pone en juego, en inglés: su material y sus acciones. Con
# esto se comprueba que la frase de la semana habla del experimento.
STEAM_EN = {
    "curso_0_2": {9: "sponge towel water wet dry splash squeeze", 10: "water bottle glass tap drip drop shake loud cold happy",
                  11: "leaf stone fall drop big down park", 12: "leaf light shadow torch window big small",
                  1: "apple bread basket box shop put eat like", 2: "apple bread fridge cold warm touch eat",
                  3: "bubble soap water bath blow pop", 4: "towel hands soap rub bath bubbles soft dry",
                  5: "shadow light torch dog teddy run sleep", 6: "ball box cushion roll stop push down morning night"},
    "curso_2_3": {9: "boat stone water float sink splash bath", 10: "boat blow wind water move far softly",
                  11: "stone leaf big small pile walk", 12: "nut leaf pan spoon drop sound listen hear",
                  1: "bread hard soft squeeze knock yesterday", 2: "apple star seeds cut inside fruit",
                  3: "hands water soap towel wash first clean", 4: "towel wet heavy light lift dry",
                  5: "run walk fast slow cat dog sleep stop box", 6: "box light stars ceiling holes room torch"},
    "curso_3_4": {9: "tower box cup build fall stand tall wobble", 10: "row red blue block spoon sock next made chosen",
                  11: "train tray car orange push down fast slow gone", 12: "cup string talk listen hear pull phone",
                  1: "shadow sun tower torch long short drawn", 2: "ice juice melt stir spoon cold warm glass",
                  3: "plate spoon table empty full count", 4: "glass jug pour full empty spill drink",
                  5: "glass water spoon tap sound high low", 6: "spoon face upside down soup turn"},
    "curso_4_5": {9: "cloth bag plaster water drink absorb teddy bandage leg dry", 10: "heart chest listen run beat fast slow sofa",
                  11: "legs teddy cat bird snake count groups fit", 12: "lens hair leaf stone look examine bigger draw",
                  1: "teddy towel carry hold fall slowly heavy", 2: "mud boots soil water rain splash wash",
                  3: "windmill paper wind blow spin turn outside", 4: "storm thunder rain rice tube loud",
                  5: "shadow sun morning long short hat", 6: "weather sky boots hat coat rain sunny warm cold"},
    "curso_5_6": {9: "colour red yellow blue orange green mix paint rainbow", 10: "colour red blue paper torch room light purple",
                  11: "paper paint fold open side same butterfly", 12: "circle spin colours paint mix",
                  1: "paper newspaper tissue sound crumple eyes listen guess", 2: "plane paper fold throw fly steps",
                  3: "map treasure hide find corridor kitchen room chair", 4: "suitcase bag books clothes water coat heavy pack",
                  5: "torch light flash message yes no question", 6: "straw blow sound low high long short train"},
}
