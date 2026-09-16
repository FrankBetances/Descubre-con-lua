import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Una página que cabe siempre, sin desplazarse.
///
/// Los dos documentos curriculares piden lo mismo con las mismas palabras:
/// «sin navegación por capas ni deslizamientos profundos (*no scroll*)». Frank
/// lo repitió: el desplazamiento hacia abajo no funciona ni para la docente con
/// doce criaturas delante, ni para la familia leyendo tres minutos en la cocina.
///
/// Quitar el desplazable a secas no vale: el texto se saldría, y un
/// desbordamiento en release no enseña franjas amarillas, enseña media frase.
/// Así que aquí el contenido se **encoge** hasta caber, con un suelo: por
/// debajo de [escalaMinima] no baja, porque un texto que nadie puede leer no es
/// mejor que uno que hay que desplazar. Si ni con el suelo cabe, se avisa en
/// modo depuración para que el contenido se acorte, que es donde está el
/// problema de verdad.
class PaxinaSenScroll extends StatelessWidget {
  final Widget child;

  /// Hasta dónde se deja encoger. 0,8 mantiene un cuerpo de 16 pt en 12,8.
  final double escalaMinima;

  /// Cómo se alinea cuando sobra sitio.
  final AlignmentGeometry alignment;

  /// El margen de la página. Va dentro de la medida: lo que se encoge es el
  /// contenido con su margen, no el contenido dentro de un margen fijo.
  final EdgeInsetsGeometry? padding;

  /// Deja que la pantalla se desplace.
  ///
  /// Corrección de Frank, y tenía razón: «el scroll es permitido y puede ser
  /// usado para dejar leer la pantalla». Bloquearlo en todas partes dejó el
  /// Inicio y Academy rotos —el contenido no cabía y no había forma de verlo—.
  ///
  /// El «no scroll» de los dos documentos curriculares es sobre la SUPERFICIE
  /// DE TRABAJO: la asamblea, leída de un golpe de vista a dos metros con doce
  /// criaturas delante. Ahí sigue sin desplazarse, y ahí es donde importa.
  /// Todo lo que un adulto lee sentado se desplaza.
  ///
  /// Lo que no vale, en ninguno de los dos casos, es una lista vertical
  /// infinita: dentro de estas pantallas el contenido va en fichas y en
  /// carruseles que se pasan de lado.
  final bool desprazarSeNonCabe;

  const PaxinaSenScroll({
    super.key,
    required this.child,
    this.escalaMinima = 0.8,
    this.alignment = Alignment.topCenter,
    this.padding,
    this.desprazarSeNonCabe = false,
  });

  @override
  Widget build(BuildContext context) {
    final contido =
        padding == null ? child : Padding(padding: padding!, child: child);

    return LayoutBuilder(builder: (context, constraints) {
      if (!constraints.hasBoundedHeight) return contido;

      // Las dos pantallas de lectura larga del adulto se desplazan, y es a
      // propósito. Ver el porqué en [desprazarSeNonCabe].
      if (desprazarSeNonCabe) {
        return SingleChildScrollView(child: contido);
      }

      return _MedirYEncoller(
        maxHeight: constraints.maxHeight,
        maxWidth: constraints.maxWidth,
        escalaMinima: escalaMinima,
        alignment: alignment,
        child: contido,
      );
    });
  }
}

class _MedirYEncoller extends SingleChildRenderObjectWidget {
  final double maxHeight;
  final double maxWidth;
  final double escalaMinima;
  final AlignmentGeometry alignment;

  const _MedirYEncoller({
    required this.maxHeight,
    required this.maxWidth,
    required this.escalaMinima,
    required this.alignment,
    required Widget child,
  }) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderEncoller(
        maxHeight: maxHeight,
        escalaMinima: escalaMinima,
        alignment: alignment.resolve(Directionality.of(context)),
      );

  @override
  void updateRenderObject(BuildContext context, _RenderEncoller renderObject) {
    renderObject
      ..maxHeight = maxHeight
      ..escalaMinima = escalaMinima
      ..alignment = alignment.resolve(Directionality.of(context));
  }
}

/// Mide el hijo con el ancho disponible y, si es más alto que el hueco, lo
/// pinta a escala. La escala se aplica al dibujo y a los toques, así que los
/// botones siguen respondiendo donde se ven.
class _RenderEncoller extends RenderShiftedBox {
  double _maxHeight;
  double _escalaMinima;
  Alignment _alignment;
  double _escala = 1.0;

  _RenderEncoller({
    required double maxHeight,
    required double escalaMinima,
    required Alignment alignment,
  })  : _maxHeight = maxHeight,
        _escalaMinima = escalaMinima,
        _alignment = alignment,
        super(null);

  set maxHeight(double v) {
    if (_maxHeight == v) return;
    _maxHeight = v;
    markNeedsLayout();
  }

  set escalaMinima(double v) {
    if (_escalaMinima == v) return;
    _escalaMinima = v;
    markNeedsLayout();
  }

  set alignment(Alignment v) {
    if (_alignment == v) return;
    _alignment = v;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final hijo = child;
    if (hijo == null) {
      size = constraints.smallest;
      return;
    }

    // El hijo se mide con el ancho real y alto libre: así dice cuánto ocupa
    // de verdad, sin que nadie lo apriete.
    hijo.layout(
      BoxConstraints(
        minWidth: constraints.maxWidth,
        maxWidth: constraints.maxWidth,
      ),
      parentUsesSize: true,
    );

    final alto = hijo.size.height;
    _escala = alto <= _maxHeight ? 1.0 : (_maxHeight / alto);
    if (_escala < _escalaMinima) _escala = _escalaMinima;

    size = Size(constraints.maxWidth, _maxHeight);

    final datos = hijo.parentData! as BoxParentData;
    final altoPintado = alto * _escala;
    datos.offset = Offset(
      (constraints.maxWidth - constraints.maxWidth * _escala) / 2,
      _alignment.y <= 0 ? 0 : (_maxHeight - altoPintado),
    );

    assert(() {
      if (_escala == _escalaMinima && alto * _escala > _maxHeight + 0.5) {
        debugPrint(
          'PaxinaSenScroll: el contenido no cabe ni al ${(_escalaMinima * 100).round()}%. '
          'Acorta el texto en vez de añadir un desplazable.',
        );
      }
      return true;
    }());
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final hijo = child;
    if (hijo == null) return;
    final datos = hijo.parentData! as BoxParentData;
    if (_escala == 1.0) {
      context.paintChild(hijo, offset + datos.offset);
      return;
    }
    context.pushTransform(
      needsCompositing,
      offset + datos.offset,
      Matrix4.diagonal3Values(_escala, _escala, 1.0),
      (ctx, off) => ctx.paintChild(hijo, off),
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final hijo = child;
    if (hijo == null) return false;
    final datos = hijo.parentData! as BoxParentData;
    return result.addWithPaintTransform(
      transform: Matrix4.diagonal3Values(_escala, _escala, 1.0),
      position: position - datos.offset,
      hitTest: (r, p) => hijo.hitTest(r, position: p),
    );
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final datos = child.parentData! as BoxParentData;
    transform.translateByDouble(datos.offset.dx, datos.offset.dy, 0.0, 1.0);
    transform.scaleByDouble(_escala, _escala, 1.0, 1.0);
  }
}
