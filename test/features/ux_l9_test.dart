import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Lote L9: lo que Frank decidió al probar la build de L8.
void main() {
  // La decisión de L7 con los pares mínimos, ahora en el gesto de «Whisper»:
  // a quien lleva audífono o implante, tapar la boca le quita la lectura
  // labial. El gesto se hace con la boca a la vista.
  test('o xesto de «Whisper» non tapa a boca, no curso nin en Ponte ao día',
      () {
    Map? buscar(Object? nodo) {
      if (nodo is Map) {
        if (nodo['id'] == 'whisper') return nodo;
        for (final v in nodo.values) {
          final r = buscar(v);
          if (r != null) return r;
        }
      } else if (nodo is List) {
        for (final v in nodo) {
          final r = buscar(v);
          if (r != null) return r;
        }
      }
      return null;
    }

    final curso = buscar(jsonDecode(
        File('assets/content/tpr/curso_3_4/tpr.09.maio.json')
            .readAsStringSync()))!;
    final ponte =
        jsonDecode(File('assets/content/ponte_ao_dia.json').readAsStringSync())
            as Map;
    for (final xesto in [
      curso['tprAction'] as Map,
      (ponte['palabras'] as Map)['whisper']['xesto'] as Map,
    ]) {
      for (final (lingua, vista) in [
        ('gl', 'coa boca á vista'),
        ('es', 'con la boca a la vista'),
      ]) {
        final texto = (xesto[lingua] as String).toLowerCase();
        expect(texto, isNot(contains('tapa')), reason: texto);
        expect(texto, contains(vista), reason: texto);
      }
    }
  });
}
