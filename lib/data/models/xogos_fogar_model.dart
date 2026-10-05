import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import '../loaders/content_asset_loader.dart';

/// Un xogo de «Xogos de movemento»: físico, na casa e sen pantalla para a
/// crianza. A pantalla é para a persoa adulta.
@immutable
class XogoFogar {
  final String id;
  final LocalizedString titulo;
  final String idade;
  final int duracionMin;
  final LocalizedString materiais;
  final LocalizedString obxectivo;
  final String fraseEn;
  final LocalizedString guionAdulto;
  final LocalizedString accionKinestesica;

  const XogoFogar({
    required this.id,
    required this.titulo,
    required this.idade,
    required this.duracionMin,
    required this.materiais,
    required this.obxectivo,
    required this.fraseEn,
    required this.guionAdulto,
    required this.accionKinestesica,
  });

  factory XogoFogar.fromJson(Map<String, dynamic> json) {
    LocalizedString texto(String campo) {
      final valor = json[campo];
      if (valor is! Map) {
        throw FormatException('xogos_fogar: ${json['id']} sen «$campo»');
      }
      return LocalizedString.fromJson(Map<String, dynamic>.from(valor));
    }

    return XogoFogar(
      id: json['id'] as String,
      titulo: texto('titulo'),
      idade: json['idade'] as String,
      duracionMin: json['duracionMin'] as int,
      materiais: texto('materiais'),
      obxectivo: texto('obxectivo'),
      fraseEn: json['fraseEn'] as String,
      guionAdulto: texto('guionAdulto'),
      accionKinestesica: texto('accionKinestesica'),
    );
  }
}

/// Os dez xogos de «Xogos de movemento».
///
/// Viven en `assets/content/xogos_fogar.json` e non no widget, como pide a
/// regra de contido. O seu «Que observar» está en
/// `xogos_fogar_observar.json`, polo mesmo id.
@immutable
class XogosFogar {
  final List<XogoFogar> xogos;

  const XogosFogar(this.xogos);

  static const String assetPath = 'assets/content/xogos_fogar.json';

  factory XogosFogar.fromRaw(String raw) {
    final decoded = jsonDecode(raw);
    final xogos = decoded is Map ? decoded['xogos'] : null;
    if (xogos is! List) {
      throw const FormatException('xogos_fogar: falta «xogos»');
    }
    return XogosFogar(List.unmodifiable([
      for (final x in xogos)
        XogoFogar.fromJson(Map<String, dynamic>.from(x as Map)),
    ]));
  }

  static Future<XogosFogar>? _enCurso;

  /// Unha soa carga por execución: o contido non cambia mentres a app vive.
  static Future<XogosFogar> cargar({AssetBundleStringLoader? stringLoader}) {
    if (stringLoader != null) {
      return stringLoader(assetPath).then(XogosFogar.fromRaw);
    }
    return _enCurso ??=
        rootBundle.loadString(assetPath).then(XogosFogar.fromRaw);
  }

  /// Solo para los tests: olvida lo cargado.
  @visibleForTesting
  static void olvidar() => _enCurso = null;

  /// Solo para los tests: deja la carga en avería, para comprobar sobre la
  /// pantalla de verdad que el fallo se enseña.
  @visibleForTesting
  static void sembrarFallo(Object error) {
    _enCurso = Future<XogosFogar>.error(error)..ignore();
  }
}
