# Arquitectura docente

Cómo se organiza lo que enseña **Descubre con Lúa · Edición Vigo**: de qué
pieza sale cada cosa que ve la docente o la familia, cómo se reparte el curso
y cómo habla la persona adulta. **Este documento no cambia ninguna pantalla.**
Es el diseño de destino. El diagnóstico del estado actual y el orden de trabajo
están en `docs/PLAN_MEJORA_INTEGRAL.md`. Los dos documentos dicen lo mismo; si
uno se queda atrás, se corrige en el mismo cambio.

Si este documento y el JSON no dicen lo mismo, manda el JSON: es lo que la app
enseña. Cuando una pieza de este diseño ya esté en el JSON, este documento la
describe; no la duplica.

## 1. Fuentes y orden de mando

1. **Reglas de producto.** La criatura no usa la pantalla. Cero datos de una
   crianza. Sin red. Nada sanitario. El contenido vive en JSON. El pulso se ve,
   no se oye.
2. **Normativa gallega, leída en el DOG**: Decreto 150/2022, Orden de 30 de
   mayo de 2023 y Decreto 79/2010.
3. **Los documentos curriculares de Frank** que ya construyen la app: *Diseño
   Curricular Infantil Trilingüe Galicia* (2.º ciclo), *Planificación Inglés
   Escuelas Infantiles* (1.º ciclo) y *Modelo de Adquisición Natural y
   Proyección Anual* (banco de cinco palabras al día).
4. **Los cinco textos de `referencias/base/`**: currículo de inglés en Galicia,
   currículo de vocabulario de 2 a 6 años, cuentos dialógicos bilingües,
   estrategias de apoyo lingüístico y rutinas SparkLing.

Los cinco textos son síntesis de trabajo, no normativa ni manuales oficiales.
Ninguna cifra, código de criterio o cita de un estudio pasa de ellos a una
pantalla sin contrastarla con su fuente primaria.

## 2. Principios del modelo

Salen de los cinco textos, filtrados por las fuentes 1 a 3.

1. **Habla una persona, no la app.** La grabación sirve para que la adulta se
   prepare. La criatura la oye a ella, con su cara, su gesto y el objeto.
2. **Primero se comprende, después se habla.** La respuesta esperada es el
   cuerpo: señalar, hacer el gesto, coger el objeto. Que hable es un regalo, no
   una meta del día.
3. **Poco, estable y con las manos.** Un núcleo corto de palabras, el mismo
   todo el mes, con objeto real y gesto, que vuelve en todas las piezas del
   mes.
4. **Una sola unidad por mes.** Todo lo del mes (asamblea, cuento, juego, casa)
   sale del mismo centro de interés y del mismo núcleo.
5. **La lengua de casa es bienvenida.** La trama y la interfaz van en gallego y
   en castellano. Lúa pone el inglés. Si la criatura contesta en gallego o en
   castellano, se acoge y se devuelve en inglés, sin corregir.
6. **Nunca se pide repetir ni se corrige de forma explícita**, en ninguna
   lengua.
7. **El inglés no es asignatura.** Es aproximación dentro del Área de
   Comunicación y Representación da Realidade. Sin ficha, sin nota y sin
   evaluación propia.

## 3. La columna vertebral: 50 unidades mensuales

El curso son **5 cursos × 10 meses = 50 unidades**. La unidad es la única
fuente del mes: las pantallas leen la unidad y no guardan contenido propio.

| Curso de la app | Etapa | Grupo en el aula | Quién la usa |
| --- | --- | --- | --- |
| 0-2 | 1.º ciclo | tramo 0-2 | educadora / familia |
| 2-3 | 1.º ciclo | tramo 2-3 | educadora / familia |
| 3-4 | 2.º ciclo | 4.º de Infantil | docente / familia |
| 4-5 | 2.º ciclo | 5.º de Infantil | docente / familia |
| 5-6 | 2.º ciclo | 6.º de Infantil | docente / familia |

### Qué tiene cada unidad

