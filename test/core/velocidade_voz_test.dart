import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/local_audio_player.dart';

/// O-20261109-4 (ACOPROS): en 0-2 años la voz va más lenta.
void main() {
  test('0-2 anos, voz a 0,8; o resto, a 1,0', () {
    expect(velocidadeDoCurso('curso_0_2'), 0.8);
    for (final c in ['curso_2_3', 'curso_3_4', 'curso_4_5', 'curso_5_6']) {
      expect(velocidadeDoCurso(c), 1.0, reason: c);
    }
  });
}
