import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../../data/repositories/content_repository.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../cuentos/views/cuento_viewer_screen.dart';
import '../../docentes/widgets/hoxe_na_aula.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../../steam/widgets/steam_no_calendario.dart';
import '../nomes_familias.dart';
import '../widgets/selector_idade.dart';
import 'xogo_de_hoxe_screen.dart';

/// «Hoxe», la portada de casa: lo que toca hoy, entero, en una pantalla.
///
/// El juego de tres minutos con su título de casa y un solo botón, las
/// palabras en inglés del día con su voz, y el cuento de la semana, que es el
/// que las lleva dentro. Antes la portada empezaba por una bienvenida, una
/// tarjeta que llevaba al calendario y siete módulos con filtros: para hacer
/// el juego de hoy había que dar cuatro toques y adivinar el mes.
class HoxeFamiliasScreen extends StatefulWidget {
  const HoxeFamiliasScreen({
    super.key,
    required this.repository,
    required this.store,
    required this.language,
    required this.onLanguageChanged,
    required this.cursoId,
    required this.onCambiarCurso,
    this.audioService,
    this.agora,
  });

  final ContentRepository repository;
  final CalendarioStore store;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final String cursoId;
  final ValueChanged<String> onCambiarCurso;
  final OfflineAudioService? audioService;

  /// Para los tests: el día que se quiere ver. Por defecto, hoy.
  final DateTime? agora;

  @override
  State<HoxeFamiliasScreen> createState() => _HoxeFamiliasScreenState();
}

class _HoxeFamiliasScreenState extends State<HoxeFamiliasScreen> {
  DiaCalendarioDual? _dia;
  Cuento? _conto;
  SteamUnit? _steam;
  bool _cargando = true;

