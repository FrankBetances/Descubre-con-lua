# Descubre con Lúa · Edición Vigo

Aplicación Android educativa, **sin conexión**, para las escuelas infantiles
municipales de Vigo y sus familias. Primer ciclo de educación infantil (0-3
años). Todo el contenido existe en gallego y castellano.

- **Juega con Lúa · Aula** — la usa la docente en la asamblea. Incluye
  **Formación · Aula**: una cápsula de tres minutos por cada paso de la asamblea.
- **Academy · Familias** — la usan las familias en casa.
- **Calendario Escola · Fogar** — los diez meses del curso, de septiembre a
  junio. La docente registra la asamblea, la familia registra el juego de tres
  minutos en casa, y el día que coinciden las dos cosas queda enlazado.
- **Los premios de Lúa** — nivel, XP, racha, insignias y las medallas del
  calendario. Premian **a la persona adulta** que usa la app, nunca a la
  criatura.

**El inglés no es una lengua de esta app: es contenido que se escucha.** Ninguna
pantalla se lee en inglés. Lo que hay son las palabras, las órdenes de cuerpo
(TPR) y la frase de cada mes, cada una con su grabación: la persona adulta pulsa
y oye cómo se dice antes de decírselo a la criatura. Una maestra de una escuela
infantil de Vigo no tiene por qué pronunciar «Crunch leaves» de oído.

**Finalidad exclusivamente educativa.** No es un producto sanitario: no evalúa,
no diagnostica y no trata nada. La criatura no usa la pantalla; la app es para
la persona adulta que acompaña.

**Licencia: gratis para las familias, con licencia para las instituciones.**
Para una familia o una persona a título individual, gratis y para siempre. Para
una escuela, un ayuntamiento, un gabinete o una empresa, hace falta una licencia
por escrito. El texto completo está en [LICENSE.md](LICENSE.md).

## Documentación

| | |
| --- | --- |
| [**Manual de casos de uso**](docs/manual-casos-de-uso.html) | 17 casos de uso —docente, familias y mantenimiento— y las 14 imágenes de pantalla. También en [PDF](docs/Descubre-con-Lua-Manual-Casos-de-Uso.pdf) y [Word](docs/Descubre-con-Lua-Manual-Casos-de-Uso.docx) |
| [**STATUS.md**](STATUS.md) | Qué funciona y qué no, con la evidencia al lado de cada línea |
| [**PROJECT.md**](PROJECT.md) | Arquitectura y diseño |
| [**CLAUDE.md**](CLAUDE.md) | Reglas de trabajo del proyecto |
| [**LICENSE.md**](LICENSE.md) | Quién puede usar esto y con qué condiciones |

Si sólo vas a leer uno: **STATUS.md**, que separa lo comprobado de lo no
comprobado y nombra el comando que lo comprobó.

## Estado

Resumen honesto: **`main` pasa sus 13 gates** (run 52), el binario **no lleva ni
un permiso de red**, las **351 locuciones tienen grabación** y de cada run de
`main` sale un **AAB firmado con la clave de release**, listo para Play Console.

| | |
| --- | --- |
| Último run verde de `main` | 52 · APK 39,38 MB · AAB 65,10 MB · `versionCode` 52 |
| Tests | 218 |
| Contenido | 1 unidad de aula · 5 cápsulas de Academy · 6 cápsulas de formación docente · 10 meses de calendario |
| Voz | 351 locuciones (123 gl + 123 es + 105 en) dentro del paquete |

Lo que no está comprobado, y no lo arregla ningún run verde:

- **Ninguna pantalla se ha visto en un aparato.** Lo que sí está comprobado es
  que caben: `filtro_edad_test.dart` y `calendario_escala_test.dart` abren las
  pantallas en gallego y castellano, a escala de texto 1,0 y 1,8, y fallan si
  algo desborda. Eso caza los desbordes; no caza la muesca, la barra de gestos,
  la densidad real ni el audio sonando.
- **Nadie ha escuchado las voces.** Ni el galego de Celtia ni el inglés de
  LJSpeech. Ningún gate dice si una frase sale imitable para una docente.
