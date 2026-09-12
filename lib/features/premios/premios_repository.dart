import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/storage/local_store.dart';
import 'premios_model.dart';

/// Qué acaba de hacer el adulto.
enum EventoPremio {
  /// Terminó una asamblea dirigida en Juega con Lúa.
  asamblea,

  /// Leyó una cápsula entera en Academy.
  capsula,
}

/// Lleva la cuenta de los premios de Lúa, para cada perfil por separado.
///
/// La maestra y la familia no comparten recorrido: son dos personas distintas
/// haciendo dos cosas distintas, y mezclarlas daría una racha que no significa
/// nada.
class PremiosRepository extends ChangeNotifier {
  static const String _assetCatalogo = 'assets/content/premios/premios.json';

  final LocalStore _store;

  /// Reloj inyectable. Los tests necesitan mover los días sin esperar a mañana.
  final DateTime Function() _ahora;

  PremiosRepository({LocalStore? store, DateTime Function()? ahora})
      : _store = store ?? LocalStore(fileName: 'premios.json'),
        _ahora = ahora ?? DateTime.now;

  CatalogoPremios? _catalogo;
  final Map<Perfil, Progreso> _progreso = {
    for (final p in Perfil.values) p: const Progreso(),
  };
  bool _cargado = false;

  CatalogoPremios? get catalogo => _catalogo;
  bool get cargado => _cargado;

  Progreso progresoDe(Perfil perfil) => _progreso[perfil] ?? const Progreso();

  /// Lee el catálogo del paquete y el progreso del disco.
  Future<void> cargar() async {
    if (_catalogo == null) {
      try {
        final raw = await rootBundle.loadString(_assetCatalogo);
        _catalogo = CatalogoPremios.fromJson(
          Map<String, dynamic>.from(json.decode(raw) as Map),
        );
      } catch (error) {
        // Sin catálogo no hay premios, pero la app entera sigue en pie: los
        // premios acompañan a la asamblea, no la sostienen.
        debugPrint('PremiosRepository: no se pudo leer el catálogo ($error)');
      }
    }

    final guardado = await _store.read();
    if (guardado != null) {
      for (final perfil in Perfil.values) {
        final bloque = guardado[perfil.clave];
        if (bloque is Map) {
          _progreso[perfil] =
              Progreso.fromJson(Map<String, dynamic>.from(bloque));
        }
      }
    }

    _cargado = true;
    notifyListeners();
  }

  /// Registra que el adulto acaba de hacer algo, y devuelve las insignias que
  /// se ganan en ESTE momento — las que no tenía y ahora sí.
  ///
  /// Devolverlas es lo que permite celebrarlas una sola vez. Recalcular la
  /// lista entera y comparar en la pantalla habría hecho que la misma insignia
  /// se celebrase en cada apertura.
  Future<List<Insignia>> registrar(Perfil perfil, EventoPremio evento) async {
    final catalogo = _catalogo;
    if (catalogo == null) return const [];

    final antes = progresoDe(perfil);
    final hoy = _soloFecha(_ahora());

    // La racha cuenta DÍAS, no sesiones: dos asambleas la misma mañana son un
    // día. Si no, bastaría con abrir y cerrar seis veces para fingir constancia.
    var racha = antes.rachaActual;
    if (antes.ultimoDia == null) {
      racha = 1;
    } else if (antes.ultimoDia == hoy) {
      racha = antes.rachaActual == 0 ? 1 : antes.rachaActual;
    } else if (antes.ultimoDia ==
        _soloFecha(_ahora().subtract(
          const Duration(days: 1),
        ))) {
      racha = antes.rachaActual + 1;
    } else {
      // Un día en blanco rompe la racha. Duro, pero es lo que la hace
      // significar algo.
      racha = 1;
    }

    var despues = antes.copyWith(
      asambleas: antes.asambleas + (evento == EventoPremio.asamblea ? 1 : 0),
      capsulas: antes.capsulas + (evento == EventoPremio.capsula ? 1 : 0),
      rachaActual: racha,
      mejorRacha: racha > antes.mejorRacha ? racha : antes.mejorRacha,
      ultimoDia: hoy,
    );

    final nuevas = <Insignia>[];
    final ganadas = Set<String>.from(antes.insignias);
    for (final insignia in catalogo.insigniasDe(perfil)) {
      if (ganadas.contains(insignia.id)) continue;
      if (_cumple(insignia, despues)) {
        ganadas.add(insignia.id);
        nuevas.add(insignia);
      }
    }
    despues = despues.copyWith(insignias: ganadas);

    _progreso[perfil] = despues;
    await _guardar();
    notifyListeners();
    return nuevas;
  }

  /// Recalcula la racha al abrir la pantalla.
  ///
  /// Sin esto, una racha de 12 días seguiría diciendo «12» en marzo aunque la
  /// última asamblea fuese en diciembre. Una racha que no se cae no es una
  /// racha: es un número viejo.
  Future<void> refrescarRachas() async {
    final hoy = _soloFecha(_ahora());
    final ayer = _soloFecha(_ahora().subtract(const Duration(days: 1)));
    var cambio = false;

    for (final perfil in Perfil.values) {
      final p = progresoDe(perfil);
      if (p.rachaActual == 0 || p.ultimoDia == null) continue;
      if (p.ultimoDia != hoy && p.ultimoDia != ayer) {
        _progreso[perfil] = p.copyWith(rachaActual: 0);
        cambio = true;
      }
    }

    if (cambio) {
      await _guardar();
      notifyListeners();
    }
  }

  /// Borra el progreso de los dos perfiles.
  Future<void> borrarTodo() async {
    for (final perfil in Perfil.values) {
      _progreso[perfil] = const Progreso();
    }
    await _store.clear();
    notifyListeners();
  }

  bool _cumple(Insignia insignia, Progreso p) => switch (insignia.tipo) {
        TipoCriterio.asambleas => p.asambleas >= insignia.valor,
        TipoCriterio.capsulas => p.capsulas >= insignia.valor,
        TipoCriterio.racha => p.rachaActual >= insignia.valor,
      };

  Future<void> _guardar() => _store.write({
        for (final perfil in Perfil.values)
          perfil.clave: progresoDe(perfil).toJson(),
      });

  /// `aaaa-mm-dd`. Sin hora, a propósito: la hora diría a qué hora trabaja una
  /// persona concreta y no hace falta para contar días.
  static String _soloFecha(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
