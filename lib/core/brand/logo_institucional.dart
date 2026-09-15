import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Un logotipo de `assets/brand/logos/`, que **solo se pinta si el fichero
/// está**.
///
/// Los logotipos institucionales son marcas de terceros con normas de uso
/// propias. No se redibujan a ojo ni se improvisan: o está el original, o no
/// hay logotipo. Por eso este widget no tiene marcador de posición, ni caja
/// gris, ni texto de «falta el logo»: si el fichero no está, no ocupa nada y
/// la fila de al lado se cierra como si nunca hubiera existido.
///
/// El nombre de la entidad va SIEMPRE en texto al lado, también cuando el
/// logotipo está: quien no puede verlo tiene que poder leerlo, y una fila de
/// logotipos sin nombres no acredita a nadie.
class LogoInstitucional extends StatefulWidget {
  /// Nombre del fichero dentro de `assets/brand/logos/`.
  final String fichero;

  /// Para el lector de pantalla. Si el nombre ya se lee al lado, pásalo `null`
  /// y el logotipo queda como decorativo: si no, se oye dos veces lo mismo.
  final String? etiqueta;

  final double alto;

  /// Para los originales que vienen con fondo blanco opaco (sin canal alfa).
  /// Sobre una tarjeta tintada, un JPEG blanco se ve como un recuadro blanco
  /// pegado; con esto se apoya en una placa blanca con esquinas redondeadas,
  /// que es como se coloca un logotipo ajeno sin tocarlo. Los que ya traen
  /// transparencia no la necesitan.
  final bool sobrePlaca;

  /// De qué color es esa placa. Blanca por defecto, que es lo que piden los
  /// originales con fondo blanco opaco.
  ///
  /// Existe por el escudo del Dr. Betances, que está dibujado para fondo
  /// OSCURO: tiene un cuervo blanco y un círculo blanco. Sobre la tarjeta clara
  /// de los créditos esas dos piezas desaparecían y quedaba medio escudo, el
  /// cuervo negro suelto. Un logotipo al que le falta la mitad no acredita a
  /// nadie. La placa oscura es la forma de colocarlo sin retocar el dibujo.
  final Color colorPlaca;

  const LogoInstitucional({
    super.key,
    required this.fichero,
    this.etiqueta,
    this.alto = 44,
    this.sobrePlaca = false,
    this.colorPlaca = Colors.white,
  });

  @override
  State<LogoInstitucional> createState() => _LogoInstitucionalState();
}

class _LogoInstitucionalState extends State<LogoInstitucional> {
  static final Map<String, bool> _existe = {};

  bool? _hay;

  String get _ruta => 'assets/brand/logos/${widget.fichero}';

  @override
  void initState() {
    super.initState();
    _comprobar();
  }

  @override
  void didUpdateWidget(LogoInstitucional oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fichero != widget.fichero) _comprobar();
  }

  Future<void> _comprobar() async {
    final recordado = _existe[_ruta];
    if (recordado != null) {
      if (mounted) setState(() => _hay = recordado);
      return;
    }
    var hay = false;
    try {
      await rootBundle.load(_ruta);
      hay = true;
    } catch (_) {
      hay = false;
    }
    _existe[_ruta] = hay;
    if (mounted) setState(() => _hay = hay);
  }

  @override
  Widget build(BuildContext context) {
    if (_hay != true) return const SizedBox.shrink();
    final imagen = Image.asset(
      _ruta,
      height: widget.alto,
      fit: BoxFit.contain,
      // Que falte en tiempo de ejecución ya no debería pasar —para eso está
      // la comprobación de arriba— pero un error de imagen no puede tumbar
      // los créditos.
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );

    return Semantics(
      image: true,
      label: widget.etiqueta,
      excludeSemantics: widget.etiqueta == null,
      child: widget.sobrePlaca
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: widget.colorPlaca,
                borderRadius: BorderRadius.circular(12),
              ),
              child: imagen,
            )
          : imagen,
    );
  }
}
