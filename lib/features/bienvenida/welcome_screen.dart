import 'package:flutter/material.dart';

import '../../core/brand/ilustracion_portal.dart';
import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/paxina_sen_scroll.dart';
import 'nomes_inicio.dart';

/// El inicio: la bienvenida y la elección de portal en una sola pantalla.
///
/// Una pregunta, «Onde vas usala?», y dos respuestas grandes: «Na casa» y «Na
/// escola». Dicen dónde se usa la app, no a quién pertenece. Antes había una
/// bienvenida con un botón «Comezar» y, detrás, una elección de portal que
/// ocupaba 2,4 pantallas: cada portal con su ilustración, cuatro viñetas y la
/// guía de dos minutos, y el de la escuela por debajo del pliegue.
///
/// Conserva la estructura de la del proyecto anterior de la casa: fondo
/// turquesa a sangre, círculos decorativos, la gata en una baldosa clara, el
/// nombre y una línea de privacidad al pie. El texto va en TINTA OSCURA, no en
/// blanco: sobre el turquesa de marca el blanco da 2,18:1 y aquí esto se mira
/// en un aula con ventanales. Ver `AppTheme.primaryInk`.
///
/// No guarda la respuesta, y es a propósito: guardarla sería un dato más que
/// declarar en Play Console, y la app no guarda nada de eso. Cuesta un toque
/// por arranque.
class WelcomeScreen extends StatelessWidget {
  final AppLanguage currentLanguage;
  final VoidCallback onToggleLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// «Na casa»: el Portal Familias.
  final VoidCallback onCasa;

  /// «Na escola»: el Portal Docentes.
  final VoidCallback onEscola;
  final VoidCallback onShowCredits;

  const WelcomeScreen({
    super.key,
    required this.currentLanguage,
    required this.onToggleLanguage,
    this.onLanguageChanged,
    required this.onCasa,
    required this.onEscola,
    required this.onShowCredits,
  });

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
                          const SizedBox(height: AppTheme.spaceMd),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spaceMd),
                            decoration: BoxDecoration(
                              color: context.acentoTint,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: const LuaPixel(
                              pose: LuaPose.sit,
                              size: 96,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceLg),
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
                                ?.copyWith(color: AppTheme.dark),
                          ),
                          const SizedBox(height: AppTheme.spaceLg),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // La pregunta va pegada a sus respuestas.
                          Semantics(
                            header: true,
                            child: Text(
                              NomesInicio.pregunta.resolve(currentLanguage),
                              key: const Key('inicio_pregunta'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: AppTheme.dark),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          // Dos respuestas del mismo peso: ninguna es la
                          // principal, así que ninguna es un botón relleno.
                          _Resposta(
                            clave: 'inicio_na_casa',
                            nome: NomesInicio.casa.resolve(currentLanguage),
                            di: NomesInicio.casaDi.resolve(currentLanguage),
                            acento: AppTheme.familias,
                            ilustracion: const IlustracionFamilia(
                              width: 226,
                              height: 100,
                            ),
                            onTap: onCasa,
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          _Resposta(
                            clave: 'inicio_na_escola',
                            nome: NomesInicio.escola.resolve(currentLanguage),
                            di: NomesInicio.escolaDi.resolve(currentLanguage),
                            acento: AppTheme.docentes,
                            ilustracion: const IlustracionEscola(
                              width: 226,
                              height: 100,
                            ),
                            onTap: onEscola,
                          ),
                          const SizedBox(height: AppTheme.spaceMd),
                          TextButton(
                            onPressed: onShowCredits,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.dark,
                            ),
                            child: Text(NomesInicio.quenFaiIsto
                                .resolve(currentLanguage)),
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.lock_rounded,
                                size: 16,
                                color: AppTheme.dark,
                              ),
                              const SizedBox(width: AppTheme.spaceXs),
                              Flexible(
                                child: Text(
                                  NomesInicio.privacidade
                                      .resolve(currentLanguage),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: AppTheme.dark),
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

/// Una de las dos respuestas del inicio: la ilustración de su sitio, el
/// nombre en el color de su portal y una línea de qué hay dentro.
class _Resposta extends StatelessWidget {
  const _Resposta({
    required this.clave,
    required this.nome,
    required this.di,
    required this.acento,
    required this.ilustracion,
    required this.onTap,
  });

  final String clave;
  final String nome;
  final String di;
  final Color acento;
  final Widget ilustracion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // La etiqueta agrupa nombre y línea, y por eso excluye a los hijos: con
    // ellos se iría también la acción de pulsar del InkWell. Va aquí, o
    // TalkBack anuncia el botón y el doble toque no hace nada.
    return Semantics(
      button: true,
      label: '$nome. $di',
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey(clave),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceSm),
            child: Row(
              children: [
                // La escena entera, a escala y recortada al centro: dibujada
                // para el ancho de una tarjeta, aquí va en miniatura.
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  child: SizedBox(
                    width: 92,
                    height: 76,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: ilustracion,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: acento,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        di,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: acento, size: 28),
              ],
            ),
          ),
        ),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(
                Icons.language_rounded,
                size: 20.0,
                color: context.acento,
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
                color: isSelected ? context.acento : Colors.transparent,
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
