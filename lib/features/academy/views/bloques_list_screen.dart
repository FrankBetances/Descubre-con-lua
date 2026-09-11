import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/capsula_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../widgets/selector_idioma_widget.dart';
import 'capsula_detail_screen.dart';

/// Screen displaying the 5 canonical developmental blocks of «Academy · Familias».
///
/// Designed exclusively for adult caregivers and families:
/// - Clear overview of infant neurodevelopmental areas (0-3 years).
/// - Dynamic bilingual switcher (`gl`/`es`) in AppBar.
/// - Navigation to 4-part micro-learning capsules.
/// - ZERO external web links, ZERO child games or touch mechanics.
class BloquesListScreen extends StatefulWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const BloquesListScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<BloquesListScreen> createState() => _BloquesListScreenState();
}

class _BloquesListScreenState extends State<BloquesListScreen> {
  late AppLanguage _language;

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

  IconData _iconForBloque(String iconKey) {
    switch (iconKey) {
      case 'ear_sparkles':
        return Icons.hearing_outlined;
      case 'chat_bubble_heart':
        return Icons.chat_bubble_outline;
      case 'people_arrows':
        return Icons.people_outline;
      case 'child_play':
        return Icons.sports_baseball_outlined;
      case 'home_globe':
        return Icons.language_outlined;
      default:
        return Icons.auto_stories_outlined;
    }
  }

  Color _colorFromHex(String hexString, Color fallback) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGl = _language == AppLanguage.gl;
    final bloques = widget.repository.getAllBloques();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGl ? 'Academy · Familias' : 'Academy · Familias',
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
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            // Header introduction for adult caregivers
            Container(
              padding: const EdgeInsets.all(18.0),
              decoration: BoxDecoration(
                color: AppTheme.cardSurface,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppTheme.primaryVigoBlue.withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.family_restroom_outlined,
                        color: AppTheme.primaryVigoBlue,
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isGl
                              ? 'Desenvolvemento infantil no fogar'
                              : 'Desarrollo infantil en el hogar',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryVigoBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    isGl
                        ? 'Guías prácticas de lectura rápida (3 minutos) baseadas na evidencia para acompañar a linguaxe e a comunicación dende o nacemento ata os 3 anos sen pantallas.'
                        : 'Guías prácticas de lectura rápida (3 minutos) basadas en la evidencia para acompañar el lenguaje y la comunicación desde el nacimiento hasta los 3 años sin pantallas.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16.0,
                      height: 1.5,
                      color: AppTheme.textSlate,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Section title
            Text(
              isGl
                  ? 'Os 5 bloques de desenvolvemento'
                  : 'Los 5 bloques de desarrollo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryVigoBlue,
                fontSize: 19.0,
              ),
            ),
            const SizedBox(height: 14.0),

            // List of the 5 canonical blocks
            ...bloques.map((bloque) {
              final capsulas = widget.repository.getCapsulasByBloqueId(bloque.id);
              final blockColor = _colorFromHex(bloque.colorHex, AppTheme.primaryVigoBlue);
              final icon = _iconForBloque(bloque.icono);

              return Card(
                margin: const EdgeInsets.only(bottom: 16.0),
                elevation: 0,
                color: AppTheme.cardSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(
                    color: blockColor.withOpacity(0.35),
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: blockColor.withOpacity(0.15),
                            child: Icon(icon, color: blockColor, size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                    vertical: 2.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: blockColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    isGl
                                        ? 'Bloque ${bloque.orden}'
                                        : 'Bloque ${bloque.orden}',
                                    style: TextStyle(
                                      color: blockColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  bloque.titulo.resolve(_language),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontSize: 17.5,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textSlate,
                                    height: 1.25,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        bloque.descripcion.resolve(_language),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16.0,
                          height: 1.45,
                          color: const Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Capsules list or status
                      if (capsulas.isNotEmpty) ...[
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          isGl ? 'Cápsulas dispoñibles:' : 'Cápsulas disponibles:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryVigoBlue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...capsulas.map((c) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8.0),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: BorderSide(
                                  color: blockColor.withOpacity(0.2),
                                ),
                              ),
                              tileColor: const Color(0xFFFAF9F4),
                              leading: Icon(
                                Icons.menu_book_outlined,
                                color: blockColor,
                                size: 22,
                              ),
                              title: Text(
                                c.titulo.resolve(_language),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16.0,
                                  color: AppTheme.textSlate,
                                ),
                              ),
                              subtitle: Text(
                                isGl
                                    ? '${c.tiempoLecturaMinutos} min · 4 apartados prácticos'
                                    : '${c.tiempoLecturaMinutos} min · 4 apartados prácticos',
                                style: const TextStyle(fontSize: 13.0),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFF718096),
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CapsulaDetailScreen(
                                      capsula: c,
                                      initialLanguage: _language,
                                      onLanguageChanged: _onToggleLanguage,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12.0,
                            vertical: 8.0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0EFE7),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.hourglass_empty_outlined,
                                size: 16,
                                color: Color(0xFF718096),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  isGl
                                      ? 'Novas cápsulas deste bloque en preparación pedagóxica.'
                                      : 'Nuevas cápsulas de este bloque en preparación pedagógica.',
                                  style: const TextStyle(
                                    fontSize: 13.0,
                                    color: Color(0xFF718096),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
