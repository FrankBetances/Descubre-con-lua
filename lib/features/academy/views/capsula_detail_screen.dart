import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/capsula_model.dart';
import '../widgets/seccion_capsula_widget.dart';
import '../widgets/selector_idioma_widget.dart';

/// Screen displaying a single Academy micro-learning capsule for families.
///
/// Implements the 4 canonical sections:
/// 1. Idea clave
/// 2. Por qué importa / Por que importa
/// 3. Qué hacer en casa / Que facer na casa
/// 4. Ejemplo cotidiano / Exemplo cotián
///
/// Plus formative reflection questions (`Afirmacion`), dynamic language toggle (`GL`/`ES`),
/// and large adult-first typography (body >= 16sp).
class CapsulaDetailScreen extends StatefulWidget {
  final Capsula capsula;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const CapsulaDetailScreen({
    super.key,
    required this.capsula,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<CapsulaDetailScreen> createState() => _CapsulaDetailScreenState();
}

class _CapsulaDetailScreenState extends State<CapsulaDetailScreen> {
  late AppLanguage _language;
  final Map<String, bool?> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final capsula = widget.capsula;
    final theme = Theme.of(context);
    final isGl = _language == AppLanguage.gl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGl ? 'Cápsula de crianza' : 'Cápsula de crianza',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Reading time & block badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryVigoBlue.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 16,
                        color: AppTheme.primaryVigoBlue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isGl
                            ? '${capsula.tiempoLecturaMinutos} min de lectura'
                            : '${capsula.tiempoLecturaMinutos} min de lectura',
                        style: const TextStyle(
                          color: AppTheme.primaryVigoBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  isGl ? 'Orientación familiar 0-3 anos' : 'Orientación familiar 0-3 años',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6B7280),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),

            // Capsule title
            Text(
              capsula.titulo.resolve(_language),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryVigoBlue,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8.0),

            // Capsule subtitle
            Text(
              capsula.subtitulo.resolve(_language),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: 17.0,
                color: const Color(0xFF4A5568),
                fontStyle: FontStyle.italic,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 24.0),

            // 1. Idea clave
            SeccionCapsulaWidget(
              tipo: TipoSeccionCapsula.ideaClave,
              titulo: isGl ? '1. Idea clave' : '1. Idea clave',
              contenido: capsula.ideaClave.resolve(_language),
              accentColor: AppTheme.primaryVigoBlue,
            ),

            // 2. Por qué importa
            SeccionCapsulaWidget(
              tipo: TipoSeccionCapsula.porQueImporta,
              titulo: isGl ? '2. Por que importa' : '2. Por qué importa',
              contenido: capsula.porQueImporta.resolve(_language),
              accentColor: const Color(0xFF2C5E7A),
            ),

            // 3. Qué hacer en casa
            SeccionCapsulaWidget(
              tipo: TipoSeccionCapsula.queHacerEnCasa,
              titulo: isGl ? '3. Que facer na casa' : '3. Qué hacer en casa',
              contenido: capsula.queHacerEnCasa.resolve(_language),
              accentColor: AppTheme.calmSage,
            ),

            // 4. Ejemplo cotidiano
            SeccionCapsulaWidget(
              tipo: TipoSeccionCapsula.ejemploCotidiano,
              titulo: isGl ? '4. Exemplo cotián' : '4. Ejemplo cotidiano',
              contenido: capsula.ejemploCotidiano.resolve(_language),
              accentColor: AppTheme.accentTerracotta,
            ),

            const SizedBox(height: 12.0),

            // Formative reflection section
            if (capsula.afirmaciones.isNotEmpty) ...[
              _buildReflectionSection(context, capsula.afirmaciones, isGl),
              const SizedBox(height: 24.0),
            ],

            // Curricular & Normative framework card (Decreto 150/2022)
            _buildCurricularCard(context, capsula, isGl),
            const SizedBox(height: 32.0),
          ],
        ),
      ),
    );
  }

  Widget _buildReflectionSection(
    BuildContext context,
    List<Afirmacion> afirmaciones,
    bool isGl,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7EE),
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: const Color(0xFFDFD7BE),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: AppTheme.primaryVigoBlue,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isGl ? 'Reflexión para a familia' : 'Reflexión para la familia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryVigoBlue,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isGl
                ? 'Unha pequena pausa para pensar sobre o día a día na crianza.'
                : 'Una pequeña pausa para pensar sobre el día a día en la crianza.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4A5568),
              fontSize: 14.5,
            ),
          ),
          const SizedBox(height: 16.0),
          ...afirmaciones.asMap().entries.map((entry) {
            final idx = entry.key;
            final afirmacion = entry.value;
            final userChoice = _userAnswers[afirmacion.id];
            final hasAnswered = userChoice != null;

            return Container(
              margin: const EdgeInsets.only(bottom: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: const Color(0xFFE2DDD0),
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${idx + 1}. ${afirmacion.enunciado.resolve(_language)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSlate,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 14.0),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _userAnswers[afirmacion.id] = true;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: userChoice == true
                                ? AppTheme.primaryVigoBlue.withOpacity(0.12)
                                : Colors.transparent,
                            side: BorderSide(
                              color: userChoice == true
                                  ? AppTheme.primaryVigoBlue
                                  : const Color(0xFFB0B7BD),
                              width: userChoice == true ? 2.0 : 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            isGl ? 'Verdadeiro' : 'Verdadero',
                            style: TextStyle(
                              color: userChoice == true
                                  ? AppTheme.primaryVigoBlue
                                  : AppTheme.textSlate,
                              fontWeight: userChoice == true
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _userAnswers[afirmacion.id] = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: userChoice == false
                                ? AppTheme.primaryVigoBlue.withOpacity(0.12)
                                : Colors.transparent,
                            side: BorderSide(
                              color: userChoice == false
                                  ? AppTheme.primaryVigoBlue
                                  : const Color(0xFFB0B7BD),
                              width: userChoice == false ? 2.0 : 1.0,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          child: Text(
                            isGl ? 'Falso' : 'Falso',
                            style: TextStyle(
                              color: userChoice == false
                                  ? AppTheme.primaryVigoBlue
                                  : AppTheme.textSlate,
                              fontWeight: userChoice == false
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (hasAnswered) ...[
                    const SizedBox(height: 14.0),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: userChoice == afirmacion.esVerdadera
                            ? AppTheme.calmSage.withOpacity(0.15)
                            : AppTheme.accentTerracotta.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: userChoice == afirmacion.esVerdadera
                              ? AppTheme.calmSage
                              : AppTheme.accentTerracotta,
                          width: 1.0,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            userChoice == afirmacion.esVerdadera
                                ? Icons.check_circle_outline
                                : Icons.info_outline,
                            color: userChoice == afirmacion.esVerdadera
                                ? const Color(0xFF2E6E50)
                                : AppTheme.accentTerracotta,
                            size: 20,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              afirmacion.explicacion.resolve(_language),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16.0,
                                height: 1.5,
                                color: AppTheme.textSlate,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurricularCard(BuildContext context, Capsula capsula, bool isGl) {
    final theme = Theme.of(context);
    final curriculo = capsula.curriculo;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFE0E3E7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bookmark_border, color: AppTheme.primaryVigoBlue, size: 20),
              const SizedBox(width: 8),
              Text(
                isGl ? 'Marco curricular e referencia' : 'Marco curricular y referencia',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryVigoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${curriculo.normativa} · ${curriculo.etapa} · ${curriculo.ciclo}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF4A5568),
              fontWeight: FontWeight.w500,
            ),
          ),
          if (curriculo.areas.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6.0,
              runSpacing: 4.0,
              children: curriculo.areas.map((area) {
                return Chip(
                  label: Text(
                    area,
                    style: const TextStyle(fontSize: 11.5, color: AppTheme.primaryVigoBlue),
                  ),
                  backgroundColor: AppTheme.primaryVigoBlue.withOpacity(0.08),
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: BorderSide.none,
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
