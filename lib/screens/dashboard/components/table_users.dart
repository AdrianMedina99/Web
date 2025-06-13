// ...existing imports...
import 'package:flutter/material.dart';
import '../../../constants.dart';

class TableUsers extends StatefulWidget {
  final String filterRole;
  const TableUsers({Key? key, this.filterRole = "Todos"}) : super(key: key);

  @override
  State<TableUsers> createState() => _TableUsersState();
}

class _TableUsersState extends State<TableUsers> {
  final List<User> demoRecentUsers = const [
    User(
      nombre: "Juan",
      apellido: "Pérez",
      email: "juan@example.com",
      role: "CLIENT",
      followers: "150",
      valoracion: 4.3,
      eventosCreados: 5,
      quedadasCreadas: 2,
    ),
    User(
      nombre: "María",
      apellido: "Gómez",
      email: "maria@example.com",
      role: "BUSSINES",
      followers: "212",
      valoracion: 3.8,
      eventosCreados: 8,
      quedadasCreadas: 5,
    ),
    User(
      nombre: "Luis",
      apellido: "Martínez",
      email: "luis@example.com",
      role: "ADMIN",
      followers: "300",
      valoracion: 4.7,
      eventosCreados: 10,
      quedadasCreadas: 7,
    ),
  ];

  User? selectedUser;

  void _selectUser(User user) {
    setState(() {
      selectedUser = user;
    });
  }

  void _accionSobreUsuario(String accion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Acción "$accion" realizada sobre ${selectedUser?.nombre ?? ""}')),
    );
    setState(() {
      selectedUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<User> filteredUsers = widget.filterRole == "Todos"
        ? demoRecentUsers
        : demoRecentUsers.where((user) => user.role == widget.filterRole).toList();
    final totalEvents = filteredUsers.fold(0, (s, u) => s + u.eventosCreados);
    final totalQuedadas = filteredUsers.fold(0, (s, u) => s + u.quedadasCreadas);
    final double screenWidth = MediaQuery.of(context).size.width;

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
                "Lista de Usuarios",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                width: double.infinity,
                child: DataTable(
                  columnSpacing: defaultPadding,
                  columns: const [
                    DataColumn(label: Text("Nombre")),
                    DataColumn(label: Text("Apellido")),
                    DataColumn(label: Text("Email")),
                    DataColumn(label: Text("Rol")),
                    DataColumn(label: Text("Seguidores")),
                    DataColumn(label: Text("Valoración")),
                    DataColumn(label: Text("Eventos Creados")),
                    DataColumn(label: Text("Quedadas Creadas")),
                  ],
                  rows: [
                    ...filteredUsers.map(
                      (user) => DataRow(
                        selected: selectedUser?.email == user.email,
                        onSelectChanged: (_) => _selectUser(user),
                        cells: [
                          DataCell(
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundImage: AssetImage("assets/images/profile_pic.png"),
                                ),
                                SizedBox(width: defaultPadding / 2),
                                Text(user.nombre),
                              ],
                            ),
                          ),
                          DataCell(Text(user.apellido)),
                          DataCell(Text(user.email)),
                          DataCell(Text(user.role)),
                          DataCell(Text(user.followers)),
                          DataCell(Text(user.valoracion.toStringAsFixed(1))),
                          DataCell(Text(user.eventosCreados.toString())),
                          DataCell(Text(user.quedadasCreadas.toString())),
                        ],
                      ),
                    ),
                    DataRow(
                      cells: [
                        DataCell(Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(Container()),
                        DataCell(Text(totalEvents.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(totalQuedadas.toString(), style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        if (selectedUser != null) ...[
          SizedBox(height: 32),
          Center(
            child: Container(
              width: screenWidth * 0.4,
              padding: EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: secondaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueGrey.shade100),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("assets/images/profile_pic.png"),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "${selectedUser!.nombre} ${selectedUser!.apellido}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _accionSobreUsuario("Ban temporal"),
                        icon: Icon(Icons.timer, color: Colors.orange),
                        label: Text("Ban temporal"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade100,
                          foregroundColor: Colors.orange.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _accionSobreUsuario("Ban permanente"),
                        icon: Icon(Icons.block, color: Colors.red),
                        label: Text("Ban permanente"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade100,
                          foregroundColor: Colors.red.shade900,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _accionSobreUsuario("Eliminar usuario"),
                        icon: Icon(Icons.delete, color: Colors.red),
                        label: Text("Eliminar usuario"),
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
                          selectedUser = null;
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

class User {
  final String nombre;
  final String apellido;
  final String email;
  final String role;
  final String followers;
  final double valoracion;
  final int eventosCreados;
  final int quedadasCreadas;

  const User({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.role,
    required this.followers,
    required this.valoracion,
    required this.eventosCreados,
    required this.quedadasCreadas,
  });
}

