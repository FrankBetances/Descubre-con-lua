import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/localization/localized_string.dart';

/// Para quién es la formación: la docente del aula o la familia en casa.
enum PerfilFormacion {
  docente,
  familia;

  String get clave => switch (this) {
        PerfilFormacion.docente => 'docente',
        PerfilFormacion.familia => 'familia',
      };

  String get asset => 'assets/content/formacion/formacion_$clave.json'
      .replaceFirst('formacion_', 'formacion.');
}

/// Un paso de la formación: qué es, por qué, y la frase que hay que recordar.
@immutable
class PasoFormacion {
  final LocalizedString titulo;
  final LocalizedString corpo;

  /// La línea que resume el paso. Es lo que queda cuando se olvida el resto.
  final LocalizedString clave;

  const PasoFormacion({
    required this.titulo,
    required this.corpo,
    required this.clave,
  });

  factory PasoFormacion.fromJson(Map<String, dynamic> json) => PasoFormacion(
        titulo: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['titulo'] as Map)),
        corpo: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['corpo'] as Map)),
        clave: LocalizedString.fromJson(
            Map<String, dynamic>.from(json['clave'] as Map)),
      );
}

/// La formación previa de un perfil: lo que hay que saber ANTES de usar esto.
///
/// Existe porque los dos documentos curriculares la piden y porque sin ella la
/// app se usa mal: la docente enseñaría la pantalla a las criaturas y la
/// familia preguntaría «¿cómo se dice?», que es exactamente lo que hay que
/// evitar. El contenido vive en JSON, nunca escrito en los widgets.
@immutable
class GuiaFormacion {
  final String id;
  final PerfilFormacion perfil;
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final List<PasoFormacion> pasos;

  const GuiaFormacion({
    required this.id,
    required this.perfil,
    required this.titulo,
    required this.subtitulo,
    required this.pasos,
  });

  factory GuiaFormacion.fromJson(Map<String, dynamic> json) {
    final rawPasos = json['pasos'];
    final List<PasoFormacion> pasos = [];
    if (rawPasos is List) {
      for (final p in rawPasos) {
        if (p is Map) {
          pasos.add(PasoFormacion.fromJson(Map<String, dynamic>.from(p)));
        }
      }
    }
    return GuiaFormacion(
      id: (json['id'] as String?)?.trim() ?? '',
      perfil: (json['perfil'] as String?) == 'familia'
          ? PerfilFormacion.familia
          : PerfilFormacion.docente,
      titulo: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['titulo'] as Map)),
      subtitulo: LocalizedString.fromJson(
          Map<String, dynamic>.from(json['subtitulo'] as Map)),
      pasos: List.unmodifiable(pasos),
    );
  }

  /// Lee la guía del paquete. Si falla, quien llama lo verá como excepción y
  /// la pantalla lo dice en palabras; no se queda girando para siempre.
  static Future<GuiaFormacion> cargar(
    PerfilFormacion perfil, {
    Future<String> Function(String)? lector,
  }) async {
    final cargar = lector ?? rootBundle.loadString;
    final raw = await cargar(perfil.asset);
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw FormatException('${perfil.asset} no es un objeto JSON');
    }
    return GuiaFormacion.fromJson(Map<String, dynamic>.from(decoded));
  }
}
