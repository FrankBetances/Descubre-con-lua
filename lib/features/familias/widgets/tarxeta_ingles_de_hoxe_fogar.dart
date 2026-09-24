import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../docentes/widgets/hoxe_na_aula.dart';

/// O inglés de hoxe na casa: as MESMAS palabras que a escola ese día, co
/// xesto para facelo na casa.
///
/// Antes esta tarxeta dicía «5 palabras novas / día» sen ensinar ningunha, e
/// atribuía o ritmo ao CDI MacArthur-Bates e a Rescorla, que describen o
/// vocabulario temperán pero non prescriben un ritmo de ensino. Agora ensina
/// as palabras do día, sacadas do curso, e o número sae do modelo.
class TarxetaInglesDeHoxeFogar extends StatelessWidget {
  final ProgramaTpr programa;

  /// O curso da crianza (`curso_0_2` … `curso_5_6`): as palabras de hoxe son
  /// as dese curso, as mesmas que ve a escola nese grupo.
  final String cursoId;
  final ValueChanged<String> onCambiarCurso;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final VoidCallback onVerXogos;

  /// Para os tests: o día que se quere ver. Por defecto, hoxe.
  final DateTime? agora;

  const TarxetaInglesDeHoxeFogar({
    super.key,
    required this.programa,
    required this.cursoId,
    required this.onCambiarCurso,
    required this.language,
    required this.onVerXogos,
    this.audioService,
    this.agora,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final hoxe = diaDoCursoParaHoxe(agora: agora);
    final d = hoxe.dia;
    final curso = programa.curso(cursoId);
    final plan = curso?.planDoDia(d.mesCalendario, d.semana, d.dia);
    if (curso == null || plan == null) return const SizedBox.shrink();
    final ritmo = curso.modelo.ritmoDiario;
    final porSemana = ritmo * WeeklyTprScheduler.diasConPalabrasNovas;

    return Container(
      key: const Key('tarxeta_ingles_de_hoxe_fogar'),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF5FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9D8FD), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Wrap e non Row: co texto grande do sistema a etiqueta e o ritmo
          // non collen nunha liña, e parten en dúas en vez de cortarse.
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF805AD5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'RITMO DIARIO TPR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              Text(
                isGl
                    ? '$ritmo palabras novas ao día · $porSemana á semana'
                    : '$ritmo palabras nuevas al día · $porSemana a la semana',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF553C9A),
                ),
              ),
            ],
          ),
          // En xullo e agosto non hai curso: sen este aviso, a familia lería
          // as palabras do primeiro día como se fosen as de hoxe.
          if (hoxe.prevista) ...[
            const SizedBox(height: 8),
            Text(
              isGl
                  ? 'O curso empeza en setembro: estas son as do primeiro día.'
                  : 'El curso empieza en septiembre: estas son las del primer día.',
              key: const Key('ingles_fogar_prevista'),
              style: const TextStyle(
                fontSize: 12.5,
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 10),
          SelectorDeCursoTpr(
            programa: programa,
            seleccionado: cursoId,
            language: language,
            prefixoClave: 'fogar_curso',
            onCambiar: onCambiarCurso,
          ),
          const SizedBox(height: 10),
          PalabrasDoDia(
            plan: plan,
            modeloDoDia: curso.modelo.dia(d.dia),
            language: language,
            audioService: audioService,
            paraFogar: true,
            detalle: false,
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              key: const Key('boton_xogos_fogar_desde_ingles'),
              onPressed: onVerXogos,
              icon: const Icon(Icons.sports_gymnastics_rounded,
                  size: 16, color: Color(0xFF6B46C1)),
              label: Text(
                isGl
                    ? 'Ver xogos e dinámicas de 3 min'
                    : 'Ver juegos y dinámicas de 3 min',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B46C1),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD6BCFA)),
                backgroundColor: Colors.white,
                minimumSize: const Size(0, AppTheme.touchMin),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
