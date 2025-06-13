import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';
import '../../../api_service.dart';

class TableEvents extends StatefulWidget {
  final String filterCategoria;
  final String filterSitio;

  const TableEvents({Key? key, this.filterCategoria = "Todos", this.filterSitio = "Todos"}) : super(key: key);

  @override
  State<TableEvents> createState() => _TableEventsState();
}

class _TableEventsState extends State<TableEvents> {
  List<Event> events = [
    Event(
      id: "1",
      title: "Evento 1",
      sitio: "Sevilla",
      categoria: "Gaming",
      capacity: 100,
    ),
    Event(
      id: "2",
      title: "Evento 2",
      sitio: "Sevilla",
      categoria: "Deporte",
      capacity: 80,
    ),
    Event(
      id: "3",
      title: "Evento 3",
      sitio: "Sevilla",
      categoria: "Gaming",
      capacity: 120,
    ),
  ];

  Future<void> _deleteEvent(BuildContext context, String eventId) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    try {
      await apiService.deleteEvent(eventId);
      setState(() {
        events.removeWhere((e) => e.id == eventId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Evento eliminado correctamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar el evento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final List<Event> filteredEvents = events.where((event) {
      final matchCategoria = widget.filterCategoria == "Todos" || event.categoria == widget.filterCategoria;
      final matchSitio = widget.filterSitio == "Todos" || event.sitio == widget.filterSitio;
      return matchCategoria && matchSitio;
    }).toList();

    return Container(
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
                DataColumn(label: Text("")),
              ],
              rows: filteredEvents.map(
                (event) => DataRow(
                  cells: [
                    DataCell(Text(event.title)),
                    DataCell(Text(event.sitio)),
                    DataCell(Text(event.categoria)),
                    DataCell(Text(event.capacity.toString())),
                    DataCell(
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await _deleteEvent(context, event.id);
                        },
                      ),
                    ),
                  ],
                ),
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class Event {
  final String id;
  final String title;
  final String sitio;
  final String categoria;
  final int capacity;

  const Event({
    required this.id,
    required this.title,
    required this.sitio,
    required this.categoria,
    required this.capacity,
  });
}
