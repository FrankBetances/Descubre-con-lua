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
import 'backstage_asamblea_screen.dart';
import 'capsulas_aula_screen.dart';
import '../../../core/storage/calendario_store.dart';
import '../../calendario/views/calendario_screen.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../../calendario/widgets/calendario_do_curso.dart';

/// Ciclos educativos de Educación Infantil (Decreto 150/2022).
enum CicloEducativo {
  primerCiclo, // 0-3 anos (1.er Ciclo)
  segundoCiclo, // 3-6 anos (2.º Ciclo)
}

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

  /// Los diez meses, si quien abre esta pantalla ya los tiene leídos. Sin
  /// esto la sección del calendario los lee sola, que en la app tarda un
  /// fotograma pero en un test de captura puede no llegar a tiempo: la
  /// imagen salía con un hueco en blanco donde va el calendario.
  final CalendarioContenido? calendarioContenido;

  /// Ciclo educativo seleccionado por defecto (1.er Ciclo ou 2.º Ciclo).
  final CicloEducativo initialCiclo;

  const UnidadesListScreen({
    super.key,
    required this.repository,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
    this.calendarioContenido,
    this.initialCiclo = CicloEducativo.primerCiclo,
  });

  @override
  State<UnidadesListScreen> createState() => _UnidadesListScreenState();
}

