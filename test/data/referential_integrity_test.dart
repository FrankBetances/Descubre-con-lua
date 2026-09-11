import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Referential Integrity and Structural Completeness Tests', () {
    test('validates complete structure and referential integrity of juega.mar.01.json', () {
      final file = File('assets/content/unidades/juega.mar.01.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = validator.validateUnidadJson(jsonMap, sourcePath: 'juega.mar.01.json');

      expect(
        result.isValid,
        isTrue,
        reason: 'Unit validation failed with errors:\n${result.errors.join("\n")}',
      );
    });

    test('validates complete structure and 4 canonical parts of academy.como_se_aprende_a_hablar.01.json', () {
      final file = File('assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json');
      expect(file.existsSync(), isTrue);

      final jsonMap = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = validator.validateCapsulaJson(
        jsonMap,
        sourcePath: 'academy.como_se_aprende_a_hablar.01.json',
      );

      expect(
        result.isValid,
        isTrue,
        reason: 'Capsule validation failed with errors:\n${result.errors.join("\n")}',
      );
    });

    test('rejects unit missing mandatory safety notice in exploracion', () {
      final unitWithoutSafety = {
        'id': 'juega.insecure.01',
        'tramoEtario': '0-3',
        'cancionPulso': {
          'audioAsset': {'gl': 'assets/audio/test.mp3', 'es': 'assets/audio/test.mp3'},
        },
        'cuento': {
          'paginas': [{'orden': 1}]
        },
        'vocabulario': [
          {
            'audioAsset': {'gl': 'assets/audio/v.mp3', 'es': 'assets/audio/v.mp3'},
          }
        ],
        'preguntas': [
          {'nivel': 1},
          {'nivel': 2},
          {'nivel': 3},
        ],
        'exploracion': {
          'titulo': {'gl': 'Exp', 'es': 'Exp'},
          // avisoSeguridad is deliberately missing
        },
        'matematicas': {},
        'puenteCasa': {},
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'primeiro_ciclo_0_3',
          'areas': ['area_1_crecemento_harmonia'],
          'criteriosEvaluacion': ['CA1.1'],
        },
      };

      final result = validator.validateUnidadJson(unitWithoutSafety);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('avisoSeguridad')), isTrue);
    });

    test('rejects unit missing any of the 3 graduated scaffolding question levels', () {
      final unitMissingLevel3 = {
        'id': 'juega.incomplete_questions.01',
        'tramoEtario': '0-3',
        'cancionPulso': {
          'audioAsset': {'gl': 'assets/audio/test.mp3', 'es': 'assets/audio/test.mp3'},
        },
        'cuento': {
          'paginas': [{'orden': 1}]
        },
        'vocabulario': [
          {
            'audioAsset': {'gl': 'assets/audio/v.mp3', 'es': 'assets/audio/v.mp3'},
          }
        ],
        'preguntas': [
          {'nivel': 1},
          {'nivel': 2},
          // Missing level 3
        ],
        'exploracion': {
          'avisoSeguridad': {'gl': 'Aviso', 'es': 'Aviso'},
        },
        'matematicas': {},
        'puenteCasa': {},
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'primeiro_ciclo_0_3',
          'areas': ['area_1_crecemento_harmonia'],
          'criteriosEvaluacion': ['CA1.1'],
        },
      };

      final result = validator.validateUnidadJson(unitMissingLevel3);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('missing graduated scaffolding level 3')), isTrue);
    });

    test('rejects audio assets with non-offline or remote paths', () {
      final unitWithRemoteAudio = {
        'id': 'juega.remote_audio.01',
        'tramoEtario': '0-3',
        'cancionPulso': {
          'audioAsset': {
            'gl': 'https://example.com/stream.mp3',
            'es': 'assets/audio/test.mp3',
          },
        },
        'cuento': {'paginas': [{'orden': 1}]},
        'vocabulario': [{'audioAsset': {'gl': 'assets/audio/v.mp3', 'es': 'assets/audio/v.mp3'}}],
        'preguntas': [{'nivel': 1}, {'nivel': 2}, {'nivel': 3}],
        'exploracion': {'avisoSeguridad': {'gl': 'A', 'es': 'A'}},
        'matematicas': {},
        'puenteCasa': {},
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'primeiro_ciclo_0_3',
          'areas': ['area_1_crecemento_harmonia'],
          'criteriosEvaluacion': ['CA1.1'],
        },
      };

      final result = validator.validateUnidadJson(unitWithRemoteAudio);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('assets/audio/')), isTrue);
    });

    test('rejects capsule missing any of the 4 canonical sections', () {
      final capsuleMissingExample = {
        'id': 'academy.incomplete.01',
        'bloqueId': 'desarrollo_comunicativo',
        'ideaClave': {'gl': 'Idea', 'es': 'Idea'},
        'porQueImporta': {'gl': 'Importa', 'es': 'Importa'},
        'queHacerEnCasa': {'gl': 'Hacer', 'es': 'Hacer'},
        // ejemploCotidiano is missing
        'afirmaciones': [{'id': 'a1', 'esVerdadera': true, 'enunciado': {'gl': 'E', 'es': 'E'}, 'explicacion': {'gl': 'X', 'es': 'X'}}],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'primeiro_ciclo_0_3',
          'areas': ['area_1_crecemento_harmonia'],
          'criteriosEvaluacion': ['CA1.1'],
        },
      };

      final result = validator.validateCapsulaJson(capsuleMissingExample);
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('ejemploCotidiano')), isTrue);
    });
  });
}
