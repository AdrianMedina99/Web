import 'package:flutter/material.dart';
import '../api_service.dart';

class UserProvider extends ChangeNotifier {
  final ApiService apiService;

  UserProvider({required this.apiService});

  List<Map<String, dynamic>> _clientUsers = [];
  List<Map<String, dynamic>> _businessUsers = [];
  bool _loading = false;

  List<Map<String, dynamic>> get clientUsers => _clientUsers;
  List<Map<String, dynamic>> get businessUsers => _businessUsers;
  bool get loading => _loading;

  Future<void> fetchUsers() async {
    _loading = true;
    notifyListeners();

    final clients = await apiService.getAllClientUsers();
    final business = await apiService.getAllBusinessUsers();

    _clientUsers = await Future.wait(clients.map((u) async {
      final uid = u['id'] ?? u['uid'];
      final valorations = await apiService.getValorationsByValorado(uid);
      double valoracion = 0;
      if (valorations.isNotEmpty) {
        valoracion = valorations.map((v) => (v['rating'] as num?)?.toDouble() ?? 0).reduce((a, b) => a + b) / valorations.length;
      }
      final quedadas = await apiService.getQuedadasPorCreador(uid);
      final quedadasCreadas = quedadas.length;
      return {
        ...u,
        'valoracion': valoracion,
        'quedadasCreadas': quedadasCreadas,
        'banned': u['banned'] ?? false,
      };
    }));

    _businessUsers = await Future.wait(business.map((u) async {
      final uid = u['id'] ?? u['uid'];
      final valorations = await apiService.getValorationsByValorado(uid);
      double valoracion = 0;
      if (valorations.isNotEmpty) {
        valoracion = valorations.map((v) => (v['rating'] as num?)?.toDouble() ?? 0).reduce((a, b) => a + b) / valorations.length;
      }
      final quedadas = await apiService.getQuedadasPorCreador(uid);
      final quedadasCreadas = quedadas.length;
      return {
        ...u,
        'valoracion': valoracion,
        'quedadasCreadas': quedadasCreadas,
        'banned': u['banned'] ?? false,
      };
    }));

    _loading = false;
    notifyListeners();
  }
}
