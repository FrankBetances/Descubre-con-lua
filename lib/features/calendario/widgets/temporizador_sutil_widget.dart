import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';

/// Temporizador sutil e distintivo de duración de sesión (asamblea ou micro-rutina).
///
/// Deseñado especificamente para educación infantil: tipografía sobria para o adulto,
/// cero animacións distractivas ou parpadeos que atraian a atención das crianzas.
class TemporizadorSutilWidget extends StatelessWidget {
  final int minutosMin;
  final int minutosMax;
  final bool esDocente;
  final AppLanguage language;

  const TemporizadorSutilWidget({
    super.key,
    required this.minutosMin,
    required this.minutosMax,
    this.esDocente = true,
    this.language = AppLanguage.gl,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    // El ámbar de la casa y no #D97706, que como letra daba 2,9:1.
    final badgeColor = esDocente ? context.acento : AppTheme.warning;
    final bgColor = esDocente ? context.acentoTint : const Color(0xFFFFF4E5);

    final duracionTexto = minutosMin == minutosMax
        ? '$minutosMax min'
        : '$minutosMin-$minutosMax min';

    final subtitulo = esDocente
        ? (isGl
            ? 'Ritmo respectuoso · Móbil fóra da vista'
            : 'Ritmo respetuoso · Móvil fuera de la vista')
        : (isGl
            ? 'Micro-rutina · Cero pantallas'
            : 'Micro-rutina · Cero pantallas');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_rounded, size: 20, color: badgeColor),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Temporizador sutil: $duracionTexto',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: badgeColor,
                  ),
                ),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
