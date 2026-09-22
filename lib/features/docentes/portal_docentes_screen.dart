import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/formacion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../academy/widgets/selector_idioma_widget.dart';
import '../calendario/views/calendario_screen.dart';
import '../english/views/english_hub_screen.dart';
import '../formacion/views/formacion_screen.dart';
import '../juega/views/unidades_list_screen.dart';
import '../palabras/views/vocabulario_ingles_screen.dart';
import '../planificador/views/dinamicas_screen.dart';
import '../planificador/views/estrategias_screen.dart';
import '../planificador/views/planificador_screen.dart';
import '../premios/premios_repository.dart';

/// Pantalla independente do Portal Docentes.
///
/// Deseñada especificamente para as escolas infantís municipais de Vigo:
/// - Programación de aula para os dous ciclos de Educación Infantil (0 a 6 anos).
/// - Asambleas guiadas a 72 bpm, canción a pulso visual, matemáticas temperás.
/// - Planificador de 50 meses baixo o Decreto 150/2022 e inmersión en inglés L3.
class PortalDocentesScreen extends StatefulWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const PortalDocentesScreen({
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
  State<PortalDocentesScreen> createState() => _PortalDocentesScreenState();
}

class _PortalDocentesScreenState extends State<PortalDocentesScreen> {
  late AppLanguage _language;

  static const _appBarTitle = LocalizedString(
    gl: 'Portal Docentes · Escola',
    es: 'Portal Docentes · Escuela',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Recursos pedagóxicos para as escolas infantís municipais de Vigo. Asambleas de aula a 72 bpm, planificador curricular e estratexias educativas.',
    es: 'Recursos pedagógicos para las escuelas infantiles municipales de Vigo. Asambleas de aula a 72 bpm, planificador curricular y estrategias educativas.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.currentLanguage;
  }

  @override
  void didUpdateWidget(covariant PortalDocentesScreen oldWidget) {
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
            // Cabecera Pedagóxica Institucional
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFEFF6FC),
                    Color(0xFFDCEBFA),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFBBD7F5)),
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
                          color: AppTheme.primaryVigoBlue,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isGl
                              ? 'MODO AULA · DOCENTES'
                              : 'MODO AULA · DOCENTES',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.school_rounded,
                        color: AppTheme.primaryVigoBlue,
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isGl
                        ? 'Escolas infantís de Vigo'
                        : 'Escuelas infantiles de Vigo',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryInk,
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
                  // Botón de Formación Docente
                  TextButton.icon(
                    key: const ValueKey('formacion_docente_portal'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FormacionScreen(
                            perfil: PerfilFormacion.docente,
                            language: _language,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.school_outlined,
                        size: 18, color: AppTheme.primaryInk),
                    label: Text(
                      isGl
                          ? 'Antes de entrar na aula · Guía de 2 min'
                          : 'Antes de entrar en el aula · Guía de 2 min',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryInk,
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
            const SizedBox(height: 18.0),

            // Título de Sección
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                isGl
                    ? 'PROGRAMACIÓN E AULA ACTIVA'
                    : 'PROGRAMACIÓN Y AULA ACTIVA',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // 1. Juega con Lúa · Modo Aula
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Juega con Lúa · Modo Aula'
                  : 'Juega con Lúa · Modo Aula',
              description: isGl
                  ? 'Asambleas guiadas para 1.º Ciclo (0-2 e 2-3 anos) e 2.º Ciclo (4, 5 e 6 de Infantil), canción a pulso visual a 72 bpm, exploración sensorial e matemáticas temperás.'
                  : 'Asambleas guiadas para 1.º Ciclo (0-2 y 2-3 años) y 2.º Ciclo (4, 5 y 6 de Infantil), canción a pulso visual a 72 bpm, exploración sensorial y matemáticas tempranas.',
              icon: Icons.groups_rounded,
              iconColor: AppTheme.primaryVigoBlue,
              iconBg: AppTheme.primaryTint,
              badge: isGl ? '1.º e 2.º Ciclo' : '1.º y 2.º Ciclo',
              buttonText: isGl ? 'Entrar en Modo Aula' : 'Entrar en Modo Aula',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => UnidadesListScreen(
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

            // 2. Planificador Curricular (50 Meses)
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Planificador Curricular (50 Meses)'
                  : 'Planificador Curricular (50 Meses)',
              description: isGl
                  ? 'Programación curricular completa dos 5 cursos de Educación Infantil (0 a 6 anos) con obxectivos e actividades baixo o Decreto 150/2022.'
                  : 'Programación curricular completa de los 5 cursos de Educación Infantil (0 a 6 años) con objetivos y actividades bajo el Decreto 150/2022.',
              icon: Icons.calendar_view_month_rounded,
              iconColor: const Color(0xFF2B6CB0),
              iconBg: const Color(0xFFEBF8FF),
              badge: isGl ? '50 Meses Curriculares' : '50 Meses Curriculares',
              buttonText: isGl ? 'Abrir Planificador' : 'Abrir Planificador',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PlanificadorScreen(
                      repository: widget.repository,
                      initialLanguage: _language,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14.0),

            // 3. Calendario Curricular de Aula
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Calendario Escola · Fogar'
                  : 'Calendario Escuela · Hogar',
              description: isGl
                  ? 'Sincronización curricular de 10 meses (Setembro a Xuño): asambleas na aula e notas de conexión para as familias.'
                  : 'Sincronización curricular de 10 meses (Septiembre a Junio): asambleas en el aula y notas de conexión para las familias.',
              icon: Icons.calendar_month_rounded,
              iconColor: const Color(0xFF319795),
              iconBg: const Color(0xFFE6FFFA),
              badge: isGl ? '10 Meses Lectivos' : '10 Meses Lectivos',
              buttonText: isGl ? 'Ver Calendario' : 'Ver Calendario',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CalendarioScreen(
                      store: widget.calendario ?? CalendarioStore(),
                      initialLanguage: _language,
                      onLanguageChanged: _handleLanguageChanged,
                      repository: widget.repository,
                      audioService: widget.audioService,
                      premios: widget.premios,
                      esDocenteInicial: true,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14.0),

            // 4. Inmersión en Inglés L3
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Inmersión en Inglés · L3'
                  : 'Inmersión en Inglés · L3',
              description: isGl
                  ? 'Inventario dos 44 fonemas do inglés, adestrador de repetición espazada FSRS, colocacións gramaticais e comprensión auditiva.'
                  : 'Inventario de los 44 fonemas del inglés, entrenador de repetición espaciada FSRS, colocaciones gramaticales y comprensión auditiva.',
              icon: Icons.language_rounded,
              iconColor: const Color(0xFF805AD5),
              iconBg: const Color(0xFFFAF5FF),
              badge: isGl ? 'Phonics & FSRS' : 'Phonics & FSRS',
              buttonText: isGl ? 'Entrar en Inglés L3' : 'Entrar en Inglés L3',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EnglishHubScreen(
                      repository: widget.repository,
                      initialLanguage: _language,
                      audioService: widget.audioService,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14.0),

            // 5. Estratexias Pedagóxicas
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Estratexias Pedagóxicas de Aula'
                  : 'Estrategias Pedagógicas de Aula',
              description: isGl
                  ? '5 estratexias clave de aula: andamiaxe, modelado, tempo de espera de 5 segundos, expansión léxica e recast con diálogos reais.'
                  : '5 estrategias clave de aula: andamiaje, modelado, tiempo de espera de 5 segundos, expansión léxica y recast con diálogos reales.',
              icon: Icons.psychology_rounded,
              iconColor: const Color(0xFFD69E2E),
              iconBg: const Color(0xFFFEFCBF),
              badge: isGl ? 'Metodoloxía' : 'Metodología',
              buttonText: isGl ? 'Ver Estratexias' : 'Ver Estrategias',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EstrategiasScreen(
                      repository: widget.repository,
                      initialLanguage: _language,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14.0),

            // 6. Dinámicas de Aula Activa
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Dinámicas de Aula Activa'
                  : 'Dinámicas de Aula Activa',
              description: isGl
                  ? 'Catálogo de dinámicas activas con roles, espazos, materiais e protocolo de avaliación cualitativa sen pantallas.'
                  : 'Catálogo de dinámicas activas con roles, espacios, materiales y protocolo de evaluación cualitativa sin pantallas.',
              icon: Icons.hub_rounded,
              iconColor: const Color(0xFF38A169),
              iconBg: const Color(0xFFC6F6D5),
              badge: isGl ? 'Aula Activa' : 'Aula Activa',
              buttonText: isGl ? 'Explorar Dinámicas' : 'Explorar Dinámicas',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DinamicasScreen(
                      repository: widget.repository,
                      initialLanguage: _language,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14.0),

            // 7. Corpus 8.000 Palabras
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Corpus 8.000 Palabras (BNC/COCA)'
                  : 'Corpus 8.000 Palabras (BNC/COCA)',
              description: isGl
                  ? 'Explorador léxico con bandas de frecuencia 1k-8k e clasificación curricular CEFR (A1-C2).'
                  : 'Explorador léxico con bandas de frecuencia 1k-8k y clasificación curricular CEFR (A1-C2).',
              icon: Icons.format_list_numbered_rounded,
              iconColor: const Color(0xFF4A5568),
              iconBg: const Color(0xFFEDF2F7),
              badge: isGl ? 'Corpus Léxico' : 'Corpus Léxico',
              buttonText: isGl ? 'Abrir Corpus' : 'Abrir Corpus',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VocabularioInglesScreen(
                      repository: widget.repository,
                      initialLanguage: _language,
                      audioService: widget.audioService,
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24.0),

            // Garantía de Privacidade
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
                        isGl
                            ? 'Sen conexión e sen datos persoais. O único que se garda neste aparello é a túa propia conta de uso. Deseñado baixo o Decreto 150/2022.'
                            : 'Sin conexión y sin datos personales. Lo único que se guarda en este aparato es tu propia cuenta de uso. Diseñado bajo el Decreto 150/2022.',
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

  Widget _buildDocenteModuleCard({
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
    final theme = Theme.of(context);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: iconBg,
                  radius: 22,
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: iconBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: iconColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
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
              style: theme.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF4A5568),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryVigoBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
