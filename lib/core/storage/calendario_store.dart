import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../data/models/calendario_model.dart';
import 'local_store.dart';

/// Almacenamiento local soberano y offline para el registro del Calendario Sincronizado.
///
/// **Privacidad estricta:** Solo almacena fechas y marcas booleanas de actividad
/// ('aula' y 'hogar'). Cero identificadores, cero nombres y cero conexión de red.
class CalendarioStore extends ChangeNotifier {
  static const String _nombreFichero = 'calendario_progreso.json';

  final LocalStore _store;
  final Map<String, Map<String, bool>> _registros = {};
  bool _cargado = false;

  CalendarioStore({String? overrideDirectory})
      : _store = LocalStore(
          fileName: _nombreFichero,
          overrideDirectory: overrideDirectory,
        );

  bool get isCargado => _cargado;

  String _claveFecha(DateTime fecha) =>
      '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';

  /// Carga el progreso persistido desde el almacenamiento privado local.
  Future<void> cargar() async {
    try {
      final data = await _store.read();
      _registros.clear();
      if (data != null && data['registros'] is Map) {
        final rawMap = data['registros'] as Map;
        for (final entry in rawMap.entries) {
          if (entry.value is Map) {
            final subMap = entry.value as Map;
            _registros[entry.key.toString()] = {
              'aula': subMap['aula'] == true,
              'hogar': subMap['hogar'] == true,
            };
          }
        }
      }
      _cargado = true;
      notifyListeners();
    } catch (e) {
      debugPrint('CalendarioStore: error ao cargar ($e)');
      _cargado = true;
    }
  }

  /// Guarda el estado actual en disco sin bloquear la interfaz.
  Future<void> _guardar() async {
    try {
      await _store.write({'registros': _registros});
    } catch (e) {
      debugPrint('CalendarioStore: error ao gardar ($e)');
    }
  }

  /// Obtiene el estado de estimulación para una fecha determinada.
  EstadoEstimulacion estadoParaFecha(DateTime fecha) {
    final clave = _claveFecha(fecha);
    final reg = _registros[clave];
    if (reg == null) return EstadoEstimulacion.sinRegistro;

    final aula = reg['aula'] == true;
    final hogar = reg['hogar'] == true;

    if (aula && hogar) return EstadoEstimulacion.dobleEstimulacion;
    if (aula) return EstadoEstimulacion.soloAula;
    if (hogar) return EstadoEstimulacion.soloHogar;
    return EstadoEstimulacion.sinRegistro;
  }

  /// Registra la realización de una asamblea en el aula para una fecha (por defecto hoy).
  Future<bool> registrarAula([DateTime? fecha]) async {
    final f = fecha ?? DateTime.now();
    final clave = _claveFecha(f);
    final reg = _registros.putIfAbsent(clave, () => {'aula': false, 'hogar': false});
    final nuevo = !reg['aula']!;
    reg['aula'] = true;
    notifyListeners();
    await _guardar();
    return nuevo;
  }

  /// Registra la realización de una micro-rutina en el hogar para una fecha (por defecto hoy).
  Future<bool> registrarHogar([DateTime? fecha]) async {
    final f = fecha ?? DateTime.now();
    final clave = _claveFecha(f);
    final reg = _registros.putIfAbsent(clave, () => {'aula': false, 'hogar': false});
    final nuevo = !reg['hogar']!;
    reg['hogar'] = true;
    notifyListeners();
    await _guardar();
    return nuevo;
  }

  /// Alterna el registro en el hogar para facilitar la corrección por parte de la familia.
  Future<void> toggleHogar([DateTime? fecha]) async {
    final f = fecha ?? DateTime.now();
    final clave = _claveFecha(f);
    final reg = _registros.putIfAbsent(clave, () => {'aula': false, 'hogar': false});
    reg['hogar'] = !(reg['hogar'] == true);
    notifyListeners();
    await _guardar();
  }

  /// Total de días en los que se alcanzó la Doble Estimulación (Aula + Hogar).
  int get totalDobleEstimulacion {
    return _registros.values.where((r) => r['aula'] == true && r['hogar'] == true).length;
  }

  /// Total de asambleas realizadas en el aula.
  int get totalSesionesAula {
    return _registros.values.where((r) => r['aula'] == true).length;
  }

  /// Total de micro-rutinas replicadas en el hogar.
  int get totalSesionesHogar {
    return _registros.values.where((r) => r['hogar'] == true).length;
  }
}
