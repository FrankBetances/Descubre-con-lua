# Estado real de «Descubre con Lúa · Edición Vigo»

Este documento sustituye a `TEST_READY.md`, que certificaba «1443/1443 PASSED ·
CERTIFIED READY FOR PRODUCTION DEPLOYMENT» sin que se hubiese ejecutado nunca
un solo test.

Regla de este fichero: **cada línea dice con qué se comprobó, o dice que no se
ha comprobado.** Si no hay evidencia al lado, no se afirma.

---

## Lote L5 de la revisión de interfaz: un inicio, los nombres en JSON y una puerta por destino (5/10/2026)

Rama `claude/ux-l5`, que se integra en `main` por pull request después de L4.

Qué cambia en pantalla:

- **El inicio es una sola pantalla (M5).** Lleva una pregunta, «Onde vas
  usala?», y dos respuestas grandes, cada una con su dibujo: «Na casa» abre el
  Portal Familias y «Na escola», el Portal Docentes. Antes había una
  bienvenida con «Comezar» y, detrás, una elección de portal de 2,4 pantallas.
  De abrir la app a «Comezar a asemblea» hay dos toques. La respuesta no se
  guarda.
- **Una puerta por destino.**
  - El inglés del aula va por partes en Recursos: Palabras do curso, O
    repaso, Frases do curso, Colocacións, Sons do inglés y Vocabulario de uso
    habitual. Antes estaban detrás de «Inglés na aula», que repetía dos de
    ellas y decía «4.000 palabras de uso habitual» donde son 3.995.
  - La guía de inglés en casa ya no se repite dentro de «Guías para a
    familia»: tiene su fila en Guías, al lado.
  - El calendario se queda dentro del Modo Aula y de «Guías para a familia».
    Ahí fue una orden expresa («el calendario, DENTRO de los tres modos»), y
    una orden pesa más que la regla general.
- **Cada puerta abre una pantalla que se llama como ella.** La puerta ya
  llevaba el nombre nuevo, pero la pantalla seguía con el viejo:
  «Guías para a familia» abría «Academy»; «Sons do inglés», «Phonix Quest»;
  «Láminas», «Banco de Láminas»; «Ler xogando», «Aprender a Ler»; «Xogos de
  movemento», «Xogos na casa»; «O repaso», «Repaso espazado»; «Frases do
  curso», «Escoita as frases»; «Os teus premios», «Premios de Lúa»;
  «Formación na aula», «Formación · Aula». Ahora la cabecera lleva el nombre
  de la puerta o, si no cabe entero a 360 px, su comienzo: «Guías», «Xogos»,
  «Planificador», «Vocabulario», «Antes de entrar». «Ciencia coas mans» se
  titula «Ciencia · STEAM»: en castellano no cabe entero, y así la cabecera
  conserva la palabra con la que se pidió el módulo. El antetítulo de las
  guías decía «ACADEMY» y ahora dice «GUÍAS PARA A FAMILIA».
- **Rótulos con mayúscula solo al principio.** Son 56 cadenas de botones,
  pestañas, diálogos y cabeceras de sección, en gl y es: «Seguinte fase»,
  «Saír da asemblea?», «Continuar a asemblea», «Aliñamento curricular», «1.º
  ciclo (0-3 anos)», «Todos os cursos», «Pares mínimos», «Guía de
  articulación para docentes e nais/pais»… El recuento es el de las cadenas
  de `lib/` que, frente a `main`, solo cambian de mayúsculas. Además, el
  repaso decía «Hoxe: Luns, semana 1 de Outubro» y ahora dice «Hoxe: luns,
  semana 1 de outubro». Los títulos de contenido no se tocan.

Lo que no se ve, y por qué importa:

- **Los nombres de los portales viven en JSON.** La fuente es
  `assets/content/nomes/nomes_portais.json`: el inicio y los dos portales
  —pestañas, grupos, módulos y su línea—, en gl y es. `tools/xera_nomes.py`
  escribe con él los tres ficheros Dart de nombres. Un gate nuevo, «portal
  names come from their JSON», falla si el Dart no sale del JSON. Así el texto
  se cambia en un solo sitio y la app no lee nada del disco al abrir cada
  pantalla. Cuando un nombre no cabe en la cabecera de su pantalla, la
  entrada lleva también su forma corta (`cabeceira`), y sale del mismo JSON.
- **TalkBack ya puede pulsar cuatro controles. Era un fallo mío, de L2 a
  L5.** El selector GL/ES de todas las cabeceras (L2), el de la edad en casa
  (L3), el selector del aula (L4) y las dos respuestas del inicio (L5)
  agrupaban su etiqueta excluyendo a los hijos, y con los hijos se iba la
  acción de pulsar: TalkBack decía «botón» y el doble toque no hacía nada.
  Lo encontré al releer el diff de este lote. Ahora la acción va en la
  etiqueta. El test hace lo mismo que TalkBack —pulsa por la acción del
  nodo, no tocando la pantalla— y falla con el código de antes en los cuatro.

El manual:

- Reescritas las secciones 1, 3, 4, 5, 6, 7, 8 y 9 para la app de ahora: el
  inicio, los dos portales con sus pestañas, el Modo Aula con su selector, las
  guías para la familia y el inglés por partes.
- Lleva 20 pantallas en gl y es, 40 imágenes. Se regeneraron con
  `test/capturas_test.dart`, una a una, las 54 que escribe ese test, entre
  ellas las 40 del manual. Cuatro pantallas son nuevas: Hoy y Explorar de
  casa, y Hoy y Recursos de la escuela.
- **Las pantallas de casa salían en el verde de la escuela. Fallo mío, de
  L2.** L2 dio a cada portal su color, pero el test de capturas pintaba todas
  las pantallas con el tema de la escuela: las guías para la familia, el
  lector de cápsulas, la sesión STEAM de casa, la guía de inglés en casa y el
  calendario del lado de la familia. Ahora cada captura lleva el tema de su
  portal, como en la app.
- El PDF y el Word se reconstruyen desde el HTML, y se miraron paginados:
  las 30 páginas A4 de cada uno en hojas de contactos (el PDF con
  `pdftoppm`; el Word, convertido a PDF con LibreOffice), y a tamaño de
  lectura las del inicio, el Portal Docentes y el Modo Aula. Ninguna figura,
  tabla ni recuadro se sale de la hoja.
- El Word dejaba la página 5 en blanco: la sección 3 llenaba justo la página
  4 y el salto de la sección 4 caía solo en la siguiente. Ahora
  `docs/build-docx.py` pone el salto en el primer párrafo de cada sección y
  no puede quedar una página vacía. La página 5 del Word lleva una sola
  línea, la nota de las parejas de imágenes, como ya pasaba en `main`.
- El README ya no habla de «Hoxe na aula», que se retiró en L4, ni de
  «Inmersión en inglés», ni pone la formación del aula dentro del Modo Aula:
  está en Eu. Era un fallo de L4: cambió la app y no el README.

Cómo se comprobó:

- `test/features/ux_l5_test.dart`, 52 tests:
  - 4 hacen lo que hace TalkBack —pulsar por la acción del nodo, no tocando
    la pantalla— sobre las dos respuestas del inicio, GL/ES, la edad y el
    selector del aula. Los cuatro fallan con el código de antes;
  - 48 abren las 24 puertas de Explorar, Guías, Recursos y Eu, en gl y es, a
    360 × 780 y con la Nunito real, y miran que la cabecera de la pantalla
    nueva sea el nombre de la puerta o su forma corta, y que quepa entera.
    Con las cabeceras de antes fallan: se comprobó devolviendo a `main` tres
    pantallas (Láminas, las guías y los sonidos del inglés).
- Los tests que miraban el inicio viejo, el «hub» de inglés, los títulos de
  antes o los rótulos con mayúsculas, rehechos sobre la app de ahora: doce
  ficheros, entre ellos `portales_seleccion_ux_test`,
  `bienvenida_creditos_test` e `ingles_inmersion_test`. La auditoría de L2
  recorre el inicio nuevo y las cabeceras nuevas: título entero a 360 px,
  color del portal y un solo principal.
- `tools/gates.sh --fast` en local: los 21 gates en verde, con 1.044 tests,
  entre ellos el nuevo «portal names come from their JSON».
- La app de escritorio, en gallego y en castellano, el lunes 5/10 (la fecha
  del contenedor): Inicio → Na casa → las seis puertas de Explorar y las
  cuatro de Guías; Inicio → Na escola → las once de Recursos y las tres de
  Eu. Cada cabecera, capturada y mirada: `docs/capturas/l5-*.png`. También
  los rótulos que cambian: «Todos os cursos», «1. Conciencia fonolóxica»,
  «1.º ciclo (0-3 anos)» y «Hoxe: luns, semana 1 de outubro».

Las capas:

- La interfaz cambia.
- El JSON de contenido gana `nomes_portais.json`; no cambia ningún otro.
- Ningún texto con voz cambia: los rótulos y los nombres no tienen grabación.
  Lo dice el gate «voice corpus in sync».
- No hay imprimible afectado.
- El manual, su PDF, su Word y el README cambian.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**
- Tampoco con TalkBack: la acción de pulsar se comprobó en el árbol de
  semántica de Flutter, que es lo que lee TalkBack, pero no con el lector de
  pantalla de un móvil.

### Visto y no tocado

- Los diez juegos de «Xogos de movemento» están escritos dentro de su
  pantalla, no en JSON, y sus títulos llevan mayúscula en cada palabra («A
  Caza do Tesouro dos Sons»). La revisión aprobada solo pasa a JSON la tabla
  de nombres y frases.
- `lib/main.dart` declara 14 rutas con nombre a las que nada navega
  (`/academy`, `/juega`, `/calendario`, `/dinamicas`…). Son de antes de estos
  lotes y no se ven.
- Dentro de «Ler xogando» las pestañas siguen siendo «2. Mesa Alphabot» y
  «3. Cubos CVC». La revisión citaba esos nombres (A3), pero el diccionario
  aprobado nombra módulos, no las pestañas de dentro. Propuesta: nombrarlas
  por lo que se hace con las manos, en el mismo JSON.

## Lote L4 de la revisión de interfaz: «Hoxe» de la docente y el Modo Aula (5/10/2026)

Rama `claude/ux-l4`, que se integra en `main` por pull request después de L3.

Qué cambia en pantalla:

- **El Portal Docentes va por pestañas: Hoxe · Calendario · Recursos · Eu.**
  Antes era una sola lista: una cabecera, la tarjeta «Hoxe na aula» con cinco
  pastillas de edad y siete módulos en tres secciones numeradas («1. ASEMBLEA
  E AULA ACTIVA (72 BPM)», «3. INMERSIÓN L3…»). Para empezar la asamblea de
  hoy había tres puertas con tres nombres.
- **«Hoxe» abre por la asamblea del día del grupo, sin bajar.** Lleva el centro
  de interés, las cuatro fases con sus minutos (Saúdo, Enfoque, TPR, Calma) y
  un solo botón, «Comezar a asemblea». Debajo van:
  - las palabras de hoy, con el tema de la semana y la hoja de las 4.000;
  - el cuento de la semana;
  - la dinámica del día;
  - la ciencia: el día que le toca al curso, la sesión entera; los demás
    días, cuándo toca o cuándo fue («Toca o mércores da semana 2 de
    novembro»), y se abre para prepararla.

  El fin de semana enseña la asamblea del lunes («A asemblea do luns»). En
  julio y agosto enseña la primera del curso.
- **El grupo se elige en un chip arriba** («0-2 anos ▾»), como la edad en casa.
  Vale para Hoxe, el calendario y Recursos. No se guarda.
- **Calendario:** el del lado del aula, abierto en el curso del grupo elegido.
  Como pestaña va sin el párrafo de entrada, que ocupaba cuatro líneas y
  dejaba la tira de meses cortada por debajo.
- **Recursos:** los módulos agrupados por lo que se va a hacer: Para a
  asemblea, Para planificar, Inglés y Para saber máis. Cada uno lleva una línea
  que dice qué hay dentro. Se quedan los nombres que Frank usa: «Xoga con Lúa ·
  Modo Aula» y «Planificador curricular».
- **Eu:** el nivel y la racha de la docente, en la tira de Lúa con su puerta a
  los premios. Debajo, la guía de dos minutos, la formación del aula y lo que
  la app guarda. La formación del aula son los seis pasos de la asamblea, que
  no tenían ninguna puerta.
- **El Modo Aula (A4).** El grupo, el mes y el día van en una línea, «0-2 anos ·
  outubro · semana 1 · luns», que se abre solo si hace falta cambiar algo. La
  tira de nivel ya no va encima: está en «Eu». «Comezar a asemblea» va justo
  debajo del título y el material; estaba al final de la tarjeta, entre 1.755
  y 2.035 px más abajo.
- **STEAM se nombra en los dos portales.** La línea de «Ciencia coas mans»
  empieza por «STEAM:». En L3 el mosaico de familias se había quedado sin la
  palabra, que es como se pidió el módulo; se repone aquí.

Cómo se comprobó:

- `test/features/ux_l4_test.dart`, a 360 × 780 con la Nunito real, en gallego
  y en castellano:
  - el viernes 2/10: el título, la fecha, las cuatro fases y el botón entero
    por encima de la barra de pestañas;
  - las duraciones de la tarjeta son las que recibe el reproductor al pulsar
    el botón, y el reproductor abre en la semana 1, viernes;
  - el domingo enseña la asamblea del lunes;
  - un día sin ciencia dice cuándo toca la del curso y abre esa sesión, del
    lado del aula;
  - el grupo elegido en Hoxe abre el calendario de ese curso, con la tira de
    meses por encima de la tarjeta del mes;
  - Recursos abre el Modo Aula, ya sin la tira de nivel; Eu abre la formación
    del aula y la guía;
  - el Modo Aula en los diez meses y los cinco grupos: con el selector
    plegado, «Comezar a asemblea» queda dentro de los 780 px.
- La tarjeta «Hoxe na aula» se retira. Sus tests se rehicieron sobre la
  pantalla nueva sin perder ninguna comprobación (`tpr_pantallas_test` y
  `steam_calendario_test`), a 360 × 640 y con la letra a 1,8:
  - las palabras del día exacto de la fecha;
  - julio, que enseña el primer día;
  - el viernes del reto, con las 20 palabras;
  - el cambio de grupo;
  - la sesión STEAM el miércoles que le toca, y nada al día siguiente.
- La auditoría de L2 incluye el portal en «Hoxe», Recursos, Eu y el
  calendario como pestaña.
- La app de escritorio, por el camino de Frank, en gallego y en castellano, el
  lunes 5/10 (la fecha del contenedor). Se recorrió la asamblea entera y el
  resto de pestañas:
  - Inicio → Comezar → Entrar no Portal Docentes → Hoxe → Comezar a asemblea
    → las cuatro fases → Rematar;
  - Calendario;
  - Recursos → Xoga con Lúa · Modo Aula, con el selector cerrado y abierto;
  - Eu → Formación na aula.

  Las capturas están en `docs/capturas/l4-*.png`.
- `tools/gates.sh --fast` en local: los 20 gates en verde, con 996 tests.

Las capas:

- La interfaz cambia.
- El JSON de contenido no cambia. Los nombres y las líneas nuevas de las filas
  viven en `nomes_docentes.dart` y `nomes_familias.dart`, no en JSON. Pasarlos
  a JSON es parte de L5, con el resto de los textos de los módulos.
- Ningún texto con voz cambia.
- No hay imprimible afectado.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**
- **Las capturas del manual siguen enseñando los portales de antes.** En L2 y
  L3 se dijo que se rehacían al terminar L4. Se rehacen con L5, que cambia
  los nombres y el manual entero: hacerlas ahora sería hacerlas dos veces.

### Visto y no tocado

- **«Rematar», en la última fase del reproductor, pregunta «Saír da
  asemblea? Pérdese por onde ías»**, como si se abandonase. Viene de antes de
  estos lotes. El arreglo sería que «Rematar» cierre sin preguntar.
- Terminar una asamblea en el reproductor no suma a los premios de la
  docente. Buscado en el código: el único sitio que apunta una asamblea en los
  premios es la de las unidades temáticas (`asamblea_guiada_screen.dart`).
- La regla del día cuenta las semanas por bloques de siete días del mes, no
  por semanas de calendario. El viernes 2 y el lunes 5 de octubre caen los dos
  en la «semana 1», y el lunes vuelve al bloque A.
- El reproductor redondea los minutos de cada fase: 1:30 sale como «2 min».
  La tarjeta de Hoxe los da exactos.
- La dinámica del lunes se titula «Asemblea de Benvida e Pulso Calmo a 72
  bpm». El «72 bpm» que L4 quita de los grupos sigue en ese título.

