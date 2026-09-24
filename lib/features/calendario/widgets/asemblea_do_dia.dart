import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../data/models/asamblea_primeiro_ciclo_model.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../juega/views/asamblea_player_screen.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';
import '../../juega/widgets/aula_segundo_ciclo_panel.dart';

/// Un grupo de la asamblea del día: 0-2, 2-3, 4.º, 5.º o 6.º.
class GrupoDaAsemblea {
  final String clave;
  final LocalizedString etiqueta;
  final String claveProgresion;
  final AsambleaPrimeiroCiclo? primeiro;
  final AsambleaSegundoCiclo? segundo;

  const GrupoDaAsemblea({
    required this.clave,
    required this.etiqueta,
    required this.claveProgresion,
    this.primeiro,
    this.segundo,
  });

  /// Si hay asamblea escrita para ese mes. Sin ella el botón no abre nada.
  bool get disponible => primeiro != null || segundo != null;
}

/// Los cinco grupos de un mes, en el orden en que se enseñan.
List<GrupoDaAsemblea> gruposDaAsembleaDoDia(
    ContentRepository repo, int mesCalendario) {
  return [
    for (final tramo in TramoPrimeiroCiclo.values)
      GrupoDaAsemblea(
        clave: '1c_${tramo.clave}',
        etiqueta: tramo.etiquetaCorta,
        claveProgresion: 'primeiro_ciclo.${tramo.clave}',
        primeiro: repo.getAsambleaPrimeiroCicloSync(mesCalendario, tramo),
      ),
    for (final nivel in NivelEducativoSegundoCiclo.values)
      GrupoDaAsemblea(
        clave: '2c_${nivel.clave}',
        etiqueta: nivel.etiquetaCorta,
        claveProgresion: AulaSegundoCicloPanel.claveProgresion(nivel),
        segundo: repo.getAsambleaByMesYNivelSync(mesCalendario, nivel),
      ),
  ];
}

/// Abre la asamblea de un grupo en un día concreto del mes.
///
/// Es el MISMO camino desde el calendario y desde el portal de la docente. Si
/// cada pantalla armara la asamblea a su manera, «la asamblea de hoy» podría
/// ser una cosa distinta según por dónde se entrara: aquí se aplica el día de
/// la progresión a las fases.
///
/// Las palabras inglesas del día NO van dentro del reproductor: su fase núcleo
/// ya no cabe en un teléfono de 360×640 en 43 de las 50 asambleas, y una fila
/// más la empeoraba. Se ven en la tarjeta de hoy y en el calendario, justo
/// antes de entrar.
Future<void> abrirAsembleaDoDia(
  BuildContext context, {
  required ContentRepository repo,
  required GrupoDaAsemblea grupo,
  required int mesCalendario,
  required int semana,
  required int dia,
  required AppLanguage language,
  OfflineAudioService? audioService,
}) {
  final fases = grupo.primeiro?.fases ?? grupo.segundo?.fases;
  if (fases == null) return Future.value();
  final progresion = repo.getProgresionSync(grupo.claveProgresion);
  final diaDaProgresion = progresion?.dia(semana, dia);
  final mes = nomeDoMes[mesCalendario]?.resolve(language) ?? '';
  return Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => AsambleaPlayerScreen(
        fases: diaDaProgresion?.aplicarA(fases) ?? fases,
        subtitulo: '$mes · ${grupo.etiqueta.resolve(language)}'
            '${diaDaProgresion != null ? ' · S${diaDaProgresion.semana} ${diaDaProgresion.nomeDia.resolve(language)}' : ''}',
        material: grupo.primeiro?.materialDoMes.resolve(language),
        cancion: grupo.primeiro?.cancionDoMes,
        centroInteres:
            (grupo.primeiro?.centroInteres ?? grupo.segundo?.centroInteres)
                ?.resolve(language),
        audioService: audioService,
        language: language,
        dia: diaDaProgresion,
        semana: progresion?.semana(semana),
      ),
    ),
  );
}
