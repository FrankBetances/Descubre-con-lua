import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// TPR action prompt attached to a classroom dynamic.
@immutable
class DinamicaTprIngles {
  final String comando;
  final LocalizedString accion;

  const DinamicaTprIngles({
    required this.comando,
    required this.accion,
  });

  factory DinamicaTprIngles.fromJson(Map<String, dynamic> json) {
    return DinamicaTprIngles(
      comando: json['comando']?.toString().trim() ??
          json['frase']?.toString().trim() ??
          '',
      accion: LocalizedString.fromJson(
        json['accion'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'comando': comando,
        'accion': accion.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DinamicaTprIngles &&
          runtimeType == other.runtimeType &&
          comando == other.comando &&
          accion == other.accion;

  @override
  int get hashCode => Object.hash(comando, accion);

  @override
  String toString() => 'DinamicaTprIngles($comando)';
}

/// Pedagogical classroom dynamic structured for the daily school routine.
///
/// Ported from `.studio_ref/src/data/dinamicasPedagogicasData.ts`.
@immutable
class DinamicaPedagogica {
  final String id;
  final String clave;
  final String diaSemana; // 'luns', 'martes', 'mercores', 'xoves', 'venres'
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final int duracionMinutos;
  final int ritmoBpm;
  final LocalizedString obxectivo;
  final LocalizedString procedementoPasoAPaso;
  final LocalizedString materialSensorial;
  final LocalizedString fraseDocente;
  final DinamicaTprIngles? tprIngles;

  const DinamicaPedagogica({
    required this.id,
    required this.clave,
    required this.diaSemana,
    required this.titulo,
    required this.subtitulo,
    required this.duracionMinutos,
    required this.ritmoBpm,
    required this.obxectivo,
    required this.procedementoPasoAPaso,
    required this.materialSensorial,
    required this.fraseDocente,
    this.tprIngles,
  });

  factory DinamicaPedagogica.fromJson(Map<String, dynamic> json) {
    final rawTpr = json['tprIngles'] ?? json['tpr_ingles'];
    final DinamicaTprIngles? tpr = rawTpr is Map<String, dynamic>
        ? DinamicaTprIngles.fromJson(rawTpr)
        : (rawTpr is Map
            ? DinamicaTprIngles.fromJson(Map<String, dynamic>.from(rawTpr))
            : null);

    return DinamicaPedagogica(
      id: json['id']?.toString().trim() ?? '',
      clave: json['clave']?.toString().trim() ?? '',
      diaSemana: json['diaSemana']?.toString().trim() ??
          json['dia_semana']?.toString().trim() ??
          'luns',
      titulo: LocalizedString.fromJson(
        json['titulo'] as Map<String, dynamic>? ?? const {},
      ),
      subtitulo: LocalizedString.fromJson(
        json['subtitulo'] as Map<String, dynamic>? ?? const {},
      ),
      duracionMinutos: (json['duracionMinutos'] as num?)?.toInt() ??
          (json['duracion_minutos'] as num?)?.toInt() ??
          15,
      ritmoBpm: (json['ritmoBpm'] as num?)?.toInt() ??
          (json['ritmo_bpm'] as num?)?.toInt() ??
          72,
      obxectivo: LocalizedString.fromJson(
        json['obxectivo'] as Map<String, dynamic>? ??
            json['objetivo'] as Map<String, dynamic>? ??
            const {},
      ),
      procedementoPasoAPaso: LocalizedString.fromJson(
        json['procedementoPasoAPaso'] as Map<String, dynamic>? ??
            json['procedemento_paso_a_paso'] as Map<String, dynamic>? ??
            json['procedimiento_paso_a_paso'] as Map<String, dynamic>? ??
            const {},
      ),
      materialSensorial: LocalizedString.fromJson(
        json['materialSensorial'] as Map<String, dynamic>? ??
            json['material_sensorial'] as Map<String, dynamic>? ??
            const {},
      ),
      fraseDocente: LocalizedString.fromJson(
        json['fraseDocente'] as Map<String, dynamic>? ??
            json['frase_docente'] as Map<String, dynamic>? ??
            const {},
      ),
      tprIngles: tpr,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clave': clave,
        'diaSemana': diaSemana,
        'titulo': titulo.toJson(),
        'subtitulo': subtitulo.toJson(),
        'duracionMinutos': duracionMinutos,
        'ritmoBpm': ritmoBpm,
        'obxectivo': obxectivo.toJson(),
        'procedementoPasoAPaso': procedementoPasoAPaso.toJson(),
        'materialSensorial': materialSensorial.toJson(),
        'fraseDocente': fraseDocente.toJson(),
        if (tprIngles != null) 'tprIngles': tprIngles!.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DinamicaPedagogica &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          clave == other.clave &&
          diaSemana == other.diaSemana &&
          titulo == other.titulo &&
          subtitulo == other.subtitulo &&
          duracionMinutos == other.duracionMinutos &&
          ritmoBpm == other.ritmoBpm &&
          obxectivo == other.obxectivo &&
          procedementoPasoAPaso == other.procedementoPasoAPaso &&
          materialSensorial == other.materialSensorial &&
          fraseDocente == other.fraseDocente &&
          tprIngles == other.tprIngles;

  @override
  int get hashCode => Object.hash(
        id,
        clave,
        diaSemana,
        titulo,
        subtitulo,
        duracionMinutos,
        ritmoBpm,
        obxectivo,
        procedementoPasoAPaso,
        materialSensorial,
        fraseDocente,
        tprIngles,
      );

  @override
  String toString() => 'DinamicaPedagogica($clave, $diaSemana, $titulo)';
}
