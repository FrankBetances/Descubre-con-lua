import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/phonics_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Motor de misións fonémicas e conciencia fonolóxica (Phonix Quest).
class PhonixQuestScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const PhonixQuestScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<PhonixQuestScreen> createState() => _PhonixQuestScreenState();
}

class _PhonixQuestScreenState extends State<PhonixQuestScreen> {
  PhonicsTaxonomy? _taxonomy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTaxonomy();
  }

  Future<void> _loadTaxonomy() async {
    setState(() => _isLoading = true);
    final tax = await widget.repository.loadPhonicsTaxonomy();
    if (mounted) {
      setState(() {
        _taxonomy = tax;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.initialLanguage;
    final phonemes = _taxonomy?.phonemes ?? [];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl ? 'Phonix Quest · Fonemas' : 'Phonix Quest · Fonemas',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Info Banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.mic, color: Colors.purple.shade700, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Guía de Articulación para Docentes e Nais/Pais'
                                  : 'Guía de Articulación para Docentes y Madres/Padres',
                              style: TextStyle(
                                color: Colors.purple.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Conciencia fonolóxica sintética: o adulto pronuncia o son e o neno imita sen pantallas.'
                                  : 'Conciencia fonológica sintética: el adulto pronuncia el sonido y el niño imita sin pantallas.',
                              style: TextStyle(
                                color: Colors.purple.shade800,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Phoneme Grid / List
                ...phonemes.map((ph) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0.5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                ph.symbolIpa,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade900,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Grafema: "${ph.grapheme.toUpperCase()}"',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        ph.category.replaceAll('_', ' '),
                                        style: TextStyle(
                                          color: Colors.grey.shade700,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Exemplo: ${ph.exampleWord.en} (${lang == AppLanguage.gl ? ph.exampleWord.gl : ph.exampleWord.es})',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.indigo.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ph.articulationGuide.resolve(lang),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
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
            ),
    );
  }
}
