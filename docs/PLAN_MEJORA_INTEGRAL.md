# Plan integral de mejora pedagógica

Qué cambia en **Descubre con Lúa · Edición Vigo** al aplicar los cinco textos
de `docs/base/`, en qué orden y cuándo se da cada pieza por hecha. **Este
documento no cambia ninguna pantalla.** Es el encargo. El contrato de datos
campo a campo está en `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`; donde los dos no
digan lo mismo, manda este hasta que la ola 0 los alinee.

Si este plan y el JSON no dicen lo mismo, manda el JSON: es lo que la app
enseña.

## 1. De dónde sale y qué manda

### Los documentos, por orden

1. **Las reglas de producto.** La criatura no usa la pantalla; cero datos de
   una crianza; sin red; nada sanitario; el contenido vive en JSON. El pulso
   de la canción se ve, no se oye. Ningún texto pasa por encima de esto.
2. **La normativa gallega**, leída en el DOG: Decreto 150/2022, Orden de 30 de
   mayo de 2023 y Decreto 79/2010. Manda sobre cualquier resumen de ella,
   incluido el de `docs/base/`.
3. **Los documentos curriculares de Frank que ya construyen la app**: el
   *Diseño Curricular Infantil Trilingüe Galicia* (2.º ciclo), la
   *Planificación Inglés Escuelas Infantiles* (1.º ciclo) y el *Modelo de
   Adquisición Natural y Proyección Anual* (el banco de cinco palabras al día,
   vigilado por `tools/planificador_5_palabras.py`). De ellos salen la
   asamblea de cuatro fases, las veinte microcápsulas del 1.º ciclo, la tarjeta
   única sin desplazamiento y el banco de 4.000 palabras.
4. **Los cinco textos de `docs/base/`.** Aportan lo que los anteriores no
   tienen: **cómo habla la persona adulta** (espera, recast, expansión, habla
   paralela), **una dosis corta y estable** dentro del banco, **el
   microcuento dialógico** y **el reto de casa**.

Los cinco textos son síntesis de trabajo, no normativa ni manuales oficiales.
Ninguna cifra, código de criterio o cita de un estudio pasa de ellos a una
pantalla sin contrastarla antes con su fuente primaria.

### Lo que esto quiere decir en la práctica

- **El banco y la dosis conviven.** Las cinco palabras nuevas al día siguen
  (lo pide el documento 3 y lo vigila un gate). La dosis no las sustituye:
  marca, dentro del banco de ese mes, el grupo corto que se queda varias
  semanas, se dice con el objeto y vuelve en el cuento y en casa.
- **Translanguaging, no inmersión total.** La trama y la interfaz van en
  gallego y en castellano; Lúa pone la frase inglesa. La regla de SparkLing de
  no pasar nunca a la lengua de casa no entra: choca con el Decreto 79/2010 y
  con el cuento dialógico, que acoge la respuesta en la lengua de casa.
- **Nunca se pide repetir, en ninguna lengua.** Tampoco con «Say…», «Can you
  say…?», «Repeat», «Dime cómo se dice» ni «Di…». Los textos de base sí lo
  piden en varios sitios (el cuarto paso de PEER, algún guion de recast). Aquí
  ese paso se llama **retomar**: la persona adulta vuelve a decir la frase con
  el gesto y deja el hueco abierto. Si la criatura la dice, bien; si no,
  también.

## 2. Lo que la app ya tiene y se respeta

Comprobado en el contenido y en el código, no de memoria:

- Cinco cursos (0-2, 2-3, 3-4, 4-5 y 5-6), diez meses cada uno. Cada mes del
  banco (`assets/content/tpr/`) trae 80 palabras, 20 por semana, con su gesto
  en gallego y en castellano.
- Asamblea de cuatro fases: apertura, pulso, reto TPR y calma. Son 20 del
  1.º ciclo (10 meses × 2 tramos, 9 minutos, unos 3,5 de inglés) y 30 del
  2.º ciclo (10 meses × 3 niveles, 10 minutos, unos 4,5 de inglés). Las
  órdenes del 1.º ciclo ya dicen «fai o xesto mentres di a orde, e agarda sen
  esixir resposta».
