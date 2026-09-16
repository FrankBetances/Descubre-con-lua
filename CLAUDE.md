# Lúa · Edición Vigo (Flutter) · Notas para Claude Code

App Android nativa en Flutter, de finalidad **exclusivamente educativa**, para las escuelas infantiles municipales de Vigo y sus familias. Tiene dos módulos:

- **Juega con Lúa**: lo usa la docente en la asamblea.
- **Academy**: lo usan las familias en casa.

Todo el contenido está en gallego y castellano. La primera versión la generó Google Antigravity y la revisión y mejora la hace Claude Code.

**No es el otro producto de la casa.** No se copia su código, sus pantallas ni sus módulos. De él se heredan las reglas de trabajo de abajo, la identidad de Lúa y las tuberías de compilación (voz neuronal, rejilla de la mascota), nada más.

> Este repositorio es **público**. Lo que se escriba aquí lo lee cualquiera, así que en este fichero y en los demás documentos no entran ni incidencias de otros productos, ni fechas de rechazos de tienda, ni nombres de ficheros internos ajenos, ni el estado de las claves de firma.

## LAS REGLAS DE FRANK

Las dictó Frank. **Mandan sobre todo lo demás de este fichero.** Si algo de más abajo las contradice, ganan ellas. Se citan como **R1…R6** —no como «regla 1»— porque «regla 1», «regla 1c» y «regla 5» ya nombran las reglas de trabajo de más abajo, que están citadas desde el código, los tests y `docs/`.

Eran cinco. **R6 la añadió Frank el 15/9/2026**, con estas palabras: «es obligatorio cumplir con las órdenes, está prohibido utilizar atajos, es tu obligación hacer el mayor esfuerzo posible, evaluando todas las posibilidades para cumplir con tu trabajo».

### R1 · Honestidad ante todo

Manda sobre las otras cuatro. No se afirma nada que no se haya comprobado, y se nombra con qué se comprobó. No se presenta la propia actividad como estado del producto. Si algo no se ha mirado, se dice **«esto no lo he verificado»**, con esas palabras.

Dos casos que ya han pasado y que cuentan como mentira aunque no lo parezcan:

- dar por bueno un número que viene de un documento, sin decir que viene de un documento;
- dar por literal el **resumen** que ha hecho otra herramienta de un fichero. Un resumen no es el fichero: si no se ha leído el original, se dice.

Desarrollo: regla 0 y regla 2.

### R2 · Nunca atajos. Siempre el trabajo completo

«Hecho» se mide en capas, no en ficheros tocados. Un cambio de contenido vive en el JSON gallego, el JSON castellano, el audio gallego, el audio castellano, el imprimible, la interfaz y la documentación: **se enumeran las capas y se dice cuál se ha mirado y cuál no.**

Si el encargo tiene cinco partes y una se atasca, se terminan las otras cuatro enteras y se dice cuál falta y por qué. Entregar la parte fácil y callar la difícil es un atajo. Reducir el alcance lo decide Frank, no Claude Code.

Desarrollo: reglas 1b, 5, 5b y 6.

### R3 · Revisar todo antes de entregar

Antes de decir que algo está listo se revisa **lo entregado**, no lo recordado: se relee el diff propio buscando qué lo tumbaría, se corren los gates, se miran las capturas en gallego y en castellano, y se comprueba que los enlaces y las referencias sigan apuntando a algo que existe.

La revisión incluye **lo entregado en turnos anteriores de la misma tarea**. Si al revisar aparece un fallo propio ya empujado, se corrige y se dice; no se deja correr porque ya esté en la rama.

Desarrollo: reglas 1, 1b, 1c y 4.

### R4 · Nada confidencial en un documento público

Este repositorio es público, y lo son **todos** sus ficheros: el README, el manual, `STATUS.md`, `PROJECT.md` y este mismo `CLAUDE.md`. Antes de escribir una línea en cualquiera de ellos: *si esto lo lee el Concello, una familia o un evaluador, ¿les sirve, o solo cuenta cómo va la obra por dentro —o cómo va otro producto de la casa—?*

