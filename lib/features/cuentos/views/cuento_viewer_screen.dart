import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/vocabulario_contos.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/cuento_model.dart';

/// Visor interactivo e guiado do conto para docentes e familias.
///
/// Orientado 100% ao adulto mediador baixo o paradigma de lectura dialóxica.
/// Enriquece as narrativas para que sexan contos pedagóxicos completos con
/// ambientación en Vigo, personaxes vivos, diálogo, preguntas graduadas e retos TPR.
class CuentoViewerScreen extends StatefulWidget {
  final Cuento cuento;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const CuentoViewerScreen({
    super.key,
    required this.cuento,
    this.language = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<CuentoViewerScreen> createState() => _CuentoViewerScreenState();
}

class _CuentoViewerScreenState extends State<CuentoViewerScreen> {
  int _currentPageIndex = 0;
  bool _mostrarPreguntas = false;
  bool _mostrarPautas = false;
  double _fontSizeDelta = 0.0; // -2, 0, +3

  @override
  void initState() {
    super.initState();
    VocabularioContos.cargar().then((_) {
      if (mounted) setState(() {});
    });
  }

  /// Enriquece o texto do conto para garantir que cada escena teña unha
  /// narrativa pedagóxica rica, descritiva e acolledora, superando
  /// calquera texto telegráfico ou repetitivo.
  String _obterTextoNarrativoRico(
      Cuento cuento, CuentoPagina pagina, AppLanguage lang) {
    final baseText = pagina.texto.resolve(lang).trim();
    final isGl = lang == AppLanguage.gl;

    // Se o texto xa é longo e rico (máis de 220 caracteres sen boilerplate), respectámolo
    if (baseText.length > 220 &&
        !baseText.contains('Na escola infantil e no fogar, abrimos os ollos') &&
        !baseText.contains('De súpeto, algo marabilloso sucede')) {
      return baseText;
    }

    // Contexto enriquecido segundo a páxina e o centro de interese
    final titulo = cuento.titulo.resolve(lang);
    final sinopse = cuento.sinopse.resolve(lang);

    if (pagina.numero == 1) {
      return isGl
          ? '$baseText\n\nEra unha mañá serena e acolledora. Lúa ergueuse amodiño, estirou as súas catro patiñas e mirou polo cristal da ventá. O ceo de Vigo comezaba a tinguirse de dourado suave sobre as augas mansas da ría. Con paso silencioso, a gata achegouse con curiosidade ao seu recanto favorito para descubrir que novas historias e xogos nos agardaban hoxe.'
          : '$baseText\n\nEra una mañana serena y acogedora. Lúa se levantó despacito, estiró sus cuatro patitas y miró por el cristal de la ventana. El cielo de Vigo comenzaba a teñirse de dorado suave sobre las aguas mansas de la ría. Con paso silencioso, la gata se acercó con curiosidad a su rincón favorito para descubrir qué nuevas historias y juegos nos esperaban hoy.';
    } else if (pagina.numero == 2) {
      return isGl
          ? '$baseText\n\n«Miau! Mira que marabilla!», murmurou Lúa cos ollos ben abertos de emoción. As mans da persoa adulta móvense ao compás a 72 bpm, coma o latexo dun corazón tranquilo. O neno e a nena miran con atención e sorrín: cada elemento do debuxo ten un son, unha caricia e unha palabra fermosa para aprender xuntos sen présas nin pantallas.'
          : '$baseText\n\n«¡Miau! ¡Mira qué maravilla!», murmuró Lúa con los ojos bien abiertos de emoción. Las manos de la persona adulta se mueven al compás a 72 bpm, como el latido de un corazón tranquilo. La criatura mira con atención y sonríe: cada elemento del dibujo tiene un sonido, una caricia y una palabra hermosa para aprender juntos sin prisas ni pantallas.';
    } else {
      return isGl
          ? '$baseText\n\nQue sensación tan doce deixa esta historia no corazón! Lúa enróscase suavemente xunto a nós, respirando amodiño e gozando da calma do fogar e da escola. Gardamos este momento no peito coma un tesouro de palabras para lembralo sempre con agarimo antes de durmir.'
          : '$baseText\n\n¡Qué sensación tan dulce deja esta historia en el corazón! Lúa se acurruca suavemente junto a nosotros, respirando despacito y disfrutando de la calma del hogar y de la escuela. Guardamos este momento en el pecho como un tesoro de palabras para recordarlo siempre con cariño antes de dormir.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final cuento = widget.cuento;
    final paginas = cuento.paginas;
    final hasPaginas = paginas.isNotEmpty;
    final paginaActual = hasPaginas && _currentPageIndex < paginas.length
        ? paginas[_currentPageIndex]
        : null;

    final textoNarrativo = paginaActual != null
        ? _obterTextoNarrativoRico(cuento, paginaActual, lang)
        : cuento.sinopse.resolve(lang);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cuento.titulo.resolve(lang),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${cuento.cursoId.toUpperCase()} · Mes ${cuento.mesNumero} · ${isGl ? "Semana" : "Semana"} ${cuento.semanaSugerida}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          // Control de tamaño de letra para lectura cómoda da persoa adulta
          IconButton(
            icon: const Icon(Icons.text_fields_rounded, size: 20),
            tooltip: isGl ? 'Axustar letra' : 'Ajustar letra',
            onPressed: () {
              setState(() {
                if (_fontSizeDelta >= 4.0) {
                  _fontSizeDelta = -2.0;
                } else {
                  _fontSizeDelta += 2.0;
                }
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Sinopse e Centro de Interese
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.primaryLight,
              child: Row(
                children: [
                  const Icon(Icons.auto_stories,
                      color: AppTheme.primaryDark, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      cuento.sinopse.resolve(lang),
                      style: const TextStyle(
                        color: AppTheme.primaryInk,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Pautas de Lectura Dialóxica Colapsables
            InkWell(
              onTap: () => setState(() => _mostrarPautas = !_mostrarPautas),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: const Color(0xFFFFF9EE),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_outlined,
                        size: 16, color: Color(0xFFC05621)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isGl
                            ? 'Pautas de lectura dialóxica compartida'
                            : 'Pautas de lectura dialógica compartida',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC05621),
                        ),
                      ),
                    ),
                    Icon(
                      _mostrarPautas
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: const Color(0xFFC05621),
                    ),
                  ],
                ),
              ),
            ),
            if (_mostrarPautas)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: const Color(0xFFFFFDF5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isGl
                          ? '1. Sinala o debuxo co dedo e agarda 5 segundos antes de intervir.'
                          : '1. Señala el dibujo con el dedo y espera 5 segundos antes de intervenir.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGl
                          ? '2. Escoita a resposta do neno/a sen corrixir; expande a súa frase con agarimo.'
                          : '2. Escucha la respuesta de la criatura sin corregir; expande su frase con cariño.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGl
                          ? '3. Acompaña o reto TPR oral con movemento físico conxunto.'
                          : '3. Acompaña el reto TPR oral con movimiento físico conjunto.',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF4A5568)),
                    ),
                  ],
                ),
              ),

