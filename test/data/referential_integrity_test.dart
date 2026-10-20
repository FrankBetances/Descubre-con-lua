import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Referential Integrity and Structural Completeness Tests', () {
    // Las canciones con pulso, que vinieron de las unidades de seis pasos
    // retiradas en M4.3: lo que aquella validación les miraba, se les sigue
    // mirando.
    test('as cancións con pulso do repositorio son válidas', () {
      final result = validator.validateCancionsConPulsoJson(jsonDecode(
          File('assets/content/cancions/cancions_con_pulso.json')
              .readAsStringSync()) as Map<String, dynamic>);
      expect(result.isValid, isTrue, reason: result.errors.join('\n'));
    });

    Map<String, dynamic> cancion(Map<String, dynamic> cambios) => {
          'cancions': [
            {
              'id': 'cancion.proba',
              'titulo': {'gl': 'Proba', 'es': 'Prueba'},
              'letraConPulsos': {'gl': '* Un * dous', 'es': '* Uno * dos'},
              'bpm': 72,
              'audioAsset': {
                'gl': 'assets/voice/gl_tutor_x.m4a',
                'es': 'assets/voice/es_tutor_x.m4a',
              },
              'consignaDocente': {'gl': 'Palmas', 'es': 'Palmas'},
              ...cambios,
            }
          ]
        };

    test('rexeita o son dunha canción fóra do paquete', () {
      final result = validator.validateCancionsConPulsoJson(cancion({
        'audioAsset': {
          'gl': 'https://example.com/stream.mp3',
          'es': 'assets/voice/es_tutor_x.m4a',
        },
      }));
      expect(result.isValid, isFalse);
      expect(result.errors.any((e) => e.contains('assets/audio/')), isTrue);
    });

    test('rexeita un verso sen pulso e unha lingua baleira', () {
      final sinPulso = validator.validateCancionsConPulsoJson(cancion({
        'letraConPulsos': {'gl': '* Un * dous\nsen marcas', 'es': '* Uno'},
      }));
      expect(sinPulso.isValid, isFalse);
      expect(sinPulso.errors.any((e) => e.contains('sin pulso')), isTrue);
      final baleira = validator.validateCancionsConPulsoJson(cancion({
        'titulo': {'gl': 'Proba', 'es': ''},
      }));
      expect(baleira.isValid, isFalse);
    });

    test(
        'validates complete structure and 4 canonical parts of academy.como_se_aprende_a_hablar.01.json',
        () {
      final file = File(
          'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json');
      expect(file.existsSync(), isTrue);

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = validator.validateCapsulaJson(
        jsonMap,
        sourcePath: 'academy.como_se_aprende_a_hablar.01.json',
      );

      expect(
        result.isValid,
        isTrue,
        reason:
            'Capsule validation failed with errors:\n${result.errors.join("\n")}',
      );
    });

    test('rejects capsule missing any of the 4 canonical sections', () {
      final capsuleMissingExample = {
        'id': 'academy.incomplete.01',
        'bloqueId': 'desarrollo_comunicativo',
        'ideaClave': {'gl': 'Idea', 'es': 'Idea'},
        'porQueImporta': {'gl': 'Importa', 'es': 'Importa'},
        'queHacerEnCasa': {'gl': 'Hacer', 'es': 'Hacer'},
        // ejemploCotidiano is missing
        'afirmaciones': [
          {
            'id': 'a1',
            'esVerdadera': true,
            'enunciado': {'gl': 'E', 'es': 'E'},
            'explicacion': {'gl': 'X', 'es': 'X'}
          }
        ],
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
