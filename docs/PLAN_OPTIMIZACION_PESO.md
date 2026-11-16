# Plan · Que la app pese menos y vaya más fluida

Orden: O-20261116-1 (`docs/ORDENES.md`). Escrito para que lo ejecute otra sesión (Sonnet) sin más contexto que este fichero y `CLAUDE.md`.

**Tesis.** El peso de la app es la voz: 417 MB de grabaciones sobre unos 440 MB empaquetados. El código, las fuentes y las imágenes no llegan a 7 MB. Cualquier optimización que no toque el códec de la voz no se va a notar. Cambiar AAC por Opus recorta la voz entre un 46 % y un 63 % (medido con una muestra), sin quitar ni una locución.

## 1. Dónde está el peso (medido en `89691006`, 16/11/2026)

| Pieza | Ficheros | Tamaño | Dónde va | Cómo se midió |
| --- | ---: | ---: | --- | --- |
| `assets/voice/` (módulo base) | 29.358 | **368,2 MB** | APK base | `du`, suma por prefijo |
| ↳ `en_tutor` | 11.231 | 130,3 MB | | |
| ↳ `gl_tutor` | 6.087 | 112,5 MB | | |
| ↳ `es_tutor` | 6.084 | 90,5 MB | | |
| ↳ `en_slow` | 5.926 | 34,7 MB | | |
| ↳ `gl_slow` + `es_slow` | 30 | 0,2 MB | | |
| `assets/voice_pack/` (significados) | 7.732 | **49,3 MB** | asset pack *install-time* | `du` |
| `assets/content/` (JSON) | — | 17 MB | APK base, comprimido | `du` (en disco, sin comprimir) |
| `assets/brand/` | — | 4,8 MB | APK base | `du` |
| `assets/audio/mar_pulso_72bpm.wav` | 1 | 1,1 MB | APK base | `du` |
| `assets/fonts/` | 4 | 0,5 MB | APK base | `du` |

Hechos de la voz:

- **37.090 locuciones, 0 huérfanas, 0 duplicadas byte a byte.** Comprobado cruzando `tools/voice_corpus.collect_locutions()` con los ficheros y con MD5. No hay nada que podar: `prune_voice_assets.py` ya hace su trabajo.
- **Códec actual: AAC-LC, ~40 kbps, mono, 22,05 kHz** (`ffprobe` sobre dos ficheros; `AAC_BITRATE` en `tools/generate_voice_assets.py:194`).
- Por origen del texto (módulo base): biblioteca 122,2 MB · corpus 71,2 · significados 60,1 · tpr 24,7 · asamblea 20,6 · microcuento 16,0 · resto < 8 MB cada uno.
- **Prueba de Opus** (300 locuciones al azar de `assets/voice/`, `ffmpeg -c:a libopus -application voip`): a 24 kbps ocupan el **54 %**; a 16 kbps, el **37 %**. Proyección sobre los 417,5 MB: **~225 MB a 24k, ~155 MB a 16k.** Es una proyección desde una muestra, no una medida del total. **La calidad no la he escuchado: esto no lo he verificado.**
- El reproductor nativo (`MainActivity.kt`, `MediaPlayer` + `assets.openFd`) lee Ogg/Opus desde Android 5; `minSdk` es 24. Ya acepta `speed` (`setSpeed`, `MainActivity.kt:97-100`; `local_audio_player.dart:74`).

Hechos del código y la compilación:

- `android/app/build.gradle`: `minifyEnabled false`, `shrinkResources false`; `noCompress += 'm4a'`.
- `.github/workflows/ci.yml:250` y `:301`: `flutter build appbundle --release` sin `--split-debug-info` ni `--obfuscate`.
- `lib/data/repositories/content_repository.dart`: 10 `jsonDecode` en el hilo de la interfaz; en todo `lib/`, 37 `loadString` y ningún `Isolate.run`/`compute`. Los JSON grandes: `calendario_dias.json` 3,5 MB, `historias_progresivas.json` 2,7 MB, `leccions.json` 2,1 MB, `banco100_cuentos.json` 1,0 MB.

**No medido, y lo primero que hay que medir (L0):** el tamaño real de descarga del AAB por dispositivo. Todo lo de arriba es tamaño en disco del repositorio.

## 2. Decisiones de Frank (antes de L1 y L2)

