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
import '../widgets/temporizador_sutil_widget.dart';

/// Contrato de callback para o lanzamento a un toque da sesión
typedef IniciarSesionCallback = void Function(MesCurricular mes, bool esDocente);

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

  const CalendarioScreen({
    super.key,
    required this.store,
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
  late int _mesSeleccionadoIndex;

  static const _titulo = LocalizedString(
    gl: 'Calendario Escola · Fogar',
    es: 'Calendario Escuela · Hogar',
  );

  static const _subtitulo = LocalizedString(
    gl: '10 meses de conexión entre a asemblea e a casa para o dobre de estimulación sen pantallas.',
    es: '10 meses de conexión entre la asamblea y la casa para el doble de estimulación sin pantallas.',
  );

  static const _rolDocente = LocalizedString(gl: 'Aula (Docentes)', es: 'Aula (Docentes)');
  static const _rolFamilia = LocalizedString(gl: 'Fogar (Familias)', es: 'Hogar (Familias)');

  static const _dobleEstimulacionTitulo = LocalizedString(
    gl: 'Dobre Estimulación Lograda',
    es: 'Doble Estimulación Lograda',
  );

  static const _dobleEstimulacionDesc = LocalizedString(
    gl: 'Asemblea na aula pola mañá + xogo de 3 min na casa pola tarde.',
    es: 'Asamblea en el aula por la mañana + juego de 3 min en casa por la tarde.',
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
    gl: 'Ver Guía de Atención e 3 Regras de Ouro',
    es: 'Ver Guía de Atención y 3 Reglas de Oro',
  );

  static const _guiaAtencionSubtitulo = LocalizedString(
    gl: 'Atención por idades (0-3 anos) e as 3 regras de ouro sen pantallas.',
    es: 'Atención por edades (0-3 años) y las 3 reglas de oro sin pantallas.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _esDocente = widget.esDocenteInicial;

    // Seleccionar el mes actual del curso escolar
    final hoy = DateTime.now();
    final mesActual = MesCurricular.mesActualParaFecha(hoy);
    _mesSeleccionadoIndex = MesCurricular.meses.indexOf(mesActual);
    if (_mesSeleccionadoIndex < 0) _mesSeleccionadoIndex = 0;
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
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mes = MesCurricular.meses[_mesSeleccionadoIndex];
    final hoy = DateTime.now();
    final estadoHoy = widget.store.estadoParaFecha(hoy);

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
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.store,
        builder: (context, _) {
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
              Text(
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
            ],
          ),
        ),
        // Carrusel horizontal de tarjetas
        SizedBox(
          height: 280,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemCount: MesCurricular.meses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final mesItem = MesCurricular.meses[index];
              final isSelected = index == _mesSeleccionadoIndex;
              final estado = widget.store.estadoParaFecha(
                DateTime(DateTime.now().year, mesItem.mesCalendario, 15),
              );

              return SizedBox(
                width: isSelected ? 220 : 160,
                child: TarjetaMesCurricular(
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
            mes: MesCurricular.meses[_mesSeleccionadoIndex],
            esDocente: _esDocente,
            acento: const [
              Color(0xFF00BFA5), Color(0xFFFF7043), Color(0xFFFF8F00),
              Color(0xFF1E88E5), Color(0xFF5C6BC0), Color(0xFFEF5350),
              Color(0xFF43A047), Color(0xFFF48FB1), Color(0xFF29B6F6),
              Color(0xFF00838F),
            ][_mesSeleccionadoIndex],
          ),
        ),
      ],
    );
  }

  Widget _buildDobleEstimulacionCard(EstadoEstimulacion estado, ThemeData theme) {
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
          ? '🌟 Parabéns! Hoxe acadastes a Dobre Estimulación (Aula + Fogar).'
          : '🌟 ¡Enhorabuena! Hoy lograsteis la Doble Estimulación (Aula + Hogar).';
    } else if (esAula) {
      cardBg = const Color(0xFFFFF9E6);
      borderColor = AppTheme.star;
      statusText = _language == AppLanguage.gl
          ? '🏫 Asemblea feita na aula. Falta o xogo de 3 min na casa!'
          : '🏫 Asamblea hecha en el aula. ¡Falta el juego de 3 min en casa!';
    } else if (esHogar) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = AppTheme.success;
      statusText = _language == AppLanguage.gl
          ? '🏡 Rutina da casa rexistrada. Excelente acompañamento!'
          : '🏡 Rutina de casa registrada. ¡Excelente acompañamiento!';
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
                    Text(
                      _dobleEstimulacionTitulo.resolve(_language),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (esDoble) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded, color: AppTheme.star, size: 20),
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
        itemCount: MesCurricular.meses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final mesItem = MesCurricular.meses[index];
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
                  color: _esDocente ? AppTheme.primaryLight : Colors.transparent,
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
                      color: _esDocente ? AppTheme.primaryInk : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _rolDocente.resolve(_language),
                      style: TextStyle(
                        fontWeight: _esDocente ? FontWeight.bold : FontWeight.normal,
                        color: _esDocente ? AppTheme.primaryInk : AppTheme.textSecondary,
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
                  color: !_esDocente ? AppTheme.primaryLight : Colors.transparent,
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
                      color: !_esDocente ? AppTheme.primaryInk : AppTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _rolFamilia.resolve(_language),
                      style: TextStyle(
                        fontWeight: !_esDocente ? FontWeight.bold : FontWeight.normal,
                        color: !_esDocente ? AppTheme.primaryInk : AppTheme.textSecondary,
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
                  child: Icon(mes.icono, color: AppTheme.primaryDark, size: 28),
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
              runSpacing: 6,
              children: [
                ...mes.lexicoIngles.map(
                  (palabra) => Chip(
                    backgroundColor: AppTheme.primaryLight,
                    label: Text(
                      palabra,
                      style: const TextStyle(
                        color: AppTheme.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                ...mes.comandosTpr.map(
                  (comando) => Chip(
                    backgroundColor: const Color(0xFFFFF4E5),
                    avatar: const Icon(
                      Icons.directions_run_rounded,
                      size: 16,
                      color: Color(0xFFE65100),
                    ),
                    label: Text(
                      comando,
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTint,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(color: AppTheme.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined, size: 18, color: AppTheme.primaryDark),
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
                minutosMax: mes.minutosAtencionSugeridos,
                esDocente: false,
                language: _language,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDF5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 18, color: Color(0xFFD97706)),
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
                subcontent: '${_language == AppLanguage.gl ? "Momento suxerido" : "Momento sugerido"}: ${mes.rutinaRecomendadaHogar.resolve(_language)}',
                badge: '${mes.minutosAtencionSugeridos} min',
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
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget _buildActionButtons(MesCurricular mes, EstadoEstimulacion estado, ThemeData theme) {
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
                isAulaHecha ? Icons.check_circle_rounded : Icons.check_circle_outline_rounded,
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
                      backgroundColor: isHogarHecho ? AppTheme.textSecondary : AppTheme.success,
                    ),
                  );
                }
              },
              icon: Icon(
                isHogarHecho ? Icons.check_circle_rounded : Icons.volunteer_activism_rounded,
                color: isHogarHecho ? AppTheme.success : const Color(0xFFD97706),
              ),
              label: Text(
                isHogarHecho
                    ? _hogarHecho.resolve(_language)
                    : _marcarHogar.resolve(_language),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isHogarHecho ? AppTheme.success : const Color(0xFFD97706),
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
