import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/espera_visible.dart';
import '../../../data/models/conto_dialogado_model.dart';
import '../../../data/models/hogar_model.dart';
import '../../../data/models/leccion_model.dart';
import '../../cuentos/views/contos_dialogados_screen.dart';
import '../../../data/models/steam_do_mes_model.dart';
import '../../../data/models/xogos_fogar_model.dart';
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
  late final Future<XogosFogar?> _xogos =
      XogosFogar.cargar().then<XogosFogar?>((x) => x, onError: (_) => null);
  late final Future<SteamDoMes?> _steam =
      SteamDoMes.cargar().then<SteamDoMes?>((s) => s, onError: (_) => null);

  /// La lección elegida en la tira; `null` es la de esta semana.
  String? _elixida;
  bool _todosObxectivos = false;

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
    final g = widget.leccions;
    String t(String clave) => g.texto(clave, lang);
    final daSemana = g.da(widget.cursoId, widget.mesCalendario, widget.semana);
    if (daSemana == null) return const SizedBox.shrink();
    final (unidade, leccion) = _elixida == null
        ? daSemana
        : (g.porId(widget.cursoId, _elixida!) ?? daSemana);
    final unidades = g.unidades[widget.cursoId] ?? const [];
    final iUnidade = unidades.indexWhere((u) => u.id == unidade.id);
    final grupo = LeccionDaSemana.grupos[widget.cursoId]?.resolve(lang) ?? '';
    final reto = leccion.reto;
    final pezas = leccion.repaso ? leccion.repasa : leccion.novas;

    // A dónde va: la lección siguiente de la unidad o, si es la última, la
    // unidad siguiente.
    final iLeccion = unidade.leccions.indexWhere((l) => l.id == leccion.id);
    final seguinte = iLeccion + 1 < unidade.leccions.length
        ? unidade.leccions[iLeccion + 1]
        : null;
    final unidadeSeguinte = seguinte == null && iUnidade + 1 < unidades.length
        ? unidades[iUnidade + 1]
        : null;

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
    const forte = TextStyle(
      fontSize: 15.5,
      fontWeight: FontWeight.w700,
      color: AppTheme.textPrimary,
      height: 1.35,
    );

    final objectivos = unidade.obxectivos;
    final vistos = _todosObxectivos ? objectivos : objectivos.take(1).toList();

    return Column(
      key: ValueKey('leccion_${leccion.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // De dónde viene y a dónde va: la unidad, la lección y su meta.
        Container(
          key: const Key('leccion_cabeceira'),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [context.acentoTint, Colors.white],
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${grupo.toUpperCase()} · '
                '${isGl ? 'UNIDADE' : 'UNIDAD'} ${iUnidade + 1} '
                'DE ${unidades.length}',
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
                    ? 'Semana ${leccion.numero} de ${leccion.de}: repaso'
                    : 'Lección ${leccion.numero} de ${leccion.de}',
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
              if (objectivos.isNotEmpty) ...[
                const Divider(height: 24),
                Row(
                  key: const Key('leccion_a_onde'),
                  children: [
                    Icon(Icons.flag_rounded, size: 18, color: context.acento),
                    const SizedBox(width: 6),
                    Expanded(
                        child: Text(t('aOnde').toUpperCase(), style: kicker)),
                  ],
                ),
                for (final o in vistos)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(o.resolve(lang), style: lectura),
                  ),
                if (objectivos.length > 1)
                  TextButton(
                    key: const Key('leccion_obxectivos'),
                    onPressed: () =>
                        setState(() => _todosObxectivos = !_todosObxectivos),
                    child: Text(_todosObxectivos
                        ? (isGl ? 'Ver menos' : 'Ver menos')
                        : (isGl
                            ? 'Ver os ${objectivos.length} obxectivos'
                            : 'Ver los ${objectivos.length} objetivos')),
                  ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        Text(
          t('comoFunciona'),
          key: const Key('leccion_como_funciona'),
          style: lectura,
        ),
        // De dónde viene: lo de las semanas anteriores. En el repaso es lo
        // mismo que el paso 1, así que no se repite.
        if (!leccion.repaso)
          _Bloque(
            clave: 'leccion_xa_sabe',
            icona: Icons.history_rounded,
            titulo: t('deOnde'),
            children: [
              Text(leccion.xaSabe.isEmpty ? t('comezo') : t('deOndeTexto'),
                  style: lectura),
              if (leccion.xaSabe.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final p in leccion.xaSabe) _chip(p, lang)],
                ),
              ],
            ],
          ),
        Padding(
          padding: const EdgeInsets.only(top: 22, bottom: 2),
          child: Text(t('pasos').toUpperCase(), style: kicker),
        ),
        _Paso(
          numero: 1,
          icona: Icons.headphones_rounded,
          titulo: t(leccion.repaso ? 'paso1Repaso' : 'paso1'),
          porque: t('paso1Porque'),
          rotuloPorque: t('porque'),
          children: [
            Text(t('paso1Texto'), style: lectura),
            const SizedBox(height: 10),
            Column(
              key: const Key('leccion_novas'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in pezas)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    // La palabra y, al lado si cabe, lo que quiere decir y su
                    // gesto. Wrap y no Row: una frase larga con el texto
                    // grande no cabe al lado y baja.
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _chip(p, lang),
                        Text(
                          [
                            if (p.significado case final s?) s.resolve(lang),
                            if (p.xesto case final x?) x.resolve(lang),
                          ].join(' · '),
                          style: lectura,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
        _Paso(
          numero: 2,
          icona: Icons.schedule_rounded,
          titulo: t('paso2'),
          porque: t('paso2Porque'),
          rotuloPorque: t('porque'),
          children: [
            Text(
              '${leccion.momento.resolve(lang)} · ${leccion.minutos} min',
              key: const Key('leccion_momento'),
              style: forte,
            ),
            if (leccion.escena.resolve(lang).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(leccion.escena.resolve(lang), style: lectura),
              ),
            const SizedBox(height: 10),
            BotonEscuchar(
              audioService: widget.audioService,
              texto: reto.frase.en,
              language: AppLanguage.en,
              interfaz: lang,
              style: estiloIngles(reto.frase.en),
              comoChip: true,
              colorChip: context.acento,
              descripcion: reto.frase.en,
              significado: reto.frase.significado,
            ),
            const SizedBox(height: 8),
            Text(reto.queFacer.resolve(lang), style: lectura),
            const SizedBox(height: 6),
            Text(reto.mans.resolve(lang), style: lectura),
          ],
        ),
        _Paso(
          numero: 3,
          icona: Icons.celebration_rounded,
          titulo: t('paso3'),
          porque: t('paso3Porque'),
          rotuloPorque: t('porque'),
          children: [
            Text(
              t('paso3Espera').replaceAll('{n}', '${reto.esperaSegundos}'),
              style: forte,
            ),
            const SizedBox(height: 8),
            EsperaVisible(
              segundos: reto.esperaSegundos,
              language: lang,
              color: context.acento,
              fondo: context.acentoTint,
            ),
            const SizedBox(height: 8),
            Text(reto.nonPedir.resolve(lang), style: lectura),
            Theme(
              data:
                  Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const Key('leccion_se_responde'),
                tilePadding: EdgeInsets.zero,
                childrenPadding: const EdgeInsets.only(bottom: 8),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                title: Text(
                  t('seResponde'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: context.acento,
                  ),
                ),
                children: [
                  for (final (k, v) in [
                    ('silencio', reto.recastSilencio),
                    ('linguaCasa', reto.recastLinguaCasa),
                    ('unhaPalabra', reto.recastUnhaPalabra),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                              text: '${t(k)}: ',
                              style: forte.copyWith(fontSize: 15)),
                          TextSpan(text: v.resolve(lang)),
                        ]),
                        style: lectura,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        _Bloque(
          clave: 'leccion_gozar',
          icona: Icons.auto_stories_rounded,
          titulo: t('gozar'),
          children: [
            if (leccion.conto != null)
              FutureBuilder<BibliotecaDialogada?>(
                future: _biblioteca,
                builder: (context, snap) {
                  final conto = snap.data?.contos
                      .where((c) => c.id == leccion.conto)
                      .firstOrNull;
                  if (conto == null) return const SizedBox.shrink();
                  return FilaPaso(
                    claveFila: ValueKey('leccion_conto_${conto.id}'),
                    icona: Icons.auto_stories_rounded,
                    rotulo:
                        isGl ? 'O CONTO DA SEMANA' : 'EL CUENTO DE LA SEMANA',
                    titulo: conto.titulo.resolve(lang),
                    onTap: () => Navigator.of(context).push(RutaLua(
                      de: context,
                      builder: (_) => ContoDialogadoScreen(
                        conto: conto,
                        language: lang,
                        audioService: widget.audioService,
                      ),
                    )),
                  );
                },
              ),
            XogoDoReto(
              hogar: HogarDaUnidade(
                momento: leccion.momento,
                minutos: leccion.minutos,
                escena: leccion.escena,
                retos: [reto],
                xogo: leccion.xogo,
                steam: leccion.steam,
              ),
              xogos: _xogos,
              steam: _steam,
              language: lang,
              rotulo: isGl ? 'O XOGO DA UNIDADE' : 'EL JUEGO DE LA UNIDAD',
              kicker: kicker,
            ),
          ],
        ),
        if (leccion.queMirar.isNotEmpty)
          _Bloque(
            clave: 'leccion_sinais',
            icona: Icons.visibility_rounded,
            titulo: t('sinais'),
            children: [
              for (final o in leccion.queMirar)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3, right: 8),
                        child: Icon(Icons.check_circle_outline_rounded,
                            size: 18, color: context.acento),
                      ),
                      Expanded(child: Text(o.resolve(lang), style: lectura)),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Text(t('sinaisTexto'),
                  style: lectura.copyWith(fontStyle: FontStyle.italic)),
            ],
          ),
        // A dónde va: lo que viene después.
        if (seguinte != null || unidadeSeguinte != null)
          _Bloque(
            clave: 'leccion_seguinte',
            icona: Icons.arrow_forward_rounded,
            titulo: t('seguinte'),
            children: [
              if (seguinte case final s?) ...[
                if (s.repaso)
                  Text(
                      isGl
                          ? 'Repaso de toda a unidade.'
                          : 'Repaso de toda la unidad.',
                      style: lectura)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final p in s.novas) _chip(p, lang)],
                  ),
              ] else if (unidadeSeguinte case final u?)
                Text(
                  '${t('seguinteUnidade')}: ${u.titulo.resolve(lang)}',
                  style: forte,
                ),
            ],
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

/// Un bloque de la lección: icono, título y lo que lleva dentro.
class _Bloque extends StatelessWidget {
  final String clave;
  final IconData icona;
  final String titulo;
  final List<Widget> children;

  const _Bloque({
    required this.clave,
    required this.icona,
    required this.titulo,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Padding(
        key: Key(clave),
        padding: const EdgeInsets.only(top: 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icona, size: 22, color: context.acento),
                const SizedBox(width: 8),
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      );
}

/// Uno de los tres pasos de la semana, con su porqué.
class _Paso extends StatelessWidget {
  final int numero;
  final IconData icona;
  final String titulo;
  final String porque;
  final String rotuloPorque;
  final List<Widget> children;

  const _Paso({
    required this.numero,
    required this.icona,
    required this.titulo,
    required this.porque,
    required this.rotuloPorque,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    // Material y no un Container decorado: el pliegue de «qué decir
    // después» necesita dónde pintar el toque.
    return Padding(
      key: ValueKey('leccion_paso_$numero'),
      padding: const EdgeInsets.only(top: 12),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: const BorderSide(color: AppTheme.border),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration:
                        BoxDecoration(color: acento, shape: BoxShape.circle),
                    child: Text(
                      '$numero',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Icon(icona, color: acento),
                ],
              ),
              const SizedBox(height: 12),
              ...children,
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 1, right: 8),
                      child: Icon(Icons.lightbulb_outline_rounded,
                          size: 20, color: acento),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(
                            text: '$rotuloPorque ',
                            style: TextStyle(
                                fontWeight: FontWeight.w800, color: acento),
                          ),
                          TextSpan(text: porque),
                        ]),
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
