import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/localization/localized_string.dart';

import 'package:descubre_con_lua/data/loaders/content_asset_loader.dart';
import 'package:descubre_con_lua/data/models/rexistro_frases_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
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
    'cancion': {'titulo': 'Chestnuts, hot and sweet'},
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
    expect(u.cancion, 'Chestnuts, hot and sweet');
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
        {...unidade, 'estructura': null, 'contraste': null, 'cancion': null});
    expect(u.cancion, isNull);
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

  // Las del repositorio: que el modelo las lea sin perder el núcleo ni las
  // órdenes. Lo demás —ids, centro, tamaños— lo mira tools/check_unidades.py.
  test('as unidades do repositorio lense enteiras', () {
    final ficheiros = Directory('assets/content/unidades_mes')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    expect(ficheiros, isNotEmpty);
    for (final f in ficheiros) {
      final datos = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
      final u = UnidadeDoMes.fromJson(datos);
      expect(u.id, datos['id'], reason: f.path);
      expect(u.nucleo, hasLength((datos['nucleo'] as List).length),
          reason: f.path);
      expect(u.ordenes, isNotEmpty, reason: f.path);
      for (final o in u.ordenes) {
        expect(u.ensina.containsAll(o.usa), isTrue,
            reason: '${f.path} ${o.ref}');
      }
    }
  });

  // M3.9: el calendario pinta el núcleo resuelto. Si una pieza no se
  // resolviera, la tarjeta del mes saldría con un hueco sin aviso.
  group('o núcleo resólvese no banco e no rexistro', () {
    late ProgramaTpr programa;
    late RexistroDeFrases rexistro;

    setUpAll(() async {
      programa = await ProgramaTpr.cargar(
          stringLoader: (path) => File(path).readAsString());
      rexistro = RexistroDeFrases.fromJson(
          jsonDecode(File(RexistroDeFrases.asset).readAsStringSync())
              as Map<String, dynamic>);
    });

    test('unha orde do rexistro trae o seu xesto e o seu obxecto', () {
      final peza = resolverPeza('frase.cmd.outubro.0_2.02',
          programa: programa,
          rexistro: rexistro,
          objeto: const LocalizedString(gl: 'Unha pluma', es: 'Una pluma'));
      expect(peza?.en, 'Tummy');
      expect(peza?.significado, isNull);
      expect(peza?.xesto.hasParity, isTrue);
      expect(peza?.objeto?.gl, 'Unha pluma');
    });

    test('unha palabra do banco trae o que quere dicir e o seu xesto', () {
      final peza = resolverPeza('0_2.outubro.s1.forehead',
          programa: programa, rexistro: rexistro);
      expect(peza?.en, 'Forehead');
      expect(peza?.significado?.gl, 'Fronte');
      expect(peza?.xesto.hasParity, isTrue);
      expect(resolverPeza('non.existe', programa: programa, rexistro: rexistro),
          isNull);
    });

    test('as 50 unidades resolven o núcleo enteiro', () {
      final ficheiros = Directory('assets/content/unidades_mes')
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'));
      var vistas = 0;
      for (final f in ficheiros) {
        final u = UnidadeDoMes.fromJson(
            jsonDecode(f.readAsStringSync()) as Map<String, dynamic>);
        final nucleo = nucleoResolto(u, programa: programa, rexistro: rexistro);
        expect(nucleo.map((p) => p.ref), u.nucleo.map((n) => n.ref),
            reason: f.path);
        for (final p in nucleo) {
          expect(p.en.trim(), isNotEmpty, reason: '${f.path} ${p.ref}');
          expect(p.xesto.hasParity, isTrue, reason: '${f.path} ${p.ref}');
        }
        vistas++;
      }
      expect(vistas, 50);
    });
  });
}