class _UnidadesListScreenState extends State<UnidadesListScreen> {
  late AppLanguage _language;
  late CicloEducativo _selectedCiclo;
  String _selectedAgeFilter = 'todas'; // 'todas', '0-2', '2-3'

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _selectedCiclo = widget.initialCiclo;
  }

  /// El calendario del curso, DENTRO de esta pantalla.
  ///
  /// Aquí había un botón azul que saltaba a otra pantalla. Un botón que lleva
  /// al calendario no es el calendario: la docente que abre el aula con dos
  /// minutos de margen tiene que ver el mes que le toca sin salir de donde
  /// está. Va en los dos ciclos, y la misma pieza va en Academy.
  Widget _buildCalendarioDoAula({EdgeInsets? padding}) {
    return CalendarioDoCurso(
      lang: _language,
      esDocente: true,
      store: widget.calendario,
      contenido: widget.calendarioContenido,
      onAbrirMes: _abrirCalendario,
      padding: padding ??
          const EdgeInsets.fromLTRB(
            AppTheme.spaceLg,
            AppTheme.spaceMd,
            AppTheme.spaceLg,
            0,
          ),
    );
  }

  void _abrirCalendario(CalendarioContenido contenido, int mesIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalendarioScreen(
          store: widget.calendario ?? CalendarioStore(),
          contenido: contenido,
          mesInicialIndex: mesIndex,
          initialLanguage: _language,
          onLanguageChanged: _onToggleLanguage,
          esDocenteInicial: true,
          repository: widget.repository,
          audioService: widget.audioService,
          premios: widget.premios,
        ),
      ),
    );
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
            // Selector de Ciclo Educativo: [ 1.er Ciclo (0-3) | 2.º Ciclo (3-6) ]
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceLg,
                vertical: AppTheme.spaceSm,
              ),
              color: AppTheme.pageBg,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: const ValueKey('tab_primer_ciclo'),
                        onTap: () {
                          if (_selectedCiclo != CicloEducativo.primerCiclo) {
                            setState(() {
                              _selectedCiclo = CicloEducativo.primerCiclo;
                            });
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedCiclo == CicloEducativo.primerCiclo
                                ? AppTheme.card
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusField),
                            boxShadow:
                                _selectedCiclo == CicloEducativo.primerCiclo
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ]
                                    : null,
                          ),
                          child: Text(
                            isGl
                                ? '1.º Ciclo (0-3 anos)'
                                : '1.er Ciclo (0-3 años)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14.5,
                              fontWeight:
                                  _selectedCiclo == CicloEducativo.primerCiclo
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                              color:
                                  _selectedCiclo == CicloEducativo.primerCiclo
                                      ? AppTheme.primaryInk
                                      : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        key: const ValueKey('tab_segundo_ciclo'),
                        onTap: () {
                          if (_selectedCiclo != CicloEducativo.segundoCiclo) {
                            setState(() {
                              _selectedCiclo = CicloEducativo.segundoCiclo;
                            });
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedCiclo == CicloEducativo.segundoCiclo
                                ? AppTheme.backstageBg
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusField),
                            boxShadow:
                                _selectedCiclo == CicloEducativo.segundoCiclo
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ]
                                    : null,
                          ),
                          child: Text(
                            isGl
                                ? '2.º Ciclo (3-6 anos)'
                                : '2.º Ciclo (3-6 años)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14.5,
                              fontWeight:
                                  _selectedCiclo == CicloEducativo.segundoCiclo
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                              color:
                                  _selectedCiclo == CicloEducativo.segundoCiclo
                                      ? AppTheme.backstageAccent
                                      : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vista condicional polo ciclo seleccionado
            if (_selectedCiclo == CicloEducativo.segundoCiclo)
              _buildSegundoCicloView(context, isGl)
            else ...[
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
                    contadores: widget.calendario?.contadores,
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
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
                    // El calendario sigue estando aunque el filtro de edad no
                    // deje ninguna unidad: no depende del tramo.
                    ? ListView(
                        padding: const EdgeInsets.all(20.0),
                        children: [
                          _buildCalendarioDoAula(
                            padding:
                                const EdgeInsets.only(bottom: AppTheme.spaceLg),
                          ),
                          Padding(
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
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        // +1: el calendario es la primera fila de la lista.
                        //
                        // Va DENTRO de la lista y no en el marco fijo de
                        // arriba a propósito: en el marco sumaba alto y a
                        // escala de texto 1,3 la pantalla desbordaba 5 px por
                        // abajo. Aquí se ve nada más entrar, que es lo que
                        // pedía Frank, y se desplaza con el resto.
                        itemCount: unidades.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return _buildCalendarioDoAula(
                              padding: const EdgeInsets.only(
                                  bottom: AppTheme.spaceLg),
                            );
                          }
                          final unidad = unidades[index - 1];
                          return _buildUnidadCard(context, unidad, isGl);
                        },
                      ),
              ),
            ],
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

  Widget _buildSegundoCicloView(BuildContext context, bool isGl) {
    final asambleas = widget.repository.getAllAsambleasSegundoCicloSync();

    return Expanded(
      child: ListView(
        // Con clave: los tests necesitan decir POR CUÁL de los desplazables
        // bajan, y ahora hay dos —este y el carrusel de meses, que va de
        // lado—. Sin clave, `find.byType(Scrollable).last` cogía el carrusel.
        key: const Key('lista_segundo_ciclo'),
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // El calendario también aquí. El 2.º ciclo reparte el mismo curso de
          // diez meses que el primero, y no tenerlo obligaba a salir de esta
          // pantalla para saber por dónde va el curso.
          //
          // Sin margen lateral propio: esta lista ya trae el suyo, y sumados
          // dejaban la tarjeta estrecha.
          _buildCalendarioDoAula(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
          ),
          // Banner explicativo do Segundo Ciclo
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppTheme.backstageBg,
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.backstageBorder, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Este Row desbordaba 299 px en gallego y 323 en castellano
                // a escala normal, y 468 a escala 1,3: la etiqueta, el Spacer
                // y «Cero pantallas infantís» no caben en 360 dp ni de lejos.
                // Wrap en vez de Row: las dos piezas bajan de línea cuando no
                // caben, que es lo que hace el filtro de edad desde que se
                // arregló el suyo.
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                      ),
                      child: Text(
                        isGl ? 'ASEMBLEA · 2.º CICLO' : 'ASAMBLEA · 2.º CICLO',
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryInk,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.visibility_off_rounded,
                          color: AppTheme.textSecondary,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        // Flexible aunque el Row sea `min`: el Wrap le da como
                        // mucho el ancho de la tarjeta, y esta línea se pasaba
                        // 17 px en 360 dp. Con Flexible parte de línea.
                        Flexible(
                          child: Text(
                            isGl
                                ? 'Cero pantallas infantís'
                                : 'Cero pantallas infantiles',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  isGl
                      ? 'Asemblea Matinal do 2.º Ciclo (3-6 anos)'
                      : 'Asamblea Matinal del 2.º Ciclo (3-6 años)',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.backstageTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isGl
                      ? '4 fases (10 min): Apertura (90s), Foco Rítmico (120s), Reto TPR en L3 (270s) e Calma (120s). A mesma pantalla que a asemblea de primeiro ciclo.'
                      : '4 fases (10 min): Apertura (90s), Foco Rítmico (120s), Reto TPR en L3 (270s) y Calma (120s). La misma pantalla que la asamblea de primer ciclo.',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: AppTheme.backstageTextSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const ValueKey('launch_backstage_primary_button'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BackstageAsambleaScreen(
                            repository: widget.repository,
                            audioService: widget.audioService,
                            initialNivel: NivelEducativoSegundoCiclo.infantil4,
                            initialLanguage: _language,
                            onLanguageChanged: _onToggleLanguage,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.backstageAccent,
                      foregroundColor: AppTheme.backstageBg,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_filled_rounded),
                    label: Text(
                      isGl ? 'Comezar a asemblea' : 'Comenzar la asamblea',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Título da sección de unidades
          Text(
            isGl
                ? 'SESIÓNS POR NIVEL (SETEMBRO)'
                : 'SESIONES POR NIVEL (SEPTIEMBRE)',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          // Tarxetas de unidades do 2º ciclo
          if (asambleas.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  isGl
                      ? 'Non se atoparon asambleas de segundo ciclo dispoñibles.'
                      : 'No se encontraron asambleas de segundo ciclo disponibles.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF64748B),
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          else
            ...asambleas.map((asamblea) {
              return _buildAsambleaSegundoCicloCard(context, asamblea, isGl);
            }),
        ],
      ),
    );
  }

  Widget _buildAsambleaSegundoCicloCard(
    BuildContext context,
    AsambleaSegundoCiclo asamblea,
    bool isGl,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
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
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryInk.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    asamblea.nivel.etiqueta.resolve(_language),
                    style: const TextStyle(
                      color: AppTheme.primaryInk,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.calmSage.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    asamblea.curriculo.normativa,
                    style: const TextStyle(
                      color: Color(0xFF1E5E43),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    asamblea.metodologiaTpr.nombre.resolve(_language),
                    style: const TextStyle(
                      color: Color(0xFF1D4ED8),
                      fontWeight: FontWeight.bold,
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14.0),
            Text(
              asamblea.titulo.resolve(_language),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryInk,
                    fontSize: 19.0,
                    height: 1.25,
                  ),
            ),
            const SizedBox(height: 6.0),
            Text(
              asamblea.centroInteres.resolve(_language),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A5568),
                    fontStyle: FontStyle.italic,
                    fontSize: 15.0,
                  ),
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.timer_outlined,
                    size: 18,
                    color: AppTheme.primaryInk,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${asamblea.fases.length} ${isGl ? 'fases' : 'fases'}'
                      ' (${asamblea.duracionTotalMinutos} min): '
                      '${asamblea.fases.map((f) => '${f.tipo.nombre.resolve(_language)} (${f.duracionSegundos}s)').join(', ')}',
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: ValueKey('launch_backstage_nivel_${asamblea.nivel.clave}'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BackstageAsambleaScreen(
                        repository: widget.repository,
                        audioService: widget.audioService,
                        initialNivel: asamblea.nivel,
                        initialLanguage: _language,
                        onLanguageChanged: _onToggleLanguage,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline),
                label: Text(
                  isGl ? 'Abrir a asemblea' : 'Abrir la asamblea',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  // Era negro con texto verde encima: ni se leía, ni pintaba
                  // nada un botón negro en una pantalla clara.
                  backgroundColor: AppTheme.primaryInk,
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
