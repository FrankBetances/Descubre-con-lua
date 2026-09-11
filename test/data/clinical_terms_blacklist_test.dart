import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Clinical Terms Blacklist Linter Tests', () {
    test(
        'confirms zero clinical terms in assets/content/unidades/juega.mar.01.json',
        () {
      final file = File('assets/content/unidades/juega.mar.01.json');
      expect(file.existsSync(), isTrue);

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<String> errors = [];
      validator.checkClinicalTerms(jsonMap,
          path: 'juega.mar.01', errors: errors);

      expect(
        errors,
        isEmpty,
        reason:
            'juega.mar.01.json contained prohibited clinical terms:\n${errors.join("\n")}',
      );
    });

    test(
        'confirms zero clinical terms in assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json',
        () {
      final file = File(
          'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json');
      expect(file.existsSync(), isTrue);

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final List<String> errors = [];
      validator.checkClinicalTerms(jsonMap,
          path: 'academy.hablar.01', errors: errors);

      expect(
        errors,
        isEmpty,
        reason:
            'academy.como_se_aprende_a_hablar.01.json contained prohibited clinical terms:\n${errors.join("\n")}',
      );
    });

    test(
        'detects prohibited medical/diagnostic terms across morphological variants',
        () {
      final prohibitedSamples = [
        'O paciente debe realizar este exercicio.',
        'Actividade para detectar síntomas precoces.',
        'Estratexia terapéutica para a intervención.',
        'Sesión de terapia individual no fogar.',
        'Non se debe diagnosticar antes dos dous anos.',
        'Os especialistas diagnosticaron o cadro.',
        'Signos de alerta ou patoloxía da fala.',
        'Patoloxías do desenvolvemento infantil.',
        'Patrón clínico patológico observado.',
        'Causas do trastorno do desenvolvemento.',
        'Cadro con déficit de atención.',
        'Plan de tratamiento familiar.',
        'Programa de tratamento personalizado.',
        'Sinais de retraso clínico na fala.',
        'Cadros con retrasos clínicos evidentes.',
        'Prevención de dislalias funcionais.',
        'Comportamento dislálico identificado.',
        'Detección temperá de dislexias no primeiro ciclo.',
        'Cadro disléxico no ámbito escolar.',
        'Programa de rehabilitación logopédica.',
        'Rehabilitar o patrón respiratorio.',
        'Equipo de traballo con profesionais rehabilitadores.',
        'Protocolo de criba clínica audiolóxica.',
        'Resultados dos cribados neonatais.',
        'Protocolo de cribaxe neonatal na área sanitaria.',
        'Ferramenta de screening infantil.',
        'Mellor pronóstico a longo prazo.',
        'Comprobación de afasia ou disfasia no neno.',
      ];

      for (final sample in prohibitedSamples) {
        final node = {
          'texto': {'gl': sample, 'es': sample}
        };
        final List<String> errors = [];
        validator.checkClinicalTerms(node, path: 'test_node', errors: errors);

        expect(
          errors,
          isNotEmpty,
          reason:
              'Linter failed to catch prohibited clinical term in: "$sample"',
        );
      }
    });

    test('allows approved pedagogical equivalents without false positives', () {
      final approvedPedagogicalSamples = [
        'Acompañamento educativo e xogo guiado na escola infantil.',
        'Cada nena e neno ten o seu propio ritmo individual de desenvolvemento.',
        'A estimulación comunicativa a través do afecto e a conversa.',
        'Manifestacións comunicativas e xogos vocais na asemblea.',
        'Observación atenta no aula de infantil durante as rutinas.',
        'Xogos de movemento e psicomotricidade sen pantallas.',
        'Conversas cálidas e miradas compartidas co bebé.',
        'O tratamento de auga na ría de Vigo para a depuración de moluscos.',
        'El tratamiento de agua en la ría de Vigo para la depuración.',
      ];

      for (final sample in approvedPedagogicalSamples) {
        final node = {
          'texto': {'gl': sample, 'es': sample}
        };
        final List<String> errors = [];
        validator.checkClinicalTerms(node,
            path: 'approved_node', errors: errors);

        expect(
          errors,
          isEmpty,
          reason:
              'Linter falsely flagged approved pedagogical term in: "$sample"',
        );
      }
    });

    test(
        'safely exempts tratamento de auga and tratamiento de agua in maritime context',
        () {
      final samples = [
        'O tratamento de auga na ría de Vigo para a depuración de moluscos',
        'El tratamiento de agua en la ría de Vigo para la depuración',
      ];
      for (final sample in samples) {
        final node = {
          'texto': {'gl': sample, 'es': sample}
        };
        final List<String> errors = [];
        validator.checkClinicalTerms(node, path: 'water_node', errors: errors);
        expect(
          errors,
          isEmpty,
          reason:
              'Linter falsely flagged maritime water treatment term in: "$sample"',
        );
      }
    });

    test('rejects English placeholder keyword in any case variant', () {
      for (final token in [
        'placeholder',
        'PLACEHOLDER',
        'Placeholder',
        'PlAcEhOlDeR'
      ]) {
        final node = {
          'texto': {'gl': token, 'es': 'Texto válido en castellano'}
        };
        final List<String> errors = [];
        validator.checkBilingualParity(node,
            path: 'placeholder_test', errors: errors);
        expect(
          errors,
          isNotEmpty,
          reason: 'Validator failed to reject placeholder token "$token"',
        );
      }
    });
  });
}
