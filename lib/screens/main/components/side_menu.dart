import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../screens/dashboard/user_management_screen.dart';
import '../../../screens/dashboard/event_management_screen.dart';
import '../../../screens/dashboard/category_management_screen.dart';
import '../../../screens/dashboard/report_management_screen.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            child: Image.asset("assets/images/kompaLogo.png"),
          ),
          DrawerListTile(
            title: "Gestion de Usuarios",
            svgSrc: "assets/icons/menu_profile.svg",
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserManagementScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Gestion de Eventos",
            svgSrc: "assets/icons/menu_tran.svg",
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const EventManagementScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Gestion de Reportes",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ReportManagementScreen()),
              );
            },
          ),
          DrawerListTile(
            title: "Gestion de Categorias",
            svgSrc: "assets/icons/menu_doc.svg",
            press: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const CategoryManagementScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    // For selecting those three line once press "Command+D"
    required this.title,
    required this.svgSrc,
    required this.press,
  }) : super(key: key);

  final String title, svgSrc;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: press,
      horizontalTitleGap: 0.0,
      leading: SvgPicture.asset(
        svgSrc,
        colorFilter: ColorFilter.mode(Colors.white54, BlendMode.srcIn),
        height: 16,
      ),
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}

