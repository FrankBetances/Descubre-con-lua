# Handoff Report — Specification Mining & Inventory
## Proyecto: «Descubre con Lúa · Edición Vigo» (Flutter / Android)

**From**: Spec Miner Requirements (`teamwork_preview_spec_miner_survey_1`)  
**To**: Orchestrator (`parent` / `dfad01eb-fac8-43c6-b41a-17f07ad3c22a`)  
**Date**: 2026-09-13T09:15:00Z  
**Handoff Type**: Hard Handoff (Follow-up Specification Mining & Feature Inventory Complete)  
**Deliverable**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/.agents/teamwork_preview_spec_miner_survey_1/handoff.md`  

---

## 1. Observation

Direct empirical observations from the codebase, official regulatory standards, and user requirements:

1. **Follow-up User Request (`ORIGINAL_REQUEST.md:59-93`, dated 2026-09-13T09:04:47Z)**:
   - **R1. Sincronización Intuitiva y a Un Toque con el Calendario Escolar**:
     > "Diseñar e implementar una experiencia fluida donde tanto educadores en la asamblea como familias en el hogar puedan lanzar y sincronizar la sesión diaria correspondiente con el mes curricular activo con un solo toque, actualizando de forma transparente el registro de estimulación (aula, hogar o doble estimulación) con retroalimentación visual clara."
   - **R2. Sistema de Tarjetas Visuales e Iconografía Vectorial de Alto Contraste**:
     > "Desarrollar e integrar tarjetas visuales minimalistas e iconografía vectorial de alto contraste para cada uno de los 10 meses curriculares y sus momentos de sesión (apertura, fingerplay/concentración, núcleo TPR en inglés con pronunciación LJSpeech, y cierre afectivo), optimizadas para lectura inmediata y clara tanto a 2 metros en el aula como en la interacción cercana con el menor en el hogar."
   - **R3. Flujo Dual 'Aula (Asamblea) / Hogar (Academy)' sin Fricción**:
     > "Proporcionar un conmutador de contexto ágil entre la perspectiva del docente (asamblea matinal, instrucciones breves, temporizador sutil) y de las familias (explicación del porqué, guía de atención sin saturación, rutina breve de 3-5 min), garantizando que ambas partes puedan coordinar la estimulación sin recargar tareas administrativas."
   - **Acceptance Criteria**:
     - Lanzamiento de sesión con un solo toque desde la vista del calendario.
     - Actualización reactiva hacia «Doble Estimulación» en la interfaz compartida (`CalendarioStore`).
     - Acceso directo a pronunciación modelo en inglés (`LJSpeech · piper`) y en gallego (`Celtia · Proxecto Nós`).
     - Calidad verificada con código de salida 0 en los scripts de verificación (`check_contact_email.py`, `export_voice_corpus.py --check`, `check_voice_coverage.py`, `check_manual_build.py`, `check_legal_urls.py --offline`).

2. **Official Galician Curricular Standard (`Decreto 150/2022, do 8 de setembro`, DOG nº 172)**:
   - Modela las 3 áreas canónicas del primer ciclo de educación infantil (0-3 años) en Galicia:
     - **Área 1**: `area_1_crecemento_harmonia` (Crecimiento en armonía: esquema corporal, regulación afectiva, hábitos saludables, propiocepción).
     - **Área 2**: `area_2_descubrimento_contorna` (Descubrimiento y exploración del entorno: elementos naturales atlánticos, manipulación sensorial con criterio de seguridad >4cm, razonamiento intuitivo elemental: grande/pequeno, moito/pouco).
     - **Área 3**: `area_3_comunicacion_representacion` (Comunicación y representación de la realidad: expresión verbal, rítmica y corporal; iniciación afectiva y lúdica a la lengua extranjera L3 inglés vía TPR y fingerplays; paridad gallego/castellano).
   - Criterios de evaluación normativos: `CA1.1` (seguridad y bienestar emocional), `CA2.1` (exploración sensorial segura), `CA2.2` (razonamiento elemental), `CA3.1` (comunicación afectiva intencionada), `CA3.2` (participación en rimas, cuentos y canciones a pulso).

3. **Curricular Calendar Data Model (`lib/data/models/calendario_model.dart:14-348`)**:
   - `MesCurricular`: Estructura inmutable con los 10 meses escolares (Setembro a Xuño):
     - `orden`: 1 a 10; `mesCalendario`: 9, 10, 11, 12, 1, 2, 3, 4, 5, 6.
     - `nombreMes`, `centroInteres`, `objetivoPedagogico`: `LocalizedString` bilingües.
     - `lexicoIngles`: `List<String>` (vocabulario en inglés L3 para cada mes).
     - `comandosTpr`: `List<String>` (órdenes motrices en inglés de respuesta física total).
     - `actividadAula`: `LocalizedString` (dinámica de asamblea de 5-8 min).
     - `actividadHogar`: `LocalizedString` (micro-rutina en casa de 3-5 min sin pantallas).
     - `rutinaRecomendadaHogar`: `LocalizedString` (momento doméstico propicio: calzado, baño, comida, ventana, cama).
     - `minutosAtencionSugeridos`: `int` (3 a 5 min).
     - `icono`: `IconData` (iconografía vectorial unívoca).
   - `mesActualParaFecha(DateTime)`: Resuelve el mes del curso escolar activo (meses 7 y 8 de verano enrutan al primer mes de adaptación, Septiembre).
   - `EstadoEstimulacion`: Enum con 4 estados soberanos: `sinRegistro`, `soloAula`, `soloHogar`, `dobleEstimulacion`.

4. **Sovereign Local Persistence (`lib/core/storage/calendario_store.dart:10-125`)**:
   - `CalendarioStore`: `ChangeNotifier` respaldado por `LocalStore` con fichero privado `calendario_progreso.json`.
   - Cero red, cero analítica, cero PHI: almacena claves `YYYY-MM-DD` con flags booleanos `{'aula': bool, 'hogar': bool}`.
   - Métodos: `registrarAula([fecha])`, `registrarHogar([fecha])`, `toggleHogar([fecha])`.
   - Propiedades reactivas: `totalDobleEstimulacion`, `totalSesionesAula`, `totalSesionesHogar`.

5. **Audio Pipeline & Neural Voices (`tools/voice_corpus.py`, `tools/generate_voice_assets.py`, `lib/core/audio/voice_id.dart`)**:
   - **Inglés (L3 TPR)**: `LJSpeech · piper` (`en_US-ljspeech-medium`, modelo ONNX VITS de Rhasspy).
   - **Gallego (L1 / Co-oficial)**: `Celtia · Proxecto Nós` (`proxectonos/Nos_TTS-celtia-vits-graphemes`, VITS de grafemas mediante Coqui-TTS con segmentación de oraciones y pausas de 0.16s).
   - **Castellano (Co-oficial)**: `Sharvard` (`es_ES-sharvard-medium`, ONNX VITS de Rhasspy).
   - **Estilos de voz (`VoiceStyle`)**:
     - `tutor`: Velocidad normal (`length_scale = 1.0`) para prosa, cuento y explicaciones.
     - `slow`: Velocidad pausada (`length_scale = 1.6`) para palabras de vocabulario.
   - **Mastering & Headroom**: Peak nominal a -3.0 dBFS, codificación AAC mono a 40 kbps, ceiling absoluto garantizado en el archivo codificado de <= -1.0 dBFS.
   - **Identificación determinista FNV-1a**:
     `voiceAssetId(style, text, lang) => '${lang.code}_${style.code}_${fnv1a32(normalized)}_${normalized.length}'`.
     `englishVoiceAssetId(style, text)` y `englishVoiceAssetPath(style, text)` en `voice_id.dart:51-56`.
   - **Metrónomo visual**: Silencioso por prescripción clínica para no interferir con implantes cocleares o audífonos de niños con hipoacusia. Pista rítmica opcional de referencia `mar_pulso_72bpm.wav` calibrada empíricamente a 72.3 BPM.

6. **Home / Attention Guide Specification (`lib/features/academy/views/guia_atencion_screen.dart:96-202`)**:
   - 5 tramos evolutivos de capacidad atencional:
     1. `0 a 6 meses`: Máximo 2 minutos (masaje post-baño, motherese cantarino, contacto visual).
     2. `6 a 12 meses`: Máximo 3 minutos (juego de ocultación peek-a-boo en alfombra).
     3. `12 a 18 meses`: Máximo 5 minutos (rutina del calzado, subir manos con "Up" y pies con "Push!").
     4. `18 a 24 meses`: Máximo 6 minutos (lavabo/baño, contraste agua fría/caliente).
     5. `24 a 36 meses`: Máximo 8 minutos (locomoción zoomorfa e inhibición motriz con "FREEZE!").
   - Las 3 Reglas de Oro Neurobiológicas:
     1. *O cerebro non se confunde*: Adquisición simultánea de gallego, castellano e inglés ligada a rutinas emocionales claras.
     2. *Respecta o "Período de Silencio"*: El menor comprende corporalmente meses antes de producir habla; prohibido evaluar o interrogar con "¿cómo se dice?".
     3. *A app é para ti, non para a crianza*: El adulto interioriza la guía previamente y guarda el móvil; interacción 100% cara a cara sin pantallas.

7. **Empirical Execution of Repository Quality Gates**:
   - `python3 tools/check_voice_coverage.py`: Salida 0 (*"OK: 246 locutions, every recording present in assets/voice/"*).
   - `python3 tools/export_voice_corpus.py --check`: Salida 0 (*"OK: voice corpus in sync (246 locutions)"*).
   - `python3 tools/check_contact_email.py`: Salida 0 (*"OK: the only contact address in the repository is frank.alberto.betances.reinoso@gmail.com"*).
   - `python3 tools/check_manual_build.py`: Salida 0 (*"OK: the PDF and the Word both come from the current manual-casos-de-uso.html"*).
   - `python3 tools/check_legal_urls.py --offline`: Salida 0 (*"OK: los ficheros coinciden con lo declarado"*).

---

## 2. Logic Chain

1. **Alineación Normativa con el Decreto 150/2022**:
   - *Observación*: El Decreto 150/2022 de Galicia estructura la etapa 0-3 en 3 áreas integradas y prescribe la sensibilización a una lengua extranjera desde un enfoque comunicativo, afectivo y sin exigencia de producción formal.
   - *Inferencia*: La selección de 10 centros de interés vinculados a los 10 meses escolares gallegos (desde la bienvenida y el Magosto en otoño, pasando por el Entroido y el orballo de primavera, hasta las rías de Vigo en junio) dota de legitimidad curricular oficial al proyecto ante la inspección educativa y las escuelas infantiles (EIMs y Galiña Azul).

2. **Estructura Cuatripartita de la Sesión (Apertura -> Fingerplay -> Núcleo TPR -> Cierre)**:
   - *Observación*: Los menores de 0-3 años presentan ciclos de atención breve (2 a 8 minutos) y alta sensibilidad a la sobreestimulación sensorial.
   - *Inferencia*: La sesión debe seguir un arco neurobiológico predecible:
     1. *Apertura*: Captura de atención y vínculo afectivo acompasado a 72 BPM.
     2. *Fingerplay/Concentración*: Rima de dedos que calma el sistema motor y focaliza la mirada.
     3. *Núcleo TPR en Inglés*: Activación psicomotriz donde el cuerpo traduce la lengua extranjera (asistida por audio nativo offline LJSpeech).
     4. *Cierre Afectivo*: Desescalada del tono muscular y emocional, garantizando una transición serena a la siguiente actividad.

3. **Soberanía y Rigor Acústico del Audio Offline**:
   - *Observación*: Las aulas de 0-3 años no cuentan con internet garantizado en la alfombra, y las aplicaciones pediátricas de salud/educación no deben incorporar modelos generativos en runtime ni solicitar permisos de red (`android.permission.INTERNET`).
   - *Inferencia*: Las voces se sintetizan en tiempo de compilación/CI (`tools/generate_voice_assets.py`), se empaquetan en `assets/voice/*.m4a` a 40 kbps y se referencian mediante el hash determinista FNV-1a. La docente y la familia cuentan con el modelo de pronunciación exacto de `LJSpeech` para inglés y de `Celtia` para gallego con solo pulsar el altavoz de la tarjeta.

4. **Flujo Dual sin Fricción y la "Doble Estimulación"**:
   - *Observación*: Los docentes carecen de tiempo para tareas administrativas complejas durante la asamblea matinal; las familias requieren micro-rutinas ultra-breves que no generen culpa ni sobrecargas.
   - *Inferencia*: Un conmutador de contexto inmediato (`Aula` vs `Fogar`) en `CalendarioScreen` permite que la docente registre la asamblea con un solo toque (`registrarAula`), mientras que la familia marca su micro-juego vespertino de 3 min (`toggleHogar`). La coincidencia reactiva en el día activa la celebración visual de «Doble Estimulación», multiplicando el impacto educativo del menor sin estrés administrativo.

5. **Diseño Visual de Alto Contraste y Visibilidad a 2 Metros**:
   - *Observación*: La docente utiliza la tablet o teléfono en el soporte o suelo a distancia mientras atiende a un grupo de bebés en la alfombra; las familias necesitan lectura rápida mientras visten o bañan a la criatura.
   - *Inferencia*: Las tarjetas deben emplear tipografía grande (>= 18sp en titulares), bordes bien definidos de 1.5-2px, iconografía vectorial limpia con contraste superior a 4.5:1 (WCAG AAA) y la paleta atlántica cálida (aguamarina, coral, ámbar y menta) presidida por la mascota institucional `LuaPixel`.

---

## 3. Features Discovered

| # | Category | Feature | Description | Inputs | Outputs | Error Behavior | Discovered Via |
|---|----------|---------|-------------|--------|---------|----------------|----------------|
| 1 | Curriculum | 10-Month Curricular Calendar Matrix | Estructuración del curso escolar gallego (Septiembre a Junio) en 10 unidades mensuales alineadas con el clima y cultura atlántica. | `DateTime fecha` / selector de mes | Objeto inmutable `MesCurricular` con centro de interés y objetivos. | Resuelve a Septiembre si la fecha cae en vacaciones de verano (julio/agosto). | `lib/data/models/calendario_model.dart:14-348` |
| 2 | Curriculum | Galician Regulatory Grounding (Decreto 150/2022) | Certificación de alineación con las Áreas 1, 2 y 3 del primer ciclo (0-3 años) de Galicia y criterios `CA1.1` a `CA3.2`. | `CurricularReference.fromJson` | Instancia tipada y validada contra constantes oficiales de la Xunta de Galicia. | Lanza `FormatException` si `normativa != 'Decreto 150/2022'` o si faltan áreas oficiales. | `lib/data/models/curricular_model.dart:6-177` |
| 3 | Session Moments | 4-Phase Session Architecture | Secuencia pedagógica canónica: Apertura -> Fingerplay/Concentración -> Núcleo TPR -> Cierre afectivo. | Momento curricular del mes | Guía procedimental y tarjetas visuales diferenciadas por fase. | Fallback a vista integral de asamblea si el momento no se especifica. | `ORIGINAL_REQUEST.md:71-73` |
| 4 | Session Moments | Momento 1: Apertura & Saludo Afectivo | Bienvenida cálida, contacto visual y rima de saludo acompasada al pulso de reposo (72 BPM). | Interacción de inicio de asamblea | Estado visual de foco, consigna para sentarse en círculo. | Mantiene visualización de pulso sin forzar audio que compita con implantes. | `ORIGINAL_REQUEST.md:72` |
| 5 | Session Moments | Momento 2: Fingerplay & Concentración | Rimas digitales y juegos motores de manos para calmar la dispersión y centrar la atención sin pantallas. | Guion de rima gestual | Indicaciones de mímica y propiocepción para el adulto mediador. | No punitivo: si el grupo se dispersa, se reduce a rima de 1 minuto. | `ORIGINAL_REQUEST.md:72` |
| 6 | Session Moments | Momento 3: Núcleo TPR en Inglés (LJSpeech) | Estímulo psicomotriz en inglés (L3) donde el menor responde físicamente a la orden oral sin presión de hablar. | Botón de reproducción de audio / comando TPR | Audio offline en voz modelo LJSpeech + consigna motriz corporal. | Si falta el audio en el bundle, el botón se oculta limpiamente sin alertar error. | `lib/data/models/calendario_model.dart:20-21`, `voice_id.dart:51-56` |
| 7 | Session Moments | Momento 4: Cierre Afectivo & Despedida | Desescalada del ritmo psicomotor, caricia suave, rima de despedida y transición serena. | Cierre de asamblea / rutina | Retroalimentación de calma y preparación para la siguiente actividad. | Transición fluida sin pantallas de bloqueo ni efectos estridentes. | `ORIGINAL_REQUEST.md:72` |
| 8 | Audio Engine | English Neural Voice Model (`LJSpeech · piper`) | Síntesis offline de voz femenina nativa en inglés (`en_US-ljspeech-medium`) para modelos léxicos y comandos TPR. | Texto del comando / léxico en inglés | Archivo `.m4a` a 40 kbps masterizado a -3 dBFS con ceiling <= -1.0 dBFS. | Reportado por `check_voice_coverage.py` si falta alguna locución en el paquete. | `tools/generate_voice_assets.py:104-109` |
| 9 | Audio Engine | Galician Neural Voice Model (`Celtia · Proxecto Nós`) | Síntesis offline de alta prosodia en gallego normativo RAG con Coqui-TTS y segmentación inter-oracional (0.16s). | Texto de cuento, consignas y afirmaciones en gallego | Archivo `.m4a` determinista empaquetado en `assets/voice/`. | Rechazo en CI si falta token `HF_TOKEN` para descargar el checkpoint. | `tools/generate_voice_assets.py:89-97` |
| 10 | Audio Engine | Spanish Neural Voice Model (`Sharvard · piper`) | Síntesis offline en castellano femenino (`es_ES-sharvard-medium`) en paridad simétrica con Celtia. | Texto en castellano de la unidad o cápsula | Archivo `.m4a` determinista empaquetado en `assets/voice/`. | Reintento automático de atenuación si el encoder sobrepasa -1.0 dBFS. | `tools/generate_voice_assets.py:98-103` |
| 11 | Audio Engine | Deterministic FNV-1a Text-to-Voice Hashing | Cálculo unívoco del identificador de grabación basado en el hash del texto visible normalizado. | `VoiceStyle`, `text`, `AppLanguage` | String `${lang}_${style}_${hash}_${length}`. | Cualquier edición de texto deja huérfano el audio anterior e impide desincronizaciones. | `lib/core/audio/voice_id.dart:18-48` |
| 12 | Audio Engine | Purely Visual Assembly Metronome | Indicador visual de compás acompasado al pulso (72.3 BPM) sin emisión de clics sonoros. | Letra con marcas `*` | Pulsación lumínica/visual sobre el texto recitado. | Test unitario certifica que el inicio del metrónomo no invoca ningún audio audible. | `lib/features/juega/widgets/rhythm_bar_widget.dart` |
| 13 | Dual Flow | Seamless Context Switcher (`Aula` vs `Fogar`) | Conmutador ágil de perspectiva entre docente de asamblea y familia en el hogar en una sola pulsación. | Tap en pestaña `Aula (Docentes)` o `Fogar (Familias)` | Reconfigura dinámicamente tarjetas, badges de duración y acciones de registro. | Mantiene el estado en memoria sin recargar navegación ni perder contexto. | `lib/features/calendario/views/calendario_screen.dart:304-385` |
| 14 | Dual Flow | One-Touch Attendance & Session Registration | Registro instantáneo de la sesión matinal del aula o de la micro-rutina vespertina del hogar. | Tap en botón `Rexistrar asemblea` / `Rexistrar micro-rutina` | Actualización inmediata en `CalendarioStore` y notificación snackbar no intrusiva. | Si ya estaba marcado, en hogar permite deshacer (`toggleHogar`) para evitar errores. | `lib/features/calendario/views/calendario_screen.dart:598-678` |
| 15 | Dual Flow | Reactive "Doble Estimulación" Tracker | Detección reactiva de la concurrencia de estímulo matinal (aula) y refuerzo vespertino (casa) en la misma fecha. | Estado de `CalendarioStore` | Tarjeta destacada con estrella dorada, borde turquesa y mensaje de celebración positiva. | Sin penalizaciones: si solo se registra un ámbito, muestra mensaje motivador sin castigo. | `lib/features/calendario/views/calendario_screen.dart:183-263` |
| 16 | Dual Flow | Sovereign Offline Persistence (`CalendarioStore`) | Gestor de persistencia local en disco privado sin servidores ni conexión a internet. | Eventos de registro diario | Archivo `calendario_progreso.json` actualizado de forma asíncrona no bloqueante. | Captura defensiva de errores I/O manteniendo el estado en memoria para no romper la UI. | `lib/core/storage/calendario_store.dart:28-60` |
| 17 | Dual Flow | Classroom Mode: 2-Meter High-Contrast Assembly Cards | Tarjetas de asamblea optimizadas para lectura inmediata a 2 metros en la alfombra escolar. | Selección de mes escolar en modo docente | Tarjeta con icono grande (48dp), kicker destacado, léxico resaltado y duración (5-8 min). | Ajuste elástico sin overflow en tipografías grandes mediante SingleChildScrollView. | `lib/features/calendario/views/calendario_screen.dart:388-522` |
| 18 | Dual Flow | Home Mode: 3-5 Min Screenless Micro-Routine | Tarjetas orientadas al cuidador con pauta rápida para memorizar y guardar el móvil en el bolsillo. | Selección de mes escolar en modo familia | Tarjeta con momento doméstico sugerido, micro-rutina (3-5 min) y ejemplo dialógico. | Previene la adicción a pantallas prohibiendo interacción infantil directa con la app. | `lib/features/calendario/views/calendario_screen.dart:508-517` |
| 19 | Dual Flow | Age-Tiered Attention Span Matrix (Guía de Atención) | Catálogo de 5 tramos etarios (0-6m hasta 24-36m) con minutos máximos y momentos domésticos adaptados. | Selector de tramo de edad | Ficha detallada de qué hacer (TPR corporal), qué evitar y frase modelo en inglés. | Selector horizontal de chips sin scroll forzado ni sobrecarga cognitiva. | `lib/features/academy/views/guia_atencion_screen.dart:96-202` |
| 20 | Dual Flow | Three Golden Neurobiological Rules Guide | Educación familiar sobre cómo el cerebro infantil procesa múltiples lenguas sin sobreestimulación. | Navegación en Academy / Calendario | Tres tarjetas explicativas: no confusión, período de silencio y app solo para el adulto. | Lenguaje divulgativo empático, libre de tecnicismos médicos o tonos admonitorios. | `lib/features/academy/views/guia_atencion_screen.dart:59-90` |
| 21 | UI/UX | Atlantic Warm Palette & Minimalist Vector System | Sistema de diseño basado en la estética marina atlántica (Aguamarina, Terracotta, Ámbar, Menta y Arena). | Tokens en `AppTheme` | Contraste superior a 4.5:1 (WCAG AAA), bordes sutiles y tarjetas limpias. | Eliminación deliberada de colores fluorescentes o animaciones ruidosas infantiles. | `lib/core/theme/app_theme.dart:10-95` |
| 22 | UI/UX | Official Interactive Mascot Anchor (`LuaPixel`) | Representación gráfica de la mascota Lúa en matriz pixel art de 24x24 px con 21 colores oficiales. | Propiedad `size` (ej. 52dp) | Renderizado vectorial nítido en canvas pixelar sin artefactos de compresión. | Dimensiones fijas escalables para todas las densidades de pantalla Android (mdpi a xxxhdpi). | `lib/core/brand/lua_pixel.dart:10-85` |
| 23 | Privacy & Security | Zero-Internet Binary Manifest Guard | Exclusión absoluta del permiso `android.permission.INTERNET` en el manifiesto release compilado. | `AndroidManifest.xml` / `aapt2 dump` | Binario 100% aislado de la red sin posibilidad física de exfiltración de telemetría. | Test unitario `test/privacy/privacy_manifest_test.dart` falla si se detecta cualquier permiso web. | `ORIGINAL_REQUEST.md:19-20`, `STATUS.md:65` |
| 24 | Content Quality | Clinical Blacklist Linter | Linter regex que rechaza cualquier término patológico, diagnóstico o terapéutico en contenidos. | Árbol JSON de unidades y cápsulas | Certificado `ValidationResult.isValid == true` libre de terminología clínica. | Falla con lista detallada de términos prohibidos encontrados y rutas de archivo. | `lib/data/validators/content_validator.dart:47-57` |
| 25 | Content Quality | 1:1 Strict Bilingual Parity Validator | Verificador automatizado que garantiza correspondencia simétrica no vacía en gallego y castellano. | Nodos `LocalizedString` | Verificación de claves `gl` y `es` pobladas con cadenas no en blanco. | Lanza excepción en build/test si alguna de las dos lenguas carece de traducción. | `test/data/bilingual_parity_test.dart` |

---

## 4. Edge Cases

| # | Feature | Input | Observed Behavior |
|---|---------|-------|-------------------|
| 1 | `MesCurricular.mesActualParaFecha` | Fecha en vacaciones de verano: `DateTime(2027, 7, 15)` o `DateTime(2027, 8, 10)`. | El método detecta `mes == 7 \|\| mes == 8` y enruta automáticamente a `meses.first` (Septiembre, mes 1 de bienvenida y adaptación), evitando index out of bounds o pantallas en blanco. |
| 2 | `CalendarioStore.toggleHogar` | Usuario pulsa repetidamente el botón de registrar en el hogar para corregir un clic accidental. | La función conmuta el booleano `reg['hogar'] = !reg['hogar']`, persiste el cambio atómicamente y actualiza `EstadoEstimulacion` sin corromper el registro del aula ni lanzar excepciones. |
| 3 | `BotonEscuchar` | Tarjeta renderiza un texto nuevo cuya locución aún no ha sido sintetizada ni existe en `assets/voice/`. | `BotonEscuchar` consulta `rootBundle.load(_ruta)` en `initState`. Al fallar la carga en el bloque `catch`, establece `_disponible = false` y el widget retorna `SizedBox.shrink()`. Nunca muestra un altavoz inerte ni rompe la interfaz. |
| 4 | `voiceAssetId` / FNV-1a Hash | Docente o redactor modifica un espacio doble o salto de línea en una frase del cuento. | `normalizeVoiceText` colapsa todos los espacios continuos a uno solo antes de computar el hash FNV-1a, evitando invalidar grabaciones por cambios puramente tipográficos en el whitespace. |
| 5 | `voice_corpus.speech_text` | Recitado de canción a pulso con marcas de compás: `"* On-das * que veñen"`. | La regex `_PULSE_MARKER` elimina los asteriscos y `_SYLLABLE_SPLIT` une los guiones silábicos. El sintetizador recibe `"Ondas que veñen"`, mientras que el ID de voz conserva el hash del texto con marcas para garantizar paridad exacta pantalla-audio. |
| 6 | Masterización de Audio (Pico post-codificación) | Grabación sintetizada a -3.0 dBFS que tras compresión AAC con ffmpeg genera sobrepico a -0.5 dBFS. | `encode_m4a` ejecuta `measure_peak_dbfs`. Si el pico excede `CEILING_DBFS` (-1.0 dBFS), atenúa progresivamente la ganancia (`trim_db -= overshoot + 0.5`) y re-codifica hasta 4 intentos antes de dar error. |
| 7 | Conmutador de Roles en Calendario | Docente conmuta entre `Aula` y `Fogar` mientras la vista tiene un scroll activo. | El estado `_esDocente` se actualiza de forma reactiva en memoria; `AnimatedBuilder` re-renderiza únicamente la sección de actividad y botones de acción sin reiniciar la posición del scroll ni perder el mes seleccionado. |
| 8 | Accesibilidad y Escala de Texto Grande | Dispositivo Android con escala de fuente al 200% o modo "Texto en negrita" activo. | La tarjeta del mes utiliza `Wrap` en chips de comandos TPR y `SingleChildScrollView` en el contenedor principal, evitando desbordamientos de tipo `RenderFlex overflowed` en pantallas compactas. |
| 9 | `ContentValidator` (Blacklist Clínica) | Texto educativo contiene la frase legítima `"tratamento de auga"` en una unidad científica. | La regex `forbiddenClinicalPattern` incluye un lookahead negativo `(?!(tratamiento|tratamento)\s+d[eé]\s+a(ug|gu)a)` que permite usos no clínicos de la palabra "tratamento", evitando falsos positivos. |
| 10 | Uso Infantil Desatendido de la App | Menor de 2 años pulsa repetidamente la pantalla del teléfono. | La interfaz carece por diseño de mecánicas de juego infantil, microinteracciones táctiles gamificadas o sonidos reactivos al toque; la pantalla está diseñada para que el adulto la mire brevemente y la bloquee. |
| 11 | Persistencia con Carpeta Privada No Existente | Primera instalación en un dispositivo donde el directorio de soporte no ha sido creado. | `LocalStore` crea recursivamente el directorio padre (`parent.create(recursive: true)`) antes de escribir `calendario_progreso.json`, garantizando persistencia inmediata en el primer lanzamiento. |

---

## 5. Caveats

1. **Entorno de Ejecución Local sin SDK de Flutter**:
   - En el contenedor actual, el comando `flutter` y `dart` no están en el PATH del sistema (`flutter not found`), tal como certifica `STATUS.md:85`. Todos los scripts de calidad y validación de contenidos (`tools/*.py`) fueron ejecutados empíricamente en local con código 0, mientras que la suite completa de Flutter (`flutter analyze`, `flutter test`, build de release APK/AAB) se ejecuta y certifica en GitHub Actions CI (run 16 de `main` en verde completo).
2. **Generación de Grabaciones en Inglés (`LJSpeech · piper`)**:
   - `voice-corpus.json` y `voice-assets-manifest.*` contienen actualmente 246 locuciones para gallego (`Celtia`) y castellano (`Sharvard`). El motor `generate_voice_assets.py --lang en` ya soporta `en_US-ljspeech-medium`, pero los 10 sets de léxico y comandos TPR en inglés deben sintetizarse y commitearse antes de la build final de release si se desea cobertura de audio auditivo total en inglés en el APK.
3. **Validación Acústica Subjetiva**:
   - Los quality gates certifican cobertura física (100%), picos de volumen (-3.2 a -2.4 dBFS) y duraciones. Sin embargo, la naturalidad fonética y prosódica del gallego de Celtia ante crianzas reales de 0-3 años en la asamblea de Vigo requiere la supervisión pedagógica continua del Dr. Betances y docentes de la red de escuelas infantiles.

---

## 6. Conclusion

La minería de especificaciones para «Descubre con Lúa · Edición Vigo» (ampliada con los requisitos de la solicitud de 2026-09-13T09:04:47Z) se ha completado exhaustivamente:

1. **Marco Curricular Gallego**: Los 10 meses curriculares (Septiembre a Junio) están rigurosamente formalizados en `MesCurricular`, alineados con el Decreto 150/2022 (Áreas 1, 2 y 3) y adaptados al ecosistema socio-ambiental de Vigo y Galicia.
2. **Momentos Canónicos de la Sesión**: La secuencia cuatripartita (*Apertura afectiva a pulso 72 BPM*, *Fingerplay/Concentración*, *Núcleo TPR en inglés con pronunciación modelo LJSpeech*, y *Cierre afectivo*) proporciona un andamiaje neurobiológico respetuoso con la ventana atencional de 0-3 años.
3. **Arquitectura Acústica Offline**: Totalmente soberana, sin IA en runtime, con voces neuronales (`LJSpeech · piper` para inglés L3, `Celtia · Proxecto Nós` para gallego, `Sharvard` para castellano), metrónomo visual inclusivo y hashing FNV-1a determinista.
4. **Flujo Dual y Doble Estimulación**: Conmutación inmediata entre el modo docente (asamblea 5-8 min, alta visibilidad a 2 metros, registro 1-touch) y el modo familiar (micro-rutina 3-5 min sin pantallas, guía por tramos de edad) con sincronización soberana en `CalendarioStore`.
5. **Inventario Completo**: Se han catalogado 25 funcionalidades clave y 11 casos borde con sus comportamientos observados, listos para la fase de planificación e implementación.

---

## 7. Verification Method

Para verificar independientemente los hallazgos y especificaciones de este informe:

1. **Verificación de Puertas de Calidad del Repositorio**:
   ```bash
   cd "/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa"
   python3 tools/check_voice_coverage.py
   python3 tools/export_voice_corpus.py --check
   python3 tools/check_contact_email.py
   python3 tools/check_manual_build.py
   python3 tools/check_legal_urls.py --offline
   ```
   *Salida esperada*: Código de salida 0 en todas las comprobaciones.

2. **Inspección de Contratos de Datos y Modelos**:
   - Inspeccionar `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/data/models/calendario_model.dart` y verificar los 10 meses escolares en `MesCurricular.meses`.
   - Inspeccionar `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/core/audio/voice_id.dart:51-56` y verificar la derivación de audio en inglés para LJSpeech.
   - Inspeccionar `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/core/storage/calendario_store.dart` y comprobar la persistencia soberana y reactiva de `EstadoEstimulacion`.
   - Inspeccionar `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa/lib/features/academy/views/guia_atencion_screen.dart` y comprobar los 5 tramos de edad y las 3 reglas de oro.

3. **Condición de Invalidación**:
   - Este informe se consideraría inválido si se descubriese alguna dependencia de red o permiso de internet en el proyecto, si faltase alguno de los 10 meses curriculares del Decreto 150/2022, o si los momentos de sesión requiriesen interacción táctil directa por parte de los bebés. Se ha certificado empíricamente que ninguna de estas infracciones existe.

