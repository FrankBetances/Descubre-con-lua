import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/progresion_model.dart';

/// Los diez meses del curso escolar, en el orden en que se dan.
const List<int> mesesDoCurso = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

const Map<int, LocalizedString> nomeDoMes = {
  9: LocalizedString(gl: 'Setembro', es: 'Septiembre'),
  10: LocalizedString(gl: 'Outubro', es: 'Octubre'),
  11: LocalizedString(gl: 'Novembro', es: 'Noviembre'),
  12: LocalizedString(gl: 'Decembro', es: 'Diciembre'),
  1: LocalizedString(gl: 'Xaneiro', es: 'Enero'),
  2: LocalizedString(gl: 'Febreiro', es: 'Febrero'),
  3: LocalizedString(gl: 'Marzo', es: 'Marzo'),
  4: LocalizedString(gl: 'Abril', es: 'Abril'),
  5: LocalizedString(gl: 'Maio', es: 'Mayo'),
  6: LocalizedString(gl: 'Xuño', es: 'Junio'),
};

/// El mes de curso que toca hoy. En julio y agosto no hay curso: septiembre.
int mesDeHoxe() {
  final m = DateTime.now().month;
  return mesesDoCurso.contains(m) ? m : 9;
}

/// Una opción del selector de edad: la etiqueta y lo que la hace distinta.
class OpcionDeIdade<T> {
  final T valor;
  final LocalizedString etiqueta;

  /// Lo que cambia entre un tramo y otro: la metodología TPR en el 2.º ciclo,
  /// el tipo de dinámica en el 1.º. No es adorno: es lo que dice que la sesión
  /// no es la misma con otro nombre.
  final LocalizedString matiz;

  const OpcionDeIdade({
    required this.valor,
    required this.etiqueta,
    required this.matiz,
  });
}

/// El selector de edad del aula. Mismo aspecto en los dos ciclos.
class SelectorDeIdade<T> extends StatelessWidget {
  final List<OpcionDeIdade<T>> opcions;
  final T seleccionado;
  final AppLanguage language;
  final ValueChanged<T> onCambiar;
  final String prefixoClave;

