import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart'
    show MicroRutinaHogarSegundoCiclo;
import '../../../data/models/hogar_model.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/con_lingua.dart';

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
/// grande, poco texto, las palabras inglesas del mes con su altavoz y nada más.
///
/// Desde M4.3 cierra la asamblea de cuatro fases y sale de la unidad del mes:
/// su centro de interés, su núcleo y, en 2.º ciclo, la micro-rutina de casa de
/// su asamblea. M4.4 le añadirá el reto de la semana (llega con M6). No hay botón
/// de compartir porque compartir necesitaría una dependencia y un permiso, y
/// esta app no tiene ni una cosa ni la otra.
class NotaParaCasasScreen extends StatelessWidget {
  /// El centro de interés del mes: lo que se hizo hoy.
  final LocalizedString centroInteres;

  /// El núcleo del mes, ya resuelto: lo que la familia puede decir en casa.
  final List<PezaDaUnidade> nucleo;

  /// En 2.º ciclo, la micro-rutina de casa de la asamblea del mes.
  final MicroRutinaHogarSegundoCiclo? microRutina;

  /// El reto de casa de esta semana (M4.4): el mismo que ve la familia en
  /// Hoxe, con el momento del mes.
  final RetoDeCasa? reto;
  final LocalizedString? momentoDoReto;

  /// El código para casa (P10): con él, la familia abre en su app el núcleo,
  /// el reto de esta semana y qué mirar.
  final String? codigoCasa;
  final AppLanguage language;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const NotaParaCasasScreen({
    super.key,
    required this.centroInteres,
    required this.nucleo,
    this.microRutina,
    this.reto,
    this.momentoDoReto,
    this.codigoCasa,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
  });

  // Cabe entero en la cabecera a 360 px; «… para as casas» se cortaba.
  static const titulo = LocalizedString(
    gl: 'A nota de hoxe',
    es: 'La nota de hoy',
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

  static const _palabras = LocalizedString(
    gl: 'AS PALABRAS EN INGLÉS DO MES',
    es: 'LAS PALABRAS EN INGLÉS DEL MES',
  );

  static const _palabrasCasa = LocalizedString(
    gl: 'Na casa, dicide unha cando saia no día, co seu xesto. Sen pedir que '
        'a repita: abonda con que a escoite.',
    es: 'En casa, decid una cuando salga en el día, con su gesto. Sin pedir que '
        'la repita: basta con que la escuche.',
  );

  static const _retoDaSemana = LocalizedString(
    gl: 'O RETO DESTA SEMANA NA CASA',
    es: 'EL RETO DE ESTA SEMANA EN CASA',
  );

  static const _paraCasa = LocalizedString(
    gl: 'PARA FACER NA CASA',
    es: 'PARA HACER EN CASA',
  );

  static const _cerrar = LocalizedString(
    gl: 'Feito, volver',
    es: 'Hecho, volver',
  );

  @override
  Widget build(BuildContext context) => ConLingua(
        inicial: language,
        aoCambiar: onLanguageChanged,
        builder: _construir,
      );

  /// A pantalla, na lingua que ten agora: [language] tapa o campo co mesmo
  /// nome, que é só a lingua coa que se abriu.
  Widget _construir(
    BuildContext context,
    AppLanguage language,
    ValueChanged<AppLanguage> cambiarLingua,
  ) {
    final theme = Theme.of(context);
    final rutina = microRutina;
    final isGl = language == AppLanguage.gl;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: titulo.resolve(language),
        language: language,
        onLanguageChanged: cambiarLingua,
      ),
      body: SafeArea(
        child: PaxinaSenScroll(
            desprazarSeNonCabe: true,
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              key: const Key('nota_para_casas'),
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Lúa encabeza la nota: es el único sitio donde la gata cruza
                // del aula a la casa, que es de lo que va esta pantalla.
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
                    centroInteres.resolve(language),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (nucleo.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  _Bloque(
                    kicker: _palabras.resolve(language),
                    acento: context.acento,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _palabrasCasa.resolve(language),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        for (final peza in nucleo)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Grandes: es lo que se copia en la libreta.
                                BotonEscuchar(
                                  audioService: audioService,
                                  texto: peza.en,
                                  language: AppLanguage.en,
                                  interfaz: language,
                                  style: estiloIngles(peza.en),
                                  comoChip: true,
                                  colorChip: context.acento,
                                  descripcion: peza.en,
                                  significado: peza.significado,
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  [
                                    if (peza.significado != null)
                                      peza.significado!.resolve(language),
                                    peza.xesto.resolve(language),
                                  ]
                                      .where((s) => s.trim().isNotEmpty)
                                      .join(' · '),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textSecondary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                if ((reto, momentoDoReto) case (final r?, final m?)) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  _Bloque(
                    key: const Key('nota_reto_da_semana'),
                    kicker: _retoDaSemana.resolve(language),
                    acento: context.acento,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BotonEscuchar(
                          audioService: audioService,
                          texto: r.frase.en,
                          language: AppLanguage.en,
                          interfaz: language,
                          style: estiloIngles(r.frase.en),
                          comoChip: true,
                          colorChip: context.acento,
                          descripcion: r.frase.en,
                          significado: r.frase.significado,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${m.resolve(language)}. ${r.queFacer.resolve(language)}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (codigoCasa case final codigo?) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  _Bloque(
                    key: const Key('nota_codigo_casa'),
                    kicker: isGl ? 'CÓDIGO PARA A CASA' : 'CÓDIGO PARA CASA',
                    acento: context.acento,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          codigo,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: context.acento,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isGl
                              ? 'Na app, entra en Na casa, abre Hoxe e toca «Tes un código da escola?». Abre o núcleo, o reto desta semana e que mirar. Non se garda nada.'
                              : 'En la app, entra en En casa, abre Hoy y toca «¿Tienes un código de la escuela?». Abre el núcleo, el reto de esta semana y qué mirar. No se guarda nada.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (rutina != null) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  _Bloque(
                    kicker: '${_paraCasa.resolve(language)}, '
                        '${rutina.nichoTiempoMinutos} '
                        '${isGl ? 'MINUTOS' : 'MINUTOS'}',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rutina.titulo.resolve(language),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rutina.momentoDelDia.resolve(language),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          rutina.escenaCotidiana.resolve(language),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spaceXl),
                ElevatedButton.icon(
                  key: const Key('boton_cerrar_nota'),
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.check_rounded),
                  label: Text(_cerrar.resolve(language)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppTheme.touchMin),
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

  /// Sin color, el acento del portal.
  final Color? acento;

  const _Bloque({
    super.key,
    required this.kicker,
    required this.child,
    this.acento,
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
              color: acento ?? context.acento,
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
