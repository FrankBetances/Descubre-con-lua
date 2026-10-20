import 'package:flutter/foundation.dart';

/// Revision and pedagogical certification metadata.
@immutable
class Revision {
  final String autor;
  final String revisorPedagogico;
  final String fechaRevision;
  final String version;
  final bool aprobadoParaAula;

  const Revision({
    required this.autor,
    required this.revisorPedagogico,
    required this.fechaRevision,
    required this.version,
    required this.aprobadoParaAula,
  });

  factory Revision.fromJson(Map<String, dynamic> json) {
    return Revision(
      autor: json['autor']?.toString().trim() ?? '',
      revisorPedagogico: json['revisorPedagogico']?.toString().trim() ??
          json['revisor_pedagogico']?.toString().trim() ??
          '',
      fechaRevision: json['fechaRevision']?.toString().trim() ??
          json['fecha_revision']?.toString().trim() ??
          '',
      version: json['version']?.toString().trim() ?? '1.0.0',
      aprobadoParaAula: json['aprobadoParaAula'] as bool? ??
          json['aprobado_para_aula'] as bool? ??
          false,
    );
  }

  Map<String, dynamic> toJson() => {
        'autor': autor,
        'revisorPedagogico': revisorPedagogico,
        'fechaRevision': fechaRevision,
        'version': version,
        'aprobadoParaAula': aprobadoParaAula,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Revision &&
          runtimeType == other.runtimeType &&
          autor == other.autor &&
          revisorPedagogico == other.revisorPedagogico &&
          fechaRevision == other.fechaRevision &&
          version == other.version &&
          aprobadoParaAula == other.aprobadoParaAula;

  @override
  int get hashCode => Object.hash(
        autor,
        revisorPedagogico,
        fechaRevision,
        version,
        aprobadoParaAula,
      );

  @override
  String toString() =>
      'Revision(v$version, $fechaRevision, approved: $aprobadoParaAula)';
}
