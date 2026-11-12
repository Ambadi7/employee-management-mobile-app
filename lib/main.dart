import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  final role = prefs.getString(AppConstants.keyEmployeeRole) ?? '';

  String initialRoute;
  if (isLoggedIn) {
    initialRoute = role == 'admin' ? AppRoutes.adminDashboard : AppRoutes.home;
  } else {
    initialRoute = AppRoutes.login;
  }

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;
  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
    );
  }
}
