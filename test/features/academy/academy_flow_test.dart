import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/scroll_helpers.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' show Revision;
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/academy/widgets/selector_idioma_widget.dart';

void main() {
  late ContentRepository repository;
  late Capsula testCapsula;

  setUp(() {
    repository = ContentRepository();
    testCapsula = const Capsula(
      id: 'test.capsula.01',
      bloqueId: 'desarrollo_comunicativo',
      orden: 1,
      titulo: LocalizedString(
        gl: 'Como se aprende a falar: o baño de lingua e as primeiras quendas',
        es: 'Cómo se aprende a hablar: el baño de lenguaje y los primeros turnos',
      ),
      subtitulo: LocalizedString(
        gl: 'A importancia de escoitar con calma',
        es: 'La importancia de escuchar con calma',
      ),
      tiempoLecturaMinutos: 3,
      icono: 'ear_sparkles',
      ideaClave: LocalizedString(
        gl: 'A fala comeza co balbuceo e a mirada.',
        es: 'El habla comienza con el balbuceo y la mirada.',
      ),
      porQueImporta: LocalizedString(
        gl: 'Fortalece os circuítos neurais afectivos.',
        es: 'Fortalece los circuitos neuronales afectivos.',
      ),
      queHacerEnCasa: LocalizedString(
        gl: 'Garda 5 segundos de espera atenta.',
        es: 'Guarda 5 segundos de espera atenta.',
      ),
      ejemploCotidiano: LocalizedString(
        gl: 'Ao mudar o cueiro: Aquí está o pé!',
        es: 'Al cambiar el pañal: ¡Aquí está el pie!',
      ),
      afirmaciones: [
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
      curriculo: CurricularReference(
        normativa: 'Decreto 150/2022',
        etapa: 'educacion_infantil',
        ciclo: 'primeiro_ciclo_0_3',
        areas: ['area_1_crecemento_harmonia'],
        criteriosEvaluacion: ['CA1.1'],
      ),
      revision: Revision(
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
    testWidgets('SelectorIdiomaWidget toggles between GL and ES correctly',
        (tester) async {
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

    testWidgets('BloquesListScreen displays all 5 developmental blocks',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BloquesListScreen(
            repository: repository,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );

      expect(find.text('Academy · Familias'), findsOneWidget);
      // The five blocks do not fit in one viewport: a family scrolls to reach
      // the last ones, so the test scrolls too instead of asserting on height.
      for (var i = 1; i <= 5; i++) {
        // Versalitas: el antetítulo de la tarjeta de Academy va en mayúsculas,
        // como en el proyecto anterior de la casa. Si alguien quita el toUpperCase, esto lo dice.
        await expectAfterScrolling(tester, find.text('BLOQUE $i'));
      }

      // Verify block 1 title in Galician
      await expectAfterScrolling(tester, find.text('Como se aprende a falar'));
    });

    testWidgets(
        'el lector recorre las 4 secciones y la reflexión, una por pantalla',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: CapsulaDetailScreen(
            capsula: testCapsula,
            initialLanguage: AppLanguage.gl,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // El lector va PAGINADO, como el del proyecto anterior de la casa: una idea por pantalla. Así
      // que no se busca todo a la vez, se recorre, que es lo que hace una
      // familia. Si alguien vuelve al scroll único, este test lo dice.
      Future<void> siguiente() async {
        await tester.tap(find.text('Seguinte'));
        await tester.pumpAndSettle();
      }

      expect(find.text('A idea clave'), findsOneWidget);
      expect(
          find.text('A fala comeza co balbuceo e a mirada.'), findsOneWidget);
      // Las otras secciones NO están todavía: eso es la paginación funcionando.
      expect(find.text('Por que importa'), findsNothing);

      await siguiente();
      expect(find.text('Por que importa'), findsOneWidget);

      await siguiente();
      expect(find.text('Que facer na casa'), findsOneWidget);
      expect(find.text('Garda 5 segundos de espera atenta.'), findsOneWidget);

      await siguiente();
      expect(find.text('Un momento calquera'), findsOneWidget);

      // Primera afirmación: aquí no se puede avanzar sin responder.
      await siguiente();
      expect(find.text('Verdadeiro'), findsOneWidget);
      expect(find.text('Falso'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
        reason: 'Sin responder no se avanza: si no, la cápsula se terminaría '
            'sin haberla leído.',
      );

      await tester.tap(find.text('Verdadeiro'));
      await tester.pumpAndSettle();
      expect(find.text('Exacto: concede tempo de resposta.'), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNotNull,
      );
    });
  });
}
