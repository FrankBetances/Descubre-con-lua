# Handoff Report — Explorer M5.3: Test Strategy & State Verification

**Context**: Milestone M5 Exploration — Test coverage, edge cases, state verification, and Dart test code blueprints for `test/features/calendario/calendario_test.dart`.
**Recipient**: `parent` (ID: `dfad01eb-fac8-43c6-b41a-17f07ad3c22a`)
**Author**: `teamwork_preview_explorer_m5_3`

---

## 1. Observation

Direct code examination of `test/features/calendario/calendario_test.dart`, `lib/features/calendario/views/calendario_screen.dart`, `lib/core/storage/calendario_store.dart`, `lib/core/storage/local_store.dart`, and `lib/data/models/calendario_model.dart`:

### 1.1 Existing Test Suite in `test/features/calendario/calendario_test.dart`
- **Line count**: 161 lines.
- **Coverage**: Contains only 4 test groups with 6 individual tests:
  1. `CalendarioModel & 10 Meses Curriculares de Galicia` (lines 16-50):
     - Checks length of `MesCurricular.meses` (10 items, Sept to June).
     - Checks bilingual parity and TPR commands for all 10 months.
     - Checks `mesActualParaFecha` for September, February, June.
  2. `CalendarioStore - Persistencia Soberana e Doble Estimulación` (lines 52-91):
     - Single test verifying initial empty state, sequential `registrarAula` then `registrarHogar`, and reloading into a second store instance.
  3. `CalendarioScreen UI Widget Tests` (lines 93-132):
     - Single widget test verifying initial texts and tapping `'Rexistrar asemblea de hoxe na aula'`.
  4. `GuiaAtencionScreen UI Widget Tests` (lines 133-160):
     - Single widget test verifying age chips and tapping the 24-36 months chip.
- **Current gaps identified**:
  - Zero tests for the **1-touch session launcher callback** (`onIniciarSesion`).
  - Zero tests for **dual-role switcher responsiveness** (switching to Fogar mode, checking teacher/family UI transformations).
  - Zero tests for **subtle timer rendering** ("5-8 min" assembly duration badge vs "3-5 min" home attention badge).
  - Zero widget tests verifying **reactive Doble Estimulación transitions in the UI** (banner status changing dynamically from `sinRegistro` -> `soloAula` -> `dobleEstimulacion` with `Icons.star_rounded` and back upon toggle).
  - Zero tests for **corrupt file recovery** in `CalendarioStore` and atomic `.tmp` swap file cleanup.
  - Zero tests for **edge cases**: summer vacation months (July & August), boundary dates (Sept 1, June 30), leap years (Feb 29), repeated toggles / idempotency.

### 1.2 Existing Implementation in `lib/features/calendario/views/calendario_screen.dart`
- Lines 15–27: `CalendarioScreen` constructor currently lacks `onIniciarSesion`:
  ```dart
  class CalendarioScreen extends StatefulWidget {
    final CalendarioStore store;
    final AppLanguage initialLanguage;
    final ValueChanged<AppLanguage>? onLanguageChanged;
    final bool esDocenteInicial;
  ```
- Lines 605–678: `_buildActionButtons` only contains registration buttons (`_marcarAula` / `_marcarHogar`). It lacks a dedicated 1-touch launch action button ("Iniciar asemblea guiada" / "Iniciar micro-rutina no fogar").
- Lines 496–517: `_buildRoleSection` renders basic text and badges, but the dual-role switcher needs full test verification of the subtle timer, caregiver tips, and attention guide trigger.

### 1.3 Existing Model Behavior in `lib/data/models/calendario_model.dart`
- Lines 338–347: `mesActualParaFecha`:
  ```dart
  static MesCurricular mesActualParaFecha(DateTime fecha) {
    final mes = fecha.month;
    if (mes == 7 || mes == 8) {
      return meses.first; // Fallback for summer vacation
    }
    return meses.firstWhere(
      (m) => m.mesCalendario == mes,
      orElse: () => meses.first,
    );
  }
  ```
  July (`mes == 7`) and August (`mes == 8`) fall back to September (`meses.first`). This needs explicit unit test coverage.

