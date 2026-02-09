import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('aura_skin.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // Optimized table for your 60 products requirement
    await db.execute('''
      CREATE TABLE favorites(
        product_id INTEGER PRIMARY KEY
      )
    ''');
  }

  // 1. SAVE Favorite (WRITE requirement)
  Future<int> insertFavorite(int productId) async {
    final db = await instance.database;
    return await db.insert('favorites', {
      'product_id': productId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // 2. REMOVE Favorite (DELETE requirement)
  Future<int> deleteFavorite(int productId) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'product_id = ?',
      whereArgs: [productId],
    );
  }

  // 3. READ ALL Favorites (READ requirement)
  // Renamed to fetchFavoriteIds to avoid the name conflict
  Future<List<int>> fetchFavoriteIds() async {
    final db = await instance.database;
    final List<Map<String, dynamic>> maps = await db.query('favorites');
    return List.generate(maps.length, (i) => maps[i]['product_id'] as int);
  }
}
