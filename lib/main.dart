import 'package:flutter/material.dart';
import 'core/audio/local_audio_player.dart';
import 'core/audio/offline_audio_service.dart';
import 'core/localization/app_language.dart';
import 'core/localization/localized_string.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/paxina_sen_scroll.dart';
import 'data/models/capsula_model.dart';
import 'data/models/unidad_model.dart';
import 'data/repositories/content_repository.dart';
import 'core/storage/calendario_store.dart';
import 'features/academy/views/bloques_list_screen.dart';
import 'features/academy/views/capsula_detail_screen.dart';
import 'features/academy/views/guia_atencion_screen.dart';
import 'features/academy/widgets/selector_idioma_widget.dart';
import 'features/bienvenida/welcome_screen.dart';
import 'features/calendario/views/calendario_screen.dart';
import 'features/creditos/credits_screen.dart';
import 'data/models/formacion_model.dart';
import 'features/formacion/views/formacion_screen.dart';
import 'features/premios/premios_repository.dart';
import 'features/premios/premios_screen.dart';
import 'features/juega/views/asamblea_guiada_screen.dart';
import 'features/juega/views/backstage_asamblea_screen.dart';
import 'features/juega/views/unidades_list_screen.dart';
import 'features/academy/views/micro_rutina_setembro_screen.dart';
import 'data/models/asamblea_segundo_ciclo_model.dart';
import 'features/cuentos/views/cuentos_list_screen.dart';
import 'features/laminas/views/laminas_gallery_screen.dart';
import 'features/palabras/views/vocabulario_ingles_screen.dart';
import 'features/english/views/english_hub_screen.dart';
import 'features/lectura/views/aprender_a_ler_screen.dart';
import 'features/planificador/views/planificador_screen.dart';
import 'features/planificador/views/estrategias_screen.dart';
import 'features/planificador/views/dinamicas_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = ContentRepository();
  await repository.initialize();
  runApp(DescubreConLuaApp(contentRepository: repository));
}

/// Root application widget for «Descubre con Lúa · Edición Vigo».
///
/// Configured strictly for offline operation with zero network dependencies,
/// sovereign bilingual content (`gl`/`es`), and sober educational Material 3 design.
class DescubreConLuaApp extends StatefulWidget {
  final ContentRepository? contentRepository;
  final PremiosRepository? premiosRepository;
  final CalendarioStore? calendarioStore;
  final OfflineAudioService? audioService;
  final AppLanguage initialLanguage;

  const DescubreConLuaApp({
    super.key,
    this.contentRepository,
    this.premiosRepository,
    this.calendarioStore,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
  });

  @override
  State<DescubreConLuaApp> createState() => _DescubreConLuaAppState();
}

class _DescubreConLuaAppState extends State<DescubreConLuaApp> {
  late AppLanguage _currentLanguage;
  late final ContentRepository _repository;
  late final PremiosRepository _premios;
  late final CalendarioStore _calendario;
  late final OfflineAudioService _audioService;
  bool _createdInternalAudioService = false;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage;
    _repository = widget.contentRepository ?? ContentRepository();
    _premios = widget.premiosRepository ?? PremiosRepository();
    _premios.cargar();
    _calendario = widget.calendarioStore ?? CalendarioStore();
    _calendario.cargar();
    if (widget.audioService != null) {
      _audioService = widget.audioService!;
    } else {
      // Production playback. This used to be MockOfflineAudioService, so the
      // play button changed state and the classroom heard nothing.
      _audioService = LocalAudioPlayer();
      _createdInternalAudioService = true;
    }

