# Las imágenes de pantalla del manual

## Qué son

El **árbol de widgets real** pintado por el motor de Flutter, con la tipografía
real de la app (Nunito y MaterialIcons) y con el contenido real de los JSON. La
disposición es la que la app calcula: no son maquetas ni montajes.

Las genera `test/capturas_test.dart`:

```bash
flutter test --tags capturas --update-goldens test/capturas_test.dart
```

Van fuera de los gates a propósito: no comprueban nada, producen un documento.

## Qué NO son

**No son capturas de un aparato.** Aquí no hay:

- muesca ni barra de gestos;
- la densidad de un teléfono concreto (se fija a 2,0);
- la escala de texto del sistema (se fija a 1,0);
- audio, que no suena en ningún test.

Es la regla 1c de `CLAUDE.md` escrita en forma de aviso: un render de Flutter se
parece mucho más a un Android que una maqueta, pero sigue sin ser un Android.

## Cómo sustituirlas por capturas de verdad

Reemplazar los PNG con el mismo nombre. El manual no se toca:

```bash
flutter run -d <dispositivo>
adb exec-out screencap -p > docs/capturas/aula-unidades-gl.png
```

Cada pantalla va en gallego **y** en castellano. Las dos lenguas no ocupan lo
mismo, y ahí es donde aparecen los cortes de texto. Estas imágenes ya han pagado
su coste: en la primera tanda se vio que el chip «Todas las edades» salía
cortado en castellano y entero en gallego. Ningún test lo había cazado, porque
un chip recorta en vez de desbordar: no hay franjas amarillas ni excepción. Está
arreglado, y ahora lo vigila `test/features/juega/filtro_edad_test.dart`, que
compara el ancho pintado con el que el texto mide de verdad.

## Los ficheros

| Fichero | Pantalla |
| --- | --- |
| `bienvenida-{gl,es}.png` | El inicio: «¿Dónde la vas a usar?» y las dos respuestas, En casa y En la escuela |
| `hoxe-familias-{gl,es}.png` | Hoy, en el Portal Familias: el juego de tres minutos, sus palabras y el cuento de la semana |
| `explorar-familias-{gl,es}.png` | Explorar: los seis módulos de casa |
| `hoxe-docentes-{gl,es}.png` | Hoy, en el Portal Docentes: la asamblea del día, sus palabras, el cuento, la dinámica y la ciencia |
| `recursos-docentes-{gl,es}.png` | Recursos: los módulos del aula en cuatro grupos |
| `aula-unidades-{gl,es}.png` | Juega con Lúa · Modo Aula: el selector compacto, la sesión del día y las unidades |
| `aula-lista-2ciclo-{gl,es}.png` | El Modo Aula en la pestaña 2.º ciclo: la clase, el mes y la sesión del día |
| `aula-2ciclo-asemblea-{gl,es}.png` | La asamblea matinal de 2.º ciclo, fase 1: el reproductor que abre «Comenzar la asamblea» |
| `aula-formacion-{gl,es}.png` | Formación en el aula: los seis pasos de la asamblea |
| `academy-bloques-{gl,es}.png` | Guías para la familia: los cinco bloques |
| `academy-lector-{gl,es}.png` | El lector paginado de una cápsula |
| `academy-lua-peche-{gl,es}.png` | El cierre de una cápsula: la frase de Lúa, después de la reflexión |
| `academy-micro-rutina-{gl,es}.png` | La micro-rutina de septiembre de segundo ciclo |
| `guia-ingles-{gl,es}.png` | El inglés en casa: cuánto dura el juego según la edad |
| `premios-{gl,es}.png` | Tus premios: nivel, racha e insignias |
| `creditos-{gl,es}.png` | Créditos |
| `asamblea-conto-{gl,es}.png` | Asamblea · fase 2: a lámina do conto, o texto e a pregunta |
| `asamblea-seguridade-{gl,es}.png` | Asamblea · fase 4: o protocolo de seguridade que se le antes de sacar material |
| `asamblea-ingles-{gl,es}.png` | Asamblea guiada: el inglés de la fase, con su grabación |
| `nota-casas-{gl,es}.png` | La nota para las casas: lo que se hizo hoy, el juego de tres minutos y la frase en inglés |
| `conto-palabras-{gl,es}.png` | El cuento de la semana con las palabras de hoy |
| `calendario-{gl,es}.png` | El Calendario Escuela · Hogar, del lado del aula |
| `calendario-familia-{gl,es}.png` | El mismo calendario, del lado de la familia |
| `steam-hub-{gl,es}.png` | Ciencia con las manos, del lado del aula: las cinco sesiones |
| `steam-sesion-aula-{gl,es}.png` | Una sesión de ciencia, versión del aula |
| `steam-sesion-casa-{gl,es}.png` | Una sesión de ciencia, versión de casa |
| `steam-hoxe-na-aula-{gl,es}.png` | Hoy de la docente el día que toca ciencia: la sesión, debajo de la asamblea |
| `laminas-hoja.png` | Hoja de contacto de las láminas del **vocabulario** (cuadradas) |
| `laminas-conto-hoja.png` | Hoja de contacto de las **escenas del cuento** (apaisadas) |

