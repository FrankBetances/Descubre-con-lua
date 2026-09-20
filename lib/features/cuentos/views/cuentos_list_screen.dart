import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/repositories/content_repository.dart';
import 'cuento_viewer_screen.dart';

/// Catálogo y biblioteca de los 200 Contos Pedagóxicos (5 cursos × 10 meses × 4 semanas).
class CuentosListScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  const CuentosListScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
  });

  @override
  State<CuentosListScreen> createState() => _CuentosListScreenState();
}

class _CuentosListScreenState extends State<CuentosListScreen> {
  late AppLanguage _language;
  List<Cuento> _allCuentos = [];
  List<Cuento> _filteredCuentos = [];
  bool _isLoading = true;
  String _selectedCurso = 'todos';
  String _searchQuery = '';

  static const List<Map<String, String>> _cursosFiltro = [
    {'id': 'todos', 'gl': 'Todos os Cursos', 'es': 'Todos los Cursos'},
    {'id': 'curso_0_2', 'gl': '0 a 2 anos', 'es': '0 a 2 años'},
    {'id': 'curso_2_3', 'gl': '2 a 3 anos', 'es': '2 a 3 años'},
    {'id': 'curso_3_4', 'gl': '3 a 4 anos', 'es': '3 a 4 años'},
    {'id': 'curso_4_5', 'gl': '4 a 5 anos', 'es': '4 a 5 años'},
    {'id': 'curso_5_6', 'gl': '5 a 6 anos', 'es': '5 a 6 años'},
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _loadCuentos();
  }

  Future<void> _loadCuentos() async {
    setState(() => _isLoading = true);
    final cuentos = await widget.repository.loadCuentos();
    if (mounted) {
      setState(() {
        _allCuentos = cuentos;
        _applyFilters();
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    _filteredCuentos = _allCuentos.where((c) {
      final matchesCurso = _selectedCurso == 'todos' || c.cursoId == _selectedCurso;
      final matchesSearch = _searchQuery.isEmpty ||
          c.titulo.resolve(_language).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.sinopse.resolve(_language).toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCurso && matchesSearch;
    }).toList();
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
          lang == AppLanguage.gl ? 'Banco de 200 Contos' : 'Banco de 200 Cuentos',
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
                // Search Input
                TextField(
                  decoration: InputDecoration(
                    hintText: lang == AppLanguage.gl ? 'Buscar conto...' : 'Buscar cuento...',
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

                // Course Selector Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _cursosFiltro.map((c) {
                      final isSelected = _selectedCurso == c['id'];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(lang == AppLanguage.gl ? c['gl']! : c['es']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCurso = c['id']!;
                                _applyFilters();
                              });
                            }
                          },
                          selectedColor: AppTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
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
                  lang == AppLanguage.gl
                      ? '${_filteredCuentos.length} contos dispoñibles'
                      : '${_filteredCuentos.length} cuentos disponibles',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // List of Stories
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCuentos.isEmpty
                    ? Center(
                        child: Text(
                          lang == AppLanguage.gl
                              ? 'Non se atoparon contos'
                              : 'No se encontraron cuentos',
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: _filteredCuentos.length,
                        itemBuilder: (context, index) {
                          final cuento = _filteredCuentos[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 0.5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CuentoViewerScreen(
                                      cuento: cuento,
                                      language: _language,
                                      audioService: widget.audioService,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryLight,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.auto_stories,
                                        color: AppTheme.primaryDark,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            cuento.titulo.resolve(lang),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            cuento.sinopse.resolve(lang),
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.textSecondary,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 6),
                                          Row(
                                            children: [
                                              _buildBadge(
                                                'Mes ${cuento.mesNumero}',
                                                Colors.teal.shade50,
                                                Colors.teal.shade800,
                                              ),
                                              const SizedBox(width: 6),
                                              _buildBadge(
                                                'Semana ${cuento.semanaSugerida}',
                                                Colors.blue.shade50,
                                                Colors.blue.shade800,
                                              ),
                                              if (cuento.paginas.isNotEmpty) ...[
                                                const SizedBox(width: 6),
                                                _buildBadge(
                                                  '${cuento.paginas.length} páx',
                                                  Colors.grey.shade100,
                                                  Colors.grey.shade700,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.grey,
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

  Widget _buildBadge(String text, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textCol,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
