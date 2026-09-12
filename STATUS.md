# Estado real de «Descubre con Lúa · Edición Vigo»

Este documento sustituye a `TEST_READY.md`, que certificaba «1443/1443 PASSED ·
CERTIFIED READY FOR PRODUCTION DEPLOYMENT» sin que se hubiese ejecutado nunca
un solo test.

Regla de este fichero: **cada línea dice con qué se comprobó, o dice que no se
ha comprobado.** Si no hay evidencia al lado, no se afirma.

---

## Cómo se comprueba

```bash
tools/gates.sh          # todos los gates
tools/gates.sh --fast   # sin la compilación del APK (rápido, para iterar)
```

CI ejecuta **ese mismo fichero** (`.github/workflows/ci.yml`). La lista de
gates no vive escrita en ningún documento: vive en el script. En Valeria la
lista del CLAUDE.md se quedó atrás respecto al workflow y una build murió en un
gate que no figuraba en ella.

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
| Paridad de identificadores de voz | `test/core/voice_id_test.dart`: Dart, Python y el corpus real de Valeria dan el mismo hash |
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

`.github/workflows/ci.yml` corre los gates **y** compila el binario firmado, con
la forma del `android.yml` de Valeria+ adaptada a Flutter. Del run 16 salen:

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

1. **El metrónomo es visual, como en Valeria.** No suena. La razón está en el
   propio fichero de Valeria: parte de las crianzas llevan audiófono o
   implante, y un metrónomo sonoro compite justo con la voz que tienen que
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
5. **El keystore de subida.** El workflow ya sabe firmar, pero no hay clave.
   Hay que decidir si esta app usa un keystore **propio** o el mismo de
   Valeria+ (técnicamente se puede: son `applicationId` distintos), y si se
   activa *Play App Signing* — que es lo que evita que perder el fichero deje
   la app sin posibilidad de actualizarse nunca más.
6. **Minificación.** `minifyEnabled false` y `shrinkResources false`. Valeria+
   va con R8 y por eso guarda `mapping.txt`; aquí el paso que lo sube está
   puesto pero no sube nada. Activarlo cambia el binario, así que no se ha
   tocado: es una decisión, no un olvido.
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
