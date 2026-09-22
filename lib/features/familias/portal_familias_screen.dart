import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../data/models/calendario_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/formacion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../academy/views/bloques_list_screen.dart';
import '../academy/widgets/selector_idioma_widget.dart';
import '../calendario/views/calendario_fogar_screen.dart';
import '../cuentos/views/cuentos_list_screen.dart';
import '../formacion/views/formacion_screen.dart';
import '../laminas/views/laminas_gallery_screen.dart';
import '../lectura/views/aprender_a_ler_screen.dart';
import '../premios/premios_repository.dart';
import '../premios/premios_screen.dart';
import 'views/xogos_fogar_screen.dart';

/// Pantalla independente do Portal Familias.
///
/// Deseñada especificamente para a persoa adulta no fogar baixo o principio
/// de Cero Pantallas para a Crianza (/tangible-l2-parent-orchestrator):
/// - A crianza non toca o teléfono nin a tablet.
/// - O adulto consulta a partitura de xogo, a rutina diaria ou o conto,
///   e media a experiencia física, fónica e manipulativa no mundo real.
/// - Sistema intuitivo de selección e filtrado de exercicios por área e tramo de idade.
class PortalFamiliasScreen extends StatefulWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const PortalFamiliasScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
  });

  @override
  State<PortalFamiliasScreen> createState() => _PortalFamiliasScreenState();
}

class _PortalFamiliasScreenState extends State<PortalFamiliasScreen> {
  late AppLanguage _language;
  String _selectedCategory = 'todas';
  String _selectedAge = 'todas';

  static const _appBarTitle = LocalizedString(
    gl: 'Portal Familias · Fogar',
    es: 'Portal Familias · Hogar',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Espazo de estimulación familiar sen pantallas para a infancia. Recursos guiados para o desenvolvemento da linguaxe e o vínculo afectivo.',
    es: 'Espacio de estimulación familiar sin pantallas para la infancia. Recursos guiados para el desarrollo del lenguaje y el vínculo afectivo.',
  );

  static const List<Map<String, String>> _categories = [
    {'id': 'todas', 'gl': 'Todas as Áreas', 'es': 'Todas las Áreas'},
    {'id': 'xogos', 'gl': 'Xogos Físicos (TPR)', 'es': 'Juegos Físicos (TPR)'},
    {'id': 'contos', 'gl': 'Contos Dialogados', 'es': 'Cuentos Dialogados'},
    {'id': 'lectura', 'gl': 'Aprender a Ler', 'es': 'Aprender a Leer'},
    {
      'id': 'laminas',
      'gl': 'Láminas e Vocabulario',
      'es': 'Láminas y Vocabulario'
    },
    {
      'id': 'calendario',
      'gl': 'Calendario Escolar',
      'es': 'Calendario Escolar'
    },
    {'id': 'academy', 'gl': 'Pautas de Crianza', 'es': 'Pautas de Crianza'},
  ];

  static const List<Map<String, String>> _ages = [
    {'id': 'todas', 'gl': 'Todas as idades', 'es': 'Todas las edades'},
    {'id': '0_2', 'gl': '0-2 anos (Nido)', 'es': '0-2 años (Nido)'},
    {'id': '2_3', 'gl': '2-3 anos (Maternal)', 'es': '2-3 años (Maternal)'},
    {
      'id': '3_4',
      'gl': '3-4 anos (4.º Infantil)',
      'es': '3-4 años (4.º Infantil)'
    },
    {
      'id': '4_5',
      'gl': '4-5 anos (5.º Infantil)',
      'es': '4-5 años (5.º Infantil)'
    },
    {
      'id': '5_6',
      'gl': '5-6 anos (6.º Infantil)',
      'es': '5-6 años (6.º Infantil)'
    },
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.currentLanguage;
  }

