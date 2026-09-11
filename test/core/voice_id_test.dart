import 'package:descubre_con_lua/core/audio/voice_id.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Voice asset identifiers', () {
    test('FNV-1a matches the value the Valeria corpus already ships', () {
      // gl_child_fd51808f_8 is a real entry of voice-assets-manifest.gl.json in
      // the Valeria repository. Pinning it here means the Dart, Python and
      // JavaScript ports cannot drift apart without a red test: if they did,
      // every recording would be looked up under a name that does not exist.
      expect(fnv1a32('Di: rúa.'), 'fd51808f');
      expect('gl_child_fd51808f_8'.split('_').last, '8');
    });

    test('Dart and the Python exporter agree on the same identifiers', () {
      // Values produced by tools/voice_corpus.py for this exact content. The
      // exporter writes the paths into the content JSON and the app looks them
      // up here: if the two implementations diverged, every lookup would miss.
      expect(
        voiceAssetId(VoiceStyle.slow, 'Cuncha', AppLanguage.gl),
        'gl_slow_492e39a1_6',
      );
      expect(
        voiceAssetId(VoiceStyle.slow, 'Concha', AppLanguage.es),
        'es_slow_35479b23_6',
      );
      expect(
        voiceAssetId(VoiceStyle.tutor, 'Ondas que veñen', AppLanguage.gl),
        'gl_tutor_57779a42_15',
      );
    });

    test('identifier is derived from the text, the style and the language', () {
      const text = 'Ondas que veñen';
      final glTutor = voiceAssetId(VoiceStyle.tutor, text, AppLanguage.gl);
      final glSlow = voiceAssetId(VoiceStyle.slow, text, AppLanguage.gl);
      final esTutor = voiceAssetId(VoiceStyle.tutor, text, AppLanguage.es);

      expect(glTutor, startsWith('gl_tutor_'));
      expect(glSlow, startsWith('gl_slow_'));
      expect(esTutor, startsWith('es_tutor_'));
      expect({glTutor, glSlow, esTutor}, hasLength(3));
    });

    test('changing one character changes the recording that is looked up', () {
      final before =
          voiceAssetId(VoiceStyle.tutor, 'Ondas que veñen', AppLanguage.gl);
      final after =
          voiceAssetId(VoiceStyle.tutor, 'Ondas que venen', AppLanguage.gl);

      // This is the whole point of hashing the text: an edited sentence can no
      // longer keep pointing at the recording of the old one.
      expect(before, isNot(after));
    });

    test('whitespace that does not change the reading does not change the id',
        () {
      final plain =
          voiceAssetId(VoiceStyle.tutor, 'Ondas que veñen', AppLanguage.gl);
      final padded = voiceAssetId(
          VoiceStyle.tutor, '  Ondas   que\n veñen  ', AppLanguage.gl);

      expect(plain, padded);
      expect(normalizeVoiceText('  Ondas   que\n veñen  '), 'Ondas que veñen');
    });

    test('paths stay inside the bundle, never on the network', () {
      final path = voiceAssetPath(VoiceStyle.slow, 'Cuncha', AppLanguage.gl);

      expect(path, startsWith('assets/voice/'));
      expect(path, endsWith('.m4a'));
      expect(path, isNot(contains('://')));
    });
  });
}
