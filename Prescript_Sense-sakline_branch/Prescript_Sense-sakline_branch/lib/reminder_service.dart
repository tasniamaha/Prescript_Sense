import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 1. The Data Model
class Reminder {
  final String id;
  final String medicineName;
  final int hour;
  final int minute;
  final List<int> repeatDays; // 1 = Monday, 2 = Tuesday, ..., 7 = Sunday. Empty = one-time only
  final int? startDate;       // millisecondsSinceEpoch (optional)
  final int? endDate;         // millisecondsSinceEpoch (optional)

  Reminder({
    required this.id,
    required this.medicineName,
    required this.hour,
    required this.minute,
    this.repeatDays = const [],
    this.startDate,
    this.endDate,
  });

  // Convert object to JSON map for storage
  Map<String, dynamic> toJson() => {
        'id': id,
        'medicineName': medicineName,
        'hour': hour,
        'minute': minute,
        'repeatDays': repeatDays,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
      };

  // Create object from JSON map
  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
        id: json['id'] as String,
        medicineName: json['medicineName'] as String,
        hour: json['hour'] as int,
        minute: json['minute'] as int,
        repeatDays: (json['repeatDays'] as List<dynamic>?)?.cast<int>() ?? [],
        startDate: json['startDate'] as int?,
        endDate: json['endDate'] as int?,
      );

  // Helper to format time nicely (e.g., "8:05 AM")
  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }

  // Nice formatting for repeat days
  String get formattedDays {
    if (repeatDays.isEmpty) return 'Once only';
    if (repeatDays.length == 7) return 'Every day';

    const dayNames = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final names = repeatDays.map((d) => dayNames[d]).where((n) => n.isNotEmpty).toList();

    return names.isEmpty ? 'Once only' : names.join(', ');
  }

  // New: Formatting for the active date period
  String get formattedPeriod {
    if (startDate == null && endDate == null) {
      return 'No date limit';
    }

    String result = '';

    if (startDate != null) {
      final start = DateTime.fromMillisecondsSinceEpoch(startDate!);
      result += 'From ${start.day} ${_shortMonth(start.month)} ${start.year}';
    }

    if (endDate != null) {
      final end = DateTime.fromMillisecondsSinceEpoch(endDate!);
      if (result.isNotEmpty) {
        result += '  •  ';
      }
      result += 'Until ${end.day} ${_shortMonth(end.month)} ${end.year}';
    }

    return result.isEmpty ? 'No date limit' : result;
  }

  String _shortMonth(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}

// 2. The Service (The Vault)
class ReminderService {
  static const String _storageKey = 'saved_reminders';

  // Get all reminders
  Future<List<Reminder>> getReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data == null) return [];

    final List<dynamic> decoded = jsonDecode(data);
    return decoded.map((item) => Reminder.fromJson(item as Map<String, dynamic>)).toList();
  }

  // Add a new reminder
  Future<void> addReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Reminder> currentList = await getReminders();

    currentList.add(reminder);

    final String encoded = jsonEncode(
      currentList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }

  // Delete a reminder
  Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Reminder> currentList = await getReminders();

    currentList.removeWhere((item) => item.id == id);

    final String encoded = jsonEncode(
      currentList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encoded);
  }
}
