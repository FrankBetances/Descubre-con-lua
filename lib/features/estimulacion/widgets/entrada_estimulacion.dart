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
    this.compacta = false,
  });

  final String cursoId;
  final int mesCalendario;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;
  final OfflineAudioService? audioService;
  final bool enAula;
  final ValueChanged<String>? onCambiarCurso;

  /// Arriba de Hoxe (F-20261120-2): una línea, para que el camino de la
  /// semana siga entrando en la primera pantalla.
  final bool compacta;

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
            padding: compacta
                ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                : const EdgeInsets.all(14),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: LaminaEscena(
                    clave: 'ico_estimulacion',
                    ancho: compacta ? 30 : 52,
                  ),
                ),
                SizedBox(width: compacta ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (compacta)
                        Text(titulo,
                            maxLines: 2,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontTitulos,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                              height: 1.2,
                            ))
                      else
                        Text(
                          titulo,
                          style: TextStyle(
                            fontFamily: AppTheme.fontTitulos,
                            fontSize: compacta ? 16 : 17,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                            height: 1.2,
                          ),
                        ),
                      if (!compacta) const SizedBox(height: 4),
                      if (!compacta)
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
                SizedBox(width: compacta ? 2 : 6),
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
