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
  late Unidad testUnidad;

  setUp(() {
    repository = ContentRepository();
    mockAudioService = MockOfflineAudioService();

    testUnidad = const Unidad(
      id: 'test.unidad.01',
      tramoEtario: '0-2',
      orden: 1,
      titulo: LocalizedString(
        gl: 'Explorando o Mar de Vigo',
        es: 'Explorando el Mar de Vigo',
      ),
      subtitulo: LocalizedString(
        gl: 'Descubrimento sensorial na ría',
        es: 'Descubrimiento sensorial en la ría',
      ),
      descripcion: LocalizedString(
        gl: 'Proposta sensorial e musical con auga e cunchas.',
        es: 'Propuesta sensorial y musical con agua y conchas.',
      ),
      portadaAsset: 'assets/images/unidades/test.png',
      cancionPulso: CancionPulso(
        titulo: LocalizedString(gl: 'As ondas da ría', es: 'Las olas de la ría'),
        letraConPulsos: LocalizedString(
          gl: '* On-das * que ve-ñen, * on-das * que van',
          es: '* O-las * que vie-nen, * o-las * que van',
        ),
        bpm: 72,
        audioAsset: LocalizedString(
          gl: 'assets/audio/mar_pulso_72bpm.wav',
          es: 'assets/audio/mar_pulso_72bpm.wav',
        ),
        consignaDocente: LocalizedString(
          gl: 'Palmear amodo sobre as pernas.',
          es: 'Palmear despacio sobre las piernas.',
        ),
      ),
      cuento: Cuento(
        titulo: LocalizedString(gl: 'Lúa na praia', es: 'Lúa en la playa'),
        paginas: [
          CuentoPagina(
            orden: 1,
            texto: LocalizedString(
              gl: 'Lúa mira as gaivotas na ría.',
              es: 'Lúa mira las gaviotas en la ría.',
            ),
            imagenAsset: 'assets/images/cuento/p1.png',
            preguntaComprension: LocalizedString(
              gl: 'Onde están as gaivotas?',
              es: '¿Dónde están las gaviotas?',
            ),
          ),
        ],
      ),
      vocabulario: [
        VocabularioItem(
          id: 'voc_01',
          palabra: LocalizedString(gl: 'Auga', es: 'Agua'),
          definicionBreve: LocalizedString(gl: 'Líquido do mar', es: 'Líquido del mar'),
          imagenAsset: 'assets/images/voc/auga.png',
          audioAsset: LocalizedString(gl: 'assets/audio/auga.mp3', es: 'assets/audio/agua.mp3'),
        ),
      ],
      preguntas: [
        PreguntaNivel(
          nivel: 1,
          enunciado: LocalizedString(gl: 'Onde está o barco?', es: '¿Dónde está el barco?'),
          respuestaSugerida: LocalizedString(gl: 'Sinala co dedo', es: 'Señala con el dedo'),
          consejoDocente: LocalizedString(gl: 'Acompañar o xesto', es: 'Acompañar el gesto'),
        ),
        PreguntaNivel(
          nivel: 2,
          enunciado: LocalizedString(gl: 'Que fai a auga?', es: '¿Qué hace el agua?'),
          respuestaSugerida: LocalizedString(gl: 'Chof, chof!', es: '¡Chof, chof!'),
          consejoDocente: LocalizedString(gl: 'Facer onomatopeias', es: 'Hacer onomatopeyas'),
        ),
        PreguntaNivel(
          nivel: 3,
          enunciado: LocalizedString(gl: 'Por que flotan os barcos?', es: '¿Por qué flotan los barcos?'),
          respuestaSugerida: LocalizedString(gl: 'Porque son lixeiros', es: 'Porque son ligeros'),
          consejoDocente: LocalizedString(gl: 'Probar na conca', es: 'Probar en el barreño'),
        ),
      ],
      exploracion: ExploracionSensorial(
        titulo: LocalizedString(gl: 'Xogando coa auga', es: 'Jugando con el agua'),
        materiales: [LocalizedString(gl: 'Conchas grandes', es: 'Conchas grandes')],
        pasos: [LocalizedString(gl: 'Tocar a auga fresca', es: 'Tocar el agua fresca')],
        avisoSeguridad: LocalizedString(
          gl: 'ATENCIÓN: Pezas de tamaño superior a 4 cm. Supervisión adulta continua.',
          es: 'ATENCIÓN: Piezas de tamaño superior a 4 cm. Supervisión adulta continua.',
        ),
        objetivoSensorial: LocalizedString(
          gl: 'Sentir a temperatura e textura da auga.',
          es: 'Sentir la temperatura y textura del agua.',
        ),
      ),
      matematicas: MatematicasTempras(
        concepto: LocalizedString(gl: 'Grande / Pequeno', es: 'Grande / Pequeño'),
        descripcion: LocalizedString(
          gl: 'Comparar conchas de diferentes dimensións.',
          es: 'Comparar conchas de diferentes dimensiones.',
        ),
        accionesSugeridas: [LocalizedString(gl: 'Separar conchas', es: 'Separar conchas')],
        vocabularioMatematico: LocalizedString(
          gl: 'Grande, pequeniño, moitas, poucas',
          es: 'Grande, pequeñito, muchas, pocas',
        ),
      ),
      puenteCasa: PonteCasa(
        mensajeFamilias: LocalizedString(
          gl: 'Hoxe exploramos as ondas da ría.',
          es: 'Hoy exploramos las olas de la ría.',
        ),
        actividadesSugeridas: [LocalizedString(gl: 'Mirar o mar no paseo', es: 'Mirar el mar en el paseo')],
        recomendacionConversacion: LocalizedString(
          gl: 'Falar dos sons dos barcos',
          es: 'Hablar de los sonidos de los barcos',
        ),
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

    repository.addUnidad(testUnidad);
  });

  group('Juega con Lúa Feature Tests', () {
    testWidgets('UnidadesListScreen renders unit card and launches assembly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: UnidadesListScreen(
            repository: repository,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      expect(find.text('Juega con Lúa · Aula'), findsOneWidget);
      expect(find.text('Explorando o Mar de Vigo'), findsOneWidget);
      expect(find.text('Tramo 0-2 anos'), findsOneWidget);
      expect(find.text('Iniciar Asemblea Guiada'), findsOneWidget);
    });

    testWidgets('AsambleaGuiadaScreen navigates through all 6 phases and manages audio', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AsambleaGuiadaScreen(
            unidad: testUnidad,
            audioService: mockAudioService,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      // Phase 1: Cancion a pulso
      expect(find.text('Fase 1 de 6'), findsOneWidget);
      expect(find.text('As ondas da ría'), findsOneWidget);
      expect(find.text('72 BPM'), findsOneWidget);
      expect(mockAudioService.isPlaying, isFalse);

      // Play audio
      final playButton = find.byIcon(Icons.play_arrow_rounded);
      expect(playButton, findsOneWidget);
      await tester.tap(playButton);
      await tester.pump();
      expect(mockAudioService.isPlaying, isTrue);

      // Advance to Phase 2: Cuento guiado
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('Fase 2 de 6'), findsOneWidget);
      expect(find.text('Lúa mira as gaivotas na ría.'), findsOneWidget);

      // Advance to Phase 3: Preguntas
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('Fase 3 de 6'), findsOneWidget);
      expect(find.text('Nivel 1: Sinalar e identificación visual'), findsOneWidget);
      expect(find.text('Nivel 2: Nomear e onomatopeias'), findsOneWidget);
      expect(find.text('Nivel 3: Causa-efecto e experiencia cotiá'), findsOneWidget);

      // Advance to Phase 4: Exploracion sensorial & Safety Alert
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('Fase 4 de 6'), findsOneWidget);
      expect(find.text('⚠️ PROTOCOLO DE SEGURIDADE NA AULA'), findsOneWidget);
      expect(find.textContaining('Supervisión adulta continua'), findsWidgets);

      // Advance to Phase 5: Matematicas temperas
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('Fase 5 de 6'), findsOneWidget);
      expect(find.text('Matemáticas temperás (0-3)'), findsOneWidget);
      expect(find.text('Grande / Pequeno'), findsOneWidget);

      // Advance to Phase 6: Ponte a casa
      await tester.tap(find.text('Seguinte'));
      await tester.pumpAndSettle();

      expect(find.text('Fase 6 de 6'), findsOneWidget);
      expect(find.text('Ponte á casa: Comunicación con familias'), findsOneWidget);
      expect(find.text('Finalizar'), findsOneWidget);
    });
  });
}
