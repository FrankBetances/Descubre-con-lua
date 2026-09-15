import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('ContentValidator placeholderPattern Case Sensitivity Tests', () {
    test(
        'allows legitimate usage of lowercase "todo" and capitalized "Todo" (Spanish/Galician for "all")',
        () {
      final validSamples = [
        {
          'gl': 'e, sobre todo, dan contexto',
          'es': 'y, sobre todo, dan contexto'
        },
        {
          'gl': 'Todo o alumnado participa na asemblea',
          'es': 'Todo el alumnado participa en la asamblea'
        },
        {
          'gl': 'Recollemos todo o material con agarimo',
          'es': 'Recogemos todo el material con cariño'
        },
        {
          'gl': 'Facemos as actividades todos xuntos',
          'es': 'Hacemos las actividades todos juntos'
        },
        {
          'gl': 'Hai de todo no recanto dos xogos',
          'es': 'Hay de todo en el rincón de los juegos'
        },
        {
          'gl': 'Acollida con todo o cariño',
          'es': 'Acogida con todo el cariño'
        },
        {
          'gl': 'O método pedagóxico é activo',
          'es': 'El método pedagógico es activo'
        },
      ];

      for (final sample in validSamples) {
        final node = {'descripcion': sample};
        final List<String> errors = [];
        validator.checkBilingualParity(node, errors: errors);
        expect(
          errors,
          isEmpty,
          reason:
              'Validator falsely flagged valid text containing "todo": "${sample['gl']}"',
        );
      }
    });

    test(
        'strictly rejects developer placeholder markers (TODO, TBD, PLACEHOLDER, PENDIENTE, PENDENTE, LOREM IPSUM)',
        () {
      final placeholderSamples = [
        'TODO: engadir gravación de audio',
        'TBD: pendente de confirmación',
        'PLACEHOLDER texto provisional',
        'PENDIENTE de revisión polo equipo',
        'PENDENTE de validación curricular',
        'LOREM IPSUM dolor sit amet',
      ];

      for (final placeholder in placeholderSamples) {
        final node = {
          'descripcion': {
            'gl': placeholder,
            'es': 'Texto válido en castellano',
          }
        };
        final List<String> errors = [];
        validator.checkBilingualParity(node, errors: errors);
        expect(
          errors,
          isNotEmpty,
          reason:
              'Validator failed to reject forbidden placeholder: "$placeholder"',
        );
        expect(errors.first, contains('contains forbidden placeholder'));
      }
    });

    test('direct RegExp pattern assertions for placeholderPattern', () {
      // Palabras corrientes en gl/es: NO son marcadores.
      expect(ContentValidator.hasPlaceholder('todo'), isFalse);
      expect(ContentValidator.hasPlaceholder('Todo'), isFalse);
      expect(ContentValidator.hasPlaceholder('sobre todo'), isFalse);
      expect(ContentValidator.hasPlaceholder('todos'), isFalse);
      expect(ContentValidator.hasPlaceholder('método'), isFalse);
      expect(ContentValidator.hasPlaceholder('tbd'), isTrue);
      expect(ContentValidator.hasPlaceholder('placeholder'), isTrue);
      expect(ContentValidator.hasPlaceholder('pendiente'), isFalse);
      expect(ContentValidator.hasPlaceholder('pendente'), isFalse);

      // Marcadores de desarrollo: SÍ lo son.
      // `placeholder`, `tbd` y `lorem ipsum` no son palabras del contenido,
      // así que se rechazan también en minúscula (test/data/clinical_terms_blacklist_test.dart).
      expect(ContentValidator.hasPlaceholder('TODO'), isTrue);
      expect(ContentValidator.hasPlaceholder('TODO: fix'), isTrue);
      expect(ContentValidator.hasPlaceholder('TBD'), isTrue);
      expect(ContentValidator.hasPlaceholder('TBD: check'), isTrue);
      expect(ContentValidator.hasPlaceholder('PLACEHOLDER'), isTrue);
      expect(ContentValidator.hasPlaceholder('PENDIENTE'), isTrue);
      expect(ContentValidator.hasPlaceholder('PENDENTE'), isTrue);
      expect(ContentValidator.hasPlaceholder('LOREM IPSUM'), isTrue);
    });
  });
}
