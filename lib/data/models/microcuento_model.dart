import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';

/// El microcuento de una unidad del mes: una conversación en inglés sobre el
/// núcleo, de 3 láminas (2-3 y 3-4 años) o 4 (4-5 y 5-6)
/// (`docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartados 5 y 7).
///
/// No es el cuento de la semana. Aquel es un baño de lenguaje con las veinte
/// palabras de la semana; este es corto, para hablar: la trama va en gallego o
/// castellano, y en cada lámina Lúa dice UNA frase en inglés hecha con el
/// núcleo. Lo que pide la adulta en el aula es la tríada (señalar, imitar,
/// acercar a su vida); lo que se lee en casa es una sola pregunta por lámina.
///
/// La frase de Lúa se CITA del registro de frases; no se copia aquí. La
/// tríada, el guion de recast y la pregunta de casa son habla de la adulta y
/// van escritos en la lámina. Lo comprueba `tools/check_microcuentos.py`.
@immutable
class Microcuento {
  final String id;
  final LocalizedString titulo;

  /// El primer tiempo de la espera (apartado 7): callar de 3 a 5 s.
  final int esperaSegundos;
  final List<LaminaMicrocuento> laminas;

  const Microcuento({
    required this.id,
    required this.titulo,
    this.esperaSegundos = 5,
    required this.laminas,
  });

  factory Microcuento.fromJson(Map<String, dynamic> json) => Microcuento(
        id: json['id']?.toString() ?? '',
        titulo: _texto(json['titulo']),
        esperaSegundos: (json['esperaSegundos'] as num?)?.toInt() ?? 5,
        laminas: [
          for (final e in (json['laminas'] as List? ?? const []))
            if (e is Map)
              LaminaMicrocuento.fromJson(Map<String, dynamic>.from(e)),
        ],
      );

  /// Sin lámina dibujada, el microcuento no entra en la app (apartado 5).
  bool get debuxado =>
      laminas.isNotEmpty &&
      laminas.every((l) => (l.lamina ?? '').trim().isNotEmpty);
}

@immutable
class LaminaMicrocuento {
  /// La clave de su dibujo en `assets/brand/laminas/`. Nula mientras no se
  /// haya dibujado.
  final String? lamina;

  /// Lo que se le pide a quien la dibuja: una acción, un contraste, sin fondo
  /// que compita. No se enseña en la app.
  final String encargo;

  /// La trama, en la lengua de la casa o de la escuela.
  final LocalizedString trama;

  /// El id de la frase de Lúa en el registro de frases.
  final String lua;

  /// La onomatopeya que acompaña a la frase de Lúa.
  final String onomatopeia;

  final PreguntaMicrocuento sinalar;
  final PreguntaMicrocuento imitar;
  final PreguntaMicrocuento achegar;
  final RecastsDaLamina recast;

  /// Lo que se lee en casa: una sola pregunta, del tipo que toca por edad.
  final PreguntaCasa casa;

  const LaminaMicrocuento({
    this.lamina,
    required this.encargo,
    required this.trama,
    required this.lua,
    required this.onomatopeia,
    required this.sinalar,
    required this.imitar,
    required this.achegar,
    required this.recast,
    required this.casa,
  });

  factory LaminaMicrocuento.fromJson(Map<String, dynamic> json) {
    final lua = json['lua'] is Map ? json['lua'] as Map : const {};
    final triada = json['triada'] is Map ? json['triada'] as Map : const {};
    PreguntaMicrocuento pregunta(String clave) =>
        PreguntaMicrocuento.fromJson(Map<String, dynamic>.from(
            triada[clave] is Map ? triada[clave] as Map : const {}));
    final lamina = json['lamina']?.toString();
    return LaminaMicrocuento(
      lamina: (lamina == null || lamina.trim().isEmpty) ? null : lamina,
      encargo: json['encargo']?.toString() ?? '',
      trama: _texto(json['trama']),
      lua: lua['ref']?.toString() ?? '',
      onomatopeia: lua['onomatopeia']?.toString() ?? '',
      sinalar: pregunta('sinalar'),
      imitar: pregunta('imitar'),
      achegar: pregunta('achegar'),
      recast: RecastsDaLamina.fromJson(Map<String, dynamic>.from(
          json['recast'] is Map ? json['recast'] as Map : const {})),
      casa: PreguntaCasa.fromJson(Map<String, dynamic>.from(
          json['casa'] is Map ? json['casa'] as Map : const {})),
    );
  }
}

