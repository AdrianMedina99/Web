import 'package:flutter/material.dart';
import '../api_service.dart';

class Event {
  final String id;
  final String title;
  final double lat;
  final double lon;
  final String categoryId;
  final int capacity;
  final Map<String, dynamic> rawData;

  Event({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    required this.categoryId,
    required this.capacity,
    required this.rawData,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      lat: (json['latitud'] as num).toDouble(),
      lon: (json['longitud'] as num).toDouble(),
      categoryId: json['categoryId'],
      capacity: json['capacity'],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return rawData;
  }
}

class EventProvider extends ChangeNotifier {
  final ApiService apiService;
  List<Event> _events = [];

  EventProvider({required this.apiService});

  List<Event> get events => _events;

  Future<void> loadEvents() async {
    try {
      final eventsData = await apiService.getAllEvents();
      _events = eventsData.map<Event>((e) => Event.fromJson(e)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar eventos: $e');
    }
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await apiService.deleteEvent(eventId);
      _events.removeWhere((element) => element.id == eventId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}

