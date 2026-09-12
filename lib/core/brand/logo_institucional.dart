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

  const LogoInstitucional({
    super.key,
    required this.fichero,
    this.etiqueta,
    this.alto = 44,
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
    return Semantics(
      image: true,
      label: widget.etiqueta,
      excludeSemantics: widget.etiqueta == null,
      child: Image.asset(
        _ruta,
        height: widget.alto,
        fit: BoxFit.contain,
        // Que falte en tiempo de ejecución ya no debería pasar —para eso está
        // la comprobación de arriba— pero un error de imagen no puede tumbar
        // los créditos.
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}
