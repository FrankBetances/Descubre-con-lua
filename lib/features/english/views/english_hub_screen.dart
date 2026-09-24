import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/repositories/content_repository.dart';
import '../../palabras/views/vocabulario_ingles_screen.dart';
import 'collocations_screen.dart';
import '../../lectura/views/phonix_quest_screen.dart';
import 'fsrs_trainer_screen.dart';
import 'listening_screen.dart';
import 'palabras_do_traxecto_screen.dart';
import '../../docentes/widgets/hoxe_na_aula.dart' show formatarMiles;

/// Hub central del módulo de Inmersión en Inglés (L3).
///
/// Los tres primeros módulos trabajan las MISMAS palabras que la clase: las
/// del trayecto, cinco nuevas al día. Antes el entrenador tenía seis palabras
/// propias y la escucha cuatro frases propias, sin relación con el curso: se
/// podía «hacer inglés» aquí todo el año sin repasar ni una palabra del aula.
class EnglishHubScreen extends StatelessWidget {
  final ContentRepository repository;
  final AppLanguage initialLanguage;
  final OfflineAudioService? audioService;

  /// El curso con el que abren el repaso, la escucha y las palabras.
  final String cursoInicial;

  const EnglishHubScreen({
    super.key,
    required this.repository,
    this.initialLanguage = AppLanguage.gl,
    this.audioService,
    this.cursoInicial = 'curso_0_2',
  });

