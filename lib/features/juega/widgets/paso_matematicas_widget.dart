import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Phase 5: Early mathematics for 0-3 years (concepts of size, quantity, position).
///
/// Provides teacher guidance for:
/// - Core mathematical concepts (grande / pequeno, moito / pouco, dentro / fóra).
/// - Everyday classroom actions without worksheets.
/// - Mathematical vocabulary for early childhood language immersion.
class PasoMatematicasWidget extends StatelessWidget {
  final MatematicasTempras matematicas;
  final AppLanguage language;

  /// Sin él no hay botón de escuchar en las matemáticas tempranas.
  final OfflineAudioService? audioService;

  const PasoMatematicasWidget({
    super.key,
    required this.matematicas,
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
        // Title & Concept
        Row(
          children: [
            Expanded(
              child: Text(
                isGl
                    ? 'Matemáticas temperás (0-3)'
                    : 'Matemáticas tempranas (0-3)',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryVigoBlue,
                  fontSize: 22.0,
                ),
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: AppTheme.calmSage.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: AppTheme.calmSage, width: 1.5),
              ),
              child: Text(
                matematicas.concepto.resolve(language),
                style: const TextStyle(
                  color: Color(0xFF235A42),
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Description Card
        Card(
          color: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFD0D7DE), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calculate_outlined,
                      color: AppTheme.primaryVigoBlue,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isGl
                          ? 'Enfoque da actividade:'
                          : 'Enfoque de la actividad:',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryVigoBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                Text(
                  matematicas.descripcion.resolve(language),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16.0,
                    height: 1.55,
                    color: AppTheme.textSlate,
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: BotonEscuchar(
                    audioService: audioService,
                    texto: matematicas.descripcion.resolve(language),
                    language: language,
                    compacto: true,
                    descripcion: isGl ? 'a descrición' : 'la descripción',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Mathematical vocabulary box
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFF86EFAC), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.translate_outlined,
                color: Color(0xFF15803D),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl
                          ? 'Vocabulario matemático clave:'
                          : 'Vocabulario matemático clave:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF15803D),
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      matematicas.vocabularioMatematico.resolve(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // Suggested Actions List
        Text(
          isGl
              ? 'Accións manipulativas suxeridas:'
              : 'Acciones manipulativas sugeridas:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
          ),
        ),
        const SizedBox(height: 10.0),
        ...matematicas.accionesSugeridas.map((act) {
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
                  const Icon(
                    Icons.touch_app_outlined,
                    color: AppTheme.calmSage,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      act.resolve(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        height: 1.5,
                        color: AppTheme.textSlate,
                      ),
                    ),
                  ),
                  BotonEscuchar(
                    audioService: audioService,
                    texto: act.resolve(language),
                    language: language,
                    compacto: true,
                    descripcion:
                        isGl ? 'a acción suxerida' : 'la acción sugerida',
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
