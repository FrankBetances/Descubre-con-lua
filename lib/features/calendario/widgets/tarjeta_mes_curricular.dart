import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/localization/app_language.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/calendario_model.dart';

// ─── Paleta atlántica cálida ────────────────────────────────────────────────
const _ambar = Color(0xFFFFB300);
const _menta = Color(0xFFE0F2F1);

/// Colores de acento por mes curricular (orden 1–10).
const _acentos = [
  Color(0xFF00BFA5), // Setembro – turquesa acogedor
  Color(0xFFFF7043), // Outubro  – coral cuerpo
  Color(0xFFFF8F00), // Novembro – ámbar otoño
  Color(0xFF1E88E5), // Decembro – azul frío
  Color(0xFF5C6BC0), // Xaneiro  – índigo invierno
  Color(0xFFEF5350), // Febreiro – rojo Entroido
  Color(0xFF43A047), // Marzo    – verde alimentos
  Color(0xFFF48FB1), // Abril    – rosa primavera
  Color(0xFF29B6F6), // Maio     – azul agua
  Color(0xFF00838F), // Xuño     – aguamarina mar
];

/// Tarjeta visual curricular minimalista para un [MesCurricular].
///
/// Diseñada para visibilidad inmediata a ≥ 2 metros en la alfombra del aula:
/// - Icono vectorial de alto contraste dibujado con [CustomPainter].
/// - Léxico inglés en chips de color (primera palabra pronunciable visible).
/// - Acceso directo a los 4 momentos de sesión mediante iconos.
/// - Paleta atlántica cálida conforme a [AppTheme].
class TarjetaMesCurricular extends StatefulWidget {
  final MesCurricular mes;
  final EstadoEstimulacion estado;
  final bool esDocente;
  final bool isSelected;

  /// Si [onTap] es nulo, la tarjeta se muestra en modo solo lectura.
  final VoidCallback? onTap;

  /// La lengua del selector de la app, no la del sistema.
  final AppLanguage lang;

  const TarjetaMesCurricular({
    super.key,
    required this.mes,
    required this.estado,
    required this.esDocente,
    this.isSelected = false,
    this.onTap,
    this.lang = AppLanguage.gl,
  });

  @override
  State<TarjetaMesCurricular> createState() => _TarjetaMesCurricularState();
}

class _TarjetaMesCurricularState extends State<TarjetaMesCurricular>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleCtrl;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  Color get _acento => _acentos[(widget.mes.orden - 1) % _acentos.length];

  @override
  Widget build(BuildContext context) {
    final nombreMes = widget.mes.nombreMes.resolve(widget.lang);
    final centroInteres = widget.mes.centroInteres.resolve(widget.lang);

    return ScaleTransition(
      scale: _scaleAnim,
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.reverse(),
        onTapUp: (_) {
          _scaleCtrl.forward();
          widget.onTap?.call();
        },
        onTapCancel: () => _scaleCtrl.forward(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            border: Border.all(
              color: widget.isSelected ? _acento : AppTheme.border,
              width: widget.isSelected ? 2.5 : 1.0,
            ),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: _acento.withAlpha(60),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    )
                  ]
                : AppTheme.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Cabecera cromática ────────────────────────────────────────
              _Cabecera(
                acento: _acento,
                mes: widget.mes,
                nombreMes: nombreMes,
                estado: widget.estado,
              ),
              // ── Centro de interés ─────────────────────────────────────────
              // Flexible: la tarjeta vive en un carrusel de altura fija y el
              // gallego ocupa más que el castellano. Lo que sobra se recorta
              // con puntos suspensivos, que se ve; un desbordamiento en
              // release no se ve.
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                  child: Text(
                    centroInteres,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              // ── Cuánto dura ───────────────────────────────────────────────
              _PieDuracion(minutos: widget.mes.minutosSugeridos),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Cabecera con ilustración vectorial ──────────────────────────────────────

class _Cabecera extends StatelessWidget {
  final Color acento;
  final MesCurricular mes;
  final String nombreMes;
  final EstadoEstimulacion estado;

  const _Cabecera({
    required this.acento,
    required this.mes,
    required this.nombreMes,
    required this.estado,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppTheme.radiusCard),
      ),
      child: SizedBox(
        height: 100,
        child: Stack(
          children: [
            // Fondo degradado
            Positioned.fill(
              child: CustomPaint(
                painter: _FondoCabeceraP(acento: acento),
              ),
            ),
            // Ilustración vectorial del mes
            Positioned(
              right: 8,
              top: 8,
              bottom: 8,
              child: SizedBox(
                width: 80,
                child: CustomPaint(
                  painter: _IlustracionMesP(orden: mes.orden, acento: acento),
                ),
              ),
            ),
            // Número de orden
            Positioned(
              left: 12,
              top: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${mes.orden}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withAlpha(230),
                  ),
                ),
              ),
            ),
            // Nombre del mes
            Positioned(
              left: 12,
              bottom: 28,
              child: Text(
                nombreMes,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.3,
                  shadows: [
                    Shadow(color: Colors.black26, blurRadius: 4),
                  ],
                ),
              ),
            ),
            // Badge de estado
            Positioned(
              left: 12,
              bottom: 8,
              child: _EstadoBadge(estado: estado),
            ),
          ],
        ),
      ),
    );
  }
}

