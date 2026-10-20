import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/validators/content_validator.dart';

void main() {
  final validator = ContentValidator();

  group('Curricular Alignment Tests (Decreto 150/2022 do 8 de setembro)', () {
    // La unidad del Mar (`juega.mar.01`) se retiró en M4.3 con la asamblea de
    // seis pasos. Las veinte asambleas de 1.º ciclo que quedan citan el mismo
    // decreto, la etapa y el ciclo. Sus criterios de evaluación están vacíos
    // hasta M1.1, así que aquí no se comprueba ninguno.
    for (final file in Directory('assets/content/asambleas_primeiro_ciclo')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))) {
      test('certifies curricular alignment for ${file.path}', () {
        final jsonMap =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final curriculo = jsonMap['curriculo'] as Map<String, dynamic>;
        final List<String> errors = [];
        validator.checkCurricularAlignment(curriculo, errors: errors);
        // Lo único que puede fallar es la lista de criterios vacía: es el
        // hueco de M1.1, y se dice aquí en lugar de relajar el validador.
        // Cuando M1.1 los escriba, esta excepción deja de hacer falta.
        const sinCriterios =
            'curriculo.criteriosEvaluacion must be a non-empty list';
        if ((curriculo['criteriosEvaluacion'] as List).isEmpty) {
          expect(errors, [sinCriterios]);
        } else {
          expect(errors, isEmpty,
              reason: 'Curricular validation failed: ${errors.join(", ")}');
        }
        final ref = CurricularReference.fromJson(curriculo);
        expect(ref.normativa, equals('Decreto 150/2022'));
        expect(ref.etapa, equals('educacion_infantil'));
        expect(ref.ciclo, equals('primeiro_ciclo_0_3'));
        expect(ref.hasArea(CurricularReference.area3ComunicacionRepresentacion),
            isTrue);
      });
    }

    test(
        'certifies curricular alignment for academy.como_se_aprende_a_hablar.01.json',
        () {
      final file = File(
          'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json');
      final jsonMap =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;

      final curriculo = jsonMap['curriculo'] as Map<String, dynamic>;
      final List<String> errors = [];
      validator.checkCurricularAlignment(curriculo, errors: errors);

      expect(errors, isEmpty,
          reason: 'Curricular validation failed: ${errors.join(", ")}');

      final ref = CurricularReference.fromJson(curriculo);
      expect(ref.isValidDecreto150, isTrue);
      expect(ref.hasArea(CurricularReference.area1CrecementoHarmonia), isTrue);
      expect(ref.hasArea(CurricularReference.area3ComunicacionRepresentacion),
          isTrue);
      expect(ref.hasCriterio(CurricularReference.criterioCuriosidadeSeguridade),
          isTrue); // CA1.1
      expect(ref.hasCriterio(CurricularReference.criterioComunicacionAfectiva),
          isTrue); // CA3.1
    });

    test(
        'rejects foreign or outdated regulation (e.g. Decreto 330/2009 or LOMLOE generic)',
        () {
      final oldRegulation = {
        'normativa': 'Decreto 330/2009',
        'etapa': 'educacion_infantil',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_1_crecemento_harmonia'],
        'criteriosEvaluacion': ['CA1.1'],
      };
      final List<String> errors = [];
      validator.checkCurricularAlignment(oldRegulation, errors: errors);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.contains('Decreto 150/2022')), isTrue);
    });

    test('rejects secondary or primary stage references', () {
      final wrongStage = {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_primaria',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_1_crecemento_harmonia'],
        'criteriosEvaluacion': ['CA1.1'],
      };
      final List<String> errors = [];
      validator.checkCurricularAlignment(wrongStage, errors: errors);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.contains('educacion_infantil')), isTrue);
    });

    test('rejects unapproved curricular areas', () {
      final wrongArea = {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_4_tecnoloxia_dixital'],
        'criteriosEvaluacion': ['CA1.1'],
      };
      final List<String> errors = [];
      validator.checkCurricularAlignment(wrongArea, errors: errors);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.contains('unrecognized area')), isTrue);
    });

    test('rejects unapproved criteria identifiers', () {
      final wrongCriterion = {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': ['area_1_crecemento_harmonia'],
        'criteriosEvaluacion': ['CR_INVENTADO_99'],
      };
      final List<String> errors = [];
      validator.checkCurricularAlignment(wrongCriterion, errors: errors);

      expect(errors, isNotEmpty);
      expect(errors.any((e) => e.contains('unrecognized criterion')), isTrue);
    });
  });
}
