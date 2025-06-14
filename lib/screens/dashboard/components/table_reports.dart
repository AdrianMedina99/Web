import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../api_service.dart';
import '../../../providers/AuthProvider.dart';

class TableReports extends StatefulWidget {
  const TableReports({Key? key}) : super(key: key);

  @override
  State<TableReports> createState() => _TableReportsState();
}

class _TableReportsState extends State<TableReports> {
  List<Map<String, dynamic>> reports = [];
  Map<String, dynamic>? selectedReport;
  final TextEditingController _respuestaController = TextEditingController();
  String selectedTipo = "Todos";
  String selectedEstado = "Todos";
  final List<String> tipoOptions = ["Todos", "CLIENT", "BUSINESS", "EVENT"];
  final List<String> estadoOptions = ["Todos", "PENDIENTE", "REVISADO"];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  @override
  void dispose() {
    _respuestaController.dispose();
    super.dispose();
  }

  Future<void> _fetchReports() async {
    setState(() {
      isLoading = true;
    });
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final data = await apiService.getAllReports();
      setState(() {
        reports = List<Map<String, dynamic>>.from(data);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar reportes')),
      );
    }
  }

  Future<String> _resolveUserName(String id) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      final user = await apiService.getClientUser(id);
      final nombre = user['nombre'] ?? '';
      final apellidos = user['apellidos'] ?? '';
      return (nombre + (apellidos.isNotEmpty ? ' $apellidos' : '')).trim();
    } catch (_) {
      try {
        final user = await apiService.getBusinessUser(id);
        return user['nombre'] ?? id;
      } catch (_) {
        return id;
      }
    }
  }

  Future<String> _resolveReportedName(String id, String type) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      if (type == "EVENT") {
        final event = await apiService.getAllEvents();
        final found = event.firstWhere((e) => e['id'] == id, orElse: () => null);
        return found != null ? (found['title'] ?? id) : id;
      } else if (type == "CLIENT") {
        final user = await apiService.getClientUser(id);
        final nombre = user['nombre'] ?? '';
        final apellidos = user['apellidos'] ?? '';
        return (nombre + (apellidos.isNotEmpty ? ' $apellidos' : '')).trim();
      } else if (type == "BUSINESS") {
        final user = await apiService.getBusinessUser(id);
        return user['nombre'] ?? id;
      }
    } catch (_) {}
    return id;
  }

  void _selectReport(Map<String, dynamic> report) {
    setState(() {
      selectedReport = report;
      _respuestaController.text = report['respuesta']?.toString() ?? '';
    });
  }

  Future<void> _accionSobreIncidencia(String accion) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final reportId = selectedReport?['id'];
    final respuesta = _respuestaController.text.trim();
    final idAdmin = authProvider.id ?? 'adm in';

    if (reportId == null) return;

    final Map<String, dynamic> reportUpdate = {
      'id': selectedReport?['id'],
      'idAdmin': idAdmin,
      'idReported': selectedReport?['idReported'],
      'idReporter': selectedReport?['idReporter'],
      'type': selectedReport?['type'],
      'description': selectedReport?['description'],
      'respuesta': respuesta,
      'status': 'REVISADO',
    };

    try {
      await apiService.updateReport(reportId, reportUpdate);

      if (accion == "Ban Manual") {
        final type = selectedReport?['type'];
        final idReported = selectedReport?['idReported'];

        if (type == "EVENT") {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("¿Estás seguro?"),
              content: Text("¿Seguro que quieres eliminar el evento denunciado?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Eliminar"),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            await apiService.deleteEvent(idReported);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Evento eliminado y reporte actualizado')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Eliminación cancelada')),
            );
          }
        } else if (type == "CLIENT" || type == "BUSINESS") {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("¿Estás seguro?"),
              content: Text("¿Seguro que quieres banear al usuario denunciado?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Banear"),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            if (type == "CLIENT") {
              await apiService.updateClientBan(idReported);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuario cliente baneado/desbaneado y reporte actualizado')),
              );
            } else if (type == "BUSINESS") {
              await apiService.updateBusinessBan(idReported);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Usuario de negocio baneado/desbaneado y reporte actualizado')),
              );
            }
          }else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Baneo cancelado')),
            );
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte actualizado correctamente')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al procesar la acción: $e')),
      );
    }

    setState(() {
      selectedReport = null;
      _respuestaController.clear();
    });
    await _fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final filteredReports = reports.where((r) {
      final tipoOk = selectedTipo == "Todos" || r['type'] == selectedTipo;
      final estadoOk = selectedEstado == "Todos" || r['status'] == selectedEstado;
      return tipoOk && estadoOk;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            const SizedBox(width: 30),
            const Text("Filtrar por estado: "),
            const SizedBox(width: 10),
            DropdownButton<String>(
              value: selectedEstado,
              items: estadoOptions
                  .map((estado) => DropdownMenuItem(
                        value: estado,
                        child: Text(estado),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedEstado = value!;
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
              isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : FutureBuilder<List<List<String>>>(
                future: filteredReports.isEmpty
                    ? Future.value([])
                    : Future.wait(filteredReports.map((report) async {
                  final denunciante = await _resolveUserName(report['idReporter'] ?? '');
                  final denunciado = await _resolveReportedName(
                      report['idReported'] ?? '', report['type'] ?? '');
                  return [
                    report['id']?.toString() ?? '',
                    denunciante,
                    report['type']?.toString() ?? '',
                    report['status']?.toString() ?? '',
                    denunciado,
                  ];
                }).toList()),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final rowsData = snapshot.data!;

                  if (rowsData.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Center(child: Text("No hay reportes que coincidan con los filtros")),
                    );
                  }

                  return SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: defaultPadding,
                      columns: const [
                        DataColumn(label: Text("ID")),
                        DataColumn(label: Text("Denunciante")),
                        DataColumn(label: Text("Tipo")),
                        DataColumn(label: Text("Estado")),
                        DataColumn(label: Text("Denunciado")),
                      ],
                      rows: List<DataRow>.generate(rowsData.length, (index) {
                        final report = filteredReports[index];
                        final row = rowsData[index];
                        return DataRow(
                          selected: selectedReport?['id'] == report['id'],
                          onSelectChanged: (_) => _selectReport(report),
                          cells: [
                            DataCell(Text(row[0])),
                            DataCell(Text(row[1])),
                            DataCell(Text(row[2])),
                            DataCell(Text(row[3])),
                            DataCell(Text(row[4])),
                          ],
                        );
                      }),
                    ),
                  );
                },
              )
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
                      Text(selectedReport!['id']?.toString() ?? ''),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Denunciante: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      FutureBuilder<String>(
                        future: _resolveUserName(selectedReport!['idReporter'] ?? ''),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Tipo: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(selectedReport!['type']?.toString() ?? ''),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Estado: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(selectedReport!['status']?.toString() ?? ''),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text("Denunciado: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      FutureBuilder<String>(
                        future: _resolveReportedName(selectedReport!['idReported'] ?? '', selectedReport!['type'] ?? ''),
                        builder: (context, snapshot) {
                          return Text(snapshot.data ?? '');
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Descripción: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(child: Text(selectedReport!['description']?.toString() ?? '')),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Respuesta: ", style: TextStyle(fontWeight: FontWeight.bold)),
                      Expanded(
                        child: TextFormField(
                          controller: _respuestaController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: "Respuesta",
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
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
                        onPressed: () => _accionSobreIncidencia("Ban Manual"),
                        icon: Icon(Icons.block, color: Colors.red),
                        label: Text("Ban Manual"),
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

