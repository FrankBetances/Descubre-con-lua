# Cobertura real en Fluent Emoji (P2.0)

Medición previa a `P2.1` sobre las **4.389** palabras y frases distintas que hoy no tienen lámina válida en `leccions.json`, `tpr/*.json` y `acopros/proxectos_0_2.json` (total de piezas sin lámina: **6.351 de 6.382**).

Criterio aplicado:
- Fuente medida: `microsoft/fluentui-emoji` (estilo `Color`, 1.595 carpetas de `assets/*/metadata.json`), sin copiar ninguna imagen al repositorio todavía.
- Se descartan pictogramas abstractos, botones con texto o cifras, símbolos de UI, flechas aisladas y banderas.
- Prohibido emparejar por homonimia o parecido de nombre: cada emoji se contrastó contra `en`, `es`, `gl` y `gesto`/`tprAction` (p. ej. `snap` *cerrar de golpe* no usa `Camera with flash`; `tap shoes`/`tap water` no usan dedo señalando; `fairy lights` no usa `Person fairy`; `tree rings`/`count rings` no usan `Ring`; `rock` *mecer* no usa `Rock`).

## Resumen

| Categoría | Piezas distintas | Porcentaje sobre 4.389 |
| --- | ---: | ---: |
| (a) Coincidencia directa (1 emoji) | 432 | 9.8% |
| (b) Composición con 2-3 emojis | 97 | 2.2% |
| (c) Sin representación posible en Fluent | 3860 | 87.9% |
| **Total medido** | **4389** | **100.0%** |

## (a) Coincidencia directa (432)

| Palabra / frase (`en`) | Español (`es`) | Emoji Fluent (`Color`) |
| --- | --- | --- |
| A bubble. | Una burbuja. | `Bubbles` |
| A leaf. | Una hoja. | `Leaf fluttering in wind` |
| Agreement | Acuerdo | `Handshake` |
| Alarm clock | Despertador | `Alarm clock` |
| Ambulance | Ambulancia | `Ambulance` |
| Anchor | Ancla | `Anchor` |
| Ant | Hormiga | `Ant` |
| Applause | Aplauso | `Clapping hands` |
| Apple | manzana | `Red apple` |
| Astronaut | Astronauta | `Astronaut` |
| Autumn | Otoño | `Fallen leaf` |
| Baby | Bebé | `Baby` |
| Backpack | Mochila | `Backpack` |
| Baker | Panadero | `Cook` |
| Balance scale | Balanza de platos | `Balance scale` |
| Ball | pelota | `Soccer ball` |
| Ballet | Ballet | `Ballet shoes` |
| Balloon | Globo | `Balloon` |
| Banana | Plátano | `Banana` |
| Basket | Cesta | `Basket` |
| Bath | Baño | `Bathtub` |
| Beach | Playa | `Beach with umbrella` |
| Beam | Sonreír de oreja a oreja | `Beaming face with smiling eyes` |
| Bean | Judía | `Beans` |
| Beans | Alubias | `Beans` |
| Bear | Oso | `Bear` |
| Bed | Cama | `Bed` |
| Bee | Abeja | `Honeybee` |
| Beetle | Escarabajo | `Beetle` |
| Bell | Campana | `Bell` |
| Big hug | Abrazo grande | `People hugging` |
| Big wheel | Noria | `Ferris wheel` |
| Bike | Bici | `Bicycle` |
| Bin | Papelera | `Wastebasket` |
| Bird | Pájaro | `Bird` |
| Birthday | Cumpleaños | `Birthday cake` |
| Biscuit | Galleta | `Cookie` |
| Black | Negro, negra | `Black circle` |
| Blackbird | Mirlo | `Blackbird` |
| Blossom | Flor de árbol | `Blossom` |
| Blow kisses | Mandar besos | `Face blowing a kiss` |
| Blue | Azul | `Blue circle` |
| Blueberry | Arándano | `Blueberries` |
| Boar | Jabalí | `Boar` |
| Boat | barco | `Sailboat` |
| Bones | Huesos | `Bone` |
| Bonfire | Hoguera | `Fire` |
| Book | Libro | `Open book` |
| Boots | Botas | `Hiking boot` |
| Bow | Hacer una reverencia | `Person bowing` |
| Bowl | Cuenco | `Bowl with spoon` |
| Box | caja | `Package` |
| Bread | pan | `Bread` |
| Bridge | Puente | `Bridge at night` |
| Broccoli | Brócoli | `Broccoli` |
| Brown | Marrón | `Brown circle` |
| Brush | Pincel | `Paintbrush` |
| Bubbles | Burbujas | `Bubbles` |
| Bucket | Cubo | `Bucket` |
| Bus | Autobús | `Bus` |
| Bus stop | Parada del autobús | `Bus stop` |
| Butterfly | Mariposa | `Butterfly` |
| Bye-bye | Adiós, adiós | `Waving hand` |
| Cake | Tarta | `Birthday cake` |
| Calendar | Calendario | `Calendar` |
| Candle | Vela | `Candle` |
| Car | Coche | `Automobile` |
| Cardboard box | Caja de cartón | `Package` |
| Castle | Castillo | `Castle` |
| Cat! | gato | `Cat` |
| Caterpillar | Oruga | `Bug` |
| Chair | Silla | `Chair` |
| Cheese | Queso | `Cheese wedge` |
| Cherry | Cereza | `Cherries` |
| Chestnut | Castaña | `Chestnut` |
| Chick | Pollito | `Baby chick` |
| Circle | Círculo | `Hollow red circle` |
| Clap | aplaudir, dar palmas | `Clapping hands` |
| Clap along | Acompañar con palmas | `Clapping hands` |
| Clap your hands | Da palmas | `Clapping hands` |
| Climb | Trepar | `Person climbing` |
| Clock | Reloj | `Alarm clock` |
| Cloud | Nube | `Cloud` |
| Cloudy | Nublado, nublada | `Cloud` |
| coat | abrigo | `Coat` |
| Coin | Moneda | `Coin` |
| Cold! | Frío, fría | `Cold face` |
| Comb | Peine | `Hair pick` |
| Comet | Cometa | `Comet` |
| Compass | Brújula | `Compass` |
| Confetti | Confeti | `Confetti ball` |
| Cook | Cocinar | `Cooking` |
| Coral | Coral | `Coral` |
| Corn | Maíz | `Ear of corn` |
| Cow | Vaca | `Cow` |
| Crab | Cangrejo | `Crab` |
| Crayon | Cera de colores | `Crayon` |
| Crocodile | Cocodrilo | `Crocodile` |
| Crown | Corona | `Crown` |
| Cucumber | Pepino | `Cucumber` |
| Cuddle | Acurrucarse | `People hugging` |
| cup | taza | `Teacup without handle` |
| Custard | Natillas | `Custard` |
| Dance | Bailar | `Woman dancing` |
| Deer | Ciervo | `Deer` |
| delicious | delicioso | `Face savoring food` |
| Diamond | Rombo | `Large blue diamond` |
| Dice | Dado | `Game die` |
| Dizzy | Mareadito | `Face with spiral eyes` |
| Dog | perro | `Dog` |
| Dolphin | Delfín | `Dolphin` |
| Donkey | Burro | `Donkey` |
| Door | Puerta | `Door` |
| Dragon | Dragón | `Dragon` |
| draw | dibujar | `Pencil` |
| Drop! | Gota | `Droplet` |
| Droplet | Gotita | `Droplet` |
| Drum | Tambor | `Drum` |
| Duck | Pato | `Duck` |
| Ears | Orejas | `Ear` |
| Earth | Tierra | `Globe showing europe-africa` |
| Earthworm | Lombriz | `Worm` |
| Egg | Huevo | `Egg` |
| Elephant | Elefante | `Elephant` |
| Excited | Emocionado, emocionada | `Star-struck` |
| Exercise book | Cuaderno de ejercicios | `Notebook` |
| Eyes | Ojos | `Eyes` |
| Fairy | Hada | `Person fairy` |
| Family | Familia | `People hugging` |
| Fan | Abanico | `Folding hand fan` |
| Farmer | Granjero | `Farmer` |
| Feather | Pluma | `Feather` |
| Feathers | Plumas | `Feather` |
| Feet | Pies | `Foot` |
| Ferry | Ferry | `Ferry` |
| Fingers | Dedos | `Hand with fingers splayed` |
| Fire | Fuego | `Fire` |
| Fire engine | Camión de bomberos | `Fire engine` |
| Firefighter | Bombero | `Firefighter` |
| First | Primero, primera | `1st place medal` |
| Fish! | pez | `Fish` |
| Fist | Puño | `Raised fist` |
| Flex | Tensar | `Flexed biceps` |
| Flip-flops | Chanclas | `Thong sandal` |
| Flower | Flor | `Blossom` |
| Foggy | Con niebla | `Foggy` |
| Foot | Pie | `Foot` |
| Footprint | Huella | `Footprints` |
| Forest | Bosque | `Evergreen tree` |
| Fountain | Fuente | `Fountain` |
| Fox | Zorro | `Fox` |
| Freezing | Helado | `Cold face` |
| Frisbee | Disco volador | `Flying disc` |
| Frog | Rana | `Frog` |
| Funny | Divertido, divertida | `Zany face` |
| Gift | Regalo | `Wrapped gift` |
| Giraffe | Jirafa | `Giraffe` |
| Glad | Contento | `Grinning face` |
| Globe | Globo terráqueo | `Globe showing europe-africa` |
| Gloves | Guantes | `Gloves` |
| Goat | Cabra | `Goat` |
| Goggles | Gafas de bucear | `Goggles` |
| Goodbye | Adiós | `Waving hand` |
| Gorilla | Gorila | `Gorilla` |
| Graduation | Graduación | `Graduation cap` |
| Graduation cap | Birrete | `Graduation cap` |
| Grandma | Abuela | `Old woman` |
| Grandpa | Abuelo | `Old man` |
| Grapes | Uvas | `Grapes` |
| Green | Verde | `Green circle` |
| Greet | Saludar | `Waving hand` |
| Guitar | Guitarra | `Guitar` |
| Hamster | Hámster | `Hamster` |
| Hands | Manos | `Open hands` |
| Happy | Contento, contenta | `Grinning face` |
| hat | sombrero | `Top hat` |
| Heart | Corazón | `Red heart` |
| Heartbeat | Latido | `Beating heart` |
| Hello! | ¡Hola! | `Waving hand` |
| Hen | Gallina | `Chicken` |
| Hike | Hacer senderismo | `Person walking` |
| Hippo | Hipopótamo | `Hippopotamus` |
| Home | Casa | `House` |
| Honey | Miel | `Honey pot` |
| Horse | Caballo | `Horse` |
| Hot | Caliente | `Hot face` |
| Hug | Abrazar | `People hugging` |
| hurt | doler, hacer daño | `Face with head-bandage` |
| Hushed | Silencioso | `Shushing face` |
| Ice | Hielo | `Ice` |
| Ice cream | Helado | `Ice cream` |
| Ice cube | Cubito de hielo | `Ice` |
| Island | Isla | `Desert island` |
| Jellyfish | Medusa | `Jellyfish` |
| juice | zumo | `Beverage box` |
| Juice box | Zumo en brik | `Beverage box` |
| Kangaroo | Canguro | `Kangaroo` |
| Key | Llave | `Key` |
| King | Rey | `Person with crown` |
| Kiss | Besar | `Face blowing a kiss` |
| Kiss goodbye | Besar al despedirse | `Face blowing a kiss` |
| Kite | Cometa | `Kite` |
| Kitten | Gatito | `Cat face` |
| Kiwi | Kiwi | `Kiwi fruit` |
| Lab coat | Bata de laboratorio | `Lab coat` |
| Ladder | Escalera de mano | `Ladder` |
| Ladybird | Mariquita | `Lady beetle` |
| Lantern | Farol | `Red paper lantern` |
| Laugh | Reír | `Grinning squinting face` |
| Leaf | hoja | `Leaf fluttering in wind` |
| Left | Izquierdo | `Backhand index pointing left` |
| leg | pierna | `Leg` |
| Legs | Piernas | `Leg` |
| Lemon | Limón | `Lemon` |
| Light | Luz | `Light bulb` |
| Light bulb | Bombilla | `Light bulb` |
| Lightning | Relámpago | `Cloud with lightning` |
| Lion | León | `Lion` |
| Lips | Labios | `Mouth` |
| Log | Tronco caído | `Wood` |
| Lorry | Camión | `Articulated lorry` |
| Lotion | Crema hidratante | `Lotion bottle` |
| Lungs | Pulmones | `Lungs` |
| Magic | Mágico, mágica | `Magic wand` |
| Magnifying glass | Lupa | `Magnifying glass tilted left` |
| Mango | Mango | `Mango` |
| Map | Mapa | `World map` |
| Maraca | Maraca | `Maracas` |
| Massage | Masaje | `Person getting massage` |
| Melon | Melón | `Melon` |
| Microphone | Micrófono | `Microphone` |
| Milk | Leche | `Glass of milk` |
| Mirror | Espejo | `Mirror` |
| Monkey | Mono | `Monkey` |
| Moon | Luna | `Crescent moon` |
| Mountain | Montaña | `Mountain` |
| Mouse | Ratón | `Mouse` |
| Mouth | Boca | `Mouth` |
| Mug | Taza | `Hot beverage` |
| Mushroom | Seta | `Mushroom` |
| Music | Música | `Musical notes` |
| Nap | Echar la siesta | `Sleeping face` |
| Nest | Nido | `Nest with eggs` |
| Nesting dolls | Muñecas rusas | `Nesting dolls` |
| Night | Noche | `Night with stars` |
| Nod | Asentir | `Head shaking vertically` |
| Nose | Nariz | `Nose` |
| Notebook | Cuaderno | `Notebook` |
| Ocean | Océano | `Water wave` |
| Octopus | Pulpo | `Octopus` |
| Older | Mayor | `Older person` |
| Olive | Aceituna | `Olive` |
| Orange | Naranja | `Orange circle` |
| Otter | Nutria | `Otter` |
| Owl | Búho | `Owl` |
| Page | Página | `Page facing up` |
| paint | pintura | `Artist palette` |
| Palette | Paleta de pintor | `Artist palette` |
| Palm tree | Palmera | `Palm tree` |
| paper | papel | `Page facing up` |
| Parrot | Loro | `Parrot` |
| Party | Fiesta | `Party popper` |
| Paw | Pata | `Paw prints` |
| Paw prints | Huellas de animal | `Paw prints` |
| Peach | Melocotón | `Peach` |
| Pear | Pera | `Pear` |
| Peas | Guisantes | `Pea pod` |
| Pebble | Piedrecita | `Rock` |
| Pencil | Lápiz | `Pencil` |
| Penguin | Pingüino | `Penguin` |
| Photo | Foto | `Camera` |
| Piano | Piano | `Musical keyboard` |
| Picture | Dibujo | `Framed picture` |
| Pig | Cerdo | `Pig` |
| Pinch | Pellizcar | `Pinching hand` |
| Pine tree | Pino | `Evergreen tree` |
| Pineapple | Piña | `Pineapple` |
| plane | avión | `Airplane` |
| Planet | Planeta | `Ringed planet` |
| Planet Earth | Tierra | `Globe showing europe-africa` |
| Plant | Planta | `Potted plant` |
| Plant pot | Maceta | `Potted plant` |
| plate | plato | `Fork and knife with plate` |
| Playground | Patio | `Playground slide` |
| Point | Señalar | `Index pointing up` |
| Polar bear | Oso polar | `Polar bear` |
| Police officer | Policía | `Police officer` |
| Postbox | Buzón | `Postbox` |
| Pot | Olla | `Pot of food` |
| Potato | Patata | `Potato` |
| Present | Regalo | `Wrapped gift` |
| Princess | Princesa | `Princess` |
| Puppy | Cachorro | `Dog face` |
| Purple | Morado, morada | `Purple circle` |
| push | empujar | `Rightwards pushing hand` |
| Puzzle | Puzle | `Puzzle piece` |
| Puzzle piece | Pieza del puzle | `Puzzle piece` |
| Quiet | Callado, callada | `Shushing face` |
| Rabbit | Conejo | `Rabbit` |
| Rain | Lluvia | `Cloud with rain` |
| Rain cloud | Nube de lluvia | `Cloud with rain` |
| Rainbow | Arcoíris | `Rainbow` |
| Rainy | Lluvioso, lluviosa | `Cloud with rain` |
| Recycle | Reciclar | `Recycling symbol` |
| Red | Rojo, roja | `Red circle` |
| Ribbon | Cinta | `Ribbon` |
| Rice | Arroz | `Cooked rice` |
| Ring | Sonar | `Bell` |
| Robot | Robot | `Robot` |
| Rocket | Cohete | `Rocket` |
| Rooster | Gallo | `Rooster` |
| Row | Remar | `Person rowing boat` |
| Rowing boat | Barca de remos | `Person rowing boat` |
| Ruler | Regla | `Straight ruler` |
| Run! | correr | `Person running` |
| Sandwich | Sándwich | `Sandwich` |
| Scale | Balanza | `Balance scale` |
| Scarf | Bufanda | `Scarf` |
| School | Escuela | `School` |
| School bag | Mochila del colegio | `Backpack` |
| Scientist | Científica | `Scientist` |
| scissors | tijeras | `Scissors` |
| Scooter | Patinete | `Kick scooter` |
| Sea | Mar | `Water wave` |
| Seal | Foca | `Seal` |
| Search | Buscar | `Magnifying glass tilted left` |
| Shake hands | Dar la mano | `Handshake` |
| Shampoo | Champú | `Lotion bottle` |
| Sheep | Oveja | `Ewe` |
| Shell | Concha | `Spiral shell` |
| Shoe | Zapato | `Running shoe` |
| Shooting star | Estrella fugaz | `Shooting star` |
| Shopping bag | Bolsa de la compra | `Shopping bags` |
| Shower | Ducharse | `Shower` |
| Shush | Chistar | `Shushing face` |
| Sing | Cantar | `Singer` |
| Sledge | Trineo | `Sled` |
| Sleep! | dormir | `Sleeping face` |
| Sleepy | Con sueño | `Sleepy face` |
| Slide | Deslizarse | `Playground slide` |
| Smile | Sonreír | `Smiling face with smiling eyes` |
| Snail | Caracol | `Snail` |
| Snake | Serpiente | `Snake` |
| Snow | Nieve | `Snowflake` |
| Snowflake | Copo de nieve | `Snowflake` |
| Snowman | Muñeco de nieve | `Snowman` |
| Soap | jabón | `Soap` |
| Socks | Calcetines | `Socks` |
| Sofa | Sofá | `Couch and lamp` |
| Soup | Caldo | `Steaming bowl` |
| Sparkle | Destellar | `Sparkles` |
| Spider | Araña | `Spider` |
| Splash! | chapotear, salpicar | `Sweat droplets` |
| Splashing | Chapoteando | `Sweat droplets` |
| Sponge | Esponja | `Sponge` |
| spoon | cuchara | `Spoon` |
| Sprout | Brotar | `Seedling` |
| Square | Cuadrado | `Blue square` |
| Squirrel | Ardilla | `Chipmunk` |
| Stand up | Ponte de pie | `Person standing` |
| Star | Estrella | `Star` |
| Stone | piedra | `Rock` |
| Stopwatch | Cronómetro | `Stopwatch` |
| Storm | Tormenta | `Cloud with lightning and rain` |
| Strawberry | Fresa | `Strawberry` |
| suitcase | maleta | `Luggage` |
| Sun | Sol | `Sun` |
| Sunflower | Girasol | `Sunflower` |
| Sunglasses | Gafas de sol | `Sunglasses` |
| Sunny | Soleado, soleada | `Sun` |
| Sunrise | Amanecer | `Sunrise` |
| Superhero | Superhéroe | `Person superhero` |
| Surf | Hacer surf | `Person surfing` |
| Surprised | Sorprendido, sorprendida | `Astonished face` |
| Sweet | Dulce | `Candy` |
| Sweet potato | Boniato | `Roasted sweet potato` |
| Swim | Nadar | `Person swimming` |
| Target | Diana | `Bullseye` |
| Taxi | Taxi | `Taxi` |
| Teacher | Maestra, maestro | `Teacher` |
| Teddy | Osito de peluche | `Teddy bear` |
| Telescope | Telescopio | `Telescope` |
| Thermometer | Termómetro | `Thermometer` |
| Thumb | Pulgar | `Thumbs up` |
| Thumbs up | Pulgar arriba | `Thumbs up` |
| Thunder | Trueno | `Cloud with lightning and rain` |
| ticket | billete | `Ticket` |
| Tie | Atar | `Knot` |
| Tiger | Tigre | `Tiger` |
| Timer | Temporizador | `Timer clock` |
| Tired | Cansado, cansada | `Tired face` |
| Toadstool | Seta de cuento | `Mushroom` |
| Tomato | Tomate | `Tomato` |
| Tongue | Lengua | `Tongue` |
| Tooth | Diente | `Tooth` |
| Toothbrush | Cepillo de dientes | `Toothbrush` |
| Torch | Linterna | `Flashlight` |
| Tractor | Tractor | `Tractor` |
| Traffic light | Semáforo | `Vertical traffic light` |
| train | tren | `Train` |
| Tram | Tranvía | `Tram` |
| Tree | Árbol | `Deciduous tree` |
| Triangle | Triángulo | `Red triangle` |
| Tulip | Tulipán | `Tulip` |
| Turtle | Tortuga | `Turtle` |
| Umbrella | Paraguas | `Umbrella` |
| Up | Arriba | `Raising hands` |
| Walk | Caminar | `Person walking` |
| Water | agua | `Droplet` |
| Water pistol | Pistola de agua | `Water pistol` |
| Watermelon | Sandía | `Watermelon` |
| Wave | Saludar con la mano | `Waving hand` |
| Wave goodbye | Decir adiós con la mano | `Waving hand` |
| Waves | Olas | `Water wave` |
| Whale | Ballena | `Whale` |
| Wheel | Rueda | `Wheel` |
| Wheels | Ruedas | `Wheel` |
| White | Blanco, blanca | `White circle` |
| Wind | Viento | `Wind face` |
| Wind chime | Campanillas de viento | `Wind chime` |
| Window | Ventana | `Window` |
| windy | con viento | `Wind face` |
| Wing | Ala | `Wing` |
| Wings | Alas | `Wing` |
| Wizard | Mago | `Person mage` |
| Wolf | Lobo | `Wolf` |
| Worm | Lombriz | `Worm` |
| Write | Escribir | `Writing hand` |
| Yawn | Bostezar | `Yawning face` |
| Yellow | Amarillo, amarilla | `Yellow circle` |
| Yummy | Riquísimo, riquísima | `Face savoring food` |
| Zebra | Cebra | `Zebra` |

## (b) Composición con 2-3 emojis (97)

| Palabra / frase (`en`) | Español (`es`) | Composición Fluent (`Color`) |
| --- | --- | --- |
| Apples and pears | Manzanas y peras | `Red apple` + `Pear` |
| Autumn walk | Paseo de otoño | `Fallen leaf` + `Person walking` |
| Baby bath | Bañera de bebé | `Baby` + `Bathtub` |
| Baby photo | Foto de bebé | `Baby` + `Framed picture` |
| Baby spoon | Cucharita | `Baby` + `Spoon` |
| Bath time! | ¡Hora del baño! | `Bathtub` + `Alarm clock` |
| Beach bag | Bolsa de playa | `Beach with umbrella` + `Shopping bags` |
| Bedtime story | Cuento para dormir | `Sleeping face` + `Open book` |
| Bird bath | Bebedero de pájaros | `Bird` + `Bathtub` |
| Bird song | Canto de los pájaros | `Bird` + `Musical notes` |
| Birdhouse | Casita de pájaros | `Bird` + `House` |
| Bread and cheese | Pan y queso | `Bread` + `Cheese wedge` |
| Brick house | Casa de ladrillo | `Brick` + `House` |
| Brush your teeth | Lávate los dientes | `Toothbrush` + `Tooth` |
| Bubble wand | Varita de burbujas | `Bubbles` + `Magic wand` |
| Bubbly water | Agua con burbujas | `Bubbles` + `Droplet` |
| Bye-bye, friends! | ¡Adiós, amigos! | `Waving hand` + `People hugging` |
| Bye-bye, nursery! | ¡Adiós, escuela! | `Waving hand` + `School` |
| Carrots and cucumbers | Zanahorias y pepinos | `Carrot` + `Cucumber` |
| Chestnut tree | Castaño | `Chestnut` + `Deciduous tree` |
| Clown nose | Nariz de payaso | `Clown face` + `Nose` |
| Coat hook | Perchero | `Coat` + `Hook` |
| Count coins | Contar monedas | `Abacus` + `Coin` |
| Dog bowl | Cuenco del perro | `Dog` + `Bowl with spoon` |
| Drink water | Beber agua | `Cup with straw` + `Droplet` |
| Ears and nose | Orejas y nariz | `Ear` + `Nose` |
| Egg cup | Huevera | `Egg` + `Teacup without handle` |
| Feather bed | Cama de plumas | `Feather` + `Bed` |
| Fingers and thumbs | Dedos y pulgares | `Hand with fingers splayed` + `Thumbs up` |
| First we wash, then we eat. | Primero lavamos, después comemos. | `Soap` + `Fork and knife with plate` |
| Fruit salad | Macedonia | `Red apple` + `Banana` + `Grapes` |
| Hands and feet | Manos y pies | `Open hands` + `Foot` |
| Hello, friend! | ¡Hola, amigo! | `Waving hand` + `People hugging` |
| Hello, sea! | ¡Hola, mar! | `Waving hand` + `Water wave` |
| Hojas que caen | Hojas que caen | `Fallen leaf` + `Leaf fluttering in wind` |
| I like bread. | Me gusta el pan. | `Red heart` + `Bread` |
| Lava, lava las manos | Lava, lava las manos | `Soap` + `Open hands` + `Droplet` |
| Listen to the birds | Escucha a los pájaros | `Ear` + `Bird` |
| Look at the stone closely. | Mira la piedra de cerca. | `Eyes` + `Magnifying glass tilted left` + `Rock` |
| Me pongo el gorro, me pongo las botas | Me pongo el gorro, me pongo las botas | `Top hat` + `Hiking boot` |
| Memory box | Caja de los recuerdos | `Package` + `Framed picture` |
| Music box | Caja de música | `Musical notes` + `Package` |
| Musical chairs | Juego de las sillas | `Musical notes` + `Chair` |
| Oak leaf | Hoja de roble | `Deciduous tree` + `Leaf fluttering in wind` |
| Old MacDonald had a farm, E-I-E-I-O. | El viejo MacDonald tenía una granja. | `Farmer` + `Cow` + `Pig` |
| Olive tree | Olivo | `Olive` + `Deciduous tree` |
| Paper bag | Bolsa de papel | `Page facing up` + `Shopping bags` |
| Paper boat | Barco de papel | `Page facing up` + `Sailboat` |
| Paper snowflake | Copo recortado | `Page facing up` + `Snowflake` |
| Parrot feather | Pluma de loro | `Parrot` + `Feather` |
| Pat-a-cake, pat-a-cake, baker's man! Bake me a cake as fast as you can. | ¡Palmas, palmitas, panadero! Hazme una torta muy deprisa. | `Clapping hands` + `Birthday cake` |
| Photo book | Libro de fotos | `Camera` + `Open book` |
| Pick up the lens. | Coge la lupa. | `Raised hand` + `Magnifying glass tilted left` |
| Picture book | Libro de imágenes | `Framed picture` + `Open book` |
| Put on your coat! | ¡Ponte el abrigo! | `Child` + `Coat` |
| Put on your hat! | Ponte el gorro | `Child` + `Top hat` |
| Put your feet into the boots. | Mete los pies en las botas. | `Foot` + `Hiking boot` |
| Rain boots | Botas de lluvia | `Cloud with rain` + `Hiking boot` |
| Rain, rain, go away, come again another day. | Lluvia, lluvia, vete ya, vuelve otro día. | `Cloud with rain` + `Umbrella` |
| Rainbow bubble | Burbuja de colores | `Rainbow` + `Bubbles` |
| Rainbow ribbon | Cinta de colores | `Rainbow` + `Ribbon` |
| Ring the bells | Toca las campanas | `Bell` + `Bell` |
| Row, row, row your boat, gently down the stream. | Rema, rema, rema tu barco, suave río abajo. | `Person rowing boat` + `Water wave` |
| Run home | Correr a casa | `Person running` + `House` |
| Salt water | Agua salada | `Salt` + `Droplet` |
| Salta la rana, vuela el pájaro | Salta la rana, vuela el pájaro | `Frog` + `Bird` |
| Silly hat | Gorro gracioso | `Zany face` + `Top hat` |
| Silly monster | Monstruo gracioso | `Zany face` + `Alien monster` |
| Smell the flower | Huele la flor | `Nose` + `Blossom` |
| Snail shell | Concha de caracol | `Snail` + `Spiral shell` |
| Sniff a flower | Oler una flor | `Nose` + `Blossom` |
| Soap and water | Jabón y agua | `Soap` + `Droplet` |
| Soap up | Enjabonar | `Soap` + `Open hands` |
| Spot a bird | Avistar un pájaro | `Eyes` + `Bird` |
| Suena el cascabel | Suena el cascabel | `Bell` + `Musical notes` |
| Sun and water | Sol y agua | `Sun` + `Droplet` |
| Sun cream | Crema solar | `Sun` + `Lotion bottle` |
| Sunny day | Día de sol | `Sun` + `Smiling face with sunglasses` |
| Sunny yellow | Amarillo sol | `Sun` + `Yellow circle` |
| The apple goes in the basket. | La manzana va en la cesta. | `Red apple` + `Basket` |
| The cat says meow | El gato dice miau | `Cat` + `Speech balloon` |
| The soap is on your hands. | El jabón está en tus manos. | `Soap` + `Open hands` |
| The sponge is wet. | La esponja está mojada. | `Sponge` + `Sweat droplets` |
| This is the way we put on our hat, put on our hat, put on our hat. | Así es como nos ponemos el gorro. | `Top hat` + `Child` |
| This is the way we wash our hands, wash our hands, wash our hands. | Así es como nos lavamos las manos. | `Soap` + `Open hands` + `Droplet` |
| Twinkle, twinkle, little star, how I wonder what you are. | Brilla, brilla, estrellita, qué serás, me pregunto. | `Glowing star` + `Star` |
| Walk fingers | Caminar con los dedos | `Person walking` + `Hand with fingers splayed` |
| Wash your hands | Lávate las manos | `Soap` + `Open hands` + `Droplet` |
| Wash, wash, clean hands! | ¡Lava, lava, manos limpias! | `Soap` + `Open hands` + `Droplet` |
| Watch the rain | Mirar la lluvia | `Eyes` + `Cloud with rain` |
| Watch the waves | Mirar las olas | `Eyes` + `Water wave` |
| Water balloon | Globo de agua | `Droplet` + `Balloon` |
| Water cup | Vaso de agua | `Droplet` + `Tumbler glass` |
| Water wheel | Rueda de agua | `Droplet` + `Wheel` |
| We eat an apple. | Comemos una manzana. | `Mouth` + `Red apple` |
| Window seat | Asiento de la ventanilla | `Window` + `Seat` |
| You put the bread in the box. | Tú pones el pan en la caja. | `Bread` + `Package` |

## (c) Sin representación posible (3860)

| Palabra / frase (`en`) | Español (`es`) | Conjunto | Gesto / acción (`es`) |
| --- | --- | --- | --- |
| A big stone. | Una piedra grande. | frases | — |
| A full plate on the table. | Un plato lleno encima de la mesa. | leccions | — |
| A heart with my hands | Un corazón con las manos | tpr | Hacer un corazón con las manos |
| A red tomato | Un tomate rojo | leccions, tpr | Enseñar el tomate |
| A slice for each | Una rodaja para cada uno | tpr | Repartir rodajas |
| A spoon for you | Una cuchara para ti | tpr | Dar la cuchara al bebé |
| Above | Por encima | tpr | Señalar por encima de la cabeza |
| Abracadabra! | ¡Abracadabra! | tpr | Mover la varita |
| Accomplished | Logrado | tpr | Levantar los brazos |
| Achievement | Logro | tpr | Levantar los brazos |
| Acorn | Bellota | tpr | Coger una bellota imaginaria con los dedos |
| Acorn cap | Capuchón de la bellota | tpr | Poner un dedo como un sombrero |
| Acrobatic | Acrobático | tpr | Girar en el sitio |
| Across the road | Al otro lado de la calle | tpr | Caminar de un lado al otro |
| Across the sea | A través del mar | tpr | Remar hasta el otro lado del aula |
| Act | Actuar | tpr | Hacer un personaje con todo el cuerpo |
| Act it out | Representarlo | tpr | Hacer la historia con el cuerpo |
| Action! | ¡Acción! | tpr | Cerrar la claqueta |
| Actor's line | Frase del papel | tpr | Decir una frase corta |
| Add one more | Añadir uno más | tpr | Poner otro bloque |
| Add up | Sumar | tpr | Juntar dos grupos |
| Admire | Admirar | tpr | Mirar con la boca abierta |
| Adventurous | Aventurero | tpr | Caminar con paso firme |
| After running, the heart beats faster | Después de correr, el corazón late más rápido | tpr | Correr y poner la mano en el pecho |
| Age | Edad | tpr | Enseñar los años con los dedos |
| Agree | Estar de acuerdo | tpr | Asentir con la cabeza |
| Agreed | Acordado | tpr | Asentir con la cabeza |
| Ahoy, pirates! | ¡Ah del barco, piratas! | tpr | Saludar con la mano en la frente |
| Air | Aire | tpr | Mover la mano en el aire |
| Alert | Alerta | leccions, tpr | Abrir mucho los ojos |
| Alive | Vivo, viva | tpr | Moverse con energía de los pies a la cabeza |
| All aboard the boat! | ¡Todos al barco! | tpr | Subir al barco imaginario |
| All aboard! | ¡Todos a bordo! | tpr | Subir a un tren imaginario con un paso grande |
| All by myself | Yo solo | tpr | Tocar el pecho orgulloso |
| All clean now | Ya todo limpio | tpr | Abrir las manos limpias |
| All done! | ¡Ya está! | tpr | Abrir las manos al terminar |
| All gone! | ¡Se acabó! | tpr | Abrir las manos vacías hacia arriba |
| All hands on deck! | ¡Todos a cubierta! | tpr | Correr al barco |
| All the family | Toda la familia | tpr | Abrir los brazos a todos |
| All together | Todos juntos | leccions, tpr | Darse las manos en círculo y subirlas a la vez |
| All wet! | ¡Todo mojado! | 0-2, leccions, tpr | Enseñar las manos mojadas |
| Almost at the top! | ¡Ya casi estamos arriba! | tpr | Estirar la mano hacia arriba |
| Along the path | Por el sendero | tpr | Caminar en fila por el sendero |
| Alternating | Alterno | tpr | Mano arriba, mano abajo |
| Although we closed our eyes, we guessed. | Aunque cerramos los ojos, adivinamos. | frases | — |
| An oak grows from an acorn | Un roble nace de una bellota | tpr | Encogerse y levantarse despacio |
| Ancient | Antiquísimo | tpr | Mover la mano despacio como el tiempo |
| Ancient town | Villa antigua | tpr | Caminar despacio |
| And then what happened? | ¿Y qué pasó después? | tpr | Señalar adelante |
| And then... | Y entonces... | tpr | Abrir una mano y luego la otra, con cara de misterio |
| Anemone | Anémona | tpr | Abrir y cerrar los dedos despacio |
| Animal ears | Orejas de animal | tpr | Poner las manos como orejas |
| Animal parade | Desfile de animales | leccions, tpr | Caminar en fila como animales |
| Animal tail | Cola de disfraz | leccions, tpr | Menear la cola del disfraz |
| Ankle | Tobillo | tpr | Girar el tobillo despacio |
| Answer | Respuesta | tpr | Levantar la mano y responder |
| Ant steps | Pasos de hormiga | tpr | Dar pasos muy cortos |
| Apologise | Pedir perdón | tpr | Poner la mano en el pecho y bajar la cabeza |
| Apricot | Albaricoque | tpr | Acariciar la piel del albaricoque |
| Arch your back | Arquear la espalda | tpr | Hacer un gato con la espalda |
| Arctic | Ártico | tpr | Abrazarse por el frío |
| Arctic fox | Zorro ártico | tpr | Enroscarse como un zorro |
| Are you OK? | ¿Estás bien? | tpr | Inclinar la cabeza preguntando |
| Are you ready? | ¿Preparados? | leccions | — |
| Armchair | Sillón | tpr | Sentarse en el sillón |
| Arms | Brazos | tpr | Abrir los brazos en cruz |
| Arms out like a plane | Brazos abiertos como un avión | tpr | Abrir los brazos |
| Arms up high! | ¡Brazos arriba! | tpr | Levantar los brazos para el jersey |
| Arms up! | ¡Brazos arriba! | leccions, tpr | Subir los dos brazos de golpe |
| Aromatic | Aromático | tpr | Oler y suspirar |
| Around the fire | Alrededor del fuego | tpr | Caminar en círculo con el bebé |
| Around the square | Alrededor del cuadrado | tpr | Caminar alrededor de un cuadrado imaginario |
| Arrange tiles | Colocar azulejos | tpr | Poner piezas en fila |
| arrive | llegar | leccions, tpr | Parar y abrir los brazos |
| As if the light were a secret! | ¡Como si la luz fuera un secreto! | frases | — |
| Ask for | Pedir | tpr | Extender la mano pidiendo |
| Ask for help | Pedir ayuda | tpr | Levantar la mano |
| At bath time, the box stops. | A la hora del baño, la caja se para. | frases | — |
| At night, the ball sleeps in the box. | Por la noche, la pelota duerme en la caja. | frases | — |
| Audience | Público | tpr | Sentarse y mirar al escenario |
| Aunt | Tía | tpr | Señalar la foto de la tía |
| Autumn-coloured | Color otoño | tpr | Señalar hojas y castañas |
| Awake | Despierto, despierta | tpr | Abrir mucho los ojos y mirar alrededor |
| Baa | Balar | 0-2, leccions, tpr | Hacer «beee» como un cordero |
| Babble | Balbucear | tpr | Repetir «ba-ba» con el bebé |
| Baby oil | Aceite de bebé | 0-2, tpr | Frotar las manos con aceite |
| Back | Espalda | tpr | Tocarse la espalda con las dos manos por detrás |
| Back and forth | Adelante y atrás | tpr | Mover al bebé adelante y atrás |
| Back in the box | Otra vez en la caja | tpr | Meter el juguete en la caja |
| Back teeth | Muelas | tpr | Señalar las muelas |
| Back to front | Al revés | tpr | Poner el gorro al revés riendo |
| Backwards | Hacia atrás | tpr | Dar dos pasos hacia atrás |
| Badge | Insignia | tpr | Poner una insignia en el pecho |
| Bagpipes | Gaita | tpr | Apretar el fuelle de una gaita imaginaria bajo el brazo |
| Bakery | Panadería | tpr | Oler el pan caliente |
| Balance | Mantener el equilibrio | leccions, tpr | Mantenerse en un pie con los brazos abiertos y la mano de una persona adulta cerca |
| Balance a plate | Equilibrar el plato | leccions, tpr | Repartir colores en el plato |
| Balance arms | Equilibrar los brazos | tpr | Poner los brazos a la misma altura |
| Balance beam | Barra de equilibrio | leccions, tpr | Caminar por la barra con los brazos abiertos |
| Balance on top | Equilibrar encima | tpr | Poner la pirámide encima del cubo |
| Balanced | Equilibrado | tpr | Quedarse quieto en un pie |
| Balanced scale | Balanza equilibrada | tpr | Quedarse con los brazos iguales |
| Ball pit | Piscina de bolas | tpr | Meter las manos en las bolas |
| Ball run | Circuito de bolas | tpr | Seguir la bola con el dedo |
| Ball to baby | Pelota para el bebé | tpr | Rodar la pelota hasta el bebé |
| Ballot box | Urna | tpr | Meter un papel en la urna |
| Bang | Golpear | tpr | Golpear las piernas con las palmas: pum, pum |
| Bang the drum | Tocar el tambor | tpr | Tocar el tambor con las manos |
| Barefoot | Descalzo, descalza | tpr | Mover los dedos de los pies descalzos |
| Bark | Ladrar | tpr | Abrir y cerrar la boca como un perro que ladra |
| Barn | Establo | tpr | Hacer un tejado con las manos |
| Base | Base | tpr | Poner las piezas grandes abajo |
| Bath foam | Espuma de baño | tpr | Posar espuma en la mano |
| Bath towel | Toalla de baño | 0-2, tpr | Envolver al bebé en la toalla |
| Bath toy | Juguete de baño | 0-2, tpr | Flotar un juguete en el agua |
| Be a little seed | Sé una semillita | tpr | Encogerse en el suelo como una semilla |
| Be gentle with bugs | Cuidado con los bichos | tpr | Posar la mano muy despacio |
| Beach ball | Pelota de playa | 0-2, leccions, tpr | Rodar la pelota grande |
| Beach ball game | Juego de pelota | leccions, tpr | Pasar la pelota a un amigo |
| Beach clean-up | Limpieza de la playa | tpr | Agacharse a recoger |
| Beach spade | Pala de playa | tpr | Cavar con la pala |
| Beach towel | Toalla de playa | 0-2, tpr | Extender la toalla en la arena |
| Beachcomb | Buscar tesoros | tpr | Caminar mirando el suelo |
| Bead | Cuenta | tpr | Ensartar una cuenta imaginaria |
| Beak | Pico | tpr | Juntar los dedos como un pico |
| Beanbag | Puf | tpr | Hundir al bebé en el puf |
| Beanbag balance | Saquito en la cabeza | tpr | Caminar con el saquito en la cabeza |
| Beat | Compás | tpr | Dar palmas al compás |
| Beat your chest | Golpear el pecho | tpr | Golpear el pecho como un gorila |
| Beautiful | Bonito, bonita | tpr | Mirar algo con cara de admiración: ¡oooh! |
| Bedtime routine | Rutina de noche | tpr | Hacer los gestos de la noche en orden |
| Bee rhymes with tree | Bee rima con tree | tpr | Volar y estirarse como árbol |
| Beep | Pitar | tpr | Tocar un claxon imaginario con la palma |
| Beep beep, nose! | ¡Pi pi, nariz! | tpr | Apretar la nariz haciendo «pi pi» |
| Beep, beep! | ¡Pi, pi! | tpr | Apretar un claxon imaginario dos veces |
| Beep, beep, bus! | ¡Pi, pi, autobús! | tpr | Pulsar una bocina imaginaria |
| Bees build hexagons because they fit together | Las abejas hacen hexágonos porque encajan | tpr | Juntar las manos en hexágono |
| Before and after | Antes y después | tpr | Señalar el pañal sucio y luego el limpio |
| Beginning | Comienzo | leccions, tpr | Levantar un dedo |
| Behind my hands | Detrás de mis manos | tpr | Esconderse detrás de las manos |
| Behind the clouds | Detrás de las nubes | tpr | Esconderse detrás de los brazos y asomarse de nuevo |
| Behind the tree | Detrás del árbol | tpr | Esconderse detrás de una compañera que hace de árbol |
| Bell button | Botón de parada | tpr | Pulsar el botón de parada |
| Belly | Barriga | tpr | Hacer círculos en la barriga |
| Belly button | Ombligo | tpr | Buscarse el ombligo con un dedo |
| Belly slide | Deslizarse de barriga | tpr | Tumbarse de barriga y deslizarse |
| Below | Por debajo | tpr | Señalar debajo de la mesa |
| Bench | Banco | tpr | Sentarse en un banco imaginario y descansar |
| Bend | Flexionar | tpr | Flexionar las rodillas y bajar un poco |
| Bend in the wind | Doblarse con el viento | tpr | Inclinarse de un lado a otro |
| Bend knees | Doblar las rodillas | leccions, tpr | Agacharse doblando las rodillas |
| Bendy | Flexible | tpr | Doblarse hacia adelante |
| Berry | Baya | tpr | Coger una baya imaginaria |
| Beside | Al lado | tpr | Ponerse al lado de un amigo |
| Best moment | Mejor momento | tpr | Levantar un dedo sonriendo |
| Between | En medio | tpr | Ponerse entre dos amigos |
| Between your fingers too! | ¡También entre los dedos! | tpr | Frotar entre los dedos |
| Bib | Babero | 0-2, tpr | Atar el babero al cuello despacio |
| Big bubble | Burbuja grande | 0-2, leccions, tpr | Abrir los brazos como una burbuja |
| Big drum | Bombo | tpr | Golpear el bombo al marchar |
| Big heavy bear! Stomp! | ¡Oso grande y pesado! ¡Pum! | leccions | — |
| Big like a giant | Grande como un gigante | tpr | Estirarse mucho y caminar a pasos grandes |
| Big mouth, hippo! | ¡Boca grande, hipopótamo! | tpr | Abrir mucho la boca |
| Big school | Escuela de los mayores | tpr | Señalar lejos |
| Big smile | Sonrisa grande | tpr | Sonreír enseñando los dientes |
| Big steps and little steps | Pasos grandes y pequeños | tpr | Alternar pasos largos y cortos |
| Big toe | Dedo gordo | tpr | Mover el dedo gordo del pie |
| Big waves! | ¡Olas grandes! | tpr | Subir los brazos muy alto y bajarlos de golpe |
| Big! | grande | 0-2, leccions, tpr | Abrir los brazos haciéndose gigantes |
| Big, bigger, biggest | Grande, más grande, el más grande | tpr | Abrir los brazos en tres pasos |
| Bigger | Más grande | tpr | Abrir más los brazos |
| Bigger and bigger | Cada vez más grande | tpr | Abrir las manos cada vez más |
| Bigger now | Más grande ahora | tpr | Medir al bebé con la mano |
| Bigger school | Colegio más grande | tpr | Abrir los brazos |
| Bigger than an ant, smaller than a mouse | Más grande que una hormiga, más pequeño que un ratón | tpr | Abrir los dedos poco y luego más |
| Biggest | El más grande | tpr | Abrir los brazos al máximo |
| Bike ride | Paseo en bici | tpr | Pedalear en el aire |
| Binoculars | Prismáticos | tpr | Hacer prismáticos con las manos |
| Bird feeder | Comedero de pájaros | tpr | Llenar el comedero con semillas |
| Birdseed | Alpiste | tpr | Echar alpiste en la mano |
| Bite! | morder, dar un mordisco | 0-2, leccions, tpr | Dar un mordisco pequeño a una manzana imaginaria |
| Bitter | Amargo, amarga | tpr | Poner cara de sorpresa y arrugar la nariz |
| Bittersweet | Agridulce | tpr | Sonreír y abrazar |
| Blade of grass | Brizna de hierba | tpr | Coger una brizna de hierba |
| Blanket | Manta | tpr | Taparse con una manta imaginaria hasta la barbilla |
| Blanket and a book | Manta y un libro | tpr | Taparse y abrir un libro |
| Blanket fort | Cabaña de mantas | 0-2, leccions, tpr | Hacer una cabaña con una manta |
| Blast off | Despegar | tpr | Saltar con los brazos arriba |
| blend | mezclar | leccions, tpr | Girar las manos como una batidora |
| Blindfold | Venda | tpr | Taparse los ojos con las manos |
| Blink | Parpadear | tpr | Cerrar y abrir los ojos muy rápido |
| block | bloque | leccions | — |
| Block the water | Parar el agua | tpr | Poner las manos delante |
| Blocks | Bloques | tpr | Poner una mano encima de la otra como bloques |
| Bloom | Florecer | tpr | Abrir los brazos de golpe como una flor que se abre |
| Bloom! Big bright flowers! | ¡Florece! ¡Flores grandes y brillantes! | leccions | — |
| Blooming | En flor | tpr | Abrir los brazos grandes |
| Blow | Soplar | leccions, tpr | Soplar fuerte una hoja imaginaria |
| Blow a raspberry | Hacer pedorretas | tpr | Hacer una pedorreta en la barriga |
| Blow away | Llevárselo el viento | leccions, tpr | Soplar y dejar volar una hoja |
| Blow bubbles | Hacer burbujas | tpr | Soplar despacio por la varita |
| Blow bubbles in water | Hacer burbujas en el agua | tpr | Soplar en el agua con los labios |
| Blow harder! | ¡Sopla más fuerte! | tpr | Soplar con fuerza |
| Blow like the autumn wind | Sopla como el viento de otoño | leccions | — |
| Blow on it | Soplar | tpr | Soplar la comida antes de darla |
| Blow seeds | Soplar semillas | leccions, tpr | Soplar un diente de león |
| Blow the boat | Soplar el barco | tpr | Soplar fuerte |
| Blow to cool | Soplar para enfriar | tpr | Soplar la comida caliente |
| Blow your nose | Sonarse | tpr | Sonarse la nariz con un pañuelo |
| Blowhole | Espiráculo | leccions, tpr | Soplar hacia arriba |
| Blub, blub, blub | Glu, glu, glu | tpr | Abrir y cerrar la boca como un pez |
| Blue and yellow | Azul y amarillo | tpr | Enseñar un objeto azul y otro amarillo |
| Blue and yellow make green | Azul y amarillo hacen verde | tpr | Juntar dos manos |
| Blue cup | Vaso azul | 0-2, tpr | Enseñar el vaso azul |
| Blue, which is cold, makes green. | El azul, que es frío, hace verde. | frases | — |
| Blueprint | Diseño | tpr | Dibujar un plano en el aire |
| Blustery | Ventoso | tpr | Mover el cuerpo con el viento |
| Board game | Juego de mesa | tpr | Mover una ficha |
| Boat trip | Viaje en barco | tpr | Balancearse como en el barco |
| Boats on the water | Barcos en el agua | tpr | Mover las manos como barcos |
| Bob | Subir y bajar | tpr | Subir y bajar al bebé suavemente |
| Bob on the water | Flotar subiendo y bajando | tpr | Subir y bajar despacio |
| Body | Cuerpo | tpr | Tocar todo el cuerpo de arriba abajo |
| Boil | Hervir | tpr | Hacer burbujas con las manos |
| Bonfire smoke | Humo de la hoguera | tpr | Subir las manos en espiral |
| Bonnet | Gorrito | tpr | Poner y quitar un gorrito ante el espejo |
| Bony | Huesudo | tpr | Tocar el tobillo |
| Boo! | ¡Bu! | tpr | Descubrir la cara de repente y sonreír |
| Boom goes the thunder | Bum, hace el trueno | tpr | Golpear en las piernas una vez fuerte |
| Boom-boom, boom-boom | Pum-pum, pum-pum | tpr | Golpear suave en el pecho |
| Booming | Retumbante | tpr | Golpear fuerte el tambor una vez |
| Boot print | Huella de la bota | tpr | Pisar en la tierra y mirar la huella |
| Boots on, let's go! | ¡Botas puestas, vamos! | tpr | Pisar fuerte hacia la puerta |
| Both sides | Las dos partes | tpr | Señalar a uno y a otro |
| Bottle | Botella | tpr | Sujetar una botella imaginaria con las dos manos |
| Bottom | Culito | tpr | Dar palmaditas suaves en el culito |
| Bounce | Botar | tpr | Botar una pelota imaginaria con la mano |
| Bounce on knee | Saltar en la rodilla | leccions, tpr | Hacer botar al bebé en la rodilla |
| Bounce up and down | Rebotar | tpr | Botar en el sitio |
| Bouncy | Saltarín | tpr | Botar en el puf |
| Bow to the audience | Saludar al público | tpr | Inclinar el títere |
| Box lid | Tapa de la caja | tpr | Cerrar la tapa de la caja |
| Bracken | Helecho | tpr | Extender la mano como un helecho |
| Brackish | Salobre | tpr | Probar y dudar |
| Brake | Frenar | tpr | Parar y echar el cuerpo atrás |
| Branch | Rama | tpr | Extender un brazo y mover los dedos como hojas |
| Brave | Valiente | tpr | Poner las manos en la cintura y sacar pecho |
| Brave and kind | Valiente y amable | leccions, tpr | Poner el puño y luego la mano abierta |
| Brave knight | Caballero valiente | tpr | Levantar el pecho |
| Breath | Aliento | 0-2, tpr | Echar el aliento en el cristal |
| Breathe | Respirar | tpr | Llenar de aire la barriga y soltarlo despacio |
| Breathe calmly | Respirar tranquilo | tpr | Inspirar y espirar despacio |
| Breathe in slowly | Coger aire despacio | tpr | Inspirar despacio por la nariz |
| Breathe in, breathe out | Coge aire, echa aire | tpr | Inflar y desinflar el pecho |
| Breathe slowly | Respirar despacio | tpr | Inflar la barriga y soltarla despacio |
| Breathing buddy | Compañero de respiración | tpr | Poner un peluche en la barriga |
| Breathtaking | Impresionante | tpr | Abrir la boca sorprendidos |
| Breeze | Brisa | tpr | Soplar suave en la cara del bebé |
| Breezy | Con brisa | tpr | Mover suavemente los brazos como la brisa |
| Breezy evening | Tarde fresca | tpr | Abanicarse despacio |
| bright | vivo, brillante | leccions, tpr | Abrir las manos de golpe como un rayo de luz |
| Bright red | Rojo vivo | tpr | Señalar algo rojo vivo |
| Brightest | El más brillante | leccions, tpr | Señalar la luz más brillante |
| Brightest star | La estrella más brillante | tpr | Señalar una estrella |
| Brilliant | Genial | tpr | Levantar los brazos y decir «¡sí!» |
| Bring | Traer | tpr | Traer un juguete a la alfombra |
| broken | roto | leccions | — |
| Brother | Hermano | tpr | Señalar al hermano y sonreír |
| Browse | Hojear | tpr | Pasar hojas despacio |
| Brr, freezing hands! | ¡Brr, manos heladas! | tpr | Soplar en las manos |
| Brr, so cold! | ¡Brr, qué frío! | leccions, tpr | Temblar y frotar los brazos |
| Brr, the Arctic! | ¡Brr, el Ártico! | tpr | Temblar y sonreír |
| Brrr, it's cold! | ¡Brrr, qué frío! | tpr | Encoger los hombros y temblar diciendo «brrr» |
| Brush head | Cabeza del cepillo | tpr | Enseñar la cabeza del cepillo |
| Brush up and down | Cepillar arriba y abajo | leccions, tpr | Mover el cepillo arriba y abajo |
| Brush, brush, brush | Cepilla, cepilla, cepilla | tpr | Mover el cepillo en el aire |
| Bubble machine | Máquina de burbujas | tpr | Señalar las burbujas que salen |
| Bubble mixture | Agua con jabón | 0-2, leccions, tpr | Mojar la varita en el bote |
| Bubble trail | Rastro de burbujas | tpr | Hacer burbujas con la boca |
| Bubbles everywhere | Burbujas por todas partes | tpr | Señalar alrededor |
| Bubbly | Burbujeante | tpr | Abrir y cerrar los dedos como burbujas que estallan |
| Bubbly baby | Bebé risueño | tpr | Hacer cosquillas y sonreír |
| Bucket of water | Cubo de agua | tpr | Llevar el cubo con cuidado |
| Buckle up | Abrocharse el cinturón | tpr | Cruzar el cinturón en el pecho |
| Bud | Capullo | 0-2, tpr | Cerrar la mano como un capullo |
| Buddy bench | Banco de los amigos | tpr | Sentarse y hacer sitio |
| Bug hotel | Hotel de insectos | tpr | Construir un hotel con ramas |
| Build | Construir | tpr | Apilar bloques imaginarios cada vez más altos |
| Build a nest | Hacer un nido | leccions, tpr | Entrelazar los dedos |
| Build high | Construir alto | tpr | Poner bloques hasta arriba |
| Builder | Albañil | tpr | Poner ladrillos imaginarios |
| Building blocks | Bloques de construcción | tpr | Poner un bloque sobre otro |
| Bumpy | Rugoso, rugosa | tpr | Tocarse el brazo con pequeños golpecitos |
| Bumpy ride | Viaje con baches | tpr | Botar en la silla |
| Bumpy walnut | Nuez rugosa | tpr | Rodar una nuez entre las manos |
| Bunch of grapes | Racimo de uvas | tpr | Colgar la mano como un racimo |
| Buoy | Boya | tpr | Subir y bajar como una boya |
| Buoyant | Que flota | tpr | Subir las manos despacio |
| Burp | Eructar | tpr | Dar palmaditas en la espalda después de comer |
| Burst | Reventar | tpr | Tocar una burbuja con el dedo |
| Bury | Enterrar | tpr | Taparse los pies con arena imaginaria |
| Busca el color | Busca el color | 0-2-cancion | — |
| Busy | Ocupado, ocupada | tpr | Mover las manos muy rápido como quien trabaja mucho |
| Busy city | Ciudad con vida | tpr | Moverse rápido |
| Busy fingers | Dedos inquietos | tpr | Mover los dedos sin parar |
| Busy harbour | Puerto activo | tpr | Moverse trabajando |
| Busy port | Puerto con trabajo | tpr | Mover los brazos trabajando |
| Busy street | Calle con gente | tpr | Mirar a un lado y a otro |
| Buttercup | Botón de oro | tpr | Poner una flor amarilla en la barbilla |
| Butterfly print | Estampa de mariposa | tpr | Pintar y doblar el papel |
| Button | Abrochar | tpr | Abrochar botones imaginarios en el pecho |
| Button nose | Nariz de botón | tpr | Apretar la nariz como un botón |
| Buy bread | Comprar pan | tpr | Dar una moneda imaginaria |
| Buzz | Zumbar | tpr | Hacer «bzzz» con los labios |
| Buzz, buzz! | ¡Bzzz, bzzz! | tpr | Volar como una abeja diciendo «bzzz» |
| By bedtime, we will have seen every colour. | A la hora de dormir, habremos visto todos los colores. | frases | — |
| By Friday, the room will have turned red. | El viernes, la habitación se habrá vuelto roja. | frases | — |
| By the sea | A la orilla del mar | tpr | Sentarse juntos mirando el mar |
| Bye for now! | ¡Hasta luego! | tpr | Saludar desde la puerta |
| Bye-bye, boat! | ¡Adiós, barco! | tpr | Saludar al barco |
| Cabeza, hombros, rodillas y pies | Cabeza, hombros, rodillas y pies | 0-2-cancion | — |
| Cable car | Teleférico | tpr | Subir la mano despacio |
| Calf | Cría | tpr | Acurrucarse junto a un amigo |
| Call your friend: come and help us! | Llama a tu amigo: ¡ven a ayudarnos! | leccions | — |
| Calm | Tranquilo, tranquila | leccions, tpr | Respirar hondo y dejar caer los hombros |
| Calm and clear | Tranquilo y claro | tpr | Hablar despacio |
| Calm down | Calmarse | tpr | Respirar despacio con las manos en la barriga |
| Calm jar | Bote de la calma | tpr | Agitar y mirar cómo baja |
| Calm sea | Mar tranquilo | leccions, tpr | Pasar la mano plana |
| Calm sea: move the cloth very slowly | Mar en calma: mueve la tela muy despacio | leccions | — |
| Calm voice | Voz tranquila | tpr | Hablar despacio |
| Calm-down corner | Rincón de la calma | tpr | Sentarse en el rincón |
| Calmer | Más tranquilo | tpr | Bajar los hombros |
| Campfire | Hoguera de campamento | tpr | Sentarse alrededor |
| Campsite | Camping | tpr | Hacer una tienda con las manos |
| Can I have more peas? | ¿Me pones más guisantes? | tpr | Extender el plato |
| Can I have one? | ¿Puedo coger una? | tpr | Extender la mano pidiendo |
| Can I help you? | ¿Puedo ayudarte? | leccions | — |
| Can I keep it? | ¿Puedo quedármelo? | tpr | Apretar el tesoro contra el pecho |
| Can I play? | ¿Puedo jugar? | tpr | Acercarse y abrir la mano |
| Can I try some? | ¿Puedo probar? | tpr | Extender la mano |
| Can the stone float? | ¿Puede flotar la piedra? | frases | — |
| Can we trade? | ¿Hacemos un cambio? | leccions | — |
| Can you catch me? | ¿Puedes pillarme? | tpr | Correr riendo |
| Can you feel your heart? | ¿Sientes el corazón? | tpr | Poner la mano en el pecho |
| Can you find something red? | ¿Encuentras algo rojo? | tpr | Buscar alrededor |
| Can you help me build? | ¿Me ayudas a construir? | tpr | Extender un bloque a un amigo |
| Can you see the Plough? | ¿Ves el Carro? | tpr | Unir puntos en el aire |
| Can you swim? | ¿Sabes nadar? | tpr | Nadar con los brazos y mirar a otra persona |
| Can you write your name? | ¿Sabes escribir tu nombre? | tpr | Escribir en el aire |
| Cannon | Cañón | tpr | Hacer un tubo con los brazos |
| Canopy | Copa de los árboles | tpr | Abrir los brazos por encima de la cabeza |
| Cape | Capa | tpr | Girar con la capa puesta |
| Captain | Capitán | tpr | Ponerse delante del grupo |
| Card | Postal | leccions, tpr | Entregar una postal |
| Card making | Hacer postales | tpr | Doblar y pintar en el aire |
| Cardigan | Rebeca | 0-2, tpr | Abotonar la rebeca |
| Care for the sea | Cuidar el mar | tpr | Abrazar el aire |
| Carefree | Despreocupado | tpr | Saltar libres |
| careful | cuidadoso | leccions, tpr | Caminar despacio mirando a un lado y al otro |
| Careful with nature | Cuidadoso con la naturaleza | tpr | Posar la mano suave |
| Careful with the egg | Cuidado con el huevo | tpr | Coger el huevo con mucho cuidado |
| Careful, it's hot | Cuidado, quema | tpr | Soplar y abanicar la mano |
| Caress | Acariciar | 0-2, leccions, tpr | Pasar la mano muy despacio por el brazo |
| Caring | Atento | tpr | Preguntar «¿estás bien?» con la mano |
| Caring for others | Cuidador | tpr | Abrazar un peluche |
| Carnival float | Carroza | tpr | Saludar desde una carroza |
| Carnival Freeze! | ¡Congelados de Carnaval! | leccions | — |
| Carol | Villancico | tpr | Cantar un villancico bajito |
| Carol singers | Cantantes de villancicos | tpr | Cantar en grupo |
| Carrot stick | Palito de zanahoria | tpr | Hacer como que se mastica un palito de zanahoria |
| Carry | Llevar | tpr | Llevar una cesta imaginaria con el brazo doblado |
| Carry carefully | Llevar con cuidado | tpr | Llevar la bandeja despacio |
| Cast a net | Lanzar la red | tpr | Abrir los brazos lanzando |
| Cast a spell | Hacer un hechizo | tpr | Mover la varita y decir «abracadabra» |
| Castle wall | Muralla | tpr | Caminar rozando una pared |
| Castrelos Park | Parque de Castrelos | tpr | Señalar el parque en el mapa |
| Cat and hat rhyme! | ¡Cat y hat riman! | tpr | Señalar la cabeza y hacer un gato |
| Catch | Atrapar | tpr | Cerrar las manos en el aire como si atrapáramos algo |
| Catch drops | Coger gotas | tpr | Abrir la mano bajo la lluvia fina |
| Catch me! | ¡Atrápame! | tpr | Alejarse despacio y dejarse atrapar |
| Catch the frisbee! | ¡Coge el disco! | tpr | Extender las manos |
| Catch the snowflake | Atrapa el copo | tpr | Estirar la mano y cerrarla suave sobre un copo |
| Catch up | Alcanzar | tpr | Correr detrás y tocar el hombro |
| Ceiling | Techo | tpr | Señalar el techo |
| Celebrate | Celebrar | tpr | Dar palmas y bailar juntos |
| Celebrate as a team | Celebrar en equipo | tpr | Chocar las manos todos |
| Celebration | Celebración | tpr | Dar palmas contentos |
| Centipede | Ciempiés | tpr | Mover muchos dedos despacio |
| Centre | Centro | tpr | Señalar el centro del cuerpo |
| Ceremony | Ceremonia | tpr | Caminar despacio y erguido |
| Certificate | Certificado | tpr | Recibir un papel con las dos manos |
| Chalk | Tiza | tpr | Dibujar en el suelo con la tiza |
| Chalky | De tiza | tpr | Soplar el polvo de las manos |
| Challenge | Desafío | tpr | Poner los puños fuertes |
| Change | Cambiar | 0-2, leccions, tpr | Cambiar el pañal contando «uno, dos» |
| Change over time | Cambiar con el tiempo | tpr | Pasar de un gesto pequeño a uno grande |
| Change the ending | Cambiar el final | tpr | Girar la mano al revés |
| Change voices | Cambiar de voz | tpr | Hablar grave y luego agudo |
| Changed a little, the plane flew further. | Cambiado un poco, el avión voló más lejos. | frases | — |
| Changing mat | Cambiador | tpr | Tumbar al bebé en el cambiador |
| Channel | Canal | tpr | Hacer un canal con las manos |
| Chapel | Capilla | tpr | Hacer un tejado en punta con las manos |
| Character | Personaje | tpr | Poner la cara de un personaje |
| Chart | Tabla | tpr | Marcar una señal en una tabla |
| Chase | Perseguir | tpr | Caminar rápido detrás de una compañera sin tocarla |
| Chase after | Ir detrás | tpr | Gatear detrás de la pelota |
| Cheap | Barato | tpr | Enseñar una moneda |
| Cheek to cheek | Mejilla con mejilla | tpr | Juntar mejilla con mejilla |
| Cheeks | Mejillas | tpr | Inflar las mejillas y tocarlas con los dedos |
| Cheer | Animar | tpr | Levantar los brazos y decir «¡bravo!» |
| Cheerful | Alegre | tpr | Abrir los ojos y sonreír mucho |
| Cheerful face | Cara alegre | tpr | Sonreír muy grande |
| Cheering crowd | Público aplaudiendo | tpr | Aplaudir fuerte |
| Chest | Pecho | tpr | Poner la mano en el pecho |
| Chestnut husk | Erizo de castaña | 0-2, tpr | Enseñar el erizo sin tocarlo |
| Chestnut stall | Puesto de castañas | tpr | Señalar el puesto de castañas |
| Chew | Masticar | tpr | Masticar despacio con la boca cerrada |
| Chew on | Mordisquear | tpr | Dejar morder el mordedor limpio |
| Childhood | Infancia | tpr | Encogerse pequeño |
| Chilly | Fresquito | tpr | Frotar los brazos como con frío |
| Chilly wind | Viento fresco | tpr | Abrazarse por el frío |
| Chin | Barbilla | tpr | Tocarse la barbilla con el dedo índice |
| Chirp | Piar | tpr | Hacer «pío» con los labios |
| Chirpy | Cantarín | tpr | Silbar y sonreír |
| Chocolate | Chocolate | tpr | Beber de una taza caliente con cuidado |
| Chocolatey | Achocolatado | tpr | Relamerse |
| Choir | Coro | tpr | Cantar juntos en fila |
| Chomp | Masticar | tpr | Mover la boca como una vaca comiendo hierba |
| Choose | Elegir | tpr | Dudar entre dos manos y elegir una |
| Choose fruit | Escoger fruta | tpr | Mirar y escoger una |
| Choose together | Elegir juntos | tpr | Levantar las manos todos |
| Chop | Trocear | tpr | Trocear con la mano plana |
| Choppy | Picado | tpr | Mover las manos en olas pequeñas |
| Chore | Tarea de casa | tpr | Barrer en el aire |
| Chorus | Estribillo | tpr | Cantar todos a la vez |
| Chubby | Regordete | tpr | Apretar suave las piernas regordetas |
| Chubby cheeks | Mofletes | tpr | Inflar los mofletes y soltar el aire |
| Chuckle | Reír bajito | tpr | Reír bajito cerca de la oreja |
| Chunky | Grueso | tpr | Tocar un jersey grueso |
| Circle around | Dar vueltas alrededor | tpr | Caminar alrededor de un amigo |
| Circle time | Asamblea | tpr | Sentarse en círculo |
| Circular | Circular | tpr | Dibujar un círculo grande |
| City lights | Luces de la ciudad | tpr | Abrir y cerrar las manos en el aire |
| Clap a pattern | Dar palmas en patrón | tpr | Palma, palma, pie |
| Clap after me | Da palmas después de mí | tpr | Repetir las palmas |
| Clap and stop | Palmada y para | tpr | Dar palmas y parar de golpe |
| Clap flippers | Batir las aletas | tpr | Dar palmas como una foca |
| Clap high, clap low | Palmas arriba, palmas abajo | leccions | — |
| Clap pattern | Serie de palmas | tpr | Dar una serie de palmas |
| Clap the rhythm on your chest | Marca el ritmo con palmadas en el pecho | leccions | — |
| Clap twice | Dar dos palmadas | tpr | Dar dos palmadas |
| Clap, clap, stamp! | ¡Palma, palma, pisada! | tpr | Dar dos palmas y pisar |
| Clap, stamp, clap, stamp, what comes next? | Palma, pie, palma, pie, ¿qué viene ahora? | tpr | Hacer el patrón y parar |
| Clapperboard | Claqueta | tpr | Cerrar los brazos como una claqueta |
| Clapping | Dando palmas | tpr | Dar palmitas |
| Class charter | Carta de la clase | tpr | Firmar un papel imaginario |
| Class photo | Foto de la clase | tpr | Juntarse todos para la foto |
| Class song | Canción de la clase | tpr | Cantar todos juntos |
| Classmate | Compañero | tpr | Señalar a un compañero |
| Classroom | Aula | tpr | Abrir los brazos dentro del aula |
| Classroom job | Encargo de la clase | tpr | Señalar el propio encargo en el panel |
| Clean | Limpio, limpia | tpr | Enseñar las manos limpias y sonreír |
| Clean and clear | Limpio y claro | tpr | Mover las manos suaves |
| Clean and shiny | Limpio y brillante | tpr | Hacer brillar el espejo con el paño |
| Clean beach | Playa limpia | tpr | Enseñar la mano vacía |
| Clean face | Cara limpia | tpr | Enseñar la cara limpia en el espejo |
| Clean hands, happy baby | Manos limpias, bebé contento | tpr | Enseñar las manos y sonreír |
| Clean up, clean up | A recoger, a recoger | tpr | Cantar y recoger |
| Clear | Despejado, despejada | tpr | Abrir las manos como si apartaran las nubes |
| Clear table | Mesa despejada | tpr | Pasar la mano por la mesa despejada |
| Clear voice | Voz clara | tpr | Hablar alto y despacio |
| Clever | Listo, lista | tpr | Tocarse la frente con un dedo y sonreír |
| Clever idea | Idea inteligente | tpr | Señalar la cabeza sonriendo |
| Cliff | Acantilado | leccions, tpr | Poner la mano vertical |
| Cliff nest | Nido en el acantilado | tpr | Hacer un nido en la pared |
| Climb a ladder | Subir una escalera | leccions, tpr | Subir alternando manos y pies |
| Climb aboard | Subir a bordo | tpr | Dar un paso grande |
| Climb over | Pasar por encima | tpr | Pasar la pierna por encima |
| Climb the oak tree and hide your nuts | Sube al roble y esconde tus nueces | leccions | — |
| Climb up the hill | Subir el monte | tpr | Caminar inclinado hacia delante |
| Close | Cerrar | tpr | Cerrar un paraguas imaginario juntando las manos |
| Close the book | Cerrar el libro | tpr | Cerrar el libro despacio |
| Close to me | Cerca de mí | tpr | Acercar al bebé al pecho |
| Close your eyes and listen | Cierra los ojos y escucha | tpr | Cerrar los ojos y quedarse quietos escuchando |
| Close your eyes and taste | Cierra los ojos y prueba | tpr | Cerrar los ojos |
| Clothes peg | Pinza | tpr | Abrir y cerrar la pinza |
| Clover | Trébol | tpr | Enseñar tres dedos como un trébol |
| Cluck | Cacarear | tpr | Hacer «coc coc» moviendo los codos |
| Clue | Pista | tpr | Señalar algo con una lupa |
| Coat on the peg | Abrigo en la percha | leccions, tpr | Colgar el abrigo |
| Coax | Animar con cariño | tpr | Llamar al bebé con voz dulce |
| Cobbles | Adoquines | tpr | Pisar con cuidado |
| Cockle | Berberecho | tpr | Abrir y cerrar las manos como una concha |
| Cold and fresh | Frío y fresco | tpr | Tocar una fruta de la nevera |
| Cold winter night: curl up and do not move | Noche fría de invierno: acurrúcate y no te muevas | leccions | — |
| Colder | Más frío | leccions, tpr | Temblar más |
| Collar | Collar | 0-2, tpr | Tocar el collar del peluche |
| Collect | Juntar | tpr | Recoger conchas imaginarias y guardarlas en la mano |
| Collect leaves | Coleccionar hojas | tpr | Meter hojas en una bolsa |
| Collect rain | Recoger lluvia | tpr | Poner un vaso fuera |
| Colour | Color | tpr | Señalar tres cosas de colores diferentes |
| Colour by colour | Color a color | tpr | Tocar cosas del aula de un color cada vez |
| Colour card | Tarjeta de color | 0-2, tpr | Enseñar una tarjeta de color |
| Colour hunt | Búsqueda de colores | tpr | Buscar algo verde |
| Colour wheel | Rueda de colores | tpr | Girar la mano en círculo |
| Colourful | De colores | tpr | Señalar cosas de muchos colores en el aula |
| Colourful plate | Plato de colores | leccions, tpr | Señalar los colores del plato |
| Colourful reef | Arrecife de colores | tpr | Mover las manos de colores |
| Come | Venir | tpr | Llamar con el brazo para que se acerquen |
| Come here for a hug | Ven que te abrazo | tpr | Abrir los brazos y esperar |
| Come here, puppy | Ven aquí, cachorrito | tpr | Llamar con un gesto suave y dar palmadas en las rodillas |
| Come out of the egg | Salir del huevo | leccions, tpr | Salir de una bola con el cuerpo |
| Come under my umbrella | Ven debajo de mi paraguas | leccions | — |
| Comfort | Consolar | tpr | Poner la mano en el hombro de un amigo |
| Comfortable | Cómodo | tpr | Colocar un cojín detrás de la espalda |
| Comfy | Cómodo, cómoda | tpr | Acomodarse en el suelo con una sonrisa |
| Comical | Cómico | tpr | Hacer una mueca graciosa |
| Command | Orden | leccions, tpr | Levantar un dedo antes de la orden |
| Communicate | Comunicarse | tpr | Silbar y responder |
| Community | Comunidad | tpr | Cogerse todos de las manos |
| Compare | Comparar | tpr | Poner dos hojas lado a lado |
| Compare results | Comparar resultados | tpr | Poner las manos lado a lado |
| Compassionate | Compasivo | tpr | Poner las manos en el pecho |
| Compliment | Cumplido | tpr | Decir algo bonito sonriendo |
| Compost | Compost | tpr | Echar restos de fruta |
| Compromise | Término medio | leccions, tpr | Juntar las manos en el medio |
| Condense | Condensarse | tpr | Juntar las manos en nube |
| Conduct | Dirigir la música | tpr | Mover la batuta al ritmo |
| Conductor | Director de orquesta | tpr | Mover una batuta |
| Cone | Cono | tpr | Rodear el cono corriendo |
| Confetti cannon | Cañón de confeti | tpr | Abrir las manos de golpe |
| Confident | Seguro | tpr | Levantar la cabeza |
| Conga line | Fila de conga | tpr | Bailar en fila con las manos en los hombros |
| Congratulations, class! | ¡Enhorabuena, clase! | tpr | Aplaudir |
| Connect | Conectar | tpr | Unir dos piezas |
| Connect the dots | Unir los puntos | tpr | Unir puntos con el dedo |
| Considerate | Considerado | tpr | Esperar con las manos en el regazo |
| Constellation | Constelación | tpr | Unir puntos en el aire |
| Construction site | Obra | tpr | Ponerse un casco imaginario |
| Content | Satisfecho | tpr | Dejar al bebé tranquilo en el regazo |
| Continue | Continuar | tpr | Seguir el movimiento |
| Coo | Hacer gorgoritos | tpr | Responder a los sonidos del bebé con sonidos suaves |
| Coo coo | Arrullo | tpr | Arrullar como una paloma |
| Cool | Fresquito, fresquita | tpr | Soplar suave en la palma de la mano |
| Cool down | Refrescarse | tpr | Mojar la nuca con agua |
| Cool shade | Sombra fresca | tpr | Sentarse a la sombra |
| Cool to touch | Fresco al tacto | tpr | Posar la mano en una piedra fresca |
| Cooperate | Colaborar | tpr | Llevar una caja entre dos |
| Copy | Imitar | 0-2, leccions, tpr | Repetir el gesto que hace el bebé |
| Copy my movements | Copia mis movimientos | leccions, tpr | Moverse y esperar la copia |
| Cork | Corcho | tpr | Echar un corcho y mirarlo flotar |
| Cormorant | Cormorán | tpr | Abrir los brazos a secar |
| Corner | Esquina | tpr | Caminar hasta la esquina |
| Corner piece | Pieza de la esquina | tpr | Señalar la esquina de la pieza |
| Costume | Disfraz | leccions, tpr | Ponerse un disfraz imaginario y dar una vuelta |
| Cosy | Acogedor, acogedora | tpr | Abrazar una manta imaginaria con cara de gusto |
| Cosy corner | Rincón acogedor | tpr | Sentarse en el rincón con cojines |
| Cosy nest | Nido acogedor | tpr | Abrazarse a sí mismo |
| Cot | Cuna | 0-2, tpr | Dejar al bebé en la cuna con cuidado |
| Cotton | Algodón | 0-2, tpr | Pasar un algodón por la mejilla |
| Cotton wool | Algodón | tpr | Limpiar la cara con un algodón |
| Count | Contar | leccions, tpr | Contar con los dedos hasta cinco |
| Count down | Contar hacia atrás | tpr | Contar de cinco a uno con los dedos |
| Count in twos | Contar de dos en dos | leccions, tpr | Saltar dos pasos cada vez |
| Count petals | Contar pétalos | tpr | Contar hasta cinco |
| Count rings | Contar los anillos | tpr | Contar círculos con el dedo |
| Count the days | Contar los días | leccions, tpr | Contar con los dedos |
| Count three leaves and jump over the ring | Cuenta tres hojas y salta por encima del aro | leccions | — |
| Count to twenty | Contar hasta veinte | tpr | Contar mientras se lavan las manos |
| Count votes | Contar votos | tpr | Contar manos con los dedos |
| Countdown | Cuenta atrás | tpr | Bajar los dedos de cinco a cero |
| Countdown to midnight | Contar hasta la medianoche | leccions, tpr | Bajar los dedos |
| Counter | Ficha | tpr | Mover la ficha dos casillas |
| Counting the steps, we measured it. | Contando los pasos, lo medimos. | frases | — |
| Countless | Incontable | tpr | Abrir las manos muchas veces |
| Cover up | Tapar | tpr | Tapar los pies con la manta |
| Cover with soil | Tapar con tierra | tpr | Tapar la semilla con las manos |
| Crack open | Abrir rompiendo | leccions, tpr | Apretar la castaña para abrirla |
| Crack, crack! | ¡Crac, crac! | tpr | Abrir las manos despacio |
| Crackly | Crujiente al tacto | tpr | Arrugar papel para que suene |
| Crackly shell | Cáscara que cruje | tpr | Romper la cáscara y escuchar |
| Cradle | Acunar | tpr | Acunar al bebé en los brazos |
| Cradle song | Canción de cuna | 0-2, tpr | Cantar mientras se mece |
| Crane | Grúa | tpr | Levantar el brazo como una grúa |
| Crate | Caja de fruta | tpr | Llevar una caja |
| Crawl | Gatear | leccions, tpr | Gatear por el suelo un rato |
| Crawl through | Gatear a través | tpr | Gatear por el túnel junto al bebé |
| Crawl under | Gatear por debajo | tpr | Gatear bajo la mesa |
| Crawl under the table | Gatea debajo de la mesa | tpr | Gatear bajo la mesa |
| Crayon pot | Bote de ceras | tpr | Meter las ceras en el bote |
| Crayons in the pot | Ceras en el bote | tpr | Meter las ceras en el bote |
| Creamy | Cremoso, cremosa | tpr | Mover la mano despacio como si removiera nata |
| Create a picture | Crear una imagen | tpr | Dibujar un marco |
| creative | creativo | leccions | — |
| Creep | Avanzar agachado | tpr | Avanzar agachados muy despacio |
| Creep up | Subir despacito | tpr | Subir con los dedos por el brazo |
| Crimson leaf | Hoja carmesí | leccions, tpr | Enseñar una hoja rojo oscuro |
| Crinkly | Arrugado | tpr | Arrugar una hoja seca |
| Crispy | Crujiente | leccions, tpr | Morder algo crujiente |
| Croak | Croar | tpr | Inflar los mofletes y decir «croac» |
| Cross the road | Cruzar la calle | leccions, tpr | Mirar a los lados y caminar |
| Cross your hands and clap with your friend | Cruza las manos y da palmas con tu amigo | leccions | — |
| Crossing | Paso de peatones | tpr | Caminar por las rayas |
| Crowded | Lleno de gente | tpr | Apretarse todos juntos |
| Crowded bus | Autobús lleno | tpr | Apretarse juntos |
| Crumbly | Desmenuzable | tpr | Desmenuzar tierra entre los dedos |
| Crumbs | Migas | tpr | Recoger las migas con los dedos |
| Crumpled | Arrugado | tpr | Arrugar un pañuelo |
| Crunch | Crujir | tpr | Pisar fuerte en el sitio como sobre hojas secas |
| Crunch a carrot | Morder una zanahoria | tpr | Hacer como que se muerde y decir «crac» |
| Crunch leaves | Pisa las hojas | tpr | Pisar hojas imaginarias haciendo «cranch, cranch» |
| Crunch your leaves! | ¡Pisa tus hojas! | leccions | — |
| Crunch, crunch! | ¡Cranch, cranch! | 0-2, leccions | — |
| Crunchy | Crujiente | tpr | Masticar muy fuerte con una cara divertida |
| Crunchy leaves | Hojas crujientes | leccions, tpr | Aplastar hojas en la mano |
| Crunchy path | Camino que cruje | tpr | Pisar sobre hojas secas |
| Crystal-clear | Cristalino | tpr | Mirar a través de los dedos |
| Cube | Cubo | tpr | Hacer un cubo con las manos |
| Cube on the cylinder | Cubo en el cilindro | tpr | Poner el cubo encima |
| Cuddly | Achuchable | tpr | Apretar el peluche contra el pecho |
| Cue | Entrada | tpr | Señalar a un amigo |
| Curious | Curioso, curiosa | tpr | Mirar de cerca con una lupa imaginaria |
| Curious mind | Mente curiosa | tpr | Mirar alrededor preguntando |
| Curl up | Hacerse un ovillo | tpr | Hacerse un ovillo como un gato |
| Curl up on the sofa | Acurrucarse en el sofá | leccions, tpr | Acurrucarse en el sofá |
| Curl up small like a tiny seed | Acurrúcate pequeñito como una semilla | leccions | — |
| Current | Corriente | tpr | Moverse llevado por el agua |
| Curtain | Cortina | tpr | Esconderse detrás de la cortina |
| Curtain call | Saludo final | tpr | Hacer una reverencia |
| Curved | Curvo | tpr | Dibujar una curva en el aire |
| Cushion | Cojín | 0-2, tpr | Apoyar la cabeza en un cojín |
| Cushion circle | Círculo de cojines | tpr | Sentarse cada uno en su cojín |
| Cushion jump | Salto al cojín | tpr | Saltar encima de un cojín |
| cut | cortar | leccions | — |
| Cut a cross | Hacer una cruz | tpr | Dibujar una cruz en el aire |
| Cut it for me. | Córtamela. | frases | — |
| Cut out | Recortar | tpr | Hacer tijeras con los dedos |
| Cut! Once more, please | ¡Corten! Otra vez, por favor | tpr | Cruzar los brazos y repetir |
| Cute | Tierno, tierna | tpr | Juntar las manos bajo la barbilla y sonreír |
| Cylinder | Cilindro | tpr | Rodar un tubo por la mesa |
| Daddy | Papá | tpr | Darse dos palmaditas suaves en el pecho al decir papá |
| Daisy | Margarita | 0-2, tpr | Enseñar una margarita |
| Dam | Presa | tpr | Poner las manos como un muro |
| Damp | Húmedo | tpr | Tocar la ropa húmeda |
| Damp sand | Arena húmeda | tpr | Apretar arena húmeda |
| Dance and freeze | Baila y congélate | leccions, tpr | Bailar y parar de golpe |
| Dance floor | Pista de baile | tpr | Bailar en medio de la sala |
| Dance freely while the drum sings | Baila libre mientras canta el tambor | leccions | — |
| Dandelion | Diente de león | tpr | Soplar un diente de león |
| dangerous | peligroso | leccions | — |
| Dark | Oscuro, oscura | tpr | Taparse los ojos con las manos |
| Darker | Más oscuro | tpr | Señalar la hoja más oscura |
| Darkest shade | El tono más oscuro | tpr | Señalar el más oscuro |
| Dash | Correr rápido | leccions, tpr | Correr unos pasos rápidos |
| Day and night | Día y noche | tpr | Abrir los ojos y cerrarlos |
| Dazzling | Deslumbrante | tpr | Taparse un poco los ojos |
| Deal | Trato | leccions, tpr | Darse la mano |
| Decide | Decidir | tpr | Pensar y asentir |
| Decorate | Decorar | tpr | Colgar adornos en el aire |
| Decoration | Adorno | tpr | Colgar un adorno imaginario |
| Deep | Profundo, profunda | tpr | Bajar la mano muy abajo como en un agua profunda |
| Deep blue | Azul profundo | leccions, tpr | Bajar despacio |
| Deep breath | Respiración profunda | tpr | Inflar la barriga de aire |
| Deep voice | Voz grave | tpr | Hablar muy grave |
| Deeper and deeper | Cada vez más hondo | tpr | Cavar más y más |
| Defend | Defender | tpr | Ponerse un escudo imaginario |
| Delicate | Delicado, delicada | tpr | Coger algo muy frágil con la punta de los dedos |
| Delicate seagrass | Pradera delicada | tpr | Mover las manos suave |
| Deliver | Repartir | tpr | Entregar paquetes |
| Democratic | Democrático | tpr | Levantar la mano y esperar |
| Den | Madriguera | tpr | Agacharse en un rincón |
| Depart | Salir | tpr | Saludar e irse |
| Desk | Pupitre | tpr | Sentarse bien en la mesa |
| Despite the noise, we listened. | A pesar del ruido, escuchamos. | frases | — |
| destination | destino | leccions | — |
| Determined | Decidido | tpr | Apretar los puños con fuerza |
| Dewdrop | Gota de rocío | tpr | Tocar la hierba mojada |
| Dewy | Con rocío | tpr | Pasar la mano por la hierba |
| Dialogue | Diálogo | tpr | Hablar y responder con dos manos |
| Did you hear it? | ¿Lo oíste? | frases | — |
| Difference | Diferencia | tpr | Separar las manos |
| Different | Diferente | tpr | Hacer un gesto distinto al de la compañera |
| Different opinions | Opiniones distintas | tpr | Señalar dos lados |
| Dig | Cavar | leccions, tpr | Cavar en el suelo con las manos |
| Dig a hole | Cavar un agujero | tpr | Cavar con las manos |
| Dig the soil with your hands | Cava la tierra con las manos | leccions | — |
| Dig tunnels | Cavar túneles | tpr | Mover las manos como cavando |
| Diligent | Trabajador | tpr | Secarse la frente con el brazo |
| Dim | Tenue | tpr | Bajar la luz despacio |
| Dimple | Hoyuelo | tpr | Tocar el hoyuelo de la mejilla |
| Dip | Mojar | tpr | Mojar los dedos en el agua |
| Diploma | Diploma | tpr | Recibir un papel con las dos manos |
| Direct | Dirigir | tpr | Mover los brazos dando órdenes |
| Direct traffic | Dirigir el tráfico | tpr | Mover los brazos dando paso |
| Direction | Dirección | tpr | Señalar hacia dónde se va |
| Director | Director | leccions, tpr | Dar una palmada de claqueta |
| Dirty | Sucio, sucia | tpr | Mirarse las manos con cara de asco divertido |
| Disagree kindly | Discrepar con amabilidad | tpr | Negar sonriendo |
| Disagreement | Desacuerdo | tpr | Negar con la cabeza |
| Disco | Discoteca | tpr | Señalar arriba y abajo bailando |
| Discover | Descubrir | tpr | Dejar al bebé tocar la cesta |
| Distant | Distante | tpr | Señalar lejos |
| Dive | Zambullirse | tpr | Juntar las manos en punta y bajar hacia el suelo |
| Dive deep | Bucear hondo | tpr | Bajar despacio |
| Dive deep and find a white shell | Bucea hondo y busca una concha blanca | leccions | — |
| Dive for fish | Zambullirse a pescar | tpr | Bajar las manos juntas en picado |
| Dive, catch, fly! | ¡Zambúllete, coge, vuela! | tpr | Bajar, coger y subir |
| Diver | Buceador | tpr | Nadar despacio con burbujas |
| Do not worry, be gentle | No te preocupes, con delicadeza | leccions | — |
| Do you know who is holding it? | ¿Sabes quién lo está sujetando? | frases | — |
| Do you remember our first day? | ¿Recuerdas nuestro primer día? | tpr | Levantar un dedo |
| Do you remember? | ¿Te acuerdas? | tpr | Tocar la cabeza |
| Do you want to play with us? | ¿Quieres jugar con nosotros? | tpr | Abrir el círculo |
| doctor / vet | doctor / veterinario | leccions | — |
| Dodge | Esquivar | tpr | Apartarse de una pelota blanda |
| Does it float or sink? | ¿Flota o se hunde? | tpr | Señalar arriba o abajo |
| Does that tickle? | ¿Hace cosquillas? | tpr | Hacer cosquillas despacio y parar |
| Doll | Muñeca | tpr | Peinar con cariño una muñeca imaginaria |
| Doll clothes | Ropa de muñeca | tpr | Lavar la ropa de la muñeca |
| Dolphin pod | Grupo de delfines | leccions, tpr | Saltar juntos con las manos en arco |
| Dolphin watching | Observación de delfines | tpr | Mirar con los prismáticos |
| Dolphins breathe air through a blowhole | Los delfines respiran por el espiráculo | tpr | Soplar hacia arriba |
| Don't move a muscle! | ¡No te muevas nada! | tpr | Quedarse como estatua |
| Don't touch, just look | No toques, solo mira | tpr | Poner las manos detrás |
| Donate | Donar | tpr | Meter algo en la caja |
| Donation box | Caja de donaciones | tpr | Meter una prenda en la caja |
| Dot | Punto | tpr | Tocar un punto en el aire con un dedo |
| Dough | Masa | tpr | Aplastar la masa con la palma |
| Down | Abajo | 0-2, leccions, tpr | Agacharse hasta tocar el suelo |
| Down the ramp | Por la rampa abajo | tpr | Soltar la pelota arriba de la rampa |
| Down to the ground | Hasta el suelo | tpr | Bajar la hoja hasta el suelo |
| Downstream | Río abajo | tpr | Mover la mano hacia abajo |
| Dozen | Docena | tpr | Enseñar diez dedos y dos más |
| Drain | Alcantarilla | tpr | Señalar el agua que se va |
| Drain away | Escurrirse | tpr | Abrir las manos hacia abajo |
| Dramatic | Dramático | leccions, tpr | Llevar la mano a la frente |
| Draw a shape | Dibujar una forma | tpr | Dibujar una forma en el suelo |
| Draw circles | Dibujar círculos | tpr | Dibujar círculos con el dedo en la espalda |
| Draw with chalk | Dibujar con tiza | tpr | Dibujar en el suelo |
| Drawer | Cajón | tpr | Abrir y cerrar el cajón |
| Drawing folder | Carpeta de dibujos | tpr | Abrir la carpeta |
| Dream | Sueño | tpr | Apoyar la cabeza en las manos y sonreír con los ojos cerrados |
| Dream journal | Cuaderno de sueños | tpr | Dibujar en el aire |
| Dreamy | Soñador | tpr | Mirar al techo sonriendo |
| Dress | Vestirse | tpr | Meter la cabeza por una camiseta imaginaria |
| Dress up | Disfrazarse | tpr | Poner una capa al bebé |
| Dressed up | Disfrazado | tpr | Enseñar el disfraz |
| Drift | Planear | tpr | Dejar caer una hoja desde arriba |
| Drift along | Dejarse llevar | tpr | Moverse despacio sin remar |
| Drift off | Quedarse dormido | tpr | Cerrar los ojos e inclinar la cabeza |
| Driftwood | Madera a la deriva | leccions, tpr | Coger un palo de la playa |
| Drink | Beber | tpr | Beber agua imaginaria y decir «aaah» |
| Drip | Gotear | leccions, tpr | Tocar el suelo con los dedos: plin, plin, plin |
| Drip, drop! | ¡Gota, gota! | 0-2, leccions, tpr | Tocar la mano dos veces |
| Dripping | Goteando | tpr | Mover los dedos hacia abajo |
| Dripping clothes | Ropa goteando | tpr | Sacudir la ropa mojada |
| Dripping wet | Empapado | tpr | Escurrir un paño empapado |
| Drippy | Goteante | tpr | Dejar gotear agua de la esponja |
| Drive | Conducir | leccions, tpr | Girar un volante imaginario |
| Driver | Conductor | tpr | Girar el volante imaginario |
| Drizzle | Llovizna | 0-2, leccions, tpr | Mover los dedos como gotas finas |
| Drizzly | Lloviznoso | tpr | Mover los dedos despacio |
| Drop a light feather | Deja caer una pluma ligera | tpr | Dejar caer la mano despacio |
| Drop a stone | Dejar caer una piedra | tpr | Soltar la piedra y mirar |
| Drop by drop | Gota a gota | tpr | Dejar caer gotas una a una |
| Drowsy | Adormilado | tpr | Inclinar la cabeza |
| Drum fingers | Tamborilear | tpr | Tamborilear en la mesa |
| Drumbeat | Golpe de tambor | tpr | Parar con el golpe de tambor |
| Dry | Seco, seca | tpr | Desmenuzar una hoja seca imaginaria entre las manos |
| Dry off | Secarse | tpr | Secarse las manos frotando |
| Dry sand | Arena seca | tpr | Dejar caer arena seca |
| Dry wings | Secar las alas | tpr | Abrir los brazos al sol |
| Dry your toes! | ¡Sécate los dedos de los pies! | leccions | — |
| Dummy | Chupete | 0-2, tpr | Acercar el chupete y retirarlo jugando |
| Dune | Duna | tpr | Dibujar una ola de arena |
| Eager | Con ganas | tpr | Saltar en el sitio |
| Early-rising | Madrugador | tpr | Desperezarse temprano |
| Earmuffs | Orejeras | tpr | Tapar las orejas con las manos |
| Earthy | Terroso | tpr | Oler la tierra |
| Easy to roll | Fácil de rodar | tpr | Rodar las manos |
| Eat your greens! | ¡Come la verdura! | tpr | Llevar el tenedor a la boca |
| Eat! | comer | 0-2, leccions, tpr | Comer con una cuchara imaginaria |
| Echo | Repetir como el eco | tpr | Repetir el sonido que se oye |
| Echo game | Juego del eco | tpr | Repetir las palmas que se oyen |
| Echoing | Con eco | tpr | Repetir bajito |
| Eco-friendly | Respetuoso con el planeta | tpr | Abrazar una bola del mundo |
| Ecological | Ecológico | tpr | Abrazar una bola |
| Egg shaker | Huevo sonoro | tpr | Agitar el huevo sonoro cerca de la oreja |
| Egg-shaped | Con forma de huevo | tpr | Hacer un huevo con las manos |
| Eggshell | Cáscara de huevo | tpr | Abrir las manos como una cáscara |
| Elbow | Codo | tpr | Tocarse un codo con la mano contraria |
| Electric | Eléctrico | tpr | Hacer «zzz» con la voz |
| Emotion | Emoción | tpr | Poner la mano en el pecho |
| Emotion card | Tarjeta de emociones | tpr | Enseñar una cara |
| Emotional | Emocionado | tpr | Poner las manos en el pecho |
| Empathy | Empatía | tpr | Poner la mano en el hombro de un amigo |
| empty | vacío | leccions, tpr | Dar la vuelta a un cuenco imaginario y mirar dentro |
| Empty out | Vaciar | tpr | Vaciar el vaso en la bandeja |
| Encourage | Animar | tpr | Dar palmas a un compañero |
| Ending | Final | tpr | Cerrar un libro |
| Energetic | Con energía | tpr | Saltar en el sitio |
| Energy | Energía | tpr | Saltar con fuerza |
| Energy saver | Ahorrador de energía | tpr | Apagar la luz |
| Enjoy your meal! | ¡Buen provecho! | tpr | Abrir las manos hacia el grupo antes de comer |
| Enormous | Enorme | tpr | Abrir los brazos muy grandes |
| Enter on the left and exit on the right | Entra por la izquierda y sal por la derecha | tpr | Caminar de un lado a otro |
| Enter the stage | Entrar en escena | tpr | Dar pasos hacia el centro |
| Equal | Igual | tpr | Poner las manos a la misma altura |
| Equal weight | Mismo peso | tpr | Poner las manos iguales |
| Escalator | Escalera mecánica | tpr | Quedarse quieto mientras sube |
| Escape | Escapar | tpr | Correr al refugio |
| Estimate | Estimar | tpr | Mover la mano dudando |
| Estuary | Ría | tpr | Dibujar la ría con el dedo |
| Evaporate | Evaporarse | leccions, tpr | Subir despacio como vapor |
| Evaporation | Evaporación | tpr | Subir despacio las manos |
| Even | Igualado | tpr | Poner las manos a la misma altura |
| Even number | Par | tpr | Enseñar dos dedos |
| Even out | Igualar | tpr | Ajustar los brazos hasta igualarlos |
| Every little thing helps | Cada poquito ayuda | tpr | Juntar los dedos |
| Every piece counts | Cada trozo cuenta | tpr | Enseñar un dedo |
| Everybody sit down! | ¡Todo el mundo sentado! | leccions | — |
| Everybody stand up! | ¡Todo el mundo de pie! | leccions | — |
| Everybody, sing the chorus! | ¡Todos, cantad el estribillo! | tpr | Abrir los brazos |
| Everyone can play | Todos pueden jugar | tpr | Abrir los brazos a todos |
| Everyone, take a bow! | ¡Todos, reverencia! | tpr | Inclinarse juntos |
| examine | examinar | leccions | — |
| Exchange gifts | Intercambiar regalos | leccions, tpr | Dar y recibir un paquete |
| Excited for next year | Con ganas del año que viene | tpr | Saltar contentos |
| Excited for summer | Con ganas de verano | tpr | Saltar contentos |
| Exciting | Emocionante | tpr | Abrir mucho los ojos |
| Exit the stage | Salir de escena | tpr | Caminar hacia el lado |
| Expensive | Caro | tpr | Enseñar muchas monedas |
| Experiment | Experimento | tpr | Mirar con atención con la lupa |
| explore | explorar | leccions, tpr | Caminar despacio mirándolo todo con curiosidad |
| Explore new places | Explorar sitios nuevos | tpr | Mirar alrededor con un mapa |
| Explore the seabed | Explorar el fondo | tpr | Gatear mirando el suelo |
| Express | Expresar | tpr | Abrir las manos desde el pecho |
| Eye to eye | Ojo con ojo | tpr | Ponerse a la altura de los ojos del bebé |
| Eyebrows | Cejas | 0-2, tpr | Pasar el dedo por las cejas |
| Eyelashes | Pestañas | tpr | Parpadear despacio cerca del bebé |
| Face | Cara | tpr | Rodearse la cara con las manos |
| Face cloth | Paño de la cara | tpr | Limpiar la cara con el paño |
| Face mask | Careta | leccions, tpr | Poner y quitar la careta |
| Face paint | Pintura de cara | 0-2, tpr | Pintar un punto en la mejilla |
| Faint | Suave | tpr | Tocar el tambor muy despacio |
| Fair | Justo | leccions, tpr | Repartir en partes iguales |
| Fair solution | Solución justa | tpr | Poner las manos iguales |
| Fairest | El más justo | tpr | Poner las manos iguales |
| Fairy lights | Lucecitas | 0-2, leccions, tpr | Señalar las lucecitas que brillan |
| Fairy tale | Cuento de hadas | leccions, tpr | Abrir un libro grande |
| fall | caer | leccions | — |
| Fall as rain | Caer en lluvia | tpr | Bajar los dedos |
| Fall down | Déjate caer | leccions, tpr | Dejarse caer despacio hasta sentarse en el suelo |
| Falling | Cayendo | tpr | Bajar despacio hasta el suelo como una hoja que cae |
| Falling, falling, falling down! | ¡Cayendo, cayendo, cayendo al suelo! | leccions | — |
| Familiar | Conocido | tpr | Señalar una cara conocida |
| Family audience | Familias en el público | tpr | Saludar a las familias |
| Family table | Mesa familiar | tpr | Sentar al bebé a la mesa con todos |
| Family tree | Árbol genealógico | tpr | Dibujar ramas en el aire |
| Famous | Famoso | tpr | Señalar orgullosos |
| Fan yourself | Abanicarse | tpr | Abanicarse con la mano |
| Far | Lejos | tpr | Señalar muy lejos con el brazo estirado |
| Faraway | Muy lejano | tpr | Señalar muy lejos |
| Farewell hug | Abrazo de despedida | tpr | Abrazar a un amigo |
| Farewell party | Fiesta de despedida | tpr | Bailar y saludar |
| Farewell song | Canción de despedida | tpr | Cantar y saludar a todos |
| Farm | Granja | tpr | Dibujar una valla en el aire con los brazos |
| Fast | Rápido, rápida | tpr | Mover las manos muy rápido |
| Fast and slow | Rápido y lento | tpr | Caminar rápido y luego muy despacio |
| Fasten | Abrochar | tpr | Abrochar un botón |
| Fasten your seatbelts | Abrochaos los cinturones | leccions | — |
| Faster | Más rápido | leccions, tpr | Golpear más rápido |
| Faster and faster | Cada vez más rápido | tpr | Acelerar los pasos |
| Faster? Yes, faster. | ¿Más rápido? Sí, más rápido. | frases | — |
| Fastest | El más rápido | tpr | Correr a toda velocidad |
| Favourite | Favorito, favorita | tpr | Abrazar un plato imaginario y sonreír |
| Favourite day | Día favorito | tpr | Señalar un día en el calendario |
| Feather mask | Máscara de plumas | tpr | Ponerse la máscara con las manos |
| Feathered | Emplumado | tpr | Acariciar una pluma |
| Feathered hat | Gorro con plumas | tpr | Pasar una pluma del gorro por la cara |
| Feathery | Con plumas | tpr | Pasar una pluma por la mano |
| Feathery tail | Cola de plumas | tpr | Mover la cola de plumas |
| Feed | Dar de comer | tpr | Extender la mano abierta con comida imaginaria |
| Feed the ducks | Dar de comer a los patos | tpr | Extender la mano con comida para patos |
| Feed yourself | Comer solo | tpr | Dejar que coja la cuchara |
| Feel | Palpar | tpr | Palpar la textura con la mano abierta |
| Feel this! | ¡Toca esto! | 0-2, leccions, tpr | Acercar un objeto a la mano |
| Feel without looking | Tocar sin mirar | leccions, tpr | Tocar con los ojos cerrados |
| Feel your heartbeat | Sentir el latido | leccions, tpr | Poner la mano en el pecho y esperar |
| Feeling | Sentimiento | tpr | Poner la mano en el pecho |
| Feelings chart | Panel de las emociones | tpr | Señalar una cara en el panel |
| Feelings words | Palabras de los sentimientos | tpr | Poner la mano en el pecho |
| Feet on the floor | Pies en el suelo | tpr | Posar los pies en el suelo |
| Festive | Festivo | tpr | Bailar contentos |
| Fewest | El que menos | tpr | Señalar el grupo pequeño |
| Fierce | Feroz | tpr | Poner cara de feroz riendo |
| Figure out | Averiguar | tpr | Abrir los ojos de golpe |
| Fill | Llenar | leccions, tpr | Llenar una cesta imaginaria hasta arriba |
| Fill a crate | Llenar una caja | tpr | Meter fruta en la caja |
| Fill a space | Llenar un hueco | tpr | Encajar la mano en un hueco |
| Fill the bucket | Llenar el cubo | tpr | Llenar el cubo de arena |
| Fill the pot, plant the seed and water it | Llena la maceta, planta la semilla y riégala | leccions | — |
| Fill up | Llenar | tpr | Llenar el vaso de agua |
| Filling | Que llena | tpr | Tocar la barriga llena |
| Fin | Aleta | tpr | Poner la mano en la espalda como aleta |
| Find | Encontrar | leccions, tpr | Buscar con la mano sobre los ojos y señalar al encontrar |
| Find a red circle! Touch it with your foot! | ¡Busca un círculo rojo! ¡Tócalo con el pie! | leccions | — |
| Find a rhyme | Rimar | tpr | Dar palmas en cada rima |
| Find something red | Busca algo rojo | tpr | Buscar por el aula y tocar algo rojo |
| Find the red flower and land softly | Busca la flor roja y posa despacio | leccions | — |
| Find the shape | Buscar la forma | leccions, tpr | Buscar un círculo en la sala |
| Find the way | Encontrar el camino | tpr | Mirar el mapa y señalar |
| Finger on lips | Dedo en los labios | tpr | Posar el dedo en los labios |
| Finger on your nose | Dedo en la nariz | tpr | Posar un dedo en la nariz |
| Finger puppet | Títere de dedo | 0-2, leccions, tpr | Mover un títere en el dedo |
| Fingertip | Punta del dedo | tpr | Tocar la punta del dedo del bebé |
| Finish line | Línea de meta | tpr | Pasar la línea de meta |
| Fireplace | Chimenea | 0-2, tpr | Señalar la chimenea de lejos |
| First day | Primer día | tpr | Levantar un dedo |
| First he whispers, then he shouts | Primero susurra, luego grita | tpr | Hablar bajo y luego alto |
| First pyjamas, then teeth, then a story | Primero el pijama, luego los dientes, luego un cuento | tpr | Hacer los tres gestos en orden |
| First slow, then fast | Primero despacio, luego rápido | tpr | Golpear despacio y luego rápido |
| First the big box, then the cup. | Primero la caja grande, luego el vaso. | frases | — |
| First the blocks, then the cars | Primero los bloques, luego los coches | tpr | Recoger en dos turnos |
| First the hero was lost, then she found her way home | Primero la heroína se perdió, luego encontró el camino a casa | tpr | Mirar alrededor y luego caminar |
| First the solo, then the choir | Primero el solo, luego el coro | tpr | Uno canta y luego todos |
| First we check the heart, then we wrap the bandage. | Primero miramos el corazón y después ponemos la venda. | leccions | — |
| First we pick, then we sort, then we share | Primero cogemos, luego clasificamos, luego repartimos | tpr | Hacer los tres gestos |
| First we sing, then we get our certificates, and finally we celebrate | Primero cantamos, luego recogemos los certificados y por último celebramos | tpr | Hacer los tres gestos |
| First, then, finally | Primero, luego, por último | tpr | Levantar uno, dos y tres dedos |
| First-ever | El primero de todos | tpr | Levantar un dedo |
| Fish for a living | Vivir de la pesca | tpr | Lanzar la red |
| Fish market | Lonja | tpr | Señalar cajas de pescado |
| Fish supper | Cena de pescado | tpr | Hacer que se coge un pez con el pico |
| Fish swim together in a shoal | Los peces nadan juntos en un banco | tpr | Moverse todos juntos |
| Fisherman | Pescador | tpr | Lanzar una red |
| Fishing boat | Barco pesquero | leccions, tpr | Remar con fuerza |
| Fishing hole | Agujero en el hielo | tpr | Hacer un círculo en el suelo |
| Fishing net | Red de pesca | tpr | Entrecruzar los dedos como una red |
| Fishing village | Aldea marinera | leccions, tpr | Tirar de una red |
| Fit | Encajar | tpr | Meter la pieza en su hueco |
| Five minutes each | Cinco minutos cada uno | tpr | Enseñar cinco dedos |
| Five years | Cinco años | tpr | Enseñar cinco dedos |
| Five, four, three, two, one! | ¡Cinco, cuatro, tres, dos, uno! | tpr | Bajar los dedos |
| Flamingo pose | Postura de flamenco | tpr | Sostenerse en un pie |
| Flap | Aletear | tpr | Mover los brazos muy rápido como alas pequeñas |
| Flap arms | Batir los brazos | tpr | Batir los brazos como el viento |
| Flap wings | Batir las alas | leccions, tpr | Batir los brazos como alas |
| Flash | Destellar | tpr | Abrir las manos de golpe |
| Flat | Plano, plana | tpr | Tumbarse en el suelo muy estirados |
| Flavour | Sabor | tpr | Relamerse los labios |
| Fleecy | Afelpado | tpr | Acariciar la chaqueta afelpada |
| Flexible body | Cuerpo flexible | tpr | Doblarse despacio |
| Flicker | Parpadear | tpr | Abrir y cerrar las manos rápido |
| Flip | Dar la vuelta | tpr | Dar la vuelta a las manos: palmas arriba, palmas abajo |
| Flipper | Aleta pectoral | tpr | Mover las manos pegadas al cuerpo |
| Float | Flotar | tpr | Tumbarse boca arriba con los brazos abiertos como en el agua |
| Float away | Irse flotando | tpr | Seguir la burbuja con la mirada |
| Float down | Bajar flotando | tpr | Bajar la mano despacio como una hoja |
| Float in space | Flotar en el espacio | tpr | Moverse muy despacio |
| Float like an otter | Flota como una nutria | tpr | Tumbarse y flotar |
| Float on top | Flotar arriba | tpr | Quedarse arriba con los brazos abiertos |
| Float on your back | Flotar boca arriba | tpr | Tumbarse con los brazos abiertos |
| Float or sink | Flotar o hundirse | tpr | Echar un objeto y mirar |
| Floating | Flotante | tpr | Mover la mano despacio en el aire |
| Floating boat | Barco flotante | tpr | Mover la mano como un barco |
| Floating raft | Batea flotante | tpr | Balancearse |
| Floaty | Ligerito | tpr | Soplar una hoja para que vuele |
| Floor | Suelo | tpr | Tocar el suelo con las palmas de las manos |
| Floppy | Flojo, floja | tpr | Dejar caer los brazos flojos como una marioneta |
| Flow | Fluir | tpr | Mover las manos suaves |
| Flower in my hand | Flor en mi mano | tpr | Poner la flor en la palma |
| Flowerpot | Maceta | tpr | Poner una planta imaginaria en una maceta |
| Fluffy | Esponjoso, esponjosa | tpr | Acariciar un conejo imaginario muy esponjoso |
| Fluffy chick | Pollito esponjoso | tpr | Acariciar una pluma amarilla |
| Fluffy seeds | Semillas algodonosas | leccions, tpr | Soplar suave |
| Flutter | Revolotear | 0-2, leccions, tpr | Mover los dedos como alas |
| Fly | Volar | leccions, tpr | Volar por el aula con los brazos abiertos, despacio |
| Fly away, bird! | ¡Vuela, pájaro! | tpr | Abrir las manos hacia arriba |
| Fly like a bird! | ¡Vuela como un pájaro! | leccions, tpr | Correr despacio con los brazos abiertos como un pájaro |
| Fly like a busy bee | Vuela como una abeja trabajadora | leccions | — |
| Fly off | Echar a volar | tpr | Estirar los brazos y correr |
| Fly to the rescue | Volar al rescate | tpr | Correr con los brazos estirados |
| Fly with wings | Volar con las alas | tpr | Estirar los brazos y volar |
| Foamy | Espumoso | tpr | Soplar la espuma |
| Foamy mouth | Boca con espuma | tpr | Señalar la espuma |
| Focused | Concentrado | tpr | Mirar un punto fijo |
| Fold | Doblar | tpr | Doblar un papel imaginario por la mitad |
| Fold paper | Doblar papel | tpr | Doblar una hoja por la mitad |
| Fold up | Doblar | tpr | Doblar un pañuelo por la mitad |
| Follow the light | Seguir la luz | tpr | Mover la linterna despacio |
| Follow the map | Seguir el mapa | tpr | Caminar señalando el mapa |
| Follow the rules | Seguir las normas | tpr | Caminar por la línea marcada |
| Follow with eyes | Seguir con la mirada | tpr | Mover la cabeza siguiendo la burbuja |
| Food plate | Plato saludable | tpr | Dividir un plato imaginario |
| Footpath | Sendero | tpr | Caminar por el sendero |
| Footprints in sand | Huellas en la arena | tpr | Pisar y mirar la huella |
| Footsteps | Pasos | tpr | Pisar las huellas del suelo |
| Forehead | Frente | 0-2, tpr | Besar la frente del bebé |
| Forgive | Perdonar | tpr | Abrir los brazos a un amigo |
| fork | tenedor | leccions | — |
| Fortress | Fortaleza | tpr | Poner los brazos como murallas |
| Found | Encontrado | tpr | Sacar el juguete y celebrarlo |
| Found one! | ¡Encontré una! | tpr | Levantar la hoja |
| Four-sided | De cuatro lados | tpr | Contar cuatro lados con los dedos |
| Fox cub | Cachorro de zorro | tpr | Correr ligero de puntillas |
| Fragile | Frágil | tpr | Coger algo con mucho cuidado |
| Fragrant | Perfumado, perfumada | tpr | Oler una flor y suspirar de gusto |
| Free | Libre | tpr | Moverse libres por el aula con los brazos sueltos |
| Freeze immediately | Congelarse al momento | tpr | Pararse al instante |
| Freeze on command | Pararse a la orden | tpr | Pararse cuando se dice «ya» |
| Freeze water | Congelar agua | tpr | Poner el cuerpo rígido |
| FREEZE! | ¡Estatuas! | leccions, tpr | Parar en seco y quedarse inmóviles como estatuas |
| Freezer | Congelador | tpr | Abrir una puerta fría |
| Fresh | Fresco, fresca | tpr | Respirar hondo el aire de la mañana |
| Fresh and clean | Limpio y fresco | tpr | Oler al bebé después del cambio |
| Fresh breath | Aliento fresco | tpr | Soplar en la mano y oler |
| Fresh from the farm | Fresco de la granja | tpr | Oler una fruta |
| Fresh green | Verde fresco | tpr | Señalar la hierba nueva |
| Fresh water | Agua dulce | tpr | Beber de mentira |
| Fresh-smelling | Con olor a limpio | tpr | Oler las manos limpias |
| Freshly picked | Recién cogido | tpr | Oler la fruta |
| Friend | Amigo, amiga | leccions, tpr | Dar la mano a la persona que está al lado |
| Friendly | Simpático, simpática | tpr | Ofrecer la mano abierta a quien está al lado |
| Friendly wolf | Lobo amigable | tpr | Sonreír con las orejas de lobo |
| Friends forever | Amigos para siempre | tpr | Enganchar los meñiques |
| Friends in a circle | Amigos en círculo | leccions, tpr | Hacer un círculo con las manos |
| Friendship | Amistad | tpr | Juntar los dedos índices |
| Frilly | Con volantes | tpr | Mover un volante con las manos |
| From cup to cup | De vaso en vaso | tpr | Verter de un vaso a otro |
| From hand to hand | De mano en mano | tpr | Pasar el objeto entre las dos manos |
| From light to dark | De claro a oscuro | tpr | Mover la mano de arriba abajo |
| From loud to quiet | De fuerte a bajito | leccions, tpr | Hablar fuerte y luego bajo |
| From seed to flower | De semilla a flor | tpr | Pasar de bola en el suelo a flor abierta |
| From small to big | De pequeño a grande | tpr | Crecer despacio desde el suelo |
| Front and back | Por delante y por detrás | tpr | Frotar la palma y el dorso |
| Front teeth | Dientes de delante | tpr | Señalar los dientes de delante |
| Frost | Escarcha | 0-2, tpr | Señalar la escarcha en la ventana |
| Frosty | Escarchado | tpr | Pasar el dedo por el cristal frío |
| Frozen solid | Congelado del todo | leccions, tpr | Quedarse rígido |
| Fruit bowl | Frutero | tpr | Sacar frutas del frutero |
| Fruit in a bowl | Fruta en un cuenco | tpr | Meter fruta en el cuenco |
| Fruit peel | Piel de la fruta | tpr | Pelar una fruta imaginaria |
| Fruity | Afrutado | leccions, tpr | Oler y sonreír |
| Frustrated | Frustrado | tpr | Apretar los puños y soltarlos |
| full | lleno | leccions, tpr | Hinchar los mofletes de aire y abrir los brazos |
| Full of pips | Con pepitas | tpr | Señalar las pepitas de la sandía |
| Full to the top | Lleno hasta arriba | tpr | Llenar hasta el borde |
| Full up | Lleno | tpr | Tocar la barriga después de comer |
| Funnel | Embudo | 0-2, tpr | Verter agua por el embudo |
| Furry | Peludo, peluda | tpr | Acariciar un pelo muy suave imaginario |
| Furry coat | Pelaje grueso | tpr | Acariciar un peluche gordito |
| Fuzzy | Peludito | tpr | Acariciar una manta peluda |
| Gallop | Galopar | leccions, tpr | Galopar en el sitio con una pierna delante |
| Gallop like a horse in the meadow | Galopa como un caballo en el prado | leccions | — |
| Gallop like a wild horse | Galopa como un caballo salvaje | leccions | — |
| Gap | Hueco | tpr | Pasar por un hueco entre dos sillas |
| Garden | Jardín | 0-2, tpr | Salir al jardín de la escuela |
| Garden hose | Manguera | tpr | Apuntar y mojar las plantas |
| Garden plot | Parcela del huerto | tpr | Cavar en el aire |
| Garden trowel | Pala de jardín | tpr | Coger tierra con la pala |
| Gargle | Hacer gárgaras | tpr | Hacer gárgaras con agua |
| Gate | Verja | tpr | Abrir la verja del parque |
| Gather | Juntar | tpr | Juntar hojas con las manos |
| Gather acorns | Recoger bellotas | tpr | Coger bellotas del suelo |
| Gaze | Mirar fijamente | tpr | Mirar a los ojos del bebé en silencio |
| Generous | Generoso | tpr | Abrir los brazos para dar |
| gentle | con delicadeza | leccions, tpr | Pasar la mano con cariño por el hombro del compañero |
| Gentle hands | Manos suaves | tpr | Acariciar muy despacio |
| Gentle waves | Olas suaves | leccions, tpr | Balancear las manos muy suave, de lado a lado |
| Gentle-hearted | De corazón dulce | tpr | Hacer un corazón con las manos |
| Gently down the stream | Despacio por el río | tpr | Remar despacio |
| Geometric | Geométrico | tpr | Dibujar un triángulo |
| Germ-free | Sin gérmenes | tpr | Enseñar las manos limpias |
| Germs | Gérmenes | tpr | Frotar las manos para quitarlos |
| Get dressed | Vestirse | tpr | Hacer que se pone la ropa |
| Get off | Bajar | tpr | Dar un paso hacia abajo |
| Get on | Subir | leccions, tpr | Dar un paso hacia arriba |
| Get ready for bed | Prepararse para dormir | tpr | Ponerse el pijama imaginario |
| Get warm | Calentarse | leccions, tpr | Frotar las manos cerca del radiador |
| Get your coat zipped! | ¡Cierra el abrigo! | frases | — |
| Giant | Gigante | tpr | Poner voz grave y dar pasos pesados |
| Giant shoe | Zapato gigante | tpr | Abrir mucho las manos |
| Giant steps | Pasos de gigante | tpr | Dar pasos muy largos |
| Giant waves! | ¡Olas gigantes! | leccions | — |
| Giggle | Risita | tpr | Hacer una risita al bebé |
| Giggly | Risueño | tpr | Reír sin parar con el bebé |
| Give | Dar | tpr | Extender la mano abierta hacia otra persona |
| Give a card | Dar una tarjeta | tpr | Extender la tarjeta |
| Give a compliment | Decir un cumplido | tpr | Hablar mirando a los ojos |
| Give a speech | Dar un discurso | tpr | Hablar alto y claro |
| Give a thumbs up | Levantar el pulgar | tpr | Levantar el pulgar |
| Give away | Regalar | tpr | Extender un objeto a otra persona |
| Give me five! | ¡Choca esos cinco! | tpr | Chocar la palma de la mano con la de una compañera |
| Glass jar | Tarro de cristal | tpr | Sostener un tarro con cuidado |
| Glass slipper | Zapato de cristal | tpr | Probarse un zapato imaginario |
| Glassy | Liso como cristal | tpr | Pasar la mano plana |
| Glide | Deslizarse | tpr | Pasar la mano plana por el aire |
| Glinting | Reluciente | tpr | Mover el cristal al sol |
| Glitter | Purpurina | tpr | Agitar un bote con purpurina |
| Glittering | Resplandeciente | tpr | Mover los dedos brillando |
| Glittery | Con purpurina | tpr | Tocar un papel con purpurina |
| Gloomy | Oscuro | tpr | Bajar la luz de la sala |
| Glossy black | Negro brillante | tpr | Pasar la mano por el pelo |
| Glove puppet | Títere de guante | tpr | Hacer hablar al títere |
| Glowing | Luminoso | tpr | Enseñar una lámpara encendida |
| Glowing moon | Luna brillante | tpr | Hacer un círculo luminoso |
| Glue | Pegamento | tpr | Extender pegamento imaginario con un dedo |
| Go around | Rodear | tpr | Caminar alrededor de un cono |
| Go fast! | ¡Ve rápido! | tpr | Correr en el sitio |
| Go on holiday | Irse de vacaciones | tpr | Llevar una maleta imaginaria |
| Go slow | Ve despacio | tpr | Caminar muy despacio |
| Go straight on | Seguir recto | tpr | Caminar recto sin girar |
| Go! | ir, adelante | 0-2, leccions, tpr | Dar un paso adelante al oír la palabra |
| Goal | Meta | tpr | Señalar un punto lejos |
| Golden | Dorado, dorada | tpr | Señalar algo dorado o amarillo brillante |
| Golden brown | Dorado | tpr | Enseñar una hoja dorada a la luz |
| Gone | Desaparecido | tpr | Abrir las manos vacías |
| Good deed | Buena acción | tpr | Levantar el pulgar |
| Good job! | ¡Muy bien! | tpr | Levantar el pulgar |
| Good morning! | ¡Buenos días! | leccions, tpr | Estirar los brazos hacia el cielo como al despertar |
| Good morning, Sun! | ¡Buenos días, Sol! | tpr | Abrir los brazos |
| Good night! | ¡Buenas noches! | tpr | Decir adiós despacio y juntar las manos bajo la mejilla |
| Good night, Moon | Buenas noches, Luna | tpr | Cerrar los ojos |
| Good sport | Buen deportista | tpr | Darse la mano al final |
| Goodbye card | Tarjeta de despedida | tpr | Dar una tarjeta a un amigo |
| Grab | Agarrar | tpr | Agarrar algo imaginario con toda la mano |
| Grab and shake | Coger y agitar | tpr | Coger el juguete y agitarlo |
| Graceful | Elegante | tpr | Moverse despacio y con elegancia como un delfín |
| Graceful flight | Vuelo elegante | tpr | Mover los brazos suave |
| Graceful steps | Pasos elegantes | tpr | Caminar de puntillas despacio |
| Graduated | Graduado | tpr | Levantar el certificado |
| Gram | Gramo | tpr | Juntar dos dedos muy poco |
| Grandad | Abuelo | 0-2, tpr | Señalar la foto del abuelo |
| Grasp | Agarrar | 0-2, leccions, tpr | Dejar que el bebé agarre el dedo |
| Grass | Hierba | leccions, tpr | Pasar las manos por el suelo como si acariciáramos hierba |
| Grasshopper | Saltamontes | tpr | Saltar como un saltamontes |
| Grassy | Herboso | tpr | Tocar la hierba con la palma |
| Grate | Rallar | tpr | Mover la mano arriba y abajo |
| Grateful | Agradecido, agradecida | tpr | Juntar las manos en el pecho e inclinar la cabeza |
| Grateful heart | Corazón agradecido | tpr | Poner las manos en el pecho |
| Graze | Pastar | tpr | Bajar la cabeza y mover la boca como quien come hierba |
| Graze like a gentle sheep | Pasta como una oveja mansa | leccions | — |
| Great | Estupendo, estupenda | tpr | Levantar los dos pulgares |
| Great-grandparents | Bisabuelos | tpr | Señalar muy atrás |
| Green card | Tarjeta verde | tpr | Correr al ver la tarjeta verde |
| Green shoot | Brote | 0-2, tpr | Subir un dedo desde el puño |
| Greener | Más verde | tpr | Abrir las manos como hojas |
| Grey | Gris | tpr | Señalar algo gris en el aula |
| Gritty | Arenoso | tpr | Frotar arena entre los dedos |
| Groovy | Marchoso | tpr | Bailar con mucha marcha |
| Group | Agrupar | tpr | Juntar de cinco en cinco |
| Group hug | Abrazo de grupo | tpr | Abrazarse todos juntos |
| Group of five | Grupo de cinco | tpr | Enseñar una mano abierta |
| Grow | Crecer | tpr | Pasar de agachados a estirados muy despacio |
| Grow bigger | Hacerse más grande | tpr | Abrir los brazos despacio |
| Grow tall into a sunflower | Crece alto hasta ser un girasol | leccions | — |
| Grow taller | Hacerse más alto | tpr | Estirarse de puntillas |
| Grow up | Crecer | tpr | Levantarse despacio |
| Grow, grow, grow! | ¡Crece, crece, crece! | tpr | Levantarse despacio hasta arriba |
| Growing | Creciendo | tpr | Estirar los brazos hacia arriba |
| Growl | Gruñir | tpr | Hacer «grrr» bajito |
| Grown bigger | Más grande | tpr | Estirarse alto |
| Grown so much | Muy crecido | tpr | Estirarse hasta arriba |
| Grown-up | Mayor | tpr | Estirarse muy alto |
| Grown-up now | Mayor ahora | tpr | Ponerse de puntillas |
| Growth chart | Tabla de altura | tpr | Medirse en la pared |
| Grrr, grrr! | ¡Grrr, grrr! | tpr | Gruñir y sonreír |
| Grumpy | Gruñón | tpr | Cruzar los brazos y luego reír |
| Guess | Adivinar | tpr | Tocarse la barbilla pensativos y señalar |
| Guess the taste | Adivinar el sabor | tpr | Probar con los ojos cerrados |
| Guess who's behind the mask | Adivina quién hay detrás de la máscara | tpr | Tapar la cara y descubrirla |
| Gull chick | Pollo de gaviota | leccions, tpr | Acurrucarse pequeño |
| Gums | Encías | tpr | Masajear las encías con un mordedor |
| Gust | Ráfaga | tpr | Soplar fuerte una vez |
| Gutter | Canalón | tpr | Seguir el agua que baja |
| Ha, ha, ha! | ¡Ja, ja, ja! | tpr | Reír y dar palmas |
| Had you been folding the paper long? | ¿Habías estado mucho rato doblando el papel? | frases | — |
| Had you seen the shadow before? | ¿Habías visto la sombra antes? | frases | — |
| Hail a taxi | Parar un taxi | tpr | Levantar la mano en la acera |
| Hair | Pelo | tpr | Pasarse las manos por el pelo como si nos peináramos |
| Hair tie | Goma del pelo | tpr | Recoger el pelo con una goma |
| Hairbrush | Cepillo del pelo | tpr | Pasar el cepillo despacio por el pelo |
| Half | Mitad | tpr | Partir algo por la mitad |
| Halt | Detenerse | leccions, tpr | Pararse con las manos arriba |
| Hammock | Hamaca | 0-2, leccions, tpr | Mecer al bebé en una manta como hamaca |
| Hand gel | Gel de manos | tpr | Frotar las manos con el gel |
| Hand in hand | De la mano | leccions, tpr | Coger la mano del compañero y caminar juntos |
| Hand it over | Darlo | tpr | Extender la mano con el juguete |
| Hand on paper | Mano en el papel | tpr | Posar la mano en el papel |
| Hand over | Entregar | tpr | Dar el objeto a la otra mano |
| Hand towel | Toalla de manos | 0-2, leccions, tpr | Secar las manos en la toalla |
| Hand wave | Saludo con la mano | tpr | Saludar a todos |
| Handle | Asidero | tpr | Agarrarse al asidero |
| Handmade | Hecho a mano | tpr | Enseñar las manos |
| Handprint | Huella de la mano | tpr | Posar la mano con pintura en el papel |
| Hands in pockets | Manos en los bolsillos | tpr | Meter las manos en los bolsillos |
| Hands in the dough | Las manos en la masa | tpr | Meter las manos en la masa |
| Hands on your tummy | Manos en la barriga | tpr | Poner las manos en la barriga y notar cómo sube y baja |
| Hands up and cheer | Manos arriba y a animar | tpr | Subir las manos y animar todos a la vez |
| Handspan | Palmo | tpr | Medir la mesa a palmos |
| Handwritten | Escrito a mano | tpr | Escribir en el aire |
| Hang | Colgar | leccions, tpr | Colgar una estrella imaginaria en lo alto |
| Hang ornaments | Colgar adornos | tpr | Estirarse a colgar |
| Hang out | Tender | leccions, tpr | Colgar la ropa en la cuerda |
| Hang up | Colgar | tpr | Colgar el abrigo en la percha |
| Happiest | El más feliz | tpr | Saltar de alegría |
| Happy birthday! | ¡Feliz cumpleaños! | tpr | Dar palmas suaves y soplar una vela imaginaria |
| Happy ending | Final feliz | tpr | Sonreír y abrazar |
| Happy holidays! | ¡Felices fiestas! | tpr | Saludar a todos |
| Happy New Year! | ¡Feliz Año Nuevo! | tpr | Abrazar a quien está al lado y sonreír |
| Harbour | Puerto | tpr | Señalar los barcos del puerto |
| Harbour wall | Espigón | tpr | Estirar el brazo largo |
| Hard | Duro, dura | tpr | Apretar una castaña imaginaria que no se aplasta |
| Hard hat | Casco de obra | tpr | Tocar el casco en la cabeza |
| Hard-shelled | De caparazón duro | tpr | Golpear suave en la espalda |
| Hard-working | Trabajador, trabajadora | tpr | Llevar cargas imaginarias de un lado a otro |
| Hare | Liebre | tpr | Saltar largo como una liebre |
| Harmonious | Armonioso | tpr | Juntar las voces |
| Harmony | Armonía | tpr | Juntar las manos suavemente |
| Harvest | Cosecha | tpr | Coger y meter en una cesta |
| Harvest fruit | Cosechar fruta | leccions, tpr | Coger fruta imaginaria |
| Harvest time! | ¡Hora de la cosecha! | tpr | Coger con la cesta |
| Hat and mittens | Gorro y manoplas | tpr | Tocar el gorro y luego las manoplas |
| Hat brim | Ala del sombrero | tpr | Sujetar el sombrero con el viento |
| Hat on, hat off | Gorro puesto, gorro fuera | leccions, tpr | Poner y quitar el gorro |
| Hat on, please | El sombrero, por favor | tpr | Poner el sombrero al bebé |
| Hat pompom | Pompón del gorro | tpr | Tocar el pompón del gorro |
| Hatch | Salir del cascarón | tpr | Salir despacio de un huevo imaginario rompiendo la cáscara |
| Hatchling | Polluelo | tpr | Acurrucarse como un polluelo |
| Have a nice summer! | ¡Feliz verano! | tpr | Abrir los brazos hacia el grupo con alegría |
| Have a safe trip! | ¡Buen viaje! | leccions | — |
| Have fun! | ¡Pásalo bien! | tpr | Dar palmas |
| Have you been holding the cup? | ¿Llevas rato sujetando el vaso? | frases | — |
| Have you finished the row? | ¿Has terminado la fila? | frases | — |
| Have you pushed it? | ¿Lo has empujado? | frases | — |
| Having folded the plane, we threw it. | Después de doblar el avión, lo lanzamos. | frases | — |
| He admitted the circle was hard to spin. | Él reconoció que el círculo era difícil de girar. | frases | — |
| He huffed and he puffed | Sopló y sopló | tpr | Soplar dos veces |
| Head | Cabeza | 0-2, leccions, tpr | Tocar la cabeza con las dos manos |
| Head to toes | De la cabeza a los pies | leccions, tpr | Acariciar desde la cabeza hasta los pies |
| Head, shoulders, knees and toes | Cabeza, hombros, rodillas y pies | leccions | — |
| Head, shoulders, knees and toes, knees and toes. | Cabeza, hombros, rodillas y pies. | 0-2-rima | — |
| Healthy | Sano | leccions, tpr | Tocar la barriga y sonreír |
| Healthy snack | Merienda saludable | tpr | Enseñar una fruta |
| Heaped | Amontonado | tpr | Hacer un montón de arena |
| Hearing | Oído | tpr | Señalar las orejas |
| Heart shape | Forma de corazón | tpr | Hacer un corazón con las manos |
| Heater | Radiador | tpr | Señalar el radiador caliente |
| Heavier | Más pesado | tpr | Bajar la mano que pesa más |
| Heavier than water | Más pesado que el agua | tpr | Bajar la mano |
| Heaviest | El más pesado | tpr | Bajar el brazo al máximo |
| Heavy | Pesado, pesada | tpr | Levantar una piedra imaginaria muy pesada |
| Heavy bag | Bolsa pesada | leccions, tpr | Llevar una bolsa con esfuerzo |
| Heavy blanket | Manta pesada | tpr | Posar la manta despacio |
| Heavy side | Lado pesado | tpr | Bajar un brazo |
| Heavy steps | Pasos pesados | tpr | Pisar muy fuerte |
| Heel | Talón | tpr | Coger el talón con la mano |
| Hello, flower! | ¡Hola, flor! | tpr | Saludar a una flor |
| Hello, I'm Sock! | ¡Hola, soy Calcetín! | tpr | Mover la boca del títere |
| Hello, little chick | Hola, pollito | tpr | Acariciar un pollito imaginario |
| Hello, little one! | ¡Hola, pequeño! | leccions, tpr | Saludar cerca de la cara del bebé |
| Hello, sailor! | ¡Hola, marinero! | tpr | Hacer el saludo de marinero |
| Hello, sun! | ¡Hola, sol! | tpr | Saludar hacia arriba y sonreír |
| Help | Ayudar | leccions, tpr | Levantar entre dos un objeto imaginario pesado |
| Help a friend | Ayudar a un amigo | tpr | Dar la mano a un amigo para levantarse |
| Help me, please | Ayúdame, por favor | leccions | — |
| Help others | Ayudar a los demás | tpr | Dar la mano a alguien |
| Helper | Ayudante | tpr | Ponerse una medalla de ayudante |
| Helpful | Servicial | tpr | Ayudar a un amigo a recoger |
| Helping hand | Mano amiga | tpr | Extender la mano |
| Here a moo, there a moo | Aquí un mu, allí un mu | tpr | Señalar a un lado y al otro |
| Here comes a wave! | ¡Ahí viene una ola! | leccions, tpr | Levantar los brazos como una ola |
| Here comes the aeroplane! | ¡Ahí viene el avión! | tpr | Acercar la cuchara volando |
| Here I am! | ¡Aquí estoy! | tpr | Aparecer detrás de la cortina |
| Here it comes! | ¡Ahí va! | tpr | Rodar la pelota hacia el bebé |
| Here it is! | ¡Aquí está! | tpr | Señalar con alegría algo encontrado |
| Here you are! | ¡Toma! | leccions | — |
| Here you go | Toma | leccions, tpr | Dar el juguete a un amigo |
| Here you go. Thank you! Your turn | Toma. ¡Gracias! Te toca | leccions | — |
| Here you go: give the light to the next pair | Toma: dale la luz a la pareja siguiente | leccions | — |
| Here you go: pass the soil to your friend | Toma: pásale la tierra a tu amigo | leccions | — |
| Here's Grandad! | ¡Aquí está el abuelo! | tpr | Descubrir la foto del abuelo |
| Here's the shop | Aquí está la tienda | tpr | Señalar la tienda |
| Here's your change | Aquí tienes el cambio | tpr | Dar una moneda |
| Here, doggy! | ¡Ven, perrito! | tpr | Llamar con el dedo y golpear las rodillas |
| Hero | Protagonista | tpr | Poner las manos en la cadera |
| Heron | Garza | tpr | Sostenerse en un pie quieto |
| Hexagon | Hexágono | tpr | Contar seis lados |
| Hidden | Escondido, escondida | tpr | Esconderse detrás de las manos y quedarse quietos |
| Hidden away | Escondido | tpr | Tapar el juguete con una manta |
| Hidden under | Escondido debajo | tpr | Levantar la mano y mirar debajo |
| Hide | Esconder | leccions, tpr | Esconder algo imaginario detrás de la espalda |
| Hide behind | Esconderse detrás | tpr | Esconderse detrás de un árbol |
| Hide in the seagrass | Esconderse en la pradera | tpr | Agacharse ondulando |
| Hide quietly | Esconderse en silencio | tpr | Esconderse sin hacer ruido |
| Hide thumbs | Esconder los pulgares | tpr | Esconder los pulgares en el puño |
| Hiding place | Escondite | tpr | Señalar dónde está escondido |
| Hiding spot | Escondrijo | tpr | Esconderse detrás de una silla |
| High | Agudo, aguda | leccions, tpr | Subir la mano al cantar una nota aguda |
| High chair | Trona | tpr | Sentar al bebé en la trona |
| High up | Muy alto | tpr | Señalar muy arriba |
| Higher than the houses | Más alto que las casas | tpr | Levantar la mano por encima |
| Hip, hip, hooray! | ¡Hip, hip, hurra! | tpr | Levantar los brazos tres veces |
| Hips | Caderas | tpr | Mover las caderas de un lado a otro |
| Historic | Histórico | tpr | Tocar una piedra vieja |
| History | Historia | tpr | Señalar hacia atrás |
| Ho, ho, ho! | ¡Jo, jo, jo! | tpr | Dar palmadas en la barriga riendo |
| Hobby | Afición | tpr | Hacer el gesto de una afición |
| Hold | Sostener | tpr | Sostener una pelota imaginaria con las dos manos sin dejarla caer |
| Hold hands | Darse la mano | leccions, tpr | Cogerse de las manos en círculo |
| Hold ice | Sostener hielo | tpr | Temblar sosteniendo algo frío |
| Hold it | Sujetar | tpr | Poner la fruta en la mano del bebé |
| Hold it, please! | ¡Sujétalo, por favor! | tpr | Sujetar con las dos manos |
| Hold my hand | Dame la mano | leccions, tpr | Coger la mano de la persona adulta |
| Hold on | Agarrarse | tpr | Agarrarse al banco |
| Hold steady | Sujetar firme | tpr | Sujetar la torre con las dos manos |
| Hold up | Mostrar | tpr | Levantar la castaña para verla |
| Hold up high | Levantar alto | tpr | Enseñar el tesoro a todos |
| Hold up one finger for first | Levantar un dedo para «primero» | tpr | Levantar un dedo |
| Hold your breath | Aguantar la respiración | tpr | Inflar las mejillas |
| Hold your hat! | ¡Sujeta el sombrero! | tpr | Posar las manos en la cabeza |
| Holiday | Vacaciones | leccions, tpr | Saltar de alegría con los brazos arriba |
| Hollow | Hueco | leccions, tpr | Mirar dentro del tubo |
| Hollow trunk | Tronco hueco | tpr | Hacer un hueco con las manos |
| Holly | Acebo | tpr | Señalar las bolas rojas |
| Homemade | Casero | tpr | Remover una olla |
| Honest | Sincero | tpr | Poner la mano en el pecho |
| Honey is sweeter than lemon | La miel es más dulce que el limón | tpr | Sonreír y luego arrugar la cara |
| Honeycomb | Panal | tpr | Hacer hexágonos con las manos |
| Honk | Pitar | tpr | Hacer «mec mec» |
| Hood | Capucha | 0-2, tpr | Poner la capucha y sonreír |
| Hooded towel | Toalla con capucha | tpr | Poner la capucha de la toalla |
| Hoop | Aro | leccions, tpr | Hacer un aro con los brazos por encima de la cabeza |
| Hoop tunnel | Túnel de aros | tpr | Pasar por los aros |
| Hooray for us! | ¡Hurra por nosotros! | tpr | Levantar los brazos |
| Hoot, hoot! | ¡Uh, uh! | tpr | Hacer un búho con las manos y decir «uh, uh» |
| Hop | Saltar a la pata coja | leccions, tpr | Saltar a la pata coja cogidos de la mano |
| Hop along | Ir a saltitos | 0-2, leccions, tpr | Dar saltitos con los dedos |
| Hop around | Saltar alrededor | tpr | Saltar dando una vuelta |
| Hop like a kangaroo | Salta como un canguro | tpr | Saltar con los pies juntos |
| Hop like a squirrel and collect the chestnuts | Brinca como una ardilla y recoge las castañas | leccions | — |
| Hop on one foot | Saltar a la pata coja | tpr | Saltar en un pie |
| Hop to number three, then turn around | Salta hasta el tres y date la vuelta | tpr | Saltar y girar |
| Hopeful | Esperanzado | tpr | Mirar hacia arriba sonriendo |
| Hopping | Dando brincos | tpr | Brincar sin parar |
| Hopscotch | Rayuela | tpr | Saltar a la pata coja en los cuadros |
| Horn | Bocina | tpr | Tocar la bocina |
| Horns | Cuernos | tpr | Poner los dedos como cuernos |
| Hot and sticky | Caluroso y húmedo | tpr | Abanicarse con la mano |
| Hot chocolate | Chocolate caliente | tpr | Soplar la taza de chocolate |
| Hot water bottle | Bolsa de agua caliente | tpr | Poner la bolsa templada en la barriga |
| Hot, hot, hot! | ¡Caliente, caliente, caliente! | tpr | Abanicar la mano como si quemara |
| Hours of sleep | Horas de sueño | tpr | Contar horas con los dedos |
| Hover | Cernerse | tpr | Quedarse con los brazos abiertos quietos |
| How are you feeling today? | ¿Cómo te sientes hoy? | tpr | Señalar el termómetro |
| How big is baby? | ¿Cuánto crece el bebé? | tpr | Abrir los brazos muy grandes |
| How can we help the planet? | ¿Cómo podemos ayudar al planeta? | tpr | Abrir las manos |
| How do you feel? | ¿Cómo te sientes? | tpr | Señalar el panel de las emociones |
| How does the story begin? | ¿Cómo empieza la historia? | tpr | Levantar un dedo |
| How high can you jump? | ¿Cuánto saltas? | tpr | Saltar lo más alto posible |
| How long can you stand on one leg? | ¿Cuánto aguantas a la pata coja? | tpr | Contar en un pie |
| How many chestnuts? | ¿Cuántas castañas? | tpr | Contar con los dedos |
| How many crates did we fill? | ¿Cuántas cajas llenamos? | tpr | Contar con los dedos |
| How many days until the party? | ¿Cuántos días faltan para la fiesta? | tpr | Contar con los dedos |
| How many legs has it got? | ¿Cuántas patas tiene? | tpr | Contar dedos |
| How many petals does it have? | ¿Cuántos pétalos tiene? | tpr | Contar con los dedos |
| How much is it? | ¿Cuánto cuesta? | tpr | Señalar la fruta |
| How old are you? | ¿Cuántos años tienes? | tpr | Enseñar los dedos |
| How old is this tree? | ¿Cuántos años tiene este árbol? | tpr | Contar anillos con el dedo |
| How would you feel if...? | ¿Cómo te sentirías si...? | tpr | Tocar el pecho preguntando |
| However, the gift paper was the loudest. | Sin embargo, el papel de regalo fue el que más sonó. | frases | — |
| Howl | Aullar | tpr | Levantar la cabeza y hacer «auuu» muy suave |
| Huddle | Acurrucarse juntos | tpr | Juntarse todos bajo una manta |
| Huddle together | Juntarse para calentarse | tpr | Apretarse todos juntos |
| Huff and puff | Soplar y soplar | tpr | Soplar muy fuerte |
| Hug a fish | Abrazar al pez | tpr | Abrazar un pez de peluche |
| Hug a friend | Abrazar a un amigo | tpr | Dar un abrazo suave |
| Hug a tree | Abrazar un árbol | tpr | Abrazar un tronco |
| Hug buddy | Compañero de abrazos | tpr | Abrazar un peluche |
| Hug goodbye | Abrazar al irse | tpr | Dar un abrazo al irse |
| Hug Lúa goodbye | Despedirse de Lúa con un abrazo | tpr | Abrazar un peluche |
| Huge | Enorme | tpr | Estirarse hacia arriba y hacia los lados a la vez |
| Hum | Tararear | tpr | Tararear con los labios cerrados: mmm |
| Hum a tune | Tararear | leccions, tpr | Tararear con los labios cerrados |
| Hum along | Tararear juntos | tpr | Tararear con la boca cerrada |
| Humid | Húmedo | tpr | Abanicarse |
| hungry | con hambre | leccions, tpr | Frotarse la barriga en círculos |
| Hurry | Darse prisa | tpr | Caminar rápido en el sitio con la cabeza tapada |
| Hush | Silencio | tpr | Poner el dedo en los labios |
| Hush, little baby | Shh, bebé | tpr | Mecer y cantar bajito |
| Hydrated | Bien hidratado | tpr | Beber y sonreír |
| Hypothesis | Hipótesis | tpr | Tocar la cabeza y decir «creo que» |
| I am blending yellow and blue because I want to make green. | Estoy mezclando amarillo y azul porque quiero hacer verde. | leccions | — |
| I am not finished yet | Todavía no he terminado | leccions | — |
| I am wet! | ¡Estoy mojado! | frases | — |
| I can blow harder, and so can you. | Yo puedo soplar más fuerte, y tú también. | frases | — |
| I can do it! | ¡Puedo yo! | tpr | Levantar los brazos orgulloso |
| I feel better after a hug | Me siento mejor después de un abrazo | tpr | Abrazarse |
| I feel happy because we play | Estoy contento porque jugamos | tpr | Sonreír y dar palmas |
| I feel proud of our work | Qué orgullo de nuestro trabajo | leccions | — |
| I found the star myself. | Encontré la estrella yo solo. | frases | — |
| I have been pulling the string. | Llevo un rato tirando del hilo. | frases | — |
| I have made a new one! | ¡He hecho una nueva! | frases | — |
| I help at home by setting the table | Ayudo en casa poniendo la mesa | tpr | Poner platos imaginarios |
| I like apples | Me gustan las manzanas | tpr | Abrazar una manzana imaginaria y sonreír |
| I like listening to your heart. | Me gusta escuchar tu corazón. | frases | — |
| I like mango | Me gusta el mango | tpr | Tocar la barriga contentos |
| I love you | Te quiero | tpr | Hacer un corazón con las manos |
| I push and it falls. | Empujo y se cae. | leccions | — |
| I put on my boots because it is raining. | Me pongo las botas porque está lloviendo. | leccions | — |
| I see it differently | Yo lo veo de otra manera | tpr | Girar la mano |
| I suggested painting three colours. | Yo propuse pintar tres colores. | frases | — |
| I think it will sink | Creo que se hundirá | tpr | Bajar la mano pensando |
| I think so because | Pienso eso porque | tpr | Tocar la cabeza y explicar |
| I want to be a baker | Quiero ser panadero | tpr | Amasar pan |
| I wish I had made a longer tube. | Ojalá hubiera hecho un tubo más largo. | frases | — |
| I wish it would thunder! | ¡Ojalá truene! | frases | — |
| I wish we had more rice. | Ojalá tuviéramos más arroz. | frases | — |
| I'm a lion! | ¡Soy un león! | tpr | Rugir y sacudir la melena |
| I'm a tiger! | ¡Soy un tigre! | tpr | Poner las garras y reír |
| I'm five and a half! | ¡Tengo cinco años y medio! | tpr | Enseñar cinco dedos y medio |
| I'm hungry | Tengo hambre | tpr | Tocarse la barriga y abrir la boca |
| I'm ready for Primary! | ¡Estoy listo para Primaria! | tpr | Levantar los brazos |
| I'm sorry | Lo siento | tpr | Poner la mano en el pecho |
| I'm taller now than in September | Ahora soy más alto que en septiembre | tpr | Medir con la mano |
| I'm taller than you! | ¡Soy más alto que tú! | tpr | Ponerse de puntillas riendo |
| Ice lolly | Polo | tpr | Lamer un polo imaginario |
| Iceberg | Iceberg | tpr | Hacer un pico con las manos |
| Icicle | Carámbano | tpr | Bajar un dedo como un carámbano |
| Icy | Helado | tpr | Temblar como en el hielo |
| Idea | Idea | tpr | Tocar la cabeza y abrir la mano |
| Identical | Idéntico | tpr | Juntar las palmas |
| Identify | Identificar | tpr | Nombrar algo tocándolo |
| If I had a spoon, I would play. | Si tuviera una cuchara, tocaría. | frases | — |
| If I take one away, there are four | Si quito uno, quedan cuatro | tpr | Bajar un dedo |
| If I touch you, you're it | Si te toco, pillas tú | tpr | Tocar y cambiar el papel |
| If I were you, I would flash twice. | Yo que tú, haría dos destellos. | frases | — |
| If it climbs the chestnut tree, crawl to the green mat | Si sube al castaño, gatea hasta la colchoneta verde | leccions | — |
| If it doesn't work, we try again | Si no funciona, volvemos a probar | tpr | Hacer y repetir |
| If it had rained, we would have found mud. | Si hubiera llovido, habríamos encontrado barro. | frases | — |
| If it is full, I say stop. | Si está lleno, digo para. | frases | — |
| If it were empty, it would sound high. | Si estuviera vacío, sonaría agudo. | frases | — |
| If it weren't windy, it wouldn't have moved. | Si no hiciera viento, no se habría movido. | frases | — |
| If it's hot, we play with water | Si hace calor, jugamos con agua | leccions, tpr | Abanicarse y salpicar |
| If it's sunny, we go to the beach; if it rains, we read | Si hace sol, vamos a la playa; si llueve, leemos | tpr | Abrir las manos y luego abrir un libro |
| If only the storm were louder! | ¡Si la tormenta fuera más fuerte! | frases | — |
| If the seed is big, put it in the brown pot | Si la semilla es grande, ponla en la maceta marrón | leccions | — |
| If the shell is smooth, put it in the blue basket | Si la concha es lisa, ponla en la cesta azul | leccions | — |
| If the water is cold, walk to the blue mat | Si el agua está fría, camina hasta la colchoneta azul | leccions | — |
| If we added water, it would sound low. | Si añadiéramos agua, sonaría grave. | frases | — |
| If we drink, it will be empty. | Si bebemos, se quedará vacío. | frases | — |
| If we had made it bigger, it would spin faster now. | Si lo hubiéramos hecho más grande, ahora giraría más rápido. | frases | — |
| If we had put it outside, it would be spinning now. | Si lo hubiéramos puesto fuera, ahora estaría girando. | frases | — |
| If we had used boots, we would have stayed clean. | Si hubiéramos llevado botas, nos habríamos quedado limpios. | frases | — |
| If we pick up plastic, fish are safer | Si recogemos el plástico, los peces están más seguros | tpr | Recoger y nadar |
| If you are the king, walk slowly | Si eres el rey, camina despacio | tpr | Caminar despacio y erguido |
| If you fold it, both halves match | Si lo doblas, las dos mitades coinciden | tpr | Doblar y juntar las manos |
| If you had blown, it would be turning. | Si hubieras soplado, estaría girando. | frases | — |
| If you had jumped, it would have splashed. | Si hubieras saltado, habría salpicado. | frases | — |
| If you pour slowly, it won't spill. | Si echas despacio, no se derramará. | frases | — |
| If you pour, the glass fills. | Si echas, el vaso se llena. | frases | — |
| If you roll a six, go again | Si sale un seis, vuelves a tirar | tpr | Tirar un dado imaginario |
| If you want to talk, raise your hand | Si quieres hablar, levanta la mano | tpr | Levantar la mano antes de hablar |
| Igloo | Iglú | tpr | Hacer una cúpula con los brazos |
| Illustrate | Ilustrar | tpr | Dibujar en el aire |
| Imaginary | Imaginario | tpr | Mover los dedos mágicos |
| Imagine | Imaginar | tpr | Cerrar los ojos y sonreír pensando |
| Imagine long ago | Imaginar hace mucho | tpr | Cerrar los ojos y pensar |
| Imagine the old ships | Imagina los barcos antiguos | tpr | Cerrar los ojos |
| In and out | Dentro y fuera | tpr | Meter y sacar el juguete de la caja |
| In my arms | En mis brazos | leccions, tpr | Coger al bebé en brazos |
| In order | En orden | tpr | Poner tres cosas en fila |
| In the barn | En el establo | tpr | Entrar agachados en un establo imaginario |
| In the basket | En la cesta | tpr | Meter castañas imaginarias en la cesta de los brazos |
| In the bath | En el baño | tpr | Meter un pie y luego el otro en una bañera imaginaria |
| In the morning, the ball rolls. | Por la mañana, la pelota rueda. | frases | — |
| In the nest | En el nido | tpr | Hacer un nido con las manos |
| In the past, people travelled by boat | Antes, la gente viajaba en barco | tpr | Remar sentados |
| In the pot | En la olla | tpr | Echar dentro de la olla imaginaria lo que cogimos |
| In the puddle | En el charco | tpr | Saltar y quedarse dentro |
| In the sand | En la arena | tpr | Sentarse y dibujar círculos en la arena imaginaria |
| In the shade | A la sombra | tpr | Llevar al bebé a la sombra |
| In the snow | En la nieve | tpr | Caminar levantando mucho los pies como en la nieve |
| In the tree | En el árbol | tpr | Señalar el árbol |
| Include someone | Incluir a alguien | tpr | Abrir el círculo |
| Inclusive | Que incluye a todos | tpr | Abrir el círculo a otro |
| Independent | Autónomo | tpr | Hacer el gesto de «puedo yo» |
| Independent learner | Aprendiz autónomo | tpr | Abrir un libro solo |
| Inside is warm | Dentro hace calorcito | tpr | Abrazarse dentro de casa |
| Inside out | Del revés | tpr | Dar la vuelta a una prenda imaginaria |
| Inside the hoop | Dentro del aro | tpr | Meterse dentro de un aro imaginario en el suelo |
| Intelligent | Inteligente | tpr | Tocar la cabeza |
| Invent | Inventar | tpr | Tocar la cabeza y abrir la mano |
| Investigate | Investigar | leccions, tpr | Mirar de cerca con atención |
| Invite | Invitar | leccions, tpr | Llamar a un amigo con la mano |
| Is ice hot or cold? | ¿El hielo es caliente o frío? | tpr | Temblar respondiendo |
| Is it cold? | ¿Está fría? | frases | — |
| Is it dry? | ¿Está seca? | frases | — |
| Is it going far? | ¿Está yendo lejos? | frases | — |
| Is it sweet or sour? | ¿Es dulce o ácido? | tpr | Sonreír o arrugar la cara |
| Is it the same on both sides? | ¿Es igual en los dos lados? | tpr | Comparar las manos |
| Is it warm? | ¿Está calentito? | tpr | Tocar la taza con cuidado |
| Islands in the sea | Islas en el mar | tpr | Hacer montes con las manos |
| It can't be full. | No puede estar lleno. | frases | — |
| It can't be warm. | No puede estar caliente. | frases | — |
| It could be empty. | Podría estar vacío. | frases | — |
| It didn't fall, did it? | No se cayó, ¿verdad? | frases | — |
| It falls because it wobbles. | Se cae porque se tambalea. | frases | — |
| It fell down because it was too high | Se cayó porque era muy alta | tpr | Dejar caer la torre y explicar con las manos |
| It floats because it's light | Flota porque es ligero | tpr | Subir las manos |
| It goes here | Va aquí | tpr | Dejar el juguete en su sitio |
| It is fair to share | Es justo compartir | leccions | — |
| It is raining hard | Llueve con fuerza | leccions | — |
| It is tall, but it falls. | Es alta, pero se cae. | frases | — |
| It is water. | Es agua. | frases | — |
| It melts because it's warm | Se derrite porque hace calor | tpr | Bajar el cuerpo despacio |
| It must be cold. | Tiene que estar frío. | frases | — |
| It smells good! | ¡Qué bien huele! | tpr | Oler el aire con cara de gusto |
| It was you who packed it. | Fuiste tú quien la hizo. | frases | — |
| It will be dry tomorrow. | Mañana estará seca. | frases | — |
| It's a deal! | ¡Trato hecho! | tpr | Darse la mano |
| It's a draw! | ¡Empate! | tpr | Juntar las manos |
| It's a star! | ¡Es una estrella! | tpr | Abrirse como una estrella |
| It's heavy, isn't it? | Pesa, ¿verdad? | frases | — |
| It's hot! | ¡Qué calor! | tpr | Abanicarse con la mano y soplar |
| It's pouring! | ¡Llueve mucho! | tpr | Bajar los brazos rápido |
| It's raining | Llueve | tpr | Mover los dedos de arriba abajo |
| It's the books that make it heavy. | Son los libros los que la hacen pesada. | frases | — |
| It's time we turned the torch off. | Ya es hora de que apaguemos la linterna. | frases | — |
| It's you! | ¡Eres tú! | tpr | Tocar el pecho del bebé |
| It's your turn to direct | Te toca dirigir | leccions, tpr | Pasar la claqueta |
| Jack-in-the-box | Caja sorpresa | tpr | Abrir la caja y decir «¡oh!» |
| Jelly | Gelatina | 0-2, leccions, tpr | Tocar la gelatina que tiembla |
| Jingle | Tintinear | tpr | Hacer sonar el cascabel |
| Jingle bell | Cascabel | 0-2, leccions, tpr | Agitar un cascabel |
| Jingle-jangle | Tintinear | tpr | Agitar unas llaves de juguete |
| Jog | Trotar | tpr | Correr despacio en el sitio |
| Joint | Articulación | tpr | Doblar el codo |
| Jolly | Alegre | tpr | Reír mucho con el bebé |
| journey | viaje | leccions | — |
| Joyful | Gozoso | tpr | Levantar los brazos contentos |
| Joyous | Gozoso | tpr | Saltar contentos |
| Jug | Jarra | 0-2, tpr | Llenar la jarra y vaciarla |
| Juice in a cup | Zumo en el vaso | tpr | Verter zumo en el vaso |
| Juicy | Jugoso, jugosa | tpr | Exprimir un racimo de uvas imaginario entre las manos |
| Jump | Saltar | leccions, tpr | Saltar con los dos pies a la vez |
| Jump and land | Salta y cae | tpr | Saltar y caer suave |
| Jump for joy | Saltar de alegría | tpr | Saltar con los brazos arriba |
| Jump in | Saltar dentro | leccions, tpr | Saltar dentro del charco |
| Jump in the puddle | Salta en el charco | tpr | Saltar con los dos pies dentro de un charco imaginario |
| Jump like a frog | Salta como una rana | tpr | Saltar desde agachados como una rana |
| Jump out | Saltar fuera | tpr | Saltar fuera del charco |
| Jump over the big puddle | Salta por encima del charco grande | leccions | — |
| Jump rope | Comba | tpr | Pasar la comba por el suelo |
| Jump up high | Saltar alto | tpr | Saltar con los brazos arriba |
| Jump, jump, green frog! Ribbit! | ¡Salta, salta, rana verde! ¡Croac! | leccions | — |
| Jumper | Jersey | tpr | Meter la cabeza por el jersey |
| Jumping | Saltando | tpr | Dar saltitos rápidos |
| Jungle | Selva | leccions, tpr | Apartar hojas con las manos |
| Keep | Guardar | tpr | Guardar el recuerdo en la caja |
| Keep a promise | Cumplir una promesa | tpr | Poner la mano en el pecho |
| Keep in touch | Seguir en contacto | tpr | Hacer un teléfono con la mano |
| Keep score | Llevar los puntos | tpr | Contar puntos con los dedos |
| Keep the beat | Llevar el ritmo | tpr | Golpear las piernas al ritmo |
| Keep to the path | Seguir el camino | tpr | Caminar por la línea |
| Keep warm | Mantener caliente | leccions, tpr | Tapar el huevo con las manos |
| Keep warm together | Calentarse juntos | tpr | Apretarse todos |
| Keep your distance | Guarda distancia | tpr | Estirar el brazo |
| Keepsake | Recuerdo | tpr | Enseñar un recuerdo pequeño |
| Kelp | Laminaria | tpr | Moverse ondulando como un alga |
| Kennel | Caseta | 0-2, tpr | Hacer un tejado con las manos |
| Kick | Dar una patada | tpr | Dar una patada suave a una pelota imaginaria |
| Kick a leaf | Chutar una hoja | leccions, tpr | Chutar una hoja seca |
| Kick leaves | Patear hojas | tpr | Mover los pies entre las hojas |
| Kick legs | Patalear | tpr | Mover las piernas del bebé como en bici |
| Kick water | Patalear en el agua | tpr | Mover las piernas en el agua |
| Kilo | Kilo | tpr | Pesar con la mano |
| Kind | Amable | tpr | Ofrecer algo con una sonrisa |
| Kind words | Palabras amables | tpr | Sonreír y hablar suave |
| Kind words make people smile | Las palabras amables hacen sonreír | tpr | Sonreír y señalar la boca |
| Kind-hearted | De buen corazón | tpr | Acariciar el brazo de un amigo |
| Kindest | El más amable | tpr | Sonreír muy grande |
| Kindness | Bondad | tpr | Hacer un corazón con las manos |
| Kindness jar | Bote de la bondad | tpr | Meter un papel en el bote |
| Kitchen | Cocina | tpr | Poner la mesa con platos imaginarios |
| Knead | Amasar | tpr | Amasar con las palmas |
| Knee | Rodilla | tpr | Tocar la rodilla y decir «pum» |
| Kneecap | Rótula | tpr | Tocar la rótula dos veces |
| Knees | Rodillas | leccions, tpr | Tocar las rodillas |
| Knees up, knees down | Rodillas arriba, rodillas abajo | tpr | Subir y bajar las rodillas |
| Knight | Caballero | leccions, tpr | Sostener un escudo imaginario |
| Knobbly | Nudoso | tpr | Tocar los nudos de la madera |
| Knock | Llamar (a la puerta) | tpr | Llamar a la calabaza con los nudillos: toc, toc |
| Knock down | Derribar | tpr | Derribar un castillo de arena imaginario con un dedo |
| Knock on the door | Llamar a la puerta | tpr | Golpear tres veces |
| Knock over | Derribar | tpr | Derribar la torre y reír |
| Knock, knock! | ¡Toc, toc! | tpr | Llamar dos veces en el aire y esperar |
| Knuckles | Nudillos | 0-2, leccions, tpr | Golpear despacio con los nudillos |
| Ladybird spots | Puntos de la mariquita | tpr | Contar puntos |
| Lamb | Cordero | 0-2, tpr | Hacer «beee» bajito |
| Lamp | Lámpara | tpr | Pulsar un botón imaginario y abrir las manos como luz |
| Lamp post | Farola | tpr | Estirarse alto como una farola |
| Land | Posarse | leccions, tpr | Bajar los brazos despacio y posarse en el suelo |
| Land softly | Caer suave | tpr | Caer doblando las rodillas |
| Landmark | Punto de referencia | tpr | Señalar algo grande y conocido |
| Lantern light | Luz de candil | tpr | Sostener una luz pequeña |
| Lap | Regazo | 0-2, tpr | Sentar al bebé en el regazo |
| Las olas de nuestra ría | Las olas de nuestra ría | 0-2-cancion | — |
| Last | Último, última | tpr | Ponerse al final de la fila y sonreír |
| Last day | Último día | tpr | Enseñar un dedo y despedirse |
| Last week | La semana pasada | tpr | Señalar atrás |
| Late | Tarde | tpr | Correr mirando el reloj |
| Laugh together | Reír juntos | tpr | Reír todos |
| Laundry basket | Cesto de la ropa | tpr | Llevar el cesto con las dos manos |
| Lay down | Acostar | tpr | Acostar al bebé boca arriba despacio |
| Lazy | Perezoso, perezosa | tpr | Estirarse muy despacio con un bostezo |
| Lead the way | Guiar | tpr | Caminar delante señalando |
| Leader | Líder | tpr | Ponerse delante y señalar el camino |
| Leaf litter | Hojarasca | tpr | Remover las hojas despacio |
| Leaf pile | Montón de hojas | 0-2, tpr | Hacer un montón de hojas |
| Leaf rubbing | Calco de hojas | tpr | Frotar una cera sobre el papel |
| Leaf-covered | Cubierto de hojas | tpr | Tapar los pies con hojas |
| Leafy | Frondoso | tpr | Mover las manos como hojas verdes |
| Leafy green | De hoja verde | tpr | Mover las manos como hojas |
| Leafy jungle | Selva frondosa | tpr | Mover los dedos como hojas |
| Leaky | Que gotea | tpr | Echar agua en un vaso con agujero |
| Lean forward | Inclinarse hacia delante | tpr | Inclinarse con las manos estiradas |
| Lean on | Apoyarse | tpr | Apoyar al bebé en el hombro |
| Leap | Brincar | tpr | Dar un brinco largo hacia delante |
| Leap out of the water | Saltar fuera del agua | tpr | Saltar con los brazos juntos |
| Learn to walk | Aprender a caminar | tpr | Dar pasitos inseguros |
| Leave only footprints | Deja solo huellas | tpr | Pisar y mirar la huella |
| Leaves are falling | Caen las hojas | leccions, tpr | Bajar los dedos como hojas |
| Leaves on my shoes | Hojas en los zapatos | tpr | Señalar las hojas en los pies |
| Left side | Lado izquierdo | tpr | Señalar el lado izquierdo |
| Leftover | Sobrante | tpr | Señalar lo que queda en el plato |
| Lentils | Lentejas | tpr | Echar lentejas en un bote |
| Less than three | Menos de tres | tpr | Enseñar dos dedos |
| Let go | Soltar | 0-2, leccions, tpr | Abrir la mano y soltar el juguete |
| Let sand run | Dejar caer arena | tpr | Abrir la mano y dejar caer arena |
| Let's breathe together | Respiremos juntos | tpr | Inspirar juntos |
| Let's build a bridge! | ¡Vamos a hacer un puente! | tpr | Juntar las manos en arco |
| Let's build a snowman | Vamos a hacer un muñeco de nieve | tpr | Amasar bolas de nieve imaginarias entre todos |
| Let's clean the beach! | ¡Vamos a limpiar la playa! | tpr | Coger una bolsa |
| Let's dance! | ¡Vamos a bailar! | tpr | Empezar a bailar |
| Let's dig! | ¡Vamos a cavar! | tpr | Cavar con la pala |
| Let's find a fair solution | Busquemos una solución justa | tpr | Juntar las manos |
| Let's find out! | ¡Vamos a descubrirlo! | tpr | Frotarse las manos |
| Let's get cosy | Vamos a calentarnos | tpr | Abrazarse bajo la manta |
| Let's go to the beach! | ¡Vamos a la playa! | tpr | Coger la mochila imaginaria y caminar contentos |
| Let's go to the park! | ¡Vamos al parque! | tpr | Coger la mano y caminar |
| Let's make music | Vamos a hacer música | tpr | Repartir instrumentos |
| Let's parade! | ¡Vamos a desfilar! | tpr | Ponerse en fila y marchar |
| Let's play! | ¡Vamos a jugar! | tpr | Levantar los brazos y echar a andar juntos |
| Let's sing! | ¡Vamos a cantar! | tpr | Abrir los brazos y empezar una canción |
| Let's stop to listen. | Paremos para escuchar. | frases | — |
| Let's try another way | Probemos de otra manera | tpr | Girar y empezar de nuevo |
| Let's vote! | ¡Vamos a votar! | tpr | Meter un papel en la urna |
| Letters and numbers | Letras y números | tpr | Dibujar una A y un 1 |
| Level | Nivelado | tpr | Poner los brazos a la misma altura |
| Library | Biblioteca | tpr | Pasar un libro despacio |
| Lick | Lamer | tpr | Lamer una piruleta imaginaria |
| Lick a lolly | Lamer el helado | tpr | Lamer en el aire |
| Lie on the grass | Tumbarse en la hierba | leccions, tpr | Tumbarse y mirar el cielo |
| Lie still | Quedarse quieto tumbado | tpr | Tumbarse sin moverse |
| Life jacket | Chaleco salvavidas | tpr | Ponerse un chaleco imaginario |
| Life story | Historia de vida | tpr | Mover la mano de atrás a adelante |
| Lift | Alzar | 0-2, leccions, tpr | Alzar al bebé por encima de la cabeza |
| Lift a log | Levantar un tronco | tpr | Levantar un tronco con cuidado |
| Lift head | Levantar la cabeza | tpr | Animar al bebé a levantar la cabeza boca abajo |
| Lift up | Levantar | leccions, tpr | Levantar una caja como la grúa |
| Light show | Espectáculo de luces | tpr | Mover las manos cambiando de color |
| Light steps | Pasos ligeros | tpr | Pisar muy suave |
| Light up | Iluminar | tpr | Abrir las manos de golpe |
| Lighter | Más claro | tpr | Señalar la hoja más clara |
| Lighter in weight | Más ligero | tpr | Subir la mano que pesa menos |
| Lighter than water | Más ligero que el agua | tpr | Subir la mano |
| Lightest | El más ligero | tpr | Subir el brazo al máximo |
| Lighthouse | Faro | tpr | Girar la cabeza despacio con una mano en la frente como una luz |
| Lights in the dark | Luces en la oscuridad | tpr | Abrir las manos en una sala oscura |
| Lights off! | ¡Luz apagada! | tpr | Apagar la luz y tapar la boca |
| Lights on! | ¡Luz encendida! | tpr | Encender la luz y sonreír |
| Lights out, eyes closed | Luz apagada, ojos cerrados | tpr | Apagar y cerrar los ojos |
| Lights, camera, action! | ¡Luces, cámara, acción! | tpr | Dar una palmada |
| Lightweight | Ligerito | tpr | Levantar la pelota con un dedo |
| Like a cat | Como un gato | tpr | Estirarse en el suelo como un gato al despertar |
| Line | Línea | tpr | Ponerse en línea, una criatura detrás de otra |
| Line them up | Ponerlos en fila | tpr | Poner los tesoros en fila |
| Line up | Ponerse en fila | tpr | Ponerse uno detrás de otro |
| Line up at the bell | Ponerse en fila al timbre | tpr | Ponerse en fila |
| Line up by size | Alinear por tamaño | tpr | Ponerse del más bajo al más alto |
| Listen | Escuchar | tpr | Llevarse la mano a la oreja y quedarse en silencio |
| Listen close | Escuchar de cerca | tpr | Llevar la mano a la oreja |
| Listen to the crunch | Escucha cómo cruje | tpr | Pisar y llevar la mano a la oreja |
| Listen to the woodpecker | Escucha al pájaro carpintero | tpr | Golpear con el dedo y escuchar |
| Listen with a hand to the ear | Escuchar con la mano en la oreja | tpr | Llevar la mano a la oreja |
| Listen with your eyes closed | Cierra los ojos y escucha | tpr | Cerrar los ojos |
| Listen, what's that? | Escucha, ¿qué es eso? | tpr | Parar y llevar la mano a la oreja |
| Listening tube | Tubo para escuchar | tpr | Escuchar el pecho de un amigo con un tubo de cartón |
| Litter | Basura | leccions, tpr | Coger basura del suelo |
| Little | Pequeñito, pequeñita | tpr | Juntar el pulgar y el índice dejando un hueco pequeño |
| Little finger | Meñique | tpr | Enganchar el meñique |
| Little fish | Pececito | 0-2, tpr | Mover la mano como un pececito |
| Little fish swimming under the sea! | ¡Pececitos nadando bajo el mar! | leccions | — |
| Little pig, let me in! | ¡Cerdito, déjame entrar! | tpr | Llamar a la puerta |
| Little seed, sleep | Semillita, duerme | tpr | Encoger el cuerpo como una semilla |
| Lively | Animado | tpr | Bailar con energía |
| Load | Cargar | tpr | Meter cajas imaginarias |
| Long | Largo, larga | tpr | Separar mucho las manos para mostrar algo largo |
| Long, long ago | Hace mucho, mucho tiempo | tpr | Señalar muy atrás |
| Long-legged | De patas largas | tpr | Estirar los dedos |
| Longer | Más largo | tpr | Separar mucho las manos |
| Longest night | La noche más larga | tpr | Separar mucho las manos |
| Look | Mirar | tpr | Hacer gafas con los dedos y mirar alrededor |
| Look after | Cuidar de | tpr | Tapar algo con las manos |
| Look after animals | Cuidar animales | tpr | Acariciar y dar de comer |
| Look at all the lights! | ¡Mira cuántas luces! | tpr | Abrir los brazos admirados |
| Look at it! | ¡Míralo! | frases | — |
| Look at me! | ¡Mírame! | tpr | Señalarse los ojos y luego al grupo |
| Look at old photos | Mirar fotos viejas | tpr | Pasar hojas de un álbum |
| Look at one spot | Mira un punto | tpr | Mirar un punto fijo |
| Look at the card and copy the shape | Mira la tarjeta y copia la forma | leccions | — |
| Look at the ducks! | ¡Mira los patos! | tpr | Señalar los patos |
| Look at the lights | Mira las luces | tpr | Señalar las luces al bebé |
| Look at this! | ¡Mira esto! | leccions | — |
| Look back | Mirar atrás | tpr | Mirar las fotos del curso |
| Look back on | Recordar | tpr | Mirar atrás sonriendo |
| Look behind you! | ¡Mira detrás de ti! | tpr | Señalar detrás |
| Look closely | Mirar de cerca | tpr | Acercar la lupa |
| Look for a hair. | Busca un pelo. | frases | — |
| Look for patterns | Buscar patrones | tpr | Mirar alrededor con la lupa |
| Look forward | Tener ganas | tpr | Mirar adelante sonriendo |
| Look how high it flies! | ¡Mira qué alto vuela! | tpr | Señalar muy alto |
| Look into the distance | Mirar a lo lejos | tpr | Mirar con la mano en la frente |
| Look left, look right | Mira a la izquierda, mira a la derecha | tpr | Mirar a los dos lados |
| Look out of the window | Mirar por la ventanilla | tpr | Mirar por la ventanilla con el dedo |
| Look outside! | ¡Mira fuera! | leccions | — |
| Look through | Mirar a través | tpr | Mirar por el tubo |
| Look through binoculars | Mirar con los prismáticos | tpr | Hacer prismáticos con las manos |
| Look through the binoculars | Mira por los prismáticos | tpr | Llevar las manos a los ojos |
| Look through the tube! | ¡Mira por el tubo! | tpr | Mirar por el tubo |
| Look under the log | Mira debajo del tronco | tpr | Levantar y mirar |
| Look up | Mirar arriba | tpr | Levantar la cabeza y mirar al cielo |
| Look what I found! | ¡Mira lo que encontré! | tpr | Abrir la mano con el tesoro |
| Look, a butterfly! | ¡Mira, una mariposa! | tpr | Señalar arriba con sorpresa y seguir el vuelo |
| Look, a rainbow! | ¡Mira, un arcoíris! | tpr | Señalar el cielo |
| Look, a sand pie! | ¡Mira, un flan de arena! | tpr | Señalar el flan |
| Look, a shell! | ¡Mira, una concha! | leccions, tpr | Agacharse y señalar el suelo con alegría |
| Look, a spiral! | ¡Mira, una espiral! | tpr | Dibujar la espiral |
| Look, dolphins! | ¡Mira, delfines! | tpr | Señalar el mar |
| Loose | Suelto | tpr | Soltar los brazos |
| Lopsided | Torcido | tpr | Inclinarse de un lado |
| Lose | Perder | tpr | Encoger los hombros y sonreír |
| Lost | Perdido | tpr | Mirar alrededor sin saber |
| Loud | Fuerte (sonido) | leccions, tpr | Dar palmadas con fuerza y luego parar |
| Loud and soft | Fuerte y suave | tpr | Golpear fuerte y luego suave |
| Loud bells! Shake fast! | ¡Campanas fuertes! ¡Agita rápido! | leccions | — |
| Loud, then quiet | Fuerte y luego suave | tpr | Golpear fuerte las piernas y luego muy suave |
| Loudest | El más fuerte | tpr | Cantar muy fuerte |
| Lovely | Precioso, preciosa | tpr | Juntar las manos en el pecho y suspirar |
| Loving | Cariñoso | tpr | Apretar suave al bebé contra el pecho |
| Low | Grave | leccions, tpr | Bajar la mano al cantar una nota grave |
| Lukewarm | Templado | tpr | Tocar el agua con el codo |
| Lullaby | Nana | tpr | Cantar una nana bajito |
| Lunch mat | Mantel individual | tpr | Extender el mantel |
| Lunch time | Hora de comer | tpr | Sentarse a la mesa |
| Lunchbox | Fiambrera | tpr | Abrir y cerrar la fiambrera |
| Lunge | Dar una zancada | tpr | Avanzar una pierna y doblarla |
| Magical | Mágico | tpr | Abrir los dedos de golpe |
| Majority | Mayoría | tpr | Contar manos levantadas |
| make | hacer | leccions | — |
| Make a card | Hacer una postal | tpr | Doblar un papel |
| Make a circle | Haced un círculo | tpr | Darse las manos y formar un círculo entre todos |
| Make a deal | Hacer un trato | tpr | Darse la mano y asentir |
| Make a resolution | Hacer un propósito | tpr | Poner la mano en el pecho |
| Make a shape | Hacer una forma | tpr | Hacer una forma con el cuerpo |
| Make a wish on a star | Pide un deseo a una estrella | tpr | Cerrar los ojos y sonreír |
| Make a wish! | ¡Pide un deseo! | tpr | Soplar el diente de león |
| Make faces | Hacer muecas | 0-2, leccions, tpr | Hacer caras divertidas en el espejo |
| Make up | Hacer las paces | tpr | Darse la mano |
| Make your pattern: clap, jump, tap | Haz tu serie: palmada, salto, golpe | leccions | — |
| Mane | Melena | tpr | Agitar el pelo como un león |
| Many bubbles! | ¡Muchas burbujas! | frases | — |
| Many-legged | De muchas patas | tpr | Mover todos los dedos |
| Marble | Canica | tpr | Dejar caer una canica |
| March | Marchar | tpr | Marchar en el sitio levantando las rodillas |
| March like a knight | Marchar como un caballero | tpr | Marchar recto |
| Marine life | Vida marina | tpr | Nadar con las manos |
| Mark the date | Marcar la fecha | tpr | Hacer un círculo con el dedo |
| Market | Mercado | tpr | Coger fruta imaginaria |
| Market stall | Puesto del mercado | leccions, tpr | Colocar fruta en el puesto |
| Mash | Chafar | tpr | Chafar fruta con el tenedor |
| Mashed banana | Plátano chafado | 0-2, tpr | Chafar el plátano con un tenedor |
| Mask | Máscara | leccions, tpr | Ponerse una máscara imaginaria delante de los ojos |
| Mask maker | Fabricante de máscaras | tpr | Recortar una máscara en el aire |
| Masked | Enmascarado | tpr | Taparse los ojos con las manos |
| Massage feet | Masajear los pies | tpr | Presionar suave la planta de los pies |
| Mast | Mástil | tpr | Estirarse muy recto |
| Mat | Esterilla | tpr | Enrollar la esterilla |
| Mat path | Camino de colchonetas | tpr | Caminar por las colchonetas |
| Match | Emparejar | tpr | Juntar dos pañuelos iguales |
| Match both sides | Igualar los dos lados | tpr | Mover las dos manos iguales |
| Match colours | Emparejar colores | tpr | Juntar dos hojas del mismo color |
| Matching | A juego | tpr | Enseñar dos guantes iguales |
| Mateo, find a round cold chestnut | Mateo, busca una castaña redonda y fría | leccions | — |
| May I see your ticket? | ¿Puedo ver tu billete? | leccions | — |
| Meadow | Prado | tpr | Abrir los brazos en el prado |
| Measure | Medir | tpr | Medir con los palmos |
| Measure a leaf | Medir una hoja | tpr | Medir con dedos |
| Measure height | Medir la altura | tpr | Ponerse contra la pared |
| Measure with hands | Medir con las manos | tpr | Medir a palmos |
| Measuring cup | Vaso medidor | tpr | Llenar hasta la raya |
| Meet the sea | Llegar al mar | leccions, tpr | Juntar las manos |
| Melody | Melodía | tpr | Mover la mano subiendo y bajando |
| Melt | Derretirse | tpr | Derretirse despacio hasta quedar tumbados |
| Melted water | Agua derretida | tpr | Abrir las manos como agua que escurre |
| Melty | Derretido | tpr | Dejarse caer despacio |
| Memorable | Memorable | tpr | Abrir mucho los ojos |
| Memory | Recuerdo | tpr | Tocar la cabeza sonriendo |
| Memory lane | Camino de los recuerdos | leccions, tpr | Caminar mirando atrás |
| Mend | Arreglar | tpr | Unir dos piezas |
| Meow! | ¡Miau! | tpr | Hacer bigotes con los dedos y decir «miau» |
| Merry | Festivo | tpr | Bailar con el bebé en el regazo |
| Merry and bright | Alegre y brillante | tpr | Dar palmas y abrir las manos |
| Merry Christmas! | ¡Feliz Navidad! | tpr | Abrir los brazos y desear feliz Navidad al grupo |
| Merry tune | Melodía alegre | tpr | Tararear una melodía alegre |
| Merry-go-round | Tiovivo | tpr | Girar en círculo con las manos estiradas |
| Messy | Desordenado, desordenada | tpr | Mover las manos hacia todos lados como un remolino |
| Metronome | Metrónomo | tpr | Mover el brazo como un metrónomo |
| Mew | Maullar | tpr | Hacer «miau» bajito |
| Microplastic | Microplástico | tpr | Juntar dos dedos muy poco |
| Middle | Mitad | leccions, tpr | Señalar el centro |
| Mighty | Poderoso | tpr | Poner los brazos fuertes |
| Mild | Suave | tpr | Mover la cabeza tranquilos |
| Milestone | Hito | tpr | Poner una piedra en el camino |
| Minty | De menta | tpr | Soplar aliento fresco |
| Mirror a friend | Imitar a un amigo como un espejo | tpr | Copiar los gestos de frente |
| Mirror check | Mirada al espejo | tpr | Mirarse en el espejo |
| Mirror line | Eje de simetría | tpr | Trazar una línea en el medio |
| Mirrored | Reflejado | tpr | Copiar un gesto al revés |
| Miss | Echar de menos | tpr | Abrazarse a uno mismo pensando en alguien |
| Mission | Misión | tpr | Señalar un objetivo |
| Misty | Brumoso | tpr | Mover las manos como niebla |
| Mittens | Manoplas | 0-2, leccions, tpr | Poner las manoplas al bebé |
| Mix | Mezclar | tpr | Mezclar pinturas imaginarias moviendo la mano en círculos |
| Mix colours | Mezclar colores | tpr | Remover con el dedo |
| Mmm, chestnuts! | ¡Mmm, castañas! | tpr | Tocar la barriga contentos |
| Mmm, orange! | ¡Mmm, naranja! | tpr | Oler la naranja y sonreír |
| Mobile | Móvil de cuna | tpr | Hacer girar el móvil de la cuna |
| Modern | Moderno | tpr | Estirarse alto como un edificio |
| Month | Mes | tpr | Señalar un mes |
| Moo! | ¡Muuu! | tpr | Hacer cuernos con los dedos y decir «muuu» |
| Mood | Estado de ánimo | tpr | Mover la mano arriba y abajo |
| Mood meter | Termómetro de las emociones | tpr | Subir y bajar el brazo |
| Moonlight | Luz de la luna | tpr | Mover las manos despacio y suave |
| More juice in my cup. | Más zumo en mi taza. | leccions | — |
| More than five | Más de cinco | tpr | Enseñar cinco dedos y uno más |
| More, please | Más, por favor | leccions, tpr | Juntar las puntas de los dedos de las dos manos |
| Morning | Mañana | tpr | Desperezarse y abrir los ojos despacio |
| Mosaic | Mosaico | leccions, tpr | Poner piezas una al lado de otra |
| Moss | Musgo | 0-2, tpr | Acariciar el musgo con el bebé |
| Most | El que más | tpr | Señalar el grupo grande |
| Most crabs walk sideways, but the spider crab walks forwards | La mayoría de los cangrejos camina de lado, pero la centolla camina hacia delante | tpr | Caminar de lado y después hacia delante |
| Most of us chose the park | La mayoría elegimos el parque | tpr | Contar manos y señalar |
| Mother bird | Mamá pájaro | tpr | Abrir los brazos como alas que protegen |
| Motionless | Inmóvil | leccions, tpr | Quedarse sin moverse |
| Motorbike | Moto | tpr | Girar el puño como una moto |
| Mould | Molde | tpr | Llenar un molde de arena |
| Move forward | Avanzar | tpr | Dar un paso adelante |
| Move like a robot | Moverse como un robot | tpr | Mover los brazos a golpes |
| Much taller | Mucho más alto | tpr | Estirarse mucho |
| Mud | Barro | tpr | Pisar despacio como si los pies se pegaran al barro |
| muddy | embarrado | leccions, tpr | Mirarse las botas imaginarias con cara de sorpresa |
| Muddy bank | Orilla embarrada | tpr | Pisar con cuidado |
| Muddy pig | Cerdo embarrado | tpr | Palmear las manos como en el barro |
| Multicoloured | Multicolor | tpr | Señalar muchos colores |
| Mummy | Mamá | tpr | Poner la mano en el corazón al decir mamá |
| Mummy and me | Mamá y yo | tpr | Señalar a mamá y luego al bebé |
| Munch | Masticar | leccions, tpr | Masticar contentos |
| Murky | Turbio | tpr | Mover las manos delante de los ojos |
| Muscles | Músculos | tpr | Enseñar el brazo fuerte |
| Muscular | Musculoso | tpr | Enseñar los dos brazos fuertes |
| Museum | Museo | tpr | Caminar despacio mirando |
| Mushy | Machacado | tpr | Machacar la castaña con un tenedor |
| Mushy peach | Melocotón blando | tpr | Chafar un melocotón maduro |
| Musical | Musical | tpr | Mover el cuerpo como si fuera un instrumento |
| Muslin cloth | Muselina | tpr | Tapar la cara con una muselina y descubrirla |
| Mussel | Mejillón | tpr | Abrir y cerrar las palmas juntas como un mejillón |
| Mussel raft | Batea | leccions, tpr | Hacer un cuadrado plano con las manos |
| Mussels grow on ropes under the raft | Los mejillones crecen en las cuerdas bajo la batea | tpr | Bajar los dedos |
| My face is turned upside down. | Mi cara se pone del revés. | frases | — |
| My favourite day was the beach | Mi día favorito fue la playa | tpr | Señalar el mar |
| My grandma is older than my mum | Mi abuela es mayor que mi madre | tpr | Señalar alto y menos alto |
| My torch. | Mi linterna. | frases | — |
| My turn | Mi turno | leccions, tpr | Tocar el pecho y sonreír |
| My turn, your turn | Mi turno, tu turno | tpr | Tocar la propia nariz y la del bebé |
| Mysterious | Misterioso | leccions, tpr | Caminar despacio y mirar a los lados |
| Mystery bag | Bolsa misteriosa | leccions, tpr | Meter la mano sin mirar |
| Nail brush | Cepillo de uñas | tpr | Frotar las uñas con el cepillo |
| Nails | Uñas | tpr | Mirarse las uñas con los dedos estirados |
| Name | Nombre | tpr | Poner la mano en el pecho al decir el propio nombre |
| Name a feeling | Nombrar un sentimiento | tpr | Señalar una cara |
| Name tag | Etiqueta del nombre | tpr | Señalar la etiqueta con el nombre |
| Nanny | Cuidadora | tpr | Señalar a la persona que cuida |
| Nap time | Hora de la siesta | tpr | Tumbarse en la esterilla |
| Napkin | Servilleta | tpr | Limpiar la boca con la servilleta |
| Nappy | Pañal | 0-2, tpr | Dar palmaditas suaves al pañal al cambiarlo |
| Nappy time! | ¡Hora del pañal! | tpr | Coger el pañal y enseñarlo |
| Narrow street | Calle estrecha | tpr | Juntar las manos cerca |
| Natural | Natural | tpr | Tocar una hoja |
| Nature | Naturaleza | tpr | Abrir los brazos al aire libre |
| Nature reserve | Espacio protegido | tpr | Abrazar el aire con cuidado |
| Near | Cerca | tpr | Acercar las manos hasta casi tocarse |
| Nearby | Cerca | tpr | Sentarse cerca de un amigo |
| Nearby shop | Tienda cercana | tpr | Señalar cerca |
| Nearly dry | Casi seco | tpr | Sacudir las manos sobre el lavabo |
| Neat | Ordenado | tpr | Alinear los zapatos juntos |
| Neatly folded | Bien doblado | tpr | Enseñar el pañuelo doblado |
| Neck | Cuello | tpr | Mover la cabeza despacio de un lado a otro |
| Necklace | Collar de cuentas | tpr | Dibujar un collar en el cuello |
| Nee-naw, nee-naw! | ¡Ni-no, ni-no! | tpr | Hacer la sirena y correr |
| Neigh | Relinchar | tpr | Hacer «hiii» y galopar sentados |
| Neighbour | Vecino | tpr | Saludar al vecino |
| Nervous but ready | Nervioso pero listo | tpr | Respirar hondo y sonreír |
| Never have we hidden the treasure so well! | ¡Nunca habíamos escondido el tesoro tan bien! | frases | — |
| New | Nuevo, nueva | tpr | Mostrar algo con las manos como si fuera un regalo |
| New Year | Año nuevo | tpr | Saltar al decir «año nuevo» |
| Newborn | Recién nacido | tpr | Acurrucarse muy pequeño |
| Newborn baby | Bebé recién nacido | tpr | Acunar en los brazos |
| Next in line | El siguiente | tpr | Señalar adelante |
| Next month | El mes que viene | tpr | Señalar adelante |
| Next stop | Siguiente parada | tpr | Señalar adelante |
| Next stop, please | En la siguiente, por favor | tpr | Pulsar el botón |
| Next to me | A mi lado | tpr | Dar unas palmaditas en el suelo al lado de uno mismo |
| Next year | El año que viene | tpr | Señalar adelante |
| Next year I will learn to read books by myself | El año que viene aprenderé a leer libros yo solo | tpr | Abrir un libro imaginario |
| Next year I will read more books | El año que viene leeré más libros | tpr | Abrir un libro imaginario |
| Next year we will be the oldest | El año que viene seremos los mayores | tpr | Estirarse de puntillas |
| Nibble | Mordisquear | tpr | Hacer que un peluche mordisquee la mano |
| Nice kitty | Qué gatito tan bueno | tpr | Acariciar al gatito y sonreír |
| Night light | Luz de noche | tpr | Hacer una luz pequeña con las manos |
| Nimble | Ágil | tpr | Mover los dedos rápido |
| Nimble-footed | De pies ágiles | leccions, tpr | Mover los pies muy rápido |
| No, thank you | No, gracias | leccions, tpr | Negar con la cabeza despacio y sonreír |
| Noa, walk five steps and take the white shell | Noa, da cinco pasos y coge la concha blanca | leccions | — |
| Noa, walk slowly and give the smooth leaf to your friend | Noa, camina despacio y dale la hoja lisa a tu amigo | leccions | — |
| Noisy | Ruidoso, ruidosa | tpr | Golpear el suelo con los pies y luego parar |
| Noisy engine | Motor ruidoso | tpr | Hacer «brum» muy alto |
| Noisy farm | Granja ruidosa | tpr | Hacer muchos sonidos de animales |
| Nose to nose | Nariz con nariz | tpr | Tocar nariz con nariz |
| Nostalgic | Nostálgico | tpr | Sonreír mirando atrás |
| Not once did you lose the map. | Ni una sola vez perdiste el mapa. | frases | — |
| Not too hot | No muy caliente | tpr | Tocar y retirar el dedo despacio |
| Notice | Darse cuenta | tpr | Parar y señalar |
| Notice feelings | Fijarse en los sentimientos | tpr | Mirar la cara de un amigo |
| Now the group copies your pattern | Ahora el grupo copia tu serie | leccions | — |
| Nudge | Empujar suave | tpr | Empujar la pelota con un dedo |
| Number line | Recta numérica | tpr | Caminar por una línea contando |
| Nursery | Escuela infantil | 0-2, tpr | Señalar la puerta de la escuela al llegar |
| Nursery rhyme | Canción infantil | tpr | Cantar una canción infantil |
| Nutritious | Nutritivo | tpr | Poner los brazos fuertes |
| Nutty | Con sabor a nuez | tpr | Oler una nuez abierta |
| Nuzzle | Acariciar con la nariz | tpr | Tocar la nariz del bebé con la nariz |
| Oak tree | Roble | tpr | Estirar los brazos como un roble |
| Oar | Remo | tpr | Mover un remo imaginario |
| Observation | Observación | tpr | Mirar con una lupa |
| Observe | Observar | tpr | Mirar sin tocar |
| Obstacle course | Circuito de obstáculos | tpr | Superar los obstáculos |
| Odd | Impar | tpr | Enseñar tres dedos |
| Off-stage | Fuera de escena | tpr | Agacharse detrás |
| Oink, oink! | ¡Oinc, oinc! | tpr | Levantar la nariz con un dedo y decir «oinc, oinc» |
| Old | Viejo, vieja | tpr | Soplar el polvo de un libro viejo imaginario |
| Old MacDonald had a farm | El viejo MacDonald tenía una granja | tpr | Cantar y hacer los animales |
| Old town | Casco viejo | tpr | Caminar por calles estrechas |
| Oldest | El más viejo | tpr | Señalar arriba en el álbum |
| On and off | Encendido y apagado | tpr | Encender y apagar dos veces |
| On Monday we push the ball. | El lunes empujamos la pelota. | frases | — |
| On the blanket | En la manta | tpr | Sentarse en la manta |
| On the bus | En el autobús | tpr | Sentarse como en el autobús |
| On the farm | En la granja | tpr | Abrir los brazos como la granja |
| On the grass | En la hierba | tpr | Sentarse en la hierba |
| On the ice | En el hielo | tpr | Caminar con cuidado |
| On the sofa | En el sofá | tpr | Sentarse en un sofá imaginario y estirar las piernas |
| On the tree | En el árbol | tpr | Colgar adornos en un árbol que hace una compañera |
| On time | A tiempo | tpr | Señalar el reloj y sonreír |
| On tiptoe | De puntillas | tpr | Caminar de puntillas |
| Once upon a time | Érase una vez | tpr | Abrir los brazos despacio como quien abre un cuento |
| One by one | Uno a uno | tpr | Tocar el hombro de cada criatura, de una en una |
| One fish, two fish | Un pez, dos peces | tpr | Enseñar una mano y luego las dos |
| One for you, one for me | Uno para ti, uno para mí | tpr | Repartir dos bloques |
| One leaf, two leaves | Una hoja, dos hojas | tpr | Enseñar una hoja y luego dos |
| One more bite | Un bocado más | tpr | Enseñar un dedo y dar otro bocado |
| One more sleep! | ¡Solo una noche más! | tpr | Enseñar un dedo |
| One peg, two pegs | Una pinza, dos pinzas | tpr | Poner una pinza y luego otra |
| One step, two steps | Un paso, dos pasos | tpr | Dar un paso y luego dos |
| One, two, toes | Uno, dos, deditos | tpr | Contar dos deditos de los pies |
| Only on the map can you find it. | Solo en el mapa puedes encontrarlo. | frases | — |
| Oops, it spilled! | ¡Uy, se ha derramado! | tpr | Señalar el agua y reír |
| Open | Abrir | tpr | Abrir las manos despacio como una flor |
| Open and shut | Abrir y cerrar | tpr | Abrir y cerrar las manos |
| Open hands to agree | Abrir las manos para acordar | tpr | Abrir las manos |
| Open like a flower | Ábrete como una flor | tpr | Desde agachados, abrir brazos y manos despacio |
| Open up | Abrir | tpr | Romper el papel juntos |
| Open up the fold | Abrir el doblez | tpr | Abrir la hoja despacio |
| Open wide | Abrir bien | tpr | Abrir mucho la boca con el bebé |
| Open your bag, take out your smock and smile | Abre la mochila, saca el babi y sonríe | leccions | — |
| Open your beak | Abrir el pico | tpr | Abrir mucho la boca |
| Open your mouth wide | Abrir mucho la boca | tpr | Abrir la boca como un león |
| Open your umbrella | Abre el paraguas | leccions | — |
| Open, shut them | Ábrelas, ciérralas | tpr | Abrir y cerrar las manos cantando |
| Open-minded | De mente abierta | tpr | Abrir las manos desde la cabeza |
| Opinion | Opinión | tpr | Poner la mano en el pecho y hablar |
| Opposite | Enfrente | tpr | Señalar el otro lado |
| Orange slice | Gajo de naranja | 0-2, leccions, tpr | Enseñar un gajo de naranja |
| Orange, which we made, is new. | El naranja, que hicimos nosotros, es nuevo. | frases | — |
| Orbit | Órbita | tpr | Caminar en círculo alrededor |
| Orchard | Huerto de frutales | tpr | Estirarse a coger fruta |
| Order | Orden | tpr | Poner tres cosas en fila |
| Organised | Organizado | tpr | Poner las cosas en fila |
| Ornament | Adorno | tpr | Colgar un adorno |
| Out of breath | Sin aliento | tpr | Respirar fuerte después de correr |
| Out of sight | Fuera de la vista | tpr | Taparse detrás de las manos |
| Out of the basket | Fuera de la cesta | tpr | Sacar un objeto de la cesta |
| Out of the egg | Fuera del huevo | tpr | Salir encogido y estirarse |
| Out of the puddle | Fuera del charco | tpr | Saltar y salir |
| Out of tune | Desafinado | tpr | Hacer una mueca graciosa |
| Out you come | Fuera del agua | tpr | Sacar al bebé de la bañera |
| Oval | Óvalo | tpr | Dibujar un óvalo en el aire |
| Over or under? | ¿Por encima o por debajo? | tpr | Señalar arriba y abajo |
| Over the log | Por encima del tronco | tpr | Pasar la pierna por encima |
| Over the stone | Por encima de la piedra | tpr | Pasar por encima de una piedra imaginaria con un paso largo |
| Over the waves | Por encima de las olas | tpr | Pasar la mano por encima en ondas |
| Overflowing | Rebosando | tpr | Llenar el vaso hasta que rebose |
| Overpass | Paso elevado | tpr | Pasar la mano por encima |
| Overwhelmed | Abrumado | tpr | Poner las manos en la cabeza y respirar |
| Owl hoot | Ululato del búho | tpr | Hacer «uuu» bajito |
| Pack | Hacer la maleta | tpr | Meter ropa imaginaria en una maleta |
| Pack the bag | Llenar la bolsa | tpr | Meter cosas en la bolsa |
| Pack your pencil case | Preparar el estuche | tpr | Meter lápices en el estuche |
| Paddle | Chapotear | tpr | Chapotear con los pies, sentados, en un agua imaginaria |
| Paddle across | Remar al otro lado | leccions, tpr | Remar hacia delante |
| Paddle boat | Hidropedal | tpr | Pedalear sentados |
| Paddle in | Mojar los pies | tpr | Mojar los pies en la orilla |
| Paddling pool | Piscina hinchable | 0-2, tpr | Meter los pies en la piscina |
| Paint stripes | Pintar rayas | tpr | Pintar rayas en la cara con el dedo |
| Pair | Pareja | tpr | Juntar dos dedos |
| Pair of socks | Par de calcetines | tpr | Juntar dos calcetines |
| Palm | Palma | 0-2, tpr | Hacer cosquillas en la palma de la mano |
| Panorama | Panorámica | tpr | Girar mirando alrededor |
| Paper boat race | Carrera de barcos de papel | tpr | Soplar un barco de papel |
| Paper cone | Cucurucho | tpr | Hacer un cucurucho de papel |
| Paper in the bin | Papel en la papelera | tpr | Tirar el papel |
| Paper towel | Papel de secar | tpr | Coger un papel y secar |
| Parade | Desfile | tpr | Desfilar en fila levantando las rodillas |
| Parade around | Desfilar | tpr | Caminar levantando las rodillas |
| Parasol | Sombrilla | 0-2, tpr | Hacer sombra con la mano |
| Park | Parque | tpr | Abrir los brazos y mirar alrededor contentos |
| Park bench | Banco del parque | tpr | Sentarse en el banco |
| Party blower | Matasuegras | 0-2, tpr | Soplar el matasuegras cerca del bebé |
| Pass | Pasar | tpr | Pasar un plato imaginario a quien está al lado |
| Pass around | Pasar de mano en mano | tpr | Pasar al bebé con cuidado al abuelo |
| Pass it, please | Pásamelo, por favor | tpr | Extender la mano |
| Pass me a peg | Pásame una pinza | tpr | Extender la mano |
| Pass the ball | Pasar la pelota | leccions, tpr | Pasar la pelota al de al lado |
| Pass the baton | Pasar el testigo | tpr | Dar el palo al siguiente |
| Pass the plate | Pasar el plato | tpr | Pasar el plato al siguiente |
| Pass the rhythm stick around the circle | Pasa el palo del ritmo alrededor del círculo | leccions | — |
| passport | pasaporte | leccions | — |
| Pastel | Pastel | tpr | Mover las manos suave |
| Pat | Dar palmaditas | tpr | Dar palmaditas suaves a un animal imaginario |
| Pat down | Aplanar | tpr | Aplanar la masa con la mano |
| Pat dry | Secar a toquecitos | tpr | Secar la piel a toquecitos |
| Pat softly | Dar palmaditas suaves | tpr | Dar palmaditas en la espalda suavemente |
| Pat the ball | Palmear la pelota | tpr | Palmear la pelota con la mano abierta |
| Pat the sand | Palmear la arena | tpr | Palmear la arena con la mano |
| Pat-a-cake | Palmitas | 0-2, leccions, tpr | Hacer palmitas con el bebé |
| Path | Camino | tpr | Caminar en fila por un camino imaginario |
| Pattern | Patrón | leccions, tpr | Dar palma, pie, palma, pie |
| Pause | Pausa | tpr | Parar con las manos abiertas |
| Pavement | Acera | tpr | Caminar por la acera |
| Paws | Zarpas | tpr | Caminar a cuatro patas |
| Pay | Pagar | tpr | Dar monedas imaginarias |
| Peace table | Mesa de la paz | tpr | Sentarse frente a frente |
| Peaceful | Sereno | tpr | Respirar despacio con el bebé en el pecho |
| Peaceful mind | Mente tranquila | tpr | Cerrar los ojos y respirar |
| Peaceful park | Parque tranquilo | tpr | Respirar hondo en el parque |
| Peaceful solution | Solución pacífica | tpr | Darse la mano sonriendo |
| Pebble path | Camino de piedrecitas | tpr | Poner piedrecitas en fila |
| Peck | Picotear | tpr | Picotear el suelo con los dedos juntos como un pico |
| Peck at seeds | Picotear semillas | tpr | Picotear con la mano como un pico |
| Pedal | Pedalear | tpr | Tumbarse boca arriba y pedalear en el aire |
| Peek | Espiar | tpr | Asomarse por un agujero hecho con los dedos |
| Peek out | Espiar | tpr | Espiar entre los dedos |
| Peekaboo! | ¡Cucú, tras! | tpr | Tapar la cara y descubrirla |
| Peekaboo, I see you! | ¡Cucú, ya te veo! | tpr | Tapar la cara y descubrirla |
| Peel | Pelar | tpr | Pelar una castaña imaginaria con las puntas de los dedos |
| Peel a carrot | Pelar una zanahoria | tpr | Pelar en el aire |
| Peep out | Asomarse | tpr | Asomar la cabeza detrás de un pañuelo |
| Peer | Asomarse a mirar | tpr | Mirar entre las hojas |
| Peg | Percha con el nombre | tpr | Colgar la mochila en su percha |
| Peg bag | Bolsa de las pinzas | tpr | Coger una pinza |
| Peg up | Sujetar con la pinza | leccions, tpr | Poner una pinza en la ropa |
| Pencil case | Estuche | tpr | Abrir y cerrar el estuche |
| Perch | Posarse | tpr | Agacharse como un pájaro en una rama |
| Periwinkle | Bígaro | tpr | Hacer una espiral con el dedo |
| Pet care | Cuidado de la mascota | tpr | Acariciar y dar de comer |
| Petal | Pétalo | 0-2, tpr | Pasar un pétalo por la mejilla |
| Petal count | Cuenta de pétalos | tpr | Contar pétalos con los dedos |
| Photo album | Álbum de fotos | tpr | Pasar las hojas del álbum juntos |
| Photo wall | Mural de fotos | tpr | Buscar la propia foto en el mural |
| Pick | Coger | tpr | Estirarse para coger fruta de un árbol |
| Pick a daisy | Coger una margarita | tpr | Coger una flor con cuidado |
| Pick up baby | Coger al bebé | tpr | Levantar al bebé del suelo despacio |
| Pick up litter | Recoger basura | tpr | Agacharse y coger |
| Pick up toys | Recoger juguetes | leccions, tpr | Agacharse y coger un juguete |
| Pick up trash | Recoger desperdicios | tpr | Agacharse y coger |
| Pick up two acorns and put them in the basket | Coge dos bellotas y ponlas en la cesta | leccions | — |
| Pick up! | Recoger | 0-2, leccions, tpr | Agacharse y recoger algo del suelo |
| Picnic | Pícnic | tpr | Extender un mantel imaginario y sentarse alrededor |
| Picnic basket | Cesta de merienda | tpr | Abrir la cesta |
| Picnic blanket | Manta de pícnic | tpr | Extender la manta en la hierba |
| Picnic spot | Sitio de merienda | tpr | Señalar un buen sitio |
| Piece by piece | Trozo a trozo | tpr | Dar la fruta trozo a trozo |
| Pier | Muelle | tpr | Caminar hasta el final del muelle |
| Pigeon | Paloma | tpr | Arrullar y mover la cabeza |
| Pile of leaves | Pila de hojas | tpr | Saltar encima de la pila de hojas |
| Pillow | Almohada | tpr | Hundir la cabeza en una almohada imaginaria |
| Pinch softly | Pellizcar suave | tpr | Pellizcar suave la mejilla |
| Pinecone | Piña | tpr | Enseñar una piña imaginaria y hacerla rodar entre las manos |
| Pinecone scales | Escamas de la piña | tpr | Tocar las escamas |
| Pink | Rosa | tpr | Señalar algo rosa en el aula |
| Pinky promise | Promesa de meñiques | tpr | Enganchar los meñiques |
| Pinwheel | Molinillo | tpr | Soplar el molinillo |
| Pipette | Pipeta | tpr | Coger agua con la pipeta |
| Pirate | Pirata | tpr | Taparse un ojo con la mano |
| Pitter-pat | Repiquetear | tpr | Golpear con los dedos en el suelo |
| Pitter-patter | Repiquetear | 0-2, leccions, tpr | Golpear con los dedos en la mesa como la lluvia |
| Place | Sitio | tpr | Señalar el sitio de cada cosa |
| Plan | Plano | tpr | Señalar un plano dibujado |
| Plan ahead | Planificar | tpr | Señalar adelante en el calendario |
| Plan B | Plan B | tpr | Levantar dos dedos |
| Planet care | Cuidado del planeta | tpr | Abrazar una bola del mundo |
| Plant a seed | Plantar | tpr | Hundir un dedo en la tierra |
| Plant a tree | Plantar un árbol | tpr | Cavar y regar |
| Plastic | Plástico | tpr | Arrugar un plástico |
| Plastic goes in the yellow bin | El plástico va en el contenedor amarillo | tpr | Echar y señalar el amarillo |
| Play | Jugar | tpr | Mover el cuerpo con alegría en el sitio |
| Play dough | Plastilina | tpr | Hacer una bola de plastilina |
| Play fair | Jugar limpio | tpr | Darse la mano antes de jugar |
| Playful | Juguetón, juguetona | tpr | Dar pequeños brincos como un cachorro |
| Playful summer | Verano juguetón | tpr | Bailar contentos |
| Playmat | Alfombra de juego | tpr | Tumbar al bebé en la alfombra de juego |
| Playtime bell | Timbre del recreo | tpr | Hacer «riiing» |
| Plentiful | Abundante | tpr | Abrir los brazos mucho |
| Plot twist | Giro en la historia | tpr | Girar y abrir la boca |
| Plough | Arar | tpr | Empujar un arado imaginario caminando despacio |
| Plum | Ciruela | tpr | Enseñar la ciruela morada |
| Pocket | Bolsillo | tpr | Meter las manos en los bolsillos |
| Poem | Poema | tpr | Recitar moviendo la mano |
| Poetic | Poético | tpr | Mover la mano despacio |
| Point at | Señalar a | tpr | Señalar un pájaro |
| Point of view | Punto de vista | tpr | Mirar desde otro lado |
| Point to | Señalar | tpr | Señalar la nariz del bebé |
| Point to the sky | Señalar el cielo | tpr | Señalar arriba |
| Pointed | Con punta | leccions, tpr | Tocar la punta de un triángulo |
| Pointer | Aguja | tpr | Mover un dedo como una aguja |
| Pointy | Puntiagudo, puntiaguda | leccions, tpr | Juntar las manos en punta por encima de la cabeza |
| Poke | Tocar con el dedo | tpr | Tocar la masa con el dedo índice |
| Polite | Educado | tpr | Decir «gracias» con la mano en el pecho |
| Polluted | Contaminado | tpr | Taparse la nariz |
| Pom-pom | Pompón | 0-2, tpr | Agitar un pompón de colores |
| Pond | Estanque | tpr | Mirar al suelo como si nos viéramos reflejados |
| Pond duck | Pato del estanque | tpr | Caminar como un pato |
| Pop | Explotar | leccions, tpr | Juntar las manos de golpe: ¡pum! |
| Pop out | Asomar | tpr | Sacar un dedo del puño |
| Pop out and dance around the fire | Sal y baila alrededor del fuego | leccions | — |
| Pop out from behind | Salir de detrás | tpr | Asomar la mano de golpe |
| Pop up | Aparecer de golpe | tpr | Aparecer de golpe detrás del sofá |
| Pop, pop, pop! | ¡Pop, pop, pop! | tpr | Tocar tres burbujas |
| Pop-up toy | Juguete sorpresa | tpr | Pulsar el botón y ver salir el juguete |
| Popping sound | Estallido | tpr | Hacer «pop» con los labios |
| Pose | Posar | tpr | Sonreír quietos para la foto |
| Post a letter | Echar una carta | tpr | Meter una hoja por una ranura |
| Postcard | Postal de viaje | tpr | Escribir una postal |
| Postman | Cartero | tpr | Entregar una carta |
| Posture | Postura | tpr | Sentarse bien recto |
| Pot lid | Tapa de olla | tpr | Golpear dos tapas despacio |
| Pounce | Abalanzarse | tpr | Saltar hacia adelante con las manos |
| pour | verter | leccions, tpr | Echar agua imaginaria de un vaso a otro |
| Pour carefully | Verter con cuidado | leccions, tpr | Verter despacio de un vaso a otro |
| Pour down | Llover a cántaros | leccions, tpr | Bajar los brazos rápido |
| Pour it out | Viértela | tpr | Verter la jarra despacio |
| Pour tea | Servir el té | tpr | Inclinar la tetera de juguete |
| Pram | Cochecito | tpr | Empujar el cochecito despacio |
| Precious | Precioso | tpr | Acariciar la mano del bebé |
| Precious sea | Mar valioso | tpr | Poner las manos en el pecho |
| Predict | Predecir | tpr | Tocar la cabeza pensando |
| Predict what's next | Adivinar lo siguiente | tpr | Señalar lo que viene |
| Prediction | Predicción | tpr | Tocar la cabeza pensando |
| Press hands | Presionar las manos | tpr | Presionar la mano en el papel |
| Press the bell | Pulsar el timbre | tpr | Pulsar un botón en el aire |
| Pretend | Hacer como que | tpr | Poner cara de misterio y jugar a ser otro animal |
| Pretty | Lindo, linda | tpr | Mirar una flor imaginaria y sonreír |
| Price | Precio | tpr | Señalar una etiqueta |
| Prickly | Pinchudo | tpr | Acercar y alejar la mano del erizo |
| Primary colours | Colores primarios | tpr | Enseñar tres dedos |
| Primary school | Colegio de Primaria | leccions, tpr | Señalar un edificio grande |
| Prism | Prisma | tpr | Mirar la luz en un cristal |
| Problem | Problema | tpr | Rascarse la cabeza pensando |
| Promise | Prometer | tpr | Enganchar los meñiques |
| Promise card | Tarjeta del compromiso | tpr | Posar la mano en la tarjeta |
| Props | Atrezo | tpr | Coger objetos imaginarios |
| protect | proteger | leccions, tpr | Cubrir algo con las manos |
| Protected | Protegido | tpr | Hacer una cúpula con las manos |
| Proud | Orgulloso, orgullosa | tpr | Levantar la barbilla y caminar como un león |
| Proud of myself | Orgulloso de mí | tpr | Poner las manos en el pecho |
| Proud parents | Familias orgullosas | tpr | Aplaudir fuerte |
| Proud peacock | Pavo real presumido | tpr | Abrir los brazos como un pavo real |
| Prowl | Acechar | tpr | Caminar agachado despacio |
| Puddle | Charco | leccions, tpr | Dibujar un charco redondo en el suelo con el pie |
| Puddle edge | Borde del charco | tpr | Caminar por el borde del charco |
| Puddle ice | Hielo en el charco | tpr | Pisar despacio como sobre hielo |
| Puddle jump | Salto al charco | tpr | Saltar dentro de un charco pintado |
| Puff of steam | Bocanada de vapor | tpr | Abrir las manos hacia arriba |
| Pull | Tirar de | leccions, tpr | Tirar de una cuerda imaginaria hacia uno mismo |
| Pull a face | Poner una mueca | tpr | Arrugar la nariz |
| Pull faces | Poner caras | tpr | Abrir mucho la boca y los ojos |
| Pull on | Ponerse tirando | leccions, tpr | Tirar del jersey hacia abajo |
| Pull on boots | Calzarse las botas | tpr | Tirar de las botas hacia arriba |
| Pull the rope together: one, two, three! | ¡Tirad juntos de la cuerda: uno, dos, tres! | leccions | — |
| Pull the strings | Mover los hilos | tpr | Mover los dedos hacia arriba |
| Pull up the rope | Tirar de la cuerda | tpr | Tirar de la cuerda hacia arriba |
| Pull, pull, pull! | ¡Tira, tira, tira! | tpr | Tirar de la cuerda |
| Pulse | Pulso | tpr | Poner dos dedos en la muñeca |
| Pump the soap | Apretar el jabón | leccions, tpr | Apretar una vez el dosificador |
| Pumpkin | Calabaza | leccions, tpr | Hacer una calabaza grande con los brazos en círculo |
| Pumpkin coach | Carroza de calabaza | tpr | Hacer una bola grande |
| Puppet | Títere | tpr | Hacer hablar a la mano como un títere |
| Puppet show | Función | tpr | Abrir una cortina imaginaria |
| Puppet theatre | Teatro de títeres | tpr | Hacer una ventana con las manos |
| Puppeteer | Titiritero | tpr | Mover un títere desde arriba |
| Purr | Ronronear | tpr | Frotar la mejilla en la mano como un gato contento |
| Purring | Que ronronea | tpr | Hacer «rrrr» en la barriga |
| Put arms in | Meter los brazos | tpr | Meter un brazo y luego el otro |
| Put away | Guardar | leccions, tpr | Guardar un bloque en su sitio |
| Put it back gently | Devolverlo con cuidado | tpr | Posar algo muy despacio |
| Put it under the bridge. | Ponlo debajo del puente. | leccions | — |
| Put on | Ponerse | leccions, tpr | Ponerse una prenda imaginaria por la cabeza |
| Put on your animal mask and roar | Ponte la máscara de animal y ruge | leccions | — |
| Put on your sun hat | Ponte el sombrero | tpr | Ponerse el sombrero al oír la orden |
| Put on your winter boots | Ponte las botas de invierno | leccions | — |
| Put out a fire | Apagar un fuego | tpr | Mover la manguera |
| Put the boat in the water! | ¡Pon el barco en el agua! | frases | — |
| Put the lens down gently. | Deja la lupa con cuidado. | frases | — |
| Put the rough one here and the smooth one there | Pon la áspera aquí y la lisa allí | leccions | — |
| Put up the umbrella | Abre el paraguas | tpr | Abrir un paraguas imaginario de golpe |
| Put your arms up and your left foot forward | Brazos arriba y el pie izquierdo adelante | leccions | — |
| Put yourself in their shoes | Ponerse en su lugar | tpr | Cambiar de sitio con un amigo |
| Pyjamas | Pijama | tpr | Meter un brazo y luego el otro en un pijama imaginario |
| Pyramid | Pirámide | tpr | Juntar las manos en punta |
| Question mark | Signo de interrogación | tpr | Dibujar un signo en el aire |
| Queue up | Hacer cola | tpr | Ponerse en fila para el lavabo |
| Quick-thinking | Espabilado | tpr | Tocar la cabeza y sonreír |
| Quiet as a mouse | Callado como un ratón | tpr | Andar de puntillas sin hacer ni un ruido |
| Quiet bells... sleep | Campanas calladas... a dormir | leccions | — |
| Quiet car | Coche silencioso | tpr | Mover la mano sin hacer ruido |
| Quiet corner | Rincón tranquilo | tpr | Sentarse en el rincón |
| Quiet time | Tiempo tranquilo | leccions, tpr | Sentarse en silencio |
| Quiet: hands on your tummy | Silencio: manos en la barriga | leccions | — |
| Quietly, quietly | Bajito, bajito | tpr | Caminar muy despacio |
| Quilt | Edredón | 0-2, tpr | Tapar al bebé con el edredón |
| Quince | Membrillo | tpr | Coger un membrillo |
| Race | Echar una carrera | tpr | Ponerse en la línea de salida y contar hasta tres |
| Race track | Pista de carreras | tpr | Correr por la pista pintada |
| Racing heart | Corazón acelerado | tpr | Golpear rápido en el pecho |
| Radiator | Radiador | tpr | Acercar las manos al radiador |
| Rain cover | Plástico del cochecito | 0-2, tpr | Tapar el cochecito con el plástico |
| Rain gauge | Pluviómetro | tpr | Llenar un vaso de lluvia |
| Rain hat | Gorro de lluvia | tpr | Ponerse el gorro de lluvia |
| Rain jacket | Chaqueta de lluvia | tpr | Ponerse la chaqueta y la capucha |
| Rain on the window | Lluvia en el cristal | tpr | Golpear despacio en el cristal |
| Rain stick | Palo de lluvia | tpr | Girar el palo de lluvia despacio |
| Rain, rain, little drops, tap, tap, tap | Lluvia, lluvia, gotitas, tap, tap, tap | leccions | — |
| Rain, then sun | Lluvia y luego sol | tpr | Hacer lluvia con los dedos y luego abrir las manos como el sol |
| Rainbow-coloured | Multicolor | tpr | Mover la cinta de colores |
| Rainbow-striped | De rayas de colores | tpr | Dibujar un arco de colores |
| Raincoat | Chubasquero | leccions, tpr | Ponerse la capucha de un chubasquero imaginario |
| Raindrop | Gota | 0-2, tpr | Tocar la mano con un dedo como una gota |
| Rainwater | Agua de lluvia | tpr | Coger agua de lluvia en un vaso |
| Raise a hand | Levantar la mano | tpr | Levantar la mano y esperar |
| Raisin | Pasa | tpr | Mostrar una pasa en la palma de la mano |
| Rake | Rastrillo | 0-2, tpr | Pasar un rastrillo de juguete |
| Ramp | Rampa | tpr | Dejar bajar la pelota por la rampa |
| Rarely is a treasure so close! | ¡Pocas veces un tesoro está tan cerca! | frases | — |
| Rattle | Sonajero | tpr | Agitar un sonajero imaginario junto a la oreja |
| Rattle toy | Juguete sonoro | tpr | Agitar el juguete cerca de la oreja |
| Rattly | Que suena | tpr | Agitar la botella con arroz |
| Razor clam | Navaja | tpr | Estirar la mano larga y fina |
| Reach | Alcanzar | tpr | Estirar el brazo para coger algo alto |
| Reach for | Intentar coger | tpr | Estirar la mano hacia la burbuja |
| Reach up | Estirarse hacia arriba | tpr | Levantar los brazos al sol |
| React | Reaccionar | tpr | Moverse rápido a la señal |
| Reaction | Reacción | tpr | Moverse al oír una palmada |
| Read | Leer | tpr | Abrir un libro imaginario y seguir las líneas con el dedo |
| Read in the shade | Leer a la sombra | tpr | Sentarse y abrir un libro |
| Read me a story | Léeme un cuento | tpr | Traer un libro |
| Ready | Listo, lista | tpr | Poner las manos en las rodillas y mirar a la persona docente |
| Ready for more | Listo para más | tpr | Dar un paso adelante |
| Ready for Primary | Listo para Primaria | tpr | Levantar el pulgar |
| Ready to go! | ¡Listos para salir! | tpr | Ponerse de pie y colocar las manos en las correas de la mochila |
| Ready, go! | ¡Listos, ya! | tpr | Salir corriendo al oír «ya» |
| Ready, set, blow! | ¡Preparados, listos, sopla! | tpr | Soplar a la señal |
| Ready, steady, go! | ¡Preparados, listos, ya! | tpr | Agacharse, prepararse y salir al decir «go» |
| Ready, steady, go: pass the tray to your friend | Preparados, listos, ya: pásale la bandeja a tu amigo | leccions | — |
| Ready, steady, stop! | ¡Preparados, listos, para! | tpr | Parar en el «para» |
| rebuild | reconstruir | leccions | — |
| Receive | Recibir | tpr | Extender las manos y coger |
| Recharge | Recargar | leccions, tpr | Encogerse y luego estirarse |
| Recite | Recitar | tpr | Hablar alto con una mano en el pecho |
| Record | Anotar | tpr | Hacer una marca en la tabla |
| Rectangle | Rectángulo | tpr | Hacer un rectángulo con los dedos |
| Recycling bin | Contenedor de reciclaje | leccions, tpr | Echar algo en el contenedor |
| Red and yellow | Rojo y amarillo | tpr | Tocar algo rojo y luego algo amarillo |
| Red ball | Pelota roja | 0-2, leccions, tpr | Rodar la pelota roja |
| Red card | Tarjeta roja | leccions, tpr | Parar al ver la tarjeta roja |
| Red, blue, red, blue | Rojo, azul, rojo, azul | tpr | Alternar manos |
| Red, orange and brown | Rojo, naranja y marrón | tpr | Enseñar tres hojas |
| Red, red, red! | ¡Rojo, rojo, rojo! | tpr | Tocar tres cosas rojas |
| Red, which is warm, mixes with yellow. | El rojo, que es cálido, se mezcla con el amarillo. | frases | — |
| Reddish | Rojizo | tpr | Enseñar una hoja rojiza |
| Reef | Arrecife | tpr | Hacer formas con las manos |
| Referee | Árbitro | tpr | Silbar y levantar la mano |
| Referee's whistle | Silbato del árbitro | tpr | Parar al oír el pitido |
| Reflection | Reflejo | tpr | Señalar al bebé en el espejo |
| Reflection game | Juego del espejo | tpr | Copiar los movimientos de un amigo |
| Refract | Separar la luz | tpr | Abrir la mano en abanico |
| Refreshed | Descansado y fresco | tpr | Desperezarse sonriendo |
| Refreshing | Refrescante | tpr | Beber y decir «aaah» |
| Refreshing splash | Salpicón refrescante | tpr | Sacudir las manos mojadas |
| Regular | Regular | tpr | Golpear siempre igual |
| Rehearse | Ensayar | tpr | Repetir un gesto varias veces |
| Reindeer | Reno | tpr | Poner las manos como cuernos |
| Relax | Relajarse | tpr | Soltar los brazos |
| Relaxed | Relajado, relajada | tpr | Soltar el cuerpo y respirar despacio |
| Relaxed summer | Verano tranquilo | tpr | Tumbarse a descansar |
| Relaxing | Relajante | tpr | Soltar los hombros |
| Relay race | Carrera de relevos | tpr | Pasar el testigo |
| Remember | Recordar | tpr | Tocarse la cabeza y asentir |
| Remember the past | Recordar el pasado | tpr | Señalar atrás |
| Remember when | Recordar cuando | tpr | Tocar la cabeza y señalar atrás |
| Remote | Lejano | tpr | Señalar muy lejos |
| Renewable | Renovable | tpr | Hacer un círculo con la mano |
| Repeat | Repetición | tpr | Hacer el mismo gesto dos veces |
| Repeating | Que se repite | tpr | Hacer el mismo gesto otra vez |
| Reply | Responder | tpr | Hacer que el títere responde |
| Respectful | Respetuoso | tpr | Escuchar mirando a quien habla |
| Responsible | Responsable | leccions, tpr | Cuidar la planta de la clase |
| Rest | Descansar | tpr | Apoyar la cabeza en los brazos y respirar despacio |
| Rest at the top | Descansar arriba | tpr | Sentarse y respirar |
| Rest time | Descanso | tpr | Apoyar la cabeza en las manos |
| Rested and happy | Descansado y contento | tpr | Estirar los brazos contentos |
| Restful | Relajante | tpr | Cerrar los ojos despacio |
| Resting | En reposo | tpr | Tumbarse tranquilos |
| Result | Resultado | tpr | Enseñar el resultado con los dedos |
| Retell | Volver a contar | tpr | Contar con los dedos |
| Return | Volver | tpr | Dar la vuelta y caminar de nuevo hacia el círculo |
| Reusable bag | Bolsa reutilizable | tpr | Doblar y guardar la bolsa |
| Reuse | Reutilizar | tpr | Usar otra vez la bolsa |
| Rhyme | Rimar | tpr | Dar palmas en dos palabras que suenan igual |
| Rhyme card | Tarjeta de rima | tpr | Levantar dos tarjetas que riman |
| Rhyming | Que rima | tpr | Dar dos palmadas |
| Rhythm | Ritmo | tpr | Golpear en las piernas al ritmo |
| Rhythmic | Rítmico | leccions, tpr | Mover la cabeza al ritmo |
| Ribbon stick | Palo con cinta | tpr | Hacer círculos con la cinta |
| Ride | Montar | tpr | Montar en una bici imaginaria en el sitio |
| Ridged | Con estrías | tpr | Pasar el dedo por las estrías de la concha |
| Right side | Lado derecho | tpr | Señalar el lado derecho |
| Right-hand | Derecho | tpr | Levantar la mano derecha |
| Ring bells | Toca las campanas | tpr | Hacer sonar campanas imaginarias con las dos manos |
| Ring-a-ring o' roses, a pocket full of posies. | Corro de rosas, el bolsillo lleno de flores. | 0-2-rima | — |
| Rinse | Aclarar | tpr | Pasar las manos bajo un agua imaginaria |
| Rinse cup | Vaso de enjuagar | tpr | Llenar el vaso de agua |
| Rinse off | Aclarar | tpr | Echar agua por la espalda |
| Rinse off sand | Quitar la arena | tpr | Aclarar la concha en el agua |
| Rinse well | Aclarar bien | tpr | Pasar las manos bajo el agua |
| Rinse your hands | Enjuagarse las manos | tpr | Enjuagarse las manos bajo el grifo |
| Ripe | Maduro, madura | tpr | Coger con cuidado una fruta madura de la rama |
| Ripe mango | Mango maduro | tpr | Apretar suave el mango |
| Ripest | El más maduro | tpr | Escoger la mejor |
| Ripples | Ondas pequeñas | 0-2, tpr | Mover un dedo en el agua |
| Rise and fall | Subir y bajar | tpr | Subir y bajar como las olas |
| Rise and shine! | ¡Arriba, que sale el sol! | tpr | Estirarse hacia arriba |
| River mouth | Desembocadura | tpr | Abrir las manos al llegar al mar |
| Riverbank | Orilla del río | tpr | Sentarse en la orilla |
| Roar | Rugir | leccions, tpr | Abrir mucho la boca y rugir suave: grrr |
| Roar loudly | Rugir fuerte | tpr | Rugir con las manos abiertas |
| Roasted | Asado | tpr | Señalar la castaña caliente |
| Roasting pan | Sartén de asar | 0-2, leccions, tpr | Enseñar la sartén de lejos |
| Roasting time | Tiempo de asado | tpr | Señalar el reloj |
| Robin | Petirrojo | tpr | Señalar el pecho rojo |
| Robin's nest | Nido de petirrojo | tpr | Hacer un nido con las manos |
| Robotic | Robótico | tpr | Hablar como un robot |
| Rock | Mecer | tpr | Balancearse despacio de un lado a otro |
| Rock and sing | Mecer y cantar | tpr | Mecer al bebé cantando |
| Rock gently | Mecer despacio | tpr | Mecer al bebé muy despacio |
| Rock pool | Charca entre rocas | tpr | Mirar dentro de la charca |
| Rock the boat | Balancear la barca | tpr | Balancearse sentados |
| Rock to and fro | Mecer adelante y atrás | tpr | Mecer al bebé adelante y atrás |
| Rock-a-bye, baby | Arrorró, mi niño | tpr | Mecer y cantar |
| Rocking chair | Mecedora | tpr | Mecerse en la silla con el bebé |
| Rocking horse | Caballito balancín | 0-2, tpr | Mecerse en el caballito balancín |
| Rocky | Rocoso | tpr | Tocar una superficie dura |
| Role | Papel | tpr | Señalar la tarjeta del papel |
| Roll | Rodar | leccions, tpr | Rodar por el suelo como una croqueta |
| Roll along | Rodar a lo largo | tpr | Rodar el cilindro |
| Roll back | Devolver rodando | tpr | Rodar la pelota de vuelta al bebé |
| Roll down | Rodar hacia abajo | tpr | Rodar de lado |
| Roll down the hill like a chestnut | Rueda cuesta abajo como una castaña | leccions | — |
| Roll it to me | Ruédala hacia mí | leccions, tpr | Abrir las manos para recibirla |
| Roll on the floor | Rodar por el suelo | tpr | Rodar de lado en la alfombra |
| Roll over | Darse la vuelta | tpr | Ayudar a girar de espaldas a barriga |
| Roll the dice | Tirar el dado | tpr | Tirar el dado y contar |
| Roll the hoop | Haz rodar el aro | tpr | Hacer rodar un aro imaginario por el suelo |
| Roll the pumpkin on the floor | Haz rodar la calabaza por el suelo | leccions | — |
| Roll up | Enrollar | leccions, tpr | Enrollar la esterilla despacio |
| Roll! / Ball! | Rodar / Pelota | 0-2, leccions | — |
| Roll, roll, yellow circle! | ¡Rueda, rueda, círculo amarillo! | leccions | — |
| Rolling | Rodante | tpr | Rodar las manos una sobre otra |
| Rolling pin | Rodillo | tpr | Rodar el rodillo por la mesa |
| Root | Raíz | tpr | Bajar los dedos como raíces |
| Roots | Raíces | tpr | Extender los dedos hacia abajo |
| Roots under the ground | Raíces bajo tierra | tpr | Bajar los dedos hacia el suelo |
| Rope | Cuerda | tpr | Tirar de una cuerda imaginaria |
| Rope bridge | Puente de cuerdas | tpr | Caminar agarrándose |
| Rope line | Cuerda de cultivo | leccions, tpr | Bajar una cuerda imaginaria |
| Rosy | Sonrosado | tpr | Tocar las mejillas sonrosadas |
| Rotate | Rotar | tpr | Girar las manos despacio |
| Rotate a piece | Girar una pieza | tpr | Girar la mano |
| Rotate arms | Girar los brazos | tpr | Hacer círculos con los brazos |
| Rough | Bravo, brava (mar) | leccions, tpr | Moverse con fuerza como un mar bravo |
| Round | Redondo, redonda | leccions, tpr | Mover la mano haciendo círculos pequeños |
| Round and flat | Redondo y plano | leccions, tpr | Enseñar una bola y una tabla |
| Round and round | Vueltas y más vueltas | tpr | Girar las manos una alrededor de la otra |
| Round and round the garden | Alrededor del jardín | tpr | Dibujar círculos en la palma |
| Round and round the garden, like a teddy bear. | Dando vueltas por el jardín, como un osito. | 0-2-rima | — |
| Round like a ball | Redondo como una bola | tpr | Hacer una bola con las manos |
| Round the chair | Alrededor de la silla | tpr | Caminar alrededor de la silla |
| Roundabout | Rotonda | tpr | Caminar en círculo |
| Route | Ruta | tpr | Seguir una línea con el dedo |
| Routine | Rutina | tpr | Tocar el reloj y hacer lo mismo cada día |
| Row of dolls | Fila de muñecas | tpr | Alinear de pequeña a grande |
| Row the boat | Remar la barca | tpr | Remar adelante y atrás |
| Row your boat through the big waves | Rema en la barca entre las olas grandes | leccions | — |
| Row, row, row your boat | Rema, rema, rema tu barca | tpr | Remar cantando |
| Royal | Real | tpr | Ponerse una corona imaginaria |
| Rub a leaf | Frotar una hoja | tpr | Frotar la cera sobre la hoja |
| Rub gently | Frotar despacio | tpr | Frotar la corteza y escuchar |
| Rub hands | Frotar las manos | tpr | Frotar las manos para calentarlas |
| Rub in | Extender | tpr | Extender la crema en círculos |
| Rub palms | Frotar las palmas | tpr | Frotar palma con palma |
| Rub your hands | Frótate las manos | tpr | Frotarse las manos muy rápido para calentarlas |
| Rub! | frotar | 0-2, leccions, tpr | Frotar las palmas una contra otra |
| Rubber duck | Patito de goma | tpr | Hacer flotar un patito imaginario sobre la palma |
| Rubber gloves | Guantes de goma | tpr | Ponerse guantes imaginarios |
| Rubbery | De goma | tpr | Tocar la bota de goma |
| Rubbish | Desperdicio | tpr | Coger y echar en la bolsa |
| Rug | Alfombra | tpr | Apoyar las dos manos en la alfombra del círculo |
| Rug by the fire | Alfombra junto al fuego | tpr | Sentarse en la alfombra |
| Rule | Norma | tpr | Levantar un dedo como una norma |
| Rumble | Retumbar | tpr | Hacer «brrum» con la voz |
| Rumbly | Retumbante | tpr | Hacer un sonido grave con la boca |
| Rumbly bus | Autobús que retumba | tpr | Hacer «brrrr» con la boca |
| Run like a fox | Correr como un zorro | tpr | Correr ligero y agachado |
| Run through the sprinkler | Correr por el aspersor | tpr | Correr riendo |
| Run to the cone | Corre hasta el cono | tpr | Correr y tocar el cono |
| Run to the den! | ¡Corre a la madriguera! | tpr | Correr al rincón |
| Run, run, run! | ¡Corre, corre, corre! | tpr | Correr en el sitio |
| Running makes it beat fast. | Correr hace que lata rápido. | frases | — |
| Rushing | Rápido y fuerte | leccions, tpr | Mover las manos muy rápido |
| Russet | Rojizo | tpr | Enseñar una hoja rojiza |
| Rustle | Crujir | tpr | Mover las hojas para que suenen |
| Rusty | Oxidado | tpr | Tocar una cadena vieja |
| Safe | Seguro, segura | tpr | Abrazarse a uno mismo y sonreír tranquilos |
| Safe and sound | Sano y salvo | tpr | Abrazar al bebé al volver |
| Sail | Navegar | tpr | Abrir los brazos como una vela y moverse con la brisa |
| Sail across the ocean | Cruzar el océano | tpr | Remar y mirar lejos |
| Sailing along | Navegando | tpr | Balancearse despacio |
| Sailing boat | Velero | leccions, tpr | Hacer una vela con las manos |
| Sailing ship | Galeón | tpr | Balancearse como un barco grande |
| Sailor | Marinero | tpr | Hacer el saludo de marinero |
| Salty | Salado, salada | tpr | Poner cara de sorpresa y beber agua |
| Salty air | Aire del mar | 0-2, tpr | Inspirar por la nariz |
| Salty lips | Labios salados | tpr | Tocar los labios después del mar |
| Salty shell | Concha salada | tpr | Oler la concha |
| Salty wind | Viento salado | tpr | Respirar el aire del mar |
| Same | Igual | tpr | Copiar el gesto de una compañera como en un espejo |
| Samil beach | Playa de Samil | 0-2, tpr | Señalar el mar desde la arena |
| Sand | Arena | leccions, tpr | Pisar despacio como sobre arena caliente |
| Sand in the bucket | Arena en el cubo | tpr | Echar arena en el cubo |
| Sand on my feet | Arena en mis pies | tpr | Echar arena en los pies |
| Sand pie | Flan de arena | tpr | Volcar el molde y levantarlo |
| Sandcastle | Castillo de arena | tpr | Amontonar arena imaginaria y darle palmaditas |
| Sandpit | Arenero | leccions, tpr | Sentarse en el arenero |
| Sandy | Arenoso, arenosa | tpr | Sacudirse las manos como si tuvieran arena |
| Satisfied | Satisfecho | tpr | Sonreír tranquilo |
| Save water | Ahorrar agua | tpr | Cerrar el grifo |
| Savour | Saborear | tpr | Masticar despacio cerrando los ojos |
| Say cheese! | ¡Di patata! | tpr | Sonreír para la foto |
| Say goodbye | Despedirse | tpr | Saludar con la mano en la puerta |
| Say hello | Decir hola | tpr | Saludar a un compañero |
| Say please | Decir por favor | tpr | Juntar las manos pidiendo |
| Say your line | Decir tu frase | tpr | Hablar cuando te señalan |
| Scale pan | Platillo | tpr | Abrir la mano plana |
| Scallop | Vieira | tpr | Abrir y cerrar la concha con las manos |
| Scarecrow | Espantapájaros | tpr | Abrir los brazos como un espantapájaros |
| Scarves | Pañuelos de colores | 0-2, tpr | Lanzar los pañuelos al aire |
| Scene | Escena | tpr | Abrir los brazos como un marco |
| Scientific | Científico | tpr | Ajustar las gafas |
| Scoop | Coger con la cuchara | tpr | Coger yogur con la cuchara |
| Scoop sand | Coger arena | tpr | Coger arena con la mano |
| Scoreboard | Marcador | tpr | Levantar un dedo por cada punto del marcador |
| Scrapbook | Álbum de recortes | tpr | Pegar un recorte |
| Scratch | Rascar | tpr | Rascarse la cabeza con un dedo |
| Scratchy | Rasposo | tpr | Pasar la mano por la corteza rasposa |
| Script | Guion | tpr | Leer un papel imaginario |
| Scrub | Restregar | tpr | Restregar el dorso de las manos con fuerza |
| Scrub nails | Frotar las uñas | tpr | Frotar las puntas de los dedos |
| Scrumptious | Riquísimo | tpr | Tocar la barriga y sonreír |
| Scrunch | Estrujar | tpr | Estrujar un papel con la mano |
| Scuttle | Correr de lado | tpr | Correr de lado como un cangrejo |
| Sea glass | Cristal de mar | leccions, tpr | Mirar un cristal a la luz |
| Sea slug | Babosa de mar | tpr | Arrastrarse despacio |
| Sea urchin | Erizo de mar | tpr | Abrir los dedos como púas |
| Seabed | Fondo del mar | tpr | Bajar las manos hasta el suelo |
| Seabird | Ave marina | leccions, tpr | Planear con los brazos abiertos |
| Seafaring | Marinero | tpr | Hacer el saludo marinero |
| Seagrass | Pradera marina | tpr | Moverse ondulando |
| Seagrass is a home for little fish | La pradera es la casa de los pececitos | tpr | Hacer un tejado con las manos |
| Seagull | Gaviota | tpr | Abrir los brazos y planear despacio |
| Seahorse | Caballito de mar | 0-2, tpr | Hacer una S con el dedo |
| Seals and bears | Focas y osos | tpr | Dar palmas y caminar pesado |
| Search for treasure | Buscar un tesoro | tpr | Mirar alrededor con un catalejo |
| Seaside | Orilla del mar | 0-2, tpr | Acercarse a la orilla con el bebé |
| Season | Estación | tpr | Hacer un círculo con la mano |
| Seasonal | De temporada | tpr | Señalar el calendario |
| Seat belt on! | ¡Cinturón puesto! | tpr | Cruzar un cinturón de seguridad imaginario por el pecho |
| Seat belts on, please | Los cinturones, por favor | tpr | Ponerse el cinturón |
| Seaweed | Algas | 0-2, tpr | Tocar un alga mojada |
| Seaworthy | Listo para el mar | tpr | Levantar el pulgar |
| Secret | Secreto, secreta | leccions, tpr | Llevarse el dedo a los labios y guiñar un ojo |
| See | Ver | leccions, tpr | Hacer prismáticos con las manos y mirar a lo lejos |
| See both sides | Ver las dos partes | tpr | Mirar a un lado y al otro |
| See you after summer | Hasta después del verano | tpr | Mandar un beso y saludar |
| See you in Primary! | ¡Nos vemos en Primaria! | tpr | Saludar a todos |
| See you in September | Nos vemos en septiembre | tpr | Contar con los dedos y decir adiós hasta la vuelta |
| See you next year! | ¡Nos vemos el año que viene! | tpr | Saludar a todos |
| See you soon! | ¡Hasta pronto! | tpr | Decir adiós y luego señalar el calendario |
| See-through | Transparente | tpr | Mirar a través de una burbuja |
| Seed | Semilla | leccions, tpr | Cerrar el puño como una semilla cerrada |
| Seed bag | Bolsa de semillas | tpr | Mirar la semilla dentro de la bolsa |
| Seed in the soil | Semilla en la tierra | tpr | Meter la semilla y taparla |
| Seek | Buscar | tpr | Mirar alrededor buscando |
| Seesaw | Balancín | 0-2, tpr | Subir y bajar con las manos |
| Self-care | Autocuidado | leccions, tpr | Abrazarse a sí mismo |
| Semilla pequeña | Semilla pequeña | 0-2-cancion | — |
| Send a postcard | Enviar una postal | tpr | Meter en un buzón |
| Send me a postcard! | ¡Mándame una postal! | tpr | Hacer que se escribe |
| Sense | Sentido | tpr | Tocar ojos, orejas, nariz, boca y mano |
| Sense of smell | Olfato | tpr | Señalar la nariz |
| Sense of taste | Gusto | tpr | Señalar la lengua |
| Sense of touch | Tacto | tpr | Enseñar las manos abiertas |
| Sensory | Sensorial | tpr | Tocar varias texturas |
| Sensory bag | Bolsa sensorial | 0-2, leccions, tpr | Apretar la bolsa sensorial |
| Sensory ball | Pelota sensorial | tpr | Apretar la pelota con pinchos suaves |
| Separate waste | Separar residuos | tpr | Echar cada cosa en su sitio |
| Sequence | Ordenar | tpr | Poner tarjetas en fila |
| Sequence strip | Tira de secuencia | tpr | Señalar de izquierda a derecha |
| Serve | Servir | tpr | Servir comida imaginaria en los platos del grupo |
| Set a timer | Poner el temporizador | tpr | Pulsar un botón imaginario |
| Set of weights | Juego de pesas | tpr | Poner pesas imaginarias |
| Set sail | Zarpar | tpr | Empujar y salir navegando |
| Setting | Lugar de la historia | tpr | Abrir los brazos como un escenario |
| Settle | Calmarse | tpr | Pasar la mano por la espalda en círculos |
| Shade | Sombra | tpr | Ponerse a la sombra |
| Shade card | Carta de tonos | tpr | Pasar de claro a oscuro |
| Shade your eyes | Taparse del sol | tpr | Poner la mano sobre los ojos |
| Shadow | Sombra | tpr | Moverse imitando la sombra de otra persona |
| Shake | Agitar | leccions, tpr | Agitar todo el cuerpo como una maraca |
| Shake dry | Sacudir para secar | leccions, tpr | Sacudir las manos tres veces |
| Shake hands kindly | Darse la mano con cariño | tpr | Darse la mano sonriendo |
| Shake it all out! | ¡Sacúdelo todo! | tpr | Sacudir el cuerpo |
| Shake off | Sacudir | tpr | Sacudir las manos mojadas |
| Shake on it | Estrecharse la mano | tpr | Estrecharse la mano con el compañero |
| Shake out | Sacudir | tpr | Sacudir todo el cuerpo |
| Shake the bottle | Agita la botella | tpr | Agitar una botella imaginaria con arroz |
| Shake the glitter | Agitar la purpurina | tpr | Agitar la botella de purpurina |
| Shake the tree | Sacudir el árbol | tpr | Sacudir los brazos |
| Shake the tree gently! | ¡Sacude el árbol despacio! | tpr | Sacudir suave |
| Shake your bells loudly | Toca fuerte tus campanas | leccions | — |
| Shake your hands! | ¡Agita las manos! | leccions | — |
| Shake, shake, shake! | ¡Agita, agita, agita! | leccions, tpr | Agitar el sonajero tres veces |
| Shaker | Sonajero | 0-2, leccions, tpr | Agitar el sonajero al ritmo |
| Shaky | Tembloroso, temblorosa | tpr | Temblar las manos como hojas al viento |
| Shallow | Poco profundo, poco profunda | tpr | Tocar el agua imaginaria solo con la punta de los pies |
| Shape | Forma | leccions, tpr | Hacer una forma con el cuerpo y quedarse quietos |
| Shape sorter | Encajable de formas | tpr | Meter la forma en su hueco |
| Shapes in the room | Formas en la sala | tpr | Señalar formas alrededor |
| Share | Compartir | tpr | Partir un objeto imaginario y dar la mitad |
| Share blocks | Compartir bloques | tpr | Dar la mitad de los bloques |
| Share equally | Repartir por igual | tpr | Dar lo mismo a cada uno |
| Share memories | Compartir recuerdos | tpr | Hablar mirando a un amigo |
| Share out | Repartir | tpr | Repartir castañas entre todos |
| Share the fruit | Repartir la fruta | tpr | Dar una fruta a cada uno |
| Share toys | Compartir juguetes | tpr | Dar un juguete |
| Shared blanket | Manta compartida | tpr | Taparse dos con la misma manta |
| Sharing | Que comparte | tpr | Partir la plastilina en dos |
| Sharp-eyed | De vista aguda | tpr | Mirar muy atento |
| She asked where the snake went. | Ella preguntó dónde iba la serpiente. | frases | — |
| She explained that the colours mix. | Ella explicó que los colores se mezclan. | frases | — |
| Shelf | Estante | tpr | Dejar un libro en el estante |
| Shell pieces | Cáscaras | tpr | Juntar las cáscaras en un montón |
| Shells in the bag | Conchas en la bolsa | tpr | Meter las conchas en la bolsa |
| Shelter | Refugio | tpr | Meterse bajo una mesa |
| Shh, a heron! | ¡Shh, una garza! | tpr | Poner el dedo en los labios |
| Shh, baby's sleeping | Shh, el bebé duerme | leccions, tpr | Poner el dedo en los labios |
| Shh, listen! | ¡Chis, escucha! | tpr | Llevarse el dedo a los labios y luego la mano a la oreja |
| Shine | Brillar | tpr | Abrir los brazos de golpe como un sol que sale |
| Shine like the Sun | Brillar como el Sol | tpr | Abrir los brazos de golpe |
| Shiny | Reluciente | tpr | Abrir y cerrar las manos como estrellitas que relucen |
| Shiny paper | Papel brillante | tpr | Hacer sonar el papel brillante |
| Shiver | Temblar | tpr | Temblar todo el cuerpo como si hiciera mucho frío |
| Shoal | Banco de peces | tpr | Moverse todos juntos |
| Shop | Tienda | tpr | Hacer que se abre la puerta de la tienda |
| Shop window | Escaparate | tpr | Mirar a través de un cristal |
| Shopkeeper | Tendero | tpr | Atender detrás de un mostrador |
| Shopping list | Lista de la compra | leccions, tpr | Leer una lista imaginaria |
| Short | Bajo, baja | tpr | Agacharse y hacerse bajito |
| Shorter | Más corto | tpr | Juntar las manos |
| Shortest day | El día más corto | tpr | Juntar las manos |
| Shoulder blade | Omóplato | tpr | Pasar la mano por el hombro |
| Shoulders | Hombros | tpr | Tocar los hombros |
| Shout for joy | Gritar de alegría | tpr | Levantar los brazos y gritar |
| Shout hooray | Gritar hurra | tpr | Levantar los brazos y gritar |
| Show | Enseñar | tpr | Enseñar un dibujo imaginario al grupo |
| Show big arms | Mostrar brazos grandes | tpr | Abrir los brazos mucho |
| Show me the heavy side | Enséñame el lado pesado | tpr | Bajar un brazo |
| Show me the star! | ¡Enséñame la estrella! | frases | — |
| Show me your teeth | Enséñame los dientes | tpr | Sonreír mucho |
| Show off | Presumir | tpr | Girar y enseñar el disfraz |
| Show small fingers | Mostrar dedos pequeños | tpr | Juntar dos dedos |
| Show you care | Mostrar que te importa | tpr | Abrazar suave |
| Showery | De chubascos | leccions, tpr | Mover los dedos como lluvia |
| Shrink | Encoger | tpr | Hacerse pequeño en el suelo |
| Shuffle | Arrastrar los pies | leccions, tpr | Arrastrar los pies bailando |
| Shut the drawer | Cerrar el cajón | tpr | Empujar el cajón |
| Shy | Tímido, tímida | tpr | Taparse la cara con las manos y asomar un ojo |
| Side to side | De un lado a otro | tpr | Balancear al bebé de un lado a otro |
| Sieve | Colador | tpr | Dejar escurrir agua por el colador |
| Sieve toy | Tamiz de juguete | tpr | Tamizar arena |
| Sift | Tamizar | tpr | Mover el tamiz |
| Sight | Vista | tpr | Señalar los ojos |
| Sign | Firmar | tpr | Escribir el nombre en el aire |
| Signal | Señal | tpr | Levantar la mano como una señal |
| Signature | Firma | tpr | Firmar en el aire |
| Silent | En silencio | tpr | Taparse la boca con las manos |
| Silent room | Sala en silencio | tpr | Poner el dedo en los labios |
| Silk scarf | Pañuelo de seda | tpr | Dejar caer el pañuelo sobre la mano |
| Silky | Sedoso | tpr | Pasar un pañuelo de seda por la mano |
| Silly face | Cara graciosa | tpr | Poner una cara graciosa |
| Silly story | Historia disparatada | tpr | Reír y encoger los hombros |
| Silver | Plateado, plateada | tpr | Señalar algo plateado que reluzca |
| Silvery | Plateado | tpr | Enseñar un papel plateado |
| Simon says touch your nose | Simón dice: tócate la nariz | tpr | Tocar la nariz solo si lo dice Simón |
| Sing in tune | Cantar afinado | tpr | Cantar mirando al director |
| Sing louder | Cantar más fuerte | tpr | Abrir más la boca |
| Sing softer | Cantar más suave | tpr | Bajar la voz |
| Sink | Lavabo | tpr | Inclinarse sobre un lavabo imaginario |
| Sink down | Hundirse | tpr | Bajar despacio hasta el suelo |
| Sink plug | Tapón del lavabo | tpr | Poner y quitar el tapón |
| Sip | Beber a sorbos | tpr | Dar un sorbo pequeño del vaso |
| Sip slowly | Beber despacio | leccions, tpr | Beber a sorbos pequeños |
| Sippy cup | Vaso de aprendizaje | tpr | Acercar el vaso a los labios |
| Sister | Hermana | tpr | Señalar a la hermana y sonreír |
| Sit | Sentarse | leccions, tpr | Bajar despacio hasta sentarse en el suelo |
| Sit around | Sentarse alrededor | tpr | Sentarse todos alrededor de la manta |
| Sit on the green mat and freeze! | Siéntate en la colchoneta verde y ¡estatua! | leccions | — |
| Sit up | Incorporarse | tpr | Ayudar al bebé a sentarse |
| Sit with me | Siéntate conmigo | tpr | Dar palmaditas en el suelo al lado |
| Six-sided | De seis lados | tpr | Enseñar seis dedos |
| Size | Tamaño | tpr | Abrir las manos a distinto tamaño |
| Skeleton | Esqueleto | tpr | Moverse como un esqueleto de cuento |
| Skin | Piel | tpr | Acariciar la piel del brazo |
| Skip | Saltar a la comba | tpr | Saltar la comba imaginaria |
| Skipping rope | Comba larga | tpr | Saltar con los pies juntos |
| Sky | Cielo | tpr | Señalar el cielo y mirar hacia arriba |
| Sky blue | Azul cielo | tpr | Señalar el cielo azul |
| Sleek | Liso y rápido | tpr | Pasar la mano plana |
| Sleep in the flower until the sun wakes up | Duerme en la flor hasta que despierte el sol | leccions | — |
| Sleep like the Moon | Dormir como la Luna | tpr | Apoyar la cabeza y cerrar los ojos |
| Sleep tight | Que duermas bien | tpr | Abrazarse fuerte y quedarse quietos |
| Sleeping animal | Animal dormido | tpr | Apoyar la cabeza en las manos |
| Sleepy-eyed | Con ojitos de sueño | tpr | Cerrar los ojos despacio |
| Sleepyhead | Dormilón | tpr | Cerrar los ojos y roncar suave |
| Sleeve | Manga | tpr | Meter el brazo por la manga |
| Slice | Cortar en rodajas | tpr | Hacer cortes con la mano |
| Slide like a penguin | Deslízate como un pingüino | tpr | Deslizarse con los brazos pegados |
| Slide on ice | Deslizarse en el hielo | tpr | Deslizarse con los calcetines |
| Slimy | Viscoso, viscosa | tpr | Tocar algo imaginario y sacudir la mano |
| Slippers | Zapatillas | 0-2, tpr | Poner las zapatillas al bebé |
| Slippery | Resbaladizo, resbaladiza | tpr | Mover los pies como si resbalaran, sin caerse |
| Slippery fish | Pez resbaladizo | tpr | Resbalar las manos una sobre otra |
| Slippery soap | Jabón resbaladizo | tpr | Dejar resbalar el jabón |
| Slither | Reptar | leccions, tpr | Arrastrarse por el suelo como una serpiente |
| Slope | Cuesta | tpr | Inclinar la mano como una cuesta |
| Slot in | Meter en el hueco | tpr | Meter la pieza en el hueco |
| Slow | Lento, lenta | leccions, tpr | Mover las manos muy despacio |
| Slow down | Ir más despacio | tpr | Mover los brazos cada vez más despacio |
| Slow down your breathing | Respirar más despacio | tpr | Inspirar y espirar muy despacio |
| Slow like a snail | Lento como un caracol | tpr | Avanzar muy, muy despacio por el suelo |
| Slower | Más despacio | leccions, tpr | Golpear más despacio |
| Slowly, slowly | Despacito, despacito | tpr | Hacer cualquier movimiento muy, muy despacio |
| Sluggish | Lentísimo | tpr | Mover la mano muy despacio |
| Slurp | Sorber | tpr | Hacer que el peluche bebe del cuenco |
| Slurp up | Sorber | tpr | Sorber zumo con una pajita |
| Sly | Astuto | leccions, tpr | Poner cara de pillo |
| Smack lips | Relamerse | tpr | Relamerse contentos |
| Small and quick | Pequeño y rápido | tpr | Mover los dedos rápido |
| Small! | pequeño | 0-2, leccions, tpr | Encogerse como una hormiguita |
| Smaller | Más pequeño | tpr | Juntar más las manos |
| Smallest | El más pequeño | tpr | Juntar las manos hasta tocarse |
| Smell | Oler | tpr | Oler una flor imaginaria cerca de la nariz |
| Smell it | Oler | tpr | Acercar la fruta a la nariz |
| Smile at me | Sonríeme | tpr | Acercar la cara y sonreír |
| Smile of thanks | Sonrisa de agradecimiento | tpr | Sonreír a alguien |
| Smiley face | Cara sonriente | tpr | Dibujar una sonrisa en el aire |
| Smoke | Humo | 0-2, leccions, tpr | Subir las manos como el humo |
| Smoky | Ahumado | tpr | Abanicar con la mano como el humo |
| Smooth | Liso, lisa | leccions, tpr | Pasar la mano muy suave por una manzana imaginaria |
| Smooth pebble | Piedra lisa | tpr | Acariciar una piedra lisa |
| Smooth sand | Arena lisa | tpr | Alisar la arena con la mano |
| Smooth skin | Piel suave | tpr | Acariciar la mejilla con el dorso de la mano |
| Smoothie | Batido | tpr | Soplar por la pajita |
| Snack | Merienda | tpr | Llevarse a la boca un trozo de fruta imaginaria |
| Snap | Cerrar de golpe | tpr | Juntar las palmas de golpe como una boca que se cierra |
| Sneak | Andar a hurtadillas | leccions, tpr | Caminar en silencio agachado |
| Sneak quietly like a fox in the woods | Ve sigiloso como un zorro en el bosque | leccions | — |
| Sniff | Olfatear | leccions, tpr | Olfatear el aire como un zorro |
| Sniff out | Descubrir por el olor | tpr | Oler y señalar |
| Sniff the fruit | Oler la fruta | tpr | Acercar la fruta a la nariz |
| Snore | Roncar | tpr | Hacer «rrr» muy suave con los ojos cerrados |
| Snorkel | Tubo de buceo | tpr | Ponerse un tubo imaginario |
| Snow globe | Bola de nieve | tpr | Agitar la bola de nieve |
| Snowsuit | Buzo de nieve | 0-2, tpr | Meter las piernas en el buzo |
| Snowy outside | Nevado fuera | tpr | Señalar la ventana |
| Snowy white | Blanco como la nieve | tpr | Señalar algo blanco |
| Snug | Arropadito | tpr | Arropar al bebé con la manta |
| Snug in the towel | Arropado en la toalla | tpr | Envolver y abrazar |
| Snuggle | Acurrucarse | tpr | Acurrucar al bebé contra el pecho |
| Snuggly | Mimoso | tpr | Acurrucar al bebé con la mejilla |
| Snuggly jumper | Jersey calentito | tpr | Abrazarse con el jersey |
| So big! | ¡Muy grande! | tpr | Levantar los brazos bien alto |
| So many bubbles! | ¡Cuántas burbujas! | tpr | Abrir los brazos sorprendidos |
| Soak | Remojar | leccions, tpr | Meter la ropa en el agua |
| Soap bar | Pastilla de jabón | tpr | Coger el jabón que resbala |
| Soap pump | Dosificador de jabón | tpr | Apretar el dosificador |
| Soap, rub, rinse | Jabón, frotar, aclarar | leccions, tpr | Hacer los tres gestos |
| Soapy | Enjabonado, enjabonada | tpr | Mover las manos como si resbalaran de jabón |
| Soar | Planear alto | tpr | Abrir los brazos y girar despacio |
| Soaring | Planeando | tpr | Volar despacio |
| Social | Sociable | tpr | Saludar a todos |
| Sock puppet | Títere de calcetín | tpr | Abrir y cerrar la mano como una boca |
| Socks on the line | Calcetines en la cuerda | tpr | Colgar dos calcetines |
| Soft and dry | Suave y seco | tpr | Acariciar la piel seca |
| Soft and slow | Suave y despacio | tpr | Mover las manos muy despacio |
| Soft and sweet | Blando y dulce | tpr | Chafar un trozo de pera |
| Soft like a cat | Suave como un gato | tpr | Acariciar la propia mejilla |
| Soft or rough? | ¿Suave o áspero? | tpr | Tocar una cosa suave y otra áspera |
| Soft toy | Peluche | tpr | Dar el peluche al bebé |
| Soft voice | Voz suave | tpr | Hablar muy suave |
| Soft! | suave, blando | 0-2, leccions, tpr | Acariciarse el brazo muy despacio |
| Soft-furred | De pelo suave | tpr | Pasar la mano por el pelo del peluche |
| Softer, please | Más suave, por favor | tpr | Bajar las manos |
| Soggy | Empapado | tpr | Escurrir un guante mojado |
| Soil | Tierra | leccions, tpr | Tocar el suelo y frotar las manos como con tierra |
| Solar panel | Placa solar | tpr | Poner las manos planas al sol |
| Solar system | Sistema solar | tpr | Girar todos alrededor del centro |
| Sole | Planta del pie | tpr | Tocar la planta del pie |
| Solid | Macizo | leccions, tpr | Golpear el cubo |
| Solo | Solo | tpr | Dar un paso adelante y cantar |
| Solstice | Solsticio | tpr | Estirar los brazos al máximo |
| Solution | Solución | tpr | Chasquear los dedos |
| Solve | Resolver | tpr | Juntar dos piezas |
| Solved | Resuelto | tpr | Dar palmas |
| Some soap. | Un poco de jabón. | frases | — |
| Some water. | Un poco de agua. | frases | — |
| Song | Canción | tpr | Mover las manos como si dirigiera una canción |
| Songbird | Pájaro cantor | tpr | Silbar como un pájaro |
| Soothing | Relajante | tpr | Acariciar la espalda en círculos |
| Sort | Clasificar | tpr | Juntar los objetos del mismo color |
| Sort by number | Ordenar por número | tpr | Poner en fila de menos a más |
| Sorted | Clasificado | tpr | Juntar ceras del mismo color |
| Sound asleep | Profundamente dormido | tpr | Apoyar la cabeza en las manos juntas |
| Sour | Ácido, ácida | tpr | Poner cara de limón, cerrando los ojos y arrugando la boca |
| Sourer | Más ácido | tpr | Arrugar más la cara |
| Sow | Sembrar | tpr | Echar semillas imaginarias al suelo |
| Space | Espacio | tpr | Flotar con los brazos abiertos |
| Spade | Pala | tpr | Cavar con una pala imaginaria y echar la arena a un lado |
| Sparkling costume | Disfraz brillante | tpr | Girar enseñando el disfraz |
| Sparkling sea | Mar brillante | tpr | Abrir y cerrar los dedos como el sol en el mar |
| Sparkly | Brillante | tpr | Enseñar un papel brillante |
| Sparkly teeth | Dientes brillantes | tpr | Sonreír con todos los dientes |
| Sparkly water | Agua brillante | tpr | Mover el agua al sol |
| Sparrow | Gorrión | tpr | Saltar con los dedos como un gorrión |
| Speak softly | Hablar suave | leccions, tpr | Decir una palabra muy bajo |
| Speaking turn | Turno de palabra | tpr | Pasar el micrófono imaginario |
| Special | Especial | tpr | Señalar a cada criatura con una sonrisa |
| Speckled | Moteado | tpr | Tocar los puntos de un huevo de juguete |
| Speech | Discurso | tpr | Hablar delante de todos |
| Speed bump | Resalto | tpr | Saltar un poco en el sitio |
| Speed up | Acelerar | leccions, tpr | Mover los brazos cada vez más rápido |
| Speed up and slow down | Acelerar y frenar | tpr | Golpear más rápido y más despacio |
| Speedy | Veloz | tpr | Mover los pies muy rápido |
| Sphere | Esfera | tpr | Rodar una bola imaginaria |
| Spice | Especia | tpr | Espolvorear algo con los dedos |
| Spicy | Picante | tpr | Abanicarse la boca |
| Spider crab | Centolla | tpr | Caminar de lado con patas largas |
| Spiky | Pinchudo, pinchuda | tpr | Tocar con un dedo muy despacio algo que pincha y retirar la mano |
| Spiky pineapple | Piña con pinchos | tpr | Tocar con cuidado las hojas |
| Spin | Hacer girar | tpr | Hacer girar un aro imaginario en la cintura |
| Spin around | Darse la vuelta | leccions, tpr | Girar sobre un pie |
| Spin around and fall down like a leaf | Da vueltas y cae como una hoja | leccions | — |
| Spin like a top | Gira como una peonza | tpr | Girar con los brazos pegados |
| Spin like the Earth | Girar como la Tierra | tpr | Girar despacio sobre sí mismo |
| Spine | Columna | tpr | Pasar la mano por la espalda |
| Spinning | Giratorio | tpr | Hacer girar una pelota |
| Spinning Earth | Tierra que gira | tpr | Girar despacio |
| Spinning top | Peonza | tpr | Hacer girar una peonza |
| Spiny | Con púas | tpr | Tocar con cuidado |
| Spiral | Espiral | tpr | Dibujar una espiral con el dedo |
| Spiralling | En espiral | tpr | Girar el dedo |
| Spit in the sink | Escupe en el lavabo | tpr | Escupir en el lavabo |
| Spit out | Escupir | tpr | Escupir en el lavabo |
| Splash about | Chapotear | tpr | Golpear el agua con las palmas |
| Splash around | Salpicar alrededor | tpr | Pisar fuerte en el charco |
| Splash down | Caer salpicando | tpr | Bajar las manos y abrirlas |
| Splash zone | Zona de salpicar | tpr | Señalar la zona de los charcos |
| Splash, splash! | ¡Chof, chof! | tpr | Saltar dos veces en el charco |
| splashy | que salpica | leccions, tpr | Salpicar un poco de agua |
| Splish, splash! | ¡Chis, chas! | 0-2, leccions, tpr | Golpear el agua dos veces |
| Split in half | Partir por la mitad | tpr | Separar las manos |
| Split open | Abierto | tpr | Abrir las manos |
| Sponge ball | Pelota de esponja | tpr | Apretar la pelota de esponja |
| Sporty | Deportista | tpr | Hacer un saludo deportivo |
| Spot | Descubrir | tpr | Señalar de repente |
| Spot the mistake | Encontrar el error | tpr | Señalar y decir «aquí» |
| Spotless | Impecable | tpr | Enseñar las manos limpias |
| Spotlight | Foco | tpr | Hacer un círculo de luz con las manos |
| Spotted | De lunares | tpr | Tocar los lunares de un pañuelo |
| Spotty | De lunares | tpr | Tocar puntos por todo el cuerpo con un dedo |
| Spout | Echar agua | tpr | Abrir las manos hacia arriba |
| Spread | Untar | tpr | Untar una rebanada imaginaria con un dedo |
| Spread out | Extender | leccions, tpr | Extender la manta con todos |
| Spring | Primavera | tpr | Respirar hondo y sonreír con el sol en la cara |
| Spring-like | Primaveral | tpr | Dar pasitos alegres |
| Springy legs | Piernas de muelle | tpr | Botar como un muelle |
| Sprinkle | Regar | tpr | Regar una planta imaginaria con los dedos |
| Sprinkle spice | Espolvorear | tpr | Mover los dedos por encima del plato |
| Sprinkler | Aspersor | tpr | Girar echando agua |
| Sprint fast | Esprintar | tpr | Correr muy rápido en el sitio |
| Sprouting | Brotando | tpr | Abrir un dedo y luego otro |
| Squash | Aplastar | tpr | Aplastar uvas imaginarias con los pies en el sitio |
| Squat | Ponerse en cuclillas | tpr | Bajar en cuclillas |
| Squawk | Graznar | tpr | Hacer «cuac» fuerte |
| Squawk like a seagull! | ¡Grazna como una gaviota! | tpr | Hacer «cuac» |
| Squeaky clean | Limpísimo | tpr | Frotar la mano hasta que «chirría» |
| Squeaky voice | Voz aguda | tpr | Hablar muy agudo |
| Squeeze | Exprimir | tpr | Apretar una naranja imaginaria con las dos manos |
| Squeeze and let go | Aprieta y suelta | tpr | Apretar y abrir la mano |
| Squeeze tight | Apretar fuerte | tpr | Dar un abrazo fuerte y soltar |
| Squeezy | Estrujable | tpr | Apretar la pelota blanda |
| Squelchy | Chapoteante | tpr | Pisar y hacer «chof» |
| Squirt | Echar un chorro | leccions, tpr | Apretar y echar un chorro |
| Squishy | Blandito | tpr | Apretar algo blando y soltarlo |
| Stack | Apilar | tpr | Poner un vaso encima de otro |
| Stack up | Amontonar | tpr | Amontonar bloques bien alto |
| Stackable | Apilable | tpr | Apilar dos piezas |
| Stacking cups | Vasos apilables | 0-2, tpr | Apilar los vasos de colores |
| Stag beetle | Ciervo volante | tpr | Poner los dedos como cuernos |
| Stage | Escenario | leccions, tpr | Subir a un escenario imaginario |
| Stage directions | Indicaciones de escena | tpr | Señalar izquierda y derecha |
| Staircase | Escalera | tpr | Subir la mano escalón a escalón |
| Stairs | Escaleras | tpr | Subir escalones imaginarios levantando las rodillas |
| Stamp | Pisotear | tpr | Mover los pies del bebé como pisando |
| Stamp feet | Patalear | tpr | Patalear en el suelo |
| Stand like a heron | Quedarse como una garza | tpr | Sostenerse en un pie |
| Stand like a tree | Ponte como un árbol | tpr | Hacer la postura del árbol |
| Stand on one leg | Sostenerse en un pie | tpr | Levantar un pie y contar |
| Stand tall | Estar erguido | tpr | Estirarse recto |
| Stand tall and proud | Ponerse erguido y orgulloso | tpr | Estirarse recto |
| Stand up and clap your hands | Ponte de pie y da palmas | leccions | — |
| Star shape | Forma de estrella | tpr | Abrir brazos y piernas como una estrella |
| Starfish | Estrella de mar | tpr | Pegar la mano abierta al suelo como una estrella de mar |
| Stargaze | Mirar las estrellas | leccions, tpr | Tumbarse y mirar arriba |
| Starlight | Luz de estrella | tpr | Abrir y cerrar las manos como estrellas |
| Starry | Estrellado | tpr | Abrir y cerrar los dedos |
| Starry night | Noche estrellada | tpr | Mirar arriba abriendo los dedos |
| Stars are further away than the Moon | Las estrellas están más lejos que la Luna | tpr | Señalar cerca y lejos |
| Statue | Estatua | leccions, tpr | Quedarse quieto como una estatua |
| Stay in | Quedarse en casa | tpr | Señalar la casa y sentarse |
| steady | firme | leccions, tpr | Sujetar al bebé bien firme |
| Steady beat | Pulso constante | tpr | Golpear igual todo el tiempo |
| Steam | Vapor | tpr | Subir los dedos como vapor |
| Steaming | Humeante | tpr | Señalar el vapor que sube |
| Steamy | Con vapor | tpr | Soplar el vapor de la taza |
| Steer | Girar el volante | tpr | Girar el volante a derecha e izquierda |
| Steer the boat | Guiar el barco | tpr | Girar un timón imaginario |
| Stem | Tallo | tpr | Estirar el brazo muy recto como un tallo |
| Step across | Pasar por encima | leccions, tpr | Dar un paso largo |
| Step back | Dar un paso atrás | tpr | Dar un paso hacia atrás |
| Step between | Pisar entre | tpr | Pisar entre dos aros |
| Step between the hoops | Pisa entre los aros | tpr | Pisar entre los aros |
| Step forward | Dar un paso adelante | leccions, tpr | Dar un paso hacia adelante |
| Step slowly and don't spill the water into the river | Pisa despacio y no derrames el agua en el río | leccions | — |
| Step stool | Taburete | tpr | Subir al taburete del lavabo |
| Stepping stones | Piedras de paso | tpr | Saltar de piedra en piedra |
| Steps | Escalones | leccions, tpr | Subir escalones en el sitio |
| Stick | Pegar | tpr | Pegar un papel imaginario en la pared dándole palmaditas |
| Stick in photos | Pegar fotos | tpr | Pegar en el aire |
| Stick out your tongue | Sacar la lengua | tpr | Sacar la lengua y esperar la copia |
| Sticker | Pegatina | tpr | Pegar una pegatina imaginaria en el dorso de la mano |
| Sticker chart | Tabla de pegatinas | tpr | Pegar una pegatina en la tabla |
| sticky | pegajoso | leccions, tpr | Separar las manos como si estuvieran pegadas |
| Sticky fingers | Dedos pegajosos | tpr | Abrir y cerrar los dedos pegajosos |
| Stiff | Tieso, tiesa | tpr | Moverse tieso como un robot |
| Still | Quieto | tpr | Quedarse quieto como una piedra |
| Stir | Remover | leccions, tpr | Remover el caldo con una cuchara grande imaginaria |
| Stir, then taste | Remover y luego probar | tpr | Remover con el brazo y luego probar de la cuchara |
| Stocking | Calcetín de Navidad | 0-2, leccions, tpr | Meter la mano en el calcetín |
| Stomp | Pisotear | leccions, tpr | Pisar fuerte con los dos pies en el sitio |
| Stomp around | Pisar fuerte alrededor | leccions, tpr | Pisar fuerte dando una vuelta |
| Stomp in the snow | Pisa fuerte en la nieve | leccions | — |
| Stomp like a bear | Pisa fuerte como un oso | tpr | Pisar fuerte y despacio como un oso |
| Stomp your boots | Pisa fuerte con las botas | tpr | Pisar fuerte con las botas imaginarias: pum, pum |
| Stomp your boots in the puddles! | ¡Pisa fuerte con las botas en los charcos! | leccions | — |
| Stomp, stomp, stomp! | ¡Pum, pum, pum! | tpr | Pisar fuerte tres veces |
| Stomping | Pisando fuerte | tpr | Pisar fuerte al ritmo |
| Stone statue | Estatua de piedra | tpr | Quedarse quieto como una estatua |
| Stone to stone | De piedra en piedra | tpr | Saltar de una a otra |
| Stone wall | Muro de piedra | tpr | Poner las manos como un muro |
| Stony | De piedra | tpr | Golpear una piedra |
| Stop and go | Parar y seguir | tpr | Caminar, parar a la señal y volver a caminar |
| Stop right there! | ¡Para ahí! | tpr | Parar y quedarse quieto |
| Stop spinning! | ¡Deja de girar! | tpr | Parar de golpe |
| Stop! | parar | 0-2, leccions, tpr | Parar de golpe con las manos delante |
| Stop, look and listen | Para, mira y escucha | tpr | Parar, mirar a ambos lados y llevarse la mano a la oreja |
| Store | Almacenar | tpr | Guardar la caja |
| Storm! Shake the sea with all your strength | ¡Tormenta! Agita el mar con toda tu fuerza | leccions | — |
| stormy | de tormenta | leccions, tpr | Mover las manos con fuerza |
| Story | Cuento | leccions, tpr | Abrir un libro imaginario y mirar al grupo |
| Storyboard | Guion gráfico | tpr | Dibujar tres cuadros en el aire |
| Straight | Recto, recta | tpr | Ponerse muy rectos con los brazos pegados al cuerpo |
| Straight on, then right | Recto y luego a la derecha | tpr | Caminar recto y girar |
| Strain | Colar | tpr | Pasar agua por el colador |
| Straw | Paja | tpr | Tejer paja con los dedos |
| Straw hat | Sombrero de paja | tpr | Poner el sombrero de paja |
| Straw house | Casa de paja | tpr | Hacer una casa que se cae |
| Stream | Arroyo | tpr | Mover la mano en olas pequeñas |
| Streamer | Serpentina | 0-2, tpr | Lanzar una serpentina al aire |
| Street | Calle | tpr | Caminar en fila como por la calle |
| Street lamp | Farol de la calle | tpr | Estirarse como un farol |
| Street sign | Placa de la calle | tpr | Leer una placa imaginaria |
| Stretch | Estirar | leccions, tpr | Estirar todo el cuerpo hacia el techo |
| Stretch as high as you can | Estírate tan alto como puedas | tpr | Estirarse al máximo |
| Stretch out your arms | Estirar los brazos | tpr | Estirar los brazos en cruz |
| Stretch time | Vuelta a la calma | tpr | Estirar despacio |
| Stretchy | Elástico | tpr | Estirar mucho los brazos |
| Strings | Hilos | tpr | Mover los dedos como hilos |
| Striped | De rayas | tpr | Dibujar rayas en el aire con un dedo |
| Stripes | Rayas | tpr | Dibujar rayas en el aire |
| Stripy | Rayado | tpr | Tocar un pañuelo de rayas |
| Stroke | Acariciar | tpr | Acariciar el pelo del bebé |
| Stroke gently | Acariciar suave | 0-2, leccions, tpr | Acariciar el peluche en una sola dirección |
| Stroll | Pasear | leccions, tpr | Caminar despacio de la mano |
| Strong | Fuerte | tpr | Doblar los brazos mostrando fuerza |
| Strong legs | Piernas fuertes | tpr | Empujar las manos con el pie |
| Strongest house | La casa más fuerte | tpr | Poner los brazos firmes |
| Strum | Rasguear | tpr | Pasar los dedos por las cuerdas de una guitarra imaginaria |
| Stuck | Atascado | tpr | Parar y encoger los hombros |
| Sturdy | Resistente | leccions, tpr | Empujar la torre sin que caiga |
| Suck | Chupar | tpr | Chupar un trozo de naranja |
| Sudden | Repentino | tpr | Parar de golpe |
| Sugary | Azucarado | tpr | Tocar los labios con un dedo |
| Suggest | Sugerir | tpr | Abrir la mano hacia delante |
| Summer | Verano | leccions, tpr | Abanicarse con un abanico imaginario |
| Summer hat | Sombrero de verano | leccions, tpr | Ponerse el sombrero y sonreír |
| Summer holidays | Vacaciones de verano | leccions, tpr | Abanicarse contentos |
| Summer reading | Lectura de verano | tpr | Abrir un libro a la sombra |
| Summertime | Veraniego | tpr | Abanicarse contentos |
| Summery | Veraniego | tpr | Abanicarse sonriendo |
| Sun and rain together | Sol y lluvia a la vez | tpr | Abrir una mano y mover la otra |
| Sun hat | Sombrero | tpr | Ponerse un sombrero grande imaginario |
| Sun-dried | Secado al sol | tpr | Oler la ropa seca |
| Sun-kissed | Besado por el sol | tpr | Tocar las mejillas |
| Sun-soaked | Lleno de sol | tpr | Abrir los brazos al sol |
| Sunbathe | Tomar el sol | tpr | Tumbarse boca arriba con los ojos cerrados |
| Sunbeam | Rayo de sol | 0-2, tpr | Posar la mano en el rayo de sol |
| Suncream bottle | Bote de crema solar | leccions, tpr | Extender crema |
| Sunlight | Luz del sol | tpr | Abrir las manos como rayos |
| Sunlight! Stand up and stretch tall | ¡Luz del sol! Ponte de pie y estírate bien alto | leccions | — |
| Sunshade | Parasol del cochecito | 0-2, leccions, tpr | Poner el parasol en el cochecito |
| Sunshine | Luz del sol | tpr | Poner las manos en las mejillas como si calentaran |
| Supportive | Que apoya | tpr | Poner la mano en el hombro |
| Suppose you saw a light: what would you say? | Imagina que ves una luz: ¿qué dirías? | frases | — |
| Surface | Salir a la superficie | tpr | Subir y coger aire |
| Surprise ending | Final sorprendente | tpr | Abrir la boca |
| Surprising | Sorprendente | tpr | Abrir mucho los ojos |
| Sustainable | Sostenible | tpr | Poner las manos en equilibrio |
| Swallow | Golondrina | tpr | Volar con los brazos en V |
| Swap | Intercambio | tpr | Cambiar un objeto con un amigo |
| Swap roles | Cambiar los papeles | tpr | Cambiar de sitio con un amigo |
| Swap toys | Intercambiar juguetes | tpr | Cambiar un juguete |
| Sway | Balancearse | tpr | Balancear al bebé al son de la música |
| Sway hips | Mover las caderas | leccions, tpr | Mover las caderas al ritmo |
| Sway like an oak | Mecerse como un roble | tpr | Mecer los brazos despacio |
| Sway with the current | Moverse con la corriente | tpr | Balancearse despacio |
| Swaying | Balanceante | tpr | Mover el cuerpo de un lado a otro |
| Sweep | Barrer | tpr | Barrer hojas con una escoba imaginaria |
| Sweet dreams | Dulces sueños | tpr | Lanzar un beso al aire con los ojos cerrados |
| Sweet-smelling | Oloroso | tpr | Oler y suspirar |
| Sweet-smelling baby | Bebé oloroso | tpr | Oler la cabeza del bebé |
| Sweeter | Más dulce | leccions, tpr | Sonreír más |
| Swim along | Nadar juntos | tpr | Mover las dos manos como peces |
| Swim in a group | Nadar en grupo | tpr | Moverse juntos como peces |
| Swim in a pod | Nadar en grupo | tpr | Moverse todos juntos |
| Swim like a dolphin | Nadar como un delfín | tpr | Saltar con las manos juntas |
| Swim like a fast fish in the ría | Nada como un pez rápido en la ría | leccions | — |
| Swim like a fish | Nada como un pez | tpr | Nadar con las manos juntas delante del cuerpo |
| Swim underwater | Nadar bajo el agua | tpr | Aguantar el aire y nadar |
| Swim, little fish | Nada, pececito | leccions, tpr | Mover la mano como un pez |
| Swing | Columpiarse | tpr | Balancear los brazos como colgados de una rama |
| Swing from a vine | Colgarse de una liana | tpr | Balancear los brazos como un mono |
| Swing seat | Columpio de bebé | tpr | Empujar el columpio despacio |
| Swirl | Arremolinar | tpr | Hacer remolinos con los brazos |
| Swirly | En remolino | tpr | Hacer un remolino con el dedo |
| Swish | Enjuagar | tpr | Mover el agua en la boca |
| Swishing | Ondulante | tpr | Mover la cadera como una cola |
| Switch | Cambiar de golpe | tpr | Cambiar de dirección |
| Switch off | Apagar | tpr | Apagar la luz y decir «ooh» |
| Switch off lights | Apagar las luces | tpr | Pulsar el interruptor |
| Switch on | Encender | tpr | Pulsar el interruptor y ver la luz |
| Swivel chair | Silla giratoria | tpr | Girar despacio en la silla |
| Swoop | Bajar en picado | tpr | Bajar los brazos volando |
| Symbol | Símbolo | tpr | Dibujar un círculo y señalarlo |
| Symmetrical | Simétrico | tpr | Abrir los brazos iguales |
| Symmetry | Simetría | leccions, tpr | Mover las dos manos igual |
| Table | Mesa | tpr | Apoyar las palmas de las manos encima de la mesa |
| Tag | Pillar | tpr | Tocar el hombro de un amigo |
| Tag game | Juego de pillar | tpr | Tocar un hombro y huir |
| Tail | Cola | tpr | Mover una cola imaginaria con las manos detrás |
| Tail fin | Aleta caudal | tpr | Mover los pies juntos |
| Tail-wagging | Que mueve el rabo | tpr | Mover la mano como un rabo |
| Tails and wings | Colas y alas | tpr | Menear la cola y batir las alas |
| Take a bow | Hacer una reverencia | tpr | Inclinarse delante del público |
| Take a break | Hacer una pausa | tpr | Parar y respirar |
| Take a mask | Coger la máscara | tpr | Coger y ponerse la máscara |
| Take a rough leaf and put it in the brown ring | Coge una hoja áspera y ponla en el aro marrón | leccions | — |
| Take a turn | Tomar el turno | tpr | Coger el palo de la palabra |
| Take away | Restar | tpr | Quitar un dedo |
| Take cover | Resguardarse | tpr | Taparse la cabeza con las manos |
| Take down | Descolgar | tpr | Quitar la ropa de la cuerda |
| Take it off! | ¡Quítatelo! | leccions | — |
| Take off | Quitarse | tpr | Quitarse una prenda imaginaria y sacudirla |
| Take off your mask | Quítate la máscara | tpr | Quitarse la máscara imaginaria y sonreír |
| Take one away | Quitar uno | tpr | Retirar un bloque |
| Take only photos | Llévate solo fotos | tpr | Hacer una foto |
| Take photos | Hacer fotos | tpr | Pulsar un botón imaginario |
| Take the smock, turn around and give it to Noa | Coge el babi, date la vuelta y dáselo a Noa | leccions | — |
| Take turns | Turnarse | leccions, tpr | Pasar el juguete al siguiente |
| Take turns directing | Dirigir por turnos | tpr | Pasar la claqueta |
| Take turns talking | Hablar por turnos | tpr | Pasar el palo de la palabra |
| Talk it through | Hablarlo | tpr | Hablar con un amigo |
| Talkative | Hablador | tpr | Abrir y cerrar la boca del títere |
| Talking stick | Palo de la palabra | tpr | Pasar el palo a quien habla |
| tall | alto | leccions, tpr | Estirarse todo lo posible con los brazos arriba |
| Tall and green | Alto y verde | tpr | Estirar el brazo como un tallo |
| Tall buildings | Edificios altos | tpr | Mirar hacia arriba muy alto |
| Tall like a giraffe | Alto como una jirafa | tpr | Ponerse de puntillas con el cuello estirado |
| Tall tower | Torre alta | tpr | Estirar el brazo hasta la punta |
| Taller | Más alto | tpr | Comparar dos torres con la mano |
| Tally | Recuento de palitos | tpr | Hacer palitos en el aire |
| Tambourine | Pandereta | tpr | Tocar una pandereta imaginaria al pulso |
| Tangram | Tangram | tpr | Encajar piezas |
| Tangy | Ácido | tpr | Poner cara de ácido |
| Tank | Tanque de agua | tpr | Señalar el tanque |
| Tap | Grifo | tpr | Abrir y cerrar un grifo imaginario |
| Tap along | Seguir el ritmo | tpr | Dar golpecitos al ritmo |
| Tap lightly | Tocar suave | tpr | Tocar suave la rodilla |
| Tap on wood | Golpear la madera | tpr | Golpear despacio la madera |
| Tap shoes | Zapatos de claqué | tpr | Golpear con los talones en el suelo |
| Tap the rhythm | Marcar el ritmo | tpr | Dar golpecitos con la mano |
| Tap water | Agua del grifo | tpr | Poner las manos bajo el agua |
| Tap your knees like rain falling fast | Da golpecitos en las rodillas como la lluvia que cae rápido | leccions | — |
| Tap, tap, tap | Toc, toc, toc | tpr | Dar tres golpecitos |
| Tap-tap | Plic, plic | leccions, tpr | Tocar con el dedo en la palma al pulso de la lluvia |
| Tape measure | Cinta métrica | tpr | Estirar una cinta imaginaria |
| Tapping game | Juego de golpecitos | tpr | Dar golpecitos por turnos |
| Taste | Saborear | tpr | Llevarse una cuchara imaginaria a la boca despacio |
| Taste a bit | Probar un poco | tpr | Acercar un trocito a la boca |
| Taste sweet | Saber dulce | tpr | Sonreír al probar |
| Taste test | Cata de sabores | tpr | Probar y pensar |
| Tasting spoon | Cuchara de probar | tpr | Acercar la cuchara a la boca |
| Tasty | Sabroso, sabrosa | tpr | Asentir con la cabeza mientras se mastica |
| Tea set | Juego de té | tpr | Servir té de juguete |
| Team | Equipo | tpr | Juntar las manos en el centro |
| Team circle | Corrillo del equipo | tpr | Juntarse en círculo |
| Team leader | Jefe de equipo | tpr | Ponerse una banda imaginaria |
| Team, huddle up! | ¡Equipo, en corro! | tpr | Juntarse en círculo |
| Teamwork | Trabajo en equipo | tpr | Juntar las manos en el centro |
| Teeny | Pequeñito | tpr | Enseñar un espacio mínimo entre los dedos |
| Teeth | Dientes | tpr | Enseñar los dientes con una sonrisa grande |
| Teethe | Echar los dientes | tpr | Dar el mordedor al bebé |
| Tell a dream | Contar un sueño | tpr | Mover las manos recordando |
| Tell a story | Contar una historia | tpr | Mover las manos explicando |
| Tell in order | Contar en orden | tpr | Levantar uno, dos, tres dedos |
| temperature | temperatura | leccions | — |
| Tempo | Tempo musical | tpr | Golpear rápido y luego despacio |
| Ten little fingers | Diez deditos | tpr | Enseñar los diez dedos |
| Ten, nine, eight... blast off! | ¡Diez, nueve, ocho... despegamos! | tpr | Contar y saltar |
| Tender | Tierno | tpr | Besar la mano con ternura |
| Test | Probar | tpr | Probar un objeto en el agua |
| Test an idea | Probar una idea | tpr | Probar un gesto |
| Thank the teachers | Agradecer a las maestras | tpr | Poner la mano en el pecho |
| Thank you | Gracias | leccions, tpr | Poner la mano en el pecho e inclinar la cabeza |
| Thank you for everything | Gracias por todo | leccions, tpr | Poner la mano en el pecho |
| Thank you for helping me | Gracias por ayudarme | tpr | Juntar las manos |
| Thank you so much! | ¡Muchísimas gracias! | leccions, tpr | Juntar las manos y sonreír |
| Thank you, firefighter! | ¡Gracias, bombero! | tpr | Saludar al bombero |
| Thank you, Lúa! | ¡Gracias, Lúa! | tpr | Saludar a Lúa |
| Thank-you note | Nota de agradecimiento | tpr | Entregar un papel |
| Thankful | Agradecido | tpr | Poner la mano en el pecho |
| That shadow. | Esa sombra. | frases | — |
| That's OK | No pasa nada | tpr | Sonreír y abrir las manos |
| The apple is always cold. | La manzana siempre está fría. | frases | — |
| The bag is heavier with potatoes | La bolsa pesa más con patatas | tpr | Bajar el brazo como si pesara |
| The bag that we used stayed dry. | La bolsa que usamos se quedó seca. | frases | — |
| The bell rings: run to the circle and freeze! | Suena el timbre: corre al círculo y ¡estatua! | leccions | — |
| The big wheel goes round and round | La noria da vueltas y vueltas | tpr | Girar los brazos |
| The boat can float. | El barco puede flotar. | frases | — |
| The boat is moving. | El barco se está moviendo. | frases | — |
| The bottle is loud. | La botella hace mucho ruido. | frases | — |
| The bread is usually warm. | El pan suele estar templado. | frases | — |
| The bread was getting hard. | El pan se estaba poniendo duro. | frases | — |
| The brick house is stronger than the straw house | La casa de ladrillo es más fuerte que la de paja | tpr | Manos firmes y luego caer |
| The brush is between the cup and the paper. | El pincel está entre la taza y el papel. | leccions | — |
| The car is on the block. | El coche está encima del bloque. | leccions | — |
| The cat has to sleep. | El gato tiene que dormir. | frases | — |
| The chestnut is heavier than the leaf | La castaña pesa más que la hoja | tpr | Bajar una mano y subir la otra |
| The chestnut pops in the fire: jump! | La castaña estalla en el fuego: ¡salta! | leccions | — |
| The cleanest hands! | ¡Las manos más limpias! | frases | — |
| The deeper you go, the darker it gets | Cuanto más hondo, más oscuro | tpr | Bajar y cerrar los ojos |
| The dog is behind the tree. | El perro está detrás del árbol. | leccions | — |
| The Earth goes around the Sun | La Tierra gira alrededor del Sol | tpr | Caminar alrededor de un amigo |
| The end | Fin | tpr | Cerrar las manos como un libro que se cierra |
| The faces in the spoon were made by us! | ¡Las caras de la cuchara las hicimos nosotros! | frases | — |
| The grass tickles! | ¡La hierba hace cosquillas! | tpr | Reír tocando la hierba |
| The gull flies higher than the cormorant | La gaviota vuela más alto que el cormorán | tpr | Volar alto y bajo |
| The hat is chosen by you. | El gorro lo eliges tú. | frases | — |
| The hedgehog wakes up: FREEZE and curl up small! | El erizo se despierta: ¡estatua y hazte una bola! | leccions | — |
| The hungry wolf wakes up: FREEZE! | El lobo hambriento se despierta: ¡estatuas! | leccions | — |
| The ice might melt. | Puede que el hielo se derrita. | frases | — |
| The leaf falls. | La hoja cae. | frases | — |
| The leaf made a small sound. | La hoja hizo un sonido pequeño. | frases | — |
| The leaf was small. | La hoja era pequeña. | frases | — |
| The left side is the same as the right side | El lado izquierdo es igual que el derecho | tpr | Señalar los dos lados |
| The light comes out of the holes. | La luz sale por los agujeros. | frases | — |
| The light goes into the box. | La luz entra en la caja. | frases | — |
| The long straw sounds low, and the short one high. | La pajita larga suena grave, y la corta aguda. | frases | — |
| The mother swims next to her calf | La madre nada al lado de su cría | tpr | Nadar junto a un amigo |
| The newspaper is loud, whereas the tissue is soft. | El periódico suena fuerte, mientras que el pañuelo es suave. | frases | — |
| The nut dropped. | La nuez cayó. | frases | — |
| The paint had been drying all morning. | La pintura había estado secándose toda la mañana. | frases | — |
| The pattern repeats again and again | El patrón se repite una y otra vez | tpr | Girar la mano en círculos |
| The rainbow, which we painted, is big. | El arcoíris, que pintamos, es grande. | frases | — |
| The river runs into the sea | El río desemboca en el mar | tpr | Mover la mano hasta abrirla |
| The robot walks slowly, but the hero runs fast | El robot camina despacio, pero el héroe corre rápido | tpr | Caminar rígido y luego correr |
| The sea sleeps: put the cloth down and lie still | El mar duerme: deja la tela y quédate quieto | leccions | — |
| The shadow had grown long. | La sombra ya había crecido mucho. | frases | — |
| The spoon could help. | La cuchara podría ayudar. | frases | — |
| The spoon is used for soup. | La cuchara se usa para la sopa. | frases | — |
| The spoons are put away. | Las cucharas se guardan. | frases | — |
| The stars go up to the ceiling. | Las estrellas suben al techo. | frases | — |
| The stone can't float. | La piedra no puede flotar. | frases | — |
| The stone sinks, but the cork floats | La piedra se hunde, pero el corcho flota | tpr | Bajar una mano y subir la otra |
| The stone was big. | La piedra era grande. | frases | — |
| The stones were in two piles. | Las piedras estaban en dos montones. | frases | — |
| The storm is here: run and hide under the umbrella! | Llega la tormenta: ¡corre y escóndete bajo el paraguas! | leccions | — |
| The sun can't have gone. | El sol no puede haberse ido. | frases | — |
| The sun comes back: shake the water off | Vuelve el sol: sacúdete el agua | leccions | — |
| The sun comes up! | ¡Sale el sol! | leccions | — |
| The sun had gone down. | El sol ya se había puesto. | frases | — |
| The sun is up! | ¡Salió el sol! | tpr | Levantar las manos como el sol |
| The sun must have moved. | El sol debe de haberse movido. | frases | — |
| The teddy who hurt his leg is fine. | El peluche que se hizo daño en la pierna está bien. | frases | — |
| The towel is dry. | La toalla está seca. | frases | — |
| The towel is next to you. | La toalla está a tu lado. | frases | — |
| The towel will be heavy. | La toalla va a pesar. | frases | — |
| The train has gone down. | El tren ha bajado. | frases | — |
| The train starts slow, then fast, then stops. | El tren empieza despacio, luego rápido, luego para. | frases | — |
| The tram is faster than the bus | El tranvía es más rápido que el autobús | tpr | Mover las manos rápido y despacio |
| The vet helps animals because she loves them | La veterinaria ayuda a los animales porque los quiere | tpr | Acariciar un peluche |
| The warmer it gets, the faster it cooks | Cuanto más caliente, más rápido se hace | tpr | Frotar las manos rápido |
| The weather was checked every morning. | El tiempo se miraba cada mañana. | frases | — |
| The wheels go round | Las ruedas giran | tpr | Girar los brazos como ruedas |
| The wild boar is coming: FREEZE! | Viene el jabalí: ¡estatuas! | leccions | — |
| The wind blows! Whoosh! | ¡Sopla el viento! ¡Fiuuu! | leccions | — |
| The wind is blowing | Sopla el viento | leccions, tpr | Soplar y mover los brazos |
| The wolf is watching: FREEZE! | El lobo está mirando: ¡estatuas! | leccions | — |
| The wolf sleeps again: tiptoe away | El lobo vuelve a dormir: vete de puntillas | leccions | — |
| Theatrical | Teatral | tpr | Abrir los brazos exagerando |
| There are bubbles. | Hay burbujas. | frases | — |
| There is a towel. | Hay una toalla. | frases | — |
| There it is! | ¡Ahí está! | tpr | Señalar la sonrisa del bebé |
| There might be more spoons. | Puede que haya más cucharas. | frases | — |
| Thermos | Termo | tpr | Servir algo caliente del termo |
| They lived happily ever after | Vivieron felices para siempre | tpr | Abrazarse |
| They move across the room. | Se mueven por la habitación. | frases | — |
| Thick | Espeso, espesa | tpr | Remover con fuerza como en una papilla espesa |
| Thin | Delgado, delgada | tpr | Juntar las palmas muy estiradas hacia arriba |
| Think hard | Pensar mucho | tpr | Poner el dedo en la frente |
| Thirsty | Con sed | tpr | Hacer el gesto de beber con la mano en forma de vaso |
| This card is for my grandma | Esta postal es para mi abuela | tpr | Enseñar la postal |
| This flower has more petals than that one | Esta flor tiene más pétalos que esa | tpr | Señalar y comparar |
| This is for you | Esto es para ti | tpr | Extender una postal |
| This is the best soap. | Este es el mejor jabón. | frases | — |
| This is the cloth that drinks water. | Este es el paño que bebe el agua. | frases | — |
| This leaf. | Esta hoja. | frases | — |
| This little piggy | Este cerdito | tpr | Coger un dedo del pie tras otro |
| This must be your spoon. | Esta debe de ser tu cuchara. | frases | — |
| This one is darker than that one | Esta es más oscura que esa | tpr | Comparar dos hojas |
| This one is longer | Este es más largo | tpr | Señalar el más largo |
| This time tomorrow, we will be using the torch. | Mañana a esta hora estaremos usando la linterna. | frases | — |
| This tree is older than our grandparents | Este árbol es más viejo que nuestros abuelos | tpr | Señalar y comparar |
| Thoughtful | Atento | tpr | Tocar la cabeza y el pecho |
| Thoughtful idea | Idea pensada | tpr | Tocar la frente despacio |
| Thread beads | Ensartar cuentas | tpr | Pasar un hilo imaginario |
| Three little pigs | Tres cerditos | tpr | Enseñar tres dedos |
| Three plus two makes five | Tres más dos son cinco | tpr | Enseñar tres y dos dedos |
| Three, two, one, happy new year! | ¡Tres, dos, uno, feliz año nuevo! | tpr | Contar y saltar |
| Through the grass | Por la hierba | tpr | Abrirse paso con las manos entre hierba alta |
| Through the jungle | Por la selva | tpr | Caminar apartando hojas |
| Throw | Lanzar | tpr | Lanzar una bola de nieve imaginaria muy suave |
| Throw and catch | Lanzar y coger | tpr | Lanzar y coger una pelota |
| Throw away | Tirar | tpr | Tirar el papel a la papelera |
| Throw caps in the air | Lanzar los birretes | tpr | Lanzar al aire |
| Throw it higher than the tree | Lánzalo más alto que el árbol | tpr | Lanzar muy alto |
| Thrown gently, it flew far. | Lanzado con suavidad, voló lejos. | frases | — |
| Thumbs up for a clean beach! | ¡Pulgar arriba por la playa limpia! | tpr | Levantar el pulgar |
| Thumbs up for a clean sea! | ¡Pulgar arriba por el mar limpio! | tpr | Levantar el pulgar |
| Thumping | Que retumba | tpr | Golpear con el pie y escuchar |
| Tick, tock! | ¡Tic, tac! | tpr | Mover la cabeza de un lado a otro al pulso |
| Tickle | Hacer cosquillas | tpr | Caminar con los dedos por el brazo haciendo cosquillas |
| Tickle toes | Hacer cosquillas en los pies | tpr | Pasar hierba por los pies |
| Tickle tummy | Hacer cosquillas en la barriga | tpr | Hacer cosquillas en la barriga despacio |
| Ticklish | Cosquilloso, cosquillosa | tpr | Reír encogidos cuando alguien se acerca con los dedos |
| Ticklish feet | Pies cosquillosos | tpr | Hacer cosquillas en los pies |
| Tickly | Que hace cosquillas | tpr | Hacerse cosquillas suaves en el brazo |
| Tickly grass | Hierba que hace cosquillas | tpr | Reír al tocar la hierba |
| Tidal | De marea | tpr | Mover la mano adelante y atrás |
| Tide | Marea | 0-2, tpr | Mover la mano adelante y atrás |
| Tidy | Ordenado, ordenada | tpr | Alinear juguetes imaginarios en fila |
| Tidy up! | ¡A recoger! | tpr | Recoger juguetes imaginarios y guardarlos en una caja |
| Tidy your room | Ordenar el cuarto | tpr | Recoger juguetes |
| Tidy-up song | Canción de recoger | tpr | Cantar mientras se recoge |
| Tie up | Amarrar | leccions, tpr | Hacer un nudo en el aire |
| Tied | Empatados | tpr | Juntar las dos manos |
| Tiger cub | Cachorro de tigre | tpr | Acurrucarse como un cachorro de tigre |
| Tight | Apretado, apretada | tpr | Apretar los brazos contra el cuerpo |
| Tightrope | Cuerda floja | tpr | Caminar por la línea con los brazos en cruz |
| Tights | Leotardos | tpr | Tirar de los leotardos hacia arriba |
| Tile | Azulejo | leccions, tpr | Posar la mano plana |
| Time for a drink | Hora de beber | tpr | Acercar la botella |
| Time it | Cronometrar | tpr | Pulsar un cronómetro |
| Timeline | Línea del tiempo | tpr | Señalar de una punta a otra |
| Timer song | Canción de dos minutos | tpr | Cantar mientras se cepilla |
| Timetable | Horario | tpr | Señalar horas en un reloj |
| Timetable board | Horario de la clase | tpr | Señalar horas |
| Tinkly | Tintineante | tpr | Tocar la campanita despacio |
| Tiny | Diminuto, diminuta | tpr | Mostrar algo diminuto entre dos dedos |
| Tiny bits | Trocitos | tpr | Juntar los dedos |
| Tiny shoe | Zapatito | tpr | Juntar mucho las manos |
| Tiny toes | Deditos pequeños | 0-2, leccions, tpr | Contar los deditos de los pies |
| Tiny village | Aldea pequeña | tpr | Juntar las manos |
| Tip over | Volcar | tpr | Dejar caer despacio hacia un lado |
| Tip the scale | Inclinar la balanza | tpr | Bajar un brazo |
| Tiptoe | Andar de puntillas | leccions, tpr | Caminar de puntillas muy callados |
| Tiptoe around | Andar de puntillas | leccions, tpr | Caminar de puntillas alrededor |
| Tiptoe past | Pasar de puntillas | tpr | Pasar de puntillas en silencio |
| Tiptoe quietly to blow out the light | Ve de puntillas, en silencio, a apagar la luz | leccions | — |
| Tiptoe through | Pasar de puntillas | tpr | Caminar de puntillas por la hierba |
| Tissue | Pañuelo de papel | tpr | Limpiar la nariz con un pañuelo |
| Tissue box | Caja de pañuelos | tpr | Coger un pañuelo de la caja |
| Toasty | Calentito | tpr | Acercar las manos al calorcito |
| Toasty warm | Calentito | tpr | Abrazar al bebé bien apretado |
| Today | Hoy | tpr | Señalar el suelo |
| Today it has gone fast! | ¡Hoy ha ido rápido! | frases | — |
| Toenails | Uñas de los pies | 0-2, tpr | Contar las uñas de los pies |
| Toes | Dedos de los pies | 0-2, leccions, tpr | Tocar los dedos de los pies |
| Together | Juntos | tpr | Juntar las manos de todos |
| Together again | Juntos otra vez | tpr | Abrazarse de nuevo |
| Together we are stronger | Juntos somos más fuertes | tpr | Juntar las manos y levantarlas |
| Tomorrow | Mañana | tpr | Señalar hacia delante |
| Toot | Tocar la trompeta | tpr | Soplar una trompeta de juguete |
| Toot the horn | Tocar la sirena | tpr | Hacer «tuuu» como el barco |
| Toot, toot! | ¡Tuu, tuu! | tpr | Hacer la sirena del barco |
| Toothpaste | Pasta de dientes | tpr | Poner un poco de pasta |
| Top and bottom | Arriba y abajo | tpr | Señalar los dientes de arriba y abajo |
| Top to toe | De la cabeza a los pies | tpr | Tocar de la cabeza a los pies con las dos manos |
| Topple | Venirse abajo | tpr | Dejar caer la torre |
| Toss | Lanzar | tpr | Lanzar un pañuelo al aire |
| Total | Total | tpr | Juntar todos los dedos |
| Touch | Tocar | tpr | Tocar suavemente algo que esté cerca |
| Touch your head | Tócate la cabeza | tpr | Tocarse la cabeza con las dos manos al oír la orden |
| Touch your knees | Tócate las rodillas | leccions, tpr | Tocar las rodillas |
| Touch your knees and freeze! | Tócate las rodillas y ¡estatua! | leccions | — |
| Touch your toes | Tocar los pies | tpr | Bajar las manos hasta los pies |
| Towel | toalla | 0-2, leccions, tpr | Secarse las manos con una toalla imaginaria |
| Tower | Torre | tpr | Hacer una torre alta |
| Town hall | Ayuntamiento | tpr | Hacer una torre con las manos |
| Town square | Plaza | tpr | Dibujar una plaza en el suelo |
| Toy | Juguete | tpr | Coger un juguete imaginario y enseñarlo al grupo |
| Toy box | Caja de los juguetes | tpr | Meter un juguete en la caja |
| Toy car | Cochecito | tpr | Rodar el cochecito por la mesa |
| Toy tambourine | Pandereta de juguete | 0-2, leccions, tpr | Golpear la pandereta con la palma |
| Toy watering can | Regadera de juguete | tpr | Verter agua con la regadera |
| Trace | Trazar | tpr | Seguir con un dedo el borde de una forma |
| Trace a spiral | Repasar una espiral | tpr | Seguir la espiral con el dedo |
| Trace around | Repasar el borde | tpr | Seguir el borde con el dedo |
| Tradition | Tradición | tpr | Juntar las manos en círculo |
| Traditional | Tradicional | tpr | Bailar como antes |
| Traffic light game | Juego del semáforo | tpr | Parar y correr según el color |
| Trail | Rastro | tpr | Seguir una línea en el suelo |
| Train set | Tren de juguete | tpr | Empujar el tren por la vía |
| Trampoline | Cama elástica | tpr | Saltar sobre la cama elástica |
| Transfer | Hacer transbordo | tpr | Cambiar de un sitio a otro |
| Travel | Viajar | tpr | Volar como un avión hasta otro rincón del aula |
| Travel by boat | Viajar en barco | tpr | Balancearse sentados |
| Travel map | Mapa de viaje | leccions, tpr | Señalar un sitio en el mapa |
| Tray | Bandeja | tpr | Llevar la bandeja con las dos manos |
| Tread | Pisar | leccions, tpr | Pisar despacio una hoja |
| Treasure basket | Cesta de los tesoros | tpr | Abrir la cesta y sacar un objeto |
| Treasured | Querido | tpr | Abrazar la caja de los recuerdos |
| Tree bark | Corteza | 0-2, tpr | Pasar la mano por la corteza |
| Tree planting | Plantación de árboles | tpr | Cavar y plantar |
| Tree pose | Postura del árbol | tpr | Poner un pie en la rodilla |
| Tree rings | Anillos del árbol | tpr | Dibujar círculos cada vez más grandes |
| Tree trunk | Tronco | tpr | Abrazar un tronco con el bebé |
| Treetop | Copa del árbol | tpr | Señalar la copa del árbol |
| Trickle | Escurrir | tpr | Bajar un dedo por el cristal |
| Trickling | Goteando | tpr | Mover un dedo despacio |
| Tricky | Complicado | tpr | Rascarse la cabeza |
| Tricycle | Triciclo | tpr | Pedalear en el aire |
| Tropical | Tropical | tpr | Mover las manos como hierba alta |
| Trot | Trotar | tpr | Hacer trotar al bebé en la rodilla como un caballo |
| Trustworthy | De confianza | tpr | Poner la mano en el hombro |
| Try again | Intentarlo de nuevo | tpr | Volver al principio |
| Try it | Probar | tpr | Acercar un trocito a la boca |
| Try your best | Hacerlo lo mejor posible | tpr | Apretar los puños con ánimo |
| Tube | Tubo | tpr | Mirar a través de un tubo |
| Tuck in | Arropar | tpr | Meter la manta bajo el bebé |
| Tummy | Barriga | 0-2, leccions, tpr | Tocarse la barriga con un dedo y reír |
| Tummy time | Tiempo boca abajo | tpr | Poner al bebé boca abajo en la alfombra |
| Tune in | Prestar atención | tpr | Llevar la mano a la oreja |
| Tuneful | Melodioso | tpr | Tararear bonito |
| Tunnel | Túnel | tpr | Pasar la mano por el túnel de tela |
| Turn | Girar | tpr | Dar una vuelta sobre uno mismo |
| Turn around | Date la vuelta | leccions, tpr | Dar una vuelta entera y mirar al grupo |
| Turn back | Volver atrás | tpr | Darse la vuelta y caminar de vuelta |
| Turn it around and try again | Dale la vuelta y prueba otra vez | tpr | Girar y volver a probar |
| Turn left | Girar a la izquierda | leccions, tpr | Girar hacia la izquierda |
| Turn left and step over the rope | Gira a la izquierda y pasa por encima de la cuerda | leccions | — |
| Turn left at the square | Gira a la izquierda en la plaza | tpr | Caminar y girar a la izquierda |
| Turn off | Apagar | leccions, tpr | Pulsar el interruptor y cerrar los ojos |
| Turn off lights | Apagar las luces | tpr | Pulsar un interruptor |
| Turn off the light when you leave | Apaga la luz cuando salgas | tpr | Pulsar e irse |
| Turn off the tap! | ¡Cierra el grifo! | tpr | Girar el grifo |
| Turn on | Encender | leccions, tpr | Pulsar un interruptor imaginario y abrir los ojos |
| Turn order | Orden de turnos | tpr | Señalar quién va primero |
| Turn out | Desmoldar | tpr | Volcar el molde y levantarlo |
| Turn over a stone | Dar la vuelta a una piedra | tpr | Voltear una piedra con cuidado |
| Turn right | Girar a la derecha | tpr | Girar hacia la derecha |
| Turn the page | Pasar la página | tpr | Pasar la página del libro |
| Turn the page of the calendar | Pasar la hoja del calendario | tpr | Pasar una hoja |
| Turn the tap | Abrir el grifo | tpr | Girar el grifo despacio |
| Turn to the door | Gírate hacia la puerta | tpr | Girarse hacia la puerta |
| Tweet | Piar | 0-2, leccions, tpr | Hacer «pío pío» bajito |
| Tweet, tweet! | ¡Pío, pío! | 0-2, leccions, tpr | Abrir y cerrar los dedos como un pico |
| Twig | Ramita | 0-2, tpr | Dar una ramita pequeña |
| Twiggy | De ramitas | tpr | Tocar un nido de ramitas |
| Twigs | Ramitas | tpr | Juntar ramitas |
| Twinkle | Titilar | tpr | Abrir y cerrar los dedos muy rápido por encima de la cabeza |
| Twinkling | Titilante | tpr | Abrir y cerrar los dedos despacio |
| Twinkly | Centelleante | tpr | Mover los dedos como luces |
| Twirl | Girar | tpr | Girar un pañuelo en el aire |
| Two apples, please | Dos manzanas, por favor | tpr | Enseñar dos dedos |
| Two big stones. | Dos piedras grandes. | frases | — |
| Two by two | De dos en dos | tpr | Ponerse por parejas y caminar de la mano |
| Two, four, six, eight | Dos, cuatro, seis, ocho | tpr | Saltar contando |
| Unanimous | Por unanimidad | tpr | Levantar todos la mano |
| Uncle | Tío | tpr | Señalar la foto del tío |
| Uncover | Destapar | tpr | Quitar el pañuelo de encima del juguete |
| Under the blanket | Debajo de la manta | tpr | Esconderse debajo de una manta imaginaria |
| Under the quilt | Debajo del edredón | tpr | Meterse bajo el edredón |
| Under the sea | Bajo el mar | tpr | Bajar al suelo y moverse despacio como bajo el agua |
| Under the stone | Debajo de la piedra | tpr | Levantar la piedra y mirar |
| Under the stones! Slither like a snake | ¡Debajo de las piedras! Arrástrate como una serpiente | leccions | — |
| Under the table | Debajo de la mesa | tpr | Meterse debajo de la mesa |
| Under the tap | Debajo del grifo | tpr | Poner las manos bajo un grifo imaginario |
| Under the tree | Debajo del árbol | tpr | Agacharse bajo los brazos de una compañera que hace de árbol |
| Under the umbrella | Debajo del paraguas | tpr | Juntarse varias criaturas debajo de un paraguas imaginario |
| Underpass | Paso inferior | leccions, tpr | Pasar agachado por debajo |
| Understanding | Comprensivo | tpr | Asentir despacio |
| Underwater | Submarino, submarina | tpr | Inflar los mofletes y moverse despacio |
| Underwater camera | Cámara submarina | tpr | Hacer fotos con las manos |
| Unfold | Desplegar | tpr | Abrir los dedos despacio como una flor |
| Unforgettable | Inolvidable | tpr | Poner las manos en el pecho |
| Uniformed | Con uniforme | tpr | Estirar la ropa |
| Unpack | Desempaquetar | tpr | Sacar las cosas de la cesta |
| Unsteady | Inestable | tpr | Tambalearse y recuperarse |
| Unstoppable | Imparable | tpr | Correr en el sitio |
| Unwind | Desconectar | leccions, tpr | Soltar los hombros |
| Unwrap | Desenvolver | tpr | Desenvolver despacio un regalo imaginario |
| Up and away | Arriba y lejos | tpr | Lanzar la hoja hacia arriba |
| Up and down | Arriba y abajo | tpr | Subir y bajar los brazos al pulso |
| Up and down the city | Arriba y abajo por la ciudad | tpr | Mover el volante e inclinarse |
| Up as steam, down as rain | Sube como vapor, baja como lluvia | tpr | Subir y bajar las manos |
| Up in the air | En el aire | tpr | Señalar las burbujas arriba |
| Up it goes! | ¡Arriba va! | tpr | Lanzar el pañuelo arriba |
| Up the arm | Por el brazo arriba | tpr | Subir con los dedos hasta el hombro |
| Up the hill and down | Cuesta arriba y abajo | tpr | Subir y bajar con las manos |
| Up the hill and down again | Monte arriba y otra vez abajo | tpr | Subir y bajar con las manos |
| Up the palm tree | Por la palmera arriba | tpr | Subir los brazos como trepando |
| Up to the star | Hasta la estrella | tpr | Estirarse de puntillas hasta tocar una estrella imaginaria |
| Up with the crane | Arriba con la grúa | tpr | Levantar el brazo despacio |
| Up you come! | ¡Arriba! | tpr | Levantar al bebé del suelo |
| Uphill | Cuesta arriba | tpr | Caminar con esfuerzo |
| Upright | Derecho | tpr | Sentar al bebé derecho |
| Upright posture | Postura recta | tpr | Sentarse recto |
| Upside-down | Del revés | tpr | Poner las manos del revés |
| Upstairs and downstairs | Escaleras arriba y abajo | tpr | Subir y bajar escalones imaginarios en el sitio |
| Upstream | Río arriba | tpr | Mover la mano hacia arriba con esfuerzo |
| Useful | Útil | tpr | Levantar una herramienta |
| Useful helper | Ayudante útil | tpr | Llevar una caja |
| Vegetables | Verduras | tpr | Enseñar una cesta de verduras |
| Vegetables make us strong | Las verduras nos hacen fuertes | tpr | Poner los brazos fuertes |
| Verse | Verso | tpr | Marcar el ritmo de un verso |
| Very dizzy | Muy mareado | tpr | Parar y tambalearse riendo |
| Very old | Muy viejo | tpr | Caminar despacio y encorvado |
| Vet | Veterinario | tpr | Acariciar un animal de peluche |
| Viewpoint | Mirador | tpr | Mirar lejos con la mano en la frente |
| Vigo was small, but now it is big | Vigo era pequeño, pero ahora es grande | tpr | Juntar las manos y abrirlas |
| Vine | Liana | tpr | Agarrarse a una liana imaginaria |
| Vinegar | Vinagre | tpr | Hacer mueca de ácido |
| Visit | Visitar | tpr | Caminar y mirar alrededor |
| Vivid | Vivo | tpr | Abrir los ojos mucho |
| Voice | Voz | tpr | Hablar con una voz distinta |
| Volunteer | Voluntario | tpr | Levantar la mano para ayudar |
| Vote | Voto | leccions, tpr | Levantar la mano para votar |
| Waddle | Anadear | tpr | Caminar balanceándose como un pato |
| Waddle along | Caminar bamboleándose | tpr | Bambolearse de un lado a otro |
| Waddling | Bamboleante | tpr | Bambolearse como un pingüino |
| Wade | Caminar por el agua | tpr | Levantar mucho las piernas |
| Wade in | Entrar caminando en el agua | leccions, tpr | Levantar las rodillas |
| Wag | Mover la cola | tpr | Mover las caderas como una cola contenta |
| Wait | Esperar | tpr | Cruzar las manos en el regazo y contar hasta tres en silencio |
| Wait for | Esperar a | tpr | Mirar el reloj |
| Wait for green | Espera al verde | tpr | Parar y esperar |
| Wait in line | Esperar en la fila | tpr | Esperar uno detrás de otro |
| Wait your turn, please | Espera tu turno, por favor | leccions, tpr | Poner las manos en el regazo y esperar |
| Wake | Despertar | tpr | Desperezarse con el bebé |
| Wake up early | Despertar temprano | tpr | Desperezarse y sentarse |
| Wake up! | ¡Despierta! | leccions, tpr | Abrir los ojos de golpe y sentarse |
| Walk across | Cruzar caminando | tpr | Caminar de un lado al otro |
| Walk along | Caminar a lo largo | tpr | Caminar en fila |
| Walk backwards | Caminar hacia atrás | tpr | Dar pasos hacia atrás con cuidado |
| Walk calmly like a sheep in the field | Camina tranquilo como una oveja en el campo | leccions | — |
| Walk down | Bajar caminando | tpr | Caminar inclinado hacia atrás |
| Walk heavily | Caminar pesado | tpr | Caminar como un gigante |
| Walk heavily like a big cow | Camina pesado como una vaca grande | leccions | — |
| Walk lightly | Caminar ligero | tpr | Caminar de puntillas |
| Walk like a penguin | Camina como un pingüino | tpr | Caminar con pasitos cortos |
| Walk like a sleepy bear with your heavy bag | Camina como un oso dormido con la mochila pesada | leccions | — |
| Walk like an elephant | Caminar como un elefante | tpr | Caminar como un elefante |
| Walk on stage | Subir al escenario | tpr | Caminar erguido |
| Walk sideways like a crab | Camina de lado como un cangrejo | tpr | Caminar de lado con los dedos en pinza |
| Walk slowly and hold your friend's hand | Camina despacio y coge la mano de tu amigo | leccions | — |
| Walk softly | Camina suave | tpr | Caminar muy suave para no hacer ruido |
| Walk through | Pasear entre | tpr | Caminar mirando arriba |
| Walk to school | Ir caminando al colegio | tpr | Caminar en el sitio |
| Walk to the circle and sit down | Camina hasta el círculo y siéntate | leccions | — |
| Walk to the hook and hang up your coat | Camina hasta el perchero y cuelga el abrigo | leccions | — |
| Walk together like one big cloud | Caminad juntos como una nube grande | leccions | — |
| Walking is better than driving for short trips | Caminar es mejor que conducir para ir cerca | tpr | Caminar y sonreír |
| Walking stick | Bastón | tpr | Caminar apoyándose en un bastón |
| Walnut | Nuez | tpr | Abrir una nuez imaginaria con las dos manos |
| Walrus | Morsa | leccions, tpr | Poner dos dedos como colmillos |
| Warm as toast | Calentito como el pan | tpr | Frotar la barriga del bebé |
| Warm chestnut | Castaña caliente | tpr | Soplar la castaña antes de tocarla |
| Warm clothes | Ropa de abrigo | tpr | Abrazar una chaqueta |
| Warm feet | Calentar los pies | tpr | Frotar los pies del bebé |
| Warm hands | Manos calientes | tpr | Frotar las manos y posarlas en la barriga |
| Warm hands, warm heart | Manos calientes, corazón caliente | tpr | Frotar las manos y posarlas en el pecho |
| Warm milk | Leche templada | 0-2, tpr | Acercar el biberón templado |
| Warm sand | Arena templada | tpr | Posar la mano en la arena templada |
| Warm up | Calentarse | tpr | Frotarse las manos y el cuerpo para entrar en calor |
| Warm up hands | Calentar las manos | tpr | Soplar en las manos del bebé |
| Warm up your body | Calienta el cuerpo | tpr | Mover todo el cuerpo |
| Warm with breath | Calentar con el aliento | tpr | Soplar en las manos |
| Warm your hands and rub them fast | Calienta las manos y frótalas rápido | leccions | — |
| Warm! | templado, calentito | 0-2, leccions, tpr | Soplarse en las manos y ponerlas en las mejillas |
| Warm-hearted | De buen corazón | tpr | Abrazarse a sí mismo |
| Warm-up exercise | Calentamiento | tpr | Mover los brazos en círculos |
| Warm... soft and warm | Calentito... suave y calentito | leccions | — |
| Warmer | Más caliente | tpr | Frotar las manos |
| Was the stone the biggest? | ¿Era la piedra la más grande? | frases | — |
| Was Vigo always big? | ¿Vigo siempre fue grande? | tpr | Abrir y cerrar las manos |
| Wash hair | Lavar el pelo | tpr | Mojar el pelo con la mano |
| Wash thoroughly | Lavar bien | tpr | Frotar entre los dedos |
| Wash vegetables | Lavar las verduras | tpr | Frotar una verdura bajo el agua |
| Wash your belly! | ¡Lávate la barriga! | leccions | — |
| Wash your face! | ¡Lávate la cara! | leccions, tpr | Lavarse la cara con agua imaginaria |
| Wash your hands before lunch | Lávate las manos antes de comer | tpr | Lavarse las manos y sentarse |
| Wash! | lavar | 0-2, leccions, tpr | Lavar una muñeca imaginaria con cuidado |
| Wash, then dry | Lavar y luego secar | tpr | Lavarse las manos imaginarias y luego secarlas |
| Wash, wash the socks | Lava, lava los calcetines | tpr | Frotar un calcetín |
| Wash, wash, wash | Lava, lava, lava | tpr | Frotar las manos tres veces |
| Washbasin | Lavabo | tpr | Señalar el lavabo |
| Washcloth | Manopla de baño | 0-2, tpr | Pasar la manopla por el brazo |
| Washing line | Tendedero | tpr | Estirar una cuerda imaginaria |
| Washing machine | Lavadora | tpr | Girar las manos como la lavadora |
| Wasteful | Que desperdicia | tpr | Dejar caer agua y parar |
| Wasteful habit | Mala costumbre | tpr | Negar con la cabeza |
| Watch it grow | Verlo crecer | tpr | Subir la mano despacio |
| Watch out, crocodile! | ¡Cuidado, cocodrilo! | tpr | Encoger las piernas de golpe y reír |
| Watch quietly | Observar en silencio | tpr | Mirar con la mano en la frente |
| Watch the glitter settle | Ver bajar la purpurina | tpr | Agitar y esperar |
| Watch the sky | Mirar el cielo | tpr | Mirar hacia arriba en silencio |
| Water always flows downhill | El agua siempre baja | tpr | Mover las manos de arriba abajo |
| Water bottle | Botella de agua | tpr | Dar un sorbo de agua |
| Water break | Pausa para beber | tpr | Beber un sorbo |
| Water cycle | Ciclo del agua | tpr | Hacer un círculo con el dedo |
| Water first, then soap | Primero agua, luego jabón | tpr | Hacer los dos gestos en orden |
| Water is faster than soap. | El agua es más rápida que el jabón. | frases | — |
| Water it | Regarla | tpr | Echar agua con la regadera |
| Water on my toes | Agua en mis deditos | tpr | Echar agua en los pies |
| Water pipe | Tubería | tpr | Hacer un tubo con los brazos |
| Water table | Mesa de agua | tpr | Posar las manos en la mesa de agua |
| Water tap | Grifo del agua | tpr | Cerrar el grifo |
| Water the plants | Regar las plantas | leccions, tpr | Inclinar una regadera |
| Water tray | Bandeja de agua | 0-2, tpr | Posar las manos en la bandeja |
| Waterfall | Cascada | tpr | Bajar los brazos de golpe |
| Watering can | Regadera | tpr | Inclinar una regadera imaginaria |
| Waterlogged | Empapado | tpr | Bajar el cuerpo pesado |
| Waterproof | Impermeable | tpr | Dejar resbalar agua por el impermeable |
| Wave and smile | Saludar y sonreír | tpr | Saludar con la mano y sonreír a la vez |
| Wave fingers | Mover los dedos | tpr | Mover los dedos como hierba |
| Wave to families | Saludar a las familias | tpr | Saludar al público |
| Wave to the boat | Saludar al barco | leccions, tpr | Saludar hacia el mar |
| Wave your graduation cap | Agitar el birrete | tpr | Agitar la mano en el aire |
| Waves go up, waves go down, blue sea | Las olas suben, las olas bajan, mar azul | leccions | — |
| Wavy | Ondulado, ondulada | tpr | Dibujar líneas onduladas en el aire |
| Wavy-edged | De borde ondulado | tpr | Dibujar ondas con el dedo |
| We are blowing the boat. | Estamos soplando el barco. | frases | — |
| We are going to lift it. | Vamos a levantarla. | frases | — |
| We are tiny seeds under the ground | Somos semillas pequeñitas bajo la tierra | leccions | — |
| We build a tower and it stands. | Hacemos una torre y aguanta. | frases | — |
| We can both be right | Podemos tener razón los dos | tpr | Darse la mano |
| We cut a cross so it doesn't pop | Hacemos una cruz para que no explote | tpr | Dibujar la cruz |
| We did it together | Lo hicimos juntos | tpr | Juntar las manos y levantarlas |
| We did it! | ¡Lo conseguimos! | tpr | Levantar los brazos todos |
| We found it! | ¡Lo encontramos! | tpr | Dar palmas |
| We had been painting before we folded it. | Habíamos estado pintando antes de doblarlo. | frases | — |
| We had drawn it before dinner. | La habíamos dibujado antes de cenar. | frases | — |
| We had the boots put by the door. | Hicimos poner las botas junto a la puerta. | frases | — |
| We have been talking in the cups. | Llevamos un rato hablando por los vasos. | frases | — |
| We have grown so much in five years | Hemos crecido mucho en cinco años | tpr | Estirarse hasta arriba |
| We have made a row. | Hemos hecho una fila. | frases | — |
| We have to hurry because the train is leaving in front of us. | Tenemos que darnos prisa porque el tren sale delante de nosotros. | leccions | — |
| We listen because we care | Escuchamos porque nos importa | tpr | Llevar la mano a la oreja y al pecho |
| We listened. | Escuchamos. | frases | — |
| We never eat cold bread. | Nunca comemos pan frío. | frases | — |
| We often touch them. | Los tocamos a menudo. | frases | — |
| We share because we care | Compartimos porque nos importa | tpr | Repartir y sonreír |
| We should have looked at the shadow earlier. | Deberíamos haber mirado la sombra antes. | frases | — |
| We smell with our nose and taste with our tongue | Olemos con la nariz y saboreamos con la lengua | tpr | Señalar nariz y lengua |
| We solved it together! | ¡Lo resolvimos juntos! | tpr | Chocar las manos |
| We walk across the bridge. | Cruzamos el puente caminando. | leccions | — |
| We walk on the path so the plants can grow | Caminamos por el camino para que crezcan las plantas | tpr | Caminar por la línea |
| We want to run. | Queremos correr. | frases | — |
| We were squeezing the bread. | Estábamos apretando el pan. | frases | — |
| Weather | Tiempo | tpr | Mirar por la ventana y señalar el cielo |
| Weather chart | Tabla del tiempo | tpr | Pegar el símbolo de la lluvia |
| Weather station | Estación meteorológica | tpr | Señalar el sol, la lluvia y el viento |
| Weather vane | Veleta | tpr | Girar un brazo como la veleta |
| Webbed | Palmeado | tpr | Abrir los dedos |
| Webbed feet | Patas palmeadas | tpr | Abrir los dedos de las manos |
| Week | Semana | tpr | Contar siete dedos |
| Weigh | Pesar | tpr | Levantar dos objetos y comparar |
| Weigh up | Pesar y comparar | tpr | Sostener dos cosas y comparar |
| Weight | Peso | tpr | Bajar una mano pesada |
| Weightless | Ingrávido | tpr | Moverse flotando |
| Welcome aboard! | ¡Bienvenidos a bordo! | leccions | — |
| Welcome back | De vuelta | tpr | Abrir los brazos contentos |
| Welcome! | ¡Bienvenido! | tpr | Abrir los brazos al recibirlo |
| Welcoming | Acogedor | tpr | Abrir los brazos |
| Well done, explorer! | ¡Muy bien, explorador! | tpr | Levantar el pulgar |
| Well-cared-for | Bien cuidado | tpr | Acariciar una planta |
| Well-rehearsed | Bien ensayado | tpr | Repetir un gesto perfecto |
| Well-rested | Descansado | tpr | Estirarse después de descansar |
| Wellies | Botas de agua | 0-2, tpr | Poner las botitas al bebé |
| Wellington boots | Botas de goma | leccions, tpr | Ponerse las botas de goma |
| Wet | mojado | 0-2, leccions, tpr | Sacudir las manos como si estuvieran mojadas |
| Wet sponge | Esponja mojada | tpr | Escurrir la esponja |
| Wet wipe | Toallita húmeda | tpr | Limpiar las manos con una toallita |
| What a colour! | ¡Qué color! | tpr | Enseñar la fruta a la luz |
| What animal are you? | ¿Qué animal eres? | tpr | Señalar el disfraz de un amigo |
| What bird is that? | ¿Qué pájaro es ese? | tpr | Señalar el cielo |
| What can we do? | ¿Qué podemos hacer? | tpr | Abrir las manos preguntando |
| What can you see from here? | ¿Qué ves desde aquí? | tpr | Mirar alrededor |
| What colour is broccoli? | ¿De qué color es el brócoli? | tpr | Señalar algo verde |
| What colour is it? | ¿De qué color es? | tpr | Encoger los hombros y señalar un objeto |
| What comes next? | ¿Qué viene después? | tpr | Señalar y esperar |
| What day is it today? | ¿Qué día es hoy? | tpr | Señalar el calendario |
| What did you dream about? | ¿Qué soñaste? | tpr | Tocar la cabeza |
| What do you do to feel calm? | ¿Qué haces para estar tranquilo? | tpr | Respirar hondo |
| What do you think will happen? | ¿Qué crees que pasará? | tpr | Tocar la cabeza |
| What do you want to be? | ¿Qué quieres ser? | tpr | Señalar varios oficios |
| What do you want? | ¿Qué quieres? | leccions | — |
| What does the cow say? | ¿Qué dice la vaca? | tpr | Enseñar la vaca y esperar |
| What grows on the ropes? | ¿Qué crece en las cuerdas? | tpr | Señalar abajo |
| What happened next? | ¿Qué pasó después? | tpr | Señalar adelante |
| What if the wolf was kind? | ¿Y si el lobo fuera bueno? | tpr | Tocar la cabeza pensando |
| What is it? | ¿Qué es? | tpr | Enseñar un objeto y esperar |
| What is it? A dog! | ¿Qué es? ¡Un perro! | frases | — |
| What lives in the seagrass? | ¿Qué vive en la pradera marina? | tpr | Mirar abajo |
| What lives on the seabed? | ¿Qué vive en el fondo del mar? | tpr | Mirar abajo |
| What matters is the coat. | Lo que importa es el abrigo. | frases | — |
| What shape is this? | ¿Qué forma es? | tpr | Enseñar una forma y esperar |
| What was happening to the bread? | ¿Qué le estaba pasando al pan? | frases | — |
| What we need is water. | Lo que necesitamos es agua. | frases | — |
| What will happen if it gets warm? | ¿Qué pasará si hace calor? | tpr | Encoger los hombros |
| What would happen if we hit the glass harder? | ¿Qué pasaría si golpeáramos el vaso más fuerte? | frases | — |
| What would have happened without water? | ¿Qué habría pasado sin agua? | frases | — |
| What's in the bag? | ¿Qué hay en la bolsa? | tpr | Meter la mano y adivinar |
| What's in the basket? | ¿Qué hay en la cesta? | tpr | Asomarse dentro de la cesta |
| What's inside? | ¿Qué hay dentro? | tpr | Agitar la caja y escuchar |
| What's your name? | ¿Cómo te llamas? | tpr | Poner la mano en el pecho y luego señalar a otra persona |
| Whee! | ¡Uiii! | tpr | Levantar al bebé y bajarlo |
| Wheelbarrow | Carretilla | tpr | Empujar la carretilla con hojas |
| When I feel angry, I breathe slowly | Cuando me enfado, respiro despacio | tpr | Apretar los puños y respirar |
| When I look after my plant, it grows | Cuando cuido mi planta, crece | tpr | Regar y subir la mano |
| When I say freeze, don't move | Cuando diga «freeze», no te muevas | tpr | Pararse como estatua |
| When I was a baby, I couldn't walk | Cuando era bebé, no sabía caminar | tpr | Gatear y luego caminar |
| When I was two, I couldn't write my name, but now I can | Cuando tenía dos años no sabía escribir mi nombre, pero ahora sí | tpr | Escribir en el aire |
| When it rains, we need boots. | Cuando llueve, necesitamos botas. | leccions | — |
| When the bell rings, we line up | Cuando suena el timbre, nos ponemos en fila | tpr | Ponerse en fila |
| When the conductor stops, we stop | Cuando el director para, nosotros paramos | tpr | Parar con la mano |
| When the drum stops, freeze | Cuando pare el tambor, congélate | tpr | Bailar y parar con el silencio |
| When the music stops, hide | Cuando pare la música, escóndete | tpr | Bailar y esconderse |
| When the sun shines through the rain, we see a rainbow | Cuando el sol brilla en la lluvia, vemos el arcoíris | tpr | Dibujar un arco |
| When the timer rings, we swap | Cuando suene el temporizador, cambiamos | tpr | Cambiar a la señal |
| Where are we on the map? | ¿Dónde estamos en el mapa? | tpr | Señalar el mapa |
| Where are you going? | ¿Adónde vas? | tpr | Abrir las manos y encoger los hombros |
| Where are your toes? | ¿Dónde están tus deditos? | tpr | Buscar los pies en el agua |
| Where did he go? | ¿Adónde fue? | tpr | Esconder el títere |
| Where did I go? | ¿Dónde estoy? | tpr | Esconderse detrás de una almohada |
| Where does it go? | ¿Dónde va? | tpr | Coger un juguete y mirar alrededor |
| Where does it hurt? | ¿Dónde te duele? | leccions | — |
| Where does rain come from? | ¿De dónde viene la lluvia? | tpr | Señalar las nubes |
| Where does the fox hide? Point with your elbows | ¿Dónde se esconde el zorro? Señala con los codos | leccions | — |
| Where does the river go? | ¿Adónde va el río? | tpr | Seguir con el dedo |
| Where is the light? | ¿Dónde está la luz? | frases | — |
| Where is the shadow? | ¿Dónde está la sombra? | frases | — |
| Where is the squirrel? | ¿Dónde está la ardilla? | tpr | Mirar alrededor con las manos sobre las cejas |
| Where will you go this summer? | ¿Adónde irás este verano? | tpr | Señalar el mapa |
| Where's teddy? | ¿Dónde está el osito? | tpr | Buscar el osito debajo de la manta |
| Where's the birdie? | ¿Dónde está el pajarito? | tpr | Buscar el pájaro con la mano en la frente |
| Where's the monkey? | ¿Dónde está el mono? | tpr | Mirar arriba y abajo buscando un mono |
| Where's the smile? | ¿Dónde está la sonrisa? | tpr | Tapar y destapar la boca sonriendo |
| Where's the sun? | ¿Dónde está el sol? | leccions, tpr | Buscar con la mano en la frente |
| Where's your hand? | ¿Dónde está tu mano? | tpr | Sacar la mano por la manga |
| Where's your nose? | ¿Dónde está tu nariz? | tpr | Buscar la nariz con el dedo |
| Which boat is faster? | ¿Qué barco es más rápido? | tpr | Soplar y comparar |
| Which bus goes to the beach? | ¿Qué autobús va a la playa? | tpr | Señalar el horario |
| Which is the biggest? | ¿Cuál es el más grande? | tpr | Comparar tres cosas |
| Which is the cloth that works? | ¿Cuál es el paño que funciona? | frases | — |
| Which light is the brightest? | ¿Cuál es la luz más brillante? | tpr | Señalar y comparar |
| Which one is blue? | ¿Cuál es el azul? | tpr | Enseñar dos objetos y esperar |
| Which one is heavier? | ¿Cuál pesa más? | tpr | Levantar uno en cada mano |
| Which piece goes here? | ¿Qué pieza va aquí? | tpr | Señalar el hueco |
| Which sense do we use? | ¿Qué sentido usamos? | tpr | Señalar un sentido |
| Which side goes down? | ¿Qué lado baja? | tpr | Señalar un lado |
| Whirl | Dar vueltas | tpr | Girar despacio con el bebé en brazos |
| Whirling | Que gira | tpr | Girar un dedo en el aire |
| Whiskers | Bigotes | 0-2, tpr | Dibujar bigotes en la cara con el dedo |
| Whisper | Susurrar | leccions, tpr | Acercarse a la oreja de quien está al lado y hablar muy bajito, con la boca a la vista |
| Whisper game | Juego del secreto | tpr | Decir algo al oído |
| Whisper the secret word to your friend | Dile al oído a tu amigo la palabra secreta | leccions | — |
| Whisper to me | Dímelo bajito | tpr | Acercar la oreja |
| Whispery | Susurrante | tpr | Hablar con la voz muy bajita |
| Whistle | Silbar | tpr | Poner los labios en forma de «o» y soplar suave |
| Whistle a tune | Silbar una melodía | leccions, tpr | Silbar bajito |
| Whistle sound | Silbido de delfín | tpr | Silbar agudo |
| White sail | Vela blanca | tpr | Abrir los brazos como una vela |
| Who agrees? | ¿Quién está de acuerdo? | tpr | Levantar la mano |
| Who am I? | ¿Quién soy yo? | tpr | Señalarse a uno mismo con cara de misterio |
| Who are you today? | ¿Quién eres hoy? | tpr | Señalar el disfraz |
| Who lives here? | ¿Quién vive aquí? | tpr | Mirar alrededor sorprendido |
| Who runs? | ¿Quién corre? | frases | — |
| Who wants to be captain? | ¿Quién quiere ser capitán? | tpr | Levantar la mano |
| Who's in the mirror? | ¿Quién está en el espejo? | tpr | Señalar el espejo y esperar |
| Who's there? | ¿Quién anda ahí? | tpr | Poner la mano en la oreja y mirar alrededor |
| Who's this? | ¿Quién es este? | tpr | Señalar una foto y esperar |
| Whole | Entero | tpr | Juntar las dos mitades |
| Wholesome | Sano y bueno | tpr | Tocar la barriga contentos |
| Whoosh around | Correr como el viento | tpr | Correr en círculo haciendo «fiuuu» |
| Whoosh! | ¡Fiuuu! | tpr | Mover los brazos como el viento |
| Whose turn is it? | ¿De quién es el turno? | leccions, tpr | Mirar alrededor |
| Why are you putting the bandage? Because the cat is sick. | ¿Por qué le pones la venda? Porque el gato está malito. | leccions | — |
| Why do we wash our hands? | ¿Por qué nos lavamos las manos? | tpr | Encoger los hombros preguntando |
| Wide | Ancho, ancha | tpr | Abrir mucho las piernas y los brazos |
| Wide awake | Bien despierto | tpr | Abrir mucho los ojos |
| Wide-eyed | Con los ojos abiertos | tpr | Abrir mucho los ojos sorprendidos |
| Wider | Más ancho | tpr | Abrir los brazos más |
| Wiggle | Menear | tpr | Menear las caderas de un lado a otro |
| Wiggle hips | Menear las caderas | tpr | Menear las caderas riendo |
| Wiggle your fingers | Mueve los dedos | tpr | Mover los dedos en el aire como si tocaran el piano |
| Wiggle your tail | Menear la cola | tpr | Menear la cola del disfraz |
| Wiggly | Inquieto | tpr | Mover todo el cuerpo |
| Wild | Salvaje | tpr | Moverse con fuerza como un animal del monte |
| Wild and free | Salvaje y libre | tpr | Correr con los brazos abiertos |
| Wild wind | Viento fuerte | tpr | Mover los brazos con fuerza |
| Will it be light? | ¿Será ligera? | frases | — |
| Will it float? | ¿Flotará? | tpr | Echar un objeto y esperar |
| Will it roll? | ¿Rodará? | tpr | Empujar y mirar |
| Will you have tried blue by then? | ¿Habrás probado el azul para entonces? | frases | — |
| Win | Ganar | tpr | Levantar los brazos |
| Win or lose, we have fun | Ganando o perdiendo, nos divertimos | tpr | Sonreír y darse la mano |
| Wind turbine | Aerogenerador | tpr | Girar los brazos |
| Winding | Serpenteante | tpr | Mover la mano en zigzag |
| Windmill | Molino | tpr | Girar los brazos como un molino |
| Window pane | Cristal | 0-2, tpr | Seguir una gota en el cristal |
| Wings up, wings down | Alas arriba, alas abajo | tpr | Subir y bajar los brazos |
| Wingspan | Envergadura | tpr | Estirar los brazos al máximo |
| Winner | Ganador | tpr | Levantar los brazos contentos |
| Winning | Ganando | tpr | Sonreír y dar palmas |
| Winter | Invierno | leccions, tpr | Abrazarse a uno mismo con frío |
| Wipe | Secar | tpr | Secarse la cara con una toalla imaginaria |
| Wipe clean | Limpiar | tpr | Pasar el paño por la cara |
| Wipe hands | Limpiarse las manos | tpr | Limpiarse las manos con una servilleta |
| Wipe the table | Limpiar la mesa | tpr | Pasar el paño por la mesa |
| Wipers | Limpiaparabrisas | tpr | Mover los brazos como limpiaparabrisas |
| Wish | Desear | leccions, tpr | Cerrar los ojos y cruzar los dedos |
| With Grandma | Con la abuela | tpr | Coger la mano de la abuela |
| With music | Con música | tpr | Bailar únicamente mientras suena la música |
| With the drum | Con el tambor | tpr | Caminar al pulso de un tambor imaginario |
| With the wind | Con el viento | tpr | Correr con los brazos abiertos |
| Wobble | Tambalearse | tpr | Tambalearse como una gelatina |
| Wobble and hold | Tambalearse y aguantar | tpr | Tambalearse sin caer |
| Wobble board | Tabla de equilibrio | tpr | Balancearse encima de la tabla |
| Wobbly | Bamboleante | tpr | Bambolear todo el cuerpo como una medusa |
| Wobbly bridge | Puente que se tambalea | tpr | Caminar con equilibrio |
| Wobbly bubble | Burbuja temblorosa | tpr | Mover las manos temblando |
| Wobbly jelly | Gelatina temblorosa | tpr | Mover el plato para que tiemble |
| Wobbly legs | Piernas temblorosas | tpr | Temblar las piernas |
| Wobbly tooth | Diente que se mueve | tpr | Tocar un diente con la lengua |
| Wobbly tower | Torre que se tambalea | tpr | Mover la torre con cuidado |
| Wolf costume | Disfraz de lobo | leccions, tpr | Ponerse las orejas de lobo |
| Wonderful | Maravilloso, maravillosa | tpr | Abrir los brazos y mirar alrededor con admiración |
| Wooden | De madera | tpr | Golpear la mesa |
| Wooden block | Bloque de madera | tpr | Poner una pieza encima de otra |
| Wooden plank | Tabla de madera | tpr | Llevar una tabla entre dos |
| Wooden spoon | Cuchara de madera | tpr | Golpear la cuchara de madera en una olla |
| Wooden top | Trompo de madera | tpr | Hacer girar el trompo |
| Woodlouse | Cochinilla | tpr | Hacer una bola con el cuerpo |
| Woodpecker | Pájaro carpintero | tpr | Golpear con el dedo como un pájaro carpintero |
| Woof | Ladrar | tpr | Hacer «guau» con suavidad |
| Woof, woof! | ¡Guau, guau! | tpr | Poner las manos como patas y decir «guau, guau» |
| Wool | Lana | 0-2, tpr | Acariciar la lana de una manta |
| Woolly | De lana | tpr | Acariciar una prenda de lana imaginaria |
| Woolly hat | Gorro de lana | tpr | Tocar el gorro de lana |
| Woolly lamb | Cordero lanudo | tpr | Acariciar la lana de un cordero de peluche |
| Word | Palabra | tpr | Llevar la mano de la boca hacia delante al decir una palabra |
| Worry doll | Muñeca quitapenas | tpr | Susurrar a una muñeca |
| Wrap | Envolver | tpr | Envolver un regalo imaginario con papel |
| Wrap in a towel | Envolver en la toalla | tpr | Envolver al bebé y abrazarlo |
| Wrap up | Abrigar | tpr | Envolver al bebé en la manta |
| Wrapping paper | Papel de regalo | 0-2, leccions, tpr | Arrugar papel de regalo |
| Wreath | Corona de flores | tpr | Hacer un círculo con las manos |
| Wriggle | Retorcerse | tpr | Retorcer los brazos como los de un pulpo |
| Wriggle toes | Mover los deditos | tpr | Mover los deditos en la arena |
| Wriggly | Que se retuerce | tpr | Retorcer el cuerpo |
| Wring out | Escurrir | tpr | Retorcer un paño mojado |
| Wrinkly | Arrugado, arrugada | tpr | Arrugar la nariz y la frente |
| Wrist | Muñeca | 0-2, tpr | Rodear la muñeca con los dedos |
| Write a card | Escribir una postal | tpr | Hacer que se escribe |
| Write a thank-you note | Escribir una nota de agradecimiento | tpr | Escribir en el aire |
| Write down | Anotar | tpr | Escribir en el aire |
| Write your name | Escribir tu nombre | tpr | Escribir en el aire |
| Xylophone | Xilófono | 0-2, leccions, tpr | Golpear las teclas del xilófono |
| Yawn wide | Bostezar mucho | tpr | Bostezar como un hipopótamo |
| Yellow duck | Pato amarillo | 0-2, tpr | Flotar el pato amarillo |
| Yes, please | Sí, por favor | leccions, tpr | Asentir con la cabeza y extender la mano |
| Yesterday | Ayer | tpr | Señalar hacia atrás |
| Yesterday the train went slowly. | Ayer el tren fue despacio. | frases | — |
| Yesterday was Monday, today is Tuesday | Ayer fue lunes, hoy es martes | tpr | Señalar atrás y al suelo |
| Yoga mat | Esterilla de yoga | tpr | Extender la esterilla |
| Yoghurt | Yogur | 0-2, tpr | Dar una cucharadita de yogur |
| You and me | Tú y yo | tpr | Señalar a otra persona y luego a uno mismo |
| You are blowing softly. | Estás soplando suave. | frases | — |
| You are happy! | ¡Estás contento! | frases | — |
| You are welcome | De nada | leccions | — |
| You can carry it, can't you? | Puedes llevarlo, ¿verdad? | frases | — |
| You can do it! | ¡Tú puedes! | tpr | Levantar el pulgar |
| You first, then me | Tú primero, luego yo | tpr | Señalar al amigo y a sí mismo |
| You had been looking for the same side. | Habías estado buscando el lado igual. | frases | — |
| You have been listening. | Llevas un rato escuchando. | frases | — |
| You have chosen blue. | Has elegido el azul. | frases | — |
| You have to run fast! | ¡Tienes que correr rápido! | frases | — |
| You must stop. | Tienes que parar. | frases | — |
| You promised to spin it fast. | Prometiste girarlo rápido. | frases | — |
| You said the cat had four legs. | Dijiste que el gato tenía cuatro patas. | frases | — |
| You should walk slowly. | Deberías caminar despacio. | frases | — |
| You think this, but I think that | Tú piensas esto, pero yo pienso aquello | tpr | Señalar a uno y a sí |
| You told me it didn't fit. | Me dijiste que no cabía. | frases | — |
| You were knocking on it. | Estabas llamando en él. | frases | — |
| You're a great friend | Eres un gran amigo | tpr | Levantar el pulgar |
| You're it! | ¡Te pillé! | tpr | Tocar un hombro |
| Younger | Más joven | tpr | Encogerse |
| Your hand in mine | Tu mano en la mía | tpr | Coger la mano del bebé |
| Your hands are cleaner now. | Tus manos están más limpias ahora. | frases | — |
| Your shadow is big! | ¡Tu sombra es grande! | frases | — |
| Your shadow might have grown. | Tu sombra puede haber crecido. | frases | — |
| Your turn | Tu turno | leccions, tpr | Señalar con amabilidad a quien le toca |
| Your turn: give the command to your friend | Te toca: dale la orden a tu amigo | leccions | — |
| Your turn: now you are the sculptor | Te toca: ahora tú eres el escultor | leccions | — |
| Yuck or yum? | ¿Puaj o ñam? | tpr | Poner dos caras |
| Yum yum! | ¡Ñam ñam! | tpr | Hacer «ñam ñam» abriendo la boca |
| Yummy chestnut! | ¡Qué rica la castaña! | tpr | Tocar la barriga y sonreír |
| Zigzag | Zigzag | tpr | Dibujar un zigzag |
| Zip | Subir la cremallera | tpr | Subir una cremallera imaginaria de abajo arriba |
| Zip it up! | ¡Sube la cremallera! | leccions, tpr | Subir la cremallera |
| Zip up | Subir la cremallera | leccions, tpr | Subir la cremallera hasta arriba |
| Zip your coat | Cierra el abrigo | tpr | Subir la cremallera del abrigo imaginario |
| Zipper pull | Tirador de la cremallera | tpr | Coger el tirador y subirlo |
| Zippy | Rapidísimo | tpr | Pasar la mano muy rápido |
| Zoom | Ir a toda velocidad | tpr | Mover los brazos como un coche rápido |
| Zoom through space | Volar por el espacio | tpr | Correr con los brazos estirados |
| ¡Buenos días, hola! | ¡Buenos días, hola! | 0-2-cancion | — |
