import 'package:flutter/material.dart';
import '../../../constants.dart';

class TableReports extends StatefulWidget {
  const TableReports({Key? key}) : super(key: key);

  @override
  State<TableReports> createState() => _TableReportsState();
}

class _TableReportsState extends State<TableReports> {
  final List<Report> demoReports = const [
    Report(
      id: "R001",
      reportado: "juan@example.com",
      reportador: "maria@example.com",
      fecha: "2024-06-01",
      tipo: "CLIENT",
    ),
    Report(
      id: "R002",
      reportado: "negocio@empresa.com",
      reportador: "luis@example.com",
      fecha: "2024-06-02",
      tipo: "BUSINESS",
    ),
    Report(
      id: "R003",
      reportado: "Evento 1",
      reportador: "ana@example.com",
      fecha: "2024-06-03",
      tipo: "EVENT",
    ),
  ];

  Report? selectedReport;
  final TextEditingController _respuestaController = TextEditingController();

  String selectedTipo = "Todos";
  final List<String> tipoOptions = ["Todos", "CLIENT", "BUSINESS", "EVENT"];

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  void _selectReport(Report report) {
    setState(() {
      selectedReport = report;
      _respuestaController.clear();
    });
  }

  void _accionSobreIncidencia(String accion) {
    // Aquí iría la lógica para procesar la acción (denegar, ban temporal, ban permanente)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Acción "$accion" realizada sobre la incidencia ${selectedReport?.id ?? ""}')),
    );
    setState(() {
      selectedReport = null;
      _respuestaController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<Report> filteredReports = selectedTipo == "Todos"
        ? demoReports
        : demoReports.where((r) => r.tipo == selectedTipo).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filtro por tipo
        Row(
          children: [
            const Text("Filtrar por tipo: "),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: selectedTipo,
              items: tipoOptions
                  .map((tipo) => DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedTipo = value!;
                  selectedReport = null;
                  _respuestaController.clear();
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: screenWidth * 0.8,
          padding: EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            color: secondaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lista de Reportes",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: defaultPadding,
                  columns: const [
                    DataColumn(label: Text("ID")),
                    DataColumn(label: Text("Reportado")),
                    DataColumn(label: Text("Reportador")),
                    DataColumn(label: Text("Fecha")),
                    DataColumn(label: Text("Tipo")),
                  ],
                  rows: filteredReports.map(
                    (report) => DataRow(
                      selected: selectedReport?.id == report.id,
                      onSelectChanged: (_) => _selectReport(report),
                      cells: [
                        DataCell(Text(report.id)),
                        DataCell(Text(report.reportado)),
                        DataCell(Text(report.reportador)),
                        DataCell(Text(report.fecha)),
                        DataCell(Text(report.tipo)),
                      ],
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
        if (selectedReport != null) ...[
          SizedBox(height: 32),
          Center(
            child: Container(
              width: screenWidth * 0.6,
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Responder a la incidencia", style: Theme.of(context).textTheme.titleSmall),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("ID de reporte: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(selectedReport!.id),
                    ],
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _respuestaController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: "Respuesta",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _accionSobreIncidencia("Denegar"),
                        icon: Icon(Icons.cancel, color: Colors.green),
                        label: Text("Denegar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade100,
                          foregroundColor: Colors.green.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _accionSobreIncidencia("Ban temporal"),
                        icon: Icon(Icons.timer, color: Colors.orange),
                        label: Text("Ban temporal"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _accionSobreIncidencia("Ban permanente"),
                        icon: Icon(Icons.block, color: Colors.red),
                        label: Text("Ban permanente"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          selectedReport = null;
                          _respuestaController.clear();
                        });
                      },
                      child: Text("Cancelar"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class Report {
  final String id;
  final String reportado;
  final String reportador;
  final String fecha;
  final String tipo;

  const Report({
    required this.id,
    required this.reportado,
    required this.reportador,
    required this.fecha,
    required this.tipo,
  });
}
