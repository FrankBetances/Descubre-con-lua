import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/cancion_pulso_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';

void main() {
  late ContentAssetLoader fileLoader;
  late ContentRepository repository;

  setUp(() {
    fileLoader = ContentAssetLoader(
      stringLoader: (path) async {
        final file = File(path);
        if (!file.existsSync()) {
          throw Exception('File not found at: $path');
        }
        return file.readAsString();
      },
    );
    repository = ContentRepository(loader: fileLoader);
  });

  group('ContentAssetLoader Tests', () {
    test('as dez cancións con pulso lense enteiras', () async {
      final cancions = CancionsConPulso.desdeJson(
          await fileLoader.loadRawString(CancionsConPulso.asset));
      expect(cancions, hasLength(10));
      expect(cancions.map((c) => c.id).toSet(), hasLength(10));
      for (final c in cancions) {
        // The pulse track measures 72.3 BPM (tools/check_pulse_bpm.py reads it
        // off the audio). The content used to declare 80.
        expect(c.cancion.bpm, equals(72), reason: c.id);
        expect(c.cancion.titulo.hasParity, isTrue, reason: c.id);
        expect(c.cancion.versos(AppLanguage.gl), isNotEmpty, reason: c.id);
        expect(c.cancion.beatsPerLine(AppLanguage.gl),
            c.cancion.beatsPerLine(AppLanguage.es),
            reason: c.id);
        expect(c.cancion.resolveAudio(AppLanguage.gl), startsWith('assets/'),
            reason: c.id);
      }
    });

    test(
        'loads and parses base capsule academy.como_se_aprende_a_hablar.01.json from assets',
        () async {
      final capsula = await fileLoader.loadCapsulaFromAsset(
        'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json',
      );

      expect(capsula.id, equals('academy.como_se_aprende_a_hablar.01'));
      expect(capsula.bloqueId, equals('desarrollo_comunicativo'));
      expect(capsula.tiempoLecturaMinutos, equals(3));
      expect(capsula.ideaClave.gl, isNotEmpty);
      expect(capsula.porQueImporta.gl, isNotEmpty);
      expect(capsula.queHacerEnCasa.gl, isNotEmpty);
      expect(capsula.ejemploCotidiano.gl, isNotEmpty);
      expect(capsula.afirmaciones.length, equals(2));
      expect(capsula.curriculo.normativa, equals('Decreto 150/2022'));
      expect(capsula.revision.aprobadoParaAula, isTrue);
    });

    test('throws FormatException on malformed JSON string', () {
      expect(
        () => fileLoader.parseCapsula('{"id": "broken", invalid}'),
        throwsFormatException,
      );
    });
  });

  group('ContentRepository Tests', () {
    test('initializes and provides query methods for capsules', () async {
      await repository.initialize(
        capsulaPaths: [
          'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json'
        ],
      );

      expect(repository.isInitialized, isTrue);
      expect(repository.capsuleCount, equals(1));

      // Capsule queries
      final capsule =
          repository.getCapsulaById('academy.como_se_aprende_a_hablar.01');
      expect(capsule, isNotNull);
      expect(capsule!.bloqueId, equals('desarrollo_comunicativo'));

      final nonExistentCapsule = repository.getCapsulaById('academy.fake.01');
      expect(nonExistentCapsule, isNull);

      final blockCapsules =
          repository.getCapsulasByBloqueId('desarrollo_comunicativo');
      expect(blockCapsules.length, equals(1));

      final numericBlockCapsules = repository.getCapsulasByBloqueId('1');
      expect(numericBlockCapsules.length, equals(1));

      final allCapsules = repository.getAllCapsulas();
      expect(allCapsules.length, equals(1));

      // Block queries
      final blocks = repository.getAllBloques();
      expect(blocks.length, equals(5));

      final b1 = repository.getBloqueById('desarrollo_comunicativo');
      expect(b1, isNotNull);
      expect(b1!.orden, equals(1));

      final b1Num = repository.getBloqueById('1');
      expect(b1Num, equals(b1));
    });

    test('as cancións con pulso cárganse unha vez', () async {
      final primeira = await repository.loadCancionsConPulso();
      expect(primeira, hasLength(10));
      expect(
          identical(await repository.loadCancionsConPulso(), primeira), isTrue);
      expect(repository.hasLoadErrors, isFalse);
    });

    test('clear resets repository state', () async {
      await repository.initialize(
        capsulaPaths: [
          'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json'
        ],
      );
      expect(repository.capsuleCount, equals(1));

      repository.clear();
      expect(repository.isInitialized, isFalse);
      expect(repository.capsuleCount, equals(0));
    });
  });
}
