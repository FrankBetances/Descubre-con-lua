import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/steam_cooperativo_model.dart';
import '../../academy/widgets/selector_idioma_widget.dart';

/// Partitura interactiva para la persona adulta facilitadora en la sesión STEAM cooperativa.
///
/// Principios clave:
/// - Cero Pantallas para el Menor: La persona adulta mediadora utiliza el dispositivo como
///   partitura visual y disparador auditivo; la criatura explora los objetos reales y la voz.
/// - Ciclo Didáctico Oppia: Observa (planteamiento sensorial y pausa socrática) ->
///   Experimenta (roles cooperativos y consigna directa) -> Construye (reto Make tangible).
/// - Estímulo TPR en inglés L2 de baja latencia (<80 ms) sin texto para la criatura.
/// - Matriz de Registro Observacional 1-Tap (Obserfy) cualitativo sin datos personales.
class SteamSesionGuiadaScreen extends StatefulWidget {
  final SteamUnit unit;
  final OfflineAudioService audioService;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const SteamSesionGuiadaScreen({
    super.key,
    required this.unit,
    required this.audioService,
    required this.initialLanguage,
    this.onLanguageChanged,
  });

  @override
  State<SteamSesionGuiadaScreen> createState() =>
      _SteamSesionGuiadaScreenState();
}

class _SteamSesionGuiadaScreenState extends State<SteamSesionGuiadaScreen> {
  late AppLanguage _language;
  StreamSubscription<bool>? _audioSub;
  bool _audioPlaying = false;

  // Temporizador de pausa socrática (5 segundos de silencio clínico)
  Timer? _timer;
  int _secondsLeft = 5;
  bool _timerActive = false;
  bool _timerDone = false;

  // Pistas desplegables
  bool _expandPistaN1 = false;
  bool _expandPistaN2 = false;

