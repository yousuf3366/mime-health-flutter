import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/exceptions.dart';
import '../mapper/intelliprove_post_message_parser.dart';

/// Native IntelliProve WebView bridge — channel name and methods from:
/// https://docs.intelliprove.com/technical-docs/flutter
class IntelliProveWebViewBridge {
  IntelliProveWebViewBridge({MethodChannel? channel})
    : _channel = channel ?? const MethodChannel(_channelName);

  static const _channelName = 'com.intelliprove/webview';

  final MethodChannel _channel;

  Completer<String>? _scanCompleter;
  String? _lastFailureMessage;
  String? _pendingFaceScanId;

  /// Opens the Face Scan plug-in.
  ///
  /// Returns a face-scan id when the plug-in reports a scan id. Callers must
  /// still validate the scan (e.g. Mime `POST /scans`) before continuing the
  /// UX — `recordingStopped` alone is not proof of a good measurement.
  Future<String> runScan(String url) async {
    _scanCompleter = Completer<String>();
    _lastFailureMessage = null;
    _pendingFaceScanId = null;
    _channel.setMethodCallHandler(_onNativeCallback);

    try {
      await _channel.invokeMethod<void>('openWebview', {'url': url});
    } on MissingPluginException {
      _cleanupHandler();
      throw const FaceScanFailedException(
        'IntelliProve native WebView is not available on this platform.',
      );
    } on PlatformException catch (error) {
      _cleanupHandler();
      throw FaceScanFailedException(
        error.message ?? 'Failed to open Face Scan WebView.',
        code: error.code,
        originalError: error,
      );
    }

    try {
      return await _scanCompleter!.future;
    } finally {
      _cleanupHandler();
    }
  }

  void _cleanupHandler() {
    _channel.setMethodCallHandler(null);
    _scanCompleter = null;
    _lastFailureMessage = null;
    _pendingFaceScanId = null;
  }

  Future<void> _onNativeCallback(MethodCall call) async {
    if (call.method != 'didReceivePostMessage') return;
    final raw = call.arguments?.toString() ?? '';
    if (kDebugMode) {
      debugPrint('[IntelliProve] postMessage: $raw');
    }
    _handlePostMessage(raw);
  }

  void _handlePostMessage(String raw) {
    final completer = _scanCompleter;
    if (completer == null || completer.isCompleted) return;

    final event = IntelliProvePostMessageParser.parse(raw);
    if (event == null) return;

    final stage = event.stage.toLowerCase();
    final eventId = IntelliProvePostMessageParser.faceScanIdFromEvent(event);
    log(
      '...............stage........>>>>${stage}..............event.....${event.raw}',
    );
    if (eventId != null) {
      _pendingFaceScanId = eventId;
    }

    if (stage == 'camera') {
      final status = event.cameraStatus;
      if (status == 'denied' || status == 'no_camera') {
        _lastFailureMessage = IntelliProvePostMessageParser.userMessageForEvent(
          event,
        );
      }
      return;
    }

    if (stage == 'timeout') {
      _lastFailureMessage = IntelliProvePostMessageParser.userMessageForEvent(
        event,
      );
      unawaited(_closeNativeWebView());
      _failScan(
        FaceScanFailedException(
          _lastFailureMessage ??
              'The face scan timed out due to inactivity. Please try again.',
        ),
      );
      return;
    }

    // Biomarker payload — confirmed success; close to skip IntelliProve questions.
    // if (IntelliProvePostMessageParser.isConfirmedSuccessStage(stage)) {
    //   unawaited(_closeNativeWebView());
    //   final id = eventId ?? _pendingFaceScanId;
    //   if (id != null) {
    //     completer.complete(id);
    //   } else {
    //     _failScan(
    //       const FaceScanFailedException(
    //         'Face scan finished without a scan id.',
    //       ),
    //     );
    //   }
    //   return;
    // }

    // Close early to skip IntelliProve questions. A uuid here is only a
    // candidate id — Mime store (caller) must confirm the scan is usable.
    // if (stage == 'recordingstopped') {
    //   unawaited(_closeNativeWebView());
    //   final id = eventId ?? _pendingFaceScanId;
    //   if (id != null) {
    //     completer.complete(id);
    //   } else {
    //     _failScan(
    //       const FaceScanFailedException(
    //         'Face scan stopped without a scan id. Please try again.',
    //       ),
    //     );
    //   }
    //   return;
    // }

    if (stage != 'dismiss') return;

    if (event.hasResults == true) {
      final id = eventId ?? _pendingFaceScanId;
      if (id != null) {
        completer.complete(id);
        return;
      }
      _failScan(
        const FaceScanFailedException('Face scan finished without a scan id.'),
      );
      return;
    }

    // Explicit failed / cancelled dismiss — do not treat as success.
    if (_lastFailureMessage != null) {
      _failScan(FaceScanFailedException(_lastFailureMessage!));
      return;
    }

    _failScan(const FaceScanCancelledException());
  }

  void _failScan(AppException error) {
    final completer = _scanCompleter;
    if (completer == null || completer.isCompleted) return;
    completer.completeError(error);
  }

  Future<void> _closeNativeWebView() async {
    try {
      await _channel.invokeMethod<void>('closeWebview');
    } on MissingPluginException {
      // Older native builds may not implement close — ignore.
    } on PlatformException catch (error) {
      if (kDebugMode) {
        debugPrint('[IntelliProve] closeWebview failed: ${error.message}');
      }
    }
  }
}