| Campo | Qué es | Regla |
| --- | --- | --- |
| `centroInteres` | Un tema del mes, igual en aula y en casa | Uno solo: **el de la asamblea del mes**, que sale del documento curricular de Frank. Lo comparten el núcleo, los cuentos, los juegos y la casa |
| `nucleo` | Unidades léxicas que se quedan todo el mes | Citadas por identificador del registro léxico (apartado 6). Tamaño por edad, abajo |
| `formulas` | Fórmulas de turno y cortesía | Solo desde 3-4 años: *my turn*, *your turn*, *here you are*, *help me, please*, *thank you* y las de la unidad |
| `estructura` | Una estructura del mes | Solo desde 4-5 años: *in / on / under*, *because…*, *first… then…* |
| `ordenes` | Órdenes TPR del mes | Hechas **con palabras del núcleo**. Cada una con su gesto en gl y es |
| `realia` | Objetos reales para la mesa o la casa | Seguros para la edad. Sin compra obligatoria |
| `contraste` | Un contraste de sonido para el oído de la adulta | Solo si la voz inglesa de la app (inglés americano) lo produce. Desde 18 meses |
| `cancion` | Canción con pulso | El pulso sale de las marcas `*` de la letra y se dibuja |
| `microcuento` | Cuento dialógico de la unidad | Desde 2 años (apartado 5) |
| `hogar` | La guía de la casa para ese mes: cuatro retos semanales, lectura del microcuento, juego, qué observar y reactivación | Ver el apartado 8.3 |
| `queObservar` | Qué puede mirar la adulta en el aula | Cuerpo, objeto, sonido y fórmula. Sin casilla, sin guardado |
| `reactivar` | Núcleos de unidades anteriores que vuelven | El del mes anterior, de forma incidental, en la fase de calma y en un reto |

### Tamaño del núcleo por edad

| Curso | Núcleo | Además | Preguntas en inglés |
| --- | --- | --- | --- |
| 0-2, hasta 18 meses | 3 palabras o expresiones de rutina | — | Ninguna. Habla paralela y espera |
| 0-2, desde 18 meses | 4-5 | — | Señalar |
| 2-3 | 5 | — | Señalar e imitar |
| 3-4 | 5 | 2 fórmulas | Señalar, imitar y algo de acercar |
| 4-5 | 5 + 3 descriptivas | 2 fórmulas, 1 estructura | Las tres |
| 5-6 | 5 + 3 descriptivas | 2 fórmulas, 1 estructura, juego de rima | Las tres |

Los textos de base no escriben nada para menos de 18 meses. Para ese tramo, la
arquitectura aplica lo que sí dicen los cinco: persona delante, parentese,
habla paralela, espera y rutina. Sin preguntas.

### El banco del mes

El banco de `assets/content/tpr/` (80 palabras al mes y cinco nuevas al día)
lo pide el documento de Frank *Modelo de Adquisición Natural* y lo vigila un
gate. En esta arquitectura **es la ampliación de la unidad, no su puerta**:

- el núcleo sale de las órdenes de la asamblea del mes y de las palabras del
  banco que encajan con su centro de interés; lo que no está en el banco va al
  registro de frases (apartado 6). El banco no se mueve: sus 800 palabras por
  curso, sus identificadores y los cuentos semanales que las llevan siguen
  como están;
- Hoy enseña primero el núcleo y debajo las cinco del día;
- el cuento de la semana sigue llevando las veinte de su semana.

Cambiar el tamaño del banco no forma parte de esta arquitectura; sería una
decisión aparte.

## 4. El ritmo: mes, semana y día

**El mes** es la unidad.

**La semana** sigue la progresión que ya existe (`assets/content/progresion/`)
y la repetición distribuida que pide el texto de vocabulario:

| Semana | Nombre | Qué pasa con el núcleo |
| --- | --- | --- |
| 1 | Descubrir | Se presenta con el objeto, una unidad cada vez, con modelado completo |
| 2 | Practicar | Vuelve dentro de otras actividades: rutinas, juego, transiciones |
| 3 | Combinar | Se junta con las fórmulas y la estructura (desde 3-4 años) |
| 4 | Consolidar | Microcuento y reto de cierre; reaparece el núcleo del mes anterior |

**El día** depende del ciclo:

- **1.º ciclo (0-3).** No hay franja de inglés. La asamblea de cuatro fases
  (unos 9 minutos) y las rutinas del día (aseo, comida, cambios de espacio)
  llevan el núcleo. Lo dice la educadora titular.
