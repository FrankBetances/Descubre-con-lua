import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/fila_portal.dart';
import '../../../data/models/cancion_pulso_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../docentes/nomes_docentes.dart';
import '../widgets/paso_cancion_widget.dart';

/// Recursos → Cancións con pulso: las diez canciones con el pulso dibujado.
///
/// Vinieron de la asamblea de seis pasos, que se retiró en M4.3. Quedan aquí,
/// fuera del mes, porque la canción del mes es la de su asamblea (D4). El
/// pulso se ve y no se oye: lo dibujan las marcas `*` de la letra (ver
/// CLAUDE.md, «El pulso se ve, no se oye»).
class CancionsConPulsoScreen extends StatefulWidget {
  final ContentRepository repository;
  final OfflineAudioService audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const CancionsConPulsoScreen({
    super.key,
    required this.repository,
    required this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
  });

  @override
  State<CancionsConPulsoScreen> createState() => _CancionsConPulsoScreenState();
}

class _CancionsConPulsoScreenState extends State<CancionsConPulsoScreen> {
  late AppLanguage _language = widget.initialLanguage;
  List<CancionConPulso>? _cancions;

  @override
  void initState() {
    super.initState();
    widget.repository.loadCancionsConPulso().then((c) {
      if (mounted) setState(() => _cancions = c);
    });
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

  void _abrir(CancionConPulso c) {
    Navigator.of(context).push(
      RutaLua(
        de: context,
        builder: (_) => _CancionScreen(
          cancion: c,
          audioService: widget.audioService,
          initialLanguage: _language,
          onLanguageChanged: _cambiarLingua,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final cancions = _cancions;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.cancions.resolve(lang),
        language: lang,
        onLanguageChanged: _cambiarLingua,
      ),
      body: SafeArea(
        child: cancions == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('cancions_con_pulso'),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                children: [
                  Text(
                    NomesDocentes.cancionsDi.resolve(lang),
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  for (final c in cancions) ...[
                    FilaPortal(
                      clave: c.id,
                      icona: Icons.music_note_rounded,
                      nome: c.cancion.titulo.resolve(lang),
                      di: '${c.cancion.bpm} BPM · '
                          '${c.cancion.beatsPerLine(lang)} '
                          '${lang == AppLanguage.gl ? 'tempos por verso' : 'tiempos por verso'}',
                      onTap: () => _abrir(c),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Una canción: la letra con su pulso dibujado, la voz y la consigna.
class _CancionScreen extends StatefulWidget {
  final CancionConPulso cancion;
  final OfflineAudioService audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const _CancionScreen({
    required this.cancion,
    required this.audioService,
    required this.initialLanguage,
    this.onLanguageChanged,
  });

  @override
  State<_CancionScreen> createState() => _CancionScreenState();
}

class _CancionScreenState extends State<_CancionScreen> {
  late AppLanguage _language = widget.initialLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: widget.cancion.cancion.titulo.resolve(_language),
        language: _language,
        onLanguageChanged: (l) {
          setState(() => _language = l);
          widget.onLanguageChanged?.call(l);
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          key: Key('cancion_${widget.cancion.id}'),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          child: PasoCancionWidget(
            cancion: widget.cancion.cancion,
            language: _language,
            audioService: widget.audioService,
          ),
        ),
      ),
    );
  }
}