- Cuento de la semana con sus veinte palabras, una pregunta por página y
  preguntas graduadas. El dato trae `tempoEsperaSegundos: 5`, pero el visor
  no lo dibuja.
- Cinco estrategias en `assets/content/estrategias_pedagogicas.json`: espera
  de 5 segundos, andamiaje en tres niveles, eco correctivo, cero pantallas y
  baño de lenguaje.
- Formación de entrada: seis pasos para la docente y seis para la familia
  (`assets/content/formacion/`).
- Nota para las casas, sin botón de compartir; repaso espaciado de la persona
  adulta; «qué observar» sin casilla.
- Voz inglesa en inglés americano (`en_US-ljspeech-medium`).

## 3. Lo que falta, en una línea cada cosa

1. La persona adulta no tiene **una sola manera de hablar** escrita: faltan el
   habla paralela y la expansión, y la espera no distingue sus dos tiempos.
2. **No hay dosis**: Hoy enseña cinco palabras nuevas cada día y ninguna se
   queda.
3. **La espera no se ve** en ninguna pantalla.
4. **No hay microcuento dialógico**: lámina corta, frase de Lúa, tres
   preguntas en inglés y un guion para cada tipo de respuesta.
5. **La nota para las casas no lleva reto**.
6. **La formación no explica el modelo entero** ni nombra sus objetivos.
7. **Lo que se cuenta no es el modelo**: los premios cuentan sesiones abiertas,
   no si se esperó, se dijo la dosis o se hizo el reto.

## 4. Decisiones que toma Frank

El plan avanza con la opción marcada. Las cinco son reversibles hasta la ola
en que se usan.

| # | Decisión | Opción con la que avanza el plan | Se usa en |
| --- | --- | --- | --- |
| D1 | Qué documento manda | El orden del apartado 1 | Ola 0 |
| D2 | Inmersión o translanguaging | Translanguaging: trama en gl/es y frase de Lúa en inglés | Ola 1 |
| D3 | Pedir repetir | Prohibido en las tres lenguas; PEER termina en «retomar» | Ola 1 |
| D4 | Mes piloto | Mayo, 1.º ciclo, los dos tramos (apartado 7) | Ola 2 |
| D5 | Cuántos microcuentos | Los dos arquetipos ahora; la extensión, después del piloto | Ola 4 |

## 5. El modelo, con una sola definición por pieza

Este glosario es la fuente única. El JSON de formación y las fichas lo citan;
no lo reescriben. Los cinco textos se contradicen en varias de estas piezas;
la definición de aquí es la que vale.

| Pieza | Definición que vale | Lo que se corrige de los textos |
| --- | --- | --- |
| **Dosis** | Cinco unidades de un mes ya existente del banco, citadas por su identificador, que se quedan todo el mes. Concretas, con objeto real y gesto, de una a tres palabras | El texto de vocabulario coloca seis unidades de seis semanas en un calendario que se solapa y se sale del curso. Aquí manda el calendario de diez meses de la app |
| **Espera** | Tres tiempos fijos: (1) la adulta dice o pregunta y calla de 3 a 5 s; (2) si llega respuesta, recast o expansión **en el turno siguiente, sin pausa**; (3) después, otra espera de unos 3 s **antes del elogio** o de la pregunta siguiente | Un texto pide el recast en menos de 2 s y otro pide 3 s de silencio antes de cualquier comentario. La secuencia de tres tiempos resuelve el choque |
| **Recast** | Devolver bien dicha la frase de la criatura, dentro de la conversación, sin «no», sin «se dice» y sin pedir que la diga | Fuera los ejemplos clínicos («tat → cat»), los modelos con un inglés poco natural y los que acaban pidiendo repetir |
| **Expansión** | Devolver la palabra suelta dentro de una frase **uno o dos elementos más larga**, no más | Los ejemplos del catálogo rompen su propia regla. Se reescriben con +1/+2 |
| **Habla paralela** | Decir en presente lo que la criatura está haciendo y mirando, con frases cortas y pausas, sin preguntas de examen | Los ejemplos del catálogo pasan de doce palabras. Se acortan |
| **Tríada del microcuento** | Por lámina, tres preguntas en inglés: **señalar**, **imitar con el cuerpo**, **acercar a su vida** | No se llama CROWD: CROWD son los cinco tipos de pregunta de la lectura dialógica. En 2 de las 7 láminas, el «acercar» de los textos no acerca nada; se reescribe |
| **PEER en casa** | Incitar, acoger, ampliar, **retomar** (sin pedir repetir) | El paso *Repeat* del texto pide repetir. Se cambia |
| **CROWD en casa** | Completar, recordar, abrir, qué/dónde, acercar a la vida. **Una sola pregunta por lámina** | Nada |

