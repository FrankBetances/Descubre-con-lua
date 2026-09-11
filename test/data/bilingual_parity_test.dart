import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Bilingual Parity Tests (1:1 Galego / Castellano)', () {
    test('verifies 100% 1:1 bilingual parity on juega.mar.01.json', () {
      final file = File('assets/content/unidades/juega.mar.01.json');
      expect(file.existsSync(), isTrue, reason: 'juega.mar.01.json must exist');

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<String> errors = [];
      validator.checkBilingualParity(jsonMap,
          path: 'juega.mar.01', errors: errors);

      expect(
        errors,
        isEmpty,
        reason:
            'juega.mar.01.json failed bilingual parity check:\n${errors.join("\n")}',
      );
    });

    test(
        'verifies 100% 1:1 bilingual parity on academy.como_se_aprende_a_hablar.01.json',
        () {
      final file = File(
          'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json');
      expect(file.existsSync(), isTrue,
          reason: 'academy.como_se_aprende_a_hablar.01.json must exist');

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<String> errors = [];
      validator.checkBilingualParity(jsonMap,
          path: 'academy.hablar.01', errors: errors);

      expect(
        errors,
        isEmpty,
        reason:
            'academy.como_se_aprende_a_hablar.01.json failed parity check:\n${errors.join("\n")}',
      );
    });

    test('rejects asymmetric node with missing castellano (gl only)', () {
      final asymmetricGlOnly = {
        'titulo': {'gl': 'Só en galego'},
      };
      final List<String> errors = [];
      validator.checkBilingualParity(asymmetricGlOnly, errors: errors);
      expect(errors, isNotEmpty);
      expect(errors.first, contains('missing "es"'));
    });

    test('rejects asymmetric node with missing galego (es only)', () {
      final asymmetricEsOnly = {
        'titulo': {'es': 'Solo en castellano'},
      };
      final List<String> errors = [];
      validator.checkBilingualParity(asymmetricEsOnly, errors: errors);
      expect(errors, isNotEmpty);
      expect(errors.first, contains('missing "gl"'));
    });

    test('rejects whitespace-only text in bilingual nodes', () {
      final blankNode = {
        'titulo': {'gl': '   \n\t  ', 'es': 'Castellano válido'},
      };
      final List<String> errors = [];
      validator.checkBilingualParity(blankNode, errors: errors);
      expect(errors, isNotEmpty);
      expect(errors.first, contains('"gl" is missing, not a string, or blank'));
    });

    test('rejects placeholder values (TODO / TBD / Pendiente)', () {
      final placeholderNode = {
        'descripcion': {
          'gl': 'TODO: traducir logo',
          'es': 'Texto en castellano'
        },
      };
      final List<String> errors = [];
      validator.checkBilingualParity(placeholderNode, errors: errors);
      expect(errors, isNotEmpty);
      expect(errors.first, contains('contains forbidden placeholder'));
    });

    test('certifies Galician linguistic quality according to RAG standard', () {
      final unitFile = File('assets/content/unidades/juega.mar.01.json');
      final content = unitFile.readAsStringSync();

      // Official RAG maritime vocabulary checks
      expect(content, contains('cuncha'));
      expect(content, contains('gaivota'));
      expect(content, anyOf(contains('mexillón'), contains('Mexillón')));
      expect(content, anyOf(contains('peixe'), contains('Peixe')));
      expect(content, contains('praia de Samil'));
      expect(content, contains('agarimo'));
    });
  });
}
