import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/academy/widgets/seccion_capsula_widget.dart';
import 'package:descubre_con_lua/features/academy/widgets/selector_idioma_widget.dart';

void main() {
  late ContentRepository repository;
  late Capsula testCapsula;

  setUp(() {
    repository = ContentRepository();
    testCapsula = Capsula(
      id: 'test.capsula.01',
      bloqueId: 'desarrollo_comunicativo',
      orden: 1,
      titulo: const LocalizedString(
        gl: 'Como se aprende a falar: o baño de lingua e as primeiras quendas',
        es: 'Cómo se aprende a hablar: el baño de lenguaje y los primeros turnos',
      ),
      subtitulo: const LocalizedString(
        gl: 'A importancia de escoitar con calma',
        es: 'La importancia de escuchar con calma',
      ),
      tiempoLecturaMinutos: 3,
      icono: 'ear_sparkles',
      ideaClave: const LocalizedString(
        gl: 'A fala comeza co balbuceo e a mirada.',
        es: 'El habla comienza con el balbuceo y la mirada.',
      ),
      porQueImporta: const LocalizedString(
        gl: 'Fortalece os circuítos neurais afectivos.',
        es: 'Fortalece los circuitos neuronales afectivos.',
      ),
      queHacerEnCasa: const LocalizedString(
        gl: 'Garda 5 segundos de espera atenta.',
        es: 'Guarda 5 segundos de espera atenta.',
      ),
      ejemploCotidiano: const LocalizedString(
        gl: 'Ao mudar o cueiro: Aquí está o pé!',
        es: 'Al cambiar el pañal: ¡Aquí está el pie!',
      ),
      afirmaciones: const [
        Afirmacion(
          id: 'af_01',
          enunciado: LocalizedString(
            gl: 'A pausa atenta axuda a falar.',
            es: 'La pausa atenta ayuda a hablar.',
          ),
          esVerdadera: true,
          explicacion: LocalizedString(
            gl: 'Exacto: concede tempo de resposta.',
            es: 'Exacto: concede tiempo de respuesta.',
          ),
        ),
      ],
      curriculo: const CurricularReference(
        normativa: 'Decreto 150/2022',
        etapa: 'educacion_infantil',
        ciclo: 'primeiro_ciclo_0_3',
        areas: ['area_1_crecemento_harmonia'],
        criteriosEvaluacion: ['CA1.1'],
      ),
      revision: const Revision(
        autor: 'Dr. Frank Betances',
        revisorPedagogico: 'Equipo Pedagóxico Vigo',
        fechaRevision: '2026-09-11',
        version: '1.0.0',
        aprobadoParaAula: true,
      ),
    );
    repository.addCapsula(testCapsula);
  });

  group('Academy Feature Tests', () {
    testWidgets('SelectorIdiomaWidget toggles between GL and ES correctly', (tester) async {
      AppLanguage selected = AppLanguage.gl;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return SelectorIdiomaWidget(
                  currentLanguage: selected,
                  onLanguageChanged: (lang) {
                    setState(() {
                      selected = lang;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('Galego'), findsOneWidget);
      expect(find.text('Castellano'), findsOneWidget);

      await tester.tap(find.text('Castellano'));
      await tester.pumpAndSettle();

      expect(selected, AppLanguage.es);
    });

    testWidgets('BloquesListScreen displays all 5 developmental blocks', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BloquesListScreen(
            repository: repository,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      expect(find.text('Academy · Familias'), findsOneWidget);
      expect(find.text('Bloque 1'), findsOneWidget);
      expect(find.text('Bloque 2'), findsOneWidget);
      expect(find.text('Bloque 3'), findsOneWidget);
      expect(find.text('Bloque 4'), findsOneWidget);
      expect(find.text('Bloque 5'), findsOneWidget);

      // Verify block 1 title in Galician
      expect(find.text('Como se aprende a falar'), findsOneWidget);
    });

    testWidgets('CapsulaDetailScreen displays 4 canonical sections and reflection', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CapsulaDetailScreen(
            capsula: testCapsula,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      // Verify 4 canonical sections
      expect(find.text('1. Idea clave'), findsOneWidget);
      expect(find.text('2. Por que importa'), findsOneWidget);
      expect(find.text('3. Que facer na casa'), findsOneWidget);
      expect(find.text('4. Exemplo cotián'), findsOneWidget);

      // Verify content presence
      expect(find.text('A fala comeza co balbuceo e a mirada.'), findsOneWidget);
      expect(find.text('Garda 5 segundos de espera atenta.'), findsOneWidget);

      // Verify formative reflection
      expect(find.text('Reflexión para a familia'), findsOneWidget);
      expect(find.text('Verdadeiro'), findsOneWidget);
      expect(find.text('Falso'), findsOneWidget);

      // Tap true
      await tester.tap(find.text('Verdadeiro'));
      await tester.pumpAndSettle();

      expect(find.text('Exacto: concede tempo de resposta.'), findsOneWidget);
    });
  });
}
