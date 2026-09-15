import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/asamblea_primeiro_ciclo_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';

/// La edad del aula: antes eran tres chips de filtro sobre una lista de
/// unidades; ahora es el selector de grupo del 1.º ciclo, que además decide
/// QUÉ microcápsula sale. Es la misma pregunta —¿con qué edad trabajas?— hecha
/// donde sirve para algo.
///
/// La familia de defectos que vigila esta prueba no ha cambiado: una etiqueta
/// que RECORTA no desborda. No hay franjas amarillas, no se lanza ninguna
/// excepción y `pumpAndSettle` termina tan contento; el texto sale cortado y en
/// release nadie se entera. Por eso aquí no se busca una excepción: se compara
/// el ancho que la pastilla le da al texto con el que ese texto mide de verdad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ContentRepository repo;

  setUpAll(() async {
    repo = ContentRepository();
    await repo.initialize();
  });

  /// ¿Cabe la cadena en ese ancho, con las líneas que la pastilla le permite?
  ///
  /// No se compara contra el ancho de UNA línea: la pastilla deja dos, así que
  /// «0-2 anos» puede partirse y seguir estando entero. Lo que esta prueba no
  /// admite es que el texto se corte, que es lo que pasa cuando ni con dos
  /// líneas cabe. En release eso no enseña franjas: enseña media palabra.
  bool cabe(String texto, TextStyle estilo, double escala, double ancho,
      int maxLines) {
    final painter = TextPainter(
      text: TextSpan(text: texto, style: estilo),
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear(escala),
      maxLines: maxLines,
    )..layout(maxWidth: ancho);
    return !painter.didExceedMaxLines;
  }

  for (final lang in AppLanguage.deInterfaz) {
    for (final escala in [1.0, 1.3]) {
      testWidgets(
why(lang, escala),
          (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.reset);

        await tester.pumpWidget(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(escala)),
            child: MaterialApp(
              theme: AppTheme.lightTheme,
              home: UnidadesListScreen(
                repository: repo,
                initialLanguage: lang,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        for (final tramo in TramoPrimeiroCiclo.values) {
          final clave = ValueKey('tramo_1c_$tramo');
          expect(find.byKey(clave), findsOneWidget,
              reason: 'Falta la pastilla del tramo $tramo');

          final etiqueta = tramo.etiquetaCorta.resolve(lang);
          final textoFinder = find.descendant(
            of: find.byKey(clave),
            matching: find.text(etiqueta),
          );
          expect(textoFinder, findsOneWidget);

          final caja = tester.getSize(textoFinder);
          final widget = tester.widget<Text>(textoFinder);

          expect(
            cabe(
              etiqueta,
              widget.style ?? const TextStyle(),
              escala,
              caja.width + 0.5,
              widget.maxLines ?? 1,
            ),
            isTrue,
            reason: 'La etiqueta «$etiqueta» se corta en '
                '${lang.name} a escala $escala: la pastilla le da '
                '${caja.width.toStringAsFixed(1)} px y ni con '
                '${widget.maxLines ?? 1} líneas cabe',
          );
        }
      });
    }
  }

  testWidgets('los dos tramos siguen respondiendo y cambian la tarjeta',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: UnidadesListScreen(
          repository: repo,
          initialLanguage: AppLanguage.gl,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Arranca en 0-2, que es el primer tramo.
    expect(find.byKey(const ValueKey('tarxeta_fluxo_1c')), findsOneWidget);
    expect(
      find.text(TramoPrimeiroCiclo.lactantes0a2.etiquetaCorta.gl),
      findsWidgets,
    );

    // Al cambiar a 2-3, la tarjeta sigue siendo una sola y el material
    // cambia: el documento da una dinámica distinta por tramo, y si no
    // cambiara nada sería la misma sesión con otra etiqueta.
    final antes = tester
        .widgetList<Text>(find.descendant(
          of: find.byKey(const ValueKey('tarxeta_fluxo_1c')),
          matching: find.byType(Text),
        ))
        .map((t) => t.data)
        .join('|');

    await tester.tap(find.byKey(
        ValueKey('tramo_1c_${TramoPrimeiroCiclo.deambulantes2a3}')));
    await tester.pumpAndSettle();

    final despois = tester
        .widgetList<Text>(find.descendant(
          of: find.byKey(const ValueKey('tarxeta_fluxo_1c')),
          matching: find.byType(Text),
        ))
        .map((t) => t.data)
        .join('|');

    expect(find.byKey(const ValueKey('tarxeta_fluxo_1c')), findsOneWidget);
    expect(despois, isNot(equals(antes)),
        reason: 'Cambiar de tramo no cambió nada de la tarjeta');
  });
}

String why(AppLanguage lang, double escala) =>
    'ninguna etiqueta del grupo se recorta en ${lang.name} a escala $escala';