- **`check_voice_levels` no está midiendo nada.** El job de Gates no instala
  `ffmpeg`, así que el gate escribe `SKIP: ffmpeg is not installed` y el script
  lo cuenta como PASS. Es un salto leyéndose como una comprobación: **hoy nadie
  ha medido el pico de las 351 grabaciones**, ni en local ni en CI. Se arregla
  instalando `ffmpeg` en el job y haciendo que el salto falle en CI.

Defectos abiertos que hay que mirar antes de publicar:

- el contenido declara **cinco palabras de vocabulario** por unidad, con
  definición y grabación, y **ninguna pantalla las muestra**;
- los logotipos de startTIC, del Consorcio da Zona Franca y del Concello ya
  están puestos, pero **falta la autorización escrita de uso de las tres
  marcas**: en una ficha de Play sugieren respaldo institucional
  (`assets/brand/logos/README.md`);
- **el manual no documenta todavía el Calendario Escola·Fogar**: sigue con sus
  17 casos de uso y sus 14 imágenes. Las cuatro imágenes nuevas ya están en
  `docs/capturas/`.

## Comprobar

```bash
flutter pub get
tools/gates.sh --fast   # formato, análisis, tests y gates de contenido
tools/gates.sh          # además compila el APK release y audita sus permisos
```

CI ejecuta ese mismo script (`.github/workflows/ci.yml`). La lista de gates vive
en el script, no en un documento que se pueda quedar atrás:

| Gate | Qué comprueba |
| --- | --- |
| `dart format` · `flutter analyze` · `flutter test` | Formato, análisis y la suite, ejecutándose de verdad |
| `check_contact_email.py` | Que no aparezca ningún correo distinto del fijo del proyecto |
| `export_voice_corpus.py --check` | Que el corpus de voz siga sincronizado con los textos |
| `check_pulse_bpm.py` | Que el tempo mostrado sea el que suena, **medido del audio** |
| `check_pulse_markers.py` | Que el compás sea constante e igual en las dos lenguas |
| `check_voice_coverage.py` | Que toda locución reproducible tenga grabación en el paquete |
| `check_voice_levels.py` | Que ninguna grabación del paquete pique cerca de saturación, **medido del fichero** |
| `check_manual_build.py` | Que el PDF y el Word del manual salgan del HTML actual y no de uno anterior |
| `flutter build apk --release` | Que el APK compile |
| Permisos del APK | Que el **binario** no declare más permiso que el que inyecta AndroidX |

## Publicar

El mismo workflow que corre los gates compila el binario firmado, con la forma
del `android.yml` de Valeria+ adaptada a Flutter. No hay un segundo workflow que
recompile lo mismo con otra configuración.

| Artefacto | Cuándo se produce | Retención |
| --- | --- | --- |
| `android-apk` (`.apk`) | En `main` y en «Run workflow» | 5 días |
| `android-aab` (`.aab`) | En `main` y en «Run workflow», **solo con secrets de firma** | 3 días |
| `android-mapping` (`mapping.txt`) | Cuando exista (hoy `minifyEnabled false`) | 30 días |

Las ramas `claude/**` **compilan igual** —los gates y Gradle corren— pero no
suben el fichero: la regla de trabajo es que nada llega a Frank hasta estar en
`main` con run verde. Para bajarse el APK de una rama: Actions → «Gates» → «Run
workflow» eligiendo esa rama.

Al final de cada run se retiran los artefactos viejos y se dejan 2 copias de
cada nombre (10 del mapa de R8), para que el almacenamiento tenga un suelo fijo
en vez de crecer con el ritmo de commits.

### Claves de firma

Se configuran en *Settings → Secrets and variables → Actions*. Son los mismos
nombres que en Valeria+, pero **los secrets son por repositorio**: hay que darlos
de alta también aquí.

| Secret | Contenido |
| --- | --- |
| `ANDROID_RELEASE_KEYSTORE_BASE64` | `base64 -w0 release.keystore` |
| `ANDROID_RELEASE_STORE_PASSWORD` | Contraseña del keystore |
| `ANDROID_RELEASE_KEY_ALIAS` | Alias de la clave |
| `ANDROID_RELEASE_KEY_PASSWORD` | Contraseña de la clave |