Nunca, en ninguno de los ficheros de este repositorio: rechazos de tienda con sus fechas, números de versión o motivos; el estado de las claves de firma; incidencias, clientes, fechas o nombres de fichero de **otros productos de la casa**.

Desarrollo: regla 0b.

### R5 · Hacer todo lo posible por completar la tarea

Un obstáculo no es el final del encargo. Antes de parar se prueban las vías que quedan, empezando por la menos invasiva, y se agotan.

Y lo que R5 **no** autoriza:

- no autoriza a ensanchar el encargo. Se agotan las vías **dentro** de lo pedido; lo que no se pidió sigue sin tocarse (regla 0a);
- no autoriza a inventarse el resultado que no se pudo obtener. **R1 manda sobre R5**: si una vía queda bloqueada, se dice que quedó bloqueada y con qué motivo exacto;
- no autoriza a saltarse un permiso denegado por una vía torcida. Se busca la vía legítima más sencilla; si tampoco, se para y se explica qué permiso hace falta.

Parar con las manos vacías solo vale si seguir sería inseguro, o si el resultado sería inútil en caso de equivocarse. En cualquier otro caso se entrega todo lo demás terminado y se dice, en una línea, qué falta y qué se necesita para cerrarlo.

### R6 · La orden se cumple, y se cumple entera

**Cumplir la orden de Frank es la obligación número uno.** No es una entrada más de una lista de prioridades: es el trabajo.

Tres cosas que esta regla prohíbe expresamente, porque las tres ya han pasado:

- **Entregar un porcentaje y llamarlo hecho.** Si el encargo abarca diez meses y tres niveles, hecho son treinta piezas, no tres. Una parte entregada con el resto sin mencionar no es un avance: es un incumplimiento disfrazado de avance.
- **Dar por cumplida una orden porque se tocó el asunto.** «Pon el calendario» no se cumple enseñando un bloque que solo aparece en un mes. «Usa el diseño del primer ciclo» no se cumple cambiando los colores. Lo cumplido se mide por lo que Frank ve al abrir la app, no por el diff.
- **Elegir el camino corto sin decirlo.** Antes de dar algo por imposible o por suficiente hay que **agotar las vías**: mirar si el material ya existe, si hay una pieza reutilizable, si el documento de referencia lo especifica. Y si de verdad falta algo, se dice qué falta y qué hace falta para cerrarlo, en la misma respuesta y sin esperar a que lo pregunte.

**R1 sigue mandando sobre esta.** Cumplir la orden nunca justifica afirmar algo sin comprobarlo: si una parte quedó fuera, se dice cuál y por qué, con esas palabras. Y R6 no deroga la 0a: lo que Frank NO pidió se sigue sin tocar. R6 obliga a hacer TODO lo pedido, no a hacer de más.

Coste propio: en el 2.º ciclo se entregaron tres asambleas de un curso de treinta, un calendario que solo enseñaba septiembre y un rediseño a medias. Se informó de ello como si fuera el encargo terminado con límites conocidos. No lo era: era la orden a medio cumplir.

---

## Reglas de producto

Este archivo importaba `.agents/rules/01-producto.md`, `02-flutter-android.md` y `03-contenido.md`. **Esos tres ficheros no existen en el repositorio**, así que las importaciones se han retirado: un import roto no es una regla, es una regla que nadie lee. Estas son las reglas, sin depender de ningún import:

- el niño no usa la pantalla;
- cero datos personales (los premios guardan contadores del adulto, nunca nada de una crianza: ver abajo);
- sin permiso INTERNET en release;
- nada con finalidad sanitaria;
- contenido en JSON, nunca escrito en los widgets.

No edites `.agents/` sin autorización: es la configuración de Antigravity.

Plataforma de esta fase: **solo Android**. No crees ni borres `ios/`.

## Reglas de trabajo (obligatorias, no negociables)

**Son el desarrollo de las cinco de arriba, no una lista aparte.** Donde R1…R5 dicen qué, estas dicen cómo, y en caso de choque manda R1…R5. Heredadas del proyecto anterior de la casa —solo las reglas: ni sus incidencias, ni sus clientes, ni sus nombres de fichero, que R4 deja fuera— y adaptadas a Flutter. Nacieron de errores reales. No son buenas prácticas genéricas: son lo que ya salió mal.

