import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/brand/imaxe_escena.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/features/calendario/widgets/palabras_do_dia.dart';

/// O-20261111-2 (A3): la tarjeta de palabras del día pinta la lámina de la
/// palabra encima de ella, con su etiqueta para el lector de pantalla en la
/// lengua de la app.
void main() {
  const crab = TprWord(
    id: 'crab',
    en: 'Crab',
    gl: 'Cangrexo',
    es: 'Cangrejo',
    tprAction: LocalizedString(gl: 'Andar de lado', es: 'Andar de lado'),
    category: 'noun',
    lamina: 'pal_crab',
  );

  for (final (lang, etiqueta) in [
    (AppLanguage.gl, 'Imaxe: Cangrexo'),
    (AppLanguage.es, 'Imagen: Cangrejo'),
  ]) {
    testWidgets('a palabra do día leva a súa lámina (${lang.code})',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: AppTheme.temaFamilias,
        home: Scaffold(
          body: PalabraConXesto(
            palabra: crab,
            language: lang,
            audioService: MockOfflineAudioService(),
          ),
        ),
      ));
      await tester.pump();
      expect(find.byType(LaminaPalabra), findsOneWidget);
      expect(find.bySemanticsLabel(etiqueta), findsOneWidget);
    });
  }
}
