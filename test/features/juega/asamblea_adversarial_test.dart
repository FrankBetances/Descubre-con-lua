import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_guiada_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';

void main() {
  late ContentRepository repository;
  late MockOfflineAudioService mockAudioService;
  late Unidad testUnidad0to2;
  late Unidad testUnidad2to3;
  late Unidad testUnidad0to3;

  setUp(() {
    repository = ContentRepository();
    mockAudioService = MockOfflineAudioService();

    testUnidad0to2 = const Unidad(
      id: 'test.mar.01',
      tramoEtario: '0-2',
      orden: 1,
      titulo: LocalizedString(gl: 'Mar de Vigo 0-2', es: 'Mar de Vigo 0-2'),
      subtitulo: LocalizedString(gl: 'Subtítulo 0-2', es: 'Subtítulo 0-2'),
      descripcion: LocalizedString(gl: 'Desc 0-2', es: 'Desc 0-2'),
      portadaAsset: 'assets/images/unidades/test.png',
      cancionPulso: CancionPulso(
        titulo: LocalizedString(gl: 'Canción 1', es: 'Canción 1'),
        letraConPulsos: LocalizedString(gl: '* Un * dous', es: '* Uno * dos'),
        bpm: 72,
        audioAsset: LocalizedString(
          gl: 'assets/audio/mar_pulso_72bpm.wav',
          es: 'assets/audio/mar_pulso_72bpm.wav',
        ),
        consignaDocente: LocalizedString(gl: 'Palmear', es: 'Palmear'),
      ),
      cuento: Cuento(
        titulo: LocalizedString(gl: 'Cuento 1', es: 'Cuento 1'),
        paginas: [
          CuentoPagina(
            orden: 1,
            texto: LocalizedString(gl: 'Páxina 1', es: 'Página 1'),
            imagenAsset: 'assets/images/cuento/p1.png',
            preguntaComprension: LocalizedString(gl: 'Pregunta?', es: '¿Pregunta?'),
          ),
        ],
      ),
      vocabulario: [],
      preguntas: [
        PreguntaNivel(
          nivel: 1,
          enunciado: LocalizedString(gl: 'P1', es: 'P1'),
          respuestaSugerida: LocalizedString(gl: 'R1', es: 'R1'),
          consejoDocente: LocalizedString(gl: 'C1', es: 'C1'),
        ),
        PreguntaNivel(
          nivel: 2,
          enunciado: LocalizedString(gl: 'P2', es: 'P2'),
          respuestaSugerida: LocalizedString(gl: 'R2', es: 'R2'),
          consejoDocente: LocalizedString(gl: 'C2', es: 'C2'),
        ),
        PreguntaNivel(
          nivel: 3,
          enunciado: LocalizedString(gl: 'P3', es: 'P3'),
          respuestaSugerida: LocalizedString(gl: 'R3', es: 'R3'),
          consejoDocente: LocalizedString(gl: 'C3', es: 'C3'),
        ),
      ],
      exploracion: ExploracionSensorial(
        titulo: LocalizedString(gl: 'Exploración', es: 'Exploración'),
        materiales: [LocalizedString(gl: 'Conchas > 5 cm', es: 'Conchas > 5 cm')],
        pasos: [LocalizedString(gl: 'Tocar', es: 'Tocar')],
        avisoSeguridad: LocalizedString(
          gl: 'ATENCIÓN: Pezas de tamaño superior a 4 cm. Supervisión adulta continua.',
          es: 'ATENCIÓN: Piezas de tamaño superior a 4 cm. Supervisión adulta continua.',
        ),
        objetivoSensorial: LocalizedString(gl: 'Tacto', es: 'Tacto'),
      ),
      matematicas: MatematicasTempras(
        concepto: LocalizedString(gl: 'Grande / Pequeno', es: 'Grande / Pequeño'),
        descripcion: LocalizedString(gl: 'Mates', es: 'Mates'),
        accionesSugeridas: [LocalizedString(gl: 'Agrupar', es: 'Agrupar')],
        vocabularioMatematico: LocalizedString(gl: 'Grande', es: 'Grande'),
      ),
      puenteCasa: PonteCasa(
        mensajeFamilias: LocalizedString(gl: 'Mensaxe', es: 'Mensaje'),
        actividadesSugeridas: [LocalizedString(gl: 'Actividade', es: 'Actividad')],
        recomendacionConversacion: LocalizedString(gl: 'Conversa', es: 'Conversación'),
      ),
      curriculo: CurricularReference(
        normativa: 'Decreto 150/2022',
        etapa: 'educacion_infantil',
        ciclo: 'primeiro_ciclo_0_3',
        areas: ['area_2_descubrimento_contorna'],
        criteriosEvaluacion: ['CA2.1'],
      ),
      revision: Revision(
        autor: 'Dr. Frank Betances',
        revisorPedagogico: 'Equipo Vigo',
        fechaRevision: '2026-09-11',
        version: '1.0.0',
        aprobadoParaAula: true,
      ),
    );

    testUnidad2to3 = testUnidad0to2.copyWith(
      id: 'test.monte.01',
      tramoEtario: '2-3',
      orden: 2,
      titulo: const LocalizedString(gl: 'Monte do Castro 2-3', es: 'Monte del Castro 2-3'),
    );

    testUnidad0to3 = testUnidad0to2.copyWith(
      id: 'test.global.01',
      tramoEtario: '0-3',
      orden: 3,
      titulo: const LocalizedString(gl: 'Vigo Global 0-3', es: 'Vigo Global 0-3'),
    );

    repository.addUnidad(testUnidad0to2);
    repository.addUnidad(testUnidad2to3);
    repository.addUnidad(testUnidad0to3);
  });

  group('Adversarial Suite 1: Phase Navigation Stress & Boundaries', () {
    testWidgets('Boundary at Step 1: Previous button disabled (onPressed == null)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsambleaGuiadaScreen(
            unidad: testUnidad0to2,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      expect(find.text('Fase 1 de 6'), findsOneWidget);
      final prevBtn = tester.widget<OutlinedButton>(find.widgetWithText(OutlinedButton, 'Anterior'));
      expect(prevBtn.onPressed, isNull, reason: 'Previous button MUST be disabled on Phase 1');
    });

    testWidgets('Rapid back-and-forth transitions between steps 1..6 maintain bounded state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsambleaGuiadaScreen(
            unidad: testUnidad0to2,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      final nextFinder = find.widgetWithText(ElevatedButton, 'Seguinte');
      final prevFinder = find.widgetWithText(OutlinedButton, 'Anterior');

      // Forward to Phase 4
      for (int i = 0; i < 3; i++) {
        await tester.tap(nextFinder);
        await tester.pumpAndSettle();
      }
      expect(find.text('Fase 4 de 6'), findsOneWidget);

      // Rapid oscillate 3 <-> 4 <-> 3
      for (int i = 0; i < 5; i++) {
        await tester.tap(prevFinder);
        await tester.pumpAndSettle();
        expect(find.text('Fase 3 de 6'), findsOneWidget);

        await tester.tap(nextFinder);
        await tester.pumpAndSettle();
        expect(find.text('Fase 4 de 6'), findsOneWidget);
      }

      // Advance to Phase 6 (boundary)
      await tester.tap(nextFinder); // Phase 5
      await tester.pumpAndSettle();
      expect(find.text('Fase 5 de 6'), findsOneWidget);

      await tester.tap(nextFinder); // Phase 6
      await tester.pumpAndSettle();
      expect(find.text('Fase 6 de 6'), findsOneWidget);

      // Boundary at Step 6: Next is replaced with Finalizar
      expect(find.widgetWithText(ElevatedButton, 'Seguinte'), findsNothing);
      expect(find.widgetWithText(ElevatedButton, 'Finalizar'), findsOneWidget);
    });

    testWidgets('Phase 6 Finalizar stops audio, displays snackbar, and pops navigator', (tester) async {
      bool popped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onPopPage: (route, result) {
              popped = true;
              return route.didPop(result);
            },
            pages: [
              MaterialPage(
                child: AsambleaGuiadaScreen(
                  unidad: testUnidad0to2,
                  audioService: mockAudioService,
                  initialLanguage: AppLanguage.gl,
                ),
              ),
            ],
          ),
        ),
      );

      // Advance to Phase 6
      final nextFinder = find.widgetWithText(ElevatedButton, 'Seguinte');
      for (int i = 0; i < 5; i++) {
        await tester.tap(nextFinder);
        await tester.pumpAndSettle();
      }

      expect(find.text('Fase 6 de 6'), findsOneWidget);
      final finishFinder = find.widgetWithText(ElevatedButton, 'Finalizar');
      expect(finishFinder, findsOneWidget);

      await tester.tap(finishFinder);
      await tester.pumpAndSettle();

      expect(mockAudioService.callLog, contains('stop'));
      expect(mockAudioService.isPlaying, isFalse);
      expect(popped, isTrue);
    });
  });

  group('Adversarial Suite 2: Audio Controller Lifecycle & Auto-Pause', () {
    testWidgets('Audio automatically pauses when moving from Phase 1 to Phase 2', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsambleaGuiadaScreen(
            unidad: testUnidad0to2,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      // Start audio in Phase 1
      final playBtn = find.byIcon(Icons.play_arrow_rounded);
      await tester.tap(playBtn);
      await tester.pump();
      expect(mockAudioService.isPlaying, isTrue);

      // Advance to Phase 2
      final nextFinder = find.widgetWithText(ElevatedButton, 'Seguinte');
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      expect(find.text('Fase 2 de 6'), findsOneWidget);
      expect(mockAudioService.isPlaying, isFalse, reason: 'Audio MUST pause when navigating away from Phase 1');
      expect(mockAudioService.callLog, contains('pause'));

      // Returning to Phase 1 does NOT auto-resume audio
      final prevFinder = find.widgetWithText(OutlinedButton, 'Anterior');
      await tester.tap(prevFinder);
      await tester.pumpAndSettle();

      expect(find.text('Fase 1 de 6'), findsOneWidget);
      expect(mockAudioService.isPlaying, isFalse, reason: 'Audio MUST remain paused when returning to Phase 1');
    });

    testWidgets('Audio stops and caller-injected service is NOT disposed when screen is disposed', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AsambleaGuiadaScreen(
                        unidad: testUnidad0to2,
                        audioService: mockAudioService,
                        initialLanguage: AppLanguage.gl,
                      ),
                    ),
                  );
                },
                child: const Text('Launch'),
              ),
            ),
          ),
        ),
      );

      // Launch screen
      await tester.tap(find.text('Launch'));
      await tester.pumpAndSettle();

      // Start audio
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();
      expect(mockAudioService.isPlaying, isTrue);

      // Pop route (simulating AppBar back or hardware back)
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Service MUST be stopped
      expect(mockAudioService.isPlaying, isFalse);
      expect(mockAudioService.callLog, contains('stop'));

      // Injected service MUST NOT be disposed (usable for next launch)
      expect(() => mockAudioService.playAsset('assets/audio/mar_pulso_72bpm.wav'), returnsNormally);
    });
  });

  group('Adversarial Suite 3: Age Filter Edge Cases in UnidadesListScreen', () {
    testWidgets('Age filter correctly segregates 0-2, 2-3, and includes 0-3 in both', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: repository,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      // Default: 'Todas as idades' shows all 3
      expect(find.text('Mar de Vigo 0-2'), findsOneWidget);
      expect(find.text('Monte do Castro 2-3'), findsOneWidget);
      expect(find.text('Vigo Global 0-3'), findsOneWidget);

      // Select '0-2 anos'
      await tester.tap(find.text('0-2 anos'));
      await tester.pumpAndSettle();

      expect(find.text('Mar de Vigo 0-2'), findsOneWidget);
      expect(find.text('Vigo Global 0-3'), findsOneWidget, reason: '0-3 unit must match 0-2 filter');
      expect(find.text('Monte do Castro 2-3'), findsNothing, reason: '2-3 unit must be excluded in 0-2 filter');

      // Select '2-3 anos'
      await tester.tap(find.text('2-3 anos'));
      await tester.pumpAndSettle();

      expect(find.text('Monte do Castro 2-3'), findsOneWidget);
      expect(find.text('Vigo Global 0-3'), findsOneWidget, reason: '0-3 unit must match 2-3 filter');
      expect(find.text('Mar de Vigo 0-2'), findsNothing, reason: '0-2 unit must be excluded in 2-3 filter');

      // Back to 'Todas as idades'
      await tester.tap(find.text('Todas as idades'));
      await tester.pumpAndSettle();

      expect(find.text('Mar de Vigo 0-2'), findsOneWidget);
      expect(find.text('Monte do Castro 2-3'), findsOneWidget);
      expect(find.text('Vigo Global 0-3'), findsOneWidget);
    });

    testWidgets('Empty repository shows friendly empty state without crash', (tester) async {
      final emptyRepo = ContentRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: emptyRepo,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      expect(find.text('Non se atoparon unidades para este tramo de idade.'), findsOneWidget);
    });
  });

  group('Adversarial Suite 4: Safety Alert Enforcement in Phase 4', () {
    testWidgets('Phase 4 safety alert card is prominent, non-dismissible, and enforces piece size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsambleaGuiadaScreen(
            unidad: testUnidad0to2,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      final nextFinder = find.widgetWithText(ElevatedButton, 'Seguinte');

      // Navigate Phase 1 -> 2 -> 3 -> 4
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();
      await tester.tap(nextFinder);
      await tester.pumpAndSettle();

      expect(find.text('Fase 4 de 6'), findsOneWidget);

      // Verify Safety Alert Banner
      expect(find.text('⚠️ PROTOCOLO DE SEGURIDADE NA AULA'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('Pezas de tamaño superior a 4 cm'), findsWidgets);
      expect(find.textContaining('Supervisión adulta continua'), findsWidgets);

      // Ensure no dismiss / close buttons exist for safety alert
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byType(Dismissible), findsNothing);
    });
  });
}
