import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';

/// Una de las cuatro fases de la sesión de 45 minutos (F3).
@immutable
class FaseSesion45 {
  final String clave;
  final LocalizedString nome;

  /// «7-10», tal como lo da el texto de base.
  final String minutos;
  final LocalizedString para;
  final List<LocalizedString> pasos;

  /// Lo fijo que dice la adulta en inglés en esta fase. Lleva voz.
  final List<String> ingles;

  const FaseSesion45({
    required this.clave,
    required this.nome,
    required this.minutos,
    required this.para,
    required this.pasos,
    required this.ingles,
  });
}

/// La sesión de 45 minutos: lo fijo de cada fase. Lo del mes sale de la
/// unidad del curso. Vive en `assets/content/sesion45/sesion45.json`.
@immutable
class Sesion45 {
  final LocalizedString titulo;
  final LocalizedString primeiroCiclo;
  final LocalizedString segundoCiclo;
  final List<FaseSesion45> fases;

  const Sesion45({
    required this.titulo,
    required this.primeiroCiclo,
    required this.segundoCiclo,
    required this.fases,
  });

  static const String assetPath = 'assets/content/sesion45/sesion45.json';

  factory Sesion45.fromRaw(String raw) {
    final j = jsonDecode(raw) as Map<String, dynamic>;
    LocalizedString t(Object? v, String onde) {
      if (v is! Map ||
          (v['gl'] as String? ?? '').trim().isEmpty ||
          (v['es'] as String? ?? '').trim().isEmpty) {
        throw FormatException('sesion45: $onde sen galego e castelán');
      }
      return LocalizedString.fromJson(Map<String, dynamic>.from(v));
    }

    final fases = (j['fases'] as List).cast<Map>();
    if (fases.length != 4) {
      throw const FormatException('sesion45: teñen que ser catro fases');
    }
    return Sesion45(
      titulo: t(j['titulo'], 'o título'),
      primeiroCiclo: t(j['primeiroCiclo'], '1.º ciclo'),
      segundoCiclo: t(j['segundoCiclo'], '2.º ciclo'),
      fases: List.unmodifiable([
        for (final f in fases)
          FaseSesion45(
            clave: f['clave'] as String,
            nome: t(f['nome'], '${f['clave']}: nome'),
            minutos: f['minutos'] as String,
            para: t(f['para'], '${f['clave']}: para'),
            pasos: [
              for (final (i, p) in (f['pasos'] as List).indexed)
                t(p, '${f['clave']}: paso ${i + 1}'),
            ],
            ingles: [for (final e in f['ingles'] as List) e as String],
          ),
      ]),
    );
  }

  static Future<Sesion45>? _enCurso;

  /// Una sola carga por ejecución: el contenido no cambia mientras la app vive.
  static Future<Sesion45> cargar() =>
      _enCurso ??= rootBundle.loadString(assetPath).then(Sesion45.fromRaw);

  /// Solo para los tests: deja la sesión ya leída, sin pasar por el bundle.
  @visibleForTesting
  static void sembrar(Sesion45 s) => _enCurso = SynchronousFuture(s);
}
