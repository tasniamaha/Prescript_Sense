import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'medicines.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE medicines(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            generic_name TEXT,
            brand_names_bd TEXT,
            dosage_adult TEXT,
            dosage_child TEXT,
            cautions TEXT,
            price TEXT,
            side_effects TEXT,
            pregnancy_risk TEXT,
            indications TEXT
          )
        ''');

        // Sample data
        await db.insert('medicines', {
          'generic_name': 'Paracetamol',
          'brand_names_bd': 'Crocin, Calpol',
          'dosage_adult': '500mg every 6h',
          'dosage_child': '250mg every 6h',
          'cautions': 'Liver disease caution',
          'price': '50 BDT',
          'side_effects': 'Nausea, dizziness',
          'pregnancy_risk': 'Category B',
          'indications': 'Fever, pain'
        });
      },
    );
  }

  Future<List<Map<String, dynamic>>> getAllMedicines() async {
    final db = await database;
    return await db.query('medicines');
  }

  Future<List<Map<String, dynamic>>> searchMedicines(String query) async {
    final db = await database;
    return await db.query(
      'medicines',
      where: 'generic_name LIKE ?',
      whereArgs: ['%$query%'],
    );
  }
}
