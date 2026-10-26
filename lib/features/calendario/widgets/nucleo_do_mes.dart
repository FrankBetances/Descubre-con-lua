import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/rexistro_frases_model.dart';
import '../../../data/models/unidade_do_mes_model.dart';

/// Lo que se queda todo el mes: el núcleo de la unidad, con su voz, su gesto
/// y su objeto, y debajo la canción, el material y qué observar.
///
/// Es la misma pieza en el calendario del aula y en el de casa: si cada uno
/// pintara el mes a su manera, volverían a contar dos meses distintos. El
/// contenido sale entero de la unidad (`assets/content/unidades_mes/`); aquí
/// solo hay rótulos.
class NucleoDoMes extends StatelessWidget {
  final UnidadeDoMes unidade;

  /// El núcleo ya resuelto en el banco y en el registro, en su orden.
  final List<PezaDaUnidade> nucleo;

  /// Desde 3-4 años, lo demás que se queda el mes: fórmulas, descriptivas
  /// (desde 4-5) y la estructura (desde 4-5). Solo en el aula.
  final List<PezaDaUnidade> formulas;
  final List<PezaDaUnidade> descriptivas;
  final PezaDaUnidade? estructura;

  /// El contraste de sonido del mes (F4), ya resuelto: las dos palabras, una
  /// detrás de otra, para el oído de la adulta. Va en el aula y en casa.
  final (PezaDaUnidade, PezaDaUnidade)? contraste;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// En casa: sin material ni qué observar, que son del aula (la casa tendrá
  /// los suyos en `hogar`, `docs/PLAN_ARQUITECTURA_PEDAGOGIA.md`, apartado 8).
  final bool enCasa;

  const NucleoDoMes({
    super.key,
    required this.unidade,
    required this.nucleo,
    this.formulas = const [],
    this.descriptivas = const [],
    this.estructura,
    this.contraste,
    required this.language,
    required this.audioService,
    this.enCasa = false,
  });

  static const _kicker =
      LocalizedString(gl: 'O NÚCLEO DO MES', es: 'EL NÚCLEO DEL MES');
  static const _explica = LocalizedString(
    gl: 'Isto queda todo o mes, na asemblea e nas rutinas. As cinco palabras '
        'de cada día van debaixo, como ampliación.',
    es: 'Esto se queda todo el mes, en la asamblea y en las rutinas. Las cinco '
        'palabras de cada día van debajo, como ampliación.',
  );
  static const _explicaCasa = LocalizedString(
    gl: 'Isto é o que se traballa na escola todo o mes.',
    es: 'Esto es lo que se trabaja en la escuela todo el mes.',
  );
  static const _con = LocalizedString(gl: 'Con', es: 'Con');
  static const _cancion = LocalizedString(gl: 'Canción', es: 'Canción');
  static const _material = LocalizedString(gl: 'Material', es: 'Material');
  static const _formulas = LocalizedString(gl: 'FÓRMULAS', es: 'FÓRMULAS');
  static const _descriptivas =
      LocalizedString(gl: 'DESCRITIVAS', es: 'DESCRIPTIVAS');
  static const _estructura =
      LocalizedString(gl: 'A ESTRUTURA DO MES', es: 'LA ESTRUCTURA DEL MES');
  static const _observar =
      LocalizedString(gl: 'QUE OBSERVAR', es: 'QUÉ OBSERVAR');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kicker = theme.textTheme.labelSmall?.copyWith(
      color: context.acento,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.0,
    );
    const lectura = TextStyle(
      fontSize: 14,
      color: AppTheme.textSecondary,
      height: 1.35,
    );
    final cancion = unidade.cancion;
    final material = [
      for (final r in unidade.realia) r.resolve(language),
    ].where((t) => t.trim().isNotEmpty).join(' · ');

