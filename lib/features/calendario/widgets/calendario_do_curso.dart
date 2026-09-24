import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/repositories/calendario_repository.dart';
import 'tarjeta_mes_curricular.dart';

/// El calendario del curso, metido DENTRO de la pantalla en la que se está.
///
/// Antes cada modo —aula de primer ciclo, aula de segundo ciclo y Academy—
/// llevaba un botón que saltaba a otra pantalla. Un botón que lleva al
/// calendario no es el calendario: la docente que abre el aula con dos minutos
/// de margen tiene que ver el mes que le toca sin salir de donde está.
///
/// Vive aquí y no copiado tres veces porque tres copias acaban divergiendo: la
/// primera vez que alguien arregle una, las otras dos se quedan con el fallo.
class CalendarioDoCurso extends StatefulWidget {
  final AppLanguage lang;

  /// Qué lado mira: la tarjeta enseña la marca del aula o la de la casa.
  final bool esDocente;

  /// De dónde sale el estado de cada mes. Sin él las tarjetas salen en blanco,
  /// que es lo correcto: no se inventa un progreso que nadie ha registrado.
  final CalendarioStore? store;

  /// Qué hacer al tocar un mes. Recibe el contenido ya leído, el curso y el mes
  /// DENTRO de ese curso (0 es septiembre), para que quien abra la pantalla
  /// completa la abra POR ESE MES y no por el de hoy.
  final void Function(
      CalendarioContenido contenido, String cursoId, int mesIndex) onAbrirMes;

  /// El curso del grupo, si quien llama lo sabe (el aula). Con él se ven sus
  /// diez meses; sin él, el trayecto entero de 0 a 6 años.
  final String? cursoId;

  /// El contenido ya leído, si quien llama lo tiene. Si no, se lee aquí.
  final CalendarioContenido? contenido;

  /// El margen de la sección. Quien la mete en una lista que ya tiene su
  /// propio margen lateral le pasa uno sin lados, para que la tarjeta no
  /// quede estrecha por sumar dos márgenes.
  final EdgeInsets padding;

  const CalendarioDoCurso({
    super.key,
    required this.lang,
    required this.esDocente,
    required this.onAbrirMes,
    this.store,
    this.contenido,
    this.cursoId,
    this.padding = const EdgeInsets.fromLTRB(
      AppTheme.spaceLg,
      AppTheme.spaceMd,
      AppTheme.spaceLg,
      0,
    ),
  });

  @override
  State<CalendarioDoCurso> createState() => _CalendarioDoCursoState();
}

class _CalendarioDoCursoState extends State<CalendarioDoCurso> {
  CalendarioContenido? _contenido;
  PageController? _paginas;
  int _mesIndex = 0;
  bool _fallo = false;

  /// Los meses que se pasan: los diez del curso del grupo, o los cincuenta del
  /// trayecto si no hay grupo. Los diez genéricos solo si el trayecto no se leyó.
  List<MesCurricular> get _meses {
    final c = _contenido;
    if (c == null) return const [];
    if (c.trayecto.isEmpty) return c.meses;
    final curso = widget.cursoId;
    if (curso == null) return c.trayecto;
    return [
      for (final m in c.trayecto)
        if (m.cursoId == curso) m,
    ];
  }

  @override
  void initState() {
    super.initState();
    final yaCargado = widget.contenido;
    if (yaCargado != null) {
      _contenido = yaCargado;
      _situar();
    } else {
      CalendarioContenido.cargar().then((c) {
        if (!mounted) return;
        setState(() {
          _contenido = c;
          _situar();
        });
        // Sin `catchError` el fallo de lectura no llega a ninguna parte: la
        // sección se queda en blanco para siempre y nadie sabe por qué. Ya
        // pasó una vez, cuando `assets/content/calendario/` no estaba en
        // pubspec.yaml.
      }).catchError((Object _) {
        if (!mounted) return;
        setState(() => _fallo = true);
      });
    }
  }

  @override
  void didUpdateWidget(covariant CalendarioDoCurso old) {
    super.didUpdateWidget(old);
    // Otro grupo, otro curso: la tira vuelve al mes de hoy de ESE curso.
    if (old.cursoId != widget.cursoId && _contenido != null) {
      setState(_situar);
    }
  }

