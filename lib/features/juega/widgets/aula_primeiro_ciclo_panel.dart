import 'package:flutter/material.dart';

import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/asamblea_primeiro_ciclo_model.dart';
import '../../../data/models/progresion_model.dart';
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

  /// La tira de Lúa. Es la mascota y el núcleo del proyecto: se quitó por error
  /// al rehacer el aula y vuelve aquí, arriba del todo.
  final Widget? cabeceira;

  /// El calendario del curso. Volvió por el mismo motivo: un aula sin el mes a
  /// la vista obliga a salir de la pantalla para saber por dónde va el curso.
  ///
  /// Recibe el curso del grupo elegido, para enseñar SUS meses.
  final Widget Function(String cursoId)? calendario;

  /// Las fichas de contenido que van debajo de la tarjeta del día.
  final Widget? pe;

  /// La progresión diaria del tramo, por su clave («primeiro_ciclo.0_2»).
  /// Sin ella la tarjeta enseña el mes entero, que es lo que había.
  final ProgresionDoMes? Function(String clave)? progresionDe;

  /// El cuento con su lámina y la dinámica que le tocan a ESTE día. Lo
  /// construye la pantalla, que es quien tiene el repositorio y el navegador;
  /// aquí solo se le dicen el curso, el mes, la semana y el día que hay
  /// elegidos arriba.
  final Widget Function(String cursoId, int mes, int semana, int dia)?
      circuloDoDia;

  final void Function(TramoPrimeiroCiclo tramo, int mes, DiaDeProgresion? dia)
      onComezar;

  const AulaPrimeiroCicloPanel({
    super.key,
    required this.asambleas,
    required this.language,
    required this.onComezar,
    this.cabeceira,
    this.calendario,
    this.pe,
    this.progresionDe,
    this.circuloDoDia,
  });

  @override
  State<AulaPrimeiroCicloPanel> createState() => _AulaPrimeiroCicloPanelState();
}

class _AulaPrimeiroCicloPanelState extends State<AulaPrimeiroCicloPanel> {
  late TramoPrimeiroCiclo _tramo;
  late int _mes;
  late int _semana;
  late int _dia;

  @override
  void initState() {
    super.initState();
    _tramo = TramoPrimeiroCiclo.lactantes0a2;
    _mes = mesDeHoxe();
    _irAoDiaDeHoxe();
  }

  /// Al cambiar de mes se abre por el día que toca: hoy si es este mes, el
  /// primer lunes si no.
  void _irAoDiaDeHoxe() {
    final h = ProgresionDoMes.hoxe(mesElixido: _mes);
    _semana = h.semana;
    _dia = h.dia;
  }

  ProgresionDoMes? get _progresion =>
      widget.progresionDe?.call('primeiro_ciclo.${_tramo.clave}');

  DiaDeProgresion? get _diaActual => _progresion?.dia(_semana, _dia);

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

