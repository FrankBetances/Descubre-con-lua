import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/localization/localized_string.dart';

/// O-20261119-8: una pieza de escucha por mes y por edad (decisión de Frank,
/// «uno por mes»), en assets/content/escoita/plan_mensual.json. Cada semana
/// del mes la lección enseña una actividad distinta con ella:
///   s1 escucha y señala el par; s2 la progresión; s3 el modelo para el
///   adulto; s4 las misiones del par.
class PalabraEscoita {
  final String en;
  final LocalizedString significado;
  final String? lamina;

  const PalabraEscoita(
      {required this.en, required this.significado, this.lamina});

  factory PalabraEscoita.fromJson(Map<String, dynamic> j) => PalabraEscoita(
        en: j['en'] as String,
        significado: LocalizedString(
            gl: (j['gl'] as String?) ?? '', es: (j['es'] as String?) ?? ''),
        lamina: j['lamina'] as String?,
      );
}

class FaseEscoita extends PalabraEscoita {
  final String tipo;
  final String frase;
  final LocalizedString accion;
  const FaseEscoita({
    required super.en,
    required super.significado,
    super.lamina,
    required this.tipo,
    required this.frase,
    required this.accion,
  });

  factory FaseEscoita.fromJson(Map<String, dynamic> j) {
    final p = PalabraEscoita.fromJson(j);
    return FaseEscoita(
      en: p.en,
      significado: p.significado,
      lamina: p.lamina,
      tipo: j['tipo'] as String,
      frase: (j['frase'] as String?) ?? '',
      accion: LocalizedString.fromJson(j['accion']),
    );
  }
}

class PezaMensual {
  final String curso;
  final int mes;

  final PalabraEscoita a;
  final PalabraEscoita b;
  final String fonema;
  final LocalizedString nota;
  final LocalizedString misionAcerto;
  final LocalizedString misionFallo;
  final LocalizedString pista;
  final LocalizedString tema;
  final List<FaseEscoita> fases;

  /// P7.9 (F-20261119-9): el par no se enseña hasta que se rehaga, porque
  /// una de sus palabras no nombra el STEAM del mes.
  final bool parPendiente;
  final String neno;
  final List<String> adulto;

  /// El significado gl/es de cada frase del modelo, para el doble toque.
  final List<LocalizedString> adultoSignificado;
  final LocalizedString notaModelo;

  const PezaMensual({
    required this.curso,
    required this.mes,
    required this.a,
    required this.b,
    required this.fonema,
    required this.nota,
    required this.misionAcerto,
    required this.misionFallo,
    required this.pista,
    required this.tema,
    required this.fases,
    this.parPendiente = false,
    required this.neno,
    required this.adulto,
    this.adultoSignificado = const [],
    required this.notaModelo,
  });

  factory PezaMensual.fromJson(Map<String, dynamic> j) {
    final par = j['par'] as Map<String, dynamic>;
    final prog = j['progresion'] as Map<String, dynamic>;
    final mod = j['modelo'] as Map<String, dynamic>;
    return PezaMensual(
      curso: j['curso'] as String,
      mes: j['mes'] as int,
      a: PalabraEscoita.fromJson(par['a'] as Map<String, dynamic>),
      b: PalabraEscoita.fromJson(par['b'] as Map<String, dynamic>),
      fonema: par['fonema'] as String,
      nota: LocalizedString.fromJson(par['nota']),
      misionAcerto: LocalizedString.fromJson(par['mision_acerto']),
      misionFallo: LocalizedString.fromJson(par['mision_fallo']),
      pista: LocalizedString.fromJson(par['pista']),
      tema: LocalizedString.fromJson(prog['tema']),
      fases: [
        for (final f in (prog['fases'] as List).cast<Map<String, dynamic>>())
          FaseEscoita.fromJson(f),
      ],
      parPendiente: par['pendiente'] != null,
      neno: mod['neno'] as String,
      adulto: (mod['adulto'] as List).cast<String>(),
      adultoSignificado: [
        for (final x in (mod['significado'] as List?) ?? const [])
          LocalizedString.fromJson(x),
      ],
      notaModelo: LocalizedString.fromJson(mod['nota']),
    );
  }
}

class PlanEscoita {
  final List<PezaMensual> pezas;
  const PlanEscoita(this.pezas);

  static const assetPath = 'assets/content/escoita/plan_mensual.json';

  factory PlanEscoita.fromRaw(String raw) {
    final j = jsonDecode(raw);
    final lista = j is List
        ? j
        : ((j as Map<String, dynamic>)['piezas'] ?? j['pezas']) as List;
    return PlanEscoita([
      for (final p in lista.cast<Map<String, dynamic>>())
        PezaMensual.fromJson(p),
    ]);
  }

  /// La pieza de [curso] en el mes del curso [mes] (1 es septiembre).
  PezaMensual? de(String curso, int mes) =>
      pezas.where((p) => p.curso == curso && p.mes == mes).firstOrNull;

  static PlanEscoita? _lido;
  static Future<PlanEscoita?>? _enCurso;
  static PlanEscoita? get lido => _lido;

  /// Sin el fichero (todavía no lo ha entregado Antigravity), no hay plan y la
  /// lección queda como estaba.
  static Future<PlanEscoita?> cargar() => _enCurso ??= rootBundle
      .loadString(assetPath)
      .then<PlanEscoita?>((r) => _lido = PlanEscoita.fromRaw(r))
      .catchError((Object _) => null);

  @visibleForTesting
  static void sembrar(PlanEscoita? p) {
    _lido = p;
    _enCurso = SynchronousFuture(p);
  }
}