  @override
  Widget build(BuildContext context) {
    final lang = initialLanguage;
    final isGl = lang == AppLanguage.gl;
    final programa = repository.programaTprSync;
    final total = programa?.totalPalabras ?? 0;
    final porCurso = programa?.cursos.firstOrNull?.totalPalabras ?? 0;
    final ritmo = programa?.modelo.ritmoDiario ?? 0;
    final milesTotal = formatarMiles(total);

    final List<Map<String, dynamic>> modules = [
      {
        'key': 'ingles_modulo_palabras',
        'title': isGl ? 'As palabras do traxecto' : 'Las palabras del trayecto',
        'subtitle': isGl
            ? 'As $milesTotal de 0 a 6 anos por curso, mes, semana e día, co seu son e o xesto. Con buscador.'
            : 'Las $milesTotal de 0 a 6 años por curso, mes, semana y día, con su sonido y el gesto. Con buscador.',
        'icon': Icons.view_week_rounded,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => PalabrasDoTraxectoScreen(
              programa: programa,
              cursoInicial: cursoInicial,
              language: lang,
              audioService: audioService,
            ),
      },
      {
        'key': 'ingles_modulo_repaso',
        'title': lang == AppLanguage.gl
            // Sin el número de versión: el motor usa los pesos por defecto de
            // FSRS-4 con la curva de olvido de 4.5, así que llamarlo «v4.5» a
            // secas es más preciso de lo que el código sostiene.
            ? 'Adestrador de repetición espazada'
            : 'Entrenador de repetición espaciada',
        'subtitle': isGl
            ? 'As $ritmo de hoxe e as que xa saíron no curso. Cada palabra volve cando toca, e o repaso gárdase no aparello.'
            : 'Las $ritmo de hoy y las que ya salieron en el curso. Cada palabra vuelve cuando toca, y el repaso se guarda en el aparato.',
        'icon': Icons.bolt,
        'color': AppTheme.warning,
        'bg': AppTheme.warningBg,
        'builder': (BuildContext ctx) => FsrsTrainerScreen(
              programa: programa,
              cursoInicial: cursoInicial,
              language: lang,
              audioService: audioService,
            ),
      },
      {
        'key': 'ingles_modulo_escoita',
        'title': isGl
            ? 'Escoita as frases do curso'
            : 'Escucha las frases del curso',
        'subtitle': isGl
            ? 'As frases e ordes de cada mes: escoitar sen ler, entender e facer o xesto.'
            : 'Las frases y órdenes de cada mes: escuchar sin leer, entender y hacer el gesto.',
        'icon': Icons.headphones,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => ListeningScreen(
              programa: programa,
              cursoInicial: cursoInicial,
              language: lang,
              audioService: audioService,
            ),
      },
      {
        'key': 'ingles_modulo_colocacions',
        'title': lang == AppLanguage.gl
            ? 'Colocacións e Gramática'
            : 'Colocaciones y Gramática',
        'subtitle': lang == AppLanguage.gl
            ? 'Combinacións fixas do día a día —wash your hands, put on your coat…— co seu son, unha frase e un consello'
            : 'Combinaciones fijas del día a día —wash your hands, put on your coat…— con su sonido, una frase y un consejo',
        'icon': Icons.menu_book,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => CollocationsScreen(
              repository: repository,
              initialLanguage: lang,
              audioService: audioService,
            ),
      },
      {
        'key': 'ingles_modulo_fonemas',
        // Los 44 fonemas son los del INGLÉS. Estaban colgando de «Aprender a
        // Ler», que es la alfabetización en gallego y castellano: allí una
        // tabla de fonemas ingleses no ayuda a leer, despista. Aquí sí es lo
        // que dice ser.
        'title': lang == AppLanguage.gl
            ? 'Fonemas do inglés · Phonix Quest'
            : 'Fonemas del inglés · Phonix Quest',
        'subtitle': lang == AppLanguage.gl
            ? 'Os 44 fonemas do inglés, 24 consoantes e 20 vogais, con palabra de exemplo, son e como se articulan'
            : 'Los 44 fonemas del inglés, 24 consonantes y 20 vocales, con palabra de ejemplo, sonido y cómo se articulan',
        'icon': Icons.graphic_eq,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => PhonixQuestScreen(
              repository: repository,
              initialLanguage: lang,
              audioService: audioService,
            ),
      },
      {
        'key': 'ingles_modulo_frecuencia',
        'title': lang == AppLanguage.gl
            ? '4.000 palabras de uso habitual'
            : '4.000 palabras de uso habitual',
        'subtitle': lang == AppLanguage.gl
            ? 'As máis usadas do inglés, con categoría, frase enteira e son'
            : 'Las más usadas del inglés, con categoría, frase entera y sonido',
        'icon': Icons.search,
        'color': AppTheme.primaryDark,
        'bg': AppTheme.primaryLight,
        'builder': (BuildContext ctx) => VocabularioInglesScreen(
              repository: repository,
              initialLanguage: lang,
              audioService: audioService,
            ),
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          lang == AppLanguage.gl
              ? 'Inmersión en Inglés (L3)'
              : 'Inmersión en Inglés (L3)',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryDark, AppTheme.primaryInk],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Flexible: con el texto grande del sistema el rótulo no cabía
                // en una fila y se cortaba 171 px por la derecha.
                const Row(
                  children: [
                    Icon(Icons.language, color: Colors.white, size: 24),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'INMERSIÓN EN INGLÉS',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  lang == AppLanguage.gl
                      ? 'Adquisición Natural e TPR'
                      : 'Adquisición Natural y TPR',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  lang == AppLanguage.gl
                      ? 'Metodoloxía comunicativa orientada ao adulto mediador con retos motores e sen exposición a pantallas infantís.'
                      : 'Metodología comunicativa orientada al adulto mediador con retos motores y sin exposición a pantallas infantiles.',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                if (programa != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    isGl
                        ? '$ritmo palabras novas ao día · $porCurso por curso · $milesTotal de 0 a 6 anos'
                        : '$ritmo palabras nuevas al día · $porCurso por curso · $milesTotal de 0 a 6 años',
                    key: const Key('ingles_cifras'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          ...modules.map((m) {
            return Card(
              key: ValueKey(m['key'] as String),
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0.5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: m['builder'] as WidgetBuilder,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: m['bg'] as Color,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          m['icon'] as IconData,
                          color: m['color'] as Color,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              m['title'] as String,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              m['subtitle'] as String,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
