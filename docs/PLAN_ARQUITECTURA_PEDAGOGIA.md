# Plan de arquitectura pedagógica

Plan de trabajo para integrar en **Descubre con Lúa · Edición Vigo** cinco
textos de base. No cambia la app: dice qué pieza entra, en qué capa, y en qué
orden. Lo que la app enseña sigue viviendo en JSON. Si este plan y el JSON no
dicen lo mismo, manda el JSON.

Este fichero es el contrato de datos. El recorrido de todo el producto —qué
pantalla mejora, cuál no, y en qué ola— está en
`docs/PLAN_MEJORA_INTEGRAL.md`. Si los dos no dicen lo mismo, se corrige el
que se haya quedado atrás: no se elige uno en silencio.

Los textos se leyeron enteros el 17 de octubre de 2026, desde los ficheros
que llegaron a la sesión. No están copiados en el repositorio. Son estos:

| Texto | Qué aporta |
| --- | --- |
| Biblioteca de cuentos dialógicos bilingües | Microcuento de 3 o 4 láminas, pregunta en tres niveles, pausa y recast |
| Currículo de inglés infantil de Galicia | El inglés no es asignatura: es aproximación dentro del Área de Comunicación |
| Currículo de vocabulario, 2 a 6 años | Dosis léxica corta, anclada a objetos y al cuerpo, con un reto en casa |
| Estrategias de apoyo lingüístico | Cuatro herramientas del adulto: recast, expansión, habla paralela, espera |
| Manual de rutinas SparkLing (UW I-LABS) | Cómo habla el adulto en vivo: turno, espera, modelado, cierre predecible |

El mapa de pantallas de abajo se comprobó en el código de la rama
`pedagogia`, no en `PROJECT.md`. Ese fichero describe un esqueleto anterior
(una unidad y una cápsula) y no es el producto que se abre hoy.

## Lo que no se toca

Estas cinco reglas mandan sobre los cinco textos. Si un texto pide lo
contrario, no entra.

1. **La criatura no usa la pantalla.** La pantalla es el guion de la persona
   adulta. La criatura oye, mira los materiales y responde con el cuerpo.
2. **Cero datos de una crianza.** Nada de nombres, anecdotarios, escalas por
   niño ni recuento de turnos. Los premios siguen siendo del adulto.
3. **Sin red.** Una frase nueva en inglés lleva su grabación dentro del
   paquete, en el mismo cambio que el texto. No hay voz en directo ni
   descarga.
4. **Nada sanitario.** No se observa para diagnosticar, no hay prueba, no hay
   nota de inglés. La espera y el recast son la manera de hablar, no una
   terapia.
5. **El inglés no es una lengua de la interfaz.** Se oye. El gallego y el
   castellano siguen siendo las lenguas de la pantalla, las dos, con paridad.

El pulso de la canción sigue siendo visual. Un metrónomo sonoro competiría
con la voz que hay que seguir.

## Qué pide cada texto, en una pieza

### Galicia: cuándo y con qué nombre

El Decreto 150/2022 y la Orden de 30 de mayo de 2023, tal como los resume el
currículo gallego:

- El inglés vive en el **Área de Comunicación y Representación de la
  Realidad**, bloque de las lenguas y sus hablantes. El objetivo de área es
  OBX5. El criterio del segundo ciclo es CA2.7: participar en intercambios
  sencillos ligados a rutinas.
- **No es asignatura.** No hay «Área de Inglés», ni ficha, ni cuaderno, ni
  nota aparte. En segundo ciclo cabe un período lectivo a la semana, mejor
  en dos medias sesiones. En primer ciclo (0-3) no hay franja ni especialista:
  es estímulo dentro de la rutina del tutor.
- El gallego y el castellano no ceden su sitio. El inglés no se evalúa solo.
  Lo que una docente puede mirar es si la criatura responde con el cuerpo,
  sigue una canción o un cuento, y usa una fórmula en el juego. Eso no se
  guarda en la app.

### Vocabulario: cuánto y con qué

