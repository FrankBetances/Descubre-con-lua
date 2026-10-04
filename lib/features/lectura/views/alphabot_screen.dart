import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/pasos_navegacion.dart';

/// Alphabot: Mesa de Lectura con Letras Manipulativas.
///
/// Propuesta sin pantallas infantiles: el adulto dispone letras de madera o imanes
/// en una mesa física, guiando la fonética articulada y la conciencia fonológica.
class AlphabotScreen extends StatefulWidget {
  final AppLanguage language;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const AlphabotScreen({
    super.key,
    this.language = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<AlphabotScreen> createState() => _AlphabotScreenState();
}

class _AlphabotScreenState extends State<AlphabotScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language = widget.language;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant AlphabotScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) _language = widget.language;
  }

  int _currentWordIndex = 0;
  final Set<String> _placedLetters = {};

  static const List<Map<String, dynamic>> _manipulativeWords = [
    {
      'word': 'LÚA',
      'letters': ['L', 'Ú', 'A'],
      'gl': 'Mascota e compañeira suave',
      'es': 'Mascota y compañera suave',
      'material': 'Letras de madeira ou feltro',
      'phonemes': ['/l/', '/u/', '/a/'],
    },
    {
      'word': 'SOL',
      'letters': ['S', 'O', 'L'],
      'gl': 'Luz cálida que esperta a mañá',
      'es': 'Luz cálida que despierta la mañana',
      'material': 'Imáns amarelos ou pasta de sal',
      'phonemes': ['/s/', '/o/', '/l/'],
    },
    {
      'word': 'MAR',
      'letters': ['M', 'A', 'R'],
      'gl': 'As ondas da ría de Vigo',
      'es': 'Las olas de la ría de Vigo',
      'material': 'Conchas ou pedras pintadas',
      'phonemes': ['/m/', '/a/', '/r/'],
    },
    {
      'word': 'PAN',
      'letters': ['P', 'A', 'N'],
      'gl': 'Alimento cotián para compartir',
      'es': 'Alimento cotidiano para compartir',
      'material': 'Masa real ou letras de cartón',
      'phonemes': ['/p/', '/a/', '/n/'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final item = _manipulativeWords[_currentWordIndex];
    final letters = item['letters'] as List<String>;
    final isComplete = _placedLetters.length >= letters.length;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: 'Alphabot',
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Pedagogical Guarantee Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.warningBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.star),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_rounded,
                        color: AppTheme.warning, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        lang == AppLanguage.gl
                            ? 'Xogo 100% físico para a crianza. Usa letras reais de madeira ou imáns na neveira.'
                            : 'Juego 100% físico para la infancia. Usa letras reales de madera o imanes en la nevera.',
                        style: const TextStyle(
                          color: AppTheme.warning,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Physical Table Simulation
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          lang == AppLanguage.gl
                              ? 'Palabra obxectivo na mesa:'
                              : 'Palabra objetivo en la mesa:',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Letters Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: letters.map((letter) {
                            final placed = _placedLetters.contains(letter);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (placed) {
                                    _placedLetters.remove(letter);
                                  } else {
                                    _placedLetters.add(letter);
                                  }
                                });
                              },
                              child: Container(
                                width: 64,
                                height: 72,
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color:
                                      placed ? context.acento : AppTheme.pageBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: placed
                                        ? context.acento
                                        : AppTheme.border,
                                    width: 2,
                                  ),
                                  boxShadow: placed
                                      ? [
                                          BoxShadow(
                                            color: context.acento
                                                .withValues(alpha: 0.3),
                                            blurRadius: 6,
                                            offset: const Offset(0, 2),
                                          )
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    letter,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: placed
                                          ? Colors.white
                                          : AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          lang == AppLanguage.gl ? item['gl']! : item['es']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Suxestión de material: ${item['material']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                        if (isComplete) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.successBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    color: AppTheme.success, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  lang == AppLanguage.gl
                                      ? 'Mesa montada con éxito!'
                                      : '¡Mesa montada con éxito!',
                                  style: TextStyle(
                                    color: context.acento,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // A frecha volve á palabra anterior; o botón principal pasa á
              // seguinte e, na última, pecha a mesa.
              PasosNavegacion(
                chaveAnterior: const ValueKey('alphabot_anterior'),
                chaveSeguinte: const ValueKey('alphabot_seguinte'),
                anterior: _currentWordIndex > 0
                    ? () {
                        setState(() {
                          _currentWordIndex--;
                          _placedLetters.clear();
                        });
                      }
                    : null,
                etiquetaAnterior: lang == AppLanguage.gl
                    ? 'Palabra anterior'
                    : 'Palabra anterior',
                etiquetaSeguinte:
                    _currentWordIndex < _manipulativeWords.length - 1
                        ? (lang == AppLanguage.gl ? 'Seguinte' : 'Siguiente')
                        : (lang == AppLanguage.gl ? 'Rematar' : 'Terminar'),
                iconaSeguinte: _currentWordIndex < _manipulativeWords.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                seguinte: () {
                  if (_currentWordIndex < _manipulativeWords.length - 1) {
                    setState(() {
                      _currentWordIndex++;
                      _placedLetters.clear();
                    });
                  } else {
                    Navigator.of(context).maybePop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
