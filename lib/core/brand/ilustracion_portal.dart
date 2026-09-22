import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Ilustración vectorial personalizada para a tarxeta do Portal Familias.
///
/// Simboliza o fogar acolledor e a crianza: a persoa adulta e a crianza
/// compartindo un conto xunto á gata Lúa, baixo a luz cálida do sol matinal,
/// sen pantallas infantís.
class IlustracionFamilia extends StatelessWidget {
  final double width;
  final double height;

  const IlustracionFamilia({
    super.key,
    this.width = double.infinity,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _FamiliaPainter(),
      ),
    );
  }
}

class _FamiliaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fondo suave con gradiente cálido
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(16),
    );
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFF9EE),
          Color(0xFFFDE8CF),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(bgRect, bgPaint);

    // Borde sutil
    final borderPaint = Paint()
      ..color = const Color(0xFFF6D4A0).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bgRect, borderPaint);

    // Sol cálido no fondo esquerdo
    final sunPaint = Paint()
      ..color = const Color(0xFFFFD56B).withValues(alpha: 0.5);
    canvas.drawCircle(Offset(w * 0.18, h * 0.35), h * 0.26, sunPaint);

    final sunInner = Paint()
      ..color = const Color(0xFFFFE89E).withValues(alpha: 0.7);
    canvas.drawCircle(Offset(w * 0.18, h * 0.35), h * 0.16, sunInner);

    // Ventana / Arco de acollemento do fogar
    final houseArchPath = Path()
      ..moveTo(w * 0.40, h * 0.88)
      ..lineTo(w * 0.40, h * 0.30)
      ..arcToPoint(
        Offset(w * 0.88, h * 0.30),
        radius: Radius.circular(w * 0.24),
        clockwise: true,
      )
      ..lineTo(w * 0.88, h * 0.88)
      ..close();
    final archPaint = Paint()
      ..color = const Color(0xFFFAF2E4).withValues(alpha: 0.7);
    canvas.drawPath(houseArchPath, archPaint);

    // Planta / Elemento natural de Vigo na ventá
    final plantStemPaint = Paint()
      ..color = const Color(0xFF76A035).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(
        Offset(w * 0.84, h * 0.82), Offset(w * 0.84, h * 0.58), plantStemPaint);

    final leafPaint = Paint()..color = const Color(0xFF8BB741);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.81, h * 0.64), width: 14, height: 8),
      leafPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.87, h * 0.60), width: 14, height: 8),
      leafPaint,
    );

    // Chán / Alfombra suave de lectura
    final rugPaint = Paint()
      ..color = const Color(0xFFF3C38A).withValues(alpha: 0.5);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w * 0.52, h * 0.88),
        width: w * 0.72,
        height: h * 0.22,
      ),
      rugPaint,
    );

    // --- Persoa Adulta (Pai / Nai / Coidador) ---
    final adultCenterX = w * 0.38;
    final adultCenterY = h * 0.54;

    // Corpo do adulto (camisola azul mariño Vigo suave)
    final adultBodyPaint = Paint()..color = const Color(0xFF2C5282);
    final adultBodyPath = Path()
      ..moveTo(adultCenterX - 22, h * 0.86)
      ..quadraticBezierTo(
        adultCenterX - 20,
        adultCenterY + 12,
        adultCenterX - 14,
        adultCenterY + 4,
      )
      ..quadraticBezierTo(
        adultCenterX,
        adultCenterY,
        adultCenterX + 16,
        adultCenterY + 6,
      )
      ..quadraticBezierTo(
        adultCenterX + 24,
        adultCenterY + 16,
        adultCenterX + 22,
        h * 0.86,
      )
      ..close();
    canvas.drawPath(adultBodyPath, adultBodyPaint);

    // Cabeza do adulto
    final skinPaint = Paint()..color = const Color(0xFFF7C8A5);
    canvas.drawCircle(Offset(adultCenterX, adultCenterY - 14), 13, skinPaint);

    // Pelo do adulto (castaño cálido)
    final hairPaint = Paint()..color = const Color(0xFF5A3E28);
    final hairPath = Path()
      ..addArc(
        Rect.fromCircle(
            center: Offset(adultCenterX, adultCenterY - 15), radius: 14),
        math.pi * 0.8,
        math.pi * 1.4,
      );
    canvas.drawPath(hairPath, hairPaint);

    // Brazo do adulto rodeando con afecto
    final adultArmPaint = Paint()
      ..color = const Color(0xFF23446D)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final armPath = Path()
      ..moveTo(adultCenterX + 12, adultCenterY + 14)
      ..quadraticBezierTo(
        adultCenterX + 26,
        adultCenterY + 28,
        adultCenterX + 36,
        h * 0.74,
      );
    canvas.drawPath(armPath, adultArmPaint);

    // --- Crianza (Neno / Nena de colo / xogo) ---
    final childCenterX = w * 0.55;
    final childCenterY = h * 0.64;

    // Corpo da crianza (mostaza / ocre cálido)
    final childBodyPaint = Paint()..color = const Color(0xFFE08838);
    final childBodyPath = Path()
      ..moveTo(childCenterX - 14, h * 0.86)
      ..quadraticBezierTo(
        childCenterX - 12,
        childCenterY + 10,
        childCenterX - 8,
        childCenterY + 4,
      )
      ..quadraticBezierTo(
        childCenterX,
        childCenterY,
        childCenterX + 10,
        childCenterY + 6,
      )
      ..quadraticBezierTo(
        childCenterX + 16,
        childCenterY + 14,
        childCenterX + 14,
        h * 0.86,
      )
      ..close();
    canvas.drawPath(childBodyPath, childBodyPaint);

    // Cabeza da crianza
    canvas.drawCircle(Offset(childCenterX, childCenterY - 10), 9.5, skinPaint);

    // Pelo da crianza (dourado / castaño claro)
    final childHairPaint = Paint()..color = const Color(0xFFB5702A);
    final childHairPath = Path()
      ..addArc(
        Rect.fromCircle(
            center: Offset(childCenterX, childCenterY - 11), radius: 10.5),
        math.pi * 0.7,
        math.pi * 1.4,
      );
    canvas.drawPath(childHairPath, childHairPaint);

    // --- Conto aberto nas mans (lectura dialóxica) ---
    final bookCenterX = w * 0.46;
    final bookCenterY = h * 0.76;

    final bookCoverPaint = Paint()..color = const Color(0xFFB83232);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(bookCenterX, bookCenterY), width: 34, height: 18),
        const Radius.circular(3),
      ),
      bookCoverPaint,
    );

    final bookPagesPaint = Paint()..color = Colors.white;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
            center: Offset(bookCenterX, bookCenterY - 1.5),
            width: 31,
            height: 15),
        const Radius.circular(2),
      ),
      bookPagesPaint,
    );

    // Liñas de conto
    final bookLinesPaint = Paint()
      ..color = const Color(0xFF718096)
      ..strokeWidth = 1.2;
    canvas.drawLine(
      Offset(bookCenterX - 11, bookCenterY - 3),
      Offset(bookCenterX - 3, bookCenterY - 3),
      bookLinesPaint,
    );
    canvas.drawLine(
      Offset(bookCenterX - 11, bookCenterY + 1),
      Offset(bookCenterX - 4, bookCenterY + 1),
      bookLinesPaint,
    );
    canvas.drawLine(
      Offset(bookCenterX + 3, bookCenterY - 3),
      Offset(bookCenterX + 11, bookCenterY - 3),
      bookLinesPaint,
    );
    canvas.drawLine(
      Offset(bookCenterX + 4, bookCenterY + 1),
      Offset(bookCenterX + 11, bookCenterY + 1),
      bookLinesPaint,
    );

    // --- Lúa, a gata compañeira, sentada acariciando ---
    final luaCenterX = w * 0.72;
    final luaCenterY = h * 0.75;

    // Corpo de Lúa
    final luaBodyPaint = Paint()..color = const Color(0xFF4A5568);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(luaCenterX, luaCenterY + 8),
        width: 22,
        height: 18,
      ),
      luaBodyPaint,
    );

    // Cabeza de Lúa
    canvas.drawCircle(Offset(luaCenterX, luaCenterY - 3), 9, luaBodyPaint);

    // Orellas de Lúa
    final earPaint = Paint()..color = const Color(0xFF2D3748);
    final earLeft = Path()
      ..moveTo(luaCenterX - 8, luaCenterY - 6)
      ..lineTo(luaCenterX - 5, luaCenterY - 14)
      ..lineTo(luaCenterX - 1, luaCenterY - 9)
      ..close();
    final earRight = Path()
      ..moveTo(luaCenterX + 1, luaCenterY - 9)
      ..lineTo(luaCenterX + 5, luaCenterY - 14)
      ..lineTo(luaCenterX + 8, luaCenterY - 6)
      ..close();
    canvas.drawPath(earLeft, earPaint);
    canvas.drawPath(earRight, earPaint);

    // Olliños pechados de felicidade de Lúa
    final eyePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(luaCenterX - 3.5, luaCenterY - 3),
          width: 4,
          height: 3),
      0,
      math.pi,
      false,
      eyePaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(luaCenterX + 3.5, luaCenterY - 3),
          width: 4,
          height: 3),
      0,
      math.pi,
      false,
      eyePaint,
    );

    // Rabo de Lúa
    final tailPaint = Paint()
      ..color = const Color(0xFF4A5568)
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path()
      ..moveTo(luaCenterX + 10, luaCenterY + 12)
      ..quadraticBezierTo(
        luaCenterX + 18,
        luaCenterY + 6,
        luaCenterX + 16,
        luaCenterY - 2,
      );
    canvas.drawPath(tailPath, tailPaint);

    // Corazón flotante sutil de afecto
    final heartPaint = Paint()
      ..color = const Color(0xFFE53E3E).withValues(alpha: 0.85);
    final heartPath = Path();
    final hx = w * 0.47;
    final hy = h * 0.40;
    heartPath.moveTo(hx, hy);
    heartPath.cubicTo(hx - 5, hy - 6, hx - 10, hy + 2, hx, hy + 9);
    heartPath.cubicTo(hx + 10, hy + 2, hx + 5, hy - 6, hx, hy);
    canvas.drawPath(heartPath, heartPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Ilustración vectorial personalizada para a tarxeta do Portal Docentes.
///
/// Simboliza unha Escola Infantil Municipal de Vigo: edificio escolar
/// acolledor con torre de campá/reloxo, xardín de árbores, porta aberta
/// e o círculo da asemblea pedagóxica a 72 bpm.
class IlustracionEscola extends StatelessWidget {
  final double width;
  final double height;

  const IlustracionEscola({
    super.key,
    this.width = double.infinity,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EscolaPainter(),
      ),
    );
  }
}

