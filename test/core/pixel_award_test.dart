import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/pixel_award.dart';

void main() {
  // Mismo motivo que `lua_pixel_test.dart`: PixelAward falla en silencio si
  // falta un fichero —una insignia que no está no debe tumbar la asamblea—, así
  // que sin este test, quitar `assets/brand/awards/` del pubspec no lo notaría
  // nadie hasta abrir la app. Ya pasó una vez con `assets/brand/`.
  group('Los glifos de insignia viajan en el paquete', () {
    testWidgets('los diez están, son 24×24 y usan colores que existen',
        (tester) async {
      await tester.runAsync(() async {
        final metaRaw =
            await rootBundle.loadString('assets/brand/awards/awards.json');
        final meta = json.decode(metaRaw) as Map<String, dynamic>;
        final paleta = (meta['paleta'] as Map<String, dynamic>).keys.toSet()
          ..addAll({'.', ' ', 'a', 'b'});
        final lado = (meta['lado'] as num).toInt();
        expect(lado, 24);

        // Los cinco metales y los diez núcleos: si falta uno, la insignia se
        // pinta en el gris de «sin ganar» y parece bloqueada para siempre.
        expect((meta['rangos'] as Map).keys.toSet(),
            AwardTier.values.map((t) => t.clave).toSet());
        expect((meta['nucleos'] as Map).keys.toSet(),
            AwardGlyph.values.map((g) => g.clave).toSet());

        for (final glyph in AwardGlyph.values) {
          final texto = await rootBundle
              .loadString('assets/brand/awards/${glyph.clave}.txt');
          final filas = texto
              .split('\n')
              .map((l) => l.trimRight())
              .where((l) => l.isNotEmpty)
              .toList();

          expect(filas.length, lado,
              reason: '${glyph.clave}.txt no tiene $lado filas.');
          for (final f in filas) {
            expect(f.length, lado,
                reason: '${glyph.clave}.txt tiene una fila de otro ancho.');
          }

          final usados = filas.join().split('').toSet();
          expect(usados.difference(paleta), isEmpty,
              reason: '${glyph.clave}.txt usa caracteres sin color.');
        }
      });
    });

    testWidgets('PixelAward ocupa su hueco y no lanza sin rejilla',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(child: PixelAward(glyph: AwardGlyph.pez, size: 40)),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PixelAward)), const Size(40, 40));
    });
  });

  group('El metal de la racha sube con los días', () {
    test('los cortes son 7, 14 y 30', () {
      expect(tierDeRacha(0), AwardTier.bronze);
      expect(tierDeRacha(6), AwardTier.bronze);
      expect(tierDeRacha(7), AwardTier.silver);
      expect(tierDeRacha(13), AwardTier.silver);
      expect(tierDeRacha(14), AwardTier.gold);
      expect(tierDeRacha(29), AwardTier.gold);
      expect(tierDeRacha(30), AwardTier.teal);
      // Una racha absurda no puede salirse de la escala.
      expect(tierDeRacha(9999), AwardTier.teal);
    });
  });
}
