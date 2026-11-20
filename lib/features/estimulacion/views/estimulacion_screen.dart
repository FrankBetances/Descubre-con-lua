import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/imaxe_escena.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/movimiento.dart';
import '../../../data/models/plan_escoita_model.dart';
import '../../docentes/nomes_docentes.dart';
import '../../familias/nomes_familias.dart';
import '../../familias/widgets/selector_idade.dart';
import '../../leccions/widgets/proxecto_0_2.dart';
import '../data/estimulacion_ui.dart';

/// P9.3 · Sección propia «Estimulación da linguaxe e o pensamento».
///
/// Reúne por edad y por los 10 meses del curso los cuatro bloques ordenados:
///   1. Escoita (o par mínimo con láminas e son),
///   2. Palabras que medran (progresión en catro pasos),
///   3. Fálalle así (modelo da persoa adulta en voz child + slow),
///   4. Pensamos (predice → proba → compara → explica no experimento STEAM).
///
/// En Modo Aula (`enAula: true`) mostra a guía para a asemblea, onde a
/// docente guía e o grupo responde en coro ou sinala á vez.
class EstimulacionScreen extends StatefulWidget {
  const EstimulacionScreen({
    super.key,
    required this.language,
    required this.onLanguageChanged,
    this.audioService,
    this.initialCursoId = 'curso_3_4',
    this.initialMes = 1,
    this.enAula = false,
    this.onCambiarCurso,
  });

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final OfflineAudioService? audioService;
  final String initialCursoId;

  /// Mes del curso escolar: 1 (Septiembre) a 10 (Junio).
  final int initialMes;
  final bool enAula;
  final ValueChanged<String>? onCambiarCurso;

  @override
  State<EstimulacionScreen> createState() => _EstimulacionScreenState();
}

class _EstimulacionScreenState extends State<EstimulacionScreen> {
  late AppLanguage _lang = widget.language;
  late String _cursoId = widget.initialCursoId;
  late int _mes = widget.initialMes.clamp(1, 10);

