import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/vocabulario_contos.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../widgets/palabras_do_conto.dart';

import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';

/// Visor interactivo e guiado do conto para docentes e familias.
///
/// Orientado 100% ao adulto mediador baixo o paradigma de lectura dialóxica.
/// Enriquece as narrativas para que sexan contos pedagóxicos completos con
/// ambientación en Vigo, personaxes vivos, diálogo, preguntas graduadas e retos TPR.
class CuentoViewerScreen extends StatefulWidget {
  final Cuento cuento;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// La semana del curso de inglés a la que pertenece el cuento: sus veinte
  /// palabras están en el texto. Sin ella el cuento se lee igual, y sus
  /// palabras se pintan con lo que trae la propia página.
  final SemanaTpr? semanaTpr;

  /// 1 (lunes) a 5 (viernes) cuando se abre desde el día del aula: entonces
  /// se marcan las palabras de HOY. `null` desde la biblioteca.
  final int? dia;

  const CuentoViewerScreen({
    super.key,
    required this.cuento,
    this.language = AppLanguage.gl,
    this.audioService,
    this.semanaTpr,
    this.dia,
  });

  @override
  State<CuentoViewerScreen> createState() => _CuentoViewerScreenState();
}

class _CuentoViewerScreenState extends State<CuentoViewerScreen> {
  /// «0-2 anos» e non «CURSO_0_2», que é o identificador interno.
  static String _idadeDoCurso(String cursoId, bool isGl) {
    final m = RegExp(r'^curso_(\d)_(\d)$').firstMatch(cursoId);
    if (m == null) return cursoId;
    return '${m[1]}-${m[2]} ${isGl ? 'anos' : 'años'}';
  }

  int _currentPageIndex = 0;
  bool _mostrarPreguntas = false;
  bool _mostrarPautas = false;
  double _fontSizeDelta = 0.0; // -2, 0, +3

  /// La tarjeta de la página: tocar una palabra de la cabecera lleva hasta
  /// ella, no solo cambia el número de abajo.
  final GlobalKey _claveDaPaxina = GlobalKey();

  late final PalabrasNoConto _palabras = PalabrasNoConto(
    cuento: widget.cuento,
    semana: widget.semanaTpr,
    dia: widget.dia,
  );

  @override
  void initState() {
    super.initState();
    VocabularioContos.cargar().then((_) {
      if (mounted) setState(() {});
    });
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

    // O texto da páxina sae do JSON, non dun xerador.
    //
    // Había un «motor de narrativa» que detectaba que os cen contos do banco
    // eran texto modelo e, en vez de arranxar o JSON, escribía tres parágrafos
    // FIXOS en tempo de execución co título e o mes metidos dentro. Os cen
    // contos lían igual salvo dúas palabras, e ningún gate podía verlo porque
    // o texto non existía en ningún ficheiro. Agora os cen levan a súa propia
    // narrativa nas tres páxinas e nas dúas linguas, dentro de
    // assets/content/cuentos/banco100_cuentos.json.
    final textoNarrativo = paginaActual != null
        ? paginaActual.texto.resolve(lang)
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
              [
                _idadeDoCurso(cuento.cursoId, isGl),
                nomeDoMes[cuento.mesCalendario]?.resolve(lang) ?? '',
                if (cuento.semanaSugerida case final semana?)
                  '${isGl ? "semana" : "semana"} $semana',
              ].join(' · '),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF4A5568)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGl
                          ? '2. Escoita a resposta do neno/a sen corrixir; expande a súa frase con agarimo.'
                          : '2. Escucha la respuesta de la criatura sin corregir; expande su frase con cariño.',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF4A5568)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGl
                          ? '3. Acompaña o reto TPR oral con movemento físico conxunto.'
                          : '3. Acompaña el reto TPR oral con movimiento físico conjunto.',
                      style: const TextStyle(
                          fontSize: 11, color: Color(0xFF4A5568)),
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
                    // Las palabras del día, dentro del cuento que se va a
                    // leer: cuáles son y en qué página están.
                    if (widget.semanaTpr != null && _palabras.levaPalabras)
                      CabeceiraPalabrasDoConto(
                        palabras: _palabras,
                        language: lang,
                        onIrAPaxina: (i) {
                          if (i < 0 || i >= paginas.length) return;
                          setState(() => _currentPageIndex = i);
                          // Sin esto la página cambiaba debajo y la docente
                          // seguía viendo la cabecera.
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final ctx = _claveDaPaxina.currentContext;
                            if (ctx != null && ctx.mounted) {
                              Scrollable.ensureVisible(ctx);
                            }
                          });
                        },
                      ),
                    if (paginaActual != null) ...[
                      Card(
                        key: _claveDaPaxina,
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
                                  // Wrap: a pastilla da escena máis a do
                                  // vocabulario desbordaban a 400 px de ancho.
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
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
                                      // Con palabras de la semana, su
                                      // significado va debajo, con su voz.
                                      if (paginaActual.palabras.isEmpty &&
                                          VocabularioContos.lista(
                                                  paginaActual
                                                      .vocabularioPara(lang),
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
                                                        .vocabularioPara(lang),
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

                                  // O texto do conto, co inglés resaltado:
                                  // o que vai entre “…” son as palabras da
                                  // semana, e as de hoxe levan fondo.
                                  Text.rich(
                                    key: const Key('texto_do_conto'),
                                    textoConPalabras(
                                      texto: textoNarrativo,
                                      palabras: _palabras,
                                      estilo: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 16.5 + _fontSizeDelta,
                                        height: 1.55,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),

                                  PalabrasDaPaxina(
                                    pagina: paginaActual,
                                    palabras: _palabras,
                                    language: lang,
                                    audioService: widget.audioService,
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
                              const Row(
                                children: [
                                  Icon(Icons.sports_gymnastics_rounded,
                                      color: Color(0xFF2B6CB0), size: 18),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Reto Físico TPR (Inglés L3)',
                                      style: TextStyle(
                                        color: Color(0xFF2B6CB0),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cuento.tprOral!.fraseEn,
                                      style: const TextStyle(
                                        color: Color(0xFF1A365D),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  BotonEscuchar(
                                    audioService: widget.audioService,
                                    texto: cuento.tprOral!.fraseEn,
                                    language: AppLanguage.en,
                                    compacto: true,
                                  ),
                                ],
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
                // Cada botón cede o seu ancho e a etiqueta encolle só cando
                // non cabe: coa letra grande do sistema, «Seguinte» e
                // «Anterior» saían pola dereita dun teléfono de 360 dp.
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _currentPageIndex > 0
                            ? () => setState(() => _currentPageIndex--)
                            : null,
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(isGl ? 'Anterior' : 'Anterior'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.pageBg,
                          foregroundColor: AppTheme.textPrimary,
                          elevation: 0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${_currentPageIndex + 1} / ${paginas.length}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    Flexible(
                      child: ElevatedButton.icon(
                        onPressed: _currentPageIndex < paginas.length - 1
                            ? () => setState(() => _currentPageIndex++)
                            : null,
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(isGl ? 'Seguinte' : 'Siguiente'),
                        ),
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryVigoBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
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
