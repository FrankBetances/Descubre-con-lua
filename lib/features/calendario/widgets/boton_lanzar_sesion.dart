import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Botón principal de lanzamento a 1 toque da sesión recomendada.
///
/// Altura accesible de 52dp (superior ao mínimo de 48dp de Android),
/// con iconografía clara e contraste óptico para o uso no aula e no fogar.
class BotonLanzarSesion extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  const BotonLanzarSesion({
    super.key,
    required this.label,
    this.icon = Icons.play_circle_filled_rounded,
    required this.backgroundColor,
    this.foregroundColor = Colors.white,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 24),
        label: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
      ),
    );
  }
}
