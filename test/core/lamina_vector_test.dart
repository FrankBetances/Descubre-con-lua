import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/core/brand/licenzas_terceiros.dart';

void main() {
  test('FormaLamina repite comandos implícitos en _parsearRuta', () {
    // Tras M, coordenadas sueltas se interpretan como L implícitas;
    // tras Q o C se repiten los argumentos correspondientes.
    final lamina = LaminaVectorial.desdeJson('''
    {
      "vb": 100,
      "formas": [
        {"t": "ruta", "d": "M10 10 90 10 90 90 10 90 Z", "f": "#e62828"},
        {"t": "ruta", "d": "M10 50 Q30 10 50 50 70 90 90 50", "s": "#334155", "sw": 3},
        {"t": "ruta", "d": "M10 20 C20 5 40 5 50 20 60 35 80 35 90 20", "s": "#2f6fd0", "sw": 2}
      ]
    }
    ''');

    final pPoligono = lamina.formas[0].aPath()!;
    expect(pPoligono.contains(const Offset(50, 50)), isTrue);
    expect(pPoligono.contains(const Offset(95, 50)), isFalse);

    final pQuad = lamina.formas[1].aPath()!;
    expect(pQuad.getBounds().right, closeTo(90, 0.5));

    final pCubic = lamina.formas[2].aPath()!;
    expect(pCubic.getBounds().right, closeTo(90, 0.5));
  });

  test('FormaLamina soporta fill-rule evenodd', () {
    // Cuadrado exterior [10..90] con hueco interior [30..70] en la misma dirección:
    // con evenOdd el centro (50, 50) queda vacío; con nonZero quedaría relleno.
    final lamina = LaminaVectorial.desdeJson('''
    {
      "vb": 100,
      "formas": [
        {
          "t": "ruta",
          "fr": "evenodd",
          "d": "M10 10 L90 10 L90 90 L10 90 Z M30 30 L70 30 L70 70 L30 70 Z",
          "f": "#ff851b"
        }
      ]
    }
    ''');

    final path = lamina.formas.single.aPath()!;
    expect(path.fillType, PathFillType.evenOdd);
    expect(path.contains(const Offset(20, 20)), isTrue);
    expect(path.contains(const Offset(50, 50)), isFalse);
  });

  test('registrarLicenzasTerceiros añade Fluent Emoji Flat e Iconify', () async {
    registrarLicenzasTerceiros();
    final entries = await LicenseRegistry.licenses.toList();
    final pkgs = entries.expand((e) => e.packages).toSet();
    expect(pkgs, contains('Microsoft Fluent Emoji (Flat)'));
    expect(pkgs, contains('Game Icons (game-icons.net)'));
    expect(pkgs, contains('Vocabulary Flashcard Dataset (dnizfor)'));
    expect(pkgs, contains('PB Image Bank (Pratham Books / StoryWeaver)'));
  });
}
