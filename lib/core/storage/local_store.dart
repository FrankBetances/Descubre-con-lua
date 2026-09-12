import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Guarda un puñado de contadores en la carpeta privada de la app.
///
/// **Lo que guarda y lo que no.** Aquí solo caben números y fechas: cuántas
/// asambleas se dirigieron, cuántas cápsulas se leyeron, qué días seguidos y
/// qué insignias se ganaron. No hay nombre, ni edad, ni nada de ninguna
/// criatura, ni identificador de aparato. Un fichero de este tipo no permite
/// saber quién usó la app, solo cuánto se usó.
///
/// **Dónde.** `getFilesDir()` de Android, que es privada de la app, la borra el
/// sistema al desinstalar y ninguna otra app puede leer. Se pide por el
/// MethodChannel que ya existe para el audio, en vez de añadir `path_provider`:
/// la app no tiene ni una dependencia externa y no va a estrenar una por esto.
///
/// **No sale de aquí.** Sigue sin haber permiso de INTERNET en el APK, así que
/// esto no puede viajar a ningún sitio ni aunque alguien quisiera.
class LocalStore {
  static const MethodChannel _channel = MethodChannel(
    'com.earlify.descubreconlua/audio',
  );

  final String fileName;

  /// Carpeta forzada. Solo la usan los tests, para no tocar el aparato.
  final String? overrideDirectory;

  LocalStore({required this.fileName, this.overrideDirectory});

  File? _file;

  Future<File?> _resolve() async {
    if (_file != null) return _file;
    try {
      final dir =
          overrideDirectory ?? await _channel.invokeMethod<String>('filesDir');
      if (dir == null || dir.isEmpty) return null;
      return _file = File('$dir/$fileName');
    } catch (error) {
      // Sin almacenamiento la app sigue funcionando entera: lo único que pasa
      // es que el progreso no sobrevive al cierre. Una asamblea no se puede
      // caer porque el disco esté lleno o el canal no responda.
      debugPrint('LocalStore: sin almacenamiento ($error)');
      return null;
    }
  }

  /// Devuelve el contenido guardado, o `null` si no hay nada o no se pudo leer.
  Future<Map<String, dynamic>?> read() async {
    try {
      final file = await _resolve();
      if (file == null || !await file.exists()) return null;
      final raw = await file.readAsString();
      if (raw.trim().isEmpty) return null;
      final decoded = json.decode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (error) {
      // Un fichero corrupto se trata como «no hay nada». Perder la racha es
      // molesto; que la app no abra, no.
      debugPrint('LocalStore: no se pudo leer $fileName ($error)');
      return null;
    }
  }

  /// Escribe el contenido. Devuelve si se pudo.
  Future<bool> write(Map<String, dynamic> data) async {
    try {
      final file = await _resolve();
      if (file == null) return false;
      await file.parent.create(recursive: true);
      // Escritura atómica: se escribe al lado y se renombra. Si la app muere a
      // mitad, el fichero bueno sigue entero en vez de quedar a medias.
      final temp = File('${file.path}.tmp');
      await temp.writeAsString(json.encode(data), flush: true);
      await temp.rename(file.path);
      return true;
    } catch (error) {
      debugPrint('LocalStore: no se pudo escribir $fileName ($error)');
      return false;
    }
  }

  /// Borra lo guardado. Es lo que hay detrás de «empezar de cero».
  Future<bool> clear() async {
    try {
      final file = await _resolve();
      if (file == null || !await file.exists()) return true;
      await file.delete();
      return true;
    } catch (error) {
      debugPrint('LocalStore: no se pudo borrar $fileName ($error)');
      return false;
    }
  }
}
