import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/boton_atras.dart';
import '../../../data/models/tpr_curriculum_scheduler.dart';
import '../../calendario/widgets/palabras_do_dia.dart';
import '../../docentes/widgets/hoxe_na_aula.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;

/// Escucha: las frases y las órdenes largas del curso, mes a mes.
///
/// Antes eran cuatro frases escritas en este fichero, las mismas para todos
/// los cursos y ninguna de las que la clase decía. Ahora son las frases
/// (`phrase`) y las órdenes encadenadas (`complex`) de cada mes del curso:
/// dieciséis por mes, 160 por curso, 800 en el trayecto. Primero se escucha
/// sin leer; después se ve el texto, lo que significa y el gesto.
class ListeningScreen extends StatefulWidget {
  final ProgramaTpr? programa;
  final String cursoInicial;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  /// Para los tests: el día que se quiere ver. Por defecto, hoy.
  final DateTime? agora;

  const ListeningScreen({
    super.key,
    required this.programa,
    this.cursoInicial = 'curso_0_2',
    this.language = AppLanguage.gl,
    this.audioService,
    this.agora,
  });

  /// Las categorías que se escuchan: frases y órdenes encadenadas.
  static const Set<String> categorias = {'phrase', 'complex'};

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  late String _curso = widget.cursoInicial;
  late int _mes = diaDoCursoParaHoxe(agora: widget.agora).dia.mesCalendario;
  int _indice = 0;
  bool _revelada = false;

  List<PalabraNoCurso> get _frases {
    final curso = widget.programa?.curso(_curso);
    if (curso == null) return const [];
    return [
      for (final p in curso.palabrasEnOrde)
        if (p.mesCalendario == _mes &&
            ListeningScreen.categorias.contains(p.palabra.category))
          p,
    ];
  }

  void _ir(void Function() cambio) {
    setState(() {
      cambio();
      _revelada = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final programa = widget.programa;
    final curso = programa?.curso(_curso);
    final frases = _frases;
    final indice = frases.isEmpty ? 0 : _indice.clamp(0, frases.length - 1);

    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BotonAtras(),
        title: Text(
          isGl ? 'Escoita as frases do curso' : 'Escucha las frases del curso',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: SafeArea(
        child: programa == null || curso == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                key: const Key('escoita_lista'),
                padding: const EdgeInsets.all(16),
                children: [
                  SelectorDeCursoTpr(
                    programa: programa,
                    seleccionado: _curso,
                    language: lang,
                    prefixoClave: 'escoita_curso',
                    onCambiar: (c) => _ir(() {
                      _curso = c;
                      _indice = 0;
                    }),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final m in curso.meses)
                        ChoiceChip(
                          key: ValueKey('escoita_mes_${m.mesCalendario}'),
                          label: Text(
                              nomeDoMes[m.mesCalendario]?.resolve(lang) ?? ''),
                          selected: m.mesCalendario == _mes,
                          showCheckmark: false,
                          onSelected: (_) => _ir(() {
                            _mes = m.mesCalendario;
                            _indice = 0;
                          }),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (frases.isEmpty)
                    Text(isGl
                        ? 'Este mes non trae frases.'
                        : 'Este mes no trae frases.')
                  else ...[
                    Text(
                      isGl
                          ? 'Frase ${indice + 1} de ${frases.length} · ${nomeDoMes[_mes]?.resolve(lang) ?? ''}'
                          : 'Frase ${indice + 1} de ${frases.length} · ${nomeDoMes[_mes]?.resolve(lang) ?? ''}',
                      key: const Key('escoita_contador'),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _tarxeta(frases[indice], lang),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('escoita_anterior'),
                            onPressed: indice > 0
                                ? () => _ir(() => _indice = indice - 1)
                                : null,
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, AppTheme.touchMin),
                            ),
                            child: Text(isGl ? 'Anterior' : 'Anterior'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            key: const Key('escoita_seguinte'),
                            onPressed: indice < frases.length - 1
                                ? () => _ir(() => _indice = indice + 1)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(0, AppTheme.touchMin),
                            ),
                            child: Text(isGl ? 'Seguinte' : 'Siguiente'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  Widget _tarxeta(PalabraNoCurso f, AppLanguage lang) {
    final isGl = lang == AppLanguage.gl;
    final p = f.palabra;
    final cando =
        '${PalabrasDoDia.nomesDosDias[f.dia - 1].resolve(lang)}, semana ${f.semana}';
    return Card(
      key: const Key('escoita_tarxeta'),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.headphones, size: 40, color: AppTheme.primaryDark),
            const SizedBox(height: 10),
            Text(
              isGl
                  ? 'Escoita primeiro, sen ler. Despois fai o xesto.'
                  : 'Escucha primero, sin leer. Después haz el gesto.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            // Una pantalla de escucha sin nada que escuchar era la promesa
            // más grande que se rompía en esta app. La frase suena con la voz
            // del propio paquete, a ritmo de tutor si es frase.
            BotonEscuchar(
              audioService: widget.audioService,
              texto: p.en,
              language: AppLanguage.en,
              style: estiloIngles(p.en),
            ),
            const SizedBox(height: 16),
            if (_revelada) ...[
              Text(
                '"${p.en}"',
                key: const Key('escoita_texto'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.significado(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.primaryInk,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.warningBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${isGl ? 'Xesto' : 'Gesto'}: ${p.tprAction.resolve(lang)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.35,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isGl ? 'Saíu o $cando.' : 'Salió el $cando.',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ] else
              TextButton.icon(
                key: const Key('escoita_amosar'),
                onPressed: () => setState(() => _revelada = true),
                icon: const Icon(Icons.translate, size: 18),
                label: Text(isGl
                    ? 'Amosar o texto, o significado e o xesto'
                    : 'Mostrar el texto, el significado y el gesto'),
              ),
          ],
        ),
      ),
    );
  }
}