class _FondoCabeceraP extends CustomPainter {
  final Color acento;
  const _FondoCabeceraP({required this.acento});

  @override
  void paint(Canvas canvas, Size size) {
    // Degradado base
    final grad = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [acento, Color.lerp(acento, Colors.black, 0.25)!],
    );
    final paint = Paint()
      ..shader =
          grad.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Ondas decorativas translúcidas
    final wave = Paint()
      ..color = Colors.white.withAlpha(20)
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(
        size.width * 0.25,
        size.height * 0.45,
        size.width * 0.5,
        size.height * 0.65,
      )
      ..quadraticBezierTo(
        size.width * 0.75,
        size.height * 0.85,
        size.width,
        size.height * 0.7,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, wave);
  }

  @override
  bool shouldRepaint(_FondoCabeceraP old) => old.acento != acento;
}

/// Ilustración vectorial minimalista por mes (orden 1–10).
class _IlustracionMesP extends CustomPainter {
  final int orden;
  final Color acento;
  const _IlustracionMesP({required this.orden, required this.acento});

  @override
  void paint(Canvas canvas, Size size) {
    switch (orden) {
      case 1:
        _dibujarBienvenida(canvas, size);
        break;
      case 2:
        _dibujarCuerpo(canvas, size);
        break;
      case 3:
        _dibujarHoja(canvas, size);
        break;
      case 4:
        _dibujarCampanilla(canvas, size);
        break;
      case 5:
        _dibujarAbrigo(canvas, size);
        break;
      case 6:
        _dibujarRana(canvas, size);
        break;
      case 7:
        _dibujarManzana(canvas, size);
        break;
      case 8:
        _dibujarFlor(canvas, size);
        break;
      case 9:
        _dibujarGota(canvas, size);
        break;
      case 10:
        _dibujarOla(canvas, size);
        break;
    }
  }

  Paint get _blanco => Paint()
    ..color = Colors.white.withAlpha(230)
    ..style = PaintingStyle.fill;

  Paint get _blancoLinea => Paint()
    ..color = Colors.white.withAlpha(200)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3
    ..strokeCap = StrokeCap.round;

  // 1. Setembro – cara sonriente / manos de saludo
  void _dibujarBienvenida(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Cara
    canvas.drawCircle(Offset(cx, s.height * 0.38), 20, _blanco);
    // Sonrisa
    final smile = Path()
      ..moveTo(cx - 8, s.height * 0.42)
      ..quadraticBezierTo(cx, s.height * 0.5, cx + 8, s.height * 0.42);
    canvas.drawPath(smile, _blancoLinea..strokeWidth = 2.5);
    // Ojos
    final ojo = Paint()..color = Color.lerp(acento, Colors.black, 0.4)!;
    canvas.drawCircle(Offset(cx - 6, s.height * 0.33), 2.5, ojo);
    canvas.drawCircle(Offset(cx + 6, s.height * 0.33), 2.5, ojo);
    // Manos abiertas
    _manoAbierta(canvas, Offset(cx - 22, s.height * 0.65), -0.3);
    _manoAbierta(canvas, Offset(cx + 22, s.height * 0.65), 0.3);
  }

