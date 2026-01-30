import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final _supabase = Supabase.instance.client;
  User? _currentUser;
  bool _isLoading = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthService() {
    _currentUser = _supabase.auth.currentUser;
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      notifyListeners();
    });
  }

  /// Inicia sesión con email y contraseña
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Registra un nuevo usuario
  Future<void> signUp(
    String email,
    String password, {
    String? displayName,
  }) async {
    _setLoading(true);
    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: displayName != null ? {'display_name': displayName} : null,
      );
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  /// Cierra la sesión
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

final authService = AuthService();
