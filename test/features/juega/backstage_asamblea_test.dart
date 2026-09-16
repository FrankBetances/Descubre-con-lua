import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/backstage_asamblea_screen.dart';
import 'package:descubre_con_lua/features/juega/widgets/backstage/backstage_phase_timer_widget.dart';
import 'package:descubre_con_lua/features/calendario/widgets/calendario_do_curso.dart';
import 'package:descubre_con_lua/features/juega/widgets/fichas_de_unidades.dart';
import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';
import 'package:descubre_con_lua/features/juega/widgets/backstage/backstage_level_switcher.dart';

void main() {
  late ContentRepository repository;
  late MockOfflineAudioService mockAudio;

  AsambleaSegundoCiclo buildFixture(NivelEducativoSegundoCiclo nivel) {
    return AsambleaSegundoCiclo(
      id: 'asamblea.test.${nivel.clave}',
      nivel: nivel,
      mes: 9,
      titulo: LocalizedString(
        gl: 'Setembro: Acollida e Rutinas (${nivel.clave})',
        es: 'Septiembre: Acogida y Rutinas (${nivel.clave})',
      ),
      centroInteres: const LocalizedString(
        gl: 'A alfombra da asemblea',
        es: 'La alfombra de la asamblea',
      ),
      metodologiaTpr: nivel.metodologiaPorDefecto,
      duracionTotalMinutos: 10,
      fases: [
        const FaseAsamblea(
          orden: 1,
          tipo: TipoFaseAsamblea.aperturaSaudo,
          titulo: LocalizedString(
            gl: 'Apertura e Saúdo no Círculo',
            es: 'Apertura y Saludo en el Círculo',
          ),
          duracionSegundos: 90,
          consignaDocente: LocalizedString(
            gl: 'Reunir ao grupo na alfombra en círculo. Contacto visual cálido.',
            es: 'Reunir al grupo en la alfombra en círculo. Contacto visual cálido.',
          ),
          cueAcustica: 'Hello, Lúa!',
          audioAsset: 'assets/audio/hello_lua.mp3',
        ),
        const FaseAsamblea(
          orden: 2,
          tipo: TipoFaseAsamblea.movementRhythmFocus,
          titulo: LocalizedString(
            gl: 'Foco Rítmico e Pulso Constante',
            es: 'Foco Rítmico y Pulso Constante',
          ),
          duracionSegundos: 120,
          consignaDocente: LocalizedString(
            gl: 'Marcar o compás suave con palmas a 72 BPM.',
            es: 'Marcar el compás suave con palmas a 72 BPM.',
          ),
          cueAcustica: 'Pulse 72 BPM',
          audioAsset: 'assets/audio/pulse_72bpm.mp3',
        ),
        FaseAsamblea(
          orden: 3,
          tipo: TipoFaseAsamblea.coreTprChallenge,
          titulo: LocalizedString(
            gl: 'Reto Núcleo TPR en L3 (${nivel.clave})',
            es: 'Reto Núcleo TPR en L3 (${nivel.clave})',
          ),
          duracionSegundos: 270,
          consignaDocente: const LocalizedString(
            gl: 'Comandos TPR graduados sen esixir produción verbal en L3.',
            es: 'Comandos TPR graduados sin exigir producción verbal en L3.',
          ),
          comandosL3: [
            ComandoTPR(
              id: 'cmd.test.01',
              textoIngles: nivel == NivelEducativoSegundoCiclo.infantil5
                  ? 'The bell rings: run to the circle and freeze!'
                  : (nivel == NivelEducativoSegundoCiclo.infantil6
                      ? 'Walk to the hook and hang your coat'
                      : 'Stand up and clap hands'),
              accionFisica: const LocalizedString(
                gl: 'Acción física de proba',
                es: 'Acción física de prueba',
              ),
              modeladoDocente: const LocalizedString(
                gl: 'Modelado sincrónico polo docente',
                es: 'Modelado sincrónico por el docente',
              ),
              audioAsset: 'assets/voice/l3/test_command.m4a',
            ),
          ],
        ),
        const FaseAsamblea(
          orden: 4,
          tipo: TipoFaseAsamblea.calmaTransicion,
          titulo: LocalizedString(
            gl: 'Calma e Transición con Materiais',
            es: 'Calma y Transición con Materiales',
          ),
          duracionSegundos: 120,
          consignaDocente: LocalizedString(
            gl: 'Respiración diafragmática e manipulación de materiais naturais.',
            es: 'Respiración diafragmática y manipulación de materiales naturales.',
          ),
          repertorioMateriales: [
            MaterialNatural(
              id: 'gasa_algodon_test',
              nombre: LocalizedString(
                gl: 'Gasa de algodón orgánico',
                es: 'Gasa de algodón orgánico',
              ),
              procedencia: LocalizedString(
                gl: 'Texido tradicional galego',
                es: 'Tejido tradicional gallego',
              ),
              pautaManipulacion: LocalizedString(
                gl: 'Soprar suavemente para sentir o aire.',
                es: 'Soplar suavemente para sentir el aire.',
              ),
              avisoSeguridad: LocalizedString(
                gl: 'Pezas grandes >= 4 cm baixo supervisión.',
                es: 'Piezas grandes >= 4 cm bajo supervisión.',
              ),
            ),
          ],
        ),
      ],
      curriculo: const CurricularReferenceSegundoCiclo(
        nivel: '4_infantil',
        areas: [
          'area_1_crecemento_harmonia',
          'area_3_comunicacion_representacion'
        ],
        criteriosEvaluacion: ['CA1.1', 'CA3.1'],
      ),
      materialesEntorno: const [],
      microRutinaHogar: const MicroRutinaHogarSegundoCiclo(
        id: 'micro.test.01',
        titulo: LocalizedString(
            gl: 'The Magic Coat Hook', es: 'The Magic Coat Hook'),
        nichoTiempoMinutos: 3,
        momentoDelDia: LocalizedString(
            gl: 'Ao chegar da escola', es: 'Al llegar de la escuela'),
        objetivoAutonomia:
            LocalizedString(gl: 'Colgar o abrigo', es: 'Colgar el abrigo'),
        pautasRecast: [],
        escenaCotidiana:
            LocalizedString(gl: 'No recibidor', es: 'En el recibidor'),
      ),
      revision: const Revision(
        autor: 'Equipo Pedagóxico',
        revisorPedagogico: '',
        fechaRevision: '2026-09-15',
        version: '1.0.0',
        aprobadoParaAula: false,
      ),
    );
  }

  late ContentRepository real;

  setUpAll(() async {
    // O contido REAL do paquete: as unidades e o calendario non están nos
    // fixtures desta suite. Inicialízase AQUÍ e non dentro dun testWidgets:
    // alí o reloxo falso deixa a lectura de assets colgada para sempre.
    real = ContentRepository();
    await real.initialize();
  });

  setUp(() {
    repository = ContentRepository();
    mockAudio = MockOfflineAudioService();

    repository.addAsambleaSegundoCiclo(
        buildFixture(NivelEducativoSegundoCiclo.infantil4));
    repository.addAsambleaSegundoCiclo(
        buildFixture(NivelEducativoSegundoCiclo.infantil5));
    repository.addAsambleaSegundoCiclo(
        buildFixture(NivelEducativoSegundoCiclo.infantil6));
  });

  group('BackstageAsambleaScreen Widget Tests', () {
    testWidgets(
        'renders the light assembly header with level switcher and progress',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repository,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify level switcher exists
      expect(find.byType(BackstageLevelSwitcher), findsOneWidget);
      expect(find.byKey(const ValueKey('level_switcher_4_infantil')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('level_switcher_5_infantil')),
          findsOneWidget);
      expect(find.byKey(const ValueKey('level_switcher_6_infantil')),
          findsOneWidget);

      // Verify phase stepper exists with 4 phases
      expect(find.text('Fase 1 de 4'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);

      // Verify timer widget exists

      // Phase 1 (Apertura) initially displayed
      expect(find.text('FASE 1 · 90s'), findsOneWidget);
      expect(find.text('Apertura e Saúdo no Círculo'), findsOneWidget);
      expect(find.text('«Hello, Lúa!»'), findsOneWidget);
    });

    testWidgets('navigates through all 4 canonical phases via stepper',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repository,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step to Phase 2: Foco Rítmico (120s)
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      expect(find.text('FASE 2 · 120s'), findsOneWidget);
      expect(find.text('Foco Rítmico e Pulso Constante'), findsOneWidget);
      expect(find.byKey(const ValueKey('play_rhythm_pulse_button')),
          findsOneWidget);

      // Step to Phase 3: Reto TPR (270s)
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      expect(find.text('FASE 3 · 270s'), findsOneWidget);
      expect(find.text('Stand up and clap hands'), findsWidgets);
      expect(find.byKey(const ValueKey('play_tpr_audio_cmd.test.01')),
          findsOneWidget);

      // Step to Phase 4: Calma e Transición (120s)
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      expect(find.text('FASE 4 · 120s'), findsOneWidget);
      expect(find.text('Gasa de algodón orgánico'), findsOneWidget);
      expect(find.text('Pezas grandes >= 4 cm baixo supervisión.'),
          findsOneWidget);
    });

    testWidgets(
        'switches levels and updates methodology and indicators (freeze & cue cards)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repository,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to Phase 3
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();

      // In 4º Infantil: Acción Expandida, no freeze indicator
      expect(
          find.byKey(const ValueKey('freeze_signal_indicator')), findsNothing);
      expect(find.byKey(const ValueKey('cue_cards_indicator')), findsNothing);

      // Switch to 5º Infantil
      await tester.tap(find.byKey(const ValueKey('level_switcher_5_infantil')));
      await tester.pumpAndSettle();

      // Nav to Phase 3
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();

      // In 5º Infantil: Freeze indicator must appear!
      expect(find.byKey(const ValueKey('freeze_signal_indicator')),
          findsOneWidget);
      expect(find.text('The bell rings: run to the circle and freeze!'),
          findsWidgets);

      // Switch to 6º Infantil
      await tester.tap(find.byKey(const ValueKey('level_switcher_6_infantil')));
      await tester.pumpAndSettle();

      // Nav to Phase 3
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();

      // In 6º Infantil: Cue cards indicator must appear!
      expect(find.byKey(const ValueKey('cue_cards_indicator')), findsOneWidget);
      expect(find.text('Walk to the hook and hang your coat'), findsWidgets);
    });

    testWidgets('toggles language between GL and ES dynamically',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repository,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GL'), findsOneWidget);
      expect(find.text('Apertura e Saúdo no Círculo'), findsOneWidget);

      // Tap language toggle
      // El conmutador es el mismo de toda la app: dos pastillas, GL y ES.
      await tester.tap(find.text('ES'));
      await tester.pumpAndSettle();

      expect(find.text('ES'), findsOneWidget);
      expect(find.text('Apertura y Saludo en el Círculo'), findsOneWidget);
    });

    testWidgets('shows exit confirmation dialog on back press', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repository,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap back button
      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();

      // Verify dialog is shown
      expect(find.text('Saír da Asemblea?'), findsOneWidget);
      expect(find.text('Continuar Asemblea'), findsOneWidget);
      expect(find.text('Saír'), findsOneWidget);

      // Cancel exit
      await tester.tap(find.text('Continuar Asemblea'));
      await tester.pumpAndSettle();

      // Still on backstage screen
      expect(find.byType(BackstageAsambleaScreen), findsOneWidget);
    });

    testWidgets(
        'navigates with bottom Next and Prev buttons and confirms assembly finish on phase 4',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repository,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initial Phase 1: Prev button is disabled (onPressed null)
      final prevFinder =
          find.byKey(const ValueKey('backstage_prev_phase_button'));
      final nextFinder =
          find.byKey(const ValueKey('backstage_next_phase_button'));

      expect(tester.widget<OutlinedButton>(prevFinder).onPressed, isNull);
      expect(find.text('Seguinte Fase'), findsOneWidget);

      // Advance to Phase 2 with next button
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(find.text('FASE 2 · 120s'), findsOneWidget);
      expect(tester.widget<OutlinedButton>(prevFinder).onPressed, isNotNull);

      // Advance to Phase 3
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(find.text('FASE 3 · 270s'), findsOneWidget);

      // Go back to Phase 2 with prev button
      await tester.tap(prevFinder);
      await tester.pumpAndSettle();
      expect(find.text('FASE 2 · 120s'), findsOneWidget);

      // Advance to Phase 3 again
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(find.text('FASE 3 · 270s'), findsOneWidget);

      // Advance to Phase 4
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      expect(find.text('FASE 4 · 120s'), findsOneWidget);

      // Next button now says "Rematar Asemblea"
      expect(find.text('Rematar Asemblea'), findsOneWidget);

      // Tap finish assembly
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      // Verify dedicated finish dialog appears
      expect(find.text('Rematar Asemblea Matinal?'), findsOneWidget);
      expect(find.text('Rematar e Saír'), findsOneWidget);
      expect(find.text('Continuar na Asemblea'), findsOneWidget);

      // Cancel finish
      await tester.tap(find.text('Continuar na Asemblea'));
      await tester.pumpAndSettle();

      // Still on backstage screen
      expect(find.byType(BackstageAsambleaScreen), findsOneWidget);
    });

    testWidgets(
        'displays Voz docente badge in opening phase when no audio asset is specified',
        (tester) async {
      final fixtureWithoutAudio =
          buildFixture(NivelEducativoSegundoCiclo.infantil4);
      final repoWithoutAudio = ContentRepository();
      // buildFixture has audioAsset in phase 1, replace with one without audioAsset
      final fases = List<FaseAsamblea>.from(fixtureWithoutAudio.fases);
      fases[0] = const FaseAsamblea(
        orden: 1,
        tipo: TipoFaseAsamblea.aperturaSaudo,
        titulo: LocalizedString(gl: 'Apertura', es: 'Apertura'),
        duracionSegundos: 90,
        consignaDocente: LocalizedString(gl: 'Consigna', es: 'Consigna'),
        cueAcustica: 'Hello, Lúa!',
        audioAsset: null,
      );
      final asambleaSinAudio = fixtureWithoutAudio.copyWith(fases: fases);
      repoWithoutAudio.addAsambleaSegundoCiclo(asambleaSinAudio);

      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repoWithoutAudio,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Must show "Voz docente" badge and not the play button
      expect(find.text('Voz docente'), findsOneWidget);
      expect(
          find.byKey(const ValueKey('play_opening_cue_button')), findsNothing);
    });

    testWidgets(
        'displays Voz docente badge in TPR phase when command has no audio asset',
        (tester) async {
      final fixtureWithoutAudio =
          buildFixture(NivelEducativoSegundoCiclo.infantil4);
      final repoWithoutAudio = ContentRepository();
      final fases = List<FaseAsamblea>.from(fixtureWithoutAudio.fases);
      fases[2] = const FaseAsamblea(
        orden: 3,
        tipo: TipoFaseAsamblea.coreTprChallenge,
        titulo: LocalizedString(gl: 'Reto TPR', es: 'Reto TPR'),
        duracionSegundos: 270,
        consignaDocente: LocalizedString(gl: 'Consigna', es: 'Consigna'),
        comandosL3: [
          ComandoTPR(
            id: 'cmd.no_audio.01',
            textoIngles: 'Stand up and stretch',
            accionFisica: LocalizedString(gl: 'Erguerse', es: 'Levantarse'),
            modeladoDocente: LocalizedString(gl: 'Modelado', es: 'Modelado'),
            audioAsset: null,
          ),
        ],
      );
      final asambleaSinAudio = fixtureWithoutAudio.copyWith(fases: fases);
      repoWithoutAudio.addAsambleaSegundoCiclo(asambleaSinAudio);

      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: repoWithoutAudio,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Go to phase 3 (Reto TPR)
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(const ValueKey('backstage_next_phase_button')));
      await tester.pumpAndSettle();

      // Must show "Voz docente" badge and not the play button
      expect(find.text('Voz docente'), findsOneWidget);
      expect(find.byKey(const ValueKey('play_tpr_audio_cmd.no_audio.01')),
          findsNothing);
    });

    testWidgets('timer widget starts, pauses and formats time accurately',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BackstagePhaseTimerWidget(
                duracionSegundos: 90,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially 90s = 01:30
      expect(find.text('01:30'), findsOneWidget);

      // Tap play/pause button to start
      await tester.tap(find.byKey(const ValueKey('timer_play_pause_button')));
      await tester.pump(const Duration(seconds: 2));

      // After 2 seconds, timer should show 01:28
      expect(find.text('01:28'), findsOneWidget);

      // Tap reset button
      await tester.tap(find.byKey(const ValueKey('timer_reset_button')));
      await tester.pumpAndSettle();

      // Back to initial 01:30
      expect(find.text('01:30'), findsOneWidget);
    });

    testWidgets(
        'timer widget formats overtime correctly with plus prefix and amber warning',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: BackstagePhaseTimerWidget(
                duracionSegundos: 2,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('00:02'), findsOneWidget);

      // Start timer and run past 2 seconds
      await tester.tap(find.byKey(const ValueKey('timer_play_pause_button')));
      await tester.pump(const Duration(seconds: 4));

      // Overtime: should display +00:02 with hourglass icon
      expect(find.text('+00:02'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_bottom_rounded), findsOneWidget);
    });

    testWidgets(
        'automatically initializes repository if screen is opened before initialization completes',
        (tester) async {
      // Content repository without pre-added fixtures, initialized via loader mock
      final uninitializedRepo = ContentRepository();
      expect(uninitializedRepo.isInitialized, isFalse);

      await tester.pumpWidget(
        MaterialApp(
          home: BackstageAsambleaScreen(
            repository: uninitializedRepo,
            audioService: mockAudio,
            initialNivel: NivelEducativoSegundoCiclo.infantil4,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      // Wait for async initialization triggered by _loadAsamblea
      await tester.pump();

      // Screen is mounted and has initiated initialization
      expect(find.byType(BackstageAsambleaScreen), findsOneWidget);
    });
  });

  group('UnidadesListScreen Cycle Selector Tests', () {
    testWidgets('toggles between 1.er Ciclo (0-3) and 2.º Ciclo (3-6)',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: repository,
            audioService: mockAudio,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('tab_primer_ciclo')), findsOneWidget);
      expect(find.byKey(const ValueKey('tab_segundo_ciclo')), findsOneWidget);

      // 1.º ciclo: o selector é por TRAMO de idade, e a tarxeta do día está
      // á vista sen desprazar nada.
      expect(find.text('O MEU GRUPO'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('tramo_1c_TramoPrimeiroCiclo.lactantes0a2')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('tab_segundo_ciclo')));
      await tester.pumpAndSettle();

      // 2.º ciclo: o selector é por CLASE, e tamén hai unha soa tarxeta.
      expect(find.text('A MIÑA CLASE'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('clase_2c_4_infantil')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('tarxeta_fluxo_2c')), findsOneWidget);
      expect(find.byKey(const ValueKey('comezar_asemblea_2c')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('tab_primer_ciclo')));
      await tester.pumpAndSettle();
      expect(find.text('O MEU GRUPO'), findsOneWidget);
    });

    testWidgets('o aula ten as tres pezas que se perderan ao refacela',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: real,
            audioService: mockAudio,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Estas tres desapareceron ao refacer o aula, e Frank tivo que dicilo:
      // «quitaste a mascota, o calendario e as imaxes». Este gate está para
      // que non volva pasar.
      //
      // 1. A lámina da tarxeta do día, que está arriba e á vista. Comprόbase
      //    ANTES de baixar: despois xa non está na pantalla.
      expect(find.byType(LaminaEscena), findsWidgets,
          reason: 'A tarxeta do día quedou sen lámina');

      // A lista só constrúe o que se ve, así que hai que baixar ata o resto.
      await tester.dragUntilVisible(
        find.byType(FichasDeUnidades),
        find.byType(Scrollable).first,
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();

      // 2. O calendario do curso, DENTRO do aula.
      expect(find.byType(CalendarioDoCurso), findsOneWidget,
          reason: 'Falta o calendario do curso no aula');
      // 3. As fichas das unidades: dez unidades de contido que quedaran sen
      //    ningunha porta que levase a elas.
      expect(find.byType(FichasDeUnidades), findsOneWidget,
          reason: 'Faltan as fichas das unidades temáticas');
    });

    testWidgets('a tira de meses vai DE LADO, non cara abaixo', (tester) async {
      tester.view.physicalSize = const Size(420, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: real,
            audioService: mockAudio,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // O aula SI se despraza: Frank corrixiuno —«el scroll es permitido y
      // puede ser usado para dejar leer la pantalla»—. O que non pode volver
      // é a lista vertical de todo: o contido vai en tiras que se pasan de
      // lado. Esta é a do mes, que é a que manda no que se ve.
      final tira =
          tester.widget<ListView>(find.byKey(const Key('tira_meses_1c')));
      expect(tira.scrollDirection, Axis.horizontal,
          reason: 'A tira de meses deixou de ir de lado');
    });
  });
}
