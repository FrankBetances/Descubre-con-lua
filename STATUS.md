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
| `check_voice_coverage.py` | Que toda locución que la app puede reproducir tenga grabación en el paquete |
| `flutter build apk --release` | Que el APK de release compile |
| Permisos del APK | Que el **artefacto compilado** no declare ni un permiso (leído con `aapt2`, no del manifiesto fuente) |

---

## Estado por área

### Verificado en esta sesión

Con Flutter 3.47.3 instalado y ejecutado en este contenedor:

| Área | Evidencia |
| --- | --- |
| La app y la suite compilan | `flutter analyze` → *No issues found* |
| La suite pasa | `flutter test` → *All tests passed!* (107 tests) |
| Formato | `dart format --set-exit-if-changed` → limpio |
| Correo de contacto | `tools/check_contact_email.py` → OK |
| Corpus de voz sincronizado | `tools/export_voice_corpus.py --check` → OK |
| Tempo declarado vs pista real | `tools/check_pulse_bpm.py` → 72,3 BPM medidos, coinciden |
| Paridad de identificadores de voz | `test/core/voice_id_test.dart`: Dart, Python y el corpus real de Valeria dan el mismo hash |
| Icono de Lúa | Renderizado y **mirado** en todas las densidades |

Y en CI (GitHub Actions, runner limpio):

| Área | Evidencia |
| --- | --- |
| La suite pasa en limpio | `flutter test` → 107 tests, en el runner |
| **El APK release compila** | `✓ Built build/app/outputs/flutter-apk/app-release.apk (50.9MB)` |
| **El binario no lleva permisos de red** | `aapt2 dump permissions` sobre el APK: un único permiso, `com.earlify.descubreconlua.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. **Sin INTERNET, sin estado de red, sin nada más** |
| La tubería de voz llega a Celtia | Resolvió el repo de `proxectonos` por la API de Hugging Face y encontró `celtia.pth`; sólo falló por el *gating* |
| 6 de 12 grabaciones sintetizadas | Las castellanas, con Sharvard. Medidas con ffmpeg: mono 22 kHz, pico a −3,0 dBFS |

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
| **Ninguna pantalla se ha visto en un aparato** | No hay emulador ni dispositivo. Cero capturas en `docs/capturas/`. El APK de CI se puede instalar: está como artefacto del workflow |
| **La app nunca se ha ejecutado** | Que el APK compile y que la asamblea funcione en el aula son cosas distintas |
| **Desbordes de disposición** | Sin aparato no hay forma de ver un `RenderFlex overflowed`. En release no se ve nada: el texto simplemente se corta. Falta comprobar en gallego, castellano y con escala de texto grande |
| **Las 12 grabaciones de voz** | `huggingface.co` también está bloqueado aquí. El gate de cobertura falla, correctamente |

### Bloqueante conocido: la app no reproduce nada

`tools/check_voice_coverage.py` falla con **6 de 12** locuciones sin grabación:
las seis gallegas. Las seis castellanas ya están sintetizadas y commiteadas. No
es un fallo del gate: es el estado del producto.

Para resolverlo:

1. Aceptar las condiciones del modelo Celtia de `proxectonos` en Hugging Face
   con una cuenta y crear un token de lectura.
2. Añadirlo como secret `HF_TOKEN` del repositorio.
3. Lanzar el workflow **Generate Voice Assets**.

El workflow sintetiza gallego con **Celtia · Proxecto Nós** y castellano con
**Sharvard**, masteriza a −3 dBFS, y commitea los `.m4a`. Los modelos corren
ahí y jamás en el aparato: el APK lleva grabaciones, no inferencia.

---

## Decisiones pendientes de Frank

1. **La canción a pulso es un recitado, no un canto.** Una voz neuronal habla;
   no canta. La grabación del paso 1 es la letra recitada a pulso constante, y
   la pista instrumental de 72 BPM sigue disponible como metrónomo. Reversible.
2. **Responsable del tratamiento.** La política nombra a «Earlify Health S.L.»
   y afirma cumplimiento estricto de COPPA y RGPD. No se ha tocado: si esa
   sociedad está constituida y asume esa responsabilidad no es algo que se
   pueda afirmar desde aquí.
3. **Tramo etario.** La única unidad está marcada `"0-3"`, que casa con las dos
   pestañas del filtro, así que el filtro 0-2 / 2-3 nunca se ejercita con el
   contenido que existe.
4. **Ilustraciones.** El cuento referencia cuatro imágenes que no están en el
   repositorio. La pantalla ahora lo dice en palabras útiles para la docente,
   en vez de imprimir la ruta del fichero.
5. **`.agents/rules/01-producto.md`, `02-flutter-android.md` y
   `03-contenido.md` no existen.** El CLAUDE.md los importa. `.agents/` es
   configuración de Antigravity y no se ha tocado.
6. **Cobertura de contenido.** Academy declara 5 bloques y tiene 1 cápsula;
   Juega con Lúa declara filtro por tramo y tiene 1 unidad.

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
