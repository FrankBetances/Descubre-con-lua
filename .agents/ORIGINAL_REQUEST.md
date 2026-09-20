# Original User Request

## Initial Request — 2026-09-11T08:15:28Z

Construir la aplicación nativa Android «Descubre con Lúa · Edición Vigo» en Flutter (Package ID: com.earlify.descubreconlua), adaptando y portando los módulos pedagógicos desde el repositorio el repositorio del proyecto anterior de la casa (Juega con Lúa · aula y Academy · familias) bajo arquitectura estricta de contenido como datos JSON bilingües (gl/es), privacidad verificable en el binario (sin permisos de internet) y audio offline pregenerado.

Working directory: <documentos locales>/Descubre con Lúa
Integrity mode: development

## Requirements

### R1. Estructura Base del Proyecto Flutter (Solo Android) & Privacidad
- Configurar el proyecto Flutter para Android con identificador `com.earlify.descubreconlua`.
- Arquitectura limpia en `lib/`:
  - `lib/core/`: Temas, constantes tipográficas y utilidades de audio local.
  - `lib/data/`: Modelos fuertemente tipados, cargador de assets JSON y repositorio de contenidos.
  - `lib/features/juega/`: Módulo Juega con Lúa · aula orientado a la docente.
  - `lib/features/academy/`: Módulo Academy · familias orientado a padres y madres.
- Privacidad estricta en binario: el manifiesto release (`android/app/src/main/AndroidManifest.xml`) no debe contener `android.permission.INTERNET` ni permisos no esenciales.
- Cero clientes de red, sockets, telemetría o SDKs analíticos en `pubspec.yaml` ni en `lib/`.

### R2. Capa de Contenido como Datos & Validador de Esquemas (Regla 03)
- Modelos Dart para unidades temáticas (`Unidad`, `Vocabulario`, `Actividad`, `Preguntas`, `Exploracion`, `Matematicas`, `PuenteCasa`, `Revision`).
- Modelos Dart para cápsulas de Academy (`Capsula`, `Bloque`, `Afirmacion`, `Revision`).
- Cargador de recursos locales desde `assets/content/**` con soporte bilingüe en paralelo (Gallego `gl` y Castellano `es`).
- Incorporar como datos base en `assets/content/`:
  - `unidades/juega.mar.01.json` (Unidad de exploración marítima de Vigo).
  - `capsulas/academy.como_se_aprende_a_hablar.01.json` (Cápsula familiar de desarrollo comunicativo).
- Validador automatizado con suite de pruebas unitarias que verifique:
  - Paridad estricta 1:1 entre gallego y castellano.
  - Integridad referencial de recursos de audio y referencias curriculares (Decreto 150/2022).
  - Ausencia de terminología clínica o diagnóstica prohibida (enfoque exclusivamente educativo/familiar 0-3 años).

### R3. Portado y Adaptación de Módulos desde el repositorio del proyecto anterior de la casa
- Consultar los componentes homólogos en el repositorio del proyecto anterior de la casa y adaptarlos al diseño docente/familiar:
  - **Academy (Familias)**:
    - Navegación por los 5 bloques de desarrollo.
    - Vista de cápsula con las 4 partes: idea clave, por qué importa, qué hacer en casa y ejemplo cotidiano.
    - Selector dinámico de lengua (`gl` / `es`), tipografía grande de lectura cómoda para adultos, sin enlaces web externos y sin interacción infantil.
  - **Juega con Lúa (Aula / Docentes)**:
    - Selector de unidades filtrable por tramo etario (0-2 años y 2-3 años).
    - Modo asamblea guiado paso a paso para la docente: canción a pulso con reproductor offline de audio local, cuento, preguntas graduadas por nivel, exploración científica con materiales y aviso de seguridad, matemáticas tempranas y puente a casa.
    - Diseño sobrio y funcional para el uso del docente, eliminando deliberadamente animaciones llamativas, efectos visuales distractores o mecánicas de pantalla táctil pensadas para niños.

## Acceptance Criteria

### Verificación de Privacidad y Binario
- [ ] El archivo `AndroidManifest.xml` no incluye `android.permission.INTERNET`.
- [ ] No existen dependencias de red (HTTP, WebSockets, Firebase, analítica) en `pubspec.yaml`.

### Verificación de Contenido y Tests Automatizados
- [ ] Suite de pruebas unitarias (`flutter test test/data/`) valida al 100% los modelos y la carga de los archivos JSON.
- [ ] El validador automatizado certifica la paridad lingüística `gl`/`es` y rechaza archivos incompletos o con términos prohibidos.

### Verificación Funcional de Pantallas (Widget Tests)
- [ ] Widget tests verifican el flujo completo de Academy (listado de bloques, cápsulas y conmutación de idioma).
- [ ] Widget tests verifican el flujo completo de Juega con Lúa (navegación de unidades y modo asamblea guiada para la docente).

## Follow-up — 2026-09-20T14:51:45Z

