import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';

/// Una orden en inglés del experimento, con su significado para el doble
/// toque.
@immutable
class OrdeSteam {
  final String en;
  final LocalizedString significado;
  const OrdeSteam(this.en, this.significado);
}

/// El experimento STEAM de un mes y curso (F8), atado a la unidad del plan
/// curricular de ese mes.
@immutable
class ExperimentoSteam {
  final String id;
  final String curso;
  final int mes;
  final String unidade;
  final String fenomeno;
  final LocalizedString titulo;
  final List<LocalizedString> material;
  final LocalizedString seguridade;
  final List<LocalizedString> aula;
  final List<LocalizedString> casa;
  final List<OrdeSteam> ordes;
  final LocalizedString observar;

  const ExperimentoSteam({
    required this.id,
    required this.curso,
    required this.mes,
    required this.unidade,
    required this.fenomeno,
    required this.titulo,
    required this.material,
    required this.seguridade,
    required this.aula,
    required this.casa,
    required this.ordes,
    required this.observar,
  });

  static const nomesFenomeno = {
    'materia': LocalizedString(gl: 'Materia', es: 'Materia'),
    'acustica': LocalizedString(gl: 'Son', es: 'Sonido'),
    'cinematica': LocalizedString(gl: 'Movemento', es: 'Movimiento'),
    'optica': LocalizedString(gl: 'Luz', es: 'Luz'),
    'logica': LocalizedString(gl: 'Lóxica', es: 'Lógica'),
  };

  LocalizedString get nomeFenomeno =>
      nomesFenomeno[fenomeno] ?? LocalizedString(gl: fenomeno, es: fenomeno);
}

/// Los 50 experimentos, de `assets/content/steam/steam_do_mes.json`.
@immutable
class SteamDoMes {
  final List<ExperimentoSteam> experimentos;
  const SteamDoMes(this.experimentos);

  static const String assetPath = 'assets/content/steam/steam_do_mes.json';

  factory SteamDoMes.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    LocalizedString t(Object? v) =>
        LocalizedString.fromJson(Map<String, dynamic>.from(v as Map));
    List<LocalizedString> ts(Object? v) => [for (final x in v as List) t(x)];
    return SteamDoMes(List.unmodifiable([
      for (final e in (j['experimentos'] as List).cast<Map>())
        ExperimentoSteam(
          id: e['id'] as String,
          curso: e['curso'] as String,
          mes: e['mes'] as int,
          unidade: e['unidade'] as String,
          fenomeno: e['fenomeno'] as String,
          titulo: t(e['titulo']),
          material: ts(e['material']),
          seguridade: t(e['seguridade']),
          aula: ts(e['aula']),
          casa: ts(e['casa']),
          ordes: [
            for (final o in (e['ordes'] as List).cast<Map>())
              OrdeSteam(
                  o['en'] as String,
                  LocalizedString(
                      gl: o['gl'] as String, es: o['es'] as String)),
          ],
          observar: t(e['observar']),
        ),
    ]));
  }

  ExperimentoSteam? para(String curso, int mes) {
    for (final e in experimentos) {
      if (e.curso == curso && e.mes == mes) return e;
    }
    return null;
  }

  static Future<SteamDoMes>? _enCurso;

  static Future<SteamDoMes> cargar() =>
      _enCurso ??= rootBundle.loadString(assetPath).then(SteamDoMes.fromRaw);

  @visibleForTesting
  static void sembrar(SteamDoMes s) => _enCurso = SynchronousFuture(s);
}
