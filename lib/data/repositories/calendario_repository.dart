import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../loaders/content_asset_loader.dart';
import '../models/calendario_model.dart';

/// El contenido del Calendario Escola·Fogar, leído del bundle.
///
/// Los diez meses y la guía de la familia son CONTENIDO: viven en
/// `assets/content/calendario/`, no escritos en ningún widget. Cambiar una
/// actividad, un mes o una frase inglesa es editar un JSON, y el corpus de voz
/// y los gates lo ven; antes había que recompilar y no lo veía nadie.
class CalendarioContenido {
  final List<MesCurricular> meses;
  final GuiaAtencion guia;

  const CalendarioContenido({required this.meses, required this.guia});

  static const String mesesAsset = 'assets/content/calendario/meses.json';
  static const String atencionAsset = 'assets/content/calendario/atencion.json';

  /// Una sola carga por ejecución: el contenido no cambia mientras la app vive,
  /// y cuatro pantallas distintas abren el calendario.
  static Future<CalendarioContenido>? _enCurso;

  /// Carga el contenido del bundle. Las llamadas siguientes devuelven la misma.
  static Future<CalendarioContenido> cargar({
    AssetBundleStringLoader? stringLoader,
  }) {
    if (stringLoader != null) {
      return _leer(stringLoader);
    }
    return _enCurso ??= _leer((path) => rootBundle.loadString(path));
  }

  /// Solo para los tests: olvida lo cargado.
  static void olvidar() => _enCurso = null;

  static Future<CalendarioContenido> _leer(
      AssetBundleStringLoader cargador) async {
    final meses = desdeJsonMeses(await cargador(mesesAsset));
    final guia = desdeJsonGuia(await cargador(atencionAsset));
    return CalendarioContenido(meses: meses, guia: guia);
  }

  /// Parsea el catálogo de meses y lo deja ordenado por curso.
  static List<MesCurricular> desdeJsonMeses(String rawJson) {
    final decoded = json.decode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('meses.json: se esperaba un objeto');
    }
    final lista = (decoded['meses'] as List? ?? const [])
        .map((e) => MesCurricular.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.orden.compareTo(b.orden));
    return List.unmodifiable(lista);
  }

  static GuiaAtencion desdeJsonGuia(String rawJson) {
    final decoded = json.decode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('atencion.json: se esperaba un objeto');
    }
    return GuiaAtencion.fromJson(decoded);
  }

  /// El mes de curso que toca en [fecha].
  ///
  /// Julio y agosto no son meses de curso: se muestra septiembre, que es por
  /// donde se empieza, en vez de dejar la pantalla vacía en vacaciones.
  MesCurricular mesParaFecha(DateTime fecha) {
    final mes = fecha.month;
    if (mes == 7 || mes == 8) return meses.first;
    return meses.firstWhere(
      (m) => m.mesCalendario == mes,
      orElse: () => meses.first,
    );
  }

  int indiceParaFecha(DateTime fecha) => meses.indexOf(mesParaFecha(fecha));
}
