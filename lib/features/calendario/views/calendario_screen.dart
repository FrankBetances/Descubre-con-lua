import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/models/capsula_model.dart';
import '../../../data/models/unidad_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../academy/views/capsula_detail_screen.dart';
import '../../academy/views/guia_atencion_screen.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../../juega/views/asamblea_guiada_screen.dart';
import '../../premios/premios_repository.dart';
import '../widgets/boton_lanzar_sesion.dart';
import '../widgets/tarjeta_mes_curricular.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/iconos_contenido.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../widgets/temporizador_sutil_widget.dart';

/// Contrato de callback para o lanzamento a un toque da sesión
typedef IniciarSesionCallback = void Function(
    MesCurricular mes, bool esDocente);

/// Pantalla del Calendario Sincronizado Escuela-Hogar (10 meses, Septiembre a Junio).
///
/// Permite a docentes y familias sincronizar la estimulación auditiva y motora
/// del inglés (L3) en torno a centros de interés de Galicia (Decreto 150/2022),
/// celebrando la **Doble Estimulación** sin estrés ni penalizaciones.
class CalendarioScreen extends StatefulWidget {
  final CalendarioStore store;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final bool esDocenteInicial;
  final IniciarSesionCallback? onIniciarSesion;
  final ContentRepository? repository;
  final OfflineAudioService? audioService;
  final PremiosRepository? premios;

  /// El contenido ya cargado. Si no se pasa, la pantalla lo lee del bundle:
  /// los diez meses y la guía viven en `assets/content/calendario/`, no aquí.
  final CalendarioContenido? contenido;

