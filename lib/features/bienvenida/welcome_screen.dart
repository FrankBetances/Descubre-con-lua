import 'package:flutter/material.dart';

import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/paxina_sen_scroll.dart';

/// Pantalla de bienvenida, con la estructura de la del proyecto anterior de la casa
/// (`docs/screenshots/01-bienvenida.png`): fondo turquesa a sangre, círculos
/// decorativos, la gata en una baldosa clara, el nombre, dos líneas de qué es
/// esto, un botón grande y una línea de privacidad al pie.
///
/// El texto va en TINTA OSCURA, no en blanco como en el proyecto anterior de la casa: sobre el
/// turquesa de marca el blanco da 2,18:1 y aquí esto se mira en un aula con
/// ventanales. Ver `AppTheme.primaryInk`.
///
/// No guarda que ya la viste, y es a propósito: guardar esa marca sería un
/// campo persistido más que declarar en Play Console, y la app no guarda nada.
/// Cuesta un toque por arranque.
class WelcomeScreen extends StatelessWidget {
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final VoidCallback onStart;
  final VoidCallback onShowCredits;

  const WelcomeScreen({
    super.key,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
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
          // Los dos círculos del proyecto anterior de la casa. Decorativos y nada más, así que van
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
            // Receta a prueba de desbordes: un scroll que envuelve TODO —
            // botones incluidos— con una altura mínima igual a la pantalla.
            // A escala normal la columna ocupa esa altura y `spaceBetween`
            // reparte como si estuviera anclada; a escala de texto grande
            // crece y se desplaza, en vez de cortarse.
            //
            // Antes esto era Column + Expanded con el bloque de botones fuera
            // del scroll, y a escala 1,8 desbordaba. Lo cazó el test, no un
            // aparato: en release el desborde no se ve, el texto se corta.
            // NINGÚN hijo puede ser Expanded ni Flexible aquí, o la altura
            // vuelve a quedar acotada y el desborde regresa.
            child: LayoutBuilder(
              builder: (context, constraints) => PaxinaSenScroll(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceXl,
                  vertical: AppTheme.spaceLg,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - AppTheme.spaceXl * 2,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: _LanguageSelector(
                          currentLanguage: currentLanguage,
                          onToggleLanguage: onToggleLanguage,
                          onLanguageChanged: onLanguageChanged,
                        ),
                      ),
                      Column(
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                    ],
                  ),
                ),
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

/// Conmutador de lingua accesible e intuitivo para a persoa adulta / mestra.
///
/// Mostra os dous códigos de idioma (GL / ES) xunto a unha icona global de lingua,
/// facendo evidente o idioma activo e permitindo cambiar cun só toque.
/// Cumpre cos criterios de contraste AA e área táctil accesible (48px).
class _LanguageSelector extends StatelessWidget {
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const _LanguageSelector({
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = currentLanguage == AppLanguage.gl;

    return Semantics(
      container: true,
      label: isGl
          ? 'Selector de idioma. Galego activo.'
          : 'Selector de idioma. Castelán activo.',
      child: Container(
        constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusButton),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.language_rounded,
                size: 20.0,
                color: AppTheme.primaryInk,
              ),
            ),
            Container(
              width: 1.0,
              height: 20.0,
              color: AppTheme.border,
            ),
            const SizedBox(width: 4.0),
            _buildSegment(
              context: context,
              lang: AppLanguage.gl,
              label: 'GL',
              fullName: 'Galego',
              isSelected: isGl,
            ),
            const SizedBox(width: 4.0),
            _buildSegment(
              context: context,
              lang: AppLanguage.es,
              label: 'ES',
              fullName: 'Castelán',
              isSelected: !isGl,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegment({
    required BuildContext context,
    required AppLanguage lang,
    required String label,
    required String fullName,
    required bool isSelected,
  }) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: isSelected ? fullName : 'Cambiar a $fullName',
      child: Tooltip(
        message: fullName,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (onLanguageChanged != null) {
                if (lang != currentLanguage) {
                  onLanguageChanged!(lang);
                }
              } else {
                onToggleLanguage();
              }
            },
            borderRadius: BorderRadius.circular(10.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              constraints: const BoxConstraints(
                minHeight: 38.0,
                minWidth: 42.0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 6.0,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primaryInk : Colors.transparent,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
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
