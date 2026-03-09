import 'package:flutter/material.dart';
import 'app_colors.dart'; // Your custom palette
import 'auth_service.dart';
import 'landing_page.dart';
import 'dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  final bool isLoggedIn = await authService.isLoggedIn();

  runApp(PrescriptSenseApp(initialRoute: isLoggedIn));
}

class PrescriptSenseApp extends StatelessWidget {
  final bool initialRoute;

  const PrescriptSenseApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    // Listen to the global themeNotifier
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'PrescriptSense',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: AppColors.cloud,
            primaryColor: AppColors.deepTeal,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.deepTeal,
              foregroundColor: AppColors.white,
              elevation: 0,
            ),
            useMaterial3: true,
          ),

          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppColors.ink,
            primaryColor: AppColors.teal,
            appBarTheme: const AppBarTheme(
              backgroundColor: AppColors.ink,
              foregroundColor: AppColors.teal,
              elevation: 0,
            ),
            useMaterial3: true,
          ),

          home: initialRoute ? const DashboardPage() : const LandingPage(),
        );
      },
    );
  }
}
