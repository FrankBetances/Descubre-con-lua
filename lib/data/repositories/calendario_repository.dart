import 'dart:convert';

import 'package:flutter/foundation.dart' show visibleForTesting;
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

  /// Los seis años: los diez meses de cada curso, de 0-2 a 5-6, seguidos. Es
  /// lo que recorre el calendario. Cada mes trae el tema, las actividades y el
  /// inglés de SU curso, no los mismos diez para todas las edades.
  final List<MesCurricular> trayecto;

  const CalendarioContenido({
    required this.meses,
    required this.guia,
    this.trayecto = const [],
  });

  static const String mesesAsset = 'assets/content/calendario/meses.json';
  static const String curriculoAsset =
      'assets/content/calendario/curriculo_50_meses.json';

  /// Los cursos del trayecto, en orden.
  static const List<String> cursos = [
    'curso_0_2',
    'curso_2_3',
    'curso_3_4',
    'curso_4_5',
    'curso_5_6',
  ];
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

  /// Solo para los tests: deja el contenido en estado de AVERÍA.
  ///
  /// Es la única forma de comprobar sobre la pantalla de verdad —no sobre una
  /// copia de mentira— que un fallo de lectura se ENSEÑA en vez de dejar el
  /// disco girando. El fallo que hubo no se podía reproducir de otra manera:
  /// nacía del paquete, no del JSON.
  @visibleForTesting
  static void sembrarFallo(Object error) {
    // `ignore()` solo silencia el aviso de «error asíncrono sin escuchar»:
    // quien haga `.then` sobre este future sigue recibiendo el error, que es
    // justo lo que el test quiere comprobar.
    _enCurso = Future<CalendarioContenido>.error(error)..ignore();
  }

  static Future<CalendarioContenido> _leer(
      AssetBundleStringLoader cargador) async {
    final meses = desdeJsonMeses(await cargador(mesesAsset));
    final guia = desdeJsonGuia(await cargador(atencionAsset));
    final trayecto = desdeJsonCurriculo(await cargador(curriculoAsset), meses);
    return CalendarioContenido(meses: meses, guia: guia, trayecto: trayecto);
  }

  /// Los 50 meses del currículo, en el orden del trayecto: curso a curso y,
  /// dentro de cada curso, de septiembre a junio.
  static List<MesCurricular> desdeJsonCurriculo(
      String rawJson, List<MesCurricular> meses) {
    final decoded = json.decode(rawJson);
    if (decoded is! List) {
      throw const FormatException(
          'curriculo_50_meses.json: se esperaba una lista');
    }
    final entradas = [
      for (final e in decoded) Map<String, dynamic>.from(e as Map),
    ]..sort((a, b) {
        final c = cursos
            .indexOf(a['cursoId'] as String)
            .compareTo(cursos.indexOf(b['cursoId'] as String));
        return c != 0
            ? c
            : (a['mesNumero'] as num).compareTo(b['mesNumero'] as num);
      });
    final porOrden = {for (final m in meses) m.orden: m};
    return List.unmodifiable([
      for (final (i, e) in entradas.indexed)
        MesCurricular.doCurriculo(
          e,
          base: porOrden[(e['mesNumero'] as num).toInt()]!,
          orden: i + 1,
        ),
    ]);
  }

  /// El índice en el [trayecto] del mes de [fecha] en el curso [cursoId].
  int indiceNoTrayecto(String cursoId, DateTime fecha) {
    final mes = mesParaFecha(fecha).mesCalendario;
    final i = trayecto
        .indexWhere((m) => m.cursoId == cursoId && m.mesCalendario == mes);
    return i < 0 ? 0 : i;
  }

  /// El índice del primer mes de [cursoId] en el [trayecto].
  int inicioDoCurso(String cursoId) {
    final i = trayecto.indexWhere((m) => m.cursoId == cursoId);
    return i < 0 ? 0 : i;
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
