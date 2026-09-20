import 'package:flutter/foundation.dart';

/// Single lexical entry in the BNC/COCA 8,000-word corpus.
///
/// Supports lexical frequency tiers (1k to 8k) and CEFR proficiency mappings
/// for English immersion and spaced repetition learning.
@immutable
class CorpusPalabra {
  final int id;
  final String lemma;
  final String pos; // Part of speech: 'NOUN', 'VERB', 'ADJ', 'ADV', 'ADP', etc.
  final String banda; // '1k', '2k', '3k', '4k', '5k', '6k', '7k', '8k'
  final String nivelCefr; // 'A1/A2', 'B1', 'B2', etc.
  final double zipfScore; // Zipf frequency score

  const CorpusPalabra({
    required this.id,
    required this.lemma,
    required this.pos,
    required this.banda,
    this.nivelCefr = 'A1/A2',
    this.zipfScore = 5.0,
  });

  /// Factory constructor to parse JSON maps from both standard and CEFR corpus formats.
  factory CorpusPalabra.fromJson(Map<String, dynamic> json) {
    final rawId = json['id_global'] ?? json['id'] ?? 0;
    final id = (rawId as num).toInt();

    final lemma = json['lemma']?.toString().trim() ??
        json['word']?.toString().trim() ??
        '';

    final pos = json['pos']?.toString().trim() ??
        json['part_of_speech']?.toString().trim() ??
        'NOUN';

    final banda = json['banda_frecuencia']?.toString().trim() ??
        json['banda']?.toString().trim() ??
        json['band']?.toString().trim() ??
        '1k';

    final nivelCefr = json['nivel_cefr']?.toString().trim() ??
        json['nivelCefr']?.toString().trim() ??
        json['cefr']?.toString().trim() ??
        'A1/A2';

    final rawZipf = json['zipf_score'] ?? json['zipfScore'];
    final zipfScore = (rawZipf as num?)?.toDouble() ?? 5.0;

    return CorpusPalabra(
      id: id,
      lemma: lemma,
      pos: pos,
      banda: banda,
      nivelCefr: nivelCefr,
      zipfScore: zipfScore,
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
        'pos': pos,
        'banda_frecuencia': banda,
        'nivel_cefr': nivelCefr,
        'zipf_score': zipfScore,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorpusPalabra &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lemma == other.lemma &&
          pos == other.pos &&
          banda == other.banda &&
          nivelCefr == other.nivelCefr &&
          zipfScore == other.zipfScore;

  @override
  int get hashCode => Object.hash(
        id,
        lemma,
        pos,
        banda,
        nivelCefr,
        zipfScore,
      );

  @override
  String toString() =>
      'CorpusPalabra(#$id, lemma: "$lemma", pos: $pos, band: $banda, CEFR: $nivelCefr)';
}
