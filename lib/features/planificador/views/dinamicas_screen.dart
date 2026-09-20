import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/dinamica_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Catálogo de Dinámicas de Aula organizadas por día de la semana y pulso BPM.
class DinamicasScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  const DinamicasScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
  });

  @override
  State<DinamicasScreen> createState() => _DinamicasScreenState();
}

class _DinamicasScreenState extends State<DinamicasScreen> {
  List<DinamicaPedagogica> _dinamicas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDinamicas();
  }

  Future<void> _loadDinamicas() async {
    setState(() => _isLoading = true);
    final results = await widget.repository.loadDinamicas();
    if (mounted) {
      setState(() {
        _dinamicas = results;
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
          lang == AppLanguage.gl ? 'Dinámicas de Aula' : 'Dinámicas de Aula',
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
              itemCount: _dinamicas.length,
              itemBuilder: (context, index) {
                final din = _dinamicas[index];
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                din.diaSemana.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${din.duracionMinutos} min · ${din.ritmoBpm} BPM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.blue.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          din.titulo.resolve(lang),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          din.subtitulo.resolve(lang),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Obxectivo
                        _buildSection(
                          title:
                              lang == AppLanguage.gl ? 'Obxectivo' : 'Objetivo',
                          content: din.obxectivo.resolve(lang),
                          color: AppTheme.primaryInk,
                        ),

                        const SizedBox(height: 10),

                        // Procedemento
                        _buildSection(
                          title: lang == AppLanguage.gl
                              ? 'Procedemento Paso a Paso'
                              : 'Procedimiento Paso a Paso',
                          content: din.procedementoPasoAPaso.resolve(lang),
                          color: Colors.teal.shade800,
                        ),

                        const SizedBox(height: 10),

                        // Material
                        _buildSection(
                          title: lang == AppLanguage.gl
                              ? 'Material Sensorial'
                              : 'Material Sensorial',
                          content: din.materialSensorial.resolve(lang),
                          color: Colors.brown.shade700,
                        ),

                        const SizedBox(height: 12),

                        // Frase docente
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
                              const Icon(Icons.record_voice_over,
                                  color: Colors.amber, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  din.fraseDocente.resolve(lang),
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
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
            color: color,
          ),
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
