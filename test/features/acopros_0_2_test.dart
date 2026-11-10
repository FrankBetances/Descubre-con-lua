import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/features/leccions/widgets/proxecto_0_2.dart';
import '../helpers/pasarela.dart';

/// O-20261109-4 (ACOPROS): 0-2 años por proyectos y sin gramática.
void main() {
  final p = Pasarela();
  setUpAll(p.cargar);
  tearDownAll(p.limpar);

  int elementos(String en) => en
      .replaceAll(RegExp(r'[!?.…]'), '')
      .split(RegExp(r'[\s,/]+'))
      .where((t) => t.isNotEmpty)
      .length;

  test(
      'os 10 proxectos: unhas 20 palabras, dous elementos como moito, sen to be',
      () {
    final ps = Proxectos02.lidos!.proxectos;
    expect(ps, hasLength(10));
    for (final pr in ps) {
      expect(pr.palabras.length, inInclusiveRange(18, 22));
      for (final w in pr.palabras) {
        expect(elementos(w.en), lessThanOrEqualTo(2), reason: w.en);
        expect(RegExp(r'\b(is|are|am)\b', caseSensitive: false).hasMatch(w.en),
            isFalse,
            reason: w.en);
      }
      for (final f in pr.comoFalar) {
        expect(elementos(f), lessThanOrEqualTo(2), reason: f);
        expect(pr.palabra(f), isNotNull, reason: 'presentada antes: $f');
      }
      for (final x in pr.xaSabe) {
        expect(elementos(x), 1, reason: x);
      }
      expect(pr.semanas.first.fase.es, contains('canción'));
      expect(pr.rimaEn, isNotEmpty);
    }
  });

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets('Hoxe 0-2 (${lang.code}): o proxecto, sen a gramática',
        (tester) async {
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
          criancas: CriancasStore.enMemoria(const [
            Crianza(id: 'c1', nome: 'Uxía', idade: 1, curso: 'curso_0_2'),
          ]),
          agora: DateTime(2026, 10, 6, 10),
        ),
      ));
      await Pasarela.asentar(tester);
      final lista = find.byType(Scrollable).first;
      await tester.scrollUntilVisible(
          find.byKey(const Key('proxecto_0_2')), 300,
          scrollable: lista);
      expect(find.byKey(const Key('proxecto_0_2')), findsOneWidget);
      // Sen gramática: nin a franxa das 48 unidades nin a frase da unidade.
      expect(find.byKey(const Key('leccion_ruta_gramatica')), findsNothing);
      expect(find.byKey(const Key('leccion_gramatica')), findsNothing);
      for (final k in [
        'proxecto_semana',
        'proxecto_cancion',
        'proxecto_rima',
        'proxecto_como_falar',
        'proxecto_xa_sabe',
        'proxecto_guia',
      ]) {
        await tester.scrollUntilVisible(find.byKey(Key(k)), 200,
            scrollable: lista);
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
    });
  }
}
