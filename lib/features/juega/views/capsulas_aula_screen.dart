import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/views/capsula_detail_screen.dart';
import '../../academy/widgets/academy_header.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/widgets/lua_game_strip.dart';

/// «Formación · Aula»: las cápsulas que lee la maestra.
///
/// Misma pieza visual que Academy —`AcademyHeader` y `AcademyCard`, el estilo
/// del proyecto anterior de la casa— y a propósito: es la misma clase de lectura, y que se vea
/// distinta solo obligaría a aprender dos interfaces para lo mismo. Lo que
/// cambia es de quién es el recorrido y cómo se titulan las secciones dentro
/// del lector.
///
/// Los seis bloques NO son temas elegidos a gusto: son los seis pasos de la
/// asamblea, en su orden. La formación va al lado de lo que hay que hacer.
class CapsulasAulaScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Opcional: sin él, leer una cápsula no cuenta para los premios.
  final PremiosRepository? premios;

  /// Opcional: sin él las cápsulas se leen, pero no se escuchan.
  final OfflineAudioService? audioService;

  const CapsulasAulaScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.audioService,
  });

  static const titulo = LocalizedString(
    gl: 'Formación · Aula',
    es: 'Formación · Aula',
  );

  @override
  State<CapsulasAulaScreen> createState() => _CapsulasAulaScreenState();
}

class _CapsulasAulaScreenState extends State<CapsulasAulaScreen> {
  late AppLanguage _language;

  static const _kicker =
      LocalizedString(gl: 'XOGA CON LÚA', es: 'JUEGA CON LÚA');

  static const _titulo = LocalizedString(
    gl: 'Os seis pasos da asemblea',
    es: 'Los seis pasos de la asamblea',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Unha lectura curta por paso, para ler antes ou despois da asemblea. '
        'Non se usa diante das crianzas.',
    es: 'Una lectura corta por paso, para leer antes o después de la asamblea. '
        'No se usa delante de las criaturas.',
  );

  static const _disponibles = LocalizedString(
    gl: 'UN PASO, UNHA CÁPSULA',
    es: 'UN PASO, UNA CÁPSULA',
  );

  static const _unaCapsula = LocalizedString(
    gl: 'cápsula dispoñible',
    es: 'cápsula disponible',
  );
  static const _variasCapsulas = LocalizedString(
    gl: 'cápsulas dispoñibles',
    es: 'cápsulas disponibles',
  );
  static const _sinCapsulas = LocalizedString(
    gl: 'Cápsula en preparación pedagóxica.',
    es: 'Cápsula en preparación pedagógica.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  /// Del set de Material, variante `outlined`: mismo grosor y mismas
  /// terminaciones en los seis. La regla 5 prohíbe emoji del sistema.
  IconData _iconForBloque(String iconKey) {
    switch (iconKey) {
      case 'ear_sparkles':
        return Icons.graphic_eq_outlined;
      case 'chat_bubble_heart':
        return Icons.chat_bubble_outline;
      case 'people_arrows':
        return Icons.help_outline;
      case 'child_play':
        return Icons.back_hand_outlined;
      case 'home_globe':
        return Icons.straighten_outlined;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final bloques = widget.repository.getAllBloquesAula();

    return Scaffold(
      appBar: AppBar(
        title: Text(CapsulasAulaScreen.titulo.resolve(lang)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceMd),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      // targetSdk 36 obliga al borde a borde en Android 15+: la ventana
      // ya no reserva la barra de gestos y el final de esta pantalla
      // quedaba por debajo. `top: false` porque el inset de arriba ya lo
      // consume el AppBar; volver a pedirlo aquí no suma nada.
      body: SafeArea(
        top: false,
        child: PaxinaSenScroll(
            desprazarSeNonCabe: true,
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcademyHeader(
                  kicker: _kicker.resolve(lang),
                  titulo: _titulo.resolve(lang),
                  subtitulo: _subtitulo.resolve(lang),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.spaceLg,
                    AppTheme.spaceXl,
                    AppTheme.spaceLg,
                    AppTheme.spaceXxl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.premios != null) ...[
                        LuaGameStrip(
                          repository: widget.premios!,
                          perfil: Perfil.docente,
                          language: lang,
                        ),
                        const SizedBox(height: AppTheme.spaceXl),
                      ],
                      Text(
                        _disponibles.resolve(lang),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.4,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      ...bloques.map((bloque) {
                        final capsulas = widget.repository
                            .getCapsulasAulaByBloqueId(bloque.id);
                        final primera =
                            capsulas.isNotEmpty ? capsulas.first : null;
                        final minutos = primera?.tiempoLecturaMinutos;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTheme.spaceMd),
                          child: AcademyCard(
                            icono: _iconForBloque(bloque.icono),
                            kicker: 'Paso ${bloque.orden}',
                            titulo: bloque.titulo.resolve(lang),
                            descripcion: bloque.descripcion.resolve(lang),
                            meta: capsulas.isEmpty
                                ? _sinCapsulas.resolve(lang)
                                : [
                                    '${capsulas.length} '
                                        '${capsulas.length == 1 ? _unaCapsula.resolve(lang) : _variasCapsulas.resolve(lang)}',
                                    if (minutos != null) '$minutos min',
                                  ].join(' · '),
                            onTap: primera == null
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CapsulaDetailScreen(
                                          capsula: primera,
                                          initialLanguage: _language,
                                          onLanguageChanged: _onToggleLanguage,
                                          premios: widget.premios,
                                          audioService: widget.audioService,
                                        ),
                                      ),
                                    ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}
