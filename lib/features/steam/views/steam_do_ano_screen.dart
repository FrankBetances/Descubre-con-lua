import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/steam_do_mes_model.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import 'steam_do_mes_screen.dart';

/// Los diez experimentos STEAM del curso, mes a mes (F10): la biblioteca,
/// para ver el año entero y no solo el mes de hoy.
class SteamDoAnoScreen extends StatefulWidget {
  final String cursoId;
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;
  final bool enCasa;

  const SteamDoAnoScreen({
    super.key,
    required this.cursoId,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
    this.enCasa = false,
  });

  @override
  State<SteamDoAnoScreen> createState() => _SteamDoAnoScreenState();
}

class _SteamDoAnoScreenState extends State<SteamDoAnoScreen> {
  late AppLanguage _lang = widget.language;
  late final Future<SteamDoMes> _steam = SteamDoMes.cargar();
  static const _meses = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  @override
  Widget build(BuildContext context) {
    final lang = _lang;
    final isGl = lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'STEAM do curso' : 'STEAM del curso',
        language: lang,
        onLanguageChanged: (l) {
          setState(() => _lang = l);
          widget.onLanguageChanged?.call(l);
        },
      ),
      body: SafeArea(
        child: FutureBuilder<SteamDoMes>(
          future: _steam,
          builder: (context, snap) {
            final s = snap.data;
            if (s == null) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView(
              key: const Key('steam_do_ano'),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              children: [
                Text(
                  isGl
                      ? 'Un experimento cada mes, co tema da unidade. O deste mes sae en Hoxe.'
                      : 'Un experimento cada mes, con el tema de la unidad. El de este mes sale en Hoy.',
                  style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.35),
                ),
                const SizedBox(height: 12),
                for (final m in _meses)
                  if (s.para(widget.cursoId, m) case final e?)
                    Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        key: ValueKey('steam_ano_${e.id}'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        title: Text(e.titulo.resolve(lang),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w800)),
                        subtitle: Text(
                            '${nomeDoMes[m]!.resolve(lang)} · ${e.nomeFenomeno.resolve(lang)}',
                            style: const TextStyle(fontSize: 14)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).push(RutaLua(
                          de: context,
                          builder: (_) => SteamDoMesScreen(
                            experimento: e,
                            language: lang,
                            audioService: widget.audioService,
                            enCasa: widget.enCasa,
                          ),
                        )),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}
