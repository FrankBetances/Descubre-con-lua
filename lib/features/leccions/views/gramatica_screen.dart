import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/cabecera.dart';
import '../../../data/models/leccion_model.dart';
import '../../juega/widgets/aula_ciclo_panel.dart' show nomeDoMes;
import '../widgets/leccion_da_semana.dart';

/// La gramática del curso, de A1 a C1 (Frank, 28/10/2026). Los puntos 1-20
/// son la columna de las cinco edades y dicen en qué edad y mes se trabajan;
/// los 21-48 son para la persona adulta, con un ejemplo que se puede oír.
class GramaticaScreen extends StatefulWidget {
  final AppLanguage language;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final OfflineAudioService? audioService;

  /// El punto de la unidad desde la que se abre, resaltado.
  final int? destacado;

  const GramaticaScreen({
    super.key,
    required this.language,
    this.onLanguageChanged,
    this.audioService,
    this.destacado,
  });

  @override
  State<GramaticaScreen> createState() => _GramaticaScreenState();
}

class _GramaticaScreenState extends State<GramaticaScreen> {
  late AppLanguage _lang = widget.language;
  // Sin catchError: en un SynchronousFuture no completa nunca.
  late final Future<GramaticaDoCurso?> _gramatica = GramaticaDoCurso.cargar()
      .then<GramaticaDoCurso?>((g) => g, onError: (_) => null);

  static const _niveis = {
    'A1': ('A1 · Principiante', 'A1 · Principiante'),
    'A2': ('A2 · Elemental', 'A2 · Elemental'),
    'B1': ('B1 · Intermedio', 'B1 · Intermedio'),
    'B2': ('B2 · Intermedio alto', 'B2 · Intermedio alto'),
    'C1': ('C1 · Dominio', 'C1 · Dominio'),
  };

  @override
  Widget build(BuildContext context) {
    final isGl = _lang == AppLanguage.gl;
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: Cabecera(
        titulo: isGl ? 'A gramática do curso' : 'La gramática del curso',
        language: _lang,
        onLanguageChanged: (l) {
          setState(() => _lang = l);
          widget.onLanguageChanged?.call(l);
        },
      ),
      body: SafeArea(
        child: FutureBuilder<GramaticaDoCurso?>(
          future: _gramatica,
          builder: (context, snap) {
            final g = snap.data;
            if (g == null) return const SizedBox.shrink();
            String? nivel;
            return ListView(
              key: const Key('gramatica'),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                Text(
                  isGl
                      ? 'Do máis sinxelo ao máis complexo. A1 e A2 son o que traballan as criaturas, de 0 a 6 anos, nas frases que dis ti; B1 a C1 son para ti, por se queres ir máis aló.'
                      : 'De lo más sencillo a lo más complejo. A1 y A2 son lo que trabajan las criaturas, de 0 a 6 años, en las frases que dices tú; B1 a C1 son para ti, por si quieres ir más allá.',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                for (final p in g.puntos) ...[
                  if (p.nivel != nivel) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 22, bottom: 6),
                      child: Text(
                        (() {
                          nivel = p.nivel;
                          final n = _niveis[p.nivel];
                          return (isGl ? n?.$1 : n?.$2) ?? p.nivel;
                        })()
                            .toUpperCase(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: context.acento,
                        ),
                      ),
                    ),
                  ],
                  _Punto(
                    punto: p,
                    onde: g.onde[p.n] ?? const [],
                    destacado: p.n == widget.destacado,
                    language: _lang,
                    audioService: widget.audioService,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  final PuntoDeGramatica punto;
  final List<(String, int)> onde;
  final bool destacado;
  final AppLanguage language;
  final OfflineAudioService? audioService;

  const _Punto({
    required this.punto,
    required this.onde,
    required this.destacado,
    required this.language,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final lang = language;
    final isGl = lang == AppLanguage.gl;
    const lectura = TextStyle(
      fontSize: 14.5,
      color: AppTheme.textSecondary,
      height: 1.4,
    );
    return Container(
      key: ValueKey('gramatica_punto_${punto.n}'),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: destacado ? context.acentoTint : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: destacado ? context.acento : AppTheme.border,
          width: destacado ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${punto.n}. ${punto.titulo.resolve(lang)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          if (punto.paraFamilias case final f?) ...[
            const SizedBox(height: 4),
            Text(f.resolve(lang), style: lectura),
          ] else if (punto.descricion case final d?) ...[
            const SizedBox(height: 4),
            Text(d.resolve(lang), style: lectura),
          ],
          if (onde.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${isGl ? 'Na ruta' : 'En la ruta'}: ${onde.map((o) => '${LeccionDaSemana.grupos[o.$1]?.resolve(lang) ?? o.$1}, ${(nomeDoMes[o.$2]?.resolve(lang) ?? '').toLowerCase()}').join(' · ')}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: context.acento,
                height: 1.35,
              ),
            ),
          ],
          if (punto.exemplo case final e?) ...[
            const SizedBox(height: 8),
            BotonEscuchar(
              audioService: audioService,
              texto: e.en,
              language: AppLanguage.en,
              interfaz: lang,
              style: estiloIngles(e.en),
              comoChip: true,
              colorChip: context.acento,
              descripcion: e.en,
              significado: e.significado,
            ),
          ],
        ],
      ),
    );
  }
}
