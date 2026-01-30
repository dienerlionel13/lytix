import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// Biometric Authentication Service
/// Supports Fingerprint and FaceID
class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  factory BiometricService() => _instance;
  BiometricService._internal();

  final LocalAuthentication _auth = LocalAuthentication();

  bool _isAvailable = false;
  List<BiometricType> _availableBiometrics = [];

  /// Whether biometric authentication is available on device
  bool get isAvailable => _isAvailable;

  /// List of available biometric types
  List<BiometricType> get availableBiometrics => _availableBiometrics;

  /// Whether device has fingerprint
  bool get hasFingerprint =>
      _availableBiometrics.contains(BiometricType.fingerprint);

  /// Whether device has face recognition
  bool get hasFaceId => _availableBiometrics.contains(BiometricType.face);

  /// Initialize and check biometric availability
  Future<void> initialize() async {
    try {
      _isAvailable = await _auth.canCheckBiometrics;

      if (_isAvailable) {
        _availableBiometrics = await _auth.getAvailableBiometrics();
      }
    } on PlatformException catch (_) {
      _isAvailable = false;
      _availableBiometrics = [];
    }
  }

  /// Authenticate user with biometrics
  /// Returns true if authentication successful
  Future<bool> authenticate({
    String reason = 'Por favor autentícate para acceder a Lytix',
  }) async {
    if (!_isAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Authenticate with any method (biometric or PIN/pattern)
  Future<bool> authenticateWithDeviceCredentials({
    String reason = 'Por favor autentícate para acceder a Lytix',
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Get friendly name for biometric type
  String getBiometricName() {
    if (hasFaceId) return 'Face ID';
    if (hasFingerprint) return 'Huella Digital';
    return 'Biométrico';
  }
}

/// Global instance
final biometricService = BiometricService();
