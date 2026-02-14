import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';
import 'notification_service.dart';

// ============================================================
// COLOR PALETTE - Matching app theme
// ============================================================
const Color _deepIndigo = Color(0xFF1E3A8A);
const Color _softBlue = Color(0xFF3B82F6);
const Color _emerald = Color(0xFF10B981);
const Color _lightBackground = Color(0xFFF8FAFF);
const Color _cardBackground = Colors.white;
const Color _textPrimary = Color(0xFF1E293B);
const Color _textSecondary = Color(0xFF64748B);
const Color _warningOrange = Color(0xFFF59E0B);
const Color _errorRed = Color(0xFFEF4444);

class MedicineCalendarPage extends StatefulWidget {
  const MedicineCalendarPage({super.key});

  @override
  State<MedicineCalendarPage> createState() => _MedicineCalendarPageState();
}

class _MedicineCalendarPageState extends State<MedicineCalendarPage> {
  // Calendar state
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  
  // Data
  final DatabaseHelper _dbHelper = DatabaseHelper();
  Map<DateTime, List<ScheduledMedicine>> _events = {};
  List<DoseSlot> _selectedDayDoses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // Load events for the current visible month
    await _loadEventsForMonth(_focusedDay);
    
    // Load doses for selected day
    await _loadDosesForSelectedDay();
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadEventsForMonth(DateTime month) async {
    final firstDay = DateTime(month.year, month.month - 1, 1);
    final lastDay = DateTime(month.year, month.month + 2, 0);
    
    _events = await _dbHelper.getMedicinesForDateRange(firstDay, lastDay);
  }

  Future<void> _loadDosesForSelectedDay() async {
    _selectedDayDoses = await _dbHelper.getDoseSlotsForDate(_selectedDay);
  }

