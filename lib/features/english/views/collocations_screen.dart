import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/repositories/content_repository.dart';

/// Explorador de colocaciones y patrones sintácticos de inglés.
class CollocationsScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const CollocationsScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<CollocationsScreen> createState() => _CollocationsScreenState();
}

class _CollocationsScreenState extends State<CollocationsScreen> {
  late AppLanguage _language;

  static const List<Map<String, dynamic>> _collocations = [
    {
      'pattern': 'Verb + Noun (Actions)',
      'items': [
        {
          'en': 'wash hands',
          'gl': 'lavar as mans',
          'es': 'lavar las manos',
          'ex': 'Wash your hands before eating.'
        },
        {
          'en': 'brush teeth',
          'gl': 'lavar os dentes',
          'es': 'cepillarse los dientes',
          'ex': 'Brush your teeth twice a day.'
        },
        {
          'en': 'read a story',
          'gl': 'ler un conto',
          'es': 'leer un cuento',
          'ex': 'Let\'s read a story together.'
        },
        {
          'en': 'sing a song',
          'gl': 'cantar unha canción',
          'es': 'cantar una canción',
          'ex': 'Sing a happy song.'
        },
        {
          'en': 'open eyes',
          'gl': 'abrir os ollos',
          'es': 'abrir los ojos',
          'ex': 'Open your eyes and look!'
        },
      ]
    },
    {
      'pattern': 'Adjective + Noun (Sensory & Emotions)',
      'items': [
        {
          'en': 'warm milk',
          'gl': 'leite morno',
          'es': 'leche tibia',
          'ex': 'Drink warm milk at bedtime.'
        },
        {
          'en': 'soft blanket',
          'gl': 'manta suave',
          'es': 'manta suave',
          'ex': 'Sleep with a soft blanket.'
        },
        {
          'en': 'big smile',
          'gl': 'grande sorriso',
          'es': 'gran sonrisa',
          'ex': 'Give me a big smile!'
        },
        {
          'en': 'loud sound',
          'gl': 'son forte',
          'es': 'sonido fuerte',
          'ex': 'Listen to that loud sound.'
        },
      ]
    },
    {
      'pattern': 'Preposition + Noun (Spatial & Routine)',
      'items': [
        {
          'en': 'at school',
          'gl': 'na escola',
          'es': 'en la escuela',
          'ex': 'We are happy at school.'
        },
        {
          'en': 'at home',
          'gl': 'na casa',
          'es': 'en el hogar',
          'ex': 'Rest and relax at home.'
        },
        {
          'en': 'in the morning',
          'gl': 'pola mañá',
          'es': 'por la mañana',
          'ex': 'Wake up in the morning.'
        },
        {
          'en': 'at night',
          'gl': 'pola noite',
          'es': 'por la noche',
          'ex': 'Go to sleep at night.'
        },
      ]
    },
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Colocacións e Gramática'
              : 'Colocaciones y Gramática',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _collocations.length,
        itemBuilder: (context, catIndex) {
          final cat = _collocations[catIndex];
          final items = cat['items'] as List<Map<String, String>>;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  cat['pattern'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppTheme.primaryInk,
                  ),
                ),
              ),
              ...items.map((item) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['en']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                lang == AppLanguage.gl
                                    ? item['gl']!
                                    : item['es']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.primaryInk,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '"${item['ex']!}"',
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}
