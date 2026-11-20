import '../localization/app_language.dart';

/// Speaking styles used by the offline voice pipeline (matching Valeria).
///
/// `tutor` (1.0): continuous reading pace for adult directions.
/// `child` (1.05): child-directed English phrases.
/// `slow` (1.6): single words and slow phrase replay («Oír amodo / Oír despacio»).
/// No `clinical` style because nothing here has a health purpose.
enum VoiceStyle {
  /// Continuous reading pace: teacher directions, story pages, capsule sections.
  tutor,

  /// Child-directed pace (1.05) for English phrases heard by the child.
  child,

  /// Slower pace (1.6) for single words and slow phrase replay.
  slow;

  String get code => name;
}

/// Collapses the whitespace that does not change how a sentence is read.
String normalizeVoiceText(String text) =>
    text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// FNV-1a, 32 bits, over UTF-16 code units.
///
/// Same function as the earlier pipeline in the house so an id computed in Dart, in Python
/// (the corpus exporter) or in JavaScript is byte-identical.
String fnv1a32(String value) {
  var hash = 0x811c9dc5;
  for (var i = 0; i < value.length; i++) {
    hash ^= value.codeUnitAt(i);
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash.toRadixString(16).padLeft(8, '0');
}

/// Identifier of the recording for [text], read in [style] and [lang].
///
/// The id is derived from the text itself, so a text edit necessarily changes
/// the id. The old recording stops being referenced and the new one does not
/// exist yet, which the coverage gate reports. That is the point: it makes it
/// impossible to ship a screen that displays one sentence and plays another.
String voiceAssetId(VoiceStyle style, String text, AppLanguage lang) {
  final normalized = normalizeVoiceText(text);
  return '${lang.code}_${style.code}_${fnv1a32(normalized)}_${normalized.length}';
}

/// Bundled path of the recording for [text].
String voiceAssetPath(VoiceStyle style, String text, AppLanguage lang) =>
    'assets/voice/${voiceAssetId(style, text, lang)}.m4a';

/// El estilo que le toca a una cadena en inglés.
///
/// Una palabra suelta se graba DESPACIO (`slow`), porque existe para que la
/// imiten; cuando hay un espacio es una frase: si la oye el niño ([paraNeno]),
/// va en `child` (1.05) acompañada de su versión `slow` (1.6); si es consigna
/// para el adulto, en `tutor` (1.0).
/// La misma regla está en `tools/voice_corpus.py`: si las dos dejaran de
/// coincidir, la app pediría una grabación con otro identificador y el botón
/// desaparecería sin que nadie supiera por qué.
VoiceStyle estiloIngles(String texto, {bool paraNeno = false}) =>
    normalizeVoiceText(texto).contains(' ')
        ? (paraNeno ? VoiceStyle.child : VoiceStyle.tutor)
        : VoiceStyle.slow;

/// Identifier of the English recording for [text] (synthesised with LJSpeech · piper).
String englishVoiceAssetId(VoiceStyle style, String text) =>
    voiceAssetId(style, text, AppLanguage.en);

/// Bundled path of the English recording for [text].
String englishVoiceAssetPath(VoiceStyle style, String text) =>
    voiceAssetPath(style, text, AppLanguage.en);
