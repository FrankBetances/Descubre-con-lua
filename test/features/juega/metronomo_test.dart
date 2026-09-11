import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/features/juega/widgets/paso_cancion_widget.dart';
import 'package:descubre_con_lua/features/juega/widgets/rhythm_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cancion = CancionPulso(
    titulo: LocalizedString(gl: 'As ondas', es: 'Las olas'),
    letraConPulsos: LocalizedString(
      gl: '* On-das * que veñen, * on-das * que van,\n'
          '* no mar * de Vi-go * os pei-xes * es-tán.',
      es: '* O-las * que vienen, * o-las * que van,\n'
          '* en el mar * de Vi-go * los pe-ces * es-tán.',
    ),
    bpm: 72,
    audioAsset: LocalizedString(gl: '', es: ''),
    consignaDocente: LocalizedString(gl: 'Amodo', es: 'Despacio'),
  );

  group('Pulse read from the lyrics', () {
    test('beats per bar come from the markers, not from a separate setting',
        () {
      expect(cancion.beatsPerLine(AppLanguage.gl), 4);
      expect(cancion.beatsPerLine(AppLanguage.es), 4);
      expect(cancion.accentEvery(AppLanguage.gl), 4);
    });

    test('a beat lasts exactly what the tempo says', () {
      // 72 BPM is one beat every 833.33 ms.
      expect(cancion.beatDuration.inMilliseconds, 833);

      const faster = CancionPulso(
        titulo: LocalizedString(gl: 'x', es: 'x'),
        letraConPulsos: LocalizedString(gl: '* a * b', es: '* a * b'),
        bpm: 120,
        audioAsset: LocalizedString(gl: '', es: ''),
        consignaDocente: LocalizedString(gl: 'x', es: 'x'),
      );
      expect(faster.beatDuration.inMilliseconds, 500);
    });

    test('a tempo of zero does not divide by zero', () {
      const broken = CancionPulso(
        titulo: LocalizedString(gl: 'x', es: 'x'),
        letraConPulsos: LocalizedString(gl: '* a', es: '* a'),
        bpm: 0,
        audioAsset: LocalizedString(gl: '', es: ''),
        consignaDocente: LocalizedString(gl: 'x', es: 'x'),
      );
      expect(broken.beatDuration.inMilliseconds, 833);
    });

    test('lyrics without markers fall back to a four-beat bar', () {
      const unmarked = CancionPulso(
        titulo: LocalizedString(gl: 'x', es: 'x'),
        letraConPulsos: LocalizedString(gl: 'sen marcas', es: 'sin marcas'),
        bpm: 72,
        audioAsset: LocalizedString(gl: '', es: ''),
        consignaDocente: LocalizedString(gl: 'x', es: 'x'),
      );
      expect(unmarked.beatsPerLine(AppLanguage.gl), 4);
    });
  });

  group('Visual metronome', () {
    Widget host() => MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PasoCancionWidget(
                cancion: cancion,
                language: AppLanguage.gl,
                audioService: MockOfflineAudioService(),
              ),
            ),
          ),
        );

    testWidgets('is silent: starting the pulse plays no audio at all',
        (tester) async {
      final audio = MockOfflineAudioService();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PasoCancionWidget(
                cancion: cancion,
                language: AppLanguage.gl,
                audioService: audio,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Marcar o pulso'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 3));

      // This is the whole point of a drawn metronome: the auditory channel
      // stays free for the voice the children are following.
      expect(audio.callLog, isEmpty);
      expect(audio.isPlaying, isFalse);

      await tester.tap(find.text('Deter o pulso'));
      await tester.pumpAndSettle();
    });

    testWidgets('advances one beat per tempo interval and wraps at the bar',
        (tester) async {
      await tester.pumpWidget(host());

      RhythmBarWidget bar() =>
          tester.widget<RhythmBarWidget>(find.byType(RhythmBarWidget));

      expect(bar().beats, 4);
      expect(bar().current, isNull, reason: 'stopped before it is started');

      await tester.tap(find.text('Marcar o pulso'));
      await tester.pump();
      expect(bar().current, 0);

      // Pumped by the real beat, not by a rounded copy of it: at 72 BPM a beat
      // is 833_333 microseconds, and 833 ms would fall just short of the tick.
      await tester.pump(cancion.beatDuration);
      expect(bar().current, 1);

      await tester.pump(cancion.beatDuration);
      expect(bar().current, 2);

      await tester.pump(cancion.beatDuration);
      expect(bar().current, 3);

      // Back to the downbeat: the bar is four beats long.
      await tester.pump(cancion.beatDuration);
      expect(bar().current, 0);

      await tester.tap(find.text('Deter o pulso'));
      await tester.pumpAndSettle();
      expect(bar().current, isNull);
    });

    testWidgets('the timer does not outlive the widget', (tester) async {
      await tester.pumpWidget(host());
      await tester.tap(find.text('Marcar o pulso'));
      await tester.pump();

      // Tearing the widget down with the pulse running used to leave a Timer
      // calling setState on a disposed State.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(seconds: 5));
      expect(tester.takeException(), isNull);
    });
  });
}
