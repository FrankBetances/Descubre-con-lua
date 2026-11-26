import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/localization/localized_string.dart';

/// Palabra de un curso participante en un reto semanal de hermanos (M3).
@immutable
class PalabraRetoIrmans {
  final String en;
  final LocalizedString significado;
  final String? lamina;

  const PalabraRetoIrmans({
    required this.en,
    required this.significado,
    this.lamina,
  });

  factory PalabraRetoIrmans.fromJson(Map<String, dynamic> j) =>
      PalabraRetoIrmans(
        en: j['en']?.toString() ?? '',
        significado: LocalizedString.fromJson(j),
        lamina: j['lamina']?.toString(),
      );
}

/// Pieza semanal de «Reto de irmáns / Reto de hermanos» para una pareja de cursos vecinos (M3).
@immutable
class RetoIrmansPeza {
  final String id;
  final String cursoMenor;
  final String cursoMaior;
  final int mesCalendario;
  final int semanaDoMes;
  final int semanaCurso;
  final LocalizedString steamMenor;
  final LocalizedString steamMaior;
  final PalabraRetoIrmans palabraMenor;
  final PalabraRetoIrmans palabraMaior;
  final LocalizedString titulo;
  final LocalizedString instrucion;
  final String fraseEn;
  final LocalizedString fraseSignificado;

  const RetoIrmansPeza({
    required this.id,
    required this.cursoMenor,
    required this.cursoMaior,
    required this.mesCalendario,
    required this.semanaDoMes,
    required this.semanaCurso,
    required this.steamMenor,
    required this.steamMaior,
    required this.palabraMenor,
    required this.palabraMaior,
    required this.titulo,
    required this.instrucion,
    required this.fraseEn,
    required this.fraseSignificado,
  });

  static LocalizedString _t(Object? v) => LocalizedString.fromJson(
      Map<String, dynamic>.from(v is Map ? v : const {}));

  factory RetoIrmansPeza.fromJson(Map<String, dynamic> j) => RetoIrmansPeza(
        id: j['id']?.toString() ?? '',
        cursoMenor: j['cursoMenor']?.toString() ?? '',
        cursoMaior: j['cursoMaior']?.toString() ?? '',
        mesCalendario: (j['mesCalendario'] as num?)?.toInt() ?? 9,
        semanaDoMes: (j['semanaDoMes'] as num?)?.toInt() ?? 1,
        semanaCurso: (j['semanaCurso'] as num?)?.toInt() ?? 1,
        steamMenor: _t((j['steamMenor'] as Map?)?['titulo']),
        steamMaior: _t((j['steamMaior'] as Map?)?['titulo']),
        palabraMenor: PalabraRetoIrmans.fromJson(
            Map<String, dynamic>.from(j['palabraMenor'] as Map? ?? const {})),
        palabraMaior: PalabraRetoIrmans.fromJson(
            Map<String, dynamic>.from(j['palabraMaior'] as Map? ?? const {})),
        titulo: _t(j['titulo']),
        instrucion: _t(j['instrucion']),
        fraseEn: j['fraseEn']?.toString() ?? '',
        fraseSignificado: _t(j['fraseSignificado']),
      );
}

/// Catálogo de retos de hermanos (M3), leído de `assets/content/nivel/reto_irmans.json`.
class CatalogoRetoIrmans {
  final Map<String, List<RetoIrmansPeza>> pares;

  const CatalogoRetoIrmans(this.pares);

  static const assetPath = 'assets/content/nivel/reto_irmans.json';
  static const List<String> ordeCursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6',
  ];

  static CatalogoRetoIrmans? _lido;
  static Future<CatalogoRetoIrmans>? _enCurso;
  static CatalogoRetoIrmans? get lido => _lido;

  static Future<CatalogoRetoIrmans> cargar() => _enCurso ??=
      rootBundle.loadString(assetPath).then((r) => _lido = fromRaw(r));

  @visibleForTesting
  static void sembrar(CatalogoRetoIrmans c) {
    _lido = c;
    _enCurso = SynchronousFuture(c);
  }

  static CatalogoRetoIrmans fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final rawPares = j['pares'] as Map? ?? const {};
    return CatalogoRetoIrmans({
      for (final e in rawPares.entries)
        if (e.value is List)
          e.key.toString(): [
            for (final item in (e.value as List))
              if (item is Map)
                RetoIrmansPeza.fromJson(Map<String, dynamic>.from(item)),
          ],
    });
  }

  /// Devuelve la pieza de la semana para dos cursos distintos.
  /// M3: para dos cursos no vecinos (ej. `2-3` y `4-5`), devuelve la pieza
  /// del curso del pequeño con el inmediatamente siguiente (`2-3` y `3-4`).
  RetoIrmansPeza? paraCursos(
    String cursoA,
    String cursoB, {
    required int mesCalendario,
    required int semanaDoMes,
  }) {
    final ia = ordeCursos.indexOf(cursoA);
    final ib = ordeCursos.indexOf(cursoB);
    if (ia < 0 || ib < 0 || ia == ib) return null;
    final iMenor = ia < ib ? ia : ib;
    final iSeguinte = iMenor + 1;
    if (iSeguinte >= ordeCursos.length) return null;
    final clave = '${ordeCursos[iMenor]}__${ordeCursos[iSeguinte]}';
    final lista = pares[clave];
    if (lista == null || lista.isEmpty) return null;
    final sem = semanaDoMes.clamp(1, 4);
    for (final it in lista) {
      if (it.mesCalendario == mesCalendario && it.semanaDoMes == sem) {
        return it;
      }
    }
    return lista.first;
  }
}
