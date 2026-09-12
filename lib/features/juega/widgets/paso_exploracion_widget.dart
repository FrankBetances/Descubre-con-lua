import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Phase 4: Sensory exploration with materials, steps, and prominent safety alert.
///
/// Designed with strict classroom safety standards:
/// - Prominent safety alert banner for manipulative materials (>4-5 cm and constant adult supervision).
/// - Sensory objectives aligned with Decreto 150/2022.
/// - Materials checklist and step-by-step facilitation guide.
class PasoExploracionWidget extends StatelessWidget {
  final ExploracionSensorial exploracion;
  final AppLanguage language;

  /// Sin él no hay botón de escuchar en la exploración sensorial.
  final OfflineAudioService? audioService;

  const PasoExploracionWidget({
    super.key,
    required this.exploracion,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = language == AppLanguage.gl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          exploracion.titulo.resolve(language),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
            fontSize: 22.0,
          ),
        ),
        const SizedBox(height: 16.0),

        // MANDATORY PROMINENT SAFETY ALERT CARD
        Container(
          padding: const EdgeInsets.all(18.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF4E5),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: AppTheme.accentTerracotta,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentTerracotta.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppTheme.accentTerracotta,
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isGl
                          ? '⚠️ PROTOCOLO DE SEGURIDADE NA AULA'
                          : '⚠️ PROTOCOLO DE SEGURIDAD EN EL AULA',
                      style: const TextStyle(
                        color: AppTheme.accentTerracotta,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      exploracion.avisoSeguridad.resolve(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: const Color(0xFF7A271A),
                      ),
                    ),
                  ),
                  BotonEscuchar(
                    audioService: audioService,
                    texto: exploracion.avisoSeguridad.resolve(language),
                    language: language,
                    compacto: true,
                    descripcion: isGl
                        ? 'o aviso de seguridade'
                        : 'el aviso de seguridad',
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6.0),
                  border: Border.all(
                      color: AppTheme.accentTerracotta.withValues(alpha: 0.4)),
                ),
                child: Text(
                  isGl
                      ? 'Requisito normativo: Pezas > 4-5 cm · Supervisión adulta continua'
                      : 'Requisito normativo: Piezas > 4-5 cm · Supervisión adulta continua',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentTerracotta,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // Sensory Objective Box
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F1F5),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFB8D3DF)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.center_focus_strong_outlined,
                color: AppTheme.primaryVigoBlue,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl ? 'Obxectivo sensorial:' : 'Objetivo sensorial:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryVigoBlue,
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exploracion.objetivoSensorial.resolve(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        height: 1.45,
                        color: AppTheme.textSlate,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BotonEscuchar(
                        audioService: audioService,
                        texto: exploracion.objetivoSensorial.resolve(language),
                        language: language,
                        compacto: true,
                        descripcion: isGl
                            ? 'o obxectivo sensorial'
                            : 'el objetivo sensorial',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // Materials List
        Text(
          isGl ? 'Materiais necesarios:' : 'Materiales necesarios:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
          ),
        ),
        const SizedBox(height: 10.0),
        Card(
          color: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14.0),
            side: const BorderSide(color: Color(0xFFE2DDD0)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: exploracion.materiales.map((m) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_box_outlined,
                        size: 20,
                        color: AppTheme.calmSage,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          m.resolve(language),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 16.0,
                            color: AppTheme.textSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Steps List
        Text(
          isGl ? 'Pasos da proposta:' : 'Pasos de la propuesta:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
          ),
        ),
        const SizedBox(height: 10.0),
        ...exploracion.pasos.asMap().entries.map((entry) {
          final idx = entry.key;
          final paso = entry.value;

          return Card(
            margin: const EdgeInsets.only(bottom: 12.0),
            color: AppTheme.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
              side: const BorderSide(color: Color(0xFFE2DDD0)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        AppTheme.primaryVigoBlue.withValues(alpha: 0.12),
                    child: Text(
                      '${idx + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                        color: AppTheme.primaryVigoBlue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      paso.resolve(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        height: 1.5,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ),
                  BotonEscuchar(
                    audioService: audioService,
                    texto: paso.resolve(language),
                    language: language,
                    compacto: true,
                    descripcion: isGl ? 'o paso' : 'el paso',
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
