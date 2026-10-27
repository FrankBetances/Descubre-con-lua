import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/conto_dialogado_model.dart';
import '../../../data/models/hogar_model.dart';
import '../../../data/models/leccion_model.dart';
import '../../cuentos/views/contos_dialogados_screen.dart';
import '../../familias/widgets/reto_da_semana.dart';
import '../../juega/widgets/pasos_do_dia.dart';

/// La lección de la semana (P11): una sola pieza, en casa y en el aula.
///
/// Arriba, el grupo, la unidad del plan curricular y en qué lección se está,
/// con todas las lecciones de la unidad a la vista para abrir cualquiera.
/// Debajo, siempre en el mismo orden: lo que ya debería saber, lo nuevo de
/// esta semana, cómo decirlo en casa, el cuento, el juego y qué mirar.
/// Todo sale de `assets/content/leccions/leccions.json`.
class LeccionDaSemana extends StatefulWidget {
  final Leccions leccions;
  final String cursoId;
  final int mesCalendario;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// En el aula el paso 3 habla de la nota para las casas.
  final bool enAula;

  const LeccionDaSemana({
    super.key,
    required this.leccions,
    required this.cursoId,
    required this.mesCalendario,
    required this.semana,
    required this.language,
    this.audioService,
    this.enAula = false,
  });

  static const grupos = {
    'curso_0_2': LocalizedString(gl: '0-2 anos', es: '0-2 años'),
    'curso_2_3': LocalizedString(gl: '2-3 anos', es: '2-3 años'),
    'curso_3_4': LocalizedString(gl: '3-4 anos', es: '3-4 años'),
    'curso_4_5': LocalizedString(gl: '4-5 anos', es: '4-5 años'),
    'curso_5_6': LocalizedString(gl: '5-6 anos', es: '5-6 años'),
  };

  @override
  State<LeccionDaSemana> createState() => _LeccionDaSemanaState();
}

class _LeccionDaSemanaState extends State<LeccionDaSemana> {
  // Sin catchError: en un SynchronousFuture no completa nunca.
  late final Future<BibliotecaDialogada?> _biblioteca =
      BibliotecaDialogada.cargar()
          .then<BibliotecaDialogada?>((b) => b, onError: (_) => null);

  /// La lección elegida en la tira; `null` es la de esta semana.
  String? _elixida;

