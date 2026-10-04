import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import '../loaders/content_asset_loader.dart';
import 'lectura_model.dart';

/// «Que observar» de cada juego de «Xogos e Dinámicas no Fogar», por id.
///
/// Vive en `assets/content/xogos_fogar_observar.json` y no en el widget, como
/// pide la regla de contenido. Sustituye al registro «Logrado · Asistido ·
/// Explorando», que pedía a la familia evaluar a su criatura y no guardaba
/// nada.
@immutable
class ObservacionsXogosFogar {
  final Map<String, List<LocalizedString>> porXogo;

  const ObservacionsXogosFogar(this.porXogo);

  static const String assetPath = 'assets/content/xogos_fogar_observar.json';

  /// Las pistas de un juego, o ninguna si el juego no las tiene.
  List<LocalizedString> de(String idXogo) => porXogo[idXogo] ?? const [];

  factory ObservacionsXogosFogar.fromRaw(String raw) {
    final decoded = jsonDecode(raw);
    final xogos = decoded is Map ? decoded['xogos'] : null;
    if (xogos is! Map) {
      throw const FormatException('xogos_fogar_observar: falta «xogos»');
    }
    return ObservacionsXogosFogar(Map.unmodifiable({
      for (final e in xogos.entries) e.key.toString(): observacionsDe(e.value),
    }));
  }

  static Future<ObservacionsXogosFogar>? _enCurso;

  /// Una sola carga por ejecución: el contenido no cambia mientras la app vive.
  static Future<ObservacionsXogosFogar> cargar({
    AssetBundleStringLoader? stringLoader,
  }) {
    if (stringLoader != null) {
      return stringLoader(assetPath).then(ObservacionsXogosFogar.fromRaw);
    }
    return _enCurso ??=
        rootBundle.loadString(assetPath).then(ObservacionsXogosFogar.fromRaw);
  }
}
