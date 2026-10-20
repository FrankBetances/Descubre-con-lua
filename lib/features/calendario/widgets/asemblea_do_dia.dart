import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../data/models/asamblea_primeiro_ciclo_model.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../../data/repositories/content_repository.dart';
import '../../juega/views/asamblea_player_screen.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';
import '../../juega/widgets/aula_segundo_ciclo_panel.dart';
import '../../../core/navigation/ruta_lua.dart';

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

/// Lo que la asamblea toma de su unidad del mes (M4.1): canción, material,
/// órdenes, fórmulas y reactivación. La unidad cita; esto lo deja resuelto en
/// el banco y en el registro de frases para el reproductor.
class AsembleaDaUnidade {
  final String? cancion;
  final String? material;
  final Map<String, PezaDaUnidade> ordenes;
  final List<PezaDaUnidade> formulas;
  final List<PezaDaUnidade> reactivar;

  const AsembleaDaUnidade({
    this.cancion,
    this.material,
    this.ordenes = const {},
    this.formulas = const [],
    this.reactivar = const [],
  });
}

/// Lee la unidad de [cursoId] en [mesCalendario] y la resuelve. `null` si no
/// se pudo leer: entonces el reproductor enseña lo de la asamblea, como antes.
Future<AsembleaDaUnidade?> lerAsembleaDaUnidade(ContentRepository repo,
    String? cursoId, int mesCalendario, AppLanguage language) async {
  if (cursoId == null) return null;
  await Future.wait([repo.loadProgramaTpr(), repo.loadRexistroFrases()]);
  final u = await repo.loadUnidadeDoMes(cursoId, mesCalendario);
  if (u == null) return null;
  List<PezaDaUnidade> resoltas(Iterable<String> refs) => [
        for (final r in refs)
          if (repo.pezaSync(r) case final p?) p,
      ];
  final material = [
    for (final r in u.realia) r.resolve(language),
  ].where((m) => m.trim().isNotEmpty).join(' · ');
  return AsembleaDaUnidade(
    cancion: u.cancion,
    material: material.isEmpty ? null : material,
    ordenes: {
      for (final o in u.ordenes)
        if (repo.pezaSync(o.ref) case final p?)
          o.ref.startsWith('frase.') ? o.ref.substring(6) : o.ref: p,
    },
    formulas: resoltas(u.formulas),
    reactivar: resoltas(u.reactivar),
  );
}

/// El curso de la unidad de un tramo de 1.º ciclo o de un nivel de 2.º.
String cursoDoTramo(TramoPrimeiroCiclo tramo) => 'curso_${tramo.clave}';
String? cursoDoNivel(NivelEducativoSegundoCiclo nivel) =>
    cursoTprDoGrupo['2c_${nivel.clave}'];

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
/// antes de entrar. Las que la orden da por sabidas sí van, pero en su propia
/// pantalla, «Antes da orde», sin tocar el núcleo.
Future<void> abrirAsembleaDoDia(
  BuildContext context, {
  required ContentRepository repo,
  required GrupoDaAsemblea grupo,
  required int mesCalendario,
  required int semana,
  required int dia,
  required AppLanguage language,
  OfflineAudioService? audioService,
}) async {
  final fases = grupo.primeiro?.fases ?? grupo.segundo?.fases;
  if (fases == null) return;
  final progresion = repo.getProgresionSync(grupo.claveProgresion);
  final diaDaProgresion = progresion?.dia(semana, dia);
  final mes = nomeDoMes[mesCalendario]?.resolve(language) ?? '';
  final daUnidade = await lerAsembleaDaUnidade(
      repo, cursoTprDoGrupo[grupo.clave], mesCalendario, language);
  if (!context.mounted) return;
  await Navigator.of(context).push(
    RutaLua(
      de: context,
      builder: (context) => AsambleaPlayerScreen(
        fases: diaDaProgresion?.aplicarA(fases) ?? fases,
        subtitulo: '$mes · ${grupo.etiqueta.resolve(language)}'
            '${diaDaProgresion != null ? ' · S${diaDaProgresion.semana} ${diaDaProgresion.nomeDia.resolve(language)}' : ''}',
        material: daUnidade?.material ??
            grupo.primeiro?.materialDoMes.resolve(language),
        cancion: daUnidade?.cancion ?? grupo.primeiro?.cancionDoMes,
        centroInteres:
            (grupo.primeiro?.centroInteres ?? grupo.segundo?.centroInteres)
                ?.resolve(language),
        audioService: audioService,
        language: language,
        dia: diaDaProgresion,
        semana: progresion?.semana(semana),
        ponteAoDia: repo.ponteAoDiaSync,
        lineaAdulta: progresion?.lineaAdulta?.resolve(language),
        esperaSegundos: progresion?.esperaSegundos ?? 5,
        ordenes: daUnidade?.ordenes ?? const {},
        formulas: daUnidade?.formulas ?? const [],
        reactivar: daUnidade?.reactivar ?? const [],
      ),
    ),
  );
}
