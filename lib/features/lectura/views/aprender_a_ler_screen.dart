import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/repositories/content_repository.dart';
import '../../cuentos/views/cuentos_list_screen.dart';
import 'alphabot_screen.dart';
import 'phonix_quest_screen.dart';

/// Hub de Aprender a Ler e Alfabetización Temperá.
class AprenderALerScreen extends StatelessWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const AprenderALerScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final lang = initialLanguage;

    final List<Map<String, dynamic>> items = [
      {
        'title': lang == AppLanguage.gl
            ? 'Alphabot · Mesa Manipulativa'
            : 'Alphabot · Mesa Manipulativa',
        'subtitle': lang == AppLanguage.gl
            ? 'Construción de palabras con letras reais de madeira ou imáns'
            : 'Construcción de palabras con letras reales de madera o imanes',
        'icon': Icons.extension,
        'color': Colors.amber.shade800,
        'bg': Colors.amber.shade50,
        'builder': (BuildContext ctx) => AlphabotScreen(
              language: lang,
              audioService: audioService,
            ),
      },
      {
        'title': lang == AppLanguage.gl
            ? 'Phonix Quest · Fonemas'
            : 'Phonix Quest · Fonemas',
        'subtitle': lang == AppLanguage.gl
            ? 'Guía de articulación e discriminación auditiva dos 44 fonemas'
            : 'Guía de articulación y discriminación auditiva de los 44 fonemas',
        'icon': Icons.graphic_eq,
        'color': Colors.purple,
        'bg': Colors.purple.shade50,
        'builder': (BuildContext ctx) => PhonixQuestScreen(
              repository: repository,
              initialLanguage: lang,
              audioService: audioService,
            ),
      },
      {
        'title': lang == AppLanguage.gl
            ? 'Biblioteca de 200 Contos'
            : 'Biblioteca de 200 Cuentos',
        'subtitle': lang == AppLanguage.gl
            ? 'Lectura dialóxica compartida con preguntas graduadas por nivel'
            : 'Lectura dialógica compartida con preguntas graduadas por nivel',
        'icon': Icons.auto_stories,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => CuentosListScreen(
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
          lang == AppLanguage.gl ? 'Aprender a Ler' : 'Aprender a Leer',
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
              gradient: LinearGradient(
                colors: [Colors.teal.shade600, Colors.teal.shade800],
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
                    Icon(Icons.auto_stories, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'ALFABETIZACIÓN TEMPERÁ',
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
                      ? 'Lectura Manipulativa e Fonética'
                      : 'Lectura Manipulativa y Fonética',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lang == AppLanguage.gl
                      ? 'A aprendizaxe da lectoescritura comeza nas mans e no oído. Sen pantallas táctiles para os nenos.'
                      : 'El aprendizaje de la lectoescritura empieza en las manos y en el oído. Sin pantallas táctiles para los niños.',
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

          ...items.map((m) {
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
                      const Icon(Icons.chevron_right, color: Colors.grey),
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
