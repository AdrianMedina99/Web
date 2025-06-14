import 'package:flutter/material.dart';
import '../api_service.dart';

enum DashboardTableType { none, businessUsers, clientUsers, events, reports }

class DashboardProvider extends ChangeNotifier {
  final ApiService apiService;

  int totalBusinessUsers = 0;
  int totalClientUsers = 0;
  int totalEvents = 0;
  int totalReports = 0;
  bool loading = true;

  DashboardTableType selectedTable = DashboardTableType.none;
  List<dynamic> tableData = [];
  bool tableLoading = false;

  DashboardProvider(this.apiService);

  Future<void> loadDashboardData() async {
    loading = true;
    notifyListeners();
    try {
      final businessUsers = await apiService.getAllBusinessUsers();
      final clientUsers = await apiService.getAllClientUsers();
      final events = await apiService.getAllEvents();
      final reports = await apiService.getAllReports();

      totalBusinessUsers = businessUsers.length;
      totalClientUsers = clientUsers.length;
      totalEvents = events.length;
      totalReports = reports.length;
    } catch (e) {
      totalBusinessUsers = 0;
      totalClientUsers = 0;
      totalEvents = 0;
      totalReports = 0;
    }
    loading = false;
    notifyListeners();
  }

  Future<void> loadTable(DashboardTableType type) async {
    selectedTable = type;
    tableLoading = true;
    notifyListeners();
    try {
      switch (type) {
        case DashboardTableType.businessUsers:
          tableData = await apiService.getAllBusinessUsers();
          break;
        case DashboardTableType.clientUsers:
          tableData = await apiService.getAllClientUsers();
          break;
        case DashboardTableType.events:
          tableData = await apiService.getAllEvents();
          break;
        case DashboardTableType.reports:
          tableData = await apiService.getAllReports();
          break;
        default:
          tableData = [];
      }
    } catch (e) {
      tableData = [];
    }
    tableLoading = false;
    notifyListeners();
  }
}