  late DiaQueToca _toca = DiaQueToca.para(agora: widget.agora);

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant HoxeFamiliasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cursoId != widget.cursoId) _cargar();
  }

  /// Cada cosa llega por su lado y se pinta en cuanto llega: el juego no
  /// espera al inglés ni al cuento. Si una lectura tarda, lo demás ya está.
  void _cargar() {
    setState(() {
      _cargando = true;
      _dia = null;
      _conto = null;
      _steam = null;
    });
    _toca = DiaQueToca.para(agora: widget.agora);
    final curso = widget.cursoId;
    final mes = _toca.mesDoCurso;
    final repo = widget.repository;
    bool vixente() => mounted && curso == widget.cursoId;

    repo.loadCalendarioDias(cursoId: curso, mes: mes).then((dias) {
      if (!vixente()) return;
      DiaCalendarioDual? dia;
      for (final d in dias) {
        if (d.semanaNumero == _toca.dia.semana &&
            d.diaSemanaNumero == _toca.dia.dia) {
          dia = d;
          break;
        }
      }
      setState(() {
        _dia = dia;
        _cargando = false;
      });
    });

    repo.loadCuentos(cursoId: curso, mesNumero: mes).then((cuentos) {
      if (!vixente()) return;
      // Solo el de ESTA semana: si no hay, no se enseña otro en su lugar.
      final daSemana =
          cuentos.where((c) => c.semanaSugerida == _toca.dia.semana).toList();
      Cuento? conto;
      for (final c in daSemana) {
        if (c.levaPalabras) {
          conto = c;
          break;
        }
      }
      conto ??= daSemana.isEmpty ? null : daSemana.first;
      setState(() => _conto = conto);
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

  bool get _feitoHoxe {
    final e = widget.store.estadoParaFecha(widget.agora ?? DateTime.now());
    return e == EstadoEstimulacion.soloHogar ||
        e == EstadoEstimulacion.dobleEstimulacion;
  }

  static const _semana = <LocalizedString>[
    LocalizedString(gl: 'Luns', es: 'Lunes'),
    LocalizedString(gl: 'Martes', es: 'Martes'),
    LocalizedString(gl: 'Mércores', es: 'Miércoles'),
    LocalizedString(gl: 'Xoves', es: 'Jueves'),
    LocalizedString(gl: 'Venres', es: 'Viernes'),
    LocalizedString(gl: 'Sábado', es: 'Sábado'),
    LocalizedString(gl: 'Domingo', es: 'Domingo'),
  ];

  /// «Domingo, 4 de outubro»: la fecha de verdad, aunque se enseñe el lunes.
  String _data(AppLanguage lang) {
    final d = widget.agora ?? DateTime.now();
    final mes = nomeDoMes[d.month]?.resolve(lang).toLowerCase() ?? '';
    return '${_semana[d.weekday - 1].resolve(lang)}, ${d.day} de $mes';
  }

  /// El nombre del día que se enseña, en minúscula: «luns».
  String _diaQueToca(AppLanguage lang) =>
      _semana[_toca.dia.dia - 1].resolve(lang).toLowerCase();

  String _titulo(AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    if (_toca.prevista) {
      return isGl ? 'Para empezar en setembro' : 'Para empezar en septiembre';
    }
    if (_toca.finDeSemana) {
      return isGl
          ? 'Os tres minutos do ${_diaQueToca(lang)}'
          : 'Los tres minutos del ${_diaQueToca(lang)}';
    }
    return isGl ? 'Os tres minutos de hoxe' : 'Los tres minutos de hoy';
  }

  void _abrirXogo() {
    final dia = _dia;
    if (dia == null) return;
    final programa = widget.repository.programaTprSync;
    final curso = programa?.curso(widget.cursoId);
    Navigator.of(context)
        .push(
          RutaLua(
            de: context,
            builder: (_) => XogoDeHoxeScreen(
              dia: dia,
              eHoxe: _toca.eHoxe,
              nomeDoDia: _semana[_toca.dia.dia - 1],
              language: widget.language,
              onLanguageChanged: widget.onLanguageChanged,
              audioService: widget.audioService,
              store: widget.store,
              agora: widget.agora,
              plan: curso?.planDoDia(
                  _toca.dia.mesCalendario, _toca.dia.semana, _toca.dia.dia),
            ),
          ),
        )
        .then((_) => mounted ? setState(() {}) : null);
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

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final programa = widget.repository.programaTprSync;
    final curso = programa?.curso(widget.cursoId);
    final plan = curso?.planDoDia(
        _toca.dia.mesCalendario, _toca.dia.semana, _toca.dia.dia);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesFamilias.hoxe.resolve(lang),
        language: lang,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('hoxe_familias'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SelectorIdade(
                cursoId: widget.cursoId,
                language: lang,
                onCambiar: widget.onCambiarCurso,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              _data(lang).toUpperCase(),
              key: const Key('hoxe_data'),
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
                key: const Key('hoxe_titulo'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.15,
                ),
              ),
            ),
            if (_toca.finDeSemana || _toca.prevista) ...[
              const SizedBox(height: 6),
              Text(
                _toca.prevista
                    ? (lang == AppLanguage.gl
                        ? 'En xullo e agosto non hai escola. Este é o primeiro xogo do curso.'
                        : 'En julio y agosto no hay escuela. Este es el primer juego del curso.')
                    : (lang == AppLanguage.gl
                        ? 'Hoxe é fin de semana. Este é o xogo do ${_diaQueToca(lang)}, para ir collendo o ritmo.'
                        : 'Hoy es fin de semana. Este es el juego del ${_diaQueToca(lang)}, para ir cogiendo el ritmo.'),
                style: const TextStyle(
                  fontSize: 14.5,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
            // Mientras llega el día, el hueco de la tarjeta, quieto: un
            // indicador que gira no dice nada que el hueco no diga ya.
            if (_cargando)
              Container(
                key: const Key('hoxe_cargando'),
                height: 260,
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(20),
                ),
              )
            else ...[
              if (_dia == null)
                Container(
                  key: const Key('hoxe_sen_xogo'),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    lang == AppLanguage.gl
                        ? 'O xogo deste día non está no calendario. Mira o Calendario ou Explorar.'
                        : 'El juego de este día no está en el calendario. Mira el Calendario o Explorar.',
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              if (_dia case final dia?)
                _TarxetaXogo(
                  dia: dia,
                  language: lang,
                  rotulo: _toca.eHoxe
                      ? (lang == AppLanguage.gl
                          ? 'O XOGO DE HOXE · 3 MIN'
                          : 'EL JUEGO DE HOY · 3 MIN')
                      : (lang == AppLanguage.gl
                          ? 'O XOGO DO ${_diaQueToca(lang).toUpperCase()} · 3 MIN'
                          : 'EL JUEGO DEL ${_diaQueToca(lang).toUpperCase()} · 3 MIN'),
                  feito: _toca.eHoxe && _feitoHoxe,
                  racha: widget.store.rachaActual,
                  onComezar: _abrirXogo,
                ),
              if (plan != null && curso != null) ...[
                const SizedBox(height: 14),
                _TarxetaPalabras(
                  plan: plan,
                  modeloDoDia: curso.modelo.dia(_toca.dia.dia),
                  language: lang,
                  audioService: widget.audioService,
                ),
              ],
              if (_conto case final conto?) ...[
                const SizedBox(height: 14),
                _FilaConto(
                  conto: conto,
                  language: lang,
                  onTap: () => _abrirConto(conto),
                ),
              ],
              if (_steam case final steam?) ...[
                const SizedBox(height: 14),
                FilaSteamDoDia(
                  unidade: steam,
                  audiencia: SteamAudiencia.hogar,
                  language: lang,
                  onTap: () => abrirSesionSteam(
                    context,
                    unidade: steam,
                    audiencia: SteamAudiencia.hogar,
                    language: lang,
                    audioService: widget.audioService,
                    onLanguageChanged: widget.onLanguageChanged,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// El juego de casa: el momento como título, el principio del texto y un
/// solo botón. Es la única tarjeta con sombra de la app: lo de hoy, delante.
class _TarxetaXogo extends StatelessWidget {
  const _TarxetaXogo({
    required this.dia,
    required this.language,
    required this.rotulo,
    required this.feito,
    required this.racha,
    required this.onComezar,
  });

  final DiaCalendarioDual dia;
  final AppLanguage language;
  final String rotulo;
  final bool feito;
  final int racha;
  final VoidCallback onComezar;

  /// La primera frase del juego: lo que se hace. El porqué va dentro.
  static String _comezo(String texto) {
    final i = texto.indexOf('. ');
    return i > 0 ? texto.substring(0, i + 1) : texto;
  }

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final fam = dia.familias;
    return Container(
      key: const Key('hoxe_xogo'),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  rotulo,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: context.acento,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const ExcludeSemantics(
                child: LuaPixel(pose: LuaPose.head, size: 34),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            fam.momento.resolve(language),
            key: const Key('hoxe_xogo_titulo'),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 8),
          // Entera: cortada con puntos suspensivos se perdía justo el título
          // del cuento, que es lo que une el juego con la escuela.
          Text(
            _comezo(fam.rutinaFogar.resolve(language)),
            key: const Key('hoxe_xogo_texto'),
            style: const TextStyle(
              fontSize: 15.5,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          if (!feito)
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                key: const Key('hoxe_comezar'),
                onPressed: onComezar,
                icon: const Icon(Icons.play_arrow_rounded, size: 24),
                label: Text(
                  isGl ? 'Comezar' : 'Comenzar',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            )
          else
            Row(
              key: const Key('hoxe_feito'),
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppTheme.successInk, size: 26),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    racha > 1
                        ? (isGl
                            ? 'Xa o fixestes hoxe. Levades $racha días seguidos.'
                            : 'Ya lo hicisteis hoy. Lleváis $racha días seguidos.')
                        : (isGl
                            ? 'Xa o fixestes hoxe.'
                            : 'Ya lo hicisteis hoy.'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.successInk,
                      height: 1.3,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onComezar,
                  child: Text(isGl ? 'Velo' : 'Verlo'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Las palabras en inglés del día, con su voz. El viernes, las veinte del reto.
class _TarxetaPalabras extends StatelessWidget {
  const _TarxetaPalabras({
    required this.plan,
    required this.modeloDoDia,
    required this.language,
    required this.audioService,
  });

  final DailyTprPlan plan;
  final DiaDoModeloTpr? modeloDoDia;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('tarxeta_ingles_de_hoxe_fogar'),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              NomesFamilias.ingles.resolve(language).toUpperCase(),
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
              modeloDoDia: modeloDoDia,
              language: language,
              audioService: audioService,
              paraFogar: true,
              detalle: false,
            ),
          ],
        ),
      ),
    );
  }
}

/// El cuento de la semana: el que lleva dentro las veinte palabras.
class _FilaConto extends StatelessWidget {
  const _FilaConto({
    required this.conto,
    required this.language,
    required this.onTap,
  });

  final Cuento conto;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final paxinas = conto.paginas.length;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('hoxe_conto_da_semana'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.auto_stories_rounded,
                    color: context.acento, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl ? 'O CONTO DA SEMANA' : 'EL CUENTO DE LA SEMANA',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conto.titulo.resolve(language),
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      conto.levaPalabras
                          ? (isGl
                              ? '$paxinas páxinas · leva as palabras da semana'
                              : '$paxinas páginas · lleva las palabras de la semana')
                          : (isGl ? '$paxinas páxinas' : '$paxinas páginas'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
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
