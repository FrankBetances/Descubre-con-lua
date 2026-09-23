import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../../core/audio/offline_audio_service.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/storage/calendario_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../core/widgets/aviso_contenido_ilegible.dart';
import '../../../data/models/calendario_model.dart';
import '../../../data/models/unidad_model.dart';
import '../../../data/models/asamblea_segundo_ciclo_model.dart';
import '../../juega/views/asamblea_player_screen.dart';
import '../../juega/widgets/aula_ciclo_panel.dart';
import '../../juega/widgets/aula_segundo_ciclo_panel.dart';
import '../../../data/models/asamblea_primeiro_ciclo_model.dart';
import '../../../data/models/progresion_model.dart';
import '../../../data/repositories/content_repository.dart';
import '../../juega/widgets/barra_ingles_widget.dart';
import '../widgets/dia_no_fogar.dart';
import '../../academy/views/guia_atencion_screen.dart';
import '../../academy/widgets/selector_idioma_widget.dart';
import '../../juega/views/asamblea_guiada_screen.dart';
import '../../premios/premios_repository.dart';
import '../widgets/boton_lanzar_sesion.dart';
import '../widgets/tarjeta_mes_curricular.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/iconos_contenido.dart';
import '../../../data/repositories/calendario_repository.dart';
import '../widgets/temporizador_sutil_widget.dart';
import '../../../core/widgets/boton_atras.dart';

/// Contrato de callback para o lanzamento a un toque da sesión
typedef IniciarSesionCallback = void Function(
    MesCurricular mes, bool esDocente);

/// Pantalla del Calendario Sincronizado Escuela-Hogar (10 meses, Septiembre a Junio).
///
/// Permite a docentes y familias sincronizar la estimulación auditiva y motora
/// del inglés (L3) en torno a centros de interés de Galicia (Decreto 150/2022),
/// Cada lado —aula y casa— registra SOLO lo suyo: la app no tiene red y un
/// aparato no sabe lo que pasó en el otro. El puente es la nota que la docente
/// entrega en mano al terminar la asamblea.
class CalendarioScreen extends StatefulWidget {
  final CalendarioStore store;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;
  final bool esDocenteInicial;

  /// Por qué mes abrir. Sin esto la pantalla abre siempre por el mes de hoy,
  /// y quien llega tocando la tarjeta de xaneiro en Modo Aula esperaba xaneiro.
  final int? mesInicialIndex;
  final IniciarSesionCallback? onIniciarSesion;
  final ContentRepository? repository;
  final OfflineAudioService? audioService;
  final PremiosRepository? premios;

  /// El contenido ya cargado. Si no se pasa, la pantalla lo lee del bundle:
  /// los diez meses y la guía viven en `assets/content/calendario/`, no aquí.
  final CalendarioContenido? contenido;

  const CalendarioScreen({
    super.key,
    required this.store,
    this.contenido,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.esDocenteInicial = false,
    this.mesInicialIndex,
    this.onIniciarSesion,
    this.repository,
    this.audioService,
    this.premios,
  });

  @override
  State<CalendarioScreen> createState() => _CalendarioScreenState();
}

class _CalendarioScreenState extends State<CalendarioScreen> {
  late AppLanguage _language;
  late bool _esDocente;
  int _mesSeleccionadoIndex = 0;
  CalendarioContenido? _contenido;

  /// La semana y el día de la asamblea que se abre desde aquí.
  int _semana = ProgresionDoMes.hoxe().semana;
  int _dia = ProgresionDoMes.hoxe().dia;

  /// El curso de la crianza, para el lado de las familias. El aula elige
  /// «O MEU GRUPO» y la familia elige lo mismo: la rutina de casa de un bebé
  /// de dieciocho meses no es la de uno de cinco años, y el calendario de
  /// familias no preguntaba.
  String _cursoFogar = _cursosDaCrianza.first.valor;

  /// El mes se cambia deslizando la tarjeta de lado, no bajando por la
  /// pantalla. Antes el mes se elegía de tres maneras apiladas en una sola
  /// página —una tira de tarjetas de 160 px, las pastillas y la ficha de
  /// abajo—, y la pantalla medía 2,2 pantallas de alto. Ahora hay una tarjeta
  /// por mes y se pasa como una página.
  PageController? _paginas;

  /// Una clave por pastilla de mes, para poder arrastrar la tira hasta la del
  /// mes abierto. Sin esto, al deslizar hasta xuño la pastilla de xuño se
  /// quedaba fuera de la tira y la fila seguía enseñando setembro marcado en
  /// ningún sitio.
  final List<GlobalKey> _clavesPastilla = [];

  /// Lo que impidió leer el contenido, si pasó. Con esto la pantalla enseña
  /// una avería en vez de un disco girando.
  String? _fallo;

  List<MesCurricular> get _meses => _contenido?.meses ?? const [];

  static const _titulo = LocalizedString(
    gl: 'Calendario Escola · Fogar',
    es: 'Calendario Escuela · Hogar',
  );

  static const _subtitulo = LocalizedString(
    gl: 'Os dez meses do curso. A docente dirixe a asemblea e entrega a nota; '
        'a familia fai o xogo de tres minutos na casa. Cada lado marca o seu.',
    es: 'Los diez meses del curso. La docente dirige la asamblea y entrega la '
        'nota; la familia hace el juego de tres minutos en casa. Cada lado '
        'marca lo suyo.',
  );