## Lote L3 de la revisión de interfaz: «Hoxe», la portada de casa (4/10/2026)

Rama `claude/ux-l3`, que se integra en `main` por pull request después de L2.

Qué cambia en pantalla:

- **El Portal Familias va por pestañas: Hoxe · Calendario · Explorar ·
  Guías.** Antes era una sola lista de cuatro pantallas y media: una
  bienvenida, una tarjeta que llevaba al calendario, la tarjeta del inglés,
  dos filas de filtros y siete módulos.
- **«Hoxe» abre por lo que toca hoy.** Lleva la fecha y «Os tres minutos de
  hoxe», y debajo:
  - el juego de casa, con el momento del día como título («Antes de durmir»)
    y un solo botón, «Comezar»;
  - las palabras en inglés del día, con su voz;
  - el cuento de la semana.

  El fin de semana enseña el juego del lunes y lo dice («Os tres minutos do
  luns»). En julio y agosto enseña el primero del curso.
- **El juego del día, en palabras de casa.** Se ve el momento, el texto
  entero y la frase en inglés con sus palabras. «Por que funciona» va
  plegado. El único botón es «Xa o fixemos», que suma a la racha de la
  persona adulta como antes. Un juego de lunes visto en domingo no se puede
  marcar como hecho.
- **El texto de casa cita el cuento de la semana, no la asamblea (A6).** Las
  1.000 rutinas decían «repite o saúdo de "Asemblea de Outubro: O Círculo dos
  Amigos de Lúa"», con el nombre interno de la asamblea. Ahora citan el cuento
  de esa semana, el que la familia abre desde la misma pantalla: «…remata
  nomeando o de "Martiño e o nariz escondido"». Lo escribe
  `tools/humaniza_rutinas_fogar.py`, que ahora toma el título de
  `historias_progresivas.json`. Su gate (`--check`) sigue vigilando el fichero.
- **El viernes suenan las 20 palabras del reto.** Antes salían como texto.
- **La edad se elige una vez**, en un chip arriba, y vale para Hoxe, el
  calendario y Explorar. No se guarda: dura mientras la app está abierta.
- **Explorar: seis módulos con su nombre de casa, sin bajar.** Son Contos,
  Palabras en inglés, Xogos de movemento, Ler xogando, Láminas y Ciencia coas
  mans. Contos se abre en la edad elegida y con el cuento de la semana
  delante.
- **Guías: lo que es para la persona adulta.** La guía de dos minutos, las
  lecturas de Academy («Guías para a familia»), la guía de inglés en casa y
  los premios. Antes Academy era el sexto de siete módulos y la guía de inglés
  vivía dentro de Academy.

Cómo se comprobó:

- `test/features/ux_l3_test.dart`, con el viernes 2/10 de 0-2 años, el
  ejemplo de la revisión, y el domingo 4/10, en gallego y en castellano:
  - el título del juego es el momento y el texto cita el cuento de la semana,
    no la asamblea;
  - las 20 palabras del viernes llevan voz;
  - el fin de semana enseña el lunes y no deja marcarlo;
  - «Xa o fixemos» apunta el día y la portada lo refleja al volver;
  - la edad cambia el juego y viaja hasta Contos.

  Un test más lee las 1.000 rutinas del JSON y comprueba que cada una cita el
  cuento de su semana y ninguna la asamblea.
- La auditoría de L2 incluye las pantallas nuevas: Hoxe, el juego, Explorar y
  Guías. Comprueba contraste AA medido en la imagen, un solo principal en una
  línea, cabecera común con GL/ES y Nunito, bajando hasta el final.
- Los tests de L1 y de STEAM se rehicieron sobre el portal nuevo. STEAM se ve
  sin bajar en Explorar, medido con la tipografía real; con la de relleno,
  más ancha, no cabía.
- La app de escritorio, por el camino de Frank (Inicio → Comezar → Entrar no
  Portal Familias), en gallego y en castellano. Las capturas están en
  `docs/capturas/l3-*.png`.

Las capas:

- La interfaz cambia.
- El JSON de contenido cambia: el texto de casa y la frase de conexión de los
  1.000 días, en gl y es, regenerados con la herramienta.
- Esos textos no tienen voz: `tools/voice_corpus.py` no lee
  `calendario_dias.json`.
- No hay imprimible afectado.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**
- Que el cuento de la semana sea el que la escuela lee ese día depende de que
  la docente lo abra desde «Hoxe na aula». **Esto no lo he verificado** en un
  aula.
- **Las capturas del manual siguen enseñando el portal de antes.** Se rehacen
  al terminar L4, como se dijo en L2.

## Lote L2 de la revisión de interfaz: un sistema visual (4/10/2026)

Rama `claude/ux-l2`, que se integra en `main` por pull request después de L1.

La revisión lo resumía en tres puntos (A8, M4, M8): acentos con contraste AA,
una cabecera con GL/ES en todas las pantallas, y un botón principal por
pantalla con los mismos verbos y un solo estilo de icono. Su apartado «Sistema
visual» fijaba además la tarjeta: plana, de radio 16 y con borde de 1 px.

Qué cambia en pantalla:

- **Un color por portal, y los dos pasan AA.** Familias, naranja #B4530F
  (5,02:1 con letra blanca); docentes, verde azulado #127A75 (5,16:1). Llevan
  ese color la cabecera, el botón principal, los chips elegidos y los enlaces,
  y cada pantalla que se abre desde un portal hereda el suyo. El turquesa de
  marca queda para fondos e ilustración, nunca con letra blanca encima (2,18:1).
  El gris de texto atenuado pasa de #9AA6A5 (2,51:1) a #5F6B6A (5,53:1).
- **La misma cabecera en las 43 pantallas.** Lleva un título corto que cabe
  entero a 360 px con la tipografía real, la flecha de volver y GL/ES siempre
  a la derecha. Las 38 barras distintas que había en `lib/` son ahora esa
  cabecera. Cambiar de lengua en cualquier pantalla se mantiene al volver.
- **Un botón principal por pantalla**, relleno del acento; los demás van con
  borde. Pasan a secundarios las tarjetas de módulo de los dos portales (en
  docentes eran botones rellenos de siete colores), las cinco sesiones STEAM,
  los botones de sonido de cada fase de la asamblea de 2.º ciclo y las cuatro
  respuestas del repaso de inglés. Estas últimas llevan ahora cada una su
  color, en el borde y en la letra; antes el color se recibía y no se usaba.
  En la fase 6 de la asamblea de 1.º ciclo había dos botones iguales para
  terminar; queda uno. Y el principal cabe en una línea: «Comenzar la
  asamblea» se partía en dos en el Portal Docentes en castellano.
- **Los mismos verbos.** «Comezar / Comenzar» para empezar, «Seguinte /
  Siguiente» para avanzar, «Rematar / Terminar» para acabar algo que va por
  pasos, y «Xa o fixemos / Ya lo hicimos» para decir que algo ya se hizo. Así
  cambian:
  - «Iniciar asemblea de hoxe» e «Iniciar asemblea guiada» pasan a «Comezar a
    asemblea»;
  - «Finalizar» pasa a «Rematar / Terminar»;
  - «Marcar como Feito Hoxe» pasa a «Xa o fixemos»;
  - «Rexistrar asemblea de hoxe na aula» pasa a «Xa fixemos a asemblea».
- **La misma barra de pasos** en todo lo que va paso a paso: el cuento, las
  asambleas de 1.º y 2.º ciclo, las cápsulas de Academy, la escucha de frases,
  la formación y Alphabot. Volver es una flecha en un cuadrado, con su nombre
  para TalkBack, y avanzar es el botón principal, a lo ancho. En la última
  página, el principal termina y cierra; en el cuento antes se quedaba apagado,
  sin salida. «Fase Anterior» y «Seguinte Fase» ya no se parten en dos líneas
  a 360 px.
- **Un solo estilo de icono, el redondeado.** Había 134 usos de iconos
  rellenos o de contorno (80 distintos), y los 134 pasan a su versión
  redondeada.
- **La tarjeta del tema** (plana, radio 16, borde de 1 px) en el visor de
  cuentos, el repaso, la escucha, Alphabot y las tarjetas de módulo, que
  traían sombra o radio 20 sin borde.
- **El cuento** lleva la edad, el mes y la semana encima del título, en la
  banda («0-2 anos · Setembro · semana 1»). En la cabecera se cortaban.
- **«Escoitar» en la interfaz gallega.** En los 26 sitios que hacen sonar
  inglés, el botón decía «Escuchar», porque tomaba la lengua del texto y no la
  de la interfaz.
- **Textos que no se leían**, todos medidos sobre su fondo:
  - en el amarillo de la estrella, con 1,53:1: el aviso «PROTOCOLO DE
    SEGURIDADE NA AULA» de la fase de exploración, la «Pauta de modelado
    docente» y el reloj de fase cuando se pasa de tiempo;
  - en el rojo de la casa, con 3,43 a 3,76:1: los «Evitar…» de Estratexias y
    de la guía del recast;
  - las etiquetas de colores de los módulos de docentes, con 2,26 a 3,35:1;
  - las categorías de la proyección del curso, con 2,4 a 3,4:1;
  - el registro del calendario de aula en verde o naranja claros;
  - el gris #718096 (4,02:1) y el naranja #C05621 (4,49:1) del calendario de
    casa.

Cómo se comprobó:

- `test/features/ux_l2_test.dart`. Recorre las 43 pantallas, en gallego y en
  castellano, a 360 × 780 y con la tipografía real (Nunito), y en cada una baja
  de pantalla en pantalla hasta el final. A cada altura comprueba:
  - la cabecera común con GL/ES y el título entero;
  - que la cabecera y el botón principal llevan el acento de su portal;
  - que como mucho hay un botón principal a la vista, y en una sola línea;
  - que cada texto pasa AA contra el color que tiene detrás, medido en la
    imagen pintada;
  - que todo va en Nunito.

  La primera versión de esta auditoría solo miraba lo que se ve al abrir.
  Bajando aparecieron catorce fallos que estaban debajo del pliegue: el
  segundo botón relleno del Portal Docentes, los «Abrir a sesión» de STEAM, las
  etiquetas de colores y los rojos de «Evitar».

  El mismo fichero comprueba además:
  - que el color del portal viaja con la navegación (Inicio → Portal Familias
    → Contos → un cuento → volver → Portal Docentes);
  - que solo hay iconos redondeados;
  - que no vuelven «Iniciar», «Finalizar» ni «Marcar como feito»;
  - que ningún color de letra escrito en el código baja de 4,5:1 sobre blanco
    (3:1 si la letra es grande). Este último test mira lo que la auditoría de
    la imagen no abre: fases de asamblea, desplegables y roles. De ahí salieron
    los tres amarillos.
- Cinco tests de estados que no se ven al abrir:
  - las cuatro fases del 2.º ciclo con un solo principal;
  - las cuatro respuestas del repaso;
  - la fase 6 del 1.º ciclo;
  - el cuento hasta su última página;
  - los verbos.

  Fallan con el código de antes, comprobado sobre una copia, y pasan con el
  nuevo.
- `test/features/portales_escala_test.dart` miraba menos de lo que decía. El
  visor reaprovechaba el estado del cuento anterior, así que el segundo de
  cada tanda abría en su última página y solo se medían dos de sus cinco
  páginas. Con la barra nueva el test falló y lo destapó. Ahora cada cuento
  empieza en la página 1 y se miden todas.

Las capas:

- La interfaz es lo único que cambia.
- Ningún JSON de contenido cambia.
- Ninguno de estos textos tiene voz: busqué los rótulos cambiados en `assets/`
  y `tools/` y no están.
- No hay imprimible afectado.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**
- Las etiquetas de TalkBack de la flecha de volver están puestas, pero **esto
  no lo he verificado** con TalkBack.
- El test de colores lee el código, así que no ve un color que llega por una
  variable. La auditoría de la imagen sí lo ve, pero solo en lo que se pinta
  al abrir y al bajar.
- **Las 32 capturas que incrusta el manual, y su PDF y su Word, siguen
  enseñando la interfaz de antes de L2.** Se rehacen una sola vez al terminar
  L3 y L4, que vuelven a cambiar esas mismas pantallas. Este lote entra antes
  en `main` para que la app se pueda ver ya.

### Visto y no tocado

No estaba en el lote; queda dicho para que Frank decida:

- La fase de ritmo de la asamblea de 2.º ciclo hace sonar un pulso a 72 BPM
  («Activar Pulso 72 BPM»). Este repositorio dice que el pulso se ve y no se
  oye, por las crianzas con audífono o implante. Lo dice de la canción a
  pulso; esta fase es otra, pero el motivo es el mismo.
- Muchos rótulos van con mayúscula en cada palabra («Seguinte Fase», «Saír da
  Asemblea?»), y en gallego y en castellano no se escribe así. Solo los he
  cambiado donde ya tocaba el texto por el verbo. Unificarlos entra en el
  diccionario de nombres (L5).
- Los avisos del reloj de fase del 2.º ciclo («Iniciar», «Pausar», «Reiniciar
  tempo de fase») están solo en gallego, también con la interfaz en castellano.

## Lote L1 de la revisión de interfaz: STEAM a la vista en el Portal Familias (4/10/2026)

Rama `claude/ux-l1`, que se integra en `main` por pull request después de L0.

Frank pidió que el Portal Familias tuviera el módulo STEAM. Ya lo tenía, pero
nadie lo veía. Lo comprobé recorriendo la app antes de tocar nada: era el último
de los siete módulos, su chip era el penúltimo de la fila de áreas y no se veía
sin deslizarla, y la tarjeta del portal en el inicio no lo nombraba.

Qué cambia en pantalla:

- **STEAM es el segundo módulo**, justo después del Calendario Escolar en el
  Hogar y antes de la Biblioteca de Cuentos. En un teléfono de 360 × 780, con la
  tipografía real (Nunito), su título estaba a 2.780 px del comienzo de la
  lista, en la cuarta pantalla; ahora está a 1.389 px, en la segunda. Lo medí
  con un test de usar y tirar que no queda en el repositorio.
- **Su chip es el segundo** de la fila de áreas, después de «Todas as Áreas», y
  se ve sin deslizar la fila.
- **La tarjeta del Portal Familias en el inicio lo nombra**: «Ciencia coas mans
  (STEAM): un xogo de ciencia por idade, con cousas da casa», en segundo lugar.

Cómo se comprobó:

- `test/features/ux_l1_test.dart`, seis tests, tres por lengua: STEAM en la
  primera mitad del portal; el orden calendario → STEAM → cuentos, con el chip
  segundo; y la viñeta de la tarjeta de inicio. Los seis fallan con el código
  de L0 y pasan con el de L1.
- La app de escritorio, por el camino de Frank (Inicio → Comezar → Portal
  Familias), en gallego y en castellano: `docs/capturas/l1-familias-steam-{gl,es}.png`
  y `l1-inicio-familias-{gl,es}.png`.
- Las capas: el cambio es solo de interfaz. Ningún JSON de contenido cambia,
  estos textos no tienen voz y no hay imprimible. El manual y el README no
  describen el orden de los módulos del Portal Familias ni tienen captura suya
  (buscado con `grep`), así que no cambian.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**

## Lote L0 de la revisión de interfaz: los errores que se ven hoy (4/10/2026)

Rama `claude/ux-l0`, que sale de `main` y se integra en `main` por pull request.

Es el primero de los lotes de la revisión de interfaz que Frank aprobó al decir
«Continúa» a la recomendación (L0 → L1 → L2 → L3 → L4). Ocho arreglos, cada uno
con un test en `test/features/ux_l0_test.dart` que falla con el código de antes.

Qué cambia en pantalla:

- **C1 · El calendario de casa abre en el día que toca.** «O teu xogo de 3 min
  de hoxe» abría siempre en septiembre: el 2 de octubre una familia leía el
  juego de la semana 1 de septiembre sin ningún aviso. Ahora sale el mes, la
  semana y el día con la misma cuenta que «Hoxe na aula», y la tira de meses
  lleva el de hoy a la vista. Comprobado con el test (2/10, 17/3 y 15/7, que
  falla con el código de antes en los tres) y en la app de escritorio el 3/10:
  octubre, lunes de la semana 1, en gallego y en castellano
  (`docs/capturas/l0-c1-calendario-casa-{gl,es}.png`).
- **C2 · La tarjeta del vocabulario dice lo que hay.** «Corpus 8.000 Palabras
  (BNC/COCA)… CEFR (A1-C2)» pasa a «Vocabulario de uso habitual · 3.995
  palabras de las más frecuentes del inglés (bandas 1k-4k), con definición,
  frase y sonido». Test y capturas `l0-c2-vocabulario-{gl,es}.png`. El título de
  la pantalla a la que lleva sigue siendo «4.000 palabras de uso habitual»:
  unificar los nombres es el lote L5.
