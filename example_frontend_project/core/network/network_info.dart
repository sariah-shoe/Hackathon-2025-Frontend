import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/type_defs.dart';

/// Handles network connectivity monitoring
class NetworkInfo {
  static final NetworkInfo _instance = NetworkInfo._internal();
  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  bool _isInitialized = false;
  bool _hasConnection = true;

  factory NetworkInfo() => _instance;

  NetworkInfo._internal() : _connectivity = Connectivity();

  /// Initialize network monitoring
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Get initial connectivity status
    _hasConnection = await _checkConnection();

    // Listen for connectivity changes
    _connectivity.onConnectivityChanged.listen((result) async {
      final hasConnection = result != ConnectivityResult.none;
      if (_hasConnection != hasConnection) {
        _hasConnection = hasConnection;
        _controller.add(hasConnection);
      }
    });

    _isInitialized = true;
  }

  /// Stream of connectivity status changes
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Current connectivity status
  bool get hasConnection => _hasConnection;

  /// Check current connection status
  Future<bool> _checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Dispose resources
  Future<void> dispose() async {
    await _controller.close();
  }

  /// Add a connectivity change listener
  StreamSubscription<bool> addListener(ConnectionStateCallback listener) {
    return onConnectivityChanged.listen(listener);
  }
}
