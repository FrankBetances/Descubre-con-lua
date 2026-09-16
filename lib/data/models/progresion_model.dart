import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';
import 'asamblea_segundo_ciclo_model.dart'
    show ComandoTPR, FaseAsamblea, TipoFaseAsamblea;

/// Cómo se trabaja la orden hoy. Es lo que cambia de un día a otro.
enum ModoDoDia {
  novo,
  material,
  combinar,
  cancion,
  elixir,
  serie,
  ritmo,
  historia,
  rol,
  senModelo,
  contexto,
  familias,
  festa;

  static ModoDoDia fromClave(String? clave) {
    for (final m in values) {
      if (m.name == clave) return m;
    }
    return ModoDoDia.novo;
  }
}

/// Una semana de la progresión: número, nombre y lo que persigue.
@immutable
class SemanaDeProgresion {
  final int numero;
  final LocalizedString nome;
  final LocalizedString meta;

  const SemanaDeProgresion({
    required this.numero,
    required this.nome,
    required this.meta,
  });

  factory SemanaDeProgresion.fromJson(Map<String, dynamic> json) =>
      SemanaDeProgresion(
        numero: (json['numero'] as num?)?.toInt() ?? 0,
        nome: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['nome'] as Map? ?? {})),
        meta: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['meta'] as Map? ?? {})),
      );
}

/// Un día de asamblea: qué órdenes del mes se trabajan y cómo.
///
/// La temática, el material, la canción y las órdenes siguen siendo las del
/// mes, que salen del documento curricular. Lo que este día aporta es el
/// FOCO y la CONSIGNA de la fase núcleo, y qué órdenes entran. Así la asamblea
/// del martes no es la del lunes, que es lo que Frank pidió.
@immutable
class DiaDeProgresion {
  final int semana;
  final int dia;
  final LocalizedString nomeDia;
  final LocalizedString foco;
  final LocalizedString consigna;

  /// Índices sobre `comandosL3` de la fase núcleo del mes.
  final List<int> comandos;
  final ModoDoDia modo;

  const DiaDeProgresion({
    required this.semana,
    required this.dia,
    required this.nomeDia,
    required this.foco,
    required this.consigna,
    required this.comandos,
    required this.modo,
  });

  factory DiaDeProgresion.fromJson(Map<String, dynamic> json) {
    final raw = json['comandos'];
    final comandos = <int>[];
    if (raw is List) {
      for (final c in raw) {
        if (c is num) comandos.add(c.toInt());
      }
    }
    return DiaDeProgresion(
      semana: (json['semana'] as num?)?.toInt() ?? 1,
      dia: (json['dia'] as num?)?.toInt() ?? 1,
      nomeDia: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['nomeDia'] as Map? ?? {})),
      foco: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['foco'] as Map? ?? {})),
      consigna: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['consigna'] as Map? ?? {})),
      comandos: List.unmodifiable(comandos),
      modo: ModoDoDia.fromClave(json['modo']?.toString()),
    );
  }

  /// Las fases del mes con ESTE día dentro.
  ///
  /// Solo cambia la fase núcleo: la apertura, el ritmo y la calma son el
  /// ritual, y el ritual se repite a propósito. En el núcleo entra la consigna
  /// del día y quedan solo las órdenes que hoy tocan, en el orden del día. Si
  /// el mes tiene menos órdenes de las que el día pide, se recortan los
  /// índices que no existen; nunca se queda sin ninguna.
  List<FaseAsamblea> aplicarA(List<FaseAsamblea> fases) {
    return [
      for (final f in fases)
        if (f.tipo == TipoFaseAsamblea.coreTprChallenge &&
            f.comandosL3.isNotEmpty)
          f.copyWith(
            consignaDocente: consigna,
            comandosL3: _ordesDeHoxe(f),
          )
        else
          f,
    ];
  }

  List<ComandoTPR> _ordesDeHoxe(FaseAsamblea f) {
    final elixidas = [
      for (final i in comandos)
        if (i >= 0 && i < f.comandosL3.length) f.comandosL3[i],
    ];
    return elixidas.isEmpty ? [f.comandosL3.first] : elixidas;
  }
}

/// La progresión de un tramo: 4 semanas x 5 días, escalonadas.
@immutable
class ProgresionDoMes {
  final String id;
  final LocalizedString nota;
  final List<SemanaDeProgresion> semanas;
  final List<DiaDeProgresion> dias;

  const ProgresionDoMes({
    required this.id,
    required this.nota,
    required this.semanas,
    required this.dias,
  });

  /// La clave del tramo: lo que va detrás de «progresion.» en el id.
  String get clave => id.startsWith('progresion.') ? id.substring(11) : id;

  factory ProgresionDoMes.fromJson(Map<String, dynamic> json) {
    final semanas = <SemanaDeProgresion>[];
    for (final s in (json['semanas'] as List? ?? const [])) {
      if (s is Map) {
        semanas.add(SemanaDeProgresion.fromJson(Map<String, dynamic>.from(s)));
      }
    }
    final dias = <DiaDeProgresion>[];
    for (final d in (json['dias'] as List? ?? const [])) {
      if (d is Map) {
        dias.add(DiaDeProgresion.fromJson(Map<String, dynamic>.from(d)));
      }
    }
    return ProgresionDoMes(
      id: (json['id'] as String?)?.trim() ?? '',
      nota: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['nota'] as Map? ?? {})),
      semanas: List.unmodifiable(semanas),
      dias: List.unmodifiable(dias),
    );
  }

  static ProgresionDoMes fromRaw(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const FormatException('progresión: non é un obxecto');
    }
    return ProgresionDoMes.fromJson(Map<String, dynamic>.from(decoded));
  }

  SemanaDeProgresion? semana(int numero) {
    for (final s in semanas) {
      if (s.numero == numero) return s;
    }
    return null;
  }

  DiaDeProgresion? dia(int semana, int dia) {
    for (final d in dias) {
      if (d.semana == semana && d.dia == dia) return d;
    }
    return null;
  }

  /// El día que toca hoy: la semana del mes (1-4) y el día laborable (1-5).
  /// En fin de semana se abre por el lunes siguiente, que es el que se
  /// prepara. Si hoy no es el mes elegido, se abre por el primer día.
  static ({int semana, int dia}) hoxe({DateTime? agora, int? mesElixido}) {
    final d = agora ?? DateTime.now();
    if (mesElixido != null && mesElixido != d.month) {
      return (semana: 1, dia: 1);
    }
    final semana = ((d.day - 1) ~/ 7 + 1).clamp(1, 4);
    final dia = d.weekday > 5 ? 1 : d.weekday;
    return (semana: semana, dia: dia);
  }
}
