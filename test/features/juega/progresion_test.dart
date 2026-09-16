import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/data/models/progresion_model.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';

/// La asamblea de hoy no es la de ayer.
///
/// Frank: «las asambleas deben ser distintas cada día; es posible que
/// mantengan una misma temática durante varios días, pero no puede ser la
/// misma un mes completo». Esto lo mide sobre el contenido real del paquete:
/// para cada uno de los 50 meses-grupo, los 20 días componen fases núcleo
/// distintas —consigna u órdenes— y nunca dos días seguidos iguales.
void main() {
  late ContentRepository repository;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    repository = ContentRepository();
    await repository.initialize();
  });

  test('hai unha progresión por tramo, con 4 semanas x 5 días', () {
    final todas = repository.getAllProgresionsSync();
    expect(todas.map((p) => p.clave).toList(), [
      'primeiro_ciclo.0_2',
      'primeiro_ciclo.2_3',
      'segundo_ciclo.4',
      'segundo_ciclo.5',
      'segundo_ciclo.6',
    ]);
    for (final p in todas) {
      expect(p.semanas.length, 4, reason: p.clave);
      expect(p.dias.length, 20, reason: p.clave);
      final claves = p.dias.map((d) => '${d.semana}/${d.dia}').toSet();
      expect(claves.length, 20, reason: '${p.clave}: días repetidos');
      for (final d in p.dias) {
        expect(d.foco.gl.trim(), isNotEmpty,
            reason: '${p.clave} ${d.semana}/${d.dia}');
        expect(d.foco.es.trim(), isNotEmpty,
            reason: '${p.clave} ${d.semana}/${d.dia}');
        expect(d.consigna.gl.trim(), isNotEmpty);
        expect(d.consigna.es.trim(), isNotEmpty);
        expect(d.comandos, isNotEmpty);
      }
    }
  });

  test(
      'en cada mes e grupo, os 20 días son distintos e non se repite o de onte',
      () {
    var mesesGrupo = 0;
    String pegada(DiaDeProgresion d, List fases) {
      final core = d.aplicarA(fases.cast()).firstWhere(
          (f) => f.comandosL3.isNotEmpty,
          orElse: () => fases.first);
      return '${core.consignaDocente.gl}|${core.comandosL3.map((c) => c.textoIngles).join(',')}';
    }

    for (final a in repository.getAllAsambleasPrimeiroCicloSync()) {
      final p =
          repository.getProgresionSync('primeiro_ciclo.${a.tramo.clave}')!;
      final pegadas = [for (final d in p.dias) pegada(d, a.fases)];
      expect(pegadas.toSet().length, 20, reason: a.id);
      for (var i = 1; i < pegadas.length; i++) {
        expect(pegadas[i], isNot(pegadas[i - 1]), reason: '${a.id} día $i');
      }
      mesesGrupo++;
    }
    for (final a in repository.getAllAsambleasSegundoCicloSync()) {
      final clave = switch (a.nivel.clave) {
        '4_infantil' => 'segundo_ciclo.4',
        '5_infantil' => 'segundo_ciclo.5',
        _ => 'segundo_ciclo.6',
      };
      final p = repository.getProgresionSync(clave)!;
      final pegadas = [for (final d in p.dias) pegada(d, a.fases)];
      expect(pegadas.toSet().length, 20, reason: a.id);
      for (var i = 1; i < pegadas.length; i++) {
        expect(pegadas[i], isNot(pegadas[i - 1]), reason: '${a.id} día $i');
      }
      mesesGrupo++;
    }
    expect(mesesGrupo, 50);
  });

  test('o día de hoxe cae na semana e no día laborable que toca', () {
    expect(ProgresionDoMes.hoxe(agora: DateTime(2026, 9, 16)),
        (semana: 3, dia: 3)); // mércores, terceira semana
    expect(ProgresionDoMes.hoxe(agora: DateTime(2026, 9, 5)),
        (semana: 1, dia: 1)); // sábado: o luns seguinte
    expect(ProgresionDoMes.hoxe(agora: DateTime(2026, 9, 30)),
        (semana: 4, dia: 3)); // día 30: tope na semana 4
    expect(ProgresionDoMes.hoxe(agora: DateTime(2026, 9, 16), mesElixido: 10),
        (semana: 1, dia: 1)); // outro mes: empeza polo principio
  });
}
