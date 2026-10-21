import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';

/// Una frase inglesa del plan curricular con lo que quiere decir (F7).
@immutable
class FraseCurricular {
  final String en;
  final LocalizedString? significado;

  /// El gesto, si es una acción TPR.
  final LocalizedString? xesto;

  const FraseCurricular(this.en, {this.significado, this.xesto});
}

/// Una de las 12 unidades del plan curricular de Frank (F11), transcrita de
/// `referencias/base/curriculo-vocabulario-infantil-2-6.txt` a
/// `assets/content/curriculo/`. Es la columna del curso: el centro de
/// interés, el vocabulario y los objetivos del mes salen de aquí.
@immutable
class UnidadeCurricular {
  final String id;
  final LocalizedString titulo;
  final int semanas;
  final List<LocalizedString> objetivos;
  final List<FraseCurricular> vocabulario;
  final List<FraseCurricular> accionsTPR;
  final List<FraseCurricular> formulas;
  final List<FraseCurricular> estructuras;
  final List<FraseCurricular> rimas;
  final List<FraseCurricular> frasesAdulta;
  final List<LocalizedString> realia;
  final LocalizedString? fonoloxia;

  /// Los pasos de la dinámica (inicio, desarrollo, cierre) o del juego
  /// sociodramático (escenario, intervención, resolución), en su orden.
  final List<(LocalizedString, LocalizedString)> dinamica;
  final LocalizedString? familia;
  final String fonte;

  const UnidadeCurricular({
    required this.id,
    required this.titulo,
    required this.semanas,
    required this.objetivos,
    required this.vocabulario,
    required this.accionsTPR,
    required this.formulas,
    required this.estructuras,
    required this.rimas,
    required this.frasesAdulta,
    required this.realia,
    required this.fonoloxia,
    required this.dinamica,
    required this.familia,
    required this.fonte,
  });

  static LocalizedString? _ls(Object? v) {
    if (v is! Map) return null;
    final gl = (v['gl'] as String? ?? '').trim();
    final es = (v['es'] as String? ?? '').trim();
    if (gl.isEmpty || es.isEmpty) return null;
    return LocalizedString(gl: gl, es: es);
  }

  static List<LocalizedString> _lista(Object? v) => [
        for (final e in (v as List?) ?? const [])
          if (_ls(e) case final l?) l,
      ];

  static List<FraseCurricular> _frases(Object? v) => [
        for (final e in ((v as List?) ?? const []).whereType<Map>())
          if ((e['en'] as String? ?? '').trim().isNotEmpty)
            FraseCurricular(
              (e['en'] as String).trim(),
              significado: _ls(e),
              xesto: _ls(e['xesto']),
            ),
      ];

  static const _pasosDinamica = [
    ('inicio', LocalizedString(gl: 'Inicio', es: 'Inicio')),
    (
      'desenvolvemento',
      LocalizedString(gl: 'Desenvolvemento', es: 'Desarrollo')
    ),
    ('peche', LocalizedString(gl: 'Peche', es: 'Cierre')),
    ('escenario', LocalizedString(gl: 'Escenario', es: 'Escenario')),
    ('intervencion', LocalizedString(gl: 'Intervención', es: 'Intervención')),
    ('resolucion', LocalizedString(gl: 'Resolución', es: 'Resolución')),
  ];

  factory UnidadeCurricular.fromJson(Map<String, dynamic> j) {
    final din = (j['dinamica'] ?? j['xogoSociodramatico']) as Map? ?? const {};
    return UnidadeCurricular(
      id: j['id'] as String,
      titulo: _ls(j['titulo']) ??
          (throw FormatException('curriculo: ${j['id']} sen título')),
      semanas: (j['semanas'] as num?)?.toInt() ?? 0,
      objetivos: _lista(j['objetivos']),
      vocabulario: _frases(j['vocabulario']),
      accionsTPR: _frases(j['accionsTPR']),
      formulas: _frases(j['formulas']),
      estructuras: _frases(j['estructuras']),
      rimas: _frases(j['rimas']),
      frasesAdulta: _frases(j['frasesAdulta']),
      realia: _lista(j['realia']),
      fonoloxia: _ls(j['fonoloxia'] ?? j['concienciaFonoloxica']),
      dinamica: [
        for (final (clave, rotulo) in _pasosDinamica)
          if (_ls(din[clave]) case final t?) (rotulo, t),
      ],
      familia: _ls(j['familia']),
      fonte: j['fonte'] as String? ?? '',
    );
  }
}

/// Las 12 unidades y qué unidad toca en cada curso y mes.
@immutable
class PlanCurricular {
  final Map<String, UnidadeCurricular> _porId;
  final Map<String, Map<int, String>> _calendario;

  const PlanCurricular(this._porId, this._calendario);

  static const ficheiros = [
    'assets/content/curriculo/tramo_18_36.json',
    'assets/content/curriculo/tramo_3_6.json',
  ];
  static const calendarioAsset =
      'assets/content/curriculo/calendario_curricular.json';

  factory PlanCurricular.fromRaw(List<String> tramos, String calendario) {
    final porId = <String, UnidadeCurricular>{};
    for (final raw in tramos) {
      for (final u
          in ((jsonDecode(raw) as Map)['unidades'] as List).cast<Map>()) {
        final unidade =
            UnidadeCurricular.fromJson(Map<String, dynamic>.from(u));
        porId[unidade.id] = unidade;
      }
    }
    final cursos = (jsonDecode(calendario) as Map)['cursos'] as Map;
    return PlanCurricular(porId, {
      for (final e in cursos.entries)
        e.key as String: {
          for (final m in (e.value as Map).entries)
            int.parse(m.key as String): m.value as String,
        },
    });
  }

  UnidadeCurricular? unidade(String id) => _porId[id];

  /// La unidad del plan de [cursoId] en [mesCalendario] (setembro = 9).
  UnidadeCurricular? para(String cursoId, int mesCalendario) {
    final id = _calendario[cursoId]?[mesCalendario];
    return id == null ? null : _porId[id];
  }

  /// En qué mes de la unidad estamos y cuántos ocupa en este curso.
  (int, int) mesDentro(String cursoId, int mesCalendario) {
    final id = _calendario[cursoId]?[mesCalendario];
    const orde = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];
    final meses = [
      for (final m in orde)
        if (_calendario[cursoId]?[m] == id) m,
    ];
    return (meses.indexOf(mesCalendario) + 1, meses.length);
  }

  static Future<PlanCurricular>? _enCurso;

  static Future<PlanCurricular> cargar() => _enCurso ??= Future.wait([
        for (final f in ficheiros) rootBundle.loadString(f),
        rootBundle.loadString(calendarioAsset),
      ]).then((r) => PlanCurricular.fromRaw(r.sublist(0, 2), r[2]));

  /// Solo para los tests: deja el plan ya leído.
  @visibleForTesting
  static void sembrar(PlanCurricular p) => _enCurso = SynchronousFuture(p);
}
