import 'dart:convert';

import '../mapper/face_scan_mapper.dart';

/// Parsed IntelliProve plug-in PostMessage (`stage` + `data`).
///
/// See https://docs.intelliprove.com/technical-docs/message-events
class IntelliProvePostMessage {
  const IntelliProvePostMessage({
    required this.stage,
    this.hasResults,
    this.cameraStatus,
    this.uuid,
    this.raw = const {},
  });

  final String stage;
  final bool? hasResults;
  final String? cameraStatus;
  final String? uuid;
  final Map<String, dynamic> raw;
}

/// Parses IntelliProve PostMessage JSON strings from the native WebView bridge.
class IntelliProvePostMessageParser {
  IntelliProvePostMessageParser._();

  static IntelliProvePostMessage? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    try {
      final decoded = jsonDecode(trimmed);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      final stage = map['stage']?.toString();
      if (stage == null || stage.isEmpty) return null;

      final data = map['data'];
      final dataMap = data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      return IntelliProvePostMessage(
        stage: stage,
        hasResults: dataMap['hasResults'] is bool
            ? dataMap['hasResults'] as bool
            : null,
        cameraStatus: dataMap['status']?.toString(),
        uuid: map['uuid']?.toString() ??
            dataMap['face_scan_id']?.toString() ??
            dataMap['faceScanId']?.toString(),
        raw: map,
      );
    } catch (_) {
      return null;
    }
  }

  /// Stages that mean biomarkers were produced (real success).
  ///
  /// `recordingStopped` is NOT included — it also fires on poor quality / network.
  static bool isConfirmedSuccessStage(String stage) {
    switch (stage.toLowerCase()) {
      case 'results':
      case 'buckets':
      case 'facescansuccessful':
      case 'facescansuccessfull':
        return true;
      default:
        return false;
    }
  }

  /// Face-scan id from event `uuid` when present.
  static String? faceScanIdFromEvent(IntelliProvePostMessage event) {
    final stage = event.stage.toLowerCase();
    if (stage == 'dismiss' && event.hasResults == false) return null;

    final uuid = event.uuid?.trim();
    if (uuid == null || uuid.isEmpty) return null;
    return FaceScanMapper.normalizeFaceScanId(uuid);
  }

  static String userMessageForEvent(IntelliProvePostMessage event) {
    final stage = event.stage.toLowerCase();
    if (stage == 'camera') {
      switch (event.cameraStatus) {
        case 'denied':
          return 'Camera permission was denied. Enable camera access and try again.';
        case 'no_camera':
          return 'No camera was found on this device.';
        default:
          return 'Camera is not available for the face scan.';
      }
    }
    if (stage == 'timeout' || event.stage == 'timeOut') {
      return 'The face scan timed out due to inactivity. Please try again.';
    }
    return 'Face scan ended without results.';
  }
}
