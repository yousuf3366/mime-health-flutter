import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Monitors network connectivity and exposes a reactive stream.
class ConnectivityService {
  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Starts listening to platform connectivity changes.
  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(_updateStatus);
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    _updateStatus(results);
    return _isOnline;
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final online = results.any(
      (result) =>
          result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn,
    );

    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(_isOnline);
    } else {
      _isOnline = online;
    }
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}
