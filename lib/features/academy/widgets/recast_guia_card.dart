import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';

/// Tarxeta pedagóxica comparativa de Modelado Indirecto (Recast).
///
/// Ilustra de xeito visual e amigable a diferenza entre:
/// - Corrección frontal punitiva (xera bloqueo e ansiedade).
/// - Modelado indirecto afectivo con movemento (recast) sen esixir repetición.
///
/// Incorpora tamén o principio «Time and Place» (3 a 5 minutos) e os 5 segundos
/// de agarda activa para respectar o tempo de procesamento da crianza.
class RecastGuiaCard extends StatelessWidget {
  final AppLanguage language;
  final List<PautaRecast>? pautas;

  const RecastGuiaCard({
    super.key,
    required this.language,
    this.pautas,
  });

  static const List<PautaRecast> _pautasPorDefecto = [
    PautaRecast(
      expresionMenor: LocalizedString(
        gl: '«Abrigo chan!»',
        es: '«¡Abrigo suelo!»',
      ),
      modeladoIndirecto: LocalizedString(
        gl: '«Si! O abrigo na percha: Up on the hook, zip!» (Acompañar co xesto de colgar e subir a cremalleira sen pedir que repita).',
        es: '«¡Sí! El abrigo en la percha: Up on the hook, zip!» (Acompañar con el gesto de colgar y subir la cremallera sin pedir que repita).',
      ),
      consejoEvitar: LocalizedString(
        gl: '«Non se di así! Mal, tes que dicir: mamá, colle o abrigo...» (Convértese en exame: a crianza cala e deixa de probar).',
        es: '«¡No se dice así! Mal, tienes que decir: mamá, coge el abrigo...» (Se convierte en examen: el niño calla y deja de probar).',
      ),
    ),
    PautaRecast(
      expresionMenor: LocalizedString(
        gl: '«Babi gardar!»',
        es: '«¡Babi guardar!»',
      ),
      modeladoIndirecto: LocalizedString(
        gl: '«Moi ben! Dobramos o babi e ao cesto: Fold the smock and put it in the basket! Bravo!»',
        es: '«¡Muy bien! Doblamos el babi y al cesto: Fold the smock and put it in the basket! ¡Bravo!»',
      ),
      consejoEvitar: LocalizedString(
        gl: '«Como se di babi en inglés? Dimo antes de merendar!» (Os exames directos aumentan a presión e cortan o diálogo).',
        es: '«¿Cómo se dice babi en inglés? ¡Dímelo antes de merendar!» (Los exámenes directos aumentan la presión y cortan el diálogo).',
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final listaPautas =
        (pautas != null && pautas!.isNotEmpty) ? pautas! : _pautasPorDefecto;

    return Card(
      elevation: 0,
      color: AppTheme.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border, width: 1.5),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeceira da guía
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  ),
                  child: const Icon(
                    Icons.compare_arrows_rounded,
                    color: AppTheme.primaryInk,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl
                            ? 'MODELADO INDIRECTO (RECAST)'
                            : 'MODELADO INDIRECTO (RECAST)',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryInk,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isGl
                            ? 'Como responder na casa sen corrixir'
                            : 'Cómo responder en casa sin corregir',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pauta dos 5 segundos de agarda activa
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.primaryTint,
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                border: Border.all(color: AppTheme.borderActive),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    color: AppTheme.primaryDark,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isGl
                          ? 'Regra de Ouro: agarda 5 segundos antes de axudar. Dálle tempo a responder pola súa conta.'
                          : 'Regla de Oro: espera 5 segundos antes de ayudar. Dale tiempo a responder por su cuenta.',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Lista comparativa de Recast
            ...listaPautas.map((pauta) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.pageBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expresión da crianza
                    Row(
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isGl ? 'A crianza di:' : 'La criatura dice:',
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pauta.expresionMenor.resolve(language),
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // O que debemos evitar
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorBg,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                        border: Border.all(
                          color: AppTheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.cancel_outlined,
                            color: AppTheme.error,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isGl
                                      ? 'Evitar (corrección frontal):'
                                      : 'Evitar (corrección frontal):',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.error,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pauta.consejoEvitar.resolve(language),
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    color: AppTheme.textPrimary,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // O modelado indirecto recomendado
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successBg,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                        border: Border.all(
                          color: AppTheme.success.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppTheme.success,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isGl
                                      ? 'Acompañar con Recast (Agarimo e movemento):'
                                      : 'Acompañar con Recast (Afecto y movimiento):',
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0D7E57),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  pauta.modeladoIndirecto.resolve(language),
                                  style: const TextStyle(
                                    fontFamily: AppTheme.fontFamily,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Principio Time and Place
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.home_outlined,
                    color: AppTheme.primaryDark,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isGl
                          ? 'Principio «Time and Place» (3 a 5 min): Establecer un momento concreto e acolledor do día (ex: colgar o abrigo na entrada) sen converter a casa nunha aula de exame.'
                          : 'Principio «Time and Place» (3 a 5 min): Establecer un momento concreto y acogedor del día (ej: colgar el abrigo en el recibidor) sin convertir el hogar en un aula de examen.',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        height: 1.35,
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
  }
}
