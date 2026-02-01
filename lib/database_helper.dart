import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Data model for scheduled medicines with calendar support
class ScheduledMedicine {
  final int? id;
  final String name;
  final String startDate; // ISO-8601 format
  final String endDate; // ISO-8601 format
  final List<String> doseTimes; // List of times like ["08:00", "20:00"]
  final int isActive; // 0 or 1
  final String? notes;

  ScheduledMedicine({
    this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.doseTimes,
    this.isActive = 1,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate,
      'endDate': endDate,
      'doseTimes': jsonEncode(doseTimes),
      'isActive': isActive,
      'notes': notes,
    };
  }

  factory ScheduledMedicine.fromMap(Map<String, dynamic> map) {
    return ScheduledMedicine(
      id: map['id'] as int?,
      name: map['name'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      doseTimes: List<String>.from(jsonDecode(map['doseTimes'] as String)),
      isActive: map['isActive'] as int,
      notes: map['notes'] as String?,
    );
  }

  /// Check if this medicine is scheduled for a specific date
  bool isScheduledForDate(DateTime date) {
    final start = DateTime.parse(startDate);
    final end = DateTime.parse(endDate);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final startOnly = DateTime(start.year, start.month, start.day);
    final endOnly = DateTime(end.year, end.month, end.day);
    
    return !dateOnly.isBefore(startOnly) && !dateOnly.isAfter(endOnly);
  }

  ScheduledMedicine copyWith({
    int? id,
    String? name,
    String? startDate,
    String? endDate,
    List<String>? doseTimes,
    int? isActive,
    String? notes,
  }) {
    return ScheduledMedicine(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      doseTimes: doseTimes ?? this.doseTimes,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}

/// Data model for medicine dose logs (tracking if user took the medicine)
class MedicineLog {
  final int? id;
  final int medicineId;
  final String scheduledDate; // The date this dose belonged to
  final String scheduledTime; // The specific time slot, e.g., "08:00"
  final String status; // 'taken', 'missed', 'skipped'
  final String? takenAt; // Actual timestamp when user marked it

  MedicineLog({
    this.id,
    required this.medicineId,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.status,
    this.takenAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicineId': medicineId,
      'scheduledDate': scheduledDate,
      'scheduledTime': scheduledTime,
      'status': status,
      'takenAt': takenAt,
    };
  }

  factory MedicineLog.fromMap(Map<String, dynamic> map) {
    return MedicineLog(
      id: map['id'] as int?,
      medicineId: map['medicineId'] as int,
      scheduledDate: map['scheduledDate'] as String,
      scheduledTime: map['scheduledTime'] as String,
      status: map['status'] as String,
      takenAt: map['takenAt'] as String?,
    );
  }
}

/// Represents a single dose slot for display in the calendar UI
class DoseSlot {
  final ScheduledMedicine medicine;
  final String time;
  final MedicineLog? log;

  DoseSlot({
    required this.medicine,
    required this.time,
    this.log,
  });

  bool get isTaken => log?.status == 'taken';
  bool get isMissed => log?.status == 'missed';
  bool get isSkipped => log?.status == 'skipped';
  bool get isPending => log == null;
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  // Database version - increment when schema changes
  static const int _databaseVersion = 2;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "prescript_sense_medicines.db");

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create original medicines table (for medicine database/lookup)
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        generic_name TEXT NOT NULL,
        brand_names_bd TEXT,
        indications TEXT,
        dosage_adult TEXT,
        dosage_child TEXT,
        cautions TEXT,
        side_effects TEXT
      )
    ''');

    // 2. Create scheduled_medicines table (for calendar & reminders)
    await db.execute('''
      CREATE TABLE scheduled_medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        doseTimes TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        notes TEXT
      )
    ''');

    // 3. Create medicine_logs table (for tracking doses taken)
    await db.execute('''
      CREATE TABLE medicine_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medicineId INTEGER NOT NULL,
        scheduledDate TEXT NOT NULL,
        scheduledTime TEXT NOT NULL,
        status TEXT NOT NULL,
        takenAt TEXT,
        FOREIGN KEY (medicineId) REFERENCES scheduled_medicines(id) ON DELETE CASCADE,
        UNIQUE(medicineId, scheduledDate, scheduledTime)
      )
    ''');

    // 4. Create index for faster queries
    await db.execute('''
      CREATE INDEX idx_logs_date ON medicine_logs(scheduledDate)
    ''');

    await db.execute('''
      CREATE INDEX idx_logs_medicine ON medicine_logs(medicineId)
    ''');

    // 5. Seed initial medicine data
    await _seedMedicineData(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new tables for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS scheduled_medicines (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          startDate TEXT NOT NULL,
          endDate TEXT NOT NULL,
          doseTimes TEXT NOT NULL,
          isActive INTEGER DEFAULT 1,
          notes TEXT
        )
      ''');

      await db.execute('''
        CREATE TABLE IF NOT EXISTS medicine_logs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          medicineId INTEGER NOT NULL,
          scheduledDate TEXT NOT NULL,
          scheduledTime TEXT NOT NULL,
          status TEXT NOT NULL,
          takenAt TEXT,
          FOREIGN KEY (medicineId) REFERENCES scheduled_medicines(id) ON DELETE CASCADE,
          UNIQUE(medicineId, scheduledDate, scheduledTime)
        )
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_logs_date ON medicine_logs(scheduledDate)
      ''');

      await db.execute('''
        CREATE INDEX IF NOT EXISTS idx_logs_medicine ON medicine_logs(medicineId)
      ''');
    }
  }

  Future<void> _seedMedicineData(Database db) async {
    final batch = db.batch();

    // Paracetamol
    batch.insert('medicines', {
      'generic_name': 'Paracetamol',
      'brand_names_bd': 'Napa (Beximco), Ace (Square), Renova',
      'indications': 'Fever, Mild to moderate pain, Headache, Toothache',
      'dosage_adult': '500mg - 1g every 4-6 hours (Max 4g/day)',
      'dosage_child': '10-15 mg/kg per dose',
      'cautions': 'Caution in liver disease.',
      'side_effects': 'Liver damage in high doses.',
    });

    // Omeprazole
    batch.insert('medicines', {
      'generic_name': 'Omeprazole',
      'brand_names_bd': 'Seclo (Square), Losectil',
      'indications': 'Gastric, Acidity, Heartburn, Acid Reflux, Ulcer',
      'dosage_adult': '20mg - 40mg once daily',
      'dosage_child': '10mg - 20mg if prescribed',
      'cautions': 'Long-term use affects magnesium.',
      'side_effects': 'Headache, diarrhea.',
    });

    // Azithromycin
    batch.insert('medicines', {
      'generic_name': 'Azithromycin',
      'brand_names_bd': 'Zimax (Square), Azithrocin',
      'indications': 'Bacterial Infections, Typhoid, Respiratory infection, Sore throat',
      'dosage_adult': '500mg daily for 3 days',
      'dosage_child': '10mg/kg daily',
      'cautions': 'Heart conditions (QT prolongation).',
      'side_effects': 'Nausea, abdominal pain.',
    });

    // Pantoprazole
    batch.insert('medicines', {
      'generic_name': 'Pantoprazole',
      'brand_names_bd': 'Pantonix, Pantodac',
      'indications': 'Gastric, Ulcer, Erosive Esophagitis, Acidity',
      'dosage_adult': '20mg - 40mg once daily',
      'dosage_child': 'Not recommended',
      'cautions': 'Monitor magnesium levels.',
      'side_effects': 'Headache, dizziness.',
    });

    // Fexofenadine
    batch.insert('medicines', {
      'generic_name': 'Fexofenadine',
      'brand_names_bd': 'Fexo, Fenofex, Axodin',
      'indications': 'Allergy, Runny nose, Sneezing, Hives, Itching',
      'dosage_adult': '120mg or 180mg once daily',
      'dosage_child': '30mg twice daily',
      'cautions': 'Kidney disease caution.',
      'side_effects': 'Drowsiness, dry mouth.',
    });

    // Montelukast
    batch.insert('medicines', {
      'generic_name': 'Montelukast',
      'brand_names_bd': 'Monas, Montair',
      'indications': 'Asthma prevention, Seasonal allergies, Breathing difficulty',
      'dosage_adult': '10mg once daily',
      'dosage_child': '4mg - 5mg daily',
      'cautions': 'Mood changes/agitation.',
      'side_effects': 'Respiratory infection.',
    });

    // Ciprofloxacin
    batch.insert('medicines', {
      'generic_name': 'Ciprofloxacin',
      'brand_names_bd': 'Ciprocin, Neofloxin',
      'indications': 'Severe Bacterial Infections, UTI, Urinary Tract Infection',
      'dosage_adult': '500mg - 750mg twice daily',
      'dosage_child': 'Avoid unless necessary',
      'cautions': 'Tendon rupture risk.',
      'side_effects': 'Nausea, photosensitivity.',
    });

    // Amoxicillin
    batch.insert('medicines', {
      'generic_name': 'Amoxicillin',
      'brand_names_bd': 'Moxacil, Tycil',
      'indications': 'Bacterial Infections, Ear infection, Throat infection, Pneumonia',
      'dosage_adult': '500mg every 8 hours',
      'dosage_child': '20-40mg/kg/day',
      'cautions': 'Penicillin allergy.',
      'side_effects': 'Rash, diarrhea.',
    });

    // Metronidazole
    batch.insert('medicines', {
      'generic_name': 'Metronidazole',
      'brand_names_bd': 'Amodis, Filmet',
      'indications': 'Dysentery, Diarrhea, Dental infection, Stomach infection',
      'dosage_adult': '400mg every 8 hours',
      'dosage_child': '7.5mg/kg every 8 hours',
      'cautions': 'NO ALCOHOL.',
      'side_effects': 'Metallic taste, dark urine.',
    });

    // Losartan
    batch.insert('medicines', {
      'generic_name': 'Losartan',
      'brand_names_bd': 'Losart, Osart',
      'indications': 'High Blood Pressure, Hypertension, Heart failure',
      'dosage_adult': '50mg - 100mg once daily',
      'dosage_child': 'Only if prescribed',
      'cautions': 'Do not use in pregnancy.',
      'side_effects': 'Dizziness, fatigue.',
    });

    await batch.commit();
  }

  // ============================================================
  // MEDICINE DATABASE (Lookup) METHODS
  // ============================================================

  Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    final db = await database;
    return await db.query(
      'medicines',
      where: 'generic_name LIKE ? OR brand_names_bd LIKE ? OR indications LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final db = await database;
    return await db.query('medicines');
  }

  // ============================================================
  // SCHEDULED MEDICINES (Calendar) METHODS
  // ============================================================

  /// Insert a new scheduled medicine
  Future<int> insertScheduledMedicine(ScheduledMedicine medicine) async {
    final db = await database;
    return await db.insert('scheduled_medicines', medicine.toMap());
  }

  /// Update an existing scheduled medicine
  Future<int> updateScheduledMedicine(ScheduledMedicine medicine) async {
    final db = await database;
    return await db.update(
      'scheduled_medicines',
      medicine.toMap(),
      where: 'id = ?',
      whereArgs: [medicine.id],
    );
  }

  /// Delete a scheduled medicine and its logs
  Future<int> deleteScheduledMedicine(int id) async {
    final db = await database;
    // Logs will be deleted automatically due to CASCADE
    return await db.delete(
      'scheduled_medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get all active scheduled medicines
  Future<List<ScheduledMedicine>> getActiveScheduledMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scheduled_medicines',
      where: 'isActive = ?',
      whereArgs: [1],
    );
    return maps.map((map) => ScheduledMedicine.fromMap(map)).toList();
  }

  /// Get all scheduled medicines (active and inactive)
  Future<List<ScheduledMedicine>> getAllScheduledMedicines() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('scheduled_medicines');
    return maps.map((map) => ScheduledMedicine.fromMap(map)).toList();
  }

  /// Get a single scheduled medicine by ID
  Future<ScheduledMedicine?> getScheduledMedicineById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'scheduled_medicines',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return ScheduledMedicine.fromMap(maps.first);
  }

  /// Get medicines scheduled for a specific date
  Future<List<ScheduledMedicine>> getMedicinesForDate(DateTime date) async {
    final db = await database;
    final dateStr = _formatDateOnly(date);
    
    // Get all active medicines where the date falls within the range
    final List<Map<String, dynamic>> maps = await db.query(
      'scheduled_medicines',
      where: 'isActive = ? AND date(startDate) <= date(?) AND date(endDate) >= date(?)',
      whereArgs: [1, dateStr, dateStr],
    );
    
    return maps.map((map) => ScheduledMedicine.fromMap(map)).toList();
  }

  /// Get expired medicines (endDate < today)
  Future<List<ScheduledMedicine>> getExpiredMedicines() async {
    final db = await database;
    final todayStr = _formatDateOnly(DateTime.now());
    
    final List<Map<String, dynamic>> maps = await db.query(
      'scheduled_medicines',
      where: 'isActive = ? AND date(endDate) < date(?)',
      whereArgs: [1, todayStr],
    );
    
    return maps.map((map) => ScheduledMedicine.fromMap(map)).toList();
  }

  /// Deactivate a medicine
  Future<void> deactivateMedicine(int id) async {
    final db = await database;
    await db.update(
      'scheduled_medicines',
      {'isActive': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get medicines with events for a date range (for calendar markers)
  Future<Map<DateTime, List<ScheduledMedicine>>> getMedicinesForDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final medicines = await getActiveScheduledMedicines();
    final Map<DateTime, List<ScheduledMedicine>> events = {};
    
    for (var date = start; !date.isAfter(end); date = date.add(const Duration(days: 1))) {
      final dateOnly = DateTime(date.year, date.month, date.day);
      final medsForDate = medicines.where((m) => m.isScheduledForDate(dateOnly)).toList();
      if (medsForDate.isNotEmpty) {
        events[dateOnly] = medsForDate;
      }
    }
    
    return events;
  }

  // ============================================================
  // MEDICINE LOGS (Dose Tracking) METHODS
  // ============================================================

  /// Mark a dose as taken
  Future<int> markDoseTaken(int medicineId, String date, String time) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    // Use INSERT OR REPLACE to handle duplicates
    return await db.rawInsert('''
      INSERT OR REPLACE INTO medicine_logs (medicineId, scheduledDate, scheduledTime, status, takenAt)
      VALUES (?, ?, ?, 'taken', ?)
    ''', [medicineId, date, time, now]);
  }

  /// Mark a dose with specific status
  Future<int> markDoseStatus(int medicineId, String date, String time, String status) async {
    final db = await database;
    final now = status == 'taken' ? DateTime.now().toIso8601String() : null;
    
    return await db.rawInsert('''
      INSERT OR REPLACE INTO medicine_logs (medicineId, scheduledDate, scheduledTime, status, takenAt)
      VALUES (?, ?, ?, ?, ?)
    ''', [medicineId, date, time, status, now]);
  }

  /// Unmark a dose (remove the log)
  Future<int> unmarkDose(int medicineId, String date, String time) async {
    final db = await database;
    return await db.delete(
      'medicine_logs',
      where: 'medicineId = ? AND scheduledDate = ? AND scheduledTime = ?',
      whereArgs: [medicineId, date, time],
    );
  }

  /// Get log for a specific dose
  Future<MedicineLog?> getDoseLog(int medicineId, String date, String time) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicine_logs',
      where: 'medicineId = ? AND scheduledDate = ? AND scheduledTime = ?',
      whereArgs: [medicineId, date, time],
    );
    if (maps.isEmpty) return null;
    return MedicineLog.fromMap(maps.first);
  }

  /// Get all logs for a specific date
  Future<List<MedicineLog>> getLogsForDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicine_logs',
      where: 'scheduledDate = ?',
      whereArgs: [date],
    );
    return maps.map((map) => MedicineLog.fromMap(map)).toList();
  }

  /// Get all logs for a specific medicine
  Future<List<MedicineLog>> getLogsForMedicine(int medicineId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'medicine_logs',
      where: 'medicineId = ?',
      whereArgs: [medicineId],
    );
    return maps.map((map) => MedicineLog.fromMap(map)).toList();
  }

  /// Get dose slots for a specific date (combines medicines + logs)
  Future<List<DoseSlot>> getDoseSlotsForDate(DateTime date) async {
    final dateStr = _formatDateOnly(date);
    final medicines = await getMedicinesForDate(date);
    final logs = await getLogsForDate(dateStr);
    
    final List<DoseSlot> slots = [];
    
    for (final medicine in medicines) {
      for (final time in medicine.doseTimes) {
        final log = logs.firstWhere(
          (l) => l.medicineId == medicine.id && l.scheduledTime == time,
          orElse: () => MedicineLog(
            medicineId: medicine.id!,
            scheduledDate: dateStr,
            scheduledTime: time,
            status: 'pending',
          ),
        );
        
        slots.add(DoseSlot(
          medicine: medicine,
          time: time,
          log: log.status == 'pending' ? null : log,
        ));
      }
    }
    
    // Sort by time
    slots.sort((a, b) => a.time.compareTo(b.time));
    return slots;
  }

  /// Get adherence statistics for a medicine
  Future<Map<String, int>> getMedicineAdherenceStats(int medicineId) async {
    final db = await database;
    
    final takenCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM medicine_logs WHERE medicineId = ? AND status = ?',
      [medicineId, 'taken'],
    )) ?? 0;
    
    final missedCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM medicine_logs WHERE medicineId = ? AND status = ?',
      [medicineId, 'missed'],
    )) ?? 0;
    
    final skippedCount = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM medicine_logs WHERE medicineId = ? AND status = ?',
      [medicineId, 'skipped'],
    )) ?? 0;
    
    return {
      'taken': takenCount,
      'missed': missedCount,
      'skipped': skippedCount,
      'total': takenCount + missedCount + skippedCount,
    };
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  String _formatDateOnly(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Reset database (for testing)
  Future<void> resetDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "prescript_sense_medicines.db");
    await deleteDatabase(path);
    _database = null;
  }
}
