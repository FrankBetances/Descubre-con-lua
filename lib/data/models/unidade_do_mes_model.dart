import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';
import 'hogar_model.dart';
import 'microcuento_model.dart';

/// La unidad de un mes de un curso: la única fuente de lo que se enseña ese
/// mes (`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartado 3). Asamblea, cuento,
/// juego y casa leen de aquí, y no guardan contenido propio.
///
/// No es la [Unidad] de `unidad_model.dart`: esa es una de las diez unidades
/// de la asamblea vieja de seis pasos, que se retira.
///
/// Todo lo inglés se CITA por id (del banco TPR o del registro de frases), no
/// se copia: así una palabra no puede decir una cosa en la unidad y otra en
/// el banco. Lo comprueba `tools/check_unidades.py`.
@immutable
class UnidadeDoMes {
  final String id;
  final String curso;

  /// El mes del curso, de 1 (septiembre) a 10 (junio).
  final int orden;
  final int mesCalendario;

  /// El id de la asamblea del mes, que es la que marca el centro de interés.
  final String asamblea;
  final LocalizedString centroInteres;

  /// La canción del mes, la de la asamblea. Nula si la asamblea no trae.
  final String? cancion;

  /// Lo que se queda todo el mes: de 3 a 5 unidades léxicas según la edad.
  final List<RefNucleo> nucleo;

  /// Solo desde 4-5 años: tres palabras descriptivas.
  final List<String> descriptivas;

  /// Solo desde 3-4 años: dos fórmulas de turno o de cortesía.
  final List<String> formulas;

  /// Solo desde 4-5 años: una estructura del mes.
  final EstructuraDoMes? estructura;
  final List<OrdeDaUnidade> ordenes;
  final List<LocalizedString> realia;

  /// Un contraste de sonido para el oído de la adulta, si la voz lo produce.
  final ContrasteDeSon? contraste;
  final List<LocalizedString> queObservar;

  /// Lo que vuelve del núcleo del mes anterior.
  final List<String> reactivar;

  /// El cuento dialógico de la unidad, desde 2-3 años. Nulo en 0-2.
  final Microcuento? microcuento;

  /// La guía de casa del mes (F5): cuatro retos, lectura, juego y qué mirar.
  final HogarDaUnidade? hogar;

  const UnidadeDoMes({
    required this.id,
    required this.curso,
    required this.orden,
    required this.mesCalendario,
    required this.asamblea,
    required this.centroInteres,
    this.cancion,
    required this.nucleo,
    this.descriptivas = const [],
    this.formulas = const [],
    this.estructura,
    required this.ordenes,
    required this.realia,
    this.contraste,
    required this.queObservar,
    this.reactivar = const [],
    this.microcuento,
    this.hogar,
  });

  factory UnidadeDoMes.fromJson(Map<String, dynamic> json) {
    List<String> refs(Object? lista) => [
          for (final e in (lista as List? ?? const []))
            if (e is Map && e['ref'] != null) e['ref'].toString(),
        ];
    final estructura = json['estructura'];
    final contraste = json['contraste'];
    final microcuento = json['microcuento'];
    final hogar = json['hogar'];
    return UnidadeDoMes(
      id: json['id'] as String? ?? '',
      curso: json['curso'] as String? ?? '',
      orden: (json['orden'] as num?)?.toInt() ?? 0,
      mesCalendario: (json['mesCalendario'] as num?)?.toInt() ?? 0,
      asamblea: json['asamblea'] as String? ?? '',
      centroInteres: _texto(json['centroInteres']),
      cancion: (json['cancion'] as Map?)?['titulo'] as String?,
      nucleo: [
        for (final e in (json['nucleo'] as List? ?? const []))
          if (e is Map) RefNucleo.fromJson(Map<String, dynamic>.from(e)),
      ],
      descriptivas: refs(json['descriptivas']),
      formulas: refs(json['formulas']),
      estructura: estructura is Map
          ? EstructuraDoMes.fromJson(Map<String, dynamic>.from(estructura))
          : null,
      ordenes: [
        for (final e in (json['ordenes'] as List? ?? const []))
          if (e is Map) OrdeDaUnidade.fromJson(Map<String, dynamic>.from(e)),
      ],
      realia: [
        for (final e in (json['realia'] as List? ?? const [])) _texto(e),
      ],
      contraste: contraste is Map
          ? ContrasteDeSon.fromJson(Map<String, dynamic>.from(contraste))
          : null,
      queObservar: [
        for (final e in (json['queObservar'] as List? ?? const [])) _texto(e),
      ],
      reactivar: [
        for (final e in (json['reactivar'] as List? ?? const [])) e.toString(),
      ],
      microcuento: microcuento is Map
          ? Microcuento.fromJson(Map<String, dynamic>.from(microcuento))
          : null,
      hogar: hogar is Map
          ? HogarDaUnidade.fromJson(Map<String, dynamic>.from(hogar))
          : null,
    );
  }

  /// Todos los ids que la unidad enseña: núcleo, descriptivas, fórmulas y
  /// estructura. Una orden solo puede usar estos.
  Set<String> get ensina => {
        for (final n in nucleo) n.ref,
        ...descriptivas,
        ...formulas,
        if (estructura != null) estructura!.ref,
      };
}

/// Una pieza del núcleo: el id y, si lo hay, el objeto real que la acompaña.
@immutable
class RefNucleo {
  final String ref;
  final LocalizedString? objeto;

  const RefNucleo({required this.ref, this.objeto});

  factory RefNucleo.fromJson(Map<String, dynamic> json) => RefNucleo(
        ref: json['ref']?.toString() ?? '',
        objeto: json['objeto'] is Map ? _texto(json['objeto']) : null,
      );
}

@immutable
class EstructuraDoMes {
  final String ref;
  final LocalizedString nota;

  const EstructuraDoMes({required this.ref, required this.nota});

  factory EstructuraDoMes.fromJson(Map<String, dynamic> json) =>
      EstructuraDoMes(
        ref: json['ref']?.toString() ?? '',
        nota: _texto(json['nota']),
      );
}

/// Una orden TPR del mes y lo que usa de lo que la unidad enseña.
@immutable
class OrdeDaUnidade {
  final String ref;
  final List<String> usa;

  const OrdeDaUnidade({required this.ref, required this.usa});

  factory OrdeDaUnidade.fromJson(Map<String, dynamic> json) => OrdeDaUnidade(
        ref: json['ref']?.toString() ?? '',
        usa: [
          for (final e in (json['usa'] as List? ?? const [])) e.toString(),
        ],
      );
}

@immutable
class ContrasteDeSon {
  final String a;
  final String b;
  final LocalizedString nota;

  const ContrasteDeSon({required this.a, required this.b, required this.nota});

  factory ContrasteDeSon.fromJson(Map<String, dynamic> json) => ContrasteDeSon(
        a: json['a']?.toString() ?? '',
        b: json['b']?.toString() ?? '',
        nota: _texto(json['nota']),
      );
}

LocalizedString _texto(Object? valor) => LocalizedString.fromJson(
    Map<String, dynamic>.from(valor is Map ? valor : const {}));
