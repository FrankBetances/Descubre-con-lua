import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// El botón de volver de todas las pantallas.
///
/// La flecha blanca de serie sobre la barra verde se leía mal: Frank lo dijo
/// —«el botón de atrás es difícil de leer, necesita más contraste»—. Esto es
/// un disco blanco con la flecha en tinta, el mismo contraste que la pastilla
/// de idioma que va al otro lado de la barra. Funciona igual sobre la barra
/// verde del aula y sobre la oscura del reproductor.
class BotonAtras extends StatelessWidget {
  const BotonAtras({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Semantics(
        button: true,
        label: MaterialLocalizations.of(context).backButtonTooltip,
        child: Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            key: const ValueKey('boton_atras'),
            customBorder: const CircleBorder(),
            onTap: () => Navigator.of(context).maybePop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.arrow_back_rounded,
                size: 24,
                color: AppTheme.primaryInk,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
