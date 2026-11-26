import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/criancas/proba_entrada.dart';
import 'package:descubre_con_lua/features/criancas/proba_entrada_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';

import '../helpers/pasarela.dart';

void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  test('catálogo proba_entrada: 4 cursos, 6 peldaños, 3 ítems cada uno y STEAM',
      () {
    final cat = CatalogoProbaEntrada.lido!;
    for (final c in const [
      'curso_2_3',
      'curso_3_4',
      'curso_4_5',
      'curso_5_6',
    ]) {
      final items = cat.itemsDoCurso(c);
      expect(items, hasLength(18));
      for (var pel = 1; pel <= 6; pel++) {
        final doPeldano = items.where((x) => x.peldano == pel).toList();
        expect(doPeldano, hasLength(3));
        for (final it in doPeldano) {
          expect(it.steamTitulo.gl, isNotEmpty);
          expect(it.steamTitulo.es, isNotEmpty);
          expect(it.experimentoParte.gl, isNotEmpty);
          expect(it.lamina, isNotEmpty);
          expect(it.palabrasSemente, isNotEmpty);
        }
      }
    }
  });

  test('árbol de decisión: 5 trayectorias y siembra de repaso FSRS', () async {
    final cat = CatalogoProbaEntrada.lido!;
    final items = cat.itemsDoCurso('curso_3_4');

    // 1) 3 fallos seguidos desde el principio -> para en el ítem 3, peldaño 1, sin siembra.
    final t1 = CatalogoProbaEntrada.avaliar(items, const [
      Observacion.aindaNon,
      Observacion.aindaNon,
      Observacion.aindaNon,
      Observacion.di, // ignorado porque ya paró
    ]);
    expect(t1.terminada, isTrue);
    expect(t1.parouPorTresFallos, isTrue);
    expect(t1.peldano, 1);
    expect(t1.semente, isEmpty);

    // 2) Supera peldaños 1 y 2 (2/3 y 3/3) y falla 3 seguidos en peldaño 3 -> peldaño 2.
    final t2 = CatalogoProbaEntrada.avaliar(items, const [
      Observacion.entende, Observacion.aindaNon,
      Observacion.entende, // pel 1: 2/3
      Observacion.di, Observacion.entende, Observacion.entende, // pel 2: 3/3
      Observacion.aindaNon, Observacion.aindaNon,
      Observacion.aindaNon, // pel 3: para
    ]);
    expect(t2.terminada, isTrue);
    expect(t2.parouPorTresFallos, isTrue);
    expect(t2.peldano, 2);
    expect(t2.semente, isNotEmpty);

    // 3) Comprende todo 1-3, dice 2/3 en peldaño 4, solo entende (no dice) 3 seguidos en 5 -> peldaño 4.
    final t3 = CatalogoProbaEntrada.avaliar(items, const [
      Observacion.entende, Observacion.entende, Observacion.entende, // 1
      Observacion.entende, Observacion.entende, Observacion.entende, // 2
      Observacion.entende, Observacion.entende, Observacion.entende, // 3
      Observacion.di, Observacion.di, Observacion.entende, // 4: 2/3 di
      Observacion.entende, Observacion.entende,
      Observacion.entende, // 5: 3 fallos seguidos de expresión
    ]);
    expect(t3.terminada, isTrue);
    expect(t3.parouPorTresFallos, isTrue);
    expect(t3.peldano, 4);
    expect(t3.semente.containsValue(Observacion.entende), isTrue);
    expect(t3.semente.containsValue(Observacion.di), isTrue);

    // 4) No acumula 3 fallos seguidos al pasar peldaño 1 (2/3) y corta justo en 2 fallos de peldaño 2 + 1 del 3.
    final t4 = CatalogoProbaEntrada.avaliar(items, const [
      Observacion.entende, Observacion.aindaNon, Observacion.entende, // 1: 2/3
      Observacion.entende, Observacion.aindaNon,
      Observacion.aindaNon, // 2: 1/3 (2 fallos)
      Observacion.aindaNon, // 3: 3er fallo seguido -> para
    ]);
    expect(t4.terminada, isTrue);
    expect(t4.parouPorTresFallos, isTrue);
    expect(t4.peldano, 1);

    // 5) Domina los 6 peldaños (2/3 en el último también) -> peldaño 6 sin parar por fallos.
    final t5 = CatalogoProbaEntrada.avaliar(items, const [
      Observacion.di, Observacion.di, Observacion.di, // 1
      Observacion.di, Observacion.di, Observacion.di, // 2
      Observacion.di, Observacion.di, Observacion.di, // 3
      Observacion.di, Observacion.di, Observacion.di, // 4
      Observacion.di, Observacion.di, Observacion.di, // 5
      Observacion.di, Observacion.aindaNon, Observacion.di, // 6: 2/3
    ]);
    expect(t5.terminada, isTrue);
    expect(t5.parouPorTresFallos, isFalse);
    expect(t5.peldano, 6);

    // Siembra FSRS tras completar: tarjetas sembradas con fecha futura (sin bloquear «Volven hoxe» el día 1).
    final agora = DateTime(2026, 11, 16);
    final store = CriancasStore.enMemoria(const [
      Crianza(
        id: 'c1',
        nome: 'Brais',
        idade: 3,
        curso: 'curso_3_4',
        probaCompletada: false,
      ),
    ]);
    await store.completarProba(
      'c1',
      peldano: t3.peldano,
      semente: t3.semente,
      agora: agora,
    );
    expect(store.criancas.single.peldano, 4);
    expect(store.criancas.single.probaCompletada, isTrue);
    expect(store.tarxetasDe('c1'), isNotEmpty);
    expect(store.tarxetasVencidas('c1', agora: agora), isEmpty);
  });

  testWidgets(
    'Alta única: proba sae unha vez, reanúdase se se interrompe e non sae na folla',
    (tester) async {
      final agora = DateTime(2026, 11, 16, 10);
      // Niño dado de alta con 2 respuestas guardadas y la prueba aún sin terminar.
      final store = CriancasStore.enMemoria(const [
        Crianza(
          id: 'c1',
          nome: 'Uxía',
          idade: 3,
          curso: 'curso_3_4',
          peldano: 1,
          probaCompletada: false,
          probaRespostas: [1, 1],
        ),
      ]);

      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.temaFamilias,
          home: PortalFamiliasScreen(
            repository: p.contenido,
            audioService: p.audio,
            currentLanguage: AppLanguage.gl,
            onToggleLanguage: () {},
            premios: p.premios,
            calendario: p.store,
            criancas: store,
            agora: agora,
          ),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await Pasarela.asentar(tester);

      // Hasta acabarla, el niño empieza en el peldaño 1 y Hoxe ofrece reanudarla.
      expect(store.criancas.single.peldano, 1);
      expect(
          find.byKey(const Key('retomar_proba_entrada_card')), findsOneWidget);
      expect(find.textContaining('2/18'), findsOneWidget);

      await tester.tap(find.byKey(const Key('retomar_proba_entrada')));
      await Pasarela.asentar(tester);
      // Reanuda directamente en el ítem 3 de 18 (paso 1).
      expect(find.textContaining('(3/18)'), findsOneWidget);

      // Si completamos el peldaño 1 (3/3) y hacemos 3 fallos seguidos en peldaño 2 -> acaba en peldaño 1.
      await tester.tap(find.byKey(const Key('proba_entende')));
      await Pasarela.asentar(tester);
      // En peldaño 2 (4/18), responde «Di» a los 3 ítems -> sube a peldaño 2.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('proba_di')));
        await Pasarela.asentar(tester);
      }
      // En peldaño 3 (7/18), 3 fallos seguidos -> para automáticamente.
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.byKey(const Key('proba_aindaNon')));
        await Pasarela.asentar(tester);
      }

      expect(find.byKey(const Key('proba_resumo')), findsOneWidget);
      expect(store.criancas.single.peldano, 2);
      expect(store.criancas.single.probaCompletada, isTrue);
      expect(store.criancas.single.probaRespostas, isEmpty);

      await tester.tap(find.byKey(const Key('proba_rematar')));
      await Pasarela.asentar(tester);

      // Al volver a Hoxe, ya no aparece nunca más el bloque de reanudar.
      expect(find.byKey(const Key('retomar_proba_entrada_card')), findsNothing);

      // Y la hoja del chip NO ofrece repetir la prueba.
      await tester.tap(find.byKey(const Key('selector_idade')));
      await Pasarela.asentar(tester);
      expect(find.byKey(const Key('folla_crianza')), findsOneWidget);
      expect(find.textContaining('por onde empezar'), findsNothing);
      await tester.tapAt(const Offset(10, 10));
      await Pasarela.asentar(tester);
    },
  );

  testWidgets('proba de entrada: 0-2 no faina e widget en es completo',
      (tester) async {
    expect(
      CatalogoProbaEntrada.debeFacerProba(
        const Crianza(
          id: 'c0',
          nome: 'Sabela',
          idade: 1,
          curso: 'curso_0_2',
          probaCompletada: false,
        ),
      ),
      isFalse,
    );

    final store = CriancasStore.enMemoria(const [
      Crianza(
        id: 'c2',
        nome: 'Mateo',
        idade: 4,
        curso: 'curso_4_5',
        probaCompletada: false,
      ),
    ]);
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.temaFamilias,
        home: ProbaEntradaScreen(
          store: store,
          crianza: store.criancas.single,
          language: AppLanguage.es,
          audioService: p.audio,
        ),
      ),
    );
    await Pasarela.asentar(tester);

    expect(find.byKey(const Key('proba_titulo')), findsOneWidget);
    expect(
        find.text('Juego de Lúa para saber por dónde empezar'), findsOneWidget);
    expect(find.byKey(const Key('proba_steam')), findsOneWidget);
  });
}
