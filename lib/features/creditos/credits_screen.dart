import 'package:flutter/material.dart';

import '../../core/brand/logo_institucional.dart';
import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/theme/app_theme.dart';

/// Créditos, con la estructura de los de Valeria+
/// (`docs/screenshots/02-creditos.png`): la gata y el nombre arriba, un
/// antetítulo en versalitas, la tarjeta de autoría y debajo los bloques de
/// atribución.
///
/// Regla de esta pantalla: **aquí solo se acredita lo que consta.** Los dos
/// colaboradores de abajo los nombró Frank; no se añade ninguno más por
/// iniciativa propia, porque poner un nombre institucional es atribuirse un
/// respaldo que esa institución no ha dado.
///
/// Cada uno va con su NOMBRE EN TEXTO, y con logotipo solo si el fichero
/// original está en `assets/brand/logos/`. Un logotipo institucional tiene
/// normas de uso propias (proporciones, versiones, fondos permitidos) y usarlo
/// mal es peor que no usarlo, así que no se redibuja ninguno a ojo: los huecos
/// de StartTIC, la Zona Franca y el Concello están puestos y vacíos, y
/// aparecen solos el día que se commiteen los ficheros. Ver el README de esa
/// carpeta.
///
/// Lo que sí está aquí es obligado: las voces neuronales y la tipografía llevan
/// licencia, y citarlas no es cortesía.
class CreditsScreen extends StatelessWidget {
  final AppLanguage currentLanguage;

  const CreditsScreen({super.key, required this.currentLanguage});

  static const _title = LocalizedString(gl: 'Créditos', es: 'Créditos');

  static const _madeBy = LocalizedString(
    gl: 'PROXECTO DESENVOLVIDO POR',
    es: 'PROYECTO DESARROLLADO POR',
  );

  static const _role = LocalizedString(
    gl: 'Otorrinolaringólogo infantil',
    es: 'Otorrinolaringólogo infantil',
  );

  static const _forWhom = LocalizedString(
    gl: 'Para as escolas infantís municipais de Vigo e as súas familias. '
        'Finalidade exclusivamente educativa.',
    es: 'Para las escuelas infantiles municipales de Vigo y sus familias. '
        'Finalidad exclusivamente educativa.',
  );

  static const _withKicker = LocalizedString(
    gl: 'EN COLABORACIÓN CON',
    es: 'EN COLABORACIÓN CON',
  );

  static const _cityHall = LocalizedString(
    gl: 'Concello de Vigo',
    es: 'Ayuntamiento de Vigo',
  );

  static const _starticDesc = LocalizedString(
    gl: 'Zona Franca de Vigo',
    es: 'Zona Franca de Vigo',
  );

  static const _cityHallDesc = LocalizedString(
    gl: 'Escolas infantís municipais',
    es: 'Escuelas infantiles municipales',
  );

  static const _voicesKicker = LocalizedString(
    gl: 'AS VOCES',
    es: 'LAS VOCES',
  );

  static const _voicesNote = LocalizedString(
    gl: 'As locucións sintetízanse unha soa vez e viaxan gravadas dentro da '
        'app. Os modelos nunca se executan no aparello, e por iso o APK non '
        'precisa permiso de rede.',
    es: 'Las locuciones se sintetizan una sola vez y viajan grabadas dentro de '
        'la app. Los modelos nunca se ejecutan en el aparato, y por eso el APK '
        'no necesita permiso de red.',
  );

  static const _celtiaDesc = LocalizedString(
    gl: 'Voz en galego. Proxecto Nós.',
    es: 'Voz en gallego. Proxecto Nós.',
  );

  static const _sharvardDesc = LocalizedString(
    gl: 'Voz en castelán. rhasspy/piper-voices.',
    es: 'Voz en castellano. rhasspy/piper-voices.',
  );

  static const _typeKicker = LocalizedString(
    gl: 'A TIPOGRAFÍA',
    es: 'LA TIPOGRAFÍA',
  );

  static const _nunitoDesc = LocalizedString(
    gl: 'The Nunito Project Authors. SIL Open Font License 1.1. '
        'A licenza viaxa no paquete, en assets/fonts/OFL.txt.',
    es: 'The Nunito Project Authors. SIL Open Font License 1.1. '
        'La licencia viaja en el paquete, en assets/fonts/OFL.txt.',
  );

