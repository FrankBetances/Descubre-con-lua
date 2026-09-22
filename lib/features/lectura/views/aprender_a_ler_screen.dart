import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../core/widgets/aviso_contenido_ilegible.dart';
import '../../../data/models/lectura_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Hub Integral de Aprender a Ler, Fónica e Alfabetización Temperá Manipulativa.
///
/// Deseñado baixo o paradigma de Cero Pantallas para a Crianza (/tangible-l2-parent-orchestrator):
/// 1. Conciencia Fonolóxica e Sons Iniciais (Rimas e sílabas corporais).
/// 2. Mesa Manipulativa Alphabot Expandida (Letras de madeira, imáns e fonemas).
/// 3. Fónica Combinatoria e Cubos CVC (Phonicubes).
/// 4. Pares Mínimos e Discriminación Auditiva (/b/ vs /p/, /m/ vs /n/).
/// 5. Rexistro Observacional 1-Toque para a persoa adulta.
class AprenderALerScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  /// El contenido ya leído, si quien abre la pantalla lo tiene.
  ///
  /// Existe por lo mismo que en `CalendarioScreen`: un test tiene que poder
  /// darle el contenido hecho. Si se deja que la pantalla lo lea ella dentro
  /// de `testWidgets`, el disco de «cargando» no para nunca —el reloj de ahí
  /// dentro es falso— y `pumpAndSettle` se agota sin decir por qué.
  final ContidoLectura? contido;

  const AprenderALerScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
    this.contido,
  });

  @override
  State<AprenderALerScreen> createState() => _AprenderALerScreenState();
}

