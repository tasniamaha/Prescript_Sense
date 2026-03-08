import 'package:flutter/material.dart';
import 'reminder_service.dart';
import 'reminder_setup_page.dart';
import 'app_colors.dart'; // Ensure you import your new color palette

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
    if (mounted) {
      setState(() {
        _reminders = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteReminder(String id) async {
    await _reminderService.deleteReminder(id);
    _loadReminders(); // Refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cloud, // Minimal background
      appBar: AppBar(
        title: const Text('My Reminders'),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ReminderSetupPage()),
          );
          if (result == true) _loadReminders();
        },
        backgroundColor: AppColors.deepTeal,
        foregroundColor: AppColors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.deepTeal),
            )
          : _reminders.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                final reminder = _reminders[index];
                return _buildReminderCard(reminder);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_add_rounded,
              size: 56,
              color: AppColors.teal,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No reminders set yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.ink,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Tap the + button to create a new routine.',
            style: TextStyle(fontSize: 16, color: AppColors.slate),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(Reminder reminder) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mist, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.alarm_rounded,
                color: AppColors.teal,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.medicineName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "${reminder.formattedTime}  •  ${reminder.formattedDays}",
                    style: const TextStyle(
                      color: AppColors.deepTeal,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  if (reminder.formattedPeriod != 'No date limit') ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.date_range_rounded,
                          size: 14,
                          color: AppColors.ash,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            reminder.formattedPeriod,
                            style: const TextStyle(
                              color: AppColors.slate,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Delete Action
            IconButton(
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.alertRed,
                size: 24,
              ),
              onPressed: () => _deleteReminder(reminder.id),
              tooltip: "Delete Reminder",
              style: IconButton.styleFrom(backgroundColor: AppColors.softRed),
            ),
          ],
        ),
      ),
    );
  }
}
