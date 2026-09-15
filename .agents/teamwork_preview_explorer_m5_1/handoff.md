# Handoff Report: Milestone M5 — 1-Touch Calendar Launch & Agile Dual Flow Strategy

**Agent**: `teamwork_preview_explorer_m5_1` (Explorer Agent)  
**Parent**: `parent` (`dfad01eb-fac8-43c6-b41a-17f07ad3c22a`)  
**Target Recipient**: `teamwork_preview_worker_m5_1` (Worker Agent)  
**Date & Time**: 2026-09-13T11:18:00Z  
**Project**: «Descubre con Lúa · Edición Vigo» (`com.earlify.descubreconlua`)  
**Workspace Root**: `/Users/frankalbertobetancesreinoso/Documentos locales/Descubre con Lúa`  
**Handoff Type**: Hard (Investigation Complete & Implementation Strategy Ready)

---

## 1. Observation

### 1.1 Existing State in `lib/features/calendario/views/calendario_screen.dart`
- **Class declaration and constructor** (lines 15–28):
  ```dart
  class CalendarioScreen extends StatefulWidget {
    final CalendarioStore store;
    final AppLanguage initialLanguage;
    final ValueChanged<AppLanguage>? onLanguageChanged;
    final bool esDocenteInicial;

    const CalendarioScreen({
      super.key,
      required this.store,
      this.initialLanguage = AppLanguage.gl,
      this.onLanguageChanged,
      this.esDocenteInicial = false,
    });
  ```
- **State and action buttons** (lines 598–678):
  Currently `_buildActionButtons(EstadoEstimulacion estado, ThemeData theme)` provides **only** manual checkbox toggling:
  - If `_esDocente`: button `_marcarAula` calling `await widget.store.registrarAula(hoy);`.
  - If `!_esDocente`: button `_marcarHogar` calling `await widget.store.toggleHogar(hoy);`.
  - **Absence observed**: There is **no 1-touch launch button** to directly open the active pedagogical session (`AsambleaGuiadaScreen` for Aula or `CapsulaDetailScreen` / `GuiaAtencionScreen` for Hogar).
  - **Absence observed**: There is **no `onIniciarSesion` callback** parameter matching the architectural contract defined in `PROJECT.md` line 58 (`typedef IniciarSesionCallback = void Function(MesCurricular mes, bool esDocente);`).
- **Role section** (lines 495–519):
  - In Aula mode: renders `_aulaKicker`, `actividadAula`, and a static text badge `'Asemblea (5-8 min)'`. Lacks a dedicated subtle timer widget and brief teacher cues for zero-screen assembly management.
  - In Fogar mode: renders `_hogarKicker`, `actividadHogar`, suggested moment `rutinaRecomendadaHogar`, and badge `'${mes.minutosAtencionSugeridos} min'`. Lacks direct linkage to `GuiaAtencionScreen` and pedagogical rationale ("por que importa").
- **Reactive Doble Estimulación Card** (lines 183–262):
  Wrapped in `AnimatedBuilder(animation: widget.store, ...)` (lines 140–164). Rebuilds dynamically when `widget.store` changes. Displays status banner with celebratory star (`Icons.star_rounded`) when `estado == EstadoEstimulacion.dobleEstimulacion`.

### 1.2 Existing State in `lib/core/storage/calendario_store.dart`
- Extends `ChangeNotifier` (line 10). Backed by `LocalStore` writing atomically to `filesDir/calendario_progreso.json`.
- Methods:
  - `registrarAula([DateTime? fecha])` (line 78): sets `'aula': true`, notifies listeners, writes atomically.
  - `registrarHogar([DateTime? fecha])` (line 90): sets `'hogar': true`, notifies listeners, writes atomically.
  - `toggleHogar([DateTime? fecha])` (line 102): toggles `'hogar'`, notifies listeners, writes atomically.
  - `estadoParaFecha(DateTime fecha)` (line 63): returns `EstadoEstimulacion` (`sinRegistro`, `soloAula`, `soloHogar`, `dobleEstimulacion`).
  - Getters: `totalDobleEstimulacion` (line 112), `totalSesionesAula` (line 117), `totalSesionesHogar` (line 122).
- Zero network dependencies, zero PII, 100% offline.