    if (!_repository.isInitialized) {
      _repository.initialize();
    }
  }

  @override
  void dispose() {
    if (_createdInternalAudioService) {
      _audioService.dispose();
    }
    super.dispose();
  }

  void _toggleLanguage() {
    setState(() {
      _currentLanguage = _currentLanguage.toggle();
    });
  }

  void _setLanguage(AppLanguage lang) {
    setState(() {
      _currentLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Descubre con Lúa · Edición Vigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        // La bienvenida es la primera pantalla, como en el proyecto anterior de la casa. No guarda que
        // ya la viste: esa marca sería un campo persistido más que declarar en
        // Play Console, y la app no guarda nada. Cuesta un toque por arranque.
        '/': (context) => WelcomeScreen(
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onStart: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
              onShowCredits: () => Navigator.of(context).pushNamed('/creditos'),
            ),
        '/creditos': (context) => CreditsScreen(
              currentLanguage: _currentLanguage,
            ),
        '/home': (context) => HomeScreen(
              repository: _repository,
              premios: _premios,
              calendario: _calendario,
              audioService: _audioService,
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/academy': (context) => BloquesListScreen(
              repository: _repository,
              premios: _premios,
              calendario: _calendario,
              audioService: _audioService,
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/juega': (context) => UnidadesListScreen(
              repository: _repository,
              premios: _premios,
              calendario: _calendario,
              audioService: _audioService,
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/calendario': (context) => CalendarioScreen(
              store: _calendario,
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
              repository: _repository,
              audioService: _audioService,
              premios: _premios,
            ),
        '/guia-atencion': (context) => GuiaAtencionScreen(
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
              audioService: _audioService,
            ),
        // `/juega/backstage` NO va aquí: `routes` gana a `onGenerateRoute` y se
        // come los `arguments`, así que el nivel elegido se perdía y la pantalla
        // abría siempre en 4.º de Infantil. Vive solo en `onGenerateRoute`.
        '/academy/micro-rutina': (context) => MicroRutinaSetembroScreen(
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/cuentos': (context) => CuentosListScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
              audioService: _audioService,
            ),
        '/laminas': (context) => LaminasGalleryScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
              audioService: _audioService,
            ),
        '/palabras': (context) => VocabularioInglesScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
              audioService: _audioService,
            ),
        '/english': (context) => EnglishHubScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
              audioService: _audioService,
            ),
        '/lectura': (context) => AprenderALerScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
              audioService: _audioService,
            ),
        '/planificador': (context) => PlanificadorScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
            ),
        '/estrategias': (context) => EstrategiasScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
            ),
        '/dinamicas': (context) => DinamicasScreen(
              repository: _repository,
              initialLanguage: _currentLanguage,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/juega/backstage') {
          final nivel = settings.arguments as NivelEducativoSegundoCiclo?;
          return MaterialPageRoute(
            builder: (context) => BackstageAsambleaScreen(
              repository: _repository,
              audioService: _audioService,
              initialNivel: nivel ?? NivelEducativoSegundoCiclo.infantil4,
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
          );
        } else if (settings.name == '/academy/capsula') {
          final capsula = settings.arguments as Capsula?;
          if (capsula != null) {
            return MaterialPageRoute(
              builder: (context) => CapsulaDetailScreen(
                capsula: capsula,
                premios: _premios,
                audioService: _audioService,
                initialLanguage: _currentLanguage,
                onLanguageChanged: _setLanguage,
              ),
            );
          }
        } else if (settings.name == '/juega/asamblea') {
          final unidad = settings.arguments as Unidad?;
          if (unidad != null) {
            return MaterialPageRoute(
              builder: (context) => AsambleaGuiadaScreen(
                unidad: unidad,
                premios: _premios,
                calendario: _calendario,
                audioService: _audioService,
                initialLanguage: _currentLanguage,
                onLanguageChanged: _setLanguage,
              ),
            );
          }
        }
        return null;
      },
    );
  }
}

/// Main hub screen providing access to the two pedagogical modules:
/// - Juega con Lúa (Aula / Docentes)
/// - Academy (Familias)
enum PortalRole {
  familias,
  docentes,
}

