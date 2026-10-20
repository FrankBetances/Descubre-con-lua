import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/cuentos/views/microcuento_screen.dart';
import 'package:descubre_con_lua/features/cuentos/widgets/boton_microcuento.dart';

/// M5.8: la puerta al microcuento del mes. Sale si la unidad tiene microcuento
/// con todas sus láminas dibujadas, y abre el visor en el modo de quien la
/// pulsa. En 0-2 no sale. Se mira en gl y es, con texto normal y grande, a
/// 360 de ancho. Lo que no prueba: fuentes reales, un aparato.
void main() {
  late ContentRepository repo;

  setUp(() async {
    repo = ContentRepository();
    // Xuño (6) de 2-3 ten as tres láminas de mostra.
    await repo.loadUnidadeDoMes('curso_2_3', 6);
    await repo.loadUnidadeDoMes('curso_0_2', 6);
    await repo.loadRexistroFrases();
  });

  Future<void> pintar(WidgetTester tester, String curso, AppLanguage lang,
      ModoMicrocuento modo, double escala) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MediaQuery(
      data: MediaQueryData(
          size: const Size(360, 640), textScaler: TextScaler.linear(escala)),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: BotonMicrocuento(
              repository: repo,
              cursoId: curso,
              mesCalendario: 6,
              modo: modo,
              language: lang,
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
  }

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.8]) {
      for (final modo in ModoMicrocuento.values) {
        testWidgets('2-3 xuño, ${modo.name}, ${lang.code}, escala $escala',
            (tester) async {
          await pintar(tester, 'curso_2_3', lang, modo, escala);
          final boton = find.byKey(ValueKey('microcuento_${modo.name}'));
          expect(boton, findsOneWidget);
          final titulo = repo
              .unidadeDoMesSync('curso_2_3', 6)!
              .microcuento!
              .titulo
              .resolve(lang);
          expect(find.textContaining(titulo), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.tap(boton);
          await tester.pumpAndSettle();
          final visor =
              tester.widget<MicrocuentoScreen>(find.byType(MicrocuentoScreen));
          expect(visor.modo, modo);
          expect(visor.microcuento.id, 'microcuento.curso_2_3.10');
          expect(tester.takeException(), isNull);
        });
      }
    }
  }

  testWidgets('0-2 non ten microcuento: non sae nada', (tester) async {
    await pintar(
        tester, 'curso_0_2', AppLanguage.gl, ModoMicrocuento.aula, 1.0);
    expect(find.byType(OutlinedButton), findsNothing);
  });
}