- **2.º ciclo (3-6).** La asamblea diaria de cuatro fases (unos 10 minutos)
  lleva las órdenes del núcleo. La aproximación al inglés vive dentro del
  período semanal que fija la Orden de 30 de mayo de 2023, en una sesión o en
  dos medias sesiones. Lo que esta app ofrezca para ese período se contrasta
  antes con el DOG (horario y criterio).

**La asamblea** mantiene sus cuatro fases: apertura, pulso, reto TPR y calma.
Es la forma corta de las cuatro fases de SparkLing (acogida, cuento, taller y
despedida), con una sola adulta y sin cambiar el horario del centro. **Es el
único modelo de asamblea de la app.**

## 5. El cuento

Hay dos piezas distintas, con funciones distintas.

| Pieza | Para qué | Forma |
| --- | --- | --- |
| **Cuento de la semana** | Baño de lenguaje con las veinte palabras de la semana | El que ya hay: páginas, pregunta por página, preguntas graduadas en gl/es y espera visible |
| **Microcuento de la unidad** | Conversación en inglés sobre el núcleo | 3 láminas (2-3 y 3-4 años) o 4 (4-5 y 5-6). Trama en gl y es, una frase de Lúa por lámina, tríada en inglés, espera y guion de recast |

Por cada lámina del microcuento:

- **Lámina limpia**: una acción, un contraste, sin fondo que compita. Sin
  lámina dibujada, el microcuento no entra.
- **Frase de Lúa** en inglés, en el momento de más carga, con gesto y
  onomatopeya. Solo usa palabras del núcleo y, desde 4-5 años, la estructura.
- **Tríada**: señalar, imitar con el cuerpo y acercar a su vida. El peso
  cambia con la edad: en 2-3 y 3-4, sobre todo señalar e imitar; en 4-5 y 5-6,
  las tres.
- **Espera** en tres tiempos (apartado 7), visible y en silencio.
- **Guion de recast** para cinco respuestas: silencio, señala, contesta en la
  lengua de casa, dice una palabra, dice la forma torcida.

**En casa, el mismo microcuento** se lee en PEER, con una sola pregunta por
lámina y no las tres.

## 6. El registro léxico

Hoy el inglés de la app sale de muchas fuentes: el banco, el léxico mensual
del calendario, las órdenes de las asambleas, las dinámicas, los juegos de
casa, STEAM, las láminas, el corpus de uso habitual y las colocaciones. En esta
arquitectura:

- **El registro tiene dos partes, y las dos tienen identificador estable.**
  - **El banco TPR** (`assets/content/tpr/`): las palabras del trayecto, con
    el esquema `<curso>.<mes>.s<semana>.<clave>`. El curso 3-4 usa hoy
    identificadores sin prefijo; se normalizan con su tabla de equivalencias y
    con la migración del repaso guardado, que usa un hash del identificador.
    El banco está cerrado (800 por curso; cada cuento semanal lleva sus
    veinte) y no recibe expresiones nuevas.
  - **El registro de frases** (`assets/content/registro/frases.json`): todo lo
    que no es palabra del banco, como órdenes de asamblea, fórmulas de turno,
    frases de Lúa, retos y frases de juegos, dinámicas y STEAM. Cada frase
    lleva su gesto en gl y es y su audio.
- **Todo lo demás cita identificadores.** Núcleo, órdenes, frase de Lúa, retos
  y juegos citan una de las dos partes; no copian la palabra. Si falta una
  expresión, se añade al registro de frases en el mismo cambio, con su gesto y
  su audio.
- **El corpus de 4.000 de uso habitual y las colocaciones son consulta de la
  adulta**, no currículo. No se cuentan como contenido de ninguna unidad.
- **La fonética se escribe en inglés americano**, que es la voz de la app.

## 7. Cómo habla la persona adulta

Una sola definición por herramienta. Los textos de base se contradicen en
varias; vale esta.

