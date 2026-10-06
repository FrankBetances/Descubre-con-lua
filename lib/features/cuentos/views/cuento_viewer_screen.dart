import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/localization/vocabulario_contos.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/aviso_contenido_ilegible.dart';
import '../../../data/models/como_funciona_o_conto_model.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../widgets/palabras_do_conto.dart';

import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/pasos_navegacion.dart';

/// Visor interactivo e guiado do conto para docentes e familias.
///
/// Orientado 100% ao adulto mediador baixo o paradigma de lectura dialóxica.
/// Enriquece as narrativas para que sexan contos pedagóxicos completos con
/// ambientación en Vigo, personaxes vivos, diálogo, preguntas graduadas e retos TPR.
class CuentoViewerScreen extends StatefulWidget {
  final Cuento cuento;
  final AppLanguage language;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// La semana del curso de inglés a la que pertenece el cuento: sus veinte
  /// palabras están en el texto. Sin ella el cuento se lee igual, y sus
  /// palabras se pintan con lo que trae la propia página.
  final SemanaTpr? semanaTpr;

  /// 1 (lunes) a 5 (viernes) cuando se abre desde el día del aula: entonces
  /// se marcan las palabras de HOY. `null` desde la biblioteca.
  final int? dia;

  /// «Como funciona o conto». Sin él se lee del paquete; los tests lo pasan.
  final ComoFuncionaOConto? comoFunciona;

  const CuentoViewerScreen({
    super.key,
    required this.cuento,
    this.language = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
    this.semanaTpr,
    this.dia,
    this.comoFunciona,
  });

  /// «Como funciona», plegado. Sale desplegado la primera vez que se abre un
  /// cuento en cada sesión de la app, que es cuando hace falta; al cerrar ese
  /// cuento, o al tocar «Ocultar», queda en una línea que se abre tocándola,
  /// para no empujar la primera página a quien ya lo conoce. Vive mientras la
  /// app está abierta y no se guarda en ningún sitio: la app solo guarda la
  /// cuenta de la persona adulta.
  static bool _explicacionPlegada = false;

  /// Solo para los tests: desplegada, como al abrir la app.
  @visibleForTesting
  static void despregarExplicacion() => _explicacionPlegada = false;

  /// Solo para los tests: plegada, como después del primer cuento.
  @visibleForTesting
  static void pregarExplicacion() => _explicacionPlegada = true;

  @override
  State<CuentoViewerScreen> createState() => _CuentoViewerScreenState();
}

