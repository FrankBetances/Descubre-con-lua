import 'package:flutter/foundation.dart';

/// Una palabra del vocabulario inglés de la app.
///
/// **De dónde sale cada campo.** El fichero que este modelo lee lo escribe
/// `tools/build_corpus_ingles.py`, y ahí está dicho con detalle. En corto: la
/// banda de frecuencia (1k…8k) la trae la lista de origen; el nivel se DERIVA
/// de la banda y la pantalla dice que no es una clasificación oficial del
/// MCER; la categoría gramatical sale de WordNet por la cuenta real de SemCor;
/// el `zipf` lo mide `wordfreq`; y la frase es una oración entera, de WordNet
/// o construida con su definición.
///
/// **Lo que se quitó en su día, y por qué volvió.** El fichero traía `pos` y
/// `zipf_score` inventados: 6.206 de las 8.000 venían etiquetadas `NOUN`
/// —«able», «across» y «accept» entre ellas— y el `zipf_score` resultó ser una
/// función del ORDEN ALFABÉTICO dentro de la banda. Se quitaron. Ahora los dos
/// campos están otra vez, pero medidos: un dato inventado presentado como dato
/// es peor que ningún dato, y un dato real presentado como dato es mejor que
/// ninguno.
@immutable
class CorpusPalabra {
  final int id;
  final String lemma;
  final String banda; // '1k', '2k', '3k', '4k', '5k', '6k', '7k', '8k'

  /// Nivel ORIENTATIVO, derivado de la banda de frecuencia.
  final String nivelCefr; // 'A1/A2', 'A2/B1', 'B1/B2', 'B2', 'C1', 'C1+'

  /// `NOUN`, `VERB`, `ADJ`, `ADV`, `ADP`, `AUX`, `PRON`, `DET`, `CCONJ`,
  /// `SCONJ`, `INTJ` o `X`. Vacío solo si el fichero no lo trae.
  final String pos;

  /// Frecuencia Zipf real (`wordfreq`). 0 cuando no hay medida.
  final double zipf;

  /// La glosa de WordNet del sentido más usado. Puede estar vacía.
  final String definicion;

  /// Una oración ENTERA que usa la palabra. Es lo que se escucha.
  final String frase;

  /// Palabra que imita un sonido: «splash», «buzz», «knock».
  final bool onomatopeya;

  const CorpusPalabra({
    required this.id,
    required this.lemma,
    required this.banda,
    this.nivelCefr = 'A1/A2',
    this.pos = '',
    this.zipf = 0,
    this.definicion = '',
    this.frase = '',
    this.onomatopeya = false,
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

    final rawZipf = json['zipf'] ?? json['zipf_score'];

    return CorpusPalabra(
      id: id,
      lemma: lemma,
      banda: banda,
      nivelCefr: nivelCefr,
      pos: json['pos']?.toString().trim().toUpperCase() ?? '',
      zipf: rawZipf is num ? rawZipf.toDouble() : 0,
      definicion: json['definicion']?.toString().trim() ?? '',
      frase: json['frase']?.toString().trim() ?? '',
      onomatopeya: json['onomatopeya'] == true,
    );
  }

  /// Numeric frequency band (1..8) extracted from [banda].
  int get bandaNumero {
    final cleaned = banda.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 1;
  }

  /// La categoría gramatical en la lengua de la interfaz, para la pantalla.
  ///
  /// No se traduce con un `switch` en el widget porque la pantalla no es el
  /// sitio del contenido; y no va a un JSON aparte porque son doce etiquetas
  /// fijas de gramática, no contenido editable.
  String posEtiqueta({required bool galego}) {
    switch (pos) {
      case 'NOUN':
        return galego ? 'Substantivo' : 'Sustantivo';
      case 'VERB':
        return 'Verbo';
      case 'ADJ':
        return galego ? 'Adxectivo' : 'Adjetivo';
      case 'ADV':
        return 'Adverbio';
      case 'ADP':
        return 'Preposición';
      case 'AUX':
        return 'Auxiliar';
      case 'PRON':
        return galego ? 'Pronome' : 'Pronombre';
      case 'DET':
        return 'Determinante';
      case 'NUM':
        return 'Numeral';
      case 'CCONJ':
      case 'SCONJ':
        return galego ? 'Conxunción' : 'Conjunción';
      case 'INTJ':
        return galego ? 'Interxección' : 'Interjección';
      default:
        return galego ? 'Outra' : 'Otra';
    }
  }

  Map<String, dynamic> toJson() => {
        'id_global': id,
        'lemma': lemma,
        'banda_frecuencia': banda,
        'nivel_cefr': nivelCefr,
        if (pos.isNotEmpty) 'pos': pos,
        if (zipf > 0) 'zipf': zipf,
        if (definicion.isNotEmpty) 'definicion': definicion,
        if (frase.isNotEmpty) 'frase': frase,
        if (onomatopeya) 'onomatopeya': true,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CorpusPalabra &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lemma == other.lemma &&
          banda == other.banda &&
          nivelCefr == other.nivelCefr &&
          pos == other.pos &&
          zipf == other.zipf &&
          definicion == other.definicion &&
          frase == other.frase &&
          onomatopeya == other.onomatopeya;

  @override
  int get hashCode => Object.hash(
        id,
        lemma,
        banda,
        nivelCefr,
        pos,
        zipf,
        definicion,
        frase,
        onomatopeya,
      );

  @override
  String toString() =>
      'CorpusPalabra(#$id, lemma: "$lemma", band: $banda, nivel: $nivelCefr, '
      'pos: $pos)';
}
