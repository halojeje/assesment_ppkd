import 'package:assesment_ppkd/model/user_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ppkd_app.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel Users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        uid TEXT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT,
        profile_photo TEXT
      )
    ''');
  }

  // ==================== OPERASI USER ====================

  /// Menyimpan atau memperbarui profil pengguna secara lokal
  Future<int> insertOrUpdateUser(UserModel user) async {
    try {
      final db = await instance.database;
      final map = {
        if (user.id != null) 'id': user.id,
        'uid': user.uid,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'profile_photo': user.profilePhoto,
      };
      return await db.insert(
        'users',
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (_) {
      return -1;
    }
  }

  /// Mengambil data profil pengguna lokal berdasarkan ID
  Future<UserModel?> getUser(int id) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  /// Mengambil data profil pengguna lokal berdasarkan UID
  Future<UserModel?> getUserByUid(String uid) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'uid = ?', whereArgs: [uid]);

    if (maps.isNotEmpty) {
      return UserModel.fromJson(maps.first);
    }
    return null;
  }

  /// Menghapus seluruh data lokal (digunakan saat User Logout)
  Future<void> clearAllData() async {
    final db = await instance.database;
    await db.delete('users');
  }

  /// Menutup koneksi database
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
