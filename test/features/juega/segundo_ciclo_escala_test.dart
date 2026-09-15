import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/backstage_asamblea_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';

/// Lo que este fichero existe para impedir.
///
/// La tarjeta de la asamblea de 2.º ciclo desbordaba **299 px en gallego y 323
/// en castellano a escala normal**, y 468 px a escala 1,3. No lo cazó nadie
/// porque las capturas retrataban el interior de la asamblea, nunca la lista
/// del aula con la pestaña de 2.º ciclo pulsada: la pantalla por la que se
/// entra.
///
/// Un `RenderFlex overflowed` solo se ve en debug, con las franjas amarillas.
/// En release el texto se corta y nadie se entera, así que la barrera tiene
/// que ser un test y no una mirada.
void main() {
  late ContentRepository contenido;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    contenido = ContentRepository();
    await contenido.initialize();
  });

  Future<void> conEscala(
    WidgetTester tester,
    double escala,
    Widget pantalla,
  ) async {
    tester.view.physicalSize = const Size(360, 900) * 2;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escala)),
        child: MaterialApp(theme: AppTheme.lightTheme, home: pantalla),
      ),
    );
    await tester.pumpAndSettle();
  }

  // 360 dp es el ancho del móvil barato que hay en una escuela infantil, no el
  // del aparato de quien programa.
  for (final lang in AppLanguage.deInterfaz) {
    final l = lang == AppLanguage.gl ? 'gl' : 'es';
    for (final escala in [1.0, 1.3]) {
      testWidgets(
          'la lista do aula, no 2.º ciclo, non desborda en $l a $escala',
          (tester) async {
        await conEscala(
          tester,
          escala,
          UnidadesListScreen(repository: contenido, initialLanguage: lang),
        );
        await tester.tap(find.byKey(const ValueKey('tab_segundo_ciclo')));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });

      testWidgets('a asemblea de 2.º ciclo non desborda en $l a $escala',
          (tester) async {
        await conEscala(
          tester,
          escala,
          BackstageAsambleaScreen(
            repository: contenido,
            initialLanguage: lang,
          ),
        );
        expect(tester.takeException(), isNull);
      });
    }
  }
}
