import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _isAuthenticated = await _authService.isLoggedIn();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(username, password);

      if (success) {
        _isAuthenticated = true;
      } else {
        _errorMessage = 'Invalid username or password.';
      }

      return success;
    } catch (_) {
      _errorMessage = 'Unable to connect to the server.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
    String username,
    String email,
    String password,
    String passwordConfirm,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(
        username,
        email,
        password,
        passwordConfirm,
      );

      if (result['success'] == true) {
        return await login(username, password);
      }

      _errorMessage = result['error']?.toString() ?? 'Registration failed.';
      return false;
    } catch (_) {
      _errorMessage = 'Unable to connect to the server.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
