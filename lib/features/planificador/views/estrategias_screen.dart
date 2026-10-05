import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/estrategia_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../core/widgets/cabecera.dart';
import '../../docentes/nomes_docentes.dart';

/// Catálogo de estratexias pedagóxicas de aula.
///
/// **Cuidado con la palabra «evidencia».** Este catálogo llegó rotulado como
/// «baseadas en evidencia científica» y con un apartado titulado «Base
/// Neurobiolóxica» —el hipocampo, la amígdala, la dopamina— sin UNA sola
/// referencia. Ahora «Por que funciona» dice lo que la docente hace y por qué,
/// en lenguaje de aula, y lleva su fuente solo donde hay una comprobada. Sin
/// cita no se dice «evidencia», y esta app no tiene finalidad sanitaria.
class EstrategiasScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const EstrategiasScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<EstrategiasScreen> createState() => _EstrategiasScreenState();
}

class _EstrategiasScreenState extends State<EstrategiasScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language = widget.initialLanguage;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant EstrategiasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

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
    final lang = _language;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.estratexiasCabeceira.resolve(lang),
        language: _language,
        onLanguageChanged: _cambiarLingua,
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
                                color: context.acentoTint,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.psychology_rounded,
                                  color: context.acento, size: 24),
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
                          icon: Icons.biotech_rounded,
                          title: lang == AppLanguage.gl
                              ? 'Por que funciona'
                              : 'Por qué funciona',
                          content: est.porQueFunciona.resolve(lang),
                          color: context.acento,
                        ),
                        if (est.fonte case final fonte?) ...[
                          const SizedBox(height: 6),
                          Text(
                            '${lang == AppLanguage.gl ? 'Fonte' : 'Fuente'}: ${fonte.resolve(lang)}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textSecondary,
                              height: 1.35,
                            ),
                          ),
                        ],

                        const SizedBox(height: 10),

                        // Como aplicar na aula
                        _buildSection(
                          icon: Icons.school_rounded,
                          title: lang == AppLanguage.gl
                              ? 'Como aplicar na aula'
                              : 'Cómo aplicar en el aula',
                          content: est.comoAplicarNaAula.resolve(lang),
                          color: context.acento,
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
                              const Icon(Icons.forum_rounded,
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
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppTheme.errorInk, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Evitar: ${est.erroComunAEvitar.resolve(lang)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.errorInk,
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
