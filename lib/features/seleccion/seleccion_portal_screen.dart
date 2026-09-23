import 'package:flutter/material.dart';

import '../../core/audio/offline_audio_service.dart';
import '../../core/brand/ilustracion_portal.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/storage/calendario_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/paxina_sen_scroll.dart';
import '../../data/models/formacion_model.dart';
import '../../data/repositories/content_repository.dart';
import '../academy/widgets/selector_idioma_widget.dart';
import '../docentes/portal_docentes_screen.dart';
import '../familias/portal_familias_screen.dart';
import '../formacion/views/formacion_screen.dart';
import '../premios/premios_repository.dart';

/// Pantalla principal de selección entre Portal Familias e Portal Docentes.
///
/// Cumpre o mandato estrito de deseño:
/// - Dúas tarxetas destacadas con cadansúa ilustración debuxada:
///   1. Tarxeta Familias: simboliza o fogar, o acollemento e a crianza (con debuxo propio).
///   2. Tarxeta Docentes: simboliza a escola infantil municipal e o aula (con debuxo propio).
/// - Navegación a dúas pantallas completamente independentes que non comparten o mesmo deseño.
class SeleccionPortalScreen extends StatefulWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SeleccionPortalScreen({
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
  State<SeleccionPortalScreen> createState() => _SeleccionPortalScreenState();
}

class _SeleccionPortalScreenState extends State<SeleccionPortalScreen> {
  late AppLanguage _language;

  static const _appBarTitle = LocalizedString(
    gl: 'Descubre con Lúa · Vigo',
    es: 'Descubre con Lúa · Vigo',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Escolas infantís municipais de Vigo · Recursos pedagóxicos para as familias e o profesorado',
    es: 'Escuelas infantiles municipales de Vigo · Recursos pedagógicos para las familias y el profesorado',
  );

  static const _invitacion = LocalizedString(
    gl: 'Elixe o teu perfil para acceder ao teu espazo independente:',
    es: 'Elige tu perfil para acceder a tu espacio independiente:',
  );

  static const _privacyNotice = LocalizedString(
    gl: 'Sen conexión e sen datos persoais. O único que se garda neste aparello é a túa propia conta de uso. Deseñado baixo o Decreto 150/2022.',
    es: 'Sin conexión y sin datos personales. Lo único que se guarda en este aparato es tu propia cuenta de uso. Diseñado bajo el Decreto 150/2022.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.currentLanguage;
  }

  @override
  void didUpdateWidget(covariant SeleccionPortalScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _language = widget.currentLanguage;
    }
  }

  void _handleLanguageChanged(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = _language == AppLanguage.gl;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        title: Text(_appBarTitle.resolve(_language)),
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
        child: PaxinaSenScroll(
          desprazarSeNonCabe: true,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cabeceira institucional
              Text(
                _subtitulo.resolve(_language),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF4A5568),
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                _invitacion.resolve(_language),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18.0),

              // ==========================================
              // TARXETA 1: PORTAL FAMILIAS (Hogar / Crianza)
              // ==========================================
              _buildPortalCard(
                context: context,
                badge: isGl
                    ? 'HOGAR E CRIANZA · CERO PANTALLAS'
                    : 'HOGAR Y CRIANZA · CERO PANTALLAS',
                badgeColor: const Color(0xFFDD6B20),
                badgeBg: const Color(0xFFFFF9EE),
                title: isGl ? 'Portal Familias' : 'Portal Familias',
                subtitle: isGl
                    ? 'Para nais, pais e familias. Estimulación sensorial, fonolóxica e comunicativa no fogar sen pantallas para os nenos.'
                    : 'Para madres, padres y familias. Estimulación sensorial, fonológica y comunicativa en el hogar sin pantallas para los niños.',
                illustration: const IlustracionFamilia(height: 145),
                puntosClave: [
                  isGl
                      ? 'Calendario escolar de casa: de 0 a 6 anos, curso a curso, e actividades diarias de 3 min'
                      : 'Calendario escolar de casa: de 0 a 6 años, curso a curso, y actividades diarias de 3 min',
                  isGl
                      ? 'Biblioteca de contos dialóxicos con preguntas graduadas'
                      : 'Biblioteca de cuentos dialógicos con preguntas graduadas',
                  isGl
                      ? 'Aprender a ler manipulativo: fonética, cubos CVC e mesa Alphabot'
                      : 'Aprender a leer manipulativo: fonética, cubos CVC y mesa Alphabot',
                  isGl
                      ? '200+ láminas táctiles, xogos TPR corporais e pautas de crianza'
                      : '200+ láminas táctiles, juegos TPR corporales y pautas de crianza',
                ],
                buttonText: isGl
                    ? 'Entrar no Portal Familias'
                    : 'Entrar en el Portal Familias',
                buttonColor: const Color(0xFFDD6B20),
                formacionTexto: isGl
                    ? 'Antes de empezar na casa · Guía de 2 min'
                    : 'Antes de empezar en casa · Guía de 2 min',
                onFormacion: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FormacionScreen(
                        perfil: PerfilFormacion.familia,
                        language: _language,
                      ),
                    ),
                  );
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PortalFamiliasScreen(
                        repository: widget.repository,
                        audioService: widget.audioService,
                        currentLanguage: _language,
                        onToggleLanguage: widget.onToggleLanguage,
                        onLanguageChanged: _handleLanguageChanged,
                        premios: widget.premios,
                        calendario: widget.calendario,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20.0),

              // ==========================================
              // TARXETA 2: PORTAL DOCENTES (Escola / Aula)
              // ==========================================
              _buildPortalCard(
                context: context,
                badge: isGl
                    ? 'ESCOLA INFANTIL · MODO AULA'
                    : 'ESCUELA INFANTIL · MODO AULA',
                badgeColor: AppTheme.primaryVigoBlue,
                badgeBg: const Color(0xFFEFF6FC),
                title: isGl ? 'Portal Docentes' : 'Portal Docentes',
                subtitle: isGl
                    ? 'Para o profesorado das escolas municipais de Vigo. Programación de aula a 72 bpm, planificador curricular e recursos pedagóxicos.'
                    : 'Para el profesorado de las escuelas municipales de Vigo. Programación de aula a 72 bpm, planificador curricular y recursos pedagógicos.',
                illustration: const IlustracionEscola(height: 145),
                puntosClave: [
                  isGl
                      ? 'Juega con Lúa: asambleas guiadas (1.º e 2.º ciclo) e canción a pulso'
                      : 'Juega con Lúa: asambleas guiadas (1.º y 2.º ciclo) y canción a pulso',
                  'Planificador curricular',
                  isGl
                      ? 'Calendario escolar de aula sincronizado co fogar'
                      : 'Calendario escolar de aula sincronizado con el hogar',
                  isGl
                      ? 'Inmersión en inglés L3: 44 fonemas, colocacións e FSRS'
                      : 'Inmersión en inglés L3: 44 fonemas, colocaciones y FSRS',
                ],
                buttonText: isGl
                    ? 'Entrar no Portal Docentes'
                    : 'Entrar en el Portal Docentes',
                buttonColor: AppTheme.primaryVigoBlue,
                formacionTexto: isGl
                    ? 'Antes de entrar na aula · Guía de 2 min'
                    : 'Antes de entrar en el aula · Guía de 2 min',
                onFormacion: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FormacionScreen(
                        perfil: PerfilFormacion.docente,
                        language: _language,
                      ),
                    ),
                  );
                },
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PortalDocentesScreen(
                        repository: widget.repository,
                        audioService: widget.audioService,
                        currentLanguage: _language,
                        onToggleLanguage: widget.onToggleLanguage,
                        onLanguageChanged: _handleLanguageChanged,
                        premios: widget.premios,
                        calendario: widget.calendario,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24.0),

              // Tarxeta de seguridade e privacidade
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
                          _privacyNotice.resolve(_language),
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

  Widget _buildPortalCard({
    required BuildContext context,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required String title,
    required String subtitle,
    required Widget illustration,
    required List<String> puntosClave,
    required String buttonText,
    required Color buttonColor,
    required VoidCallback onTap,
    String? formacionTexto,
    VoidCallback? onFormacion,
  }) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: const BorderSide(color: AppTheme.border, width: 1.2),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ilustración debuxada que simboliza a familia ou a escola
            illustration,

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge superior
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: badgeColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 10.5,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Título
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 21,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Subtítulo descritivo
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4A5568),
                      fontSize: 13.5,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Lista de puntos destacados
                  ...puntosClave.map((punto) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 16,
                            color: badgeColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              punto,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF2D3748),
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 14),

                  // Botón de formación e botón de entrada, UN DEBAIXO DO
                  // OUTRO.
                  //
                  // Estaban os dous na mesma fila, e nun teléfono non caben:
                  // «Entrar no Portal Docentes» a 13.5 bold máis o enlace de
                  // formación desbordaban 95 px a 400 de ancho e 136 coa
                  // escala de texto grande. A 800 px —o ancho que trae o test
                  // por defecto— non se notaba nada.
                  //
                  // Non é un axuste de padding: nun teléfono a acción
                  // principal vai a ancho completo, que é ademais máis doado
                  // de acertar co dedo.
                  if (formacionTexto != null && onFormacion != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton.icon(
                        onPressed: onFormacion,
                        icon: const Icon(Icons.school_outlined, size: 16),
                        label: Text(
                          formacionTexto,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryInk,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 36),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                      ),
                      child: Text(
                        buttonText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
