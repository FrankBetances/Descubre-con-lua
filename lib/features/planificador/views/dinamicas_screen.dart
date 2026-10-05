import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dinamica_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../core/widgets/cabecera.dart';
import '../../docentes/nomes_docentes.dart';

/// Catálogo de Dinámicas de Aula organizadas por día de la semana y pulso BPM.
class DinamicasScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const DinamicasScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<DinamicasScreen> createState() => _DinamicasScreenState();
}

class _DinamicasScreenState extends State<DinamicasScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language = widget.initialLanguage;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant DinamicasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

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
    final lang = _language;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.dinamicas.resolve(lang),
        language: _language,
        onLanguageChanged: _cambiarLingua,
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
                                color: context.acentoTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                din.diaSemana.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: context.acento,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: context.acentoTint,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${din.duracionMinutos} min · ${din.ritmoBpm} BPM',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: context.acento,
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
                          color: context.acento,
                        ),

                        const SizedBox(height: 10),

                        // Procedemento
                        _buildSection(
                          title: lang == AppLanguage.gl
                              ? 'Procedemento paso a paso'
                              : 'Procedimiento paso a paso',
                          content: din.procedementoPasoAPaso.resolve(lang),
                          color: context.acento,
                        ),

                        const SizedBox(height: 10),

                        // Material
                        _buildSection(
                          title: lang == AppLanguage.gl
                              ? 'Material Sensorial'
                              : 'Material Sensorial',
                          content: din.materialSensorial.resolve(lang),
                          color: AppTheme.textSecondary,
                        ),

                        const SizedBox(height: 12),

                        // Frase docente
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.warningBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.star),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.record_voice_over_rounded,
                                  color: AppTheme.warning, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  din.fraseDocente.resolve(lang),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: AppTheme.warning,
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
