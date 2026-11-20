import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/movimiento.dart';
import '../../docentes/nomes_docentes.dart';
import '../../familias/nomes_familias.dart';
import '../data/estimulacion_ui.dart';
import '../views/estimulacion_screen.dart';

/// P9.3 · Entrada principal destacada hacia «Estimulación da linguaxe e o pensamento»
/// desde Na casa (Inicio / Hoxe) e Modo Aula.
class EntradaEstimulacionCard extends StatelessWidget {
  const EntradaEstimulacionCard({
    super.key,
    required this.cursoId,
    required this.mesCalendario,
    required this.language,
    required this.onLanguageChanged,
    this.audioService,
    this.enAula = false,
    this.onCambiarCurso,
  });

  final String cursoId;
  final int mesCalendario;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final OfflineAudioService? audioService;
  final bool enAula;
  final ValueChanged<String>? onCambiarCurso;

  @override
  Widget build(BuildContext context) {
    final titulo = enAula
        ? NomesDocentes.estimulacion.resolve(language)
        : NomesFamilias.estimulacion.resolve(language);
    final descricion = enAula
        ? NomesDocentes.estimulacionDi.resolve(language)
        : NomesFamilias.estimulacionDi.resolve(language);
    final mesCurso = EstimulacionUi.mesDeCalendario(mesCalendario);

    return Pulsable(
      child: Material(
        key: Key(
            enAula ? 'entrada_estimulacion_aula' : 'entrada_estimulacion_casa'),
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          side: BorderSide(color: context.acento.withAlpha(90), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).push(
            RutaLua(
              de: context,
              builder: (_) => EstimulacionScreen(
                language: language,
                onLanguageChanged: onLanguageChanged,
                audioService: audioService,
                initialCursoId: cursoId,
                initialMes: mesCurso,
                enAula: enAula,
                onCambiarCurso: onCambiarCurso,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: const LaminaEscena(
                    clave: 'ico_estimulacion',
                    ancho: 52,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontTitulos,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        descricion,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: context.acento,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
