import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/dinamica_model.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../../data/repositories/content_repository.dart';
import '../../calendario/widgets/asemblea_do_dia.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../cuentos/views/cuento_viewer_screen.dart';
import '../../familias/widgets/selector_idade.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../../planificador/views/dinamicas_screen.dart';
import '../../steam/widgets/steam_no_calendario.dart';
import '../nomes_docentes.dart';
import '../widgets/hoxe_na_aula.dart'
    show DiaQueToca, ProxeccionDoCurso, formatarMiles;

/// «Hoxe», la portada de la docente: la asamblea de hoy, arriba, con sus
/// cuatro fases y un botón.
///
/// Debajo, lo que la acompaña: las palabras inglesas del día, el cuento de la
/// semana, la dinámica del día y, si toca, la ciencia. Antes la asamblea
/// estaba detrás de cinco pastillas de edad y de «Entrar en Modo Aula», y el
/// nivel y la racha ocupaban el sitio de arriba.
class HoxeDocentesScreen extends StatefulWidget {
  const HoxeDocentesScreen({
    super.key,
    required this.repository,
    required this.language,
    required this.onLanguageChanged,
    required this.cursoId,
    required this.onCambiarCurso,
    this.audioService,
    this.agora,
  });

  final ContentRepository repository;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final String cursoId;
  final ValueChanged<String> onCambiarCurso;
  final OfflineAudioService? audioService;
  final DateTime? agora;

  @override
  State<HoxeDocentesScreen> createState() => _HoxeDocentesScreenState();
}

class _HoxeDocentesScreenState extends State<HoxeDocentesScreen> {
  late DiaQueToca _toca = DiaQueToca.para(agora: widget.agora);
  Cuento? _conto;
  DinamicaPedagogica? _dinamica;
  SteamUnit? _steam;

  static const _diasClave = ['luns', 'martes', 'mercores', 'xoves', 'venres'];