**En el aula hay un grupo; en casa, una criatura.** Las cuatro herramientas
nacieron para una o dos criaturas. En la asamblea la espera es **para el
grupo**, el recast se hace **sobre la respuesta que llegue** y la app no pide
ni guarda nombres. En casa se aplican tal cual, con una sola criatura.

**Fonética con la voz que suena.** La voz inglesa de la app es americana. Un
contraste solo entra si esa voz lo produce: /ɪ/ frente a /iː/ (*fish*, *sea*)
sí; /ɒ/ frente a /ɔː/ (*box*, *ball*) no, porque en inglés americano no existe
así. Las transcripciones que entren se escriben en americano.

## 6. Qué entra de cada texto

| Texto | Entra | Se adapta | No entra |
| --- | --- | --- | --- |
| Currículo de inglés en Galicia | El inglés como aproximación dentro del Área de Comunicación y Representación de la Realidad. Sin asignatura, sin ficha, sin nota. En 0-3, incidental y dentro de la rutina | El código de criterio (CA2.7 en el texto, CA1.1/CA3.1 en las asambleas actuales) se contrasta con el DOG antes de pintarlo | La rúbrica por criatura; las afirmaciones sobre la Inspección que no tienen fuente primaria |
| Currículo de vocabulario 2-6 | Dosis corta con objeto y gesto, objetivos del tramo como texto explicativo, el reto de casa por unidad, PEER y CROWD en casa | Calendario, fonética (al inglés americano y a los contrastes que la voz produce), PEER sin repetir | La rúbrica de cuatro estadios, la escala de turnos, el registro anecdótico, el horario de 09:00 a 13:00 en inglés, el 80 % como dato |
| Cuentos dialógicos | Microcuento de 3 láminas (2-3 años) o de 4 (4-6), frase de Lúa, tríada, guion de recast por tipo de respuesta, lámina limpia | Identificadores únicos, escenario de la edad que toca, color del pez coherente, 1-2 palabras diana (2-3 años) y 3-4 (4-6), gallego del segundo cuento | La matriz combinatoria como promesa de calidad; «mutismo selectivo», «diagnóstico» y cualquier lenguaje clínico |
| Estrategias de apoyo | Las cuatro herramientas y lo que hay que evitar con cada una | Ejemplos reescritos, espera en tres tiempos, versión para grupo | Dosis clínica, ejemplos de trastorno fonológico, «silencio clínico» como nombre |
| Rutinas SparkLing | Persona delante y no grabación; bajar al suelo; cierre previsible con dos o tres objetos | La forma de cuatro fases ya existe en la asamblea; solo se le pone la manera de hablar | 45 minutos diarios, tres adultos, marioneta como reclamo, nombres, LENA, pruebas, inmersión sin L1, «Good job» inmediato |

## 7. El piloto: mayo, primer ciclo

**Por qué mayo y por qué el 1.º ciclo.** Es donde el texto de vocabulario
escribe una unidad entera (agua, chapoteo, mojado, baño) y donde la app ya
tiene ese mismo centro de interés:

- la asamblea `asamblea.primeiro_ciclo.maio.0_2_anos` («auga, salpicaduras e
  rutinas de aseo»), con la orden *Wash, wash, clean hands!*;
