import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/imaxe_escena.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/movimiento.dart';
import '../../../data/models/plan_escoita_model.dart';

/// O-20261119-8: la actividad de escucha de la semana, dentro de la lección.
/// La pieza es la del mes; la actividad cambia con la semana (1 a 4).
class PasoEscoita {
  final int semana;
  final PezaMensual peza;
  const PasoEscoita({required this.semana, required this.peza});

  /// El mes y la semana salen del id de la lección: «curso_4_5.03.2».
  static PasoEscoita? para(String leccionId, PlanEscoita? plan) {
    final m = RegExp(r'^(curso_\d_\d)\.(\d+)\.(\d+)$').firstMatch(leccionId);
    if (m == null || plan == null) return null;
    final peza = plan.de(m.group(1)!, int.parse(m.group(2)!));
    final semana = int.parse(m.group(3)!);
    if (peza == null || semana < 1 || semana > 4) return null;
    return PasoEscoita(semana: semana, peza: peza);
  }

  String titulo(AppLanguage lang) {
    final gl = lang == AppLanguage.gl;
    return switch (semana) {
      1 => gl ? 'Escoita e sinala' : 'Escucha y señala',
      2 => gl ? 'Palabras que medran' : 'Palabras que crecen',
      3 => gl ? 'Fálalle así' : 'Háblale así',
      _ => gl ? 'Xogo do par' : 'Juego del par',
    };
  }
}

class VistaPasoEscoita extends StatelessWidget {
  final PasoEscoita paso;
  final AppLanguage lang;
  final OfflineAudioService? audioService;
  const VistaPasoEscoita(
      {super.key,
      required this.paso,
      required this.lang,
      required this.audioService});

  Widget _palabra(PalabraEscoita p, {double ancho = 130}) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (p.lamina case final c?)
            LaminaPalabra(
                clave: c,
                significado: p.significado.resolve(lang),
                lang: lang,
                ancho: ancho),
          const SizedBox(height: 6),
          BotonEscuchar(
            audioService: audioService,
            texto: p.en,
            language: AppLanguage.en,
            interfaz: lang,
            style: estiloIngles(p.en),
            comoChip: true,
            descripcion: p.en,
            significado: p.significado,
          ),
        ],
      );

  Text _nota(String t) => Text(t,
      style: const TextStyle(
          fontSize: 16, height: 1.4, color: AppTheme.textPrimary));

  @override
  Widget build(BuildContext context) {
    final p = paso.peza;
    final gl = lang == AppLanguage.gl;
    final par = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(child: Entrada(orden: 1, child: _palabra(p.a))),
        Flexible(child: Entrada(orden: 2, child: _palabra(p.b))),
      ],
    );
    final List<Widget> corpo = switch (paso.semana) {
      1 => [
          par,
          const SizedBox(height: 14),
          _nota(p.nota.resolve(lang)),
          const SizedBox(height: 8),
          _nota(gl
              ? 'Di ti unha das dúas sen sinalar; o neno ou a nena sinala o debuxo.'
              : 'Di tú una de las dos sin señalar; el niño o la niña señala el dibujo.'),
        ],
      2 => [
          Text(p.tema.resolve(lang),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (var i = 0; i < p.fases.length; i++)
            Entrada(
              orden: i + 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _palabra(p.fases[i], ancho: 96),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_tipo(p.fases[i].tipo, gl),
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: context.acento)),
                          const SizedBox(height: 4),
                          _nota(p.fases[i].accion.resolve(lang)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      3 => [
          _nota(gl
              ? 'Se di «${p.neno}», devólvelle a palabra un pouco máis longa:'
              : 'Si dice «${p.neno}», devuélvele la palabra un poco más larga:'),
          const SizedBox(height: 10),
          for (var i = 0; i < p.adulto.length; i++)
            Entrada(
              orden: i + 1,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BotonEscuchar(
                  audioService: audioService,
                  texto: p.adulto[i],
                  language: AppLanguage.en,
                  interfaz: lang,
                  style: estiloIngles(p.adulto[i]),
                  comoChip: true,
                  descripcion: p.adulto[i],
                ),
              ),
            ),
          const SizedBox(height: 6),
          _nota(p.notaModelo.resolve(lang)),
        ],
      _ => [
          par,
          const SizedBox(height: 14),
          _nota(p.misionAcerto.resolve(lang)),
          const SizedBox(height: 8),
          _nota(p.pista.resolve(lang)),
          const SizedBox(height: 8),
          _nota(p.misionFallo.resolve(lang)),
        ],
    };
    return Column(
      key: Key('leccion_escoita_s${paso.semana}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: corpo,
    );
  }

  static String _tipo(String t, bool gl) => switch (t) {
        'concepto' => gl ? 'O QUE É' : 'QUÉ ES',
        'parte' => gl ? 'UNHA PARTE' : 'UNA PARTE',
        'accion' => gl ? 'O QUE FAI' : 'QUÉ HACE',
        _ => gl ? 'COMO É' : 'CÓMO ES',
      };
}
