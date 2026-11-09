import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/features/criancas/criancas_store.dart';
import 'package:descubre_con_lua/features/criancas/xogo_lua.dart';

/// El gate del TERCER fichero que la app guarda en el aparato: `criancas.json`
/// (O-20261109-1, decidido por Frank el 9/11/2026).
///
/// La política de privacidad declara exactamente esto: de cada niño, el
/// nombre, la edad en años y el curso; cuál se vio el último; y por semana
/// del curso, sin fecha ni hora, qué palabras la persona adulta marcó como
/// «la entiende» o «la dice». Si aparece una clave más, o una hora, falla.
void main() {
  late Directory dir;
  setUp(() => dir = Directory.systemTemp.createTempSync('criancas_priv_'));
  tearDown(() => dir.deleteSync(recursive: true));

  test('criancas.json: solo estas claves, sin hora ni fecha', () async {
    final s = CriancasStore(
        store: LocalStore(
            fileName: CriancasStore.nomeFicheiro, overrideDirectory: dir.path));
    await s.cargar();
    final a = await s.engadir(nome: 'Uxía', idade: 2, curso: 'curso_2_3');
    final b = await s.engadir(nome: 'Antón', idade: 5, curso: 'curso_5_6');
    await s.escoller(a.id);
    await s.observar(a.id, CriancasStore.semana('curso_2_3', 10, 2), 'leaf',
        Observacion.entende);
    await s.observar(
        b.id, CriancasStore.semana('curso_5_6', 3, 4), 'river', Observacion.di);

    // O-20261109-3: el juego del niño con Lúa (XP, racha, insignias, armario).
    final c = CatalogoLua.lido!;
    await s.xogarHoxe(a.id, c,
        agora: DateTime(2026, 10, 6, 21, 47),
        semana: CriancasStore.semana('curso_2_3', 10, 2),
        palabrasDaSemana: ['leaf']);
    await s.acariciar(a.id);
    await s.darPeixe(a.id, DateTime(2026, 10, 6, 21, 50));

    final raw =
        File('${dir.path}/${CriancasStore.nomeFicheiro}').readAsStringSync();
    final j = json.decode(raw) as Map<String, dynamic>;

    expect(j.keys.toSet(), {'criancas', 'activa', 'observacions', 'xogo'});
    for (final g in (j['xogo'] as Map).values) {
      expect((g as Map).keys.toSet().difference(XogoLua.claves), isEmpty);
      // Las dos fechas del juego, en día y sin hora.
      expect(g['ultimoDia'], '2026-10-06');
      expect(g['comeu'], '2026-10-06');
    }
    for (final c in j['criancas'] as List) {
      expect((c as Map).keys.toSet(), {'id', 'nome', 'idade', 'curso'});
      expect(c['idade'], isA<int>());
    }
    final semana = RegExp(r'^curso_\d_\d/\d{1,2}/[1-5]$');
    for (final porNeno in (j['observacions'] as Map).values) {
      for (final e in (porNeno as Map).entries) {
        expect(semana.hasMatch(e.key as String), isTrue,
            reason: 'semana sin fecha: ${e.key}');
        for (final v in (e.value as Map).values) {
          expect(v, anyOf(1, 2));
        }
      }
    }
    // Ni una hora, ni una fecha, ni milisegundos desde 1970.
    expect(RegExp(r'\d{2}:\d{2}').hasMatch(raw), isFalse);
    // Fechas solo las dos del juego, en día: ninguna otra.
    expect(RegExp(r'\d{4}-\d{2}-\d{2}').allMatches(raw).length, 2);
    expect(RegExp(r'\d{10,}').hasMatch(raw), isFalse);
  });
}
