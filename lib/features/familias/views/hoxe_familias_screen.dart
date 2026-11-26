import 'package:flutter/material.dart';

import '../../formacion/widgets/lista_de_practica.dart';
import '../../juega/widgets/pasos_do_dia.dart';
import '../../juega/widgets/tarxeta_curricular.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/imaxe_escena.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../criancas/xogo_lua.dart' show CatalogoLua;
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/fsrs_card_model.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/models/ponte_ao_dia_model.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../../data/repositories/content_repository.dart';
import '../../calendario/widgets/nucleo_de_hoxe.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../cuentos/views/cuento_viewer_screen.dart';
import '../../cuentos/views/microcuento_screen.dart' show ModoMicrocuento;
import '../../cuentos/widgets/boton_microcuento.dart';
import '../../docentes/widgets/hoxe_na_aula.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../../leccions/widgets/leccion_da_semana.dart';
import '../../criancas/crianza_da_casa.dart';
import '../../criancas/marcar_palabras_screen.dart';
import '../../criancas/criancas_store.dart';
import '../../criancas/proba_entrada.dart';
import '../../criancas/proba_entrada_screen.dart';
import '../../criancas/tarxeta_lua.dart';
import '../widgets/learn_duolingo.dart';
import '../../leccions/widgets/proxecto_0_2.dart';
import '../../../core/brand/lua_valeria.dart';
import '../../../data/models/leccion_model.dart';
import '../../steam/widgets/steam_no_calendario.dart';
import '../nomes_familias.dart';
import '../widgets/reto_da_semana.dart';
import '../widgets/selector_idade.dart';
import '../../estimulacion/widgets/entrada_estimulacion.dart';
import 'codigo_da_escola_screen.dart';
import 'ponte_ao_dia_screen.dart';
import 'xogo_de_hoxe_screen.dart';