Son de calidad de lo que se oye y de coste: no las toma Claude Code (R1).

- **D1 · Cómo se pasa la voz a Opus.**
  - **(a) Regenerar desde Piper/Celtia directamente a Opus (recomendada).** Una sola compresión, la mejor calidad. Coste: volver a sintetizar las 37.090 locuciones en `voice-assets.yml`, en tandas de 40 min por lengua; horas de CI (no lo he cronometrado).
  - (b) Recodificar los `.m4a` actuales a Opus en local. Minutos de trabajo, pero suma una segunda compresión con pérdida sobre la primera.
- **D2 · Calidad.** 24 kbps (recomendada: ~46 % menos, margen cómodo para voz) o 16 kbps (~63 % menos, más riesgo de sonido metálico en el gallego y el castellano largos). Se decide oyendo 10 locuciones de cada lengua en un móvil.
- **D3 · La voz lenta del inglés (`en_slow`, 34,7 MB).** Mantenerla sintetizada (mejor prosodia, recomendada si Frank la nota distinta) o generarla en el aparato reproduciendo `en_tutor` a 0,625 de velocidad (`setSpeed`), que ahorra los 34,7 MB enteros. Se decide oyendo las dos versiones de las mismas 10 palabras.

## 3. Lotes

Un lote = una rama, un PR, `tools/gates.sh` en verde en local antes de empujar (R000). Orden de ejecución: **L0 → L3 → L4 → L5** ya; **L1 y L2** cuando Frank conteste D1-D3.

### L0 · Medir de verdad y poner un techo (sin cambio visible)

- Script `tools/medir_peso.py`: compila (o recibe) el AAB, corre `bundletool build-apks` + `bundletool get-size total --dimensions=SDK,ABI` y escribe `docs/peso.json` (base, voice_pack, total por ABI) más una tabla en `STATUS.md` (R5: los tamaños no van al README).
- Gate `tools/check_peso.py` en `tools/gates.sh`/CI: falla si el módulo base supera el techo guardado en `docs/peso.json` + 2 %. Es la guarda de R∞+: que el peso no vuelva a crecer sin que nadie lo vea.
- Aceptación: `docs/peso.json` con los números de partida; el gate falla en un test que infla el techo.
- Riesgo: `bundletool` hay que descargarlo (jar de GitHub Releases). Si la red del entorno lo bloquea, se dice y se para este lote, sin inventar el número.

### L1 · Voz a Opus (el 90 % del ahorro) · espera D1 y D2

Capas que toca, todas en el mismo PR (regla 1b: texto y audio juntos):

1. `tools/generate_voice_assets.py`: `-c:a libopus -b:a <D2> -application voip`, contenedor `.ogg`. Mantener la normalización de volumen que ya hace.
2. Extensión: `lib/core/audio/voice_id.dart`, `lib/data/validators/content_validator.dart`, `tools/voice_corpus.py`, `check_voice_coverage.py`, `check_voice_levels.py`, `check_bundled_assets.py`, `prune_voice_assets.py`, `export_voice_corpus.py`, `.github/workflows/ci.yml`, `voice-assets.yml` (lista completa: `grep -rln '\.m4a' lib tools .github`).
3. `android/app/build.gradle`: `noCompress += 'ogg'`, igual que hoy con `m4a`: `openFd` falla sobre un asset comprimido. Comprobar con `unzip -v` sobre el APK que los `.ogg` salen «Stored».
4. `lib/core/audio/widgets/boton_escuchar.dart:195`: la ruta del `voice_pack` sigue igual, solo cambia la extensión vía `voiceAssetPath`.
5. Borrar los `.m4a` en el mismo commit que entran los `.ogg` (si no, el repositorio pesa el doble y el APK también).
6. Si D1 = (b): script `tools/recodificar_voz_opus.py` que recorre `assets/voice*` y comprueba duración original ≈ nueva (±50 ms) por fichero.

Aceptación:
- `check_voice_coverage.py` y `check_voice_levels.py` en verde con las 37.090.
- `docs/peso.json` (L0) baja al menos un 40 % en el módulo base, medido con `bundletool`.
- Test de widget que reproduce una locución `.ogg` por `MethodChannel` mockeado.
- **En un Android real**: oír 10 locuciones de gl, es y en (incluido un significado del `voice_pack`). Si no hay aparato, escribir «esto no lo he oído en un aparato» y pedírselo a Frank antes de mergear.

