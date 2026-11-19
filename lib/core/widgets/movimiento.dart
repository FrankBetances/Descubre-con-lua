import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../brand/lua_valeria.dart';

/// O-20261119-7: el movimiento de la app, en un solo sitio.
///
/// Todo se para si el sistema pide «reducir movimiento»
/// (`MediaQuery.disableAnimations`) o en los tests ([luaQuieta]): entonces
/// cada pieza pinta su estado final, sin reloj. Así nadie se marea, y
/// `pumpAndSettle` termina.
bool movimientoQuieto(BuildContext context) =>
    luaQuieta || (MediaQuery.maybeDisableAnimationsOf(context) ?? false);

/// Late suave y sin fin: el nodo de hoy, lo que toca tocar.
class Latido extends StatefulWidget {
  final Widget child;
  final double escala;
  final Duration periodo;
  const Latido({
    super.key,
    required this.child,
    this.escala = 1.07,
    this.periodo = const Duration(milliseconds: 1400),
  });

  @override
  State<Latido> createState() => _LatidoState();
}

class _LatidoState extends State<Latido> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.periodo);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movimientoQuieto(context) ? _c.stop() : _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return widget.child;
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: widget.escala)
          .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
      child: widget.child,
    );
  }
}

/// Flota arriba y abajo: el globo de «Empezar». Valeria `Breathe`
/// (src/ui/motion.tsx): sube 3 px en 1,4 s y vuelve.
class Flotar extends StatefulWidget {
  final Widget child;
  final double altura;
  const Flotar({super.key, required this.child, this.altura = 3});

  @override
  State<Flotar> createState() => _FlotarState();
}

class _FlotarState extends State<Flotar> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movimientoQuieto(context) ? _c.stop() : _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Transform.translate(
        offset:
            Offset(0, -widget.altura * Curves.easeInOut.transform(_c.value)),
        child: child,
      ),
    );
  }
}

/// Entra una vez, subiendo y apareciendo; [orden] escalona una lista.
/// Valeria `enterAt` (src/ui/motion.tsx): 55 ms entre filas, hasta la 10, y
/// 380 ms de entrada.
class Entrada extends StatefulWidget {
  final Widget child;
  final int orden;
  final double desde;
  const Entrada(
      {super.key, required this.child, this.orden = 0, this.desde = 18});

  @override
  State<Entrada> createState() => _EntradaState();
}

class _EntradaState extends State<Entrada> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  bool _quieto = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _quieto = movimientoQuieto(context);
    if (_quieto) {
      _c.value = 1;
    } else if (_c.value == 0 && !_c.isAnimating) {
      Future.delayed(Duration(milliseconds: 55 * math.min(widget.orden, 10)),
          () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_quieto) return widget.child;
    final a = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _c.value,
        child: Transform.translate(
          offset: Offset(0, widget.desde * (1 - a.value)),
          child: child,
        ),
      ),
    );
  }
}

/// Se hunde al dedo, como un botón de verdad. No toma el toque: lo deja
/// pasar al botón que envuelve.
class Pulsable extends StatefulWidget {
  final Widget child;
  const Pulsable({super.key, required this.child});

  @override
  State<Pulsable> createState() => _PulsableState();
}

class _PulsableState extends State<Pulsable> {
  bool _abaixo = false;

  void _pon(bool v) {
    if (_abaixo != v) setState(() => _abaixo = v);
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => _pon(true),
        onPointerUp: (_) => _pon(false),
        onPointerCancel: (_) => _pon(false),
        child: AnimatedScale(
          scale: _abaixo ? 0.94 : 1,
          duration: movimientoQuieto(context)
              ? Duration.zero
              : const Duration(milliseconds: 90),
          child: widget.child,
        ),
      );
}

/// Lúa salta de alegría: dos botes al aparecer y uno más a cada toque.
class SaltoLua extends StatefulWidget {
  final Widget child;
  final bool alEntrar;
  const SaltoLua({super.key, required this.child, this.alEntrar = false});

  @override
  State<SaltoLua> createState() => _SaltoLuaState();
}

class _SaltoLuaState extends State<SaltoLua>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));
  int _botes = 0;

  @override
  void initState() {
    super.initState();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed && _botes > 1) {
        _botes--;
        _c.forward(from: 0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.alEntrar && _botes == 0 && !movimientoQuieto(context)) {
      _saltar(2);
    }
  }

  void _saltar(int n) {
    if (movimientoQuieto(context)) return;
    _botes = n;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => _saltar(1),
        child: AnimatedBuilder(
          animation: _c,
          child: widget.child,
          builder: (context, child) {
            final t = _c.value;
            final y = -22 * math.sin(math.pi * t);
            // Se aplasta un poco al despegar y al caer.
            final aplaste = (t > 0 && (t < 0.12 || t > 0.88)) ? 0.93 : 1.0;
            return Transform.translate(
              offset: Offset(0, y),
              child: Transform.scale(
                  scaleY: aplaste,
                  alignment: Alignment.bottomCenter,
                  child: child),
            );
          },
        ),
      );
}

/// Confeti propio: tiras y círculos con los colores de la casa, sin emoji.
/// Cae una vez y se va. Con movimiento reducido no se pinta.
class Confeti extends StatefulWidget {
  final List<Color> cores;
  const Confeti({super.key, required this.cores});

  @override
  State<Confeti> createState() => _ConfetiState();
}

