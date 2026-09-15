import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/repositories/ritual_repository.dart';

/// Qué hace la docente AHORA, en una línea, y cuánto lleva.
///
/// **El problema que resuelve.** La asamblea eran seis pantallas de prosa que
/// había que leer. Con doce criaturas en la alfombra nadie lee un párrafo: se
/// mira el móvil dos segundos y se levanta la cabeza. Esos dos segundos tienen
/// que bastar para saber qué toca, y antes no bastaban.
///
/// **Por qué el cronómetro empieza parado.** Porque la asamblea empieza cuando
/// la docente dice, no cuando se abre la pantalla. Y porque un contador que
/// corre solo desde el primer fotograma convierte una sugerencia de ritmo en
/// una cuenta atrás, que es justo lo que no queremos en 0-3.
///
/// **Por qué no suena nada al pasarse.** El canal auditivo es para la voz que
/// las crianzas tienen que seguir: parte de ellas llevan audiófono o implante.
/// Al pasarse, el número cambia de color y ya. La docente lo ve; la clase no se
/// entera.
class ConsignaFaseWidget extends StatefulWidget {
  final FaseAsamblea fase;
  final AppLanguage language;

  const ConsignaFaseWidget({
    super.key,
    required this.fase,
    required this.language,
  });

  @override
  State<ConsignaFaseWidget> createState() => _ConsignaFaseWidgetState();
}

class _ConsignaFaseWidgetState extends State<ConsignaFaseWidget> {
  Timer? _reloxo;
  Duration _levo = Duration.zero;

  static const _empezar = LocalizedString(gl: 'Contar', es: 'Contar');
  static const _parar = LocalizedString(gl: 'Parar', es: 'Parar');

  @override
  void didUpdateWidget(covariant ConsignaFaseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Cambiar de fase reinicia la cuenta: lo que importa es cuánto lleva ESTA
    // fase, no cuánto lleva la asamblea entera.
    if (oldWidget.fase.clave != widget.fase.clave) _parada();
  }

  @override
  void dispose() {
    _reloxo?.cancel();
    super.dispose();
  }

  void _parada() {
    _reloxo?.cancel();
    _reloxo = null;
    setState(() => _levo = Duration.zero);
  }

  void _alternar() {
    if (_reloxo != null) {
      _parada();
      return;
    }
    setState(() {
      _reloxo = Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() => _levo += const Duration(seconds: 1)),
      );
    });
  }

  String get _reloxoTexto {
    final m = _levo.inMinutes;
    final s = _levo.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final consigna = widget.fase.consigna.resolve(widget.language);
    if (consigna.isEmpty) return const SizedBox.shrink();

    final tope = Duration(minutes: widget.fase.minutos);
    final pasado = _levo > tope;
    final corriendo = _reloxo != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: const BoxDecoration(
        color: AppTheme.primaryLight,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2DDD0)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              consigna,
              // Grande de verdad: esta es la línea que se lee de un vistazo, y
              // el resto de la pantalla es consulta.
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 19.0,
                height: 1.3,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                corriendo ? _reloxoTexto : '${widget.fase.minutos} min',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: pasado
                      ? AppTheme.accentTerracotta
                      : AppTheme.primaryVigoBlue,
                ),
              ),
              const SizedBox(height: 2),
              TextButton(
                key: const Key('boton_reloxo_fase'),
                onPressed: _alternar,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  visualDensity: VisualDensity.compact,
                ),
                child: Text(
                  (corriendo ? _parar : _empezar).resolve(widget.language),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
