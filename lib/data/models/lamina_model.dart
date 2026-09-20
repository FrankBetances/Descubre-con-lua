import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// TPR action prompt in English, Galician and Spanish.
@immutable
class LaminaTprAccion {
  final String en;
  final String gl;
  final String es;

  const LaminaTprAccion({
    required this.en,
    required this.gl,
    required this.es,
  });

  factory LaminaTprAccion.fromJson(Map<String, dynamic> json) {
    return LaminaTprAccion(
      en: json['en']?.toString().trim() ?? '',
      gl: json['gl']?.toString().trim() ?? '',
      es: json['es']?.toString().trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'en': en,
        'gl': gl,
        'es': es,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LaminaTprAccion &&
          runtimeType == other.runtimeType &&
          en == other.en &&
          gl == other.gl &&
          es == other.es;

  @override
  int get hashCode => Object.hash(en, gl, es);

  @override
  String toString() => 'LaminaTprAccion(en: "$en")';
}

/// Illustrated flashcard or card item from the 200+ Didactic Cards Bank.
///
/// Ported from `.studio_ref/src/data/banco200LaminasData.ts`.
@immutable
class Lamina {
  final String id;
  final int numero;
  final String categoria;
  final String gl;
  final String es;
  final String en;
  final String cefr; // 'Pre-A1', 'A1', 'A2'
  final String ratio; // '3:5' | '16:10'
  final String? rfidTag;
  final String? corHex;
  final String? bgHex;
  final String? simbolo;
  final LocalizedString? preguntaSugerida;
  final LocalizedString? obxectivo;
  final LaminaTprAccion? tprAccion;

  const Lamina({
    required this.id,
    required this.numero,
    required this.categoria,
    required this.gl,
    required this.es,
    required this.en,
    required this.cefr,
    required this.ratio,
    this.rfidTag,
    this.corHex,
    this.bgHex,
    this.simbolo,
    this.preguntaSugerida,
    this.obxectivo,
    this.tprAccion,
  });

  factory Lamina.fromJson(Map<String, dynamic> json) {
    final rawPregunta =
        json['preguntaSugerida'] ?? json['pregunta_sugerida'];
    final LocalizedString? pregunta = rawPregunta is Map<String, dynamic>
        ? LocalizedString.fromJson(rawPregunta)
        : (rawPregunta is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawPregunta))
            : null);

    final rawObj = json['obxectivo'] ?? json['objetivo'];
    final LocalizedString? obj = rawObj is Map<String, dynamic>
        ? LocalizedString.fromJson(rawObj)
        : (rawObj is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawObj))
            : null);

    final rawTpr = json['tprAccion'] ?? json['tpr_accion'];
    final LaminaTprAccion? tpr = rawTpr is Map<String, dynamic>
        ? LaminaTprAccion.fromJson(rawTpr)
        : (rawTpr is Map
            ? LaminaTprAccion.fromJson(Map<String, dynamic>.from(rawTpr))
            : null);

    return Lamina(
      id: json['id']?.toString().trim() ?? '',
      numero: (json['numero'] as num?)?.toInt() ?? 1,
      categoria: json['categoria']?.toString().trim() ?? 'vocabulario',
      gl: json['gl']?.toString().trim() ?? '',
      es: json['es']?.toString().trim() ?? '',
      en: json['en']?.toString().trim() ?? '',
      cefr: json['cefr']?.toString().trim() ?? 'Pre-A1',
      ratio: json['ratio']?.toString().trim() ?? '3:5',
      rfidTag: json['rfidTag']?.toString().trim() ??
          json['rfid_tag']?.toString().trim(),
      corHex: json['corHex']?.toString().trim() ??
          json['cor_hex']?.toString().trim(),
      bgHex: json['bgHex']?.toString().trim() ??
          json['bg_hex']?.toString().trim(),
      simbolo: json['simbolo']?.toString().trim(),
      preguntaSugerida: pregunta,
      obxectivo: obj,
      tprAccion: tpr,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'numero': numero,
        'categoria': categoria,
        'gl': gl,
        'es': es,
        'en': en,
        'cefr': cefr,
        'ratio': ratio,
        if (rfidTag != null) 'rfidTag': rfidTag,
        if (corHex != null) 'corHex': corHex,
        if (bgHex != null) 'bgHex': bgHex,
        if (simbolo != null) 'simbolo': simbolo,
        if (preguntaSugerida != null)
          'preguntaSugerida': preguntaSugerida!.toJson(),
        if (obxectivo != null) 'obxectivo': obxectivo!.toJson(),
        if (tprAccion != null) 'tprAccion': tprAccion!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lamina &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          numero == other.numero &&
          categoria == other.categoria &&
          gl == other.gl &&
          es == other.es &&
          en == other.en &&
          cefr == other.cefr &&
          ratio == other.ratio &&
          rfidTag == other.rfidTag &&
          corHex == other.corHex &&
          bgHex == other.bgHex &&
          simbolo == other.simbolo &&
          preguntaSugerida == other.preguntaSugerida &&
          obxectivo == other.obxectivo &&
          tprAccion == other.tprAccion;

  @override
  int get hashCode => Object.hash(
        id,
        numero,
        categoria,
        gl,
        es,
        en,
        cefr,
        ratio,
        rfidTag,
        corHex,
        bgHex,
        simbolo,
        preguntaSugerida,
        obxectivo,
        tprAccion,
      );

  @override
  String toString() => 'Lamina(#$numero, id: $id, $gl)';
}
