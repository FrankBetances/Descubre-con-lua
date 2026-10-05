import 'package:flutter/material.dart';
import 'core/audio/local_audio_player.dart';
import 'core/audio/offline_audio_service.dart';
import 'core/localization/app_language.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/content_repository.dart';
import 'core/storage/calendario_store.dart';
import 'features/bienvenida/welcome_screen.dart';
import 'features/creditos/credits_screen.dart';
import 'features/premios/premios_repository.dart';
import 'features/familias/portal_familias_screen.dart';
import 'features/docentes/portal_docentes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = ContentRepository();
  await repository.initialize();
  // El inglés del curso —cinco palabras al día— lo usan el portal, el
  // calendario y la asamblea: se lee una vez aquí y lo encuentran ya leído.
  await repository.loadProgramaTpr();
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
              onCasa: () => Navigator.of(context).pushNamed('/portal-familias'),
              onEscola: () =>
                  Navigator.of(context).pushNamed('/portal-docentes'),
              onShowCredits: () => Navigator.of(context).pushNamed('/creditos'),
            ),
        '/creditos': (context) => CreditsScreen(
              currentLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/portal-familias': (context) => Theme(
              data: AppTheme.temaFamilias,
              child: PortalFamiliasScreen(
                repository: _repository,
                premios: _premios,
                calendario: _calendario,
                audioService: _audioService,
                currentLanguage: _currentLanguage,
                onToggleLanguage: _toggleLanguage,
                onLanguageChanged: _setLanguage,
              ),
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
      },
    );
  }
}
