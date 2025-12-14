import 'package:flutter/material.dart';

class ReminderSetupPage extends StatelessWidget {
  const ReminderSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Up Reminder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.alarm_add, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'Set up your medicine reminders here',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for adding reminder
              },
              child: const Text('Add Reminder'),
            ),
          ],
        ),
      ),
    );
  }
}
