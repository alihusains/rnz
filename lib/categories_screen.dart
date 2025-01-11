import 'package:flutter/material.dart';
import 'package:raazoneyaz/detail_screen.dart';
import 'database_helper.dart';

class CategoriesScreen extends StatefulWidget {
  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _subcategories = [];
  int _currentLevel = 0; // Level for subcategories

  late DatabaseHelper _dbHelper;

  @override
  void initState() {
    super.initState();
    _dbHelper = DatabaseHelper();
    _fetchCategories(); // Fetch all categories when the app starts
  }

  Future<void> _fetchCategories() async {
    // Fetch all categories without any condition
    final result = await _dbHelper.getCategories();
    setState(() {
      _categories = result; // Load categories in the UI
    });
  }

  Future<void> _fetchSubcategories(int parentId, int level) async {
    debugPrint("ParentID: $parentId, Level: $level");
    final result = await _dbHelper.getSubcategories(parentId, level);

    if (result.isEmpty) {
      debugPrint("No subcategories found.");
      return;
    }

    // Check if all subcategories have HasChildren = 0
    bool allHaveNoChildren = result.every((item) => item['HasChildren'] == 0);

    if (allHaveNoChildren) {
      // Navigate to detail screen if no further subcategories exist
      await _navigateToDetailScreen(parentId, result.first['EnglishName']);
    } else {
      // Increment level and display subcategories
      setState(() {
        _currentLevel = level + 1;
        _subcategories = result;
      });
    }
  }

  Future<void> _navigateToDetailScreen(int subIndexId, String title) async {
    // Fetch metadata for the selected subcategory
    final linesMetadata = await _dbHelper.getLinesMetadata(subIndexId);

    // Extract Lines IDs from metadata
    final lineIds = linesMetadata.map((e) => e['LinesId']).toList();

    // Fetch final lines data using the extracted IDs
    final lines = await _dbHelper.getLines(lineIds);

    // Navigate to the detailed screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailedScreen(title: title, lines: lines),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemsToDisplay =
        _subcategories.isEmpty ? _categories : _subcategories;

    return Scaffold(
      appBar: AppBar(
        title: Text(_subcategories.isEmpty ? 'Categories' : 'Subcategories'),
        leading: _subcategories.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  setState(() {
                    _subcategories = [];
                    _currentLevel = 0; // Reset level on back
                  });

                  // Navigator.pop(context);
                },
              )
            : null,
      ),
      body: ListView.builder(
        itemCount: itemsToDisplay.length,
        itemBuilder: (context, index) {
          final item = itemsToDisplay[index];
          return ListTile(
            title: Text(item['EnglishName'] ?? item['EnglishIndexName']),
            trailing:
                item['HasChildren'] == 1 ? Icon(Icons.arrow_forward) : null,
            onTap: () async {
              if (_subcategories.isEmpty) {
                // When in categories view, fetch subcategories with Level = 0
                await _fetchSubcategories(item['Id'], 0);
              } else {
                // In subcategories view, increment level or navigate to detail
                if (item['HasChildren'] == 1) {
                  debugPrint("Inside Has Children ==1");
                  await _fetchSubcategories(item['Id'], _currentLevel);
                } else if (item['HasChildren'] == 0) {
                  _navigateToDetailScreen(item['Id'],
                      item['EnglishName'] ?? item['EnglishIndexName']);
                }
              }
            },
          );
        },
      ),
    );
  }
}

//===
