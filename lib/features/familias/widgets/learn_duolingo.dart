import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/imaxe_escena.dart';
import '../../../core/brand/lua_valeria.dart';
import '../../../core/brand/pixel_award.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/localization/localized_string.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/movimiento.dart';
import '../../../data/models/leccion_model.dart';
import '../../criancas/criancas_store.dart';
import '../../criancas/xogo_lua.dart';
import '../../leccions/widgets/proxecto_0_2.dart';
import '../../../data/models/plan_escoita_model.dart';
import 'paso_escoita.dart';

/// La pantalla «Learn» de duolingo-clone, copiada (O-20261109-5).
///
/// Fuente: sanidhyy/duolingo-clone (MIT): `app/(main)/learn/unit-banner.tsx`,
/// `lesson-button.tsx`, `components/user-progress.tsx`, `app/lesson/header.tsx`,
/// `footer.tsx`, `quiz.tsx` y `result-card.tsx`. Mismos colores (green-500 y
/// green-600, neutral-200 y neutral-400, orange-400 y rose-500), el mismo
/// zigzag de 8 nodos, el nodo actual con su anillo y su cartel «Start», la
/// barra de la lección con la X y el botón de abajo, y la pantalla de fin con
/// «Total XP». Lo que cambia: los corazones son la racha, y el premio es Lúa.
class DuoCores {
  // green-500 de la fuente da 2,3:1 con texto blanco y no pasa el gate de
  // contraste (ux_l2): se usa green-700 y green-800, el mismo verde más
  // oscuro, que da 5:1.
  static const verde = Color(0xFF15803D);
  static const verdeBorde = Color(0xFF166534);
  static const verdeClaro = Color(0xFF4ADE80);
  static const bloqueado = Color(0xFFE5E5E5);
  static const bloqueadoBorde = Color(0xFFA3A3A3);
  static const laranxa = Color(0xFFFB923C);
  static const laranxaTexto = Color(0xFFC2410C);
  static const rosa = Color(0xFFF43F5E);
  static const rosaTexto = Color(0xFFBE123C);
  static const trilla = Color(0xFFE5E7EB);
  static const textoVerde = Color(0xFF15803D);
}

/// `user-progress.tsx`: el curso a la izquierda, los puntos y la racha.
class CabeceraLearn extends StatelessWidget {
  final Widget curso;
  final int xp;
  final int racha;
  const CabeceraLearn({
    super.key,
    required this.curso,
    required this.xp,
    required this.racha,
  });

  @override
  Widget build(BuildContext context) => Row(
        key: const Key('learn_cabeceira'),
        children: [
          Flexible(child: curso),
          const SizedBox(width: 8),
          const PixelAward(
              glyph: AwardGlyph.star, tier: AwardTier.gold, size: 26),
          const SizedBox(width: 4),
          Text(
            '$xp',
            key: const Key('learn_xp'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: DuoCores.laranxaTexto,
            ),
          ),
          const SizedBox(width: 12),
          PixelAward(
            glyph: AwardGlyph.flame,
            tier: tierDeRacha(racha),
            size: 24,
            locked: racha == 0,
          ),
          const SizedBox(width: 4),
          Text(
            '$racha',
            key: const Key('learn_racha'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: DuoCores.rosaTexto,
            ),
          ),
        ],
      );
}

/// `unit-banner.tsx`: la caja verde con el título de la unidad y «Continuar».
class BannerUnidade extends StatelessWidget {
  final String titulo;
  final String descricion;
  final String continuar;
  final VoidCallback? onContinuar;
  const BannerUnidade({
    super.key,
    required this.titulo,
    required this.descricion,
    required this.continuar,
    this.onContinuar,
  });

