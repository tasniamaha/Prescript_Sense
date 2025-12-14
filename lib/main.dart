import 'package:flutter/material.dart';
//import 'package:prescript_sense/backend_test_page.dart';
import 'landing_page.dart';

void main() {
  runApp(const PrescriptSenseApp());
}

class PrescriptSenseApp extends StatelessWidget {
  const PrescriptSenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PrescriptSense',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
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
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A1A2F),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A1A2F),
          foregroundColor: Colors.white,
        ),
        useMaterial3: true,
      ),

      themeMode: ThemeMode.light,
      home: const LandingPage(),
    );
  }
}
