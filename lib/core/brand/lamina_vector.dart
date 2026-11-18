import 'dart:convert';
import 'dart:typed_data';

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
/// `vb` es el ANCHO del lienzo de diseño y `vh` su alto —si falta, es
/// cuadrado—; todo se escala desde ahí. `f` relleno,
/// `s` color del contorno, `sw` su grosor en unidades del lienzo. En `rrect`,
/// `w` y `h` son el ancho y el alto: por eso el grosor NO puede llamarse `w`.
/// Se pinta en orden: la primera forma es la de más atrás.
@immutable
class LaminaVectorial {
  /// El ancho del lienzo de diseño.
  final double lienzo;

  /// El alto. Las láminas del vocabulario son cuadradas y no lo declaran; las
  /// del cuento son APAISADAS, porque una escena no cabe en un cuadrado sin
  /// encogerse hasta no distinguirse.
  final double lienzoAlto;

  final List<FormaLamina> formas;

  const LaminaVectorial({
    required this.lienzo,
    required this.formas,
    double? lienzoAlto,
  }) : lienzoAlto = lienzoAlto ?? lienzo;

  /// Ancho partido por alto. Lo usa la escena para reservar su sitio.
  double get proporcion => lienzo / lienzoAlto;

  static String assetDe(String clave) => 'assets/brand/laminas/$clave.json';

  static LaminaVectorial desdeJson(String raw) {
    final mapa = json.decode(raw) as Map<String, dynamic>;
    return LaminaVectorial(
      lienzo: (mapa['vb'] as num?)?.toDouble() ?? 100,
      lienzoAlto: (mapa['vh'] as num?)?.toDouble(),
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
  final PathFillType regla;

  const FormaLamina({
    required this.tipo,
    required this.datos,
    this.relleno,
    this.contorno,
    this.grosor = 0,
    this.regla = PathFillType.nonZero,
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

  static PathFillType _reglaDe(Map<String, dynamic> m) {
    final raw = (m['fr'] ?? m['regla'] ?? m['fillRule'])?.toString().toLowerCase();
    return raw == 'evenodd' ? PathFillType.evenOdd : PathFillType.nonZero;
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
        regla: _reglaDe(m),
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
        final path = Path()..fillType = regla;
        for (var i = 0; i < puntos.length; i++) {
          final par = List<num>.from(puntos[i] as List);
          final p = Offset(par[0].toDouble(), par[1].toDouble());
          i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
        }
        return path..close();
      case 'ruta':
        return _parsearRuta(datos['d']?.toString() ?? '', regla: regla);
    }
    return null;
  }
}

/// El subconjunto de rutas que hace falta para dibujar cosas redondas:
/// `M` mover, `L` línea, `Q` curva cuadrática, `C` cúbica, `Z` cerrar. Solo
/// coordenadas absolutas: las relativas ahorran teclas y cuestan errores.
final RegExp _token = RegExp(r'[MLQCZmlqcz]|-?\d*\.?\d+');

Path? _parsearRuta(String d, {PathFillType regla = PathFillType.nonZero}) {
  if (d.trim().isEmpty) return null;
  final path = Path()..fillType = regla;
  final piezas = _token.allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  String? ultima;
  double num_() => double.parse(piezas[i++]);
  bool hay(int n) {
    if (i + n > piezas.length) return false;
    for (var k = 0; k < n; k++) {
      if (RegExp(r'^[A-Za-z]$').hasMatch(piezas[i + k])) return false;
    }
    return true;
  }

  while (i < piezas.length) {
    final pieza = piezas[i];
    if (RegExp(r'^[A-Za-z]$').hasMatch(pieza)) {
      i++;
      ultima = pieza.toUpperCase();
    } else if (ultima == null) {
      i++;
      continue;
    } else if (ultima == 'M') {
      // En SVG, tras M las coordenadas sueltas se interpretan como L implícitas.
      ultima = 'L';
    }

    switch (ultima) {
      case 'M':
        if (!hay(2)) {
          i = piezas.length;
          break;
        }
        path.moveTo(num_(), num_());
      case 'L':
        if (!hay(2)) {
          i = piezas.length;
          break;
        }
        path.lineTo(num_(), num_());
      case 'Q':
        if (!hay(4)) {
          i = piezas.length;
          break;
        }
        path.quadraticBezierTo(num_(), num_(), num_(), num_());
      case 'C':
        if (!hay(6)) {
          i = piezas.length;
          break;
        }
        path.cubicTo(num_(), num_(), num_(), num_(), num_(), num_());
      case 'Z':
        path.close();
        ultima = null;
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
  /// No es un error: las claves que aún no están redibujadas caen al píxel art
  /// o a una lámina raster del banco (.webp/.jpg).
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

/// Carga y cachea láminas raster (.webp/.jpg/.png) de dnizfor y pb-imagebank.
class LaminasRaster {
  static const extensiones = ['webp', 'jpg', 'jpeg', 'png'];
  static final Map<String, Uint8List?> _cache = {};

  static Uint8List? enCache(String clave) => _cache[clave];

  static Future<Uint8List?> cargar(String clave) async {
    if (_cache.containsKey(clave)) return _cache[clave];
    for (final ext in extensiones) {
      final ruta = 'assets/brand/laminas/$clave.$ext';
      try {
        final data = await rootBundle.load(ruta);
        final bytes = data.buffer.asUint8List();
        _cache[clave] = bytes;
        return bytes;
      } catch (_) {}
    }
    _cache[clave] = null;
    return null;
  }
}

/// Una lámina APAISADA, del ancho que se le dé y con el alto que pide su
/// lienzo. La usan las páginas del cuento: allí la ilustración ocupa todo el
/// ancho de la tarjeta y no tendría sentido recortarla a un cuadrado.
///
/// Mientras la escena no está dibujada NO se reserva sitio: la tarjeta enseña
/// entonces el aviso de «lámina pendiente», que es lo que había antes, en vez
/// de un hueco en blanco que parece un fallo.
class LaminaEscena extends StatefulWidget {
  final String clave;
  final double ancho;

  /// Qué pintar mientras no exista la escena. Si es nulo, no se pinta nada.
  final Widget? mentres;

  const LaminaEscena({
    super.key,
    required this.clave,
    required this.ancho,
    this.mentres,
  });

  @override
  State<LaminaEscena> createState() => _LaminaEscenaState();
}

class _LaminaEscenaState extends State<LaminaEscena> {
  LaminaVectorial? _lamina;
  Uint8List? _raster;
  bool _buscada = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void didUpdateWidget(covariant LaminaEscena oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.clave != widget.clave) _cargar();
  }

  Future<void> _cargar() async {
    final l = await LaminasVectoriales.cargar(widget.clave);
    final r = l == null ? await LaminasRaster.cargar(widget.clave) : null;
    if (!mounted) return;
    setState(() {
      _lamina = l;
      _raster = r;
      _buscada = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final lamina = _lamina;
    if (lamina != null) {
      return SizedBox(
        width: widget.ancho,
        height: widget.ancho / lamina.proporcion,
        child: CustomPaint(
          painter: LaminaVectorPainter(lamina),
          isComplex: true,
          willChange: false,
        ),
      );
    }
    final raster = _raster;
    if (raster != null) {
      return SizedBox(
        width: widget.ancho,
        height: widget.ancho,
        child: Image.memory(
          raster,
          width: widget.ancho,
          height: widget.ancho,
          fit: BoxFit.contain,
        ),
      );
    }
    return _buscada
        ? (widget.mentres ?? const SizedBox.shrink())
        : const SizedBox.shrink();
  }
}