| Herramienta | Qué hace | Lo que no hace |
| --- | --- | --- |
| **Habla paralela** | Dice en presente lo que la criatura hace y mira, con frases cortas y pausas | Preguntas de examen; narrar lo que la criatura ya no mira; monólogo sin pausas |
| **Espera, en tres tiempos** | (1) Dice o pregunta y calla de 3 a 5 s. (2) Si llega respuesta, recast o expansión en el turno siguiente. (3) Otra espera de unos 3 s antes del elogio o de lo siguiente | Rellenar el silencio; preguntas en ráfaga; «Good job!» al instante |
| **Expansión** | Devuelve la palabra suelta dentro de una frase uno o dos elementos más larga | Discursos; repetir en telegráfico |
| **Recast** | Devuelve bien dicha la frase de la criatura, dentro de la conversación | «No», «se dice», «repite», «say», «can you say» |
| **Acoger la lengua de casa** | Valida en gl o es y devuelve la idea en inglés | Pedir la traducción |

**Aula y casa no son lo mismo.** En el aula hay un grupo y una adulta: la
espera es para el grupo, el recast se hace sobre la respuesta que llegue y la
app no pide ni guarda nombres. En casa hay una criatura: las herramientas van
tal cual, y en el cuento se lee con PEER (incitar, acoger, ampliar y retomar,
sin pedir repetir) y CROWD (completar, recordar, abrir, qué/dónde y acercar),
con una pregunta por lámina.

## 8. Indicaciones pedagógicas para el hogar

La casa no es una versión reducida del aula. Allí hay **una persona adulta y
una criatura**, sin grupo y sin horario lectivo, y las herramientas del
apartado 7 se aplican tal cual. Las indicaciones para el hogar son una capa
propia de la arquitectura, con tres niveles. Cada nivel vive en su JSON, en
gallego y en castellano, y ninguno se escribe en un widget.

### 8.1 La guía estable: lo que no cambia en todo el trayecto

Fichero: `assets/content/hogar/guia_hogar.json`. Reúne y sustituye lo que hoy
está repartido entre `formacion/formacion.familia.json`, las reglas de
`calendario/atencion.json` y la tarjeta de recast de Academy.

1. **La app es para ti, no para la criatura.** Escuchas la frase, la aprendes y
   la dices tú, con tu cara y tu gesto. El audio no se le pone a la criatura.
2. **La lengua de casa es la base.** Sea gallego, castellano u otra, la casa
   sigue hablando su lengua. El inglés son unos minutos, nunca sustituye a
   nada.
3. **Una lengua, una rutina.** El inglés va ligado a un momento fijo del día
   (el baño, la merienda, el paseo), siempre el mismo, para que la criatura
   sepa cuándo llega.
4. **Pocos minutos, el mismo momento.** Entre 2 y 8 minutos según la edad
   (8.2). Mejor tres minutos cada día que media hora el sábado.
5. **Cara a cara y cerca.** A su altura, de frente, con poco ruido de fondo y
   sin pantallas encendidas alrededor.
6. **Primero entender.** Que responda con el cuerpo (mirar, señalar, hacer el
   gesto, coger el objeto) ya es la respuesta.
7. **Nunca preguntes «¿cómo se dice?»**, no pidas que repita ni que traduzca, y
   no hagas listas de palabras.
8. **Si se equivoca o contesta en la lengua de casa**, acoges lo que dijo y le
   devuelves la frase bien dicha, sin señalar el error.
9. **Las cuatro herramientas en casa**: habla paralela, espera en tres tiempos,
   expansión y recast. Cada una con un ejemplo doméstico.
10. **No es una evaluación.** La app no guarda nada de tu criatura ni hace
    informes. Lo que cuenta la escuela de su progreso lo cuenta la escuela.

### 8.2 La guía por edad: cinco cursos

Fichero: `assets/content/hogar/hogar_por_edad.json`. Amplía
`calendario/atencion.json`, que hoy tiene cinco tramos hasta los 36 meses y
ninguno de 3 a 6 años.

