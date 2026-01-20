import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/memo.dart';

class MemoDatabase {
  static final MemoDatabase instance = MemoDatabase._init();
  static Database? _database;

  MemoDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('memo.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, 
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE memo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        isPinned INTEGER NOT NULL DEFAULT 0,
        isLocked INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<int> insertMemo(Memo memo) async {
    final db = await instance.database;
    return await db.insert('memo', memo.toMap());
  }

  Future<int> updateMemo(Memo memo) async {
    final db = await instance.database;
    return await db.update(
      'memo', 
      memo.toMap(), 
      where: 'id = ?', 
      whereArgs: [memo.id]
    );
  }

  Future<int> deleteMemo(int id) async {
    final db = await instance.database;
    return await db.delete(
      'memo', 
      where: 'id = ?', 
      whereArgs: [id]
    );
  }

  Future<List<Memo>> getAllMemo() async {
    final db = await instance.database;
    // Urutkan: Pinned paling atas, lalu ID terbaru
    final result = await db.query('memo', orderBy: 'isPinned DESC, id DESC');
    return result.map((e) => Memo.fromMap(e)).toList();
  }
}