- la de 2-3 del mismo mes, con *Wash your face!* y *Dry your toes!*;
- el banco de 0-2, semana 1 («Chapoteo»), con *Splish, splash!*, *All wet!*,
  *Splash about*, *Kick water* y *Water tray*;
- el banco de 2-3, semanas 1 y 3, con *Tap water*, *Soap, rub, rinse*, *Wet
  sponge*, *Splashing* y *Bubbly water*;
- el reto de casa del texto, el baño con *All wet!*, que en 0-2 ya existe como
  palabra del banco.

El piloto que se propuso antes (curso 2-3 con *water*, *splash*, *boat*, *wet*
y *fish*) no se puede hacer: esas cinco palabras no están en el banco de 2-3.

**La dosis del piloto.** Cinco identificadores por tramo, todos de la lista de
arriba. La lista definitiva la elige Frank. Si falta una palabra, se dice cuál
falta; no se inventa un identificador.

**El reto de casa del piloto.** El momento del baño: una frase (*All wet!* o
*Splish, splash!*), el gesto de chapotear, esperar y no pedir que lo diga. En
gallego y en castellano, con la frase inglesa grabada.

## 8. Recorrido por la app

Los caminos son los que usa quien abre la app, no los ficheros. Cada fila dice
en cuál de los tres modos se ve: aula del 1.º ciclo, aula del 2.º ciclo y casa.

**Restricción de disposición.** El aula funciona con una tarjeta única, sin
desplazamiento vertical (hay un gate que lo vigila) y con la consigna a 26 pt.
Todo lo que se añada ahí **sustituye o se pliega**; no se apila. Si no cabe,
se rediseña la tarjeta entera y se mira en gallego, en castellano y con texto
grande antes de darla por buena.

| Camino | Qué cambia | 1.º ciclo | 2.º ciclo | Casa |
| --- | --- | --- | --- | --- |
| Inicio → Modo Aula → Hoy | Arriba, la dosis del mes con su objeto real; debajo sigue el día del banco | Sí | Sí | — |
| Inicio → Portal de familias → Hoy | La dosis, la frase y el reto de tres minutos, no las 80 palabras del mes | — | — | Sí |
| Asamblea, fase de reto TPR | Una línea para la adulta (qué decir, cuánto callar, que el silencio es normal) y la cuenta de espera visual | Sí | Sí | — |
| Asamblea, cierre | La nota para las casas lleva el reto del mes. Sigue sin botón de compartir | Sí | Sí | — |
| Cuento de la semana | La cuenta visual de espera que el dato ya anuncia. No gana preguntas nuevas | Sí | Sí | Sí |
| Explorar → Cuentos | Los microcuentos, como cuentos de la lista y no como un modo aparte; lámina, frase de Lúa con altavoz, tríada, espera visual y guion de recast | 3 láminas | 4 láminas | Una pregunta por lámina (PEER) |
| Eu → El modelo · Guías → El modelo | Espacio nuevo con tres partes: cómo funciona, objetivos del tramo y qué no es un objetivo | Sí | Sí | Sí |
| Recursos → Estrategias | Se suman el habla paralela y la expansión con el molde de las cinco que hay; la espera pasa a tres tiempos | Sí | Sí | — |
| Recursos → Programación | El área por su nombre oficial y la dosis del mes. Nunca «Área de Inglés» | Sí | Sí | — |
| Recursos → inglés (palabras, repaso, colocaciones, sonidos) | Primero la dosis; las fórmulas de turno marcadas; los contrastes de sonido, solo los que la voz produce | Sí | Sí | Explorar → inglés |
| Calendario | Ese día enseña la dosis. La casilla, si la hay, es de la persona adulta | Sí | Sí | Sí |
| Premios | Siguen siendo de la persona adulta. Una insignia nueva solo puede contar semanas de la lista del adulto | Sí | Sí | Sí |

## 9. Olas

