import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

// ─── Tokens de paleta atlántica cálida (misma que tarjeta_mes_curricular) ────
const _aguamarina = Color(0xFF00838F);
const _coral = Color(0xFFFF7043);
const _ambar = Color(0xFFFFB300);
const _menta = Color(0xFFE0F2F1);
const _mentaDark = Color(0xFF4DB6AC);
const _violeta = Color(0xFF7C4DFF);
const _rose = Color(0xFFF06292);

// ─── Enumerado de medallas ────────────────────────────────────────────────────

/// Categorías de medalla para docentes y familias.
enum TipoMedalla {
  // ── Familia ──────────────────────────────────────────────────
  /// Primera rutina completada en casa.
  primerPasoFamilia,

  /// 5 días de estimulación en el hogar.
  constanciaFamilia,

  /// Doble estimulación lograda hoy.
  dobleSincronia,

  /// 10 sesiones de hogar acumuladas.
  embajadoraFamilia,

  /// Un mes completo de participación.
  mesCompleto,

  // ── Docente ──────────────────────────────────────────────────
  /// Primera asamblea registrada.
  primerAsambleaDocente,

  /// 5 asambleas seguidas sin falta.
  rachaAula,

  /// Toda la clase logró doble estimulación en una semana.
  claseEstrella,

  /// 10 sesiones de aula acumuladas.
  maestraConectada,

  /// Completó los 10 meses curriculares.
  curriculo10Meses,
}

extension TipoMedallaX on TipoMedalla {
  bool get esDocente => [
        TipoMedalla.primerAsambleaDocente,
        TipoMedalla.rachaAula,
        TipoMedalla.claseEstrella,
        TipoMedalla.maestraConectada,
        TipoMedalla.curriculo10Meses,
      ].contains(this);

  String titulo(String lang) => switch (this) {
        TipoMedalla.primerPasoFamilia =>
          lang == 'es' ? '¡Primer Paso!' : '¡Primeiro Paso!',
        TipoMedalla.constanciaFamilia =>
          lang == 'es' ? 'Familia Constante' : 'Familia Constante',
        TipoMedalla.dobleSincronia =>
          lang == 'es' ? 'Doble Sincronía' : 'Dobre Sincronía',
        TipoMedalla.embajadoraFamilia =>
          lang == 'es' ? 'Embajadora del Hogar' : 'Embaixadora do Fogar',
        TipoMedalla.mesCompleto =>
          lang == 'es' ? 'Mes Completo' : 'Mes Completo',
        TipoMedalla.primerAsambleaDocente =>
          lang == 'es' ? '¡Primera Asamblea!' : '¡Primeira Asemblea!',
        TipoMedalla.rachaAula =>
          lang == 'es' ? 'Racha en el Aula' : 'Racha na Aula',
        TipoMedalla.claseEstrella =>
          lang == 'es' ? 'Clase Estrella' : 'Clase Estrela',
        TipoMedalla.maestraConectada =>
          lang == 'es' ? 'Maestra Conectada' : 'Mestra Conectada',
        TipoMedalla.curriculo10Meses =>
          lang == 'es' ? '10 Meses · Logro Máximo' : '10 Meses · Logro Máximo',
      };

