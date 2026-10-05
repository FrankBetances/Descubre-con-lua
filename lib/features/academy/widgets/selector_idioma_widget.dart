import 'package:flutter/material.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';

/// El selector de lengua (`GL` / `ES`) de la cabecera de todas las pantallas.
///
/// Va siempre sobre el acento del portal, que pasa AA con blanco: la lengua sin
/// elegir va en blanco sobre el acento (5,02:1 en familias y 5,16:1 en
/// docentes) y la elegida en el acento sobre blanco. Antes la pastilla llevaba
/// un velo blanco del 15 % que bajaba el blanco a 3,85:1, y en las cabeceras
/// blancas la lengua sin elegir —blanca— no se veía.
///
/// Cada lengua se puede pulsar en 48 × 48 dp, aunque la pastilla que se ve
/// mide 34 de alto: es el mínimo táctil de Android.
class SelectorIdiomaWidget extends StatelessWidget {
  final AppLanguage currentLanguage;
  final ValueChanged<AppLanguage> onLanguageChanged;

  /// `GL` / `ES` en vez de `Galego` / `Castellano`. En la cabecera, siempre.
  final bool compact;

  const SelectorIdiomaWidget({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final acento = tema.appBarTheme.backgroundColor ?? tema.colorScheme.primary;
    final ancho = compact ? AppTheme.touchMin : 96.0;
    // Dos letras en una pastilla de 34 px: con la letra del sistema muy
    // grande se saldrían, y GL/ES se leen igual a 1,3.
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.3,
      child: SizedBox(
        height: AppTheme.touchMin,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 34,
              width: ancho * 2 + 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(17),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final lang in AppLanguage.deInterfaz)
                  _opcion(lang, acento, ancho),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcion(AppLanguage lang, Color acento, double ancho) {
    final elixida = currentLanguage == lang;
    return Semantics(
      button: true,
      selected: elixida,
      label: lang.displayName,
      // Excluir a los hijos quita también la acción del InkWell.
      onTap: elixida ? null : () => onLanguageChanged(lang),
      excludeSemantics: true,
      child: InkWell(
        key: ValueKey('lingua_${lang.code}'),
        customBorder: const StadiumBorder(),
        onTap: elixida ? null : () => onLanguageChanged(lang),
        child: SizedBox(
          width: ancho,
          height: AppTheme.touchMin,
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: ancho - 6,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: elixida ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                compact ? lang.flagLabel : lang.displayName,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: elixida ? acento : Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