  void _manoAbierta(Canvas canvas, Offset center, double angle) {
    final p = _blanco;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    // Palma
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-8, -5, 16, 12),
        const Radius.circular(4),
      ),
      p,
    );
    // Dedos
    for (int i = 0; i < 4; i++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(-7 + i * 4.5, -14, 3, 10),
          const Radius.circular(2),
        ),
        p,
      );
    }
    canvas.restore();
  }

  // 2. Outubro – silueta cuerpo simplificada
  void _dibujarCuerpo(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Cabeza
    canvas.drawCircle(Offset(cx, s.height * 0.2), 14, _blanco);
    // Torso
    final torso = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, s.height * 0.55),
        width: 22,
        height: 26,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(torso, _blanco);
    // Brazos
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 24, s.height * 0.43, 12, 8),
        const Radius.circular(4),
      ),
      _blanco,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 12, s.height * 0.43, 12, 8),
        const Radius.circular(4),
      ),
      _blanco,
    );
    // Piernas
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 12, s.height * 0.68, 10, 20),
        const Radius.circular(4),
      ),
      _blanco,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx + 2, s.height * 0.68, 10, 20),
        const Radius.circular(4),
      ),
      _blanco,
    );
  }

  // 3. Novembro – hoja caída
  void _dibujarHoja(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.48;
    final path = Path()
      ..moveTo(cx, cy - 28)
      ..cubicTo(cx + 24, cy - 20, cx + 24, cy + 10, cx, cy + 28)
      ..cubicTo(cx - 24, cy + 10, cx - 24, cy - 20, cx, cy - 28)
      ..close();
    canvas.drawPath(path, _blanco);
    // Nervio central
    canvas.drawLine(
      Offset(cx, cy - 24),
      Offset(cx, cy + 24),
      _blancoLinea..strokeWidth = 2,
    );
    // Nervios laterales
    for (int i = -1; i <= 1; i += 2) {
      canvas.drawLine(
        Offset(cx, cy + i * 4),
        Offset(cx + i * 14, cy + i * 12),
        _blancoLinea..strokeWidth = 1.5,
      );
    }
  }

  // 4. Decembro – campanilla
  void _dibujarCampanilla(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Cuerpo campana
    final bell = Path()
      ..moveTo(cx, s.height * 0.12)
      ..quadraticBezierTo(cx + 22, s.height * 0.25, cx + 22, s.height * 0.6)
      ..lineTo(cx - 22, s.height * 0.6)
      ..quadraticBezierTo(cx - 22, s.height * 0.25, cx, s.height * 0.12)
      ..close();
    canvas.drawPath(bell, _blanco);
    // Boca
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, s.height * 0.62),
        width: 44,
        height: 8,
      ),
      Paint()..color = Colors.white.withAlpha(140),
    );
    // Badajo
    canvas.drawCircle(Offset(cx, s.height * 0.72), 5, _blanco);
    // Asita
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 5, s.height * 0.06, 10, 8),
        const Radius.circular(3),
      ),
      _blanco,
    );
  }

  // 5. Xaneiro – bota de agua
  void _dibujarAbrigo(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Bota
    final bota = Path()
      ..moveTo(cx - 10, s.height * 0.1)
      ..lineTo(cx - 10, s.height * 0.62)
      ..quadraticBezierTo(cx - 10, s.height * 0.78, cx, s.height * 0.8)
      ..lineTo(cx + 16, s.height * 0.8)
      ..quadraticBezierTo(cx + 22, s.height * 0.8, cx + 22, s.height * 0.72)
      ..lineTo(cx + 22, s.height * 0.62)
      ..lineTo(cx + 10, s.height * 0.62)
      ..lineTo(cx + 10, s.height * 0.1)
      ..close();
    canvas.drawPath(bota, _blanco);
    // Detalle superior bota
    canvas.drawLine(
      Offset(cx - 10, s.height * 0.28),
      Offset(cx + 10, s.height * 0.28),
      _blancoLinea..strokeWidth = 2,
    );
    // Gotitas de lluvia
    for (int i = 0; i < 3; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(cx + 26 + i * 6.0, s.height * (0.2 + i * 0.18)),
          width: 4,
          height: 7,
        ),
        Paint()..color = Colors.white.withAlpha(160),
      );
    }
  }

  // 6. Febreiro – rana saltando
  void _dibujarRana(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.52;
    // Cuerpo
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: 32, height: 24),
      _blanco,
    );
    // Cabeza
    canvas.drawCircle(Offset(cx, cy - 18), 14, _blanco);
    // Ojos (círculos saltones)
    canvas.drawCircle(Offset(cx - 10, cy - 27), 6, _blanco);
    canvas.drawCircle(Offset(cx + 10, cy - 27), 6, _blanco);
    final pupil = Paint()..color = Color.lerp(acento, Colors.black, 0.6)!;
    canvas.drawCircle(Offset(cx - 10, cy - 27), 3, pupil);
    canvas.drawCircle(Offset(cx + 10, cy - 27), 3, pupil);
    // Patas traseras
    final pataIzq = Path()
      ..moveTo(cx - 14, cy + 10)
      ..quadraticBezierTo(cx - 28, cy + 22, cx - 22, cy + 32);
    canvas.drawPath(pataIzq, _blancoLinea..strokeWidth = 4);
    final pataDer = Path()
      ..moveTo(cx + 14, cy + 10)
      ..quadraticBezierTo(cx + 28, cy + 22, cx + 22, cy + 32);
    canvas.drawPath(pataDer, _blancoLinea..strokeWidth = 4);
  }

  // 7. Marzo – manzana
  void _dibujarManzana(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.5;
    // Cuerpo manzana
    final apple = Path()
      ..moveTo(cx, cy - 26)
      ..cubicTo(cx + 20, cy - 26, cx + 24, cy - 8, cx + 22, cy + 4)
      ..cubicTo(cx + 20, cy + 22, cx + 8, cy + 30, cx, cy + 28)
      ..cubicTo(cx - 8, cy + 30, cx - 20, cy + 22, cx - 22, cy + 4)
      ..cubicTo(cx - 24, cy - 8, cx - 20, cy - 26, cx, cy - 26)
      ..close();
    canvas.drawPath(apple, _blanco);
    // Tallo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 2, cy - 38, 4, 14),
        const Radius.circular(2),
      ),
      _blancoLinea..strokeWidth = 1,
    );
    // Hojita
    final hoja = Path()
      ..moveTo(cx + 2, cy - 34)
      ..quadraticBezierTo(cx + 14, cy - 34, cx + 12, cy - 24)
      ..quadraticBezierTo(cx + 2, cy - 26, cx + 2, cy - 34)
      ..close();
    canvas.drawPath(hoja, _blanco);
    // Reflejo
    canvas.drawCircle(
      Offset(cx - 8, cy - 12),
      5,
      Paint()..color = Colors.white.withAlpha(80),
    );
  }

  // 8. Abril – flor creciendo
  void _dibujarFlor(Canvas canvas, Size s) {
    final cx = s.width / 2;
    // Tallo
    canvas.drawLine(
      Offset(cx, s.height * 0.9),
      Offset(cx, s.height * 0.3),
      _blancoLinea..strokeWidth = 4,
    );
    // Pétalos
    for (int i = 0; i < 5; i++) {
      final angle = (math.pi * 2 / 5) * i - math.pi / 2;
      final px = cx + math.cos(angle) * 16;
      final py = s.height * 0.3 + math.sin(angle) * 16;
      canvas.drawCircle(Offset(px, py), 8, _blanco);
    }
    // Centro flor
    canvas.drawCircle(
      Offset(cx, s.height * 0.3),
      9,
      Paint()..color = _ambar.withAlpha(220),
    );
    // Hojita en el tallo
    final hoja = Path()
      ..moveTo(cx, s.height * 0.6)
      ..quadraticBezierTo(cx + 16, s.height * 0.54, cx + 14, s.height * 0.66)
      ..close();
    canvas.drawPath(hoja, _blanco);
  }

  // 9. Maio – gota de agua
  void _dibujarGota(Canvas canvas, Size s) {
    final cx = s.width / 2;
    final cy = s.height * 0.5;
    final drop = Path()
      ..moveTo(cx, cy - 30)
      ..quadraticBezierTo(cx + 22, cy, cx + 22, cy + 10)
      ..arcToPoint(
        Offset(cx - 22, cy + 10),
        radius: const Radius.circular(22),
      )
      ..quadraticBezierTo(cx - 22, cy, cx, cy - 30)
      ..close();
    canvas.drawPath(drop, _blanco);
    // Reflejo interno
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx - 6, cy - 4),
        width: 8,
        height: 14,
      ),
      Paint()..color = Colors.white.withAlpha(70),
    );
    // Ondas debajo
    for (int i = 0; i < 2; i++) {
      final wavePaint = Paint()
        ..color = Colors.white.withAlpha(90 - i * 35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      final wr = 12.0 + i * 8;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(cx, cy + 24 + i * 6.0),
          width: wr * 2,
          height: 8,
        ),
        0,
        math.pi,
        false,
        wavePaint,
      );
    }
  }

  // 10. Xuño – ola del mar
  void _dibujarOla(Canvas canvas, Size s) {
    final cx = s.width / 2;
    for (int i = 0; i < 3; i++) {
      final y = s.height * (0.3 + i * 0.22);
      final amplitude = 14.0 - i * 3;
      final wavePaint = Paint()
        ..color = Colors.white.withAlpha(180 - i * 45)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 - i * 1.0
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(0, y);
      for (double x = 0; x <= s.width; x += 2) {
        path.lineTo(x, y + math.sin((x / s.width) * math.pi * 2) * amplitude);
      }
      canvas.drawPath(path, wavePaint);
    }
    // Pececito
    final fishX = cx;
    final fishY = s.height * 0.75;
    final fish = Path()
      ..moveTo(fishX - 18, fishY)
      ..quadraticBezierTo(fishX, fishY - 10, fishX + 14, fishY)
      ..quadraticBezierTo(fishX, fishY + 10, fishX - 18, fishY)
      ..close();
    canvas.drawPath(fish, _blanco);
    // Cola
    final cola = Path()
      ..moveTo(fishX + 14, fishY)
      ..lineTo(fishX + 24, fishY - 8)
      ..lineTo(fishX + 24, fishY + 8)
      ..close();
    canvas.drawPath(cola, _blanco);
  }

  @override
  bool shouldRepaint(_IlustracionMesP old) =>
      old.orden != orden || old.acento != acento;
}

