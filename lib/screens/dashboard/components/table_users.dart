import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../constants.dart';
import '../../../providers/UserProvider.dart';
import '../../../api_service.dart';

class TableUsers extends StatefulWidget {
  final String filterRole;
  const TableUsers({Key? key, this.filterRole = "Todos"}) : super(key: key);

  @override
  State<TableUsers> createState() => _TableUsersState();
}

class _TableUsersState extends State<TableUsers> {
  Map<String, dynamic>? selectedUser;
  String? selectedUserType;

  final Map<String, bool> _bannedStatus = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.fetchUsers();
      await _fetchBannedStatus(userProvider);
    });
  }

  Future<void> _fetchBannedStatus(UserProvider userProvider) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final List<Map<String, dynamic>> allUsers = [
      ...userProvider.clientUsers.map((u) => {...u, 'type': 'client'}),
      ...userProvider.businessUsers.map((u) => {...u, 'type': 'business'}),
    ];

    final Map<String, bool> updatedStatus = {};

    for (final user in allUsers) {
      final id = user['id'];
      final type = user['type'];
      if (id == null) continue;
      try {
        bool banned = false;
        if (type == 'client') {
          final data = await apiService.getClientUser(id);
          banned = data['banned'] == true;
        } else {
          final data = await apiService.getBusinessUser(id);
          banned = data['banned'] == true;
        }
        updatedStatus[id] = banned;
      } catch (_) {
        updatedStatus[id] = false;
      }
    }

    setState(() {
      _bannedStatus.addAll(updatedStatus);
    });
  }

  void _selectUser(Map<String, dynamic> user, String type) {
    setState(() {
      selectedUser = user;
      selectedUserType = type;
    });
  }

  Future<void> _accionSobreUsuario(String accion) async {
    final apiService = Provider.of<ApiService>(context, listen: false);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = selectedUser;
    final userType = selectedUserType;

    if (user == null || userType == null) return;

    if (accion == "Eliminar usuario") {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("¿Estás seguro?"),
          content: Text("¿Seguro que quieres eliminar este usuario?"),
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
        try {
          if (userType == "business") {
            await apiService.deleteBusinessUser(user['id']);
          } else {
            await apiService.deleteClientUser(user['id']);
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Usuario eliminado correctamente')),
          );
          await userProvider.fetchUsers();
          await _fetchBannedStatus(userProvider);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al eliminar usuario: $e')),
          );
        }
        setState(() {
          selectedUser = null;
          selectedUserType = null;
        });
      }
    } else if (accion == "Ban permanente") {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("¿Estás seguro?"),
          content: Text("¿Seguro que quieres banear/desbanear este usuario?"),
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
        try {
          if (userType == "client") {
            await apiService.updateClientBan(user['id']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Usuario cliente baneado/desbaneado')),
            );
          } else if (userType == "business") {
            await apiService.updateBusinessBan(user['id']);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Usuario de negocio baneado/desbaneado')),
            );
          }
          await userProvider.fetchUsers();
          await _fetchBannedStatus(userProvider);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al banear usuario: $e')),
          );
        }
        setState(() {
          selectedUser = null;
          selectedUserType = null;
        });
      }
    }
  }

  Widget buildTable({
    required List<Map<String, dynamic>> users,
    required bool isClient,
  }) {
    final totalQuedadas = users.fold<double>(0, (s, u) => s + ((u['quedadasCreadas'] ?? 0) as num).toDouble());
    return Container(
      margin: EdgeInsets.only(bottom: 32),
      width: MediaQuery.of(context).size.width * 0.8,
      padding: EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: secondaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isClient ? "Clientes" : "Negocios",
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: [
                DataColumn(label: Text("ID")),
                DataColumn(label: Text("Nombre")),
                if (isClient) DataColumn(label: Text("Apellido")),
                DataColumn(label: Text("Valoración")),
                if (isClient) DataColumn(label: Text("Quedadas Creadas")),
              ],
              rows: [
                ...users.map(
                      (user) {
                    final banned = _bannedStatus[user['id']] == true;
                    return DataRow(
                      selected: selectedUser?['id'] == user['id'],
                      onSelectChanged: (_) => _selectUser(user, isClient ? "client" : "business"),
                      cells: [
                        DataCell(Text(user['id']?.toString() ?? '')),
                        DataCell(
                          Row(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 15,
                                    backgroundImage: user['photo'] != null && user['photo'] != ""
                                        ? NetworkImage(user['photo'])
                                        : AssetImage("assets/images/profile_pic.png") as ImageProvider,
                                  ),
                                  if (banned)
                                    Positioned(
                                      right: -2,
                                      top: -2,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              SizedBox(width: defaultPadding / 2),
                              Text(user['nombre'] ?? ''),
                            ],
                          ),
                        ),
                        if (isClient) DataCell(Text(user['apellidos'] ?? '')),
                        DataCell(Text((user['valoracion'] as double).toStringAsFixed(1))),
                        if (isClient) DataCell(Text((user['quedadasCreadas'] ?? 0).toString())),
                      ],
                    );
                  },
                ),
                DataRow(
                  cells: [
                    DataCell(Container()),
                    DataCell(Text("Total", style: TextStyle(fontWeight: FontWeight.bold))),
                    if (isClient) DataCell(Container()),
                    DataCell(Container()),
                    if (isClient)
                      DataCell(Text(totalQuedadas.toStringAsFixed(1), style: TextStyle(fontWeight: FontWeight.bold))),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.loading) {
      return Center(child: CircularProgressIndicator());
    }
    List<Map<String, dynamic>> filteredClients = userProvider.clientUsers;
    List<Map<String, dynamic>> filteredBusiness = userProvider.businessUsers;
    if (widget.filterRole != "Todos") {
      filteredClients = filteredClients.where((u) => u['role'] == widget.filterRole).toList();
      filteredBusiness = filteredBusiness.where((u) => u['role'] == widget.filterRole).toList();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildTable(users: filteredClients, isClient: true),
        buildTable(users: filteredBusiness, isClient: false),
        if (selectedUser != null) ...[
          SizedBox(height: 32),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.4,
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
                    backgroundImage: selectedUser?['photo'] != null && selectedUser?['photo'] != ""
                        ? NetworkImage(selectedUser?['photo'])
                        : AssetImage("assets/images/profile_pic.png") as ImageProvider,
                  ),
                  SizedBox(height: 16),
                  Text(
                    selectedUserType == "client"
                        ? "${selectedUser!['nombre']} ${selectedUser!['apellidos'] ?? ''}"
                        : "${selectedUser!['nombre']}",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
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
                          selectedUserType = null;
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

