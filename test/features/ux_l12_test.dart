import 'package:flutter/gestures.dart' show kDoubleTapTimeout;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/voice_id.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/features/calendario/widgets/palabras_do_dia.dart';

/// Lote L12: as palabras inglesas tampouco as saben as familias. Un toque na
/// pastilla dia a palabra en inglés; dous toques, o que quere dicir, na lingua
/// da app.
void main() {
  const hop = TprWord(
    id: 'hop',
    en: 'Hop',
    gl: 'Pé coxo',
    es: 'Pata coja',
    tprAction: LocalizedString(gl: 'Saltar', es: 'Saltar'),
    category: 'verb',
  );

  Future<MockOfflineAudioService> abrir(
      WidgetTester tester, AppLanguage lang) async {
    final audio = MockOfflineAudioService();
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.temaFamilias,
      home: Scaffold(
        body:
            PalabraConXesto(palabra: hop, language: lang, audioService: audio),
      ),
    ));
    await tester.pumpAndSettle();
    return audio;
  }

  for (final lang in AppLanguage.deInterfaz) {
    final gl = lang == AppLanguage.gl;

    testWidgets('un toque: en inglés (${lang.code})', (tester) async {
      final audio = await abrir(tester, lang);
      await tester.tap(find.text('Hop'));
      await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      expect(audio.currentAssetPath,
          voiceAssetPath(estiloIngles('Hop'), 'Hop', AppLanguage.en));
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('dous toques: o significado (${lang.code})', (tester) async {
      final audio = await abrir(tester, lang);
      await tester.tap(find.text('Hop'));
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tap(find.text('Hop'));
      await tester.pumpAndSettle();
      // Escrito sempre; a voz, cando a grabación está no paquete.
      expect(find.text(gl ? 'Hop: Pé coxo' : 'Hop: Pata coja'), findsOneWidget);
      expect(audio.currentAssetPath,
          isNot(voiceAssetPath(estiloIngles('Hop'), 'Hop', AppLanguage.en)));
    });
  }
}
