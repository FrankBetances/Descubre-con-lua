# Plan integral de mejora

Qué va a cambiar en la app, módulo a módulo, cuando se apliquen los cinco
textos de base. **Este documento no cambia ninguna pantalla.** Es el encargo
de mejora de todo el producto. El contrato de datos —qué JSON entra y con qué
campos— está en `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`. Aquí se dice qué ve la
docente y qué ve la familia, y en qué orden se hace.

Los cinco textos se leyeron enteros el 17 de octubre de 2026. No están
copiados en el repositorio. El mapa de módulos de abajo se sacó del código de
la rama `pedagogia` (las pantallas de `lib/features/` y el JSON de
`assets/content/`). **Esto no lo he verificado** abriendo la app de nuevo en
esta redacción: la última vez que se recorrió Inicio → Modo Aula y Inicio →
Portal de familias fue el 17 de octubre de 2026, en escritorio Linux, y esas
capturas están en `docs/capturas/verificacion-pedagogia/`.

## El criterio

Cada mejora tiene que poder señalarse en uno de estos cinco textos. Si no
sale de ellos, no entra en este plan.

| Texto | La mejora que pide |
| --- | --- |
| Currículo de inglés infantil de Galicia | Llamar al inglés por su nombre oficial: aproximación dentro del Área de Comunicación y Representación de la Realidad. Sin asignatura, sin ficha y sin nota. |
| Currículo de vocabulario, 2 a 6 años | Una dosis corta, con objeto real y gesto, y un solo reto en casa. El banco grande se queda detrás. |
| Estrategias de apoyo lingüístico | Cuatro herramientas del adulto, en la pantalla donde habla: reformular, ampliar, hablar en paralelo y esperar. |
| Manual de rutinas SparkLing (UW I-LABS) | Turno, espera, modelado y cierre predecible. La voz grabada no sustituye a la persona que está delante. |
| Biblioteca de cuentos dialógicos bilingües | Microcuento de tres o cuatro láminas, pregunta en tres peldaños, pausa y eco. |

Cinco límites mandan sobre los cinco textos. Si un texto pide lo contrario,
no entra:

1. La criatura no usa la pantalla. La pantalla es el guion del adulto.
2. Cero datos de una crianza. Ni nombres, ni escalas, ni recuento de turnos.
3. Sin red. Una frase inglesa nueva lleva su grabación en el mismo cambio.
4. Nada sanitario. La espera y el eco son la manera de hablar, no una terapia.
5. El inglés se oye. El gallego y el castellano siguen siendo las dos lenguas
   de la pantalla, con paridad.

El pulso de la canción sigue siendo visual.

## Qué ya está y no se reescribe

Esto se comprobó leyendo el JSON y las pantallas que lo cargan, no de
memoria:

- El curso ya tiene diez meses por edad (0-2, 2-3, 3-4, 4-5, 5-6), asamblea
  de cuatro fases, cuento de la semana, palabras del día y un banco de unas
  cuatro mil palabras de uso habitual.
- Las estrategias de `assets/content/estrategias_pedagogicas.json` ya traen
  la espera de cinco segundos, el andamiaje en tres niveles, el eco, el cero
  pantallas y el baño de lenguaje. Faltan, como piezas propias, el habla
  paralela y la expansión: hoy viven dentro de otros textos, no como
  herramienta que la docente abre.
- La formación docente (`formacion.docente.json`) ya dice que el móvil es del
  adulto, que la sesión son cuatro fases y que el cuerpo va antes que la voz.
- La nota para las casas ya es de papel a propósito: se lee en alto y se
  copia. No hay botón de compartir.
- El repaso espaciado guarda la tarjeta de la persona adulta (la palabra y
  unas fechas sin hora), nunca un dato de una crianza.
- «Qué observar», en aprender a leer, ya es una pista que no se marca ni se
  guarda.

Reescribir eso para que «parezca» el texto nuevo sería tirar un curso entero.
La mejora es poner la dosis y la manera de hablar **delante**, y dejar el
banco donde está.

## Qué se desvía de los cinco textos

