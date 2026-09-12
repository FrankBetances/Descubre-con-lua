import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/content_repository.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/widgets/lua_game_strip.dart';
import '../widgets/academy_header.dart';
import '../widgets/selector_idioma_widget.dart';
import 'capsula_detail_screen.dart';

/// Los 5 bloques de desarrollo de «Academy · Familias».
///
/// Portada de la lista de Academy de Valeria+
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

  const BloquesListScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
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
  /// lo que usa Valeria+ aquí y lo que cambia de fabricante a fabricante.
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
      body: ListView(
        padding: EdgeInsets.zero,
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
                  final capsulas =
                      widget.repository.getCapsulasByBloqueId(bloque.id);
                  final primera = capsulas.isNotEmpty ? capsulas.first : null;
                  final minutos = primera?.tiempoLecturaMinutos;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
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
                                  builder: (context) => CapsulaDetailScreen(
                                    capsula: primera,
                                    initialLanguage: _language,
                                    onLanguageChanged: _onToggleLanguage,
                                    premios: widget.premios,
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
      ),
    );
  }
}