  List<ScheduledMedicine> _getEventsForDay(DateTime day) {
    final normalizedDay = DateTime(day.year, day.month, day.day);
    return _events[normalizedDay] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });
    _loadDosesForSelectedDay().then((_) => setState(() {}));
  }

  void _onPageChanged(DateTime focusedDay) {
    _focusedDay = focusedDay;
    _loadEventsForMonth(focusedDay).then((_) => setState(() {}));
  }

  Future<void> _markDoseTaken(DoseSlot slot) async {
    if (slot.medicine.id == null) return;
    
    final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDay);
    
    if (slot.isTaken) {
      // If already taken, unmark it
      await _dbHelper.unmarkDose(slot.medicine.id!, dateStr, slot.time);
    } else {
      // Mark as taken
      await _dbHelper.markDoseTaken(slot.medicine.id!, dateStr, slot.time);
    }
    
    // Reload doses
    await _loadDosesForSelectedDay();
    setState(() {});
    
    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            slot.isTaken 
                ? '${slot.medicine.name} unmarked' 
                : '${slot.medicine.name} marked as taken ✓',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: slot.isTaken ? _textSecondary : _emerald,
        ),
      );
    }
  }

  void _navigateToAddMedicine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(
          initialDate: _selectedDay,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  void _showMedicineDetails(ScheduledMedicine medicine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MedicineDetailsSheet(
        medicine: medicine,
        onEdit: () {
          Navigator.pop(context);
          _navigateToEditMedicine(medicine);
        },
        onDelete: () async {
          Navigator.pop(context);
          await _deleteMedicine(medicine);
        },
      ),
    );
  }

  void _navigateToEditMedicine(ScheduledMedicine medicine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedicinePage(
          initialDate: _selectedDay,
          medicineToEdit: medicine,
        ),
      ),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  Future<void> _deleteMedicine(ScheduledMedicine medicine) async {
    if (medicine.id == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Medicine'),
        content: Text('Are you sure you want to delete ${medicine.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: _errorRed),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Cancel notifications
      await NotificationService().cancelMedicineNotifications(medicine.id!);
      
      // Delete from database
      await _dbHelper.deleteScheduledMedicine(medicine.id!);
      
      // Reload data
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${medicine.name} deleted'),
            backgroundColor: _errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _deepIndigo),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Medicine Calendar',
          style: TextStyle(
            color: _deepIndigo,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: _softBlue),
            onPressed: () {
              setState(() {
                _selectedDay = DateTime.now();
                _focusedDay = DateTime.now();
              });
              _loadDosesForSelectedDay().then((_) => setState(() {}));
            },
            tooltip: 'Go to today',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddMedicine,
        backgroundColor: _softBlue,
        icon: const Icon(Icons.add),
        label: const Text('Add Medicine'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Calendar
                _buildCalendar(),
                
                const SizedBox(height: 8),
                
                // Selected day header
                _buildSelectedDayHeader(),
                
                // Doses list
                Expanded(
                  child: _buildDosesList(),
                ),
              ],
            ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _softBlue.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TableCalendar<ScheduledMedicine>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: _getEventsForDay,
        startingDayOfWeek: StartingDayOfWeek.saturday,
        onDaySelected: _onDaySelected,
        onFormatChanged: (format) {
          setState(() => _calendarFormat = format);
        },
        onPageChanged: _onPageChanged,
        
        // Calendar style
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,
          weekendTextStyle: const TextStyle(color: _errorRed),
          holidayTextStyle: const TextStyle(color: _errorRed),
          
          // Today
          todayDecoration: BoxDecoration(
            color: _softBlue.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          todayTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: _deepIndigo,
          ),
          
          // Selected day
          selectedDecoration: const BoxDecoration(
            color: _deepIndigo,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          
          // Markers
          markerDecoration: const BoxDecoration(
            color: _emerald,
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 6,
          markerMargin: const EdgeInsets.symmetric(horizontal: 1),
        ),
        
        // Header style
        headerStyle: HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          formatButtonDecoration: BoxDecoration(
            color: _softBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          formatButtonTextStyle: const TextStyle(
            color: _softBlue,
            fontWeight: FontWeight.bold,
          ),
          titleTextStyle: const TextStyle(
            color: _deepIndigo,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          leftChevronIcon: const Icon(Icons.chevron_left, color: _deepIndigo),
          rightChevronIcon: const Icon(Icons.chevron_right, color: _deepIndigo),
        ),
        
        // Days of week style
        daysOfWeekStyle: const DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: _textSecondary,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: _errorRed,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayHeader() {
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final isToday = isSameDay(_selectedDay, DateTime.now());
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(
            isToday ? Icons.today : Icons.calendar_today,
            color: _softBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isToday ? 'Today' : dateFormat.format(_selectedDay),
            style: const TextStyle(
              color: _textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const Spacer(),
          if (_selectedDayDoses.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _emerald.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_selectedDayDoses.length} dose${_selectedDayDoses.length > 1 ? 's' : ''}',
                style: const TextStyle(
                  color: _emerald,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDosesList() {
    if (_selectedDayDoses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medication_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No medicines scheduled',
              style: TextStyle(
                color: _textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _navigateToAddMedicine,
              icon: const Icon(Icons.add),
              label: const Text('Add a medicine'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: _selectedDayDoses.length,
      itemBuilder: (context, index) {
        final slot = _selectedDayDoses[index];
        return _buildDoseCard(slot);
      },
    );
  }

  Widget _buildDoseCard(DoseSlot slot) {
    final timeFormat = _formatTime(slot.time);
    final isPast = _isTimePast(slot.time);
    
    return InkWell(
      onDoubleTap: () => _markDoseTaken(slot),
      onLongPress: () => _showMedicineDetails(slot.medicine),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: slot.isTaken 
                ? _emerald.withOpacity(0.3)
                : isPast && !slot.isTaken
                    ? _warningOrange.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: (slot.isTaken ? _emerald : _softBlue).withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: slot.isTaken
                    ? _emerald.withOpacity(0.1)
                    : isPast && !slot.isTaken
                        ? _warningOrange.withOpacity(0.1)
                        : _softBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                slot.isTaken
                    ? Icons.check_circle
                    : isPast && !slot.isTaken
                        ? Icons.warning_rounded
                        : Icons.access_time,
                color: slot.isTaken
                    ? _emerald
                    : isPast && !slot.isTaken
                        ? _warningOrange
                        : _softBlue,
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Medicine info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.medicine.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _textPrimary,
                      decoration: slot.isTaken 
                          ? TextDecoration.lineThrough 
                          : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: _textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        timeFormat,
                        style: TextStyle(
                          color: _textSecondary,
                          fontSize: 13,
                        ),
                      ),
                      if (slot.isTaken && slot.log?.takenAt != null) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.done_all,
                          size: 14,
                          color: _emerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Taken at ${_formatTakenTime(slot.log!.takenAt!)}',
                          style: const TextStyle(
                            color: _emerald,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            
            // Action hint
            Column(
              children: [
                Icon(
                  Icons.touch_app,
                  size: 16,
                  color: Colors.grey[400],
                ),
                Text(
                  'Double tap',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    
    return '$h:$m $period';
  }

  String _formatTakenTime(String isoString) {
    final dateTime = DateTime.parse(isoString);
    return DateFormat('h:mm a').format(dateTime);
  }

  bool _isTimePast(String time) {
    if (!isSameDay(_selectedDay, DateTime.now())) {
      return _selectedDay.isBefore(DateTime.now());
    }
    
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final now = DateTime.now();
    final scheduleTime = DateTime(now.year, now.month, now.day, hour, minute);
    
    return now.isAfter(scheduleTime);
  }
}

// ============================================================
// ADD/EDIT MEDICINE PAGE
// ============================================================
class AddMedicinePage extends StatefulWidget {
  final DateTime initialDate;
  final ScheduledMedicine? medicineToEdit;

  const AddMedicinePage({
    super.key,
    required this.initialDate,
    this.medicineToEdit,
  });

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  
  late DateTime _startDate;
  late DateTime _endDate;
  List<TimeOfDay> _doseTimes = [TimeOfDay(hour: 8, minute: 0)];
  
  bool _isLoading = false;
  bool get _isEditing => widget.medicineToEdit != null;

  @override
  void initState() {
    super.initState();
    
    if (_isEditing) {
      final med = widget.medicineToEdit!;
      _nameController.text = med.name;
      _notesController.text = med.notes ?? '';
      _startDate = DateTime.parse(med.startDate);
      _endDate = DateTime.parse(med.endDate);
      _doseTimes = med.doseTimes.map((t) {
        final parts = t.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }).toList();
    } else {
      _startDate = widget.initialDate;
      _endDate = widget.initialDate.add(const Duration(days: 7));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _addDoseTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 12, minute: 0),
    );
    
    if (picked != null) {
      setState(() {
        _doseTimes.add(picked);
        _doseTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  Future<void> _editDoseTime(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _doseTimes[index],
    );
    
    if (picked != null) {
      setState(() {
        _doseTimes[index] = picked;
        _doseTimes.sort((a, b) {
          final aMinutes = a.hour * 60 + a.minute;
          final bMinutes = b.hour * 60 + b.minute;
          return aMinutes.compareTo(bMinutes);
        });
      });
    }
  }

  void _removeDoseTime(int index) {
    if (_doseTimes.length > 1) {
      setState(() {
        _doseTimes.removeAt(index);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('At least one dose time is required')),
      );
    }
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;
    if (_doseTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one dose time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dbHelper = DatabaseHelper();
      final notificationService = NotificationService();
      
      // Convert dose times to strings
      final doseTimeStrings = _doseTimes.map((t) {
        final h = t.hour.toString().padLeft(2, '0');
        final m = t.minute.toString().padLeft(2, '0');
        return '$h:$m';
      }).toList();

      final medicine = ScheduledMedicine(
        id: widget.medicineToEdit?.id,
        name: _nameController.text.trim(),
        startDate: DateFormat('yyyy-MM-dd').format(_startDate),
        endDate: DateFormat('yyyy-MM-dd').format(_endDate),
        doseTimes: doseTimeStrings,
        isActive: 1,
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (_isEditing) {
        await dbHelper.updateScheduledMedicine(medicine);
        await notificationService.updateMedicineNotifications(medicine);
      } else {
        final id = await dbHelper.insertScheduledMedicine(medicine);
        final savedMedicine = medicine.copyWith(id: id);
        await notificationService.scheduleMedicineNotifications(savedMedicine);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing 
                ? 'Medicine updated successfully' 
                : 'Medicine added successfully'),
            backgroundColor: _emerald,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: _errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: _deepIndigo),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Medicine' : 'Add Medicine',
          style: const TextStyle(
            color: _deepIndigo,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveMedicine,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Save',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Medicine Name
            _buildSectionTitle('Medicine Name'),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'Enter medicine name',
                prefixIcon: const Icon(Icons.medication, color: _softBlue),
                filled: true,
                fillColor: _cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _softBlue, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter medicine name';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // Date Range
            _buildSectionTitle('Schedule Duration'),
            Row(
              children: [
                Expanded(
                  child: _buildDateCard(
                    label: 'Start Date',
                    date: _startDate,
                    onTap: _selectStartDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDateCard(
                    label: 'End Date',
                    date: _endDate,
                    onTap: _selectEndDate,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Dose Times
            _buildSectionTitle('Dose Times'),
            const Text(
              'Tap to edit, swipe to remove',
              style: TextStyle(color: _textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            
            ..._doseTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return _buildTimeChip(time, index);
            }),
            
            const SizedBox(height: 12),
            
            // Add Time Button
            OutlinedButton.icon(
              onPressed: _addDoseTime,
              icon: const Icon(Icons.add),
              label: const Text('Add Another Time'),
              style: OutlinedButton.styleFrom(
                foregroundColor: _softBlue,
                side: const BorderSide(color: _softBlue),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Notes
            _buildSectionTitle('Notes (Optional)'),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add any notes or instructions...',
                filled: true,
                fillColor: _cardBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _softBlue, width: 2),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _textPrimary,
        ),
      ),
    );
  }

  Widget _buildDateCard({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: _textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: _softBlue),
                const SizedBox(width: 8),
                Text(
                  DateFormat('MMM d, yyyy').format(date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeChip(TimeOfDay time, int index) {
    final formattedTime = _formatTimeOfDay(time);
    
    return Dismissible(
      key: Key('time_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _removeDoseTime(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: _errorRed.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: _errorRed),
      ),
      child: InkWell(
        onTap: () => _editDoseTime(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: _cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _emerald.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _emerald.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.access_time,
                  color: _emerald,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                formattedTime,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _textPrimary,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.edit,
                size: 18,
                color: _textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final h = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}

// ============================================================
// MEDICINE DETAILS BOTTOM SHEET
// ============================================================
class MedicineDetailsSheet extends StatelessWidget {
  final ScheduledMedicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MedicineDetailsSheet({
    super.key,
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _softBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medication,
                  color: _softBlue,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                      ),
                    ),
                    Text(
                      medicine.isActive == 1 ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: medicine.isActive == 1 ? _emerald : _textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Schedule info
          _buildInfoRow(
            Icons.date_range,
            'Schedule',
            '${DateFormat('MMM d').format(DateTime.parse(medicine.startDate))} - ${DateFormat('MMM d, yyyy').format(DateTime.parse(medicine.endDate))}',
          ),
          
          const SizedBox(height: 12),
          
          _buildInfoRow(
            Icons.access_time,
            'Times',
            medicine.doseTimes.map((t) => _formatTime(t)).join(', '),
          ),
          
          if (medicine.notes != null && medicine.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.notes, 'Notes', medicine.notes!),
          ],
          
          const SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _softBlue,
                    side: const BorderSide(color: _softBlue),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _errorRed,
                    side: const BorderSide(color: _errorRed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: _textSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _textSecondary,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: _textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    final period = hour >= 12 ? 'PM' : 'AM';
    final h = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final m = minute.toString().padLeft(2, '0');
    
    return '$h:$m $period';
  }
}