    // El aula vuelve a DESPLAZARSE. Frank: «el scroll es permitido y puede ser
    // usado para dejar leer la pantalla». Lo que no vale es una lista vertical
    // de todo; por eso lo de dentro son fichas y carruseles que van de lado.
    //
    // Y vuelven las tres cosas que se habían perdido al rehacer esta pantalla:
    // la tira de Lúa, el calendario del curso y las fichas de contenido.
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
                const SizedBox(height: AppTheme.spaceLg),
                RotuloSeccion(isGl ? 'MES DO CURSO' : 'MES DEL CURSO'),
                const SizedBox(height: AppTheme.spaceSm),
              ],
            ),
          ),
          TiraDeMeses(
            prefixoClave: '1c',
            mesSeleccionado: _mes,
            language: lang,
            onCambiar: (m) => setState(() {
              _mes = m;
              _irAoDiaDeHoxe();
            }),
          ),
          if (_progresion != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spaceLg,
                AppTheme.spaceLg,
                AppTheme.spaceLg,
                0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  RotuloSeccion(isGl ? 'SEMANA E DÍA' : 'SEMANA Y DÍA'),
                  const SizedBox(height: AppTheme.spaceSm),
                  TiraDeDias(
                    prefixoClave: '1c',
                    progresion: _progresion!,
                    semana: _semana,
                    dia: _dia,
                    language: lang,
                    onCambiar: (s, d) => setState(() {
                      _semana = s;
                      _dia = d;
                    }),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppTheme.spaceLg),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spaceLg,
            ),
            child: asamblea == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppTheme.spaceXl),
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
                    ),
                  )
                : _TarxetaDeFluxo(
                    asamblea: asamblea,
                    language: lang,
                    dia: _diaActual,
                    semana: _progresion?.semana(_semana),
                    // El aula numera los meses por el CALENDARIO (setembro es
                    // 9) y el banco de cuentos por el ORDEN DEL CURSO (setembro
                    // es 1). Sin esta conversión, en septiembre salía el cuento
                    // de mayo: se vio abriendo la app, no en un test.
                    circulo: widget.circuloDoDia?.call(
                      'curso_${_tramo.clave}',
                      mesesDoCurso.indexOf(_mes) + 1,
                      _semana,
                      _dia,
                    ),
                    onComezar: () => widget.onComezar(_tramo, _mes, _diaActual),
                  ),
          ),
          if (widget.calendario case final calendario?)
            calendario('curso_${_tramo.clave}'),
          if (widget.pe != null) widget.pe!,
        ],
      ),
    );
  }
}

class _TarxetaDeFluxo extends StatelessWidget {
  final AsambleaPrimeiroCiclo asamblea;
  final AppLanguage language;
  final DiaDeProgresion? dia;
  final SemanaDeProgresion? semana;

  /// El cuento y la dinámica del día. Nulo si la pantalla no lo pasa.
  final Widget? circulo;
  final VoidCallback onComezar;

  const _TarxetaDeFluxo({
    required this.asamblea,
    required this.language,
    required this.dia,
    required this.semana,
    required this.circulo,
    required this.onComezar,
  });

  /// Las órdenes en inglés que tocan hoy, ya recortadas al día.
  List<String> get _ordesDeHoxe {
    final d = dia;
    if (d == null) return const [];
    for (final f in d.aplicarA(asamblea.fases)) {
      if (f.comandosL3.isNotEmpty) {
        return [for (final c in f.comandosL3) c.textoIngles];
      }
    }
    return const [];
  }

  /// La lámina de la fase del núcleo TPR, que es la que da el tema del mes.
  String get _lamina {
    for (final f in asamblea.fases) {
      if (f.lamina.isNotEmpty && f.lamina != 'gato') return f.lamina;
    }
    return 'gato';
  }

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;

    // Altura natural: esta tarjeta vive dentro de una lista que se desplaza,
    // así que no puede depender de un hueco acotado. Nada se recorta y nada
    // se encoge; si el texto crece, la tarjeta crece.
    return Container(
      key: const ValueKey('tarxeta_fluxo_1c'),
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
          // La lámina del mes, arriba y a todo ancho. Es lo que hace que la
          // pantalla se reconozca de un vistazo y lo que la volvía fría
          // cuando no estaba.
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
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    height: 1.2,
                  ),
                ),
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
                const SizedBox(height: AppTheme.spaceMd),
                if (dia != null) ...[
                  BloqueDoDia(
                    dia: dia!,
                    semana: semana,
                    ordes: _ordesDeHoxe,
                    language: language,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                ],
                for (final fase in asamblea.fases)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                    child: FilaDeFase(
                      orden: fase.orden,
                      titulo: fase.titulo.resolve(language),
                      minutos: (fase.duracionSegundos / 60).round(),
                    ),
                  ),
                if (circulo != null) ...[
                  const SizedBox(height: AppTheme.spaceSm),
                  circulo!,
                ],
                const SizedBox(height: AppTheme.spaceSm),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    key: const ValueKey('comezar_asemblea_1c'),
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
