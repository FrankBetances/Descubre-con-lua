import 'package:flutter/material.dart';

import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/unidad_model.dart';

/// Las unidades temáticas, en fichas que se pasan DE LADO.
///
/// Estuvieron a punto de perderse: al rehacer el aula quedaron sin ninguna
/// puerta que llevara a ellas. Diez unidades de contenido —cuento, vocabulario,
/// exploración sensorial, matemáticas tempranas y puente a casa— vivas en el
/// repositorio y muertas en la app. Esto las devuelve.
///
/// De lado y no en lista vertical porque es lo que Frank pidió: fichas o
/// carrusel horizontal, con su lámina a la vista, que es lo que hace que una
/// ficha se reconozca de un vistazo.
class FichasDeUnidades extends StatelessWidget {
  final List<Unidad> unidades;
  final AppLanguage language;
  final ValueChanged<Unidad> onAbrir;

  const FichasDeUnidades({
    super.key,
    required this.unidades,
    required this.language,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    if (unidades.isEmpty) return const SizedBox.shrink();
    final isGl = language == AppLanguage.gl;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLg,
            AppTheme.spaceLg,
            AppTheme.spaceLg,
            AppTheme.spaceSm,
          ),
          child: Row(
            children: [
              const Icon(Icons.auto_stories_outlined,
                  size: 18, color: AppTheme.primaryInk),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGl
                      ? 'UNIDADES TEMÁTICAS DE VIGO'
                      : 'UNIDADES TEMÁTICAS DE VIGO',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 208,
          child: ListView.separated(
            key: const Key('fichas_unidades'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            itemCount: unidades.length,
            separatorBuilder: (_, __) =>
                const SizedBox(width: AppTheme.spaceMd),
            itemBuilder: (context, i) => _Ficha(
              unidad: unidades[i],
              language: language,
              onAbrir: () => onAbrir(unidades[i]),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spaceLg,
            AppTheme.spaceSm,
            AppTheme.spaceLg,
            0,
          ),
          child: Text(
            isGl
                ? 'Desliza para ver máis unidades'
                : 'Desliza para ver más unidades',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: AppTheme.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _Ficha extends StatelessWidget {
  final Unidad unidad;
  final AppLanguage language;
  final VoidCallback onAbrir;

  const _Ficha({
    required this.unidad,
    required this.language,
    required this.onAbrir,
  });

  /// La lámina de la unidad: la del primer objeto de su vocabulario, que es lo
  /// que la unidad trabaja. Si no hay, la gata.
  String get _clave {
    for (final v in unidad.vocabulario) {
      if (v.lamina.isNotEmpty) return v.lamina;
    }
    return 'gato';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 178,
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          key: ValueKey('ficha_unidade_${unidad.id}'),
          onTap: onAbrir,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.border, width: 1.5),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // La lámina, arriba y grande: es lo que hace que la ficha se
                // reconozca sin leerla.
                Container(
                  height: 96,
                  width: double.infinity,
                  color: AppTheme.primaryTint,
                  alignment: Alignment.center,
                  child: LaminaEscena(
                    clave: _clave,
                    ancho: 72,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.spaceMd),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          unidad.titulo.resolve(language),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14.5,
                            height: 1.2,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Text(
                            unidad.subtitulo.resolve(language),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            language == AppLanguage.gl
                                ? 'Tramo ${unidad.tramoEtario} anos'
                                : 'Tramo ${unidad.tramoEtario} años',
                            style: const TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
