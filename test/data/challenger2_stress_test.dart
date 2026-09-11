import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Adversarial Suite 1: Malformed & Corrupted JSON Payloads', () {
    test('rejects payloads missing essential root identifiers', () {
      final resUnidad = validator.validateUnidadJson({
        'tramoEtario': '0-3',
      });
      expect(resUnidad.isValid, isFalse);
      expect(resUnidad.errors.any((e) => e.contains('Missing or empty root "id"')), isTrue);

      final resCapsula = validator.validateCapsulaJson({
        'bloqueId': 'desarrollo_comunicativo',
      });
      expect(resCapsula.isValid, isFalse);
      expect(resCapsula.errors.any((e) => e.contains('Missing or empty root "id"')), isTrue);
    });

    test('rejects invalid tramoEtario in Unidad', () {
      final res = validator.validateUnidadJson({
        'id': 'test.unit',
        'tramoEtario': 'primaria',
      });
      expect(res.isValid, isFalse);
      expect(res.errors.any((e) => e.contains('Invalid "tramoEtario"')), isTrue);
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
      expect(repository.getUnidadById('inexistente'), isNull);
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
      expect(repository.unitCount, equals(0));

      repository.clear();
      expect(repository.isInitialized, isFalse);
      expect(repository.getAllUnidades(), isEmpty);
    });
  });

  group('Adversarial Suite 3: Unidad Model Boundary Conditions', () {
    test('Unidad matchesAgeBand behavior under 0-3 wildcard', () {
      const unidad = Unidad(
        id: 'test.01',
        tramoEtario: '0-3',
        orden: 1,
        titulo: LocalizedString(gl: 'gl', es: 'es'),
        subtitulo: LocalizedString(gl: 'gl', es: 'es'),
        descripcion: LocalizedString(gl: 'gl', es: 'es'),
        portadaAsset: 'assets/image.png',
        cancionPulso: CancionPulso(
          titulo: LocalizedString(gl: 'gl', es: 'es'),
          letraConPulsos: LocalizedString(gl: 'gl', es: 'es'),
          bpm: 80,
          audioAsset: LocalizedString(gl: 'a.mp3', es: 'a.mp3'),
          consignaDocente: LocalizedString(gl: 'gl', es: 'es'),
        ),
        cuento: Cuento(titulo: LocalizedString(gl: 'gl', es: 'es'), paginas: []),
        vocabulario: [],
        preguntas: [],
        exploracion: ExploracionSensorial(
          titulo: LocalizedString(gl: 'gl', es: 'es'),
          materiales: [],
          pasos: [],
          avisoSeguridad: LocalizedString(gl: 'gl', es: 'es'),
          objetivoSensorial: LocalizedString(gl: 'gl', es: 'es'),
        ),
        matematicas: MatematicasTempras(
          concepto: LocalizedString(gl: 'gl', es: 'es'),
          descripcion: LocalizedString(gl: 'gl', es: 'es'),
          accionesSugeridas: [],
          vocabularioMatematico: LocalizedString(gl: 'gl', es: 'es'),
        ),
        puenteCasa: PonteCasa(
          mensajeFamilias: LocalizedString(gl: 'gl', es: 'es'),
          actividadesSugeridas: [],
          recomendacionConversacion: LocalizedString(gl: 'gl', es: 'es'),
        ),
        curriculo: CurricularReference(
          normativa: 'Decreto 150/2022',
          etapa: 'educacion_infantil',
          ciclo: 'primeiro_ciclo_0_3',
          areas: ['area_1_crecemento_harmonia'],
          criteriosEvaluacion: ['CA1.1'],
        ),
        revision: Revision(
          autor: 'Autor',
          revisorPedagogico: 'Revisor',
          fechaRevision: '2026-09-11',
          version: '1.0.0',
          aprobadoParaAula: true,
        ),
      );

      expect(unidad.matchesAgeBand('0-2'), isTrue);
      expect(unidad.matchesAgeBand('2-3'), isTrue);
      expect(unidad.matchesAgeBand('0-3'), isTrue);
      expect(unidad.matchesAgeBand('all'), isFalse);
      expect(unidad.matchesAgeBand('primaria'), isFalse);
    });

    test('validator rejects questions lacking levels 1, 2, or 3', () {
      final errors = <String>[];
      final warnings = <String>[];

      // Missing level 3
      validator.checkReferentialIntegrityUnidad({
        'cancionPulso': {'audioAsset': 'assets/audio/test.mp3'},
        'cuento': {'paginas': [{'p': 1}]},
        'vocabulario': [{'audioAsset': 'assets/audio/test.mp3'}],
        'preguntas': [
          {'nivel': 1},
          {'nivel': 2},
        ],
        'exploracion': {
          'avisoSeguridad': {'gl': 'Aviso', 'es': 'Aviso'},
        },
        'matematicas': {},
        'puenteCasa': {},
      }, errors: errors, warnings: warnings);

      expect(errors.any((e) => e.contains('missing graduated scaffolding level 3')), isTrue);
    });

    test('validator rejects missing or blank classroom safety notice', () {
      final errors = <String>[];
      final warnings = <String>[];

      validator.checkReferentialIntegrityUnidad({
        'cancionPulso': {'audioAsset': 'assets/audio/test.mp3'},
        'cuento': {'paginas': [{'p': 1}]},
        'vocabulario': [{'audioAsset': 'assets/audio/test.mp3'}],
        'preguntas': [{'nivel': 1}, {'nivel': 2}, {'nivel': 3}],
        'exploracion': {
          'avisoSeguridad': {'gl': '   ', 'es': 'Aviso'},
        },
        'matematicas': {},
        'puenteCasa': {},
      }, errors: errors, warnings: warnings);

      expect(errors.any((e) => e.contains('avisoSeguridad must be populated')), isTrue);
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

      expect(errors.any((e) => e.contains('curriculo.normativa must be "Decreto 150/2022"')), isTrue);
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

      expect(errors.any((e) => e.contains('curriculo.etapa must be "educacion_infantil"')), isTrue);
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