Las dos hojas de contacto no son capturas de pantalla: son el set entero junto,
que es como se juzga si comparten grosor, terminaciones y peso de color. Salen
de `test/laminas_hoja_test.dart` y se rehacen con:

```bash
flutter test --tags capturas --update-goldens test/laminas_hoja_test.dart
```

## Las capturas de la app de escritorio

Las que empiezan por `l0-` a `l6-`, y las de `vocabulario-flower-`, son otra
cosa: la app **compilada para escritorio** (Linux), abierta en una pantalla
virtual de 360 × 780 px y recorrida a mano por el mismo camino que usa quien la
maneja (hasta L4, Inicio → Comezar → portal → módulo; desde L5, Inicio → Na
casa o Na escola → pestaña → módulo). Son la prueba de que un cambio se ve
donde se dijo, no ilustraciones del manual, y el manual no las usa.

Tampoco son capturas de un aparato: la app de escritorio comparte la interfaz con
la de Android, pero no sus barras del sistema, su densidad ni su escala de texto.

| Fichero | Qué enseña |
| --- | --- |
| `vocabulario-flower-{gl,es}.png` | El vocabulario de uso habitual buscando *flower*: definición y frase escritas a mano |
| `l0-c1-calendario-casa-{gl,es}.png` | El calendario de casa abierto en el mes de hoy (3/10: octubre, lunes de la semana 1) |
| `l0-c2-vocabulario-{gl,es}.png` | La tarjeta «Vocabulario de uso habitual» del Portal Docentes, con sus números reales |
| `l0-c3-aprender-a-ler-{gl,es}.png` | «Que observar» en lugar de los botones de calificar, en Aprender a Ler |
| `l0-c3-xogos-casa-{gl,es}.png` | «Que observar» en los Xogos e Dinámicas no Fogar |
| `l0-c4-laminas-{gl,es}.png` | Una lámina de título largo, entero en tres líneas y sin desborde |
| `l0-c5-biblioteca-{gl,es}.png` | La biblioteca: el mes por su nombre y la semana solo en el cuento de la semana |
| `l0-c5-visor-{gl,es}.png` | La cabecera del visor: la edad y el mes, sin «CURSO_0_2» ni «Semana 1» |
| `l0-a5-estratexias-{gl,es}.png` | «Por que funciona» en lenguaje de aula, con su fuente |
| `l0-a5-dinamicas-{gl,es}.png` | La dinámica del viernes sin «ton vagal» ni «regulación parasimpática» |
| `l0-m2-xoga-con-lua-gl.png` | «Xoga con Lúa» en la interfaz gallega, en la elección de portal |
| `l0-m7-reprodutor-{gl,es}.png` | El reproductor de la asamblea: volver es una flecha visible y «Seguinte fase» cabe |
| `l1-familias-steam-{gl,es}.png` | El Portal Familias: STEAM es el segundo módulo, justo después del calendario, y el segundo chip de la fila de áreas |
| `l1-inicio-familias-{gl,es}.png` | La tarjeta del Portal Familias en el inicio: STEAM nombrado entre lo que hay dentro |
| `l2-calendario-casa-{gl,es}.png` | El calendario de casa en el naranja de familias, con un solo botón principal: «Xa o fixemos» / «Ya lo hicimos» |
| `l2-conto-{gl,es}.png` | El visor de cuentos: la edad, el mes y la semana encima del título, y la barra de pasos común (flecha, «1 / 5», «Seguinte») |
| `l2-portal-docentes-{gl,es}.png` | El Portal Docentes en su verde azulado: un solo principal, «Comezar a asemblea», y las tarjetas de módulo con botón de borde |
| `l3-hoxe-{gl,es}.png` | «Hoxe», la portada de casa, un domingo: el juego del lunes con el momento como título, un solo botón y el cuento de la semana citado en el texto |
| `l3-xogo-{gl,es}.png` | El juego del día: el momento, el texto entero, el inglés con el cuerpo y sus palabras con voz, y el porqué plegado |
| `l3-explorar-{gl,es}.png` | Explorar: los seis módulos de casa con su nombre de casa, Ciencia coas mans entre ellos, sin bajar |
| `l3-guias-{gl,es}.png` | Guías: la guía de dos minutos, las lecturas para la familia, el inglés en casa y los premios |
| `l3-idade-es.png` | La edad se elige una vez, en un chip arriba; la hoja recuerda que no se guarda |
| `l4-hoxe-{gl,es}.png` | «Hoxe», la portada de la docente, un lunes: la asamblea del día arriba, con sus cuatro fases y sus minutos, y un solo botón; debajo, las palabras de hoy con el tema de la semana |
| `l4-hoxe-ciencia-{gl,es}.png` | El final de «Hoxe»: el cuento de la semana, la dinámica del día y cuándo toca la ciencia del curso |
| `l4-calendario-{gl,es}.png` | El calendario como pestaña del Portal Docentes, sin el párrafo de entrada: la tira de meses se ve entera |
| `l4-recursos-{gl,es}.png` | Recursos: los módulos agrupados por lo que se va a hacer, con «Xoga con Lúa · Modo Aula» y «Planificador curricular» |
| `l4-modo-aula-{gl,es}.png` | El Modo Aula: el grupo, el mes y el día en una línea, sin la tira de nivel encima, y «Comezar a asemblea» en la primera pantalla |
| `l4-modo-aula-selector-{gl,es}.png` | El mismo selector abierto: grupo, mes, semana y día, con la tira de meses dentro del margen |
| `l4-eu-{gl,es}.png` | «Eu»: el nivel y la racha de la docente, la guía de dos minutos, la formación del aula y lo que se guarda |
| `l4-explorar-familias-{gl,es}.png` | Explorar de familias: «Ciencia coas mans» dice debajo que es STEAM |
| `l5-inicio-{gl,es}.png` | El inicio: una pregunta, «Onde vas usala?», y dos respuestas, «Na casa» y «Na escola», cada una con su dibujo |
| `l5-recursos-ingles-{gl,es}.png` | Recursos de la escuela, en dos pantallas: el inglés por partes, una puerta para cada una (palabras del curso, repaso, frases, colocaciones, sonidos y vocabulario) |
| `l5-portas-casa-{gl,es}.png` | La cabecera de cada pantalla a la que se llega desde Explorar y Guías: lleva el nombre de su puerta, o su comienzo si no cabe |
| `l5-portas-escola-{gl,es}.png` | Lo mismo desde Recursos y Eu: las once puertas de Recursos, los premios de la docente y sus dos guías |
| `l6-casa-{gl,es}.png` | Casa con la letra de L6, en cuatro pantallas: el inicio (GL/ES de 48 dp), el calendario (trimestres de 48 dp), «Ler xogando» y Contos |
| `l6-escola-{gl,es}.png` | La escuela con la letra de L6: el Modo Aula (pestañas de ciclo de 48 dp), el vocabulario, la ciencia y Hoy |
