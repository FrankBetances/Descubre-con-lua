import 'package:flutter/foundation.dart';
import '../../data/models/calendario_model.dart';
import 'local_store.dart';

/// El registro del Calendario Escola·Fogar, en la carpeta privada de la app.
///
/// **Qué guarda, y nada más:** por cada día en que alguien marcó algo, la fecha
/// en `aaaa-mm-dd` —sin hora— y dos booleanos, `aula` y `hogar`. No hay nombre,
/// ni edad, ni identificador de aparato, ni nada de ninguna criatura: dice
/// cuánto se usó la app, nunca quién la usó. Vive en `getFilesDir()`, que
/// ninguna otra app puede leer, y no puede salir del aparato porque el APK no
/// tiene permiso de INTERNET.
///
/// Esto está declarado en `docs/privacy.html` y en el formulario de Seguridad
/// de los datos de Play. **Si añades una clave a este fichero, actualiza los dos
/// en el mismo cambio**, o lo declarado y lo compilado dejan de coincidir. Lo
/// vigila `test/privacy/privacy_manifest_test.dart`.
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

  /// El estado de un MES entero: lo mejor que se alcanzó cualquier día de ese
  /// mes del año escolar.
  ///
  /// La tarjeta del carrusel preguntaba por el día 15 de cada mes y enseñaba
  /// «sen rexistro» en un mes con la mitad de los días trabajados. Un mes no
  /// tiene el estado de su día 15.
  EstadoEstimulacion estadoParaMes(int anho, int mes) {
    final prefijo = '$anho-${mes.toString().padLeft(2, '0')}-';
    var huboAula = false;
    var huboFogar = false;
    var huboDobre = false;
    for (final entrada in _registros.entries) {
      if (!entrada.key.startsWith(prefijo)) continue;
      final aula = entrada.value['aula'] == true;
      final fogar = entrada.value['hogar'] == true;
      if (aula && fogar) huboDobre = true;
      if (aula) huboAula = true;
      if (fogar) huboFogar = true;
    }
    if (huboDobre) return EstadoEstimulacion.dobleEstimulacion;
    if (huboAula) return EstadoEstimulacion.soloAula;
    if (huboFogar) return EstadoEstimulacion.soloHogar;
    return EstadoEstimulacion.sinRegistro;
  }

  /// Registra la realización de una asamblea en el aula para una fecha (por defecto hoy).
  Future<bool> registrarAula([DateTime? fecha]) async {
    final f = fecha ?? DateTime.now();
    final clave = _claveFecha(f);
    final reg =
        _registros.putIfAbsent(clave, () => {'aula': false, 'hogar': false});
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
    final reg =
        _registros.putIfAbsent(clave, () => {'aula': false, 'hogar': false});
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
    final reg =
        _registros.putIfAbsent(clave, () => {'aula': false, 'hogar': false});
    reg['hogar'] = !(reg['hogar'] == true);
    notifyListeners();
    await _guardar();
  }

  /// Total de días en los que se alcanzó la Doble Estimulación (Aula + Hogar).
  int get totalDobleEstimulacion {
    return _registros.values
        .where((r) => r['aula'] == true && r['hogar'] == true)
        .length;
  }

  /// Total de asambleas realizadas en el aula.
  int get totalSesionesAula {
    return _registros.values.where((r) => r['aula'] == true).length;
  }

  /// Total de micro-rutinas replicadas en el hogar.
  int get totalSesionesHogar {
    return _registros.values.where((r) => r['hogar'] == true).length;
  }

  /// Días consecutivos con sesión en el hogar, contando hacia atrás.
  ///
  /// Se DERIVA de `_registros`: no hay ninguna clave nueva en el fichero, que
  /// es lo que permite que la política de privacidad y el formulario de
  /// Seguridad de los datos sigan diciendo exactamente lo que dicen. Guardar
  /// una racha sería guardar un dato que ya está implícito en las fechas.
  ///
  /// La cuenta arranca hoy si hoy está marcado y, si no, ayer: una racha no se
  /// pierde por que aún no haya dado tiempo a hacer la sesión de hoy. En
  /// cuanto falta un día entero, se corta.
  int get rachaActual {
    bool hayFogar(DateTime f) => _registros[_claveFecha(f)]?['hogar'] == true;

    final hoxe = DateTime.now();
    final hoy = DateTime(hoxe.year, hoxe.month, hoxe.day);
    var cursor = hayFogar(hoy) ? hoy : hoy.subtract(const Duration(days: 1));

    var racha = 0;
    while (hayFogar(cursor)) {
      racha++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return racha;
  }

  /// Las tres cuentas, que es lo único que sale de aquí hacia las medallas.
  /// Las fechas no viajan: se quedan en este objeto.
  ContadoresCalendario get contadores => ContadoresCalendario(
        diasAula: totalSesionesAula,
        diasFogar: totalSesionesHogar,
        diasDobres: totalDobleEstimulacion,
      );
}
