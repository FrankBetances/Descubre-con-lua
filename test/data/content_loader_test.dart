import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
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
    test('loads and parses base unit juega.mar.01.json from assets', () async {
      final unidad = await fileLoader.loadUnidadFromAsset('assets/content/unidades/juega.mar.01.json');

      expect(unidad.id, equals('juega.mar.01'));
      expect(unidad.tramoEtario, equals('0-3'));
      expect(unidad.titulo.gl, contains('Mar de Vigo'));
      expect(unidad.titulo.es, contains('Mar de Vigo'));
      expect(unidad.cancionPulso.bpm, equals(80));
      expect(unidad.cuento.paginas.length, equals(3));
      expect(unidad.vocabulario.length, equals(5));
      expect(unidad.preguntas.length, equals(3));
      expect(unidad.exploracion.materiales.length, equals(4));
      expect(unidad.exploracion.avisoSeguridad.gl, contains('5 cm'));
      expect(unidad.curriculo.normativa, equals('Decreto 150/2022'));
      expect(unidad.revision.aprobadoParaAula, isTrue);
    });

    test('loads and parses base capsule academy.como_se_aprende_a_hablar.01.json from assets', () async {
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
        () => fileLoader.parseUnidad('{"id": "broken", invalid}'),
        throwsFormatException,
      );
      expect(
        () => fileLoader.parseCapsula('{"id": "broken", invalid}'),
        throwsFormatException,
      );
    });
  });

  group('ContentRepository Tests', () {
    test('initializes and provides query methods for units and capsules', () async {
      await repository.initialize(
        unidadPaths: ['assets/content/unidades/juega.mar.01.json'],
        capsulaPaths: ['assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json'],
      );

      expect(repository.isInitialized, isTrue);
      expect(repository.unitCount, equals(1));
      expect(repository.capsuleCount, equals(1));

      // Unit queries
      final unit = repository.getUnidadById('juega.mar.01');
      expect(unit, isNotNull);
      expect(unit!.id, equals('juega.mar.01'));

      final nonExistentUnit = repository.getUnidadById('inexistente');
      expect(nonExistentUnit, isNull);

      final units02 = repository.getUnidadesByTramoEtario('0-2');
      expect(units02.length, equals(1)); // '0-3' encompasses '0-2'

      final units23 = repository.getUnidadesByTramoEtario('2-3');
      expect(units23.length, equals(1)); // '0-3' encompasses '2-3'

      final allUnits = repository.getAllUnidades();
      expect(allUnits.length, equals(1));

      // Capsule queries
      final capsule = repository.getCapsulaById('academy.como_se_aprende_a_hablar.01');
      expect(capsule, isNotNull);
      expect(capsule!.bloqueId, equals('desarrollo_comunicativo'));

      final nonExistentCapsule = repository.getCapsulaById('academy.fake.01');
      expect(nonExistentCapsule, isNull);

      final blockCapsules = repository.getCapsulasByBloqueId('desarrollo_comunicativo');
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

    test('clear resets repository state', () async {
      await repository.initialize(
        unidadPaths: ['assets/content/unidades/juega.mar.01.json'],
        capsulaPaths: ['assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json'],
      );
      expect(repository.unitCount, equals(1));

      repository.clear();
      expect(repository.isInitialized, isFalse);
      expect(repository.unitCount, equals(0));
      expect(repository.capsuleCount, equals(0));
    });
  });
}