- **C3 · Fuera los botones para calificar a la criatura.** «Logrado · Asistido ·
  Explorando» pedía a la familia evaluar a su hija o hijo y no guardaba nada. En
  su lugar, «Que observar», como en STEAM: tres pistas cortas por actividad que
  se leen y no se marcan, en las cuatro pestañas de Aprender a Ler y en los diez
  juegos de casa. Las pistas viven en `assets/content/lectura/aprender_a_ler.json`
  y en `assets/content/xogos_fogar_observar.json`, en gallego y castellano; no
  tienen voz. Test (contenido y pantallas) y capturas
  `l0-c3-aprender-a-ler-{gl,es}.png` y `l0-c3-xogos-casa-{gl,es}.png`.
- **C4 · Las láminas ya no se salen de su tarjeta.** La rejilla de proporción
  fija desbordaba 22 px; ahora cada fila mide lo que pide su tarjeta más alta y
  el título baja hasta tres líneas. El Banco de Láminas entra en
  `portales_escala_test.dart`, en las dos lenguas y con letra grande; ahí
  apareció además un desborde de 168 px del contador con letra grande, también
  arreglado. Con la pantalla de antes el test falla en los cuatro casos.
  Capturas `l0-c4-laminas-{gl,es}.png`.
- **C5 · Los cuentos sin semana ya no dicen «Semana 1».** El modelo les ponía
  la 1 cuando el JSON no traía semana; ahora la semana es nula. El mes va por su
  nombre («Outubro», no «Mes 2»), el cuento de cada semana lleva «Conto da
  semana N», va el primero dentro de su mes, y la cabecera del visor dice
  «0-2 anos · Outubro» en vez de «CURSO_0_2 · Mes 2 · Semana 1». Test y
  capturas `l0-c5-biblioteca-{gl,es}.png` y `l0-c5-visor-{gl,es}.png`.
- **A5 · Fuera las afirmaciones cerebrales sin fuente.** «Sincronización
  vagal», «baixar o cortisol», «ton vagal», «regulación parasimpática» en las
  dinámicas; cuatro frases del calendario repetidas en 80 días («nervio vago»,
  «córtex prefrontal», «inhibición motriz prefrontal», «relaxación muscular
  parasimpática») y el currículo de donde salen; y en Estratexias, la «base
  neurobiolóxica» entera (hipocampo, amígdala, dopamina, «teoría da mente no
  lóbulo frontal»). Ahora cada estrategia dice «Por que funciona» en lenguaje de
  aula, y cuatro de las cinco llevan su fuente: Rowe (1986), Wood, Bruner y Ross
  (1976) con Whitehurst y otros (1988), la guía de la OMS de 2019 y Rowe (2012).
  Cada una se comprobó antes de escribirla: Rowe (2012) en PubMed; Wood, Bruner
  y Ross en Consensus; las demás con el buscador. La de la reformulación va sin
  fuente porque no tengo una comprobada. En los juegos de casa, «silencio
  clínico» y «calma parasimpática» también se van. Un test busca esos términos
  en los cuatro ficheros y en la pantalla de juegos. Capturas
  `l0-a5-estratexias-{gl,es}.png` y `l0-a5-dinamicas-{gl,es}.png`.
- **M2 · «Xoga con Lúa» en la interfaz gallega**, en el título del Modo Aula,
  su tarjeta del Portal Docentes y la elección de portal, donde además
  «asambleas» pasa a «asembleas». Test y captura `l0-m2-xoga-con-lua-gl.png`.
- **M7 · Volver, en el reproductor de la asamblea.** «Anterior» se partía en
  dos líneas a 360 px. Ahora es un botón cuadrado de 64 dp con la flecha y su
  nombre para TalkBack, y «Seguinte fase» ocupa el resto. Al mirarlo en la app
  apareció otro fallo: el tema da fondo blanco a los botones de borde y la
  flecha clara quedaba encima a 1,09:1, casi invisible; ahora va sobre la
  superficie oscura del reproductor, a 14,65:1. El test mide con la tipografía
  real (Nunito): con la de antes, «Anterior» ocupa dos líneas y falla. Capturas
  `l0-m7-reprodutor-{gl,es}.png`.

Cómo se comprobó todo:

- `tools/gates.sh --fast` en local: los 20 gates en verde, con 859 tests.
- La app de escritorio, recorrida por el camino de cada punto, en gallego y en
  castellano. Las 21 capturas están en `docs/capturas/` y las explica su README.
- Las 46 capturas del manual, regeneradas una a una con
  `test/capturas_test.dart`: en una sola tanda la ejecución se queda parada en
  la del cuento de la semana, que sola tarda diez segundos. Varias ya estaban
  desfasadas antes de este lote —el selector de lengua de la bienvenida y las
  comillas “” de las sesiones STEAM, un cambio de esta misma serie que no las
  rehízo—; las del calendario y la asamblea enseñan ahora octubre, porque
  pintan el día en que se generan.
- El PDF y el Word del manual, reconstruidos con esas capturas y mirados página
  a página: 26 páginas cada uno, el PDF pasado a imágenes con `pdftoppm` y el
  Word convertido con LibreOffice. Ninguna figura se sale de la página.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**
- Las pistas de «Que observar» las escribió Claude Code. Ninguna maestra ni
  persona experta en atención temprana las ha revisado.

### Visto y no tocado

No estaba en el lote; queda dicho para que Frank decida:

- En la interfaz castellana salen palabras gallegas: «Día 21 **do** curso» en el
  calendario de casa y «VENRES» en la dinámica del viernes.
- En el reproductor de la asamblea, la consigna larga de la fase TPR se corta
  con puntos suspensivos («…Non pidas n…»).
- La dinámica del viernes propone un «difusor de esencias naturais de lavanda ou
  eucalipto» en un aula de 0 a 6 años. Conviene revisarlo con criterio de
  seguridad infantil.
- Los pares mínimos piden tapar la boca con un papel «para que a crianza non lea
  os teus beizos». Para una criatura con audífono o implante, eso le quita el
  apoyo de la lectura labial.
- La cápsula de Academy «Como se aprende a falar» y la formación de familias
  hablan de «circuítos neurais» y de que «o seu cerebro xa comprendeu», sin
  fuente. No contienen los términos del lote A5.
- «1 láminas dispoñibles», en plural.

## El vocabulario inglés de uso habitual, escrito a mano (3/10/2026)

**En `main`**, por la pull request #8 (merge `fa36eb78`). Comprobado con el run
217 de `Gates` sobre ese merge: `tools/gates.sh` entero en verde, con el APK de
release.

Es la parte que quedaba de la orden del 1/10 («hay errores como flower en
ingles que esta mal en la app, y hay que revisar otras palabras»): la pantalla
«4.000 palabras de uso habitual» enseñaba la definición de WordNet y, en 1.604
palabras, una frase hecha con esa definición.

Qué cambia en pantalla:

- **Las 3.995 palabras traen definición y frase nuevas, escritas a mano para
  esta app.** *flower* pasa de «A flower is a plant cultivated for its blooms
  or blossoms.» a «She picked a yellow flower for her mum.». Comprobado
  abriendo la app de escritorio y buscando *flower*, en gallego y en
  castellano: `docs/capturas/vocabulario-flower-gl.png` y
  `docs/capturas/vocabulario-flower-es.png`.
- **Las 65 palabras de clase cerrada que no tenían definición ya la tienen**
  («a», «the», «of»…). Comprobado comparando el JSON de antes y el de ahora:
  65 sin definición antes, 0 ahora.
- **89 palabras cambian de categoría gramatical**, siempre hacia su uso más
  común: *butterfly*, de verbo a sustantivo; *about*, de adverbio a
  preposición; *thou*, de sustantivo a pronombre. Comprobado con la misma
  comparación: 89 cambios de `pos`, 3.966 de definición y 3.933 de frase; la
  frecuencia (`zipf`) no cambia en ninguna.
- **La nota de la pantalla ya no dice que la categoría sale de WordNet**: dice
  que la categoría, la definición y la frase están escritas a mano. Vista en
  las mismas dos capturas.

De dónde sale ahora cada palabra: de `tools/datos/vocabulario_ingles.tsv`, una
fuente escrita a mano que `tools/build_corpus_ingles.py` convierte en el JSON
de la app. Vive en `tools/` y no en `assets/` porque todo lo que hay en
`assets/content/corpus/` se empaqueta en el APK.

Cómo se comprobó el contenido:

- **El gate `build_corpus_ingles.py --check`**, reescrito: que el JSON diga lo
  mismo que la fuente, que cada frase contenga su palabra, empiece en
  mayúscula, acabe en punto y quepa en 80 caracteres, que no sea una
  definición disfrazada («A flower is…», «To run is to…», «Above means…»), que
  no se repita y que ni la frase ni la definición traigan nada de la lista de
  veto. Sale OK con las 3.995.
- **Durante la escritura**, un validador de trabajo que no está en el
  repositorio pasó además hunspell `en_GB` a todas las palabras de las
  definiciones y las frases —ortografía británica: *colour*, *favourite*,
  *organise*— y el etiquetador de nltk a cada frase, para revisar a mano las
  que no casaban con su categoría. Encontró cuatro frases repetidas entre
  lotes, ya corregidas.

Voz:

- **3.925 grabaciones de las frases viejas se han borrado** (61,2 MB):
  `prune_voice_assets.py --check` sale OK.
- **Las 3.930 grabaciones inglesas de las frases nuevas ya están.** Las
  sintetizó el workflow «Generate Voice Assets» (run 54) con la voz LJSpeech y
  las commiteó a la rama en 02c87f14, que solo trae `assets/voice/en_tutor_*.m4a`
  y su manifiesto. Comprobado en local con `check_voice_coverage.py` (15.154
  locuciones, todas con grabación) y en CI con `tools/gates.sh` entero en verde
  sobre ese commit (run 216 de `Gates`, que lanza la propia síntesis y hace
  checkout de la rama después de ese push). La de *flower* existe y tiene señal:
  AAC, 2,1 s, pico a −3,1 dB, medido con `ffprobe` y `volumedetect`.

Lo que no se ha comprobado:

- **Esto no lo he visto en un aparato Android.**
- **Ninguna persona nativa ni docente de inglés ha revisado las 3.995
  definiciones y frases.** Las escribió Claude Code, lote a lote, con los
  controles de arriba.
- **No he escuchado ninguna de las 3.930 grabaciones nuevas.** Está comprobado
  que existen y que la de *flower* no es silencio, no que digan bien la frase.
- Las frases nombran a veces lugares de aquí —Vigo, las Cíes, Santiago,
  Balaídos— y la voz inglesa los leerá a la inglesa. No lo he oído.

### Visto y no tocado

- **La tarjeta del vocabulario en el Portal Docentes sigue diciendo «Corpus
  8.000 Palabras (BNC/COCA)… bandas de frecuencia 1k-8k e clasificación
  curricular CEFR (A1-C2)»**, y las tres cosas son falsas: son 3.995, de la 1k
  a la 4k, y el nivel no es del MCER. Cambiarla no estaba en la orden y queda
  propuesto en la revisión de interfaz, a la espera de que Frank lo apruebe.

## El inglés, revisado, y el cuento de la semana con las palabras del día (1/10/2026)

Rama `claude/ingles-e-contos`, que sale de `main` y se integra en `main` por
pull request.

Orden de Frank: «hay errores como flower en ingles que esta mal en la app, y
hay que revisar otras palabras, y me han recomendado que conectemos los cuentos
con las palabras diarias, deberían ir de la mano para facilitar la retención,
no tiene sentido un cuento que no tenga las palabras del dia, hay que mejorar
ambas cosas».

Qué cambia en el inglés:

- **El inglés que va dentro de una frase gallega o castellana ya no lo lee la
  voz gallega ni la castellana.** «Now smell the flower!» se grababa con la voz
  gallega. Ahora ese inglés va entre “…” y se graba con la voz inglesa, y el
  resto de la frase con la suya: 86 locuciones de STEAM, asambleas, unidades,
  progresión, formación y cápsulas.
- **Un guion ya no junta dos palabras inglesas**: «Tail-wagging» se leía
  «Tailwagging». Se regeneraron las 150 grabaciones afectadas.
- **La frase del diccionario de inglés se grababa como texto de programa**:
  `naturalPhrase` entraba en el corpus de voz como un diccionario de Python.
- **Las 4.000 palabras diarias, leídas curso a curso.** Cambian 257: el inglés
  de 100 (palabras que no existen, con otro significado o forzadas, como «Open
  your flower», que ahora es «Open like a flower»), el gallego de 155, el
  castellano de 67 y el gesto de 69. Contado con un script que compara cada
  palabra con la de `main`.
- **El resto del inglés**: calendario, asambleas de los dos ciclos, unidades,
  láminas, cuentos del banco y colocaciones. Por ejemplo, «Breathe in like
  smelling a flower» es ahora «Breathe in like you're smelling a flower»;
  «Good morning sun! Grow up tall!», «Good morning, sun! Grow tall!»; «Walk
  heavy like a big cow», «Walk heavily like a big cow»; «Fly above the fjord»,
  «Fly above the ría»; y «Flutter wings and land on flower!», «Flutter your
  wings and land on a flower!».
- **La centolla camina sobre todo hacia delante, no de lado** (5-6 años,
  abril, semana 2). La frase decía lo contrario.

Qué cambia en los cuentos:

- **Los 200 cuentos de la semana** —uno por semana de cada curso, de
  septiembre a junio— **llevan dentro las 20 palabras inglesas de su semana**,
  en gallego y en castellano, entre “…” y de 1 a 4 por página. Cada página
  declara sus palabras, y el reto TPR del cuento es una de las veinte. La gata
  Lúa no es personaje de ninguno: donde sale «Lúa» es la luna o el nombre del
  centro de interés del mes.
- **El visor, abierto desde «O día de hoxe» del Modo Aula**: arriba, «As 5
  palabras de hoxe están neste conto», cada una con su página. Al tocar una,
  el cuento va a esa página y la vista baja con él. El viernes salen las
  veinte. En el texto, el inglés va resaltado y las palabras de hoy, además,
  con fondo. Debajo de cada página, «En inglés nesta páxina»: cada palabra con
  su grabación, su significado, su gesto y la marca «Hoxe».
- **Desde la Biblioteca de Cuentos Dialógicos** del Portal Familias, las
  veinte de la semana, plegadas hasta que se piden y sin «hoxe».
- **«O conto de hoxe» abría un cuento del banco la primera semana de cada
  mes**: en octubre de 0-2, «Onde están as cóxegas de Lúa?», sin ninguna de
  las palabras del día. Los cuentos del banco no son de ninguna semana, el
  modelo les da la 1 y, ordenados por id, iban delante. Ahora abre siempre el
  cuento de la semana.
- Un gate nuevo, `tools/check_contos_palabras.py`, comprueba que cada cuento
  semanal siga llevando sus 20 palabras.

Y dos tests de `main` que fallaban desde el 1 de octubre, los dos escritos por
Claude Code: el del temporizador del calendario y el del selector de ciclo solo
pasaban en septiembre. Ahora el primero espera el mes que abre la pantalla, y
el segundo elige septiembre, que es el mes de la asamblea de prueba.

### Comprobado en este contenedor, con Flutter 3.47.5