  String descripcion(String lang) => switch (this) {
        TipoMedalla.primerPasoFamilia =>
          lang == 'es'
              ? 'Completaste la primera rutina en casa. ¡Lúa está contenta!'
              : 'Completaches a primeira rutina na casa. ¡Lúa está contenta!',
        TipoMedalla.constanciaFamilia =>
          lang == 'es'
              ? '5 días de estimulación en el hogar. ¡Qué familia más comprometida!'
              : '5 días de estimulación no fogar. ¡Que familia máis comprometida!',
        TipoMedalla.dobleSincronia =>
          lang == 'es'
              ? 'Aula y hogar el mismo día. La Doble Estimulación funciona.'
              : 'Aula e fogar o mesmo día. A Dobre Estimulación funciona.',
        TipoMedalla.embajadoraFamilia =>
          lang == 'es'
              ? '10 sesiones en casa. Eres embajadora de la estimulación temprana.'
              : '10 sesións na casa. Es embaixadora da estimulación temperá.',
        TipoMedalla.mesCompleto =>
          lang == 'es'
              ? 'Un mes entero de participación activa. ¡Increíble!'
              : 'Un mes enteiro de participación activa. ¡Incrível!',
        TipoMedalla.primerAsambleaDocente =>
          lang == 'es'
              ? 'Primera asamblea matinal registrada. ¡El curso comienza!'
              : 'Primeira asemblea matinal rexistrada. ¡O curso comeza!',
        TipoMedalla.rachaAula =>
          lang == 'es'
              ? '5 asambleas seguidas. La rutina del aula ya está consolidada.'
              : '5 asambleas seguidas. A rutina da aula xa está consolidada.',
        TipoMedalla.claseEstrella =>
          lang == 'es'
              ? 'Toda la clase logró Doble Estimulación esta semana.'
              : 'Toda a clase logrou Dobre Estimulación esta semana.',
        TipoMedalla.maestraConectada =>
          lang == 'es'
              ? '10 sesiones de aula. Maestra comprometida con el desarrollo.'
              : '10 sesións de aula. Mestra comprometida co desenvolvemento.',
        TipoMedalla.curriculo10Meses =>
          lang == 'es'
              ? '¡Los 10 meses completados! Logro máximo del curso.'
              : '¡Os 10 meses completados! Logro máximo do curso.',
      };

  /// Color primario de la medalla.
  Color get color => switch (this) {
        TipoMedalla.primerPasoFamilia => _mentaDark,
        TipoMedalla.constanciaFamilia => _aguamarina,
        TipoMedalla.dobleSincronia => _ambar,
        TipoMedalla.embajadoraFamilia => _coral,
        TipoMedalla.mesCompleto => _rose,
        TipoMedalla.primerAsambleaDocente => _mentaDark,
        TipoMedalla.rachaAula => _aguamarina,
        TipoMedalla.claseEstrella => _ambar,
        TipoMedalla.maestraConectada => _violeta,
        TipoMedalla.curriculo10Meses => _coral,
      };

  /// Color secundario (borde/degradado) de la medalla.
  Color get colorSecundario => switch (this) {
        TipoMedalla.primerPasoFamilia => _menta,
        TipoMedalla.constanciaFamilia => const Color(0xFF00BFA5),
        TipoMedalla.dobleSincronia => const Color(0xFFFFD54F),
        TipoMedalla.embajadoraFamilia => const Color(0xFFFF8A65),
        TipoMedalla.mesCompleto => const Color(0xFFF48FB1),
        TipoMedalla.primerAsambleaDocente => const Color(0xFF80CBC4),
        TipoMedalla.rachaAula => const Color(0xFF26C6DA),
        TipoMedalla.claseEstrella => const Color(0xFFFFCC02),
        TipoMedalla.maestraConectada => const Color(0xFFB39DDB),
        TipoMedalla.curriculo10Meses => const Color(0xFFFF5722),
      };

  /// Cuántos puntos XP otorga esta medalla.
  int get xp => switch (this) {
        TipoMedalla.primerPasoFamilia => 10,
        TipoMedalla.primerAsambleaDocente => 10,
        TipoMedalla.constanciaFamilia => 25,
        TipoMedalla.rachaAula => 25,
        TipoMedalla.dobleSincronia => 50,
        TipoMedalla.claseEstrella => 50,
        TipoMedalla.embajadoraFamilia => 75,
        TipoMedalla.maestraConectada => 75,
        TipoMedalla.mesCompleto => 100,
        TipoMedalla.curriculo10Meses => 200,
      };
}

// ─── Widget de medalla individual ────────────────────────────────────────────

