import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'dashboard_page.dart';

void main() async {
  // Ensure Flutter binding is initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check auth status before app starts
  final authService = AuthService();
  final bool isLoggedIn = await authService.isLoggedIn();

  runApp(PrescriptSenseApp(initialRoute: isLoggedIn));
}

class PrescriptSenseApp extends StatelessWidget {
  final bool initialRoute;

  const PrescriptSenseApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrescriptSense',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // ... (Keep your existing Light Theme) ...
        primaryColor: const Color(0xFF4A90E2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90E2),
          primary: const Color(0xFF4A90E2),
          secondary: const Color(0xFFA17CF5),
          tertiary: const Color(0xFF4FF1D0),
          background: const Color(0xFFF7F9FC),
          surface: const Color(0xFFE5E7EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F9FC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4A90E2),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),
      // ... (Keep your existing Dark Theme) ...
      
      themeMode: ThemeMode.light,
      
      // ROUTING LOGIC:
      // If logged in, go to Dashboard. If not, go to Landing Page.
      home: initialRoute ? const DashboardPage() : const LandingPage(),
    );
  }
}