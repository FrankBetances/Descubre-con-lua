import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/lamina_model.dart';

/// Visor interactivo individual de cada lámina didáctica.
class LaminaDetailScreen extends StatelessWidget {
  final Lamina lamina;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const LaminaDetailScreen({
    super.key,
    required this.lamina,
    this.language = AppLanguage.gl,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final lang = language;

    Color cardBg = Colors.white;
    if (lamina.bgHex != null && lamina.bgHex!.startsWith('#')) {
      try {
        final hex = lamina.bgHex!.replaceFirst('#', '');
        cardBg = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    Color mainColor = AppTheme.primaryDark;
    if (lamina.corHex != null && lamina.corHex!.startsWith('#')) {
      try {
        final hex = lamina.corHex!.replaceFirst('#', '');
        mainColor = Color(int.parse('FF$hex', radix: 16));
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          'Lámina #${lamina.numero} · ${lamina.categoria.toUpperCase()}',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Visual Card
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: mainColor.withValues(alpha: 0.3), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: LaminaEscena(
                          clave: lamina.lamina,
                          ancho: 150,
                          mentres: Icon(
                            Icons.image,
                            size: 64,
                            color: mainColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lang == AppLanguage.gl ? lamina.gl : lamina.es,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'English: ${lamina.en}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Badges: CEFR, Categoria, Ratio
              Row(
                children: [
                  _buildBadge(
                    'CEFR: ${lamina.cefr}',
                    AppTheme.primaryLight,
                    AppTheme.primaryInk,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    lamina.categoria,
                    AppTheme.primaryLight,
                    AppTheme.primaryInk,
                  ),
                  const SizedBox(width: 8),
                  _buildBadge(
                    'Proporción ${lamina.ratio}',
                    AppTheme.pageBg,
                    AppTheme.textSecondary,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Pregunta Sugerida
              if (lamina.preguntaSugerida != null)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.help_outline,
                                color: AppTheme.primaryDark, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Pregunta de estimulación dialóxica'
                                  : 'Pregunta de estimulación dialógica',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.primaryInk,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lamina.preguntaSugerida!.resolve(lang),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Obxectivo pedagóxico
              if (lamina.obxectivo != null)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.track_changes,
                                color: AppTheme.warning, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              lang == AppLanguage.gl
                                  // «Neurodesenvolvemento» promete una
                                  // medida del desarrollo del cerebro que esta
                                  // app ni toma ni podría tomar, y además
                                  // declara no tener finalidad sanitaria. Lo
                                  // que hay aquí es lo que se busca con la
                                  // lámina, que ya es bastante.
                                  ? 'Que se busca con esta lámina'
                                  : 'Qué se busca con esta lámina',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.warning,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lamina.obxectivo!.resolve(lang),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Reto TPR en inglés
              if (lamina.tprAccion != null)
                Card(
                  color: AppTheme.primaryLight,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.primaryLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.directions_run,
                                color: AppTheme.primaryDark, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Acción TPR en Inglés (L3)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lamina.tprAccion!.en,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lang == AppLanguage.gl
                              ? lamina.tprAccion!.gl
                              : lamina.tprAccion!.es,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.primaryInk,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
