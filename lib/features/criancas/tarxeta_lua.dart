import 'package:flutter/material.dart';

import '../../core/brand/lua_valeria.dart';
import '../../core/brand/pixel_award.dart';
import '../../core/localization/app_language.dart';
import '../../core/theme/app_theme.dart';
import 'criancas_store.dart';
import 'premios_lua_sheet.dart';
import 'xogo_lua.dart';

/// La tarjeta de Lúa de Valeria (O-20261109-3), copiada de
/// FrankBetances/Valeria:src/components/lua/ValeriaCatInteractiveCard.tsx:
/// la gata de cuerpo entero que respira y mueve la cola, parpadea cada 4,5 s,
/// ronronea al tocarla, come el pescadito cuando tiene antojo y lleva lo que
/// se le ponga; al lado, el nivel con su nombre, la racha con la llama, la
/// barra hasta el siguiente nivel y «Premios ›».
///
/// Lo único que no está en Valeria: el botón del juego del día. Allí el
/// niño juega en la pantalla; aquí la persona adulta lo marca en su nombre,
/// y eso es lo que da los puntos.
class TarxetaLua extends StatefulWidget {
  final CriancasStore store;
  final Crianza crianza;
  final AppLanguage language;
  final DateTime? agora;

  /// La semana de la lección (`curso/mes/semana`) y sus palabras nuevas.
  final String semana;
  final List<String> palabrasDaSemana;

  const TarxetaLua({
    super.key,
    required this.store,
    required this.crianza,
    required this.language,
    required this.semana,
    required this.palabrasDaSemana,
    this.agora,
  });

  @override
  State<TarxetaLua> createState() => _TarxetaLuaState();
}

class _TarxetaLuaState extends State<TarxetaLua> {
  CatalogoLua? _c = CatalogoLua.lido;
  CaraLua _cara = CaraLua.neutral;
  String _humor = 'luaPatShort';
  bool _comendo = false;
  double _salto = 0;
  final _tempo = TemporizadorLua();

