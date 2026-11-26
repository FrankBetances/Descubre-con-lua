# Seguridad de los datos · Google Play Console

Declaración exacta del formulario **Seguridad de los datos** (*Data safety*) correspondiente al APK compilado (`com.earlify.descubreconlua`).

## Resumen del binario compilado

- **Permiso de red:** NINGUNO. El manifiesto elimina `android.permission.INTERNET` y `ACCESS_NETWORK_STATE` mediante `tools:node="remove"`.
- **Permisos declarados en el APK (`aapt2 dump permissions`):**
  1. `com.earlify.descubreconlua.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION` (inyectado por AndroidX)
  2. `android.permission.CAMERA` (opcional: `<uses-feature android:name="android.hardware.camera.ar" android:required="false"/>`)
- **SDKs de analítica, publicidad o telemetría:** NINGUNO.

## Respuestas del formulario en Play Console

| Pregunta de Play Console | Respuesta | Justificación verificable en código |
| --- | --- | --- |
| ¿Recoge o comparte tu aplicación alguno de los tipos de datos obligatorios de usuario? | **No** | Sin cuentas, sin red, sin analítica. Todos los ficheros (`progreso.json`, `premios.json`, `criancas.json`) se almacenan únicamente en el directorio privado de la app (`getFilesDir()` / almacenamiento interno). En casa, `criancas.json` guarda nombre/apodo, mes y año de nacimiento (sin día), edad, curso, año de revisión de septiembre, observaciones por semana del curso (sin fecha ni hora) y premios con Lúa (fechas en día, sin hora). |
| ¿Comparte tu aplicación datos de usuario con otras empresas u organizaciones? | **No** | No existe permiso `INTERNET` en el binario compilado (`tools/gates.sh` lo comprueba). |
| Uso de la cámara (`android.permission.CAMERA`) | **Solo procesamiento efímero en memoria RAM; no recogido ni compartido** | Se solicita únicamente al pulsar **Abrir escena en RA** o **Abrir espello facial** dentro de «Realidade aumentada con Lúa». Los fotogramas de ARCore / Filament y los puntos faciales de MediaPipe `face_landmarker.task` se procesan fotograma a fotograma en RAM y se descartan al instante. No se guarda ninguna foto, vídeo ni geometría facial en `getFilesDir()`, caché ni galería. Si el aparato no tiene cámara o ARCore, la app ofrece la versión sin cámara (láminas y voz). |
| Uso de grabaciones de audio / micrófono | **No aplicable** | Sin permiso `RECORD_AUDIO`, sin reconocimiento de voz. Solo reproducción offline de locuciones pregrabadas. |
| Política de privacidad declarada | `https://frankbetances.github.io/Descubre-con-lua/privacy.html` | Publicada en GitHub Pages (`docs/privacy.html`) y comprobada a diario por `.github/workflows/legal-urls.yml`. |
| Uso con público infantil (Política de Familias) | **Cumple** | Diseñada para adultos acompañantes (familias y docentes) y niñez 0–6 años bajo supervisión adulta. Cero anuncios, cero compras integradas, cero recopilación de datos personales. |
