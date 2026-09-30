import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/aviso_contenido_ilegible.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/loaders/content_asset_loader.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../widgets/steam_comun.dart';
import 'steam_sesion_guiada_screen.dart';

/// Las cinco unidades STEAM, una por curso.
///
/// La abren los dos portales y cada uno con su [audiencia]: el Portal Docentes
/// abre la versión del aula y el Portal Familias la de casa. No es el mismo
/// texto con otro título: en casa no hay grupo ni material de aula.
class SteamHubScreen extends StatefulWidget {
  final ContentRepository repository;
  final OfflineAudioService audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final SteamAudiencia audiencia;

  /// El curso con el que se abre filtrado (`curso_0_2` … `curso_5_6`): el de
  /// «Hoxe na aula» en el portal docente, la edad elegida en el de familias.
  /// Sin curso, se ven las cinco.
  final String? initialCursoId;

  const SteamHubScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.initialLanguage,
    required this.audiencia,
    this.onLanguageChanged,
    this.initialCursoId,
  });

  @override
  State<SteamHubScreen> createState() => _SteamHubScreenState();
}

class _SteamHubScreenState extends State<SteamHubScreen> {
  late AppLanguage _language;
  String? _curso;
  bool _cargando = false;

  static const _introAula = LocalizedString(
    gl: 'Cinco sesións de ciencia con materiais reais, unha por curso, de 12 meses a 6 anos. Cada unha trae o que tes que preparar, o que dis en cada paso e as ordes en inglés para responder co corpo.',
    es: 'Cinco sesiones de ciencia con materiales reales, una por curso, de 12 meses a 6 años. Cada una trae lo que tienes que preparar, lo que dices en cada paso y las órdenes en inglés para responder con el cuerpo.',
  );

  static const _introCasa = LocalizedString(
    gl: 'Cinco xogos de ciencia con cousas da casa, un para cada idade, de 12 meses a 6 anos. Cada un trae o que precisas, o que dis en cada paso e as ordes en inglés para responder co corpo.',
    es: 'Cinco juegos de ciencia con cosas de casa, uno para cada edad, de 12 meses a 6 años. Cada uno trae lo que necesitas, lo que dices en cada paso y las órdenes en inglés para responder con el cuerpo.',
  );

  static const _edad = LocalizedString(gl: 'Idade', es: 'Edad');

  static const _ningunha = LocalizedString(
    gl: 'Non hai ningunha unidade para esta idade.',
    es: 'No hay ninguna unidad para esta edad.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _curso = widget.initialCursoId;
    if (widget.repository.steamUnits.isEmpty) {
      _cargando = true;
      widget.repository.loadSteamUnits().whenComplete(() {
        if (mounted) setState(() => _cargando = false);
      });
    }
  }

  @override
  void didUpdateWidget(covariant SteamHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  void _abrir(SteamUnit unidad) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SteamSesionGuiadaScreen(
          unit: unidad,
          audiencia: widget.audiencia,
          audioService: widget.audioService,
          initialLanguage: _language,
          onLanguageChanged: _cambiarLingua,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todas = widget.repository.steamUnits;
    final visibles = _curso == null
        ? todas
        : todas.where((u) => u.estadio == _curso).toList();

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          SteamTextos.titulo.resolve(_language),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _cambiarLingua,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : todas.isEmpty
                ? AvisoContenidoIlegible(
                    asset: ContentAssetLoader.steamAssetPath,
                    language: _language,
                  )
                : ListView(
                    key: const ValueKey('steam_hub_lista'),
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    children: [
                      _cabecera(),
                      const SizedBox(height: AppTheme.spaceLg),
                      _filtro(todas),
                      const SizedBox(height: AppTheme.spaceMd),
                      if (visibles.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(AppTheme.spaceXl),
                          child: Text(
                            _ningunha.resolve(_language),
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                        ),
                      for (final u in visibles) ...[
                        _TarxetaUnidade(
                          unidad: u,
                          audiencia: widget.audiencia,
                          language: _language,
                          onAbrir: () => _abrir(u),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                      ],
                    ],
                  ),
      ),
    );
  }

  Widget _cabecera() {
    final aula = widget.audiencia == SteamAudiencia.aula;
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderActive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SteamPastilla(
            icono: aula ? Icons.school_rounded : Icons.home_rounded,
            texto: SteamTextos.audiencia(widget.audiencia).resolve(_language),
            tinta: steamTinta,
            fondo: steamFondo,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            (aula ? _introAula : _introCasa).resolve(_language),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.phonelink_lock_rounded,
                    size: 18, color: AppTheme.primaryInk),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  SteamTextos.senPantallas.resolve(_language),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryInk,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// El filtro por edad, en varias filas cuando no cabe en una. Una fila con
  /// scroll horizontal escondía los tramos de 3 a 6 años fuera de la pantalla.
  Widget _filtro(List<SteamUnit> todas) {
    Widget chip(String? curso, String texto) {
      final sel = _curso == curso;
      return ChoiceChip(
        key: ValueKey('steam_filtro_${curso ?? 'todas'}'),
        label: Text(texto),
        selected: sel,
        onSelected: (_) => setState(() => _curso = curso),
        selectedColor: AppTheme.primaryInk,
        labelStyle: TextStyle(
          color: sel ? Colors.white : AppTheme.textPrimary,
          fontWeight: sel ? FontWeight.bold : FontWeight.w600,
          fontSize: 13,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _edad.resolve(_language).toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            chip(null, SteamTextos.todas.resolve(_language)),
            for (final u in todas)
              chip(u.estadio, u.rangoEdad.resolve(_language)),
          ],
        ),
      ],
    );
  }
}

class _TarxetaUnidade extends StatelessWidget {
  final SteamUnit unidad;
  final SteamAudiencia audiencia;
  final AppLanguage language;
  final VoidCallback onAbrir;

  const _TarxetaUnidade({
    required this.unidad,
    required this.audiencia,
    required this.language,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    final variante = unidad.variante(audiencia);
    return Material(
      color: AppTheme.card,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onAbrir,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SteamDatosUnidad(unidad: unidad, language: language),
              const SizedBox(height: AppTheme.spaceSm),
              Text(
                unidad.titulo.resolve(language),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                unidad.fenomeno.resolve(language),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.groups_rounded,
                        size: 16, color: AppTheme.primaryDark),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      variante.agrupamiento.resolve(language),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceSm),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final o in unidad.ordenesIngles)
                    SteamPastilla(
                      icono: Icons.record_voice_over_rounded,
                      texto: o.en,
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spaceMd),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  key: ValueKey('abrir_steam_${unidad.id}'),
                  onPressed: onAbrir,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryInk,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(AppTheme.touchMin),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusButton),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    SteamTextos.abrirSesion.resolve(language),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
