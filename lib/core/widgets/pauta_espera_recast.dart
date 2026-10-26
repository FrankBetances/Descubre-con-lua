import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../localization/app_language.dart';
import '../localization/localized_string.dart';
import '../theme/app_theme.dart';

/// La línea de espera y recast de una frase inglesa (M7.2), según el tipo de
/// actividad: `dinamica`, `steam`, `lamina` o `xogo`. El texto vive en
/// `assets/content/registro/pautas_espera_recast.json`.
class PautaEsperaRecast extends StatelessWidget {
  final String tipo;
  final AppLanguage language;

  const PautaEsperaRecast({
    super.key,
    required this.tipo,
    required this.language,
  });

  static const asset = 'assets/content/registro/pautas_espera_recast.json';
  static Future<Map<String, (LocalizedString, LocalizedString)>>? _enCurso;

  static Map<String, (LocalizedString, LocalizedString)> fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    LocalizedString t(Object? v) =>
        LocalizedString.fromJson(Map<String, dynamic>.from(v as Map));
    return {
      for (final e in (j['pautas'] as Map).entries)
        e.key.toString(): (
          t((e.value as Map)['espera']),
          t((e.value as Map)['recast']),
        ),
    };
  }

  // Sin catchError: en un SynchronousFuture no completa nunca.
  static Future<Map<String, (LocalizedString, LocalizedString)>> cargar() =>
      _enCurso ??= rootBundle.loadString(asset).then(fromRaw,
          onError: (_) => <String, (LocalizedString, LocalizedString)>{});

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return FutureBuilder<Map<String, (LocalizedString, LocalizedString)>>(
      future: cargar(),
      builder: (context, snap) {
        final p = snap.data?[tipo];
        if (p == null) return const SizedBox.shrink();
        const corpo = TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
          height: 1.35,
        );
        Widget fila(String rotulo, LocalizedString texto) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(
                    text: '$rotulo: ',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  TextSpan(text: texto.resolve(language)),
                ]),
                style: corpo,
              ),
            );
        return Column(
          key: ValueKey('pauta_$tipo'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            fila(isGl ? 'Espera' : 'Espera', p.$1),
            fila('Recast', p.$2),
          ],
        );
      },
    );
  }
}
