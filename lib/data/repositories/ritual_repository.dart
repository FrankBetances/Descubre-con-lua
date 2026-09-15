import 'dart:convert';

import 'package:flutter/foundation.dart' show immutable, visibleForTesting;
import 'package:flutter/services.dart' show rootBundle;

import '../loaders/content_asset_loader.dart';
import '../../core/localization/localized_string.dart';

/// Una fase de la asamblea: qué se hace y cuánto dura.
@immutable
class FaseAsamblea {
  /// `pulso`, `conto`, `preguntas`, `exploracion`, `matematicas`, `ponteCasa`.
  final String clave;

  /// Minutos sugeridos. NO es un cronómetro que haya que cumplir: es el ritmo
  /// que evita que una fase se coma la asamblea entera.
  final int minutos;

  /// La línea que la docente lee de un vistazo antes de levantar la cabeza.
  final LocalizedString consigna;

  const FaseAsamblea({
    required this.clave,
    required this.minutos,
    required this.consigna,
  });

  factory FaseAsamblea.fromJson(Map<String, dynamic> json) => FaseAsamblea(
        clave: json['clave']?.toString().trim() ?? '',
        minutos: (json['minutos'] as num?)?.toInt() ?? 1,
        consigna: LocalizedString.fromJson(
            json['consigna'] as Map<String, dynamic>? ?? const {}),
      );
}

/// El ritual de la asamblea, leído del paquete.
///
/// **Por qué es un fichero aparte y no un campo de cada unidad.** Lo que la
/// docente HACE en cada fase es el mismo gesto los diez meses: sentar el
/// círculo, leer la página, ofrecer el material. Lo que cambia cada mes es el
/// material, y eso ya vive en la unidad. Repetir la consigna diez veces sería
/// diez sitios donde se puede quedar vieja.
///
/// **Por qué es contenido y no está escrito en el widget.** Porque lo va a
/// corregir quien sepa de aula, no quien sepa de Dart, y porque un gate puede
/// leerlo. Es la regla del CLAUDE.md.
@immutable
class RitualAsamblea {
  final List<FaseAsamblea> fases;

  const RitualAsamblea({required this.fases});

  static const String asset = 'assets/content/asamblea/fases.json';

  /// El ritual vacío: la pantalla funciona igual, sin consigna ni minutos.
  static const RitualAsamblea ningun = RitualAsamblea(fases: []);

  /// La fase por su posición, o `null` si el ritual no la trae.
  FaseAsamblea? enPosicion(int indice) =>
      (indice >= 0 && indice < fases.length) ? fases[indice] : null;

  /// La suma de los minutos sugeridos. La cabecera la enseña en vez de una
  /// cifra escrita a mano: antes decía «5-8 min» sin que nada la sostuviera.
  int get minutosTotales =>
      fases.fold(0, (total, fase) => total + fase.minutos);

  static Future<RitualAsamblea>? _enCurso;

  static Future<RitualAsamblea> cargar({
    AssetBundleStringLoader? stringLoader,
  }) {
    if (stringLoader != null) return _leer(stringLoader);
    return _enCurso ??= _leer((path) => rootBundle.loadString(path));
  }

  @visibleForTesting
  static void olvidar() => _enCurso = null;

  static Future<RitualAsamblea> _leer(AssetBundleStringLoader cargador) async =>
      desdeJson(await cargador(asset));

  static RitualAsamblea desdeJson(String rawJson) {
    final decoded = json.decode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('fases.json: se esperaba un objeto');
    }
    return RitualAsamblea(
      fases: List.unmodifiable(
        (decoded['fases'] as List? ?? const []).map(
            (e) => FaseAsamblea.fromJson(Map<String, dynamic>.from(e as Map))),
      ),
    );
  }
}
