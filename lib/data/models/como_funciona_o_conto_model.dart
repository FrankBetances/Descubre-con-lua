import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import '../loaders/content_asset_loader.dart';

/// Cando sae un paso da explicación: só se o conto ten iso.
enum CandoPaso { sempre, conPalabras, conDia, senDia, conPregunta, conReto }

@immutable
class PasoDoConto {
  final CandoPaso cando;
  final LocalizedString texto;

  const PasoDoConto(this.cando, this.texto);
}

/// «Como funciona o conto»: a explicación breve para quen o abre por primeira
/// vez. Vive en `assets/content/cuentos/como_funciona.json`, non no visor.
@immutable
class ComoFuncionaOConto {
  final LocalizedString titulo;
  final LocalizedString ocultar;
  final List<PasoDoConto> pasos;

  const ComoFuncionaOConto({
    required this.titulo,
    required this.ocultar,
    required this.pasos,
  });

  static const String assetPath = 'assets/content/cuentos/como_funciona.json';

  /// Os pasos que tocan a este conto, na súa orde.
  List<LocalizedString> pasosPara({
    required bool conPalabras,
    required bool conDia,
    required bool conPregunta,
    required bool conReto,
  }) =>
      [
        for (final p in pasos)
          if (switch (p.cando) {
            CandoPaso.sempre => true,
            CandoPaso.conPalabras => conPalabras,
            CandoPaso.conDia => conPalabras && conDia,
            CandoPaso.senDia => conPalabras && !conDia,
            CandoPaso.conPregunta => conPregunta,
            CandoPaso.conReto => conReto,
          })
            p.texto,
      ];

  factory ComoFuncionaOConto.fromRaw(String raw) {
    final json = jsonDecode(raw);
    if (json is! Map) {
      throw const FormatException('como_funciona: non é un obxecto');
    }
    LocalizedString texto(Object? valor, String onde) {
      if (valor is! Map ||
          (valor['gl'] as String? ?? '').trim().isEmpty ||
          (valor['es'] as String? ?? '').trim().isEmpty) {
        throw FormatException('como_funciona: $onde sen galego e castelán');
      }
      return LocalizedString.fromJson(Map<String, dynamic>.from(valor));
    }

    final pasos = json['pasos'];
    if (pasos is! List || pasos.isEmpty) {
      throw const FormatException('como_funciona: faltan «pasos»');
    }
    return ComoFuncionaOConto(
      titulo: texto(json['titulo'], 'o título'),
      ocultar: texto(json['ocultar'], '«ocultar»'),
      pasos: List.unmodifiable([
        for (final (i, p) in pasos.indexed)
          PasoDoConto(
            CandoPaso.values.firstWhere(
              (c) => c.name == (p as Map)['cando'],
              orElse: () =>
                  throw FormatException('como_funciona: o paso ${i + 1} ten '
                      'un «cando» que non existe'),
            ),
            texto((p as Map)['texto'], 'o paso ${i + 1}'),
          ),
      ]),
    );
  }

  static Future<ComoFuncionaOConto>? _enCurso;

  /// Unha soa carga por execución: o contido non cambia mentres a app vive.
  static Future<ComoFuncionaOConto> cargar(
      {AssetBundleStringLoader? stringLoader}) {
    if (stringLoader != null) {
      return stringLoader(assetPath).then(ComoFuncionaOConto.fromRaw);
    }
    return _enCurso ??=
        rootBundle.loadString(assetPath).then(ComoFuncionaOConto.fromRaw);
  }

  /// Solo para los tests: olvida lo cargado.
  @visibleForTesting
  static void olvidar() => _enCurso = null;

  /// Solo para los tests: deja la carga en avería, para comprobar sobre la
  /// pantalla de verdad que el fallo se enseña.
  @visibleForTesting
  static void sembrarFallo(Object error) {
    _enCurso = Future<ComoFuncionaOConto>.error(error)..ignore();
  }
}
