import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/unidade_do_mes_model.dart';
import '../../../data/repositories/content_repository.dart';

/// El núcleo del mes encima de los recursos de inglés (M7.1): palabras,
/// repaso y escucha abren por lo que se queda todo el mes, y el banco va
/// debajo, como ampliación.
class NucleoArriba extends StatelessWidget {
  final ContentRepository repository;
  final String cursoId;
  final int mesCalendario;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const NucleoArriba({
    super.key,
    required this.repository,
    required this.cursoId,
    required this.mesCalendario,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return FutureBuilder<UnidadeDoMes?>(
      key: ValueKey('nucleo_arriba_$cursoId.$mesCalendario'),
      future: repository.loadUnidadeDoMes(cursoId, mesCalendario),
      initialData: repository.unidadeDoMesSync(cursoId, mesCalendario),
      builder: (context, snap) {
        final u = snap.data;
        final List<PezaDaUnidade> nucleo =
            u == null ? const [] : repository.nucleoSync(u);
        if (nucleo.isEmpty) return const SizedBox.shrink();
        return Container(
          key: const Key('nucleo_arriba'),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.acentoTint,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGl
                    ? 'PRIMEIRO, O NÚCLEO DO MES'
                    : 'PRIMERO, EL NÚCLEO DEL MES',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: context.acento,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                isGl
                    ? 'O que se queda todo o mes. O resto do banco vai debaixo, como ampliación.'
                    : 'Lo que se queda todo el mes. El resto del banco va debajo, como ampliación.',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final p in nucleo)
                    BotonEscuchar(
                      audioService: audioService,
                      texto: p.en,
                      language: AppLanguage.en,
                      interfaz: language,
                      style: estiloIngles(p.en),
                      comoChip: true,
                      colorChip: context.acento,
                      descripcion: p.en,
                      significado: p.significado,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