class _CuentoViewerScreenState extends State<CuentoViewerScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language = widget.language;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant CuentoViewerScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.language != widget.language) _language = widget.language;
  }

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

  late ComoFuncionaOConto? _comoFunciona = widget.comoFunciona;
  Object? _erroComoFunciona;

  @override
  void initState() {
    super.initState();
    VocabularioContos.cargar().then((_) {
      if (mounted) setState(() {});
    });
    if (_comoFunciona == null) {
      ComoFuncionaOConto.cargar().then<void>(
        (c) {
          if (mounted) setState(() => _comoFunciona = c);
        },
        onError: (Object e) {
          if (mounted) setState(() => _erroComoFunciona = e);
        },
      );
    }
  }

  @override
  void dispose() {
    // Ya se vio una vez en esta sesión: la próxima, plegada.
    if (_comoFunciona != null) CuentoViewerScreen._explicacionPlegada = true;
    super.dispose();
  }

  /// La explicación, solo en la primera página: es donde empieza quien abre
  /// el cuento por primera vez, por cualquiera de sus cuatro puertas.
  Widget? _explicacion(AppLanguage lang) {
    if (_currentPageIndex != 0) return null;
    if (_erroComoFunciona != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceLg),
        child: AvisoContenidoIlegible(
          asset: ComoFuncionaOConto.assetPath,
          language: lang,
        ),
      );
    }
    final como = _comoFunciona;
    if (como == null) return null;
    final cuento = widget.cuento;
    return _ComoFunciona(
      como: como,
      pasos: como.pasosPara(
        conPalabras: _palabras.levaPalabras,
        conDia: _palabras.plan != null,
        conPregunta: cuento.paginas.any(
            (p) => (p.preguntaImaxe?.resolve(lang) ?? '').trim().isNotEmpty),
        conReto: cuento.tprOral != null,
      ),
      language: lang,
      aberta: !CuentoViewerScreen._explicacionPlegada,
      onAlternar: () => setState(() => CuentoViewerScreen._explicacionPlegada =
          !CuentoViewerScreen._explicacionPlegada),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
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
      appBar: Cabecera(
        titulo: isGl ? 'Conto' : 'Cuento',
        language: _language,
        onLanguageChanged: _cambiarLingua,
        accions: [
          // Control de tamaño de letra para lectura cómoda da persoa adulta
          IconButton(
            icon: const Icon(Icons.text_fields_rounded,
                size: 22, color: Colors.white),
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
            // O título do conto e a súa sinopse. O título vivía na cabeceira,
            // pero alí non cabe enteiro: hai contos de máis de trinta letras.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: context.acentoTint,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.auto_stories_rounded,
                        color: context.acento, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Para quién y cuándo, encima del título. En la
                        // cabecera, al lado del selector de lengua, se cortaba.
                        Text(
                          [
                            _idadeDoCurso(cuento.cursoId, isGl),
                            nomeDoMes[cuento.mesCalendario]?.resolve(lang) ??
                                '',
                            if (cuento.semanaSugerida case final semana?)
                              'semana $semana',
                          ].where((t) => t.isNotEmpty).join(' · '),
                          key: const ValueKey('conto_meta'),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cuento.titulo.resolve(lang),
                          key: const ValueKey('conto_titulo'),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          cuento.sinopse.resolve(lang),
                          style: TextStyle(
                            color: context.acento,
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
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
                color: AppTheme.warningBg,
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates_rounded,
                        size: 16, color: AppTheme.warning),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isGl
                            ? 'Pautas de lectura dialóxica compartida'
                            : 'Pautas de lectura dialógica compartida',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warning,
                        ),
                      ),
                    ),
                    Icon(
                      _mostrarPautas
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppTheme.warning,
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
                          fontSize: 12, color: Color(0xFF4A5568)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGl
                          ? '2. Escoita a resposta do neno/a sen corrixir; expande a súa frase con agarimo.'
                          : '2. Escucha la respuesta de la criatura sin corregir; expande su frase con cariño.',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A5568)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isGl
                          ? '3. Acompaña o reto TPR oral con movemento físico conxunto.'
                          : '3. Acompaña el reto TPR oral con movimiento físico conjunto.',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF4A5568)),
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
                    if (_explicacion(lang) case final explicacion?) explicacion,
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
                                          color: context.acentoTint,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isGl
                                              ? 'Escena ${paginaActual.numero} de ${paginas.length}'
                                              : 'Escena ${paginaActual.numero} de ${paginas.length}',
                                          style: TextStyle(
                                            color: context.acento,
                                            fontSize: 12,
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
                                              fontSize: 12,
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
                                      acento: context.acento,
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
                                                    fontSize: 12,
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
                                                    fontSize: 14,
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
                                      'Reto físico TPR (inglés L3)',
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
                                    interfaz: lang,
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
                                  fontSize: 14,
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
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded),
                        label: Text(
                          isGl
                              ? 'Preguntas graduadas (${cuento.preguntasGraduadas.length} niveis)'
                              : 'Preguntas graduadas (${cuento.preguntasGraduadas.length} niveles)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.acento,
                          side: BorderSide(color: context.acento),
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
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: context.acento,
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
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: AppTheme.textMuted,
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

            // Pasar páxina: a frecha volve, o botón principal avanza e, na
            // última, pecha o conto. Antes eran dous botóns iguais e a última
            // páxina deixaba o principal apagado, sen saída.
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
                child: PasosNavegacion(
                  chaveAnterior: const ValueKey('conto_anterior'),
                  chaveSeguinte: const ValueKey('conto_seguinte'),
                  anterior: _currentPageIndex > 0
                      ? () => setState(() => _currentPageIndex--)
                      : null,
                  etiquetaAnterior:
                      isGl ? 'Páxina anterior' : 'Página anterior',
                  centro: Text(
                    '${_currentPageIndex + 1} / ${paginas.length}',
                    key: const ValueKey('conto_paxina'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  etiquetaSeguinte: _currentPageIndex < paginas.length - 1
                      ? (isGl ? 'Seguinte' : 'Siguiente')
                      : (isGl ? 'Rematar' : 'Terminar'),
                  iconaSeguinte: _currentPageIndex < paginas.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded,
                  seguinte: () {
                    if (_currentPageIndex < paginas.length - 1) {
                      setState(() => _currentPageIndex++);
                    } else {
                      Navigator.of(context).maybePop();
                    }
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// «Como funciona o conto»: cuatro o cinco frases, numeradas, que dicen qué
/// es cada cosa de la página y qué se hace con ella. Desplegada, se pliega con
/// «Ocultar»; plegada, es una línea que se vuelve a abrir tocándola.
class _ComoFunciona extends StatelessWidget {
  final ComoFuncionaOConto como;
  final List<LocalizedString> pasos;
  final AppLanguage language;
  final bool aberta;
  final VoidCallback onAlternar;

  const _ComoFunciona({
    required this.como,
    required this.pasos,
    required this.language,
    required this.aberta,
    required this.onAlternar,
  });

  @override
  Widget build(BuildContext context) {
    final titulo = Row(
      children: [
        Icon(Icons.lightbulb_rounded, size: 20, color: context.acento),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            como.titulo.resolve(language),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        if (aberta)
          TextButton(
            key: const ValueKey('como_funciona_ocultar'),
            onPressed: onAlternar,
            style: TextButton.styleFrom(
              foregroundColor: context.acento,
              minimumSize: const Size(AppTheme.touchMin, AppTheme.touchMin),
            ),
            child: Text(
              como.ocultar.resolve(language),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          )
        else
          Icon(Icons.keyboard_arrow_down_rounded, color: context.acento),
      ],
    );

    return Container(
      key: const ValueKey('como_funciona_o_conto'),
      margin: const EdgeInsets.only(bottom: AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: aberta
          ? Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 6, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  titulo,
                  for (final (i, paso) in pasos.indexed)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, right: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            child: Text(
                              '${i + 1}.',
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w800,
                                color: context.acento,
                                height: 1.4,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              paso.resolve(language),
                              style: const TextStyle(
                                fontSize: 14.5,
                                color: AppTheme.textPrimary,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : InkWell(
              key: const ValueKey('como_funciona_abrir'),
              onTap: onAlternar,
              borderRadius: BorderRadius.circular(AppTheme.radiusField),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: titulo,
                ),
              ),
            ),
    );
  }
}