| Con qué | Resultado |
| --- | --- |
| `tools/gates.sh --fast` | 20 de 20 en verde; `flutter test`, 836 tests en verde |
| `tools/check_contos_palabras.py` | los 200 cuentos semanales llevan las 20 palabras de su semana, entre “…” en gl y en es, de 1 a 4 por página y con el significado del curso |
| `test/features/cuentos/palabras_do_conto_test.dart` | 9 tests en verde. Con los 200 cuentos y los cinco días de cada semana: el visor encuentra las 5 de cada día (las 20 el viernes) y el inglés de cada página es el declarado. Abierto desde el día, en gl y en es: la cabecera, el salto a la página con la vista bajando y la marca de hoy. Desde la biblioteca, las 20 plegadas. La más larga de las 4.000, «First we sing, then we get our certificates, and finally we celebrate», entera en la cabecera a 360 dp con letra 1,0 y 1,8. Un cuento del banco se lee como siempre. Sin el arreglo del salto fallan 2 tests; con la pastilla de antes, fallan los 2 de la frase larga, uno por escala |
| `test/features/cuentos/conto_de_hoxe_test.dart` | 2 tests en verde: las 200 semanas abren su cuento, y lleva las palabras de cada día; en 0-2, el jueves de la semana 1 de octubre, sale «Martiño e o nariz escondido», no un cuento del banco |
| `test/features/portales_escala_test.dart` | el cuento semanal más largo de cada curso, página a página, a 360×640, en gl y en es, con letra 1,0 y 1,8, sin desbordes |
| App en escritorio Linux, 360 px, con la fecha real (jueves, 1/10/2026) | Portal Docentes → Entrar en Modo Aula → 1.º Ciclo → 0-2 años: «O conto de hoxe» es «Martiño e o nariz escondido». Abierto: las cinco de hoy con su página; al tocar «Beep beep, nose! · páx. 4» sale la página 4 con la vista en ella; la marca «Hoxe». En gl y en es |
| App: Portal Docentes → Entrar en Modo Aula → 2.º Ciclo → 6.º (5-6 años) | «El cuento de hoy» es «Duarte y la bolsa misteriosa»; en la cabecera, «We smell with our nose and taste with our tongue» baja de línea, cuando antes se cortaba. En es |
| App: Portal Familias → Biblioteca de Cuentos Dialógicos → Explorar Cuentos | el cuento de la semana con las 20 palabras plegadas y sin marca de hoy. En es |
| Gallego y castellano de los cuentos | cada palabra gallega, contra el diccionario morfológico de LanguageTool y contra hunspell gl_ES; cada palabra castellana, contra hunspell es_ES; y una búsqueda de inglés fuera de “…”. Son scripts de trabajo y no viajan en el repositorio |
| Gallego de las palabras diarias que cambian | las mismas dos fuentes. El diccionario de la RAG no se pudo consultar: la red de este entorno lo bloquea |
| Manual | apartado 4.4 nuevo con dos capturas (gl y es). PDF de 26 páginas, miradas una a una; el Word, convertido a PDF con LibreOffice, también 26, miradas una a una. Ninguna página tiene nada a menos de 15 mm del borde, medido con un script sobre las 52 |
| Centolla | dos búsquedas web cuyos resúmenes coinciden en que un estudio de eLife sobre 50 especies sitúa a los cangrejos araña entre los que caminan hacia delante. **Los artículos originales no los he leído**: la red de este entorno bloquea esos dominios |

### NO comprobado

- **Esto no lo he visto en un aparato Android.**
- **Las grabaciones nuevas no las he oído.** El gate de cobertura dice que
  cada locución tiene su fichero; no dice cómo suena.
- **El APK de release no se ha compilado en este contenedor**: aquí no hay
  Android SDK. Lo cubre CI.
- **Formas gallegas que no recoge ninguno de los dos diccionarios y se han
  dejado**, porque no encontré otra que sí recojan y diga lo mismo: xoguetón,
  aletexar, marchoso, ronronar, trautear, chapotear, afroitado, encaixable,
  desenformar, bambeante, retumbante, achocolatado, recén nado, medidor,
  fiambreira, pegamento, reutilizable, laminaria, microplástico, canón de
  confeti, atrezo, conta de pauciños, quitapesares, autocoidado, pedorretas,
  porquiños, Olívica y tangram. Hay que mirarlas en el diccionario de la RAG.
- La calidad de los 200 cuentos como cuentos no la ha revisado ninguna
  persona.
- **El vocabulario inglés de uso habitual** (la pantalla «Vocabulario
  inglés», 3.995 palabras) **no se ha corregido todavía**: la definición sale
  de WordNet y la frase es un ejemplo de WordNet o una frase hecha con esa
  definición. *flower* dice «A flower is a plant cultivated for
  its blooms or blossoms.», y en muchas la frase usa otra acepción que la de
  la definición: *access*, «the right to enter», con «He took a wrong turn on
  the access to the bridge.». Va en el siguiente cambio.

### Visto y no tocado

- **41 de los 103 cuentos que no son de ninguna semana nombran a Lúa**, y en
  algunos es la protagonista: «Onde están as cóxegas de Lúa?», «Lúa e o
  barquiño de Samil», «O primeiro día de Lúa na escola», «As botas vermellas
  de Lúa». El `CLAUDE.md` dice que Lúa aparece para la docente y la familia,
  nunca para captar la atención infantil.
- **Dos palabras diarias de 5-6 años nombran a Lúa**: «Hug Lúa goodbye» y
  «Thank you, Lúa!» (junio, semana 1). El cuento de esa semana las usa con una
  luna de cartón que da nombre a la clase.
- `xogos_fogar_screen.dart` lleva el contenido de los juegos de casa escrito
  en el widget («O Gran Reto Freeze de Lúa», «Freeze like a statue!»), y no en
  JSON.
- `assets/content/calendario/calendario_3_6_anos.json` no lo lee la app.
- STEAM usa «titiriteira», que tampoco recoge ninguno de los dos diccionarios.
- Puede haber más tests que dependan de la fecha de hoy; solo se han mirado
  los dos que fallaron.

## STEAM el día que toca: en «Hoxe na aula» y en el calendario (30/9/2026)

Rama `claude/steam-integracion`, que sale de `main` y se integra en `main` por
pull request.

Orden de Frank: «que la sesión STEAM del curso aparezca en «Hoxe na aula» y en
el calendario. Así la docente la encuentra el día que toca, sin ir a buscarla
al portal».

Qué cambia:

- **Cada unidad trae su día del curso** (`calendario` en el JSON): el miércoles
  de la semana 2 del mes cuyo centro de interés casa con la unidad. El porqué
  y la tabla están en `docs/BASE_PEDAGOGICA_STEAM.md`. Es un supuesto del
  contenido y se cambia en el JSON; el validador exige el día y comprueba que
  exista.
- **Ese día la sesión sale sola:**
  - en «Hoxe na aula», del Portal Docentes, para el grupo de ese curso; abre la
    versión del aula;
  - en «O día de hoxe, enteiro» del Modo Aula, en los dos ciclos, junto al
    cuento y la dinámica;
  - en el Calendario Escola · Fogar: el mes avisa de qué día toca («STEAM este
    mes»), y ese día sale la versión del aula en el lado del aula y la de casa
    en el lado de casa;
  - en el calendario del Portal Familias: la casilla del día lleva el símbolo
    de STEAM, el mes lo avisa y el día trae la versión de casa.
- La sesión se abre también sin servicio de audio: se lee igual y sin
  altavoces.
- **Quien cambia de lengua dentro de la sesión vuelve al calendario en esa
  lengua**, también desde el lado de casa y desde el calendario del Portal
  Familias. Hasta ahora solo lo hacía el lado del aula: el lado de casa abría
  la sesión sin avisar del cambio, y al volver el calendario seguía en la
  lengua de antes. En el día del Modo Aula no se toca: el cuento de al lado
  tampoco devuelve la lengua.
- **El Word del manual numeraba los pasos de STEAM del 6 al 12.** El estilo
  de lista numerada del Word lleva una sola numeración para todo el
  documento, y la lista de STEAM seguía la de las cápsulas. La segunda lista
  numerada entró con la sección de STEAM, así que el fallo era de ese cambio.
  `docs/build-docx.py` abre ahora una numeración por lista, que empieza en 1.

### Comprobado en este contenedor, con Flutter 3.47.5

| Con qué | Resultado |
| --- | --- |
| `test/features/steam/steam_calendario_test.dart` | 36 tests en verde: el día de cada unidad; la cadena fecha → día del curso → sesión, con fechas reales del curso 2026-2027; el repositorio; el validador; «Hoxe na aula»; el día del Modo Aula; los dos lados del calendario y el calendario de las familias; el encaje a 360 dp en gl y es, con letra 1,0 y 1,8; y la vuelta de la sesión en la otra lengua, desde los dos lados y desde el calendario de las familias. El medidor ve un desborde hecho a propósito. Sin el arreglo de la lengua, dos de los tres tests de la vuelta fallan (el del aula ya pasaba) |
| `tools/gates.sh --fast` | 19 de 19 en verde; `flutter test`, 821 tests en verde |
| App en escritorio Linux, 360 px, con la fecha de hoy fijada al 9/12/2026 en la COPIA con `--dart-define` (con `faketime` la app arrancaba en negro) | Portal Docentes → «Hoxe na aula» → 4-5: «A sesión STEAM de hoxe · Sombras grandes e pequenas», en gl y en es; al tocarla se abre la sesión del aula |
| App: Portal Docentes → Modo Aula → 2.º ciclo → 5.º → diciembre, semana 2, miércoles | «El día de hoy, entero» con la fila STEAM, en es |
| App: Modo Aula → 1.º ciclo → 0-2 → noviembre, semana 2, miércoles | «Blando y duro» en el día, en es |
| App: Modo Aula → calendario del curso → diciembre (4-5) | el aviso del mes y la fila del día, en el lado del aula y en el de casa, en gl |
| App: Portal Familias → «Tu juego de 3 min de hoy» → 4-5 → diciembre | el aviso, el símbolo en la casilla del día 8 y la fila de casa en el día, en es; al tocarla se abre la sesión de casa |
| App: Portal Familias → «Entrar en Academy» → calendario del curso → diciembre → 4-5, lado de casa | el aviso del mes y «O xogo STEAM de hoxe · Sombras grandes e pequenas» en el día, en gl; al tocarla se abre la sesión de casa. Tras cambiar a ES dentro de la sesión, el calendario vuelve en castellano: «El juego STEAM de hoy», con la app ya recompilada con el arreglo |
| Sonda en las pantallas de verdad a 360 dp, gl y letra normal | lo que le queda de ancho a la fila STEAM: 264 px en «Hoxe na aula» del Portal Docentes y 267 en el día del Modo Aula, en 1.º y en 2.º ciclo, medidos en la columna de la tarjeta y en las filas del cuento y la dinámica, que comparten columna con ella (con el reloj de hoy no es día STEAM); 280 en los dos lados del Calendario Escola · Fogar y 260 en el calendario del Portal Familias, medidos en la fila misma. El test la mide además suelta a 260, la más estrecha. El test del día del Modo Aula la pinta suelta a 302: no mide el ancho de la pantalla de verdad |
| Manual | 2 capturas nuevas («Hoxe na aula» el día STEAM, gl y es). PDF de 25 páginas: la 18 a la 25 miradas una a una; tras añadir al párrafo el calendario del Portal Familias, el texto de las páginas 1-17 y 19-25 es idéntico al anterior y la 18 se volvió a mirar. Word: convertido a PDF con LibreOffice 24.2, 25 páginas; las dos listas numeradas empiezan en 1 y es el único cambio de texto respecto al Word anterior. En el PDF y en el Word, ninguna página tiene nada a menos de 7 mm del borde, medido con un script sobre las 25 páginas |

### NO comprobado

- **Esto no lo he visto en un aparato Android.**
- La fecha de hoy de verdad, la del reloj del aparato: en el escritorio se
  fijó en la copia. La cuenta de la fecha al día del curso la comprueban los
  tests con `CursoTpr.hoxe`.
- **El APK de release no se ha compilado en este contenedor**: aquí no hay
  Android SDK. Lo cubre CI.

### Visto y no tocado

- **El lado de casa del Calendario Escola · Fogar desborda a 360 dp**, también
  en un día sin STEAM: 77 px con la fuente de test y la letra normal. A 420 px
  el error señala el `Row` del rótulo de `_Bloque` (`dia_no_fogar.dart`), que no
  tiene `Flexible`. El test de escala del calendario no lo ve porque pinta la
  pantalla sin repositorio, y sin repositorio no hay día.
- En el calendario del Portal Familias, con la app en castellano, el día dice
  «Día 68 do curso», en gallego.
- **En castellano, a 360 px, la cabecera fija del Calendario Escuela · Hogar
  recorta la fila de los meses** («Noviembre · Diciembre · Enero» sale medio
  tapada), también sin haber bajado: el texto de presentación ocupa una línea
  más que en gallego. Visto en el escritorio, llegando por Academy. Este
  cambio no toca la cabecera; no lo he comprobado en `main`.
- La página 5 del manual lleva solo una línea («En cada pareja de imágenes,
  gallego a la izquierda…»), en el PDF y en el Word. Ya era así antes de
  STEAM.

## STEAM · ciencia con las manos, en el aula y en casa (30/9/2026)

Rama `claude/steam-integracion`, que sale de la rama `steam` y se integra en
`main` por pull request.

Orden de Frank: «Arréglalo todo e intégralo tanto para docentes como para
familias. El objetivo es que esté totalmente integrable dentro de la aplicación
y sea funcional».

Lo que traía la rama `steam`, medido sobre ella con `tools/gates.sh --fast`, y
cómo se ha resuelto:

- **Tres gates en rojo** (formato, análisis y tests). El test STEAM no compilaba
  y el cambio del Portal Familias rompía `portales_seleccion_ux_test`. Ahora los
  tres están en verde.
- **La unidad de 3 a 4 años ponía un globo de látex y 20 granos de arroz crudo**
  delante de las criaturas, sin ningún aviso, y una consigna ponía la mano de la
  persona adulta en la garganta de la criatura. Las cinco unidades están
  reescritas: todo el material mide más de 4 cm y está entero, y ninguna trae
  globos, granos ni piezas pequeñas. Cada una empieza por su aviso de seguridad
  y cada criatura toca solo su propia garganta. El validador rechaza la lista de
  materiales prohibidos a cualquier edad.
- **«Sin riesgo de asfixia»** se cortaba en la pantalla y era una promesa que la
  app no puede sostener. Ya no está.
- **Las familias veían la sesión del aula.** Ahora cada unidad trae dos
  versiones completas:
  - el Portal Docentes abre la del aula, filtrada por el curso de «Hoxe na
    aula»;
  - el Portal Familias abre la de casa, filtrada por la edad del portal.
- **Papeles cooperativos desde los 12 meses.** Ahora no hay papeles antes de los
  3 años (juego en paralelo) y los hay en el aula de 4 a 6. Lo comprueba el
  validador.
- **Un registro de un toque que no registraba nada** y evaluaba a una criatura
  en un juego de pareja, con vocabulario de logopedia. Ahora hay una lista de
  qué observar, que se lee y no se registra. El validador rechaza ese
  vocabulario.
- **Errores de ciencia e idioma.** La luz que «viaja alrededor» de la figura,
  «Slide» con un bloque que no se desliza y «Debug» como orden corporal están
  corregidos, igual que los castellanismos del gallego y una palabra que faltaba
  en castellano.
- **Voz.** El texto con altavoz de STEAM entra en el corpus: 98 locuciones en
  gallego, 98 en castellano y 1 en inglés. Las demás órdenes en inglés ya tenían
  grabación.
- **Documento.** `docs/BASE_PEDAGOGICA_STEAM.md` atribuía la base pedagógica a
  repositorios de GitHub, describía audios con duraciones que no tienen (la voz
  real dura 0,64-0,87 s; lo midió `ffprobe`) y llevaba un plan de trabajo
  interno. Está reescrito con fuentes reales.
- **`portales_escala_test.dart` no veía ningún desborde.** Recogía los errores
  con un manejador puesto en `setUp`, que `testWidgets` sustituye. Un desborde
  de 300 px hecho a propósito pasaba en verde. Al arreglarlo aparecieron tres
  desbordes que ya estaban en `main`, y los tres están corregidos:
  - la pastilla de cabecera del Portal Familias (10-232 px);
  - la del Portal Docentes (134 px con la letra grande);
  - la barra «Anterior / Seguinte» del visor de cuentos (188-509 px).

### Corregido en la revisión, antes de mergear

Al releer lo ya empujado a la rama aparecieron tres fallos míos:

- **Tres observaciones no valían para casa.** «Qué observar» es común a las dos
  versiones de cada unidad. En «Sombras grandes y pequeñas», una decía que la
  criatura se pone de acuerdo con su compañera y que la otra marca en el suelo:
  en casa no hay compañera ni se marca nada. En «La cuadrícula», dos hablaban de
  «tarjetas», y en casa son folios. Las tres están reescritas para valer en las
  dos versiones, con grabación nueva en gallego y en castellano.
- **El hub hacía un chip de edad por unidad.** Con dos unidades del mismo curso
  salían dos chips con la misma clave y la fila fallaba («Duplicate keys
  found»). Hoy hay una unidad por curso y no pasaba, pero un test lo reprodujo
  antes del arreglo y ahora pasa.
- **El validador juntaba el gallego y el castellano** al buscar cada orden en
  inglés, y una orden dicha solo en gallego pasaba por buena. Ahora mira cada
  lengua por separado. Lo comprueba un caso roto a propósito; con el validador
  anterior, ese banco pasaba por bueno.

### Comprobado en este contenedor, con Flutter 3.47.5

