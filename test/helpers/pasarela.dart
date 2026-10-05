import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:descubre_con_lua/core/audio/mock_offline_audio_service.dart';
import 'package:descubre_con_lua/core/progress_service.dart';
import 'package:descubre_con_lua/core/localization/app_language.dart';
import 'package:descubre_con_lua/core/storage/calendario_store.dart';
import 'package:descubre_con_lua/core/storage/local_store.dart';
import 'package:descubre_con_lua/data/models/asamblea_segundo_ciclo_model.dart';
import 'package:descubre_con_lua/data/models/cuento_model.dart';
import 'package:descubre_con_lua/data/models/formacion_model.dart';
import 'package:descubre_con_lua/data/models/lamina_model.dart';
import 'package:descubre_con_lua/data/models/lectura_model.dart';
import 'package:descubre_con_lua/data/models/steam_model.dart';
import 'package:descubre_con_lua/data/models/tpr_curriculum_scheduler.dart';
import 'package:descubre_con_lua/data/models/unidad_model.dart' hide Cuento;
import 'package:descubre_con_lua/data/models/xogos_fogar_observar_model.dart';
import 'package:descubre_con_lua/data/repositories/calendario_repository.dart';
import 'package:descubre_con_lua/data/repositories/content_repository.dart';
import 'package:descubre_con_lua/features/academy/views/bloques_list_screen.dart';
import 'package:descubre_con_lua/features/bienvenida/welcome_screen.dart';
import 'package:descubre_con_lua/features/academy/views/capsula_detail_screen.dart';
import 'package:descubre_con_lua/features/academy/views/guia_atencion_screen.dart';
import 'package:descubre_con_lua/features/academy/views/micro_rutina_setembro_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_fogar_screen.dart';
import 'package:descubre_con_lua/features/calendario/views/calendario_screen.dart';
import 'package:descubre_con_lua/features/creditos/credits_screen.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuento_viewer_screen.dart';
import 'package:descubre_con_lua/features/cuentos/views/cuentos_list_screen.dart';
import 'package:descubre_con_lua/features/docentes/portal_docentes_screen.dart';
import 'package:descubre_con_lua/features/docentes/views/eu_docente_screen.dart';
import 'package:descubre_con_lua/features/docentes/views/recursos_docentes_screen.dart';
import 'package:descubre_con_lua/features/english/views/collocations_screen.dart';
import 'package:descubre_con_lua/features/english/views/fsrs_trainer_screen.dart';
import 'package:descubre_con_lua/features/english/views/listening_screen.dart';
import 'package:descubre_con_lua/features/english/views/palabras_do_traxecto_screen.dart';
import 'package:descubre_con_lua/features/familias/portal_familias_screen.dart';
import 'package:descubre_con_lua/core/localization/localized_string.dart';
import 'package:descubre_con_lua/data/models/dia_calendario_dual_model.dart';
import 'package:descubre_con_lua/features/familias/views/guias_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/explorar_familias_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogo_de_hoxe_screen.dart';
import 'package:descubre_con_lua/features/familias/views/xogos_fogar_screen.dart';
import 'package:descubre_con_lua/features/formacion/views/formacion_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_guiada_screen.dart';
import 'package:descubre_con_lua/features/juega/views/asamblea_player_screen.dart';
import 'package:descubre_con_lua/features/juega/views/backstage_asamblea_screen.dart';
import 'package:descubre_con_lua/features/juega/views/capsulas_aula_screen.dart';
import 'package:descubre_con_lua/features/juega/views/nota_para_casas_screen.dart';
import 'package:descubre_con_lua/features/juega/views/unidades_list_screen.dart';
import 'package:descubre_con_lua/features/laminas/views/lamina_detail_screen.dart';
import 'package:descubre_con_lua/features/laminas/views/laminas_gallery_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/alphabot_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/aprender_a_ler_screen.dart';
import 'package:descubre_con_lua/features/lectura/views/phonix_quest_screen.dart';
import 'package:descubre_con_lua/features/palabras/views/vocabulario_ingles_screen.dart';
import 'package:descubre_con_lua/features/planificador/views/dinamicas_screen.dart';
import 'package:descubre_con_lua/features/planificador/views/estrategias_screen.dart';
import 'package:descubre_con_lua/features/planificador/views/planificador_screen.dart';
import 'package:descubre_con_lua/features/premios/premios_model.dart';
import 'package:descubre_con_lua/features/premios/premios_repository.dart';
import 'package:descubre_con_lua/features/premios/premios_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_hub_screen.dart';
import 'package:descubre_con_lua/features/steam/views/steam_sesion_guiada_screen.dart';

