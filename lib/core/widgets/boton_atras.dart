import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// El botón de volver de todas las pantallas.
///
/// La flecha blanca de serie sobre la barra verde se leía mal: Frank lo dijo
/// —«el botón de atrás es difícil de leer, necesita más contraste»—. Esto es
/// un disco blanco con la flecha en el acento de la cabecera, el mismo
/// contraste que la lengua elegida en el selector del otro lado: naranja en
/// familias, turquesa oscuro en docentes.
///
/// El disco mide 40, pero se pulsa en 48 × 48 dp, el mínimo táctil de Android.
class BotonAtras extends StatelessWidget {
  const BotonAtras({super.key});

  @override
  Widget build(BuildContext context) {
    final fondo = Theme.of(context).appBarTheme.backgroundColor;
    // Sobre una barra clara, el acento sería invisible en el disco blanco.
    final flecha = fondo == null || fondo.computeLuminance() > 0.5
        ? AppTheme.primaryInk
        : fondo;
    return Center(
      child: Semantics(
        button: true,
        label: MaterialLocalizations.of(context).backButtonTooltip,
        child: SizedBox(
          width: AppTheme.touchMin,
          height: AppTheme.touchMin,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              key: const ValueKey('boton_atras'),
              customBorder: const CircleBorder(),
              onTap: () => Navigator.of(context).maybePop(),
              child: Center(
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    size: 24,
                    color: flecha,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