### 1.3 Existing State in `lib/features/juega/views/asamblea_guiada_screen.dart`
- Constructor (lines 41–53):
  ```dart
  /// Rexistro do calendario escolar-fogar para a dobre estimulación.
  final CalendarioStore? calendario;

  const AsambleaGuiadaScreen({
    super.key,
    required this.unidad,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
  });
  ```
- Completion hook in `_finalizarAsamblea()` (lines 143–145):
  ```dart
  // Se rexistra a asemblea no calendario escola-fogar para activar a dobre estimulación
  await widget.calendario?.registrarAula();
  ```
  `AsambleaGuiadaScreen` **already auto-registers** the classroom session upon assembly completion if passed `calendario: widget.store`!

### 1.4 Existing State in `lib/features/academy/` and `lib/main.dart`
- In `lib/main.dart`:
  - Line 151: Route `'/calendario'` creates `CalendarioScreen`.
  - Line 161–189: `onGenerateRoute` declares routes `'/academy/capsula'` (accepting `Capsula`) and `'/juega/asamblea'` (accepting `Unidad`).
  - Line 156: Route `'/guia-atencion'` creates `GuiaAtencionScreen`.
- In `lib/features/academy/views/guia_atencion_screen.dart`:
  Presents 5 age brackets (0–6m, 6–12m, 12–18m, 18–24m, 24–36m) and 3 golden neurobiological rules for screen-free home stimulation.

### 1.5 Existing State in `test/features/calendario/calendario_test.dart`
- Contains 4 test groups:
  1. `CalendarioModel & 10 Meses Curriculares de Galicia` (lines 16–50)
  2. `CalendarioStore - Persistencia Soberana e Doble Estimulación` (lines 52–91)
  3. `CalendarioScreen UI Widget Tests` (lines 93–131) — only tests the basic render and old manual registration button.
  4. `GuiaAtencionScreen UI Widget Tests` (lines 133–159)
- **Deficiencies to address**: Currently zero tests for 1-touch launch (`onIniciarSesion`), zero tests for dual context switching with subtle timer validation, and zero tests for reactive Doble Estimulación transitions on the live UI widget.

---

## 2. Logic Chain