class _ConfetiState extends State<Confeti> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2600));
  final _pezas = <_Peza>[];

  @override
  void initState() {
    super.initState();
    final r = math.Random(7);
    for (var i = 0; i < 70; i++) {
      _pezas.add(_Peza(
        x: r.nextDouble(),
        vx: (r.nextDouble() - 0.5) * 0.5,
        retraso: r.nextDouble() * 0.25,
        xiro: (r.nextDouble() - 0.5) * 14,
        cor: widget.cores[i % widget.cores.length],
        circulo: i % 3 == 0,
        tam: 6 + r.nextDouble() * 6,
      ));
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!movimientoQuieto(context) && _c.value == 0) _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return const SizedBox.shrink();
    return IgnorePointer(
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => CustomPaint(
            size: Size.infinite,
            painter: _PintaConfeti(_pezas, _c.value),
          ),
        ),
      ),
    );
  }
}

class _Peza {
  final double x, vx, retraso, xiro, tam;
  final Color cor;
  final bool circulo;
  const _Peza({
    required this.x,
    required this.vx,
    required this.retraso,
    required this.xiro,
    required this.cor,
    required this.circulo,
    required this.tam,
  });
}

class _PintaConfeti extends CustomPainter {
  final List<_Peza> pezas;
  final double t;
  _PintaConfeti(this.pezas, this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint();
    for (final z in pezas) {
      final u = ((t - z.retraso) / (1 - z.retraso)).clamp(0.0, 1.0);
      if (u <= 0 || u >= 1) continue;
      final x = (z.x + z.vx * u) * size.width;
      final y = -20 + (size.height + 40) * Curves.easeIn.transform(u);
      p.color = z.cor.withValues(alpha: u > 0.8 ? (1 - u) / 0.2 : 1);
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(z.xiro * u);
      if (z.circulo) {
        canvas.drawCircle(Offset.zero, z.tam / 2, p);
      } else {
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                Rect.fromCenter(
                    center: Offset.zero, width: z.tam, height: z.tam * 0.45),
                const Radius.circular(1.5)),
            p);
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PintaConfeti o) => o.t != t;
}

/// Cuenta de 0 al número: los puntos se suman ante los ojos.
class ContadorAnimado extends StatelessWidget {
  final int valor;
  final TextStyle? style;
  const ContadorAnimado({super.key, required this.valor, this.style});

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return Text('$valor', style: style);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: valor),
      duration: Duration(milliseconds: 500 + 25 * valor.clamp(0, 40)),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('$v', style: style),
    );
  }
}

/// Los seis colores del confeti de Valeria (src/ui/Celebration.tsx).
const coresCelebracion = [
  Color(0xFFFFD23F),
  Color(0xFF00C4BE),
  Color(0xFFFF6B9A),
  Color(0xFF7C5CFF),
  Color(0xFF4CD964),
  Color(0xFFFF9F1C),
];

/// Anillo de avance que se dibuja al aparecer: Valeria `ProgressRing`
/// (src/ui/motion.tsx), 250 ms de espera y 900 ms de trazo.
class AnilloAvance extends StatelessWidget {
  final double valor;
  final double tam;
  final double grosor;
  final Color cor;
  final Color fondo;
  const AnilloAvance({
    super.key,
    required this.valor,
    required this.tam,
    required this.cor,
    required this.fondo,
    this.grosor = 8,
  });

  @override
  Widget build(BuildContext context) {
    final v = valor.clamp(0.0, 1.0);
    Widget aro(double x) => SizedBox(
          width: tam,
          height: tam,
          child: CircularProgressIndicator(
              value: x,
              strokeWidth: grosor,
              backgroundColor: fondo,
              color: cor),
        );
    if (movimientoQuieto(context)) return aro(v);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: const Duration(milliseconds: 1150),
      curve: const Interval(250 / 1150, 1, curve: Curves.easeOutCubic),
      builder: (context, x, _) => aro(x),
    );
  }
}

/// Halo que late alrededor de lo que toca tocar: Valeria `ReactiveTile` con
/// `hint` (src/ui/ReactiveTile.tsx), 650 ms de ida y 650 de vuelta.
class Halo extends StatefulWidget {
  final Widget child;
  final Color cor;
  final double radio;
  const Halo(
      {super.key, required this.child, required this.cor, this.radio = 999});

  @override
  State<Halo> createState() => _HaloState();
}

class _HaloState extends State<Halo> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 650));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    movimientoQuieto(context) ? _c.stop() : _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radio),
          boxShadow: [
            BoxShadow(
              color: widget.cor
                  .withValues(alpha: 0.55 * Curves.easeOut.transform(_c.value)),
              spreadRadius: 6,
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Tres estrellas que caen escalonadas, la del medio más grande: Valeria
/// `Celebration` (src/ui/Celebration.tsx), 180 ms + 140 ms por estrella.
class Estrelas extends StatelessWidget {
  final Widget Function(double tam) estrela;
  const Estrelas({super.key, required this.estrela});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < 3; i++)
            Padding(
              padding: EdgeInsets.fromLTRB(5, 0, 5, i == 1 ? 6 : 0),
              child: _Cae(
                  retraso: 180 + i * 140, child: estrela(i == 1 ? 44 : 32)),
            ),
        ],
      );
}

class _Cae extends StatefulWidget {
  final int retraso;
  final Widget child;
  const _Cae({required this.retraso, required this.child});

  @override
  State<_Cae> createState() => _CaeState();
}

class _CaeState extends State<_Cae> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 520));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (movimientoQuieto(context)) {
      _c.value = 1;
    } else if (_c.value == 0 && !_c.isAnimating) {
      Future.delayed(Duration(milliseconds: widget.retraso), () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (movimientoQuieto(context)) return widget.child;
    final a = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) => Opacity(
        opacity: _c.value.clamp(0.0, 1.0),
        child: Transform.translate(
            offset: Offset(0, -24 * (1 - a.value)), child: child),
      ),
    );
  }
}