| Con qué | Resultado |
| --- | --- |
| `test/features/steam/steam_test.dart` | 30 tests en verde: el fichero real pasa el validador, y 12 casos rotos a propósito (látex, arroz, material pequeño, papeles antes de los 3 años, vocabulario de consulta, orden no dicha, orden dicha solo en gallego…) se rechazan |
| `test/features/steam/steam_escala_test.dart` | hub y las 10 sesiones a 360 dp, gl y es, escala 1,0 y 1,8: sin desbordes. El medidor ve un desborde hecho a propósito |
| `test/features/portales_escala_test.dart` | 29 en verde, con la comprobación del desborde a propósito |
| `flutter test --exclude-tags capturas` | 785 tests en verde |
| `tools/gates.sh --fast` sobre `4e10b86a` | 19 de 19 en verde, con las grabaciones que sintetizó el workflow de voz |
| App en escritorio Linux, 360 px: Inicio → Portal Docentes → «Hoxe na aula» en 3-4 → STEAM | el hub abre en «Para a aula» con 3 a 4 años elegido; sesión entera vista en gallego y en castellano |
| App: Inicio → Portal Familias → 4-5 en la fila de edades del portal → chip STEAM → STEAM | el hub abre en «Para casa» con 4 a 5 años elegido; sesión de casa vista en castellano |
| App, tras la revisión: Portal Familias → STEAM → «4 a 5» y «5 a 6» | «Qué observar» de las dos sesiones de casa con los textos nuevos, vistos en gallego y en castellano |

### Comprobado en CI (GitHub Actions)

