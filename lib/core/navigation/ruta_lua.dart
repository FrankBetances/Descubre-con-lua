import 'package:flutter/material.dart';

/// La ruta de todas las pantallas: la de Material, con el tema de quien la
/// abre.
///
/// Cada portal tiene su acento (`AppTheme.temaFamilias`, `temaDocentes`). Pero
/// una pantalla nueva no cuelga de la que la abre, sino del `Navigator`, y
/// allí el tema es el de la app: sin esto, un cuento abierto desde el Portal
/// Familias saldría con la cabecera de las docentes. Se captura el tema en
/// [de], el contexto que abre, y se le pone a la pantalla nueva; así pasa de
/// pantalla en pantalla todo lo hondo que se baje.
class RutaLua<T> extends MaterialPageRoute<T> {
  RutaLua({
    required BuildContext de,
    required WidgetBuilder builder,
    super.settings,
    super.fullscreenDialog,
  }) : super(builder: _conTema(Theme.of(de), builder));

  static WidgetBuilder _conTema(ThemeData tema, WidgetBuilder builder) =>
      (context) => Theme(data: tema, child: Builder(builder: builder));
}
