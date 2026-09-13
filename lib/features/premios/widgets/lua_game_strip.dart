import 'package:flutter/material.dart';

import '../../../core/brand/lua_pixel.dart';
import '../../../core/brand/pixel_award.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/calendario_model.dart';
import '../premios_model.dart';
import '../premios_repository.dart';
import '../premios_screen.dart';

/// La tira de juego: Lúa, el nivel con su barra, la racha con su metal y la
/// puerta a los premios. Portada de `ValeriaGameStrip.tsx`.
///
/// Existe porque los premios estaban escondidos detrás de un botón del hub:
/// se ganaban insignias que nadie veía. Una gamificación que no se ve no es
/// gamificación, es un fichero JSON.
///
/// Va en la lista de unidades (la maestra), en la lista de bloques (la familia)
/// y dentro de la asamblea y del lector. Es la misma pieza en los cuatro
/// sitios: si el nivel saliera distinto en dos pantallas, el número dejaría de
/// significar nada.
class LuaGameStrip extends StatelessWidget {
  final PremiosRepository repository;
  final Perfil perfil;
  final AppLanguage language;

  /// Compacta: sin la línea de «faltan N XP». Para meterla dentro de una
  /// pantalla que ya va llena, como la asamblea.
  final bool compacta;

  /// Las cuentas del calendario, para que la pantalla de premios que se abre
  /// desde aquí pueda pintar también las medallas.
  final ContadoresCalendario? contadores;

  const LuaGameStrip({
    super.key,
    required this.repository,
    required this.perfil,
    required this.language,
    this.compacta = false,
    this.contadores,
  });

  static const _faltan = LocalizedString(
    gl: 'XP para o seguinte nivel',
    es: 'XP para el siguiente nivel',
  );
  static const _maximo = LocalizedString(
    gl: 'Último nivel',
    es: 'Último nivel',
  );
  static const _verPremios = LocalizedString(
    gl: 'Ver premios',
    es: 'Ver premios',
  );
  static const _dias = LocalizedString(gl: 'días', es: 'días');
  static const _nivel = LocalizedString(gl: 'Nivel', es: 'Nivel');

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final catalogo = repository.catalogo;
        // Sin catálogo no hay tira. No se pinta un hueco ni un esqueleto: la
        // asamblea funciona igual sin premios y una caja vacía solo confunde.
        if (catalogo == null) return const SizedBox.shrink();

        final progreso = repository.progresoDe(perfil);
        final nivel = progreso.nivelActual(catalogo);
        final siguiente = progreso.siguienteNivel(catalogo);
        final racha = progreso.rachaActual;
        final text = Theme.of(context).textTheme;

        return Semantics(
          button: true,
          label: '${_verPremios.resolve(language)}. '
              '${_nivel.resolve(language)} ${nivel.nivel}, '
              '$racha ${_dias.resolve(language)}',
          child: Material(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppTheme.radiusCard),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PremiosScreen(
                    repository: repository,
                    currentLanguage: language,
                    perfilInicial: perfil,
                    contadores: contadores,
                  ),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spaceMd),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // La gata. Frank la quiere en las pantallas de aula y de
                    // Academy, no solo en la bienvenida.
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusField),
                      ),
                      alignment: Alignment.center,
                      child: const LuaPixel(pose: LuaPose.head, size: 46),
                    ),
                    const SizedBox(width: AppTheme.spaceMd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              // El pescado: el metal sube con el nivel, así
                              // que el nivel se ve sin leer el número.
                              PixelAward(
                                glyph: nivel.glifo,
                                tier: nivel.rango,
                                size: 22,
                              ),
                              const SizedBox(width: AppTheme.spaceXs),
                              Expanded(
                                child: Text(
                                  '${_nivel.resolve(language)} ${nivel.nivel} · '
                                  '${nivel.titulo.resolve(language)}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.titleSmall,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spaceXs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: siguiente == null
                                  ? 1.0
                                  : progreso.avanceDeNivel(catalogo),
                              minHeight: 8,
                              backgroundColor: AppTheme.border,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                AppTheme.primary,
                              ),
                            ),
                          ),
                          if (!compacta) ...[
                            const SizedBox(height: AppTheme.spaceXs),
                            Text(
                              siguiente == null
                                  ? _maximo.resolve(language)
                                  : '${progreso.xpParaSiguiente(catalogo)} '
                                      '${_faltan.resolve(language)}',
                              maxLines: 2,
                              style: text.bodySmall?.copyWith(
                                // Secundario y no «muted»: es justo la línea
                                // que dice cuánto falta.
                                color: AppTheme.textSecondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PixelAward(
                              glyph: AwardGlyph.flame,
                              tier: tierDeRacha(racha),
                              size: 24,
                              locked: racha == 0,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '$racha',
                              style: text.titleSmall?.copyWith(
                                color: AppTheme.primaryDark,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: AppTheme.primaryInk,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
