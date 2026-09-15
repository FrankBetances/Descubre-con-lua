@Tags(['capturas'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/lamina_pixel.dart';
import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

/// La hoja de contacto de las láminas: todas juntas, para mirarlas de una vez.
///
/// Un set propio se juzga en conjunto, no pieza a pieza: es donde se ve si
/// comparten grosor, terminaciones y peso de color. Se corre a mano, como las
/// demás imágenes:
///
///     flutter test --tags capturas --update-goldens test/laminas_hoja_test.dart
///
/// Son DOS hojas, no una. Las del vocabulario son objetos cuadrados y las del
/// cuento son escenas apaisadas: mezcladas en la misma rejilla no se puede
/// juzgar ninguna de las dos.
List<String> _claves({required bool conto}) => Directory('assets/brand/laminas')
    .listSync()
    .whereType<File>()
    .map((f) => f.uri.pathSegments.last)
    .map((n) => n.replaceAll('.txt', '').replaceAll('.json', ''))
    .where((n) => n.startsWith('conto_') == conto)
    .toSet()
    .toList()
  ..sort();

/// La lectura del paquete es E/S real: no avanza con el reloj falso del test,
/// así que hay que darle un turno de verdad antes de pintar la hoja.
Future<void> _calentar(WidgetTester tester, List<String> claves) async {
  for (final clave in claves) {
    await tester.pumpWidget(
        MaterialApp(home: Center(child: LaminaPixel(clave: clave))));
    await tester.pumpAndSettle();
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 40)));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('hoja de contacto das láminas', (tester) async {
    final claves = _claves(conto: false);

    tester.view.physicalSize = const Size(560, 1560) * 2;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await _calentar(tester, claves);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final clave in claves)
                SizedBox(
                  width: 104,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      LaminaPixel(clave: clave, size: 88),
                      Text(clave, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('../docs/capturas/laminas-hoja.png'));
  });

  testWidgets('hoja de contacto das escenas do conto', (tester) async {
    final claves = _claves(conto: true);
    expect(claves.length, 30,
        reason: 'dez unidades por tres páxinas: trinta escenas');

    tester.view.physicalSize = const Size(820, 1980) * 2;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    await _calentar(tester, claves);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Padding(
          padding: const EdgeInsets.all(14),
          child: Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              for (final clave in claves)
                SizedBox(
                  width: 252,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Con el mismo recorte redondeado que la tarjeta del
                      // cuento: el borde es lo que hace que una escena apaisada
                      // se lea como una lámina y no como un fondo suelto.
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LaminaEscena(clave: clave, ancho: 252),
                      ),
                      Text(clave, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('../docs/capturas/laminas-conto-hoja.png'));
  });
}
