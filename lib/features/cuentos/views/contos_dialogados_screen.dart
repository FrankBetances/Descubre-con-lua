import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/conto_dialogado_model.dart';

/// Los cuentos dialogados de una unidad del plan curricular (F12).
class ContosDialogadosScreen extends StatelessWidget {
  final String unidade;
  final String tituloUnidade;
  final List<ContoDialogado> contos;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const ContosDialogadosScreen({
    super.key,
    required this.unidade,
    required this.tituloUnidade,
    required this.contos,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'Contos dialogados' : 'Cuentos dialogados',
        language: language,
        // La lengua se elige en la pantalla anterior; aquí solo se ve.
        onLanguageChanged: (_) {},
      ),
      body: SafeArea(
        child: ListView(
          key: ValueKey('contos_$unidade'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Text(
              tituloUnidade,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isGl
                  ? '${contos.length} contos desta unidade. Cóntaos ti, lámina a lámina: Lúa só fala inglés.'
                  : '${contos.length} cuentos de esta unidad. Cuéntalos tú, lámina a lámina: Lúa solo habla inglés.',
              style: const TextStyle(
                  fontSize: 15, color: AppTheme.textSecondary, height: 1.35),
            ),
            const SizedBox(height: 12),
            for (final c in contos)
              Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  key: ValueKey('conto_${c.id}'),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  title: Text(
                    c.titulo.resolve(language),
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${c.id} · ${c.laminas.length} ${isGl ? 'láminas' : 'láminas'} · ${c.palabrasDiana.join(', ')}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(RutaLua(
                    de: context,
                    builder: (_) => ContoDialogadoScreen(
                      conto: c,
                      language: language,
                      audioService: audioService,
                    ),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Un cuento dialogado, lámina a lámina, con la plantilla del documento:
/// dibujo, narración de la adulta, frase de Lúa, tríada CROWD, espera y
/// recast.
class ContoDialogadoScreen extends StatefulWidget {
  final ContoDialogado conto;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const ContoDialogadoScreen({
    super.key,
    required this.conto,
    required this.language,
    this.audioService,
  });

  @override
  State<ContoDialogadoScreen> createState() => _ContoDialogadoScreenState();
}

class _ContoDialogadoScreenState extends State<ContoDialogadoScreen> {
  int _i = 0;

  static const _niveis = {
    'nivel1': ('Nivel 1 · sinalar', 'Nivel 1 · señalar'),
    'nivel2': ('Nivel 2 · imitar', 'Nivel 2 · imitar'),
    'nivel3': ('Nivel 3 · achegar á súa vida', 'Nivel 3 · acercar a su vida'),
  };
  static const _recast = {
    'silencio': ('Se cala', 'Si se calla'),
    'linguaCasa': (
      'Se responde na lingua de casa',
      'Si responde en la lengua de casa'
    ),
    'aproximacion': ('Se se achega á palabra', 'Si se acerca a la palabra'),
  };

  Widget _chip(FraseDoConto f) => BotonEscuchar(
        audioService: widget.audioService,
        texto: f.en,
        language: AppLanguage.en,
        interfaz: widget.language,
        comoChip: true,
        significado: f.significado,
      );

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final c = widget.conto;
    final l = c.laminas[_i];
    final ultima = _i == c.laminas.length - 1;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: c.titulo.resolve(lang),
        language: lang,
        onLanguageChanged: (_) {},
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                key: ValueKey('conto_dialogado_${c.id}_$_i'),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  Text(
                    isGl
                        ? 'Lámina ${_i + 1} de ${c.laminas.length}'
                        : 'Lámina ${_i + 1} de ${c.laminas.length}',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: context.acento),
                  ),
                  const SizedBox(height: 8),
                  // La lámina aún no está dibujada (F9): se describe lo que
                  // tiene que verse, para que la adulta la muestre con un
                  // dibujo propio o con el objeto real.
                  Container(
                    key: const Key('conto_dibujo'),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: context.acentoTint,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    ),
                    child: Text(
                      '${isGl ? 'Na lámina' : 'En la lámina'}: ${l.dibujo.resolve(lang)}',
                      style: const TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textPrimary,
                          height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l.narracion.resolve(lang),
                    style: const TextStyle(
                        fontSize: 17,
                        color: AppTheme.textPrimary,
                        height: 1.45),
                  ),
                  if (l.lua case final lua?) ...[
                    const SizedBox(height: 12),
                    Text(isGl ? 'LÚA DI' : 'LÚA DICE',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: context.acento)),
                    const SizedBox(height: 6),
                    _chip(lua),
                    if (l.onomatopeia case final o? when o.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(o,
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic)),
                      ),
                  ],
                  const SizedBox(height: 14),
                  for (final (k, f) in l.crowd) ...[
                    Text(
                      isGl ? _niveis[k]?.$1 ?? k : _niveis[k]?.$2 ?? k,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    _chip(f),
                    if (f.axuda case final a?)
                      Padding(
                        padding: const EdgeInsets.only(top: 4, bottom: 10),
                        child: Text(a.resolve(lang),
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                                height: 1.35)),
                      )
                    else
                      const SizedBox(height: 10),
                  ],
                  if (l.espera case final e?)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.warningBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                          '${isGl ? 'Agarda' : 'Espera'}: ${e.resolve(lang)}',
                          style: const TextStyle(
                              fontSize: 14, color: AppTheme.warning)),
                    ),
                  if (l.recast.isNotEmpty)
                    ExpansionTile(
                      key: ValueKey('conto_recast_$_i'),
                      tilePadding: EdgeInsets.zero,
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      title: Text(
                        isGl
                            ? 'Se responde... (recast)'
                            : 'Si responde... (recast)',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: context.acento),
                      ),
                      children: [
                        for (final (k, f) in l.recast) ...[
                          Text(isGl ? _recast[k]?.$1 ?? k : _recast[k]?.$2 ?? k,
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          _chip(f),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const Key('conto_anterior'),
                      onPressed: _i == 0 ? null : () => setState(() => _i--),
                      child: Text(isGl ? 'Anterior' : 'Anterior'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      key: const Key('conto_seguinte'),
                      onPressed: ultima
                          ? () => Navigator.of(context).pop()
                          : () => setState(() => _i++),
                      child: Text(ultima
                          ? (isGl ? 'Rematar' : 'Terminar')
                          : (isGl ? 'Seguinte' : 'Siguiente')),
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
