import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../docentes/nomes_docentes.dart';
import '../../familias/nomes_familias.dart';
import '../../familias/widgets/selector_idade.dart';
import '../ar/ar_bridge.dart';
import '../data/ar_estimulacion_model.dart';
import '../data/estimulacion_ui.dart';

class ArActividadScreen extends StatefulWidget {
  const ArActividadScreen({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    this.audioService,
    this.initialCursoId = 'curso_3_4',
    this.initialMes = 1,
    this.enAula = false,
    this.arBridge = const MethodChannelArBridge(),
    this.plan,
    this.ui,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final OfflineAudioService? audioService;
  final String initialCursoId;
  final int initialMes;
  final bool enAula;
  final ArBridge arBridge;
  final ArEstimulacionPlan? plan;
  final EstimulacionUi? ui;

  @override
  State<ArActividadScreen> createState() => _ArActividadScreenState();
}

class _ArActividadScreenState extends State<ArActividadScreen> {
  late AppLanguage _lang;
  late String _cursoId;
  late int _mes;
  ArEstimulacionPlan? _plan;
  EstimulacionUi? _ui;
  ArAvailability? _availability;
  String? _statusMessage;
  bool _senCamaraAberto = false;

  @override
  void initState() {
    super.initState();
    _lang = widget.language;
    _cursoId = widget.initialCursoId == 'curso_0_2'
        ? 'curso_2_3'
        : widget.initialCursoId;
    _mes = widget.initialMes.clamp(1, 10);
    _plan = widget.plan;
    _ui = widget.ui;
    _cargar();
  }

  Future<void> _cargar() async {
    final p = _plan ?? await ArEstimulacionPlan.cargar();
    final u = _ui ?? await EstimulacionUi.cargar();
    final av = await widget.arBridge.checkAvailability();
    if (!mounted) return;
    setState(() {
      _plan = p;
      _ui = u;
      _availability = av;
      if (!av.available) {
        _senCamaraAberto = true;
      }
    });
  }

  Future<void> _abrirMesa(ArEscenaMensual escena, EstimulacionUi ui) async {
    final av = _availability ?? await widget.arBridge.checkAvailability();
    if (!mounted) return;
    if (!av.available) {
      setState(() {
        _availability = av;
        _senCamaraAberto = true;
        _statusMessage = ui.ra.avisoSenArcore.resolve(_lang);
      });
      return;
    }
    final res = await widget.arBridge.openScene(escena.toNativeSpecJson(_lang));
    if (!mounted) return;
    setState(() {
      if (res.needsFallback) {
        _senCamaraAberto = true;
        _statusMessage = ui.ra.avisoSenArcore.resolve(_lang);
      } else {
        _statusMessage = _lang == AppLanguage.gl
            ? 'Escena rematada (${res.confirmed.length} pasos confirmados).'
            : 'Escena terminada (${res.confirmed.length} pasos confirmados).';
      }
    });
  }

  Future<void> _abrirEspello(
      ArActividadFacial facial, EstimulacionUi ui) async {
    final av = _availability ?? await widget.arBridge.checkAvailability();
    if (!mounted) return;
    if (!av.available || !av.hasFrontCamera) {
      setState(() {
        _availability = av;
        _senCamaraAberto = true;
        _statusMessage = ui.ra.avisoSenArcore.resolve(_lang);
      });
      return;
    }
    final res =
        await widget.arBridge.openFaceActivity(facial.toNativeSpecJson(_lang));
    if (!mounted) return;
    setState(() {
      if (res.needsFallback) {
        _senCamaraAberto = true;
        _statusMessage = ui.ra.avisoSenArcore.resolve(_lang);
      } else {
        _statusMessage = res.gestureDone
            ? (_lang == AppLanguage.gl
                ? 'Xesto de Lúa completado!'
                : '¡Gesto de Lúa completado!')
            : (_lang == AppLanguage.gl
                ? 'Espello pechado.'
                : 'Espejo cerrado.');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ui = _ui;
    final plan = _plan;
    final lang = _lang;
    final titulo = widget.enAula
        ? NomesDocentes.realidadeAumentadaCabeceira.resolve(lang)
        : NomesFamilias.realidadeAumentadaCabeceira.resolve(lang);

    final escena = plan?.escenaDe(_cursoId, _mes);
    final facial = escena != null ? plan?.facialDe(escena.faceId) : null;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: titulo,
        language: lang,
        onLanguageChanged: (nova) {
          setState(() => _lang = nova);
          widget.onLanguageChanged(nova);
        },
      ),
      body: SafeArea(
        child: ui == null || escena == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('ar_actividad_screen'),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                children: [
                  _CabeceraRa(
                    ui: ui,
                    lang: lang,
                    enAula: widget.enAula,
                    cursoId: _cursoId,
                    mes: _mes,
                    escena: escena,
                    onCambiarCurso: (c) => setState(() {
                      _cursoId = c == 'curso_0_2' ? 'curso_2_3' : c;
                    }),
                    onCambiarMes: (m) => setState(() => _mes = m),
                  ),
                  const SizedBox(height: 14),
                  if (_statusMessage != null ||
                      (_availability != null && !_availability!.available))
                    Container(
                      key: const Key('ar_aviso_sen_camara'),
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.warningBg,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusCard),
                        border:
                            Border.all(color: AppTheme.warning.withAlpha(140)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.info_outline_rounded,
                              color: AppTheme.textPrimary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _statusMessage ??
                                  ui.ra.avisoSenArcore.resolve(lang),
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.35,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  _TarxetaEscenaRa(
                    ui: ui,
                    lang: lang,
                    escena: escena,
                    audioService: widget.audioService,
                    onAbrirMesa: () => _abrirMesa(escena, ui),
                    onAlternarSenCamara: () =>
                        setState(() => _senCamaraAberto = !_senCamaraAberto),
                    senCamaraAberto: _senCamaraAberto,
                  ),
                  if (facial != null) ...[
                    const SizedBox(height: 14),
                    _TarxetaEspelloFacial(
                      ui: ui,
                      lang: lang,
                      facial: facial,
                      audioService: widget.audioService,
                      onAbrirEspello: () => _abrirEspello(facial, ui),
                    ),
                  ],
                  if (_senCamaraAberto) ...[
                    const SizedBox(height: 14),
                    _VersionSenCamaraCard(
                      key: const Key('ar_version_sen_camara'),
                      ui: ui,
                      lang: lang,
                      escena: escena,
                      audioService: widget.audioService,
                    ),
                  ],
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      ui.ra.avisoPrivacidade.resolve(lang),
                      key: const Key('ar_privacidade_nota'),
                      style: const TextStyle(
                        fontSize: 13.5,
                        height: 1.35,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _CabeceraRa extends StatelessWidget {
  const _CabeceraRa({
    required this.ui,
    required this.lang,
    required this.enAula,
    required this.cursoId,
    required this.mes,
    required this.escena,
    required this.onCambiarCurso,
    required this.onCambiarMes,
  });

  final EstimulacionUi ui;
  final AppLanguage lang;
  final bool enAula;
  final String cursoId;
  final int mes;
  final ArEscenaMensual escena;
  final ValueChanged<String> onCambiarCurso;
  final ValueChanged<int> onCambiarMes;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: context.acento.withAlpha(70), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ui.ra.titulo.resolve(lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontTitulos,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            (enAula ? ui.ra.subtituloAula : ui.ra.subtituloCasa).resolve(lang),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              SelectorIdade(
                cursoId: cursoId,
                language: lang,
                paraAula: enAula,
                onCambiar: onCambiarCurso,
              ),
              Chip(
                label: Text(
                  '${escena.steamTitulo.resolve(lang)} (${escena.valeriaSceneId})',
                  style: const TextStyle(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in ui.meses)
                ChoiceChip(
                  label: Text(
                    m.curto.resolve(lang),
                    style: const TextStyle(fontSize: 13),
                  ),
                  selected: m.mes == mes,
                  onSelected: (_) => onCambiarMes(m.mes),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarxetaEscenaRa extends StatelessWidget {
  const _TarxetaEscenaRa({
    required this.ui,
    required this.lang,
    required this.escena,
    required this.audioService,
    required this.onAbrirMesa,
    required this.onAlternarSenCamara,
    required this.senCamaraAberto,
  });

  final EstimulacionUi ui;
  final AppLanguage lang;
  final ArEscenaMensual escena;
  final OfflineAudioService? audioService;
  final VoidCallback onAbrirMesa;
  final VoidCallback onAlternarSenCamara;
  final bool senCamaraAberto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            escena.titulo.resolve(lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontTitulos,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            escena.guiaAdulto.resolve(lang),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          BotonEscuchar(
            audioService: audioService,
            texto: escena.fraseCenaEn,
            language: AppLanguage.en,
            interfaz: lang,
            style: estiloIngles(escena.fraseCenaEn, paraNeno: true),
            conVozLenta: true,
            comoChip: true,
            descripcion: escena.fraseCenaEn,
            significado: escena.fraseCenaSig,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                key: const Key('ar_btn_abrir_mesa'),
                onPressed: onAbrirMesa,
                icon: const Icon(Icons.view_in_ar_rounded),
                label: Text(ui.ra.abrirMesa.resolve(lang)),
              ),
              OutlinedButton.icon(
                key: const Key('ar_btn_sen_camara'),
                onPressed: onAlternarSenCamara,
                icon: const Icon(Icons.photo_library_outlined),
                label: Text(ui.ra.modoSenCamara.resolve(lang)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarxetaEspelloFacial extends StatelessWidget {
  const _TarxetaEspelloFacial({
    required this.ui,
    required this.lang,
    required this.facial,
    required this.audioService,
    required this.onAbrirEspello,
  });

  final EstimulacionUi ui;
  final AppLanguage lang;
  final ArActividadFacial facial;
  final OfflineAudioService? audioService;
  final VoidCallback onAbrirEspello;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            facial.titulo.resolve(lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontTitulos,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            facial.guia.resolve(lang),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          BotonEscuchar(
            audioService: audioService,
            texto: facial.fraseEn,
            language: AppLanguage.en,
            interfaz: lang,
            style: estiloIngles(facial.fraseEn, paraNeno: true),
            conVozLenta: true,
            comoChip: true,
            descripcion: facial.fraseEn,
            significado: facial.sig,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('ar_btn_abrir_espello'),
            onPressed: onAbrirEspello,
            icon: const Icon(Icons.face_retouching_natural_rounded),
            label: Text(ui.ra.abrirEspello.resolve(lang)),
          ),
        ],
      ),
    );
  }
}

class _VersionSenCamaraCard extends StatelessWidget {
  const _VersionSenCamaraCard({
    super.key,
    required this.ui,
    required this.lang,
    required this.escena,
    required this.audioService,
  });

  final EstimulacionUi ui;
  final AppLanguage lang;
  final ArEscenaMensual escena;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: context.acento.withAlpha(90), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ui.ra.modoSenCamara.resolve(lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontTitulos,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            escena.fallbackInstrucion.resolve(lang),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          if (escena.laminasSuporte.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < escena.laminasSuporte.length; i++)
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pageBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        LaminaEscena(
                          clave: escena.laminasSuporte[i],
                          ancho: 76,
                        ),
                        if (i < escena.palabrasEn.length) ...[
                          const SizedBox(height: 6),
                          BotonEscuchar(
                            audioService: audioService,
                            texto: escena.palabrasEn[i],
                            language: AppLanguage.en,
                            interfaz: lang,
                            style: estiloIngles(escena.palabrasEn[i],
                                paraNeno: true),
                            comoChip: true,
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          for (final ev in escena.eventos) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.pageBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ev.label.resolve(lang),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ev.prompt.resolve(lang),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  BotonEscuchar(
                    audioService: audioService,
                    texto: ev.englishPhrase,
                    language: AppLanguage.en,
                    interfaz: lang,
                    style: estiloIngles(ev.englishPhrase, paraNeno: true),
                    conVozLenta: true,
                    comoChip: true,
                    descripcion: ev.englishPhrase,
                    significado: LocalizedString(
                      gl: ev.prompt.gl,
                      es: ev.prompt.es,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