De 18 a 36 meses, seis unidades de unas seis semanas, **cinco palabras** cada
una, con objeto real, gesto y un contraste de sonido frente al gallego o al
castellano. De 3 a 6 años, seis unidades de unas ocho semanas (construcción,
restaurante, veterinaria, tiempo, arte, viajes): léxico básico y léxico de
relación, fórmulas de turno (`my turn`, `here you are`), preposiciones y, más
tarde, un `because`. Cada unidad trae un rincón de juego y **un micro-reto en
casa**, y la lectura en casa sigue PEER (incitar, acoger, ampliar, retomar) y
CROWD (completar, recordar, abrir, preguntar qué/dónde, acercar a la vida).

La dosis es corta a propósito. El texto lo dice así: un bloque pequeño y
funcional, no una lista para memorizar.

### Cuentos dialógicos: la unidad narrativa

Un cuento son **tres láminas** a los 2-3 años o **cuatro** a los 4-6. Dura
dos o tres minutos. La trama va en gallego o en castellano. Lúa dice **una
frase en inglés** en el momento de más carga, con gesto y onomatopeya. Cada
lámina trae tres preguntas en inglés:

1. señalar;
2. imitar con el cuerpo;
3. acercar la escena a la vida de la criatura.

Después de cada pregunta, **cinco segundos** de espera. Si la criatura calla,
señala, responde en gallego o castellano, dice una sola palabra o deforma la
frase, el adulto tiene un guion de recast: acoge y devuelve la frase bien
dicha, sin «mal» y sin «repite».

El texto trae el molde (escenario, conflicto, gesto, desenlace) y dos cuentos
ya escritos: *Lúa e o peixiño azul* (2-3) y *Lúa y el viento travieso* (4-6).
Esos dos son el arquetipo. El catálogo de cien no se inventa en este plan.

### Apoyo lingüístico: las cuatro herramientas

Van siempre juntas, en este orden cuando la criatura está jugando:

1. **Habla paralela.** El adulto dice lo que la criatura está haciendo, en
   presente, sin examen (`You are putting the red block on top`).
2. **Espera.** Un silencio de 3 a 5 segundos después de hablar, y otro
   después de que la criatura responda, antes del elogio.
3. **Expansión.** Una palabra suelta se devuelve dentro de una frase corta,
   un escalón por encima, no un discurso.
4. **Recast.** Si la forma falla, se devuelve la forma bien dicha dentro de
   la conversación, en el turno siguiente, sin corrección explícita.

Lo que el texto prohíbe: «no se dice así», la ráfaga de preguntas, el habla
telegráfica del adulto y narrar un objeto que la criatura ya no está mirando.

### SparkLing: cómo suena la sesión, no cuánto dura

Lo que sí entra: la criatura aprende la lengua nueva con una persona delante,
no con un vídeo; el adulto baja al suelo, espera el turno, modela con calma
y cierra con un ritual. Las cuatro fases del manual (acogida con pulso,
cuento, taller de gesto, despedida con dos o tres objetos) son la forma de
una sesión **cuando hay equipo y cuarenta y cinco minutos**.

Lo que no entra, porque choca con Galicia o con las reglas de arriba:

- una sesión diaria de 45 minutos y tres adultos (el segundo ciclo tiene un
  período a la semana; el primero no tiene franja);
- registrar turnos o grabar al grupo;
- una marioneta pensada para captar a la criatura (Lúa es la guía de quien
  tiene la pantalla, no un reclamo);
- sustituir la asamblea de diez minutos por ese protocolo.

## Dónde está hoy la app

Comprobado en el código de esta rama.

