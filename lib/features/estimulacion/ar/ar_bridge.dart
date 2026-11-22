import 'dart:convert';

import 'package:flutter/services.dart';

class ArAvailability {
  final bool available;
  final bool hasCamera;
  final bool hasFrontCamera;
  final bool arCoreSupported;
  final bool modelShaOk;
  final String reason;

  const ArAvailability({
    required this.available,
    required this.hasCamera,
    required this.hasFrontCamera,
    required this.arCoreSupported,
    required this.modelShaOk,
    required this.reason,
  });

  static const unsupported = ArAvailability(
    available: false,
    hasCamera: false,
    hasFrontCamera: false,
    arCoreSupported: false,
    modelShaOk: false,
    reason: 'UNSUPPORTED',
  );

  factory ArAvailability.fromMap(Map<Object?, Object?> raw) {
    return ArAvailability(
      available: raw['available'] == true,
      hasCamera: raw['hasCamera'] == true,
      hasFrontCamera: raw['hasFrontCamera'] == true,
      arCoreSupported: raw['arCoreSupported'] == true,
      modelShaOk: raw['modelShaOk'] == true,
      reason: (raw['reason'] ?? 'UNKNOWN').toString(),
    );
  }
}

class ArLaunchOutcome {
  final String outcome;
  final List<String> confirmed;
  final bool gestureDone;
  final String? reason;

  const ArLaunchOutcome({
    required this.outcome,
    this.confirmed = const [],
    this.gestureDone = false,
    this.reason,
  });

  bool get needsFallback => outcome == 'unsupported' || outcome == 'denied';

  factory ArLaunchOutcome.fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) {
      return const ArLaunchOutcome(outcome: 'unsupported', reason: 'EMPTY');
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return ArLaunchOutcome(
        outcome: (decoded['outcome'] ?? 'completed').toString(),
        confirmed: [
          for (final x in (decoded['confirmed'] as List? ?? const []))
            x.toString(),
        ],
        gestureDone: decoded['gestureDone'] == true,
        reason: decoded['reason']?.toString(),
      );
    } catch (_) {
      return const ArLaunchOutcome(outcome: 'aborted', reason: 'PARSE_ERROR');
    }
  }
}

abstract class ArBridge {
  Future<ArAvailability> checkAvailability();
  Future<ArLaunchOutcome> openScene(String specJson);
  Future<ArLaunchOutcome> openFaceActivity(String specJson);
}

class MethodChannelArBridge implements ArBridge {
  static const MethodChannel _channel =
      MethodChannel('com.earlify.descubreconlua/ar');

  const MethodChannelArBridge();

  @override
  Future<ArAvailability> checkAvailability() async {
    try {
      final res = await _channel
          .invokeMethod<Map<Object?, Object?>>('checkAvailability');
      if (res == null) return ArAvailability.unsupported;
      return ArAvailability.fromMap(res);
    } on MissingPluginException {
      return ArAvailability.unsupported;
    } on PlatformException {
      return ArAvailability.unsupported;
    }
  }

  @override
  Future<ArLaunchOutcome> openScene(String specJson) async {
    try {
      final raw = await _channel.invokeMethod<String>(
        'openScene',
        {'specJson': specJson},
      );
      return ArLaunchOutcome.fromJsonString(raw);
    } on MissingPluginException {
      return const ArLaunchOutcome(
        outcome: 'unsupported',
        reason: 'NO_NATIVE_MODULE',
      );
    } on PlatformException catch (e) {
      return ArLaunchOutcome(
        outcome: 'unsupported',
        reason: e.code,
      );
    }
  }

  @override
  Future<ArLaunchOutcome> openFaceActivity(String specJson) async {
    try {
      final raw = await _channel.invokeMethod<String>(
        'openFaceActivity',
        {'specJson': specJson},
      );
      return ArLaunchOutcome.fromJsonString(raw);
    } on MissingPluginException {
      return const ArLaunchOutcome(
        outcome: 'unsupported',
        reason: 'NO_NATIVE_MODULE',
      );
    } on PlatformException catch (e) {
      return ArLaunchOutcome(
        outcome: 'unsupported',
        reason: e.code,
      );
    }
  }
}
