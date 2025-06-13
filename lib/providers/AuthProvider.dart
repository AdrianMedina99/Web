import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;

  String? _token;
  String? _userType;
  String? _email;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  String? get userType => _userType;
  String? get email => _email;
  bool get isLoading => _isLoading;
  String? get error => _error;

  AuthProvider({required this.apiService}) {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    if (savedToken != null) {
      _token = savedToken;
      apiService.setToken(_token);
      notifyListeners();
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await apiService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (data['userType'] == 'ADMIN' && data['success'] == true) {
        _token = data['token'];
        _userType = data['userType'];
        _email = data['email'];
        apiService.setToken(_token);

        // Guarda el token en localStorage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'No tienes permisos de administrador';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Error al iniciar sesión: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() async {
    _token = null;
    _userType = null;
    _email = null;
    apiService.setToken(null);

    // Elimina el token de localStorage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');

    notifyListeners();
  }
}