| Pieza | Dónde está | Qué hace ya |
| --- | --- | --- |
| Dos portales | Inicio → Na casa / Na escola | Hoy, calendario, explorar o recursos, guías o yo |
| Asamblea de 2.º ciclo | Cuatro fases, 10 minutos: saludo, pulso, reto TPR, calma | Una pantalla por fase, con consigna y minutos |
| Asamblea de 1.º ciclo | La misma familia de pantalla, día a día | Sin bloque de inglés como materia |
| Palabras del día | `assets/content/tpr/`, cinco cursos | Cinco palabras nuevas de lunes a jueves; el viernes repasa las veinte. 800 por curso, 4.000 en el trayecto, sin repetir una como nueva |
| Cuento de la semana | `Cuento` en `lib/data/models/cuento_model.dart` | La trama en gl y es, las veinte palabras de la semana dentro del texto, gesto y voz |
| Preguntas del cuento | `PreguntaGraduada`, niveles 1-3 | Están en el cuento entero, no en cada lámina. El comentario del modelo las llama literal, inferencial y crítica. No son las tres de señalar / imitar / acercar |
| Espera de 5 segundos | Campo `tempoEsperaSegundos` del cuento, valor 5 | Está en el dato. No se pinta: el visor del cuento no lee ese campo |
| Recast en casa | `PautaRecast` y la micro-rutina de 2.º ciclo; tarjeta en Academy | Expresión de la criatura, frase devuelta, y qué no decir. Tres a cinco minutos |
| Inglés que se oye | `assets/voice/` | La persona adulta pulsa y oye antes de decir |

La asamblea de segundo ciclo ya tiene la forma corta de una acogida, un
pulso, un reto con el cuerpo y una calma. No hay que inventar otra sesión
encima.

## El conflicto de la dosis, dicho claro

Hoy el curso mete **cinco palabras nuevas al día** y llega a cuatro mil en
cinco cursos. El currículo de vocabulario pide **cinco palabras en seis
semanas** entre los 18 y los 36 meses, y un puñado funcional en cada unidad
de los 3 a los 6 años.

Las dos cifras no describen la misma cosa. Una es el banco de todo el
trayecto. La otra es lo que una sesión puede hacer vivir con las manos.

**No se borra el banco en este plan.** Quitarlo sería otro encargo. Lo que
se añade es una capa de dosis: cada mes señala, dentro de las palabras que
ya existen, el grupo corto que esa semana se dice, se gesticula y se vuelve
a encontrar en el cuento y en el reto de casa. El resto sigue en su día, con
el repaso que ya tiene. Si más adelante se decide adelgazar el banco, se
decide aparte y se recorren las capas (JSON gl, JSON es, audio gl, audio es,
imprimible, pantalla, este documento).

## Cómo se integra

Una sola tubería. El adulto abre la pantalla; el JSON trae el guion; la voz
ya está grabada.

```text
dosis del mes          cuento dialógico           ficha LSS
(apunta a palabras     (3 o 4 láminas,            (cuatro herramientas,
 que ya existen)        frase de Lúa,              ejemplos, qué evitar)
        \               CROWD, recast)                  /
         \                    |                        /
          +-------------------+-----------------------+
                              |
                    guion de la persona adulta
                              |
          +-------------------+-------------------+
          |                   |                   |
     Hoy, aula           Biblioteca          Hoy, casa
     (la misma frase     (el cuento          (un reto de
      y el mismo gesto)   largo)              3 minutos)
```

### Datos nuevos, no pantallas nuevas

Todo en `assets/content/`, bilingüe, nunca escrito en el widget.

**`lss.json`.** Las cuatro herramientas. Cada una: cuándo se usa, qué dice
el adulto, qué no dice, y dos o tres ejemplos en inglés con la situación en
gallego y en castellano. Sale de las tablas del catálogo de apoyo, no de un
resumen. La tarjeta de recast que ya existe en Academy lee de aquí, en vez
de quedarse como caso suelto.

**Cuento dialógico.** Mismo `Cuento`, con campos opcionales para no romper
el cuento de la semana:

- en el cuento: cohorte (`2-3` o `4-6`), escenario, conflicto, gesto,
  desenlace, palabras diana, frase de Lúa;
- en cada lámina: la frase de Lúa de esa lámina, tres preguntas
  (`senalar`, `imitar`, `acercar`) en inglés, con la pista para el adulto en
  gl y es, y un recast por tipo de respuesta (silencio, señal, lengua de
  casa, una palabra, forma torcida).

`PreguntaGraduada` no se reutiliza tal cual: su nivel 1-3 es otra escala. El
cuento de la semana la conserva. El dialógico lleva la tríada en la lámina.

