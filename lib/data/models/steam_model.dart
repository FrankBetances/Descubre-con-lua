import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';

/// Para quién está escrita la sesión.
///
/// Las dos versiones de una unidad no son la misma con otro título: en el aula
/// hay un grupo, una docente y material de aula; en casa hay una persona adulta,
/// una criatura y lo que haya en la cocina. Por eso cada unidad trae las dos
/// enteras y cada portal abre la suya.
enum SteamAudiencia { aula, hogar }

LocalizedString _texto(dynamic value) {
  if (value is Map) {
    return LocalizedString.fromJson(Map<String, dynamic>.from(value));
  }
  return const LocalizedString(gl: '', es: '');
}

Map<String, dynamic> _mapa(dynamic value) =>
    value is Map ? Map<String, dynamic>.from(value) : const <String, dynamic>{};

List<Map<String, dynamic>> _lista(dynamic value) => value is List
    ? value.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList()
    : const [];

List<String> _cadenas(dynamic value) => value is List
    ? value.map((e) => e.toString().trim()).toList(growable: false)
    : const [];

/// Un material de la sesión.
@immutable
class SteamMaterial {
  final LocalizedString item;

  /// Más de 4 cm: que no quepa en la boca, en la nariz ni en el oído. El
  /// validador lo exige en todos los materiales de las cinco unidades, no solo
  /// en las de 0 a 3 años: los cuerpos extraños en la nariz y el oído se
  /// concentran entre el año y los cinco.
  final bool seguridadMayor4cm;

  const SteamMaterial({required this.item, required this.seguridadMayor4cm});

  factory SteamMaterial.fromJson(Map<String, dynamic> json) => SteamMaterial(
        item: _texto(json['item']),
        seguridadMayor4cm: json['seguridadMayor4cm'] == true,
      );

  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'seguridadMayor4cm': seguridadMayor4cm,
      };
}

/// Un papel del juego cooperativo. Solo a partir de los 3 años: antes, el
/// juego es en paralelo y repartir papeles no tiene sentido.
@immutable
class SteamRol {
  final String clave;
  final LocalizedString nombre;
  final LocalizedString mision;

  const SteamRol({
    required this.clave,
    required this.nombre,
    required this.mision,
  });

  factory SteamRol.fromJson(Map<String, dynamic> json) => SteamRol(
        clave: json['clave']?.toString() ?? '',
        nombre: _texto(json['nombre']),
        mision: _texto(json['mision']),
      );

  Map<String, dynamic> toJson() => {
        'clave': clave,
        'nombre': nombre.toJson(),
        'mision': mision.toJson(),
      };
}

/// Observa, experimenta y construye: los tres pasos de la sesión.
@immutable
class SteamCiclo {
  final LocalizedString planteamiento;
  final LocalizedString preguntaIndagacion;
  final int pausaSilencioSegundos;
  final LocalizedString consignaAdulto;
  final LocalizedString pistaN1;
  final LocalizedString pistaN2;
  final LocalizedString retoTangible;
  final LocalizedString sintesisCierre;

  const SteamCiclo({
    required this.planteamiento,
    required this.preguntaIndagacion,
    required this.pausaSilencioSegundos,
    required this.consignaAdulto,
    required this.pistaN1,
    required this.pistaN2,
    required this.retoTangible,
    required this.sintesisCierre,
  });

  factory SteamCiclo.fromJson(Map<String, dynamic> json) {
    final observa = _mapa(json['observa']);
    final experimenta = _mapa(json['experimenta']);
    final construye = _mapa(json['construye']);
    return SteamCiclo(
      planteamiento: _texto(observa['planteamiento']),
      preguntaIndagacion: _texto(observa['preguntaIndagacion']),
      pausaSilencioSegundos:
          (observa['pausaSilencioSegundos'] as num?)?.toInt() ?? 5,
      consignaAdulto: _texto(experimenta['consignaAdulto']),
      pistaN1: _texto(experimenta['pistaN1']),
      pistaN2: _texto(experimenta['pistaN2']),
      retoTangible: _texto(construye['retoTangible']),
      sintesisCierre: _texto(construye['sintesisCierre']),
    );
  }

