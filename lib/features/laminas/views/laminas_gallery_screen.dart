import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/lamina_model.dart';
import '../../../data/repositories/content_repository.dart';
import 'lamina_detail_screen.dart';

/// Galería y catálogo de las 200+ Láminas Didácticas Ilustradas.
class LaminasGalleryScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const LaminasGalleryScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<LaminasGalleryScreen> createState() => _LaminasGalleryScreenState();
}

class _LaminasGalleryScreenState extends State<LaminasGalleryScreen> {
  late AppLanguage _language;
  List<Lamina> _allLaminas = [];
  List<Lamina> _filteredLaminas = [];
  bool _isLoading = true;
  String _selectedCategoria = 'todas';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _loadLaminas();
  }

  Future<void> _loadLaminas() async {
    setState(() => _isLoading = true);
    final laminas = await widget.repository.loadLaminas();
    if (mounted) {
      setState(() {
        _allLaminas = laminas;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredLaminas = _allLaminas.where((l) {
      final matchesCat = _selectedCategoria == 'todas' || l.categoria == _selectedCategoria;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          l.gl.toLowerCase().contains(query) ||
          l.es.toLowerCase().contains(query) ||
          l.en.toLowerCase().contains(query);
      return matchesCat && matchesSearch;
    }).toList();
  }

  List<String> get _categoriasDisponibles {
    final set = <String>{'todas'};
    for (final l in _allLaminas) {
      set.add(l.categoria);
    }
    return set.toList();
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
          lang == AppLanguage.gl ? 'Banco de 200 Láminas' : 'Banco de 200 Láminas',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: lang == AppLanguage.gl ? 'Buscar lámina...' : 'Buscar lámina...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.primaryDark),
                    filled: true,
                    fillColor: AppTheme.pageBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _applyFilters();
                    });
                  },
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categoriasDisponibles.map((cat) {
                      final isSelected = _selectedCategoria == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoria = cat;
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lang == AppLanguage.gl
                      ? '${_filteredLaminas.length} láminas dispoñibles'
                      : '${_filteredLaminas.length} láminas disponibles',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Grid of Cards
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredLaminas.isEmpty
                    ? Center(
                        child: Text(
                          lang == AppLanguage.gl
                              ? 'Non se atoparon láminas'
                              : 'No se encontraron láminas',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.85,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _filteredLaminas.length,
                        itemBuilder: (context, index) {
                          final lamina = _filteredLaminas[index];
                          return Card(
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => LaminaDetailScreen(
                                      lamina: lamina,
                                      language: _language,
                                      audioService: widget.audioService,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (lamina.simbolo != null && lamina.simbolo!.isNotEmpty)
                                      Text(
                                        lamina.simbolo!,
                                        style: const TextStyle(fontSize: 36),
                                      )
                                    else
                                      const Icon(
                                        Icons.photo_library,
                                        size: 36,
                                        color: AppTheme.primaryDark,
                                      ),
                                    const SizedBox(height: 8),
                                    Text(
                                      lang == AppLanguage.gl ? lamina.gl : lamina.es,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: AppTheme.textPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      lamina.en,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.indigo.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.purple.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        lamina.cefr,
                                        style: TextStyle(
                                          color: Colors.purple.shade700,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