  static const List<OpcionDeIdade<String>> _cursosDaCrianza = [
    OpcionDeIdade(
      valor: 'curso_0_2',
      etiqueta: LocalizedString(gl: '0-2 anos', es: '0-2 años'),
      matiz: LocalizedString(gl: 'Colo', es: 'Regazo'),
    ),
    OpcionDeIdade(
      valor: 'curso_2_3',
      etiqueta: LocalizedString(gl: '2-3 anos', es: '2-3 años'),
      matiz: LocalizedString(gl: 'Xogo', es: 'Juego'),
    ),
    OpcionDeIdade(
      valor: 'curso_3_4',
      etiqueta: LocalizedString(gl: '3-4 anos', es: '3-4 años'),
      matiz: LocalizedString(gl: 'Frases', es: 'Frases'),
    ),
    OpcionDeIdade(
      valor: 'curso_4_5',
      etiqueta: LocalizedString(gl: '4-5 anos', es: '4-5 años'),
      matiz: LocalizedString(gl: 'Relato', es: 'Relato'),
    ),
    OpcionDeIdade(
      valor: 'curso_5_6',
      etiqueta: LocalizedString(gl: '5-6 anos', es: '5-6 años'),
      matiz: LocalizedString(gl: 'Ler', es: 'Leer'),
    ),
  ];

  static const _rolDocente =
      LocalizedString(gl: 'Aula (Docentes)', es: 'Aula (Docentes)');
  static const _rolFamilia =
      LocalizedString(gl: 'Fogar (Familias)', es: 'Hogar (Familias)');

  static const _tituloHoxeAula = LocalizedString(
    gl: 'Hoxe, na aula',
    es: 'Hoy, en el aula',
  );

  static const _tituloHoxeFogar = LocalizedString(
    gl: 'Hoxe, na casa',
    es: 'Hoy, en casa',
  );

  static const _marcarAula = LocalizedString(
    gl: 'Rexistrar asemblea de hoxe na aula',
    es: 'Registrar asamblea de hoy en el aula',
  );

  static const _marcarHogar = LocalizedString(
    gl: 'Rexistrar micro-rutina de hoxe na casa',
    es: 'Registrar micro-rutina de hoy en casa',
  );

  static const _hogarHecho = LocalizedString(
    gl: 'Rutina feita na casa hoxe!',
    es: '¡Rutina hecha en casa hoy!',
  );

  static const _aulaHecha = LocalizedString(
    gl: 'Asemblea feita na aula hoxe!',
    es: '¡Asamblea hecha en el aula hoy!',
  );

  static const _fraseKicker = LocalizedString(
    gl: 'A FRASE EN INGLÉS DESTE MES',
    es: 'LA FRASE EN INGLÉS DE ESTE MES',
  );

  static const _aulaKicker = LocalizedString(
    gl: 'ACTIVIDADE NA AULA (ASEMBLEA MATINAL)',
    es: 'ACTIVIDAD EN EL AULA (ASAMBLEA MATINAL)',
  );

  static const _hogarKicker = LocalizedString(
    gl: 'MICRO-RUTINA NO FOGAR (3-5 MIN SEN PANTALLAS)',
    es: 'MICRO-RUTINA EN EL HOGAR (3-5 MIN SIN PANTALLAS)',
  );

  static const _iniciarAula = LocalizedString(
    gl: 'Iniciar asemblea guiada',
    es: 'Iniciar asamblea guiada',
  );

  static const _instruccionsBrevesTitulo = LocalizedString(
    gl: 'Instrucións breves para a asemblea:',
    es: 'Instrucciones breves para la asamblea:',
  );

  static const _instruccionsBrevesCuerpo = LocalizedString(
    gl: 'Círculo na alfombra · Móbil só para a docente · Pulso a 72 BPM e xogo sensoriomotriz.',
    es: 'Círculo en la alfombra · Móvil solo para la docente · Pulso a 72 BPM y juego sensoriomotriz.',
  );

  static const _enPreparacion = LocalizedString(
    gl: 'A unidade de aula deste mes aínda non está escrita. Cando estea, o '
        'botón de iniciar a asemblea aparece aquí só.',
    es: 'La unidad de aula de este mes todavía no está escrita. Cuando lo '
        'esté, el botón de iniciar la asamblea aparece aquí solo.',
  );

  static const _guiaAtencionBoton = LocalizedString(
    gl: 'Ver a guía de inglés na casa',
    es: 'Ver la guía de inglés en casa',
  );

  static const _guiaAtencionSubtitulo = LocalizedString(
    gl: 'Canto dura o xogo segundo a idade, tres regras para a casa e a '
        'pronuncia de cada frase.',
    es: 'Cuánto dura el juego según la edad, tres reglas para casa y la '
        'pronunciación de cada frase.',
  );

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
    _esDocente = widget.esDocenteInicial;

