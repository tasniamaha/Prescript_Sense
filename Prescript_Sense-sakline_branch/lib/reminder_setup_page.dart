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

  // Weekday selection (1 = Monday ... 7 = Sunday)
  final List<int> _selectedDays = [];

  // Date range
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

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

  Future<void> _pickDateRange() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = DateTime(now.year - 1);
    final DateTime lastDate = DateTime(now.year + 10);

    final DateTimeRange? range = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      currentDate: now,
      helpText: 'Select reminder active period',
      confirmText: 'Confirm',
      cancelText: 'Clear',
      fieldStartHintText: 'Start date',
      fieldEndHintText: 'End date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        _startDate = range.start;
        _endDate = range.end;
      });
    } else {
      setState(() {
        _startDate = null;
        _endDate = null;
      });
    }
  }

  Future<void> _saveReminder() async {
    if (_medicineController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("[SAVE] Starting save process...");

      // ────────────────────────────────────────────────
      // Fixed: sort BEFORE making the list unmodifiable
      final sortedDays = [..._selectedDays]..sort();
      // ────────────────────────────────────────────────

      final newReminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        medicineName: _medicineController.text.trim(),
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        repeatDays: List.unmodifiable(sortedDays),
        startDate: _startDate?.millisecondsSinceEpoch,
        endDate: _endDate?.millisecondsSinceEpoch,
      );

      print("[SAVE] Reminder object created → ID: ${newReminder.id}");

      print("[SAVE] Calling addReminder...");
      await _reminderService.addReminder(newReminder);
      print("[SAVE] addReminder completed successfully");

      setState(() => _isLoading = false);

      if (mounted) {
        print("[SAVE] Navigating back with success");
        Navigator.pop(context, true);
      }
    } catch (e, stack) {
      print("[SAVE ERROR] Failed to save reminder");
      print("Error: $e");
      print("Stack trace:\n$stack");

      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Reminder')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine Name
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

              const SizedBox(height: 32),

              // Time
              const Text(
                'Time',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
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

              const SizedBox(height: 32),

              // Repeat on
              const Text(
                'Repeat on',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index];
                  final isSelected = _selectedDays.contains(dayNumber);

                  return ChoiceChip(
                    label: Text(dayLabel),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedDays.add(dayNumber);
                        } else {
                          _selectedDays.remove(dayNumber);
                        }
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    backgroundColor: Colors.grey.shade200,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue.shade900 : Colors.black87,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 32),

              // Active Period
              const Text(
                'Active Period (optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _startDate == null || _endDate == null
                              ? 'No date limit set (tap to select period)'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}  –  ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          style: TextStyle(
                            fontSize: 16,
                            color: _startDate == null ? Colors.grey[700] : Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.blue),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveReminder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Set Reminder', style: TextStyle(fontSize: 18)),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