Migrate all pedagogical content and UI modules from a React/TypeScript prototype (located at `/Users/frankalbertobetancesreinoso/Downloads/descubre-con-lua/`) into the existing Flutter native app. The React source is read-only reference material — no React/web code should be committed. Everything must become Dart + JSON, fully offline, respecting the app's strict zero-network privacy policy.

Working directory: /Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa
Integrity mode: development

Reference source (READ-ONLY): `/Users/frankalbertobetancesreinoso/Downloads/descubre-con-lua/`

## Critical Context

- The app is on Git branch `studio` (already checked out). All work goes to `studio` only. Do NOT touch `main`.
- The app enforces **zero internet permissions** (`AndroidManifest.xml` uses `tools:node="remove"` for INTERNET). This must be preserved.
- Read `CLAUDE.md` in the working directory for project rules R1-R6 (brutal honesty, zero shortcuts, full scope).
- The app uses a 3-layer architecture: `lib/core/`, `lib/data/`, `lib/features/`.
- All text content must be bilingual (Galician `gl` + Spanish `es`) using `LocalizedString` maps.
- Audio playback uses pre-synthesized `.m4a` files in `assets/voice/` — no TTS at runtime.
- The React source uses `window.speechSynthesis` and `SpeechRecognition` (Web APIs) — these have NO Flutter equivalent in offline mode. Replace with guided exercises where the adult evaluates, not the machine.
- Use `git` via `/Library/Developer/CommandLineTools/usr/bin/git` (the Xcode shim at `/usr/bin/git` triggers a license prompt).
- Note: ORIGINAL_REQUEST.md has already been updated with this task.

## Requirements

### R1. Convert all pedagogical data from TypeScript to offline JSON assets

Read the following TypeScript data files from the React source and convert them to well-structured JSON files in `assets/content/`:

| React source file | Target JSON |
|---|---|
| `src/data/banco200CuentosData.ts` (28,243 lines — 200 stories) | `assets/content/cuentos/banco200_cuentos.json` |
| `src/data/banco200LaminasData.ts` (200 illustrated cards) | `assets/content/laminas/banco200_laminas.json` |
| `src/data/banco100CuentosData.ts` (100 extra stories) | `assets/content/cuentos/banco100_cuentos.json` |
| `src/data/historiasProgresivasData.ts` | `assets/content/cuentos/historias_progresivas.json` |
| `src/data/curriculo50Meses.ts` (5 courses × 10 months) | `assets/content/calendario/curriculo_50_meses.json` |
| `src/data/calendarDaysData.ts` (1000 school days) | `assets/content/calendario/calendario_dias.json` |
| `src/data/englishCorpus.ts` | `assets/content/english/english_corpus.json` |
| `src/data/collocationsAndGrammar.ts` | `assets/content/english/collocations_grammar.json` |
| `src/data/phonicsTaxonomyData.ts` (44 English phonemes) | `assets/content/english/phonics_taxonomy.json` |
| `src/data/estrategiasPedagogicasData.ts` | `assets/content/estrategias_pedagogicas.json` |
| `src/data/dinamicasPedagogicasData.ts` | `assets/content/dinamicas_aula.json` |
| `src/data/contentRepository.ts` (BLOQUES_ACADEMY, FASES_ASAMBLEA, SEGUNDO_CICLO_FASES, MESES_CICLO_2, NIVELES_PREMIOS, CAPSULAS, UNIDADES catalog) | Merge into existing JSONs or create new ones as appropriate |
| `src/data/luaArt.ts` | `assets/content/lua_art.json` |
| Root `corpus_8000_palabras.csv` and `corpus_8000_palabras_cefr.csv` | `assets/content/corpus/bnc_coca_8000.json` and `assets/content/corpus/bnc_coca_8000_cefr.json` |
| Root `calendario-3-6-anos.json` | `assets/content/calendario/calendario_3_6_anos.json` |

Also copy the `src/data/bncCoca8000.json` and `src/data/bncCoca8000Cefr.json` files directly since they are already JSON.

Update `pubspec.yaml` to declare all new asset directories.

### R2. Create Dart data models for all new content types

Create immutable Dart model classes in `lib/data/models/` following the existing pattern (see `unidad_model.dart`, `capsula_model.dart` for style reference). Required models:

- `cuento_model.dart` — for the 200-story bank (fields: id, cursoId, mesNumero, semanaSugerida, titulo gl/es, sinopse, paginas[], preguntasGraduadas[], tprOral)
- `lamina_model.dart` — for the 200-card bank
- `corpus_palabra_model.dart` — for the 8,000-word corpus (lemma, pos, banda, nivel_cefr, zipf_score)
- `dia_calendario_dual_model.dart` — for the 1,000-day dual calendar
- `fsrs_card_model.dart` — for the FSRS spaced repetition card state
- `english_corpus_model.dart` — for English vocabulary items
- `phonics_model.dart` — for phonics taxonomy entries
- `estrategia_model.dart` and `dinamica_model.dart`

Extend `lib/data/repositories/content_repository.dart` with methods to load these new JSONs.

