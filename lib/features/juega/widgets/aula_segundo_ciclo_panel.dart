import 'package:flutter/material.dart';

import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import 'aula_ciclo_panel.dart';

/// El aula de 2.º ciclo: se elige la CLASE y el MES, y sale UNA tarjeta.
///
/// Lo que había antes volcaba las 30 asambleas del curso en una lista vertical,
/// bajo un encabezado que decía «SETEMBRO» mientras la primera tarjeta era de
/// enero. La docente no tenía forma de decir qué clase da ni qué mes quiere: el
/// botón de empezar abría siempre septiembre de 4.º.
///
/// El documento curricular lo pide así y con estas palabras: «una única tarjeta
/// de flujo diario que compendia la estructura de la microcápsula sin requerir
/// navegación por capas ni deslizamientos profundos (no scroll)». Por eso aquí
/// no hay ningún desplazable vertical: la clase son tres pastillas, el mes se
/// pasa de lado, y debajo va una sola tarjeta con las cuatro fases.
///
/// La clase elegida NO se guarda en el aparato. Guardarla sería un campo nuevo
/// que declarar en Play Console, y para lo que vale —dos toques al abrir— no
/// compensa tocar la política de privacidad.
class AulaSegundoCicloPanel extends StatefulWidget {
  /// Las 30 asambleas del curso: 10 meses x 3 niveles.
  final List<AsambleaSegundoCiclo> asambleas;

  final AppLanguage language;

  /// La tira de Lúa. Es la mascota y el núcleo del proyecto: se quitó por error
  /// al rehacer el aula y vuelve aquí, arriba del todo.
  final Widget? cabeceira;

  /// El calendario del curso. Volvió por el mismo motivo: un aula sin el mes a
  /// la vista obliga a salir de la pantalla para saber por dónde va el curso.
  final Widget? calendario;

  /// Las fichas de contenido que van debajo de la tarjeta del día.
  final Widget? pe;

  /// Abre el Modo Asamblea por la clase y el mes que la docente eligió aquí.
  final void Function(NivelEducativoSegundoCiclo nivel, int mes) onComezar;

  const AulaSegundoCicloPanel({
    super.key,
    required this.asambleas,
    required this.language,
    required this.onComezar,
    this.cabeceira,
    this.calendario,
    this.pe,
  });

  @override
  State<AulaSegundoCicloPanel> createState() => _AulaSegundoCicloPanelState();
}

class _AulaSegundoCicloPanelState extends State<AulaSegundoCicloPanel> {
  /// El curso escolar en el orden en que se da, no en el del calendario.
  static const List<int> _mesesDoCurso = [9, 10, 11, 12, 1, 2, 3, 4, 5, 6];

  static const Map<int, LocalizedString> _nomeMes = {
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

  late NivelEducativoSegundoCiclo _nivel;
  late int _mes;

  @override
  void initState() {
    super.initState();
    _nivel = NivelEducativoSegundoCiclo.infantil4;
    _mes = _mesDeHoxe();
  }

  /// Abre por el mes de curso que toca hoy. En julio y agosto no hay curso: se
  /// entra por septiembre, que es por donde se empieza.
  int _mesDeHoxe() {
    final m = DateTime.now().month;
    return _mesesDoCurso.contains(m) ? m : 9;
  }

  AsambleaSegundoCiclo? get _asambleaActual {
    for (final a in widget.asambleas) {
      if (a.nivel == _nivel && a.mes == _mes) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final asamblea = _asambleaActual;

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.only(bottom: AppTheme.spaceXxl),
        children: [
          if (widget.cabeceira != null) widget.cabeceira!,
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spaceLg,
              AppTheme.spaceMd,
              AppTheme.spaceLg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RotuloSeccion(texto: isGl ? 'A MIÑA CLASE' : 'MI CLASE'),
                const SizedBox(height: AppTheme.spaceSm),
                _SelectorDeClase(
                  nivelSeleccionado: _nivel,
                  language: lang,
                  onCambiar: (n) => setState(() => _nivel = n),
                ),
                const SizedBox(height: AppTheme.spaceLg),
                _RotuloSeccion(
                  texto: isGl ? 'MES DO CURSO' : 'MES DEL CURSO',
                ),
                const SizedBox(height: AppTheme.spaceSm),
              ],
            ),
          ),
          _SelectorDeMes(
            meses: _mesesDoCurso,
            mesSeleccionado: _mes,
            nomes: _nomeMes,
            language: lang,
            onCambiar: (m) => setState(() => _mes = m),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
            child: asamblea == null
                ? _SenContido(isGl: isGl)
                : _TarxetaDeFluxo(
                    asamblea: asamblea,
                    nomeMes: _nomeMes[_mes]!,
                    language: lang,
                    onComezar: () => widget.onComezar(_nivel, _mes),
                  ),
          ),
          if (widget.calendario != null) widget.calendario!,
          if (widget.pe != null) widget.pe!,
        ],
      ),
    );
  }
}

class _RotuloSeccion extends StatelessWidget {
  final String texto;