| Edad | Minutos | Herramienta principal | Qué se le pide | Lectura |
| --- | --- | --- | --- | --- |
| 0-6 m | 2 | Parentese y habla paralela con contacto | Nada: mirar y sentir | Mirar una lámina juntos, sin preguntas |
| 6-12 m | 3 | Habla paralela, juegos de cucú y turnos de sonido | Nada: sonreír, balbucear | Igual |
| 12-18 m | 5 | Habla paralela y espera | Mirar y señalar, si sale | Una lámina, señalar |
| 18-24 m | 6 | Espera, órdenes con gesto y objeto | Hacer el gesto, coger el objeto | Microcuento señalando |
| 24-36 m | 8 | Órdenes, expansión y recast | Gesto, objeto, alguna palabra si sale | Microcuento de 3 láminas, PEER con una pregunta por lámina |
| 3-4 a | 8 | Fórmulas de turno en el juego (*my turn*, *here you are*) | Turnarse, dar y recibir | Microcuento de 3 láminas, PEER y CROWD: completar y qué/dónde |
| 4-5 a | 8-10 | Expansión, *because* en el juego | Colocar *in / on / under*, contar qué pasa | Microcuento de 4 láminas, CROWD: recordar y abrir |
| 5-6 a | 10 | Conversación, rimas y juegos de sonidos | Jugar con la rima, contar con sus palabras | Microcuento de 4 láminas, CROWD: las cinco, una por lámina |

Los minutos de 0 a 36 meses son los que ya tiene `atencion.json`; los de 3 a 6
años son una propuesta de esta arquitectura. Para cada fila, el JSON trae
además el momento del día recomendado, qué hacer, qué evitar y un ejemplo con
una frase inglesa del registro.

### 8.3 La guía de cada unidad: los 50 meses

Va dentro de la unidad (apartado 3), en un bloque `hogar`, para que la casa
cuente siempre lo mismo que el aula ese mes.

| Campo | Qué es |
| --- | --- |
| `retosCasa` | **Cuatro retos, uno por semana**, siguiendo la progresión: descubrir, practicar, combinar y consolidar. Cada reto lleva el momento del día, una frase del núcleo, qué hacer con las manos, el objeto de casa, la espera, qué no pedir y un recast para tres respuestas (silencio, lengua de casa, una palabra) |
| `lecturaCasa` | El microcuento de la unidad leído en casa: **una sola pregunta por lámina**, del tipo PEER o CROWD que toque por edad, con su ayuda en gl y es |
| `juegoCasa` | Un juego del mes, citado de los juegos de casa o del apartado de casa de STEAM. Si ninguno encaja con el centro de interés o la edad, se lista y no se fuerza |
| `queObservarCasa` | Dos o tres cosas que mirar (se gira al oír la frase, hace el gesto, coge el objeto, usa la frase en el juego). Sin casilla |
| `reactivarCasa` | Una línea para volver a la frase del mes anterior en otro momento del día |

Los retos del **2.º ciclo** parten de las micro-rutinas que ya traen las
asambleas (`microRutinaHogar`, con su momento, su tiempo y sus pautas de
recast): esa es la del primer reto, y las otras tres siguen su progresión. Los
del **1.º ciclo** no tienen todavía ninguna rutina de casa por mes y se
escriben enteros.

### 8.4 Dónde lo ve la familia

| Camino | Qué ve |
| --- | --- |
| Portal de familias → Hoy | El reto de esta semana, la frase con su audio (para la adulta), el núcleo del mes y el juego |
| Portal de familias → Calendario | Cada día: el reto de la semana y el momento del día |
| Explorar → Cuentos | El microcuento de la unidad, en modo casa: una pregunta por lámina |
| Explorar → Palabras en inglés | El núcleo del mes primero; el banco debajo |
| Guías → Antes de empezar | La versión de dos minutos de la guía estable |
| Guías → El modelo | La guía estable entera, la guía de su edad y los porqués |
| Guías → lecturas de Academy | Las cápsulas actuales, enlazadas al punto de la guía que desarrollan |

### 8.5 El puente entre aula y casa

- **La nota para las casas** cierra la asamblea con el reto de la semana. Es el
  **mismo identificador** que enseña Hoy en casa. Es de papel: se lee en alto y
  se copia, sin botón de compartir.
- La frase del reto es una frase que la criatura ya ha oído esa semana en la
  asamblea.
- **El cuaderno viajero** de objetos reales se queda fuera de la app: es un
  objeto físico y, si la escuela lo usa, es cosa suya. La app no lo registra.

## 9. La formación de la persona adulta

- **Antes de entrar / Antes de empezar**: puerta de dos minutos, en cada
  portal. La de la familia es el resumen de la guía estable del hogar
  (apartado 8.1).
