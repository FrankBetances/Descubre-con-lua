import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/codigo_casa.dart';

/// P10: el código para casa sustituye al imprimible.
void main() {
  test('ida e volta: curso, mes e semana', () {
    for (final curso in [
      'curso_0_2',
      'curso_2_3',
      'curso_3_4',
      'curso_4_5',
      'curso_5_6'
    ]) {
      for (final mes in [9, 10, 11, 12, 1, 2, 3, 4, 5, 6]) {
        for (var s = 1; s <= 4; s++) {
          final c = CodigoCasa.para(curso, mes, s)!;
          final l = CodigoCasa.ler(c.texto)!;
          expect((l.cursoId, l.mesCalendario, l.semana), (curso, mes, s));
        }
      }
    }
    expect(CodigoCasa.para('curso_4_5', 11, 1)!.texto, '45-11-1');
  });

  test('le o que escribe a familia, con ou sen separadores', () {
    for (final t in ['45-11-1', '45 11 1', '45.11.1', '45111', ' 45-11-1 ']) {
      expect(CodigoCasa.ler(t)?.cursoId, 'curso_4_5', reason: t);
    }
  });

  test('rexeita o que non é un código', () {
    for (final t in [
      '',
      '45-07-1',
      '45-11-5',
      '99-11-1',
      '4511',
      '45-11-12',
      'abc'
    ]) {
      expect(CodigoCasa.ler(t), isNull, reason: t);
    }
    expect(CodigoCasa.para('curso_4_5', 8, 1), isNull);
  });
}
