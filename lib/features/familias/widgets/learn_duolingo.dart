import 'package:flutter/material.dart';

import '../../../core/audio/offline_audio_service.dart';
import '../../../core/audio/voice_id.dart';
import '../../../core/audio/widgets/boton_escuchar.dart';
import '../../../core/brand/lua_valeria.dart';
import '../../../core/brand/pixel_award.dart';
import '../../../core/localization/app_language.dart';
import '../../../core/navigation/ruta_lua.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/leccion_model.dart';
import '../../criancas/criancas_store.dart';
import '../../criancas/xogo_lua.dart';

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
  const CabeceraLearn(
      {super.key, required this.curso, required this.xp, required this.racha});

  @override
  Widget build(BuildContext context) => Row(
        key: const Key('learn_cabeceira'),
        children: [
          Flexible(child: curso),
          const SizedBox(width: 8),
          const PixelAward(
              glyph: AwardGlyph.star, tier: AwardTier.gold, size: 26),
          const SizedBox(width: 4),
          Text('$xp',
              key: const Key('learn_xp'),
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: DuoCores.laranxaTexto)),
          const SizedBox(width: 12),
          PixelAward(
              glyph: AwardGlyph.flame,
              tier: tierDeRacha(racha),
              size: 24,
              locked: racha == 0),
          const SizedBox(width: 4),
          Text('$racha',
              key: const Key('learn_racha'),
              style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: DuoCores.rosaTexto)),
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
  Widget build(BuildContext context) => Container(
        key: const Key('learn_banner'),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: DuoCores.verde,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo,
                style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text(descricion,
                style: const TextStyle(
                    fontSize: 15.5, height: 1.3, color: Colors.white)),
            if (onContinuar != null) ...[
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
                  color: off ? DuoCores.bloqueadoBorde : borde, width: 4),
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
                child: Text(texto.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w900,
                        color: off ? Colors.white : cor)),
              ),
            ],
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
    return SizedBox(
      key: const Key('learn_camino'),
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          if (lua != null) Positioned(right: 4, top: 90, child: lua!),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < etiquetas.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 36 : 22),
                  child: Transform.translate(
                    // `right: ${rightPosition}px` de la fuente.
                    offset: Offset(-sangria(i), 0),
                    child: _Nodo(
                      key: ValueKey('learn_nodo_$i'),
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
            ],
          ),
        ],
      ),
    );
  }
}

class _Nodo extends StatelessWidget {
  final String etiqueta;
  final EstadoNodo estado;
  final bool ultimo;
  final String empezar;
  final VoidCallback onTap;
  const _Nodo({
    super.key,
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
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bloq ? DuoCores.bloqueado : DuoCores.verde,
        border: Border(
          bottom: BorderSide(
              color: bloq ? DuoCores.bloqueadoBorde : DuoCores.verdeBorde,
              width: 8),
        ),
      ),
      child: Icon(
        estado == EstadoNodo.feito
            ? Icons.check_rounded
            : ultimo
                ? Icons.workspace_premium_rounded
                : Icons.star_rounded,
        size: 40,
        color: bloq ? DuoCores.bloqueadoBorde : Colors.white,
      ),
    );
    return Semantics(
      button: !bloq,
      label: etiqueta,
      child: GestureDetector(
        onTap: bloq ? null : onTap,
        child: Column(
          children: [
            if (estado == EstadoNodo.actual)
              SizedBox(
                width: 102,
                height: 130,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      top: 28,
                      child: SizedBox(
                        width: 102,
                        height: 102,
                        child: CircularProgressIndicator(
                          value: 0,
                          strokeWidth: 8,
                          backgroundColor: DuoCores.trilla,
                          color: DuoCores.verdeClaro,
                        ),
                      ),
                    ),
                    Positioned(top: 44, child: boton),
                    Positioned(
                      top: 0,
                      child: Container(
                        key: const Key('learn_empezar'),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: DuoCores.trilla, width: 2),
                        ),
                        child: Text(empezar.toUpperCase(),
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: DuoCores.textoVerde)),
                      ),
                    ),
                  ],
                ),
              )
            else
              boton,
            const SizedBox(height: 4),
            Text(etiqueta,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: bloq ? AppTheme.textMuted : DuoCores.textoVerde)),
          ],
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
  const PasoLeccion({required this.titulo, required this.texto, this.peza});
}

