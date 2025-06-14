
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../api_service.dart';
import '../../constants.dart';
import 'components/header.dart';
import '../../providers/DashboardProvider.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => DashboardProvider(
        Provider.of<ApiService>(context, listen: false),
      )..loadDashboardData(),
      child: Consumer<DashboardProvider>(
        builder: (context, dashboard, _) {
          if (dashboard.loading) {
            return Center(child: CircularProgressIndicator());
          }
          return SafeArea(
            child: SingleChildScrollView(
              primary: false,
              padding: EdgeInsets.all(defaultPadding),
              child: Column(
                children: [
                  Header(),
                  SizedBox(height: 60
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => dashboard.loadTable(DashboardTableType.businessUsers),
                                    child: _SummaryCard(
                                      title: "Usuarios Negocio",
                                      value: dashboard.totalBusinessUsers,
                                      color: Colors.blue,
                                      icon: Icons.business,
                                    ),
                                  ),
                                ),
                                SizedBox(width: defaultPadding / 2),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => dashboard.loadTable(DashboardTableType.clientUsers),
                                    child: _SummaryCard(
                                      title: "Usuarios Cliente",
                                      value: dashboard.totalClientUsers,
                                      color: Colors.green,
                                      icon: Icons.person,
                                    ),
                                  ),
                                ),
                                SizedBox(width: defaultPadding / 2),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => dashboard.loadTable(DashboardTableType.events),
                                    child: _SummaryCard(
                                      title: "Eventos",
                                      value: dashboard.totalEvents,
                                      color: Colors.orange,
                                      icon: Icons.event,
                                    ),
                                  ),
                                ),
                                SizedBox(width: defaultPadding / 2),
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () => dashboard.loadTable(DashboardTableType.reports),
                                    child: _SummaryCard(
                                      title: "Reportes",
                                      value: dashboard.totalReports,
                                      color: Colors.red,
                                      icon: Icons.report,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: defaultPadding),
                            Card(
                              color: secondaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "Distribución de entidades",
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: PieChart(
                                        PieChartData(
                                          sections: [
                                            PieChartSectionData(
                                              color: Colors.blue,
                                              value: dashboard.totalBusinessUsers.toDouble(),
                                              title: "Negocio",
                                              radius: 40,
                                              titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                            PieChartSectionData(
                                              color: Colors.green,
                                              value: dashboard.totalClientUsers.toDouble(),
                                              title: "Cliente",
                                              radius: 40,
                                              titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                            PieChartSectionData(
                                              color: Colors.orange,
                                              value: dashboard.totalEvents.toDouble(),
                                              title: "Eventos",
                                              radius: 40,
                                              titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                            PieChartSectionData(
                                              color: Colors.red,
                                              value: dashboard.totalReports.toDouble(),
                                              title: "Reportes",
                                              radius: 40,
                                              titleStyle: TextStyle(color: Colors.white, fontSize: 12),
                                            ),
                                          ],
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Container(
        width: 140,
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(height: 6),
            Text(
              "$value",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
