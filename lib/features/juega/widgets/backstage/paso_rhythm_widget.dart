import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/audio/offline_audio_service.dart';
import '../../../../core/audio/voice_id.dart';
import '../../../../core/audio/widgets/boton_escuchar.dart';
import '../../../../core/brand/lamina_vector.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Fase 2: Foco Rítmico e Movemento (120 segundos = 2:00 min).
///
/// Características pedagóxicas:
/// - Sincronización psicomotriz e proprioceptiva a 72 BPM constante.
/// - Praxias orofaciais e rimas dactilares coordinadas.
/// - Cero esixencia de verbalización sonora en L3.
class PasoRhythmWidget extends StatelessWidget {
  final FaseAsamblea fase;
  final AppLanguage language;

  /// Para el altavoz de la consigna y del inglés. Sin él la fase se lee
  /// pero no se escucha, que es como nació este módulo.
  final OfflineAudioService? audioService;
  final VoidCallback? onTogglePulse;
  final bool isPulsePlaying;

  const PasoRhythmWidget({
    super.key,
    required this.fase,
    required this.language,
    this.audioService,
    this.onTogglePulse,
    this.isPulsePlaying = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final titulo = fase.titulo.resolve(language);
    final consigna = fase.consignaDocente.resolve(language);
    final cueText = fase.cueAcustica ?? 'Pulse 72 BPM';

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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
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
                  const Icon(
                    Icons.music_note_rounded,
                    color: AppTheme.backstageAccent,
                    size: 26,
                  ),
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
              Row(
                children: [
                  const Icon(
                    Icons.record_voice_over_outlined,
                    color: AppTheme.backstageAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    isGl
                        ? 'Consigna para o Docente'
                        : 'Consigna para el Docente',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.backstageAccent,
                    ),
                  )),
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
              BotonEscuchar(
                audioService: audioService,
                texto: consigna,
                language: language,
                compacto: true,
                descripcion: isGl
                    ? 'a consigna do foco rítmico'
                    : 'la consigna del foco rítmico',
              ),
              if (cueText.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: BotonEscuchar(
                      audioService: audioService,
                      texto: cueText,
                      language: AppLanguage.en,
                      style: estiloIngles(cueText),
                      compacto: true,
                      descripcion:
                          isGl ? 'o sinal en inglés' : 'la señal en inglés',
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Pulso rítmico a 72 BPM
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: isPulsePlaying
                  ? AppTheme.backstageAccent
                  : AppTheme.backstageBorder,
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isPulsePlaying
                          ? AppTheme.backstageAccent.withValues(alpha: 0.2)
                          : AppTheme.backstageSurfaceElevated,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPulsePlaying
                          ? Icons.graphic_eq_rounded
                          : Icons.speed_rounded,
                      color: isPulsePlaying
                          ? AppTheme.backstageAccent
                          : AppTheme.backstageTextSecondary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isGl
                              ? 'Pulso Rítmico de Referencia: 72 BPM'
                              : 'Pulso Rítmico de Referencia: 72 BPM',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.backstageTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isGl
                              ? 'Sinal acústico: «$cueText»'
                              : 'Señal acústica: «$cueText»',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.backstageTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: const ValueKey('play_rhythm_pulse_button'),
                  onPressed: onTogglePulse,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPulsePlaying
                        ? AppTheme.backstageWarning
                        : AppTheme.backstageAccent,
                    foregroundColor: AppTheme.backstageBg,
                    minimumSize: const Size.fromHeight(56),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  icon: Icon(
                    isPulsePlaying
                        ? Icons.stop_rounded
                        : Icons.play_arrow_rounded,
                    size: 28,
                  ),
                  label: Text(
                    isPulsePlaying
                        ? (isGl
                            ? 'Deter Pulso Rítmico'
                            : 'Detener Pulso Rítmico')
                        : (isGl
                            ? 'Activar Pulso 72 BPM'
                            : 'Activar Pulso 72 BPM'),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Praxias Orofaciais e Rimas Dactilares
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: AppTheme.backstageBorder,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.face_retouching_natural_rounded,
                    color: AppTheme.backstageAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                    isGl
                        ? 'Praxias Orofaciais e Rimas Dactilares'
                        : 'Praxias Orofaciales y Rimas Dactilares',
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.backstageAccent,
                    ),
                  )),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                isGl
                    ? 'Acompañar o pulso con movementos coordinados de lingua, beizos e xestos cos dedos. A docente modela o movemento sen esixir emisión verbal sonora. Sincronía visual e motriz.'
                    : 'Acompañar el pulso con movimientos coordinados de lengua, labios y gestos con los dedos. La docente modela el movimiento sin exigir emisión verbal sonora. Sincronía visual y motriz.',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.backstageTextSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
