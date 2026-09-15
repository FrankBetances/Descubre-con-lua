import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/asamblea_segundo_ciclo_model.dart';
import '../models/capsula_model.dart';
import '../models/unidad_model.dart';

/// Function signature for asset string loader. Enables headless testing without Flutter engine.
typedef AssetBundleStringLoader = Future<String> Function(String path);

/// Loads and parses pedagogical JSON content from application assets or raw strings.
///
/// Fully offline: strictly reads bundled assets or in-memory strings.
class ContentAssetLoader {
  final AssetBundleStringLoader _stringLoader;

  /// Creates a [ContentAssetLoader]. If [stringLoader] is omitted, defaults to [rootBundle.loadString].
  ContentAssetLoader({AssetBundleStringLoader? stringLoader})
      : _stringLoader = stringLoader ?? ((path) => rootBundle.loadString(path));

  /// Default asset path prefix for thematic units.
  static const String unidadesAssetPrefix = 'assets/content/unidades/';

  /// Default asset path prefix for Academy capsules.
  static const String capsulasAssetPrefix = 'assets/content/capsulas/';

  /// Canonical base unit path.
  static const String baseUnidadMar01 =
      'assets/content/unidades/juega.mar.01.json';

  /// Canonical base capsule path.
  static const String baseCapsulaHablar01 =
      'assets/content/capsulas/academy.como_se_aprende_a_hablar.01.json';

  /// Default asset path prefix for Segundo Ciclo assemblies (3-6 years).
  static const String asambleasSegundoCicloAssetPrefix =
      'assets/content/asambleas_segundo_ciclo/';

  /// Canonical base assembly paths for September pilot month.
  static const String baseAsambleaSetembro4 =
      'assets/content/asambleas_segundo_ciclo/asamblea.setembro.4_infantil.json';
  static const String baseAsambleaSetembro5 =
      'assets/content/asambleas_segundo_ciclo/asamblea.setembro.5_infantil.json';
  static const String baseAsambleaSetembro6 =
      'assets/content/asambleas_segundo_ciclo/asamblea.setembro.6_infantil.json';

  /// Loads and parses an [Unidad] from an asset path.
  Future<Unidad> loadUnidadFromAsset(String assetPath) async {
    final jsonString = await _stringLoader(assetPath);
    return parseUnidad(jsonString);
  }

  /// Loads and parses a [Capsula] from an asset path.
  Future<Capsula> loadCapsulaFromAsset(String assetPath) async {
    final jsonString = await _stringLoader(assetPath);
    return parseCapsula(jsonString);
  }

  /// Parses an [Unidad] from a raw JSON string.
  Unidad parseUnidad(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object at root for Unidad');
    }
    return Unidad.fromJson(decoded);
  }

  /// Parses a [Capsula] from a raw JSON string.
  Capsula parseCapsula(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object at root for Capsula');
    }
    return Capsula.fromJson(decoded);
  }

  /// Loads multiple [Unidad] instances from a list of asset paths.
  Future<List<Unidad>> loadAllUnidades(List<String> assetPaths) async {
    final List<Unidad> list = [];
    for (final path in assetPaths) {
      final unidad = await loadUnidadFromAsset(path);
      list.add(unidad);
    }
    return List.unmodifiable(list);
  }

  /// Loads multiple [Capsula] instances from a list of asset paths.
  Future<List<Capsula>> loadAllCapsulas(List<String> assetPaths) async {
    final List<Capsula> list = [];
    for (final path in assetPaths) {
      final capsula = await loadCapsulaFromAsset(path);
      list.add(capsula);
    }
    return List.unmodifiable(list);
  }

  /// Loads and parses an [AsambleaSegundoCiclo] from an asset path.
  Future<AsambleaSegundoCiclo> loadAsambleaSegundoCiclo(String assetPath) async {
    final jsonString = await _stringLoader(assetPath);
    return parseAsambleaSegundoCiclo(jsonString);
  }

  /// Alias for [loadAsambleaSegundoCiclo] matching [loadUnidadFromAsset] nomenclature.
  Future<AsambleaSegundoCiclo> loadAsambleaSegundoCicloFromAsset(
          String assetPath) =>
      loadAsambleaSegundoCiclo(assetPath);

  /// Parses an [AsambleaSegundoCiclo] from a raw JSON string.
  AsambleaSegundoCiclo parseAsambleaSegundoCiclo(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
          'Expected JSON object at root for AsambleaSegundoCiclo');
    }
    return AsambleaSegundoCiclo.fromJson(decoded);
  }

  /// Loads multiple [AsambleaSegundoCiclo] instances from a list of asset paths.
  Future<List<AsambleaSegundoCiclo>> loadAllAsambleasSegundoCiclo(
      List<String> assetPaths) async {
    final List<AsambleaSegundoCiclo> list = [];
    for (final path in assetPaths) {
      final asamblea = await loadAsambleaSegundoCiclo(path);
      list.add(asamblea);
    }
    return List.unmodifiable(list);
  }

  /// Decodes raw JSON string safely into a Map.
  Map<String, dynamic> decodeJson(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON map structure');
    }
    return decoded;
  }
}
