import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import '../loaders/content_asset_loader.dart';

/// Lo que dice la adulta en inglés en una situación del aula o de casa.
@immutable
class ExemploDoModelo {
  final LocalizedString situacion;

  /// En inglés, tal cual se dice. Lleva voz (`tools/voice_corpus.py`).
  final String adulta;

  const ExemploDoModelo({required this.situacion, required this.adulta});
}

/// Un tramo de edad: qué cabe esperar, qué no y qué hace la adulta.
@immutable
class TramoDoModelo {
  final String clave;
  final LocalizedString nome;
  final List<LocalizedString> cabeEsperar;
  final List<LocalizedString> nonCabeEsperar;
  final List<LocalizedString> aAdultaFai;

  const TramoDoModelo({
    required this.clave,
    required this.nome,
    required this.cabeEsperar,
    required this.nonCabeEsperar,
    required this.aAdultaFai,
  });
}

@immutable
class SeccionDoModelo {
  final String clave;
  final LocalizedString titulo;
  final LocalizedString que;
  final LocalizedString porque;
  final List<LocalizedString> como;
  final ExemploDoModelo? exemploAula;
  final ExemploDoModelo? exemploCasa;
  final LocalizedString erro;

  /// Autor y año tal como los da el documento de base. Nulo si no cita.
  final LocalizedString? fonte;
  final List<TramoDoModelo> tramos;

  const SeccionDoModelo({
    required this.clave,
    required this.titulo,
    required this.que,
    required this.porque,
    required this.como,
    required this.exemploAula,
    required this.exemploCasa,
    required this.erro,
    required this.fonte,
    required this.tramos,
  });
}

/// «El modelo: cómo se habla» (F2). Vive en `assets/content/modelo/`, no en
/// la pantalla, y es el mismo para el aula y para casa: solo cambia el
/// ejemplo.
@immutable
class OModelo {
  final LocalizedString intro;
  final List<SeccionDoModelo> seccions;

  const OModelo({required this.intro, required this.seccions});

  static const String assetPath = 'assets/content/modelo/o_modelo.json';

  factory OModelo.fromRaw(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map) throw const FormatException('o_modelo: non é un obxecto');

    LocalizedString texto(Object? v, String onde) {
      if (v is! Map ||
          (v['gl'] as String? ?? '').trim().isEmpty ||
          (v['es'] as String? ?? '').trim().isEmpty) {
        throw FormatException('o_modelo: $onde sen galego e castelán');
      }
      return LocalizedString.fromJson(Map<String, dynamic>.from(v));
    }

    List<LocalizedString> lista(Object? v, String onde) => [
          for (final (i, x) in ((v as List?) ?? const []).indexed)
            texto(x, '$onde ${i + 1}'),
        ];

    ExemploDoModelo? exemplo(Object? v, String onde) {
      if (v == null) return null;
      if (v is! Map || (v['adulta'] as String? ?? '').trim().isEmpty) {
        throw FormatException('o_modelo: $onde sen frase da adulta');
      }
      return ExemploDoModelo(
        situacion: texto(v['situacion'], '$onde (situación)'),
        adulta: (v['adulta'] as String).trim(),
      );
    }

    final seccions = json['seccions'];
    if (seccions is! List || seccions.isEmpty) {
      throw const FormatException('o_modelo: faltan «seccions»');
    }
    return OModelo(
      intro: texto(json['intro'], 'a intro'),
      seccions: List.unmodifiable([
        for (final s in seccions.cast<Map>())
          () {
            final c = s['clave'] as String;
            final fonte = s['fonte'];
            final conFonte = fonte is Map &&
                (fonte['gl'] as String? ?? '').trim().isNotEmpty;
            return SeccionDoModelo(
              clave: c,
              titulo: texto(s['titulo'], '$c: título'),
              que: texto(s['que'], '$c: que'),
              porque: texto(s['porque'], '$c: porque'),
              como: lista(s['como'], '$c: como'),
              exemploAula: exemplo(s['exemploAula'], '$c: exemplo de aula'),
              exemploCasa: exemplo(s['exemploCasa'], '$c: exemplo de casa'),
              erro: texto(s['erro'], '$c: erro'),
              fonte: conFonte ? texto(fonte, '$c: fonte') : null,
              tramos: List.unmodifiable([
                for (final t
                    in ((s['tramos'] as List?) ?? const []).cast<Map>())
                  TramoDoModelo(
                    clave: t['clave'] as String,
                    nome: texto(t['nome'], '$c: tramo'),
                    cabeEsperar: lista(t['cabeEsperar'], '$c: cabe esperar'),
                    nonCabeEsperar:
                        lista(t['nonCabeEsperar'], '$c: non cabe esperar'),
                    aAdultaFai: lista(t['aAdultaFai'], '$c: a adulta fai'),
                  ),
              ]),
            );
          }(),
      ]),
    );
  }

  static Future<OModelo>? _enCurso;

  /// Unha soa carga por execución: o contido non cambia mentres a app vive.
  static Future<OModelo> cargar({AssetBundleStringLoader? stringLoader}) {
    if (stringLoader != null) {
      return stringLoader(assetPath).then(OModelo.fromRaw);
    }
    return _enCurso ??= rootBundle.loadString(assetPath).then(OModelo.fromRaw);
  }

  /// Solo para los tests: olvida lo cargado.
  @visibleForTesting
  static void olvidar() => _enCurso = null;

  /// Solo para los tests: deja el modelo ya leído, sin pasar por el bundle.
  @visibleForTesting
  static void sembrar(OModelo m) => _enCurso = SynchronousFuture(m);
}
