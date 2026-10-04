import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Volver y avanzar en todo lo que va paso a paso: la formación, el cuento,
/// la cápsula, la asamblea, las frases del curso.
///
/// Volver es una flecha en un cuadrado con borde; avanzar, el botón principal
/// de la pantalla, a lo ancho. Antes cada pantalla tenía su pareja y varias
/// se rompían a 360 px: «Anterior» en un tercio de la fila salía «Anterio» o
/// «Anteri / or», y en una caja de 48 px la letra del botón se cortaba por
/// arriba. La flecha lleva su nombre para TalkBack.
class PasosNavegacion extends StatelessWidget {
  const PasosNavegacion({
    super.key,
    required this.anterior,
    required this.seguinte,
    required this.etiquetaAnterior,
    required this.etiquetaSeguinte,
    this.iconaSeguinte = Icons.arrow_forward_rounded,
    this.centro,
    this.chaveAnterior,
    this.chaveSeguinte,
  });

  /// `null` deja la flecha apagada: el primer paso no tiene anterior.
  final VoidCallback? anterior;
  final VoidCallback? seguinte;

  /// El nombre que oye TalkBack en la flecha: «Anterior», «Fase anterior».
  final String etiquetaAnterior;
  final String etiquetaSeguinte;
  final IconData iconaSeguinte;

  /// Lo que va entre los dos: el «2 / 5» de un cuento, por ejemplo.
  final Widget? centro;

  final Key? chaveAnterior;
  final Key? chaveSeguinte;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: etiquetaAnterior,
          child: SizedBox(
            width: 56,
            height: 56,
            child: OutlinedButton(
              key: chaveAnterior,
              onPressed: anterior,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(56, 56),
              ),
              child: Semantics(
                label: etiquetaAnterior,
                child: const Icon(Icons.arrow_back_rounded, size: 26),
              ),
            ),
          ),
        ),
        if (centro != null) ...[
          const SizedBox(width: AppTheme.spaceMd),
          centro!,
        ],
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: SizedBox(
            height: 56,
            child: ElevatedButton.icon(
              key: chaveSeguinte,
              onPressed: seguinte,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                minimumSize: const Size(0, 56),
              ),
              iconAlignment: IconAlignment.end,
              icon: Icon(iconaSeguinte, size: 22),
              label: Text(
                etiquetaSeguinte,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
