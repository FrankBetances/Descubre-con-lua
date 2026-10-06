import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/localization/localized_string.dart';
import 'asamblea_segundo_ciclo_model.dart' show FaseAsamblea, TipoFaseAsamblea;
import 'tpr_curriculum_scheduler.dart';

/// Unha palabra que unha orde da asemblea dá por sabida: o curso TPR
/// ensinouna antes do mes desa asemblea.
@immutable
class PalabraDadaPorSabida {
  final String id;

  /// O curso do traxecto en que se ensinou (`curso_3_4`…) e o seu mes.
  final String cursoId;
  final int mes;

  final String en;
  final String gl;
  final String es;
  final LocalizedString xesto;

  const PalabraDadaPorSabida({
    required this.id,
    required this.cursoId,
    required this.mes,
    required this.en,
    required this.gl,
    required this.es,
    required this.xesto,
  });

  /// A mesma palabra coma as do curso, para pintala coas pezas que xa a
  /// pintan co seu xesto e a súa voz.
  TprWord get comoPalabraTpr => TprWord(
        id: id,
        en: en,
        gl: gl,
        es: es,
        tprAction: xesto,
        category: '',
      );
}

/// Ponte ao día: o que cada orde da asemblea dá por sabido.
///
/// Vive en `assets/content/ponte_ao_dia.json`. As listas xéraas
/// `tools/xera_ponte_ao_dia.py` desde o curso TPR e as asembleas, coa revisión
/// a man escrita no mesmo ficheiro; o gate comproba que coinciden. Aquí só se
/// len: a app non decide que palabra se dá por sabida.
///
/// Non garda nada de ningunha crianza: é contido, igual para todo o mundo.
@immutable
class PonteAoDia {
  static const String assetPath = 'assets/content/ponte_ao_dia.json';

  /// As claves que a pantalla le de «textos». Se falta algunha, o ficheiro
  /// non vale: mellor o aviso de contido ilexible que un oco na pantalla.
  static const Map<String, List<String>> textosObrigatorios = {
    'reprodutor': [
      'titulo',
      'duracion',
      'consigna',
      'porque',
      'guia',
      'xesto',
      'anterior',
      'seguinte',
    ],
    'casa': [
      'titulo',
      'entrada',
      'intro',
      'naoSeGarda',
      'dia',
      'baleiro',
    ],
  };

  final Map<String, Map<String, LocalizedString>> _textos;
  final Map<String, PalabraDadaPorSabida> palabras;
  final Map<String, List<String>> _ordes;
  final Map<String, Map<int, List<String>>> _meses;

  const PonteAoDia._(this._textos, this.palabras, this._ordes, this._meses);

  /// Un texto da pantalla: `texto('reprodutor', 'titulo')`.
  LocalizedString texto(String grupo, String clave) => _textos[grupo]![clave]!;

  /// O que dá por sabido unha orde, na orde en que se di.
  List<PalabraDadaPorSabida> daOrde(String idOrde) => [
        for (final id in _ordes[idOrde] ?? const <String>[]) palabras[id]!,
      ];

  /// O que dan por sabido as ordes que se van dar hoxe: as da fase núcleo,
  /// xa co día aplicado. Sen repetir, na orde en que saen.
  List<PalabraDadaPorSabida> dasFases(List<FaseAsamblea> fases) {
    final saida = <PalabraDadaPorSabida>[];
    final vistos = <String>{};
    for (final fase in fases) {
      if (fase.tipo != TipoFaseAsamblea.coreTprChallenge) continue;
      for (final orde in fase.comandosL3) {
        for (final p in daOrde(orde.id)) {
          if (vistos.add(p.id)) saida.add(p);
        }
      }
    }
    return saida;
  }

  /// O que dan por sabido as asembleas dun mes nun curso (`curso_4_5`, 10).
  List<PalabraDadaPorSabida> doMes(String cursoId, int mes) => [
        for (final id in _meses[cursoId]?[mes] ?? const <String>[])
          palabras[id]!,
      ];

  factory PonteAoDia.fromRaw(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map) {
      throw const FormatException('ponte_ao_dia: non é un obxecto');
    }

    LocalizedString localizado(Object? valor, String onde) {
      if (valor is! Map ||
          (valor['gl'] as String? ?? '').trim().isEmpty ||
          (valor['es'] as String? ?? '').trim().isEmpty) {
        throw FormatException('ponte_ao_dia: $onde sen galego e castelán');
      }
      return LocalizedString.fromJson(Map<String, dynamic>.from(valor));
    }

    final textosJson = json['textos'];
    if (textosJson is! Map) {
      throw const FormatException('ponte_ao_dia: faltan «textos»');
    }
    final textos = <String, Map<String, LocalizedString>>{};
    textosObrigatorios.forEach((grupo, claves) {
      final g = textosJson[grupo];
      if (g is! Map) {
        throw FormatException('ponte_ao_dia: faltan os textos de «$grupo»');
      }
      textos[grupo] = {
        for (final clave in claves)
          clave: localizado(g[clave], 'textos.$grupo.$clave'),
      };
    });

    final palabrasJson = json['palabras'];
    if (palabrasJson is! Map) {
      throw const FormatException('ponte_ao_dia: faltan «palabras»');
    }
    final palabras = <String, PalabraDadaPorSabida>{};
    palabrasJson.forEach((id, valor) {
      if (valor is! Map) {
        throw FormatException('ponte_ao_dia: a palabra $id non é un obxecto');
      }
      palabras[id as String] = PalabraDadaPorSabida(
        id: id,
        cursoId: valor['curso'] as String,
        mes: valor['mes'] as int,
        en: valor['en'] as String,
        gl: valor['gl'] as String,
        es: valor['es'] as String,
        xesto: localizado(valor['xesto'], 'o xesto de $id'),
      );
    });

    List<String> lista(Object? valor, String onde) {
      if (valor is! List) {
        throw FormatException('ponte_ao_dia: $onde non é unha lista');
      }
      return List.unmodifiable([
        for (final id in valor)
          if (palabras.containsKey(id))
            id as String
          else
            throw FormatException('ponte_ao_dia: $onde nomea «$id», '
                'que non está en «palabras»'),
      ]);
    }

    final ordesJson = json['ordes'];
    final mesesJson = json['meses'];
    if (ordesJson is! Map || mesesJson is! Map) {
      throw const FormatException('ponte_ao_dia: faltan «ordes» ou «meses»');
    }
    final ordes = <String, List<String>>{
      for (final e in ordesJson.entries)
        e.key as String: lista(e.value, 'a orde ${e.key}'),
    };
    final meses = <String, Map<int, List<String>>>{};
    mesesJson.forEach((curso, porMes) {
      if (porMes is! Map) {
        throw FormatException('ponte_ao_dia: os meses de $curso');
      }
      meses[curso as String] = {
        for (final e in porMes.entries)
          int.parse(e.key as String): lista(e.value, '$curso, mes ${e.key}'),
      };
    });

    return PonteAoDia._(
      Map.unmodifiable(textos),
      Map.unmodifiable(palabras),
      Map.unmodifiable(ordes),
      Map.unmodifiable(meses),
    );
  }
}
