import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Las láminas vectoriales del contenido: dibujo de trazo grueso, color plano y
/// brillo, descrito como DATOS y pintado por un solo painter.
///
/// **Por qué no píxel art.** Las rejillas de 24×24 son pictogramas: valen para
/// una insignia, no para que una criatura de dieciocho meses reconozca un
/// barco. A esa edad la referencia tiene que tener volumen, contorno y una
/// silueta grande y amable.
///
/// **Por qué no PNG ni SVG.** Un PNG obliga a tres resoluciones y se ve blando
/// al ampliar; un SVG de verdad necesitaría una dependencia, y este proyecto
/// no tiene ninguna y no la va a tener. Aquí la lámina es una lista de formas
/// en JSON —elipses, rectángulos redondeados, polígonos y rutas con curvas—,
/// se pinta nítida a cualquier tamaño, ocupa uno o dos kilobytes y no puede
/// llegar del aire.
///
/// **Por qué datos y no un painter por objeto.** Cincuenta objetos serían
/// cincuenta clases de Dart que nadie sabría corregir sin recompilar. Como
/// dato, lo edita quien dibuja y lo ve un gate. Es la misma regla que el resto
/// del contenido.
///
/// **El formato**, deliberadamente corto:
///
/// ```json
/// {
///   "vb": 100,
///   "formas": [
///     {"t": "elipse", "cx": 50, "cy": 55, "rx": 32, "ry": 30,
///      "f": "#e62828", "s": "#7a1414", "sw": 4},
///     {"t": "rrect", "x": 20, "y": 40, "w": 60, "h": 26, "r": 10, "f": "#2f6fd0"},
///     {"t": "poli", "p": [[10,80],[50,20],[90,80]], "f": "#2ecc40"},
///     {"t": "ruta", "d": "M10 80 Q50 20 90 80 Z", "f": "#00c4be"}
///   ]
/// }
/// ```
///
/// `vb` es el lado del lienzo de diseño; todo se escala desde ahí. `f` relleno,
/// `s` color del contorno, `sw` su grosor en unidades del lienzo. En `rrect`,
/// `w` y `h` son el ancho y el alto: por eso el grosor NO puede llamarse `w`.
/// Se pinta en orden: la primera forma es la de más atrás.
@immutable
class LaminaVectorial {
  final double lienzo;
  final List<FormaLamina> formas;

  const LaminaVectorial({required this.lienzo, required this.formas});

  static String assetDe(String clave) => 'assets/brand/laminas/$clave.json';

  static LaminaVectorial desdeJson(String raw) {
    final mapa = json.decode(raw) as Map<String, dynamic>;
    return LaminaVectorial(
      lienzo: (mapa['vb'] as num?)?.toDouble() ?? 100,
      formas: [
        for (final f in (mapa['formas'] as List? ?? const []))
          FormaLamina.desde(Map<String, dynamic>.from(f as Map)),
      ],
    );
  }
}

/// Una forma de la lámina. Pública porque `LaminaVectorial` la expone: una
/// lámina ES su lista de formas, y esconderla obligaría a copiarla.
@immutable
class FormaLamina {
  final String tipo;
  final Map<String, dynamic> datos;
  final Color? relleno;
  final Color? contorno;
  final double grosor;

  const FormaLamina({
    required this.tipo,
    required this.datos,
    this.relleno,
    this.contorno,
    this.grosor = 0,
  });

  static Color? _color(Object? valor) {
    if (valor is! String || valor.isEmpty) return null;
    final hex = valor.replaceFirst('#', '');
    // Ocho dígitos son RRGGBBAA, como en SVG y en CSS, porque es como los
    // escribe quien dibuja. Dart quiere AARRGGBB: hay que REORDENAR, no
    // concatenar. Sin esto, `#ffffff55` —un brillo blanco translúcido— se leía
    // como A=ff R=ff G=ff B=55, o sea un manchón amarillo opaco. Salió en la
    // manzana y en el gato antes de que nadie dibujara nada más.
    final completo = hex.length == 8
        ? '${hex.substring(6)}${hex.substring(0, 6)}'
        : 'FF$hex';
    final n = int.tryParse(completo, radix: 16);
    return n == null ? null : Color(n);
  }

