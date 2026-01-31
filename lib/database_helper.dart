import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, "prescript_sense_medicines.db");

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // 1. Create table with NEW 'indications' column
    await db.execute('''
      CREATE TABLE medicines (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        generic_name TEXT NOT NULL,
        brand_names_bd TEXT,
        indications TEXT,  -- NEW COLUMN
        dosage_adult TEXT,
        dosage_child TEXT,
        cautions TEXT,
        side_effects TEXT
      )
    ''');

    final batch = db.batch();

    // 2. Insert data with Disease Keywords

    // Paracetamol
    batch.insert('medicines', {
      'generic_name': 'Paracetamol',
      'brand_names_bd': 'Napa (Beximco), Ace (Square), Renova',
      'indications':
          'Fever, Mild to moderate pain, Headache, Toothache', // Added Keywords
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
      'indications':
          'Bacterial Infections, Typhoid, Respiratory infection, Sore throat',
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
      'indications':
          'Asthma prevention, Seasonal allergies, Breathing difficulty',
      'dosage_adult': '10mg once daily',
      'dosage_child': '4mg - 5mg daily',
      'cautions': 'Mood changes/agitation.',
      'side_effects': 'Respiratory infection.',
    });

    // Ciprofloxacin
    batch.insert('medicines', {
      'generic_name': 'Ciprofloxacin',
      'brand_names_bd': 'Ciprocin, Neofloxin',
      'indications':
          'Severe Bacterial Infections, UTI, Urinary Tract Infection',
      'dosage_adult': '500mg - 750mg twice daily',
      'dosage_child': 'Avoid unless necessary',
      'cautions': 'Tendon rupture risk.',
      'side_effects': 'Nausea, photosensitivity.',
    });

    // Amoxicillin
    batch.insert('medicines', {
      'generic_name': 'Amoxicillin',
      'brand_names_bd': 'Moxacil, Tycil',
      'indications':
          'Bacterial Infections, Ear infection, Throat infection, Pneumonia',
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

  // 3. UPDATED SEARCH QUERY
  Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    final db = await database;
    return await db.query(
      'medicines',
      // We now search in generic_name, brand_names, AND indications
      where:
          'generic_name LIKE ? OR brand_names_bd LIKE ? OR indications LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final db = await database;
    return await db.query('medicines');
  }
}
