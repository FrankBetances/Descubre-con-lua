import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';

/// Las palabras inglesas de UN día del curso: las nuevas y las que se repasan.
///
/// Es la misma pieza en el portal de la docente, en el calendario del aula, en
/// el de casa y en el portal de las familias. Si cada pantalla pintara el día a
/// su manera, la docente y la familia podrían leer palabras distintas para el
/// mismo martes, que es justo lo que el calendario existe para evitar.
///
/// Todo sale del contenido (`assets/content/tpr/`): las palabras, su
/// significado, su gesto y lo que se hace ese día. Aquí solo hay rótulos.
class PalabrasDoDia extends StatelessWidget {
  final DailyTprPlan plan;

  /// Lo que se hace ese día. Sin él se pintan las palabras y nada más.
  final DiaDoModeloTpr? modeloDoDia;

  /// La semana, para decir su tema. Opcional.
  final SemanaTpr? semana;

  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// La dinámica de casa en vez de la del aula.
  final bool paraFogar;

  /// Cada palabra nueva con su significado y su gesto. Sin esto, solo las
  /// pastillas: es lo que cabe en una tarjeta de portada.
  final bool detalle;

  const PalabrasDoDia({
    super.key,
    required this.plan,
    required this.language,
    this.modeloDoDia,
    this.semana,
    this.audioService,
    this.paraFogar = false,
    this.detalle = true,
  });

  static const List<LocalizedString> nomesDosDias = [
    LocalizedString(gl: 'Luns', es: 'Lunes'),
    LocalizedString(gl: 'Martes', es: 'Martes'),
    LocalizedString(gl: 'Mércores', es: 'Miércoles'),
    LocalizedString(gl: 'Xoves', es: 'Jueves'),
    LocalizedString(gl: 'Venres', es: 'Viernes'),
  ];

  /// «Mércores · Bloque C: 5 novas + repaso de A e B (15 palabras)».
  static String resumo(DailyTprPlan plan, AppLanguage language) {
    final isGl = language == AppLanguage.gl;
    final dia = nomesDosDias[(plan.dia.clamp(1, 5)) - 1].resolve(language);
    if (plan.eReto) {
      return isGl
          ? '$dia · Reto: as ${plan.reviewWords.length} palabras da semana, sen novas'
          : '$dia · Reto: las ${plan.reviewWords.length} palabras de la semana, sin nuevas';
    }
    final novas = plan.newWords.length;
    final cabeza = isGl
        ? '$dia · Bloque ${plan.bloque}: $novas novas'
        : '$dia · Bloque ${plan.bloque}: $novas nuevas';
    if (plan.reviewWords.isEmpty) return cabeza;
    final repasados = WeeklyTprScheduler.bloques
        .take(plan.reviewWords.length ~/ WeeklyTprScheduler.palabrasPorDia)
        .toList();
    final unidos = repasados.length == 1
        ? repasados.first
        : '${repasados.sublist(0, repasados.length - 1).join(', ')}'
            ' ${isGl ? 'e' : 'y'} ${repasados.last}';
    return '$cabeza + repaso de $unidos (${plan.totalLoad} palabras)';
  }

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final dinamica = paraFogar
        ? modeloDoDia?.dinamicaFogar.resolve(language)
        : modeloDoDia?.dinamica.resolve(language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          resumo(plan, language),
          key: const Key('palabras_do_dia_resumo'),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: context.acento,
            height: 1.3,
          ),
        ),
        if (semana != null) ...[
          const SizedBox(height: 2),
          Text(
            '${isGl ? 'Semana' : 'Semana'} ${semana!.semana} · '
            '${semana!.tema.resolve(language)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
        if (dinamica != null && dinamica.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            dinamica,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
        if (plan.newWords.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spaceSm),
          if (detalle)
            for (final p in plan.newWords)
              PalabraConXesto(
                  palabra: p, language: language, audioService: audioService)
          else
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in plan.newWords)
                  _Pastilla(
                      palabra: p,
                      audioService: audioService,
                      language: language),
              ],
            ),
        ],
        if (plan.reviewWords.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spaceSm),
          _Repaso(
            plan: plan,
            language: language,
            // En casa, el viernes, las veinte del reto también suenan: antes
            // salían como texto y había que saber pronunciarlas de oído.
            audioService: !detalle ? audioService : null,
            conVoz: !detalle,
          ),
        ],
      ],
    );
  }
}

/// El recuadro del inglés de un día, con su rótulo: la MISMA pieza en el
/// calendario del aula, en el día en casa y en el calendario de casa.
class BloqueInglesDoDia extends StatelessWidget {
  final String rotulo;
  final DailyTprPlan plan;
  final DiaDoModeloTpr? modeloDoDia;
  final SemanaTpr? semana;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final bool paraFogar;

  const BloqueInglesDoDia({
    super.key,
    required this.rotulo,
    required this.plan,
    required this.language,
    this.modeloDoDia,
    this.semana,
    this.audioService,
    this.paraFogar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: context.acentoTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: context.acento.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            rotulo,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: context.acento,
            ),
          ),
          const SizedBox(height: 6),
          PalabrasDoDia(
            plan: plan,
            modeloDoDia: modeloDoDia,
            semana: semana,
            language: language,
            audioService: audioService,
            paraFogar: paraFogar,
          ),
        ],
      ),
    );
  }
}

