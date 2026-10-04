import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../localization/localized_string.dart';
import '../theme/app_theme.dart';

/// «Que observar»: pistas cortas para la persona adulta, que se leen y no se
/// marcan. Es el mismo bloque que lleva la sesión STEAM, y sustituye a los
/// botones «Logrado · Asistido · Explorando», que pedían a la familia evaluar a
/// la criatura —justo lo que la app dice que no hace— y que además no guardaban
/// nada.
class QueObservar extends StatelessWidget {
  final List<LocalizedString> pistas;
  final AppLanguage language;

  const QueObservar({
    super.key,
    required this.pistas,
    required this.language,
  });

  static const _titulo =
      LocalizedString(gl: 'Que observar', es: 'Qué observar');
  static const _nota = LocalizedString(
    gl: 'Non é unha avaliación: son pistas para ti. A app non garda nada de ningunha criatura.',
    es: 'No es una evaluación: son pistas para ti. La app no guarda nada de ninguna criatura.',
  );

  @override
  Widget build(BuildContext context) {
    if (pistas.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded,
                  size: 20, color: AppTheme.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _titulo.resolve(language),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          for (final pista in pistas)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 7, right: 8),
                    child: Icon(Icons.circle,
                        size: 7, color: AppTheme.primaryDark),
                  ),
                  Expanded(
                    child: Text(
                      pista.resolve(language),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            _nota.resolve(language),
            style: const TextStyle(
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
