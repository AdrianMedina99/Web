import 'package:flutter/material.dart';
import '../api_service.dart';

class Category {
  final String id;
  final String title;
  final String svgContent;

  Category({required this.id, required this.title, required this.svgContent});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      svgContent: json['svgContent'] ?? '',
    );
  }
}

class CategoryProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Category> categories = [];
  bool loading = false;
  String? error;

  CategoryProvider({required this.apiService});

  Future<void> fetchCategories() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final data = await apiService.getAllCategories();
      categories = data.map<Category>((cat) => Category.fromJson(cat)).toList();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<Category?> getCategoryById(String id) async {
    try {
      final data = await apiService.getCategoryById(id);
      return Category.fromJson(data);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> createCategory(String title, String svgRawContent) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final svgUrl = await apiService.uploadSvgToFirebaseStorage(
        svgContent: svgRawContent,
        fileName: 'icono-${DateTime.now().millisecondsSinceEpoch}.svg',
        name: title,
      );
      await apiService.createCategory({
        'title': title,
        'svgContent': svgUrl,
      });
      await fetchCategories();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> updateCategory(String id, String title, String svgRawContent) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      final svgUrl = await apiService.uploadSvgToFirebaseStorage(
        svgContent: svgRawContent,
        fileName: 'icono-${DateTime.now().millisecondsSinceEpoch}.svg',
        name: title,
      );
      await apiService.updateCategory(id, {
        'title': title,
        'svgContent': svgUrl,
      });
      await fetchCategories();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }

  Future<void> deleteCategory(String id) async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      await apiService.deleteCategory(id);
      await fetchCategories();
    } catch (e) {
      error = e.toString();
    }
    loading = false;
    notifyListeners();
  }
}

