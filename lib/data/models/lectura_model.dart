import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../loaders/content_asset_loader.dart';

import '../../core/localization/app_language.dart';
import '../../core/localization/localized_string.dart';

/// Una lista de cadenas por lengua: las letras y los fonemas de una palabra.
///
/// No es cosmético que sean por lengua. «Rá» se monta con dos letras en galego
/// y «Rana» con cuatro en castellano, y los fonemas tampoco coinciden. La
/// pantalla de fónica manipulativa enseña las letras que la crianza pone sobre
/// la mesa: si la lista no cambia con la lengua, la familia castellanohablante
/// ve una palabra galega en las fichas.
@immutable
class ListaLocalizada {
  final List<String> gl;
  final List<String> es;

  const ListaLocalizada({required this.gl, required this.es});

  factory ListaLocalizada.fromJson(Map<String, dynamic> json) =>
      ListaLocalizada(
        gl: _lista(json['gl']),
        es: _lista(json['es']),
      );

  static List<String> _lista(Object? raw) => raw is List
      ? List<String>.unmodifiable(raw.map((e) => e.toString()))
      : const <String>[];

  List<String> resolve(AppLanguage lang) => lang == AppLanguage.gl ? gl : es;
}

/// Una palabra de la mesa de letras: qué se dice, cómo se escribe y qué se hace
/// con el cuerpo.
@immutable
class PalabraAlphabot {
  final String id;

  /// La palabra en su forma natural, con inicial mayúscula, que es la
  /// convención del vocabulario de la casa («Ra», «Oso», «Gato»).
  ///
  /// La tarjeta la pinta en mayúsculas porque es una ficha de letras, pero al
  /// botón de escuchar va ESTA forma: el identificador de la grabación sale del
  /// texto exacto, y «GATO» y «Gato» son dos grabaciones distintas. Pasar la
  /// forma de la pantalla dejaba el botón sin pintar, que es lo que pasaba.
  final LocalizedString palabra;

  final ListaLocalizada letras;
  final ListaLocalizada fonemas;
  final LocalizedString significado;
  final LocalizedString material;
  final LocalizedString tpr;

  const PalabraAlphabot({
    required this.id,
    required this.palabra,
    required this.letras,
    required this.fonemas,
    required this.significado,
    required this.material,
    required this.tpr,
  });

  factory PalabraAlphabot.fromJson(Map<String, dynamic> json) =>
      PalabraAlphabot(
        id: json['id']?.toString() ?? '',
        palabra: LocalizedString.fromJson(_mapa(json['palabra'])),
        letras: ListaLocalizada.fromJson(_mapa(json['letras'])),
        fonemas: ListaLocalizada.fromJson(_mapa(json['fonemas'])),
        significado: LocalizedString.fromJson(_mapa(json['significado'])),
        material: LocalizedString.fromJson(_mapa(json['material'])),
        tpr: LocalizedString.fromJson(_mapa(json['tpr'])),
      );
}

@immutable
class CategoriaAlphabot {
  final String id;
  final LocalizedString nome;
  final List<PalabraAlphabot> palabras;

  const CategoriaAlphabot({
    required this.id,
    required this.nome,
    required this.palabras,
  });

  factory CategoriaAlphabot.fromJson(Map<String, dynamic> json) =>
      CategoriaAlphabot(
        id: json['id']?.toString() ?? '',
        nome: LocalizedString.fromJson(_mapa(json['nome'])),
        palabras: List<PalabraAlphabot>.unmodifiable(
          (json['palabras'] as List? ?? const []).whereType<Map>().map(
              (e) => PalabraAlphabot.fromJson(Map<String, dynamic>.from(e))),
        ),
      );
}

/// Un cubo CVC. `palabraEn` cuando la palabra es inglesa, `palabra` cuando es
/// una sílaba transparente de galego o castellano; nunca las dos.
@immutable
class CuboCvc {
  final String id;
  final String c1;
  final String v;
  final String c2;
  final String? palabraEn;
  final LocalizedString? palabra;
  final String ipa;
  final LocalizedString significado;
  final LocalizedString material;
  final LocalizedString consigna;

  const CuboCvc({
    required this.id,
    required this.c1,
    required this.v,
    required this.c2,
    required this.palabraEn,
    required this.palabra,
    required this.ipa,
    required this.significado,
    required this.material,
    required this.consigna,
  });

  factory CuboCvc.fromJson(Map<String, dynamic> json) => CuboCvc(
        id: json['id']?.toString() ?? '',
        c1: json['c1']?.toString() ?? '',
        v: json['v']?.toString() ?? '',
        c2: json['c2']?.toString() ?? '',
        palabraEn: json['palabraEn']?.toString(),
        palabra: json['palabra'] is Map
            ? LocalizedString.fromJson(_mapa(json['palabra']))
            : null,
        ipa: json['ipa']?.toString() ?? '',
        significado: LocalizedString.fromJson(_mapa(json['significado'])),
        material: LocalizedString.fromJson(_mapa(json['material'])),
        consigna: LocalizedString.fromJson(_mapa(json['consigna'])),
      );

  /// Lo que se pinta grande en la tarjeta, en mayúsculas.
  String rotulo(AppLanguage lang) =>
      (palabraEn ?? palabra?.resolve(lang) ?? '').toUpperCase();

  /// Lo que suena. En inglés cuando la palabra es inglesa.
  String textoAudio(AppLanguage lang) =>
      palabraEn ?? palabra?.resolve(lang) ?? '';