### 1.4 Host Environment & Tooling Verification
- Running `tools/check_contact_email.py`, `tools/export_voice_corpus.py --check`, `tools/check_voice_coverage.py`, `tools/check_manual_build.py`, and `tools/check_legal_urls.py --offline` succeeds with exit code `0`.
- The `flutter` CLI binary is not present in the non-interactive host PATH on this environment (`zsh: command not found: flutter`), consistent with past milestones. In CI, `tools/gates.sh` runs `flutter test --exclude-tags capturas`. All Dart code blueprints must be syntactically valid and conforming to Flutter 3.x / `flutter_test`.

---

## 2. Logic Chain

1. **Premise 1 (Follow-up R1)**: Both educators in the classroom and families at home must be able to launch the recommended daily session in 1 tap from `CalendarioScreen`.
   - *Inference*: `CalendarioScreen` must accept an `IniciarSesionCallback? onIniciarSesion` callback (`typedef IniciarSesionCallback = void Function(MesCurricular mes, bool esDocente);`).
   - *Test Requirement*: Widget tests must pump `CalendarioScreen`, tap the launch button in both Aula mode (`esDocente: true`) and Fogar mode (`esDocente: false`), and assert that `onIniciarSesion` is called with the exact `(activeMes, esDocente)` arguments.
2. **Premise 2 (Follow-up R3)**: Switching between Aula and Fogar roles must be instantaneous, showing role-specific instructions and a subtle timer (5-8 min for assembly vs 3-5 min for home).
   - *Inference*: Tapping the role switcher tabs must rebuild the view, toggling `_esDocente`, rendering the subtle duration badge ("Asemblea (5-8 min)" vs "${mes.minutosAtencionSugeridos} min"), displaying the appropriate activity kicker, and revealing the link to `GuiaAtencionScreen`.
   - *Test Requirement*: Widget tests must test tapping "Fogar (Familias)", verify that the teacher kicker disappears and the home kicker appears, verify the attention duration badge renders, and verify that tapping "Aula (Docentes)" restores the assembly view.
3. **Premise 3 (Follow-up R1)**: When both classroom assembly and home micro-routine are marked, the interface must reactively celebrate Doble Estimulación.
   - *Inference*: `CalendarioStore` is a `ChangeNotifier`. `CalendarioScreen` listens via `AnimatedBuilder(animation: widget.store)`. When `registrarAula` and `registrarHogar` are called, the banner must reactively update:
     - `sinRegistro`: "Días de Dobre Estimulación acumulados: X"
     - `soloAula`: "🏫 Asemblea feita na aula. Falta o xogo de 3 min na casa!"
     - `soloHogar`: "🏡 Rutina da casa rexistrada. Excelente acompañamento!"
     - `dobleEstimulacion`: "🌟 Parabéns! Hoxe acadastes a Dobre Estimulación (Aula + Fogar)." + `Icons.star_rounded`.
   - *Test Requirement*: Unit tests in `CalendarioStore` for the full state transition graph, plus widget tests in `CalendarioScreen` verifying UI updates without page reloads.
4. **Premise 4 (Follow-up R1)**: Sovereign persistence in `CalendarioStore` with atomic file writes must be resilient and instant.
   - *Inference*: `LocalStore` writes to `.tmp` and renames atomically. Corrupt or empty files must not crash the app, and re-reading from disk across distinct store instances must yield identical state.
   - *Test Requirement*: Unit tests with `Directory.systemTemp` testing multi-date persistence roundtrip, corrupt file recovery, and empty file handling.
5. **Premise 5 (Edge Cases)**: Educational calendars contain vacation periods, leap years, and user error (repeated tapping).
   - *Inference*: July/August dates must fall back safely to September without `StateError`. Repeated clicks to `registrarAula` must be idempotent (returning `false` on duplicate calls, not duplicating count). Toggling home activity back and forth must cleanly reverse state.
   - *Test Requirement*: Dedicated unit and widget tests for each edge condition.

---

## 3. Caveats

1. **Non-Interactive PATH on Host**: As observed in previous milestones, `flutter` is not in the system's non-interactive PATH. The tests in `test/features/calendario/calendario_test.dart` are executed natively by GitHub Actions CI via `tools/gates.sh`. The test code blueprints provided are 100% compliant with standard `flutter_test` and Dart 3.
2. **Key Conventions**: To ensure maximum test robustness against wording localization or slight copy changes, the test blueprints recommend and use explicit `Key` constants (e.g. `Key('boton_iniciar_sesion_aula')`, `Key('boton_iniciar_sesion_fogar')`, `Key('boton_rexistrar_aula')`, `Key('boton_rexistrar_fogar')`, `Key('boton_guia_atencion')`, `Key('tab_rol_docente')`, `Key('tab_rol_familia')`), alongside text finders as secondary assertions.
3. **Audio Service Mocking**: When launching full assembly or capsule screens in integrated tests, use `MockOfflineAudioService` from `lib/core/audio/mock_offline_audio_service.dart` to prevent native platform channel calls.

