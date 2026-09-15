import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Milestone 2 Challenger Adversarial Probes', () {
    test('PROBE-CLIN-01: Probes clinical verb and plural inflections', () {
      final terms = [
        'diagnosticaron',
        'diagnosticouse',
        'diagnosticado',
        'retrasos clínicos',
        'cribados',
        'cribaxe',
        'dislálico',
        'disléxicos',
        'rehabilitador',
      ];

      for (final term in terms) {
        final node = {
          'texto': {'gl': 'Atención: $term', 'es': 'Atención: $term'}
        };
        final List<String> errors = [];
        validator.checkClinicalTerms(node, errors: errors);
        expect(
          errors,
          isNotEmpty,
          reason:
              'Vulnerability: ContentValidator failed to catch clinical inflection "$term"',
        );
      }
    });

    test('PROBE-ASYM-01: Probes placeholder token rejection', () {
      final placeholders = [
        'placeholder',
        'PLACEHOLDER',
        'Placeholder value',
      ];

      for (final p in placeholders) {
        final node = {
          'titulo': {'gl': p, 'es': 'Texto válido'}
        };
        final List<String> errors = [];
        validator.checkBilingualParity(node, errors: errors);
        expect(
          errors,
          isNotEmpty,
          reason:
              'Vulnerability: ContentValidator accepted untranslated token "$p"',
        );
      }
    });

    test(
        'PROBE-FP-01: Probes false positive resistance on legitimate non-clinical terms',
        () {
      final nonClinicalTerms = [
        'O tratamento de auga na ría de Vigo',
        'El tratamiento de agua en la ría de Vigo',
      ];

      for (final term in nonClinicalTerms) {
        final node = {
          'texto': {'gl': term, 'es': term}
        };
        final List<String> errors = [];
        validator.checkClinicalTerms(node, errors: errors);
        expect(
          errors,
          isEmpty,
          reason:
              'False Positive: ContentValidator falsely flagged legitimate term "$term"',
        );
      }
    });
  });
}
