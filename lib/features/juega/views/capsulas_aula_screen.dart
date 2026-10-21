import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/views/capsula_detail_screen.dart';
import '../../academy/widgets/academy_header.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/widgets/lua_game_strip.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/widgets/cabecera.dart';
import '../../docentes/nomes_docentes.dart';
import '../../formacion/views/o_modelo_screen.dart';
import '../../../data/models/capsula_model.dart';

/// «Formación · Aula»: las cápsulas que lee la maestra.
///
/// Misma pieza visual que Academy —`AcademyHeader` y `AcademyCard`, el estilo
/// del proyecto anterior de la casa— y a propósito: es la misma clase de lectura, y que se vea
/// distinta solo obligaría a aprender dos interfaces para lo mismo. Lo que
/// cambia es de quién es el recorrido y cómo se titulan las secciones dentro
/// del lector.
///
/// Las seis lecturas se agrupan por las CUATRO fases de la asamblea (saludo,
/// enfoque, núcleo TPR y calma), y delante van las herramientas de cómo se
/// habla, que viven en «O modelo» (arquitectura, apartado 9). La formación va
/// al lado de lo que hay que hacer.
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

  static const titulo = NomesDocentes.formacionCabeceira;

  @override
  State<CapsulasAulaScreen> createState() => _CapsulasAulaScreenState();
}

class _CapsulasAulaScreenState extends State<CapsulasAulaScreen> {
  late AppLanguage _language;

  static const _kicker =
      LocalizedString(gl: 'XOGA CON LÚA', es: 'JUEGA CON LÚA');

  static const _titulo = LocalizedString(
    gl: 'As catro fases da asemblea',
    es: 'Las cuatro fases de la asamblea',
  );

  /// Las cuatro fases, con las lecturas de cada una. Una lectura está en la
  /// fase en la que la maestra la usa.
  static const fases = <(LocalizedString, List<String>)>[
    (
      LocalizedString(gl: '1 · Saúdo e apertura', es: '1 · Saludo y apertura'),
      [Bloque.aulaPulsoId],
    ),
    (
      LocalizedString(gl: '2 · Enfoque', es: '2 · Enfoque'),
      [Bloque.aulaContoId, Bloque.aulaPreguntasId],
    ),
    (
      LocalizedString(gl: '3 · Núcleo TPR', es: '3 · Núcleo TPR'),
      [Bloque.aulaExploracionId, Bloque.aulaMatematicasId],
    ),
    (
      LocalizedString(gl: '4 · Calma e despedida', es: '4 · Calma y despedida'),
      [Bloque.aulaPonteCasaId],
    ),
  ];

  static const _subtitulo = LocalizedString(
    gl: 'Unha lectura curta por paso, para ler antes ou despois da asemblea. '
        'Non se usa diante das crianzas.',
    es: 'Una lectura corta por paso, para leer antes o después de la asamblea. '
        'No se usa delante de las criaturas.',
  );

  static const _ferramentas = LocalizedString(
    gl: 'COMO SE FALA, EN TODAS AS FASES',
    es: 'CÓMO SE HABLA, EN TODAS LAS FASES',
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
        return Icons.graphic_eq_rounded;
      case 'chat_bubble_heart':
        return Icons.chat_bubble_rounded;
      case 'people_arrows':
        return Icons.help_rounded;
      case 'child_play':
        return Icons.back_hand_rounded;
      case 'home_globe':
        return Icons.straighten_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  Widget _tarxeta(BuildContext context, Bloque bloque) {
    final lang = _language;
    final capsulas = widget.repository.getCapsulasAulaByBloqueId(bloque.id);
    final primera = capsulas.isNotEmpty ? capsulas.first : null;
    final minutos = primera?.tiempoLecturaMinutos;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
      child: AcademyCard(
        icono: _iconForBloque(bloque.icono),
        kicker: lang == AppLanguage.gl ? 'Lectura curta' : 'Lectura corta',
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
                  RutaLua(
                    de: context,
                    builder: (context) => CapsulaDetailScreen(
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
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final bloques = widget.repository.getAllBloquesAula();

    return Scaffold(
      appBar: Cabecera(
        titulo: CapsulasAulaScreen.titulo.resolve(lang),
        language: _language,
        onLanguageChanged: _onToggleLanguage,
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
                          onLanguageChanged: _onToggleLanguage,
                          repository: widget.premios!,
                          perfil: Perfil.docente,
                          language: lang,
                        ),
                        const SizedBox(height: AppTheme.spaceXl),
                      ],
                      _Rotulo(_ferramentas.resolve(lang)),
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppTheme.spaceLg),
                        child: AcademyCard(
                          key: const ValueKey('formacion_o_modelo'),
                          icono: Icons.record_voice_over_rounded,
                          kicker: lang == AppLanguage.gl
                              ? 'Ferramentas'
                              : 'Herramientas',
                          titulo: OModeloScreen.nome.resolve(lang),
                          descripcion: OModeloScreen.di.resolve(lang),
                          onTap: () => Navigator.of(context).push(RutaLua(
                            de: context,
                            builder: (_) => OModeloScreen(
                              paraAula: true,
                              language: _language,
                              onLanguageChanged: _onToggleLanguage,
                              audioService: widget.audioService,
                            ),
                          )),
                        ),
                      ),
                      for (final (fase, ids) in fases) ...[
                        _Rotulo(fase.resolve(lang).toUpperCase()),
                        for (final bloque
                            in bloques.where((b) => ids.contains(b.id)))
                          _tarxeta(context, bloque),
                        const SizedBox(height: AppTheme.spaceSm),
                      ],
                    ],
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
        child: Text(
          texto,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
        ),
      );
}
