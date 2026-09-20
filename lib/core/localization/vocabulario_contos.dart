import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'app_language.dart';

/// El vocabulario clave de las páginas del cuento, en las dos lenguas.
///
/// **Por qué existe.** `CuentoPagina.vocabularioClave` es una lista de cadenas
/// planas, no un `LocalizedString`: el banco lo trae solo en gallego. La
/// tarjeta del cuento enseñaba «Acollemento · Calma · Lúa · Vigo» igual en
/// gallego que en castellano, dentro de una pantalla por lo demás bilingüe.
///
/// La traducción vive en `assets/content/cuentos/vocabulario_gl_es.json`, no
/// aquí: el contenido va en JSON, nunca escrito en los widgets. Los nombres
/// propios —Vigo, Lúa, Castrelos— y las onomatopeyas no se traducen, y por eso
/// aparecen en el fichero con el mismo valor a los dos lados.
class VocabularioContos {
  static const String assetPath =
      'assets/content/cuentos/vocabulario_gl_es.json';

  static Map<String, String>? _glEs;

  /// Carga la tabla una vez. Si el fichero no está, la app sigue: el
  /// vocabulario se queda en gallego, que es lo que hacía antes.
  static Future<void> cargar() async {
    if (_glEs != null) return;
    try {
      final raw = await rootBundle.loadString(assetPath);
      final mapa = json.decode(raw) as Map<String, dynamic>;
      final palabras = mapa['palabras'] as Map<String, dynamic>? ?? const {};
      _glEs = palabras.map((k, v) => MapEntry(k, v.toString()));
    } catch (_) {
      _glEs = const {};
    }
  }

  /// La palabra tal y como debe leerse en [lang].
  ///
  /// Normaliza antes de buscar: el banco trae entradas con coma pegada
  /// («Outono,») y artículos sueltos («O», «A») de un corte mal hecho en el
  /// origen. Una coma no es vocabulario y un artículo suelto tampoco.
  static String? resolver(String bruta, AppLanguage lang) {
    final limpia = bruta.trim().replaceAll(RegExp(r'^[,.;:]+|[,.;:]+$'), '');
    if (limpia.length < 2) return null;
    if (lang == AppLanguage.gl) return limpia;
    return _glEs?[limpia] ?? limpia;
  }

  /// La lista entera de una página, ya limpia y en la lengua que toca.
  static List<String> lista(List<String> brutas, AppLanguage lang) {
    final salida = <String>[];
    for (final bruta in brutas) {
      final palabra = resolver(bruta, lang);
      if (palabra != null && !salida.contains(palabra)) salida.add(palabra);
    }
    return salida;
  }
}