También comprobado en el código, y es lo que este plan corrige:

- **Hoy** abre el mes del banco. Los cincuenta ficheros de
  `assets/content/tpr/` (cinco cursos, diez meses) traen **ochenta** palabras
  cada uno, veinte por semana. El día ya enseña cinco de esa semana, y el
  viernes las veinte. Los textos piden otra cosa: cinco palabras estables
  durante unas seis u ocho semanas, con objeto y gesto, no cinco nuevas cada
  día.
- **El cuento de la semana** ya lleva esas veinte palabras, una pregunta en
  cada página, una guía que dice «espera cinco segundos» y, detrás de un
  botón, las preguntas graduadas. El modelo guarda `tempoEsperaSegundos` y
  el visor no lo dibuja: se buscó en `lib/features/cuentos/` y no hay un
  contador. El cuento dialógico pide, además, tres o cuatro láminas, la
  pregunta en inglés en tres peldaños y el eco escrito.
- **Las estrategias** no nombran el habla paralela ni la expansión como
  herramientas aparte, y el andamiaje de Bloom está escrito como preguntas
  en gallego o castellano. El cuento bilingüe pide la pregunta en inglés, con
  la ayuda del adulto en la lengua de la pantalla.
- **El planificador y los recursos de inglés** presentan el banco (palabras
  del curso, repaso, escucha, colocaciones, sonidos, lista de vocabulario)
  sin decir que eso no es una asignatura ni una nota.
- **La nota para las casas** cierra la asamblea. Todavía no lleva el micro-reto
  de la casa: la frase de esta semana, el objeto de la cocina y la consigna
  de no pedir que repita.

## El producto, módulo a módulo

Cada fila dice el camino, qué mejora y de qué texto sale. «Igual» significa
que el módulo se queda y este plan no le cambia la disposición.

### Entrada

| Camino | Mejora |
| --- | --- |
| Inicio | Igual. Sigue habiendo dos puertas: Modo Aula y Portal de familias. |
| Antes de entrar en el aula (`formacion.docente`) | Se añaden dos pasos cortos: el inglés no es asignatura, y las cuatro herramientas (reformular, ampliar, hablar en paralelo, esperar). Los pasos que ya están se quedan. |
| Guías de familias (`formacion.familia` y `guias_familias`) | Los seis pasos que ya están se quedan, entre ellos «nunca preguntes cómo se dice» y el eco. Se añade cómo leer una lámina: incitar, acoger, ampliar, retomar, y la espera. Sin deberes ni lista de palabras. |

### El día, en el aula

Camino: Inicio → Entrar en Modo Aula → Hoy.

| Pieza | Mejora |
| --- | --- |
| Hoy, aula | Arriba, el grupo estable de la dosis y el objeto real. Debajo sigue el día del banco, que ya muestra las cinco de hoy. La dosis no sustituye a esas cinco: dice cuáles se quedan varias semanas. |
| Asamblea de primer ciclo | En cada fase, una línea de adulto: qué decir, cuánto callar, y que el silencio de la criatura es normal. No se alarga la sesión. |
| Asamblea de segundo ciclo | La pausa, que hoy está escrita en la guía del cuento, pasa a ser un contador visual de cinco segundos en esa fase. El pulso de la canción no se toca. |
| Cuento dentro de la asamblea | Se queda la pregunta de la página y las preguntas graduadas. Lo que se añade es el contador visual de cinco segundos, que el dato ya anuncia y la pantalla no enseña. El peldaño en inglés (señalar, imitar, acercar) es del microcuento, no una segunda pregunta del cuento semanal. |
| Nota para las casas | Al texto que ya se copia se le añade el micro-reto: una frase, un objeto de casa y «no le pidas que repita». Sigue sin botón de compartir. |
| Calendario del aula | El día enseña la dosis del grupo, no una casilla de logro. No se marca a ninguna criatura. |

### El día, en casa

Camino: Inicio → Portal de familias → Hoy.

