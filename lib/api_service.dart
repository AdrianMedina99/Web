// lib/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl;
  String? _token;

  ApiService({required this.baseUrl});

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders({bool needsAuth = true}) {
    final headers = {'Content-Type': 'application/json'};
    if (needsAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // =========
  // Auth
  // =========

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: _getHeaders(needsAuth: false),
      body: jsonEncode({
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('token')) setToken(data['token']);
      return data;
    } else {
      throw Exception('Error al iniciar sesión: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> validateToken(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/validate-token'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al validar token: ${response.body}');
    }
  }

  // =========
  // Users
  // =========

  // --- Business Users ---

  // Obtener un usuario de negocio por ID
  Future<Map<String, dynamic>> getBusinessUser(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/businessUsers/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuario de negocio: ${response.body}');
    }
  }

  // Obtener todos los usuarios de negocio
  Future<List<dynamic>> getAllBusinessUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/businessUsers'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuarios de negocio: ${response.body}');
    }
  }

  // Actualizar un usuario de negocio
  Future<String> updateBusinessUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/businessUsers/$id'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al actualizar usuario de negocio: ${response.body}');
    }
  }

  // Actualizar un usuario de negocio con foto
  Future<String> updateBusinessUserWithPhoto(String id, Map<String, dynamic> userData, File? photoFile) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/businessUsers/$id'));

      // Agregar token de autorización
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      // Convertir userData a formato JSON y agregarlo como parte de la solicitud
      request.files.add(http.MultipartFile.fromString(
        'user',
        jsonEncode(userData),
        contentType: MediaType('application', 'json'),
      ));

      // Si hay una foto para subir, agregarla
      if (photoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Error al actualizar usuario de negocio: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Eliminar un usuario de negocio
  Future<String> deleteBusinessUser(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/businessUsers/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al eliminar usuario de negocio: ${response.body}');
    }
  }

  // --- Client Users ---

  // Obtener un usuario cliente por ID
  Future<Map<String, dynamic>> getClientUser(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/clientUsers/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Error al obtener usuario cliente: ${response.body}');
    }
  }

  // Obtener todos los usuarios cliente
  Future<List<dynamic>> getAllClientUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/clientUsers'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener usuarios cliente: ${response.body}');
    }
  }

  // Actualizar un usuario cliente
  Future<String> updateClientUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/clientUsers/$id'),
      headers: _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al actualizar usuario cliente: ${response.body}');
    }
  }

  // Actualizar un usuario cliente con foto
  Future<String> updateClientUserWithPhoto(String id, Map<String, dynamic> userData, File? photoFile) async {
    try {
      var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/api/clientUsers/$id'));

      // Agregar token de autorización
      request.headers.addAll({
        'Authorization': 'Bearer $_token',
      });

      // Convertir userData a formato JSON y agregarlo como parte de la solicitud
      request.files.add(http.MultipartFile.fromString(
        'user',
        jsonEncode(userData),
        contentType: MediaType('application', 'json'),
      ));

      // Si hay una foto para subir, agregarla
      if (photoFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'photo',
          photoFile.path,
        ));
      }

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Error al actualizar usuario cliente: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error en la solicitud: $e');
    }
  }

  // Eliminar un usuario cliente
  Future<String> deleteClientUser(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/clientUsers/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Error al eliminar usuario cliente: ${response.body}');
    }
  }

  // =========
  // Valorations
  // =========

  // Obtener valoraciones por ID de valorado
  Future<List<dynamic>> getValorationsByValorado(String valoradoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/valorations/byValorado/$valoradoId'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener las valoraciones: ${response.body}');
    }
  }

  // =========
  // Events
  // =========

  Future<List<dynamic>> getAllEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/events'),
      headers: _getHeaders(),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener eventos: ${response.body}');
    }
  }

  // Eliminar un evento
  Future<void> deleteEvent(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/events/$id'),
      headers: _getHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar el evento: ${response.body}');
    }
  }

  Future<List<dynamic>> getQuedadasPorCreador(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/quedadas/creador/$userId'),
      headers: _getHeaders(),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al listar quedadas: ${response.body}');
    }
  }

  // =========
  // Categories
  // =========

  Future<List<dynamic>> getAllCategories() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories'),
      headers: _getHeaders(),
    );
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener categorías: ${response.body}');
    }
  }

  // Obtener una categoría por ID
  Future<Map<String, dynamic>> getCategoryById(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/categories/$id'),
      headers: _getHeaders(),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener la categoría: ${response.body}');
    }
  }

  // Crear una categoría
  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/categories'),
      headers: _getHeaders(),
      body: jsonEncode(categoryData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al crear la categoría: ${response.body}');
    }
  }

  // Actualizar una categoría
  Future<Map<String, dynamic>> updateCategory(String id, Map<String, dynamic> categoryData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/categories/$id'),
      headers: _getHeaders(),
      body: jsonEncode(categoryData),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al actualizar la categoría: ${response.body}');
    }
  }

  // Eliminar una categoría
  Future<void> deleteCategory(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/categories/$id'),
      headers: _getHeaders(),
    );
    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la categoría: ${response.body}');
    }
  }

  // =========
  // Media
  // =========

  // Subir un SVG a Firebase Storage y obtener la URL
  Future<String> uploadSvgToFirebaseStorage({
    required String svgContent,
    required String fileName,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/media/upload'),
      headers: _getHeaders(),
      body: jsonEncode({
        'fileName': fileName,
        'fileType': 'svg',
        'content': svgContent,
        'name': name,
      }),
    );
    if (response.statusCode == 200) {
      return response.body.replaceAll('"', ''); // El backend devuelve la URL como string
    } else {
      throw Exception('Error al subir SVG a Firebase Storage: ${response.body}');
    }
  }
}

