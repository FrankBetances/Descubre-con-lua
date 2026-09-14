import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/brand/lamina_vector.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/core/theme/app_theme.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/features/juega/widgets/paso_conto_widget.dart';

/// Que cada página del cuento tenga su escena, y que la tarjeta la pinte.
///
/// Son dos cosas distintas y las dos se rompen calladas. Una página puede
/// perder su `lamina` en un JSON y nadie lo nota; y el widget puede dejar de
/// pedirla —un `if` mal puesto, un refactor— y la pantalla enseña el aviso de
/// «lámina pendente» como si el dibujo no existiera, cuando sí existe.
///
/// `check_bundled_assets.py` ya exige que el fichero exista y viaje. Aquí se
/// comprueba lo otro: que el contenido la declare y que la pantalla la use.
void main() {
  final unidades = Directory('assets/content/unidades')
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('as dez unidades declaran unha lámina por páxina do conto', () {
    expect(unidades.length, 10, reason: 'dez meses de curso, dez unidades');

    for (final fichero in unidades) {
      final unidade =
          json.decode(fichero.readAsStringSync()) as Map<String, dynamic>;
      final paxinas = (unidade['cuento'] as Map<String, dynamic>)['paginas']
          as List<dynamic>;
      expect(paxinas, hasLength(3), reason: '${fichero.path}: tres páxinas');

      for (var i = 0; i < paxinas.length; i++) {
        final clave =
            (paxinas[i] as Map<String, dynamic>)['lamina']?.toString() ?? '';
        expect(clave, isNotEmpty,
            reason: '${fichero.path}: a páxina ${i + 1} non ten lámina');

        final ficheiro = File('assets/brand/laminas/$clave.json');
        expect(ficheiro.existsSync(), isTrue, reason: 'falta $clave.json');

        // Apaisada de verdad: una escena metida en un cuadrado se encoge hasta
        // no distinguirse a dos metros, que es la distancia de la asamblea.
        final lamina = LaminaVectorial.desdeJson(ficheiro.readAsStringSync());
        expect(lamina.proporcion, greaterThan(1.2),
            reason: '$clave debería ser apaisada');
        expect(lamina.formas, isNotEmpty, reason: '$clave non ten formas');
      }
    }
  });

  testWidgets('a tarxeta do conto pide a escena da páxina', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: PasoContoWidget(
            cuento: const Cuento(
              titulo: LocalizedString(gl: 'Conto', es: 'Cuento'),
              paginas: [
                CuentoPagina(
                  orden: 1,
                  texto: LocalizedString(gl: 'Unha', es: 'Una'),
                  imagenAsset: '',
                  preguntaComprension: LocalizedString(gl: 'Que?', es: '¿Qué?'),
                  lamina: 'conto_mar_1',
                ),
              ],
            ),
            language: AppLanguage.gl,
            audioService: MockOfflineAudioService(),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    final escena = tester.widget<LaminaEscena>(find.byType(LaminaEscena));
    expect(escena.clave, 'conto_mar_1');
  });

  testWidgets('sen lámina, a tarxeta di que hai que ler o texto',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: SingleChildScrollView(
          child: PasoContoWidget(
            cuento: const Cuento(
              titulo: LocalizedString(gl: 'Conto', es: 'Cuento'),
              paginas: [
                CuentoPagina(
                  orden: 1,
                  texto: LocalizedString(gl: 'Unha', es: 'Una'),
                  imagenAsset: '',
                  preguntaComprension: LocalizedString(gl: 'Que?', es: '¿Qué?'),
                ),
              ],
            ),
            language: AppLanguage.gl,
            audioService: MockOfflineAudioService(),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(LaminaEscena), findsNothing);
    expect(find.textContaining('Lámina ilustrada pendente'), findsOneWidget);
  });
}
