/// Supported application languages for «Descubre con Lúa · Edición Vigo».
///
/// Strictly bilingual: Galego (`gl`) and Castellano (`es`).
enum AppLanguage {
  gl,
  es;

  /// ISO 639-1 two-letter code.
  String get code => this == AppLanguage.gl ? 'gl' : 'es';

  /// Human-readable display label in each language's native name.
  String get displayName => this == AppLanguage.gl ? 'Galego' : 'Castellano';

  /// Short badge label for quick UI toggle buttons.
  String get flagLabel => this == AppLanguage.gl ? 'GL' : 'ES';

  /// Resolves an [AppLanguage] from an ISO code string. Defaults to [AppLanguage.gl].
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.gl;
    final normalized = code.trim().toLowerCase();
    if (normalized.startsWith('es')) {
      return AppLanguage.es;
    }
    return AppLanguage.gl;
  }

  /// Toggles between Galego and Castellano.
  AppLanguage toggle() => this == AppLanguage.gl ? AppLanguage.es : AppLanguage.gl;
}
