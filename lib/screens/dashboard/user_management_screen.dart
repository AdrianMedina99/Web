import 'package:flutter/material.dart';
import '../../constants.dart';
import '../main/components/side_menu.dart';
import 'components/header.dart';
import 'components/table_users.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String selectedRole = "Todos";
  // Opciones de roles para el filtro
  final List<String> roleOptions = ["Todos", "CLIENT", "BUSSINES", "ADMIN"];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: const SideMenu(), // Para móviles
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (MediaQuery.of(context).size.width >= 1024)
              const Expanded(
                child: SideMenu(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Header(),
                    const SizedBox(height: 60),
                    // Filtro por role
                    Row(
                      children: [
                        const Text("Filtrar por Rol: "),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: selectedRole,
                          items: roleOptions
                              .map((role) => DropdownMenuItem(
                                    value: role,
                                    child: Text(role),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Pasar el filtro al widget RecentUsers
                    TableUsers(filterRole: selectedRole),
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
