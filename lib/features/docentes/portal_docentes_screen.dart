import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../../../data/repositories/content_repository.dart';
import '../calendario/views/calendario_screen.dart';
import '../familias/nomes_familias.dart';
import '../premios/premios_repository.dart';
import 'nomes_docentes.dart';
import 'views/eu_docente_screen.dart';
import 'views/hoxe_docentes_screen.dart';
import 'views/recursos_docentes_screen.dart';

/// O Portal Docentes: catro pestanas, e cada cousa vive nunha soa.
///
/// - **Hoxe**: a asemblea do día do grupo, arriba e cun botón; debaixo, as
///   palabras en inglés, o conto da semana, a dinámica e, se toca, a ciencia.
/// - **Calendario**: o curso mes a mes, polo lado da aula.
/// - **Recursos**: todas as asembleas, a programación, o inglés e as
///   estratexias, agrupados polo que se vai facer.
/// - **Eu**: o nivel e a racha da persoa docente, a guía de dous minutos e a
///   formación.
///
/// Antes era unha soa lista: unha cabeceira, unha tarxeta con cinco pastillas
/// de idade e sete módulos en tres seccións numeradas. Para comezar a
/// asemblea de hoxe había tres portas con tres nomes distintos.
class PortalDocentesScreen extends StatefulWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Para os tests: o día que se quere ver. Por defecto, hoxe.
  final DateTime? agora;

  /// Os dez meses, se quen abre o portal xa os ten lidos. Sen eles, o
  /// calendario e o Modo Aula lenos sós, como fai a app.
  final CalendarioContenido? calendarioContenido;

  const PortalDocentesScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
    this.agora,
    this.calendarioContenido,
  });

  @override
  State<PortalDocentesScreen> createState() => _PortalDocentesScreenState();
}

class _PortalDocentesScreenState extends State<PortalDocentesScreen> {
  late AppLanguage _language = widget.currentLanguage;
  late final CalendarioStore _store = widget.calendario ?? CalendarioStore();
  int _pestana = 0;

  /// Las pestañas ya abiertas: cada una se construye la primera vez que se
  /// visita. El calendario lee mucho contenido y la asamblea de hoy no tiene
  /// por qué esperarlo.
  final Set<int> _visitadas = {0};

  /// El grupo de la docente. Solo mientras la app está abierta: no se guarda
  /// nada de un aula.
  String _curso = NomesFamilias.idades.first.$1;

  @override
  void didUpdateWidget(covariant PortalDocentesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _language = widget.currentLanguage;
    }
  }

  void _cambiarLingua(AppLanguage lingua) {
    setState(() => _language = lingua);
    widget.onLanguageChanged?.call(lingua);
  }

  void _cambiarCurso(String curso) => setState(() => _curso = curso);

  List<Widget> _pestanas(AppLanguage lang) => [
        HoxeDocentesScreen(
          repository: widget.repository,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          cursoId: _curso,
          onCambiarCurso: _cambiarCurso,
          audioService: widget.audioService,
          agora: widget.agora,
        ),
        // Con clave: cambiar el grupo en Hoxe abre el calendario de ese curso.
        CalendarioScreen(
          key: ValueKey('calendario_aula_$_curso'),
          store: _store,
          contenido: widget.calendarioContenido,
          initialLanguage: lang,
          onLanguageChanged: _cambiarLingua,
          repository: widget.repository,
          audioService: widget.audioService,
          premios: widget.premios,
          esDocenteInicial: true,
          cursoInicial: _curso,
          conIntroducion: false,
        ),
        RecursosDocentesScreen(
          repository: widget.repository,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          cursoId: _curso,
          audioService: widget.audioService,
          premios: widget.premios,
          calendario: _store,
          calendarioContenido: widget.calendarioContenido,
          agora: widget.agora,
        ),
        EuDocenteScreen(
          repository: widget.repository,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          premios: widget.premios,
          calendario: _store,
          audioService: widget.audioService,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    return Scaffold(
      body: IndexedStack(
        index: _pestana,
        children: [
          for (final (i, pestana) in _pestanas(lang).indexed)
            // Las que no se ven, paradas: sin animaciones gastando batería.
            TickerMode(
              enabled: i == _pestana,
              child: _visitadas.contains(i) ? pestana : const SizedBox.shrink(),
            ),
        ],
      ),
      // Las etiquetas crecen con la letra del sistema hasta 1,3: más, y
      // «Calendario» no cabe en un cuarto de 360 px y se corta.
      bottomNavigationBar: MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: DecoratedBox(
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFFE9EEEE))),
          ),
          child: NavigationBar(
            key: const Key('pestanas_docentes'),
            selectedIndex: _pestana,
            onDestinationSelected: (i) => setState(() {
              _pestana = i;
              _visitadas.add(i);
            }),
            destinations: [
              NavigationDestination(
                key: const Key('pestana_hoxe'),
                icon: const Icon(Icons.wb_sunny_rounded),
                label: NomesDocentes.hoxe.resolve(lang),
              ),
              NavigationDestination(
                key: const Key('pestana_calendario'),
                icon: const Icon(Icons.calendar_month_rounded),
                label: NomesDocentes.calendario.resolve(lang),
              ),
              NavigationDestination(
                key: const Key('pestana_recursos'),
                icon: const Icon(Icons.grid_view_rounded),
                label: NomesDocentes.recursos.resolve(lang),
              ),
              NavigationDestination(
                key: const Key('pestana_eu'),
                icon: const Icon(Icons.person_rounded),
                label: NomesDocentes.eu.resolve(lang),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
