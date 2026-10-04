import 'package:flutter/material.dart';

import '../localization/app_language.dart';

/// La lengua de una pantalla que no tiene estado propio.
///
/// Empieza en [inicial], cambia desde el selector de la cabecera y avisa a
/// quien abrió la pantalla con [aoCambiar], para que al volver también esté
/// en la lengua nueva. Existe para que todas las pantallas lleven GL/ES sin
/// convertir cada una en un `StatefulWidget`.
class ConLingua extends StatefulWidget {
  const ConLingua({
    super.key,
    required this.inicial,
    required this.builder,
    this.aoCambiar,
  });

  final AppLanguage inicial;
  final ValueChanged<AppLanguage>? aoCambiar;
  final Widget Function(
    BuildContext context,
    AppLanguage lingua,
    ValueChanged<AppLanguage> cambiar,
  ) builder;

  @override
  State<ConLingua> createState() => _ConLinguaState();
}

class _ConLinguaState extends State<ConLingua> {
  late AppLanguage _lingua = widget.inicial;

  @override
  void didUpdateWidget(covariant ConLingua oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inicial != widget.inicial) _lingua = widget.inicial;
  }

  void _cambiar(AppLanguage lingua) {
    setState(() => _lingua = lingua);
    widget.aoCambiar?.call(lingua);
  }

  @override
  Widget build(BuildContext context) =>
      widget.builder(context, _lingua, _cambiar);
}
