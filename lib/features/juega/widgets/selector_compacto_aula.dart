import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';

/// El grupo, el mes y el día del aula en una sola línea:
/// «0-2 anos · outubro · semana 1 · venres ▾».
///
/// Antes eran tres filas de filtros —grupo, mes, semana y día— que ocupaban
/// la primera pantalla entera, aunque ya vinieran puestas en hoy, y «Comezar
/// a asemblea» quedaba casi dos pantallas más abajo. Ahora se ve lo elegido y
/// los filtros se abren solo si hace falta cambiar algo.
class SelectorCompactoDoAula extends StatelessWidget {
  const SelectorCompactoDoAula({
    super.key,
    required this.prefixoClave,
    required this.resumo,
    required this.aberto,
    required this.onAlternar,
    required this.language,
    required this.selectores,
  });

  /// `1c` o `2c`: da la clave del botón, `selector_compacto_1c`.
  final String prefixoClave;

  /// Lo elegido, en una línea.
  final String resumo;
  final bool aberto;
  final VoidCallback onAlternar;
  final AppLanguage language;

  /// Los filtros de siempre, que se pintan solo con el selector abierto.
  final Widget selectores;

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
          child: Semantics(
            button: true,
            expanded: aberto,
            label: isGl ? 'Grupo e día: $resumo' : 'Grupo y día: $resumo',
            // Excluir a los hijos quita también la acción del InkWell.
            onTap: onAlternar,
            excludeSemantics: true,
            child: Material(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                side: BorderSide(
                  color:
                      aberto ? context.acento : context.acento.withAlpha(110),
                  width: 1.5,
                ),
              ),
              child: InkWell(
                key: ValueKey('selector_compacto_$prefixoClave'),
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                onTap: onAlternar,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 52),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 8, 10, 8),
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 20, color: context.acento),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            resumo,
                            key: ValueKey('resumo_aula_$prefixoClave'),
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                              height: 1.25,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          aberto
                              ? (isGl ? 'Feito' : 'Hecho')
                              : (isGl ? 'Cambiar' : 'Cambiar'),
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: context.acento,
                          ),
                        ),
                        Icon(
                          aberto
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          size: 22,
                          color: context.acento,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: aberto ? selectores : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
