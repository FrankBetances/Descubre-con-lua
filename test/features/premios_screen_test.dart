import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/premios/premios_screen.dart';

void main() {
  late Directory dir;
  late DateTime reloj;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('premios_screen_test');
    reloj = DateTime(2026, 3, 10, 9, 30);
  });

  tearDown(() {
    if (dir.existsSync()) dir.deleteSync(recursive: true);
  });

  /// Ojo con `runAsync`: leer el catálogo del paquete y escribir el progreso es
  /// E/S REAL, y dentro de `testWidgets` un `await` de E/S no avanza con el
  /// reloj falso. Sin esto el catálogo se quedaba en null para siempre y la
  /// pantalla no llegaba a pintarse nunca.
  Future<PremiosRepository> repo(WidgetTester tester) async {
    final r = PremiosRepository(
      store: LocalStore(fileName: 'premios.json', overrideDirectory: dir.path),
      ahora: () => reloj,
    );
    await tester.runAsync(() => r.cargar());
    return r;
  }

  Future<void> registrar(
    WidgetTester tester,
    PremiosRepository r,
    Perfil perfil,
    EventoPremio evento,
  ) =>
      tester.runAsync(() => r.registrar(perfil, evento));

  Widget pantalla(PremiosRepository r, AppLanguage lang) => MaterialApp(
        theme: AppTheme.lightTheme,
        home: PremiosScreen(repository: r, currentLanguage: lang),
      );

  testWidgets('sin actividad dice qué hacer, no un cero seco', (tester) async {
    final r = await repo(tester);
    await tester.pumpWidget(pantalla(r, AppLanguage.es));
    await tester.pumpAndSettle();

    // Un panel a cero sin explicación parece roto. Tiene que decir qué da la
    // primera insignia.
    expect(find.textContaining('Todavía no dirigiste'), findsOneWidget);
    expect(find.text('Insignias · 0 / 6'), findsOneWidget);
  });

  testWidgets('el nivel, la racha y el XP salen de lo que se hizo',
      (tester) async {
    final r = await repo(tester);
    for (var i = 0; i < 3; i++) {
      await registrar(tester, r, Perfil.docente, EventoPremio.asamblea);
      reloj = reloj.add(const Duration(days: 1));
    }

    await tester.pumpWidget(pantalla(r, AppLanguage.es));
    await tester.pumpAndSettle();

    final c = r.catalogo!;
    final p = r.progresoDe(Perfil.docente);
    expect(find.text('${p.rachaActual}'), findsOneWidget);
    expect(find.text('${p.xp(c)}'), findsOneWidget);
    expect(
      find.textContaining('Nivel ${p.nivelActual(c).nivel}'),
      findsOneWidget,
    );
  });

  testWidgets('el conmutador separa de verdad los dos recorridos',
      (tester) async {
    final r = await repo(tester);
    await registrar(tester, r, Perfil.docente, EventoPremio.asamblea);

    await tester.pumpWidget(pantalla(r, AppLanguage.es));
    await tester.pumpAndSettle();

    // Como maestra ya hay una asamblea: no sale el aviso de vacío.
    expect(find.textContaining('Todavía no dirigiste'), findsNothing);

    await tester.tap(find.text('Familia'));
    await tester.pumpAndSettle();

    // Como familia sigue todo a cero: lo de la maestra no le cuenta.
    expect(find.textContaining('Todavía no leíste'), findsOneWidget);
  });

  testWidgets('dice en pantalla que esto es del adulto', (tester) async {
    final r = await repo(tester);
    await tester.pumpWidget(pantalla(r, AppLanguage.es));
    await tester.pumpAndSettle();

    // La nota está al final de la lista, así que hay que bajar hasta ella: un
    // ListView no construye lo que no se ve, y buscarla sin desplazarse daría
    // «no está» aunque esté. Llegar hasta ella es además lo que haría una
    // persona, así que el test comprueba que SE PUEDE llegar.
    final nota = find.textContaining('no se guarda nada de ninguna criatura');
    await tester.dragUntilVisible(
      nota,
      find.byType(ListView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();

    // No es decoración: quien abra esto tiene que entender que no se está
    // midiendo a ninguna criatura.
    expect(nota, findsOneWidget);
  });

  for (final lang in AppLanguage.values) {
    testWidgets('cabe con la escala de texto grande en ${lang.code}',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final r = await repo(tester);
      await registrar(tester, r, Perfil.docente, EventoPremio.asamblea);

      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.lightTheme,
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
          child: PremiosScreen(repository: r, currentLanguage: lang),
        ),
      ));
      await tester.pumpAndSettle();

      final errores = <Object>[];
      while (true) {
        final e = tester.takeException();
        if (e == null) break;
        errores.add(e);
      }
      expect(errores, isEmpty,
          reason: 'Los premios desbordan con la escala de texto grande en '
              '${lang.code}.');
    });
  }
}
