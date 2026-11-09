import 'package:flutter/material.dart';

import '../leccions/views/calendario_de_leccions_screen.dart';
import '../criancas/crianza_da_casa.dart';
import '../criancas/criancas_store.dart';
import '../criancas/resultados_crianza_screen.dart';
import '../criancas/rexistro_crianza_screen.dart';
import '../../../core/navigation/ruta_lua.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../data/repositories/content_repository.dart';
import '../calendario/views/calendario_fogar_screen.dart';
import '../premios/premios_repository.dart';
import 'nomes_familias.dart';
import 'views/explorar_familias_screen.dart';
import 'views/guias_familias_screen.dart';
import 'views/hoxe_familias_screen.dart';

/// O Portal Familias: catro pestanas, e cada cousa vive nunha soa.
///
/// - **Hoxe**: o xogo de tres minutos, as súas palabras en inglés e o conto
///   da semana.
/// - **Calendario**: o curso mes a mes, aberto no día de hoxe.
/// - **Explorar**: os seis módulos de casa, cos seus nomes de casa.
/// - **Guías**: o que é para a persoa adulta: a guía de dous minutos, as
///   lecturas, a guía de inglés e os premios.
///
/// Antes era unha soa lista de catro pantallas e media: unha benvida, unha
/// tarxeta que levaba ao calendario, a tarxeta do inglés, dúas filas de
/// filtros e sete módulos. A crianza non toca o teléfono: quen o mira é a
/// persoa adulta, de esguello e con dous segundos.
class PortalFamiliasScreen extends StatefulWidget {
  final ContentRepository repository;
  final PremiosRepository? premios;
  final CalendarioStore? calendario;
  final OfflineAudioService audioService;
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Los niños de la casa (O-20261109-1). Por defecto, [CriancasStore.crear].
  final CriancasStore? criancas;

  /// Para os tests: o día que se quere ver. Por defecto, hoxe.
  final DateTime? agora;

  const PortalFamiliasScreen({
    super.key,
    required this.repository,
    required this.audioService,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
    this.criancas,
    this.agora,
  });

  @override
  State<PortalFamiliasScreen> createState() => _PortalFamiliasScreenState();
}

class _PortalFamiliasScreenState extends State<PortalFamiliasScreen> {
  late AppLanguage _language = widget.currentLanguage;
  late final CalendarioStore _store = widget.calendario ?? CalendarioStore();
  int _pestana = 0;

  /// Las pestañas ya abiertas. Una pestaña se construye la primera vez que
  /// se visita, no al entrar en el portal: el calendario y Explorar leen
  /// mucho contenido, y la portada no tiene por qué esperarlos.
  final Set<int> _visitadas = {0};

  /// Los niños de la casa: el curso de Hoy es el del último que se vio, y
  /// así no se pregunta cada vez que se abre la app (O-20261109-1).
  late final CriancasStore _criancas = widget.criancas ?? CriancasStore.crear();

  String get _curso => _criancas.activa?.curso ?? NomesFamilias.idades.first.$1;

  @override
  void initState() {
    super.initState();
    _criancas.addListener(_cambioCriancas);
    if (!_criancas.cargado) _criancas.cargar();
  }

  @override
  void dispose() {
    _criancas.removeListener(_cambioCriancas);
    super.dispose();
  }

  void _cambioCriancas() {
    if (mounted) setState(() {});
  }

  void _abrirResultados(BuildContext context) {
    Navigator.of(context).push(RutaLua(
      de: context,
      builder: (_) => ResultadosCrianzaScreen(
        store: _criancas,
        language: _language,
        onLanguageChanged: _cambiarLingua,
        calendario: _store,
        premios: widget.premios,
        agora: widget.agora,
      ),
    ));
  }

  @override
  void didUpdateWidget(covariant PortalFamiliasScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _language = widget.currentLanguage;
    }
  }

  void _cambiarLingua(AppLanguage lingua) {
    setState(() => _language = lingua);
    widget.onLanguageChanged?.call(lingua);
  }

  void _cambiarCurso(String curso) {
    if (_criancas.activa case final c?) {
      _criancas.actualizar(c.id, curso: curso);
    }
  }

  List<Widget> _pestanas(AppLanguage lang) => [
        HoxeFamiliasScreen(
          repository: widget.repository,
          store: _store,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          cursoId: _curso,
          onCambiarCurso: _cambiarCurso,
          audioService: widget.audioService,
          agora: widget.agora,
        ),
        // O-20261101-1: el calendario de lecciones; el de antes, dentro.
        CalendarioDeLeccionsScreen(
          key: ValueKey('calendario_leccions_$_curso'),
          cursoId: _curso,
          onCambiarCurso: _cambiarCurso,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          audioService: widget.audioService,
          paraAula: false,
          agora: widget.agora,
          calendarioCompleto: (_) => CalendarioFogarScreen(
            key: ValueKey('calendario_$_curso'),
            repository: widget.repository,
            store: _store,
            initialLanguage: lang,
            onLanguageChanged: _cambiarLingua,
            audioService: widget.audioService,
            initialCursoId: _curso,
            agora: widget.agora,
          ),
        ),
        ExplorarFamiliasScreen(
          repository: widget.repository,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          cursoId: _curso,
          onCambiarCurso: _cambiarCurso,
          audioService: widget.audioService,
          agora: widget.agora,
        ),
        GuiasFamiliasScreen(
          repository: widget.repository,
          language: lang,
          onLanguageChanged: _cambiarLingua,
          premios: widget.premios,
          calendario: _store,
          audioService: widget.audioService,
          onResultados:
              _criancas.activa == null ? null : () => _abrirResultados(context),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    if (!_criancas.cargado) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    // La primera vez: quién va a aprender. Después, nunca más.
    if (_criancas.activa == null) {
      return RexistroCrianzaScreen(
        key: const Key('rexistro_primeira'),
        store: _criancas,
        language: lang,
        onLanguageChanged: _cambiarLingua,
        primeira: true,
        onGardado: (_) {},
      );
    }
    return CrianzaDaCasa(
      store: _criancas,
      onLanguageChanged: _cambiarLingua,
      abrirResultados: _abrirResultados,
      child: _portal(context, lang),
    );
  }

  Widget _portal(BuildContext context, AppLanguage lang) {
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
            key: const Key('pestanas_familias'),
            selectedIndex: _pestana,
            onDestinationSelected: (i) => setState(() {
              _pestana = i;
              _visitadas.add(i);
            }),
            destinations: [
              NavigationDestination(
                key: const Key('pestana_hoxe'),
                icon: const Icon(Icons.wb_sunny_rounded),
                label: NomesFamilias.hoxe.resolve(lang),
              ),
              NavigationDestination(
                key: const Key('pestana_calendario'),
                icon: const Icon(Icons.calendar_month_rounded),
                label: NomesFamilias.calendario.resolve(lang),
              ),
              NavigationDestination(
                key: const Key('pestana_explorar'),
                icon: const Icon(Icons.grid_view_rounded),
                label: NomesFamilias.explorar.resolve(lang),
              ),
              NavigationDestination(
                key: const Key('pestana_guias'),
                icon: const Icon(Icons.menu_book_rounded),
                label: NomesFamilias.guias.resolve(lang),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
