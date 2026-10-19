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
4. **Los cinco textos de `docs/base/`**: currículo de inglés en Galicia,
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
| `centroInteres` | Un tema del mes, igual en aula y en casa | Uno solo. Lo comparten asamblea, cuentos, juegos y reto |
| `nucleo` | Unidades léxicas que se quedan todo el mes | Citadas por identificador del registro léxico (apartado 6). Tamaño por edad, abajo |
| `formulas` | Fórmulas de turno y cortesía | Solo desde 3-4 años: *my turn*, *your turn*, *here you are*, *help me, please*, *thank you* y las de la unidad |
| `estructura` | Una estructura del mes | Solo desde 4-5 años: *in / on / under*, *because…*, *first… then…* |
| `ordenes` | Órdenes TPR del mes | Hechas **con palabras del núcleo**. Cada una con su gesto en gl y es |
| `realia` | Objetos reales para la mesa o la casa | Seguros para la edad. Sin compra obligatoria |
| `contraste` | Un contraste de sonido para el oído de la adulta | Solo si la voz inglesa de la app (inglés americano) lo produce. Desde 18 meses |
| `cancion` | Canción con pulso | El pulso sale de las marcas `*` de la letra y se dibuja |
| `microcuento` | Cuento dialógico de la unidad | Desde 2 años (apartado 5) |
| `retosCasa` | Un reto por semana, cuatro por unidad | Un momento del día, una frase del núcleo, qué hacer con las manos, qué no pedir |
| `queObservar` | Qué puede mirar la adulta | Cuerpo, objeto, sonido y fórmula. Sin casilla, sin guardado |
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

- el núcleo sale del banco de ese mes, o se añade al banco en el mismo cambio;
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

- **El banco TPR es el registro canónico.** Cada unidad léxica tiene un
  identificador estable (`<curso>.<mes>.s<semana>.<clave>`). El curso 3-4 usa
  hoy identificadores sin prefijo; se normalizan con su tabla de equivalencias.
- **Todo lo demás cita identificadores.** Núcleo, órdenes, frase de Lúa, retos
  y frases de juegos citan el registro; no copian la palabra. Si falta una
  expresión, se añade al banco en el mismo cambio, con su gesto y su audio.
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

## 8. La casa

- **Hoy en casa**: el núcleo de la unidad, el reto de la semana (unos tres
  minutos, en un momento del día) y el juego del día.
- **La nota para las casas** cierra la asamblea con el reto de la semana. Es de
  papel: se lee en alto y se copia, sin botón de compartir.
- **Las guías de la familia** explican el modelo con ejemplos de casa.
- **El tiempo** se ajusta al tramo de edad. Las indicaciones de
  `assets/content/calendario/atencion.json` llegan hoy hasta los 36 meses; la
  arquitectura las amplía a 3-6 años.
- **El cuaderno viajero** de objetos reales se queda fuera de la app: es un
  objeto físico, no un registro.

## 9. La formación de la persona adulta

- **Antes de entrar / Antes de empezar**: puerta de dos minutos, en cada
  portal.
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
| Portal de familias → Hoy | unidad | — | — | Núcleo, reto de la semana, juego |
| Explorar → Cuentos | cuentos + microcuento | — | — | El de la semana primero y el microcuento de la unidad |
| Visor de cuento | cuento / microcuento | Microcuento desde 2-3 años | Microcuento de 3 o 4 láminas | PEER con una pregunta por lámina |
| Eu → El modelo · Guías → El modelo | modelo | Sí | Sí | Sí |
| Recursos → Estrategias | estrategias | 7 fichas | 7 fichas | — |
| Recursos → Planificador | unidad | Área por su nombre oficial, centro, núcleo | Igual, con criterio contrastado | — |
| Recursos → Inglés | registro léxico | Núcleo primero; banco del mes debajo | Igual, con fórmulas marcadas | Explorar → Palabras en inglés |
| Dinámicas, Ciencia, Juegos de casa | su JSON + unidad | Sus frases inglesas citan el registro; espera y recast | Igual | Igual |
| Calendario de casa | unidad | — | — | El día con el núcleo y el reto |

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
