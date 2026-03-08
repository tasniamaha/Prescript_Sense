import 'package:flutter/material.dart';
import 'reminder_service.dart';
import 'app_colors.dart'; // Ensure you import your new color palette

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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepTeal,
              onPrimary: AppColors.white,
              onSurface: AppColors.ink,
            ),
          ),
          child: child!,
        );
      },
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.deepTeal,
              onPrimary: AppColors.white,
              onSurface: AppColors.ink,
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
        SnackBar(
          content: const Text('Please enter a medicine name'),
          backgroundColor: AppColors.alertRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final sortedDays = [..._selectedDays]..sort();

      final newReminder = Reminder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        medicineName: _medicineController.text.trim(),
        hour: _selectedTime.hour,
        minute: _selectedTime.minute,
        repeatDays: List.unmodifiable(sortedDays),
        startDate: _startDate?.millisecondsSinceEpoch,
        endDate: _endDate?.millisecondsSinceEpoch,
      );

      await _reminderService.addReminder(newReminder);

      setState(() => _isLoading = false);

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: AppColors.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud,
      appBar: AppBar(
        title: const Text('Add Reminder'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.deepTeal,
        centerTitle: true,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.deepTeal,
          letterSpacing: -0.5,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.mist, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: AppColors.ink.withOpacity(0.03),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- MEDICINE NAME ---
              const Text(
                'Medicine Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _medicineController,
                style: const TextStyle(color: AppColors.ink),
                decoration: InputDecoration(
                  hintText: 'Ex: Paracetamol',
                  hintStyle: const TextStyle(color: AppColors.ash),
                  filled: true,
                  fillColor: AppColors.mist,
                  prefixIcon: const Icon(
                    Icons.medication_outlined,
                    color: AppColors.teal,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: AppColors.deepTeal,
                      width: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- TIME PICKER ---
              const Text(
                'Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        color: AppColors.teal,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Change',
                        style: TextStyle(
                          color: AppColors.deepTeal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // --- REPEAT DAYS ---
              const Text(
                'Repeat on',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 12.0,
                children: List.generate(7, (index) {
                  final dayNumber = index + 1;
                  final dayLabel = [
                    'Mon',
                    'Tue',
                    'Wed',
                    'Thu',
                    'Fri',
                    'Sat',
                    'Sun',
                  ][index];
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
                    selectedColor: AppColors.deepTeal,
                    backgroundColor: AppColors.cloud,
                    labelStyle: TextStyle(
                      color: isSelected ? AppColors.white : AppColors.slate,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected ? AppColors.deepTeal : AppColors.mist,
                      ),
                    ),
                    showCheckmark: false,
                  );
                }),
              ),

              const SizedBox(height: 32),

              // --- ACTIVE PERIOD ---
              const Text(
                'Active Period (optional)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDateRange,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mist,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        color: AppColors.teal,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _startDate == null || _endDate == null
                              ? 'No date limit set'
                              : '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}  –  ${_endDate!.day}/${_endDate!.month}/${_endDate!.year}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: _startDate == null
                                ? AppColors.slate
                                : AppColors.ink,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.edit_calendar_rounded,
                        color: AppColors.deepTeal,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // --- SAVE BUTTON ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveReminder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    backgroundColor: AppColors.deepTeal,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Set Reminder',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
