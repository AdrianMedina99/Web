import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../providers/DashboardProvider.dart';

class RecentFiles extends StatelessWidget {
  const RecentFiles({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dashboard = Provider.of<DashboardProvider>(context);
    final type = dashboard.selectedTable;
    final loading = dashboard.tableLoading;
    final data = dashboard.tableData;

    String title = "Selecciona una tarjeta para ver detalles";
    List<DataColumn> columns = [];
    List<DataRow> rows = [];

    if (type == DashboardTableType.businessUsers) {
      title = "Usuarios Negocio";
      columns = const [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Nombre")),
      ];
      rows = data.map<DataRow>((user) {
        return DataRow(
          cells: [
            DataCell(Text(user['id']?.toString() ?? '')),
            DataCell(Text(user['nombre'] ?? '')),
          ],
        );
      }).toList();
    } else if (type == DashboardTableType.clientUsers) {
      title = "Usuarios Cliente";
      columns = const [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Nombre")),
        DataColumn(label: Text("Apellido")),
      ];
      rows = data.map<DataRow>((user) {
        return DataRow(
          cells: [
            DataCell(Text(user['id']?.toString() ?? '')),
            DataCell(Text(user['nombre'] ?? '')),
            DataCell(Text(user['apellidos'] ?? '')),
          ],
        );
      }).toList();
    } else if (type == DashboardTableType.events) {
      title = "Eventos";
      columns = const [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Título")),
        DataColumn(label: Text("Capacidad")),
      ];
      rows = data.map<DataRow>((event) {
        return DataRow(
          cells: [
            DataCell(Text(event['id']?.toString() ?? '')),
            DataCell(Text(event['title'] ?? '')),
            DataCell(Text(event['capacity']?.toString() ?? '')),
          ],
        );
      }).toList();
    } else if (type == DashboardTableType.reports) {
      title = "Reportes";
      columns = const [
        DataColumn(label: Text("ID")),
        DataColumn(label: Text("Tipo")),
        DataColumn(label: Text("Estado")),
        DataColumn(label: Text("Descripción")),
      ];
      rows = data.map<DataRow>((report) {
        return DataRow(
          cells: [
            DataCell(Text(report['id']?.toString() ?? '')),
            DataCell(Text(report['type'] ?? '')),
            DataCell(Text(report['status'] ?? '')),
            DataCell(Text(report['description'] ?? '')),
          ],
        );
      }).toList();
    }

    return Container(
      margin: EdgeInsets.only(bottom: 32),
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        border: Border.all(color: Colors.blueGrey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 16),
          if (loading)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (columns.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(child: Text("Selecciona una tarjeta para ver la tabla")),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: defaultPadding,
                columns: columns,
                rows: rows,
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    return Colors.blueGrey.shade900.withOpacity(0.8);
                  },
                ),
                headingTextStyle: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Colors.blueGrey.shade100.withOpacity(0.3);
                    }
                    return Colors.transparent;
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