/// De que portal é unha pantalla. Decide a cor da súa cabeceira e do seu
/// botón principal.
enum Portal { comun, familias, docentes }

/// Unha pantalla da app, lista para pintala nun test.
class PantallaDaApp {
  const PantallaDaApp(this.nome, this.portal, this.construir);

  /// Para os nomes dos ficheiros e as mensaxes dos tests.
  final String nome;
  final Portal portal;
  final Widget Function(AppLanguage lang) construir;

  @override
  String toString() => nome;
}

/// Todas as pantallas da app con barra superior, co contido real dos JSON.
///
/// Existe para os tests que teñen que percorrelas TODAS: un test que mira só
/// as pantallas que alguén lembrou deixa fóra xusto a que non se lembrou.
///
/// Todo o que é E/S de verdade —o disco, o paquete de assets— lese en
/// [cargar], que vai en `setUpAll`. Dentro de `testWidgets` o reloxo é falso
/// e unha lectura de disco non remata nunca.
class Pasarela {
  final audio = MockOfflineAudioService();
  late ContentRepository contenido;
  late ProgramaTpr programa;
  late CalendarioContenido calendario;
  late ContidoLectura lectura;
  late ObservacionsXogosFogar observacions;
  late CalendarioStore store;
  late PremiosRepository premios;
  late GuiaFormacion guiaFamilia;
  late GuiaFormacion guiaDocente;
  late Cuento contoDaSemana;
  late Lamina lamina;
  late Unidad unidade;
  late AsambleaSegundoCiclo asamblea;
  late SteamUnit steam;
  late DiaCalendarioDual diaDeCasa;
  late ProgressService progreso;
  late String colocacions;
  late Directory _tmp;

  /// O día que pintan as pantallas que dependen da data: o venres 2 de
  /// outubro de 2026, un día de escola con asemblea.
  static final agora = DateTime(2026, 10, 2, 10);

  Future<void> cargar() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await cargarFontes();
    Future<String> ler(String p) => File(p).readAsString();

    _tmp = Directory.systemTemp.createTempSync('pasarela_');
    contenido = ContentRepository();
    await contenido.initialize();
    programa = await ProgramaTpr.cargar(stringLoader: ler);
    contenido.addProgramaTpr(programa);
    calendario = await CalendarioContenido.cargar(stringLoader: ler);
    lectura = ContidoLectura.fromRaw(
        File(ContidoLectura.assetPath).readAsStringSync());
    observacions = ObservacionsXogosFogar.fromRaw(
        File(ObservacionsXogosFogar.assetPath).readAsStringSync());
    guiaFamilia =
        await GuiaFormacion.cargar(PerfilFormacion.familia, lector: ler);
    guiaDocente =
        await GuiaFormacion.cargar(PerfilFormacion.docente, lector: ler);

    // O que as pantallas piden ao repositorio ao abrirse, xa lido: así a
    // primeira foto xa trae o contido e non o indicador de carga.
    await contenido.loadCuentos();
    await contenido.loadLaminas();
    await contenido.loadDinamicas();
    await contenido.loadEstrategias();
    await contenido.loadSteamUnits();
    await contenido.loadCorpusPalabras();
    await contenido.loadEnglishCorpus();
    await contenido.loadPhonicsTaxonomy();
    await contenido.loadCalendarioDias(cursoId: 'curso_0_2');
    await contenido.loadCurriculo50Meses();
    colocacions = File(CollocationsScreen.asset).readAsStringSync();

    store = CalendarioStore(overrideDirectory: _tmp.path);
    await store.cargar();
    premios = PremiosRepository(
      store: LocalStore(fileName: 'premios.json', overrideDirectory: _tmp.path),
    );
    await premios.cargar();
    progreso = ProgressService(overrideDirectory: _tmp.path);
    await progreso.initialize();

    final contos = (jsonDecode(
            File('assets/content/cuentos/historias_progresivas.json')
                .readAsStringSync()) as List)
        .map((e) => Cuento.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    contoDaSemana =
        contos.firstWhere((c) => c.paginas.any((p) => p.palabras.isNotEmpty));
    lamina = (await contenido.loadLaminas()).first;
    unidade = contenido.getAllUnidades().first;
    asamblea = contenido.getAsambleaByMesYNivelSync(
        10, NivelEducativoSegundoCiclo.infantil4)!;
    steam = contenido.steamUnits.first;
    // O venres 2 de outubro de 0-2 anos: o do exemplo da revisión (A6).
    diaDeCasa =
        (await contenido.loadCalendarioDias(cursoId: 'curso_0_2', mes: 2))
            .firstWhere((d) => d.semanaNumero == 1 && d.diaSemanaNumero == 5);
  }