// ─── Badge de estado de estimulación ─────────────────────────────────────────

class _EstadoBadge extends StatelessWidget {
  final EstadoEstimulacion estado;
  const _EstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final (icon, label, color) = switch (estado) {
      EstadoEstimulacion.dobleEstimulacion => (
          Icons.star_rounded,
          'Aula e casa',
          _ambar,
        ),
      EstadoEstimulacion.soloAula => (
          Icons.school_rounded,
          'Aula',
          _menta,
        ),
      EstadoEstimulacion.soloHogar => (
          Icons.home_rounded,
          'Casa',
          _menta,
        ),
      EstadoEstimulacion.sinRegistro => (
          Icons.radio_button_unchecked,
          'Sen rexistro',
          Colors.white.withAlpha(100),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(45),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(120), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: Colors.white),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Chips de léxico inglés ───────────────────────────────────────────────────

/// El pie de la tarjeta del carrusel: cuánto dura la sesión de ese mes.
class _PieDuracion extends StatelessWidget {
  final int minutos;

  const _PieDuracion({required this.minutos});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Row(
        children: [
          const Icon(Icons.timer_rounded, size: 14, color: AppTheme.textMuted),
          const SizedBox(width: 5),
          // Flexible y con puntos suspensivos: en gallego la línea es más
          // larga, y con el texto grande del sistema más todavía. Lo que se
          // recorta se ve; un desbordamiento en release no se ve.
          Flexible(
            child: Text(
              '$minutos min',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
