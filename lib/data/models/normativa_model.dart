import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';
import '../loaders/content_asset_loader.dart';

LocalizedString _t(Object? v) => LocalizedString.fromJson(
    Map<String, dynamic>.from(v is Map ? v : const {}));

/// El criterio de un curso: objetivo de área, código (si lo hay) y texto.
@immutable
class CriterioDoCurso {
  final String obx;
  final String? codigo;
  final LocalizedString criterio;
  final LocalizedString encadre;
  final LocalizedString horario;

  /// Fichero y línea del texto de Frank de donde sale.
  final String cita;

  const CriterioDoCurso({
    required this.obx,
    this.codigo,
    required this.criterio,
    required this.encadre,
    required this.horario,
    required this.cita,
  });
}

/// El marco normativo del inglés (F6, M1.1 con P6): del texto curricular de
/// Frank, pendiente de contrastar con el DOG. Ver `docs/referencias/normativa.md`.
@immutable
class Normativa {
  final LocalizedString aviso;
  final LocalizedString area;
  final LocalizedString saber;
  final Map<String, CriterioDoCurso> cursos;

  const Normativa({
    required this.aviso,
    required this.area,
    required this.saber,
    required this.cursos,
  });

  static const assetPath = 'assets/content/curriculo/normativa.json';

  factory Normativa.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    final ciclos = Map<String, dynamic>.from(j['ciclos'] as Map);
    return Normativa(
      aviso: _t(j['aviso']),
      area: _t(j['area']),
      saber: _t(j['saber']),
      cursos: {
        for (final e in (j['cursos'] as Map).entries)
          e.key.toString(): () {
            final c = Map<String, dynamic>.from(e.value as Map);
            final ciclo =
                Map<String, dynamic>.from(ciclos[c['ciclo']] as Map? ?? {});
            return CriterioDoCurso(
              obx: c['obx']?.toString() ?? '',
              codigo: c['codigo']?.toString(),
              criterio: _t(c['criterio']),
              encadre: _t(ciclo['encadre']),
              horario: _t(ciclo['horario']),
              cita: c['cita']?.toString() ?? '',
            );
          }(),
      },
    );
  }

  static Future<Normativa>? _enCurso;

  /// Una sola carga por ejecución.
  static Future<Normativa> cargar({AssetBundleStringLoader? stringLoader}) {
    if (stringLoader != null) {
      return stringLoader(assetPath).then(Normativa.fromRaw);
    }
    return _enCurso ??=
        rootBundle.loadString(assetPath).then(Normativa.fromRaw);
  }

  /// Solo para los tests: deja la normativa ya leída.
  @visibleForTesting
  static void sembrar(Normativa n) => _enCurso = SynchronousFuture(n);
}
