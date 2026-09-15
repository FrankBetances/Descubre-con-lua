import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Fase 1: Apertura e Saúdo no Círculo (90 segundos = 1:30 min).
class PasoOpeningWidget extends StatelessWidget {
  final FaseAsamblea fase;
  final AppLanguage language;
  final VoidCallback? onPlayCue;
  final bool isPlayingCue;

  const PasoOpeningWidget({
    super.key,
    required this.fase,
    required this.language,
    this.onPlayCue,
    this.isPlayingCue = false,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = fase.titulo.resolve(language);
    final consigna = fase.consignaDocente.resolve(language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeceira da fase
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.backstageBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.backstageAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    ),
                    child: const Text(
                      'FASE 1 · 90s',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.backstageAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.wb_sunny_rounded, color: AppTheme.star, size: 24),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 24.0,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.backstageTextPrimary,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Consigna pedagóxica do docente
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.backstageBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.record_voice_over_outlined, color: AppTheme.backstageAccent, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Consigna para o Docente',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.backstageAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                consigna,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.backstageTextPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pista acústica / Saúdo condicionado
        if (fase.cueAcustica != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backstageSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.backstageAccent.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sinal Sonoro de Transición (Cue)',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.backstageTextMuted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '«${fase.cueAcustica}»',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.backstageTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onPlayCue != null)
                  ElevatedButton.icon(
                    key: const ValueKey('play_opening_cue_button'),
                    onPressed: onPlayCue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.backstageAccent,
                      foregroundColor: AppTheme.backstageBg,
                      minimumSize: const Size(120, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                    icon: Icon(isPlayingCue ? Icons.pause_rounded : Icons.play_arrow_rounded),
                    label: Text(
                      isPlayingCue ? 'Pausar' : 'Tocar',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
