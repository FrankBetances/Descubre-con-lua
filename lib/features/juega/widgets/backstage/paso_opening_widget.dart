import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/audio/offline_audio_service.dart';
import '../../../../core/audio/voice_id.dart';
import '../../../../core/audio/widgets/boton_escuchar.dart';
import '../../../../core/brand/lamina_vector.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Fase 1: Apertura e Saúdo no Círculo (90 segundos = 1:30 min).
class PasoOpeningWidget extends StatelessWidget {
  final FaseAsamblea fase;
  final AppLanguage language;

  /// Para el altavoz de la consigna y del inglés. Sin él la fase se lee
  /// pero no se escucha, que es como nació este módulo.
  final OfflineAudioService? audioService;
  final VoidCallback? onPlayCue;
  final bool isPlayingCue;

  const PasoOpeningWidget({
    super.key,
    required this.fase,
    required this.language,
    this.audioService,
    this.onPlayCue,
    this.isPlayingCue = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final titulo = fase.titulo.resolve(language);
    final hasAudio = fase.audioAsset != null && fase.audioAsset!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Cabeceira da fase
        // La lámina de la fase: la asamblea eran cuatro pantallas de prosa
        // seguidas, sin una sola imagen.
        if (fase.lamina.isNotEmpty) ...[
          Center(
            child: LaminaEscena(clave: fase.lamina, ancho: 128),
          ),
          const SizedBox(height: 16),
        ],
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.backstageAccent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    ),
                    child: Text(
                      'FASE ${fase.orden} · ${fase.duracionSegundos}s',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.backstageAccent,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.wb_sunny_rounded,
                      color: AppTheme.star, size: 24),
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
        // Pista acústica / Saúdo condicionado
        if (fase.cueAcustica != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backstageSurface,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                  color: AppTheme.backstageAccent.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl
                            ? 'Sinal Sonoro de Transición (Cue)'
                            : 'Señal Sonora de Transición (Cue)',
                        style: const TextStyle(
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
                // El cue es inglés: aquí se oye cómo suena antes de decirlo.
                BotonEscuchar(
                  audioService: audioService,
                  texto: fase.cueAcustica ?? '',
                  language: AppLanguage.en,
                  style: estiloIngles(fase.cueAcustica ?? ''),
                  compacto: true,
                  descripcion:
                      isGl ? 'o sinal en inglés' : 'la señal en inglés',
                ),
                const SizedBox(height: 8),
                if (hasAudio && onPlayCue != null)
                  ElevatedButton.icon(
                    key: const ValueKey('play_opening_cue_button'),
                    onPressed: onPlayCue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPlayingCue
                          ? AppTheme.backstageWarning
                          : AppTheme.backstageAccent,
                      foregroundColor: AppTheme.backstageBg,
                      minimumSize: const Size(120, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                    icon: Icon(isPlayingCue
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded),
                    label: Text(
                      isPlayingCue
                          ? (isGl ? 'Deter' : 'Detener')
                          : (isGl ? 'Escoitar' : 'Escuchar'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                else
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.backstageSurfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                      border: Border.all(color: AppTheme.backstageBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.record_voice_over_rounded,
                          size: 18,
                          color: AppTheme.backstageAccent,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isGl ? 'Voz docente' : 'Voz docente',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.backstageAccent,
                          ),
                        ),
                      ],
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
