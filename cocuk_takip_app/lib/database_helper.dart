import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('pedagog_analiz.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE raporlar ( 
      id INTEGER PRIMARY KEY AUTOINCREMENT, 
      durum TEXT,
      detay TEXT,
      tarih TEXT
    )
    ''');
  }


  Future<int> kaydet(String durum, String detay) async {
    final db = await instance.database;
    final tarih = DateTime.now().toString();
    return await db.insert('raporlar', {
      'durum': durum,
      'detay': detay,
      'tarih': tarih
    });
  }


  Future<List<Map<String, dynamic>>> getirTumRaporlar() async {
    final db = await instance.database;
    return await db.query('raporlar', orderBy: 'id DESC');
  }
  

  Future<int> temizle() async {
    final db = await instance.database;
    return await db.delete('raporlar');
  }
}