import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Stepper horizontal das 4 fases canónicas da asemblea matinal.
class BackstagePhaseStepper extends StatelessWidget {
  final int faseActivaIndex; // 0..3
  final ValueChanged<int> onFaseSelected;

  /// Las fases de la asamblea que se está dando. El rótulo y los minutos salen
  /// de aquí y no de una lista escrita en el widget: si el JSON dice otra
  /// duración, el stepper decía una cosa y el cronómetro otra.
  final List<FaseAsamblea> fases;
  final AppLanguage language;

  const BackstagePhaseStepper({
    super.key,
    required this.faseActivaIndex,
    required this.onFaseSelected,
    this.fases = const [],
    this.language = AppLanguage.gl,
  });

  static const _iconosFases = [
    Icons.wb_sunny_outlined,
    Icons.music_note_outlined,
    Icons.directions_run_outlined,
    Icons.spa_outlined,
  ];

  /// Rótulo corto de la fase. Sale del modelo; si todavía no hay asamblea
  /// cargada, cae en el nombre canónico del tipo de fase.
  String _rotulo(int index) {
    if (index < fases.length) {
      return fases[index].tipo.nombre.resolve(language);
    }
    const canonicos = [
      TipoFaseAsamblea.aperturaSaudo,
      TipoFaseAsamblea.movementRhythmFocus,
      TipoFaseAsamblea.coreTprChallenge,
      TipoFaseAsamblea.calmaTransicion,
    ];
    return canonicos[index].nombre.resolve(language);
  }

  @override
  Widget build(BuildContext context) {
    // Cuatro segmentos que se reparten el ancho. Antes era un Row con scroll
    // horizontal y cada pastilla llevaba el título entero: la fila medía 1387 px
    // y en un móvil las fases 3 y 4 quedaban fuera de la pantalla, sin manera de
    // pulsarlas. Rehecha la pieza entera en vez de recortar el texto.
    // IntrinsicHeight: los cuatro segmentos miden lo mismo aunque un rótulo
    // parta en dos líneas y otro no. `stretch` a secas dentro de una Column sin
    // altura acotada pide altura infinita y revienta el layout.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 3 ? 0.0 : 6.0),
              child: InkWell(
                key: ValueKey('stepper_phase_button_$index'),
                onTap: () => onFaseSelected(index),
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 48),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    border: Border.all(
                        color: borderColor, width: isCurrent ? 2 : 1),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDone ? Icons.check_circle : _iconosFases[index],
                        color: isCurrent
                            ? AppTheme.backstageAccent
                            : (isDone
                                ? AppTheme.backstageAccent
                                : AppTheme.backstageTextMuted),
                        size: 20,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${index + 1}. ${_rotulo(index)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11.5,
                          fontWeight:
                              isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
