import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// The canonical section types of an Academy micro-learning capsule.
enum TipoSeccionCapsula {
  ideaClave,
  porQueImporta,
  queHacerEnCasa,
  ejemploCotidiano,
}

/// A dedicated pedagogical section card for Academy capsules.
///
/// Ensures strict adherence to adult design rules:
/// - Body text >= 16sp for comfortable parental reading.
/// - High contrast between text and background.
/// - Clear pedagogical iconography and section badges.
/// - ZERO external links and ZERO child game mechanics.
class SeccionCapsulaWidget extends StatelessWidget {
  final TipoSeccionCapsula tipo;
  final String titulo;
  final String contenido;
  final IconData? iconOverride;
  final Color? accentColor;

  const SeccionCapsulaWidget({
    super.key,
    required this.tipo,
    required this.titulo,
    required this.contenido,
    this.iconOverride,
    this.accentColor,
  });

  IconData get _defaultIcon {
    switch (tipo) {
      case TipoSeccionCapsula.ideaClave:
        return Icons.lightbulb_outline;
      case TipoSeccionCapsula.porQueImporta:
        return Icons.psychology_outlined;
      case TipoSeccionCapsula.queHacerEnCasa:
        return Icons.home_outlined;
      case TipoSeccionCapsula.ejemploCotidiano:
        return Icons.forum_outlined;
    }
  }

  Color get _effectiveAccentColor {
    if (accentColor != null) return accentColor!;
    switch (tipo) {
      case TipoSeccionCapsula.ideaClave:
        return AppTheme.primaryVigoBlue;
      case TipoSeccionCapsula.porQueImporta:
        return const Color(0xFF2C5E7A);
      case TipoSeccionCapsula.queHacerEnCasa:
        return AppTheme.calmSage;
      case TipoSeccionCapsula.ejemploCotidiano:
        return AppTheme.accentTerracotta;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _effectiveAccentColor;
    final icon = iconOverride ?? _defaultIcon;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: accent.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header band
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: accent.withOpacity(0.08),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14.5),
                topRight: Radius.circular(14.5),
              ),
              border: Border(
                bottom: BorderSide(
                  color: accent.withOpacity(0.15),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: accent.withOpacity(0.18),
                  child: Icon(icon, color: accent, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    titulo,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSlate,
                      fontWeight: FontWeight.bold,
                      fontSize: 17.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Section body text with large adult typography (>= 16sp)
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              contenido,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.5,
                height: 1.6,
                color: AppTheme.textSlate,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
