import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../core/localization/app_language.dart';

/// O-20261119-8: los juegos de escucha y palabras, copiados de Valeria y
/// adaptados. El contenido vive en assets/content/escoita/valeria_`lingua`.json
/// y lo genera tools/importar_valeria_escoita.py; aquí solo se lee.
class PezaEscoita {
  final String palabra;
  final String? lamina;
  final String frase;
  final String accion;
  const PezaEscoita({
    required this.palabra,
    this.lamina,
    this.frase = '',
    this.accion = '',
  });

  factory PezaEscoita.fromJson(Map<String, dynamic> j) => PezaEscoita(
        palabra: j['palabra'] as String,
        lamina: j['lamina'] as String?,
        frase: (j['frase'] as String?) ?? '',
        accion: (j['accion'] as String?) ?? '',
      );
}

/// Dos palabras que solo cambian en un sonido.
class ParEscoita {
  final String id;
  final PezaEscoita a;
  final PezaEscoita b;
  final String fonema;
  final String pista;
  final String misionAcerto;
  final String misionFallo;
  const ParEscoita({
    required this.id,
    required this.a,
    required this.b,
    required this.fonema,
    required this.pista,
    required this.misionAcerto,
    required this.misionFallo,
  });

  factory ParEscoita.fromJson(Map<String, dynamic> j) => ParEscoita(
        id: j['id'] as String,
        a: PezaEscoita.fromJson(j['a'] as Map<String, dynamic>),
        b: PezaEscoita.fromJson(j['b'] as Map<String, dynamic>),
        fonema: j['fonema'] as String,
        pista: j['pista'] as String,
        misionAcerto: j['misionAcerto'] as String,
        misionFallo: j['misionFallo'] as String,
      );
}

/// Un grupo de palabras con título: progresión, cápsula, escenario o categoría.
class GrupoEscoita {
  final String id;
  final String titulo;
  final String subtitulo;
  final List<PezaEscoita> pezas;
  const GrupoEscoita({
    required this.id,
    required this.titulo,
    this.subtitulo = '',
    required this.pezas,
  });
}

class BancoEscoita {
  final List<ParEscoita> pares;
  final List<GrupoEscoita> progresions;
  final List<GrupoEscoita> capsulas;
  final List<GrupoEscoita> escenarios;
  final List<GrupoEscoita> categorias;
  const BancoEscoita({
    required this.pares,
    required this.progresions,
    required this.capsulas,
    required this.escenarios,
    required this.categorias,
  });

  static String assetPath(AppLanguage lang) =>
      'assets/content/escoita/valeria_${lang.code}.json';

  factory BancoEscoita.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    List<GrupoEscoita> grupos(String clave, String campo,
            {String titulo = 'titulo', String sub = 'subtitulo'}) =>
        [
          for (final g in (j[clave] as List).cast<Map<String, dynamic>>())
            GrupoEscoita(
              id: g['id'] as String,
              titulo: (g[titulo] as String?) ??
                  (g['voltas'] as List?)
                      ?.map((v) => (v as Map)['palabra'])
                      .join(' · ') ??
                  '',
              subtitulo: (g[sub] as String?) ?? '',
              pezas: [
                for (final p in (g[campo] as List).cast<Map<String, dynamic>>())
                  PezaEscoita.fromJson(p),
              ],
            ),
        ];
    return BancoEscoita(
      pares: [
        for (final p in (j['pares'] as List).cast<Map<String, dynamic>>())
          ParEscoita.fromJson(p),
      ],
      progresions: grupos('progresions', 'fases', titulo: 'tema'),
      capsulas: grupos('capsulas', 'voltas', titulo: '_', sub: 'montaxe'),
      escenarios: grupos('escenarios', 'items'),
      categorias: grupos('categorias', 'items'),
    );
  }

  static final Map<AppLanguage, Future<BancoEscoita>> _cache = {};

  static Future<BancoEscoita> cargar(AppLanguage lang) => _cache[lang] ??=
      rootBundle.loadString(assetPath(lang)).then(BancoEscoita.fromRaw);

  @visibleForTesting
  static void sembrar(AppLanguage lang, BancoEscoita b) =>
      _cache[lang] = SynchronousFuture(b);
}
