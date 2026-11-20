# P9.4 · Informe técnico sobre la Realidad Aumentada de Valeria para «Descubre con Lúa»

> **Estado**: **PARADO EN INFORME (sin código de RA ni permiso de cámara).**
> Conforme a la orden P9.4, no se añade código de RA ni `android.permission.CAMERA` sin el «sí» explícito de Frank.

## 1. Qué hace la Realidad Aumentada de Valeria (`e2a2a5e8`)

Valeria implementa dos modalidades nativas independientes en Android (`android-native/valeria-ar/`), expuestas a TypeScript mediante `src/valeriaArBridge.ts`:

1. **Escenas 3D sobre la mesa con sets físicos y muñeco Lúa (`ValeriaArSceneActivity` + `arScenes.ts` + `arActivities.ts` + `worlds/`)**:
   - Usa la **cámara trasera** y planos de mesa detectados por ARCore para fijar un ancla 1:1 en metros.
   - Superpone modelos `.glb` de los sets y piezas (`AR_SET_MODELS`) junto con formas/efectos guiados (`tile`, `circle`, `rings`, `line`, `flow`, `arrow`, `label`) y respuestas de Lúa (`LuaLink.ts`: 28 expresiones faciales oficiales más patrones de luz `LIGHT_TO_OPCODE_PARAM` y vibración `HAPTIC_TO_OPCODE_PARAM`, en pantalla o vía protocolo BLE cuando existe enlace físico).
   - **Sets cubiertos**:
     - Sets principales (`src/steam/worlds/`): `S0` (El kit), `S1` (El camino), `S2` (El sonido), `S3` (Las rampas), `S4` (El soplo), `S5` (El puente), `S6` (El jardín).
     - Maquetas de oficios (`arActivities.ts` + `arScenes.ts`): `S8`–`S11`.
     - Solo Lúa sobre mesa: `L02`–`L05`.
   - Confirmación de hitos por la persona adulta en pantalla (mientras no existe detector automático de piezas), siguiendo el ciclo tripartito (`observa → experimenta → construye`).

2. **Gestos faciales frente a la cámara frontal (`ValeriaArActivity` + `luaSolo.ts` + `ValeriaArSceneLaunch.tsx`)**:
   - Usa la **cámara frontal** exclusivamente con actividades sin voz ni texto invasivo (`L01`, `L07`, ejercicios `ar1`–`ar6`) y una prueba previa de aptitud del dispositivo (`A/B/C/D`).
   - ARCore gestiona la sesión de cámara y cede fotogramas (`acquireCameraImage()`) a MediaPipe Face Landmarker (`478` puntos de referencia + `52` blendshapes compatibles con ARKit + matriz `4×4`). Lúa cambia de expresión al inicio (`luaStart`) y al final (`luaEnd`) sin interrumpir el gesto.

## 2. Motor, paquetes nativos y licencias

Según `android-native/valeria-ar/build.gradle` y `scripts/fetch-ar-model.js`:

| Componente | Artefacto / Origen | Versión | Licencia | Compatible app con ánimo de lucro |
| --- | --- | --- | --- | --- |
| Sesión de cámara y tracking de planos | `com.google.ar:core` | `1.54.0` | **Apache-2.0** | Sí |
| Motor de renderizado 3D (sin SceneView) | `com.google.android.filament:{filament,gltfio,filament-utils}-android` | `1.72.1` | **Apache-2.0** | Sí |
| Landmarks y blendshapes faciales | `com.google.mediapipe:tasks-vision` | `0.10.29` | **Apache-2.0** | Sí |
| Modelo ML empaquetado offline | `face_landmarker.task` (`3.758.596 B`, SHA-256 fijado) | `float16/1` | **Apache-2.0** | Sí |
| UI host nativa | `androidx.appcompat:appcompat` · `androidx.compose.ui:ui` · `kotlinx-coroutines-android` | `1.7.0` / `1.9.0` | **Apache-2.0** | Sí |

No utiliza librerías con licencia NC/ND, copyleft fuerte ni dependencia de `io.github.sceneview` (descartado explícitamente en Valeria para no arrastrar BOMs incompatibles ni subir Compose en toda la app).

## 3. Permisos, red y estado actual de «Descubre con Lúa»