1. **Requirement R1 (1-Touch Calendar Launch & Auto-Sync)**:
   - Users viewing `CalendarioScreen` need to launch the active session in a single tap without navigating through intermediate lists.
   - For teachers (Aula mode), the 1-touch action must launch `AsambleaGuiadaScreen` for the active month's thematic unit, passing `calendario: widget.store` so that finishing the assembly automatically marks classroom attendance.
   - For families (Fogar mode), the 1-touch action must launch either `CapsulaDetailScreen` (for the active month's capsule) or `GuiaAtencionScreen` (micro-routine guide).
   - Providing `final IniciarSesionCallback? onIniciarSesion` in `CalendarioScreen` satisfies both decoupled testing (callback assertion) and standard route navigation (fallback).

2. **Requirement R3 (Agile Dual Flow & Subtle Timer)**:
   - Early childhood educators need adult-oriented cues that do not distract toddlers in the morning circle:
     - Brief instruction pill: circle on rug, 72 BPM steady pulse, zero child screen interaction.
     - Subtle timer widget: a calm, non-blinking visual pill showing the recommended duration (`5-8 min`) with an hourglass/timer icon (`Icons.timer_outlined`).
   - Families need clarity without cognitive overload:
     - Clear duration badge (`3-5 min sen pantallas`).
     - "Por que importa" pedagogical rationale.
     - Direct button to open `GuiaAtencionScreen`.

3. **Reactivity & Sovereign Persistence**:
   - `CalendarioStore` is already a `ChangeNotifier` with atomic disk writes.
   - Wrapping `CalendarioScreen`'s content in `AnimatedBuilder(animation: widget.store, ...)` ensures that when `registrarAula()` or `registrarHogar()` completes, the UI re-renders immediately, transitioning to `EstadoEstimulacion.dobleEstimulacion` and displaying the celebratory card with `Icons.star_rounded`.

---

## 3. Concrete Implementation Strategy for the Worker

### Step 1: Create Dedicated Widgets in `lib/features/calendario/widgets/`

#### 1.1 `lib/features/calendario/widgets/temporizador_sutil_widget.dart`
Create a clean, elegant subtle timer / duration badge widget:
```dart
import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';

/// Temporizador sutil e distintivo de duración de sesión (asamblea ou micro-rutina).
///
/// Deseñado especificamente para educación infantil: tipografía sobria para o adulto,
/// cero animacións distractivas ou parpadeos que atraian a atención das crianzas.
class TemporizadorSutilWidget extends StatelessWidget {
  final int minutosMin;
  final int minutosMax;
  final bool esDocente;
  final AppLanguage language;

  const TemporizadorSutilWidget({
    super.key,
    required this.minutosMin,
    required this.minutosMax,
    this.esDocente = true,
    this.language = AppLanguage.gl,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final badgeColor = esDocente ? AppTheme.primaryDark : const Color(0xFFD97706);
    final bgColor = esDocente ? AppTheme.primaryLight : const Color(0xFFFFF4E5);

    final duracionTexto = minutosMin == minutosMax
        ? '$minutosMax min'
        : '$minutosMin-$minutosMax min';

    final subtitulo = esDocente
        ? (isGl ? 'Ritmo respectuoso · Móbil fóra da vista' : 'Ritmo respetuoso · Móvil fuera de la vista')
        : (isGl ? 'Micro-rutina · Cero pantallas' : 'Micro-rutina · Cero pantallas');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 20, color: badgeColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${isGl ? "Temporizador sutil" : "Temporizador sutil"}: $duracionTexto',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
              Text(
                subtitulo,
                style: TextStyle(
                  fontSize: 11,
                  color: badgeColor.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### 1.2 `lib/features/calendario/widgets/boton_lanzar_sesion.dart`
Create the 1-touch launcher button widget:
```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Botón principal de lanzamento a 1 toque da sesión recomendada.
class BotonLanzarSesion extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const BotonLanzarSesion({
    super.key,
    required this.label,
    this.icon = Icons.play_circle_filled_rounded,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
      ),
    );
  }
}
```

---

### Step 2: Exact Modifications in `lib/features/calendario/views/calendario_screen.dart`

1. **Add Callback Typedef and Imports**:
   ```dart
   import '../../../data/repositories/content_repository.dart';
   import '../../../core/audio/offline_audio_service.dart';
   import '../../premios/premios_repository.dart';
   import '../../juega/views/asamblea_guiada_screen.dart';
   import '../../academy/views/capsula_detail_screen.dart';
   import '../../academy/views/guia_atencion_screen.dart';
   import '../widgets/temporizador_sutil_widget.dart';
   import '../widgets/boton_lanzar_sesion.dart';

   /// Contrato de callback para o lanzamento a un toque da sesión
   typedef IniciarSesionCallback = void Function(MesCurricular mes, bool esDocente);
   ```

2. **Update Constructor**:
   ```dart
   class CalendarioScreen extends StatefulWidget {
     final CalendarioStore store;
     final AppLanguage initialLanguage;
     final ValueChanged<AppLanguage>? onLanguageChanged;
     final bool esDocenteInicial;
     final IniciarSesionCallback? onIniciarSesion;
     final ContentRepository? repository;
     final OfflineAudioService? audioService;
     final PremiosRepository? premios;

     const CalendarioScreen({
       super.key,
       required this.store,
       this.initialLanguage = AppLanguage.gl,
       this.onLanguageChanged,
       this.esDocenteInicial = false,
       this.onIniciarSesion,
       this.repository,
       this.audioService,
       this.premios,
     });
   ```

3. **Add Localized Strings in `_CalendarioScreenState`**:
   ```dart
   static const _iniciarAula = LocalizedString(
     gl: 'Iniciar asemblea guiada',
     es: 'Iniciar asamblea guiada',
   );

   static const _iniciarHogar = LocalizedString(
     gl: 'Iniciar micro-rutina no fogar',
     es: 'Iniciar micro-rutina en el hogar',
   );

   static const _instruccionsBrevesTitulo = LocalizedString(
     gl: 'Instrucións breves para a asemblea:',
     es: 'Instrucciones breves para la asamblea:',
   );

   static const _instruccionsBrevesCuerpo = LocalizedString(
     gl: 'Círculo na alfombra · Móbil só para a docente · Pulso a 72 BPM e xogo sensoriomotriz.',
     es: 'Círculo en la alfombra · Móvil solo para la docente · Pulso a 72 BPM y juego sensoriomotriz.',
   );

   static const _porQueImportaTitulo = LocalizedString(
     gl: 'Por que importa no desenvolvemento:',
     es: 'Por qué importa en el desarrollo:',
   );

   static const _guiaAtencionBoton = LocalizedString(
     gl: 'Ver Guía de Atención e 3 Regras de Ouro',
     es: 'Ver Guía de Atención y 3 Reglas de Oro',
   );
   ```

4. **Implement Navigation Method `_lanzarSesion`**:
   ```dart
   void _lanzarSesion(MesCurricular mes, bool esDocente) {
     if (widget.onIniciarSesion != null) {
       widget.onIniciarSesion!(mes, esDocente);
       return;
     }

     if (esDocente) {
       final unidad = widget.repository?.getAllUnidades().firstOrNull;
       if (unidad != null) {
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => AsambleaGuiadaScreen(
               unidad: unidad,
               calendario: widget.store,
               audioService: widget.audioService,
               premios: widget.premios,
               initialLanguage: _language,
               onLanguageChanged: _onToggleLanguage,
             ),
           ),
         );
       } else {
         Navigator.of(context).pushNamed('/juega');
       }
     } else {
       final capsula = widget.repository?.getAllCapsulas().firstOrNull;
       if (capsula != null) {
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => CapsulaDetailScreen(
               capsula: capsula,
               premios: widget.premios,
               audioService: widget.audioService,
               initialLanguage: _language,
               onLanguageChanged: _onToggleLanguage,
             ),
           ),
         );
       } else {
         Navigator.of(context).push(
           MaterialPageRoute(
             builder: (context) => GuiaAtencionScreen(
               initialLanguage: _language,
               onLanguageChanged: _onToggleLanguage,
             ),
           ),
         );
       }
     }
   }
   ```

5. **Enhance Role Section (`_buildMonthDetailCard`)**:
   In `_buildMonthDetailCard`:
   - In Aula perspective:
     - Render `TemporizadorSutilWidget(minutosMin: 5, minutosMax: 8, esDocente: true, language: _language)`.
     - Render brief teacher instructions banner (`_instruccionsBrevesTitulo` and `_instruccionsBrevesCuerpo`).
   - In Fogar perspective:
     - Render `TemporizadorSutilWidget(minutosMin: 3, minutosMax: mes.minutosAtencionSugeridos, esDocente: false, language: _language)`.
     - Render "Por que importa" explanation based on `mes.objetivoPedagogico`.
     - Render action button to open `GuiaAtencionScreen`.

6. **Revamp `_buildActionButtons` for 1-Touch Flow**:
   Replace the solitary toggle button with a 2-tier action block:
   - **Primary Action**: `BotonLanzarSesion`
     - Aula: `label: _iniciarAula.resolve(_language)`, `backgroundColor: AppTheme.primary`, `onPressed: () => _lanzarSesion(mes, true)`.
     - Fogar: `label: _iniciarHogar.resolve(_language)`, `backgroundColor: const Color(0xFFD97706)`, `onPressed: () => _lanzarSesion(mes, false)`.
   - **Secondary Action**: `OutlinedButton.icon` for manual registration/undo.

---

### Step 3: Integrate with `lib/main.dart` and Calling Screens
- Update `lib/main.dart`:
  In `/calendario` route and in `HomeScreen._buildCard`, pass `repository: _repository`, `audioService: _audioService`, `premios: _premios`.
- In `lib/features/juega/views/unidades_list_screen.dart` and `lib/features/academy/views/bloques_list_screen.dart`:
  Pass `repository: widget.repository`, `audioService: widget.audioService`, `premios: widget.premios`.

---

### Step 4: Unit & Widget Test Cases in `test/features/calendario/calendario_test.dart`

Add 4 new comprehensive test groups covering Milestone M5:

1. **Group: `CalendarioScreen 1-Touch Session Launcher & Callbacks`**:
   - `testWidgets('lanzamento a 1 toque en modo Aula dispara callback con mes actual e esDocente=true')`:
     - Renders `CalendarioScreen` with `esDocenteInicial: true` and `onIniciarSesion: (mes, docente) { calledMes = mes; calledDocente = docente; }`.
     - Finds `find.text('Iniciar asemblea guiada')`.
     - Taps the button.
     - Asserts `calledDocente == true` and `calledMes != null`.
   - `testWidgets('lanzamento a 1 toque en modo Fogar dispara callback con mes actual e esDocente=false')`:
     - Renders `CalendarioScreen` with `esDocenteInicial: false` and `onIniciarSesion: (mes, docente) { calledMes = mes; calledDocente = docente; }`.
     - Finds `find.text('Iniciar micro-rutina no fogar')`.
     - Taps the button.
     - Asserts `calledDocente == false` and `calledMes != null`.

2. **Group: `CalendarioScreen Flujo Dual & Temporizador Sutil`**:
   - `testWidgets('renderiza temporizador sutil de 5-8 min e instrucións breves en modo Aula')`:
     - Renders `CalendarioScreen` in Aula mode.
     - Expects to find `find.textContaining('Temporizador sutil: 5-8 min')`.
     - Expects to find `find.textContaining('Instrucións breves')`.
   - `testWidgets('conmuta a Fogar e renderiza tempo 3-5 min sen pantallas e enlace a Guía de Atención')`:
     - Taps on `find.text('Fogar (Familias)')`.
     - Expects to find `find.textContaining('Temporizador sutil: 3-')`.
     - Expects to find `find.text('Ver Guía de Atención e 3 Regras de Ouro')`.

3. **Group: `CalendarioScreen Reactividade Doble Estimulación en UI`**:
   - `testWidgets('actualiza reactivamente a tarxeta cara a Dobre Estimulación ao rexistrar aula e fogar')`:
     - Mounts `CalendarioScreen(store: store)`.
     - Checks initial state: `find.textContaining('Días de Dobre Estimulación acumulados: 0')`.
     - Executes `await store.registrarAula(DateTime.now())` and pumps.
     - Checks transition to Solo Aula: `find.textContaining('Asemblea feita na aula')`.
     - Executes `await store.registrarHogar(DateTime.now())` and pumps.
     - Checks transition to Doble Estimulación: `find.textContaining('Dobre Estimulación (Aula + Fogar)')` and finds `find.byIcon(Icons.star_rounded)`.

4. **Group: `CalendarioScreen Bilingüismo e Paridade en Lanzador`**:
   - `testWidgets('conmuta idioma a castelán actualizando textos do lanzador e temporizador')`:
     - Mounts `CalendarioScreen(initialLanguage: AppLanguage.gl)`.
     - Expects `find.text('Iniciar asemblea guiada')`.
     - Toggles language to Spanish (`AppLanguage.es`).
     - Expects `find.text('Iniciar asamblea guiada')`, `find.text('Temporizador sutil: 5-8 min')`.

---

## 4. Caveats

1. **Mocking in Tests**: In widget tests verifying 1-touch launch with `onIniciarSesion`, ensure `tapAfterScrolling` from `test/helpers/scroll_helpers.dart` is used if the button lies below the 800x600 test surface.
2. **Audio Service Safety**: When instantiating `AsambleaGuiadaScreen` or `CapsulaDetailScreen` in fallback routes, make sure `widget.audioService` is passed through so unit tests running without native audio channels do not attempt to invoke platform channels.
3. **No Network Violation**: Ensure zero network imports (`dart:io` sockets, `http`, `dio`, etc.) are introduced.

---

## 5. Conclusion

Milestone M5 is clearly defined and ready for execution by the Worker. The existing architecture (`CalendarioStore`, `AsambleaGuiadaScreen`, `GuiaAtencionScreen`, `ContentRepository`) contains all necessary backing infrastructure. By introducing the `BotonLanzarSesion` and `TemporizadorSutilWidget`, adding `onIniciarSesion` to `CalendarioScreen`, wiring fallback navigation, and augmenting `calendario_test.dart` with the 4 targeted test suites, the Worker will fulfill Requirements R1 and R3 with zero architectural drift and complete test coverage.

---

## 6. Verification Method

To independently verify the Worker's implementation:
1. **Source Code Inspection**:
   - Verify `lib/features/calendario/views/calendario_screen.dart` contains `IniciarSesionCallback` and 1-touch launch button.
   - Verify `lib/features/calendario/widgets/temporizador_sutil_widget.dart` and `boton_lanzar_sesion.dart` exist.
2. **Python Quality Gates**:
   ```bash
   python3 tools/check_contact_email.py
   python3 tools/export_voice_corpus.py --check
   python3 tools/check_voice_coverage.py
   python3 tools/check_manual_build.py
   python3 tools/check_legal_urls.py --offline
   ```
   All 5 gates must pass with exit code `0`.
3. **Test Suite Command**:
   ```bash
   flutter test test/features/calendario/calendario_test.dart
   ```
   Must compile cleanly and pass 100% of all assertions.
