import 'package:flutter/material.dart';
import 'reminder_service.dart';

class ReminderSetupPage extends StatefulWidget {
  const ReminderSetupPage({super.key});

  @override
  State<ReminderSetupPage> createState() => _ReminderSetupPageState();
}

class _ReminderSetupPageState extends State<ReminderSetupPage> {
  final TextEditingController _medicineController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();
  final ReminderService _reminderService = ReminderService();
  bool _isLoading = false;

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  // Function to show the Time Picker
  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Function to Save
  Future<void> _saveReminder() async {
    if (_medicineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Create the object
    final newReminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Unique ID
      medicineName: _medicineController.text.trim(),
      hour: _selectedTime.hour,
      minute: _selectedTime.minute,
    );

    // Save to storage
    await _reminderService.addReminder(newReminder);

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pop(context, true); // Return 'true' to indicate success
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Medicine Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _medicineController,
              decoration: InputDecoration(
                hintText: 'Ex: Paracetamol',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.medication),
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Time Picker Card
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.blue),
                    const SizedBox(width: 12),
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(fontSize: 18),
                    ),
                    const Spacer(),
                    const Text('Change', style: TextStyle(color: Colors.blue)),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveReminder,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Set Reminder', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}