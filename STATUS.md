# Estado real de «Descubre con Lúa · Edición Vigo»

Este documento sustituye a `TEST_READY.md`, que certificaba «1443/1443 PASSED ·
CERTIFIED READY FOR PRODUCTION DEPLOYMENT» sin que se hubiese ejecutado nunca
un solo test.

Regla de este fichero: **cada línea dice con qué se comprobó, o dice que no se
ha comprobado.** Si no hay evidencia al lado, no se afirma.

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
| **El permiso de uso de los logotipos** | Concello de Vigo, Zona Franca y startTIC son marcas de terceros y en una ficha de Play sugieren respaldo institucional. Hace falta autorización escrita |

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