  factory FormaLamina.desde(Map<String, dynamic> m) => FormaLamina(
        tipo: m['t']?.toString() ?? '',
        datos: m,
        relleno: _color(m['f']),
        contorno: _color(m['s']),
        // `sw`, no `w`: en un `rrect`, `w` ES EL ANCHO del rectángulo. Usar la
        // misma letra para el grosor del contorno dejaba la clave duplicada
        // dentro del mismo objeto JSON, y JSON se queda con la última en
        // silencio. Resultado: la barra de la toalla no se pintaba y nadie
        // podía saber por qué mirando el fichero.
        grosor: (m['sw'] as num?)?.toDouble() ?? 0,
      );

  Path? aPath() {
    double d(String k, [double si = 0]) => (datos[k] as num?)?.toDouble() ?? si;

    switch (tipo) {
      case 'elipse':
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(d('cx'), d('cy')),
            width: d('rx') * 2,
            height: d('ry') * 2,
          ));
      case 'rrect':
        return Path()
          ..addRRect(RRect.fromRectAndRadius(
            Rect.fromLTWH(d('x'), d('y'), d('w'), d('h')),
            Radius.circular(d('r')),
          ));
      case 'poli':
        final puntos = (datos['p'] as List?) ?? const [];
        if (puntos.length < 2) return null;
        final path = Path();
        for (var i = 0; i < puntos.length; i++) {
          final par = List<num>.from(puntos[i] as List);
          final p = Offset(par[0].toDouble(), par[1].toDouble());
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        return path..close();
      case 'ruta':
        return _parsearRuta(datos['d']?.toString() ?? '');
    }
    return null;
  }
}

/// El subconjunto de rutas que hace falta para dibujar cosas redondas:
/// `M` mover, `L` línea, `Q` curva cuadrática, `C` cúbica, `Z` cerrar. Solo
/// coordenadas absolutas: las relativas ahorran teclas y cuestan errores.
final RegExp _token = RegExp(r'[MLQCZmlqcz]|-?\d*\.?\d+');

Path? _parsearRuta(String d) {
  if (d.trim().isEmpty) return null;
  final path = Path()..fillType = PathFillType.nonZero;
  final piezas = _token.allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  double num_() => double.parse(piezas[i++]);

  while (i < piezas.length) {
    final orden = piezas[i];
    if (RegExp(r'^[A-Za-z]$').hasMatch(orden)) {
      i++;
      switch (orden.toUpperCase()) {
        case 'M':
          path.moveTo(num_(), num_());
        case 'L':
          path.lineTo(num_(), num_());
        case 'Q':
          path.quadraticBezierTo(num_(), num_(), num_(), num_());
        case 'C':
          path.cubicTo(num_(), num_(), num_(), num_(), num_(), num_());
        case 'Z':
          path.close();
      }
    } else {
      // Números sueltos tras una orden: se repite la última, como en SVG.
      i++;
    }
  }
  return path;
}

/// Pinta una lámina vectorial encajada en el cuadrado que se le dé.
class LaminaVectorPainter extends CustomPainter {
  final LaminaVectorial lamina;

  const LaminaVectorPainter(this.lamina);

  @override
  void paint(Canvas canvas, Size size) {
    final escala = size.width / lamina.lienzo;
    canvas.save();
    canvas.scale(escala);

    for (final forma in lamina.formas) {
      final path = forma.aPath();
      if (path == null) continue;
      final relleno = forma.relleno;
      if (relleno != null) {
        canvas.drawPath(path, Paint()..color = relleno);
      }
      final contorno = forma.contorno;
      if (contorno != null && forma.grosor > 0) {
        canvas.drawPath(
          path,
          Paint()
            ..color = contorno
            ..style = PaintingStyle.stroke
            ..strokeWidth = forma.grosor
            // Redondo en punta y en junta: es lo que separa un dibujo infantil
            // de un diagrama.
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round,
        );
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LaminaVectorPainter old) => old.lamina != lamina;
}

/// Carga y cachea las láminas vectoriales del paquete.
class LaminasVectoriales {
  static final Map<String, LaminaVectorial?> _cache = {};

  static LaminaVectorial? enCache(String clave) => _cache[clave];

  static bool seIntento(String clave) => _cache.containsKey(clave);

  /// Devuelve la lámina, o `null` si no hay fichero vectorial para esa clave.
  /// No es un error: las claves que aún no están redibujadas caen al píxel art.
  static Future<LaminaVectorial?> cargar(String clave) async {
    if (_cache.containsKey(clave)) return _cache[clave];
    try {
      final raw = await rootBundle.loadString(LaminaVectorial.assetDe(clave));
      final lamina = LaminaVectorial.desdeJson(raw);
      _cache[clave] = lamina;
      return lamina;
    } catch (_) {
      _cache[clave] = null;
      return null;
    }
  }
}
