import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  static Database? _database;

  DBHelper._internal();
  factory DBHelper() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'tabungan_global.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE users(id INTEGER PRIMARY KEY AUTOINCREMENT, email TEXT, password TEXT)');

        await db.execute('''
          CREATE TABLE targets(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            target_amount REAL,
            status INTEGER DEFAULT 0  -- 0: Belum Selesai, 1: Selesai (Masuk History)
          )
        ''');

        await db.execute('''
          CREATE TABLE transactions(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT, -- 'IN' (Pemasukan) atau 'OUT' (Target Tercapai)
            description TEXT,
            amount REAL,
            created_at TEXT
          )
        ''');
      },
    );
  }


  Future<double> getGlobalBalance() async {
    final db = await database;
    var resIn = await db.rawQuery("SELECT SUM(amount) as total FROM transactions WHERE type='IN'");
    double totalIn = resIn[0]['total'] != null ? (resIn[0]['total'] as num).toDouble() : 0.0;

    var resOut = await db.rawQuery("SELECT SUM(amount) as total FROM transactions WHERE type='OUT'");
    double totalOut = resOut[0]['total'] != null ? (resOut[0]['total'] as num).toDouble() : 0.0;

    return totalIn - totalOut;
  }

  Future<int> addIncome(double amount, String source) async {
    final db = await database;
    return await db.insert('transactions', {
      'type': 'IN',
      'description': source, 
      'amount': amount,
      'created_at': DateTime.now().toString()
    });
  }

  Future<int> createTarget(String title, double targetAmount) async {
    final db = await database;
    return await db.insert('targets', {
      'title': title,
      'target_amount': targetAmount,
      'status': 0 // Aktif
    });
  }

  Future<List<Map<String, dynamic>>> getActiveTargets() async {
    final db = await database;
    return await db.query('targets', where: 'status = 0');
  }

  Future<List<Map<String, dynamic>>> getCompletedTargets() async {
    final db = await database;
    return await db.query('targets', where: 'status = 1');
  }

  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    final db = await database;
    return await db.query('transactions', orderBy: "created_at DESC");
  }

  Future<void> completeTarget(int id, String title, double amount) async {
    final db = await database;
    
    await db.insert('transactions', {
      'type': 'OUT',
      'description': 'Tercapai: $title',
      'amount': amount,
      'created_at': DateTime.now().toString()
    });

    await db.update('targets', {'status': 1}, where: 'id = ?', whereArgs: [id]);
  }
  
  Future<int> registerUser(String email, String password) async {
    final db = await database;
    return await db.insert('users', {'email': email, 'password': password});
  }
  Future<bool> loginUser(String email, String password) async {
    final db = await database;
    var res = await db.query('users', where: 'email = ? AND password = ?', whereArgs: [email, password]);
    return res.isNotEmpty;
  }
}