- **Qué pide la RA de Valeria (`android-native/valeria-ar/src/main/AndroidManifest.xml`)**:
  - Declara **`android.permission.CAMERA`**.
  - Marca como **opcionales (`android:required="false"`)** `camera`, `camera.front`, `camera.any`, `camera.ar` y orientaciones (`screen.portrait`, `screen.landscape`), más `<meta-data android:name="com.google.ar.core" android:value="optional" />`.
- **¿Necesita red en ejecución?**
  - **No.** Todos los modelos `.glb`, mallas y `face_landmarker.task` viajan empaquetados en `src/main/assets/` con `noCompress 'task', 'glb'` y verificación SHA-256 en compilación (`preBuild`). Ninguna actividad de RA abre sockets ni envía fotogramas fuera del aparato.
  - **Matiz operativo en Android**: si el dispositivo no tiene instalados los *Google Play Services for AR*, `ArCoreApk.requestInstall()` pide al sistema/Play Store instalarlos cuando el usuario intenta abrir AR; si rechaza o no hay cámara compatible, la función se degrada sin romper la app.
- **Estado actual de «Descubre con Lúa»**:
  - `android/app/src/main/AndroidManifest.xml` elimina explícitamente `INTERNET`, `ACCESS_NETWORK_STATE` y `ACCESS_WIFI_STATE` (`tools:node="remove"`), y no declara `CAMERA`.
  - El gate de `tools/gates.sh` falla si el APK de lanzamiento declara cualquier permiso distinto de `com.earlify.descubreconlua.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`.
  - `docs/privacy.html` y la ficha de Google Play declaran explícitamente **0 permisos peligrosos / cámara no solicitada / app 100% offline**.

## 4. Cómo se llevaría a Flutter sin permiso `INTERNET` (si Frank dice «sí»)

1. **Arquitectura nativa sin red**:
   - Portar las actividades Kotlin (`ValeriaArSceneActivity` / `ValeriaArActivity`) como librería/módulo Android dentro de `android/` (usando exactamente `com.google.ar:core:1.54.0`, `filament-android:1.72.1` y opcionalmente `tasks-vision:0.10.29`, todo **Apache-2.0**).
   - Comunicar Flutter y Android mediante un `MethodChannel` equivalente a `valeriaArBridge.ts` (`isArAvailable`, `launchArScene`, etc.) con **degradación elegante** (si el aparato no soporta ARCore o cámara, o no acepta el permiso en tiempo de ejecución, se oculta/omite sin error).
   - Mantener `tools:node="remove"` para `INTERNET`, `ACCESS_NETWORK_STATE` y `ACCESS_WIFI_STATE` en `AndroidManifest.xml`.
   - Empaquetar todos los `.glb` y `face_landmarker.task` dentro de `android/app/src/main/assets/` (sin descarga en caliente).
   - **Orientación STEAM en gl y es**: asociar cada set con el fenómeno del experimento en `assets/content/steam/steam_do_mes.json`:
     - `materia` → `S0` (kit / soportes) y `S5` (puente / masas)
     - `acustica` → `S2` (El sonido) y `S4` (El soplo / aire)
     - `cinematica` → `S1` (El camino) y `S3` (Las rampas)
     - `optica` → `S6` (El jardín: luz y sombras)
     - `logica` → `S8`–`S11` (maquetas de secuencias y turnos) y `L02`–`L05` (Solo Lúa).
2. **Impacto obligatorio en el MISMO commit que añada cámara/RA**:
   - Añadir `android.permission.CAMERA` (con `uses-feature required="false"` y `com.google.ar.core="optional"`).
   - Actualizar `docs/privacy.html` (apartado 3 de permisos en `gl`, `es` y `en`) indicando que la cámara se usa únicamente de forma local y efímera para la RA educativa, sin grabación ni transmisión.
   - Actualizar el formulario de **Seguridad de los datos** en Google Play y la ficha de la tienda.
   - Actualizar la lista blanca del gate de permisos de APK en `tools/gates.sh` para admitir `android.permission.CAMERA` junto con `DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (manteniendo bloqueado `INTERNET`).

## 5. Decisión pendiente para Frank

> **Pregunta**: ¿Autorizas añadir `android.permission.CAMERA` (opcional en manifest, sin `INTERNET`, todo procesado en el dispositivo) y actualizar `docs/privacy.html`, Seguridad de los datos de Play y `tools/gates.sh` para activar el módulo de RA con Lúa y los sets STEAM?
> Hasta recibir tu «sí», este bloque se mantiene detenido sin código nativo de cámara ni permiso añadido.
