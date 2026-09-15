import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Conmutador de nivel educativo para o Segundo Ciclo (4º, 5º, 6º de Infantil).
class BackstageLevelSwitcher extends StatelessWidget {
  final NivelEducativoSegundoCiclo nivelSeleccionado;
  final ValueChanged<NivelEducativoSegundoCiclo> onNivelChanged;

  const BackstageLevelSwitcher({
    super.key,
    required this.nivelSeleccionado,
    required this.onNivelChanged,
  });

  @override
  Widget build(BuildContext context) {
    const niveis = [
      (NivelEducativoSegundoCiclo.infantil4, '4.º (3-4 anos)', 'Acción Expandida'),
      (NivelEducativoSegundoCiclo.infantil5, '5.º (4-5 anos)', 'Dramatizado / Freeze'),
      (NivelEducativoSegundoCiclo.infantil6, '6.º (5-6 anos)', 'Peer-to-Peer / P2P'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.backstageSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.backstageBorder, width: 1.5),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: niveis.map((item) {
          final nivel = item.$1;
          final label = item.$2;
          final sub = item.$3;
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
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.backstageAccent : Colors.transparent,
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
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? AppTheme.backstageBg : AppTheme.backstageTextPrimary,
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
                            color: isSelected ? AppTheme.backstageBg : AppTheme.backstageTextMuted,
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
