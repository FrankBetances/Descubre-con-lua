import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';

/// Una canción con pulso: la letra lleva las marcas `*` de los tiempos, y
/// el pulso se dibuja con ellas (ver «El pulso se ve, no se oye» en CLAUDE.md).
@immutable
class CancionPulso {
  final LocalizedString titulo;
  final LocalizedString letraConPulsos;
  final int bpm;
  final LocalizedString audioAsset;
  final LocalizedString consignaDocente;

  const CancionPulso({
    required this.titulo,
    required this.letraConPulsos,
    required this.bpm,
    required this.audioAsset,
    required this.consignaDocente,
  });

  factory CancionPulso.fromJson(Map<String, dynamic> json) {
    final rawAudio = json['audioAsset'] ?? json['audio_asset'];
    final LocalizedString resolvedAudio;
    if (rawAudio is Map<String, dynamic>) {
      resolvedAudio = LocalizedString.fromJson(rawAudio);
    } else if (rawAudio is String) {
      resolvedAudio = LocalizedString(gl: rawAudio, es: rawAudio);
    } else {
      resolvedAudio = const LocalizedString(gl: '', es: '');
    }

    return CancionPulso(
      titulo: LocalizedString.fromJson(
          json['titulo'] as Map<String, dynamic>? ?? {}),
      letraConPulsos: LocalizedString.fromJson(
        (json['letraConPulsos'] ?? json['letra_con_pulsos'])
                as Map<String, dynamic>? ??
            {},
      ),
      bpm: (json['bpm'] as num?)?.toInt() ?? 72,
      audioAsset: resolvedAudio,
      consignaDocente: LocalizedString.fromJson(
        (json['consignaDocente'] ?? json['consigna_docente'])
                as Map<String, dynamic>? ??
            {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo.toJson(),
        'letraConPulsos': letraConPulsos.toJson(),
        'bpm': bpm,
        'audioAsset': audioAsset.toJson(),
        'consignaDocente': consignaDocente.toJson(),
      };

  /// Resolves audio path according to active language.
  String resolveAudio(AppLanguage lang) => audioAsset.resolve(lang);

  /// The song's lines, as written, one per verse.
  List<String> versos(AppLanguage lang) => letraConPulsos
      .resolve(lang)
      .split('\n')
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();

  /// Beats in a bar, read from the `*` markers in the lyrics.
  ///
  /// The markers are the beats, so the pulse is not configured separately and
  /// cannot disagree with the words the teacher is reading.
  /// tools/check_pulse_markers.py enforces that every line carries the same
  /// number of them, in both languages.
  int beatsPerLine(AppLanguage lang) {
    for (final verso in versos(lang)) {
      final beats = '*'.allMatches(verso).length;
      if (beats > 0) return beats;
    }
    return 4;
  }

  /// Beats between strong beats: the downbeat of every bar.
  int accentEvery(AppLanguage lang) => beatsPerLine(lang);

  /// How long one beat lasts at this tempo.
  Duration get beatDuration =>
      Duration(microseconds: (60000000 / (bpm <= 0 ? 72 : bpm)).round());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CancionPulso &&
          runtimeType == other.runtimeType &&
          titulo == other.titulo &&
          letraConPulsos == other.letraConPulsos &&
          bpm == other.bpm &&
          audioAsset == other.audioAsset &&
          consignaDocente == other.consignaDocente;

  @override
  int get hashCode => Object.hash(
        titulo,
        letraConPulsos,
        bpm,
        audioAsset,
        consignaDocente,
      );
}

/// Una de las diez canciones con pulso, con su identificador.
@immutable
class CancionConPulso {
  final String id;
  final CancionPulso cancion;

  const CancionConPulso({required this.id, required this.cancion});
}

/// Las canciones con pulso de `assets/content/cancions/cancions_con_pulso.json`.
///
/// Vinieron de la asamblea de seis pasos, que se retiró en M4.3, y quedan como
/// recurso suelto en Recursos, fuera del mes: la canción del mes es la de su
/// asamblea (D4).
class CancionsConPulso {
  static const String asset = 'assets/content/cancions/cancions_con_pulso.json';

  static List<CancionConPulso> desdeJson(String raw) {
    final datos = jsonDecode(raw) as Map<String, dynamic>;
    return List.unmodifiable([
      for (final e in (datos['cancions'] as List? ?? const []))
        if (e is Map)
          CancionConPulso(
            id: e['id']?.toString() ?? '',
            cancion: CancionPulso.fromJson(Map<String, dynamic>.from(e)),
          ),
    ]);
  }
}