| Pieza | Mejora |
| --- | --- |
| Hoy, familias | El mismo grupo de palabras que el aula, en corto: la frase, el gesto y el reto. No el banco del mes. |
| Cápsulas Academy | La cápsula del mes del piloto dice cómo leer esa frase en casa (incitar, acoger, ampliar, retomar). El resto de cápsulas se queda. |
| Ponte al día | Igual. Sigue siendo el sitio para recuperar una palabra ya vista, no la dosis nueva. |
| Juego de hoy y juegos de casa | Donde ya hay una frase inglesa, se añade la espera y «no corrijas: di la frase bien y sigue». No se crean juegos nuevos. |
| Calendario del hogar | Igual que el de aula: la dosis del día, sin casilla de logro de la criatura. |

### El cuento

Camino de la familia: Portal de familias → Explorar → Cuentos.
Camino del aula: el cuento sale dentro de la asamblea del día.

| Pieza | Mejora |
| --- | --- |
| Lista de cuentos | El cuento de la semana sigue destacado. Los dos microcuentos dialógicos (uno de tres láminas, otro de cuatro) aparecen como cuentos, no como un modo aparte. |
| Visor | En el microcuento: lámina, frase inglesa con altavoz, pregunta del peldaño, contador de cinco segundos, y el eco que dice el adulto si hace falta. En el cuento semanal: las preguntas que ya tiene, más el mismo contador, sin rehacer las veinte palabras. |
| Láminas | Siguen siendo papel. El microcuento señala qué lámina se imprime; no se enseña la lámina en la pantalla a la criatura. |

Los dos primeros microcuentos, y no más en esta mejora, son los que los
textos traen escritos: *Lúa e o peixiño azul* (2-3 años) y *Lúa e o vento
rebuldeiro* / *Lúa y el viento travieso* (4-6). Cada uno, en gallego y en
castellano.

### El inglés que ya existe

Camino: Modo Aula → Recursos → grupo de inglés. En casa, Explorar → inglés
abre solo las palabras del trayecto.

| Pieza | Mejora |
| --- | --- |
| Palabras del curso | Al abrirlas, primero las de la dosis de esta semana. El resto del mes sigue ahí, una sección más abajo. |
| Repaso espaciado | Sigue siendo el repaso **de la persona adulta**, para acordarse de cómo se dice antes de entrar. Las palabras de la dosis salen primero. No se convierte en un examen de la criatura. |
| Escucha | Igual: la docente oye la frase antes de decirla. Si la dosis añade una frase, entra su audio en el mismo cambio. |
| Colocaciones | Se marcan las fórmulas de turno que el currículo de 3 a 6 años pide (`my turn`, `here you are` y las que el texto nombre en esa unidad). No se añade una lección de gramática. |
| Sonidos | El contraste que el currículo pide frente al gallego o al castellano (la vocal breve, la vocal larga, el cierre de la sílaba) apunta al sonido que ya está en este módulo. No se abre un juego de fonemas para la criatura. |
| Lista de vocabulario (el banco de uso habitual) | Igual, y deja de ser la puerta. Se entra desde Recursos, nunca desde Hoy. |
| Aprender a leer (casa) | Sigue siendo el guion del adulto con letras de madera y «qué observar» sin marcar. Los contrastes de sonido del currículo se enlazan aquí cuando coinciden. No vuelve el registro «logrado / asistido». |

### El resto de la jornada

| Camino | Mejora |
| --- | --- |
| Recursos → Dinámicas | Donde la dinámica ya trae una frase inglesa, se añade la espera y el eco. No se alarga el procedimiento ni se pide el nombre de una criatura a la app. El nombre, si se usa, se usa en la sala: la app no lo pregunta ni lo guarda. |
| Recursos → Ciencia (STEAM) | La sesión sigue siendo de ciencia con las manos. Si ya hay una orden en inglés, esa orden usa la misma espera y el mismo eco. No se convierte la ciencia en clase de inglés. |
| Recursos → Programación | El mes dice en qué área vive el inglés (Comunicación y Representación de la Realidad, objetivo OBX5, criterio CA2.7 en segundo ciclo) y cuál es la dosis. No aparece «Área de Inglés» ni una nota. |
| Recursos → Estrategias | Se suman el habla paralela y la expansión, con el mismo molde que las cinco que ya hay: por qué, cómo, un ejemplo, el error a evitar. La espera que ya está se completa con las dos pausas: después de hablar el adulto, y después de hablar la criatura. |
| Premios | Igual. Siguen siendo del adulto. Este plan no añade una insignia por «progreso» de una criatura. |
| Créditos | Igual. |