  bool get esIngles => palabraEn != null;
}

@immutable
class ParMinimo {
  final String id;
  final String par;
  final String palabra1En;
  final String palabra2En;
  final LocalizedString palabra1;
  final LocalizedString palabra2;
  final LocalizedString contraste;
  final LocalizedString instrucion;

  const ParMinimo({
    required this.id,
    required this.par,
    required this.palabra1En,
    required this.palabra2En,
    required this.palabra1,
    required this.palabra2,
    required this.contraste,
    required this.instrucion,
  });

  factory ParMinimo.fromJson(Map<String, dynamic> json) => ParMinimo(
        id: json['id']?.toString() ?? '',
        par: json['par']?.toString() ?? '',
        palabra1En: json['palabra1En']?.toString() ?? '',
        palabra2En: json['palabra2En']?.toString() ?? '',
        palabra1: LocalizedString.fromJson(_mapa(json['palabra1'])),
        palabra2: LocalizedString.fromJson(_mapa(json['palabra2'])),
        contraste: LocalizedString.fromJson(_mapa(json['contraste'])),
        instrucion: LocalizedString.fromJson(_mapa(json['instrucion'])),
      );
}

@immutable
class ActividadeConciencia {
  final String id;
  final LocalizedString titulo;
  final LocalizedString subtitulo;
  final LocalizedString descricion;
  final LocalizedString tpr;

  const ActividadeConciencia({
    required this.id,
    required this.titulo,
    required this.subtitulo,
    required this.descricion,
    required this.tpr,
  });

  factory ActividadeConciencia.fromJson(Map<String, dynamic> json) =>
      ActividadeConciencia(
        id: json['id']?.toString() ?? '',
        titulo: LocalizedString.fromJson(_mapa(json['titulo'])),
        subtitulo: LocalizedString.fromJson(_mapa(json['subtitulo'])),
        descricion: LocalizedString.fromJson(_mapa(json['descricion'])),
        tpr: LocalizedString.fromJson(_mapa(json['tpr'])),
      );
}

/// Todo el contenido de «Aprender a Ler», que vive en
/// `assets/content/lectura/aprender_a_ler.json` y no en el widget.
@immutable
class ContidoLectura {
  final LocalizedString avisoZeroPantalla;
  final List<ActividadeConciencia> actividadesConciencia;
  final List<CategoriaAlphabot> categoriasAlphabot;
  final List<CuboCvc> cubosCvc;
  final List<ParMinimo> paresMinimos;

  const ContidoLectura({
    required this.avisoZeroPantalla,
    required this.actividadesConciencia,
    required this.categoriasAlphabot,
    required this.cubosCvc,
    required this.paresMinimos,
  });

  static const String assetPath = 'assets/content/lectura/aprender_a_ler.json';

  factory ContidoLectura.fromJson(Map<String, dynamic> json) => ContidoLectura(
        avisoZeroPantalla:
            LocalizedString.fromJson(_mapa(json['avisoZeroPantalla'])),
        actividadesConciencia: List<ActividadeConciencia>.unmodifiable(
          (json['actividadesConciencia'] as List? ?? const [])
              .whereType<Map>()
              .map((e) =>
                  ActividadeConciencia.fromJson(Map<String, dynamic>.from(e))),
        ),
        categoriasAlphabot: List<CategoriaAlphabot>.unmodifiable(
          (json['categoriasAlphabot'] as List? ?? const [])
              .whereType<Map>()
              .map((e) =>
                  CategoriaAlphabot.fromJson(Map<String, dynamic>.from(e))),
        ),
        cubosCvc: List<CuboCvc>.unmodifiable(
          (json['cubosCvc'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => CuboCvc.fromJson(Map<String, dynamic>.from(e))),
        ),
        paresMinimos: List<ParMinimo>.unmodifiable(
          (json['paresMinimos'] as List? ?? const [])
              .whereType<Map>()
              .map((e) => ParMinimo.fromJson(Map<String, dynamic>.from(e))),
        ),
      );

  factory ContidoLectura.fromRaw(String rawJson) {
    final decoded = jsonDecode(rawJson);
    if (decoded is! Map) {
      throw const FormatException(
          'Expected JSON object at root for ContidoLectura');
    }
    return ContidoLectura.fromJson(Map<String, dynamic>.from(decoded));
  }

  /// Una sola carga por ejecución, igual que el calendario: el contenido no
  /// cambia mientras la app vive.
  static Future<ContidoLectura>? _enCurso;

  static Future<ContidoLectura> cargar({
    AssetBundleStringLoader? stringLoader,
  }) {
    if (stringLoader != null) {
      return stringLoader(assetPath).then(ContidoLectura.fromRaw);
    }
    return _enCurso ??=
        rootBundle.loadString(assetPath).then(ContidoLectura.fromRaw);
  }

  /// Solo para los tests: olvida lo cargado.
  @visibleForTesting
  static void olvidar() => _enCurso = null;

  /// Solo para los tests: deja el contenido en estado de AVERÍA, para poder
  /// comprobar sobre la pantalla de verdad que un fallo de lectura se ENSEÑA
  /// en vez de dejar el disco girando.
  @visibleForTesting
  static void sembrarFallo(Object error) {
    _enCurso = Future<ContidoLectura>.error(error)..ignore();
  }
}

Map<String, dynamic> _mapa(Object? raw) =>
    raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};
