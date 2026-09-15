import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/asamblea_primeiro_ciclo_model.dart';
import 'aula_ciclo_panel.dart';

/// El aula de 1.º ciclo (0-3): se elige el TRAMO y el MES, y sale UNA tarjeta.
///
/// La misma forma que el 2.º ciclo, a propósito: la docente que cambia de aula
/// no tiene que aprender dos interfaces. Y el mismo principio del documento
/// curricular: una sola tarjeta de flujo, sin desplazamiento vertical.
///
/// El escalonamiento aquí no es por nivel sino por tramo: el documento da, para
/// cada mes, una dinámica para lactantes de 0 a 2 y otra distinta para el aula
/// de 2 a 3. Cambian el material, la canción y las órdenes.
class AulaPrimeiroCicloPanel extends StatefulWidget {
  final List<AsambleaPrimeiroCiclo> asambleas;
  final AppLanguage language;
  final void Function(TramoPrimeiroCiclo tramo, int mes) onComezar;

  const AulaPrimeiroCicloPanel({
    super.key,
    required this.asambleas,
    required this.language,
    required this.onComezar,
  });

  @override
  State<AulaPrimeiroCicloPanel> createState() => _AulaPrimeiroCicloPanelState();
}

class _AulaPrimeiroCicloPanelState extends State<AulaPrimeiroCicloPanel> {
  late TramoPrimeiroCiclo _tramo;
  late int _mes;

  @override
  void initState() {
    super.initState();
    _tramo = TramoPrimeiroCiclo.lactantes0a2;
    _mes = mesDeHoxe();
  }

  AsambleaPrimeiroCiclo? get _actual {
    for (final a in widget.asambleas) {
      if (a.tramo == _tramo && a.mes == _mes) return a;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final asamblea = _actual;

    // Sin scroll, el marco no puede comerse la tarjeta. En pantallas cortas o
    // con la escala de texto grande del sistema, los dos rótulos de sección y
    // los huecos generosos dejaban a la tarjeta del día unos cien píxeles: se
    // recortan ellos, que son etiqueta, y no la tarjeta, que es el trabajo.
    final escala = MediaQuery.textScalerOf(context).scale(16.0) / 16.0;
    final alto = MediaQuery.sizeOf(context).height;
    final apretado = alto < 720 || escala > 1.15;
    final hueco = apretado ? AppTheme.spaceXs : AppTheme.spaceLg;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppTheme.spaceLg,
          apretado ? AppTheme.spaceXs : AppTheme.spaceMd,
          AppTheme.spaceLg,
          apretado ? AppTheme.spaceXs : AppTheme.spaceLg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RotuloSeccion(isGl ? 'O MEU GRUPO' : 'MI GRUPO'),
            const SizedBox(height: AppTheme.spaceSm),
            SelectorDeIdade<TramoPrimeiroCiclo>(
              prefixoClave: 'tramo_1c',
              seleccionado: _tramo,
              language: lang,
              onCambiar: (t) => setState(() => _tramo = t),
              opcions: [
                for (final t in TramoPrimeiroCiclo.values)
                  OpcionDeIdade<TramoPrimeiroCiclo>(
                    valor: t,
                    etiqueta: t.etiquetaCorta,
                    matiz: t.descricionCurta,
                  ),
              ],
            ),
            SizedBox(height: hueco),
            RotuloSeccion(isGl ? 'MES DO CURSO' : 'MES DEL CURSO'),
            const SizedBox(height: AppTheme.spaceSm),
            TiraDeMeses(
              prefixoClave: '1c',
              mesSeleccionado: _mes,
              language: lang,
              onCambiar: (m) => setState(() => _mes = m),
            ),
            SizedBox(height: hueco),
            Expanded(
              child: asamblea == null
                  ? Center(
                      child: Text(
                        isGl
                            ? 'Non hai microcápsula para este grupo neste mes.'
                            : 'No hay microcápsula para este grupo en este mes.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  : _TarxetaDeFluxo(
                      asamblea: asamblea,
                      language: lang,
                      onComezar: () => widget.onComezar(_tramo, _mes),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TarxetaDeFluxo extends StatelessWidget {
  final AsambleaPrimeiroCiclo asamblea;
  final AppLanguage language;
  final VoidCallback onComezar;

  const _TarxetaDeFluxo({
    required this.asamblea,
    required this.language,
    required this.onComezar,
  });

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;

    // Sin scroll hay que caber de verdad. En 360x640, y más con la escala de
    // texto grande del sistema, al hueco de la tarjeta le sobran doscientos
    // píxeles de contenido: entonces se recorta lo accesorio —el material y la
    // canción, que la docente ya tiene en la mano— y se queda lo que no puede
    // faltar: qué se trabaja, las cuatro fases y el botón.
    return LayoutBuilder(builder: (context, constraints) {
      // El umbral no es un número mágico: con la escala de texto grande del
      // sistema la versión holgada necesita cerca de 400 px, así que por
      // debajo de eso —o en cuanto el sistema agranda el texto— se pasa a la
      // compacta. Sin scroll, quedarse corto no desborda: recorta.
      final escala = MediaQuery.textScalerOf(context).scale(16.0) / 16.0;
      final compacto = constraints.maxHeight < 420 || escala > 1.15;
      return Container(
        key: const ValueKey('tarxeta_fluxo_1c'),
        padding: EdgeInsets.all(
            compacto ? AppTheme.spaceMd : AppTheme.spaceLg),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          border: Border.all(color: AppTheme.border, width: 1.5),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${nomeDoMes[asamblea.mes]!.resolve(language)} · ${asamblea.tramo.etiquetaCorta.resolve(language)}',
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
            maxLines: compacto ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: compacto ? 16 : 19,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.2,
            ),
          ),
          // El material del mes y la canción: las dos cosas que la educadora
          // tiene que tener en la mano antes de sentarse en la alfombra.
          if (!compacto) ...[
            const SizedBox(height: AppTheme.spaceSm),
            _LinaDeApoio(
              icona: Icons.pan_tool_outlined,
              texto: asamblea.materialDoMes.resolve(language),
            ),
            if (asamblea.cancionDoMes.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceXs),
              _LinaDeApoio(
                icona: Icons.music_note_outlined,
                texto: asamblea.cancionDoMes,
              ),
            ],
          ],
          SizedBox(height: compacto ? AppTheme.spaceSm : AppTheme.spaceMd),
          Expanded(
            child: BloqueDeFases(
              isGl: isGl,
              minutosTotais: asamblea.duracionTotalMinutos,
              fases: [
                for (final fase in asamblea.fases)
                  (
                    orden: fase.orden,
                    titulo: fase.titulo.resolve(language),
                    minutos: (fase.duracionSegundos / 60).round(),
                  ),
              ],
            ),
          ),
          SizedBox(height: compacto ? AppTheme.spaceSm : AppTheme.spaceMd),
          SizedBox(
            height: compacto ? AppTheme.touchMin : 52,
            child: ElevatedButton.icon(
              key: const ValueKey('comezar_asemblea_1c'),
              onPressed: onComezar,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryInk,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
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
      );
    });
  }
}

class _LinaDeApoio extends StatelessWidget {
  final IconData icona;
  final String texto;

  const _LinaDeApoio({required this.icona, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icona, size: 16, color: AppTheme.textMuted),
        const SizedBox(width: AppTheme.spaceSm),
        Expanded(
          child: Text(
            texto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
