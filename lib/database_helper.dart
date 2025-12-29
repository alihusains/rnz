// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:path/path.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sqflite/sqflite.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class DatabaseHelper {
//   static Database? _database;
//   static final DatabaseHelper _instance = DatabaseHelper._internal();

//   DatabaseHelper._internal();

//   factory DatabaseHelper() {
//     return _instance;
//   }

//   /// Logs SQL query with all placeholders replaced by actual argument values
//   void _logQuery(String query, [List<dynamic>? args]) {
//     String formatted = query;
//     if (args != null && args.isNotEmpty) {
//       for (var arg in args) {
//         String value;
//         if (arg is String) {
//           // Escape single quotes
//           final escaped = arg.replaceAll("'", "''");
//           value = "'" + escaped + "'";
//         } else {
//           value = arg.toString();
//         }
//         formatted = formatted.replaceFirst('?', value);
//       }
//     }
//     debugPrint('Executing SQL Query: $formatted');
//   }

//   Future<Database> initDatabase() async {
//     if (_database != null) return _database!;

//     Directory documentsDirectory = await getApplicationDocumentsDirectory();
//     String path = join(documentsDirectory.path, 'ron.db');
//     debugPrint('Database path: $path');

//     if (!await File(path).exists()) {
//       debugPrint('Creating new database from assets');
//       ByteData data = await rootBundle.load('assets/ron.db');
//       List<int> bytes =
//           data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
//       await File(path).writeAsBytes(bytes);
//     }

//     _database = await openDatabase(path, version: 1);
//     return _database!;
//   }

//   /// Fetch only visible categories (IsVisible = 1)
//   Future<List<Map<String, dynamic>>> getCategories() async {
//     final db = await initDatabase();
//     const query = 'SELECT * FROM categories WHERE IsVisible = 1';
//     _logQuery(query);
//     return await db.rawQuery(query);
//   }

//   /// Fetch subcategories for a given categoryId, parentId, and level, ordered by Number asc
//   Future<List<Map<String, dynamic>>> getSubcategories(
//       int categoryId, int parentId, int level) async {
//     final db = await initDatabase();
//     const query =
//         'SELECT * FROM subindex WHERE CategoryId = ? AND ParentId = ? AND Level = ? ORDER BY Number ASC';
//     _logQuery(query, [categoryId, parentId, level]);
//     return await db.rawQuery(query, [categoryId, parentId, level]);
//   }

//   /// Fetch lines metadata joined with lines data for a subindex, ordered by metadata.Number asc
//   Future<List<Map<String, dynamic>>> getLinesForSubindex(int subIndexId) async {
//     final db = await initDatabase();

//     // Retrieve the selected language from shared preferences
//     final prefs = await SharedPreferences.getInstance();
//     final language = prefs.getString('selectedLanguage') ?? 'English';

//     // Dynamically construct the query based on the selected language
//     final query = '''
//       SELECT lm.*,
//              l.${language}Title,
//              l.${language}Description,
//              l.${language},
//              l.RArabic,
//              CONCAT_WS('', l.ArabicText1, l.ArabicText2, l.ArabicText3, l.ArabicText4, l.ArabicText5,
//                         l.ArabicText6, l.ArabicText7, l.ArabicText8, l.ArabicText9, l.ArabicText10,
//                         l.ArabicText11, l.ArabicText12, l.ArabicText13, l.ArabicText14, l.ArabicText15,
//                         l.ArabicText16, l.ArabicText17, l.ArabicText18, l.ArabicText19, l.ArabicText20) AS ArabicContent
//       FROM linesmetadata lm
//       JOIN lines l ON lm.LinesId = l.id
//       WHERE lm.SubindexId = ?
//       ORDER BY lm.Number ASC
//     ''';

//     _logQuery(query, [subIndexId]);
//     return await db.rawQuery(query, [subIndexId]);
//   }

//   /// Fetch lines by hyperlink name (for hyperlink navigation)
//   /// This searches the subindex table for a matching HyperlinkName and returns associated lines
//   Future<List<Map<String, dynamic>>> getLinesByHyperlinkName(
//       String hyperlinkName) async {
//     final db = await initDatabase();

//     // Retrieve the selected language from shared preferences
//     final prefs = await SharedPreferences.getInstance();
//     final language = prefs.getString('selectedLanguage') ?? 'English';

