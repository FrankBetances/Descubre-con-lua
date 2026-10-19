import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/rexistro_frases_model.dart';

/// El núcleo del mes en la tarjeta de Hoy (M3.10, D1): va delante, en
/// pastillas con voz, y las cinco palabras del día quedan debajo como
/// ampliación ([PalabrasDoDiaPlegadas]).
///
/// Es la forma corta de [NucleoDoMes]: en Hoy la tarjeta no puede crecer, así
/// que el gesto y el significado van en la pastilla (un toque, en inglés; dos,
/// lo que quiere decir) y solo se escribe el objeto, que es lo que hay que
/// tener a mano antes de empezar.
class NucleoDeHoxe extends StatelessWidget {
  final List<PezaDaUnidade> nucleo;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const NucleoDeHoxe({
    super.key,
    required this.nucleo,
    required this.language,
    required this.audioService,
  });

  static const kicker =
      LocalizedString(gl: 'O NÚCLEO DO MES', es: 'EL NÚCLEO DEL MES');
  static const _con = LocalizedString(gl: 'Con', es: 'Con');

  @override
  Widget build(BuildContext context) {
    final conObxecto = [
      for (final p in nucleo)
        if ((p.objeto?.resolve(language).trim() ?? '').isNotEmpty) p,
    ];
    return Column(
      key: const Key('nucleo_de_hoxe'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          kicker.resolve(language),
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        // Wrap: con letra grande las pastillas bajan de línea en vez de salirse.
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final peza in nucleo)
              BotonEscuchar(
                audioService: audioService,
                texto: peza.en,
                language: AppLanguage.en,
                interfaz: language,
                // La regla del corpus de voz: con otro estilo no hay grabación.
                style: estiloIngles(peza.en),
                comoChip: true,
                colorChip: context.acento,
                descripcion: peza.en,
                significado: peza.significado ?? peza.xesto,
              ),
          ],
        ),
        for (final peza in conObxecto)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                  text: peza.en,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                    text: ' · ${_con.resolve(language)}: '
                        '${peza.objeto!.resolve(language)}'),
              ]),
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                height: 1.35,
              ),
            ),
          ),
      ],
    );
  }
}

/// Las cinco palabras del día, plegadas bajo el núcleo: con D1 son ampliación,
/// no lo primero. Cerradas, ocupan una fila; abiertas, son lo de siempre.
class PalabrasDoDiaPlegadas extends StatefulWidget {
  /// El rótulo de la fila, que es el que tenía la tarjeta: «PALABRAS DE HOXE».
  final String titulo;
  final AppLanguage language;
  final Widget child;

  const PalabrasDoDiaPlegadas({
    super.key,
    required this.titulo,
    required this.language,
    required this.child,
  });

  static const _cerradas = LocalizedString(
    gl: 'As cinco do día, como ampliación. Toca para velas.',
    es: 'Las cinco del día, como ampliación. Toca para verlas.',
  );
  static const _abertas = LocalizedString(
    gl: 'As cinco do día, como ampliación.',
    es: 'Las cinco del día, como ampliación.',
  );

  @override
  State<PalabrasDoDiaPlegadas> createState() => _PalabrasDoDiaPlegadasState();
}

class _PalabrasDoDiaPlegadasState extends State<PalabrasDoDiaPlegadas> {
  bool _aberta = false;

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          button: true,
          expanded: _aberta,
          child: InkWell(
            key: const Key('abrir_palabras_do_dia'),
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
            onTap: () => setState(() => _aberta = !_aberta),
            child: ConstrainedBox(
              // 48 px: el mínimo de diana táctil.
              constraints: const BoxConstraints(minHeight: 48),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.titulo,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          (_aberta
                                  ? PalabrasDoDiaPlegadas._abertas
                                  : PalabrasDoDiaPlegadas._cerradas)
                              .resolve(lang),
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _aberta
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: context.acento,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_aberta) ...[
          const SizedBox(height: 6),
          widget.child,
        ],
      ],
    );
  }
}
