import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';

/// Una frase inglesa del cuento con lo que quiere decir (doble toque, F7).
@immutable
class FraseDoConto {
  final String en;
  final LocalizedString? significado;
  final LocalizedString? axuda;

  const FraseDoConto(this.en, {this.significado, this.axuda});

  static FraseDoConto? fromJson(Object? v) {
    if (v is! Map || (v['en'] as String? ?? '').trim().isEmpty) return null;
    return FraseDoConto(
      (v['en'] as String).trim(),
      significado: ContoDialogado._ls(v),
      axuda: ContoDialogado._ls(v['axuda']),
    );
  }
}

/// Una lámina: el dibujo, la narración de la adulta, la frase de Lúa, la
/// tríada CROWD, la espera y los tres recast (plantilla del documento).
@immutable
class LaminaDoConto {
  final String papel;
  final LocalizedString dibujo;
  final LocalizedString narracion;
  final FraseDoConto? lua;
  final String? onomatopeia;
  final List<(String, FraseDoConto)> crowd;
  final LocalizedString? espera;
  final List<(String, FraseDoConto)> recast;

  const LaminaDoConto({
    required this.papel,
    required this.dibujo,
    required this.narracion,
    required this.lua,
    required this.onomatopeia,
    required this.crowd,
    required this.espera,
    required this.recast,
  });
}

/// Un cuento de la biblioteca HIS-001…HIS-100 (F12), de
/// `referencias/base/biblioteca-cuentos-dialogicos-bilingues.txt`, atado a
/// una unidad del plan curricular (F11).
@immutable
class ContoDialogado {
  final String id;
  final String cohorte;
  final String unidade;
  final LocalizedString titulo;
  final String tituloEn;
  final List<String> palabrasDiana;
  final FraseDoConto? fraseLua;
  final List<LaminaDoConto> laminas;

  const ContoDialogado({
    required this.id,
    required this.cohorte,
    required this.unidade,
    required this.titulo,
    required this.tituloEn,
    required this.palabrasDiana,
    required this.fraseLua,
    required this.laminas,
  });

  static LocalizedString? _ls(Object? v) {
    if (v is! Map) return null;
    final gl = (v['gl'] as String? ?? '').trim();
    final es = (v['es'] as String? ?? '').trim();
    return gl.isEmpty || es.isEmpty ? null : LocalizedString(gl: gl, es: es);
  }

  static List<(String, FraseDoConto)> _grupo(Object? v) => [
        if (v is Map)
          for (final e in v.entries)
            if (FraseDoConto.fromJson(e.value) case final f?)
              (e.key as String, f),
      ];

  factory ContoDialogado.fromJson(Map<String, dynamic> j) => ContoDialogado(
        id: j['id'] as String,
        cohorte: j['cohorte'] as String? ?? '',
        unidade: j['unidade'] as String? ?? '',
        titulo: _ls(j['titulo']) ?? LocalizedString(gl: j['id'], es: j['id']),
        tituloEn: ((j['titulo'] as Map?)?['en'] as String?) ?? '',
        palabrasDiana: [
          for (final p in (j['palabrasDiana'] as List? ?? const [])) '$p',
        ],
        fraseLua: FraseDoConto.fromJson(j['fraseLua']),
        laminas: [
          for (final l in (j['laminas'] as List? ?? const []).cast<Map>())
            LaminaDoConto(
              papel: l['papel'] as String? ?? '',
              dibujo: _ls(l['dibujo']) ?? const LocalizedString(gl: '', es: ''),
              narracion:
                  _ls(l['narracion']) ?? const LocalizedString(gl: '', es: ''),
              lua: FraseDoConto.fromJson(l['lua']),
              onomatopeia: l['onomatopeia'] as String?,
              crowd: _grupo(l['crowd']),
              espera: _ls(l['espera']),
              recast: _grupo(l['recast']),
            ),
        ],
      );
}

/// Los 100 cuentos, leídos una vez.
@immutable
class BibliotecaDialogada {
  final List<ContoDialogado> contos;

  const BibliotecaDialogada(this.contos);

  static const ficheiros = [
    'assets/content/biblioteca/his_a.json',
    'assets/content/biblioteca/his_b.json',
    'assets/content/biblioteca/his_c.json',
    'assets/content/biblioteca/his_d.json',
  ];

  factory BibliotecaDialogada.fromRaw(List<String> raws) {
    final todos = [
      for (final r in raws)
        for (final c in (jsonDecode(r) as List).cast<Map>())
          ContoDialogado.fromJson(Map<String, dynamic>.from(c)),
    ]..sort((a, b) => a.id.compareTo(b.id));
    return BibliotecaDialogada(List.unmodifiable(todos));
  }

  List<ContoDialogado> daUnidade(String unidade) => [
        for (final c in contos)
          if (c.unidade == unidade) c
      ];

  static Future<BibliotecaDialogada>? _enCurso;

  static Future<BibliotecaDialogada> cargar() => _enCurso ??= Future.wait([
        for (final f in ficheiros) rootBundle.loadString(f),
      ]).then(BibliotecaDialogada.fromRaw);

  @visibleForTesting
  static void sembrar(BibliotecaDialogada b) => _enCurso = SynchronousFuture(b);
}