**Los cuatro secrets están configurados en este repositorio** y verificados en el
run 16 de `main`. Si faltasen, el APK se firmaría con la **clave de depuración**
—se instala a mano, y Google Play lo rechaza— y el AAB no se generaría, porque un
AAB sin firmar no se puede subir a ningún sitio y solo sería un fichero que
engaña.

Un gate en rojo también bloquea el AAB: los pasos posteriores a uno fallido se
saltan. Cuando el AAB no aparezca, el motivo está más arriba en el run.
El paso «Comprobar con qué clave va firmado» lee el certificado **del APK** con
`apksigner` y lo publica en el resumen del run, igual que el gate de permisos lee
el binario en vez de la configuración.

`versionCode` sale del número de run del workflow, porque Play exige que cada
subida lleve uno mayor que el anterior; `pubspec.yaml` lo deja fijo en 1.

> Perder el keystore sin tener activado *Play App Signing* deja la app sin
> posibilidad de actualizarse nunca más. Con *Play App Signing* activado, lo
> peor que pasa es pedir una clave de subida nueva.


## El pulso se ve, no se oye

El metrónomo de la canción a pulso es **visual**, como en Valeria+. No es una
decisión estética: parte de las criaturas llevan audiófono o implante, y un
metrónomo sonoro compite justo con la voz que tienen que seguir.

Los tiempos del compás salen de las marcas `*` de la letra, no de una
configuración aparte, así que el pulso no puede discrepar de lo que la docente
lee.

## Voz

El audio se genera con voces neuronales en tiempo de compilación y viaja
grabado dentro del paquete. Los modelos **nunca** corren en el aparato.

Casi todas las tarjetas con texto seguido llevan botón de altavoz: la lectura
del cuento, las preguntas, la exploración, las matemáticas, el puente con la
casa, y en Academy las cuatro partes de cada cápsula y sus afirmaciones. Si un
texto no tiene grabación, el botón **no se pinta** —ni apagado ni con aviso—:
un altavoz que no suena promete algo que no cumple.

- gallego → **Celtia**, do Proxecto Nós (*gated* en Hugging Face: requiere el
  secret `HF_TOKEN`)
- castellano → **Sharvard** (rhasspy/piper-voices)
- inglés → **LJSpeech** (rhasspy/piper-voices)

**El inglés es un caso aparte.** No hay pantallas en inglés: lo que se graba es
el léxico, las órdenes TPR y la frase de cada mes del calendario, que salen de
`assets/content/calendario/meses.json`. La persona adulta pulsa la pastilla y
oye cómo se dice antes de decírselo a la criatura. Una pastilla sin grabación se
pinta igual, con la palabra legible y sin altavoz.

```bash
python3 tools/export_voice_corpus.py       # corpus desde assets/content
python3 tools/generate_voice_assets.py --lang gl
python3 tools/check_voice_coverage.py      # ¿falta alguna grabación?
```

El identificador de cada grabación es el hash de su propio texto, así que
editar una frase cambia el identificador, la grabación pasa a faltar y el gate
lo detecta. La app no puede enseñar un texto y reproducir otro.

## Privacidad

Cero datos personales, cero analítica, cero SDK de terceros, y ningún permiso
de red. `pubspec.yaml` no tiene una sola dependencia externa: la reproducción de
audio va por un `MethodChannel` contra el `MediaPlayer` de Android.

**Lo único que la app guarda**, en el almacenamiento privado del aparato: los
contadores de los premios **de la persona adulta** —asambleas dirigidas,
cápsulas leídas, racha actual y mejor racha, la fecha del último día *sin hora*
e identificadores de insignias—. No identifica a nadie, no contiene nada de
ninguna criatura y no puede salir del aparato. Lo guarda un gate:
`test/features/premios_test.dart` falla si aparece una clave nueva en ese
fichero.

La comprobación que cuenta se hace sobre el **APK compilado** con `aapt2`, no
sobre el manifiesto fuente.

**URLs legales** (las que se declaran en Play Console; salen del sitio de Pages
que publica `docs/`):

| | |
| --- | --- |
| Política de privacidad | `https://frankbetances.github.io/Descubre-con-lua/privacy.html` |
| Página del proyecto | `https://frankbetances.github.io/Descubre-con-lua/` |

