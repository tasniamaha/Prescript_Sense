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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReminderSetupPage()),
          );
          if (result == true) _loadReminders();
        },
        child: const Icon(Icons.add),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(103, 184, 246, 1),
              Color(0xFFDDF2FF),
              Color(0xFFF8FCFF),
              Color.fromARGB(255, 166, 214, 240),
            ],
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _reminders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/image/reminder.png",
                          width: 250,
                          height: 250,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error, size: 50, color: Colors.red);
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No reminders set yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
      ),
    );
  }
}
