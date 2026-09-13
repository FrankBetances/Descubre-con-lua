import 'app_language.dart';

/// Strongly typed immutable representation of bilingual text (`gl` / `es`).
///
/// Ensures 1:1 linguistic parity between Galician and Spanish throughout
/// all pedagogical units and Academy capsules.
class LocalizedString {
  final String gl;
  final String es;

  const LocalizedString({
    required this.gl,
    required this.es,
  });

  /// Factory constructor to parse JSON maps into [LocalizedString].
  factory LocalizedString.fromJson(Map<String, dynamic> json) {
    return LocalizedString(
      gl: json['gl'] as String? ?? '',
      es: json['es'] as String? ?? '',
    );
  }

  /// Resolves the string based on the active [AppLanguage].
  String resolve(AppLanguage lang) => lang == AppLanguage.gl ? gl : es;

  /// Serializes to JSON map.
  Map<String, String> toJson() => {
        'gl': gl,
        'es': es,
      };

  /// Returns true if both language variants are non-empty and non-blank.
  bool get hasParity => gl.trim().isNotEmpty && es.trim().isNotEmpty;

  /// Returns a copy with updated fields.
  LocalizedString copyWith({
    String? gl,
    String? es,
  }) {
    return LocalizedString(
      gl: gl ?? this.gl,
      es: es ?? this.es,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalizedString &&
          runtimeType == other.runtimeType &&
          gl == other.gl &&
          es == other.es;

  @override
  int get hashCode => Object.hash(gl, es);

  @override
  String toString() => 'LocalizedString(gl: "$gl", es: "$es")';
}
