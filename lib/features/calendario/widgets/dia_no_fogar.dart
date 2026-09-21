import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/dia_calendario_dual_model.dart';
import '../../../data/models/progresion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';

/// La semana, el día y la rutina de casa: el espejo exacto del Modo Aula, con
/// la familia en el sitio de la docente.
///
/// **Por qué existe.** El Calendario Escola · Fogar llegaba a MES por el lado
/// de las familias y se paraba ahí, mientras el lado del aula baja hasta el día
/// —mes, semana, día— y enseña lo que toca hoy. La familia veía un texto del
/// mes entero y tenía que adivinar qué hacer el martes de la semana 3.
///
/// **De dónde sale.** De `assets/content/calendario/calendario_dias.json`, que
/// trae los 1.000 días del proyecto —5 cursos × 10 meses × 4 semanas × 5 días—
/// y cada uno con sus DOS lados: `profesorado` y `familias`. El fichero ya
/// estaba en el repositorio y lo leía `ContentRepository`; lo que no había era
/// ninguna pantalla que lo pintara.
///
/// **Por qué la misma tira que el aula.** `TiraDeDias` es la del Modo Aula, sin
/// tocar: la familia y la docente hablan del mismo martes de la misma semana, y
/// dos interfaces distintas para la misma rejilla obligarían a traducir en la
/// cabeza justo en el sitio donde las dos tienen que coincidir.
class DiaNoFogar extends StatefulWidget {
  final ContentRepository repository;

  /// `curso_0_2`, `curso_2_3`, `curso_3_4`, `curso_4_5` o `curso_5_6`.
  final String cursoId;

  /// 1..10, donde 1 es septiembre: el orden del CURSO, no el del calendario.
  final int mes;

  final AppLanguage language;

  const DiaNoFogar({
    super.key,
    required this.repository,
    required this.cursoId,
    required this.mes,
    required this.language,
  });

  @override
  State<DiaNoFogar> createState() => _DiaNoFogarState();
}

class _DiaNoFogarState extends State<DiaNoFogar> {
  List<DiaCalendarioDual> _dias = const [];
  bool _cargado = false;
  int _semana = 1;
  int _dia = 1;

  @override
  void initState() {
    super.initState();
    final hoxe = ProgresionDoMes.hoxe();
    _semana = hoxe.semana;
    _dia = hoxe.dia;
    _cargar();
  }

  @override
  void didUpdateWidget(covariant DiaNoFogar old) {
    super.didUpdateWidget(old);
    if (old.cursoId != widget.cursoId || old.mes != widget.mes) _cargar();
  }

  Future<void> _cargar() async {
    final dias = await widget.repository.loadCalendarioDias(
      cursoId: widget.cursoId,
      mes: widget.mes,
    );
    if (!mounted) return;
    setState(() {
      _dias = dias;
      _cargado = true;
    });
  }

  DiaCalendarioDual? get _actual {
    for (final d in _dias) {
      if (d.semanaNumero == _semana && d.diaSemanaNumero == _dia) return d;
    }
    return _dias.isNotEmpty ? _dias.first : null;
  }

  /// Los veinte días del mes, vestidos de `ProgresionDoMes` para que la tira de
  /// pastillas sea LA MISMA del aula y no una copia parecida.
  ProgresionDoMes get _progresion {
    final semanas = <SemanaDeProgresion>[];
    final dias = <DiaDeProgresion>[];
    for (var s = 1; s <= 4; s++) {
      semanas.add(SemanaDeProgresion(
        numero: s,
        nome: LocalizedString(gl: 'Semana $s', es: 'Semana $s'),
        meta: const LocalizedString(gl: '', es: ''),
      ));
    }
    for (final d in _dias) {
      dias.add(DiaDeProgresion(
        semana: d.semanaNumero,
        dia: d.diaSemanaNumero,
        nomeDia: d.nombreDiaSemana,
        foco: d.temaDia,
        consigna: d.familias.consignaFamilia,
        comandos: const [],
        modo: ModoDoDia.combinar,
      ));
    }
    return ProgresionDoMes(
      id: '${widget.cursoId}_mes_${widget.mes}',
      nota: const LocalizedString(gl: '', es: ''),
      semanas: semanas,
      dias: dias,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGl = widget.language == AppLanguage.gl;
    final dia = _actual;

    // Mientras lee no se reserva sitio: el calendario no puede dar un salto
    // debajo del dedo de quien acaba de tocar el mes.
    if (!_cargado || dia == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RotuloSeccion(isGl ? 'SEMANA E DÍA' : 'SEMANA Y DÍA'),
        const SizedBox(height: AppTheme.spaceSm),
        TiraDeDias(
          prefixoClave: 'fogar',
          progresion: _progresion,
          semana: _semana,
          dia: _dia,
          language: widget.language,
          onCambiar: (s, d) => setState(() {
            _semana = s;
            _dia = d;
          }),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        _TarxetaDoDiaNoFogar(dia: dia, language: widget.language),
      ],
    );
  }
}

class _TarxetaDoDiaNoFogar extends StatelessWidget {
  final DiaCalendarioDual dia;
  final AppLanguage language;

  const _TarxetaDoDiaNoFogar({required this.dia, required this.language});

  @override
  Widget build(BuildContext context) {
    final isGl = language == AppLanguage.gl;
    final theme = Theme.of(context);

    return Container(
      key: const Key('tarxeta_dia_fogar'),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderActive, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${dia.nombreDiaSemana.resolve(language)} · '
                  '${isGl ? "Semana" : "Semana"} ${dia.semanaNumero}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppTheme.primaryInk,
                  ),
                ),
              ),
              if (dia.familias.senPantallas)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.successBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success),
                  ),
                  child: Text(
                    isGl ? 'Sen pantallas' : 'Sin pantallas',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryInk,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            dia.temaDia.resolve(language),
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              height: 1.25,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _Bloque(
            icona: Icons.schedule_rounded,
            rotulo: isGl ? 'Cando' : 'Cuándo',
            texto: dia.familias.momento.resolve(language),
            theme: theme,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _Bloque(
            icona: Icons.volunteer_activism_rounded,
            rotulo: isGl ? 'Que facer na casa' : 'Qué hacer en casa',
            texto: _sinPrefixoDeMaquina(
                dia.familias.rutinaFogar.resolve(language)),
            theme: theme,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          _Bloque(
            icona: Icons.link_rounded,
            rotulo: isGl
                ? 'Por que enlaza coa escola'
                : 'Por qué enlaza con la escuela',
            texto: dia.familias.fraseConexion.resolve(language),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

/// El texto del día, sin el corchete de máquina que trae el fichero.
///
/// Cada rutina empieza por «[Fogar · 1.º Curso (0-2 anos · 12 a 24 meses)]»,
/// que repite lo que la tarjeta ya dice arriba y ocupa una línea y media de una
/// tarjeta que se lee con una criatura en brazos.
String _sinPrefixoDeMaquina(String texto) {
  final limpio = texto.trimLeft();
  if (!limpio.startsWith('[')) return texto.trim();
  final fin = limpio.indexOf(']');
  return fin < 0 ? texto.trim() : limpio.substring(fin + 1).trim();
}

class _Bloque extends StatelessWidget {
  final IconData icona;
  final String rotulo;
  final String texto;
  final ThemeData theme;

  const _Bloque({
    required this.icona,
    required this.rotulo,
    required this.texto,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.pageBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icona, size: 16, color: AppTheme.primaryDark),
              const SizedBox(width: 6),
              Text(
                rotulo,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: AppTheme.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            texto,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