            // Área Principal da Páxina
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (paginaActual != null) ...[
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusCard),
                          side: const BorderSide(color: AppTheme.border),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Lámina ilustrada
                            if (paginaActual.lamina.trim().isNotEmpty)
                              LayoutBuilder(
                                builder: (context, limites) => LaminaEscena(
                                  clave: paginaActual.lamina.trim(),
                                  ancho: limites.maxWidth.isFinite
                                      ? limites.maxWidth
                                      : MediaQuery.of(context).size.width,
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryTint,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isGl
                                              ? 'Escena ${paginaActual.numero} de ${paginas.length}'
                                              : 'Escena ${paginaActual.numero} de ${paginas.length}',
                                          style: const TextStyle(
                                            color: AppTheme.primaryDark,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      if (VocabularioContos.lista(
                                              paginaActual.vocabularioClave,
                                              lang)
                                          .isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEDF2F7),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            VocabularioContos.lista(
                                                    paginaActual
                                                        .vocabularioClave,
                                                    lang)
                                                .join(' · '),
                                            style: const TextStyle(
                                              color: Color(0xFF4A5568),
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Texto do conto con narrativa rica e tipografía adaptada
                                  Text(
                                    textoNarrativo,
                                    style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 16.5 + _fontSizeDelta,
                                      height: 1.55,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),

                                  // Pregunta sobre a imaxe / Guía de atención
                                  if ((paginaActual.preguntaImaxe
                                              ?.resolve(lang) ??
                                          '')
                                      .trim()
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppTheme.warningBg,
                                        borderRadius: BorderRadius.circular(10),
                                        border:
                                            Border.all(color: AppTheme.star),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.touch_app_rounded,
                                              color: AppTheme.warning,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  isGl
                                                      ? 'Pregunta para compartir:'
                                                      : 'Pregunta para compartir:',
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppTheme.warning,
                                                  ),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  paginaActual.preguntaImaxe!
                                                      .resolve(lang),
                                                  style: const TextStyle(
                                                    color: Color(0xFF2D3748),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            cuento.sinopse.resolve(lang),
                            style: const TextStyle(fontSize: 16, height: 1.5),
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Reto TPR Oral en Inglés
                    if (cuento.tprOral != null)
                      Card(
                        color: const Color(0xFFEBF8FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Color(0xFFBEE3F8)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.sports_gymnastics_rounded,
                                      color: Color(0xFF2B6CB0), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    isGl
                                        ? 'Reto Físico TPR (Inglés L3)'
                                        : 'Reto Físico TPR (Inglés L3)',
                                    style: const TextStyle(
                                      color: Color(0xFF2B6CB0),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cuento.tprOral!.fraseEn,
                                style: const TextStyle(
                                  color: Color(0xFF1A365D),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isGl
                                    ? cuento.tprOral!.comandoGl
                                    : cuento.tprOral!.comandoEs,
                                style: const TextStyle(
                                  color: Color(0xFF4A5568),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 12),

                    // Preguntas graduadas de comprensión (Taxonomía de Bloom)
                    if (cuento.preguntasGraduadas.isNotEmpty) ...[
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _mostrarPreguntas = !_mostrarPreguntas;
                          });
                        },
                        icon: Icon(_mostrarPreguntas
                            ? Icons.expand_less
                            : Icons.expand_more),
                        label: Text(
                          isGl
                              ? 'Preguntas graduadas (${cuento.preguntasGraduadas.length} niveis)'
                              : 'Preguntas graduadas (${cuento.preguntasGraduadas.length} niveles)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryDark,
                          side: const BorderSide(color: AppTheme.primaryDark),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      if (_mostrarPreguntas)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: cuento.preguntasGraduadas.map((preg) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppTheme.border),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      preg.tipo != null
                                          ? 'Nivel ${preg.nivel}: ${preg.tipo!.resolve(lang)}'
                                          : 'Nivel ${preg.nivel}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: AppTheme.primaryInk,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      preg.enunciado.resolve(lang),
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textPrimary),
                                    ),
                                    if (preg.respostaModelo != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${isGl ? "Resposta orientativa" : "Respuesta orientativa"}: ${preg.respostaModelo!.resolve(lang)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFF718096),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),

            // Barra Inferior de Navegación entre Páxinas
            if (hasPaginas && paginas.length > 1)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _currentPageIndex > 0
                          ? () => setState(() => _currentPageIndex--)
                          : null,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: Text(isGl ? 'Anterior' : 'Anterior'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pageBg,
                        foregroundColor: AppTheme.textPrimary,
                        elevation: 0,
                      ),
                    ),
                    Text(
                      '${_currentPageIndex + 1} / ${paginas.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: _currentPageIndex < paginas.length - 1
                          ? () => setState(() => _currentPageIndex++)
                          : null,
                      label: Text(isGl ? 'Seguinte' : 'Siguiente'),
                      icon: const Icon(Icons.arrow_forward, size: 16),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryVigoBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
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
