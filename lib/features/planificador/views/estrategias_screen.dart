import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/estrategia_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Catálogo de Estratexias Pedagóxicas baseadas en evidencia científica.
class EstrategiasScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  const EstrategiasScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
  });

  @override
  State<EstrategiasScreen> createState() => _EstrategiasScreenState();
}

class _EstrategiasScreenState extends State<EstrategiasScreen> {
  List<EstrategiaPedagogica> _estrategias = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEstrategias();
  }

  Future<void> _loadEstrategias() async {
    setState(() => _isLoading = true);
    final results = await widget.repository.loadEstrategias();
    if (mounted) {
      setState(() {
        _estrategias = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.initialLanguage;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Estratexias Pedagóxicas'
              : 'Estrategias Pedagógicas',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _estrategias.length,
              itemBuilder: (context, index) {
                final est = _estrategias[index];
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
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.psychology,
                                  color: AppTheme.primaryDark, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    est.nome.resolve(lang),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  Text(
                                    est.subtitulo.resolve(lang),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Base Neurobiolóxica
                        _buildSection(
                          icon: Icons.biotech,
                          title: lang == AppLanguage.gl
                              ? 'Base Neurobiolóxica'
                              : 'Base Neurobiológica',
                          content: est.baseNeurobioloxica.resolve(lang),
                          color: Colors.teal.shade800,
                        ),

                        const SizedBox(height: 10),

                        // Como aplicar na aula
                        _buildSection(
                          icon: Icons.school,
                          title: lang == AppLanguage.gl
                              ? 'Como Aplicar na Aula'
                              : 'Cómo Aplicar en el Aula',
                          content: est.comoAplicarNaAula.resolve(lang),
                          color: AppTheme.primaryInk,
                        ),

                        const SizedBox(height: 10),

                        // Diálogo exemplo
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.forum, color: Colors.amber, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  est.exemploDialogoAula.resolve(lang),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.amber.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Erro común
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.red.shade100),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber,
                                  color: Colors.red.shade700, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Evitar: ${est.erroComunAEvitar.resolve(lang)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade900,
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
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 13,
            color: AppTheme.textPrimary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
