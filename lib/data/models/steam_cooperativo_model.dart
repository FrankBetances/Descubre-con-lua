import 'package:flutter/foundation.dart';
import '../../core/localization/localized_string.dart';

/// Parse helper supporting both Map<String, dynamic> and String for LocalizedString.
LocalizedString _parseLocalized(dynamic value) {
  if (value is Map<String, dynamic>) {
    return LocalizedString.fromJson(value);
  } else if (value is Map) {
    return LocalizedString.fromJson(Map<String, dynamic>.from(value));
  } else if (value is String) {
    return LocalizedString(gl: value, es: value);
  }
  return const LocalizedString(gl: '', es: '');
}

/// Material manipulativo para una experiencia STEAM.
@immutable
class MaterialSteam {
  final LocalizedString item;
  final int cantidad;
  final bool seguridadMayor4cm;

  const MaterialSteam({
    required this.item,
    required this.cantidad,
    required this.seguridadMayor4cm,
  });

  factory MaterialSteam.fromJson(Map<String, dynamic> json) {
    return MaterialSteam(
      item: _parseLocalized(json['item']),
      cantidad: (json['cantidad'] as num?)?.toInt() ?? 1,
      seguridadMayor4cm: json['seguridadMayor4cm'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'cantidad': cantidad,
        'seguridadMayor4cm': seguridadMayor4cm,
      };
}

/// Rol físico cooperativo asignado a una criatura en la experiencia STEAM.
@immutable
class RolCooperativo {
  final String clave;
  final LocalizedString nombre;
  final LocalizedString mision;

  const RolCooperativo({
    required this.clave,
    required this.nombre,
    required this.mision,
  });

  factory RolCooperativo.fromJson(Map<String, dynamic> json) {
    return RolCooperativo(
      clave: json['clave']?.toString() ?? '',
      nombre: _parseLocalized(json['nombre']),
      mision: _parseLocalized(json['mision']),
    );
  }

  Map<String, dynamic> toJson() => {
        'clave': clave,
        'nombre': nombre.toJson(),
        'mision': mision.toJson(),
      };
}

/// Dinámica cooperativa en parejas o pequeños grupos sin competitividad ni pantallas.
@immutable
class DinamicaCooperativa {
  final String modalidad;
  final LocalizedString descripcion;
  final List<RolCooperativo> roles;

  const DinamicaCooperativa({
    required this.modalidad,
    required this.descripcion,
    required this.roles,
  });

  factory DinamicaCooperativa.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List<dynamic>? ?? [];
    return DinamicaCooperativa(
      modalidad: json['modalidad']?.toString() ?? 'parella',
      descripcion: _parseLocalized(json['descripcion']),
      roles: rawRoles
          .map((e) => RolCooperativo.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
    );
  }

  Map<String, dynamic> toJson() => {
        'modalidad': modalidad,
        'descripcion': descripcion.toJson(),
        'roles': roles.map((r) => r.toJson()).toList(),
      };
}

/// Ciclo didáctico tripartito (Oppia Exploration State Machine): Observa -> Experimenta -> Construye.
@immutable
class CicloDidacticoSteam {
  final LocalizedString observaPlanteamiento;
  final LocalizedString observaPregunta;
  final int pausaSilencioSegundos;
  final LocalizedString experimentaConsigna;
  final LocalizedString experimentaPistaN1;
  final LocalizedString experimentaPistaN2;
  final LocalizedString construyeReto;
  final LocalizedString construyeSintesis;

  const CicloDidacticoSteam({
    required this.observaPlanteamiento,
    required this.observaPregunta,
    required this.pausaSilencioSegundos,
    required this.experimentaConsigna,
    required this.experimentaPistaN1,
    required this.experimentaPistaN2,
    required this.construyeReto,
    required this.construyeSintesis,
  });

  factory CicloDidacticoSteam.fromJson(Map<String, dynamic> json) {
    final obs = json['observa'] as Map<String, dynamic>? ??
        (json['observa'] is Map
            ? Map<String, dynamic>.from(json['observa'] as Map)
            : const <String, dynamic>{});
    final exp = json['experimenta'] as Map<String, dynamic>? ??
        (json['experimenta'] is Map
            ? Map<String, dynamic>.from(json['experimenta'] as Map)
            : const <String, dynamic>{});
    final con = json['construye'] as Map<String, dynamic>? ??
        (json['construye'] is Map
            ? Map<String, dynamic>.from(json['construye'] as Map)
            : const <String, dynamic>{});

    return CicloDidacticoSteam(
      observaPlanteamiento: _parseLocalized(obs['planteamiento']),
      observaPregunta: _parseLocalized(obs['preguntaIndagacion']),
      pausaSilencioSegundos: (obs['pausaSilencioSegundos'] as num?)?.toInt() ?? 5,
      experimentaConsigna: _parseLocalized(exp['consignaAdulto']),
      experimentaPistaN1: _parseLocalized(exp['pistaN1']),
      experimentaPistaN2: _parseLocalized(exp['pistaN2']),
      construyeReto: _parseLocalized(con['retoTangible']),
      construyeSintesis: _parseLocalized(con['sintesisCierre']),
    );
  }

  Map<String, dynamic> toJson() => {
        'observa': {
          'planteamiento': observaPlanteamiento.toJson(),
          'preguntaIndagacion': observaPregunta.toJson(),
          'pausaSilencioSegundos': pausaSilencioSegundos,
        },
        'experimenta': {
          'consignaAdulto': experimentaConsigna.toJson(),
          'pistaN1': experimentaPistaN1.toJson(),
          'pistaN2': experimentaPistaN2.toJson(),
        },
        'construye': {
          'retoTangible': construyeReto.toJson(),
          'sintesisCierre': construyeSintesis.toJson(),
        },
      };
}

/// Comando en inglés L2 para Respuesta Física Total (TPR), 100% auditivo y cinestésico.
@immutable
class TprComandoSteam {
  final String comando;
  final String ipa;
  final String audioAsset;
  final LocalizedString accionCorporal;

  const TprComandoSteam({
    required this.comando,
    required this.ipa,
    required this.audioAsset,
    required this.accionCorporal,
  });

  factory TprComandoSteam.fromJson(Map<String, dynamic> json) {
    return TprComandoSteam(
      comando: json['comando']?.toString() ?? '',
      ipa: json['ipa']?.toString() ?? '',
      audioAsset: json['audioAsset']?.toString() ?? '',
      accionCorporal: _parseLocalized(json['accionCorporal']),
    );
  }

  Map<String, dynamic> toJson() => {
        'comando': comando,
        'ipa': ipa,
        'audioAsset': audioAsset,
        'accionCorporal': accionCorporal.toJson(),
      };
}

/// Pauta observacional de registro de 1 toque (1-Tap Logging / Obserfy).
@immutable
class EvaluacionObservacionalSteam {
  final LocalizedString criterioLogro;
  final LocalizedString pautaLogrado;
  final LocalizedString pautaAsistido;
  final LocalizedString pautaExplorando;

  const EvaluacionObservacionalSteam({
    required this.criterioLogro,
    required this.pautaLogrado,
    required this.pautaAsistido,
    required this.pautaExplorando,
  });

  factory EvaluacionObservacionalSteam.fromJson(Map<String, dynamic> json) {
    final pauta = json['pauta1Tap'] as Map<String, dynamic>? ??
        (json['pauta1Tap'] is Map
            ? Map<String, dynamic>.from(json['pauta1Tap'] as Map)
            : const <String, dynamic>{});

    return EvaluacionObservacionalSteam(
      criterioLogro: _parseLocalized(json['criterioLogro']),
      pautaLogrado: _parseLocalized(pauta['logrado']),
      pautaAsistido: _parseLocalized(pauta['asistido']),
      pautaExplorando: _parseLocalized(pauta['explorando']),
    );
  }

  Map<String, dynamic> toJson() => {
        'criterioLogro': criterioLogro.toJson(),
        'pauta1Tap': {
          'logrado': pautaLogrado.toJson(),
          'asistido': pautaAsistido.toJson(),
          'explorando': pautaExplorando.toJson(),
        },
      };
}

/// Unidad curricular STEAM canónica calibrada con los 16 marcos abiertos.
@immutable
class SteamUnit {
  final String id;
  final String estadio;
  final String nivelMadurativo;
  final LocalizedString rangoEdad;
  final LocalizedString fenomeno;
  final LocalizedString titulo;
  final int tiempoEstimadoMin;
  final List<MaterialSteam> materiales;
  final DinamicaCooperativa dinamicaCooperativa;
  final CicloDidacticoSteam cicloDidactico;
  final TprComandoSteam tprIngles;
  final EvaluacionObservacionalSteam evaluacionObservacional;

  const SteamUnit({
    required this.id,
    required this.estadio,
    required this.nivelMadurativo,
    required this.rangoEdad,
    required this.fenomeno,
    required this.titulo,
    required this.tiempoEstimadoMin,
    required this.materiales,
    required this.dinamicaCooperativa,
    required this.cicloDidactico,
    required this.tprIngles,
    required this.evaluacionObservacional,
  });

  factory SteamUnit.fromJson(Map<String, dynamic> json) {
    final rawMats = json['materiales'] as List<dynamic>? ?? [];
    final dc = json['dinamicaCooperativa'] as Map<String, dynamic>? ??
        (json['dinamicaCooperativa'] is Map
            ? Map<String, dynamic>.from(json['dinamicaCooperativa'] as Map)
            : const <String, dynamic>{});
    final cd = json['cicloDidactico'] as Map<String, dynamic>? ??
        (json['cicloDidactico'] is Map
            ? Map<String, dynamic>.from(json['cicloDidactico'] as Map)
            : const <String, dynamic>{});
    final tpr = json['tprIngles'] as Map<String, dynamic>? ??
        (json['tprIngles'] is Map
            ? Map<String, dynamic>.from(json['tprIngles'] as Map)
            : const <String, dynamic>{});
    final eval = json['evaluacionObservacional'] as Map<String, dynamic>? ??
        (json['evaluacionObservacional'] is Map
            ? Map<String, dynamic>.from(json['evaluacionObservacional'] as Map)
            : const <String, dynamic>{});

    return SteamUnit(
      id: json['id']?.toString() ?? '',
      estadio: json['estadio']?.toString() ?? 'curso_0_2',
      nivelMadurativo: json['nivelMadurativo']?.toString() ?? 'I1',
      rangoEdad: _parseLocalized(json['rangoEdad']),
      fenomeno: _parseLocalized(json['fenomeno']),
      titulo: _parseLocalized(json['titulo']),
      tiempoEstimadoMin: (json['tiempoEstimadoMin'] as num?)?.toInt() ?? 15,
      materiales: rawMats
          .map((e) => MaterialSteam.fromJson(
              e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(growable: false),
      dinamicaCooperativa: DinamicaCooperativa.fromJson(dc),
      cicloDidactico: CicloDidacticoSteam.fromJson(cd),
      tprIngles: TprComandoSteam.fromJson(tpr),
      evaluacionObservacional: EvaluacionObservacionalSteam.fromJson(eval),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'estadio': estadio,
        'nivelMadurativo': nivelMadurativo,
        'rangoEdad': rangoEdad.toJson(),
        'fenomeno': fenomeno.toJson(),
        'titulo': titulo.toJson(),
        'tiempoEstimadoMin': tiempoEstimadoMin,
        'materiales': materiales.map((m) => m.toJson()).toList(),
        'dinamicaCooperativa': dinamicaCooperativa.toJson(),
        'cicloDidactico': cicloDidactico.toJson(),
        'tprIngles': tprIngles.toJson(),
        'evaluacionObservacional': evaluacionObservacional.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SteamUnit && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