### R3. Build Flutter screens for all major pedagogical modules

Create new feature screens in `lib/features/` following the existing architecture:

**Cuentos (Stories)**:
- `lib/features/cuentos/views/cuentos_list_screen.dart` — Gallery of 200 stories filterable by course/month/week
- `lib/features/cuentos/views/cuento_viewer_screen.dart` — Interactive story viewer with page-by-page narration, comprehension questions, vocabulary, and offline audio integration

**Láminas (Illustrated Cards)**:
- `lib/features/laminas/views/laminas_gallery_screen.dart` — Visual gallery with filters
- `lib/features/laminas/views/lamina_detail_screen.dart` — Individual card viewer

**Corpus 8,000 Words**:
- `lib/features/palabras/views/palabras_8000_screen.dart` — Searchable explorer with band/CEFR filters

**English Immersion**:
- `lib/features/english/views/english_hub_screen.dart` — Hub screen with sub-modules
- `lib/features/english/views/fsrs_trainer_screen.dart` — FSRS v4.5 spaced repetition trainer (port `src/utils/fsrsAlgorithm.ts` to Dart)
- `lib/features/english/views/collocations_screen.dart` — Collocations and grammar explorer
- `lib/features/english/views/listening_screen.dart` — Listening comprehension with offline audio

**Lectura / Phonics**:
- `lib/features/lectura/views/aprender_a_ler_screen.dart` — Reading hub
- `lib/features/lectura/views/alphabot_screen.dart` — Manipulative letter table (Alphabot)
- `lib/features/lectura/views/phonix_quest_screen.dart` — Phonics mission engine

**Planificador & Estrategias**:
- `lib/features/planificador/views/planificador_screen.dart` — Curricular planner for 50 months
- `lib/features/planificador/views/estrategias_screen.dart` — Pedagogical strategies catalog
- `lib/features/planificador/views/dinamicas_screen.dart` — Classroom dynamics catalog

### R4. Extend the calendar and integrate Portal Dual navigation

- Refactor `lib/features/calendario/` to support all 5 courses (0-2, 2-3, 3-4, 4-5, 5-6) with a course selector and the dual day-by-day view (aula + fogar)
- Add a `UserProgress` service (`lib/core/progress_service.dart`) with XP, daily logs (aula/fogar), completed capsules/assemblies — persisted via `SharedPreferences`
- Add Portal Dual navigation concept to `lib/main.dart`: a top-level selector (Familias / Docentes) that shows different tab sets for each role
- Port the FSRS algorithm to `lib/core/fsrs_service.dart` (pure Dart, ~172 lines from `src/utils/fsrsAlgorithm.ts`)

### R5. Commit and push to origin/studio

After all changes pass verification:
- Stage all new and modified files
- Commit with message: `feat(studio): migrar innovaciones pedagógicas de Studio AI a Flutter nativo`
- Push to `origin/studio` using `/Library/Developer/CommandLineTools/usr/bin/git push origin studio`
- Do NOT merge into main. Do NOT touch the main branch.
- Verify the push succeeded by checking the remote SHA matches the local HEAD.

## Acceptance Criteria

### Data Conversion
- [ ] All 15+ JSON files listed in R1 exist in `assets/content/` and are valid JSON (parseable without errors)
- [ ] `banco200_cuentos.json` contains exactly 200 story objects, each with `id`, `titulo.gl`, `titulo.es`, `paginas[]` (non-empty)
- [ ] `bnc_coca_8000.json` contains at least 7,500 word entries with `lemma`, `banda_frecuencia` fields
- [ ] `pubspec.yaml` declares all new asset directories and `flutter analyze` produces zero errors
- [ ] Running `flutter test` passes all existing tests (zero regressions)

### Dart Models
- [ ] Each model class in `lib/data/models/` has a `fromJson(Map<String, dynamic>)` factory constructor
- [ ] `ContentRepository` can load every new JSON file successfully (verified by a unit test or by `flutter test`)

### Flutter Screens
- [ ] At least 10 new screen files exist under `lib/features/` covering: cuentos, laminas, palabras, english, lectura, planificador
- [ ] The app compiles without errors: `flutter build apk --debug` exits with code 0
- [ ] `flutter analyze` exits with zero errors and zero warnings

### Privacy & Integrity
- [ ] `AndroidManifest.xml` still contains `tools:node="remove"` for `android.permission.INTERNET`
- [ ] No `import 'dart:io'` with `HttpClient` or `import 'package:http'` anywhere in `lib/`
- [ ] `flutter test test/privacy_manifest_test.dart` passes (if it exists)

### Git & Cloud Sync
- [ ] All changes are committed to branch `studio` (not `main`)
- [ ] `git push origin studio` succeeds and the remote SHA matches local HEAD
- [ ] Branch `main` has zero new commits from this work

## Follow-up — 2026-09-20T15:12:32Z

The reference source has been copied directly into the workspace at `.studio_ref/` (and added to `.gitignore`). All subagents must read reference materials from `.studio_ref/` within the workspace.