  static const _semana = <LocalizedString>[
    LocalizedString(gl: 'Luns', es: 'Lunes'),
    LocalizedString(gl: 'Martes', es: 'Martes'),
    LocalizedString(gl: 'Mércores', es: 'Miércoles'),
    LocalizedString(gl: 'Xoves', es: 'Jueves'),
    LocalizedString(gl: 'Venres', es: 'Viernes'),
    LocalizedString(gl: 'Sábado', es: 'Sábado'),
    LocalizedString(gl: 'Domingo', es: 'Domingo'),
  ];

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant HoxeDocentesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cursoId != widget.cursoId) _cargar();
  }

  /// Cada cosa llega por su lado: la asamblea no espera al cuento.
  void _cargar() {
    _toca = DiaQueToca.para(agora: widget.agora);
    final curso = widget.cursoId;
    final repo = widget.repository;
    bool vixente() => mounted && curso == widget.cursoId;
    // Sin setState: se llama desde initState y didUpdateWidget, y en los dos
    // casos el build viene detrás.
    _conto = null;
    _steam = null;

    repo.loadCuentos(cursoId: curso, mesNumero: _toca.mesDoCurso).then((cs) {
      if (!vixente()) return;
      final daSemana =
          cs.where((c) => c.semanaSugerida == _toca.dia.semana).toList();
      Cuento? conto;
      for (final c in daSemana) {
        if (c.levaPalabras) {
          conto = c;
          break;
        }
      }
      setState(
          () => _conto = conto ?? (daSemana.isEmpty ? null : daSemana.first));
    });
    repo.loadDinamicas().then((ds) {
      if (!mounted) return;
      final clave = _diasClave[_toca.dia.dia - 1];
      DinamicaPedagogica? dinamica;
      for (final d in ds) {
        if (d.diaSemana == clave) {
          dinamica = d;
          break;
        }
      }
      setState(() => _dinamica = dinamica);
    });
    if (repo.programaTprSync == null) {
      repo.loadProgramaTpr().then((_) {
        if (mounted) setState(() {});
      });
    }
    repo.loadSteamUnits().then((_) {
      if (!vixente()) return;
      setState(() => _steam = steamDoDiaDoCurso(repo, curso, _toca.dia));
    });
  }

  GrupoDaAsemblea? get _grupo {
    for (final g
        in gruposDaAsembleaDoDia(widget.repository, _toca.dia.mesCalendario)) {
      if (cursoTprDoGrupo[g.clave] == widget.cursoId && g.disponible) return g;
    }
    return null;
  }

  String _data(AppLanguage lang) {
    final d = widget.agora ?? DateTime.now();
    final mes = nomeDoMes[d.month]?.resolve(lang).toLowerCase() ?? '';
    return '${_semana[d.weekday - 1].resolve(lang)}, ${d.day} de $mes';
  }

  String _diaQueToca(AppLanguage lang) =>
      _semana[_toca.dia.dia - 1].resolve(lang).toLowerCase();

  String _titulo(AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    if (_toca.prevista) {
      return isGl ? 'Para empezar en setembro' : 'Para empezar en septiembre';
    }
    if (_toca.finDeSemana) {
      return isGl
          ? 'A asemblea do ${_diaQueToca(lang)}'
          : 'La asamblea del ${_diaQueToca(lang)}';
    }
    return isGl ? 'A asemblea de hoxe' : 'La asamblea de hoy';
  }

  void _comezar(GrupoDaAsemblea grupo) {
    abrirAsembleaDoDia(
      context,
      repo: widget.repository,
      grupo: grupo,
      mesCalendario: _toca.dia.mesCalendario,
      semana: _toca.dia.semana,
      dia: _toca.dia.dia,
      language: widget.language,
      audioService: widget.audioService,
    );
  }

  void _abrirConto(Cuento conto) {
    Navigator.of(context).push(
      RutaLua(
        de: context,
        builder: (_) => CuentoViewerScreen(
          cuento: conto,
          language: widget.language,
          onLanguageChanged: widget.onLanguageChanged,
          audioService: widget.audioService,
          semanaTpr: switch (conto.semanaSugerida) {
            final semana? => widget.repository
                .cursoTprSync(conto.cursoId)
                ?.semanaPorOrden(conto.mesNumero, semana),
            null => null,
          },
          dia: _toca.eHoxe ? _toca.dia.dia : null,
        ),
      ),
    );
  }

  void _verPalabras(ProgramaTpr programa) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => ProxeccionDoCurso(
          programa: programa,
          language: widget.language,
          scrollController: scrollController,
          onPechar: () => Navigator.of(sheetContext).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final programa = widget.repository.programaTprSync;
    final curso = programa?.curso(widget.cursoId);
    final plan = curso?.planDoDia(
        _toca.dia.mesCalendario, _toca.dia.semana, _toca.dia.dia);
    final grupo = _grupo;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.hoxe.resolve(lang),
        language: lang,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('hoxe_docentes'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectorIdade(
                cursoId: widget.cursoId,
                language: lang,
                onCambiar: widget.onCambiarCurso,
                paraAula: true,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _data(lang).toUpperCase(),
              key: const Key('hoxe_aula_data'),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Semantics(
              header: true,
              child: Text(
                _titulo(lang),
                key: const Key('hoxe_aula_titulo'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (grupo != null)
              _TarxetaAsemblea(
                grupo: grupo,
                repository: widget.repository,
                toca: _toca,
                language: lang,
                onComezar: () => _comezar(grupo),
              )
            else
              Container(
                key: const Key('hoxe_aula_sen_asemblea'),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Text(
                  isGl
                      ? 'Este mes non ten asemblea escrita para este grupo.'
                      : 'Este mes no tiene asamblea escrita para este grupo.',
                  style: const TextStyle(
                    fontSize: 15.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            if (plan != null && curso != null && programa != null) ...[
              const SizedBox(height: 14),
              Card(
                key: const Key('hoxe_aula_palabras'),
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        isGl ? 'PALABRAS DE HOXE' : 'PALABRAS DE HOY',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      PalabrasDoDia(
                        plan: plan,
                        modeloDoDia: curso.modelo.dia(_toca.dia.dia),
                        semana: curso.semana(
                            _toca.dia.mesCalendario, _toca.dia.semana),
                        language: lang,
                        audioService: widget.audioService,
                        detalle: false,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          key: const Key('boton_ver_palabras_do_curso'),
                          onPressed: () => _verPalabras(programa),
                          child: Text(isGl
                              ? 'Ver as ${formatarMiles(programa.totalPalabras)} palabras'
                              : 'Ver las ${formatarMiles(programa.totalPalabras)} palabras'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_conto case final conto?) ...[
              const SizedBox(height: 14),
              _FilaRecurso(
                clave: 'hoxe_aula_conto',
                icona: Icons.auto_stories_rounded,
                rotulo: isGl ? 'O CONTO DA SEMANA' : 'EL CUENTO DE LA SEMANA',
                titulo: conto.titulo.resolve(lang),
                onTap: () => _abrirConto(conto),
              ),
            ],
            if (_dinamica case final d?) ...[
              const SizedBox(height: 10),
              _FilaRecurso(
                clave: 'hoxe_aula_dinamica',
                icona: Icons.groups_rounded,
                rotulo: 'DINÁMICA · ${d.duracionMinutos} MIN',
                titulo: d.titulo.resolve(lang),
                onTap: () => Navigator.of(context).push(
                  RutaLua(
                    de: context,
                    builder: (_) => DinamicasScreen(
                      repository: widget.repository,
                      initialLanguage: lang,
                      onLanguageChanged: widget.onLanguageChanged,
                    ),
                  ),
                ),
              ),
            ],
            if (_steam case final steam?) ...[
              const SizedBox(height: 10),
              FilaSteamDoDia(
                unidade: steam,
                audiencia: SteamAudiencia.aula,
                language: lang,
                onTap: () => abrirSesionSteam(
                  context,
                  unidade: steam,
                  audiencia: SteamAudiencia.aula,
                  language: lang,
                  audioService: widget.audioService,
                  onLanguageChanged: widget.onLanguageChanged,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La asamblea del día: su centro de interés, las cuatro fases con sus
/// minutos y un solo botón. La única tarjeta con sombra del portal.
class _TarxetaAsemblea extends StatelessWidget {
  const _TarxetaAsemblea({
    required this.grupo,
    required this.repository,
    required this.toca,
    required this.language,
    required this.onComezar,
  });

  final GrupoDaAsemblea grupo;
  final ContentRepository repository;
  final DiaQueToca toca;
  final AppLanguage language;
  final VoidCallback onComezar;

  static const _nomeCurto = {
    TipoFaseAsamblea.aperturaSaudo: LocalizedString(gl: 'Saúdo', es: 'Saludo'),
    TipoFaseAsamblea.movementRhythmFocus:
        LocalizedString(gl: 'Enfoque', es: 'Enfoque'),
    TipoFaseAsamblea.coreTprChallenge: LocalizedString(gl: 'TPR', es: 'TPR'),
    TipoFaseAsamblea.calmaTransicion: LocalizedString(gl: 'Calma', es: 'Calma'),
  };

  static String _minutos(int s) =>
      '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final base = grupo.primeiro?.fases ?? grupo.segundo?.fases ?? const [];
    final dia = repository
        .getProgresionSync(grupo.claveProgresion)
        ?.dia(toca.dia.semana, toca.dia.dia);
    final fases = dia?.aplicarA(base) ?? base;
    final total = fases.fold<int>(0, (s, f) => s + f.duracionSegundos);
    final minutos = (total / 60).round();
    final tema = (grupo.primeiro?.centroInteres ?? grupo.segundo?.centroInteres)
            ?.resolve(language) ??
        '';
    final mes = nomeDoMes[toca.dia.mesCalendario]?.resolve(language) ?? '';

    return Container(
      key: const Key('hoxe_aula_asemblea'),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.acento.withAlpha(70)),
        boxShadow: [
          BoxShadow(
            color: context.acento.withAlpha(36),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${grupo.etiqueta.resolve(language)} · ${mes.toLowerCase()} · '
                    'semana ${toca.dia.semana} · $minutos min'
                .toUpperCase(),
            key: const Key('hoxe_aula_rotulo'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: context.acento,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tema,
            key: const Key('hoxe_aula_tema'),
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 14),
          // Las cuatro fases, con sus minutos: de un vistazo se ve cuánto
          // dura y en qué orden va.
          Row(
            key: const Key('hoxe_aula_fases'),
            children: [
              for (final (i, f) in fases.indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: context.acento.withAlpha(60)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          (_nomeCurto[f.tipo] ?? f.titulo).resolve(language),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: context.acento,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _minutos(f.duracionSegundos),
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              key: const Key('boton_asemblea_de_hoxe'),
              onPressed: onComezar,
              icon: const Icon(Icons.play_arrow_rounded, size: 24),
              label: Text(
                isGl ? 'Comezar a asemblea' : 'Comenzar la asamblea',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una fila que lleva a algo: icono, rótulo, título y flecha.
class _FilaRecurso extends StatelessWidget {
  const _FilaRecurso({
    required this.clave,
    required this.icona,
    required this.rotulo,
    required this.titulo,
    required this.onTap,
  });

  final String clave;
  final IconData icona;
  final String rotulo;
  final String titulo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey(clave),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icona, color: context.acento, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rotulo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
