import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/leccion_model.dart';
import '../widgets/camino_da_unidade.dart';
import '../widgets/leccion_da_semana.dart';

/// Todo el camino del curso, como la página «learn» de duolingo-clone
/// (github.com/sanidhyy/duolingo-clone, MIT, `app/(main)/learn/page.tsx`):
/// las unidades una detrás de otra, cada una con su franja y sus lecciones.
/// Al tocar una lección se ve lo que trae.
class CaminoDoCursoScreen extends StatefulWidget {
  final Leccions leccions;
  final String cursoId;

  /// La lección de esta semana.
  final String actual;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const CaminoDoCursoScreen({
    super.key,
    required this.leccions,
    required this.cursoId,
    required this.actual,
    required this.language,
    this.audioService,
  });

  @override
  State<CaminoDoCursoScreen> createState() => _CaminoDoCursoScreenState();
}

class _CaminoDoCursoScreenState extends State<CaminoDoCursoScreen> {
  late AppLanguage _lang = widget.language;
  final _actual = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Se abre en la unidad de ahora, no en la primera.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final c = _actual.currentContext;
      if (c != null) Scrollable.ensureVisible(c, alignment: 0.1);
    });
  }

  void _abrir(UnidadeDeLeccions u, Leccion l) {
    final lang = _lang;
    final isGl = lang == AppLanguage.gl;
    Widget chip(PezaDaLeccion p) => BotonEscuchar(
          audioService: widget.audioService,
          texto: p.en,
          language: AppLanguage.en,
          interfaz: lang,
          style: estiloIngles(p.en),
          comoChip: true,
          colorChip: context.acento,
          descripcion: p.en,
          significado: p.significado,
        );
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          key: ValueKey('camino_leccion_${l.id}'),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${u.titulo.resolve(lang)} · '
                '${l.repaso ? 'Repaso' : 'Lección'} ${l.numero} ${isGl ? 'de' : 'de'} ${l.de}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in l.repaso ? l.repasa : l.novas) chip(p)
                ],
              ),
              if (u.gramatica case final gr?) ...[
                const SizedBox(height: 12),
                Text(
                  '${isGl ? 'Gramática' : 'Gramática'} · ${gr.nivel} · '
                  '${gr.titulo.resolve(lang)}',
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (l.fraseGramatica case final fg?) ...[
                  const SizedBox(height: 6),
                  chip(fg),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _lang == AppLanguage.gl;
    final unidades = widget.leccions.unidades[widget.cursoId] ?? const [];
    final iActual = unidades
        .indexWhere((u) => u.leccions.any((l) => l.id == widget.actual));
    final nActual = iActual < 0
        ? 0
        : unidades[iActual]
            .leccions
            .firstWhere((l) => l.id == widget.actual)
            .numero;
    final grupo = LeccionDaSemana.grupos[widget.cursoId]?.resolve(_lang) ?? '';
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'O camiño · $grupo' : 'El camino · $grupo',
        language: _lang,
        onLanguageChanged: (l) => setState(() => _lang = l),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: const Key('camino_do_curso'),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, u) in unidades.indexed)
                Padding(
                  key: i == iActual ? _actual : null,
                  padding: const EdgeInsets.only(bottom: 28),
                  child: CaminoDaUnidade(
                    unidade: u,
                    numero: i + 1,
                    de: unidades.length,
                    actual: i == iActual ? widget.actual : null,
                    feita: (l) =>
                        i < iActual || (i == iActual && l.numero < nActual),
                    onTap: (l) => _abrir(u, l),
                    language: _lang,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
