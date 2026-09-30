import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/steam_model.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../widgets/steam_comun.dart';

/// La sesión de una unidad STEAM, para la persona adulta.
///
/// Se lee de arriba abajo en el orden en que se hace: seguridad, cómo os
/// organizáis, qué preparar, y los tres pasos. La criatura no mira la
/// pantalla: toca los materiales y escucha a la persona adulta.
///
/// No registra nada. La primera versión tenía tres botones de «registro» que
/// no guardaban nada y evaluaban a una sola criatura en un juego de pareja; lo
/// que queda es qué mirar mientras juegan, y se lee, no se puntúa.
class SteamSesionGuiadaScreen extends StatefulWidget {
  final SteamUnit unit;
  final SteamAudiencia audiencia;

  /// Sin él la sesión se lee igual: los altavoces no se pintan.
  final OfflineAudioService? audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SteamSesionGuiadaScreen({
    super.key,
    required this.unit,
    required this.audiencia,
    required this.audioService,
    required this.initialLanguage,
    this.onLanguageChanged,
  });

  @override
  State<SteamSesionGuiadaScreen> createState() =>
      _SteamSesionGuiadaScreenState();
}

class _SteamSesionGuiadaScreenState extends State<SteamSesionGuiadaScreen> {
  late AppLanguage _language;

  Timer? _reloxo;
  int _quedan = 0;
  bool _contando = false;
  bool _pausaFeita = false;

  bool _pista1 = false;
  bool _pista2 = false;

  static const _seguridade = LocalizedString(
      gl: 'Antes de empezar: seguridade', es: 'Antes de empezar: seguridad');
  static const _organizacion =
      LocalizedString(gl: 'Como vos organizades', es: 'Cómo os organizáis');
  static const _materiais =
      LocalizedString(gl: 'Que preparar', es: 'Qué preparar');
  static const _paso1 =
      LocalizedString(gl: 'Paso 1 · Observa', es: 'Paso 1 · Observa');
  static const _paso2 =
      LocalizedString(gl: 'Paso 2 · Experimenta', es: 'Paso 2 · Experimenta');
  static const _paso3 =
      LocalizedString(gl: 'Paso 3 · Constrúe', es: 'Paso 3 · Construye');
  static const _pregunta = LocalizedString(gl: 'A pregunta', es: 'La pregunta');
  static const _peche = LocalizedString(gl: 'Para pechar', es: 'Para cerrar');
  static const _pistaN1 = LocalizedString(
      gl: 'Se precisa axuda: pista 1', es: 'Si necesita ayuda: pista 1');
  static const _pistaN2 = LocalizedString(
      gl: 'Se aínda precisa axuda: pista 2',
      es: 'Si todavía necesita ayuda: pista 2');
  static const _ordes =
      LocalizedString(gl: 'Ordes en inglés', es: 'Órdenes en inglés');
  static const _ordesAxuda = LocalizedString(
    gl: 'Escóitaa antes de dicila. A criatura responde co corpo: non ten que repetila.',
    es: 'Escúchala antes de decirla. La criatura responde con el cuerpo: no tiene que repetirla.',
  );
  static const _observar =
      LocalizedString(gl: 'Que observar', es: 'Qué observar');
  static const _observarNota = LocalizedString(
    gl: 'Non é unha avaliación: son pistas para ti. A app non garda nada de ningunha criatura.',
    es: 'No es una evaluación: son pistas para ti. La app no guarda nada de ninguna criatura.',
  );
  static const _curriculo = LocalizedString(gl: 'Currículo', es: 'Currículo');

