import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../main/components/side_menu.dart';
import 'components/header.dart';
import 'components/table_events.dart';
import '../../providers/CategoryProvider.dart';

class EventManagementScreen extends StatefulWidget {
  const EventManagementScreen({Key? key}) : super(key: key);

  @override
  _EventManagementScreenState createState() => _EventManagementScreenState();
}

class _EventManagementScreenState extends State<EventManagementScreen> {
  String selectedCategoria = "Todos";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoryProvider>(context);
    final categoriaOptions = [
      "Todos",
      ...categoryProvider.categories.map((cat) => cat.title).toList()
    ];
    final categoryTitleToId = {
      for (var cat in categoryProvider.categories) cat.title: cat.id
    };

    return SafeArea(
      child: Scaffold(
        drawer: const SideMenu(),
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
                      ],
                    ),
                    const SizedBox(height: 20),
                    TableEvents(
                      filterCategoria: selectedCategoria == "Todos"
                          ? "Todos"
                          : (categoryTitleToId[selectedCategoria] ?? "Todos"),
                    ),
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
