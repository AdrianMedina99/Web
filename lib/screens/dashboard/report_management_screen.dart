import 'package:flutter/material.dart';
import '../../constants.dart';
import '../main/components/side_menu.dart';
import 'components/header.dart';
import 'components/table_reports.dart';

class ReportManagementScreen extends StatelessWidget {
  const ReportManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  children: const [
                    Header(),
                    SizedBox(height: 60),
                    TableReports(),
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
