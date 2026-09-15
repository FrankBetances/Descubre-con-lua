import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';

/// El inglés de la fase que la docente tiene delante, ahí mismo.
///
/// **Por qué aquí y no en una pantalla propia.** El inglés vivía en el
/// calendario: para oír cómo se dice «Gentle waves» había que salir de la
/// asamblea, entrar en el calendario, buscar el mes y abrir la ficha. Una
/// maestra con doce criaturas en la alfombra no hace ese viaje, así que el
/// inglés no se usaba. Ahora va pegado a la fase en la que se dice.
///
/// **Por qué siempre en el mismo sitio.** La barra se pinta al final de cada
/// una de las seis fases, con el mismo color y el mismo rótulo. A la tercera
/// asamblea la mano va sola: no hay que leer la pantalla para encontrarla.
///
/// **Por qué son pastillas y no una lista.** Cada pastilla ES la palabra, y se
/// pulsa entera —48 dp de alto, que es lo mínimo que una mano acierta sin
/// mirar—. Si una grabación todavía no existe, la pastilla se queda con la
/// palabra legible y sin altavoz, en vez de prometer un sonido que no llega.
class BarraInglesFase extends StatelessWidget {
  /// Lo que se dice en esta fase. Si viene vacío, la barra no se pinta.
  final List<String> textos;

  final AppLanguage language;
  final OfflineAudioService? audioService;

  const BarraInglesFase({
    super.key,
    required this.textos,
    required this.language,
    this.audioService,
  });

  static const _kicker = LocalizedString(
    gl: 'DILLO EN INGLÉS',
    es: 'DILO EN INGLÉS',
  );

  static const _ayuda = LocalizedString(
    gl: 'Óeo antes de dicilo',
    es: 'Óyelo antes de decirlo',
  );

  /// El acento del inglés en toda la app: el mismo en la asamblea, en la
  /// cápsula de la familia y en la nota para casa.
  static const acento = Color(0xFF00838F);

  @override
  Widget build(BuildContext context) {
    if (textos.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceLg,
        AppTheme.spaceSm,
        AppTheme.spaceLg,
        AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: acento.withAlpha(16),
        border: const Border(top: BorderSide(color: Color(0xFFE2DDD0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volume_up_rounded, size: 16, color: acento),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  _kicker.resolve(language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: acento,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // La ayuda es lo primero que sobra cuando no cabe: con el texto
              // grande del sistema desaparece y el rótulo se queda entero.
              if (MediaQuery.textScalerOf(context).scale(12) < 18)
                Flexible(
                  child: Text(
                    _ayuda.resolve(language),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Una sola fila que se desliza: anclada encima de la navegación, el
          // alto es lo que escasea. Con dos o tres pastillas caben todas sin
          // deslizar; con más, se empuja con el pulgar sin perder la fase.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final texto in textos) ...[
                  BotonEscuchar(
                    audioService: audioService,
                    texto: texto,
                    language: AppLanguage.en,
                    // La regla vive en voice_id.dart y es la misma que usa el
                    // corpus: palabra suelta despacio, frase a ritmo de lectura.
                    style: estiloIngles(texto),
                    comoChip: true,
                    colorChip: acento,
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