| Con qué | Resultado |
| --- | --- |
| Workflow `voice-assets`: [run #44](https://github.com/FrankBetances/Descubre-con-lua/actions/runs/36689354166) sobre `1696422f` y [run #45](https://github.com/FrankBetances/Descubre-con-lua/actions/runs/36693483242) sobre `1755232d` | sintetizaron las 197 locuciones nuevas (`411a9368` y `d588594d`) y las 6 de las observaciones reescritas (`4e10b86a`) |
| Workflow `Gates` sobre `a8dc69ac`: [run #179](https://github.com/FrankBetances/Descubre-con-lua/actions/runs/36691891063) (push) y [run #180](https://github.com/FrankBetances/Descubre-con-lua/actions/runs/36691898030) (PR) | los 21 gates en verde, también los dos que `--fast` salta aquí: el **APK de release** se compila y no declara ningún permiso salvo el interno que añade AndroidX: ni INTERNET ni ningún otro. Es anterior a los arreglos de la revisión |

### NO comprobado

- **Esto no lo he visto en un aparato Android**, ni con la escala de texto
  grande de un teléfono real. La escala grande sí está medida en los tests.
- **El APK de release no se ha compilado en este contenedor**: aquí no hay
  Android SDK. Lo cubre CI.
- El audio no lo he escuchado. Los tests comprueban que el botón pide la
  grabación correcta, pero el escritorio Linux no tiene el canal de audio de
  Android.
- El gallego y el castellano de las cinco unidades no los ha revisado una
  persona nativa ni una educadora de infantil.
- El criterio de 4 cm es una regla del contenido, no una certificación de
  seguridad de producto.

## Los cuentos son historias, no microrrelatos · **en la rama `claude/tender-hamilton-mzhnxj`, pendiente de mergear** (24/9/2026)

Orden de Frank: «un cuento no es un microrrelato, un cuento es una historia con
objetivos y personajes, arregla los cuentos».

Antes (medido sobre los dos JSON de `main`): 302 cuentos visibles, de tres
páginas o menos y 67 palabras de media; en 298 páginas el texto llevaba
instrucciones de aula («compás de 72 bpm»); los títulos se repetían de curso en
curso y 200 de los 206 de `historias_progresivas.json` tenían las mismas tres
preguntas.

- Los 303 cuentos visibles están reescritos: cada uno tiene protagonista, un deseo,
  un problema, intentos que fallan, una idea o una ayuda y un final, y tres
  preguntas propias (literal, inferencia, creativa).
- La extensión crece con la edad. Es un listón propio, no sale de ningún
  documento de referencia:

  | Curso | Páginas | Palabras por cuento (media gl/es) |
  | --- | --- | --- |
  | 0-2 | 5 | ≥ 60 |
  | 2-3 | 6 | ≥ 85 |
  | 3-4 | 6-7 | ≥ 130 |
  | 4-5 | 8 | ≥ 200 |
  | 5-6 | 8 | ≥ 260 |

- Se conservan id, curso, mes, semana, nivel y reto TPR de cada cuento: el reto
  TPR es lo único con voz, así que no hace falta ninguna grabación nueva.
- `conto_040_s4` (0-2, junio, semana 4) repetía el título de otro cuento y la app
  no lo enseñaba nunca: ahora tiene historia propia y se ve. Tres duplicados del
  banco que nunca se enseñaban (`conto_001_l_a…`, `conto_002_mans…`,
  `conto_005_o_magosto…`) salen del JSON.
- Las palabras clave de cada página son las del propio cuento, en las dos lenguas
  a la vez. Antes la etiqueta de las preguntas salía «Nivel 1: Nivel 1: …».

### Comprobado en este contenedor, con Flutter 3.47.5

| Con qué | Resultado |
| --- | --- |
| Validador de los textos, script de esta sesión que no queda en el repositorio (páginas y palabras por edad, títulos únicos por curso, sin letras cirílicas coladas) | 303/303 |
| `flutter test --exclude-tags capturas` | todo en verde; `portales_seleccion_ux_test.dart` ahora exige las páginas de cada edad, ningún texto de página repetido y el vocabulario en las dos lenguas |
| `tools/gates.sh --fast` | todos los gates en verde; el corpus de voz sigue en 14.962 locuciones |
| App en escritorio Linux: Inicio → Portal Docentes → Modo Aula → 2.º Ciclo → 6.º (5-6) → semana 1 → el cuento de hoy | 8 páginas, miradas la 1, la 6 y la 8 en gallego |
| App: Portal Familias → Biblioteca de Cuentos, en castellano | «303 cuentos disponibles»; el cuento recuperado de 0-2 aparece; página 5 y preguntas de un cuento de 5-6 miradas |

### NO comprobado

- **Esto no lo he visto en un aparato**, ni con la escala de texto grande del
  sistema: el visor desplaza el texto, pero las páginas ahora llegan a ~115
  palabras.
- El gallego lo ha revisado Claude Code, no una persona nativa.
- La pregunta de cada lámina es por etapa del cuento (presentación, problema,
  idea…), no escrita a mano para cada página: en algunas encaja peor.

---

## De 0 a 6 años: cinco cursos de inglés, calendario de 50 meses e Inmersión ampliada · **en la rama `claude/tender-hamilton-mzhnxj`, pendiente de mergear** (24/9/2026)

Órdenes de Frank: el calendario no puede quedarse en los diez primeros meses
«cuando hablamos de seis años de trabajo»; fuera «50 meses» del planificador;
los 44 fonemas «son una miseria así no van a aprender las cinco palabras
diarias».

- Inglés: 5 cursos × 800 = 4.000 palabras, ninguna repetida entre cursos; cada
  grupo del aula usa las de su curso. Los 800 anteriores pasan a ser 3-4 años.
- Calendario (aula y casa): los 50 meses del trayecto, selector de curso, la
  pastilla del curso en cada tarjeta, y de junio se pasa a septiembre del curso
  siguiente. Desde el Modo Aula abre en el curso del grupo y en el lado del aula.
- Modo Aula: las palabras del día debajo del círculo del día.
- Inmersión en inglés: consulta de las 4.000 con buscador; repaso espaciado con
  las palabras del curso, que ahora sí se guarda en `user_progress.json` (lo que
  la política ya declaraba); escucha de las 16 frases de cada mes; 63
  colocaciones leídas del JSON (antes 13 escritas en el widget); 44 fonemas de
  verdad (antes 34 fichas y 31 sonidos distintos).
- `pubspec.yaml`: faltaban los cinco directorios de curso; sin ellos el APK
  viajaba sin palabras. Lo detectaba `check_bundled_assets.py`.

### Comprobado en este contenedor, con Flutter 3.47.5

| Con qué | Resultado |
| --- | --- |
| `flutter test --exclude-tags capturas` | 737/737 |
| `test/features/ingles_inmersion_test.dart` | 32/32: rondas de repaso, persistencia, cambio de curso, escucha, buscador, fonemas y colocaciones, gl/es y escala 1,0/1,8 |
| `test/features/calendario/calendario_test.dart` | 38/38, con el trayecto: 50 tarjetas, salto de curso al mismo mes, de junio a septiembre del curso siguiente |
| `planificador_5_palabras.py --check` | OK; con una palabra de 4-5 metida también en 0-2, falla y dice dónde |
| Gates de contenido, activos, manual y URLs legales | OK |
| Capturas `calendario-*`, `aula-unidades-*`, `aula-lista-2ciclo-*`, `academy-bloques-*` | regeneradas y miradas en gl y es |
| Manual PDF y Word | regenerados; PDF de 20 páginas, ninguna imagen fuera de la hoja (medido con PyMuPDF), secciones 5 y 7 miradas |

### NO comprobado

- **Esto no lo he visto en un aparato.**
- ~~`every locution has a recording`: faltan 3.344 grabaciones inglesas~~.
  Las sintetizó el workflow de voz en el commit `5e65947a`; comprobado después
  con `check_voice_coverage.py`: 14.962 locuciones, todas con grabación.
- `bienvenida-*` y `laminas-hoja` no coinciden con la app; no se han tocado.

---

## Cinco palabras inglesas al día: el curso de 800 · **en la rama `claude/tender-hamilton-mzhnxj`, pendiente de mergear** (23/9/2026)

Orden de Frank: «elimina eso de 6 palabras por mes, lo correcto es 5 palabras
diarias», con el documento «Modelo de Adquisición Natural y Proyección Anual».
La rama lleva además el commit de la rama `UI` de Frank (`0964f40`), corregido.

- El léxico mensual de `meses.json` (6 palabras × 10 meses) ya no existe. Sus
  60 palabras están dentro del curso nuevo.
- `assets/content/tpr/`: 10 meses × 4 semanas × 20 palabras = 800, cada una con
  significado gl/es, gesto gl/es y categoría. Reparto 280/200/160/96/64.
- Donde se ve: tarjeta «Hoxe na aula» del Portal Docentes, hoja «Ver as 800
  palabras», bloque del día en el Calendario (aula y casa), calendario de casa y
  tarjeta del Portal Familias. Todo lee el mismo día que la asamblea.
- Las palabras NO van dentro del reproductor de la asamblea: su fase núcleo ya
  desborda a 360×640 en 43 de 50 asambleas antes de este cambio.

### Comprobado en este contenedor, con Flutter 3.47.5

| Con qué | Resultado |
| --- | --- |
| `flutter test` (suite entera) | 526/526 |
| `test/features/tpr_pantallas_test.dart` | 76/76; incluye los 200 días del curso a 360 de ancho, gl/es, escala 1,0 y 1,8. Que el arnés caza un desborde se comprobó metiendo uno a propósito |
| `tools/planificador_5_palabras.py --check` | OK; con cuatro defectos metidos en una copia, los cuatro salen |
| `dart format`, `flutter analyze` y el resto de gates de contenido | OK, incluido `check_voice_levels.py` (10.991 grabaciones, ninguna por encima de −1 dBFS) |
| Manual: PDF y Word regenerados | 20 páginas (antes 19), mirados página a página; ninguna figura sale de la hoja (medido con PyMuPDF) |
| Capturas `calendario-*` | regeneradas; en `main` ya no coincidían `bienvenida-*`, `aula-unidades-*` y `aula-lista-2ciclo-*`, que no se han tocado |
| App de escritorio Linux (Xvfb 460×1000) | Portal Docentes → «Hoxe na aula» y «Ver as 800 palabras» vistos en gallego |

### NO comprobado

- **Esto no lo he visto en un aparato.** Tampoco con texto grande del sistema.
- `every locution has a recording`: faltan 629 grabaciones inglesas; las
  sintetiza el workflow de voz al empujar.

---

## El inglés que la app enseña: 4.000 palabras que suenan, con su frase · **en main, grabado y con los gates en verde** (21/9/2026)

Tres órdenes de Frank, en este orden:

1. «Las 8.000 deben sonar todas… necesitamos todas las palabras con frases
   completas».
2. «Quita de la app las doce palabras que son insultos o anatomía sexual».
3. «Solo deja las 4.000 palabras que usan de forma habitual».

Queda: **3.995 palabras**, que son las cuatro primeras bandas de frecuencia
(1k–4k) menos las cinco de la lista de exclusión que caían dentro. Las otras
3.998 de la lista de origen no están ni en el fichero, ni en la pantalla, ni en
el corpus de voz.

**Supuesto explícito**: «las que se usan de forma habitual» se ha leído como
«las cuatro primeras bandas de frecuencia de la lista BNC/COCA», que es el
propio orden de frecuencia de la lista. Si querías otro corte —por Zipf real,
por ejemplo— es una línea en `tools/build_corpus_ingles.py`.

Con el recorte, el fichero y la pantalla cambian de nombre: se llamaban
«8.000» y ya no lo son.

| Antes | Ahora |
| --- | --- |
| `assets/content/corpus/bnc_coca_8000_cefr.json` | `assets/content/corpus/ingles_4000_uso_habitual.json` |
| `tools/build_corpus_8000.py` | `tools/build_corpus_ingles.py` |
| `Palabras8000Screen` · «Corpus 8.000 Palabras» | `VocabularioInglesScreen` · «4.000 palabras de uso habitual» |

También se ha quitado el respaldo que tenía `ContentRepository`: si el fichero
bueno fallaba, la app cargaba la lista cruda de 7.998 —sin categoría, sin frase
y con las doce prohibidas dentro—. Un respaldo que enseña lo que se prohibió no
es un respaldo.

### Qué trae ahora cada palabra, y de dónde sale

El fichero lo escribe `tools/build_corpus_ingles.py` y el gate
`build_corpus_ingles.py --check` comprueba que no se caiga ninguna, que ninguna
salga de las bandas 1k–4k y que no vuelva ninguna de las doce.

| Campo | De dónde sale | Cuántas |
| --- | --- | --- |
| `pos` | WordNet, por la cuenta real del corpus SemCor, no por el orden en que WordNet lista los sentidos; 65 a mano | 3.995 de 3.995 |
| `frase` | Ejemplo real de WordNet que use la palabra, si pasa cuatro filtros; si no, oración construida con su definición; las de clase cerrada, a mano | 3.995 de 3.995 |
| `zipf` | `wordfreq`, frecuencia real | 3.995 de 3.995 |
| `definicion` | Glosa del sentido más usado de esa categoría | 3.995 de 3.995 |
| `onomatopeya` | Lista escrita a mano: WordNet no lo marca | 23 |

Reparto: **1.978 sustantivos, 1.199 verbos, 636 adjetivos, 122 adverbios** y 60
de clase cerrada. Antes eran 6.206 «NOUN» inventados.

El origen de la frase: **2.326** de un ejemplo real de WordNet, **1.604**
construidas con su definición y **65** escritas a mano.

**Dieciséis de las escritas a mano salieron de abrir la app**, no de un test.
WordNet sí tiene «a», «he», «it», «who» y «at», pero como el amperio, el helio,
la informática, la OMS y el astato: la palabra más frecuente del inglés entraba
en la pantalla definida como una unidad eléctrica. Ningún gate lo habría dicho.

**Los cuatro filtros del ejemplo**: misma categoría que se enseña (si no,
«overlook · sustantivo» salía con «the apartment overlooks the Hudson»);
**oración con verbo en forma personal**, comprobado con el etiquetador de nltk,
porque «a card shark» no es una frase completa; 80 caracteres como mucho,
porque esto se graba y se imita; y nada de la lista de veto, porque WordNet es
un diccionario general y sus ejemplos vienen de prensa adulta.

### Lo que queda por decir de la calidad

**1.604 frases son prosa de diccionario**: «A boat is a small vessel for travel
on water». Son correctas y reales, pero no son lenguaje de aula. Lo que faltaría
para cerrarlo bien: escribir a mano las 1.000 de la banda 1k, que son las que de
verdad se usan. **No está hecho y Frank no lo ha pedido.**

### El tamaño, ya MEDIDO

Las grabaciones ya existen, así que esto deja de ser una estimación. Medido
sobre `main` en `59f78f6`:

| | Ficheros | Tamaño real |
| --- | --- | --- |
| Palabra sola (`en_slow`) | 4.174 | 24,4 MB |
| Frase entera (`en_tutor`) | 4.663 | 69,6 MB |
| Toda la voz (gl + es + en) | 10.975 | **151,4 MB** |
| Todos los assets | | **163,6 MB** |

La estimación que se dio antes de sintetizar decía ~92 MB de voz nueva y ~171
MB de assets. Salió alta en un 5 %: lo real son 163,6 MB. El método —ajustar
una recta al tamaño de los ficheros que ya existían— funcionó.

**Y lo que construye CI con eso** (artefactos del run 157 de `Gates`):

| Artefacto | Tamaño |
| --- | --- |
| `app-release.apk` | ~179 MB |
| `app-release.aab` | ~211 MB |

**El límite de Google Play sigue SIN VERIFICAR**, y no por falta de intentarlo:
la página que lo dice —el artículo de «maximum size limits» del soporte de Play
Console— está bloqueada por la política de salida de este entorno. Lo único que
sí se pudo leer, en la documentación de Android, es que las apps de más de 200
MB usan Play Asset Delivery en vez de los ficheros de expansión antiguos; el
número exacto del límite hay que mirarlo en Play Console antes de subir nada.

### Cómo se graban

**Ya están grabadas todas.** El corpus de voz pasa de 3.159 a **10.975
locuciones** y `check_voice_coverage.py` está en verde en `main`: ni falta
ninguna grabación ni sobra ninguna.

Las sintetizó el workflow en dos corridas. La última, el run 37 sobre `main`,
hizo las **4.289 que faltaban en 17 minutos y 44 segundos** —del paso
«Synthesise en»—, así que el temor al límite de seis horas de un job no se
cumplió ni de lejos. El paso va **por tandas de 40 minutos** que se empujan en
cuanto acaban (`tools/ci_push_voice.sh`); con este volumen basta una.

**Lo que costó de verdad** fue coordinar las corridas con los merges: una
corrida que arranca de un commit anterior no ve las grabaciones que ya
entraron, las vuelve a sintetizar con otros bytes y el mismo nombre, y su push
choca al rebasar. Hubo que parar dos corridas y relanzar una desde el `main`
del momento.

`tools/check_voice_levels.py` mide ahora **en paralelo y en silencio**: con
tantos ficheros, uno detrás de otro eran veinte minutos de gate y miles de
líneas que nadie lee.

### Estado de los gates, en `main` y en `59f78f6`

| Gate | Cómo salió |
| --- | --- |
| Los 18 de `tools/gates.sh` | **Todos en verde**, en el run 157 de `Gates` sobre `main`. Ahí van `dart format`, `flutter analyze`, los 387 tests, `flutter build apk --release` y el gate de permisos del APK |
| `build_corpus_ingles.py --check` | OK, gate nuevo: 3.995 palabras, todas con categoría y frase |
| `humaniza_rutinas_fogar.py --check` | OK, gate nuevo: 1.000 días, ninguna rutina con firma ni corchete |
| `prune_voice_assets.py --check` | OK, gate nuevo: 10.975 grabaciones y ninguna sobra |
| `check_voice_coverage.py` | OK: las 10.975 están |

Lo que **no** se corrió en esta máquina, y por qué: `flutter build apk
--release` y el gate de permisos del APK necesitan el SDK de Android, y
`dl.google.com` está bloqueado por la política de salida de este entorno. Los
corrió CI, y pasaron.

---

## Las 1.000 rutinas de familia, reescritas para que suenen a casa · **en main** (21/9/2026)

Frank: «quita eso de que las 1.000 rutinas de familia empiezan por Dr.
Betances, necesito que las rutinas suenen naturales, que empiecen como
empezarían en la casa, calle o escuela de forma habitual».

**Lo que había, medido**: las 1.000 rutinas eran **cinco textos repetidos 200
veces cada uno**, y los cinco **idénticos para las cinco edades**. A una
criatura de seis años le decían «piel con piel» y «canto de cuna», lo mismo que
a un bebé de doce meses. Además empezaban por un corchete de máquina y llevaban
una firma delante del consejo:

> [Hogar · 1.º Curso (0-2 años · 12 a 24 meses)] En la hora del baño: Conectar
> con el cuento "X". Dr. Betances: El agua tibia es el mejor espacio
> sensoriomotriz sin pantallas para liberar tensiones. Sin pantallas ni prisas.

**Lo que hay**: 25 rutinas escritas a mano —5 momentos del día × 5 cursos— en
gallego y en castellano, en `tools/humaniza_rutinas_fogar.py`. Cada una empieza
donde empieza de verdad, y el registro sube con la edad:

> Antes de salir de casa, con la criatura en brazos, nombra lo que vais tocando
> —el abrigo, la puerta, la calle— y repite el saludo de «Manos que Saludan en
> la Asamblea». A esta edad el contacto y tu voz calman la despedida mucho más
> que cualquier explicación.

> De camino al colegio, pregúntale qué cree que va a pasar hoy y por qué, y liga
> algo con «Asamblea de Diciembre: El Círculo de los Amigos de Lúa». Decir «por
> qué» en voz alta es el paso que separa contar de explicar.

Se reescriben cuatro campos de los 1.000 días: `rutinaFogar`,
`consignaFamilia`, `momento` —«Antes de dormir / Canto de cuna» llevaba una
barra que nadie dice en voz alta— y `fraseConexion`, que decía cosas como «en
la hora de al despertar y antes de salir». El título del cuento se teje dentro,
**en su lengua**: la rutina gallega citaba el título en castellano.

Lo comprueba el gate `humaniza_rutinas_fogar.py --check`, que falla si vuelve
la firma, si una rutina vuelve a empezar por corchete o si un día se sale de la
tabla de 25.

Las 1.000 rutinas son ahora **1.000 cadenas distintas** —ninguna se repite,
contado sobre el fichero—, pero eso sale de 25 textos base más el cuento del
día. **Lo que esto NO arregla**: dentro del mismo curso y el mismo momento, las
cuatro semanas del mes comparten la misma estructura y solo cambia el cuento
citado. Para que la estructura también cambiase habría que escribir 100 textos
(25 × 4 semanas) en vez de 25, y eso no está hecho.

---

## Fóra o desprazamento vertical de toda a app · **sen mergear** (15/9/2026)

Frank: «quita a merda de scroll de todo». Fíxose, con dúas excepcións medidas
que se explican abaixo.

A peza nova é `lib/core/widgets/paxina_sen_scroll.dart`: mide o contido co
ancho real e, se é máis alto que o oco, **encólleo** ata que cabe, cun chan no
80 % para que non quede ilexible. A escala aplícase ao debuxo e aos toques, así
que os botóns seguen respondendo onde se ven.

| Pantalla | Que había | Que hai |
| --- | --- | --- |
| Inicio, Benvida, Créditos | `ListView` / `SingleChildScrollView` | Páxina que cabe |
| Academy · bloques e lector de cápsulas | Desprazable por páxina | Páxina que cabe; o lector xa ía por páxinas |
| Micro-rutina, cápsulas do aula, nota para as casas | `ListView` | Páxina que cabe |
| Premios, aviso de contido ilexible | `ListView` / desprazable | Páxina que cabe |
| Backstage do 2.º ciclo | Desprazable no corpo da fase | Páxina que cabe |

**As dúas excepcións, e por que.** A guía de inglés na casa e a ficha do mes do
calendario **seguen desprazándose**. Mediuse: o seu texto **non cabe nin
encollido ao 80 %**. Apretar máis a tipografía deixa sen ler a quen pon a letra
grande do sistema porque ve pouco. O «no scroll» dos dous documentos
curriculares fala da superficie de traballo —a asemblea, lida dun golpe de
vista a dous metros—, non dun texto que un adulto le sentado. Para que esas dúas
deixen de desprazarse hai que **acurtar o seu contido**, non apretar a letra.
Está escrito no código, con ese motivo.

**Unha pantalla que debería desaparecer.** A asemblea guiada vella de **seis
pasos** do 1.º ciclo segue aí, colgando do calendario, e tamén se despraza polo
mesmo motivo. Non está nos documentos de Frank —piden catro fases— e xa existe
o reprodutor novo que a substitúe. **Non se borrou**: é decisión de Frank.

**Non comprobado**: ningunha destas pantallas se viu nun aparello Android.

---

## El aula rehecha desde los dos documentos curriculares · **sin mergear** (15/9/2026)

Frank, muchas veces: «la UX del aula está mal», «quita el scroll», «estructurado
por edad», «la docencia tiene que ser escalonada», «te di dos documentos y los
has destrozado». Las cinco cosas eran ciertas y se pueden citar.

**De dónde sale ahora la pedagogía.** De los dos documentos de Frank, leídos
enteros en esta sesión:

- *Diseño Curricular Infantil Trilingüe Galicia* (2.º ciclo, 3-6). Escalona por
  nivel: 4.º acción expandida, 5.º dramatizado narrativo, 6.º transaccional.
- *Planificación Inglés Escuelas Infantiles* (1.º ciclo, 0-3). Escalona por
  tramo y trimestre: cada mes trae **dos dinámicas distintas**, una para 0-2 y
  otra para 2-3, con su material, su canción y sus órdenes.

**Lo que estaba incumplido, con la cita al lado.** Los dos documentos piden
«una única tarjeta de flujo diario… **sin navegación por capas ni
deslizamientos profundos (*no scroll*)**», modo oscuro y tipografía «no
inferior a 24 puntos» legible a dos metros. El aula de 2.º ciclo volcaba las 30
asambleas en una lista vertical bajo un encabezado que decía «SETEMBRO» con
enero debajo; no tenía selector de clase ni de mes; el botón de empezar abría
siempre septiembre de 4.º. El 1.º ciclo no seguía el documento en nada: 10
unidades con cuento, vocabulario y matemáticas, y una asamblea de **seis**
pasos, cuando el documento pide **cuatro** fases y dos tramos por mes.

| Capa | Qué se hizo | Con qué se comprobó |
| --- | --- | --- |
| Contenido 1.º ciclo (nuevo) | **20 microcápsulas**: 10 meses × 2 tramos, con las órdenes en inglés, las canciones y los materiales **literales del documento**. Donde el documento no especifica algo, el campo va vacío | `tools/gen_asambleas_primeiro_ciclo.py`; 20 ficheros en `assets/content/asambleas_primeiro_ciclo/` |
| Aula 1.º ciclo | Selector de grupo (0-2 / 2-3), tira de meses **de lado**, y UNA tarjeta con centro de interés, material, canción y 4 fases. Cero scroll vertical | App arrancada en escritorio Linux; captura **mirada** |
| Aula 2.º ciclo | Selector de clase (4.º/5.º/6.º con su metodología TPR), misma tira de meses, misma tarjeta única | App arrancada; captura **mirada** |
| Reproductor de asamblea (nuevo, uno para los dos ciclos) | Fondo oscuro, consigna a 26 pt, **una fase por pantalla**, se pasa de lado | App arrancada; captura **mirada** |
| Formación previa (nueva) | Dos recorridos de 6 pasos —docente y familia— en JSON, enlazados **antes** del botón de entrar en cada modo | `flutter analyze` limpio; **no vista en la app todavía** |
| Tests | Reescritos los que probaban el diseño viejo; añadido un gate que falla si aparece **cualquier desplazable vertical** en el aula | Suite completa |

**Defectos propios encontrados y corregidos por el camino**: la tarjeta sin
scroll desbordaba 200 px en 360×640, y otros 33 y 5 con la escala de texto 1,3.
Ahora el bloque de fases se resume solo cuando no caben las cuatro filas, y la
etiqueta del tramo se comprueba contra las líneas que la pastilla permite, no
contra una sola.

**Lo que NO se ha comprobado**: nada de esto se ha visto en un aparato Android.
Solo en escritorio Linux con pantalla virtual.

**Lo que falta del encargo**: Academy, Calendario, Premios, Créditos y
Bienvenida siguen con desplazamiento vertical. Y las 20 microcápsulas nuevas
**no tienen audio**: el corpus de voz no se ha regenerado para ellas.

Las 10 unidades viejas del 1.º ciclo **no se han borrado**: siguen en
`assets/content/unidades/`. Dejan de ser la puerta del aula, nada más.

---

## El calendario, DENTRO de los tres modos · **en la rama `claude/analizar-rama-mejora-g5yh9z`** (15/9/2026)

Frank, cuatro veces: «el calendario de aula no está». Tenía razón las cuatro.
En Modo Aula, en el 2.º ciclo y en Academy había **un botón** que saltaba a otra
pantalla. Un botón que lleva al calendario no es el calendario.

**Por qué no se vio antes**: se rehízo `calendario_screen.dart` —la pantalla
suelta— cuatro entregas seguidas, con 379 tests, 14 gates y dos runs de CI en
verde, sin haber abierto la app ni una vez. Una golden enseña la pantalla que se
eligió construir; si se eligió la equivocada, la confirma en verde. Está
registrado como **regla 1d de `CLAUDE.md`**, con los comandos para arrancar la
app aquí.

| Capa | Qué se hizo | Con qué se comprobó |
| --- | --- | --- |
| `calendario_do_curso.dart` (nuevo) | La sección del calendario como UNA pieza: tarjeta por mes, se pasa de lado, la siguiente asoma, al tocarla se abre el calendario por ESE mes | App ejecutada en escritorio Linux; capturas de los tres modos, **miradas** |
| Modo Aula · 1.º ciclo | Fuera el botón azul. La sección va como primera fila de la lista de unidades | `tiro-31-aula.png`, **mirada** |
| Modo Aula · 2.º ciclo | Fuera el salto. La sección abre la lista | `tiro-33-2ciclo.png`, **mirada** |
| Academy · Familias | Fuera la `AcademyCard` que saltaba. La sección va en su sitio, con el lado familia | `tiro-34-academy.png`, **mirada** |
| `CalendarioScreen` | Acepta `mesInicialIndex`: quien llega tocando la tarjeta de xaneiro ve xaneiro, no el mes de hoy | `flutter analyze` limpio |

**Cuatro defectos encontrados al mirar, no al testear:**

- **Desbordamiento de 5 px a escala 1,3.** La sección en el marco fijo de Modo
  Aula no cabía. Ahora es la primera fila de la lista y se desplaza con ella.
- **El arrastre con ratón no movía la tarjeta.** Flutter solo admite dedo y
  lápiz por defecto; se amplió `dragDevices`. Con el dedo ya funcionaba, y por
  eso el test no lo cazaba.
- **Hueco en blanco en la captura de Academy.** La sección leía el contenido por
  su cuenta y no llegaba a tiempo al retrato: golden inestable. Las dos
  pantallas aceptan ahora `calendarioContenido` ya leído.
- **«Sen rexistro» en la interfaz en castellano.** El distintivo de estado de la
  tarjeta tenía las cadenas en gallego a fuego, sin lengua. Visto en
  `aula-unidades-es.png`, no por un test.

**Esto no se ha visto en un aparato Android.** Lo ejecutado es el escritorio
Linux con pantalla virtual: sirve para saber qué pantalla sale y qué hay dentro,
no para insets reales ni densidades.

**Defecto visto y NO tocado, porque no se pidió**: en 2.º ciclo el rótulo dice
«SESIÓNS POR NIVEL (SETEMBRO)» y la primera tarjeta debajo es «Xaneiro: A
choiva…». O el rótulo o la tarjeta mienten.

---

## El Calendario, rehecho: tarjetas que se pasan de lado · **en la rama `claude/analizar-rama-mejora-g5yh9z`** (15/9/2026)

Frank había pedido tres cosas para esta pantalla —la interfaz del primer ciclo,
el calendario como en el otro lado y tarjetas de desplazamiento lateral— y
estaban sin hacer. La pantalla seguía siendo la que generó Antigravity.

**Lo que había, medido**: el golden se renderizaba en una pantalla falsa de
412×2000 px lógicos cuando un móvil real tiene ~915. Eran 2,2 pantallas de
desplazamiento vertical, con el mismo mes representado tres veces —la tira de
tarjetas de 160 px, las pastillas y la ficha de abajo—.

| Capa | Qué se hizo | Con qué se comprobó |
| --- | --- | --- |
| `calendario_screen.dart` | Fuera el carrusel de 160 px. Una `PageView` con una tarjeta por mes; el mes se cambia deslizando de lado | `calendario_test.dart`, test nuevo «o mes cámbiase deslizando a tarxeta de lado» |
| Marco de la pantalla | Subtítulo, cartel de hoy, conmutador de rol y pastillas quedan fijos arriba, como las pestañas de ciclo de «Juega con Lúa · Aula». El resto se desplaza | Capturas de las cuatro pantallas, **miradas** |
| Conmutador Aula/Fogar | Repintado con el patrón del primer ciclo: carril gris y pastilla levantada | `docs/capturas/calendario-gl.png`, **mirada** |
| Duplicados | Fuera `DetalleSesionPanel` (repetía la actividad palabra por palabra) y fuera el bloque «Por que importa no desenvolvemento» (repetía el objetivo pedagógico dentro de la misma tarjeta) | `flutter analyze` limpio; −132 líneas netas |
| Tira de pastillas | Se arrastra sola hasta la pastilla del mes abierto | Test nuevo «a pastilla do mes aberto non se queda fóra da tira». **Verificado que falla sin el arreglo**: sin él la pastilla de febreiro ni se construye |
| Capturas | Las cuatro pasan de lienzos de 1800/2000 px a un móvil de 412×915 | Regeneradas y **miradas** en gallego y castellano, lado aula y lado familia |
| Manual y README | El paso 2 del caso de uso dice ahora cómo se cambia de mes; el README lo dice en la línea del Calendario | PDF y DOCX regenerados; `tools/check_manual_build.py` en verde |

**Dos defectos propios encontrados al revisar, y corregidos:**

- Con `viewportFraction: 0.92` —el trozo de la tarjeta siguiente asomando— la
  página vecina **se construye**: había dos botones «Iniciar asemblea» y dos
  «Rexistrar» a la vez, uno de ellos de otro mes y tocable por el canto. Se
  pasó a página entera. Lo cazaron seis tests que pedían `findsOneWidget`.
- Con el marco fijo arriba, a escala de texto 1,8 desbordaba **418 px en
  gallego y 458 en castellano**. El marco tiene ahora un techo del 55 % de la
  pantalla y se desplaza dentro de él. `calendario_escala_test.dart` en verde.

**Esto no se ha visto en un aparato.** Es un cambio de disposición, que es
justo la familia de defectos que la regla 1c dice que no se ve en un test:
insets reales, densidades y escala de texto del sistema. Sigue sin mergearse a
`main` a la espera de que Frank lo mire.

**Decisión pendiente de Frank**: la tarjeta del mes siguiente no asoma por el
canto. Asomando se ve mejor que la tarjeta se desliza, pero vuelve a construir
la página vecina con sus botones tocables. Se eligió lo seguro.

---

## El logotipo del Concello de Vigo, retirado · **en `main`** (15/9/2026)

Frank pidió eliminarlo. Se ha quitado la **marca gráfica** en las tres capas
donde se pintaba, y se ha borrado el fichero del repositorio.

| Capa | Qué se hizo |
| --- | --- |
| Pantalla de créditos | Fuera el `LogoInstitucional` de `credits_screen.dart`. Comprobado con `docs/capturas/creditos-gl.png` y `creditos-es.png`, regeneradas y **miradas** |
| Portada del manual | Fuera la `<figure>` de `docs/manual-casos-de-uso.html`. PDF y DOCX regenerados; página 1 **mirada** |
| Cabecera del README | Fuera el `<img>`. La fila de marcas queda con startTIC y la Zona Franca |
| `assets/brand/logos/concello-vigo.png` | Borrado con `git rm` |
| `LICENSE.md` §7 | La cláusula enumeraba los logotipos «que aparecen en los créditos». Ya no aparece, así que sale de la lista |

**El nombre no se ha tocado**, y es a propósito: sigue en los créditos
(«Concello de Vigo» / «Ayuntamiento de Vigo», con «Escolas infantís
municipais» debajo), en la línea de entidades de la cabecera del README y en el
texto que dice para quién se hace la app. Lo guarda el test
`test/features/bienvenida_creditos_test.dart`, que exige ese nombre en las dos
lenguas: si alguien lo borrara, el gate se pone rojo.

Lo que **no** se ha hecho, porque no se pidió: retirar el nombre de la entidad
de ningún sitio.

---

## Los logotipos, completos · **en `main`, run de Gates #111 en verde** (15/9/2026)

Frank creó la rama `logo` con los ficheros completos y pidió actualizarlos.

| Fichero | Qué pasa con él |
| --- | --- |
| `concello-vigo.png` | Entró con la rama `logo` y **se retiró el mismo día**, a petición de Frank. Ver la sección de arriba |
| `zona-franca-vigo.png` | **Resuelto de verdad.** Pasa de 400 × 166 RGB —un recorte de captura de web— a 702 × 280 RGBA con margen propio. Medido: el canal alfa no toca ningún borde |
| `dr-betances-crest` | De PNG para fondo oscuro a JPEG 1024 × 1024 con fondo turquesa propio. Se le retira la placa oscura de créditos, que ahora solo le pondría un marco negro |
| `earlify-health.jpg` | De 47 KB a 335 KB. Sube a 76 px en créditos: a 56 se veía diminuto al lado del escudo |
| `startic.png` | **Sigue igual, y hay que decirlo.** El fichero de la rama `logo` es **byte a byte el mismo** que ya estaba: mismo SHA-256. Sigue recortado, con el dibujo tocando `x=0`, `x=509` e `y=101`. Falta el oficial de startTIC |
| `starttic.png` | **No se copia.** Idéntico a `startic.png`; dos nombres para la misma imagen acaban desincronizándose |

Las alturas se igualan por peso óptico y no por caja: 72-76 px los cuadrados,
48 los apaisados medios, 32 el de startTIC, que es 5:1.

### Comprobado en este contenedor

| Área | Evidencia |
| --- | --- |
| Gates locales | `tools/gates.sh --fast` → **14 de 14 en verde** |
| Suite completa | **340 tests, 0 fallos** · `analyze` limpio |
| Medición de los ficheros | Canal alfa en la primera y última fila y columna de cada PNG, y SHA-256 para comparar con lo que ya había. No es una impresión: está medido |
| Imágenes, **miradas** | `docs/capturas/creditos-{gl,es}.png` con las cinco marcas, y la portada del manual en el PDF regenerado |

### NO comprobado

| Área | Por qué |
| --- | --- |
| **El logotipo de startTIC sigue incompleto** | Lo que falta, falta. No se arregla por recorte ni retocando la marca de un tercero. Hace falta el fichero oficial |
| **Ninguna pantalla se ha visto en un aparato** | Las capturas son del motor de Flutter |

---

## Los seis defectos que encontró Frank en el 2.º ciclo · **en `claude/analizar-rama-mejora-g5yh9z`, pendiente de mergear** (15/9/2026)

Frank probó el módulo y devolvió seis cosas. Las seis eran ciertas, y una de
ellas —el desbordamiento— era peor de lo que él veía.

| Lo que dijo | Qué se encontró al comprobarlo | Qué se hizo |
| --- | --- | --- |
| «El diseño UX-UI no me gusta, prefiero el modelo del primer ciclo» | La asamblea de 2.º ciclo tenía su propia piel: fondo casi negro, stepper de cuatro pastillas y cronómetro gigante. Dos lenguajes visuales en un mismo producto | Rehecha con la pieza del primer ciclo: fondo claro, `Fase N de 4` con barra de progreso, aviso de «móvil fuera de la vista» y navegación por «Seguinte Fase» |
| «El color de la tarjeta de asamblea es incorrecto, el negro no ayuda» | Los tokens `backstage*` eran una paleta oscura aparte, y el botón de cada nivel iba negro con texto verde encima: ilegible | Los tokens apuntan ya a la paleta clara del primer ciclo. El botón, turquesa oscuro con texto blanco |
| «El texto se desborda donde dice cero pantallas» | **Desbordaba 299 px en gallego y 323 en castellano a escala normal, y 468 px a escala 1,3.** En cualquier móvil | `Wrap` en vez de `Row`, y `Flexible` en la línea. Y 11 filas más de icono+texto por toda la asamblea, que desbordaban igual |
| «Falta el calendario, eso es un error imperdonable» | Cierto: al 2.º ciclo solo se llegaba por la lista del aula. El Calendario Escola·Fogar no lo mencionaba | La ficha del mes trae los tres niveles al final. Si un mes no tiene asambleas escritas, no se pinta nada |
| «Faltan las voces en gallego e inglés» | Cierto: `tools/voice_corpus.py` no miraba `asambleas_segundo_ciclo/`, así que el gate de cobertura daba OK sin cubrirlo | 97 locuciones nuevas (42 gl + 42 es + 13 en): consignas, señales y órdenes TPR. Cada una con su altavoz en pantalla |
| «¿Dónde están los gráficos e imágenes?» | Cierto: cuatro pantallas de prosa seguidas, sin una sola imagen | Lámina en cada fase y en la micro-rutina, del catálogo vectorial que ya existía: `gato`, `man`, `pes`, `mochila`, `abrigo`, `cuncha`, `arbore`, `toalla`, `amiga` |

### Comprobado en este contenedor, con Flutter 3.47.4

| Área | Evidencia |
| --- | --- |
| Gates locales | `tools/gates.sh --fast` → **13 de 14 en verde**; el que falta es la cobertura de voz, abajo |
| Suite completa | `flutter test --exclude-tags capturas` → **340 tests, 0 fallos** |
| Barrera nueva contra desbordes | `test/features/juega/segundo_ciclo_escala_test.dart`: las dos pantallas del 2.º ciclo, en gallego y castellano, a escala 1,0 y 1,3, sobre 360 dp. **Los ocho casos fallaban al escribirlo** |
| Imágenes, **miradas** | `aula-lista-2ciclo-{gl,es}.png` —la pantalla que nunca se había retratado y donde estaba el desbordamiento—, `aula-backstage-{gl,es}.png`, `academy-micro-rutina-{gl,es}.png` y el calendario con su bloque de 2.º ciclo |

### Por qué se coló

La captura del turno anterior retrataba el **interior** de la asamblea, nunca la
lista del aula con la pestaña de 2.º ciclo pulsada, que es la pantalla por la
que se entra. Dije «capturas miradas» y era verdad de lo que capturé; lo que
faltaba era capturar lo que importaba. Ahora esa pantalla está en el banco de
capturas y en el test de escala.

### NO comprobado en esta rama

| Área | Por qué |
| --- | --- |
| **Las 97 grabaciones nuevas** | El corpus ya las declara; las sintetiza el workflow `voice-assets` al empujar. Hasta entonces `check_voice_coverage.py` está rojo y los altavoces no se pintan |
| **Ninguna pantalla se ha visto en un aparato** | Sigue abierto, y es lo único que las capturas del motor no pueden cerrar |
| **El 2.º ciclo solo cubre septiembre** | Tres asambleas, una por nivel. Los otros nueve meses no están escritos |

---

## La rama `mejora` reconstruida sobre `main` · **en `claude/analizar-rama-mejora-g5yh9z`, pendiente de mergear** (15/9/2026)

El módulo de asambleas matinales de 2.º ciclo con el inglés como L3 —backstage
docente, micro-rutina de hogar y cápsula de familia— venía de la rama `mejora`,
que estaba 43 commits por detrás de `main` y **no compilaba**: usaba
`LocalizedString(en:)`, que `main` había retirado a propósito en `d79e85a`.
Aquí se porta encima de `main`, alineado con esa decisión, y se corrige lo que
salió al correrlo por primera vez.

### Comprobado en este contenedor, con Flutter 3.47.4

| Área | Evidencia |
| --- | --- |
| Gates locales | `tools/gates.sh --fast` → **14 de 14 en verde**, con el manual y la voz dentro |
| Suite completa | `flutter test --exclude-tags capturas` → **332 tests, 0 fallos** |
| Análisis y formato | `flutter analyze` → *No issues found* · `dart format` limpio |
| La rama de origen NO compilaba | `flutter analyze` sobre `origin/mejora` en un worktree aparte → **12 errores** en `recast_guia_card.dart` y 3 en tests. Sus `GATE_STATUS.md` decían «PASS» y «CLEAN»: eran agentes aprobándose entre ellos, con `handoff.md` por única fuente |
| Desborde real, cazado y rehecho | El selector de ciclo desbordaba **224 px** a escala 1,3 (`filtro_edad_test.dart`). El stepper de fases medía **1387 px** de ancho: las fases 3 y 4 caían fuera de la pantalla y no había manera de pulsarlas. Las dos piezas rehechas, no apretadas |
| Imágenes, **miradas** | `docs/capturas/aula-backstage-{gl,es}.png` y `academy-micro-rutina-{gl,es}.png`, generadas con el motor real |
| README y manual | La etapa 3-6 descrita en los dos. El manual suma **CU-12** (conducir la asamblea matinal de 2.º ciclo) y **CU-17** (la micro-rutina en casa), el mapa de la app, dos pares de capturas y los límites reales. PDF y Word regenerados; `check_manual_build.py` en verde. Los rótulos de CU-12 se contrastaron contra el código: el manual llegó a citar un botón —«Comezar a asemblea»— que no existe |
| Fuga R4 | `grep` sobre el árbol entero → **0 ficheros** con el nombre del otro producto o la ruta personal. `mejora` traía 210 porque es anterior a la limpieza de `5323d79`; sus 124 ficheros nuevos de `.agents/` no se han traído |

### Lo que se corrigió del contenido, y por qué

| Qué | Por qué |
| --- | --- |
| Fuera las **praxias orofaciales** (soplo y vibración labial /v/ /z/) de 5.º de Infantil | Es técnica logopédica prescrita a una docente, en una app que declara no tener finalidad sanitaria. La fase se queda como foco rítmico |
| «Bloquea el filtro afectivo» → reescrito | Estaba del revés: en el modelo de Krashen la ansiedad SUBE el filtro. El mismo texto decía lo correcto en inglés y lo contrario en gallego y castellano |
| «El cerebro infantil ajusta sus estructuras» → fuera | Mecanismo neurológico afirmado sin fuente, en un texto que leen familias |
| `revisorPedagogico` vacío y `aprobadoParaAula: false` en los 4 ficheros nuevos | Declaraban revisión y aprobación de un especialista que no existe |
| El alineamiento curricular sale ya del JSON | La pantalla decía **CA1.2** y su propia cápsula dice **CA1.1**. Ahora hay una sola fuente |
| El conmutador de nivel, bilingüe | Tenía los rótulos escritos solo en gallego: en castellano enseñaba «anos» |
| Los minutos de cada fase y el resumen de la tarjeta, desde el modelo | Estaban escritos a mano en los widgets; si el JSON decía otra duración, la pantalla mentía |
| Emoji fuera (🧥 ❌ ✅ 📍 🛑 🎴) | Regla 5. Sustituidos por iconos Material |
| `luaDice` en la cápsula nueva | `cierre_lua_test.dart` existe justo para que la cápsula número seis no se escriba sin él. Lo cazó |

### NO comprobado en esta rama

| Área | Por qué |
| --- | --- |
| ~~Faltan 6 grabaciones~~ · **resuelto** | Las sintetizó el workflow `voice-assets` (run #23, en verde) y las commiteó en `1e326a3`. `check_voice_coverage.py` → **OK, 1038 locuciones, todas presentes** |
| **El APK de release, EN LOCAL** | No hay Android SDK en este contenedor. Lo cubre CI |
| **Ninguna pantalla se ha visto en un aparato** | Las capturas son del motor de Flutter: cazan desbordes, no la muesca, ni la barra de gestos, ni la densidad real |
| **El 2.º ciclo solo cubre septiembre** | Tres asambleas (una por nivel) y una cápsula. Los otros nueve meses del curso no están escritos. El manual lo dice en su capítulo 5 |
| **Nadie ha escuchado nada** | El gate de niveles dice que no saturan. Ningún gate dice si Celtia pronuncia bien |
| **Si CA1.1 o CA1.2 es el criterio correcto** | No tengo el Decreto 150/2022 delante. Lo que se arregló es que haya **una sola** fuente, no que esa fuente sea la buena |
| ~~Si el 2.º ciclo (3-6) entra en el encargo~~ · **decidido** | Frank: «es el objetivo de esta iteración y una ampliación natural del proyecto». README y manual actualizados en consecuencia |

---

## Lúa entra en las actividades · **ya en `main`** (14/9/2026)

Llegó por `claude/youthful-dijkstra-9tf5gy` y está mergeada. Dos piezas: el
cierre de Lúa en las cápsulas de Academy (`luaDice`) y la gata al frente de la
nota para las casas.

**Frank mergeó sabiendo lo que falta**, que está en la tabla de abajo: ninguna
pantalla se ha visto en un aparato. La regla 1c pide justamente eso —decirlo y
que lo mire él— y no que la evidencia exista.

### Comprobado en este contenedor, con Flutter 3.47.4

| Área | Evidencia |
| --- | --- |
| Gates locales | `tools/gates.sh --fast` → **14 de 14 en verde** |
| Suite completa | `flutter test --exclude-tags capturas` → **245 tests, 0 fallos** (218 antes) |
| Análisis y formato | `flutter analyze` → *No issues found* · `dart format` limpio |
| Desbordes de disposición | `academy_escala_test.dart`, gl y es a escala 1,8. El recorrido **ya contesta la reflexión**: antes moría en esa página y ninguna posterior se miraba nunca |
| Voz | Las 10 locuciones nuevas de `luaDice` las sintetizó el workflow `voice-assets` y están en la rama; `check_voice_coverage.py` en verde con 1 020 |
| Imágenes | `docs/capturas/academy-lua-peche-{gl,es}.png` y `nota-casas-{gl,es}.png`, generadas con el motor real y **miradas** |
| **CI, sobre la cabeza de la rama** | [Run #87](https://github.com/FrankBetances/Descubre-con-lua/actions/runs/34858575993) sobre `39fa44a`: **verde entero**. Ahí sí entra lo que `--fast` salta en local: la compilación del **APK de release** y la auditoría de permisos del binario |

### NO comprobado en esta rama

| Área | Por qué |
| --- | --- |
| **El APK de release, EN LOCAL** | Aquí no hay Android SDK, así que `--fast` salta la compilación. Lo cubre CI, no este contenedor |
| **Ninguna pantalla se ha visto en un aparato** | No hay emulador ni móvil. Las imágenes son del motor de Flutter: cazan desbordes, no la muesca, ni la barra de gestos, ni la densidad real. **Esta es la que sigue abierta de verdad** |
| **Nadie ha escuchado las 10 locuciones nuevas** | Están sintetizadas y el gate de niveles dice que no saturan. Ningún gate dice si Celtia pronuncia bien «quédate cun só xesto» |

**Corregido el mismo día.** Esta tabla decía que CI no tenía ningún run verde de
la rama y que el APK no llegaba a generarse. Era cierto del run #85, que corrió
antes de la síntesis de voz, y dejó de serlo en cuanto un push propio —no el del
`GITHUB_TOKEN`— volvió a disparar los gates: el #87 está verde con el APK dentro.
Un pendiente que no se cierra el día que se cierra se lee después como abierto.

---

## Rama `claude/english-learning-integration-56daa7` · el inglés, el calendario y las medallas

Esto NO está en `main`. Se dice en rama, con el número de comprobación al lado.

### Comprobado en este contenedor, con Flutter 3.47.4

Esta vez sí hay SDK: se descargó el `stable` y se corrieron los gates de Dart
que antes quedaban para CI.

| Área | Evidencia |
| --- | --- |
| Análisis estático | `flutter analyze` → *No issues found* |
| Suite completa | `flutter test --exclude-tags capturas` → **218 tests, 0 fallos** |
| Formato | `dart format --output=none --set-exit-if-changed .` → limpio |
| Gates de contenido | correo, marcas de pulso, corpus sincronizado (351 locuciones) y URLs legales offline → OK |
| **Desbordes de disposición** | `test/features/calendario/calendario_escala_test.dart`: calendario y guía, en gallego y castellano, a escala de texto 1,0 y 1,8. Encontró y ahora vigila **cinco desbordes reales** |
| Imágenes de las pantallas nuevas | `docs/capturas/calendario-{gl,es}.png` y `guia-ingles-{gl,es}.png`, generadas con el motor real y **miradas** |

### Lo que la rama `mejora` traía roto, y ya no

| Qué | Cómo se veía |
| --- | --- |
| El test del calendario **no compilaba** | `xuño` como nombre de variable: Dart no admite `ñ` en un identificador. Las 474 líneas de test de esa rama **nunca se ejecutaron** |
| El cartel del calendario **no se actualizaba nunca** | El estado del día se leía fuera del `AnimatedBuilder`: se registraba la asamblea, se guardaba bien, y la pantalla seguía diciendo que no había nada hasta salir y volver a entrar |
| La tarjeta del mes desbordaba | 47 px por abajo y 41 por la derecha. En depuración salen las franjas; **en release el texto se corta y ya** |
| El conmutador de rol y la barra desbordaban | 5 px el conmutador, 119 px la barra a escala de texto grande |
| El altavoz de las palabras inglesas era un dibujo | Un icono de altavoz pintado que no reproducía nada |
| La tarjeta del mes decía «sen rexistro» con el mes trabajado | Preguntaba por el día 15 de cada mes |
| `AppLanguage.fromCode('en')` abría la app en inglés | No hay ni una pantalla en inglés. Un móvil en inglés abre ahora en galego |

### NO comprobado en esta rama

| Área | Por qué |
| --- | --- |
| **Ninguna de las pantallas nuevas se ha visto en un aparato** | Aquí no hay emulador ni móvil. Lo que hay son imágenes del motor de Flutter con la tipografía real (`docs/capturas/`) y el test de escala: eso caza los desbordes, pero no la muesca, ni la barra de gestos, ni la densidad real |
| **Las 105 grabaciones en inglés no existen todavía** | Las sintetiza el workflow `voice-assets` al empujar. Hasta que ese run termine, `check_voice_coverage.py` está **en rojo** y las pastillas de inglés se ven sin altavoz: la palabra se lee, pero no suena |
| **Nadie ha escuchado el inglés de LJSpeech** | Ningún gate dice si una frase de tres palabras suena bien para imitarla |
| **El APK de release no se ha compilado aquí** | Sigue sin resolverse el Android Gradle Plugin en este contenedor. El permiso del binario y el tamaño salen de CI |
| **El manual no documenta el calendario** | Los 17 casos de uso y las 14 imágenes del manual son los de antes. Las cuatro imágenes nuevas están en `docs/capturas/` pero el manual no las usa |
| **El permiso de uso de los logotipos** | Zona Franca y startTIC son marcas de terceros y en una ficha de Play sugieren respaldo institucional. Hace falta autorización escrita. El del Concello de Vigo ya no se usa: se retiró el 15/9/2026 |

---

## Cómo se comprueba

```bash
tools/gates.sh          # todos los gates
tools/gates.sh --fast   # sin la compilación del APK (rápido, para iterar)
```

CI ejecuta **ese mismo fichero** (`.github/workflows/ci.yml`). La lista de
gates no vive escrita en ningún documento: vive en el script. Una lista escrita
a mano en un documento se queda atrás respecto al workflow, y entonces una build
muere en un gate que no figuraba en ella.

| Gate | Qué comprueba |
| --- | --- |
| `dart format` | Formato del código |
| `flutter analyze` | Análisis estático |
| `flutter test` | La suite completa, ejecutándose de verdad |
| `check_contact_email.py` | Que no aparezca ningún correo distinto del fijo del proyecto |
| `export_voice_corpus.py --check` | Que el corpus de voz y las rutas del contenido estén sincronizados con los textos |
| `check_pulse_bpm.py` | Que el tempo que muestra la unidad sea el que suena en la pista de pulso, **medido del audio** |
| `check_pulse_markers.py` | Que las marcas `*` describan un pulso constante, igual en gallego y castellano |
| `check_voice_coverage.py` | Que toda locución que la app puede reproducir tenga grabación en el paquete |
| `check_voice_levels.py` | Que ninguna grabación pique por encima de −1 dBFS, **medido del fichero publicado** |
| `flutter build apk --release` | Que el APK de release compile |
| Permisos del APK | Que el **artefacto compilado** no declare ningún permiso salvo el que inyecta AndroidX (leído con `aapt2`, no del manifiesto fuente) |

---

## Estado por área

### Verificado en esta sesión

Con Flutter 3.47.3, ejecutado en el contenedor de trabajo (el actual ya no
trae SDK de Flutter; esos tres gates viven hoy en CI):

| Área | Evidencia |
| --- | --- |
| La app y la suite compilan | `flutter analyze` → *No issues found* |
| La suite pasa | `flutter test` → *All tests passed!* |
| Formato | `dart format --set-exit-if-changed` → limpio |
| Correo de contacto | `tools/check_contact_email.py` → OK |
| Corpus de voz sincronizado | `tools/export_voice_corpus.py --check` → OK |
| Tempo declarado vs pista real | `tools/check_pulse_bpm.py` → 72,3 BPM medidos, coinciden |
| Paridad de identificadores de voz | `test/core/voice_id_test.dart`: la implementación en Dart y la de Python dan el mismo hash sobre el mismo texto |
| Icono de Lúa | Renderizado y **mirado** en todas las densidades |
| **La app arranca y se navega en un aparato real** | Frank instaló el APK del run 16 en un **Pixel 6**: abre sin problemas y las secciones funcionan. Es la primera vez que esta app corre en un Android |

Y en CI (GitHub Actions, runner limpio):

| Área | Evidencia |
| --- | --- |
| La suite pasa en limpio | `flutter test` en el runner, dentro del gate verde del run 16 de `main` |
| **El APK release compila** | `✓ Built build/app/outputs/flutter-apk/app-release.apk (50.9MB)` |
| **El binario no lleva permisos de red** | `aapt2 dump permissions` sobre el APK: un único permiso, `com.earlify.descubreconlua.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. **Sin INTERNET, sin estado de red, sin nada más** |
| **Las 12 grabaciones existen** | Gallego con Celtia (Proxecto Nós), castellano con Sharvard. `check_voice_coverage.py` → 12/12 |
| **Ninguna graba­ción pica** | `check_voice_levels.py` sobre los 12 ficheros publicados: entre −3,2 y −2,4 dBFS, ninguna por encima de −1 |
| **El APK va firmado con la clave de release** | `apksigner verify --print-certs` sobre el APK del run: `CN=Descubre con Lua, O=Earlify Health S.L.`. Con los secrets puestos, una firma de depuración habría tumbado el paso |
| **El AAB se compila** | `flutter build appbundle --release` en el run 16 de `main`: artefacto `android-aab`, 45,93 MB, `versionCode 16` |

**Sobre el único permiso del binario.** Lo inyecta AndroidX Core en toda app que
lo use, y Flutter exige AndroidX. Lleva el nombre de paquete de esta app, se
declara con `protectionLevel="signature"` y sólo permite registrar receptores de
difusión propios no exportados. No da acceso a nada fuera de la app y no entra
en ninguna categoría del formulario de *Seguridad de los datos* de Play. El gate
lo acepta de forma explícita y rechaza cualquier otro.

### NO verificado

| Área | Por qué |
| --- | --- |
| **Nada de esto se ha compilado en este contenedor** | La política de red devuelve 403 para `dl.google.com`, así que el Android Gradle Plugin no se resuelve aquí. Todo lo de Android está verificado **en CI**, no en local |
| **La app no se ha usado en una asamblea real** | Frank la abrió en un Pixel 6 y recorrió las secciones. Que arranque y que funcione con doce crianzas en el aula son cosas distintas |
| **Desbordes de disposición** | Sin aparato no hay forma de ver un `RenderFlex overflowed`. En release no se ve nada: el texto simplemente se corta. Falta comprobar en gallego, castellano y con escala de texto grande |
| **Los gates de Dart, en este contenedor** | No hay SDK de Flutter instalado aquí (`dart: command not found`). Los siete gates de contenido sí corrieron y pasaron; `dart format`, `flutter analyze` y `flutter test` quedan para CI |
| **Nadie ha escuchado las grabaciones** | Los gates miden picos, duración y cobertura. Que el galego de Celtia suene natural para una docente de Vigo, y que «Mexillón» se entienda a la primera en una asamblea, no lo dice ningún gate |

### Estado de CI

**`main` en verde entero: run 16, los 12 gates.** Es la primera vez que este
proyecto pasa sus propias comprobaciones completas. Antes de ese run, `main`
nunca había tenido uno limpio.

`.github/workflows/ci.yml` corre los gates **y** compila el binario firmado.
Del run 16 salen:

| Artefacto | Tamaño | Retención |
| --- | --- | --- |
| `android-aab` · `versionCode 16` | 45,93 MB | 3 días |
| `android-apk` | 23,21 MB | 5 días |

El AAB pesa el doble que el APK porque lleva todas las arquitecturas, densidades
e idiomas; Play entrega a cada móvil sólo su porción.

`android-mapping` no se genera: `minifyEnabled false`, así que Gradle no escribe
`mapping.txt`. El paso está puesto y no falla por ello.

**Un gate en rojo bloquea el AAB**, porque los pasos posteriores a uno fallido se
saltan. Es lo correcto —un AAB es lo que se sube a Play— pero conviene saberlo:
cuando el AAB no aparece, el motivo está más arriba en el run, no en el paso del
AAB. El APK sí se sube en runs rojos, a propósito: sirve para instalar y mirar.

### Resuelto: la app ya reproduce las 12 locuciones

`check_voice_coverage.py` llegó a fallar con 7 de 12 sin grabación. Se resolvió
aceptando las condiciones del modelo Celtia de `proxectonos` en Hugging Face,
añadiendo el token como secret `HF_TOKEN` y lanzando **Generate Voice Assets**
(run 5), que sintetizó las seis gallegas y las commiteó.

Medidas aquí sobre los ficheros descargados:

| Locución | Duración | Pico |
| --- | ---: | ---: |
| Peixe | 0,81 s | −3,2 dBFS |
| Cuncha | 1,02 s | −3,0 dBFS |
| Barco | 0,53 s | −2,7 dBFS |
| Gaivota | 1,15 s | −3,0 dBFS |
| Mexillón | 1,08 s | −3,0 dBFS |
| O recitado a pulso | 8,01 s | −2,9 dBFS |

El recitado se sintetizó **sin** las marcas de pulso ni la partición silábica: el
fichero dice «Ondas que veñen», la pantalla muestra `* On-das * que veñen`. El
identificador `07aaac78` es el hash del texto **mostrado**, así que mover una
marca deja la grabación huérfana y el gate lo dice.

Los modelos corren en CI y jamás en el aparato: el APK lleva grabaciones, no
inferencia. Eso es lo que mantiene el binario sin permisos de red.

---

## Decisiones resueltas por Frank

1. **El metrónomo es visual.** No suena: parte de las crianzas llevan audiófono
   o implante, y un metrónomo sonoro compite justo con la voz que tienen que
   seguir. Los tiempos salen de las marcas `*` de la letra, no de una
   configuración aparte. Un test comprueba que iniciar el pulso **no reproduce
   ningún audio**.
2. **Earlify Health S.L. es correcto** como responsable del tratamiento. La
   política queda como está.
3. **Las importaciones rotas se han retirado** del CLAUDE.md, que además ahora
   está versionado en el repositorio. `.agents/` no se ha tocado.

## Decisiones que siguen pendientes

1. **Tramo etario.** La única unidad está marcada `"0-3"`, que casa con las dos
   pestañas del filtro, así que el filtro 0-2 / 2-3 nunca se ejercita con el
   contenido que existe.
2. **Ilustraciones.** El cuento referencia cuatro imágenes que no están en el
   repositorio. La pantalla ahora lo dice en palabras útiles para la docente,
   en vez de imprimir la ruta del fichero.
3. **Cobertura de contenido.** Academy ya tiene **una cápsula por bloque** (5 de
   5): ningún bloque queda con el aviso «en preparación pedagógica». Juega con
   Lúa sigue con 1 unidad.
4. **La pista de pulso de 2,3 MB.** Con el metrónomo visual ya no hace falta
   como metrónomo sonoro. Sigue en el paquete y sigue verificada en 72,3 BPM;
   retirarla ahorraría 2,3 MB del APK.
5. **El keystore de subida.** Las decisiones de firma —qué clave usa esta app y
   qué se activa en la consola de la tienda— **no se documentan aquí**: este
   repositorio es público y eso es información de operación.
6. **Minificación.** `minifyEnabled false` y `shrinkResources false`. El paso
   que sube `mapping.txt` está puesto pero hoy no sube nada. Activar R8 cambia
   el binario, así que no se ha tocado: es una decisión, no un olvido.
7. **`placeholderPattern` caza la palabra «todo».** En
   `content_validator.dart:60` el patrón `\b(TODO|TBD|…)\b` va con
   `caseSensitive: false`, así que rechaza cualquier texto que contenga «todo»
   —una de las palabras más comunes en castellano y galego—. Salió al escribir
   las cápsulas nuevas: «y, sobre todo, dan contexto» habría tumbado la
   validación. Se sorteó reescribiendo la frase, pero la trampa sigue puesta
   para la próxima cápsula. El arreglo es de una línea: `caseSensitive: true`,
   porque un marcador de tarea pendiente se escribe en mayúsculas. **No se ha
   tocado**: es código, no contenido, y no estaba en el encargo.

---

## Lo que había antes, para que no vuelva

`TEST_READY.md` y los ficheros `verify_m*.py` y `test/**/*.py` afirmaban 27 de
27 funcionalidades «✅ VERIFIED» y 1443 comprobaciones superadas. El runner
recorría los `.dart`, comprobaba que contuvieran `import flutter_test` y los
daba por ejecutados en 0,00 segundos cada uno. Con Flutter realmente instalado,
el estado era: 6 errores en `flutter analyze`, `flutter test` con código de
salida 1, y 7 ficheros de test que no cargaban porque `lib/core/theme/app_theme.dart`
no compilaba.

Esos ficheros están borrados. Lo que dice si algo funciona es `tools/gates.sh`.
