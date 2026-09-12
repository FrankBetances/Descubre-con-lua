import 'package:flutter/material.dart';
import 'core/audio/local_audio_player.dart';
import 'core/audio/offline_audio_service.dart';
import 'core/localization/app_language.dart';
import 'core/localization/localized_string.dart';
import 'core/theme/app_theme.dart';
import 'data/models/capsula_model.dart';
import 'data/models/unidad_model.dart';
import 'data/repositories/content_repository.dart';
import 'features/academy/views/bloques_list_screen.dart';
import 'features/academy/views/capsula_detail_screen.dart';
import 'features/academy/widgets/selector_idioma_widget.dart';
import 'features/bienvenida/welcome_screen.dart';
import 'features/creditos/credits_screen.dart';
import 'features/premios/premios_repository.dart';
import 'features/premios/premios_screen.dart';
import 'features/juega/views/asamblea_guiada_screen.dart';
import 'features/juega/views/unidades_list_screen.dart';

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
  final OfflineAudioService? audioService;
  final AppLanguage initialLanguage;

  const DescubreConLuaApp({
    super.key,
    this.contentRepository,
    this.premiosRepository,
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
  late final OfflineAudioService _audioService;
  bool _createdInternalAudioService = false;

  @override
  void initState() {
    super.initState();
    _currentLanguage = widget.initialLanguage;
    _repository = widget.contentRepository ?? ContentRepository();
    _premios = widget.premiosRepository ?? PremiosRepository();
    _premios.cargar();
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
        // La bienvenida es la primera pantalla, como en Valeria+. No guarda que
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
              audioService: _audioService,
              currentLanguage: _currentLanguage,
              onToggleLanguage: _toggleLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/academy': (context) => BloquesListScreen(
              repository: _repository,
              premios: _premios,
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
        '/juega': (context) => UnidadesListScreen(
              repository: _repository,
              audioService: _audioService,
              initialLanguage: _currentLanguage,
              onLanguageChanged: _setLanguage,
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/academy/capsula') {
          final capsula = settings.arguments as Capsula?;
          if (capsula != null) {
            return MaterialPageRoute(
              builder: (context) => CapsulaDetailScreen(
                capsula: capsula,
                premios: _premios,
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
class HomeScreen extends StatelessWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const HomeScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
    this.premios,
  });

  static const _appBarTitle = LocalizedString(
    gl: 'Descubre con Lúa · Vigo',
    es: 'Descubre con Lúa · Vigo',
  );

  static const _subtitle = LocalizedString(
    gl: 'Recurso pedagóxico e familiar para o 1º ciclo de educación infantil (0-3 anos)',
    es: 'Recurso pedagógico y familiar para el 1.er ciclo de educación infantil (0-3 años)',
  );

  static const _juegaTitle = LocalizedString(
    gl: 'Juega con Lúa · Aula',
    es: 'Juega con Lúa · Aula',
  );

  static const _juegaSubtitle = LocalizedString(
    gl: 'Para docentes: unidades temáticas de Vigo, asamblea guiada con canción a pulso offline, exploración sensorial e matemáticas temperás.',
    es: 'Para docentes: unidades temáticas de Vigo, asamblea guiada con canción a pulso offline, exploración sensorial y matemáticas tempranas.',
  );

  static const _academyTitle = LocalizedString(
    gl: 'Academy · Familias',
    es: 'Academy · Familias',
  );

  static const _academySubtitle = LocalizedString(
    gl: 'Para familias: 5 bloques de desenvolvemento da comunicación, lectura en 4 partes con exemplos cotiáns sen pantallas infantís.',
    es: 'Para familias: 5 bloques de desarrollo de la comunicación, lectura en 4 partes con ejemplos cotidianos sin pantallas infantiles.',
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = currentLanguage == AppLanguage.gl;

    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle.resolve(currentLanguage)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: currentLanguage,
              onLanguageChanged: (newLang) {
                if (onLanguageChanged != null) {
                  onLanguageChanged!(newLang);
                } else {
                  onToggleLanguage();
                }
              },
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                _subtitle.resolve(currentLanguage),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4A5568),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildModuleCard(
              context: context,
              title: _juegaTitle.resolve(currentLanguage),
              description: _juegaSubtitle.resolve(currentLanguage),
              icon: Icons.school_outlined,
              buttonText: isGl ? 'Entrar en Modo Aula' : 'Entrar en Modo Aula',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UnidadesListScreen(
                      repository: repository,
                      audioService: audioService,
                      initialLanguage: currentLanguage,
                      onLanguageChanged: onLanguageChanged,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            _buildModuleCard(
              context: context,
              title: _academyTitle.resolve(currentLanguage),
              description: _academySubtitle.resolve(currentLanguage),
              icon: Icons.family_restroom_outlined,
              buttonText: isGl ? 'Entrar en Academy' : 'Entrar en Academy',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BloquesListScreen(
                      repository: repository,
                      premios: premios,
                      initialLanguage: currentLanguage,
                      onLanguageChanged: onLanguageChanged,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24.0),
            if (premios != null)
              OutlinedButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PremiosScreen(
                      repository: premios!,
                      currentLanguage: currentLanguage,
                    ),
                  ),
                ),
                icon: const Icon(Icons.military_tech_outlined),
                label: Text(PremiosScreen.titulo.resolve(currentLanguage)),
              ),
            if (premios != null) ...[
              const SizedBox(height: 8.0),
              Text(
                _premiosSubtitle.resolve(currentLanguage),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppTheme.textMuted),
              ),
              const SizedBox(height: 24.0),
            ],
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
                        _privacyNotice.resolve(currentLanguage),
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
    );
  }

  Widget _buildModuleCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required String buttonText,
    required VoidCallback onTap,
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