  const SelectorDeIdade({
    super.key,
    required this.opcions,
    required this.seleccionado,
    required this.language,
    required this.onCambiar,
    required this.prefixoClave,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final op in opcions)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppTheme.spaceSm),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  key: ValueKey('${prefixoClave}_${op.valor}'),
                  onTap: () => onCambiar(op.valor),
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  child: Container(
                    constraints:
                        const BoxConstraints(minHeight: AppTheme.touchMin),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spaceMd,
                      horizontal: AppTheme.spaceSm,
                    ),
                    decoration: BoxDecoration(
                      color: op.valor == seleccionado
                          ? AppTheme.primaryInk
                          : AppTheme.card,
                      borderRadius: BorderRadius.circular(AppTheme.radiusField),
                      border: Border.all(
                        color: op.valor == seleccionado
                            ? AppTheme.primaryInk
                            : AppTheme.border,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          op.etiqueta.resolve(language),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: op.valor == seleccionado
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          op.matiz.resolve(language),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: op.valor == seleccionado
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Los diez meses en una tira que se pasa DE LADO.
///
/// De lado y no hacia abajo: hacia abajo empuja la tarjeta del día fuera de la
/// pantalla, que es justo lo que había que quitar.
class TiraDeMeses extends StatelessWidget {
  final int mesSeleccionado;
  final AppLanguage language;
  final ValueChanged<int> onCambiar;
  final String prefixoClave;

  const TiraDeMeses({
    super.key,
    required this.mesSeleccionado,
    required this.language,
    required this.onCambiar,
    required this.prefixoClave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.touchMin,
      child: ListView.separated(
        key: Key('tira_meses_$prefixoClave'),
        scrollDirection: Axis.horizontal,
        itemCount: mesesDoCurso.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spaceSm),
        itemBuilder: (context, i) {
          final mes = mesesDoCurso[i];
          final activo = mes == mesSeleccionado;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('${prefixoClave}_mes_$mes'),
              onTap: () => onCambiar(mes),
              borderRadius: BorderRadius.circular(AppTheme.radiusField),
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                decoration: BoxDecoration(
                  color: activo ? AppTheme.primary : AppTheme.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(
                    color: activo ? AppTheme.primary : AppTheme.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  nomeDoMes[mes]!.resolve(language),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                    color: activo ? Colors.white : AppTheme.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// El rótulo de una sección del aula.
class RotuloSeccion extends StatelessWidget {
  final String texto;

  const RotuloSeccion(this.texto, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppTheme.textSecondary,
        letterSpacing: 1.2,
      ),
    );
  }
}

/// Una fila de fase dentro de la tarjeta de flujo del día.
class FilaDeFase extends StatelessWidget {
  final int orden;
  final String titulo;
  final int minutos;

  /// Cuando el hueco aprieta, el título de la fase baja a una línea. Sin
  /// scroll la alternativa sería desbordar, y un desbordamiento en release no
  /// enseña franjas: enseña texto cortado y nadie se entera.
  final bool compacto;

  const FilaDeFase({
    super.key,
    required this.orden,
    required this.titulo,
    required this.minutos,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: compacto ? 22 : 26,
          height: compacto ? 22 : 26,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$orden',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryInk,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceMd),
        Expanded(
          child: Text(
            titulo,
            maxLines: compacto ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: compacto ? 13.5 : 14.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Text(
          '$minutos min',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Las cuatro fases, o su resumen si no caben.
///
/// Sin scroll no vale «que se apañe»: o caben las cuatro filas enteras, o se
/// enseña una línea que dice cuántas fases y cuántos minutos. Lo que no puede
/// pasar es desbordar, porque en release un desbordamiento no enseña franjas
/// amarillas: enseña texto cortado y nadie se entera.
class BloqueDeFases extends StatelessWidget {
  final List<({int orden, String titulo, int minutos})> fases;
  final int minutosTotais;
  final bool isGl;

  const BloqueDeFases({
    super.key,
    required this.fases,
    required this.minutosTotais,
    required this.isGl,
  });

  /// Lo que mide una fila con una sola línea de texto, con holgura.
  static const double altoMinimoFila = 30.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final escala = MediaQuery.textScalerOf(context).scale(16.0) / 16.0;
      final minimo = altoMinimoFila * escala * fases.length;

      if (constraints.maxHeight >= minimo) {
        final compacto = constraints.maxHeight < minimo * 1.45;
        return Column(
          children: [
            for (final f in fases)
              Expanded(
                child: FilaDeFase(
                  orden: f.orden,
                  titulo: f.titulo,
                  minutos: f.minutos,
                  compacto: compacto,
                ),
              ),
          ],
        );
      }

      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          isGl
              ? '${fases.length} fases · $minutosTotais min'
              : '${fases.length} fases · $minutosTotais min',
          key: const ValueKey('resumo_de_fases'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textSecondary,
          ),
        ),
      );
    });
  }
}

/// La semana y el día: lo que hace que hoy no sea ayer.
///
/// Dos filas de pastillas: las cuatro semanas del mes y los cinco días
/// lectivos. Frank: «las asambleas deben ser distintas cada día; es posible
/// que mantengan una misma temática durante varios días, pero no puede ser la
/// misma un mes completo».
class TiraDeDias extends StatelessWidget {
  final ProgresionDoMes progresion;
  final int semana;
  final int dia;
  final AppLanguage language;
  final void Function(int semana, int dia) onCambiar;
  final String prefixoClave;

  const TiraDeDias({
    super.key,
    required this.progresion,
    required this.semana,
    required this.dia,
    required this.language,
    required this.onCambiar,
    required this.prefixoClave,
  });

  @override
  Widget build(BuildContext context) {
    final semanaActual = progresion.semana(semana);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (final s in progresion.semanas)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spaceSm),
                  child: _Pastilla(
                    clave: ValueKey('${prefixoClave}_semana_${s.numero}'),
                    activa: s.numero == semana,
                    onTap: () => onCambiar(s.numero, dia),
                    texto: '${s.numero}',
                    subtexto: s.nome.resolve(language),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        Row(
          children: [
            for (final d in progresion.dias.where((d) => d.semana == semana))
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppTheme.spaceSm),
                  child: _Pastilla(
                    clave: ValueKey('${prefixoClave}_dia_${d.dia}'),
                    activa: d.dia == dia,
                    onTap: () => onCambiar(semana, d.dia),
                    texto: d.nomeDia.resolve(language).substring(0, 2),
                    subtexto: null,
                  ),
                ),
              ),
          ],
        ),
        if (semanaActual != null) ...[
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            semanaActual.meta.resolve(language),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}

class _Pastilla extends StatelessWidget {
  final Key clave;
  final bool activa;
  final VoidCallback onTap;
  final String texto;
  final String? subtexto;

  const _Pastilla({
    required this.clave,
    required this.activa,
    required this.onTap,
    required this.texto,
    required this.subtexto,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: clave,
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: activa ? AppTheme.primary : AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusField),
            border: Border.all(
              color: activa ? AppTheme.primary : AppTheme.border,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                texto,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: activa ? Colors.white : AppTheme.textPrimary,
                ),
              ),
              if (subtexto != null)
                Text(
                  subtexto!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: activa
                        ? Colors.white.withValues(alpha: 0.9)
                        : AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Lo que se hace HOY, dentro de la tarjeta de flujo: el foco del día, la
/// consigna y las órdenes en inglés que tocan.
class BloqueDoDia extends StatelessWidget {
  final DiaDeProgresion dia;
  final SemanaDeProgresion? semana;
  final List<String> ordes;
  final AppLanguage language;

  const BloqueDoDia({
    super.key,
    required this.dia,
    required this.semana,
    required this.ordes,
    required this.language,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    return Container(
      key: const ValueKey('bloque_do_dia'),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${isGl ? 'HOXE' : 'HOY'} · ${isGl ? 'SEMANA' : 'SEMANA'} ${dia.semana}'
            '${semana != null ? ' · ${semana!.nome.resolve(language).toUpperCase()}' : ''}'
            ' · ${dia.nomeDia.resolve(language).toUpperCase()}',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryInk,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dia.foco.resolve(language),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dia.consigna.resolve(language),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.35,
            ),
          ),
          if (ordes.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final o in ordes)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Text(
                      o,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryInk,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
