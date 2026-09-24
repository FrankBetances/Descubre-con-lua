# Estado real de «Descubre con Lúa · Edición Vigo»

Este documento sustituye a `TEST_READY.md`, que certificaba «1443/1443 PASSED ·
CERTIFIED READY FOR PRODUCTION DEPLOYMENT» sin que se hubiese ejecutado nunca
un solo test.

Regla de este fichero: **cada línea dice con qué se comprobó, o dice que no se
ha comprobado.** Si no hay evidencia al lado, no se afirma.

---

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
