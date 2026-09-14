import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';
import 'barra_ingles_widget.dart';

/// Las cinco palabras de la unidad, en las tres lenguas y con altavoz.
///
/// **Por qué aparece ahora.** El vocabulario llevaba desde el principio sus
/// grabaciones dentro del APK —la palabra despacio, en galego y en castelán,
/// para que se pueda imitar— y NINGUNA pantalla lo pintaba. Cien locuciones
/// viajando sin nada que las reprodujera. El comentario del corpus lo decía:
/// «entra el día que exista la tarjeta, no antes». Este es ese día, y llega
/// con la palabra inglesa al lado, que es lo que faltaba para que el inglés
/// del mes fuese algo más que una lista en el calendario.
///
/// **Por qué va en el cuento y no en una fase propia.** Las palabras salen en
/// la narración: aquí se oyen mientras se está leyendo la página en la que
/// aparecen, no en un apartado al que hay que ir a buscarlas. Una fase más
/// serían siete, y la asamblea son seis.
class VocabularioDaUnidade extends StatelessWidget {
  final List<VocabularioItem> items;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const VocabularioDaUnidade({
    super.key,
    required this.items,
    required this.language,
    this.audioService,
  });

  static const _titulo = LocalizedString(
    gl: 'AS PALABRAS DE HOXE',
    es: 'LAS PALABRAS DE HOY',
  );

  static const _axuda = LocalizedString(
    gl: 'Pulsa para oílas antes de dicilas. A palabra vai devagar a propósito.',
    es: 'Pulsa para oírlas antes de decirlas. La palabra va despacio a propósito.',
  );

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titulo.resolve(language),
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppTheme.primaryDark,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _axuda.resolve(language),
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          for (final item in items) ...[
            _FilaPalabra(
              item: item,
              language: language,
              audioService: audioService,
            ),
            if (item != items.last) const SizedBox(height: AppTheme.spaceMd),
          ],
        ],
      ),
    );
  }
}

class _FilaPalabra extends StatelessWidget {
  final VocabularioItem item;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const _FilaPalabra({
    required this.item,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Wrap y no Row: en galego «Mexillón» con «Mussel» al lado no cabe en
        // 360 dp con el texto grande del sistema, y una fila fija lo cortaría
        // en silencio en release.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            BotonEscuchar(
              audioService: audioService,
              texto: item.palabra.resolve(language),
              language: language,
              // Despacio: la palabra existe para que la imiten.
              style: VoiceStyle.slow,
              comoChip: true,
              colorChip: AppTheme.primaryVigoBlue,
            ),
            if (item.ingles.isNotEmpty)
              BotonEscuchar(
                audioService: audioService,
                texto: item.ingles,
                language: AppLanguage.en,
                style: estiloIngles(item.ingles),
                comoChip: true,
                colorChip: BarraInglesFase.acento,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          item.definicionBreve.resolve(language),
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
