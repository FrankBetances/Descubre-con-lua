import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/backstage_asamblea_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';
import 'package:descubre_con_lua/features/juega/widgets/backstage/backstage_level_switcher.dart';
import 'package:descubre_con_lua/features/juega/widgets/backstage/backstage_phase_stepper.dart';
import 'package:descubre_con_lua/features/juega/widgets/backstage/backstage_phase_timer_widget.dart';

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
        en: 'September: Welcome and Routines (${nivel.clave})',
      ),
      centroInteres: const LocalizedString(
        gl: 'A alfombra da asemblea',
        es: 'La alfombra de la asamblea',
        en: 'The circle rug',
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
            en: 'Opening & Circle Greeting',
          ),
          duracionSegundos: 90,
          consignaDocente: LocalizedString(
            gl: 'Reunir ao grupo na alfombra en círculo. Contacto visual cálido.',
            es: 'Reunir al grupo en la alfombra en círculo. Contacto visual cálido.',
            en: 'Gather the group in circle. Warm eye contact.',
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
            en: 'Movement & Rhythmic Focus',
          ),
          duracionSegundos: 120,
          consignaDocente: LocalizedString(
            gl: 'Marcar o compás suave con palmas a 72 BPM.',
            es: 'Marcar el compás suave con palmas a 72 BPM.',
            en: 'Keep gentle 72 BPM pulse with claps.',
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
            en: 'Core TPR Challenge in L3 (${nivel.clave})',
          ),
          duracionSegundos: 270,
          consignaDocente: const LocalizedString(
            gl: 'Comandos TPR graduados sen esixir produción verbal en L3.',
            es: 'Comandos TPR graduados sin exigir producción verbal en L3.',
            en: 'Graded TPR commands without verbal speech demand.',
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
                en: 'Test physical action',
              ),
              modeladoDocente: const LocalizedString(
                gl: 'Modelado sincrónico polo docente',
                es: 'Modelado sincrónico por el docente',
                en: 'Synchronous modeling by teacher',
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
            en: 'Calm & Transition with Materials',
          ),
          duracionSegundos: 120,
          consignaDocente: LocalizedString(
            gl: 'Respiración diafragmática e manipulación de materiais naturais.',
            es: 'Respiración diafragmática y manipulación de materiales naturales.',
            en: 'Diaphragmatic breathing and sensory exploration.',
          ),
          repertorioMateriales: [
            MaterialNatural(
              id: 'gasa_algodon_test',
              nombre: LocalizedString(
                gl: 'Gasa de algodón orgánico',
                es: 'Gasa de algodón orgánico',
                en: 'Organic Cotton Muslin',
              ),
              procedencia: LocalizedString(
                gl: 'Texido tradicional galego',
                es: 'Tejido tradicional gallego',
                en: 'Traditional Galician fabric',
              ),
              pautaManipulacion: LocalizedString(
                gl: 'Soprar suavemente para sentir o aire.',
                es: 'Soplar suavemente para sentir el aire.',
                en: 'Blow gently to feel the air.',
              ),
              avisoSeguridad: LocalizedString(
                gl: 'Pezas grandes >= 4 cm baixo supervisión.',
                es: 'Piezas grandes >= 4 cm bajo supervisión.',
                en: 'Safe sizes >= 4 cm under supervision.',
              ),
            ),
          ],
        ),
      ],
      curriculo: const CurricularReferenceSegundoCiclo(
        nivel: '4_infantil',
        areas: ['area_1_crecemento_harmonia', 'area_3_comunicacion_representacion'],
        criteriosEvaluacion: ['CA1.1', 'CA3.1'],
      ),
      materialesEntorno: const [],
      microRutinaHogar: const MicroRutinaHogarSegundoCiclo(
        id: 'micro.test.01',
        titulo: LocalizedString(gl: 'The Magic Coat Hook', es: 'The Magic Coat Hook'),
        nichoTiempoMinutos: 3,
        momentoDelDia: LocalizedString(gl: 'Ao chegar da escola', es: 'Al llegar de la escuela'),
        objetivoAutonomia: LocalizedString(gl: 'Colgar o abrigo', es: 'Colgar el abrigo'),
        pautasRecast: [],
        escenaCotidiana: LocalizedString(gl: 'No recibidor', es: 'En el recibidor'),
      ),
      revision: const Revision(
        autor: 'Equipo Pedagóxico',
        fechaRevision: '2026-09-15',
        version: '1.0.0',
        aprobadoParaAula: true,
      ),
    );
  }

  setUp(() {
    repository = ContentRepository();
    mockAudio = MockOfflineAudioService();

    repository.addAsambleaSegundoCiclo(buildFixture(NivelEducativoSegundoCiclo.infantil4));
    repository.addAsambleaSegundoCiclo(buildFixture(NivelEducativoSegundoCiclo.infantil5));
    repository.addAsambleaSegundoCiclo(buildFixture(NivelEducativoSegundoCiclo.infantil6));
  });

  group('BackstageAsambleaScreen Widget Tests', () {
    testWidgets('renders backstage dark theme with level switcher, stepper and timer',
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
      expect(find.byKey(const ValueKey('level_switcher_4_infantil')), findsOneWidget);
      expect(find.byKey(const ValueKey('level_switcher_5_infantil')), findsOneWidget);
      expect(find.byKey(const ValueKey('level_switcher_6_infantil')), findsOneWidget);

      // Verify phase stepper exists with 4 phases
      expect(find.byType(BackstagePhaseStepper), findsOneWidget);
      expect(find.byKey(const ValueKey('stepper_phase_button_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('stepper_phase_button_1')), findsOneWidget);
      expect(find.byKey(const ValueKey('stepper_phase_button_2')), findsOneWidget);
      expect(find.byKey(const ValueKey('stepper_phase_button_3')), findsOneWidget);

      // Verify timer widget exists
      expect(find.byType(BackstagePhaseTimerWidget), findsOneWidget);

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
      await tester.tap(find.byKey(const ValueKey('stepper_phase_button_1')));
      await tester.pumpAndSettle();
      expect(find.text('FASE 2 · 120s'), findsOneWidget);
      expect(find.text('Foco Rítmico e Pulso Constante'), findsOneWidget);
      expect(find.byKey(const ValueKey('play_rhythm_pulse_button')), findsOneWidget);

      // Step to Phase 3: Reto TPR (270s)
      await tester.tap(find.byKey(const ValueKey('stepper_phase_button_2')));
      await tester.pumpAndSettle();
      expect(find.text('FASE 3 · 270s'), findsOneWidget);
      expect(find.text('Stand up and clap hands'), findsOneWidget);
      expect(find.byKey(const ValueKey('play_tpr_audio_cmd.test.01')), findsOneWidget);

      // Step to Phase 4: Calma e Transición (120s)
      await tester.tap(find.byKey(const ValueKey('stepper_phase_button_3')));
      await tester.pumpAndSettle();
      expect(find.text('FASE 4 · 120s'), findsOneWidget);
      expect(find.text('Gasa de algodón orgánico'), findsOneWidget);
      expect(find.text('Pezas grandes >= 4 cm baixo supervisión.'), findsOneWidget);
    });

    testWidgets('switches levels and updates methodology and indicators (freeze & cue cards)',
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
      await tester.tap(find.byKey(const ValueKey('stepper_phase_button_2')));
      await tester.pumpAndSettle();

      // In 4º Infantil: Acción Expandida, no freeze indicator
      expect(find.byKey(const ValueKey('freeze_signal_indicator')), findsNothing);
      expect(find.byKey(const ValueKey('cue_cards_indicator')), findsNothing);

      // Switch to 5º Infantil
      await tester.tap(find.byKey(const ValueKey('level_switcher_5_infantil')));
      await tester.pumpAndSettle();

      // Nav to Phase 3
      await tester.tap(find.byKey(const ValueKey('stepper_phase_button_2')));
      await tester.pumpAndSettle();

      // In 5º Infantil: Freeze indicator must appear!
      expect(find.byKey(const ValueKey('freeze_signal_indicator')), findsOneWidget);
      expect(find.text('The bell rings: run to the circle and freeze!'), findsOneWidget);

      // Switch to 6º Infantil
      await tester.tap(find.byKey(const ValueKey('level_switcher_6_infantil')));
      await tester.pumpAndSettle();

      // Nav to Phase 3
      await tester.tap(find.byKey(const ValueKey('stepper_phase_button_2')));
      await tester.pumpAndSettle();

      // In 6º Infantil: Cue cards indicator must appear!
      expect(find.byKey(const ValueKey('cue_cards_indicator')), findsOneWidget);
      expect(find.text('Walk to the hook and hang your coat'), findsOneWidget);
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
      await tester.tap(find.byKey(const ValueKey('backstage_language_toggle')));
      await tester.pumpAndSettle();

      expect(find.text('ES'), findsOneWidget);
      expect(find.text('Apertura y Saludo en el Círculo'), findsOneWidget);
    });

    testWidgets('shows exit confirmation dialog on back press',
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

      // Verify cycle tabs exist
      expect(find.byKey(const ValueKey('tab_primer_ciclo')), findsOneWidget);
      expect(find.byKey(const ValueKey('tab_segundo_ciclo')), findsOneWidget);

      // Initially on Primer Ciclo (filter chip is visible)
      expect(find.text('Filtrar por tramo etario:'), findsOneWidget);

      // Switch to Segundo Ciclo
      await tester.tap(find.byKey(const ValueKey('tab_segundo_ciclo')));
      await tester.pumpAndSettle();

      // Verify Segundo Ciclo banner and cards are shown
      expect(find.text('Asemblea Matinal do 2.º Ciclo (3-6 anos)'), findsOneWidget);
      expect(find.byKey(const ValueKey('launch_backstage_primary_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('launch_backstage_nivel_4_infantil')), findsOneWidget);
      expect(find.byKey(const ValueKey('launch_backstage_nivel_5_infantil')), findsOneWidget);
      expect(find.byKey(const ValueKey('launch_backstage_nivel_6_infantil')), findsOneWidget);

      // Switch back to Primer Ciclo
      await tester.tap(find.byKey(const ValueKey('tab_primer_ciclo')));
      await tester.pumpAndSettle();

      // 0-3 views are restored
      expect(find.text('Filtrar por tramo etario:'), findsOneWidget);
    });
  });
}