### Lo que se oye

Toda frase inglesa nueva —de la dosis, del microcuento o del reto de casa—
entra con su audio en el mismo cambio que el texto, en la voz que ya usa el
inglés del proyecto. El gallego y el castellano de la interfaz, si cambian,
entran también los dos, con su audio si esa cadena ya se oye.

La persona adulta puede oír la frase para prepararse. Luego la dice ella, en
la sala o en casa, con su gesto. La grabación no se pone delante del grupo
como si fuera la maestra.

## Olas

Seis olas. Cada una se termina entera —gallego, castellano, audio si la
frase se oye, y la pantalla— antes de abrir la siguiente. El detalle de los
campos JSON está en el plan de arquitectura; aquí está el orden en el que
Frank lo ve.

### 1. La manera de hablar

Estrategias (habla paralela, expansión, las dos esperas) y los dos textos de
antes de empezar: docente y familia.

Hecho cuando, en gallego y en castellano, Estrategias muestra las cuatro
herramientas y la formación las nombra en sus pasos.

### 2. El día

Hoy del aula, Hoy de casa, la asamblea de los dos ciclos, el calendario de
los dos portales y la nota para las casas. Solo el mes piloto (septiembre
del curso 3-4, que ya es el de bienvenida y rutinas). El contador de cinco
segundos entra en la fase del cuento.

Hecho cuando el día enseña la dosis y el reto, y la nota se puede copiar con
la frase de casa.

### 3. El cuento

Los dos microcuentos, con su pregunta en tres peldaños, y el contador de
cinco segundos en el visor. El cuento de la semana no gana otra pregunta:
gana el contador que su guía ya pide por escrito.

Hecho cuando cada microcuento se abre desde la lista, se oye la frase y se
ve la pausa, en las dos lenguas, y el cuento de la semana enseña la misma
pausa.

### 4. El banco de inglés

Palabras, repaso, colocaciones y sonidos pasan a abrir por la dosis y por la
fórmula de turno. La lista grande y la escucha se quedan donde están.

Hecho cuando, con el curso 3-4 y septiembre, lo primero que se ve son las
palabras de la dosis y no las ochenta del mes.

### 5. El resto de la jornada

Dinámicas, ciencia y aprender a leer: solo la línea de adulto donde ya hay
inglés. Programación: el nombre del área y la dosis del mes piloto.

Hecho cuando ninguna de esas pantallas pide un dato de una criatura ni llama
al inglés asignatura.

### 6. El papel y la guía

El manual, en la página de cada pantalla tocada. La programación, si la ola 5
solo cubrió el mes piloto, se extiende al resto de meses **cuando exista la
dosis de ese mes**. No se rellena un mes con una dosis inventada.

Hecho cuando el manual y la pantalla dicen lo mismo.

## Qué no entra

- Un área, una ficha o una nota de inglés.
- Guardar qué dijo o qué hizo una criatura.
- Más de dos microcuentos en esta mejora.
- Rehacer los cincuenta meses del banco, la ciencia o aprender a leer.
- Voz en directo, red, o un metrónomo que suene.
- Traducir la interfaz al inglés.

## Cómo se sabe que una ola está hecha

En este orden, y se nombra con qué:

1. El JSON gallego y el castellano dicen lo mismo.
2. Si hay frase nueva que se oye, el audio está en el mismo cambio.
3. Los gates del repositorio (`tools/gates.sh`) salen verdes, y el APK de
   release sigue sin permiso de red.
4. Se abre la app, se llega por el camino de la tabla (no por el fichero) y
   se mira la captura en gallego y en castellano.

Hasta entonces la ola está en la rama, pendiente de mergear. No está hecha.
