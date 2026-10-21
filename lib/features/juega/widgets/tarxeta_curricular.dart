import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidade_curricular_model.dart';

/// La unidad del plan curricular de Frank que toca este mes (F11): su título,
/// en qué mes de la unidad se está, los objetivos y el vocabulario diana con
/// voz y significado; debajo, plegado, cómo se trabaja.
class TarxetaCurricular extends StatefulWidget {
  final String cursoId;
  final int mesCalendario;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// En casa: sin dinámica de aula, con la orientación para la familia.
  final bool enCasa;

  const TarxetaCurricular({
    super.key,
    required this.cursoId,
    required this.mesCalendario,
    required this.language,
    this.audioService,
    this.enCasa = false,
  });

  @override
  State<TarxetaCurricular> createState() => _TarxetaCurricularState();
}

class _TarxetaCurricularState extends State<TarxetaCurricular> {
  late final Future<PlanCurricular> _plan = PlanCurricular.cargar();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PlanCurricular>(
      future: _plan,
      builder: (context, snap) {
        final plan = snap.data;
        final u = plan?.para(widget.cursoId, widget.mesCalendario);
        if (plan == null || u == null) return const SizedBox.shrink();
        final lang = widget.language;
        final isGl = lang == AppLanguage.gl;
        final (n, de) = plan.mesDentro(widget.cursoId, widget.mesCalendario);
        Widget chips(List<FraseCurricular> fs) => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final f in fs)
                  BotonEscuchar(
                    audioService: widget.audioService,
                    texto: f.en,
                    language: AppLanguage.en,
                    interfaz: lang,
                    comoChip: true,
                    significado: f.significado,
                  ),
              ],
            );
        // Material y no Container: el ExpansionTile pinta su toque en el
        // Material más cercano, y un fondo intermedio lo taparía.
        return Padding(
          key: ValueKey('plan_curricular_${u.id}'),
          padding: const EdgeInsets.only(top: AppTheme.spaceMd),
          child: Material(
            color: AppTheme.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              side: BorderSide(color: context.acento, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    (isGl
                            ? 'PLAN CURRICULAR · MES $n DE $de DA UNIDADE'
                            : 'PLAN CURRICULAR · MES $n DE $de DE LA UNIDAD')
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: context.acento,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    u.titulo.resolve(lang),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  if (u.objetivos.isNotEmpty) ...[
                    _Rotulo(isGl ? 'Obxectivos' : 'Objetivos'),
                    for (final o in u.objetivos) _Texto('· ${o.resolve(lang)}'),
                  ],
                  if (u.vocabulario.isNotEmpty) ...[
                    _Rotulo(isGl
                        ? 'Vocabulario diana (dous toques: o significado)'
                        : 'Vocabulario diana (dos toques: el significado)'),
                    chips(u.vocabulario),
                  ],
                  Theme(
                    data: Theme.of(context)
                        .copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      key: ValueKey('plan_curricular_mais_${u.id}'),
                      tilePadding: EdgeInsets.zero,
                      childrenPadding: EdgeInsets.zero,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Text(
                        isGl ? 'Como se traballa' : 'Cómo se trabaja',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: context.acento,
                        ),
                      ),
                      children: [
                        if (u.accionsTPR.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Accións TPR' : 'Acciones TPR'),
                          for (final a in u.accionsTPR)
                            _Texto('${a.en} — ${a.xesto?.resolve(lang) ?? ''}'),
                        ],
                        if (u.formulas.isNotEmpty) ...[
                          _Rotulo(
                              isGl ? 'Fórmulas de xogo' : 'Fórmulas de juego'),
                          chips(u.formulas),
                        ],
                        if (u.estructuras.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Estruturas' : 'Estructuras'),
                          chips(u.estructuras),
                        ],
                        if (u.rimas.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Rimas' : 'Rimas'),
                          chips(u.rimas),
                        ],
                        if (u.realia.isNotEmpty) ...[
                          _Rotulo(isGl ? 'Material real' : 'Material real'),
                          for (final r in u.realia)
                            _Texto('· ${r.resolve(lang)}'),
                        ],
                        if (u.fonoloxia case final f?) ...[
                          _Rotulo(isGl ? 'O son' : 'El sonido'),
                          _Texto(f.resolve(lang)),
                        ],
                        if (!widget.enCasa)
                          for (final (rotulo, texto) in u.dinamica) ...[
                            _Rotulo(rotulo.resolve(lang)),
                            _Texto(texto.resolve(lang)),
                          ],
                        if (u.frasesAdulta.isNotEmpty) ...[
                          _Rotulo(isGl ? 'O que dis ti' : 'Lo que dices tú'),
                          chips(u.frasesAdulta),
                        ],
                        if (widget.enCasa)
                          if (u.familia case final f?) ...[
                            _Rotulo(isGl ? 'Na casa' : 'En casa'),
                            _Texto(f.resolve(lang)),
                          ],
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Rotulo extends StatelessWidget {
  final String texto;
  const _Rotulo(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 6),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
      );
}

class _Texto extends StatelessWidget {
  final String texto;
  const _Texto(this.texto);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          texto,
          style: const TextStyle(
            fontSize: 15,
            color: AppTheme.textPrimary,
            height: 1.4,
          ),
        ),
      );
}
