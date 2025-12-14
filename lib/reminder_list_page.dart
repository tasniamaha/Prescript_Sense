import 'package:flutter/material.dart';

class ReminderListPage extends StatelessWidget {
  const ReminderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reminder List'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Paracetamol - 8:00 AM'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
            ),
            ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Amoxicillin - 9:00 PM'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {},
              ),
            ),
            // Add more reminder items here
          ],
        ),
      ),
    );
  }
}
