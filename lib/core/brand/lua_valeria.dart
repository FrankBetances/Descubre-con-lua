import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lúa de cuerpo entero, como en Valeria (O-20261109-3): la misma rejilla
/// de 32×38, sus cuatro caras y sus accesorios, copiados con
/// `tools/port_lua_valeria.mjs` a `assets/brand/lua_valeria.json`.
///
/// Fuente: FrankBetances/Valeria:src/components/lua/ValeriaCatInteractiveCard.tsx.
/// Respira a 15 rpm (2 s dentro, 2 s fuera), la punta de la cola oscila ±7°
/// cada 1,6 s y la cabeza sube un poco más despacio que el cuerpo. Las caras
/// son cambios de rejilla, no interpolaciones.
enum CaraLua { neutral, blink, love, eat }

class ArteLua {
  final Map<String, Color> paleta;
  final Map<CaraLua, List<String>> caras;
  final List<String> corpo;
  final List<String> cola;
  final Map<String, ({int row, int col, List<String> art})> obxectos;

  const ArteLua({
    required this.paleta,
    required this.caras,
    required this.corpo,
    required this.cola,
    required this.obxectos,
  });

  static const assetPath = 'assets/brand/lua_valeria.json';
  static ArteLua? _lida;
  static Future<ArteLua>? _enCurso;
  static ArteLua? get lida => _lida;

  static Future<ArteLua> cargar() => _enCurso ??=
      rootBundle.loadString(assetPath).then((r) => _lida = fromRaw(r));

  @visibleForTesting
  static void sembrar(ArteLua a) {
    _lida = a;
    _enCurso = SynchronousFuture(a);
  }

  static Color _cor(String hex) =>
      Color(int.parse('FF${hex.substring(1)}', radix: 16));

  static ArteLua fromRaw(String raw) {
    final j = json.decode(raw) as Map<String, dynamic>;
    List<String> l(Object? v) => [for (final x in v as List) x.toString()];
    final h = j['head'] as Map<String, dynamic>;
    return ArteLua(
      paleta: {
        for (final e in (j['palette'] as Map).entries)
          e.key.toString(): _cor(e.value.toString()),
      },
      caras: {
        CaraLua.neutral: l(h['neutral']),
        CaraLua.blink: l(h['blink']),
        CaraLua.love: l(h['love']),
        CaraLua.eat: l(h['eat']),
      },
      corpo: l(j['body']),
      cola: l(j['tail']),
      obxectos: {
        for (final e in (j['items'] as Map).entries)
          e.key.toString(): (
            row: (e.value as Map)['row'] as int,
            col: (e.value as Map)['col'] as int,
            art: l((e.value as Map)['art']),
          ),
      },
    );
  }
}

/// Pinta una rejilla en celdas cuadradas desde [fila0], [col0].
class _Rejilla extends CustomPainter {
  final List<String> filas;
  final Map<String, Color> paleta;
  final double celda;
  final int fila0;
  final int col0;

  _Rejilla(this.filas, this.paleta, this.celda,
      {this.fila0 = 0, this.col0 = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..isAntiAlias = false;
    for (var y = 0; y < filas.length; y++) {
      final f = filas[y];
      for (var x = 0; x < f.length; x++) {
        final c = paleta[f[x]];
        if (c == null) continue;
        p.color = c;
        // +0.05 de solape: sin él asoman líneas de la placa entre celdas.
        canvas.drawRect(
            Rect.fromLTWH((col0 + x) * celda, (fila0 + y) * celda, celda + 0.05,
                celda + 0.05),
            p);
      }
    }
  }

  @override
  bool shouldRepaint(_Rejilla o) =>
      o.filas != filas || o.celda != celda || o.fila0 != fila0;
}

class LuaValeria extends StatefulWidget {
  final CaraLua cara;
  final String? cabeza;
  final String? pescozo;
  final double ancho;

  /// Salto de la cabeza al acariciarla (0 en reposo).
  final double salto;

  const LuaValeria({
    super.key,
    this.cara = CaraLua.neutral,
    this.cabeza,
    this.pescozo,
    this.ancho = 96,
    this.salto = 0,
  });

