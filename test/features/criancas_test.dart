import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/criancas/xogo_lua.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import '../helpers/pasarela.dart';

/// O-20261109-1: el registro de cada niño en casa, el chip con su nombre,
/// varios niños y la pantalla de resultados.
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  final martes = DateTime(2026, 10, 6, 10);

  CriancasStore storeEnDisco(Directory dir) => CriancasStore(
      store: LocalStore(
          fileName: CriancasStore.nomeFicheiro, overrideDirectory: dir.path));

  Directory dir() {
    final d = Directory.systemTemp.createTempSync('criancas_');
    addTearDown(() => d.deleteSync(recursive: true));
    return d;
  }

  Future<void> abrir(WidgetTester tester, CriancasStore store,
      {AppLanguage lang = AppLanguage.gl}) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.temaFamilias,
      home: PortalFamiliasScreen(
        repository: p.contenido,
        audioService: p.audio,
        currentLanguage: lang,
        onToggleLanguage: () {},
        premios: p.premios,
        calendario: p.store,
        criancas: store,
        agora: martes,
      ),
    ));
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await Pasarela.asentar(tester);
  }

  testWidgets(
      'a primeira vez pide nome, idade e curso con Lúa; a segunda xa non',
      (tester) async {
    final d = dir();
    await abrir(tester, storeEnDisco(d));
    expect(find.byKey(const Key('rexistro_crianza')), findsOneWidget);
    expect(find.byKey(const Key('rexistro_privacidade')), findsOneWidget);
    // Sin nombre no se puede guardar.
    final boton = find.byKey(const Key('rexistro_gardar'));
    expect(tester.widget<FilledButton>(boton).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('rexistro_nome')), 'Breixo');
    await tester.tap(find.byKey(const ValueKey('rexistro_idade_3')));
    await tester.pump();
    // La edad propone su curso.
    expect(
        tester
            .widget<ChoiceChip>(
                find.byKey(const ValueKey('rexistro_curso_curso_3_4')))
            .selected,
        isTrue);
    await tester.runAsync(() async {
      await tester.tap(boton);
      await Future<void>.delayed(const Duration(milliseconds: 50));
    });
    await Pasarela.asentar(tester);

    expect(find.byKey(const Key('hoxe_familias')), findsOneWidget);
    expect(find.byKey(const Key('selector_nome')), findsOneWidget);
    expect(find.text('Breixo · '), findsOneWidget);
    expect(find.text('3-4 anos'), findsWidgets);

    // Otra vez, como al volver a abrir la app: sin registro, con Breixo.
    await tester.pumpWidget(const SizedBox());
    await abrir(tester, storeEnDisco(d));
    expect(find.byKey(const Key('rexistro_crianza')), findsNothing);
    expect(find.text('Breixo · '), findsOneWidget);
    expect(find.text('3-4 anos'), findsWidgets);
  });

  testWidgets('varios nenos: cambiar de neno, de curso e borrar',
      (tester) async {
    final store = CriancasStore.enMemoria(const [
      Crianza(id: 'c1', nome: 'Uxía', idade: 1, curso: 'curso_0_2'),
      Crianza(id: 'c2', nome: 'Antón', idade: 5, curso: 'curso_5_6'),
    ]);
    await abrir(tester, store);
    expect(find.text('Uxía · '), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('selector_idade')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('folla_crianza')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('crianza_c2')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('selector_nome')), findsOneWidget);
    expect(find.text('Antón · '), findsOneWidget);
    expect(find.text('5-6 anos'), findsWidgets);

    // Cambiar el curso desde la hoja lo guarda en el niño.
    await tester.tap(find.byKey(const ValueKey('selector_idade')));
    await Pasarela.asentar(tester);
    await tester.tap(find.byKey(const ValueKey('idade_curso_4_5')));
    await Pasarela.asentar(tester);
    expect(store.activa!.curso, 'curso_4_5');

    // Borrar a Antón deja a Uxía.
    await tester.tap(find.byKey(const ValueKey('selector_idade')));
    await Pasarela.asentar(tester);
    await tester.ensureVisible(find.byKey(const Key('crianza_borrar')));
    await tester.tap(find.byKey(const Key('crianza_borrar')));
    await Pasarela.asentar(tester);
    await tester.tap(find.byKey(const Key('crianza_borrar_si')));
    await Pasarela.asentar(tester);
    expect(store.criancas.map((c) => c.nome), ['Uxía']);
    expect(find.text('Uxía · '), findsOneWidget);
  });

  testWidgets(
      'resultados: Lúa, sen evolución inventada, e a observación da semana conta',
      (tester) async {
    final store = CriancasStore.enMemoria(const [
      Crianza(id: 'c1', nome: 'Uxía', idade: 4, curso: 'curso_4_5'),
    ]);
    await abrir(tester, store, lang: AppLanguage.es);

    await tester.tap(find.byKey(const ValueKey('selector_idade')));
    await Pasarela.asentar(tester);
    await tester.tap(find.byKey(const Key('crianza_resultados')));
    await Pasarela.asentar(tester);

    expect(find.byKey(const Key('tarxeta_lua')), findsOneWidget);
    expect(find.text('Resultados de Uxía'), findsOneWidget);
    // Sin marcas: ni una cifra que no exista, y la evolución lo dice.
    expect(
        find.descendant(
            of: find.byKey(const Key('resultados_entende')),
            matching: find.text('0')),
        findsOneWidget);
    final lista = find
        .descendant(
            of: find.byKey(const Key('resultados_crianza')),
            matching: find.byType(Scrollable))
        .first;
    await tester.scrollUntilVisible(
        find.textContaining('Todavía no has marcado ninguna palabra'), 300,
        scrollable: lista);
    expect(find.textContaining('Todavía no has marcado ninguna palabra'),
        findsOneWidget);

    // La primera palabra nueva de esta semana: «la dice».
    final opcion = find.byWidgetPredicate((w) =>
        w.key is ValueKey<String> &&
        (w.key as ValueKey<String>).value.endsWith('_di') &&
        (w.key as ValueKey<String>).value.startsWith('observar_'));
    expect(opcion, findsWidgets);
    await tester.ensureVisible(opcion.first);
    await tester.tap(opcion.first);
    await Pasarela.asentar(tester);

    expect(store.totais('c1'), (entende: 1, di: 1));
    expect(store.evolucion('c1'), hasLength(1));
    await tester.drag(
        find.byKey(const Key('resultados_crianza')), const Offset(0, 3000));
    await Pasarela.asentar(tester);
    expect(find.textContaining('Uxía ya entiende 1 palabra'), findsOneWidget);
    expect(find.textContaining('Todavía no has marcado ninguna palabra'),
        findsNothing);
    // Lo que hizo la persona adulta, con las medallas de premios.
    await tester.scrollUntilVisible(
        find.byKey(const Key('resultados_adulto')), 300,
        scrollable: find
            .descendant(
                of: find.byKey(const Key('resultados_crianza')),
                matching: find.byType(Scrollable))
            .first);
    expect(find.textContaining('Días de juego en casa'), findsOneWidget);
  });

  testWidgets('Guías leva aos resultados', (tester) async {
    await abrir(
        tester,
        CriancasStore.enMemoria(const [
          Crianza(id: 'c1', nome: 'Uxía', idade: 1, curso: 'curso_0_2'),
        ]));
    await tester.tap(find.byKey(const Key('pestana_guias')));
    await Pasarela.asentar(tester);
    await tester.tap(find.byKey(const ValueKey('guia_resultados')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('resultados_crianza')), findsOneWidget);
  });

  test('o que se observa persiste e borrar o neno bórrao todo', () async {
    final d = Directory.systemTemp.createTempSync('criancas_');
    addTearDown(() => d.deleteSync(recursive: true));
    final a = storeEnDisco(d);
    await a.cargar();
    final c = await a.engadir(nome: ' Iria ', idade: 2, curso: 'curso_2_3');
    final s = CriancasStore.semana('curso_2_3', 10, 1);
    await a.observar(c.id, s, 'leaf', Observacion.entende);
    await a.observar(c.id, s, 'tree', Observacion.di);

    final b = storeEnDisco(d);
    await b.cargar();
    expect(b.activa!.nome, 'Iria');
    expect(b.observacion(c.id, s, 'leaf'), Observacion.entende);
    expect(b.totais(c.id), (entende: 2, di: 1));

    await b.borrar(c.id);
    final raw =
        File('${d.path}/${CriancasStore.nomeFicheiro}').readAsStringSync();
    expect(raw.contains('Iria'), isFalse);
    expect(raw.contains('leaf'), isFalse);
  });

  testWidgets(
      'Lúa de Valeria en Hoy: xogar dá XP e a primeira insignia, e a folla de premios a mostra',
      (tester) async {
    final store = CriancasStore.enMemoria(const [
      Crianza(id: 'c1', nome: 'Uxía', idade: 4, curso: 'curso_4_5'),
    ]);
    await abrir(tester, store);
    final tarxeta = find.byKey(const Key('tarxeta_lua'));
    await tester.scrollUntilVisible(tarxeta, 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Nivel 1 · Gatiña'), findsOneWidget);
    expect(find.byKey(const Key('lua_racha')), findsOneWidget);

    await tester.ensureVisible(find.byKey(const Key('lua_acariciar')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('lua_acariciar')));
    await tester.pump();
    expect(find.text('Ronroneo!'), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));

    await tester.ensureVisible(find.byKey(const Key('lua_xogar')));
    await tester.tap(find.byKey(const Key('lua_xogar')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('recompensa_lua')), findsOneWidget);
    expect(find.text('Primeiro paso de Lúa'), findsOneWidget);
    expect(store.xogo('c1').xp, greaterThan(0));
    expect(store.xogo('c1').insignias, contains('primera'));
    await tester.tap(find.byKey(const Key('recompensa_continuar')));
    await Pasarela.asentar(tester);

    // Unha vez ao día.
    expect(
        tester
            .widget<FilledButton>(find.byKey(const Key('lua_xogar')))
            .onPressed,
        isNull);

    await tester.ensureVisible(find.byKey(const Key('lua_premios')));
    await tester.tap(find.byKey(const Key('lua_premios')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('premios_lua')), findsOneWidget);
    expect(find.text('INSIGNIAS · 1 DE 18'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Lazo Escarlata'), 300,
        scrollable: find
            .descendant(
                of: find.byKey(const Key('premios_lua')),
                matching: find.byType(Scrollable))
            .first);
    expect(find.text('Lazo Escarlata'), findsOneWidget);
  });

  test('o xogo de Valeria: racha, insignias e obxectos', () {
    final c = CatalogoLua.lido!;
    var g = const XogoLua();
    for (var d = 1; d <= 3; d++) {
      g = rexistrarSesion(g, c,
              agora: DateTime(2026, 10, d, 12),
              palabras: 2,
              media: 3,
              perfecta: true)
          .xogo;
    }
    expect(g.racha, 3);
    expect(g.insignias, containsAll(['primera', 'racha3', 'perfecta']));
    expect(
        g.obxectos, containsAll(['snack_fish', 'neck_red_bow', 'head_flower']));
    // El mismo día no suma dos veces.
    final mesmo = rexistrarSesion(g, c,
        agora: DateTime(2026, 10, 3, 18),
        palabras: 2,
        media: 3,
        perfecta: true);
    expect(mesmo.xogo.xp, g.xp);
    expect(mesmo.recompensa.xaXogouHoxe, isTrue);
  });

  testWidgets(
      'Learn de Duolingo: o nodo de hoxe abre a lección paso a paso e o fin dá XP',
      (tester) async {
    final store = CriancasStore.enMemoria(const [
      Crianza(id: 'c1', nome: 'Uxía', idade: 4, curso: 'curso_4_5'),
    ]);
    await abrir(tester, store);
    expect(find.byKey(const Key('learn_banner')), findsOneWidget);
    expect(find.byKey(const Key('learn_empezar')), findsOneWidget);
    expect(find.byKey(const Key('learn_xp')), findsOneWidget);

    // martes: o nodo de hoxe é o segundo.
    await tester.tap(find.byKey(const ValueKey('learn_nodo_1')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('leccion_progreso')), findsOneWidget);
    for (var i = 0; i < 20; i++) {
      if (find.byKey(const Key('leccion_fin')).evaluate().isNotEmpty) break;
      await tester.runAsync(() async {
        await tester.tap(find.byKey(const Key('leccion_continuar')));
        await Future<void>.delayed(const Duration(milliseconds: 20));
      });
      await Pasarela.asentar(tester);
    }
    expect(find.byKey(const Key('leccion_fin')), findsOneWidget);
    expect(find.byKey(const Key('leccion_fin_xp')), findsOneWidget);
    // XP, racha e premio de Lúa, como o fin de duolingo-clone.
    expect(
        find.descendant(
            of: find.byKey(const Key('leccion_fin_racha')),
            matching: find.text('1')),
        findsOneWidget);
    expect(find.text('Primeiro paso de Lúa'), findsOneWidget);
    expect(store.xogo('c1').xp, greaterThan(0));
    await tester.tap(find.byKey(const Key('leccion_continuar')));
    await Pasarela.asentar(tester);
    expect(find.byKey(const Key('learn_banner')), findsOneWidget);
  });
}
