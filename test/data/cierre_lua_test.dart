import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/data/models/capsula_model.dart';

/// El cierre de Lúa, sujeto por un test y no por la memoria de nadie.
///
/// Las cápsulas de Academy son lo que la familia lee en casa, y hasta ahora la
/// gata no aparecía en ninguna de las cinco: su única mención en esos JSON era
/// el nombre del autor. `luaDice` cierra ese hueco, y este fichero existe para
/// que la cápsula número seis no se escriba sin él: un campo de contenido que
/// ningún gate vigila se queda sin escribir a la primera prisa.
void main() {
  final directorio = Directory('assets/content/capsulas');

  List<MapEntry<String, Map<String, dynamic>>> capsulas() => directorio
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .map((f) => MapEntry(
            f.uri.pathSegments.last,
            jsonDecode(f.readAsStringSync()) as Map<String, dynamic>,
          ))
      .toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  group('toda cápsula de familia cierra con Lúa', () {
    test('las cápsulas de Academy traen luaDice en las dos lenguas', () {
      final deFamilia = capsulas().where((e) =>
          DestinatarioCapsula.desdeClave(e.value['destinatario']?.toString()) ==
          DestinatarioCapsula.familia);

      expect(deFamilia, isNotEmpty,
          reason: 'No hay ninguna cápsula de familia que comprobar.');

      for (final entrada in deFamilia) {
        final capsula = Capsula.fromJson(entrada.value);
        expect(capsula.luaDice, isNotNull,
            reason: '${entrada.key}: una cápsula que lee la familia tiene que '
                'cerrar con Lúa. Añade "luaDice" con "gl" y "es".');
        expect(capsula.luaDice!.hasParity, isTrue,
            reason: '${entrada.key}: "luaDice" necesita las dos lenguas.');
        // Lúa habla en primera persona a la persona adulta: es quien lee. Si
        // el cierre no la nombra, deja de ser el cierre de la gata y pasa a ser
        // una quinta sección sin encabezado.
        for (final lengua in AppLanguage.deInterfaz) {
          expect(capsula.luaDice!.resolve(lengua), contains('Lúa'),
              reason: '${entrada.key}: el cierre en ${lengua.code} no nombra '
                  'a Lúa.');
        }
      }
    });
  });

  group('el modelo no pinta medio cierre', () {
    Map<String, dynamic> base(Map<String, dynamic> extra) => {
          'id': 'test.capsula.01',
          'bloqueId': 'desarrollo_comunicativo',
          'ideaClave': {'gl': 'a', 'es': 'a'},
          'porQueImporta': {'gl': 'b', 'es': 'b'},
          'queHacerEnCasa': {'gl': 'c', 'es': 'c'},
          'ejemploCotidiano': {'gl': 'd', 'es': 'd'},
          'afirmaciones': const [],
          'curriculo': const {
            'normativa': 'Decreto 150/2022',
            'etapa': 'educacion_infantil',
            'ciclo': 'primeiro_ciclo_0_3',
            'areas': ['area_1_crecemento_harmonia'],
            'criteriosEvaluacion': ['CA1.1'],
          },
          'revision': const {
            'autor': 'Equipo Pedagóxico',
            'revisorPedagogico': 'Revisor',
            'fechaRevision': '2026-09-14',
            'version': '1.0.0',
            'aprobadoParaAula': true,
          },
          ...extra,
        };

    test('sin el campo, luaDice es nulo y la cápsula se lee igual', () {
      expect(Capsula.fromJson(base({})).luaDice, isNull);
    });

    test('con una sola lengua se descarta entero', () {
      // Media frase en gallego y nada en castellano dejaría la pantalla del
      // cierre en blanco, que se ve peor que no pintar el cierre.
      final soloGl = Capsula.fromJson(base({
        'luaDice': {'gl': 'Son Lúa.', 'es': '   '},
      }));
      expect(soloGl.luaDice, isNull);
    });

    test('con las dos lenguas sobrevive al viaje de ida y vuelta', () {
      final original = Capsula.fromJson(base({
        'luaDice': {'gl': 'Son Lúa.', 'es': 'Soy Lúa.'},
      }));
      expect(original.luaDice, isNotNull);
      expect(Capsula.fromJson(original.toJson()).luaDice,
          equals(original.luaDice));
    });

    test('las cuatro secciones canónicas siguen siendo cuatro', () {
      // `contido` es el agregado de las secciones canónicas. El cierre de Lúa
      // NO es una quinta: si un día entra ahí, la validación referencial y el
      // lector empiezan a contar cinco y esto avisa.
      final conCierre = Capsula.fromJson(base({
        'luaDice': {'gl': 'Son Lúa.', 'es': 'Soy Lúa.'},
      }));
      final sinCierre = Capsula.fromJson(base({}));
      expect(conCierre.contido, equals(sinCierre.contido));
    });
  });
}
