import 'package:flutter/material.dart';
import 'core/audio/local_audio_player.dart';
import 'core/audio/offline_audio_service.dart';
import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'data/models/capsula_model.dart';
import 'data/models/unidad_model.dart';
import 'data/repositories/content_repository.dart';
import 'core/storage/calendario_store.dart';
import 'features/academy/views/bloques_list_screen.dart';
import 'features/academy/views/capsula_detail_screen.dart';
import 'features/academy/views/guia_atencion_screen.dart';
import 'features/bienvenida/welcome_screen.dart';
import 'features/calendario/views/calendario_screen.dart';
import 'features/creditos/credits_screen.dart';
import 'features/premios/premios_repository.dart';
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
import 'features/seleccion/seleccion_portal_screen.dart';
import 'features/familias/portal_familias_screen.dart';
import 'features/docentes/portal_docentes_screen.dart';
import 'features/calendario/views/calendario_fogar_screen.dart';
import 'features/familias/views/xogos_fogar_screen.dart';

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
        '/': (context) => WelcomeScreen(
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onLanguageChanged: _setLanguage,
              onStart: () =>
                  Navigator.of(context).pushReplacementNamed('/home'),
              onShowCredits: () => Navigator.of(context).pushNamed('/creditos'),
            ),
        '/creditos': (context) => CreditsScreen(
              currentLanguage: _currentLanguage,
            ),
        '/home': (context) => SeleccionPortalScreen(
              repository: _repository,
              premios: _premios,
              calendario: _calendario,
              audioService: _audioService,
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/portal-familias': (context) => PortalFamiliasScreen(
              repository: _repository,
              premios: _premios,
              calendario: _calendario,
              audioService: _audioService,
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/portal-docentes': (context) => PortalDocentesScreen(
              repository: _repository,
              premios: _premios,
              calendario: _calendario,
              audioService: _audioService,
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/calendario-fogar': (context) => CalendarioFogarScreen(
              repository: _repository,
              store: _calendario,
              initialLanguage: _currentLanguage,
              audioService: _audioService,
              onLanguageChanged: _setLanguage,
            ),
        '/xogos-fogar': (context) => XogosFogarScreen(
              initialLanguage: _currentLanguage,
              audioService: _audioService,
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

enum PortalRole {
  familias,
  docentes,
}

/// Compatibility wrapper for HomeScreen that redirects to SeleccionPortalScreen.
class HomeScreen extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SeleccionPortalScreen(
      repository: repository,
      premios: premios,
      calendario: calendario,
      audioService: audioService,
      currentLanguage: currentLanguage,
      onToggleLanguage: onToggleLanguage,
      onLanguageChanged: onLanguageChanged,
    );
  }
}
