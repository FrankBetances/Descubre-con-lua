import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
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
  List<MesCurricular50> _meses = [];
  bool _isLoading = true;
  String _selectedCurso = 'curso_0_2';

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
    _loadCurriculo();
  }

  Future<void> _loadCurriculo() async {
    setState(() => _isLoading = true);
    final results = await widget.repository.loadCurriculo50Meses();
    if (mounted) {
      setState(() {
        _meses = results;
        _isLoading = false;
      });
    }
  }

  List<MesCurricular50> get _filteredMeses {
    return _meses.where((m) => m.cursoId == _selectedCurso).toList();
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

          // Monthly Cards List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredMeses.length,
                    itemBuilder: (context, index) {
                      final mes = _filteredMeses[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        elevation: 0.5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: context.acentoTint,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'MES ${mes.mesNumero} · ${mes.nombreMes.resolve(lang).toUpperCase()}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: context.acento,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${mes.minutosSugeridos} min/día',
                                    style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                mes.centroInteres.resolve(lang),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mes.objetivoPedagogico.resolve(lang),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Aula
                              _buildPill(
                                icon: Icons.school_rounded,
                                title: lang == AppLanguage.gl
                                    ? 'Actividade de Aula'
                                    : 'Actividad de Aula',
                                content: mes.actividadAula.resolve(lang),
                                color: context.acento,
                              ),
                              const SizedBox(height: 8),

                              // Fogar
                              _buildPill(
                                icon: Icons.home_rounded,
                                title: lang == AppLanguage.gl
                                    ? 'Rutina no Fogar'
                                    : 'Rutina en el Hogar',
                                content: mes.actividadHogar.resolve(lang),
                                color: AppTheme.warning,
                              ),
                              const SizedBox(height: 8),

                              // English
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: context.acentoTint,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.language_rounded,
                                        color: context.acento, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'L3: "${mes.ingles.frase}" (TPR: ${mes.ingles.tpr.join(", ")})',
                                        style: TextStyle(
                                          color: context.acento,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              style: const TextStyle(
                  fontSize: 14, color: AppTheme.textPrimary, height: 1.3),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(text: content),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
