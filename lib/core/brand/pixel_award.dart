import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Los diez glifos de insignia, portados de Valeria+ (`ValeriaPixelArt.ts`).
///
/// Son las MISMAS rejillas de 24×24 que allí; no se han redibujado a ojo, igual
/// que la rejilla de Lúa. Viven en `assets/brand/awards/*.txt`.
enum AwardGlyph {
  /// Racha. El glifo de la tira de juego.
  flame,
  paw,
  star,
  sunrise,
  moon,
  home,
  yarn,
  heart,
  crown,

  /// El pescado. No es de la familia de insignias de Valeria+: es el
  /// pictograma 117 de su set, y aquí hace de premio de Lúa porque es lo que
  /// una gata quiere.
  pez;

  String get clave => name;

  static AwardGlyph desdeClave(String valor) => AwardGlyph.values.firstWhere(
        (g) => g.clave == valor,
        orElse: () => AwardGlyph.star,
      );
}

/// El metal de la insignia, en orden de valor creciente.
enum AwardTier {
  bronze,
  silver,
  gold,
  teal,
  violet;

  String get clave => name;

  static AwardTier desdeClave(String valor) => AwardTier.values.firstWhere(
        (t) => t.clave == valor,
        orElse: () => AwardTier.bronze,
      );
}

/// El metal de la racha sube con los días, igual que en Valeria+: el premio se
/// ve venir antes de ganarlo.
AwardTier tierDeRacha(int dias) => dias >= 30
    ? AwardTier.teal
    : dias >= 14
        ? AwardTier.gold
        : dias >= 7
            ? AwardTier.silver
            : AwardTier.bronze;

/// Una insignia en píxel art, con su disco de fondo y sus dos anillos.
///
/// El fondo va DENTRO del widget, no fuera, por la misma razón que en Valeria+:
/// solo dos de los diez glifos usan celdas `a`/`b`, así que los otros ocho
/// saldrían idénticos en los cinco metales si el rango solo tiñese la placa de
/// alrededor. Metiéndolo aquí, una racha de 3 días y una de 30 se distinguen
/// en cualquier sitio donde se pinte la insignia.
class PixelAward extends StatefulWidget {
  final AwardGlyph glyph;
  final AwardTier tier;
  final double size;

  /// Sin ganar: se ve la forma en dos grises, no el premio.
  final bool locked;

  const PixelAward({
    super.key,
    required this.glyph,
    this.tier = AwardTier.bronze,
    this.size = 34,
    this.locked = false,
  });

  @override
  State<PixelAward> createState() => _PixelAwardState();
}

class _PixelAwardState extends State<PixelAward> {
  static _AwardArt? _art;
  static Future<_AwardArt>? _cargando;

  _AwardArt? _local;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_art != null) {
      _local = _art;
      return;
    }
    // Igual que la gata: si falta el fichero, la pantalla se queda sin
    // insignia pero no se cae. Que el fichero esté es cosa de un test.
    try {
      final art = await (_cargando ??= _AwardArt.load());
      _art = art;
      if (mounted) setState(() => _local = art);
    } catch (_) {
      if (mounted) setState(() => _local = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final art = _local;
    if (art == null) {
      return SizedBox(width: widget.size, height: widget.size);
    }
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: _AwardPainter(
          art: art,
          glyph: widget.glyph,
          tier: widget.tier,
          locked: widget.locked,
        ),
        isComplex: true,
        willChange: false,
      ),
    );
  }
}

/// Rango de color: `a` es el tono del metal, `b` su realce, `bg` el disco.
class _Rango {
  final Color a;
  final Color b;
  final Color bg;

  const _Rango(this.a, this.b, this.bg);
}

/// Todo el arte de insignias ya leído: rejillas, paleta fija, metales y
/// núcleos. Se lee una vez para toda la app.
class _AwardArt {
  final Map<AwardGlyph, List<String>> rejillas;
  final Map<String, Color> paleta;
  final Map<AwardTier, _Rango> rangos;
  final Map<AwardGlyph, Color> nucleos;
  final int lado;

  const _AwardArt({
    required this.rejillas,
    required this.paleta,
    required this.rangos,
    required this.nucleos,
    required this.lado,
  });

  /// Sin ganar. Dos grises y la silueta.
  static const _bloqueado = _Rango(
    Color(0xFF5A6068),
    Color(0xFF7D858F),
    Color(0xFF191C20),
  );

