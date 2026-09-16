import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/repositories/content_repository.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/widgets/lua_game_strip.dart';
import '../widgets/academy_header.dart';
import '../widgets/selector_idioma_widget.dart';
import 'capsula_detail_screen.dart';
import 'guia_atencion_screen.dart';
import 'micro_rutina_setembro_screen.dart';
import '../../../core/storage/calendario_store.dart';
import '../../calendario/views/calendario_screen.dart';
import '../../calendario/widgets/calendario_do_curso.dart';
import '../../../data/repositories/calendario_repository.dart';

/// Los 5 bloques de desarrollo de «Academy · Familias».
///
/// Portada de la lista de Academy del proyecto anterior de la casa
/// (`docs/screenshots/28-academy-capsulas.png`): cabecera de color a sangre con
/// antetítulo en versalitas, y debajo una tarjeta blanca por bloque con su
/// baldosa de icono, su título y su línea de metadatos.
///
/// Quien mira esto es un adulto en casa. Cero enlaces externos y cero mecánicas
/// de juego infantil.
class BloquesListScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Opcional: sin él, leer una cápsula no cuenta para los premios.
  final PremiosRepository? premios;

  /// Opcional: sin él las cápsulas se leen, pero no se escuchan.
  final OfflineAudioService? audioService;

  /// Opcional: para acceder ao calendario sincronizado escola-fogar.
  final CalendarioStore? calendario;

  /// Los diez meses, si quien abre esta pantalla ya los tiene leídos. Sin
  /// esto la sección del calendario los lee sola, que en la app tarda un
  /// fotograma pero en un test de captura puede no llegar a tiempo: la
  /// imagen salía con un hueco en blanco donde va el calendario.
  final CalendarioContenido? calendarioContenido;

  const BloquesListScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.audioService,
    this.calendario,
    this.calendarioContenido,
  });

  @override
  State<BloquesListScreen> createState() => _BloquesListScreenState();
}

class _BloquesListScreenState extends State<BloquesListScreen> {
  late AppLanguage _language;

  static const _kicker = LocalizedString(gl: 'ACADEMY', es: 'ACADEMY');

  static const _titulo = LocalizedString(
    gl: 'Os 5 bloques de desenvolvemento',
    es: 'Los 5 bloques de desarrollo',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Lecturas curtas para a familia, cunha reflexión ao final. '
        'Sen pantallas para a crianza.',
    es: 'Lecturas cortas para la familia, con una reflexión al final. '
        'Sin pantallas para la criatura.',
  );

