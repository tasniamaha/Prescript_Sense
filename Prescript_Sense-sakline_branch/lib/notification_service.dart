import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'database_helper.dart';

/// Robust notification service for medicine reminders
/// Handles scheduling, rescheduling, and cleanup of expired notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _isSupported = false;

  /// Notification channel details
  static const String _channelId = 'medicine_reminders';
  static const String _channelName = 'Medicine Reminders';
  static const String _channelDescription = 'Daily reminders for your medications';

  /// Base notification ID offset to avoid conflicts
  /// Each medicine gets IDs: baseId + (medicineId * 100) + timeIndex
  static const int _notificationIdBase = 10000;

  /// Check if notifications are supported on current platform
  bool get isSupported => _isSupported;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Check if platform supports local notifications
    if (kIsWeb) {
      debugPrint('NotificationService: Web platform - notifications not supported');
      _isInitialized = true;
      _isSupported = false;
      return;
    }

    try {
      // Only support Android and iOS
      if (!Platform.isAndroid && !Platform.isIOS) {
        debugPrint('NotificationService: Platform not supported for notifications');
        _isInitialized = true;
        _isSupported = false;
        return;
      }

      _isSupported = true;

      // Initialize timezone database
      tz_data.initializeTimeZones();

      // Set local timezone
      try {
        final String timeZoneName = await _getLocalTimezoneName();
        tz.setLocalLocation(tz.getLocation(timeZoneName));
      } catch (e) {
        debugPrint('NotificationService: Failed to set timezone, using UTC: $e');
        tz.setLocalLocation(tz.UTC);
      }

      // Android initialization settings
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Initialize
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
        onDidReceiveBackgroundNotificationResponse: _onBackgroundNotificationResponse,
      );

      _isInitialized = true;
      debugPrint('NotificationService: Initialized successfully');
    } catch (e) {
      debugPrint('NotificationService: Initialization failed: $e');
      _isInitialized = true;
      _isSupported = false;
    }
  }

  /// Get local timezone name based on platform
  Future<String> _getLocalTimezoneName() async {
    // Default fallback
    String timeZoneName = 'Asia/Dhaka'; // Default for Bangladesh

    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // On mobile, we can use a reasonable default or system time
        final now = DateTime.now();
        final offset = now.timeZoneOffset;
        
        // Map offset to common timezone
        if (offset.inHours == 6) {
          timeZoneName = 'Asia/Dhaka';
        } else if (offset.inHours == 5 && offset.inMinutes == 30) {
          timeZoneName = 'Asia/Kolkata';
        } else if (offset.inHours == 0) {
          timeZoneName = 'UTC';
        } else if (offset.inHours == -5) {
          timeZoneName = 'America/New_York';
        } else if (offset.inHours == -8) {
          timeZoneName = 'America/Los_Angeles';
        }
      }
    } catch (e) {
      debugPrint('NotificationService: Error getting timezone: $e');
    }

    return timeZoneName;
  }

  /// Handle notification tap (foreground)
  static void _onNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Notification tapped: ${response.payload}');
    // Can navigate to specific screen based on payload
  }

  /// Handle notification tap (background)
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    debugPrint('NotificationService: Background notification: ${response.payload}');
  }

  /// Request necessary permissions
  Future<bool> requestPermissions() async {
    if (!_isSupported || kIsWeb) return true;
    
    bool granted = true;

    try {
      if (Platform.isAndroid) {
        // Request Android 13+ notification permission
        final androidPlugin = _notifications
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
        if (androidPlugin != null) {
          // Request notification permission
          final notificationPermission = await androidPlugin.requestNotificationsPermission();
          granted = notificationPermission ?? false;

          // Request exact alarm permission for Android 12+
          final exactAlarmPermission = await androidPlugin.requestExactAlarmsPermission();
          granted = granted && (exactAlarmPermission ?? false);
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _notifications
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
        
        if (iosPlugin != null) {
          final result = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          granted = result ?? false;
      }
    }
    } catch (e) {
      debugPrint('NotificationService: Error requesting permissions: $e');
      return false;
    }

    return granted;
  }

  /// Generate unique notification ID for a medicine time slot
  /// Formula: baseId + (medicineId * 100) + timeIndex
  /// This allows up to 100 time slots per medicine
  int _generateNotificationId(int medicineId, int timeIndex) {
    return _notificationIdBase + (medicineId * 100) + timeIndex;
  }

  /// Schedule all notifications for a medicine
  Future<void> scheduleMedicineNotifications(ScheduledMedicine medicine) async {
    if (!_isSupported) return;
    if (!_isInitialized) await initialize();
    if (medicine.id == null) return;

    // First, cancel any existing notifications for this medicine
    await cancelMedicineNotifications(medicine.id!);

    // Don't schedule if medicine is inactive
    if (medicine.isActive != 1) return;

    // Don't schedule if already expired
    final endDate = DateTime.parse(medicine.endDate);
    if (endDate.isBefore(DateTime.now())) {
      debugPrint('NotificationService: Medicine ${medicine.name} already expired');
      return;
    }

    // Schedule a notification for each time slot
    for (int i = 0; i < medicine.doseTimes.length; i++) {
      final timeStr = medicine.doseTimes[i];
      final notificationId = _generateNotificationId(medicine.id!, i);

      await _scheduleRepeatingNotification(
        id: notificationId,
        title: 'Medicine Reminder 💊',
        body: 'Time to take ${medicine.name}',
        time: timeStr,
        payload: 'medicine_${medicine.id}_time_$i',
      );

      debugPrint('NotificationService: Scheduled notification $notificationId for ${medicine.name} at $timeStr');
    }
  }

  /// Schedule a repeating daily notification at a specific time
  Future<void> _scheduleRepeatingNotification({
    required int id,
    required String title,
    required String body,
    required String time, // Format: "HH:mm"
    String? payload,
  }) async {
    // Parse time
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    // Create scheduled time
    final now = tz.TZDateTime.now(tz.local);
    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Notification details
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule with daily repeat
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at this time
      payload: payload,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Cancel all notifications for a specific medicine
  Future<void> cancelMedicineNotifications(int medicineId) async {
    if (!_isSupported) return;
    // Cancel up to 100 possible time slots
    for (int i = 0; i < 100; i++) {
      final notificationId = _generateNotificationId(medicineId, i);
      await _notifications.cancel(notificationId);
    }
    debugPrint('NotificationService: Cancelled all notifications for medicine $medicineId');
  }

  /// Cancel a specific notification
  Future<void> cancelNotification(int notificationId) async {
    if (!_isSupported) return;
    await _notifications.cancel(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    if (!_isSupported) return;
    await _notifications.cancelAll();
    debugPrint('NotificationService: Cancelled all notifications');
  }

  /// Check and deactivate expired medicines
  /// This should be called on app startup
  Future<void> checkExpiredMedicines() async {
    if (!_isInitialized) await initialize();

    final dbHelper = DatabaseHelper();
    final expiredMedicines = await dbHelper.getExpiredMedicines();

    for (final medicine in expiredMedicines) {
      if (medicine.id != null) {
        // Cancel notifications
        await cancelMedicineNotifications(medicine.id!);
        
        // Deactivate in database
        await dbHelper.deactivateMedicine(medicine.id!);
        
        debugPrint('NotificationService: Deactivated expired medicine: ${medicine.name}');
      }
    }

    if (expiredMedicines.isNotEmpty) {
      debugPrint('NotificationService: Cleaned up ${expiredMedicines.length} expired medicines');
    }
  }

  /// Reschedule all active medicine notifications
  /// Call this after device reboot or app reinstall
  Future<void> rescheduleAllNotifications() async {
    if (!_isInitialized) await initialize();

    // First, cleanup expired medicines
    await checkExpiredMedicines();

    // Get all active medicines
    final dbHelper = DatabaseHelper();
    final activeMedicines = await dbHelper.getActiveScheduledMedicines();

    // Cancel all existing notifications first
    await cancelAllNotifications();

    // Reschedule each active medicine
    for (final medicine in activeMedicines) {
      await scheduleMedicineNotifications(medicine);
    }

    debugPrint('NotificationService: Rescheduled ${activeMedicines.length} medicine notifications');
  }

  /// Update notifications when a medicine is edited
  /// This handles the edge case of time changes
  Future<void> updateMedicineNotifications(ScheduledMedicine medicine) async {
    if (!_isSupported) return;
    if (medicine.id == null) return;

    // Cancel old notifications
    await cancelMedicineNotifications(medicine.id!);

    // Schedule new notifications with updated times
    await scheduleMedicineNotifications(medicine);

    debugPrint('NotificationService: Updated notifications for ${medicine.name}');
  }

  /// Show an immediate test notification
  Future<void> showTestNotification() async {
    if (!_isSupported) return;
    if (!_isInitialized) await initialize();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      'Test Notification',
      'Medicine reminder system is working! 💊',
      notificationDetails,
    );
  }

  /// Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