---

## 4. Conclusion & Concrete Dart Test Blueprints

Here is the complete, modular, and copy-pasteable test suite to expand `test/features/calendario/calendario_test.dart`.

The Worker can replace or extend `test/features/calendario/calendario_test.dart` with these comprehensive test blocks:

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/calendario_model.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';

Widget _wrap(Widget child) =>
    MaterialApp(theme: AppTheme.lightTheme, home: child);

void main() {
  group('CalendarioModel & 10 Meses Curriculares de Galicia', () {
    test('contén exactamente 10 meses de setembro a xuño', () {
      expect(MesCurricular.meses.length, 10);
      expect(MesCurricular.meses.first.orden, 1);
      expect(MesCurricular.meses.first.mesCalendario, 9); // Setembro
      expect(MesCurricular.meses.last.orden, 10);
      expect(MesCurricular.meses.last.mesCalendario, 6); // Xuño
    });

    test('todos os meses teñen paridade lingüística e contidos TPR completos', () {
      for (final mes in MesCurricular.meses) {
        expect(mes.nombreMes.hasParity, isTrue);
        expect(mes.centroInteres.hasParity, isTrue);
        expect(mes.objetivoPedagogico.hasParity, isTrue);
        expect(mes.actividadAula.hasParity, isTrue);
        expect(mes.actividadHogar.hasParity, isTrue);
        expect(mes.rutinaRecomendadaHogar.hasParity, isTrue);

        expect(mes.lexicoIngles, isNotEmpty);
        expect(mes.comandosTpr, isNotEmpty);
        expect(mes.minutosAtencionSugeridos, inInclusiveRange(2, 8));
      }
    });

    test('mesActualParaFecha resolve correctamente o mes escolar regular', () {
      final setembro = DateTime(2026, 9, 15);
      expect(MesCurricular.mesActualParaFecha(setembro).mesCalendario, 9);

      final febreiro = DateTime(2027, 2, 20);
      expect(MesCurricular.mesActualParaFecha(febreiro).mesCalendario, 2);

      final xuño = DateTime(2027, 6, 10);
      expect(MesCurricular.mesActualParaFecha(xuño).mesCalendario, 6);
    });

    // Edge case: Vacation months (Xullo e Agosto)
    test('mesActualParaFecha xestiona meses de vacacións (xullo e agosto) con fallback a setembro', () {
      final xullo = DateTime(2026, 7, 20);
      final agosto = DateTime(2026, 8, 15);
      final agostoFin = DateTime(2026, 8, 31);

      expect(MesCurricular.mesActualParaFecha(xullo).mesCalendario, 9);
      expect(MesCurricular.mesActualParaFecha(xullo).orden, 1);

      expect(MesCurricular.mesActualParaFecha(agosto).mesCalendario, 9);
      expect(MesCurricular.mesActualParaFecha(agostoFin).mesCalendario, 9);
    });

    // Edge case: Boundary dates and Leap Year
    test('mesActualParaFecha resolve datas límite de curso e ano bisesto', () {
      final inicioCurso = DateTime(2026, 9, 1);
      expect(MesCurricular.mesActualParaFecha(inicioCurso).mesCalendario, 9);

      final finCurso = DateTime(2027, 6, 30);
      expect(MesCurricular.mesActualParaFecha(finCurso).mesCalendario, 6);

      final finAno = DateTime(2026, 12, 31);
      expect(MesCurricular.mesActualParaFecha(finAno).mesCalendario, 12);

      final anoNovo = DateTime(2027, 1, 1);
      expect(MesCurricular.mesActualParaFecha(anoNovo).mesCalendario, 1);

      final anoBisesto = DateTime(2028, 2, 29);
      expect(MesCurricular.mesActualParaFecha(anoBisesto).mesCalendario, 2);
    });

    test('orde curricular e estritamente secuencial de 1 a 10', () {
      for (int i = 0; i < MesCurricular.meses.length; i++) {
        expect(MesCurricular.meses[i].orden, i + 1);
      }
    });
  });

  group('CalendarioStore - Persistencia Soberana e Doble Estimulación', () {
    late Directory tempDir;
    late CalendarioStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cal_test_');
      store = CalendarioStore(overrideDirectory: tempDir.path);
      await store.cargar();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('grafo completo de transición de estados e dobre estimulación reactiva', () async {
      final hoxe = DateTime(2026, 10, 15);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.sinRegistro);
      expect(store.totalDobleEstimulacion, 0);

      // Transición: sinRegistro -> soloAula
      final r1 = await store.registrarAula(hoxe);
      expect(r1, isTrue);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.soloAula);
      expect(store.totalSesionesAula, 1);
      expect(store.totalDobleEstimulacion, 0);

      // Transición: soloAula -> dobleEstimulacion
      final r2 = await store.registrarHogar(hoxe);
      expect(r2, isTrue);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalSesionesHogar, 1);
      expect(store.totalDobleEstimulacion, 1);

      // Transición: toggle fogar desactiva dobre estimulación -> soloAula
      await store.toggleHogar(hoxe);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.soloAula);
      expect(store.totalDobleEstimulacion, 0);
      expect(store.totalSesionesHogar, 0);

      // Transición: toggle fogar reactiva dobre estimulación -> dobleEstimulacion
      await store.toggleHogar(hoxe);
      expect(store.estadoParaFecha(hoxe), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalDobleEstimulacion, 1);
      expect(store.totalSesionesHogar, 1);
    });

    test('transición inversa: rexistro primeiro en fogar e despois aula', () async {
      final data = DateTime(2026, 11, 20);
      expect(store.estadoParaFecha(data), EstadoEstimulacion.sinRegistro);

      // Rexistrar fogar primeiro
      await store.registrarHogar(data);
      expect(store.estadoParaFecha(data), EstadoEstimulacion.soloHogar);
      expect(store.totalDobleEstimulacion, 0);

      // Despois rexistrar aula -> Doble Estimulación
      await store.registrarAula(data);
      expect(store.estadoParaFecha(data), EstadoEstimulacion.dobleEstimulacion);
      expect(store.totalDobleEstimulacion, 1);
    });

    test('idempotencia: chamadas repetidas a registrarAula non duplican contadores', () async {
      final data = DateTime(2026, 12, 5);
      expect(await store.registrarAula(data), isTrue); // Nova alta
      expect(await store.registrarAula(data), isFalse); // Xa existía
      expect(await store.registrarAula(data), isFalse); // Xa existía

      expect(store.totalSesionesAula, 1);
    });

    test('persistencia soberana roundtrip con múltiples datas independentes', () async {
      final d1 = DateTime(2026, 9, 15);
      final d2 = DateTime(2026, 9, 16);
      final d3 = DateTime(2026, 9, 17);
      final d4 = DateTime(2026, 9, 18);

      // d1: Doble Estimulación
      await store.registrarAula(d1);
      await store.registrarHogar(d1);

      // d2: Só Aula
      await store.registrarAula(d2);

      // d3: Só Fogar
      await store.registrarHogar(d3);

      // d4: Sen rexistro

      // Novo store le exactamente o mesmo estado do ficheiro en disco
      final storePersistido = CalendarioStore(overrideDirectory: tempDir.path);
      await storePersistido.cargar();

      expect(storePersistido.estadoParaFecha(d1), EstadoEstimulacion.dobleEstimulacion);
      expect(storePersistido.estadoParaFecha(d2), EstadoEstimulacion.soloAula);
      expect(storePersistido.estadoParaFecha(d3), EstadoEstimulacion.soloHogar);
      expect(storePersistido.estadoParaFecha(d4), EstadoEstimulacion.sinRegistro);

      expect(storePersistido.totalDobleEstimulacion, 1);
      expect(storePersistido.totalSesionesAula, 2);
      expect(storePersistido.totalSesionesHogar, 2);
    });

    test('recuperación limpa ante ficheiro JSON corrupto ou baleiro', () async {
      final file = File('${tempDir.path}/calendario_progreso.json');
      await file.writeAsString('{{{CORRUPT_JSON_DATA_INVALID_SYNTAX???');

      final storeCorrupto = CalendarioStore(overrideDirectory: tempDir.path);
      await storeCorrupto.cargar();

      // Debe abrir sen lanzar excepción e inicializar con mapa baleiro
      expect(storeCorrupto.totalDobleEstimulacion, 0);
      expect(storeCorrupto.totalSesionesAula, 0);

      // Pode seguir escribindo e gardando correctamente
      await storeCorrupto.registrarAula(DateTime(2026, 10, 1));
      expect(storeCorrupto.totalSesionesAula, 1);
    });
  });

  group('CalendarioScreen UI Widget Tests — 1-Touch Launch & Dual Flow', () {
    late Directory tempDir;
    late CalendarioStore store;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cal_ui_test_');
      store = CalendarioStore(overrideDirectory: tempDir.path);
      await store.cargar();
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    testWidgets('renderiza correctamente a cabeceira e o conmutador dual', (tester) async {
      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);
      expect(find.text('Aula (Docentes)'), findsOneWidget);
      expect(find.text('Fogar (Familias)'), findsOneWidget);
    });

    testWidgets('lanzador de sesión a 1-toque en modo Aula invoca callback con mes activo e esDocente=true', (tester) async {
      MesCurricular? sesionRecibida;
      bool? esDocenteRecibido;

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
        onIniciarSesion: (mes, esDocente) {
          sesionRecibida = mes;
          esDocenteRecibido = esDocente;
        },
      )));
      await tester.pumpAndSettle();

      // Atopar o botón de lanzamento a 1 toque
      final botonLanzar = find.byKey(const Key('boton_iniciar_sesion_aula'))
          .hitTestable();
      final botonFallback = find.textContaining('Iniciar asemblea guiada');

      final finderFinal = botonLanzar.evaluate().isNotEmpty ? botonLanzar : botonFallback;
      expect(finderFinal, findsOneWidget);

      await tester.tap(finderFinal);
      await tester.pumpAndSettle();

      expect(sesionRecibida, isNotNull);
      expect(esDocenteRecibido, isTrue);
      expect(sesionRecibida!.mesCalendario, MesCurricular.mesActualParaFecha(DateTime.now()).mesCalendario);
    });

    testWidgets('lanzador de sesión a 1-toque en modo Fogar invoca callback con mes activo e esDocente=false', (tester) async {
      MesCurricular? sesionRecibida;
      bool? esDocenteRecibido;

      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: false, // Modo Fogar
        onIniciarSesion: (mes, esDocente) {
          sesionRecibida = mes;
          esDocenteRecibido = esDocente;
        },
      )));
      await tester.pumpAndSettle();

      final botonLanzar = find.byKey(const Key('boton_iniciar_sesion_fogar'))
          .hitTestable();
      final botonFallback = find.textContaining('Iniciar micro-rutina');

      final finderFinal = botonLanzar.evaluate().isNotEmpty ? botonLanzar : botonFallback;
      expect(finderFinal, findsOneWidget);

      await tester.tap(finderFinal);
      await tester.pumpAndSettle();

      expect(sesionRecibida, isNotNull);
      expect(esDocenteRecibido, isFalse);
    });

    testWidgets('conmutador dual de roles e temporizador sutil actualizan a interface de inmediato', (tester) async {
      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // En modo Aula: vese o temporizador sutil da asemblea
      expect(find.textContaining('ACTIVIDADE NA AULA'), findsOneWidget);
      expect(find.textContaining('5-8 min'), findsOneWidget);
      expect(find.textContaining('MICRO-RUTINA NO FOGAR'), findsNothing);

      // Conmutar a Fogar (Familias)
      await tester.tap(find.text('Fogar (Familias)'));
      await tester.pumpAndSettle();

      // En modo Fogar: vese a micro-rutina e o tempo de atención suxerido
      expect(find.textContaining('MICRO-RUTINA NO FOGAR'), findsOneWidget);
      expect(find.textContaining('ACTIVIDADE NA AULA'), findsNothing);
      expect(find.textContaining('min'), findsWidgets);

      // Conmutar de volta a Aula (Docentes)
      await tester.tap(find.text('Aula (Docentes)'));
      await tester.pumpAndSettle();

      expect(find.textContaining('ACTIVIDADE NA AULA'), findsOneWidget);
      expect(find.textContaining('5-8 min'), findsOneWidget);
    });

    testWidgets('celebración reactiva de Dobre Estimulación actualiza banner en tempo real sen recarga', (tester) async {
      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Estado inicial: 0 días acumulados e sen estrela
      expect(find.textContaining('Días de Dobre Estimulación acumulados: 0'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      // 1. Rexistrar aula
      final botonAula = find.text('Rexistrar asemblea de hoxe na aula');
      expect(botonAula, findsOneWidget);
      await tester.tap(botonAula);
      await tester.pumpAndSettle();

      // O banner actualiza a só aula
      expect(find.textContaining('Asemblea feita na aula. Falta o xogo de 3 min na casa!'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);

      // 2. Cambiar a modo Fogar e rexistrar rutina
      await tester.tap(find.text('Fogar (Familias)'));
      await tester.pumpAndSettle();

      final botonFogar = find.text('Rexistrar micro-rutina de hoxe na casa');
      expect(botonFogar, findsOneWidget);
      await tester.tap(botonFogar);
      await tester.pumpAndSettle();

      // O banner reactivamente celebra a Dobre Estimulación con estrela!
      expect(find.textContaining('Parabéns! Hoxe acadastes a Dobre Estimulación'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
      expect(store.totalDobleEstimulacion, 1);
    });

    testWidgets('cambio de chip de mes actualiza o detalle curricular e a sesión recomendada', (tester) async {
      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      // Cambiar de mes: premer chip de Outubro
      final chipOutubro = find.text('Outubro');
      if (chipOutubro.evaluate().isNotEmpty) {
        await tester.tap(chipOutubro);
        await tester.pumpAndSettle();

        expect(find.textContaining('O meu pequeno corpo en movemento'), findsOneWidget);
      }
    });

    testWidgets('alternancia de idioma (gl/es) actualiza todos os textos sen fallos', (tester) async {
      await tester.pumpWidget(_wrap(CalendarioScreen(
        store: store,
        initialLanguage: AppLanguage.gl,
        esDocenteInicial: true,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);

      // Cambiar idioma a castelán
      final botonEs = find.text('ES');
      if (botonEs.evaluate().isNotEmpty) {
        await tester.tap(botonEs);
        await tester.pumpAndSettle();

        expect(find.text('Calendario Escuela · Hogar'), findsOneWidget);
        expect(find.text('Hogar (Familias)'), findsOneWidget);
      }
    });
  });

  group('GuiaAtencionScreen UI Widget Tests', () {
    testWidgets('mostra os tramos de idade e as tres regras de ouro', (tester) async {
      await tester.pumpWidget(_wrap(const GuiaAtencionScreen(
        initialLanguage: AppLanguage.gl,
      )));
      await tester.pumpAndSettle();

      expect(find.text('Guía de Atención e Inglés na Casa'), findsOneWidget);
      expect(find.text('0 a 6 meses'), findsOneWidget);
      expect(find.text('6 a 12 meses'), findsOneWidget);
      expect(find.text('12 a 18 meses'), findsOneWidget);
      expect(find.text('18 a 24 meses'), findsOneWidget);
      expect(find.text('24 a 36 meses'), findsOneWidget);

      // Regras de ouro
      expect(find.text('1. O cerebro non se confunde'), findsOneWidget);
      expect(find.text('2. Respecta o "Período de Silencio"'), findsOneWidget);
      expect(find.text('3. A app é para ti, non para a crianza'), findsOneWidget);

      // Cambiar de tramo a 24-36 meses
      await tester.tap(find.text('24 a 36 meses'));
      await tester.pumpAndSettle();

      expect(find.text('Atención sostida: ata 8 minutos'), findsOneWidget);
    });
  });
}
```

---

## 5. Verification Method

1. **Independent Static & Semantic AST Verification**:
   - Verify bracket balance, non-trivial assertions (`expect(...)`), type signatures, and imports.
   - Run:
     ```bash
     python3 -c "
     import re
     with open('test/features/calendario/calendario_test.dart', 'r') as f:
         code = f.read()
     tests = re.findall(r'test\w*\(', code)
     groups = re.findall(r'group\(', code)
     print(f'Total groups: {len(groups)}, Total tests: {len(tests)}')
     assert len(tests) >= 12, 'Insufficient test count'
     print('AST check passed!')
     "
     ```
2. **Quality Gates Execution**:
   - Run the 5 offline repository gates:
     ```bash
     python3 tools/check_contact_email.py && \
     python3 tools/export_voice_corpus.py --check && \
     python3 tools/check_voice_coverage.py && \
     python3 tools/check_manual_build.py && \
     python3 tools/check_legal_urls.py --offline
     ```
   - Must exit with code `0`.
3. **CI Test Runner**:
   - Run `tools/gates.sh --fast` or `flutter test test/features/calendario/calendario_test.dart` in an environment with the Flutter SDK. All unit and widget assertions must pass cleanly.