  static const _disponibles = LocalizedString(
    gl: 'BLOQUES DISPOÑIBLES',
    es: 'BLOQUES DISPONIBLES',
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
    gl: 'Novas cápsulas en preparación pedagóxica.',
    es: 'Nuevas cápsulas en preparación pedagógica.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  /// Del set de Material, en su variante `outlined`: mismo grosor y mismas
  /// terminaciones en los cinco. La regla 5 prohíbe emoji del sistema, que es
  /// lo que usa el proyecto anterior de la casa aquí y lo que cambia de fabricante a fabricante.
  IconData _iconForBloque(String iconKey) {
    switch (iconKey) {
      case 'ear_sparkles':
        return Icons.hearing_outlined;
      case 'chat_bubble_heart':
        return Icons.chat_bubble_outline;
      case 'people_arrows':
        return Icons.people_outline;
      case 'child_play':
        return Icons.sports_baseball_outlined;
      case 'home_globe':
        return Icons.language_outlined;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final bloques = widget.repository.getAllBloques();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy · Familias'),
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
                      // La tira de juego de la familia, justo debajo de la cabecera:
                      // la gata, el nivel por cápsulas leídas y la racha.
                      if (widget.premios != null) ...[
                        LuaGameStrip(
                          repository: widget.premios!,
                          perfil: Perfil.familia,
                          language: lang,
                          contadores: widget.calendario?.contadores,
                        ),
                        const SizedBox(height: AppTheme.spaceXl),
                      ],
                      // Acceso destacado a la Guía de Atención y al Calendario
                      AcademyCard(
                        icono: Icons.record_voice_over_outlined,
                        kicker: lang == AppLanguage.gl
                            ? 'O INGLÉS NA CASA'
                            : 'EL INGLÉS EN CASA',
                        titulo: lang == AppLanguage.gl
                            ? 'Guía de inglés na casa'
                            : 'Guía de inglés en casa',
                        descripcion: lang == AppLanguage.gl
                            ? 'Canto dura o xogo segundo a idade, tres regras para a casa e a pronuncia de cada frase.'
                            : 'Cuánto dura el juego según la edad, tres reglas para casa y la pronunciación de cada frase.',
                        meta: lang == AppLanguage.gl
                            ? 'Guía interactiva'
                            : 'Guía interactiva',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GuiaAtencionScreen(
                              initialLanguage: _language,
                              onLanguageChanged: _onToggleLanguage,
                              audioService: widget.audioService,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      // El calendario, DENTRO de Academy. Era una tarjeta que
                      // llevaba a otra pantalla; una tarjeta que lleva al
                      // calendario no es el calendario. La familia ve aquí el mes
                      // que la escuela está trabajando, sin salir de su sitio.
                      CalendarioDoCurso(
                        lang: _language,
                        esDocente: false,
                        store: widget.calendario,
                        contenido: widget.calendarioContenido,
                        padding: EdgeInsets.zero,
                        onAbrirMes: (contenido, mesIndex) =>
                            Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CalendarioScreen(
                              store: widget.calendario ?? CalendarioStore(),
                              contenido: contenido,
                              mesInicialIndex: mesIndex,
                              initialLanguage: _language,
                              onLanguageChanged: _onToggleLanguage,
                              esDocenteInicial: false,
                              repository: widget.repository,
                              audioService: widget.audioService,
                              premios: widget.premios,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceMd),
                      AcademyCard(
                        icono: Icons.home_work_outlined,
                        kicker: lang == AppLanguage.gl
                            ? 'SEGUNDO CICLO (3-6 ANOS) · NOVO'
                            : 'SEGUNDO CICLO (3-6 AÑOS) · NUEVO',
                        titulo: lang == AppLanguage.gl
                            ? 'Micro-rutina de setembro: responder sen corrixir'
                            : 'Micro-rutina de septiembre: responder sin corregir',
                        descripcion: lang == AppLanguage.gl
                            ? 'Principio de Tempo e Lugar (3-5 min) e guía comparativa entre devolver a frase ben dita e corrixir de fronte.'
                            : 'Principio de Tiempo y Lugar (3-5 min) y guía comparativa entre devolver la frase bien dicha y corregir de frente.',
                        meta: lang == AppLanguage.gl
                            ? 'Micro-rutina · Fogar'
                            : 'Micro-rutina · Hogar',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => MicroRutinaSetembroScreen(
                              initialLanguage: _language,
                              onLanguageChanged: _onToggleLanguage,
                              curriculo: widget.repository
                                  .getCapsulaById(
                                      'academy.segundo_ciclo.setembro.01')
                                  ?.curriculo,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXl),
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
                        final capsulas =
                            widget.repository.getCapsulasByBloqueId(bloque.id);
                        final primera =
                            capsulas.isNotEmpty ? capsulas.first : null;
                        final minutos = primera?.tiempoLecturaMinutos;

                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppTheme.spaceMd),
                          child: AcademyCard(
                            icono: _iconForBloque(bloque.icono),
                            kicker: 'Bloque ${bloque.orden}',
                            titulo: bloque.titulo.resolve(lang),
                            descripcion: bloque.descripcion.resolve(lang),
                            meta: capsulas.isEmpty
                                ? _sinCapsulas.resolve(lang)
                                : [
                                    '${capsulas.length} '
                                        '${capsulas.length == 1 ? _unaCapsula.resolve(lang) : _variasCapsulas.resolve(lang)}',
                                    if (minutos != null) '$minutos min'
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