  Map<String, dynamic> toJson() => {
        'observa': {
          'planteamiento': planteamiento.toJson(),
          'preguntaIndagacion': preguntaIndagacion.toJson(),
          'pausaSilencioSegundos': pausaSilencioSegundos,
        },
        'experimenta': {
          'consignaAdulto': consignaAdulto.toJson(),
          'pistaN1': pistaN1.toJson(),
          'pistaN2': pistaN2.toJson(),
        },
        'construye': {
          'retoTangible': retoTangible.toJson(),
          'sintesisCierre': sintesisCierre.toJson(),
        },
      };

  /// Toda la prosa del ciclo, en el orden en que se lee. Es lo que lleva
  /// altavoz, y lo mismo que recoge `tools/voice_corpus.py`.
  List<LocalizedString> get prosa => [
        planteamiento,
        preguntaIndagacion,
        consignaAdulto,
        pistaN1,
        pistaN2,
        retoTangible,
        sintesisCierre,
      ];
}

/// Una de las dos versiones de la unidad: la del aula o la de casa.
@immutable
class SteamVariante {
  final LocalizedString agrupamiento;
  final List<SteamRol> roles;
  final List<SteamMaterial> materiales;
  final SteamCiclo ciclo;

  const SteamVariante({
    required this.agrupamiento,
    required this.roles,
    required this.materiales,
    required this.ciclo,
  });

  factory SteamVariante.fromJson(Map<String, dynamic> json) => SteamVariante(
        agrupamiento: _texto(json['agrupamiento']),
        roles: _lista(json['roles'])
            .map(SteamRol.fromJson)
            .toList(growable: false),
        materiales: _lista(json['materiales'])
            .map(SteamMaterial.fromJson)
            .toList(growable: false),
        ciclo: SteamCiclo.fromJson(_mapa(json['ciclo'])),
      );

  Map<String, dynamic> toJson() => {
        'agrupamiento': agrupamiento.toJson(),
        'roles': roles.map((r) => r.toJson()).toList(),
        'materiales': materiales.map((m) => m.toJson()).toList(),
        'ciclo': ciclo.toJson(),
      };
}

/// Una orden en inglés para responder con el cuerpo (TPR).
///
/// No lleva ruta de audio: la grabación la deriva `BotonEscuchar` del propio
/// texto, igual que en el resto de la app. Así no puede enseñar una orden y
/// sonar otra.
@immutable
class SteamOrdenIngles {
  final String en;

  /// Transcripción fonética de la voz inglesa de la app (inglés americano).
  /// Solo en las órdenes de una palabra; vacía en las frases.
  final String ipa;
  final LocalizedString accion;

  const SteamOrdenIngles({
    required this.en,
    required this.ipa,
    required this.accion,
  });

  factory SteamOrdenIngles.fromJson(Map<String, dynamic> json) =>
      SteamOrdenIngles(
        en: json['en']?.toString().trim() ?? '',
        ipa: json['ipa']?.toString().trim() ?? '',
        accion: _texto(json['accion']),
      );

  Map<String, dynamic> toJson() => {
        'en': en,
        'ipa': ipa,
        'accion': accion.toJson(),
      };
}

/// El anclaje curricular de la unidad en el Decreto 150/2022.
@immutable
class SteamCurriculo {
  final String normativa;
  final String etapa;
  final String ciclo;
  final String nivel;
  final List<String> areas;
  final List<String> competenciasClave;
  final List<String> criteriosEvaluacion;

  const SteamCurriculo({
    required this.normativa,
    required this.etapa,
    required this.ciclo,
    required this.nivel,
    required this.areas,
    required this.competenciasClave,
    required this.criteriosEvaluacion,
  });

  factory SteamCurriculo.fromJson(Map<String, dynamic> json) => SteamCurriculo(
        normativa: json['normativa']?.toString() ?? '',
        etapa: json['etapa']?.toString() ?? '',
        ciclo: json['ciclo']?.toString() ?? '',
        nivel: json['nivel']?.toString() ?? '',
        areas: _cadenas(json['areas']),
        competenciasClave: _cadenas(json['competenciasClave']),
        criteriosEvaluacion: _cadenas(json['criteriosEvaluacion']),
      );