class _EscolaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Fondo suave con gradiente azul mar de Vigo e celur
    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, w, h),
      const Radius.circular(16),
    );
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFEFF6FC),
          Color(0xFFDCEBFA),
        ],
      ).createShader(Rect.fromLTWH(0, 0, w, h));
    canvas.drawRRect(bgRect, bgPaint);

    // Borde sutil
    final borderPaint = Paint()
      ..color = const Color(0xFFBBD7F5).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawRRect(bgRect, borderPaint);

    // Nubes suaves no ceo
    final cloudPaint = Paint()..color = Colors.white.withValues(alpha: 0.85);
    canvas.drawCircle(Offset(w * 0.15, h * 0.25), 14, cloudPaint);
    canvas.drawCircle(Offset(w * 0.21, h * 0.22), 18, cloudPaint);
    canvas.drawCircle(Offset(w * 0.27, h * 0.26), 13, cloudPaint);

    canvas.drawCircle(Offset(w * 0.78, h * 0.22), 12, cloudPaint);
    canvas.drawCircle(Offset(w * 0.84, h * 0.19), 16, cloudPaint);
    canvas.drawCircle(Offset(w * 0.89, h * 0.23), 11, cloudPaint);

    // Pradería / Chan da escola infantil
    final groundPaint = Paint()..color = const Color(0xFFD4E7B8);
    final groundPath = Path()
      ..moveTo(0, h * 0.82)
      ..quadraticBezierTo(w * 0.5, h * 0.76, w, h * 0.82)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(groundPath, groundPaint);

    // Árbore esquerda (Castiñeiro / Carballo galego)
    final trunkPaint = Paint()
      ..color = const Color(0xFF7A512D)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
        Offset(w * 0.14, h * 0.84), Offset(w * 0.14, h * 0.55), trunkPaint);

    final foliagePaint1 = Paint()..color = const Color(0xFF5B8A3C);
    canvas.drawCircle(Offset(w * 0.14, h * 0.48), 22, foliagePaint1);
    final foliagePaint2 = Paint()..color = const Color(0xFF6DA248);
    canvas.drawCircle(Offset(w * 0.17, h * 0.44), 16, foliagePaint2);

    // Árbore dereita
    canvas.drawLine(
        Offset(w * 0.88, h * 0.85), Offset(w * 0.88, h * 0.60), trunkPaint);
    final foliagePaintRight = Paint()..color = const Color(0xFF5B8A3C);
    canvas.drawCircle(Offset(w * 0.88, h * 0.52), 20, foliagePaintRight);

    // --- Edificio Central da Escola Infantil ---
    final schoolLeft = w * 0.30;
    final schoolWidth = w * 0.42;
    final schoolHeight = h * 0.46;
    final schoolTop = h * 0.82 - schoolHeight;

    // Paredes da escola (crema suave institucional)
    final wallPaint = Paint()..color = const Color(0xFFFFFDF5);
    final wallRect =
        Rect.fromLTWH(schoolLeft, schoolTop, schoolWidth, schoolHeight);
    canvas.drawRect(wallRect, wallPaint);

    // Borde do edificio
    final wallBorderPaint = Paint()
      ..color = const Color(0xFFCBD5E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(wallRect, wallBorderPaint);

    // Teito a dúas augas (terracota / tella Vigo)
    final roofPath = Path()
      ..moveTo(schoolLeft - 8, schoolTop)
      ..lineTo(schoolLeft + schoolWidth / 2, schoolTop - h * 0.16)
      ..lineTo(schoolLeft + schoolWidth + 8, schoolTop)
      ..close();
    final roofPaint = Paint()..color = const Color(0xFFC54A2D);
    canvas.drawPath(roofPath, roofPaint);

    // Torresiña central co reloxo / campá
    final towerWidth = w * 0.11;
    final towerHeight = h * 0.16;
    final towerLeft = schoolLeft + schoolWidth / 2 - towerWidth / 2;
    final towerTop = schoolTop - h * 0.16 - towerHeight + 4;

    final towerPaint = Paint()..color = const Color(0xFFF7FAFC);
    canvas.drawRect(
      Rect.fromLTWH(towerLeft, towerTop, towerWidth, towerHeight),
      towerPaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(towerLeft, towerTop, towerWidth, towerHeight),
      wallBorderPaint,
    );

    // Teito piramidal da torresiña
    final spirePath = Path()
      ..moveTo(towerLeft - 3, towerTop)
      ..lineTo(towerLeft + towerWidth / 2, towerTop - 12)
      ..lineTo(towerLeft + towerWidth + 3, towerTop)
      ..close();
    canvas.drawPath(spirePath, roofPaint);

    // Reloxo na torre (marca as 9:00, hora da asemblea)
    final clockCenter =
        Offset(towerLeft + towerWidth / 2, towerTop + towerHeight * 0.52);
    final clockBg = Paint()..color = Colors.white;
    canvas.drawCircle(clockCenter, 7, clockBg);
    final clockBorder = Paint()
      ..color = const Color(0xFF2B6CB0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawCircle(clockCenter, 7, clockBorder);

    // Agullas ás 9:00
    final handPaint = Paint()
      ..color = const Color(0xFF1A365D)
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(clockCenter, Offset(clockCenter.dx, clockCenter.dy - 4.5),
        handPaint); // 12
    canvas.drawLine(clockCenter, Offset(clockCenter.dx - 3.5, clockCenter.dy),
        handPaint); // 9

    // Fiestras con arco (Infantil / Luz natural)
    final winPaint = Paint()..color = const Color(0xFFBEE3F8);
    final winBorder = Paint()
      ..color = const Color(0xFF2B6CB0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Fiestra esquerda
    final winLeftRect = Rect.fromLTWH(schoolLeft + 10, schoolTop + 14, 18, 22);
    canvas.drawRRect(
        RRect.fromRectAndRadius(winLeftRect, const Radius.circular(8)),
        winPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(winLeftRect, const Radius.circular(8)),
        winBorder);

    // Fiestra dereita
    final winRightRect =
        Rect.fromLTWH(schoolLeft + schoolWidth - 28, schoolTop + 14, 18, 22);
    canvas.drawRRect(
        RRect.fromRectAndRadius(winRightRect, const Radius.circular(8)),
        winPaint);
    canvas.drawRRect(
        RRect.fromRectAndRadius(winRightRect, const Radius.circular(8)),
        winBorder);

    // Porta principal de madeira aberta (Acollemento)
    const doorWidth = 22.0;
    const doorHeight = 32.0;
    final doorLeft = schoolLeft + schoolWidth / 2 - doorWidth / 2;
    final doorTop = schoolTop + schoolHeight - doorHeight;

    final doorPaint = Paint()..color = const Color(0xFF9C4221);
    final doorRRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(doorLeft, doorTop, doorWidth, doorHeight),
      topLeft: const Radius.circular(10),
      topRight: const Radius.circular(10),
    );
    canvas.drawRRect(doorRRect, doorPaint);

    final doorKnob = Paint()..color = const Color(0xFFFFD700);
    canvas.drawCircle(
        Offset(doorLeft + doorWidth - 4, doorTop + 18), 1.8, doorKnob);

    // Camiño de entrada
    final pathPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.fill;
    final footPath = Path()
      ..moveTo(doorLeft - 2, schoolTop + schoolHeight)
      ..lineTo(doorLeft + doorWidth + 2, schoolTop + schoolHeight)
      ..lineTo(doorLeft + doorWidth + 14, h)
      ..lineTo(doorLeft - 14, h)
      ..close();
    canvas.drawPath(footPath, pathPaint);

    // Círculo pedagóxico da asemblea na herba (simbolizado con puntiños de cores)
    final dotColors = [
      AppTheme.primaryVigoBlue,
      const Color(0xFFDD6B20),
      const Color(0xFF38A169),
      const Color(0xFFD69E2E),
      const Color(0xFF805AD5),
    ];
    for (var i = 0; i < dotColors.length; i++) {
      final angle = (i / dotColors.length) * math.pi + math.pi;
      final dx = w * 0.24 + math.cos(angle) * 16;
      final dy = h * 0.88 + math.sin(angle) * 8;
      final dotPaint = Paint()..color = dotColors[i];
      canvas.drawCircle(Offset(dx, dy), 3.2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
