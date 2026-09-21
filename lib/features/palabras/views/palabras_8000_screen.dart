import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/corpus_palabra_model.dart';
import '../../../data/repositories/content_repository.dart';

/// Explorador del Corpus de 8.000 Palabras BNC/COCA con mapeo CEFR.
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

class _Palabras8000ScreenState extends State<Palabras8000Screen> {
  late AppLanguage _language;
  List<CorpusPalabra> _palabras = [];
  bool _isLoading = true;
  String _searchQuery = '';
  int? _selectedBanda;
  String? _selectedCefr;

  static const List<int> _bandas = [1, 2, 3, 4, 5, 6, 7, 8];
  static const List<String> _nivelesCefr = ['A1/A2', 'B1', 'B2', 'C1/C2'];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _fetchPalabras();
  }

  Future<void> _fetchPalabras() async {
    setState(() => _isLoading = true);
    final results = await widget.repository.loadCorpusPalabras(
      banda: _selectedBanda,
      cefr: _selectedCefr,
    );

    if (mounted) {
      setState(() {
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          _palabras =
              results.where((p) => p.lemma.toLowerCase().contains(q)).toList();
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
    final lang = _language;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Corpus 8.000 Palabras'
              : 'Corpus 8.000 Palabras',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Input
                TextField(
                  decoration: InputDecoration(
                    hintText: lang == AppLanguage.gl
                        ? 'Buscar palabra inglesa (auga: water)...'
                        : 'Buscar palabra inglesa (agua: water)...',
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
                const SizedBox(height: 12),

                // Band Chips (1k..8k)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(lang == AppLanguage.gl
                              ? 'Todas as bandas'
                              : 'Todas las bandas'),
                          selected: _selectedBanda == null,
                          onSelected: (sel) {
                            if (sel) {
                              setState(() => _selectedBanda = null);
                              _fetchPalabras();
                            }
                          },
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: _selectedBanda == null
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      ..._bandas.map((b) {
                        final isSel = _selectedBanda == b;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text('${b}k'),
                            selected: isSel,
                            onSelected: (sel) {
                              setState(() => _selectedBanda = sel ? b : null);
                              _fetchPalabras();
                            },
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color:
                                  isSel ? Colors.white : AppTheme.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // CEFR Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(lang == AppLanguage.gl
                              ? 'Todos os niveis'
                              : 'Todos los niveles'),
                          selected: _selectedCefr == null,
                          onSelected: (sel) {
                            if (sel) {
                              setState(() => _selectedCefr = null);
                              _fetchPalabras();
                            }
                          },
                          selectedColor: AppTheme.primaryDark,
                          labelStyle: TextStyle(
                            color: _selectedCefr == null
                                ? Colors.white
                                : AppTheme.textPrimary,
                            fontSize: 11,
                          ),
                        ),
                      ),
                      ..._nivelesCefr.map((c) {
                        final isSel = _selectedCefr == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: isSel,
                            onSelected: (sel) {
                              setState(() => _selectedCefr = sel ? c : null);
                              _fetchPalabras();
                            },
                            selectedColor: AppTheme.primaryDark,
                            labelStyle: TextStyle(
                              color:
                                  isSel ? Colors.white : AppTheme.textPrimary,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // De dónde sale el nivel. Sin esta línea, la etiqueta «A1/A2» se lee
          // como una clasificación CEFR oficial, y no lo es: sale de la banda
          // de frecuencia, en bloques de mil.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              lang == AppLanguage.gl
                  ? 'O nivel oriéntase pola banda de frecuencia (as mil primeiras '
                      'palabras, A1/A2; as mil seguintes, A2/B1…). Non é unha '
                      'clasificación oficial do MCER. O altavoz sae nas '
                      'palabras que a app ensina noutras pantallas: esta é unha '
                      'lista para explorar, non para dicir enteira.'
                  : 'El nivel se orienta por la banda de frecuencia (las mil primeras '
                      'palabras, A1/A2; las mil siguientes, A2/B1…). No es una '
                      'clasificación oficial del MCER. El altavoz sale en las '
                      'palabras que la app enseña en otras pantallas: esta es una '
                      'lista para explorar, no para decirla entera.',
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                height: 1.35,
              ),
            ),
          ),

          // Count Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == AppLanguage.gl
                      ? '${_palabras.length} palabras'
                      : '${_palabras.length} palabras',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // List of Words
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _palabras.isEmpty
                    ? const Center(
                        child: Text(
                          'No words match current filters',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount:
                            _palabras.length > 500 ? 500 : _palabras.length,
                        itemBuilder: (context, index) {
                          final item = _palabras[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              child: Row(
                                children: [
                                  // Aquí iba la categoría gramatical, y estaba
                                  // inventada: 6.206 de las 8.000 palabras
                                  // venían etiquetadas «NOUN». Ahora va la
                                  // banda, que es el dato que la lista trae de
                                  // verdad.
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryLight,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.banda,
                                        style: const TextStyle(
                                          color: AppTheme.primaryInk,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.lemma,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          lang == AppLanguage.gl
                                              ? 'Banda de frecuencia ${item.banda}'
                                              : 'Banda de frecuencia ${item.banda}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // El altavoz solo aparece si la grabación
                                  // existe: `BotonEscuchar` no se pinta apagado
                                  // ni con un aviso. De estas 8.000 palabras
                                  // suenan las que la app ENSEÑA de verdad en
                                  // el resto de pantallas; el explorador no las
                                  // graba todas a propósito (ver la nota de
                                  // arriba y tools/voice_corpus.py).
                                  BotonEscuchar(
                                    audioService: widget.audioService,
                                    texto: item.lemma,
                                    language: AppLanguage.en,
                                    style: estiloIngles(item.lemma),
                                    compacto: true,
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryTint,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.nivelCefr,
                                      style: const TextStyle(
                                        color: AppTheme.primaryDark,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