/// Los pasos del día: qué se hace, cada palabra nueva con su voz y la frase.
List<PasoLeccion> pasosDoDia(Leccion l, int dia, AppLanguage lang) {
  final isGl = lang == AppLanguage.gl;
  final d =
      l.dias.isEmpty ? null : l.dias[(dia - 1).clamp(0, l.dias.length - 1)];
  final pezas = l.repaso ? l.repasa : l.novas;
  return [
    if (d != null)
      PasoLeccion(titulo: d.dia.resolve(lang), texto: d.texto.resolve(lang)),
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
        r = await s.xogarHoxe(n.id, c,
            agora: widget.agora ?? DateTime.now(),
            semana: widget.semana,
            palabrasDaSemana: widget.palabrasDaSemana);
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
                    icon: const Icon(Icons.close_rounded,
                        color: Color(0xFF64748B), size: 28),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        key: const Key('leccion_progreso'),
                        value: _fin ? 1 : (_i + 1) / total,
                        minHeight: 16,
                        backgroundColor: DuoCores.trilla,
                        color: DuoCores.verde,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
            // footer.tsx: la franja de abajo con el botón.
            Container(
              decoration: const BoxDecoration(
                border:
                    Border(top: BorderSide(color: DuoCores.trilla, width: 2)),
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

class _PasoVista extends StatelessWidget {
  final PasoLeccion paso;
  final AppLanguage lang;
  final OfflineAudioService? audioService;
  const _PasoVista(
      {required this.paso, required this.lang, required this.audioService});

  @override
  Widget build(BuildContext context) => ListView(
        key: const Key('leccion_paso'),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        children: [
          Text(paso.titulo,
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF334155))),
          const SizedBox(height: 24),
          if (paso.peza case final p?) ...[
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
                child: Text(s.resolve(lang),
                    style: const TextStyle(
                        fontSize: 18, color: AppTheme.textSecondary)),
              ),
            ],
            const SizedBox(height: 20),
          ],
          if (paso.texto.isNotEmpty)
            Text(paso.texto,
                style: const TextStyle(
                    fontSize: 18, height: 1.4, color: AppTheme.textPrimary)),
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
    return ListView(
      key: const Key('leccion_fin'),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      children: [
        const Center(child: LuaValeria(ancho: 110, cara: CaraLua.love)),
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
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF334155)),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: _Resultado(
                key: const Key('leccion_fin_xp'),
                titulo: 'Total XP',
                valor: '${r?.xpGanado ?? 0}',
                cor: DuoCores.laranxa,
                texto: DuoCores.laranxaTexto,
                icono: AwardGlyph.star,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Resultado(
                titulo: isGl ? 'Nivel' : 'Nivel',
                valor: '${r?.nivel ?? 1}',
                cor: DuoCores.rosa,
                texto: DuoCores.rosaTexto,
                icono: AwardGlyph.crown,
              ),
            ),
          ],
        ),
        if (r != null && c != null) ...[
          for (final i in r!.insigniasNovas) ...[
            const SizedBox(height: 14),
            Center(child: PixelAward(glyph: i.glyph, tier: i.tier, size: 48)),
            Text(i.nome.resolve(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
          for (final o in r!.obxectosNovos) ...[
            const SizedBox(height: 14),
            Center(child: ObxectoLuaIcona(id: o.id, alto: 26)),
            Text(
                '${isGl ? 'Novo para Lúa' : 'Nuevo para Lúa'}: ${o.nome.resolve(lang)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800)),
          ],
        ],
      ],
    );
  }
}

/// `result-card.tsx`: la cabecera de color y el valor dentro.
class _Resultado extends StatelessWidget {
  final String titulo;
  final String valor;
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
              child: Text(titulo.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.white)),
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
                  Text(valor,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: texto)),
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
  OfflineAudioService? audioService,
  CriancasStore? store,
  Crianza? crianza,
  DateTime? agora,
}) {
  Navigator.of(context).push(RutaLua(
    de: context,
    builder: (_) => LeccionDuolingoScreen(
      pasos: pasosDoDia(leccion, dia, language),
      language: language,
      audioService: audioService,
      store: store,
      crianza: crianza,
      semana: semana,
      palabrasDaSemana: [
        for (final p in leccion.novas)
          if (p.en.isNotEmpty) p.en,
      ],
      agora: agora,
    ),
  ));
}