  DateTime get _agora => widget.agora ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    if (_c == null) {
      CatalogoLua.cargar().then((c) {
        if (mounted) setState(() => _c = c);
      }, onError: (_) {});
    }
    if (ArteLua.lida == null) {
      ArteLua.cargar().then((_) {
        if (mounted) setState(() {});
      }, onError: (_) {});
    }
    // Parpadeo en reposo, también con antojo: es la misma cara, esperando.
    if (!luaQuieta) {
      _tempo.cada(const Duration(milliseconds: 4500), () {
        if (!mounted || _cara != CaraLua.neutral) return;
        setState(() => _cara = CaraLua.blink);
        _tempo.tras(const Duration(milliseconds: 160), () {
          if (mounted && _cara == CaraLua.blink) {
            setState(() => _cara = CaraLua.neutral);
          }
        });
      });
    }
  }

  @override
  void dispose() {
    _tempo.parar();
    super.dispose();
  }

  void _volver(Duration d) => _tempo.tras(d, () {
        if (mounted) {
          setState(() {
            _cara = CaraLua.neutral;
            _humor = 'luaPatShort';
            _comendo = false;
          });
        }
      });

  Future<void> _acariciar() async {
    setState(() {
      _cara = CaraLua.love;
      _humor = 'luaPurring';
      _salto = -2.5;
    });
    _tempo.tras(const Duration(milliseconds: 160), () {
      if (mounted) setState(() => _salto = 0);
    });
    await widget.store.acariciar(widget.crianza.id);
    _volver(const Duration(milliseconds: 1800));
  }

  Future<void> _darPeixe() async {
    setState(() {
      _cara = CaraLua.eat;
      _humor = 'luaEating';
      _comendo = true;
    });
    await widget.store.darPeixe(widget.crianza.id, _agora);
    _tempo.tras(const Duration(milliseconds: 620), () {
      if (mounted) setState(() => _cara = CaraLua.love);
    });
    _volver(const Duration(milliseconds: 1500));
  }

  Future<void> _xogar(CatalogoLua c) async {
    final r = await widget.store.xogarHoxe(widget.crianza.id, c,
        agora: _agora,
        semana: widget.semana,
        palabrasDaSemana: widget.palabrasDaSemana);
    if (!mounted) return;
    setState(() {
      _cara = CaraLua.love;
      _humor = 'luaPurring';
    });
    _volver(const Duration(milliseconds: 1800));
    await mostrarRecompensa(context, r, c, widget.language,
        nome: widget.crianza.nome);
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    if (c == null) return const SizedBox.shrink();
    final lang = widget.language;
    final isGl = lang == AppLanguage.gl;
    final acento = context.acento;
    final g = widget.store.xogo(widget.crianza.id);
    final nivel = c.nivel(g.xp);
    final maximo = nivel >= c.nivelMaximo;
    final racha = g.rachaViva(_agora);
    final antollo = g.antollo(_agora) && !_comendo;
    final humor = (antollo && _humor == 'luaPatShort' ? 'luaCraving' : _humor);
    final feito = g.xogouHoxe(_agora);

    return Container(
      key: const Key('tarxeta_lua'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: acento.withAlpha(70)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x210F172A), blurRadius: 20, offset: Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Column(
                children: [
                  Semantics(
                    button: true,
                    label: isGl ? 'Acariñar a Lúa' : 'Acariciar a Lúa',
                    child: GestureDetector(
                      key: const Key('lua_acariciar'),
                      onTap: _acariciar,
                      child: AnimatedScale(
                        scale: _cara == CaraLua.love ? 1.06 : 1,
                        duration: const Duration(milliseconds: 160),
                        child: Container(
                          width: 88,
                          height: 96,
                          decoration: BoxDecoration(
                            color: context.acentoTint,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          alignment: Alignment.center,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              LuaValeria(
                                ancho: 72,
                                cara: _cara,
                                cabeza: g.cabeza,
                                pescozo: g.pescozo,
                                salto: _salto,
                              ),
                              if (antollo || _comendo)
                                Positioned(
                                  top: -10,
                                  right: -12,
                                  child: _Burbulla(
                                    borde: acento,
                                    child: const ObxectoLuaIcona(
                                        id: 'snack_fish', alto: 12),
                                  ),
                                ),
                              if (_cara == CaraLua.love)
                                const Positioned(
                                  top: -10,
                                  left: -12,
                                  child: _Burbulla(
                                    borde: Color(0xFFEF8296),
                                    fondo: Color(0xFFFFF0F4),
                                    child: PixelAward(
                                        glyph: AwardGlyph.heart,
                                        tier: AwardTier.teal,
                                        size: 15),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    c.humor[humor]?.resolve(lang) ?? '',
                    key: const Key('lua_humor'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: humor == 'luaPatShort'
                          ? AppTheme.textSecondary
                          : acento,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.crianza.nome,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: acento),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Nivel $nivel · ${c.nomeNivel(nivel).resolve(lang)}',
                            key: const Key('lua_nivel'),
                            style: const TextStyle(
                                fontSize: 15,
                                height: 1.25,
                                fontWeight: FontWeight.w900,
                                color: AppTheme.textPrimary),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF3EA),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PixelAward(
                                glyph: AwardGlyph.flame,
                                tier: tierDeRacha(racha),
                                size: 20,
                                locked: racha == 0,
                              ),
                              const SizedBox(width: 4),
                              Text('$racha',
                                  key: const Key('lua_racha'),
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFC2571E))),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: maximo ? 1 : c.progreso(g.xp),
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE3ECEC),
                        color: acento,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maximo
                          ? c.textos['maxNivel']!.resolve(lang)
                          : (isGl
                              ? '${c.xpParaSeguinte(g.xp)} XP para o seguinte nivel'
                              : '${c.xpParaSeguinte(g.xp)} XP para el siguiente nivel'),
                      style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (g.obxectos.contains('snack_fish'))
                OutlinedButton.icon(
                  key: const Key('lua_peixe'),
                  onPressed: _comendo ? null : _darPeixe,
                  icon: const ObxectoLuaIcona(id: 'snack_fish', alto: 12),
                  label: Text(c.humor['luaFeedFish']!.resolve(lang),
                      style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
              const Spacer(),
              TextButton(
                key: const Key('lua_premios'),
                onPressed: () => abrirPremiosLua(context,
                    store: widget.store,
                    crianza: widget.crianza,
                    catalogo: c,
                    language: lang,
                    agora: _agora),
                child: Text('${isGl ? 'Premios' : 'Premios'} ›',
                    style: const TextStyle(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          FilledButton.icon(
            key: const Key('lua_xogar'),
            style: FilledButton.styleFrom(
              backgroundColor: acento,
              minimumSize: const Size.fromHeight(48),
            ),
            onPressed: feito ? null : () => _xogar(c),
            icon: Icon(feito ? Icons.check_rounded : Icons.star_rounded),
            label: Text(
              feito
                  ? (isGl
                      ? 'O xogo de hoxe xa está feito'
                      : 'El juego de hoy ya está hecho')
                  : (isGl
                      ? 'Xogamos hoxe con ${widget.crianza.nome}'
                      : 'Hoy jugamos con ${widget.crianza.nome}'),
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _Burbulla extends StatelessWidget {
  final Widget child;
  final Color borde;
  final Color fondo;
  const _Burbulla(
      {required this.child, required this.borde, this.fondo = Colors.white});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: fondo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borde),
        ),
        child: child,
      );
}
