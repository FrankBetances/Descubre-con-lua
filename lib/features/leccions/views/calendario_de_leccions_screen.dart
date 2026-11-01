import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/leccion_model.dart';
import '../../familias/widgets/selector_idade.dart';
import '../widgets/leccion_da_semana.dart';

/// El calendario de casa y del aula (O-20261101-1, aprobado por Frank): un
/// selector de edad, los 10 meses en una fila y las 4 semanas de cada mes,
/// cada una con su unidad de las 48, su STEAM y sus palabras. Tocar una
/// semana abre esa lección, la misma que Hoy.
class CalendarioDeLeccionsScreen extends StatefulWidget {
  final String cursoId;
  final ValueChanged<String> onCambiarCurso;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final OfflineAudioService? audioService;
  final bool paraAula;
  final DateTime? agora;

  /// El calendario de antes, entero, a un toque: el registro del aula y la
  /// asamblea de cada día siguen ahí.
  final WidgetBuilder? calendarioCompleto;

  const CalendarioDeLeccionsScreen({
    super.key,
    required this.cursoId,
    required this.onCambiarCurso,
    required this.language,
    required this.onLanguageChanged,
    this.audioService,
    this.paraAula = false,
    this.agora,
    this.calendarioCompleto,
  });

  @override
  State<CalendarioDeLeccionsScreen> createState() =>
      _CalendarioDeLeccionsScreenState();
}

const _meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];
const _nomes = {
  9: ('Setembro', 'Septiembre'),
  10: ('Outubro', 'Octubre'),
  11: ('Novembro', 'Noviembre'),
  12: ('Decembro', 'Diciembre'),
  1: ('Xaneiro', 'Enero'),
  2: ('Febreiro', 'Febrero'),
  3: ('Marzo', 'Marzo'),
  4: ('Abril', 'Abril'),
  5: ('Maio', 'Mayo'),
  6: ('Xuño', 'Junio'),
};

class _CalendarioDeLeccionsScreenState
    extends State<CalendarioDeLeccionsScreen> {
  // Sin catchError: en un SynchronousFuture no completa nunca.
  late final Future<Leccions?> _leccions =
      Leccions.cargar().then<Leccions?>((l) => l, onError: (_) => null);
  late int _mes = () {
    final m = (widget.agora ?? DateTime.now()).month;
    return _meses.contains(m) ? m : 9;
  }();

  void _abrir(Leccions l, int semana) {
    final lang = widget.language;
    Navigator.of(context).push(RutaLua(
      de: context,
      builder: (_) => Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: Cabecera(
          titulo:
              '${_nome(_mes, lang)} · ${lang == AppLanguage.gl ? 'semana' : 'semana'} $semana',
          language: lang,
          onLanguageChanged: widget.onLanguageChanged,
        ),
        body: SafeArea(
          child: ListView(
            key: const Key('calendario_leccion'),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              LeccionFamilia(
                leccions: l,
                cursoId: widget.cursoId,
                mesCalendario: _mes,
                semana: semana,
                dia: 1,
                language: lang,
                audioService: widget.audioService,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  static String _nome(int m, AppLanguage lang) =>
      lang == AppLanguage.gl ? _nomes[m]!.$1 : _nomes[m]!.$2;

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'Calendario' : 'Calendario',
        language: lang,
        onLanguageChanged: widget.onLanguageChanged,
      ),
      body: SafeArea(
        child: FutureBuilder<Leccions?>(
          future: _leccions,
          builder: (context, snap) {
            final l = snap.data;
            return ListView(
              key: const Key('calendario_leccions'),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: SelectorIdade(
                    cursoId: widget.cursoId,
                    language: lang,
                    onCambiar: widget.onCambiarCurso,
                    paraAula: widget.paraAula,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    key: const Key('calendario_meses'),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final m in _meses)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            key: ValueKey('calendario_mes_$m'),
                            label: Text(_nome(m, lang)),
                            selected: m == _mes,
                            showCheckmark: false,
                            selectedColor: acento,
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: m == _mes
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                            ),
                            onSelected: (_) => setState(() => _mes = m),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (l != null)
                  if (l.da(widget.cursoId, _mes, 1) case (final u, _))
                    Padding(
                      key: const Key('calendario_mes_cabeceira'),
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (u.gramatica case final gr?)
                            Text(
                              '${isGl ? 'Unidade' : 'Unidad'} ${gr.n} · ${gr.nivel} · ${gr.titulo.resolve(lang)}',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: acento),
                            ),
                          Text(u.titulo.resolve(lang),
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          if (u.steam case final st?)
                            Text('STEAM: ${st.resolve(lang)}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: acento)),
                        ],
                      ),
                    ),
                if (l != null)
                  for (var s = 1; s <= 4; s++)
                    if (l.da(widget.cursoId, _mes, s) case (final u, final lec))
                      _Semana(
                        unidade: u,
                        leccion: lec,
                        semana: s,
                        language: lang,
                        onTap: () => _abrir(l, s),
                      ),
                if (widget.calendarioCompleto case final b?)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('calendario_completo'),
                      icon: const Icon(Icons.calendar_month_rounded),
                      label: Text(isGl
                          ? 'Calendario completo: asembleas e rexistro'
                          : 'Calendario completo: asambleas y registro'),
                      onPressed: () => Navigator.of(context)
                          .push(RutaLua(de: context, builder: b)),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Semana extends StatelessWidget {
  final UnidadeDeLeccions unidade;
  final Leccion leccion;
  final int semana;
  final AppLanguage language;
  final VoidCallback onTap;

  const _Semana({
    required this.unidade,
    required this.leccion,
    required this.semana,
    required this.language,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final acento = context.acento;
    final palabras = (leccion.repaso ? leccion.repasa : leccion.novas)
        .map((p) => p.en)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: const BorderSide(color: AppTheme.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey('calendario_semana_$semana'),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: acento,
                  child: Text('$semana',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${isGl ? 'Semana' : 'Semana'} $semana · ${leccion.reto.nomeFase.resolve(language)}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: acento),
                      ),
                      if (leccion.fraseGramatica case final fg?)
                        Text(
                          fg.en,
                          style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary),
                        ),
                      const SizedBox(height: 2),
                      Text(
                        palabras,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 13.5, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: acento),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
