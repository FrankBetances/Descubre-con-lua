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
import '../views/camino_do_curso_screen.dart';
import '../views/gramatica_screen.dart';
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

  /// El día de la semana que se enseña (1 = lunes); `null`, ninguno.
  final int? dia;

  const LeccionDaSemana({
    this.dia,
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

    // Qué trae esta semana, contado por clase: «2 verbos, 1 adxectivo».
    final porClase = <String, int>{};
    for (final p in pezas) {
      if (p.que case final q?) {
        porClase.update(q.resolve(lang).split(':').first, (n) => n + 1,
            ifAbsent: () => 1);
      }
    }
    final objectivos = unidade.obxectivos;
    final vistos = _todosObxectivos ? objectivos : objectivos.take(1).toList();

    return Column(
      key: ValueKey('leccion_${leccion.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // La unidad de gramática de la semana, arriba y en grande.
        if (unidade.gramatica case final gr?) ...[
          UnidadeGramaticalDaSemana(
            punto: gr,
            frase: leccion.fraseGramatica,
            language: lang,
            audioService: widget.audioService,
          ),
          const SizedBox(height: 16),
        ],
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
                '${isGl ? 'TEMA' : 'TEMA'} ${iUnidade + 1} '
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
              if (unidade.plan case final pl?) ...[
                const SizedBox(height: 4),
                Text(
                  '${t('doPlan')}: ${pl.resolve(lang)}',
                  key: const Key('leccion_do_plan'),
                  style: lectura,
                ),
              ],
              const SizedBox(height: 8),
              Text(
                leccion.repaso
                    ? 'Semana ${leccion.numero} de ${leccion.de}: repaso'
                    : (isGl
                        ? 'Lección ${leccion.numero} de ${leccion.de} deste tema'
                        : 'Lección ${leccion.numero} de ${leccion.de} de este tema'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (leccion.espera case final e?) ...[
                const SizedBox(height: 6),
                Text(
                  e.resolve(lang),
                  key: const Key('leccion_espera'),
                  style: lectura,
                ),
              ],
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
        // De dónde viene y a dónde va entre cursos: la ruta de los cinco,
        // con el de la criatura resaltado.
        if (g.ruta.isNotEmpty)
          _Bloque(
            clave: 'leccion_ruta',
            icona: Icons.stairs_rounded,
            titulo: t('ruta'),
            children: [
              Text(t('rutaTexto'), style: lectura),
              const SizedBox(height: 10),
              for (final (curso, titulo, texto) in g.ruta)
                Container(
                  key: ValueKey('leccion_ruta_$curso'),
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: curso == widget.cursoId
                        ? context.acentoTint
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: curso == widget.cursoId
                          ? context.acento
                          : AppTheme.border,
                      width: curso == widget.cursoId ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo.resolve(lang),
                        style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: curso == widget.cursoId
                              ? context.acento
                              : AppTheme.textPrimary,
                        ),
                      ),
                      // Solo el curso propio, entero: los demás, el título.
                      if (curso == widget.cursoId) ...[
                        const SizedBox(height: 4),
                        Text(texto.resolve(lang), style: lectura),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        // Qué se trabaja: la gramática del plan y qué clase de palabras trae
        // la semana.
        _Bloque(
          clave: 'leccion_foco',
          icona: Icons.menu_book_rounded,
          titulo: t('foco'),
          children: [
            if (unidade.foco case final f?) ...[
              Text(f.resolve(lang), style: forte),
              const SizedBox(height: 8),
            ],
            if (porClase.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in porClase.entries)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: context.acentoTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${e.value} · ${e.key}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: context.acento,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
        // Cada día, una cosa distinta; la de hoy, resaltada.
        if (leccion.dias.isNotEmpty)
          _Bloque(
            clave: 'leccion_dias',
            icona: Icons.calendar_view_week_rounded,
            titulo: t('dias'),
            children: [
              for (final (i, d) in leccion.dias.indexed)
                Container(
                  key: ValueKey('leccion_dia_${i + 1}'),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        widget.dia == i + 1 ? context.acentoTint : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: widget.dia == i + 1
                          ? context.acento
                          : AppTheme.border,
                      width: widget.dia == i + 1 ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.dia == i + 1
                            ? '${t('hoxe')} · ${d.dia.resolve(lang).toUpperCase()}'
                            : d.dia.resolve(lang).toUpperCase(),
                        style: kicker,
                      ),
                      const SizedBox(height: 4),
                      Text(d.texto.resolve(lang), style: lectura),
                      if (d.en case final en?) ...[
                        const SizedBox(height: 6),
                        BotonEscuchar(
                          audioService: widget.audioService,
                          texto: en,
                          language: AppLanguage.en,
                          interfaz: lang,
                          style: estiloIngles(en),
                          comoChip: true,
                          colorChip: context.acento,
                          descripcion: en,
                          significado: d.significado,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
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
                            if (p.que case final q?) q.resolve(lang),
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
              rotulo: isGl ? 'O XOGO DO TEMA' : 'EL JUEGO DEL TEMA',
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
  final int? dia;

  const LeccionDaSemanaCargada({
    this.dia,
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
          // La misma lección clara en casa y en el aula (O-20261028-6): la
          // docente ve lo que ven las familias.
          return LeccionFamilia(
            leccions: l,
            cursoId: widget.cursoId,
            mesCalendario: widget.mesCalendario,
            semana: widget.semana,
            dia: widget.dia,
            language: widget.language,
            audioService: widget.audioService,
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

/// Hoxe de las familias (O-20261028-4/6). Arriba, dónde estamos: la unidad
/// de gramática de antes, la de ahora y la siguiente, y el tema del mes con su
/// lección. Debajo, lo de hoy y la semana día a día, como los nodos del camino
/// de duolingo-clone (github.com/sanidhyy/duolingo-clone, MIT): hecho, hoy y
/// lo que viene. Luego lo nuevo de la semana y lo que ya debería saber. El
/// cómo y el porqué, plegados.
class LeccionFamilia extends StatefulWidget {
  final Leccions leccions;
  final String cursoId;
  final int mesCalendario;
  final int semana;
  final int? dia;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const LeccionFamilia({
    super.key,
    required this.leccions,
    required this.cursoId,
    required this.mesCalendario,
    required this.semana,
    required this.language,
    this.dia,
    this.audioService,
  });

  @override
  State<LeccionFamilia> createState() => _LeccionFamiliaState();
}

class _LeccionFamiliaState extends State<LeccionFamilia> {
  /// El día que se mira en la semana; `null` es hoy.
  int? _diaElixido;

  @override
  void didUpdateWidget(LeccionFamilia old) {
    super.didUpdateWidget(old);
    if (old.cursoId != widget.cursoId ||
        old.mesCalendario != widget.mesCalendario ||
        old.semana != widget.semana) {
      _diaElixido = null;
    }
  }

  Widget _chip(PezaDaLeccion p) => BotonEscuchar(
        audioService: widget.audioService,
        texto: p.en,
        language: AppLanguage.en,
        interfaz: widget.language,
        style: estiloIngles(p.en),
        comoChip: true,
        colorChip: context.acento,
        descripcion: p.en,
        significado: p.significado,
      );

  static const _iconas = [
    Icons.headphones_rounded,
    Icons.record_voice_over_rounded,
    Icons.music_note_rounded,
    Icons.extension_rounded,
    Icons.auto_stories_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final g = widget.leccions;
    final daSemana = g.da(widget.cursoId, widget.mesCalendario, widget.semana);
    if (daSemana == null) return const SizedBox.shrink();
    final (unidade, leccion) = daSemana;
    final unidades = g.unidades[widget.cursoId] ?? const [];
    final iU = unidades.indexWhere((u) => u.id == unidade.id);
    final grupo = LeccionDaSemana.grupos[widget.cursoId]?.resolve(lang) ?? '';
    final pezas = leccion.repaso ? leccion.repasa : leccion.novas;
    final acento = context.acento;
    final hoxeN = (widget.dia ?? 1).clamp(1, 5);
    final nDia = _diaElixido ?? hoxeN;
    final dia = leccion.dias.length >= nDia ? leccion.dias[nDia - 1] : null;
    final reto = leccion.reto;

    final kicker = TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      color: acento,
    );
    const lectura =
        TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.4);
    const forte = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
        height: 1.3);
    BoxDecoration tarxeta({bool chea = false}) => BoxDecoration(
          color: chea ? context.acentoTint : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: chea ? acento : AppTheme.border),
        );

    Widget paso(String rotulo, PuntoDeGramatica? p, {bool agora = false}) =>
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: agora ? acento : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: agora ? acento : AppTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rotulo,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: agora ? Colors.white : AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p == null ? '—' : '${p.n} · ${p.nivel}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: agora ? Colors.white : acento,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  p?.titulo.resolve(lang) ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: agora ? Colors.white : AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );

    return Column(
      key: ValueKey('leccion_${leccion.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1 · Dónde estamos, de dónde venimos y a dónde vamos.
        Container(
          key: const Key('leccion_cabeceira'),
          padding: const EdgeInsets.all(14),
          decoration: tarxeta(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${grupo.toUpperCase()} · '
                '${isGl ? 'ONDE ESTAMOS NAS 48 UNIDADES' : 'DÓNDE ESTAMOS EN LAS 48 UNIDADES'}',
                style: kicker,
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                key: const Key('leccion_ruta_gramatica'),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    paso(isGl ? 'ANTES' : 'ANTES', unidade.gramaticaAntes),
                    const SizedBox(width: 6),
                    paso(isGl ? 'AGORA' : 'AHORA', unidade.gramatica,
                        agora: true),
                    const SizedBox(width: 6),
                    paso(
                        isGl ? 'DESPOIS' : 'DESPUÉS', unidade.gramaticaDespois),
                  ],
                ),
              ),
              if (unidade.gramatica?.paraFamilias case final pf?) ...[
                const SizedBox(height: 8),
                Text(pf.resolve(lang), style: lectura),
              ],
              if (leccion.fraseGramatica case final fg?) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      '${isGl ? 'A frase da unidade' : 'La frase de la unidad'} '
                      '${unidade.gramatica?.n ?? ''}:',
                      key: const Key('leccion_gramatica'),
                      style: kicker,
                    ),
                    _chip(fg),
                  ],
                ),
              ],
              const Divider(height: 20),
              Text(
                '${isGl ? 'Tema' : 'Tema'} ${iU + 1} ${isGl ? 'de' : 'de'} ${unidades.length} · '
                '${leccion.repaso ? 'Repaso' : 'Lección'} ${leccion.numero} ${isGl ? 'de' : 'de'} ${leccion.de}',
                key: const Key('leccion_tema'),
                style: kicker,
              ),
              const SizedBox(height: 2),
              Text(unidade.titulo.resolve(lang), style: forte),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  key: const Key('leccion_progreso'),
                  value: ((iU * 4) + leccion.numero) / (unidades.length * 4),
                  minHeight: 8,
                  color: acento,
                  backgroundColor: context.acentoTint,
                ),
              ),
              // La barra es del curso entero, no del tema: se dice.
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    'Curso: ${isGl ? 'semana' : 'semana'} ${iU * 4 + leccion.numero} de ${unidades.length * 4}',
                    key: const Key('leccion_progreso_texto'),
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  TextButton(
                    key: const Key('leccion_ver_camino'),
                    onPressed: () => Navigator.of(context).push(RutaLua(
                      de: context,
                      builder: (_) => CaminoDoCursoScreen(
                        leccions: g,
                        cursoId: widget.cursoId,
                        actual: leccion.id,
                        language: lang,
                        audioService: widget.audioService,
                      ),
                    )),
                    child: Text(isGl
                        ? 'Os ${unidades.length} temas'
                        : 'Los ${unidades.length} temas'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // 2 · La semana, día a día (los nodos de duolingo-clone), y lo de hoy.
        const SizedBox(height: 12),
        Container(
          key: const Key('leccion_hoxe'),
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
          decoration: tarxeta(chea: true),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                key: const Key('leccion_dias'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 1; i <= leccion.dias.length; i++)
                    _NodoDoDia(
                      clave: 'leccion_dia_$i',
                      icona: _iconas[(i - 1) % _iconas.length],
                      dia: leccion.dias[i - 1].dia.resolve(lang),
                      feito: i < hoxeN,
                      hoxe: i == hoxeN,
                      elixido: i == nDia,
                      onTap: () =>
                          setState(() => _diaElixido = i == hoxeN ? null : i),
                    ),
                ],
              ),
              if (dia != null) ...[
                const SizedBox(height: 14),
                Text(
                  nDia == hoxeN
                      ? '${g.texto('hoxe', lang)} · ${dia.dia.resolve(lang).toUpperCase()}'
                      : dia.dia.resolve(lang).toUpperCase(),
                  style: kicker,
                ),
                const SizedBox(height: 4),
                Text(dia.texto.resolve(lang), style: forte),
                if (dia.en case final en?) ...[
                  const SizedBox(height: 8),
                  _chip(PezaDaLeccion(
                      tipo: 'dia', en: en, significado: dia.significado)),
                ],
              ],
              // 3 · Lo nuevo de la semana, con lo de hoy: es lo que se usa.
              Divider(height: 24, color: acento.withValues(alpha: 0.25)),
              Column(
                key: const Key('leccion_esta_semana'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leccion.repaso
                        ? (isGl ? 'ESTA SEMANA VOLVEN' : 'ESTA SEMANA VUELVEN')
                        : (isGl
                            ? 'O NOVO DESTA SEMANA'
                            : 'LO NUEVO DE ESTA SEMANA'),
                    style: kicker,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    key: const Key('leccion_novas'),
                    spacing: 8,
                    runSpacing: 8,
                    children: [for (final p in pezas) _chip(p)],
                  ),
                ],
              ),
            ],
          ),
        ),
        // 4 · Lo que ya debería saber: lo de antes.
        if (leccion.xaSabe.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            key: const Key('leccion_xa_sabe'),
            padding: const EdgeInsets.all(16),
            decoration: tarxeta(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGl ? 'XA DEBERÍA SABER' : 'YA DEBERÍA SABER',
                  style: kicker,
                ),
                const SizedBox(height: 4),
                Text(
                  [
                    if (unidade.gramaticaAntes case final ga?)
                      '${isGl ? 'A unidade' : 'La unidad'} ${ga.n}, ${ga.titulo.resolve(lang)},',
                    isGl
                        ? 'e estas palabras de antes. Se algunha non a recorda, dila ti tamén esta semana.'
                        : 'y estas palabras de antes. Si alguna no la recuerda, dila tú también esta semana.',
                  ].join(' '),
                  style: lectura,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final p in leccion.xaSabe) _chip(p)],
                ),
              ],
            ),
          ),
        ],
        // 5 · Cómo y por qué: plegado.
        const SizedBox(height: 12),
        Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            side: const BorderSide(color: AppTheme.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: ExpansionTile(
            key: const Key('leccion_como_e_por_que'),
            leading: Icon(Icons.menu_book_rounded, color: acento),
            title: Text(isGl ? 'Guía: como e por que' : 'Guía: cómo y por qué',
                style: forte),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${leccion.momento.resolve(lang)} · ${leccion.minutos} min',
                style: forte,
              ),
              const SizedBox(height: 4),
              Text(reto.queFacer.resolve(lang), style: lectura),
              const SizedBox(height: 4),
              Text(reto.mans.resolve(lang), style: lectura),
              const SizedBox(height: 8),
              Text(
                g
                    .texto('paso3Espera', lang)
                    .replaceAll('{n}', '${reto.esperaSegundos}'),
                style: forte,
              ),
              Text(reto.nonPedir.resolve(lang), style: lectura),
              if (leccion.espera case final e?) ...[
                const SizedBox(height: 8),
                Text(e.resolve(lang), style: forte),
              ],
              const SizedBox(height: 10),
              for (final k in ['paso1Porque', 'paso2Porque', 'paso3Porque'])
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text('${g.texto('porque', lang)} ${g.texto(k, lang)}',
                      style: lectura),
                ),
              if (leccion.queMirar.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(g.texto('sinais', lang), style: forte),
                for (final o in leccion.queMirar)
                  Text('·  ${o.resolve(lang)}', style: lectura),
              ],
              TextButton(
                key: const Key('leccion_ver_gramatica'),
                onPressed: () => Navigator.of(context).push(RutaLua(
                  de: context,
                  builder: (_) => GramaticaScreen(
                    language: lang,
                    audioService: widget.audioService,
                    destacado: unidade.gramatica?.n,
                  ),
                )),
                child: Text(isGl
                    ? 'Ver as 48 unidades, de A1 a C1'
                    : 'Ver las 48 unidades, de A1 a C1'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Un día de la semana como nodo de duolingo-clone: redondo, con el canto de
/// abajo más oscuro; hecho, hoy (con anillo) o por venir.
class _NodoDoDia extends StatelessWidget {
  final String clave;
  final IconData icona;
  final String dia;
  final bool feito;
  final bool hoxe;
  final bool elixido;
  final VoidCallback onTap;

  const _NodoDoDia({
    required this.clave,
    required this.icona,
    required this.dia,
    required this.feito,
    required this.hoxe,
    required this.elixido,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    final activo = feito || hoxe;
    final cor = activo ? acento : const Color(0xFFE5E7EB);
    final canto = activo
        ? Color.lerp(acento, Colors.black, 0.25)!
        : const Color(0xFFC4C8CF);
    return Semantics(
      button: true,
      selected: elixido,
      label: dia,
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey(clave),
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: 58,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: elixido ? acento : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cor,
                    shape: BoxShape.circle,
                    border: Border(bottom: BorderSide(color: canto, width: 5)),
                  ),
                  child: Icon(
                    feito ? Icons.check_rounded : icona,
                    size: 22,
                    color: activo ? Colors.white : const Color(0xFF9CA3AF),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dia.length > 3 ? dia.substring(0, 3) : dia,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: hoxe ? FontWeight.w800 : FontWeight.w600,
                  color: hoxe ? acento : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La unidad de gramática de la semana, arriba y en grande (Frank,
/// 28/10/2026: «pon la maldita unidad que se está tratando en la semana»):
/// su número de los 48, el nivel, el título, qué es en una línea y la frase.
class UnidadeGramaticalDaSemana extends StatelessWidget {
  final PuntoDeGramatica punto;
  final PezaDaLeccion? frase;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const UnidadeGramaticalDaSemana({
    super.key,
    required this.punto,
    required this.language,
    this.frase,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final acento = context.acento;
    return Container(
      key: const Key('leccion_unidade_gramatical'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: acento, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isGl ? 'UNIDADE' : 'UNIDAD'} ${punto.n} ${isGl ? 'DE' : 'DE'} 48 · ${punto.nivel}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: acento,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            punto.titulo.resolve(language),
            key: const Key('leccion_unidade_titulo'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.15,
            ),
          ),
          if (punto.paraFamilias case final pf?) ...[
            const SizedBox(height: 6),
            Text(
              pf.resolve(language),
              style: const TextStyle(
                fontSize: 15.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
          if (frase case final f?) ...[
            const SizedBox(height: 10),
            Text(
              isGl ? 'A frase desta semana' : 'La frase de esta semana',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            BotonEscuchar(
              audioService: audioService,
              texto: f.en,
              language: AppLanguage.en,
              interfaz: language,
              style: estiloIngles(f.en),
              comoChip: true,
              colorChip: acento,
              descripcion: f.en,
              significado: f.significado,
            ),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              key: const Key('leccion_ver_gramatica'),
              onPressed: () => Navigator.of(context).push(RutaLua(
                de: context,
                builder: (_) => GramaticaScreen(
                  language: language,
                  audioService: audioService,
                  destacado: punto.n,
                ),
              )),
              child: Text(isGl
                  ? 'Ver as 48 unidades, de A1 a C1'
                  : 'Ver las 48 unidades, de A1 a C1'),
            ),
          ),
        ],
      ),
    );
  }
}
