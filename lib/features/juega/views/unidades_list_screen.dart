import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../../premios/widgets/lua_game_strip.dart';
import 'asamblea_guiada_screen.dart';
import 'capsulas_aula_screen.dart';
import '../../../core/storage/calendario_store.dart';
import '../../calendario/views/calendario_screen.dart';

/// Screen listing pedagogical units for early childhood educators («Juega con Lúa · Aula»).
///
/// Features:
/// - Age band filtering tabs: 'Todas', '0-2 anos', '2-3 anos'.
/// - Thematic unit cards with curricular alignment badges (Decreto 150/2022).
/// - Launching the 6-step guided assembly mode.
/// - Dynamic bilingual language toggle (`gl`/`es`).
/// - Strict teacher focus: Sober Material 3 UI, zero child-distracting animations or games.
class UnidadesListScreen extends StatefulWidget {
  final ContentRepository repository;
  final OfflineAudioService? audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Opcional: sin él no se pinta la tira de juego ni cuentan las asambleas.
  final PremiosRepository? premios;

  /// Opcional: para sincronizar asambleas realizadas con o calendario escola-fogar.
  final CalendarioStore? calendario;

  const UnidadesListScreen({
    super.key,
    required this.repository,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
  });

  @override
  State<UnidadesListScreen> createState() => _UnidadesListScreenState();
}

class _UnidadesListScreenState extends State<UnidadesListScreen> {
  late AppLanguage _language;
  String _selectedAgeFilter = 'todas'; // 'todas', '0-2', '2-3'

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  List<Unidad> _getFilteredUnits() {
    if (_selectedAgeFilter == 'todas') {
      return widget.repository.getAllUnidades();
    }
    return widget.repository.getUnidadesByTramoEtario(_selectedAgeFilter);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = _language == AppLanguage.gl;
    final unidades = _getFilteredUnits();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGl ? 'Juega con Lúa · Aula' : 'Juega con Lúa · Aula',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // La tira de juego, arriba del todo: Lúa, el nivel de la maestra y
            // su racha. Es lo primero que ve al entrar en el aula.
            if (widget.premios != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spaceLg,
                  AppTheme.spaceMd,
                  AppTheme.spaceLg,
                  0,
                ),
                child: LuaGameStrip(
                  repository: widget.premios!,
                  perfil: Perfil.docente,
                  language: _language,
                ),
              ),

