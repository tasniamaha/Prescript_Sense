import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'auth_service.dart';
import 'landing_page.dart';
import 'dashboard_page.dart';
import 'notification_service.dart';



void main() async {
  // Ensure Flutter binding is initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the medicine notification service
  final notificationService = NotificationService();
  await notificationService.initialize();
  
  // Request notification permissions
  await notificationService.requestPermissions();
  
  // Cleanup expired medicines and reschedule active ones
  await notificationService.checkExpiredMedicines();
  
  // Check auth status before app starts
  final authService = AuthService();
  final bool isLoggedIn = await authService.isLoggedIn();
  await AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
    null,
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'medication_channel', // We will use this key later
        channelName: 'Medication Reminders',
        channelDescription: 'Daily reminders for medication',
        defaultColor: const Color(0xFF1E3A8A),
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        playSound: true,
      )
    ],
    // Debug mode helps you see logs if something fails
    debug: true,
  );

  // 2. Request Permission immediately (for simplicity)
  bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowed) {
    await AwesomeNotifications().requestPermissionToSendNotifications();
  }

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

