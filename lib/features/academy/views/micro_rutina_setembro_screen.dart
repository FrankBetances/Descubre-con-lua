import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../widgets/academy_header.dart';
import '../widgets/recast_guia_card.dart';
import '../widgets/selector_idioma_widget.dart';
import '../../../data/models/curricular_model.dart';

/// Pantalla da Micro-Rutina do Fogar de Setembro para o Segundo Ciclo (3-6 anos).
///
/// Principio pedagóxico:
/// - «Time and Place» (3 a 5 minutos ao día): nicho cotián de acollida ao chegar da escola.
/// - Modelado indirecto (recast) sen avaliación frontal nin reprobacións.
/// - Cero exposición a pantallas para a crianza.
class MicroRutinaSetembroScreen extends StatefulWidget {
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// El alineamiento curricular de la cápsula a la que acompaña esta
  /// micro-rutina. Estaba escrito a mano en el widget y contradecía al JSON
  /// —decía CA1.2 donde el contenido dice CA1.1—, que es justo lo que la regla
  /// de «contenido en JSON, nunca en los widgets» existe para evitar. Si no
  /// llega, el bloque no se pinta: mejor sin códigos que con los equivocados.
  final CurricularReference? curriculo;

  const MicroRutinaSetembroScreen({
    super.key,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.curriculo,
  });

  @override
  State<MicroRutinaSetembroScreen> createState() =>
      _MicroRutinaSetembroScreenState();
}

class _MicroRutinaSetembroScreenState extends State<MicroRutinaSetembroScreen> {
  late AppLanguage _language;

  static const _kicker = LocalizedString(
    gl: 'SEGUNDO CICLO (3-6 ANOS) · FOGAR',
    es: 'SEGUNDO CICLO (3-6 AÑOS) · HOGAR',
  );

  static const _titulo = LocalizedString(
    gl: 'Acollida na escola e linguas na casa: o principio de tempo e lugar',
    es: 'Acogida en la escuela y lenguas en casa: el principio de tiempo y lugar',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Como acompañar o Segundo Ciclo con micro-rutinas diarias de 3-5 minutos e modelado indirecto (recast).',
    es: 'Cómo acompañar el Segundo Ciclo con micro-rutinas diarias de 3-5 minutos y modelado indirecto (recast).',
  );

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

  static const _nombresArea = {
    'area_1_crecemento_harmonia': (
      'Área 1: Crecemento en harmonía',
      'Área 1: Crecimiento en armonía'
    ),
    'area_2_descubrimento_contorna': (
      'Área 2: Descubrimento e exploración da contorna',
      'Área 2: Descubrimiento y exploración del entorno'
    ),
    'area_3_comunicacion_representacion': (
      'Área 3: Comunicación e representación da realidade',
      'Área 3: Comunicación y representación de la realidad'
    ),
  };

  /// Las áreas y los criterios, tal y como los declara el JSON de la cápsula.
  String _lineasCurriculares(bool isGl) {
    final c = widget.curriculo!;
    final lineas = c.areas.map((slug) {
      final nombres = _nombresArea[slug];
      return '• ${nombres == null ? slug : (isGl ? nombres.$1 : nombres.$2)}.';
    }).toList();
    if (c.criteriosEvaluacion.isNotEmpty) {
      lineas.add(
          '• ${isGl ? 'Criterios de avaliación' : 'Criterios de evaluación'}: '
          '${c.criteriosEvaluacion.join(', ')}.');
    }
    return lineas.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGl ? 'Micro-Rutina · Setembro' : 'Micro-Rutina · Septiembre',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceMd),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      body: PaxinaSenScroll(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeceira gráfica Academy
              AcademyHeader(
                kicker: _kicker.resolve(_language),
                titulo: _titulo.resolve(_language),
                subtitulo: _subtitulo.resolve(_language),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceLg,
                  AppTheme.spaceXl,
                  AppTheme.spaceLg,
                  AppTheme.spaceXxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nicho temporal e momento do día
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.card,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: AppTheme.border, width: 1.5),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusField,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.hourglass_top_rounded,
                                      size: 16,
                                      color: AppTheme.primaryInk,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '3-5 MINUTOS',
                                      style: TextStyle(
                                        fontFamily: AppTheme.fontFamily,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.primaryInk,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(
                                    AppTheme.radiusField,
                                  ),
                                ),
                                child: Text(
                                  isGl
                                      ? 'Ao chegar da escola'
                                      : 'Al llegar de la escuela',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1D4ED8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Center(
                            child: LaminaEscena(clave: 'abrigo', ancho: 120),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            isGl
                                ? 'A Escena Cotiá: «The Magic Coat Hook»'
                                : 'La Escena Cotidiana: «The Magic Coat Hook»',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isGl
                                ? 'No recibidor da casa: a crianza descalza e quita a chaqueta con calma. En vez de facer preguntas directas ou pedir traducións («Como se di abrigo?»), acompañamos o movemento con ritmo e modelado: «Coat off, hang it up! Moi ben, que acolledora queda a entrada!»'
                                : 'En el recibidor de casa: el menor se descalza y se quita la chaqueta con calma. En lugar de hacer preguntas directas o pedir traducciones («¿Cómo se dice abrigo?»), acompañamos el movimiento con ritmo y modelado: «Coat off, hang it up! ¡Muy bien, qué acogedora queda la entrada!»',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: AppTheme.textSecondary,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tarxeta interactiva de pautas Recast
                    RecastGuiaCard(language: _language),
                    const SizedBox(height: 20),

                    // Aliñamento Curricular e Seguridade Familiar. Sin el JSON de la
                    // cápsula delante no se pinta: los códigos no se adivinan.
                    if (widget.curriculo != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusCard),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.school_outlined,
                                  color: AppTheme.primaryInk,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                    child: Text(
                                  isGl
                                      ? 'Aliñamento Curricular (Decreto 150/2022)'
                                      : 'Alineamiento Curricular (Decreto 150/2022)',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.primaryInk,
                                  ),
                                )),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _lineasCurriculares(isGl),
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
