import 'package:flutter/foundation.dart';

/// Una palabra de la lista de 8.000 del corpus BNC/COCA.
///
/// **Lo que este modelo SÍ tiene y por qué.** La banda de frecuencia (1k…8k) es
/// el dato que trae la lista, y el nivel orientativo se DERIVA de esa banda:
/// las 1.000 primeras palabras son A1/A2, las 1.000 siguientes A2/B1, y así.
/// Eso no es una clasificación CEFR oficial y la pantalla lo dice con esas
/// palabras.
///
/// **Lo que se quitó, y por qué.** El fichero traía además `pos` y
/// `zipf_score`, y los dos estaban inventados: 6.206 de las 8.000 palabras
/// venían etiquetadas `NOUN` —«able», «across», «accept» entre ellas— y el
/// `zipf_score` resultó ser una función del ORDEN ALFABÉTICO dentro de la
/// banda, no una frecuencia: «able» salía con 7.7, el valor de la palabra más
/// frecuente del inglés, solo por ir la primera de la lista. La pantalla los
/// enseñaba como medición. Un dato inventado presentado como dato es peor que
/// ningún dato, así que no están.
@immutable
class CorpusPalabra {
  final int id;
  final String lemma;
  final String banda; // '1k', '2k', '3k', '4k', '5k', '6k', '7k', '8k'

  /// Nivel ORIENTATIVO, derivado de la banda de frecuencia.
  final String nivelCefr; // 'A1/A2', 'B1', 'B2', etc.

  const CorpusPalabra({
    required this.id,
    required this.lemma,
    required this.banda,
    this.nivelCefr = 'A1/A2',
  });

  /// Factory constructor to parse JSON maps from both standard and CEFR corpus formats.
  factory CorpusPalabra.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_global'] ?? json['id'] ?? 0;
    final id = (rawId as num).toInt();

    final lemma = json['lemma']?.toString().trim() ??
        json['word']?.toString().trim() ??
        '';

    final banda = json['banda_frecuencia']?.toString().trim() ??
        json['banda']?.toString().trim() ??
        json['band']?.toString().trim() ??
        '1k';

    final nivelCefr = json['nivel_cefr']?.toString().trim() ??
        json['nivelCefr']?.toString().trim() ??
        json['cefr']?.toString().trim() ??
        'A1/A2';

    return CorpusPalabra(
      id: id,
      lemma: lemma,
      banda: banda,
      nivelCefr: nivelCefr,
    );
  }

  /// Numeric frequency band (1..8) extracted from [banda].
  int get bandaNumero {
    final cleaned = banda.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 1;
  }

  Map<String, dynamic> toJson() => {
        'id_global': id,
        'lemma': lemma,
        'banda_frecuencia': banda,
        'nivel_cefr': nivelCefr,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorpusPalabra &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lemma == other.lemma &&
          banda == other.banda &&
          nivelCefr == other.nivelCefr;

  @override
  int get hashCode => Object.hash(
        id,
        lemma,
        banda,
        nivelCefr,
      );

  @override
  String toString() =>
      'CorpusPalabra(#$id, lemma: "$lemma", band: $banda, nivel: $nivelCefr)';
}