  void limpar() {
    if (_tmp.existsSync()) _tmp.deleteSync(recursive: true);
  }

  /// Nunito e as iconas de Material. Sen elas o test pinta coa fonte de
  /// recheo, máis ancha, e mide outra app (regra 1c).
  static Future<void> cargarFontes() async {
    File? iconas;
    var dir = File(Platform.resolvedExecutable).parent;
    for (var i = 0; i < 8 && iconas == null; i++) {
      final f = File(
          '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf');
      if (f.existsSync()) iconas = f;
      dir = dir.parent;
    }
    for (final entrada in {
      'Nunito': [
        for (final peso in ['Regular', 'SemiBold', 'Bold', 'ExtraBold'])
          'assets/fonts/Nunito-$peso.ttf',
      ],
      if (iconas != null) 'MaterialIcons': [iconas.path],
    }.entries) {
      final loader = FontLoader(entrada.key);
      for (final p in entrada.value) {
        loader.addFont(
            File(p).readAsBytes().then((b) => ByteData.view(b.buffer)));
      }
      await loader.load();
    }
  }

  /// Deixa a pantalla quieta e co contido cargado.
  ///
  /// Alterna fotogramas co reloxo falso e esperas de verdade (`runAsync`): o
  /// que se le do paquete é E/S real, e sen a espera de verdade a foto sae co
  /// indicador de carga.
  static Future<void> asentar(WidgetTester tester) async {
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 60));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 60)));
    }
    await tester.pumpAndSettle();
  }

  List<PantallaDaApp> get pantallas => [
        // ------------------------------------------------------ común
        // A primeira pantalla, o inicio: leva a súa propia cabeceira de
        // marca, co selector de lingua dentro, e as dúas respostas.
        PantallaDaApp(
            'bienvenida',
            Portal.comun,
            (l) => WelcomeScreen(
                  currentLanguage: l,
                  onToggleLanguage: () {},
                  onCasa: () {},
                  onEscola: () {},
                  onShowCredits: () {},
                )),
        PantallaDaApp(
            'creditos', Portal.comun, (l) => CreditsScreen(currentLanguage: l)),
        PantallaDaApp(
            'calendario_escola_fogar',
            Portal.comun,
            (l) => CalendarioScreen(
                  store: store,
                  contenido: calendario,
                  initialLanguage: l,
                  repository: contenido,
                  audioService: audio,
                  premios: premios,
                )),
        // ---------------------------------------------------- familias
        PantallaDaApp(
            'portal_familias',
            Portal.familias,
            (l) => PortalFamiliasScreen(
                  repository: contenido,
                  audioService: audio,
                  currentLanguage: l,
                  onToggleLanguage: () {},
                  premios: premios,
                  calendario: store,
                  agora: agora,
                )),
        PantallaDaApp(
            'xogo_de_hoxe',
            Portal.familias,
            (l) => XogoDeHoxeScreen(
                  dia: diaDeCasa,
                  eHoxe: true,
                  nomeDoDia: const LocalizedString(gl: 'Venres', es: 'Viernes'),
                  language: l,
                  store: store,
                  audioService: audio,
                  plan: programa.curso('curso_0_2')!.planDoDia(10, 1, 5),
                  agora: agora,
                )),
        PantallaDaApp(
            'explorar_familias',
            Portal.familias,
            (l) => ExplorarFamiliasScreen(
                  repository: contenido,
                  language: l,
                  onLanguageChanged: (_) {},
                  cursoId: 'curso_0_2',
                  onCambiarCurso: (_) {},
                  audioService: audio,
                  agora: agora,
                )),
        PantallaDaApp(
            'guias_familias',
            Portal.familias,
            (l) => GuiasFamiliasScreen(
                  repository: contenido,
                  language: l,
                  onLanguageChanged: (_) {},
                  premios: premios,
                  calendario: store,
                  audioService: audio,
                )),
        PantallaDaApp(
            'calendario_casa',
            Portal.familias,
            (l) => CalendarioFogarScreen(
                  repository: contenido,
                  store: store,
                  initialLanguage: l,
                  audioService: audio,
                  agora: agora,
                )),
        PantallaDaApp(
            'steam_casa',
            Portal.familias,
            (l) => SteamHubScreen(
                  repository: contenido,
                  audioService: audio,
                  initialLanguage: l,
                  audiencia: SteamAudiencia.hogar,
                )),
        PantallaDaApp(
            'steam_sesion_casa',
            Portal.familias,
            (l) => SteamSesionGuiadaScreen(
                  unit: steam,
                  audiencia: SteamAudiencia.hogar,
                  audioService: audio,
                  initialLanguage: l,
                )),
        PantallaDaApp(
            'contos',
            Portal.familias,
            (l) => CuentosListScreen(
                  repository: contenido,
                  initialLanguage: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'conto',
            Portal.familias,
            (l) => CuentoViewerScreen(
                  cuento: contoDaSemana,
                  language: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'aprender_a_ler',
            Portal.familias,
            (l) => AprenderALerScreen(
                  repository: contenido,
                  initialLanguage: l,
                  audioService: audio,
                  contido: lectura,
                )),
        PantallaDaApp('alphabot', Portal.familias,
            (l) => AlphabotScreen(language: l, audioService: audio)),
        // Ábrese desde o inglés das docentes, non desde Aprender a Ler.
        PantallaDaApp(
            'phonix',
            Portal.docentes,
            (l) => PhonixQuestScreen(
                  repository: contenido,
                  initialLanguage: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'laminas',
            Portal.familias,
            (l) => LaminasGalleryScreen(
                  repository: contenido,
                  initialLanguage: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'lamina',
            Portal.familias,
            (l) => LaminaDetailScreen(
                  lamina: lamina,
                  language: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'xogos_casa',
            Portal.familias,
            (l) => XogosFogarScreen(
                  initialLanguage: l,
                  audioService: audio,
                  observacions: observacions,
                )),
        PantallaDaApp(
            'academy',
            Portal.familias,
            (l) => BloquesListScreen(
                  repository: contenido,
                  initialLanguage: l,
                  premios: premios,
                  audioService: audio,
                  calendario: store,
                  calendarioContenido: calendario,
                )),
        PantallaDaApp(
            'capsula',
            Portal.familias,
            (l) => CapsulaDetailScreen(
                  capsula: contenido.getAllCapsulas().first,
                  initialLanguage: l,
                  premios: premios,
                  audioService: audio,
                )),
        PantallaDaApp(
            'guia_ingles_casa',
            Portal.familias,
            (l) => GuiaAtencionScreen(
                  initialLanguage: l,
                  audioService: audio,
                  contenido: calendario,
                )),
        PantallaDaApp('micro_rutina', Portal.familias,
            (l) => MicroRutinaSetembroScreen(initialLanguage: l)),
        PantallaDaApp(
            'formacion_familia',
            Portal.familias,
            (l) => FormacionScreen(
                  perfil: PerfilFormacion.familia,
                  language: l,
                  guiaPrecargada: guiaFamilia,
                )),
        PantallaDaApp(
            'premios_familia',
            Portal.familias,
            (l) => PremiosScreen(
                  repository: premios,
                  currentLanguage: l,
                  perfilInicial: Perfil.familia,
                )),
        // ---------------------------------------------------- docentes
        PantallaDaApp(
            'portal_docentes',
            Portal.docentes,
            (l) => PortalDocentesScreen(
                  repository: contenido,
                  audioService: audio,
                  currentLanguage: l,
                  onToggleLanguage: () {},
                  premios: premios,
                  calendario: store,
                  agora: agora,
                  calendarioContenido: calendario,
                )),
        // Las otras dos pestañas del portal, sueltas: la auditoría recorre la
        // pantalla que se abre, y el portal abre en «Hoxe».
        PantallaDaApp(
            'recursos_docentes',
            Portal.docentes,
            (l) => RecursosDocentesScreen(
                  repository: contenido,
                  language: l,
                  onLanguageChanged: (_) {},
                  cursoId: 'curso_0_2',
                  audioService: audio,
                  premios: premios,
                  calendario: store,
                  agora: agora,
                  calendarioContenido: calendario,
                )),
        PantallaDaApp(
            'eu_docente',
            Portal.docentes,
            (l) => EuDocenteScreen(
                  repository: contenido,
                  language: l,
                  onLanguageChanged: (_) {},
                  premios: premios,
                  calendario: store,
                  audioService: audio,
                )),
        PantallaDaApp(
            'calendario_aula_pestana',
            Portal.docentes,
            (l) => CalendarioScreen(
                  store: store,
                  contenido: calendario,
                  initialLanguage: l,
                  repository: contenido,
                  audioService: audio,
                  premios: premios,
                  esDocenteInicial: true,
                  conIntroducion: false,
                )),
        PantallaDaApp(
            'aula_1ciclo',
            Portal.docentes,
            (l) => UnidadesListScreen(
                  repository: contenido,
                  audioService: audio,
                  initialLanguage: l,
                  premios: premios,
                  calendario: store,
                  calendarioContenido: calendario,
                )),
        PantallaDaApp(
            'aula_2ciclo',
            Portal.docentes,
            (l) => UnidadesListScreen(
                  repository: contenido,
                  audioService: audio,
                  initialLanguage: l,
                  premios: premios,
                  calendario: store,
                  calendarioContenido: calendario,
                  initialCiclo: CicloEducativo.segundoCiclo,
                )),
        PantallaDaApp(
            'asamblea_1ciclo',
            Portal.docentes,
            (l) => AsambleaGuiadaScreen(
                  unidad: unidade,
                  audioService: audio,
                  initialLanguage: l,
                  premios: premios,
                  calendario: store,
                )),
        PantallaDaApp(
            'asamblea_2ciclo',
            Portal.docentes,
            (l) => BackstageAsambleaScreen(
                  repository: contenido,
                  audioService: audio,
                  initialLanguage: l,
                )),
        PantallaDaApp(
            'reprodutor',
            Portal.docentes,
            (l) => AsambleaPlayerScreen(
                  fases: asamblea.fases,
                  subtitulo: asamblea.titulo.resolve(l),
                  language: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'capsulas_aula',
            Portal.docentes,
            (l) => CapsulasAulaScreen(
                  repository: contenido,
                  initialLanguage: l,
                  premios: premios,
                  audioService: audio,
                )),
        PantallaDaApp(
            'nota_casas',
            Portal.docentes,
            (l) => NotaParaCasasScreen(
                  unidad: unidade,
                  language: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'steam_aula',
            Portal.docentes,
            (l) => SteamHubScreen(
                  repository: contenido,
                  audioService: audio,
                  initialLanguage: l,
                  audiencia: SteamAudiencia.aula,
                )),
        PantallaDaApp(
            'steam_sesion_aula',
            Portal.docentes,
            (l) => SteamSesionGuiadaScreen(
                  unit: steam,
                  audiencia: SteamAudiencia.aula,
                  audioService: audio,
                  initialLanguage: l,
                )),
        PantallaDaApp('dinamicas', Portal.docentes,
            (l) => DinamicasScreen(repository: contenido, initialLanguage: l)),
        PantallaDaApp(
            'estratexias',
            Portal.docentes,
            (l) =>
                EstrategiasScreen(repository: contenido, initialLanguage: l)),
        PantallaDaApp(
            'planificador',
            Portal.docentes,
            (l) =>
                PlanificadorScreen(repository: contenido, initialLanguage: l)),
        PantallaDaApp(
            'colocacions',
            Portal.docentes,
            (l) => CollocationsScreen(
                  repository: contenido,
                  initialLanguage: l,
                  audioService: audio,
                  stringLoader: (_) async => colocacions,
                )),
        PantallaDaApp(
            'repaso',
            Portal.docentes,
            (l) => FsrsTrainerScreen(
                  programa: programa,
                  progreso: progreso,
                  language: l,
                  audioService: audio,
                  agora: agora,
                )),
        PantallaDaApp(
            'escoita',
            Portal.docentes,
            (l) => ListeningScreen(
                  programa: programa,
                  language: l,
                  audioService: audio,
                  agora: agora,
                )),
        PantallaDaApp(
            'palabras_traxecto',
            Portal.docentes,
            (l) => PalabrasDoTraxectoScreen(
                  programa: programa,
                  language: l,
                  audioService: audio,
                  agora: agora,
                )),
        PantallaDaApp(
            'vocabulario',
            Portal.docentes,
            (l) => VocabularioInglesScreen(
                  repository: contenido,
                  initialLanguage: l,
                  audioService: audio,
                )),
        PantallaDaApp(
            'formacion_docente',
            Portal.docentes,
            (l) => FormacionScreen(
                  perfil: PerfilFormacion.docente,
                  language: l,
                  guiaPrecargada: guiaDocente,
                )),
        PantallaDaApp(
            'premios_docente',
            Portal.docentes,
            (l) => PremiosScreen(
                  repository: premios,
                  currentLanguage: l,
                )),
      ];
}