Los dos arquetipos del texto son el primer contenido: *Lúa e o peixiño azul*
(el texto ya lo trae en gallego y en inglés) y *Lúa y el viento travieso*
(en el texto, el cuerpo de varias láminas está solo en castellano). El
gallego de ese segundo cuento se escribe en el lote, no se deja vacío ni se
da aquí por traducido. El
dibujo de cada lámina sigue la regla de lámina limpia: una acción, un
contraste, sin fondo que compita. Si no hay lámina, el cuento no entra en la
biblioteca.

**Dosis.** Un JSON por curso y mes que **cita identificadores** de
`assets/content/tpr/`. No copia la palabra. Ahí caben el gesto, el objeto de
la mesa y el contraste de sonido que el adulto tiene que oír (por ejemplo
`fish` frente a `sea`), como nota para quien habla, no como prueba para la
criatura.

**Reto de casa.** Una ficha por unidad, del estilo de la micro-rutina que ya
existe: momento del día, una frase, qué hacer con las manos, qué no pedir.
El cuaderno viajero de objetos reales se queda fuera de la app: es un objeto
físico, no un registro.

**El modelo.** Un JSON de formación, con perfil docente y perfil familia, en
gallego y en castellano. Tres bloques: cómo funciona, los objetivos del
tramo (los cuatro de 18 a 36 meses y los cuatro de 3 a 6, tal como los
escribe el currículo de vocabulario), y qué no es un objetivo. El 80 % de
órdenes con el cuerpo se escribe como criterio del texto. No es un campo
numérico y no se calcula.

**Cumplimiento del adulto.** Una lista cerrada de identificadores, distinta
por perfil, citada desde ese JSON. Al marcarla, el aparato guarda el día
sin hora y esos identificadores. No guarda texto libre, ni un porcentaje, ni
nada de una criatura. Si la clave es nueva, el mismo cambio toca la política
de privacidad y los dos gates de los ficheros (`premios.json` y
`user_progress.json`).

### Dónde se ve, en los tres modos

| Qué | Aula, 1.º ciclo | Aula, 2.º ciclo | Casa |
| --- | --- | --- | --- |
| Asamblea de cuatro fases | La de su día, sin franja de inglés | Igual que ahora: saludo, pulso, reto, calma | No aplica |
| Frase y gesto del día | Dentro del día, incidental | Dentro del reto TPR, el grupo corto de la dosis | Las mismas palabras, con el juego de tres minutos |
| Cuento dialógico | 3 láminas, casi todo señalar e imitar | 4 láminas, entra el acercar a la vida | El mismo cuento, en PEER: una pregunta por lámina, no las tres a la vez |
| Ficha LSS | Una línea en la guía de antes de entrar: espera y no corrijas | La ficha completa en El modelo | La misma ficha, con el ejemplo de casa |
| El modelo | El espacio entero. Los objetivos escritos del texto empiezan a los 18 meses | El espacio entero, con los objetivos de 3 a 6 | El mismo espacio, con el reto de casa |
| Cumplimiento | La lista del adulto al cerrar el día, sin casilla de criatura | La misma lista | La lista del reto de casa |
| Nota de observación | No se muestra como nota | Una frase de qué mirar (cuerpo, canción, fórmula), sin casilla | No se muestra |

Un botón que lleve al cuento no cumple el cuento. La tríada y la espera van
en la lámina que la persona adulta tiene abierta.

La espera se dibuja: el campo `tempoEsperaSegundos` pasa a verse en esa
lámina (una cuenta visual de cinco segundos, en silencio). Hoy el campo
existe y el visor no lo usa.

### Voz

Cada frase nueva de Lúa, cada pregunta CROWD y cada modelo de recast que se
vaya a oír llevan grabación en inglés. El texto de alrededor, en gallego y
en castellano, lleva la suya si la pantalla lo reproduce. Texto y audio
entran en el mismo cambio. Si no hay grabación, la pantalla enseña el texto
y lo dice, y no finge un botón de voz.

## Plan de trabajo

Cada lote se termina en las capas que toca, o se dice cuál falta. No se da
por hecho un lote porque el JSON exista y la pantalla no.

### Lote 1. Las cuatro herramientas, visibles

`lss.json` en gl y es. La guía que ya explica el recast pasa a enseñar las
cuatro, con el ejemplo y con lo que no hay que decir. Sin audio todavía: es
texto para el adulto.