  @override
  void didUpdateWidget(covariant PortalFamiliasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _language = widget.currentLanguage;
    }
  }

  void _handleLanguageChanged(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  String? get _cursoIdActual {
    if (_selectedAge == 'todas') return null;
    return 'curso_$_selectedAge';
  }

  bool _matchesFilter(String categoryId) {
    return _selectedCategory == 'todas' || _selectedCategory == categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = _language == AppLanguage.gl;
    final store = widget.calendario ?? CalendarioStore();
    final estadoHoy = store.estadoParaFecha(DateTime.now());
    final bool feitoHoxe = estadoHoy == EstadoEstimulacion.soloHogar ||
        estadoHoy == EstadoEstimulacion.dobleEstimulacion;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          _appBarTitle.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _handleLanguageChanged,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Cabecera Acolledora de Familia
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFFF9EE),
                    Color(0xFFFDE8CF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFF6D4A0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDD6B20),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isGl
                              ? 'CERO PANTALLAS INFANTÍS'
                              : 'CERO PANTALLAS INFANTILES',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const LuaPixel(size: 32),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isGl
                        ? 'Benvida ao fogar de Lúa'
                        : 'Bienvenida al hogar de Lúa',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7B341E),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _subtitulo.resolve(_language),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4A5568),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    key: const ValueKey('formacion_familia_portal'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FormacionScreen(
                            perfil: PerfilFormacion.familia,
                            language: _language,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school_outlined,
                        size: 18, color: Color(0xFF9C4221)),
                    label: Text(
                      isGl
                          ? 'Antes de empezar na casa · Guía de 2 min'
                          : 'Antes de empezar en casa · Guía de 2 min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9C4221),
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 36),
                      alignment: Alignment.centerLeft,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),

            // Card de Rutina de Hoxe no Fogar (Destaque Principal)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: feitoHoxe
                      ? const Color(0xFF38A169)
                      : AppTheme.primaryVigoBlue,
                  width: 1.5,
                ),
              ),
              color: feitoHoxe ? const Color(0xFFF0FDF4) : Colors.white,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CalendarioFogarScreen(
                        repository: widget.repository,
                        store: store,
                        initialLanguage: _language,
                        audioService: widget.audioService,
                        onLanguageChanged: _handleLanguageChanged,
                        initialCursoId: _cursoIdActual,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: feitoHoxe
                            ? const Color(0xFFC6F6D5)
                            : AppTheme.primaryTint,
                        child: Icon(
                          feitoHoxe
                              ? Icons.check_circle_rounded
                              : Icons.calendar_today_rounded,
                          color: feitoHoxe
                              ? const Color(0xFF22543D)
                              : AppTheme.primaryVigoBlue,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              feitoHoxe
                                  ? (isGl
                                      ? 'Xogo de hoxe completado!'
                                      : '¡Juego de hoy completado!')
                                  : (isGl
                                      ? 'O teu xogo de 3 min de hoxe'
                                      : 'Tu juego de 3 min de hoy'),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: feitoHoxe
                                    ? const Color(0xFF22543D)
                                    : AppTheme.primaryInk,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              feitoHoxe
                                  ? (isGl
                                      ? 'Racha: ${store.rachaActual} días de xogo compartido'
                                      : 'Racha: ${store.rachaActual} días de juego compartido')
                                  : (isGl
                                      ? 'Toca para abrir a rutina do día no calendario escolar'
                                      : 'Toca para abrir la rutina del día en el calendario escolar'),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded,
                          color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // Selector e Filtros de Dinámicas e Exercicios
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                isGl
                    ? 'EXPLORAR DINÁMICAS POR ÁREA'
                    : 'EXPLORAR DINÁMICAS POR ÁREA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 8.0),

            // Chips de filtro de categorías
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSel = _selectedCategory == cat['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(isGl ? cat['gl']! : cat['es']!),
                      selected: isSel,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => _selectedCategory = cat['id']!);
                        }
                      },
                      selectedColor: AppTheme.primaryVigoBlue,
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppTheme.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8.0),

            // Chips de filtro por idade / etapa
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _ages.map((age) {
                  final isSel = _selectedAge == age['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(isGl ? age['gl']! : age['es']!),
                      selected: isSel,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedAge = age['id']!);
                      },
                      selectedColor: const Color(0xFFDD6B20),
                      labelStyle: TextStyle(
                        color: isSel ? Colors.white : AppTheme.textPrimary,
                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                        fontSize: 11.5,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            // 1. Calendario Escolar no Fogar
            if (_matchesFilter('calendario')) ...[
              _buildFamilyModuleCard(
                context: context,
                title: isGl
                    ? 'Calendario Escolar no Fogar'
                    : 'Calendario Escolar en el Hogar',
                description: isGl
                    ? '10 meses escolares (Setembro a Xuño), 5 cursos diferenciados por semanas e días con actividades concretas de 3 min, momentos cotiáns e conexión coa escola.'
                    : '10 meses escolares (Septiembre a Junio), 5 cursos diferenciados por semanas y días con actividades concretas de 3 min, momentos cotidianos y conexión con la escuela.',
                icon: Icons.calendar_month_rounded,
                iconColor: const Color(0xFFDD6B20),
                iconBg: const Color(0xFFFFF9EE),
                badge: isGl ? '10 Meses · 5 Cursos' : '10 Meses · 5 Cursos',
                buttonText: isGl ? 'Abrir Calendario' : 'Abrir Calendario',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CalendarioFogarScreen(
                        repository: widget.repository,
                        store: store,
                        initialLanguage: _language,
                        audioService: widget.audioService,
                        onLanguageChanged: _handleLanguageChanged,
                        initialCursoId: _cursoIdActual,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14.0),
            ],

            // 2. Biblioteca de Contos Ilustrados
            if (_matchesFilter('contos')) ...[
              _buildFamilyModuleCard(
                context: context,
                title: isGl
                    ? 'Biblioteca de Contos Dialóxicos'
                    : 'Biblioteca de Cuentos Dialógicos',
                description: isGl
                    ? 'Contos ilustrados con desenvolvemento narrativo por curso e mes, preguntas graduadas en 3 niveis de comprensión e reto físico TPR oral en inglés.'
                    : 'Cuentos ilustrados con desarrollo narrativo por curso y mes, preguntas graduadas en 3 niveles de comprensión y reto físico TPR oral en inglés.',
                icon: Icons.auto_stories_rounded,
                iconColor: AppTheme.primaryVigoBlue,
                iconBg: AppTheme.primaryTint,
                badge: isGl ? 'Lectura Dialóxica' : 'Lectura Dialógica',
                buttonText: isGl ? 'Explorar Contos' : 'Explorar Cuentos',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CuentosListScreen(
                        repository: widget.repository,
                        initialLanguage: _language,
                        audioService: widget.audioService,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14.0),
            ],

            // 3. Aprender a Ler · Fónica Manipulativa
            if (_matchesFilter('lectura')) ...[
              _buildFamilyModuleCard(
                context: context,
                title: isGl
                    ? 'Aprender a Ler · Fónica Manipulativa'
                    : 'Aprender a Leer · Fonética Manipulativa',
                description: isGl
                    ? 'Conciencia fonolóxica, mesa Alphabot expandida con letras reais de madeira/imáns, cubos CVC combinatorios (Phonicubes) e discriminación de pares mínimos.'
                    : 'Conciencia fonológica, mesa Alphabot expandida con letras reales de madera/imanes, cubos CVC combinatorios (Phonicubes) y discriminación de pares mínimos.',
                icon: Icons.spellcheck_rounded,
                iconColor: const Color(0xFFD69E2E),
                iconBg: const Color(0xFFFEFCBF),
                badge: isGl ? 'Alfabetización Táctil' : 'Alfabetización Táctil',
                buttonText: isGl ? 'Entrar en Lectura' : 'Entrar en Lectura',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AprenderALerScreen(
                        repository: widget.repository,
                        initialLanguage: _language,
                        audioService: widget.audioService,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14.0),
            ],

            // 4. Banco de Láminas Didácticas
            if (_matchesFilter('laminas')) ...[
              _buildFamilyModuleCard(
                context: context,
                title: isGl
                    ? 'Banco de Láminas e Vocabulario'
                    : 'Banco de Láminas y Vocabulario',
                description: isGl
                    ? '200+ láminas ilustradas por categorías (animais, ría de Vigo, emocións, alimentos), con preguntas de diálogo, retos de sinalamento táctil e pronunciación.'
                    : '200+ láminas ilustradas por categorías (animales, ría de Vigo, emociones, alimentos), con preguntas de diálogo, retos de señalamiento táctil y pronunciación.',
                icon: Icons.photo_library_rounded,
                iconColor: const Color(0xFF38A169),
                iconBg: const Color(0xFFC6F6D5),
                badge: isGl ? '200+ Tarxetas' : '200+ Tarjetas',
                buttonText: isGl ? 'Ver Láminas' : 'Ver Láminas',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => LaminasGalleryScreen(
                        repository: widget.repository,
                        initialLanguage: _language,
                        audioService: widget.audioService,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14.0),
            ],

            // 5. Xogos e Dinámicas Físicas no Fogar (TPR)
            if (_matchesFilter('xogos')) ...[
              _buildFamilyModuleCard(
                context: context,
                title: isGl
                    ? 'Xogos e Dinámicas Corporais (TPR)'
                    : 'Juegos y Dinámicas Corporales (TPR)',
                description: isGl
                    ? 'Repertorio de xogos de movemento físico sen pantallas: Caza do tesouro dos sons, O barquiño de Samil, O xigante e a formiga, e masaxe a 72 bpm.'
                    : 'Repertorio de juegos de movimiento físico sin pantallas: Caza del tesoro de los sonidos, El barquito de Samil, El gigante y la hormiguita, y masaje a 72 bpm.',
                icon: Icons.sports_gymnastics_rounded,
                iconColor: const Color(0xFF805AD5),
                iconBg: const Color(0xFFE9D8FD),
                badge: isGl ? 'Xogos Físicos' : 'Juegos Físicos',
                buttonText: isGl ? 'Ver Dinámicas' : 'Ver Dinámicas',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => XogosFogarScreen(
                        initialLanguage: _language,
                        audioService: widget.audioService,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14.0),
            ],

            // 6. Academy · Cápsulas de Crianza
            if (_matchesFilter('academy')) ...[
              _buildFamilyModuleCard(
                context: context,
                title: isGl
                    ? 'Academy · Pautas de Crianza'
                    : 'Academy · Pautas de Crianza',
                description: isGl
                    ? '5 bloques de desenvolvemento da comunicación para a persoa adulta: quendas de conversa, baño de linguaxe, bilingüismo aditivo e xogo motor sen pantallas.'
                    : '5 bloques de desarrollo de la comunicación para la persona adulta: turnos de conversación, baño de lenguaje, bilingüismo aditivo y juego motor sin pantallas.',
                icon: Icons.family_restroom_rounded,
                iconColor: const Color(0xFF319795),
                iconBg: const Color(0xFFB2F5EA),
                badge: isGl ? 'Formación Familiar' : 'Formación Familiar',
                buttonText: isGl ? 'Entrar en Academy' : 'Entrar en Academy',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BloquesListScreen(
                        repository: widget.repository,
                        premios: widget.premios,
                        calendario: widget.calendario,
                        audioService: widget.audioService,
                        initialLanguage: _language,
                        onLanguageChanged: _handleLanguageChanged,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14.0),
            ],

            // 7. Premios e Insignias do Mediador
            if (widget.premios != null) ...[
              const SizedBox(height: 14.0),
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PremiosScreen(
                      repository: widget.premios!,
                      currentLanguage: _language,
                      contadores: widget.calendario?.contadores,
                    ),
                  ),
                ),
                icon: const Icon(Icons.military_tech_outlined),
                label: Text(PremiosScreen.titulo.resolve(_language)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppTheme.touchMin),
                  side: const BorderSide(color: AppTheme.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                isGl
                    ? 'Nivel, racha e insignias da persoa adulta que dedica tempo á crianza.'
                    : 'Nivel, racha e insignias de la persona adulta que dedica tiempo a la criatura.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppTheme.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFamilyModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String badge,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: iconBg,
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        badge.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: iconColor,
                          letterSpacing: 0.6,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
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