  /// Abre por el mes de curso que toca hoy, no por septiembre.
  void _situar() {
    final hoxe = DateTime.now();
    final mesDeHoxe = _contenido?.mesParaFecha(hoxe).mesCalendario;
    final i = _meses.indexWhere((m) => m.mesCalendario == mesDeHoxe);
    final indice = i < 0 ? 0 : i;
    _mesIndex = indice < 0 ? 0 : indice;
    _paginas?.dispose();
    _paginas = PageController(
      initialPage: _mesIndex,
      // Deja asomar el canto del mes siguiente, que es lo que dice que la
      // tarjeta se desliza. Aquí la tarjeta no lleva botones dentro, así que
      // ver a medias la de al lado no pone nada tocable donde no toca.
      viewportFraction: 0.86,
    );
  }

  @override
  void dispose() {
    _paginas?.dispose();
    super.dispose();
  }

  /// El curso que se ve en el rótulo: el del grupo, o los seis años enteros.
  String _rotuloDoCurso(AppLanguage lang) {
    final curso = MesCurricular.etiquetasDosCursos[widget.cursoId];
    if (curso != null) return curso.resolve(lang).toUpperCase();
    return lang == AppLanguage.gl ? '0-6 ANOS' : '0-6 AÑOS';
  }

  /// Abre el calendario completo por el mes [index] de la tira.
  void _abrir(int index) {
    final mes = _meses[index];
    widget.onAbrirMes(
      _contenido!,
      mes.cursoId ?? widget.cursoId ?? 'curso_0_2',
      mes.mesDoCurso - 1,
    );
  }

  EstadoEstimulacion _estadoDe(MesCurricular mes) {
    final store = widget.store;
    if (store == null) return EstadoEstimulacion.sinRegistro;
    final hoy = DateTime.now();
    final anho = mes.mesCalendario >= 9
        ? (hoy.month >= 9 ? hoy.year : hoy.year - 1)
        : (hoy.month >= 9 ? hoy.year + 1 : hoy.year);
    return store.estadoParaMes(anho, mes.mesCalendario);
  }

  @override
  Widget build(BuildContext context) {
    final isGl = widget.lang == AppLanguage.gl;

    if (_fallo) return const SizedBox.shrink();
    if (_meses.isEmpty) {
      // Dura un fotograma en un aparato real. Reservar el alto evita que la
      // pantalla dé un salto cuando el contenido entra.
      return const SizedBox(height: 232);
    }

    final paginas = _paginas;
    return Padding(
      padding: widget.padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGl
                      ? 'CALENDARIO ESCOLA · FOGAR · ${_rotuloDoCurso(widget.lang)}'
                      : 'CALENDARIO ESCUELA · HOGAR · ${_rotuloDoCurso(widget.lang)}',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              TextButton(
                key: const Key('ver_calendario_completo'),
                onPressed: () => _abrir(_mesIndex),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  isGl ? 'Ver todo' : 'Ver todo',
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            // Alto acotado: la tarjeta recorta el centro de interés con un
            // `Flexible`, y un `Flexible` sin alto acotado revienta.
            //
            // Y acotado CON LA ESCALA DE TEXTO: con 172 px fijos, a escala 1,3
            // la cabecera y el pie de la tarjeta ya no cabían y desbordaba 5 px
            // por abajo. El techo de 260 evita que a escala 1,8 la tarjeta se
            // coma la pantalla entera.
            height:
                MediaQuery.textScalerOf(context).scale(172).clamp(172.0, 260.0),
            child: ScrollConfiguration(
              // Flutter, por defecto, solo deja arrastrar con el dedo y el
              // lápiz. Con un ratón conectado la tarjeta no se movía y parecía
              // que el desplazamiento lateral no existía.
              behavior: const _ArrastreTamenConRato(),
              child: PageView.builder(
                key: const Key('meses_do_curso'),
                controller: paginas,
                itemCount: _meses.length,
                onPageChanged: (i) => setState(() => _mesIndex = i),
                itemBuilder: (context, index) {
                  final mes = _meses[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: TarjetaMesCurricular(
                      lang: widget.lang,
                      mes: mes,
                      estado: _estadoDe(mes),
                      esDocente: widget.esDocente,
                      isSelected: index == _mesIndex,
                      onTap: () => _abrir(index),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            isGl
                ? 'Desliza para cambiar de mes · Toca a tarxeta para abrila'
                : 'Desliza para cambiar de mes · Toca la tarjeta para abrirla',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11.5,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

/// El arrastre lateral, también con ratón y trackpad.
class _ArrastreTamenConRato extends MaterialScrollBehavior {
  const _ArrastreTamenConRato();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}