//     // Dynamically construct the query based on the selected language
//     // Using case-insensitive search and flexible column naming
//     final query = '''
//       SELECT lm.*,
//              l.${language}Title,
//              l.${language}Description,
//              l.${language},
//              l.RArabic,
//              CONCAT_WS('', l.ArabicText1, l.ArabicText2, l.ArabicText3, l.ArabicText4, l.ArabicText5,
//                         l.ArabicText6, l.ArabicText7, l.ArabicText8, l.ArabicText9, l.ArabicText10,
//                         l.ArabicText11, l.ArabicText12, l.ArabicText13, l.ArabicText14, l.ArabicText15,
//                         l.ArabicText16, l.ArabicText17, l.ArabicText18, l.ArabicText19, l.ArabicText20) AS ArabicContent
//       FROM linesmetadata lm
//       JOIN lines l ON lm.LinesId = l.id
//       JOIN subindex s ON lm.SubindexId = s.id
//       WHERE s.Hyperlink${language}Name = ?
//       ORDER BY lm.Number ASC
//     ''';

//     _logQuery(query, [hyperlinkName]);
//     return await db.rawQuery(query, [hyperlinkName]);
//   }

//   // ============= BOOKMARK METHODS =============

//   /// Save a bookmark (language-specific)
//   Future<void> saveBookmark({
//     required int subIndexId,
//     required String title,
//     required String language,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];
//     final bookmarkKey = '$subIndexId|$title';

//     if (!bookmarks.contains(bookmarkKey)) {
//       bookmarks.add(bookmarkKey);
//       await prefs.setStringList('bookmarks_$language', bookmarks);
//       debugPrint('Bookmark saved: $bookmarkKey for language: $language');
//     }
//   }

//   /// Remove a bookmark (language-specific)
//   Future<void> removeBookmark({
//     required int subIndexId,
//     required String language,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];
//     bookmarks.removeWhere((bookmark) => bookmark.startsWith('$subIndexId|'));
//     await prefs.setStringList('bookmarks_$language', bookmarks);
//     debugPrint('Bookmark removed for subIndexId: $subIndexId, language: $language');
//   }

//   /// Check if a bookmark exists (language-specific)
//   Future<bool> isBookmarked({
//     required int subIndexId,
//     required String language,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];
//     return bookmarks.any((bookmark) => bookmark.startsWith('$subIndexId|'));
//   }

//   /// Get all bookmarks for current language
//   Future<List<Map<String, dynamic>>> getBookmarksForLanguage(String language) async {
//     final prefs = await SharedPreferences.getInstance();
//     final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];

