import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Fase 3: Reto Núcleo TPR en L3 (270 segundos = 4:30 min).
///
/// Características pedagóxicas:
/// - Comandos L3 en tipografía ampla (>= 24sp) para lectura a distancia polo docente.
/// - Indicacións de modelado docente diferenciado (sincrónico, fading a 2s, autonomía motriz).
/// - Soporte específico para xogos de freada rápida / freeze (5.º Infantil)
///   e tarxetas icónicas entre iguais (6.º Infantil).
/// - Botón táctil amplo (>= 64dp) para escoita modelo en audio offline.
class PasoCoreTprWidget extends StatelessWidget {
  final FaseAsamblea fase;
  final AppLanguage language;
  final MetodologiaTPR metodologia;
  final Function(String audioAsset)? onPlayCommandAudio;
  final String? currentlyPlayingAsset;
  final VoidCallback? onStopAudio;

  const PasoCoreTprWidget({
    super.key,
    required this.fase,
    required this.language,
    required this.metodologia,
    this.onPlayCommandAudio,
    this.currentlyPlayingAsset,
    this.onStopAudio,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final titulo = fase.titulo.resolve(language);
    final consigna = fase.consignaDocente.resolve(language);
    final isDramatizado = metodologia == MetodologiaTPR.dramatizadoNarrativo;
    final isTransaccional =
        metodologia == MetodologiaTPR.transaccionalPragmatico;

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
                    Icons.directions_run_rounded,
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

        // Distintivo de Metodoloxía Pedagóxica TPR
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: AppTheme.backstageAccent.withValues(alpha: 0.4),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    color: AppTheme.backstageAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      metodologia.nombre.resolve(language),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.backstageAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _getMetodologiaExplicacion(isGl),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.backstageTextSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Indicador específico de Inhibición / Freeze (5.º de Infantil)
        if (isDramatizado) ...[
          Container(
            key: const ValueKey('freeze_signal_indicator'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backstageWarning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: AppTheme.backstageWarning,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.front_hand_rounded,
                  color: AppTheme.backstageWarning,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl
                            ? 'Sinal de Inhibición: FREEZE!'
                            : 'Señal de Inhibición: ¡FREEZE!',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.backstageWarning,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGl
                            ? 'Ao escoitar «FREEZE!», os escolares deteñen o movemento en seco coma estatuas. Fomentar o control inhibitorio sen reprobacións verbais.'
                            : 'Al escuchar «¡FREEZE!», los escolares detienen el movimiento en seco como estatuas. Fomentar el control inhibitorio sin reproches verbales.',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.backstageTextPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Indicador específico de Tarxetas Cue Cards entre Iguais (6.º de Infantil)
        if (isTransaccional) ...[
          Container(
            key: const ValueKey('cue_cards_indicator'),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backstageAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: AppTheme.backstageAccent,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.style_rounded,
                  color: AppTheme.backstageAccent,
                  size: 32,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl
                            ? 'Tarxetas Icónicas Cue Cards (Sen Texto)'
                            : 'Tarjetas Icónicas Cue Cards (Sin Texto)',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.backstageAccent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isGl
                            ? 'O intercambio faise por parellas mediante tarxetas visuais sen palabras escritas. Un compañeiro guía e o outro realiza a acción motriz.'
                            : 'El intercambio se realiza por parejas mediante tarjetas visuales sin palabras escritas. Un compañero guía y el otro realiza la acción motriz.',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.backstageTextPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Consigna pedagóxica do docente
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurface,
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
                  Text(
                    isGl
                        ? 'Pauta Xeral para o Docente'
                        : 'Pauta General para el Docente',
                    style: const TextStyle(
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
                  fontSize: 17.0,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.backstageTextPrimary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Título de Comandos L3
        Row(
          children: [
            const Icon(
              Icons.record_voice_over_rounded,
              color: AppTheme.backstageAccent,
              size: 22,
            ),
            const SizedBox(width: 8),
            Text(
              isGl ? 'Comandos de Acción en L3' : 'Comandos de Acción en L3',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.backstageTextPrimary,
              ),
            ),
            const Spacer(),
            Text(
              '${fase.comandosL3.length} ${isGl ? 'comandos' : 'comandos'}',
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.backstageTextMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Lista de Comandos TPR
        ...List.generate(fase.comandosL3.length, (index) {
          final cmd = fase.comandosL3[index];
          final isPlayingThis =
              cmd.audioAsset != null && currentlyPlayingAsset == cmd.audioAsset;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.backstageSurfaceElevated,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(
                color: isPlayingThis
                    ? AppTheme.backstageAccent
                    : AppTheme.backstageBorder,
                width: isPlayingThis ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Fila superior: número de comando e botón de audio
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.backstageAccent.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                      ),
                      child: Text(
                        'COMANDO ${index + 1}',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.backstageAccent,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (cmd.audioAsset != null &&
                        cmd.audioAsset!.isNotEmpty &&
                        onPlayCommandAudio != null)
                      SizedBox(
                        height: 48,
                        child: ElevatedButton.icon(
                          key: ValueKey('play_tpr_audio_${cmd.id}'),
                          onPressed: () {
                            if (isPlayingThis) {
                              onStopAudio?.call();
                            } else {
                              onPlayCommandAudio!(cmd.audioAsset!);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPlayingThis
                                ? AppTheme.backstageWarning
                                : AppTheme.backstageAccent,
                            foregroundColor: AppTheme.backstageBg,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusButton,
                              ),
                            ),
                          ),
                          icon: Icon(
                            isPlayingThis
                                ? Icons.stop_rounded
                                : Icons.volume_up_rounded,
                            size: 22,
                          ),
                          label: Text(
                            isPlayingThis
                                ? (isGl ? 'Deter' : 'Detener')
                                : (isGl ? 'Escoitar' : 'Escuchar'),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.backstageSurfaceElevated,
                          borderRadius: BorderRadius.circular(
                            AppTheme.radiusField,
                          ),
                          border: Border.all(color: AppTheme.backstageBorder),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.record_voice_over_rounded,
                              size: 16,
                              color: AppTheme.backstageAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isGl ? 'Voz docente' : 'Voz docente',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.backstageAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // Texto do comando en L3 (inglés) >= 24sp
                Text(
                  cmd.textoIngles,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 26.0,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.backstageTextPrimary,
                    height: 1.25,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 16),

                // Acción física esperada
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backstageSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.accessibility_new_rounded,
                        color: AppTheme.backstageAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGl
                                  ? 'Acción motriz esperada:'
                                  : 'Acción motriz esperada:',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.backstageAccent,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cmd.accionFisica.resolve(language),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.backstageTextPrimary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Pauta de modelado docente
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.backstageSurface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.model_training_rounded,
                        color: AppTheme.star,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isGl
                                  ? 'Pauta de modelado docente:'
                                  : 'Pauta de modelado docente:',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.star,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              cmd.modeladoDocente.resolve(language),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                color: AppTheme.backstageTextSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  String _getMetodologiaExplicacion(bool isGl) {
    return switch (metodologia) {
      MetodologiaTPR.accionExpandida => isGl
          ? 'Comandos coordenados con "and", andamiaxe decrecente con modelado sincrónico inicial, fading a 2 segundos e respecto estrito ao período de silencio fónico.'
          : 'Comandos coordinados con "and", andamiaje decreciente con modelado sincrónico inicial, fading a 2 segundos y respeto estricto al período de silencio fónico.',
      MetodologiaTPR.dramatizadoNarrativo => isGl
          ? 'Micro-narrativa de causa-efecto físico, movementos corporais pesados ou lixeiros e freada postural inmediata ante o sinal sintáctico «FREEZE!». Cero penalizacións.'
          : 'Micro-narrativa de causa-efecto físico, movimientos corporales pesados o ligeros y frenada postural inmediata ante la señal sintáctica «¡FREEZE!». Cero penalizaciones.',
      MetodologiaTPR.transaccionalPragmatico => isGl
          ? 'Dinámica cooperativa entre iguais (peer-to-peer) mediante tarxetas icónicas sen texto escrito, fórmulas pragmáticas de cortesía e orientación espacial.'
          : 'Dinámica cooperativa entre iguales (peer-to-peer) mediante tarjetas visuales sin palabras escritas. Un compañero guía y el otro realiza la acción motriz.',
    };
  }
}