  static const _contactKicker = LocalizedString(gl: 'CONTACTO', es: 'CONTACTO');

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: AppBar(title: Text(_title.resolve(currentLanguage))),
      body: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -100,
            child: ExcludeSemantics(child: _Blob(size: 280)),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceXl,
                AppTheme.spaceXl,
                AppTheme.spaceXl,
                AppTheme.spaceXxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: LuaPixel(size: 96)),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    'Descubre con Lúa',
                    textAlign: TextAlign.center,
                    style: text.headlineSmall?.copyWith(color: AppTheme.dark),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_madeBy.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: Column(
                      children: [
                        // El escudo es de Frank, no de un tercero: se usa.
                        const LogoInstitucional(
                          fichero: 'dr-betances-crest.png',
                          alto: 72,
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'Dr. Frank Alberto Betances Reinoso',
                          textAlign: TextAlign.center,
                          style: text.titleMedium
                              ?.copyWith(color: AppTheme.primaryInk),
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          _role.resolve(currentLanguage),
                          textAlign: TextAlign.center,
                          style: text.bodySmall
                              ?.copyWith(color: AppTheme.primaryInk),
                        ),
                        const Divider(height: AppTheme.spaceXl),
                        Text(
                          'Earlify Health S.L.',
                          textAlign: TextAlign.center,
                          style: text.titleSmall
                              ?.copyWith(color: AppTheme.primaryInk),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          _forWhom.resolve(currentLanguage),
                          textAlign: TextAlign.center,
                          style: text.bodySmall
                              ?.copyWith(color: AppTheme.primaryInk),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_withKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // El logotipo va encima del nombre y solo si el
                        // fichero está. El nombre no desaparece nunca: una
                        // fila de logotipos sin nombres no acredita a nadie, y
                        // quien no puede ver el logotipo tiene que leerlo.
                        // StartTIC es el programa del Consorcio, no una
                        // entidad aparte: los dos logotipos van sobre la misma
                        // entrada. Se envuelve en Wrap y no en Row para que a
                        // escala de texto grande caigan uno debajo del otro en
                        // vez de desbordar.
                        const Wrap(
                          spacing: AppTheme.spaceLg,
                          runSpacing: AppTheme.spaceSm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            LogoInstitucional(fichero: 'startic.png'),
                            LogoInstitucional(fichero: 'zona-franca-vigo.png'),
                          ],
                        ),
                        _Entry(
                          name: 'Programa StartTIC',
                          detail: _starticDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        const LogoInstitucional(fichero: 'concello-vigo.png'),
                        _Entry(
                          name: _cityHall.resolve(currentLanguage),
                          detail: _cityHallDesc.resolve(currentLanguage),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_voicesKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Entry(
                          name: 'Celtia',
                          detail: _celtiaDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _Entry(
                          name: 'Sharvard',
                          detail: _sharvardDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          _voicesNote.resolve(currentLanguage),
                          style: text.bodySmall
                              ?.copyWith(color: AppTheme.primaryInk),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_typeKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: _Entry(
                      name: 'Nunito',
                      detail: _nunitoDesc.resolve(currentLanguage),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_contactKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: SelectableText(
                      'frank.alberto.betances.reinoso@gmail.com',
                      textAlign: TextAlign.center,
                      style:
                          text.bodyMedium?.copyWith(color: AppTheme.primaryInk),
                    ),
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

class _Kicker extends StatelessWidget {
  final String label;

  const _Kicker(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.primaryInk,
            fontWeight: FontWeight.w800,
            letterSpacing: 2.0,
          ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spaceXl),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderActive),
      ),
      child: child,
    );
  }
}

class _Entry extends StatelessWidget {
  final String name;
  final String detail;

  const _Entry({required this.name, required this.detail});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: text.titleSmall?.copyWith(color: AppTheme.primaryInk),
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          detail,
          style: text.bodySmall?.copyWith(color: AppTheme.primaryInk),
        ),
      ],
    );
  }
}

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