  const _RotuloSeccion({required this.texto});

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

/// Las tres clases del 2.º ciclo. Debajo de cada una, la metodología TPR que le
/// corresponde: no es decoración, es lo que hace que la docencia sea escalonada
/// y no la misma sesión repetida tres veces.
class _SelectorDeClase extends StatelessWidget {
  final NivelEducativoSegundoCiclo nivelSeleccionado;
  final AppLanguage language;
  final ValueChanged<NivelEducativoSegundoCiclo> onCambiar;

  const _SelectorDeClase({
    required this.nivelSeleccionado,
    required this.language,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    const niveis = NivelEducativoSegundoCiclo.values;

    return Row(
      children: niveis.map((nivel) {
        final activo = nivel == nivelSeleccionado;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceSm),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                key: ValueKey('clase_2c_${nivel.clave}'),
                onTap: () => onCambiar(nivel),
                borderRadius: BorderRadius.circular(AppTheme.radiusField),
                child: Container(
                  constraints:
                      const BoxConstraints(minHeight: AppTheme.touchMin),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spaceMd,
                    horizontal: AppTheme.spaceSm,
                  ),
                  decoration: BoxDecoration(
                    color: activo ? AppTheme.primaryInk : AppTheme.card,
                    borderRadius: BorderRadius.circular(AppTheme.radiusField),
                    border: Border.all(
                      color: activo ? AppTheme.primaryInk : AppTheme.border,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        nivel.etiquetaCorta.resolve(language),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: activo ? Colors.white : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        nivel.metodologiaPorDefecto.nombreCorto
                            .resolve(language),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: activo
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
        );
      }).toList(),
    );
  }
}

/// Los diez meses del curso, en una tira que se pasa DE LADO.
///
/// De lado y no hacia abajo a propósito: hacia abajo empuja la tarjeta del día
/// fuera de la pantalla, que es justo lo que Frank mandó quitar.
class _SelectorDeMes extends StatelessWidget {
  final List<int> meses;
  final int mesSeleccionado;
  final Map<int, LocalizedString> nomes;
  final AppLanguage language;
  final ValueChanged<int> onCambiar;

  const _SelectorDeMes({
    required this.meses,
    required this.mesSeleccionado,
    required this.nomes,
    required this.language,
    required this.onCambiar,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppTheme.touchMin,
      child: ListView.separated(
        key: const Key('tira_meses_2c'),
        scrollDirection: Axis.horizontal,
        itemCount: meses.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppTheme.spaceSm),
        itemBuilder: (context, i) {
          final mes = meses[i];
          final activo = mes == mesSeleccionado;
          return Material(
            color: Colors.transparent,
            child: InkWell(
              key: ValueKey('mes_2c_$mes'),
              onTap: () => onCambiar(mes),
              borderRadius: BorderRadius.circular(AppTheme.radiusField),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spaceLg,
                ),
                decoration: BoxDecoration(
                  color: activo ? AppTheme.primary : AppTheme.card,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(
                    color: activo ? AppTheme.primary : AppTheme.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  nomes[mes]!.resolve(language),
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

/// La tarjeta única del día: qué se trabaja, y las cuatro fases con sus
/// minutos. Es lo que la docente mira de un vistazo antes de empezar.
class _TarxetaDeFluxo extends StatelessWidget {
  final AsambleaSegundoCiclo asamblea;
  final LocalizedString nomeMes;
  final AppLanguage language;
  final VoidCallback onComezar;

  const _TarxetaDeFluxo({
    required this.asamblea,
    required this.nomeMes,
    required this.language,
    required this.onComezar,
  });

  String get _lamina {
    for (final f in asamblea.fases) {
      if (f.lamina.isNotEmpty && f.lamina != 'gato') return f.lamina;
    }
    return 'gato';
  }

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;

    return Container(
      key: const ValueKey('tarxeta_fluxo_2c'),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderActive, width: 1.5),
        boxShadow: AppTheme.shadowCard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            color: AppTheme.primaryTint,
            alignment: Alignment.center,
            child: LaminaEscena(clave: _lamina, ancho: 96),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${nomeMes.resolve(language)} · ${asamblea.nivel.etiquetaCorta.resolve(language)}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryInk,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceXs),
                Text(
                  asamblea.centroInteres.resolve(language),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                for (final fase in asamblea.fases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                    child: FilaDeFase(
                      orden: fase.orden,
                      titulo: fase.titulo.resolve(language),
                      minutos: (fase.duracionSegundos / 60).round(),
                    ),
                  ),
                const SizedBox(height: AppTheme.spaceSm),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    key: const ValueKey('comezar_asemblea_2c'),
                    onPressed: onComezar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryInk,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusButton),
                      ),
                    ),
                    icon: const Icon(Icons.play_circle_filled_rounded),
                    label: Text(
                      isGl ? 'Comezar a asemblea' : 'Comenzar la asamblea',
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SenContido extends StatelessWidget {
  final bool isGl;

  const _SenContido({required this.isGl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        isGl
            ? 'Non hai asemblea para esta clase neste mes.'
            : 'No hay asamblea para esta clase en este mes.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 15,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }
}
