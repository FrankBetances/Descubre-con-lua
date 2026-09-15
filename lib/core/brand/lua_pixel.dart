import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Las dos poses de Lúa que hay en `assets/brand/`.
enum LuaPose {
  /// Solo la cabeza. Es la que rinde el icono del lanzador.
  head,

  /// La gata sentada, de cuerpo entero.
  sit,
}

/// Lúa, a gata, pintada desde su rejilla de caracteres.
///
/// La rejilla vive en `assets/brand/*.txt` y es la MISMA fuente de la que
/// `tools/build_launcher_icons.py` saca el icono del lanzador, el icono
/// adaptativo y el splash. Dibujarla aquí en vez de meter un PNG es lo que
/// impide que la Lúa de la pantalla y la del icono se separen: si alguien
/// cambia la rejilla, cambian las cuatro a la vez.
///
/// Se pinta con [CustomPainter] y bordes duros: un PNG escalado con
/// interpolación convierte el pixel art en una mancha borrosa.
class LuaPixel extends StatefulWidget {
  final LuaPose pose;

  /// Lado del cuadrado en el que se encaja la rejilla.
  final double size;

  const LuaPixel({super.key, this.pose = LuaPose.head, this.size = 96});

  @override
  State<LuaPixel> createState() => _LuaPixelState();
}

class _LuaPixelState extends State<LuaPixel> {
  static final Map<LuaPose, _LuaGrid> _cache = {};

  _LuaGrid? _grid;

  @override
  void initState() {
    super.initState();
    // La caché se lee SÍNCRONA, para que una rejilla ya leída entre en el
    // PRIMER build. Antes esto vivía dentro de `_load`, con un `setState` que
    // caía en pleno build del padre: `initState` corre ahí, y en el camino de
    // caché acertada no hay ningún `await` antes. Eso es incorrecto sin más,
    // aunque en la práctica Flutter lo tolerase.
    //
    // HONESTIDAD: NO he demostrado que esto causara ningún fallo en un
    // aparato. Lo que sí hace falta es para que el arnés de las imágenes del
    // manual funcione: allí se calienta la caché antes de pintar cada
    // pantalla, y sin esta lectura síncrona la gata no llegaría al primer
    // build. `PixelAward` ya asignaba directo.
    _grid = _cache[widget.pose];
    if (_grid == null) _load();
  }

  @override
  void didUpdateWidget(LuaPixel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pose == widget.pose) return;
    final cached = _cache[widget.pose];
    if (cached != null) {
      // Aquí sí hace falta setState: ya no estamos en el build inicial.
      setState(() => _grid = cached);
    } else {
      _grid = null;
      _load();
    }
  }

  /// Solo el camino de caché fallada: leer la rejilla del paquete.
  Future<void> _load() async {
    // Si la rejilla no está, la pantalla se queda sin gata pero NO se cae. La
    // mascota es decorativa; tumbar la bienvenida entera por un fichero que
    // falta sería peor que no dibujarla. Que el fichero esté es cosa de un
    // test, no del tiempo de ejecución.
    try {
      final grid = await _LuaGrid.load(widget.pose);
      _cache[widget.pose] = grid;
      if (mounted) setState(() => _grid = grid);
    } catch (error) {
      // Se DICE en el registro. Antes se tragaba en silencio, así que una
      // rejilla que no cargase dejaba el hueco vacío sin que nada lo contara,
      // y eso costó una tanda entera de imágenes del manual investigando a
      // ciegas. El fallo sigue sin tumbar la pantalla, que es lo que importa,
      // pero ya no es mudo.
      debugPrint('LuaPixel: no se pudo leer la rejilla ${widget.pose.name} '
          '($error)');
      if (mounted) setState(() => _grid = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final grid = _grid;
    // Mientras carga ocupa ya su sitio: si no, la pantalla da un salto al
    // aparecer la gata y eso se ve feo justo en la primera impresión.
    if (grid == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _LuaPainter(grid),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

/// Una rejilla ya leída: las filas de caracteres y el color de cada letra.
class _LuaGrid {
  final List<String> rows;
  final Map<String, Color> palette;
  final int width;

  const _LuaGrid(this.rows, this.palette, this.width);

  static Future<_LuaGrid> load(LuaPose pose) async {
    final name = pose == LuaPose.head ? 'lua_head' : 'lua_sit';
    final text = await rootBundle.loadString('assets/brand/$name.txt');
    final paletteJson =
        await rootBundle.loadString('assets/brand/palette.json');

    final rows = text
        .split('\n')
        .map((line) => line.trimRight())
        .where((line) => line.isNotEmpty && !line.startsWith('#'))
        .toList(growable: false);

    final decoded = json.decode(paletteJson) as Map<String, dynamic>;
    final palette = <String, Color>{};
    decoded.forEach((key, value) {
      final hex = value.toString().replaceFirst('#', '');
      palette[key] = Color(int.parse('FF$hex', radix: 16));
    });

    final width =
        rows.fold<int>(0, (acc, r) => r.length > acc ? r.length : acc);
    return _LuaGrid(rows, palette, width);
  }
}

class _LuaPainter extends CustomPainter {
  final _LuaGrid grid;

  const _LuaPainter(this.grid);

  @override
  void paint(Canvas canvas, Size size) {
    if (grid.rows.isEmpty || grid.width == 0) return;

    // Un solo lado para los dos ejes: un píxel rectangular deformaría la gata.
    final side = (size.width / grid.width) < (size.height / grid.rows.length)
        ? size.width / grid.width
        : size.height / grid.rows.length;
    final dx = (size.width - side * grid.width) / 2;
    final dy = (size.height - side * grid.rows.length) / 2;

    final paint = Paint()..style = PaintingStyle.fill;

    for (var y = 0; y < grid.rows.length; y++) {
      final row = grid.rows[y];
      for (var x = 0; x < row.length; x++) {
        final color = grid.palette[row[x]];
        if (color == null) continue; // '.' es transparente
        paint.color = color;
        // +0.5 de solape: sin él quedan costuras blancas entre píxeles cuando
        // el lado no cae en un número entero de puntos de pantalla.
        canvas.drawRect(
          Rect.fromLTWH(
            dx + x * side,
            dy + y * side,
            side + 0.5,
            side + 0.5,
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LuaPainter oldDelegate) => oldDelegate.grid != grid;
}
