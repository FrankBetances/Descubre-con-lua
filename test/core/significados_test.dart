import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/widgets/boton_escuchar.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/significados.dart';

/// F7: todo botón en inglés dice su significado con dos toques. Si la pantalla
/// no se lo pasa, sale del diccionario de significados.
void main() {
  final dic = Significados.fromRaw(
      File('assets/content/significados/significados.json').readAsStringSync());

  test('ninguna frase inglesa del corpus de voz se queda sin significado', () {
    final corpus = (jsonDecode(File('voice-corpus.json').readAsStringSync())
        as Map)['corpus'] as List;
    final conSignificado = <String>{
      for (final e in corpus)
        if ((e['source'] as String).endsWith('/significado'))
          (e['source'] as String).replaceFirst(RegExp(r'/significado$'), ''),
    };
    final sinNada = <String>{
      for (final e in corpus)
        if (e['lang'] == 'en' &&
            !conSignificado.contains(e['source']) &&
            !(e['source'] as String).startsWith('corpus') &&
            !(e['source'] as String).startsWith('curriculo') &&
            !(e['source'] as String).startsWith('biblioteca') &&
            !dic.containsKey(e['text']))
          e['text'] as String,
    };
    expect(sinNada, isEmpty);
  });

  test('cada significado trae gallego y castellano', () {
    for (final e in dic.entries) {
      expect(e.value.gl.trim(), isNotEmpty, reason: e.key);
      expect(e.value.es.trim(), isNotEmpty, reason: e.key);
    }
  });

  for (final lang in AppLanguage.deInterfaz) {
    testWidgets(
        'dos toques sin significado propio: el del diccionario, ${lang.code}',
        (tester) async {
      Significados.sembrar(dic);
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BotonEscuchar(
            audioService: MockOfflineAudioService(),
            texto: 'Show me!',
            language: AppLanguage.en,
            interfaz: lang,
            comoChip: true,
          ),
        ),
      ));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pumpAndSettle();
      final chip = find.byType(InkWell).first;
      await tester.tap(chip);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(chip);
      await tester.pumpAndSettle();
      expect(find.text('Show me!: ${dic['Show me!']!.resolve(lang)}'),
          findsOneWidget);
    });
  }
}
