import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../../premios/premios_repository.dart';
import '../widgets/aula_ciclo_panel.dart';
import '../widgets/aula_primeiro_ciclo_panel.dart';
import '../widgets/aula_segundo_ciclo_panel.dart';
import 'asamblea_player_screen.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../data/repositories/calendario_repository.dart';

/// Ciclos educativos de Educación Infantil (Decreto 150/2022).
enum CicloEducativo {
  primerCiclo, // 0-3 anos (1.er Ciclo)
  segundoCiclo, // 3-6 anos (2.º Ciclo)
}

/// Screen listing pedagogical units for early childhood educators («Juega con Lúa · Aula»).
///
/// Features:
/// - Age band filtering tabs: 'Todas', '0-2 anos', '2-3 anos'.
/// - Thematic unit cards with curricular alignment badges (Decreto 150/2022).
/// - Launching the 6-step guided assembly mode.
/// - Dynamic bilingual language toggle (`gl`/`es`).
/// - Strict teacher focus: Sober Material 3 UI, zero child-distracting animations or games.
class UnidadesListScreen extends StatefulWidget {
  final ContentRepository repository;
  final OfflineAudioService? audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Opcional: sin él no se pinta la tira de juego ni cuentan las asambleas.
  final PremiosRepository? premios;

  /// Opcional: para sincronizar asambleas realizadas con o calendario escola-fogar.
  final CalendarioStore? calendario;

  /// Los diez meses, si quien abre esta pantalla ya los tiene leídos. Sin
  /// esto la sección del calendario los lee sola, que en la app tarda un
  /// fotograma pero en un test de captura puede no llegar a tiempo: la
  /// imagen salía con un hueco en blanco donde va el calendario.
  final CalendarioContenido? calendarioContenido;

  /// Ciclo educativo seleccionado por defecto (1.er Ciclo ou 2.º Ciclo).
  final CicloEducativo initialCiclo;

  const UnidadesListScreen({
    super.key,
    required this.repository,
    this.audioService,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.calendario,
    this.calendarioContenido,
    this.initialCiclo = CicloEducativo.primerCiclo,
  });

  @override
  State<UnidadesListScreen> createState() => _UnidadesListScreenState();
}

class _UnidadesListScreenState extends State<UnidadesListScreen> {
  late AppLanguage _language;
  late CicloEducativo _selectedCiclo; // 'todas', '0-2', '2-3'

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _selectedCiclo = widget.initialCiclo;
  }

  /// El calendario del curso, DENTRO de esta pantalla.
  ///
  /// Aquí había un botón azul que saltaba a otra pantalla. Un botón que lleva
  /// al calendario no es el calendario: la docente que abre el aula con dos
  /// minutos de margen tiene que ver el mes que le toca sin salir de donde
  /// está. Va en los dos ciclos, y la misma pieza va en Academy.
  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isGl ? 'Juega con Lúa · Aula' : 'Juega con Lúa · Aula',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Selector de Ciclo Educativo: [ 1.er Ciclo (0-3) | 2.º Ciclo (3-6) ]
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceLg,
                vertical: AppTheme.spaceSm,
              ),
              color: AppTheme.pageBg,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        key: const ValueKey('tab_primer_ciclo'),
                        onTap: () {
                          if (_selectedCiclo != CicloEducativo.primerCiclo) {
                            setState(() {
                              _selectedCiclo = CicloEducativo.primerCiclo;
                            });
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedCiclo == CicloEducativo.primerCiclo
                                ? AppTheme.card
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusField),
                            boxShadow:
                                _selectedCiclo == CicloEducativo.primerCiclo
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x1A000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ]
                                    : null,
                          ),
                          child: Text(
                            isGl
                                ? '1.º Ciclo (0-3 anos)'
                                : '1.er Ciclo (0-3 años)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14.5,
                              fontWeight:
                                  _selectedCiclo == CicloEducativo.primerCiclo
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                              color:
                                  _selectedCiclo == CicloEducativo.primerCiclo
                                      ? AppTheme.primaryInk
                                      : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: InkWell(
                        key: const ValueKey('tab_segundo_ciclo'),
                        onTap: () {
                          if (_selectedCiclo != CicloEducativo.segundoCiclo) {
                            setState(() {
                              _selectedCiclo = CicloEducativo.segundoCiclo;
                            });
                          }
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedCiclo == CicloEducativo.segundoCiclo
                                ? AppTheme.backstageBg
                                : Colors.transparent,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusField),
                            boxShadow:
                                _selectedCiclo == CicloEducativo.segundoCiclo
                                    ? const [
                                        BoxShadow(
                                          color: Color(0x33000000),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        )
                                      ]
                                    : null,
                          ),
                          child: Text(
                            isGl
                                ? '2.º Ciclo (3-6 anos)'
                                : '2.º Ciclo (3-6 años)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 14.5,
                              fontWeight:
                                  _selectedCiclo == CicloEducativo.segundoCiclo
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                              color:
                                  _selectedCiclo == CicloEducativo.segundoCiclo
                                      ? AppTheme.backstageAccent
                                      : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Vista condicional polo ciclo seleccionado. Os dous ciclos
            // teñen agora a MESMA forma: idade primeiro, mes de lado, e unha
            // soa tarxeta de fluxo. Sen desprazamento vertical.
            if (_selectedCiclo == CicloEducativo.segundoCiclo)
              _buildSegundoCicloView(context, isGl)
            else
              _buildPrimeiroCicloView(context),
          ],
        ),
      ),
    );
  }

  /// O aula do 1.º ciclo: tramo de idade, mes, e a microcápsula do día.
  Widget _buildPrimeiroCicloView(BuildContext context) {
    return AulaPrimeiroCicloPanel(
      asambleas: widget.repository.getAllAsambleasPrimeiroCicloSync(),
      language: _language,
      onComezar: (tramo, mes) {
        final asamblea =
            widget.repository.getAsambleaPrimeiroCicloSync(mes, tramo);
        if (asamblea == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AsambleaPlayerScreen(
              fases: asamblea.fases,
              subtitulo:
                  '${nomeDoMes[asamblea.mes]!.resolve(_language)} · ${asamblea.tramo.etiquetaCorta.resolve(_language)}',
              material: asamblea.materialDoMes.resolve(_language),
              cancion: asamblea.cancionDoMes,
              centroInteres: asamblea.centroInteres.resolve(_language),
              audioService: widget.audioService,
              language: _language,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSegundoCicloView(BuildContext context, bool isGl) {
    // El aula de 2.º ciclo ya no es una lista de 30 tarjetas bajo un
    // encabezado que decía «SETEMBRO» mientras la primera era de enero. Se
    // elige clase y mes, y sale una sola tarjeta de flujo. Sin scroll
    // vertical, que es lo que pide el documento curricular.
    return AulaSegundoCicloPanel(
      asambleas: widget.repository.getAllAsambleasSegundoCicloSync(),
      language: _language,
      onComezar: (nivel, mes) {
        final asamblea =
            widget.repository.getAsambleaByMesYNivelSync(mes, nivel);
        if (asamblea == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AsambleaPlayerScreen(
              fases: asamblea.fases,
              subtitulo:
                  '${nomeDoMes[asamblea.mes]!.resolve(_language)} · ${asamblea.nivel.etiquetaCorta.resolve(_language)}',
              centroInteres: asamblea.centroInteres.resolve(_language),
              audioService: widget.audioService,
              language: _language,
            ),
          ),
        );
      },
    );
  }

}
