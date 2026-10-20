import 'package:flutter_test/flutter_test.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/curricular_model.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';

void main() {
  group('CurricularReference Model Tests', () {
    test(
        'serializes and deserializes correctly with valid Decreto 150/2022 data',
        () {
      final json = {
        'normativa': 'Decreto 150/2022',
        'etapa': 'educacion_infantil',
        'ciclo': 'primeiro_ciclo_0_3',
        'areas': [
          'area_1_crecemento_harmonia',
          'area_3_comunicacion_representacion',
        ],
        'criteriosEvaluacion': ['CA1.1', 'CA3.1'],
      };

      final ref = CurricularReference.fromJson(json);

      expect(ref.normativa, equals('Decreto 150/2022'));
      expect(ref.etapa, equals('educacion_infantil'));
      expect(ref.ciclo, equals('primeiro_ciclo_0_3'));
      expect(ref.areas, contains('area_1_crecemento_harmonia'));
      expect(ref.areas, contains('area_3_comunicacion_representacion'));
      expect(ref.criteriosEvaluacion, equals(['CA1.1', 'CA3.1']));
      expect(ref.isValidDecreto150, isTrue);
      expect(ref.hasArea('area_1_crecemento_harmonia'), isTrue);
      expect(ref.hasArea('area_2_descubrimento_contorna'), isFalse);
      expect(ref.hasCriterio('CA1.1'), isTrue);
      expect(ref.hasCriterio('CA2.1'), isFalse);

      final serialized = ref.toJson();
      expect(serialized['normativa'], equals('Decreto 150/2022'));
      expect(serialized['areas'], equals(ref.areas));
      expect(
          serialized['criteriosEvaluacion'], equals(ref.criteriosEvaluacion));

      final copy = ref.copyWith(areas: ['area_2_descubrimento_contorna']);
      expect(copy.areas, equals(['area_2_descubrimento_contorna']));
      expect(copy.normativa, equals(ref.normativa));
    });

    test('rejects non-Decreto 150/2022 regulations as invalid', () {
      const invalid = CurricularReference(
        normativa: 'LOMLOE_GENERICA',
        etapa: 'educacion_infantil',
        ciclo: 'primeiro_ciclo_0_3',
        areas: ['area_1_crecemento_harmonia'],
        criteriosEvaluacion: ['CA1.1'],
      );
      expect(invalid.isValidDecreto150, isFalse);
    });

    test('rejects invalid or unrecognized area codes', () {
      const invalidArea = CurricularReference(
        normativa: 'Decreto 150/2022',
        etapa: 'educacion_infantil',
        ciclo: 'primeiro_ciclo_0_3',
        areas: ['area_99_inexistente'],
        criteriosEvaluacion: ['CA1.1'],
      );
      expect(invalidArea.isValidDecreto150, isFalse);
    });
  });

  group('Capsula, Bloque, and ContidoCapsula Models Tests', () {
    test('instantiates complete Capsula and exposes 4 canonical sections', () {
      final capsulaJson = {
        'id': 'academy.test.01',
        'bloqueId': 'desarrollo_comunicativo',
        'orden': 1,
        'titulo': {'gl': 'Título cápsula gl', 'es': 'Título cápsula es'},
        'subtitulo': {'gl': 'Subtítulo gl', 'es': 'Subtítulo es'},
        'tiempoLecturaMinutos': 3,
        'icono': 'ear_sparkles',
        'ideaClave': {'gl': 'Idea clave gl', 'es': 'Idea clave es'},
        'porQueImporta': {
          'gl': 'Por que importa gl',
          'es': 'Por qué importa es'
        },
        'queHacerEnCasa': {'gl': 'Que facer gl', 'es': 'Qué hacer es'},
        'ejemploCotidiano': {'gl': 'Exemplo gl', 'es': 'Ejemplo es'},
        'afirmaciones': [
          {
            'id': 'af1',
            'enunciado': {'gl': 'Enunciado gl', 'es': 'Enunciado es'},
            'esVerdadera': true,
            'explicacion': {'gl': 'Explicación gl', 'es': 'Explicación es'},
          }
        ],
        'curriculo': {
          'normativa': 'Decreto 150/2022',
          'etapa': 'educacion_infantil',
          'ciclo': 'primeiro_ciclo_0_3',
          'areas': ['area_1_crecemento_harmonia'],
          'criteriosEvaluacion': ['CA1.1'],
        },
        'revision': {
          'autor': 'Equipo Academy',
          'revisorPedagogico': 'Revisor Academy',
          'fechaRevision': '2026-09-11',
          'version': '1.0.0',
          'aprobadoParaAula': true,
        },
      };

      final capsula = Capsula.fromJson(capsulaJson);

      expect(capsula.id, equals('academy.test.01'));
      expect(capsula.bloqueId, equals('desarrollo_comunicativo'));
      expect(capsula.tiempoLecturaMinutos, equals(3));
      expect(capsula.afirmaciones.length, equals(1));
      expect(capsula.afirmaciones.first.esVerdadera, isTrue);

      // Check 4 canonical sections directly and via contido helper
      expect(
          capsula.ideaClave.resolve(AppLanguage.gl), equals('Idea clave gl'));
      expect(capsula.porQueImporta.resolve(AppLanguage.es),
          equals('Por qué importa es'));
      expect(capsula.queHacerEnCasa.resolve(AppLanguage.gl),
          equals('Que facer gl'));
      expect(capsula.ejemploCotidiano.resolve(AppLanguage.es),
          equals('Ejemplo es'));

      final contido = capsula.contido;
      expect(contido.ideaClave, equals(capsula.ideaClave));
      expect(contido.porQueImporta, equals(capsula.porQueImporta));
      expect(contido.queHacerEnCasa, equals(capsula.queHacerEnCasa));
      expect(contido.ejemploCotidiano, equals(capsula.ejemploCotidiano));

      // Serialization round-trip
      final serialized = capsula.toJson();
      expect(serialized['id'], equals('academy.test.01'));
      expect(serialized['bloqueId'], equals('desarrollo_comunicativo'));
    });

    test('validates the 5 canonical developmental blocks', () {
      expect(Bloque.todos.length, equals(5));

      final b1 = Bloque.byId('desarrollo_comunicativo');
      expect(b1, isNotNull);
      expect(b1!.orden, equals(1));
      expect(b1.titulo.resolve(AppLanguage.gl),
          contains('Como se aprende a falar'));

      final b2 = Bloque.byOrden(2);
      expect(b2, isNotNull);
      expect(b2!.id, equals(Bloque.rutinasYBanoDeLenguajeId));

      final b3 = Bloque.byOrden(3);
      expect(b3!.id, equals(Bloque.turnosYAtencionConjuntaId));

      final b4 = Bloque.byOrden(4);
      expect(b4!.id, equals(Bloque.juegoMovimientoSinPantallasId));

      final b5 = Bloque.byOrden(5);
      expect(b5!.id, equals(Bloque.bilinguismoYCulturaId));
    });
  });
}
