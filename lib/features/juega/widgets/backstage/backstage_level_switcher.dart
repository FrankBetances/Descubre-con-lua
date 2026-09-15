import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Conmutador de nivel educativo para o Segundo Ciclo (4º, 5º, 6º de Infantil).
class BackstageLevelSwitcher extends StatelessWidget {
  final NivelEducativoSegundoCiclo nivelSeleccionado;
  final ValueChanged<NivelEducativoSegundoCiclo> onNivelChanged;
  final AppLanguage language;

  const BackstageLevelSwitcher({
    super.key,
    required this.nivelSeleccionado,
    required this.onNivelChanged,
    this.language = AppLanguage.gl,
  });

  @override
  Widget build(BuildContext context) {
    const niveis = [
      NivelEducativoSegundoCiclo.infantil4,
      NivelEducativoSegundoCiclo.infantil5,
      NivelEducativoSegundoCiclo.infantil6,
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backstageSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.backstageBorder, width: 1.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: niveis.map((nivel) {
          final label = nivel.etiquetaCorta.resolve(language);
          final sub = nivel.metodologiaPorDefecto.nombreCorto.resolve(language);
          final isSelected = nivel == nivelSeleccionado;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('level_switcher_${nivel.clave}'),
                  onTap: () => onNivelChanged(nivel),
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 48),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.backstageAccent
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14.0,
                            fontWeight:
                                isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? AppTheme.backstageBg
                                : AppTheme.backstageTextPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.backstageBg
                                : AppTheme.backstageTextMuted,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