Las vigilan dos gates: `check_legal_urls.py --offline` dentro de `tools/gates.sh`
comprueba los ficheros, y `.github/workflows/legal-urls.yml` pide las URLs **a
diario**. El segundo existe porque un sitio de Pages se puede apagar sin que se
ponga rojo nada: en Valeria+, Google rechazó la ficha por un 404 teniendo el
último despliegue en verde. Un despliegue correcto no demuestra que el sitio
esté vivo.

Contacto: frank.alberto.betances.reinoso@gmail.com

## El manual

`docs/manual-casos-de-uso.html` es la **fuente única**. De ahí salen el PDF y el
Word; no se editan a mano:

```bash
npm install playwright                          # sólo para el PDF
CHROMIUM_PATH=<chrome> node docs/build-pdf.js   # → docs/*.pdf
pip install python-docx lxml                    # sólo para el Word
python3 docs/build-docx.py                      # → docs/*.docx
python3 tools/check_manual_build.py             # ¿alguno se quedó atrás?
```

Misma estructura que Valeria+, y por su misma razón: allí el texto llegó a estar
duplicado dentro del constructor y el Word se quedó describiendo una versión
anterior sin que nada avisara.

Las 14 imágenes de pantalla viven en `docs/capturas/` y se regeneran con:

```bash
flutter test --tags capturas --update-goldens test/capturas_test.dart
```

**No son fotos de un móvil.** Son el árbol de widgets real pintado por el motor
de Flutter, con la tipografía y el contenido de la app, pero sin muesca, sin
barra de gestos, sin la densidad de un aparato concreto y sin audio. Ver
[`docs/capturas/README.md`](docs/capturas/README.md). Sustituirlas por capturas
de verdad es reemplazar los PNG; el manual no se toca.

## Licencia

**Gratis para las familias. Con licencia para las instituciones.**

| Quién | Qué puede hacer |
| --- | --- |
| Una familia, una persona a título individual | Usar la app, leer y compilar el código, modificarlo para su casa. **Gratis, para siempre, sin pedir permiso** |
| Una escuela, un ayuntamiento, un hospital, una asociación, una universidad | **Licencia previa por escrito**, aunque el uso sea gratuito y la entidad no tenga ánimo de lucro |
| Cualquiera que cobre por usarla o por servicios prestados con ella | **Licencia previa por escrito** |

Nadie —ni siquiera en uso personal— puede redistribuirla, publicarla en una
tienda, quitarle los créditos ni presentarla como propia.

Las condiciones de una licencia institucional se acuerdan caso por caso y
**pueden ser gratuitas** (convenios con administraciones, pilotos). Se piden en
frank.alberto.betances.reinoso@gmail.com.

Los componentes de terceros conservan su licencia: la tipografía Nunito (SIL
OFL 1.1, en `assets/fonts/OFL.txt`), Flutter y sus paquetes, y los modelos de
voz Celtia, Sharvard y LJSpeech, que **solo corren en compilación y nunca en el
aparato**. Los logotipos institucionales son marcas de sus titulares y no se
licencian aquí.

El texto que manda es [LICENSE.md](LICENSE.md).

## Estructura

```
lib/core/       tema, idiomas, audio (servicio, reproductor nativo, ids de voz)
lib/data/       modelos, cargador, repositorio, validador de contenido
lib/features/   juega/ (aula, asamblea de 6 fases, metrónomo, formación docente)
                academy/ (familias) · calendario/ (escola·fogar, 10 meses)
                premios/ (insignias y medallas) · bienvenida/ · creditos/
assets/content/ unidades, cápsulas y calendario en JSON, bilingües
                calendario/ (10 meses + guía de inglés en casa)
assets/voice/   grabaciones neuronales (generadas en CI)
assets/brand/   rejilla de píxeles de Lúa: de aquí salen icono y splash
                awards/ (los 10 glifos de insignia) · logos/ (marcas)
docs/capturas/  las imágenes de pantalla (14 del manual + calendario y guía)
tools/          gates y tubería de voz
LICENSE.md      condiciones de uso: familias gratis, instituciones con licencia
```
