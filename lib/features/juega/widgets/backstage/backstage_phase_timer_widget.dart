import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

/// Temporizador discreto e silencioso para as fases da asemblea matinal.
///
/// Características de deseño para o docente:
/// - Díxitos tabulares amplos (34sp) lexibles a máis de dous metros de distancia.
/// - Cambio suave a cor ámbar (`AppTheme.backstageWarning`) cando se supera o tempo prescrito.
/// - Cero alarmas acústicas nin campás que interrompan a concentración dos nenos.
class BackstagePhaseTimerWidget extends StatefulWidget {
  final int duracionSegundos;
  final VoidCallback? onTimeCompleted;

  const BackstagePhaseTimerWidget({
    super.key,
    required this.duracionSegundos,
    this.onTimeCompleted,
  });

  @override
  State<BackstagePhaseTimerWidget> createState() =>
      _BackstagePhaseTimerWidgetState();
}

class _BackstagePhaseTimerWidgetState extends State<BackstagePhaseTimerWidget> {
  late int _segundosRestantes;
  Timer? _timer;
  bool _isRunning = false;
  bool _completedNotified = false;

  @override
  void initState() {
    super.initState();
    _segundosRestantes = widget.duracionSegundos;
  }

  @override
  void didUpdateWidget(covariant BackstagePhaseTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duracionSegundos != widget.duracionSegundos) {
      _resetTimer();
    }
  }

  void _toggleRunning() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _segundosRestantes--;
        if (_segundosRestantes <= 0 && !_completedNotified) {
          _completedNotified = true;
          widget.onTimeCompleted?.call();
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    if (mounted) {
      setState(() => _isRunning = false);
    }
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _segundosRestantes = widget.duracionSegundos;
      _completedNotified = false;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int totalSeconds) {
    final absSeconds = totalSeconds.abs();
    final minutes = absSeconds ~/ 60;
    final seconds = absSeconds % 60;
    final prefix = totalSeconds < 0 ? '+' : '';
    final mStr = minutes.toString().padLeft(2, '0');
    final sStr = seconds.toString().padLeft(2, '0');
    return '$prefix$mStr:$sStr';
  }

  @override
  Widget build(BuildContext context) {
    final isOvertime = _segundosRestantes < 0;
    final timerColor =
        isOvertime ? AppTheme.backstageWarning : AppTheme.backstageTextPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backstageSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(
          color: isOvertime
              ? AppTheme.backstageWarning.withValues(alpha: 0.6)
              : AppTheme.backstageBorder,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icono indicador de estado
          Icon(
            isOvertime
                ? Icons.hourglass_bottom_rounded
                : (_isRunning ? Icons.play_arrow_rounded : Icons.pause_rounded),
            color: timerColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          // Díxitos en alta lexibilidade
          Text(
            _formatTime(_segundosRestantes),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 34.0,
              fontWeight: FontWeight.w800,
              color: timerColor,
              letterSpacing: 1.5,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 16),
          // Botón Iniciar / Pausa (área táctil >= 48dp)
          IconButton(
            key: const ValueKey('timer_play_pause_button'),
            icon: Icon(
              _isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: AppTheme.backstageAccent,
              size: 38,
            ),
            onPressed: _toggleRunning,
            tooltip: _isRunning ? 'Pausar' : 'Iniciar',
          ),
          // Botón Reiniciar
          IconButton(
            key: const ValueKey('timer_reset_button'),
            icon: const Icon(
              Icons.replay_rounded,
              color: AppTheme.backstageTextSecondary,
              size: 28,
            ),
            onPressed: _resetTimer,
            tooltip: 'Reiniciar tempo de fase',
          ),
        ],
      ),
    );
  }
}
