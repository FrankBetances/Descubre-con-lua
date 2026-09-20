import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/repositories/content_repository.dart';
import 'dinamicas_screen.dart';
import 'estrategias_screen.dart';

/// Planificador Curricular Docente para os 50 meses dos 5 cursos de Educación Infantil.
class PlanificadorScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  const PlanificadorScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
  });

  @override
  State<PlanificadorScreen> createState() => _PlanificadorScreenState();
}

class _PlanificadorScreenState extends State<PlanificadorScreen> {
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Planificador Curricular'
              : 'Planificador Curricular',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: AppTheme.primaryDark),
            tooltip: 'Estratexias',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EstrategiasScreen(
                    repository: widget.repository,
                    initialLanguage: _language,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.alarm, color: AppTheme.primaryDark),
            tooltip: 'Dinámicas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DinamicasScreen(
                    repository: widget.repository,
                    initialLanguage: _language,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Course Selector Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      selectedColor: AppTheme.primary,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      'MES ${mes.mesNumero} · ${mes.nombreMes.resolve(lang).toUpperCase()}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppTheme.primaryDark,
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
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Aula
                              _buildPill(
                                icon: Icons.school,
                                title: lang == AppLanguage.gl
                                    ? 'Actividade de Aula'
                                    : 'Actividad de Aula',
                                content: mes.actividadAula.resolve(lang),
                                color: AppTheme.primaryInk,
                              ),
                              const SizedBox(height: 8),

                              // Fogar
                              _buildPill(
                                icon: Icons.home,
                                title: lang == AppLanguage.gl
                                    ? 'Rutina no Fogar'
                                    : 'Rutina en el Hogar',
                                content: mes.actividadHogar.resolve(lang),
                                color: Colors.amber.shade900,
                              ),
                              const SizedBox(height: 8),

                              // English
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.indigo.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.language,
                                        color: Colors.indigo, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'L3: "${mes.ingles.frase}" (TPR: ${mes.ingles.tpr.join(", ")})',
                                        style: TextStyle(
                                          color: Colors.indigo.shade800,
                                          fontSize: 12,
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
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textPrimary, height: 1.3),
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