  Map<String, dynamic> toJson() => {
        'normativa': normativa,
        'etapa': etapa,
        'ciclo': ciclo,
        if (nivel.isNotEmpty) 'nivel': nivel,
        'areas': areas,
        if (competenciasClave.isNotEmpty)
          'competenciasClave': competenciasClave,
        'criteriosEvaluacion': criteriosEvaluacion,
      };
}

/// Una unidad STEAM: un fenómeno, una edad y dos versiones de la sesión.
@immutable
class SteamUnit {
  final String id;

  /// El curso, con la misma clave que el resto de la app (`curso_0_2` …
  /// `curso_5_6`). Es lo que casa la unidad con el curso de «Hoxe na aula» y
  /// con el filtro de edad del Portal Familias.
  final String estadio;
  final String nivelMadurativo;
  final LocalizedString rangoEdad;
  final LocalizedString titulo;
  final LocalizedString fenomeno;
  final int tiempoEstimadoMin;
  final SteamCurriculo curriculo;
  final LocalizedString avisoSeguridad;
  final List<SteamOrdenIngles> ordenesIngles;

  /// Qué mirar mientras juegan. No es una evaluación ni se registra: la app no
  /// guarda nada de ninguna criatura.
  final List<LocalizedString> queObservar;
  final SteamVariante aula;
  final SteamVariante hogar;

  const SteamUnit({
    required this.id,
    required this.estadio,
    required this.nivelMadurativo,
    required this.rangoEdad,
    required this.titulo,
    required this.fenomeno,
    required this.tiempoEstimadoMin,
    required this.curriculo,
    required this.avisoSeguridad,
    required this.ordenesIngles,
    required this.queObservar,
    required this.aula,
    required this.hogar,
  });

  factory SteamUnit.fromJson(Map<String, dynamic> json) => SteamUnit(
        id: json['id']?.toString() ?? '',
        estadio: json['estadio']?.toString() ?? '',
        nivelMadurativo: json['nivelMadurativo']?.toString() ?? '',
        rangoEdad: _texto(json['rangoEdad']),
        titulo: _texto(json['titulo']),
        fenomeno: _texto(json['fenomeno']),
        tiempoEstimadoMin: (json['tiempoEstimadoMin'] as num?)?.toInt() ?? 0,
        curriculo: SteamCurriculo.fromJson(_mapa(json['curriculo'])),
        avisoSeguridad: _texto(_mapa(json['seguridad'])['aviso']),
        ordenesIngles: _lista(json['ordenesIngles'])
            .map(SteamOrdenIngles.fromJson)
            .toList(growable: false),
        queObservar: (json['queObservar'] is List
                ? (json['queObservar'] as List).map(_texto)
                : const Iterable<LocalizedString>.empty())
            .toList(growable: false),
        aula: SteamVariante.fromJson(_mapa(json['aula'])),
        hogar: SteamVariante.fromJson(_mapa(json['hogar'])),
      );

  SteamVariante variante(SteamAudiencia audiencia) =>
      audiencia == SteamAudiencia.aula ? aula : hogar;

  Map<String, dynamic> toJson() => {
        'id': id,
        'estadio': estadio,
        'nivelMadurativo': nivelMadurativo,
        'rangoEdad': rangoEdad.toJson(),
        'titulo': titulo.toJson(),
        'fenomeno': fenomeno.toJson(),
        'tiempoEstimadoMin': tiempoEstimadoMin,
        'curriculo': curriculo.toJson(),
        'seguridad': {'aviso': avisoSeguridad.toJson()},
        'ordenesIngles': ordenesIngles.map((o) => o.toJson()).toList(),
        'queObservar': queObservar.map((q) => q.toJson()).toList(),
        'aula': aula.toJson(),
        'hogar': hogar.toJson(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is SteamUnit && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
