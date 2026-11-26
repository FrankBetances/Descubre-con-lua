import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/criancas/reto_irmans.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import '../helpers/pasarela.dart';

void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  testWidgets(
      'M2: dous nenos con rutinas distintas ven só a súa rutina en Hoxe',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final store = CriancasStore.enMemoria(const [
      Crianza(
        id: 'c1',
        nome: 'Uxía',
        idade: 2,
        curso: 'curso_2_3',
        rutinas: ['bano'],
      ),
      Crianza(
        id: 'c2',
        nome: 'Antón',
        idade: 4,
        curso: 'curso_4_5',
        rutinas: ['parque'],
      ),
    ]);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.temaFamilias,
      home: PortalFamiliasScreen(
        repository: p.contenido,
        audioService: p.audio,
        currentLanguage: AppLanguage.gl,
        onToggleLanguage: () {},
        premios: p.premios,
        calendario: p.store,
        criancas: store,
        agora: DateTime(2026, 10, 7, 10),
      ),
    ));
    await Pasarela.asentar(tester);

    final lista = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('rutinas_fogar_card')),
      250,
      scrollable: lista,
    );
    expect(find.byKey(const Key('rutinas_fogar_card')), findsOneWidget);
    expect(find.byKey(const ValueKey('rutina_fogar_bano')), findsOneWidget);
    expect(find.byKey(const ValueKey('rutina_fogar_parque')), findsNothing);
    expect(find.textContaining('No baño'), findsWidgets);

    // Cambia a Antón (c2) na fila superior.
    await tester.ensureVisible(find.byKey(const ValueKey('hoxe_neno_c2')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('hoxe_neno_c2')));
    await Pasarela.asentar(tester);

    await tester.scrollUntilVisible(
      find.byKey(const Key('rutinas_fogar_card')),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byKey(const ValueKey('rutina_fogar_parque')), findsOneWidget);
    expect(find.byKey(const ValueKey('rutina_fogar_bano')), findsNothing);
    expect(find.textContaining('No parque'), findsWidgets);

    // Escoitar a rutina suma no contador M4 do neno activo.
    await tester
        .ensureVisible(find.byKey(const ValueKey('rutina_audio_parque')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('rutina_audio_parque')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      store.criancas.firstWhere((c) => c.id == 'c2').rutinas,
      const ['parque'],
    );
  });

  testWidgets(
      'M3: dous irmáns de 2-3 e 4-5 amosan Reto de irmáns con palabras dos dous cursos e gardan marca para ambos',
      (tester) async {
    tester.view.physicalSize = const Size(412, 915);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final agora = DateTime(2026, 10, 7, 10);
    final pezaEsperada = CatalogoRetoIrmans.lido!.paraCursos(
      'curso_2_3',
      'curso_4_5',
      mesCalendario: 10,
      semanaDoMes: 1,
    )!;
    // Cursos non veciños: usa a peza de 2-3 con 3-4.
    expect(pezaEsperada.cursoMenor, 'curso_2_3');
    expect(pezaEsperada.cursoMaior, 'curso_3_4');

    final store = CriancasStore.enMemoria(const [
      Crianza(
        id: 'c1',
        nome: 'Mateo',
        idade: 2,
        curso: 'curso_2_3',
        rutinas: ['bano'],
      ),
      Crianza(
        id: 'c2',
        nome: 'Sofía',
        idade: 4,
        curso: 'curso_4_5',
        rutinas: ['comida'],
      ),
    ]);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.temaFamilias,
      home: PortalFamiliasScreen(
        repository: p.contenido,
        audioService: p.audio,
        currentLanguage: AppLanguage.es,
        onToggleLanguage: () {},
        premios: p.premios,
        calendario: p.store,
        criancas: store,
        agora: agora,
      ),
    ));
    await Pasarela.asentar(tester);

    final lista = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.byKey(const Key('reto_irmans_card')),
      250,
      scrollable: lista,
    );
    expect(find.byKey(const Key('reto_irmans_card')), findsOneWidget);
    expect(find.text('Reto de hermanos'), findsOneWidget);
    // Mostra a palabra do pequeno (2-3) e a do maior (4-5).
    expect(
      find.textContaining(pezaEsperada.palabraMenor.en),
      findsWidgets,
    );
    expect(find.textContaining('Sofía (4-5 años):'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byKey(const Key('reto_irmans_gardar')),
      150,
      scrollable: lista,
    );
    await tester.ensureVisible(find.byKey(const Key('reto_irmans_gardar')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('reto_irmans_gardar')));
    await Pasarela.asentar(tester);

    // Unha vez por semana: pasa a insignia de feito e actualiza FSRS dos dous.
    expect(store.tarxetasDe('c1'), isNotEmpty);
    expect(store.tarxetasDe('c2'), isNotEmpty);
    await tester.scrollUntilVisible(
      find.byKey(const Key('reto_irmans_feito')),
      -200,
      scrollable: lista,
    );
    expect(find.byKey(const Key('reto_irmans_feito')), findsOneWidget);
  });
}
