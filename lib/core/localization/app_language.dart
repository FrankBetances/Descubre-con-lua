/// Supported application languages for «Descubre con Lúa · Edición Vigo».
///
/// Bilingual baseline: Galego (`gl`) and Castellano (`es`), with full English (`en`)
/// support for the L3 early language acquisition and TPR curriculum (LJSpeech · piper).
enum AppLanguage {
  gl,
  es,
  en;

  /// ISO 639-1 two-letter code.
  String get code {
    switch (this) {
      case AppLanguage.gl:
        return 'gl';
      case AppLanguage.es:
        return 'es';
      case AppLanguage.en:
        return 'en';
    }
  }

  /// Human-readable display label in each language's native name.
  String get displayName {
    switch (this) {
      case AppLanguage.gl:
        return 'Galego';
      case AppLanguage.es:
        return 'Castellano';
      case AppLanguage.en:
        return 'English';
    }
  }

  /// Short badge label for quick UI toggle buttons.
  String get flagLabel {
    switch (this) {
      case AppLanguage.gl:
        return 'GL';
      case AppLanguage.es:
        return 'ES';
      case AppLanguage.en:
        return 'EN';
    }
  }

  /// Resolves an [AppLanguage] from an ISO code string. Defaults to [AppLanguage.gl].
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.gl;
    final normalized = code.trim().toLowerCase();
    if (normalized.startsWith('es')) {
      return AppLanguage.es;
    }
    if (normalized.startsWith('en')) {
      return AppLanguage.en;
    }
    return AppLanguage.gl;
  }

  /// Toggles between Galego and Castellano (canonical school alternation).
  AppLanguage toggle() {
    switch (this) {
      case AppLanguage.gl:
        return AppLanguage.es;
      case AppLanguage.es:
        return AppLanguage.gl;
      case AppLanguage.en:
        return AppLanguage.gl;
    }
  }
}
