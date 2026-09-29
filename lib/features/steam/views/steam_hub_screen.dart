import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/steam_cooperativo_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import 'steam_sesion_guiada_screen.dart';

/// Hub principal do Módulo STEAM Cooperativo de Indagación Temperá.
///
/// Deseñado tanto para o Portal Docentes (Modo Aula) como para o Portal Familias (Fogar):
/// - 5 unidades canónicas calibradas neuroevolutivamente de I1 a I5 (0 a 6 anos).
/// - 100% analóxico e manipulativo: Cero Pantallas para a Crianza.
/// - Xogo cooperativo en parellas con roles físicos complementarios.
/// - Estímulos fónicos TPR en inglés L2 de baixa latencia (<80 ms) e sen texto visible para o menor.
class SteamHubScreen extends StatefulWidget {
  final ContentRepository repository;
  final OfflineAudioService audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SteamHubScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.initialLanguage,
    this.onLanguageChanged,
  });

  @override
  State<SteamHubScreen> createState() => _SteamHubScreenState();
}

class _SteamHubScreenState extends State<SteamHubScreen> {
  late AppLanguage _language;
  String _selectedStage = 'todos'; // 'todos', 'I1', 'I2', 'I3', 'I4', 'I5'
  bool _isLoading = false;

  static const _appBarTitle = LocalizedString(
    gl: 'STEAM Cooperativo · Indagación e TPR',
    es: 'STEAM Cooperativo · Indagación y TPR',
  );

  static const _intro = LocalizedString(
    gl: 'Descubrimento analóxico, ciencia cotiá e xogo cooperativo en parellas sen pantallas (0 a 6 anos). Cada experiencia combina materiais reais, roles colaborativos e comandos auditivos en inglés (TPR).',
    es: 'Descubrimiento analógico, ciencia cotidiana y juego cooperativo en parejas sin pantallas (0 a 6 años). Cada experiencia combina materiales reales, roles colaborativos y comandos auditivos en inglés (TPR).',
  );

  static const List<Map<String, String>> _stageFilters = [
    {'id': 'todos', 'gl': 'Todos os niveis', 'es': 'Todos los niveles'},
    {'id': 'I1', 'gl': 'I1 · 12-24 meses', 'es': 'I1 · 12-24 meses'},
    {'id': 'I2', 'gl': 'I2 · 2-3 anos', 'es': 'I2 · 2-3 años'},
    {'id': 'I3', 'gl': 'I3 · 3-4 anos', 'es': 'I3 · 3-4 años'},
    {'id': 'I4', 'gl': 'I4 · 4-5 anos', 'es': 'I4 · 4-5 años'},
    {'id': 'I5', 'gl': 'I5 · 5-6 anos', 'es': 'I5 · 5-6 años'},
  ];

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    if (widget.repository.steamUnits.isEmpty) {
      _isLoading = true;
      widget.repository.loadSteamUnits().then((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }).catchError((_) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      });
    }
  }

  @override
  void didUpdateWidget(covariant SteamHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
  }

  void _handleLanguageChanged(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  List<SteamUnit> get _filteredUnits {
    final all = widget.repository.steamUnits;
    if (_selectedStage == 'todos') return all;
    return all.where((u) => u.nivelMadurativo == _selectedStage).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;
    final units = _filteredUnits;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          _appBarTitle.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
        child: Column(
          children: [
            // Cabecera informativa y filtro de estadios
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryTint,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.borderActive),
                        ),
                        child: Text(
                          isGl
                              ? 'ZERO-SCREEN CHILD INTERACTION'
                              : 'ZERO-SCREEN CHILD INTERACTION',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryInk,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.biotech_rounded,
                          color: AppTheme.primary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _intro.resolve(_language),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF4A5568),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filtro por estadio madurativo
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _stageFilters.map((stg) {
                        final isSel = _selectedStage == stg['id'];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(isGl ? stg['gl']! : stg['es']!),
                            selected: isSel,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedStage = stg['id']!);
                              }
                            },
                            selectedColor: AppTheme.primary,
                            labelStyle: TextStyle(
                              color: isSel ? Colors.white : AppTheme.textPrimary,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.border),

            // Lista de experiencias STEAM
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : units.isEmpty
                      ? Center(
                          child: Text(
                            isGl
                                ? 'Non se atoparon experiencias para este nivel.'
                                : 'No se encontraron experiencias para este nivel.',
                            style: const TextStyle(color: AppTheme.textMuted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: units.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            return _buildUnitCard(context, units[index], isGl);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, SteamUnit unit, bool isGl) {
    final tieneSeguridadMayor4cm =
        unit.materiales.every((m) => m.seguridadMayor4cm);

    return Card(
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Nivel + Rango edad + Duración
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryTint,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.borderActive),
                  ),
                  child: Text(
                    '${unit.nivelMadurativo} · ${unit.rangoEdad.resolve(_language)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryInk,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.access_time_rounded,
                    size: 15, color: AppTheme.textMuted),
                const SizedBox(width: 4),
                Text(
                  '${unit.tiempoEstimadoMin} min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Título
            Text(
              unit.titulo.resolve(_language),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryInk,
              ),
            ),
            const SizedBox(height: 4),

            // Fenómeno científico analógico
            Text(
              unit.fenomeno.resolve(_language),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF4A5568),
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),

            // Distintivo de seguridad para menores de 3 años (previsión de asfixia)
            if (tieneSeguridadMayor4cm) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.successBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_outlined,
                        size: 14, color: AppTheme.success),
                    const SizedBox(width: 6),
                    Text(
                      (unit.nivelMadurativo == 'I1' ||
                              unit.nivelMadurativo == 'I2')
                          ? (isGl
                              ? 'Seguridade 0-3 anos: obxectos > 4 cm (sen risco de asfixia)'
                              : 'Seguridad 0-3 años: objetos > 4 cm (sin riesgo de asfixia)')
                          : (isGl
                              ? 'Materiais seguros: obxectos > 4 cm'
                              : 'Materiales seguros: objetos > 4 cm'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Dinámica y Roles Cooperativos
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE9D8FD)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.groups_rounded,
                          size: 16, color: Color(0xFF805AD5)),
                      const SizedBox(width: 6),
                      Text(
                        isGl
                            ? 'Xogo Cooperativo en Parellas'
                            : 'Juego Cooperativo en Parejas',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF553C9A),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    unit.dinamicaCooperativa.descripcion.resolve(_language),
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Comando TPR en inglés
            Row(
              children: [
                const Icon(Icons.hearing_rounded,
                    size: 18, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(
                  'TPR: «${unit.tprIngles.comando}» ${unit.tprIngles.ipa}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  isGl ? 'Cero pantallas' : 'Cero pantallas',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Botón de inicio de sesión guiada
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton.icon(
                key: ValueKey('iniciar_steam_${unit.id}'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => SteamSesionGuiadaScreen(
                        unit: unit,
                        audioService: widget.audioService,
                        initialLanguage: _language,
                        onLanguageChanged: _handleLanguageChanged,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                label: Text(
                  isGl ? 'Abrir Partitura Guiada' : 'Abrir Partitura Guiada',
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
