import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/repositories/content_repository.dart';
import 'cuento_viewer_screen.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/widgets/cabecera.dart';

/// Catálogo y biblioteca de los contos pedagóxicos (5 cursos × 10 meses × 4
/// semanas). El número de contos NO se escribe en el rótulo: lo cuenta la
/// propia pantalla a partir de lo que hay cargado, para que no pueda mentir.
class CuentosListScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// La edad con la que se abre (`curso_0_2`…). Sin ella, todas.
  final String? initialCursoId;

  /// El cuento de esta semana va el primero: la biblioteca se abre por él.
  /// [mes] es el del curso (1 es septiembre).
  final ({int mes, int semana})? semanaDestacada;

  const CuentosListScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
    this.initialCursoId,
    this.semanaDestacada,
  });

  @override
  State<CuentosListScreen> createState() => _CuentosListScreenState();
}

class _CuentosListScreenState extends State<CuentosListScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language;
  List<Cuento> _allCuentos = [];
  List<Cuento> _filteredCuentos = [];
  bool _isLoading = true;
  late String _selectedCurso = widget.initialCursoId ?? 'todos';
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
      final matchesCurso =
          _selectedCurso == 'todos' || c.cursoId == _selectedCurso;
      final matchesSearch = _searchQuery.isEmpty ||
          c.titulo
              .resolve(_language)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          c.sinopse
              .resolve(_language)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesCurso && matchesSearch;
    }).toList();
    // El de esta semana, delante; el resto, en su orden.
    final d = widget.semanaDestacada;
    if (d != null) {
      final i = _filteredCuentos.indexWhere(
          (c) => c.mesNumero == d.mes && c.semanaSugerida == d.semana);
      if (i > 0) _filteredCuentos.insert(0, _filteredCuentos.removeAt(i));
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: lang == AppLanguage.gl ? 'Contos' : 'Cuentos',
        language: _language,
        onLanguageChanged: _cambiarLingua,
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
                    hintText: lang == AppLanguage.gl
                        ? 'Buscar conto...'
                        : 'Buscar cuento...',
                    prefixIcon:
                        Icon(Icons.search_rounded, color: context.acento),
                    filled: true,
                    fillColor: AppTheme.pageBg,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
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
                          label: Text(
                              lang == AppLanguage.gl ? c['gl']! : c['es']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCurso = c['id']!;
                                _applyFilters();
                              });
                            }
                          },
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
                                  RutaLua(
                                    de: context,
                                    builder: (_) => CuentoViewerScreen(
                                      onLanguageChanged: _cambiarLingua,
                                      cuento: cuento,
                                      language: _language,
                                      audioService: widget.audioService,
                                      // Desde la biblioteca no hay «hoy»:
                                      // van las veinte de la semana.
                                      semanaTpr: switch (
                                          cuento.semanaSugerida) {
                                        final semana? => widget.repository
                                            .cursoTprSync(cuento.cursoId)
                                            ?.semanaPorOrden(
                                                cuento.mesNumero, semana),
                                        null => null,
                                      },
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
                                        color: context.acentoTint,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(
                                        Icons.auto_stories_rounded,
                                        color: context.acento,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                                          // El curso va PRIMERO y siempre. El
                                          // mismo título se repite a propósito
                                          // en los cinco cursos —es la misma
                                          // asamblea contada para cada edad—,
                                          // así que sin esta etiqueta la lista
                                          // parecía llena de filas repetidas.
                                          Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: [
                                              _buildBadge(
                                                _etiquetaCurso(
                                                    cuento.cursoId, lang),
                                                context.acentoTint,
                                                context.acento,
                                              ),
                                              // El mes por su nombre: «Mes 2»
                                              // obligaba a contar.
                                              _buildBadge(
                                                nomeDoMes[cuento.mesCalendario]
                                                        ?.resolve(lang) ??
                                                    '',
                                                context.acentoTint,
                                                context.acento,
                                              ),
                                              // La semana, solo en el cuento
                                              // DE la semana, y dicho así:
                                              // antes los que no son de
                                              // ninguna llevaban también
                                              // «Semana 1».
                                              if (cuento.semanaSugerida
                                                  case final semana?)
                                                _buildBadge(
                                                  cuento.levaPalabras
                                                      ? (lang == AppLanguage.gl
                                                          ? 'Conto da semana $semana'
                                                          : 'Cuento de la semana $semana')
                                                      : (lang == AppLanguage.gl
                                                          ? 'Semana $semana'
                                                          : 'Semana $semana'),
                                                  // Blanco sobre primaryInk:
                                                  // 5,16:1 (AA).
                                                  cuento.levaPalabras
                                                      ? context.acento
                                                      : context.acentoTint,
                                                  cuento.levaPalabras
                                                      ? Colors.white
                                                      : context.acento,
                                                ),
                                              if (cuento.paginas.isNotEmpty)
                                                _buildBadge(
                                                  lang == AppLanguage.gl
                                                      ? '${cuento.paginas.length} páx'
                                                      : '${cuento.paginas.length} pág',
                                                  AppTheme.pageBg,
                                                  AppTheme.textSecondary,
                                                ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: AppTheme.textMuted,
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

  /// La misma etiqueta que usan los filtros de arriba, para que la fila y el
  /// filtro hablen igual.
  String _etiquetaCurso(String cursoId, AppLanguage lang) {
    for (final curso in _cursosFiltro) {
      if (curso['id'] == cursoId) {
        return (lang == AppLanguage.gl ? curso['gl'] : curso['es'])!;
      }
    }
    return cursoId;
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