/// Medalla vectorial animada para docentes y familias.
///
/// Dibujada 100% con [CustomPainter]: sin imágenes PNG, alineado con el
/// estilo pixel art de Lúa y la paleta atlántica cálida.
class MedallaWidget extends StatefulWidget {
  final TipoMedalla tipo;
  final bool desbloqueada;

  /// Si es [null] se usa el idioma del [Locale] del contexto.
  final String? lang;

  /// Tamaño del medallón (diámetro de la zona circular). Default 80.
  final double size;

  /// Mostrar etiqueta de título debajo de la medalla.
  final bool showLabel;

  const MedallaWidget({
    super.key,
    required this.tipo,
    this.desbloqueada = true,
    this.lang,
    this.size = 80,
    this.showLabel = true,
  });

  @override
  State<MedallaWidget> createState() => _MedallaWidgetState();
}

class _MedallaWidgetState extends State<MedallaWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shine;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _shine = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    if (widget.desbloqueada) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.lang ??
        Localizations.localeOf(context).languageCode;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _shine,
          builder: (_, __) => CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _MedallaPainter(
              tipo: widget.tipo,
              desbloqueada: widget.desbloqueada,
              shineValue: widget.desbloqueada ? _shine.value : 0,
            ),
          ),
        ),
        if (widget.showLabel) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: widget.size + 16,
            child: Text(
              widget.desbloqueada
                  ? widget.tipo.titulo(lang)
                  : (lang == 'es' ? 'Bloqueada' : 'Bloqueada'),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: widget.desbloqueada
                    ? AppTheme.textPrimary
                    : AppTheme.textMuted,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _MedallaPainter extends CustomPainter {
  final TipoMedalla tipo;
  final bool desbloqueada;
  final double shineValue;

  const _MedallaPainter({
    required this.tipo,
    required this.desbloqueada,
    required this.shineValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 * 0.88;

    if (!desbloqueada) {
      _dibujarBloqueada(canvas, cx, cy, r);
      return;
    }

    // ── 1. Sombra exterior ───────────────────────────────────────────────────
    final sombra = Paint()
      ..color = tipo.color.withAlpha(50)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(cx, cy + 3), r, sombra);

    // ── 2. Rayos de fondo (tipo sol / estrella) ──────────────────────────────
    _dibujarRayos(canvas, cx, cy, r);

    // ── 3. Cuerpo circular principal con degradado ───────────────────────────
    final grad = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 1.1,
      colors: [tipo.colorSecundario, tipo.color],
    );
    final circuloPaint = Paint()
      ..shader = grad.createShader(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
      );
    canvas.drawCircle(Offset(cx, cy), r, circuloPaint);

    // ── 4. Borde metálico doble ──────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = Colors.white.withAlpha(70)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r - 3,
      Paint()
        ..color = tipo.color.withAlpha(120)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // ── 5. Brillo animado (lens flare suave) ─────────────────────────────────
    final shineX = cx - r * 0.3 + shineValue * r * 0.15;
    final shineY = cy - r * 0.35;
    canvas.drawCircle(
      Offset(shineX, shineY),
      r * 0.22 * (0.6 + shineValue * 0.4),
      Paint()..color = Colors.white.withAlpha((40 + shineValue * 60).toInt()),
    );

    // ── 6. Icono central del tipo de medalla ─────────────────────────────────
    _dibujarIconoCentral(canvas, cx, cy, r * 0.48);

    // ── 7. XP badge ──────────────────────────────────────────────────────────
    _dibujarXpBadge(canvas, cx, cy, r, size);
  }

  void _dibujarBloqueada(Canvas canvas, double cx, double cy, double r) {
    // Fondo gris
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = const Color(0xFFE0E0E0),
    );
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFBDBDBD)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    // Candado
    _dibujarCandado(canvas, cx, cy, r * 0.5);
  }

  void _dibujarCandado(Canvas canvas, double cx, double cy, double sz) {
    final p = Paint()..color = Colors.white.withAlpha(200);
    // Arco superior
    final arcRect = Rect.fromCenter(
      center: Offset(cx, cy - sz * 0.2),
      width: sz,
      height: sz * 0.8,
    );
    canvas.drawArc(arcRect, math.pi, math.pi, false,
        Paint()
          ..color = Colors.white.withAlpha(200)
          ..style = PaintingStyle.stroke
          ..strokeWidth = sz * 0.2
          ..strokeCap = StrokeCap.round);
    // Cuerpo
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(cx, cy + sz * 0.22), width: sz, height: sz * 0.7),
        Radius.circular(sz * 0.1),
      ),
      p,
    );
    // Ojo del candado
    canvas.drawCircle(
      Offset(cx, cy + sz * 0.18),
      sz * 0.12,
      Paint()..color = const Color(0xFFBDBDBD),
    );
  }

  void _dibujarRayos(Canvas canvas, double cx, double cy, double r) {
    final rayPaint = Paint()
      ..color = tipo.colorSecundario.withAlpha(30)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const numRayos = 12;
    for (int i = 0; i < numRayos; i++) {
      final angle = (math.pi * 2 / numRayos) * i;
      canvas.drawLine(
        Offset(cx + math.cos(angle) * (r + 2), cy + math.sin(angle) * (r + 2)),
        Offset(
            cx + math.cos(angle) * (r + 8), cy + math.sin(angle) * (r + 8)),
        rayPaint,
      );
    }
  }

  void _dibujarXpBadge(
      Canvas canvas, double cx, double cy, double r, Size size) {
    final bx = size.width - r * 0.35;
    final by = r * 0.35;
    canvas.drawCircle(
      Offset(bx, by),
      r * 0.28,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      Offset(bx, by),
      r * 0.28,
      Paint()
        ..color = tipo.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // Texto XP (lo dibujo como líneas geométricas, sin TextPainter)
    // Usamos un rectángulo pequeño como placeholder del badge
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(bx, by), width: r * 0.46, height: r * 0.26),
        Radius.circular(r * 0.08),
      ),
      Paint()..color = tipo.color.withAlpha(20),
    );
  }

  void _dibujarIconoCentral(Canvas canvas, double cx, double cy, double r) {
    switch (tipo) {
      case TipoMedalla.primerPasoFamilia:
      case TipoMedalla.primerAsambleaDocente:
        _iconoEstrella(canvas, cx, cy, r, 5);
        break;
      case TipoMedalla.constanciaFamilia:
      case TipoMedalla.rachaAula:
        _iconoRelampago(canvas, cx, cy, r);
        break;
      case TipoMedalla.dobleSincronia:
      case TipoMedalla.claseEstrella:
        _iconoEstrella(canvas, cx, cy, r, 6);
        break;
      case TipoMedalla.embajadoraFamilia:
      case TipoMedalla.maestraConectada:
        _iconoCorazon(canvas, cx, cy, r);
        break;
      case TipoMedalla.mesCompleto:
        _iconoOnda(canvas, cx, cy, r);
        break;
      case TipoMedalla.curriculo10Meses:
        _iconoTrofeo(canvas, cx, cy, r);
        break;
    }
  }

  // ── Iconos centrales ────────────────────────────────────────────────────────

  void _iconoEstrella(
      Canvas canvas, double cx, double cy, double r, int puntas) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path();
    final rOuter = r;
    final rInner = r * 0.42;
    for (int i = 0; i < puntas * 2; i++) {
      final angle = (math.pi / puntas) * i - math.pi / 2;
      final radio = i.isEven ? rOuter : rInner;
      final x = cx + math.cos(angle) * radio;
      final y = cy + math.sin(angle) * radio;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
    // Sombra interior
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withAlpha(15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _iconoRelampago(Canvas canvas, double cx, double cy, double r) {
    final path = Path()
      ..moveTo(cx + r * 0.15, cy - r)
      ..lineTo(cx - r * 0.25, cy + r * 0.05)
      ..lineTo(cx + r * 0.05, cy + r * 0.05)
      ..lineTo(cx - r * 0.15, cy + r)
      ..lineTo(cx + r * 0.35, cy - r * 0.05)
      ..lineTo(cx + r * 0.05, cy - r * 0.05)
      ..close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _iconoCorazon(Canvas canvas, double cx, double cy, double r) {
    final path = Path();
    final scale = r / 14.0;
    path.moveTo(cx, cy + 8 * scale);
    path.cubicTo(
        cx - 2 * scale, cy + 5 * scale,
        cx - 14 * scale, cy,
        cx - 10 * scale, cy - 8 * scale);
    path.cubicTo(
        cx - 7 * scale, cy - 14 * scale,
        cx, cy - 8 * scale,
        cx, cy - 3 * scale);
    path.cubicTo(
        cx, cy - 8 * scale,
        cx + 7 * scale, cy - 14 * scale,
        cx + 10 * scale, cy - 8 * scale);
    path.cubicTo(
        cx + 14 * scale, cy,
        cx + 2 * scale, cy + 5 * scale,
        cx, cy + 8 * scale);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);
  }

  void _iconoOnda(Canvas canvas, double cx, double cy, double r) {
    for (int i = 0; i < 3; i++) {
      final y = cy - r * 0.3 + i * r * 0.3;
      final paint = Paint()
        ..color = Colors.white.withAlpha(200 - i * 50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = r * 0.18 - i * r * 0.04
        ..strokeCap = StrokeCap.round;
      final path = Path()..moveTo(cx - r, y);
      for (double x = cx - r; x <= cx + r; x += 2) {
        final t = (x - (cx - r)) / (2 * r);
        path.lineTo(x, y + math.sin(t * math.pi * 2) * r * 0.3);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _iconoTrofeo(Canvas canvas, double cx, double cy, double r) {
    final p = Paint()..color = Colors.white;
    // Copa
    final copa = Path()
      ..moveTo(cx - r * 0.6, cy - r * 0.6)
      ..lineTo(cx + r * 0.6, cy - r * 0.6)
      ..quadraticBezierTo(cx + r * 0.55, cy + r * 0.1, cx, cy + r * 0.3)
      ..quadraticBezierTo(cx - r * 0.55, cy + r * 0.1, cx - r * 0.6, cy - r * 0.6)
      ..close();
    canvas.drawPath(copa, p);
    // Pie
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(cx, cy + r * 0.65),
          width: r * 0.7,
          height: r * 0.18,
        ),
        const Radius.circular(3),
      ),
      p,
    );
    // Soporte
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, cy + r * 0.47),
        width: r * 0.18,
        height: r * 0.35,
      ),
      p,
    );
    // Asas laterales
    for (int lado in [-1, 1]) {
      final asaPath = Path()
        ..moveTo(cx + lado * r * 0.55, cy - r * 0.45)
        ..quadraticBezierTo(
          cx + lado * r * 0.9, cy - r * 0.45,
          cx + lado * r * 0.9, cy - r * 0.1,
        )
        ..quadraticBezierTo(
          cx + lado * r * 0.9, cy + r * 0.1,
          cx + lado * r * 0.55, cy + r * 0.05,
        );
      canvas.drawPath(
        asaPath,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.15
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_MedallaPainter old) =>
      old.tipo != tipo ||
      old.desbloqueada != desbloqueada ||
      old.shineValue != shineValue;
}

// ─── Pantalla / panel de premios ──────────────────────────────────────────────

/// Panel de premios con el mosaico de medallas de familias y docentes.
///
/// Puede usarse como pantalla completa o como sección dentro de otra pantalla.
class PremiosPanelWidget extends StatelessWidget {
  final bool esDocente;
  final Set<TipoMedalla> medallasDesbloqueadas;
  final String lang;

  const PremiosPanelWidget({
    super.key,
    required this.esDocente,
    required this.medallasDesbloqueadas,
    this.lang = 'gl',
  });

  @override
  Widget build(BuildContext context) {
    final medallas = TipoMedalla.values
        .where((m) => m.esDocente == esDocente)
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: esDocente
                    ? [const Color(0xFF127A75), const Color(0xFF00838F)]
                    : [const Color(0xFFFF7043), const Color(0xFFFFB300)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusCard),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  esDocente ? Icons.school_rounded : Icons.home_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        esDocente
                            ? (lang == 'es' ? 'Premios · Docentes' : 'Premios · Docentes')
                            : (lang == 'es' ? 'Premios · Familias' : 'Premios · Familias'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${medallasDesbloqueadas.where((m) => m.esDocente == esDocente).length} / ${medallas.length} desbloqueadas',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Progreso circular
                _ProgresCircular(
                  total: medallas.length,
                  desbloqueadas: medallasDesbloqueadas
                      .where((m) => m.esDocente == esDocente)
                      .length,
                ),
              ],
            ),
          ),
          // Mosaico de medallas
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 8,
              childAspectRatio: 0.75,
              children: medallas.map((medalla) {
                final desbloqueada = medallasDesbloqueadas.contains(medalla);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MedallaWidget(
                      tipo: medalla,
                      desbloqueada: desbloqueada,
                      lang: lang,
                      size: 72,
                      showLabel: false,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desbloqueada
                          ? medalla.titulo(lang)
                          : '???',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: desbloqueada
                            ? AppTheme.textPrimary
                            : AppTheme.textMuted,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (desbloqueada)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: medalla.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '+${medalla.xp} XP',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: medalla.color,
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Progreso circular en cabecera ───────────────────────────────────────────

class _ProgresCircular extends StatelessWidget {
  final int total;
  final int desbloqueadas;
  const _ProgresCircular({required this.total, required this.desbloqueadas});

  @override
  Widget build(BuildContext context) {
    final porcentaje = total > 0 ? desbloqueadas / total : 0.0;
    return SizedBox(
      width: 44,
      height: 44,
      child: CustomPaint(
        painter: _CircularProgressP(porcentaje: porcentaje),
        child: Center(
          child: Text(
            '$desbloqueadas',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _CircularProgressP extends CustomPainter {
  final double porcentaje;
  const _CircularProgressP({required this.porcentaje});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 3;
    // Fondo
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()..color = Colors.white.withAlpha(30),
    );
    // Arco de progreso
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      math.pi * 2 * porcentaje,
      false,
      Paint()
        ..color = Colors.white.withAlpha(220)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressP old) => old.porcentaje != porcentaje;
}

// ─── Toast de medalla desbloqueada ───────────────────────────────────────────

/// Muestra una notificación elegante cuando se desbloquea una medalla.
/// Llama desde cualquier [BuildContext] tras una acción que la otorgue.
void mostrarMedallaDesbloqueada(
  BuildContext context, {
  required TipoMedalla medalla,
  String lang = 'gl',
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _MedallaToast(
      medalla: medalla,
      lang: lang,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _MedallaToast extends StatefulWidget {
  final TipoMedalla medalla;
  final String lang;
  final VoidCallback onDismiss;
  const _MedallaToast(
      {required this.medalla, required this.lang, required this.onDismiss});

  @override
  State<_MedallaToast> createState() => _MedallaToastState();
}

class _MedallaToastState extends State<_MedallaToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _salir);
  }

  void _salir() async {
    if (mounted) {
      await _ctrl.reverse();
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    widget.medalla.colorSecundario,
                    widget.medalla.color,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: widget.medalla.color.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  MedallaWidget(
                    tipo: widget.medalla,
                    desbloqueada: true,
                    lang: widget.lang,
                    size: 52,
                    showLabel: false,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.lang == 'es'
                              ? '🏅 ¡Medalla desbloqueada!'
                              : '🏅 ¡Medalla desbloqueada!',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.medalla.titulo(widget.lang),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '+${widget.medalla.xp} XP',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withAlpha(220),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _salir,
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