Su numeración se conserva —0, 0a, 0b, 1, 1b, 1c, 2…7— porque el código, los tests y `docs/` las citan por ese número.

### 0. No afirmes nada que no hayas comprobado · desarrollo de R1

| Puedes decir | Cuándo |
| --- | --- |
| «He escrito / he cambiado X» | Siempre. Es lo que hiciste, no dice nada del producto |
| «He comprobado X **con** Y» | Cuando Y existe y lo has ejecutado. **Nombra Y**: el gate, la captura, el comando |
| «Está hecho» | Solo con la evidencia al lado, y solo del alcance que cubre esa evidencia |

- **No presentes tu actividad como el estado del producto.** «Cambiado en el widget» y «analyze limpio» son hechos sobre ti. Frank necesita hechos sobre lo que la app hace.
- **`flutter analyze` no es verificación.** Corre los gates (§1b).
- **«Hecho» se mide en capas, no en ficheros editados.** Un cambio de contenido vive en: JSON gl, JSON es, audio gl, audio es, imprimible, ARB de interfaz y README. **Enumera las capas y di cuál has mirado y cuál no.**
- **Lo que Antigravity dejó escrito en `docs/` es contexto, no verdad.** Contrástalo con el código antes de repetirlo.
- **Nada llega a Frank como «entregado» mientras esté en una rama.** Se dice «en la rama X, pendiente de mergear» y se da la versión o el número de build.

**Si no lo has comprobado, dilo con esas palabras: «esto no lo he verificado».**

Coste heredado: se dijo «está hecho» tres veces sin haber mirado, y a la tercera la build ya estaba distribuida.

Coste propio: este proyecto llegó a declarar «1443/1443 · CERTIFIED READY FOR PRODUCTION» mientras la app no compilaba. El certificador leía los `.dart` y comprobaba que contuvieran `import flutter_test`.

### 0a. No actúes sin autorización · límite de R5

**No hagas nada que Frank no haya pedido.** Decide él. Si ves algo que convendría cambiar, **no lo cambies: díselo en una frase y espera.** Estas tres cosas no son un sí:

- que el cambio sea pequeño u obvio;
- que autorizara algo parecido en otro momento;
- que no conteste.

«Revisa y mejora» no es permiso para cambiar. Se ejecuta así: informe, Frank elige lotes, se aplica solo el lote elegido.

Coste heredado: un trabajo pedido para el galego tocó también un formulario que nadie mandó tocar, y el cambio salió publicado sin que nadie lo hubiera aprobado.

### 0b. Este repositorio es PÚBLICO · desarrollo de R4

Lo escrito aquí lo lee cualquiera: una familia, una escuela, el Concello, un evaluador de convocatoria. **El README describe el producto. No lleva contabilidad interna del proyecto.**

Fuera del README, sin excepción:

- **fechas y motivos de rechazos de tienda**, y cualquier historia de versiones rechazadas;
- **el estado de las claves de firma**: si están dadas de alta, con cuál y desde cuándo. Los nombres de los secrets viven donde se usan, en el workflow, y ahí se quedan;
- **incidencias de otros productos de la casa**, sus nombres de fichero internos y sus capturas;
- **contabilidad interna de QA**: qué no se ha visto en un aparato, qué gate estuvo roto durante meses, qué activo lo dibujó alguien que no es ilustrador, qué revisión legal está pendiente;
- **números de run, tamaños de artefacto y `versionCode`** como si fueran el estado del producto.

Nada de esto desaparece: **va a `STATUS.md`**, que es el fichero cuya regla es que cada línea diga con qué se comprobó. Y una advertencia real para quien usa la app —«estas imágenes no son fotos de un móvil»— no es contabilidad interna: esa se queda.

La prueba antes de escribir una línea en el README: *si esto lo lee el Concello o una familia, ¿les sirve, o solo cuenta cómo va la obra por dentro?* Si es lo segundo, va a `STATUS.md`.

