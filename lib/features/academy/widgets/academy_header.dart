import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// La cabecera de Academy, portada del proyecto anterior de la casa
/// (`docs/screenshots/28-academy-capsulas.png` y `29-academy-lector.png`):
/// un bloque de color a sangre con las esquinas de abajo redondeadas,
/// antetítulo en versalitas espaciadas, título grande y, opcionalmente,
/// subtítulo o puntos de progreso.
///
/// Va sobre `primaryInk` y no sobre el turquesa de marca porque lleva texto
/// blanco: sobre el turquesa el blanco da 2,18:1 y esto se lee en un aula con
/// ventanales.
class AcademyHeader extends StatelessWidget {
  /// Versalitas de arriba. En el proyecto anterior de la casa es el bloque al que pertenece la cápsula.
  final String kicker;

  final String titulo;

  /// Una línea de qué es esto. Se omite en el lector, que usa `pasos`.
  final String? subtitulo;

  /// Cuántos pasos tiene el lector y en cuál va. Sin esto no se pintan puntos.
  final int? pasos;
  final int? pasoActual;

  const AcademyHeader({
    super.key,
    required this.kicker,
    required this.titulo,
    this.subtitulo,
    this.pasos,
    this.pasoActual,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spaceXl,
        AppTheme.spaceLg,
        AppTheme.spaceXl,
        AppTheme.spaceXl,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryInk,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(AppTheme.spaceXxl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kicker.toUpperCase(),
            style: text.bodySmall?.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            titulo,
            style: text.headlineSmall?.copyWith(color: Colors.white),
          ),
          if (subtitulo != null) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              subtitulo!,
              style: text.bodyMedium?.copyWith(color: Colors.white70),
            ),
          ],
          if (pasos != null && pasos! > 1) ...[
            const SizedBox(height: AppTheme.spaceLg),
            _Puntos(total: pasos!, actual: pasoActual ?? 0),
          ],
        ],
      ),
    );
  }
}

/// Puntos de progreso del lector. El activo es una barra, no un punto más
/// grande: la diferencia de forma se ve aunque la de tamaño se pierda con la
/// escala de texto del sistema.
class _Puntos extends StatelessWidget {
  final int total;
  final int actual;

  const _Puntos({required this.total, required this.actual});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Paso ${actual + 1} de $total',
      child: Row(
        children: List.generate(total, (i) {
          final activo = i == actual;
          return Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceSm),
            child: Container(
              width: activo ? 28 : 16,
              height: 6,
              decoration: BoxDecoration(
                color: activo ? Colors.white : Colors.white38,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Tarjeta blanca de la lista de Academy, portada de `28-academy-capsulas.png`:
/// baldosa de icono, antetítulo en versalitas, título, descripción, línea de
/// metadatos y galón a la derecha.
class AcademyCard extends StatelessWidget {
  final IconData icono;
  final String kicker;
  final String titulo;
  final String descripcion;

  /// «3 min de lectura · 15 XP» y similares. Opcional.
  final String? meta;

  final VoidCallback? onTap;

  /// Cuando no hay nada que abrir, la tarjeta se ve apagada y no responde.
  bool get habilitada => onTap != null;

  const AcademyCard({
    super.key,
    required this.icono,
    required this.kicker,
    required this.titulo,
    required this.descripcion,
    this.meta,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: habilitada,
      child: Material(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Iconografía de un set coherente, no emoji del sistema:
                // El proyecto anterior de la casa usa emoji aquí y cambian de fabricante a fabricante.
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: habilitada ? AppTheme.primaryLight : AppTheme.border,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  ),
                  child: Icon(
                    icono,
                    color:
                        habilitada ? AppTheme.primaryInk : AppTheme.textMuted,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spaceLg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kicker.toUpperCase(),
                        style: text.bodySmall?.copyWith(
                          color: habilitada
                              ? AppTheme.primaryDark
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        titulo,
                        style: text.titleSmall?.copyWith(
                          color: habilitada
                              ? AppTheme.textPrimary
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spaceXs),
                      Text(
                        descripcion,
                        style: text.bodySmall?.copyWith(
                          color: habilitada
                              ? AppTheme.textSecondary
                              : AppTheme.textMuted,
                        ),
                      ),
                      if (meta != null) ...[
                        const SizedBox(height: AppTheme.spaceSm),
                        Text(
                          meta!,
                          style: text.bodySmall?.copyWith(
                            color: AppTheme.textMuted,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (habilitada) ...[
                  const SizedBox(width: AppTheme.spaceSm),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.primaryInk,
                      size: 20,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
