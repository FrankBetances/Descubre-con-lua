import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/audio/voice_id.dart';
import 'package:descubre_con_lua/core/audio/widgets/boton_escuchar.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';

void main() {
  Widget montar({
    required String texto,
    MockOfflineAudioService? servicio,
    AppLanguage lang = AppLanguage.gl,
    VoiceStyle style = VoiceStyle.tutor,
    bool compacto = false,
  }) =>
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Center(
            child: BotonEscuchar(
              audioService: servicio,
              texto: texto,
              language: lang,
              style: style,
              compacto: compacto,
            ),
          ),
        ),
      );

  group('El botón no miente sobre lo que puede sonar', () {
    testWidgets('sin grabación no se pinta, ni siquiera apagado',
        (tester) async {
      final servicio = MockOfflineAudioService();
      addTearDown(servicio.dispose);

      await tester.runAsync(() async {
        await tester.pumpWidget(montar(
          texto: 'Unha frase que non ten gravación ningunha neste paquete.',
          servicio: servicio,
        ));
      });
      await tester.pumpAndSettle();

      // Una tarjeta con un altavoz que no suena es peor que una sin altavoz:
      // promete algo y no lo cumple.
      expect(find.byIcon(Icons.volume_up_rounded), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('con grabación se pinta y reproduce ESA grabación',
        (tester) async {
      final servicio = MockOfflineAudioService();
      addTearDown(servicio.dispose);

      // Una locución que sí está en el paquete: la palabra de vocabulario
      // «Barco», grabada despacio en galego.
      const palabra = 'Barco';
      final ruta = voiceAssetPath(VoiceStyle.slow, palabra, AppLanguage.gl);

      await tester.runAsync(() async {
        await tester.pumpWidget(montar(
          texto: palabra,
          servicio: servicio,
          style: VoiceStyle.slow,
        ));
      });
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget,
          reason: 'La grabación $ruta existe: el botón tiene que estar.');

      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();

      // La ruta sale del TEXTO, no de un campo aparte: por eso es imposible
      // que la tarjeta enseñe una frase y suene otra.
      expect(servicio.currentAssetPath, ruta);
    });

    testWidgets('sin servicio de audio tampoco se pinta', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(montar(texto: 'Calquera cousa'));
      });
      await tester.pumpAndSettle();
      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('La ruta se deriva del texto', () {
    test('cambiar una letra cambia la grabación', () {
      final a = voiceAssetPath(VoiceStyle.tutor, 'Ola mundo', AppLanguage.gl);
      final b = voiceAssetPath(VoiceStyle.tutor, 'Ola mundu', AppLanguage.gl);
      expect(a, isNot(b));
    });

    test('las dos lenguas y los dos ritmos no comparten fichero', () {
      const t = 'Barco';
      expect(
        voiceAssetPath(VoiceStyle.slow, t, AppLanguage.gl),
        isNot(voiceAssetPath(VoiceStyle.slow, t, AppLanguage.es)),
      );
      expect(
        voiceAssetPath(VoiceStyle.slow, t, AppLanguage.gl),
        isNot(voiceAssetPath(VoiceStyle.tutor, t, AppLanguage.gl)),
      );
    });
  });
}