  @override
  Widget build(BuildContext context) => Entrada(
        child: Pulsable(
          child: GestureDetector(
            onTap: onContinuar,
            child: Container(
              key: const Key('learn_banner'),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: DuoCores.verde,
                // O-20261119-7: el verde de siempre, que se oscurece hacia abajo; nunca más claro, para que el blanco pase AA.
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [DuoCores.verde, DuoCores.verdeBorde],
                ),
                borderRadius: BorderRadius.circular(16),
                border: const Border(
                  bottom: BorderSide(color: DuoCores.verdeBorde, width: 4),
                ),
              ),
              child: Stack(
                children: [
                  // Dos lunas de adorno, sin texto ni toque.
                  const Positioned(
                    right: -26,
                    top: -30,
                    child: _Circulo(diametro: 110),
                  ),
                  const Positioned(
                    right: 46,
                    bottom: -38,
                    child: _Circulo(diametro: 70),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 11),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          titulo,
                          style: const TextStyle(
                            fontFamily: AppTheme.fontTitulos,
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          descricion,
                          style: const TextStyle(
                            fontSize: 15.5,
                            height: 1.3,
                            color: Colors.white,
                          ),
                        ),
                        // En la fuente el botón va `hidden ... xl:flex`: en el móvil no
                        // sale, y la caja entera se toca.
                        if (onContinuar != null &&
                            MediaQuery.sizeOf(context).width >= 600) ...[
                          const SizedBox(height: 12),
                          _BotonDuo(
                            key: const Key('learn_banner_continuar'),
                            texto: continuar,
                            fondo: Colors.white,
                            borde: const Color(0xFFD4D4D4),
                            cor: DuoCores.textoVerde,
                            onTap: onContinuar,
                            icono: Icons.menu_book_rounded,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class _Circulo extends StatelessWidget {
  final double diametro;
  const _Circulo({required this.diametro});

  @override
  Widget build(BuildContext context) => Container(
        width: diametro,
        height: diametro,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0x1FFFFFFF),
        ),
      );
}

/// Un botón de Duolingo: color plano con el borde inferior grueso.
class _BotonDuo extends StatelessWidget {
  final String texto;
  final Color fondo;
  final Color borde;
  final Color cor;
  final VoidCallback? onTap;
  final IconData? icono;
  final bool ancho;
  const _BotonDuo({
    super.key,
    required this.texto,
    required this.fondo,
    required this.borde,
    required this.cor,
    required this.onTap,
    this.icono,
    this.ancho = false,
  });

  @override
  Widget build(BuildContext context) {
    final off = onTap == null;
    return Semantics(
      button: true,
      child: Pulsable(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: ancho ? double.infinity : null,
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: off ? DuoCores.bloqueado : fondo,
              borderRadius: BorderRadius.circular(14),
              border: Border(
                bottom: BorderSide(
                  color: off ? DuoCores.bloqueadoBorde : borde,
                  width: 4,
                ),
                top: BorderSide(color: off ? DuoCores.bloqueado : borde),
                left: BorderSide(color: off ? DuoCores.bloqueado : borde),
                right: BorderSide(color: off ? DuoCores.bloqueado : borde),
              ),
            ),
            child: Row(
              mainAxisSize: ancho ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icono != null) ...[
                  Icon(icono, color: off ? Colors.white : cor, size: 20),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    texto.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontTitulos,
                      fontSize: 16,
                      letterSpacing: 0.6,
                      fontWeight: FontWeight.w900,
                      color: off ? Colors.white : cor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum EstadoNodo { feito, actual, bloqueado }

/// `lesson-button.tsx`: los nodos en zigzag. El ciclo de 8 y la sangría de
/// 40 px son los de la fuente; el último lleva corona.
class CaminoNodos extends StatelessWidget {
  final List<String> etiquetas;
  final int actual;
  final bool feitoHoxe;
  final String empezar;
  final ValueChanged<int> onNodo;
  final Widget? lua;

  const CaminoNodos({
    super.key,
    required this.etiquetas,
    required this.actual,
    required this.feitoHoxe,
    required this.empezar,
    required this.onNodo,
    this.lua,
  });

  static double sangria(int i) {
    final c = i % 8;
    final int n;
    if (c <= 2) {
      n = c;
    } else if (c <= 6) {
      n = 4 - c;
    } else {
      n = c - 8;
    }
    return n * 40.0;
  }

  @override
  Widget build(BuildContext context) {
    // O-20261118-1: Lúa va pegada al camino, en el hueco que deja el zigzag
    // al irse a la izquierda (nodos 1-3), no contra el borde de la pantalla.
    return LayoutBuilder(
      builder: (context, c) => SizedBox(
        key: const Key('learn_camino'),
        width: double.infinity,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            if (lua != null)
              Positioned(
                key: const Key('learn_lua'),
                left: c.maxWidth / 2 + 28,
                top: 84,
                // O-20261119-7: Lúa entra, y salta si se la toca.
                child: Entrada(orden: 6, child: SaltoLua(child: lua!)),
              ),
            SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  for (var i = 0; i < etiquetas.length; i++)
                    Padding(
                      padding: EdgeInsets.only(top: i == 0 ? 4 : 1),
                      // `right: ${rightPosition}px` de la fuente. Con relleno y
                      // no con Transform.translate: un nodo trasladado solo al
                      // pintar queda fuera de la caja de su padre y no recibe el
                      // toque (O-20261111-2, B: el miércoles no respondía).
                      child: Padding(
                        padding: EdgeInsets.only(
                          right: sangria(i) > 0 ? 2 * sangria(i) : 0,
                          left: sangria(i) < 0 ? -2 * sangria(i) : 0,
                        ),
                        child: Entrada(
                          orden: i + 1,
                          child: _Nodo(
                            key: ValueKey('learn_nodo_$i'),
                            avance: actual / etiquetas.length,
                            etiqueta: etiquetas[i],
                            estado: i < actual || (i == actual && feitoHoxe)
                                ? EstadoNodo.feito
                                : i == actual
                                    ? EstadoNodo.actual
                                    : EstadoNodo.bloqueado,
                            ultimo: i == etiquetas.length - 1,
                            empezar: empezar,
                            onTap: () => onNodo(i),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nodo extends StatelessWidget {
  final double avance;
  final String etiqueta;
  final EstadoNodo estado;
  final bool ultimo;
  final String empezar;
  final VoidCallback onTap;
  const _Nodo({
    super.key,
    this.avance = 0,
    required this.etiqueta,
    required this.estado,
    required this.ultimo,
    required this.empezar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bloq = estado == EstadoNodo.bloqueado;
    final boton = Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bloq ? DuoCores.bloqueado : DuoCores.verde,
        border: Border(
          bottom: BorderSide(
            color: bloq ? DuoCores.bloqueadoBorde : DuoCores.verdeBorde,
            width: 6,
          ),
        ),
      ),
      child: Icon(
        estado == EstadoNodo.feito
            ? Icons.check_rounded
            : ultimo
                ? Icons.workspace_premium_rounded
                : Icons.star_rounded,
        size: 32,
        color: bloq ? DuoCores.bloqueadoBorde : Colors.white,
      ),
    );
    // O-20261111-2 (B): los cinco nodos responden siempre. Quien los pinta
    // decide si abre la lección o avisa de cuándo se abre; aquí nunca hay un
    // toque mudo. El área de toque cubre el nodo y su etiqueta (≥ 48 px).
    return Semantics(
      button: true,
      label: etiqueta,
      child: Pulsable(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 88, minHeight: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (estado == EstadoNodo.actual)
                  SizedBox(
                    width: 88,
                    height: 116,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          top: 28,
                          child: SizedBox(
                            width: 88,
                            height: 88,
                            // O-20261119-8: el anillo de Valeria, que se
                            // dibuja con lo que va de semana.
                            child: AnilloAvance(
                              valor: avance,
                              tam: 88,
                              fondo: DuoCores.trilla,
                              cor: DuoCores.verdeClaro,
                            ),
                          ),
                        ),
                        // O-20261119-7: el de hoy late, para que se vea qué toca.
                        Positioned(
                          top: 42,
                          child: Halo(cor: DuoCores.verdeClaro, child: boton),
                        ),
                        Positioned(
                          top: 0,
                          child: Flotar(
                            child: Container(
                              key: const Key('learn_empezar'),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: DuoCores.trilla,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                empezar.toUpperCase(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.6,
                                  color: DuoCores.textoVerde,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  boton,
                const SizedBox(height: 2),
                Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: bloq ? AppTheme.textMuted : DuoCores.textoVerde,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Un paso de la lección: lo que hay que enseñar en esa pantalla.
class PasoLeccion {
  final String titulo;
  final String texto;
  final PezaDaLeccion? peza;

  /// O-20261111-1: la escena del reto, con su imagen encima del texto.
  final LocalizedString? escena;

  /// O-20261111-2: las láminas de lo que nombra un paso sin pieza propia
  /// (las palabras nuevas de la semana, la canción): clave y significado.
  final List<({String clave, String significado})> laminas;

  /// O-20261119-8: la actividad de escucha de la semana.
  final PasoEscoita? escoita;
  const PasoLeccion({
    required this.titulo,
    required this.texto,
    this.peza,
    this.escena,
    this.laminas = const [],
    this.escoita,
  });
}

/// Los pasos del día: qué se hace, cada palabra nueva con su voz y la frase.
List<PasoLeccion> pasosDoDia(Leccion l, int dia, AppLanguage lang) {
  final isGl = lang == AppLanguage.gl;
  final d =
      l.dias.isEmpty ? null : l.dias[(dia - 1).clamp(0, l.dias.length - 1)];
  final pezas = l.repaso ? l.repasa : l.novas;
  // O-20261111-2: la lámina de la escena solo va en el paso del reto (el día
  // cuyo inglés es la frase del reto). Los demás días enseñan los dibujos de
  // las palabras de la semana, que son las que ese paso nombra.
  final eReto = d != null && d.en != null && d.en == l.reto.frase.en;
  final escena = eReto && l.escena.resolve(lang).isNotEmpty ? l.escena : null;
  final daSemana = [
    for (final p in pezas)
      if (p.lamina case final c?)
        (clave: c, significado: p.significado?.resolve(lang) ?? p.en),
  ];
  return [
    if (d != null)
      PasoLeccion(
        titulo: d.dia.resolve(lang),
        texto: d.texto.resolve(lang),
        escena: escena,
        laminas: escena == null ? daSemana : const [],
      ),
    for (final p in pezas)
      if (p.en.isNotEmpty)
        PasoLeccion(
          titulo: isGl
              ? 'Escoita e repite con xesto'
              : 'Escucha y repite con gesto',
          texto: p.xesto?.resolve(lang) ?? '',
          peza: p,
        ),
    if (l.fraseGramatica case final f?)
      PasoLeccion(
        titulo: isGl ? 'A frase da semana' : 'La frase de la semana',
        texto: '',
        peza: f,
      ),
    if (PasoEscoita.para(l.id, PlanEscoita.lido) case final e?)
      PasoLeccion(titulo: e.titulo(lang), texto: '', escoita: e),
  ];
}

/// Los pasos de 0-2 (ACOPROS): las cinco palabras de la semana con su gesto,
/// la canción y la rima tradicional. Sin frase de gramática.
List<PasoLeccion> pasosDoProxecto(Proxecto02 p, int semana, AppLanguage lang) {
  final isGl = lang == AppLanguage.gl;
  return [
    for (final w in p.daSemana(semana))
      PasoLeccion(
        titulo: isGl ? 'Escoita e fai o xesto' : 'Escucha y haz el gesto',
        texto: w.xesto.resolve(lang),
        peza: PezaDaLeccion(
          tipo: 'palabra',
          en: w.en,
          significado: w.significado,
          lamina: w.lamina,
        ),
      ),
    PasoLeccion(
      titulo: isGl ? 'A canción do proxecto' : 'La canción del proyecto',
      texto: '«${p.cancion.resolve(lang)}»',
      laminas: [
        if (p.cancionLamina case final c?)
          (clave: c, significado: p.cancion.resolve(lang)),
      ],
    ),
    PasoLeccion(
      titulo: isGl ? 'Rima tradicional' : 'Rima tradicional',
      texto: '',
      peza: PezaDaLeccion(
        tipo: 'frase',
        en: p.rimaEn,
        significado: p.rima,
        lamina: p.rimaLamina,
      ),
    ),
  ];
}

/// `app/lesson`: la X, la barra de progreso, un paso por pantalla y el botón
/// «Continuar» abajo. Al final, `quiz.tsx`: «¡Muy bien! Lección completada»
/// con las tarjetas de XP y de racha, y Lúa.
class LeccionDuolingoScreen extends StatefulWidget {
  final List<PasoLeccion> pasos;
  final AppLanguage language;
  final OfflineAudioService? audioService;
  final CriancasStore? store;
  final Crianza? crianza;
  final String semana;
  final List<String> palabrasDaSemana;
  final DateTime? agora;

  const LeccionDuolingoScreen({
    super.key,
    required this.pasos,
    required this.language,
    required this.semana,
    required this.palabrasDaSemana,
    this.audioService,
    this.store,
    this.crianza,
    this.agora,
  });

  @override
  State<LeccionDuolingoScreen> createState() => _LeccionDuolingoScreenState();
}

class _LeccionDuolingoScreenState extends State<LeccionDuolingoScreen> {
  int _i = 0;
  RecompensaLua? _r;
  bool _fin = false;

  Future<void> _continuar() async {
    if (_i < widget.pasos.length - 1) {
      setState(() => _i++);
      return;
    }
    final c = CatalogoLua.lido ?? await CatalogoLua.cargar();
    RecompensaLua? r;
    if (widget.store case final s?) {
      if (widget.crianza case final n?) {
        r = await s.xogarHoxe(
          n.id,
          c,
          agora: widget.agora ?? DateTime.now(),
          semana: widget.semana,
          palabrasDaSemana: widget.palabrasDaSemana,
        );
      }
    }
    if (mounted) {
      setState(() {
        _r = r;
        _fin = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final total = widget.pasos.isEmpty ? 1 : widget.pasos.length;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // header.tsx: la X, la barra y la racha.
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    key: const Key('leccion_pechar'),
                    tooltip: isGl ? 'Saír' : 'Salir',
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFF64748B),
                      size: 28,
                    ),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      // O-20261119-7: la barra corre hasta su sitio.
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: _fin ? 1 : (_i + 1) / total),
                        duration: movimientoQuieto(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 450),
                        curve: Curves.easeOutCubic,
                        builder: (context, v, _) => LinearProgressIndicator(
                          key: const Key('leccion_progreso'),
                          value: v,
                          minHeight: 16,
                          backgroundColor: DuoCores.trilla,
                          color: DuoCores.verde,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _Transicion(
                clave: _fin ? -1 : _i,
                child: _fin
                    ? _Fin(r: _r, lang: lang, nome: widget.crianza?.nome)
                    : _PasoVista(
                        paso: widget.pasos.isEmpty
                            ? const PasoLeccion(titulo: '', texto: '')
                            : widget.pasos[_i],
                        lang: lang,
                        audioService: widget.audioService,
                      ),
              ),
            ),
            // footer.tsx: la franja de abajo con el botón.
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: DuoCores.trilla, width: 2),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: _BotonDuo(
                key: const Key('leccion_continuar'),
                texto: isGl ? 'Continuar' : 'Continuar',
                fondo: DuoCores.verde,
                borde: DuoCores.verdeBorde,
                cor: Colors.white,
                ancho: true,
                onTap:
                    _fin ? () => Navigator.of(context).maybePop() : _continuar,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// O-20261119-7: cada paso entra por la derecha y el anterior se va por la
/// izquierda, como al pasar página. Con movimiento reducido, el paso cambia
/// sin más.
class _Transicion extends StatelessWidget {
  final int clave;
  final Widget child;
  const _Transicion({required this.clave, required this.child});

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return child;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, a) {
        final entra = child.key == ValueKey(clave);
        final desde = Offset(entra ? 0.35 : -0.35, 0);
        return FadeTransition(
          opacity: a,
          child: SlideTransition(
            position: Tween(begin: desde, end: Offset.zero).animate(a),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(clave), child: child),
    );
  }
}

class _PasoVista extends StatelessWidget {
  final PasoLeccion paso;
  final AppLanguage lang;
  final OfflineAudioService? audioService;
  const _PasoVista({
    required this.paso,
    required this.lang,
    required this.audioService,
  });

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('leccion_paso'),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        children: [
          Text(
            paso.titulo,
            style: const TextStyle(
              fontSize: 24,
              fontFamily: AppTheme.fontTitulos,
              fontWeight: FontWeight.w900,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 24),
          if (paso.laminas.isNotEmpty) ...[
            Entrada(
              orden: 2,
              child: Wrap(
                key: const Key('leccion_paso_laminas'),
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final l in paso.laminas)
                    LaminaPalabra(
                      clave: l.clave,
                      significado: l.significado,
                      lang: lang,
                      ancho: paso.laminas.length == 1 ? 240 : 104,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (paso.peza case final p?) ...[
            if (p.lamina case final c?) ...[
              Entrada(
                orden: 2,
                child: Center(
                  child: LaminaPalabra(
                    clave: c,
                    significado: p.significado?.resolve(lang) ?? p.en,
                    lang: lang,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Center(
              child: BotonEscuchar(
                audioService: audioService,
                texto: p.en,
                language: AppLanguage.en,
                interfaz: lang,
                style: estiloIngles(p.en),
                comoChip: true,
                colorChip: DuoCores.verde,
                descripcion: p.en,
                significado: p.significado,
              ),
            ),
            if (p.significado case final s?) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(
                  s.resolve(lang),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
          if (paso.escena case final e?) ...[
            Entrada(
              orden: 2,
              child: ImaxeEscena(escena: e, lang: lang, ancho: 260),
            ),
            const SizedBox(height: 8),
            Text(
              e.resolve(lang),
              key: const Key('leccion_paso_escena'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (paso.escoita case final e?)
            VistaPasoEscoita(paso: e, lang: lang, audioService: audioService),
          if (paso.texto.isNotEmpty)
            Text(
              paso.texto,
              style: const TextStyle(
                fontSize: 18,
                height: 1.4,
                color: AppTheme.textPrimary,
              ),
            ),
        ],
      );
}

class _Fin extends StatelessWidget {
  final RecompensaLua? r;
  final AppLanguage lang;
  final String? nome;
  const _Fin({required this.r, required this.lang, required this.nome});

  @override
  Widget build(BuildContext context) {
    final isGl = lang == AppLanguage.gl;
    final c = CatalogoLua.lido;
    final lista = ListView(
      key: const Key('leccion_fin'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        // O-20261119-7: Lúa salta de alegría al llegar, y otra vez si se la
        // toca.
        if (r?.xaXogouHoxe != true)
          Estrelas(
            estrela: (t) => PixelAward(
              glyph: AwardGlyph.star,
              tier: AwardTier.gold,
              size: t,
            ),
          ),
        const SizedBox(height: 6),
        const Center(
          child: SaltoLua(
            alEntrar: true,
            child: LuaValeria(ancho: 120, cara: CaraLua.love),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          r?.xaXogouHoxe == true
              ? (isGl
                  ? 'Xa xogastes hoxe.\nMañá máis!'
                  : 'Ya jugasteis hoy.\n¡Mañana más!')
              : (isGl
                  ? 'Moi ben${nome == null ? '' : ', $nome'}!\nLección completada.'
                  : '¡Muy bien${nome == null ? '' : ', $nome'}!\nLección completada.'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppTheme.fontTitulos,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 20),
        Entrada(
          orden: 2,
          child: Row(
            children: [
              Expanded(
                child: _Resultado(
                  key: const Key('leccion_fin_xp'),
                  titulo: 'Total XP',
                  valor: r?.xpGanado ?? 0,
                  cor: DuoCores.laranxa,
                  texto: DuoCores.laranxaTexto,
                  icono: AwardGlyph.star,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // Donde duolingo-clone pone los corazones, la racha.
                child: _Resultado(
                  key: const Key('leccion_fin_racha'),
                  titulo: isGl ? 'Racha' : 'Racha',
                  valor: r?.racha ?? 0,
                  cor: DuoCores.rosa,
                  texto: DuoCores.rosaTexto,
                  icono: AwardGlyph.flame,
                ),
              ),
            ],
          ),
        ),
        if (r != null && c != null) ...[
          const SizedBox(height: 12),
          Text(
            'Nivel ${r!.nivel} · ${c.nomeNivel(r!.nivel).resolve(lang)}',
            key: const Key('leccion_fin_nivel'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          for (final i in r!.insigniasNovas) ...[
            const SizedBox(height: 14),
            Entrada(
              orden: 4,
              desde: 30,
              child: Center(
                child: Latido(
                  escala: 1.1,
                  child: PixelAward(glyph: i.glyph, tier: i.tier, size: 48),
                ),
              ),
            ),
            Text(
              i.nome.resolve(lang),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          for (final o in r!.obxectosNovos) ...[
            const SizedBox(height: 14),
            Center(child: ObxectoLuaIcona(id: o.id, alto: 26)),
            Text(
              '${isGl ? 'Novo para Lúa' : 'Nuevo para Lúa'}: ${o.nome.resolve(lang)}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ],
      ],
    );
    // Confeti propio por encima, solo si la lección se acaba de completar.
    if (r?.xaXogouHoxe == true) return lista;
    return Stack(
      children: [
        lista,
        const Positioned.fill(child: Confeti(cores: coresCelebracion)),
      ],
    );
  }
}

/// `result-card.tsx`: la cabecera de color y el valor dentro.
class _Resultado extends StatelessWidget {
  final String titulo;
  final int valor;
  final Color cor;
  final Color texto;
  final AwardGlyph icono;
  const _Resultado({
    super.key,
    required this.titulo,
    required this.valor,
    required this.cor,
    required this.texto,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: cor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cor, width: 2),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                titulo.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PixelAward(glyph: icono, tier: AwardTier.gold, size: 26),
                  const SizedBox(width: 8),
                  ContadorAnimado(
                    valor: valor,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: texto,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
}

/// Abre la lección de [dia] a pantalla completa.
void abrirLeccionDuolingo(
  BuildContext context, {
  required Leccion leccion,
  required int dia,
  required AppLanguage language,
  required String semana,
  String cursoId = '',
  int mesCalendario = 0,
  int semanaN = 1,
  OfflineAudioService? audioService,
  CriancasStore? store,
  Crianza? crianza,
  DateTime? agora,
}) {
  final proxecto =
      cursoId == 'curso_0_2' ? Proxectos02.lidos?.doMes(mesCalendario) : null;
  Navigator.of(context).push(
    RutaLua(
      de: context,
      builder: (_) => LeccionDuolingoScreen(
        pasos: proxecto != null
            ? pasosDoProxecto(proxecto, semanaN, language)
            : pasosDoDia(leccion, dia, language),
        language: language,
        audioService: audioService,
        store: store,
        crianza: crianza,
        semana: semana,
        palabrasDaSemana: proxecto != null
            ? [for (final w in proxecto.daSemana(semanaN)) w.en]
            : [
                for (final p in leccion.novas)
                  if (p.en.isNotEmpty) p.en,
              ],
        agora: agora,
      ),
    ),
  );
}
