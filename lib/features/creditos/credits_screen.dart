import 'package:flutter/material.dart';

import '../../core/brand/logo_institucional.dart';
import '../../core/brand/lua_pixel.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/paxina_sen_scroll.dart';
import '../../core/widgets/cabecera.dart';

/// Créditos, con la estructura de los del proyecto anterior de la casa
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
/// mal es peor que no usarlo, así que no se redibuja ninguno a ojo. Hoy se
/// pintan los de startTIC y la Zona Franca; el Concello de Vigo va sin
/// logotipo por decisión de Frank, y su nombre sigue donde estaba. Ver el
/// README de esa carpeta.
///
/// Lo que sí está aquí es obligado: las voces neuronales y la tipografía llevan
/// licencia, y citarlas no es cortesía.
class CreditsScreen extends StatefulWidget {
  final AppLanguage currentLanguage;

  /// Avisa a quien la abrió de que se cambió de lengua aquí.
  final ValueChanged<AppLanguage>? onLanguageChanged;

  const CreditsScreen({
    super.key,
    required this.currentLanguage,
    this.onLanguageChanged,
  });

  @override
  State<CreditsScreen> createState() => _CreditsScreenState();
}

class _CreditsScreenState extends State<CreditsScreen> {
  late AppLanguage _language = widget.currentLanguage;