Hecho cuando, en los dos idiomas, la guía de casa y la de la escuela enseñan
recast, expansión, habla paralela y espera, y un gate impide que falte una
lengua o que vuelva un «repite» como consigna.

### Lote 2. Los dos cuentos arquetipo

Modelo de lámina con tríada y recast. *Lúa e o peixiño azul* y *Lúa y el
viento travieso*, en gallego y en castellano, con la frase de Lúa en
inglés. El gallego del segundo se redacta en este lote. Láminas propias, o el lote no se abre en la biblioteca.

Hecho cuando los dos se abren desde la biblioteca en los dos portales y en
los dos idiomas, y cada lámina muestra sus tres preguntas y su pauta.

### Lote 3. La espera, en la lámina

La cuenta de cinco segundos en la lámina del cuento dialógico, en silencio.
El cuento de la semana no cambia de layout en este lote.

Hecho cuando se ve la cuenta en gallego y en castellano, en aula y en casa.
Sin un aparato, se dice que no se ha visto en un aparato.

### Lote 4. La dosis, sin tocar el banco

Un mes piloto (el del agua, en el curso 2-3, porque el texto lo escribe
entero: water, splash, boat, wet, fish). Esas cinco se citan si ya están en
el TPR; si falta alguna, se dice cuál y no se inventa el identificador. Hoy
de la escuela y Hoy de casa muestran ese grupo como «las que se viven esta
semana», distinto de las cinco nuevas del día.

Hecho cuando el mismo identificador sale en el JSON de dosis, en el día del
aula y en el día de casa, y el banco de cuatro mil sigue pasando su gate.

### Lote 5. Un reto de casa por ese mes

La ficha del baño (`water`, `splash`, «All wet!»), en el momento del baño,
con espera y sin pedir que repita. Misma ficha en los dos idiomas.

Hecho cuando Hoy de casa la enseña ese mes y no enseña una nota ni un
cuaderno.

### Lote 6. El marco gallego, en la guía de la docente

Un texto corto en Guías / Yo: el inglés es aproximación dentro del área de
comunicación, no una materia; en 0-3 no hay sesión propia; lo que se puede
mirar es el cuerpo, la canción y la fórmula, y no se anota. Sin mención a
plataformas de notas ni a calificaciones.

Hecho cuando esa guía está en gl y es, dentro de El modelo, y no añade ningún
campo guardado sobre una criatura.

### Lote 7. El espacio «El modelo»

La puerta nueva en Eu (aula) y en Guías (casa). Las tres partes. La guía de
dos minutos no se sustituye: sigue siendo la entrada corta.

Hecho cuando las dos puertas, en los dos idiomas, enseñan cómo funciona el
modelo, los objetivos del tramo y la frase de que el 80 % no se guarda.

### Lote 8. La lista de cumplimiento del adulto

La lista cerrada al terminar Hoy, en los dos perfiles, solo con los
identificadores del mes piloto. El día se guarda sin hora.

Hecho cuando se marca, se cierra, se vuelve a abrir y se ve lo mismo, y los
dos gates de privacidad siguen verdes con la clave nueva —o sin clave nueva,
si cupo en las que ya existen.

Los lotes 2 y 3 comparten pantalla. El 4 y el 5 comparten el mes piloto. El
1, el 6 y el 7 pueden ir juntos: son el espacio de formación. El 8 espera al
4, porque no se marca un objetivo de una dosis que aún no existe. El
catálogo de cien cuentos y las otras once unidades de vocabulario esperan a
que estos ocho estén vistos: el molde ya queda en el lote 2 y en el lote 4.

## Qué queda fuera, a propósito

- Grabar turnos, anecdotarios, una escala por criatura o el 80 % de las
  órdenes. Ese porcentaje se explica en El modelo y no se calcula.
- Una sesión de 45 minutos con tres adultos.
- Tratar el inglés como asignatura, ficha o nota.
- Sustituir las cuatro mil palabras por las treinta del tramo de 18 a 36
  meses, mientras no haya un encargo distinto.
- Fondos de lámina cargados, o una pregunta de examen en medio del juego.
- Pedir a la criatura que repita, que traduzca o que conteste en inglés.
