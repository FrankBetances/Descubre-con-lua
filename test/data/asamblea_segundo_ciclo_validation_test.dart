import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Validador Curricular Segundo Ciclo · Unidades de Setembro', () {
    test(
        '4.º de Infantil (Acción Expandida) cumpre todas as regras curriculares',
        () {
      final file = File(
          'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.setembro.4_infantil.json');
      expect(file.existsSync(), isTrue,
          reason: 'O ficheiro JSON de 4º infantil debe existir');

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = validator.validateAsambleaSegundoCicloJson(jsonMap,
          sourcePath: file.path);

      expect(result.isValid, isTrue,
          reason: 'Erros atopados: ${result.errors.join("\n")}');
      expect(result.errors, isEmpty);
    });

    test(
        '5.º de Infantil (Dramatizado e Narrativo) cumpre todas as regras curriculares',
        () {
      final file = File(
          'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.setembro.5_infantil.json');
      expect(file.existsSync(), isTrue,
          reason: 'O ficheiro JSON de 5º infantil debe existir');

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = validator.validateAsambleaSegundoCicloJson(jsonMap,
          sourcePath: file.path);

      expect(result.isValid, isTrue,
          reason: 'Erros atopados: ${result.errors.join("\n")}');
      expect(result.errors, isEmpty);
    });

    test(
        '6.º de Infantil (Transaccional e Pragmático) cumpre todas as regras curriculares',
        () {
      final file = File(
          'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.setembro.6_infantil.json');
      expect(file.existsSync(), isTrue,
          reason: 'O ficheiro JSON de 6º infantil debe existir');

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result = validator.validateAsambleaSegundoCicloJson(jsonMap,
          sourcePath: file.path);

      expect(result.isValid, isTrue,
          reason: 'Erros atopados: ${result.errors.join("\n")}');
      expect(result.errors, isEmpty);
    });

    test(
        'Cápsula Academy de Setembro do Segundo Ciclo cumpre o validador de cápsulas',
        () {
      final file = File(
          'assets/content/capsulas/academy.segundo_ciclo.setembro.01.json');
      expect(file.existsSync(), isTrue,
          reason: 'A cápsula Academy de Setembro debe existir');

      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final result =
          validator.validateCapsulaJson(jsonMap, sourcePath: file.path);

      expect(result.isValid, isTrue,
          reason: 'Erros atopados: ${result.errors.join("\n")}');
      expect(result.errors, isEmpty);
    });
  });

  group(
      'Validador Curricular Segundo Ciclo · Detección de Defectos Adversariais',
      () {
    test('Rexeita asemblea con duración incorrecta en fases (non suma 600s)',
        () {
      final file = File(
          'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.setembro.4_infantil.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      // Modificamos a duración da fase 1 a 60s en troques de 90s
      final fases = List<Map<String, dynamic>>.from(jsonMap['fases']);
      final fase1 = Map<String, dynamic>.from(fases[0]);
      fase1['duracionSegundos'] = 60;
      fases[0] = fase1;
      jsonMap['fases'] = fases;

      final result = validator.validateAsambleaSegundoCicloJson(jsonMap);
      expect(result.isValid, isFalse);
      expect(
          result.errors
              .any((e) => e.contains('duracionSegundos must be exactly 90s')),
          isTrue);
      expect(
          result.errors.any((e) => e.contains(
              'Total assembly duration must sum exactly 600 seconds')),
          isTrue);
    });

    test('Rexeita termos clínicos prohibidos', () {
      final file = File(
          'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.setembro.4_infantil.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      jsonMap['titulo']['gl'] = 'Setembro: Terapia e diagnóstico da linguaxe';

      final result = validator.validateAsambleaSegundoCicloJson(jsonMap);
      expect(result.isValid, isFalse);
      expect(
          result.errors
              .any((e) => e.contains('prohibited clinical/diagnostic term')),
          isTrue);
    });

    test('Rexeita fase 3 (Core TPR) sen comandos L3', () {
      final file = File(
          'assets/content/asambleas_segundo_ciclo/asamblea.segundo_ciclo.setembro.4_infantil.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final fases = List<Map<String, dynamic>>.from(jsonMap['fases']);
      final fase3 = Map<String, dynamic>.from(fases[2]);
      fase3['comandosL3'] = [];
      fases[2] = fase3;
      jsonMap['fases'] = fases;

      final result = validator.validateAsambleaSegundoCicloJson(jsonMap);
      expect(result.isValid, isFalse);
      expect(
          result.errors.any((e) => e.contains(
              'Phase 3 (Core TPR Challenge) must contain at least 1 L3 command')),
          isTrue);
    });
  });
}
