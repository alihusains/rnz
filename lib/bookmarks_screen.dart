import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:raazoneyaz/detail_screen.dart';
import 'package:raazoneyaz/app_theme.dart';
import 'database_helper.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen();

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  List<Map<String, dynamic>> bookmarks = [];
  late DatabaseHelper _dbHelper;
  String? _selectedLanguage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _loadBookmarks();
  }

  Future<void> _loadBookmarks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final language = prefs.getString('selectedLanguage') ?? 'English';
      
      setState(() {
        _selectedLanguage = language;
      });

      final bookmarkList =
          await _dbHelper.getBookmarksForLanguage(language);
      
      if (mounted) {
        setState(() {
          bookmarks = bookmarkList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeBookmark(int subIndexId) async {
    try {
      await _dbHelper.removeBookmark(
        subIndexId: subIndexId,
        language: _selectedLanguage ?? 'English',
      );
      
      if (mounted) {
        setState(() {
          bookmarks.removeWhere((b) => b['SubindexId'] == subIndexId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bookmark removed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookmarks'),
      ),
      body: Container(
        color: AppTheme.creamWhite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : bookmarks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bookmark_outline,
                          size: 64,
                          color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookmarks yet',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppTheme.darkText.withValues(alpha: 0.6),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Bookmark your favorite items to access them quickly',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.darkText.withValues(alpha: 0.4),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    itemCount: bookmarks.length,
                    itemBuilder: (context, index) {
                      final bookmark = bookmarks[index];
                      final title = bookmark['Title'] ?? '';
                      final subIndexId = bookmark['SubindexId'] as int;

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8.0, vertical: 4.0),
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: AppTheme.primaryGold.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            leading: Icon(
                              Icons.bookmark,
                              color: AppTheme.primaryGold,
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                color: AppTheme.darkGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.close),
                              color: AppTheme.errorRed,
                              onPressed: () {
                                _removeBookmark(subIndexId);
                              },
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailedScreen(
                                    title: title,
                                    subIndexId: subIndexId,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
