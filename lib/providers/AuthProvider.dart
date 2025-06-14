import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService apiService;

  String? _token;
  String? _userType;
  String? _email;
  String? _id;
  bool _isLoading = false;
  String? _error;

  String? get token => _token;
  String? get userType => _userType;
  String? get email => _email;
  String? get id => _id;
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
      _id = prefs.getString('auth_id');
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
        _id = data['id'];
        apiService.setToken(_token);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _token!);
        if (_id != null) {
          await prefs.setString('auth_id', _id!);
        }

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
    _id = null;
    apiService.setToken(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_id');

    notifyListeners();
  }
}