/// Main hub screen providing access to both pedagogical portals:
/// - Portal Familias (Academy, Contos, Láminas, Aprender a Ler, Calendario, Premios)
/// - Portal Docentes (Juega con Lúa, Planificador 50 Meses, English L3, Estratexias, Dinámicas, Corpus 8000)
class HomeScreen extends StatefulWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final PortalRole initialRole;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
    this.initialRole = PortalRole.familias,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late PortalRole _currentRole;

  static const _appBarTitle = LocalizedString(
    gl: 'Descubre con Lúa · Vigo',
    es: 'Descubre con Lúa · Vigo',
  );

  static const _subtitle = LocalizedString(
    gl: 'Recurso pedagóxico e familiar para o desenvolvemento da linguaxe e comunicación',
    es: 'Recurso pedagógico y familiar para el desarrollo del lenguaje y la comunicación',
  );

  static const _portalFamilias = LocalizedString(
    gl: 'Portal Familias',
    es: 'Portal Familias',
  );

  static const _portalDocentes = LocalizedString(
    gl: 'Portal Docentes',
    es: 'Portal Docentes',
  );

  static const _juegaTitle = LocalizedString(
    gl: 'Juega con Lúa · Aula',
    es: 'Juega con Lúa · Aula',
  );

  static const _juegaSubtitle = LocalizedString(
    gl: 'Para docentes: unidades temáticas de Vigo, asamblea guiada con canción a pulso offline, exploración sensorial e matemáticas temperás.',
    es: 'Para docentes: unidades temáticas de Vigo, asamblea guiada con canción a pulso offline, exploración sensorial y matemáticas tempranas.',
  );

  static const _calendarioTitle = LocalizedString(
    gl: 'Calendario Escola · Fogar',
    es: 'Calendario Escuela · Hogar',
  );

  static const _calendarioSubtitle = LocalizedString(
    gl: 'Sincronización curricular de 10 meses (Setembro a Xuño): asambleas na aula e micro-rutinas de 3 min na casa para dobre estimulación sen pantallas.',
    es: 'Sincronización curricular de 10 meses (Septiembre a Junio): asambleas en el aula y micro-rutinas de 3 min en casa para doble estimulación sin pantallas.',
  );

  static const _academyTitle = LocalizedString(
    gl: 'Academy · Familias',
    es: 'Academy · Familias',
  );

  static const _academySubtitle = LocalizedString(
    gl: 'Para familias: 5 bloques de desenvolvemento da comunicación, lectura en 4 partes con exemplos cotiáns sen pantallas infantís.',
    es: 'Para familias: 5 bloques de desarrollo de la comunicación, lectura en 4 partes con ejemplos cotidianos sin pantallas infantiles.',
  );

  // Ningún rótulo lleva la cuenta escrita. La llevaba —«Banco de 200»— y la
  // pantalla cargaba 306 contos y 205 láminas: el rótulo mentía en la cara de
  // quien abría la app. Ahora cuenta la pantalla, que sabe lo que hay.
  static const _cuentosTitle = LocalizedString(
    gl: 'Biblioteca de Contos Pedagóxicos',
    es: 'Biblioteca de Cuentos Pedagógicos',
  );

  static const _cuentosSubtitle = LocalizedString(
    gl: 'Contos ilustrados por curso, mes e semana, con preguntas graduadas en tres niveis e reto TPR oral.',
    es: 'Cuentos ilustrados por curso, mes y semana, con preguntas graduadas en tres niveles y reto TPR oral.',
  );

  static const _laminasTitle = LocalizedString(
    gl: 'Banco de Láminas Didácticas',
    es: 'Banco de Láminas Didácticas',
  );

  static const _laminasSubtitle = LocalizedString(
    gl: 'Láminas debuxadas e tarxetas de vocabulario por categoría, con pregunta suxerida e acción TPR.',
    es: 'Láminas dibujadas y tarjetas de vocabulario por categoría, con pregunta sugerida y acción TPR.',
  );

  static const _lecturaTitle = LocalizedString(
    gl: 'Aprender a Ler · Alfabetización',
    es: 'Aprender a Leer · Alfabetización',
  );

  static const _lecturaSubtitle = LocalizedString(
    gl: 'Mesa manipulativa Alphabot con letras reais de madeira e a biblioteca de contos para ler xuntos.',
    es: 'Mesa manipulativa Alphabot con letras reales de madera y la biblioteca de cuentos para leer juntos.',
  );

  static const _planificadorTitle = LocalizedString(
    gl: 'Planificador Curricular (50 Meses)',
    es: 'Planificador Curricular (50 Meses)',
  );

  static const _planificadorSubtitle = LocalizedString(
    gl: 'Programación completa dos 5 cursos de Educación Infantil (0 a 6 anos) con obxectivos e actividades.',
    es: 'Programación completa de los 5 cursos de Educación Infantil (0 a 6 años) con objetivos y actividades.',
  );

  static const _englishTitle = LocalizedString(
    gl: 'Inmersión en Inglés · L3',
    es: 'Inmersión en Inglés · L3',
  );

  static const _englishSubtitle = LocalizedString(
    gl: 'Repetición espazada, colocacións, comprensión auditiva e os 44 fonemas do inglés, guiado polo adulto.',
    es: 'Repetición espaciada, colocaciones, comprensión auditiva y los 44 fonemas del inglés, guiado por el adulto.',
  );

  static const _estrategiasTitle = LocalizedString(
    gl: 'Estratexias Pedagóxicas',
    es: 'Estrategias Pedagógicas',
  );

  static const _estrategiasSubtitle = LocalizedString(
    gl: '5 estratexias de aula co seu porqué, a guía de aplicación, un exemplo de diálogo e o erro a evitar.',
    es: '5 estrategias de aula con su porqué, la guía de aplicación, un ejemplo de diálogo y el error a evitar.',
  );

  static const _dinamicasTitle = LocalizedString(
    gl: 'Dinámicas de Aula Activa',
    es: 'Dinámicas de Aula Activa',
  );

  static const _dinamicasSubtitle = LocalizedString(
    gl: 'Catálogo de dinámicas activas con roles, espazos, materiais e protocolo de avaliación.',
    es: 'Catálogo de dinámicas activas con roles, espacios, materiales y protocolo de evaluación.',
  );

  static const _corpusTitle = LocalizedString(
    gl: 'Corpus 8.000 Palabras (BNC/COCA)',
    es: 'Corpus 8.000 Palabras (BNC/COCA)',
  );

  static const _corpusSubtitle = LocalizedString(
    gl: 'Explorador léxico con bandas de frecuencia 1k-8k e clasificación curricular CEFR (A1-C2).',
    es: 'Explorador léxico con bandas de frecuencia 1k-8k y clasificación curricular CEFR (A1-C2).',
  );

  static const _privacyNotice = LocalizedString(
    gl: 'Sen conexión e sen datos persoais. O único que se garda neste '
        'aparello é a túa propia conta de uso. Deseñado baixo o Decreto '
        '150/2022.',
    es: 'Sin conexión y sin datos personales. Lo único que se guarda en este '
        'aparato es tu propia cuenta de uso. Diseñado bajo el Decreto '
        '150/2022.',
  );

  static const _premiosSubtitle = LocalizedString(
    gl: 'Nivel, racha e insignias da persoa adulta que usa a app.',
    es: 'Nivel, racha e insignias de la persona adulta que usa la app.',
  );

  @override
  void initState() {
    super.initState();
    _currentRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = widget.currentLanguage == AppLanguage.gl;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle.resolve(widget.currentLanguage)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: widget.currentLanguage,
              onLanguageChanged: (newLang) {
                if (widget.onLanguageChanged != null) {
                  widget.onLanguageChanged!(newLang);
                } else {
                  widget.onToggleLanguage();
                }
              },
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: PaxinaSenScroll(
          desprazarSeNonCabe: true,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  _subtitle.resolve(widget.currentLanguage),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4A5568),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12.0),
              // Selector de Portal Dual: Familias / Docentes
              Center(
                child: SegmentedButton<PortalRole>(
                  segments: [
                    ButtonSegment<PortalRole>(
                      value: PortalRole.familias,
                      icon: const Icon(Icons.family_restroom_outlined),
                      label:
                          Text(_portalFamilias.resolve(widget.currentLanguage)),
                    ),
                    ButtonSegment<PortalRole>(
                      value: PortalRole.docentes,
                      icon: const Icon(Icons.school_outlined),
                      label:
                          Text(_portalDocentes.resolve(widget.currentLanguage)),
                    ),
                  ],
                  selected: {_currentRole},
                  onSelectionChanged: (Set<PortalRole> newSelection) {
                    setState(() {
                      _currentRole = newSelection.first;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              if (_currentRole == PortalRole.familias)
                ..._buildFamiliasModules(context, isGl),
              if (_currentRole == PortalRole.docentes)
                ..._buildDocentesModules(context, isGl),
              const SizedBox(height: 24.0),
              Card(
                color: const Color(0xFFEBE7D5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: const BorderSide(color: Color(0xFFD3CEB8)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        color: AppTheme.primaryVigoBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _privacyNotice.resolve(widget.currentLanguage),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSlate,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFamiliasModules(BuildContext context, bool isGl) {
    final theme = Theme.of(context);
    return [
      _buildModuleCard(
        context: context,
        title: _academyTitle.resolve(widget.currentLanguage),
        description: _academySubtitle.resolve(widget.currentLanguage),
        icon: Icons.family_restroom_outlined,
        buttonText: isGl ? 'Entrar en Academy' : 'Entrar en Academy',
        formacionKey: const ValueKey('formacion_familia'),
        formacionTexto: isGl
            ? 'Antes de empezar na casa · 2 min'
            : 'Antes de empezar en casa · 2 min',
        onFormacion: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FormacionScreen(
                perfil: PerfilFormacion.familia,
                language: widget.currentLanguage,
              ),
            ),
          );
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => BloquesListScreen(
                repository: widget.repository,
                premios: widget.premios,
                calendario: widget.calendario,
                audioService: widget.audioService,
                initialLanguage: widget.currentLanguage,
                onLanguageChanged: widget.onLanguageChanged,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _cuentosTitle.resolve(widget.currentLanguage),
        description: _cuentosSubtitle.resolve(widget.currentLanguage),
        icon: Icons.menu_book_outlined,
        buttonText: isGl ? 'Explorar Contos' : 'Explorar Cuentos',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CuentosListScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
                audioService: widget.audioService,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _laminasTitle.resolve(widget.currentLanguage),
        description: _laminasSubtitle.resolve(widget.currentLanguage),
        icon: Icons.photo_library_outlined,
        buttonText: isGl ? 'Ver Láminas' : 'Ver Láminas',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LaminasGalleryScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
                audioService: widget.audioService,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _lecturaTitle.resolve(widget.currentLanguage),
        description: _lecturaSubtitle.resolve(widget.currentLanguage),
        icon: Icons.spellcheck_outlined,
        buttonText: isGl ? 'Entrar en Lectura' : 'Entrar en Lectura',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AprenderALerScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
                audioService: widget.audioService,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _calendarioTitle.resolve(widget.currentLanguage),
        description: _calendarioSubtitle.resolve(widget.currentLanguage),
        icon: Icons.calendar_month_outlined,
        buttonText: isGl
            ? 'Ver Calendario Escola · Fogar'
            : 'Ver Calendario Escuela · Hogar',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CalendarioScreen(
                store: widget.calendario ?? CalendarioStore(),
                initialLanguage: widget.currentLanguage,
                onLanguageChanged: widget.onLanguageChanged,
                repository: widget.repository,
                audioService: widget.audioService,
                premios: widget.premios,
              ),
            ),
          );
        },
      ),
      if (widget.premios != null) ...[
        const SizedBox(height: 24.0),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PremiosScreen(
                repository: widget.premios!,
                currentLanguage: widget.currentLanguage,
                contadores: widget.calendario?.contadores,
              ),
            ),
          ),
          icon: const Icon(Icons.military_tech_outlined),
          label: Text(PremiosScreen.titulo.resolve(widget.currentLanguage)),
        ),
        const SizedBox(height: 8.0),
        Text(
          _premiosSubtitle.resolve(widget.currentLanguage),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: AppTheme.textMuted),
        ),
      ],
    ];
  }

  List<Widget> _buildDocentesModules(BuildContext context, bool isGl) {
    return [
      _buildModuleCard(
        context: context,
        title: _juegaTitle.resolve(widget.currentLanguage),
        description: _juegaSubtitle.resolve(widget.currentLanguage),
        icon: Icons.school_outlined,
        buttonText: isGl ? 'Entrar en Modo Aula' : 'Entrar en Modo Aula',
        formacionKey: const ValueKey('formacion_docente'),
        formacionTexto: isGl
            ? 'Antes de entrar na aula · 2 min'
            : 'Antes de entrar en el aula · 2 min',
        onFormacion: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => FormacionScreen(
                perfil: PerfilFormacion.docente,
                language: widget.currentLanguage,
              ),
            ),
          );
        },
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => UnidadesListScreen(
                repository: widget.repository,
                premios: widget.premios,
                calendario: widget.calendario,
                audioService: widget.audioService,
                initialLanguage: widget.currentLanguage,
                onLanguageChanged: widget.onLanguageChanged,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _planificadorTitle.resolve(widget.currentLanguage),
        description: _planificadorSubtitle.resolve(widget.currentLanguage),
        icon: Icons.calendar_view_month_outlined,
        buttonText: isGl ? 'Abrir Planificador' : 'Abrir Planificador',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => PlanificadorScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _englishTitle.resolve(widget.currentLanguage),
        description: _englishSubtitle.resolve(widget.currentLanguage),
        icon: Icons.language_outlined,
        buttonText: isGl ? 'Entrar en Inglés L3' : 'Entrar en Inglés L3',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EnglishHubScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
                audioService: widget.audioService,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _estrategiasTitle.resolve(widget.currentLanguage),
        description: _estrategiasSubtitle.resolve(widget.currentLanguage),
        icon: Icons.psychology_outlined,
        buttonText: isGl ? 'Ver Estratexias' : 'Ver Estrategias',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EstrategiasScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _dinamicasTitle.resolve(widget.currentLanguage),
        description: _dinamicasSubtitle.resolve(widget.currentLanguage),
        icon: Icons.groups_outlined,
        buttonText: isGl ? 'Explorar Dinámicas' : 'Explorar Dinámicas',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DinamicasScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 16.0),
      _buildModuleCard(
        context: context,
        title: _corpusTitle.resolve(widget.currentLanguage),
        description: _corpusSubtitle.resolve(widget.currentLanguage),
        icon: Icons.format_list_numbered_outlined,
        buttonText: isGl ? 'Abrir Corpus' : 'Abrir Corpus',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => VocabularioInglesScreen(
                repository: widget.repository,
                initialLanguage: widget.currentLanguage,
                audioService: widget.audioService,
              ),
            ),
          );
        },
      ),
    ];
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
    String? formacionTexto,
    VoidCallback? onFormacion,
    Key? formacionKey,
  }) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      AppTheme.secondarySeaGlass.withValues(alpha: 0.25),
                  radius: 24,
                  child: Icon(icon, color: AppTheme.primaryVigoBlue, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryVigoBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            if (formacionTexto != null && onFormacion != null)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: formacionKey,
                  onPressed: onFormacion,
                  icon: const Icon(Icons.school_outlined, size: 20),
                  label: Text(formacionTexto),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryInk,
                    minimumSize: const Size(0, AppTheme.touchMin),
                    textStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
