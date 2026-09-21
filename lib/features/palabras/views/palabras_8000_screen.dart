import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/corpus_palabra_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Explorador del corpus de 8.000 palabras BNC/COCA.
///
/// **Qué se ve en cada tarjeta y por qué.** La palabra, su categoría
/// gramatical, su frecuencia medida, la definición y UNA FRASE ENTERA. Y dos
/// altavoces: uno para la palabra sola, despacio, que es lo que se imita; otro
/// para la frase, a ritmo de tutor, que es lo que se entiende. Las dos
/// grabaciones existen para las 7.998 palabras, así que el altavoz no
/// desaparece a mitad de la lista.
///
/// **De dónde salen los datos.** De `assets/content/corpus/`, que escribe
/// `tools/build_corpus_8000.py` con WordNet y wordfreq. El nivel se deriva de
/// la banda de frecuencia y la pantalla lo dice: no es MCER oficial.
class Palabras8000Screen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const Palabras8000Screen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<Palabras8000Screen> createState() => _Palabras8000ScreenState();
}

/// Un filtro de categoría gramatical, con su etiqueta en las dos lenguas.
class _FiltroPos {
  final String? pos;
  final bool onomatopeia;
  final String gl;
  final String es;

  const _FiltroPos(this.pos, this.gl, this.es, {this.onomatopeia = false});
}

class _Palabras8000ScreenState extends State<Palabras8000Screen> {
  late AppLanguage _language;
  List<CorpusPalabra> _palabras = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedBanda;
  String? _selectedCefr;
  int _filtroPos = 0;

  static const List<int> _bandas = [1, 2, 3, 4, 5, 6, 7, 8];

  // Los niveles que el fichero trae DE VERDAD. Antes esta lista decía
  // «A1/A2, B1, B2, C1/C2» y tres de las cuatro pastillas no encontraban
  // ninguna palabra: el corpus nunca tuvo un nivel llamado «B1» a secas.
  static const List<String> _nivelesCefr = [
    'A1/A2',
    'A2/B1',
    'B1/B2',
    'B2',
    'C1',
    'C1+',
  ];

  static const List<_FiltroPos> _filtrosPos = [
    _FiltroPos(null, 'Todas', 'Todas'),
    _FiltroPos('NOUN', 'Substantivos', 'Sustantivos'),
    _FiltroPos('VERB', 'Verbos', 'Verbos'),
    _FiltroPos('ADJ', 'Adxectivos', 'Adjetivos'),
    _FiltroPos('ADV', 'Adverbios', 'Adverbios'),
    _FiltroPos(null, 'Onomatopeas', 'Onomatopeyas', onomatopeia: true),
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _fetchPalabras();
  }

