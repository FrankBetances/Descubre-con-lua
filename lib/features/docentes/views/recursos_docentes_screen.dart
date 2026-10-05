import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../core/widgets/fila_portal.dart';
import '../../../data/models/steam_model.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../../../data/repositories/content_repository.dart';
import '../../english/views/collocations_screen.dart';
import '../../english/views/fsrs_trainer_screen.dart';
import '../../english/views/listening_screen.dart';
import '../../english/views/palabras_do_traxecto_screen.dart';
import '../../juega/views/unidades_list_screen.dart';
import '../../lectura/views/phonix_quest_screen.dart';
import '../../palabras/views/vocabulario_ingles_screen.dart';
import '../../planificador/views/dinamicas_screen.dart';
import '../../planificador/views/estrategias_screen.dart';
import '../../planificador/views/planificador_screen.dart';
import '../../premios/premios_repository.dart';
import '../../steam/views/steam_hub_screen.dart';
import '../nomes_docentes.dart';

/// «Recursos»: todo lo que no es la asamblea de hoy, agrupado por para qué
/// sirve.
///
/// Antes eran siete tarjetas en tres secciones numeradas —«1. ASEMBLEA E AULA
/// ACTIVA (72 BPM)», «3. INMERSIÓN L3…»—, cada una con su párrafo y su botón.
/// Ahora cada recurso es una fila con su nombre y una línea que dice qué hay
/// dentro, y los grupos se llaman por lo que la docente va a hacer.
class RecursosDocentesScreen extends StatelessWidget {
  const RecursosDocentesScreen({
    super.key,
    required this.repository,
    required this.language,
    required this.onLanguageChanged,
    required this.cursoId,
    required this.audioService,
    this.premios,
    this.calendario,
    this.agora,
    this.calendarioContenido,
  });

  final ContentRepository repository;
  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  /// El grupo elegido en «Hoxe»: la ciencia, las palabras y el inglés abren
  /// en él.
  final String cursoId;
  final OfflineAudioService audioService;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;

  /// Para los tests: el día que se quiere ver. Por defecto, hoy.
  final DateTime? agora;

  /// Los diez meses, si ya están leídos: el Modo Aula los usa en su
  /// calendario. Sin ellos los lee él solo.
  final CalendarioContenido? calendarioContenido;

  void _abrir(BuildContext context, WidgetBuilder builder) {
    Navigator.of(context).push(RutaLua(de: context, builder: builder));
  }

  @override
  Widget build(BuildContext context) {
    final grupos = <(
      LocalizedString,
      List<(String, IconData, LocalizedString, LocalizedString, WidgetBuilder)>
    )>[
      (
        NomesDocentes.paraAsemblea,
        [
          (
            'recurso_asembleas',
            Icons.groups_rounded,
            NomesDocentes.asembleas,
            NomesDocentes.asembleasDi,
            (_) => UnidadesListScreen(
                  repository: repository,
                  premios: premios,
                  calendario: calendario,
                  calendarioContenido: calendarioContenido,
                  audioService: audioService,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                ),
          ),
          (
            'recurso_dinamicas',
            Icons.hub_rounded,
            NomesDocentes.dinamicas,
            NomesDocentes.dinamicasDi,
            (_) => DinamicasScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                ),
          ),
          (
            'recurso_ciencia',
            Icons.science_rounded,
            NomesDocentes.ciencia,
            NomesDocentes.cienciaDi,
            (_) => SteamHubScreen(
                  repository: repository,
                  audioService: audioService,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                  audiencia: SteamAudiencia.aula,
                  initialCursoId: cursoId,
                ),
          ),
        ],
      ),
      (
        NomesDocentes.paraPlanificar,
        [
          (
            'recurso_programacion',
            Icons.calendar_view_month_rounded,
            NomesDocentes.programacion,
            NomesDocentes.programacionDi,
            (_) => PlanificadorScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                ),
          ),
        ],
      ),
      (
        NomesDocentes.ingles,
        [
          (
            'recurso_palabras',
            Icons.record_voice_over_rounded,
            NomesDocentes.palabrasCurso,
            NomesDocentes.palabrasCursoDi,
            (_) => PalabrasDoTraxectoScreen(
                  programa: repository.programaTprSync,
                  cursoInicial: cursoId,
                  language: language,
                  onLanguageChanged: onLanguageChanged,
                  audioService: audioService,
                  agora: agora,
                  titulo: NomesDocentes.palabrasCurso,
                ),
          ),
          (
            'recurso_repaso',
            Icons.bolt_rounded,
            NomesDocentes.repaso,
            NomesDocentes.repasoDi,
            (_) => FsrsTrainerScreen(
                  programa: repository.programaTprSync,
                  cursoInicial: cursoId,
                  language: language,
                  onLanguageChanged: onLanguageChanged,
                  audioService: audioService,
                  agora: agora,
                ),
          ),
          (
            'recurso_escoita',
            Icons.headphones_rounded,
            NomesDocentes.escoita,
            NomesDocentes.escoitaDi,
            (_) => ListeningScreen(
                  programa: repository.programaTprSync,
                  cursoInicial: cursoId,
                  language: language,
                  onLanguageChanged: onLanguageChanged,
                  audioService: audioService,
                  agora: agora,
                ),
          ),
          (
            'recurso_colocacions',
            Icons.menu_book_rounded,
            NomesDocentes.colocacions,
            NomesDocentes.colocacionsDi,
            (_) => CollocationsScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                  audioService: audioService,
                ),
          ),
          (
            'recurso_sons',
            Icons.graphic_eq_rounded,
            NomesDocentes.sons,
            NomesDocentes.sonsDi,
            (_) => PhonixQuestScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                  audioService: audioService,
                ),
          ),
          (
            'recurso_vocabulario',
            Icons.format_list_numbered_rounded,
            NomesDocentes.vocabulario,
            NomesDocentes.vocabularioDi,
            (_) => VocabularioInglesScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                  audioService: audioService,
                ),
          ),
        ],
      ),
      (
        NomesDocentes.paraSaberMais,
        [
          (
            'recurso_estratexias',
            Icons.psychology_rounded,
            NomesDocentes.estratexias,
            NomesDocentes.estratexiasDi,
            (_) => EstrategiasScreen(
                  repository: repository,
                  initialLanguage: language,
                  onLanguageChanged: onLanguageChanged,
                ),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: NomesDocentes.recursos.resolve(language),
        language: language,
        onLanguageChanged: onLanguageChanged,
      ),
      body: SafeArea(
        child: ListView(
          key: const Key('recursos_docentes'),
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            for (final (i, (rotulo, filas)) in grupos.indexed) ...[
              if (i > 0) const SizedBox(height: 14),
              RotuloGrupo(rotulo.resolve(language)),
              for (final (clave, icona, nome, di, abrir) in filas) ...[
                FilaPortal(
                  clave: clave,
                  icona: icona,
                  nome: nome.resolve(language),
                  di: di.resolve(language),
                  onTap: () => _abrir(context, abrir),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