  @override
  void didUpdateWidget(LeccionDaSemana old) {
    super.didUpdateWidget(old);
    if (old.cursoId != widget.cursoId ||
        old.mesCalendario != widget.mesCalendario ||
        old.semana != widget.semana) {
      _elixida = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final daSemana =
        widget.leccions.da(widget.cursoId, widget.mesCalendario, widget.semana);
    if (daSemana == null) return const SizedBox.shrink();
    final (unidade, deHoxe) = _elixida == null
        ? daSemana
        : (widget.leccions.porId(widget.cursoId, _elixida!) ?? daSemana);
    final leccion = deHoxe;
    final unidades = widget.leccions.unidades[widget.cursoId] ?? const [];
    final nUnidade = unidades.indexWhere((u) => u.id == unidade.id) + 1;
    final grupo = LeccionDaSemana.grupos[widget.cursoId]?.resolve(lang) ?? '';
    final kicker = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: context.acento,
    );
    const lectura = TextStyle(
      fontSize: 15,
      color: AppTheme.textSecondary,
      height: 1.4,
    );

    Widget pezas(List<PezaDaLeccion> ps, {bool conDetalle = false}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final p in ps)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: conDetalle
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _chip(p, lang),
                          const SizedBox(height: 4),
                          Text(
                            [
                              if (p.significado case final s?) s.resolve(lang),
                              if (p.xesto case final x?) x.resolve(lang),
                            ].join(' · '),
                            style: lectura,
                          ),
                        ],
                      )
                    : _chip(p, lang),
              ),
          ],
        );

    final hogar = HogarDaUnidade(
      momento: leccion.momento,
      minutos: leccion.minutos,
      escena: leccion.escena,
      retos: [leccion.reto],
      xogo: leccion.xogo,
      steam: leccion.steam,
      queObservar: leccion.queMirar,
    );

    return Column(
      key: ValueKey('leccion_${leccion.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // La unidad y dónde se está en ella.
        Container(
          key: const Key('leccion_cabeceira'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.acentoTint,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${grupo.toUpperCase()} · '
                '${isGl ? 'UNIDADE' : 'UNIDAD'} $nUnidade '
                '${isGl ? 'DE' : 'DE'} ${unidades.length}',
                style: kicker,
              ),
              const SizedBox(height: 4),
              Text(
                unidade.titulo.resolve(lang),
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                leccion.repaso
                    ? (isGl
                        ? 'Semana ${leccion.numero} de ${leccion.de}: repaso'
                        : 'Semana ${leccion.numero} de ${leccion.de}: repaso')
                    : (isGl
                        ? 'Lección ${leccion.numero} de ${leccion.de}'
                        : 'Lección ${leccion.numero} de ${leccion.de}'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final l in unidade.leccions)
                    _Punto(
                      leccion: l,
                      actual: l.id == leccion.id,
                      deHoxe: l.id == daSemana.$2.id,
                      onTap: () => setState(() =>
                          _elixida = l.id == daSemana.$2.id ? null : l.id),
                    ),
                ],
              ),
              if (_elixida != null) ...[
                const SizedBox(height: 6),
                TextButton(
                  key: const Key('leccion_volver'),
                  onPressed: () => setState(() => _elixida = null),
                  child: Text(isGl
                      ? 'Volver á lección desta semana'
                      : 'Volver a la lección de esta semana'),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        RotuloPaso(
          numero: 1,
          titulo: isGl ? 'O que xa debería saber' : 'Lo que ya debería saber',
          subtitulo: leccion.xaSabe.isEmpty
              ? (isGl
                  ? 'É a primeira semana: aínda non hai nada de antes.'
                  : 'Es la primera semana: todavía no hay nada de antes.')
              : (isGl
                  ? 'O das semanas anteriores. Se algunha non a coñece, dila ti outra vez esta semana.'
                  : 'Lo de las semanas anteriores. Si alguna no la conoce, dila tú otra vez esta semana.'),
        ),
        if (leccion.xaSabe.isNotEmpty)
          Wrap(
            key: const Key('leccion_xa_sabe'),
            spacing: 8,
            runSpacing: 8,
            children: [for (final p in leccion.xaSabe) _chip(p, lang)],
          ),
        RotuloPaso(
          numero: 2,
          titulo: leccion.repaso
              ? (isGl ? 'Esta semana volven' : 'Esta semana vuelven')
              : (isGl
                  ? 'As palabras novas desta semana'
                  : 'Las palabras nuevas de esta semana'),
          subtitulo: leccion.repaso
              ? (isGl
                  ? 'Non hai nada novo: repásanse estas, no mesmo momento do día.'
                  : 'No hay nada nuevo: se repasan estas, en el mismo momento del día.')
              : (isGl
                  ? 'Só estas. Un toque: en inglés; dous toques: o que quere dicir.'
                  : 'Solo estas. Un toque: en inglés; dos toques: lo que quiere decir.'),
        ),
        Container(
          key: const Key('leccion_novas'),
          child: pezas(leccion.repaso ? leccion.repasa : leccion.novas,
              conDetalle: true),
        ),
        RotuloPaso(
          numero: 3,
          titulo: widget.enAula
              ? (isGl
                  ? 'O que leva a nota para casa'
                  : 'Lo que lleva la nota para casa')
              : (isGl ? 'Como dicilas na casa' : 'Cómo decirlas en casa'),
          subtitulo: widget.enAula
              ? (isGl
                  ? 'O mesmo reto que fan as familias esta semana, para que o vexas antes de mandalo.'
                  : 'El mismo reto que hacen las familias esta semana, para que lo veas antes de mandarlo.')
              : (isGl
                  ? 'Un momento fixo do día, a espera e que responder. Debaixo, o conto e o xogo.'
                  : 'Un momento fijo del día, la espera y qué responder. Debajo, el cuento y el juego.'),
        ),
        RetoDaSemana(
          hogar: hogar,
          semana: leccion.numero,
          language: lang,
          audioService: widget.audioService,
          rotulo: '${isGl ? 'O RETO' : 'EL RETO'} · '
              '${leccion.reto.nomeFase.resolve(lang).toUpperCase()}',
          lectura: leccion.conto == null
              ? null
              : FutureBuilder<BibliotecaDialogada?>(
                  future: _biblioteca,
                  builder: (context, snap) {
                    final conto = snap.data?.contos
                        .where((c) => c.id == leccion.conto)
                        .firstOrNull;
                    if (conto == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: FilaPaso(
                        claveFila: ValueKey('leccion_conto_${conto.id}'),
                        icona: Icons.auto_stories_rounded,
                        rotulo: isGl
                            ? 'O CONTO DA SEMANA'
                            : 'EL CUENTO DE LA SEMANA',
                        titulo: conto.titulo.resolve(lang),
                        onTap: () => Navigator.of(context).push(RutaLua(
                          de: context,
                          builder: (_) => ContoDialogadoScreen(
                            conto: conto,
                            language: lang,
                            audioService: widget.audioService,
                          ),
                        )),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _chip(PezaDaLeccion p, AppLanguage lang) => BotonEscuchar(
        audioService: widget.audioService,
        texto: p.en,
        language: AppLanguage.en,
        interfaz: lang,
        style: estiloIngles(p.en),
        comoChip: true,
        colorChip: context.acento,
        descripcion: p.en,
        significado: p.significado,
      );
}

/// Un número de la tira de lecciones de la unidad.
class _Punto extends StatelessWidget {
  final Leccion leccion;
  final bool actual;
  final bool deHoxe;
  final VoidCallback onTap;

  const _Punto({
    required this.leccion,
    required this.actual,
    required this.deHoxe,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    return Semantics(
      button: true,
      selected: actual,
      excludeSemantics: true,
      // «Lección» y «Repaso» se escriben igual en gallego y en castellano.
      label: '${leccion.repaso ? 'Repaso' : 'Lección'} ${leccion.numero}',
      child: InkWell(
        key: ValueKey('leccion_punto_${leccion.numero}'),
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: actual ? acento : Colors.white,
            border: Border.all(
              color: leccion.repaso ? AppTheme.border : acento,
              width: deHoxe ? 3 : 1.5,
            ),
          ),
          child: Text(
            leccion.repaso ? 'R' : '${leccion.numero}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: actual ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

/// La lección de la semana con su carga: mientras llegan las lecciones, el
/// hueco quieto; si no llegan, nada.
class LeccionDaSemanaCargada extends StatefulWidget {
  final String cursoId;
  final int mesCalendario;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final bool enAula;

  const LeccionDaSemanaCargada({
    super.key,
    required this.cursoId,
    required this.mesCalendario,
    required this.semana,
    required this.language,
    this.audioService,
    this.enAula = false,
  });

  @override
  State<LeccionDaSemanaCargada> createState() => _LeccionDaSemanaCargadaState();
}

class _LeccionDaSemanaCargadaState extends State<LeccionDaSemanaCargada> {
  // Sin catchError: en un SynchronousFuture no completa nunca.
  late final Future<Leccions?> _leccions =
      Leccions.cargar().then<Leccions?>((l) => l, onError: (_) => null);

  @override
  Widget build(BuildContext context) => FutureBuilder<Leccions?>(
        future: _leccions,
        builder: (context, snap) {
          final l = snap.data;
          if (l == null) {
            return snap.connectionState == ConnectionState.done
                ? const SizedBox.shrink()
                : Container(
                    key: const Key('leccion_cargando'),
                    height: 220,
                    decoration: BoxDecoration(
                      color: context.acentoTint,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    ),
                  );
          }
          return LeccionDaSemana(
            leccions: l,
            cursoId: widget.cursoId,
            mesCalendario: widget.mesCalendario,
            semana: widget.semana,
            language: widget.language,
            audioService: widget.audioService,
            enAula: widget.enAula,
          );
        },
      );
}

/// La lección de la semana en la ficha del día (P11): en qué lección se está,
/// las palabras de esa semana y la frase del reto, con su momento.
class LeccionNoCalendario extends StatelessWidget {
  final UnidadeDeLeccions unidade;
  final Leccion leccion;
  final int semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const LeccionNoCalendario({
    super.key,
    required this.unidade,
    required this.leccion,
    required this.semana,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final pezas = leccion.repaso ? leccion.repasa : leccion.novas;
    final reto = leccion.reto;
    return Container(
      key: ValueKey('calendario_leccion_$semana'),
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            leccion.repaso
                ? '${isGl ? 'REPASO' : 'REPASO'} · '
                    '${isGl ? 'SEMANA' : 'SEMANA'} ${leccion.numero} '
                    '${isGl ? 'DE' : 'DE'} ${leccion.de}'
                : '${isGl ? 'LECCIÓN' : 'LECCIÓN'} ${leccion.numero} '
                    '${isGl ? 'DE' : 'DE'} ${leccion.de}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: context.acento,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unidade.titulo.resolve(language),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final p in pezas)
                BotonEscuchar(
                  audioService: audioService,
                  texto: p.en,
                  language: AppLanguage.en,
                  interfaz: language,
                  style: estiloIngles(p.en),
                  comoChip: true,
                  colorChip: context.acento,
                  descripcion: p.en,
                  significado: p.significado,
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${isGl ? 'O reto' : 'El reto'}: «${reto.frase.en}» · '
            '${leccion.momento.resolve(language)} · ${leccion.minutos} min',
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
