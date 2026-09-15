import 'package:flutter/material.dart';

import '../../core/brand/pixel_award.dart';
import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/calendario_model.dart';
import 'premios_model.dart';

/// Las medallas del Calendario Escola·Fogar.
///
/// Son lo mismo que las insignias y se dibujan con el mismo set propio
/// ([PixelAward]): un glifo dice QUÉ se hizo —casa, amanecer, corazón— y el
/// metal CUÁNTO. No hay un segundo juego de dibujos para esto; si hubiera dos
/// sets, la colección dejaría de leerse de un vistazo.
///
/// El catálogo entero está en `assets/content/premios/premios.json`, nunca
/// escrito aquí, y cada medalla se DERIVA de los contadores del calendario: no
/// se guarda ninguna medalla en disco, así que esto no añade ni un dato nuevo a
/// lo que la app almacena.
class MedallasCalendario extends StatelessWidget {
  final List<Medalla> medallas;
  final ContadoresCalendario contadores;
  final AppLanguage lang;

  /// Título de la sección. Si es `null` no se pinta cabecera: en el calendario
  /// la sección ya va bajo su propio rótulo.
  final String? titulo;

  const MedallasCalendario({
    super.key,
    required this.medallas,
    required this.contadores,
    required this.lang,
    this.titulo,
  });

  static const vacio = LocalizedString(
    gl: 'Aínda non hai ningunha medalla. Rexístrase soa ao dirixir a asemblea '
        'ou ao marcar o xogo da casa no calendario.',
    es: 'Todavía no hay ninguna medalla. Se registra sola al dirigir la '
        'asamblea o al marcar el juego de casa en el calendario.',
  );

  @override
  Widget build(BuildContext context) {
    if (medallas.isEmpty) return const SizedBox.shrink();
    final text = Theme.of(context).textTheme;
    final ganadas = medallas.where((m) => m.ganadaCon(contadores)).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (titulo != null) ...[
          Text('$titulo · $ganadas / ${medallas.length}',
              style: text.titleSmall),
          const SizedBox(height: AppTheme.spaceMd),
        ],
        if (ganadas == 0)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            child: Text(
              vacio.resolve(lang),
              style: text.bodySmall?.copyWith(color: AppTheme.textMuted),
            ),
          ),
        ...medallas.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spaceMd),
            child: TarjetaMedalla(
              medalla: m,
              contadores: contadores,
              lang: lang,
            ),
          ),
        ),
      ],
    );
  }
}

/// Una medalla, con lo que lleva hecho de lo que pide.
class TarjetaMedalla extends StatelessWidget {
  final Medalla medalla;
  final ContadoresCalendario contadores;
  final AppLanguage lang;

  const TarjetaMedalla({
    super.key,
    required this.medalla,
    required this.contadores,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final avance = medalla.avanceCon(contadores);
    final ganada = medalla.ganadaCon(contadores);
    // El avance se recorta al objetivo: «12 / 10» leería como un error.
    final hechos = avance > medalla.valor ? medalla.valor : avance;

    return Semantics(
      label: ganada ? 'Medalla gañada' : 'Medalla pendente',
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: ganada ? AppTheme.primaryTint : AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(
            color: ganada ? AppTheme.borderActive : AppTheme.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PixelAward(
              glyph: medalla.glifo,
              tier: medalla.rango,
              size: 52,
              locked: !ganada,
            ),
            const SizedBox(width: AppTheme.spaceLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medalla.titulo.resolve(lang),
                    style: text.titleSmall?.copyWith(
                      color: ganada ? AppTheme.textPrimary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceXs),
                  Text(
                    medalla.descripcion.resolve(lang),
                    style: text.bodySmall?.copyWith(
                      color:
                          ganada ? AppTheme.textSecondary : AppTheme.textMuted,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceSm),
                  Text(
                    '$hechos / ${medalla.valor}',
                    style: text.labelSmall?.copyWith(
                      color: ganada ? AppTheme.primaryInk : AppTheme.textMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
