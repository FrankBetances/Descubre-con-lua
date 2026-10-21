import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';
import 'tpr_curriculum_scheduler.dart';
import 'unidade_do_mes_model.dart';

/// Una frase del registro: todo el inglés de la app que no es palabra del
/// banco TPR (`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartado 6).
@immutable
class FraseDoRexistro {
  final String id;

  /// `orde`, `formula`, `estructura`, `dinamica`, `xogo`, `steam`, `atencion`.
  final String tipo;
  final String en;
  final LocalizedString accion;

  /// Lo que quiere decir, en gl y es, para el doble toque (F7). Nulo si la
  /// fuente todavía no lo trae.
  final LocalizedString? significado;

  const FraseDoRexistro({
    required this.id,
    required this.tipo,
    required this.en,
    required this.accion,
    this.significado,
  });

  factory FraseDoRexistro.fromJson(Map<String, dynamic> json) =>
      FraseDoRexistro(
        id: json['id']?.toString() ?? '',
        tipo: json['tipo']?.toString() ?? '',
        en: json['en']?.toString() ?? '',
        accion: LocalizedString.fromJson(Map<String, dynamic>.from(
            json['accion'] is Map ? json['accion'] as Map : const {})),
        significado: json['significado'] is Map
            ? LocalizedString.fromJson(
                Map<String, dynamic>.from(json['significado'] as Map))
            : null,
      );
}

/// El registro de frases, leído de `assets/content/registro/frases.json`. Lo
/// genera `tools/xera_rexistro_frases.py`; no se edita a mano.
@immutable
class RexistroDeFrases {
  static const String asset = 'assets/content/registro/frases.json';

  final Map<String, FraseDoRexistro> _porId;

  RexistroDeFrases(Iterable<FraseDoRexistro> frases)
      : _porId = {for (final f in frases) f.id: f};

  factory RexistroDeFrases.fromJson(Map<String, dynamic> json) =>
      RexistroDeFrases([
        for (final e in (json['frases'] as List? ?? const []))
          if (e is Map) FraseDoRexistro.fromJson(Map<String, dynamic>.from(e)),
      ]);

  FraseDoRexistro? frase(String id) => _porId[id];

  int get length => _porId.length;
}

/// Una pieza de la unidad ya resuelta: lo que se dice en inglés, lo que se
/// hace con el cuerpo y, si lo hay, lo que quiere decir y el objeto real.
///
/// La unidad solo guarda el id; el inglés y el gesto salen del banco o del
/// registro, para que una palabra no diga una cosa en la unidad y otra donde
/// se enseña.
@immutable
class PezaDaUnidade {
  final String ref;
  final String en;

  /// Lo que quiere decir, para la persona adulta. Solo las palabras del banco
  /// lo traen; una orden del registro se entiende por su gesto.
  final LocalizedString? significado;
  final LocalizedString xesto;
  final LocalizedString? objeto;

  const PezaDaUnidade({
    required this.ref,
    required this.en,
    this.significado,
    required this.xesto,
    this.objeto,
  });
}

/// Resuelve [ref] en el banco del [programa] o en el [rexistro]. `null` si no
/// está en ninguno: `tools/check_unidades.py` no deja pasar una unidad así, de
/// modo que aquí solo ocurre si falló la lectura de uno de los dos.
PezaDaUnidade? resolverPeza(
  String ref, {
  required ProgramaTpr? programa,
  required RexistroDeFrases? rexistro,
  LocalizedString? objeto,
}) {
  final frase = rexistro?.frase(ref);
  if (frase != null) {
    return PezaDaUnidade(
        ref: ref,
        en: frase.en,
        significado: frase.significado,
        xesto: frase.accion,
        objeto: objeto);
  }
  final palabra = programa?.palabra(ref);
  if (palabra != null) {
    return PezaDaUnidade(
      ref: ref,
      en: palabra.en,
      significado: LocalizedString(gl: palabra.gl, es: palabra.es),
      xesto: palabra.tprAction,
      objeto: objeto,
    );
  }
  return null;
}

/// El núcleo de [unidade], resuelto pieza a pieza y en su orden. Lo que no se
/// pudo resolver se queda fuera en vez de pintarse vacío.
List<PezaDaUnidade> nucleoResolto(
  UnidadeDoMes unidade, {
  required ProgramaTpr? programa,
  required RexistroDeFrases? rexistro,
}) =>
    [
      for (final n in unidade.nucleo)
        if (resolverPeza(n.ref,
                programa: programa, rexistro: rexistro, objeto: n.objeto)
            case final peza?)
          peza,
    ];
