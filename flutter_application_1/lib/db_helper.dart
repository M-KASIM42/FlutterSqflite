
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as database;
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();

  factory DbHelper() => _instance;

  DbHelper._internal();

  Future<Database> get database async {
    return await initDatabase();
  }

  Future<Database> initDatabase() async {
    final String databasesPath = await getDatabasesPath();
    final String path = join(databasesPath, 'mydb.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            description TEXT,
            createdAt TEXT
          )
        ''');
      },
    );
  }

  Future<int> addItem(Map<String, dynamic> item) async {
    final Database db = await _instance.database;
    return await db.insert('items', item);
  }

  Future<List<Map<String, dynamic>>> getItems() async {
    final Database db = await _instance.database;
    return await db.query('items');
  }

  Future<int> updateItem(Map<String, dynamic> item) async {
    final Database db = await _instance.database;
    return await db.update(
      'items',
      item,
      where: 'id = ?',
      whereArgs: [item['id']],
    );
  }

  Future<int> deleteItem(int id) async {
    final Database db = await _instance.database;
    return await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