/// Lo que dice la adulta en inglés y, en la lengua de la pantalla, qué hace
/// mientras lo dice.
@immutable
class PreguntaMicrocuento {
  final String en;
  final LocalizedString axuda;

  const PreguntaMicrocuento({required this.en, required this.axuda});

  factory PreguntaMicrocuento.fromJson(Map<String, dynamic> json) =>
      PreguntaMicrocuento(
        en: json['en']?.toString() ?? '',
        axuda: _texto(json['axuda']),
      );
}

/// El guion de recast para las cinco respuestas que pueden llegar
/// (apartado 5). Ninguna pide repetir: la adulta devuelve la frase bien dicha
/// dentro de la conversación.
@immutable
class RecastsDaLamina {
  /// No llega nada: la adulta modela la acción con el cuerpo.
  final PreguntaMicrocuento silencio;

  /// Señala sin hablar.
  final PreguntaMicrocuento sinala;

  /// Contesta en la lengua de casa: se acoge en esa lengua y se devuelve la
  /// idea en inglés.
  final RespostaEnLinguaDeCasa linguaCasa;

  /// Dice una palabra suelta: se devuelve dentro de una frase un poco más
  /// larga.
  final RespostaEnIngles unhaPalabra;

  /// Dice la forma torcida: se devuelve bien dicha, sin señalar el error.
  final RespostaEnIngles formaTorcida;

  const RecastsDaLamina({
    required this.silencio,
    required this.sinala,
    required this.linguaCasa,
    required this.unhaPalabra,
    required this.formaTorcida,
  });

  factory RecastsDaLamina.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> m(String k) =>
        Map<String, dynamic>.from(json[k] is Map ? json[k] as Map : const {});
    return RecastsDaLamina(
      silencio: PreguntaMicrocuento.fromJson(m('silencio')),
      sinala: PreguntaMicrocuento.fromJson(m('sinala')),
      linguaCasa: RespostaEnLinguaDeCasa.fromJson(m('linguaCasa')),
      unhaPalabra: RespostaEnIngles.fromJson(m('unhaPalabra')),
      formaTorcida: RespostaEnIngles.fromJson(m('formaTorcida')),
    );
  }
}

@immutable
class RespostaEnLinguaDeCasa {
  /// Lo que dice la criatura.
  final LocalizedString di;

  /// Cómo se acoge, en la misma lengua.
  final LocalizedString acolle;

  /// La idea devuelta en inglés.
  final String en;

  const RespostaEnLinguaDeCasa({
    required this.di,
    required this.acolle,
    required this.en,
  });

  factory RespostaEnLinguaDeCasa.fromJson(Map<String, dynamic> json) =>
      RespostaEnLinguaDeCasa(
        di: _texto(json['di']),
        acolle: _texto(json['acolle']),
        en: json['en']?.toString() ?? '',
      );
}

@immutable
class RespostaEnIngles {
  /// Lo que dice la criatura, en inglés.
  final String di;

  /// Lo que devuelve la adulta.
  final String en;

  const RespostaEnIngles({required this.di, required this.en});

  factory RespostaEnIngles.fromJson(Map<String, dynamic> json) =>
      RespostaEnIngles(
        di: json['di']?.toString() ?? '',
        en: json['en']?.toString() ?? '',
      );
}

/// Los tipos de pregunta de la lectura en casa (apartado 7): PEER en 2-3,
/// y del CROWD lo que toque por edad.
enum TipoPreguntaCasa {
  peer('peer'),
  completar('completar'),
  recordar('recordar'),
  abrir('abrir'),
  queOnde('queOnde'),
  achegar('achegar');

  final String clave;
  const TipoPreguntaCasa(this.clave);

  static TipoPreguntaCasa? deClave(String? clave) {
    for (final t in values) {
      if (t.clave == clave) return t;
    }
    return null;
  }
}

@immutable
class PreguntaCasa {
  final TipoPreguntaCasa? tipo;
  final String en;
  final LocalizedString axuda;

  const PreguntaCasa({this.tipo, required this.en, required this.axuda});

  factory PreguntaCasa.fromJson(Map<String, dynamic> json) => PreguntaCasa(
        tipo: TipoPreguntaCasa.deClave(json['tipo']?.toString()),
        en: json['en']?.toString() ?? '',
        axuda: _texto(json['axuda']),
      );
}

LocalizedString _texto(Object? valor) => LocalizedString.fromJson(
    Map<String, dynamic>.from(valor is Map ? valor : const {}));
