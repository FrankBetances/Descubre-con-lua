import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';

/// El día del curso que toca: el de hoy, o el primero del curso en julio y
/// agosto, que no son lectivos y en los que se prepara septiembre.
({DiaDoCursoTpr dia, bool prevista}) diaDoCursoParaHoxe({DateTime? agora}) {
  final hoxe = CursoTpr.hoxe(agora: agora);
  if (hoxe != null) return (dia: hoxe, prevista: false);
  return (dia: (mesCalendario: 9, semana: 1, dia: 1), prevista: true);
}

/// «Hoxe na aula»: las palabras inglesas del día que toca, en el curso del
/// grupo que se elige arriba.
///
/// Antes esta tarjeta llevaba las palabras escritas en el widget, las mismas
/// veinte todas las semanas del año y para todas las edades. Ahora el día sale
/// de la fecha —con la misma regla que la asamblea del día— y las palabras, del
/// curso del grupo en `assets/content/tpr/`: las de 0-2 no son las de 5-6.
class TarxetaHoxeNaAula extends StatelessWidget {
  final ProgramaTpr programa;

  /// El curso del grupo elegido (`curso_0_2` … `curso_5_6`).
  final String cursoId;
  final ValueChanged<String> onCambiarCurso;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// Para los tests: el día que se quiere ver. Por defecto, hoy.
  final DateTime? agora;

  /// Abre la asamblea de ESE día para el grupo de ESE curso.
  final void Function(DiaDoCursoTpr dia, String cursoId) onIniciarAsemblea;
  final VoidCallback onVerPalabras;