    final yaCargado = widget.contenido;
    if (yaCargado != null) {
      _contenido = yaCargado;
      _situarEnElMesDeHoy();
    } else {
      CalendarioContenido.cargar().then((c) {
        if (!mounted) return;
        setState(() {
          _contenido = c;
          _situarEnElMesDeHoy();
        });
        // Sin este catchError, un fallo de lectura no llegaba a ninguna parte:
        // el setState no corría, `_meses` se quedaba vacío y la pantalla
        // giraba para siempre. Fue exactamente lo que pasó cuando faltaba
        // `assets/content/calendario/` en pubspec.yaml.
      }).catchError((Object e) {
        if (!mounted) return;
        setState(() => _fallo = '${CalendarioContenido.mesesAsset} · $e');
      });
    }
  }

  /// Abre por el mes de curso que toca hoy, no por septiembre.
  void _situarEnElMesDeHoy() {
    final pedido = widget.mesInicialIndex;
    final total = _contenido?.meses.length ?? 0;
    final indice = (pedido != null && pedido >= 0 && pedido < total)
        ? pedido
        : (_contenido?.indiceParaFecha(DateTime.now()) ?? 0);
    _mesSeleccionadoIndex = indice < 0 ? 0 : indice;
    // El controlador se crea AQUI y no en `initState`: hasta que el contenido
    // no esta leido no se sabe por que mes hay que abrir, y `initialPage` solo
    // se lee al construirlo. Mientras `_meses` esta vacio la pantalla ensena
    // el indicador de carga, asi que el `PageView` todavia no existe.
    _clavesPastilla
      ..clear()
      ..addAll(List.generate(_meses.length, (_) => GlobalKey()));
    _paginas?.dispose();
    _paginas = PageController(
      initialPage: _mesSeleccionadoIndex,
      // Una página entera por mes, sin dejar asomar la siguiente. Asomando
      // —`viewportFraction` por debajo de 1— el mes vecino SE CONSTRUYE: había
      // dos botones «Iniciar asemblea» y dos «Rexistrar» a la vez en la
      // pantalla, uno de ellos del mes de al lado y tocable por el canto. Quien
      // quiera saltar a un mes lejano tiene las pastillas justo encima.
    );
  }

  @override
  void dispose() {
    _paginas?.dispose();
    super.dispose();
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() {
      _language = newLang;
    });
    widget.onLanguageChanged?.call(newLang);
  }

  /// La unidad de aula de ese mes, o `null` si todavía no está escrita.
  ///
  /// Antes esto caía en `unidades.first` cuando no encontraba el mes, y como
  /// solo existe UNA unidad, los diez meses abrían la misma asamblea del Mar
  /// de Vigo. Un calendario de diez meses sobre contenido de uno. Ahora, si no
  /// hay unidad, no hay botón: el mes se ve «en preparación» y no miente.
  Unidad? _unidadDe(MesCurricular mes) {
    final id = mes.unidadId;
    if (id == null) return null;
    return widget.repository?.getUnidadById(id);
  }

  void _lanzarSesion(MesCurricular mes, bool esDocente) {
    if (widget.onIniciarSesion != null) {
      widget.onIniciarSesion!(mes, esDocente);
      return;
    }

    final unidad = _unidadDe(mes);
    if (unidad == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AsambleaGuiadaScreen(
          unidad: unidad,
          calendario: widget.store,
          audioService: widget.audioService,
          premios: widget.premios,
          initialLanguage: _language,
          onLanguageChanged: _onToggleLanguage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fallo = _fallo;
    if (fallo != null) {
      return Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(
            leading: const BotonAtras(),
            title: Text(_titulo.resolve(_language))),
        body: AvisoContenidoIlegible(asset: fallo, language: _language),
      );
    }
    if (_meses.isEmpty) {
      // El contenido todavía se está leyendo del paquete. Dura un fotograma en
      // un aparato real; una pantalla a medias se vería peor que esto.
      return Scaffold(
        backgroundColor: AppTheme.pageBg,
        appBar: AppBar(
            leading: const BotonAtras(),
            title: Text(_titulo.resolve(_language))),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: AppTheme.pageBg,
      appBar: AppBar(
        leading: const BotonAtras(),
        title: Text(
          _titulo.resolve(_language),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              // GL/ES, como el resto de la app: con el nombre entero
              // («Galego», «Castellano») la barra desbordaba 119 px a escala
              // de texto grande.
              compact: true,
            ),
          ),
        ],
      ),
      // targetSdk 36 obliga al borde a borde en Android 15+: la ventana
      // ya no reserva la barra de gestos y el final de esta pantalla
      // quedaba por debajo. `top: false` porque el inset de arriba ya lo
      // consume el AppBar; volver a pedirlo aquí no suma nada.
      body: SafeArea(
        top: false,
        child: AnimatedBuilder(
          animation: widget.store,
          builder: (context, _) {
            // El estado del día se lee AQUÍ DENTRO, no en el `build` de fuera.
            // Estaba fuera, y como AnimatedBuilder solo vuelve a llamar a este
            // closure, el cuerpo se repintaba con el estado viejo: se registraba
            // la asamblea, se guardaba bien en disco, y el cartel seguía
            // diciendo «aínda non hai nada» hasta salir y volver a entrar.
            final estadoHoy = widget.store.estadoParaFecha(DateTime.now());
            return LayoutBuilder(
              builder: (context, restricciones) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Lo de arriba NO se desplaza con los meses: es el marco de
                    // la pantalla, igual que en «Juega con Lúa · Aula», donde
                    // las pestañas de ciclo y los filtros se quedan fijos y
                    // solo corre la lista.
                    //
                    // El techo del 55 % no es decorativo: a escala de texto 1,8
                    // el marco crecía más que la pantalla y desbordaba 418 px en
                    // gallego y 458 en castellano. Con techo, ahí se desplaza él
                    // solo. A escala normal no llega al techo y no se mueve.
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: restricciones.maxHeight * 0.55,
                      ),
                      child: PaxinaSenScroll(
                        desprazarSeNonCabe: true,
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.spaceLg,
                          AppTheme.spaceLg,
                          AppTheme.spaceLg,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildHeader(theme),
                            const SizedBox(height: AppTheme.spaceMd),
                            _buildDobleEstimulacionCard(estadoHoy, theme),
                            const SizedBox(height: AppTheme.spaceMd),
                            _buildRoleSwitcher(theme),
                            const SizedBox(height: AppTheme.spaceMd),
                            // El espejo del aula: allí se elige el grupo antes
                            // que el mes, aquí también.
                            if (!_esDocente && widget.repository != null) ...[
                              RotuloSeccion(_language == AppLanguage.gl
                                  ? 'A MIÑA CRIANZA'
                                  : 'MI CRIATURA'),
                              const SizedBox(height: AppTheme.spaceSm),
                              SelectorDeIdade<String>(
                                prefixoClave: 'curso_fogar',
                                seleccionado: _cursoFogar,
                                language: _language,
                                opcions: _cursosDaCrianza,
                                onCambiar: (c) =>
                                    setState(() => _cursoFogar = c),
                              ),
                              const SizedBox(height: AppTheme.spaceMd),
                            ],
                            _buildMonthSelector(theme),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Expanded(child: _buildPaginasDeMes(estadoHoy, theme)),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _subtitulo.resolve(_language),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Una tarjeta por mes, y el mes se cambia deslizando de lado.
  ///
  /// Esto es lo que Frank pidió y lo que la pantalla no hacía. Había una tira
  /// horizontal de tarjetas de 160 px metida dentro de una página que medía
  /// 2,2 pantallas de alto, y el mismo mes salía tres veces: en la tira, en
  /// las pastillas y en la ficha de abajo. El [DetalleSesionPanel] que colgaba
  /// de la tira repetía, palabra por palabra, la actividad que ya estaba en la
  /// ficha. Ahora cada mes es una página entera y lo que se desplaza es la
  /// tarjeta.
  Widget _buildPaginasDeMes(EstadoEstimulacion estadoHoy, ThemeData theme) {
    final paginas = _paginas;
    // Sin controlador no hay páginas: pasa solo mientras el contenido se lee,
    // y en ese rato la pantalla ya está enseñando el indicador de carga.
    if (paginas == null) return const SizedBox.shrink();
    return ScrollConfiguration(
      // Flutter, por defecto, NO deja arrastrar con el ratón ni con el
      // trackpad: solo con el dedo y el lápiz. Con el dedo se desliza —lo
      // prueba el test, que usa un gesto táctil—, pero arrastrando con el
      // ratón la tarjeta no se movía y parecía que la pantalla no hacía nada.
      behavior: const _ArrastreTamenConRato(),
      child: PageView.builder(
        key: const Key('paginas_meses'),
        controller: paginas,
        itemCount: _meses.length,
        onPageChanged: (index) {
          setState(() => _mesSeleccionadoIndex = index);
          _traerPastillaALaVista(index);
        },
        itemBuilder: (context, index) =>
            _buildPaginaMes(index, estadoHoy, theme),
      ),
    );
  }

  /// Arrastra la tira de pastillas hasta que se vea la del mes abierto.
  ///
  /// Va en el fotograma siguiente porque durante el `setState` la pastilla
  /// nueva todavía no está montada y su contexto aún no existe.
  void _traerPastillaALaVista(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || index >= _clavesPastilla.length) return;
      final contexto = _clavesPastilla[index].currentContext;
      if (contexto == null) return;
      Scrollable.ensureVisible(
        contexto,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.5,
      );
    });
  }

  Widget _buildPaginaMes(
      int index, EstadoEstimulacion estadoHoy, ThemeData theme) {
    final mesItem = _meses[index];
    // El año del curso: de septiembre a diciembre es el año en curso; de enero
    // a junio, el siguiente. Preguntar siempre por el año natural de hoy
    // dejaba enero a junio mirando un curso que aún no había empezado.
    final hoy = DateTime.now();
    final anhoDoMes = mesItem.mesCalendario >= 9
        ? (hoy.month >= 9 ? hoy.year : hoy.year - 1)
        : (hoy.month >= 9 ? hoy.year + 1 : hoy.year);
    final estado = widget.store.estadoParaMes(anhoDoMes, mesItem.mesCalendario);

    // La ficha del mes se DESPLAZA. Encogerla hasta caber la dejaba al 80 %,
    // descentrada y con la mitad de abajo cortada: un adulto la lee sentado,
    // y lo que un adulto lee sentado se desplaza (ver PaxinaSenScroll).
    return PaxinaSenScroll(
      desprazarSeNonCabe: true,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceSm,
        vertical: AppTheme.spaceSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Altura acotada a propósito: la tarjeta recorta el centro de
          // interés con un `Flexible`, y un `Flexible` dentro de una columna
          // de altura libre —que es lo que hay dentro de un scroll— revienta.
          SizedBox(
            height: 170,
            child: TarjetaMesCurricular(
              lang: _language,
              mes: mesItem,
              estado: estado,
              esDocente: _esDocente,
              isSelected: true,
            ),
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildMonthDetailCard(mesItem, theme),
          const SizedBox(height: AppTheme.spaceLg),
          _buildActionButtons(mesItem, estadoHoy, theme),
          const SizedBox(height: AppTheme.spaceXl),
        ],
      ),
    );
  }

  /// El estado de HOY, del lado que esta persona lleva.
  ///
  /// Antes celebraba «Dobre Estimulación (Aula + Fogar)». La app no tiene red:
  /// el móvil de una familia no sabe si hubo asamblea, y el de la docente no
  /// sabe lo que pasó en ninguna casa. Las dos casillas solo podían coincidir
  /// si una misma persona marcaba las dos, así que aquello celebraba un
  /// autoinforme. Ahora cada lado ve lo suyo, que es lo único que se mide, y
  /// el puente con el otro lado es la nota que la docente entrega en mano.
  Widget _buildDobleEstimulacionCard(
      EstadoEstimulacion estado, ThemeData theme) {
    final hecho = _esDocente
        ? (estado == EstadoEstimulacion.soloAula ||
            estado == EstadoEstimulacion.dobleEstimulacion)
        : (estado == EstadoEstimulacion.soloHogar ||
            estado == EstadoEstimulacion.dobleEstimulacion);

    final cuenta = _esDocente
        ? widget.store.totalSesionesAula
        : widget.store.totalSesionesHogar;

    final Color cardBg;
    final Color borderColor;
    final String statusText;

    if (hecho) {
      cardBg = const Color(0xFFF0FDF4);
      borderColor = AppTheme.success;
      statusText = _esDocente
          ? (_language == AppLanguage.gl
              ? 'Asemblea feita hoxe. Lembra darlles a nota ás familias.'
              : 'Asamblea hecha hoy. Acuérdate de darles la nota a las familias.')
          : (_language == AppLanguage.gl
              ? 'Xogo feito hoxe na casa. Iso é o que conta.'
              : 'Juego hecho hoy en casa. Eso es lo que cuenta.');
    } else {
      cardBg = Colors.white;
      borderColor = AppTheme.border;
      statusText = _esDocente
          ? (_language == AppLanguage.gl
              ? 'Asembleas rexistradas: $cuenta'
              : 'Asambleas registradas: $cuenta')
          : (_language == AppLanguage.gl
              ? 'Días de xogo na casa: $cuenta'
              : 'Días de juego en casa: $cuenta');
    }

    final esDoble = hecho;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceLg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: borderColor, width: 2),
        boxShadow: AppTheme.shadowCard,
      ),
      child: Row(
        children: [
          const LuaPixel(size: 52),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        (_esDocente ? _tituloHoxeAula : _tituloHoxeFogar)
                            .resolve(_language),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (esDoble) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.star_rounded,
                          color: AppTheme.star, size: 20),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusText,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: esDoble ? FontWeight.w700 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int get _trimestreActual {
    if (_mesSeleccionadoIndex <= 3) return 0;
    if (_mesSeleccionadoIndex <= 6) return 1;
    return 2;
  }

  Widget _buildTrimesterSelector(ThemeData theme) {
    final isGl = _language == AppLanguage.gl;
    final trimestreActual = _trimestreActual;
    final trimestres = [
      (
        nome: isGl ? '1.º Outono' : '1.º Otoño',
        sub: isGl ? 'Set - Dec (320 p.)' : 'Sep - Dic (320 p.)',
        inicioMes: 0,
      ),
      (
        nome: isGl ? '2.º Inverno' : '2.º Invierno',
        sub: isGl ? 'Xan - Mar (240 p.)' : 'Ene - Mar (240 p.)',
        inicioMes: 4,
      ),
      (
        nome: isGl ? '3.º Primavera' : '3.º Primavera',
        sub: isGl ? 'Abr - Xuñ (240 p.)' : 'Abr - Jun (240 p.)',
        inicioMes: 7,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF2F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(3, (i) {
          final t = trimestres[i];
          final isActivo = trimestreActual == i;
          return Expanded(
            child: InkWell(
              onTap: () {
                final targetMes = t.inicioMes;
                _paginas?.animateToPage(
                  targetMes,
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                );
                setState(() => _mesSeleccionadoIndex = targetMes);
                _traerPastillaALaVista(targetMes);
              },
              borderRadius: BorderRadius.circular(9),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
                decoration: BoxDecoration(
                  color: isActivo ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isActivo
                      ? const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        t.nome,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isActivo ? FontWeight.bold : FontWeight.w600,
                          color: isActivo
                              ? AppTheme.primaryInk
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 1),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        t.sub,
                        style: TextStyle(
                          fontSize: 9,
                          color:
                              isActivo ? AppTheme.primary : AppTheme.textMuted,
                          fontWeight:
                              isActivo ? FontWeight.w700 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTrimesterSelector(theme),
        const SizedBox(height: 6),
        SizedBox(
          height: 44,
          child: ListView.separated(
            key: const Key('selector_meses'),
            scrollDirection: Axis.horizontal,
            itemCount: _meses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final mesItem = _meses[index];
              final isSelected = index == _mesSeleccionadoIndex;

              return ChoiceChip(
                key: _clavesPastilla[index],
                label: Text(mesItem.nombreMes.resolve(_language)),
                selected: isSelected,
                onSelected: (selected) {
                  if (!selected) return;
                  // Las pastillas son el atajo para saltar a un mes lejano; el
                  // gesto normal es deslizar la tarjeta. Mueven LA PÁGINA, no un
                  // estado aparte: si cada una llevara su cuenta, la pastilla y la
                  // tarjeta acabarían enseñando meses distintos.
                  _paginas?.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                  );
                  setState(() => _mesSeleccionadoIndex = index);
                  _traerPastillaALaVista(index);
                },
                selectedColor: AppTheme.primary,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? AppTheme.primary : AppTheme.border,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// El conmutador Aula/Fogar, con el mismo patrón que las pestañas de ciclo
  /// de «Juega con Lúa · Aula»: carril gris y pastilla levantada encima. Antes
  /// era una caja blanca con borde y relleno turquesa, que no se parecía a
  /// ningún otro conmutador de la app.
  Widget _buildRoleSwitcher(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(AppTheme.radiusButton),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildRolePill(
              clave: const Key('tab_rol_docente'),
              icono: Icons.school_rounded,
              texto: _rolDocente.resolve(_language),
              activo: _esDocente,
              onTap: () => setState(() => _esDocente = true),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildRolePill(
              clave: const Key('tab_rol_familia'),
              icono: Icons.home_rounded,
              texto: _rolFamilia.resolve(_language),
              activo: !_esDocente,
              onTap: () => setState(() => _esDocente = false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRolePill({
    required Key clave,
    required IconData icono,
    required String texto,
    required bool activo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: clave,
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusField),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: activo ? AppTheme.card : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusField),
          boxShadow: activo
              ? const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              size: 20,
              color: activo ? AppTheme.primaryInk : AppTheme.textMuted,
            ),
            const SizedBox(width: 8),
            // Flexible: «Fogar (Familias)» con su icono no cabe en media
            // pantalla estrecha, ni en gallego ni con el texto grande del
            // sistema. Desbordaba 5 px.
            Flexible(
              child: Text(
                texto,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14.5,
                  fontWeight: activo ? FontWeight.w800 : FontWeight.w600,
                  color: activo ? AppTheme.primaryInk : AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDetailCard(MesCurricular mes, ThemeData theme) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        side: const BorderSide(color: AppTheme.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Aquí NO se repiten el nombre del mes ni el centro de interés:
            // están en la tarjeta que hay justo encima, en la misma página.
            // Salían dos veces con 210 px de por medio, que es la misma
            // duplicación que hacía larga esta pantalla.
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryLight,
                  radius: 24,
                  child: Icon(iconoDeContenido(mes.icono),
                      color: AppTheme.primaryDark, size: 28),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Text(
                    mes.objetivoPedagogico.resolve(_language),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),

            // La frase del mes, y solo la frase.
            //
            // El léxico y las órdenes TPR vivían aquí como una pared de diez
            // pastillas. Eso no lo usa nadie: la docente las necesita DENTRO
            // de la asamblea, en la fase en la que se dicen, y ahí están
            // ahora. La familia necesita una sola frase, la de su rutina.
            Text(
              _fraseKicker.resolve(_language),
              style: theme.textTheme.labelSmall?.copyWith(
                color: BarraInglesFase.acento,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            if (mes.ingles.frase.isNotEmpty)
              BotonEscuchar(
                audioService: widget.audioService,
                texto: mes.ingles.frase,
                language: AppLanguage.en,
                style: estiloIngles(mes.ingles.frase),
                comoChip: true,
                colorChip: BarraInglesFase.acento,
              ),
            const SizedBox(height: 20),

            // Actividad según rol seleccionado
            if (_esDocente) ...[
              TemporizadorSutilWidget(
                minutosMin: 5,
                minutosMax: 8,
                esDocente: true,
                language: _language,
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTint,
                  borderRadius: BorderRadius.circular(AppTheme.radiusField),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.school_outlined,
                            size: 18, color: AppTheme.primaryDark),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _instruccionsBrevesTitulo.resolve(_language),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _instruccionsBrevesCuerpo.resolve(_language),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _buildRoleSection(
                kicker: _aulaKicker.resolve(_language),
                content: mes.actividadAula.resolve(_language),
                badge: _language == AppLanguage.gl
                    ? 'Asemblea (5-8 min)'
                    : 'Asamblea (5-8 min)',
                icon: Icons.groups_rounded,
                color: AppTheme.primaryDark,
                theme: theme,
              ),
              const SizedBox(height: 14),
              _buildMatrizSemanalDocente(mes, theme),
            ] else ...[
              TemporizadorSutilWidget(
                minutosMin: 3,
                minutosMax: mes.minutosSugeridos,
                esDocente: false,
                language: _language,
              ),
              // Aquí iba «Por que importa no desenvolvemento» con el objetivo
              // pedagógico dentro. Es EL MISMO TEXTO que abre esta ficha, dos
              // veces en la misma tarjeta. Se veía menos cuando había 400 px
              // de por medio; no por eso dejaba de estar duplicado.
              const SizedBox(height: 12),
              _buildRoleSection(
                kicker: _hogarKicker.resolve(_language),
                content: mes.actividadHogar.resolve(_language),
                subcontent:
                    '${_language == AppLanguage.gl ? "Momento suxerido" : "Momento sugerido"}: ${mes.rutinaRecomendadaHogar.resolve(_language)}',
                badge: '${mes.minutosSugeridos} min',
                icon: Icons.volunteer_activism_rounded,
                color: AppTheme.warning,
                theme: theme,
              ),
              // Y aquí baja el calendario de las familias hasta el DÍA, que es
              // donde llegaba el del aula y donde se quedaba el de casa: el mes
              // entero no dice qué hacer el martes de la semana 3.
              if (widget.repository != null) ...[
                const SizedBox(height: 12),
                DiaNoFogar(
                  repository: widget.repository!,
                  cursoId: _cursoFogar,
                  // El calendario numera los meses por el orden del CURSO:
                  // setembro es 1. Es el mismo número que usa el banco de días.
                  mes: _mesSeleccionadoIndex + 1,
                  language: _language,
                ),
              ],
              const SizedBox(height: 14),
              _buildMatrizSemanalFogar(mes, theme),
              const SizedBox(height: 12),
              InkWell(
                key: const Key('boton_guia_atencion'),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => GuiaAtencionScreen(
                      initialLanguage: _language,
                      onLanguageChanged: _onToggleLanguage,
                      audioService: widget.audioService,
                      contenido: _contenido,
                    ),
                  ),
                ),
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                child: Container(
                  padding: const EdgeInsets.all(AppTheme.spaceMd),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.psychology_outlined,
                        color: AppTheme.primaryInk,
                        size: 26,
                      ),
                      const SizedBox(width: AppTheme.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _guiaAtencionBoton.resolve(_language),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _guiaAtencionSubtitulo.resolve(_language),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                height: 1.3,
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
            ],
            if (_esDocente) ..._buildAsambleasDoDia(mes),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrizSemanalDocente(MesCurricular mes, ThemeData theme) {
    final isGl = _language == AppLanguage.gl;
    final diasMatriz = [
      (
        dia: isGl ? 'Luns' : 'Lunes',
        blq: isGl ? 'Bloque A (5 novas)' : 'Bloque A (5 nuevas)',
        carga: '5 p.',
        cor: const Color(0xFF3182CE),
      ),
      (
        dia: isGl ? 'Martes' : 'Martes',
        blq: isGl ? 'Bloque B (5 n.) + Repaso A' : 'Bloque B (5 n.) + Repaso A',
        carga: '10 p.',
        cor: const Color(0xFF2B6CB0),
      ),
      (
        dia: isGl ? 'Mércores' : 'Miércoles',
        blq: isGl ? 'Bloque C (5 n.) + Repaso A-B' : 'Bloque C (5 n.) + Repaso A-B',
        carga: '15 p.',
        cor: const Color(0xFF2C5282),
      ),
      (
        dia: isGl ? 'Xoves' : 'Jueves',
        blq: isGl ? 'Bloque D (5 n.) + Repaso A-C' : 'Bloque D (5 n.) + Repaso A-C',
        carga: '20 p.',
        cor: const Color(0xFF1A365D),
      ),
      (
        dia: isGl ? 'Venres' : 'Viernes',
        blq: isGl ? 'Reto Semanal «Freeze» (20 p.)' : 'Reto Semanal «Freeze» (20 p.)',
        carga: '20 p.',
        cor: const Color(0xFF805AD5),
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: const Color(0xFFF7FAFC),
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  size: 20, color: AppTheme.primaryDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGl
                      ? 'RITMO SEMANAL TPR · 5 PALABRAS/DÍA'
                      : 'RITMO SEMANAL TPR · 5 PALABRAS/DÍA',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryDark,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTint,
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  isGl ? '80 p./mes' : '80 p./mes',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isGl
                ? 'Distribución acumulativa segundo MacArthur-Bates & Rescorla. O venres consolida o léxico semanal con xogo sensoriomotriz.'
                : 'Distribución acumulativa según MacArthur-Bates & Rescorla. El viernes consolida el léxico semanal con juego sensoriomotriz.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: diasMatriz.map((d) {
                return Container(
                  width: 115,
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            d.dia,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: d.cor,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: d.cor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              d.carga,
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: d.cor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.blq,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppTheme.textSecondary,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatrizSemanalFogar(MesCurricular mes, ThemeData theme) {
    final isGl = _language == AppLanguage.gl;

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(AppTheme.radiusField),
        border: Border.all(color: const Color(0xFFFDE68A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.volunteer_activism_rounded,
                  size: 20, color: Color(0xFFD97706)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isGl
                      ? 'MICRO-RUTINA FAMILIAR · 3 MINUTOS SEN PANTALLAS'
                      : 'MICRO-RUTINA FAMILIAR · 3 MINUTOS SIN PANTALLAS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFB45309),
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isGl
                ? 'O adulto sostén o dispositivo como partitura. Luns a xoves: modelado motor da orde en inglés. Venres: Gran reto «Freeze» bailando e conxelando o corpo.'
                : 'El adulto sostiene el dispositivo como partitura. Lunes a jueves: modelado motor de la orden en inglés. Viernes: Gran reto «Freeze» bailando y congelando el cuerpo.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF92400E),
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  /// La asamblea del DÍA desde la ficha del mes: semana, día y un botón por
  /// grupo (0-2, 2-3, 4.º, 5.º, 6.º). Antes aquí había un botón por nivel de
  /// 2.º ciclo que abría la asamblea del mes entero; el calendario decía «una
  /// actividad por mes» porque eso era lo que abría.
  List<Widget> _buildAsambleasDoDia(MesCurricular mes) {
    final repo = widget.repository;
    if (repo == null) return const [];
    // Las semanas y los días se llaman igual en todos los tramos; para la tira
    // vale cualquiera de las progresiones que haya en el paquete.
    final progresions = repo.getAllProgresionsSync();
    if (progresions.isEmpty) return const [];
    final referencia = progresions.first;
    final isGl = _language == AppLanguage.gl;

    final grupos = <({String etiqueta, String clave, VoidCallback? abrir})>[];
    for (final tramo in TramoPrimeiroCiclo.values) {
      final a = repo.getAsambleaPrimeiroCicloSync(mes.mesCalendario, tramo);
      grupos.add((
        etiqueta: tramo.etiquetaCorta.resolve(_language),
        clave: '1c_${tramo.clave}',
        abrir: a == null
            ? null
            : () => _abrirDia(
                  clave: 'primeiro_ciclo.${tramo.clave}',
                  fases: a.fases,
                  subtitulo:
                      '${mes.nombreMes.resolve(_language)} · ${tramo.etiquetaCorta.resolve(_language)}',
                  material: a.materialDoMes.resolve(_language),
                  cancion: a.cancionDoMes,
                  centroInteres: a.centroInteres.resolve(_language),
                ),
      ));
    }
    for (final nivel in NivelEducativoSegundoCiclo.values) {
      final a = repo.getAsambleaByMesYNivelSync(mes.mesCalendario, nivel);
      grupos.add((
        etiqueta: nivel.etiquetaCorta.resolve(_language),
        clave: '2c_${nivel.clave}',
        abrir: a == null
            ? null
            : () => _abrirDia(
                  clave: AulaSegundoCicloPanel.claveProgresion(nivel),
                  fases: a.fases,
                  subtitulo:
                      '${mes.nombreMes.resolve(_language)} · ${nivel.etiquetaCorta.resolve(_language)}',
                  centroInteres: a.centroInteres.resolve(_language),
                ),
      ));
    }

    return [
      const SizedBox(height: 16),
      const Divider(height: 1),
      const SizedBox(height: 12),
      Text(
        isGl ? 'A ASEMBLEA DE HOXE' : 'LA ASAMBLEA DE HOY',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
          color: AppTheme.primaryInk,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        isGl
            ? 'Cada día do mes ten a súa asemblea: elixe semana, día e grupo.'
            : 'Cada día del mes tiene su asamblea: elige semana, día y grupo.',
        style: const TextStyle(
          fontSize: 12.5,
          color: AppTheme.textSecondary,
          height: 1.35,
        ),
      ),
      const SizedBox(height: 10),
      TiraDeDias(
        prefixoClave: 'cal',
        progresion: referencia,
        semana: _semana,
        dia: _dia,
        language: _language,
        onCambiar: (s, d) => setState(() {
          _semana = s;
          _dia = d;
        }),
      ),
      const SizedBox(height: 10),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final g in grupos)
            OutlinedButton(
              key: ValueKey('calendario_dia_${mes.mesCalendario}_${g.clave}'),
              onPressed: g.abrir,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, AppTheme.touchMin),
                foregroundColor: AppTheme.primaryInk,
              ),
              child: Text(g.etiqueta),
            ),
        ],
      ),
    ];
  }

  void _abrirDia({
    required String clave,
    required List<FaseAsamblea> fases,
    required String subtitulo,
    String? material,
    String? cancion,
    String? centroInteres,
  }) {
    final progresion = widget.repository?.getProgresionSync(clave);
    final dia = progresion?.dia(_semana, _dia);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AsambleaPlayerScreen(
          fases: dia?.aplicarA(fases) ?? fases,
          subtitulo:
              '$subtitulo${dia != null ? ' · S${dia.semana} ${dia.nomeDia.resolve(_language)}' : ''}',
          material: material,
          cancion: cancion,
          centroInteres: centroInteres,
          audioService: widget.audioService,
          language: _language,
          dia: dia,
          semana: progresion?.semana(_semana),
        ),
      ),
    );
  }

  Widget _buildRoleSection({
    required String kicker,
    required String content,
    String? subcontent,
    required String badge,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
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
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  kicker,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              // La chapa no puede empujar al rótulo fuera de la tarjeta: con
              // el texto grande del sistema, «Asemblea (5-8 min)» sola ya no
              // cabe al lado del rótulo.
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.textPrimary,
              height: 1.4,
            ),
          ),
          if (subcontent != null) ...[
            const SizedBox(height: 6),
            Text(
              subcontent,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      MesCurricular mes, EstadoEstimulacion estado, ThemeData theme) {
    final hoy = DateTime.now();
    final isAulaHecha = estado == EstadoEstimulacion.soloAula ||
        estado == EstadoEstimulacion.dobleEstimulacion;
    final isHogarHecho = estado == EstadoEstimulacion.soloHogar ||
        estado == EstadoEstimulacion.dobleEstimulacion;

    if (_esDocente) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_unidadDe(mes) != null)
            BotonLanzarSesion(
              key: const Key('boton_iniciar_sesion_aula'),
              label: _iniciarAula.resolve(_language),
              icon: Icons.play_circle_filled_rounded,
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              onPressed: () => _lanzarSesion(mes, true),
            )
          else
            _AvisoEnPreparacion(texto: _enPreparacion.resolve(_language)),
          const SizedBox(height: AppTheme.spaceSm),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: const Key('boton_rexistrar_aula'),
              onPressed: () async {
                await widget.store.registrarAula(hoy);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_aulaHecha.resolve(_language)),
                      backgroundColor: AppTheme.success,
                    ),
                  );
                }
              },
              icon: Icon(
                isAulaHecha
                    ? Icons.check_circle_rounded
                    : Icons.check_circle_outline_rounded,
                color: isAulaHecha ? AppTheme.success : AppTheme.primaryDark,
              ),
              label: Text(
                isAulaHecha
                    ? _aulaHecha.resolve(_language)
                    : _marcarAula.resolve(_language),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isAulaHecha ? AppTheme.success : AppTheme.primaryDark,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isAulaHecha ? AppTheme.success : AppTheme.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // La familia no lanza nada: la rutina del mes ya está arriba, en la
          // ficha, con su frase y su altavoz. Aquí solo queda marcar que se
          // hizo. Antes había un botón que abría una cápsula elegida por
          // descarte —siempre la misma— sin relación con el mes.
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              key: const Key('boton_rexistrar_fogar'),
              onPressed: () async {
                await widget.store.toggleHogar(hoy);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isHogarHecho
                            ? (_language == AppLanguage.gl
                                ? 'Rexistro cancelado'
                                : 'Registro deshecho')
                            : _hogarHecho.resolve(_language),
                      ),
                      backgroundColor: isHogarHecho
                          ? AppTheme.textSecondary
                          : AppTheme.success,
                    ),
                  );
                }
              },
              icon: Icon(
                isHogarHecho
                    ? Icons.check_circle_rounded
                    : Icons.volunteer_activism_rounded,
                color:
                    isHogarHecho ? AppTheme.success : const Color(0xFFD97706),
              ),
              label: Text(
                isHogarHecho
                    ? _hogarHecho.resolve(_language)
                    : _marcarHogar.resolve(_language),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color:
                      isHogarHecho ? AppTheme.success : const Color(0xFFD97706),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: isHogarHecho ? AppTheme.success : AppTheme.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusButton),
                ),
              ),
            ),
          ),
        ],
      );
    }
  }
}

/// «Este mes todavía no tiene unidad de aula.»
///
/// Se pinta en lugar del botón de iniciar. Es la diferencia entre un calendario
/// que enseña diez meses y uno que promete diez y abre siempre el mismo.
class _AvisoEnPreparacion extends StatelessWidget {
  final String texto;

  const _AvisoEnPreparacion({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('aviso_mes_en_preparacion'),
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.schedule_rounded,
              size: 18, color: AppTheme.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textMuted, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

/// El arrastre lateral, también con ratón y trackpad.
///
/// `MaterialScrollBehavior` solo admite dedo y lápiz. En un móvil eso basta,
/// pero con un ratón conectado —o en un portátil— la tarjeta del mes no se
/// movía al arrastrarla, y quien lo probaba así concluía que el deslizamiento
/// no existía.
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