  static Color _hex(String value) =>
      Color(int.parse('FF${value.replaceFirst('#', '')}', radix: 16));

  static Future<_AwardArt> load() async {
    final metaRaw =
        await rootBundle.loadString('assets/brand/awards/awards.json');
    final meta = json.decode(metaRaw) as Map<String, dynamic>;

    final paleta = <String, Color>{};
    (meta['paleta'] as Map<String, dynamic>).forEach((k, v) {
      paleta[k] = _hex(v.toString());
    });

    final rangos = <AwardTier, _Rango>{};
    (meta['rangos'] as Map<String, dynamic>).forEach((k, v) {
      final m = Map<String, dynamic>.from(v as Map);
      rangos[AwardTier.desdeClave(k)] = _Rango(
        _hex(m['a'].toString()),
        _hex(m['b'].toString()),
        _hex(m['bg'].toString()),
      );
    });

    final nucleos = <AwardGlyph, Color>{};
    (meta['nucleos'] as Map<String, dynamic>).forEach((k, v) {
      nucleos[AwardGlyph.desdeClave(k)] = _hex(v.toString());
    });

    final rejillas = <AwardGlyph, List<String>>{};
    for (final glyph in AwardGlyph.values) {
      final texto =
          await rootBundle.loadString('assets/brand/awards/${glyph.clave}.txt');
      rejillas[glyph] = texto
          .split('\n')
          .map((l) => l.trimRight())
          .where((l) => l.isNotEmpty)
          .toList(growable: false);
    }

    return _AwardArt(
      rejillas: rejillas,
      paleta: paleta,
      rangos: rangos,
      nucleos: nucleos,
      lado: (meta['lado'] as num?)?.toInt() ?? 24,
    );
  }

  _Rango rango(AwardTier tier, bool locked) =>
      locked ? _bloqueado : (rangos[tier] ?? _bloqueado);
}

class _AwardPainter extends CustomPainter {
  final _AwardArt art;
  final AwardGlyph glyph;
  final AwardTier tier;
  final bool locked;

  const _AwardPainter({
    required this.art,
    required this.glyph,
    required this.tier,
    required this.locked,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rows = art.rejillas[glyph];
    if (rows == null || rows.isEmpty) return;

    final pal = art.rango(tier, locked);
    final core = locked ? null : art.nucleos[glyph];

    // El aparato dibuja el glifo de 24 celdas con el anillo a radio 18, o sea
    // con 6 celdas de margen repartidas. Se reproduce en unidades de celda
    // para que la proporción sea la misma a cualquier tamaño.
    final total = art.lado + 12;
    final celda = size.shortestSide / total;
    final origen = Offset(
      (size.width - celda * total) / 2 + celda * 6,
      (size.height - celda * total) / 2 + celda * 6,
    );
    final centro = origen + Offset(celda * art.lado / 2, celda * art.lado / 2);

    final paint = Paint()..style = PaintingStyle.fill;

    paint.color = pal.bg;
    canvas.drawCircle(centro, celda * 18, paint);

    final anillo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = celda
      ..color = pal.a;
    canvas.drawCircle(centro, celda * 17.5, anillo);
    anillo
      ..strokeWidth = celda * 0.35
      ..color = core ?? pal.b;
    canvas.drawCircle(centro, celda * 16.9, anillo);

    for (var y = 0; y < rows.length; y++) {
      final row = rows[y];
      for (var x = 0; x < row.length; x++) {
        final color = _color(row[x], pal, core);
        if (color == null) continue;
        paint.color = color;
        // +0.5 de solape, igual que en la gata: sin él quedan costuras.
        canvas.drawRect(
          Rect.fromLTWH(
            origen.dx + x * celda,
            origen.dy + y * celda,
            celda + 0.5,
            celda + 0.5,
          ),
          paint,
        );
      }
    }
  }

  /// El reparto es el mismo que hace Valeria+: `a` el tono del metal, `b` el
  /// núcleo del glifo si lo tiene y si no el realce. El núcleo SUSTITUYE a
  /// `b`, no le hace de reserva: el corazón de una llama es naranja aunque la
  /// insignia sea de plata.
  Color? _color(String c, _Rango pal, Color? core) {
    if (c == '.' || c == ' ') return null;
    if (locked) return (c == 'b' || c == 'w') ? pal.b : pal.a;
    if (c == 'a') return pal.a;
    if (c == 'b') return core ?? pal.b;
    return art.paleta[c];
  }

  @override
  bool shouldRepaint(_AwardPainter old) =>
      old.glyph != glyph || old.tier != tier || old.locked != locked;
}