  EstimulacionUi? _ui = EstimulacionUi.lido;
  PlanEscoita? _plan = PlanEscoita.lido;
  Proxectos02? _proxectos = Proxectos02.lidos;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant EstimulacionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) {
      _lang = widget.language;
    }
  }

  Future<void> _cargar() async {
    final res = await Future.wait<Object?>([
      EstimulacionUi.cargar(),
      PlanEscoita.cargar(),
      Proxectos02.cargar(),
    ]);
    if (!mounted) return;
    setState(() {
      _ui = res[0] as EstimulacionUi;
      _plan = res[1] as PlanEscoita;
      _proxectos = res[2] as Proxectos02;
    });
  }

  void _cambiarCurso(String novoCurso) {
    setState(() => _cursoId = novoCurso);
    widget.onCambiarCurso?.call(novoCurso);
  }

  void _cambiarMes(int novoMes) {
    setState(() => _mes = novoMes);
  }

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    final ui = _ui;
    final mesCalendario = EstimulacionUi.calendarioDeMes(_mes);
    final peza = _cursoId == 'curso_0_2' ? null : _plan?.de(_cursoId, _mes);
    final proxecto =
        _cursoId == 'curso_0_2' ? _proxectos?.doMes(mesCalendario) : null;
    final steamTitulo = _cursoId == 'curso_0_2'
        ? proxecto?.steam?.resolve(lang)
        : peza?.steamTitulo.resolve(lang);

    final tituloCabecera = widget.enAula
        ? NomesDocentes.estimulacionCabeceira.resolve(lang)
        : NomesFamilias.estimulacionCabeceira.resolve(lang);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: tituloCabecera,
        language: lang,
        onLanguageChanged: (nova) {
          setState(() => _lang = nova);
          widget.onLanguageChanged(nova);
        },
      ),
      body: SafeArea(
        child: ui == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('estimulacion_screen'),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 32),
                children: [
                  Entrada(
                    orden: 0,
                    child: _CabeceraSeccion(
                      ui: ui,
                      lang: lang,
                      enAula: widget.enAula,
                      cursoId: _cursoId,
                      mes: _mes,
                      steamTitulo: steamTitulo,
                      onCambiarCurso: _cambiarCurso,
                      onCambiarMes: _cambiarMes,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_cursoId == 'curso_0_2')
                    if (proxecto != null)
                      Entrada(
                        orden: 1,
                        child: _BloqueZeroDous(
                          ui: ui,
                          proxecto: proxecto,
                          lang: lang,
                          enAula: widget.enAula,
                          audioService: widget.audioService,
                        ),
                      )
                    else
                      const Center(child: CircularProgressIndicator())
                  else if (peza != null) ...[
                    Entrada(
                      orden: 1,
                      child: _BloqueEscoita(
                        ui: ui,
                        peza: peza,
                        lang: lang,
                        enAula: widget.enAula,
                        audioService: widget.audioService,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrada(
                      orden: 2,
                      child: _BloqueProgresion(
                        ui: ui,
                        peza: peza,
                        lang: lang,
                        enAula: widget.enAula,
                        audioService: widget.audioService,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Entrada(
                      orden: 3,
                      child: _BloqueModelo(
                        ui: ui,
                        peza: peza,
                        lang: lang,
                        enAula: widget.enAula,
                        audioService: widget.audioService,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (peza.pensamiento case final pens?)
                      Entrada(
                        orden: 4,
                        child: _BloquePensamos(
                          ui: ui,
                          peza: peza,
                          pens: pens,
                          lang: lang,
                          enAula: widget.enAula,
                          audioService: widget.audioService,
                        ),
                      ),
                  ],
                ],
              ),
      ),
    );
  }
}

class _CabeceraSeccion extends StatelessWidget {
  const _CabeceraSeccion({
    required this.ui,
    required this.lang,
    required this.enAula,
    required this.cursoId,
    required this.mes,
    required this.steamTitulo,
    required this.onCambiarCurso,
    required this.onCambiarMes,
  });

  final EstimulacionUi ui;
  final AppLanguage lang;
  final bool enAula;
  final String cursoId;
  final int mes;
  final String? steamTitulo;
  final ValueChanged<String> onCambiarCurso;
  final ValueChanged<int> onCambiarMes;

  @override
  Widget build(BuildContext context) {
    final mesInfo = ui.mesUi(mes);
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: const LaminaEscena(
                  clave: 'ico_estimulacion',
                  ancho: 52,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: context.acentoTint,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        (enAula ? ui.etiquetaAula : ui.etiquetaCasa)
                            .resolve(lang),
                        key: const Key('estimulacion_etiqueta_modo'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: context.acento,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ui.titulo.resolve(lang),
                      key: const Key('estimulacion_titulo'),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontTitulos,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            (enAula ? ui.subtituloAula : ui.subtituloCasa).resolve(lang),
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          if (enAula) ...[
            const SizedBox(height: 10),
            Container(
              key: const Key('estimulacion_guia_asemblea'),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.acentoTint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                ui.guiaAsemblea.resolve(lang),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SelectorIdade(
                cursoId: cursoId,
                language: lang,
                paraAula: enAula,
                onCambiar: onCambiarCurso,
              ),
              Container(
                key: const Key('estimulacion_mes_actual'),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.pageBg,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  '${ui.mesActual.resolve(lang)} $mes · ${mesInfo.nome.resolve(lang)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (steamTitulo != null && steamTitulo!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              key: const Key('estimulacion_steam_banner'),
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE8C587)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ui.experimentoMes.resolve(lang).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: Color(0xFF9A5B00),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    steamTitulo!,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontTitulos,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
          Text(
            ui.mesesNav.resolve(lang).toUpperCase(),
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final m in ui.meses)
                ChoiceChip(
                  key: ValueKey('estimulacion_mes_${m.mes}'),
                  label: Text('${m.mes} · ${m.curto.resolve(lang)}'),
                  selected: m.mes == mes,
                  selectedColor: context.acentoTint,
                  labelStyle: TextStyle(
                    fontWeight:
                        m.mes == mes ? FontWeight.w800 : FontWeight.w600,
                    color: m.mes == mes ? context.acento : AppTheme.textPrimary,
                  ),
                  side: BorderSide(
                    color: m.mes == mes ? context.acento : AppTheme.border,
                  ),
                  onSelected: (_) => onCambiarMes(m.mes),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TarxetaBloque extends StatelessWidget {
  const _TarxetaBloque({
    super.key,
    required this.numero,
    required this.titulo,
    required this.subtitulo,
    required this.fillo,
  });

  final String numero;
  final String titulo;
  final String subtitulo;
  final Widget fillo;

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
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.acento,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  numero,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitulos,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitulos,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitulo,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 14),
          fillo,
        ],
      ),
    );
  }
}

class _BloqueEscoita extends StatelessWidget {
  const _BloqueEscoita({
    required this.ui,
    required this.peza,
    required this.lang,
    required this.enAula,
    required this.audioService,
  });

  final EstimulacionUi ui;
  final PezaMensual peza;
  final AppLanguage lang;
  final bool enAula;
  final OfflineAudioService? audioService;

  Widget _parItem(PalabraEscoita p) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p.lamina case final c?)
            LaminaPalabra(
              clave: c,
              significado: p.significado.resolve(lang),
              lang: lang,
              ancho: 120,
            ),
          const SizedBox(height: 6),
          BotonEscuchar(
            audioService: audioService,
            texto: p.en,
            language: AppLanguage.en,
            interfaz: lang,
            style: estiloIngles(p.en, paraNeno: true),
            conVozLenta: true,
            comoChip: true,
            descripcion: p.en,
            significado: p.significado,
          ),
          const SizedBox(height: 4),
          Text(
            p.significado.resolve(lang),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final b = ui.escoita;
    return _TarxetaBloque(
      key: const Key('bloque_estimulacion_escoita'),
      numero: b.numero,
      titulo: b.titulo.resolve(lang),
      subtitulo: (enAula ? b.subtituloAula : b.subtituloCasa).resolve(lang),
      fillo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.spaceEvenly,
            children: [
              SizedBox(width: 138, child: _parItem(peza.a)),
              SizedBox(width: 138, child: _parItem(peza.b)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: context.acentoTint,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${b.fonemaRotulo.resolve(lang)}: ${peza.fonema}',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: context.acento,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            peza.nota.resolve(lang),
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.4,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BloqueProgresion extends StatelessWidget {
  const _BloqueProgresion({
    required this.ui,
    required this.peza,
    required this.lang,
    required this.enAula,
    required this.audioService,
  });

  final EstimulacionUi ui;
  final PezaMensual peza;
  final AppLanguage lang;
  final bool enAula;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final b = ui.progresion;
    return _TarxetaBloque(
      key: const Key('bloque_estimulacion_progresion'),
      numero: b.numero,
      titulo: b.titulo.resolve(lang),
      subtitulo: (enAula ? b.subtituloAula : b.subtituloCasa).resolve(lang),
      fillo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            peza.tema.resolve(lang),
            style: const TextStyle(
              fontFamily: AppTheme.fontTitulos,
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          for (final f in peza.fases)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (f.lamina case final c?) ...[
                    LaminaPalabra(
                      clave: c,
                      significado: f.significado.resolve(lang),
                      lang: lang,
                      ancho: 72,
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (b.fases[f.tipo] ??
                                  LocalizedString(gl: f.tipo, es: f.tipo))
                              .resolve(lang),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                            color: context.acento,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            BotonEscuchar(
                              audioService: audioService,
                              texto: f.en,
                              language: AppLanguage.en,
                              interfaz: lang,
                              style: estiloIngles(f.en, paraNeno: true),
                              conVozLenta: true,
                              comoChip: true,
                              descripcion: f.en,
                              significado: f.significado,
                            ),
                            if (f.frase.isNotEmpty)
                              BotonEscuchar(
                                audioService: audioService,
                                texto: f.frase,
                                language: AppLanguage.en,
                                interfaz: lang,
                                style: estiloIngles(f.frase, paraNeno: true),
                                conVozLenta: true,
                                comoChip: true,
                                descripcion: f.frase,
                                significado: f.accion,
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          f.accion.resolve(lang),
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BloqueModelo extends StatelessWidget {
  const _BloqueModelo({
    required this.ui,
    required this.peza,
    required this.lang,
    required this.enAula,
    required this.audioService,
  });

  final EstimulacionUi ui;
  final PezaMensual peza;
  final AppLanguage lang;
  final bool enAula;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final b = ui.modelo;
    return _TarxetaBloque(
      key: const Key('bloque_estimulacion_modelo'),
      numero: b.numero,
      titulo: b.titulo.resolve(lang),
      subtitulo: (enAula ? b.subtituloAula : b.subtituloCasa).resolve(lang),
      fillo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.pageBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${b.seDi.resolve(lang)} «${peza.neno}»',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < peza.adulto.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotonEscuchar(
                    audioService: audioService,
                    texto: peza.adulto[i],
                    language: AppLanguage.en,
                    interfaz: lang,
                    style: estiloIngles(peza.adulto[i], paraNeno: true),
                    conVozLenta: true,
                    comoChip: true,
                    descripcion: peza.adulto[i],
                    significado: i < peza.adultoSignificado.length
                        ? peza.adultoSignificado[i]
                        : null,
                  ),
                  if (i < peza.adultoSignificado.length) ...[
                    const SizedBox(height: 2),
                    Text(
                      peza.adultoSignificado[i].resolve(lang),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            peza.notaModelo.resolve(lang),
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BloquePensamos extends StatelessWidget {
  const _BloquePensamos({
    required this.ui,
    required this.peza,
    required this.pens,
    required this.lang,
    required this.enAula,
    required this.audioService,
  });

  final EstimulacionUi ui;
  final PezaMensual peza;
  final PensamientoSteam pens;
  final AppLanguage lang;
  final bool enAula;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final b = ui.pensamos;
    final idadeLabel = b.idadeModo[pens.edadModo];
    return _TarxetaBloque(
      key: const Key('bloque_estimulacion_pensamos'),
      numero: b.numero,
      titulo: b.titulo.resolve(lang),
      subtitulo: (enAula ? b.subtituloAula : b.subtituloCasa).resolve(lang),
      fillo: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (idadeLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  idadeLabel.resolve(lang),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: context.acento,
                  ),
                ),
              ),
            ),
          for (final m in pens.momentos) _momentoCard(context, b, m),
        ],
      ),
    );
  }

  Widget _momentoCard(
    BuildContext context,
    BloquePensamosUi b,
    MomentoPensamiento m,
  ) {
    final info = b.momentos[m.clave];
    final titulo =
        info != null ? '${info.orde}. ${info.nome.resolve(lang)}' : m.clave;
    return Container(
      key: ValueKey('estimulacion_momento_${m.clave}'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFCFBF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontFamily: AppTheme.fontTitulos,
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: context.acento,
            ),
          ),
          const SizedBox(height: 8),
          BotonEscuchar(
            audioService: audioService,
            texto: m.preguntaEn,
            language: AppLanguage.en,
            interfaz: lang,
            style: estiloIngles(m.preguntaEn, paraNeno: true),
            conVozLenta: true,
            comoChip: true,
            descripcion: m.preguntaEn,
            significado: m.significado,
          ),
          const SizedBox(height: 6),
          Text(
            '${b.significado.resolve(lang)}: ${m.significado.resolve(lang)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${b.guia.resolve(lang)}: ${m.guia.resolve(lang)}',
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${b.observar.resolve(lang)}: ${m.observar.resolve(lang)}',
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.35,
              color: AppTheme.textSecondary,
            ),
          ),
          if (m.modeloEn != null && m.modeloEn!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '${b.modeloAdulto.resolve(lang)}:',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            BotonEscuchar(
              audioService: audioService,
              texto: m.modeloEn!,
              language: AppLanguage.en,
              interfaz: lang,
              style: estiloIngles(m.modeloEn!, paraNeno: true),
              conVozLenta: true,
              comoChip: true,
              descripcion: m.modeloEn!,
              significado: m.modeloSignificado,
            ),
            if (m.modeloSignificado != null) ...[
              const SizedBox(height: 2),
              Text(
                m.modeloSignificado!.resolve(lang),
                style: const TextStyle(
                  fontSize: 13.5,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ],
          if (enAula && info != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.acentoTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                info.aula.resolve(lang),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: context.acento,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BloqueZeroDous extends StatelessWidget {
  const _BloqueZeroDous({
    required this.ui,
    required this.proxecto,
    required this.lang,
    required this.enAula,
    required this.audioService,
  });

  final EstimulacionUi ui;
  final Proxecto02 proxecto;
  final AppLanguage lang;
  final bool enAula;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final mira = proxecto.miraENota;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TarxetaBloque(
          key: const Key('bloque_estimulacion_0_2'),
          numero: '1',
          titulo: proxecto.titulo.resolve(lang),
          subtitulo: ui.zeroDousSenPreguntas.resolve(lang),
          fillo: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  ui.zeroDousEtiqueta.resolve(lang),
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: context.acento,
                  ),
                ),
              ),
              if (enAula) ...[
                const SizedBox(height: 8),
                Text(
                  ui.zeroDousAulaNota.resolve(lang),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
              if (mira != null) ...[
                const SizedBox(height: 12),
                Text(
                  mira.titulo.resolve(lang),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontTitulos,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                BotonEscuchar(
                  audioService: audioService,
                  texto: mira.fraseEn,
                  language: AppLanguage.en,
                  interfaz: lang,
                  style: estiloIngles(mira.fraseEn, paraNeno: true),
                  conVozLenta: true,
                  comoChip: true,
                  descripcion: mira.fraseEn,
                  significado: mira.significado,
                ),
                const SizedBox(height: 6),
                Text(
                  '${ui.pensamos.significado.resolve(lang)}: ${mira.significado.resolve(lang)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ui.pensamos.guia.resolve(lang)}: ${mira.guia.resolve(lang)}',
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${ui.pensamos.observar.resolve(lang)}: ${mira.observar.resolve(lang)}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Text(
                ui.zeroDousPalabras.resolve(lang),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final pal in proxecto.palabras.take(6))
                    Container(
                      width: 146,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.pageBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          if (pal.lamina case final c?)
                            LaminaPalabra(
                              clave: c,
                              significado: pal.significado.resolve(lang),
                              lang: lang,
                              ancho: 68,
                            ),
                          const SizedBox(height: 4),
                          BotonEscuchar(
                            audioService: audioService,
                            texto: pal.en,
                            language: AppLanguage.en,
                            interfaz: lang,
                            style: estiloIngles(pal.en, paraNeno: true),
                            conVozLenta: true,
                            comoChip: true,
                            descripcion: pal.en,
                            significado: pal.significado,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
