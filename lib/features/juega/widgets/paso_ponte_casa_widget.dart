import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Phase 6: Bridge to home (family communication and shared conversation topics).
///
/// Connects classroom activities with families:
/// - Family communication message draft.
/// - Recommended conversation topics for home pickup/dropoff.
/// - Suggested home activities reinforcing early language and sensory discovery.
class PasoPonteCasaWidget extends StatelessWidget {
  final PonteCasa ponteCasa;
  final AppLanguage language;
  final VoidCallback? onFinalizar;

  const PasoPonteCasaWidget({
    super.key,
    required this.ponteCasa,
    required this.language,
    this.onFinalizar,
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
          isGl
              ? 'Ponte á casa: Comunicación con familias'
              : 'Puente a casa: Comunicación con familias',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
            fontSize: 22.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          isGl
              ? 'Proposta para compartir coas familias o vivido hoxe na aula e reforzar o vínculo fogar-escola.'
              : 'Propuesta para compartir con las familias lo vivido hoy en el aula y reforzar el vínculo hogar-escuela.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4A5568),
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 20.0),

        // Family Message Box
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
                      Icons.mark_email_read_outlined,
                      color: AppTheme.primaryVigoBlue,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isGl
                            ? 'Mensaxe suxerida para o taboleiro ou caderno:'
                            : 'Mensaje sugerido para el tablón o cuaderno:',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryVigoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF7EE),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFDFD7BE)),
                  ),
                  child: Text(
                    ponteCasa.mensajeFamilias.resolve(language),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16.0,
                      height: 1.55,
                      color: AppTheme.textSlate,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20.0),

        // Conversation Recommendation Box
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFBFDBFE), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.chat_outlined,
                color: Color(0xFF1D4ED8),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl
                          ? 'Recomendación para a conversa no fogar:'
                          : 'Recomendación para la conversación en el hogar:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1D4ED8),
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ponteCasa.recomendacionConversacion.resolve(language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        height: 1.5,
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

        // Home Suggested Activities
        Text(
          isGl
              ? 'Actividades suxeridas para casa:'
              : 'Actividades sugeridas para casa:',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
          ),
        ),
        const SizedBox(height: 10.0),
        ...ponteCasa.actividadesSugeridas.map((act) {
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
                    Icons.home_outlined,
                    color: AppTheme.accentTerracotta,
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
                ],
              ),
            ),
          );
        }),

        if (onFinalizar != null) ...[
          const SizedBox(height: 24.0),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onFinalizar,
              icon: const Icon(Icons.check_circle_outline),
              label: Text(
                isGl ? 'Completar Asemblea' : 'Completar Asamblea',
                style: const TextStyle(
                    fontSize: 16.0, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryVigoBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