/// «Hoxe», la portada de casa: la lección de la semana (P11), y debajo, como
/// material complementario, el juego de tres minutos, las palabras del día,
/// el reto del mes y el cuento.
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
  Leccions? _leccions;
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
    // M3.10: el núcleo del mes, el mismo que ve la escuela, va delante.
    if (repo.unidadeDoMesSync(curso, _toca.dia.mesCalendario) == null) {
      repo.loadUnidadeDoMes(curso, _toca.dia.mesCalendario).then((_) {
        if (vixente()) setState(() {});
      });
    }
    if (repo.rexistroFrasesSync == null) {
      repo.loadRexistroFrases().then((_) {
        if (mounted) setState(() {});
      });
    }

    Leccions.cargar().then<Leccions?>((l) => l, onError: (_) => null).then((l) {
      if (mounted && l != null) setState(() => _leccions = l);
    });

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
    return isGl ? 'A lección desta semana' : 'La lección de esta semana';
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
                _toca.dia.mesCalendario,
                _toca.dia.semana,
                _toca.dia.dia,
              ),
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

  void _abrirPonteAoDia(PonteAoDia ponte) {
    Navigator.of(context).push(
      RutaLua(
        de: context,
        builder: (_) => PonteAoDiaScreen(
          ponte: ponte,
          cursoId: widget.cursoId,
          mes: _toca.dia.mesCalendario,
          language: widget.language,
          onLanguageChanged: widget.onLanguageChanged,
          onCambiarCurso: widget.onCambiarCurso,
          audioService: widget.audioService,
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
      _toca.dia.mesCalendario,
      _toca.dia.semana,
      _toca.dia.dia,
    );
    // Para quen chega novo: o que dan por sabido as asembleas deste mes.
    final ponte = widget.repository.ponteAoDiaSync;
    final dadasPorSabidas =
        ponte?.doMes(widget.cursoId, _toca.dia.mesCalendario) ?? const [];

    final casa = CrianzaDaCasa.maybeOf(context);
    final criancas = casa?.store.criancas ?? const <Crianza>[];
    final nenoActivo = casa?.store.activa;
    final agora = widget.agora ?? DateTime.now();
    final proxSetembro = (casa != null && nenoActivo != null)
        ? casa.store.cursoPropostoEnSetembro(nenoActivo, agora)
        : null;

    String resumoHoxePara(Crianza c) {
      final feito = casa?.store.xogo(c.id).xogouHoxe(agora) ?? false;
      final prefixo = feito ? (lang == AppLanguage.gl ? 'Feito' : 'Hecho') : '';
      String tema = '';
      if (c.curso == 'curso_0_2') {
        tema = Proxectos02.lidos
                ?.doMes(_toca.dia.mesCalendario)
                ?.titulo
                .resolve(lang) ??
            '';
      } else {
        tema = _leccions
                ?.da(c.curso, _toca.dia.mesCalendario, _toca.dia.semana)
                ?.$1
                .titulo
                .resolve(lang) ??
            '';
      }
      if (tema.isEmpty) {
        return prefixo.isNotEmpty
            ? prefixo
            : '${_semana[_toca.dia.dia - 1].resolve(lang)} · S${_toca.dia.semana}';
      }
      return prefixo.isNotEmpty ? '$prefixo · $tema' : tema;
    }

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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            // O-20261028-4: la edad, la fecha y el título en una fila, para
            // que la lección entre en la primera pantalla.
            // Con letra normal, en una fila; con letra grande, el título
            // baja debajo del selector en vez de estrecharse.
            Builder(
              builder: (context) {
                final grande = MediaQuery.textScalerOf(context).scale(1) > 1.3;
                final selector = SelectorIdade(
                  cursoId: widget.cursoId,
                  language: lang,
                  onCambiar: widget.onCambiarCurso,
                );
                final titulo = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _data(lang).toUpperCase(),
                      key: const Key('hoxe_data'),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Semantics(
                      header: true,
                      child: Text(
                        _titulo(lang),
                        key: const Key('hoxe_titulo'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                );
                return grande
                    ? Wrap(
                        spacing: 12,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [selector, titulo],
                      )
                    : Row(
                        children: [
                          selector,
                          const SizedBox(width: 12),
                          Expanded(child: titulo),
                        ],
                      );
              },
            ),
            if (_toca.finDeSemana || _toca.prevista) ...[
              const SizedBox(height: 4),
              Text(
                _toca.prevista
                    ? (lang == AppLanguage.gl
                        ? 'Xullo e agosto: a primeira lección do curso.'
                        : 'Julio y agosto: la primera lección del curso.')
                    : (lang == AppLanguage.gl
                        ? 'Fin de semana: bo momento para repasala.'
                        : 'Fin de semana: buen momento para repasarla.'),
                key: const Key('hoxe_fin_de_semana'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
            // P11.1: en septiembre, si por mes/año de nacimiento toca el curso
            // siguiente, la app lo propone y la persona adulta confirma.
            if (proxSetembro != null && nenoActivo != null && casa != null) ...[
              const SizedBox(height: 6),
              Container(
                key: const Key('setembro_promocion_card'),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: context.acento.withAlpha(110)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang == AppLanguage.gl
                          ? 'É setembro! ${nenoActivo.nome} pasa a ${NomesFamilias.idade(proxSetembro).resolve(lang)}?'
                          : '¡Es septiembre! ¿${nenoActivo.nome} pasa a ${NomesFamilias.idade(proxSetembro).resolve(lang)}?',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton(
                          key: const Key('setembro_promocion_si'),
                          onPressed: () =>
                              casa.store.responderPromocionSetembro(
                            nenoActivo.id,
                            ano: agora.year,
                            aceptar: true,
                            agora: agora,
                          ),
                          child: Text(
                            lang == AppLanguage.gl
                                ? 'Pasar a ${NomesFamilias.idade(proxSetembro).resolve(lang)}'
                                : 'Pasar a ${NomesFamilias.idade(proxSetembro).resolve(lang)}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          key: const Key('setembro_promocion_non'),
                          onPressed: () =>
                              casa.store.responderPromocionSetembro(
                            nenoActivo.id,
                            ano: agora.year,
                            aceptar: false,
                            agora: agora,
                          ),
                          child: Text(
                            lang == AppLanguage.gl
                                ? 'Manter agora'
                                : 'Mantener ahora',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            // P11.1: fila arriba con cada niño de la casa (su Lúa, su nombre,
            // su curso y en una línea lo que le toca hoy). Un toque cambia el
            // niño activo y actualiza Hoxe, Calendario y Explorar.
            if (criancas.isNotEmpty && casa != null) ...[
              const SizedBox(height: 6),
              FutureBuilder<CatalogoLua>(
                future: CatalogoLua.cargar(),
                initialData: CatalogoLua.lido,
                builder: (context, cat) {
                  final ini = cat.data?.deInicio ?? const {};
                  return SingleChildScrollView(
                    key: const Key('fila_nenos_hoxe'),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var idx = 0; idx < criancas.length; idx++) ...[
                          if (idx > 0) const SizedBox(width: 8),
                          Builder(
                            builder: (context) {
                              final c = criancas[idx];
                              final activo = c.id == nenoActivo?.id;
                              final g = casa.store.xogo(c.id);
                              final tocaLinha = resumoHoxePara(c);
                              final cursoNome =
                                  NomesFamilias.idade(c.curso).resolve(lang);
                              return Semantics(
                                button: true,
                                selected: activo,
                                label: '${c.nome}, $cursoNome, $tocaLinha',
                                excludeSemantics: true,
                                child: Material(
                                  color: activo
                                      ? context.acentoTint
                                      : Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    side: BorderSide(
                                      color: activo
                                          ? context.acento
                                          : AppTheme.border,
                                      width: activo ? 1.5 : 1,
                                    ),
                                  ),
                                  child: InkWell(
                                    key: ValueKey('hoxe_neno_${c.id}'),
                                    borderRadius: BorderRadius.circular(14),
                                    onTap: () => casa.store.escoller(c.id),
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        minHeight: 48,
                                        maxWidth: 205,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            LuaValeria(
                                              ancho: 24,
                                              cabeza: g.cabeza ?? ini['head'],
                                              pescozo: g.pescozo ?? ini['neck'],
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    '${c.nome} · $cursoNome',
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      height: 1.15,
                                                      color: activo
                                                          ? context.acento
                                                          : AppTheme
                                                              .textPrimary,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 1),
                                                  Text(
                                                    tocaLinha,
                                                    key: ValueKey(
                                                      'hoxe_neno_toca_${c.id}',
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      height: 1.15,
                                                      color: AppTheme
                                                          .textSecondary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ],
            // O-20261120-1 (F-20261120-2): la estimulación del lenguaje y el
            // pensamiento, arriba y a la vista, no al final de la lección.
            const SizedBox(height: 2),
            EntradaEstimulacionCard(
              cursoId: widget.cursoId,
              mesCalendario: _toca.dia.mesCalendario,
              language: lang,
              onLanguageChanged: widget.onLanguageChanged,
              audioService: widget.audioService,
              enAula: false,
              onCambiarCurso: widget.onCambiarCurso,
              compacta: true,
            ),
            // O-20261109-5: la pantalla «Learn» de duolingo-clone: puntos y
            // racha del niño, la unidad en su caja verde y el camino de los
            // cinco días en nodos; el nodo de hoy abre la lección paso a paso.
            const SizedBox(height: 2),
            FutureBuilder<Leccions?>(
              future: Leccions.cargar().then<Leccions?>(
                (l) => l,
                onError: (_) => null,
              ),
              builder: (context, snap) {
                final da = snap.data?.da(
                  widget.cursoId,
                  _toca.dia.mesCalendario,
                  _toca.dia.semana,
                );
                if (da == null) return const SizedBox.shrink();
                final (u, lec) = da;
                final neno = casa?.store.activa;
                final xogo = neno == null ? null : casa!.store.xogo(neno.id);
                final semanaKey = CriancasStore.semana(
                  widget.cursoId,
                  _toca.dia.mesCalendario,
                  _toca.dia.semana,
                );
                final actual = _toca.prevista
                    ? 0
                    : _toca.finDeSemana
                        ? 4
                        : _toca.dia.dia - 1;
                // O-20261111-2 (B): un día que aún no ha llegado no se abre,
                // pero lo dice: nunca un toque sin respuesta.
                void avisar(int i) {
                  const dias = [
                    LocalizedString(gl: 'o luns', es: 'el lunes'),
                    LocalizedString(gl: 'o martes', es: 'el martes'),
                    LocalizedString(gl: 'o mércores', es: 'el miércoles'),
                    LocalizedString(gl: 'o xoves', es: 'el jueves'),
                    LocalizedString(gl: 'o venres', es: 'el viernes'),
                  ];
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        key: const Key('learn_aviso_futuro'),
                        content: Text(
                          lang == AppLanguage.gl
                              ? 'Este día ábrese ${dias[i].gl}'
                              : 'Este día se abre ${dias[i].es}',
                        ),
                      ),
                    );
                }

                void abrirLeccion(int i) => abrirLeccionDuolingo(
                      context,
                      leccion: lec,
                      dia: i + 1,
                      language: lang,
                      semana: semanaKey,
                      cursoId: widget.cursoId,
                      mesCalendario: _toca.dia.mesCalendario,
                      semanaN: _toca.dia.semana,
                      audioService: widget.audioService,
                      store: casa?.store,
                      crianza: neno,
                      agora: widget.agora,
                    );
                void abrir(int i) => i > actual ? avisar(i) : abrirLeccion(i);
                final excluidas = {
                  for (final p in lec.novas) CriancasStore.claveRepaso(p.en),
                };
                final vencidas = (neno != null && casa != null)
                    ? casa.store.tarxetasVencidas(
                        neno.id,
                        agora: agora,
                        excluir: excluidas,
                      )
                    : const <FSRSCard>[];
                final volven = vencidas.take(4).toList(growable: false);
                final moitasVencidas = vencidas.length > 6;
                final mapaPezas = _pezasDoCurso(snap.data, widget.cursoId);
                final senMarcas = (neno != null && casa != null)
                    ? casa.store.semanasSenMarcas(
                        neno.id,
                        mesCalendario: _toca.dia.mesCalendario,
                        semana: _toca.dia.semana,
                      )
                    : 0;
                final vistosDomingo = <String>{};
                final palabrasDomingo = [
                  for (final p in [...lec.novas, ...lec.repasa])
                    if (vistosDomingo.add(CriancasStore.claveRepaso(p.en))) p,
                ].take(3).toList(growable: false);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (xogo != null)
                      CabeceraLearn(
                        curso: Text(
                          neno!.nome,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        xp: xogo.xp,
                        racha: xogo.rachaViva(agora),
                      ),
                    if (neno != null &&
                        casa != null &&
                        CatalogoProbaEntrada.debeFacerProba(neno)) ...[
                      const SizedBox(height: 6),
                      Container(
                        key: const Key('retomar_proba_entrada_card'),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Xogo de Lúa pendente para ${neno.nome} (${neno.probaRespostas.length}/18)'
                                  : 'Juego de Lúa pendiente para ${neno.nome} (${neno.probaRespostas.length}/18)',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              lang == AppLanguage.gl
                                  ? 'Mentres non remate, ${neno.nome} empeza polo comezo do seu curso.'
                                  : 'Mientras no acabe, ${neno.nome} empieza por el principio de su curso.',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton(
                                    key: const Key('retomar_proba_entrada'),
                                    onPressed: () => Navigator.of(context).push(
                                      RutaLua(
                                        de: context,
                                        builder: (_) => ProbaEntradaScreen(
                                          store: casa.store,
                                          crianza: neno,
                                          language: lang,
                                          audioService: widget.audioService,
                                          agora: agora,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      lang == AppLanguage.gl
                                          ? 'Seguir onde quedou'
                                          : 'Seguir donde se quedó',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  key: const Key('saltar_proba_desde_hoxe'),
                                  onPressed: () => casa.store.completarProba(
                                    neno.id,
                                    peldano: 1,
                                    agora: agora,
                                  ),
                                  child: const Text('Saltar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (senMarcas >= 2 && neno != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        key: const Key('aviso_duas_semanas_sen_marcas'),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.pageBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Text(
                          lang == AppLanguage.gl
                              ? 'Levas dúas semanas sen marcar as palabras de ${neno.nome}. Podes facelo nun intre cando xoguedes.'
                              : 'Llevas dos semanas sin marcar las palabras de ${neno.nome}. Puedes hacerlo en un momento cuando juguéis.',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                    if (agora.weekday == DateTime.sunday &&
                        neno != null &&
                        casa != null &&
                        palabrasDomingo.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      _LuaPreguntaCard(
                        neno: neno,
                        semana: semanaKey,
                        palabras: palabrasDomingo,
                        store: casa.store,
                        agora: agora,
                        language: lang,
                        audioService: widget.audioService,
                      ),
                    ],
                    if (volven.isNotEmpty && neno != null && casa != null) ...[
                      const SizedBox(height: 6),
                      _VolvenHoxeCard(
                        nenoId: neno.id,
                        vencidasTotais: vencidas.length,
                        tarxetas: volven,
                        pezas: mapaPezas,
                        store: casa.store,
                        agora: agora,
                        language: lang,
                        audioService: widget.audioService,
                      ),
                    ],
                    if (!moitasVencidas) ...[
                      const SizedBox(height: 6),
                      BannerUnidade(
                        titulo: u.titulo.resolve(lang),
                        descricion: u.steam?.resolve(lang) ?? '',
                        continuar:
                            lang == AppLanguage.gl ? 'Continuar' : 'Continuar',
                        onContinuar: () => abrir(actual),
                      ),
                      CaminoNodos(
                        etiquetas: [
                          for (var d = 0; d < 5; d++) _semana[d].resolve(lang),
                        ],
                        actual: actual,
                        feitoHoxe: xogo?.xogouHoxe(agora) ?? false,
                        empezar: lang == AppLanguage.gl ? 'Empezar' : 'Empezar',
                        onNodo: abrir,
                        lua: xogo == null
                            ? null
                            : FutureBuilder<CatalogoLua>(
                                future: CatalogoLua.cargar(),
                                initialData: CatalogoLua.lido,
                                builder: (context, cat) {
                                  final ini = cat.data?.deInicio ?? const {};
                                  return LuaValeria(
                                    key: const Key('hoxe_lua'),
                                    ancho: 112,
                                    cabeza: xogo.cabeza ?? ini['head'],
                                    pescozo: xogo.pescozo ?? ini['neck'],
                                  );
                                },
                              ),
                      ),
                    ],
                    if (neno != null && casa != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          casa.store
                              .calcularAxustePara(
                                neno.id,
                                mesCalendario: _toca.dia.mesCalendario,
                                semana: _toca.dia.semana,
                                agora: agora,
                              )
                              .explicacion(lang),
                          key: const Key('axuste_semanal_explicacion'),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                            height: 1.3,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            // P11: debajo, la lección de la semana entera, para consultar
            // (salvo si hay más de 6 palabras vencidas, que ese día no entran nuevas).
            if (!_haiMoitasVencidas(context, _leccions)) ...[
              const SizedBox(height: 10),
              LeccionDaSemanaCargada(
                cursoId: widget.cursoId,
                mesCalendario: _toca.dia.mesCalendario,
                semana: _toca.dia.semana,
                dia: _toca.dia.dia,
                language: lang,
                audioService: widget.audioService,
              ),
            ],
            // O-20261109-3: Lúa de Valeria, con los premios del niño.
            if (CrianzaDaCasa.maybeOf(context) case final casa?)
              if (casa.store.activa case final neno?) ...[
                const SizedBox(height: 16),
                FutureBuilder<Leccions?>(
                  future: Leccions.cargar().then<Leccions?>(
                    (l) => l,
                    onError: (_) => null,
                  ),
                  builder: (context, snap) => TarxetaLua(
                    key: ValueKey('tarxeta_lua_${neno.id}'),
                    store: casa.store,
                    crianza: neno,
                    language: lang,
                    agora: widget.agora,
                    semana: CriancasStore.semana(
                      neno.curso,
                      _toca.dia.mesCalendario,
                      _toca.dia.semana,
                    ),
                    palabrasDaSemana: neno.curso == 'curso_0_2'
                        ? [
                            for (final w in Proxectos02.lidos
                                    ?.doMes(_toca.dia.mesCalendario)
                                    ?.daSemana(_toca.dia.semana) ??
                                const <PalabraProxecto>[])
                              w.en,
                          ]
                        : [
                            for (final p in snap.data
                                    ?.da(
                                      neno.curso,
                                      _toca.dia.mesCalendario,
                                      _toca.dia.semana,
                                    )
                                    ?.$2
                                    .novas ??
                                const <PezaDaLeccion>[])
                              if (p.en.isNotEmpty) p.en,
                          ],
                  ),
                ),
              ],
            const SizedBox(height: 16),
            // O-20261028-4: Hoxe es la lección. Todo lo demás —el código de
            // la escuela, el juego de tres minutos, las palabras del banco, el
            // reto del mes, el cuento, la ciencia y la lista de práctica—,
            // plegado aquí, al final.
            const SizedBox(height: 12),
            Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                side: const BorderSide(color: AppTheme.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                key: const Key('hoxe_complementario'),
                title: Text(
                  lang == AppLanguage.gl ? 'Máis para casa' : 'Más para casa',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Text(
                  lang == AppLanguage.gl
                      ? 'Para cando queirades máis. Non fai falta.'
                      : 'Para cuando queráis más. No hace falta.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // P10: el código que da la escuela abre el mes y la semana que
                  // dice la nota, aunque no sean los de hoy.
                  Material(
                    key: const Key('hoxe_codigo_escola'),
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.border),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.of(context).push(
                        RutaLua(
                          de: context,
                          builder: (_) => CodigoDaEscolaScreen(
                            repository: widget.repository,
                            language: lang,
                            onLanguageChanged: widget.onLanguageChanged,
                            audioService: widget.audioService,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.pin_rounded, color: context.acento),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                lang == AppLanguage.gl
                                    ? 'Tes un código da escola?'
                                    : '¿Tienes un código de la escuela?',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: context.acento,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
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
                        proxecto02: widget.cursoId == 'curso_0_2'
                            ? (_toca.dia.mesCalendario, _toca.dia.semana)
                            : null,
                        plan: plan,
                        modeloDoDia: curso.modelo.dia(_toca.dia.dia),
                        nucleo: switch (widget.repository.unidadeDoMesSync(
                          widget.cursoId,
                          _toca.dia.mesCalendario,
                        )) {
                          final u? => widget.repository.nucleoSync(u),
                          null => const <PezaDaUnidade>[],
                        },
                        language: lang,
                        audioService: widget.audioService,
                      ),
                    ],
                    if (ponte != null && dadasPorSabidas.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _FilaPonteAoDia(
                        ponte: ponte,
                        cantas: dadasPorSabidas.length,
                        mes: _toca.dia.mesCalendario,
                        language: lang,
                        onTap: () => _abrirPonteAoDia(ponte),
                      ),
                    ],
                    if (widget.repository
                            .unidadeDoMesSync(
                              widget.cursoId,
                              _toca.dia.mesCalendario,
                            )
                            ?.hogar
                        case final hogar?) ...[
                      RetoDaSemana(
                        hogar: hogar,
                        semana: _toca.dia.semana,
                        rotulo: lang == AppLanguage.gl
                            ? 'O RETO DO MES · SEMANA ${_toca.dia.semana} DE 4'
                            : 'EL RETO DEL MES · SEMANA ${_toca.dia.semana} DE 4',
                        language: lang,
                        audioService: widget.audioService,
                        lectura: hogar.microcuento == null
                            ? null
                            : BotonMicrocuento(
                                repository: widget.repository,
                                cursoId: widget.cursoId,
                                mesCalendario: _toca.dia.mesCalendario,
                                modo: ModoMicrocuento.casa,
                                language: lang,
                                onLanguageChanged: widget.onLanguageChanged,
                                audioService: widget.audioService,
                              ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    TarxetaCurricular(
                      cursoId: widget.cursoId,
                      mesCalendario: _toca.dia.mesCalendario,
                      language: lang,
                      audioService: widget.audioService,
                      enCasa: true,
                      conAccesos: false,
                    ),
                    PasosDoMes(
                      cursoId: widget.cursoId,
                      mesCalendario: _toca.dia.mesCalendario,
                      semana: _toca.dia.semana,
                      language: lang,
                      audioService: widget.audioService,
                      enCasa: true,
                    ),
                    if (_conto case final conto?) ...[
                      const SizedBox(height: 6),
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
                  const SizedBox(height: 18),
                  ListaDePracticaCard(
                    store: widget.store,
                    perfil: 'hogar',
                    dia: widget.agora ?? DateTime.now(),
                    language: lang,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, PezaDaLeccion> _pezasDoCurso(Leccions? lec, String cursoId) {
    final mapa = <String, PezaDaLeccion>{};
    if (lec == null) return mapa;
    void engadirCurso(String cid) {
      for (final u in lec.unidades[cid] ?? const <UnidadeDeLeccions>[]) {
        for (final l in u.leccions) {
          for (final p in [...l.novas, ...l.repasa, ...l.xaSabe]) {
            mapa.putIfAbsent(CriancasStore.claveRepaso(p.en), () => p);
          }
        }
      }
    }

    engadirCurso(cursoId);
    for (final cid in lec.unidades.keys) {
      if (cid != cursoId) engadirCurso(cid);
    }
    return mapa;
  }

  bool _haiMoitasVencidas(BuildContext context, Leccions? lec) {
    final casa = CrianzaDaCasa.maybeOf(context);
    final neno = casa?.store.activa;
    if (casa == null || neno == null) return false;
    final par =
        lec?.da(widget.cursoId, _toca.dia.mesCalendario, _toca.dia.semana);
    final excluidas = {
      for (final p in par?.$2.novas ?? const <PezaDaLeccion>[])
        CriancasStore.claveRepaso(p.en),
    };
    return casa.store.haiMoitasVencidas(
      neno.id,
      agora: widget.agora,
      excluir: excluidas,
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
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppTheme.successInk,
                  size: 26,
                ),
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

/// El inglés de hoy: el núcleo del mes delante y, plegadas debajo, las
/// palabras del día con su voz (el viernes, las veinte del reto).
class _TarxetaPalabras extends StatelessWidget {
  const _TarxetaPalabras({
    required this.plan,
    required this.modeloDoDia,
    required this.nucleo,
    required this.language,
    required this.audioService,
    this.proxecto02,
  });

  /// Mes y semana del proyecto de 0-2; `null` en el resto de edades.
  final (int, int)? proxecto02;

  final DailyTprPlan plan;
  final List<PezaDaUnidade> nucleo;

  static const _tituloPalabras = LocalizedString(
    gl: 'PALABRAS DE HOXE',
    es: 'PALABRAS DE HOY',
  );
  final DiaDoModeloTpr? modeloDoDia;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    // O-20261109-4 (ACOPROS): en 0-2, las del proyecto, no el banco diario.
    final Widget palabras = proxecto02 != null
        ? PalabrasProxecto02(
            mesCalendario: proxecto02!.$1,
            semana: proxecto02!.$2,
            language: language,
            audioService: audioService,
          )
        : PalabrasDoDia(
            plan: plan,
            modeloDoDia: modeloDoDia,
            language: language,
            audioService: audioService,
            paraFogar: true,
            detalle: false,
          );
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
            const SizedBox(height: 2),
            // Las palabras son para la criatura y quien las dice no siempre
            // las sabe: un toque las dice en inglés; dos, lo que quieren decir.
            Text(
              NomesFamilias.inglesToques.resolve(language),
              key: const Key('hoxe_ingles_toques'),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            // M3.10 (D1): sin núcleo leído, la tarjeta de siempre. En 0-2
            // (ACOPROS), las palabras del proyecto, a la vista.
            if (nucleo.isEmpty || proxecto02 != null)
              palabras
            else ...[
              const SizedBox(height: 4),
              NucleoDeHoxe(
                nucleo: nucleo,
                language: language,
                audioService: audioService,
              ),
              const SizedBox(height: 10),
              PalabrasDoDiaPlegadas(
                titulo: _tituloPalabras.resolve(language),
                language: language,
                child: palabras,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La puerta de «Ponte ao día»: para quien llega nuevo al curso, cuántas
/// palabras de antes dan por sabidas las asambleas de este mes.
class _FilaPonteAoDia extends StatelessWidget {
  const _FilaPonteAoDia({
    required this.ponte,
    required this.cantas,
    required this.mes,
    required this.language,
    required this.onTap,
  });

  final PonteAoDia ponte;
  final int cantas;
  final int mes;
  final AppLanguage language;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final nomeMes = nomeDoMes[mes]?.resolve(language).toLowerCase() ?? '';
    final entrada = ponte
        .texto('casa', 'entrada')
        .resolve(language)
        .replaceAll('{n}', '$cantas')
        .replaceAll('{mes}', nomeMes);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('hoxe_ponte_ao_dia'),
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
                child: Icon(
                  Icons.update_rounded,
                  color: context.acento,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ponte
                          .texto('casa', 'titulo')
                          .resolve(language)
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entrada,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
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
                child: Icon(
                  Icons.auto_stories_rounded,
                  color: context.acento,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl
                          ? 'CONTO LONGO DA SEMANA'
                          : 'CUENTO LARGO DE LA SEMANA',
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
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VolvenHoxeCard extends StatelessWidget {
  const _VolvenHoxeCard({
    required this.nenoId,
    required this.vencidasTotais,
    required this.tarxetas,
    required this.pezas,
    required this.store,
    required this.agora,
    required this.language,
    required this.audioService,
  });

  final String nenoId;
  final int vencidasTotais;
  final List<FSRSCard> tarxetas;
  final Map<String, PezaDaLeccion> pezas;
  final CriancasStore store;
  final DateTime agora;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final acento = context.acento;
    final moitas = vencidasTotais > 6;
    return Container(
      key: const Key('volven_hoxe_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.replay_rounded, color: acento, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGl ? 'Volven hoxe' : 'Vuelven hoy',
                  key: const Key('volven_hoxe_titulo'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: acento,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            moitas
                ? (isGl
                    ? 'Hoxe non entran palabras novas: hai $vencidasTotais palabras vencidas para repasar con calma.'
                    : 'Hoy no entran palabras nuevas: hay $vencidasTotais palabras vencidas para repasar con calma.')
                : (isGl
                    ? 'Palabras doutros días para lembrar xuntos. Marca o que ves sen pantalla para o neno.'
                    : 'Palabras de otros días para recordar juntos. Marca lo que ves sin pantalla para el niño.'),
            key: moitas ? const Key('volven_hoxe_sen_novas') : null,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < tarxetas.length; i++) ...[
            if (i > 0) const Divider(height: 16, color: AppTheme.border),
            _FilaVolvenHoxe(
              nenoId: nenoId,
              tarxeta: tarxetas[i],
              peza: pezas[CriancasStore.claveRepaso(tarxetas[i].lemma)],
              store: store,
              agora: agora,
              language: language,
              audioService: audioService,
            ),
          ],
        ],
      ),
    );
  }
}

class _FilaVolvenHoxe extends StatelessWidget {
  const _FilaVolvenHoxe({
    required this.nenoId,
    required this.tarxeta,
    required this.peza,
    required this.store,
    required this.agora,
    required this.language,
    required this.audioService,
  });

  final String nenoId;
  final FSRSCard tarxeta;
  final PezaDaLeccion? peza;
  final CriancasStore store;
  final DateTime agora;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final en = peza?.en ?? tarxeta.lemma;
    final significado = peza?.significado;
    final lamina = peza?.lamina;
    final xesto = peza?.xesto?.resolve(language) ??
        (isGl
            ? 'Ten na man aquilo do que falas e ensínallo mentres o dis.'
            : 'Ten en la mano aquello de lo que hablas y enséñaselo mientras lo dices.');

    Widget boton(Observacion o, String texto) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Semantics(
            button: true,
            label: '$en: $texto',
            child: Material(
              key: ValueKey('volven_marcar_${tarxeta.lemma}_${o.name}'),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: AppTheme.border),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => store.repasar(nenoId, en, o, agora: agora),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 8,
                      ),
                      child: Text(
                        texto,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      key: ValueKey('volven_hoxe_${tarxeta.lemma}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (lamina != null) ...[
              LaminaPalabra(
                clave: lamina,
                significado: significado?.resolve(language) ?? en,
                lang: language,
                ancho: 48,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BotonEscuchar(
                    audioService: audioService,
                    texto: en,
                    language: AppLanguage.en,
                    interfaz: language,
                    comoChip: true,
                    colorChip: context.acento,
                    descripcion: en,
                    significado: significado,
                    onEscoitar: () => store.rexistrarEscoita(nenoId, en),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    TarxetaMarcarPalabra.textoEscoitas(
                      store.escoitasDe(nenoId, en),
                      language,
                    ),
                    key: ValueKey('escoitas_${CriancasStore.claveRepaso(en)}'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    xesto,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            boton(Observacion.aindaNon, isGl ? 'Aínda non' : 'Aún no'),
            boton(Observacion.entende, isGl ? 'Enténdea' : 'La entiende'),
            boton(Observacion.di, isGl ? 'Dia' : 'La dice'),
          ],
        ),
      ],
    );
  }
}

class _LuaPreguntaCard extends StatelessWidget {
  const _LuaPreguntaCard({
    required this.neno,
    required this.semana,
    required this.palabras,
    required this.store,
    required this.agora,
    required this.language,
    required this.audioService,
  });

  final Crianza neno;
  final String semana;
  final List<PezaDaLeccion> palabras;
  final CriancasStore store;
  final DateTime agora;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final acento = context.acento;
    return Container(
      key: const Key('lua_pregunta_card'),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const LuaValeria(ancho: 32, cara: CaraLua.love),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lúa pregunta',
                  key: const Key('lua_pregunta_titulo'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: acento,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isGl
                ? 'Tres palabras desta semana para ${neno.nome}.'
                : 'Tres palabras de esta semana para ${neno.nome}.',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < palabras.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            TarxetaMarcarPalabra(
              key: ValueKey('lua_pregunta_card_${palabras[i].en}'),
              peza: palabras[i],
              store: store,
              crianzaId: neno.id,
              semana: semana,
              language: language,
              audioService: audioService,
              agora: agora,
              prefixoBoton: 'lua_pregunta',
            ),
          ],
        ],
      ),
    );
  }
}