Cada ola se termina en todas las capas que toca antes de abrir la siguiente.
Las capas son: JSON en gallego, JSON en castellano, audio inglés de cada frase
que se oye, audio gl/es si esa cadena se reproduce, imprimible, textos de la
interfaz, manual y, si cambia lo que se guarda, la política de privacidad y el
formulario de Seguridad de los datos de Play Console.

**Cada ola está hecha cuando:**

1. el JSON gallego y el castellano dicen lo mismo;
2. el audio está en el mismo cambio que el texto;
3. `tools/gates.sh` sale verde y el APK de release sigue sin permiso de red;
4. se abre la app, se llega por el camino de la tabla y se miran las capturas
   en gallego y en castellano, también con texto grande.

Hasta entonces, la ola está en la rama, pendiente de mergear.

### Ola 0 · Alinear la base (solo documentos)

- Alinear `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md` con este plan: piloto, espera
  en tres tiempos, «retomar», tríada sin la palabra CROWD, formulario de Play
  Console y restricción de no desplazamiento.
- Una **fe de erratas** de los cinco textos (identificadores repetidos,
  fonética, ejemplos que piden repetir, lenguaje clínico), para que ningún
  error pase al JSON.
- Contrastar con el DOG el área, el bloque y el código de criterio (CA2.7
  frente a CA1.1/CA3.1) y el horario del 2.º ciclo.
- `docs/base/` sale del sitio público, o cada fichero se titula como síntesis
  de trabajo y el nombre del texto de SparkLing deja de nombrar a I-LABS.

**Hecho cuando** los dos planes dicen lo mismo, la fe de erratas existe y el
código de criterio que vaya a pantalla lleva al lado su cita del DOG.

### Ola 1 · El modelo en su espacio

- El glosario del apartado 5, en JSON, en gallego y en castellano, con el
  ejemplo del aula y el de casa.
- El espacio «El modelo» en Eu y en Guías.
- Las dos estrategias nuevas en Recursos → Estrategias y la espera en tres
  tiempos.
- **Gate nuevo**: falla si cualquier consigna, guion o pregunta, en gl, es o
  en, pide repetir o corrige de forma explícita («say», «can you say»,
  «repeat», «repite», «di», «dime cómo se dice», «no se dice así», «that's
  wrong»).

**Hecho cuando** las dos puertas abren el mismo esqueleto en las dos lenguas
y el gate está en `tools/gates.sh`.

### Ola 2 · El piloto del día (mayo, 1.º ciclo)

- Un JSON de dosis por tramo que cita identificadores.
- Hoy en el aula y Hoy en casa, la línea para la adulta de la asamblea de mayo
  y el calendario de los dos portales.
- La nota para las casas con el reto del baño.

**Hecho cuando** el mismo identificador aparece en la dosis, en Hoy del aula,
en Hoy de casa y en la nota, y el gate del banco sigue verde.

### Ola 3 · La espera se ve

Una cuenta visual y silenciosa, con los segundos del dato, en el cuento de la
semana, en la fase de reto de la asamblea y en el visor del microcuento.

**Hecho cuando** se ve en los tres sitios, en las dos lenguas, sin sonido.

### Ola 4 · Los dos microcuentos

*Lúa e o peixiño azul* (2-3 años, 3 láminas) y *Lúa y el viento travieso*
(4-6 años, 4 láminas), con las correcciones de la fe de erratas. El gallego del
segundo se escribe en esta ola, título incluido. Para cada lámina: dibujo
propio de lámina limpia, frase de Lúa grabada, tríada grabada y guion de
recast por tipo de respuesta (silencio, señala, contesta en la lengua de casa,
una palabra, forma torcida).

Volumen estimado de audio inglés: unas seis frases por lámina, unas 42 en
total. Sin lámina dibujada, el cuento no entra en la lista.

**Hecho cuando** cada microcuento se abre desde Explorar → Cuentos en los dos
portales y en las dos lenguas, y cada lámina enseña su tríada, su guion y su
espera.

### Ola 5 · La dosis en todo el curso

