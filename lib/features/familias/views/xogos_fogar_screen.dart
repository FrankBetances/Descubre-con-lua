import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/que_observar.dart';
import '../../../data/models/xogos_fogar_model.dart';
import '../../../data/models/xogos_fogar_observar_model.dart';
import '../../../core/widgets/aviso_contenido_ilegible.dart';
import '../../../core/widgets/cabecera.dart';
import '../nomes_familias.dart';

/// Pantalla de Dinámicas e Xogos Físicos no Fogar.
///
/// Baseada en `/tangible-l2-parent-orchestrator`:
/// 1. Espazo Físico do Neno: manipulativo, cinestésico e puramente acústico (Cero Pantallas).
/// 2. Espazo Dixital do Adulto: partitura de facilitación, comando TPR e «Que observar».
class XogosFogarScreen extends StatefulWidget {
  final AppLanguage initialLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// O «Que observar» de cada xogo, se quen abre a pantalla xa o leu. Existe
  /// polo mesmo que en «Aprender a Ler»: un test ten que poder darllo feito.
  final ObservacionsXogosFogar? observacions;

  /// Os xogos, se quen abre a pantalla xa os leu (un test). Se non, a
  /// pantalla lé `assets/content/xogos_fogar.json`.
  final XogosFogar? xogos;

  const XogosFogarScreen({
    super.key,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.audioService,
    this.observacions,
    this.xogos,
  });

  @override
  State<XogosFogarScreen> createState() => _XogosFogarScreenState();
}

class _XogosFogarScreenState extends State<XogosFogarScreen> {
  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  late AppLanguage _language;
  String _filtroIdade = 'todas';
  ObservacionsXogosFogar? _observacions;
  XogosFogar? _xogos;
  Object? _erroXogos;

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _xogos = widget.xogos;
    if (_xogos == null) {
      XogosFogar.cargar().then((x) {
        if (mounted) setState(() => _xogos = x);
      }).catchError((Object e) {
        // Un fallo de lectura se enseña: sin esto la pantalla saldría vacía
        // sin decir por qué.
        if (mounted) setState(() => _erroXogos = e);
      });
    }
    _observacions = widget.observacions;
    if (_observacions == null) {
      ObservacionsXogosFogar.cargar().then((o) {
        if (mounted) setState(() => _observacions = o);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final isGl = lang == AppLanguage.gl;

    final xogosFiltrados = (_xogos?.xogos ?? const <XogoFogar>[]).where((x) {
      if (_filtroIdade == 'todas') return true;
      return x.idade.contains(_filtroIdade);
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesFamilias.movementoCabeceira.resolve(_language),
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: _erroXogos != null
            ? AvisoContenidoIlegible(
                asset: XogosFogar.assetPath,
                language: lang,
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Banner de Garantía Zero-Screen
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9EE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFF6D4A0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.volunteer_activism_rounded,
                          color: context.acento,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isGl
                                    ? 'XOGO 100% CORPORAL E FÍSICO'
                                    : 'JUEGO 100% CORPORAL Y FÍSICO',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: context.acento,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isGl
                                    ? 'A pantalla é a túa partitura. A crianza xoga con obxectos reais da casa, movemento corporal e a túa voz viva.'
                                    : 'La pantalla es tu partitura. La criatura juega con objetos reales de la casa, movimiento corporal y tu voz viva.',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Filtro por idades
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFiltroChip('todas',
                            isGl ? 'Todas as idades' : 'Todas las edades'),
                        const SizedBox(width: 8),
                        _buildFiltroChip('0-2', '0 a 2 anos'),
                        const SizedBox(width: 8),
                        _buildFiltroChip('2-4', '2 a 4 anos'),
                        const SizedBox(width: 8),
                        _buildFiltroChip('2-6', '3 a 6 anos'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Lista de Xogos
                  ...xogosFiltrados.map((xogo) => _buildCardXogo(xogo, isGl)),
                ],
              ),
      ),
    );
  }

  Widget _buildFiltroChip(String id, String label) {
    final isSelected = _filtroIdade == id;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _filtroIdade = id),
    );
  }

  Widget _buildCardXogo(XogoFogar xogo, bool isGl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0.5,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeceira do xogo
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDF2F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.sports_gymnastics_rounded,
                    color: context.acento,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        xogo.titulo.resolve(_language),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.acentoTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              xogo.idade,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: context.acento,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              '${xogo.duracionMin} min',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Materiais reais da casa
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_rounded,
                      size: 16, color: Color(0xFF4A5568)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${isGl ? "Materiais" : "Materiales"}: ${xogo.materiais.resolve(_language)}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF4A5568),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Orde física en inglés (L3 TPR)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEBF8FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBEE3F8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.record_voice_over_rounded,
                          size: 16, color: Color(0xFF2B6CB0)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Comando oral (inglés L3)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2B6CB0),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '«${xogo.fraseEn}»',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A365D),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Guión verbal para o adulto (Partitura)
            Text(
              isGl ? 'A túa guía verbal:' : 'Tu guía verbal:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              xogo.guionAdulto.resolve(_language),
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF2D3748), height: 1.35),
            ),
            const SizedBox(height: 10),

            // Acción kinestésica
            Text(
              isGl ? 'Movemento da crianza:' : 'Movimiento de la criatura:',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              xogo.accionKinestesica.resolve(_language),
              style: const TextStyle(
                  fontSize: 14, color: Color(0xFF4A5568), height: 1.35),
            ),
            const SizedBox(height: 14),

            // Que observar: pistas que se len e non se marcan. Antes era un
            // rexistro «Logrado · Asistido · Explorando» que pedía á familia
            // avaliar a súa criatura e non gardaba nada.
            QueObservar(
              pistas: _observacions?.de(xogo.id) ?? const [],
              language: _language,
            ),
          ],
        ),
      ),
    );
  }
}
