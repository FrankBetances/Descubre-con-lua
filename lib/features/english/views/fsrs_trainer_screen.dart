import 'package:flutter/material.dart';

import '../../../core/fsrs_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/fsrs_card_model.dart';

/// Entrenador de vocabulario en inglés mediante algoritmo FSRS v4.5.
class FsrsTrainerScreen extends StatefulWidget {
  final AppLanguage language;

  const FsrsTrainerScreen({
    super.key,
    this.language = AppLanguage.gl,
  });

  @override
  State<FsrsTrainerScreen> createState() => _FsrsTrainerScreenState();
}

class _FsrsTrainerScreenState extends State<FsrsTrainerScreen> {
  final FsrsService _fsrs = const FsrsService();
  final List<FSRSCard> _deck = [];
  int _currentIndex = 0;
  bool _revealed = false;
  int _reviewsCount = 0;

  static const List<Map<String, String>> _sampleWords = [
    {
      'lemma': 'hello',
      'ipa': '/həˈloʊ/',
      'gl': 'ola',
      'es': 'hola',
      'example': 'Hello my friend!'
    },
    {
      'lemma': 'water',
      'ipa': '/ˈwɔːtər/',
      'gl': 'auga',
      'es': 'agua',
      'example': 'Drink some water.'
    },
    {
      'lemma': 'apple',
      'ipa': '/ˈæp.əl/',
      'gl': 'mazá',
      'es': 'manzana',
      'example': 'A sweet red apple.'
    },
    {
      'lemma': 'play',
      'ipa': '/pleɪ/',
      'gl': 'xogar',
      'es': 'jugar',
      'example': 'Let\'s play together.'
    },
    {
      'lemma': 'happy',
      'ipa': '/ˈhæp.i/',
      'gl': 'feliz',
      'es': 'feliz',
      'example': 'We are happy today.'
    },
    {
      'lemma': 'listen',
      'ipa': '/ˈlɪs.ən/',
      'gl': 'escoitar',
      'es': 'escuchar',
      'example': 'Listen to the music.'
    },
  ];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _sampleWords.length; i++) {
      _deck.add(_fsrs.createInitialFSRSCard(i + 1, _sampleWords[i]['lemma']!));
    }
  }

  void _gradeCard(int rating) {
    if (_deck.isEmpty || _currentIndex >= _deck.length) return;

    final current = _deck[_currentIndex];
    final updated = _fsrs.reviewFSRSCard(current, rating);

    setState(() {
      _deck[_currentIndex] = updated;
      _reviewsCount++;
      _revealed = false;
      _currentIndex = (_currentIndex + 1) % _deck.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final currentCard = _deck.isNotEmpty ? _deck[_currentIndex] : null;
    final currentWord = currentCard != null
        ? _sampleWords.firstWhere((w) => w['lemma'] == currentCard.lemma,
            orElse: () => _sampleWords.first)
        : null;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Adestrador FSRS (Repetición Espazada)'
              : 'Entrenador FSRS (Repetición Espaciada)',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stats Card
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(
                        'Tarxeta', '${_currentIndex + 1}/${_deck.length}'),
                    _buildStat('Repaso', '$_reviewsCount'),
                    if (currentCard != null) ...[
                      _buildStat('Estabilidade',
                          '${currentCard.stability.toStringAsFixed(1)}d'),
                      _buildStat('Dificultade',
                          '${currentCard.difficulty.toStringAsFixed(1)}/10'),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Flashcard
              Expanded(
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      setState(() => _revealed = !_revealed);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (currentWord != null) ...[
                            Text(
                              currentWord['lemma']!,
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              currentWord['ipa']!,
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.indigo.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_revealed) ...[
                              const Divider(),
                              const SizedBox(height: 16),
                              Text(
                                lang == AppLanguage.gl
                                    ? currentWord['gl']!
                                    : currentWord['es']!,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '"${currentWord['example']!}"',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.primaryInk,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ] else ...[
                              Text(
                                lang == AppLanguage.gl
                                    ? 'Pulsa para descubrir a tradución'
                                    : 'Pulsa para descubrir la traducción',
                                style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Rating Buttons
              if (_revealed)
                Row(
                  children: [
                    _buildGradeButton(1, 'Again', Colors.red.shade600),
                    const SizedBox(width: 8),
                    _buildGradeButton(2, 'Hard', Colors.orange.shade700),
                    const SizedBox(width: 8),
                    _buildGradeButton(3, 'Good', AppTheme.primary),
                    const SizedBox(width: 8),
                    _buildGradeButton(4, 'Easy', AppTheme.success),
                  ],
                )
              else
                ElevatedButton(
                  onPressed: () => setState(() => _revealed = true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    lang == AppLanguage.gl
                        ? 'Amosar Resposta'
                        : 'Mostrar Respuesta',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(String label, String val) {
    return Column(
      children: [
        Text(
          val,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeButton(int rating, String label, Color color) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _gradeCard(rating),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
