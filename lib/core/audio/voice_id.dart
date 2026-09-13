import '../localization/app_language.dart';

/// Speaking styles used by the offline voice pipeline.
///
/// Deliberately narrow. There is no `child` style because a child never uses
/// this app, and no `clinical` style because nothing here has a health purpose:
/// every locution is addressed to the teacher or to the family.
enum VoiceStyle {
  /// Continuous reading pace: teacher directions, story pages, capsule sections.
  tutor,

  /// Slower pace for single words, used by the vocabulary cards.
  slow;

  String get code => name;
}

/// Collapses the whitespace that does not change how a sentence is read.
String normalizeVoiceText(String text) =>
    text.replaceAll(RegExp(r'\s+'), ' ').trim();

/// FNV-1a, 32 bits, over UTF-16 code units.
///
/// Same function as the Valeria pipeline so an id computed in Dart, in Python
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

/// Identifier of the English recording for [text] (synthesised with LJSpeech · piper).
String englishVoiceAssetId(VoiceStyle style, String text) =>
    voiceAssetId(style, text, AppLanguage.en);

/// Bundled path of the English recording for [text].
String englishVoiceAssetPath(VoiceStyle style, String text) =>
    voiceAssetPath(style, text, AppLanguage.en);