  const CalendarioScreen({
    super.key,
    required this.store,
    this.contenido,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.esDocenteInicial = false,
    this.onIniciarSesion,
    this.repository,
    this.audioService,
    this.premios,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  late AppLanguage _language;
  late bool _esDocente;
  int _mesSeleccionadoIndex = 0;
  CalendarioContenido? _contenido;

  List<MesCurricular> get _meses => _contenido?.meses ?? const [];

  static const _titulo = LocalizedString(
    gl: 'Calendario Escola · Fogar',
    es: 'Calendario Escuela · Hogar',
  );

  static const _subtitulo = LocalizedString(
    gl: '10 meses de conexión entre a asemblea e a casa para o dobre de estimulación sen pantallas.',
    es: '10 meses de conexión entre la asamblea y la casa para el doble de estimulación sin pantallas.',
  );

  static const _rolDocente =
      LocalizedString(gl: 'Aula (Docentes)', es: 'Aula (Docentes)');
  static const _rolFamilia =
      LocalizedString(gl: 'Fogar (Familias)', es: 'Hogar (Familias)');

  static const _dobleEstimulacionTitulo = LocalizedString(
    gl: 'Dobre Estimulación Lograda',
    es: 'Doble Estimulación Lograda',
  );

  static const _marcarAula = LocalizedString(
    gl: 'Rexistrar asemblea de hoxe na aula',
    es: 'Registrar asamblea de hoy en el aula',
  );

  static const _marcarHogar = LocalizedString(
    gl: 'Rexistrar micro-rutina de hoxe na casa',
    es: 'Registrar micro-rutina de hoy en casa',
  );

  static const _hogarHecho = LocalizedString(
    gl: 'Rutina feita na casa hoxe!',
    es: '¡Rutina hecha en casa hoy!',
  );

  static const _aulaHecha = LocalizedString(
    gl: 'Asemblea feita na aula hoxe!',
    es: '¡Asamblea hecha en el aula hoy!',
  );

  static const _lexicoKicker = LocalizedString(
    gl: 'LÉXICO E COMANDOS TPR EN INGLÉS',
    es: 'LÉXICO Y COMANDOS TPR EN INGLÉS',
  );

  static const _aulaKicker = LocalizedString(
    gl: 'ACTIVIDADE NA AULA (ASEMBLEA MATINAL)',
    es: 'ACTIVIDAD EN EL AULA (ASAMBLEA MATINAL)',
  );

  static const _hogarKicker = LocalizedString(
    gl: 'MICRO-RUTINA NO FOGAR (3-5 MIN SEN PANTALLAS)',
    es: 'MICRO-RUTINA EN EL HOGAR (3-5 MIN SIN PANTALLAS)',
  );

  static const _iniciarAula = LocalizedString(
    gl: 'Iniciar asemblea guiada',
    es: 'Iniciar asamblea guiada',
  );

  static const _iniciarHogar = LocalizedString(
    gl: 'Iniciar micro-rutina no fogar',
    es: 'Iniciar micro-rutina en el hogar',
  );

  static const _instruccionsBrevesTitulo = LocalizedString(
    gl: 'Instrucións breves para a asemblea:',
    es: 'Instrucciones breves para la asamblea:',
  );

  static const _instruccionsBrevesCuerpo = LocalizedString(
    gl: 'Círculo na alfombra · Móbil só para a docente · Pulso a 72 BPM e xogo sensoriomotriz.',
    es: 'Círculo en la alfombra · Móvil solo para la docente · Pulso a 72 BPM y juego sensoriomotriz.',
  );

  static const _porQueImportaTitulo = LocalizedString(
    gl: 'Por que importa no desenvolvemento:',
    es: 'Por qué importa en el desarrollo:',
  );

  static const _guiaAtencionBoton = LocalizedString(
    gl: 'Ver a guía de inglés na casa',
    es: 'Ver la guía de inglés en casa',
  );

  static const _guiaAtencionSubtitulo = LocalizedString(
    gl: 'Canto dura o xogo segundo a idade, tres regras para a casa e a '
        'pronuncia de cada frase.',
    es: 'Cuánto dura el juego según la edad, tres reglas para casa y la '
        'pronunciación de cada frase.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _esDocente = widget.esDocenteInicial;

    final yaCargado = widget.contenido;
    if (yaCargado != null) {
      _contenido = yaCargado;
      _situarEnElMesDeHoy();
    } else {
      CalendarioContenido.cargar().then((c) {
        if (!mounted) return;
        setState(() {
          _contenido = c;
          _situarEnElMesDeHoy();
        });
      });
    }
  }

  /// Abre por el mes de curso que toca hoy, no por septiembre.
  void _situarEnElMesDeHoy() {
    final indice = _contenido?.indiceParaFecha(DateTime.now()) ?? 0;
    _mesSeleccionadoIndex = indice < 0 ? 0 : indice;
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  void _lanzarSesion(MesCurricular mes, bool esDocente) {
    if (widget.onIniciarSesion != null) {
      widget.onIniciarSesion!(mes, esDocente);
      return;
    }

    if (esDocente) {
      final unidades = widget.repository?.getAllUnidades() ?? [];
      Unidad? unidad;
      for (final u in unidades) {
        if (u.orden == mes.orden) {
          unidad = u;
          break;
        }
      }
      unidad ??= (unidades.isNotEmpty ? unidades.first : null);

      if (unidad != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AsambleaGuiadaScreen(
              unidad: unidad!,
              calendario: widget.store,
              audioService: widget.audioService,
              premios: widget.premios,
              initialLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
            ),
          ),
        );
      } else {
        Navigator.of(context).pushNamed('/juega');
      }
    } else {
      final capsulas = widget.repository?.getAllCapsulas() ?? [];
      Capsula? capsula;
      for (final c in capsulas) {
        if (c.orden == mes.orden) {
          capsula = c;
          break;
        }
      }
      capsula ??= (capsulas.isNotEmpty ? capsulas.first : null);

      if (capsula != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CapsulaDetailScreen(
              capsula: capsula!,
              premios: widget.premios,
              audioService: widget.audioService,
              initialLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
            ),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GuiaAtencionScreen(
              initialLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              audioService: widget.audioService,
              contenido: _contenido,
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_meses.isEmpty) {
      // El contenido todavía se está leyendo del paquete. Dura un fotograma en
      // un aparato real; una pantalla a medias se vería peor que esto.
      return Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(title: Text(_titulo.resolve(_language))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final mes = _meses[_mesSeleccionadoIndex];

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        title: Text(
          _titulo.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              // GL/ES, como el resto de la app: con el nombre entero
              // («Galego», «Castellano») la barra desbordaba 119 px a escala
              // de texto grande.
              compact: true,
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
          // El estado del día se lee AQUÍ DENTRO, no en el `build` de fuera.
          // Estaba fuera, y como AnimatedBuilder solo vuelve a llamar a este
          // closure, el cuerpo se repintaba con el estado viejo: se registraba
          // la asamblea, se guardaba bien en disco, y el cartel seguía
          // diciendo «aínda non hai nada». La Dobre Estimulación no se
          // celebraba nunca hasta salir de la pantalla y volver a entrar.
          final estadoHoy = widget.store.estadoParaFecha(DateTime.now());
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(theme),
                const SizedBox(height: AppTheme.spaceMd),
                _buildDobleEstimulacionCard(estadoHoy, theme),
                const SizedBox(height: AppTheme.spaceLg),
                _buildTarjetasVisuales(theme),
                const SizedBox(height: AppTheme.spaceMd),
                _buildMonthSelector(theme),
                const SizedBox(height: AppTheme.spaceLg),
                _buildRoleSwitcher(theme),
                const SizedBox(height: AppTheme.spaceLg),
                _buildMonthDetailCard(mes, theme),
                const SizedBox(height: AppTheme.spaceLg),
                _buildActionButtons(mes, estadoHoy, theme),
                const SizedBox(height: AppTheme.spaceXl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _subtitulo.resolve(_language),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Carrusel horizontal de tarjetas visuales curriculares (10 meses).
  ///
  /// Muestra la [TarjetaMesCurricular] con ilustración vectorial del mes
  /// seleccionado expandida y las demás en miniatura. Bajo la tarjeta activa
  /// aparece el [DetalleSesionPanel] con la actividad contextualizada.
  Widget _buildTarjetasVisuales(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kicker de sección
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: const Color(0xFF00838F),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _language == AppLanguage.gl
                      ? 'TARXETAS CURRICULARES · 10 MESES'
                      : 'TARJETAS CURRICULARES · 10 MESES',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF00838F),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Carrusel horizontal de tarjetas
        SizedBox(
          height: 232,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: _meses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final mesItem = _meses[index];
              final isSelected = index == _mesSeleccionadoIndex;
              // El año del curso: de septiembre a diciembre es el año en
              // curso; de enero a junio, el siguiente. Preguntar siempre por
              // el año natural de hoy dejaba enero a junio mirando un curso
              // que aún no había empezado.
              final hoy = DateTime.now();
              final anhoDoMes = mesItem.mesCalendario >= 9
                  ? (hoy.month >= 9 ? hoy.year : hoy.year - 1)
                  : (hoy.month >= 9 ? hoy.year + 1 : hoy.year);
              final estado =
                  widget.store.estadoParaMes(anhoDoMes, mesItem.mesCalendario);

              return SizedBox(
                width: isSelected ? 220 : 160,
                child: TarjetaMesCurricular(
                  lang: _language,
                  mes: mesItem,
                  estado: estado,
                  esDocente: _esDocente,
                  isSelected: isSelected,
                  onTap: () {
                    setState(() => _mesSeleccionadoIndex = index);
                  },
                ),
              );
            },
          ),
        ),
        // Panel de detalle contextualizado bajo la tarjeta activa
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.06),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: DetalleSesionPanel(
            key: ValueKey('panel_$_mesSeleccionadoIndex'),
            lang: _language,
            audioService: widget.audioService,
            mes: _meses[_mesSeleccionadoIndex],
            esDocente: _esDocente,
            acento: const [
              Color(0xFF00BFA5),
              Color(0xFFFF7043),
              Color(0xFFFF8F00),
              Color(0xFF1E88E5),
              Color(0xFF5C6BC0),
              Color(0xFFEF5350),
              Color(0xFF43A047),
              Color(0xFFF48FB1),
              Color(0xFF29B6F6),
              Color(0xFF00838F),
            ][_mesSeleccionadoIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildDobleEstimulacionCard(
      EstadoEstimulacion estado, ThemeData theme) {
    final esDoble = estado == EstadoEstimulacion.dobleEstimulacion;
    final esAula = estado == EstadoEstimulacion.soloAula;
    final esHogar = estado == EstadoEstimulacion.soloHogar;

    Color cardBg;
    Color borderColor;
    String statusText;

    if (esDoble) {
      cardBg = const Color(0xFFE8F8F5);
      borderColor = AppTheme.primary;
      statusText = _language == AppLanguage.gl
          ? 'Parabéns! Hoxe acadastes a Dobre Estimulación (Aula + Fogar).'
          : '¡Enhorabuena! Hoy lograsteis la Doble Estimulación (Aula + Hogar).';
    } else if (esAula) {
      cardBg = const Color(0xFFFFF9E6);
      borderColor = AppTheme.star;
      statusText = _language == AppLanguage.gl
          ? 'Asemblea feita na aula. Falta o xogo de 3 min na casa!'
          : 'Asamblea hecha en el aula. ¡Falta el juego de 3 min en casa!';
    } else if (esHogar) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = AppTheme.success;
      statusText = _language == AppLanguage.gl
          ? 'Rutina da casa rexistrada. Excelente acompañamento!'
          : 'Rutina de casa registrada. ¡Excelente acompañamiento!';
    } else {
      cardBg = Colors.white;
      borderColor = AppTheme.border;
      statusText = _language == AppLanguage.gl
          ? 'Días de Dobre Estimulación acumulados: ${widget.store.totalDobleEstimulacion}'
          : 'Días de Doble Estimulación acumulados: ${widget.store.totalDobleEstimulacion}';
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          const LuaPixel(size: 52),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        _dobleEstimulacionTitulo.resolve(_language),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (esDoble) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          color: AppTheme.star, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: esDoble ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _meses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mesItem = _meses[index];
          final isSelected = index == _mesSeleccionadoIndex;

          return ChoiceChip(
            label: Text(mesItem.nombreMes.resolve(_language)),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _mesSeleccionadoIndex = index;
                });
              }
            },
            selectedColor: AppTheme.primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : AppTheme.border,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleSwitcher(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              key: const Key('tab_rol_docente'),
              onTap: () => setState(() => _esDocente = true),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppTheme.radiusField),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      _esDocente ? AppTheme.primaryLight : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppTheme.radiusField),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_rounded,
                      size: 20,
                      color:
                          _esDocente ? AppTheme.primaryInk : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    // Flexible: «Fogar (Familias)» con su icono no cabe en
                    // media pantalla estrecha, ni en gallego ni con el texto
                    // grande del sistema. Desbordaba 5 px.
                    Flexible(
                      child: Text(
                        _rolDocente.resolve(_language),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              _esDocente ? FontWeight.bold : FontWeight.normal,
                          color: _esDocente
                              ? AppTheme.primaryInk
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              key: const Key('tab_rol_familia'),
              onTap: () => setState(() => _esDocente = false),
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(AppTheme.radiusField),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      !_esDocente ? AppTheme.primaryLight : Colors.transparent,
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(AppTheme.radiusField),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.home_rounded,
                      size: 20,
                      color: !_esDocente
                          ? AppTheme.primaryInk
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    // Flexible: «Fogar (Familias)» con su icono no cabe en
                    // media pantalla estrecha, ni en gallego ni con el texto
                    // grande del sistema. Desbordaba 5 px.
                    Flexible(
                      child: Text(
                        _rolFamilia.resolve(_language),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight:
                              !_esDocente ? FontWeight.bold : FontWeight.normal,
                          color: !_esDocente
                              ? AppTheme.primaryInk
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthDetailCard(MesCurricular mes, ThemeData theme) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera del mes
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  radius: 24,
                  child: Icon(iconoDeContenido(mes.icono),
                      color: AppTheme.primaryDark, size: 28),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mes.nombreMes.resolve(_language).toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.primaryDark,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        mes.centroInteres.resolve(_language),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              mes.objetivoPedagogico.resolve(_language),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const Divider(height: 32),

            // Léxico en inglés y Comandos TPR
            Text(
              _lexicoKicker.resolve(_language),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.primaryDark,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Cada pastilla SUENA. El altavoz no es decoración: se pulsa y
                // se oye la pronunciación antes de llevarla a la asamblea. La
                // que no tenga grabación todavía no se pinta.
                for (final palabra in mes.ingles.lexico)
                  BotonEscuchar(
                    audioService: widget.audioService,
                    texto: palabra,
                    language: AppLanguage.en,
                    style: VoiceStyle.slow,
                    comoChip: true,
                  ),
                for (final comando in mes.ingles.tpr)
                  BotonEscuchar(
                    audioService: widget.audioService,
                    texto: comando,
                    language: AppLanguage.en,
                    comoChip: true,
                    colorChip: const Color(0xFFE65100),
                  ),
              ],
            ),
            if (mes.ingles.frase.isNotEmpty) ...[
              const SizedBox(height: 10),
              BotonEscuchar(
                audioService: widget.audioService,
                texto: mes.ingles.frase,
                language: AppLanguage.en,
                comoChip: true,
                colorChip: AppTheme.primaryInk,
              ),
            ],
            const SizedBox(height: 20),

            // Actividad según rol seleccionado
            if (_esDocente) ...[
              TemporizadorSutilWidget(
                minutosMin: 5,
                minutosMax: 8,
                esDocente: true,
                language: _language,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTint,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 18, color: AppTheme.primaryDark),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _instruccionsBrevesTitulo.resolve(_language),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _instruccionsBrevesCuerpo.resolve(_language),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildRoleSection(
                kicker: _aulaKicker.resolve(_language),
                content: mes.actividadAula.resolve(_language),
                badge: _language == AppLanguage.gl
                    ? 'Asemblea (5-8 min)'
                    : 'Asamblea (5-8 min)',
                icon: Icons.groups_rounded,
                color: AppTheme.primaryDark,
                theme: theme,
              ),
            ] else ...[
              TemporizadorSutilWidget(
                minutosMin: 3,
                minutosMax: mes.minutosSugeridos,
                esDocente: false,
                language: _language,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded,
                            size: 18, color: Color(0xFFD97706)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _porQueImportaTitulo.resolve(_language),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mes.objetivoPedagogico.resolve(_language),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildRoleSection(
                kicker: _hogarKicker.resolve(_language),
                content: mes.actividadHogar.resolve(_language),
                subcontent:
                    '${_language == AppLanguage.gl ? "Momento suxerido" : "Momento sugerido"}: ${mes.rutinaRecomendadaHogar.resolve(_language)}',
                badge: '${mes.minutosSugeridos} min',
                icon: Icons.volunteer_activism_rounded,
                color: const Color(0xFFD97706),
                theme: theme,
              ),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('boton_guia_atencion'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GuiaAtencionScreen(
                      initialLanguage: _language,
                      onLanguageChanged: _onToggleLanguage,
                      audioService: widget.audioService,
                      contenido: _contenido,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.psychology_outlined,
                        color: AppTheme.primaryInk,
                        size: 26,
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _guiaAtencionBoton.resolve(_language),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guiaAtencionSubtitulo.resolve(_language),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                height: 1.3,
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection({
    required String kicker,
    required String content,
    String? subcontent,
    required String badge,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  kicker,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              // La chapa no puede empujar al rótulo fuera de la tarjeta: con
              // el texto grande del sistema, «Asemblea (5-8 min)» sola ya no
              // cabe al lado del rótulo.
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          if (subcontent != null) ...[
            const SizedBox(height: 6),
            Text(
              subcontent,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      MesCurricular mes, EstadoEstimulacion estado, ThemeData theme) {
    final hoy = DateTime.now();
    final isAulaHecha = estado == EstadoEstimulacion.soloAula ||
        estado == EstadoEstimulacion.dobleEstimulacion;
    final isHogarHecho = estado == EstadoEstimulacion.soloHogar ||
        estado == EstadoEstimulacion.dobleEstimulacion;

    if (_esDocente) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BotonLanzarSesion(
            key: const Key('boton_iniciar_sesion_aula'),
            label: _iniciarAula.resolve(_language),
            icon: Icons.play_circle_filled_rounded,
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            onPressed: () => _lanzarSesion(mes, true),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: const Key('boton_rexistrar_aula'),
              onPressed: () async {
                await widget.store.registrarAula(hoy);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_aulaHecha.resolve(_language)),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              icon: Icon(
                isAulaHecha
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                color: isAulaHecha ? AppTheme.success : AppTheme.primaryDark,
              ),
              label: Text(
                isAulaHecha
                    ? _aulaHecha.resolve(_language)
                    : _marcarAula.resolve(_language),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isAulaHecha ? AppTheme.success : AppTheme.primaryDark,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isAulaHecha ? AppTheme.success : AppTheme.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BotonLanzarSesion(
            key: const Key('boton_iniciar_sesion_fogar'),
            label: _iniciarHogar.resolve(_language),
            icon: Icons.volunteer_activism_rounded,
            backgroundColor: const Color(0xFFD97706),
            foregroundColor: Colors.white,
            onPressed: () => _lanzarSesion(mes, false),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: const Key('boton_rexistrar_fogar'),
              onPressed: () async {
                await widget.store.toggleHogar(hoy);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHogarHecho
                            ? (_language == AppLanguage.gl
                                ? 'Rexistro cancelado'
                                : 'Registro deshecho')
                            : _hogarHecho.resolve(_language),
                      ),
                      backgroundColor: isHogarHecho
                          ? AppTheme.textSecondary
                          : AppTheme.success,
                    ),
                  );
                }
              },
              icon: Icon(
                isHogarHecho
                    ? Icons.check_circle_rounded
                    : Icons.volunteer_activism_rounded,
                color:
                    isHogarHecho ? AppTheme.success : const Color(0xFFD97706),
              ),
              label: Text(
                isHogarHecho
                    ? _hogarHecho.resolve(_language)
                    : _marcarHogar.resolve(_language),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      isHogarHecho ? AppTheme.success : const Color(0xFFD97706),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isHogarHecho ? AppTheme.success : AppTheme.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}
