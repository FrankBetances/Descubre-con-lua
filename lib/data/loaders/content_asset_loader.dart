import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
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

  /// Decodes raw JSON string safely into a Map.
  Map<String, dynamic> decodeJson(String rawJson) {
    final dynamic decoded = jsonDecode(rawJson);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid JSON map structure');
    }
    return decoded;
  }
}
