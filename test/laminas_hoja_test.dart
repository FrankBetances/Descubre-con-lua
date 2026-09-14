@Tags(['capturas'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/lamina_pixel.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

/// La hoja de contacto de las láminas: todas juntas, para mirarlas de una vez.
///
/// Un set propio se juzga en conjunto, no pieza a pieza: es donde se ve si
/// comparten grosor, terminaciones y peso de color. Se corre a mano, como las
/// demás imágenes:
///
///     flutter test --tags capturas --update-goldens test/laminas_hoja_test.dart
void main() {
  testWidgets('hoja de contacto das láminas', (tester) async {
    final claves = Directory('assets/brand/laminas')
        .listSync()
        .whereType<File>()
        .map((f) => f.uri.pathSegments.last.replaceAll('.txt', ''))
        .toList()
      ..sort();

    tester.view.physicalSize = const Size(480, 780) * 2;
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);

    // Calentar: la lectura del paquete es E/S real y no avanza con el reloj
    // falso del test.
    for (final clave in claves) {
      await tester.pumpWidget(
          MaterialApp(home: Center(child: LaminaPixel(clave: clave))));
      await tester.pumpAndSettle();
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 40)));
      await tester.pumpAndSettle();
    }

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
}