/// Las cinco edades del trayecto, en pastillas: el curso cuyas palabras se
/// enseñan. Es la misma elección que «O meu grupo» en el aula y «A miña
/// crianza» en casa.
class SelectorDeCursoTpr extends StatelessWidget {
  final ProgramaTpr programa;
  final String seleccionado;
  final AppLanguage language;
  final String prefixoClave;
  final ValueChanged<String> onCambiar;

  const SelectorDeCursoTpr({
    super.key,
    required this.programa,
    required this.seleccionado,
    required this.language,
    required this.prefixoClave,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    // Wrap y no fila con scroll: con texto grande las cinco edades bajan de
    // línea y se ven todas, en vez de quedar la última fuera de la pantalla.
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final c in programa.cursos)
          ChoiceChip(
            key: ValueKey('${prefixoClave}_${c.id}'),
            label: Text(c.etiqueta.resolve(language)),
            selected: c.id == seleccionado,
            onSelected: (sel) {
              if (sel && c.id != seleccionado) onCambiar(c.id);
            },
            showCheckmark: false,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
      ],
    );
  }
}

class _Pastilla extends StatelessWidget {
  final TprWord palabra;
  final OfflineAudioService? audioService;
  final AppLanguage language;

  const _Pastilla({
    required this.palabra,
    required this.audioService,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    return BotonEscuchar(
      audioService: audioService,
      texto: palabra.en,
      language: AppLanguage.en,
      interfaz: language,
      // La misma regla que el corpus de voz: si aquí se pidiera otro estilo,
      // el botón buscaría una grabación que no existe y no se pintaría.
      style: estiloIngles(palabra.en),
      comoChip: true,
      colorChip: context.acento,
      descripcion: palabra.en,
    );
  }
}

/// La palabra, lo que significa y lo que se hace con el cuerpo.
///
/// Pública porque el cuento de la semana pinta sus palabras con esta MISMA
/// pieza: la docente ve igual la palabra en el día y dentro del cuento.
class PalabraConXesto extends StatelessWidget {
  final TprWord palabra;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// Una marca corta junto a la palabra («Hoxe»). Sin ella no se pinta nada.
  final String? marca;

  const PalabraConXesto({
    super.key,
    required this.palabra,
    required this.language,
    required this.audioService,
    this.marca,
  });

  @override
  Widget build(BuildContext context) {
    final xesto = palabra.tprAction.resolve(language).trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (marca == null)
            _Pastilla(
                palabra: palabra,
                audioService: audioService,
                language: language)
          else
            // Wrap y no fila: con letra grande la marca baja de línea en vez
            // de empujar la pastilla fuera de la pantalla.
            Wrap(
              spacing: 6,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Pastilla(
                    palabra: palabra,
                    audioService: audioService,
                    language: language),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.acento,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    marca!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: palabra.significado(language),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                if (xesto.isNotEmpty) TextSpan(text: ' · $xesto'),
              ],
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// Las que se repasan, en texto: se oyeron el día que fueron nuevas. El viernes
/// van por bloques, que es como se juega el reto.
class _Repaso extends StatelessWidget {
  final DailyTprPlan plan;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// El reto del viernes en pastillas con voz, por bloques.
  final bool conVoz;

  const _Repaso({
    required this.plan,
    required this.language,
    this.audioService,
    this.conVoz = false,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    // Las palabras del repaso se leen: 14 px, el mínimo de lectura (M6).
    const estilo = TextStyle(
      fontSize: 14,
      color: AppTheme.textSecondary,
      height: 1.4,
    );
    if (!plan.eReto) {
      return Text(
        '${isGl ? 'Repaso' : 'Repaso'} (${plan.reviewWords.length}): '
        '${plan.reviewWords.map((p) => p.en).join(' · ')}',
        style: estilo,
      );
    }
    const n = WeeklyTprScheduler.palabrasPorDia;
    if (conVoz) {
      return Column(
        key: const Key('reto_con_voz'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i * n < plan.reviewWords.length; i++) ...[
            if (i > 0) const SizedBox(height: AppTheme.spaceSm),
            Text(
              '${isGl ? 'Bloque' : 'Bloque'} ${WeeklyTprScheduler.bloques[i]}',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: context.acento,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in plan.reviewWords.sublist(
                    i * n,
                    (i + 1) * n > plan.reviewWords.length
                        ? plan.reviewWords.length
                        : (i + 1) * n))
                  _Pastilla(
                    palabra: p,
                    audioService: audioService,
                    language: language,
                  ),
              ],
            ),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i * n < plan.reviewWords.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: '${WeeklyTprScheduler.bloques[i]} · ',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: context.acento,
                  ),
                ),
                TextSpan(
                  text: plan.reviewWords
                      .sublist(i * n, (i + 1) * n)
                      .map((p) => p.en)
                      .join(' · '),
                ),
              ]),
              style: estilo,
            ),
          ),
      ],
    );
  }
}
