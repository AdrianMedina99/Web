import 'package:admin/constants.dart';
import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/providers/AuthProvider.dart';
import 'package:admin/providers/EventProvider.dart';
import 'package:admin/screens/login/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'api_service.dart';
import 'providers/CategoryProvider.dart';
import 'providers/UserProvider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String apiBaseUrl = 'https://apirestfullkompa.up.railway.app';

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(baseUrl: apiBaseUrl);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => MenuAppController(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => EventProvider(apiService: apiService),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(apiService: apiService),
        ),
        Provider<ApiService>.value(
          value: apiService,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kompa Admin Panel',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor,
        ),
        home: LoginScreen(),
      ),
    );
  }
}
