import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../localization/app_language.dart';
import '../localization/localized_string.dart';
import 'lamina_vector.dart';

/// O-20261111-1: la imagen de la escena de un reto, encima de su texto.
///
/// El mapa escena → lámina vive en assets/content/escenas/escenas.json, que
/// genera tools/gen_escenas_retos.py; tools/check_imagenes_escenas.py tumba CI
/// si una escena del contenido se queda sin imagen. Se busca por el texto
/// gallego de la escena, que es el mismo en leccions.json y en unidades_mes.
class EscenasImaxes {
  static const asset = 'assets/content/escenas/escenas.json';
  static Map<String, ({String clave, LocalizedString etiqueta})>? _mapa;

  static Future<Map<String, ({String clave, LocalizedString etiqueta})>>
      cargar() async {
    final m = _mapa;
    if (m != null) return m;
    final d = jsonDecode(await rootBundle.loadString(asset));
    final out = <String, ({String clave, LocalizedString etiqueta})>{};
    for (final e in (d['escenas'] as List).cast<Map<String, dynamic>>()) {
      final gl = (e['escena'] as Map)['gl'] as String;
      out[gl] = (
        clave: e['clave'] as String,
        etiqueta: LocalizedString.fromJson(
            (e['etiqueta'] as Map).cast<String, dynamic>()),
      );
    }
    return _mapa = out;
  }
}

/// La imagen de la escena, con su etiqueta para el lector de pantalla en la
/// lengua de la interfaz. Si la escena no tiene imagen no pinta nada (el gate
/// impide que eso llegue a una build).
class ImaxeEscena extends StatefulWidget {
  final LocalizedString escena;
  final AppLanguage lang;
  final double ancho;

  const ImaxeEscena({
    super.key,
    required this.escena,
    required this.lang,
    this.ancho = 220,
  });

  @override
  State<ImaxeEscena> createState() => _ImaxeEscenaState();
}

class _ImaxeEscenaState extends State<ImaxeEscena> {
  ({String clave, LocalizedString etiqueta})? _e;

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  @override
  void didUpdateWidget(covariant ImaxeEscena old) {
    super.didUpdateWidget(old);
    if (old.escena.gl != widget.escena.gl) _buscar();
  }

  Future<void> _buscar() async {
    final m = await EscenasImaxes.cargar();
    if (!mounted) return;
    setState(() => _e = m[widget.escena.gl]);
  }

  @override
  Widget build(BuildContext context) {
    final e = _e;
    if (e == null) return const SizedBox.shrink();
    return Semantics(
      key: Key('imaxe_escena_${e.clave}'),
      image: true,
      label: e.etiqueta.resolve(widget.lang),
      excludeSemantics: true,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: ColoredBox(
            color: const Color(0xFFFFF8EC),
            child: LaminaEscena(clave: e.clave, ancho: widget.ancho),
          ),
        ),
      ),
    );
  }
}

/// O-20261111-2: la lámina de UNA palabra o frase, encima de ella, con su
/// etiqueta gl/es para el lector de pantalla. Nunca una lámina de escena de
/// reto (lo impide tools/check_laminas_leccion.py).
class LaminaPalabra extends StatelessWidget {
  final String clave;

  /// Lo que la palabra quiere decir, en la lengua de la interfaz.
  final String significado;
  final AppLanguage lang;
  final double ancho;

  const LaminaPalabra({
    super.key,
    required this.clave,
    required this.significado,
    required this.lang,
    this.ancho = 240,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      key: Key('lamina_palabra_$clave'),
      image: true,
      label: lang == AppLanguage.gl
          ? 'Imaxe: $significado'
          : 'Imagen: $significado',
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ColoredBox(
          color: const Color(0xFFFFF8EC),
          child: LaminaEscena(clave: clave, ancho: ancho),
        ),
      ),
    );
  }
}
