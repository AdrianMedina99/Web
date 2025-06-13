import 'package:flutter/material.dart';
import '../../constants.dart';
import '../main/components/side_menu.dart';
import 'components/header.dart';
import 'components/table_events.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({Key? key}) : super(key: key);

  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  String selectedCategoria = "Todos";
  String selectedSitio = "Todos";

  final List<String> categoriaOptions = ["Todos", "Gaming", "Deporte"];
  final List<String> sitioOptions = ["Todos", "Sevilla"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const SideMenu(), // Para móviles
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.of(context).size.width >= 1024)
              const Expanded(child: SideMenu()),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  children: [
                    const Header(),
                    const SizedBox(height: 60),
                    // Filtros
                    Row(
                      children: [
                        const Text("Filtrar por Categoría: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedCategoria,
                          items: categoriaOptions
                              .map((categoria) => DropdownMenuItem(
                                    value: categoria,
                                    child: Text(categoria),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategoria = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 40),
                        const Text("Filtrar por Sitio: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedSitio,
                          items: sitioOptions
                              .map((sitio) => DropdownMenuItem(
                                    value: sitio,
                                    child: Text(sitio),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSitio = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Se pasa el filtro al widget RecentEvents
                    TableEvents(filterCategoria: selectedCategoria, filterSitio: selectedSitio),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
