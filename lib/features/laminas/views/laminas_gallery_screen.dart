import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/lamina_model.dart';
import '../../../data/repositories/content_repository.dart';
import 'lamina_detail_screen.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/widgets/cabecera.dart';
import '../nome_categoria.dart';
import '../../familias/nomes_familias.dart';

/// Galería y catálogo de las 200+ Láminas Didácticas Ilustradas.
class LaminasGalleryScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  const LaminasGalleryScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
  });

  @override
  State<LaminasGalleryScreen> createState() => _LaminasGalleryScreenState();
}

class _LaminasGalleryScreenState extends State<LaminasGalleryScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

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
      final matchesCat =
          _selectedCategoria == 'todas' || l.categoria == _selectedCategoria;
      final query = _searchQuery.toLowerCase();
      final matchesSearch = query.isEmpty ||
          l.gl.toLowerCase().contains(query) ||
          l.es.toLowerCase().contains(query) ||
          l.en.toLowerCase().contains(query);
      return matchesCat && matchesSearch;
    }).toList();
  }

  /// El nombre de la categoría en la lengua de la interfaz. La clave que trae
  /// el banco —`vigo_natureza`, `escola_rutinas`— es de máquina y se enseñaba
  /// tal cual, con guion bajo y en gallego para los dos idiomas.
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
      appBar: Cabecera(
        titulo: NomesFamilias.laminas.resolve(lang),
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
                TextField(
                  decoration: InputDecoration(
                    hintText: lang == AppLanguage.gl
                        ? 'Buscar lámina...'
                        : 'Buscar lámina...',
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
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categoriasDisponibles.map((cat) {
                      final isSelected = _selectedCategoria == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(nomeCategoria(cat, lang).toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedCategoria = cat;
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

          // Cuántas hay. Sin Row: un Row con un solo texto no lo deja bajar de
          // línea, y con la letra grande del sistema desbordaba 168 px.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                lang == AppLanguage.gl
                    ? '${_filteredLaminas.length} láminas dispoñibles'
                    : '${_filteredLaminas.length} láminas disponibles',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
                    // Filas de dos y no una rejilla de proporción fija: con la
                    // proporción fija cada tarjeta desbordaba 22 px por abajo
                    // y, en un APK de producción, el texto simplemente se
                    // cortaba. Así cada fila mide lo que pide su tarjeta más
                    // alta.
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        itemCount: (_filteredLaminas.length + 1) ~/ 2,
                        itemBuilder: (context, fila) {
                          final i = fila * 2;
                          final segunda = i + 1 < _filteredLaminas.length
                              ? _filteredLaminas[i + 1]
                              : null;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: _tarxeta(
                                        context, _filteredLaminas[i], lang),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: segunda == null
                                        ? const SizedBox.shrink()
                                        : _tarxeta(context, segunda, lang),
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

  Widget _tarxeta(BuildContext context, Lamina lamina, AppLanguage lang) {
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
            RutaLua(
              de: context,
              builder: (_) => LaminaDetailScreen(
                onLanguageChanged: _cambiarLingua,
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
              // La lámina, dibujada. Las 205 tienen una:
              // 88 reutilizan un dibujo del repositorio y
              // el resto son tarjeta tipográfica, todas
              // en el mismo formato vectorial.
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LaminaEscena(
                  clave: lamina.lamina,
                  ancho: 92,
                  mentres: Icon(
                    Icons.photo_library_rounded,
                    size: 36,
                    color: context.acento,
                  ),
                ),
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
                // Hasta tres líneas: títulos como «O conto da lúa chea que
                // vixía o sono» no caben en una, y antes se cortaban.
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                lamina.en,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: context.acento,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.acentoTint,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  lamina.cefr,
                  style: TextStyle(
                    color: context.acento,
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
  }
}