//     List<Map<String, dynamic>> result = [];
//     for (var bookmark in bookmarks) {
//       final parts = bookmark.split('|');
//       if (parts.length == 2) {
//         final subIndexId = int.tryParse(parts[0]);
//         final title = parts[1];
//         if (subIndexId != null) {
//           result.add({
//             'SubindexId': subIndexId,
//             'Title': title,
//           });
//         }
//       }
//     }
//     return result;
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static final _initMutex = Mutex();

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
    // Check if database is already open
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    // Use mutex to prevent concurrent initialization
    await _initMutex.acquire();
    try {
      // Double-check pattern
      if (_database != null && _database!.isOpen) {
        return _database!;
      }

      debugPrint('Initializing database...');

      Directory documentsDirectory = await getApplicationDocumentsDirectory();
      String path = join(documentsDirectory.path, 'ron.db');
      debugPrint('Database path: $path');

      bool dbExists = await File(path).exists();
      debugPrint('Database exists: $dbExists');

      if (!dbExists) {
        debugPrint('Database does not exist, creating from assets...');
        try {
          ByteData data = await rootBundle.load('assets/ron.db');
          List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(path).writeAsBytes(bytes);
          debugPrint(
              'Database created successfully from assets (${bytes.length} bytes)');
        } catch (e) {
          debugPrint('Error copying database from assets: $e');
          rethrow;
        }
      } else {
        debugPrint('Database already exists');
      }

      try {
        debugPrint('Opening database at $path...');
        _database = await openDatabase(
          path,
          version: 1,
          onOpen: (db) {
            debugPrint('✓ Database opened successfully');
          },
          onConfigure: (db) async {
            await db.execute('PRAGMA foreign_keys = ON');
          },
        );

        // Verify database is readable by querying table count
        final tables = await _database!.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table'",
        );
        debugPrint(
            '✓ Database verification passed. Tables found: ${tables.length}');

        return _database!;
      } catch (e) {
        debugPrint('✗ Error opening database: $e');
        _database = null;
        rethrow;
      }
    } finally {
      _initMutex.release();
    }
  }

  /// Fetch only visible categories (IsVisible = 1)
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final db = await initDatabase();
      const query =
          'SELECT * FROM categories WHERE IsVisible = 1 ORDER BY Number ASC';
      _logQuery(query);
      final result = await db.rawQuery(query);
      debugPrint('✓ Successfully fetched ${result.length} categories');
      return result;
    } catch (e) {
      debugPrint('✗ Error in getCategories: $e');
      rethrow;
    }
  }

  /// Fetch subcategories for a given categoryId, parentId, and level
  Future<List<Map<String, dynamic>>> getSubcategories(
      int categoryId, int parentId, int level) async {
    try {
      final db = await initDatabase();
      const query =
          'SELECT * FROM subindex WHERE CategoryId = ? AND ParentId = ? AND Level = ? ORDER BY Number ASC';
      _logQuery(query, [categoryId, parentId, level]);
      final result = await db.rawQuery(query, [categoryId, parentId, level]);
      debugPrint(
          '✓ Successfully fetched ${result.length} subcategories for CategoryId=$categoryId, ParentId=$parentId, Level=$level');
      return result;
    } catch (e) {
      debugPrint('✗ Error in getSubcategories: $e');
      rethrow;
    }
  }

  /// Fetch lines metadata joined with lines data for a subindex
  Future<List<Map<String, dynamic>>> getLinesForSubindex(int subIndexId) async {
    try {
      final db = await initDatabase();

      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('selectedLanguage') ?? 'English';

      // Use SQLite string concatenation (compatible with SQLite)
      final query = '''
        SELECT lm.*, 
               l.${language}Title, 
               l.${language}Description, 
               l.${language}, 
               l.RArabic,
               COALESCE(
                 NULLIF(
                   TRIM(
                     COALESCE(l.ArabicText1, '') || 
                     COALESCE(l.ArabicText2, '') || 
                     COALESCE(l.ArabicText3, '') || 
                     COALESCE(l.ArabicText4, '') || 
                     COALESCE(l.ArabicText5, '') || 
                     COALESCE(l.ArabicText6, '') || 
                     COALESCE(l.ArabicText7, '') || 
                     COALESCE(l.ArabicText8, '') || 
                     COALESCE(l.ArabicText9, '') || 
                     COALESCE(l.ArabicText10, '') || 
                     COALESCE(l.ArabicText11, '') || 
                     COALESCE(l.ArabicText12, '') || 
                     COALESCE(l.ArabicText13, '') || 
                     COALESCE(l.ArabicText14, '') || 
                     COALESCE(l.ArabicText15, '') || 
                     COALESCE(l.ArabicText16, '') || 
                     COALESCE(l.ArabicText17, '') || 
                     COALESCE(l.ArabicText18, '') || 
                     COALESCE(l.ArabicText19, '') || 
                     COALESCE(l.ArabicText20, '')
                   ), 
                   ''
                 ), 
                 ''
               ) AS ArabicContent
        FROM linesmetadata lm
        JOIN lines l ON lm.LinesId = l.id
        WHERE lm.SubindexId = ?
        ORDER BY lm.Number ASC
      ''';

      _logQuery(query, [subIndexId]);
      final result = await db.rawQuery(query, [subIndexId]);
      debugPrint(
          '✓ Successfully fetched ${result.length} lines for subIndexId=$subIndexId');
      return result;
    } catch (e) {
      debugPrint('✗ Error in getLinesForSubindex: $e');
      rethrow;
    }
  }

  /// Fetch lines by hyperlink name
  Future<List<Map<String, dynamic>>> getLinesByHyperlinkName(
      String hyperlinkName) async {
    try {
      final db = await initDatabase();

      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('selectedLanguage') ?? 'English';

      final query = '''
        SELECT lm.*, 
               l.${language}Title, 
               l.${language}Description, 
               l.${language}, 
               l.RArabic,
               COALESCE(
                 NULLIF(
                   TRIM(
                     COALESCE(l.ArabicText1, '') || 
                     COALESCE(l.ArabicText2, '') || 
                     COALESCE(l.ArabicText3, '') || 
                     COALESCE(l.ArabicText4, '') || 
                     COALESCE(l.ArabicText5, '') || 
                     COALESCE(l.ArabicText6, '') || 
                     COALESCE(l.ArabicText7, '') || 
                     COALESCE(l.ArabicText8, '') || 
                     COALESCE(l.ArabicText9, '') || 
                     COALESCE(l.ArabicText10, '') || 
                     COALESCE(l.ArabicText11, '') || 
                     COALESCE(l.ArabicText12, '') || 
                     COALESCE(l.ArabicText13, '') || 
                     COALESCE(l.ArabicText14, '') || 
                     COALESCE(l.ArabicText15, '') || 
                     COALESCE(l.ArabicText16, '') || 
                     COALESCE(l.ArabicText17, '') || 
                     COALESCE(l.ArabicText18, '') || 
                     COALESCE(l.ArabicText19, '') || 
                     COALESCE(l.ArabicText20, '')
                   ), 
                   ''
                 ), 
                 ''
               ) AS ArabicContent
        FROM linesmetadata lm
        JOIN lines l ON lm.LinesId = l.id
        JOIN subindex s ON lm.SubindexId = s.id
        WHERE s.Hyperlink${language}Name = ?
        ORDER BY lm.Number ASC
      ''';

      _logQuery(query, [hyperlinkName]);
      final result = await db.rawQuery(query, [hyperlinkName]);
      debugPrint(
          '✓ Successfully fetched ${result.length} lines for hyperlink: $hyperlinkName');
      return result;
    } catch (e) {
      debugPrint('✗ Error in getLinesByHyperlinkName: $e');
      rethrow;
    }
  }

  // ============= BOOKMARK METHODS =============

  Future<void> saveBookmark({
    required int subIndexId,
    required String title,
    required String language,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];
      final bookmarkKey = '$subIndexId|$title';

      if (!bookmarks.contains(bookmarkKey)) {
        bookmarks.add(bookmarkKey);
        await prefs.setStringList('bookmarks_$language', bookmarks);
        debugPrint('✓ Bookmark saved: $bookmarkKey for language: $language');
      }
    } catch (e) {
      debugPrint('✗ Error saving bookmark: $e');
      rethrow;
    }
  }

  Future<void> removeBookmark({
    required int subIndexId,
    required String language,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];
      bookmarks.removeWhere((bookmark) => bookmark.startsWith('$subIndexId|'));
      await prefs.setStringList('bookmarks_$language', bookmarks);
      debugPrint(
          '✓ Bookmark removed for subIndexId: $subIndexId, language: $language');
    } catch (e) {
      debugPrint('✗ Error removing bookmark: $e');
      rethrow;
    }
  }

  Future<bool> isBookmarked({
    required int subIndexId,
    required String language,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];
      return bookmarks.any((bookmark) => bookmark.startsWith('$subIndexId|'));
    } catch (e) {
      debugPrint('✗ Error checking bookmark: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getBookmarksForLanguage(
      String language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarks = prefs.getStringList('bookmarks_$language') ?? [];

      List<Map<String, dynamic>> result = [];
      for (var bookmark in bookmarks) {
        final parts = bookmark.split('|');
        if (parts.length == 2) {
          final subIndexId = int.tryParse(parts[0]);
          final title = parts[1];
          if (subIndexId != null) {
            result.add({
              'SubindexId': subIndexId,
              'Title': title,
            });
          }
        }
      }
      return result;
    } catch (e) {
      debugPrint('✗ Error getting bookmarks: $e');
      return [];
    }
  }
}

/// Simple Mutex implementation for thread-safe database initialization
class Mutex {
  bool _locked = false;
  final List<Completer<void>> _waitQueue = [];

  Future<void> acquire() async {
    if (!_locked) {
      _locked = true;
      return;
    }

    final completer = Completer<void>();
    _waitQueue.add(completer);
    await completer.future;
  }

  void release() {
    if (_waitQueue.isEmpty) {
      _locked = false;
    } else {
      final completer = _waitQueue.removeAt(0);
      completer.complete();
    }
  }
}