El piloto es una muestra, no el encargo. Esta ola lleva la dosis y el reto de
casa a los **50 meses** del trayecto (5 cursos × 10 meses): 50 dosis y 50
retos. Cada dosis cita cinco identificadores del banco de su mes, con las
reglas del apartado 5. Donde un mes no tenga cinco candidatas que cumplan, se
lista el mes y lo que falta, y lo decide Frank. No se rellena con palabras
inventadas.

**Hecho cuando** cada uno de los 50 meses tiene dosis y reto en las dos
lenguas, o figura en la lista de meses pendientes con su motivo.

### Ola 6 · El banco de inglés y el resto de la jornada

- Palabras, repaso, colocaciones y sonidos abren por la dosis.
- Las fórmulas de turno de 3 a 6 años (*my turn*, *your turn*, *here you
  are*, *help me, please*) quedan marcadas.
- Los contrastes de sonido se limitan a los que la voz produce.
- En Dinámicas y en Ciencia, solo donde ya haya una frase inglesa, la línea de
  espera y recast.
- En Programación, el área por su nombre oficial.

**Hecho cuando** ninguna de esas pantallas llama al inglés asignatura, ninguna
pide un dato de una criatura y, en el mes de la dosis, lo primero que se ve es
la dosis.

### Ola 7 · La lista de la persona adulta

Una lista cerrada que se marca al terminar Hoy y desde «El modelo»:

- en el aula: dije la dosis con el objeto, esperé, hice la pausa del cuento,
  copié la nota;
- en casa: hice el momento de tres minutos, dije la frase con el gesto, no
  pedí que lo dijera.

Se guarda el día sin hora y los identificadores marcados. Nada de texto libre,
porcentajes ni nombres.

Es un apoyo para que la persona adulta mire su propia práctica, no una medida
de lo que aprende la criatura.

**Hecho cuando** un día marcado se cierra, se vuelve a abrir y se ve igual, y
en el mismo cambio se han actualizado la política de privacidad, el formulario
de Seguridad de los datos y los dos gates (`test/features/premios_test.dart` y
`test/core/progreso_privacidad_test.dart`).

### Ola 8 · El papel y la guía

Manual, imprimibles y README, en cada página de lo que se haya tocado.

**Hecho cuando** el manual, mirado página a página, y la pantalla dicen lo
mismo.

### Dependencias

- La ola 0 va antes que todo.
- La 1 va antes que la 2 y la 4, porque sin glosario no hay guion.
- La 3 comparte pantalla con la 4.
- La 5 espera a que el piloto se haya visto.
- La 7 espera a la 2, porque no se marca una dosis que no existe.

## 10. Riesgos y cómo se cubren

| Riesgo | Cobertura |
| --- | --- |
| Llevar a una pantalla una cifra o un código que solo dice un resumen | Ola 0: todo dato normativo va con su cita del DOG; las cifras de estudios no se pintan |
| Que un «repite» se cuele en una de las tres lenguas | Gate de la ola 1 |
| Que la tarjeta del aula desborde en gallego o con texto grande | Se sustituye o se pliega, no se apila; captura con texto grande antes de dar algo por bueno |
| Que la dosis se lea como «menos inglés» que el banco | El banco sigue intacto; la dosis solo dice cuáles se quedan |
| Que la lista del adulto se lea como evaluación | No guarda nada de la criatura y lo dice en pantalla |
| Que una frase inglesa no tenga audio | Texto y audio en el mismo cambio; sin grabación no hay botón de voz |
| Que el lenguaje clínico de los textos llegue a la app | Fe de erratas y revisión de cada JSON nuevo con la regla «nada sanitario» |

## 11. Qué no entra

- Un área, una ficha o una nota de inglés.
- Guardar qué dijo o qué hizo una criatura, el 80 %, una escala por niño,
  turnos o grabaciones.
- Sesiones diarias de 45 minutos, tres adultos o inmersión sin lengua de casa.
- Pedir a la criatura que repita, traduzca o conteste en inglés.
- Borrar o adelgazar el banco de 4.000 palabras sin un encargo aparte.
- Voz en directo, red o un metrónomo que suene.
- Traducir la interfaz al inglés.