  // Si quien la abrió la vuelve a pintar en otra lengua, se cambia; si no,
  // se quedaba en la de la primera vez.
  @override
  void didUpdateWidget(covariant CreditsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentLanguage != widget.currentLanguage) {
      _language = widget.currentLanguage;
    }
  }

  void _cambiarLingua(AppLanguage lang) {
    setState(() => _language = lang);
    widget.onLanguageChanged?.call(lang);
  }

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
    gl: 'Para as escolas infantís de Galicia e as súas familias. '
        'Finalidade exclusivamente educativa.',
    es: 'Para las escuelas infantiles de Galicia y sus familias. '
        'Finalidad exclusivamente educativa.',
  );

  static const _withKicker = LocalizedString(
    gl: 'PROCEDENCIA',
    es: 'PROCEDENCIA',
  );

  /// Nombre oficial confirmado por Frank el 12/9/2026. No se abrevia: la
  /// incubadora es un programa del Consorcio, y acreditar a una institución
  /// con el nombre mal escrito es peor que no acreditarla.
  static const _startic = LocalizedString(
    gl: 'Incubadora de Alta Tecnoloxía startTIC',
    es: 'Incubadora de Alta Tecnología startTIC',
  );

  static const _starticDesc = LocalizedString(
    gl: 'Consorcio da Zona Franca de Vigo',
    es: 'Consorcio de la Zona Franca de Vigo',
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

  static const _ljSpeechDesc = LocalizedString(
    gl: 'Voz en inglés (en-US), a da capa de inglés. rhasspy/piper-voices.',
    es: 'Voz en inglés (en-US), la de la capa de inglés. rhasspy/piper-voices.',
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

  static const _fredokaDesc = LocalizedString(
    gl: 'The Fredoka Project Authors. SIL Open Font License 1.1. Os títulos, '
        'como en Valeria. A licenza viaxa no paquete, en assets/fonts/OFL-Fredoka.txt.',
    es: 'The Fredoka Project Authors. SIL Open Font License 1.1. Los títulos, '
        'como en Valeria. La licencia viaja en el paquete, en assets/fonts/OFL-Fredoka.txt.',
  );

  static const _imagesKicker = LocalizedString(
    gl: 'AS IMAXES',
    es: 'LAS IMÁGENES',
  );

  static const _fluentEmojiDesc = LocalizedString(
    gl: 'Microsoft Fluent Emoji (estilo Flat). Copyright (c) Microsoft Corporation. '
        'Licenza MIT (assets/third_party/fluentui-emoji/LICENSE).',
    es: 'Microsoft Fluent Emoji (estilo Flat). Copyright (c) Microsoft Corporation. '
        'Licencia MIT (assets/third_party/fluentui-emoji/LICENSE).',
  );

  static const _iconifyDesc = LocalizedString(
    gl: 'Iconify (sets MIT, Apache 2.0 e CC0) e Game Icons (CC BY 3.0, con atribución por autor en ATTRIBUTION.md).',
    es: 'Iconify (sets MIT, Apache 2.0 y CC0) y Game Icons (CC BY 3.0, con atribución por autor en ATTRIBUTION.md).',
  );

  static const _dnizforDesc = LocalizedString(
    gl: 'dnizfor/vocabulary-flashcard-dataset. Copyright (c) 2026 Dnizfor. Licenza MIT.',
    es: 'dnizfor/vocabulary-flashcard-dataset. Copyright (c) 2026 Dnizfor. Licencia MIT.',
  );

  static const _pbImageBankDesc = LocalizedString(
    gl: 'Pratham Books / StoryWeaver (global-asp/pb-imagebank). Licenza CC BY 4.0, só para escenas de apoio co seu ilustrador en ATTRIBUTION.md.',
    es: 'Pratham Books / StoryWeaver (global-asp/pb-imagebank). Licencia CC BY 4.0, solo para escenas de apoyo con su ilustrador en ATTRIBUTION.md.',
  );

  static const _arNativeLibsDesc = LocalizedString(
    gl: 'Google ARCore SDK, Google Filament e Google MediaPipe Tasks Vision (Apache License 2.0, NOTICE en assets/third_party/ar-apache-2.0/NOTICE.txt). Todo o procesado da cámara faise na memoria RAM e nunca se garda nin se envía.',
    es: 'Google ARCore SDK, Google Filament y Google MediaPipe Tasks Vision (Apache License 2.0, NOTICE en assets/third_party/ar-apache-2.0/NOTICE.txt). Todo el procesado de cámara se hace en memoria RAM y nunca se guarda ni se envía.',
  );

  static const _contactKicker = LocalizedString(gl: 'CONTACTO', es: 'CONTACTO');

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final currentLanguage = _language;

    return Scaffold(
      backgroundColor: AppTheme.primary,
      appBar: Cabecera(
        titulo: _title.resolve(currentLanguage),
        language: _language,
        onLanguageChanged: _cambiarLingua,
      ),
      body: Stack(
        children: [
          const Positioned(
            top: -120,
            left: -100,
            child: ExcludeSemantics(child: _Blob(size: 280)),
          ),
          SafeArea(
            child: PaxinaSenScroll(
              desprazarSeNonCabe: true,
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
                        // La versión de la rama `logo` trae YA su propio fondo
                        // turquesa sólido, así que la placa oscura que llevaba
                        // antes sobra: le pondría un marco negro alrededor de
                        // un cuadrado que ya está resuelto.
                        const LogoInstitucional(
                          fichero: 'dr-betances-crest.jpg',
                          alto: 72,
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          'Dr. Frank Alberto Betances Reinoso',
                          textAlign: TextAlign.center,
                          style:
                              text.titleMedium?.copyWith(color: context.acento),
                        ),
                        const SizedBox(height: AppTheme.spaceXs),
                        Text(
                          _role.resolve(currentLanguage),
                          textAlign: TextAlign.center,
                          style:
                              text.bodySmall?.copyWith(color: context.acento),
                        ),
                        const Divider(height: AppTheme.spaceXl),
                        // Casi cuadrado y con margen blanco propio: a la
                        // altura de los apaisados se veía diminuto. Las marcas
                        // se igualan por peso óptico, no por alto de caja.
                        const LogoInstitucional(
                          fichero: 'earlify-health.jpg',
                          alto: 76,
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          'Earlify Health S.L.',
                          textAlign: TextAlign.center,
                          style:
                              text.titleSmall?.copyWith(color: context.acento),
                        ),
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          _forWhom.resolve(currentLanguage),
                          textAlign: TextAlign.center,
                          style:
                              text.bodySmall?.copyWith(color: context.acento),
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
                          runSpacing: AppTheme.spaceMd,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            LogoInstitucional(fichero: 'startic.png', alto: 32),
                            LogoInstitucional(
                              fichero: 'zona-franca-vigo.png',
                              alto: 48,
                            ),
                          ],
                        ),
                        _Entry(
                          name: _startic.resolve(currentLanguage),
                          detail: _starticDesc.resolve(currentLanguage),
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
                        _Entry(
                          name: 'LJSpeech',
                          detail: _ljSpeechDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        Text(
                          _voicesNote.resolve(currentLanguage),
                          style:
                              text.bodySmall?.copyWith(color: context.acento),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_typeKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Entry(
                          name: 'Nunito',
                          detail: _nunitoDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _Entry(
                          name: 'Fredoka',
                          detail: _fredokaDesc.resolve(currentLanguage),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_imagesKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Entry(
                          name: 'Fluent Emoji (Flat)',
                          detail: _fluentEmojiDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _Entry(
                          name: 'Iconify & Game Icons',
                          detail: _iconifyDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _Entry(
                          name: 'Vocabulary Flashcard Dataset',
                          detail: _dnizforDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _Entry(
                          name: 'PB Image Bank',
                          detail: _pbImageBankDesc.resolve(currentLanguage),
                        ),
                        const SizedBox(height: AppTheme.spaceMd),
                        _Entry(
                          name: 'ARCore SDK, Filament & MediaPipe',
                          detail: _arNativeLibsDesc.resolve(currentLanguage),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXl),
                  _Kicker(_contactKicker.resolve(currentLanguage)),
                  const SizedBox(height: AppTheme.spaceMd),
                  _GlassCard(
                    child: SelectableText(
                      'frank.alberto.betances.reinoso@gmail.com',
                      textAlign: TextAlign.center,
                      style: text.bodyMedium?.copyWith(color: context.acento),
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
            // Sobre la página turquesa de marca: tinta oscura, 8,59:1.
            color: AppTheme.dark,
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
        color: context.acentoTint,
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
          style: text.titleSmall?.copyWith(color: context.acento),
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          detail,
          style: text.bodySmall?.copyWith(color: context.acento),
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
