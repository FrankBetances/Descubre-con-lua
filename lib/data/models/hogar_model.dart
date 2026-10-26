import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import '../loaders/content_asset_loader.dart';

LocalizedString _t(Object? v) => LocalizedString.fromJson(
    Map<String, dynamic>.from(v is Map ? v : const {}));

/// Una frase inglesa con lo que quiere decir, si lo trae.
@immutable
class FraseDoReto {
  final String en;
  final LocalizedString? significado;

  const FraseDoReto({required this.en, this.significado});

  factory FraseDoReto.fromJson(Map<String, dynamic> j) {
    final s = _t(j);
    return FraseDoReto(
      en: j['en']?.toString() ?? '',
      significado: s.hasParity ? s : null,
    );
  }
}

/// Un reto de casa de una semana (F5, apartado 8.3 de la arquitectura).
@immutable
class RetoDeCasa {
  final String id;
  final int semana;
  final LocalizedString nomeFase;
  final FraseDoReto frase;
  final LocalizedString queFacer;
  final LocalizedString mans;
  final int esperaSegundos;
  final LocalizedString nonPedir;

  /// Qué hacer ante el silencio, la lengua de casa y una palabra suelta.
  final LocalizedString recastSilencio;
  final LocalizedString recastLinguaCasa;
  final LocalizedString recastUnhaPalabra;

  const RetoDeCasa({
    required this.id,
    required this.semana,
    required this.nomeFase,
    required this.frase,
    required this.queFacer,
    required this.mans,
    required this.esperaSegundos,
    required this.nonPedir,
    required this.recastSilencio,
    required this.recastLinguaCasa,
    required this.recastUnhaPalabra,
  });

  factory RetoDeCasa.fromJson(Map<String, dynamic> j) {
    final r = Map<String, dynamic>.from(j['recast'] as Map? ?? const {});
    return RetoDeCasa(
      id: j['id']?.toString() ?? '',
      semana: (j['semana'] as num?)?.toInt() ?? 1,
      nomeFase: _t(j['nomeFase']),
      frase: FraseDoReto.fromJson(
          Map<String, dynamic>.from(j['frase'] as Map? ?? const {})),
      queFacer: _t(j['queFacer']),
      mans: _t(j['mans']),
      esperaSegundos: (j['esperaSegundos'] as num?)?.toInt() ?? 5,
      nonPedir: _t(j['nonPedir']),
      recastSilencio: _t(r['silencio']),
      recastLinguaCasa: _t(r['linguaCasa']),
      recastUnhaPalabra: _t(r['unhaPalabra']),
    );
  }
}

/// La guía de casa de un mes: lo que la familia hace con la unidad.
@immutable
class HogarDaUnidade {
  final LocalizedString momento;
  final int minutos;
  final LocalizedString escena;
  final List<RetoDeCasa> retos;

  /// El id del microcuento que se lee en casa, si la unidad lo tiene.
  final String? microcuento;

  /// El juego del mes: de `xogos_fogar.json` o, si ninguno casa, del STEAM.
  final String? xogo;
  final String? steam;
  final List<LocalizedString> queObservar;
  final FraseDoReto? reactivar;
  final LocalizedString? reactivarTexto;

  const HogarDaUnidade({
    required this.momento,
    required this.minutos,
    required this.escena,
    required this.retos,
    this.microcuento,
    this.xogo,
    this.steam,
    this.queObservar = const [],
    this.reactivar,
    this.reactivarTexto,
  });

  /// El reto de la semana N del mes (1 a 4; la 5.ª, si la hay, es la 4.ª).
  RetoDeCasa? daSemana(int semana) {
    if (retos.isEmpty) return null;
    final s = semana.clamp(1, retos.length);
    return retos.firstWhere((r) => r.semana == s, orElse: () => retos.first);
  }

  factory HogarDaUnidade.fromJson(Map<String, dynamic> j) {
    final xogo = Map<String, dynamic>.from(j['juegoCasa'] as Map? ?? const {});
    final reac = j['reactivarCasa'];
    return HogarDaUnidade(
      momento: _t(j['momento']),
      minutos: (j['minutos'] as num?)?.toInt() ?? 5,
      escena: _t(j['escena']),
      retos: [
        for (final r in (j['retosCasa'] as List? ?? const []))
          if (r is Map) RetoDeCasa.fromJson(Map<String, dynamic>.from(r)),
      ],
      microcuento: (j['lecturaCasa'] as Map?)?['microcuento']?.toString(),
      xogo: xogo['xogo']?.toString(),
      steam: xogo['steam']?.toString(),
      queObservar: [
        for (final o in (j['queObservarCasa'] as List? ?? const [])) _t(o),
      ],
      reactivar: reac is Map && reac['en'] != null
          ? FraseDoReto(en: reac['en'].toString())
          : null,
      reactivarTexto: reac is Map ? _t(reac['texto']) : null,
    );
  }
}

