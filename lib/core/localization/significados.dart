import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'localized_string.dart';

/// El significado gl/es de las frases en inglés que no lo traen en su propio
/// contenido (F7). Lo usa el doble toque de `BotonEscuchar` cuando la pantalla
/// no le pasa uno. Vive en `assets/content/significados/significados.json`.
class Significados {
  Significados._();

  static const String assetPath =
      'assets/content/significados/significados.json';

  static Map<String, LocalizedString> _porFrase = const {};

  static Map<String, LocalizedString> fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    return {
      for (final e in (j['significados'] as Map<String, dynamic>).entries)
        e.key: LocalizedString.fromJson(Map<String, dynamic>.from(e.value)),
    };
  }

  /// Se lee una vez al arrancar. Si falla, el doble toque sigue funcionando
  /// en los botones que traen su significado.
  static Future<void> cargar() async {
    try {
      _porFrase = fromRaw(await rootBundle.loadString(assetPath));
    } catch (_) {}
  }

  static LocalizedString? de(String en) => _porFrase[en];

  @visibleForTesting
  static void sembrar(Map<String, LocalizedString> m) => _porFrase = m;
}
