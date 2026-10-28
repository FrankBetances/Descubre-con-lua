import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/app_language.dart';
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

  /// Qué es, dicho para una familia: «Verbo: unha acción».
  final LocalizedString? que;

  const PezaDaLeccion({
    required this.tipo,
    required this.en,
    this.significado,
    this.xesto,
    this.que,
  });

  factory PezaDaLeccion.fromJson(Map<String, dynamic> j) {
    final s = _t(j);
    return PezaDaLeccion(
      tipo: j['tipo']?.toString() ?? 'palabra',
      en: j['en']?.toString() ?? '',
      significado: s.hasParity ? s : null,
      xesto: j['xesto'] is Map ? _t(j['xesto']) : null,
      que: j['que'] is Map ? _t(j['que']) : null,
    );
  }
}

/// Lo que toca un día de la semana.
@immutable
class DiaDaLeccion {
  final LocalizedString dia;
  final LocalizedString texto;

  /// El inglés de ese día, si lleva, para oírlo.
  final String? en;

  /// Lo que quiere decir, para el doble toque.
  final LocalizedString? significado;

  const DiaDaLeccion({
    required this.dia,
    required this.texto,
    this.en,
    this.significado,
  });
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

  /// Lunes a viernes: una cosa distinta cada día.
  final List<DiaDaLeccion> dias;

  /// El nivel de logro que se espera esta semana.
  final LocalizedString? espera;

  /// La frase de gramática de la semana, con su significado.
  final PezaDaLeccion? fraseGramatica;

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
    this.dias = const [],
    this.espera,
    this.fraseGramatica,
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
      espera: j['espera'] is Map ? _t(j['espera']) : null,
      fraseGramatica: j['fraseGramatica'] is Map
          ? PezaDaLeccion.fromJson({
              ...Map<String, dynamic>.from(j['fraseGramatica'] as Map),
              'tipo': 'gramatica'
            })
          : null,
      dias: [
        for (final d in (j['dias'] as List? ?? const []))
          if (d is Map)
            DiaDaLeccion(
              dia: _t(d['dia']),
              texto: _t(d['texto']),
              en: d['en']?.toString(),
              significado: d['gl'] != null ? _t(d) : null,
            ),
      ],
    );
  }
}

/// Una unidad del plan curricular, con sus lecciones en orden.
@immutable
class UnidadeDeLeccions {
  final String id;
  final LocalizedString titulo;

  /// A dónde va la unidad: sus objetivos, tal cual los dice el plan.
  final List<LocalizedString> obxectivos;

  /// La unidad del plan curricular en la que va este mes.
  final LocalizedString? plan;

  /// Lo que trabaja en gramática, del documento del plan; no todas lo traen.
  final LocalizedString? foco;

  /// El punto de la gramática del curso (A1-A2) de esta unidad.
  final PuntoDeGramatica? gramatica;

  /// La unidad de gramática de antes y la de después.
  final PuntoDeGramatica? gramaticaAntes;
  final PuntoDeGramatica? gramaticaDespois;
  final List<Leccion> leccions;

  const UnidadeDeLeccions({
    required this.id,
    required this.titulo,
    this.obxectivos = const [],
    this.plan,
    this.foco,
    this.gramatica,
    this.gramaticaAntes,
    this.gramaticaDespois,
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

  /// Lo que la familia lee para entender qué hace, cómo y por qué.
  final Map<String, LocalizedString> guia;

  /// La ruta de los cinco cursos: curso, título y qué se trabaja.
  final List<(String, LocalizedString, LocalizedString)> ruta;

  const Leccions({
    required this.unidades,
    required this.calendario,
    this.guia = const {},
    this.ruta = const [],
  });

  /// Un texto de la guía; vacío si falta.
  String texto(String clave, AppLanguage lang) =>
      guia[clave]?.resolve(lang) ?? '';

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
              obxectivos: [
                for (final o in (u['obxectivos'] as List? ?? const [])) _t(o),
              ],
              plan: u['plan'] is Map ? _t((u['plan'] as Map)['titulo']) : null,
              foco: u['foco'] is Map ? _t(u['foco']) : null,
              gramatica: u['gramatica'] is Map
                  ? PuntoDeGramatica.fromJson(
                      Map<String, dynamic>.from(u['gramatica'] as Map))
                  : null,
              gramaticaAntes: u['gramaticaAntes'] is Map
                  ? PuntoDeGramatica.fromJson(
                      Map<String, dynamic>.from(u['gramaticaAntes'] as Map))
                  : null,
              gramaticaDespois: u['gramaticaDespois'] is Map
                  ? PuntoDeGramatica.fromJson(
                      Map<String, dynamic>.from(u['gramaticaDespois'] as Map))
                  : null,
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
    return Leccions(
      unidades: unidades,
      calendario: calendario,
      guia: {
        for (final g in (j['guia'] as Map? ?? const {}).entries)
          g.key.toString(): _t(g.value),
      },
      ruta: [
        for (final r in (j['ruta'] as List? ?? const []))
          if (r is Map)
            (r['curso'].toString(), _t(r['titulo']), _t(r['texto'])),
      ],
    );
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

/// Un punto de la gramática del curso (Frank, 28/10/2026): de A1 a C1.
@immutable
class PuntoDeGramatica {
  final int n;
  final String nivel;
  final LocalizedString titulo;
  final LocalizedString? descricion;
  final LocalizedString? paraFamilias;
  final PezaDaLeccion? exemplo;

  const PuntoDeGramatica({
    required this.n,
    required this.nivel,
    required this.titulo,
    this.descricion,
    this.paraFamilias,
    this.exemplo,
  });

  factory PuntoDeGramatica.fromJson(Map<String, dynamic> j) => PuntoDeGramatica(
        n: (j['n'] as num).toInt(),
        nivel: j['nivel']?.toString() ?? '',
        titulo: _t(j['titulo']),
        descricion: j['descricion'] is Map ? _t(j['descricion']) : null,
        paraFamilias: j['paraFamilias'] is Map ? _t(j['paraFamilias']) : null,
        exemplo: j['exemplo'] is Map
            ? PezaDaLeccion.fromJson({
                ...Map<String, dynamic>.from(j['exemplo'] as Map),
                'tipo': 'gramatica'
              })
            : null,
      );
}

/// Los 48 puntos y en qué edad y mes va cada uno de A1-A2.
@immutable
class GramaticaDoCurso {
  final List<PuntoDeGramatica> puntos;

  /// Punto → los (curso, mes) en que se trabaja.
  final Map<int, List<(String, int)>> onde;

  const GramaticaDoCurso({required this.puntos, required this.onde});

  static const assetPath = 'assets/content/gramatica/gramatica.json';

  factory GramaticaDoCurso.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final onde = <int, List<(String, int)>>{};
    for (final c in (j['ruta'] as Map).entries) {
      for (final m in (c.value as Map).entries) {
        final n = ((m.value as Map)['punto'] as num).toInt();
        onde
            .putIfAbsent(n, () => [])
            .add((c.key.toString(), int.parse(m.key.toString())));
      }
    }
    return GramaticaDoCurso(
      puntos: [
        for (final p in (j['puntos'] as List))
          PuntoDeGramatica.fromJson(Map<String, dynamic>.from(p as Map)),
      ],
      onde: onde,
    );
  }

  static Future<GramaticaDoCurso>? _enCurso;

  static Future<GramaticaDoCurso> cargar() => _enCurso ??=
      rootBundle.loadString(assetPath).then(GramaticaDoCurso.fromRaw);

  @visibleForTesting
  static void sembrar(GramaticaDoCurso g) => _enCurso = SynchronousFuture(g);
}
