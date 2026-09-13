import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/juega/views/capsulas_aula_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repo;

  setUpAll(() async {
    repo = ContentRepository();
    await repo.initialize();
  });

  List<Object> errores(WidgetTester tester) {
    final out = <Object>[];
    while (true) {
      final e = tester.takeException();
      if (e == null) break;
      out.add(e);
    }
    return out;
  }

  group('Las seis cápsulas del aula están y son del aula', () {
    test('hay una por cada uno de los seis pasos de la asamblea', () {
      final bloques = repo.getAllBloquesAula();
      expect(bloques.length, 6);
      // El orden importa: son los pasos de la asamblea, no una lista suelta.
      expect(bloques.map((b) => b.orden), [1, 2, 3, 4, 5, 6]);

      for (final bloque in bloques) {
        final capsulas = repo.getCapsulasAulaByBloqueId(bloque.id);
        expect(capsulas, isNotEmpty,
            reason: 'El paso ${bloque.orden} («${bloque.id}») no tiene '
                'cápsula. Un paso sin cápsula deja una tarjeta apagada en una '
                'lista de seis.');
        for (final c in capsulas) {
          expect(c.destinatario, DestinatarioCapsula.docente);
        }
      }
    });

    test('pasan el validador de contenido, igual que las de Academy', () {
      final validator = ContentValidator();
      for (final c in repo.getAllCapsulas()) {
        final result = validator.validateCapsulaJson(c.toJson());
        expect(result.isValid, isTrue,
            reason: '${c.id}: ${result.errors.join(" · ")}');
      }
    });
  });

  group('Una cápsula del aula no puede acabar en Academy', () {
    test('los cinco bloques de Academy solo devuelven cápsulas de familia', () {
      for (final bloque in repo.getAllBloques()) {
        for (final c in repo.getCapsulasByBloqueId(bloque.id)) {
          expect(c.destinatario, DestinatarioCapsula.familia,
              reason: 'La cápsula ${c.id} sale en Academy y es del aula. Una '
                  'familia leería formación docente y la lista se pintaría '
                  'igual de bien.');
        }
      }
    });

    testWidgets('Academy no enseña ninguna cápsula del aula', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: BloquesListScreen(repository: repo),
      ));
      await tester.pumpAndSettle();

      final textos = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' ');
      // Títulos que solo existen en las cápsulas del aula.
      expect(textos, isNot(contains('asemblea')));
      expect(textos, isNot(contains('asamblea')));
    });
  });

  group('La pantalla del aula', () {
    for (final lang in AppLanguage.deInterfaz) {
      for (final escala in [1.0, 1.8]) {
        testWidgets('cabe en ${lang.code} a escala $escala', (tester) async {
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          await tester.pumpWidget(MaterialApp(
            theme: AppTheme.lightTheme,
            home: MediaQuery(
              data: MediaQueryData(textScaler: TextScaler.linear(escala)),
              child: CapsulasAulaScreen(
                repository: repo,
                initialLanguage: lang,
              ),
            ),
          ));
          await tester.pumpAndSettle();

          expect(errores(tester), isEmpty,
              reason: 'Desborda en ${lang.code} a escala $escala.');
        });
      }
    }

    testWidgets('enseña los seis pasos, ninguno apagado', (tester) async {
      tester.view.physicalSize = const Size(400, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CapsulasAulaScreen(
            repository: repo, initialLanguage: AppLanguage.es),
      ));
      await tester.pumpAndSettle();

      for (var i = 1; i <= 6; i++) {
        expect(find.text('PASO $i'), findsOneWidget,
            reason: 'Falta el paso $i en la lista.');
      }
      expect(find.textContaining('preparación pedagógica'), findsNothing,
          reason: 'Un paso sin cápsula deja una tarjeta apagada.');
    });
  });

  group('Leer una cápsula del aula cuenta para la MAESTRA', () {
    late Directory dir;

    setUp(() => dir = Directory.systemTemp.createTempSync('aula_premios'));
    tearDown(() {
      if (dir.existsSync()) dir.deleteSync(recursive: true);
    });

    testWidgets('suma a la docente y no a la familia', (tester) async {
      tester.view.physicalSize = const Size(400, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final premios = PremiosRepository(
        store:
            LocalStore(fileName: 'premios.json', overrideDirectory: dir.path),
        ahora: () => DateTime(2026, 3, 10),
      );
      await tester.runAsync(() => premios.cargar());

      final capsula = repo.getCapsulasAulaByBloqueId('aula_pulso').first;
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: CapsulaDetailScreen(
          capsula: capsula,
          initialLanguage: AppLanguage.es,
          premios: premios,
        ),
      ));
      await tester.pumpAndSettle();

      // Se recorren las cuatro secciones y se responde a cada afirmación.
      for (var i = 0; i < 20; i++) {
        final verdadero = find.text('Verdadero');
        if (verdadero.evaluate().isNotEmpty) {
          await tester.tap(verdadero);
          await tester.pumpAndSettle();
        }
        final siguiente = find.text('Siguiente');
        if (siguiente.evaluate().isEmpty) break;
        final boton =
            tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        if (boton.onPressed == null) break;
        await tester.tap(siguiente);
        await tester.pumpAndSettle();
      }

      expect(premios.progresoDe(Perfil.docente).capsulas, 1,
          reason: 'La cápsula del aula la lee la maestra.');
      expect(premios.progresoDe(Perfil.familia).capsulas, 0,
          reason: 'No puede sumarle a la familia, que no la ha leído.');
    });
  });
}
