import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/app_constants.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.dbName);
    return openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE attendance (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT NOT NULL,
        employeeName TEXT NOT NULL,
        date TEXT NOT NULL,
        checkInTime TEXT,
        checkOutTime TEXT,
        checkInLatitude REAL,
        checkInLongitude REAL,
        checkOutLatitude REAL,
        checkOutLongitude REAL,
        status TEXT NOT NULL DEFAULT 'not_checked_in',
        UNIQUE(employeeId, date)
      )
    ''');
  }
}