            // La puerta a la formación docente. Va arriba y no escondida en un
            // menú: una maestra que abre el aula con dos minutos de margen
            // tiene que poder leer el paso que le toca sin buscarlo.
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceLg,
                AppTheme.spaceMd,
                AppTheme.spaceLg,
                0,
              ),
              child: ElevatedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CalendarioScreen(
                      store: widget.calendario ?? CalendarioStore(),
                      initialLanguage: _language,
                      onLanguageChanged: _onToggleLanguage,
                      esDocenteInicial: true,
                      repository: widget.repository,
                      audioService: widget.audioService,
                      premios: widget.premios,
                    ),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_rounded),
                label: Text(
                  isGl
                      ? 'Calendario Escola · Fogar (Dobre Estimulación)'
                      : 'Calendario Escuela · Hogar (Doble Estimulación)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryVigoBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(AppTheme.touchMin),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceLg,
                AppTheme.spaceSm,
                AppTheme.spaceLg,
                0,
              ),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CapsulasAulaScreen(
                      repository: widget.repository,
                      initialLanguage: _language,
                      onLanguageChanged: _onToggleLanguage,
                      premios: widget.premios,
                      audioService: widget.audioService,
                    ),
                  ),
                ),
                icon: const Icon(Icons.menu_book_outlined),
                label: Text(
                  isGl
                      ? 'Formación: os seis pasos da asemblea'
                      : 'Formación: los seis pasos de la asamblea',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(AppTheme.touchMin),
                ),
              ),
            ),

            // Age band filter bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              color: AppTheme.cardSurface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGl
                        ? 'Filtrar por tramo etario:'
                        : 'Filtrar por tramo de edad:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Wrap y no Row: con tres `Expanded` cada chip se llevaba un
                  // tercio exacto del ancho, y «Todas las edades» no cabe en un
                  // tercio. Se veía «Todas las edade», cortado, SOLO en
                  // castellano —en galego «Todas as idades» sí cabía—, y ningún
                  // test lo cazó porque un chip recorta en vez de desbordar: no
                  // hay franjas amarillas ni excepción, el texto se corta y ya.
                  //
                  // Con Wrap cada chip ocupa lo que mide su texto y baja de
                  // línea cuando no caben. Deja de depender del ancho de la
                  // pantalla, de la lengua y de la escala de texto del sistema.
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: isGl ? 'Todas as idades' : 'Todas las edades',
                        filterKey: 'todas',
                      ),
                      _buildFilterChip(
                        label: isGl ? '0-2 anos' : '0-2 años',
                        filterKey: '0-2',
                      ),
                      _buildFilterChip(
                        label: isGl ? '2-3 anos' : '2-3 años',
                        filterKey: '2-3',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Units List View
            Expanded(
              child: unidades.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          isGl
                              ? 'Non se atoparon unidades para este tramo de idade.'
                              : 'No se encontraron unidades para este tramo de edad.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20.0),
                      itemCount: unidades.length,
                      itemBuilder: (context, index) {
                        final unidad = unidades[index];
                        return _buildUnidadCard(context, unidad, isGl);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String filterKey,
  }) {
    final isSelected = _selectedAgeFilter == filterKey;

    // Sin Expanded ni Center: el chip se mide por su texto, que es lo que
    // impide que lo recorte.
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 13.0,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? Colors.white : AppTheme.textSlate,
        ),
      ),
      selected: isSelected,
      selectedColor: AppTheme.primaryVigoBlue,
      backgroundColor: const Color(0xFFF1F5F9),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: BorderSide(
          color:
              isSelected ? AppTheme.primaryVigoBlue : const Color(0xFFCBD5E1),
        ),
      ),
      onSelected: (_) {
        setState(() {
          _selectedAgeFilter = filterKey;
        });
      },
    );
  }

  Widget _buildUnidadCard(BuildContext context, Unidad unidad, bool isGl) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 20.0),
      color: AppTheme.cardSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: const BorderSide(color: Color(0xFFD0D7DE), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Las dos etiquetas de arriba: tramo etario y normativa.
            //
            // Wrap y no Row, por lo mismo que los chips del filtro: en un
            // móvil de 360 dp esta fila DESBORDABA 143 px, en las dos lenguas.
            // No se había visto porque el aparato en el que se prueba tiene
            // 412 dp, y porque en release un desborde no pinta franjas: las
            // etiquetas se cortan y ya. Lo destapó el test del filtro.
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryVigoBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    isGl
                        ? 'Tramo ${unidad.tramoEtario} anos'
                        : 'Tramo ${unidad.tramoEtario} años',
                    style: const TextStyle(
                      color: AppTheme.primaryVigoBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppTheme.calmSage.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    unidad.curriculo.normativa,
                    style: const TextStyle(
                      color: Color(0xFF1E5E43),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),

            // Title
            Text(
              unidad.titulo.resolve(_language),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryVigoBlue,
                fontSize: 20.0,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 6.0),

            // Subtitle
            Text(
              unidad.subtitulo.resolve(_language),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
                fontStyle: FontStyle.italic,
                fontSize: 16.0,
              ),
            ),
            const SizedBox(height: 12.0),

            // Description
            Text(
              unidad.descripcion.resolve(_language),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 16.0,
                height: 1.5,
                color: AppTheme.textSlate,
              ),
            ),
            const SizedBox(height: 16.0),

            // Assembly Phase Summary Pill
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.format_list_numbered,
                      size: 18, color: AppTheme.primaryVigoBlue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isGl
                          ? '6 fases de asemblea: Pulso, conto, preguntas, exploración, mates e fogar'
                          : '6 fases de asamblea: Pulso, cuento, preguntas, exploración, mates y hogar',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Primary Launch Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AsambleaGuiadaScreen(
                        unidad: unidad,
                        audioService: widget.audioService,
                        initialLanguage: _language,
                        onLanguageChanged: _onToggleLanguage,
                        premios: widget.premios,
                        calendario: widget.calendario,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline),
                label: Text(
                  isGl ? 'Iniciar Asemblea Guiada' : 'Iniciar Asamblea Guiada',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryVigoBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
