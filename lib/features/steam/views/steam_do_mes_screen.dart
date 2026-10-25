import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/steam_do_mes_model.dart';

/// El experimento STEAM del mes (F8): material, seguridad, cómo se hace en el
/// aula o en casa, las órdenes en inglés y qué observar.
class SteamDoMesScreen extends StatefulWidget {
  final ExperimentoSteam experimento;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final bool enCasa;

  const SteamDoMesScreen({
    super.key,
    required this.experimento,
    required this.language,
    this.audioService,
    this.enCasa = false,
  });

  @override
  State<SteamDoMesScreen> createState() => _SteamDoMesScreenState();
}

class _SteamDoMesScreenState extends State<SteamDoMesScreen> {
  late AppLanguage _lang = widget.language;

  @override
  Widget build(BuildContext context) {
    final e = widget.experimento;
    final lang = _lang;
    final enCasa = widget.enCasa;
    final audioService = widget.audioService;
    final isGl = lang == AppLanguage.gl;
    Widget rotulo(String t) => Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 6),
          child: Text(t,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: context.acento)),
        );
    Widget texto(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(t,
              style: const TextStyle(
                  fontSize: 15, color: AppTheme.textPrimary, height: 1.4)),
        );
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: 'STEAM',
        language: lang,
        onLanguageChanged: (l) => setState(() => _lang = l),
      ),
      body: SafeArea(
        child: ListView(
          key: ValueKey('steam_do_mes_${e.id}'),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Text(e.nomeFenomeno.resolve(lang).toUpperCase(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: context.acento)),
            const SizedBox(height: 4),
            Text(e.titulo.resolve(lang),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary)),
            Container(
              key: const Key('steam_seguridade'),
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.warningBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                  '${isGl ? 'Seguridade' : 'Seguridad'}: ${e.seguridade.resolve(lang)}',
                  style:
                      const TextStyle(fontSize: 14, color: AppTheme.warning)),
            ),
            rotulo(isGl ? 'MATERIAL' : 'MATERIAL'),
            for (final m in e.material) texto('· ${m.resolve(lang)}'),
            rotulo(enCasa
                ? (isGl ? 'NA CASA' : 'EN CASA')
                : (isGl ? 'NA AULA' : 'EN EL AULA')),
            for (final (i, p) in (enCasa ? e.casa : e.aula).indexed)
              texto('${i + 1}. ${p.resolve(lang)}'),
            rotulo(isGl
                ? 'EN INGLÉS (dous toques: o significado)'
                : 'EN INGLÉS (dos toques: el significado)'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final o in e.ordes)
                  BotonEscuchar(
                    audioService: audioService,
                    texto: o.en,
                    language: AppLanguage.en,
                    interfaz: lang,
                    comoChip: true,
                    significado: o.significado,
                  ),
              ],
            ),
            rotulo(isGl ? 'QUE OBSERVAR' : 'QUÉ OBSERVAR'),
            texto(e.observar.resolve(lang)),
          ],
        ),
      ),
    );
  }
}
