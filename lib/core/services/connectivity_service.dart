import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';

/// Global connectivity status - updates in real-time
/// Pings supabase.com every second to check connection
class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isConnected = false;
  bool _isChecking = false;
  Timer? _pingTimer;
  DateTime? _lastCheckTime;

  static const String _supabaseHost = 'supabase.com';
  static const Duration _checkInterval = Duration(seconds: 1);
  static const Duration _pingTimeout = Duration(seconds: 5);

  /// Current connection status
  bool get isConnected => _isConnected;

  /// Whether device is offline
  bool get isOffline => !_isConnected;

  /// Last time connectivity was checked
  DateTime? get lastCheckTime => _lastCheckTime;

  /// Start real-time connectivity monitoring
  void startMonitoring() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_checkInterval, (_) => _checkConnectivity());
    _checkConnectivity(); // Initial check
  }

  /// Stop monitoring
  void stopMonitoring() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  /// Manual connectivity check
  Future<bool> checkNow() async {
    await _checkConnectivity();
    return _isConnected;
  }

  Future<void> _checkConnectivity() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final result = await InternetAddress.lookup(
        _supabaseHost,
      ).timeout(_pingTimeout);

      final wasConnected = _isConnected;
      _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      _lastCheckTime = DateTime.now();

      if (wasConnected != _isConnected) {
        notifyListeners();
      }
    } on SocketException catch (_) {
      _updateOffline();
    } on TimeoutException catch (_) {
      _updateOffline();
    } catch (_) {
      // Keep current state on unknown errors
    } finally {
      _isChecking = false;
    }
  }

  void _updateOffline() {
    if (_isConnected) {
      _isConnected = false;
      _lastCheckTime = DateTime.now();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopMonitoring();
    super.dispose();
  }
}

/// Global instance for easy access
final connectivityService = ConnectivityService();
