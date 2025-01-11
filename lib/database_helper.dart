import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static Database? _database;

  void _logQuery(String query, [List<dynamic>? args]) {
    print('Executing SQL Query: $query');
    if (args != null) {
      print('With arguments: $args');
    }
  }

  static Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ron.db');
    print('Database path: $path');

    if (!await File(path).exists()) {
      print('Creating new database from assets');
      ByteData data = await rootBundle.load('assets/ron.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    _database = await openDatabase(path, version: 1);
    return _database!;
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await initDatabase();
    const query = "SELECT * FROM categories";
    _logQuery(query);
    return await db.rawQuery(query);
  }

  Future<List<Map<String, dynamic>>> getSubcategories(
      int parentId, int level) async {
    final db = await initDatabase();
    const query = "SELECT * FROM subindex WHERE ParentId = ? AND Level = ?";
    String query2 =
        "SELECT * FROM subindex WHERE ParentId = $parentId AND Level = $level";
    _logQuery(query2);
    return await db.rawQuery(query, [parentId, level]);
  }

  Future<List<Map<String, dynamic>>> getLinesMetadata(int subIndexId) async {
    final db = await initDatabase();
    const query = "SELECT * FROM linesmetadata WHERE SubIndexId = ?";
    String query2 =
        "SELECT * FROM linesmetadata WHERE SubIndexId = $subIndexId";
    _logQuery(query2);
    return await db.rawQuery(query, [subIndexId]);
  }

  Future<List<Map<String, dynamic>>> getLines(List<dynamic> lineIds) async {
    final db = await initDatabase();
    final query = "SELECT * FROM lines WHERE Id IN (${lineIds.join(',')})";
    _logQuery(query);
    return await db.rawQuery(query);
  }
}