### L2 · Voz lenta en el aparato · solo si D3 = generarla

- `offline_audio_service.dart`: para `VoiceStyle.slow` en inglés, reproducir la ruta `en_tutor` con `speed: 0.625` (es `1/1,6`, el `LENGTH_SCALE` de `voice_corpus.py`).
- `voice_corpus.py`: dejar de emitir `en_slow`; `prune_voice_assets.py` borra los 5.926.
- Aceptación: `grep en_slow assets/voice | wc -l` = 0; test que comprueba que el estilo lento pide `speed` 0,625 sobre el fichero `en_tutor`; escuchado en aparato.

### L3 · Los JSON grandes, fuera del hilo de la interfaz (fluidez, no peso)

- Un único helper en `lib/data/repositories/`, p. ej. `Future<dynamic> decodificarAsset(String ruta)`: `loadString` y, si el texto pasa de 200 KB, `Isolate.run(() => jsonDecode(raw))`.
- Sustituir los `jsonDecode(raw)` de `content_repository.dart` y de `leccion_model.dart` por el helper.
- Gate `tools/check_json_isolate.py`: falla si aparece `jsonDecode(` sobre un `loadString` fuera del helper.
- Ojo: el repositorio tiene un plan «sembrado» con `SynchronousFuture` (`content_repository.dart:1046`). No romper ese camino de tests: correr `flutter test` entero.
- Aceptación: `flutter test` en verde; con `flutter run --profile` en aparato, abrir el Calendario de Modo Aula sin frames > 16 ms en el DevTools timeline (si no hay aparato, decirlo).

### L4 · Compilación más ligera (sin cambio visible)

- `ci.yml` (las dos llamadas a `flutter build appbundle`): añadir `--obfuscate --split-debug-info=build/symbols` y subir `build/symbols` como artefacto del run (sin él, un fallo en producción no se puede leer).
- `build.gradle`: `minifyEnabled true` y `shrinkResources true` en release. Comprobar con `apkanalyzer` que el APK arranca y que `MainActivity` y el canal de audio siguen (añadir `proguard-rules.pro` con `-keep class com.earlify.descubreconlua.** { *; }`).
- Gate de permisos: seguir sin INTERNET en el release (ya lo comprueba `gates.sh`).
- Aceptación: `docs/peso.json` antes/después; la app arranca y suena en el bundle de escritorio Linux y, si hay, en aparato. El ahorro esperado son pocos MB (no medido).

### L5 · Piezas pequeñas (~1,3 MB)

- `assets/audio/mar_pulso_72bpm.wav` (1,1 MB) → `.ogg` Opus; adaptar `tools/check_pulse_bpm.py` (que lee el WAV) y `paso_cancion_widget.dart:106`.
- `assets/brand/logos/earlify-health.jpg` (335 KB) y `dr-betances-crest.jpg` (104 KB) → WebP; actualizar `credits_screen.dart:205,227`. Captura de Créditos en gl y es (regla 1).

## 4. Lo que vi y no entra en el plan (regla 0a)

No reduce peso ni fluidez, así que no se toca sin que Frank lo pida: pantallas de más de 1.700 líneas (`calendario_screen.dart`, `leccion_da_semana.dart`) y `content_repository.dart` con 1.292 líneas. Partirlas facilitaría el mantenimiento, no la app.

## 5. Para la sesión que lo ejecute

- Leer `CLAUDE.md` entero antes de tocar nada (R∞, R0, R1, R000).
- La orden ya está en `docs/ORDENES.md` como O-20261116-1; marcar cada criterio solo con su evidencia al lado.
- Cada informe empieza por lo que falta, con números: «de 37.090 locuciones, pasadas a Opus N; base: X MB → Y MB».
- Prompt para pegar:

> Lee CLAUDE.md y docs/PLAN_OPTIMIZACION_PESO.md. Ejecuta L0, L3, L4 y L5 en ese orden, un PR por lote, con tools/gates.sh en verde en local antes de cada push. No empieces L1 ni L2 hasta que Frank haya contestado D1, D2 y D3 en docs/ORDENES.md (O-20261116-1). Al acabar cada lote, rellena su evidencia en docs/ORDENES.md y dime qué falta, con números.
