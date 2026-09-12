# Descubre con Lúa · Edición Vigo

Aplicación Android educativa, **sin conexión**, para las escuelas infantiles
municipales de Vigo y sus familias. Primer ciclo de educación infantil (0-3
años). Todo el contenido existe en gallego y castellano.

- **Juega con Lúa · Aula** — la usa la docente en la asamblea.
- **Academy · Familias** — la usan las familias en casa.

**Finalidad exclusivamente educativa.** No es un producto sanitario: no evalúa,
no diagnostica y no trata nada. La criatura no usa la pantalla; la app es para
la persona adulta que acompaña.

## Documentación

| | |
| --- | --- |
| [**Manual de casos de uso**](docs/manual-casos-de-uso.html) | Cómo se usa, caso a caso: docente, familias y mantenimiento. También en [PDF](docs/Descubre-con-Lua-Manual-Casos-de-Uso.pdf) y [Word](docs/Descubre-con-Lua-Manual-Casos-de-Uso.docx) |
| [**STATUS.md**](STATUS.md) | Qué funciona y qué no, con la evidencia al lado de cada línea |
| [**PROJECT.md**](PROJECT.md) | Arquitectura y diseño |
| [**CLAUDE.md**](CLAUDE.md) | Reglas de trabajo del proyecto |

Si sólo vas a leer uno: **STATUS.md**, que separa lo comprobado de lo no
comprobado y nombra el comando que lo comprobó.

## Estado

Resumen honesto: **`main` pasa sus 12 gates** (run 16), el binario **no lleva ni
un permiso de red**, las **12 locuciones tienen grabación** y de cada run de
`main` sale un **AAB firmado con la clave de release**, listo para Play Console.

Lo que no está comprobado, y no lo arregla ningún run verde: **ninguna pantalla
se ha visto en un aparato** y **nadie ha escuchado las voces gallegas**. Los
gates miden picos, duraciones y cobertura; no dicen si el galego suena natural
ni si una cadena se corta en una pantalla pequeña.

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

- gallego → **Celtia**, do Proxecto Nós (*gated* en Hugging Face: requiere el
  secret `HF_TOKEN`)
- castellano → **Sharvard** (rhasspy/piper-voices)

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

La comprobación que cuenta se hace sobre el **APK compilado** con `aapt2`, no
sobre el manifiesto fuente.

Política publicada: [`docs/privacy.html`](docs/privacy.html).
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

## Estructura

```
lib/core/       tema, idiomas, audio (servicio, reproductor nativo, ids de voz)
lib/data/       modelos, cargador, repositorio, validador de contenido
lib/features/   juega/ (aula, asamblea de 6 fases, metrónomo) · academy/ (familias)
assets/content/ unidades y cápsulas en JSON, bilingües
assets/voice/   grabaciones neuronales (generadas en CI)
assets/brand/   rejilla de píxeles de Lúa: de aquí salen icono y splash
tools/          gates y tubería de voz
```
