import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
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
          _palabras = results.where((p) => p.lemma.toLowerCase().contains(q)).toList();
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
                    hintText: 'Search English lemma (e.g. water, play)...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryDark),
                    filled: true,
                    fillColor: AppTheme.pageBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                          label: const Text('All Bands'),
                          selected: _selectedBanda == null,
                          onSelected: (sel) {
                            if (sel) {
                              setState(() => _selectedBanda = null);
                              _fetchPalabras();
                            }
                          },
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: _selectedBanda == null ? Colors.white : AppTheme.textPrimary,
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
                              color: isSel ? Colors.white : AppTheme.textPrimary,
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
                          label: const Text('All CEFR'),
                          selected: _selectedCefr == null,
                          onSelected: (sel) {
                            if (sel) {
                              setState(() => _selectedCefr = null);
                              _fetchPalabras();
                            }
                          },
                          selectedColor: Colors.purple.shade600,
                          labelStyle: TextStyle(
                            color: _selectedCefr == null ? Colors.white : AppTheme.textPrimary,
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
                            selectedColor: Colors.purple.shade600,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppTheme.textPrimary,
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

          // Count Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_palabras.length} words found',
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
                        itemCount: _palabras.length > 500 ? 500 : _palabras.length,
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
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: Colors.indigo.shade50,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.pos.substring(0, item.pos.length > 3 ? 3 : item.pos.length),
                                        style: TextStyle(
                                          color: Colors.indigo.shade800,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                          'Band: ${item.banda} · Zipf: ${item.zipfScore.toStringAsFixed(1)}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      item.nivelCefr,
                                      style: TextStyle(
                                        color: Colors.purple.shade800,
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
