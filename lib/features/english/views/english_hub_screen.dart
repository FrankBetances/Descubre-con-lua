import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/repositories/content_repository.dart';
import '../../palabras/views/palabras_8000_screen.dart';
import 'collocations_screen.dart';
import 'fsrs_trainer_screen.dart';
import 'listening_screen.dart';

/// Hub central del módulo de Inmersión en Inglés (L3).
class EnglishHubScreen extends StatelessWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const EnglishHubScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final lang = initialLanguage;

    final List<Map<String, dynamic>> modules = [
      {
        'title': lang == AppLanguage.gl
            // Sin el número de versión: el motor usa los pesos por defecto de
            // FSRS-4 con la curva de olvido de 4.5, así que llamarlo «v4.5» a
            // secas es más preciso de lo que el código sostiene.
            ? 'Adestrador de repetición espazada'
            : 'Entrenador de repetición espaciada',
        'subtitle': lang == AppLanguage.gl
            ? 'Repetición espazada baseada na curva de esquecemento DSR'
            : 'Repetición espaciada basada en la curva de olvido DSR',
        'icon': Icons.bolt,
        'color': AppTheme.warning,
        'bg': AppTheme.warningBg,
        'builder': (BuildContext ctx) => FsrsTrainerScreen(language: lang),
      },
      {
        'title': lang == AppLanguage.gl
            ? 'Comprensión Auditiva'
            : 'Comprensión Auditiva',
        'subtitle': lang == AppLanguage.gl
            ? 'Escoita dialóxica con resposta corporal motora (TPR)'
            : 'Escucha dialógica con respuesta corporal motora (TPR)',
        'icon': Icons.headphones,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => ListeningScreen(
              language: lang,
              audioService: audioService,
            ),
      },
      {
        'title': lang == AppLanguage.gl
            ? 'Colocacións e Gramática'
            : 'Colocaciones y Gramática',
        'subtitle': lang == AppLanguage.gl
            ? 'Patróns léxicos naturais verbo + substantivo para o fogar e aula'
            : 'Patrones léxicos naturales verbo + sustantivo para el hogar y aula',
        'icon': Icons.menu_book,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => CollocationsScreen(
              repository: repository,
              initialLanguage: lang,
              audioService: audioService,
            ),
      },
      {
        'title': lang == AppLanguage.gl
            ? 'Corpus 8.000 Palabras'
            : 'Corpus 8.000 Palabras',
        'subtitle': lang == AppLanguage.gl
            ? 'Explorador BNC/COCA por bandas de frecuencia 1k..8k, con nivel orientativo'
            : 'Explorador BNC/COCA por bandas de frecuencia 1k..8k, con nivel orientativo',
        'icon': Icons.search,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => Palabras8000Screen(
              repository: repository,
              initialLanguage: lang,
              audioService: audioService,
            ),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Inmersión en Inglés (L3)'
              : 'Inmersión en Inglés (L3)',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryInk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.language, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'INMERSIÓN EN INGLÉS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lang == AppLanguage.gl
                      ? 'Adquisición Natural e TPR'
                      : 'Adquisición Natural y TPR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lang == AppLanguage.gl
                      ? 'Metodoloxía comunicativa orientada ao adulto mediador con retos motores e sen exposición a pantallas infantís.'
                      : 'Metodología comunicativa orientada al adulto mediador con retos motores y sin exposición a pantallas infantiles.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...modules.map((m) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: m['builder'] as WidgetBuilder,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: m['bg'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          m['icon'] as IconData,
                          color: m['color'] as Color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
