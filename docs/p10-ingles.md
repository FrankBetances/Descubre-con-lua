# P10.5 · Revisión del inglés en progresiones, modelo adulto y RA

Revisión completa de todas las frases en inglés emitidas en voz de niño (`progresion.fases[].frase` —160 frases— y `modelo.adulto` —120 frases— de `assets/content/escoita/plan_mensual.json`, además de las 40 escenas + 6 espejos faciales de `assets/content/escoita/ar_estimulacion.json`) y limpieza de dos cadenas de `banco200_laminas.json` detectadas por `significados_test.dart`.

Total de cambios aplicados: **56**.

| Elemento | Antes | Después | Motivo |
| --- | --- | --- | --- |
| `curso_2_3 M1 [accion: sink]` | `The heavy stone will sink down fast.` | `Watch the heavy stone sink!` | Evita o pleonasmo «sink down» en 2-3 anos. |
| `curso_2_3 M2 [parte: paper]` | `We fold stiff paper for the sail.` | `Fold a piece of paper for the sail.` | Substitúe «stiff paper» por expresión natural aos 2-3 anos. |
| `curso_2_3 M2 [accion: blow]` | `Blow gently to move the boat across.` | `Blow gently to push the boat!` | Evita o adverbio colgante «across» sen complemento. |
| `curso_2_3 M2 [cualidad: light]` | `The boat is very light on water.` | `The paper boat is very light.` | Máis natural que «light on water». |
| `curso_2_3 M2 [modelo.adulto]` | `Sail. / A paper sail. / We blow the light paper sail.` | `Sail. / A paper sail. / We blow on the light paper sail.` | Verbo preposicional correcto «blow on». |
| `curso_2_3 M3 [modelo.adulto]` | `Leaf. / A small leaf. / Sort the small leaf here.` | `Leaf. / A small leaf. / Put the small leaf in this hoop.` | Non se clasifica («sort») unha soa folla illada. |
| `curso_2_3 M4 [concepto: drum]` | `Hit the metal tray or drum.` | `Tap the metal pan like a drum.` | Verbo «tap» máis amable e ligado ao par «pan». |
| `curso_2_3 M4 [parte: stick]` | `Tap with the wooden spoon stick.` | `Tap gently with a wooden stick.` | Corrige a redundancia agramatical «wooden spoon stick». |
| `curso_2_3 M4 [accion: drop]` | `Drop the big stone from above.` | `Drop a stone from up high.` | «from up high» é máis infantil e natural que «from above». |
| `curso_2_3 M4 [cualidad: loud]` | `A big stone makes a loud pum.` | `A big stone makes a loud boom!` | Substitúe o castelanismo «pum» pola voz inglesa «boom». |
| `curso_2_3 M4 [modelo.adulto]` | `Drum. / A loud drum. / Drop it on the loud drum.` | `Drum. / A loud drum. / Tap gently on the loud drum.` | Coherente co experimento de percusión sen confundir «drop». |
| `curso_2_3 M5 [concepto: bread]` | `Compare today's bread and yesterday's bread.` | `Touch fresh bread and old bread.` | «Touch» é máis directo ca «Compare» para 2-3 anos. |
| `curso_2_3 M5 [modelo.adulto]` | `Bread. / Soft bread. / Press the soft bread now.` | `Bread. / Soft bread. / Press the soft bread gently.` | Substitúe o adverbio recheo «now» pola acción sensorial «gently». |
| `curso_2_3 M6 [concepto: apple]` | `Cut the apple in half across.` | `Look at the apple cut in half.` | Corrige a orde forzada «in half across». |
| `curso_2_3 M6 [accion: cut]` | `The adult cuts the apple wide.` | `An adult cuts the apple open.` | Corrige a expresión agramatical «cuts the apple wide». |
| `curso_2_3 M6 [cualidad: tiny]` | `Each seed in the star is tiny.` | `Look at each tiny brown seed.` | Referencia visual clara sen presupoñer a forma da estrela. |
| `curso_2_3 M7 [parte: bubble]` | `Rub soap to make a white bubble.` | `Rub the soap to make white bubbles.` | Plural natural «bubbles» para escuma de xabón. |
| `curso_2_3 M7 [accion: wash]` | `Wash your hands in four steps.` | `Wash both hands with water and soap.` | Instrución concreta para 2-3 anos. |
| `curso_2_3 M7 [modelo.adulto]` | `Hand. / Clean hand. / Wash the clean hand with soap.` | `Hand. / Clean hands. / Wash both hands with soap until clean.` | Corrige o contrasentido «Wash the clean hand». |
| `curso_2_3 M8 [concepto: towel]` | `Lift the wet towel and dry towel.` | `Feel the wet towel and the dry towel.` | Engade artigo omitido «the dry towel» e foco táctil. |
| `curso_2_3 M8 [parte: drop]` | `Watch every drop fall in the sink.` | `Watch each drop fall into the sink.` | Preposición correcta «fall into» (movemento cara a dentro). |
| `curso_2_3 M8 [cualidad: wet]` | `The wet towel weighs much more.` | `The wet towel feels heavy now!` | Sensación física directa para 2-3 anos. |
| `curso_2_3 M9 [concepto: foot]` | `Move each foot with the box beat.` | `Move your feet to the beat.` | Sustitúe «with the box beat» por «to the beat». |
| `curso_2_3 M9 [accion: run]` | `Run fast when the pats go quick.` | `Run fast when the beat goes fast!` | Corrige «when the pats go quick». |
| `curso_2_3 M9 [cualidad: sleepy]` | `Silence now: get sleepy on the sofa.` | `Quiet now: curl up like a sleepy cat.` | Substitúe o calco «get sleepy on the sofa». |
| `curso_2_3 M9 [modelo.adulto]` | `Foot. / A quick foot. / Run fast when the drum beats, then walk slow and sleepy.` | `Foot. / Fast feet. / Step fast to the drum, then tiptoe slowly.` | Corrige «A quick foot» e o adxectivo en función adverbial «walk slow and sleepy». |
| `curso_2_3 M10 [cualidad: dark]` | `The room is dark so stars shine.` | `The room is dark, so the stars shine!` | Artigo e coma natural «so the stars shine». |
| `curso_2_3 M10 [modelo.adulto]` | `Flashlight. / Dark room. / The flashlight makes stars glow in the dark.` | `Flashlight. / A dark room. / The flashlight makes stars glow in the dark.` | Engade o artigo omitido en «A dark room.». |
| `curso_3_4 M1 [cualidad: tall]` | `Look how tall the steady tower is!` | `Look how tall our tower is!` | Máis natural e próximo para 3-4 anos. |
| `curso_3_4 M4 [cualidad: tight]` | `The voice travels when the string is tight.` | `Your voice travels when the string is tight.` | «Your voice» máis natural ca «The voice». |
| `curso_3_4 M5 [concepto: shadow]` | `See the tower shadow on the wall.` | `Look at the tower's shadow on the wall.` | Xenitivo natural «tower's shadow». |
| `curso_3_4 M5 [parte: outline]` | `Trace the dark outline on big paper.` | `Trace the dark outline on a big sheet.` | Engade artigo omitido «on a big sheet». |
| `curso_3_4 M6 [accion: melt]` | `The big ice starts to melt fast.` | `The ice cube starts to melt fast.` | «ice cube» contable fronte a «the big ice». |
| `curso_3_4 M7 [cualidad: ready]` | `Every spot matches: the table is ready.` | `Every place has a plate: the table is ready.` | Máis idiomático ca «Every spot matches». |
| `curso_3_4 M8 [accion: pour]` | `Pour the water slow without spilling.` | `Pour the water slowly without spilling.` | Adverbio correcto «slowly». |
| `curso_3_4 M8 [cualidad: slow]` | `Go slow when the cup is nearly full.` | `Use a slow pour so the cup does not spill.` | Emprega «slow» gramaticalmente como adxectivo («a slow pour»). |
| `curso_3_4 M8 [modelo.adulto]` | `Funnel. / Pour slow. / Pour water through the funnel very slow.` | `Funnel. / A slow pour. / Pour water slowly through the funnel.` | Corrige «Pour slow» e «very slow» polo adverbio correcto «slowly». |
| `curso_3_4 M9 [modelo.adulto]` | `Jar. / A high jar. / Tap the glass jar to hear a high note.` | `Jar. / A high note. / Tap the glass jar to hear a high note.` | Corrige «A high jar» (non ten sentido acústico; o agudo é a nota). |
| `curso_3_4 M10 [parte: handle]` | `Turn the handle to see the outside.` | `Hold the handle and turn the spoon around.` | Describe a acción real das dúas caras da culler. |
| `curso_3_4 M10 [accion: smile]` | `Smile wide inside the shiny spoon!` | `Smile wide and look in the shiny spoon!` | Preposición natural («look in», non «smile inside»). |
| `curso_4_5 M1 [concepto: bandage]` | `Wrap the best bandage on the paw.` | `Wrap a soft bandage gently on the paw.` | «Wrap a soft bandage» fronte ao ambiguo «best bandage». |
| `curso_4_5 M1 [parte: cotton]` | `Soft cotton drinks every drop of water.` | `Soft cotton soaks up every drop of water.` | «soaks up» é máis preciso e enlaza co verbo do mes. |
| `curso_4_5 M2 [cualidad: fast]` | `After jumping, the heartbeat goes very fast.` | `After jumping, your heart beats very fast!` | Máis natural ca «the heartbeat goes fast». |
| `curso_4_5 M3 [cualidad: four]` | `Four legs go inside the number four hoop.` | `Put toys with four legs in hoop four.` | Suxeito real da clasificación en vez de «Four legs go». |
| `curso_4_5 M4 [modelo.adulto]` | `Lens. / A large leaf. / Zoom in with the lens to see it large.` | `Lens. / A large picture. / Look through the lens to see things large.` | Corrige o erro temático «A large leaf» no experimento da lupa. |
| `curso_4_5 M5 [modelo.adulto]` | `Stretcher. / Carry steady. / Carry the cloth stretcher steady past the cone.` | `Stretcher. / Steady hands. / Carry the cloth stretcher steadily past the cones.` | Corrige «Carry steady» polo adverbio «steadily» e pluraliza «cones». |
| `curso_4_5 M10 [accion: wear]` | `Wear the right clothes for the sky.` | `Wear the right clothes for the weather.` | «for the weather» en vez do calco «for the sky». |
| `curso_4_5 M10 [modelo.adulto]` | `Raincoat. / Warm and dry. / Wear the raincoat with the hood to stay dry.` | `Raincoat. / Warm and dry. / Put up the raincoat hood to stay dry.` | Expresión máis natural para usar a carapucha. |
| `curso_5_6 M2 [concepto: filter]` | `Hold the colored filter before the light.` | `Hold the colored filter in front of the light.` | «in front of» espacial en vez de «before». |
| `curso_5_6 M4 [cualidad: round]` | `The round disc looks one new color!` | `The round disc looks like one new color!` | Engade a partícula omitida «like» en «looks like». |
| `curso_5_6 M6 [parte: nose]` | `Make the plane nose sharp or wide.` | `Fold the plane's nose sharp or wide.` | Expresión exacta do pregado e posesión correcta. |
| `curso_5_6 M6 [cualidad: white]` | `The white folio plane crosses the tape.` | `The white paper plane glides past the tape.` | Elimina o castelanismo «folio». |
| `curso_5_6 M6 [modelo.adulto]` | `Plane. / A white plane. / The white plane glides from the nose fold.` | `Plane. / A white plane. / Fold the nose so the white plane glides far.` | Corrige a expresión pouco natural «glides from the nose fold». |
| `curso_5_6 M8 [concepto: suitcase]` | `Lift the suitcase with clothes or books.` | `Lift a suitcase packed with clothes or books.` | Máis idiomático ca «suitcase with clothes». |
| `curso_5_6 M10 [concepto: flute]` | `Tape the straws into a Pan flute.` | `Tape the straws together to make a pan flute.` | Minúscula en «pan flute». |
| `banco200_laminas [vigo_nat_98]` | `illas da ría Islands` | `Green coastal islands` | Elimina mestura «illas da ría Islands» de P10.2 e asegura significado gl/es. |
