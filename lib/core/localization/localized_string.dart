import 'app_language.dart';

/// Strongly typed immutable representation of multilingual text (`gl` / `es`, with optional `en`).
///
/// Ensures 1:1 linguistic parity between Galician and Spanish throughout
/// all pedagogical units and Academy capsules, while allowing English variants
/// for the L3 TPR curriculum and shared components.
class LocalizedString {
  final String gl;
  final String es;
  final String? en;

  const LocalizedString({
    required this.gl,
    required this.es,
    this.en,
  });

  /// Factory constructor to parse JSON maps into [LocalizedString].
  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      gl: json['gl'] as String? ?? '',
      es: json['es'] as String? ?? '',
      en: json['en'] as String?,
    );
  }

  /// Resolves the string based on the active [AppLanguage].
  String resolve(AppLanguage lang) {
    if (lang == AppLanguage.en && en != null && en!.isNotEmpty) {
      return en!;
    }
    return lang == AppLanguage.gl ? gl : es;
  }

  /// Serializes to JSON map.
  Map<String, String> toJson() => {
        'gl': gl,
        'es': es,
        if (en != null) 'en': en!,
      };

  /// Returns true if both language variants are non-empty and non-blank.
  bool get hasParity => gl.trim().isNotEmpty && es.trim().isNotEmpty;

  /// Returns a copy with updated fields.
  LocalizedString copyWith({
    String? gl,
    String? es,
    String? en,
  }) {
    return LocalizedString(
      gl: gl ?? this.gl,
      es: es ?? this.es,
      en: en ?? this.en,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedString &&
          runtimeType == other.runtimeType &&
          gl == other.gl &&
          es == other.es &&
          en == other.en;

  @override
  int get hashCode => Object.hash(gl, es, en);

  @override
  String toString() =>
      'LocalizedString(gl: "$gl", es: "$es"${en != null ? ', en: "$en"' : ''})';
}
