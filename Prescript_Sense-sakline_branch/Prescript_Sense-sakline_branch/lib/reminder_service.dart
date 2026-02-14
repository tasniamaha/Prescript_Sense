import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// 1. The Data Model
class Reminder {
  final String id;
  final String medicineName;
  final int hour;
  final int minute;

  Reminder({
    required this.id,
    required this.medicineName,
    required this.hour,
    required this.minute,
  });

  // Convert object to JSON map for storage
  Map<String, dynamic> toJson() => {
    'id': id,
    'medicineName': medicineName,
    'hour': hour,
    'minute': minute,
  };

  // Create object from JSON map
  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'],
    medicineName: json['medicineName'],
    hour: json['hour'],
    minute: json['minute'],
  );

  // Helper to format time nicely (e.g., "8:05 AM")
  String get formattedTime {
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
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
    return decoded.map((item) => Reminder.fromJson(item)).toList();
  }

  // Add a new reminder
  Future<void> addReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Reminder> currentList = await getReminders();

    currentList.add(reminder);

    // Save back to storage
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
