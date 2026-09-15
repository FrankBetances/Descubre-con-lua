import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/models/unidad_model.dart';
import '../widgets/barra_ingles_widget.dart';

/// La nota que la escuela manda a las casas al terminar la asamblea.
///
/// **Es el puente, y es de papel a propósito.** La app no tiene permiso de red
/// y no lo va a tener: dos aparatos no se hablan. El calendario fingía que sí,
/// y la familia acababa marcando en su móvil una asamblea en la que no estuvo.
/// Aquí el puente es el de siempre en una escuela infantil: la docente copia
/// esto en la libreta, lo escribe en la pizarra de la entrada o lo enseña en la
/// puerta. Lo que llega a casa es el mensaje, no un dato.
///
/// Por eso la pantalla está hecha para LEERSE EN ALTO y para copiarse: letra
/// grande, poco texto, la frase inglesa con su altavoz y nada más. No hay botón
/// de compartir porque compartir necesitaría una dependencia y un permiso, y
/// esta app no tiene ni una cosa ni la otra.
class NotaParaCasasScreen extends StatelessWidget {
  final Unidad unidad;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const NotaParaCasasScreen({
    super.key,
    required this.unidad,
    required this.language,
    this.audioService,
  });

  static const titulo = LocalizedString(
    gl: 'A nota de hoxe para as casas',
    es: 'La nota de hoy para las casas',
  );

  static const _comoUsala = LocalizedString(
    gl: 'Cópiaa na libreta, escríbea na entrada ou léella á familia na porta. '
        'Non fai falta que ninguén instale nada.',
    es: 'Cópiala en la libreta, escríbela en la entrada o léesela a la familia '
        'en la puerta. No hace falta que nadie instale nada.',
  );

  static const _queDicimos = LocalizedString(
    gl: 'O QUE FIXEMOS HOXE',
    es: 'LO QUE HICIMOS HOY',
  );

  static const _paraCasa = LocalizedString(
    gl: 'PARA FACER NA CASA, TRES MINUTOS',
    es: 'PARA HACER EN CASA, TRES MINUTOS',
  );

  static const _laFrase = LocalizedString(
    gl: 'A FRASE EN INGLÉS',
    es: 'LA FRASE EN INGLÉS',
  );

  static const _cerrar = LocalizedString(
    gl: 'Feito, volver',
    es: 'Hecho, volver',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ponte = unidad.puenteCasa;
    final frase = unidad.ingles.frase;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        title: Text(
          titulo.resolve(language),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: PaxinaSenScroll(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lúa encabeza la nota porque la nota HABLA de ella: el mensaje
                // para las familias de cada unidad la nombra («hoxe navegamos coa
                // gata Lúa»), y hasta ahora la familia oía el nombre en la puerta
                // sin haberle visto la cara nunca. Es el único sitio donde la
                // gata cruza del aula a la casa, que es de lo que va esta pantalla.
                //
                // Cuadrado de lado fijo y centrado, sin nada al lado: no puede
                // desbordar a lo ancho por mucho que crezca la escala de texto.
                const Center(child: LuaPixel(pose: LuaPose.sit, size: 88)),
                const SizedBox(height: AppTheme.spaceMd),
                Text(
                  _comoUsala.resolve(language),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _Bloque(
                  kicker: _queDicimos.resolve(language),
                  child: Text(
                    unidad.titulo.resolve(language),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _Bloque(
                  kicker: _paraCasa.resolve(language),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ponte.mensajeFamilias.resolve(language),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textPrimary,
                          height: 1.45,
                        ),
                      ),
                      if (ponte.actividadesSugeridas.isNotEmpty) ...[
                        const SizedBox(height: AppTheme.spaceMd),
                        for (final actividad in ponte.actividadesSugeridas)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('· ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                Expanded(
                                  child: Text(
                                    actividad.resolve(language),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                if (frase.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  _Bloque(
                    kicker: _laFrase.resolve(language),
                    acento: BarraInglesFase.acento,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Grande, porque esta es la línea que se copia en la
                        // libreta y la que la familia va a decir esta noche.
                        Text(
                          frase,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BarraInglesFase.acento,
                            height: 1.35,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        BotonEscuchar(
                          audioService: audioService,
                          texto: frase,
                          language: AppLanguage.en,
                          style: estiloIngles(frase),
                          comoChip: true,
                          colorChip: BarraInglesFase.acento,
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spaceXl),
                ElevatedButton.icon(
                  key: const Key('boton_cerrar_nota'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check),
                  label: Text(_cerrar.resolve(language)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppTheme.touchMin),
                    backgroundColor: AppTheme.primaryVigoBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXl),
              ],
            )),
      ),
    );
  }
}

class _Bloque extends StatelessWidget {
  final String kicker;
  final Widget child;
  final Color acento;

  const _Bloque({
    required this.kicker,
    required this.child,
    this.acento = AppTheme.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
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
            kicker,
            style: theme.textTheme.labelSmall?.copyWith(
              color: acento,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          child,
        ],
      ),
    );
  }
}
