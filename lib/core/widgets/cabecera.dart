import 'package:flutter/material.dart';

import '../../features/academy/widgets/selector_idioma_widget.dart';
import '../localization/app_language.dart';
import '../theme/app_theme.dart';
import 'boton_atras.dart';

/// La cabecera de todas las pantallas: volver, un título corto y GL/ES.
///
/// Había cuatro: verde con el selector de lengua, verde sin él, blanca sin él
/// y blanca con un «GL» suelto. En diez pantallas no se podía cambiar de
/// lengua. Ahora hay una, del color del portal, y el selector va siempre: por
/// eso [language] y [onLanguageChanged] son obligatorios.
///
/// El título tiene que caber entero a 360 px de ancho, en gallego y en
/// castellano, con la flecha y el selector al lado. Lo comprueba
/// `ux_l2_test.dart` con la tipografía real; si un título no cabe, se acorta
/// el título, no la letra.
class Cabecera extends StatelessWidget implements PreferredSizeWidget {
  const Cabecera({
    super.key,
    required this.titulo,
    required this.language,
    required this.onLanguageChanged,
    this.subtitulo,
    this.accions = const [],
    this.bottom,
    this.atras = true,
  });

  final String titulo;

  /// Una segunda línea pequeña: la edad y el mes de un cuento, por ejemplo.
  final String? subtitulo;

  final AppLanguage language;
  final ValueChanged<AppLanguage> onLanguageChanged;

  /// Iconos propios de la pantalla. Van antes del selector de lengua.
  final List<Widget> accions;

  /// Las pestañas, si la pantalla las tiene.
  final PreferredSizeWidget? bottom;

  /// Sin flecha de volver: solo en la primera pantalla de la app.
  final bool atras;

  static const double _altoConSubtitulo = 64.0;

  @override
  Size get preferredSize =>
      Size.fromHeight((subtitulo == null ? kToolbarHeight : _altoConSubtitulo) +
          (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final estilo = Theme.of(context).appBarTheme.titleTextStyle;
    final titular = Text(
      titulo,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: estilo,
    );
    return AppBar(
      automaticallyImplyLeading: false,
      leading: atras ? const BotonAtras() : null,
      titleSpacing: atras ? 4 : 16,
      toolbarHeight: subtitulo == null ? kToolbarHeight : _altoConSubtitulo,
      title: Semantics(
        header: true,
        child: subtitulo == null
            ? titular
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titular,
                  Text(
                    subtitulo!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: estilo?.copyWith(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
      actions: [
        ...accions,
        Padding(
          padding: const EdgeInsets.only(left: 4, right: 8),
          child: SelectorIdiomaWidget(
            currentLanguage: language,
            onLanguageChanged: onLanguageChanged,
            compact: true,
          ),
        ),
      ],
      // Las pestañas, sobre blanco: encima del acento, la elegida —del color
      // del acento— no se vería, y las demás quedaban en gris sobre naranja.
      bottom: bottom == null
          ? null
          : PreferredSize(
              preferredSize: bottom!.preferredSize,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppTheme.card,
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                ),
                child: bottom,
              ),
            ),
    );
  }
}
