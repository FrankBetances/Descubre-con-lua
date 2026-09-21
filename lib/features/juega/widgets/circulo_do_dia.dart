import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lamina_vector.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/cuento_model.dart';
import '../../../data/models/dinamica_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../cuentos/views/cuento_viewer_screen.dart';
import '../../planificador/views/dinamicas_screen.dart';

/// Lo que el día del aula tiene ADEMÁS de su asamblea: su cuento, con su
/// lámina, y la dinámica que le toca a ese día de la semana.
///
/// **Por qué existe.** El banco de cuentos, el de láminas y el de dinámicas
/// llegaron como tres catálogos paralelos, cada uno con su pantalla y su
/// buscador. La docente que abre el aula un lunes de la semana 3 de octubre
/// tenía que ir a tres sitios distintos y cruzar a mano curso, mes, semana y
/// día para saber qué cuento le tocaba. Los datos ya decían todo eso —los
/// cuentos traen `cursoId`, `mesNumero` y `semanaSugerida`; las dinámicas,
/// `diaSemana`—: lo único que faltaba era preguntárselo.
///
/// **Qué NO hace.** No elige por la docente ni sustituye a los catálogos: es un
/// atajo al que ya está seleccionado arriba. Si para ese día no hay cuento o no
/// hay dinámica, la fila correspondiente no se pinta; no se inventa un relleno
/// ni se enseña un hueco.
class CirculoDoDia extends StatefulWidget {
  final ContentRepository repository;

  /// `curso_0_2`, `curso_2_3`, `curso_3_4`, `curso_4_5` o `curso_5_6`.
  final String cursoId;

  /// 1..10, donde 1 es septiembre. Es el mismo número que usan el aula y el
  /// banco de cuentos: se comprobó contra `mesNome` del propio banco.
  final int mes;

  /// 1..4.
  final int semana;

  /// 1..5, de lunes a viernes.
  final int dia;

  final AppLanguage language;
  final OfflineAudioService? audioService;

  const CirculoDoDia({
    super.key,
    required this.repository,
    required this.cursoId,
    required this.mes,
    required this.semana,
    required this.dia,
    required this.language,
    this.audioService,
  });

  @override
  State<CirculoDoDia> createState() => _CirculoDoDiaState();
}

class _CirculoDoDiaState extends State<CirculoDoDia> {
  static const List<String> _diasDaSemana = [
    'luns',
    'martes',
    'mercores',
    'xoves',
    'venres',
  ];

  Cuento? _cuento;
  DinamicaPedagogica? _dinamica;
  bool _cargado = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant CirculoDoDia old) {
    super.didUpdateWidget(old);
    if (old.cursoId != widget.cursoId ||
        old.mes != widget.mes ||
        old.semana != widget.semana ||
        old.dia != widget.dia) {
      _cargar();
    }
  }

  Future<void> _cargar() async {
    final cuentos = await widget.repository.loadCuentos(
      cursoId: widget.cursoId,
      mesNumero: widget.mes,
    );
    final dinamicas = await widget.repository.loadDinamicas();
    if (!mounted) return;

    Cuento? cuento;
    for (final c in cuentos) {
      if (c.semanaSugerida == widget.semana) {
        cuento = c;
        break;
      }
    }
    // Si esa semana no tiene cuento propio, el del mes sirve: es el mismo
    // centro de interés. Lo que no vale es dejar la fila vacía teniendo
    // material del mes a mano.
    cuento ??= cuentos.isNotEmpty ? cuentos.first : null;

    final claveDia = widget.dia >= 1 && widget.dia <= _diasDaSemana.length
        ? _diasDaSemana[widget.dia - 1]
        : '';
    DinamicaPedagogica? dinamica;
    for (final d in dinamicas) {
      if (d.diaSemana == claveDia) {
        dinamica = d;
        break;
      }
    }

    setState(() {
      _cuento = cuento;
      _dinamica = dinamica;
      _cargado = true;
    });
  }

  void _abrirCuento(Cuento cuento) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CuentoViewerScreen(
          cuento: cuento,
          language: widget.language,
          audioService: widget.audioService,
        ),
      ),
    );
  }

  void _abrirDinamicas() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DinamicasScreen(
          repository: widget.repository,
          initialLanguage: widget.language,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isGl = widget.language == AppLanguage.gl;
    final cuento = _cuento;
    final dinamica = _dinamica;

    // Mientras carga no se reserva sitio: la tarjeta del día no puede dar un
    // salto delante de la docente en mitad de la asamblea.
    if (!_cargado || (cuento == null && dinamica == null)) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.primaryTint,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.borderActive),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            isGl ? 'O DÍA DE HOXE, ENTEIRO' : 'EL DÍA DE HOY, ENTERO',
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: AppTheme.primaryInk,
            ),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          if (cuento != null)
            _FilaDoCirculo(
              lamina:
                  cuento.paginas.isNotEmpty ? cuento.paginas.first.lamina : '',
              icona: Icons.auto_stories_rounded,
              rotulo: isGl ? 'O conto de hoxe' : 'El cuento de hoy',
              titulo: cuento.titulo.resolve(widget.language),
              detalle: isGl
                  ? '${cuento.paginas.length} páxinas · ${cuento.preguntasGraduadas.length} preguntas'
                  : '${cuento.paginas.length} páginas · ${cuento.preguntasGraduadas.length} preguntas',
              onTap: () => _abrirCuento(cuento),
            ),
          if (cuento != null && dinamica != null)
            const SizedBox(height: AppTheme.spaceSm),
          if (dinamica != null)
            _FilaDoCirculo(
              lamina: '',
              icona: Icons.groups_rounded,
              rotulo: isGl ? 'A dinámica de hoxe' : 'La dinámica de hoy',
              titulo: dinamica.titulo.resolve(widget.language),
              detalle: isGl
                  ? '${dinamica.duracionMinutos} min · ${dinamica.ritmoBpm} bpm'
                  : '${dinamica.duracionMinutos} min · ${dinamica.ritmoBpm} bpm',
              onTap: _abrirDinamicas,
            ),
        ],
      ),
    );
  }
}

class _FilaDoCirculo extends StatelessWidget {
  /// Clave de la lámina, o vacía si esta fila no ilustra nada.
  final String lamina;
  final IconData icona;
  final String rotulo;
  final String titulo;
  final String detalle;
  final VoidCallback onTap;

  const _FilaDoCirculo({
    required this.lamina,
    required this.icona,
    required this.rotulo,
    required this.titulo,
    required this.detalle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceSm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 56,
                  height: 44,
                  child: lamina.isEmpty
                      ? Container(
                          color: AppTheme.primaryLight,
                          child: Icon(icona,
                              size: 22, color: AppTheme.primaryDark),
                        )
                      : LaminaEscena(
                          clave: lamina,
                          ancho: 56,
                          mentres: Container(
                            color: AppTheme.primaryLight,
                            child: Icon(icona,
                                size: 22, color: AppTheme.primaryDark),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      rotulo,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryDark,
                      ),
                    ),
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    Text(
                      detalle,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 11,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
