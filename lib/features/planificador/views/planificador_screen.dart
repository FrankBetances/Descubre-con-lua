import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/localized_string.dart';
import '../../../data/models/normativa_model.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/unidade_curricular_model.dart';
import '../../../data/models/unidade_do_mes_model.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../../../data/repositories/content_repository.dart';
import 'dinamicas_screen.dart';
import 'estrategias_screen.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/widgets/cabecera.dart';
import '../../docentes/nomes_docentes.dart';

/// Planificador curricular docente dos cinco cursos de Educación Infantil (0-6 anos).
class PlanificadorScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const PlanificadorScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<PlanificadorScreen> createState() => _PlanificadorScreenState();
}

class _PlanificadorScreenState extends State<PlanificadorScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language;
  String _selectedCurso = 'curso_0_2';

  // M7.3: cada mes sale de su unidad, del plan curricular de Frank y del
  // marco normativo; ya no de `curriculo_50_meses.json`, que contaba otros
  // temas que los de la asamblea y el plan.
  static const _meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];
  late final Future<Normativa?> _normativa =
      Normativa.cargar().then<Normativa?>((n) => n, onError: (_) => null);
  final Map<String, Future<(Normativa?, List<UnidadeDoMes?>)>> _datos = {};

  // Un futuro por curso, guardado: si se crease en cada build, cambiar de
  // lengua dejaría la lista en blanco mientras vuelve a esperar.
  Future<(Normativa?, List<UnidadeDoMes?>)> _datosDo(String curso) =>
      _datos[curso] ??= Future.wait([
        for (final m in _meses) widget.repository.loadUnidadeDoMes(curso, m),
      ]).then((u) async => (await _normativa, u));

  static const List<Map<String, String>> _cursos = [
    {'id': 'curso_0_2', 'gl': '0 a 2 anos (Nido)', 'es': '0 a 2 años (Nido)'},
    {
      'id': 'curso_2_3',
      'gl': '2 a 3 anos (Comunidade)',
      'es': '2 a 3 años (Comunidad)'
    },
    {
      'id': 'curso_3_4',
      'gl': '3 a 4 anos (Descubridores)',
      'es': '3 a 4 años (Descubridores)'
    },
    {
      'id': 'curso_4_5',
      'gl': '4 a 5 anos (Investigadores)',
      'es': '4 a 5 años (Investigadores)'
    },
    {
      'id': 'curso_5_6',
      'gl': '5 a 6 anos (Grandes Creadores)',
      'es': '5 a 6 años (Grandes Creadores)'
    },
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.programacionCabeceira.resolve(lang),
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: Column(
        children: [
          // Course Selector Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _cursos.map((c) {
                  final isSelected = _selectedCurso == c['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(lang == AppLanguage.gl ? c['gl']! : c['es']!),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCurso = c['id']!);
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          // Estratexias e Dinámicas: eran dous iconos sen texto na cabeceira
          // e deixaban ao título 88 px. Aquí van co seu nome.
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
            child: Row(
              children: [
                TextButton.icon(
                  key: const ValueKey('planificador_estratexias'),
                  icon: const Icon(Icons.psychology_rounded, size: 20),
                  label: Text(
                      lang == AppLanguage.gl ? 'Estratexias' : 'Estrategias'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      RutaLua(
                        de: context,
                        builder: (_) => EstrategiasScreen(
                          repository: widget.repository,
                          initialLanguage: _language,
                          onLanguageChanged: _cambiarLingua,
                        ),
                      ),
                    );
                  },
                ),
                TextButton.icon(
                  key: const ValueKey('planificador_dinamicas'),
                  icon: const Icon(Icons.alarm_rounded, size: 20),
                  label:
                      Text(lang == AppLanguage.gl ? 'Dinámicas' : 'Dinámicas'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      RutaLua(
                        de: context,
                        builder: (_) => DinamicasScreen(
                          repository: widget.repository,
                          initialLanguage: _language,
                          onLanguageChanged: _cambiarLingua,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Los meses del curso
          Expanded(
            child: FutureBuilder<(Normativa?, List<UnidadeDoMes?>)>(
              key: ValueKey('planificador_$_selectedCurso'),
              future: _datosDo(_selectedCurso),
              builder: (context, snap) {
                final datos = snap.data;
                if (datos == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                final (normativa, unidades) = datos;
                final criterio = normativa?.cursos[_selectedCurso];
                return ListView(
                  key: const ValueKey('planificador_meses'),
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (normativa != null && criterio != null)
                      _Marco(
                        normativa: normativa,
                        criterio: criterio,
                        language: lang,
                      ),
                    for (final (i, u) in unidades.indexed)
                      if (u != null)
                        _MesDoPlan(
                          numero: i + 1,
                          unidade: u,
                          nucleo: widget.repository.nucleoSync(u),
                          plan: widget.repository.planCurricularSync
                              ?.para(u.curso, u.mesCalendario),
                          area: normativa?.area,
                          criterio: criterio,
                          language: lang,
                        ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// El marco del curso, una vez arriba: área, encuadre, horario y criterio,
/// con el aviso de que sale del texto de Frank y falta el DOG.
class _Marco extends StatelessWidget {
  final Normativa normativa;
  final CriterioDoCurso criterio;
  final AppLanguage language;

  const _Marco({
    required this.normativa,
    required this.criterio,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    String l(LocalizedString s) => s.resolve(language);
    const corpo =
        TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.35);
    Widget fila(String rotulo, String texto) => Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '$rotulo: ',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              TextSpan(text: texto),
            ]),
            style: corpo,
          ),
        );
    return Container(
      key: const ValueKey('planificador_marco'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isGl ? 'O MARCO DO CURSO' : 'EL MARCO DEL CURSO',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: context.acento,
            ),
          ),
          fila(isGl ? 'Área' : 'Área', l(normativa.area)),
          fila(isGl ? 'Encadre' : 'Encuadre', l(criterio.encadre)),
          fila(isGl ? 'Saber' : 'Saber', l(normativa.saber)),
          fila(isGl ? 'Horario' : 'Horario', l(criterio.horario)),
          fila(
            isGl ? 'Criterio' : 'Criterio',
            '${criterio.obx}${criterio.codigo == null ? '' : ' · ${criterio.codigo}'}: '
            '${l(criterio.criterio)}',
          ),
          const SizedBox(height: 8),
          Text(
            '${l(normativa.aviso)} (${criterio.cita})',
            key: const ValueKey('planificador_aviso_dog'),
            style: const TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// Un mes del plan: el área por su nombre oficial, el criterio, el centro de
/// interés de la unidad, la unidad del plan curricular y el núcleo.
class _MesDoPlan extends StatelessWidget {
  final int numero;
  final UnidadeDoMes unidade;
  final List<PezaDaUnidade> nucleo;
  final UnidadeCurricular? plan;
  final LocalizedString? area;
  final CriterioDoCurso? criterio;
  final AppLanguage language;

  const _MesDoPlan({
    required this.numero,
    required this.unidade,
    required this.nucleo,
    required this.plan,
    required this.area,
    required this.criterio,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    String l(LocalizedString s) => s.resolve(language);
    const corpo =
        TextStyle(fontSize: 14, color: AppTheme.textPrimary, height: 1.35);
    Widget fila(String rotulo, String texto) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(
                text: '$rotulo: ',
                style: TextStyle(
                    fontWeight: FontWeight.w800, color: context.acento),
              ),
              TextSpan(text: texto),
            ]),
            style: corpo,
          ),
        );
    return Card(
      key: ValueKey('planificador_mes_${unidade.id}'),
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: context.acentoTint,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'MES $numero · ${l(nomeDoMes[unidade.mesCalendario]!).toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: context.acento,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l(unidade.centroInteres),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (area case final a?) fila(isGl ? 'Área' : 'Área', l(a)),
            if (criterio case final c?)
              fila(
                isGl ? 'Criterio' : 'Criterio',
                '${c.obx}${c.codigo == null ? '' : ' · ${c.codigo}'}',
              ),
            if (plan case final p?)
              fila(isGl ? 'Plan curricular' : 'Plan curricular', l(p.titulo)),
            if (nucleo.isNotEmpty)
              fila(isGl ? 'Núcleo' : 'Núcleo',
                  [for (final n in nucleo) n.en].join(' · ')),
          ],
        ),
      ),
    );
  }
}
