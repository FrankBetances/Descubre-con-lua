import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Phase 3: Graded scaffolding questions for levels 1, 2, and 3 with pedagogical hints.
///
/// Implements early childhood developmental questioning:
/// - Level 1: Pointing & visual recognition (Sinalar / Identificación visual)
/// - Level 2: Naming & onomatopoeia (Nomear / Onomatopeia)
/// - Level 3: Causal links & everyday experience (Causa-efecto / Relación cotiá)
class PasoPreguntasWidget extends StatelessWidget {
  final List<PreguntaNivel> preguntas;
  final AppLanguage language;

  /// Sin él no hay botón de escuchar en las preguntas.
  final OfflineAudioService? audioService;

  const PasoPreguntasWidget({
    super.key,
    required this.preguntas,
    required this.language,
    this.audioService,
  });

  String _levelTitle(int nivel, bool isGl) {
    switch (nivel) {
      case 1:
        return isGl
            ? 'Nivel 1: Sinalar e identificación visual'
            : 'Nivel 1: Señalar e identificación visual';
      case 2:
        return isGl
            ? 'Nivel 2: Nomear e onomatopeias'
            : 'Nivel 2: Nombrar y onomatopeyas';
      case 3:
        return isGl
            ? 'Nivel 3: Causa-efecto e experiencia cotiá'
            : 'Nivel 3: Causa-efecto y experiencia cotidiana';
      default:
        return isGl ? 'Nivel $nivel' : 'Nivel $nivel';
    }
  }

  Color _levelColor(int nivel) {
    switch (nivel) {
      case 1:
        return AppTheme.primaryVigoBlue;
      case 2:
        return AppTheme.secondarySeaGlass;
      case 3:
        return AppTheme.accentTerracotta;
      default:
        return AppTheme.primaryVigoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = language == AppLanguage.gl;

    // Ensure sorted by level 1, 2, 3
    final sortedPreguntas = List<PreguntaNivel>.from(preguntas)
      ..sort((a, b) => a.nivel.compareTo(b.nivel));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title & pedagogical note
        Text(
          isGl
              ? 'Preguntas graduadas para a asemblea'
              : 'Preguntas graduadas para la asamblea',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryVigoBlue,
            fontSize: 22.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          isGl
              ? 'Andamiaxe pedagóxico en 3 niveis adaptado aos diferentes ritmos madurativos do grupo 0-3 anos.'
              : 'Andamiaje pedagógico en 3 niveles adaptado a los diferentes ritmos madurativos del grupo 0-3 años.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF4A5568),
            fontSize: 16.0,
          ),
        ),
        const SizedBox(height: 20.0),

        // Cards for each level
        ...sortedPreguntas.map((p) {
          final levelColor = _levelColor(p.nivel);
          final levelTitle = _levelTitle(p.nivel, isGl);

          return Card(
            margin: const EdgeInsets.only(bottom: 18.0),
            color: AppTheme.cardSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: levelColor.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Level Header
                  // Flexible: «Nivel 3: Causa-efecto e experiencia cotiá» no
                  // cabe en una pastilla de una línea en 360 dp. Desbordaba
                  // 300 px y en release solo se veía el texto cortado.
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: levelColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            levelTitle,
                            maxLines: 2,
                            style: TextStyle(
                              color: levelColor == AppTheme.secondarySeaGlass
                                  ? const Color(0xFF1B6A7F)
                                  : levelColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Question
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          p.enunciado.resolve(language),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 17.5,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSlate,
                            height: 1.35,
                          ),
                        ),
                      ),
                      BotonEscuchar(
                        audioService: audioService,
                        texto: p.enunciado.resolve(language),
                        language: language,
                        compacto: true,
                        descripcion: isGl ? 'a pregunta' : 'la pregunta',
                      ),
                    ],
                  ),
                  const SizedBox(height: 14.0),

                  // Expected toddler response
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.subdirectory_arrow_right,
                          color: Color(0xFF475569),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16.0,
                                color: AppTheme.textSlate,
                              ),
                              children: [
                                TextSpan(
                                  text: isGl
                                      ? 'Resposta esperada: '
                                      : 'Respuesta esperada: ',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: p.respuestaSugerida.resolve(language),
                                  style: const TextStyle(
                                      fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BotonEscuchar(
                          audioService: audioService,
                          texto: p.respuestaSugerida.resolve(language),
                          language: language,
                          compacto: true,
                          descripcion: isGl
                              ? 'a resposta esperada'
                              : 'la respuesta esperada',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10.0),

                  // Teacher pedagogical tip
                  Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFAF7EE),
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: const Color(0xFFDFD7BE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          color: AppTheme.primaryVigoBlue,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16.0,
                                color: AppTheme.textSlate,
                              ),
                              children: [
                                TextSpan(
                                  text: isGl
                                      ? 'Consello docente: '
                                      : 'Consejo docente: ',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryVigoBlue,
                                  ),
                                ),
                                TextSpan(
                                  text: p.consejoDocente.resolve(language),
                                ),
                              ],
                            ),
                          ),
                        ),
                        BotonEscuchar(
                          audioService: audioService,
                          texto: p.consejoDocente.resolve(language),
                          language: language,
                          compacto: true,
                          descripcion: isGl
                              ? 'o consello docente'
                              : 'el consejo docente',
                        ),
                      ],
                    ),
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
