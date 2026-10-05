import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../../data/repositories/content_repository.dart';
import '../views/steam_sesion_guiada_screen.dart';
import 'steam_comun.dart';
import '../../../core/navigation/ruta_lua.dart';

/// Los días de la semana, del 1 (lunes) al 5 (viernes).
const List<LocalizedString> _diasDaSemana = [
  LocalizedString(gl: 'luns', es: 'lunes'),
  LocalizedString(gl: 'martes', es: 'martes'),
  LocalizedString(gl: 'mércores', es: 'miércoles'),
  LocalizedString(gl: 'xoves', es: 'jueves'),
  LocalizedString(gl: 'venres', es: 'viernes'),
];

/// «mércores da semana 2» / «miércoles de la semana 2».
String diaSteamEnTexto(SteamDiaNoCalendario d, AppLanguage language) {
  final nome = d.dia >= 1 && d.dia <= _diasDaSemana.length
      ? _diasDaSemana[d.dia - 1].resolve(language)
      : '';
  return language == AppLanguage.gl
      ? '$nome da semana ${d.semana}'
      : '$nome de la semana ${d.semana}';
}

/// La sesión STEAM que le toca a [cursoId] el día del curso [dia], o `null`.
///
/// [dia] es el de «Hoxe na aula»: su mes es el del CALENDARIO (9 es
/// septiembre), y el de la sesión, el del curso (1 es septiembre).
SteamUnit? steamDoDiaDoCurso(
  ContentRepository repository,
  String cursoId,
  DiaDoCursoTpr dia,
) {
  final lista = repository.getSteamUnitsDoDia(
    cursoId: cursoId,
    mes: SteamDiaNoCalendario.mesDoCursoDe(dia.mesCalendario),
    semana: dia.semana,
    dia: dia.dia,
  );
  return lista.isEmpty ? null : lista.first;
}

/// Abre la sesión de [unidade] en la versión de [audiencia].
void abrirSesionSteam(
  BuildContext context, {
  required SteamUnit unidade,
  required SteamAudiencia audiencia,
  required AppLanguage language,
  required OfflineAudioService? audioService,
  ValueChanged<AppLanguage>? onLanguageChanged,
}) {
  Navigator.of(context).push(
    RutaLua(
      de: context,
      builder: (_) => SteamSesionGuiadaScreen(
        unit: unidade,
        audiencia: audiencia,
        audioService: audioService,
        initialLanguage: language,
        onLanguageChanged: onLanguageChanged,
      ),
    ),
  );
}

/// La fila de la sesión STEAM del día: qué es, cuánto dura y qué órdenes en
/// inglés trae. Se toca y se abre la sesión entera, en la versión que toca.
///
/// Va en «Hoxe na aula», en el día del Modo Aula y en el día del calendario,
/// del lado del aula y del de casa. Antes la sesión solo vivía en el portal y
/// la docente tenía que acordarse de ir a buscarla; ahora sale sola el día que
/// toca, con la misma forma que el cuento y la dinámica de ese día.
class FilaSteamDoDia extends StatelessWidget {
  final SteamUnit unidade;
  final SteamAudiencia audiencia;
  final AppLanguage language;
  final VoidCallback? onTap;

  /// Con la edad delante: en el catálogo de diez meses, el mismo día puede
  /// traer la sesión de dos cursos.
  final bool conIdade;

  const FilaSteamDoDia({
    super.key,
    required this.unidade,
    required this.audiencia,
    required this.language,
    required this.onTap,
    this.conIdade = false,
  });

  static const _rotuloAula = LocalizedString(
    gl: 'A sesión STEAM de hoxe',
    es: 'La sesión STEAM de hoy',
  );
  static const _rotuloCasa = LocalizedString(
    gl: 'O xogo STEAM de hoxe',
    es: 'El juego STEAM de hoy',
  );

  @override
  Widget build(BuildContext context) {
    final rotulo =
        (audiencia == SteamAudiencia.aula ? _rotuloAula : _rotuloCasa)
            .resolve(language);
    final detalle = [
      if (conIdade) unidade.rangoEdad.resolve(language),
      '${unidade.tiempoEstimadoMin} min',
      for (final o in unidade.ordenesIngles) o.en,
    ].join(' · ');

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        key: ValueKey('fila_steam_${unidade.id}'),
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(color: steamTinta.withAlpha(70)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 44,
                decoration: BoxDecoration(
                  color: steamFondo,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.science_rounded,
                    size: 24, color: steamTinta),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: steamTinta,
                      ),
                    ),
                    Text(
                      unidade.titulo.resolve(language),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

/// El aviso del mes: qué día de este mes toca STEAM y qué sesión es. Sin él,
/// para encontrarla en el calendario había que abrir los veinte días.
///
/// Con [conIdade], cada sesión lleva su edad: es el catálogo de los diez meses,
/// donde un mismo mes puede traer la sesión de dos cursos.
class AvisoSteamDoMes extends StatelessWidget {
  final List<SteamUnit> unidades;
  final AppLanguage language;
  final bool conIdade;

  const AvisoSteamDoMes({
    super.key,
    required this.unidades,
    required this.language,
    this.conIdade = false,
  });

  static const _este = LocalizedString(
    gl: 'STEAM este mes',
    es: 'STEAM este mes',
  );

  @override
  Widget build(BuildContext context) {
    final lineas = <String>[
      for (final u in unidades)
        if (u.diaNoCalendario case final d?)
          '${diaSteamEnTexto(d, language)} · ${u.titulo.resolve(language)}'
              '${conIdade ? ' (${u.rangoEdad.resolve(language)})' : ''}',
    ];
    if (lineas.isEmpty) return const SizedBox.shrink();

    return Container(
      key: const ValueKey('aviso_steam_do_mes'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: steamFondo,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: Icon(Icons.science_rounded, size: 18, color: steamTinta),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _este.resolve(language),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: steamTinta,
                  ),
                ),
                for (final l in lineas)
                  Text(
                    l,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      height: 1.35,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
