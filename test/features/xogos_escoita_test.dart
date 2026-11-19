import 'dart:io';
import 'dart:math' as math;

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/escoita_model.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_escoita_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// O-20261119-8: los juegos de escucha de Valeria, en casa.
void main() {
  final bancos = {
    for (final l in [AppLanguage.gl, AppLanguage.es])
      l: BancoEscoita.fromRaw(
          File(BancoEscoita.assetPath(l)).readAsStringSync()),
  };
  setUpAll(() => bancos.forEach(BancoEscoita.sembrar));

  test('o banco de Valeria, enteiro: 13 pares en galego e 15 en castelán', () {
    expect(bancos[AppLanguage.gl]!.pares, hasLength(13));
    expect(bancos[AppLanguage.es]!.pares, hasLength(15));
    for (final b in bancos.values) {
      expect(b.progresions, hasLength(9));
      expect(b.capsulas, hasLength(8));
      expect(b.escenarios, hasLength(5));
      expect(b.categorias, hasLength(5));
    }
  });

  for (final lang in [AppLanguage.gl, AppLanguage.es]) {
    testWidgets('as cinco seccións, en ${lang.code}', (t) async {
      await t.pumpWidget(MaterialApp(
          home: XogosEscoitaScreen(language: lang, onLanguageChanged: (_) {})));
      await t.pumpAndSettle();
      for (final k in [
        'escoita_pares',
        'escoita_progresions',
        'escoita_capsulas',
        'escoita_escenarios',
        'escoita_categorias',
      ]) {
        await t.scrollUntilVisible(find.byKey(Key(k)), 200);
        expect(find.byKey(Key(k)), findsOneWidget);
      }
    });
  }

  testWidgets('xogo do par: acerto dá a misión; erro dá a pista', (t) async {
    final par = bancos[AppLanguage.es]!.pares.first; // rana · lana
    await t.pumpWidget(MaterialApp(
        home: XogoPar(
            par: par,
            lang: AppLanguage.es,
            audio: null,
            azar: math.Random(1))));
    await t.tap(find.byKey(const Key('escoita_escoitar')));
    await t.pump();
    final dita = math.Random(1).nextBool() ? par.a : par.b;
    final outra = identical(dita, par.a) ? par.b : par.a;
    await t.tap(
        find.byKey(Key(identical(dita, par.a) ? 'escoita_a' : 'escoita_b')));
    await t.pump();
    expect(find.text(par.misionAcerto), findsOneWidget);
    await t.tap(
        find.byKey(Key(identical(outra, par.a) ? 'escoita_a' : 'escoita_b')));
    await t.pump();
    expect(find.text(par.pista), findsOneWidget);
    expect(find.text(par.misionFallo), findsOneWidget);
  });
}
