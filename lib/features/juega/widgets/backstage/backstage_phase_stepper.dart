import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Stepper horizontal das 4 fases canónicas da asemblea matinal.
class BackstagePhaseStepper extends StatelessWidget {
  final int faseActivaIndex; // 0..3
  final ValueChanged<int> onFaseSelected;

  const BackstagePhaseStepper({
    super.key,
    required this.faseActivaIndex,
    required this.onFaseSelected,
  });

  static const _titulosFases = [
    '1. Apertura (1:30)',
    '2. Foco Rítmico (2:00)',
    '3. Reto TPR (4:30)',
    '4. Calma (2:00)',
  ];

  static const _iconosFases = [
    Icons.wb_sunny_outlined,
    Icons.music_note_outlined,
    Icons.directions_run_outlined,
    Icons.spa_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(4, (index) {
          final isCurrent = index == faseActivaIndex;
          final isDone = index < faseActivaIndex;

          final Color bgColor = isCurrent
              ? AppTheme.backstageAccent.withValues(alpha: 0.15)
              : (isDone
                  ? AppTheme.backstageSurfaceElevated
                  : AppTheme.backstageSurface);

          final Color borderColor = isCurrent
              ? AppTheme.backstageAccent
              : (isDone
                  ? AppTheme.backstageAccent.withValues(alpha: 0.4)
                  : AppTheme.backstageBorder);

          final Color textColor = isCurrent
              ? AppTheme.backstageAccent
              : (isDone
                  ? AppTheme.backstageTextPrimary
                  : AppTheme.backstageTextSecondary);

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: InkWell(
              key: ValueKey('stepper_phase_button_$index'),
              onTap: () => onFaseSelected(index),
              borderRadius: BorderRadius.circular(AppTheme.radiusField),
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isDone ? Icons.check_circle : _iconosFases[index],
                      color: isCurrent
                          ? AppTheme.backstageAccent
                          : (isDone ? AppTheme.backstageAccent : AppTheme.backstageTextMuted),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _titulosFases[index],
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15.0,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
