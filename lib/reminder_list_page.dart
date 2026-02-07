import 'package:flutter/material.dart';
import 'reminder_service.dart';
import 'reminder_setup_page.dart';

class ReminderListPage extends StatefulWidget {
  const ReminderListPage({super.key});

  @override
  State<ReminderListPage> createState() => _ReminderListPageState();
}

class _ReminderListPageState extends State<ReminderListPage> {
  final ReminderService _reminderService = ReminderService();
  List<Reminder> _reminders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    final list = await _reminderService.getReminders();
    setState(() {
      _reminders = list;
      _isLoading = false;
    });
  }

  Future<void> _deleteReminder(String id) async {
    await _reminderService.deleteReminder(id);
    _loadReminders(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Reminders')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Wait for the result from Setup Page
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReminderSetupPage()),
          );

          // If true (saved successfully), refresh the list
          if (result == true) {
            _loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reminders.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_off, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text('No reminders set yet'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.1),
                      child: const Icon(Icons.alarm, color: Colors.blue),
                    ),
                    title: Text(
                      reminder.medicineName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(reminder.formattedTime),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _deleteReminder(reminder.id),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
