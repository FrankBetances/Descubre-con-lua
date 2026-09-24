import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../docentes/widgets/hoxe_na_aula.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;

/// Las 4.000 palabras del trayecto, por curso, mes, semana y día, con su
/// sonido, lo que significan y el gesto. Y un buscador para las cinco edades.
///
/// Hasta ahora las palabras solo se veían de cinco en cinco, el día que
/// tocaban. Para preparar la semana, o para saber cuándo sale «umbrella», no
/// había dónde mirarlas.
class PalabrasDoTraxectoScreen extends StatefulWidget {
  final ProgramaTpr? programa;
  final String cursoInicial;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// Para los tests: el día que se quiere ver. Por defecto, hoy.
  final DateTime? agora;

  const PalabrasDoTraxectoScreen({
    super.key,
    required this.programa,
    this.cursoInicial = 'curso_0_2',
    this.language = AppLanguage.gl,
    this.audioService,
    this.agora,
  });

  /// Cuántos resultados enseña el buscador como mucho.
  static const int maxResultados = 60;

  @override
  State<PalabrasDoTraxectoScreen> createState() =>
      _PalabrasDoTraxectoScreenState();
}

class _PalabrasDoTraxectoScreenState extends State<PalabrasDoTraxectoScreen> {
  late String _curso = widget.cursoInicial;
  late int _mes = diaDoCursoParaHoxe(agora: widget.agora).dia.mesCalendario;
  late int _semana = diaDoCursoParaHoxe(agora: widget.agora).dia.semana;
  String _busca = '';

  static String _normal(String s) => s
      .toLowerCase()
      .replaceAll(RegExp('[áà]'), 'a')
      .replaceAll(RegExp('[éè]'), 'e')
      .replaceAll(RegExp('[íì]'), 'i')
      .replaceAll(RegExp('[óò]'), 'o')
      .replaceAll(RegExp('[úùü]'), 'u')
      .replaceAll('ñ', 'n');

