import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lua_pixel.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/paxina_sen_scroll.dart';
import '../../../data/models/capsula_model.dart';
import '../../premios/premios_model.dart';
import '../../premios/premios_repository.dart';
import '../widgets/academy_header.dart';
import '../widgets/selector_idioma_widget.dart';

/// El lector de una cápsula, portado del proyecto anterior de la casa
/// (`docs/screenshots/29-academy-lector.png` y `30-academy-quiz.png`).
///
/// El cambio de fondo respecto a lo que había: **va paginado**. Antes era un
/// scroll larguísimo con las cuatro secciones y la reflexión abajo del todo.
/// El proyecto anterior de la casa presenta una idea por pantalla, con puntos de progreso arriba y un
/// botón grande abajo, y eso no es estética: una familia lee esto en cinco
/// minutos robados, y una pantalla con una sola idea se puede terminar.
///
/// La cápsula cuenta como LEÍDA cuando se responde a todas las afirmaciones,
/// no al abrirla. Abrir y salir no es leer, y un contador que premie eso mide
/// otra cosa distinta de la que dice medir.
class CapsulaDetailScreen extends StatefulWidget {
  final Capsula capsula;
  final AppLanguage initialLanguage;
  final ValueChanged<AppLanguage>? onLanguageChanged;

  /// Opcional: sin repositorio la cápsula se lee igual y no cuenta nada.
  final PremiosRepository? premios;

  /// Opcional: sin él la cápsula se lee, pero no se escucha. Una familia lee
  /// esto en casa muchas veces con las manos ocupadas.
  final OfflineAudioService? audioService;

  const CapsulaDetailScreen({
    super.key,
    required this.capsula,
    this.initialLanguage = AppLanguage.gl,
    this.onLanguageChanged,
    this.premios,
    this.audioService,
  });

  @override
  State<CapsulaDetailScreen> createState() => _CapsulaDetailScreenState();
}

class _CapsulaDetailScreenState extends State<CapsulaDetailScreen> {
  late AppLanguage _language;
  final Map<String, bool?> _userAnswers = {};
  final PageController _pages = PageController();
  int _pagina = 0;

  /// Para no contar la misma cápsula dos veces si alguien cambia una respuesta.
  bool _yaContada = false;

  static const _siguiente = LocalizedString(gl: 'Seguinte', es: 'Siguiente');
  static const _terminar = LocalizedString(gl: 'Rematar', es: 'Terminar');
  static const _atras = LocalizedString(gl: 'Atrás', es: 'Atrás');

  static const _reflexion = LocalizedString(
    gl: 'PARA PENSAR',
    es: 'PARA PENSAR',
  );

  static const _luaDi = LocalizedString(
    gl: 'LÚA DI',
    es: 'LÚA DICE',
  );
  static const _verdadero = LocalizedString(gl: 'Verdadeiro', es: 'Verdadero');
  static const _falso = LocalizedString(gl: 'Falso', es: 'Falso');

  static const _pendiente = LocalizedString(
    gl: 'Escolle unha resposta para continuar.',
    es: 'Elige una respuesta para continuar.',
  );

  /// Las cuatro secciones canónicas, con su antetítulo y su icono.
  bool get _esDeAula =>
      widget.capsula.destinatario == DestinatarioCapsula.docente;

  List<_Seccion> get _secciones {
    final c = widget.capsula;
    final esDeAula = _esDeAula;
    return [
      _Seccion(
        icono: Icons.lightbulb_outline,
        kicker: const LocalizedString(gl: 'A IDEA', es: 'LA IDEA'),
        titulo: const LocalizedString(
          gl: 'A idea clave',
          es: 'La idea clave',
        ),
        cuerpo: c.ideaClave,
      ),
      _Seccion(
        icono: Icons.psychology_outlined,
        kicker: const LocalizedString(gl: 'POR QUE', es: 'POR QUÉ'),
        titulo: const LocalizedString(
          gl: 'Por que importa',
          es: 'Por qué importa',
        ),
        cuerpo: c.porQueImporta,
      ),
      // La tercera sección es el mismo campo del JSON en los dos casos, pero
      // NO el mismo encabezado: a una maestra en su aula no se le dice «qué
      // hacer en casa». Es lo único que cambia entre una cápsula de Academy y
      // una del aula; el resto de la estructura es idéntico, y por eso no hay
      // dos modelos ni dos pantallas.
      _Seccion(
        icono: esDeAula ? Icons.groups_outlined : Icons.home_outlined,
        kicker: esDeAula
            ? const LocalizedString(gl: 'NA ASEMBLEA', es: 'EN LA ASAMBLEA')
            : const LocalizedString(gl: 'NA CASA', es: 'EN CASA'),
        titulo: esDeAula
            ? const LocalizedString(
                gl: 'Que facer na asemblea',
                es: 'Qué hacer en la asamblea',
              )
            : const LocalizedString(
                gl: 'Que facer na casa',
                es: 'Qué hacer en casa',
              ),
        cuerpo: c.queHacerEnCasa,
      ),
      _Seccion(
        icono: Icons.wb_sunny_outlined,
        kicker: const LocalizedString(gl: 'UN EXEMPLO', es: 'UN EJEMPLO'),
        titulo: esDeAula
            ? const LocalizedString(
                gl: 'Unha asemblea calquera',
                es: 'Una asamblea cualquiera',
              )
            : const LocalizedString(
                gl: 'Un momento calquera',
                es: 'Un momento cualquiera',
              ),
        cuerpo: c.ejemploCotidiano,
      ),
    ];
  }