  Future<void> _fetchPalabras() async {
    setState(() => _isLoading = true);
    final filtro = _filtrosPos[_filtroPos];
    final results = await widget.repository.loadCorpusPalabras(
      banda: _selectedBanda,
      cefr: _selectedCefr,
      pos: filtro.pos,
      soloOnomatopeias: filtro.onomatopeia,
    );

    if (mounted) {
      setState(() {
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          _palabras = results
              .where((p) =>
                  p.lemma.toLowerCase().contains(q) ||
                  p.frase.toLowerCase().contains(q))
              .toList();
        } else {
          _palabras = results;
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _fetchPalabras();
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: const Text(
          'Corpus 8.000 Palabras',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: isGl
                        ? 'Buscar na palabra ou na frase…'
                        : 'Buscar en la palabra o en la frase…',
                    prefixIcon:
                        const Icon(Icons.search, color: AppTheme.primaryDark),
                    filled: true,
                    fillColor: AppTheme.pageBg,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
                const SizedBox(height: 10),

                // Categoría gramatical. Es el primer filtro porque es el que
                // Frank pidió: sustantivos, verbos, adverbios y onomatopeyas.
                _TiraDeFiltros(
                  children: [
                    for (var i = 0; i < _filtrosPos.length; i++)
                      _Pastilla(
                        etiqueta: isGl ? _filtrosPos[i].gl : _filtrosPos[i].es,
                        activa: _filtroPos == i,
                        color: AppTheme.primaryDark,
                        onTap: () {
                          setState(() => _filtroPos = i);
                          _fetchPalabras();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                _TiraDeFiltros(
                  children: [
                    _Pastilla(
                      etiqueta: isGl ? 'Todas as bandas' : 'Todas las bandas',
                      activa: _selectedBanda == null,
                      color: AppTheme.primary,
                      onTap: () {
                        setState(() => _selectedBanda = null);
                        _fetchPalabras();
                      },
                    ),
                    for (final b in _bandas)
                      _Pastilla(
                        etiqueta: '${b}k',
                        activa: _selectedBanda == b,
                        color: AppTheme.primary,
                        onTap: () {
                          setState(() =>
                              _selectedBanda = _selectedBanda == b ? null : b);
                          _fetchPalabras();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                _TiraDeFiltros(
                  children: [
                    _Pastilla(
                      etiqueta: isGl ? 'Todos os niveis' : 'Todos los niveles',
                      activa: _selectedCefr == null,
                      color: AppTheme.primaryDark,
                      onTap: () {
                        setState(() => _selectedCefr = null);
                        _fetchPalabras();
                      },
                    ),
                    for (final c in _nivelesCefr)
                      _Pastilla(
                        etiqueta: c,
                        activa: _selectedCefr == c,
                        color: AppTheme.primaryDark,
                        onTap: () {
                          setState(() =>
                              _selectedCefr = _selectedCefr == c ? null : c);
                          _fetchPalabras();
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),

          // De dónde sale el nivel. Sin esta línea, la etiqueta «A1/A2» se lee
          // como una clasificación CEFR oficial, y no lo es: sale de la banda
          // de frecuencia, en bloques de mil.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Text(
              isGl
                  ? 'O nivel oriéntase pola banda de frecuencia (as mil primeiras '
                      'palabras, A1/A2; as mil seguintes, A2/B1…). Non é unha '
                      'clasificación oficial do MCER. A categoría gramatical sae '
                      'de WordNet e a frecuencia, de wordfreq.'
                  : 'El nivel se orienta por la banda de frecuencia (las mil primeras '
                      'palabras, A1/A2; las mil siguientes, A2/B1…). No es una '
                      'clasificación oficial del MCER. La categoría gramatical sale '
                      'de WordNet y la frecuencia, de wordfreq.',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.35,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${_palabras.length} ${isGl ? "palabras" : "palabras"}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _palabras.isEmpty
                    ? Center(
                        child: Text(
                          isGl
                              ? 'Ningunha palabra con eses filtros.'
                              : 'Ninguna palabra con esos filtros.',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _palabras.length,
                        itemBuilder: (context, index) => _TarxetaDePalabra(
                          palabra: _palabras[index],
                          language: _language,
                          audioService: widget.audioService,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

/// Una tira horizontal de pastillas de filtro.
class _TiraDeFiltros extends StatelessWidget {
  final List<Widget> children;

  const _TiraDeFiltros({required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final hijo in children)
            Padding(padding: const EdgeInsets.only(right: 6), child: hijo),
        ],
      ),
    );
  }
}

class _Pastilla extends StatelessWidget {
  final String etiqueta;
  final bool activa;
  final Color color;
  final VoidCallback onTap;

  const _Pastilla({
    required this.etiqueta,
    required this.activa,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(etiqueta),
      selected: activa,
      onSelected: (_) => onTap(),
      selectedColor: color,
      labelStyle: TextStyle(
        color: activa ? Colors.white : AppTheme.textPrimary,
        fontSize: 11,
        fontWeight: activa ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}

/// La palabra, lo que es, lo que significa, y una frase que se puede oír.
class _TarxetaDePalabra extends StatelessWidget {
  final CorpusPalabra palabra;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const _TarxetaDePalabra({
    required this.palabra,
    required this.language,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      palabra.banda,
                      style: const TextStyle(
                        color: AppTheme.primaryInk,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        palabra.lemma,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (palabra.pos.isNotEmpty)
                            _Etiqueta(
                              texto: palabra.posEtiqueta(galego: isGl),
                              fondo: AppTheme.primaryTint,
                              tinta: AppTheme.primaryDark,
                            ),
                          if (palabra.onomatopeya)
                            _Etiqueta(
                              texto: isGl ? 'Onomatopea' : 'Onomatopeya',
                              fondo: AppTheme.successBg,
                              tinta: AppTheme.primaryInk,
                            ),
                          _Etiqueta(
                            texto: palabra.nivelCefr,
                            fondo: AppTheme.pageBg,
                            tinta: AppTheme.textSecondary,
                          ),
                          if (palabra.zipf > 0)
                            _Etiqueta(
                              texto: 'Zipf ${palabra.zipf.toStringAsFixed(2)}',
                              fondo: AppTheme.pageBg,
                              tinta: AppTheme.textSecondary,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // La palabra sola, despacio: es la que se imita.
                BotonEscuchar(
                  audioService: audioService,
                  texto: palabra.lemma,
                  language: AppLanguage.en,
                  style: estiloIngles(palabra.lemma),
                  compacto: true,
                  descripcion: palabra.lemma,
                ),
              ],
            ),
            if (palabra.definicion.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                palabra.definicion,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
            if (palabra.frase.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(AppTheme.spaceSm),
                decoration: BoxDecoration(
                  color: AppTheme.pageBg,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        palabra.frase,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textPrimary,
                          height: 1.4,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    // La frase entera, a ritmo de tutor: es la que se
                    // entiende y la que enseña a comunicarse.
                    BotonEscuchar(
                      audioService: audioService,
                      texto: palabra.frase,
                      language: AppLanguage.en,
                      style: VoiceStyle.tutor,
                      compacto: true,
                      descripcion: palabra.frase,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color tinta;

  const _Etiqueta({
    required this.texto,
    required this.fondo,
    required this.tinta,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: tinta,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
