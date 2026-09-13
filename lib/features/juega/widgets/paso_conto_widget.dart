import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Phase 2: Cuento guiado with story pages and comprehension prompts for assembly.
///
/// Designed for teacher guidance:
/// - Step-by-step page progression through the illustrated short story.
/// - Clear narrative text for reading aloud to the circle.
/// - Prompts with comprehension questions for the children.
class PasoContoWidget extends StatefulWidget {
  final Cuento cuento;
  final AppLanguage language;

  /// Sin él no hay botón de escuchar. La lectura de la asamblea es justo donde
  /// más falta hace oír la pronunciación modelo en galego.
  final OfflineAudioService? audioService;

  /// Avisa de qué página se está leyendo, para que la barra de inglés anclada
  /// enseñe lo que se dice EN ESA PÁGINA y no un resumen de todo el cuento.
  final ValueChanged<int>? onPaginaCambiada;

  const PasoContoWidget({
    super.key,
    required this.cuento,
    required this.language,
    this.audioService,
    this.onPaginaCambiada,
  });

  @override
  State<PasoContoWidget> createState() => _PasoContoWidgetState();
}

class _PasoContoWidgetState extends State<PasoContoWidget> {
  int _currentPageIndex = 0;

  void _irAPagina(int indice) {
    setState(() => _currentPageIndex = indice);
    widget.onPaginaCambiada?.call(indice);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = widget.language == AppLanguage.gl;
    final pages = widget.cuento.paginas;

    if (pages.isEmpty) {
      return Center(
        child: Text(
          isGl
              ? 'Non hai páxinas dispoñibles no conto.'
              : 'No hay páginas disponibles en el cuento.',
          style: theme.textTheme.bodyMedium,
        ),
      );
    }

    final currentPage = pages[_currentPageIndex.clamp(0, pages.length - 1)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Story title & page indicator
        Row(
          children: [
            Expanded(
              child: Text(
                widget.cuento.titulo.resolve(widget.language),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryVigoBlue,
                  fontSize: 22.0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: AppTheme.secondarySeaGlass.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  isGl
                      ? 'Páxina ${_currentPageIndex + 1} de ${pages.length}'
                      : 'Página ${_currentPageIndex + 1} de ${pages.length}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.primaryVigoBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.0,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16.0),

        // Main Story Card
        Card(
          color: AppTheme.cardSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: const BorderSide(color: Color(0xFFD0D7DE), width: 1.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Visual illustration container (sober pedagogical frame)
                Container(
                  constraints: const BoxConstraints(minHeight: 140),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F1F5),
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.auto_stories_rounded,
                          size: 42,
                          color: AppTheme.primaryVigoBlue,
                        ),
                        const SizedBox(height: 8),
                        // The asset path itself used to be printed here, so a
                        // teacher running the assembly read
                        // "assets/images/cuento/..." off the projector. The
                        // illustrations are not in the package yet; until they
                        // are, this says so in words a teacher can act on.
                        Text(
                          isGl
                              ? 'Lámina ilustrada pendente. Le o texto e sinala o que vedes na aula.'
                              : 'Lámina ilustrada pendiente. Lee el texto y señala lo que veis en el aula.',
                          style: const TextStyle(
                            fontSize: 12.0,
                            color: Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),

                // Narrative text to read aloud
                Text(
                  isGl
                      ? 'Lectura para a asamblea:'
                      : 'Lectura para la asamblea:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  currentPage.texto.resolve(widget.language),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18.0,
                    height: 1.6,
                    color: AppTheme.textSlate,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12.0),
                Align(
                  alignment: Alignment.centerLeft,
                  child: BotonEscuchar(
                    audioService: widget.audioService,
                    texto: currentPage.texto.resolve(widget.language),
                    language: widget.language,
                    descripcion: isGl
                        ? 'a lectura da asemblea'
                        : 'la lectura de la asamblea',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16.0),

        // Teacher Comprehension Prompt Box
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9E6),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: const Color(0xFFFFE082), width: 1.5),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.help_outline_rounded,
                color: Color(0xFFB78103),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl
                          ? 'Pregunta de comprensión para as crianzas:'
                          : 'Pregunta de comprensión para los niños/as:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8D6200),
                        fontSize: 16.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentPage.preguntaComprension.resolve(widget.language),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSlate,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: BotonEscuchar(
                        audioService: widget.audioService,
                        texto: currentPage.preguntaComprension
                            .resolve(widget.language),
                        language: widget.language,
                        compacto: true,
                        descripcion: isGl
                            ? 'a pregunta de comprensión'
                            : 'la pregunta de comprensión',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),

        // Page Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Expanded y etiqueta corta: «Páxina anterior» y «Seguinte páxina»
            // juntos desbordaban 308 px en 360 dp, ya a escala normal. La
            // flecha dice la dirección; la palabra larga sobraba.
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentPageIndex > 0
                    ? () => _irAPagina(_currentPageIndex - 1)
                    : null,
                icon: const Icon(Icons.arrow_back),
                // Dos líneas, no puntos suspensivos: «Páxina anterior» es lo
                // que distingue este botón del de cambiar de FASE, que también
                // dice «Anterior». Cortarlo dejaba dos botones iguales.
                label: Text(
                  isGl ? 'Páxina\nanterior' : 'Página\nanterior',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _currentPageIndex < pages.length - 1
                    ? () => _irAPagina(_currentPageIndex + 1)
                    : null,
                icon: const Icon(Icons.arrow_forward),
                label: Text(
                  isGl ? 'Páxina\nseguinte' : 'Página\nsiguiente',
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