  const TarxetaHoxeNaAula({
    super.key,
    required this.programa,
    required this.cursoId,
    required this.onCambiarCurso,
    required this.language,
    required this.onIniciarAsemblea,
    required this.onVerPalabras,
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
    final mes = nomeDoMes[d.mesCalendario]!.resolve(language);

    return Card(
      key: const Key('tarxeta_hoxe_na_aula'),
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.primaryVigoBlue, width: 1.5),
      ),
      color: AppTheme.primaryTint,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTheme.primaryLight,
                  child: Icon(Icons.bolt_rounded,
                      color: AppTheme.primaryInk, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hoxe.prevista
                            ? (isGl
                                ? 'O PRIMEIRO DÍA DO CURSO · RITMO TPR'
                                : 'EL PRIMER DÍA DEL CURSO · RITMO TPR')
                            : (isGl
                                ? 'HOXE NA AULA · RITMO TPR'
                                : 'HOY EN EL AULA · RITMO TPR'),
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryInk,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        '$mes · semana ${d.semana} · '
                        '${curso.etiqueta.resolve(language)}',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            SelectorDeCursoTpr(
              programa: programa,
              seleccionado: cursoId,
              language: language,
              prefixoClave: 'hoxe_curso',
              onCambiar: onCambiarCurso,
            ),
            const SizedBox(height: 10),
            PalabrasDoDia(
              plan: plan,
              modeloDoDia: curso.modelo.dia(d.dia),
              semana: curso.semana(d.mesCalendario, d.semana),
              language: language,
              audioService: audioService,
              detalle: false,
            ),
            const SizedBox(height: 12),
            // Wrap y no Row: con el texto grande del sistema los dos botones no
            // caben en una fila y se parten en dos, en vez de encoger la letra.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  key: const Key('boton_asemblea_de_hoxe'),
                  onPressed: () => onIniciarAsemblea(d, cursoId),
                  icon: const Icon(Icons.play_arrow_rounded, size: 18),
                  label: Text(
                    isGl
                        ? 'Iniciar asemblea de hoxe'
                        : 'Iniciar asamblea de hoy',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryVigoBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, AppTheme.touchMin),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                OutlinedButton(
                  key: const Key('boton_ver_palabras_do_curso'),
                  onPressed: onVerPalabras,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryVigoBlue),
                    foregroundColor: AppTheme.primaryInk,
                    minimumSize: const Size(0, AppTheme.touchMin),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    isGl
                        ? 'Ver as ${formatarMiles(programa.totalPalabras)} palabras'
                        : 'Ver las ${formatarMiles(programa.totalPalabras)} palabras',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 4000 → «4.000», como se escriben los miles en gallego y en castellano.
String formatarMiles(int n) {
  final s = '$n';
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('.');
    out.write(s[i]);
  }
  return out.toString();
}

/// Los números del trayecto, CONTADOS en el contenido: si alguien añade o
/// quita una palabra, esta hoja lo dice sin que nadie la toque.
///
/// Sustituye a una hoja con los números escritos a mano —800, 280, 200…— y con
/// la distribución atribuida al CDI MacArthur-Bates y a Rescorla. El orden de
/// las categorías sí se inspira en el vocabulario temprano que describen esos
/// inventarios; los porcentajes y el ritmo son del programa, y la nota de
/// fuentes, que sale del contenido, lo dice así.
class ProxeccionDoCurso extends StatelessWidget {
  final ProgramaTpr programa;
  final AppLanguage language;
  final ScrollController? scrollController;
  final VoidCallback onPechar;

  const ProxeccionDoCurso({
    super.key,
    required this.programa,
    required this.language,
    required this.onPechar,
    this.scrollController,
  });

  static const List<Color> _cores = [
    Color(0xFF3182CE),
    Color(0xFF38A169),
    Color(0xFFDD6B20),
    Color(0xFF805AD5),
    Color(0xFFD69E2E),
  ];

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final total = programa.totalPalabras;
    final porCategoria = programa.porCategoria;
    final ritmo = programa.modelo.ritmoDiario;
    const dias = WeeklyTprScheduler.diasConPalabrasNovas;
    final porSemana = ritmo * dias;
    final primeiro = programa.cursos.first;
    final semanasPorMes = primeiro.meses.first.semanas.length;
    final porMes = primeiro.meses.first.totalPalabras;
    final meses = primeiro.meses.length;
    final porCurso = primeiro.totalPalabras;
    final cursos = programa.cursos.length;

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.all(20),
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          isGl
              ? 'PROXECCIÓN LÉXICA · ${formatarMiles(total)} PALABRAS DE 0 A 6 ANOS'
              : 'PROYECCIÓN LÉXICA · ${formatarMiles(total)} PALABRAS DE 0 A 6 AÑOS',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryInk,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          isGl
              ? 'Cinco palabras novas cada día, $cursos cursos'
              : 'Cinco palabras nuevas cada día, $cursos cursos',
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.pageBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGl ? 'O traxecto en números' : 'El trayecto en números',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryInk,
                ),
              ),
              const SizedBox(height: 8),
              _Fila(
                isGl ? 'Luns a xoves:' : 'Lunes a jueves:',
                isGl
                    ? '$ritmo palabras novas ao día × $dias días = $porSemana por semana'
                    : '$ritmo palabras nuevas al día × $dias días = $porSemana por semana',
              ),
              _Fila(
                isGl ? 'Venres:' : 'Viernes:',
                isGl
                    ? 'ningunha nova; reto coas $porSemana da semana'
                    : 'ninguna nueva; reto con las $porSemana de la semana',
              ),
              _Fila(
                'Cada mes:',
                '$porSemana × $semanasPorMes semanas = $porMes',
              ),
              _Fila(
                isGl ? 'Cada curso:' : 'Cada curso:',
                '$porMes × $meses meses = $porCurso palabras',
              ),
              _Fila(
                isGl ? 'De 0 a 6 anos:' : 'De 0 a 6 años:',
                isGl
                    ? '$porCurso × $cursos cursos = ${formatarMiles(total)} palabras, sen repetir ningunha'
                    : '$porCurso × $cursos cursos = ${formatarMiles(total)} palabras, sin repetir ninguna',
                destacado: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          isGl ? 'OS CINCO CURSOS' : 'LOS CINCO CURSOS',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 8),
        for (final c in programa.cursos)
          _Fila(
            c.etiqueta.resolve(language),
            isGl
                ? '${c.totalPalabras} palabras · trimestres '
                    '${c.palabrasEnMeses(const [9, 10, 11, 12])} · '
                    '${c.palabrasEnMeses(const [1, 2, 3])} · '
                    '${c.palabrasEnMeses(const [4, 5, 6])}'
                : '${c.totalPalabras} palabras · trimestres '
                    '${c.palabrasEnMeses(const [9, 10, 11, 12])} · '
                    '${c.palabrasEnMeses(const [1, 2, 3])} · '
                    '${c.palabrasEnMeses(const [4, 5, 6])}',
          ),
        const SizedBox(height: 18),
        const Text(
          'REPARTO POR CATEGORÍAS',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppTheme.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, c) in programa.modelo.categorias.indexed) ...[
          _Categoria(
            titulo: c.nome.resolve(language),
            detalle: '${formatarMiles(porCategoria[c.clave] ?? 0)} palabras · '
                '${c.descricion.resolve(language)}',
            cor: _cores[i % _cores.length],
            porcentaxe: total == 0 ? 0 : (porCategoria[c.clave] ?? 0) / total,
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        Text(
          programa.modelo.fontes.resolve(language),
          key: const Key('proxeccion_fontes'),
          style: const TextStyle(
            fontSize: 11.5,
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPechar,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryVigoBlue,
              foregroundColor: Colors.white,
              minimumSize: const Size(0, AppTheme.touchMin),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              isGl ? 'Pechar' : 'Cerrar',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

class _Fila extends StatelessWidget {
  final String rotulo;
  final String valor;
  final bool destacado;

  const _Fila(this.rotulo, this.valor, {this.destacado = false});

  @override
  Widget build(BuildContext context) {
    final cor = destacado ? AppTheme.primaryInk : AppTheme.textSecondary;
    // Un solo texto con el rótulo en negrita, no una fila de dos: a escala de
    // texto grande el rótulo y el valor no caben lado a lado.
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text.rich(
        TextSpan(children: [
          TextSpan(
            text: '$rotulo ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: destacado ? AppTheme.primaryInk : AppTheme.textPrimary,
            ),
          ),
          TextSpan(text: valor),
        ]),
        style: TextStyle(
          fontSize: 12,
          fontWeight: destacado ? FontWeight.w800 : FontWeight.w500,
          color: cor,
          height: 1.35,
        ),
      ),
    );
  }
}

class _Categoria extends StatelessWidget {
  final String titulo;
  final String detalle;
  final Color cor;
  final double porcentaxe;

  const _Categoria({
    required this.titulo,
    required this.detalle,
    required this.cor,
    required this.porcentaxe,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                titulo,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: cor,
                ),
              ),
            ),
            Text(
              '${(porcentaxe * 100).round()} %',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaxe,
            backgroundColor: cor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(cor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detalle,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}
