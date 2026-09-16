import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../localization/localized_string.dart';
import '../theme/app_theme.dart';
import '../widgets/paxina_sen_scroll.dart';

/// Lo que se ve cuando el contenido de una pantalla no se puede leer.
///
/// **Por qué existe.** El Calendario y la Guía cargaban su JSON con
/// `cargar().then(...)` y sin `catchError`. Cuando el fichero no estaba en el
/// paquete —que es lo que pasó: faltaba `assets/content/calendario/` en
/// `pubspec.yaml`—, el future fallaba, el `setState` no llegaba nunca y la
/// pantalla se quedaba con el disco girando. Para siempre. Una docente delante
/// de doce criaturas no tiene forma de saber si eso es lentitud o avería, así
/// que espera, y luego cierra la app.
///
/// Un fallo de carga no se parece a «cargando»: se parece a una avería, y se
/// dice con esas palabras. El disco girando queda para lo que de verdad tarda.
class AvisoContenidoIlegible extends StatelessWidget {
  /// La ruta que no se pudo leer. Se enseña pequeña, al final: no le sirve a
  /// la docente, pero es lo primero que hace falta para arreglarlo.
  final String asset;

  final AppLanguage language;

  const AvisoContenidoIlegible({
    super.key,
    required this.asset,
    required this.language,
  });

  static const _titulo = LocalizedString(
    gl: 'Este contido non se puido abrir',
    es: 'Este contenido no se pudo abrir',
  );

  static const _explicacion = LocalizedString(
    gl: 'Non é a túa conexión: esta app non usa internet. Falta un ficheiro '
        'dentro do propio paquete, así que non hai nada que agardar. Volve '
        'instalar a app; se segue igual, avisa e arránxase na seguinte versión.',
    es: 'No es tu conexión: esta app no usa internet. Falta un fichero dentro '
        'del propio paquete, así que no hay nada que esperar. Vuelve a '
        'instalar la app; si sigue igual, avisa y se arregla en la siguiente '
        'versión.',
  );

  static const _paraQuienLoArregle = LocalizedString(
    gl: 'Para quen o arranxe:',
    es: 'Para quien lo arregle:',
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: PaxinaSenScroll(
        desprazarSeNonCabe: true,
        padding: const EdgeInsets.all(AppTheme.spaceXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.report_problem_outlined,
              size: 40,
              color: AppTheme.textMuted,
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              _titulo.resolve(language),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              _explicacion.resolve(language),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppTheme.spaceLg),
            Text(
              _paraQuienLoArregle.resolve(language),
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              asset,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textMuted,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