  // Registro observacional 1-Tap
  String? _selectedLog; // 'logrado', 'asistido', 'explorando'

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _listenAudio();
  }

  void _listenAudio() {
    _audioPlaying = widget.audioService.isPlaying &&
        widget.audioService.currentAssetPath == widget.unit.tprIngles.audioAsset;
    _audioSub = widget.audioService.isPlayingStream.listen((playing) {
      if (!mounted) return;
      setState(() {
        _audioPlaying = playing &&
            widget.audioService.currentAssetPath ==
                widget.unit.tprIngles.audioAsset;
      });
    });
  }

  @override
  void didUpdateWidget(covariant SteamSesionGuiadaScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialLanguage != widget.initialLanguage) {
      _language = widget.initialLanguage;
    }
    if (oldWidget.audioService != widget.audioService) {
      _audioSub?.cancel();
      _listenAudio();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioSub?.cancel();
    super.dispose();
  }

  void _handleLanguageChanged(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  void _startSocraticTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = widget.unit.cicloDidactico.pausaSilencioSegundos;
      _timerActive = true;
      _timerDone = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_secondsLeft <= 1) {
        t.cancel();
        setState(() {
          _secondsLeft = 0;
          _timerActive = false;
          _timerDone = true;
        });
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  Future<void> _toggleAudio() async {
    final assetPath = widget.unit.tprIngles.audioAsset;
    if (_audioPlaying) {
      await widget.audioService.stop();
    } else {
      if (widget.audioService.isPlaying) {
        await widget.audioService.stop();
      }
      await widget.audioService.playAsset(assetPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGl = _language == AppLanguage.gl;
    final unit = widget.unit;

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          unit.titulo.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _handleLanguageChanged,
              compact: true,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner recordatorio Cero Pantallas
              _buildZeroScreenNotice(isGl),
              const SizedBox(height: 12.0),

              // Cabecera de la Unidad: Nivel, Tiempo y Fenómeno
              _buildHeaderCard(isGl),
              const SizedBox(height: 14.0),

              // Materiales & Seguridad
              _buildMaterialesCard(isGl),
              const SizedBox(height: 14.0),

              // Roles Cooperativos
              _buildRolesCooperativosCard(isGl),
              const SizedBox(height: 16.0),

              // PASO 1: OBSERVA
              _buildPasoObservaCard(isGl),
              const SizedBox(height: 16.0),

              // PASO 2: EXPERIMENTA
              _buildPasoExperimentaCard(isGl),
              const SizedBox(height: 16.0),

              // PASO 3: CONSTRUYE (MAKE)
              _buildPasoConstruyeCard(isGl),
              const SizedBox(height: 16.0),

              // COMANDO TPR AUDITIVO EN INGLÉS L2
              _buildTprFloatingCard(isGl),
              const SizedBox(height: 16.0),

              // MATRIZ DE REGISTRO 1-TAP (OBSERFY)
              _buildEvaluacionCard(isGl),
              const SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZeroScreenNotice(bool isGl) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: AppTheme.primaryTint,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: AppTheme.borderActive),
      ),
      child: Row(
        children: [
          const Icon(Icons.screen_lock_portrait_rounded,
              color: AppTheme.primaryInk, size: 22),
          const SizedBox(width: 10.0),
          Expanded(
            child: Text(
              isGl
                  ? 'Aviso para a facilitadora: a criatura non mira a pantalla. A experiencia é 100% física, táctil e motriz.'
                  : 'Aviso para la facilitadora: la criatura no mira la pantalla. La experiencia es 100% física, táctil y motriz.',
              style: const TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryInk,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(bool isGl) {
    final unit = widget.unit;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${unit.nivelMadurativo} · ${unit.rangoEdad.resolve(_language)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                const Icon(Icons.timer_outlined,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${unit.tiempoEstimadoMin} min',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              unit.titulo.resolve(_language),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              unit.fenomeno.resolve(_language),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialesCard(bool isGl) {
    final unit = widget.unit;
    final tieneSeguridad =
        unit.materiales.every((m) => m.seguridadMayor4cm);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined,
                    color: AppTheme.primaryInk, size: 20),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Materiais da experiencia' : 'Materiales de la experiencia',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryInk,
                  ),
                ),
                const Spacer(),
                if (tieneSeguridad)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.successBg,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.success),
                    ),
                    child: Text(
                      isGl ? '> 4 cm seguridade' : '> 4 cm seguridad',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.success,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ...unit.materiales.map((m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ',
                          style: TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          '${m.item.resolve(_language)} (${m.cantidad}x)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRolesCooperativosCard(bool isGl) {
    final roles = widget.unit.dinamicaCooperativa.roles;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt_outlined,
                    color: Color(0xFF805AD5), size: 20),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Roles Cooperativos' : 'Roles Cooperativos',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF805AD5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.unit.dinamicaCooperativa.descripcion
                  .resolve(_language),
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            ...roles.map((r) => Container(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFAF5FF),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: const Color(0xFFE9D8FD)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.badge_outlined,
                          size: 18, color: Color(0xFF805AD5)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.nombre.resolve(_language),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF553C9A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              r.mision.resolve(_language),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildPasoObservaCard(bool isGl) {
    final ciclo = widget.unit.cicloDidactico;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: AppTheme.primaryLight,
                  child: Text('1',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryInk)),
                ),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Paso 1 · Observa' : 'Paso 1 · Observa',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryInk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ciclo.observaPlanteamiento.resolve(_language),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9EE),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFFBD38D)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGl ? 'Pregunta socrática de indagación:' : 'Pregunta socrática de indagación:',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF975A16),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ciclo.observaPregunta.resolve(_language),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF744210),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Botón de temporizador socrático (5s de silencio)
            OutlinedButton.icon(
              onPressed: _timerActive ? null : _startSocraticTimer,
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: _timerDone
                      ? AppTheme.success
                      : (_timerActive ? AppTheme.primary : AppTheme.border),
                ),
                backgroundColor: _timerDone
                    ? AppTheme.successBg
                    : (_timerActive ? AppTheme.primaryLight : Colors.white),
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: Icon(
                _timerDone
                    ? Icons.check_circle_outline_rounded
                    : Icons.hourglass_top_rounded,
                size: 18,
                color: _timerDone
                    ? AppTheme.success
                    : (_timerActive ? AppTheme.primaryInk : AppTheme.textSecondary),
              ),
              label: Text(
                _timerActive
                    ? (isGl
                        ? 'Silencio de observación: $_secondsLeft s...'
                        : 'Silencio de observación: $_secondsLeft s...')
                    : (_timerDone
                        ? (isGl
                            ? 'Pausa completada (${ciclo.pausaSilencioSegundos} s)'
                            : 'Pausa completada (${ciclo.pausaSilencioSegundos} s)')
                        : (isGl
                            ? 'Pausa socrática de silencio (${ciclo.pausaSilencioSegundos} s)'
                            : 'Pausa socrática de silencio (${ciclo.pausaSilencioSegundos} s)')),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: _timerDone
                      ? AppTheme.success
                      : (_timerActive ? AppTheme.primaryInk : AppTheme.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasoExperimentaCard(bool isGl) {
    final ciclo = widget.unit.cicloDidactico;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFC6F6D5),
                  child: Text('2',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF22543D))),
                ),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Paso 2 · Experimenta' : 'Paso 2 · Experimenta',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF22543D),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ciclo.experimentaConsigna.resolve(_language),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Pistas graduales (FreeCodeCamp)
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    title: Text(
                      isGl
                          ? 'Pista Nivel 1 (Socrática)'
                          : 'Pista Nivel 1 (Socrática)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryInk,
                      ),
                    ),
                    trailing: Icon(
                      _expandPistaN1
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: AppTheme.primaryInk,
                    ),
                    onTap: () =>
                        setState(() => _expandPistaN1 = !_expandPistaN1),
                  ),
                  if (_expandPistaN1)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        ciclo.experimentaPistaN1.resolve(_language),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                  const Divider(height: 1, color: AppTheme.border),
                  ListTile(
                    dense: true,
                    title: Text(
                      isGl
                          ? 'Pista Nivel 2 (Modelado físico)'
                          : 'Pista Nivel 2 (Modelado físico)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryInk,
                      ),
                    ),
                    trailing: Icon(
                      _expandPistaN2
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                      size: 20,
                      color: AppTheme.primaryInk,
                    ),
                    onTap: () =>
                        setState(() => _expandPistaN2 = !_expandPistaN2),
                  ),
                  if (_expandPistaN2)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: Text(
                        ciclo.experimentaPistaN2.resolve(_language),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppTheme.textSecondary,
                          height: 1.35,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasoConstruyeCard(bool isGl) {
    final ciclo = widget.unit.cicloDidactico;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 12,
                  backgroundColor: Color(0xFFFED7D7),
                  child: Text('3',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF9B2C2C))),
                ),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Paso 3 · Constrúe (Make)' : 'Paso 3 · Construye (Make)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF9B2C2C),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              ciclo.construyeReto.resolve(_language),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAFC),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isGl ? 'Síntese de peche:' : 'Síntesis de cierre:',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ciclo.construyeSintesis.resolve(_language),
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTprFloatingCard(bool isGl) {
    final tpr = widget.unit.tprIngles;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.primary, width: 1.5),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.volume_up_rounded,
                    color: AppTheme.primaryInk, size: 22),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Comando TPR en inglés (L2)' : 'Comando TPR en inglés (L2)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryInk,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tpr.ipa,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      color: AppTheme.primaryInk,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              tpr.accionCorporal.resolve(_language),
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                key: const ValueKey('boton_tpr_audio'),
                onPressed: _toggleAudio,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _audioPlaying ? const Color(0xFFE53E3E) : AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  _audioPlaying
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded,
                  size: 24,
                ),
                label: Text(
                  _audioPlaying
                    ? (isGl ? 'Parar estímulo' : 'Detener estímulo')
                    : (isGl
                        ? 'Emitir comando: «${tpr.comando}»'
                        : 'Emitir comando: «${tpr.comando}»'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluacionCard(bool isGl) {
    final eval = widget.unit.evaluacionObservacional;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.fact_check_outlined,
                    color: AppTheme.primaryInk, size: 20),
                const SizedBox(width: 8),
                Text(
                  isGl ? 'Avaliación Observacional (1-Tap)' : 'Evaluación Observacional (1-Tap)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryInk,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              eval.criterioLogro.resolve(_language),
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLogButton(
                    key: 'log_btn_logrado',
                    code: 'L',
                    label: isGl ? 'Logrado' : 'Logrado',
                    desc: eval.pautaLogrado.resolve(_language),
                    color: const Color(0xFF38A169),
                    isSelected: _selectedLog == 'logrado',
                    onTap: () => setState(() => _selectedLog = 'logrado'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLogButton(
                    key: 'log_btn_asistido',
                    code: 'A',
                    label: isGl ? 'Asistido' : 'Asistido',
                    desc: eval.pautaAsistido.resolve(_language),
                    color: const Color(0xFFD69E2E),
                    isSelected: _selectedLog == 'asistido',
                    onTap: () => setState(() => _selectedLog = 'asistido'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildLogButton(
                    key: 'log_btn_explorando',
                    code: 'E',
                    label: isGl ? 'Explorando' : 'Explorando',
                    desc: eval.pautaExplorando.resolve(_language),
                    color: const Color(0xFF3182CE),
                    isSelected: _selectedLog == 'explorando',
                    onTap: () => setState(() => _selectedLog = 'explorando'),
                  ),
                ),
              ],
            ),
            if (_selectedLog != null) ...[
              const SizedBox(height: 10),
              Text(
                _selectedLog == 'logrado'
                    ? eval.pautaLogrado.resolve(_language)
                    : (_selectedLog == 'asistido'
                        ? eval.pautaAsistido.resolve(_language)
                        : eval.pautaExplorando.resolve(_language)),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLogButton({
    required String key,
    required String code,
    required String label,
    required String desc,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: desc,
      child: InkWell(
        key: ValueKey(key),
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? color : AppTheme.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '[$code]',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? color : AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
