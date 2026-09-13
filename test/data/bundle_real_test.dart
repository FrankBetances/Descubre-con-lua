import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/widgets/aviso_contenido_ilegible.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/ritual_repository.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';

/// Lo que la app le pide al PAQUETE, pedido al paquete.
///
/// **El defecto que existe para que no vuelva.** `assets/content/calendario/`
/// no estaba en la lista `assets:` de pubspec.yaml. Flutter no entra en los
/// subdirectorios de una entrada, así que `meses.json` y `atencion.json` no
/// viajaban dentro del APK: `rootBundle.loadString` fallaba, no había
/// `catchError`, y el Calendario y la Guía se quedaban con el disco girando
/// para siempre. En el aparato, no en una rama.
///
/// Cincuenta y siete runs verdes pasaron por encima, por este patrón, que
/// estaba en TODOS los tests del calendario:
///
///     CalendarioContenido.cargar(stringLoader: (p) => File(p).readAsString())
///
/// Leer del árbol de trabajo demuestra que el JSON es correcto y no demuestra
/// NADA sobre lo que llega al aparato. Este fichero es el único que le
/// pregunta a `rootBundle`, que es lo que hace la app.
///
/// **Lo que este fichero NO cubre, dicho sin adornos.** Dentro de
/// `testWidgets` el reloj es falso, y el future que devuelve `rootBundle` se
/// completa en el zona real: su callback no llega nunca a correr por muchos
/// `pump` que se hagan. Así que aquí no se ejercita el `then` de `initState`
/// con una carga de verdad. Se ejercita, en tres piezas que juntas cubren el
/// fallo: que el bundle TIENE el fichero, que la pantalla pinta cuando el
/// contenido llega, y que ENSEÑA la avería cuando la carga falla —esta última
/// sí sobre el `initState` de verdad—.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('el paquete lleva el contenido del calendario', () {
    test('meses.json se lee del bundle y trae los diez meses', () async {
      final raw = await rootBundle.loadString(CalendarioContenido.mesesAsset);
      final meses = CalendarioContenido.desdeJsonMeses(raw);
      expect(meses, hasLength(10));
      expect(meses.first.orden, 1);
      expect(meses.last.orden, 10);
    });

    test('fases.json se lee del bundle y trae las seis fases', () async {
      // Mismo riesgo que el calendario: `assets/content/asamblea/` es un
      // directorio nuevo, y si se olvida en pubspec la consigna desaparece sin
      // que nadie se entere. Aquí se entera este test.
      final raw = await rootBundle.loadString(RitualAsamblea.asset);
      final ritual = RitualAsamblea.desdeJson(raw);
      expect(ritual.fases, hasLength(6));
      expect(ritual.minutosTotales, greaterThan(0));
      for (final fase in ritual.fases) {
        expect(fase.consigna.gl, isNotEmpty,
            reason: '${fase.clave} sen consigna en galego');
        expect(fase.consigna.es, isNotEmpty,
            reason: '${fase.clave} sin consigna en castellano');
      }
    });

    test('atencion.json se lee del bundle', () async {
      final raw =
          await rootBundle.loadString(CalendarioContenido.atencionAsset);
      final guia = CalendarioContenido.desdeJsonGuia(raw);
      expect(guia.tramos, isNotEmpty);
      expect(guia.reglas, isNotEmpty);
    });
  });

  group('con el contenido del paquete, las pantallas pintan', () {
    late CalendarioContenido contenido;

    setUpAll(() async {
      // Del BUNDLE, no de un File: si el asset no viajara, esto reventaría
      // aquí, que es donde se quiere que reviente.
      contenido = CalendarioContenido(
        meses: CalendarioContenido.desdeJsonMeses(
            await rootBundle.loadString(CalendarioContenido.mesesAsset)),
        guia: CalendarioContenido.desdeJsonGuia(
            await rootBundle.loadString(CalendarioContenido.atencionAsset)),
      );
    });

    testWidgets('el Calendario, sin disco girando', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CalendarioScreen(
          store: CalendarioStore(overrideDirectory: null),
          contenido: contenido,
          initialLanguage: AppLanguage.gl,
        ),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AvisoContenidoIlegible), findsNothing);
      expect(find.text('Calendario Escola · Fogar'), findsOneWidget);
    });

    testWidgets('la Guía de inglés en casa', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: GuiaAtencionScreen(
          contenido: contenido,
          initialLanguage: AppLanguage.gl,
        ),
      ));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AvisoContenidoIlegible), findsNothing);
    });
  });

  group('cuando el contenido NO se puede leer, se dice', () {
    tearDown(CalendarioContenido.olvidar);

    testWidgets('el Calendario enseña la avería en vez de girar',
        (tester) async {
      CalendarioContenido.sembrarFallo(Exception('asset ausente'));
      await tester.pumpWidget(MaterialApp(
        home: CalendarioScreen(
          store: CalendarioStore(overrideDirectory: null),
          initialLanguage: AppLanguage.gl,
        ),
      ));
      await tester.pump();

      expect(find.byType(AvisoContenidoIlegible), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('la Guía enseña la avería en vez de girar', (tester) async {
      CalendarioContenido.sembrarFallo(Exception('asset ausente'));
      await tester.pumpWidget(const MaterialApp(
        home: GuiaAtencionScreen(initialLanguage: AppLanguage.gl),
      ));
      await tester.pump();

      expect(find.byType(AvisoContenidoIlegible), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
