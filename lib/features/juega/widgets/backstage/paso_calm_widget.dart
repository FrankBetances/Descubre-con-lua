import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Fase 4: Calma e Transición (120 segundos = 2:00 min).
///
/// Características pedagóxicas:
/// - Desaceleración psicomotriz progresiva e respiración diafragmática fonda.
/// - Exploración sensorial con materiais analóxicos da contorna natural galega
///   (gasas de algodón, claves de castiñeiro, cunchas de vieira).
/// - Avisos de seguridade estritos (dimensións >= 4 cm, sen arestas cortantes).
/// - Transición serena e ordenada cara aos recantos de traballo na aula.
class PasoCalmWidget extends StatelessWidget {
  final FaseAsamblea fase;
  final AppLanguage language;
  final VoidCallback? onPlayCalmAudio;
  final bool isPlayingCalmAudio;

  const PasoCalmWidget({
    super.key,
    required this.fase,
    required this.language,
    this.onPlayCalmAudio,
    this.isPlayingCalmAudio = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final titulo = fase.titulo.resolve(language);
    final consigna = fase.consignaDocente.resolve(language);
    final hasMaterials = fase.repertorioMateriales.isNotEmpty;

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
                    child: const Text(
                      'FASE 4 · 120s',
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
                  const Icon(
                    Icons.spa_rounded,
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
                  Text(
                    isGl ? 'Consigna para o Docente' : 'Consigna para el Docente',
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
        const SizedBox(height: 16),

        // Pauta de respiración e desaceleración somática
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backstageSurface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: AppTheme.backstageAccent.withValues(alpha: 0.3),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.backstageAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.air_rounded,
                  color: AppTheme.backstageAccent,
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
                          ? 'Desaceleración e Respiración Diafragmática'
                          : 'Desaceleración y Respiración Diafragmática',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.backstageTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGl
                          ? 'Inspirar fondo en silencio / Espirar con suave sopro. Postura de acougo con pernas cruzadas.'
                          : 'Inspirar hondo en silencio / Espirar con suave soplido. Postura de calma con piernas cruzadas.',
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
        ),
        const SizedBox(height: 20),

        // Repertorio de Materiais Naturais da Contorna Galega
        if (hasMaterials) ...[
          Row(
            children: [
              const Icon(
                Icons.forest_rounded,
                color: AppTheme.backstageAccent,
                size: 22,
              ),
              const SizedBox(width: 8),
              Text(
                isGl
                    ? 'Materiais Naturais da Contorna'
                    : 'Materiales Naturales del Entorno',
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.backstageTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...fase.repertorioMateriales.map((mat) {
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.backstageSurfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.backstageBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do material
                  Row(
                    children: [
                      const Icon(
                        Icons.eco_rounded,
                        color: AppTheme.backstageAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mat.nombre.resolve(language),
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.backstageTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Procedencia galega
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📍 ',
                        style: TextStyle(fontSize: 14),
                      ),
                      Expanded(
                        child: Text(
                          '${isGl ? 'Procedencia:' : 'Procedencia:'} ${mat.procedencia.resolve(language)}',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.backstageTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Pauta de manipulación sensorial
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
                          Icons.touch_app_rounded,
                          color: AppTheme.backstageAccent,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            mat.pautaManipulacion.resolve(language),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.backstageTextPrimary,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Aviso de seguridade obrigatorio
                  if (mat.avisoSeguridad != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backstageWarning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTheme.radiusField),
                        border: Border.all(
                          color: AppTheme.backstageWarning.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: AppTheme.backstageWarning,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isGl
                                      ? 'Aviso de Seguridade (>= 4 cm):'
                                      : 'Aviso de Seguridad (>= 4 cm):',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.backstageWarning,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  mat.avisoSeguridad!.resolve(language),
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13,
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
                  ],
                ],
              ),
            );
          }),
        ],

        // Botón opcional de audio de calma (só se hai audioAsset dispoñible)
        if (fase.audioAsset != null &&
            fase.audioAsset!.isNotEmpty &&
            onPlayCalmAudio != null) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const ValueKey('play_calm_audio_button'),
              onPressed: onPlayCalmAudio,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPlayingCalmAudio
                    ? AppTheme.backstageWarning
                    : AppTheme.backstageSurfaceElevated,
                foregroundColor: isPlayingCalmAudio
                    ? AppTheme.backstageBg
                    : AppTheme.backstageTextPrimary,
                side: const BorderSide(color: AppTheme.backstageBorder),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
              icon: Icon(
                isPlayingCalmAudio
                    ? Icons.stop_rounded
                    : Icons.volume_up_rounded,
              ),
              label: Text(
                isPlayingCalmAudio
                    ? (isGl ? 'Deter Son de Calma' : 'Detener Sonido de Calma')
                    : (isGl ? 'Reproducir Sons da Fraga / Calma' : 'Reproducir Sonidos del Bosque / Calma'),
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