- **El modelo**: un espacio en Eu (aula) y en Guías (casa), con tres partes:
  1. cómo funciona: los apartados 2 a 8 de este documento, en lenguaje de aula
     y de casa;
  2. los objetivos del tramo, como texto que explica qué mirar;
  3. qué no es un objetivo: una nota, un examen o que la criatura repita.
- **Estrategias de aula**: siete fichas, las cinco que ya hay más el habla
  paralela y la expansión, con el mismo molde (por qué, cómo, ejemplo, error
  que evitar). La espera pasa a tres tiempos. El andamiaje en tres niveles
  sigue siendo para las preguntas en gl/es del cuento de la semana; la tríada
  es para el inglés del microcuento.
- **Formación en el aula** pasa de seis pasos a las cuatro fases de la
  asamblea, más las herramientas del apartado 7.

## 10. Observación y registro

- **De la criatura no se guarda nada.** «Qué observar» nombra lo que se puede
  mirar (responde con el cuerpo, coge el objeto, se orienta al sonido, usa una
  fórmula) y no se marca. Las rúbricas, las escalas, los recuentos de turnos y
  los registros anecdóticos de los textos no entran.
- **De la persona adulta**, si Frank lo decide: una lista cerrada de su propia
  práctica (dije el núcleo con el objeto, esperé, hice el microcuento, copié la
  nota, hice el reto). Se guarda el día sin hora y los identificadores. Una
  clave nueva obliga, en el mismo cambio, a actualizar la política de
  privacidad, el formulario de Seguridad de los datos de Play Console y los dos
  gates de privacidad.
- **Los premios** siguen siendo de la persona adulta.

## 11. Reparto por pantallas

Por camino de uso, en los tres modos.

| Camino | Lee de | 1.º ciclo | 2.º ciclo | Casa |
| --- | --- | --- | --- | --- |
| Modo Aula → Hoy | unidad + banco del día | Núcleo con objeto, asamblea, cuento | Igual | — |
| Modo Aula → asamblea | unidad (`ordenes`, `cancion`, `reactivar`) | 4 fases, órdenes del núcleo, espera visible | Igual, con fórmulas | — |
| Modo Aula → Calendario | unidad | El día: núcleo, semana de la progresión y botón de la asamblea de **4 fases** | Igual | — |
| Portal de familias → Hoy | unidad (`hogar`) + guía por edad | — | — | Reto de la semana, frase con audio para la adulta, núcleo, juego |
| Guías → El modelo | guía estable + guía por edad | — | — | La guía entera de la casa (apartado 8) |
| Explorar → Cuentos | cuentos + microcuento (`lecturaCasa`) | — | — | El de la semana primero y el microcuento de la unidad, una pregunta por lámina |
| Visor de cuento | cuento / microcuento | Microcuento desde 2-3 años | Microcuento de 3 o 4 láminas | PEER con una pregunta por lámina |
| Eu → El modelo · Guías → El modelo | modelo | Sí | Sí | Sí |
| Recursos → Estrategias | estrategias | 7 fichas | 7 fichas | — |
| Recursos → Planificador | unidad | Área por su nombre oficial, centro, núcleo | Igual, con criterio contrastado | — |
| Recursos → Inglés | registro léxico | Núcleo primero; banco del mes debajo | Igual, con fórmulas marcadas | Explorar → Palabras en inglés |
| Dinámicas, Ciencia, Juegos de casa | su JSON + unidad | Sus frases inglesas citan el registro; espera y recast | Igual | Igual |
| Calendario de casa | unidad (`hogar`) | — | — | El día con el reto de la semana y su momento |

## 12. Lo que no entra

- Un área, una ficha, una nota o una evaluación de inglés.
- Guardar nada de una criatura: nombres, turnos, escalas, porcentajes o
  grabaciones.
- Sesiones diarias de 45 minutos, tres adultos, marioneta como reclamo,
  inmersión sin lengua de casa.
- Pedir a la criatura que repita, traduzca o conteste en inglés.
- Voz en directo, red o un metrónomo que suene.
- Lenguaje clínico: diagnóstico, mutismo, intervención o silencio clínico.
- Traducir la interfaz al inglés.