  /// La cápsula termina con Lúa cuando el contenido la trae.
  ///
  /// Va la ÚLTIMA, después de las afirmaciones, y no antes: la cápsula se
  /// cuenta como leída al responder la última afirmación, así que el premio
  /// cae primero y la gata cierra. Al revés, Lúa despediría una cápsula que
  /// todavía no está terminada.
  bool get _tieneCierreDeLua => widget.capsula.luaDice != null;

  int get _totalPaginas =>
      _secciones.length +
      widget.capsula.afirmaciones.length +
      (_tieneCierreDeLua ? 1 : 0);

  @override
  void initState() {
    super.initState();
    _language = widget.initialLanguage;
  }

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onToggleLanguage(AppLanguage newLang) {
    setState(() => _language = newLang);
    widget.onLanguageChanged?.call(newLang);
  }

  /// Cuenta la cápsula cuando ya se respondió a todas sus afirmaciones.
  Future<void> _contarSiEstaLeida() async {
    if (_yaContada) return;
    final afirmaciones = widget.capsula.afirmaciones;
    if (afirmaciones.isEmpty) return;
    if (!afirmaciones.every((a) => _userAnswers[a.id] != null)) return;

    _yaContada = true;
    // La cápsula cuenta para QUIEN la lee. Una cápsula del aula la lee la
    // maestra, así que suma a su recorrido y a su racha, no al de la familia.
    //
    // Reutiliza el contador `capsulas` que ya existe para los dos perfiles: no
    // se guarda ninguna clave nueva, así que esto NO cambia lo que la app
    // almacena ni obliga a tocar la política de privacidad. Lo que sí queda sin
    // premiar es una insignia propia de cápsula docente: las tres de cápsula
    // del catálogo son de familia, y no me invento insignias.
    final nuevas = await widget.premios?.registrar(
          _esDeAula ? Perfil.docente : Perfil.familia,
          EventoPremio.capsula,
        ) ??
        const <Insignia>[];

    if (!mounted || nuevas.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _language == AppLanguage.gl
              ? 'Gañaches: ${nuevas.first.titulo.gl}'
              : 'Ganaste: ${nuevas.first.titulo.es}',
        ),
      ),
    );
  }

  void _avanzar() {
    if (_pagina >= _totalPaginas - 1) {
      Navigator.of(context).pop();
      return;
    }
    _pages.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  /// En una página de reflexión no se avanza sin responder: si se pudiera,
  /// la cápsula se terminaría sin haberla leído y el contador mediría otra cosa.
  bool get _puedeAvanzar {
    final indice = _pagina - _secciones.length;
    if (indice < 0) return true;
    // El cierre de Lúa va detrás de la última afirmación y no pide nada. Sin
    // esta línea, la página de la gata se salía de la lista de afirmaciones.
    if (indice >= widget.capsula.afirmaciones.length) return true;
    final afirmacion = widget.capsula.afirmaciones[indice];
    return _userAnswers[afirmacion.id] != null;
  }

  @override
  Widget build(BuildContext context) {
    final lang = _language;
    final capsula = widget.capsula;
    final secciones = _secciones;
    final esUltima = _pagina >= _totalPaginas - 1;

    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppTheme.spaceMd),
            child: SelectorIdiomaWidget(
              currentLanguage: _language,
              onLanguageChanged: _onToggleLanguage,
              compact: true,
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pages,
              // Solo se navega con los botones: un deslizamiento accidental
              // saltaría una reflexión sin responder.
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalPaginas,
              onPageChanged: (i) => setState(() => _pagina = i),
              itemBuilder: (context, i) {
                final indiceAfirmacion = i - secciones.length;
                final esCierreDeLua =
                    indiceAfirmacion >= capsula.afirmaciones.length;

                final String kicker;
                if (i < secciones.length) {
                  kicker = secciones[i].kicker.resolve(lang);
                } else if (esCierreDeLua) {
                  kicker = _luaDi.resolve(lang);
                } else {
                  kicker = _reflexion.resolve(lang);
                }

                // La cabecera va DENTRO del scroll de cada página, no fija
                // arriba. Con la cabecera fija más el pie de botones, a escala
                // de texto 1,8 no queda altura para el contenido y la pantalla
                // desborda: lo cazó el test de escala, no un aparato. A escala
                // normal se ve igual que la del proyecto anterior de la casa; a escala grande, se
                // desplaza en vez de cortarse.
                final cabecera = AcademyHeader(
                  kicker: kicker,
                  titulo: capsula.titulo.resolve(lang),
                  pasos: _totalPaginas,
                  pasoActual: i,
                );
                if (i < secciones.length) {
                  return _PaginaSeccion(
                    seccion: secciones[i],
                    lang: lang,
                    cabecera: cabecera,
                    audioService: widget.audioService,
                  );
                }
                if (esCierreDeLua) {
                  return _PaginaLua(
                    cabecera: cabecera,
                    texto: capsula.luaDice!,
                    lang: lang,
                    audioService: widget.audioService,
                  );
                }
                final afirmacion = capsula.afirmaciones[indiceAfirmacion];
                return _PaginaReflexion(
                  cabecera: cabecera,
                  afirmacion: afirmacion,
                  lang: lang,
                  audioService: widget.audioService,
                  numero: i - secciones.length + 1,
                  total: capsula.afirmaciones.length,
                  respuesta: _userAnswers[afirmacion.id],
                  verdadero: _verdadero.resolve(lang),
                  falso: _falso.resolve(lang),
                  onResponder: (valor) {
                    setState(() => _userAnswers[afirmacion.id] = valor);
                    _contarSiEstaLeida();
                  },
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!_puedeAvanzar)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppTheme.spaceSm),
                      child: Text(
                        _pendiente.resolve(lang),
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppTheme.textMuted),
                      ),
                    ),
                  Row(
                    children: [
                      if (_pagina > 0) ...[
                        OutlinedButton(
                          onPressed: () => _pages.previousPage(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOut,
                          ),
                          child: Text(_atras.resolve(lang)),
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _puedeAvanzar ? _avanzar : null,
                          child: Text(
                            esUltima
                                ? _terminar.resolve(lang)
                                : _siguiente.resolve(lang),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Seccion {
  final IconData icono;
  final LocalizedString kicker;
  final LocalizedString titulo;
  final LocalizedString cuerpo;

  const _Seccion({
    required this.icono,
    required this.kicker,
    required this.titulo,
    required this.cuerpo,
  });
}

/// Una idea por pantalla, con su cabecera dentro del scroll.
class _PaginaSeccion extends StatelessWidget {
  final _Seccion seccion;
  final AppLanguage lang;
  final Widget cabecera;
  final OfflineAudioService? audioService;

  const _PaginaSeccion({
    required this.seccion,
    required this.lang,
    required this.cabecera,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PaxinaSenScroll(
      child: Column(
        children: [
          cabecera,
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      seccion.icono,
                      color: AppTheme.primaryInk,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  Text(
                    seccion.titulo.resolve(lang),
                    textAlign: TextAlign.center,
                    style: text.titleLarge,
                  ),
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    seccion.cuerpo.resolve(lang),
                    textAlign: TextAlign.center,
                    style:
                        text.bodyLarge?.copyWith(color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  BotonEscuchar(
                    audioService: audioService,
                    texto: seccion.cuerpo.resolve(lang),
                    language: lang,
                    descripcion: seccion.titulo.resolve(lang),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// El cierre: Lúa convierte la cápsula en un gesto para hoy.
///
/// Es la ÚNICA pantalla de Academy en la que aparece la gata dentro de la
/// lectura, y aparece al final por una razón: la familia acaba de leer cuatro
/// pantallas de por qué, y lo que se lleva a la cocina es una sola cosa que
/// hacer. Quien lee esto es la persona adulta —la criatura no usa la pantalla—,
/// así que Lúa le habla a ella, no a la criatura.
///
/// La gata se pinta desde la MISMA rejilla que el icono del lanzador
/// (`assets/brand/lua_sit.txt`), no desde un PNG aparte: si alguien cambia la
/// rejilla, cambian las dos a la vez.
class _PaginaLua extends StatelessWidget {
  final Widget cabecera;
  final LocalizedString texto;
  final AppLanguage lang;
  final OfflineAudioService? audioService;

  const _PaginaLua({
    required this.cabecera,
    required this.texto,
    required this.lang,
    this.audioService,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PaxinaSenScroll(
      child: Column(
        children: [
          cabecera,
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              decoration: BoxDecoration(
                // Fondo y borde distintos de las cuatro tarjetas blancas: esto
                // no es una quinta sección, es quien te lo cuenta.
                color: AppTheme.primaryTint,
                borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                border: Border.all(color: AppTheme.borderActive),
              ),
              child: Column(
                children: [
                  // Cuadrado de lado fijo y centrado: no hay texto al lado que
                  // pueda empujarlo, así que no puede desbordar a lo ancho por
                  // mucho que crezca la escala de texto del sistema.
                  const LuaPixel(pose: LuaPose.sit, size: 104),
                  const SizedBox(height: AppTheme.spaceLg),
                  Text(
                    texto.resolve(lang),
                    textAlign: TextAlign.center,
                    style: text.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),
                  BotonEscuchar(
                    audioService: audioService,
                    texto: texto.resolve(lang),
                    language: lang,
                    descripcion: lang == AppLanguage.gl
                        ? 'o que di Lúa'
                        : 'lo que dice Lúa',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Una afirmación por pantalla, con sus dos opciones y su explicación.
class _PaginaReflexion extends StatelessWidget {
  final Widget cabecera;
  final Afirmacion afirmacion;
  final AppLanguage lang;
  final OfflineAudioService? audioService;
  final int numero;
  final int total;
  final bool? respuesta;
  final String verdadero;
  final String falso;
  final ValueChanged<bool> onResponder;

  const _PaginaReflexion({
    required this.cabecera,
    required this.afirmacion,
    required this.lang,
    this.audioService,
    required this.numero,
    required this.total,
    required this.respuesta,
    required this.verdadero,
    required this.falso,
    required this.onResponder,
  });

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final acertada = respuesta == afirmacion.esVerdadera;

    return PaxinaSenScroll(
      child: Column(
        children: [
          cabecera,
          Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '$numero / $total',
                  style: text.bodySmall?.copyWith(
                    color: AppTheme.textMuted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        afirmacion.enunciado.resolve(lang),
                        style: text.titleMedium,
                      ),
                    ),
                    BotonEscuchar(
                      audioService: audioService,
                      texto: afirmacion.enunciado.resolve(lang),
                      language: lang,
                      compacto: true,
                      descripcion: lang == AppLanguage.gl
                          ? 'a afirmación'
                          : 'la afirmación',
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceXl),
                _Opcion(
                  etiqueta: verdadero,
                  elegida: respuesta == true,
                  onTap: () => onResponder(true),
                ),
                const SizedBox(height: AppTheme.spaceMd),
                _Opcion(
                  etiqueta: falso,
                  elegida: respuesta == false,
                  onTap: () => onResponder(false),
                ),
                if (respuesta != null) ...[
                  const SizedBox(height: AppTheme.spaceXl),
                  // Formativo y NO punitivo. Quien lee esto es una madre o un
                  // padre aprendiendo, no alguien a quien se examina: una
                  // respuesta que no coincide se aclara, no se marca en rojo.
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spaceLg),
                    decoration: BoxDecoration(
                      color:
                          acertada ? AppTheme.successBg : AppTheme.primaryTint,
                      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                      border: Border.all(
                        color:
                            acertada ? AppTheme.success : AppTheme.borderActive,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          acertada
                              ? Icons.check_circle_outline
                              : Icons.info_outline,
                          color:
                              acertada ? AppTheme.success : AppTheme.primaryInk,
                          size: 22,
                        ),
                        const SizedBox(width: AppTheme.spaceMd),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                afirmacion.explicacion.resolve(lang),
                                style: text.bodyMedium,
                              ),
                              BotonEscuchar(
                                audioService: audioService,
                                texto: afirmacion.explicacion.resolve(lang),
                                language: lang,
                                compacto: true,
                                descripcion: lang == AppLanguage.gl
                                    ? 'a explicación'
                                    : 'la explicación',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta blanca de opción, como en `30-academy-quiz.png`.
class _Opcion extends StatelessWidget {
  final String etiqueta;
  final bool elegida;
  final VoidCallback onTap;

  const _Opcion({
    required this.etiqueta,
    required this.elegida,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: elegida ? AppTheme.primaryLight : AppTheme.card,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppTheme.touchMin),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceXl,
            vertical: AppTheme.spaceLg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: elegida ? AppTheme.primary : AppTheme.border,
              width: elegida ? 2 : 1,
            ),
          ),
          child: Text(
            etiqueta,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
      ),
    );
  }
}
