import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/estrategia_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Catálogo de estratexias pedagóxicas de aula.
///
/// **Cuidado con la palabra «evidencia».** Este catálogo llegó rotulado como
/// «baseadas en evidencia científica» y con un apartado titulado «Base
/// Neurobiolóxica», y ni el modelo de datos ni el contenido traen UNA sola
/// referencia que sostenga eso. Son buenas prácticas de aula, que es mucho, y
/// se presentan como lo que son: sin cita no se dice «evidencia», y esta app
/// declara que no tiene finalidad sanitaria.
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
              itemCount: _estrategias.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.warningBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.star),
                      ),
                      child: Text(
                        lang == AppLanguage.gl
                            ? 'Son orientacións de práctica de aula, escritas para '
                                'a persoa adulta. Non son un protocolo clínico nin '
                                'substitúen a valoración dun profesional.'
                            : 'Son orientaciones de práctica de aula, escritas para '
                                'la persona adulta. No son un protocolo clínico ni '
                                'sustituyen la valoración de un profesional.',
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppTheme.warning,
                        ),
                      ),
                    ),
                  );
                }
                final est = _estrategias[index - 1];
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

                        // El porqué de la estrategia
                        _buildSection(
                          icon: Icons.biotech,
                          title: lang == AppLanguage.gl
                              ? 'Por que funciona'
                              : 'Por qué funciona',
                          content: est.baseNeurobioloxica.resolve(lang),
                          color: AppTheme.primaryInk,
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
                            color: AppTheme.warningBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.star),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.forum,
                                  color: AppTheme.warning, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  est.exemploDialogoAula.resolve(lang),
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

                        const SizedBox(height: 10),

                        // Erro común
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.errorBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.errorBg),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.warning_amber,
                                  color: AppTheme.error, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Evitar: ${est.erroComunAEvitar.resolve(lang)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.error,
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
