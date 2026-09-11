import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/scroll_helpers.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';

void main() {
  late ContentRepository repository;
  late Capsula testCapsula;

  setUp(() {
    repository = ContentRepository();
    testCapsula = const Capsula(
      id: 'academy.como_se_aprende_a_hablar.01',
      bloqueId: 'desarrollo_comunicativo',
      orden: 1,
      titulo: LocalizedString(
        gl: 'Como se aprende a falar: o baño de lingua e as primeiras quendas',
        es: 'Cómo se aprende a hablar: el baño de lenguaje y los primeros turnos',
      ),
      subtitulo: LocalizedString(
        gl: 'A importancia de escoitar con calma e interactuar antes das primeiras palabras',
        es: 'La importancia de escuchar con calma e interactuar antes de las primeras palabras',
      ),
      tiempoLecturaMinutos: 3,
      icono: 'ear_sparkles',
      ideaClave: LocalizedString(
        gl: 'A fala comeza moito antes da primeira palabra.',
        es: 'El habla comienza mucho antes de la primera palabra.',
      ),
      porQueImporta: LocalizedString(
        gl: 'O cerebro do bebé precisa escoitar repeticións.',
        es: 'El cerebro del bebé necesita escuchar repeticiones.',
      ),
      queHacerEnCasa: LocalizedString(
        gl: 'Nomea en voz alta e garda 5 segundos de espera.',
        es: 'Nombra en voz alta y guarda 5 segundos de espera.',
      ),
      ejemploCotidiano: LocalizedString(
        gl: 'Ao mudar o cueiro: Mira o pé!',
        es: 'Al cambiar el pañal: ¡Mira el pie!',
      ),
      afirmaciones: [
        Afirmacion(
          id: 'afirmacion_01',
          enunciado: LocalizedString(
            gl: 'Esperar en silencio axuda a que o neno tome a iniciativa.',
            es: 'Esperar en silencio ayuda a que el niño tome la iniciativa.',
          ),
          esVerdadera: true,
          explicacion: LocalizedString(
            gl: 'Exacto: a pausa atenta é a invitación máis respectuosa.',
            es: 'Exacto: la pausa atenta es la invitación más respetuosa.',
          ),
        ),
        Afirmacion(
          id: 'afirmacion_02',
          enunciado: LocalizedString(
            gl: 'É necesario esixir que repita correctamente as palabras.',
            es: 'Es necesario exigir que repita correctamente las palabras.',
          ),
          esVerdadera: false,
          explicacion: LocalizedString(
            gl: 'Non é conveniente: nos primeiros 3 anos o modelo natural é mellor.',
            es: 'No es conveniente: en los primeros 3 años el modelo natural es mejor.',
          ),
        ),
      ],
      curriculo: CurricularReference(
        normativa: 'Decreto 150/2022',
        etapa: 'educacion_infantil',
        ciclo: 'primeiro_ciclo_0_3',
        areas: [
          'area_1_crecemento_harmonia',
          'area_3_comunicacion_representacion'
        ],
        criteriosEvaluacion: ['CA1.1', 'CA3.1'],
      ),
      revision: Revision(
        autor: 'Equipo Pedagóxico Descubre con Lúa',
        revisorPedagogico: 'Especialista en Desenvolvemento Infantil e Familia',
        fechaRevision: '2026-09-11',
        version: '1.0.0',
        aprobadoParaAula: true,
      ),
    );
    repository.addCapsula(testCapsula);
  });

  group('Adversarial Language Switching Suite', () {
    testWidgets(
        'Rapid dynamic language toggling updates strings without state corruption',
        (tester) async {
      AppLanguage currentLanguage = AppLanguage.gl;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return BloquesListScreen(
                repository: repository,
                initialLanguage: currentLanguage,
                onLanguageChanged: (newLang) {
                  setState(() {
                    currentLanguage = newLang;
                  });
                },
              );
            },
          ),
        ),
      );

      // Verify Galician text on initial load
      expect(find.text('Os 5 bloques de desenvolvemento'), findsOneWidget);
      expect(find.text('Como se aprende a falar'), findsOneWidget);

      // Switch to ES
      await tester.tap(find.text('ES'));
      await tester.pumpAndSettle();

      // Verify Spanish translation updated immediately
      expect(find.text('Los 5 bloques de desarrollo'), findsOneWidget);
      expect(find.text('Cómo se aprende a hablar'), findsOneWidget);

      // Switch back to GL
      await tester.tap(find.text('GL'));
      await tester.pumpAndSettle();

      expect(find.text('Os 5 bloques de desenvolvemento'), findsOneWidget);
      expect(find.text('Como se aprende a falar'), findsOneWidget);
    });

    testWidgets(
        'Language switch preserves formative reflection answer state in CapsulaDetailScreen',
        (tester) async {
      AppLanguage currentLanguage = AppLanguage.gl;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: StatefulBuilder(
            builder: (context, setState) {
              return CapsulaDetailScreen(
                capsula: testCapsula,
                initialLanguage: currentLanguage,
                onLanguageChanged: (newLang) {
                  setState(() {
                    currentLanguage = newLang;
                  });
                },
              );
            },
          ),
        ),
      );

      // Initially no feedback shown
      expect(
          find.text('Exacto: a pausa atenta é a invitación máis respectuosa.'),
          findsNothing);

      // Select 'Verdadeiro' for affirmation 1
      final verdaderoButtons = find.text('Verdadeiro');
      await expectAfterScrolling(tester, verdaderoButtons,
          matcher: findsNWidgets(2));
      await tapAfterScrolling(tester, verdaderoButtons);

      // Feedback should now be visible in Galician
      await expectAfterScrolling(tester,
          find.text('Exacto: a pausa atenta é a invitación máis respectuosa.'));

      // Switch language to ES
      await tester.tap(find.text('ES'));
      await tester.pumpAndSettle();

      // Feedback explanation must update immediately to Spanish WITHOUT losing selection
      await expectAfterScrolling(
          tester,
          find.text(
              'Exacto: la pausa atenta es la invitación más respetuosa.'));
      expect(
          find.text('Exacto: a pausa atenta é a invitación máis respectuosa.'),
          findsNothing);
    });
  });

  group('Adversarial Formative Reflection Interaction Suite', () {
    testWidgets(
        'True/False selection exhibits idempotent tapping and state stability',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CapsulaDetailScreen(
            capsula: testCapsula,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      final verdaderoButtons = find.text('Verdadeiro');
      final falsoButtons = find.text('Falso');
      await expectAfterScrolling(tester, verdaderoButtons,
          matcher: findsNWidgets(2));

      // Tap True for question 1
      await tapAfterScrolling(tester, verdaderoButtons);
      await expectAfterScrolling(tester,
          find.text('Exacto: a pausa atenta é a invitación máis respectuosa.'));

      // Idempotent re-tap: tap True again, state must remain True
      await tapAfterScrolling(tester, verdaderoButtons);
      await expectAfterScrolling(tester,
          find.text('Exacto: a pausa atenta é a invitación máis respectuosa.'));

      // Switch to False for question 1 (disagreeing with the true statement)
      await tapAfterScrolling(tester, falsoButtons);

      // Feedback still shown (formative non-punitive), icon indicates clarification
      await expectAfterScrolling(tester,
          find.text('Exacto: a pausa atenta é a invitación máis respectuosa.'));
      expect(find.byIcon(Icons.info_outline), findsWidgets);

      // Tap False for question 2 (which is indeed false: "esVerdadera: false")
      await tapAfterScrolling(tester, falsoButtons.at(1));

      // Feedback for question 2 shown with positive check
      await expectAfterScrolling(
          tester,
          find.text(
              'Non é conveniente: nos primeiros 3 anos o modelo natural é mellor.'));
      expect(find.byIcon(Icons.check_circle_outline), findsWidgets);
    });
  });

  group('Adversarial Invariant Probes: Links and Game Mechanics', () {
    testWidgets('Screen contains zero web links or child game widgets',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CapsulaDetailScreen(
            capsula: testCapsula,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      // Ensure no child game elements
      expect(find.textContaining('Puntos'), findsNothing);
      expect(find.textContaining('Monedas'), findsNothing);
      expect(find.textContaining('Nivel superado'), findsNothing);

      // Ensure no web anchor links
      expect(find.textContaining('http://'), findsNothing);
      expect(find.textContaining('https://'), findsNothing);
    });
  });
}
