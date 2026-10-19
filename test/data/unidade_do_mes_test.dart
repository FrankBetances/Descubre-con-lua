import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/unidade_do_mes_model.dart';

/// M3.1: la unidad del mes se lee entera, y lo que cita sigue siendo un id.
/// Que los ids existan y que el centro sea el de la asamblea lo comprueba
/// `tools/check_unidades.py`; aquí, que el modelo no pierda nada al leer.
void main() {
  final unidade = {
    'version': 1,
    'id': 'unidade.curso_4_5.03',
    'curso': 'curso_4_5',
    'orden': 3,
    'mesCalendario': 11,
    'asamblea': 'asamblea.segundo_ciclo.novembro.5_infantil',
    'centroInteres': {'gl': 'O magosto', 'es': 'El magosto'},
    'nucleo': [
      {
        'ref': '4_5.novembro.s1.chestnut',
        'objeto': {'gl': 'Unha castaña', 'es': 'Una castaña'},
      },
      {'ref': '4_5.novembro.s1.fire'},
    ],
    'descriptivas': [
      {'ref': '4_5.novembro.s2.hot'},
    ],
    'formulas': [
      {'ref': 'frase.my-turn'},
    ],
    'estructura': {
      'ref': 'frase.because',
      'nota': {'gl': 'Por que?', 'es': '¿Por qué?'},
    },
    'ordenes': [
      {
        'ref': 'frase.peel-the-chestnut',
        'usa': ['4_5.novembro.s1.chestnut'],
      },
    ],
    'realia': [
      {'gl': 'Castañas cruas', 'es': 'Castañas crudas'},
    ],
    'contraste': {
      'a': '4_5.novembro.s1.fire',
      'b': '4_5.novembro.s2.hot',
      'nota': {'gl': 'Dúas vogais', 'es': 'Dos vocales'},
    },
    'queObservar': [
      {'gl': 'Fai o xesto', 'es': 'Hace el gesto'},
      {'gl': 'Colle a castaña', 'es': 'Coge la castaña'},
    ],
    'reactivar': ['4_5.outubro.s1.leaf'],
  };

  test('a unidade do mes lese enteira', () {
    final u = UnidadeDoMes.fromJson(unidade);
    expect(u.id, 'unidade.curso_4_5.03');
    expect(u.orden, 3);
    expect(u.mesCalendario, 11);
    expect(u.centroInteres.es, 'El magosto');
    expect(u.nucleo.map((n) => n.ref),
        ['4_5.novembro.s1.chestnut', '4_5.novembro.s1.fire']);
    expect(u.nucleo.first.objeto?.gl, 'Unha castaña');
    expect(u.nucleo.last.objeto, isNull);
    expect(u.descriptivas, ['4_5.novembro.s2.hot']);
    expect(u.formulas, ['frase.my-turn']);
    expect(u.estructura?.ref, 'frase.because');
    expect(u.ordenes.single.usa, ['4_5.novembro.s1.chestnut']);
    expect(u.realia.single.es, 'Castañas crudas');
    expect(u.contraste?.b, '4_5.novembro.s2.hot');
    expect(u.queObservar, hasLength(2));
    expect(u.reactivar, ['4_5.outubro.s1.leaf']);
  });

  test('o que ensina a unidade: núcleo, descritivas, fórmulas e estrutura', () {
    expect(UnidadeDoMes.fromJson(unidade).ensina, {
      '4_5.novembro.s1.chestnut',
      '4_5.novembro.s1.fire',
      '4_5.novembro.s2.hot',
      'frase.my-turn',
      'frase.because',
    });
  });

  test('sen estrutura nin contraste, quedan en nulo', () {
    final u = UnidadeDoMes.fromJson(
        {...unidade, 'estructura': null, 'contraste': null});
    expect(u.estructura, isNull);
    expect(u.contraste, isNull);
  });

  test('o cargador le a unidade da súa ruta', () async {
    String? pedida;
    final loader = ContentAssetLoader(stringLoader: (path) async {
      pedida = path;
      return jsonEncode(unidade);
    });
    final u = await loader.loadUnidadeDoMes('curso_4_5', 3);
    expect(pedida, 'assets/content/unidades_mes/curso_4_5/unidade.03.json');
    expect(u.id, 'unidade.curso_4_5.03');
  });
}