  static const _nomesArea = {
    'area_1_crecemento_harmonia': LocalizedString(
      gl: 'Área 1: Crecemento en harmonía',
      es: 'Área 1: Crecimiento en armonía',
    ),
    'area_2_descubrimento_contorna': LocalizedString(
      gl: 'Área 2: Descubrimento e exploración da contorna',
      es: 'Área 2: Descubrimiento y exploración del entorno',
    ),
    'area_3_comunicacion_representacion': LocalizedString(
      gl: 'Área 3: Comunicación e representación da realidade',
      es: 'Área 3: Comunicación y representación de la realidad',
    ),
  };

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  void didUpdateWidget(covariant SteamSesionGuiadaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

  @override
  void dispose() {
    _reloxo?.cancel();
    super.dispose();
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  void _empezarPausa(int segundos) {
    _reloxo?.cancel();
    setState(() {
      _quedan = segundos;
      _contando = true;
      _pausaFeita = false;
    });
    _reloxo = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _quedan--;
        if (_quedan <= 0) {
          t.cancel();
          _contando = false;
          _pausaFeita = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.unit;
    final variante = unit.variante(widget.audiencia);
    final ciclo = variante.ciclo;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          unit.titulo.resolve(_language),
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
        child: ListView(
          key: const ValueKey('steam_sesion_lista'),
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            _cabecera(unit),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              key: const ValueKey('steam_seguridade'),
              icono: Icons.health_and_safety_rounded,
              titulo: _seguridade,
              tinta: AppTheme.warning,
              fondo: AppTheme.warningBg,
              children: [_textoConVoz(unit.avisoSeguridad, _seguridade)],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              icono: Icons.groups_rounded,
              titulo: _organizacion,
              children: [
                _textoConVoz(variante.agrupamiento, _organizacion),
                for (final rol in variante.roles) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  _rol(rol),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              icono: Icons.inventory_2_outlined,
              titulo: _materiais,
              children: [
                for (final m in variante.materiales) _vinheta(m.item),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              key: const ValueKey('steam_paso_1'),
              icono: Icons.visibility_rounded,
              titulo: _paso1,
              children: [
                _textoConVoz(ciclo.planteamiento, _paso1),
                const SizedBox(height: AppTheme.spaceSm),
                _destacado(_pregunta, ciclo.preguntaIndagacion),
                const SizedBox(height: AppTheme.spaceSm),
                _botonPausa(ciclo.pausaSilencioSegundos),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              key: const ValueKey('steam_paso_2'),
              icono: Icons.pan_tool_alt_rounded,
              titulo: _paso2,
              children: [
                _textoConVoz(ciclo.consignaAdulto, _paso2),
                const SizedBox(height: AppTheme.spaceSm),
                _pista(
                  clave: 'steam_pista_1',
                  titulo: _pistaN1,
                  texto: ciclo.pistaN1,
                  aberta: _pista1,
                  onTap: () => setState(() => _pista1 = !_pista1),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                _pista(
                  clave: 'steam_pista_2',
                  titulo: _pistaN2,
                  texto: ciclo.pistaN2,
                  aberta: _pista2,
                  onTap: () => setState(() => _pista2 = !_pista2),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              key: const ValueKey('steam_paso_3'),
              icono: Icons.construction_rounded,
              titulo: _paso3,
              children: [
                _textoConVoz(ciclo.retoTangible, _paso3),
                const SizedBox(height: AppTheme.spaceSm),
                _destacado(_peche, ciclo.sintesisCierre),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              key: const ValueKey('steam_ordes'),
              icono: Icons.record_voice_over_rounded,
              titulo: _ordes,
              children: [
                Text(
                  _ordesAxuda.resolve(_language),
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                for (final orden in unit.ordenesIngles) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  _orden(orden),
                ],
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            _seccion(
              key: const ValueKey('steam_observar'),
              icono: Icons.lightbulb_outline_rounded,
              titulo: _observar,
              children: [
                for (final q in unit.queObservar) _vinheta(q, conVoz: true),
                const SizedBox(height: AppTheme.spaceSm),
                Text(
                  _observarNota.resolve(_language),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
            if (widget.audiencia == SteamAudiencia.aula) ...[
              const SizedBox(height: AppTheme.spaceMd),
              _seccion(
                key: const ValueKey('steam_curriculo'),
                icono: Icons.menu_book_rounded,
                titulo: _curriculo,
                children: [_curriculoTexto(unit.curriculo)],
              ),
            ],
            const SizedBox(height: AppTheme.spaceXl),
          ],
        ),
      ),
    );
  }

  Widget _cabecera(SteamUnit unit) {
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              SteamDatosUnidad(unidad: unit, language: _language),
              SteamPastilla(
                icono: aula ? Icons.school_rounded : Icons.home_rounded,
                texto:
                    SteamTextos.audiencia(widget.audiencia).resolve(_language),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            unit.titulo.resolve(_language),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unit.fenomeno.resolve(_language),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
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

  Widget _seccion({
    Key? key,
    required IconData icono,
    required LocalizedString titulo,
    required List<Widget> children,
    Color tinta = AppTheme.primaryInk,
    Color fondo = AppTheme.card,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: fondo == AppTheme.card ? AppTheme.border : tinta.withAlpha(60),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icono, size: 20, color: tinta),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titulo.resolve(_language),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: tinta,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          ...children,
        ],
      ),
    );
  }

  Widget _boton(LocalizedString texto, LocalizedString que) => BotonEscuchar(
        audioService: widget.audioService,
        texto: texto.resolve(_language),
        language: _language,
        compacto: true,
        descripcion: que.resolve(_language),
      );

  /// Un párrafo con su altavoz al lado. El altavoz solo aparece si la
  /// grabación existe: lo decide `BotonEscuchar`.
  Widget _textoConVoz(LocalizedString texto, LocalizedString que) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            texto.resolve(_language),
            style: const TextStyle(
              fontSize: 14.5,
              color: AppTheme.textPrimary,
              height: 1.45,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _boton(texto, que),
      ],
    );
  }

  Widget _destacado(LocalizedString rotulo, LocalizedString texto) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: steamFondo,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo.resolve(_language).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: steamTinta,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  texto.resolve(_language),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _boton(texto, rotulo),
        ],
      ),
    );
  }

  Widget _botonPausa(int segundos) {
    final LocalizedString texto;
    if (_contando) {
      texto = LocalizedString(
        gl: 'En silencio… quedan $_quedan s',
        es: 'En silencio… quedan $_quedan s',
      );
    } else if (_pausaFeita) {
      texto = const LocalizedString(
        gl: 'Feito. Agora deixa que respondan co corpo ou coas palabras.',
        es: 'Hecho. Ahora deja que respondan con el cuerpo o con palabras.',
      );
    } else {
      texto = LocalizedString(
        gl: 'Agarda $segundos segundos en silencio',
        es: 'Espera $segundos segundos en silencio',
      );
    }
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        key: const ValueKey('steam_pausa'),
        onPressed: _contando ? null : () => _empezarPausa(segundos),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(AppTheme.touchMin),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          side: BorderSide(
            color: _pausaFeita ? AppTheme.success : AppTheme.borderActive,
          ),
          backgroundColor: _pausaFeita ? AppTheme.successBg : AppTheme.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
        ),
        icon: Icon(
          _pausaFeita
              ? Icons.check_circle_outline_rounded
              : Icons.hourglass_top_rounded,
          size: 20,
          color: _pausaFeita ? AppTheme.success : AppTheme.primaryInk,
        ),
        label: Text(
          texto.resolve(_language),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _pista({
    required String clave,
    required LocalizedString titulo,
    required LocalizedString texto,
    required bool aberta,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: ValueKey(clave),
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo.resolve(_language),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryInk,
                        ),
                      ),
                    ),
                    Icon(
                      aberta
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      color: AppTheme.primaryInk,
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (aberta)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: _textoConVoz(texto, titulo),
            ),
        ],
      ),
    );
  }

