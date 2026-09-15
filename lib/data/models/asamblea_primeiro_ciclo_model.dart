import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';
import 'asamblea_segundo_ciclo_model.dart' show FaseAsamblea;
import 'unidad_model.dart' show Revision;

/// Os dous tramos do 1.º ciclo de educación infantil (0-3 anos).
///
/// O documento curricular do primeiro ciclo describe, para CADA mes, dúas
/// dinámicas distintas: unha para lactantes de 0 a 2 e outra para a aula de 2
/// a 3. Ese é o escalonamento do ciclo. Non é o mesmo contido con outra
/// etiqueta: cambian o material, a canción e as ordes.
enum TramoPrimeiroCiclo {
  lactantes0a2,
  deambulantes2a3;

  /// Clave canónica empregada nos esquemas JSON e no nome do ficheiro.
  String get clave => switch (this) {
        TramoPrimeiroCiclo.lactantes0a2 => '0_2',
        TramoPrimeiroCiclo.deambulantes2a3 => '2_3',
      };

  /// Etiqueta curta para o selector de tramo.
  LocalizedString get etiquetaCorta => switch (this) {
        TramoPrimeiroCiclo.lactantes0a2 => const LocalizedString(
            gl: '0-2 anos',
            es: '0-2 años',
          ),
        TramoPrimeiroCiclo.deambulantes2a3 => const LocalizedString(
            gl: '2-3 anos',
            es: '2-3 años',
          ),
      };

  /// Como chama o documento a cada grupo. Vai debaixo da etiqueta, igual que
  /// no 2.º ciclo vai a metodoloxía TPR: di por que a sesión é distinta.
  LocalizedString get descricionCurta => switch (this) {
        TramoPrimeiroCiclo.lactantes0a2 => const LocalizedString(
            gl: 'Colo e contacto',
            es: 'Regazo y contacto',
          ),
        TramoPrimeiroCiclo.deambulantes2a3 => const LocalizedString(
            gl: 'Movemento en grupo',
            es: 'Movimiento en grupo',
          ),
      };

  static TramoPrimeiroCiclo desdeClave(String? valor) {
    final v = valor?.trim();
    if (v == '2_3') return TramoPrimeiroCiclo.deambulantes2a3;
    return TramoPrimeiroCiclo.lactantes0a2;
  }
}

/// Unha microcápsula matinal do 1.º ciclo: un mes, un tramo, catro fases.
@immutable
class AsambleaPrimeiroCiclo {
  final String id;
  final TramoPrimeiroCiclo tramo;

  /// Mes do calendario (9 = setembro … 6 = xuño).
  final int mes;

  final LocalizedString titulo;
  final LocalizedString centroInteres;
  final int duracionTotalMinutos;

  /// O material manipulable do mes, tal e como o nomea o documento.
  final LocalizedString materialDoMes;

  /// A canción que o documento nomea para este mes e tramo. Vai baleira cando
  /// o documento non nomea ningunha: non se inventa unha.
  final String cancionDoMes;

  final List<FaseAsamblea> fases;
  final Revision revision;

  const AsambleaPrimeiroCiclo({
    required this.id,
    required this.tramo,
    required this.mes,
    required this.titulo,
    required this.centroInteres,
    required this.duracionTotalMinutos,
    required this.materialDoMes,
    required this.cancionDoMes,
    required this.fases,
    required this.revision,
  });

  factory AsambleaPrimeiroCiclo.fromJson(Map<String, dynamic> json) {
    final rawFases = json['fases'];
    final List<FaseAsamblea> fases = [];
    if (rawFases is List) {
      for (final f in rawFases) {
        if (f is Map) {
          fases.add(FaseAsamblea.fromJson(Map<String, dynamic>.from(f)));
        }
      }
    }
    fases.sort((a, b) => a.orden.compareTo(b.orden));

    return AsambleaPrimeiroCiclo(
      id: (json['id'] as String?)?.trim() ?? '',
      tramo: TramoPrimeiroCiclo.desdeClave(json['tramo'] as String?),
      mes: (json['mes'] as num?)?.toInt() ?? 9,
      titulo: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['titulo'] as Map)),
      centroInteres: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['centroInteres'] as Map)),
      duracionTotalMinutos:
          (json['duracionTotalMinutos'] as num?)?.toInt() ?? 9,
      materialDoMes: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['materialDoMes'] as Map)),
      cancionDoMes: (json['cancionDoMes'] as String?) ?? '',
      fases: List.unmodifiable(fases),
      revision: json['revision'] is Map
          ? Revision.fromJson(Map<String, dynamic>.from(json['revision'] as Map))
          : const Revision(
              autor: '',
              revisorPedagogico: '',
              fechaRevision: '',
              version: '',
              aprobadoParaAula: false,
            ),
    );
  }
}
