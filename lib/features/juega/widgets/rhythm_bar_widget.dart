import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Visual metronome for the pulse step.
///
/// Ported from Valeria's LuaRhythmBar, and for the reason written there: the
/// pulse has to be SEEN, not only heard. Half the children this kind of work is
/// aimed at wear a hearing aid or an implant, and an audible metronome competes
/// with the very voice they are meant to follow. Drawing the pulse leaves the
/// auditory channel whole for the words.
///
/// Drawn, not emoji: circles on a single stroke width, like the rest of the
/// set. The strong beat is larger and filled, the weak ones are rings, and the
/// beat in progress carries an outer ring — which is what lets a teacher
/// anticipate it, and anticipating is half the exercise.
class RhythmBarWidget extends StatelessWidget {
  /// Beats in one bar, one per pulse marker in the verse.
  final int beats;

  /// How often the strong beat falls.
  final int accentEvery;

  /// Beat in progress inside the bar, 0..beats-1. `null` means stopped.
  final int? current;

  /// Tempo caption, already formatted by the caller.
  final String tempoLabel;

  /// Spoken description for screen readers.
  final String semanticsLabel;

  const RhythmBarWidget({
    super.key,
    required this.beats,
    required this.accentEvery,
    required this.current,
    required this.tempoLabel,
    required this.semanticsLabel,
  });

  static const double _dot = 34.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: semanticsLabel,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6.0,
            runSpacing: 6.0,
            children: List.generate(beats, (index) {
              return CustomPaint(
                size: const Size(_dot, _dot),
                painter: _BeatPainter(
                  strong: index % accentEvery == 0,
                  active: current == index,
                  colour: AppTheme.primaryVigoBlue,
                ),
              );
            }),
          ),
          const SizedBox(height: 10.0),
          Text(
            tempoLabel,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textSlate,
            ),
          ),
        ],
      ),
    );
  }
}

class _BeatPainter extends CustomPainter {
  final bool strong;
  final bool active;
  final Color colour;

  const _BeatPainter({
    required this.strong,
    required this.active,
    required this.colour,
  });

  /// One stroke width for the whole set, as in the Valeria sprite sheet.
  static const double _stroke = 2.4;

  @override
  void paint(Canvas canvas, Size size) {
    final centre = Offset(size.width / 2, size.height / 2);
    final unit = size.width / 26.0;

    if (active) {
      canvas.drawCircle(
        centre,
        12.0 * unit,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = _stroke
          ..color = colour,
      );
    }

    final radius = (strong ? 8.5 : 6.0) * unit;
    final opacity = active
        ? 1.0
        : strong
            ? 0.55
            : 0.4;

    if (active || strong) {
      canvas.drawCircle(
        centre,
        radius,
        Paint()..color = colour.withValues(alpha: opacity),
      );
    }

    canvas.drawCircle(
      centre,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = _stroke
        ..color = colour.withValues(alpha: opacity),
    );
  }

  @override
  bool shouldRepaint(_BeatPainter old) =>
      old.strong != strong || old.active != active || old.colour != colour;
}
