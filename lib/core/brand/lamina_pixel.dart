import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'lamina_vector.dart';

/// Las láminas del contenido: un objeto por rejilla, en píxel art propio.
///
/// **Por qué píxel art y no ilustraciones.** Porque el proyecto ya tiene un
/// set propio y coherente —la gata Lúa y las diez insignias— y la regla 5 del
/// CLAUDE.md dice que los iconos salen de un set propio, misma rejilla, mismo
/// grosor, mismas terminaciones. Traer ilustraciones de otro sitio sería un
/// segundo estilo compitiendo con el primero. Estas comparten rejilla de 24×24
/// y comparten LA MISMA paleta que las insignias, el fichero
/// `assets/brand/awards/awards.json`: una sola paleta, no dos que se separan.
///
/// **Por qué no son PNG.** Un PNG de 24×24 escalado a 96 se ve blando; una
/// rejilla se pinta nítida a cualquier tamaño, ocupa 600 bytes, no necesita
/// resoluciones múltiples y no puede llegar del aire: la app no tiene red.
///
/// **Qué pasa si falta la rejilla.** No se pinta nada y la pantalla sigue en
/// pie, igual que con la gata y las insignias. Que el fichero esté es cosa de
/// `tools/check_bundled_assets.py`, que lo exige.
class LaminaPixel extends StatefulWidget {
  /// El nombre de la rejilla, sin ruta ni extensión: `barco`, `man`, `folla`.
  final String clave;

  final double size;

  const LaminaPixel({super.key, required this.clave, this.size = 96});

  /// Dónde vive cada rejilla. Lo usa el gate para exigir que exista.
  static String assetDe(String clave) => 'assets/brand/laminas/$clave.txt';

  @override
  State<LaminaPixel> createState() => _LaminaPixelState();
}

class _LaminaPixelState extends State<LaminaPixel> {
  static final Map<String, List<String>> _rejillas = {};
  static Map<String, Color>? _paleta;

  List<String>? _rejilla;

  /// El dibujo vectorial de esta clave, si ya está redibujado. Manda sobre la
  /// rejilla: la rejilla es el marcador de posición mientras se convierte.
  LaminaVectorial? _vector;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant LaminaPixel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clave != widget.clave) _cargar();
  }

  Future<void> _cargar() async {
    final vector = await LaminasVectoriales.cargar(widget.clave);
    if (vector != null) {
      if (mounted) setState(() => _vector = vector);
      return;
    }
    if (mounted) setState(() => _vector = null);

    final yaEsta = _rejillas[widget.clave];
    if (yaEsta != null && _paleta != null) {
      setState(() => _rejilla = yaEsta);
      return;
    }
    try {
      _paleta ??= await _cargarPaleta();
      final raw =
          await rootBundle.loadString(LaminaPixel.assetDe(widget.clave));
      final filas = raw
          .split('\n')
          .map((l) => l.trimRight())
          .where((l) => l.isNotEmpty)
          .toList();
      _rejillas[widget.clave] = filas;
      if (mounted) setState(() => _rejilla = filas);
    } catch (_) {
      if (mounted) setState(() => _rejilla = null);
    }
  }

  static Future<Map<String, Color>> _cargarPaleta() async {
    final raw = await rootBundle.loadString('assets/brand/awards/awards.json');
    final meta = json.decode(raw) as Map<String, dynamic>;
    final paleta = <String, Color>{};
    (meta['paleta'] as Map<String, dynamic>).forEach((k, v) {
      paleta[k] = Color(
          int.parse('FF${v.toString().replaceFirst('#', '')}', radix: 16));
    });
    return paleta;
  }

  @override
  Widget build(BuildContext context) {
    final vector = _vector;
    if (vector != null) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: LaminaVectorPainter(vector),
          isComplex: true,
          willChange: false,
        ),
      );
    }

    final rejilla = _rejilla;
    final paleta = _paleta;
    if (rejilla == null || paleta == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _LaminaPainter(rejilla: rejilla, paleta: paleta),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

class _LaminaPainter extends CustomPainter {
  final List<String> rejilla;
  final Map<String, Color> paleta;

  const _LaminaPainter({required this.rejilla, required this.paleta});

  @override
  void paint(Canvas canvas, Size size) {
    final lado = rejilla.length;
    if (lado == 0) return;
    final celda = size.width / lado;
    final pincel = Paint()..isAntiAlias = false;

    for (var y = 0; y < lado; y++) {
      final fila = rejilla[y];
      for (var x = 0; x < fila.length && x < lado; x++) {
        final ch = fila[x];
        if (ch == '.' || ch == ' ') continue;
        final color = paleta[ch];
        if (color == null) continue;
        pincel.color = color;
        // +0.5 en el lado: sin ese solape quedan costuras blancas de un píxel
        // entre celdas cuando el tamaño no es múltiplo exacto de la rejilla.
        canvas.drawRect(
          Rect.fromLTWH(x * celda, y * celda, celda + 0.5, celda + 0.5),
          pincel,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LaminaPainter old) =>
      old.rejilla != rejilla || old.paleta != paleta;
}