Coste propio: el README llegó a llevar un dato de operación de tienda que este mismo fichero ya prohibía tres líneas más arriba. Lo escribió Claude Code. Que la regla estuviera escrita no bastó, porque estaba en una cita suelta y no en una regla numerada; por eso ahora lo es.

### 1. No digas que una pantalla está hecha sin haberla mirado

Todo cambio visual lleva **captura propia en emulador o aparato**, en gallego **y** en castellano:

```bash
flutter run -d <dispositivo>
adb exec-out screencap -p > docs/capturas/<pantalla>-<gl|es>.png
```

Las dos lenguas no miden lo mismo: una pantalla correcta en castellano puede cortarse en gallego. **Mira las capturas antes de decir «hecho».**

**Un documento generado se mira PAGINADO, página a página, antes de entregarlo.**
Que el gate del manual diga que el PDF viene del HTML actual solo dice de dónde
viene, no cómo se ve. Que el HTML se vea bien en una tira continua tampoco: una
captura de móvil mide tres veces el alto de un A4 y, en la hoja, se sale o se
corta. Si no hay visor de PDF en el entorno, se mide: se renderiza con el medio
de impresión al tamaño de la caja y se comprueba que ninguna figura, tabla ni
recuadro supere el alto ni el ancho de la página.

Coste propio: el manual se entregó con las veintidós capturas desbordando la
hoja. El PDF se construyó, el gate salió verde y nadie miró una página.

### 1b. «Hecho» exige los gates, no solo analyze

Los gates se sacan **del script o del workflow de CI** (`tools/gates.sh` o `.github/workflows/`), nunca de una lista escrita aquí. Una lista escrita a mano se queda atrás respecto al workflow, y entonces una build muere en un gate que no figuraba en ella.

