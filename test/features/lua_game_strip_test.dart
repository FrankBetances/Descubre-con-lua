import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/premios/premios_screen.dart';
import 'package:descubre_con_lua/features/premios/widgets/lua_game_strip.dart';

/// La tira de juego es disposición NUEVA en cuatro pantallas, y va en una fila
/// con la gata a un lado y la racha al otro. La familia de defectos de la
/// regla 1c vive exactamente aquí: en release un desborde no pinta franjas
/// amarillas, el texto simplemente se corta.
void main() {
  late Directory dir;
  late DateTime reloj;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('game_strip_test');
    reloj = DateTime(2026, 3, 10, 9, 30);
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  // Leer el catálogo del paquete es E/S real: dentro de `testWidgets` un
  // `await` de E/S no avanza con el reloj falso, así que sin `runAsync` el
  // catálogo se queda en null y la tira nunca llega a pintarse.
  Future<PremiosRepository> repo(WidgetTester tester) async {
    final r = PremiosRepository(
      store: LocalStore(fileName: 'premios.json', overrideDirectory: dir.path),
      ahora: () => reloj,
    );
    await tester.runAsync(() => r.cargar());
    return r;
  }

  List<Object> errores(WidgetTester tester) {
    final out = <Object>[];
    while (true) {
      final e = tester.takeException();
      if (e == null) break;
      out.add(e);
    }
    return out;
  }

  Widget montar(
    PremiosRepository r,
    AppLanguage lang, {
    double escala = 1.0,
    Perfil perfil = Perfil.docente,
  }) =>
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(escala)),
          child: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: LuaGameStrip(
                repository: r,
                perfil: perfil,
                language: lang,
              ),
            ),
          ),
        ),
      );

  group('La tira cabe', () {
    for (final lang in AppLanguage.deInterfaz) {
      for (final escala in [1.0, 1.8]) {
        testWidgets('en ${lang.code} a escala $escala, con el peor texto',
            (tester) async {
          // Pantalla estrecha: el Pixel 6 en el que Frank prueba es más ancho,
          // pero un móvil de 360 dp es lo que hay en muchas aulas.
          tester.view.physicalSize = const Size(360, 640);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(tester.view.reset);

          final r = await repo(tester);
          // El peor caso: nivel alto (título largo) y racha de dos cifras.
          await tester.runAsync(() async {
            for (var i = 0; i < 40; i++) {
              await r.registrar(Perfil.docente, EventoPremio.asamblea);
              reloj = reloj.add(const Duration(days: 1));
            }
          });

          await tester.pumpWidget(montar(r, lang, escala: escala));
          await tester.pumpAndSettle();

          expect(errores(tester), isEmpty,
              reason: 'La tira desborda en ${lang.code} a escala $escala.');
        });
      }
    }
  });

  group('La tira dice la verdad y lleva a alguna parte', () {
    testWidgets('enseña el nivel y la racha del perfil que se le pasa',
        (tester) async {
      final r = await repo(tester);
      // La maestra dirige tres asambleas; la familia no lee nada.
      await tester.runAsync(() async {
        for (var i = 0; i < 3; i++) {
          await r.registrar(Perfil.docente, EventoPremio.asamblea);
          reloj = reloj.add(const Duration(days: 1));
        }
      });

      await tester.pumpWidget(montar(r, AppLanguage.es));
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget, reason: 'La racha de la maestra.');

      // Mismo repositorio, otro perfil: no puede enseñar la racha ajena.
      await tester.pumpWidget(
        montar(r, AppLanguage.es, perfil: Perfil.familia),
      );
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget,
          reason: 'La familia no ha leído nada: su racha es 0, no la de la '
              'maestra.');
    });

    testWidgets('pulsarla abre los premios en ese mismo perfil',
        (tester) async {
      final r = await repo(tester);
      await tester
          .pumpWidget(montar(r, AppLanguage.es, perfil: Perfil.familia));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(LuaGameStrip));
      await tester.pumpAndSettle();

      // Estaba escondida detrás de un botón del hub: se ganaban insignias que
      // nadie veía. Que la tira lleve a la colección es el punto de la tira.
      expect(find.byType(PremiosScreen), findsOneWidget);
      final pantalla = tester.widget<PremiosScreen>(find.byType(PremiosScreen));
      expect(pantalla.perfilInicial, Perfil.familia);
    });

    testWidgets('sin catálogo no pinta una caja vacía', (tester) async {
      // Repositorio sin cargar: no hay catálogo. La asamblea funciona igual
      // sin premios, y un hueco vacío solo confunde.
      final r = PremiosRepository(
        store:
            LocalStore(fileName: 'premios.json', overrideDirectory: dir.path),
        ahora: () => reloj,
      );
      await tester.pumpWidget(montar(r, AppLanguage.gl));
      await tester.pumpAndSettle();

      expect(errores(tester), isEmpty);
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
