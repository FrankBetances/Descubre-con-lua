import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import 'hogar_model.dart';

LocalizedString _t(Object? v) => LocalizedString.fromJson(
    Map<String, dynamic>.from(v is Map ? v : const {}));

/// Una pieza que se enseña: palabra, orden, fórmula o estructura.
@immutable
class PezaDaLeccion {
  final String tipo;
  final String en;
  final LocalizedString? significado;
  final LocalizedString? xesto;

  const PezaDaLeccion({
    required this.tipo,
    required this.en,
    this.significado,
    this.xesto,
  });

  factory PezaDaLeccion.fromJson(Map<String, dynamic> j) {
    final s = _t(j);
    return PezaDaLeccion(
      tipo: j['tipo']?.toString() ?? 'palabra',
      en: j['en']?.toString() ?? '',
      significado: s.hasParity ? s : null,
      xesto: j['xesto'] is Map ? _t(j['xesto']) : null,
    );
  }
}

/// Una semana de una unidad del plan curricular (P11): lo que ya debería
/// saber, lo nuevo, el reto de casa, el cuento, el juego y qué mirar.
@immutable
class Leccion {
  final String id;
  final int numero;
  final int de;
  final bool repaso;
  final List<PezaDaLeccion> xaSabe;
  final List<PezaDaLeccion> novas;
  final List<PezaDaLeccion> repasa;

  /// El reto de casa de la semana, con el mismo molde que el del mes.
  final RetoDeCasa reto;
  final LocalizedString momento;
  final LocalizedString escena;
  final int minutos;
  final String? conto;
  final String? xogo;
  final String? steam;
  final List<LocalizedString> queMirar;

  const Leccion({
    required this.id,
    required this.numero,
    required this.de,
    required this.repaso,
    required this.xaSabe,
    required this.novas,
    required this.repasa,
    required this.reto,
    required this.momento,
    required this.escena,
    required this.minutos,
    this.conto,
    this.xogo,
    this.steam,
    this.queMirar = const [],
  });

  factory Leccion.fromJson(Map<String, dynamic> j) {
    List<PezaDaLeccion> pezas(Object? v) => [
          for (final p in (v as List? ?? const []))
            if (p is Map) PezaDaLeccion.fromJson(Map<String, dynamic>.from(p)),
        ];
    final r = Map<String, dynamic>.from(j['reto'] as Map? ?? const {});
    final xogo = Map<String, dynamic>.from(j['xogo'] as Map? ?? const {});
    return Leccion(
      id: j['id']?.toString() ?? '',
      numero: (j['numero'] as num?)?.toInt() ?? 1,
      de: (j['de'] as num?)?.toInt() ?? 1,
      repaso: j['tipo'] == 'repaso',
      xaSabe: pezas(j['xaSabe']),
      novas: pezas(j['novas']),
      repasa: pezas(j['repasa']),
      reto: RetoDeCasa.fromJson({
        ...r,
        'id': '${j['id']}.reto',
        'semana': (j['numero'] as num?)?.toInt() ?? 1,
      }),
      momento: _t(r['momento']),
      escena: _t(r['escena']),
      minutos: (r['minutos'] as num?)?.toInt() ?? 5,
      conto: j['conto']?.toString(),
      xogo: xogo['xogo']?.toString(),
      steam: xogo['steam']?.toString(),
      queMirar: [for (final q in (j['queMirar'] as List? ?? const [])) _t(q)],
    );
  }
}

/// Una unidad del plan curricular, con sus lecciones en orden.
@immutable
class UnidadeDeLeccions {
  final String id;
  final LocalizedString titulo;
  final List<Leccion> leccions;

  const UnidadeDeLeccions({
    required this.id,
    required this.titulo,
    required this.leccions,
  });
}

/// Las lecciones de los cinco cursos, de `assets/content/leccions/`
/// (`tools/gen_leccions.py`).
@immutable
class Leccions {
  final Map<String, List<UnidadeDeLeccions>> unidades;

  /// Curso → mes → las lecciones de sus semanas 1 a 4.
  final Map<String, Map<int, List<String>>> calendario;

  const Leccions({required this.unidades, required this.calendario});

  static const assetPath = 'assets/content/leccions/leccions.json';

  factory Leccions.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final unidades = <String, List<UnidadeDeLeccions>>{};
    final calendario = <String, Map<int, List<String>>>{};
    for (final e in (j['cursos'] as Map).entries) {
      final c = Map<String, dynamic>.from(e.value as Map);
      unidades[e.key.toString()] = [
        for (final u in (c['unidades'] as List? ?? const []))
          if (u is Map)
            UnidadeDeLeccions(
              id: u['id']?.toString() ?? '',
              titulo: _t(u['titulo']),
              leccions: [
                for (final l in (u['leccions'] as List? ?? const []))
                  if (l is Map) Leccion.fromJson(Map<String, dynamic>.from(l)),
              ],
            ),
      ];
      calendario[e.key.toString()] = {
        for (final m in (c['calendario'] as Map? ?? const {}).entries)
          int.parse(m.key.toString()): [
            for (final id in (m.value as List)) id.toString(),
          ],
      };
    }
    return Leccions(unidades: unidades, calendario: calendario);
  }

  /// La lección de la semana 1 a 4 (la 5.ª es la 4.ª) de un mes del curso.
  (UnidadeDeLeccions, Leccion)? da(String curso, int mes, int semana) {
    final ids = calendario[curso]?[mes];
    if (ids == null || ids.isEmpty) return null;
    final id = ids[(semana.clamp(1, ids.length)) - 1];
    return porId(curso, id);
  }

  (UnidadeDeLeccions, Leccion)? porId(String curso, String id) {
    for (final u in unidades[curso] ?? const <UnidadeDeLeccions>[]) {
      for (final l in u.leccions) {
        if (l.id == id) return (u, l);
      }
    }
    return null;
  }

  static Future<Leccions>? _enCurso;
  static Leccions? _lidas;

  /// Las lecciones, si ya se leyeron; si no, `null`.
  static Leccions? get lidas => _lidas;

  /// Una sola carga por ejecución.
  static Future<Leccions> cargar() => _enCurso ??= rootBundle
      .loadString(assetPath)
      .then(Leccions.fromRaw)
      .then((l) => _lidas = l);

  /// Solo para los tests: deja las lecciones ya leídas.
  @visibleForTesting
  static void sembrar(Leccions l) {
    _lidas = l;
    _enCurso = SynchronousFuture(l);
  }
}