Si todavía no existe ni script ni CI, díselo a Frank. Hasta entonces, el mínimo es:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --release
apkanalyzer manifest permissions build/app/outputs/flutter-apk/app-release.apk   # o aapt2 dump permissions
```

A eso se suma el validador de contenido, si existe. **Bloqueante:** INTERNET o cualquier permiso no aprobado en el APK release.

**Texto con audio:** si cambia el texto de un ítem que tiene audio, el audio gl/es se regenera **en el mismo commit**. Si no, la app enseña un texto y reproduce otro, y ningún test lo detecta.

Verde en local no es verde en CI. Si hay CI, no se dice «entregado» hasta que `main` tenga un run completo en verde.

### 1c. Un widget test o una golden NO prueban un Android

Flutter pinta su propia disposición, así que los tests se parecen al aparato más que una captura web de React Native. Aun así hay cuatro cosas que no se ven en ellos:

- en tests el texto sale con fuentes de relleno salvo que se carguen las reales;
- no hay insets reales (muesca, barra de gestos);
- no hay escala de texto del sistema ni densidades reales;
- el audio no suena de verdad.

La familia de defectos típica aquí es **`RenderFlex overflowed`** con una cadena gallega más larga o con texto grande del sistema. En debug salen las franjas amarillas y negras. **En release no sale nada: el texto simplemente se corta.**

En todo cambio de disposición:

- comprueba en aparato con gl, es y **escala de texto grande**;
- si no hay aparato, escribe **«esto no lo he visto en un aparato»**;
- lo más seguro sin aparato es **no cambiar la disposición**.

Lo que esta regla **no** autoriza: retener el cambio en una rama a la espera de que Frank lo mire. No puede mirar lo que no está en `main`. Ver 1d.

### 1d. Abre la app y llega hasta donde Frank dijo · desarrollo de R1 y R6

**Una golden enseña la pantalla QUE TÚ ELEGISTE construir.** Si elegiste la equivocada, la golden te la confirma en verde. Los tests, los gates y CI están todos por debajo de tu interpretación de la orden: ninguno puede desmentirla. La única comprobación que sí puede es **arrancar la app y llegar andando hasta el sitio que Frank nombró**.

Antes de tocar una línea por una orden de pantalla:

1. arranca la app de verdad;
2. navega hasta ese sitio **por el camino que usa Frank**, no por el fichero;
3. captura esa pantalla y **mírala**;
4. si lo que ves no es lo que él describe, **para y pregunta antes de cambiar nada**. No hay prisa que justifique rehacer la pantalla equivocada.

Al terminar, la misma ruta otra vez: arrancar, navegar, capturar, mirar.

**Sí se puede arrancar aquí.** No hay emulador de Android, pero sí escritorio Linux con pantalla virtual. Sobre una COPIA del repositorio, nunca sobre él:

```bash
apt-get install -y libgtk-3-dev imagemagick xdotool xvfb   # una vez
flutter config --enable-linux-desktop
flutter create --platforms=linux .          # en la copia
flutter build linux --debug
Xvfb :99 -screen 0 460x1000x24 &
DISPLAY=:99 ./descubre_con_lua &            # bundle: binario + data/ + lib/
DISPLAY=:99 import -window root tiro.png    # capturar
DISPLAY=:99 xdotool mousemove X Y click 1   # navegar
```

Dos avisos de lo que ahí NO es real: el arrastre con ratón no mueve un `PageView` salvo que se amplíe `dragDevices` —con el dedo sí—, y el almacenamiento de Android no existe, así que los contadores salen a cero. Lo que sí es real, y es lo que importa: **qué pantalla sale y qué hay dentro**.

**El sitio se nombra por el camino, no por el fichero.** «El calendario» no es `calendario_screen.dart`: es el sitio al que se llega por Inicio → Entrar en Modo Aula. Buscar la palabra con `grep` y quedarse con el fichero que sale es elegir la interpretación que ya sabes satisfacer. Si la orden nombra un sitio, escribe el camino completo en la respuesta **antes de empezar**, para que Frank lo corrija en una línea si te equivocaste de puerta.

**Si la orden nombra un elemento, va en TODOS los modos donde ese elemento pinta.** Enumera los modos —aula de 1.º ciclo, aula de 2.º ciclo, Academy— y di en cuál está y en cuál no.

**Un botón que lleva a una pantalla no es esa pantalla.** «Pon el calendario aquí» no se cumple poniendo un enlace al calendario.

**Y no está cumplida mientras viva en una rama.** Frank compila `main`. Si el cambio es de disposición y no se ha visto en aparato, se mergea igual y se dice con esas palabras que no se ha visto; retenerlo es incumplir la orden, no protegerla.

Coste propio: el Calendario se rehízo entero, con 379 tests, 14 gates y dos runs de CI en verde, sobre `calendario_screen.dart`. La orden era sobre el Calendario del **Modo Aula**, donde solo había un botón que saltaba fuera. Cuatro entregas seguidas dadas por buenas sin haber abierto la app ni una vez.

### 2. Informa de lo que Frank VA A VER, no de lo que has hecho

Primera línea de la respuesta: qué cambia en pantalla. Si no cambia nada visible (refactor, tests, docs), **dilo en la primera línea**.

### 3. Nada de feature flags para cambios de pantalla completa

Un flag convierte «está mergeado» y «se ve» en dos cosas distintas.

### 4. Un push por cambio, y solo a la rama destino

Nunca empujes el mismo commit a dos ramas. Un agente por rama a la vez: antes de empezar, `git status` y `git log --oneline -5`. Si hay cambios sin commit de otra herramienta, **para y díselo a Frank**.

### 5. «Premium» significa activos propios

Nada de emoji del sistema como iconografía: cambian entre fabricantes y nunca forman un set. Los iconos salen de un set propio coherente (misma rejilla, grosor y terminaciones). Si el set no existe, díselo a Frank antes de improvisar.

### 5b. La mascota es Lúa, la gata

- Es el mismo personaje que en el proyecto anterior de la casa, donde el sprite vive como rejilla de caracteres y de ella salen icono, icono adaptativo y splash.
- Aquí se **porta la rejilla**, no se redibuja a ojo. Vive en `assets/brand/lua_head.txt`, y de ahí salen icono, icono adaptativo y splash mediante `tools/build_launcher_icons.py`. Icono y splash deben salir de la misma fuente.
- **El sistema de premios existe, pero premia al ADULTO.** Frank lo pidió así. Lo que NO se hereda es el sujeto: allí los gana quien juega, que es la criatura; aquí el niño no toca la pantalla, así que premiar su «progreso» sería inventarse un dato que nadie ha medido. Hay dos recorridos separados: la docente por asambleas dirigidas, la familia por cápsulas leídas. Sigue sin heredarse el desfile ni el espejo con el periférico Lúa. Lúa aparece para la docente y la familia, nunca para captar la atención infantil.
- Los premios viven en `lib/features/premios/` y su contenido —niveles e insignias— en `assets/content/premios/premios.json`, nunca escrito en los widgets.

### 6. Rediseñar, no parchear

Si Frank dice que algo se ve pobre, se rehace la pieza entera y se enseña la captura. No se hacen rondas de ajustes de padding.

### 7. Menos prosa, más resultado

Comenta solo lo que evita que alguien rompa algo (red, datos, finalidad educativa, sincronía texto-audio). Calla el resto.

## El pulso se ve, no se oye

El metrónomo de la canción a pulso es **visual**. La razón no es estética: parte de las crianzas llevan audiófono o implante, y un metrónomo sonoro compite justo con la voz que tienen que seguir. El pulso se dibuja y el canal auditivo queda entero para la letra.

Los tiempos del compás salen de las marcas `*` de `letraConPulsos`, no de una configuración aparte: así el pulso no puede discrepar de lo que la docente está leyendo.

## Correo de contacto (regla fija)

El correo de contacto del proyecto es **siempre**:

```
frank.alberto.betances.reinoso@gmail.com
```

Aplica a la política de privacidad, las fichas de Google Play Console, los textos legales y cualquier documento de contacto. No lo sustituyas por una dirección de dominio (`@futureforkids.eu` u otra), ni propongas el cambio como mejora.

Lo comprueba un gate: `tools/check_contact_email.py`.

## Privacidad declarada = privacidad compilada

Si la app se publica en Google Play, la política de privacidad y el formulario de *Seguridad de los datos* deben decir lo mismo que el APK: sin datos, sin permisos, sin SDKs de terceros.

Cualquier cambio en lo que la app recoge (un permiso, un paquete, un campo guardado) obliga a actualizar **en el mismo cambio** la política y el formulario de Play Console.

**Lo que la app guarda hoy**, y nada más: la cuenta de uso de la persona adulta para los premios de Lúa —asambleas dirigidas, cápsulas leídas, racha actual y mejor racha, fecha del último día **sin hora**, e identificadores de insignias ganadas—. Va en el almacenamiento privado de la app (`getFilesDir()`), no identifica a nadie, no contiene nada de ninguna crianza y no puede salir del aparato porque no hay permiso de red. Lo guarda un gate: `test/features/premios_test.dart` falla si aparece una clave nueva en ese fichero.

Las URLs legales de esta app son estas, y no otras. Salen del sitio de GitHub Pages que publica `docs/`:

```
https://frankbetances.github.io/Descubre-con-lua/privacy.html   ← política de privacidad
https://frankbetances.github.io/Descubre-con-lua/
```

Son las que se declaran en Play Console. No reutilices las de ningún otro proyecto: describen otra app.

Lo comprueban dos gates, y hacen falta los dos:

- `tools/check_legal_urls.py --offline`, dentro de `tools/gates.sh`: que los ficheros existan en `docs/`, sean lo que dicen ser y lleven el correo de contacto.
- `.github/workflows/legal-urls.yml`, **a diario y por calendario**: que las URLs respondan 200 de verdad.

El segundo no es redundante. Un sitio de Pages se puede apagar con el fichero intacto y el último despliegue en verde: no se rompe el contenido, se apaga el sitio, y la tienda rechaza la ficha con un «HTTP server is returning 404». Ese fallo es mudo —no hay run rojo ni push que lo delate— y solo aparece semanas después por boca de la tienda, con la publicación parada. Un despliegue correcto no demuestra que el sitio esté vivo; solo lo demuestra pedir la URL.
