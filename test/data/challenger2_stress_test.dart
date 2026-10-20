import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Adversarial Suite 1: Malformed & Corrupted JSON Payloads', () {
    test('rejects payloads missing essential root identifiers', () {
      final resCapsula = validator.validateCapsulaJson({
        'bloqueId': 'desarrollo_comunicativo',
      });
      expect(resCapsula.isValid, isFalse);
      expect(
          resCapsula.errors
              .any((e) => e.contains('Missing or empty root "id"')),
          isTrue);
    });

    test('rejects invalid bloqueId in Capsula', () {
      final res = validator.validateCapsulaJson({
        'id': 'test.capsule',
        'bloqueId': 'bloque_ficticio',
      });
      expect(res.isValid, isFalse);
      expect(res.errors.any((e) => e.contains('Invalid "bloqueId"')), isTrue);
    });

    test('rejects asymmetric and blank localized strings', () {
      final errors = <String>[];
      validator.checkBilingualParity(
        {'gl': 'Só galego'},
        path: 'asymmetric',
        errors: errors,
      );
      expect(errors.length, equals(1));
      expect(errors.first, contains('missing "es"'));

      errors.clear();
      validator.checkBilingualParity(
        {'gl': '   ', 'es': 'Castellano'},
        path: 'blank',
        errors: errors,
      );
      expect(errors.length, equals(1));
      expect(errors.first, contains('blank'));
    });
  });

  group('Adversarial Suite 2: ContentRepository Query Edge Cases', () {
    late ContentRepository repository;

    setUp(() {
      repository = ContentRepository();
    });

    test('returns null / empty for unknown IDs and blocks', () {
      expect(repository.getCapsulaById('inexistente'), isNull);
      expect(repository.getBloqueById('inexistente'), isNull);
      expect(repository.getBloqueById('99'), isNull);
      expect(repository.getCapsulasByBloqueId('inexistente'), isEmpty);
    });

    test('resolves blocks case-insensitively and via numeric ordinals', () {
      final b1 = repository.getBloqueById('DESARROLLO_COMUNICATIVO');
      expect(b1, isNotNull);
      expect(b1!.id, equals('desarrollo_comunicativo'));

      final b2 = repository.getBloqueById('1');
      expect(b2, isNotNull);
      expect(b2!.orden, equals(1));
    });

    test('cache lifecycle and state reset on clear()', () {
      expect(repository.isInitialized, isFalse);
      expect(repository.capsuleCount, equals(0));

      repository.clear();
      expect(repository.isInitialized, isFalse);
      expect(repository.getAllCapsulas(), isEmpty);
    });
  });

  group('Adversarial Suite 4: CurricularReference Constraints', () {
    test('rejects non-Decreto 150/2022 and non-Galician legislation', () {
      final errors = <String>[];
      validator.checkCurricularAlignment({
        'normativa': 'LOMLOE',
        'etapa': 'educacion_infantil',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_1_crecemento_harmonia'],
        'criteriosEvaluacion': ['CA1.1'],
      }, errors: errors);

      expect(
          errors.any((e) =>
              e.contains('curriculo.normativa must be "Decreto 150/2022"')),
          isTrue);
    });

    test('rejects primary or secondary educational stages', () {
      final errors = <String>[];
      validator.checkCurricularAlignment({
        'normativa': 'Decreto 150/2022',
        'etapa': 'primaria',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_1_crecemento_harmonia'],
        'criteriosEvaluacion': ['CA1.1'],
      }, errors: errors);

      expect(
          errors.any((e) =>
              e.contains('curriculo.etapa must be "educacion_infantil"')),
          isTrue);
    });

    test('rejects unrecognized area and criteria codes', () {
      final errors = <String>[];
      validator.checkCurricularAlignment({
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_invalida'],
        'criteriosEvaluacion': ['CA9.9_invalido'],
      }, errors: errors);

      expect(errors.any((e) => e.contains('unrecognized area')), isTrue);
      expect(errors.any((e) => e.contains('unrecognized criterion')), isTrue);
    });
  });
}