  @override
  State<LuaValeria> createState() => _LuaValeriaState();
}

class _LuaValeriaState extends State<LuaValeria>
    with SingleTickerProviderStateMixin {
  // Un solo reloj de 12,8 s: 3,2 respiraciones de 4 s y 4 colas de 3,2 s.
  late final AnimationController _t = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 12800));
  ArteLua? _arte = ArteLua.lida;

  @override
  void initState() {
    super.initState();
    if (!luaQuieta) _t.repeat();
    if (_arte == null) {
      ArteLua.cargar().then((a) {
        if (mounted) setState(() => _arte = a);
      }, onError: (_) {});
    }
  }

  @override
  void dispose() {
    _t.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = _arte;
    final celda = widget.ancho / 32;
    final alto = celda * 38;
    if (a == null) return SizedBox(width: widget.ancho, height: alto);
    final cara = a.caras[widget.cara]!;
    List<String> enGata(String? id) {
      final o = id == null ? null : a.obxectos[id];
      return o == null ? const [] : o.art;
    }

    return Semantics(
      image: true,
      label: 'Lúa',
      child: AnimatedBuilder(
        animation: _t,
        builder: (context, _) {
          final s = _t.value * 12800;
          // Respiración: seno de 4 s, 0..1.
          final resp = (1 - math.cos(2 * math.pi * s / 4000)) / 2;
          final yCorpo = -1.4 * resp * celda / 2;
          final yCabeza = -0.8 * resp * celda / 2 + widget.salto * celda;
          final ang = math.sin(2 * math.pi * s / 3200) * 7 * math.pi / 180;
          final cabezaObx =
              widget.cabeza == null ? null : a.obxectos[widget.cabeza];
          final pescozoObx =
              widget.pescozo == null ? null : a.obxectos[widget.pescozo];
          return SizedBox(
            width: widget.ancho,
            height: alto,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // La punta de la cola, que oscila desde su base.
                Positioned(
                  left: 26 * celda,
                  top: 24 * celda + yCorpo,
                  child: Transform.rotate(
                    angle: ang,
                    alignment: Alignment.bottomCenter,
                    child: CustomPaint(
                      size: Size(5 * celda, 6 * celda),
                      painter: _Rejilla(a.cola, a.paleta, celda),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: 22 * celda + yCorpo,
                  child: CustomPaint(
                    size: Size(widget.ancho, 16 * celda),
                    painter: _Rejilla(a.corpo, a.paleta, celda),
                  ),
                ),
                Positioned(
                  left: 0,
                  top: yCabeza,
                  child: CustomPaint(
                    size: Size(widget.ancho, 22 * celda),
                    painter: _Rejilla(cara, a.paleta, celda),
                  ),
                ),
                // Los accesorios van DESPUÉS de la cabeza, como en Valeria:
                // con la cabeza encima, el nudo de la pajarita quedaba tapado.
                if (pescozoObx != null)
                  Positioned(
                    left: 0,
                    top: yCorpo,
                    child: CustomPaint(
                      size: Size(widget.ancho, alto),
                      painter: _Rejilla(enGata(widget.pescozo), a.paleta, celda,
                          fila0: pescozoObx.row, col0: pescozoObx.col),
                    ),
                  ),
                if (cabezaObx != null)
                  Positioned(
                    left: 0,
                    top: yCabeza,
                    child: CustomPaint(
                      size: Size(widget.ancho, alto),
                      painter: _Rejilla(enGata(widget.cabeza), a.paleta, celda,
                          fila0: cabezaObx.row, col0: cabezaObx.col),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Un accesorio suelto, en su caja: para el armario y la burbuja del antojo.
class ObxectoLuaIcona extends StatelessWidget {
  final String id;
  final double alto;
  const ObxectoLuaIcona({super.key, required this.id, this.alto = 18});

  @override
  Widget build(BuildContext context) {
    final a = ArteLua.lida;
    final o = a?.obxectos[id];
    if (a == null || o == null) return SizedBox(height: alto, width: alto);
    final ancho = o.art.map((f) => f.length).reduce(math.max);
    final celda = alto / o.art.length;
    return CustomPaint(
      size: Size(ancho * celda, alto),
      painter: _Rejilla(o.art, a.paleta, celda),
    );
  }
}

/// Sin animación en los tests de pantalla: un reloj infinito impide que
/// `pumpAndSettle` termine. Solo lo pone a `true`
/// `test/flutter_test_config.dart`; la app no lo toca.
bool luaQuieta = false;

/// Pausa útil en la tarjeta: [Timer] que se cancela solo al desmontar.
class TemporizadorLua {
  final List<Timer> _t = [];
  void tras(Duration d, VoidCallback f) => _t.add(Timer(d, f));
  void cada(Duration d, VoidCallback f) =>
      _t.add(Timer.periodic(d, (_) => f()));
  void parar() {
    for (final t in _t) {
      t.cancel();
    }
    _t.clear();
  }
}
