import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// Classroom assembly activity and pedagogical guidance for teachers (profesorado).
@immutable
class DiaProfesorado {
  final LocalizedString actividadAula;
  final LocalizedString dinamica;
  final int duracionMin;
  final String? tprIngles;
  final LocalizedString consignaDocente;

  const DiaProfesorado({
    required this.actividadAula,
    required this.dinamica,
    required this.duracionMin,
    this.tprIngles,
    required this.consignaDocente,
  });

  factory DiaProfesorado.fromJson(Map<String, dynamic> json) {
    return DiaProfesorado(
      actividadAula: LocalizedString.fromJson(
        json['actividadAula'] as Map<String, dynamic>? ??
            json['actividad_aula'] as Map<String, dynamic>? ??
            const {},
      ),
      dinamica: LocalizedString.fromJson(
        json['dinamica'] as Map<String, dynamic>? ?? const {},
      ),
      duracionMin: (json['duracionMin'] as num?)?.toInt() ??
          (json['duracion_min'] as num?)?.toInt() ??
          15,
      tprIngles:
          json['tprIngles']?.toString() ?? json['tpr_ingles']?.toString(),
      consignaDocente: LocalizedString.fromJson(
        json['consignaDocente'] as Map<String, dynamic>? ??
            json['consigna_docente'] as Map<String, dynamic>? ??
            const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'actividadAula': actividadAula.toJson(),
        'dinamica': dinamica.toJson(),
        'duracionMin': duracionMin,
        if (tprIngles != null) 'tprIngles': tprIngles,
        'consignaDocente': consignaDocente.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaProfesorado &&
          runtimeType == other.runtimeType &&
          actividadAula == other.actividadAula &&
          dinamica == other.dinamica &&
          duracionMin == other.duracionMin &&
          tprIngles == other.tprIngles &&
          consignaDocente == other.consignaDocente;

  @override
  int get hashCode => Object.hash(
        actividadAula,
        dinamica,
        duracionMin,
        tprIngles,
        consignaDocente,
      );

  @override
  String toString() => 'DiaProfesorado($actividadAula, $duracionMin min)';
}

/// Home routine and screen-free connection moments for families (familias).
@immutable
class DiaFamilias {
  final LocalizedString rutinaFogar;
  final LocalizedString momento;
  final bool senPantallas;
  final LocalizedString consignaFamilia;
  final LocalizedString fraseConexion;

  const DiaFamilias({
    required this.rutinaFogar,
    required this.momento,
    this.senPantallas = true,
    required this.consignaFamilia,
    required this.fraseConexion,
  });

  factory DiaFamilias.fromJson(Map<String, dynamic> json) {
    return DiaFamilias(
      rutinaFogar: LocalizedString.fromJson(
        json['rutinaFogar'] as Map<String, dynamic>? ??
            json['rutina_fogar'] as Map<String, dynamic>? ??
            const {},
      ),
      momento: LocalizedString.fromJson(
        json['momento'] as Map<String, dynamic>? ?? const {},
      ),
      senPantallas: json['senPantallas'] as bool? ??
          json['sen_pantallas'] as bool? ??
          true,
      consignaFamilia: LocalizedString.fromJson(
        json['consignaFamilia'] as Map<String, dynamic>? ??
            json['consigna_familia'] as Map<String, dynamic>? ??
            const {},
      ),
      fraseConexion: LocalizedString.fromJson(
        json['fraseConexion'] as Map<String, dynamic>? ??
            json['frase_conexion'] as Map<String, dynamic>? ??
            const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'rutinaFogar': rutinaFogar.toJson(),
        'momento': momento.toJson(),
        'senPantallas': senPantallas,
        'consignaFamilia': consignaFamilia.toJson(),
        'fraseConexion': fraseConexion.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaFamilias &&
          runtimeType == other.runtimeType &&
          rutinaFogar == other.rutinaFogar &&
          momento == other.momento &&
          senPantallas == other.senPantallas &&
          consignaFamilia == other.consignaFamilia &&
          fraseConexion == other.fraseConexion;

  @override
  int get hashCode => Object.hash(
        rutinaFogar,
        momento,
        senPantallas,
        consignaFamilia,
        fraseConexion,
      );

  @override
  String toString() => 'DiaFamilias($rutinaFogar, senPantallas: $senPantallas)';
}

/// Dual-track day model supporting synchronized classroom assembly and home routines.
///
/// Ported from `.studio_ref/src/data/calendarDaysData.ts` and `.studio_ref/src/types.ts`.
/// Represents each day of the 1,000-day progression (5 courses × 10 months × 20 school days).
@immutable
class DiaCalendarioDual {
  final int dia; // 1..20 (day in month)
  final int diaSemana; // 0: Luns to 4: Venres
  final int diaSemanaNumero; // 1..5
  final LocalizedString nombreDiaSemana;
  final int semanaNumero; // 1..4
  final int semanaCursoNumero; // 1..40
  final int semanaGlobalNumero; // 1..200
  final int diaCursoNumero; // 1..200
  final int diaGlobalNumero; // 1..1000
  final int mesNumero; // 1..10
  final int mesGlobalNumero; // 1..50
  final String fechaClave; // e.g. "curso_0_2-mes-1-dia-1"
  final bool esFinDeSemana;
  final LocalizedString temaDia;
  final DiaProfesorado profesorado;
  final DiaFamilias familias;

  const DiaCalendarioDual({
    required this.dia,
    required this.diaSemana,
    required this.diaSemanaNumero,
    required this.nombreDiaSemana,
    required this.semanaNumero,
    required this.semanaCursoNumero,
    required this.semanaGlobalNumero,
    required this.diaCursoNumero,
    required this.diaGlobalNumero,
    required this.mesNumero,
    required this.mesGlobalNumero,
    required this.fechaClave,
    this.esFinDeSemana = false,
    required this.temaDia,
    required this.profesorado,
    required this.familias,
  });

  factory DiaCalendarioDual.fromJson(Map<String, dynamic> json) {
    final rawNombre = json['nombreDiaSemana'] ?? json['nombre_dia_semana'];
    final LocalizedString nombreDia = rawNombre is Map<String, dynamic>
        ? LocalizedString.fromJson(rawNombre)
        : (rawNombre is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawNombre))
            : const LocalizedString(gl: 'Día', es: 'Día'));

    final rawTema = json['temaDia'] ?? json['tema_dia'];
    final LocalizedString tema = rawTema is Map<String, dynamic>
        ? LocalizedString.fromJson(rawTema)
        : (rawTema is Map
            ? LocalizedString.fromJson(Map<String, dynamic>.from(rawTema))
            : const LocalizedString(gl: '', es: ''));

    final rawProf = json['profesorado'] as Map<String, dynamic>? ??
        (json['profesorado'] is Map
            ? Map<String, dynamic>.from(json['profesorado'] as Map)
            : const {});

    final rawFam = json['familias'] as Map<String, dynamic>? ??
        (json['familias'] is Map
            ? Map<String, dynamic>.from(json['familias'] as Map)
            : const {});

    return DiaCalendarioDual(
      dia: (json['dia'] as num?)?.toInt() ?? 1,
      diaSemana: (json['diaSemana'] as num?)?.toInt() ??
          (json['dia_semana'] as num?)?.toInt() ??
          0,
      diaSemanaNumero: (json['diaSemanaNumero'] as num?)?.toInt() ??
          (json['dia_semana_numero'] as num?)?.toInt() ??
          1,
      nombreDiaSemana: nombreDia,
      semanaNumero: (json['semanaNumero'] as num?)?.toInt() ??
          (json['semana_numero'] as num?)?.toInt() ??
          1,
      semanaCursoNumero: (json['semanaCursoNumero'] as num?)?.toInt() ??
          (json['semana_curso_numero'] as num?)?.toInt() ??
          1,
      semanaGlobalNumero: (json['semanaGlobalNumero'] as num?)?.toInt() ??
          (json['semana_global_numero'] as num?)?.toInt() ??
          1,
      diaCursoNumero: (json['diaCursoNumero'] as num?)?.toInt() ??
          (json['dia_curso_numero'] as num?)?.toInt() ??
          1,
      diaGlobalNumero: (json['diaGlobalNumero'] as num?)?.toInt() ??
          (json['dia_global_numero'] as num?)?.toInt() ??
          1,
      mesNumero: (json['mesNumero'] as num?)?.toInt() ??
          (json['mes_numero'] as num?)?.toInt() ??
          1,
      mesGlobalNumero: (json['mesGlobalNumero'] as num?)?.toInt() ??
          (json['mes_global_numero'] as num?)?.toInt() ??
          1,
      fechaClave: json['fechaClave']?.toString().trim() ??
          json['fecha_clave']?.toString().trim() ??
          '',
      esFinDeSemana: json['esFinDeSemana'] as bool? ??
          json['es_fin_de_semana'] as bool? ??
          false,
      temaDia: tema,
      profesorado: DiaProfesorado.fromJson(rawProf),
      familias: DiaFamilias.fromJson(rawFam),
    );
  }

  Map<String, dynamic> toJson() => {
        'dia': dia,
        'diaSemana': diaSemana,
        'diaSemanaNumero': diaSemanaNumero,
        'nombreDiaSemana': nombreDiaSemana.toJson(),
        'semanaNumero': semanaNumero,
        'semanaCursoNumero': semanaCursoNumero,
        'semanaGlobalNumero': semanaGlobalNumero,
        'diaCursoNumero': diaCursoNumero,
        'diaGlobalNumero': diaGlobalNumero,
        'mesNumero': mesNumero,
        'mesGlobalNumero': mesGlobalNumero,
        'fechaClave': fechaClave,
        'esFinDeSemana': esFinDeSemana,
        'temaDia': temaDia.toJson(),
        'profesorado': profesorado.toJson(),
        'familias': familias.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiaCalendarioDual &&
          runtimeType == other.runtimeType &&
          dia == other.dia &&
          diaSemana == other.diaSemana &&
          diaSemanaNumero == other.diaSemanaNumero &&
          nombreDiaSemana == other.nombreDiaSemana &&
          semanaNumero == other.semanaNumero &&
          semanaCursoNumero == other.semanaCursoNumero &&
          semanaGlobalNumero == other.semanaGlobalNumero &&
          diaCursoNumero == other.diaCursoNumero &&
          diaGlobalNumero == other.diaGlobalNumero &&
          mesNumero == other.mesNumero &&
          mesGlobalNumero == other.mesGlobalNumero &&
          fechaClave == other.fechaClave &&
          esFinDeSemana == other.esFinDeSemana &&
          temaDia == other.temaDia &&
          profesorado == other.profesorado &&
          familias == other.familias;

  @override
  int get hashCode => Object.hash(
        dia,
        diaSemana,
        diaSemanaNumero,
        nombreDiaSemana,
        semanaNumero,
        semanaCursoNumero,
        semanaGlobalNumero,
        diaCursoNumero,
        diaGlobalNumero,
        mesNumero,
        mesGlobalNumero,
        fechaClave,
        esFinDeSemana,
        temaDia,
        profesorado,
        familias,
      );

  @override
  String toString() =>
      'DiaCalendarioDual(diaGlobal: $diaGlobalNumero, fechaClave: $fechaClave, $temaDia)';
}

/// English pedagogical item in a curricular month.
@immutable
class InglesMesCurricular {
  final List<String> lexico;
  final List<String> tpr;
  final String frase;
  final String? audioId;

  const InglesMesCurricular({
    required this.lexico,
    required this.tpr,
    required this.frase,
    this.audioId,
  });

  factory InglesMesCurricular.fromJson(Map<String, dynamic> json) {
    final rawLex = json['lexico'];
    final List<String> lexicoList =
        rawLex is List ? rawLex.map((e) => e.toString()).toList() : const [];

    final rawTpr = json['tpr'];
    final List<String> tprList =
        rawTpr is List ? rawTpr.map((e) => e.toString()).toList() : const [];

    return InglesMesCurricular(
      lexico: List.unmodifiable(lexicoList),
      tpr: List.unmodifiable(tprList),
      frase: json['frase']?.toString() ?? '',
      audioId: json['audio_id']?.toString() ?? json['audioId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'lexico': lexico,
        'tpr': tpr,
        'frase': frase,
        if (audioId != null) 'audio_id': audioId,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InglesMesCurricular &&
          runtimeType == other.runtimeType &&
          listEquals(lexico, other.lexico) &&
          listEquals(tpr, other.tpr) &&
          frase == other.frase &&
          audioId == other.audioId;

  @override
  int get hashCode => Object.hash(
        Object.hashAll(lexico),
        Object.hashAll(tpr),
        frase,
        audioId,
      );
}

/// Month definition across the 50-month curricular timeline (5 courses × 10 months).
///
/// Ported from `.studio_ref/src/data/curriculo50Meses.ts`.
@immutable
class MesCurricular50 {
  final String id;
  final String cursoId; // 'curso_0_2', 'curso_2_3', etc.
  final int cursoNumero; // 1..5
  final int mesNumero; // 1..10
  final LocalizedString nombreMes;
  final String icono;
  final LocalizedString centroInteres;
  final LocalizedString objetivoPedagogico;
  final LocalizedString actividadAula;
  final LocalizedString actividadHogar;
  final LocalizedString rutinaRecomendadaHogar;
  final int minutosSugeridos;
  final InglesMesCurricular ingles;
  final LocalizedString dinamicaEvolutiva;
  final LocalizedString ponteCasaEscola;

  const MesCurricular50({
    required this.id,
    required this.cursoId,
    required this.cursoNumero,
    required this.mesNumero,
    required this.nombreMes,
    required this.icono,
    required this.centroInteres,
    required this.objetivoPedagogico,
    required this.actividadAula,
    required this.actividadHogar,
    required this.rutinaRecomendadaHogar,
    required this.minutosSugeridos,
    required this.ingles,
    required this.dinamicaEvolutiva,
    required this.ponteCasaEscola,
  });

  factory MesCurricular50.fromJson(Map<String, dynamic> json) {
    final rawIngles = json['ingles'] as Map<String, dynamic>? ??
        (json['ingles'] is Map
            ? Map<String, dynamic>.from(json['ingles'] as Map)
            : const {});

    return MesCurricular50(
      id: json['id']?.toString().trim() ?? '',
      cursoId: json['cursoId']?.toString().trim() ??
          json['curso_id']?.toString().trim() ??
          'curso_0_2',
      cursoNumero: (json['cursoNumero'] as num?)?.toInt() ??
          (json['curso_numero'] as num?)?.toInt() ??
          1,
      mesNumero: (json['mesNumero'] as num?)?.toInt() ??
          (json['mes_numero'] as num?)?.toInt() ??
          1,
      nombreMes: LocalizedString.fromJson(
        json['nombreMes'] as Map<String, dynamic>? ??
            json['nombre_mes'] as Map<String, dynamic>? ??
            const {},
      ),
      icono: json['icono']?.toString().trim() ?? 'lua',
      centroInteres: LocalizedString.fromJson(
        json['centroInteres'] as Map<String, dynamic>? ??
            json['centro_interes'] as Map<String, dynamic>? ??
            const {},
      ),
      objetivoPedagogico: LocalizedString.fromJson(
        json['objetivoPedagogico'] as Map<String, dynamic>? ??
            json['objetivo_pedagogico'] as Map<String, dynamic>? ??
            const {},
      ),
      actividadAula: LocalizedString.fromJson(
        json['actividadAula'] as Map<String, dynamic>? ??
            json['actividad_aula'] as Map<String, dynamic>? ??
            const {},
      ),
      actividadHogar: LocalizedString.fromJson(
        json['actividadHogar'] as Map<String, dynamic>? ??
            json['actividad_hogar'] as Map<String, dynamic>? ??
            const {},
      ),
      rutinaRecomendadaHogar: LocalizedString.fromJson(
        json['rutinaRecomendadaHogar'] as Map<String, dynamic>? ??
            json['rutina_recomendada_hogar'] as Map<String, dynamic>? ??
            const {},
      ),
      minutosSugeridos: (json['minutosSugeridos'] as num?)?.toInt() ??
          (json['minutos_sugeridos'] as num?)?.toInt() ??
          3,
      ingles: InglesMesCurricular.fromJson(rawIngles),
      dinamicaEvolutiva: LocalizedString.fromJson(
        json['dinamicaEvolutiva'] as Map<String, dynamic>? ??
            json['dinamica_evolutiva'] as Map<String, dynamic>? ??
            const {},
      ),
      ponteCasaEscola: LocalizedString.fromJson(
        json['ponteCasaEscola'] as Map<String, dynamic>? ??
            json['ponte_casa_escola'] as Map<String, dynamic>? ??
            const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cursoId': cursoId,
        'cursoNumero': cursoNumero,
        'mesNumero': mesNumero,
        'nombreMes': nombreMes.toJson(),
        'icono': icono,
        'centroInteres': centroInteres.toJson(),
        'objetivoPedagogico': objetivoPedagogico.toJson(),
        'actividadAula': actividadAula.toJson(),
        'actividadHogar': actividadHogar.toJson(),
        'rutinaRecomendadaHogar': rutinaRecomendadaHogar.toJson(),
        'minutosSugeridos': minutosSugeridos,
        'ingles': ingles.toJson(),
        'dinamicaEvolutiva': dinamicaEvolutiva.toJson(),
        'ponteCasaEscola': ponteCasaEscola.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MesCurricular50 &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          cursoId == other.cursoId &&
          cursoNumero == other.cursoNumero &&
          mesNumero == other.mesNumero &&
          nombreMes == other.nombreMes &&
          icono == other.icono &&
          centroInteres == other.centroInteres &&
          objetivoPedagogico == other.objetivoPedagogico &&
          actividadAula == other.actividadAula &&
          actividadHogar == other.actividadHogar &&
          rutinaRecomendadaHogar == other.rutinaRecomendadaHogar &&
          minutosSugeridos == other.minutosSugeridos &&
          ingles == other.ingles &&
          dinamicaEvolutiva == other.dinamicaEvolutiva &&
          ponteCasaEscola == other.ponteCasaEscola;

  @override
  int get hashCode => Object.hash(
        id,
        cursoId,
        cursoNumero,
        mesNumero,
        nombreMes,
        icono,
        centroInteres,
        objetivoPedagogico,
        actividadAula,
        actividadHogar,
        rutinaRecomendadaHogar,
        minutosSugeridos,
        ingles,
        dinamicaEvolutiva,
        ponteCasaEscola,
      );

  @override
  String toString() => 'MesCurricular50($id, curso: $cursoId, mes: $mesNumero)';
}

/// Course metadata for one of the 5 Infant Education courses.
@immutable
class CursoInfo {
  final String id; // 'curso_0_2', 'curso_2_3', etc.
  final int orden; // 1..5
  final String ciclo; // 'ciclo1' | 'ciclo2'
  final LocalizedString nombre;
  final LocalizedString subtitulo;
  final String edad;
  final LocalizedString badge;
  final LocalizedString etapaCurricular;
  final LocalizedString descripcion;

  const CursoInfo({
    required this.id,
    required this.orden,
    required this.ciclo,
    required this.nombre,
    required this.subtitulo,
    required this.edad,
    required this.badge,
    required this.etapaCurricular,
    required this.descripcion,
  });

  factory CursoInfo.fromJson(Map<String, dynamic> json) {
    return CursoInfo(
      id: json['id']?.toString().trim() ?? 'curso_0_2',
      orden: (json['orden'] as num?)?.toInt() ?? 1,
      ciclo: json['ciclo']?.toString().trim() ?? 'ciclo1',
      nombre: LocalizedString.fromJson(
        json['nombre'] as Map<String, dynamic>? ?? const {},
      ),
      subtitulo: LocalizedString.fromJson(
        json['subtitulo'] as Map<String, dynamic>? ?? const {},
      ),
      edad: json['edad']?.toString().trim() ?? '',
      badge: LocalizedString.fromJson(
        json['badge'] as Map<String, dynamic>? ?? const {},
      ),
      etapaCurricular: LocalizedString.fromJson(
        json['etapaCurricular'] as Map<String, dynamic>? ??
            json['etapa_curricular'] as Map<String, dynamic>? ??
            const {},
      ),
      descripcion: LocalizedString.fromJson(
        json['descripcion'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orden': orden,
        'ciclo': ciclo,
        'nombre': nombre.toJson(),
        'subtitulo': subtitulo.toJson(),
        'edad': edad,
        'badge': badge.toJson(),
        'etapaCurricular': etapaCurricular.toJson(),
        'descripcion': descripcion.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CursoInfo &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          orden == other.orden &&
          ciclo == other.ciclo &&
          nombre == other.nombre &&
          subtitulo == other.subtitulo &&
          edad == other.edad &&
          badge == other.badge &&
          etapaCurricular == other.etapaCurricular &&
          descripcion == other.descripcion;

  @override
  int get hashCode => Object.hash(
        id,
        orden,
        ciclo,
        nombre,
        subtitulo,
        edad,
        badge,
        etapaCurricular,
        descripcion,
      );

  @override
  String toString() => 'CursoInfo($id, orden: $orden, $nombre)';
}
