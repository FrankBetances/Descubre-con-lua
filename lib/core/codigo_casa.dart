/// El código para casa (P10, Frank 26/10/2026): en lugar de imprimibles, la
/// escuela da a la familia un código corto que, escrito en la app de casa,
/// abre el núcleo del mes, el reto de la semana y qué mirar.
///
/// Es curso, mes y semana, nada más: `45-11-1` es 4-5 años, noviembre,
/// semana 1. No identifica a nadie, no se guarda y no sale del aparato.
class CodigoCasa {
  final String cursoId;
  final int mesCalendario;
  final int semana;

  const CodigoCasa({
    required this.cursoId,
    required this.mesCalendario,
    required this.semana,
  });

  static const _cursos = {
    '02': 'curso_0_2',
    '23': 'curso_2_3',
    '34': 'curso_3_4',
    '45': 'curso_4_5',
    '56': 'curso_5_6',
  };
  static const _meses = {9, 10, 11, 12, 1, 2, 3, 4, 5, 6};

  /// El texto que se copia: `45-11-1`.
  String get texto {
    final c = _cursos.entries.firstWhere((e) => e.value == cursoId).key;
    return '$c-${mesCalendario.toString().padLeft(2, '0')}-$semana';
  }

  /// `null` si el curso, el mes del curso o la semana no existen.
  static CodigoCasa? para(String cursoId, int mesCalendario, int semana) {
    if (!_cursos.containsValue(cursoId) || !_meses.contains(mesCalendario)) {
      return null;
    }
    return CodigoCasa(
      cursoId: cursoId,
      mesCalendario: mesCalendario,
      semana: semana.clamp(1, 4),
    );
  }

  /// Lee lo que escribe la familia: acepta espacios, puntos o nada entre las
  /// partes (`45 11 1`, `45.11.1`, `45111`). `null` si no es un código.
  static CodigoCasa? ler(String escrito) {
    final d = escrito.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.length != 5) return null;
    final curso = _cursos[d.substring(0, 2)];
    final mes = int.parse(d.substring(2, 4));
    final semana = int.parse(d.substring(4));
    if (curso == null || !_meses.contains(mes) || semana < 1 || semana > 4) {
      return null;
    }
    return CodigoCasa(cursoId: curso, mesCalendario: mes, semana: semana);
  }
}
