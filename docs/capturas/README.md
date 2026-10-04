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
| `bienvenida-{gl,es}.png` | La pantalla con la que arranca la app |
| `aula-unidades-{gl,es}.png` | Juega con Lúa · Aula: tira de Lúa, formación y unidades |
| `aula-formacion-{gl,es}.png` | Formación · Aula: los seis pasos de la asamblea |
| `academy-bloques-{gl,es}.png` | Academy · Familias: los cinco bloques |
| `academy-lector-{gl,es}.png` | El lector paginado de una cápsula |
| `premios-{gl,es}.png` | Los premios de Lúa: nivel, racha e insignias |
| `creditos-{gl,es}.png` | Créditos |
| `asamblea-conto-{gl,es}.png` | Asamblea · fase 2: a lámina do conto, o texto e a pregunta |
| `asamblea-seguridade-{gl,es}.png` | Asamblea · fase 4: o protocolo de seguridade que se le antes de sacar material |
| `laminas-hoja.png` | Hoja de contacto de las láminas del **vocabulario** (cuadradas) |
| `laminas-conto-hoja.png` | Hoja de contacto de las **escenas del cuento** (apaisadas) |

Las dos hojas de contacto no son capturas de pantalla: son el set entero junto,
que es como se juzga si comparten grosor, terminaciones y peso de color. Salen
de `test/laminas_hoja_test.dart` y se rehacen con:

```bash
flutter test --tags capturas --update-goldens test/laminas_hoja_test.dart
```

## Las capturas de la app de escritorio

Las que empiezan por `l0-` y las de `vocabulario-flower-` son otra cosa: la app
**compilada para escritorio** (Linux), abierta en una pantalla virtual de
360 × 780 px y recorrida a mano por el mismo camino que usa quien la maneja
(Inicio → Comezar → portal → módulo). Son la prueba de que un cambio se ve donde
se dijo, no ilustraciones del manual, y el manual no las usa.

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