  Widget _rol(SteamRol rol) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.badge_outlined, size: 18, color: steamTinta),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rol.nombre.resolve(_language),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rol.mision.resolve(_language),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vinheta(LocalizedString texto, {bool conVoz = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 7, right: 8),
            child: Icon(Icons.circle, size: 7, color: AppTheme.primaryDark),
          ),
          Expanded(
            child: Text(
              texto.resolve(_language),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.45,
              ),
            ),
          ),
          if (conVoz) ...[
            const SizedBox(width: 8),
            _boton(texto, _observar),
          ],
        ],
      ),
    );
  }

  Widget _orden(SteamOrdenIngles orden) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              BotonEscuchar(
                audioService: widget.audioService,
                texto: orden.en,
                language: AppLanguage.en,
                style: estiloIngles(orden.en),
                comoChip: true,
                colorChip: steamTinta,
                descripcion: orden.accion.resolve(_language),
              ),
              if (orden.ipa.isNotEmpty)
                Text(
                  orden.ipa,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            orden.accion.resolve(_language),
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _curriculoTexto(SteamCurriculo c) {
    final isGl = _language == AppLanguage.gl;
    final lineas = <String>[
      c.normativa,
      for (final a in c.areas) _nomesArea[a]?.resolve(_language) ?? a,
      if (c.criteriosEvaluacion.isNotEmpty)
        '${isGl ? 'Criterios de avaliación' : 'Criterios de evaluación'}: '
            '${c.criteriosEvaluacion.join(', ')}',
      if (c.competenciasClave.isNotEmpty)
        '${isGl ? 'Competencias clave' : 'Competencias clave'}: '
            '${c.competenciasClave.join(', ')}',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final l in lineas)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              l,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }
}
