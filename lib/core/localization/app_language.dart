/// Las lenguas de «Descubre con Lúa · Edición Vigo».
///
/// La INTERFAZ es bilingüe: galego y castelán, y el selector solo ofrece esas
/// dos. [AppLanguage.en] no es una lengua de interfaz y no aparece en ningún
/// selector: existe únicamente para etiquetar las grabaciones en inglés de la
/// capa L3 (el léxico y las frases de `assets/content/calendario/`), que la
/// persona adulta escucha para pronunciarlas. Ninguna pantalla se traduce al
/// inglés, porque nadie la lee en inglés.
enum AppLanguage {
  gl,
  es,

  /// Solo para el identificador de las grabaciones en inglés. No es idioma de
  /// interfaz: no lo pongas en un selector ni lo uses para resolver textos.
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

  /// Las dos lenguas en las que se puede leer la app.
  static const List<AppLanguage> deInterfaz = [AppLanguage.gl, AppLanguage.es];

  /// Si esta lengua se puede elegir en pantalla.
  bool get esDeInterfaz => this != AppLanguage.en;

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

  /// La lengua de interfaz que corresponde a un código ISO. Por defecto, galego.
  ///
  /// **Nunca devuelve `en`**, ni para un aparato en inglés. Esto elige lo que se
  /// LEE, y no hay pantallas en inglés: un móvil configurado en inglés abre la
  /// app en galego, como cualquier otro que no esté en castellano. El inglés se
  /// pide siempre a mano, y solo para sonar.
  static AppLanguage fromCode(String? code) {
    if (code == null) return AppLanguage.gl;
    final normalized = code.trim().toLowerCase();
    if (normalized.startsWith('es')) {
      return AppLanguage.es;
    }
    return AppLanguage.gl;
  }

  /// Alterna entre las dos lenguas de la escuela. Desde `en` —que nunca es la
  /// lengua de la pantalla— se vuelve al galego.
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