  List<({CursoTpr curso, PalabraNoCurso p})> _resultados(ProgramaTpr programa) {
    final q = _normal(_busca.trim());
    if (q.isEmpty) return const [];
    final fora = <({CursoTpr curso, PalabraNoCurso p})>[];
    for (final c in programa.cursos) {
      for (final p in c.palabrasEnOrde) {
        final w = p.palabra;
        if (_normal(w.en).contains(q) ||
            _normal(w.gl).contains(q) ||
            _normal(w.es).contains(q)) {
          fora.add((curso: c, p: p));
          if (fora.length >= PalabrasDoTraxectoScreen.maxResultados) {
            return fora;
          }
        }
      }
    }
    return fora;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final programa = widget.programa;
    final curso = programa?.curso(_curso);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          isGl ? 'As palabras do traxecto' : 'Las palabras del trayecto',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: programa == null || curso == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('traxecto_lista'),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    isGl
                        ? '${formatarMiles(programa.totalPalabras)} palabras en ${programa.cursos.length} cursos, ${programa.modelo.ritmoDiario} novas cada día de luns a xoves.'
                        : '${formatarMiles(programa.totalPalabras)} palabras en ${programa.cursos.length} cursos, ${programa.modelo.ritmoDiario} nuevas cada día de lunes a jueves.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    key: const Key('traxecto_busca'),
                    onChanged: (v) => setState(() => _busca = v),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: isGl
                          ? 'Buscar en inglés, galego ou castelán'
                          : 'Buscar en inglés, gallego o castellano',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_busca.trim().isNotEmpty)
                    ..._buscador(programa, lang)
                  else
                    ..._porSemana(programa, curso, lang),
                ],
              ),
      ),
    );
  }

  List<Widget> _buscador(ProgramaTpr programa, AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    final r = _resultados(programa);
    return [
      Text(
        r.isEmpty
            ? (isGl
                ? 'Ningunha palabra coincide.'
                : 'Ninguna palabra coincide.')
            : r.length >= PalabrasDoTraxectoScreen.maxResultados
                ? (isGl
                    ? 'As primeiras ${r.length}: afina a busca.'
                    : 'Las primeras ${r.length}: afina la búsqueda.')
                : (isGl ? '${r.length} palabras' : '${r.length} palabras'),
        key: const Key('traxecto_resultados'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppTheme.textSecondary,
        ),
      ),
      const SizedBox(height: 8),
      for (final x in r)
        _Fila(
          palabra: x.p.palabra,
          language: lang,
          audioService: widget.audioService,
          onde: '${x.curso.etiqueta.resolve(lang)} · '
              '${nomeDoMes[x.p.mesCalendario]?.resolve(lang) ?? ''} · '
              'semana ${x.p.semana} · '
              '${PalabrasDoDia.nomesDosDias[x.p.dia - 1].resolve(lang)}',
        ),
    ];
  }

  List<Widget> _porSemana(
      ProgramaTpr programa, CursoTpr curso, AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    final semana = curso.semana(_mes, _semana);
    return [
      SelectorDeCursoTpr(
        programa: programa,
        seleccionado: _curso,
        language: lang,
        prefixoClave: 'traxecto_curso',
        onCambiar: (c) => setState(() => _curso = c),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (final m in curso.meses)
            ChoiceChip(
              key: ValueKey('traxecto_mes_${m.mesCalendario}'),
              label: Text(nomeDoMes[m.mesCalendario]?.resolve(lang) ?? ''),
              selected: m.mesCalendario == _mes,
              showCheckmark: false,
              onSelected: (_) => setState(() => _mes = m.mesCalendario),
            ),
        ],
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 6,
        runSpacing: 6,
        children: [
          for (var s = 1; s <= 4; s++)
            ChoiceChip(
              key: ValueKey('traxecto_semana_$s'),
              label: Text('${isGl ? 'Semana' : 'Semana'} $s'),
              selected: s == _semana,
              showCheckmark: false,
              onSelected: (_) => setState(() => _semana = s),
            ),
        ],
      ),
      const SizedBox(height: 14),
      if (semana != null) ...[
        Text(
          semana.tema.resolve(lang),
          key: const Key('traxecto_tema'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        for (var d = 1; d <= WeeklyTprScheduler.diasConPalabrasNovas; d++) ...[
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 6),
            child: Text(
              '${PalabrasDoDia.nomesDosDias[d - 1].resolve(lang).toUpperCase()}'
              ' · ${isGl ? 'BLOQUE' : 'BLOQUE'} ${semana.planDoDia(d).bloque}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: AppTheme.primaryInk,
              ),
            ),
          ),
          for (final p in semana.planDoDia(d).newWords)
            _Fila(
              palabra: p,
              language: lang,
              audioService: widget.audioService,
            ),
        ],
        const SizedBox(height: 10),
        Text(
          isGl
              ? 'VENRES · RETO: as ${semana.palabras.length} da semana, sen novas.'
              : 'VIERNES · RETO: las ${semana.palabras.length} de la semana, sin nuevas.',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppTheme.primaryInk,
          ),
        ),
      ],
    ];
  }
}

/// Una palabra: su sonido, lo que significa y el gesto.
class _Fila extends StatelessWidget {
  final TprWord palabra;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final String? onde;

  const _Fila({
    required this.palabra,
    required this.language,
    required this.audioService,
    this.onde,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey('traxecto_palabra_${palabra.id}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BotonEscuchar(
            audioService: audioService,
            texto: palabra.en,
            language: AppLanguage.en,
            // La misma regla que el corpus de voz: con otro estilo el botón
            // buscaría una grabación que no existe.
            style: estiloIngles(palabra.en),
            comoChip: true,
            colorChip: AppTheme.primaryDark,
            descripcion: palabra.en,
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: palabra.significado(language),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              TextSpan(text: ' · ${palabra.tprAction.resolve(language)}'),
            ]),
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          if (onde != null) ...[
            const SizedBox(height: 3),
            Text(
              onde!,
              style: const TextStyle(
                fontSize: 11.5,
                color: AppTheme.primaryInk,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
