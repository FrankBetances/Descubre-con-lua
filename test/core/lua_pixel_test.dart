import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/brand/lua_pixel.dart';

void main() {
  // Este fichero existe por un fallo real: `assets/brand/` no estaba declarado
  // en pubspec.yaml. Hasta ahora esas rejillas solo las leía el script de Python
  // en tiempo de compilación, así que nunca se empaquetaron, y la primera
  // pantalla que quiso pintarlas se encontró sin ellas. En un aparato habría
  // fallado igual que en el test.
  //
  // LuaPixel falla en silencio a propósito —una mascota que falta no debe
  // tumbar la bienvenida—, y eso hace que ESTE fichero sea imprescindible: sin
  // él, quitar `assets/brand/` del pubspec no lo notaría nadie hasta ver la app.
  //
  // Se comprueba con rootBundle y no montando el widget: la carga es E/S real y
  // en flutter_test un `await` de E/S no avanza fuera de `runAsync`. Montar la
  // pantalla probaría el reloj del test; esto prueba el paquete.
  group('Las rejillas de Lúa viajan en el paquete', () {
    const ficheros = ['lua_head.txt', 'lua_sit.txt'];

    for (final fichero in ficheros) {
      testWidgets('$fichero se empaqueta y es una rejilla válida',
          (tester) async {
        await tester.runAsync(() async {
          final texto = await rootBundle.loadString('assets/brand/$fichero');
          final filas = texto
              .split('\n')
              .map((l) => l.trimRight())
              .where((l) => l.isNotEmpty && !l.startsWith('#'))
              .toList();

          expect(filas, isNotEmpty,
              reason: '$fichero no trae ninguna fila de rejilla.');

          // Todas las filas del mismo ancho: una fila corta deforma la gata.
          final ancho = filas.first.length;
          for (final f in filas) {
            expect(f.length, ancho,
                reason: 'En $fichero hay filas de ancho distinto.');
          }

          // Todo carácter tiene color o es transparente. Uno suelto sale como
          // un agujero en la gata y no lo ve nadie hasta mirarla.
          final paleta =
              await rootBundle.loadString('assets/brand/palette.json');
          final claves = RegExp(r'"(\w)"\s*:')
              .allMatches(paleta)
              .map((m) => m.group(1)!)
              .toSet()
            ..add('.');
          final usados = filas.join().split('').toSet();
          expect(usados.difference(claves), isEmpty,
              reason: '$fichero usa caracteres que no están en palette.json.');
        });
      });
    }

    testWidgets('LuaPixel ocupa su hueco y no lanza aunque no haya rejilla',
        (tester) async {
      // Sin runAsync la rejilla no llega a cargarse, que es justo el caso que
      // se quiere probar aquí: la pantalla tiene que aguantar igual.
      await tester.pumpWidget(
        const MaterialApp(home: Center(child: LuaPixel(size: 96))),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(LuaPixel), findsOneWidget);
      expect(tester.getSize(find.byType(LuaPixel)), const Size(96, 96));
    });
  });
}
