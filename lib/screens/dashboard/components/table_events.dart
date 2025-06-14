import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../api_service.dart';
import '../../../providers/EventProvider.dart';

class TableEvents extends StatefulWidget {
  final String filterCategoria;

  const TableEvents({Key? key, this.filterCategoria = "Todos"}) : super(key: key);

  @override
  State<TableEvents> createState() => _TableEventsState();
}

class _TableEventsState extends State<TableEvents> {
  Event? selectedEvent;

  @override
  void initState() {
    super.initState();
    Provider.of<EventProvider>(context, listen: false).loadEvents();
  }

  Future<String> _getCategoryTitle(String categoryId) async {
    final category = await Provider.of<ApiService>(context, listen: false).getCategoryById(categoryId);
    return category['title'] as String;
  }

  void _selectEvent(Event event) {
    setState(() {
      selectedEvent = event;
    });
  }

  void _closeDetails() {
    setState(() {
      selectedEvent = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final filteredEvents = eventProvider.events.where((event) {
          final matchCategoria = widget.filterCategoria == "Todos" || event.categoryId == widget.filterCategoria;
          return matchCategoria;
        }).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    "Lista de Eventos",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      columnSpacing: defaultPadding,
                      columns: const [
                        DataColumn(label: Text("Title")),
                        DataColumn(label: Text("Sitio")),
                        DataColumn(label: Text("Categoría")),
                        DataColumn(label: Text("Capacity")),
                        DataColumn(label: Text("Eliminar")),
                      ],
                      rows: filteredEvents.map((event) {
                        return DataRow(
                          selected: selectedEvent?.id == event.id,
                          onSelectChanged: (_) {
                            _selectEvent(event);
                          },
                          cells: [
                            DataCell(Text(event.title)),
                            DataCell(
                              Text('${event.lat}, ${event.lon}'),
                            ),
                            DataCell(
                              FutureBuilder<String>(
                                future: _getCategoryTitle(event.categoryId),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) return Text("Cargando...");
                                  return Text(snapshot.data ?? "No disponible");
                                },
                              ),
                            ),
                            DataCell(Text(event.capacity.toString())),
                            DataCell(
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await eventProvider.deleteEvent(event.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Evento eliminado correctamente")),
                                    );
                                    if (selectedEvent?.id == event.id) {
                                      _closeDetails();
                                    }
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Error al eliminar el evento")),
                                    );
                                  }
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            if (selectedEvent != null) ...[
              SizedBox(height: 24),
              Center(
                child: Container(
                  width: screenWidth * 0.7,
                  padding: EdgeInsets.all(defaultPadding),
                  decoration: BoxDecoration(
                    color: secondaryColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueGrey.shade100),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text(
                            "Detalles del Evento",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close, color: Colors.white70),
                            onPressed: _closeDetails,
                          ),
                        ],
                      ),
                      Divider(color: Colors.white24),
                      ...selectedEvent!.toJson().entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.key}: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[200],
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value is Map || entry.value is List
                                      ? entry.value.toString()
                                      : '${entry.value}',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
