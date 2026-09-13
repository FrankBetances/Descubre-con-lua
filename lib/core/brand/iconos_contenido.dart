import 'package:flutter/material.dart';

/// Traduce el token de icono que trae el contenido a un icono de pantalla.
///
/// El JSON de contenido no conoce Flutter: escribe `"icono": "mar"`, no un
/// `IconData`. La correspondencia vive aquí, que es código, y así el mismo
/// contenido lo puede leer el corpus de voz, un gate de Python o un imprimible
/// sin arrastrar el motor gráfico detrás.
IconData iconoDeContenido(String token) {
  switch (token) {
    // Meses del curso.
    case 'saudo':
      return Icons.waving_hand_rounded;
    case 'corpo':
      return Icons.accessibility_new_rounded;
    case 'follas':
      return Icons.eco_rounded;
    case 'inverno':
      return Icons.notifications_active_rounded;
    case 'choiva':
      return Icons.umbrella_rounded;
    case 'animais':
      return Icons.pets_rounded;
    case 'cores':
      return Icons.palette_rounded;
    case 'primavera':
      return Icons.local_florist_rounded;
    case 'auga':
      return Icons.water_drop_rounded;
    case 'mar':
      return Icons.waves_rounded;

    // Tramos de edad de la guía de la familia.
    case 'bebe':
      return Icons.child_care_rounded;
    case 'mirada':
      return Icons.visibility_rounded;
    case 'camina':
      return Icons.directions_walk_rounded;
    case 'movemento':
      return Icons.sports_gymnastics_rounded;

    // Reglas de la casa.
    case 'voz':
      return Icons.record_voice_over_rounded;
    case 'silencio':
      return Icons.hearing_rounded;
    case 'sen_pantallas':
      return Icons.phonelink_erase_rounded;
  }
  return Icons.circle_outlined;
}
