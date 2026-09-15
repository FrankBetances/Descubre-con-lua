import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/micro_rutina_setembro_screen.dart';
import 'package:descubre_con_lua/features/academy/widgets/recast_guia_card.dart';

void main() {
  group('RecastGuiaCard Widget Tests', () {
    testWidgets(
        'renders recast comparison guide with positive and negative modeling',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecastGuiaCard(language: AppLanguage.gl),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header
      expect(find.text('MODELADO INDIRECTO (RECAST)'), findsOneWidget);
      expect(find.text('Como responder na casa sen corrixir'), findsOneWidget);

      // 5-second active wait rule
      expect(find.textContaining('agarda 5 segundos antes de axudar'),
          findsOneWidget);

      // Expresión menor
      expect(find.text('«Abrigo chan!»'), findsOneWidget);

      // Negative frontal correction to avoid
      expect(find.textContaining('Evitar (corrección frontal)'), findsWidgets);
      expect(find.textContaining('Convértese en exame'), findsOneWidget);

      // Positive indirect recast
      expect(find.textContaining('Acompañar con Recast'), findsWidgets);
      expect(find.textContaining('Up on the hook, zip!'), findsOneWidget);

      // Time and place
      expect(find.textContaining('Principio «Time and Place»'), findsOneWidget);
    });

    testWidgets('renders recast guide in Spanish when language is ES',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecastGuiaCard(language: AppLanguage.es),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cómo responder en casa sin corregir'), findsOneWidget);
      expect(find.textContaining('espera 5 segundos antes de ayudar'),
          findsOneWidget);
      expect(find.text('«¡Abrigo suelo!»'), findsOneWidget);
    });
  });

  group('MicroRutinaSetembroScreen Widget Tests', () {
    testWidgets(
        'renders September micro-routine screen with scene and curricular alignment',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MicroRutinaSetembroScreen(
            initialLanguage: AppLanguage.gl,
            // El alineamiento curricular sale del JSON de la cápsula; sin él la
            // pantalla no lo pinta, que es lo que se quiere.
            curriculo: CurricularReference(
              normativa: 'Decreto 150/2022',
              etapa: 'educacion_infantil',
              ciclo: 'segundo_ciclo_3_6',
              areas: [
                'area_1_crecemento_harmonia',
                'area_3_comunicacion_representacion'
              ],
              criteriosEvaluacion: ['CA1.1', 'CA3.1'],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title and kicker
      expect(find.text('SEGUNDO CICLO (3-6 ANOS) · FOGAR'), findsOneWidget);
      expect(
        find.text(
            'Acollida na escola e linguas na casa: o principio de tempo e lugar'),
        findsOneWidget,
      );

      // Everyday scene
      expect(
          find.text('A Escena Cotiá: «The Magic Coat Hook»'), findsOneWidget);
      expect(find.text('3-5 MINUTOS'), findsOneWidget);

      // Embedded RecastGuiaCard
      expect(find.byType(RecastGuiaCard), findsOneWidget);

      // Curricular alignment
      expect(find.text('Aliñamento Curricular (Decreto 150/2022)'),
          findsOneWidget);
    });

    testWidgets(
        'toggles language between GL and ES in MicroRutinaSetembroScreen',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MicroRutinaSetembroScreen(
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Micro-Rutina · Setembro'), findsOneWidget);

      // El selector son dos pastillas, GL y ES: se pulsa ES directamente.
      await tester.tap(find.text('ES'));
      await tester.pumpAndSettle();

      expect(find.text('Micro-Rutina · Septiembre'), findsOneWidget);
      expect(find.text('La Escena Cotidiana: «The Magic Coat Hook»'),
          findsOneWidget);
    });
  });

  group('BloquesListScreen Segundo Ciclo Integration Tests', () {
    testWidgets(
        'shows Segundo Ciclo card and navigates to MicroRutinaSetembroScreen',
        (tester) async {
      final repository = ContentRepository();

      await tester.pumpWidget(
        MaterialApp(
          home: BloquesListScreen(
            repository: repository,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the card for Segundo Ciclo micro-routine
      final segundoCicloCard =
          find.text('Micro-rutina de setembro: responder sen corrixir');
      expect(segundoCicloCard, findsOneWidget);

      // Tap card to open screen
      await tester.tap(segundoCicloCard);
      await tester.pumpAndSettle();

      // Verifies navigation to MicroRutinaSetembroScreen
      expect(find.byType(MicroRutinaSetembroScreen), findsOneWidget);
      expect(find.byType(RecastGuiaCard), findsOneWidget);
    });
  });
}