    return Column(
      key: const Key('nucleo_do_mes'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_kicker.resolve(language), style: kicker),
        const SizedBox(height: 4),
        Text((enCasa ? _explicaCasa : _explica).resolve(language),
            style: lectura),
        const SizedBox(height: AppTheme.spaceSm),
        for (final peza in nucleo)
          _Peza(
              peza: peza,
              language: language,
              audioService: audioService,
              con: _con.resolve(language)),
        if (!enCasa)
          for (final (rotulo, pezas) in [
            (_formulas, formulas),
            (_descriptivas, descriptivas),
            (_estructura, [if (estructura case final e?) e]),
          ])
            if (pezas.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceSm),
              Text(rotulo.resolve(language), style: kicker),
              const SizedBox(height: 4),
              for (final peza in pezas)
                _Peza(
                    peza: peza,
                    language: language,
                    audioService: audioService,
                    con: _con.resolve(language)),
              if (identical(pezas.first, estructura) &&
                  unidade.estructura!.nota.hasParity)
                Text(unidade.estructura!.nota.resolve(language),
                    style: lectura),
            ],
        if (contraste case (final a, final b))
          ContrasteDoMes(
            nota: unidade.contraste!.nota,
            a: a,
            b: b,
            language: language,
            audioService: audioService,
          ),
        if (cancion != null && cancion.trim().isNotEmpty) ...[
          const SizedBox(height: 4),
          _Linea(rotulo: _cancion.resolve(language), texto: cancion),
        ],
        if (!enCasa && material.isNotEmpty) ...[
          const SizedBox(height: 4),
          _Linea(rotulo: _material.resolve(language), texto: material),
        ],
        if (!enCasa && unidade.queObservar.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spaceMd),
          Text(_observar.resolve(language), style: kicker),
          const SizedBox(height: 4),
          for (final linea in unidade.queObservar)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('·  ', style: lectura),
                  Expanded(
                    child: Text(linea.resolve(language), style: lectura),
                  ),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// El contraste de sonido del mes: las dos palabras con su voz, una al lado
/// de la otra, y cómo decirlas. Es para el oído de la adulta, no un ejercicio
/// para la criatura. Va en el calendario y en la tarjeta del mes del aula.
class ContrasteDoMes extends StatelessWidget {
  final LocalizedString nota;
  final PezaDaUnidade a;
  final PezaDaUnidade b;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const ContrasteDoMes({
    super.key,
    required this.nota,
    required this.a,
    required this.b,
    required this.language,
    required this.audioService,
  });

  static const _rotulo =
      LocalizedString(gl: 'ESCOITA A DIFERENZA', es: 'ESCUCHA LA DIFERENCIA');

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('contraste_do_mes'),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _rotulo.resolve(language),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: context.acento,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final peza in [a, b])
                BotonEscuchar(
                  audioService: audioService,
                  texto: peza.en,
                  language: AppLanguage.en,
                  interfaz: language,
                  style: estiloIngles(peza.en),
                  comoChip: true,
                  colorChip: context.acento,
                  descripcion: peza.en,
                  significado: peza.significado,
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            nota.resolve(language),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// Una pieza del núcleo: la pastilla con voz y, debajo, lo que quiere decir,
/// el gesto y el objeto con que se presenta.
class _Peza extends StatelessWidget {
  final PezaDaUnidade peza;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final String con;

  const _Peza({
    required this.peza,
    required this.language,
    required this.audioService,
    required this.con,
  });

  @override
  Widget build(BuildContext context) {
    final significado = peza.significado?.resolve(language).trim() ?? '';
    final xesto = peza.xesto.resolve(language).trim();
    final objeto = peza.objeto?.resolve(language).trim() ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BotonEscuchar(
            audioService: audioService,
            texto: peza.en,
            language: AppLanguage.en,
            interfaz: language,
            // La misma regla que el corpus de voz: con otro estilo, el botón
            // buscaría una grabación que no existe y no se pintaría.
            style: estiloIngles(peza.en),
            comoChip: true,
            colorChip: context.acento,
            descripcion: peza.en,
            significado: peza.significado,
          ),
          const SizedBox(height: 3),
          Text.rich(
            TextSpan(
              children: [
                if (significado.isNotEmpty)
                  TextSpan(
                    text: significado,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                if (xesto.isNotEmpty)
                  TextSpan(text: significado.isEmpty ? xesto : ' · $xesto'),
              ],
            ),
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          if (objeto.isNotEmpty)
            Text(
              '$con: $objeto',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
                height: 1.35,
              ),
            ),
        ],
      ),
    );
  }
}

class _Linea extends StatelessWidget {
  final String rotulo;
  final String texto;

  const _Linea({required this.rotulo, required this.texto});

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$rotulo: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: texto),
          ],
        ),
        style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textSecondary,
          height: 1.35,
        ),
      );
}
