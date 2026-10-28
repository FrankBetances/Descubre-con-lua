import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/leccion_model.dart';

/// El camino de una unidad, como en duolingo-clone (github.com/sanidhyy/
/// duolingo-clone, MIT, `app/(main)/learn/unit.tsx`, `unit-banner.tsx` y
/// `lesson-button.tsx`): una franja con el título y la descripción de la
/// unidad, y sus lecciones en zigzag —ciclo de 8, 40 px por paso—, con la
/// marca de hecha, la estrella y el globo en la de esta semana, gris lo que
/// viene y la corona en la última.
class CaminoDaUnidade extends StatelessWidget {
  final UnidadeDeLeccions unidade;
  final int numero;
  final int de;

  /// La lección de esta semana; `null` si la unidad no es la de ahora.
  final String? actual;

  /// Las lecciones ya pasadas en el curso.
  final bool Function(Leccion) feita;

  /// La lección abierta abajo, resaltada.
  final String? elixida;
  final ValueChanged<Leccion> onTap;
  final AppLanguage language;

  /// Cuánto va de la semana actual, de 0 a 1 (el anillo de duolingo-clone).
  final double progreso;

  const CaminoDaUnidade({
    this.progreso = 0,
    super.key,
    required this.unidade,
    required this.numero,
    required this.de,
    required this.actual,
    required this.feita,
    required this.onTap,
    required this.language,
    this.elixida,
  });

  /// El desplazamiento de duolingo-clone: 0, 1, 2, 1, 0, -1, -2, -1.
  static double sangria(int i) {
    final c = i % 8;
    final n = c <= 2
        ? c
        : c <= 6
            ? 4 - c
            : c - 8;
    return n * 40.0;
  }

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final acento = context.acento;
    return Column(
      key: ValueKey('camino_${unidade.id}'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // La franja de la unidad.
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: acento,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isGl ? 'Tema' : 'Tema'} $numero ${isGl ? 'de' : 'de'} $de',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                unidade.titulo.resolve(language),
                style: const TextStyle(
                  fontSize: 16.5,
                  color: Colors.white,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        // Las lecciones, en zigzag.
        for (final (i, l) in unidade.leccions.indexed)
          Padding(
            padding: EdgeInsets.only(top: i == 0 && l.id == actual ? 44 : 18),
            child: Transform.translate(
              offset: Offset(-sangria(i), 0),
              child: Center(
                child: _Nodo(
                  leccion: l,
                  actual: l.id == actual,
                  feita: feita(l),
                  ultima: i == unidade.leccions.length - 1,
                  elixida: l.id == elixida,
                  onTap: () => onTap(l),
                  language: language,
                  progreso: progreso,
                ),
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Nodo extends StatelessWidget {
  final Leccion leccion;
  final bool actual;
  final bool feita;
  final bool ultima;
  final bool elixida;
  final VoidCallback onTap;
  final AppLanguage language;
  final double progreso;

  const _Nodo({
    required this.progreso,
    required this.leccion,
    required this.actual,
    required this.feita,
    required this.ultima,
    required this.elixida,
    required this.onTap,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final acento = context.acento;
    final bloqueada = !actual && !feita;
    final cor = bloqueada ? const Color(0xFFE5E7EB) : acento;
    // El canto de abajo, más oscuro: el botón «en 3D» de duolingo-clone.
    final canto = bloqueada
        ? const Color(0xFFC4C8CF)
        : Color.lerp(acento, Colors.black, 0.25)!;
    final icona = feita
        ? Icons.check_rounded
        : ultima
            ? Icons.emoji_events_rounded
            : Icons.star_rounded;
    final boton = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: cor,
          shape: BoxShape.circle,
          border: Border(bottom: BorderSide(color: canto, width: 8)),
          boxShadow: elixida
              ? [
                  BoxShadow(
                      color: acento.withAlpha(90),
                      blurRadius: 0,
                      spreadRadius: 5)
                ]
              : null,
        ),
        child: Icon(
          icona,
          size: 38,
          color: bloqueada ? const Color(0xFF9CA3AF) : Colors.white,
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: elixida,
      excludeSemantics: true,
      label:
          '${leccion.repaso ? 'Repaso' : 'Lección'} ${leccion.numero}${actual ? (language == AppLanguage.gl ? ', esta semana' : ', esta semana') : ''}',
      child: SizedBox(
        key: ValueKey('leccion_punto_${leccion.numero}'),
        width: 102,
        height: actual ? 102 : 78,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (actual)
              SizedBox(
                width: 96,
                height: 96,
                child: CircularProgressIndicator(
                  value: progreso,
                  strokeWidth: 6,
                  color: acento,
                  backgroundColor: const Color(0xFFE5E7EB),
                ),
              ),
            boton,
            if (actual)
              Positioned(
                top: -34,
                child: Container(
                  key: const Key('leccion_globo'),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border, width: 2),
                  ),
                  child: Text(
                    language == AppLanguage.gl ? 'ESTA SEMANA' : 'ESTA SEMANA',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: acento,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