/// Un punto de la guía estable de casa (apartado 8.1).
@immutable
class PuntoDaGuia {
  final String clave;
  final LocalizedString titulo;
  final LocalizedString texto;

  /// Solo en «as catro ferramentas»: herramienta, situación y frase inglesa.
  final List<(LocalizedString, LocalizedString, String)> exemplos;

  const PuntoDaGuia({
    required this.clave,
    required this.titulo,
    required this.texto,
    this.exemplos = const [],
  });
}

/// Una fila de la guía por edad (apartado 8.2).
@immutable
class TramoDeCasa {
  final String clave;
  final String curso;
  final LocalizedString idade;
  final String minutos;
  final LocalizedString ferramenta;
  final LocalizedString quePedir;
  final LocalizedString lectura;
  final LocalizedString momento;
  final LocalizedString queFacer;
  final LocalizedString queEvitar;
  final String exemploEn;
  final LocalizedString exemploSituacion;

  const TramoDeCasa({
    required this.clave,
    required this.curso,
    required this.idade,
    required this.minutos,
    required this.ferramenta,
    required this.quePedir,
    required this.lectura,
    required this.momento,
    required this.queFacer,
    required this.queEvitar,
    required this.exemploEn,
    required this.exemploSituacion,
  });
}

/// La guía estable y la guía por edad de casa, de `assets/content/hogar/`.
@immutable
class GuiaDeCasa {
  final LocalizedString intro;
  final List<PuntoDaGuia> puntos;
  final List<TramoDeCasa> tramos;

  const GuiaDeCasa({
    required this.intro,
    required this.puntos,
    required this.tramos,
  });

  static const guiaAsset = 'assets/content/hogar/guia_hogar.json';
  static const idadeAsset = 'assets/content/hogar/hogar_por_edad.json';

  List<TramoDeCasa> doCurso(String curso) => [
        for (final t in tramos)
          if (t.curso == curso) t
      ];

  factory GuiaDeCasa.fromRaw(String guia, String idade) {
    final g = jsonDecode(guia) as Map<String, dynamic>;
    final e = jsonDecode(idade) as Map<String, dynamic>;
    return GuiaDeCasa(
      intro: _t(g['intro']),
      puntos: [
        for (final p in (g['puntos'] as List? ?? const []))
          if (p is Map)
            PuntoDaGuia(
              clave: p['clave']?.toString() ?? '',
              titulo: _t(p['titulo']),
              texto: _t(p['texto']),
              exemplos: [
                for (final x in (p['exemplos'] as List? ?? const []))
                  if (x is Map)
                    (
                      _t(x['ferramenta']),
                      _t(x['situacion']),
                      x['en']?.toString() ?? ''
                    ),
              ],
            ),
      ],
      tramos: [
        for (final t in (e['tramos'] as List? ?? const []))
          if (t is Map)
            TramoDeCasa(
              clave: t['clave']?.toString() ?? '',
              curso: t['curso']?.toString() ?? '',
              idade: _t(t['idade']),
              minutos: t['minutos']?.toString() ?? '',
              ferramenta: _t(t['ferramenta']),
              quePedir: _t(t['quePedir']),
              lectura: _t(t['lectura']),
              momento: _t(t['momento']),
              queFacer: _t(t['queFacer']),
              queEvitar: _t(t['queEvitar']),
              exemploEn: (t['exemplo'] as Map?)?['en']?.toString() ?? '',
              exemploSituacion: _t((t['exemplo'] as Map?)?['situacion']),
            ),
      ],
    );
  }

  static Future<GuiaDeCasa>? _enCurso;

  /// Una sola carga por ejecución.
  static Future<GuiaDeCasa> cargar({AssetBundleStringLoader? stringLoader}) {
    Future<GuiaDeCasa> ler(Future<String> Function(String) l) =>
        Future.wait([l(guiaAsset), l(idadeAsset)])
            .then((r) => GuiaDeCasa.fromRaw(r[0], r[1]));
    if (stringLoader != null) return ler(stringLoader);
    return _enCurso ??= ler(rootBundle.loadString);
  }

  /// Solo para los tests: deja la guía ya leída, sin pasar por el bundle.
  @visibleForTesting
  static void sembrar(GuiaDeCasa g) => _enCurso = SynchronousFuture(g);
}
