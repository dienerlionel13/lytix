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
    if (_currentUser != null) {
      _loadUserDetails();
    }
    _supabase.auth.onAuthStateChange.listen((data) {
      _currentUser = data.session?.user;
      if (_currentUser != null) {
        _loadUserDetails();
      } else {
        notifyListeners();
      }
    });
  }

  Future<void> _loadUserDetails() async {
    try {
      final response = await _supabase
          .schema('lytix')
          .from('users')
          .select()
          .eq('id', _currentUser!.id)
          .maybeSingle();

      if (response == null) {
        // Si el usuario existe en Auth pero no en lytix.users, lo creamos
        await _supabase.schema('lytix').from('users').insert({
          'id': _currentUser!.id,
          'email': _currentUser!.email,
          'display_name': _currentUser!.userMetadata?['display_name'],
          'photo_url': _currentUser!.userMetadata?['avatar_url'],
        });
      }
    } catch (e) {
      debugPrint('Error verificando usuario en lytix.users: $e');
    } finally {
      notifyListeners();
    }
  }

  /// Inicia sesión con email y contraseña
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    try {
      await _supabase.auth.signInWithPassword(email: email, password: password);
      await _loadUserDetails();
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
