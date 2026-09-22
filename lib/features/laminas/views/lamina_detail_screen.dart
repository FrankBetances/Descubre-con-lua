import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
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

  String _suxestionManipulativa(Lamina lamina, AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    switch (lamina.categoria.toLowerCase()) {
      case 'animais':
        return isGl
            ? 'Coloca un boneco ou figura do animal diante. Anima á crianza a imitar o seu son e movemento polo chan antes de nomealo.'
            : 'Coloca un muñeco o figura del animal delante. Anima a la criatura a imitar su sonido y movimiento por el suelo antes de nombrarlo.';
      case 'vigo_natureza':
        return isGl
            ? 'Se tedes unha cuncha, folla, pedra de praia ou auga nun caldeiro, tocade a textura real xuntos mentres escoitades o son do mar.'
            : 'Si tenéis una concha, hoja, piedra de playa o agua en un cuenco, tocad la textura real juntos mientras escucháis el sonido del mar.';
      case 'escola_rutinas':
        return isGl
            ? 'Usa o obxecto cotián real (mochila, culler, abrigo) e xogade a gardalo ou poñelo dicindo a palabra en voz alta a 72 bpm.'
            : 'Usa el objeto cotidiano real (mochila, cuchara, abrigo) y jugad a guardarlo o ponerlo diciendo la palabra en voz alta a 72 bpm.';
      case 'emocions_corpo':
        return isGl
            ? 'Toca no teu propio corpo a parte sinalada (ollos, nariz, mans) ou fai o xesto da emoción diante dun espello de man.'
            : 'Toca en tu propio cuerpo la parte señalada (ojos, nariz, manos) o haz el gesto de la emoción delante de un espejo de mano.';
      default:
        return isGl
            ? 'Busca un obxecto semellante no cuarto, pousade a man sobre el e agardade 5 segundos de silencio antes de repetir o nome.'
            : 'Busca un objeto similar en la habitación, posad la mano sobre él y esperad 5 segundos de silencio antes de repetir el nombre.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = language;
    final isGl = lang == AppLanguage.gl;

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
          '${isGl ? "Lámina" : "Lámina"} #${lamina.numero} · ${lamina.categoria.toUpperCase()}',
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'English: ${lamina.en}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryInk,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          BotonEscuchar(
                            audioService: audioService,
                            texto: lamina.en,
                            language: AppLanguage.en,
                            style: estiloIngles(lamina.en),
                            compacto: true,
                          ),
                        ],
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

              // Dinámica Manipulativa Física no Fogar (Zero-Screen)
              Card(
                color: const Color(0xFFFFF9EE),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFF6D4A0)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.touch_app_rounded,
                              color: Color(0xFFDD6B20), size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isGl
                                ? 'Xogo Manipulativo Táctil (Fogar / Aula)'
                                : 'Juego Manipulativo Táctil (Hogar / Aula)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFFDD6B20),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _suxestionManipulativa(lamina, lang),
                        style: const TextStyle(
                          fontSize: 13.5,
                          height: 1.4,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Pregunta Sugerida
              if (lamina.preguntaSugerida != null)
                Card(
                  elevation: 0.5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: AppTheme.border),
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
                              isGl
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
                    side: const BorderSide(color: AppTheme.border),
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
                              isGl
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
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lamina.tprAccion!.en,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            BotonEscuchar(
                              audioService: audioService,
                              texto: lamina.tprAccion!.en,
                              language: AppLanguage.en,
                              style: estiloIngles(lamina.tprAccion!.en),
                              compacto: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isGl
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
