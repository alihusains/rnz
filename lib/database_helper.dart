import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  /// Logs SQL query with all placeholders replaced by actual argument values
  void _logQuery(String query, [List<dynamic>? args]) {
    String formatted = query;
    if (args != null && args.isNotEmpty) {
      for (var arg in args) {
        String value;
        if (arg is String) {
          // Escape single quotes
          final escaped = arg.replaceAll("'", "''");
          value = "'" + escaped + "'";
        } else {
          value = arg.toString();
        }
        formatted = formatted.replaceFirst('?', value);
      }
    }
    debugPrint('Executing SQL Query: $formatted');
  }

  Future<Database> initDatabase() async {
    if (_database != null) return _database!;

    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'ron.db');
    debugPrint('Database path: $path');

    if (!await File(path).exists()) {
      debugPrint('Creating new database from assets');
      ByteData data = await rootBundle.load('assets/ron.db');
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    _database = await openDatabase(path, version: 1);
    return _database!;
  }

  /// Fetch only visible categories (IsVisible = 1)
  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await initDatabase();
    const query = 'SELECT * FROM categories WHERE IsVisible = 1';
    _logQuery(query);
    return await db.rawQuery(query);
  }

  /// Fetch subcategories for a given categoryId, parentId, and level, ordered by Number asc
  Future<List<Map<String, dynamic>>> getSubcategories(
      int categoryId, int parentId, int level) async {
    final db = await initDatabase();
    const query =
        'SELECT * FROM subindex WHERE CategoryId = ? AND ParentId = ? AND Level = ? ORDER BY Number ASC';
    _logQuery(query, [categoryId, parentId, level]);
    return await db.rawQuery(query, [categoryId, parentId, level]);
  }

  /// Fetch lines metadata joined with lines data for a subindex, ordered by metadata.Number asc
  Future<List<Map<String, dynamic>>> getLinesForSubindex(int subIndexId) async {
    final db = await initDatabase();

    // Retrieve the selected language from shared preferences
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('selectedLanguage') ?? 'English';

    // Dynamically construct the query based on the selected language
    final query = '''
      SELECT lm.*, 
             l.${language}Title, 
             l.${language}Description, 
             l.${language}, 
             l.RArabic,
             CONCAT_WS('', l.ArabicText1, l.ArabicText2, l.ArabicText3, l.ArabicText4, l.ArabicText5, 
                       l.ArabicText6, l.ArabicText7, l.ArabicText8, l.ArabicText9, l.ArabicText10, 
                       l.ArabicText11, l.ArabicText12, l.ArabicText13, l.ArabicText14, l.ArabicText15, 
                       l.ArabicText16, l.ArabicText17, l.ArabicText18, l.ArabicText19, l.ArabicText20) AS ArabicContent
      FROM linesmetadata lm
      JOIN lines l ON lm.LinesId = l.id
      WHERE lm.SubindexId = ?
      ORDER BY lm.Number ASC
    ''';

    _logQuery(query, [subIndexId]);
    return await db.rawQuery(query, [subIndexId]);
  }
}
// TODO : 
 

// in detail screen check in ${_selectedLanguage}Description:

// if there is any text like <abcd-efg> present, extract the entire text
// (Also in the front end remove the brackets and show it as a hyperlink in a good UX)

// When user taps on that link

// What it should do is fire this query : 

// SELECT lm.*, l.{language}Title,l.{language}Description ,l.{language},
// CONCAT_WS('', l.ArabicText1, l.ArabicText2, l.ArabicText3, l.ArabicText4, l.ArabicText5, l.ArabicText6, l.ArabicText7, l.ArabicText8, l.ArabicText9, l.ArabicText10, l.ArabicText11, l.ArabicText12, l.ArabicText13, l.ArabicText14, l.ArabicText15, l.ArabicText16, l.ArabicText17, l.ArabicText18, l.ArabicText19, l.ArabicText20),
// l.RArabic,
// FROM linesmetadata lm 
// JOIN lines l ON lm.LinesId = l.id 
// JOIN subindex s ON lm.SubindexId = s.id
// WHERE s.Hyperlink${language}Name = 'EXTRACTED_TEXT_HERE'
// ORDER BY lm.Number ASC;

// Get the result and again load the detail page with this query results