import 'package:flutter/material.dart';

import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/theme/app_theme.dart';

/// Pantalla de bienvenida, con la estructura de la de Valeria+
/// (`docs/screenshots/01-bienvenida.png`): fondo turquesa a sangre, círculos
/// decorativos, la gata en una baldosa clara, el nombre, dos líneas de qué es
/// esto, un botón grande y una línea de privacidad al pie.
///
/// El texto va en TINTA OSCURA, no en blanco como en Valeria+: sobre el
/// turquesa de marca el blanco da 2,18:1 y aquí esto se mira en un aula con
/// ventanales. Ver `AppTheme.primaryInk`.
///
/// No guarda que ya la viste, y es a propósito: guardar esa marca sería un
/// campo persistido más que declarar en Play Console, y la app no guarda nada.
/// Cuesta un toque por arranque.
class WelcomeScreen extends StatelessWidget {
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final VoidCallback onStart;
  final VoidCallback onShowCredits;

  const WelcomeScreen({
    super.key,
    required this.currentLanguage,
    required this.onToggleLanguage,
    required this.onStart,
    required this.onShowCredits,
  });

  static const _claim = LocalizedString(
    gl: 'A asemblea e a casa, na mesma lingua.',
    es: 'La asamblea y la casa, en la misma lengua.',
  );

  static const _body = LocalizedString(
    gl: 'Xoga con Lúa é para a mestra na asemblea. Academy é para as familias '
        'na casa. Lúa acompaña ás dúas.',
    es: 'Juega con Lúa es para la maestra en la asamblea. Academy es para las '
        'familias en casa. Lúa acompaña a las dos.',
  );

  static const _start = LocalizedString(gl: 'Comezar', es: 'Comenzar');

  static const _credits = LocalizedString(
    gl: 'Quen fai isto',
    es: 'Quién hace esto',
  );

  static const _privacy = LocalizedString(
    gl: 'Sen datos, sen contas e sen conexión',
    es: 'Sin datos, sin cuentas y sin conexión',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: Stack(
        children: [
          // Los dos círculos de Valeria+. Decorativos y nada más, así que van
          // fuera del árbol semántico para que el lector de pantalla no los lea.
          const Positioned(
            top: -140,
            right: -90,
            child: ExcludeSemantics(child: _Blob(size: 320)),
          ),
          const Positioned(
            bottom: -110,
            left: -120,
            child: ExcludeSemantics(child: _Blob(size: 260)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spaceXl,
                vertical: AppTheme.spaceLg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: _LanguagePill(
                      language: currentLanguage,
                      onTap: onToggleLanguage,
                    ),
                  ),
                  // Scroll a propósito: con la escala de texto grande del
                  // sistema este bloque no cabe, y sin esto se corta en release
                  // sin decir nada.
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: AppTheme.spaceXl),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spaceLg),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: const LuaPixel(
                              pose: LuaPose.sit,
                              size: 132,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceXl),
                          Text(
                            'Descubre con Lúa',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(color: AppTheme.dark),
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          Text(
                            'Edición Vigo',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppTheme.primaryInk),
                          ),
                          const SizedBox(height: AppTheme.spaceXl),
                          Text(
                            _claim.resolve(currentLanguage),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(color: AppTheme.dark),
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          Text(
                            _body.resolve(currentLanguage),
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppTheme.primaryInk),
                          ),
                          const SizedBox(height: AppTheme.spaceXl),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryInk,
                    ),
                    child: Text(_start.resolve(currentLanguage)),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  TextButton(
                    onPressed: onShowCredits,
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryInk,
                    ),
                    child: Text(_credits.resolve(currentLanguage)),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        size: 16,
                        color: AppTheme.primaryInk,
                      ),
                      const SizedBox(width: AppTheme.spaceXs),
                      Flexible(
                        child: Text(
                          _privacy.resolve(currentLanguage),
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.primaryInk),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Círculo decorativo del fondo.
class _Blob extends StatelessWidget {
  final double size;

  const _Blob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0x1AFFFFFF),
        shape: BoxShape.circle,
      ),
    );
  }
}

/// Conmutador de lengua. Va arriba porque la mestra cambia de lingua delante
/// de las crianzas y tiene que encontrarlo sin buscar.
class _LanguagePill extends StatelessWidget {
  final AppLanguage language;
  final VoidCallback onTap;

  const _LanguagePill({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: language == AppLanguage.gl
          ? 'Cambiar a castelán'
          : 'Cambiar a galego',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceLg,
            vertical: AppTheme.spaceSm,
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          ),
          child: Text(
            language.flagLabel,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.primaryInk,
                ),
          ),
        ),
      ),
    );
  }
}
