import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';

/// Pantalla de comprensión auditiva en inglés con audio offline.
class ListeningScreen extends StatefulWidget {
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const ListeningScreen({
    super.key,
    this.language = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  int _currentIndex = 0;
  bool _revealed = false;

  static const List<Map<String, String>> _listeningExercises = [
    {
      'title': 'Good Morning Circle',
      'phrase': 'Good morning everyone! Let us clap our hands together.',
      'gl': 'Bos días a todos! Imos bater as palmas xuntos.',
      'es': '¡Buenos días a todos! Vamos a aplaudir juntos.',
      'tpr': 'Clap hands twice',
    },
    {
      'title': 'Castrelos Park Leaves',
      'phrase': 'Look at the brown leaves falling from the tall trees.',
      'gl': 'Miras as follas marróns caendo das árbores altas.',
      'es': 'Mira las hojas marrones cayendo de los árboles altos.',
      'tpr': 'Wave arms like falling leaves',
    },
    {
      'title': 'Washing Hands Routine',
      'phrase': 'Turn on the water, take the soap, and rub your hands.',
      'gl': 'Abre a auga, colle o xabón e frega as mans.',
      'es': 'Abre el agua, toma el jabón y frota las manos.',
      'tpr': 'Rub palms together gently',
    },
    {
      'title': 'Quiet Bedtime Story',
      'phrase': 'Close your eyes, breathe in deep, and listen to the rain.',
      'gl': 'Pecha os ollos, respira fondo e escoita a choiva.',
      'es': 'Cierra los ojos, respira hondo y escucha la lluvia.',
      'tpr': 'Close eyes and take a slow breath',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final exercise = _listeningExercises[_currentIndex];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Comprensión Auditiva (Inglés)'
              : 'Comprensión Auditiva (Inglés)',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1} de ${_listeningExercises.length}',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'L3 Immersion',
                      style: TextStyle(
                        color: AppTheme.primaryInk,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Listening Player Card
              Expanded(
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.headphones,
                            size: 44,
                            color: AppTheme.primaryDark,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          exercise['title']!,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.pageBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.border),
                          ),
                          // Una pantalla que se llama «Comprensión Auditiva»
                          // y no tiene nada que escuchar es la promesa más
                          // grande que se rompía en esta app. La frase se oye
                          // aquí, con la voz del propio paquete.
                          child: Column(
                            children: [
                              Text(
                                '"${exercise['phrase']!}"',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                  color: AppTheme.textPrimary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              BotonEscuchar(
                                audioService: widget.audioService,
                                texto: exercise['phrase']!,
                                language: AppLanguage.en,
                                style: estiloIngles(exercise['phrase']!),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_revealed) ...[
                          Text(
                            lang == AppLanguage.gl
                                ? exercise['gl']!
                                : exercise['es']!,
                            style: const TextStyle(
                              fontSize: 15,
                              color: AppTheme.primaryInk,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.warningBg,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.pan_tool,
                                    size: 16, color: AppTheme.warning),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Acción TPR: ${exercise['tpr']!}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ] else ...[
                          TextButton.icon(
                            onPressed: () => setState(() => _revealed = true),
                            icon: const Icon(Icons.translate, size: 18),
                            label: Text(
                              lang == AppLanguage.gl
                                  ? 'Amosar tradución e reto TPR'
                                  : 'Mostrar traducción y reto TPR',
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentIndex > 0
                        ? () {
                            setState(() {
                              _currentIndex--;
                              _revealed = false;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.pageBg,
                      foregroundColor: AppTheme.textPrimary,
                      elevation: 0,
                    ),
                    child:
                        Text(lang == AppLanguage.gl ? 'Anterior' : 'Anterior'),
                  ),
                  ElevatedButton(
                    onPressed: _currentIndex < _listeningExercises.length - 1
                        ? () {
                            setState(() {
                              _currentIndex++;
                              _revealed = false;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child:
                        Text(lang == AppLanguage.gl ? 'Seguinte' : 'Siguiente'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