class _AprenderALerScreenState extends State<AprenderALerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late AppLanguage _language;

  // Estado da Mesa Alphabot
  int _alphabotCategoryIndex = 0;
  int _alphabotWordIndex = 0;
  final Set<String> _placedLetters = {};

  // Estado dos Cubos CVC
  int _cvcIndex = 0;

  // Estado de Pares Mínimos
  int _paresIndex = 0;

  // Rexistro Observacional 1-Toque
  final Map<String, String> _observacions = {}; // id -> 'L' | 'A' | 'E'

  // O contido vive en assets/content/lectura/aprender_a_ler.json, non aquí.
  ContidoLectura? _contido;
  Object? _erroContido;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _tabController = TabController(length: 4, vsync: this);
    if (widget.contido != null) {
      _contido = widget.contido;
    } else {
      ContidoLectura.cargar().then((c) {
        if (mounted) setState(() => _contido = c);
      }).catchError((Object e) {
        if (mounted) setState(() => _erroContido = e);
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          isGl
              ? 'Aprender a Ler · Alfabetización'
              : 'Aprender a Leer · Alfabetización',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.primaryVigoBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryVigoBlue,
          indicatorWeight: 3,
          tabs: [
            Tab(
                text: isGl
                    ? '1. Conciencia Fonolóxica'
                    : '1. Conciencia Fonológica'),
            Tab(text: isGl ? '2. Mesa Alphabot' : '2. Mesa Alphabot'),
            Tab(text: isGl ? '3. Cubos CVC' : '3. Cubos CVC'),
            Tab(text: isGl ? '4. Pares Mínimos' : '4. Pares Mínimos'),
          ],
        ),
      ),
      body: SafeArea(
        child: _erroContido != null
            // Un fallo de lectura se ENSEÑA. El disco girando queda para lo
            // que de verdad tarda: ver aviso_contenido_ilegible.dart.
            ? AvisoContenidoIlegible(
                asset: ContidoLectura.assetPath,
                language: lang,
              )
            : _contido == null
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabConcienciaFonoloxica(isGl),
                      _buildTabMesaAlphabot(isGl),
                      _buildTabCubosCvc(isGl),
                      _buildTabParesMinimos(isGl),
                    ],
                  ),
      ),
    );
  }

  // --- TAB 1: CONCIENCIA FONOLÓXICA ---
  Widget _buildTabConcienciaFonoloxica(bool isGl) {
    final contido = _contido!;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(contido.avisoZeroPantalla.resolve(_language)),
        const SizedBox(height: 14),
        ...contido.actividadesConciencia
            .map((act) => _buildCardActividadeFonoloxica(act, isGl)),
      ],
    );
  }

  Widget _buildCardActividadeFonoloxica(ActividadeConciencia act, bool isGl) {
    final obs = _observacions[act.id];

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hearing_rounded,
                    color: AppTheme.primaryVigoBlue, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    act.titulo.resolve(_language),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              act.subtitulo.resolve(_language),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              act.descricion.resolve(_language),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEDF2F7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.touch_app_outlined,
                      size: 14, color: Color(0xFF4A5568)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Acción corporal: ${act.tpr.resolve(_language)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D3748),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _buildSelector1Tap(act.id, obs, isGl),
          ],
        ),
      ),
    );
  }

  // --- TAB 2: MESA MANIPULATIVA ALPHABOT ---
  Widget _buildTabMesaAlphabot(bool isGl) {
    final categorias = _contido!.categoriasAlphabot;
    final cat = categorias[_alphabotCategoryIndex % categorias.length];
    final words = cat.palabras;
    final item = words[_alphabotWordIndex % words.length];
    final letters = item.letras.resolve(_language);
    final phonemes = item.fonemas.resolve(_language);
    final isComplete = _placedLetters.length >= letters.length;
    final obs = _observacions[item.id];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'Mesa física: coloca letras de madeira, imáns na neveira ou cartolinas recortadas diante da crianza. O adulto guia a articulación fonema a fonema.'
              : 'Mesa física: coloca letras de madera, imanes en la nevera o cartulinas recortadas delante de la criatura. El adulto guía la articulación fonema a fonema.',
        ),
        const SizedBox(height: 14),

        // Selector de Categoría
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(categorias.length, (idx) {
              final c = categorias[idx];
              final isSel = _alphabotCategoryIndex == idx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.nome.resolve(_language)),
                  selected: isSel,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _alphabotCategoryIndex = idx;
                        _alphabotWordIndex = 0;
                        _placedLetters.clear();
                      });
                    }
                  },
                  selectedColor: AppTheme.primaryVigoBlue,
                  labelStyle: TextStyle(
                    color: isSel ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),

        // Tarxeta da Palabra Manipulativa Actual
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${isGl ? "Palabra" : "Palabra"} ${_alphabotWordIndex + 1} / ${words.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        setState(() {
                          _alphabotWordIndex =
                              (_alphabotWordIndex + 1) % words.length;
                          _placedLetters.clear();
                        });
                      },
                      tooltip: isGl ? 'Seguinte palabra' : 'Siguiente palabra',
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Palabra en letras grandes manipulativas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.palabra.resolve(_language).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.primaryInk,
                        letterSpacing: 6,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // A ficha pintase en MAIÚSCULAS porque é unha ficha de
                    // letras, pero ao botón vai a forma natural: o
                    // identificador da gravación sae do texto exacto, e «GATO»
                    // e «Gato» son dúas gravacións distintas. Pasar a forma da
                    // pantalla deixaba o botón sen pintar.
                    BotonEscuchar(
                      audioService: widget.audioService,
                      texto: item.palabra.resolve(_language),
                      language: _language,
                      style: VoiceStyle.slow,
                      compacto: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.significado.resolve(_language),
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 16),

                // Reixa de Letras Táctiles (Espello do que o neno monta na mesa)
                Wrap(
                  spacing: 10,
                  children: letters.map((l) {
                    final isPlaced = _placedLetters.contains(l);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isPlaced) {
                            _placedLetters.remove(l);
                          } else {
                            _placedLetters.add(l);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 52,
                        height: 58,
                        decoration: BoxDecoration(
                          color: isPlaced
                              ? const Color(0xFFC6F6D5)
                              : const Color(0xFFFFF9EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isPlaced
                                ? const Color(0xFF38A169)
                                : const Color(0xFFF6D4A0),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            l,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isPlaced
                                  ? const Color(0xFF22543D)
                                  : const Color(0xFFB7791F),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                Text(
                  isComplete
                      ? (isGl
                          ? 'Palabra montada na mesa!'
                          : '¡Palabra montada en la mesa!')
                      : (isGl
                          ? 'Toca as letras que a crianza coloque na mesa'
                          : 'Toca las letras que la criatura coloque en la mesa'),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color:
                        isComplete ? Colors.green[700] : AppTheme.textSecondary,
                  ),
                ),
                const Divider(height: 28),

                // Fonemas articulados
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.record_voice_over_rounded,
                        size: 16, color: AppTheme.primaryVigoBlue),
                    const SizedBox(width: 6),
                    // Flexible: cinco fonemas nunha palabra longa non caben
                    // nunha fila de 400 px, e un `Text` espido nun `Row` non
                    // se pode encoller.
                    Flexible(
                      child: Text(
                        'Fonemas: ${phonemes.join("  +  ")}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryVigoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Materiais recomendados e reto TPR
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.extension_outlined,
                              size: 14, color: Color(0xFF4A5568)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Material físico: ${item.material.resolve(_language)}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.directions_run_rounded,
                              size: 14, color: Color(0xFF4A5568)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Acción corporal: ${item.tpr.resolve(_language)}',
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _buildSelector1Tap(item.id, obs, isGl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- TAB 3: CUBOS CVC (PHONICUBES) ---
  Widget _buildTabCubosCvc(bool isGl) {
    final cubos = _contido!.cubosCvc;
    final item = cubos[_cvcIndex % cubos.length];
    final obs = _observacions[item.id];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'Phonicubes: bloques físicos de Consonante-Vocal-Consonante. A crianza xunta fisicamente tres tacos de madeira e o adulto pronuncia a síntese acústica inmediata.'
              : 'Phonicubes: bloques físicos de Consonante-Vocal-Consonante. La criatura junta físicamente tres tacos de madera y el adulto pronuncia la síntesis acústica inmediata.',
        ),
        const SizedBox(height: 14),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cubo CVC ${_cvcIndex + 1} / ${cubos.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        setState(
                            () => _cvcIndex = (_cvcIndex + 1) % cubos.length);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Tres Cubos CVC Visuais
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCvcCube(item.c1, 'C', const Color(0xFF2B6CB0)),
                    const SizedBox(width: 8),
                    _buildCvcCube(item.v, 'V', const Color(0xFFC53030)),
                    const SizedBox(width: 8),
                    _buildCvcCube(item.c2, 'C', const Color(0xFF276749)),
                  ],
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        '${item.rotulo(_language)} · ${item.ipa}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // O rótulo vai en MAIÚSCULAS; ao audio vai a forma
                    // natural, que é a que ten gravación. E a lingua sae de se
                    // a palabra é inglesa ou unha sílaba transparente, non de
                    // buscar «pan» ou «sol» dentro do id.
                    BotonEscuchar(
                      audioService: widget.audioService,
                      texto: item.textoAudio(_language),
                      language: item.esIngles ? AppLanguage.en : _language,
                      style: VoiceStyle.slow,
                      compacto: true,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.significado.resolve(_language),
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary),
                ),
                const Divider(height: 24),

                Text(
                  item.consigna.resolve(_language),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Materiais suxeridos: ${item.material.resolve(_language)}',
                  textAlign: TextAlign.center,
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF718096)),
                ),
                const SizedBox(height: 16),
                _buildSelector1Tap(item.id, obs, isGl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCvcCube(String letter, String role, Color color) {
    return Container(
      width: 64,
      height: 70,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            role,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          Text(
            letter,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // --- TAB 4: PARES MÍNIMOS ---
  Widget _buildTabParesMinimos(bool isGl) {
    final pares = _contido!.paresMinimos;
    final item = pares[_paresIndex % pares.length];
    final obs = _observacions[item.id];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildGarantiaZeroScreen(
          isGl
              ? 'Pares Mínimos: adestramento de discriminación auditiva fina. O adulto oculta a boca cunha folla para que a crianza distinga o son exclusivamente polo oído.'
              : 'Pares Mínimos: entrenamiento de discriminación auditiva fina. El adulto oculta la boca con una hoja para que la criatura distinga el sonido exclusivamente por el oído.',
        ),
        const SizedBox(height: 14),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppTheme.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.par,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryVigoBlue,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded),
                      onPressed: () {
                        setState(() =>
                            _paresIndex = (_paresIndex + 1) % pares.length);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.contraste.resolve(_language),
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
                const Divider(height: 24),

                // Dúas tarxetas físicas de contraste
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEBF8FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF90CDF4)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.palabra1En,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2B6CB0),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                BotonEscuchar(
                                  audioService: widget.audioService,
                                  texto: item.palabra1En,
                                  language: AppLanguage.en,
                                  style: VoiceStyle.slow,
                                  compacto: true,
                                ),
                              ],
                            ),
                            Text(
                              item.palabra1.resolve(_language),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('vs',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFEB2B2)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.palabra2En,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC53030),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                BotonEscuchar(
                                  audioService: widget.audioService,
                                  texto: item.palabra2En,
                                  language: AppLanguage.en,
                                  style: VoiceStyle.slow,
                                  compacto: true,
                                ),
                              ],
                            ),
                            Text(
                              item.palabra2.resolve(_language),
                              style: const TextStyle(
                                  fontSize: 11, color: Color(0xFF4A5568)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Instrución de facilitación
                Text(
                  item.instrucion.resolve(_language),
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF2D3748), height: 1.4),
                ),
                const SizedBox(height: 16),
                _buildSelector1Tap(item.id, obs, isGl),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGarantiaZeroScreen(String texto) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF6D4A0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: Color(0xFFDD6B20), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF7B341E), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector1Tap(String id, String? estadoActual, bool isGl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      // Wrap e non Row: a etiqueta máis os tres botóns desbordaban 273 px a
      // 400 de ancho. Nun teléfono os tres estados baixan á liña seguinte en
      // vez de saírse da tarxeta.
      child: Wrap(
        spacing: 6,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            isGl ? 'Rexistro:' : 'Registro:',
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary),
          ),
          _buildTapButton(
              id, 'L', '[L] Logrado', estadoActual == 'L', Colors.green, isGl),
          _buildTapButton(
              id, 'A', '[A] Asistido', estadoActual == 'A', Colors.blue, isGl),
          _buildTapButton(id, 'E', '[E] Explorando', estadoActual == 'E',
              Colors.orange, isGl),
        ],
      ),
    );
  }

  Widget _buildTapButton(String id, String val, String label, bool isSel,
      MaterialColor color, bool isGl) {
    return InkWell(
      onTap: () => setState(() => _observacions[id] = val),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSel ? color.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSel ? color.shade700 : const Color(0xFFCBD5E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isSel ? color.shade900 : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
