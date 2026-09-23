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
/// - Cockpit pedagóxico de traballo diario para o profesorado.
/// - Ritmo de adquisición natural: 5 palabras novas/día e matriz de reforzo acumulativo.
/// - Asambleas guiadas a 72 bpm, canción a pulso visual, matemáticas temperás.
/// - Planificador de 10 meses / 50 meses baixo o Decreto 150/2022 e inmersión en inglés L3.
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

  String _obtenerPlanDoDia(bool isGl) {
    final weekday = DateTime.now().weekday; // 1 = Luns .. 5 = Venres
    switch (weekday) {
      case 1:
        return isGl
            ? 'Luns · Bloque A (5 palabras novas) · Modelado motriz directo e pulso a 72 bpm.'
            : 'Lunes · Bloque A (5 palabras nuevas) · Modelado motriz directo y pulso a 72 bpm.';
      case 2:
        return isGl
            ? 'Martes · Bloque B (5 novas) + Repaso Bloque A (10 palabras) · Contraste motriz e velocidade.'
            : 'Martes · Bloque B (5 nuevas) + Repaso Bloque A (10 palabras) · Contraste motriz y velocidad.';
      case 3:
        return isGl
            ? 'Mércores · Bloque C (5 novas) + Repaso A e B (15 palabras) · Circuíto TPR con comandos encadeados.'
            : 'Miércoles · Bloque C (5 nuevas) + Repaso A y B (15 palabras) · Circuito TPR con comandos encadenados.';
      case 4:
        return isGl
            ? 'Xoves · Bloque D (5 novas) + Repaso A, B e C (20 palabras) · Conto motor integrado das 20 palabras.'
            : 'Jueves · Bloque D (5 nuevas) + Repaso A, B y C (20 palabras) · Cuento motor integrado de las 20 palabras.';
      case 5:
        return isGl
            ? 'Venres · 0 novas + Consolidación total (20 palabras) · ¡Gran Reto TPR Acumulativo e Freeze!'
            : 'Viernes · 0 nuevas + Consolidación total (20 palabras) · ¡Gran Reto TPR Acumulativo y Freeze!';
      default:
        return isGl
            ? 'Fin de semana · Planificación: 20 palabras preparadas para a vindeira semana.'
            : 'Fin de semana · Planificación: 20 palabras preparadas para la próxima semana.';
    }
  }

  List<String> _obtenerPalabrasDoDia() {
    final weekday = DateTime.now().weekday;
    switch (weekday) {
      case 1:
        return const ['Head', 'Shoulders', 'Knees', 'Toes', 'Freeze'];
      case 2:
        return const ['Eyes', 'Ears', 'Mouth', 'Nose', 'Jump'];
      case 3:
        return const ['Hands', 'Feet', 'Walk', 'Stop', 'Turn'];
      case 4:
        return const ['Big', 'Small', 'Up', 'Down', 'Clap'];
      case 5:
        return const ['Freeze', 'Head', 'Eyes', 'Hands', 'Big'];
      default:
        return const ['Head', 'Shoulders', 'Knees', 'Toes', 'Freeze'];
    }
  }

  void _mostrarProxeccionAnual(BuildContext context, bool isGl) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFEBF8FF),
                      radius: 20,
                      child: Icon(Icons.bar_chart_rounded,
                          color: AppTheme.primaryVigoBlue, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGl
                                ? 'PROXECCIÓN LÉXICA ANUAL (800 PALABRAS)'
                                : 'PROYECCIÓN LÉXICA ANUAL (800 PALABRAS)',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryVigoBlue,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isGl
                                ? 'Adquisición Natural · 10 Meses'
                                : 'Adquisición Natural · 10 Meses',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isGl
                            ? 'Rendemento Matemático do Curso Escolar'
                            : 'Rendimiento Matemático del Curso Escolar',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryInk,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMatematicaRow(
                        isGl ? 'Luns a Xoves:' : 'Lunes a Jueves:',
                        isGl
                            ? '5 palabras novas/día × 4 días = 20 / semana'
                            : '5 palabras nuevas/día × 4 días = 20 / semana',
                      ),
                      const SizedBox(height: 4),
                      _buildMatematicaRow(
                        isGl ? 'Venres:' : 'Viernes:',
                        isGl
                            ? '0 novas + Gran Reto TPR das 20 da semana'
                            : '0 nuevas + Gran Reto TPR de las 20 de la semana',
                      ),
                      const SizedBox(height: 4),
                      _buildMatematicaRow(
                        isGl ? 'Rendemento Mensual:' : 'Rendimiento Mensual:',
                        isGl
                            ? '20 palabras/semana × 4 semanas = 80 / mes'
                            : '20 palabras/semana × 4 semanas = 80 / mes',
                      ),
                      const SizedBox(height: 4),
                      _buildMatematicaRow(
                        isGl ? 'Rendemento Anual:' : 'Rendimiento Anual:',
                        isGl
                            ? '80 palabras/mes × 10 meses = 800 palabras / curso'
                            : '80 palabras/mes × 10 meses = 800 palabras / curso',
                        destacado: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  isGl
                      ? 'DISTRIBUCIÓN POR CATEGORÍAS (CDI MacArthur-Bates & Rescorla)'
                      : 'DISTRIBUCIÓN POR CATEGORÍAS (CDI MacArthur-Bates & Rescorla)',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategoriaItem(
                  titulo: isGl ? 'Sustantivos (Nouns) ~35%' : 'Sustantivos (Nouns) ~35%',
                  detalle: isGl
                      ? '280 palabras · Etiquetas concretas (corpo, animais, obxectos)'
                      : '280 palabras · Etiquetas concretas (cuerpo, animales, objetos)',
                  cor: const Color(0xFF3182CE),
                  porcentaxe: 0.35,
                ),
                const SizedBox(height: 10),
                _buildCategoriaItem(
                  titulo: isGl ? 'Verbos de Acción (Verbs) ~25%' : 'Verbos de Acción (Verbs) ~25%',
                  detalle: isGl
                      ? '200 palabras · Comandos motrices TPR (jump, freeze, walk, stop)'
                      : '200 palabras · Comandos motrices TPR (jump, freeze, walk, stop)',
                  cor: const Color(0xFF38A169),
                  porcentaxe: 0.25,
                ),
                const SizedBox(height: 10),
                _buildCategoriaItem(
                  titulo: isGl ? 'Adxectivos / Sensorial ~20%' : 'Adjetivos / Sensorial ~20%',
                  detalle: isGl
                      ? '160 palabras · Atributos e cualidades perceptivas (big, soft, cold)'
                      : '160 palabras · Atributos y cualidades perceptivas (big, soft, cold)',
                  cor: const Color(0xFFDD6B20),
                  porcentaxe: 0.20,
                ),
                const SizedBox(height: 10),
                _buildCategoriaItem(
                  titulo: isGl ? 'Oracións e Preguntas ~12%' : 'Oraciones y Preguntas ~12%',
                  detalle: isGl
                      ? '96 palabras · Sintaxe básica e interacción comunicativa'
                      : '96 palabras · Sintaxis básica e interacción comunicativa',
                  cor: const Color(0xFF805AD5),
                  porcentaxe: 0.12,
                ),
                const SizedBox(height: 10),
                _buildCategoriaItem(
                  titulo: isGl ? 'Complexas e Conectores ~8%' : 'Complejas y Conectores ~8%',
                  detalle: isGl
                      ? '64 palabras · Fluidez natural, conectores e matices'
                      : '64 palabras · Fluidez natural, conectores y matices',
                  cor: const Color(0xFFD69E2E),
                  porcentaxe: 0.08,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryVigoBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isGl ? 'Pechar Proxección' : 'Cerrar Proyección',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildMatematicaRow(String label, String valor,
      {bool destacado = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: destacado ? FontWeight.w800 : FontWeight.bold,
            color: destacado ? AppTheme.primaryDark : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            valor,
            style: TextStyle(
              fontSize: 12,
              fontWeight: destacado ? FontWeight.w800 : FontWeight.w500,
              color: destacado ? AppTheme.primaryDark : const Color(0xFF4A5568),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoriaItem({
    required String titulo,
    required String detalle,
    required Color cor,
    required double porcentaxe,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
            Text(
              '${(porcentaxe * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: cor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: porcentaxe,
            backgroundColor: cor.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(cor),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detalle,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = _language == AppLanguage.gl;
    final planDoDia = _obtenerPlanDoDia(isGl);
    final palabrasDoDia = _obtenerPalabrasDoDia();

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
            const SizedBox(height: 16.0),

            // Card Destacada: Hoxe na Aula (Asamblea & Dinámica TPR das 5 Palabras)
            Card(
              elevation: 1,
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(
                    color: AppTheme.primaryVigoBlue, width: 1.5),
              ),
              color: const Color(0xFFF0F7FF),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryTint,
                          child: Icon(Icons.bolt_rounded,
                              color: AppTheme.primaryVigoBlue, size: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGl
                                    ? 'HOXE NA AULA · RITMO TPR'
                                    : 'HOY EN EL AULA · RITMO TPR',
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryVigoBlue,
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                isGl
                                    ? 'Matriz de Reforzo Acumulativo'
                                    : 'Matriz de Refuerzo Acumulativo',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryInk,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      planDoDia,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF2D3748),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: palabrasDoDia.map((palabra) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFBEE3F8)),
                          ),
                          child: Text(
                            palabra,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2B6CB0),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
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
                            icon: const Icon(Icons.play_arrow_rounded,
                                size: 18),
                            label: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isGl
                                    ? 'Iniciar Asemblea de Hoxe'
                                    : 'Iniciar Asamblea de Hoy',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryVigoBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () =>
                              _mostrarProxeccionAnual(context, isGl),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                                color: AppTheme.primaryVigoBlue),
                            foregroundColor: AppTheme.primaryVigoBlue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            isGl ? 'Ver 800 Palabras' : 'Ver 800 Palabras',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 11.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18.0),

            // ==========================================
            // SECCIÓN 1: ASEMBLEA E AULA ACTIVA
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                isGl
                    ? '1. ASEMBLEA E AULA ACTIVA (72 BPM)'
                    : '1. ASAMBLEA Y AULA ACTIVA (72 BPM)',
                style: const TextStyle(
                  fontSize: 11.5,
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
            const SizedBox(height: 12.0),

            // 2. Dinámicas de Aula Activa
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
            const SizedBox(height: 20.0),

            // ==========================================
            // SECCIÓN 2: PLANIFICACIÓN CURRICULAR E CALENDARIO
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                isGl
                    ? '2. PLANIFICACIÓN CURRICULAR E CALENDARIO'
                    : '2. PLANIFICACIÓN CURRICULAR Y CALENDARIO',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // 3. Calendario Curricular de Aula (10 Meses Estruturados)
            _buildDocenteModuleCard(
              context: context,
              title: isGl
                  ? 'Calendario Escola · Fogar'
                  : 'Calendario Escuela · Hogar',
              description: isGl
                  ? 'Sincronización curricular dos 10 meses lectivos estructurados por trimestres (Outono, Inverno e Primavera): asambleas na aula e notas de conexión para as familias.'
                  : 'Sincronización curricular de los 10 meses lectivos estructurados por trimestres (Otoño, Invierno y Primavera): asambleas en el aula y notas de conexión para las familias.',
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
            const SizedBox(height: 12.0),

            // 4. Planificador Curricular (50 Meses)
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
            const SizedBox(height: 20.0),

            // ==========================================
            // SECCIÓN 3: INMERSIÓN L3 E ESTRATEXIAS DOCENTES
            // ==========================================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Text(
                isGl
                    ? '3. INMERSIÓN L3 E ESTRATEXIAS DOCENTES'
                    : '3. INMERSIÓN L3 Y ESTRATEGIAS DOCENTES',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),

            // 5. Inmersión en Inglés L3
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
            const SizedBox(height: 12.0),

            // 6. Estratexias Pedagóxicas
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
            const SizedBox(height: 12.0),

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
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: iconBg,
                    radius: 20,
                    child: Icon(icon, color: iconColor, size: 22),
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
                    minimumSize: const Size(0, 38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
