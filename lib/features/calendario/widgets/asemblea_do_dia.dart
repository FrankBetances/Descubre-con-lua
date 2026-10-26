import 'package:flutter/material.dart';

import '../../../core/codigo_casa.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../data/models/hogar_model.dart';
import '../../../data/models/asamblea_primeiro_ciclo_model.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../../data/repositories/content_repository.dart';
import '../../juega/views/asamblea_player_screen.dart';
import '../../juega/views/nota_para_casas_screen.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';
import '../../juega/widgets/aula_segundo_ciclo_panel.dart';
import '../../premios/premios_repository.dart';
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
  final LocalizedString centroInteres;
  final List<PezaDaUnidade> nucleo;
  final String? cancion;
  final String? material;
  final Map<String, PezaDaUnidade> ordenes;
  final List<PezaDaUnidade> formulas;
  final List<PezaDaUnidade> reactivar;

  /// La guía de casa del mes: la nota lleva el reto de la semana (M4.4).
  final HogarDaUnidade? hogar;

  /// El curso y el mes de la unidad: con la semana dan el código para casa.
  final String? cursoId;
  final int? mesCalendario;

  const AsembleaDaUnidade({
    required this.centroInteres,
    this.nucleo = const [],
    this.cancion,
    this.material,
    this.ordenes = const {},
    this.formulas = const [],
    this.reactivar = const [],
    this.hogar,
    this.cursoId,
    this.mesCalendario,
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
    centroInteres: u.centroInteres,
    // La asamblea es la del documento de su mes (opción 2 de Frank): su
    // núcleo, no el del plan curricular.
    nucleo: repo.nucleoDaAsembleaSync(u),
    cancion: u.cancion,
    material: material.isEmpty ? null : material,
    ordenes: {
      for (final o in u.ordenes)
        if (repo.pezaSync(o.ref) case final p?)
          o.ref.startsWith('frase.') ? o.ref.substring(6) : o.ref: p,
    },
    formulas: resoltas(u.formulas),
    reactivar: resoltas(u.reactivar),
    hogar: u.hogar,
    cursoId: u.curso,
    mesCalendario: u.mesCalendario,
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
  PremiosRepository? premios,
  CalendarioStore? calendario,
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
        notaParaCasas: notaDaAsemblea(
            daUnidade, grupo.segundo, language, audioService,
            semana: diaDaProgresion?.semana ?? semana),
        premios: premios,
        calendario: calendario,
      ),
    ),
  );
}

/// La nota para las casas que cierra la asamblea (M4.3): el centro y el
/// núcleo de la unidad del mes y, en 2.º ciclo, la micro-rutina de casa de su
/// asamblea. Desde M4.4 trae además el reto de casa de [semana], el mismo que
/// enseña Hoxe en casa. Sin unidad leída, no hay nota.
WidgetBuilder? notaDaAsemblea(
  AsembleaDaUnidade? daUnidade,
  AsambleaSegundoCiclo? segundo,
  AppLanguage language,
  OfflineAudioService? audioService, {
  int semana = 1,
}) {
  if (daUnidade == null) return null;
  return (_) => NotaParaCasasScreen(
        centroInteres: daUnidade.centroInteres,
        nucleo: daUnidade.nucleo,
        microRutina: segundo?.microRutinaHogar,
        reto: daUnidade.hogar?.daSemana(semana),
        momentoDoReto: daUnidade.hogar?.momento,
        codigoCasa: switch ((daUnidade.cursoId, daUnidade.mesCalendario)) {
          (final c?, final m?) => CodigoCasa.para(c, m, semana)?.texto,
          _ => null,
        },
        language: language,
        audioService: audioService,
      );
}
